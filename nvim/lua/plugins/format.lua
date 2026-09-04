-- Web formatting is decided per repo, not globally. Some projects are on the
-- oxc toolchain (.oxfmtrc.json), the rest are still on Biome (biome.json).
-- Both are listed and every entry sets require_cwd, so a formatter only runs
-- in a repo that actually carries its config file and migrating one project
-- leaves the others alone.
--
-- oxlint is deliberately absent from these chains. conform only formats here;
-- lint fixes go through the oxlint LSP's oxc.fixAll code action
-- (`:LspOxlintFixAll`, registered in lsp.lua). Its built-in conform entry is
-- `stdin = false` and rewrites the file on disk, which would have to interleave
-- with oxfmt's stdin pipeline in an order nobody has measured.
local both = { "oxfmt", "biome-check" }

-- Biome does not handle these, so there is nothing to fall back to.
local oxfmt_only = { "oxfmt" }

return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = {
      formatters = {
        -- A formatter chain runs every entry in order; require_cwd is what
        -- turns each one into a no-op outside its own repo. The built-in cwd
        -- resolves .oxfmtrc.json but defaults require_cwd to false, so without
        -- this oxfmt would format Biome repos with its own defaults.
        oxfmt = { require_cwd = true },
        ["biome-check"] = { require_cwd = true },
      },
      formatters_by_ft = {
        javascript = both,
        javascriptreact = both,
        typescript = both,
        typescriptreact = both,
        json = both,
        jsonc = both,
        css = both,
        scss = both,
        yaml = oxfmt_only,
        html = oxfmt_only,
        markdown = oxfmt_only,
        lua = { "stylua" },
      },
      format_on_save = {
        timeout_ms = 3000,
        lsp_format = "fallback",
      },
    },
  },
}
