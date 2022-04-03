return {
    'vim-airline/vim-airline-themes',
    dependencies = {
        'vim-airline/vim-airline',
    },
    config = function()
        -- Configure vim-airline without icons
        vim.g.airline_powerline_fonts = 0
        vim.g.airline_symbols_ascii = 1
        vim.g["airline#extensions#tabline#enabled"] = 0

        -- Disable filetype icons that use webdevicons
        vim.g.airline_skip_empty_sections = 1
        vim.g["airline#extensions#tabline#formatter"] = 'unique_tail'

        -- Simple section configuration to avoid question marks
        vim.g.airline_section_x = 'filetype'
        vim.g.airline_section_y = 'fileencoding'
        vim.g.airline_section_z = '%p%% %l/%L:%c'
    end
}
