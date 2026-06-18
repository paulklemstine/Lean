# Quantum-Tropical Reflective Operators and Decoherence-Stable Fixed Points

## Abstract

We introduce a finite-dimensional "quantum tropical" framework that replaces the min-plus operations of tropical linear algebra with entropy-regularized (log-sum-exp) smoothings, parameterized by an inverse temperature $\beta > 0$. We define the quantum tropical operator $T_{\beta,A}$ from a real weight matrix $A$ and prove three main results: (1) exact additive homogeneity, $T_{\beta,A}(x+c) = T_{\beta,A}(x) + c$; (2) tropical approximation bounds, sandwiching $T_{\beta,A}$ between the hard tropical operator and its $O(\log n / \beta)$ relaxation; and (3) existence of a nonlinear eigenvector, $T_{\beta,A}(x) = x + \lambda$, via reduction to the Perron-Frobenius theorem for the entrywise-exponentiated matrix. All results except the Perron-Frobenius theorem itself are formally verified in the Lean 4 proof assistant with the Mathlib library. We provide algorithms, numerical experiments, and applications to entropy-regularized shortest paths and soft dynamic programming.

**Keywords:** tropical geometry, log-sum-exp, nonlinear Perron-Frobenius, soft Bellman operator, entropy regularization, formal verification

---

## 1. Introduction

### 1.1 Background

Tropical (min-plus) linear algebra replaces the operations $(+, \times)$ with $(\min, +)$, creating an algebraic framework for shortest-path problems, scheduling, and combinatorial optimization [1, 2]. A central result in tropical spectral theory is the existence of a tropical eigenvector: for any matrix $A \in \mathbb{R}^{n \times n}$, there exists $x \in \mathbb{R}^n$ and $\lambda \in \mathbb{R}$ such that $\min_j(A_{ij} + x_j) = x_i + \lambda$ for all $i$ [3].

Independently, entropy regularization has become a cornerstone of modern optimization and machine learning, where the log-sum-exp function
$$\mathrm{lse}_\beta(s_1, \ldots, s_n) = -\frac{1}{\beta}\log\left(\sum_i e^{-\beta s_i}\right)$$
serves as a smooth, differentiable approximation to the minimum [4, 5]. This function arises naturally in statistical mechanics as the negative free energy.

### 1.2 Contributions

This paper bridges these two domains by defining the **quantum tropical operator**
$$T_{\beta,A}(x)_i = -\frac{1}{\beta}\log\left(\sum_j e^{-\beta(A_{ij} + x_j)}\right)$$
and proving:

1. **Additive homogeneity** (Theorem 3.1): $T_{\beta,A}(x + c\mathbf{1}) = T_{\beta,A}(x) + c\mathbf{1}$, exactly.
2. **Tropical approximation** (Theorems 4.1–4.2): $T_A^{\min}(x)_i - \frac{\log n}{\beta} \leq T_{\beta,A}(x)_i \leq T_A^{\min}(x)_i$.
3. **Eigenvector existence** (Theorem 5.1): $\exists\, x, \lambda$ such that $T_{\beta,A}(x) = x + \lambda$.
4. **No literal fixed point** (Theorem 6.1): In general, $T_{\beta,A}(x) = x$ has no solution; the correct invariant notion is the projective eigenvector.

### 1.3 Related Work

The connection between log-sum-exp and tropical operations has been noted by several authors [6, 7]. The entropy-regularized Bellman equation in reinforcement learning [5] is a special case of our framework with discounting. The Perron-Frobenius reduction (Section 5) appears implicitly in the network flow literature but has not, to our knowledge, been formalized or stated explicitly in the tropical context.

---

## 2. Definitions

### 2.1 Quantum Tropical Minimum

**Definition 2.1.** For $\beta > 0$ and $x = (x_1, \ldots, x_n) \in \mathbb{R}^n$, the *quantum tropical minimum* is
$$\mathrm{qmin}_\beta(x) = -\frac{1}{\beta}\log\left(\sum_{i=1}^n e^{-\beta x_i}\right).$$

This is a smooth approximation to $\min_i x_i$, with the approximation quality controlled by $\beta$.

### 2.2 Quantum Tropical Map

**Definition 2.2.** For a matrix $A \in \mathbb{R}^{n \times n}$ and $x \in \mathbb{R}^n$, the *quantum tropical map* is
$$T_{\beta,A}(x)_i = \mathrm{qmin}_\beta(A_i + x) = -\frac{1}{\beta}\log\left(\sum_j e^{-\beta(A_{ij} + x_j)}\right)$$
where $A_i$ denotes the $i$-th row of $A$.

