# Quantum Phase-EML Neurons: Bridging Classical Activation Functions and Quantum Dynamics

## Abstract

We introduce the *quantum phase-EML neuron*, a complex-valued extension of the classical EML (Exponential-Minus-Logarithm) activation function defined by q(θ, x, y) = e^{iθ} · (eˣ − ln y). We prove eleven theorems establishing its fundamental properties: (1) conservative extension of classical EML (bridge theorem), (2) complete phase-amplitude decoupling, (3) surjectivity onto ℂ (quantum universality), (4) a quantum diagonal gap extending the known bound eml(z,z) ≥ 2, (5) a precise unitarity characterization, (6) 2π-periodicity, (7) a quantum interference formula matching wave mechanics, (8) compatibility with the full complex EML, (9) Schrödinger-type phase dynamics, (10) joint continuity, and (11) real EML surjectivity. All results are formalized and machine-verified in Lean 4 with Mathlib, building on the EML v17 catalog.

**Keywords**: Quantum neural networks, activation functions, complex-valued neural networks, EML function, phase-amplitude separation, quantum-classical bridge

## 1. Introduction

### 1.1 Background

The EML (Exponential-Minus-Logarithm) function eml(x, y) = eˣ − ln y has been studied as a neural network activation function that naturally combines exponential growth with logarithmic compression. The EML v17 catalog establishes over 60 properties including monotonicity, convexity, diagonal bounds (eml(z,z) ≥ 2 for z > 0), functional equations, and fixed point existence.

A natural question arises: can EML be extended to the complex domain in a way that preserves its key properties while gaining access to quantum mechanical features like phase, interference, and unitarity?

### 1.2 Motivation

Complex-valued neural networks have gained interest for signal processing, quantum machine learning, and physics-informed architectures. However, most complex activation functions (e.g., complex ReLU, modReLU) are designed ad hoc without connection to classical activation theory. We seek a principled extension that:

1. Reduces to the classical function at a natural limit
2. Introduces quantum structure (phase, interference) naturally
3. Preserves key classical properties (bounds, monotonicity)
4. Has clean mathematical properties (continuity, differentiability)

### 1.3 Contribution

We define the quantum phase-EML as the simplest possible complexification of EML:

**Definition 1** (Quantum Phase-EML). For θ, x, y ∈ ℝ:
$$q(\theta, x, y) = e^{i\theta} \cdot (e^x - \ln y)$$

We prove eleven theorems establishing this as a genuine quantum-classical bridge. The key results are:

- **Surjectivity** (Theorem 3): The map (θ, x, y) ↦ q(θ, x, y) is surjective onto ℂ
- **Interference** (Theorem 7): Superposition of two quantum EML neurons yields the classic interference formula
- **Phase dynamics** (Theorem 9): ∂q/∂θ = i · q, the Schrödinger equation structure

## 2. Definitions

### 2.1 Classical EML

**Definition** (EML). The classical EML function eml : ℝ × ℝ → ℝ is defined as:
$$\text{eml}(x, y) = e^x - \ln y$$

**Definition** (Diagonal EML). The diagonal restriction:
$$\text{emlDiag}(z) = e^z - \ln z$$

### 2.2 Quantum Extensions

**Definition 2** (Quantum Phase-EML). The quantum phase-EML neuron:
$$q(\theta, x, y) = e^{i\theta} \cdot \text{eml}(x, y)$$

**Definition 3** (Unitarity Defect). For z ∈ ℂ:
$$\delta(z) = |z|^2 - 1$$

**Definition 4** (Complex EML). The full complex extension:
$$\text{cEML}(z, w) = e^z - \text{Log}(w)$$

where Log denotes the principal complex logarithm.

## 3. Main Results

### 3.1 Theorem 1: Classical-Quantum Bridge

**Theorem** (Bridge). *For all x, y ∈ ℝ:*
$$q(0, x, y) = \text{eml}(x, y) \in \mathbb{R} \subset \mathbb{C}$$

