# Future Directions: Tropical Spectral Theory and Computational Lower Bounds

## Overview

The results formalized in this project — connecting cycle-gap arguments to tropical spectral bounds and branching program complexity — open a substantial corridor of research opportunities. Below are five concrete, breakthrough-level directions, each with specific hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Tropical Collatz–Wielandt Formalization

### Vision
Characterize the maximum cycle mean λ(W) as the solution to a tropical optimization problem analogous to the classical Collatz–Wielandt minimax formula for the Perron–Frobenius eigenvalue.

### Specific Target
Formalize and prove:
```
λ(W) = inf { λ ∈ ℝ | ∃ x : Fin n → ℝ, ∀ i, max_j (W_{ij} + x_j) ≤ λ + x_i }
```
This says λ(W) is the smallest "tropical eigenvalue" for which a tropical subeigenvector exists.

### Proof Strategy
1. Define tropical subeigenvectors: vectors x satisfying W ⊗ x ≤ λ ⊗ x componentwise.
2. Show that the set of valid λ is closed and bounded below by the maximum cycle mean.
3. Construct an explicit subeigenvector for λ = maxCycleMean using shortest-path potentials.
4. Show no subeigenvector exists for λ < maxCycleMean by extracting a violating cycle.

### Key Lemmas to Formalize
- `tropSubeigenvector_exists_iff`: existence characterization via cycle means
- `maxCycleMean_eq_inf_subeigen`: the Collatz–Wielandt identity
- `shortest_path_potential`: construction from Bellman–Ford

### Cross-Domain Impact
- **Optimization**: provides dual certificates for max cycle mean computations
- **Game theory**: connects to strategy potentials in mean-payoff games
- **Tropical geometry**: characterizes the tropical eigenvariety

### Feasibility: High
All ingredients exist in Mathlib (finite optimization, inf/sup characterizations). The key challenge is managing the tropical arithmetic formalism cleanly.

---

## Direction 2: Max-Plus Perron–Frobenius for Irreducible Matrices

### Vision
For irreducible (strongly connected) weight matrices, prove the strong tropical Perron–Frobenius theorem: the tropical power W^⊗k converges (up to additive shift) to a periodic pattern with period dividing n, and the shift per period is exactly n · λ(W).

### Specific Target
Formalize:
```
theorem tropPow_eventual_periodicity (W : Matrix (Fin n) (Fin n) ℝ) (hirr : Irreducible W) :
    ∃ γ : ℕ, γ ≥ 1 ∧ γ ∣ n ∧ ∀ᶠ k in atTop,
      tropPow W (k + γ) = tropPow W k + (γ * maxCycleMean W) • 1
```

### Proof Strategy
1. Define irreducibility for tropical matrices (every vertex is reachable from every other).
2. Prove the critical graph structure: the subgraph of edges on maximum-mean cycles.
3. Show the critical graph has a well-defined cyclicity γ (gcd of critical cycle lengths).
4. Prove eventual periodicity with period γ using the critical graph decomposition.

