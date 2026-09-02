# Computational evidence — multiset erasure ledger

All numbers below are reproduced as **kernel-checked Lean theorems** in
`Catalog/Novelty/MultisetSortingLabNotes.lean` (`decide` / explicit `Real` computations, never
`native_decide`); nothing here rests on an unchecked script.

## 1. Small cases of the counting law

For a key word `w` on `n` slots with multiplicities `m`, the conjecture is
`#{distinguishable inputs} = n! / ∏ mᵢ!`.

| key word     | `n` | `m`        | `n!` | `∏ mᵢ!` | predicted | verified in Lean |
|--------------|-----|------------|------|---------|-----------|------------------|
| `a a b b`    | 4   | `(2,2)`    | 24   | 4       | 6         | `card_rearrangements_wAABB` |
| `a a b b c`  | 5   | `(2,2,1)`  | 120  | 4       | 30        | `card_rearrangements_wAABBC` |
| `a a b b b`  | 5   | `(2,3)`    | 120  | 12      | 10        | `card_rearrangements_coarsened` |
| distinct     | `n` | all `1`    | `n!` | 1       | `n!`      | `card_rearrangements_of_injective` |
| all equal    | `n` | `(n)`      | `n!` | `n!`    | 1         | `rearrangements_of_constant` |

The division-free identity `#orbit · ∏ mᵢ! = n!` is checked at `(2,2)`
(`orbit_stabilizer_wAABB`: `6 · 4 = 24`) and proved in general
(`card_rearrangements_mul_prod_factorial`).

Sequence remark: the balanced two-key family `n = 2k`, `m = (k,k)` gives the central binomial
coefficients `1, 2, 6, 20, 70, …` (the `k`-th central binomial coefficient), and the general
counting function is the multinomial coefficient — both are the classical objects, so no new OEIS
entry is implied.

## 2. Counterexample hunt against the Shannon ceiling

Claim tested: `log₂(n!/∏ mᵢ!) ≤ n·H(p)` with `pᵢ = mᵢ/n`.

| `m`       | `n` | erased bits `log₂ M` | `n·H(p)` bits | slack |
|-----------|-----|----------------------|---------------|-------|
| `(2,2)`   | 4   | `log₂ 6  ≈ 2.585`    | `4`           | 1.415 |
| `(2,2,1)` | 5   | `log₂ 30 ≈ 4.907`    | `≈ 7.219`     | 2.312 |
| `(2,3)`   | 5   | `log₂ 10 ≈ 3.322`    | `≈ 4.855`     | 1.533 |
| `(1,1)`   | 2   | `1`                  | `2`           | 1     |
| `(n)`     | `n` | `0`                  | `0`           | 0     |

No counterexample was found, and the slack is positive in every mixed case.  This suggested — and
we then proved — that the inequality is **strict** whenever two distinct keys occur
(`infoErased_lt_keyEntropyBits`), with equality only in the degenerate single-key case.  The
`(2,2)` instance is machine-checked as `infoErased_wAABB_lt_keyEntropyBits` (`log₂ 6 < 4`).

## 3. Coarsening (data-processing) probe

Merging keys `b, c ↦ b` in `a a b b c` gives `a a b b b`, and the count drops `30 → 10`
(`coarsening_strictly_decreases`).  Merging never increased the count in any case tried, which
led to the general surjection proof (`card_rearrangements_le_of_coarsening`).

## 4. Merge probe

Concatenating `a a` (over `{a}`) with `b b` (over `{b}`) predicts
`C(4,2) · 1 · 1 = 6` distinguishable inputs, matching the direct count for `a a b b`.  The general
identity `multinomial(m ⊕ m') = C(n+n',n)·multinomial(m)·multinomial(m')` is proved in
`Catalog/Novelty/MultisetSortingMerge.lean`.

## 5. Decision-tree probe

`⌈log₂ 6⌉ = 3` versus `⌈log₂ 24⌉ = 5`: two repeated keys save two binary comparisons
(`comparison_bound_wAABB`, `clog_baseline_four_distinct`, both by `decide`).
