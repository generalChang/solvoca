# Three card states and a daily Queue of ten, not spaced repetition

Solvoca is a small local-only study app. A Card is New, Learning, or Mastered; Mastered takes three consecutive Knew days; the default Queue is at most ten Cards, Learning first. We rejected Anki-style intervals and an unbounded daily mix because they would grow the session, add settings, and fight the product's one job: a short daily loop with high-polish UX.

## Considered Options

- **Spaced repetition (due dates per Card):** the obvious study-app default. Rejected: interval math, extra UI, and a Queue that cannot be explained in one sentence.
- **Binary Unseen/Known:** too coarse — one Knew would graduate a Card, and first-day luck would empty the pool.
- **Chosen: New / Learning / Mastered + cap of ten:** progress accumulates, a session still ends, and Learning backlog blocks New instead of inflating the day.
