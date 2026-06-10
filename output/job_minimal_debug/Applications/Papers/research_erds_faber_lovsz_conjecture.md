# Formalized Structural Theory of the Erdős–Faber–Lovász Conjecture

## Abstract

We present a comprehensive formalization of the structural theory underlying the Erdős–Faber–Lovász (EFL) conjecture. We introduce formal definitions of EFL systems (k-uniform linear hypergraphs with k edges) and general hypergraph structures, and prove 16 theorems establishing key combinatorial properties. Our results include the incidence count identity, Fisher-type pair-sharing bounds, edge injectivity, vertex set size bounds, double counting identities, degree bounds, the exclusive vertex lemma, high-degree vertex bounds, near-pencil structural analysis, the EFL conjecture for small cases (k ∈ {0, 1, 2}), and the exact vertex count for near-pencil configurations. All proofs are machine-verified and use only standard axioms.

## 1. Introduction

The Erdős–Faber–Lovász conjecture, posed in 1972, states that if k complete graphs on k vertices each pairwise share at most one vertex, then the vertices of their union can be properly colored with k colors [1]. This conjecture, resolved for sufficiently large k by Kang, Kelly, Kühn, Methuku, and Osthus in 2021 [2], has inspired extensive research in extremal combinatorics, hypergraph theory, and probabilistic methods.

In hypergraph-theoretic terms, the conjecture states: any k-uniform linear hypergraph with exactly k edges has chromatic number at most k. Here "linear" means any two edges share at most one vertex, and "k-uniform" means every edge has exactly k vertices.

### 1.1 Contributions

We contribute:

1. **Novel definitions**: A comprehensive type-theoretic framework for EFL systems and general hypergraphs, including notions of k-uniformity, intersecting families, linearity, sunflower structures, proper colorings, and chromatic number.

2. **16 verified theorems**: A complete structural analysis of EFL systems, including base cases, counting arguments, and near-pencil analysis.

3. **The exclusive vertex lemma**: A formalized proof that every edge in an EFL system with k ≥ 2 contains at least one vertex of degree exactly 1, providing a novel structural decomposition.

4. **Near-pencil geometry**: A complete analysis showing near-pencil configurations have exactly k² − k + 1 vertices, with disjoint non-center parts.

5. **Falsifiable conjecture**: We state a conjecture about the relationship between the number of degree-1 vertices and the chromatic number.

## 2. Definitions

### 2.1 EFL Systems

**Definition 2.1** (EFL System). An *EFL system* over a finite type V consists of:
- A natural number k (the uniformity parameter)
- A function `edges : Fin k → Finset V` (the edge family)
- A proof that `∀ i, (edges i).card = k` (k-uniformity)
- A proof that `∀ i j, i ≠ j → (edges i ∩ edges j).card ≤ 1` (linearity)

**Definition 2.2** (Degree). The *degree* of a vertex v in an EFL system S is:
```
deg_S(v) = |{i ∈ Fin k : v ∈ edges(i)}|
```

**Definition 2.3** (Strong Coloring). A *strong coloring* of an EFL system S is a function `c : V → Fin k` such that c is injective on each edge.

**Definition 2.4** (k-Colorability). An EFL system is *k-colorable* if there exists a strong coloring.

**Definition 2.5** (Near-Pencil). An EFL system is a *near-pencil* if all edges share a common vertex.

### 2.2 General Hypergraphs

**Definition 2.6** (Hypergraph). A *hypergraph* over V is a pair (V, E) where E ⊆ P(V) is a finite collection of finite subsets.

**Definition 2.7** (k-Uniform, Intersecting, Linear). A hypergraph is:
- *k-uniform* if every edge has exactly k vertices
- *intersecting* if every two edges share at least one vertex
- *linear* if every two distinct edges share at most one vertex

**Definition 2.8** (Sunflower). A *sunflower* in a hypergraph is a collection of edges with a common core such that distinct petals intersect exactly in the core.

## 3. Main Results

### 3.1 Counting Results

**Theorem 3.1** (Incidence Count). For any EFL system with parameter k:
```
∑ᵢ |edges(i)| = k²
```

*Proof sketch.* Each of the k edges has exactly k vertices; direct computation gives k · k = k².

**Theorem 3.2** (Double Counting Identity). For any EFL system:
```
∑_v deg(v) = k²
```

*Proof sketch.* The left side counts vertex-edge incidences by vertex; the right side counts by edge. Both equal the total incidence count. The formal proof uses `Finset.sum_comm` to swap the order of summation.

**Theorem 3.3** (Pair-Sharing Bound). For any EFL system:
```
∑ᵢ ∑_{j≠i} |edges(i) ∩ edges(j)| ≤ k(k−1)
```

*Proof sketch.* Each term |edges(i) ∩ edges(j)| ≤ 1 by linearity. There are k(k−1) ordered pairs (i,j) with i ≠ j.

### 3.2 Structural Results

**Theorem 3.4** (Degree Bound). For any vertex v: deg(v) ≤ k.

*Proof sketch.* deg(v) = |filter P (Fin.univ)| ≤ |Fin.univ| = k.

