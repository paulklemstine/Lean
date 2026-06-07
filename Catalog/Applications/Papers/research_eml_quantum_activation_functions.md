# Quantum EML Activation Functions: Surjectivity, Phase-Amplitude Factorization, and the Classical Bridge

## Abstract

We introduce the **quantum EML (Exponential-Minus-Logarithm) activation function**, a complex-valued extension of the classical EML activation `eml(x,y) = exp(x) - log(y)` obtained by replacing the real exponential with a unitary phase rotation exp(iθ) and the logarithmic input with a complex argument 1 + ri. We define the quantum EML neuron as

$$\text{qeml}(\theta, r) = e^{i\theta} \cdot \log(1 + ri)$$

and prove three main results: (1) **Phase-amplitude factorization** — the norm of qeml(θ,r) depends only on r, establishing a natural U(1)-fibration structure; (2) **Surjectivity** — the map (θ,r) ↦ qeml(θ,r) is surjective onto ℂ, the scalar analog of the SU(2) coverage conjecture for quantum neural networks; and (3) **Classical bridge** — the complex EML ceml(z₁,z₂) = exp(z₁) - log(z₂) restricted to real inputs recovers the classical EML identically. All results are formalized and verified in Lean 4 with Mathlib.

## 1. Introduction

The EML activation function `eml(x,y) = exp(x) - log(y)` has emerged as a mathematically rich building block for neural network architectures. Its algebraic properties — including the chain cancellation `exp(log(x)) = x`, monotonicity in both arguments, and convexity structure — make it particularly amenable to theoretical analysis.

A natural question arises when considering quantum extensions: if the exponential and logarithm are the fundamental operations of classical EML, what happens when we replace them with their quantum analogs? In quantum mechanics, the exponential of an imaginary Hermitian operator exp(iH) produces a unitary transformation, while the complex logarithm provides the necessary nonlinearity. This motivates the **quantum EML conjecture**: that quantum EML neurons, defined via unitary exponentials and complex logarithms, can implement arbitrary quantum operations.

In this paper, we establish the scalar (single-complex-number) version of this conjecture. Our main result is that the quantum EML neuron qeml(θ,r) = exp(iθ) · log(1 + ri) is surjective onto ℂ. This provides the foundational case for the matrix-valued conjecture about SU(2) coverage.

## 2. Definitions

### 2.1 Quantum EML Activation

**Definition 1** (Quantum EML). For θ, r ∈ ℝ, the *quantum EML activation function* is
$$\text{qeml}(\theta, r) = e^{i\theta} \cdot \log(1 + ri)$$
where log denotes the principal branch of the complex logarithm.

**Definition 2** (Complex EML). For z₁, z₂ ∈ ℂ, the *complex EML function* is
$$\text{ceml}(z_1, z_2) = e^{z_1} - \log(z_2)$$
generalizing the classical `eml(x,y) = exp(x) - log(y)`.

**Definition 3** (Quantum EML Norm). The *quantum EML norm function* is
$$\|\text{qeml}\|(r) = \|\log(1 + ri)\|$$
which controls the radial component of the quantum EML output.

### 2.2 Slit Plane Membership

A key technical prerequisite is that the input 1 + ri always lies in the complex slit plane (the complement of the negative real axis), ensuring the principal logarithm is well-defined and analytic.

**Lemma 1** (Slit Plane Membership). For all r ∈ ℝ, 1 + ri ∈ slitPlane.

*Proof.* Re(1 + ri) = 1 > 0. ∎

**Lemma 2** (Nonvanishing). For all r ∈ ℝ, 1 + ri ≠ 0.

**Lemma 3** (Log Characterization). log(1 + ri) = 0 if and only if r = 0.

*Proof.* If log(1 + ri) = 0, then exp(log(1 + ri)) = exp(0) = 1. Since 1 + ri ≠ 0 (Lemma 2), exp(log(1 + ri)) = 1 + ri, so 1 + ri = 1, giving r = 0. The converse follows from log(1) = 0. ∎

## 3. Main Results

### 3.1 Phase-Amplitude Factorization

