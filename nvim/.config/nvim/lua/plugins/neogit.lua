return {
  "NeogitOrg/neogit",

  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "nvim-telescope/telescope.nvim",
    "ibhagwan/fzf-lua",
    "nvim-mini/mini.pick",
    "folke/snacks.nvim",
  },

  config = function()
    local neogit = require("neogit")

    neogit.setup({
      disable_hint = true,
      kind = "tab",

      commit_editor = { kind = "tab" },
      commit_select_view = { kind = "tab" },
      commit_view = { kind = "tab", verify_commit = true },
      log_view = { kind = "tab" },
      reflog_view = { kind = "tab" },
      stash = { kind = "tab" },
      refs_view = { kind = "tab" },
      popup = { kind = "tab" },
    })
  end,
}
