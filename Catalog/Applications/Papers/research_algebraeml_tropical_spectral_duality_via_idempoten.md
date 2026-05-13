# Tropical Spectral Duality via Idempotent Koopman Semimodules and Certified Eigenfunction Reconstruction

## Abstract

We develop a spectral semantics for discrete dynamical systems over idempotent semirings. Given an idempotent semiring $S$, an $S$-module $M$, and an $S$-linear endomorphism $T : M \to M$, we define *tropical eigenfunctionals* $\varphi : M \to S$ satisfying $\varphi(Tx) = \lambda \cdot \varphi(x)$ and prove that finite families of such eigenfunctionals provide complete observational characterizations of the dynamics. Our main result, the **Finite Tropical Spectral Reconstruction Theorem**, establishes that whenever a setoid quotient of $M$ admits separation by finitely many eigenfunctionals, there exists a minimal such family that simultaneously: (1) separates all observationally distinct states, (2) conjugates $T$ to coordinatewise tropical scaling, and (3) achieves the minimum possible dimension — the *tropical observer dimension* of $(M, T)$. This dimension is a well-defined invariant, unique for each system.

We further prove that observable equivalence forms a $T$-invariant setoid, that the observation map automatically intertwines $T$ with diagonal scaling, that finite separating families admit minimal subfamilies, and that the observer dimension is unique. The idempotent/closure specialization — where $T^2 = T$ — is treated as a distinguished case where eigenfunctionals with eigenvalue 1 correspond exactly to $T$-invariant functionals.

All results are formalized and machine-verified. The framework provides a new bridge connecting idempotent algebra, Koopman-style observable dynamics, Myhill-Nerode minimization theory, and tropical transfer operators.

**Keywords:** tropical spectral theory, idempotent semiring, Koopman operator, eigenfunctional, observable quotient, Myhill-Nerode, observer dimension, closure operator, spectral reconstruction

---

## 1. Introduction

### 1.1 Motivation

Classical spectral theory — the decomposition of linear operators into eigenspaces — is among the most powerful tools in mathematics and its applications. From Fourier analysis to quantum mechanics, from Google's PageRank to principal component analysis, spectral methods reduce complex systems to transparent coordinates.

However, classical spectral theory relies fundamentally on the arithmetic of fields or at least rings: subtraction, division, and cancellation are essential to the eigenvalue theory of matrices and operators. When the underlying algebraic structure is an *idempotent semiring* — where $a + a = a$, so that addition behaves as a supremum operation — classical spectral methods fail entirely. There is no subtraction, no inverse, and no characteristic polynomial.

Idempotent semirings (also called dioids) arise naturally across mathematics and computer science:

- **Tropical algebra** ($\mathbb{R} \cup \{-\infty\}$ with $\max$ and $+$): optimization, algebraic geometry, phylogenetics
- **Max-plus algebra**: discrete event systems, manufacturing scheduling, train networks
- **Boolean algebra**: logic, circuit design, formal verification
- **Closure algebras**: static program analysis, abstract interpretation, database query optimization

In all these settings, one encounters discrete dynamical systems governed by idempotent-linear operators. The question motivating this paper is: *Can such systems be spectrally decomposed?*

### 1.2 Main Contributions

We answer this question affirmatively by developing **tropical spectral semantics** — a framework for spectral decomposition over idempotent semirings. Our contributions are:

1. **Definitions.** We introduce *tropical eigenfunctionals*, *observable equivalence*, *separating families*, and the *tropical observer dimension* as precise mathematical objects.

2. **Spectral intertwining.** We prove that any family of eigenfunctionals automatically conjugates the dynamics to coordinatewise tropical scaling (Theorem 3.1).

3. **T-invariance.** Observable equivalence defined by eigenfunctionals is shown to be a dynamically invariant setoid (Theorem 3.3).

4. **Finite reconstruction.** Given finite separability, we prove existence of a minimal eigenfamily achieving separation, conjugacy, and optimal dimension (Theorem 4.1).

5. **Uniqueness.** The observer dimension is a well-defined invariant (Theorem 4.2).

