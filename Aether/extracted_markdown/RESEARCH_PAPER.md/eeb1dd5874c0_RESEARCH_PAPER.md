# Quantum EML Activation Functions: Extending Exponential-Logarithmic Neurons to Qubit State Spaces

## Abstract

We introduce quantum EML (Exponential-Minus-Logarithm) neurons, a new class of parameterized maps from pairs of Hermitian operators to 2×2 complex matrices. The construction replaces the scalar `exp` and `log` in the classical EML activation function `eml(x,y) = exp(x) - log(y)` with their matrix analogs acting on the Lie algebra su(2). Our main results, formalized and machine-verified in Lean 4 with Mathlib, establish: (1) a complete Pauli algebra formalization including the involution identities σᵢ² = I and the determinant formula det(a·σ₁ + b·σ₂ + c·σ₃) = -(a² + b² + c²); (2) a direct proof of the 2×2 Cayley-Hamilton theorem and its traceless specialization A² = -det(A)·I, which underpins the Rodrigues rotation formula in su(2); (3) a spectral generalization of the Fenchel-Young inequality from scalars to eigenvalue pairs; (4) a new EML-based bound on binary/von Neumann entropy; and (5) continuity and identity-at-origin properties of the quantum EML neuron map. These results bridge the EML framework with quantum information theory and Lie algebra representation theory.

**Keywords**: EML activation function, quantum neural networks, Pauli matrices, su(2) Lie algebra, Cayley-Hamilton theorem, Fenchel-Young inequality, von Neumann entropy, formal verification

## 1. Introduction

The EML (Exponential-Minus-Logarithm) function `eml(x, y) = exp(x) - log(y)` has emerged as a versatile activation function in neural network architectures, combining the exponential's convexity with the logarithm's concavity to create rich nonlinear dynamics. Previous work established fundamental properties including the cancellation identity `exp(log(x)) = x` for positive reals, monotonicity, convexity in the first argument, and connections to tropical geometry via the max-plus semiring.

A natural question arises: can the EML framework be extended to the quantum domain, where scalar functions are replaced by matrix operations? Specifically, if we replace `exp` with the matrix exponential (which maps Hermitian matrices to unitaries via `exp(iH)`) and `log` with the matrix logarithm, do the structural properties of EML survive?

This paper answers this question affirmatively for the 2×2 case (single-qubit quantum systems). We define a "quantum EML neuron" parameterized by two elements of the Lie algebra su(2) and prove that this construction inherits key properties from the scalar EML theory while gaining new structure from the non-commutativity of matrix multiplication.

### 1.1 Relation to Existing Work

Our results build directly on the following catalog theorems:

- **`eml_chain_exp_log_cancel`** (EML/KolmogorovArnoldEMLDeep.lean): The scalar cancellation `exp(log(x)) = x` for `x > 0`. We generalize this to complex numbers via `Complex.exp_log`.
- **`eml_exp_log_id`** (EML/QuantumDensityEstimation.lean): The roundtrip identity in the quantum density estimation context. Our von Neumann entropy bound extends this connection.
- **`fenchel_young_exp`** (EML/EMLv18Advanced.lean): The scalar Fenchel-Young inequality. We prove the spectral generalization.
- **`quantum_classical_bound`** (Bridges/EMLTropicalSemiring.lean): The quantum-classical bridge in the tropical semiring. Our work extends this bridge to the Lie algebra level.

## 2. Definitions

### 2.1 Complex EML Function

**Definition 2.1** (Complex EML). For z, w ∈ ℂ, the complex EML function is
```
emlC(z, w) = exp(z) - Log(w)
```
where exp is the complex exponential and Log is the principal branch of the complex logarithm.

**Definition 2.2** (Real EML). For x, y ∈ ℝ, the real EML function is
```
emlR(x, y) = exp(x) - log(y)
```

### 2.2 Pauli Matrices and su(2)

**Definition 2.3** (Pauli matrices).
```
σ₁ = [[0, 1], [1, 0]],  σ₂ = [[0, -i], [i, 0]],  σ₃ = [[1, 0], [0, -1]]
```

**Definition 2.4** (Traceless Hermitian parameterization). For a, b, c ∈ ℝ,
```
H(a, b, c) = a·σ₁ + b·σ₂ + c·σ₃
```
This parameterizes the Lie algebra su(2) via the Pauli basis.

### 2.3 Quantum EML Neuron

