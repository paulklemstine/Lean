# Quantum EML Activation Functions: Phase Neurons and the Unitarity Locus

## Abstract

We introduce the **phase neuron**, a complex-valued activation function `phaseNeuron(θ, φ) = exp(iθ) − iφ` that generalizes the real-valued EML (exp-minus-log) framework to the complex plane. We establish four main results: (1) a closed-form norm-squared identity `‖phaseNeuron(θ, φ)‖² = 1 − 2φ sin θ + φ²`; (2) a complete characterization of the unitarity locus as the union of φ = 0 and the sinusoidal curve φ = 2 sin θ, with the surprising consequence that the sinusoidal branch produces time-reversed rotations exp(−iθ); (3) an image characterization showing the phase neuron surjects exactly onto the vertical strip {z ∈ ℂ : |Re(z)| ≤ 1}; and (4) a spectral gap amplification theorem for the diagonal spectral EML in the regime l ≥ 1. All results are machine-verified in Lean 4 with Mathlib. We organize these into the `QuantumEMLGate` structure, equipped with a defect measure and continuity properties, establishing foundations for quantum-classical neural network architectures.

## 1. Introduction

The EML (exp-minus-log) function `eml(x, y) = exp(x) − log(y)` has emerged as a fundamental building block in neural network architecture design, possessing clean analytical properties: strict monotonicity in both arguments, no critical points on the positive reals, and convexity properties that facilitate optimization.

A natural question arises: can the EML framework be extended to the complex plane to interface with quantum computing? Quantum gates are unitary operators, and the exponential map `exp(iH)` for Hermitian H is the standard bridge between Lie algebra elements and unitary group elements. The logarithm provides the inverse bridge. An "EML-style" quantum neuron would combine these operations.

We propose the **phase neuron** as the simplest non-trivial quantum EML construction. Rather than working with matrix exponentials (which would require heavy functional analysis infrastructure), we work with the scalar complex exponential, capturing the essential phase-rotation structure of quantum gates in a tractable setting.

### 1.1 Contributions

1. **Novel mathematical structure**: The `QuantumEMLGate` parameterized by (θ, φ) ∈ ℝ², with output phaseNeuron(θ, φ) = exp(iθ) − iφ
2. **Norm-squared identity** (Theorem 3.1): Complete analytical formula
3. **Unitarity characterization** (Theorem 3.2): The unitarity locus is φ = 0 ∨ φ = 2 sin θ
4. **Sinusoidal branch identity** (Theorem 3.3): Time reversal on the non-trivial unitary branch
5. **Image characterization** (Theorem 4.1): Surjection onto the strip |Re(z)| ≤ 1
6. **Spectral gap amplification** (Theorem 5.1): Monotonicity of diagonal spectral EML for l ≥ 1
7. **Quantum-classical bridge** (Theorem 6.1): Exact recovery of phase gates at φ = 0

## 2. Definitions

### 2.1 Complex EML

**Definition 2.1** (Complex EML). For z, w ∈ ℂ, define
```
ceml(z, w) = exp(z) − log(w)
```
where exp and log are the complex exponential and principal logarithm.

**Theorem 2.1** (Real restriction). For x, y ∈ ℝ:
```
Re(ceml(x, y)) = exp(x) − log(y) = realEml(x, y)
```
This holds without any positivity assumption on y, connecting the complex and real EML.

### 2.2 Phase Neuron

**Definition 2.2** (Phase Neuron). For θ, φ ∈ ℝ, define
```
phaseNeuron(θ, φ) = exp(iθ) − iφ = cos(θ) + i(sin(θ) − φ)
```

The decomposition into real and imaginary parts follows immediately from Euler's formula.

### 2.3 QuantumEMLGate

**Definition 2.3** (QuantumEMLGate). A quantum EML gate is a pair G = (θ, φ) ∈ ℝ². Its output is phaseNeuron(θ, φ). The identity gate is (0, 0), producing output 1.

**Definition 2.4** (Defect). The defect of gate G is `δ(G) = ‖output(G)‖² − 1`, measuring deviation from unitarity.

### 2.4 Spectral EML Transform

