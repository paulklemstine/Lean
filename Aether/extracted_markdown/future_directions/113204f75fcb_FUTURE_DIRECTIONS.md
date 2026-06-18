# Future Directions
## A Functorial Tropical Lower Bound for Rips Connectivity via Valuation-Depth Sublevel Graphs

This cycle established the core "ultrametric collapse" theorem in
`Catalog/Bridges/TropicalRipsConnectivity.lean`:

> Over an ultrametric (non-Archimedean / valuation) space, two points are connected in the
> Rips graph at scale `ε ≥ 0` **iff** `dist x y ≤ ε`. Hence the connectivity threshold
> `connThreshold x y = dist x y` is the exact, tight scale at which points merge, and it
> itself satisfies the tropical (max) triangle inequality `connThreshold x z ≤
> max (connThreshold x y) (connThreshold y z)`.

We also isolated the contrasting general ("Archimedean") bound `dist x y ≤ length · ε`,
quantifying exactly how much the leak can be in a non-ultrametric space.

Below are bold, **falsifiable** conjectures for follow-up cycles.

---

### C1 — Bottleneck = distance characterization of ultrametricity (converse)
**Conjecture.** For a `PseudoMetricSpace α`, the equivalence
`(ripsGraph α ε).Reachable x y ↔ dist x y ≤ ε` holds for **all** `ε ≥ 0` and all `x y`
**iff** `α` is ultrametric (`IsUltrametricDist α`). The forward direction is proved this
cycle (`reachable_iff`); the converse — *Rips-reachability collapsing to the sublevel test
forces the strong triangle inequality* — would make the collapse a **characterization** of
non-Archimedean geometry, not merely a consequence. Testable: assume the iff and derive
`dist x z ≤ max (dist x y) (dist y z)` using the 2-edge walk `x → y → z`.

### C2 — Functorial component-count lower bound on finite clouds
**Conjecture.** For a finite ultrametric space, the number of connected components of
`ripsGraph α ε` equals the number of distinct closed `ε`-balls, is **antitone** in `ε`, and
its value at scale `ε` is a **certified lower bound** for the component count of *any*
pseudometric `d' ≥ d` with the same point set at the same scale (functoriality under
1-Lipschitz domination). This upgrades `reachable_mono` from a pointwise statement to a
quantitative π₀ inequality. Testable: `Fintype.card (ConnectedComponent (ripsGraph α ε))`.

### C3 — Valuation-depth = persistence-length identity
**Conjecture.** Define the *valuation depth* of a pair `(x, y)` as the number of distinct
ultrametric balls strictly between them (the length of the maximal chain of nested
`ε`-balls separating them as `ε` increases from `0` to `dist x y`). Then this depth equals
the number of distinct finite "death scales" appearing in the π₀ persistence barcode of the
Rips filtration restricted to `{x, y}` and its ancestors. This directly bridges
`PadicValuationDepth.lean` (max-composition depth) with persistent homology: depth is the
tropical length of the merge tree.

### C4 — Tropical functor preserves products / ultrametric on `α × β`
**Conjecture.** The connectivity-threshold functor is **monoidal** for the `max`-product
metric: on `α × β` with `dist((a,b),(a',b')) = max (dist a a') (dist b b')`, one has
`connThreshold ((a,b),(a',b')) = max (connThreshold a a') (connThreshold b b')`, and
`ripsGraph (α × β) ε`-reachability factors as the conjunction of the factor reachabilities.
Hence the tropical lower bound is compatible with the tropical (max) tensor product —
making "valuation reconstruction is a quantitative functor" (the parent bridge) hold at the
level of Rips connectivity. Testable in Lean with `Prod` and `sup`-metrics.

### C5 — Stability of the threshold functor under Gromov–Hausdorff / Lipschitz perturbation
**Conjecture.** If `f : α → β` is an `L`-Lipschitz map between ultrametric spaces, then
reachability transfers with a scale dilation: `(ripsGraph α ε).Reachable x y →
(ripsGraph β (L·ε)).Reachable (f x) (f y)`, and the connectivity thresholds satisfy
`connThreshold (f x) (f y) ≤ L · connThreshold x y`. This is the "certified robustness"
payoff promised by `CategoricalTropicalUltrametric.lean`: tropical bounds transfer
functorially to perturbed point clouds. Testable directly from `reachable_iff` + Lipschitz.
