local dap = require('dap')
dap.defaults.fallback.terminal_win_cmd = 'tabnew'

-- ============================================================================
-- GO DEBUG CONFIGURATION
-- ============================================================================

-- Go debugging with delve
dap.adapters.delve = {
  type = 'server',
  port = '${port}',
  executable = {
    command = 'dlv',
    args = { 'dap', '-l', '127.0.0.1:${port}' },
  }
}

dap.configurations.go = {
  {
    type = 'delve',
    name = 'Debug',
    request = 'launch',
    program = '${file}',
  },
  {
    type = 'delve',
    name = 'Debug test',
    request = 'launch',
    mode = 'test',
    program = '${file}',
  },
  {
    type = 'delve',
    name = 'Debug test (go.mod)',
    request = 'launch',
    mode = 'test',
    program = './${relativeFileDirname}',
  },
}

-- ============================================================================
-- DEBUG UI SETUP
-- ============================================================================

-- DAP UI configuration for better debugging experience
local dapui_ok, dapui = pcall(require, 'dapui')
if dapui_ok then
  dapui.setup({
    icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
    mappings = {
      expand = { "<CR>", "<2-LeftMouse>" },
      open = "o",
      remove = "d",
      edit = "e",
      repl = "r",
      toggle = "t",
    },
    expand_lines = vim.fn.has("nvim-0.7") == 1,
    layouts = {
      {
        elements = {
          { id = "scopes", size = 0.25 },
          "breakpoints",
          "stacks",
          "watches",
        },
        size = 40,
        position = "left",
      },
      {
        elements = {
          "repl",
          "console",
        },
        size = 0.25,
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
      max_height = nil,
      max_width = nil,
      border = "single",
      mappings = {
        close = { "q", "<Esc>" },
      },
    },
    windows = { indent = 1 },
    render = {
      max_type_length = nil,
      max_value_lines = 100,
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

local remap = function(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Main debug controls
remap('n', '<F5>', function() dap.continue() end, { desc = "Debug: Continue/Start" })
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

-- ============================================================================
-- DEBUG HIGHLIGHTS
-- ============================================================================

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

vim.cmd('doautocmd ColorScheme')

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

_G.debug_status = function()
  local session = dap.session()
  if session then
    vim.notify("Debug session active: " .. (session.config.name or "Unknown"), vim.log.levels.INFO)
  else
    vim.notify("No active debug session", vim.log.levels.WARN)
  end
end

vim.api.nvim_create_user_command('DebugStatus', function()
  _G.debug_status()
end, { desc = 'Show debug session status' })

vim.api.nvim_create_user_command('DebugClearBreakpoints', function()
  dap.clear_breakpoints()
  vim.notify("All breakpoints cleared", vim.log.levels.INFO)
end, { desc = 'Clear all breakpoints' })

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
