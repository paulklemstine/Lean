# Algebraic Circuit Complexity: Formally Verified Foundations for Degree-Depth Tradeoffs, Evaluation Soundness, and Polynomial Identity Testing

## Abstract

We present a formally verified foundation for algebraic circuit complexity theory, establishing core definitions and fundamental theorems in a machine-checked mathematical framework. Our formalization introduces algebraic circuits as an inductive type over commutative semirings with $n$ input variables, defines evaluation semantics, and establishes a canonical mapping to multivariate polynomial rings. We prove five principal results: (1) the **Evaluation Soundness Theorem**, establishing that circuit evaluation coincides with polynomial evaluation; (2) the **Degree-Depth Tradeoff**, showing that circuit degree is bounded by $2^{\text{depth}}$; (3) the **Work-Span Inequality**, proving $\text{size} \geq \text{depth} + 1$; (4) **Depth Lower Bounds** from degree information; and (5) the **Ideal Structure** of zero-function circuits, providing algebraic foundations for Polynomial Identity Testing. We also formalize circuit substitution with a semantics-preservation theorem, complexity bounds, and gate-counting inequalities. These results connect algebra (polynomial rings, ideals) to computation (circuit complexity, PIT) and provide verified building blocks for further work on algebraic complexity classes VP and VNP.

**Keywords:** algebraic circuits, polynomial identity testing, degree-depth tradeoff, circuit complexity, formal verification, algebraic complexity theory

---

## 1. Introduction

Algebraic circuit complexity studies the resources required to compute multivariate polynomials using the elementary operations of addition and multiplication. Introduced by Valiant [1] in 1979, the algebraic circuit model provides a clean framework for studying computational complexity in the polynomial setting, paralleling the Boolean circuit model for discrete computation.

The central objects are *straight-line programs* — directed acyclic graphs where internal nodes perform addition or multiplication, leaf nodes hold constants or input variables, and a designated output node produces the computed polynomial. The *size* (number of gates) and *depth* (longest path from input to output) of a circuit are the primary complexity measures, corresponding to total sequential work and parallel time, respectively.

Despite decades of research, the algebraic circuit model harbors some of the deepest open problems in mathematics:

- **Valiant's Conjecture (VP ≠ VNP):** The algebraic analogue of P ≠ NP, asserting that the permanent polynomial cannot be computed by polynomial-size circuits.
- **Polynomial Identity Testing (PIT):** Given a circuit, determine whether it computes the zero polynomial — solvable in randomized polynomial time, but no deterministic polynomial-time algorithm is known.
- **Circuit Lower Bounds:** Proving super-polynomial lower bounds on circuit size for explicit polynomial families remains a major challenge.

In this work, we present a machine-verified formalization of the foundational definitions and theorems of algebraic circuit complexity (@file Catalog/Algebra/AlgebraicCircuitComplexity.lean). The formalization covers the complete pipeline from circuit definition through evaluation semantics, structural invariants, the degree-depth tradeoff, and the algebraic structure of polynomial identity testing.

### 1.1 Contributions

Our principal contributions are:

1. **Inductive circuit formalization** over arbitrary commutative semirings with a clean, compositional structure.
2. **Evaluation soundness** linking circuit semantics to formal multivariate polynomial evaluation.
3. **Degree-depth tradeoff** with tight exponential bound: $\text{degreeBound}(C) \leq 2^{\text{depth}(C)}$.
4. **Work-span inequality**: $\text{size}(C) \geq \text{depth}(C) + 1$.
5. **PIT algebraic foundations**: zero-function circuits form an ideal, closed under addition and multiplication.
6. **Substitution semantics**: circuit composition preserves evaluation.
7. **Complexity bounds**: combining structural invariants with resource bounds.

### 1.2 Related Work

