local vim = vim

local M = {}

function M.config()
    vim.g.fzf_layout         = { down = '100%', up = '100%' }
    vim.g.NERDTreeShowHidden = 1
end

function M.searchFzfCommand()
    vim.api.nvim_command(
        'command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, "--smart-case --color-path=\\"0;33\\"", {\'options\': "--delimiter : --nth 4.."}, <bang>0)')
end

function M.findFileFromCurrentDirFzf()
    -- find file at current folder use ripgrep if exists
    if (vim.fn.executable('rg') ~= 0) then
        vim.env.FZF_DEFAULT_COMMAND =
        'rg --hidden --files --glob="!.git/*" --glob="!go.sum" --glob="!*.class" --glob="!venv/*" --glob="!coverage/*" --glob="!node_modules/*" --glob="!target/*" --glob="!__pycache__/*" --glob="!dist/*" --glob="!build/*" --glob="!*.DS_Store"'
        vim.api.nvim_set_option('grepprg', 'rg --vimgrep --smart-case --follow')
    end
    if (vim.fn.executable('ag') ~= 0) then
        vim.env.FZF_DEFAULT_COMMAND =
        'ag --hidden --ignore .git --ignore venv/ --ignore coverage/ --ignore node_modules/ --ignore target/  --ignore __pycache__/ --ignore dist/ --ignore build/ --ignore .DS_Store  --ignore .class -g ""'
        vim.api.nvim_set_option('grepprg', 'ag')
    else
        -- else fallback to find
        vim.env.FZF_DEFAULT_COMMAND =
        [[find * -path '*/\.*' -prune -o -path 'venv/**' -prune -o -path  'coverage/**' -prune -o -path 'node_modules/**' -prune -o -path '__pycache__/**' -prune -o -path 'target/**' -prune -o -path 'dist/**' -prune -o  -type f -print -o -type l -print 2> /dev/null]]
    end
end

return M
