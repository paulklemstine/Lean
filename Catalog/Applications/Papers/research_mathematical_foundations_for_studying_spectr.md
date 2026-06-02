# Spectral Theory of Theorem Dependency Graphs: Walk Algebra, Degree Invariants, and Renormalization

## Abstract

We develop the spectral theory of directed graphs modeling theorem dependency networks in formal mathematical libraries. Working with directed graphs on finite vertex sets, we formalize walk counting via matrix-power recursion, establish the walk composition theorem (A^{k+l} = A^k · A^l at the entry level), prove that closed walks of positive length vanish in DAGs, and show that DAG walk lengths are bounded by the number of vertices. We introduce degree variance as a spectral invariant that characterizes hub structure, prove its non-negativity via a Cauchy-Schwarz inequality, and show that zero variance characterizes regular graphs. For coarse-graining via partition quotients, we prove edge preservation, edge count bounds, and stabilization of iterated coarse-graining chains. We define a spectral distance metric on moment sequences and state a refined spectral universality conjecture for theorem dependency graphs. All results are formalized in Lean 4 with complete machine-checked proofs.

**Keywords**: spectral graph theory, directed graphs, walk counting, degree variance, coarse-graining, renormalization, theorem dependency graphs, formal verification

---

## 1. Introduction

The logical structure of mathematical knowledge forms a directed acyclic graph (DAG): theorems depend on lemmas, which depend on definitions, which depend on axioms. This *theorem dependency graph* is implicit in every mathematical library and becomes explicit in formal proof systems where every dependency is tracked.

Recent work in the philosophy and sociology of mathematics has begun studying these dependency graphs empirically, asking questions about centrality, depth, and modularity. However, the *spectral* properties of theorem dependency graphs — the eigenvalues and eigenvectors of their adjacency matrices — remain largely unexplored.

We develop a rigorous mathematical framework for spectral analysis of theorem dependency graphs, inspired by two sources:

1. **Spectral graph theory** (Chung 1997, Cvetković et al. 2010), which relates graph topology to matrix spectra.
2. **Renormalization group theory** (Wilson 1971, Kadanoff 1966), where coarse-graining operations reveal universal fixed-point structure.

The central hypothesis is the *Spectral Universality Conjecture*: mature mathematical theories, despite differing in content, share a common spectral fingerprint detectable through their dependency graph structure.

### 1.1 Contributions

We make the following contributions, all formalized in Lean 4:

1. **Walk counting algebra** (§3): Recursive definition of walk counts and proof of the composition theorem.
2. **DAG spectral vanishing** (§4): All closed walks of positive length vanish in DAGs; all walks of length ≥ n vanish.
3. **Degree variance theory** (§5): Cauchy-Schwarz inequality for degrees, non-negativity of variance, characterization of regular graphs.
4. **Coarse-graining theory** (§6): Quotient graph construction, edge bounds, cross-edge preservation, chain stabilization.
5. **Spectral distance** (§7): Metric on moment sequences with symmetry and zero-characterization.

---

## 2. Preliminaries

### 2.1 Directed Graphs

**Definition 2.1** (DGraph). A *directed graph on n vertices* is a pair (V, E) where V = Fin n and E ⊆ V × V is an irreflexive relation (no self-loops). We represent E by a Boolean-valued adjacency function `adj : Fin n → Fin n → Bool` with `adj(i, i) = false` for all i.

**Definition 2.2** (Degrees). The *out-degree* of vertex i is `outDeg(i) = |{j : adj(i,j) = true}|` and the *in-degree* is `inDeg(i) = |{j : adj(j,i) = true}|`.

**Definition 2.3** (DAG). A directed graph is a *DAG* if there exists a function f : Fin n → ℕ such that adj(i,j) = true implies f(j) < f(i). (Topological ordering by strictly decreasing values.)

### 2.2 Adjacency Numerics

**Definition 2.4**. The *adjacency integer* is `adjNat(i,j) = 1` if `adj(i,j)` and `0` otherwise.

---

## 3. Walk Counting Algebra

### 3.1 Walk Count Definition

**Definition 3.1** (Walk count). The number of directed walks of length k from vertex i to vertex j is defined recursively:

```
walkCount(0, i, j) = δ_{ij}
walkCount(k+1, i, j) = Σ_w walkCount(k, i, w) · adjNat(w, j)
```

This corresponds to the (i,j) entry of the matrix power A^k, where A is the adjacency matrix.

**Definition 3.2** (Closed walk count). The *k-th closed walk count* is the trace:

```
closedWalkCount(k) = Σ_i walkCount(k, i, i)
```

### 3.2 Basic Properties

**Theorem 3.3** (Walk count at zero).
- `walkCount(0, i, i) = 1` for all i.
- `walkCount(0, i, j) = 0` for i ≠ j.
- `closedWalkCount(0) = n`.

*Proof.* Direct from the definition. □

