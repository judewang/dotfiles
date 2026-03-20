return {
  {
    "johmsalas/text-case.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("textcase").setup({})
      require("telescope").load_extension("textcase")
    end,
    keys = {
      -- Open Telescope picker to choose case conversion
      { "<leader>cc", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "v" }, desc = "Convert case (picker)" },

      -- Direct conversions via ga prefix (mnemonic: go-alter)
      { "gas", "<cmd>lua require('textcase').current_word('to_snake_case')<CR>",    desc = "To snake_case" },
      { "gac", "<cmd>lua require('textcase').current_word('to_camel_case')<CR>",    desc = "To camelCase" },
      { "gap", "<cmd>lua require('textcase').current_word('to_pascal_case')<CR>",   desc = "To PascalCase" },
      { "gak", "<cmd>lua require('textcase').current_word('to_dash_case')<CR>",     desc = "To kebab-case" },
      { "gau", "<cmd>lua require('textcase').current_word('to_upper_case')<CR>",    desc = "To UPPER CASE" },
      { "gal", "<cmd>lua require('textcase').current_word('to_lower_case')<CR>",    desc = "To lower case" },
      { "gaU", "<cmd>lua require('textcase').current_word('to_constant_case')<CR>", desc = "To CONSTANT_CASE" },
      { "gat", "<cmd>lua require('textcase').current_word('to_title_case')<CR>",    desc = "To Title Case" },
      { "ga.", "<cmd>lua require('textcase').current_word('to_dot_case')<CR>",      desc = "To dot.case" },

      -- Same but operate on visual selection
      { "gas", "<cmd>lua require('textcase').visual('to_snake_case')<CR>",    mode = "v", desc = "To snake_case" },
      { "gac", "<cmd>lua require('textcase').visual('to_camel_case')<CR>",    mode = "v", desc = "To camelCase" },
      { "gap", "<cmd>lua require('textcase').visual('to_pascal_case')<CR>",   mode = "v", desc = "To PascalCase" },
      { "gak", "<cmd>lua require('textcase').visual('to_dash_case')<CR>",     mode = "v", desc = "To kebab-case" },
      { "gau", "<cmd>lua require('textcase').visual('to_upper_case')<CR>",    mode = "v", desc = "To UPPER CASE" },
      { "gal", "<cmd>lua require('textcase').visual('to_lower_case')<CR>",    mode = "v", desc = "To lower case" },
      { "gaU", "<cmd>lua require('textcase').visual('to_constant_case')<CR>", mode = "v", desc = "To CONSTANT_CASE" },
      { "gat", "<cmd>lua require('textcase').visual('to_title_case')<CR>",    mode = "v", desc = "To Title Case" },
    },
  },
}
