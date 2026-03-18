return {
  "LazyVim/LazyVim",
  init = function()
    local todo_file = vim.fn.expand("~/notes/todo.md")
    local todo_dir = vim.fn.fnamemodify(todo_file, ":h")
    local todo_template = {
      "## _M - Must do_",
      "",
      "## **S - Should do**",
      "",
      "### C - Could do",
      "",
      "#### W - Won't do",
      "",
    }

    local function ensure_todo_file()
      vim.fn.mkdir(todo_dir, "p")
      if vim.fn.filereadable(todo_file) == 0 then
        vim.fn.writefile(todo_template, todo_file)
      end
    end

    local function ensure_todo_sections(buf)
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      if #lines < 3 then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, todo_template)
      end
    end

    local function is_todo_buf(buf)
      return vim.api.nvim_buf_get_name(buf) == todo_file
    end

    local function toggle_checkbox()
      local line = vim.api.nvim_get_current_line()
      local new_line

      if line:match("^%- %[ %]") then
        new_line = line:gsub("^%- %[ %]", "- [x]", 1)
      elseif line:match("^%- %[x%]") then
        new_line = line:gsub("^%- %[x%]", "- [ ]", 1)
      else
        return
      end

      vim.api.nvim_set_current_line(new_line)
    end

    local function setup_todo_buffer(buf)
      vim.diagnostic.enable(false, { bufnr = buf })
      vim.b[buf].format_on_save = false
      vim.bo[buf].buflisted = false
      vim.opt_local.spell = false
      vim.keymap.set("n", "x", toggle_checkbox, { buffer = buf, silent = true, desc = "Toggle todo checkbox" })
    end

    local function open_todo_float()
      ensure_todo_file()
      local buf = vim.fn.bufadd(todo_file)
      vim.fn.bufload(buf)

      local width = math.max(40, math.floor(vim.o.columns * 0.4))
      local height = math.max(12, math.floor(vim.o.lines * 0.5))
      local row = 2
      local col = math.max(0, vim.o.columns - width - 2)

      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
      })

      vim.wo[win].winblend = 10
      vim.wo[win].number = true
      vim.wo[win].relativenumber = true

      ensure_todo_sections(buf)
      setup_todo_buffer(buf)

      vim.keymap.set("n", "q", function()
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modified then
          vim.cmd("write")
        end
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end, { buffer = buf, silent = true, desc = "Close todo float" })

      vim.api.nvim_win_set_cursor(win, { 2, 0 })
    end

    local headers = {
      m = todo_template[1],
      s = todo_template[3],
      c = todo_template[5],
      w = todo_template[7],
    }

    vim.keymap.set("n", "<leader>td", open_todo_float, { desc = "Open TODO float" })

    vim.api.nvim_create_user_command("AddTodo", function(opts)
      ensure_todo_file()
      local priority = (opts.fargs[1] or "s"):lower()
      local section = headers[priority]
      if not section then
        print("Invalid priority! Use m, s, c, or w")
        return
      end

      vim.ui.input({ prompt = "New TODO: " }, function(input)
        if not input or input == "" then
          print("Cancelled: No TODO added")
          return
        end

        local lines = vim.fn.readfile(todo_file)
        local section_index
        for i, line in ipairs(lines) do
          if line == section then
            section_index = i + 1
            break
          end
        end

        if not section_index then
          print("Error: Could not find the correct section")
          return
        end

        table.insert(lines, section_index, "- [ ] " .. input)
        vim.fn.writefile(lines, todo_file)
        print("TODO added")
      end)
    end, {
      nargs = "?",
      complete = function()
        return { "m", "s", "c", "w" }
      end,
    })

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
      pattern = todo_file,
      callback = function(args)
        if is_todo_buf(args.buf) then
          ensure_todo_sections(args.buf)
          setup_todo_buffer(args.buf)
        end
      end,
    })
  end,
}
