# Computational Evidence — knees vs. upper-tail counting functions

*Status: exploratory computation (evaluated in Lean with `#eval` on a bounded reimplementation of
`tail`/`knee` over lists). These numbers are **not** themselves formal proofs; the formal
statements are proved in `Catalog/NumberTheory/KneeTail.lean`.*

Definitions: `tail D t = #{d ∈ D : d > t}`; `knee D g = min {t : tail D t ≤ g}`.

## Small case
`D = {7, 3, 3, 9, 1}`

| t | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|---|---|
| tail D t | 5 | 4 | 4 | 2 | 2 | 2 | 2 | 1 | 1 | 0 |

| g | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| knee D g | 9 | 7 | 3 | 3 | 1 | 0 |

The knee row is the decreasing sort `9,7,3,3,1` (order statistic), and it is the conjugate
partition of the tail row (`5,4,4,2,2,2,2,1,1` is the transpose of `9,7,3,3,1`).
Area check: `9+7+3+3+1 = 23 = 5+4+4+2+2+2+2+1+1`.

## Exhaustive counterexample hunt
Search space: all 85 lists of length ≤ 3 with entries in `{0,1,2,3}`, all ordered pairs
(7 225 pairs).

* **All-gates claim** (knees equal on gates 0..3 ⟺ positive parts equal as multisets):
  0 mismatches; 457 pairs with equal knees.
* **Window claim with the clamped band** (gates `a ≤ g < a+w`, `a < 3`, `w ≤ 3`;
  counts clamped to `[a, a+w]`): 86 700 cases, **0 mismatches**.
* **Naive window claim** ("tails agree wherever `tail D t ∈ [a, a+w-1]`"):
  **5 148 violations**, e.g. `D = {5}`, `D' = ∅`, gate window `{1}`, threshold `t = 0`.
  This motivated the corrected statement (`knee_window_iff_clamp`) and the formal
  refutation `naive_closed_band_false`.
* **Zero demands**: `{0}` and `∅` have identical knees and tails, so the "iff equal
  multisets" form only holds for positive demands (`knee_eq_iff_filter_pos_eq`).
* **Area identity** `Σ_{g<|D|} knee D g = Σ D`: true on all 85 lists.

## OEIS
No integer sequence is intrinsic to the claim (it is a structural equivalence), so no OEIS
lookup was relevant.
