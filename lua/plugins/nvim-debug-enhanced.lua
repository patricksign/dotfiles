-- Enhanced debugging plugins for Java and other languages
return {
  -- DAP UI for better debugging experience
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio', -- Required dependency for DAP UI
    },
    config = false, -- Configuration is handled in lua/config/nvim-dap.lua
    event = 'VeryLazy',
  },

  -- Virtual text support for showing variable values inline during debugging
  {
    'theHamsta/nvim-dap-virtual-text',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-treesitter/nvim-treesitter',
    },
    config = false, -- Configuration is handled in lua/config/nvim-dap.lua
    event = 'VeryLazy',
  },

  -- Telescope integration for DAP (optional but useful)
  {
    'nvim-telescope/telescope-dap.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'mfussenegger/nvim-dap',
    },
    config = function()
      local telescope = require('telescope')
      telescope.load_extension('dap')
      
      -- Add telescope DAP keymaps
      local remap = function(mode, lhs, rhs, opts)
        local options = { noremap = true, silent = true }
        if opts then
          options = vim.tbl_extend("force", options, opts)
        end
        vim.keymap.set(mode, lhs, rhs, options)
      end

      remap('n', '<leader>dsc', function() telescope.extensions.dap.configurations{} end, 
            { desc = "Debug: Show Configurations" })
      remap('n', '<leader>dsb', function() telescope.extensions.dap.list_breakpoints{} end, 
            { desc = "Debug: Show Breakpoints" })
      remap('n', '<leader>dsv', function() telescope.extensions.dap.variables{} end, 
            { desc = "Debug: Show Variables" })
      remap('n', '<leader>dsf', function() telescope.extensions.dap.frames{} end, 
            { desc = "Debug: Show Frames" })
    end,
    event = 'VeryLazy',
  },

  -- Persistent breakpoints (optional but nice to have)
  {
    'Weissle/persistent-breakpoints.nvim',
    dependencies = { 'mfussenegger/nvim-dap' },
    config = function()
      require('persistent-breakpoints').setup({
        save_dir = vim.fn.stdpath('data') .. '/nvim_checkpoints',
        load_breakpoints_event = { 'BufReadPost' },
        perf_record = false,
      })

      -- Override default DAP breakpoint functions with persistent ones
      local remap = function(mode, lhs, rhs, opts)
        local options = { noremap = true, silent = true }
        if opts then
          options = vim.tbl_extend("force", options, opts)
        end
        vim.keymap.set(mode, lhs, rhs, options)
      end

      -- Use persistent breakpoints instead of default DAP breakpoints
      remap('n', '<leader>db', function() 
        require('persistent-breakpoints.api').toggle_breakpoint() 
      end, { desc = "Debug: Toggle Persistent Breakpoint" })

      remap('n', '<leader>dB', function()
        local condition = vim.fn.input('Breakpoint condition: ')
        if condition and condition ~= '' then
          require('persistent-breakpoints.api').set_conditional_breakpoint(condition)
        end
      end, { desc = "Debug: Set Persistent Conditional Breakpoint" })

      remap('n', '<leader>dC', function()
        require('persistent-breakpoints.api').clear_all_breakpoints()
      end, { desc = "Debug: Clear All Persistent Breakpoints" })
    end,
    event = 'VeryLazy',
  },
} 