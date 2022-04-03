local vim = vim

local M = {}
function M.baseConfig()
    local g                       = vim.g
    g.floaterm_gitcommit          = 'floaterm'
    g.floaterm_width              = 0.9
    g.floaterm_height             = 0.8
    g.floaterm_wintitle           = 0
    g.floaterm_autoclose          = 1
    g.floaterm_completeoptPreview = 0
    g.floaterm_keymap_toggle      = '<leader>ft'

    -- Add user command to test floaterm
    vim.api.nvim_create_user_command('TestFloaterm', function()
        vim.cmd('FloatermToggle')
        vim.notify("Floaterm should now be accessible via <leader>ft (space + ft)", vim.log.levels.INFO)
    end, { desc = "Test floaterm toggle functionality" })
end

return M
