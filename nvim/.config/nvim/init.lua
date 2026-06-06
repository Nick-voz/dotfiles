-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
local arg = vim.fn.argv(0)
if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
  vim.api.nvim_set_current_dir(vim.fn.fnamemodify(arg, ":p"))
end
