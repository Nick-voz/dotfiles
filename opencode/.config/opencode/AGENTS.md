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
