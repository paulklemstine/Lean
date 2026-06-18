# Future Directions — Rips Filtration as a Functorial Image of Tropical Valuation Objects

These conjectures extend `Bridges/RipsTropicalFunctor.lean`, which builds the functor

> tropical valuation carrier  ⟶  ultrametric distance  ⟶  Rips-graph filtration

and proves its central qualitative consequence: in the non-archimedean world, Rips
adjacency is transitive up to equality, so connected components are exactly closed balls
(`tropRips_reachable_iff`), every triangle is isosceles (`tropDist_isosceles`), and the
component partitions are nested (`tropRips_reachable_mono`). Each direction below is stated
so that it can be turned directly into a Lean theorem skeleton in a follow-up cycle.

---

## Conjecture 1 — The component functor is a true dendrogram (full single-linkage equivalence)

**Statement.** For a `ValuationMetricCarrier X`, the map
`ε ↦ (Setoid from (tropRipsGraph X ε).Reachable)` is a monotone family of equivalence
relations on `X.K` whose value at scale `ε` is exactly the closed-`ε`-ball partition, and
the join over all `ε ≥ 0` is the indiscrete relation iff `X` has finite valuation diameter.

**Testable form.** Prove `tropRips_components_eq_ballSetoid : ε ≥ 0 → (the Reachable Setoid at
ε) = (ballSetoid X ε)` and `iSup_components_top_iff_bounded`. The first follows from
`tropRips_reachable_iff`; the second isolates the boundedness hypothesis used in
`tropRipsGraph_eq_top`.

**Why bold.** Asserts that the entire persistence module of an ultrametric point cloud is a
*dendrogram* (a tree), recovering the classical Carlsson–Mémoli theorem as a corollary of the
tropical functor — with zero homology computation, purely from `tropDist_strong_triangle`.

---

## Conjecture 2 — Functorial collapse: ultrametric Rips persistence has no H₁

**Statement.** For every scale `ε`, each connected component of `tropRipsGraph X ε` is a
**clique** (complete subgraph). Consequently the clique (flag) complex of the ultrametric Rips
graph is a disjoint union of simplices, hence contractible on each component, so the Vietoris–
Rips complex has trivial reduced homology in all degrees ≥ 1 at every scale.

**Testable form.** Prove `tropRips_component_isClique : (tropRipsGraph X ε).Reachable x y → x ≠ y
→ (tropRipsGraph X ε).Adj x y` (immediate from `tropRips_reachable_iff`), then
`tropRips_cliqueComplex_eq_simplices`.

**Why bold.** Predicts that *all* topological persistence of non-archimedean data lives in
H₀ (the dendrogram); H₁ and higher are identically zero. This is a sharp falsifiable
dividing line between archimedean and non-archimedean TDA.

---

## Conjecture 3 — Lipschitz scale-shift is the unique obstruction to isometric functoriality

**Statement.** A `ValMetricHom f : X ⟶ Y` induces a graph isomorphism `tropRipsGraph X ε ≅
tropRipsGraph (image) ε` for every `ε` **iff** `f` is valuation-isometric
(`Y.val (f a) = X.val a`) and injective. With only the multiplicative bound
(`Y.val (f a) ≤ C · X.val a`, cf. `tropDist_map_lipschitz`) the induced map is a filtration
morphism shifting scale by `C`, and `C = 1` exactly when it is non-distorting.

**Testable form.** Prove `tropRipsIso_of_isometry_injective` and its converse
`isometry_of_tropRipsIso_all_scales`, plus `interleaving_distance_le_log C` linking the
multiplicative constant `C` to the persistence interleaving distance.

**Why bold.** Promotes the functor to a *quantitative* (interleaving-metric) functor, giving a
tropical analogue of the algebraic-stability theorem of persistence modules.

---

## Conjecture 4 — Reconstruction round-trip: the functor factors through `valuationReconstruct`

**Statement.** The diagram

```
ValuationMetricCarrier  --tropRipsFiltration-->  GraphFiltration
        |                                              ‖
   valuationReconstruct                                ‖
        v                                              ‖
   UltraNormObj  --(norm-Rips)-->  GraphFiltration  ===
```

commutes on the nose: the Rips filtration built from `tropDist` equals the Rips filtration
built from the catalog's reconstructed ultranorm. (`tropDist_eq_reconstruct` is the
object-level base case.)

**Testable form.** Equip `UltraNormObj` with the analogous metric axioms, define `ultraRips`,
and prove `tropRipsFiltration_eq_ultraRipsFiltration_reconstruct`.

**Why bold.** Makes "the Rips filtration is a functorial image of tropical valuation objects"
a literal commuting-functor statement bridging the two catalog files, not just an analogy.

---

## Conjecture 5 — `p`-adic instantiation and the spherical-shell threshold

**Statement.** The `p`-adic valuation `v_p` on `ℤ` (or `ℚ`) yields a `ValuationMetricCarrier`
whose Rips components at scale `ε = p^{-k}` are exactly the residue classes mod `p^{k}`. Hence
the "Poincaré threshold" of `MetricFiltration.lean` for `p`-adic data is the discrete ladder
`{p^{-k}}`, and `coveringNumber` of a ball of radius `p^{-k}` is exactly `p` (each ball splits
into `p` sub-balls).

**Testable form.** Build `padicCarrier p`, prove `padic_components_eq_residues` and
`padic_coveringNumber_ball = p`, connecting to `coveringNumber_antitone` from
`MetricFiltration.lean`.

**Why bold.** Turns the abstract trivial-valuation example (`intTrivialCarrier`) into the full
self-similar `p`-adic tree, predicting an exact (not asymptotic) covering-number law `N = p^k`
— a clean falsifiable refinement of the generic `n^{-1/d}` packing scaling.
