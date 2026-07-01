# Computational Evidence — Crystal Reflections and the `d`-balanced Property

All computations below are reproduced *inside the formal development* as
`native_decide` checks in `Evidence.lean`; a standalone exploratory script
(`explore.py`) was used first to fix conventions.

## 1. Objects and definitions

A partition `λ` is drawn as its Young diagram; cell `(i,j)` (row `i`, column `j`,
`0`-indexed) has

* arm `a(i,j) = λ_i − 1 − j`,
* leg  `ℓ(i,j) = λ'_j − 1 − i`,
* hook `h(i,j) = a + ℓ + 1`.

`λ` is **`d`-balanced w.r.t. `e`** iff every cell with `e ∣ h(i,j)` has `d ∣ a(i,j)`.

The affine crystal-reflection operator `s_i` (residue `(j−i) mod e`) is computed
from the `i`-signature: list addable (`+`) / removable (`−`) `i`-nodes by
**decreasing content** `j−i`, cancel adjacent `+−` pairs to get `−^{ε} +^{φ}`, and
set `s_i = f_i^{φ−ε}` if `φ ≥ ε`, else `e_i^{ε−φ}`.

## 2. Small cases

| λ | e | s_0(λ) (standard) |
|---|---|-------------------|
| ∅ | 2 | (1) |
| (1) | 2 | ∅ |
| (2,1) | 2 | (3,2,1) |
| (3,1,1,1) | 3 | (4,1,1,1) |

The last row is the diagnostic case: `(3,1,1,1)` is `2`-balanced w.r.t. `3`; under
the **standard** convention `s_0(3,1,1,1) = (4,1,1,1)`, which is again
`2`-balanced w.r.t. `3`. Under the **mirror** (increasing-content) convention,
however, `s_0(3,1,1,1) = (3,2,1,1)`, which is **not** `2`-balanced w.r.t. `3`
(a hook of length 3 with arm 1). This contrast is
`mirror_convention_breaks_dBalanced` in `Evidence.lean`.

## 3. Crystal-axiom sanity checks

* `e_i ∘ f_i = id` wherever `f_i` is defined — passes for all partitions of size
  `≤ 10`, `e ∈ {2,3,4}`.
* `s_i` is an involution — `crystal_reflection_involution`: all partitions of size
  `≤ 12`, `e ∈ {2,3,4}`. **No failure.**

## 4. Counterexample hunt for the conjecture

Standard convention, exhaustive over all partitions of size `≤ 16`:

| d | e | balanced λ tested | s_i-violations |
|---|---|-------------------|----------------|
| 2 | 2 | all | 0 |
| 2 | 3 | all | 0 |
| 3 | 3 | all | 0 |
| 2 | 4 | all | 0 |
| 3 | 4 | all | 0 |
| 4 | 4 | all | 0 |
| 2 | 5 | all | 0 |
| 3 | 5 | all | 0 |
| 4 | 5 | all | 0 |

Total: **8356** `(λ, d, e, i)` checks, **no counterexample**
(`crystal_reflection_preserves_dBalanced`).

Mirror convention: a counterexample appears already at size `6`
(`(3,1,1,1)`), confirming the conjecture is orientation-specific.

## 5. Structural finding (proved, not just checked)

Conjugation `λ ↦ λ'` (the diagram automorphism of the affine Dynkin diagram)
interchanges the arm- and leg-versions of the property:
`λ` is `d`-balanced (arm) **iff** `λ'` is leg-`d`-balanced — theorem
`isDBalanced_transpose_iff_isLegBalanced`. Because conjugation swaps rows/columns,
it does **not** preserve the arm-condition itself; the crystal reflections `s_i`
do, precisely because they act within a fixed content grading.

## 6. OEIS

No new integer sequence is claimed. The count of `d`-balanced partitions of `n`
(for fixed `d, e`), computed for `n = 0..10`, gives

* `(d,e)=(2,2)`: `1, 1, 1, 2, 1, 2, 2, 2, 2, 2, 3`
* `(d,e)=(2,3)`: `1, 1, 2, 2, 4, 5, 5, 7, 9, 10, 12`
* `(d,e)=(3,3)`: `1, 1, 2, 1, 3, 3, 3, 3, 4, 5, 5`

These filtrations were used as consistency probes only and are not asserted to
match any existing OEIS entry.
