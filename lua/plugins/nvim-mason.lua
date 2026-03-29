return {
    {"williamboman/mason.nvim",
      build = function ()
        pcall(vim.cmd, "MasonUpdate")
      end,
      config = function()
        require("mason").setup({
          ensure_installed = {}
        })
      end
    },
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
    },
}

