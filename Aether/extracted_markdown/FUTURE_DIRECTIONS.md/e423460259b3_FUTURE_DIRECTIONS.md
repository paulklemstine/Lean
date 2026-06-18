# Future Directions: Functorial Tropical Valuation from Rips Edge-Count Filtrations

These conjectures extend the results formalized in
`Bridges/RipsEdgeCountTropical.lean`, which bridges the Rips graph filtration of
`Applications/PoincareData/MetricFiltration.lean` with the tropical valuation
machinery of `Bridges/CategoricalTropicalUltrametric.lean`.

Established facts (this cycle):

* `tropicalScaleSemiring` : `WithBot ℝ` is a `TropicalValuationObject` (max, +).
* `edgeCount_monotone`, `edgeCount_max` : edge-count is a monotone, `max`-preserving
  (tropical-additive) map `ℝ → ℕ`.
* `edgeCountExt_add`, `edgeCountExt_zero` : edge-count is an additive (max-monoid)
  morphism into `tropicalization_base`.
* `edgeCount_isometry_le`, `edgeCount_isometry_eq` : edge-count is a lax functor in the
  space (monotone under isometric embeddings, invariant under isometries).
* Failure analysis: edge-count is **not** a full `TropHom` because it does not preserve
  the multiplicative unit (`edgeCount α 0 = 0 ≠ 1`).

---

## D1. Strict-growth / jump characterization (testable)

**Conjecture.** For a finite metric space `α`, the edge-count function `edgeCount α`
is a right-continuous step function whose set of jump points is exactly the set of
distinct pairwise distances `{ dist x y | x ≠ y }`, and the total jump (i.e.
`edgeCount α (diam) − edgeCount α 0`) equals `card α * (card α − 1)`.

*Why bold/testable:* gives an exact bijection between "tropical critical scales" and
the multiset of pairwise distances, refining `edgeCount_saturate`. Formalize the jump
set and prove `edgeCount` is locally constant off it.

## D2. Multiplicative refinement: a true `TropHom` via birth-time products

**Conjecture.** Replacing the *count* by the *tropical product of edge birth-times*
yields a genuine `TropHom` of the catalog's tropical *ring* objects. Concretely, define
`birthVal α : WithBot ℝ → WithBot ℝ` summing (tropically: `+`) the birth scales of all
edges present at scale `ε`; then `birthVal` preserves both tropical `add = max` and
tropical `mul = (+)`, repairing the multiplicative-unit failure documented in the lab
notes (H3 REFUTED).

*Why bold/testable:* directly attacks the one obstruction we found, and would upgrade
`ScaleTropicalValuation` to a morphism in the full tropical category of
`CategoricalTropicalUltrametric`.

## D3. Edge-count interleaving stability (TDA bridge)

**Conjecture.** If two finite metric spaces on the same carrier satisfy
`|dist₁ x y − dist₂ x y| ≤ δ` for all `x,y`, then their edge-count functions are
`δ`-interleaved: `edgeCount₁ α ε ≤ edgeCount₂ α (ε+δ)` and symmetrically. Hence
edge-count is `1`-Lipschitz as a map from the Gromov–Hausdorff-style perturbation to the
sup-distance of step functions.

*Why bold/testable:* this is the persistence-stability theorem at the π₀/edge level and
ties the tropical valuation to `MetricFiltration`'s perturbation theorems
(`sphere_perturbation_stability`).

## D4. Two-variable (bi)functoriality and a Galois connection

**Conjecture.** The assignment `(α, ε) ↦ edgeCount α ε` is a bifunctor
`(FinPMet^iso)ᵒᵖ-free × (ℝ,≤) → (ℕ,≤)` that is *separately* tropical in `ε`
(`edgeCount_max`) and monotone in `α` (`edgeCount_isometry_le`); moreover the maps
`ε ↦ edgeCount α ε` and `n ↦ inf{ε | edgeCount α ε ≥ n}` form a Galois connection between
`(ℝ,≤)` and `(ℕ,≤)`.

*Why bold/testable:* a Galois connection would give an adjunction-style "tropical
duality" between scales and edge-budgets, connecting to the covering/packing duality
(`maximal_packing_is_cover`).

## D5. Spectral/threshold conjecture: connectivity vs. edge-count

**Conjecture.** There is an explicit monotone threshold `ε*` (the Rips connectivity
scale) such that `edgeCount α ε ≥ card α − 1` for all `ε ≥ ε*`, and `ε*` equals the
maximum edge weight of a minimum spanning tree of `α`. Equivalently, the first scale at
which the tropical valuation reaches the "spanning budget" `card α − 1` is the MST
bottleneck.

*Why bold/testable:* converts the abstract edge-count valuation into the classical MST
bottleneck, linking tropical valuation theory to single-linkage clustering and the
`completeGraph_connected` threshold theme of `MetricFiltration.lean`.
