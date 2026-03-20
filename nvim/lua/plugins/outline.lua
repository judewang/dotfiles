return {
  {
    "hedyhli/outline.nvim",
    cmd = { "Outline", "OutlineOpen" },
    keys = {
      { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
      outline_window = {
        position = "right",
        width = 30,
        auto_jump = true,
      },
      symbols = {
        -- Filter for what to show (useful for JSON, TSX, etc.)
        filter = nil, -- show all by default
      },
      symbol_folding = {
        autofold_depth = 1, -- auto-fold nested items beyond depth 1
      },
    },
  },
}
