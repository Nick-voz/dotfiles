-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>wf", "<cmd>w<CR>", { desc = "write file" })
vim.keymap.set("n", "<leader>wa", "<cmd>wa<CR>", { desc = "write all" })

vim.keymap.set("n", "<leader>rf", "<cmd>!python3 %<CR>", { desc = "run curent file through python" })
vim.keymap.set(
  "n",
  "<leader>rt",
  "<cmd>terminal python3 %<CR>",
  { desc = "run curent file through python in new terminal window" }
)
vim.keymap.set("n", "<leader>rm", "<cmd>!python3 main.py<CR>", { desc = "run main.py" })
vim.keymap.set(
  "n",
  "<leader>rM",
  "<cmd>terminal python3 main.py<CR>" .. vim.fn.getcwd() .. "<CR>",
  { desc = "run main.py in new terminal window" }
)
vim.keymap.set("n", "<leader>rT", "<cmd>terminal pytest<CR>", { desc = "run pytest in new terminal window" })
vim.keymap.set(
  "n",
  "<leader>ro",
  [[<cmd>exe "silent !firefox --new-window file://" . expand('%:p')<CR>]],
  { desc = "open courent file with firefox" }
)
vim.keymap.set("n", "<leader>hh", "<cmd>nohlsearch<CR>", { desc = "clear highlights" })

vim.keymap.set("n", "<CR>", "<cmd>call append(line('.'), '')<CR>", { desc = "apped empty line down" })
vim.keymap.set("n", "<S-CR>", "<cmd>call append(line('.')-1, '')<CR>", { desc = "append empty line up " })
vim.keymap.set("n", "<C-CR>", "yyp$", { desc = "duplicate line down" })
vim.keymap.set("n", "<C-S-CR>", "yyP^", { desc = "duplicate line up" })

vim.keymap.set("n", "<A-Up>", ":m -2<CR>==", { silent = true, desc = "Move line up" })
vim.keymap.set("n", "<A-Down>", ":m +1<CR>==", { silent = true, desc = "Move line down" })
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>==gv", { silent = true, desc = "Move selection up" })
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>==gv", { silent = true, desc = "Move selection down" })

vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Open neogit" })

-- Tabs: no tabline (see options.lua), no <leader><tab>; managed through
-- the <leader>t group and the picker on <leader>ft. config/tabs.lua holds
-- the picker. This file loads after LazyVim's defaults, so unsetting here works.
local Tabs = require("config.tabs")
for _, lhs in ipairs({
  "<leader><tab>",
  "<leader><tab><tab>",
  "<leader><tab>[",
  "<leader><tab>]",
  "<leader><tab>d",
  "<leader><tab>f",
  "<leader><tab>l",
  "<leader><tab>o",
  "<leader>fT",
}) do
  pcall(vim.keymap.del, "n", lhs)
end
vim.keymap.set("n", "<leader>t", "", { desc = "tabs" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader>tw", "<cmd>tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
vim.keymap.set("n", "<leader>ft", Tabs.pick, { desc = "Find Tabs" })
-- Terminals moved out of <leader>f (now free for the tabs picker) into the tabs group
vim.keymap.set("n", "<leader>tt", function()
  Snacks.terminal(nil, { cwd = LazyVim.root() })
end, { desc = "Terminal (Root Dir)" })
vim.keymap.set("n", "<leader>tT", function()
  Snacks.terminal()
end, { desc = "Terminal (cwd)" })

-- Tabline toggle moved from <leader>uA to <leader>ut: the tabline is hidden
-- by default (showtabline = 0), this is the escape hatch to bring it back.
pcall(vim.keymap.del, "n", "<leader>uA")
Snacks.toggle.option("showtabline", { off = 0, on = 2, name = "Tabline" }):map("<leader>ut")
local opts = { noremap = true, silent = true }
vim.keymap.set("i", "<C-BS>", "<C-w>", opts)
vim.keymap.set("i", "<M-BS>", "<C-w>", opts)
vim.keymap.set("i", "<C-a>", "<Home>", opts)
vim.keymap.set("i", "<C-e>", "<End>", opts)
vim.keymap.set("i", "<M-Left>", "<C-o>b", opts)
vim.keymap.set("i", "<M-Right>", "<C-o>w", opts)
