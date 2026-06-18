# Future Directions — Maslov Dequantization (Tropical = Limit of Classical)

The file `Catalog/Tropical/MaslovDequantization.lean` formalizes the deformation
`a ⊕_h b := h·log(exp(a/h) + exp(b/h))` and proves the dequantization limit
`a ⊕_h b → max a b` as `h → 0⁺`, together with the exact translation law
`(a+c) ⊕_h (b+c) = (a ⊕_h b) + c`, the sandwich `max a b ≤ a ⊕_h b ≤ max a b + h·log 2`,
and the sharp idempotency defect `a ⊕_h a = a + h·log 2`. These results upgrade the
purely combinatorial max-plus content of `Tropical.Basic` and `Tropical.MinPlusAlgebra`
to an analytic limit statement. The directions below are concrete, falsifiable next steps.

## 1. The n-ary dequantization limit over a finite index set

Conjecture: define `maslovFin h (f : Fin n → ℝ) := h·log (∑ i, exp (f i / h))`. Then for
`n ≥ 1`, `maslovFin h f → Finset.univ.sup' ⟨0,…⟩ f` (i.e. `max_i f i`) as `h → 0⁺`, with the
exact sandwich `max_i f i ≤ maslovFin h f ≤ max_i f i + h·log n`.

The key insight is that the two-term sandwich generalizes verbatim once `2` is replaced by
the cardinality `n`: the sum of `n` exponentials is squeezed between the single dominant term
and `n` copies of it, so the only change in the limit is that the defect constant `log 2`
becomes `log n`, which still vanishes after multiplication by `h`.

Why now? The binary case is already fully proved with only standard axioms, and Mathlib's
`Finset.sum`, `Real.add_pow_le_pow_mul_pow_of_sq_le_sq`-style estimates, and
`tendsto_of_tendsto_of_tendsto_of_le_of_le'` make the squeeze argument mechanical to lift to
finite sums; this turns one scalar identity into a statement about arbitrary tropical
polynomials evaluated at a point.

## 2. Uniform (not just pointwise) convergence on compact sets

Conjecture: on any compact box `K ⊆ ℝ²`, `sup_{(a,b)∈K} |a ⊕_h b − max a b| ≤ h·log 2`, hence
`(a,b) ↦ a ⊕_h b` converges **uniformly** to `(a,b) ↦ max a b` as `h → 0⁺`, with an explicit
rate independent of the point.

The key insight is that the additive defect bound `0 ≤ a ⊕_h b − max a b ≤ h·log 2` proved in
`maslov_le_max_add`/`maslov_ge_max` is already uniform in `(a,b)` — it never mentions `a` or `b`
on the right — so uniform convergence is essentially free once phrased with `TendstoUniformly`.

Why now? Uniformity is the precise sense in which tropical varieties are limits of amoebas
(cf. `Tropical.AmoebaRonkin`); having a pointwise limit plus a point-independent bound is exactly
the hypothesis Mathlib's `tendstoUniformly_iff` needs, so the upgrade is low-risk and directly
connects this file to the existing amoeba material in the catalog.

## 3. Tropicalization of polynomial roots via the deformed semiring

Conjecture: for a "classical" univariate expression built from `+` (classical) and `⊕_h`
(deformed max), the `h → 0⁺` limit of its real logarithmic profile is the corresponding tropical
polynomial, and the locus where the maximum in the tropical polynomial is attained twice (the
tropical variety) is the limit of the level sets where the dominant exponential balances a
competitor.

The key insight is that `maslov_add_right` shows ordinary addition is *exactly* the deformed
multiplication at every `h` (no error term), so a deformed polynomial is genuinely a classical
object whose only `h`-dependence sits in the `⊕_h` operations; the tropical variety is then the
set of corners where `maslov_self`'s `h·log 2` defect signals a tie between two monomials.

Why now? The exact (error-free) distributive law is already proved, which is the crucial
ingredient missing from a naive "everything is approximate" picture; with it, root/balancing
statements reduce to comparisons of two exponentials, which the squeeze infrastructure handles.

## 4. The min-plus (dual) deformation and a temperature-reflection symmetry

Conjecture: the dual operation `a ⊟_h b := -h·log(exp(-a/h) + exp(-b/h))` satisfies
`a ⊟_h b → min a b` as `h → 0⁺`, and is conjugate to `⊕_h` by negation:
`a ⊟_h b = -((-a) ⊕_h (-b))` for all `h ≠ 0`.

The key insight is that negation is an order-reversing semiring isomorphism between the max-plus
and min-plus worlds, and because the Maslov operation is built from `exp`/`log` it intertwines
with negation cleanly; the min-plus limit then follows from the max-plus one with zero new
analysis, just `maslov_tendsto_max` composed with the continuous map `x ↦ -x`.

Why now? The catalog's `Tropical.MinPlusAlgebra` works in the min-plus convention while this
file is max-plus; establishing the negation conjugacy as a theorem makes every result here
immediately transportable to that file, eliminating duplicated effort across the two conventions.

## 5. Quantitative entropy interpretation: the defect equals a Gibbs free-energy correction

Conjecture: `a ⊕_h b − max a b = h·H(p)` is *not* generally true, but the defect is exactly
`h·log(1 + exp(−|a−b|/h))`, a strictly decreasing function of `|a−b|/h`; consequently the defect
is largest (`h·log 2`) precisely on the tropical diagonal `a = b` and decays exponentially away
from it.

The key insight is that factoring out the dominant exponential turns the defect into a single
`softplus` term `h·log(1 + exp(−|a−b|/h))`, exposing `|a−b|/h` as the natural "inverse
temperature × gap" order parameter; `maslov_self` is the maximal-defect boundary case of this
formula at gap `0`.

Why now? `maslov_self` already pins the `a=b` endpoint and the sandwich pins the two extremes, so
proving the exact softplus formula is an algebraic `log_mul`/`exp` manipulation of the kind
already used in `maslov_add_right`; it would give the catalog a clean bridge between tropical
geometry (`Tropical.StatisticalMechanics.Basic`) and statistical-mechanical free energy.
