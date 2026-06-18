# Walk Algebra and Spectral Invariants of Theorem-Dependency Graphs

## Abstract

We develop the algebraic theory of walks in directed graphs modeling theorem-dependency networks, establishing a rigorous foundation for the spectral analysis of mathematical knowledge structure. Our central contribution is a suite of formally verified theorems connecting walk combinatorics to spectral moments: (1) the Walk Composition Theorem, proving that walk counts satisfy the multiplicative identity A^{j+k} = A^j · A^k; (2) a DAG Walk Vanishing theorem showing that all walk counts of length ≥ n vanish in DAGs on n vertices; (3) a Bipartite Closed Walk Parity result constraining odd spectral moments to zero in bipartite digraphs; and (4) the Shannon non-negativity of graph entropy for out-degree distributions. We define a novel GraphEntropy measure and prove its well-definedness. Together, these results provide the mathematical infrastructure needed to formulate and test the Spectral Universality Conjecture for proof networks.

**Keywords**: directed graph, walk algebra, spectral moment, DAG, graph entropy, theorem dependency, renormalization, coarse-graining

---

## 1. Introduction

The structure of mathematical knowledge can be modeled as a directed graph: vertices represent theorems, definitions, and lemmas, while directed edges encode proof dependencies. If theorem A uses theorem B in its proof, we draw an edge A → B. The resulting graph — the *theorem-dependency graph* — captures the logical architecture of a mathematical theory.

This paper develops the algebraic theory of walks in such graphs, with the goal of extracting spectral invariants that can be compared across different mathematical domains. Our motivation comes from an analogy with statistical mechanics: just as physical systems exhibit universality at critical points (where the spectral properties of the transfer matrix become independent of microscopic details), we conjecture that theorem-dependency graphs exhibit spectral universality as the theory matures.

### 1.1 Related Work

Graph-theoretic models of mathematical knowledge have been studied in scientometrics and knowledge representation. The spectral theory of undirected graphs is well-developed (Chung, 1997; Brouwer & Haemers, 2011), but the directed case is less understood. Renormalization group methods in graph theory have been explored in the context of complex networks (Kim et al., 2004) and community detection (Reichardt & Bornholdt, 2006). Our work is distinguished by its focus on DAGs arising from proof dependencies and the formal verification of all results.

### 1.2 Contributions

1. **Walk Composition Theorem** (Theorem 3.1): We prove that the walk count function satisfies the matrix multiplication identity, establishing the algebraic foundation for spectral moment analysis.

2. **Closed Walk Trace Identities** (Theorems 3.2–3.4): We characterize the traces of A^0, A^1, and A^2 in terms of vertex count, self-loops, and reciprocal pairs.

3. **Bipartite Closed Walk Parity** (Theorem 4.1): We prove that all closed walks in bipartite directed graphs have even length, implying vanishing of odd spectral moments.

4. **DAG Walk Vanishing** (Theorem 5.1): We prove that in a DAG on n vertices, all walk counts of length ≥ n vanish, establishing spectral finiteness.

5. **Graph Entropy** (Definition 6.1, Theorem 6.1): We define the Shannon entropy of the out-degree distribution and prove its non-negativity.

6. **Mean Degree Identity** (Theorem 7.1): We prove that the mean out-degree equals the edge density, connecting local and global statistics.

All results are formally verified in Lean 4 with Mathlib.

---

## 2. Preliminaries

### 2.1 Directed Graphs

**Definition 2.1 (DigraphOn).** A directed graph on n vertices is a pair (Fin n, adj) where adj : Fin n → Fin n → Bool satisfies adj(i, i) = false for all i (no self-loops).

**Definition 2.2.** For a digraph G on n vertices:
- The *out-degree* of vertex i is outDeg(i) = |{j : adj(i, j) = true}|.
- The *in-degree* of vertex i is inDeg(i) = |{j : adj(j, i) = true}|.
- The *edge count* is |E| = |{(i, j) : adj(i, j) = true}|.

**Definition 2.3 (DAG).** A digraph G is a *directed acyclic graph* (DAG) if there exists a function f : Fin n → ℕ such that adj(i, j) = true implies f(j) < f(i).

**Definition 2.4 (Bipartite).** A digraph G is *bipartite* if there exists a coloring color : Fin n → Bool such that adj(i, j) = true implies color(i) ≠ color(j).

### 2.2 SCC Partitions

**Definition 2.5 (SCCPartition).** An SCC partition of Fin n consists of a number of blocks m, an assignment blockOf : Fin n → Fin m, and a proof that blockOf is surjective.

**Definition 2.6 (Coarse-grain graph).** Given a digraph G and SCC partition P, the coarse-grain graph has vertices Fin m with adj(b₁, b₂) = true iff b₁ ≠ b₂ and there exist i, j with blockOf(i) = b₁, blockOf(j) = b₂, adj(i, j) = true.

