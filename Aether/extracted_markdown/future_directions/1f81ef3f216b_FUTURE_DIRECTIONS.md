# Future Directions — Metric Filtration Rank Profiles as Tropical Valuation Objects

This research cycle established (file
`Catalog/Bridges/MetricFiltrationTropicalProfile.lean`, all theorems verified, 0 sorries,
axioms `propext`/`Classical.choice`/`Quot.sound` only) that the connectivity data of a finite
metric (Rips) filtration is a **tropical valuation object**:

* the *merge scale* `connThreshold` is an ultrametric whose strong triangle inequality is the
  tropical `max`-additive law (`connThreshold_isUltrametric`);
* it is *attained* / minimax (`connThreshold_attained`, `connAt_iff_threshold_le`);
* it is *subdominant* (`connThreshold_le_dist`) and, in fact, **the greatest** subdominant
  ultrametric (`isUltrametric_le_connThreshold` — was Conjecture C1, now proved);
* the construction is **idempotent** on ultrametric spaces
  (`connThreshold_eq_dist_of_isUltrametric` — was Conjecture C5, now proved);
* it is *functorial* under nonexpansive maps (`connThreshold_nonexpansive_map`);
* the π₀ rank profile `compCount` is antitone in scale (`compCount_antitone`).

Below are bold, falsifiable conjectures for the next cycles. Each is stated so it can be
formalized directly as a Lean theorem (or disproved by a counterexample).

## Conjecture C2 — π₀ persistence / barcode identity
The rank profile is a step function whose jumps are exactly the distinct merge scales.
Formally, for a finite nonempty space, `compCount α ε` equals `Nat.card α` minus the number
of "independent" merges with threshold `≤ ε`; equivalently the number of distinct values of
`connThreshold` that are `≤ ε` (counted with merge multiplicity) equals
`Nat.card α - compCount α ε`. **Test:** induct on `criticalScales`; relate component merges
to edges of a minimum spanning tree (Kruskal / single-linkage dendrogram).

## Conjecture C3 — Bottleneck / Lipschitz stability of the profile
The merge-scale ultrametric is `1`-Lipschitz in the underlying metric: if `d₁, d₂` are two
pseudometrics on the same finite carrier with `∀ a b, |d₁ a b - d₂ a b| ≤ δ`, then
`|connThreshold₁ x y - connThreshold₂ x y| ≤ δ` for all `x, y`. This is the π₀ case of the
persistence stability theorem. **Test:** symmetric application of the functoriality method
(`connAt_map_of_nonexpansive`) with the identity map between the two metrics.

## Conjecture C4 — Genuine tropical-valuation-object instance and a faithful functor
Construct an explicit `CategoricalTropicalUltrametric.TropicalValuationObject` whose order
and `max_op` are realized by `connThreshold`, and assemble a `TropHom` (resp. `UltraHom`)
from each nonexpansive map (using `connThreshold_nonexpansive_map`). Conjecture: this
assignment is a **faithful functor** from the category of finite pseudometric spaces &
nonexpansive maps to tropical valuation objects. **Test:** discharge the structure axioms;
faithfulness from injectivity of the induced map on merge-scale tables.

## Conjecture C6 — Kruskal / minimum-spanning-tree identity
On a finite metric space, `connThreshold x y` equals the **bottleneck (minimax) distance**
read off a minimum spanning tree: the maximum edge weight along the unique MST path from `x`
to `y`. Equivalently, `connThreshold` is computed by Kruskal's algorithm and depends only on
the MST. **Test:** build the MST via greedy edge addition and match merges to the
`criticalScales` ordering; prove path-bottleneck invariance under the cycle property.

## Conjecture C7 — Monoidal / product law for merge scales
For the `max`-metric (ℓ∞) product `α × β` of two finite spaces,
`connThreshold_{α×β} (a,b) (a',b') = max (connThreshold_α a a') (connThreshold_β b b')`.
That is, the merge-scale functor is **strong monoidal** with respect to the tropical `max`,
mirroring the `max_op` law of `TropicalValuationObject`. **Test:** components of the product
Rips filtration factor as products; transport reachability componentwise and take the
tropical `max`.
