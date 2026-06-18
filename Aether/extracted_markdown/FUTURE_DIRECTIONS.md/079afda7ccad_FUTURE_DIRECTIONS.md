# FUTURE_DIRECTIONS.md — Hadwiger's Conjecture Formalization

## Synthesis

This cycle established the foundational formalization of graph minors via branch-set models
in Lean 4, building on Mathlib's `SimpleGraph` infrastructure. We proved the base cases
of Hadwiger's conjecture (k ≤ 2), the clique-to-complete-minor theorem, and Wagner's
forward direction (Hadwiger(5) ⟹ 4CT). The branch-set characterization proved to be
clean and natural for formal proof — singleton branch sets handle all the easy cases
uniformly, and the structure decomposes well into nonemptiness, disjointness, connectivity,
and adjacency witnesses.

The main structural insight is that minor monotonicity (if K is a minor of H and H ≤ G,
then K is a minor of G) follows directly from the branch-set model by reusing the same
branch sets and lifting adjacency/connectivity. This suggests that edge contraction can
also be formalized as a derived operation rather than a primitive one.

The Hadwiger number definition via `⨆` over subtypes works but creates friction for
proving lower bounds due to `BddAbove` obligations in `ℕ∞`. A finite-type version
using `Finset.sup` might be more tractable for computational cases.

## Results Summary

| Theorem | Status | Significance |
|---------|--------|-------------|
| `isMinor_refl` | proved | Reflexivity of minor relation via singleton branch sets |
| `isMinor_of_le` | proved | Subgraph implies minor (foundational monotonicity) |
| `isMinor_of_isMinor_of_le` | proved | Minor relation is monotone under subgraph ordering |
| `hadwiger_case_zero` | proved | K₀ is a minor of any graph (vacuous) |
| `hadwiger_case_one` | proved | K₁ is a minor of any nonempty graph |
| `hadwiger_of_adj` | proved | Any graph with an edge has K₂ as a minor |
| `completeGraph_minor_of_clique` | proved | Cliques of size n witness K_n as a minor |
| `wagner_forward` | proved | Hadwiger(5) implies the Four Color Theorem |
| `HadwigerConj` | definition | Formal statement of Hadwiger's conjecture: χ(G) ≤ h(G) |

## Research Directions

### Direction 1: Hadwiger for k = 3 via Kuratowski subdivision
**Hypothesis**: Every graph with chromatic number ≥ 3 (equivalently, containing an odd cycle)
has K₃ as a minor. This is equivalent to: every 2-colorable graph is bipartite.
**Test**: Formalize the proof that odd cycles give K₃ minors. An odd cycle C_{2n+1}
contracts to a triangle by collapsing edges along the cycle. Alternatively, show that
a non-bipartite graph contains an odd cycle, then contract it.
**Why now**: The branch-set framework handles contractions naturally — contracting an
edge (u,v) means merging their branch sets. The Mathlib bipartiteness API
(`SimpleGraph.IsBipartite`) should connect to 2-colorability.
**If true**: Completes Hadwiger for k ≤ 3 and validates the contraction approach.
**If false**: Would mean a gap in the formalization of odd cycles, requiring more
cycle theory in Mathlib.
The key insight is that contraction of edges along a path is equivalent to merging
branch sets, which our framework handles natively.

### Direction 2: Edge contraction as a derived operation on MinorModel
**Hypothesis**: Contracting an edge (u,v) in G produces a graph G/e such that
any minor of G is also a minor of G/e (with appropriate vertex identification).
Formally: there exists a `contractEdge` function on `SimpleGraph` such that
`IsMinor G H → IsMinor (contractEdge G e) H'` for an appropriate H'.
**Test**: Define `contractEdge` by merging vertex u into v (via `Quotient`),
then prove that contracting an edge in a branch set preserves the minor model.
**Why now**: Our minor monotonicity theorem (`isMinor_of_isMinor_of_le`) shows
the pattern works for subgraph inclusion. Edge contraction is the natural next step.
**If true**: Enables inductive proofs on graph size for Hadwiger cases k = 4, 5.
**If false**: Would indicate that quotient-based contraction needs a more careful
treatment of the induced graph structure.
The key insight is that edge contraction is a quotient operation on vertices, and
Lean's `Quotient` type should handle this cleanly when combined with `SimpleGraph`.

### Direction 3: Computational verification of Hadwiger for small graphs
**Hypothesis**: Hadwiger's conjecture holds for all graphs on at most 6 vertices.
This is computationally verifiable by exhaustive enumeration (2^15 = 32768 graphs
on 6 vertices).
**Test**: Define `HadwigerSmall n` and use `native_decide` or `decide` for n ≤ 5.
This requires decidable instances for `IsMinor` and `chromaticNumber` on finite graphs.
**Why now**: The `MinorModel` structure can be made `Decidable` on `Fin n` by
searching over all possible branch-set assignments. Mathlib's `SimpleGraph.Colorable`
already has decidability for finite types.
**If true**: Provides machine-verified evidence for Hadwiger up to 6 vertices.
**If false**: Would reveal a bug in the formalization — Hadwiger is known to be true
for small cases.
The key insight is that decidability of `IsMinor` on `Fin n` reduces to a finite
search over partitions of `Fin n` into connected subsets.

### Direction 4: Wagner's converse — 4CT implies Hadwiger(5)
**Hypothesis**: The Four Color Theorem implies Hadwiger's conjecture for k = 5.
The proof by Wagner (1937) shows that K₅-minor-free graphs can be decomposed
(via clique sums) into planar graphs and the Wagner graph V₈, both of which are
4-colorable.
**Test**: Formalize the Wagner graph V₈ (Möbius-Kantor graph on 8 vertices),
prove it is 4-colorable, then prove that clique sums preserve 4-colorability
for graphs with no K₅ minor.
**Why now**: We have the forward direction (Hadwiger(5) ⟹ 4CT). The converse
would close the equivalence, making it a significant formalization milestone.
**If true**: Establishes the full Wagner equivalence, reducing Hadwiger(5) to 4CT.
**If false**: Would indicate missing structural decomposition theory (clique sums)
that needs to be built from scratch.
The key insight is that the hard part is the clique-sum decomposition theorem, which
requires significant graph structure theory not yet in Mathlib.

### Direction 5: Mader's density bound for K₃ and K₄ minors
**Hypothesis**: Every simple graph with average degree > 2(k-1) contains K_k as a minor,
for k ≤ 4 (Mader 1967). For k = 3: average degree > 4 guarantees a K₃ minor.
For k = 4: average degree > 6 guarantees a K₄ minor.
**Test**: Prove the k = 3 case: if the average degree > 4, the graph has at least
2|V|+1 edges, which forces a cycle (by handshaking + spanning tree argument), hence
a K₃ minor by contraction.
**Why now**: Our `avgDegree` definition and `completeGraph_minor_of_clique` provide
the framework. The argument combines counting (sum of degrees = 2|E|) with the
structural minor theory we've built.
**If true**: Gives quantitative versions of Hadwiger for small k, complementing
the qualitative results.
**If false**: Would indicate that the density-to-minor pipeline needs cycle
detection theory not yet formalized.
The key insight is that Mader's bound provides a bridge between edge-counting
(well-supported in Mathlib) and topological minor theory (our contribution).
