-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    client.server_capabilities.documentHighlightProvider = false
  end,
})

vim.api.nvim_create_user_command("Tr", function(opts)
  vim.api.nvim_put({ vim.trim(vim.fn.system(opts.args)) }, "c", true, true)
end, { nargs = 1, complete = "shellcmd" })
