# Future directions

These directions all build on the order valuation `ordEGF` introduced in
`Catalog/Bridges/SpeciesTropicalValuation.lean` and the species ↔ EGF dictionary of
`Catalog/Applications/CombinatorialSpecies.lean`.

## 1. Exact (not merely subadditive) tropical addition law

The current `ordEGF_add_min_le` is an inequality, but for disjoint unions of species the counting
sequences are non-negative, so the leading terms can never cancel and equality should in fact hold:
`ordEGF (F.add G) = min (ordEGF F) (ordEGF G)`. The key insight is that the order of a power series
with *non-negative* rational coefficients is determined by its earliest non-zero coefficient, and
the coefficient-wise minimum of two non-negative supports cannot vanish, so the generic-cancellation
escape hatch in `min_order_le_order_add` is closed in this combinatorial regime. Why now? Because we
already have `EGF_add` reducing the species statement to a pure power-series statement, and the only
missing piece is a small Mathlib-level lemma about `order` of sums under a positivity hypothesis,
which is squarely within reach of the existing `order_le` / `nat_le_order` API.

## 2. Packaging `ordEGF` as a tropical semiring homomorphism

Rather than stating the multiplication and addition laws as separate theorems, one can package a
genuine product species `Species.mul` (with its Day-convolution action) and prove that
`ordEGF : (Species, ⊕, ⊗) → (ℕ∞, min, +)` is a semiring-style homomorphism object. The key insight
is that all the *enumerative* content is already finished — `egf_card_prodSpecies` and `EGF_add`
reduce everything to `order_mul` and `min_order_le_order_add` — so the remaining work is purely the
categorical bookkeeping of the relabelling action on `Σ S ⊆ [n], A[|S|] × B[n∖S]`. Why now? Because
the valuation laws are already verified at the EGF level, the homomorphism packaging cannot fail for
mathematical reasons; it is a structuring task that immediately upgrades the bridge into a reusable
interface for downstream tropical arguments.

## 3. Composition of species and the valuation of substitution

Joyal's substitution `F ∘ G` (structures of `F` on the blocks of a `G`-partition) has EGF given by
functional composition of EGFs when `G` has no constant term. The key insight is that the order
valuation of a composite is *multiplicative-then-additive*: `ord(F ∘ G)` is governed by the smallest
`F`-degree times the order of `G`, mirroring the chain rule for tropical valuations of substituted
power series. Why now? Because the file already formalizes the derivative and pointed species
(`EGF_derivativeSpecies`, `EGF_pointedSpecies`), the differential-calculus infrastructure needed to
control composition's lowest-order behaviour is in place, and only the composition counting law
(set-partition refinement of `card_prodSpecies`) must be added.

## 4. Lifting from `ℕ∞`-orders to a full tropical/Newton-polygon invariant

The order is only the first vertex of the Newton polygon of the EGF; recording the whole support (or
the convex lower hull of `(n, v(coeffSeq n))` for a coefficient valuation `v`) yields a finer
tropical invariant of a species. The key insight is that the additive `min` and multiplicative `+`
laws for the *order* are the degree-zero shadow of a Minkowski-sum law for Newton polygons, so the
single-number bridge proved here is the base case of a polygon-valued functor. Why now? Because the
order-level laws are settled and serve as a correctness oracle: any polygon-valued refinement must
restrict to `ordEGF_structProd` and `ordEGF_add_min_le` on its lowest vertex, giving an immediate
regression check while the richer invariant is developed.

## 5. p-adic and multivariate valuations of species generating functions

Replacing the order at `X = 0` by a `p`-adic valuation of the coefficients, or by the order of a
*multivariate* (weighted) generating function, would connect the species bridge to the existing
`Catalog/Pythagorean/PadicOrbitalValuation.lean` and `Catalog/Tropical` material. The key insight is
that every reasonable valuation on `ℚ` (archimedean order, `p`-adic, or a tropical weight on several
variables) turns the same `egf_mul` / `egf_add` identities into the same pair of tropical laws, so
the proof skeleton of this file is valuation-agnostic. Why now? Because the project already contains
both a `p`-adic valuation development and a large tropical catalog, and unifying them through the
species EGF would reuse existing verified components rather than building new theory from scratch.
