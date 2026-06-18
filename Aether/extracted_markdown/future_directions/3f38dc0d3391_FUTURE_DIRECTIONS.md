# Future Directions: Mathematical Uncanny Valley Theory

## Synthesis

This cycle established the mathematical foundations of the uncanny valley phenomenon for proofs. We proved that the asymmetric suspicion kernel k²(n−k) exhibits a genuine uncanny valley—an effect absent from the symmetric kernel k(n−k)—and that this valley deepens quadratically with proof length. The most promising cross-domain connection emerged between **proof architecture complexity** (Bridges/Basic.lean's walk counts and branching obstructions) and our suspicion kernels: both exhibit superlinear growth phenomena that make partial completion exponentially more problematic than either full completion or no attempt at all.

The cycle's results connect naturally to the Catalog's optimization gap theorems (BreakthroughDirections.lean) through the "last mile" phenomenon: in both optimization and proof trust, the final increment of quality is disproportionately valuable. The depth advantage theorem (`depth_advantage` in BreakthroughDirections.lean) parallels our valley depth growth theorem—both show that scaling up (deeper networks / longer proofs) amplifies structural phenomena (expressiveness gaps / trust gaps). The most promising direction for breakthrough is **Direction 1** (Positional Suspicion), which would bridge the suspicion kernel formalism with the digraph walk model from Bridges/Basic.lean, creating a unified theory of proof complexity and trust.

The Valley Monotonicity Conjecture was stated, computationally verified for n up to 1000, and then formally proved using integer casting and nlinarith. This validates the core theoretical framework: below the valley peak at 2n/3, each additional verified step strictly increases suspicion.

---

### Direction 1: Positional Suspicion Kernels on Proof DAGs

**Conjecture**: Let G = (V, E) be a directed acyclic graph representing a proof, where each vertex is a logical step and edges represent dependencies. Define the *positional suspicion* of a partial verification S ⊆ V as:

P(S, G) = |S|² · max_{v ∈ V \ S} (depth(v) · in-degree(v))

Then for any DAG with branching obstruction (in the sense of `HasBranchingObstruction` from Bridges/Basic.lean), the positional suspicion at |S| = 2|V|/3 exceeds the suspicion at |S| = |V|/3.

**Test**: Construct 1000 random DAGs with 20-50 vertices, branching factor 2-4, and depth 5-10. For each, compute positional suspicion at 1/3 and 2/3 completion. The conjecture predicts the 2/3 value is always larger.

**Impact**: If true, this unifies the uncanny valley theory with proof architecture complexity theory. The `finite_digraph_walk_count_le` bound from Bridges/Basic.lean would give an upper bound on suspicion through the walk count, connecting trust to computational search space size. If false, the failure would reveal that graph structure can create "safe harbors" in the uncanny valley—positions where partial verification is locally stable.

**Catalog References**: `Bridges/Basic.lean` (DigraphWalk, HasBranchingObstruction, finite_digraph_walk_count_le), `Bridges/BreakthroughDirections.lean` (depth_advantage, architecture_comparison)

**Proof Strategy**: 
1. Define `PositionalSuspicion` on DAGs as a function of the verified subset
2. Prove that for DAGs without branching (linear chains), positional suspicion reduces to the scalar kernel k²(n−k)
3. Use the branching obstruction to show multiplicative amplification at high completion
4. Apply `finite_digraph_walk_count_le` to bound the maximum depth factor

**Domain Bridges**: Bridges <-> Computation, Algebra <-> Logic

**Lineage**: Builds on `uncanny_valley_ordering`, `valley_position_asymmetry`, and `HasBranchingObstruction` from Bridges/Basic.lean

**Ambition**: grand_challenge

---

### Direction 2: Information-Theoretic Suspicion and Entropy Bounds

**Conjecture**: Define the *suspicion entropy* of a proof of length n at completion level k as:

H_s(k, n) = -log₂(1 - k²(n−k)/n³)

Then H_s satisfies a chain rule: for a proof composed of two independent sub-proofs of lengths n₁ and n₂ with completions k₁ and k₂:

H_s(k₁ + k₂, n₁ + n₂) ≤ H_s(k₁, n₁) + H_s(k₂, n₂) + log₂(n₁ + n₂)

This sub-additivity bound (up to a logarithmic correction) would establish that combining proofs cannot reduce suspicion faster than the sum of their individual suspicions.

**Test**: Compute H_s for all pairs (n₁, n₂) with n₁, n₂ ∈ {3, ..., 50} and all valid (k₁, k₂). Verify the inequality numerically. A single counterexample disproves the conjecture.

**Impact**: If true, this connects the uncanny valley to information theory and provides a framework for analyzing modular proofs. It would explain why large collaborative proofs (like the classification of finite simple groups) accumulate suspicion: the logarithmic correction grows slowly, so the total suspicion of a composite proof is approximately the sum of its parts. If false, it would reveal that proof composition can create destructive interference in suspicion—combining suspicious sub-proofs could yield a less suspicious whole.

**Catalog References**: `Computation/InfoEfficientAlgorithms.lean` (InfoEfficientAlgorithm, terminates_within_potential), `EML/AdvancedTheory.lean` (ensembleComplexity, ensemble_complexity_additive)

**Proof Strategy**:
1. Formalize suspicion entropy as a real-valued function using Mathlib's `Real.log`
2. Prove the trivial bound H_s(k, n) ≤ log₂(n) from the normalization k²(n−k) ≤ 4n³/27
3. For the chain rule, use the AM-GM inequality on the cross terms
4. The logarithmic correction should follow from concavity of log

**Domain Bridges**: Computation <-> Bridges, EML <-> Bridges

**Lineage**: Builds on `integral_valley_dominance`, `trust_recovery_at_full_rigor`, and `ensemble_complexity_additive` from EML

**Ambition**: grand_challenge

---

### Direction 3: Empirical Calibration of the Suspicion Exponent

**Conjecture**: The general asymmetric suspicion kernel k^α · (n−k)^β with α > β > 0 has its valley peak at k = αn/(α+β). For real mathematical proofs, the empirically optimal parameters are α ≈ 2.3 ± 0.3 and β ≈ 0.8 ± 0.2, as measured by survey data on mathematician trust at varying rigor levels.

**Test**: Design a survey presenting 100 mathematicians with proof excerpts at 5 rigor levels (k/n = 0, 0.25, 0.5, 0.75, 0.95, 1.0) for 10 different theorems. Fit the suspicion kernel parameters α, β by maximum likelihood. The conjecture predicts α/β ≈ 2.9, placing the valley peak at roughly k/n ≈ 0.74.

**Impact**: If the empirical α/β ratio matches the theoretical prediction of 2 (from our k²(n−k) kernel, which has α=2, β=1), the theory is validated. If α/β is significantly different (e.g., > 4 or < 1.5), the kernel shape needs revision. Either outcome advances the field: confirmation establishes the theory, and refutation provides calibration data for a better model.

**Catalog References**: `Bridges/UncannyValley.lean` (asymSuspicion, SuspicionProfile, uncanny_valley_ordering)

**Proof Strategy**: 
1. Formalize the generalized kernel k^α(n−k)^β in Lean using real-valued exponents
2. Prove that the continuous maximum is at k = αn/(α+β) using calculus lemmas from Mathlib
3. Prove that the uncanny valley ordering holds if and only if α > β
4. Connect to the discrete kernel via floor/ceiling bounds

**Domain Bridges**: Bridges <-> MachineLearning (survey design), Algebra <-> Bridges (generalized kernels)

**Lineage**: Builds on `asymSuspicion`, `uncanny_valley_ordering`, `valley_position_asymmetry`

**Ambition**: extension

---

### Direction 4: Tropical Suspicion and the Proof Complexity Barrier

**Conjecture**: Define the *tropical suspicion* of a proof using the tropical semiring (max-plus algebra):

T_trop(k, n) = max(2·log(k), log(n−k))

(where log is taken in the tropical sense as a formal variable). Then the tropical suspicion exhibits a phase transition: for k < 2n/3, the first term dominates (suspicion grows with verification effort), and for k > 2n/3, the second term dominates (suspicion shrinks as gaps close). The phase transition point is exactly the valley peak.

This connects the uncanny valley to tropical geometry, where the asymmetric kernel k²(n−k) is the "classical" lift of the tropical kernel max(2k, n−k).

**Test**: Compute the tropical and classical kernels for n = 10, 100, 1000. Verify that the tropical phase transition point converges to the classical valley peak (2n/3) as n → ∞. Compute the tropicalization error |log(k²(n−k)) - max(2log(k), log(n−k))| and verify it is O(log(n)).

**Impact**: If the tropical connection holds, it would provide a combinatorial/piecewise-linear framework for analyzing suspicion, potentially leading to closed-form solutions for the valley monotonicity conjecture and related problems. The tropical perspective has been highly productive in algebraic geometry and optimization; applying it to proof theory would be a novel cross-domain bridge. If the connection fails, it would illuminate the essentially non-tropical nature of trust—that proof evaluation is inherently multiplicative rather than additive.

**Catalog References**: `Bridges/BreakthroughDirections.lean` (tropical_max_idempotent, lse2, tropical_quantum_gap), `Tropical/` (various tropical geometry results), `Bridges/AlgebraTropicalGeometry/` (tropical algebraic geometry)

**Proof Strategy**:
1. Define tropical suspicion using `Tropical` type from Mathlib
2. Prove the phase transition: for k < 2n/3, T_trop = 2·log(k); for k > 2n/3, T_trop = log(n−k)
3. Show that exp(T_trop) ≤ k²(n−k) ≤ 2·exp(T_trop) (tropical sandwich bound)
4. Use `lse_sandwich` from BreakthroughDirections to bound the approximation error

**Domain Bridges**: Tropical <-> Bridges, Algebra <-> Tropical

**Lineage**: Builds on `tropical_max_idempotent`, `lse_sandwich`, `valley_monotonicity_conjecture`

**Ambition**: extension

---

### Direction 5: Multi-Author Proof Suspicion and Social Choice Theory

**Conjecture**: For a proof with m authors, each responsible for n_i steps with k_i verified, the total suspicion is NOT simply the sum of individual suspicions. Instead, there is a *cross-author suspicion term*:

S_multi = Σ_i k_i²(n_i − k_i) + λ · Σ_{i<j} k_i · k_j · |k_i/n_i − k_j/n_j|

where the cross term captures the additional suspicion generated when different parts of a proof have different rigor levels. The coefficient λ > 0 measures the "heterogeneity penalty."

The conjecture states: for any λ > 0, the multi-author suspicion S_multi is minimized only when either (a) all k_i = 0 or (b) all k_i = n_i. There is no stable interior equilibrium—partial rigor is always Pareto-dominated.

**Test**: For m = 2, 3, 4 authors with n_i = 10 and λ = 1, exhaustively compute S_multi for all (k₁, ..., k_m) ∈ {0, ..., 10}^m. Verify that no interior point (0 < k_i < n_i for some i) achieves a global minimum.

**Impact**: If true, this provides a game-theoretic argument for either fully informal or fully formal collaboration—no middle ground. This would have practical implications for large collaborative projects in mathematics. It connects to Arrow's impossibility theorem in social choice: just as Arrow showed no fair voting system exists, this would show no "fair" intermediate rigor level exists for multi-author proofs.

**Catalog References**: `Bridges/UncannyValley.lean` (SuspicionProfile, asymSuspicion), `Bridges/BeatpathRobustness.lean` (voting/social choice connections)

**Proof Strategy**:
1. Define `MultiAuthorSuspicion` as a function of vectors (k₁,...,k_m) and (n₁,...,n_m)
2. Prove that the gradient vanishes only at boundary points using KKT conditions
3. For the discrete case, show any interior point can be improved by moving some k_i to 0 or n_i
4. Use the convexity of k²(n−k) on [0, 2n/3] and concavity on [2n/3, n] to establish the result

**Domain Bridges**: Bridges <-> Logic (social choice), MachineLearning <-> Bridges (game theory)

**Lineage**: Builds on `SuspicionProfile`, `uncanny_valley_ordering`, `last_sorry_penalty`

**Ambition**: extension
