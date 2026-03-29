-- Startup messages for debugging
local M = {}

local show_messages = false

function M.show_startup_info()
    if not show_messages then
        return
    end

    vim.defer_fn(function()
        print("")
        print("=" .. string.rep("=", 60))
        print("Debug Configuration")
        print("=" .. string.rep("=", 60))
        print("")
        print("Debug Controls:")
        print("  F5: Continue/Start  F10: Step Over  F11: Step Into  F12: Step Out")
        print("  <leader>db: Toggle Breakpoint  <leader>dB: Conditional  <leader>dp: Log Point")
        print("  <leader>du: Toggle Debug UI  <leader>de: Evaluate expression")
        print("")
        print("Commands: :DebugStatus :DebugClearBreakpoints :DebugListBreakpoints")
        print("=" .. string.rep("=", 60))
        print("")
    end, 2000)
end

function M.show_debug_info()
    print("=" .. string.rep("=", 60))
    print("Debug Configuration")
    print("=" .. string.rep("=", 60))
    print("Debug Controls:")
    print("  F5: Continue/Start  F10: Step Over  F11: Step Into  F12: Step Out")
    print("")
    print("Breakpoints:")
    print("  <leader>db: Toggle  <leader>dB: Conditional  <leader>dp: Log Point")
    print("")
    print("UI Controls:")
    print("  <leader>du: Toggle Debug UI  <leader>de: Evaluate expression")
    print("")
    print("Commands: :DebugStatus :DebugClearBreakpoints :DebugListBreakpoints")
    print("=" .. string.rep("=", 60))
end

vim.api.nvim_create_user_command('DebugInfo', function()
    M.show_debug_info()
end, { desc = 'Show debug configuration information' })

return M
