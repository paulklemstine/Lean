# Future Directions: Certified Tropical Spectral Theory

This document outlines five concrete breakthrough research directions opened by the formalization of tropical max-plus spectral theory. Each direction includes a precise theorem target, significance, proof strategy, and cross-domain connections.

---

## 1. Tropical Collatz–Wielandt Formula

### Theorem Statement

For every `A : Matrix (Fin n) (Fin n) ℝ` with `n ≥ 1`:

```
λ(A) = inf {mu | ∃ v, IsTropicalSubeigenpair A mu v}
     = sup {cycleMean A c | c is a directed cycle in A}
```

The tropical spectral value simultaneously equals the infimum of all subeigenvector bounds AND the supremum of all cycle means.

### Why It Matters

This is the tropical analogue of the classical Collatz–Wielandt min-max characterization of the Perron–Frobenius eigenvalue. It provides a **duality theorem** bridging optimization (infimum characterization) and combinatorics (cycle mean supremum). It would complete the formal connection between our subeigenpair infrastructure and the cycle mean framework.

### Proof Strategy

1. The inequality `inf ≥ sup` follows from our `cycle_mean_le_of_subeigenpair` theorem.
2. The reverse `inf ≤ sup` requires showing that the maximum cycle mean admits a subeigenvector. Use the Bellman-Ford/shortest-path construction: define `v_i = max_{walk w from r to i} (walkWeight w - |w| * mu)` for `mu =` max cycle mean, and verify the subeigenpair condition.
3. Formalize simple cycle decomposition to reduce general cycles to simple ones.

### Cross-Domain Connection

**Operations Research / LP Duality**: The Collatz–Wielandt formula is a strong duality theorem for tropical linear programming. It connects to the feasibility/infeasibility threshold in difference constraint systems, bridging graph algorithms and optimization theory.

---

## 2. Ultimate Periodicity of Max-Plus Powers

### Theorem Statement

For every `A : Matrix (Fin n) (Fin n) ℝ` with `n ≥ 1` and spectral value `λ`, there exist `k₀, c ∈ ℕ` such that for all `k ≥ k₀`:

```
A^{⊗(k+c)} = λ^c · A^{⊗k}    (in the max-plus sense)
```

where `A^{⊗k}` denotes the k-th max-plus power and `λ^c · M` means adding `c·λ` to every entry.

### Why It Matters

This is the **max-plus analogue of the Perron–Frobenius convergence theorem**. It shows that the long-term behavior of max-plus linear dynamical systems is eventually periodic modulo linear drift. The cyclicity `c` is determined by the critical graph structure (specifically, the GCD of cycle lengths in the critical graph).

### Proof Strategy

1. Build on the CSR decomposition: partition vertices into critical and non-critical.
2. On the critical component, show the max-plus power is eventually periodic with period = cyclicity of the critical graph.
3. On non-critical components, show the contributions stabilize (dominated by critical growth).
4. Combine using the block structure of the tropical power.

### Cross-Domain Connection

**Discrete Event Systems**: Ultimate periodicity is the foundation for analyzing manufacturing systems, railway timetables, and communication protocols modeled as max-plus linear systems. A formally verified periodicity theorem would enable certified scheduling and timing analysis.

---

## 3. Mean-Payoff Game Duality

### Theorem Statement

For every `A : Matrix (Fin n) (Fin n) ℝ` with `n ≥ 1`:

The value of the deterministic mean-payoff game with payoff matrix `A` equals `λ(A)`, and the tropical eigenvector `v` provides the optimal positional strategy for both players.

Formally: define the game value at vertex `i` as
```
Val(i) = sup over infinite plays starting at i of (lim inf average payoff)
```

Then `Val(i) = λ(A)` for all `i` in the same strongly connected component, and the optimal strategy for Max is to choose the edge achieving the maximum in `A ⊗ v`.

### Why It Matters

This bridges tropical algebra and algorithmic game theory. Mean-payoff games are a fundamental model in verification (model checking of liveness properties) and have deep connections to parity games and the Zwick-Paterson algorithm. A formal proof would provide certified game solvers.

