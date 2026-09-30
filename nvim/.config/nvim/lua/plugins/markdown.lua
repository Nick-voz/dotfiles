return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      -- Keep rendering off. A FileType autocmd that calls `rm.buf_disable()` cannot do this:
      -- the plugin's own FileType autocmd attaches (and renders) the buffer afterwards.
      -- Toggle at runtime with <leader>um.
      enabled = false,
      win_options = {
        conceallevel = { default = 0, rendered = 3 },
      },
    },
  },
}
