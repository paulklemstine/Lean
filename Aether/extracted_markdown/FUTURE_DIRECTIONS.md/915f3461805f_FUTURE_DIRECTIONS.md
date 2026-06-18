# Future Directions — Species ↔ Metric-Filtration Bridge

## Synthesis

This cycle closed the conceptual gap between two previously separate corners of the catalog:
the combinatorial-species / exponential-generating-function (EGF) machinery in
`Catalog/Applications/CombinatorialSpecies.lean` (which already had a complete product law
`egf_card_prodSpecies`, the binomial convolution `binConv`, and the EGF dictionary `egf_add`,
`egf_mul`), and the Rips-graph metric-filtration API in
`Catalog/Applications/PoincareData/MetricFiltration.lean` (`ripsGraph`, `ripsGraph_mono`).

The new file `Catalog/Applications/SpeciesMetricBridge.lean` introduces the **π₀ counting
invariant** `numComponents α r = Nat.card (ripsGraph α r).ConnectedComponent` and proves that it
is the shared "size invariant" through which the two theories talk to each other:

- π₀ is **antitone in scale** (`numComponents_antitone`, built on `ripsGraph_mono`): the
  components-only-die half of a persistence diagram.
- π₀ is **additive on disjoint sums of graphs** (`connectedComponent_card_sum`) and, metrically,
  on **separated disjoint unions of point clouds** (`ripsGraph_eq_sum`, `numComponents_separated`):
  the species *sum* law incarnate.
- The **labeled-assembly count** of a two-cloud disjoint union is the binomial convolution
  `binConv 1 1`, whose EGF `egf (n ↦ 2ⁿ)` equals `setSpecies.EGF * setSpecies.EGF`
  (`egf_disjointLabelings`): the species *product* law incarnate.

## Results Summary

| Theorem | Statement | Built on |
|---|---|---|
| `connectedComponent_card_anti` | `G ≤ H ⇒ |π₀ H| ≤ |π₀ G|` | `ConnectedComponent.map` surjectivity |
| `numComponents_antitone` | `r₁ ≤ r₂ ⇒ numComponents r₂ ≤ numComponents r₁` | `ripsGraph_mono` |
| `connectedComponent_card_sum` | `|π₀ (G ⊕g H)| = |π₀ G| + |π₀ H|` | explicit `cc ≃ cc ⊕ cc` |
| `numComponents_separated` | separated split ⇒ π₀ counts add | `ripsGraph_eq_sum`, `Equiv.sumCompl` |
| `egf_disjointLabelings` | `egf (2ⁿ) = setSpecies.EGF · setSpecies.EGF` | `egf_card_prodSpecies`, `egf_mul` |

All five are `sorry`-free and depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. A genuine multiplicative π₀-EGF for *rooted/pointed* assemblies

So far the metric disjoint union gives an **additive** π₀ law, while multiplicativity only appears
at the level of labelings (`2ⁿ`). The natural next object is the EGF of the sequence
`n ↦ Σ over n-point separated clouds of (number of components)`, weighted so that the convolution
becomes genuine. Conjecture: if `cₙ` counts component-pointed structures on an `n`-point separated
cloud, then `egf c` for a two-block family factors as `egf cᴬ * egf cᴮ` exactly when the pointing
distributes over the binomial split — i.e. the pointed species bridge `EGF_pointedSpecies` of the
catalog transports through `numComponents_separated`.
**The key insight is** that pointing (`X · d/dX`, already formalized as `egf_pointing`) is precisely
the operation that converts the *additive* π₀ law into a *multiplicative* generating-function law,
because choosing a distinguished component is exactly the data a product species records.
**Why now?** The catalog just gained `EGF_pointedSpecies`/`egf_pointing` in the previous deepening,
and this cycle gave `numComponents_separated`; combining them is the immediate, falsifiable next
step (it fails if a counterexample two-block family violates the factorization).

### 2. Quantitative persistence: bounding the number of scale thresholds where π₀ drops

`numComponents_antitone` says π₀ is a non-increasing integer step function of `r`. Conjecture: for a
finite metric space of `n` points the number of distinct values it takes is at most `n`, and the set
of "death scales" (values of `r` where `numComponents` strictly decreases) has cardinality exactly
`n − numComponents α (diam)`; moreover each death scale is a pairwise distance.
**The key insight is** that every merge event is witnessed by a single edge crossing its threshold,
so the death multiset injects into the finite multiset of pairwise distances.
**Why now?** With π₀ now a first-class `Nat.card` invariant and `ripsGraph_mono` in hand, the step
function is fully formalizable; this turns the qualitative "components only die" into a counted
persistence-diagram statement that is directly testable on explicit finite point sets.

### 3. Functoriality of π₀ under `coveringNumber` — a packing/component inequality

`MetricFiltration.lean` already proves `coveringNumber_antitone` and `maximal_packing_is_cover`.
Conjecture: at scale `r`, `numComponents α r ≤ coveringNumber α (r/2)`, i.e. an `r/2`-cover
provides an upper bound on the number of `r`-Rips components, because two points in a common cover
ball are within `r` and hence Rips-adjacent.
**The key insight is** that a cover ball is contained in a single Rips component, so the cover map
descends to a surjection cover-centers ↠ components, exactly the `Nat.card_le_card_of_surjective`
pattern used in `connectedComponent_card_anti`.
**Why now?** Both `coveringNumber` and `numComponents` are now `Nat`-valued invariants with the same
proof toolkit (surjections of finite types), so the inequality is a short, falsifiable bridge that
links the packing/covering theory to the π₀ theory within one file.

### 4. The EGF of components of a *product* metric (Cartesian / box) space

`Mathlib.Combinatorics.SimpleGraph.Prod` provides the box product `□`. Conjecture: for the
`ℓ∞`-product of two finite metric spaces, `ripsGraph (α × β) r` relates to the box product of the
factor Rips graphs, and consequently `numComponents (α × β) r = numComponents α r · numComponents β r`
(π₀ of a connected box product is the product of π₀'s).
**The key insight is** that the box product is the graph-theoretic shadow of the *metric* product,
turning the species **product** EGF (`egf_card_prodSpecies`) into a genuine *multiplicative* π₀ law —
the multiplicative companion to this cycle's additive `numComponents_separated`.
**Why now?** This cycle established the additive (disjoint-sum) half cleanly; the multiplicative
(product) half is the symmetric counterpart and is exactly where `egf_mul` would acquire a true
metric meaning, making the whole species EGF ring map (sum ↦ ⊔, product ↦ ×) metrically realized.

### 5. Higher π: from `ripsGraph` 1-skeleton to a clique-complex Euler characteristic species

The Rips *graph* is only the 1-skeleton. Conjecture: the alternating count of cliques of the Rips
graph (the Euler characteristic of the Vietoris–Rips clique complex) is, for separated disjoint
unions, *additive*, and its generating function is the **sum** of the factor generating functions —
extending `numComponents_separated` (which is the degree-0 case) to all degrees at once.
**The key insight is** that Euler characteristic is the universal additive-under-disjoint-union
invariant, so the same `Equiv.sumCompl`/`SimpleGraph.sum` decomposition used here should lift verbatim
from `ConnectedComponent` counts to clique counts.
**Why now?** Mathlib has `SimpleGraph.cliqueFinset`/clique counting, and this cycle supplies the
disjoint-union splitting lemma `ripsGraph_eq_sum`; chaining them is the natural, falsifiable route to
a full Euler-characteristic species bridge (it fails if cross-cliques can appear, which `ripsGraph_eq_sum`
provably rules out under separation).
