# Future Directions: Certified Tropical Linear Algebra

## Overview

The certified tropical matrix calculus established in this work opens five concrete breakthrough research directions. Each is specified at the theorem level with precise goals, proof strategies, and cross-domain connections.

---

## Direction 1: Karp's Theorem — Certified Minimum Cycle Mean Computation

### Goal
Formalize and prove Karp's theorem: the minimum cycle mean of a weighted digraph on $n$ vertices can be computed exactly from the first $n+1$ tropical powers.

### Theorem Statement
```
theorem karp_minimum_cycle_mean [NeZero n]
    (A : Fin n → Fin n → ℝ) :
    tropicalEigenvalue A =
    Finset.inf' Finset.univ Finset.univ_nonempty (fun i =>
      Finset.sup' (Finset.range n) (by simp) (fun k =>
        (tropMatPow A n i i - tropMatPow A k i i) / (n - k)))
```

### Proof Strategy
1. Use the subadditivity theorem (`tropMatPow_diag_subadditive`) as the foundation.
2. Prove that the infimum in the definition of `tropicalEigenvalue` is attained for some $k \leq n$ by a cycle decomposition argument.
3. Show that any walk of length $> n$ contains a cycle, and extracting cycles can only improve the cycle mean.
4. Connect the Karp formula to the dynamic programming table $D[k][i]$ of shortest $k$-walks.

### Prerequisites
- Formalize the cycle decomposition lemma: every walk of length $> n$ contains a simple cycle.
- Prove that the minimum cycle mean is attained by a simple cycle.
- Connect `tropMatPow A k i j` with the weight of minimum-weight walks.

### Applications
- Certified optimal scheduling for periodic discrete-event systems.
- Verified policy evaluation in mean-payoff games.
- Complexity-certified shortest-path subroutines.

### Estimated Difficulty: ★★★★☆

---

## Direction 2: Tropical Matrix Star and All-Pairs Shortest Paths

### Goal
Formalize the tropical Kleene star $A^* = I \oplus A \oplus A^2 \oplus \cdots$ and prove it certifies all-pairs shortest paths under the no-negative-cycle hypothesis.

### Theorem Statement
```
theorem tropKleeneStar_eq_shortest_paths [NeZero n]
    (A : Fin n → Fin n → ℝ) (hA : ∀ i, 0 ≤ A i i)
    (hNoNegCycle : ∀ k i, 0 ≤ tropMatPow A k i i) :
    tropKleeneStar A = shortestPathMatrix A

theorem tropKleeneStar_triangle [NeZero n]
    (A : Fin n → Fin n → ℝ) (hNoNegCycle : ...) :
    ∀ i j k, tropKleeneStar A i j ≤ tropKleeneStar A i k + tropKleeneStar A k j
```

### Proof Strategy
1. Define `tropKleeneStar A i j = inf_k (tropMatPow_extended A k i j)` where the extended power includes the identity.
2. Show the sequence of partial closures stabilizes after $n-1$ steps (from the power stabilization theorem already in the catalog).
3. Prove the triangle inequality from the star's definition and subadditivity.
4. Connect to Floyd-Warshall by showing the $k$-th intermediate closure equals the star restricted to paths through vertices $\{0, \ldots, k-1\}$.

### Applications
- Certified Floyd-Warshall correctness.
- Formal verification of routing protocols.
- Transitive closure certification for reachability queries.

### Estimated Difficulty: ★★★☆☆

---

## Direction 3: Weighted Automata and Tropical Matrix Powers

### Goal
Formalize the connection between weighted automata acceptance and tropical matrix powers, establishing that the acceptance weight of a word $w$ in a weighted automaton equals an entry of the tropical product of transition matrices.

### Theorem Statement
```
theorem weighted_automaton_acceptance [NeZero n]
    (transitions : Σ → Fin n → Fin n → ℝ)
    (initial final : Fin n → ℝ)
    (w : List Σ) :
    acceptance_weight transitions initial final w =
    tropVecMatVec initial (tropProductList (w.map transitions)) final
```

### Proof Strategy
1. Define weighted automata as tuples $(Q, \Sigma, \delta, \alpha, \beta)$ where $\delta(a)$ is a tropical matrix for each symbol $a$.
2. Show that the acceptance weight of a word $w = a_1 a_2 \cdots a_m$ equals $\alpha^T \otimes \delta(a_1) \otimes \cdots \otimes \delta(a_m) \otimes \beta$.
3. Use the associativity theorem to show this is independent of evaluation order.
4. Connect the tropical eigenvalue of $\bigoplus_a \delta(a)$ to the asymptotic growth rate of acceptance weights.

