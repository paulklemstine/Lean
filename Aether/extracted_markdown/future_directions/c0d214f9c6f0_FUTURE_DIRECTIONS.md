# Future Directions: Discrete Noether Shadow Theory

## Synthesis

The discrete Noether shadow principle established in this work—that variational integrators carry certified O(h²) energy shadows of continuous conservation laws—sits at a crossroads of geometric mechanics, numerical analysis, tropical algebra, and formal verification. The five directions below fan out from this hub.

Direction 1 (long-time metastability) deepens the time-horizon control from polynomial to exponential. Direction 2 (symmetry rigidity) turns the momentum conservation theorem into a characterization theorem, converting a sufficient condition into a necessary-and-sufficient one. Direction 3 (tropical action spectrum) pushes the min-plus action bridge toward a genuine tropical spectral theory. Direction 4 (shadow-energy universality) tests whether the drift constant is intrinsic to the Lagrangian's geometry rather than to the specific system dimension. Direction 5 (discrete-to-continuous Noether convergence) closes the loop by showing that the discrete shadow converges to the continuous Noether invariant as h → 0.

Together, these five directions would elevate discrete Noether shadow theory from a single certified theorem into a comprehensive, machine-verified framework for structure-preserving computation—capable of certifying numerical simulations at the level of mathematical proof.

---

## Direction 1: Long-Time Metastability (Exponential Conservation)

**Conjecture.** For analytic autonomous Lagrangians with symmetric second-order discrete Lagrangians, the discrete energy drift over exponentially long times T = exp(c/h) remains O(h²) on compact non-resonant energy shells. That is, the shadow energy is metastable: it oscillates around the true energy with bounded amplitude for times exponentially longer than the naive estimate.

**Test.** Numerical experiment: integrate the Kepler problem with Störmer–Verlet for T ∈ {10², 10³, 10⁴, 10⁵, 10⁶} at h = 0.01. Plot max|ΔE| vs T. The conjecture predicts a plateau (constant drift bound) rather than linear growth. Compare with the Hénon–Heiles system near and away from resonance.

**Impact.** This would be the formal analogue of the KAM theorem for variational integrators. It would certify that symplectic integrators maintain geometric fidelity not just for fixed-time simulations but for the astronomically long timescales relevant to solar system dynamics and molecular conformation sampling.

**Catalog References.**
- `discrete_energy_drift_uniform_bound` in `Physics/DiscreteNoetherShadow.lean` (current O(h²) bound over T)
- `discrete_energy_drift_vanishes` in `Physics/DiscreteNoetherShadow.lean` (h → 0 recovery)

**Proof Strategy.** Formalize a Nekhoroshev-type estimate: for analytic Hamiltonians, construct a truncated normal form that is approximately conserved. The key lemma is that the remainder in the normal form transformation is exponentially small in 1/h for analytic systems. This requires formalizing Cauchy estimates for the complexified Hamiltonian—a significant Mathlib extension but within reach given existing complex analysis infrastructure.

**Domain Bridges.** Hamiltonian dynamics ↔ formal verification ↔ celestial mechanics.

**Lineage.** Builds on Benettin–Giorgilli (1994), Hairer–Lubich (1997), extends `discrete_energy_drift_uniform_bound`.

**Ambition.** Grand challenge. Would be the first machine-verified exponential stability result in Hamiltonian numerics.

---

## Direction 2: Symmetry Rigidity (Converse Noether)

**Conjecture.** Among local two-point discrete Lagrangians of fixed order, exact discrete momentum conservation *characterizes* discrete group invariance. That is, if p(qk, qk₊₁) = p(q₀, q₁) for all discrete Euler–Lagrange trajectories and all initial conditions, then Ld is invariant under the group action generating p.

**Test.** Computational test: take a rotationally invariant Kepler discrete Lagrangian and add a small anisotropic perturbation εΔLd that breaks rotational symmetry. Measure angular momentum drift as a function of ε. The conjecture predicts drift ∝ ε·h (not ε alone), because the symmetry breaking couples to the discretization scale.

**Impact.** This would turn `discrete_momentum_conserved` from a sufficient condition into a characterization theorem, providing a *diagnostic* for symmetry: if momentum drifts, the discrete Lagrangian has a broken symmetry, and the drift rate quantifies the breaking.

**Catalog References.**
- `discrete_momentum_conserved` in `Physics/DiscreteNoetherShadow.lean`
- `discrete_momentum_conserved_range` in `Physics/DiscreteNoetherShadow.lean`

**Proof Strategy.** Use the discrete first-variation formula: the momentum change equals the integrated symmetry-breaking term. For the converse, show that if the integrated term vanishes for all solutions, the Lagrangian must be invariant, using density of discrete Euler–Lagrange solutions in the space of two-point boundary data.

**Domain Bridges.** Lie group theory ↔ numerical analysis ↔ formal verification.

**Lineage.** Extends Marsden–West discrete Noether theory; converse direction is new.

**Ambition.** Solid extension. Requires moderate Mathlib infrastructure for Lie group actions.

---

## Direction 3: Tropical Action Spectrum

