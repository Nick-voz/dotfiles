return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN] = "W",
            [vim.diagnostic.severity.INFO] = "I",
            [vim.diagnostic.severity.HINT] = "H",
          },
        },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    dependencies = {
      "olimorris/onedarkpro.nvim",
      "catppuccin/nvim",
    },
    opts = {
      colorscheme = "catppuccin",
      -- colorscheme = "onedark_dark",
    },
  },
}
