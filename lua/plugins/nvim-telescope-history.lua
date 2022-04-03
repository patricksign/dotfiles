return {
    'dawsers/telescope-file-history.nvim',
    dependencies = {
        'nvim-telescope/telescope.nvim'
    },
    config = function()
        require('file_history').setup {
            -- This is the location where it will create your file history repository
            backup_dir = "~/.file-history-git",
            -- command line to execute git
            git_cmd = "git"
        }
        require('telescope').load_extension('file_history')
    end
}