**Theorem 3.4** (Closed walks of length 1 vanish).
`closedWalkCount(1) = 0`.

*Proof.* Each diagonal entry `walkCount(1, i, i) = adjNat(i, i) = 0` by irreflexivity. □

### 3.3 Walk Composition Theorem

**Theorem 3.5** (Walk Composition). For all k, l ∈ ℕ and vertices i, j:

```
walkCount(k + l, i, j) = Σ_w walkCount(k, i, w) · walkCount(l, w, j)
```

*Proof sketch.* By induction on l. The base case l = 0 uses the fact that `walkCount(0, w, j) = δ_{wj}`, so the sum collapses to `walkCount(k, i, j)`. The inductive step uses the definition of `walkCount(l+1, ·, ·)` and the interchange of summation order:

```
walkCount(k + (l+1), i, j)
  = Σ_w walkCount(k+l, i, w) · adjNat(w, j)
  = Σ_w (Σ_v walkCount(k, i, v) · walkCount(l, v, w)) · adjNat(w, j)  [by IH]
  = Σ_v walkCount(k, i, v) · (Σ_w walkCount(l, v, w) · adjNat(w, j))
  = Σ_v walkCount(k, i, v) · walkCount(l+1, v, j)
```

□

**Theorem 3.6** (Closed walks of length 2 count mutual edges).

```
closedWalkCount(2) = |{(i,j) : adj(i,j) ∧ adj(j,i)}|
```

*Proof sketch.* By expanding `walkCount(2, i, i) = Σ_w adjNat(i, w) · adjNat(w, i)`, each nonzero term corresponds to a mutual edge pair. Summing over i and collecting pairs gives the cardinality of the mutual edge set. □

---

## 4. DAG Spectral Theory

### 4.1 Walk Vanishing

**Theorem 4.1** (DAG closed walk vanishing). If G is a DAG, then `closedWalkCount(k) = 0` for all k > 0.

*Proof sketch.* Let f be the topological ordering. We show by induction on k that `walkCount(k, i, j) > 0` implies `f(j) + k ≤ f(i)`. For a closed walk (i = j), this gives `f(i) + k ≤ f(i)`, which is impossible for k > 0. □

### 4.2 Walk Length Bound

**Theorem 4.2** (DAG walk length bound). If G is a DAG on n vertices, then `walkCount(k, i, j) = 0` for all k ≥ n and all vertices i, j.

*Proof sketch.* If `walkCount(k, i, j) > 0`, there exists a walk v₀, v₁, ..., v_k with v₀ = i, v_k = j. In a DAG, the topological ordering is strictly decreasing along the walk, making the map from {0, ..., k} → Fin n injective. By pigeonhole, k + 1 ≤ n, so k < n. □

**Corollary 4.3.** The adjacency matrix of a DAG on n vertices is nilpotent: A^n = 0.

---

## 5. Degree Variance Theory

### 5.1 Handshaking

**Theorem 5.1** (Directed handshaking). `Σ_i outDeg(i) = edgeCount = Σ_i inDeg(i)`.

*Proof.* The sum of out-degrees counts edges by their source; the edge count counts edges directly; the sum of in-degrees counts edges by their target. □

### 5.2 Cauchy-Schwarz for Degrees

**Theorem 5.2** (Cauchy-Schwarz for degree sequences).

```
n · Σ_i outDeg(i)² ≥ (Σ_i outDeg(i))²
```

*Proof sketch.* This is the standard Cauchy-Schwarz inequality applied to the sequence (outDeg(i))_i and the constant sequence (1)_i. Equivalently, it follows from the non-negativity of Σ_{i<j} (outDeg(i) - outDeg(j))². □

### 5.3 Degree Variance

**Definition 5.3** (Degree variance). For a graph on n > 0 vertices:

```
Var(d) = (1/n) · Σ_i outDeg(i)² - ((1/n) · Σ_i outDeg(i))²
```

**Theorem 5.4** (Non-negativity). `Var(d) ≥ 0`.

*Proof.* Follows from Theorem 5.2: `Var(d) = (n · Σd² - (Σd)²) / n²`, and the numerator is non-negative by Cauchy-Schwarz. □

**Theorem 5.5** (Regularity characterization). `Var(d) = 0` if and only if all out-degrees are equal.

*Proof sketch.* Forward: Var(d) = 0 implies Σ(d_i - mean)² = 0, so each d_i = mean. Backward: if all d_i = c, then mean = c and each squared deviation is 0. □

---

## 6. Coarse-Graining Theory

### 6.1 Partitions

**Definition 6.1** (Partition). A *partition* of Fin n into Fin m is a surjective function `blockOf : Fin n → Fin m`.

**Theorem 6.2** (Block size sum). `Σ_b blockSize(b) = n`.

**Theorem 6.3** (Non-empty blocks). Every block has positive size.

**Theorem 6.4** (Pigeonhole). If m < n, some block has size ≥ 2.

