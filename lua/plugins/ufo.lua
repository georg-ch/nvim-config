return {
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    opts = {
      provider_selector = function(_, filetype, _)
        if filetype == "python" then
          return { "indent" }
        end
        return { "indent" }
      end,
    },
    config = function(_, opts)
      require("ufo").setup(opts)

      vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
    end,
  },
}