### Prerequisites
- SCC decomposition formalized in Lean (partially available)
- GCD of a finite set of natural numbers (available in Mathlib)
- Eventual filter reasoning (Mathlib's `Filter.Eventually`)

### Cross-Domain Impact
- **Discrete event systems**: characterizes steady-state behavior of timed Petri nets
- **Tropical geometry**: provides algebraic structure for tropical eigenspaces
- **Control theory**: gives stability criteria for max-plus linear systems

### Feasibility: Medium-High
Requires significant graph theory infrastructure but all mathematical steps are well-understood. The cyclicity argument is the most technically demanding part.

---

## Direction 3: Mean-Payoff Game Certification from Tropical Eigenvalues

### Vision
Formalize the equivalence between the value of a mean-payoff game and the maximum cycle mean, then provide certified optimal strategies.

### Specific Target
Given a two-player mean-payoff game on a weighted graph:
```
def meanPayoffValue (G : GameGraph n) : ℝ := ...

theorem meanPayoff_eq_maxCycleMean (G : GameGraph n) :
    meanPayoffValue G = maxCycleMean (toWeightMatrix G)
```

For the single-player (optimization) version, this is exactly our spectral bound. The two-player version requires minimax duality.

### Proof Strategy
1. Define mean-payoff games with alternating Max/Min players.
2. Formalize positional determinacy: optimal strategies can be memoryless.
3. Reduce to cycle analysis: every memoryless strategy induces a tropical matrix.
4. Apply maxCycleMean characterization to each strategy matrix.
5. Use LP duality or strategy improvement to show the minimax equals the cycle mean.

### Key Lemmas
- `positional_determinacy`: optimal strategies are positional
- `strategy_induces_matrix`: each positional strategy gives a tropical matrix
- `minimax_cycle_mean`: the game value equals the saddle point of cycle means

### Cross-Domain Impact
- **Formal verification of controllers**: certified optimal strategies for reactive systems
- **Model checking**: mean-payoff objectives in LTL/CTL model checking
- **Algorithmic game theory**: certified solvers for mean-payoff and energy games

### Feasibility: Medium
The single-player case is immediate from our work. The two-player extension requires game-theoretic infrastructure not yet in Mathlib.

---

## Direction 4: Periodic Branching Program Lower Bounds

### Vision
Prove explicit lower bounds on the width of periodic branching programs computing specific target functions, using the spectral obstruction from Direction 1.

### Specific Target
```
theorem width_lower_bound_for_multiplication :
    ∀ w : ℕ, (∀ W : Matrix (Fin w) (Fin w) ℝ, maxCycleMean W < targetGrowthRate) →
      ¬ computableByPeriodicBP w targetFunction
```

### Proof Strategy
1. Define "computable by periodic BP" formally.
2. Show that if a function has growth rate exceeding λ(W) for all w×w matrices, no width-w periodic BP can compute it.
3. Construct explicit functions (e.g., iterated tropical multiplication) whose growth rate exceeds any bounded-width spectral bound.
4. Use the spectral gap: for w×w random matrices, λ(W) concentrates around a value that grows with w, giving explicit width lower bounds.

### Key Innovation
This would be the first formal proof technology using tropical spectral theory for computational lower bounds. The approach is:
- Target function has growth rate R(d) at depth d
- Any width-w BP has growth rate ≤ w · maxEdgeWeight per step
- Spectral refinement: actual growth rate is ≤ λ(W) per step
- If R(d)/d > max_{w×w matrices} λ(W), width w is insufficient

### Cross-Domain Impact
- **Circuit complexity**: new proof technique for restricted circuit classes
- **Communication complexity**: tropical branching programs model nondeterministic communication
- **Streaming algorithms**: width corresponds to space, depth to passes

### Feasibility: Medium-Low
Requires formalizing the computation model and connecting it to tropical linear algebra. Conceptually clear but technically demanding.

---

## Direction 5: Tropical Entropy and Information-Flow Invariants

### Vision
Define a tropical entropy measure H_trop(W) that captures the "information content" of a tropical matrix, analogous to Shannon entropy for stochastic matrices, and prove that it governs the complexity of tropical computations.

### Specific Target
```
def tropEntropy (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  -- Tropical analogue of entropy based on cycle structure

theorem tropEntropy_bounds_complexity :
    tropEntropy W ≤ f(maxCycleMean W, n)

theorem tropEntropy_monotone_under_composition :
    tropEntropy (tropMul A B) ≤ tropEntropy A + tropEntropy B
```

### Proof Strategy
1. Define tropical entropy using the distribution of cycle means across SCCs.
2. Show it is subadditive under tropical multiplication (information doesn't increase).
3. Connect to the maximum cycle mean: entropy captures the "diversity" of spectral behavior.
4. Prove that functions requiring high tropical entropy cannot be computed by low-entropy (narrow) branching programs.

### Possible Definitions
- **Cycle mean spectrum entropy**: H = -Σ p_i log p_i where p_i is the normalized contribution of each SCC's cycle mean
- **Walk weight entropy**: H(k) = log(#{distinct walk weights at length k}) / k
- **Tropical rank entropy**: based on the tropical rank of successive powers

### Cross-Domain Impact
- **Information theory**: tropical analogue of channel capacity
- **Cryptography**: tropical entropy as a hardness measure for tropical cryptosystems
- **Machine learning**: tropical entropy of weight matrices as a complexity measure for ReLU networks
- **Ergodic theory**: connects to Lyapunov exponents of products of tropical matrices

### Feasibility: Exploratory
This is the most speculative direction but potentially the most impactful. Initial formalization of definitions is straightforward; the deep theorems would require novel mathematical insights.

---

## Prioritization and Dependencies

```
Direction 1 (Collatz-Wielandt)     ← Most natural next step, builds directly on current work
    ↓
Direction 2 (Perron-Frobenius)     ← Requires Direction 1's subeigenvector theory
    ↓
Direction 3 (Mean-Payoff Games)    ← Can start independently, benefits from Direction 2
    ↓
Direction 4 (BP Lower Bounds)      ← Requires Directions 1-2 for spectral tools
    ↓
Direction 5 (Tropical Entropy)     ← Exploratory, can proceed in parallel
```

### Recommended Team Structure
- **Team A** (Algebra): Directions 1 and 2 — tropical spectral theory core
- **Team B** (Complexity): Direction 4 — computational lower bounds
- **Team C** (Applications): Directions 3 and 5 — games, entropy, verification
- **Integration**: Regular sync between teams to ensure compatible formalizations

### Timeline Estimate
- Direction 1: 2-4 weeks for full formalization
- Direction 2: 4-8 weeks (depends on SCC infrastructure)
- Direction 3: 3-6 weeks (single-player case fast, two-player harder)
- Direction 4: 6-12 weeks (requires new formalization patterns)
- Direction 5: Ongoing exploration, initial results in 4-8 weeks