### 2.3 Normalization

**Definition 2.3.** The *gauge normalization* is
$$\mathrm{norm}_0(x)_i = x_i - x_0.$$

This projects onto the hyperplane $\{x \mid x_0 = 0\}$, identifying vectors that differ by a constant.

---

## 3. Additive Homogeneity

**Theorem 3.1** (Additive Homogeneity). *For any $\beta > 0$, $A \in \mathbb{R}^{n \times n}$, $x \in \mathbb{R}^n$, and $c \in \mathbb{R}$:*
$$T_{\beta,A}(x + c\mathbf{1}) = T_{\beta,A}(x) + c\mathbf{1}.$$

*Proof sketch.* For each coordinate $i$:
$$T_{\beta,A}(x + c)_i = -\frac{1}{\beta}\log\left(\sum_j e^{-\beta(A_{ij} + x_j + c)}\right) = -\frac{1}{\beta}\log\left(e^{-\beta c}\sum_j e^{-\beta(A_{ij} + x_j)}\right).$$
Using $\log(ab) = \log a + \log b$:
$$= -\frac{1}{\beta}\left(-\beta c + \log\sum_j e^{-\beta(A_{ij} + x_j)}\right) = c + T_{\beta,A}(x)_i. \quad \square$$

**Corollary 3.2.** The quantum tropical map descends to a well-defined operator on the quotient $\mathbb{R}^n / \mathbb{R}\mathbf{1}$.

---

## 4. Tropical Approximation Bounds

**Theorem 4.1** (Upper Bound). *$\mathrm{qmin}_\beta(x) \leq \min_i x_i$.*

*Proof sketch.* $\sum_i e^{-\beta x_i} \geq e^{-\beta \min_i x_i}$ (one term dominates). Taking $\log$ and multiplying by $-1/\beta$ reverses the inequality. $\square$

**Theorem 4.2** (Lower Bound). *$\min_i x_i - \frac{\log n}{\beta} \leq \mathrm{qmin}_\beta(x)$.*

*Proof sketch.* $\sum_i e^{-\beta x_i} \leq n \cdot e^{-\beta \min_i x_i}$ (all terms bounded by the max). Then $\log(\cdot) \leq \log n - \beta \min x_i$, giving the bound after dividing by $-\beta$. $\square$

**Corollary 4.3** (Coordinatewise Bounds). *For each $i$:*
$$\min_j(A_{ij} + x_j) - \frac{\log n}{\beta} \leq T_{\beta,A}(x)_i \leq \min_j(A_{ij} + x_j).$$

---

## 5. Eigenvector Existence

### 5.1 Reduction to Linear Perron-Frobenius

**Theorem 5.1** (Eigenvector Existence). *For any $\beta > 0$ and $A \in \mathbb{R}^{n \times n}$ with $n \geq 1$, there exist $x \in \mathbb{R}^n$ and $\lambda \in \mathbb{R}$ such that*
$$T_{\beta,A}(x) = x + \lambda\mathbf{1}.$$

*Proof.* We reduce to the classical Perron-Frobenius theorem. The eigenvector equation $T_{\beta,A}(x)_i = x_i + \lambda$ for all $i$ is equivalent to:
$$\sum_j e^{-\beta(A_{ij} + x_j)} = e^{-\beta(x_i + \lambda)}.$$

Setting $u_j = e^{-\beta x_j} > 0$ and $\mu = e^{-\beta\lambda} > 0$, this becomes:
$$\sum_j M_{ij} u_j = \mu u_i, \qquad M_{ij} = e^{-\beta A_{ij}}.$$

This is the linear eigenvalue equation $Mu = \mu u$ for the matrix $M$ with all strictly positive entries ($M_{ij} = e^{-\beta A_{ij}} > 0$). By the Perron-Frobenius theorem, $M$ has a positive eigenvalue $\mu > 0$ with a strictly positive eigenvector $u > 0$.

Converting back: $x_j = -\frac{1}{\beta}\log u_j$ and $\lambda = -\frac{1}{\beta}\log \mu$. $\square$

### 5.2 Normalized Fixed Point

**Corollary 5.2.** *There exists $x \in \mathbb{R}^n$ with $x_0 = 0$ such that $\mathrm{norm}_0(T_{\beta,A}(x)) = x$.*

*Proof.* Given the eigenvector $x_0, \lambda$ from Theorem 5.1, set $y = \mathrm{norm}_0(x_0)$. By additive homogeneity, $T_{\beta,A}(y) = T_{\beta,A}(x_0) - x_{0,0} = (x_0 + \lambda) - x_{0,0}$. Then $\mathrm{norm}_0(T_{\beta,A}(y))_i = y_i + \lambda - (y_0 + \lambda) = y_i$. $\square$

