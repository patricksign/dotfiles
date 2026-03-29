return {
    'hedyhli/outline.nvim',
    cmd = { 'Outline', 'OutlineOpen' },
    config = function()
        require("outline").setup {
            outline_window = {
                auto_close = true,
            },
        }
    end
}
