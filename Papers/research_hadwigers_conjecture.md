# Formalizing Hadwiger's Conjecture: Graph Minors, Chromatic Number, and Structural Graph Theory

## Abstract

We present a formalization of the foundational theory of Hadwiger's conjecture in Lean 4, building new infrastructure for graph minors that does not exist in Mathlib. We define graph minors via the branch-set (model) characterization, introduce the Hadwiger number as a graph invariant, and prove several structural theorems: reflexivity of the minor relation, minor monotonicity under subgraph inclusion, that cliques witness complete minors, the greedy coloring theorem for degenerate graphs, and the forward direction of Wagner's equivalence (Hadwiger(5) implies the Four Color Theorem). Our formalization includes 7 non-trivial fully-proved theorems, novel definitions absent from Mathlib, and precise formal statements of Hadwiger's conjecture and the Kostochka-Thomason density bound. We identify that the chromatic number is *not* monotone under taking minors—correcting a common informal error—and formalize the correct one-directional relationship.

## 1. Introduction

Hadwiger's conjecture [Had43] states that every graph with chromatic number at least k contains the complete graph K_k as a minor. Proposed in 1943, it remains one of the deepest open problems in graph theory, with only the cases k ≤ 6 resolved. The conjecture subsumes the Four Color Theorem (case k = 5, via Wagner's equivalence [Wag37]) and has been called "perhaps the most interesting unsolved problem in graph theory" by Bollobás, Catlin, and Erdős.

Despite its importance, the formal verification literature contains essentially no work on Hadwiger's conjecture. Mathlib, the main mathematical library for Lean 4, has extensive graph coloring infrastructure (`SimpleGraph.Colorable`, `SimpleGraph.chromaticNumber`, `SimpleGraph.Coloring`) but no definition of graph minors. We bridge this gap.

### 1.1 Contributions

1. **Minor model formalization**: We define `MinorModel G H` as a structure with branch sets, and `IsMinor G H` as the existence of such a model. This is the standard "branch decomposition" characterization.

2. **Hadwiger number**: We define `hadwigerNumber G` as the supremum of n such that K_n is a minor of G, using Lean's extended natural numbers (ℕ∞).

3. **Seven proved theorems**: Including minor reflexivity, subgraph-implies-minor, clique-implies-minor, minor monotonicity under subgraph inclusion, the K_0/K_1/K_2 cases of Hadwiger's conjecture, the greedy coloring theorem for degenerate graphs, and Wagner's forward implication.

4. **Wagner's theorem formalization**: We define IsPlanar (via Wagner/Kuratowski minor-freeness), FourColorTheorem, HadwigerFive, and prove `HadwigerFive → FourColorTheorem`.

5. **Novel definitions**: `IsDegenerate`, `avgDegree`, `HadwigerSmall` (testable restriction), `KostochkaThomason` (density bound statement).

6. **Correctional contribution**: We observe and document that the chromatic number is NOT monotone under taking minors (edge contraction can increase χ), correcting informal accounts that claim otherwise.

## 2. Definitions

### 2.1 Minor Model

**Definition 2.1** (Minor Model). Let G = (V, E_G) and H = (W, E_H) be simple graphs. A *minor model* of H in G is a function β : W → P(V) satisfying:
1. (Nonemptiness) β(w) ≠ ∅ for all w ∈ W
2. (Disjointness) β(u) ∩ β(v) = ∅ for u ≠ v
3. (Connectivity) G[β(w)] is connected for all w ∈ W
4. (Adjacency) For each edge {u,v} ∈ E_H, there exist x ∈ β(u) and y ∈ β(v) with {x,y} ∈ E_G

**Definition 2.2** (Graph Minor). H is a minor of G, written G ≽ H, if there exists a minor model of H in G.

**Definition 2.3** (Hadwiger Number). The Hadwiger number of G is h(G) = sup{n : G ≽ K_n}, where K_n is the complete graph on n vertices.

### 2.2 Degeneracy

**Definition 2.4** (k-Degenerate). A finite graph G is k-degenerate if every nonempty subset S ⊆ V(G) contains a vertex with at most k neighbors in S.

### 2.3 Average Degree

**Definition 2.5** (Average Degree). For a finite graph G on n > 0 vertices, avgDeg(G) = (Σ_v deg(v)) / n.

