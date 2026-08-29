return {
    'godlygeek/tabular',
    'ixru/nvim-markdown',
    'leafOfTree/vim-svelte-plugin',
    'wbthomason/packer.nvim',

    'nvim-lua/plenary.nvim',
    'tpope/vim-commentary',
    'tpope/vim-fugitive',
    'tpope/vim-repeat',
    'tpope/vim-rhubarb',
    'tpope/vim-surround',
    'tpope/vim-unimpaired',
    {
        'andymass/vim-matchup',
        -- Newer tree-sitter-go wraps block statements in a `statement_list`
        -- node, which turns the plugin's `(block (if_statement ...))` query
        -- into an "Impossible pattern" (E5108) on CursorMoved in Go files.
        -- Patch the bundled query on every install/update so it survives
        -- `Lazy sync`. Idempotent.
        build = function(plugin)
            local path = plugin.dir .. '/after/queries/go/matchup.scm'
            local fd = io.open(path, 'r')
            if not fd then return end
            local content = fd:read('*a')
            fd:close()
            local broken = '(block\n  (if_statement\n    "if" @open.if) @scope.if)'
            local fixed = '(if_statement\n  "if" @open.if) @scope.if'
            if content:find(broken, 1, true) then
                content = content:gsub(vim.pesc(broken), fixed)
                local out = io.open(path, 'w')
                if out then
                    out:write(content)
                    out:close()
                end
            end
        end,
    },
    'rbgrouleff/bclose.vim',
    'jiangmiao/auto-pairs',
    "Exafunction/codeium.nvim",
}
