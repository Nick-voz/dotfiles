return {
  "folke/noice.nvim",
  opts = {
    commands = { history = { view = "popup" } },
    views = { split = { size = "auto" } },
    lsp = { hover = { silent = true } },
    presets = { command_palette = true, bottom_search = false, lsp_doc_border = true },
    routes = {
      { filter = { event = "msg_show", kind = "shell_out" }, view = "popup" },
      { filter = { event = "msg_show", find = "Word.*spell" }, view = "mini" },
    },
  },
  keys = {
    { "<leader>nh", "<CMD>Noice history<CR>", { desc = "Show notifications history" } },
    { "<leader>nl", "<CMD>Noice last<CR>", { desc = "Show last notification" } },
  },
}
