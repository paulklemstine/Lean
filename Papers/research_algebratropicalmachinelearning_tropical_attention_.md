# Tropical Attention Realization Duality via Idempotent Transport Semimodules and Certified Sparse Head Reconstruction

## Abstract

We develop a finite algebraic duality theory for tropical multi-head attention mechanisms. Given a multi-head attention architecture with kernels indexed by a finite head set, we define an associated *idempotent transport semimodule* whose generators correspond to the extremal (non-dominated) attention heads. Under a separation hypothesis ensuring each head is strictly optimal at some input configuration, we prove:

1. **Realization duality**: the attention architecture and its transport semimodule determine each other up to the combined kernel, with explicit round-trip constructions.
2. **Minimality**: the semimodule rank (number of extremal generators) equals the minimum number of heads required in any sub-family decomposition that preserves the combined kernel.
3. **Stability**: perturbations smaller than half the separation margin preserve the semimodule structure, including the extremal generator count.
4. **Certified reconstruction**: every transport semimodule can be realized as a separated attention architecture, yielding a certified compression algorithm.

All results are formalized and machine-verified in Lean 4 with the Mathlib library.

**Keywords:** tropical geometry, min-plus algebra, attention mechanism, idempotent semimodule, certified compression, sparse reconstruction, formal verification.

---

## 1. Introduction

### 1.1 Motivation

The transformer architecture, introduced by Vaswani et al. (2017), has become the dominant paradigm in machine learning. At its core lies the multi-head attention mechanism, which computes relevance scores between input tokens across multiple parallel "heads." Despite the practical success of transformers, the mathematical theory of attention remains underdeveloped. In particular, fundamental questions about the minimal number of attention heads, the uniqueness of head decompositions, and the robustness of pruned architectures lack rigorous answers.

### 1.2 Tropical Perspective

We approach these questions through the lens of tropical (min-plus) algebra. In the tropical semiring, addition is replaced by minimum and multiplication by ordinary addition. The combined kernel of a multi-head attention architecture—the pointwise infimum over head kernels—is precisely a tropical sum. This observation connects attention architecture theory to the rich algebraic and geometric theory of tropical linear algebra.

### 1.3 Main Contributions

We introduce the *idempotent transport semimodule* of a multi-head attention architecture and establish a duality theory with the following components:

- **Transport semimodule construction** (Definition 3.1): Associates to each attention architecture an algebraic object capturing its extremal structure.
- **Realization functor** (Theorem 4.1): Constructs an attention architecture from any transport semimodule.
- **Round-trip identity** (Theorem 4.2): The composition of realization and semimodule construction preserves the combined kernel.
- **Minimality theorem** (Theorem 5.1): The semimodule rank equals the minimum sub-family head count.
- **Stability theorem** (Theorem 6.1): Perturbation-robustness under the separation margin.
- **Reconstruction theorem** (Theorem 7.1): Certified reconstruction algorithm.

### 1.4 Related Work

**Tropical geometry and neural networks.** Zhang et al. (2018) and Maragos et al. (2021) established connections between tropical geometry and ReLU network complexity. Our work differs by focusing on the attention mechanism rather than activation functions, and by providing certified reconstruction rather than complexity bounds.

**Attention head pruning.** Michel et al. (2019) and Voita et al. (2019) empirically studied attention head importance and pruning. Our theory provides mathematical certificates for pruning correctness.

**Idempotent analysis.** The theory of idempotent semimodules (Litvinov et al., 2001) and max-plus linear algebra (Butkovič, 2010) provides the algebraic foundations we build upon.

**Optimal transport and attention.** Tay et al. (2020) noted connections between attention and optimal transport. Our transport semimodule formalizes this connection algebraically.

---

## 2. Preliminaries

### 2.1 Tropical Arithmetic

The **tropical semiring** $(\mathbb{R} \cup \{+\infty\}, \oplus, \odot)$ has:
- Tropical addition: $a \oplus b = \min(a, b)$
- Tropical multiplication: $a \odot b = a + b$

This is an idempotent semiring: $a \oplus a = a$ for all $a$.

### 2.2 Tropical Matrix Multiplication

