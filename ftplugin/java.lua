-- Clean JDTLS configuration - prevents multiple instances and retry loops
local vim = vim
local status_ok, jdtls = pcall(require, 'jdtls')
if not status_ok then
    vim.notify("JDTLS not found. Please install nvim-jdtls.", vim.log.levels.ERROR)
    return
end

-- Check if JDTLS is already running for this buffer
local clients = vim.lsp.get_clients({ bufnr = 0, name = 'jdtls' })
if #clients > 0 then
    -- JDTLS is already running, just set up keymaps
    local client = clients[1]
    if not client.is_stopped() then
        vim.notify("JDTLS already running for this buffer (ID: " .. client.id .. ")", vim.log.levels.INFO)
        return
    end
end

-- Check if we're already in the process of starting JDTLS
if vim.b.jdtls_starting then
    vim.notify("JDTLS is already starting for this buffer", vim.log.levels.INFO)
    return
end

-- Mark that we're starting JDTLS
vim.b.jdtls_starting = true

-- Debug info
vim.notify("Setting up JDTLS for Java file...", vim.log.levels.INFO)

-- Get proper OS config
local os_config = "mac_arm"
if vim.fn.has("mac") == 1 then
    if vim.fn.system("uname -m"):find("arm64") then
        os_config = "mac_arm"
    else
        os_config = "mac"
    end
elseif vim.fn.has("unix") == 1 then
    os_config = "linux"
elseif vim.fn.has("win32") == 1 then
    os_config = "win"
end

-- Setup workspace
-- Try to get project name from pom.xml first, fallback to directory name
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local pom_file = vim.fn.getcwd() .. "/pom.xml"
if vim.fn.filereadable(pom_file) == 1 then
    local pom_content = vim.fn.readfile(pom_file)
    for _, line in ipairs(pom_content) do
        local artifact_id = line:match('<artifactId>([^<]+)</artifactId>')
        if artifact_id then
            project_name = artifact_id
            break
        end
    end
end
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. project_name

-- Ensure workspace directory exists
vim.fn.mkdir(workspace_dir, "p")

-- Lombok configuration (optional)
local lombok_path = vim.fn.stdpath("data") .. "/mason/packages/lombok-nightly/lombok.jar"
local lombok_agent = ""
if vim.fn.filereadable(lombok_path) == 1 then
    lombok_agent = "-javaagent:" .. lombok_path
    vim.notify("Lombok found and will be used", vim.log.levels.INFO)
else
    vim.notify("Lombok not found, continuing without Lombok support", vim.log.levels.WARN)
end

-- LSP capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Testing and debugging bundles (optional)
local bundles = {}
local mason_path = vim.fn.stdpath("data") .. "/mason/"

-- Try to add Java test bundles (optional)
local test_path = mason_path .. "packages/java-test"
if vim.fn.isdirectory(test_path) == 1 then
    local test_jars = vim.fn.glob(test_path .. "/extension/server/*.jar")
    if test_jars ~= "" then
        vim.list_extend(bundles, vim.split(test_jars, "\n"))
        vim.notify("Java test bundles loaded", vim.log.levels.INFO)
    end
end

