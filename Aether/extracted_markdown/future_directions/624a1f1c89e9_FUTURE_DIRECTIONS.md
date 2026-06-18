# Future Directions: Tropical Statistical Learning Theory

## Overview

The formalization of double descent as a tropical phase transition opens a new research program: **tropical statistical learning theory**, where bias-variance tradeoffs, interpolation thresholds, and generalization phases are studied as polyhedral geometry in min-plus semirings. Below we outline five concrete breakthrough directions, each with specific hypotheses, proof strategies, cross-domain connections, and actionable next steps.

---

## Direction 1: Multidimensional Tropical Phase Boundaries

### Hypothesis
When model complexity is parameterized by multiple dimensions (width w, depth d, data size N), the interpolation threshold generalizes from a single point to a **tropical hypersurface** — a polyhedral complex in (w, d, N)-space that partitions the parameter space into learning phases.

### Proof Strategy
1. Define `affineMulti (coeffs : Fin k → ℝ) (c : ℝ) (p : Fin k → ℕ) : ℝ` as a general affine form in k variables.
2. Define `tropicalRiskMulti (facets : Finset (Fin k → ℝ × ℝ)) (p : Fin k → ℕ) : ℝ` as the min over finitely many affine forms.
3. Prove that the **tropical variety** — the locus where two or more facets are co-dominant — is a union of affine hyperplanes intersected with ℕᵏ.
4. Prove that each connected component of the complement is a **phase region** with a unique dominant facet.

### Key Lemma Targets
- `tropical_hypersurface_is_polyhedral`: The set {p | ∃ i ≠ j, fᵢ(p) = fⱼ(p) = R(p)} is a finite union of affine subspaces.
- `phase_region_connected`: Each region where a single facet dominates is connected in ℕᵏ.
- `phase_count_bound`: The number of phases is at most k (the number of facets).

### Cross-Domain Connections
- **Tropical geometry**: This is precisely the theory of tropical varieties in Tⁿ (Maclagan-Sturmfels, Ch. 3).
- **Neural architecture search**: The phase diagram would tell practitioners which (width, depth) combinations avoid the interpolation spike.
- **Statistical physics**: The Gibbs phase rule connects the codimension of a phase boundary to the number of coexisting phases.

### Actionable Next Steps
1. Formalize `tropicalRiskMulti` for k = 2 variables (width, depth).
2. Prove the 2D analogue of unique_tropical_corner_crossing: under generic slopes, phase boundaries are line segments in ℕ².
3. Implement computational enumeration of 2D tropical vertices.
4. Connect to the existing `two_vertex_weight` graph-theoretic infrastructure.

---

## Direction 2: Tropical Free-Energy Limits via Log-Sum-Exp

### Hypothesis
The tropical risk min(f₁(n), ..., fₖ(n)) is the pointwise limit as β → ∞ of the **soft risk**:
$$R_\beta(n) = -\frac{1}{\beta} \log \sum_{i=1}^k e^{-\beta f_i(n)}$$

Formalizing this limit connects tropical learning theory to statistical mechanics and provides a smooth approximation for numerical computation.

### Proof Strategy
1. Define `softRisk (β : ℝ) (facets : List (ℕ → ℝ)) (n : ℕ) : ℝ` as the log-sum-exp.
2. Prove pointwise convergence: `∀ n, Tendsto (fun β => softRisk β facets n) atTop (nhds (tropicalRisk facets n))`.
3. The key estimate is: `min_i f_i(n) ≤ softRisk β n ≤ min_i f_i(n) + (log k)/β`.

### Key Lemma Targets
- `log_sum_exp_lower_bound`: softRisk ≥ min.
- `log_sum_exp_upper_bound`: softRisk ≤ min + (log k)/β.
- `softRisk_converges_to_tropical`: pointwise convergence as β → ∞.
- `soft_vertex_convergence`: the "soft vertex" (maximum of softRisk) converges to the tropical vertex.