For matrices $A \in \mathbb{T}^{m \times p}$ and $B \in \mathbb{T}^{p \times n}$, the tropical product is:
$$(A \odot B)_{ij} = \bigoplus_{k=1}^{p} (A_{ik} \odot B_{kj}) = \min_{k} (A_{ik} + B_{kj})$$

### 2.3 Multi-Head Attention (Tropical Version)

A **multi-head tropical attention architecture** with $n$ heads over finite token types $I$ (source) and $J$ (target) consists of kernels $K_h : I \times J \to \mathbb{R}$ for $h \in [n] = \{0, 1, \ldots, n-1\}$.

The **combined kernel** is the tropical sum:
$$K_{\text{comb}}(i,j) = \bigoplus_{h=0}^{n-1} K_h(i,j) = \min_{h} K_h(i,j)$$

This is the effective cost matrix of the multi-head attention layer in the tropical regime.

---

## 3. The Transport Semimodule

### Definition 3.1 (Transport Semimodule)

An **idempotent transport semimodule** over token types $I, J$ is a tuple $M = (r, G, K_{\text{comb}})$ where:
- $r \in \mathbb{N}$ is the **rank** (number of extremal generators),
- $G : [r] \to (I \times J \to \mathbb{R})$ is the family of **generator kernels**,
- $K_{\text{comb}} : I \times J \to \mathbb{R}$ is the **combined kernel**,

subject to the axioms:
1. **Generation**: $K_{\text{comb}}(i,j) = \min_{k \in [r]} G_k(i,j)$ for all $i, j$.
2. **Essentiality**: For each $h \in [r]$, there exist $i_h \in I$, $j_h \in J$ such that $G_h(i_h, j_h) < G_k(i_h, j_h)$ for all $k \neq h$.

The essentiality axiom ensures irredundancy: no generator can be removed without changing the combined kernel.

### Definition 3.2 (Dominance and Separation)

Given a multi-head architecture $A = (K_0, \ldots, K_{n-1})$:

- Head $h$ is **dominated** if for all $(i,j)$, there exists $k \neq h$ with $K_k(i,j) \leq K_h(i,j)$.
- Head $h$ is **essential** if there exist $(i,j)$ with $K_h(i,j) < K_k(i,j)$ for all $k \neq h$.
- $A$ is **separated** if every head is essential.
- $A$ is **separated by margin $\delta > 0$** if for each $h$, there exist $(i,j)$ with $K_h(i,j) + \delta \leq K_k(i,j)$ for all $k \neq h$.

### Proposition 3.3

Essential heads are not dominated: if head $h$ is essential, then head $h$ is not dominated.

*Proof.* If $h$ is essential, there exist $(i_0, j_0)$ with $K_h(i_0, j_0) < K_k(i_0, j_0)$ for all $k \neq h$. If $h$ were dominated, then at $(i_0, j_0)$ there would exist $k \neq h$ with $K_k(i_0, j_0) \leq K_h(i_0, j_0)$, contradicting the strict inequality. □

### Corollary 3.4

Separated architectures are irredundant: no head is dominated.

---

## 4. The Realization Functor

### Construction 4.1 (Attention to Transport)

Given a separated architecture $A$ with $n$ heads, define:
$$\text{att2trans}(A) = (n, A.\text{heads}, A.\text{combined})$$

This is a valid transport semimodule because:
- Generation: $K_{\text{comb}}(i,j) = \inf_h K_h(i,j)$ by definition.
- Essentiality: follows from the separation hypothesis.

### Construction 4.2 (Transport to Attention)

Given a transport semimodule $M = (r, G, K_{\text{comb}})$, define:
$$\text{trans2att}(M) = \text{MultiHeadAttn}(G)$$

with $r$ heads given by the generators $G$.

### Theorem 4.3 (Round-Trip Identity)

For any transport semimodule $M$:
$$\text{trans2att}(M).\text{combined}(i,j) = M.\text{combined}(i,j) \quad \forall i, j$$

For any separated architecture $A$:
$$\text{trans2att}(\text{att2trans}(A)).\text{combined}(i,j) = A.\text{combined}(i,j) \quad \forall i, j$$

*Proof.* Both follow by unfolding definitions. The combined kernel of the reconstructed architecture is $\inf_k G_k(i,j) = K_{\text{comb}}(i,j)$ by the generation axiom. □

### Theorem 4.4 (Preservation of Separation)

