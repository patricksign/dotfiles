require('telescope').setup({
    defaults = {
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
        },
        path_display = {
            shorten = {
                len = 3, exclude = { 1, -1 }
            },
            truncate = true
        },
        dynamic_preview_title = true,
        mappings = {
            n = {
                ['<c-d>'] = require('telescope.actions').delete_buffer
            },
            i = {
                ['<c-d>'] = require('telescope.actions').delete_buffer,
                ["<esc>"] = require('telescope.actions').close,
            },
        },
    },
    pickers = {
        lsp_references = {
            initial_mode = "normal",
            show_line = false,
        },
        lsp_definitions = {
            initial_mode = "normal",
        },
        lsp_implementations = {
            initial_mode = "normal",
        },
    },
    extensions = {
        fzf = {
            fuzzy = true,             -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
        },
    }
})
require('telescope').load_extension('fzf')
require('telescope').load_extension('ui-select')
require('telescope').load_extension('dap')

-- Add user command to test references
vim.api.nvim_create_user_command('TestReferences', function()
    vim.notify("Testing Telescope references - press 'gr' on any symbol to test auto-close behavior", vim.log.levels
    .INFO)
    vim.cmd('Telescope lsp_references')
end, { desc = "Test Telescope references picker" })
