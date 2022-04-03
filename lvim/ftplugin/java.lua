local vim = vim
local lvim = lvim
local status, jdtls = pcall(require, "jdtls")
if not status then
    return
end

-- Setup Workspace
local home = os.getenv "HOME"
local workspace_path = home .. "/env/vikki/github"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = workspace_path .. project_name


local remap = require("me.util").remap
-- Determine OS
local os_config = "linux"
if vim.fn.has "mac" == 1 then
    os_config = "mac"
end

-- Setup Capabilities
local capabilities = require("lvim.lsp").common_capabilities()
local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

-- Setup Testing and Debugging
local bundles = {}
local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")
vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. "packages/java-test/extension/server/*.jar"), "\n"))
vim.list_extend(
    bundles,
    vim.split(
        vim.fn.glob(mason_path .. "packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar")
    )
)

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
        "-javaagent:" .. home .. "/env/lombok.jar",
        "-jar",
        vim.fn.glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
        "-configuration",
        home .. "/.local/share/nvim/mason/packages/jdtls/config_" .. os_config,
        "-data",
        workspace_dir,
    },
    root_dir = require("jdtls.setup").find_root { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" },
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
        java = {
            eclipse = {
                downloadSources = true,
            },
            configuration = {
                updateBuildConfiguration = "interactive",
                runtimes = {
                    {
                        name = "JavaSE-17",
                        --   path = "/opt/homebrew/opt/openjdk@17/bin",
                        path = "/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home",
                    },
                },
            },
            maven = {
                downloadSources = true,
            },
            implementationsCodeLens = {
                enabled = true,
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
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    remap('n', 'gf', vim.lsp.buf.declaration, bufopts, "Go to declaration")
    remap('n', 'gd', vim.lsp.buf.definition, bufopts, "Go to definition")
    remap('n', 'gi', vim.lsp.buf.implementation, bufopts, "Go to implementation")
    remap('n', 'gr', vim.lsp.buf.references, bufopts, "Go to references")
    remap('n', 'hv', vim.lsp.buf.hover, bufopts, "Hover text")
    remap('n', '<C-l>', vim.lsp.diagnostic.show_line_diagnostics(), bufopts, "show line error")
    remap('n', '<C-k>', vim.lsp.buf.signature_help, bufopts, "Show signature")
    remap('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts, "Add workspace folder")
    remap('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts, "Remove workspace folder")
    remap('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts, "List workspace folders")
    remap('n', '<space>rk', vim.lsp.buf.rename, bufopts, "Rename")
    remap('n', '<space>ca', vim.lsp.buf.code_action, bufopts, "Code actions")
    vim.keymap.set('v', "<C-i>", "<ESC><CMD>lua vim.lsp.buf.range_code_action()<CR>",
        { noremap = true, silent = true, buffer = bufnr, desc = "Code actions" })
    remap('n', '<C-r>', function() vim.lsp.buf.format { async = true } end, bufopts, "Format file")

    remap("<leader>vc", jdtls.test_class, bufopts, "Test class (DAP)")
    remap("<leader>vm", jdtls.test_nearest_method, bufopts, "Test method (DAP)")
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

local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
    return
end

local opts = {
    mode = "n",   -- NORMAL mode
    prefix = "<leader>",
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = true, -- use `nowait` when creating keymaps
}

local vopts = {
    mode = "v",   -- VISUAL mode
    prefix = "<leader>",
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = true, -- use `nowait` when creating keymaps
}

local mappings = {
    C = {
        name = "Java",
        o = { "<Cmd>lua require'jdtls'.organize_imports()<CR>", "Organize Imports" },
        v = { "<Cmd>lua require('jdtls').extract_variable()<CR>", "Extract Variable" },
        c = { "<Cmd>lua require('jdtls').extract_constant()<CR>", "Extract Constant" },
        t = { "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", "Test Method" },
        T = { "<Cmd>lua require'jdtls'.test_class()<CR>", "Test Class" },
        u = { "<Cmd>JdtUpdateConfig<CR>", "Update Config" },
    },
}

local vmappings = {
    C = {
        name = "Java",
        v = { "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract Variable" },
        c = { "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", "Extract Constant" },
        m = { "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract Method" },
    },
}
which_key.register(mappings, opts)
which_key.register(vmappings, vopts)
which_key.register(vmappings, vopts)
