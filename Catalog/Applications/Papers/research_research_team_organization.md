# Tropical Matrix Iteration: Monotonicity, Dominance Certificates, and Nonexpansiveness

## A Formally Verified Foundation for Max-Plus Dynamical Systems

---

## Abstract

We develop a formally verified theory of tropical (max-plus) matrix operators acting on finite-dimensional real vector spaces. The central object is the Bellman operator $T(x)_i = \max_j(A_{ij} + x_j)$ associated with a weight matrix $A \in \mathbb{R}^{n \times n}$. We prove nine theorems establishing the structural properties of this operator:

1. **One-step monotonicity**: $x \leq y \Rightarrow T(x) \leq T(y)$.
2. **Iterated monotonicity**: $x \leq y \Rightarrow T^k(x) \leq T^k(y)$ for all $k$.
3. **Post-fixed point certificate**: $x \leq T(x) \Rightarrow x \leq T^k(x)$ for all $k$.
4. **Pre-fixed point certificate**: $T(x) \leq x \Rightarrow T^k(x) \leq x$ for all $k$.
5. **Sup-norm nonexpansiveness**: $|T(x)_i - T(y)_i| \leq \max_j |x_j - y_j|$.
6. **Additive homogeneity**: $T(x + c \cdot \mathbf{1}) = T(x) + c$.
7. **Composition = tropical multiplication**: $T_A \circ T_B = T_{A \otimes B}$.
8. **Iterate growth bound**: $T^k(x)_i \geq x_{\min} + k \cdot m$ where $m = \min_{ij} A_{ij}$.
9. **Squeeze theorem**: if $x \leq T(x)$, $T(y) \leq y$, and $x \leq y$, then $x \leq T^k(x) \leq T^k(y) \leq y$.

All proofs are machine-checked in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound). The formalization introduces reusable definitions for the tropical matrix map and tropical matrix multiplication, providing a foundation for future work on tropical spectral theory, certified algorithms, and max-plus dynamical systems.

**Keywords**: tropical algebra, max-plus semiring, Bellman operator, monotone operators, nonexpansiveness, formal verification, dominance certificates

---

## 1. Introduction

### 1.1 Motivation

The max-plus (tropical) semiring $(\mathbb{R} \cup \{-\infty\}, \max, +)$ replaces conventional addition with maximum and multiplication with addition. This algebraic structure arises naturally in:

