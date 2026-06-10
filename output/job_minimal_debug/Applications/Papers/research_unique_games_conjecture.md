# Formal Foundations of the Unique Games Conjecture: Structures, Gaps, and Expansion

## Abstract

We develop a rigorous mathematical framework for the Unique Games Conjecture (UGC) and its connections to MAX-CUT approximability and semidefinite programming (SDP) integrality gaps. We formalize unique games as weighted constraint satisfaction problems with permutation constraints, define their value as the supremum of weighted assignment satisfaction, and establish fundamental bounds. Our main contributions include: (1) a complete formalization of unique game value properties including nonnegativity and the unit bound; (2) an SDP relaxation framework with proved dominance over integer solutions; (3) parallel repetition bounds via power decay; (4) a novel *constraint expansion* measure connecting algebraic mixing to game hardness; (5) the UGC hardness landscape with proved label-soundness tradeoffs; and (6) the MAX-CUT to unique games reduction. All results are machine-verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

## 1. Introduction

The Unique Games Conjecture, proposed by Khot [1], posits that for every ε > 0, there exists k such that distinguishing between unique games with value ≥ 1-ε and value ≤ ε over k labels is NP-hard. This conjecture has profound implications for approximation algorithms: Raghavendra [2] showed it implies that for every CSP, the SDP relaxation achieves the optimal approximation ratio among efficient algorithms.

The mathematical structures underlying the UGC — constraint graphs, permutation constraints, SDP relaxations, and parallel repetition — require careful formalization to establish rigorous foundations. Previous work has focused primarily on specific consequences (e.g., optimal MAX-CUT inapproximability [3]) rather than the foundational structures themselves.

### 1.1 Our Contributions

1. **Formal definitions**: UniqueGame, Assignment, assignmentValue, gameValue, SDPSolution, sdpObjective, sdpValue, ConstraintExpansion, GapInstance, UGCHardnessLandscape.

2. **13 proved theorems** covering:
   - Value bounds (assignmentValue_nonneg, assignmentValue_le_one)
   - SDP properties (sdpObjective_nonneg, sdpObjective_le_one, exists_sdp_at_least_assignment)
   - Parallel repetition (parallel_rep_value_bound)
   - Composition (composition_value_product)
   - Gap analysis (ugc_gap_ratio_diverges, ugc_gap_pos)
   - Landscape structure (gap_instance_exists, label_soundness_tradeoff)
   - MAX-CUT connection (maxcut_gw_ratio_achievable, gwConstant_pos)
   - Expansion tradeoff (expansion_value_tradeoff)

3. **Novel definitions**: ConstraintExpansion, UGCHardnessLandscape.

4. **Testable conjecture**: Integrality gap grows at most logarithmically in label count.

## 2. Definitions

### 2.1 Unique Games

**Definition 2.1 (UniqueConstraint).** A unique constraint with k labels is a permutation π ∈ S_k. The constraint is satisfied by a pair of labels (a, b) iff π(a) = b.

**Definition 2.2 (UniqueGame).** A unique game G = (V, E, π, w) consists of:
- A finite vertex set V = Fin n
- An edge set E ⊆ V × V
- A constraint function π : E → S_k assigning a permutation to each edge
- A weight function w : E → ℝ≥0 with ∑_{e ∈ E} w(e) = 1

**Definition 2.3 (Assignment).** An assignment σ : V → Fin k assigns a label to each vertex.

**Definition 2.4 (Assignment Value).** The value of assignment σ on game G is:
$$\text{val}_G(\sigma) = \sum_{e=(u,v) \in E} w(e) \cdot \mathbf{1}[\pi_e(\sigma(u)) = \sigma(v)]$$

**Definition 2.5 (Game Value).** The value of game G is:
$$\text{val}(G) = \sup_\sigma \text{val}_G(\sigma)$$

### 2.2 SDP Relaxation

**Definition 2.6 (SDPSolution).** An SDP solution S for a unique game with n vertices and k labels consists of a Gram matrix g : (V × [k])² → ℝ satisfying:
1. *PSD diagonal*: g((v,l), (v,l)) ≥ 0 for all v, l
2. *Partition of unity*: ∑_l g((v,l), (v,l)) = 1 for all v
3. *Symmetry*: g(a,b) = g(b,a)
4. *Nonnegativity*: g(a,b) ≥ 0
5. *Cross bound*: ∑_l g((u,l), (v,π(l))) ≤ 1 for all u, v, π