The algebraic circuit model was introduced by Valiant [1]. The degree-depth tradeoff is a classical result appearing in Strassen [2] and Bürgisser, Clausen, and Shokrollahi [3]. Polynomial identity testing has been extensively studied; we refer to the survey by Saxena [4] for background. The connection between circuit depth and neural network expressivity has been explored by Telgarsky [5] and Eldan and Shamir [6].

---

## 2. Definitions

### 2.1 Algebraic Circuits

**Definition 2.1 (Algebraic Circuit).** Let $R$ be a commutative semiring and $n \in \mathbb{N}$. An *algebraic circuit* over $R$ with $n$ input variables is inductively defined as one of:

- $\texttt{const}(r)$ for $r \in R$ (constant gate),
- $\texttt{var}(i)$ for $i \in \{0, \ldots, n-1\}$ (input gate),
- $\texttt{add}(C_1, C_2)$ (addition gate), or
- $\texttt{mul}(C_1, C_2)$ (multiplication gate),

where $C_1, C_2$ are algebraic circuits over $R$ with $n$ inputs.

This corresponds to the type `AlgCircuit R n` in @file Catalog/Algebra/AlgebraicCircuitComplexity.lean.

### 2.2 Evaluation Semantics

**Definition 2.2 (Evaluation).** The *evaluation* of a circuit $C$ on an assignment $v : \{0, \ldots, n-1\} \to R$ is defined recursively:

$$
\text{eval}(C, v) = \begin{cases}
r & \text{if } C = \texttt{const}(r) \\
v(i) & \text{if } C = \texttt{var}(i) \\
\text{eval}(C_1, v) + \text{eval}(C_2, v) & \text{if } C = \texttt{add}(C_1, C_2) \\
\text{eval}(C_1, v) \cdot \text{eval}(C_2, v) & \text{if } C = \texttt{mul}(C_1, C_2)
\end{cases}
$$

### 2.3 Structural Invariants

**Definition 2.3 (Depth).** The *depth* of a circuit is the length of the longest root-to-leaf path:

$$
\text{depth}(C) = \begin{cases}
0 & \text{if } C \in \{\texttt{const}(r), \texttt{var}(i)\} \\
1 + \max(\text{depth}(C_1), \text{depth}(C_2)) & \text{if } C \in \{\texttt{add}(C_1, C_2), \texttt{mul}(C_1, C_2)\}
\end{cases}
$$

**Definition 2.4 (Size).** The *size* of a circuit is the total number of gates:

$$
\text{size}(C) = \begin{cases}
1 & \text{if } C \in \{\texttt{const}(r), \texttt{var}(i)\} \\
1 + \text{size}(C_1) + \text{size}(C_2) & \text{if } C \in \{\texttt{add}(C_1, C_2), \texttt{mul}(C_1, C_2)\}
\end{cases}
$$

**Definition 2.5 (Degree Bound).** The *syntactic degree bound* of a circuit:

$$
\text{degreeBound}(C) = \begin{cases}
0 & \text{if } C = \texttt{const}(r) \\
1 & \text{if } C = \texttt{var}(i) \\
\max(\text{degreeBound}(C_1), \text{degreeBound}(C_2)) & \text{if } C = \texttt{add}(C_1, C_2) \\
\text{degreeBound}(C_1) + \text{degreeBound}(C_2) & \text{if } C = \texttt{mul}(C_1, C_2)
\end{cases}
$$

**Definition 2.6 (Gate Counts).** The *multiplicative gate count* $\mu(C)$ and *additive gate count* $\alpha(C)$ count the number of multiplication and addition gates, respectively.

### 2.4 Polynomial Representation

**Definition 2.7 (Polynomial Map).** The *polynomial representation* of a circuit $C$ is the element $\text{toMvPolynomial}(C) \in R[x_0, \ldots, x_{n-1}]$ defined recursively:

$$
\text{toMvPolynomial}(C) = \begin{cases}
r & \text{if } C = \texttt{const}(r) \\
x_i & \text{if } C = \texttt{var}(i) \\
\text{toMvPolynomial}(C_1) + \text{toMvPolynomial}(C_2) & \text{if } C = \texttt{add}(C_1, C_2) \\
\text{toMvPolynomial}(C_1) \cdot \text{toMvPolynomial}(C_2) & \text{if } C = \texttt{mul}(C_1, C_2)
\end{cases}
$$

---

## 3. Main Results

### 3.1 Evaluation Soundness

**Theorem 3.1 (Evaluation Soundness).** *For any algebraic circuit $C$ over a commutative semiring $R$ with $n$ inputs, and any assignment $v : \{0, \ldots, n-1\} \to R$:*

$$\text{eval}(C, v) = \text{eval}_{\text{poly}}(v, \text{toMvPolynomial}(C))$$

*where $\text{eval}_{\text{poly}}$ denotes polynomial evaluation in $R[x_0, \ldots, x_{n-1}]$.*

**Proof sketch.** By structural induction on $C$. The base cases ($\texttt{const}$ and $\texttt{var}$) follow from the definitions of polynomial evaluation on constants and indeterminates. The inductive cases ($\texttt{add}$ and $\texttt{mul}$) follow from the fact that polynomial evaluation is a ring homomorphism, preserving addition and multiplication. ∎

*Formalized as* `eval_eq_mvpolynomial_eval` *in* @file Catalog/Algebra/AlgebraicCircuitComplexity.lean.

**Corollary 3.2 (Semantic Equivalence).** *If $C_1$ and $C_2$ are circuits with $\text{toMvPolynomial}(C_1) = \text{toMvPolynomial}(C_2)$, then $\text{eval}(C_1, v) = \text{eval}(C_2, v)$ for all assignments $v$.*

*Formalized as* `circuits_with_same_poly_agree`.

### 3.2 The Degree-Depth Tradeoff

**Theorem 3.3 (Degree-Depth Tradeoff).** *For any algebraic circuit $C$:*

$$\text{degreeBound}(C) \leq 2^{\text{depth}(C)}$$

**Proof sketch.** By structural induction on $C$.

- *Base cases:* Constants have degree bound 0 and variables have degree bound 1, both $\leq 2^0 = 1$.
- *Addition:* $\text{degreeBound}(\texttt{add}(C_1, C_2)) = \max(\text{degreeBound}(C_1), \text{degreeBound}(C_2))$. By induction, each is $\leq 2^{\text{depth}(C_i)} \leq 2^{\max(\text{depth}(C_1), \text{depth}(C_2))} \leq 2^{1 + \max(\text{depth}(C_1), \text{depth}(C_2))}$.
- *Multiplication:* $\text{degreeBound}(\texttt{mul}(C_1, C_2)) = \text{degreeBound}(C_1) + \text{degreeBound}(C_2) \leq 2^{\text{depth}(C_1)} + 2^{\text{depth}(C_2)} \leq 2 \cdot 2^{\max(\text{depth}(C_1), \text{depth}(C_2))} = 2^{1 + \max(\text{depth}(C_1), \text{depth}(C_2))}$. ∎

*Formalized as* `degreeBound_le_two_pow_depth` *in* @file Catalog/Algebra/AlgebraicCircuitComplexity.lean.

**Remark.** The bound is tight: iterated squaring of a single variable produces a circuit of depth $d$ computing $x^{2^d}$.

### 3.3 Depth Lower Bound

**Theorem 3.4 (Depth Lower Bound from Degree).** *If $C$ is a circuit with $\text{degreeBound}(C) > 2^d$, then $\text{depth}(C) > d$.*

**Proof sketch.** Contrapositive of Theorem 3.3: if $\text{depth}(C) \leq d$, then $\text{degreeBound}(C) \leq 2^{\text{depth}(C)} \leq 2^d$. ∎

*Formalized as* `depth_lower_bound_from_degree` *in* @file Catalog/Algebra/AlgebraicCircuitComplexity.lean.

