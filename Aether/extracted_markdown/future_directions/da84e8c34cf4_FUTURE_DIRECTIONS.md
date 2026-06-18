# Future Directions

## Synthesis

The results in this cycle establish the structural toolkit for proving strict sub-d integrality gaps in d-uniform hypergraphs with bounded pair codegree: threshold rounding, conflict graph coloring, overlap bounds, edge count inequalities, and independent set cover. These components form a *layered rounding framework* that decomposes the covering problem into a well-controlled threshold phase and a repair phase whose cost is governed by the chromatic number of a conflict graph. The five directions below extend this framework along orthogonal axes — closing the quantitative gap, bridging to tropical geometry, extending to higher-order codegree, connecting to proof complexity, and developing online variants. Together, they form a research program that transforms pair codegree from a local structural parameter into a universal lens for approximation quality.

---

## Direction 1: Close the Full Sub-d Gap Conjecture

**Conjecture.** For every d ≥ 3 and K ≥ 1, there exists ε(d,K) = 1/(2d(K+1)) such that every d-uniform hypergraph H with Δ₂(H) ≤ K and sufficiently many vertices satisfies τ(H) ≤ (d − ε(d,K)) · τ*(H).

**Test.** Computationally verify for d = 3, K = 1, 2, 3 on all linear 3-uniform hypergraphs up to n = 15 vertices. If any instance achieves τ/τ* > d − 1/(2d(K+1)), the predicted constant must be revised.

**Impact.** This would be the first general integrality gap improvement for structured hypergraph covering, with implications for approximation algorithm design and LP-based proofs of combinatorial bounds.

**Catalog References.**
- `Catalog/Pythagorean/SubdIntegralityGap.lean` — structural toolkit (this cycle)
- `Catalog/Pythagorean/HypergraphTransversal.lean` — base τ ≤ d·τ* bound

**Proof Strategy.** The key missing piece is bounding the total weight of uncovered edges. If x is an optimal fractional transversal, the uncovered edges U at threshold θ = 1/(d−δ) satisfy Σ_{e∈U} (1 − Σ_{v∈e} x(v)·I[x(v)≥θ]) > 0. By LP complementary slackness, the uncovered weight can be bounded in terms of τ* and the threshold gap δ. Combine with the conflict graph coloring (K·C(d,2)+1 colors) and the repair bound (≤ 1 vertex per edge per color class) to get total ≤ (d−1+δ)·τ* + (K·C(d,2)+1)/(d−1−δ)·τ*. Optimize δ to minimize.

**Domain Bridges.** Approximation algorithms, LP rounding, polyhedral combinatorics.

**Lineage.** Direct extension of this cycle's `uniform_transversal_exists` and `edgesSharingPair_card_bound`.

**Ambition.** Grand challenge — closing this conjecture would resolve a 50-year-old open problem in the integrality gap landscape.

---

## Direction 2: Tropical Geometry of LP Integrality Gaps

**Conjecture.** The integrality gap τ/τ* of a d-uniform covering LP equals the tropical intersection number of the constraint arrangement in the tropical d-torus, and the pair codegree bound Δ₂ ≤ K constrains this intersection number to ≤ K·C(d,2).

**Test.** For d = 3, compute the tropical intersection number for 50 random linear 3-uniform hypergraphs and compare with the observed τ/τ*. Correlation > 0.9 validates the bridge.

**Impact.** Would establish a new connection between LP integrality gaps and tropical algebraic geometry, opening a geometric theory of approximation ratios.

**Catalog References.**
- `Catalog/Pythagorean/SubdIntegralityGap.lean` — integrality gap framework
- `Catalog/Pythagorean/TropicalHypergraphTransversal.lean` — tropical transversal duality (if exists)

**Proof Strategy.** The fractional transversal LP is dual to a packing LP. In tropical coordinates (taking logarithms), the LP becomes a tropical linear program. The feasibility region is a tropical polyhedron whose codimension-1 faces correspond to edges. The pair codegree constrains how many faces share a codimension-2 feature (a pair), which is exactly the tropical intersection multiplicity along that feature.

**Domain Bridges.** Tropical geometry, Newton polytopes, polyhedral combinatorics, algebraic statistics.

**Lineage.** Builds on `edge_count_bound` (Fisher inequality is the first tropical bound).

**Ambition.** Grand challenge — paradigm-shifting connection between discrete optimization and algebraic geometry.

