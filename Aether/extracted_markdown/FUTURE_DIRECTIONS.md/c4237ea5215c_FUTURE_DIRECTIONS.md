# Future Directions — Nonexpansive Tropical-to-Ultrametric Functor on Rips Filtrations

## Synthesis

This cycle built a genuine bridge between two previously disconnected catalog domains:
the tropical valuation objects of `Catalog/Bridges/CategoricalTropicalUltrametric.lean`
and the metric-filtration / Rips-graph pipeline of
`Catalog/Applications/PoincareData/MetricFiltration.lean`. The new file
`Catalog/Bridges/TropicalUltrametricRips.lean` shows that an ultrametric valuation on an
abelian group induces an honest ultrametric distance `du x y = val (x - y)`, that this
distance is filtration-monotone and nonexpansive for Rips thresholds, and that the
resulting ultrametric Rips graphs have an exceptionally rigid topology: their connected
components are *cliques*.

The central conceptual payoff is that ultrametricity is exactly the hypothesis that turns
the "two points are within scale r" relation into an *equivalence relation*. This is the
algebraic reason single-linkage and complete-linkage clustering coincide on ultrametric
data, and it is now a machine-checked corollary (`ball_equiv`,
`ultrametric_rips_reachable_iff`) of the strong triangle inequality `du_ultra`.

## Results Summary

* **Genuine ultrametric distance.** `UltraValuation.du_self`, `du_symm`, `du_ultra`,
  `du_triangle`: `du x y = val (x - y)` is reflexive, symmetric, and satisfies the strong
  (max) triangle inequality.
* **Ultrametric balls partition.** `UltraValuation.ball_equiv`: the "within r" relation is
  an equivalence relation.
* **Catalog bridge.** `UltraValuation.ofCarrier`: every catalog `TropicalValuationCarrier`
  whose additive operations form an `AddCommGroup` yields an `UltraValuation`;
  `carrier_val_ultrametric` records the seminorm-level fact provable from the bare axioms.
* **Generalized Rips graph.** `ripsGraphD` with `ripsGraphD_dist_eq` (recovers the catalog
  `ripsGraph` for honest pseudometrics) and `ripsGraphD_mono`.
* **Nonexpansive transport.** `ripsGraphD_transport`, `ripsGraph_mono_transport`,
  `ripsGraph_of_valuation_le`: a monotone control `du ≤ φ ∘ d` gives canonical, threshold-
  monotone inclusions of Rips filtrations.
* **Clique structure.** `ultrametric_rips_reachable_iff`: in an ultrametric Rips graph,
  distinct vertices are reachable iff adjacent.
* **Falsification.** The bare `TropicalValuationCarrier` axioms are provably *insufficient*
  for a distance ultrametric; abelian-group structure is the minimal honest addition.

All main results depend only on the standard axioms `propext`, `Classical.choice`,
`Quot.sound`.

## Research Directions

### 1. The induced ultrametric is a bona fide `PseudoMetricSpace`/`UltrametricSpace`

We currently keep `du` as an `ℕ`-valued function and compare Rips graphs via the explicit
`ripsGraphD`. The next step is to package `(K, fun x y => (V.du x y : ℝ))` as a genuine
Mathlib `PseudoMetricSpace` instance (via `PseudoMetricSpace.ofDistTopology` or the
`IsUltrametricDist` API) and then prove `ripsGraphD V.duR r = ripsGraph K r` *as catalog
Rips graphs*, closing the loop with `MetricFiltration` at the instance level. The key
insight is that the only obstruction is bookkeeping: `du_self`, `du_symm`, and
`du_triangle` are already exactly the three `PseudoMetricSpace` axioms, so the instance is
forced. Why now: Mathlib v4.28 ships `IsUltrametricDist`, so the target structure exists
and the induced filtration would immediately inherit every `MetricFiltration` theorem
(covering numbers, packing-covering duality) for free.

### 2. Persistence is trivial for ultrametric filtrations (clique-rank barcode)

Because every component of an ultrametric Rips graph is a clique, the entire connected-
component (π₀) persistence module is determined by the *sorted multiset of pairwise
valuations*. Conjecture: the number of connected components of `ripsGraphD V.duR r` is a
right-continuous step function of `r` whose jump points are exactly the distinct finite
values of `du`, and the π₀ barcode equals the merge tree of the ultrametric. The key
insight is that `ball_equiv` reduces persistence to counting equivalence classes of a
threshold relation, eliminating all simplicial machinery. Why now: `ultrametric_rips_
reachable_iff` already proves components are cliques, so the component count is literally
the number of `ball_equiv` classes — the remaining work is a finite-combinatorics count,
well within reach.

### 3. Functoriality: valuation-carrier morphisms induce Rips-graph homomorphisms

The catalog has `TropValCarrierHom` and proves `valuationReconstruct` is a functor. Extend
this: a nonexpansive carrier morphism `f : K → K'` (with `V'.du (f x) (f y) ≤ V.du x y`)
should induce a `SimpleGraph.Hom (ripsGraphD V.duR r) (ripsGraphD V'.duR r)` for every `r`,
and these homomorphisms commute with the filtration inclusions `ripsGraphD_mono`. The key
insight is that nonexpansiveness is precisely the condition for a map to send edges to
edges at the same scale, so the assignment `r ↦ ripsGraph` becomes a functor from carrier
morphisms to filtered-graph morphisms. Why now: `ripsGraphD_transport` is the object-level
half of exactly this statement (take `φ = id`), so only the morphism-level packaging
(a `SimpleGraph.Hom`) remains.

### 4. Sharpness of the group hypothesis: a separating counterexample carrier

The Failure Analysis claims the bare carrier axioms cannot yield a distance ultrametric.
Make this a *theorem*, not a remark: construct an explicit `TropicalValuationCarrier`
(e.g. a commutative monoid with a deliberately broken `sub_op`) on which
`val (sub_op x z) ≤ max (val (sub_op x y)) (val (sub_op y z))` provably *fails* for some
`x, y, z`. The key insight is that without the cancellation law `(-y) + y = 0` the
expression `(x - y) + (y - z)` need not equal `x - z`, so a monoid where `sub_op` ignores
its second argument breaks transitivity. Why now: producing one finite counterexample
carrier (e.g. on a 3-element carrier with `val` into `{0,1,2}`) turns a philosophical
disclaimer into a falsifiable, machine-checked sharpness result, strengthening the bridge's
foundations.

### 5. Quantitative interleaving / stability of the comparison map

Strengthen `ripsGraph_of_valuation_le` from a one-sided inclusion to a two-sided
*interleaving*: if additionally `d x y ≤ ψ (du x y)` for a monotone `ψ`, then the source
and induced filtrations are `(φ, ψ)`-interleaved, giving a bound on the bottleneck distance
between their π₀ barcodes. The key insight is that the nonexpansive inclusion already proven
is one of the two maps required by the interleaving definition; the reverse control supplies
the other, and ultrametric clique structure makes the bottleneck bound explicit rather than
existential. Why now: this connects the bridge directly to the stability theorem of
persistent homology and to the catalog's certified-robustness theme (Lipschitz transfer in
`CategoricalTropicalUltrametric`), turning a comparison map into a certified, quantitative
data-analysis pipeline.
