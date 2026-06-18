# Future Directions — Tropical Valuation Objects from Combinatorial Species

Derived from the two completed research cycles in
`Catalog/Bridges/SpeciesTropicalValuation.lean` and
`Catalog/Bridges/SpeciesTropicalPipeline.lean`, which proved that the support-threshold
(order) valuation of a nonnegative species coefficient profile is a **min-plus tropical
valuation**: additive species ↦ pointwise `min` of thresholds (`order_add`), binomial
convolution ↦ `+` of thresholds (`order_binConvNat`), packaged on the catalog object
`minPlusTropObj`, with a certified computable extractor (`firstSupport_eq_order`) and a
linear power law (`order_convPow`).

Each conjecture below is falsifiable: it either yields the stated equality/inequality or a
concrete counterexample forces refinement of the species class.

## 1. Bundled tropical semiring valuation morphism
**Conjecture.** The four laws (`order convUnit = 0`, `order_add`, `order_binConvNat`, and
`order` of the zero sequence `= ⊤`) assemble into a `RingHom`-like *valuation morphism*
from the species counting semiring `(ℕ → ℕ, +, ⋆, δ, 0)` into the tropical semiring
`Tropical (WithTop ℕ)` (min-plus), and this morphism is the unique semiring map sending
`X ↦ 1`.
**The key insight is** that cycle 1 already proves equalities (not just `≥`), so the only
missing ingredient is recognizing `(ℕ → ℕ, ⋆)` as a commutative monoid with unit `δ` —
which `order_convUnit` and `binConv_comm` (from the catalog) already supply.
**Why now?** Mathlib has `Tropical` and `binConv_comm` is in the catalog; bundling closes the
gap between our four standalone laws and a reusable `→+*` arrow other files can compose with.

## 2. The threshold is exactly the EGF order (valuation = analytic order)
**Conjecture.** For every species `F`, `speciesThreshold F = PowerSeries.order (egf F.coeffSeq)`
under the `WithTop ℕ ≃ ℕ∞` identification, i.e. the *combinatorial* support threshold equals the
*analytic* order of the exponential generating function.
**The key insight is** that dividing by `n!` (which is a unit in `ℚ`) never changes which
coefficient first becomes nonzero, so the tropical valuation is invariant under the EGF transform.
**Why now?** `CombinatorialSpecies.egf` and `egf_injective` are already proved; this would make the
threshold a genuine bridge invariant shared by the enumerative and analytic pictures.

## 3. Sub-multiplicativity collapses to additivity iff no zero divisors
**Conjecture.** Over a coefficient *ring* `R` with possible cancellation, the convolution valuation
satisfies only `order(a⋆b) ≥ order a + order b`, with equality for **all** `a,b` iff `R` has no zero
divisors (an integral domain). For `R = ℤ/6` one can exhibit `a,b` with strict inequality.
**The key insight is** that our equality proof used `C(i+j,i)·aᵢ·bⱼ ≠ 0`, which is precisely the
absence of zero divisors; introducing them must break exactness at the leading term.
**Why now?** The cycle-1 proof isolates the single surviving antidiagonal term, so generalizing the
hypothesis on `R` and searching for a `ZMod 6` counterexample is a direct, bounded experiment.

## 4. Derivative and pointing lower the threshold predictably
**Conjecture.** With the catalog derivative/pointing species, `speciesThreshold F.derivative =
speciesThreshold F - 1` (truncated, with the `⊤` and `0` corners handled), and
`speciesThreshold F.pointed = speciesThreshold F` unless `F` has a constant term, in which case it
strictly increases by the index of the first *pointable* structure.
**The key insight is** that the EGF derivative shifts coefficients down by one (`egf_derivative`)
and the Euler operator multiplies the `n`-th coefficient by `n`, so the threshold transforms by a
shift on `ℕ∞`.
**Why now?** `EGF_derivativeSpecies` and `EGF_pointedSpecies` are already in the catalog; this turns
Joyal's differential calculus into explicit tropical shift operators.

## 5. A tropical Newton-polygon functor for two-variable species
**Conjecture.** For bivariate (weighted) species with coefficient table `a : ℕ × ℕ → ℕ`, the
support-threshold construction extends to the **lower Newton polygon** of the table, and the species
product becomes Minkowski sum of polygons — a 2D refinement of `order_binConvNat`.
**The key insight is** that the 1D threshold `min { n | aₙ ≠ 0 }` is the 0-dimensional Newton
polygon, and convolution-as-addition is the 1D shadow of Minkowski addition.
**Why now?** Mathlib has `Finset`-based convexity and Minkowski sums; lifting cycle 1's
antidiagonal argument to two indices is the natural next bridge into tropical geometry proper.