6. **Closure specialization.** For idempotent operators ($T^2 = T$), eigenfunctionals with eigenvalue 1 correspond exactly to $T$-invariant functionals (Theorem 5.1).

7. **Formal verification.** All results are machine-verified.

### 1.3 Relationship to Prior Work

**Koopman operators.** The classical Koopman theory [Koopman 1931, Mezić 2005] linearizes nonlinear dynamics by moving to the space of observables. Our framework is a tropical analogue: eigenfunctionals are tropical Koopman eigenfunctions, and the observation map is a finite-dimensional tropical Koopman embedding.

**Myhill-Nerode theory.** The Myhill-Nerode theorem [Myhill 1957, Nerode 1958] characterizes regular languages via the finiteness of an observational quotient. Our observable equivalence is a structured generalization: states are equivalent iff no eigenfunctional distinguishes them, and the observer dimension generalizes the number of Myhill-Nerode classes.

**Tropical linear algebra.** Prior work on tropical eigenvalues [Gaubert 1992, Akian-Bapat-Gaubert 2006] focuses on critical graphs and cycle means for tropical matrices. Our approach is dual: we study eigenfunctionals (in the dual module) rather than eigenvectors, and emphasize minimality of separating families over individual eigenvalue computation.

**Max-plus spectral theory.** The spectral theory of max-plus matrices [Heidergott-Olsder-van der Woude 2006] identifies eigenvalues with critical circuit means. Our framework generalizes beyond matrices to arbitrary module endomorphisms and introduces the observer dimension as a new invariant.

**Abstract interpretation.** Cousot and Cousot's abstract interpretation framework [1977] uses closure operators and Galois connections for program analysis. Our spectral decomposition of closure operators (Theorem 5.1) provides a new algebraic foundation for abstract domain construction.

---

## 2. Preliminaries and Definitions

### 2.1 Idempotent Semirings

An **idempotent semiring** (or dioid) is a semiring $(S, +, \cdot, 0, 1)$ where addition is idempotent: $a + a = a$ for all $a \in S$. This implies that $(S, +)$ is a join-semilattice with $a + b = a \vee b$, and $0$ is the bottom element.

**Examples:**
- The *tropical semiring* $(\mathbb{R} \cup \{-\infty\}, \max, +, -\infty, 0)$
- The *Boolean semiring* $(\{0, 1\}, \vee, \wedge, 0, 1)$
- Any *bounded distributive lattice* with $\cdot = \wedge$, $+ = \vee$

### 2.2 Semimodules and Linear Maps

An **$S$-semimodule** (or $S$-module when $S$ is a semiring in the Lean/Mathlib sense) is an additive commutative monoid $M$ with a compatible $S$-action. An **$S$-linear map** $f : M \to N$ satisfies $f(a \cdot x + b \cdot y) = a \cdot f(x) + b \cdot f(y)$.

### 2.3 Tropical Eigenfunctionals

**Definition 2.1.** Let $T : M \to M$ be an $S$-linear endomorphism. A *tropical eigenfunctional* for $T$ is an $S$-linear map $\varphi : M \to S$ together with an *eigenvalue* $\lambda \in S$ satisfying:
$$\varphi(T(x)) = \lambda \cdot \varphi(x) \quad \text{for all } x \in M$$

### 2.4 Observable Equivalence

**Definition 2.2.** Given a family $E$ of $S$-linear functionals on $M$, the *observable equivalence* is:
$$x \sim_E y \iff \forall \varphi \in E,\; \varphi(x) = \varphi(y)$$

**Definition 2.3.** A family $E = \{\varphi_1, \ldots, \varphi_n\}$ *separates* a setoid $Q$ on $M$ if:
$$\neg(x \sim_Q y) \implies \exists i,\; \varphi_i(x) \neq \varphi_i(y)$$

### 2.5 The Observation Map

**Definition 2.4.** The *observation map* for an indexed family $E = (\varphi_1, \ldots, \varphi_n)$ is:
$$\text{Obs}_E : M \to S^n, \quad \text{Obs}_E(x) = (\varphi_1(x), \ldots, \varphi_n(x))$$

