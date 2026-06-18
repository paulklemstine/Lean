# Future Directions — Functorial Tropicalization of Rips Filtrations

## Synthesis

This cycle built the missing functor connecting three previously-disjoint catalog
regions: the **Rips filtration** machinery of
`Applications/PoincareData/MetricFiltration.lean` (`ripsGraph`, `ripsGraph_mono`,
`ripsGraph_bot_of_neg`), the **categorical tropical valuation objects** of
`Bridges/CategoricalTropicalUltrametric.lean` (`TropicalValuationObject`, `TropObj`),
and the language of nonarchimedean / ultrametric geometry.

The bridge is a single number per pair of points, the **single-linkage connectivity
threshold**

```
connThreshold X x y = sInf { r : ℝ | (ripsGraph X r).Reachable x y },
```

the first scale at which `x` and `y` fall into the same connected component of the
Vietoris–Rips graph. The file `Bridges/RipsTropicalization.lean` proves this object is:

* an **ultrametric** — `connThreshold_self` (`u(x,x)=0`), `connThreshold_symm`,
  `connThreshold_nonneg`, and the strong triangle inequality
  `connThreshold_strong_triangle` (`u(x,z) ≤ max (u(x,y)) (u(y,z))`);
* **dominated by the metric** — `connThreshold_le_dist` (`u ≤ d`), i.e. it is the
  single-linkage ultrametric extracted from `d`;
* **functorial** — `connThreshold_nonexpansive`: every 1-Lipschitz map of metric spaces
  is 1-Lipschitz for the induced ultrametrics, so the construction is a functor
  `Met → UltraMet`;
* **idempotent** — `connThreshold_eq_dist_of_ultrametric`: applied to a space that is
  already ultrametric, it returns the same ultrametric;
* **packaged tropically** — `maxTimesTrop` realizes `ℝ≥0` as a genuine
  `TropicalValuationObject` (max–times semiring), `ripsTropObj` is the associated
  `TropObj`, and `connThreshold_tropical_max_law` shows the threshold valuation obeys the
  object's `max_op` law verbatim.

## Results Summary

| Theorem | Statement | Axioms |
|---|---|---|
| `connThreshold_self` | `u(x,x) = 0` | `propext, Classical.choice, Quot.sound` |
| `connThreshold_strong_triangle` | `u(x,z) ≤ max (u(x,y)) (u(y,z))` | same |
| `connThreshold_le_dist` | `u ≤ d` pointwise | same |
| `connThreshold_nonexpansive` | 1-Lipschitz functoriality | same |
| `connThreshold_eq_dist_of_ultrametric` | idempotence on ultrametrics | same |
| `connThreshold_tropical_max_law` | valuation into `ripsTropObj` obeys `max_op` | same |

The decisive structural observation is that `connSet x y` is an **up-set** in `ℝ`
(monotonicity of `ripsGraph`), reducing the strong triangle inequality to concatenating
two reachability witnesses at a common scale `max(u,u)+ε` and letting `ε → 0`. No
simplicial-complex machinery is required — only `SimpleGraph.Reachable`.

## Research Directions

### 1. Maximality: `connThreshold` is the greatest ultrametric below `d`

We proved `u ≤ d` and idempotence, but not the universal property that pins down
single-linkage: among **all** ultrametrics `ρ ≤ d`, `connThreshold` is the largest. The
falsifiable claim is that for any ultrametric `ρ` with `ρ(x,y) ≤ d(x,y)` for all `x,y`,
one has `ρ(x,y) ≤ connThreshold(x,y)`. The key insight is that a connecting Rips chain at
scale `r` forces `ρ(x,y) ≤ max` of the edge values `≤ r` by the strong triangle
inequality of `ρ` (exactly the argument already used in `rips_reach_ultra`, now run with
`ρ` in place of `d`). Why now? `rips_reach_ultra` is already a generic "chain ⟹ max
bound" lemma; abstracting its `dist`-specific hypothesis to an arbitrary ultrametric `ρ`
turns idempotence into the full universal property essentially for free, upgrading the
construction from "an ultrametric below `d`" to "the canonical adjoint to the inclusion
`UltraMet ↪ Met`."

