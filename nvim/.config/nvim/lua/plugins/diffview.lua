return {
  "sindrets/diffview.nvim",
  opts = {
    view = {
      merge_tool = { layout = "diff4_mixed", disable_diagnostics = true, winbar_info = true },
      default = { layout = "diff2_vertical", winbar_info = true },
    },
    hooks = {
      view_opened = function()
        local actions = require("diffview.actions")
        actions.toggle_files()
      end,
    },
  },
}
