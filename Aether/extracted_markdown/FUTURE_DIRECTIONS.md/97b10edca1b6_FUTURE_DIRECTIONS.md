# FUTURE DIRECTIONS
## Functorial monotonicity bridge: tropical valuation objects → metric filtrations

This research cycle produced two fully-verified Lean files (0 sorries, standard
axioms only):

* `Bridges/TropicalMetricFiltrationBridge.lean` — builds a `MetricFiltration`
  from any bundled `UltraNormObj` / `TropicalValuationCarrier`, and proves the
  **functorial monotonicity bridge**: a valuation-nonexpansive injective carrier
  morphism transports Rips edges along the scale-relaxation order
  (`functorial_monotonicity_bridge`, `tropRipsHom`, `tropRipsHom_natural`,
  `tropRipsHom_id`, `tropRipsHom_comp`).
* `Bridges/ValuationNormFiltration.lean` — isolates the clean ultrametric setting
  (`AddCommGroup` + `ValuationNorm`), proves the full (ultra)metric axioms, and
  establishes the **ultrametric clique theorem** `vRips_ultra_trans` /
  `vRips_isEquivClasses`: at every scale the ultrametric Rips graph is a disjoint
  union of cliques (a dendrogram), the metric-filtration face of `add = max`.

Below are bold, testable conjectures for the next cycle. Each is stated so that a
counterexample search or a Lean proof attempt can falsify or confirm it.

---

### F1. Persistence-stability transfer (interleaving conjecture)
If `f : K →+ L` is a valuation-nonexpansive group homomorphism with
`|NL.v (f x) - NK.v(...)|` controlled by a constant `c`, then the induced map of
`MetricFiltration`s is a **`c`-interleaving** in the sense of persistent homology:
`vRips NK t ⊑ comap f (vRips NL (t+c))` and a matching reverse bound. Concretely,
formalize an interleaving distance on `MetricFiltration K` and prove
`d_interleave (vFiltration NK) (pushforward f (vFiltration NL)) ≤ c`. Testable:
start with `c = 0` (the nonexpansive case proved this cycle) and relax.

### F2. Group-completion makes `tropFiltration` a genuine Rips filtration
Conjecture: adding cancellation (`sub_op x y = zero ↔ x = y`) to
`TropicalValuationCarrier` (i.e. an `AddCommGroup` core, as in Iteration 2) is
*exactly* the condition under which `tropRips` collapses to the one-directional
`vRips` and `tropFiltration` becomes isometric, via a type-synonym
`PseudoMetricSpace`, to `MetricFiltration.rips`. Falsifiable: exhibit a
non-cancellative carrier whose two-sided and one-sided Rips graphs differ at some
scale (the lab notes already show the bare carrier is too weak — make this sharp).

### F3. The ultrametric clique theorem characterizes ultrametricity
Conjecture (converse of `vRips_ultra_trans`): for an `AddCommGroup`-valued
symmetric ℕ-distance `d` with `d x y = 0 ↔ x = y`, if `vRips`-style edge relations
are transitive at *every* real scale `t`, then `d` satisfies the strong triangle
inequality (is an ultrametric). I.e. "every scale's threshold graph is a disjoint
union of cliques" ⟺ ultrametric. Testable on small finite metric spaces by brute
force before attempting the Lean proof.

### F4. Dendrogram / hierarchical-clustering functor
Build on `vRips_isEquivClasses`: the assignment `t ↦ (partition of K into vRips
cliques)` is a monotone (coarsening) family of `Setoid K`, i.e. a **dendrogram**.
Conjecture: `t ↦ Quotient (vRips_isEquivClasses N t)` is a functor from `(ℝ, ≤)` to
`Set`/`Type` whose connecting maps are surjective, and it is the persistent-`π₀`
of `vFiltration`. Deliver: a `Dendrogram K` structure plus the proof that every
`ValuationNorm` yields one, recovering Carlsson–Mémoli's ultrametric/clustering
correspondence inside the bridge.

### F5. Quantitative covering-number transfer
Connect to `coveringNumber` from `Applications/PoincareData/MetricFiltration.lean`.
Conjecture: for a valuation-nonexpansive injective `f : K →+ L`, the covering
numbers satisfy `coveringNumber (f '' S) ε ≤ coveringNumber S ε` for all `ε ≥ 0`
(images are no harder to cover), and for the discrete valuation the covering number
at `0 ≤ ε < 1` equals `|S|` while at `ε ≥ 1` it equals `1`. This bridges the
functorial transfer to the metric-entropy / Poincaré-threshold side of the
catalog. Testable computationally on finite subsets first.