### 2. The functor is a genuine reflection (adjunction) onto `UltraMet`

Direction 1 plus the existing functoriality strongly suggests `X ↦ (X, connThreshold)` is
**left adjoint** to the forgetful functor `UltraMet → Met`, with unit the identity-on-
points 1-Lipschitz map `(X,d) → (X,u)`. The falsifiable statement: for every ultrametric
space `(Y,ρ)` and 1-Lipschitz `f : (X,d) → (Y,ρ)`, the same `f` is 1-Lipschitz
`(X,u) → (Y,ρ)`, and this factorization is unique. The key insight is that any
`d`-nonexpansive map into an ultrametric target automatically dominates connectivity
chains, so `ρ(f x, f y) ≤ u(x,y)` follows from Direction 1 applied along `f`. Why now?
The catalog's `CategoricalTropicalUltrametric.lean` already encodes morphism categories
and adjunction-style "unit/counit" reasoning (`unit_iso_on_rigid_objects`,
`counit_iso_on_separated_objects`); proving the reflection makes `connThreshold` a
first-class citizen of that categorical framework rather than a standalone gadget.

### 3. Stability: the threshold is itself 1-Lipschitz in the Gromov–Hausdorff/`ℓ∞` sense

Persistent-homology pipelines live or die by stability. Conjecture: if two metrics
`d, d'` on the same set satisfy `|d(x,y) − d'(x,y)| ≤ δ` for all pairs, then
`|connThreshold_d(x,y) − connThreshold_{d'}(x,y)| ≤ δ`. The key insight is that an
additive `δ`-shift of every edge weight shifts each connecting chain's max by at most `δ`,
so the up-sets `connSet` translate by at most `δ` and their infima move by at most `δ` —
a direct `csInf` comparison, no homology needed. Why now? `MetricFiltration.lean` already
proves perturbation stability for sphere detection (`sphere_perturbation_stability`) and
antitonicity of covering numbers; an `ℓ∞` stability theorem for the connectivity
threshold is the natural π₀-level companion and connects the bridge to the interleaving-
distance results in `Applications/BoltzmannBridge/`.

### 4. Dendrogram / ultrametric-as-tree representation theorem

Every finite ultrametric is the leaf metric of a rooted weighted tree (a dendrogram);
single linkage is precisely the agglomerative tree. Falsifiable target: for a finite
metric space, `connThreshold` equals the cophenetic distance of the single-linkage
dendrogram, and the sublevel sets `{ (x,y) | connThreshold x y ≤ r }` are exactly the
equivalence relations "same component of `ripsGraph r`". The key insight is that
`connThreshold x y ≤ r ↔ r ∈ connSet x y` (up-set membership), so sublevel sets *are*
connectivity partitions, which are nested and transitive — i.e. a tree. Why now? This is
the representation-theoretic dual (a *spatial*/tree model) of the algebraic valuation
object built this cycle, exactly in the spirit of the engine's Stone/Gelfand-duality
mandate: it turns the tropical valuation `connThreshold` into a concrete combinatorial
tree, and the partition-lattice structure is already latent in `connSet_up`.

### 5. Higher-dimensional / weighted tropical valuations

`connThreshold` is the `H₀` (connectivity) shadow of the Rips filtration. The bold
direction: define analogous tropical valuations from higher Betti birth/death scales and
ask which strong-triangle-style inequalities survive. A concrete falsifiable first step:
the "cycle-birth" scale (first `r` at which a fixed 1-cycle becomes a boundary) does
**not** in general satisfy the ultrametric inequality, but a max–min variant over
representative chains does. The key insight is that `H₀` connectivity is special because
reachability is transitive (`Reachable.trans`), the lone ingredient behind the strong
triangle inequality; higher homology lacks a literal transitivity, so any surviving
nonarchimedean law must come from a chain-level max–min duality. Why now? The catalog's
`CategoricalTropicalUltrametric.lean` already treats valuations abstractly over an
idempotent semiring, so a higher-dimensional valuation that lands in the *same* `TropObj`
machinery would extend the bridge from π₀ to full persistence while reusing all the
tropical infrastructure.
