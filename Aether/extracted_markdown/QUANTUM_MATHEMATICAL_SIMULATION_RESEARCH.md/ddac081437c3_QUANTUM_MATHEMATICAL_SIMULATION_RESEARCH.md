# Mathematical Simulation of Quantum Computation: A Research Framework

## Executive Summary

**Can quantum computation be performed purely mathematically, without physical qubits?**

**Yes — with fundamental caveats.** Quantum mechanics is, at its core, linear algebra over ℂ. Every quantum computation is a sequence of unitary transformations on vectors in a Hilbert space ℂ^(2^n). This can be computed classically with perfect fidelity. However, the exponential scaling of the state space (2^n complex amplitudes for n qubits) creates an insurmountable classical computational barrier for large systems, which is precisely why quantum computers are believed to offer a computational advantage.

---

## Formalized Results (QuantumMathSimulation.lean)

All theorems compile without `sorry` and use only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### Theorems Proved

1. **`identity_is_unitary`** — The identity matrix is a valid quantum gate.
2. **`unitary_comp`** — Composition of unitary gates is unitary (circuits compose correctly).
3. **`unitary_adjoint`** — The conjugate transpose of a unitary is unitary.
4. **`born_rule_valid`** — The Born rule produces valid probability distributions (probabilities sum to 1).
5. **`born_probability_nonneg`** — Each measurement probability is non-negative.
6. **`born_probability_le_one`** — Each measurement probability is at most 1.
7. **`bell_state_entangled`** — The Bell state (1/√2)(|00⟩ + |11⟩) is entangled (not a product state).
8. **`circuit_composition`** — Applying a circuit gate-by-gate equals applying the total unitary.
9. **`state_space_exponential`** — The n-qubit state space has dimension 2^n.
10. **`qubit_doubles_space`** — Each additional qubit doubles the state space.
11. **`simulation_dimension`** — The linear algebra dimension of ℂ^(2^n) is 2^n.
12. **`pauliX_unitary`** — The Pauli X gate is unitary.
13. **`pauliZ_unitary`** — The Pauli Z gate is unitary.
14. **`pauliX_involution`** — Pauli X is its own inverse.
15. **`pauliZ_involution`** — Pauli Z is its own inverse.
16. **`hadamard_unitary`** — The Hadamard gate is unitary.
17. **`hadamard_conjugation`** — HZH = X (Hadamard conjugation swaps X and Z).
18. **`no_cloning_inner_product`** — The no-cloning theorem: cloning forces inner products to be 0 or 1.
19. **`quantum_is_linear_algebra`** — Quantum computation is determined by linear algebra alone.

### Key Definitions

- **`IsQuantumState`** — A unit vector in ℂ^d (Born rule normalization).
- **`IsUnitaryGate`** — A matrix satisfying U†U = I.
- **`QSeparable`** / **`QEntangled`** — Separability and entanglement as tensor product properties.
- **`bellState`** — The canonical Bell state (1/√2)(|00⟩ + |11⟩).
- **`hadamardGate`**, **`pauliX`**, **`pauliZ`** — Standard quantum gates.
- **`applyGate`**, **`applyCircuit`**, **`circuitUnitary`** — Circuit simulation as matrix multiplication.
