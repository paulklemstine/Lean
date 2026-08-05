# Computational evidence — weak/strong `B_d`-free families

All computations below were run by exhaustive search in Python (ground sets `[n]`
with `n ≤ 7`).  They guided the choice of statements that are *formally proved*
in `Catalog/Bridges/B3FreeFamilies.lean`; where a statement is claimed as
verified in the Lean file, the Lean proof — not this table — is the authority.
The numbers in this file come from ad-hoc exploration and are **not** machine-checked.

## 1. `e(B_3) = 3`: how many consecutive layers stay `B_3`-free?

A weak copy of `B_3` was searched for by backtracking over injective
order-preserving maps `2^[3] → F`.

| `n` | all 3 consecutive layers `[a, a+2]` weak `B_3`-free? | all 4 consecutive layers `[a, a+3]` (with `a+3 ≤ n`) contain a copy? |
|-----|---|---|
| 3 | yes | yes |
| 4 | yes | yes |
| 5 | yes | yes |
| 6 | yes | yes |
| 7 | yes | yes |

Formalized as `layers_weakFree` / `exists_strongCopy_layers`, combined in
`weakFree_layers_iff` and `strongFree_layers_iff` (`k` consecutive layers are
weak/strong `B_d`-free **iff** `k ≤ d`).

## 2. Exact values of `La(n, P)` for tiny `n` (brute force over all `2^(2^n)` families)

| `n` | `La(n, B_2)` | 2-layer construction | `La(n, B_3)` | 3-layer construction | `2^n` |
|-----|---|---|---|---|---|
| 2 | 3 | 3 | 4 | 4 | 4 |
| 3 | 6 | 6 | 7 | 7 | 8 |
| 4 | 10 | 10 | 14 | 14 | 16 |

So for `n ≤ 4` the layer construction is *exactly* optimal.  The case
`La(3, B_3) = 7` is formally proved (`La_boolLat3_fin3`), as is the general
statement `La(d, B_d) = 2^d − 1` when the ground set has exactly `d` elements
(`La_boolLat_eq_of_card_eq`).

## 3. Counterexample hunt: can the layer family be improved by *adding* sets?

For each `n` we took the three central layers and tested, for every single set
`A` outside them, whether the enlarged family is still weak `B_3`-free.

| `n` | central layers | size | extra sets keeping `B_3`-freeness |
|-----|---|---|---|
| 4 | 1,2,3 | 14 | 0 / 2 |
| 5 | 1,2,3 | 25 | 0 / 7 |
| 6 | 2,3,4 | 50 | 0 / 14 |
| 7 | 2,3,4 | 91 | 0 / 37 |

**Finding.** The three central layers are *maximal* weak `B_3`-free families:
no single set can be added.  Any `ε`-improvement (the content of the paper) must
therefore delete part of the layers and rebuild, not merely append.  This is a
useful negative result: naive "layers plus extras" constructions cannot work.

## 4. Asymptotics of the layer bound

Ratio `(C(n,⌊n/2⌋−1) + C(n,⌊n/2⌋) + C(n,⌊n/2⌋+1)) / C(n,⌊n/2⌋)`:

| `n` | 4 | 6 | 8 | 10 | 20 | 40 | 100 | 1000 |
|-----|---|---|---|---|---|---|---|---|
| ratio | 2.3333 | 2.5000 | 2.6000 | 2.6667 | 2.8182 | 2.9048 | 2.9608 | 2.9960 |

The ratio increases to `3 = e(B_3)` from below, confirming that the three-layer
construction only gives `(3 − o(1)) C(n,⌊n/2⌋)`, and that a result of the form
`La(n, B_3) ≥ (3 + ε) C(n,⌊n/2⌋)` genuinely needs a different construction.
The formalized quantitative version of the layer bound is
`three_mul_choose_le_La_boolLat3 : 3 * C(n, ⌊n/2⌋ − 2) ≤ La(n, B_3)`.

## 5. OEIS

No new integer sequence was isolated: the quantities appearing here are sums of
central binomial coefficients (e.g. `A001405` for `C(n,⌊n/2⌋)`); the sequence
`La(n,B_3)` for `n = 2,3,4` (`4, 7, 14`) is too short to identify meaningfully.

## 6. Update: which of these observations are now machine-checked

The following items, previously only supported by the ad-hoc search reported above,
are now theorems in the Lean files (checked by the kernel, no `sorry`, no
`native_decide`):

* §3 (the central layers are maximal): `not_strongFree_insert_layers`,
  `layers_maximal_weakFree`, `layers_maximal_strongFree` in
  `Catalog/Bridges/B3FreeFamiliesBounds.lean`, for all `d`, `a`, `n` with `a + d ≤ n`.
* §2 (`La(4, B_3) = 14`): `La_boolLat3_fin4`, as the case `d = 3` of
  `La_boolLat_eq_of_card_eq_succ : La(d+1, B_d) = 2^(d+1) − 2`.
* §4 (three layers cannot exceed `3·C(n, ⌊n/2⌋)` by much): the complementary upper
  bound `La_boolLat3_le : La(n, B_3) ≤ 7·C(n, ⌊n/2⌋)` is now proved, so the truth
  lies in `[3 − o(1), 7]·C(n, ⌊n/2⌋)`.

The remaining numbers in this file (e.g. `La(4, B_2) = 10`) are still ad-hoc
exploration and are *not* machine-checked.

## 7. Update: levels and symmetry

A further observation from the small-case data was that the best families that are
determined by the *sizes* of their sets always consist of `d` consecutive central
layers, and never of a spread-out selection of levels.  This is now a theorem, for all
`n` and `d`, in `Catalog/Bridges/B3FreeFamiliesLevels.lean`:

* `levelFamily_weakFree_iff` — the family of all sets whose size lies in `S` is weak
  (equivalently strong) `B_d`-free iff `S` realizes at most `d` levels; the levels need
  not be consecutive, the required strong copy of `B_d` is built explicitly
  (`exists_strongCopy_of_levels`).
* `sum_choose_le_sum_choose_window` — for any `d` levels, `∑_{i ∈ S} C(n,i)` is at most
  the same sum over the `d` central levels `[centralStart n d, centralStart n d + d)`.
* `level_extremal` — consequently the level-restricted extremal number equals the size of
  those `d` central layers, and `symmetric_weakFree_card_le` extends this to every
  permutation-invariant family.

Sample values of the central window (evaluated in Lean with `#eval`):
`centralStart 6 3 = 2` with window weight `C(6,2)+C(6,3)+C(6,4) = 50`, and
`centralStart 7 3 = 2` with weight `C(7,2)+C(7,3)+C(7,4) = 91`; both agree with the
brute-force maxima over all 3-element sets of levels.
