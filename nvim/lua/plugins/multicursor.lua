return {
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = "VeryLazy",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      local set = vim.keymap.set

      -- VS Code Cmd+D: select the word under the cursor, repeat to add the next match
      set({ "n", "x" }, "<C-d>", function() mc.matchAddCursor(1) end,
        { desc = "Multicursor: add next match" })

      -- VS Code Cmd+Shift+L: add cursors to ALL matches at once
      set({ "n", "x" }, "<leader>D", function() mc.matchAllAddCursors() end,
        { desc = "Multicursor: select all matches" })

      -- Add a cursor on the line below / above (VS Code Cmd+Opt+Down / Up)
      set({ "n", "x" }, "<A-Down>", function() mc.lineAddCursor(1) end,
        { desc = "Multicursor: add cursor below" })
      set({ "n", "x" }, "<A-Up>", function() mc.lineAddCursor(-1) end,
        { desc = "Multicursor: add cursor above" })

      -- Layer: these bindings are active ONLY while multiple cursors exist,
      -- so they never shadow the global mappings outside multicursor mode.
      mc.addKeymapLayer(function(layerSet)
        -- Skip the current match and jump to the next one (VS Code Cmd+K Cmd+D)
        layerSet({ "n", "x" }, "<C-x>", function() mc.matchSkipCursor(1) end,
          { desc = "Multicursor: skip to next match" })
        -- Cycle which cursor is the main one
        layerSet({ "n", "x" }, "<Left>", mc.prevCursor, { desc = "Multicursor: prev cursor" })
        layerSet({ "n", "x" }, "<Right>", mc.nextCursor, { desc = "Multicursor: next cursor" })
        -- Esc clears all cursors (falls through to normal Esc when none exist)
        layerSet("n", "<Esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end, { desc = "Multicursor: clear" })
      end)

      -- Theme the multicursor highlights to match tokyonight
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { link = "Cursor" })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { link = "SignColumn" })
    end,
  },
}
