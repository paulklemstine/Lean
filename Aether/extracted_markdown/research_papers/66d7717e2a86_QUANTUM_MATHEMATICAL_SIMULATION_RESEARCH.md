# Mathematical Simulation of Quantum Computation: A Research Framework

## Executive Summary

**Can quantum computation be performed purely mathematically, without physical qubits?**

**Yes — with fundamental caveats.** Quantum mechanics is, at its core, linear algebra over ℂ. Every quantum computation is a sequence of unitary transformations on vectors in a Hilbert space ℂ^(2^n). This can be computed classically with perfect fidelity. However, the exponential scaling of the state space (2^n complex amplitudes for n qubits) creates an insurmountable classical computational barrier for large systems, which is precisely why quantum computers are believed to offer a computational advantage.

---

## Part I: The Mathematical Space of Quantum Computation

### 1.1 The Hilbert Space Model

The complete mathematical framework for quantum computation consists of:

- **State Space**: An n-qubit system lives in ℂ^(2^n), the tensor product of n copies of ℂ². A quantum state |ψ⟩ is a unit vector in this space.
- **Evolution**: Quantum gates are unitary operators U ∈ U(2^n). Unitarity (U†U = I) guarantees probability conservation.
- **Measurement**: Projection onto computational basis states, with probabilities given by the Born rule: P(outcome = k) = |⟨k|ψ⟩|².
- **Entanglement**: States in ℂ^(2^n) that cannot be decomposed as tensor products of individual qubit states.

### 1.2 Entanglement as Linear Algebra

A state |ψ⟩ ∈ ℂ² ⊗ ℂ² is *entangled* if there do not exist |a⟩, |b⟩ ∈ ℂ² such that |ψ⟩ = |a⟩ ⊗ |b⟩.

**Example (Bell State)**: |Φ⁺⟩ = (1/√2)(|00⟩ + |11⟩). This is provably not a product state — a fact formalized and proved in Lean.

---

## Part V: Key Theorems (Formalized in Lean)

The file `QuantumMathSimulation.lean` formalizes and *proves* (no sorry) the following **19 theorems**:

### Core Unitarity (Sections 2)
1. **`identity_is_unitary`** — The identity matrix is a valid quantum gate
2. **`unitary_comp`** — Composition of unitary gates is unitary (circuits compose correctly)
3. **`unitary_adjoint`** — The adjoint of a unitary is unitary

### Born Rule & Measurement (Section 3)
4. **`born_rule_valid`** — Measurement probabilities sum to 1
5. **`born_probability_nonneg`** — Each measurement probability is non-negative
6. **`born_probability_le_one`** — Each measurement probability is at most 1

### Entanglement (Section 4)
7. **`bell_state_entangled`** — The Bell state (1/√2)(|00⟩ + |11⟩) is entangled (not a product state)

### Circuit Simulation (Section 5)
8. **`circuit_composition`** — Gate-by-gate simulation equals applying the total circuit unitary

### Exponential Barrier (Section 6)
9. **`state_space_exponential`** — The n-qubit state space has dimension 2^n
10. **`qubit_doubles_space`** — Each additional qubit doubles the state space
11. **`simulation_dimension`** — Module.finrank of the n-qubit Hilbert space is 2^n

### Clifford Group (Section 7)
12. **`pauliX_unitary`** — Pauli X gate is unitary
13. **`pauliZ_unitary`** — Pauli Z gate is unitary
14. **`pauliX_involution`** — Pauli X is self-inverse
15. **`pauliZ_involution`** — Pauli Z is self-inverse
16. **`hadamard_unitary`** — The Hadamard gate is unitary
17. **`hadamard_conjugation`** — HZH = X (Hadamard conjugation swaps X and Z)

### No-Cloning Theorem (Section 8)
18. **`no_cloning_inner_product`** — A cloning unitary forces inner products to be 0 or 1

### Determinism (Section 9)
19. **`quantum_is_linear_algebra`** — Equal inputs produce equal outputs under any unitary

All proofs are verified by Lean with only standard axioms (propext, Classical.choice, Quot.sound).
