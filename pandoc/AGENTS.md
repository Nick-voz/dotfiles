# pandoc — templates

Eisvogel template files under `.local/share/pandoc/templates/` — symlinked
to `~/.local/share/pandoc/templates/` (not `.config`).

Local fork deviations from upstream eisvogel:

- TOC title defaults to "Содержание" (still overridable via `toc-title`).
- Figure captions forced to "Рис." via `\AtBeginDocument` (beats babel).