**Theorem 1** (Phase-Amplitude Factorization). For all θ, r ∈ ℝ,
$$\|\text{qeml}(\theta, r)\| = \|\text{qeml}\|(r)$$
That is, the norm of the quantum EML output is independent of the phase parameter θ.

*Proof.* ‖qeml(θ,r)‖ = ‖exp(iθ)‖ · ‖log(1+ri)‖ = 1 · ‖log(1+ri)‖ = ‖qeml‖(r), using the fact that |exp(iθ)| = 1 for all real θ. ∎

This theorem establishes that the quantum EML output space has the structure of a U(1)-principal bundle: the base space is parameterized by the norm (controlled by r), and the fiber over each norm value is a circle (parameterized by θ). This is the geometric foundation for the surjectivity proof.

**Corollary 1.** qeml(θ,r) = 0 if and only if r = 0.

### 3.2 Real and Imaginary Part Decomposition

**Theorem 2** (Component Formulas). For all r ∈ ℝ,
$$\text{Re}(\log(1 + ri)) = \log\sqrt{1 + r^2}, \quad \text{Im}(\log(1 + ri)) = \arctan(r)$$

*Proof.* The real part follows from Complex.log_re, which gives Re(log z) = log ‖z‖, and the computation ‖1 + ri‖ = √(1 + r²). The imaginary part follows from Complex.log_im, which gives Im(log z) = arg(z), and the fact that arg(1 + ri) = arctan(r/1) = arctan(r) since Re(1 + ri) = 1 > 0. ∎

### 3.3 Surjectivity

**Theorem 3** (Quantum EML Surjectivity). The map (θ, r) ↦ qeml(θ, r) is surjective onto ℂ.

*Proof sketch.* For w = 0, use (θ, 0) for any θ. For w ≠ 0:

**Step 1 (Norm matching via IVT):** The norm function ‖qeml‖(r) is continuous (Theorem 4), vanishes at r = 0, and tends to infinity (Theorem 5). By the Intermediate Value Theorem, for any target norm ‖w‖ > 0, there exists r₀ with ‖qeml‖(r₀) = ‖w‖.

**Step 2 (Phase matching):** With r₀ chosen, let L = log(1 + r₀i) ≠ 0. The ratio w/L has norm ‖w‖/‖L‖ = 1, so w/L lies on the unit circle. Setting θ₀ = arg(w/L), we have exp(iθ₀) = w/L (since any unit-norm complex number equals exp(i · arg(·))). Therefore qeml(θ₀, r₀) = exp(iθ₀) · L = (w/L) · L = w. ∎

**Theorem 4** (Continuity). The functions qeml and ‖qeml‖ are continuous.

*Proof.* The map r ↦ 1 + ri is continuous (linear), Complex.log is continuous at slit plane points (by differentiability), and the composition with norm is continuous. For qeml, the product of the continuous functions θ ↦ exp(iθ) and r ↦ log(1 + ri) is continuous. ∎

**Theorem 5** (Norm Divergence). ‖qeml‖(r) → ∞ as r → ∞.

*Proof.* ‖log(1 + ri)‖ ≥ |Re(log(1 + ri))| = |log √(1 + r²)| = log √(1 + r²) → ∞. ∎

### 3.4 Classical Bridge

**Theorem 6** (Classical Bridge). For all x, y ∈ ℝ,
$$\text{Re}(\text{ceml}(x, y)) = \exp(x) - \log(y)$$

*Proof.* Re(ceml(x, y)) = Re(exp(x) - log(y)) = exp(x) - Re(log(y)) = exp(x) - log(y), using the fact that the complex exponential and logarithm restricted to the real axis agree with their real counterparts. ∎

This theorem establishes that the classical EML lives inside the complex EML as the real slice. The quantum EML neuron is therefore a genuine extension, not a replacement.

### 3.5 Quantum-Classical Norm Bound

**Theorem 7** (Norm Lower Bound). For all θ, r ∈ ℝ,
$$|\arctan(r)| \leq \|\text{qeml}(\theta, r)\|$$

*Proof.* ‖qeml(θ,r)‖ = ‖log(1+ri)‖ ≥ |Im(log(1+ri))| = |arctan(r)|, using the fact that the norm of a complex number bounds its imaginary part. ∎

