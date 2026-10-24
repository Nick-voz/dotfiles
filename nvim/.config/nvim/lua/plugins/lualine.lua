return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    -- tabline is hidden; show "2/3" while more than one tab is open
    table.insert(opts.sections.lualine_x, {
      function()
        return vim.fn.tabpagenr() .. "/" .. vim.fn.tabpagenr("$")
      end,
      cond = function()
        return vim.fn.tabpagenr("$") > 1
      end,
    })
  end,
}
