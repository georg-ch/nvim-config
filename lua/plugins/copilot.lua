-- lua/plugins/copilot.lua
return {
  "zbirenbaum/copilot.lua",
  dependencies = { "copilotlsp-nvim/copilot-lsp" },
  event = "InsertEnter",
  opts = function(_, opts)
    opts = opts or {}

    opts.suggestion = vim.tbl_deep_extend("force", opts.suggestion or {}, {
      enabled = false, -- let blink show items
    })

    opts.panel = vim.tbl_deep_extend("force", opts.panel or {}, {
      enabled = false,
    })

    opts.filetypes = vim.tbl_deep_extend("force", opts.filetypes or {}, {
      ["*"] = true,
    })

    opts.nes = vim.tbl_deep_extend("force", opts.nes or {}, {
      enabled = true,
      debounce = 120,
      keymap = {
        accept_and_goto = "π", -- NES-only
        accept = false,
        dismiss = "<Esc>",
      },
    })

    return opts
  end,
}