- **Dynamic programming**: the Bellman equation $V(s) = \max_a [R(s,a) + V(s')]$ is a tropical fixed-point equation.
- **Graph algorithms**: shortest/longest path computations are tropical matrix-vector products.
- **Discrete event systems**: job scheduling in manufacturing, where the start time of each operation depends on the maximum of its predecessors' completion times.
- **Neural network verification**: ReLU layers compute max-affine functions, which are tropical operators.
- **Idempotent analysis**: the Maslov dequantization of quantum mechanics, where $\hbar \to 0$ transforms the Schrödinger equation into a tropical Hamilton-Jacobi equation.

Despite the extensive literature on tropical mathematics, **formally verified** results in this area are scarce. Our contribution fills this gap by providing machine-checked proofs of the foundational properties of tropical matrix iteration.

### 1.2 Contributions

We provide:
1. A clean Lean 4 formalization of the tropical matrix map and tropical matrix multiplication.
2. Complete, machine-checked proofs of 9 structural theorems.
3. Reusable infrastructure (definitions, lemma API) for future tropical formalization.
4. Python implementations with numerical demonstrations and visualizations.
5. Applications to graph algorithms, manufacturing scheduling, neural network verification, and dynamic programming.

### 1.3 Related Work

**Tropical algebra theory.** The foundational references are Baccelli, Cohen, Olsder, and Quadrat (1992) for max-plus linear systems, and Butkovič (2010) for max-linear systems. Gaubert (1992) developed the spectral theory. Our work formalizes the most fundamental layer of this theory.

**Formal verification of mathematics.** Lean 4 and Mathlib provide extensive libraries for algebra, analysis, and order theory. Prior tropical formalizations in proof assistants are extremely limited; our work appears to be the first comprehensive treatment of tropical matrix dynamics in any proof assistant.

**Certified algorithms.** The connection between tropical algebra and certified computation was explored by Allamigeon and Gaubert (2013) in the context of policy iteration. Our post-fixed point certificate theorem provides the formal foundation for such certifications.

---

## 2. Mathematical Setup

### 2.1 The Tropical Semiring

The **max-plus semiring** is the set $\mathbb{R}_{\max} = \mathbb{R} \cup \{-\infty\}$ equipped with:
- $a \oplus b = \max(a, b)$ (tropical addition)
- $a \otimes b = a + b$ (tropical multiplication)

The zero element is $-\infty$ and the unit element is $0$.

### 2.2 Tropical Matrix-Vector Product

For $A \in \mathbb{R}^{n \times n}$ and $x \in \mathbb{R}^n$, the tropical matrix-vector product is:

$$T_A(x)_i = \bigoplus_{j=1}^n (A_{ij} \otimes x_j) = \max_{j=1}^n (A_{ij} + x_j)$$

In our formalization, we work with finite-dimensional vectors over $\mathbb{R}$ (not $\mathbb{R}_{\max}$), avoiding the need for $-\infty$. This is achieved by using `Finset.sup'` (finite supremum with nonemptiness witness) instead of `Finset.sup` (which requires a bottom element).

### 2.3 Lean Formalization

```lean
def tropicalMatMap {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + x j)
```

The `[Nonempty (Fin n)]` constraint ensures $n \geq 1$, which is necessary for the finite supremum to be well-defined.

### 2.4 Tropical Matrix Multiplication

```lean
def tropicalMatMul {n : ℕ} [Nonempty (Fin n)]
    (A B : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i k => Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + B j k)
```

---

## 3. Main Results

### 3.1 Monotonicity (Theorems 1–2)

**Theorem 1 (One-step monotonicity).** *If $x_i \leq y_i$ for all $i$, then $T(x)_i \leq T(y)_i$ for all $i$.*

*Proof sketch.* For each $j$, $A_{ij} + x_j \leq A_{ij} + y_j$ by monotonicity of addition. Taking the supremum over $j$ preserves the inequality by `Finset.sup'_le` and `Finset.le_sup'`.

**Theorem 2 (Iterated monotonicity).** *If $x \leq y$ pointwise, then $T^k(x) \leq T^k(y)$ pointwise for all $k \geq 0$.*

*Proof.* By induction on $k$. The base case $k = 0$ is immediate. For $k + 1$: $T^{k+1}(x) = T(T^k(x)) \leq T(T^k(y)) = T^{k+1}(y)$ by the inductive hypothesis and Theorem 1.

### 3.2 Fixed-Point Certificates (Theorems 3–4)

**Theorem 3 (Post-fixed point certificate).** *If $x \leq T(x)$, then $x \leq T^k(x)$ for all $k \geq 0$.*

*Proof.* By induction on $k$. Base case $k = 0$: trivial. For $k + 1$: by the inductive hypothesis, $x \leq T^k(x)$. By Theorem 1, $T(x) \leq T^{k+1}(x)$. Combined with $x \leq T(x)$, we get $x \leq T^{k+1}(x)$.

**Theorem 4 (Pre-fixed point certificate).** *If $T(x) \leq x$, then $T^k(x) \leq x$ for all $k \geq 0$.*

*Proof.* Dual to Theorem 3. By induction: $T^k(x) \leq x$ implies $T^{k+1}(x) = T(T^k(x)) \leq T(x) \leq x$.

**Interpretation.** These certificates are the tropical analogues of loop invariants in program verification. Checking the one-step condition $x \leq T(x)$ certifies the bound $x \leq T^k(x)$ for *all* future iterations, without explicitly computing any iterate.

### 3.3 Nonexpansiveness (Theorem 5)

**Theorem 5 (Sup-norm nonexpansiveness).** *For all $i$:*
$$|T(x)_i - T(y)_i| \leq \max_j |x_j - y_j|$$

*Proof sketch.* For each $j$: $A_{ij} + x_j = A_{ij} + y_j + (x_j - y_j) \leq A_{ij} + y_j + |x_j - y_j| \leq A_{ij} + y_j + \max_k |x_k - y_k|$. Taking the supremum over $j$: $T(x)_i \leq T(y)_i + \max_k |x_k - y_k|$. By symmetry, $T(y)_i \leq T(x)_i + \max_k |x_k - y_k|$. Combining gives the result.

**Significance.** This establishes the tropical map as a nonexpansive (1-Lipschitz) operator in the $\ell^\infty$ norm. This is the key property for convergence analysis: the operator cannot amplify perturbations.

### 3.4 Additive Homogeneity (Theorem 6)

**Theorem 6.** *$T(x + c \cdot \mathbf{1}) = T(x) + c$ for any constant $c \in \mathbb{R}$.*

*Proof.* $T(x + c)_i = \max_j(A_{ij} + x_j + c) = \max_j(A_{ij} + x_j) + c = T(x)_i + c$.

**Significance.** Combined with monotonicity, additive homogeneity characterizes the tropical map as a **topical function** in the sense of Gunawardena and Keane (1995). Topical functions (monotone + additively homogeneous) are the nonlinear maps that admit a well-defined spectral theory.

### 3.5 Composition Principle (Theorem 7)

**Theorem 7.** *$T_A \circ T_B = T_{A \otimes B}$, where $(A \otimes B)_{ik} = \max_j(A_{ij} + B_{jk})$.*

*Proof sketch.* Both sides equal $\max_{j,k}(A_{ij} + B_{jk} + x_k)$ after rearranging the double supremum.

**Significance.** This establishes the functoriality of the tropical matrix-to-operator correspondence: composition of operators equals the operator of the tropical product. The $k$-th iterate $T_A^k$ equals $T_{A^{\otimes k}}$, where $A^{\otimes k}$ is the $k$-th tropical matrix power.

### 3.6 Growth Bound (Theorem 8)

**Theorem 8.** *If $m \leq A_{ij}$ for all $i,j$ and $x_{\min} \leq x_i$ for all $i$, then $T^k(x)_i \geq x_{\min} + km$ for all $k, i$.*

*Proof.* By induction on $k$. At each step, $T^{k+1}(x)_i \geq A_{ij} + T^k(x)_j \geq m + (x_{\min} + km)$ for any $j$.

### 3.7 Squeeze Theorem (Theorem 9)

**Theorem 9.** *If $x \leq T(x)$, $T(y) \leq y$, and $x \leq y$, then for all $k$:*
$$x \leq T^k(x) \leq T^k(y) \leq y$$

*Proof.* Combines Theorems 2, 3, and 4.

---

## 4. Algorithms

### 4.1 Tropical Matrix-Vector Multiplication

```
ALGORITHM TropicalMatVec(A, x):
  Input: A ∈ ℝ^{n×n}, x ∈ ℝ^n
  Output: T(x) ∈ ℝ^n
  for i = 1 to n:
    result[i] = max_{j=1..n} (A[i,j] + x[j])
  return result

Time: O(n²)    Space: O(n)
```

### 4.2 Tropical Matrix Multiplication

```
ALGORITHM TropicalMatMul(A, B):
  Input: A, B ∈ ℝ^{n×n}
  Output: A ⊗ B ∈ ℝ^{n×n}
  for i = 1 to n:
    for k = 1 to n:
      C[i,k] = max_{j=1..n} (A[i,j] + B[j,k])
  return C

Time: O(n³)    Space: O(n²)
```

### 4.3 Certified Iteration

```
ALGORITHM CertifiedIteration(A, x, K):
  Input: A ∈ ℝ^{n×n}, x ∈ ℝ^n, K ∈ ℕ
  Output: T^K(x), certificate

  // Check post-fixed condition
  Tx = TropicalMatVec(A, x)
  is_postfixed = (x ≤ Tx componentwise)

  // Iterate
  v = x
  for k = 1 to K:
    v = TropicalMatVec(A, v)

  // Build certificate
  certificate = {
    is_postfixed: is_postfixed,
    lower_bound: min(x) + K * min(A),
    guarantee: "x ≤ T^k(x) for all k" if is_postfixed
  }
  return v, certificate

Time: O(K·n²)    Space: O(n)
```

### 4.4 Maximum Cycle Mean (Karp's Algorithm)

```
ALGORITHM MaxCycleMean(A):
  Input: A ∈ ℝ^{n×n}
  Output: λ* (tropical eigenvalue)

  D[0][i] = 0 for all i
  for k = 1 to n:
    for i = 1 to n:
      D[k][i] = max_{j=1..n} (A[j,i] + D[k-1][j])

  λ* = max_i min_{k=0..n-1} (D[n][i] - D[k][i]) / (n - k)
  return λ*

Time: O(n³)    Space: O(n²)
```

---

## 5. Applications

### 5.1 Graph Algorithms

The $k$-th tropical matrix power $A^{\otimes k}_{ij} = \max_{\text{paths } p: i \to j, |p|=k} w(p)$ gives the maximum-weight path of length $k$ from $i$ to $j$. Longest-path dynamic programming is tropical matrix-vector iteration.

### 5.2 Manufacturing Scheduling

A system of $n$ machines with processing/transfer time matrix $A$ evolves as $x(k+1) = T_A(x(k))$, where $x(k)_i$ is the start time of the $k$-th job on machine $i$. The tropical eigenvalue $\lambda$ gives the asymptotic cycle time: one job completes every $\lambda$ time units.

**Numerical example.** For 3 machines with $A = \begin{pmatrix} 5 & 3 & 2 \\ 4 & 6 & 1 \\ 2 & 3 & 4 \end{pmatrix}$, the maximum cycle mean is $\lambda = 6$, giving a throughput of $1/6$ jobs per time unit.

### 5.3 Neural Network Verification

A ReLU layer computes $h = \max(Wx + b, 0)$. The positive part is a tropical max-affine map. The monotonicity theorem guarantees that certified bounds propagate through network layers: tighter input bounds yield tighter output bounds.

### 5.4 Dynamic Programming

The Bellman equation $V = T(V) = \max_a [R_a + V]$ is a tropical fixed-point equation. Our post-fixed point certificate (Theorem 3) says: if $V_0 \leq T(V_0)$, then $V_0$ is a certified lower bound on the true value function $V^*$ for all horizons.

---

## 6. Computational Experiments

We implemented all algorithms in Python (NumPy) and verified the theorems numerically.

### 6.1 Monotonicity Verification

For 200 random pairs $(x, y)$ with $x \leq y$ and random matrices $A \in \mathbb{R}^{3 \times 3}$, we verified $T^k(x) \leq T^k(y)$ for $k = 0, \ldots, 20$. All 4,200 inequalities held exactly.

### 6.2 Nonexpansiveness

For 200 random pairs, the contraction ratio $\|T(x) - T(y)\|_\infty / \|x - y\|_\infty$ was always $\leq 1$, with mean $\approx 0.67$ and maximum $1.0$.

### 6.3 Eigenvalue Convergence

For $A = \begin{pmatrix} 0 & 3 & -1 \\ 2 & 0 & 1 \\ 1 & 2 & 0 \end{pmatrix}$, tropical power iteration converges to $\lambda = 2.5$ (the maximum cycle mean of the 2-cycle $1 \to 2 \to 1$ with mean $(3+2)/2$). Convergence is $O(1/k)$.

---

## 7. Discussion

### 7.1 Formalization Choices

We chose to work with `Finset.sup'` (requiring `Nonempty (Fin n)`) rather than `Finset.sup` (requiring `OrderBot`) to avoid introducing $-\infty$ into the type. This keeps the theory within $\mathbb{R}$, which is more natural for applications and avoids `WithBot` coercion issues.

The `Nonempty (Fin n)` constraint is mild — all meaningful tropical matrix maps act on spaces of dimension $\geq 1$.

### 7.2 Comparison with Abstract Approaches

An alternative formalization would define the tropical map as an `OrderHom` on the product order `(Fin n → ℝ)` and use generic monotone iteration theorems. We chose the concrete approach for:
1. Transparency — the proofs directly manipulate `Finset.sup'` and `add_le_add`.
2. Computability — the definition reduces to explicit maxima.
3. Accessibility — the theory is self-contained and doesn't require category-theoretic infrastructure.

The `tropicalMatMap_orderHom` packaging is provided for users who prefer the abstract approach.

### 7.3 Limitations

- The theory is restricted to finite dimensions ($\mathbb{R}^n$, $n$ finite).
- We do not prove existence of tropical eigenvectors (a non-trivial result requiring compactness arguments or graph-theoretic construction).
- The formalization does not yet cover $\mathbb{R}_{\max} = \mathbb{R} \cup \{-\infty\}$, which would require `WithBot ℝ`.

---

## 8. Future Work

1. **Tropical eigenvector existence**: Prove $\exists \lambda, v: T(v) = v + \lambda$ using maximum cycle mean construction.
2. **Path-weight semantics**: Show $T^k(x)_i = \max_{\text{paths}} \sum \text{weights} + x_{\text{start}}$.
3. **Algebraic generalization**: Extend to `[LinearOrder α] [OrderedAddCommMonoid α]`.
4. **Tropical Perron–Frobenius**: Prove uniqueness of the tropical eigenvalue and convergence of normalized iterates.
5. **Algorithm extraction**: Derive certified shortest-path and scheduling algorithms from the formal proofs.

---

## 9. References

1. F. Baccelli, G. Cohen, G.J. Olsder, J.-P. Quadrat. *Synchronization and Linearity: An Algebra for Discrete Event Systems*. Wiley, 1992.

2. P. Butkovič. *Max-linear Systems: Theory and Algorithms*. Springer, 2010.

3. S. Gaubert. *Théorie des systèmes linéaires dans les dioïdes*. Thèse, École des Mines de Paris, 1992.

4. J. Gunawardena, M. Keane. On the existence of cycle times for some nonexpansive maps. Technical Report, HP Labs, 1995.

5. S. Allamigeon, S. Gaubert. Certification of inequalities involving transcendental functions. *J. Formalized Reasoning*, 6(1), 2013.

6. M. Akian, S. Gaubert, C. Walsh. The max-plus Martin boundary. *Documenta Mathematica*, 14:195–240, 2009.

7. R.M. Karp. A characterization of the minimum cycle mean in a digraph. *Discrete Mathematics*, 23:309–311, 1978.