---

## 3. Walk Algebra

### 3.1 Walk Count Function

**Definition 3.1 (WalkCount).** The walk count function WalkCount(G, k, u, v) counts the number of directed walks of length k from u to v:
- WalkCount(G, 0, u, v) = δ_{u,v} (Kronecker delta)
- WalkCount(G, k+1, u, v) = Σ_w WalkCount(G, k, u, w) · adj(w, v)

This recursive definition mirrors the standard construction of matrix powers: WalkCount(G, k, ·, ·) is the (·,·)-entry of A^k where A is the adjacency matrix.

### 3.2 The Walk Composition Theorem

**Theorem 3.1 (Walk Composition).** For any digraph G on n vertices and any j, k ∈ ℕ,

WalkCount(G, j + k, u, v) = Σ_w WalkCount(G, j, u, w) · WalkCount(G, k, w, v)

*Proof sketch.* By induction on k. The base case k = 0 reduces to summing against the Kronecker delta. The inductive step uses the recursive definition of WalkCount at index k+1, the induction hypothesis at index k, and the interchange of summation order (Fubini for finite sums). □

This theorem is the combinatorial analog of the matrix identity A^{j+k} = A^j · A^k. It enables the decomposition of spectral moment computations into lower-order components.

### 3.3 Trace Identities

**Definition 3.2 (Closed Walk Count).** The k-th closed walk count is

closedWalkCount(G, k) = Σ_v WalkCount(G, k, v, v) = tr(A^k)

**Theorem 3.2.** closedWalkCount(G, 0) = n.

*Proof.* Each vertex contributes 1 from the Kronecker delta. □

**Theorem 3.3.** closedWalkCount(G, 1) = 0.

*Proof.* WalkCount(G, 1, v, v) involves adj(v, v) which is false by irreflexivity. □

**Theorem 3.4.** closedWalkCount(G, 2) = |{(i,j) : adj(i,j) ∧ adj(j,i)}|.

*Proof.* By the Walk Composition Theorem with j = k = 1, WalkCount(G, 2, v, v) = Σ_w WalkCount(G, 1, v, w) · WalkCount(G, 1, w, v). Using walkCount_one, each term is (adj(v,w))·(adj(w,v)), which is 1 iff both edges exist. Summing over v gives the total count of reciprocal pairs. □

---

## 4. Bipartite Parity

**Theorem 4.1 (Bipartite Closed Walk Parity).** If G is a bipartite digraph, then for every vertex v and every k ∈ ℕ, if WalkCount(G, k, v, v) ≠ 0, then k is even.

*Proof sketch.* Let color : Fin n → Bool be the bipartite coloring. We prove the stronger claim: for any k, u, v, if WalkCount(G, k, u, v) ≠ 0, then (color(u) = color(v)) ↔ Even(k). This proceeds by induction on k:
- Base case (k = 0): WalkCount(G, 0, u, v) ≠ 0 implies u = v, so color(u) = color(v) and 0 is even.
- Inductive step (k+1): A nonzero walk of length k+1 from u to v decomposes (via the Walk Composition Theorem) into a walk of length k from u to some intermediate vertex w, followed by an edge w → v. The edge w → v forces color(w) ≠ color(v), and by the induction hypothesis, color(u) = color(w) iff k is even. Combining: color(u) = color(v) iff k is odd iff k+1 is even.

Specializing to u = v (closed walk), color(v) = color(v) is trivially true, so k must be even. □

**Corollary 4.2.** For bipartite digraphs, closedWalkCount(G, k) = 0 for all odd k.

---

## 5. DAG Walk Vanishing

### 5.1 Walk Ordering Lemma

**Lemma 5.1 (Walk Ordering).** Let G be a digraph with topological ordering f : Fin n → ℕ satisfying adj(i, j) ⟹ f(j) < f(i). If WalkCount(G, k, u, v) ≠ 0, then f(v) + k ≤ f(u).

*Proof.* By induction on k:
- k = 0: u = v, so f(v) + 0 ≤ f(u).
- k+1: There exists w with WalkCount(G, k, u, w) ≠ 0 and adj(w, v) = true. By IH, f(w) + k ≤ f(u). By the ordering, f(v) < f(w), so f(v) + 1 ≤ f(w). Combining: f(v) + k + 1 ≤ f(u). □

### 5.2 DAG Walk Length Bound

**Theorem 5.1 (DAG Walk Vanishing).** In a DAG on n vertices, WalkCount(G, k, u, v) = 0 for all k ≥ n and all u, v.

