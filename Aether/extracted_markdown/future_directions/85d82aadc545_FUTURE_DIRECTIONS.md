# Future Directions: Certified Optimal Transport Theory

## Synthesis

Our certified discrete optimal transport development establishes weak duality, complementary slackness, the gluing lemma with triangle inequality, WGAN critic stability, and the quadratic swap inequality. These results form a verified bridge connecting transport geometry to adversarial machine learning.

The natural next steps fall into two categories: **grand challenges** that would represent paradigm shifts in verified mathematics (strong duality, full Brenier theorem, continuous extensions), and **solid extensions** that build directly on our proven results (cyclical monotonicity from complementary slackness, entropy regularization, Wasserstein metric properties). Each direction below identifies a specific falsifiable hypothesis with computational tests.

---

## Direction 1: Strong Kantorovich Duality via Verified Finite LP Duality

**Conjecture:** For finite types α, β with any cost function c : α → β → ℝ and probability distributions μ, ν, the primal optimal transport value equals the dual optimal value:
$$\inf_\pi \text{transportCost}(c, \pi) = \sup_{(\varphi,\psi) \text{ admissible}} \text{dualValue}(\mu, \nu, \varphi, \psi)$$

**Test:** Verify numerically on all cost matrices with entries in {0,1,2,3} on spaces of size ≤ 4, checking that LP primal and dual solutions have zero gap. Then attempt formalization via a verified Farkas lemma for the coupling polytope.

**Impact:** Strong duality completes the Kantorovich theory and unlocks the characterization of Wasserstein distance via 1-Lipschitz dual potentials (Kantorovich-Rubinstein duality). This would make the WGAN stability theorem tight rather than merely an upper bound.

**Catalog References:** `MachineLearning/OptimalTransport/Theorems.lean` (weak_duality, complementary_slackness)