-- Try to add Java debug adapter bundles (optional)
local debug_path = mason_path .. "packages/java-debug-adapter"
if vim.fn.isdirectory(debug_path) == 1 then
    local debug_jars = vim.fn.glob(debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar")
    if debug_jars ~= "" then
        vim.list_extend(bundles, vim.split(debug_jars, "\n"))
        vim.notify("Java debug adapter bundles loaded: " .. debug_jars, vim.log.levels.INFO)
    else
        vim.notify("No Java debug adapter JAR files found", vim.log.levels.WARN)
    end
else
    vim.notify("Java debug adapter directory not found: " .. debug_path, vim.log.levels.WARN)
end

-- Build command line with optional Lombok agent
local cmd = {
    "/opt/homebrew/opt/openjdk@25/bin/java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Djava.awt.headless=true",
    "-Xms1g",
    "-Xmx4g",
    "-XX:+UseG1GC",
    "-XX:+UseStringDeduplication",
    "-XX:MaxGCPauseMillis=200",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
}

-- Add Lombok agent if available
if lombok_agent ~= "" then
    table.insert(cmd, lombok_agent)
end

-- Add remaining command line arguments
table.insert(cmd, "-jar")
table.insert(cmd,
    vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"))
table.insert(cmd, "-configuration")
table.insert(cmd, vim.fn.stdpath("data") .. "/mason/packages/jdtls/config_" .. os_config)
table.insert(cmd, "-data")
table.insert(cmd, workspace_dir)

local config = {
    cmd = cmd,
    root_dir = require('jdtls.setup').find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
    settings = {
        java = {
            configuration = {
                runtimes = {
                    {
                        name = "JavaSE-22",
                        path = "/Library/Java/JavaVirtualMachines/jdk-22.jdk/Contents/Home",
                        default = true
                    },
                    {
                        name = "JavaSE-17",
                        path = "/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home"
                    },
                    {
                        name = "JavaSE-8",
                        path = "/Library/Java/JavaVirtualMachines/jdk-1.8.jdk/Contents/Home"
                    }
                }
            },
            eclipse = {
                downloadSources = true,
            },
            maxConcurrentBuilds = 8,
            maxConcurrentBuildsPerProject = 8,
            autobuild = {
                enabled = true,
            },
            saveActions = {
                organizeImports = true,
            },
            configuration = {
                updateBuildConfiguration = "interactive",
                runtimes = {
                    {
                        name = "JavaSE-22",
                        path = "/Library/Java/JavaVirtualMachines/jdk-22.jdk/Contents/Home",
                        default = true,
                    },
                    {
                        name = "JavaSE-1.8",
                        path = "/Library/Java/JavaVirtualMachines/jdk-1.8.jdk/Contents/Home",
                        default = false,
                    }
                }
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
                    enabled = "all",
                },
            },
            format = {
                enabled = true,
                insertSpaces = true,
                tabSize = 4,
            },
            codeGeneration = {
                useBlocks = true,
            },
            preferences = {
                ["org.eclipse.jdt.core.formatter.tabulation.char"] = "space",
                ["org.eclipse.jdt.core.formatter.tabulation.size"] = "4",
                ["org.eclipse.jdt.core.formatter.indentation.size"] = "4",
                ["org.eclipse.jdt.core.formatter.continuation_indentation"] = "4",
                ["org.eclipse.jdt.core.formatter.continuation_indentation_for_array_initializer"] = "4",
                ["org.eclipse.jdt.core.formatter.indent_statements_compare_to_block"] = "true",
                ["org.eclipse.jdt.core.formatter.indent_statements_compare_to_body"] = "true",
                ["org.eclipse.jdt.core.formatter.indent_body_declarations_compare_to_type_header"] = "true",
                ["org.eclipse.jdt.core.formatter.indent_breaks_compare_to_cases"] = "true",
                ["org.eclipse.jdt.core.formatter.indent_switchstatements_compare_to_cases"] = "true",
                ["org.eclipse.jdt.core.formatter.indent_switchstatements_compare_to_switch"] = "true",
                ["org.eclipse.jdt.core.formatter.insert_space_before_assignment_operator"] = "insert",
                ["org.eclipse.jdt.core.formatter.insert_space_after_assignment_operator"] = "insert",
                ["org.eclipse.jdt.core.formatter.insert_space_before_binary_operator"] = "insert",
                ["org.eclipse.jdt.core.formatter.insert_space_after_binary_operator"] = "insert",
                ["org.eclipse.jdt.core.formatter.insert_space_after_comma_in_method_declaration_parameters"] = "insert",
                ["org.eclipse.jdt.core.formatter.insert_space_after_comma_in_method_invocation_arguments"] = "insert",
                ["org.eclipse.jdt.core.formatter.brace_position_for_type_declaration"] = "end_of_line",
                ["org.eclipse.jdt.core.formatter.brace_position_for_method_declaration"] = "end_of_line",
                ["org.eclipse.jdt.core.formatter.brace_position_for_constructor_declaration"] = "end_of_line",
                ["org.eclipse.jdt.core.formatter.brace_position_for_block"] = "end_of_line",
                ["org.eclipse.jdt.core.formatter.brace_position_for_switch"] = "end_of_line",
                ["org.eclipse.jdt.core.formatter.brace_position_for_array_initializer"] = "end_of_line",
                ["org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_method_declaration"] = "insert",
                ["org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_type_declaration"] = "insert",
                ["org.eclipse.jdt.core.formatter.insert_space_before_opening_brace_in_block"] = "insert",
                ["org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_if"] = "insert",
                ["org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_for"] = "insert",
                ["org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_while"] = "insert",
                ["org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_method_declaration"] =
                "do not insert",
                ["org.eclipse.jdt.core.formatter.insert_space_before_opening_paren_in_method_invocation"] =
                "do not insert",
                ["org.eclipse.jdt.core.formatter.lineSplit"] = "240",
                ["org.eclipse.jdt.core.formatter.comment.line_length"] = "240",
            },
            signatureHelp = {
                enabled = true,
            },
            contentProvider = {
                preferred = "fernflower",
            },
            codeGeneration = {
                toString = {
                    template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
                }
            }
        },
        -- Force project name to be the correct one
        projectName = project_name,
    },
    capabilities = capabilities,
    init_options = {
        bundles = bundles,
    },
}

-- On attach function
config['on_attach'] = function(client, bufnr)
    -- Clear the starting flag
    vim.b.jdtls_starting = nil

    -- Import LSP common on_attach
    local common_on_attach = require("lsp.common").on_attach
    if common_on_attach then
        common_on_attach(client, bufnr)
    end

    -- Set up formatexpr for visual mode formatting
    vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr()"

    -- Enable smart auto-formatting using Git to detect changed lines
    if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
                pcall(function()
                    local git_format = require('core.git_format')
                    git_format.format_if_modified()
                end)
            end,
        })
    end

    -- Enable codelens
    if client.server_capabilities.codeLensProvider then
        vim.lsp.codelens.refresh()
    end

    -- Setup DAP if available
    local status_ok, jdtls_dap = pcall(require, "jdtls.dap")
    if status_ok then
        jdtls_dap.setup_dap_main_class_configs()
        -- Setup the Java debug adapter
        jdtls_dap.setup_dap()
    end

    -- Setup JDTLS DAP with hot code replace
    local jdtls_ok, jdtls = pcall(require, "jdtls")
    if jdtls_ok then
        jdtls.setup_dap({ hotcodereplace = "auto" })
    end

    -- Setup Java test debugging configurations
    local setup_java_test_debug_ok, _ = pcall(function()
        if _G.setup_java_test_debug then
            _G.setup_java_test_debug()
        end
    end)
    if not setup_java_test_debug_ok then
        vim.notify("Could not setup Java test debug configurations", vim.log.levels.WARN)
    end

    -- Java-specific keymaps
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    local remap = require("me.util").remap

    -- Direct key mappings for Java LSP navigation - use explicit function calls
    vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end,
        { noremap = true, silent = true, buffer = 0, desc = "Go to definition (JDTLS)" })

    vim.keymap.set('n', 'gi', function() vim.lsp.buf.implementation() end,
        { noremap = true, silent = true, buffer = 0, desc = "Go to implementation (JDTLS)" })

    vim.keymap.set('n', 'gf', function() vim.lsp.buf.declaration() end,
        { noremap = true, silent = true, buffer = 0, desc = "Go to declaration (JDTLS)" })

    -- Also add leader key alternatives in case the above conflict with Vim defaults
    vim.keymap.set('n', '<leader>gd', function() vim.lsp.buf.definition() end,
        { noremap = true, silent = true, buffer = 0, desc = "Go to definition (JDTLS)" })

    vim.keymap.set('n', '<leader>gi', function() vim.lsp.buf.implementation() end,
        { noremap = true, silent = true, buffer = 0, desc = "Go to implementation (JDTLS)" })

    vim.keymap.set('n', '<leader>gf', function() vim.lsp.buf.declaration() end,
        { noremap = true, silent = true, buffer = 0, desc = "Go to declaration (JDTLS)" })

    -- Keep the original mappings too for compatibility
    remap('n', 'gd', vim.lsp.buf.definition, bufopts, "Go to definition (JDTLS)")
    remap('n', 'gi', vim.lsp.buf.implementation, bufopts, "Go to implementation (JDTLS)")
    remap('n', 'gf', vim.lsp.buf.declaration, bufopts, "Go to declaration (JDTLS)")
    remap('n', 'gr', '<cmd>Telescope lsp_references<cr>', bufopts, "Go to references (Telescope)")
    remap('n', '<leader>co', function() require('jdtls').organize_imports() end, bufopts, "Organize imports")
    remap('n', '<leader>cf', function() vim.lsp.buf.format() end, bufopts, "Format entire file")
    remap('v', '<leader>cf', function()
        local start_pos = vim.api.nvim_buf_get_mark(0, '<')
        local end_pos = vim.api.nvim_buf_get_mark(0, '>')
        vim.notify(string.format("Formatting range: line %d to %d", start_pos[1], end_pos[1]), vim.log.levels.INFO)
        vim.cmd('normal! gq')
        vim.notify("Selected code formatted successfully!", vim.log.levels.INFO)
    end, bufopts, "Format selected code")
    remap('v', '=', function()
        local start_pos = vim.api.nvim_buf_get_mark(0, '<')
        local end_pos = vim.api.nvim_buf_get_mark(0, '>')
        vim.notify(string.format("Formatting range: line %d to %d", start_pos[1], end_pos[1]), vim.log.levels.INFO)
        vim.cmd('normal! =')
    end, bufopts, "Format selected code (alternative)")
    remap('n', '<leader>ci', function() require('jdtls').organize_imports() end, bufopts, "Organize imports only")
    remap('n', '<leader>ca', function()
        require('jdtls').organize_imports()
        vim.lsp.buf.format()
    end, bufopts, "Organize imports + format entire file")
    remap('n', '<leader>cv', function() require('jdtls').extract_variable() end, bufopts, "Extract variable")
    remap('n', '<leader>cc', function() require('jdtls').extract_constant() end, bufopts, "Extract constant")
    remap('n', '<leader>cm', function() require('jdtls').extract_method() end, bufopts, "Extract method")
    remap('n', '<leader>ct', function() require('jdtls').test_nearest_method() end, bufopts, "Test method")
    remap('n', '<leader>cT', function() require('jdtls').test_class() end, bufopts, "Test class")

    -- Debug test keymaps (as described in JAVA_DEBUG_METHODS.md)
    remap('n', '<leader>dt', function()
        -- Debug current test method
        local dap_ok, dap = pcall(require, 'dap')
        if not dap_ok then
            vim.notify("DAP not available", vim.log.levels.ERROR)
            return
        end

        -- Find test configuration for current method
        if dap.configurations.java then
            for _, config in ipairs(dap.configurations.java) do
                if config.name and config.name:match("Debug Test.*Method") then
                    dap.run(config)
                    return
                end
            end
        end

        vim.notify("No test debug configuration found", vim.log.levels.WARN)
    end, bufopts, "Debug: Test Method")

    remap('n', '<leader>dT', function()
        -- Debug current test class
        local dap_ok, dap = pcall(require, 'dap')
        if not dap_ok then
            vim.notify("DAP not available", vim.log.levels.ERROR)
            return
        end

        -- Find test configuration for current class
        if dap.configurations.java then
            for _, config in ipairs(dap.configurations.java) do
                if config.name and config.name:match("Debug Test.*Class") then
                    dap.run(config)
                    return
                end
            end
        end

        vim.notify("No test debug configuration found", vim.log.levels.WARN)
    end, bufopts, "Debug: Test Class")

    -- Manual completion triggers
    remap('i', '<C-Space>', function()
        local cmp_ok, cmp = pcall(require, 'cmp')
        if cmp_ok then
            cmp.complete()
        else
            vim.lsp.buf.completion()
        end
    end, bufopts, "Trigger LSP completion")

    remap('i', '<C-x><C-o>', function()
        vim.lsp.buf.completion()
    end, bufopts, "Trigger omnifunc completion")

    vim.notify("JDTLS attached successfully to buffer " .. bufnr, vim.log.levels.INFO)
end

-- Start JDTLS with error handling
vim.notify("Starting JDTLS...", vim.log.levels.INFO)
local success, result = pcall(function()
    jdtls.start_or_attach(config)
end)

if not success then
    vim.b.jdtls_starting = nil
    vim.notify("JDTLS failed to start: " .. tostring(result), vim.log.levels.ERROR)
else
    vim.notify("JDTLS start command executed successfully", vim.log.levels.INFO)
end

-- Auto-refresh codelens (but don't auto-format)
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = { "*.java" },
    callback = function()
        local _, _ = pcall(vim.lsp.codelens.refresh)
    end,
})

-- Set basic Java buffer options
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4
vim.bo.expandtab = true
vim.bo.smartindent = true
vim.bo.cindent = true
vim.bo.autoindent = true