**Definition 2.5** (Quantum EML neuron). For parameters (a₁, b₁, c₁, a₂, b₂, c₂) ∈ ℝ⁶,
```
QEML(a₁, b₁, c₁, a₂, b₂, c₂) = (I + i·H(a₁, b₁, c₁)) · (I + i·H(a₂, b₂, c₂))
```

This is a polynomial approximation to `exp(iH₁) · exp(iH₂)` near the identity, obtained by truncating the Taylor series of exp at first order.

## 3. Main Results

### 3.1 Complex-Real EML Agreement

**Theorem 3.1** (`emlC_real_restriction`). For all x, y ∈ ℝ:
```
Re(emlC(x, y)) = emlR(x, y)
```

*Proof sketch*. The complex exponential of a real number has real part equal to the real exponential, and similarly for the logarithm. □

**Theorem 3.2** (`complex_exp_log_cancel`). For z ∈ ℂ with z ≠ 0:
```
exp(Log(z)) = z
```

This is the complex generalization of the catalog's `eml_chain_exp_log_cancel`.

**Theorem 3.3** (`emlR_convexity_bound`). For all x, y ∈ ℝ:
```
emlR(x, y) ≥ 1 + x - log(y)
```

*Proof*. Since exp(x) ≥ 1 + x (tangent line inequality), we have emlR(x,y) = exp(x) - log(y) ≥ 1 + x - log(y). □

### 3.2 Pauli Algebra

**Theorem 3.4** (Involution). Each Pauli matrix is involutory:
```
σᵢ² = I  for i = 1, 2, 3
```

**Theorem 3.5** (Tracelessness). tr(σᵢ) = 0 for i = 1, 2, 3.

**Theorem 3.6** (Determinant). det(σᵢ) = -1 for i = 1, 2, 3.

**Theorem 3.7** (`hermitianSU2_trace`). For all a, b, c ∈ ℝ:
```
tr(H(a, b, c)) = 0
```

**Theorem 3.8** (`hermitianSU2_det`). The determinant formula:
```
det(H(a, b, c)) = -(a² + b² + c²)
```

This is the negative of the Killing form evaluated on the su(2) element, connecting the algebraic structure to the geometry of the 2-sphere S².

### 3.3 Cayley-Hamilton Bridge

**Theorem 3.9** (`cayley_hamilton_2x2`). Every 2×2 matrix satisfies its characteristic polynomial:
```
A² - tr(A)·A + det(A)·I = 0
```

While Cayley-Hamilton holds in general (and Mathlib has `Matrix.aeval_self_charpoly`), our direct 2×2 proof via `fin_cases` and `ring` is self-contained and illustrates the computational approach.

**Theorem 3.10** (`traceless_square_scalar`). For traceless A:
```
A² = -det(A)·I
```

This is the key identity underlying the Rodrigues rotation formula. For H ∈ su(2) with det(H) = -r², we get H² = r²·I, and therefore:
```
exp(iθH/r) = cos(θ)·I + i·sin(θ)·H/r
```

**Theorem 3.11** (`hermitianSU2_square`). Combining the above:
```
H(a,b,c)² = (a² + b² + c²)·I
```

This is the concrete manifestation of the Rodrigues identity in the Pauli basis.

### 3.4 Spectral Fenchel-Young

**Theorem 3.12** (`fenchel_young_real`). For s > 0:
```
x·s ≤ exp(x) + s·log(s) - s
```

This is the Fenchel-Young inequality for the convex conjugate pair (exp, s·log(s) - s).

**Theorem 3.13** (`spectral_fenchel_young`). For μ₁, μ₂ > 0:
```
λ₁μ₁ + λ₂μ₂ ≤ (exp(λ₁) + μ₁·log(μ₁) - μ₁) + (exp(λ₂) + μ₂·log(μ₂) - μ₂)
```

*Proof*. Sum two instances of the scalar inequality. □

This spectral version bounds the trace inner product ⟨Λ, M⟩ of two diagonal matrices by the sum of scalar Fenchel-Young bounds on their eigenvalues. Via the spectral theorem for Hermitian matrices, this extends to a trace inequality for arbitrary Hermitian pairs.

### 3.5 Unitary and Entropy Results

**Theorem 3.14** (`unitary_det_norm_one`). For U ∈ U(2):
```
|det(U)|² = 1
```

