# Future Directions: Tropical Spectral Theory via Minimum Cycle Mean

This document outlines breakthrough-level research opportunities opened by the formalization of the tropical eigenvalue as the minimum cycle mean.

---

## 1. Tropical Collatz–Wielandt Theorem

**Theorem Statement:**
For any `n > 0` and weight matrix `W : Matrix (Fin n) (Fin n) ℝ`,
```
tropicalEigenvalue W = sInf { μ : ℝ | ∃ x : Fin n → ℝ,
  ∀ i, Finset.univ.inf' hn (fun j => W i j + x j) ≤ μ + x i }
```

**Why It Matters:**
This characterizes the min-plus spectral radius as a minimax value over "tropical sub-eigenvectors." It is the min-plus analogue of the classical Collatz–Wielandt theorem for nonneg matrices (Perron–Frobenius theory). It provides a dual certificate for the minimum cycle mean: instead of finding an optimal cycle, one exhibits a potential function.

**Proof Strategy:**
- (≤) For any valid (μ, x), summing the inequality along any cycle of length k shows cycleMean ≥ μ. Hence tropicalEigenvalue ≥ μ.
- (≥) Construct x from shortest-path potentials in the "policy graph" achieving the minimum cycle mean. The classical construction sets x(i) = min over paths from i to the optimal cycle, weighted by W minus the eigenvalue.

**Cross-Domain Connections:**
- Linear programming duality in network optimization
- Howard's policy iteration algorithm correctness
- Mean-payoff game values (one-player case)
- Tropical Perron–Frobenius theory

---

## 2. Karp's Algorithm: Certified Computation of Minimum Cycle Mean

**Theorem Statement:**
Define `d(k, v) = min cost of a walk of length exactly k ending at v`. Then:
```
tropicalEigenvalue W = min_v max_k (d(n, v) - d(k, v)) / (n - k)
```
where the max is over `k ∈ {0, …, n-1}`.

**Why It Matters:**
Karp's algorithm (1978) computes the minimum cycle mean in O(n·m) time. A certified implementation would be the first formally verified algorithm for this fundamental graph optimization problem. Combined with `tropicalEigenvalue_attained`, it provides a complete computational pipeline: compute the value, then extract the witness cycle.

**Proof Strategy:**
1. Define `d(k, v)` by dynamic programming: `d(0, v) = 0` for a fixed source, `d(k+1, v) = min_u (d(k, u) + W(u, v))`.
2. Show that `max_k (d(n, v) - d(k, v)) / (n - k)` equals the minimum mean of cycles passing through v.
3. Take the min over v to get the global minimum cycle mean.
4. The key lemma: every cycle is detected by comparing d(n, v) with d(k, v) for some k.

**Cross-Domain Connections:**
- Verified algorithms for combinatorial optimization
- Shortest-path algorithms (Bellman–Ford as a special case)
- Network flow theory
- Real-time systems (worst-case execution time analysis)

---

## 3. Mean-Payoff Game Value = Tropical Eigenvalue

**Theorem Statement:**
For a one-player (Min) deterministic mean-payoff game with transition matrix W:
```
game_value W = tropicalEigenvalue W
```
For two-player games, the value equals the saddle point of tropical eigenvalues over strategies.

**Why It Matters:**
Mean-payoff games are central to verification, automata theory, and algorithmic game theory. The connection to tropical eigenvalues provides structural insight and algorithmic tools. Formalizing this in Lean would create a bridge between game theory and tropical algebra.

**Proof Strategy:**
- One-player case: the optimal strategy induces a policy graph. The long-run average cost equals the minimum cycle mean in this graph, which is the tropical eigenvalue.
- Two-player case: use strategy iteration. Each fixed strategy pair yields a one-player game. The value is the minimax over strategies.
- Key lemma: the Collatz–Wielandt dual (Direction 1) provides the certificate.

**Cross-Domain Connections:**
- Formal verification of reactive systems (ω-regular objectives)
- Parity games and the Zielonka algorithm
- Ergodic control theory
- Stochastic games (extension to probabilistic transitions)

---

## 4. Full Bridge to Tropical Rayleigh Eigenvalue

**Theorem Statement:**
Given a max-plus kernel operator `K : MaxPlusKernelOp (Fin n)` with kernel matrix W:
```
∃ ev phi, K.IsEigenpair ev phi →
  ev = - tropicalEigenvalue (fun i j => - W j i)
```
That is, the max-plus eigenvalue of K equals the negation of the min-plus eigenvalue of the transposed negated matrix.

**Why It Matters:**
This bridges the existing `tropical_rayleigh_eigenvalue` theorem (max-plus variational principle) with the combinatorial cycle-mean theory. It unifies the analytic/spectral and combinatorial/graph-theoretic perspectives on tropical spectral theory.

**Proof Strategy:**
1. Show that negating all matrix entries converts min-plus to max-plus: `max_j (-W_{ij} + x_j) = -(min_j (W_{ij} - x_j))`.
2. The max-plus eigenvalue equation becomes `max_j (K.kernel(j,i) + φ(j)) = ev + φ(i)`.
3. For the cycle characterization: max-plus eigenvalue = maximum cycle mean of the kernel, which is -min(cycle mean of negated kernel) = -tropicalEigenvalue(-K.kernel^T).

**Cross-Domain Connections:**
- Tropical spectral geometry (slopes of tropical varieties)
- Non-Archimedean functional analysis
- Idempotent analysis (Maslov dequantization)
- `tropical_eigenvalue_determines_char` in the Langlands catalog

---

## 5. Tropical Characteristic Data from Cycle Structure

**Theorem Statement:**
If the catalog's `tropical_eigenvalue_determines_char` establishes that a tropical spectral value determines a tropical character χ, then:
```
∀ W, ∀ χ determined by tropicalEigenvalue W,
  χ is determined by the minimum cycle mean structure of W
```

**Why It Matters:**
This would show that purely combinatorial data (cycles and their means) determines arithmetic/tropical characters. It connects graph optimization to the tropical Langlands program, suggesting that representation-theoretic invariants can be computed from shortest-path data.

**Proof Strategy:**
1. Inspect `tropical_eigenvalue_determines_char` to extract the precise relationship between eigenvalue and character.
2. Substitute `tropicalEigenvalue = min cycle mean` (our attainment theorem).
3. Show the resulting character depends only on the cycle structure, not on any analytic/spectral machinery.

**Cross-Domain Connections:**
- Tropical Langlands program
- Hecke algebra representations
- Arithmetic geometry over function fields
- Tropical moduli spaces

---

## Additional Directions

### 6. Tropical Perron–Frobenius Theory
Formalize: if W is "irreducible" (the digraph is strongly connected), then the tropical eigenvalue is the unique μ such that the equation `min_j (W_{ij} + x_j) = μ + x_i` has a solution x.

### 7. Tropical Power Method Convergence
Show that `(W^k x)_i / k → tropicalEigenvalue W` as k → ∞ for min-plus matrix powers.

### 8. Sensitivity Analysis
Formalize how the tropical eigenvalue changes under perturbation of individual matrix entries. This connects to parametric shortest-path problems.

### 9. Tropical Eigenspaces
Characterize the set of tropical eigenvectors `{x | min_j (W_{ij} + x_j) = λ + x_i}` as a tropical polyhedron.

### 10. Applications to Scheduling and Control
Formalize the connection between tropical eigenvalues and optimal scheduling: the throughput of a timed event graph equals `1/tropicalEigenvalue`.