### Cross-Domain Connections
- **Statistical mechanics**: This is exactly the zero-temperature limit of the Boltzmann free energy.
- **Deep learning**: The softmax function is exp(-βf)/Σexp(-βf), so this connects to attention mechanisms and Boltzmann machines.
- **Optimization**: Log-sum-exp is a smooth approximation to max, widely used in convex optimization.

### Actionable Next Steps
1. Prove the sandwich bound for two facets in Lean.
2. Use Mathlib's `Tendsto` and `Filter` API for the limit theorem.
3. Define the soft vertex as the argmax of softRisk and prove its convergence.
4. Connect to information-theoretic quantities (KL divergence, entropy).

---

## Direction 3: Perturbation-Stable Phase Diagrams Under Quantization

### Hypothesis
If each risk facet is subject to bounded perturbation |εᵢ(n)| ≤ η (from finite-precision arithmetic, measurement noise, or model misspecification), the phase assignment is preserved whenever the dominance margin exceeds 2η. Furthermore, the perturbed tropical vertex is within O(η/|a₁-a₂|) of the true vertex.

### Proof Strategy
1. Use `tropical_risk_dominance_margin` to bound the gap: |f₁(n) - f₂(n)| = |a₁-a₂| · |n-τ|.
2. Show that for |n-τ| > 2η/|a₁-a₂|, the perturbed min agrees with the unperturbed min.
3. Prove that the perturbed vertex (where perturbed facets cross) satisfies |τ̃ - τ| ≤ 2η/|a₁-a₂|.

### Key Lemma Targets
- `phase_stable_away_from_vertex`: Under η-perturbation, phase assignment is correct for |n-τ| > 2η/|a₁-a₂|.
- `perturbed_vertex_bound`: The perturbed crossing point is within O(η) of the true one.
- `phase_diagram_hausdorff_stability`: The Hausdorff distance between true and perturbed phase boundaries is O(η).

### Cross-Domain Connections
- **Numerical analysis**: Connects to backward stability and condition numbers.
- **Quantized neural networks**: INT8/INT4 arithmetic introduces bounded perturbation to risk evaluation.
- **Experimental ML**: Establishes when empirical risk measurements reliably identify the phase.
- **`fixed_point_error`** catalog theorem: Direct application to fixed-point arithmetic error bounds.

### Actionable Next Steps
1. Strengthen `tropical_vertex_stability_under_uniform_error` from the existing catalog with explicit bounds.
2. Prove the vertex displacement bound |τ̃ - τ| ≤ 2η/|a₁-a₂|.
3. Extend to k facets with pairwise margin conditions.
4. Implement numerical experiments demonstrating stability under FP16 arithmetic.

---

## Direction 4: Benign Overfitting via Tropical Monomial Dominance

### Hypothesis
**Benign overfitting** (Bartlett et al., 2020) — the phenomenon where interpolating models generalize well — can be characterized as the modern facet having both a negative slope (decreasing risk) and a sufficiently large dominance margin that noise perturbations cannot flip the phase assignment. The "benign" region is the interior of the modern phase where the margin is large.

### Proof Strategy
1. Define `benign_region (a₁ a₂ b₁ b₂ : ℝ) (τ : ℕ) (η : ℝ) : Set ℕ` as the set where the modern facet dominates by margin > 2η.
2. Prove that this region is a half-line: {n : ℕ | n > τ + ⌈2η/|a₁-a₂|⌉}.
3. Prove that within this region, the risk is monotonically decreasing (from Theorem 3.4) and the phase assignment is stable (from Direction 3).

### Key Lemma Targets
- `benign_region_halfline`: The benign region is {n > τ + Δ} for explicit Δ.
- `benign_risk_monotone_decreasing`: R is strictly decreasing in the benign region.
- `benign_overfitting_certified`: In the benign region, increasing model size is guaranteed to help.