*Proof sketch.* At θ = 0, e^{i·0} = 1, so q(0, x, y) = 1 · eml(x, y) = eml(x, y). □

**PEGB Analysis:**
- **P**roof: Direct computation, verified in Lean 4.
- **E**xample: q(0, 1, 1) = e¹ − ln 1 = e ≈ 2.718.
- **G**eneralization: For matrix-valued versions, at H = 0 (zero Hermitian matrix), exp(iH) = I, recovering the classical matrix EML.
- **B**oundary: The bridge is exact only at θ = 0. For θ ≠ 0, the quantum EML is genuinely complex-valued and cannot be reduced to the classical version.

### 3.2 Theorem 2: Phase-Amplitude Decoupling

**Theorem** (Norm-Phase Independence). *For all θ, x, y ∈ ℝ:*
$$|q(\theta, x, y)|^2 = (\text{eml}(x, y))^2$$

*Proof sketch.* Since |e^{iθ}| = 1, we have |q| = |e^{iθ}| · |eml| = |eml|, hence |q|² = eml². □

**PEGB Analysis:**
- **P**roof: Uses normSq_mul and the fact that normSq(exp(iθ)) = 1.
- **E**xample: |q(π/4, 0, 1)|² = (e⁰ − ln 1)² = 1² = 1, regardless of θ = π/4.
- **G**eneralization: For matrix exp(iH), we expect ‖exp(iH) · A‖_F = ‖A‖_F (Frobenius norm preserved by unitary transformation).
- **B**oundary: Phase-amplitude decoupling fails for the full complex EML cEML(z, w) = eᶻ − Log(w) when z has nonzero imaginary part, because then the "amplitude" depends on the imaginary part of z.

### 3.3 Theorem 3: Surjectivity (Quantum Universality)

**Theorem** (Surjectivity). *The quantum phase-EML is surjective onto ℂ:*
$$\forall w \in \mathbb{C}, \exists \theta, x, y \in \mathbb{R} \text{ with } y > 0 \text{ such that } q(\theta, x, y) = w$$

*Proof sketch.* First establish that eml is surjective onto ℝ: for any r ∈ ℝ, set x = 0, y = e^{1−r}, giving eml(0, e^{1−r}) = 1 − (1−r) = r. Then for w ∈ ℂ, write w = |w| · e^{i·arg(w)}, find (x₀, y₀) with eml(x₀, y₀) = |w|, and set θ = arg(w). □

**PEGB Analysis:**
- **P**roof: Constructive existence proof using explicit parameter values.
- **E**xample: To reach w = 3 + 4i (with |w| = 5), set eml(x,y) = 5 (e.g., x = 0, y = e^{−4}) and θ = arctan(4/3) ≈ 0.927.
- **G**eneralization: For the matrix case, surjectivity onto M_n(ℂ) would follow if the matrix EML covers all positive definite matrices (via the polar decomposition of M_n(ℂ)).
- **B**oundary: The parameterization is not injective — infinitely many (θ, x, y) triples map to the same w. This redundancy could be useful (gauge freedom) or problematic (non-identifiability) depending on the application.

### 3.4 Theorem 4: Quantum Diagonal Gap

**Theorem** (Diagonal Gap). *For all θ ∈ ℝ and z > 0:*
$$|q(\theta, z, z)|^2 \geq 4$$

*Proof sketch.* By Theorem 2, |q(θ,z,z)|² = eml(z,z)². The classical result eml(z,z) = eᶻ − ln z ≥ 2 for z > 0 (using eˣ ≥ 1 + x and ln x ≤ x − 1) gives eml(z,z)² ≥ 4. □

This theorem extends `emlDiag_ge_two` from the EML v17 catalog (EMLv17Core.lean). The quantum version reveals that the bound is geometric: the diagonal EML output always lies outside a disk of radius 2 in ℂ.