**Theorem 3.5** (Edge Injectivity for k ≥ 2). If k ≥ 2, then the edge function is injective: distinct indices give distinct edges.

*Proof sketch.* If edges(i) = edges(j) with i ≠ j, then |edges(i) ∩ edges(j)| = |edges(i)| = k ≥ 2, contradicting linearity.

**Theorem 3.6** (Vertex Set Bounds). For k > 0:
```
k ≤ |vertexSet| ≤ k²
```

*Proof sketch.* Lower bound: a single edge has k vertices, all in the vertex set. Upper bound: the vertex set is the union of k sets of size k.

**Theorem 3.7** (High-Degree Vertex Bound). The number of vertices with degree ≥ 2 is at most k(k−1)/2.

*Proof sketch.* Each high-degree vertex determines a pair of distinct edges containing it. By linearity, distinct vertices determine distinct edge pairs. The number of edge pairs is C(k,2) = k(k−1)/2.

### 3.3 The Exclusive Vertex Lemma

**Theorem 3.8** (Exclusive Vertex Lemma). For k ≥ 2, every edge contains at least one vertex of degree exactly 1.

*Proof sketch.* Consider edge i. The "shared" vertices of edge i — those appearing in at least one other edge — inject into the set of other edge indices {j : j ≠ i}. The injection sends each shared vertex v to some j ≠ i with v ∈ edges(j); this is well-defined since deg(v) ≥ 2, and injective since |edges(i) ∩ edges(j)| ≤ 1 implies at most one vertex of edge i is shared with any given edge j. Since the codomain has k−1 elements and edge i has k vertices, at least one vertex has degree 1. ∎

This result has important implications for coloring algorithms: the degree-1 vertices provide "free" coloring choices that constrain the rest of the problem.

### 3.4 Near-Pencil Analysis

**Theorem 3.9** (Near-Pencil Intersection). In a near-pencil with center v₀, for i ≠ j:
```
edges(i) ∩ edges(j) = {v₀}
```

*Proof sketch.* The intersection contains v₀ and has cardinality ≤ 1 by linearity; hence it equals {v₀}.

**Theorem 3.10** (Near-Pencil Unique Edge). In a near-pencil, every non-center vertex belongs to exactly one edge.

*Proof sketch.* If v ≠ v₀ belongs to edges i and edges j with i ≠ j, then {v, v₀} ⊆ edges(i) ∩ edges(j), giving |edges(i) ∩ edges(j)| ≥ 2, contradicting linearity.

**Theorem 3.11** (Near-Pencil Vertex Count). For k ≥ 2, a near-pencil has exactly k² − k + 1 vertices.

*Proof sketch.* The vertex set decomposes as {v₀} ∪ ⊔ᵢ (edges(i) \ {v₀}). The k disjoint sets each have k−1 elements (by Theorem 3.10), giving 1 + k(k−1) = k² − k + 1.

### 3.5 Base Cases

**Theorem 3.12** (EFL for k = 0). Any EFL system with k = 0 over an empty type is k-colorable.

**Theorem 3.13** (EFL for k = 1). Any EFL system with k = 1 is k-colorable.

*Proof sketch.* A single edge with one vertex needs only one color.

**Theorem 3.14** (EFL for k = 2). Any EFL system with k = 2 is k-colorable.

*Proof sketch.* Two 2-element edges sharing at most one vertex; exhaustive case analysis on the four overlap patterns.

## 4. The Conjecture and Open Questions

### 4.1 The EFL Conjecture

**Conjecture (EFL).** Every EFL system with parameter k is k-colorable.

This conjecture, proved for sufficiently large k by Kang–Kelly–Kühn–Methuku–Osthus [2], remains open for small finite k. Our formalization includes:
- Proofs for k ∈ {0, 1, 2}
- The full conjecture statement as a formally stated sorry

### 4.2 A Falsifiable Conjecture

**Conjecture 4.1** (Degree-1 Coloring Bound). For k ≥ 2, the number of degree-1 vertices in an EFL system is at least k. Moreover, the maximum number of degree-1 vertices is achieved by the near-pencil (with k(k−1) degree-1 vertices).

*Computational test.* Enumerate all EFL systems for k ∈ {3, 4, 5} and verify the minimum number of degree-1 vertices equals k.

### 4.3 Near-Pencil Colorability

The near-pencil colorability theorem (that near-pencil systems are k-colorable) follows from the structural analysis: the non-center parts are disjoint, so coloring reduces to independently assigning k−1 colors to k−1 elements per edge. This is stated but not yet formally verified in our framework.

## 5. Algorithms

### 5.1 Near-Pencil Coloring Algorithm

```
Input: Near-pencil EFL system S with center v₀
Output: Strong k-coloring c

1. Set c(v₀) ← 0
2. For each edge i ∈ {0, ..., k−1}:
   a. Enumerate the non-center vertices of edge i as v₁, ..., vₖ₋₁
   b. For j = 1 to k−1: set c(vⱼ) ← j
3. For any v ∉ vertexSet: set c(v) ← 0
4. Return c
```