### Applications
- Certified Viterbi decoding in speech recognition and NLP.
- Formal verification of weighted model checking.
- Tropical formal language theory: decidability of equivalence for finitely ambiguous weighted automata.

### Cross-Domain Bridge
The `bool_and_as_tropical_max` theorem in the catalog provides the seed: Boolean reachability is a special case of tropical acceptance where all weights are 0 or $+\infty$.

### Estimated Difficulty: ★★★☆☆

---

## Direction 4: Tropical Cayley-Hamilton and Characteristic Polynomial

### Goal
Formalize a tropical analogue of the Cayley-Hamilton theorem: every tropical matrix satisfies its own tropical characteristic equation.

### Theorem Statement
```
theorem tropical_cayley_hamilton [NeZero n]
    (A : Fin n → Fin n → ℝ) :
    tropMatPow A n = tropMatAdd
      (tropScalarMul (tropChar A n) (tropIdentity n))
      (tropMatAdd
        (tropScalarMul (tropChar A (n-1)) (tropMatPow A 1))
        (...))
```

Here `tropChar A k` is the $k$-th coefficient of the tropical characteristic polynomial, defined via the tropical permanent (optimal assignment).

### Proof Strategy
1. Define the tropical characteristic polynomial via the tropical determinant: $\chi_A(\lambda) = \text{tdet}(\lambda I \oplus A)$.
2. Show that the coefficients are related to optimal assignments in subgraphs.
3. Prove the Cayley-Hamilton identity by showing that every walk of length $n$ can be decomposed into components corresponding to terms of the characteristic polynomial.
4. This requires the theory of optimal assignments (Hungarian algorithm) and cycle covers.

### Applications
- Minimal polynomial computation for tropical matrices.
- Certified periodicity detection for tropical dynamical systems.
- Connections to tropical intersection theory.

### Estimated Difficulty: ★★★★★

---

## Direction 5: Mean-Payoff Game Values via Tropical Spectral Theory

### Goal
Formalize the connection between tropical eigenvalues and mean-payoff game values, and certify value computation via tropical power iteration.

### Theorem Statement
```
theorem mean_payoff_value_eq_tropical_eigenvalue [NeZero n]
    (G : MeanPayoffGame n)
    (hDet : G.isDetermined) :
    G.value = tropicalEigenvalue G.weightMatrix

theorem tropical_policy_iteration_correct [NeZero n]
    (G : MeanPayoffGame n) (policy : Fin n → Fin n) :
    G.value ≤ tropicalEigenvalue (G.restrictedMatrix policy)
```

### Proof Strategy
1. Define mean-payoff games as weighted graphs with vertex partitions (Min/Max).
2. Show that optimal play produces a cycle, and the game value equals the minimum (or maximum, depending on convention) cycle mean.
3. Connect this to the tropical eigenvalue via our infimum characterization theorem.
4. Prove policy iteration converges by showing each policy improvement strictly decreases the eigenvalue of the restricted game.

### Applications
- Certified reactive system verification (LTL model checking reduces to mean-payoff games).
- Verified optimal control for discrete-event systems.
- Formal connections between tropical algebra and game-theoretic equilibria.

### Cross-Domain Bridge
This direction connects to the `tropical_spectral_bound` and `spectral_tropical_bound` theorems already in the catalog, which provide the initial inequalities needed for game-value bounds.

### Estimated Difficulty: ★★★★☆

---

## Research Roadmap

```
Direction 2 (Kleene Star)  ──→  Direction 1 (Karp's Theorem)
         ↓                              ↓
Direction 3 (Automata)     ──→  Direction 5 (Mean-Payoff Games)
                                        ↓
                           Direction 4 (Cayley-Hamilton)
```

**Recommended execution order:**
1. Direction 2 (Kleene Star) — builds directly on power stabilization
2. Direction 3 (Weighted Automata) — uses associativity and distributivity
3. Direction 1 (Karp's Theorem) — requires cycle decomposition infrastructure
4. Direction 5 (Mean-Payoff Games) — requires eigenvalue characterization from Direction 1
5. Direction 4 (Cayley-Hamilton) — deepest, requires optimal assignment theory

Each direction can seed an independent research cycle with clear hypotheses, proof strategies, and testable milestones.