### Proof Strategy

1. Show that any tropical subeigenvector provides a lower bound on the game value (via the potential argument).
2. Show that the eigenvector achieves this bound (the optimal strategy follows the critical graph).
3. Use the telescoping/cycle mean bounds already formalized as the core engine.

### Cross-Domain Connection

**Formal Verification / Model Checking**: Mean-payoff games are polynomially equivalent to parity games, which decide the winner in μ-calculus model checking. A certified tropical spectral solver would give verified model checking for liveness properties.

---

## 4. Certified Karp Algorithm Correctness

### Theorem Statement

Formalize Karp's dynamic programming algorithm and prove it computes the maximum cycle mean exactly:

```lean
theorem karp_algorithm_correct (A : Matrix (Fin n) (Fin n) ℝ) (hn : 0 < n) :
    karpValue A hn = maxCycleMean A hn
```

where `karpValue` is defined via the DP recurrence:
```
dp 0 i = 0
dp (k+1) i = max_j (A i j + dp k j)
karpValue = max_i min_{0≤k≤n-1} (dp n i - dp k i) / (n - k)
```

### Why It Matters

Karp's algorithm is one of the most widely used algorithms in operations research and scheduling, yet its correctness has never been formally verified. A machine-checked proof would establish trust in critical infrastructure that depends on cycle mean computation (railway scheduling, chip timing analysis, network optimization).

### Proof Strategy

1. Formalize the DP recurrence (dp k i = max weight walk of length k starting at i).
2. Prove Karp's formula using the "walk decomposition" argument: every walk of length n can be decomposed into a cycle and a shorter walk.
3. Show the min over k selects the cycle with maximum mean.
4. Use our existing walkWeight and cycleMean infrastructure.

### Cross-Domain Connection

**Computer Science / Algorithm Verification**: This would be among the first formally verified graph optimization algorithms in Lean 4. The verification methodology generalizes to other DP-based graph algorithms (Bellman-Ford, Floyd-Warshall, Johnson's algorithm).

---

## 5. Tropical Neural Fixed-Point Certificates

### Theorem Statement

For a ReLU neural network with weight matrices `W₁, ..., W_L` and bias vectors `b₁, ..., b_L`, define the tropical representation:

```
T(x)_i = max_j (W[i,j] + x[j])   (without ReLU)
```

The tropical eigenvector of the composed weight matrix certifies the existence of a fixed direction: an input `x*` such that the network output is a scalar shift of `x*`.

### Why It Matters

ReLU networks are piecewise-linear functions, and tropical geometry provides the natural algebraic framework for analyzing their behavior. Tropical eigenvectors correspond to invariant directions of the max-affine operator, which characterize:
- Adversarial robustness certificates
- Network expressivity bounds
- Training dynamics attractors

### Proof Strategy

1. Define the tropical composition of weight matrices as max-plus matrix multiplication.
2. Apply the tropical eigenvector existence theorem to the composed matrix.
3. Show that the eigenvector direction is invariant under the tropical action.
4. Extend to handle bias terms via affine tropical algebra.
5. Connect to Lipschitz constant bounds via the spectral value.

### Cross-Domain Connection

**Machine Learning / AI Safety**: Certified robustness bounds for neural networks are a critical open problem. Tropical spectral certificates provide dimension-independent bounds that don't suffer from the exponential blowup of polytope enumeration methods. A formally verified version would provide provable safety guarantees.

---

## Research Team Directive

Each direction should be pursued by a team with:
- **Hypothesis**: Clear mathematical conjecture to test
- **Proof Strategy**: Decomposition into 5-10 lemmas with informal sketches
- **Validation**: Computational experiments in Python before formalization
- **Cross-domain Expert**: At least one team member from the application domain
- **Iteration Protocol**: Weekly proof attempts with subagent, adjusting decomposition based on failures

The most impactful near-term target is **Direction 4 (Certified Karp Algorithm)**, as it builds most directly on the existing infrastructure and has immediate practical applications. **Direction 1 (Collatz-Wielandt)** provides the theoretical foundation for all other directions and should be pursued in parallel.
