return {
  -- Mason: package manager for LSP servers, formatters, linters
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- Mason-lspconfig v2: bridges Mason and lspconfig
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "ts_ls",
        "biome",
        "html",
        "cssls",
        "jsonls",
        "lua_ls",
        "tailwindcss",
      },
      automatic_enable = true,
    },
  },

  -- nvim-lspconfig
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      -- Diagnostic display settings
      vim.diagnostic.config({
        virtual_text = { spacing = 4, prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded" },
      })

      -- LSP hover/signature window borders
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

      -- Server-specific configs via vim.lsp.config (Neovim 0.11 API)
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })

      vim.lsp.config("ts_ls", {
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
          },
        },
      })

      vim.lsp.config("jsonls", {
        settings = {
          json = {
            validate = { enable = true },
          },
        },
      })

      vim.lsp.config("tailwindcss", {
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
              },
            },
          },
        },
      })

      -- Oxlint diagnostics and lint fixes for projects on the oxc toolchain.
      --
      -- typeAware is pinned off. lspconfig's before_init turns it on by itself
      -- once `tsgolint` is executable and the project's .oxlintrc.json mentions
      -- "typescript" — which ours do, in plugin and rule names. CI does not run
      -- type-aware linting, so leaving that to autodetect means the editor
      -- starts reporting a different rule set the day tsgolint lands on PATH.
      -- Setting it explicitly keeps the two in step.
      --
      -- fixKind is what :LspOxlintFixAll applies. safe_fix is the server's own
      -- default, spelled out so widening it is a deliberate edit.
      vim.lsp.config("oxlint", {
        settings = {
          typeAware = false,
          fixKind = "safe_fix",
        },
      })

      -- Both servers are enabled by hand rather than through mason: their
      -- lspconfig entries prefer <root>/node_modules/.bin/, and these projects
      -- carry oxlint and oxfmt as devDependencies, so there is nothing for
      -- mason to install and the editor always matches the version CI runs.
      --
      -- They self-gate. oxlint's root_markers are { ".oxlintrc.json",
      -- "oxlint.config.ts" } and oxfmt's root_dir walks up to .oxfmtrc.json,
      -- both with workspace_required = true, so they attach only inside an oxc
      -- repo and stay out of the Biome ones. Biome's server gates the same way,
      -- so the two toolchains coexist without fighting.
      vim.lsp.enable({ "oxlint", "oxfmt" })
    end,
  },
}
