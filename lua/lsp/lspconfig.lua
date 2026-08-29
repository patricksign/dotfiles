-- LSP Configuration for Neovim 0.11+
local vim = vim
local util = require("me.util")

local on_attach = require("lsp.common").on_attach
local bin_name = "typescript-language-server"

-- add completion capability
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Common config applied to all servers
local common_config = {
    on_attach = on_attach,
    capabilities = capabilities
}

-- gopls
vim.lsp.config.gopls = {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        gopls = {
            analyses = {
                unusedparams = true
            },
            staticcheck = true
        }
    }
}

-- ts_ls (typescript/javascript)
vim.lsp.config.ts_ls = {
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { bin_name, "--stdio" },
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx"
    },
    root_markers = { "package.json", "tsconfig.json", ".git" }
}

-- vue_ls (Vue.js)
vim.lsp.config.vue_ls = {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "vue" },
    init_options = {
        vue = {
            hybridMode = false,
        },
    },
}

-- lua_ls
vim.lsp.config.lua_ls = {
    on_attach = on_attach,
    capabilities = capabilities
}

-- Enable the configured servers
vim.lsp.enable({
    "gopls",
    "ts_ls",
    "vue_ls",
    "lua_ls",
})