**Conjecture.** On finite-state discretizations of configuration space, the discrete value function V(N, q₀, qf) = min-path Σ Ld converges projectively (after rescaling) to a tropical eigenfunction of the min-plus transfer matrix T[i,j] = Ld(qi, qj). The convergence rate is exponential in N, governed by the tropical spectral gap.

**Test.** Computational test (implementable now): discretize a 1D quartic oscillator on a grid of M = 20 points. Compute the min-plus transfer matrix. Iterate V(N) = T ⊕ V(N-1) (where ⊕ is min-plus matrix-vector multiplication) for N = 1, ..., 100. Check for projective convergence: does V(N+1) - V(N) converge to a constant vector (the tropical eigenvalue)?

**Impact.** This would establish a concrete bridge between variational mechanics and tropical geometry. The tropical eigenvalue would be a discrete analogue of the ground-state energy, and the eigenfunction would encode the optimal (least-action) configuration distribution.

**Catalog References.**
- `discrete_action_additive` in `Physics/DiscreteNoetherShadow.lean`
- `tropical_vacuum_energy_eq_minimal_action` in `Catalog/FINAL/Physics/TropicalVacuumEnergy.lean`

**Proof Strategy.** Apply the tropical Perron–Frobenius theorem (Akian, Bapat, Gaubert) to the min-plus transfer matrix. The key condition is primitivity of the tropical matrix, which corresponds to reachability in the discretized configuration space. The spectral gap controls the convergence rate.

**Domain Bridges.** Tropical geometry ↔ variational mechanics ↔ spectral theory ↔ optimization.

**Lineage.** Connects to `tropical_vacuum_energy_eq_minimal_action`; builds new tropical spectral bridge.

**Ambition.** Grand challenge. Founding a new subfield: tropical variational mechanics.

---

## Direction 4: Shadow-Energy Universality

**Conjecture.** For separable Lagrangians L = T(v) - V(q) with smooth convex kinetic energy and symmetric second-order discrete Lagrangians, the O(h²) drift constant C·T in the energy bound |ΔE| ≤ C·T·h² depends primarily on the curvature of the energy shell and not on the spatial dimension n. Specifically, C ≤ C₀(E₀) · (1 + κ·n⁻¹) where C₀ depends only on the energy level E₀ and κ is bounded.

**Test.** Already partially tested: our coupled oscillator experiments show drift/h² ≈ 0.152 for n = 2, 5, 10, 20 with coupling 0.1. Extend to n = 50, 100, 1000 and vary the coupling strength. Also test with Lennard-Jones pair potentials for a more realistic many-body system.

**Impact.** If confirmed, this universality would mean that the certified energy bound scales favorably to large systems—crucial for molecular dynamics where n can be 10⁶.

**Catalog References.**
- `discrete_energy_drift_uniform_bound` in `Physics/DiscreteNoetherShadow.lean`
- `energy_drift_explicit_constant` in `Physics/DiscreteNoetherShadow.lean`

**Proof Strategy.** For separable Lagrangians, the energy defect decomposes into a sum of single-particle contributions. By the extensivity of the action, the defect per particle is O(h³) with a constant depending on the single-particle potential, not on n. The total defect is then O(n · h³), but the energy is also O(n), so the relative defect is O(h³) independent of n.

**Domain Bridges.** Statistical mechanics ↔ numerical analysis ↔ molecular dynamics.

**Lineage.** Extends `discrete_energy_drift_uniform_bound` to many-body regime.

**Ambition.** Solid extension. Directly testable with current code.

---

## Direction 5: Discrete-to-Continuous Noether Convergence

**Conjecture.** As h → 0, the normalized discrete Noether charge (energy shadow) converges uniformly on compact energy shells to the continuous Noether invariant from classical mechanics. The convergence rate is O(h²), matching the consistency order of the discrete Lagrangian.

**Test.** Compare the discrete energy E_d(qk, qk₊₁; h) with the exact continuous energy E(q(tk), q̇(tk)) along exact or high-precision reference trajectories of the Kepler problem. Measure the difference as a function of h. The conjecture predicts |E_d - E| = O(h²) uniformly.

**Impact.** This closes the logical loop: the discrete shadow *converges* to the continuous invariant, not just *approximates* it. Combined with `discrete_energy_drift_vanishes`, it gives a complete formal picture of the relationship between discrete and continuous Noether theory.

**Catalog References.**
- `discrete_energy_drift_vanishes` in `Physics/DiscreteNoetherShadow.lean`
- `noether_defect_eq_energy_diff` in `Physics/DiscreteNoetherShadow.lean`

**Proof Strategy.** Use Taylor expansion of the discrete Lagrangian Ld(h, q₀, q₁) = h·L(q₀, (q₁-q₀)/h) + O(h³) and the corresponding expansion of the discrete energy. The O(h²) convergence follows from the second-order consistency of the discrete Lagrangian. Formalization requires polynomial Taylor remainder bounds, available in Mathlib's `Analysis.Calculus.Taylor`.

**Domain Bridges.** Classical mechanics ↔ numerical analysis ↔ formal verification.

**Lineage.** Direct extension of all five main theorems.

**Ambition.** Solid extension. Most likely to be fully formalized next.
