# Computational evidence

All numbers below were produced by `#eval` inside Lean 4 / Mathlib, in the file
`Catalog/Algebra/PosetFlow/Evidence.lean` (which compiles as part of the project).
They were computed *before* the corresponding statements were formalised, and each
of them is now covered by a machine-checked theorem.

## 1. Chains in a linear order

For the linear order `Fin 4`:

| quantity | value |
|---|---|
| `#(chains from 0 to 3)` | `4` (= `2 ^ 2`, one for each subset of the interior) |
| `chainAltSum 0 3` | `0` |
| `chainAltSum 0 1` | `1` |
| `μ(0,3)`, `μ(0,1)` | `0`, `-1` |

The two rows are consistent with Philip Hall's theorem `chainAltSum x y = -μ x y`
(`PosetFlow.chainAltSum_eq_neg_mu`).

## 2. Counterexample hunt for Philip Hall's theorem

Exhaustive checks of the universal statement `∀ x y, chainAltSum x y = -μ x y`:

| poset | number of pairs | result |
|---|---|---|
| `Fin 5` (chain) | 25 | `true` |
| `B₃ = Finset (Fin 3)` (Boolean lattice, 8 elements) | 64 | `true` |

No counterexample was found; the statement is now proved in general
(`PosetFlow.chainAltSum_eq_neg_mu`).

## 3. Chains from `⊥` to `⊤` in Boolean lattices

| `n` | `#(chains ⊥ → ⊤ in Bₙ)` |
|---|---|
| 1 | 1 |
| 2 | 3 |
| 3 | 13 |

These are the *ordered Bell (Fubini) numbers* `1, 3, 13, 75, …`
(OEIS **A000670**, shifted): a chain from `⊥` to `⊤` in `Bₙ` is the same thing as
an ordered set partition of an `n`-set, the blocks being the successive
differences. Correspondingly
`chainAltSum ⊥ ⊤ = 1` and `μ(⊥,⊤) = -1 = (-1)³` for `B₃`, as predicted by Hall's
theorem together with the classical value `μ_{Bₙ}(⊥,⊤) = (-1)ⁿ`.

## 4. Cone points and the vanishing of the alternating face sum

| poset | `∑_{faces C of the order complex} (-1)^{#C}` | has a cone point? |
|---|---|---|
| `Fin 4` | `0` | yes (`⊥`) |
| `B₂ = Finset (Fin 2)` | `0` | yes (`⊥`) |
| two-element antichain | `-1` | **no** |

The first two are instances of
`PosetFlow.alternatingSum_orderComplex_eq_zero_of_conePoint`; the third shows the
hypothesis is not removable (an antichain with two points is homotopy equivalent to
two points, reduced Euler characteristic `1`, so the unreduced alternating sum is
`-1`).

## 5. The open-interval form

| interval | `∑_{faces of Δ(x,y)} (-1)^{#F}` | `-μ(x,y)` |
|---|---|---|
| `(⊥,⊤)` in `B₃` (interior = 6 elements) | `1` | `1` |
| `(∅,{0,1})` in `B₃` (interior = 2-element antichain) | `-1` | `-1` |

Both agree with `PosetFlow.alternatingSum_openInterval_eq_neg_mu`.

## 6. Order-reflection is necessary

For the two-element antichain `{a, b}` mapping injectively and monotonically into
the two-element chain, the number of chains from `a` to `b` in the source is `0`
while the target does have a chain between the images (which is supported on the
image). This computation is the seed of the theorem
`PosetFlow.orderReflecting_necessary`.
