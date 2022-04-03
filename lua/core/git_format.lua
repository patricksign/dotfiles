-- Git-based formatting utility for Java files
local M = {}

-- Check if a file is in a Git repository
function M.is_git_repo(file_path)
    local dir = vim.fn.fnamemodify(file_path, ':h')
    local git_root = vim.fn.system('git -C ' .. dir .. ' rev-parse --show-toplevel 2>/dev/null')
    return git_root ~= ''
end

-- Check if a file has been modified in Git
function M.is_file_modified(file_path)
    local git_status = vim.fn.system('git status --porcelain "' .. file_path .. '" 2>/dev/null')
    return git_status ~= ''
end

-- Get changed line ranges by comparing with Git HEAD
function M.get_changed_ranges(file_path)
    local changed_ranges = {}
    
    -- Get current buffer content
    local current_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    
    -- Get the version from Git HEAD
    local temp_file = vim.fn.tempname() .. '.java'
    local success = vim.fn.system('git show HEAD:"' .. file_path .. '" > "' .. temp_file .. '" 2>/dev/null')
    
    if success ~= 0 then
        -- File doesn't exist in HEAD (new file), consider all lines as changed
        table.insert(changed_ranges, {start = 1, ['end'] = #current_lines})
        return changed_ranges
    end
    
    -- Read the HEAD version
    local head_lines = {}
    local head_file = io.open(temp_file, 'r')
    if head_file then
        for line in head_file:lines() do
            table.insert(head_lines, line)
        end
        head_file:close()
    end
    
    -- Clean up temp file
    vim.fn.delete(temp_file)
    
    -- Find changed ranges using a simple diff algorithm
    local max_lines = math.max(#current_lines, #head_lines)
    local i = 1
    
    while i <= max_lines do
        local current_line = current_lines[i] or ''
        local head_line = head_lines[i] or ''
        
        if current_line ~= head_line then
            -- Found a change, find the range
            local start = i
            local end_line = i
            
            -- Look ahead to find the end of the change
            for j = i + 1, max_lines do
                local curr = current_lines[j] or ''
                local head = head_lines[j] or ''
                if curr == head then
                    break
                end
                end_line = j
            end
            
            table.insert(changed_ranges, {start = start, ['end'] = end_line})
            i = end_line + 1 -- Skip to after this change
        else
            i = i + 1
        end
    end
    
    return changed_ranges
end

-- Format only changed ranges
function M.format_changed_ranges(changed_ranges)
    if #changed_ranges == 0 then
        return false
    end
    
    vim.notify("Formatting " .. #changed_ranges .. " changed code blocks", vim.log.levels.INFO)
    
    -- Organize imports first
    pcall(function() require('jdtls').organize_imports() end)
    
    -- Format each changed range
    for _, range in ipairs(changed_ranges) do
        pcall(function()
            vim.lsp.buf.format({
                range = {
                    start = {range.start - 1, 0},
                    ['end'] = {range['end'] - 1, 0}
                },
                async = false,
                timeout_ms = 5000
            })
        end)
    end
    
    return true
end

-- Main function to handle Git-based formatting
function M.format_if_modified()
    local file_path = vim.api.nvim_buf_get_name(0)
    
    -- Check if this is a Git repository
    if not M.is_git_repo(file_path) then
        -- Not a Git repo, format entire file
        pcall(function() require('jdtls').organize_imports() end)
        vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
        return
    end
    
    -- Check if file has been modified
    if not M.is_file_modified(file_path) then
        -- File not modified in Git, don't format
        vim.notify("File not modified in Git, skipping auto-format", vim.log.levels.INFO)
        return
    end
    
    -- Get changed ranges
    local changed_ranges = M.get_changed_ranges(file_path)
    
    -- Try to format only changed ranges
    if not M.format_changed_ranges(changed_ranges) then
        -- Fallback to full file formatting
        vim.notify("No specific ranges found, formatting entire file", vim.log.levels.INFO)
        pcall(function() require('jdtls').organize_imports() end)
        vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
    end
end

return M 