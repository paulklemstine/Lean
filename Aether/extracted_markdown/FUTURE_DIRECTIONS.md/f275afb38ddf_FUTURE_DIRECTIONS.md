# Future Directions — Functorial tropical valuation profiles via coefficient-support truncation

This cycle added `Catalog/Applications/SpeciesTropicalTruncation.lean`, building on
`SpeciesTropicalProfile.lean` (the `ord`/`deg` tropical valuation profile and its exact
additivity under the Cauchy convolution `cconv`) and the species/EGF dictionary in
`CombinatorialSpecies.lean`.

We established that **coefficient-support truncation** `trunc N f = f|_{<N}` is:
- an idempotent `ℚ`-linear projection (`trunc_add`, `trunc_smul`, `trunc_idem`,
  `trunc_trunc_of_le`);
- **functorial for convolution** — it descends to the truncated quotient `ℚ[X]/(X^N)`:
  `trunc N (cconv f g) = trunc N (cconv (trunc N f) (trunc N g))` (`trunc_cconv`);
- transparent to the tropical valuation profile: it only raises the order
  (`ord_le_ord_trunc`), preserves it inside the window (`ord_trunc_of_lt`), forces the
  degree strictly below the cutoff (`deg_trunc_lt`), and makes the valuation of a
  convolution visible inside any window that contains it (`ord_trunc_cconv`);
- compatible with the binomial/exponential convolution `binConv` of species
  (`binConv_trunc_agree`).

The following conjectures are precise, falsifiable, and each is a natural next Lean target.

## Conjecture 1 — Truncation is a `RingHom` onto the truncated convolution quotient
Equip the image `{trunc N f : f : ℕ →₀ ℚ}` with `+` and the truncated product
`f ⊛_N g := trunc N (cconv f g)`. Conjecture: this is a commutative ring with unit
`trunc N (single 0 1)`, and `f ↦ trunc N f` is a surjective ring homomorphism from the
exponential-convolution ring of `SpeciesConvolutionRing.lean` (after transporting
`binConv` ↔ `cconv`). Concretely: `trunc N (cconv (cconv f g) h) = trunc N (cconv f (cconv g h))`
and `trunc N` commutes with `binConvPow`. **Test:** prove associativity of `⊛_N` and
`(trunc N) (binConvPow a k) = (⊛_N)`-power, using `trunc_cconv` + `binConv_assoc`.

## Conjecture 2 — Tropical profile is a graded/filtered monoid morphism
The map `profile f = (ord f, deg f) : WithTop ℕ × WithBot ℕ` sends `cconv` to coordinatewise
addition exactly (already: `ord_cconv`, `deg_cconv`). Conjecture: it is a *strict* morphism
of ordered monoids and detects the filtration: `f ∈ ker(trunc N)` (i.e. `trunc N f = 0`)
iff `ord f ≥ N`, and `deg (trunc N f) = min (deg f) (N-1)` whenever `ord f < N`. **Test:**
formalize `ker_trunc_iff : trunc N f = 0 ↔ N ≤ ord f` and the `deg`-window equality.

## Conjecture 3 — Truncation commutes with the species derivative/pointing operators
With the differential calculus of species (`Species.derivative`, `Species.pointed`,
`egf_derivative`, `egf_pointing`), conjecture the *shift–truncation* intertwiners at the
sequence level: `trunc N ((shift) f) = (shift) (trunc (N+1) f)` where `shift a n = a (n+1)`,
and the Euler-operator analogue `trunc N (n ↦ n • a n) = (n ↦ n • (trunc N a) n)`. This
makes `trunc` a natural transformation compatible with `d/dX` and `X·d/dX` modulo a shift of
the window. **Test:** prove the two intertwining identities and deduce
`trunc (N) ∘ derivative = derivative ∘ trunc (N+1)` on counting sequences.

## Conjecture 4 — Valuation-Lipschitz / ultrametric bridge for truncation distance
Define `dist_T f g = 2 ^ (-(ord (f - g)).toNat)` (with `dist_T f f = 0`). Conjecture this is
a genuine **ultrametric** on `ℕ →₀ ℚ`: `dist_T f h ≤ max (dist_T f g) (dist_T g h)`, with
truncation `trunc N` a `1`-Lipschitz idempotent and `dist_T (trunc N f) f ≤ 2^{-N}`. This
links the tropical valuation profile to the ultrametric world of
`Bridges/CategoricalTropicalUltrametric.lean`. **Test:** prove the strong triangle
inequality from `min (ord f) (ord g) ≤ ord (f+g)` (`ord_add_ge`) and the contraction bound.

## Conjecture 5 — Truncated EGF and convergence of the species dictionary
Let `truncSeq N a` be the function-level truncation. Conjecture that the partial EGFs
`egf (truncSeq N a)` converge coefficientwise to `egf a` (each fixed coefficient is exact for
`N` large), and that `egf (truncSeq N a)` equals the `ℚ⟦X⟧`-image of `PowerSeries.trunc N`
applied to `egf a`. **Test:** prove `∀ k, k < N → coeff k (egf (truncSeq N a)) = coeff k (egf a)`
and identify `egf (truncSeq N a)` with `↑(PowerSeries.trunc N (egf a))`.
