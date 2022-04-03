local vim = vim

local M = {}
function M.JavaHighlight()
    local g = vim.g
    g.java_highlight_all = 1
    g.java_highlight_functions = 1
    g.java_highlight_debug = 1
    g.java_allow_cpp_keywords = 1
end

function M.JavaBuild()
    local java_build = vim.api.nvim_create_augroup('java-build-command', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        pattern = '*.java',
        group = java_build,
        command = 'UnusedImportsRemove',
    })

    vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        pattern = '*.java',
        group = java_build,
        command = 'UnusedImportsReset',
    })
end

function M.JavaSyntax()
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*.java",
        callback = function()
            vim.bo.filetype = "java"
            vim.bo.syntax = "java"
        end,
    })
end

return M
