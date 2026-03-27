return {
  -- Tokyonight theme with Glow-inspired syntax overrides
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      style = "storm",
      on_highlights = function(hl, c)
        -- Glow-inspired overrides: brighter keywords, warmer strings, vivid functions
        hl["@keyword"]          = { fg = "#00AAFF" }
        hl["@keyword.function"] = { fg = "#00AAFF" }
        hl["@keyword.return"]   = { fg = "#00AAFF" }
        hl["Keyword"]           = { fg = "#00AAFF" }
        hl["Conditional"]       = { fg = "#00AAFF" }
        hl["Repeat"]            = { fg = "#00AAFF" }
        hl["Statement"]         = { fg = "#00AAFF" }
        hl["@string"]           = { fg = "#C69669" }
        hl["String"]            = { fg = "#C69669" }
        hl["@function"]         = { fg = "#00D787" }
        hl["@function.call"]    = { fg = "#00D787" }
        hl["Function"]          = { fg = "#00D787" }
        hl["@number"]           = { fg = "#6EEFC0" }
        hl["Number"]            = { fg = "#6EEFC0" }
        hl["@boolean"]          = { fg = "#6EEFC0" }
        hl["Boolean"]           = { fg = "#6EEFC0" }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- File icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- Buffer line (tab bar)
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Explorer",
            highlight = "Directory",
            separator = true,
          },
        },
      },
    },
    keys = {
      { "<leader>1", "<cmd>BufferLineGoToBuffer 1<CR>", desc = "Go to buffer 1" },
      { "<leader>2", "<cmd>BufferLineGoToBuffer 2<CR>", desc = "Go to buffer 2" },
      { "<leader>3", "<cmd>BufferLineGoToBuffer 3<CR>", desc = "Go to buffer 3" },
      { "<leader>4", "<cmd>BufferLineGoToBuffer 4<CR>", desc = "Go to buffer 4" },
      { "<leader>5", "<cmd>BufferLineGoToBuffer 5<CR>", desc = "Go to buffer 5" },
      { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>", desc = "Close unpinned buffers" },
    },
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
      exclude = {
        filetypes = { "help", "lazy", "mason", "neo-tree" },
      },
    },
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = vim.keymap.set
        local opts = function(desc)
          return { buffer = bufnr, desc = desc }
        end

        map("n", "]h", gs.next_hunk, opts("Next hunk"))
        map("n", "[h", gs.prev_hunk, opts("Previous hunk"))
        map("n", "<leader>ghs", gs.stage_hunk, opts("Stage hunk"))
        map("n", "<leader>ghr", gs.reset_hunk, opts("Reset hunk"))
        map("n", "<leader>ghp", gs.preview_hunk, opts("Preview hunk"))
        map("n", "<leader>gb", gs.blame, opts("Blame file"))
        map("n", "<leader>gs", gs.stage_buffer, opts("Stage file"))
        map("n", "<leader>gd", gs.diffthis, opts("Diff file"))
        map("n", "<leader>gR", gs.reset_buffer, opts("Reset file"))
      end,
    },
  },
}
