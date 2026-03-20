local parsers = {
  "typescript",
  "tsx",
  "javascript",
  "json",
  "html",
  "css",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "yaml",
  "toml",
  "bash",
  "vim",
  "vimdoc",
  "regex",
  "diff",
  "gitignore",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()

      -- Install parsers if missing (wait up to 5 minutes for completion)
      local ts = require("nvim-treesitter")
      local installed = ts.get_installed()
      local to_install = {}
      for _, parser in ipairs(parsers) do
        if not vim.list_contains(installed, parser) then
          table.insert(to_install, parser)
        end
      end
      if #to_install > 0 then
        ts.install(to_install):wait(300000)
      end

      -- Enable treesitter highlighting and indentation for all supported filetypes
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true }),
        callback = function()
          if pcall(vim.treesitter.start) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