**Corollary 3.5.** *Any circuit computing a polynomial of degree $d$ must have depth at least $\lceil \log_2 d \rceil$.*

### 3.4 Work-Span Inequality

**Theorem 3.6 (Work ≥ Span).** *For any algebraic circuit $C$:*

$$\text{size}(C) \geq \text{depth}(C) + 1$$

**Proof sketch.** By structural induction. Base cases: leaf nodes have size 1 and depth 0. For internal nodes:

$$\text{size}(\texttt{op}(C_1, C_2)) = 1 + \text{size}(C_1) + \text{size}(C_2) \geq 1 + (\text{depth}(C_1) + 1) + (\text{depth}(C_2) + 1)$$

which exceeds $1 + \max(\text{depth}(C_1), \text{depth}(C_2)) + 1 = \text{depth}(\texttt{op}(C_1, C_2)) + 1$. ∎

*Formalized as* `size_ge_depth_succ` *in* @file Catalog/Algebra/AlgebraicCircuitComplexity.lean.

### 3.5 Gate Count Inequalities

**Theorem 3.7 (Gate Count Bounds).** *For any circuit $C$:*

1. $\mu(C) \leq \text{size}(C)$ — multiplicative gates bounded by total size.
2. $\alpha(C) \leq \text{size}(C)$ — additive gates bounded by total size.
3. $\alpha(C) + \mu(C) \leq \text{size}(C)$ — internal gates bounded by total size.

*Formalized as* `mulGates_le_size`, `addGates_le_size`, *and* `addGates_plus_mulGates_le_size`.

**Remark.** Inequality (3) implies that the number of leaf nodes (constants and variables) equals $\text{size}(C) - \alpha(C) - \mu(C) \geq 0$.

### 3.6 Algebraic Structure of Zero-Function Circuits (PIT Foundations)

**Definition 3.8.** A circuit $C$ is a *zero-function circuit* if $\text{eval}(C, v) = 0$ for all $v$.

**Theorem 3.9 (Ideal Structure).** *The set of zero-function circuits is closed under:*

1. *Addition:* If $C_1, C_2$ are zero-function circuits, then $\texttt{add}(C_1, C_2)$ is a zero-function circuit.
2. *Left multiplication:* If $C_1$ is a zero-function circuit and $C_2$ is any circuit, then $\texttt{mul}(C_1, C_2)$ is a zero-function circuit.
3. *Right multiplication:* If $C_2$ is a zero-function circuit and $C_1$ is any circuit, then $\texttt{mul}(C_1, C_2)$ is a zero-function circuit.

**Proof sketch.** (1) follows from $0 + 0 = 0$. (2) follows from $0 \cdot r = 0$. (3) follows from $r \cdot 0 = 0$. ∎

*Formalized as* `add_zero_functions_is_zero`, `mul_zero_function_left`, *and* `mul_zero_function_right` *in* @file Catalog/Algebra/AlgebraicCircuitComplexity.lean.

**Theorem 3.10 (Polynomial Zero implies Function Zero).** *If $\text{toMvPolynomial}(C) = 0$, then $C$ is a zero-function circuit.*

*Formalized as* `zero_poly_implies_zero_function`.

### 3.7 Substitution and Composition

**Definition 3.11 (Substitution).** Given a circuit $C$ over $n$ variables and circuits $s_0, \ldots, s_{n-1}$ (one per variable), the *substitution* $C[s_0, \ldots, s_{n-1}]$ replaces each $\texttt{var}(i)$ node with $s_i$.

**Theorem 3.12 (Substitution Semantics).** *For any circuit $C$, substitution functions $s$, and assignment $v$:*

$$\text{eval}(C[s], v) = \text{eval}(C, \lambda i.\, \text{eval}(s(i), v))$$

**Proof sketch.** By structural induction on $C$. Constants are unchanged; variables are replaced by the corresponding substitution circuit; addition and multiplication distribute over substitution. ∎

