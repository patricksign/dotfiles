return {
    'nvim-lualine/lualine.nvim',
    config = function()
        require('lualine').setup {
            options = {
                theme = 'gruvbox',
                icons_enabled = false, -- Disable icons to avoid question marks
                component_separators = { left = '', right = ''},
                section_separators = { left = '', right = ''},
            },
            sections = {
                lualine_x = {
                    {
                        'filetype',
                        colored = true,      -- Display filetype in color
                        icon_only = false,    -- Display only icon for filetype
                        icon = { align = 'right' },
                    },
                    'encoding',
                    'fileformat',
                },
            }
        }
    end
}
