# Quantum EML Activation Functions: Bridging Classical Neural Networks and Quantum Computing

## Abstract

We introduce the quantum EML (Exp-Minus-Log) activation framework, which lifts the classical EML function `eml(x,y) = exp(x) - log(y)` to the complex unit circle via the phase map `(x,y) ↦ exp(i·eml(x,y))`. We prove that this quantum EML phase map is surjective onto S¹ (the U(1) analog of the SU(2) coverage conjecture), that quantum EML phases compose multiplicatively via EML addition, and that the classical exp-log cancellation identity `eml(log a, exp b) = a - b` lifts exactly to quantum phase simplification. We establish a quantitative bound relating the quantum EML gate error to the classical EML value: `|exp(i·eml(x,y)) - 1|² ≤ eml(x,y)²`, and prove that any U(1) rotation can be exactly compiled as a quantum EML gate. All results are formalized and machine-verified in Lean 4 with Mathlib.

**Keywords**: quantum activation functions, EML, unitary phases, gate compilation, quantum-classical bridge

## 1. Introduction

The EML (Exp-Minus-Log) activation function `eml(x,y) = exp(x) - log(y)` combines exponential amplification with logarithmic compression, producing activation profiles with no critical points and controlled growth. Classical properties of EML — including the fundamental identity `eml(log a, exp b) = a - b` and the chain cancellation `eml(log x, x) = x - log x` — have been established in previous work (see `EML/EMLv17Core.lean`, `EML/KolmogorovArnoldEMLDeep.lean`).

This paper investigates a natural question: **can the EML function serve as a bridge between classical neural networks and quantum computing?** We answer affirmatively by constructing the *quantum EML phase map*, which maps EML parameters to points on the complex unit circle. This map inherits the algebraic structure of EML while producing genuine unitary (U(1)) quantum gates.

### 1.1 Motivation

In quantum computing, single-qubit gates are elements of SU(2), parameterized by three real parameters. A fundamental question in quantum neural networks is whether classical activation functions can naturally generate quantum gates. The EML function, with its exp-log duality, is particularly suited for this role because:

1. The exponential `exp(iθ)` is the standard parameterization of U(1) rotations
2. The logarithm is its inverse, enabling exact gate compilation
3. The EML function `exp(x) - log(y)` combines both, creating a two-parameter family of phases

### 1.2 Contributions

We make the following contributions, all formally verified:

1. **Quantum EML Phase Map** (Definition): `quantumEMLPhase(x,y) = exp(i·eml(x,y))`
2. **Unitarity** (Theorem): `‖quantumEMLPhase(x,y)‖ = 1` for all x, y
3. **Phase Surjectivity** (Theorem): The map is surjective onto S¹
4. **Composition Law** (Theorem): Phases compose via EML addition
5. **Classical-Quantum Bridge** (Theorem): `eml(log a, exp b) = a - b` lifts to `quantumEMLPhase(log a, exp b) = exp(i(a-b))`
6. **Gap Bound** (Theorem): `|exp(i·eml) - 1|² ≤ eml²`
7. **Exact Compilation** (Theorem): Any U(1) rotation is a quantum EML gate
8. **Full ℂ\{0} Coverage** (Theorem): With amplitude control, quantum EML covers all nonzero complex numbers

## 2. Definitions

### 2.1 Classical EML

The classical EML activation function is:

```
eml(x, y) = exp(x) - log(y)
```

where `exp` and `log` are the real exponential and natural logarithm. Key properties include:
- `eml(0, 1) = 1` (the "unit" activation)
- `eml(log a, exp b) = a - b` for `a > 0` (exp-log cancellation)
- `eml(x, ·)` is surjective from `(0,∞)` onto `ℝ` for any fixed `x`

### 2.2 Quantum EML Phase Map

**Definition 1** (Quantum EML Phase). The quantum EML phase map is:

```
quantumEMLPhase(x, y) = exp(i · eml(x, y)) ∈ S¹ ⊂ ℂ
```

This maps pairs of real parameters to points on the unit circle.

**Definition 2** (Full Quantum EML). The full quantum EML with amplitude control is:

```
quantumEMLFull(r, x, y) = r · exp(i · eml(x, y)) ∈ ℂ
```

**Definition 3** (Quantum EML Gap). The gate error relative to identity is:

```
quantumEMLGap(x, y) = ‖quantumEMLPhase(x, y) - 1‖²
```