*Proof.* Given a topological ordering f from the DAG property, we construct a *rank function* g(i) = |{j : f(j) < f(i)}| that satisfies g : Fin n → {0, ..., n-1} while preserving the ordering (adj(i,j) ⟹ g(j) < g(i)). By Lemma 5.1 applied to g, any nonzero walk of length k satisfies g(v) + k ≤ g(u) < n. With k ≥ n, this yields g(v) + n ≤ g(u) < n, giving g(v) < 0 — a contradiction since g(v) ∈ ℕ. □

**Corollary 5.2 (Spectral Moment Vanishing).** In a DAG on n vertices, closedWalkCount(G, k) = 0 for all k ≥ n. The spectral signature is determined by finitely many moments.

---

## 6. Graph Entropy

### 6.1 Definition

**Definition 6.1 (Shannon Term).** For p ∈ ℝ, the Shannon entropy term is

h(p) = if p ≤ 0 then 0 else -p · log(p)

**Definition 6.2 (Degree Distribution).** For a digraph G on n vertices, the normalized out-degree distribution is

π(i) = outDeg(i) / |E| if |E| > 0, otherwise π(i) = 1/n

**Definition 6.3 (Graph Entropy).** The graph entropy is

H(G) = Σ_i h(π(i))

### 6.2 Non-negativity

**Theorem 6.1 (Shannon Term Non-negativity).** For 0 ≤ p ≤ 1, h(p) ≥ 0.

*Proof.* If p ≤ 0, h(p) = 0 by definition. If p > 0, then since p ≤ 1, we have log(p) ≤ 0 (logarithm is non-positive on (0, 1]). Thus -p · log(p) = p · (-log(p)) ≥ 0 as the product of two non-negative reals. □

---

## 7. Mean Degree and Edge Density

**Theorem 7.1 (Mean Degree Identity).** For a digraph G on n ≥ 1 vertices,

meanOutDeg(G) = |E| / n

where meanOutDeg(G) = (1/n) Σ_i outDeg(i).

*Proof.* By the directed handshaking lemma: Σ_i outDeg(i) = |E|. The identity follows by dividing both sides by n. □

---

## 8. Concrete Constructions

### 8.1 Empty Graph

The empty digraph on n vertices (no edges) has:
- Zero edge count (Theorem 8.1)
- Is trivially a DAG with any function as topological ordering (Theorem 8.2)
- Graph entropy H = log(n) (uniform distribution)

### 8.2 Complete Tournament

**Definition 8.1.** The complete tournament on n vertices is the digraph with adj(i, j) = true iff j.val < i.val.

**Theorem 8.3.** The complete tournament is a DAG with topological ordering f = Fin.val.

The complete tournament has n(n-1)/2 edges — the maximum for any DAG — and represents the extreme case of a total ordering on theorems.

---

## 9. Discussion and Future Work

### 9.1 The Spectral Universality Conjecture

Our results provide the formal infrastructure to state and test the following:

**Conjecture (Spectral Universality).** For any precision level K and renormalization scheme R, there exists a threshold N₀ such that any two DAGs with ≥ N₀ vertices, after suitable coarse-graining, have spectral moments agreeing up to level K.

The DAG Walk Vanishing theorem (Theorem 5.1) is crucial here: it ensures that the spectral signature is finite-dimensional, making comparison tractable. The Bipartite Parity theorem (Theorem 4.1) provides a structural invariant that must be preserved under any valid coarse-graining.

### 9.2 Entropy Monotonicity

A key open question is whether graph entropy is monotonically non-decreasing under coarse-graining. If true, this would provide a "thermodynamic arrow" for proof network renormalization, analogous to the second law of thermodynamics.

### 9.3 Computational Testing

The walk counting framework developed here can be implemented efficiently using matrix exponentiation. For a graph on n vertices, computing all spectral moments up to order n requires O(n^4) time using naive matrix multiplication, or O(n^{3.37}) with fast matrix multiplication. Extracting dependency graphs from Mathlib and computing their spectral signatures is the immediate next step.

---

## 10. Conclusion

We have established the algebraic foundations for spectral analysis of theorem-dependency graphs. The Walk Composition Theorem provides the algebraic backbone, the DAG Walk Vanishing theorem guarantees finite-dimensional spectral signatures, the Bipartite Parity theorem constrains moment structures, and the Graph Entropy definition measures structural complexity. Together, these results form a complete toolkit for investigating whether mathematical knowledge has universal spectral properties.

---

## References

1. Brouwer, A. E., & Haemers, W. H. (2011). *Spectra of Graphs*. Springer.
2. Chung, F. R. K. (1997). *Spectral Graph Theory*. AMS.
3. Kim, B. J., Yoon, C. N., Han, S. K., & Jeong, H. (2004). Path lengths, correlations, and centrality in temporal networks. *Physical Review E*, 65(2).
4. Shannon, C. E. (1948). A mathematical theory of communication. *Bell System Technical Journal*, 27(3), 379–423.
