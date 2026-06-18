# Future Directions: Tropical Spectral Theory Roadmap

## Overview

The formal verification of the tropical Perron–Frobenius theorem establishes the first rigorous foundation for tropical spectral theory. This document outlines concrete breakthrough research directions opened by this work, organized by priority and feasibility.

---

## Direction 1: Walk Decomposition and Exact Spectral Identification

**Status**: High priority, high feasibility

**Goal**: Close the gap between `tropRate` and `maxCycleMean` by proving the reverse inequality:

```
tropRate(W) ≤ maxCycleMean(W)
```

Combined with the already-proved `maxCycleMean(W) ≤ tropRate(W)`, this establishes exact equality.

**Proof Strategy**:
1. Formalize walks as functions `Fin(m+2) → Fin(n+1)` with boundary conditions.
2. Prove `tropPow W m i j = max over all walks of walkWeight`.
3. Prove the **Pigeonhole Cycle Extraction Lemma**: any walk of length > n on n+1 vertices contains a repeated vertex, hence a cycle of length ≤ n+1.
4. Prove that any closed walk decomposes into simple cycles, each with mean ≤ maxCycleMean.
5. Conclude: `tropPow W m i i ≤ (m+1) * maxCycleMean W`.

**Key Lemma**:
```
theorem walk_cycle_decomposition :
    ∀ (w : Walk n m i i), ∃ (cycles : List (SimpleCycle n)),
      walkWeight w = sum (cycles.map cycleWeight) ∧
      sum (cycles.map cycleLength) = m + 1
```

**Impact**: Completes the spectral identification. Every downstream application gains exact characterization.

**Cross-domain connections**: Algorithmic graph theory, combinatorial optimization.

---

## Direction 2: Formal Verification of Karp's Algorithm

**Status**: High priority, medium feasibility

**Goal**: Formalize Karp's 1978 algorithm for computing the maximum cycle mean in O(n³) time, and prove it correct against the formal definition of `maxCycleMean`.

**Algorithm** (to formalize):
```
def karpMCM (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) : ℝ :=
  -- F k i = max weight walk of k edges ending at i
  -- μ = max_i min_{k<n+1} (F (n+1) i - F k i) / (n+1-k)
```

**Proof obligations**:
1. Correctness: `karpMCM W = maxCycleMean W`
2. Complexity: runs in O(n³) arithmetic operations

**Hypotheses to validate**:
- The min-over-k characterization encodes exactly the maximum cycle mean
- The algorithm handles all edge cases (negative weights, self-loops)

**Impact**: Verified algorithms for safety-critical timing analysis (e.g., avionics, medical devices).

**Cross-domain connections**: Verified compilation, static timing analysis, safety-critical systems.

---

## Direction 3: Tropical Additive Eigenvectors (Bellman Eigenpairs)

**Status**: High priority, medium-high feasibility

**Goal**: Prove existence of additive eigenpairs for the tropical Bellman operator.

**Formal target**:
```
theorem tropical_bellman_eigenpair
    (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    ∃ (λ : ℝ) (v : Fin (n+1) → ℝ),
      λ = tropRate W ∧
      ∀ i, (Finset.univ.sup' Finset.univ_nonempty fun j => W i j + v j) = λ + v i
```

**Proof Strategy**:
1. Define the Bellman operator T : (Fin(n+1) → ℝ) → (Fin(n+1) → ℝ) by (Tx)(i) = max_j(W(i,j) + x(j)).
2. Show T is order-preserving and additively homogeneous: T(x + c) = Tx + c.
3. Shift by the eigenvalue: define W' = W - μ with μ = tropRate(W).
4. Show T' has eigenvalue 0; find v with T'v = v.
5. Use the critical graph (subgraph of edges achieving equality) and a shortest-path construction.

**Hypotheses**:
- The eigenvector exists for all finite real matrices (not just irreducible ones)
- The critical graph is always nonempty
- The eigenvector can be constructed as a max-weight path from a reference vertex

**Impact**: Foundations for tropical control theory, dynamic programming verification.

**Cross-domain connections**: Optimal control, reinforcement learning value functions, Markov decision processes.

---

## Direction 4: Eventual Periodicity and Tropical Jordan Theory

**Status**: Medium priority, challenging feasibility

**Goal**: Prove that normalized tropical powers are eventually periodic, not just convergent.

**Formal target**:
```
theorem tropical_eventual_periodicity
    (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    ∃ (p : ℕ) (N : ℕ), p ≥ 1 ∧ ∀ m ≥ N, ∀ i j,
      tropPow W (m + p) i j = tropPow W m i j + p * tropRate W
```

