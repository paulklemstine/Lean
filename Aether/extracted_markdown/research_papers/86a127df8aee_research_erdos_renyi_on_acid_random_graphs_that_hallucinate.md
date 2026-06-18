# Spectral Theory of Complex-Weighted Random Graphs: Collinearity, Normality, and the Failure of the Circular Law

## Abstract

We develop the spectral theory of complex-weighted graphs G(n, z), where each edge carries a uniform complex weight z ∈ ℂ. We prove that the adjacency matrix A_z factors as z · B, where B is the {0,1} Boolean adjacency matrix (Theorem 1), and derive five main consequences:

1. **Normality** (Theorem 4): A_z is always a normal matrix, hence unitarily diagonalizable.
2. **Spectral Collinearity** (Theorem 6): All eigenvalues of A_z lie on a single line through the origin in ℂ.
3. **Walk Phase Accumulation** (Theorem 5): The k-th matrix power satisfies A_z^k = z^k · B^k.
4. **Eigenvector Inheritance** (Theorem 7): Every eigenvector of B is an eigenvector of A_z with eigenvalue scaled by z.
5. **Frobenius-Topology Identity** (Theorem 8): tr(A_z* · A_z) = |z|² · |E_directed|.

These results demonstrate that the circular law prediction for complex-weighted random graphs fails in the symmetric (undirected) case, while remaining valid for directed graphs. All results have been formally verified in Lean 4 with Mathlib.

**Keywords**: complex weighted graphs, spectral graph theory, random matrix theory, circular law, normal matrices, Erdős-Rényi model

---

## 1. Introduction

### 1.1 Motivation

The Erdős-Rényi random graph G(n, p) is the foundational model of random graph theory. Each of the $\binom{n}{2}$ possible edges appears independently with probability p, generating a rich landscape of phase transitions as p varies. The spectral theory of these random graphs — the study of eigenvalues of their adjacency matrices — connects graph theory to random matrix theory through Wigner's semicircle law and its variants.

A natural extension is to consider complex-valued edge weights. In quantum information theory, graph states are defined via adjacency matrices with complex entries. In signal processing on graphs, Fourier analysis requires complex-valued graph operators. In mathematical physics, transfer matrices of lattice models naturally have complex entries.

We define the **complex weighted graph** G(n, z) for z ∈ ℂ: an undirected simple graph on n vertices where each present edge carries weight z and each absent edge carries weight 0. The adjacency matrix A_z has entries z or 0.

### 1.2 The Circular Law Hypothesis

Given the success of the circular law for random matrices with i.i.d. complex entries (Ginibre 1965, Tao-Vu 2010), one might conjecture that the empirical spectral distribution of A_z converges to a uniform distribution on a disk of radius |z| · √(p(1-p)) · √n. This is the "circular law hypothesis" for complex-weighted random graphs.

**Our main result is that this hypothesis is false for undirected graphs.** The symmetry constraint forces the eigenvalue distribution to collapse from a 2D disk onto a 1D line segment. We provide a complete explanation via the scalar factorization A_z = z · B and the resulting normality of A_z.

### 1.3 Organization

Section 2 presents definitions. Section 3 proves the scalar factorization and its immediate consequences. Section 4 establishes normality. Section 5 develops the spectral collinearity theory. Section 6 treats walk phase accumulation. Section 7 discusses the Frobenius norm identity. Section 8 examines when the circular law does apply (directed graphs). Section 9 discusses applications and open problems.

---

## 2. Definitions

### Definition 2.1 (Complex Weighted Graph)

A **complex weighted graph** G = (n, z, E) consists of:
- A positive integer n (number of vertices, indexed by Fin n)
- A complex number z ∈ ℂ (the edge weight)
- A symmetric, irreflexive Boolean function E : Fin n × Fin n → {0, 1}

The **Boolean adjacency matrix** is B ∈ M_n(ℂ) with B_{ij} = E(i,j).

The **complex adjacency matrix** is A_z ∈ M_n(ℂ) with (A_z)_{ij} = z · E(i,j).

