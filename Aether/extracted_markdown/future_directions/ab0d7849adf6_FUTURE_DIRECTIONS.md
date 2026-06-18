# Future Directions — p-adic Tropical Ultrametrics from Valuation Depth

## Synthesis

This cycle closed a bridge that the catalog had left open on both ends. On the
**Computation** side, `Catalog/Computation/PadicValuationDepth.lean` supplied a
valuation-depth philosophy and the genuine p-adic ultrametric facts
(`padic_norm_ultrametric`, `padic_dist_ultrametric`, `padic_norm_mul`). On the
**Bridges** side, `Catalog/Bridges/CategoricalTropicalUltrametric.lean` supplied an
abstract target interface — `TropicalValuationCarrier`, the functor
`valuationReconstruct`, `UltraNormObj`, and the morphism lift
`valuationReconstruct_map` — but no concrete arithmetic instance feeding it.

`Catalog/Bridges/PadicTropicalUltrametric.lean` connects them. It defines the
**unit-depth** seminorm `unitDepth x = ⟦‖x‖ = 1⟧` on the p-adic integers `ℤ_[p]`,
proves it is an ℕ-valued, multiplicative, ultrametric seminorm
(`unitDepth_zero/_neg/_mul/_add`), packages it as a concrete
`TropicalValuationCarrier` (`padicUnitCarrier`), and transports it through the
existing categorical functor to obtain a verified `UltraNormObj`
(`padicUnitUltra`) whose strong triangle law and multiplicativity are theorems
(`padicUnit_reconstruct_ultrametric`, `padicUnit_reconstruct_mul`). The induced
distance `d x y = unitDepth (x − y)` is proven to be an ultrametric
(`padicDist_strong_triangle`, `padicDist_comm`, `padicDist_self`), depth-preserving
carrier morphisms are shown non-expansive (`depth_preserving_nonexpansive`), with a
concrete isometric example (`mulByUnit`, `mulByUnit_isometry`).

The decisive technical finding — recorded as a Failure analysis in the file — is
that the *abstract* `ValuationDepthMeasure.vdepth` does **not** instantiate
`UltraNormObj`: its `vdepth_add` carries a `+ 1`, so it is only a *lax* ultrametric.
The strong triangle law requires a genuine valuation, which is exactly why we had to
descend to `ℤ_[p]` and `PadicInt.nonarchimedean`. The honest negative companion
result `padicUnit_not_separated` shows the construction is a true *seminorm* (the
maximal ideal `p·ℤ_[p]` collapses to depth `0`), not a norm.

## Results Summary

- `unitDepth_mul` — multiplicativity of the unit-depth seminorm.
- `unitDepth_add` — strong (ultrametric) triangle inequality, from `PadicInt.nonarchimedean`.
- `padicUnitCarrier` / `padicUnitUltra` — a concrete instance of the catalog's abstract interface.
- `padicUnit_reconstruct_ultrametric` — the reconstructed object is ultrametric.
- `padicDist_strong_triangle` — `d(x,z) ≤ max(d(x,y), d(y,z))` for the induced distance.
- `mulByUnit` / `mulByUnit_isometry` / `depth_preserving_nonexpansive` — functorial non-expansiveness.
- `padicUnit_not_separated` — the construction is a seminorm, not a norm.

All theorems compile with `sorry`-free proofs depending only on
`propext`, `Classical.choice`, and `Quot.sound`.

## Research Directions

