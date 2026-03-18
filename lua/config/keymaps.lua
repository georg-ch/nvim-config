-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", ",", ":", { noremap = true })
vim.keymap.set("n", ":", ",", { noremap = true })

vim.keymap.set("i", "kj", "<Esc>", { noremap = true })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

vim.keymap.set("n", "J", "mzJ`z", { noremap = true })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true })

vim.keymap.set("x", "<leader>v", '"_dP', { noremap = true })

vim.keymap.set("n", "<leader>w", ":w<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>q", ":wq<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>z", ":q!<CR>", { noremap = true, silent = true })

require("mini.comment").setup({
  mappings = {
    comment = "<Leader>m",
    comment_visual = "<Leader>m",
    comment_line = "<Leader>mm",
  },
})

local function feedkeys(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "m", false)
end

vim.keymap.set("n", '<leader>"', function()
  feedkeys("gsa")
  vim.schedule(function()
    feedkeys("iw")
    vim.schedule(function()
      feedkeys('"')
    end)
  end)
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>'", function()
  feedkeys("gsa")
  vim.schedule(function()
    feedkeys("iw")
    vim.schedule(function()
      feedkeys("'")
    end)
  end)
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>o", function()
  local fname = vim.fn.input("Function name: ")
  if fname == "" then
    return
  end
  local original_word = vim.fn.expand("<cword>")
  local replacement = fname .. "(" .. original_word .. ")"
  vim.cmd("normal! ciw" .. replacement .. "\27")
end, { noremap = true, silent = true })

local terminal_buf = nil
local last_python_file = nil
local last_python_dir = nil
local python_terminal_large = false
local has_snacks, Snacks = pcall(require, "snacks")
local python_terminal_count = 99
local venvs = { "venv", ".venv" }

local function activate_venv_if_needed(chan, dir, buf)
  if not vim.b[buf].venv_activated then
    for _, name in ipairs(venvs) do
      local activate = dir .. "/" .. name .. "/bin/activate"
      if vim.fn.filereadable(activate) == 1 then
        vim.fn.chansend(chan, "source " .. name .. "/bin/activate\n")
        vim.b[buf].venv_activated = true
        break
      end
    end
  end
end

local function get_python_terminal(dir, create)
  if not has_snacks then
    return nil
  end
  dir = dir or last_python_dir
  if not dir or dir == "" then
    return nil
  end
  local term, created = Snacks.terminal.get(nil, {
    cwd = dir,
    count = python_terminal_count,
    create = create ~= false,
  })
  if term and term.buf then
    terminal_buf = term.buf
  end
  return term, created
end

local function toggle_python_terminal()
  if not has_snacks then
    print("snacks.nvim is disabled; terminal toggle is unavailable.")
    return
  end
  local dir = last_python_dir
    or (last_python_file and vim.fn.fnamemodify(last_python_file, ":h"))
    or (vim.bo.filetype == "python" and vim.fn.expand("%:p:h"))
    or nil
  local term = get_python_terminal(dir, false)
  if not term then
    dir = dir or vim.fn.getcwd()
    last_python_dir = dir
    local created
    term, created = get_python_terminal(dir, true)
    if created then
      return
    end
  end
  if not term then
    print("Could not create Python terminal.")
    return
  end
  term:toggle()
end

local function cycle_python_terminal_size()
  if not has_snacks then
    return
  end
  local term = get_python_terminal(nil, false)
  if not (term and term.win and vim.api.nvim_win_is_valid(term.win)) then
    return
  end
  local height = python_terminal_large and math.max(8, math.floor(vim.o.lines * 0.3)) or (vim.o.lines - 4)
  python_terminal_large = not python_terminal_large
  vim.api.nvim_win_call(term.win, function()
    vim.cmd("resize " .. height)
  end)
end

local function run_python_file(file, dir)
  if not file or file == "" then
    print("No file to run.")
    return
  end
  if not has_snacks then
    print("snacks.nvim is disabled; terminal runner is unavailable.")
    return
  end
  last_python_file = file
  last_python_dir = dir

  local term = get_python_terminal(dir, true)
  if not term then
    print("Could not create Python terminal.")
    return
  end
  term:show()
  vim.defer_fn(function()
    local buf = term.buf
    if buf and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
      local chan = vim.b[buf].terminal_job_id
      if chan then
        terminal_buf = buf
        activate_venv_if_needed(chan, dir, buf)
        vim.fn.chansend(chan, 'python "' .. file .. '"\n')
        vim.cmd("startinsert")
      end
    end
  end, 100)
end

vim.keymap.set("n", "<C-CR>", function()
  vim.cmd("write")
  if not last_python_file then
    last_python_file = vim.fn.expand("%:p")
  end
  run_python_file(last_python_file, vim.fn.fnamemodify(last_python_file, ":h"))
end, { desc = "Run last Python file", noremap = true, silent = true })

vim.keymap.set("n", "<C-\\>", function()
  vim.cmd("write")
  local current = vim.fn.expand("%:p")
  last_python_file = current
  run_python_file(current, vim.fn.fnamemodify(current, ":h"))
end, { desc = "Set and run current Python file", noremap = true, silent = true })

vim.keymap.set({ "n", "t" }, "<C-/>", toggle_python_terminal, { desc = "Toggle Python terminal", noremap = true, silent = true })
vim.keymap.set({ "n", "t" }, "<C-_>", toggle_python_terminal, { desc = "Toggle Python terminal", noremap = true, silent = true })
vim.keymap.set({ "n", "t" }, "<C-;>", cycle_python_terminal_size, { desc = "Cycle Python terminal size", noremap = true, silent = true })
vim.keymap.set("n", "<leader>tt", toggle_python_terminal, { desc = "Toggle Python terminal", noremap = true, silent = true })
