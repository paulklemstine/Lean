# Future Directions: Thermodynamic Self-Reference Capacity Theory

## Breakthrough Opportunities (ranked by impact)

### 1. Monotonicity and Convexity of the Capacity Gap

- **Theorem Statement**: Under natural monotonicity hypotheses on the capacity functions (e.g., reflCap monotone increasing, budget concave), prove that the capacity gap g(β) is concave, and the critical set {β : g(β) = 0} is convex.
- **Proof Strategy**:
  - (a) Prove concavity of the gap from concavity of the budget and convexity of the capacity sum.
  - (b) Use the intermediate value theorem to show the critical set is an interval.
  - (c) Derive monotonicity of the subcritical region boundary.
- **Why This Is Revolutionary**: Convexity of the critical set would mean phase transitions occur in a connected region, not scattered points — a structural result analogous to convexity of phase boundaries in equilibrium thermodynamics.
- **Catalog Leverage**: Build on `gap_monotone_of_budget_mono_sum_antimono`, `mem_rigidity_envelope_iff_zero_gap`.
- **Research Mode**: prove
- **Estimated Depth**: 3

### 2. Tropicalization of the Conservation Law

- **Theorem Statement**: Define a tropical (max-plus) semiring structure on capacity pairs. Prove that ordinary criticality implies tropical criticality under the natural order-preserving embedding ℝ → ℝ_trop.
- **Proof Strategy**:
  - (a) Define `TropicalCapacityPair` as a structure with max-plus operations.
  - (b) Prove that the embedding r ↦ r preserves the ordering.
  - (c) Show `IsCritical M β → TropicalCritical M β` where tropical criticality uses max instead of +.
- **Why This Is Revolutionary**: Creates a bridge between EML thermodynamics and tropical geometry, opening connections to algebraic geometry, optimization, and combinatorics.
- **Catalog Leverage**: `tropical_phase_split_of_critical_budget`, `tropical_conservation_general`, Mathlib's `Tropical` type.
- **Research Mode**: prove
- **Estimated Depth**: 4

### 3. Entropy-Rate Analogues for Stochastic Self-Models

- **Theorem Statement**: For stochastic closure self-models where capacities are random variables, prove that E[reflCap] + E[diagCap] ≤ E[B] (conservation in expectation) and derive concentration inequalities showing that the probability of near-supercritical configurations decays exponentially.
- **Proof Strategy**:
  - (a) Use linearity of expectation for the conservation-in-mean result.
  - (b) Apply Hoeffding's inequality or McDiarmid's inequality to bound P(g(β) < ε).
  - (c) Derive a large-deviation rate function for the capacity gap.
- **Why This Is Revolutionary**: Connects self-reference theory to information theory and large deviations, enabling probabilistic certificates for ML systems.
- **Catalog Leverage**: `capacityGap_nonneg`, `subcritical_has_positive_slack`, Mathlib's probability theory.
- **Research Mode**: prove
- **Estimated Depth**: 5

### 4. Post-Quantum Cryptographic Interpretation of Diagonal Reserve

- **Theorem Statement**: In a lattice-based key-exchange model, prove that the diagonal reserve postQuantumDiagonalReserve(M, β) lower-bounds the security parameter against quantum adversaries, and that the critical threshold β* determines the minimum lattice dimension for quantum resistance.
- **Proof Strategy**:
  - (a) Define a `LatticeCryptoModel` extending `ClosureSelfModel` with lattice hardness parameters.
  - (b) Map the diagonal reserve to the lattice security parameter via a reduction lemma.
  - (c) Prove that subcritical models admit secure key exchange with positive margin.
- **Why This Is Revolutionary**: Gives a thermodynamic foundation for post-quantum security parameter selection, potentially unifying different lattice-based schemes under a single capacity framework.
- **Catalog Leverage**: `barrier_profile_ge_diag`, `diagonal_reserve_ge_refl`, `post_quantum_security_tradeoff`.
- **Research Mode**: formalize
- **Estimated Depth**: 4

### 5. Certified Robustness Transfer from Capacity Gap to Neural Networks

- **Theorem Statement**: Prove that a neural network whose internal self-evaluation mechanism satisfies the closure self-model axioms inherits a certified robustness radius of gap(β₀)/L from the Lipschitz theorem.
- **Proof Strategy**:
  - (a) Define `NeuralClosureModel` instantiating `ClosureSelfModel` with network capacity functions.
  - (b) Prove Lipschitz continuity of the capacity gap from Lipschitz continuity of the network.
  - (c) Apply `lipschitz_certified_robustness_from_capacity_gap` to derive the robustness ball.
- **Why This Is Revolutionary**: Provides a new route to certified robustness that bypasses expensive per-sample verification, using thermodynamic structure instead.
- **Catalog Leverage**: `lipschitz_certified_robustness_from_capacity_gap`, `certified_robust_is_subcritical`.
- **Research Mode**: prove
- **Estimated Depth**: 3

## Under-explored Territory

### Gap Function Analysis
The capacity gap g(β) has been defined and its sign characterized, but its analytic properties (continuity, differentiability, convexity) are unexplored. Adding regularity hypotheses to the model structure would unlock:
- Implicit function theorem for the critical set
- Sensitivity analysis of the phase boundary
- Variational characterization of the optimal capacity split

### Multi-Model Composition
How do capacity budgets compose when self-models are combined? If M₁ and M₂ are closure self-models, is M₁ × M₂ naturally a closure self-model? What is the budget of the product? This would enable modular reasoning about complex systems.

### Higher-Order Self-Reference
The current framework treats reflection and diagonalization as first-order operations. What about models that reflect on their own reflection capacity? This leads to fixed-point equations g(β) = F(g(β)) whose solutions characterize "self-consistent" capacity allocations.

## Cross-Domain Bridges

### Thermodynamics ↔ Tropical Geometry
The tropical capacity envelope `max(reflCap, diagCap)` is the beginning of a tropicalization program. The full bridge would map:
- Conservation law → tropical Plücker relation
- Phase transition → tropical curve singularity
- Capacity gap → tropical distance function

### Logic ↔ Information Theory
The capacity gap has an information-theoretic interpretation as the "self-referential entropy surplus." The critical model has zero surplus, analogous to a maximally compressed message. This connects to:
- Kolmogorov complexity of self-descriptions
- Algorithmic information theory bounds
- Shannon capacity of self-referential channels

### ML Robustness ↔ Cryptographic Security
The Lipschitz robustness theorem and the reserve-splitting theorem are two faces of the same phenomenon: quantitative margins in self-referential systems. A unified framework would treat certified robustness and post-quantum security as different instances of "capacity gap positivity."

## Open Problems Encountered

1. **Naturality of the budget**: Is there a canonical choice of B(β) given reflCap and diagCap? The current framework takes B as given; a constructive version would derive it from a partition function.

2. **Phase transition order**: At a critical point, is the transition first-order (discontinuous gap derivative) or second-order (continuous but non-smooth)? This requires differentiability hypotheses not in the current framework.

3. **Extremal self-description characterization**: The ExtremalSelfDescriptionFamily is currently defined as budget saturation. A deeper characterization would identify the geometric or combinatorial structure of extremal families.

4. **Computational complexity of the gap**: Given oracles for reflCap, diagCap, and B, what is the complexity of deciding whether g(β) > 0? Is this problem in P, or does it require solving an optimization problem?

5. **Connection to Sanov's theorem**: The capacity gap resembles a KL divergence between the "actual" and "equilibrium" capacity distributions. Can this be made precise using large-deviation theory?
