return {
  "folke/noice.nvim",
  opts = {
    views = {
      sigsplit = {
        backend = "split",
        enter = false,
        relative = "editor",
        position = "bottom",
        size = "20%",
        win_options = { wrap = true },
      },
    },
    routes = {
      { filter = { event = "lsp", kind = "signature" }, view = "sigsplit" },
    },
    lsp = {
      signature = { enabled = true },
    },
  },
}