**Correctness.** On each edge i, the coloring assigns colors {0, 1, ..., k−1} to k distinct vertices, achieving injectivity. The non-center vertices of distinct edges receive independent assignments that don't conflict because those vertices are in disjoint sets.

**Complexity.** O(k²) time, O(k²) space.

### 5.2 Greedy Coloring for General EFL Systems

```
Input: EFL system S
Output: Coloring c (possibly using more than k colors)

1. Initialize c(v) ← undefined for all v
2. Order vertices by decreasing degree
3. For each vertex v in order:
   a. Let F = {c(u) : u ∈ edge(i) for some i with v ∈ edge(i)}
   b. Set c(v) ← min({0,...,k-1} \ F)
4. Return c
```

**Analysis.** This greedy algorithm uses at most Δ + 1 colors where Δ is the maximum degree. Since Δ ≤ k for EFL systems, the greedy bound gives k + 1 colors — one more than the conjectured optimum.

## 6. Discussion

### 6.1 Relationship to Design Theory

EFL systems are closely related to *balanced incomplete block designs* (BIBDs) and *near-pencil designs*. A near-pencil is precisely a degenerate Steiner system where all blocks pass through a single point. The Fisher inequality in design theory — that the number of blocks is at least the number of points — has a direct analog in our edge bound for intersecting linear hypergraphs.

### 6.2 Probabilistic Approaches

The Kang–Kelly–Kühn–Methuku–Osthus proof [2] uses the randomized nibble method:

1. **Semi-random process**: Color most vertices using a random process, controlled to maintain near-uniform distributions.
2. **Absorption**: Show that the uncolored vertices can be handled by a deterministic cleanup step.
3. **Regularity**: Use a form of hypergraph regularity to control the random process.

Our structural results (especially the exclusive vertex lemma and degree bounds) provide the deterministic infrastructure on which such probabilistic arguments can be built.

### 6.3 Computational Complexity

Determining whether a hypergraph can be properly colored with k colors is NP-hard in general. However, the strong structural constraints of EFL systems (linearity, k-uniformity, exactly k edges) suggest that coloring EFL systems might be polynomial-time solvable. This remains open.

## 7. Future Work

1. **Complete the near-pencil colorability proof** by formalizing the piecewise coloring construction.
2. **Prove the linear intersecting edge bound** (|E| ≤ k² − k + 1) for general k-uniform linear intersecting hypergraphs.
3. **Extend to k = 3, 4, 5** using case analysis or computational methods.
4. **Formalize the absorption method** from the Kang et al. proof.
5. **Explore connections to tropical geometry** and chromatic polynomials.

## References

[1] P. Erdős, "Problems and results in graph theory and combinatorics," *Proceedings of the Fifth British Combinatorial Conference*, 1975.

[2] D. Y. Kang, T. Kelly, D. Kühn, A. Methuku, and D. Osthus, "A proof of the Erdős–Faber–Lovász conjecture," *Annals of Mathematics*, vol. 198, no. 2, pp. 537–618, 2023.

[3] J. Kahn, "Coloring nearly-disjoint hypergraphs with n + o(n) colors," *Journal of Combinatorial Theory, Series A*, vol. 59, pp. 31–39, 1992.

[4] C. Berge, *Hypergraphs: Combinatorics of Finite Sets*, North-Holland, 1989.

## Appendix: Theorem Summary

| # | Theorem | File | Status |
|---|---------|------|--------|
| 1 | incidence_count_eq_sq | Theorems.lean | ✓ Proved |
| 2 | pairwise_intersection_sum_bound | Theorems.lean | ✓ Proved |
| 3 | efl_zero | Theorems.lean | ✓ Proved |
| 4 | degree_le_k | Theorems.lean | ✓ Proved |
| 5 | edges_injective_of_k_ge_two | Theorems.lean | ✓ Proved |
| 6 | vertexSet_card_ge_k | Theorems.lean | ✓ Proved |
| 7 | vertexSet_card_le_sq | Theorems.lean | ✓ Proved |
| 8 | degree_sum_eq_incidence | Theorems.lean | ✓ Proved |
| 9 | efl_one | Theorems.lean | ✓ Proved |
| 10 | vertexSet_nonempty | Theorems.lean | ✓ Proved |
| 11 | high_degree_vertex_bound | Theorems.lean | ✓ Proved |
| 12 | near_pencil_inter_eq_singleton | Advanced.lean | ✓ Proved |
| 13 | near_pencil_unique_edge | Advanced.lean | ✓ Proved |
| 14 | near_pencil_erase_card | Advanced.lean | ✓ Proved |
| 15 | efl_two | Advanced.lean | ✓ Proved |
| 16 | edge_has_exclusive_vertex | Advanced.lean | ✓ Proved |
| 17 | near_pencil_vertexSet_card | Advanced.lean | ✓ Proved |
| 18 | linear_intersecting_edge_bound | Theorems.lean | □ Open |
| 19 | near_pencil_colorable | Theorems.lean | □ Open |
| 20 | efl_conjecture | Theorems.lean | □ Open |