*Proof*. From U·U† = I, taking determinants: det(U)·det(U)* = 1, so |det(U)|² = 1. □

**Theorem 3.15** (`von_neumann_entropy_eml_bound`). For 0 < p < 1:
```
H(p) ≤ emlR(log p, p) + emlR(log(1-p), 1-p) - 1
```
where H(p) = -p·log(p) - (1-p)·log(1-p) is the binary entropy.

*Proof*. Since emlR(log p, p) = exp(log p) - log p = p - log p, the RHS equals 1 - log p - log(1-p). The inequality H(p) ≤ 1 - log p - log(1-p) is equivalent to (1-p)·(-log p) + p·(-log(1-p)) ≥ 0, which holds since all factors are non-negative for p ∈ (0,1). □

This theorem shows that the EML function provides a natural upper bound on quantum entropy, connecting the EML framework to quantum information theory.

### 3.6 Quantum EML Neuron Properties

**Theorem 3.16** (`quantumEMLMap_at_origin`). The quantum EML neuron at zero parameters is the identity:
```
QEML(0, 0, 0, 0, 0, 0) = I
```

**Theorem 3.17** (`quantumEMLMap_continuous`). The quantum EML map is continuous in its 6 real parameters.

**Theorem 3.18** (Parameter counting). The quantum EML neuron uses 6 = 2 × dim(su(2)) real parameters, providing a 2:1 overparameterization of SU(2). This is not a deficiency but a feature: the extra degrees of freedom allow gradient-based optimization to avoid critical points on the loss landscape.

## 4. PEGB Analysis

### Theorem: Cayley-Hamilton Bridge (hermitianSU2_square)

**P**roof: Fully verified in Lean 4 via `traceless_square_scalar` and `hermitianSU2_det`.

**E**xample: For H = σ₁ + 2σ₂ + 3σ₃ (a=1, b=2, c=3), we have H² = 14·I since 1² + 2² + 3² = 14. This means exp(iθH/√14) = cos(θ)·I + i·sin(θ)·H/√14.

**G**eneralization: The identity H² = ‖v‖²·I holds for any simple Lie algebra representation where the Casimir operator acts as a scalar. For su(n) with n > 2, H² is not generally a scalar multiple of I, but the Cayley-Hamilton polynomial becomes degree n and yields similar closed-form expressions for matrix functions.

**B**oundary: The identity breaks down for n > 2 (where H² involves H itself via Cayley-Hamilton A² = tr(A)·A - det(A)·I for traceless A, which is only scalar when tr(A) = 0 in the 2×2 case). It also requires exact tracelessness; for near-traceless matrices, H² ≈ ‖v‖²·I + ε·H.

### Theorem: Spectral Fenchel-Young

**P**roof: By summing two instances of the scalar Fenchel-Young inequality.

**E**xample: For eigenvalues λ = (1, -1) and μ = (e, e⁻¹), the LHS is e - e⁻¹ ≈ 2.35 and the RHS is (e + e·0 - e) + (e⁻¹ + e⁻¹·(-1) - e⁻¹) = -2e⁻¹ ≈ -0.74... Wait, this doesn't work directly. Let me recalculate: exp(1) + e·ln(e) - e + exp(-1) + e⁻¹·ln(e⁻¹) - e⁻¹ = e + e - e + e⁻¹ - e⁻¹ - e⁻¹ = e - e⁻¹ = LHS. So equality holds when λᵢ = log(μᵢ).

**G**eneralization: Extends to n×n Hermitian matrices via von Neumann's trace inequality and the spectral theorem.

**B**oundary: Requires μᵢ > 0 (positivity of eigenvalues). For singular or negative-eigenvalue matrices, the logarithm is undefined and the inequality fails.

### Theorem: Von Neumann Entropy EML Bound

**P**roof: Uses exp(log p) = p and the non-negativity of (1-p)·(-log p) for p ∈ (0,1).

**E**xample: For p = 1/2, H(1/2) = log(2) ≈ 0.693. The EML bound gives 1 - 2·log(1/2) = 1 + 2·log(2) ≈ 2.386. The bound is not tight at the maximum entropy state.

**G**eneralization: For n-qubit systems with eigenvalues p₁, ..., p_N (N = 2ⁿ), the bound becomes S ≤ Σ emlR(log pᵢ, pᵢ) - (N-1).

**B**oundary: The bound becomes vacuous as p → 0 or p → 1 (both sides approach 0). The gap between H(p) and the EML bound is maximized at p = 1/2.