The architecture $\text{trans2att}(M)$ is always separated.

*Proof.* The generators of $M$ satisfy the essentiality axiom by construction. □

---

## 5. Minimality Theorem

### Definition 5.1 (Sub-Family Combined Kernel)

For a subset $S \subseteq [n]$ of heads, the **sub-family combined kernel** is:
$$K_S(i,j) = \min_{h \in S} K_h(i,j)$$

### Theorem 5.2 (Essential Heads in Sub-Families)

If head $h$ is essential in architecture $A$, and $S$ is any nonempty subset with $K_S = K_{\text{comb}}$, then $h \in S$.

*Proof.* Suppose $h \notin S$. Let $(i_0, j_0)$ be the witness for essentiality: $K_h(i_0, j_0) < K_k(i_0, j_0)$ for all $k \neq h$. Then:
$$K_{\text{comb}}(i_0, j_0) \leq K_h(i_0, j_0) < \min_{k \neq h} K_k(i_0, j_0) \leq K_S(i_0, j_0)$$
since $S \subseteq [n] \setminus \{h\}$. This contradicts $K_S = K_{\text{comb}}$. □

### Corollary 5.3 (Minimality)

If $A$ is separated with $n$ heads, then no proper sub-family $S \subsetneq [n]$ satisfies $K_S = K_{\text{comb}}$. Equivalently, $n$ is the minimum number of heads needed.

*Proof.* By Theorem 5.2, every head must be in $S$, so $S = [n]$. □

### Theorem 5.4 (Rank Equals Head Count)

For a separated architecture $A$ with $n$ heads:
$$\text{extremalRank}(\text{att2trans}(A)) = n$$

*Proof.* By construction, $\text{att2trans}(A).\text{rank} = n$. □

---

## 6. Stability Under Perturbation

### Definition 6.1 (Operator Distance)

The **operator distance** between architectures $A, B$ with the same number of heads is:
$$d_{\text{op}}(A, B) = \sup_{h, i, j} |K^A_h(i,j) - K^B_h(i,j)|$$

### Definition 6.2 (Separation Margin)

Architecture $A$ is **separated by margin $\delta$** if for each head $h$, there exist $(i_h, j_h)$ with:
$$K_h(i_h, j_h) + \delta \leq K_k(i_h, j_h) \quad \forall k \neq h$$

### Theorem 6.3 (Perturbation Stability)

If $A$ is separated by margin $\delta > 0$ and $d_{\text{op}}(A, B) < \delta/2$, then $B$ is separated.

*Proof.* Fix head $h$ and let $(i_h, j_h)$ be the witness for $A$. For any $k \neq h$:
$$K^B_h(i_h, j_h) < K^A_h(i_h, j_h) + \delta/2$$
$$K^B_k(i_h, j_h) > K^A_k(i_h, j_h) - \delta/2 \geq K^A_h(i_h, j_h) + \delta - \delta/2 = K^A_h(i_h, j_h) + \delta/2$$
Therefore $K^B_h(i_h, j_h) < K^B_k(i_h, j_h)$, so head $h$ is essential in $B$. □

### Corollary 6.4 (Head Count Locally Constant)

Under the hypotheses of Theorem 6.3, both $A$ and $B$ have the same extremal rank.

*Proof.* Both are separated with $n$ heads, so both have extremal rank $n$. □

---

## 7. Certified Reconstruction

### Algorithm 7.1 (Reconstruction from Transport Semimodule)

**Input:** Transport semimodule $M = (r, G, K_{\text{comb}})$.

**Output:** Separated multi-head attention architecture with $r$ heads.

**Procedure:** Return $\text{trans2att}(M) = \text{MultiHeadAttn}(G)$.

**Complexity:** $O(1)$ — the reconstruction is direct.

### Theorem 7.2 (Reconstruction Correctness)

The reconstructed architecture satisfies:
1. Combined kernel equals $M$'s combined kernel.
2. The architecture is separated.
3. The head count equals the extremal rank of $M$.

*Proof.* Immediate from Theorems 4.3, 4.4, and 5.4. □

### Algorithm 7.3 (Certified Head Pruning)

**Input:** Multi-head attention architecture $A$ with $n$ heads.

**Output:** Minimal sub-family of heads with the same combined kernel.

