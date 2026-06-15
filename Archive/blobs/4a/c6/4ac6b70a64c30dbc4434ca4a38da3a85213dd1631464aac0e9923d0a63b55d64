# Future Directions — Species GF ↔ Tropical Valuation Profiles

This cycle established a **lax monoidal functor** from the generating-function algebra of
combinatorial species `(ℕ → K, +, ⋆)` (where `⋆ = binConv` is the binomial/Day-convolution
product) to the **min-plus (tropical) semiring** of valuation profiles `(ℕ → WithTop ℤ, min, +)`,
via an additive Krull valuation applied coefficient-wise.

* `vprofile_add_ge` — sum ↦ coefficient-wise `min` (ultrametric).
* `vprofile_binConv_ge` — product ↦ min-plus convolution `tropConv` (lax, ≤).
* `padicAddVal` — the `p`-adic concrete instance (tie-in to `PadicValuationDepth`).

The following conjectures are precise, falsifiable, and target the gap between the **lax** bridge
proved here and an **exact** tropical correspondence.

---

## Conjecture 1 (Tropical transversality ⇒ equality in the product law)

The product law `vprofile_binConv_ge` is `≤`. **Conjecture:** equality
`tropConv (vprofile V a) (vprofile V b) n = vprofile V (binConv a b) n`
holds whenever the antidiagonal infimum `inf_{i+j=n} (v(aᵢ)+v(bⱼ))` is attained at a **unique**
pair `(i,j)` with `v(C(n,i)) = 0` (i.e. `p ∤ C(n,i)` in the p-adic model). This is the
"tropically transverse / no-cancellation" regime. Testable: it predicts equality of p-adic
valuations of `binConv` coefficients exactly when Kummer's theorem gives a carry-free binomial
coefficient and the minimizing decomposition is unique.

## Conjecture 2 (Newton polygon = tropicalized profile is convex under products)

Define the **Newton profile** `N a : ℕ → WithTop ℤ` as the lower convex hull of `n ↦ v(aₙ)`.
**Conjecture:** `N (binConv a b) = ` the inf-convolution of `N a` and `N b` (Minkowski sum of the
two Newton polygons), with *equality* (not just ≤). This is the species-level Newton-polygon
additivity theorem and would upgrade the lax functor to a strict one after passing to convex
hulls.

## Conjecture 3 (Derivative/pointing operators are tropically Lipschitz)

`CombinatorialSpecies` proves `EGF F′ = (EGF F)′` (derivative species) and
`EGF F• = X·(EGF F)′` (pointed species). **Conjecture:** the corresponding valuation profiles
satisfy `vprofile V (shift a) n = vprofile V a (n+1)` exactly, and the pointing operator
`a ↦ (n·aₙ)` satisfies `vprofile V (point a) n ≥ vprofile V a n` with equality iff `v(n) = 0`
(i.e. `p ∤ n`). I.e. the tropical derivative is a 1-shift and pointing is non-decreasing on
profiles, witnessing Joyal's differential calculus tropically.

## Conjecture 4 (Composition / substitution becomes tropical composition)

Species support a substitution `(F ∘ G)` with EGF `F(EGF G)`. **Conjecture:** there is a
tropical analogue: `vprofile V (subst a b)` is bounded below by a min-plus "composition"
`inf` over set-partitions, and for the `p`-adic valuation this lower bound is governed by the
valuations of the multinomial coefficients (a multivariate Kummer phenomenon). Formalizing
`subst` and proving the lax composition law is the natural next building block.

## Conjecture 5 (Exactness for valuations trivial on ℕ ⇒ characterization)

`v_natCast_nonneg` (multiplicities have valuation ≥ 0) is the *only* obstruction to exactness in
the product law. **Conjecture:** for a valuation `V` with `v(n) = 0` for all `n ≥ 1` (e.g. a
valuation trivial on the prime field, or any `p`-adic valuation restricted to `binConv` of
integer sequences supported away from `p`-divisible multiplicities), the product law holds with
equality `tropConv = vprofile ∘ binConv` exactly. This isolates the precise algebraic condition
turning the lax bridge into an isomorphism of min-plus modules.
