# Future Directions — Tropical Valuations → Functorial Rips Filtrations

These conjectures build directly on `Bridges/TropicalRipsFiltration.lean`, which shows that
an ℕ-valued ultrametric valuation `v : UltraVal α` on an additive commutative group induces

* a catalog `MetricFiltration` (`UltraVal.toMetricFiltration`),
* whose every stage is a *cluster graph* — the "within radius ε" relation is an
  equivalence relation (`UltraVal.ballSetoid`) and connected components are exactly the
  ε-balls (`UltraVal.valRips_reachable_iff`),
* functorially in valuation-nonincreasing injective group homomorphisms
  (`UltraVal.valRipsHom`, `valRipsHom_id`, `valRipsHom_comp`),
* and which agrees with the standard pseudometric `ripsGraph` whenever the ambient distance
  realizes the radius (`UltraVal.valRips_eq_ripsGraph`).

The combined picture: the chain
`TropicalValuationCarrier → UltraNormObj → UltraVal → MetricFiltration` is established.
The following are concrete, falsifiable next steps.

## Conjecture C1 (Ultrametric characterization of constant persistence)
For a finite `α` and an `UltraVal v`, the connected-components functor `π₀` applied to
`v.toMetricFiltration` is a *step function* of the scale `ε` that is constant on each open
interval between consecutive values of `v.radius`. Equivalently, the number of clusters
`(v.valRips ε).ConnectedComponent` cardinality is right-continuous and changes only at
points of `Set.range (fun p => (v.radius p.1 p.2 : ℝ))`. **Test:** formalize
`numClusters v ε := Fintype.card (v.valRips ε).ConnectedComponent` and prove it is
antitone and locally constant off the finite radius spectrum.

## Conjecture C2 (Functorial monotone interleaving)
A valuation-nonincreasing injective group hom `f : α →+ β` (with `w.val (f a) ≤ v.val a`)
induces, at *every* scale simultaneously, a morphism of `MetricFiltration`s, i.e. for all
`ε` the square commutes and `valRipsHom` assembles into a natural transformation
`v.toMetricFiltration ⟶ w.toMetricFiltration` along `f`. Strengthening: if additionally
`v.val a ≤ C * w.val (f a)` for a constant `C ≥ 1`, then the induced map is a
`C`-interleaving of filtrations (bridge to the `BoltzmannBridge` interleaving files).
**Test:** define a `FiltrationHom` structure and prove `valRipsHom` is natural in `ε`.

## Conjecture C3 (Ball-Setoid quotient is the persistence skeleton)
The quotient `α ⧸ v.ballSetoid k` is, for each `k : ℕ`, a *finer-to-coarser* tower:
`k₁ ≤ k₂ → ` the partition at `k₁` refines that at `k₂` (ultrametric balls nest). Hence the
sequence of quotients forms an inverse system whose limit recovers `α` when `v` is
separated (`v.val x = 0 ↔ x = 0`). **Test:** prove `ballSetoid` refinement
`v.ballRel k₁ x y → v.ballRel k₂ x y` for `k₁ ≤ k₂` (immediate) and that the induced
surjections `α ⧸ ballSetoid k₁ → α ⧸ ballSetoid k₂` are well-defined and compose
functorially; identify the inverse limit with `α` under separation.

## Conjecture C4 (Strict separation from archimedean Rips)
There is *no* pseudometric space `α` with `> 2` points whose ordinary `ripsGraph` satisfies
the clustering law `valRips_adj_trans` at every scale unless the metric is an ultrametric.
That is, the equivalence-relation property of the ε-neighborhood relation, holding for all
`ε`, characterizes ultrametricity. **Test:** state `(∀ ε x y z, Adj ε x y → Adj ε y z →
x ≠ z → Adj ε x z) ↔ (∀ x y z, dist x z ≤ max (dist x y) (dist y z))` for the metric Rips
graph and prove both directions.

## Conjecture C5 (Tropical Lipschitz ⇒ filtration contraction)
A tropical `C`-Lipschitz self-map in the sense of `CategoricalTropicalUltrametric`
(`TropLipschitzWith X C f`) lifted to the additive-group setting induces, for `C ≤ 1`, a
graph endomorphism of `v.valRips ε` at every scale; for general `C` it maps
`v.valRips ε` into `v.valRips (C·ε)`. This connects the catalog's iterated-Lipschitz rate
theorems (`iterated_ultrametric_lipschitz_rate`) to a *scale-dilation* action on the Rips
filtration. **Test:** prove `(hLip : ∀ a, v.val (f a) ≤ C * v.val a) → ∀ ε,
Adj_(valRips v ε) x y → x = y ∨ Adj_(valRips v (C*ε)) (f x) (f y)` and derive an
n-fold `Cⁿ`-dilation corollary.
