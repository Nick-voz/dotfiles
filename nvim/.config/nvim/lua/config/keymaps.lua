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
