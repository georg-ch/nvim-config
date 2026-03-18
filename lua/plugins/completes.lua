return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["˚"] = { "select_prev", "fallback" },
        ["∆"] = {
          function(cmp)
            if cmp.is_visible() then
              return cmp.select_next()
            end
            return cmp.show()
          end,
          "fallback",
        },
        ["<A-Tab>"] = { "accept", "fallback" },
        ["<CR>"] = {},
      },
    },
  },
}
