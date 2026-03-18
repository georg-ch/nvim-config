return {
  "epwalsh/pomo.nvim",
  version = "*",
  lazy = true,
  cmd = { "TimerStart", "TimerRepeat", "TimerSession" },
  dependencies = {
    "rcarriga/nvim-notify",
  },
  opts = {
    sessions = {
      work = {
        { name = "Work", duration = "60m" },
        { name = "Break", duration = "10m" },
        { name = "Work", duration = "60m" },
        { name = "Break", duration = "10m" },
        { name = "Work", duration = "60m" },
        { name = "Break", duration = "10m" },
      },
    },
  },
}