**Proof Strategy**:
1. After subtracting the eigenvalue (working with W' = W - μ), the problem reduces to showing eventual periodicity of the shifted powers.
2. The critical graph has a structure (cyclicity = gcd of cycle lengths) that determines the period p.
3. Use the tropical eigenvector to show that powers stabilize modulo the period.

**Key sub-problems**:
- Define the critical graph formally
- Compute the cyclicity (gcd of critical cycle lengths)
- Prove the convergence to periodicity

**Impact**: Complete tropical Jordan normal form theory. Connects to tropical algebraic geometry.

**Cross-domain connections**: Algebraic geometry (tropical curves), automata theory (ultimate periodicity).

---

## Direction 5: Two-Player Mean-Payoff Games

**Status**: Medium priority, high impact, challenging feasibility

**Goal**: Extend the tropical Perron–Frobenius theorem to the minimax setting of two-player mean-payoff games.

**Formal target**:
```
theorem mean_payoff_game_value
    (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (player : Fin (n+1) → Bool)  -- vertex ownership
    : ∃ (v : Fin (n+1) → ℝ),
      ∀ i, v i = if player i then
        Finset.univ.sup' _ (fun j => W i j + v j)  -- Max player
      else
        Finset.univ.inf' _ (fun j => W i j + v j)  -- Min player
```

**Proof Strategy**:
1. Define the two-player Bellman operator combining max and min.
2. Use strategy improvement or value iteration to show convergence.
3. Connect to the determinacy theorem for mean-payoff games (Ehrenfeucht-Mycielski).

**Hypotheses**:
- The game value exists (determinacy)
- It can be computed in polynomial time (known but complex)
- It reduces to tropical spectral theory on the optimal strategy graph

**Impact**: Formal foundations for program verification (model checking with quantitative objectives).

**Cross-domain connections**: Program verification, reactive synthesis, automata theory.

---

## Direction 6: Extension to ℝ ∪ {−∞} (Full Max-Plus Algebra)

**Status**: Medium priority, medium feasibility

**Goal**: Extend all results to the full tropical semiring where matrix entries can be −∞ (representing absent edges).

**Key challenges**:
1. The graph is no longer complete; need explicit strong connectivity hypothesis.
2. Different SCCs may have different growth rates.
3. The spectral theorem applies per-SCC with a global decomposition.

**Formal target**:
```
def stronglyConnected (W : Matrix (Fin n) (Fin n) (WithBot ℝ)) : Prop := ...

theorem tropical_pf_irreducible
    (W : Matrix (Fin (n+1)) (Fin (n+1)) (WithBot ℝ))
    (hsc : stronglyConnected W) :
    ∃ λ, ∀ i j, ∃ finite walk from i to j →
      tropPow W m i j / m → λ
```

**Impact**: Handles sparse graphs, incomplete networks, and practical applications where not all connections exist.

---

## Direction 7: Tropical Representation Theory Connections

**Status**: Low priority (speculative), very high impact if successful

**Goal**: Connect tropical spectral theory to tropical Langlands and tropical representation theory.

**Hypothesis**: The maximum cycle mean of a tropical matrix associated to a reductive group encodes representation-theoretic data (character growth, weight multiplicities).

**Concrete sub-problems**:
1. For GL_n(ℝ((t))), the tropicalization of the Hecke algebra produces max-plus matrices whose spectral data encodes Satake parameters.
2. The tropical Perron–Frobenius eigenvalue of a Hecke operator should equal the tropical Satake parameter.
3. The eigenvector should be related to the tropical Whittaker function.

**Impact**: Would provide a formal bridge between combinatorial optimization and number theory/representation theory.

---

## Research Infrastructure Recommendations

### Team Structure
- **Core formalization team**: 2-3 people focused on Lean proofs
- **Algorithm verification**: 1 person on Karp's algorithm and variants
- **Applications**: 1 person connecting to scheduling, timing analysis, game theory
- **Theory development**: 1-2 people on eigenvectors, periodicity, Jordan theory

### Priority Ordering
1. Walk decomposition (Direction 1) — completes the current work
2. Karp's algorithm (Direction 2) — highest practical value
3. Bellman eigenvectors (Direction 3) — richest mathematical content
4. Eventual periodicity (Direction 4) — deepest structural result
5. Mean-payoff games (Direction 5) — broadest application scope

### Validation Protocol
For each direction:
1. State the main theorem precisely in Lean
2. Write computational tests (Python) to validate on examples
3. Identify the key lemmas and prove them bottom-up
4. Use the subadditive/Fekete infrastructure established here as a foundation
5. Document cross-domain applications with worked examples

---

## Timeline Estimate

| Direction | Estimated Effort | Dependencies |
|-----------|-----------------|--------------|
| 1. Walk decomposition | 2-4 weeks | None |
| 2. Karp's algorithm | 2-3 weeks | Direction 1 |
| 3. Bellman eigenvectors | 3-5 weeks | Direction 1 |
| 4. Eventual periodicity | 4-8 weeks | Directions 1, 3 |
| 5. Mean-payoff games | 6-10 weeks | Direction 3 |
| 6. Full max-plus | 3-5 weeks | Direction 1 |
| 7. Representation theory | 8+ weeks | Directions 1, 3 |

---

*This roadmap is designed so that each direction produces independently valuable formal mathematics while building toward a comprehensive tropical spectral theory.*