This bound connects the quantum EML to the arctangent function, establishing that the quantum activation always provides at least as much "signal" as the classical phase accumulation arctan(r). This generalizes the `quantum_classical_bound` from the tropical semiring bridge.

### 3.6 Phase Group Structure

**Theorem 8** (Phase Periodicity). qeml(θ + 2π, r) = qeml(θ, r).

**Theorem 9** (U(1) Action). exp(iθ₁) · qeml(θ₂, r) = qeml(θ₁ + θ₂, r).

These results establish that the phase parameter θ makes the quantum EML equivariant under the U(1) group action, confirming the fiber bundle picture from Theorem 1.

### 3.7 Quantum Chain Rule

**Theorem 10** (Quantum Exp-Log Cancellation). If -π < Im(qeml(θ,r)) ≤ π, then
$$\log(\exp(\text{qeml}(\theta, r))) = \text{qeml}(\theta, r)$$

This extends the classical chain cancellation `exp(log(x)) = x` (formalized as `eml_chain_exp_log_cancel` in the catalog) to the quantum setting, establishing that the exp-log duality of EML survives complexification.

## 4. PEGB Analysis

### 4.1 Surjectivity Theorem (Theorem 3)

- **Proof**: Complete Lean 4 proof via IVT on the norm function and phase matching.
- **Example**: To reach w = 3 + 4i (norm 5), find r ≈ 148.41 such that ‖log(1+ri)‖ = 5, then set θ = arg((3+4i)/log(1+148.41i)).
- **Generalization**: The next level up is the matrix case: for H₁, H₂ ∈ su(2) (traceless Hermitian 2×2), does (θ₁,θ₂,θ₃,r₁,r₂,r₃) ↦ exp(iH₁)·log(I+iH₂) cover SU(2)? The Euler angle decomposition suggests yes, with 6 parameters covering the 3-dimensional group.
- **Boundary**: The construction breaks at r = 0, where the output collapses to zero regardless of phase. This is the "dark point" of the quantum EML — the origin is reachable only as a limit, and the fiber bundle structure degenerates there (the fiber over norm 0 is a single point, not a circle).

### 4.2 Phase-Amplitude Factorization (Theorem 1)

- **Proof**: Direct computation using |exp(iθ)| = 1.
- **Example**: qeml(0, 1) = log(1+i) = ½log2 + iπ/4. qeml(π/2, 1) = i · log(1+i). Both have norm ‖log(1+i)‖ = √(¼(log2)² + π²/16) ≈ 0.868.
- **Generalization**: For matrix-valued quantum EML, the norm factorization becomes ‖exp(iH₁)·M‖ = ‖M‖ since unitary multiplication preserves operator norms — the same principle at higher dimension.
- **Boundary**: The factorization relies on |exp(iθ)| = 1, which holds only for the unitary exponential. If we allowed exp(zI) for general complex z (not purely imaginary), the factorization breaks and ‖exp(z)·M‖ = e^(Re z)·‖M‖ depends on both parameters.

### 4.3 Classical Bridge (Theorem 6)

- **Proof**: Direct computation using Complex.exp_re and Complex.log_ofReal_re.
- **Example**: ceml(1, e) = exp(1) - log(e) = e - 1 ≈ 1.718 on the real axis, matching eml(1, e).
- **Generalization**: The bridge extends to the full complex plane: ceml(z₁, z₂) reduces to eml when both arguments are real. This suggests a family of "partially quantum" activations interpolating between classical and quantum.
- **Boundary**: The bridge is exact only for real inputs. For complex inputs, the imaginary parts of exp and log introduce quantum phases with no classical analog.

## 5. Algorithm

### Quantum EML Neuron Forward Pass

```
ALGORITHM: QuantumEMLForward(θ, r)
INPUT: Phase angle θ ∈ ℝ, amplitude r ∈ ℝ
OUTPUT: Complex activation z ∈ ℂ

1. Compute unitary rotation: U ← cos(θ) + i·sin(θ)
2. Compute complex input: w ← 1 + r·i
3. Compute log-activation: L ← ½·ln(1 + r²) + i·arctan(r)
4. Return z ← U · L
```