### Definition 2.2 (Edge Pair Count)

The **directed edge pair count** is |E_dir| = |{(i,j) : E(i,j) = 1}|. For symmetric E, |E_dir| = 2|E|.

### Definition 2.3 (Vertex Degree)

The **degree** of vertex i is deg(i) = |{j : E(i,j) = 1}|.

### Definition 2.4 (Spectral Collinearity)

A matrix M ∈ M_n(ℂ) has **collinear spectrum** with direction w ∈ ℂ if there exists a Hermitian matrix H ∈ M_n(ℂ) such that M = w · H.

### Definition 2.5 (Directed Complex Graph)

A **directed complex graph** is defined as above but without the symmetry requirement on E. This is the setting where the circular law applies.

---

## 3. The Scalar Factorization

### Theorem 1 (Scalar Factorization)

For any complex weighted graph G = (n, z, E),
$$A_z = z \cdot B$$

*Proof.* For each (i,j), $(A_z)_{ij} = z \cdot E(i,j) = z \cdot B_{ij} = (z \cdot B)_{ij}$. □

### Theorem 2 (Trace Identity)

$$\mathrm{tr}(A_z) = 0$$

*Proof.* $\mathrm{tr}(A_z) = \sum_i (A_z)_{ii} = \sum_i z \cdot E(i,i) = \sum_i z \cdot 0 = 0$ by irreflexivity. □

### Theorem 3 (Hermitianness of B)

The Boolean adjacency matrix satisfies $B^* = B$.

*Proof.* $(B^*)_{ij} = \overline{B_{ji}} = \overline{E(j,i)} = E(j,i) = E(i,j) = B_{ij}$ using symmetry of E and the fact that E(j,i) ∈ {0,1} ⊂ ℝ. □

### Corollary 3.1 (Conjugate Transpose of A_z)

$$A_z^* = \bar{z} \cdot B$$

*Proof.* $A_z^* = (z \cdot B)^* = \bar{z} \cdot B^* = \bar{z} \cdot B$. □

---

## 4. Normality

### Theorem 4 (Normality of A_z)

For any complex weighted graph, $A_z A_z^* = A_z^* A_z$.

*Proof.*
$$A_z A_z^* = (z \cdot B)(\bar{z} \cdot B) = z\bar{z} \cdot B^2$$
$$A_z^* A_z = (\bar{z} \cdot B)(z \cdot B) = \bar{z}z \cdot B^2$$

Since $z\bar{z} = \bar{z}z$ by commutativity of ℂ, the two expressions are equal. □

### Remark

Normality is equivalent to unitary diagonalizability (by the spectral theorem for normal operators). Thus A_z has an orthonormal eigenbasis despite not being Hermitian when Im(z) ≠ 0. This is the algebraic foundation for spectral collinearity.

---

## 5. Spectral Collinearity

### Theorem 5 (Eigenvector Scaling)

If Bv = μv for some v ∈ ℂ^n and μ ∈ ℝ, then $A_z v = (z \cdot μ) v$.

*Proof.* $A_z v = (z \cdot B)v = z \cdot (Bv) = z \cdot (\mu v) = (z\mu) \cdot v$. □

### Theorem 6 (Spectral Collinearity)

Every complex weighted graph has collinear spectrum: $A_z = z \cdot B$ where B is Hermitian.

*Proof.* Take H = B, w = z. By Theorem 3, B is Hermitian. By Theorem 1, $A_z = z \cdot B$. □

### Corollary 6.1

The eigenvalues of A_z lie on the line $\{t \cdot z : t \in \mathbb{R}\}$ in the complex plane. In particular, all eigenvalue arguments are either arg(z) or arg(z) + π.

*Proof.* Since B is Hermitian, its eigenvalues λ₁, ..., λ_n are real. By Theorem 5, the eigenvalues of A_z are zλ₁, ..., zλ_n. Each zλ_i = |λ_i| · z if λ_i ≥ 0, or |λ_i| · (-z) if λ_i < 0. □

