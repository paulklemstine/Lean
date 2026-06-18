# Future Directions — Species growth ↝ tropical generating-function valuations

This cycle built the missing Applications↝Bridges link between the combinatorial-species /
EGF machinery (`Catalog/Applications/CombinatorialSpecies.lean`) and the tropical valuation
infrastructure (`Catalog/Bridges/CategoricalTropicalUltrametric.lean`).  We sent each integer
counting sequence to its coefficientwise valuation profile `n ↦ v(aₙ) ∈ ℕ∞` and proved that

* disjoint sum ↝ pointwise tropical minimum (`profile_add_ge`, with calibrated equality
  off the collision locus `profile_add_eq_of_ne`),
* structural Day-product ↝ tropical convolution (`profile_binConv_ge`,
  `profile_prodSpecies_ge`),
* the linear-order species ↝ the exact calibration `profile_linearOrder`, which under the
  genuine `p`-adic model `padicCoeffValuation` becomes `emultiplicity p (n!)`
  (`profile_linearOrder_padic`),
* the profiles form a commutative, unital, distributive min-plus algebra
  (`tropConv_comm`, `tropConv_tropUnit_left/right`, `tropConv_min_distrib_left/right`),
* and a concrete `2`-adic case where the product bound is *strict*
  (`profile_binConv_strict_example`), certifying the laws are genuine bounds.

The following conjectures are the natural next falsifiable targets.

## 1. The carry-free equality criterion for the product bound

**Conjecture.** `profile_binConv_ge` holds with *equality* at `n` if and only if there is a
split `i + j = n` minimizing `v(aᵢ) + v(bⱼ)` for which (a) the minimizer is unique among all
splits (no tropical collision) and (b) the binomial prefactor is a `v`-unit, `v(C(n,i)) = 0`.

**The key insight is** that exactly two mechanisms can make the inequality strict — additive
collisions (handled by the isosceles law `v_add_eq_of_ne`) and the nonnegative multiplicative
contribution of the binomial coefficient `v(C(n,i))` — and the `2`-adic example
`profile_binConv_strict_example` realizes the second mechanism in isolation.

**Why now?** Both ingredients are already formalized: `v_add_eq_of_ne` controls collisions and
`profile_binConv_ge`'s proof pinpoints the `v(C(n,i))` term, so the criterion is a direct
refinement rather than new infrastructure.

## 2. The valuation profile is a min-plus semiring homomorphism

**Conjecture.** The map sending an integer counting sequence to its profile is a homomorphism
of idempotent semirings from `(ℕ → ℤ, pointwise +, binConvInt)` to
`(ℕ → ℕ∞, pointwise min, tropConv)` *after lax-to-strict correction on the carry-free
locus*; i.e. it is lax in general (the two bound theorems) and strict exactly where the
criterion of Direction 1 holds.

**The key insight is** that `tropConv_comm`, the `tropUnit` laws, and
`tropConv_min_distrib_left/right` already supply every semiring axiom on the target except
associativity of `tropConv`, so the homomorphism statement — not the algebra — is the real
remaining content.

**Why now?** `SpeciesTropicalProfileAlgebra.lean` closes the algebraic laws this cycle, and
`profile_add_ge` / `profile_binConv_ge` are precisely the lax homomorphism inequalities.

## 3. The Legendre profile is a prime fingerprint

**Conjecture.** For the `p`-adic model, the linear-order profile
`n ↦ emultiplicity p (n!) = (n − sₚ(n))/(p−1)` (with `sₚ` the base-`p` digit sum) determines
`p` uniquely; moreover an integer sequence `c` is the profile of *some* species' EGF under
*some* `p`-adic valuation only if its successive differences `c(n+1) − c(n)` are themselves
`p`-adic valuations of integers.

**The key insight is** that `profile_linearOrder_padic` already identifies the calibration
with `emultiplicity p (n!)`, whose Legendre closed form is strictly increasing in a
digit-controlled way, making the profile an injective invariant of `p`.

**Why now?** The exact calibration and its recurrence `profile_linearOrder_succ` are proved,
so the difference sequence is directly available for the divisibility characterization.

## 4. Tropical shadows of the species differential calculus

**Conjecture.** The catalog's species derivative `F′` and pointing `F•`
(`EGF_derivativeSpecies`, `EGF_pointedSpecies`) tropicalize: the profile of `F′` is the shift
`n ↦ profile(F)(n+1)`, and the profile of `F•` equals `profile(F)` pointwise away from `0`,
with `tropConv` against a "pointing kernel" reproducing the Euler operator `X·d/dX`
coefficientwise.

**The key insight is** that the EGF differential operators act on *coefficients* by an
index shift and an index multiplication, and under a valuation an index shift becomes a
profile shift while index multiplication by an integer only *adds* `v(n)` — a tropical, not
analytic, derivative.

**Why now?** `CombinatorialSpecies.lean` already proves the analytic differential dictionary
and this cycle defines `profile`/`tropConv`, so the tropical operators are one definitional
step from being stated and tested.

## 5. Functorial complexity certificates for ResNet/tropical pipelines

**Conjecture.** Composing the profile map with the catalog's `speciesMinPlusTrop`
`TropicalValuationObject` and the `CategoricalTropicalUltrametric` reconstruction functor
yields, for every species built from sum/product/derivative, an ultrametric Lipschitz
certificate whose constant is the maximal profile slope `sup_n (profile(n+1) − profile(n))`.

**The key insight is** that `speciesMinPlusTrop` places profiles inside the *same* tropical
object the reconstruction functor consumes, so combinatorial growth data flows directly into
certified-robustness constants without leaving the formalized pipeline.

**Why now?** `speciesMinPlusTrop` is proved this cycle to satisfy the catalog's tropical
axioms verbatim, and the reconstruction functor (`valuationReconstruct`, with functoriality
`valuationReconstruct_map_comp`) already exists, so only the composite needs assembling.
