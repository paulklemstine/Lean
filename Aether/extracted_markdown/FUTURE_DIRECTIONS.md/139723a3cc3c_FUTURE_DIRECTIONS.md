# Future Directions — Species Generating Functions ↔ Tropical Valuation Profiles

These conjectures extend the functorial bridge established in
`Bridges/SpeciesTropicalValuation.lean`, which sends a combinatorial species `F` to its
**tropical valuation profile** `tropOrder F = order(F.EGF) ∈ ℕ∞` and proves:

* `tropOrder (F · G) = tropOrder F + tropOrder G` (Day-convolution product ↦ tropical ×);
* `min (tropOrder F) (tropOrder G) ≤ tropOrder (F + G)` (disjoint union ↦ tropical +);
* `tropChar` is a monoid homomorphism into `Tropical (WithTop ℕ)`.

Each direction below is stated as a precise, falsifiable Lean target.

---

## C1. The Newton-polygon profile is a tropical-multiplicative invariant

The scalar `tropOrder` only records the *leading* valuation. Upgrade it to the full
**Newton polygon**: the lower convex hull of `{(n, v(aₙ))}`. With `v = `p-adic valuation, or
the trivial order valuation, conjecture that the Newton polygon of a product species equals the
**inf-convolution (Minkowski sum)** of the factor polygons.

> **Conjecture.** For counting sequences `a, b : ℕ → ℚ`,
> `NewtonPolygon (binConv a b) = infConvolution (NewtonPolygon a) (NewtonPolygon b)`,
> i.e. the slopes of the product are the multiset union of the slopes of the factors.

Testable first step: prove the leftmost slope equals `tropOrder a + tropOrder b`
(already a corollary of `tropOrder_mul`) and the rightmost behaviour for finitely-supported `a`.

## C2. Differential calculus of species shifts the valuation profile

Joyal's derivative species satisfies `F′[n] = F[n+1]`, so its EGF is the formal derivative.

> **Conjecture (derivative drop).** If `tropOrder F = k + 1` (with `k : ℕ`) then
> `tropOrder F.derivative = k`; and `tropOrder F.pointed = tropOrder F` whenever `tropOrder F ≥ 1`
> (pointing multiplies the `n`-th term by `n`, killing the constant term but preserving the leading
> order otherwise).

This connects the tropical valuation profile to the *Euler operator* `X·d/dX` already formalized
in `Applications/CombinatorialSpecies.lean`.

## C3. The EGF transform is a valued ring isomorphism

`egf_bijective` shows `egf : (ℕ → ℚ) ≃ ℚ⟦X⟧`. Equip the domain with `(+, binConv)`.

> **Conjecture.** `egf` is a ring isomorphism `(ℕ → ℚ, +, binConv) ≃+* ℚ⟦X⟧`, and `tropOrder`
> is the *unique* non-archimedean valuation `v` on the domain with `v(binUnit) = 0` and
> `v(X-generator) = 1`, where the `X`-generator is the sequence `δ₁` with `δ₁ 1 = 1`, else `0`.

Proving associativity/distributivity of `binConv` directly is the missing ingredient; the bijection
transports it for free, giving the first fully-formal "species ring".

## C4. p-adic valuation profiles and ultrametric depth classes

Replace `order` by the coefficientwise p-adic valuation, connecting to
`Computation/PadicValuationDepth.lean`.

> **Conjecture.** For a fixed prime `p`, the map `a ↦ (n ↦ v_p(aₙ))` is sub-multiplicative under
> `binConv`: `v_p((binConv a b)ₙ) ≥ minᵢ₊ⱼ₌ₙ (v_p(C(n,i)) + v_p(aᵢ) + v_p(bⱼ))`, with the binomial
> term governed by Kummer's theorem (carries of `i + j` in base `p`). Equality holds on the Newton
> polygon's vertices.

This realises the "carry-free" ultrametric intuition of `PadicValuationDepth` at the level of
species enumeration.

## C5. A strict valuation-depth hierarchy of species

Let `VALₖ` be the set of species with `tropOrder ≥ k` (minimal structure size `≥ k`). By
`tropOrder_mul`, `VALⱼ · VALₖ ⊆ VAL_{j+k}`, so the `VALₖ` form a multiplicative filtration.

> **Conjecture.** The filtration `{VALₖ}` is *strict* at every level (`VAL_{k+1} ⊊ VALₖ`), with
> explicit witnesses (e.g. the species `Xᵏ` "structures of size exactly `k`"), giving a
> `StratifiedComputation`-style strict hierarchy (cf. `PadicValuationDepth`'s `DepthWitness`) whose
> grading is exactly the tropical valuation profile.