### Remark (Failure of the Circular Law)

Corollary 6.1 shows that the circular law hypothesis fails for undirected complex weighted graphs. The eigenvalues are confined to a 1-dimensional subset of ℂ (a line through the origin), not a 2-dimensional region (a disk). The symmetry constraint E(i,j) = E(j,i) — equivalently, B = B^T — is the mechanism of collapse.

---

## 6. Walk Phase Accumulation

### Theorem 7 (Walk Phase Theorem)

For all k ≥ 0,
$$A_z^k = z^k \cdot B^k$$

*Proof.* By induction on k. Base case: $A_z^0 = I = z^0 \cdot B^0$. Inductive step:
$$A_z^{k+1} = A_z \cdot A_z^k = (z \cdot B)(z^k \cdot B^k) = z^{k+1} \cdot B^{k+1}$$
using the algebra structure of $M_n(\mathbb{C})$ as a $\mathbb{C}$-algebra. □

### Interpretation

The (i,j) entry of $B^k$ counts the number of walks of length k from i to j. Therefore:

$$(A_z^k)_{ij} = z^k \cdot (\text{number of walks of length } k \text{ from } i \text{ to } j)$$

If $z = |z| e^{i\theta}$, then a walk of length k contributes phase $e^{ik\theta}$. Walks of different lengths k₁ and k₂ interfere constructively when $(k_1 - k_2)\theta \equiv 0 \pmod{2\pi}$ and destructively when $(k_1 - k_2)\theta \equiv \pi \pmod{2\pi}$.

This creates a **resonance structure**: the graph has "preferred walk lengths" determined by the phase of z.

---

## 7. Frobenius Norm Identity

### Theorem 8 (Frobenius-Topology Identity)

$$\mathrm{tr}(A_z^* A_z) = |z|^2 \cdot |E_{\mathrm{dir}}|$$

*Proof.*
$$\mathrm{tr}(A_z^* A_z) = \mathrm{tr}((\bar{z} \cdot B)(z \cdot B)) = |z|^2 \cdot \mathrm{tr}(B^2) = |z|^2 \cdot \sum_{i,j} B_{ij}^2$$

Since $B_{ij} \in \{0, 1\}$, we have $B_{ij}^2 = B_{ij}$, so $\sum_{i,j} B_{ij}^2 = \sum_{i,j} B_{ij} = |E_{\mathrm{dir}}|$. □

### Corollary 8.1

For a normal matrix, $\mathrm{tr}(A^*A) = \sum_i |\lambda_i|^2$. Combined with Theorem 8:

$$\sum_{i=1}^n |\lambda_i|^2 = |z|^2 \cdot |E_{\mathrm{dir}}|$$

This constrains the eigenvalue distribution: the total "spectral energy" depends only on |z| and the edge count, independent of the phase arg(z).

### Theorem 9 (Degree-Weight Connection)

For each vertex i, the row sum satisfies:
$$\sum_j (A_z)_{ij} = z \cdot \deg(i)$$

*Proof.* $\sum_j (A_z)_{ij} = \sum_j z \cdot E(i,j) = z \sum_j E(i,j) = z \cdot \deg(i)$. □

---

## 8. The Directed Case: When the Circular Law Applies

For directed complex graphs, the edge function E is not necessarily symmetric. The scalar factorization $A_z = z \cdot B$ still holds, but B is no longer symmetric, hence no longer Hermitian. Consequently:

1. A_z is **not** normal in general (z·z̄·B·B^T ≠ z̄·z·B^T·B when B ≠ B^T)
2. B has **complex** eigenvalues
3. Eigenvalues of A_z are not constrained to a line

For G(n, p) directed random graphs with edge probability p, the centered and normalized matrix $(A_z - zpJ) / (|z|\sqrt{p(1-p)n})$ converges in empirical spectral distribution to the circular law (uniform on the unit disk) as n → ∞, by the Tao-Vu theorem (2010). This is the correct setting for the "circular hallucination."

