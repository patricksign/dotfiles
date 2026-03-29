return {
    'ahmedkhalf/project.nvim',
    config = function()
        require('project_nvim').setup({
            detection_methods = { 'lsp', 'pattern' },
            patterns = { '.git', 'Makefile', 'go.mod', 'pom.xml', 'package.json' },
        })
    end
}
