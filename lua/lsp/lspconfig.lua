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

-- dartls
vim.lsp.config.dartls = {
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

-- pyright
vim.lsp.config.pyright = {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        pyright = {
            analysis = {
                useLibraryCodeForTypes = true
            }
        }
    }
}

-- solargraph
vim.lsp.config.solargraph = {
    on_attach = on_attach,
    capabilities = capabilities
}

-- svelte
vim.lsp.config.svelte = {
    on_attach = on_attach,
    capabilities = capabilities
}

-- ts_ls (typescript)
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

-- erlangls
vim.lsp.config.erlangls = {
    on_attach = on_attach,
    capabilities = capabilities
}

-- lua_ls
vim.lsp.config.lua_ls = {
    on_attach = on_attach,
    capabilities = capabilities
}

-- metals (scala)
vim.lsp.config.metals = {
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "metals" },
    filetypes = { "scala" },
    init_options = {
        compilerOptions = {
            snippetAutoIndent = false
        },
        isHttpEnabled = true,
        statusBarProvider = "show-message"
    }
}

-- Enable the configured servers
vim.lsp.enable({
    "dartls",
    "gopls",
    "pyright",
    "solargraph",
    "svelte",
    "ts_ls",
    "erlangls",
    "lua_ls",
    "metals"
})
