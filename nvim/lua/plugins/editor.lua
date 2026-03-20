return {
  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
    },
    config = function(_, opts)
      local autopairs = require("nvim-autopairs")
      autopairs.setup(opts)
      -- Integrate with nvim-cmp
      local cmp_ok, cmp = pcall(require, "cmp")
      if cmp_ok then
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },

  -- Comment toggle (Ctrl+/)
  {
    "numToStr/Comment.nvim",
    keys = {
      { "<C-/>", function() require("Comment.api").toggle.linewise.current() end, desc = "Toggle comment" },
      { "<C-/>", "<Esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", mode = "v", desc = "Toggle comment" },
    },
    opts = {},
  },

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-`>", "<cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
      { "<C-`>", "<cmd>ToggleTerm<CR>", mode = "t", desc = "Toggle terminal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", desc = "Float terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal size=15<CR>", desc = "Horizontal terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<CR>", desc = "Vertical terminal" },
      { "<leader>gg", desc = "LazyGit" },
    },
    opts = {
      size = 15,
      shade_terminals = true,
      shading_factor = 2,
      direction = "horizontal",
      float_opts = { border = "rounded" },
      on_open = function(term)
        -- Esc Esc to exit terminal mode
        vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { buffer = term.bufnr, desc = "Exit terminal mode" })
      end,
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      -- LazyGit dedicated terminal
      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit = Terminal:new({
        cmd = "lazygit",
        direction = "float",
        float_opts = { border = "rounded" },
        hidden = true,
      })

      vim.keymap.set("n", "<leader>gg", function() lazygit:toggle() end, { desc = "LazyGit" })
    end,
  },

  -- Auto close/rename HTML/JSX tags
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },

  -- Surround: ys/ds/cs + motion + char; visual S to wrap selection
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Incremental selection expand/shrink (like VS Code Expand Selection)
  {
    "sustech-data/wildfire.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      keymaps = {
        init_selection = "<C-j>",
        node_incremental = "<C-j>",
        node_decremental = "<C-k>",
      },
    },
  },
}
