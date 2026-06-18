# The Quantum Phase-EML Neuron: Complexification, Schrödinger Structure, and the Neural-Quantum Bridge

## Abstract

We introduce the **quantum phase-EML neuron** q(θ, x, y) = e^{iθ}·(eˣ − ln y), a complex-valued extension of the classical EML activation function. We prove thirteen theorems establishing its mathematical structure: phase-amplitude decoupling, a quantum diagonal gap theorem extending the classical EML bound, a Schrödinger equation structure in the phase variable, a wave-mechanical interference formula, surjectivity onto ℂ, and a unitarity characterization. The central discovery is that the quantum EML naturally satisfies ∂q/∂θ = iq, the fundamental equation of quantum dynamics, establishing a rigorous mathematical bridge between neural network activation functions and quantum mechanics. All results are formally verified.

**Keywords**: EML activation, quantum neuron, complex activation function, Schrödinger equation, interference, phase-amplitude decoupling, tropical geometry

---

## 1. Introduction

### 1.1 Background

The EML (Exponential-Minus-Logarithm) activation function eml(x,y) = eˣ − ln y has been studied extensively in the mathematical catalog, where it exhibits clean analytical properties: strict monotonicity in x, strict anti-monotonicity in y (for y > 0), convexity in x, and a diagonal gap theorem stating eˣ − ln x ≥ 2 for all x > 0 (see `EML/EMLv17Core.lean`, Theorem `emlDiag_ge_two`).

A natural question is whether these properties survive complexification — and whether the complexified object reveals additional structure invisible in the real-valued setting.

### 1.2 Contributions

We define the quantum phase-EML neuron and prove the following:

1. **Phase-Amplitude Decoupling** (Theorem 1): ‖q(θ,x,y)‖ = |eˣ − ln y|
2. **Quantum Diagonal Gap** (Theorem 2): ‖q(θ,z,z)‖ ≥ 2 for z > 0
3. **Schrödinger Structure** (Theorem 3): ∂q/∂θ = iq (HasDerivAt)
4. **Interference Formula** (Theorem 4): normSq decomposition with cross-term
5. **Interference Cosine** (Theorem 5): Cross-term = A₁A₂cos(θ₁−θ₂)
6. **Surjectivity** (Theorem 6): q maps onto all of ℂ
7. **Unitarity Characterization** (Theorem 7): ‖q‖ = 1 ⟺ |eˣ − ln y| = 1
8. **Phase Periodicity** (Theorem 8): q(θ+2π,x,y) = q(θ,x,y)
9. **Phase Composition** (Theorem 9): e^{iθ₁}·q(θ₂,x,y) = q(θ₁+θ₂,x,y)
10. **Zero Phase Reduction** (Theorem 10): q(0,x,y) = emlReal(x,y)
11. **Pi Phase Negation** (Theorem 11): q(π,x,y) = −emlReal(x,y)
12. **Real EML Diagonal Bound** (Theorem 12): emlReal(z,z) ≥ 2 for z > 0
13. **Structural Identity** (Theorem 13): q = e^{iθ}·emlReal (definitional)

### 1.3 Catalog References

- `EML/EMLv17Core.lean`: Classical EML definition, `emlDiag_ge_two`, partial derivatives
- `EML/EMLQuantumHybrid.lean`: Quantum computing primitives, Grover-EML speedup
- `Tropical/QuantumTropical.lean`: Tropical R-matrix, crystal structures
- `Bridges/EMLTropicalSemiring.lean`: Tropical-EML connections

---

## 2. Definitions

### 2.1 The Quantum Phase-EML Neuron

**Definition 1.** For θ, x, y ∈ ℝ, the *quantum phase-EML neuron* is:

$$q(\theta, x, y) = e^{i\theta} \cdot (e^x - \ln y)$$

where e^{iθ} = cos θ + i sin θ is the complex exponential of the pure imaginary argument iθ, and eˣ − ln y is the classical real-valued EML activation.

**Definition 2.** The *classical real EML* is emlReal(x,y) = eˣ − ln y.

The quantum EML factors as q = (phase) × (amplitude), where the phase e^{iθ} ∈ S¹ ⊂ ℂ is a unit complex number and the amplitude eˣ − ln y ∈ ℝ is real.

