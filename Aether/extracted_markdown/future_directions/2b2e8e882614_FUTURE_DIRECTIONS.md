# Future Directions — Tropical Valuation Filtrations

## Synthesis

`Bridges/TropicalValuationFiltration.lean` turns the static valuation→ultranorm
dictionary of `Bridges/CategoricalTropicalUltrametric.lean` into a *functor* landing in
scale-indexed combinatorial filtrations, in the spirit of the Rips-graph filtration of
`Applications/PoincareData/MetricFiltration.lean`. From a difference operation `sub` and an
integer ultranorm `val` we build the valuation distance `d(x,y) = val(sub x y)`, its closed
balls `valBall`, and the symmetric valuation–Rips graph `valRipsGraph`. We proved:

- **Threshold monotonicity** (`valBall_mono`, `valRipsGraph_mono`, `valRipsGraph_monotone`):
  the filtration is monotone in the scale `r`, the ℕ-valued analogue of `ripsGraph_mono`.
- **Valuation comparison** (`valBall_comparison`, `valRipsGraph_comparison`,
  `valRipsGraph_comparison_carrier`): pointwise domination `val₂ ≤ val₁` reverses into an
  inclusion of filtered graphs — the dominating valuation gives the *finer* filtration.
- **Functoriality** (`valRipsGraph_map_adj`, `valRipsGraph_hom`,
  `valRipsGraph_hom_threshold_comm`): a valuation-preserving injection induces a genuine
  `SimpleGraph.Hom` of filtrations at every scale, commuting with the threshold inclusions.
- **Bridge instances** onto `UltraNormObj` (`UltraNormObj.dist`, `UltraNormObj.ripsGraph`,
  `UltraNormObj.valRipsGraph_mono`).

All main results are `sorry`-free and depend on no extra axioms.

## Results summary

The deliverable is one self-contained Lean file with seven theorems plus the bundled
`SimpleGraph.Hom` functor, all building directly on the catalog's `UltraNormObj`. The
conceptually important result is the comparison theorem: an *inequality on valuations*
becomes a *certified inclusion of combinatorial filtrations*, the precise "coarser/finer"
statement the concept asked for, and the engine for converting symbolic valuation bounds
into machine-checkable filtration maps.

## Research directions

### 1. Persistent π₀: connected components are monotone along the valuation filtration
The key insight is that `valRipsGraph_mono` already gives an inclusion of graphs at every
scale, and quotient-by-`Reachable` is a functor on inclusions, so the number of connected
components of `valRipsGraph sub val r` should be **antitone in `r`** and the induced maps on
component sets should assemble into a persistence module over `ℕ`. Conjecture: for finite
carriers, `(valRipsGraph sub val r).ConnectedComponent` cardinality is antitone, and the
comparison theorem makes it antitone in the valuation too. Why now? Mathlib already has
`SimpleGraph.ConnectedComponent` and `Reachable`, and our monotonicity lemmas supply exactly
the inclusion maps these constructions consume; the only missing piece is the finiteness
bookkeeping, which is mechanical.

### 2. An ultrametric strong-triangle refinement of the balls
The key insight is that when `val` genuinely satisfies the ultrametric bound
`val(add x y) ≤ max (val x) (val y)` (the `UltraNormObj.norm_add` axiom), the closed balls
should satisfy the nonarchimedean "every interior point is a center" property: if
`z ∈ valBall sub val r x` then `valBall sub val r z = valBall sub val r x`. Conjecture: this
holds once `sub` is compatible with `add`/`neg` as in a group, and it upgrades `valRipsGraph`
to a *transitive* (equivalence-like) relation at each scale, collapsing the filtration to a
chain of partitions. Why now? `CategoricalTropicalUltrametric` already ships `norm_add` and
`norm_neg`; only the `sub`/group-compatibility hypotheses must be isolated and added.

### 3. Cohomological obstruction to gluing local filtration sections
The key insight is that the threshold inclusions make `r ↦ valRipsGraph sub val r` a
presheaf on the poset `ℕᵒᵖ`, and asking whether locally-defined component labels glue into a
global labeling is a degree-1 Čech/limit obstruction. Conjecture: the obstruction vanishes
iff the filtration is "tame" (finitely many critical scales), giving a falsifiable
local-to-global criterion. Why now? The functoriality lemmas (`valRipsGraph_hom`,
`_threshold_comm`) are precisely the restriction maps a presheaf needs, so the diagram is
already in hand and the limit/colimit can be taken in `Type` or `SimpleGraph`.

### 4. Valuation comparison is a Galois-style adjunction on filtrations
The key insight is that `valRipsGraph_comparison` is monotone in `val` and `valRipsGraph_mono`
is monotone in `r`, so the assignment `(val, r) ↦ valRipsGraph sub val r` is a *bimonotone*
map of posets; one expects an adjoint pair relating "minimal scale achieving a target graph"
and "maximal valuation refining it." Conjecture: there is a Galois connection between scale
thresholds and valuation thresholds for a fixed target subgraph. Why now? The catalog already
contains `GaloisConnectionBridge.lean`; combining its API with our two monotonicity directions
is a direct cross-domain synthesis.

### 5. From integer ultranorm to real Vietoris–Rips, bridging into `MetricFiltration`
The key insight is that casting `val : α → ℕ` into `ℝ` and symmetrizing `sub` should make
`d(x,y) = ((val(sub x y) + val(sub y x))/2 : ℝ)` a genuine `PseudoMetricSpace`, at which point
`valRipsGraph` becomes (a subgraph of) the real `ripsGraph` of `MetricFiltration.lean`, and
`ripsGraph_mono` follows from `valRipsGraph_mono` by transport. Conjecture: under
symmetry of the valuation distance the two filtrations coincide, formally linking the two
catalog files. Why now? The only obstruction was that `Applications` is not a build target and
its `ripsGraph` needs a symmetric real distance; isolating the symmetry hypothesis (or adding
`Applications` to the lakefile) closes the gap and yields a literal equality of filtrations.
