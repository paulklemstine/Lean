# Future Directions: Certified Tropical Spectral Theory

## 1. Tropical Collatz–Wielandt Variational Formula

**Theorem statement:**
For any matrix `A : Matrix (Fin n) (Fin n) ℝ` with `n ≥ 1`:
```
tropSpec A = sup { μ | ∃ v, IsTropicalSubeigenpair A μ v }
           = max_{cycles C} weight(C) / |C|
           = inf { μ | ∃ v, IsTropicalSupereigenpair A μ v }
```

**Why it matters:** This minimax characterization is the tropical analogue of the classical Collatz–Wielandt formula for Perron eigenvalues. Our work proves the first equality; the full formula adds the supereigenvector dual, creating a complete variational picture. This is the foundation for sensitivity analysis—how does λ change when matrix entries change?

**Proof strategy:** The hard direction (infimum of supereigenvector bounds = max cycle mean) requires constructing a supereigenvector from a minimizing sequence. Use the potential construction with min-plus duality: if `v` is a max-plus subeigenvector at `μ`, then `-v` gives constraints in the dual direction. Combine with the compactness of the feasibility threshold.

**Cross-domain connection:** Linear programming duality. The Collatz-Wielandt formula is a strong duality theorem for a tropical LP. It connects to the LP relaxation of mean-payoff games and to sensitivity analysis in scheduling.

## 2. Ultimate Periodicity of Max-Plus Matrix Powers

**Theorem statement:**
For `A : Matrix (Fin n) (Fin n) ℝ` with tropical eigenvalue λ, there exist `T, p ≥ 1` such that for all `k ≥ T`:
```
tropPow A (k + p) i j = tropPow A k i j + p * λ
```
where `tropPow` is iterated tropical matrix multiplication.

**Why it matters:** This is the max-plus cyclicity theorem—the tropical analogue of the Perron-Frobenius theorem on primitive matrix convergence. It says that max-plus linear dynamical systems are eventually periodic with linear drift. This is fundamental for:
- Predicting long-run behavior of production systems
- Computing steady-state schedules
- Analyzing periodic orbits in discrete event systems

**Proof strategy:**
1. Prove that `tropPow A k i j - k * λ` is bounded (using the subeigenvector bound).
2. Show this shifted sequence is eventually periodic by the finite graph structure.
3. The period `p` divides the lcm of cycle lengths in the critical graph (cyclicity).
4. Use the critical graph structure from our eigenvector theorem to determine the transient length `T`.

**Cross-domain connection:** Dynamical systems and automata theory. The periodicity corresponds to eventual regularity of weighted automaton outputs and to periodic scheduling in manufacturing.

## 3. Mean-Payoff Game Value Duality

**Theorem statement:**
For a weighted directed graph encoded by `A : Matrix (Fin n) (Fin n) ℝ`, the value of the one-player mean-payoff game (where the player maximizes long-run average weight) equals `tropSpec A`:
```
∀ i, gameValue A i = tropSpec A
```
where `gameValue A i = lim_{k→∞} (tropPow A k i i) / (k + 1)`.

For the two-player version with matrices `A` (maximizer edges) and `B` (minimizer edges):
```
∃ v, ∀ i, maxₖ (A i k + v k) ≥ λ + v i ∧ minₖ (B i k + v k) ≤ λ + v i
```

**Why it matters:** Mean-payoff games are a central object in theoretical computer science with applications to:
- Model checking (the μ-calculus model checking problem reduces to MPGs)
- Synthesis of reactive systems
- Algorithmic game theory

Our eigenvector theorem provides the algebraic certificate for game values. Extending it to two-player games would connect tropical spectral theory to one of the most important open algorithmic problems (polynomial-time solvability of mean-payoff games).

**Proof strategy:** For the one-player case, use the superadditive ergodic theorem for tropical powers: `tropPow A k i i ≥ (k+1) * λ` (from eigenvector existence) and `tropPow A k i i ≤ (k+1) * λ + C` (from boundedness). For two-player games, use the tropical fixed-point theorem on the Shapley operator.

**Cross-domain connection:** Verification and synthesis. A formal tropical game value theorem would be a certified building block for model checkers.

## 4. Certified Karp Algorithm Correctness

**Theorem statement:**
```
theorem karp_algorithm_correct (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) :
    let dp := fun k i => bestWalk hn A i k
    tropSpec hn A = Finset.sup' univ univ_nonempty
      (fun i => Finset.inf' (Finset.range n) ⟨0, mem_range.mpr hn⟩
        (fun k => (dp n i - dp k i) / (n - k)))
```

**Why it matters:** Karp's algorithm is the standard O(n³) method for computing cycle means. Certifying its correctness means:
- Verified implementations for safety-critical scheduling systems
- Trusted optimization primitives for certified compilers
- A template for certifying other dynamic programming algorithms

**Proof strategy:**
1. Show `dp n i - dp k i ≤ (n - k) * tropSpec A` for all i, k (from subeigenvector existence).
2. Show equality is achieved for the optimal cycle by tracking which walks achieve the dp values.
3. The min-over-k formulation is Karp's insight: at the optimal vertex, the minimum over k gives exactly λ.
4. Formalize the DP recurrence `dp (k+1) i = max_j (A i j + dp k j)` and prove it matches bestWalk.

**Cross-domain connection:** Certified algorithms and static analysis. Karp's algorithm is used in WCET (Worst-Case Execution Time) analysis for real-time systems. A certified version would be directly applicable to safety-critical system verification.

## 5. Tropical Fixed-Point Certificates for Piecewise-Linear Systems

**Theorem statement:**
For a max-affine operator `T : (Fin n → ℝ) → (Fin n → ℝ)` defined by
```
T(x)_i = max_j (A i j + x j + b i j)
```
if `A` has tropical eigenvalue `λ < 0`, then `T` has a unique fixed point, and the iteration `x_{k+1} = T(x_k)` converges to it at rate `|λ|`.

**Why it matters:** ReLU neural networks compute piecewise-linear functions. Each layer is a max-affine map (after applying ReLU). The tropical eigenvalue controls:
- Whether the network amplifies or attenuates signals
- The rate of convergence of iterative inference
- Robustness certificates (Lipschitz bounds from spectral analysis)

A formal tropical fixed-point theorem would enable certified analysis of neural network properties without training or simulation.

**Proof strategy:**
1. Prove the max-affine operator is order-preserving and additively homogeneous.
2. Apply the nonlinear Perron-Frobenius theorem (Nussbaum, 1988): such operators have a spectral radius equal to the tropical eigenvalue.
3. When λ < 0, the operator is contracting in the Hilbert projective metric.
4. Conclude unique fixed point and geometric convergence.

**Cross-domain connection:** Neural network verification. This would provide the first tropical spectral certificates for deep learning systems, enabling mathematically guaranteed bounds on network behavior.

---

## Research Infrastructure Roadmap

### Near-term (building on current results):
- Formalize Karp's DP recurrence and prove equivalence with tropSpec
- Prove cyclicity theorem for irreducible matrices
- Implement certified tropical eigenvalue computation in Lean 4

### Medium-term (new theory):
- Two-player mean-payoff game formalization
- Tropical Perron-Frobenius for reducible matrices (block structure)
- Connection to weighted automata and formal language theory

### Long-term (cross-domain applications):
- Certified scheduling algorithms for real-time systems
- Tropical certificates for neural network robustness
- Max-plus linear model predictive control with formal guarantees