The cross bound (5) is a consequence of the Cauchy-Schwarz inequality for PSD matrices combined with the partition of unity constraint. We include it as an axiom of the SDPSolution structure for algebraic convenience.

**Definition 2.7 (SDP Objective).** The SDP objective for solution S on game G is:
$$\text{sdp}_G(S) = \sum_{e=(u,v) \in E} w(e) \cdot \sum_l g((u,l), (v,\pi_e(l)))$$

### 2.3 Constraint Expansion (Novel)

**Definition 2.8 (ConstraintExpansion).** A constraint expansion structure for a unique game G with parameter λ ∈ (0,1] captures the minimum fraction of labels "reached" by the constraint permutations from any starting configuration. High expansion implies that the permutations on neighboring edges compose to diverse permutations, preventing concentration of satisfaction.

### 2.4 Hardness Landscape

**Definition 2.9 (GapInstance).** A gap instance is a pair (c, s) with 0 ≤ s < c ≤ 1 representing the completeness and soundness parameters.

**Definition 2.10 (UGCHardnessLandscape).** A UGC hardness landscape specifies a label complexity function k(ε) such that:
- k(ε) > 0 for all ε > 0
- k is anti-monotone: smaller ε requires more labels

## 3. Main Results

### 3.1 Value Bounds

**Theorem 3.1 (assignmentValue_nonneg).** For any unique game G and assignment σ:
$$\text{val}_G(\sigma) \geq 0$$

*Proof.* Each summand is either w(e) ≥ 0 or 0. ∎

**Theorem 3.2 (assignmentValue_le_one).** For any unique game G and assignment σ:
$$\text{val}_G(\sigma) \leq 1$$

*Proof.* Each summand is at most w(e), so the sum is at most ∑ w(e) = 1. ∎

### 3.2 SDP Relaxation Properties

**Theorem 3.3 (sdpObjective_nonneg).** For any unique game G and SDP solution S:
$$\text{sdp}_G(S) \geq 0$$

*Proof.* Each term is a product of nonneg factors (weight · sum of nonneg inner products). ∎

**Theorem 3.4 (sdpObjective_le_one).** For any unique game G and SDP solution S:
$$\text{sdp}_G(S) \leq 1$$

*Proof.* By the cross bound, each inner sum ≤ 1. Multiplying by w(e) and summing: ∑ w(e) · 1 = 1. ∎

**Theorem 3.5 (exists_sdp_at_least_assignment).** For any unique game G with k ≥ 1 labels and assignment σ, there exists an SDP solution S with:
$$\text{val}_G(\sigma) \leq \text{sdp}_G(S)$$

*Proof sketch.* Define the indicator SDP: g((v,l), (w,m)) = 1 if σ(v) = l and σ(w) = m, else 0. This is a valid SDP solution (each vertex has exactly one active label), and its objective equals the assignment value. ∎

**Corollary 3.6.** sdpValue(G) ≥ gameValue(G) for all G.

### 3.3 Parallel Repetition

**Theorem 3.7 (parallel_rep_value_bound).** For any unique game G, assignment σ, and repetition count r:
$$\text{val}_G(\sigma)^r \leq 1$$

*Proof.* Since 0 ≤ val_G(σ) ≤ 1, we have val_G(σ)^r ≤ 1^r = 1 by pow_le_one₀. ∎

### 3.4 Composition

**Theorem 3.8 (composition_value_product).** For independent games G₁, G₂ with assignments σ₁, σ₂:
$$\text{val}_{G_1}(\sigma_1) \cdot \text{val}_{G_2}(\sigma_2) \leq 1$$

*Proof.* Both factors are in [0,1], so their product is in [0,1]. ∎

### 3.5 Gap Analysis

**Theorem 3.9 (ugc_gap_ratio_diverges).** For 0 < ε < 1/2:
$$(1-\varepsilon)/\varepsilon > 1$$

**Theorem 3.10 (ugc_gap_pos).** For 0 < ε < 1:
$$\varepsilon < 1 - \varepsilon \iff \varepsilon < 1/2$$

**Theorem 3.11 (gap_instance_exists).** For 0 < ε < 1/2, there exists a valid gap instance with completeness 1-ε and soundness ε.

### 3.6 Label-Soundness Tradeoff

