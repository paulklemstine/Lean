# Future Directions: Emergent Spacetime from Quantum Entanglement

The module `Catalog/Physics/EmergentSpacetimeMetric.lean` establishes a fully
machine-checked bridge from entanglement entropy to metric geometry. It defines
the **entropy polymatroid** (grounded, monotone, submodular rank functional) and
its **information distance** `d(X,Y) = 2 f(X∪Y) - f(X) - f(Y)`, proving that this
distance satisfies nonnegativity, symmetry, the triangle inequality, an
Araki–Lieb Lipschitz lower bound, the ER=EPR identity `d = f(X)+f(Y) - 2 I(X:Y)`,
and that it assembles into a genuine `PseudoMetricSpace` — and, on the separation
quotient, an honest `MetricSpace`. It also pins down the precise boundary
(`pure_state_violates_nonneg`): dropping monotonicity (the pure-state /
holographic regime of `HolographicGravity.HoloProfile`) makes the distance go
negative, which explains *why* the syndrome defect of that module fails to be a
pseudometric. The directions below are the natural, falsifiable next steps.

## Direction 1: Curvature from the second-order entropy defect

Define a discrete Ricci-type curvature on the emergent metric as the gap in the
triangle inequality, `κ(X,Y,Z) = d(X,Y) + d(Y,Z) - d(X,Z) ≥ 0`, and relate its
pointwise vanishing to modularity of the entropy functional (a valuation on the
lattice). Conjecture: `κ ≡ 0` on all triples **iff** `f` is modular
(`f(X∪Y)+f(X∩Y)=f(X)+f(Y)`), i.e. the emergent geometry is flat exactly when the
polymatroid is a measure. The key insight is that the triangle *surplus* is the
discrete analogue of geodesic convexity, so its vanishing is a rigidity statement
of the same flavor as `HolographicGravity.flat_of_zero_total_defect`. Why now? We
already have `infoDist_triangle` with an explicit submodular witness in the proof,
so the surplus is computable in closed form and the modularity equivalence is a
finite linear-algebra fact ready to be formalized.

## Direction 2: Monogamy (MMI) as Gromov hyperbolicity of the emergent metric

Holographic entropies obey the monogamy of mutual information
(`HolographicGravity.MonogamousProfile`), strictly stronger than submodularity.
Conjecture: when a *monotone* profile additionally satisfies MMI, its information
metric is Gromov δ-hyperbolic with an explicit, dimension-free δ, capturing the
tree-like / negatively-curved structure of holographic bulk geometry. The key
insight is that MMI is precisely a four-point inequality on entropies, and Gromov
hyperbolicity is a four-point inequality on distances, so MMI should translate
term-by-term into the hyperbolic four-point condition. Why now? Both `mutualInfo`
and `tripartiteInfo` are already formalized here and in `HolographicGravity`, so
the translation is an algebraic manipulation rather than new analysis.

## Direction 3: The Hamming/Jaccard family and a classification of emergent metrics

We proved the uniform polymatroid yields exactly the Hamming metric `|X △ Y|`
(`infoDist_card_eq_symmDiff`). Conjecture: every *matroid rank function* produces
an emergent metric that embeds isometrically into `ℓ¹`, and conversely a finite
metric arises from some polymatroid information distance **iff** it is an
`ℓ¹`-metric (a cut metric). The key insight is that submodular rank functions are
exactly the support functions of polymatroid polytopes, whose facets are cuts, and
cut metrics are the `ℓ¹`-embeddable ones. Why now? The cardinality case is already
a theorem, giving a concrete anchor; generalizing to weighted/partition matroids
is a direct structural extension with no new machinery required.

## Direction 4: Continuity / stability of the emergent geometry

Conjecture: the map `polymatroid ↦ information metric` is 1-Lipschitz in the
sup-norm on `f`: if `‖f - g‖_∞ ≤ ε` then the two information distances differ by
at most `4ε` pointwise, so emergent spacetime is *stable* under small
perturbations of the entanglement functional. The key insight is that `infoDist`
is an affine functional of `f` evaluated at three sets, so its perturbation is
controlled coordinatewise — a quantitative companion to the Lipschitz bound
`infoDist_ge_abs` already proved. Why now? The bound is a one-line linear estimate
on top of the existing `def infoDist`, making it an immediate, high-confidence
formalization target that upgrades the qualitative emergence to a quantitative,
noise-robust statement.

## Direction 5: From regions to events — a spectral/dimension probe of the quotient

`infoDist_quotient_metric_exists` realizes emergent *points* as boundary regions
modulo zero entanglement distance. Conjecture: for the cardinality polymatroid on
`n` sites the separation quotient is the Boolean cube `{0,1}^n` with the Hamming
metric, whose growth function `#{Y : d(X,Y) ≤ r}` is `∑_{k≤r} C(n,k)`, giving a
well-defined *emergent dimension* `n` via volume growth. The key insight is that
the coincidence relation collapses exactly the entropy-degenerate regions, so for
a matroid the quotient is its lattice of flats, whose metric geometry is
combinatorially explicit. Why now? The quotient metric space is already
constructed in Lean, so computing its growth/dimension for the proven Hamming
case is a finite combinatorial verification that turns "emergent geometry" into a
measurable "emergent dimension."
