local function recent_file_only(item)
  return item.file == nil or vim.fn.isdirectory(item.file) == 0
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