### Cross-Domain Connections
- **Benign overfitting theory**: Provides a tropical geometric characterization complementing the spectral/eigenvalue conditions of Bartlett et al.
- **Implicit regularization**: The modern facet slope a₂ encodes the implicit regularization strength.
- **Model selection**: The benign region boundary gives a principled threshold above which overparameterization is safe.

### Actionable Next Steps
1. Formalize the benign region definition in Lean.
2. Prove it's a half-line using the dominance margin theorem.
3. Prove risk monotonicity within the region.
4. Connect the slope a₂ to concrete model properties (e.g., minimum eigenvalue of the kernel matrix).

---

## Direction 5: Graph-Theoretic Learning Phases via Shortest-Path Competition

### Hypothesis
The competition between k learning regimes can be modeled as a **shortest-path problem** in a weighted directed graph with k nodes. Each node represents a regime, and edge weights encode the cost of transitioning between regimes. The tropical risk at complexity n is the shortest path from "source" to "sink" in this graph, and phase transitions correspond to shortest-path switches.

### Proof Strategy
1. Construct a two-node graph G = ({classical, modern}, E) where edge classical→modern has weight f_cl(n) and edge modern→classical has weight f_mod(n).
2. The shortest path selects the minimum: R(n) = min(f_cl(n), f_mod(n)).
3. Generalize to k nodes for k competing regimes, where the tropical risk is the shortest-path distance.
4. Prove that phase transitions correspond to shortest-path switches, which are tropical vertices of the distance function.

### Key Lemma Targets
- `two_node_shortest_path_is_tropical_risk`: The shortest path in the two-node graph equals the tropical risk.
- `k_regime_shortest_path`: For k competing regimes, R(n) = tropical shortest-path distance.
- `shortest_path_switch_is_vertex`: Phase transitions correspond to shortest-path switches.
- `tropical_bellman_ford`: The Bellman-Ford algorithm computes the tropical risk in O(k²) per complexity value.

### Cross-Domain Connections
- **Network optimization**: Direct application of min-plus algebra to weighted graph algorithms.
- **`two_vertex_weight`** catalog theorem: Starting point for the graph-theoretic formalization.
- **Ensemble methods**: Different models in an ensemble compete like paths in a network.
- **Multi-task learning**: Tasks compete for model capacity, creating a multi-path competition.

### Actionable Next Steps
1. Define the two-node regime graph in Lean.
2. Prove equivalence between shortest-path and tropical risk for k = 2.
3. Extend to k = 3 with an explicit worked example.
4. Connect to the existing `tropical_sum_to_min` ultrametric infrastructure.

---

## Research Program Architecture

### Phase 1 (Immediate): Directions 3 and 4
These build directly on the current formalized theorems and require minimal new infrastructure.

### Phase 2 (Medium-term): Direction 2
Requires engagement with Mathlib's analysis library (limits, filters, log/exp).

### Phase 3 (Long-term): Directions 1 and 5
Require new definitions and significant infrastructure (multidimensional tropical geometry, graph theory).

### Cross-cutting Theme
All five directions share a common algebraic substrate: the min-plus semiring and its order-theoretic properties. Building a clean Lean library for min-plus algebra (tropical semiring, tropical polynomials, tropical varieties) would accelerate all five directions simultaneously.

---

## Team Coordination

- **Thread A (Theorem Proving)**: Focus on formalizing Directions 3-4 as immediate extensions of the current theorems. Target: 5-10 new lemmas per direction.
- **Thread B (Counterexample Search)**: For each proposed lemma, generate counterexamples with random parameters before attempting formalization. Use `#eval` and `lean_run_code` extensively.
- **Thread C (Geometric Interpretation)**: Develop visualizations of 2D tropical phase diagrams (Direction 1). Create interactive plots showing how phase boundaries move with parameters.
- **Thread D (Catalog Integration)**: Connect new theorems to existing catalog infrastructure (`tropical_plus_distributes_over_min`, `fixed_point_error`, `two_vertex_weight`). Ensure all cross-references are documented.
