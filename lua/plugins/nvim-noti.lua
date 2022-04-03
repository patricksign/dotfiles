return {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        "MunifTanjim/nui.nvim",
        -- OPTIONAL:
        --   `nvim-notify` is only needed, if you want to use the notification view.
        --   If not available, we use `mini` as the fallback
        "rcarriga/nvim-notify"
    },
    config = function()
        -- Configure nvim-notify first
        require("notify").setup({
            background_colour = "#000000",
            fps = 30,
            icons = {
                DEBUG = "🐛",
                ERROR = "❌",
                INFO = "ℹ️",
                TRACE = "🔍",
                WARN = "⚠️"
            },
            level = vim.log.levels.INFO,
            minimum_width = 50,
            render = "default",
            stages = "fade_in_slide_out",
            timeout = 5000,
            top_down = true,
        })
        
        -- Set up notification highlight groups
        vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "*",
            callback = function()
                vim.api.nvim_set_hl(0, 'NotifyBackground', { bg = '#000000' })
                vim.api.nvim_set_hl(0, 'NotifyERRORBorder', { fg = '#8A1F1F' })
                vim.api.nvim_set_hl(0, 'NotifyWARNBorder', { fg = '#79491D' })
                vim.api.nvim_set_hl(0, 'NotifyINFOBorder', { fg = '#4F6752' })
                vim.api.nvim_set_hl(0, 'NotifyDEBUGBorder', { fg = '#8B8B8B' })
                vim.api.nvim_set_hl(0, 'NotifyTRACEBorder', { fg = '#4F3552' })
                vim.api.nvim_set_hl(0, 'NotifyERRORIcon', { fg = '#F70067' })
                vim.api.nvim_set_hl(0, 'NotifyWARNIcon', { fg = '#F79000' })
                vim.api.nvim_set_hl(0, 'NotifyINFOIcon', { fg = '#A9FF68' })
                vim.api.nvim_set_hl(0, 'NotifyDEBUGIcon', { fg = '#8B8B8B' })
                vim.api.nvim_set_hl(0, 'NotifyTRACEIcon', { fg = '#D484FF' })
                vim.api.nvim_set_hl(0, 'NotifyERRORTitle', { fg = '#F70067' })
                vim.api.nvim_set_hl(0, 'NotifyWARNTitle', { fg = '#F79000' })
                vim.api.nvim_set_hl(0, 'NotifyINFOTitle', { fg = '#A9FF68' })
                vim.api.nvim_set_hl(0, 'NotifyDEBUGTitle', { fg = '#8B8B8B' })
                vim.api.nvim_set_hl(0, 'NotifyTRACETitle', { fg = '#D484FF' })
                vim.api.nvim_set_hl(0, 'NotifyERRORBody', { fg = '#F70067', bg = '#000000' })
                vim.api.nvim_set_hl(0, 'NotifyWARNBody', { fg = '#F79000', bg = '#000000' })
                vim.api.nvim_set_hl(0, 'NotifyINFOBody', { fg = '#A9FF68', bg = '#000000' })
                vim.api.nvim_set_hl(0, 'NotifyDEBUGBody', { fg = '#8B8B8B', bg = '#000000' })
                vim.api.nvim_set_hl(0, 'NotifyTRACEBody', { fg = '#D484FF', bg = '#000000' })
            end
        })
        
        -- Apply highlights immediately
        vim.cmd('doautocmd ColorScheme')
        
        -- Test notification command
        vim.api.nvim_create_user_command('TestNotify', function()
            vim.notify("This is an INFO notification", vim.log.levels.INFO)
            vim.notify("This is a WARN notification", vim.log.levels.WARN)
            vim.notify("This is an ERROR notification", vim.log.levels.ERROR)
        end, { desc = 'Test notification system' })
        
        require("noice").setup(
            {
                lsp = {
                    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true
                    },
                    progress = {
                        enabled = true,
                        -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
                        -- See the section on formatting for more details on how to customize.
                        format = "lsp_progress",
                        format_done = "lsp_progress_done",
                        throttle = 1000 / 30, -- frequency to update lsp progress message
                        view = "mini"
                    },
                    hover = {
                        enabled = true,
                        silent = false, -- set to true to not show a message if hover is not available
                        view = nil,     -- when nil, use defaults from documentation
                        opts = {}       -- merged with defaults from documentation
                    },
                    signature = {
                        enabled = true,
                        auto_open = {
                            enabled = true,
                            trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
                            luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
                            throttle = 50   -- Debounce lsp signature help request by 50ms
                        },
                        view = nil,         -- when nil, use defaults from documentation
                        opts = {}           -- merged with defaults from documentation
                    },
                    message = {
                        -- Messages shown by lsp servers
                        enabled = true,
                        view = "notify",
                        opts = {}
                    },
                    -- defaults for hover and signature help
                    documentation = {
                        view = "hover",
                        opts = {
                            lang = "markdown",
                            replace = true,
                            render = "plain",
                            format = { "{message}" },
                            win_options = { concealcursor = "n", conceallevel = 3 }
                        }
                    }
                },
                -- you can enable a preset for easier configuration
                presets = {
                    bottom_search = true,         -- use a classic bottom cmdline for search
                    command_palette = true,       -- position the cmdline and popupmenu together
                    long_message_to_split = true, -- long messages will be sent to a split
                    inc_rename = false,           -- enables an input dialog for inc-rename.nvim
                    lsp_doc_border = false        -- add a border to hover docs and signature help
                },
                cmdline = {
                    enabled = true,
                    menu = "popup",
                    view = "cmdline_popup",
                    icons = {
                        ["/"] = { icon = "Q", hl_group = "DiagnosticWarn" },
                        ["?"] = { icon = "Q", hl_group = "DiagnosticWarn" },
                        ["."] = { icon = ">", hl_group = "DiagnosticInfo", firstc = false },
                    },
                    format = {
                        -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
                        -- view: (default is cmdline view)
                        -- opts: any options passed to the view
                        -- icon_hl_group: optional hl_group for the icon
                        -- title: set to anything or empty string to hide
                        cmdline = { pattern = "^:", icon = "", lang = "vim" },
                        search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
                        search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
                        filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
                        lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
                        help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
                        input = {} -- Used by input()
                        -- lua = false, -- to disable a format, set to `false`          },
                    }
                },
                messages = {
                    -- NOTE: If you enable messages, then the cmdline is enabled automatically.
                    -- This is a current Neovim limitation.
                    enabled = true,             -- enables the Noice messages UI
                    view = "notify",            -- default view for messages
                    view_error = "notify",      -- view for errors
                    view_warn = "notify",       -- view for warnings
                    view_history = "messages",  -- view for :messages
                    view_search = "virtualtext" -- view for search count messages. Set to `false` to disable
                },
                popupmenu = {
                    enabled = true,  -- enables the Noice popupmenu UI
                    backend = "nui", -- backend to use to show regular cmdline completions
                    kind_icons = {}  -- set to `false` to disable icons
                },
                redirect = {
                    view = "popup",
                    filter = { event = "msg_show" }
                },
                commands = {
                    history = {
                        -- options for the message history that you get with `:Noice`
                        view = "split",
                        opts = { enter = true, format = "details" },
                        filter = {
                            any = {
                                { event = "notify" },
                                { error = true },
                                { warning = true },
                                { event = "msg_show", kind = { "" } },
                                { event = "lsp",      kind = "message" }
                            }
                        }
                    },
                    -- :Noice last
                    last = {
                        view = "popup",
                        opts = { enter = true, format = "details" },
                        filter = {
                            any = {
                                { event = "notify" },
                                { error = true },
                                { warning = true },
                                { event = "msg_show", kind = { "" } },
                                { event = "lsp",      kind = "message" }
                            }
                        },
                        filter_opts = { count = 1 }
                    },
                    -- :Noice errors
                    errors = {
                        -- options for the message history that you get with `:Noice`
                        view = "popup",
                        opts = { enter = true, format = "details" },
                        filter = { error = true },
                        filter_opts = { reverse = true }
                    },
                    all = {
                        -- options for the message history that you get with `:Noice`
                        view = "split",
                        opts = { enter = true, format = "details" },
                        filter = {}
                    }
                },
                notify = {
                    -- Noice can be used as `vim.notify` so you can route any notification like other messages
                    -- Notification messages have their level and other properties set.
                    -- event is always "notify" and kind can be any log level as a string
                    -- The default routes will forward notifications to nvim-notify
                    -- Benefit of using Noice for this is the routing and consistent history view
                    enabled = true,
                    view = "notify"
                },
                markdown = {
                    hover = {
                        ["|(%S-)|"] = vim.cmd.help,                      -- vim help links
                        ["%[.-%]%((%S-)%)"] = require("noice.util").open -- markdown links
                    },
                    highlights = {
                        ["|%S-|"] = "@text.reference",
                        ["@%S+"] = "@parameter",
                        ["^%s*(Parameters:)"] = "@text.title",
                        ["^%s*(Return:)"] = "@text.title",
                        ["^%s*(See also:)"] = "@text.title",
                        ["{%S-}"] = "@parameter"
                    }
                },
                health = {
                    checker = true -- Disable if you don't want health checks to run
                },
                smart_move = {
                    -- noice tries to move out of the way of existing floating windows.
                    enabled = true, -- you can disable this behaviour here
                    -- add any filetypes here, that shouldn't trigger smart move.
                    excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" }
                },
                throttle = 1000 / 30, -- how frequently does Noice need to check for ui updates? This has no effect when in blocking mode.
                views = {},
                routes = {},
                status = {},
                format = {}
            }
        )
    end
}
