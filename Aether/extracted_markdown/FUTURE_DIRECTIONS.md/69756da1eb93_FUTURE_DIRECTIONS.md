# Future Directions: The Valuation–Tropicalization Bridge (cycle 2)

## Synthesis

This package now formalizes three coherent slabs of the bridge between a non-Archimedean valued
field `(K, v)` and tropical geometry, each building on the previous one:

1. **`TropicalValuationLimitBridge.lean`** — the *easy half* of the Fundamental Theorem of
   Tropical Geometry: `kapranov_easy_direction` (tropicalization of a hypersurface point lands on
   the corner locus), the ultrametric winner-takes-all lemma
   `addValuation_sum_eq_of_unique_min`, the strengthening `corner_of_leading_cancellation`, and
   min-plus multiplicativity `TropPoly.eval_mul`.

2. **`TropicalBezoutFactorization.lean`** — the *combinatorial half*: scale invariance of the
   corner locus (`attainedTwice_smul`, the "valuation → ∞" limit), the union law
   `tropRoot_mul_iff` / `tropRootSet_mul` (`V(P ⊙ Q) = V(P) ∪ V(Q)`), and Newton-polytope
   additivity `range_exp_mul` (Minkowski sum). This settled **Directions 2 and 3** of the
   original future-directions note.

3. **`TropicalValuationMorphismDefect.lean`** (this cycle) — the *algebraic half*, settling
   **Direction 5**: the tropicalization map `tropVal v : K → Tropical Γ`, `x ↦ trop (v x)`, is an
   honest multiplicative morphism (`tropValMonoidHom : K →* Tropical Γ`) and is sub-additive
   (`tropVal_add_le`); its *only* defect on addition is pinned to the diagonal tie set
   (`addValuation_add_eq_min_of_ne`, `addValuation_defect_imp_tie`), which for two monomials is
   *literally* the corner locus (`attainedTwice_fin2_iff`, `addValuation_defect_imp_corner`).
   This unifies the additive (defect) and combinatorial (corner) stories: "morphism defect =
   corner locus".

## Results summary

New, fully proved (sorry-free, only `propext`/`Classical.choice`/`Quot.sound`):

* `addValuation_add_eq_min_of_ne` — `v x ≠ v y → v (x+y) = min (v x) (v y)` (additivity off ties).
* `addValuation_defect_imp_tie` — `v(x+y) ≠ min(v x, v y) → v x = v y` (defect locus ⊆ tie set).
* `tropVal`, `tropValMonoidHom : K →* Tropical Γ` — bundled multiplicative morphism.
* `tropVal_one`, `tropVal_mul` — exact multiplicativity / unit.
* `tropVal_add_le`, `tropVal_add_eq_of_ne` — tropical sub-additivity and its equality off ties.
* `attainedTwice_fin2_iff` — two-monomial corner locus `= {a = b}`.
* `addValuation_defect_imp_corner` — every additive defect of `v` lands on the binary corner locus.

The remaining open targets are **Directions 1 (Kapranov's hard direction)** and
**Direction 4 (balancing)**, refined below alongside three new conjectures the morphism picture
opens up.

## Direction A — Kapranov's hard direction, univariate seed

Conjecture: if `K` is algebraically closed with a non-trivial *divisible*-value-group valuation
`v`, then for every `w` on the corner locus of `trop(f)` there is `p` with `f(p) = 0` and
`v(p) = w`. Start with `Fin 1` variables, where the Newton polygon is the lower convex hull of
`{(i, v(cᵢ))}`.

The key insight is that the easy direction proven here is purely the *equality* half of the
ultrametric inequality (`addValuation_add_eq_min_of_ne` is exactly that equality), so the hard
direction is precisely the *failure* of that equality to be one-directional: a genuine lift is
needed, supplied by Hensel's lemma applied at each Newton-polygon edge slope. The univariate case
reduces the whole theorem to "Hensel + convex hull".

Why now? Mathlib has Hensel's lemma and `Polynomial.Monic`; the only missing glue is a
Newton-polygon predicate, a finite-combinatorial object of exactly the flavour of the already
proven `inf'_product_add`/`range_exp_mul` lemmas.

## Direction B — Balancing as the completeness of the minimizer fan

Conjecture: at every corner `x` of `V(P)`, the primitive edge directions weighted by lattice
length sum to zero. The tie set produced by `kapranov_easy_direction` / `attainedTwice_fin2_iff`
is the vertex set of a polytope whose outward normal fan is complete; balancing is exactly that
completeness.

The key insight is that the *same* tie set that certifies membership in the corner locus already
carries the balancing data: `addValuation_defect_imp_corner` extracts ≥ 2 minimizers, and
generalizing its conclusion from "≥ 2 minimizers" to "the minimizer set spans a complete fan" is
the natural strengthening — no new geometric input, only the convex-geometry API.

Why now? With `attainedTwice_fin2_iff` characterizing the binary corner exactly, the `n`-ary
generalization (the minimizer Finset and its convex hull) is now a clean inductive target, and
Mathlib's `Finset` convex-geometry API can already state primitive lattice vectors.

## Direction C — The defect is a `RingHom`-obstruction class, not just a set

Conjecture: package the additive defect `δ(x,y) := untrop (tropVal v (x+y)) - untrop (tropVal v x
+ tropVal v y) ≥ 0` and show `δ` is a *symmetric, `v`-translation-equivariant 2-cocycle* whose
support is exactly the tie set; equivalently, `tropVal v` is a `RingHom` into the tropical
semiring *if and only if* `Γ` is trivial.

The key insight is that this cycle proved `tropVal` is a `MonoidHom` but *provably not* an
`AddHom` (the failure-analysis note: `x + (-x) = 0` forces `v 0 = ⊤ ≠ v x`). Measuring exactly
*how much* additivity fails turns the qualitative "defect ⊆ tie set" into a quantitative cocycle,
the tropical analogue of a ramification/different invariant.

Why now? `addValuation_add_eq_min_of_ne` already gives `δ = 0` off the tie set, so `δ` is
supported on `{v x = v y}`; the only remaining work is proving the cocycle identity, a direct
`grind`-style computation on the four valuations involved.

## Direction D — Functoriality: pullback of `tropValMonoidHom` along field extensions

Conjecture: for a finite extension `L/K` with valuation `w` extending `v` (ramification index
`e`), the square relating `tropValMonoidHom w` and `tropValMonoidHom v` commutes up to the scaling
`× e`, realizing `attainedTwice_smul`'s positive rescaling as a *functorial* (not merely
analytic) operation on the tropical semiring.

The key insight is that `attainedTwice_smul` already proved the corner locus is invariant under
positive rescaling; ramification supplies the *canonical* scale `e`, so the "valuation → ∞" family
of Direction 2 is reinterpreted as the tower of finite extensions, with `tropValMonoidHom` the
natural transformation between them.

Why now? `tropValMonoidHom` is a bundled `MonoidHom`, so "commuting square" is a literal
`MonoidHom` equation; Mathlib's `Valuation.IsExtension`/extension API supplies the comparison `w ∘
algebraMap = e • v`, making the diagram checkable by `ext` + the scale lemma.