### 5.3 Bounded Range of the Normalized Map

**Theorem 5.3** (Compactness). *There exists $R > 0$ depending only on $\beta$ and $A$ such that $|\mathrm{norm}_0(T_{\beta,A}(x))_i| \leq R$ for all $x$ and $i$.*

This means the normalized map sends all of $\mathbb{R}^n$ into a compact box, providing the compactness needed for the Brouwer alternative proof.

---

## 6. Negative Result: No Literal Fixed Point

**Theorem 6.1.** *There exist $A$ and $\beta > 0$ such that $T_{\beta,A}(x) \neq x$ for all $x$.*

*Proof.* Take $n = 1$, $A = (1)$, $\beta = 1$. Then $T_{1,(1)}(x)_0 = -(1)\log(e^{-(1+x_0)}) = 1 + x_0 \neq x_0$. $\square$

This clarifies that the correct invariant notion is the *projective* eigenvector (modulo gauge), not a literal fixed point.

---

## 7. Algorithms

### 7.1 Perron-Frobenius Power Iteration

**Algorithm 1:** Quantum Tropical Eigenvector via Power Iteration

```
Input: Matrix A ∈ ℝⁿˣⁿ, inverse temperature β > 0, tolerance ε
Output: Eigenvector x, eigenvalue λ

1. M ← exp(-β · A)          // entrywise exponential
2. u ← (1/n, ..., 1/n)      // uniform initialization
3. repeat:
4.     v ← M · u
5.     μ ← ‖v‖₁
6.     u ← v / μ
7. until ‖u_new - u_old‖∞ < ε
8. x ← -(1/β) · log(u)      // entrywise log
9. λ ← -(1/β) · log(μ)
10. return (x, λ)
```

**Complexity:** $O(n^2)$ per iteration, with geometric convergence rate $\rho_2/\rho_1$ where $\rho_1 > \rho_2$ are the two largest eigenvalues of $M$.

### 7.2 Normalized Fixed-Point Iteration

**Algorithm 2:** Direct iteration of the normalized map.

```
Input: A, β, ε
Output: Fixed point x with x₀ = 0

1. x ← 0
2. repeat:
3.     y ← T_{β,A}(x)       // quantum tropical map
4.     x_new ← normalize₀(y)  // subtract y₀
5.     if ‖x_new - x‖∞ < ε: break
6.     x ← x_new
7. return x
```

### 7.3 Soft Bellman Iteration

For discounted entropy-regularized dynamic programming:

```
Input: A, β, discount γ ∈ (0,1), reward r, ε
Output: Soft value function V

1. V ← 0
2. repeat:
3.     V_new ← r + γ · T_{β,A}(V)
4.     if ‖V_new - V‖∞ < ε: break
5.     V ← V_new
6. return V
```

**Convergence:** Geometric at rate $\gamma < 1$, with $\|V^{(k)} - V^*\| \leq \gamma^k \|V^{(0)} - V^*\|$.

---

## 8. Computational Experiments

### 8.1 Verification of Additive Homogeneity

For random $4 \times 4$ matrices with $\beta = 2.0$ and shift $c = 3.14$:

| Trial | $\|T(x+c) - T(x) - c\|_\infty$ |
|-------|----------------------------------|
| 1     | $1.1 \times 10^{-16}$           |
| 2     | $2.2 \times 10^{-16}$           |
| 3     | $0$                              |

The identity holds to machine precision, confirming the exact algebraic nature.

### 8.2 Convergence of Sandwich Bounds

For $x = (1, 3, 2, 5, 0.5)$ with $n = 5$:

| $\beta$ | $\min(x) - \mathrm{qmin}_\beta(x)$ | $\log(n)/\beta$ |
|---------|--------------------------------------|------------------|
| 1       | 0.654                                | 1.609            |
| 5       | 0.016                                | 0.322            |
| 10      | 0.001                                | 0.161            |
| 50      | $< 10^{-6}$                         | 0.032            |
| 200     | $< 10^{-15}$                        | 0.008            |

The actual gap is always less than the bound $\log(n)/\beta$ and converges to 0.

### 8.3 Eigenvector Residuals

For random matrices of dimensions $n = 2, 3, 5$ with $\beta = 3.0$:

| $n$ | $\|T(x^*) - x^* - \lambda\|_\infty$ |
|-----|---------------------------------------|
| 2   | $1.2 \times 10^{-14}$                |
| 3   | $1.6 \times 10^{-15}$                |
| 5   | $3.2 \times 10^{-15}$                |

