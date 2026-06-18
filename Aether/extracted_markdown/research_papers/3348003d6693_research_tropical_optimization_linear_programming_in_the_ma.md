# Tropical Linear Programming via Residuation: Closed-Form Solutions and Duality Theory

## Abstract

We formalize **tropical linear programming (TLP)** in the max-plus algebra and prove that it admits closed-form solutions via the residuation operator. Given a TLP with constraint matrix $A \in \mathbb{R}^{m \times n}$, right-hand side $b \in \mathbb{R}^m$, and objective $c \in \mathbb{R}^n$, the optimal solution is $x^*_j = \min_i(b_i - a_{ij})$ and the optimal value is $\max_j(c_j + \min_i(b_i - a_{ij}))$. We establish: (1) the residuated solution is the componentwise maximum of the feasible set; (2) tropical weak duality as a minimax inequality; (3) a witness pair theorem guaranteeing the optimum is attained at a single variable-constraint interaction; (4) a log-transform bridge connecting tropical and classical LP; (5) universal feasibility of tropical LP over $\mathbb{R}$. All results are machine-verified in Lean 4 with Mathlib. The strongly polynomial $O(mn)$ complexity of the residuation algorithm contrasts with the open question of strongly polynomial classical LP.

## 1. Introduction

Linear programming is one of the most important and well-studied problems in mathematical optimization. The classical LP problem—maximize $c^T x$ subject to $Ax \leq b$—admits efficient polynomial-time algorithms (ellipsoid, interior point), but whether it can be solved in **strongly polynomial time** remains one of Smale's unsolved problems.

In this paper, we study LP in the **max-plus algebra** $(\mathbb{R}, \max, +)$, where the conventional addition is replaced by $\max$ and conventional multiplication by $+$. This algebraic framework, known as **tropical mathematics**, has deep connections to algebraic geometry, combinatorial optimization, and discrete event systems.

### 1.1 Main Contributions

We introduce the **Tropical Linear Program (TLP)** as a formal mathematical structure and prove the following:

1. **Closed-form optimality** (Theorem 4.1): The optimal solution is given by the residuation formula $x^*_j = \min_i(b_i - a_{ij})$, computable in $O(mn)$ time.

2. **Feasibility decomposition** (Theorem 3.1): Tropical feasibility decomposes into elementwise bounds, revealing the rectangular structure of tropical polyhedra.

3. **Weak duality** (Theorem 5.1): The minimax inequality $\max_j \min_i f(i,j) \leq \min_i \max_j f(i,j)$ provides dual bounds.

4. **Witness pair theorem** (Theorem 5.2): Every TLP admits a witness pair $(j^*, i^*)$ such that the optimal value equals $c_{j^*} + b_{i^*} - a_{i^*j^*}$.

5. **Log-transform bridge** (Theorem 6.1): Classical feasibility with positive data maps to tropical feasibility under logarithmic transformation.

6. **Universal feasibility** (Theorem 3.4): Tropical LP over $\mathbb{R}$ is always feasible—the residuated solution is a universal witness.

7. **Translation invariance** (Theorem 7.1): Shifting $b$ by a constant $s$ shifts the optimum by $s$.

## 2. The Max-Plus Algebra

### 2.1 Definition

The **max-plus semiring** $\mathbb{T} = (\mathbb{R} \cup \{-\infty\}, \oplus, \otimes)$ has operations:
$$a \oplus b = \max(a, b), \quad a \otimes b = a + b$$

with additive identity $\mathbf{0} = -\infty$ and multiplicative identity $\mathbf{1} = 0$.

In our formalization, we work over $\mathbb{R}$ (without $-\infty$), which simplifies the theory while retaining all essential structure. This choice guarantees universal feasibility.

### 2.2 Max-Plus Matrix Operations

For $A \in \mathbb{R}^{m \times n}$ and $x \in \mathbb{R}^n$:
$$(A \otimes x)_i = \bigoplus_{j=1}^n (a_{ij} \otimes x_j) = \max_{j=1}^n (a_{ij} + x_j)$$

For objective vector $c \in \mathbb{R}^n$:
$$c^T \otimes x = \max_{j=1}^n (c_j + x_j)$$

## 3. Tropical Linear Programming

### 3.1 Problem Formulation

**Definition (TropicalLP).** A tropical linear program is a triple $(A, b, c)$ where $A \in \mathbb{R}^{m \times n}$, $b \in \mathbb{R}^m$, $c \in \mathbb{R}^n$, defining:

$$\text{maximize} \quad \max_j(c_j + x_j) \quad \text{subject to} \quad \max_j(a_{ij} + x_j) \leq b_i \quad \forall i$$

### 3.2 Feasibility Decomposition

