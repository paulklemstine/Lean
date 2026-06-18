# Future Directions — Tropical Valuation Objects ↔ Metric Filtrations

## Synthesis

This cycle built a working bridge between two previously disconnected pieces of the
catalog: the categorical theory of tropical valuation objects
(`Bridges/CategoricalTropicalUltrametric.lean`: `TropicalValuationObject`,
`UltraNormObj`, `valuationReconstruct`) and the metric-filtration apparatus
(`Applications/PoincareData/MetricFiltration.lean`: `ripsGraph`, `ripsGraph_mono`,
`ripsGraph_bot_of_metric`). The unifying device is a **distance-parametric Rips
graph** `genRipsGraph d ε`, defined for an arbitrary real-valued pairwise weight `d`
via the symmetrized adjacency `x ≠ y ∧ d x y ≤ ε ∧ d y x ≤ ε`. This single object
absorbs the metric Rips graph as the special case `d = dist`
(`genRipsGraph_eq_ripsGraph`) while remaining well-defined for the *asymmetric,
non-metric* valuation distance `ultraDist X x y = (X.norm (X.sub_op x y) : ℝ)`
extracted from any `UltraNormObj` — crucially without needing symmetry or a triangle
inequality that the `UltraNormObj` API cannot supply.

The conceptual payoff is the recognition that the Rips construction is a **functor of
the distance that is monotone in scale and antitone in distance**. Antitonicity
(`genRipsGraph_antitone`: smaller distance ⟹ more edges) is the load-bearing
structural fact, and it immediately yields a two-sided filtration comparison together
with scale-monotone and emptiness endpoints.

## Results Summary

All results are fully proved (no `sorry`; axioms limited to `propext`,
`Classical.choice`, `Quot.sound`). See
`Catalog/Bridges/TropicalMetricFiltrationBridge.lean`.

- `genRipsGraph` — distance-parametric Rips graph for arbitrary weights.
- `genRipsGraph_mono` — scale monotonicity (mirrors `ripsGraph_mono`).
- `genRipsGraph_antitone` — **central comparison principle**: `d₂ ≤ d₁` ⟹
  `genRipsGraph d₁ ε ≤ genRipsGraph d₂ ε`.
- `genRipsGraph_eq_ripsGraph` — compatibility with the catalog's metric Rips graph.
- `genRipsGraph_bot_of_neg`, `ripsGraph_bot_of_metric` — boundary/emptiness lemmas.
- `ultraDist`, `ultraDist_nonneg` — the tropical valuation distance of an `UltraNormObj`.
- `tropRips_le_metricRips` / `metricRips_le_tropRips` — the two-sided bridge theorems
  (tropical ⊆ ambient under `dist ≤ ultraDist`; ambient ⊆ tropical under the natural
  `ultraDist ≤ dist`).
- `tropRips_le_metricRips_mono` — scale-monotone bridge.
- `tropRips_bot_of_metric`, `tropRips_bot_of_neg` — endpoint transfer of triviality.
- `tropFiltration_le_metricFiltration` — packaged pointwise filtration containment.

A faithfulness correction is recorded in the file: the proposing concept stated the
domination/inclusion in a single direction that is *false* for the antitone Rips
construction; both correct directions are proved instead.

## Research Directions

**1. A persistence-stable interleaving distance between the tropical and ambient filtrations.**
Right now we prove only *pointwise containment* of filtrations. The natural upgrade is
quantitative: if `|ultraDist X x y - dist x y| ≤ δ` uniformly, then the tropical and
metric Rips filtrations should be `δ`-interleaved, and hence their persistence diagrams
are `δ`-close in bottleneck distance. The key insight is that `genRipsGraph_antitone`
plus `genRipsGraph_mono` already give one-sided inclusions at shifted scales
(`genRipsGraph (ultraDist X) ε ≤ ripsGraph X.α (ε+δ)` and the reverse), which is exactly
an interleaving at the 1-skeleton level — the missing step is to lift it through `π₀`
(connected components). Falsifiable: exhibit an `UltraNormObj` with bounded distortion
whose `π₀`-persistence is *not* within `δ`, which would refute the lift. Why now: the
containment lemmas are in place and `MetricFiltration.lean` already isolates the
`π₀`-level behavior the conjecture targets, so the only new ingredient is monotone
functoriality of connected components.

