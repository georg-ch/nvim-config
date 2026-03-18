-- lua/plugins/copilot-lsp.lua
return {
  "copilotlsp-nvim/copilot-lsp",
  branch = "main",
  init = function()
    vim.g.copilot_nes_debounce = 120
  end,
  config = function()
    require("copilot-lsp").setup({
      nes = { move_count_threshold = 3 },
    })
    pcall(vim.lsp.enable, "copilot_ls")

    -- Insert-mode π: accept NES if active, else type π
    vim.keymap.set("i", "π", function()
      local ok, nes = pcall(require, "copilot-lsp.nes")
      if ok and nes and nes.apply_pending_nes then
        local applied = nes.apply_pending_nes()
        if applied and nes.walk_cursor_end_edit then
          nes.walk_cursor_end_edit()
        end
        return ""
      end
      return "π"
    end, { expr = true, desc = "Copilot NES accept (π) or insert π" })
  end,
}