**Theorem 3.1 (Feasibility Decomposition).** $x$ is feasible if and only if $a_{ij} + x_j \leq b_i$ for all $i, j$.

*Proof.* Forward: $\max_j(a_{ij} + x_j) \leq b_i$ implies each summand $a_{ij} + x_j \leq b_i$. Backward: if every summand is $\leq b_i$, their maximum is $\leq b_i$. ∎

This decomposition reveals that tropical polyhedra are **rectangular**: the feasible set is an intersection of halfspaces $\{x : x_j \leq b_i - a_{ij}\}$, each of which constrains only a single variable.

### 3.3 The Residuation Operator

**Definition.** The **residuation** of $(A, b)$ is the vector:
$$(b \oslash A)_j = \min_i(b_i - a_{ij})$$

This is the right adjoint of max-plus matrix multiplication in the following precise sense:

**Theorem 3.2 (Galois Connection).** $A \otimes x \leq b$ if and only if $x \leq b \oslash A$ (componentwise).

*Proof.* By Theorem 3.1, $A \otimes x \leq b$ iff $x_j \leq b_i - a_{ij}$ for all $i$, iff $x_j \leq \min_i(b_i - a_{ij}) = (b \oslash A)_j$ for all $j$. ∎

### 3.4 Universal Feasibility

**Theorem 3.3 (Universal Feasibility).** Every tropical LP over $\mathbb{R}$ is feasible.

*Proof.* The residuated solution $x^* = b \oslash A$ is always feasible (Theorem 3.2). ∎

## 4. Optimality Theory

### 4.1 Objective Monotonicity

**Theorem 4.0 (Monotonicity).** If $x \leq y$ componentwise, then $\max_j(c_j + x_j) \leq \max_j(c_j + y_j)$.

### 4.1 Closed-Form Optimality

**Theorem 4.1 (Residuated Optimality).** The residuated solution $x^* = b \oslash A$ achieves the maximum of $c^T \otimes x$ over all feasible $x$.

*Proof.* By the Galois connection (Theorem 3.2), every feasible $x$ satisfies $x \leq x^*$ componentwise. By monotonicity of the objective (Theorem 4.0), $c^T \otimes x \leq c^T \otimes x^*$. ∎

**Corollary 4.2 (Closed-Form Optimum).** The optimal value equals:
$$\text{OPT} = \max_j\left(c_j + \min_i(b_i - a_{ij})\right)$$

This is computed by $n$ minimizations over $m$ elements and one maximization over $n$ elements, giving **$O(mn)$ strongly polynomial complexity**.

## 5. Duality Theory

### 5.1 Tropical Weak Duality

**Definition (Tropical Dual).** The dual of the TLP $(A, b, c)$ is:
$$\text{minimize} \quad \min_i(b_i + y_i) \quad \text{subject to} \quad \min_i(a_{ij} + y_i) \geq c_j \; \forall j, \quad y \geq 0$$

**Theorem 5.1 (Weak Duality).** For any primal-feasible $x$ and dual-feasible $y$:
$$\max_j(c_j + x_j) \leq \min_i(b_i + y_i)$$

*Proof.* For each $j$: by dual feasibility, $c_j \leq a_{ij} + y_i$ for all $i$. By primal feasibility, $x_j \leq b_i - a_{ij}$ for all $i$. Adding: $c_j + x_j \leq b_i + y_i$ for all $i$. Taking $\min$ over $i$: $c_j + x_j \leq \min_i(b_i + y_i)$. Taking $\max$ over $j$ gives the result. ∎

### 5.2 Minimax Inequality

**Theorem 5.2 (Minimax Inequality).** The optimal value satisfies:
$$\max_j \min_i (c_j + b_i - a_{ij}) \leq \min_i \max_j (c_j + b_i - a_{ij})$$