**Proof Strategy:** Encode the coupling constraints as a matrix LP. Prove a finite-dimensional Farkas lemma (either from scratch or leveraging Mathlib's convex analysis). Apply to the coupling polytope to establish strong duality. Extract dual optimal potentials.

**Domain Bridges:** Convex optimization → LP duality → combinatorial optimization → game theory (minimax theorems)

**Lineage:** Extends weak_duality (Theorem 1) to equality. Prerequisite for Wasserstein metric identity of indiscernibles.

**Ambition:** Grand challenge — would be the first verified strong LP duality theorem applied to optimal transport.

---

## Direction 2: Cyclical Monotonicity of Optimal Supports

**Conjecture:** If π is an optimal coupling (achieving minimum transport cost) and (φ, ψ) are dual-optimal potentials with transportCost(c, π) = dualValue(μ, ν, φ, ψ), then the support {(a,b) | π(a,b) > 0} is c-cyclically monotone: for any finite cycle (a₁,b₁), ..., (aₙ,bₙ) in the support and any permutation σ,
$$\sum_i c(a_i, b_i) \leq \sum_i c(a_i, b_{\sigma(i)})$$

**Test:** Generate 10,000 random OT instances on spaces of size 5-8. Solve for optimal couplings. Check cyclical monotonicity by exhaustive enumeration of cycles of length ≤ 6. A single violation refutes the conjecture.

**Impact:** Cyclical monotonicity is the geometric fingerprint of optimal transport. It is the discrete shadow of Brenier's theorem and the entry point for convex potential theory.

**Catalog References:** `MachineLearning/OptimalTransport/Theorems.lean` (complementary_slackness)

**Proof Strategy:** From complementary slackness, the support is contained in {(a,b) | φ(a) + ψ(b) = c(a,b)}. For any cycle in this set, sum the equalities: ∑ c(aᵢ,bᵢ) = ∑ φ(aᵢ) + ∑ ψ(bᵢ). For the permuted cycle, use admissibility: ∑ c(aᵢ,b_{σ(i)}) ≥ ∑ φ(aᵢ) + ∑ ψ(b_{σ(i)}) = ∑ φ(aᵢ) + ∑ ψ(bᵢ). The inequality follows.

**Domain Bridges:** Convex analysis → monotone operator theory → PDE (Monge-Ampère) → matching theory

**Lineage:** Direct consequence of complementary_slackness. Prerequisite for discrete Brenier theorem.

**Ambition:** Solid extension — logically follows from existing results but requires careful cycle enumeration formalization.

---

## Direction 3: Wasserstein-1 as a Certified Metric

**Conjecture:** On a finite metric space (α, d), define W₁(μ, ν) = inf_π transportCost(d, π). Then W₁ satisfies:
1. W₁(μ, ν) ≥ 0
2. W₁(μ, ν) = W₁(ν, μ) 
3. W₁(μ, ν) = 0 ↔ μ = ν
4. W₁(μ, ρ) ≤ W₁(μ, ν) + W₁(ν, ρ)

**Test:** Property (3, →) requires strong duality. Computationally verify on all distributions on spaces of size ≤ 5 that W₁ = 0 implies identical weight vectors.

**Impact:** Establishing W₁ as a formal metric makes the space of probability distributions a verified metric space, enabling convergence theory, gradient flows, and stability analysis.

**Catalog References:** `MachineLearning/OptimalTransport/Wasserstein.lean` (gluedCoupling_cost_le, transportCost_identity_eq_zero, transportCost_reverse)

**Proof Strategy:** (1) from transportCost_nonneg. (2) from transportCost_reverse + infimum symmetry. (4) from gluedCoupling_cost_le. (3, →) from strong duality + identity coupling. (3, ←) from d(a,b) = 0 ↔ a = b + LP uniqueness argument.

**Domain Bridges:** Metric geometry → probability theory → functional analysis → machine learning convergence theory

**Lineage:** Builds on gluing lemma (Theorem 6-7), identity coupling, and reverse coupling.

**Ambition:** Solid extension — properties (1,2,4) are accessible now; (3) requires Direction 1.

---

## Direction 4: Entropy-Regularized Transport and Sinkhorn Convergence

**Conjecture:** For the entropy-regularized optimal transport problem with parameter ε > 0:
$$\min_\pi \sum_{a,b} c(a,b)\pi(a,b) + \varepsilon \sum_{a,b} \pi(a,b)\log\pi(a,b)$$
the Sinkhorn algorithm converges linearly at rate (1 - ε/C)^k for a computable constant C depending on the cost matrix and distributions.

**Test:** Run Sinkhorn on 1000 random instances for ε ∈ {0.01, 0.1, 1.0}. Measure convergence rate and compare with theoretical prediction. Verify that regularized cost converges monotonically to exact cost as ε → 0.

**Impact:** Sinkhorn is the dominant computational method for large-scale OT. Certifying its convergence would provide verified bounds on approximation quality, critical for applications in ML training pipelines.

**Catalog References:** `MachineLearning/OptimalTransport/Basic.lean` (FinProb, Coupling, transportCost)

**Proof Strategy:** Define the entropy-regularized problem. Show the Sinkhorn fixed point corresponds to the KKT conditions. Prove linear convergence via Hilbert metric contraction on the positive cone. Bound the regularization gap using entropy properties.

**Domain Bridges:** Information theory → convex optimization → numerical analysis → large-scale ML → computational biology

**Lineage:** Extends the primal formulation with an entropy penalty. Uses FinProb and Coupling structures directly.

**Ambition:** Grand challenge — Sinkhorn convergence with formal rate bounds would be a breakthrough in verified numerical algorithms.

---

## Direction 5: Discrete Brenier Graph Sparsity

**Conjecture (Discrete Brenier Graph Sparsity).** For any optimal coupling for quadratic cost on n source and m target points in ℝ^d in general position, there exists a dual-optimal potential pair whose equality graph has at most n + m - 1 active edges.

**Test:** Generate random finite point clouds (n, m ≤ 20, d ≤ 3) and solve the primal/dual LP. Count equality edges in a dual-optimal certificate. A single instance with strictly more than n + m - 1 active edges refutes the conjecture.

**Impact:** This sparsity bound, if true, implies that optimal transport plans on finite spaces have combinatorial complexity linear in the support sizes — a dramatic structural constraint with implications for algorithm design.

**Catalog References:** `MachineLearning/OptimalTransport/Theorems.lean` (complementary_slackness, quadratic_swap_inequality)

**Proof Strategy:** Use LP basis theory: the coupling polytope has m + n - 1 equality constraints (after removing one redundancy), so a basic feasible solution has at most m + n - 1 nonzero entries. The dual-optimal equality graph corresponds to the support of a basic optimal solution.

**Domain Bridges:** Linear programming → combinatorics → graph theory → computational geometry → algorithm design

**Lineage:** Combines complementary slackness with LP basis theory. The quadratic swap inequality provides the geometric structure for 1D specialization.

**Ambition:** Solid extension — the LP basis argument is classical but formalizing it requires verified LP theory.
