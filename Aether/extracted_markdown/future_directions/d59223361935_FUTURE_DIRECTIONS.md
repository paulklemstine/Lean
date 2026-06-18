# Future Directions — Tropical-to-Ultrametric Rips Bridge

## Synthesis

This cycle joined two previously disconnected pillars of the catalog. On the
geometric side, `Applications/PoincareData/MetricFiltration.lean` supplied the
Rips graph filtration `ripsGraph` and its monotonicity `ripsGraph_mono`. On the
algebraic side, `Bridges/CategoricalTropicalUltrametric.lean` supplied the typed
tropical valuation framework (`TropicalValuationCarrier`, `valuationReconstruct`,
`UltraNormObj`). The new file `Bridges/TropicalUltrametricRips.lean` builds the
missing edge-level bridge between them.

The decisive move was to generalize the Rips construction away from
`PseudoMetricSpace` to an arbitrary symmetric distance datum `d : V → V → ℝ`
(`ripsGraphOf`). This is exactly the generality required to feed in a *tropical
valuation distance* `carrierDist X x y = X.val (X.sub_op x y)`, which is **not**
an honest metric — it need not satisfy the triangle inequality, and not even
symmetry follows from the carrier axioms. With this generalization in hand, the
entire stability phenomenon collapses, just as in the catalog's bottleneck file,
onto a *single* pointwise inequality `du ≤ dt + ε`, from which monotonicity, the
graph homomorphism packaging, and two-sided interleaving all follow as
bookkeeping.

## Results Summary

* `ripsGraphOf` / `ripsGraphOf_mono` — Rips filtration of an arbitrary symmetric
  ℝ-valued distance and its monotonicity (a strict generalization of the catalog
  `ripsGraph_mono`), with `ripsGraphOf_dist` recovering `ripsGraph` for
  `d = dist`.
* `ripsGraphOf_le_shift` — the falsifiable core: a comparison inequality
  `du ≤ dt + ε` transports every edge of the source graph at scale `r` to an
  edge of the target graph at scale `r + ε` (verified to depend on **no**
  axioms).
* `ripsHomOfShift` — the transport realized as a genuine `SimpleGraph.Hom`.
* `ripsGraphOf_interleaving` — two-sided scale-shift stability from
  `|d₁ - d₂| ≤ ε`.
* `trop_to_ultra_rips_transport` / `trop_to_ultra_rips_hom` — the cross-domain
  bridge from tropical valuation data to ultrametric Rips edge inclusions.
* `reconstruct_rips_eq` — the `ε = 0` functorial identity: a tropical carrier's
  Rips filtration equals that of its reconstructed ultrametric object.
* `tropCarrierMax` — a concrete `ℕ`-carrier grounding the bridge (non-vacuity).

A key *negative* result is documented in the Lab Notebook: the intuitive
hypothesis direction `d_trop ≤ u + ε` does **not** yield transport of tropical
edges into the ultrametric graph; the target distance must be the majorized one
(`u ≤ d_trop + ε`). Stating the theorem with the wrong direction is provably
unsound for the intended conclusion.

## Research Directions

### 1. A persistence-stability theorem for valuation filtrations

The two-sided interleaving `ripsGraphOf_interleaving` is a relational
ε-interleaving but is not yet tied to the catalog's metric
`interleavingDist` from `Applications/BoltzmannBridge/BottleneckStability.lean`.
The conjecture: for any two symmetric distance data with
`supDist d₁ d₂ ≤ ε`, the associated `ripsGraphOf` filtrations satisfy
`interleavingDist ≤ ε`, i.e. the bridge factors through the established
bottleneck pre-distance. **The key insight is** that `ripsGraphOf_le_shift`
already produces both inclusions an interleaving needs, so only the packaging
into the `Interleaved`/`interleavingDist` API is missing — no new geometry.
**Why now?** The interleaving metric and its 1-Lipschitz stability theorem were
just completed in the catalog; wiring `ripsGraphOf` into them turns a pair of
ad hoc inclusions into a bona fide stability theorem with a named distance.

### 2. When is the valuation distance an honest ultrametric?

`carrierDist` is symmetric and satisfies the strong triangle inequality only
under extra hypotheses on the carrier (distributivity of `neg_op` over `add_op`,
and additivity of `sub_op` along a midpoint). The conjecture: adding the single
axiom `sub_op x z = add_op (sub_op x y) (sub_op y z)` to
`TropicalValuationCarrier` makes `carrierDist` a genuine ℕ-valued ultrametric,
so that `ripsGraphOf (carrierDist X)` becomes the Rips filtration of an actual
`PseudoMetricSpace` and inherits `ripsGraph_bot_of_metric`. **The key insight
is** that the strong triangle inequality for the *distance* is a consequence of
`val_add` (already an axiom) *plus* additive compatibility of subtraction — the
norm axiom is there, only the algebraic glue is missing. **Why now?** It cleanly
separates the load-bearing axiom from decorative ones and would let the bridge
reuse every metric-side boundary theorem in `MetricFiltration` for free.

### 3. Functoriality of the whole filtration assignment

`reconstruct_rips_eq` is the object-level `ε = 0` identity. The conjecture: the
assignment `X ↦ (r ↦ ripsGraphOf (carrierDist X) r)` extends to a functor from
the category of valuation-carrier morphisms (`TropValCarrierHom`) to the
category of `GeneralizedFiltration`s, with carrier morphisms inducing graph
homomorphisms commuting with the scale parameter. **The key insight is** that
`TropValCarrierHom.val_nonexpansive'` (norm does not increase) is exactly the
condition that makes a vertex map a Rips graph homomorphism at *equal* scale,
so functoriality reduces to the already-proven `ripsGraphOf_le_shift` with
`ε = 0` along the morphism. **Why now?** The catalog already has the morphism
category and its composition laws; lifting them to filtrations would deliver the
"functor between filtration categories" promised by the original concept.

### 4. Quantitative loss under valuation reconstruction with error

`tropical_bound_to_ultrametric_bound` transfers bounds with *no* loss when the
reconstruction is exact. The conjecture: if a reconstruction is only
approximate, with `|norm(reconstruct x) − val x| ≤ δ`, then the induced Rips
filtrations are `δ`-interleaved via `ripsGraphOf_interleaving`, giving an
explicit `interleavingDist ≤ δ` certificate for *lossy* valuation reconstruction.
**The key insight is** that approximate reconstruction is just a perturbed
distance datum, so the existing interleaving machinery measures the loss without
any new analytic input. **Why now?** It converts the qualitative "faithful
functor" slogan into a falsifiable quantitative robustness statement, directly
extending the catalog's certified-robustness narrative.

### 5. Persistent π₀ (connected components) transport

The bridge currently transports *edges*. The conjecture: edge transport implies
component transport — if `ripsGraphOf dt r ≤ ripsGraphOf du (r+ε)` then the map
on connected components (`SimpleGraph.ConnectedComponent`) induced by
`ripsHomOfShift` is surjective, so the number of components is monotone
non-increasing under the scale shift, yielding a one-parameter bound on the
persistent π₀ of valuation data. **The key insight is** that a spanning graph
homomorphism (identity on vertices) always induces a surjection on components,
so persistent-π₀ stability is a formal consequence of the homomorphism we
already built. **Why now?** π₀ is the only homological degree fully supported at
the graph level, making this the highest-value, lowest-risk next theorem and a
direct route from valuation data to a computable topological summary.