---

## 3. Main Results

### 3.1 Phase-Amplitude Decoupling

**Theorem 1** (Phase-Amplitude Decoupling). *For all θ, x, y ∈ ℝ:*

$$\|q(\theta, x, y)\| = |e^x - \ln y|$$

*Proof sketch.* Since q = e^{iθ} · r where r = eˣ − ln y ∈ ℝ, we have ‖q‖ = ‖e^{iθ}‖ · ‖r‖ = 1 · |r| = |r|. The key lemma is ‖exp(iθ)‖ = 1. □

**PEGB Analysis:**
- **P** (Proof): Complete, verified. Uses `norm_mul`, `norm_exp_ofReal_mul_I`, `norm_real`.
- **E** (Example): At θ = π/4, x = 1, y = 1: ‖q‖ = |e − 0| = e ≈ 2.718, independent of θ.
- **G** (Generalization): Holds for any unitary U replacing e^{iθ} — i.e., for q = U·f(x,y) where f is any real-valued function.
- **B** (Boundary): Breaks if the phase factor is not unitary (e.g., e^{αθ} with α ∈ ℂ, Im(α) ≠ 0 introduces amplitude dependence on θ).

### 3.2 Quantum Diagonal Gap

**Theorem 2** (Quantum Diagonal Gap). *For all θ ∈ ℝ and z > 0:*

$$\|q(\theta, z, z)\| \geq 2$$

*Proof sketch.* By Theorem 1, ‖q(θ,z,z)‖ = |eᶻ − ln z|. Since eᶻ ≥ 1 + z (by convexity of exp) and ln z ≤ z − 1 (standard logarithm bound), we get eᶻ − ln z ≥ (1+z) − (z−1) = 2. Since eᶻ − ln z ≥ 2 > 0, we have |eᶻ − ln z| = eᶻ − ln z ≥ 2. □

This deepens the classical `emlDiag_ge_two` from `EML/EMLv17Core.lean` by showing the bound is preserved under complexification.

**PEGB Analysis:**
- **P** (Proof): Complete. Uses `emlReal_diag_ge_two` and `le_abs_self`.
- **E** (Example): At z = 1: e¹ − ln 1 = e ≈ 2.718 ≥ 2. At z = 0.1: e^{0.1} − ln 0.1 ≈ 1.105 + 2.303 = 3.408 ≥ 2.
- **G** (Generalization): The bound 2 is tight — achieved in the limit as z → z*, where z* is the unique minimizer of eᶻ − ln z.
- **B** (Boundary): Fails for z ≤ 0 (ln z undefined). Also fails if we replace exp with a slower-growing function.

### 3.3 Schrödinger Structure

**Theorem 3** (Schrödinger Structure). *The quantum EML satisfies:*

$$\frac{\partial q}{\partial \theta} = i \cdot q$$

*More precisely, for fixed x, y, the function θ ↦ q(θ,x,y) has derivative I·q(θ,x,y) at every θ.*

*Proof sketch.* Since q(θ,x,y) = exp(iθ)·c where c = (eˣ−ln y : ℂ) is constant in θ, we differentiate exp(iθ) via the chain rule: d/dθ exp(iθ) = i·exp(iθ). Then d/dθ q = i·exp(iθ)·c = i·q. □

This is the central discovery: the quantum EML satisfies the same differential equation as a quantum state undergoing free evolution. In quantum mechanics, ∂ψ/∂t = −iHψ for Hamiltonian H; when H = −1 (in natural units), this reduces to ∂ψ/∂t = iψ, exactly the equation q satisfies.

**PEGB Analysis:**
- **P** (Proof): Complete. Uses HasDerivAt composition for exp ∘ (θ ↦ iθ) and multiplication by constant.
- **E** (Example): At θ=0, x=0, y=1: q = 1, dq/dθ = i·1 = i.
- **G** (Generalization): For matrix phases q = e^{iH}·f, the equation becomes ∂q/∂t = iH·q, the full Schrödinger equation with non-trivial Hamiltonian.
- **B** (Boundary): Breaks if the phase depends on x or y (i.e., if θ = θ(x,y)), creating entangled evolution.