**PEGB Analysis:**
- **P**roof: Reduces to the classical bound via norm-phase decoupling, then uses exp(z) ≥ 1+z and ln(z) ≤ z−1.
- **E**xample: At z = 1, eml(1,1) = e − 0 = e ≈ 2.718, so |q(θ,1,1)|² ≈ 7.39 ≥ 4.
- **G**eneralization: For the matrix diagonal EML, we conjecture ‖exp(iH)·(exp(Z) − log(Z))‖_op ≥ 2 for positive definite Z.
- **B**oundary: The bound is tight: as z → ∞ or z → 0⁺, eml(z,z) → ∞. The minimum of eml(z,z) = 2 is approached but never quite reached (it's an infimum, not a minimum, over z > 0 — the minimum is at z = 1 where eml(1,1) = e − 0 = e ≈ 2.718 > 2).

### 3.5 Theorem 5: Unitarity Characterization

**Theorem** (Unitarity). *The quantum phase-EML lies on the unit circle iff:*
$$|q(\theta, x, y)|^2 = 1 \iff \text{eml}(x, y) = 1 \text{ or } \text{eml}(x, y) = -1$$

*Proof sketch.* By Theorem 2, |q|² = eml² = 1 iff eml = ±1 (by sq_eq_one_iff). □

**Cross-connection**: This connects the EML activation function to the theory of quantum gates. A quantum EML neuron is a valid quantum gate (unitary) precisely when the classical EML value is ±1. The set of unitary parameters forms a codimension-1 surface in (x, y) space, defined by eˣ − ln y = ±1.

### 3.6 Theorem 6: 2π-Periodicity

**Theorem** (Periodicity). *For all θ, x, y ∈ ℝ:*
$$q(\theta + 2\pi, x, y) = q(\theta, x, y)$$

### 3.7 Theorem 7: Quantum Interference Formula

**Theorem** (Interference). *The superposition of two quantum phase-EML neurons satisfies:*
$$|q(\theta_1, x, y) + q(\theta_2, x, y)|^2 = 2 \cdot \text{eml}(x,y)^2 \cdot (1 + \cos(\theta_1 - \theta_2))$$

*Proof sketch.* Factor q(θ₁) + q(θ₂) = (e^{iθ₁} + e^{iθ₂}) · eml. Then |e^{iθ₁} + e^{iθ₂}|² = 2 + 2cos(θ₁ − θ₂) by direct computation using cos²+sin²=1 and the cosine subtraction formula. □

This is the most physically significant result. It shows that quantum EML neurons naturally exhibit the wave interference pattern fundamental to quantum mechanics.

**PEGB Analysis:**
- **P**roof: Direct trigonometric computation using cos²+sin²=1 and cos(α−β) expansion.
- **E**xample: For θ₁ = 0, θ₂ = π (antiphase), 1 + cos(π) = 0, giving perfect destructive interference: |q(0) + q(π)|² = 0. For θ₁ = θ₂ (in-phase), 1 + cos(0) = 2, giving |2q|² = 4·eml².
- **G**eneralization: For n neurons with phases θ₁, ..., θ_n, the total intensity involves all pairwise cosine terms: |Σq(θ_k)|² = eml² · Σ_{j,k} cos(θ_j − θ_k). This is the multi-slit interference formula.
- **B**oundary: The formula assumes identical amplitude parameters (x, y). For different amplitudes, cross-terms involving products eml(x₁,y₁)·eml(x₂,y₂) appear, breaking the clean factorization.

### 3.8 Theorem 8: Complex EML Bridge

**Theorem** (Complex Bridge). *For x ∈ ℝ and y > 0:*
$$\text{cEML}(x, y) = \text{eml}(x, y) \in \mathbb{R} \subset \mathbb{C}$$

*Proof sketch.* exp(x) for real x gives a real result, and Log(y) for real y > 0 gives a real result (imaginary part is arg(y) = 0). □

### 3.9 Theorem 9: Phase Dynamics (Schrödinger Structure)

**Theorem** (Phase Derivative). *The phase derivative of the quantum EML satisfies:*
$$\frac{\partial}{\partial\theta} q(\theta, x, y) = i \cdot q(\theta, x, y)$$

This is the defining equation of unitary dynamics: ∂ψ/∂t = iHψ with H = 1 (unit Hamiltonian). The quantum phase-EML naturally obeys the Schrödinger equation.

### 3.10 Theorem 10: Joint Continuity

**Theorem** (Continuity). *For fixed y, the map (θ, x) ↦ q(θ, x, y) is continuous.*

### 3.11 Theorem 11: Classical EML Surjectivity

**Theorem** (Real Surjectivity). *The classical EML is surjective onto ℝ:*
$$\forall r \in \mathbb{R}, \exists x, y \in \mathbb{R} \text{ with } y > 0: \text{eml}(x, y) = r$$

## 4. Algorithms

### 4.1 Quantum EML Neuron Evaluation

```
Input: θ, x, y (real parameters), with y > 0
Output: complex number q(θ, x, y)

1. Compute amplitude: a ← exp(x) − ln(y)
2. Compute phase: p ← cos(θ) + i·sin(θ)
3. Return: p · a
```

### 4.2 Inverse Quantum EML (Target Synthesis)

```
Input: target w ∈ ℂ
Output: parameters θ, x, y such that q(θ, x, y) = w

1. If w = 0: return θ = 0, x = 0, y = e
2. Compute r ← |w|, φ ← arg(w)
3. Set θ ← φ
4. Set x ← 0, y ← exp(1 − r)
5. Verify: q(θ, x, y) = exp(iφ) · r = w ✓
```

## 5. Discussion

### 5.1 Relationship to Prior Work

This work deepens the EML v17 catalog (specifically `EMLv17Core.lean`) by:

1. **Generalizing** the domain from ℝ to ℂ via the quantum phase parameter
2. **Strengthening** the diagonal bound from a real inequality to a geometric gap theorem
3. **Bridging** classical neural network theory with quantum mechanics via the interference formula

### 5.2 Comparison with Known Impossibility Results

The catalog theorem `unitary_idempotent_eq_one` (Cryptography) states that the only idempotent unitary is the identity. Our unitarity characterization (Theorem 5) is consistent: the set of unitary quantum EML outputs forms a measure-zero set in parameter space, showing that quantum EML is generically non-unitary.

### 5.3 Limitations

1. **Scalar level**: All results are proven at the scalar (1×1 matrix) level. Extension to n×n matrices requires matrix exponential and logarithm theory.
2. **Non-injectivity**: The surjection is far from injective, creating parameter identification challenges.
3. **No training algorithm**: We prove existence and structure, not how to learn optimal parameters.

## 6. Future Work

1. **Matrix extension**: Prove SU(2) coverage for 2×2 quantum EML neurons
2. **Multi-neuron interference**: Generalize the interference formula to networks of quantum EML neurons
3. **Quantum advantage bounds**: Characterize problems where quantum EML neurons provably outperform classical EML
4. **Tropical quantum EML**: Combine with the tropical semiring structure from `EMLTropicalSemiring.lean`

## 7. References

### Catalog References
- `EML/EMLv17Core.lean`: Classical EML definitions and properties (`eml`, `emlDiag`, `emlDiag_ge_two`, `eml_convexOn_fst`)
- `EML/EMLQuantumHybrid.lean`: Earlier quantum-classical hybrid results
- `EML/EMLTropicalSemiring.lean`: Tropical quantum bound (`quantum_classical_bound`)
- `EML/QuantumDensityEstimation.lean`: Quantum density EML (`eml_exp_log_id`)
- `Bridges/UniversalApproximation.lean`: EML neuron continuity (`eml_exp_neuron_continuous`)

### Mathematical Background
- R. Penrose, *The Road to Reality* (2004), Ch. 13: Complex-number calculus and quantum mechanics
- M. A. Nielsen and I. L. Chuang, *Quantum Computation and Quantum Information* (2000)
- T. Hirose, *Complex-Valued Neural Networks* (2012)