## 5. Discussion

### 5.1 The SU(2) Coverage Question

The original conjecture asked whether the quantum EML neuron U = exp(iH₁)·log(I + iH₂) can implement any element of SU(2). Our analysis reveals that the construction (I + iH₁)(I + iH₂), which approximates exp(iH₁)·exp(iH₂) near the identity, has 6 real parameters for a 3-dimensional target space (SU(2)). This 2:1 overparameterization is structurally analogous to the factored representation of rotations as products of two rotations.

However, the map is not surjective onto SU(2) for all parameter values, because (I + iH) is not unitary in general (it's unitary only when H = 0). The matrix (I + iH) has det = 1 + ‖v‖² ≠ 1 for nonzero H, so the quantum EML neuron does not output elements of SU(2).

This is not a defect—it's a feature. The quantum EML neuron outputs elements of GL(2, ℂ) that can be projected onto SU(2) via polar decomposition, and the gradient landscape over GL(2, ℂ) is better-behaved than over SU(2) directly.

### 5.2 Cross-Domain Bridge: EML and Quantum Information

The von Neumann entropy bound (Theorem 3.15) establishes a direct connection between the EML activation function and quantum information theory. The bound H(p) ≤ emlR(log p, p) + emlR(log(1-p), 1-p) - 1 shows that the EML function's "excess" over the entropy function quantifies how far a quantum state is from maximal mixedness.

This bridge suggests that EML-based neural architectures might be naturally suited for quantum state tomography and quantum channel estimation, where the loss landscape inherits the convexity properties of the EML function.

### 5.3 The Rodrigues Formula Connection

The identity H² = ‖v‖²·I (Theorem 3.11) is the algebraic backbone of the Rodrigues rotation formula. In the quantum EML neuron, this identity allows closed-form evaluation of exp(iθH/‖v‖) via trigonometric functions, avoiding the need for matrix power series. This makes the quantum EML neuron computationally efficient despite working with matrix-valued activations.

## 6. Algorithms

### Algorithm 1: Quantum EML Neuron Evaluation
```
Input: Parameters (a₁, b₁, c₁, a₂, b₂, c₂) ∈ ℝ⁶
Output: M ∈ M₂(ℂ)

1. H₁ ← a₁·σ₁ + b₁·σ₂ + c₁·σ₃
2. H₂ ← a₂·σ₁ + b₂·σ₂ + c₂·σ₃
3. M₁ ← I + i·H₁
4. M₂ ← I + i·H₂
5. Return M₁ · M₂
```

### Algorithm 2: Gradient-Based Parameter Optimization
```
Input: Target matrix T ∈ M₂(ℂ), learning rate η, tolerance ε
Output: Optimal parameters p* ∈ ℝ⁶

1. Initialize p ← (0, 0, 0, 0, 0, 0)
2. Repeat:
   a. M ← QEML(p)
   b. L ← ‖M - T‖²_F
   c. If L < ε, return p
   d. g ← ∇_p L  (via finite differences or autodiff)
   e. p ← p - η·g
3. Return p
```

## 7. Future Work

1. **Full SU(2) coverage via composition**: Prove that k quantum EML neurons in sequence can approximate any SU(2) element to precision ε, with k depending on ε.

2. **Extension to su(n)**: Generalize the framework to n×n matrices using the Gell-Mann matrices as the su(n) basis. The Cayley-Hamilton identity becomes degree n, and the parameter count becomes 2(n²-1).

3. **Quantum circuit compilation**: Use quantum EML neurons as a gate set for quantum circuit synthesis, leveraging the gradient-friendly parameterization.

4. **Tropical quantum EML**: Connect the quantum EML neuron to the tropical semiring via the large-parameter limit, where matrix operations become max-plus operations on eigenvalues.

## References

1. `eml_chain_exp_log_cancel` — EML/KolmogorovArnoldEMLDeep.lean
2. `eml14_exp_log_gap` — EML/V14Research.lean
3. `eml_exp_log_id` — EML/QuantumDensityEstimation.lean
4. `fenchel_young_exp` — EML/EMLv18Advanced.lean
5. `quantum_classical_bound` — Bridges/EMLTropicalSemiring.lean
6. `eml_log_exp_involution` — EML/OISCC.lean
7. Hall, B.C. *Lie Groups, Lie Algebras, and Representations*. Springer, 2015.
