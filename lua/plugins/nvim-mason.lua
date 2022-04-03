return {
    {"williamboman/mason.nvim",
      build = function ()
        pcall(vim.cmd, "MasonUpdate")
      end,
      config = function()
        require("mason").setup({
          ensure_installed = {
            -- Java debugging tools
            "java-debug-adapter",
            "java-test",
            "jdtls",
            -- Other useful tools
            "lombok-nightly",
          }
        })
      end
    },
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
    },
}

