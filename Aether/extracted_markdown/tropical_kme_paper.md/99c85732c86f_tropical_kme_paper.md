# Tropical Kernel Mean Embedding for Maxitive Measures via Idempotent Residuation

## Abstract

We formalize, in Lean 4 with Mathlib, the tropical (max-plus) analogue of kernel mean embeddings. Given a real-valued kernel $k : \alpha \times \alpha \to \mathbb{R}$ on a finite type $\alpha$ and a weight profile $w : \alpha \to \overline{\mathbb{R}}$ (where $\overline{\mathbb{R}} = \mathbb{R} \cup \{-\infty, +\infty\}$ denotes the extended reals), the **tropical kernel mean embedding** is defined as

$$m_w(y) = \sup_x \bigl(w(x) + k(x,y)\bigr).$$

We establish a Galois connection between the embedding operator $\Phi(w) = m_w$ and the residuation operator $\Psi(m)(x) = \inf_y (m(y) - k(x,y))$:

$$\Phi(w) \leq m \quad\Longleftrightarrow\quad w \leq \Psi(m)$$

in the pointwise order on $\alpha \to \overline{\mathbb{R}}$. All theorems are machine-verified in Lean 4, with no axioms beyond the standard foundational ones (propext, Classical.choice, Quot.sound).

## 1. Introduction

Kernel mean embeddings (KME) are a cornerstone of modern machine learning and statistics. Given a probability measure $\mu$ on a space $\mathcal{X}$ and a positive definite kernel $k : \mathcal{X} \times \mathcal{X} \to \mathbb{R}$, the classical KME maps $\mu$ to a function in a reproducing kernel Hilbert space (RKHS):

$$\mu \mapsto \int k(x, \cdot)\, d\mu(x).$$

This embedding turns measures into functions, enabling algorithmic comparison via the maximum mean discrepancy (MMD), hypothesis testing, and representation learning.

In this work, we develop the **tropical** (max-plus) analogue. We replace the integral with a supremum and the ring $(\mathbb{R}, +, \times)$ with the tropical semiring $(\mathbb{R} \cup \{-\infty\}, \max, +)$. The resulting embedding sends a "tropical distribution" — formally, a weight profile $w : \alpha \to \overline{\mathbb{R}}$ — to the tropical potential

$$m_w(y) = \sup_x \bigl(w(x) + k(x,y)\bigr).$$

The key structural result is that reconstruction of $w$ from $m_w$ is governed not by Hilbert-space orthogonality but by **residuation**: the tropical analogue of division in the max-plus algebra. We prove a Galois connection between the embedding and its residual, establishing the fundamental order-theoretic framework for tropical kernel theory.

### Contributions

1. **Formal definitions** in Lean 4 of the tropical KME, residuation operator, and separating kernel structures.
2. **17 machine-verified theorems** including monotonicity, the fundamental residuation inequality, the Galois connection, reconstruction, injectivity, and witness separation.
3. **Mathematical analysis** revealing that no real-valued kernel on a finite type with $|\alpha| \geq 2$ can be separating (i.e., the tropical KME is not injective for any finite real-valued kernel).
4. **Python demonstrations** with visualizations illustrating the theory.

## 2. Mathematical Framework

### 2.1 Extended Reals and the Tropical Semiring

We work with $\overline{\mathbb{R}} = \mathbb{R} \cup \{-\infty, +\infty\}$ (the type `EReal` in Lean 4), which forms a complete lattice under the natural ordering. The tropical operations are:
- **Tropical addition**: $a \oplus b = \max(a, b)$
- **Tropical multiplication**: $a \odot b = a + b$ (classical addition)

The tropical semiring $(\overline{\mathbb{R}}, \oplus, \odot)$ with identity elements $-\infty$ (for $\oplus$) and $0$ (for $\odot$) is the natural algebraic setting.

### 2.2 Tropical Kernel Mean Embedding

**Definition 1** (Tropical KME). Let $\alpha$ be a finite type, $k : \alpha \times \alpha \to \mathbb{R}$ a kernel, and $w : \alpha \to \overline{\mathbb{R}}$ a weight profile. The tropical KME is

$$\Phi_k(w)(y) = \bigoplus_x w(x) \odot k(x,y) = \sup_x \bigl(w(x) + k(x,y)\bigr).$$

This is precisely a max-plus matrix-vector product when we view $k$ as a matrix and $w$ as a vector.

**Definition 2** (Residuation operator). The tropical residuation is

$$\Psi_k(m)(x) = \bigwedge_y \bigl(m(y) \ominus k(x,y)\bigr) = \inf_y \bigl(m(y) - k(x,y)\bigr)$$

where $\ominus$ denotes classical subtraction (the residual of tropical multiplication).

### 2.3 The Galois Connection

**Theorem 1** (Galois connection; `trop_galois` in Lean). For any kernel $k$, weight profile $w$, and target $m$:

$$(\forall y,\; \Phi_k(w)(y) \leq m(y)) \quad\Longleftrightarrow\quad (\forall x,\; w(x) \leq \Psi_k(m)(x))$$

*Proof sketch.* The forward direction is the residuation upper bound: from $w(x) + k(x,y) \leq \Phi_k(w)(y) \leq m(y)$, rearrange to $w(x) \leq m(y) - k(x,y)$, then take $\inf_y$. The reverse direction: from $w(x) \leq \inf_y (m(y) - k(x,y))$, specialize to any $y$ to get $w(x) + k(x,y) \leq m(y)$, then take $\sup_x$. $\square$

**Corollary 2** (Fundamental residuation inequality; `tropKME_residuation_upper`). For any $w$ and $k$:

$$w(x) \leq \inf_y \bigl(\Phi_k(w)(y) - k(x,y)\bigr) = \Psi_k(\Phi_k(w))(x)$$

This follows by applying the forward direction of the Galois connection with $m = \Phi_k(w)$.

### 2.4 Separating Kernels and Reconstruction

**Definition 3**. A kernel $k$ is *separating* if $\Psi_k \circ \Phi_k = \text{id}$, i.e., $w(x) = \inf_y (\Phi_k(w)(y) - k(x,y))$ for all $w$ and $x$.

**Theorem 3** (`tropKME_injective`). If $k$ is separating, then $\Phi_k$ is injective.

*Proof.* If $\Phi_k(w_1) = \Phi_k(w_2)$, then for all $x$:
$$w_1(x) = \Psi_k(\Phi_k(w_1))(x) = \Psi_k(\Phi_k(w_2))(x) = w_2(x). \quad\square$$

### 2.5 Non-Existence of Real-Valued Separating Kernels

**Proposition 4**. For any finite type $\alpha$ with $|\alpha| \geq 2$ and any kernel $k : \alpha \times \alpha \to \mathbb{R}$, there exist distinct weight profiles $w_1 \neq w_2$ with $\Phi_k(w_1) = \Phi_k(w_2)$.

*Proof.* Fix $x_0, x_1 \in \alpha$ distinct. Let $M = \max_{x,y} |k(x,y)|$. Define $w_1(x_0) = 0$, $w_1(x_1) = 10M$, and $w_1(x) = -10M$ for other $x$. Then for any $y$:

$$\Phi_k(w_1)(y) = \max\bigl(k(x_0,y),\; 10M + k(x_1,y),\; \max_{x \neq x_0,x_1}(-10M + k(x,y))\bigr) = 10M + k(x_1,y)$$

since $10M + k(x_1,y) \geq 9M > M \geq k(x_0,y)$. Now let $w_2 = w_1$ except $w_2(x_0) = 1$. The same calculation gives $\Phi_k(w_2) = \Phi_k(w_1)$, since $1 + k(x_0,y) \leq 1 + M < 9M$. $\square$

This shows that the tropical KME with real-valued kernels inherently loses information. Separation requires extended-real-valued kernels (allowing $-\infty$), corresponding to the tropical Dirac kernel.

## 3. Formalization in Lean 4

### 3.1 Design Choices

We formalize the theory using `EReal` (extended reals) for weight profiles and `ℝ` for kernel values. This gives:
- A complete lattice structure on `EReal` for `iSup` and `iInf`
- Clean arithmetic via `EReal.le_sub_iff_add_le` for the key residuation step
- Well-defined addition `w(x) + (k(x,y) : EReal)` via coercion

The restriction to real-valued kernels ensures that the pivotal arithmetic identity $a + b \leq c \implies a \leq c - b$ holds without side conditions.

### 3.2 Theorem Inventory

| Theorem | Statement |
|---------|-----------|
| `tropKME_mono` | $w_1 \leq w_2 \implies \Phi(w_1) \leq \Phi(w_2)$ |
| `le_tropKME` | $w(x) + k(x,y) \leq \Phi(w)(y)$ |
| `tropKME_residual_pointwise` | $\Phi(w) \leq m \implies w(x) \leq m(y) - k(x,y)$ |
| `tropKME_le_iff` | $\Phi(w) \leq m \implies w \leq \Psi(m)$ |
| `tropKME_residuation_upper` | $w \leq \Psi(\Phi(w))$ |
| `trop_galois` | $\Phi(w) \leq m \iff w \leq \Psi(m)$ |
| `TropWitnessSeparatingKernel.toSeparating` | Witness $\implies$ full separation |
| `tropKME_reconstruct` | Reconstruction under separation |
| `tropKME_injective` | Separation $\implies$ injectivity |
| `tropKME_eq_iff` | $\Phi(w_1) = \Phi(w_2) \iff w_1 = w_2$ (under sep.) |
| `tropKME_witness_separation` | $w_1 \neq w_2 \implies \exists y, \Phi(w_1)(y) \neq \Phi(w_2)(y)$ |
| `tropKMEFinset_eq_tropKME_of_univ` | Finset version = Fintype version |
| `tropKME_delta_le` | $\Phi_\delta(w)(y) \geq w(y) + c$ |
| `tropKME_delta_ge_offdiag` | $\Phi_\delta(w)(y) \geq w(x) + d$ for $x \neq y$ |
| `tropKME_witness_strict` | Strict witness for strict weight inequality |
| `tropResiduatedBy_tropKME_ge` | $w \leq \Psi \circ \Phi(w)$ (closure lower bound) |
| `tropResiduatedBy_mono` | Monotonicity of residuation |

