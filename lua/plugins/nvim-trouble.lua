return {
    'folke/trouble.nvim',
    config = function()
        require("trouble").setup({
            mode = "document_diagnostics"
        })
    end
}