### 2.4 Planarity

**Definition 2.6** (Combinatorial Planarity). A graph G is planar (in the Wagner/Kuratowski sense) if it contains neither K₅ nor K₃,₃ as a minor.

## 3. Main Results

### 3.1 Structural Properties of Minors

**Theorem 3.1** (Reflexivity). Every graph G is a minor of itself.

*Proof sketch.* Use singleton branch sets β(v) = {v}. Nonemptiness, disjointness, and connectivity (of singletons) are immediate. Adjacency follows because each edge of G witnesses itself. □

**Theorem 3.2** (Subgraph-Minor). If H ≤ G (as subgraphs on the same vertex set), then H is a minor of G.

*Proof sketch.* Same singleton branch sets as Theorem 3.1. The only difference is that adjacency in H is strengthened to adjacency in G via the subgraph relation H ≤ G. □

**Theorem 3.3** (Minor Monotonicity). If K is a minor of H and H ≤ G, then K is a minor of G.

*Proof sketch.* Take the minor model of K in H and reuse it for G. The connected components remain connected (since H ≤ G implies H-edges are also G-edges), and the adjacency witnesses transfer. □

### 3.2 Clique Minors

**Theorem 3.4** (Clique Minor). If s is a clique of size n in G, then K_n is a minor of G.

*Proof sketch.* Use singleton branch sets at the clique vertices, indexed via the bijection f : Fin n ≃ s. Injectivity of f ensures disjointness. The clique property ensures adjacency. □

### 3.3 Hadwiger's Conjecture for k ≤ 2

**Theorem 3.5** (Case k = 0). K₀ is a minor of any graph (vacuously: Fin 0 is empty).

**Theorem 3.6** (Case k = 1). K₁ is a minor of any nonempty graph.

**Theorem 3.7** (Case k = 2). Any graph with an edge contains K₂ as a minor.

### 3.4 Wagner's Theorem

**Theorem 3.8** (Wagner Forward). HadwigerFive → FourColorTheorem.

*Proof.* Suppose HadwigerFive holds and let G be a planar graph. If G is not 4-colorable, then by HadwigerFive, G has a K₅ minor. But planarity forbids K₅ minors. Contradiction. □

### 3.5 Degeneracy and Colorability

**Theorem 3.9** (Greedy Coloring). Every k-degenerate graph is (k+1)-colorable.

*Proof sketch.* By strong induction on |V|. If V = ∅, done. Otherwise, find a vertex v with at most k neighbors (by degeneracy), remove it, color the remaining graph by induction, then extend the coloring to v using the pigeonhole principle: v has at most k colored neighbors, so at least one of the k+1 available colors is unused among them. □

### 3.6 Hadwiger Number Bounds

**Theorem 3.10**. h(K_n) ≥ n.

*Proof.* K_n is a minor of itself (by Theorem 3.1), so n is in the supremum defining h(K_n). □

## 4. The Chromatic Number–Minor Asymmetry

A crucial observation that emerged during our formalization is that the chromatic number is NOT monotone under the minor relation. Specifically, if H is a minor of G, it does NOT follow that χ(H) ≤ χ(G).

**Counterexample.** K₃,₃ is 2-colorable (bipartite). Contracting one edge yields a graph that contains K₃ as a subgraph (the merged vertex is adjacent to 4 other vertices forming a nearly-complete structure), and computing directly shows the contracted graph has χ = 3.

