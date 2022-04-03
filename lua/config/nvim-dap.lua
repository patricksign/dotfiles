require('dap.ext.vscode').load_launchjs()

local dap = require('dap')
dap.defaults.fallback.terminal_win_cmd = 'tabnew'

-- Helper function to get project name from pom.xml or fallback to directory name
local function get_project_name()
    local pom_file = vim.fn.getcwd() .. "/pom.xml"
    if vim.fn.filereadable(pom_file) == 1 then
        local pom_content = vim.fn.readfile(pom_file)
        for _, line in ipairs(pom_content) do
            local artifact_id = line:match('<artifactId>([^<]+)</artifactId>')
            if artifact_id then
                return artifact_id
            end
        end
    end
    return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

-- ============================================================================
-- JAVA DEBUG CONFIGURATION
-- ============================================================================

-- Java debugging configuration with multiple runtime support
dap.configurations.java = {
  {
    type = 'java',
    request = 'launch',
    name = "Debug (Launch) - Current File",
    mainClass = function()
      -- Automatically detect main class from current file
      local current_file = vim.fn.expand('%:p')
      if current_file:match('%.java$') then
        local package_name = ""
        local class_name = vim.fn.expand('%:t:r')
        
        -- Try to extract package name from file
        local lines = vim.fn.readfile(current_file)
        for _, line in ipairs(lines) do
          local pkg = line:match('^package%s+([%w%.]+)%s*;')
          if pkg then
            package_name = pkg .. "."
            break
          end
        end
        
        return package_name .. class_name
      end
      return ""
    end,
    projectName = function()
      return get_project_name()
    end,
    javaExec = "/Library/Java/JavaVirtualMachines/jdk-22.jdk/Contents/Home/bin/java",
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = '',
    vmArgs = '-Xmx2G',
    env = {}, -- Environment variables will be set here
  },
  {
    type = 'java',
    request = 'attach',
    name = "Debug (Attach) - Remote",
    hostName = "127.0.0.1",
    port = 5005,
  },
  {
    type = 'java',
    request = 'launch',
    name = "Debug (Launch) with JDK 17",
    mainClass = function()
      return vim.fn.input('Main class (with package): ', '', 'customlist,v:lua.require"jdtls".complete_main_class')
    end,
    projectName = function()
      return get_project_name()
    end,
    javaExec = "/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home/bin/java",
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = function()
      return vim.fn.input('Program arguments: ')
    end,
    vmArgs = function()
      return vim.fn.input('VM arguments: ', '-Xmx2G')
    end,
    env = {}, -- Environment variables will be set here
  },
  {
    type = 'java',
    request = 'launch',
    name = "Debug (Launch) with JDK 8",
    mainClass = function()
      return vim.fn.input('Main class (with package): ', '', 'customlist,v:lua.require"jdtls".complete_main_class')
    end,
    projectName = function()
      return get_project_name()
    end,
    javaExec = "/Library/Java/JavaVirtualMachines/jdk-1.8.jdk/Contents/Home/bin/java",
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = function()
      return vim.fn.input('Program arguments: ')
    end,
    vmArgs = '-Xmx1G',
    env = {}, -- Environment variables will be set here
  },
}

-- Java debug adapter configuration
-- The Java debug adapter is handled by JDTLS, so we don't need to configure it manually
-- JDTLS will automatically set up the debug adapter when it starts

-- Check if Java debug adapter is installed (silent mode)
local function check_java_debug_adapter()
  local mason_path = vim.fn.stdpath('data') .. '/mason/packages/java-debug-adapter'
  if vim.fn.isdirectory(mason_path) ~= 1 then
    -- Only log this to the log file, no notifications
    print("Java debug adapter not found at: " .. mason_path)
  end
end

-- Run check when DAP is loaded
vim.defer_fn(check_java_debug_adapter, 1000)

-- ============================================================================
-- DEBUG UI SETUP
-- ============================================================================