All proofs use only standard axioms: `propext`, `Classical.choice`, `Quot.sound`.

## 4. Applications

### 4.1 Robust Statistics and Worst-Case Analysis

In robust optimization and distributionally robust machine learning, one works with worst-case expectations over uncertainty sets. The tropical KME provides a natural framework: the weight profile $w$ encodes log-capacities of a maxitive (possibility) measure, and $\Phi_k(w)$ represents the worst-case potential under kernel smoothing.

### 4.2 Morphological Signal Processing

The tropical KME is precisely a **grey-scale dilation** from mathematical morphology:

$$\Phi_k(w) = w \oplus_k = \delta_k(w)$$

The residuation $\Psi_k$ is the corresponding **erosion**. The Galois connection is the fundamental adjunction of mathematical morphology, here formalized for the first time in a proof assistant.

### 4.3 Tropical Neural Networks

ReLU networks compute piecewise-linear functions expressible as tropical rational functions. A single max-pooling layer $h(y) = \max_i (w_i + k_i(y))$ is a tropical KME. Our formalization provides verified foundations for reasoning about such architectures.

### 4.4 Comparison of Maxitive Measures

The tropical KME enables a "tropical MMD":

$$\text{tropMMD}(w_1, w_2) = \sup_y |\Phi_k(w_1)(y) - \Phi_k(w_2)(y)|$$

Monotonicity ensures this is well-behaved, and the Galois connection characterizes when profiles produce similar embeddings.

## 5. Discussion: Making Suprema Do the Work of Integrals

*For the general reader*

Imagine you have a collection of sensors, each reporting a confidence level. A classical statistician would average these — compute an expectation. A tropical statistician takes the maximum.

This seemingly drastic simplification has profound mathematical consequences. In classical statistics, we can recover a probability distribution from enough expectations (the moment problem). In the tropical world, the question becomes: can we recover confidences from the maxima they produce against test functions?

Our answer is nuanced. The embedding $w \mapsto m_w$ is always well-defined and monotone. There is always a residuation bound giving the best possible recovery. But exact recovery requires special kernels that can "mask out" cross-talk by assigning $-\infty$ to off-diagonal interactions.

This connects to a fundamental principle: **maximization loses information**. Taking the maximum of several numbers remembers only the winner. The losers' values are forgotten. Our non-injectivity theorem captures this precisely. In contrast, averaging preserves information about all contributors, which is why classical kernel mean embeddings can be injective.

The Galois connection expresses a universal principle: there is a *best possible recovery* from maximum-based observations, given by taking the minimum over all consistent explanations. This min-max duality appears throughout optimization, game theory, and robust decision-making.

Historically, this mathematics was developed independently in tropical geometry (algebraic geometry over max-plus), mathematical morphology (image processing), and idempotent analysis (dequantization as Planck's constant goes to zero). Our work unifies these through the lens of machine learning, providing formalized kernel technology for supremum-based uncertainty.

## 6. Related Work

- **Classical KME**: Gretton, Borgwardt, Rasch, Schölkopf, Smola (2012) established kernel two-sample tests via MMD.
- **Tropical geometry**: Maclagan and Sturmfels (2015) provide comprehensive foundations for tropical algebraic geometry.
- **Idempotent analysis**: Kolokoltsov and Maslov (1997) developed idempotent mathematical foundations.
- **Mathematical morphology**: Serra (1982) and Heijmans (1994) established lattice-theoretic foundations, with the Galois connection between dilation and erosion being central.

## 7. Conclusion

We have provided the first formalized tropical kernel mean embedding theory, with 17 machine-verified theorems in Lean 4. The central result is the Galois connection between the tropical embedding and residuation operators, serving as the foundation for tropical kernel methods. Our analysis reveals fundamental limits of real-valued kernels while establishing the complete residuation theory governing information recovery in the max-plus setting.

## References

1. A. Gretton, K. Borgwardt, M. Rasch, B. Schölkopf, A. Smola, "A Kernel Two-Sample Test," *JMLR* 13, 723–773, 2012.
2. D. Maclagan, B. Sturmfels, *Introduction to Tropical Geometry*, AMS, 2015.
3. V.N. Kolokoltsov, V.P. Maslov, *Idempotent Analysis and Its Applications*, Kluwer, 1997.
4. H.J.A.M. Heijmans, *Morphological Image Operators*, Academic Press, 1994.
5. J. Serra, *Image Analysis and Mathematical Morphology*, Academic Press, 1982.
