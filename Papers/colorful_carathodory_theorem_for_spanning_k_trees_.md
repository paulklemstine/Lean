# Computational Evidence

## 1. Face counts of the width-`m` skeleton (`∑_{i≤m} C(n,i)`)

For a ground set of `n` vertices and faces of at most `m` vertices, the number of
faces is `∑_{i=0}^{m} C(n,i)`:

| n \ m | m=1 | m=2 | m=3 |
|-------|-----|-----|-----|
| 3     | 4   | 7   | 8   |
| 4     | 5   | 11  | 15  |
| 5     | 6   | 16  | 26  |
| 6     | 7   | 22  | 42  |
| 10    | 11  | 56  | 176 |

Reading columns: for fixed `m` the counts grow like a degree-`m` polynomial in `n`
(`m=1` linear: 4,5,6,7,...,11; `m=2` quadratic; `m=3` cubic). This matches
`skeleton_card_eq_choose_sum` and the degree bound `choose_sum_le_poly`
(`∑_{i≤m} C(n,i) ≤ (m+1)(n+1)^m`), e.g. `n=10,m=2`: `56 ≤ 3·121 = 363`.

## 2. Spanning trees: linear collapse (`k = 1`)

A spanning tree on `n` vertices has exactly `n-1` edges and `n` vertices, so its
clique complex has `1 + n + (n-1) = 2n` faces:

| n            | 2  | 3  | 4  | 5  | 10 |
|--------------|----|----|----|----|----|
| tree faces   | 4  | 6  | 8  | 10 | 20 |
| generic m=2  | 2  | 7  | 11 | 16 | 56 |

For `n ≥ 4` the tree face count `2n` is strictly below the generic width-`2`
quadratic count, confirming the acyclicity-driven collapse of
`spanningTree_face_count`.

## 3. Colorful capture on the line (counterexample hunt)

Testing `colorful_caratheodory_dim1` on random sign-mixed classes: whenever each
of `V₁, V₂` contains both a nonpositive and a nonnegative value, a rainbow edge
through `0` was always found by pairing `min' V₁` (≤0) with `max' V₂` (≥0). No
counterexample exists — the argument is exhaustive via extreme points. Example:
`V₁ = {-2, 1}`, `V₂ = {-3, 4}` gives rainbow edge `{-2, 4} ∋ 0`.

If either class lies strictly on one side of `0` its hull misses the origin, so the
hypothesis fails and the statement is vacuously respected — no spurious capture is
claimed.

## Note on scope
Evidence is intentionally small-scale and confirmatory; the formal file supplies
exact identities (`skeleton_card_eq_choose_sum`, `spanningTree_face_count`) and
universally quantified bounds, which subsume any finite table.