-- DAP UI configuration for better debugging experience
local dapui_ok, dapui = pcall(require, 'dapui')
if dapui_ok then
  dapui.setup({
    icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
    mappings = {
      -- Use a table to apply multiple mappings
      expand = { "<CR>", "<2-LeftMouse>" },
      open = "o",
      remove = "d",
      edit = "e",
      repl = "r",
      toggle = "t",
    },
    -- Expand lines larger than the window
    expand_lines = vim.fn.has("nvim-0.7") == 1,
    layouts = {
      {
        elements = {
          { id = "scopes", size = 0.25 },
          "breakpoints",
          "stacks",
          "watches",
        },
        size = 40, -- columns
        position = "left",
      },
      {
        elements = {
          "repl",
          "console",
        },
        size = 0.25, -- 25% of total lines
        position = "bottom",
      },
    },
    controls = {
      enabled = true,
      element = "repl",
      icons = {
        pause = "",
        play = "",
        step_into = "",
        step_over = "",
        step_out = "",
        step_back = "",
        run_last = "↻",
        terminate = "□",
      },
    },
    floating = {
      max_height = nil, -- These can be integers or a float between 0 and 1.
      max_width = nil,   -- Floats will be treated as percentage of your screen.
      border = "single", -- Border style. Can be "single", "double" or "rounded"
      mappings = {
        close = { "q", "<Esc>" },
      },
    },
    windows = { indent = 1 },
    render = {
      max_type_length = nil, -- Can be integer or nil.
      max_value_lines = 100, -- Can be integer or nil.
    }
  })

  -- Auto-open DAP UI when debugging starts
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
end

-- ============================================================================
-- VIRTUAL TEXT AND SIGNS
-- ============================================================================

-- DAP virtual text for inline variable values
local virtual_text_ok, virtual_text = pcall(require, 'nvim-dap-virtual-text')
if virtual_text_ok then
  virtual_text.setup({
    enabled = true,
    enabled_commands = true,
    highlight_changed_variables = true,
    highlight_new_as_changed = false,
    show_stop_reason = true,
    commented = false,
    only_first_definition = true,
    all_references = false,
    filter_references_pattern = '<module',
    virt_text_pos = 'eol',
    all_frames = false,
    virt_lines = false,
    virt_text_win_col = nil
  })
end

-- Debug signs configuration
vim.fn.sign_define('DapBreakpoint', {
  text = '●',
  texthl = 'DapBreakpoint',
  linehl = '',
  numhl = ''
})

vim.fn.sign_define('DapBreakpointCondition', {
  text = '◆',
  texthl = 'DapBreakpointCondition',
  linehl = '',
  numhl = ''
})

vim.fn.sign_define('DapBreakpointRejected', {
  text = '○',
  texthl = 'DapBreakpointRejected',
  linehl = '',
  numhl = ''
})

vim.fn.sign_define('DapLogPoint', {
  text = '◇',
  texthl = 'DapLogPoint',
  linehl = '',
  numhl = ''
})

vim.fn.sign_define('DapStopped', {
  text = '→',
  texthl = 'DapStopped',
  linehl = 'DapStoppedLine',
  numhl = ''
})

-- ============================================================================
-- DEBUG KEYMAPS
-- ============================================================================

-- Global debug keymaps
local remap = function(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Main debug controls
remap('n', '<F5>', function() 
  -- Use the first configuration (launch) instead of continue
  if dap.configurations.java and dap.configurations.java[1] then
    dap.run(dap.configurations.java[1])
  else
    dap.continue()
  end
end, { desc = "Debug: Launch Current File" })
remap('n', '<F10>', function() dap.step_over() end, { desc = "Debug: Step Over" })
remap('n', '<F11>', function() dap.step_into() end, { desc = "Debug: Step Into" })
remap('n', '<F12>', function() dap.step_out() end, { desc = "Debug: Step Out" })

-- Breakpoint management
remap('n', '<leader>db', function() dap.toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })
remap('n', '<leader>dB', function() 
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) 
end, { desc = "Debug: Set Conditional Breakpoint" })
remap('n', '<leader>dp', function() 
  dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) 
end, { desc = "Debug: Set Log Point" })

-- Debug session management
remap('n', '<leader>dc', function() dap.continue() end, { desc = "Debug: Continue" })
remap('n', '<leader>dr', function() dap.repl.toggle() end, { desc = "Debug: Toggle REPL" })
remap('n', '<leader>dl', function() dap.run_last() end, { desc = "Debug: Run Last" })
remap('n', '<leader>dt', function() dap.terminate() end, { desc = "Debug: Terminate" })

-- Debug UI controls
if dapui_ok then
  remap('n', '<leader>du', function() dapui.toggle() end, { desc = "Debug: Toggle UI" })
  remap('n', '<leader>de', function() dapui.eval() end, { desc = "Debug: Evaluate Expression" })
  remap('v', '<leader>de', function() dapui.eval() end, { desc = "Debug: Evaluate Selection" })
end

-- Java-specific debug shortcuts (these will be available globally but mainly useful in Java files)
remap('n', '<leader>djc', function()
  -- Debug current Java file using the first launch configuration
  dap.run(dap.configurations.java[1])
end, { desc = "Debug: Java Current File" })

