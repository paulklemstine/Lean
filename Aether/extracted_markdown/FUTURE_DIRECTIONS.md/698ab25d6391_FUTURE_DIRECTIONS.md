# Future Directions — Topological code overlap profiles as tropical valuation objects

Derived from the cycle that produced
`Catalog/Applications/SmoothPoincare/OverlapIntersectionForm.lean`,
`Catalog/Applications/SmoothPoincare/TropicalOverlapProfile.lean`, and
`Catalog/Bridges/OverlapTropicalValuation.lean`.

This cycle isolated the **off-diagonal correlation** `corr C = max_{x≠y∈C} overlap x y`
as the genuinely pairwise, geometric-interaction invariant of a binary code (the mod-2
shadow of the lattice intersection form), proved it obeys a **max-convolution**
`corr (C ⊕ D) = max (maxWt C + corr D) (corr C + maxWt D)`, and packaged that law as a
degree-1 tropical (max, +) polynomial in the new valuation object `maxPlusAddObj`. The
following conjectures push on the boundaries discovered along the way.

## Conjecture 1 — Correlation lower-bounds the covering radius

For a self-dual doubly-even code `C` of length `n`, the covering radius `ρ(C)` satisfies
`ρ(C) ≥ maxWt C − corr C`.

The key insight is that two distinct codewords whose overlap realizes `corr C` have
symmetric difference of weight `≥ maxWt C − corr C` concentrated where exactly one is
supported, so the deepest hole between them is bounded below by the *gap* between the
weight envelope and the correlation — precisely the quantity `maxWt − corr` that this
cycle showed is `8 − 4 = 4` for the extended Hamming code.

Why now? We now have `corr` and `maxWt` as first-class, computable invariants with
proven direct-sum laws (`corr_append`, `maxWt_append`), so the inequality can be tested
on `hamming`, `hamming ⊕ hamming`, and the family `hamming^{⊕k}` and then attacked in
general via the convolution laws.

## Conjecture 2 — The correlation gap is super-additive under code sum

Define the **interaction gap** `gap C = maxWt C − corr C`. Then
`gap (C ⊕ D) = min (gap C, gap D)` — the gap tropicalizes as a *min*, dual to the way
`corr` tropicalizes as a max-convolution.

The key insight is that `corr_append` says the diagonal of the larger-weight block wins,
so `maxWt(C⊕D) − corr(C⊕D) = (maxWt C + maxWt D) − max(maxWt C + corr D, corr C + maxWt D)
= min(maxWt D − corr D, maxWt C − corr C)`, an exact algebraic identity, not a bound.

Why now? Both `maxWt_append` and `corr_append` are proved `sorry`-free in this cycle, so
this identity is a short corollary to formalize next, and it would make `gap` a genuine
min-plus valuation in `minPlusTropObj` — closing the loop between the two objects built
here.

## Conjecture 3 — A MacWilliams-type duality for the overlap correlation

For a binary linear code `C` and its dual `C⊥`, the correlations are linked by
`corr C + corr C⊥ ≥ n − 1` whenever both are nondegenerate (length `≥ 2`, dimension
strictly between `0` and `n`).

The key insight is that the overlap form is the mod-2 reduction of the intersection
pairing, and self-duality forces `overlap x y` to be even for distinct codewords (a
consequence of `doublyEven_selfOrthogonal`); the dual code's correlation must then
compensate, mirroring how the classical MacWilliams identity ties a code's weight
enumerator to its dual's.

Why now? The bridge theorem `doublyEven_selfOrthogonal` and the self-dual machinery
(`hamming_selfDual`, `selfDual_even_weight`) are already in the catalog, and this cycle
adds the `corr` invariant they were missing, so the two halves can finally be combined.

## Conjecture 4 — Tropical profiles separate inequivalent codes that weight enumerators cannot

There exist two binary codes `C₁, C₂` with identical Hamming weight enumerators (a
*formal duality pair*) but distinct correlation profiles `corr C₁ ≠ corr C₂`; hence the
tropical overlap profile is a strictly stronger invariant than the (tropical or
classical) weight enumerator.

The key insight is that this cycle already exhibited the *intra-code* version of this
phenomenon — `corr hamming = 4 ≠ 8 = maxWt hamming`, with the weight-4 stratum invisible
to the convex-hull envelope `twe` — so the same off-diagonal information that `corr`
records but `twe` discards should distinguish weight-equivalent but inequivalent codes.

Why now? The catalog contains both the tropical weight enumerator (`twe`, `twePlus`) and,
as of this cycle, the tropical overlap profile (`tov`, `tovPlus`, `corr`); a head-to-head
comparison on a small isospectral pair is now a finite, decidable experiment.

## Conjecture 5 — Functoriality of the profile under all monomial code morphisms

The correlation profile extends to a functor on the category of binary codes with
*monomial* morphisms (coordinate permutations and complementations), and the assignment
`C ↦ ((maxWt C : WithBot ℕ), (corr C : WithBot ℕ))` is a morphism of tropical valuation
objects into `maxPlusAddObj × maxPlusAddObj`, natural in `C`.

The key insight is that `overlap` is invariant under simultaneous coordinate permutation
of its two arguments, so `corr` and `maxWt` are monomial invariants, and the direct-sum
laws proven here are exactly the statement that this assignment respects the monoidal
(`⊕`) structure — promoting the present *object-level* packaging to a *functor*.

Why now? The Bridges file already provides `TropHom` and the categorical scaffolding
(`TropHom.comp`, identity, associativity), and this cycle supplies the object-level laws;
the remaining work is to define the morphism action and check naturality, a concrete
next deliverable rather than an open-ended search.