**Definition 4** (Quantum EML Fidelity). The overlap with target phase `exp(iα)` is:

```
quantumEMLFidelity(x, y, α) = Re(exp(i(eml(x,y) - α))) = cos(eml(x,y) - α)
```

## 3. Main Results

### 3.1 Unitarity (Theorem 1)

**Theorem** (`quantumEMLPhase_norm`). *For all x, y ∈ ℝ:*
```
‖quantumEMLPhase(x, y)‖ = 1
```

*Proof.* Direct application of `Complex.norm_exp_ofReal_mul_I`. □

**Corollary** (`quantumEMLPhase_normSq`). `normSq(quantumEMLPhase(x,y)) = 1`.

**Corollary** (`quantumEMLPhase_mul_conj`). `quantumEMLPhase(x,y) · conj(quantumEMLPhase(x,y)) = 1`.

This establishes that quantum EML neurons produce genuine unitary gates.

### 3.2 Phase Surjectivity (Theorem 2)

**Theorem** (`quantumEMLPhase_achieves_target`). *For any α ∈ ℝ, there exists y > 0 such that:*
```
quantumEMLPhase(0, y) = exp(iα)
```

*Proof.* The witness is `y = exp(1 - α)`. Then:
```
eml(0, exp(1-α)) = exp(0) - log(exp(1-α)) = 1 - (1-α) = α
```
So `quantumEMLPhase(0, exp(1-α)) = exp(iα)`. □

This is the U(1) analog of the SU(2) coverage conjecture. It shows that, at the abelian level, quantum EML neurons can implement any single-qubit phase rotation.

### 3.3 Composition Law (Theorem 3)

**Theorem** (`quantumEMLPhase_compose`). *The composition of two quantum EML phases equals:*
```
emlPhaseCompose(x₁,y₁,x₂,y₂) = exp(i·(eml(x₁,y₁) + eml(x₂,y₂)))
```

*Proof.* Uses `Complex.exp_add` and the fact that `↑a·I + ↑b·I = ↑(a+b)·I`. □

This shows that quantum EML phases form a group homomorphism from `(ℝ, +)` to `(S¹, ·)` through the EML function.

### 3.4 Classical-Quantum Bridge (Theorem 4)

**Theorem** (`eml_exp_log_cancel_quantum`). *For a > 0:*
```
quantumEMLPhase(log a, exp b) = exp(i(a - b))
```

*Proof.* Apply `eml_log_exp` to reduce `eml(log a, exp b) = a - b`, then the result follows from the definition of `quantumEMLPhase`. □

This is the deepest result: it shows that the algebraic miracle of the classical EML function — where exp and log cancel each other — lifts perfectly to the quantum setting. The classical simplification `eml(log a, exp b) = a - b` becomes quantum phase simplification.

### 3.5 Gap Bound (Theorem 5)

**Theorem** (`quantum_eml_gap_bound`). *For all x, y ∈ ℝ:*
```
quantumEMLGap(x, y) ≤ eml(x, y)²
```

*Proof.* First establish `quantumEMLGap(x,y) = 2 - 2cos(eml(x,y))`. Then use the Taylor bound `1 - cos(t) ≤ t²/2`, which follows from `|sin(t/2)| ≤ |t/2|` and the identity `1 - cos(t) = 2sin²(t/2)`. □

This provides a quantitative bridge between classical and quantum EML: the quantum gate error is bounded by the square of the classical activation value.

### 3.6 Exact Gate Compilation (Theorem 6)

**Theorem** (`quantum_eml_exact_compilation`). *Any U(1) rotation exp(iα) can be exactly compiled as:*
```
quantumEMLPhase(0, exp(1 - α)) = exp(iα)
```

This gives an explicit compilation formula: to implement rotation by angle α, use quantum EML parameters `x = 0, y = exp(1-α)`.

### 3.7 Full Coverage (Theorem 7)

**Theorem** (`quantumEMLFull_covers_nonzero`). *For any z ∈ ℂ with z ≠ 0, there exist r > 0, x ∈ ℝ, y > 0 such that:*
```
quantumEMLFull(r, x, y) = z
```

*Proof.* Uses the polar decomposition of z and the surjectivity of the EML function. □

### 3.8 Identity and Inverse (Theorems 8-9)

**Theorem** (`quantumEMLPhase_identity_condition`). *quantumEMLPhase(x,y) = 1 if and only if eml(x,y) = 2πk for some integer k.*