**1. Graded valuation depth: escape the {0,1} ceiling via the residue tower.**
The unit-depth lands in `{0,1}` because an ℕ-valued multiplicative ultrametric
absolute value on a ring whose `1` is additively reachable is forced (Ostrowski-style)
into `{0,1}`. The conjecture is that the *quotient tower* `ℤ_[p] / pⁿ` carries a
genuinely `{0,1,…,n}`-valued depth `depthₙ x = min(n, v_p(x))` that satisfies a
*graded* strong triangle law `depthₙ(x+y) ≥ min(depthₙ x, depthₙ y)` and is
sub-multiplicative, instantiating a *filtered* family of `UltraNormObj`s whose limit
recovers the full additive valuation. The key insight is that range is recovered not by
changing the codomain semiring but by truncating the valuation at finite precision,
turning the rigidity obstruction into a directed system. Why now? `padicValRat`/
`padicValInt` and `Nat.min` are already in Mathlib, and the present file fixes the
exact interface (`TropicalValuationCarrier`) that such a tower must populate, so the
only new content is the order-reversal (min vs max) bookkeeping.

**2. The additive (min,+) tropicalization is the *true* tropical image.**
The catalog's `TropicalValuationObject` uses (max, ·); genuine tropical geometry uses
(min, +) with `v(xy) = v(x) + v(y)`. Conjecture: there is a faithful functor from
`ℚ`-with-`padicValRat` into a (min,+) tropical object such that
`v(x+y) ≥ min(v x, v y)` and `v(xy) = v(x) + v(y)` hold as equalities/inequalities,
and that this functor is *adjoint* to the (max, ·) `valuationReconstruct` via the
logarithm/exponential `n ↦ p^{-n}`. The key insight is that the `+1` lax defect of
`ValuationDepthMeasure` disappears precisely when one passes to the additive
convention, because circuit-depth "cost +1" is the additive shadow of multiplicative
norm collapse. Why now? `padicValRat.add_eq_of_lt` and friends give the exact min-law
in Mathlib, and the present bridge already isolates which axioms must be re-expressed.

**3. Separated quotient: the canonical ultrametric *space* of the seminorm.**
`padicUnit_not_separated` shows the seminorm is degenerate. Conjecture: quotienting
`ℤ_[p]` by the depth-`0` kernel (the maximal ideal) yields an `UltraSeparated`
`UltraNormObj` isomorphic to the residue field `𝔽_p` with its trivial valuation, and
this quotient is the universal separated object receiving every depth-preserving map.
The key insight is that "seminorm minus its kernel" is a functor landing in the
`UltraSeparated` subcategory already defined in `CategoricalTropicalUltrametric.lean`,
making `padicUnit_not_separated` the obstruction class of a localization. Why now? The
`UltraSeparated` class and `separated_norm_detects_equality` already exist in the
catalog; only the kernel-quotient construction is missing.

**4. Contractive Hensel iteration as an ultrametric fixed-point theorem.**
The Computation file certifies quadratic Hensel convergence numerically
(`HenselConvergenceData.precision_exponential`). Conjecture: a Newton map that is
`unitDepth`-contractive (`unitDepth(f x − f y) ≤ unitDepth(x − y)` strictly on the
maximal ideal) has a unique fixed point reachable in `O(log n)` steps, recovered as a
Banach-style fixed-point theorem *internal to* the reconstructed `UltraNormObj`. The
key insight is that the abstract `ultrametric_fixed_point_one_step_bound` of the
Bridges file becomes a genuine convergence theorem once fed the concrete contractive
constant supplied by `padicDist_strong_triangle`. Why now? Both the abstract one-step
bound and the numeric Hensel certificate already exist; this direction merely glues
them through the new distance.

**5. Cross-prime product carriers and an adelic depth.**
Conjecture: the finite product `∏_{p ≤ N} padicUnitCarrier p` carries a
componentwise depth whose `UltraNormObj` reconstruction satisfies a *simultaneous*
strong triangle law, and whose separated quotient is `∏ 𝔽_p` — a finite-adelic
analogue. The key insight is that `valuationReconstruct` and `valuationReconstruct_map`
are already proven functorial (`valuationReconstruct_map_comp`), so products of carriers
map to products of ultrametric objects automatically, making the adelic assembly a
formal consequence rather than new analysis. Why now? The functoriality lemmas needed
to commute reconstruction with finite products are exactly the catalog results this
cycle reused, so the construction is within immediate reach.
