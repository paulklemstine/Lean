# Computational Evidence: line-covering threshold for checkmate on the Hilbert board

The formalization lives in `Geometry/HilbertChessLines.lean`. Long-range chess
pieces (rooks, bishops, queens, any ray) are modelled as affine lines
`a·x + b·y = c` on `ℤ × ℤ`. The central quantitative claim is:

> A single line covers **at most 3** of the 9 squares of a king's `3 × 3`
> neighbourhood; hence `n` lines cover at most `3n`, so at least `3` long-range
> pieces are needed to cover all 9 (a prerequisite for checkmate), and `3`
> suffice.

## 1. Small-case calculations — how many block squares can one line cover?

Take the block centred at the origin, the 9 offsets `(i,j)`, `i,j ∈ {-1,0,1}`.

| line (a,b,c)        | type       | covered offsets                     | count |
|---------------------|------------|-------------------------------------|-------|
| `y = 0`  (0,1,0)    | rook (horiz.) | (-1,0),(0,0),(1,0)               | 3     |
| `x = 0`  (1,0,0)    | rook (vert.)  | (0,-1),(0,0),(0,1)               | 3     |
| `y = x`  (1,-1,0)   | bishop     | (-1,-1),(0,0),(1,1)                 | 3     |
| `y = -x` (1,1,0)    | bishop     | (-1,1),(0,0),(1,-1)                 | 3     |
| `y = 2x` (2,-1,0)   | knight-slope line | (0,0) (others leave the block)| 1     |
| `2x+3y=1`           | generic    | (2,-1)? no int in block → (−1,1)? test | ≤3 |

Every direction attains **at most 3**, and the four "aligned" directions attain
exactly 3. No line reaches 4, matching `Line.block_card_le_three`.

## 2. The `3n` bound and the sharp threshold

* `n = 1`: ≤ 3 of 9 covered ⟹ ≥ 6 safe.
* `n = 2`: ≤ 6 of 9 covered ⟹ ≥ 3 safe ⟹ **no checkmate** (`no_mate_with_lt_three`).
* `n = 3`: `3·3 = 9`, so covering all 9 is *arithmetically possible*, and the
  explicit three parallel rooks on rows `y = p₂−1, p₂, p₂+1` realise it
  (`mate_exists`). Threshold is sharp at **3**.

A quick check that 3 is genuinely necessary and not merely sufficient: with two
lines the six covered squares can never include all four corners *and* all four
edges *and* the centre, because `6 < 9`. This is a pure pigeonhole count, needing
no case analysis on directions — which is exactly how the Lean proof proceeds
(`blockCovered_card_le` + `blockOffsets_card = 9`).

## 3. Counterexample hunt — is any configuration of 2 lines a mate?

We attempted to cover the 9-square block with 2 lines for the "best" directions:

* two parallel rooks (rows −1,0): cover 6 squares (rows −1,0), row +1 fully safe.
* rook + bishop, vertical + `y=x`: cover `x=0` (3) ∪ `y=x` (3) = 5 squares
  (they share the centre), so 4 safe.
* two crossing bishops `y=x`, `y=−x`: cover 5 squares, 4 safe.

No pair of lines covers 7, 8, or 9 of the block squares. Consistent with the
theorem; no counterexample exists.

## 4. Global escape — the board is never fully covered

For any finite list of lines, pick a row `y = k` avoided by all horizontal
pieces (finitely many forbidden `k`), then each remaining line meets that row in
≤ 1 point, leaving cofinitely many safe squares in the row. Small check: three
rooks on rows `0,1,2` plus a bishop `y=x` leave, on row `k = 100`, only the
single point `x = 100` attacked (by the bishop), so `x ≠ 100` are all safe —
an unbounded escape corridor. Formalized as `escape_infinite` /
`escape_unbounded`.

## Conclusion

All numerical experiments agree with the formal statements; the counterexample
hunt for a 2-line mate found none, and the 3-line mate is explicit. The evidence
is elementary counting, which is precisely why the Lean proofs are unconditional.