**2. Genuine ultrametricity of `ultraDist` under a group-completed `UltraNormObj`.**
The current `UltraNormObj` lacks a group law, so `ultraDist` is not provably symmetric
or ultrametric. Conjecture: if one adds associativity/inverse axioms making
`(α, add_op, neg_op, zero_val)` an abelian group, then `ultraDist` is a genuine
*pseudo-ultrametric* — `ultraDist X x z ≤ max (ultraDist X x y) (ultraDist X y z)`,
`ultraDist X x x = 0`, and symmetry — turning `genRipsGraph (ultraDist X)` into a true
`MetricFiltration` valued in ultrametric space. The key insight is that
`sub_op x z = add_op (sub_op x y) (sub_op y z)` is the *only* identity needed to push
`norm_add` (the strong triangle inequality on norms) into the strong triangle inequality
on distances. Falsifiable: a finite group-valued `UltraNormObj` violating the triangle
bound would kill it. Why now: `valuationReconstruct` already manufactures `UltraNormObj`s
from `TropicalValuationCarrier`s carrying ring structure, so the group axioms are
essentially free in the reconstructed case.

**3. Functoriality of the bridge along `UltraHom`/`TropHom` morphisms.**
`CategoricalTropicalUltrametric.lean` defines norm-nonexpansive morphisms `UltraHom`.
Conjecture: a nonexpansive `f : UltraHom X Y` induces, for each scale `ε`, a graph
homomorphism `genRipsGraph (ultraDist X) ε → genRipsGraph (ultraDist Y) ε`, making the
tropical filtration a *functor* from the category of `UltraNormObj`s to filtered
`SimpleGraph`s. The key insight is that `norm_nonexpansive'` is precisely the pointwise
distance-domination hypothesis that `genRipsGraph_antitone` consumes, but transported
across a map rather than across two metrics on the same type. Falsifiable: a nonexpansive
morphism whose induced vertex map fails to preserve some edge. Why now: the morphism
algebra (`UltraHom.comp`, `id`, associativity) is already proved in the catalog, so the
functor laws reduce to the comparison lemma plus bookkeeping.

**4. Covering-number transfer across the bridge.**
`MetricFiltration.lean` proves `coveringNumber_antitone` for the ambient metric.
Conjecture: under `ultraDist ≤ dist`, every ambient `ε`-cover is a tropical `ε`-cover,
so `coveringNumber_trop S ε ≤ coveringNumber S ε`, giving a transfer of packing/covering
complexity from the metric world to the valuation world (and hence bounds on the size of
the tropical Rips complex). The key insight is that `IsEpsilonCover` is, like Rips
adjacency, *antitone in distance*, so the same domination hypothesis that controls edges
also controls covers — unifying the two `MetricFiltration` theorem families under one
monotonicity principle. Falsifiable: a configuration where the tropical covering number
strictly exceeds the metric one despite domination. Why now: both `coveringNumber` and
its antitonicity already exist in the catalog; only the cross-distance comparison is new.

**5. Compiling valuation data into Vietoris–Rips persistence pipelines.**
The headline application: package `valuationReconstruct ∘ ultraDist ∘ genRipsGraph` as a
reusable *compiler* taking a `TropicalValuationCarrier` (ring + ℕ-valued valuation) to a
filtered graph ready for persistent-homology computation, with the bridge theorems
certifying that its output is sandwiched by the ambient metric filtration. The key
insight is that everything in this cycle is constructive on the `ℕ`-valued norm, so the
filtration is *decidable and computable* whenever the carrier's `val` and operations are.
Falsifiable as an engineering claim: produce a `TropicalValuationCarrier` for which the
compiled filtration's barcodes provably disagree with the certified containment bounds.
Why now: `valuationReconstruct` gives the carrier→`UltraNormObj` half and this file gives
the `UltraNormObj`→filtration half, so the full pipeline is one composition away.
