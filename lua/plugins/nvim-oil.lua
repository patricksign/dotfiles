return {
    'stevearc/oil.nvim',
    config = function()
        require("oil").setup({
            skip_confirm_for_simple_edits = true,
        })
    end
}