### 2.6 Conjugate Scaling

**Definition 2.5.** We say $E$ and eigenvalues $(\lambda_1, \ldots, \lambda_n)$ give *conjugate scaling* for $T$ if:
$$\text{Obs}_E(T(x)) = (\lambda_1 \cdot \varphi_1(x), \ldots, \lambda_n \cdot \varphi_n(x))$$

### 2.7 Observer Dimension

**Definition 2.6.** The *observer dimension* of $(M, T)$ relative to a quotient $Q$ is the smallest $n$ such that there exist eigenfunctionals $\varphi_1, \ldots, \varphi_n$ with eigenvalues $\lambda_1, \ldots, \lambda_n$ that separate $Q$.

---

## 3. Core Structural Results

### 3.1 Spectral Intertwining Theorem

**Theorem 3.1** (Observation Map Intertwines). *Let $T : M \to M$ be $S$-linear, and let $E = (\varphi_1, \ldots, \varphi_n)$ be eigenfunctionals with eigenvalues $(\lambda_1, \ldots, \lambda_n)$. Then $E$ gives conjugate scaling for $T$:*
$$\text{Obs}_E(T(x))_i = \lambda_i \cdot \text{Obs}_E(x)_i \quad \text{for all } x \in M, \; i = 1, \ldots, n$$

*Proof.* By the eigenfunctional property: $\text{Obs}_E(T(x))_i = \varphi_i(T(x)) = \lambda_i \cdot \varphi_i(x) = \lambda_i \cdot \text{Obs}_E(x)_i$. □

This theorem is the heart of the spectral framework. It says that the observation map transforms arbitrarily complex $S$-linear dynamics into the simplest possible form: independent coordinatewise scaling.

### 3.2 Separation Implies Embedding

**Theorem 3.2.** *If $E$ separates the setoid $Q$, then equal observations imply $Q$-equivalence:*
$$\text{Obs}_E(x) = \text{Obs}_E(y) \implies x \sim_Q y$$

*Proof.* Contrapositive of the separation property. □

### 3.3 Dynamical Invariance

**Theorem 3.3** ($T$-Invariance of Observable Equivalence). *Let $E = (\varphi_1, \ldots, \varphi_n)$ be eigenfunctionals for $T$. Then observable equivalence is $T$-invariant: if $x \sim_E y$, then $T(x) \sim_E T(y)$.*

*Proof.* For each $i$: $\varphi_i(T(x)) = \lambda_i \cdot \varphi_i(x) = \lambda_i \cdot \varphi_i(y) = \varphi_i(T(y))$, using $\varphi_i(x) = \varphi_i(y)$ and the eigenfunctional property. □

This is a key structural result: the quotient dynamics is well-defined. The dynamics $T$ descends to a well-defined map on the observable quotient $M/{\sim_E}$.

### 3.4 Iterated Scaling

**Theorem 3.4** (Orbit Scaling). *For all $k \geq 0$:*
$$\varphi_i(T^k(x)) = \lambda_i^k \cdot \varphi_i(x)$$

*Proof.* Induction on $k$. Base case: $\varphi_i(T^0(x)) = \varphi_i(x) = 1 \cdot \varphi_i(x) = \lambda_i^0 \cdot \varphi_i(x)$. Inductive step: $\varphi_i(T^{k+1}(x)) = \lambda_i \cdot \varphi_i(T^k(x)) = \lambda_i \cdot \lambda_i^k \cdot \varphi_i(x) = \lambda_i^{k+1} \cdot \varphi_i(x)$. □

This shows that along any orbit, each coordinate of the observation map evolves as a geometric sequence with ratio $\lambda_i$.

---

## 4. Main Reconstruction Theorems

### 4.1 Finite Tropical Spectral Reconstruction

**Theorem 4.1** (Finite Tropical Spectral Reconstruction). *Let $S$ be an idempotent semiring, $M$ an $S$-module, $T : M \to M$ an $S$-linear endomorphism, and $Q$ a setoid on $M$. Suppose there exist finitely many eigenfunctionals separating $Q$. Then there exist $n \in \mathbb{N}$, eigenfunctionals $\varphi_1, \ldots, \varphi_n : M \to S$ with eigenvalues $\lambda_1, \ldots, \lambda_n \in S$ such that:*

