-----------------------------------------------------------
-- Autocommand functions
-----------------------------------------------------------

-- Define autocommands with Lua APIs
-- See: h:api-autocmd, h:augroup
local vim = vim
local augroup = vim.api.nvim_create_augroup      -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd      -- Create autocommand
local usercmd = vim.api.nvim_create_user_command -- Create usercommand

-- local  wait_ms = 10

-- General settings:
--------------------

-- use Open instead of netrw
usercmd(
    'Browse',
    "silent execute '!open' shellescape(<q-args>,1)",
    { nargs = 1, bang = true }
)

-- Highlight on yank
augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
    group = 'YankHighlight',
    callback = function()
        vim.hl.on_yank({ higroup = 'IncSearch', timeout = '1000' })
    end
})

-- Remove whitespace on save
autocmd('BufWritePre', {
    pattern = '',
    command = ":%s/\\s\\+$//e"
})

--

-- -- Don't auto comment new lines
-- autocmd('BufEnter', {
--   pattern = '',
--   command = 'set fo-=c fo-=r fo-=o'
-- })

-- Terminal settings:
---------------------

-- Open a Terminal on the right tab
-- autocmd('CmdlineEnter', {
--   command = 'command! Term :botright vsplit term://$SHELL'
-- })

-- Enter insert mode when switching to terminal
-- autocmd('TermOpen', {
--   command = 'setlocal listchars= nonumber norelativenumber nocursorline',
-- })
--
-- autocmd('TermOpen', {
--   pattern = '',
--   command = 'startinsert'
-- })

-- Close terminal buffer on process exit
autocmd('BufLeave', {
    pattern = 'term://*',
    command = 'stopinsert'
})


autocmd('FileType', {
    pattern = "*.html,*.css",
    command = "EmmetInstall"
})

-- Enhanced auto-indentation for programming languages
autocmd('FileType', {
    pattern = { 'javascript', 'typescript', 'lua', 'go', 'html', 'css', 'vue' },
    callback = function()
        -- Enhanced 4-space indentation for all code
        vim.bo.tabstop = 4
        vim.bo.shiftwidth = 4
        vim.bo.softtabstop = 4
        vim.bo.expandtab = true
        vim.bo.smartindent = true
        vim.bo.cindent = true
        vim.o.shiftround = true -- Global option, use vim.o instead of vim.bo
        -- Better bracket handling
        vim.bo.cinoptions = "(0,u0,U0,t0,g0"
        vim.bo.cinkeys = "0{,0},0),0],!^F,o,O,e"
    end
})

-- Auto-indent on specific characters and improve bracket organization
autocmd('InsertCharPre', {
    callback = function()
        local char = vim.v.char
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]

        -- Auto-indent after opening bracket
        if char == '{' or char == '(' or char == '[' then
            -- Check if we have less than 4 spaces from beginning
            local indent = line:match("^%s*")
            if #indent < 4 then
                -- Schedule indent correction after insertion
                vim.schedule(function()
                    local new_line = vim.api.nvim_get_current_line()
                    local needed_spaces = 4 - #indent
                    if needed_spaces > 0 then
                        local spaces = string.rep(" ", needed_spaces)
                        local updated_line = spaces .. new_line:gsub("^%s*", "")
                        vim.api.nvim_set_current_line(updated_line)
                        vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], col + needed_spaces + 1 })
                    end
                end)
            end
        end
    end
})

-- Check current indentation settings
usercmd(
    'CheckIndent',
    function()
        local bo = vim.bo
        local settings = {
            filetype = bo.filetype,
            tabstop = bo.tabstop,
            shiftwidth = bo.shiftwidth,
            softtabstop = bo.softtabstop,
            expandtab = bo.expandtab,
            smartindent = bo.smartindent,
            cindent = bo.cindent
        }

        print("Current buffer indentation settings:")
        for key, value in pairs(settings) do
            print("  " .. key .. ": " .. tostring(value))
        end

        if bo.tabstop == 4 and bo.shiftwidth == 4 and bo.expandtab then
            print("✅ Indentation is correctly set to 4 spaces!")
        else
            print("⚠️  Indentation might not be optimal")
        end
    end,
    { desc = "Show current indentation settings for this buffer" }
)

