# Computational evidence — curvature of a model pool

All numbers below come from ad-hoc exploratory computation (double-precision
floating point) and are **not** machine-verified. They were used only to decide
*which* statements to attempt in Lean. Every claim that appears as a theorem in
`Catalog/Cryptography/UniversalRedundancyCurvature.lean` is proved there
without `sorry`; the exploratory numbers here are evidence, not proof.

Setting: models `p_1, …, p_N` are probability mass functions on a finite
alphabet `X`; the price of a library `A` is the Shtarkov sum
`C(A) = ∑_x max_{i ∈ A} p_i(x)`; the curvature of the pool `Ω` is
`κ = 1 − min_{j ∈ Ω} (C(Ω) − C(Ω∖{j}))/C({j})`.

## 1. Small-case calculations

Random pools (`|X| = 4`, `|Ω| = 5`, 400 trials, uniform Dirichlet-like
normalised uniforms), greedy library of size `n = 3` versus the exact optimum
over all 3-subsets:

| trial | κ | greedy/opt | `(1−e^{−κ})/κ` | `1 − curvatureProd(3,κ,3)` |
|---|---|---|---|---|
| 0 | 1.0000 | 0.853031 | 0.632121 | 0.703704 |
| 1 | 1.0000 | 0.867133 | 0.632121 | 0.703704 |
| 2 | 1.0000 | 0.948599 | 0.632121 | 0.703704 |
| 3 | 1.0000 | 1.000000 | 0.632121 | 0.703704 |
| 6 | 1.0000 | 0.881328 | 0.632121 | 0.703704 |
| 7 | 1.0000 | 0.973581 | 0.632121 | 0.703704 |

Minimum over the 400 trials of `greedy/opt − (1−e^{−κ})/κ` was `+0.2209`, i.e.
**no counterexample to the conjectured factor was found**.

Striking observation: *every* random pool had `κ = 1`. The reason is
combinatorial, not numerical: with `|Ω| = 5 > 4 = |X|` at most `|X|` models can
be the pointwise maximum-likelihood explanation, so some model is redundant and
its marginal value in the full pool is `0`. This observation became the theorem
`curvature_eq_one_of_card_lt` (*pigeonhole curvature saturation*).

## 2. Counterexample hunt for `κ ≤ δ·|Ω|`

The conjecture predicts that pools of pairwise total-variation distance `≤ δ`
have small curvature. The computation says the opposite:

| pool | max pairwise TV `δ` | κ | conjectured bound `δ·|Ω|` |
|---|---|---|---|
| two identical fair coins | 0 | 1.000000 | 0 |
| `{(.6,.4), (.5,.5), (.4,.6)}` | 0.20 | 1.000000 | 0.60 |
| `{(.51,.49), (.5,.5), (.49,.51)}` | 0.02 | 1.000000 | 0.06 |
| `{(.501,.499), (.5,.5), (.499,.501)}` | 0.002 | 1.000000 | 0.006 |

Nearly identical pools are *maximally* curved: when the sources almost agree,
each one adds almost nothing on top of the others, so the numerator of the
marginal ratio is almost `0` and `κ ≈ 1`. This produced two theorems:
`one_sub_tv_le_curvature` (`κ ≥ 1 − (|Ω|−1)·δ`) and the explicit refutation
`not_curvature_le_tv_mul_card` (twin fair coins: `δ = 0`, `κ = 1`).

## 3. How strong is the proved product bound?

The theorem `greedy_curvature_gap_le` gives the decay factor
`Q(n,κ) = ∏_{i<n} (1 − 1/(n − (1−κ)i))`, i.e. the guarantee `1 − Q(n,κ)`.
Compared with the conjectured factor `(1 − e^{−κ})/κ`:

| n | κ | `1 − Q(n,κ)` (proved) | `(1−e^{−κ})/κ` (conjectured) |
|---|---|---|---|
| 2 | 0.10 | 0.954545 | 0.951626 |
| 3 | 0.10 | 0.941799 | 0.951626 |
| 5 | 0.10 | 0.932844 | 0.951626 |
| 10 | 0.05 | 0.960060 | 0.975412 |
| 3 | 0.50 | 0.800000 | 0.786939 |
| 5 | 0.90 | 0.689437 | 0.659367 |

So the proved bound is *stronger* than the conjecture for larger κ and for very
small `n`, and *weaker* for small κ with `n ≥ 3`. In particular the conjectured
`(1 − e^{−κ})/κ` factor is **not** implied by the accounting used here; closing
that gap (a Conforti–Cornuéjols style linear-programming argument over all
greedy steps rather than a step-by-step recursion) is left as the first future
direction. Both endpoints of the conjecture *are* proved:
`κ = 0` gives exact optimality (`greedy_zero_curvature_optimal`) and `κ = 1`
gives `1 − 1/e` (`greedy_one_sub_inv_exp_le_pool`), and
`greedy_low_curvature_gap` proves a gap of at most `κ·(n−1)` — the qualitative
"low curvature ⇒ nearly optimal" statement.

## 4. OEIS

No integer sequence arises: all objects here are real-valued set functions, so
an OEIS search is not applicable.
