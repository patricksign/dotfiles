-- Startup messages for Java debugging and profile management
local M = {}

-- Configuration for enabling/disabling startup messages
local show_messages = false -- Set to false to disable auto-messages at startup

-- Show comprehensive startup information
function M.show_startup_info()
    -- If messages are disabled, return early
    if not show_messages then
        return
    end

    -- Wait a bit to ensure everything is loaded
    vim.defer_fn(function()
        print("")
        print("=" .. string.rep("=", 80))
        print("🚀 Java Development Environment Loaded!")
        print("=" .. string.rep("=", 80))
        print("")

        -- Debug Configuration
        print("🔧 Enhanced Java Debug Configuration:")
        print("  F5: Continue/Start  F10: Step Over  F11: Step Into  F12: Step Out")
        print("  <leader>db: Toggle Breakpoint  <leader>dB: Conditional  <leader>dp: Log Point")
        print("  <leader>djc: Debug current file  <leader>dja: Attach remote")
        print("  <leader>du: Toggle Debug UI  <leader>de: Evaluate expression")
        print("")

        -- Profile Management
        print("📋 Java Profile Manager:")
        print("  <leader>jp: Show profiles  <leader>jc: Create profile")
        print("  :JavaProfileShow - Show profile selection")
        print("  :JavaProfileCreate - Create new profile")
        print("  :JavaProfileList - List all profiles")
        print("  :JavaProfileDelete <name> - Delete profile")
        print("")

        -- Git-based Formatting
        print("🎨 Git-Based Smart Formatting:")
        print("  Auto-formats only changed lines on save")
        print("  <leader>cf: Format entire file")
        print("  V<leader>cf: Format selected lines")
        print("  V=: Alternative formatting (works better with JDTLS)")
        print("")

        -- Commands
        print("📝 Available Commands:")
        print("  :DebugInfo - Show debug configuration")
        print("  :JavaProfileInfo - Show profile manager info")
        print("  :DebugStatus - Show debug session status")
        print("  :DebugClearBreakpoints - Clear all breakpoints")
        print("  :DebugListBreakpoints - List all breakpoints")
        print("")

        print("💡 Tip: Use :DebugInfo or :JavaProfileInfo to see this information again")
        print("=" .. string.rep("=", 80))
        print("")
    end, 2000)
end

-- Show debug-specific information
function M.show_debug_info()
    print("=" .. string.rep("=", 60))
    print("🚀 Enhanced Java Debug Configuration")
    print("=" .. string.rep("=", 60))
    print("Debug Controls:")
    print("  F5: Continue/Start  F10: Step Over  F11: Step Into  F12: Step Out")
    print("")
    print("Breakpoints:")
    print("  <leader>db: Toggle  <leader>dB: Conditional  <leader>dp: Log Point")
    print("")
    print("Java Debug:")
    print("  <leader>djc: Debug current file  <leader>dja: Attach remote")
    print("")
    print("UI Controls:")
    print("  <leader>du: Toggle Debug UI  <leader>de: Evaluate expression")
    print("")
    print("Commands: :DebugStatus :DebugClearBreakpoints :DebugListBreakpoints")
    print("=" .. string.rep("=", 60))
end

-- Show profile manager information
function M.show_profile_info()
    print("=" .. string.rep("=", 60))
    print("🚀 Java Profile Manager")
    print("=" .. string.rep("=", 60))
    print("Commands:")
    print("  :JavaProfileShow - Show profile selection")
    print("  :JavaProfileCreate - Create new profile")
    print("  :JavaProfileList - List all profiles")
    print("  :JavaProfileDelete <name> - Delete profile")
    print("  :JavaProfileTest - Test profile creation")
    print("")
    print("Keymaps:")
    print("  <leader>jp - Show profiles")
    print("  <leader>jc - Create profile")
    print("=" .. string.rep("=", 60))
end

-- Create global commands
vim.api.nvim_create_user_command('JavaStartupInfo', function()
    M.show_startup_info()
end, { desc = 'Show comprehensive Java startup information' })

vim.api.nvim_create_user_command('DebugInfo', function()
    M.show_debug_info()
end, { desc = 'Show debug configuration information' })

vim.api.nvim_create_user_command('JavaProfileInfo', function()
    M.show_profile_info()
end, { desc = 'Show Java profile manager information' })

return M 