-- Compatibility shims for deprecated Neovim APIs still called by plugins.
--
-- `vim.lsp.buf_get_clients()` is deprecated in favour of `vim.lsp.get_clients()`
-- and emits a `vim.deprecate` warning every time a plugin calls it (project.nvim,
-- telescope.nvim, outline.nvim, cmp-nvim-lsp-signature-help all still use it).
-- We cannot edit those plugin files durably (a `Lazy sync` would revert them), so
-- we override the function itself with a warning-free reimplementation that
-- preserves the original contract exactly: takes an optional bufnr (0/nil = current)
-- and returns a map of { [client_id] = client }.
if vim.lsp and vim.lsp.get_clients then
    vim.lsp.buf_get_clients = function(bufnr)
        local result = {}
        local resolve = vim._resolve_bufnr or function(b)
            if b == nil or b == 0 then
                return vim.api.nvim_get_current_buf()
            end
            return b
        end
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = resolve(bufnr) })) do
            result[client.id] = client
        end
        return result
    end
end
