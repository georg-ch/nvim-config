return {
  "stevearc/aerial.nvim",
  opts = {
    close_on_select = true,
  },
  config = function(_, opts)
    require("aerial").setup(opts)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "aerial",
      callback = function(event)
        vim.keymap.set("n", "<Esc>", "<cmd>AerialClose<CR>", { buffer = event.buf, silent = true })
      end,
    })
  end,
}