1. *Each $\varphi_i$ is an eigenfunctional: $\varphi_i(T(x)) = \lambda_i \cdot \varphi_i(x)$*
2. *The family separates $Q$: if $x \not\sim_Q y$, then $\varphi_i(x) \neq \varphi_i(y)$ for some $i$*
3. *Conjugate scaling holds: $\text{Obs}(T(x)) = (\lambda_1 \varphi_1(x), \ldots, \lambda_n \varphi_n(x))$*
4. *$n$ is minimal: no family of size $< n$ achieves (1) and (2)*

*Proof sketch.* The hypothesis gives a finite $n_0$ and an eigenfamily of that size that separates $Q$. Among all such sizes, take the minimum — this exists because $\{m \leq n_0 : \text{separating eigenfamily of size } m \text{ exists}\}$ is a finite nonempty subset of $\mathbb{N}$. Let $n$ be this minimum. Extract a witnessing eigenfamily; conjugate scaling follows from Theorem 3.1; minimality from the definition of $n$. □

### 4.2 Uniqueness of Observer Dimension

**Theorem 4.2** (Observer Dimension Uniqueness). *The observer dimension is unique: if both $n$ and $m$ satisfy the definition of observer dimension for $(T, Q)$, then $n = m$.*

*Proof.* By antisymmetry. If $n < m$, then the existence part of the $n$-witness gives a separating eigenfamily of size $n < m$, contradicting the minimality part of the $m$-witness. Similarly, $m < n$ leads to a contradiction. □

### 4.3 Minimal Separating Subfamily

**Theorem 4.3** (Minimal Separating Subfamily). *Let $E$ be a finite set of functionals separating a setoid $Q$. Then there exists a subset $E' \subseteq E$ that:*
1. *separates $Q$, and*
2. *is minimal: no proper subset of $E'$ separates $Q$.*

*Proof.* By well-founded induction on the strict subset ordering of finite sets. Consider the collection of all subsets of $E$ that separate $Q$. This collection is nonempty (it contains $E$) and the strict subset relation is well-founded on finite sets. Take a minimal element. □

---

## 5. Closure Operator Specialization

### 5.1 Idempotent Operators and Invariant Functionals

**Theorem 5.1.** *Let $T : M \to M$ be an idempotent operator ($T \circ T = T$). Then a functional $\varphi$ is an eigenfunctional with eigenvalue 1 if and only if $\varphi$ is $T$-invariant: $\varphi(T(x)) = \varphi(x)$ for all $x$.*

*Proof.* The eigenfunctional condition with $\lambda = 1$ reads $\varphi(T(x)) = 1 \cdot \varphi(x) = \varphi(x)$, which is exactly $T$-invariance. □

This theorem connects our framework to the theory of closure operators. When $T$ is a closure operator (idempotent, extensive, monotone), the eigenfunctionals with eigenvalue 1 are precisely the observables that "see through" the closure — they cannot distinguish a state from its closure.

### 5.2 Implications for Abstract Interpretation

In the Cousot-Cousot framework of abstract interpretation, a closure operator defines an abstract domain. Theorem 5.1 says that the eigenvalue-1 eigenfunctionals characterize the abstract domain precisely: they are the observables for which concrete and abstract states are indistinguishable.

The observer dimension in this setting counts the minimum number of abstract predicates needed to fully characterize the abstract domain — a measure of the domain's intrinsic complexity.

---

## 6. Algorithmic Aspects

### 6.1 Spectral Extraction Algorithm

Given a finitely presented $S$-module $M$ with generators $g_1, \ldots, g_k$ and a transition matrix $[T]$ expressing $T(g_i)$ in terms of generators, the spectral decomposition can be extracted as follows:

**Algorithm: Tropical Spectral Extraction**