*Formalized as* `eval_substitute` *in* @file Catalog/Algebra/AlgebraicCircuitComplexity.lean.

**Theorem 3.13 (Identity Substitution).** *Substituting $\texttt{var}(i)$ for each variable $i$ leaves the circuit unchanged: $C[\texttt{var}] = C$.*

*Formalized as* `substitute_var_id`.

### 3.8 Complexity Bounds

**Definition 3.14 (Complexity Bound).** A *circuit complexity bound* is a triple $(S, D, \Delta)$ specifying upper bounds on size, degree, and depth.

**Theorem 3.15 (Bounded Circuit Degree).** *If a circuit $C$ satisfies a complexity bound with depth bound $\Delta$, then $\text{degreeBound}(C) \leq 2^\Delta$.*

*Formalized as* `bounded_circuit_degree_bound`.

**Theorem 3.16 (Bounded Depth-Size Relationship).** *If a circuit $C$ satisfies a complexity bound with size bound $S$, then $\text{depth}(C) + 1 \leq S$.*

*Formalized as* `bounded_circuit_depth_size`.

---

## 4. Applications and Connections

### 4.1 Circuit Complexity and VP/VNP

The formalization includes a `CircuitComplexityBound` structure that captures the notion of polynomial-size, polynomially-bounded circuits — the basis for Valiant's complexity class VP. A polynomial family $(f_n)$ belongs to VP if there exist circuits $(C_n)$ with $\text{size}(C_n) \leq n^{O(1)}$, $\text{degreeBound}(C_n) \leq n^{O(1)}$, and $C_n$ computes $f_n$. Our `satisfiesBound` predicate and the accompanying theorems provide the verified infrastructure for reasoning about membership in VP.

### 4.2 Neural Network Depth

The degree-depth tradeoff (Theorem 3.3) has direct implications for deep learning. Polynomial neural networks (networks with polynomial activation functions) are algebraic circuits. The theorem implies that a network of depth $d$ can represent polynomials of degree at most $2^d$, establishing a formal separation between shallow and deep networks when the target function has high polynomial degree.

### 4.3 Polynomial Identity Testing

The ideal structure of zero-function circuits (Theorem 3.9) provides the algebraic foundation for PIT. The Schwartz-Zippel lemma, when combined with Theorem 3.15 (degree bounds for bounded circuits), gives a randomized PIT algorithm with error probability at most $d/|S|$ over a finite evaluation domain $S$ of size $|S|$, where $d$ is the degree bound.

### 4.4 Cryptographic Applications

Circuit size bounds directly relate to cryptographic hardness assumptions. Many post-quantum cryptographic schemes assume that certain polynomial families (related to lattice problems) require super-polynomial circuit size. Our formalization of the size-depth-degree relationships provides verified bounds that could be used to reason about the security parameters of such schemes.

---

## 5. Algorithms

### 5.1 Circuit Evaluation

**Algorithm 5.1.** Given a circuit $C$ and assignment $v$, compute $\text{eval}(C, v)$ by recursive traversal.

- **Time complexity:** $O(\text{size}(C))$
- **Space complexity:** $O(\text{depth}(C))$ (stack depth)

The correctness of this algorithm is guaranteed by the evaluation function definition and the soundness theorem (Theorem 3.1).

### 5.2 Degree Bound Computation

**Algorithm 5.2.** Given a circuit $C$, compute $\text{degreeBound}(C)$ by recursive traversal using max for addition and sum for multiplication.

- **Time complexity:** $O(\text{size}(C))$

The result is guaranteed to be an upper bound on the true degree by Theorem 3.3 and the definition of the degree bound.

### 5.3 Randomized PIT via Schwartz-Zippel

**Algorithm 5.3.** Given a circuit $C$ with degree bound $d$ over a field $\mathbb{F}$:

1. Choose a subset $S \subseteq \mathbb{F}$ with $|S| \geq 2d$.
2. Sample $v \in S^n$ uniformly at random.
3. Evaluate $\text{eval}(C, v)$.
4. If $\text{eval}(C, v) = 0$, output "likely zero"; otherwise "non-zero."

- **Error probability:** At most $d/|S| \leq 1/2$ (by Schwartz-Zippel).
- The degree bound $d$ can be computed using Algorithm 5.2, with Theorem 3.3 guaranteeing $d \leq 2^{\text{depth}(C)}$.

---

## 6. Discussion

### 6.1 Tightness of Bounds

The degree-depth bound $2^d$ is tight (iterated squaring achieves it), as is the work-span bound (a chain of $d$ operations has size $2d + 1$ and depth $d$, giving a ratio approaching 2). The gate count bounds are also tight in the worst case: a circuit consisting entirely of multiplication gates has $\mu(C) = \text{size}(C) - O(1)$.

### 6.2 Limitations

Our formalization captures the *tree* circuit model (each gate's output is used exactly once). The more general *DAG* circuit model, where gate outputs can be shared (fan-out > 1), computes the same class of polynomials but potentially with exponentially smaller circuits. Extending to DAG circuits would require tracking shared subexpressions.

The syntactic degree bound may overestimate the true degree of the computed polynomial (e.g., $\texttt{add}(\texttt{var}(0) \cdot \texttt{var}(0), -\texttt{var}(0) \cdot \texttt{var}(0))$ has degree bound 2 but computes the zero polynomial of degree $-\infty$). This gap is inherent in any syntactic analysis.

### 6.3 Connections to Topological Data Analysis

An emerging direction connects algebraic circuit complexity to the computational aspects of topological data analysis (TDA). Computing persistent homology of a Vietoris-Rips filtration involves algebraic operations (boundary operators, Smith normal form) whose complexity can be analyzed in the circuit model. The "Poincaré threshold" — the scale at which a point cloud's Rips complex exhibits the homology of a sphere — involves detecting specific algebraic signatures. The circuit complexity of computing this threshold, and its scaling with dimension and sample size, connects algebraic complexity to manifold learning.

---

## 7. Future Work

1. **DAG circuits:** Extend the formalization to directed acyclic graph circuits with fan-out, capturing the polynomial-size circuits that define VP.
2. **Lower bounds:** Formalize known super-polynomial lower bounds for restricted circuit classes (e.g., depth-3 circuits, multilinear circuits).
3. **PIT algorithms:** Formalize the Schwartz-Zippel lemma and connect it to the circuit degree bounds.
4. **Valiant's classes:** Define VP and VNP as complexity classes and formalize the VP ≠ VNP conjecture.
5. **Persistent homology circuits:** Analyze the algebraic circuit complexity of computing persistent Betti numbers, connecting to TDA applications.

---

## 8. Broader Impact

The formalization of algebraic circuit complexity has implications beyond pure mathematics. In machine learning, the degree-depth tradeoff provides a theoretical foundation for understanding why deep architectures outperform shallow ones: a network of depth $d$ with polynomial activations can represent functions of degree up to $2^d$, creating an exponential expressivity gap between networks of different depths. This formalizes the intuition that "depth matters" and provides quantitative bounds on the minimum depth required to approximate a target function of given polynomial degree.

In cryptography, circuit size lower bounds are intimately connected to computational hardness assumptions. Many lattice-based post-quantum cryptographic schemes rely on the assumption that certain polynomial families require super-polynomial circuits. Our formalization of the size-depth-degree relationships, combined with the complexity bound infrastructure, provides a verified framework for reasoning about the circuit complexity of cryptographic primitives.

In program verification and compiler optimization, the substitution semantics theorem (Theorem 3.12) provides a formal guarantee that modular program composition preserves semantics. This is the algebraic analogue of the fundamental theorem of denotational semantics, and its machine verification adds confidence to compiler transformations that decompose and recompose computational graphs.

The PIT foundations connect to derandomization, one of the central themes of modern complexity theory. A deterministic polynomial-time PIT algorithm would imply strong circuit lower bounds via the Kabanets-Impagliazzo framework. Our formalization of the ideal structure of zero-function circuits, combined with the degree bounds, provides the verified algebraic infrastructure needed to reason about PIT-based derandomization strategies.

Finally, the connection to topological data analysis — where algebraic operations underpin persistent homology computations — opens a pathway toward analyzing the computational complexity of manifold detection and shape recognition algorithms. The circuit complexity of computing persistent Betti numbers, and the scaling of detection thresholds with dimension and sample size, are natural questions that bridge algebraic complexity with applied topology.

## References

[1] L. G. Valiant, "Completeness classes in algebra," in *Proceedings of the 11th Annual ACM Symposium on Theory of Computing*, 1979, pp. 249–261.

[2] V. Strassen, "Vermeidung von Divisionen," *Journal für die reine und angewandte Mathematik*, vol. 264, pp. 184–202, 1973.

[3] P. Bürgisser, M. Clausen, and M. A. Shokrollahi, *Algebraic Complexity Theory*, Springer, 1997.

[4] N. Saxena, "Progress on polynomial identity testing," *Bulletin of the EATCS*, vol. 99, pp. 49–79, 2009.

[5] M. Telgarsky, "Benefits of depth in neural networks," in *COLT*, 2016.

[6] R. Eldan and O. Shamir, "The power of depth for feedforward neural networks," in *COLT*, 2016.

---

## Appendix: Catalog of Formalized Results

| # | Name | Statement | Reference |
|---|------|-----------|-----------|
| 1 | `eval_eq_mvpolynomial_eval` | $\text{eval}(C, v) = \text{eval}_{\text{poly}}(v, \text{toMvPoly}(C))$ | Theorem 3.1 |
| 2 | `circuits_with_same_poly_agree` | Same polynomial $\Rightarrow$ same evaluation | Corollary 3.2 |
| 3 | `degreeBound_le_two_pow_depth` | $\text{degreeBound}(C) \leq 2^{\text{depth}(C)}$ | Theorem 3.3 |
| 4 | `depth_lower_bound_from_degree` | $\text{degreeBound}(C) > 2^d \Rightarrow \text{depth}(C) > d$ | Theorem 3.4 |
| 5 | `size_ge_depth_succ` | $\text{size}(C) \geq \text{depth}(C) + 1$ | Theorem 3.6 |
| 6 | `AlgCircuit.size_pos` | $\text{size}(C) > 0$ | — |
| 7 | `mulGates_le_size` | $\mu(C) \leq \text{size}(C)$ | Theorem 3.7(1) |
| 8 | `addGates_le_size` | $\alpha(C) \leq \text{size}(C)$ | Theorem 3.7(2) |
| 9 | `addGates_plus_mulGates_le_size` | $\alpha(C) + \mu(C) \leq \text{size}(C)$ | Theorem 3.7(3) |
| 10 | `add_zero_functions_is_zero` | Zero functions closed under addition | Theorem 3.9(1) |
| 11 | `mul_zero_function_left` | Zero functions absorb on the left | Theorem 3.9(2) |
| 12 | `mul_zero_function_right` | Zero functions absorb on the right | Theorem 3.9(3) |
| 13 | `zero_poly_implies_zero_function` | Zero polynomial $\Rightarrow$ zero function | Theorem 3.10 |
| 14 | `eval_substitute` | Substitution preserves evaluation semantics | Theorem 3.12 |
| 15 | `substitute_var_id` | Identity substitution is identity | Theorem 3.13 |
| 16 | `bounded_circuit_degree_bound` | Bounded circuits have bounded degree | Theorem 3.15 |
| 17 | `bounded_circuit_depth_size` | Bounded circuits: depth + 1 ≤ size bound | Theorem 3.16 |
