return {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
        'nvim-telescope/telescope-dap.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        'nvim-telescope/telescope-ui-select.nvim',
    },
    pickers = {
        search_history = {
            theme = "dropdown",
        }
    },
    config = function() require('config.telescope') end,
}