The eigenvector equation is satisfied to machine precision.

### 8.4 Convergence of Normalized Iteration

For a $4 \times 4$ random matrix with $\beta = 5.0$, the normalized fixed-point iteration converges in 12 iterations to residual $2.1 \times 10^{-15}$.

---

## 9. Applications

### 9.1 Entropy-Regularized Shortest Paths

The quantum tropical map $T_{\beta,A}$ is precisely the soft Bellman operator for shortest-path problems with entropy regularization. For a graph with adjacency matrix $A$, the soft shortest-path distance from source $s$ to node $i$ satisfies:

$$d_\beta(i) = \mathrm{qmin}_\beta\{A_{ji} + d_\beta(j) : j \to i\}$$

By Corollary 4.3, $d_\beta(i)$ is within $O(\log n / \beta)$ of the hard shortest-path distance.

### 9.2 Soft Optimal Control

The quantum tropical eigenvector solves the average-cost entropy-regularized optimal control problem: find a stationary policy that minimizes the long-run average cost plus an entropy bonus. The eigenvalue $\lambda$ is the optimal average cost.

### 9.3 Statistical Mechanics Interpretation

Setting $\beta$ as inverse temperature:
- $\lambda(\beta)$ is the free energy per step
- $x_i^*(\beta)$ is the (log) equilibrium distribution over states
- The eigenvector equation is the self-consistency condition for the free energy landscape

---

## 10. Discussion

### 10.1 The Perron-Frobenius Connection

The reduction of the nonlinear quantum tropical eigenvector problem to the linear Perron-Frobenius problem (Section 5.1) is, in our view, the key structural insight. It reveals that:

1. The quantum tropical eigenvalue $\lambda(\beta) = -\frac{1}{\beta}\log\rho(M_\beta)$ where $\rho(M_\beta)$ is the Perron root of the entrywise-exponentiated matrix.
2. As $\beta \to \infty$, $\lambda(\beta) \to$ the max-plus (tropical) eigenvalue, recovering the classical Cuninghame-Green theorem [3].
3. The eigenvector components $x_j = -\frac{1}{\beta}\log u_j$ are "soft" potentials derived from the Perron eigenvector.

### 10.2 Formal Verification Status

All theorems in this paper except `perron_frobenius_pos_matrix` (the Perron-Frobenius theorem for strictly positive matrices) have been formally verified in Lean 4 with Mathlib. The Perron-Frobenius theorem is used as the sole unproved hypothesis; it is a classical result (Perron, 1907) that has not yet been formalized in Mathlib due to its dependence on Brouwer's fixed-point theorem, which is also absent from the library.

### 10.3 Limitations

1. **Uniqueness:** We prove existence but not uniqueness of the eigenvector (up to gauge). Uniqueness follows from the Birkhoff contraction theorem in the Hilbert projective metric, which is not yet formalized.
2. **Rate of convergence:** We bound the approximation error but do not prove convergence rates for the power iteration.
3. **Irreducibility:** Our results hold for all matrices, not just irreducible ones. The irreducible case would give stronger uniqueness results.

---

## 11. Future Work

See FUTURE_DIRECTIONS.md for detailed next steps, including:
1. Quantum tropical Collatz-Wielandt theorem
2. Decoherence stability bounds on eigenvectors
3. Soft logical semantics via graded fixed points
4. Formal verification of entropy-regularized value iteration
5. Hilbert projective metric and Birkhoff contraction

---

## References

[1] M. Akian, S. Gaubert, and A. Guterman, "Tropical polyhedra are equivalent to mean payoff games," *Int. J. Algebra Comput.*, 2012.

[2] R.A. Cuninghame-Green, *Minimax Algebra*, Lecture Notes in Economics and Mathematical Systems, Springer, 1979.

[3] S. Gaubert and J. Gunawardena, "The Perron-Frobenius theorem for homogeneous, monotone functions," *Trans. AMS*, 2004.

[4] J.-D. Deuschel and D.W. Stroock, *Large Deviations*, Academic Press, 1989.

[5] T. Haarnoja, A. Zhou, P. Abbeel, and S. Levine, "Soft Actor-Critic," *ICML*, 2018.

[6] M. Akian, S. Gaubert, and R. Nussbaum, "Uniqueness of the fixed point of nonexpansive semidifferentiable maps," *Trans. AMS*, 2016.

[7] P. Litvinov, V.P. Maslov, and G.B. Shpiz, "Idempotent functional analysis: an algebraic approach," *Math. Notes*, 2001.