### Inverse Quantum EML (Target Matching)

```
ALGORITHM: QuantumEMLInverse(w)
INPUT: Target w ∈ ℂ, w ≠ 0
OUTPUT: Parameters (θ, r) such that qeml(θ, r) = w

1. Target norm: ρ ← |w|
2. Solve ‖log(1 + ri)‖ = ρ for r (numerical root-finding on the norm equation)
3. Compute L ← log(1 + r·i)
4. Set θ ← arg(w / L)
5. Return (θ, r)
```

## 6. Discussion

### 6.1 Relation to Prior Work

The quantum EML activation function builds on several threads from the EML theory:

- **Chain cancellation** (`eml_chain_exp_log_cancel`): Our Theorem 10 extends this to the complex domain, showing the exp-log duality survives quantization.
- **Classical EML identities** (`eml_log_exp`, `eml_exp_log_id`): The classical bridge theorem (Theorem 6) shows these are special cases of complex EML identities.
- **Quantum-classical bounds** (`quantum_classical_bound`): Our norm lower bound (Theorem 7) provides a more geometric version of this result.

### 6.2 The SU(2) Conjecture

The scalar surjectivity result (covering ℂ) is strong evidence for the matrix conjecture (covering SU(2)). The key structural parallel is:

| Scalar (this paper) | Matrix (conjecture) |
|---------------------|---------------------|
| exp(iθ) ∈ U(1) | exp(iH) ∈ SU(2) |
| log(1+ri) ∈ ℂ | log(I+iH) ∈ M₂(ℂ) |
| 2 real parameters | 6 real parameters |
| Covers ℂ (2D) | Covers SU(2) (3D) |

The parameter count is favorable: 6 parameters for a 3-dimensional target space leaves 3 degrees of freedom, suggesting not just coverage but a 3-parameter family of representations for each SU(2) element.

### 6.3 Limitations

1. The construction has a degenerate point at r = 0 where all phases collapse.
2. The inverse map is not unique (multiple (θ,r) pairs can reach the same target).
3. The branch cut of the complex logarithm introduces discontinuities in the parameterization.

## 7. Future Work

1. **Matrix extension**: Prove the SU(2) coverage conjecture for 2×2 matrix quantum EML.
2. **Multi-qubit universality**: Extend to SU(2ⁿ) for n-qubit quantum circuits.
3. **Tropical-quantum bridge**: Connect the quantum EML to tropical semiring structures via the Maslov dequantization.
4. **Gradient flow**: Analyze the training dynamics of quantum EML neurons under gradient descent.

## 8. References

1. `eml_chain_exp_log_cancel` — EML/KolmogorovArnoldEMLDeep.lean
2. `eml_log_exp` — EML/EMLv17Core.lean  
3. `quantum_classical_bound` — Bridges/EMLTropicalSemiring.lean
4. `eml_exp_log_id` — EML/QuantumDensityEstimation.lean
5. `eml_exp_neuron_continuous` — EML/UniversalApproximation.lean
6. `eml_log_exp_involution` — EML/OISCC.lean

## Appendix: Formalized Theorem Statements

All theorems in this paper are formalized and verified in Lean 4 with Mathlib. The complete formalization is in `Applications/QuantumEMLActivation.lean`. Key theorem signatures:

```lean
theorem qeml_norm_eq (θ r : ℝ) : ‖qeml θ r‖ = qemlNorm r
theorem qeml_surj : Function.Surjective (fun p : ℝ × ℝ => qeml p.1 p.2)
theorem ceml_extends_eml (x y : ℝ) : (ceml ↑x ↑y).re = Real.exp x - Real.log y
theorem qeml_norm_lower_bound (θ r : ℝ) : |Real.arctan r| ≤ ‖qeml θ r‖
theorem qeml_phase_periodic (θ r : ℝ) : qeml (θ + 2 * Real.pi) r = qeml θ r
theorem qeml_phase_add (θ₁ θ₂ r : ℝ) : exp (↑θ₁ * I) * qeml θ₂ r = qeml (θ₁ + θ₂) r
```
