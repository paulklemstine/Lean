# Future Directions: Sharp Information Inequalities and Entropy Power

This cycle formalized, in `Catalog/Bridges/GibbsEqualityPinsker.lean`, the *sharp*
form of the discrete Gibbs inequality together with the discrete Pinsker
inequality:

* `kl_nonneg` — Gibbs' inequality `0 ≤ KL(μ‖ν)`.
* `kl_eq_zero_iff_eq` — the equality characterization `KL(μ‖ν) = 0 ↔ μ = ν`.
* `kl_self_eq_zero` — the boundary case `KL(μ‖μ) = 0`.
* `binary_pinsker` — Pinsker for two-point distributions, via convexity of the
  binary KL.
* `pinsker_general` — `(1/2)·‖μ−ν‖₁² ≤ KL(μ‖ν)`, bridging the Gibbs inequality
  (`Bridges.LogSumExpVariational.gibbs_inequality_finite`,
  `Bridges.ContinuousDiscreteTransfer.kl_le_chiSq`) to total-variation distance.

These results turn the catalog's *qualitative* `KL ≥ 0` into a *quantitative,
two-sided* control: KL is squeezed between `(1/2)‖μ−ν‖₁²` (Pinsker, below) and
`χ²(μ‖ν)` (catalog `kl_le_chiSq`, above), vanishing exactly on the diagonal. The
following directions extend this frontier.

## 1. Bretagnolle–Huber and the saturation of Pinsker

Pinsker's bound `KL ≥ (1/2)‖μ−ν‖₁²` becomes vacuous when KL is large, because the
total-variation distance is capped at `‖μ−ν‖₁ ≤ 2`. The Bretagnolle–Huber
inequality repairs this: `‖μ−ν‖₁ ≤ 2·√(1 − exp(−KL(μ‖ν)))`, equivalently
`KL(μ‖ν) ≥ −log(1 − (‖μ−ν‖₁/2)²)`. The key insight is that the *same* two-group
log-sum reduction used in `pinsker_general` collapses the general statement to a
binary one, after which the binary case is a single-variable calculus inequality
analogous to `binary_pinsker` but with the sharper concave right-hand side
`−log(1 − (a−b)²)`. Combined with our Pinsker bound this yields a complete
"small-deviation vs. large-deviation" dictionary for KL.

**Why now?** `pinsker_general` already isolates the partition `s = {μ ≥ ν}` and the
reduction `‖μ−ν‖₁ = 2(P₁−Q₁)`; only the binary inequality
`binary_BH : −Real.log (1 − (a−b)^2) ≤ a·log(a/b) + (1−a)·log((1−a)/(1−b))` is new,
and it is provable by the very `convexOn_of_deriv2_nonneg` machinery that closed
`binary_pinsker`.

## 2. The full chi-square sandwich and refined stability

The catalog proves `KL ≤ χ²` (`kl_le_chiSq`) and this cycle proves
`KL ≥ (1/2)‖μ−ν‖₁²`. Together they sandwich KL, but the lower and upper proxies
live in different metrics. The natural unification is the refined chain
`(1/2)‖μ−ν‖₁² ≤ KL(μ‖ν) ≤ log(1 + χ²(μ‖ν)) ≤ χ²(μ‖ν)`. The key insight is that the
middle inequality `KL ≤ log(1 + χ²)` is *Jensen applied to the concave logarithm*
against the same probability weights used in `log_sum_group`, so the existing
`Real.convexOn_mul_log` / `ConcaveOn.le_map_sum` toolkit transfers directly.
This produces the tightest elementary two-sided KL estimate stated purely in terms
of `coeffDist` and `chiSqDiv`.

**Why now?** Both endpoints are already formalized in the catalog; the missing link
reuses the Jensen pattern from `log_sum_group` verbatim, with `log` in place of
`x·log x`.

## 3. Data-processing monotonicity of KL under finite stochastic maps

`log_sum_group` is exactly the two-group case of the data-processing inequality:
lumping outcomes cannot increase KL. The general statement is that for any
stochastic kernel (column-stochastic matrix) `T : β → α → ℝ`, the pushforwards
satisfy `KL(Tμ ‖ Tν) ≤ KL(μ‖ν)`. The key insight is that each output coordinate is
a *convex combination* of input ratios, so the joint convexity of the map
`(x,y) ↦ x·log(x/y)` (the perspective of `x·log x`) gives the bound termwise; our
`log_sum_group` is precisely this for the deterministic "merge" kernel. Proving the
joint-perspective convexity lemma `perspective_mul_log_convex` is the one genuinely
new ingredient and unlocks contraction-coefficient theory.

**Why now?** `log_sum_group` already encodes the partition/merge case and was proved
from `Real.convexOn_mul_log`; generalizing from a 0/1 kernel to an arbitrary
stochastic kernel is a finite-sum bookkeeping step on top of the joint convexity.

## 4. Sanov-type lower bound and exponential concentration

With `kl_eq_zero_iff_eq` pinning the unique zero of KL at `μ = ν`, the next
quantitative step is the finite, non-asymptotic Sanov lower bound: for i.i.d.
samples from `ν`, the probability that the empirical distribution lands in a set
`E` of distributions decays like `exp(−n·inf_{μ∈E} KL(μ‖ν))`. The key insight is
that the method-of-types counting estimate `|T(μ_type)| ≤ exp(n·H(μ))` combined with
`KL(μ‖ν) = log|support| − H(μ) − (correction)` (the `gaussianProximity` identity
from `Catalog/Catalog/Bridges/EntropyPowerInequality.lean`) turns a purely
combinatorial multinomial bound into the divergence rate. This directly couples the
*equality theory* proved here (the rate is zero iff `μ = ν`) to large-deviation
exponents.

**Why now?** The exact zero-set of the rate function is now formalized
(`kl_eq_zero_iff_eq`), and the entropy/`log card` infrastructure
(`shannonEntropy`, `entropy_le_log_card`) already exists in the catalog; the
remaining step is the multinomial-coefficient estimate, a finite computation.

## 5. Discrete log-Sobolev and the entropy method for concentration

Pinsker controls KL by an `L¹` (first-moment) quantity; a strictly stronger and
more flexible control is a *modified log-Sobolev inequality*
`Ent(f) ≤ C·Dirichlet(f)` for the uniform or product measure, where `Ent` is the
entropy functional dual to KL. The key insight is that tensorization of entropy —
the statement `Ent_{μ⊗ν}(f) ≤ E_ν[Ent_μ(f)] + E_μ[Ent_ν(f)]`, itself a
consequence of the variational `KL ≥ 0` we sharpened — lifts a one-coordinate log-
Sobolev constant to all dimensions, yielding sub-Gaussian concentration via Herbst's
argument. This would connect our pointwise `kl_term_eq_iff` (equality on the
diagonal) to dimension-free concentration on the discrete cube.

**Why now?** The variational characterization of entropy is exactly
`Bridges.LogSumExpVariational.freeEnergy_le_lse` plus the sharp `kl_nonneg` /
`kl_eq_zero_iff_eq` of this cycle; tensorization is a two-coordinate application of
the same Gibbs inequality, and Herbst's argument is an ODE comparison on the
moment-generating function that Mathlib's calculus library can support.