This is the tropical analogue of the classical minimax theorem. Unlike the classical case (where von Neumann's theorem guarantees equality with mixed strategies), the tropical minimax gap can be strictly positive.

### 5.3 Witness Pair Theorem

**Theorem 5.3 (Witness Pair).** There exist indices $j_0, i_0$ such that:
$$\text{OPT} = c_{j_0} + b_{i_0} - a_{i_0 j_0} \quad \text{and} \quad x^*_{j_0} = b_{i_0} - a_{i_0 j_0}$$

*Proof.* The optimum $\max_j(c_j + x^*_j)$ is attained at some $j_0$ (finite maximum). The infimum $\min_i(b_i - a_{ij_0})$ defining $x^*_{j_0}$ is attained at some $i_0$ (finite minimum). ∎

This theorem shows that the tropical optimum has a **combinatorial structure**: it is determined by a single pair of indices, interpretable as the "bottleneck" variable-constraint interaction.

## 6. Classical-Tropical Bridge

### 6.1 The Log Transform

**Definition.** For $x \in \mathbb{R}^n_{>0}$, the **log-transform** is $\log(x) = (\log x_1, \ldots, \log x_n)$.

**Theorem 6.1 (Log-Transform Bridge).** If $\exp(a_{ij}) \cdot x_j \leq \exp(b_i)$ for all $i, j$ (with $x > 0$), then $\log(x)$ is feasible for the tropical LP $(A, b, c)$.

*Proof.* Taking logarithms: $a_{ij} + \log x_j \leq b_i$. By Theorem 3.1, this is tropical feasibility. ∎

This bridge maps multiplicative classical constraints to additive tropical constraints, connecting the two optimization frameworks.

## 7. Structural Properties

### 7.1 Translation Invariance

**Theorem 7.1.** Shifting $b$ by a constant $s$ shifts the optimal value by $s$:
$$\text{OPT}(A, b+s, c) = \text{OPT}(A, b, c) + s$$

### 7.2 Tropical Convexity of the Feasible Set

**Theorem 7.2.** For feasible $x, y$ and $t \leq 0$, the point $z_j = \max(t + x_j, y_j)$ is feasible.

### 7.3 Crude Bounds

**Theorem 7.3.** $\text{OPT} \leq \max_j c_j + \max_i b_i - \min_{i,j} a_{ij}$.

**Theorem 7.4.** For any $j_0$: $c_{j_0} + \min_i(b_i - a_{ij_0}) \leq \text{OPT}$.

## 8. Algorithms

### 8.1 Residuation Algorithm

```
Algorithm: TROPICAL-LP-SOLVE(A, b, c)
Input: A ∈ ℝ^{m×n}, b ∈ ℝ^m, c ∈ ℝ^n
Output: Optimal solution x* and value OPT

1. For j = 1 to n:
     x*[j] ← min_{i=1}^m (b[i] - A[i,j])
2. OPT ← max_{j=1}^n (c[j] + x*[j])
3. Return (x*, OPT)

Complexity: O(mn) — strongly polynomial
```

### 8.2 Witness Pair Algorithm

```
Algorithm: FIND-WITNESS(A, b, c, x*)
Input: A, b, c, x* (from TROPICAL-LP-SOLVE)
Output: Witness pair (j*, i*)

1. j* ← argmax_j (c[j] + x*[j])
2. i* ← argmin_i (b[i] - A[i, j*])
3. Return (j*, i*)
   // Satisfies: OPT = c[j*] + b[i*] - A[i*, j*]

Complexity: O(m + n) additional
```

## 9. Discussion

### 9.1 Comparison with Classical LP

| Property | Classical LP | Tropical LP |
|----------|-------------|-------------|
| Solution method | Iterative (simplex, IPM) | Closed-form (residuation) |
| Complexity | Polynomial (not strongly) | O(mn) strongly polynomial |
| Feasibility | May be infeasible | Always feasible (over ℝ) |
| Strong duality | Always holds | May have gap |
| Witness structure | Vertex of polytope | Single (i,j) pair |

### 9.2 Disproof of Naïve Strong Duality

An important negative result: we proved that the naïve formulation of tropical strong duality (existence of dual-feasible $y$ achieving equality) is **false** in general. This was discovered during formal verification — the automated prover found a concrete counterexample. This highlights the value of machine verification in catching subtle mathematical errors.

### 9.3 Connections to Existing Work

Our formalization connects to the existing tropical mathematics catalog:
- The **log-transform bridge** (Theorem 6.1) generalizes `tropical_classical_bridge` from the existing catalog, extending it from scalar to vector-valued settings.
- The **closed-form optimality** relates to the Collatz-Wielandt theory for tropical matrices, where eigenvalues also admit closed-form characterizations.
- The **tropical convexity** of the feasible set (Theorem 7.2) builds on the `TropicalConvexity` development in the catalog.

## 10. Future Work

1. **Nonlinear tropical optimization**: Extend residuation to quadratic tropical programs.
2. **Parametric sensitivity**: Characterize the optimal value as a function of all parameters simultaneously.
3. **Tropical interior point methods**: Develop analogues of IPM that exploit tropical structure.
4. **Tropical LP relaxations**: Use tropical LP as a tractable relaxation for classical combinatorial optimization.

## References

1. Butkovič, P. (2010). *Max-linear Systems: Theory and Algorithms*. Springer.
2. Maclagan, D., & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
3. Akian, M., Gaubert, S., & Guterman, A. (2012). Tropical polyhedra are equivalent to mean payoff game problems. *Journal of Algebra*, 356, 281-307.
4. Gaubert, S., & Katz, R. D. (2007). The Minkowski theorem for max-plus convex sets. *Linear Algebra and its Applications*, 421, 356-369.
5. Cuninghame-Green, R. A. (1979). *Minimax Algebra*. Springer.