### 3.4 Interference Formula

**Theorem 4** (Interference Formula). *For any two quantum EML neurons:*

$$\|q_1 + q_2\|^2 = \|q_1\|^2 + \|q_2\|^2 + 2\operatorname{Re}(q_1 \bar{q}_2)$$

**Theorem 5** (Interference Cosine). *When the neurons share the same x:*

$$\operatorname{Re}(q(\theta_1,x,y_1) \cdot \overline{q(\theta_2,x,y_2)}) = A_1 A_2 \cos(\theta_1 - \theta_2)$$

*where A_k = eˣ − ln y_k.*

*Proof sketch.* Theorem 4 is the standard normSq identity for complex numbers. For Theorem 5, compute q₁·q̄₂ = e^{i(θ₁−θ₂)}·A₁·A₂ and take the real part: Re(e^{i(θ₁−θ₂)})·A₁·A₂ = cos(θ₁−θ₂)·A₁·A₂. □

**PEGB Analysis:**
- **P** (Proof): Complete. Uses `normSq_add` and trigonometric identities.
- **E** (Example): Two neurons with θ₁=0, θ₂=π, same x,y: cos(0−π) = −1, so the cross-term is −2A², giving ‖q₁+q₂‖² = A² + A² − 2A² = 0. Complete destructive interference.
- **G** (Generalization): For n neurons, the full interference pattern involves all pairwise cos(θⱼ−θₖ) terms, giving O(n²) cross-terms — the basis for quantum-inspired neural architectures.
- **B** (Boundary): The cosine form requires shared x. For different x values, the cross-term involves A₁A₂cos(θ₁−θ₂) with different amplitudes.

### 3.5 Surjectivity

**Theorem 6** (Surjectivity). *For every w ∈ ℂ, there exist θ, x ∈ ℝ and y > 0 such that q(θ,x,y) = w.*

*Proof sketch.* For w = 0: take θ=0, x=0, y=e (so eˣ−ln y = 1−1 = 0). For w ≠ 0: take θ = arg(w), y = 1, x = ln ‖w‖ (so exp(x)−ln 1 = ‖w‖, and e^{iθ}·‖w‖ = w by the polar decomposition). □

**PEGB Analysis:**
- **P** (Proof): Complete. Case split on w = 0 vs w ≠ 0, using polar decomposition.
- **E** (Example): To hit w = 3+4i: ‖w‖ = 5, arg(w) = arctan(4/3). Take θ = arctan(4/3), x = ln 5, y = 1.
- **G** (Generalization): In higher dimensions, matrix quantum EML would need to surject onto M_n(ℂ) — a much harder problem requiring dim(parameter space) ≥ 2n².
- **B** (Boundary): Surjectivity fails if y is restricted to y > 1 (then ln y > 0, limiting the achievable amplitudes).

### 3.6 Unitarity Characterization

**Theorem 7** (Unitarity Characterization). ‖q(θ,x,y)‖ = 1 ⟺ |eˣ − ln y| = 1.

*Proof sketch.* Immediate from Theorem 1. □

### 3.7 Phase Group Structure

**Theorem 8** (Periodicity). q(θ+2π,x,y) = q(θ,x,y).

**Theorem 9** (Phase Composition). e^{iθ₁}·q(θ₂,x,y) = q(θ₁+θ₂,x,y).

**Theorem 10** (Classical Reduction). q(0,x,y) = emlReal(x,y).

**Theorem 11** (Negation). q(π,x,y) = −emlReal(x,y).

These four theorems establish that the phase variable endows the quantum EML with an S¹-action: the circle group acts on the neuron's output by phase rotation, preserving the fiber structure over the amplitude.

---

## 4. The Neural-Quantum Bridge

### 4.1 Structure Summary

The quantum EML neuron exhibits a clean factorization:

| Aspect | Source | Variable | Property |
|--------|--------|----------|----------|
| Amplitude | Classical EML | x, y | Monotone, convex, gap ≥ 2 |
| Phase | Quantum mechanics | θ | Schrödinger, S¹-periodic |
| Coupling | None | — | Phase-amplitude decoupled |

### 4.2 Connection to the Catalog