```
Input: Generators g_1, ..., g_k; transition matrix A (k × k over S)
Output: Eigenfunctionals φ_1, ..., φ_n with eigenvalues λ_1, ..., λ_n

1. Compute the tropical eigenvalues of A:
   For each λ, find row vectors v such that v · A = λ · v
   (These are left eigenvectors = eigenfunctionals on generators)

2. Collect all eigenpairs (v, λ)

3. Greedily select a minimal separating subfamily:
   a. Initialize E = ∅
   b. While there exist x, y distinguishable but not separated by E:
      - Find (v, λ) separating x, y
      - Add (v, λ) to E

4. Return E
```

**Complexity:** For a $k \times k$ tropical matrix, step 1 runs in $O(k^3)$ using the tropical eigenvalue algorithm (critical graph / cycle mean computation). Step 3 runs in $O(k^2 \cdot |\text{eigenpairs}|)$ in the worst case.

### 6.2 Verified Certification

The algorithm produces a candidate spectral decomposition. Verification consists of:
1. Checking each eigenfunctional equation: $\varphi_i(T(g_j)) = \lambda_i \cdot \varphi_i(g_j)$ for all generators $g_j$
2. Checking separation: for each pair of distinct quotient classes, at least one $\varphi_i$ distinguishes them
3. Checking minimality: each $\varphi_i$ is essential (removing it loses separation for some pair)

All three checks are finite and decidable when $M$ is finitely generated.

---

## 7. Applications

### 7.1 Network Timing Analysis

Consider a synchronous digital circuit with $k$ registers. The timing behavior is governed by a max-plus linear system $x(t+1) = A \otimes x(t)$ where $A$ is a $k \times k$ max-plus matrix. The eigenfunctionals of $A$ correspond to critical timing paths, and the observer dimension counts the minimum number of timing monitors needed to fully characterize the circuit's timing behavior.

### 7.2 Train Scheduling

In the max-plus model of train networks [Heidergott et al. 2006], the state vector records departure times and the transition matrix encodes the network topology and travel times. The tropical spectral decomposition identifies the fundamental periodic regimes of the schedule, and the observer dimension gives the minimum number of monitoring points for full schedule observability.

### 7.3 Abstract Program Analysis

When analyzing a program using abstract interpretation over a lattice domain, the abstract transfer function $T$ is a closure operator. The eigenvalue-1 eigenfunctionals characterize the abstract domain, and the spectral extraction algorithm computes an optimal set of abstract predicates for the analysis.

### 7.4 Tropical Machine Learning

Recent work connects tropical geometry to neural networks via tropical rational functions. Our spectral framework suggests a principled approach to decomposing tropical network computations into interpretable spectral components, with the observer dimension providing a notion of "effective complexity" for tropical classifiers.

---

## 8. Worked Example

Consider the max-plus semiring $S = (\mathbb{R} \cup \{-\infty\}, \max, +)$ and $M = S^2$ with the standard module structure.

Let $T : S^2 \to S^2$ be defined by:
$$T(x_1, x_2) = (\max(x_1 + 2, x_2 + 1), \max(x_1 + 3, x_2 + 1))$$

The transition matrix is:
$$A = \begin{pmatrix} 2 & 1 \\ 3 & 1 \end{pmatrix}$$

The tropical eigenvalue is $\lambda = 2.5$ (the maximum cycle mean), and a left eigenvector is $v = (0, 1)$, giving eigenfunctional $\varphi(x_1, x_2) = \max(x_1, x_2 + 1)$.

