-- Global keymaps (VS Code-like)
local map = vim.keymap.set

-- Save
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR><Esc>", { desc = "Save file" })

-- Quit
map("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit all" })

-- Better window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize windows
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Move lines (Alt+j/k)
map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("i", "<A-j>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move line up" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<CR>", { desc = "Force delete buffer" })

-- Better indenting (stay in visual mode)
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- jk as Esc in insert mode
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- F1 = Command Palette (like VS Code Ctrl+Shift+P)
map({ "n", "i", "v" }, "<F1>", "<cmd>Telescope commands<CR>", { desc = "Command palette" })

-- F8 = Go to next problem (like VS Code)
map("n", "<F8>", vim.diagnostic.goto_next, { desc = "Go to next problem" })
map("n", "<S-F8>", vim.diagnostic.goto_prev, { desc = "Go to previous problem" })

-- Jump list navigation (VS Code-like Alt+Left / Alt+Right)
map("n", "<C-->", "<C-o>", { desc = "Jump to previous cursor position" })
map("n", "<C-_>", "<C-i>", { desc = "Jump to next cursor position" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Diagnostic navigation
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- LSP keymaps (set when LSP attaches)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
  callback = function(event)
    local buf = event.buf
    local opts = function(desc)
      return { buffer = buf, desc = desc }
    end

    map("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
    map("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
    map("n", "gr", vim.lsp.buf.references, opts("Go to references"))
    map("n", "gi", vim.lsp.buf.implementation, opts("Go to implementation"))
    map("n", "K", vim.lsp.buf.hover, opts("Hover documentation"))
    map("n", "<F2>", vim.lsp.buf.rename, opts("Rename symbol"))
    map("n", "<F12>", vim.lsp.buf.definition, opts("Go to definition"))
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts("Code action"))
    map("n", "<leader>cr", vim.lsp.buf.rename, opts("Rename symbol"))
  end,
})

-- Chinese Simplified <-> Traditional conversion (requires the `opencc` CLI)
-- Normal mode acts on the current line, visual mode on the selection.
local function opencc(config)
  return function()
    if vim.fn.executable("opencc") == 0 then
      vim.notify("opencc not found — run `brew install opencc`", vim.log.levels.ERROR, { title = "OpenCC" })
      return
    end

    local visual = vim.fn.mode():match("^[vV\22]") ~= nil
    local saved = {
      z = { vim.fn.getreg("z"), vim.fn.getregtype("z") },
      unnamed = { vim.fn.getreg('"'), vim.fn.getregtype('"') },
    }

    vim.cmd(visual and 'noautocmd normal! "zy' or 'noautocmd normal! V"zy')

    local out = vim.fn.system({ "opencc", "-c", config }, vim.fn.getreg("z"))
    if vim.v.shell_error == 0 then
      vim.fn.setreg("z", out, vim.fn.getregtype("z"))
      vim.cmd('noautocmd normal! gv"zp')
    else
      vim.notify(out, vim.log.levels.ERROR, { title = "OpenCC" })
    end

    vim.fn.setreg("z", saved.z[1], saved.z[2])
    vim.fn.setreg('"', saved.unnamed[1], saved.unnamed[2])
  end
end

-- Lives here rather than in textcase.lua so it does not depend on text-case.nvim loading.
map({ "n", "v" }, "gaz", opencc("s2twp"), { desc = "To Traditional Chinese (TW)" })
