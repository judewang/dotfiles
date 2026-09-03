-- Web formatting is decided per repo, not globally. Some projects are on the
-- oxc toolchain (.oxfmtrc.json / .oxlintrc.json), the rest are still on Biome
-- (biome.json). Both are listed and every entry sets require_cwd, so a
-- formatter only runs in a repo that actually carries its config file and
-- migrating one project leaves the others alone.
local web = { "oxfmt", "oxlint", "biome-check" }
local data = { "oxfmt", "biome-check" }

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
        -- Built-in cwd already resolves .oxfmtrc.json; require_cwd turns that
        -- into a gate instead of a hint, so oxfmt never formats a Biome repo
        -- with its own defaults.
        oxfmt = { require_cwd = true },

        -- The built-in definition has no cwd at all, so without this oxlint
        -- would --fix files in every project. Gate it on .oxlintrc.json.
        --
        -- exit_codes: `oxlint --fix` exits 1 whenever an unfixable finding
        -- remains, which is the normal state of a file carrying suppressed
        -- debt. Default exit_codes is {0}, so conform would report a format
        -- failure on nearly every save. It still applies what it can fix.
        oxlint = {
          cwd = require("conform.util").root_file({ ".oxlintrc.json" }),
          require_cwd = true,
          exit_codes = { 0, 1 },
        },

        ["biome-check"] = { require_cwd = true },
      },
      formatters_by_ft = {
        javascript = web,
        javascriptreact = web,
        typescript = web,
        typescriptreact = web,
        -- No oxlint here: it is a JS/TS linter, not a JSON tool.
        json = data,
        jsonc = data,
        -- oxfmt is intentionally absent. The oxc projects here exclude CSS from
        -- the formatter, and oxfmt passes an ignored path straight through, so
        -- listing it would only add a no-op pass.
        css = { "biome-check" },
        lua = { "stylua" },
      },
      format_on_save = {
        timeout_ms = 3000,
        lsp_format = "fallback",
      },
    },
  },
}
