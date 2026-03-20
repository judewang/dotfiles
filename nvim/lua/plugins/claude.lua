return {
  -- snacks.nvim as terminal provider for claudecode.nvim
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      terminal = { enabled = true },
    },
  },

  -- claudecode.nvim: proper Claude Code IDE integration via MCP WebSocket
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      -- Disable default keymaps, use our own below
      keymaps = { disable_default = true },
      terminal = {
        provider = "snacks",
        snacks_win_opts = {
          position = "right",
          width = 0.40,
        },
      },
      auto_start = true,
    },
    keys = {
      { "<leader>ai", "<cmd>ClaudeCode<cr>",             desc = "Toggle Claude" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>",       mode = "v", desc = "Send selection" },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
    },
  },
}
