# nvim — LazyVim

LazyVim with extras: mini-surround, mini-move, json, markdown, python, toml.
Stylua format: spaces, indent 2, width 120 (`stylua.toml` in the config).

## Tabs

Tabs are the exception, not the rule: use buffers for navigation
(`S-h`/`S-l`, `<leader>fb`, `<leader>bd`); reserve tabs for whole layouts.

- Tabline is permanently hidden (`showtabline = 0` in `config/options.lua`).
  lualine (`plugins/lualine.lua`) shows `2/3` only while >1 tab is open.
- `<leader>t` group (`config/keymaps.lua`): `tn` new, `tw` close,
  `to` close others. LazyVim's `<leader><tab>` defaults are unset there.
- `<leader>ft` — tabs picker (`config/tabs.lua`): other tabs, most recently
  visited first, files listed per tab (current tab is skipped, like
  `recent`'s current file) — so `<leader>ft<cr>` is "back to the previous
  tab", a toggle between the two most recent ones;
  Enter switches, `w`/`<c-x>` closes a tab from the list
  (hops there and back — vim can't close a background tab any other way;
  the current tab is never in the list, so it can't be misclosed).
- Tab rows use real tab numbers from `gettabinfo()` (same as `:tabs`);
  `nvim_list_tabpages()` returns handles — they drift apart after closes.
- Terminals moved from `<leader>ft`/`fT` to `<leader>tt` (root) and
  `<leader>tT` (cwd). `<c-/>` still toggles the root terminal.
- `<leader>ut` toggles the tabline back on (moved from LazyVim's `<leader>uA`;
  unsetting a toggle keymap also prunes its which-key entry — they map with
  `real = true`, and which-key drops real-mapped nodes with no keymap).
- `config/keymaps.lua` loads after LazyVim's defaults, so overrides/unsets
  of default keymaps belong there, not in plugin `keys` specs.

## Diffs

Neogit renders diffs through diffview, so `lua/plugins/diffview.lua`
decides every layout — including commits, staged and unstaged files.
diffview names layouts by the axis the panes sit on, the opposite of
Vim's splits: `diff2_horizontal` = side by side (`:vsp`), `diff2_vertical`
= stacked (`:sp`). Two-sided views use the former; merge tool keeps
`diff4_mixed`.

parrot.nvim reads `PERPLEXITY_API_KEY`, which comes from the untracked
`~/.config/.env` (see the root `AGENTS.md`). Inside the menu window that env
is sourced by the menu server — see `awesome/AGENTS.md`.

## Lockfile

`lazy-lock.json` stays **tracked** — it pins plugin commits, which is what
makes the config reproducible. Do not gitignore it.

Routine `:Lazy update` bumps land as pure hash diffs (no plugins added or
removed). Commit those as their **own** commit, separate from config edits:

    nvim: update lazy plugin lockfile

`gitignore` is only for machine-local state (see the root `AGENTS.md`).