---

## Direction 3: Higher-Order Codegree Extensions

**Conjecture.** For t ≥ 2, if the t-wise codegree Δ_t(H) ≤ K (every t-element set is contained in at most K edges), then τ(H) ≤ (d − ε_t(d,K)) · τ*(H) where ε_t(d,K) ≥ ε_2(d,K·C(d,t)/C(d,2)).

**Test.** Generate random 4-uniform hypergraphs with controlled Δ₃ ≤ 2 and measure the integrality gap. Compare with the predicted bound from the 2-codegree reduction.

**Impact.** Extends the framework to a hierarchy of local overlap conditions, each yielding progressively better integrality gap bounds.

**Catalog References.**
- `Catalog/Pythagorean/SubdIntegralityGap.lean` — pair codegree toolkit

**Proof Strategy.** For t-wise codegree, the conflict graph changes: two edges conflict if they share t or more vertices. The max degree in this graph is ≤ K·C(d,t), and greedy coloring gives χ ≤ K·C(d,t)+1. Each independent set consists of edges with pairwise intersections of size < t. By the Helly property for (t−1)-intersecting families, these can be covered more efficiently — with O(1/(d−t+1)) vertices per edge instead of O(1).

**Domain Bridges.** Extremal set theory, Turán-type problems, matroid theory.

**Lineage.** Direct generalization of `edgesSharingPair_card_bound` and `uncovered_pairwise_overlap`.

**Ambition.** Solid extension — natural next step in the hierarchy.

---

## Direction 4: Resolution Width from Integrality Gaps

**Conjecture.** If a d-CNF formula F has variable co-occurrence at most K (each pair of variables appears together in at most K clauses), then the minimum resolution refutation width is at least (d − ε(d,K)) · τ*(H_F), where H_F is the clause-variable incidence hypergraph.

**Test.** For random 3-SAT instances with controlled co-occurrence K = 2, measure resolution width experimentally using SAT solvers with proof logging, and compare with (3 − 1/12) · τ*.

**Impact.** Provides structural lower bounds on SAT solving difficulty, explaining why structured instances are easier for modern solvers.

**Catalog References.**
- `Catalog/Pythagorean/SubdIntegralityGap.lean` — integrality gap
- `Catalog/Pythagorean/ClauseSpaceTheorems.lean` — clause space complexity

**Proof Strategy.** The Ben-Sasson–Wigderson theorem relates resolution width to space, and space to the integrality gap of the covering LP on the clause hypergraph. Our sub-d gap directly translates: bounded co-occurrence ⟹ bounded pair codegree ⟹ sub-d integrality gap ⟹ sub-d resolution width.

**Domain Bridges.** Proof complexity, SAT solving, computational complexity.

**Lineage.** Extends `greedy_coloring_partition` application to proof complexity.

**Ambition.** Solid extension — concrete bridge between combinatorial optimization and proof complexity.

---

## Direction 5: Online Covering with Bounded Overlap

**Conjecture.** There exists an online algorithm for d-uniform set cover with Δ₂ ≤ K achieving competitive ratio at most d − c/(K+1), where c > 0 is an absolute constant.

**Test.** Implement the online version of layered threshold rounding (process edges in adversarial order, maintain threshold set, repair greedily) and measure competitive ratio on adversarial sequences for d = 3, K = 1, 2, 3.

**Impact.** First sub-d competitive ratio for structured online set cover, with applications to network design, scheduling, and resource allocation.

**Catalog References.**
- `Catalog/Pythagorean/SubdIntegralityGap.lean` — offline algorithm and structural bounds
- `Catalog/Pythagorean/AdaptiveOverlapRounding.lean` — adaptive rounding techniques (if exists)

**Proof Strategy.** The repair phase of layered rounding is inherently online: when a new uncovered edge arrives, add it to the conflict graph, update the coloring locally (since max degree is bounded, recoloring affects ≤ K·C(d,2) edges), and pick a repair vertex from the new edge. The competitive analysis uses the dual fitting method: maintain a feasible dual solution whose value lower-bounds τ*, then show the primal cost (number of selected vertices) is at most (d − ε) times the dual value.

**Domain Bridges.** Online algorithms, competitive analysis, network design.

**Lineage.** Online extension of `thresholdSet_isTransversal` and `independent_set_cover_bound`.

**Ambition.** Solid extension — fills a gap in the online algorithms literature.
