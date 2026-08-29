-- nvim-treesitter `main` branch (Neovim 0.12+).
-- The legacy `require'nvim-treesitter.configs'.setup{}` API no longer exists:
-- parsers are installed via .install{} and highlighting is enabled per-buffer
-- with vim.treesitter.start() from a FileType autocmd.
local ts = require('nvim-treesitter')

ts.setup {}

local ensure = {
    'go', 'gomod', 'gosum', 'lua', 'javascript',
    'typescript', 'tsx', 'html', 'css', 'vue',
}

-- Install any missing parsers (async; no-op for already-installed ones).
local installed = ts.get_installed()
local missing = vim.tbl_filter(function(lang)
    return not vim.tbl_contains(installed, lang)
end, ensure)
if #missing > 0 then
    ts.install(missing)
end

-- Enable treesitter highlighting for the relevant filetypes.
-- (filetypes differ from parser names for some languages, e.g. tsx/typescriptreact)
local filetypes = {
    'go', 'gomod', 'gosum', 'lua', 'javascript', 'javascriptreact',
    'typescript', 'typescriptreact', 'html', 'css', 'vue',
}
vim.api.nvim_create_autocmd('FileType', {
    pattern = filetypes,
    callback = function()
        pcall(vim.treesitter.start)
    end,
})