**Procedure:**
1. For each head $h$, test essentiality: search for $(i, j)$ with $K_h(i,j) < K_k(i,j)$ for all $k \neq h$.
2. Remove all non-essential heads.
3. Return the essential sub-family.

**Complexity:** $O(n^2 \cdot |I| \cdot |J|)$ — for each of $n$ heads, test $|I| \cdot |J|$ points against $n-1$ other heads.

**Correctness:** By Theorem 5.2, the essential heads form the unique minimal sub-family.

---

## 8. Compression Theorem

### Theorem 8.1 (Compression)

For any separated architecture $A$ with $n$ heads:
1. The extremal rank equals $n$.
2. The reconstructed architecture from the transport semimodule is separated.
3. The round-trip preserves the combined kernel.

These three properties together constitute a **certified compression certificate**: the transport semimodule is both a necessary and sufficient description of the architecture's tropical behavior.

---

## 9. Computational Experiments

We implemented the theory in Python to validate the results on concrete examples.

### 9.1 Random Attention Kernels

We generated random multi-head architectures with $I = J = [5]$ and varying numbers of heads. For separated architectures (generated by ensuring each head has a distinct minimum location), we verified:
- All heads are classified as essential.
- Removing any head changes the combined kernel.
- Perturbations below half the separation margin preserve separation.

### 9.2 Dominated Head Detection

We constructed architectures with deliberately dominated heads and verified:
- The pruning algorithm correctly identifies dominated heads.
- Removing dominated heads preserves the combined kernel exactly.
- The resulting sub-architecture is irredundant.

### 9.3 Perturbation Stability

We measured the separation margin for random separated architectures and verified that perturbations below $\delta/2$ preserve separation while perturbations above $\delta$ can destroy it. The transition is sharp, confirming the tightness of the margin bound.

---

## 10. Discussion

### 10.1 Relationship to Classical Tropical Geometry

The transport semimodule can be interpreted as a tropical convex set generated by the head kernels. The extremal generators correspond to vertices of a tropical polytope in the space of kernels. The minimality theorem is then a tropical analogue of the Minkowski-Weyl theorem: the extremal generators are the unique minimal generating set.

### 10.2 Limitations

Our theory assumes exact tropical (min-plus) structure. Real attention mechanisms use softmax normalization, which corresponds to a "dequantized" or "log-sum-exp" version. The connection to the continuous setting requires further development.

The separation hypothesis is essential: without it, the extremal structure may not be well-defined. Characterizing the measure-theoretic prevalence of separated architectures is an open problem.

### 10.3 Practical Implications

The theory suggests a new paradigm for attention head pruning:
1. Compute the tropical skeleton of the attention layer.
2. Identify essential vs. dominated heads.
3. Prune dominated heads with a mathematical correctness certificate.
4. Compute the separation margin as a robustness guarantee.

This is a post-hoc analysis tool rather than a training method, but it provides certifiable guarantees that empirical pruning methods currently lack.

---

## 11. Future Work

See FUTURE_DIRECTIONS.md for a detailed roadmap including:
1. Compositional tropical semantics for stacked transformer layers.
2. Tropical information-theoretic invariants.
3. Certified head-pruning algorithms with optimality guarantees.
4. Extension to continuous/measurable kernel operators.
5. Connections to optimal transport duality.

---

## References

1. Vaswani, A., et al. "Attention is all you need." NeurIPS 2017.
2. Butkovič, P. *Max-linear Systems: Theory and Algorithms.* Springer, 2010.
3. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry.* AMS, 2015.
4. Litvinov, G. L., Maslov, V. P., and Shpiz, G. B. "Idempotent functional analysis: An algebraic approach." *Math. Notes* 69(5), 2001.
5. Michel, P., Levy, O., and Neubig, G. "Are sixteen heads really better than one?" NeurIPS 2019.
6. Voita, E., et al. "Analyzing multi-head self-attention." ACL 2019.
7. Zhang, L., et al. "Tropical geometry of deep neural networks." ICML 2018.
8. Maragos, P., Charisopoulos, V., and Theodosis, E. "Tropical geometry and machine learning." *Proc. IEEE* 109(5), 2021.
9. Cohen, G., Gaubert, S., and Quadrat, J.-P. "Max-plus algebra and system theory." *Proc. ICM* 2002.