**Definition 2.5** (Spectral EML). For eigenvalues l₁, l₂ ∈ ℝ:
```
spectralEML(l₁, l₂) = exp(l₁) − log(l₂)
```

## 3. The Unitarity Locus

### 3.1 Norm-Squared Identity

**Theorem 3.1** (Norm-squared formula). For all θ, φ ∈ ℝ:
```
‖phaseNeuron(θ, φ)‖² = 1 − 2φ sin(θ) + φ²
```

*Proof sketch*. Expand using Re² + Im² = cos²θ + (sinθ − φ)². The Pythagorean identity cos²θ + sin²θ = 1 yields the result after algebraic simplification. □

### 3.2 Unitarity Characterization

**Theorem 3.2** (Unitarity iff). The phase neuron has unit norm if and only if:
```
‖phaseNeuron(θ, φ)‖² = 1  ⟺  φ = 0 ∨ φ = 2 sin(θ)
```

*Proof sketch*. From Theorem 3.1, unitarity requires φ² − 2φ sin θ = 0, i.e., φ(φ − 2 sin θ) = 0. □

**Corollary 3.2.1** (Defect formula). The defect equals φ² − 2φ sin θ, a quadratic form in φ.

### 3.3 The Sinusoidal Branch

**Theorem 3.3** (Time reversal). On the non-trivial unitary branch:
```
phaseNeuron(θ, 2 sin θ) = exp(−iθ)
```

*Proof sketch*. The real part is cos θ = cos(−θ). The imaginary part is sin θ − 2 sin θ = −sin θ = sin(−θ). □

This is a striking result: the combination of a forward rotation exp(iθ) with a calibrated imaginary displacement 2i sin θ produces the *time-reversed* rotation exp(−iθ). The EML structure naturally generates CPT-like symmetry operations.

## 4. Image Characterization

**Theorem 4.1** (Strip theorem). The image of phaseNeuron : ℝ² → ℂ is exactly the closed vertical strip:
```
im(phaseNeuron) = {z ∈ ℂ : −1 ≤ Re(z) ≤ 1}
```

*Proof (forward)*. Since Re(phaseNeuron(θ, φ)) = cos θ ∈ [−1, 1], the image is contained in the strip. □

*Proof (surjectivity)*. Given z with |Re(z)| ≤ 1, let θ = arccos(Re(z)) and φ = sin(arccos(Re(z))) − Im(z). Then:
- Re(phaseNeuron(θ, φ)) = cos(arccos(Re(z))) = Re(z) ✓
- Im(phaseNeuron(θ, φ)) = sin θ − φ = Im(z) ✓ □

## 5. Spectral Theory

### 5.1 Monotonicity Properties

**Theorem 5.1** (First-argument monotonicity). spectralEML(·, l₂) is strictly increasing.

**Theorem 5.2** (Second-argument anti-monotonicity). spectralEML(l₁, ·) is strictly decreasing on (0, ∞).

### 5.2 Gap Amplification

**Theorem 5.3** (Spectral gap amplification). For 1 ≤ l₂ < l₁:
```
spectralEML(l₂, l₂) < spectralEML(l₁, l₁)
```

*Proof sketch*. The function f(l) = exp(l) − log(l) has derivative f'(l) = exp(l) − 1/l. For l ≥ 1, exp(l) ≥ e > 1 ≥ 1/l, so f is strictly increasing. The proof uses the mean value theorem to obtain a point c ∈ (l₂, l₁) where f'(c) > 0, then concludes by the sign of the difference quotient. □

**Remark**. The restriction l₂ ≥ 1 is necessary: f has a minimum near l ≈ 0.567 where exp(l) = 1/l. Below this point, f is decreasing, so gap amplification fails. This non-monotonicity is a genuinely quantum phenomenon — the interplay between exponential growth and logarithmic contraction creates a phase transition in the spectral EML behavior.

## 6. Quantum-Classical Bridge

**Theorem 6.1** (Bridge theorem). At φ = 0:
```
phaseNeuron(θ, 0) = exp(iθ)  and  ‖phaseNeuron(θ, 0)‖ = 1
```