### Conjecture (Spectral Dimension Transition)

For a partially symmetric graph where a fraction α of edges are bidirectional and (1-α) are unidirectional, there exists a critical α* such that:
- For α < α*, eigenvalues fill a 2D region (disk-like)
- For α = 1, eigenvalues collapse to a 1D line

The nature of this transition (continuous vs. sharp) is an open question.

---

## 9. Algorithms

### Algorithm 1: Complex Graph Spectral Analysis

```
Input: n (vertices), z (complex weight), edge indicator E
Output: eigenvalues, spectral collinearity direction

1. Construct B_{ij} = E(i,j) for all i,j
2. Compute A_z = z * B
3. Compute eigenvalues λ₁, ..., λ_n of A_z
4. Verify collinearity: check all λ_i / z are real (up to numerical precision)
5. Report direction = arg(z), eigenvalues sorted by |λ_i|
```

### Algorithm 2: Phase Interference Detection

```
Input: Complex weighted graph G(n,z), vertices i,j, max walk length K
Output: Interference pattern

1. For k = 1 to K:
     a. Compute (A_z^k)_{ij} = z^k * (B^k)_{ij}
     b. Record amplitude |z^k * (B^k)_{ij}| and phase arg(z^k * (B^k)_{ij})
2. Plot amplitude vs. k (interference pattern)
3. Identify resonant walk lengths: k where amplitude is locally maximal
```

---

## 10. Discussion

### 10.1 Significance

Our results clarify the boundary between semicircular and circular spectral behavior in random graph models. The key variable is symmetry: symmetric edge relations produce collinear spectra (semicircle on a line), while asymmetric relations produce 2D spectra (circular law on a disk).

### 10.2 Physical Interpretation

In quantum mechanics, a complex-weighted graph with weight z = |z|e^{iθ} represents a system where all transition amplitudes have the same phase θ. The spectral collinearity implies that the energy levels are effectively one-dimensional — the system has a hidden conservation law imposed by the uniform phase.

### 10.3 Connection to Existing Work

The spectral collinearity phenomenon is a special case of the general principle that scalar multiples of Hermitian matrices are normal. What is novel is the connection to graph theory and the explicit contradiction of the circular law hypothesis for symmetric complex graphs.

### 10.4 Limitations

Our model assumes uniform edge weights (all edges carry the same z). For non-uniform weights, the scalar factorization fails, and the spectral theory becomes substantially more complex. The random matrix analysis (large-n behavior) is not fully formalized; we have provided the algebraic framework but not the probabilistic limit theorems.

---

## 11. Future Work

1. **Partially symmetric graphs**: Characterize the spectral dimension transition between α = 0 (fully directed) and α = 1 (fully symmetric).

2. **Non-uniform weights**: Extend to graphs where different edges carry different complex weights z_{ij}, breaking the scalar factorization.

3. **Quantum graph states**: Apply complex weighted graphs to the analysis of graph states in quantum information, where edge weights encode entanglement phases.

4. **Spectral gap bounds**: Establish bounds on the spectral gap of complex weighted graphs in terms of graph expansion properties.

5. **Higher-order tensors**: Extend the theory to complex weighted hypergraphs, where hyperedges carry complex weights.

---

## References

1. P. Erdős and A. Rényi, "On Random Graphs I," *Publicationes Mathematicae Debrecen*, 6:290–297, 1959.

2. J. Ginibre, "Statistical ensembles of complex, quaternion, and real matrices," *Journal of Mathematical Physics*, 6(3):440–449, 1965.

3. T. Tao and V. Vu, "Random matrices: The circular law," *Communications in Contemporary Mathematics*, 12(02):261–307, 2010.

4. E. Wigner, "On the distribution of the roots of certain symmetric matrices," *Annals of Mathematics*, 67(2):325–327, 1958.

5. F. Chung, "Spectral Graph Theory," *CBMS Regional Conference Series in Mathematics*, No. 92, AMS, 1997.