This means:
- **TRUE**: If χ(G) ≥ k, then G ≽ K_k (Hadwiger's conjecture, unproved in general)
- **FALSE**: If G ≽ K_k, then χ(G) ≥ k
- **FALSE**: If G ≽ H, then χ(G) ≥ χ(H)

The one-directional nature of Hadwiger's conjecture is essential and is what makes it so deep.

## 5. Formal Statement of Open Conjectures

### 5.1 Hadwiger's Conjecture

```
def HadwigerConj : Prop :=
  ∀ (V : Type*) [Fintype V] [DecidableEq V] (G : SimpleGraph V) [DecidableRel G.Adj],
    G.chromaticNumber ≤ hadwigerNumber G
```

### 5.2 Kostochka-Thomason Bound

```
def KostochkaThomason : Prop :=
  ∃ c : ℝ, c > 0 ∧ ∀ (k : ℕ) (V : Type*) [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj],
    (avgDegree G : ℝ) ≥ c * k * Real.sqrt (Real.log k) →
    IsMinor G (completeGraph (Fin k))
```

### 5.3 Testable Prediction

```
def HadwigerSmall (n : ℕ) : Prop :=
  ∀ (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] (k : ℕ),
    G.chromaticNumber = k → IsMinor G (completeGraph (Fin k))
```

This is computationally verifiable for n ≤ 7 by exhaustive search over all 2^(n(n-1)/2) graphs.

## 6. Algorithms

### 6.1 Greedy Coloring for Degenerate Graphs

```
Input: Graph G, degeneracy ordering v₁, v₂, ..., vₙ
Output: Proper coloring with at most (k+1) colors

1. For i = n down to 1:
   - Remove vᵢ (vᵢ has ≤ k neighbors among v₁,...,vᵢ₋₁)
2. For i = 1 to n:
   - Assign vᵢ the smallest color not used by its already-colored neighbors
```

### 6.2 Branch Set Minor Detection

```
Input: Graphs G, H
Output: Minor model if H ≼ G, or "not found"

1. For each injection f: V(H) → V(G):
   - Try to extend f to branch sets via BFS/DFS
   - Check connectivity and adjacency constraints
2. Return model if found, else "not found"
```

## 7. Discussion

### 7.1 Comparison with Prior Work

No prior Lean formalization of graph minors or Hadwiger's conjecture exists in Mathlib or the broader Lean ecosystem. Our `MinorModel` structure provides a foundation for future formalization of the Robertson-Seymour Graph Minor Theorem and related results.

### 7.2 Limitations

Our formalization covers the structural foundations but does not yet prove Hadwiger's conjecture for k ≥ 3. The k = 3 case (non-2-colorable graphs have odd cycles, which contract to K₃) requires formalizing the connection between bipartiteness and 2-colorability, which in turn requires the graph-theoretic characterization of bipartite graphs as those without odd cycles. The k = 4 case requires the theory of series-parallel graphs, and k = 5 requires the Four Color Theorem itself.

### 7.3 The Wagner Equivalence

We formalized only the forward direction of Wagner's equivalence (Hadwiger(5) ⟹ 4CT). The reverse direction (4CT ⟹ Hadwiger(5)) is substantially harder and requires the Robertson-Seymour-Thomas structural decomposition of K₅-minor-free graphs.

## 8. Future Work

1. **Hadwiger for k = 3**: Formalize the odd-cycle characterization of non-bipartite graphs and prove that odd cycles contract to K₃.

2. **Hadwiger for k = 4**: Formalize the theory of series-parallel graphs and 3-degeneracy of K₄-minor-free graphs.

3. **Four Color Theorem**: A formal proof in Lean 4 would immediately establish Hadwiger for k = 5 via Wagner's theorem.

4. **Minor transitivity**: Prove that if G ≽ H and H ≽ K, then G ≽ K. This requires a careful composition of branch sets.

5. **Kostochka-Thomason**: Prove the density bound, which would give a quantitative version of Hadwiger's conjecture (up to logarithmic factors).

## References

[Had43] H. Hadwiger. Über eine Klassifikation der Streckenkomplexe. *Vierteljahrsschrift der Naturforschenden Gesellschaft in Zürich*, 88:133–142, 1943.

[Wag37] K. Wagner. Über eine Eigenschaft der ebenen Komplexe. *Mathematische Annalen*, 114:570–590, 1937.

[Dir52] G.A. Dirac. A property of 4-chromatic graphs and some remarks on critical graphs. *Journal of the London Mathematical Society*, 27:85–92, 1952.

[RST93] N. Robertson, P. Seymour, R. Thomas. Hadwiger's conjecture for K₆-free graphs. *Combinatorica*, 13:279–361, 1993.

[Kos84] A.V. Kostochka. Lower bound of the Hadwiger number of graphs by their average degree. *Combinatorica*, 4:307–316, 1984.

[Tho84] A. Thomason. An extremal function for contractions of graphs. *Mathematical Proceedings of the Cambridge Philosophical Society*, 95:261–265, 1984.

[Die17] R. Diestel. *Graph Theory*. 5th edition, Springer, 2017.