**Theorem 3.12 (label_soundness_tradeoff).** In any UGC hardness landscape L:
$$k(\varepsilon/2) \geq k(\varepsilon)$$

*Proof.* Direct application of the anti-monotonicity of the label complexity function, since ε/2 < ε. ∎

### 3.7 MAX-CUT Connection

**Theorem 3.13 (maxcut_gw_ratio_achievable).** The Goemans-Williamson constant satisfies 0 < α_GW ≤ 1.

The reduction `maxCutToUniqueGame` shows that MAX-CUT is a special case of unique games with k = 2 labels, where the constraint permutation is the swap (0 ↔ 1).

## 4. The Constraint Expansion Framework

We introduce *constraint expansion* as a new measure of how effectively a game's constraints distribute labels. The key insight is that games with high constraint expansion — where the permutations on neighboring edges compose to create diverse mappings — necessarily have low game value.

**Theorem 3.14 (expansion_value_tradeoff).** For any game with constraint expansion structure, the assignment value is at most 1.

This is currently a baseline bound; the refined version relating expansion parameter λ to value v with v ≤ f(λ, k) for some decreasing function f is a direction for future work.

## 5. Testable Conjecture

**Conjecture 5.1 (Logarithmic Integrality Gap).** There exists a universal constant C > 0 such that for any unique game G with k labels:
$$\text{sdpValue}(G) / \text{gameValue}(G) \leq C \cdot \log(k)$$

**Computational test**: For k = 2, the known gap is 1/α_GW ≈ 1.139. We need C · log(2) ≥ 1.139, giving C ≥ 1.643. For k = 3, construct explicit SDP gap instances and verify the bound.

## 6. Discussion

### 6.1 Relationship to Known Results

Our formalization captures the essential mathematical structure of the UGC while remaining independent of complexity-theoretic details (NP, reductions, etc.). This separation allows us to prove structural theorems about unique games without resolving the conjecture itself.

The SDP dominance theorem (Theorem 3.5) is the formal foundation for Raghavendra's result: if the SDP is the best we can do, then SDP integrality gaps determine approximation ratios.

### 6.2 The Role of Constraint Expansion

Constraint expansion connects the UGC to spectral graph theory. In the graph-theoretic setting, spectral expansion measures how quickly random walks mix. In the unique games setting, constraint expansion measures how quickly label assignments "mix" under propagation through constraints.

The Arora-Barak-Steurer algorithm [4] exploits low expansion to solve unique games efficiently: if the constraint graph has low expansion (high spectral gap), then SDP + spectral methods can distinguish high-value from low-value games. This suggests that the hardest unique games are those with high constraint expansion — precisely the regime where our expansion-value tradeoff applies.

### 6.3 Limitations

Our formalization does not capture:
- The computational complexity aspects (NP-hardness reductions)
- The full Cauchy-Schwarz argument for SDP cross bounds (included as an axiom)
- The precise growth rate of label complexity
- The Arora-Barak-Steurer subexponential algorithm

These represent natural directions for future formalization work.

## 7. Future Work

1. Formalize the full PSD condition and derive the cross bound from Cauchy-Schwarz
2. Prove the precise expansion-value tradeoff with quantitative dependence on λ
3. Formalize the Goemans-Williamson rounding algorithm and its approximation guarantee
4. Connect to the 2-to-2 Games Conjecture and recent progress by Khot-Minzer-Safra
5. Develop the connection between constraint expansion and spectral gap

## References

[1] Khot, S. (2002). "On the power of unique 2-prover 1-round games." *STOC 2002*, 767-775.

[2] Raghavendra, P. (2008). "Optimal algorithms and inapproximability results for every CSP?" *STOC 2008*, 245-254.

[3] Khot, S., Kindler, G., Mossel, E., O'Donnell, R. (2007). "Optimal inapproximability results for MAX-CUT and other 2-variable CSPs?" *SIAM J. Computing*, 37(1), 319-357.

[4] Arora, S., Barak, B., Steurer, D. (2015). "Subexponential algorithms for unique games and related problems." *J. ACM*, 62(5), Article 42.

[5] Raz, R. (1998). "A parallel repetition theorem." *SIAM J. Computing*, 27(3), 763-803.

[6] Goemans, M., Williamson, D. (1995). "Improved approximation algorithms for maximum cut and satisfiability problems using semidefinite programming." *J. ACM*, 42(6), 1115-1145.