The quantum EML framework exactly contains quantum phase gates.

**Theorem 6.2** (Reality curve). At φ = sin θ:
```
Im(phaseNeuron(θ, sin θ)) = 0  and  Re(phaseNeuron(θ, sin θ)) = cos θ
```

The quantum EML framework contains classical real-valued activations as a codimension-1 slice.

### 6.1 Three Regimes

The parameter space ℝ² decomposes into three qualitatively distinct regimes:

| Curve | Formula | Output | Character |
|-------|---------|--------|-----------|
| Trivial unitary | φ = 0 | exp(iθ) | Quantum phase gate |
| Reality | φ = sin θ | cos θ | Classical activation |
| Sinusoidal unitary | φ = 2 sin θ | exp(−iθ) | Time-reversed gate |

Between φ = 0 and φ = sin θ: sub-unitary, complex-valued (dissipative quantum).
Between φ = sin θ and φ = 2 sin θ: sub-unitary, complex-valued (approaching reversal).
Beyond φ = 2 sin θ: super-unitary (amplifying).

## 7. Continuity and Topology

**Theorem 7.1** (Continuity). The map (θ, φ) ↦ phaseNeuron(θ, φ) is continuous ℝ² → ℂ.

**Theorem 7.2** (Defect continuity). The defect function (θ, φ) ↦ δ(θ, φ) is continuous ℝ² → ℝ.

These ensure that the unitarity locus {(θ, φ) : δ = 0} is a closed subset of ℝ², and that small perturbations of gate parameters produce small perturbations of the output — essential for any practical optimization procedure.

## 8. Algorithms

### 8.1 Phase Neuron Synthesis

Given a target z ∈ ℂ with |Re(z)| ≤ 1:
1. Compute θ = arccos(Re(z))
2. Compute φ = sin(θ) − Im(z)
3. Return QuantumEMLGate(θ, φ)

Complexity: O(1) per gate synthesis.

### 8.2 Unitarity Projection

Given a gate G = (θ, φ), project to the nearest unitary gate:
- If |φ| ≤ |φ − 2 sin θ|, project to (θ, 0)
- Otherwise, project to (θ, 2 sin θ)

This gives the nearest unitary gate in parameter space (not necessarily in operator norm).

## 9. Discussion and Open Problems

### 9.1 Falsifiable Conjecture

**Conjecture** (Quantum EML Universal Approximation). For any continuous f : [−1, 1] → ℂ and ε > 0, there exists a finite composition of quantum EML gates G₁, …, Gₙ such that the pointwise product of outputs approximates f uniformly to within ε.

**Test**: For specific target functions (e.g., the Chebyshev polynomials restricted to [−1,1] with complex coefficients), compute the approximation error as a function of the number of gates.

### 9.2 Connections to Existing Work

The EML framework connects to tropical semirings via the large-parameter limits: as θ → ∞ or φ → ∞, the phase neuron's behavior transitions from oscillatory to dominated by the imaginary shift, analogous to the tropical limit of the max-plus algebra.

The defect quadratic form φ² − 2φ sin θ connects to the theory of quantum error correction, where syndrome measurements are quadratic forms on error spaces.

## 10. Conclusion

The phase neuron and QuantumEMLGate framework provide a rigorous mathematical foundation for quantum-classical neural network architectures. The key insight is that the unitarity locus — the set of parameters yielding information-preserving gates — has a beautiful geometric structure (two intersecting curves in ℝ²) with physical meaning (time reversal on the sinusoidal branch). The image characterization and spectral gap amplification results complete the picture, showing both what the framework can compute and how it processes spectral information.

## References

1. EML Framework: `Catalog/EML/EMLv17Core.lean` — Original real-valued EML definitions and properties
2. Tropical connection: `Catalog/Bridges/EMLTropicalSemiring.lean` — Quantum-classical bound
3. Universal approximation: `Catalog/Bridges/UniversalApproximation.lean` — Continuity of EML exp neurons
4. Spectral theory context: `Catalog/Cryptography/BerggrenDiophantineLattice.lean` — Lorentz form and spectral methods
