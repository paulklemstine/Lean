# Computational evidence

All numbers below were produced with `#eval` inside the same Lean 4 / Mathlib environment
in which the theorems are proved. They are exploratory checks, not proofs; the
corresponding statements are proved in the `.lean` files (and, where marked, the concrete
instance is itself verified in Lean by `decide`).

## 1. Sharp transitivity of `S₃` on ordered pairs of distinct colours

For every `(a,b)` with `a ≠ b` and every `(x,y)`, the number of `π ∈ Perm (Fin 3)` with
`π a = x`, `π b = y` was enumerated over all `81` quadruples:

| condition | set of observed counts |
|---|---|
| `a ≠ b`, `x ≠ y` | `{1}` |
| `a ≠ b`, `x = y` | `{0}` |

This is exactly `perm3_pair_count` in `ThreeColoringZK.lean` (proved there by kernel
evaluation over all `6 · 81` cases), and it is what makes the GMW simulator perfect: the
opened pair of colours is uniform over the six ordered distinct pairs.

## 2. The soundness gap `1 - 1/|E|` and its tightness

Exhaustive search over all `3⁴ = 81` assignments `Fin 4 → Fin 3`:

| instance | `|E|` | max # accepted edges | acceptance probability |
|---|---|---|---|
| `K₃` (3-colourable) | 3 | 3 | `1` |
| `K₄` (not 3-colourable) | 6 | 5 | `5/6 = 1 - 1/6` |

So the bound `acceptProb ≤ 1 - 1/|E|` of `acceptProb_le_one_sub_inv` is attained: no
counterexample exists (the search is exhaustive for `K₄`), and the extremal assignment
`![0,1,2,0]` is recorded as `K4cheat`, with the equality proved in Lean as
`K4_soundness_tight`.

## 3. Exact parallel repetition

For `K₄` with `k = 2`, the maximum over assignments of the number of accepting pairs of
edges is `25 = 5²`, matching `prodAccept_card` (`accepting k-tuples = accCard ^ k`) rather
than merely being bounded by it.

## 4. Schwartz–Zippel / batching soundness

Roots of nonzero polynomials of degree `≤ 2` over small prime fields:

| polynomial | field | # roots | degree bound |
|---|---|---|---|
| `r² + 2r + 3` | `𝔽₇` | 0 | ≤ 2 |
| `4r² + 1` | `𝔽₅` | 2 | ≤ 2 |

The second row shows the bound `#bad challenges ≤ m - 1` of `batch_soundness_card` is
attained; no polynomial in the sample exceeded its degree in root count.

## 5. Random-oracle fibers

With `|Msg| = 2`, `|Chal| = 3` (so `|Msg → Chal| = 9`):

| set | count | predicted `|B| · |Msg → Chal| / |Chal|` |
|---|---|---|
| `{H : H 0 = 1}` | 3 | 3 |
| `{H : H 0 = 2}` | 3 | 3 |
| `{H : H 0 ∈ {0,2}}` | 6 | 6 |

This matches `fiber_card_const`, `fiber_card_mul` and `hashHits_card_mul` in
`NIZKFiatShamir.lean`.

## Counterexample hunt

No counterexample to any of the formalized statements was found in the searches above
(items 1 and 2 are exhaustive over their finite parameter ranges). Every general claim
tested here is subsequently proved in full generality in the Lean files.

## OEIS

No new integer sequence arises; the counts encountered (`6 = 3!`, `|C|^{|A|-1}`,
`accCard ^ k`) are elementary.
