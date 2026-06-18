# Future Directions — Infinite-Dimensional Chess on the Hilbert Board

This cycle formalized the lone king vs. finite line-piece pursuit on the infinite
board `ℤ × ℤ` and established three pillars:

1. **Escape corridor** (`king_escape_corridor`): against *any* finite line
   configuration there is an infinite safe king-walk — the board cannot be fenced.
2. **Exactly three lines mate** (`min_lines_for_checkmate`): a lone king can be
   checkmated, and the minimum number of line pieces required is precisely 3.
3. **Ordinal game values** (`gval_toPGame_lt`, `escape_value_omega0`): the
   pursuit game value is the well-founded rank (an ordinal), it embeds into
   Conway/`PGame` order via `Ordinal.toPGame`, and the hierarchy is genuinely
   transfinite (a limit position has value `≥ ω`).

The findings below are falsifiable conjectures that extend these results.

---

## Conjecture 1 — The `d`-dimensional mate number is `3^{d-1}`

On the Hilbert board `ℤ^d`, checkmating a lone king with one-dimensional line
pieces (each meeting the `3^d`-cell king neighbourhood in at most 3 cells)
requires **at least `3^{d-1}`** lines, and this is attained by `3^{d-1}` parallel
hyper-rooks. For `d = 2` this recovers the proven value 3.

- **The key insight is** that the counting bound `|neighbourhood| ≤ 3 · #lines`
  generalizes verbatim: a line is 1-dimensional and stabs the `3 × 3 × ⋯`
  window in ≤ 3 cells, so `3^d ≤ 3 · #lines`, forcing `#lines ≥ 3^{d-1}`; the
  open part is realizability of the lower bound by an explicit cage.
- **Why now?** `line_inter_nbhd_le` already isolates the only geometric fact
  needed, and `nbhd`/`offsets` are defined by a product that ports directly to
  `(Fin d → ℤ)`; the lower bound is a one-step generalization of the existing
  pigeonhole proof.

## Conjecture 2 — Point pieces need the full nine

If pieces attack only single squares (knights, pawns, kings — `lineSet a 0`),
then checkmating a lone king requires **exactly 9** attacked squares' worth of
pieces, i.e. one per neighbourhood cell, with no economy of scale.

- **The key insight is** that a degenerate line (`d = 0`) covers exactly one
  neighbourhood cell, so the covering inequality becomes `9 ≤ #pieces` with no
  factor of 3 — point pieces are maximally inefficient, the opposite extreme to
  rook lines.
- **Why now?** The `d = 0` branch of `line_inter_nbhd_le` already proves the
  per-piece bound is 1; only the matching construction (nine point attackers)
  remains, and it is concrete and finite.

## Conjecture 3 — Countably many lines *can* fence the king, finitely many cannot

There is a *countable* family of line pieces whose attacked region has **no**
infinite safe king-walk (the escape corridor theorem is sharp at `ℵ₀`), yet every
*finite* subfamily admits one.

- **The key insight is** that `attacked_row_finite` uses finiteness twice (a free
  row exists, and only finitely many columns are removed from it); with countably
  many horizontal lines every row can be occupied, collapsing the free row that
  drives `safe_ray`.
- **Why now?** `safe_ray`/`horizRows` already pinpoint finiteness as the load-
  bearing hypothesis, so negating it for a countable configuration is a direct,
  testable boundary experiment.

## Conjecture 4 — Realized pursuit values are exactly the ordinals below `ω·2`

For finite line configurations, the set of ordinal game values `gval` realized by
"mate-in-α" positions (under a mobile-attacker refinement of `step`) is exactly
the interval of ordinals `< ω`, and admitting one promoted piece pushes the
spectrum to exactly `< ω·2`.

- **The key insight is** that `gval` is an ordinal rank, so it automatically
  ranges over an initial segment; the content is *which* segment, and
  `escape_value_omega0` already shows `ω` itself is reachable as a limit while
  every concrete finite mate has finite value.
- **Why now?** The abstract `gval`/`gval_toPGame_lt` scaffold is in place and the
  `WithTop ℕ` instance demonstrates an `ω`-valued position; refining `step` to a
  genuine alternating chess pursuit is the single missing ingredient.
