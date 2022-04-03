local remap = require("me.util").remap
-----------------------------------------------------------
-- Define keymaps of Neovim and installed plugins.
-----------------------------------------------------------
local vim = vim
local bufopts = { silent = true, noremap = true }
-- local bufopts = require("lsp.common").bufopts

-- disable search highlighting by pressing enter
remap("n", "<cr>", "<cmd>:nohlsearch<cr><cr>")
remap("n", "<leader>b", "<cmd>:FineCmdline<cr>")

-- tab management
remap("n", "<C-Insert>", "<cmd>:tabnew<cr>", bufopts, "New tab")
remap("n", "<C-Delete>", "<cmd>:tabclose<cr>", bufopts, "Close tab")
remap("i", "<C-Insert>", "<cmd>:tabnew<cr>", bufopts, "New tab")
remap("i", "<C-Delete>", "<cmd>:tabclose<cr>", bufopts, "Close tab")

-- Enhanced tab behavior for code organization (works with nvim-cmp)
vim.keymap.set("i", "<Tab>", function()
    -- Check if nvim-cmp is available and completion menu is visible
    local cmp_status, cmp = pcall(require, 'cmp')
    if cmp_status and cmp.visible() then
        cmp.select_next_item()
        return
    end

    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local before_cursor = line:sub(1, col)

    -- Check if we're inside brackets and need organization
    local inside_brackets = before_cursor:match("[{%(%[]%s*$")
    if inside_brackets then
        -- We're right after opening bracket, provide proper indentation
        local current_indent = line:match("^%s*")
        local new_indent = current_indent .. string.rep(" ", 4)
        local keys = vim.api.nvim_replace_termcodes("\n" .. new_indent .. "\n" .. current_indent .. "<Up><End>", true,
            false, true)
        vim.api.nvim_feedkeys(keys, "n", false)
        return
    end

    -- Check if line needs more indentation (less than 4 spaces)
    local indent = before_cursor:match("^%s*")
    if #indent < 4 and before_cursor:match("^%s*$") then
        local needed = 4 - #indent
        local spaces = string.rep(" ", needed)
        vim.api.nvim_feedkeys(spaces, "n", false)
        return
    end

    -- Default tab behavior (4 spaces)
    vim.api.nvim_feedkeys("    ", "n", false)
end, { desc = "Smart tab for code organization" })

-- Shift+Tab for reverse indentation
vim.keymap.set("i", "<S-Tab>", function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local before_cursor = line:sub(1, col)

    -- Remove 4 spaces if possible
    if before_cursor:match("%s%s%s%s$") then
        local keys = vim.api.nvim_replace_termcodes("<BS><BS><BS><BS>", true, false, true)
        vim.api.nvim_feedkeys(keys, "n", false)
    elseif before_cursor:match("%s+$") then
        local keys = vim.api.nvim_replace_termcodes("<BS>", true, false, true)
        vim.api.nvim_feedkeys(keys, "n", false)
    else
        local keys = vim.api.nvim_replace_termcodes("<BS>", true, false, true)
        vim.api.nvim_feedkeys(keys, "n", false)
    end
end, { desc = "Reverse indent" })

-- Normal mode tab for indenting selected text or current line
remap("n", "<Tab>", function()
    local line = vim.api.nvim_get_current_line()
    local indent = line:match("^%s*")

    -- If line has less than 4 spaces, fix it
    if #indent < 4 then
        local needed = 4 - #indent
        vim.api.nvim_set_current_line(string.rep(" ", needed) .. line:gsub("^%s*", ""))
    else
        -- Regular indent
        vim.cmd("normal! >>")
    end
end, bufopts, "Indent line with 4-space minimum")

-- Visual mode tab for indenting selection
remap("v", "<Tab>", ">gv", bufopts, "Indent selection")
remap("v", "<S-Tab>", "<gv", bufopts, "Reverse indent selection")

-- custom
remap("n", "<C-s>", "<cmd>:w!<cr>", bufopts, "Save File")
remap("n", "<C-q>", "<cmd>:q!<cr>", bufopts, "Quit File")
remap("n", "<leader><leader>", "<cmd>:noh<cr>", bufopts, "No highlight")
remap("n", "<leader>tg", "<cmd>:TigBlame<cr>", bufopts, "Git blame")
remap("n", "<C-f>", "<cmd>:NERDTreeFind<cr>", bufopts, "Current file location")
remap("n", "<C-n>", "<cmd>:NERDTreeToggle<cr>", bufopts, "Open left pannel")
remap("n", "<leader>m", "<cmd>:History<cr>", bufopts, "History open recent files")
-- remap("n", "<leader>m", "<cmd>:Telescope file_history history <cr>", bufopts, "History open recent files")
remap("n", "<C-h>", "<C-w>h", bufopts, "Jump to left")
remap("n", "<C-j>", "<C-w>j", bufopts, "Jump to bottom")
remap("n", "<C-k>", "<C-w>k", bufopts, "Jump to top")
remap("n", "<C-l>", "<C-w>l", bufopts, "Jump to right")
remap("n", "<C-g>", "<cmd>:vsplit<cr>", bufopts, "vertical split")
remap("n", "<C-e>", "<cmd>:lua vim.diagnostic.open_float()<cr>", bufopts, "load error multiline")
vim.g.go_addtags_transform = 'snakecase' -- snakecase, camelcase
remap("n", "<leader>fj", "<cmd>:GoAddTags json,omitempty<Cr>", bufopts, "generation json tag")