-- Command to fix indentation on current buffer
usercmd(
    'FixIndent',
    function()
        -- Set proper 4-space indentation
        vim.bo.tabstop = 4
        vim.bo.shiftwidth = 4
        vim.bo.softtabstop = 4
        vim.bo.expandtab = true
        vim.bo.smartindent = true
        vim.bo.cindent = true
        vim.bo.shiftround = true

        -- Fix all lines with less than 4-space indentation
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local fixed_lines = {}
        local changes_made = 0

        for i, line in ipairs(lines) do
            local indent = line:match("^%s*")
            local content = line:gsub("^%s*", "")

            if content ~= "" and #indent > 0 and #indent < 4 then
                -- Fix indentation to minimum 4 spaces
                local new_line = string.rep(" ", 4) .. content
                table.insert(fixed_lines, new_line)
                changes_made = changes_made + 1
            else
                table.insert(fixed_lines, line)
            end
        end

        if changes_made > 0 then
            vim.api.nvim_buf_set_lines(0, 0, -1, false, fixed_lines)
            vim.notify("Fixed " .. changes_made .. " lines with insufficient indentation", vim.log.levels.INFO)
        else
            vim.notify("No indentation issues found", vim.log.levels.INFO)
        end
    end,
    { desc = "Fix indentation issues in current buffer" }
)
-- Autocmd for organizing imports on save for Go files
autocmd('BufWritePre', {
    pattern = '*.go',
    callback = function()
        local params = vim.lsp.util.make_range_params()
        params.context = { only = { "source.organizeImports" } }

        -- Use the modern API for Neovim 0.11+
        vim.lsp.buf.code_action({
            context = { only = { "source.organizeImports" } },
            apply = true,
        })
    end
})

augroup("AutoFormat", {})

autocmd("BufWritePost", {
    pattern = "*.lua",
    group = "AutoFormat",
    callback = function()
        vim.cmd("silent !black --quiet %")
        vim.cmd("edit")
    end,
}
)

vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
        local mode = vim.api.nvim_get_mode().mode
        local filetype = vim.bo.filetype

        if vim.bo.modified == true and mode == 'n' then
            if filetype ~= "lua" then
                vim.lsp.buf.format()
            end
        end
    end
})

-- Command to test auto-indentation behavior
usercmd(
    'TestIndent',
    function()
        -- Create a test buffer with various indentation scenarios
        local test_lines = {
            "function testFunc() {",
            "  if (condition) {",
            "console.log('hello');",
            "}",
            "}"
        }

        -- Create new buffer
        vim.cmd('new')
        vim.bo.filetype = 'javascript'

        -- Set the test content
        vim.api.nvim_buf_set_lines(0, 0, -1, false, test_lines)

        vim.notify("Test buffer created! Try:\n" ..
            "1. Press Tab on lines with <4 spaces\n" ..
            "2. Type '{' to see auto-bracket organization\n" ..
            "3. Use :FixIndent to fix all indentation\n" ..
            "4. Use :CheckIndent to verify settings", vim.log.levels.INFO)
    end,
    { desc = "Test auto-indentation behavior with sample code" }
)

-- Command to demo all indentation improvements
usercmd(
    'DemoIndent',
    function()
        vim.notify("🚀 Enhanced Auto-Indentation Features:\n\n" ..
            "✅ DEFAULT: Now 4 spaces (was 2 spaces)\n" ..
            "✅ AUTO-FIX: Lines with <4 spaces get auto-corrected\n" ..
            "✅ SMART TAB: Tab organizes code within brackets {}\n" ..
            "✅ BRACKET MAGIC: Type '{' for auto-bracket organization\n\n" ..
            "📝 Commands to try:\n" ..
            "• :TestIndent - Create test buffer\n" ..
            "• :FixIndent - Fix current buffer indentation\n" ..
            "• :CheckIndent - Check current settings\n\n" ..
            "⌨️  Key bindings:\n" ..
            "• Tab - Smart indentation (4 spaces minimum)\n" ..
            "• Shift+Tab - Reverse indentation\n" ..
            "• Visual mode: Tab/Shift+Tab for selection", vim.log.levels.INFO)
    end,
    { desc = "Show all indentation improvements and features" }
)
