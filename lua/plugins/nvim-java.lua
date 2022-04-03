return {
  'mfussenegger/nvim-jdtls',
  'akhaku/vim-java-unused-imports',
  'uiiaoo/java-syntax.vim',
  ft = {'java'},
  dependencies = {
    'neovim/nvim-lspconfig',
    'mfussenegger/nvim-dap',
    {
      'williamboman/mason.nvim',
      opts = {
        registries = {
          'github:mason-org/mason-registry',
        },
      },
    }
  }
}