-- telescope
remap("n", "<leader>lc", "<cmd>:FZF!<cr>", bufopts, "Find file from current folfer")
remap("n", "<C-a>", "<cmd>Telescope find_files<cr>", bufopts, "Find file")
remap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", bufopts, "Grep")
remap("n", "<leader>h", "<cmd>Telescope git_stash<cr>", bufopts, "Git Stash History")
remap("n", "<leader>bf", "<cmd>Telescope buffers<cr>", bufopts, "Find buffer")
remap("n", "<leader>fm", "<cmd>Telescope marks<cr>", bufopts, "Find mark")
remap("n", "<C-x>", "<cmd>Telescope lsp_references<cr>", bufopts, "Find references in current folder (LSP)")
remap("n", "<C-z>", "<cmd>Telescope lsp_document_symbols<cr>", bufopts, "Find symbols method in a current file (LSP)")
remap("n", "<C-i>", "<cmd>Telescope lsp_incoming_calls<cr>", bufopts, "Find incoming calls in current file(LSP)")
remap("n", "<leader>fo", "<cmd>Telescope lsp_outgoing_calls<cr>", bufopts, "Find outgoing calls from outside (LSP)")
remap("n", "<leader>fx", "<cmd>Telescope diagnostics bufnr=0<cr>", bufopts, "Find errors (LSP)")

-- floaterm (fixed conflict with Java extract constant)
remap("n", "<leader>ft", "<cmd>:FloatermToggle<cr>", bufopts, "Toggle float terminal")

remap("n", "th", "<cmd>:tabfirst<cr>", bufopts, "First tab")
remap("n", "tk", "<cmd>:tabnext<cr>", bufopts, "Next tab")
remap("n", "tj", "<cmd>:tabprev<cr>", bufopts, "Previous tab")
remap("n", "tl", "<cmd>:tablast<cr>", bufopts, "Last tab")
remap("n", "tt", "<cmd>:tabedit<cr>", bufopts, "New tab")
remap("n", "td", "<cmd>:tabclose<cr>", bufopts, "Close tab")
remap("n", "tn", "<cmd>:tabmove -1<cr>", bufopts, "Move tab next")
remap("n", "tm", "<cmd>:tabmove +1<cr>", bufopts, "Move tab previous")

-- window management
remap("n", "<C-S-Right>", "<cmd>:vertical resize -1<cr>", bufopts, "Minimize window")
remap("n", "<C-S-Left>", "<cmd>:vertical resize +1<cr>", bufopts, "Maximize window")

-- formatting
remap("n", "Q", "gqap", bufopts, "Format paragraph")
remap("x", "Q", "gq", bufopts, "Format paragraph")
remap("n", "<leader>Q", "vapJgqap", bufopts, "Merge paragraphs")

--
-- Plugins
--

-- vim-marked
remap("n", "<leader>mo", "<cmd>MarkedOpen<cr>", bufopts, "Open marked")

-- vim-pencil
remap("n", "<leader>qc", "<Plug>ReplaceWithCurly", bufopts, "Curl quotes")
remap("n", "<leader>qs", "<Plug>ReplaceWithStraight", bufopts, "Straighten quotes")

-- trouble
remap("n", "<leader>xx", "<cmd>TroubleToggle<cr>", bufopts, "Display errors")
remap("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", bufopts, "Display workspace errors")
remap("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", bufopts, "Display document errors")

-- symbols-outline
remap("n", "<leader>o", "<cmd>SymbolsOutline<cr>", bufopts, "Show symbols")

-- oil
remap("n", "<leader>n", "<cmd>Oil<cr>", bufopts, "Oil")

-- vim-test
remap("n", "<leader>vt", "<cmd>TestNearest<cr>", bufopts, "Test nearest")
remap("n", "<leader>vf", "<cmd>TestFile<cr>", bufopts, "Test file")
remap("n", "<leader>vs", "<cmd>TestSuite<cr>", bufopts, "Test suite")
remap("n", "<leader>vl", "<cmd>TestLast<cr>", bufopts, "Test last")
remap("n", "<leader>vg", "<cmd>TestVisit<cr>", bufopts, "Go to test")

-- nvim-dap
remap("n", "<leader>bb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", bufopts, "Set breakpoint")
remap("n", "<leader>bc", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>", bufopts,
    "Set conditional breakpoint")
remap("n", "<leader>bl", "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>",
    bufopts, "Set log point")
remap("n", "<leader>br", "<cmd>lua require'dap'.clear_breakpoints()<cr>", bufopts, "Clear breakpoints")
remap("n", "<leader>ba", "<cmd>Telescope dap list_breakpoints<cr>", bufopts, "List breakpoints")

remap("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", bufopts, "Continue")
remap("n", "<leader>dj", "<cmd>lua require'dap'.step_over()<cr>", bufopts, "Step over")
remap("n", "<leader>dk", "<cmd>lua require'dap'.step_into()<cr>", bufopts, "Step into")
remap("n", "<leader>do", "<cmd>lua require'dap'.step_out()<cr>", bufopts, "Step out")
remap("n", "<leader>dd", "<cmd>lua require'dap'.disconnect()<cr>", bufopts, "Disconnect")
remap("n", "<leader>dt", "<cmd>lua require'dap'.terminate()<cr>", bufopts, "Terminate")
remap("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", bufopts, "Open REPL")
remap("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>", bufopts, "Run last")
remap("n", "<leader>di", function() require "dap.ui.widgets".hover() end, bufopts, "Variables")
remap("n", "<leader>d?", function()
    local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes)
end, bufopts, "Scopes")
remap("n", "<leader>df", "<cmd>Telescope dap frames<cr>", bufopts, "List frames")
remap("n", "<leader>dh", "<cmd>Telescope dap commands<cr>", bufopts, "List commands")

remap("n", "<leader>pl", "<cmd>:TigGrep<cr>", bufopts, "tig grep multi use")