### 6.2 Quotient Graphs

**Definition 6.5** (Quotient graph). Given a graph G and partition P, the quotient graph has:
- Vertices: Fin m (the blocks)
- Edge b₁ → b₂ iff b₁ ≠ b₂ and ∃ i ∈ b₁, j ∈ b₂ with adj(i,j)

**Theorem 6.6** (Edge bound). The quotient graph has at most m(m-1) edges.

*Proof.* Every edge connects distinct blocks, and there are m(m-1) ordered pairs of distinct blocks. □

**Theorem 6.7** (Cross-edge preservation). If adj(i,j) and blockOf(i) ≠ blockOf(j), then the quotient has edge blockOf(i) → blockOf(j).

### 6.3 Chain Stabilization

**Definition 6.8** (Coarse-graining chain). A sequence of vertex counts `vertexCount : ℕ → ℕ` with `vertexCount(k+1) ≤ vertexCount(k)` for all k.

**Theorem 6.9** (Stabilization). Every coarse-graining chain eventually stabilizes: there exists K such that `vertexCount(k+1) = vertexCount(k)` for all k ≥ K.

*Proof.* The sequence is antitone and ℕ-valued, hence bounded below. By the well-ordering principle, it achieves its infimum, after which it must remain constant. □

**Theorem 6.10** (Drop bound). If all steps j < k are strict decreases, then `vertexCount(k) + k ≤ vertexCount(0)`.

*Proof.* By induction on k: each strict decrease reduces the value by at least 1. □

---

## 7. Spectral Distance

**Definition 7.1** (Spectral distance). For moment sequences μ, ν and truncation level K:

```
d_K(μ, ν) = max_{k ≤ K} |μ(k) - ν(k)|
```

**Theorem 7.2** (Symmetry). `d_K(μ, ν) = d_K(ν, μ)`.

**Theorem 7.3** (Zero characterization). `d_K(μ, ν) = 0 ↔ ∀k ≤ K, μ(k) = ν(k)`.

---

## 8. The Spectral Universality Conjecture

**Conjecture 8.1** (Spectral Universality). For any ε > 0 and moment level K, there exists N₀ such that any two "natural" theorem dependency DAGs with at least N₀ vertices have spectral distance less than ε after suitable coarse-graining.

The conjecture is stated formally in the Lean development as `RefinedSpectralUniversality`. The key challenge is defining "natural" — we expect it requires conditions on degree distribution regularity and bounded-depth structure.

---

## 9. Discussion

### 9.1 Connection to Renormalization

The coarse-graining operation on theorem dependency graphs is formally analogous to block-spin renormalization in statistical mechanics. The stabilization theorem (Theorem 6.9) plays the role of the existence of a renormalization group fixed point. The spectral moments serve as "coupling constants" whose flow under coarse-graining is tracked by the spectral distance.

The critical difference from physical renormalization is that our graphs are finite and the coarse-graining is deterministic, whereas physical systems typically involve infinite lattices and statistical averaging. Nevertheless, the structural parallel is precise enough to guide the formulation of universality conjectures.

### 9.2 Computational Aspects

All definitions in this paper are constructive and computable. Walk counting has time complexity O(n^(k+1)) via the recursive definition but can be accelerated to O(n³ log k) via matrix exponentiation. SCC computation runs in O(n + m) time via Tarjan's algorithm. The spectral distance computation is linear in K after moments are computed.

### 9.3 Relation to Existing Work

The degree variance characterization (Theorem 5.5) is a directed-graph analog of the classical result that a graph is regular iff its adjacency matrix has a single largest eigenvalue equal to the degree. The walk vanishing theorem (Theorem 4.1) is well-known but our formalization provides the precise quantitative bound (Theorem 4.2) via topological ordering.

---

## 10. Future Work

1. **Empirical testing**: Compute spectral moments of Mathlib dependency graphs across mathematical domains and measure spectral distances after coarse-graining.
2. **Entropy monotonicity**: Prove or disprove that Shannon entropy of the degree distribution is non-decreasing under coarse-graining.
3. **Spectral gap bounds**: Relate the degree variance to the spectral gap of the normalized Laplacian.
4. **Category-theoretic formulation**: Express coarse-graining as a functor between graph categories and study its categorical properties.

---

## References

- Chung, F. R. K. *Spectral Graph Theory*. CBMS Regional Conference Series, AMS, 1997.
- Cvetković, D., Rowlinson, P., Simić, S. *An Introduction to the Theory of Graph Spectra*. Cambridge University Press, 2010.
- Kadanoff, L. P. "Scaling laws for Ising models near T_c." *Physics* 2(6), 263–272, 1966.
- Wilson, K. G. "Renormalization Group and Critical Phenomena." *Physical Review B* 4(9), 3174–3183, 1971.
- Tarjan, R. "Depth-first search and linear graph algorithms." *SIAM J. Comput.* 1(2), 146–160, 1972.
