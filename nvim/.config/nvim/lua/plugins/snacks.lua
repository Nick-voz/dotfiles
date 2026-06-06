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
        explorer = { auto_close = true, layout = { preset = "default", preview = true }, hidden = true, ignored = true },
        files = { hidden = true, ignored = true },
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
  },
}
