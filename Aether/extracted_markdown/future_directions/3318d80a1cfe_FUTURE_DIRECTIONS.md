# Future Directions — Functorial Tropical Threshold Graphs

Derived from the two research cycles formalized in
`Bridges/TropicalThresholdGraph.lean` and
`Bridges/TropicalThresholdGraphUltrametric.lean`, which built the bridge
`TropicalValuationObject` → graph filtration (`tropThresholdGraph`), proved
monotonicity, functoriality (a *full* embedding under distance-preserving injections),
the comparison theorem `tropThresholdGraph_eq_ripsGraph` with the catalog `ripsGraph`,
the reconstruction theorem `threshold_graphs_eq_imp_pred_eq`, and the ultrametric
closed-ball transitivity `tropThresholdGraph_ultrametric_trans`.

Below, each conjecture is **bold and falsifiable**, with a "key insight" and a
"why now" justification.

---

## Conjecture 1 — Ultrametric threshold graphs are exactly the cluster graphs

**Statement.** For every threshold `r`, the graph `tropThresholdGraph T d _ r` of an
*ultrametric* tropical distance (one satisfying the strong triangle inequality) is a
**disjoint union of cliques** (a "cluster graph"): the relation `x = y ∨ Adj x y` is an
equivalence relation, and the quotient is a discrete set of complete subgraphs.
Conversely, any `ℝ`-indexed monotone filtration whose every level is a cluster graph
arises from some ultrametric tropical distance.

**The key insight is** that `tropThresholdGraph_ultrametric_trans` already proves the
transitivity half on the nose; promoting it to a structural equivalence/quotient
statement turns the ultrametric strong triangle inequality into a *combinatorial
classification* of the entire filtration, and the converse is a reconstruction in the
spirit of `threshold_graphs_eq_imp_pred_eq`.

**Why now?** The strong-triangle hypothesis is already isolated and proven sufficient in
cycle 2, and the catalog's `CategoricalTropicalUltrametric.lean` supplies the matching
`ultrametric_reconstruction_isosceles`; the only missing step is packaging
transitivity as a `Setoid` and reading off the clique decomposition.

---

## Conjecture 2 — Persistent π₀ of the tropical filtration equals the ultrametric dendrogram

**Statement.** The number of connected components of `tropThresholdGraph T d _ r`, viewed
as a function of `r`, is a non-increasing step function whose merge tree (barcode in
degree 0) is **isomorphic to the dendrogram of single-linkage clustering** of the
induced ultrametric, with merge heights given by `val` of the tropical distances.

**The key insight is** that monotonicity (`tropThresholdGraph_mono`) plus the
comparison theorem (`tropThresholdGraph_eq_ripsGraph`) identify the tropical π₀
filtration with the Rips π₀ filtration, and in the ultrametric case Rips π₀ *is* the
single-linkage dendrogram — so the tropical valuation object computes the dendrogram
directly, no metric embedding required.

**Why now?** `MetricFiltration.lean` already provides the Rips side and
`coveringNumber_antitone`; the bridge file now provides the exact identification at every
level, so degree-0 persistence is the immediate next invariant to formalize.

---

## Conjecture 3 — Functoriality upgrades to a faithful functor into `SimpleGraph`-valued sheaves

**Statement.** The assignment `(V, d) ↦ (r ↦ tropThresholdGraph T d _ r)` extends to a
**faithful functor** from the category of `R`-valued metric point sets with
distance-preserving injections to the category of monotone `R`-indexed diagrams of
`SimpleGraph`s and graph embeddings, and this functor *reflects isomorphisms*.

**The key insight is** that the embedding `tropThresholdGraph_embedding` is *full*
(it reflects as well as preserves adjacency — proven via `hf.ne_iff`), and the functor
laws `tropThresholdGraph_embedding_refl` / `..._trans` already hold definitionally; thus
faithfulness and iso-reflection are the genuinely new categorical content.

**Why now?** Both functor laws are now machine-checked, so the remaining categorical
statements (faithful, reflects isos) sit one elaboration step away and need only the
existing `TropHom`/category scaffolding of `CategoricalTropicalUltrametric.lean`.

---

## Conjecture 4 — The comparison theorem fails for ordinary metrics by a sharp factor 2

**Statement.** For a *non-ultrametric* tropical distance realized by `val`, the tropical
threshold graph at `r` and the Rips graph can differ, and the discrepancy is controlled:
`tropThresholdGraph T d _ r ⊆ ripsGraph α (2 · val r)` always, while equality at
`val r` can fail. The constant `2` is **sharp** and is exactly the triangle-inequality
slack that the ultrametric case removes.

**The key insight is** that the comparison theorem's two localized hypotheses
(`hreal`, `hthr`) are *necessary*, not cosmetic: when `val` only sub-additively realizes
the metric, the strong-triangle gap of cycle-2's critique re-enters as a multiplicative
factor, and `sphere_diam_bound` (factor `2r`) in `MetricFiltration.lean` predicts the
same constant.

**Why now?** Cycle 2 explicitly flagged that the ordinary triangle inequality gives only
`d x z ≤ r + r`; turning that failure analysis into a *quantified, sharp* containment
theorem is the natural falsifiable sequel and reuses `ripsGraph_mono`.

---

## Conjecture 5 — Reconstruction is constructive: an algorithm recovers `d` up to order-iso from the filtration

**Statement.** From the full family `r ↦ tropThresholdGraph T d _ r` over a finite point
set one can **algorithmically reconstruct** the tropical distance `d` up to a monotone
relabeling of `R`, in time polynomial in the number of distinct threshold graphs; the
reconstruction is unique exactly on off-diagonal pairs.

**The key insight is** that `threshold_graphs_eq_imp_pred_eq` already shows the
filtration determines the pairwise predicate `T.le (d x y) r` on distinct pairs; making
this *effective* turns the bridge into a concrete pipeline from combinatorial filtrations
back to tropical valuations, closing the loop the project set out to build.

**Why now?** The information-theoretic uniqueness is now a theorem; the only remaining
ingredient is a finite-search extraction, which is well within reach for finite `V` and
connects directly to the `coveringNumber`/packing machinery already in the catalog.