**Theorem** (`quantum_eml_inverse_exists`). *For any quantum EML gate, its inverse is also a quantum EML gate:*
```
∃ y' > 0, quantumEMLPhase(x,y) · quantumEMLPhase(0,y') = 1
```

## 4. Algorithm: Quantum EML Gate Compilation

### 4.1 Single-Gate Compilation

Given a target phase `α`:
1. Compute `y = exp(1 - α)`
2. Return `quantumEMLPhase(0, y) = exp(iα)`

### 4.2 Gate Sequence Optimization

Given a target phase `α` and a current accumulated phase from gates `(x₁,y₁), ..., (xₙ,yₙ)`:
1. Compute current phase: `φ = Σᵢ eml(xᵢ, yᵢ)`
2. Compute correction: `δ = α - φ`
3. Add correction gate: `(0, exp(1 - δ))`

## 5. Discussion

### 5.1 Why EML is Natural for Quantum Gates

The EML function is uniquely suited for quantum gate parameterization because:

1. **Exp-log duality**: The same mathematical operations that define EML (exp, log) are the operations that connect Lie algebras (Hermitian matrices) to Lie groups (unitary matrices) in quantum mechanics.

2. **Algebraic cancellation**: The identity `eml(log a, exp b) = a - b` means that EML-parameterized gates can be simplified algebraically before physical implementation, reducing circuit depth.

3. **Surjectivity**: The surjectivity of EML onto ℝ translates directly to full phase coverage, ensuring no quantum gate is unreachable.

### 5.2 From U(1) to SU(2)

Our results establish the U(1) (abelian) case completely. The extension to SU(2) requires replacing scalar exp/log with matrix exp/log. The key structural ingredients — surjectivity, composition, cancellation — are all present in the scalar case and suggest that the matrix case should follow by similar arguments, using the matrix exponential's surjectivity onto a neighborhood of the identity in SU(2) and the Lie algebra structure of su(2).

### 5.3 Relation to Prior Work

This work builds on and extends:
- `eml_log_exp` from `EML/EMLv17Core.lean`: We lift this scalar identity to the quantum (complex phase) setting
- `eml_chain_exp_log_cancel` from `EML/KolmogorovArnoldEMLDeep.lean`: Our chain quantum theorem generalizes this
- `quantum_classical_bound` from `Bridges/EMLTropicalSemiring.lean`: Our gap bound provides a new type of quantum-classical comparison

## 6. PEGB Analysis

### 6.1 Quantum EML Phase Surjectivity
- **P**roof: `quantumEMLPhase_achieves_target` — witness construction via `y = exp(1-α)`
- **E**xample: Target α = π/4 → use y = exp(1-π/4) ≈ 2.14, get exp(iπ/4) = (1+i)/√2
- **G**eneralization: Extends naturally to matrix EML for SU(n) coverage
- **B**oundary: Breaks for SU(2) without matrix logarithm theory; the scalar approach gives U(1) but not higher-dimensional unitaries directly

### 6.2 Classical-Quantum Bridge
- **P**roof: `eml_exp_log_cancel_quantum` — lifts `eml_log_exp` via congruence
- **E**xample: a=e, b=1 → eml(1, e) = e-1 → quantumEMLPhase = exp(i(e-1))
- **G**eneralization: Should extend to any Lie group with exp-log duality
- **B**oundary: Requires positivity (a > 0); complex logarithm branch cuts may obstruct matrix generalization

### 6.3 Quantum-Classical Gap Bound
- **P**roof: `quantum_eml_gap_bound` — via |sin(t)| ≤ |t| and cos half-angle identity
- **E**xample: eml = 0.1 → gap ≤ 0.01 (actual gap ≈ 0.00998)
- **G**eneralization: Higher-order bounds using cos(t) ≥ 1 - t²/2 + t⁴/24
- **B**oundary: Bound is tight only near t = 0; for large t, the gap saturates at 4 while eml² grows unboundedly

## 7. References

1. `EML/EMLv17Core.lean` — Core EML definitions and identities
2. `EML/KolmogorovArnoldEMLDeep.lean` — EML chain properties
3. `Bridges/EMLTropicalSemiring.lean` — Quantum-classical bounds
4. `EML/QuantumDensityEstimation.lean` — EML exp-log identity for density
5. `Bridges/UniversalApproximation.lean` — EML neuron continuity
