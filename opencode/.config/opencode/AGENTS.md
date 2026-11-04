# Global instructions

## Subagent delegation

- When a task splits into 2+ independent pieces (separate modules,
  per-file review, unrelated research questions), launch `subagent`
  calls with `background: true` — one per piece — and combine results.
  Prefer this over sequential grep/read wandering across areas.
- Delegate only what does not depend on your current context. A child
  starts empty: its prompt must be self-contained — goal, exact paths,
  relevant conventions, expected output shape.
- Do not delegate a single small step, or anything you can answer from
  context you already hold; restating context costs more than doing.
- Do not run parallel children editing overlapping files. Parallel
  work is for reads, research, and disjoint file sets.
- `explore` for read-only code/web search; `general` for multi-step
  work. While a background child runs, keep doing independent work;
  never poll for it.

## Verified tools (this machine, Oct–Nov 2026)

Project `AGENTS.md` rules override this section; explicit project bans
(e.g. no PDF builds in `~/Documents/rgpu/webinar/`) stay in force.

- md→PDF: `topdf FILE.md [key=value ...] [-- raw-pandoc-args]`
  (`~/.local/bin/topdf`) — pandoc + eisvogel + xelatex; bare `key=value`
  become pandoc metadata; author defaults to `Возисов Н.С.`, date to
  today dd.mm.yyyy. Runs detached with notify-send progress; `-F`
  converts in foreground — prefer `topdf -F <file.md>`.
- Cyrillic `~~strikeout~~` silently disappears under xelatex (soul
  limitation) — fix: `topdf -F FILE.md strikeout=true --
  --pdf-engine=lualatex` (eisvogel then loads lua-ul). Emoji are tofu
  boxes under both engines — keep them out of documents.
- TeX Live 2026: `xelatex`, `lualatex`, `pdflatex`, `latexmk`, beamer,
  `soul.sty`. pandoc templates in `~/.local/share/pandoc/templates/`
  (`eisvogel.latex`, `eisvogel.beamer`), found by name;
  `--pdf-engine=xelatex` is mandatory — without it images/fonts break.
  Beamer from md: `pandoc x.md -o x.pdf -t beamer --template=eisvogel
  --pdf-engine=xelatex`.
- PDFs: poppler-utils — `pdfinfo` page counts, `pdftotext [-layout]`,
  `pdfimages`, `pdftoppm` page→PNG, `pdfseparate`/`pdfunite`; `qpdf`
  for structural edits, `gs` for compression. Scans without a text
  layer give empty `pdftotext`; tesseract 5.5 lacks Russian data —
  OCR needs `rus.traineddata` first. Two-column ФИПИ PDFs: physical
  pages are twice the printed ones.
- Code screenshots: `silicon` 0.5.2, house style:

  ```
  silicon --font "JetBrains Mono" --theme "OneHalfLight" --background "#FFFFFF" \
          --pad-vert 34 --pad-horiz 34 --line-pad 4 -l python -o out.png in.py
  ```

  `--window-title` caption; `--line-offset N` + `sed -n '10,25p'`
  fragment for mid-file numbering; `--highlight-lines 6-22` dims the
  rest; `-l bash` over `<(python3 file.py)` captures run output.
- Images: ImageMagick 7.1 — call as `magick`; GIMP 3.2.6 — batch via
  Script-Fu; graphviz `dot` for diagrams.
- Office: LibreOffice 26.2 headless converts formats (`soffice
  --headless --convert-to csv <file.ods>`); if the GUI is open the
  headless call may attach to it instead. No openpyxl/pandas/odfpy —
  `.xlsx`/`.ods` are zips, inspect with `unzip -l` or convert.
- Archives: `zip`/`unzip`, `7z`, `unrar`. Terminal: `rg`, `fd`, `bat`,
  `eza`, `jq`, `fzf`, `rename`; `tldr` (tealdeer) needs one-time
  `tldr --update` before use. Toolchains: python3, node/npm,
  gcc/make/cmake, cargo/rustc.
