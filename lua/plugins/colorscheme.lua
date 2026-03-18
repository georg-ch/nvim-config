return {
  "rmehri01/onenord.nvim",
  branch = "main",
  priority = 1000,
  config = function()
    require("onenord").setup({
      theme = nil,
      borders = true,
      fade_nc = false,
      styles = {
        comments = "italic",
        strings = "NONE",
        keywords = "bold",
        functions = "NONE",
        variables = "NONE",
        diagnostics = "underline",
      },
      disable = {
        background = false,
        float_background = false,
        cursorline = false,
        eob_lines = true,
      },
      inverse = {
        match_paren = false,
      },
    })
    vim.cmd.colorscheme("onenord")
  end,
}
