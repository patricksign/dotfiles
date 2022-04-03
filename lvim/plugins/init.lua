-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny--
local lvim = require('lvim')
local vim = require('nvim')
lvim.plugins = {
  "nvim-treesitter/nvim-treesitter",
  "mfussenegger/nvim-jdtls",
  'williamboman/nvim-lsp-installer',
  'neovim/nvim-lspconfig',
  'hrsh7th/nvim-cmp',
  'nvim-telescope/telescope-dap.nvim',
	'nvim-telescope/telescope-fzf-native.nvim',
	'nvim-telescope/telescope-ui-select.nvim',
	'nvim-telescope/telescope.nvim',
}
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "jdtls" })
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  {
    command = "clang-format",
    filetypes = { "java" },
    extra_args = { "--style", "Google" },
  }
}
lvim.builtin.treesitter.ensure_installed = {
  "java",
}
