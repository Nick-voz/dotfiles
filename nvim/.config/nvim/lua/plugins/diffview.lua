return {
  "sindrets/diffview.nvim",
  opts = {
    view = {
      merge_tool = { layout = "diff4_mixed", disable_diagnostics = true, winbar_info = true },
      default = { layout = "diff2_horizontal", winbar_info = true },
      file_history = { layout = "diff2_horizontal", winbar_info = true },
    },
    hooks = {
      view_opened = function()
        local actions = require("diffview.actions")
        actions.toggle_files()
      end,
    },
  },
}