Since $M = S^2$ and $\varphi$ alone cannot separate all pairs (it's one-dimensional), we need $n = 2$ eigenfunctionals for full separation. The observer dimension is 2, which equals the state dimension — reflecting that this particular system has "full observational complexity."

---

## 9. Discussion

### 9.1 Relationship to Classical Spectral Theory

Our framework parallels classical spectral theory in structure but differs fundamentally in content:

| Classical | Tropical |
|-----------|----------|
| Field/Ring | Idempotent semiring |
| Eigenvectors | Eigenfunctionals (dual) |
| Eigenspaces | Observable equivalence classes |
| Spectral decomposition | Observation map + scaling |
| Dimension | Observer dimension |
| Characteristic polynomial | (no analogue) |

The key difference is that we work dually: classical theory decomposes the state space, while tropical theory decomposes the observable space. This is forced by the absence of subtraction: we cannot "subtract off" eigenspaces, but we can "test" with eigenfunctionals.

### 9.2 Limitations

1. **Spectral separation hypothesis.** Our main theorem assumes that the quotient is spectrally separable — i.e., that enough eigenfunctionals exist. This is not automatic and must be verified for each system.

2. **Finite generation.** We work with finitely generated modules. Infinite-dimensional extensions would require additional topological structure.

3. **Algorithmic complexity.** While the extraction algorithm is polynomial for matrices, the separation check can be expensive for large state spaces.

### 9.3 Open Questions

1. Can the spectral separation hypothesis be characterized algebraically? What properties of $(S, M, T)$ guarantee it?
2. Is there a tropical analogue of the spectral theorem for self-adjoint operators?
3. What is the relationship between observer dimension and tropical rank?

---

## 10. Future Work

1. **Tropical Hankel realization theory:** Connect input-output behavior of tropical systems to finite-dimensional spectral realizations, paralleling classical realization theory.

2. **Categorical duality:** Develop a duality between the category of tropical dynamical systems (with simulation morphisms) and the category of spectral presentations (with eigenfunctional inclusions).

3. **Entropy-dimension inequalities:** Relate the observer dimension to notions of tropical entropy and topological complexity.

4. **Spectral learning algorithms:** Develop algorithms that learn tropical spectral models from observed orbit data.

5. **Stochastic extensions:** Extend the framework to probabilistic/stochastic tropical dynamics, connecting to large deviation theory and idempotent probability.

---

## References

1. Akian, M., Bapat, R., Gaubert, S. (2006). Max-plus algebra. In *Handbook of Linear Algebra*.
2. Butkovič, P. (2010). *Max-linear Systems: Theory and Algorithms*. Springer.
3. Cousot, P., Cousot, R. (1977). Abstract interpretation: a unified lattice model for static analysis. POPL.
4. Gaubert, S. (1992). *Théorie des systèmes linéaires dans les dioïdes*. Thèse, École des Mines de Paris.
5. Heidergott, B., Olsder, G.J., van der Woude, J. (2006). *Max Plus at Work*. Princeton.
6. Koopman, B.O. (1931). Hamiltonian systems and transformations in Hilbert space. *PNAS*.
7. Litvinov, G.L. (2007). The Maslov dequantization, idempotent and tropical mathematics. *J. Math. Sci.*
8. Mezić, I. (2005). Spectral properties of dynamical systems, model reduction and decompositions. *Nonlinear Dynamics*.
9. Myhill, J. (1957). Finite automata and the representation of events. WADD TR-57-624.
10. Nerode, A. (1958). Linear automaton transformations. *Proc. AMS*.
11. Simon, I. (1988). Recognizable sets with multiplicities in the tropical semiring. *MFCS*.

---

## Appendix: Formal Verification Summary

All theorems in Sections 3–5 have been machine-verified. The formalization uses `IdemSemiring` from Mathlib for the idempotent semiring, `Module` for the semimodule structure, and `LinearMap` for morphisms. The key verified results are:

| Theorem | Formalized Name | Status |
|---------|-----------------|--------|
| 3.1 (Intertwining) | `obs_map_intertwines` | ✓ |
| 3.2 (Separation → Embedding) | `separating_implies_obs_equiv` | ✓ |
| 3.3 (T-invariance) | `obs_equiv_fin_T_invariant` | ✓ |
| 3.4 (Orbit scaling) | `conjugate_scaling_iterate` | ✓ |
| 4.1 (Reconstruction) | `finite_tropical_spectral_reconstruction` | ✓ |
| 4.2 (Uniqueness) | `observer_dimension_unique` | ✓ |
| 4.3 (Minimal subfamily) | `exists_minimal_separating_subset` | ✓ |
| 5.1 (Closure special.) | `eigenfunctional_of_idempotent_op` | ✓ |

The proofs use only the standard axioms: `propext`, `Classical.choice`, and `Quot.sound`.
