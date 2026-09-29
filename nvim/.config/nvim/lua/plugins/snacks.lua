local function recent_file_only(item)
  return item.file == nil or vim.fn.isdirectory(item.file) == 0
end

-- Delete from cursor to the start of the line in the picker input.
local function delete_to_line_start(input_win)
  local win = input_win and input_win.win or vim.api.nvim_get_current_win()
  local buf = input_win and input_win.buf or vim.api.nvim_get_current_buf()
  if not (vim.api.nvim_win_is_valid(win) and vim.api.nvim_buf_is_valid(buf)) then
    return
  end
  local cursor = vim.api.nvim_win_get_cursor(win)
  local row, col = cursor[1], cursor[2]
  local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""
  vim.api.nvim_buf_set_lines(buf, row - 1, row, false, { line:sub(col + 1) })
  vim.api.nvim_win_set_cursor(win, { row, 0 })
end

return {
  "folke/snacks.nvim",

  opts = {
    dashboard = {
      sections = {
        { section = "header", enabled = false },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup", enabled = false },
      },
    },
    picker = {
      win = {
        input = {
          keys = {
            -- kitty sends C-a/C-e/C-u for Ctrl+Left/Right/Backspace (kitty.conf send_text).
            ["<C-a>"] = { "<home>", mode = { "i", "n" }, expr = true, desc = "Move to start of line" },
            ["<C-e>"] = { "<end>", mode = { "i", "n" }, expr = true, desc = "Move to end of line" },
            ["<C-u>"] = { delete_to_line_start, mode = { "i", "n" }, desc = "Delete to start of line" },
            -- Real keycodes (other terminals, linux console, ssh).
            ["<C-Left>"] = { "<home>", mode = "i", expr = true, desc = "Move to start of line" },
            ["<C-Right>"] = { "<end>", mode = "i", expr = true, desc = "Move to end of line" },
            ["<C-BS>"] = { delete_to_line_start, mode = "i", desc = "Delete to start of line" },
            ["<M-Left>"] = { "<c-o>b", mode = "i", expr = true, desc = "Move word left" },
            ["<M-Right>"] = { "<c-o>w", mode = "i", expr = true, desc = "Move word right" },
            ["<M-BS>"] = { "<c-s-w>", mode = "i", expr = true, desc = "Delete word backward" },
          },
        },
      },
      sources = {
        explorer = {
          auto_close = true,
          layout = { preset = "default", preview = true },
          hidden = true,
          ignored = true,
          exclude = { ".DS_Store", "__pycache__" },
        },
        files = { hidden = true, ignored = true, exclude = { ".DS_Store", "__pycache__", ".venv", ".git" } },
        keymaps = {
          layout = { preview = false },
          format = function(item)
            local lhs = item.item.lhs or ""
            local desc = item.item.desc or ""
            lhs = vim.fn.keytrans(lhs)
            return { { lhs, "SnacksPickerKey" }, { "  ", "Comment" }, { desc, "SnacksPickerDesc" } }
          end,
        },
      },
    },
  },
  keys = {
    { "<leader>n", false },
    { "<leader>e", "<leader>fe", desc = "Explorer Snacks (cwd)", remap = true },
    { "<leader>E", "<leader>fE", desc = "Explorer Snacks (git root)", remap = true },
    {
      "<leader>fe",
      function()
        Snacks.explorer()
      end,
      desc = "Explorer Snacks (cwd)",
    },
    {
      "<leader>fE",
      function()
        Snacks.explorer({ cwd = LazyVim.root.git() })
      end,
      desc = "Explorer Snacks (git root)",
    },
    { "<leader>ff", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
    {
      "<leader>fF",
      function()
        LazyVim.pick.open("files", { cwd = LazyVim.root.git() })
      end,
      desc = "Find Files (git root)",
    },
    {
      "<leader>fr",
      function()
        Snacks.picker.recent({ filter = { cwd = true, filter = recent_file_only } })
      end,
      desc = "Recent (cwd)",
    },
    {
      "<leader>fR",
      function()
        LazyVim.pick.open("oldfiles", { filter = { filter = recent_file_only } })
      end,
      desc = "Recent",
    },
    { "<leader>sg", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
    {
      "<leader>sG",
      function()
        LazyVim.pick.open("live_grep", { cwd = LazyVim.root.git() })
      end,
      desc = "Grep (git root)",
    },
    {
      "<leader>sw",
      LazyVim.pick("grep_word", { root = false }),
      desc = "Visual selection or word (cwd)",
      mode = { "n", "x" },
    },
    {
      "<leader>sW",
      function()
        LazyVim.pick.open("grep_word", { cwd = LazyVim.root.git() })
      end,
      desc = "Visual selection or word (git root)",
      mode = { "n", "x" },
    },
  },
}
