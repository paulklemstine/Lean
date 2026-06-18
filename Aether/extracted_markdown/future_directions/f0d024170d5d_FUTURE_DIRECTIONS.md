# Future Directions — Functorial Tropical Valuation of Metric Filtrations

## Synthesis

`Catalog/Bridges/RipsTropicalValuation.lean` builds a load-bearing bridge between two
previously disconnected catalog domains: the metric-filtration / persistent-homology
machinery of `Applications/PoincareData/MetricFiltration.lean` (`ripsGraph`,
`ripsGraph_mono`) and the abstract tropical valuation category of
`Bridges/CategoricalTropicalUltrametric.lean` (`TropicalValuationObject`, `TropObj`).

The unifying object is the **edge-appearance valuation** `τ(x,y)`, the infimal scale at
which a pair becomes a Rips edge. We proved it (i) *characterizes* edges
(`mem_rips_iff_threshold_le`), (ii) *generates* the entire filtration via sublevel
monotonicity (`rips_mono`, generalizing the catalog `ripsGraph_mono` to arbitrary
symmetric dissimilarities with no triangle inequality), (iii) is *stable* under
pointwise domination, with `d₁ ≤ d₂` reversing graph inclusion
(`rips_anti_of_dist_le`), (iv) *reconstructs* the filtration — two filtrations are equal
iff their thresholds agree off the diagonal (`rips_eq_iff_threshold_eq`), and (v) lives
inside an explicit **max-plus tropical valuation object** `tropMaxPlus` on `WithBot ℝ`,
where Rips edges become tropical sublevel sets (`edge_appears_iff_tropLe`) and
domination becomes the intrinsic tropical order (`threshold_tropLe_of_dist_le`).

## Results Summary

| Theorem | Role |
|---|---|
| `EdgeDissim.mem_rips_iff_threshold_le` | edge ⇔ valuation sublevel |
| `EdgeDissim.rips_mono` | filtration monotonicity (generalizes `ripsGraph_mono`) |
| `EdgeDissim.metricDissim_rips_eq_ripsGraph` | restricts to catalog `ripsGraph` |
| `EdgeDissim.rips_anti_of_dist_le` | stability / functoriality |
| `EdgeDissim.rips_eq_iff_threshold_eq` | reconstruction |
| `tropMaxPlus` | max-plus instance of `TropicalValuationObject` |
| `EdgeDissim.edge_appears_iff_tropLe` | Rips edges = tropical sublevels |
| `EdgeDissim.threshold_tropLe_of_dist_le` | order-preserving valuation morphism |

## Conjectures for the Next Cycle

### 1. Lipschitz stability of the valuation profile in the tropical sup-metric
A bi-Lipschitz comparison `c · d₁(x,y) ≤ d₂(x,y) ≤ C · d₁(x,y)` should force the
threshold valuations to be uniformly close in the tropical (sup over edges of the
`WithBot ℝ` difference) sense, giving a quantitative refinement of the qualitative
`threshold_tropLe_of_dist_le`. **The key insight is** that the max-plus object turns
multiplicative metric distortion into *additive* tropical displacement, so a Lipschitz
constant becomes a single additive shift bound on the whole valuation profile. **Why
now?** We already have the order-preserving morphism and the explicit `WithBot ℝ`
carrier; upgrading `≤` to a numeric gap is the natural and falsifiable next step (it
fails the instant some edge violates the claimed shift), and it directly connects to the
certified-robustness bounds that `CategoricalTropicalUltrametric` advertises.

### 2. Persistence-diagram bottleneck stability from threshold reconstruction
The reconstruction theorem `rips_eq_iff_threshold_eq` says the valuation is a complete
invariant; the conjecture is that the *0-dimensional persistence diagram* of the Rips
filtration is a function of the sorted multiset of edge thresholds, and that bottleneck
distance between two diagrams is bounded by the sup-norm of the threshold difference.
**The key insight is** that π₀-persistence is a minimum-spanning-tree statistic of the
threshold weights, so it factors through the tropical valuation rather than the metric.
**Why now?** With `rips` and `τ` already proven equivalent and monotone, the MST/union-
find reduction is purely combinatorial and computable (`decide`/`#eval` on finite vertex
sets), making the bound concretely testable before any homology machinery is formalized.

### 3. Functoriality as a genuine categorical functor `EdgeDissim → TropObj`
Promote the constructions to a functor: objects `EdgeDissim α` map to `tropMaxPlus`-valued
profiles and domination-respecting maps to order morphisms, satisfying identity and
composition laws mirroring `TropHom.comp_id` / `TropHom.comp_assoc` in the catalog.
**The key insight is** that the valuation is natural in the vertex set: relabelings and
quotients of vertices act on thresholds by min/inf, exactly the tropical `add = max`
operation, so the assignment is functorial *for free* once the morphism class is fixed.
**Why now?** The catalog already supplies a full category of tropical objects with
verified category laws; we only need to package our two morphism theorems into that
existing scaffold, a low-risk formalization with an immediately falsifiable composition
law.

### 4. Ultrametric collapse of the threshold valuation
Conjecture: the threshold valuation `τ` satisfies the strong (ultrametric) triangle
inequality `τ(x,z) ≤ max(τ(x,y), τ(y,z))` **iff** the underlying dissimilarity is itself
an ultrametric, in which case `τ` factors through an `UltraNormObj` from
`CategoricalTropicalUltrametric` and the Rips filtration's connected components form a
hierarchical clustering tree. **The key insight is** that single-linkage clustering is
precisely the ultrametric *sub-dominant* of `τ`, the largest ultrametric below it, so the
gap between `τ` and its ultrametric collapse measures non-tree-likeness. **Why now?** The
target `UltraNormObj` and its norm axioms already exist in the catalog, so this closes the
remaining Tropical↔Ultrametric leg of the bridge and is falsifiable on any 4-point space
violating the ultrametric inequality.

### 5. Computable threshold valuation and decidable filtration equality
For `Fintype` vertex sets with rational dissimilarities, the valuation profile is a finite
table, `rips r` is `DecidableRel`, and `rips_eq_iff_threshold_eq` becomes a *decidable*
equivalence checkable by `decide`. **The key insight is** that the entire continuous
filtration `{rips r}_{r∈ℝ}` is determined by the finite set of *critical* thresholds
`{τ(x,y)}`, so equality of two filtrations over all real scales reduces to equality of two
finite rational tables. **Why now?** Our definitions are already `noncomputable`-free in
spirit (only the `WithBot ℝ` carrier is `noncomputable`); replaying them over `ℚ` yields an
executable persistent-homology equality oracle, an algorithmic deliverable that is directly
testable against hand computations.
