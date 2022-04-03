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

local remap = require("me.util").remap
local bufopts = { silent = true, noremap = true }

remap("n", "<C-s>", "<cmd>:w!<cr>", bufopts, "Save File")
remap("n", "<C-q>", "<cmd>:q!<cr>", bufopts, "Quit File")
remap("n", "<leader><leader>", "<cmd>:noh<cr>", bufopts, "No highlight")
remap("n", "<leader>tg", "<cmd>:TigBlame<cr>", bufopts, "Git blame")
remap("n", "<C-f>", "<cmd>:NERDTreeFind<cr>", bufopts, "Current file location")
remap("n", "<C-n>", "<cmd>:NERDTreeToggle<cr>", bufopts, "Open left pannel")
remap("n", "<leader>m", "<cmd>:History<cr>", bufopts, "History open recent files")
remap("n", "<C-h>", "<C-w>h", bufopts, "Jump to left")
remap("n", "<C-j>", "<C-w>j", bufopts, "Jump to bottom")
remap("n", "<C-k>", "<C-w>k", bufopts, "Jump to top")
remap("n", "<C-l>", "<C-w>l", bufopts, "Jump to right")
remap("n", "<C-g>", "<cmd>:vsplit<cr>", bufopts, "vertical split")

lvim.builtin.dap.active = true
local config = {
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xms1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-javaagent:" .. home .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar",
    "-jar",
    vim.fn.glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
    "-configuration",
    home .. "/.local/share/nvim/mason/packages/jdtls/config_" .. os_config,
    "-data",
    workspace_dir,
  },
  root_dir = require("jdtls.setup").find_root { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" },
  capabilities = capabilities,

  settings = {
    java = {
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = {
          {
            name = "JavaSE-11",
            path = "~/.sdkman/candidates/java/11.0.17-tem",
          },
          {
            name = "JavaSE-18",
            path = "~/.sdkman/candidates/java/18.0.2-sem",
          },
        },
      },
      maven = {
        downloadSources = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      inlayHints = {
        parameterNames = {
          enabled = "all", -- literals, all, none
        },
      },
      format = {
        enabled = false,
      },
    },
    signatureHelp = { enabled = true },
    extendedClientCapabilities = extendedClientCapabilities,
  },
  init_options = {
    bundles = bundles,
  },
}

config["on_attach"] = function(client, bufnr)
  local _, _ = pcall(vim.lsp.codelens.refresh)
 require("jdtls").setup_dap({ hotcodereplace = "auto" })
 require("lvim.lsp").on_attach(client, bufnr)
  local status_ok, jdtls_dap = pcall(require, "jdtls.dap")
  if status_ok then
    jdtls_dap.setup_dap_main_class_configs()
  end
end

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = { "*.java" },
  callback = function()
    local _, _ = pcall(vim.lsp.codelens.refresh)
  end,
})

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "google_java_format", filetypes = { "java" } },
}

require("jdtls").start_or_attach(config)
