-- Autocommands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Restore cursor position
autocmd("BufReadPost", {
  group = augroup("RestoreCursor", { clear = true }),
  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-resize splits on window resize
autocmd("VimResized", {
  group = augroup("ResizeSplits", { clear = true }),
  command = "tabdo wincmd =",
})

-- Close some filetypes with 'q'
autocmd("FileType", {
  group = augroup("CloseWithQ", { clear = true }),
  pattern = { "help", "man", "qf", "checkhealth", "notify", "lspinfo" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})

-- Follow symlinks to their real path.
-- Dotfiles are symlinked out of config repos (e.g. ~/.claude/settings.json ->
-- coramdeo-config/claude/settings.json), and path-relative tooling resolves
-- against the buffer name: formatters look upward for biome.json/.editorconfig,
-- git plugins look for .git. Editing via the link makes all of them miss.
autocmd("BufReadPost", {
  group = augroup("ResolveSymlink", { clear = true }),
  callback = function(event)
    if vim.bo[event.buf].buftype ~= "" then
      return
    end
    local name = vim.api.nvim_buf_get_name(event.buf)
    local real = name ~= "" and vim.uv.fs_realpath(name) or nil
    if not real or real == name then
      return
    end
    -- Re-edit under the real path so LSP and git plugins attach to it too.
    -- Deferred: reloading inside BufReadPost re-enters filetype detection.
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(event.buf) then
        return
      end
      vim.api.nvim_buf_call(event.buf, function()
        -- keepalt so the alternate file stays useful.
        vim.cmd("keepalt file " .. vim.fn.fnameescape(real))
        vim.cmd("edit!")
      end)
    end)
  end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = augroup("TrimWhitespace", { clear = true }),
  pattern = "*",
  command = [[%s/\s\+$//e]],
})
