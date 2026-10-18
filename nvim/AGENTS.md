# nvim — LazyVim

LazyVim with extras: mini-surround, mini-move, json, markdown, python, toml.
Stylua format: spaces, indent 2, width 120 (`stylua.toml` in the config).

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
