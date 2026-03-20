return {
  {
    "monkoose/neocodeium",
    event = "InsertEnter",
    config = function()
      local neocodeium = require("neocodeium")
      neocodeium.setup({
        show_label = false,
        filetypes = {
          ["neo-tree-popup"] = false,
          ["TelescopePrompt"] = false,
          ["toggleterm"] = false,
          ["help"] = false,
        },
        silent = true,
      })

      -- Cycle suggestions: Alt+] / Alt+[
      vim.keymap.set("i", "<A-]>", function()
        neocodeium.cycle_or_complete(1)
      end, { desc = "Next AI suggestion" })
      vim.keymap.set("i", "<A-[>", function()
        neocodeium.cycle_or_complete(-1)
      end, { desc = "Previous AI suggestion" })
      -- Accept one word
      vim.keymap.set("i", "<C-l>", function()
        neocodeium.accept_word()
      end, { desc = "Accept AI word" })
      -- Accept one line
      vim.keymap.set("i", "<C-k>", function()
        neocodeium.accept_line()
      end, { desc = "Accept AI line" })
      -- Dismiss suggestion
      vim.keymap.set("i", "<C-]>", function()
        neocodeium.clear()
      end, { desc = "Dismiss AI suggestion" })
    end,
  },
}