remap('n', '<leader>dja', function()
  -- Attach to Java remote debugger using the attach configuration
  dap.run(dap.configurations.java[2])
end, { desc = "Debug: Java Attach Remote" })

-- Add a specific keymap for continue (when already debugging)
remap('n', '<leader>dc', function() dap.continue() end, { desc = "Debug: Continue" })

-- ============================================================================
-- DEBUG HIGHLIGHTS
-- ============================================================================

-- Set up debug highlighting
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, 'DapBreakpoint', { ctermbg = 0, fg = '#993939', bg = '#31353f' })
    vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { ctermbg = 0, fg = '#ffa500', bg = '#31353f' })
    vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { ctermbg = 0, fg = '#888888', bg = '#31353f' })
    vim.api.nvim_set_hl(0, 'DapLogPoint', { ctermbg = 0, fg = '#61afef', bg = '#31353f' })
    vim.api.nvim_set_hl(0, 'DapStopped', { ctermbg = 0, fg = '#98c379', bg = '#31353f' })
    vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })
  end
})

-- Apply highlights immediately
vim.cmd('doautocmd ColorScheme')

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Function to show debug status
_G.debug_status = function()
  local session = dap.session()
  if session then
    vim.notify("Debug session active: " .. (session.config.name or "Unknown"), vim.log.levels.INFO)
  else
    vim.notify("No active debug session", vim.log.levels.WARN)
  end
end

-- Command to show debug status
vim.api.nvim_create_user_command('DebugStatus', function()
  _G.debug_status()
end, { desc = 'Show debug session status' })

-- Command to clear all breakpoints
vim.api.nvim_create_user_command('DebugClearBreakpoints', function()
  dap.clear_breakpoints()
  vim.notify("All breakpoints cleared", vim.log.levels.INFO)
end, { desc = 'Clear all breakpoints' })

-- Command to list all breakpoints
vim.api.nvim_create_user_command('DebugListBreakpoints', function()
  local breakpoints = dap.list_breakpoints()
  if vim.tbl_isempty(breakpoints) then
    vim.notify("No breakpoints set", vim.log.levels.INFO)
  else
    print("Current breakpoints:")
    for buf, bp_list in pairs(breakpoints) do
      local buf_name = vim.api.nvim_buf_get_name(buf)
      print("  " .. (buf_name ~= "" and buf_name or "Buffer " .. buf) .. ":")
      for _, bp in ipairs(bp_list) do
        local condition = bp.condition and (" (condition: " .. bp.condition .. ")") or ""
        local logMessage = bp.logMessage and (" (log: " .. bp.logMessage .. ")") or ""
        print("    Line " .. bp.line .. condition .. logMessage)
      end
    end
  end
end, { desc = 'List all breakpoints' })

-- Commands are now defined in core/startup_messages.lua

-- ============================================================================
-- JAVA-SPECIFIC DEBUG ENHANCEMENTS
-- ============================================================================

-- Function to set up Java test debugging
_G.setup_java_test_debug = function()
  -- This function can be called from Java ftplugin to set up test-specific debug configs
  local java_test_configs = {
    {
      type = 'java',
      request = 'launch',
      name = "Debug Test - Current Method",
      mainClass = function()
        -- Use JDTLS to get the current test method
        local jdtls_ok, jdtls = pcall(require, 'jdtls')
        if jdtls_ok then
          return jdtls.test_nearest_method()
        end
        return vim.fn.input('Test class: ')
      end,
      projectName = function()
        return get_project_name()
      end,
      args = '-ea', -- Enable assertions for tests
      vmArgs = '-Xmx1G',
    },
    {
      type = 'java',
      request = 'launch',
      name = "Debug Test - Current Class",
      mainClass = function()
        local jdtls_ok, jdtls = pcall(require, 'jdtls')
        if jdtls_ok then
          return jdtls.test_class()
        end
        return vim.fn.input('Test class: ')
      end,
      projectName = function()
        return get_project_name()
      end,
      args = '-ea',
      vmArgs = '-Xmx1G',
    }
  }
  
  -- Add test configurations to existing Java configs
  vim.list_extend(dap.configurations.java, java_test_configs)
  -- Silent load - no notification
  -- vim.notify("Java test debug configurations loaded", vim.log.levels.INFO)
end

-- Disabled startup message for Java debugging
-- To enable, uncomment the lines below:
-- vim.defer_fn(function()
--     local startup_messages = require('core.startup_messages')
--     startup_messages.show_startup_info()
-- end, 1000)