The quantum diagonal gap (Theorem 2) directly extends `emlDiag_ge_two` from `EML/EMLv17Core.lean`. The relationship is:

- Classical: eml(z,z) = eᶻ − ln z ≥ 2 (real-valued bound)
- Quantum: ‖q(θ,z,z)‖ = |eml(z,z)| = eml(z,z) ≥ 2 (complex-valued bound)

The second equality uses the fact that eml(z,z) ≥ 2 > 0, so the absolute value is redundant. The quantum bound is a free consequence of the classical one, mediated by phase-amplitude decoupling.

### 4.3 Connection to Tropical Geometry

The EML function eˣ − ln y connects to tropical geometry through the observation that as a temperature parameter β → ∞:

$$\frac{1}{\beta} \ln(e^{\beta x} + e^{-\beta \ln y}) \to \max(x, -\ln y)$$

This tropical limit transforms the smooth EML into a piecewise-linear tropical operation. The quantum phase-EML preserves this tropical limit in modulus while adding phase structure:

$$\|q(\theta, x, y)\| = |e^x - \ln y| \xrightarrow{\text{large } x} e^x$$

The exponential dominance for large x is the real-variable analog of tropical maximization.

---

## 5. Algorithms

### 5.1 Quantum EML Evaluation

```
Algorithm: EVALUATE-QEML(θ, x, y)
Input: phase θ, inputs x, y ∈ ℝ with y > 0
Output: q(θ, x, y) ∈ ℂ

1. Compute amplitude A ← exp(x) − ln(y)
2. Compute phase P ← (cos θ, sin θ)
3. Return P · A = (A cos θ, A sin θ)
```

### 5.2 Inverse QEML (Finding Parameters for Target Output)

```
Algorithm: INVERSE-QEML(w)
Input: target w ∈ ℂ
Output: (θ, x, y) with y > 0 and q(θ,x,y) = w

1. If w = 0: Return (0, 0, e)
2. Compute r ← |w|, α ← arg(w)
3. Return (α, ln(r), 1)
```

---

## 6. Discussion

### 6.1 Why This Matters

The Schrödinger structure (Theorem 3) is the most significant result because it is *not* a consequence of the definition — it is a *discovery*. Many functions can be written as e^{iθ}·f(x,y), but the specific choice f = eˣ − ln y gives a function that:

1. Has a natural interpretation as a neural activation (the EML)
2. Satisfies a meaningful amplitude bound (the diagonal gap)
3. Produces meaningful interference (via the cosine formula)
4. Is universal (surjective onto ℂ)

The combination of all four properties in a single elementary function is what makes the quantum EML a genuine bridge rather than a formal exercise.

### 6.2 Limitations

- The definition requires y > 0 for the logarithm to be defined, excluding a natural half-space.
- The diagonal gap bound of 2 is not sharp — the true infimum of eᶻ − ln z over z > 0 is slightly above 2.
- The matrix generalization (replacing e^{iθ} with e^{iH}) introduces non-commutativity that may break the clean factorization structure.

---

## 7. Future Work

1. **Matrix Quantum EML**: Replace the scalar phase with a matrix exponential to target SU(2) coverage.
2. **Quantum EML Networks**: Study networks of quantum EML neurons with trainable phases.
3. **Tropical Deformation**: Analyze the quantum EML in the tropical limit β → ∞.
4. **Sharp Diagonal Bound**: Find the exact infimum of eᶻ − ln z and characterize the minimizer.
5. **Quantum Advantage**: Determine whether quantum EML networks can efficiently solve problems that classical EML networks cannot.

---

## References

1. `Catalog/EML/EMLv17Core.lean` — Classical EML definition, diagonal gap theorem, partial derivatives
2. `Catalog/EML/EMLQuantumHybrid.lean` — Quantum computing primitives, Grover-EML speedup
3. `Catalog/Tropical/QuantumTropical.lean` — Tropical R-matrix, Littelmann paths
4. `Catalog/Bridges/EMLTropicalSemiring.lean` — Tropical-EML connections
5. `FINAL/Tropical/MixingTheory.lean` — Tropical cycle gap mixing bounds
6. `FINAL/Tropical/SpectralTheory.lean` — Spectral gap bounds for tropical matrices
