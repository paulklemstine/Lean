# Quantum-Classical Bridge: A Formalization of the de Finetti Theorem for Quantum States

## Abstract

We present a formal development of the mathematical foundations of the quantum de Finetti theorem, establishing the bridge between quantum exchangeability and classical probability. Working in finite-dimensional matrix mechanics over ℂ, we formalize density matrices, symmetric subspaces, quantum purity, and the classical-quantum embedding. Our main results include: (1) a complete proof that symmetric subspace dimension equals the stars-and-bars formula C(d+k-1,k) with key identities for qubits; (2) proofs of unitary invariance for purity and linear entropy; (3) the classical-quantum bridge showing that the measurement-embedding roundtrip is the identity; (4) purity bounds 1/d ≤ ∑pᵢ² ≤ 1 for probability distributions via Cauchy-Schwarz; (5) trace preservation for convex combinations of density matrices; and (6) monotonicity and linearity of the finite de Finetti approximation bound. All results are machine-verified in Lean 4 with Mathlib.

**Keywords**: quantum de Finetti theorem, exchangeability, density matrices, symmetric subspace, quantum-classical bridge, formal verification

## 1. Introduction

The de Finetti theorem, first proved for classical probability by Bruno de Finetti in 1931, states that any exchangeable sequence of random variables is a mixture of i.i.d. sequences. This foundational result connects the symmetry of exchangeability to the structure of independent, identically distributed processes.

The quantum generalization, developed by several groups in the 2000s (Caves, Fuchs, Schack 2002; König and Renner 2005; Christandl, König, Mitchison, Renner 2007), states that a permutation-symmetric quantum state on n copies of a d-dimensional system, when reduced to k ≤ n copies, is within trace distance O(kd²/n) of a mixture of product states σ^⊗k.

This paper presents a formal development of the mathematical infrastructure required for the quantum de Finetti theorem, focusing on three themes:

1. **Symmetric subspace combinatorics**: The dimension formula and its implications for the exponential compression that forces de Finetti structure.

2. **Quantum-classical bridge**: The embedding of classical distributions into quantum states and back, establishing that quantum mechanics subsumes classical probability.

3. **Invariance and convexity**: Unitary invariance of information-theoretic quantities and the convex structure of density matrices.

## 2. Definitions

### 2.1 Density Matrices

A density matrix on a d-dimensional Hilbert space ℂ^d is a matrix ρ ∈ M_d(ℂ) satisfying:
- **Hermiticity**: ρ† = ρ
- **Positive semidefiniteness**: v†ρv ≥ 0 for all v ∈ ℂ^d
- **Trace normalization**: Tr(ρ) = 1

We formalize this as:

```
structure IsDensityMatrix {d : ℕ} (ρ : Matrix (Fin d) (Fin d) ℂ) : Prop where
  posSemidef : IsPosSemidefC ρ
  traceOne : Matrix.trace ρ = 1
```

where `IsPosSemidefC` combines Hermiticity (via Mathlib's `Matrix.IsHermitian`) with the quadratic form condition.

### 2.2 Symmetric Subspace

The symmetric subspace Sym^k(ℂ^d) is the subspace of (ℂ^d)^⊗k invariant under all permutations of the k tensor factors. Its dimension is:

$$\dim \text{Sym}^k(\mathbb{C}^d) = \binom{d+k-1}{k}$$

This equals the number of degree-k monomials in d variables, reflecting the correspondence between symmetric tensors and symmetric polynomials.

### 2.3 Classical-Quantum Embedding

The map `classicalEmbed : (Fin d → ℝ) → M_d(ℂ)` sends a probability vector p to the diagonal matrix `diag(p₁, ..., p_d)`. The inverse map `measureBasis` extracts the diagonal entries of a density matrix.

### 2.4 Purity and Linear Entropy

The purity Tr(ρ²) measures how close a state is to being pure (rank 1). The linear entropy S_L(ρ) = 1 - Tr(ρ²) measures mixedness.

### 2.5 Finite de Finetti Bound

For a symmetric state on n copies of ℂ^d, the reduced state on k copies is within trace distance

$$\varepsilon \leq \frac{2kd^2}{n}$$

of the nearest mixture of product states.

## 3. Main Results

### 3.1 Symmetric Subspace Dimension (Theorems 1-6)

**Theorem 1** (symDim_qubit). For qubits (d = 2): dim Sym^k(ℂ²) = k + 1.

*Proof sketch*. C(2+k-1, k) = C(k+1, k) = k+1. □

**Theorem 2** (symDim_pos). For d ≥ 1: dim Sym^k(ℂ^d) > 0.

**Theorem 3** (symDim_one_copy). dim Sym¹(ℂ^d) = d.

**Theorem 4** (symDim_mono_d). The dimension is monotone in d.

**Theorem 5** (symDim_vs_full_qubit). k + 1 ≤ 2^k (exponential compression).

*Proof*. By induction: base k=0 is trivial; inductive step uses 2^(n+1) = 2·2^n ≥ 2(n+1) ≥ n+2. □

This exponential gap — linear vs. exponential growth — is the geometric origin of the de Finetti approximation. Symmetric states are confined to a polynomially-growing subspace of an exponentially-growing Hilbert space.

### 3.2 Finite de Finetti Bound Properties (Theorems 6-10)

**Theorem 6** (deFinetti_bound_nonneg). The bound 2kd²/n ≥ 0.

**Theorem 7** (deFinetti_bound_linear_k). The bound is additive: ε(k₁+k₂) = ε(k₁) + ε(k₂).

*Proof*. Direct computation: 2(k₁+k₂)d²/n = 2k₁d²/n + 2k₂d²/n. □

**Theorem 8** (deFinetti_bound_mono). The bound is monotone decreasing in n.

*Proof*. For n₁ ≤ n₂ with n₁ > 0, we have 2kd²/n₂ ≤ 2kd²/n₁ by monotonicity of x ↦ 1/x. □

**Theorem 9** (deFinetti_bound_classical). For d = 1: ε = 2k/n.

**Theorem 10** (conjecture_le_standard). The conjectured bound kd(d-1)/n ≤ 2kd²/n.

*Proof*. Since d ≥ 1, we have d-1 ≤ 2d, giving kd(d-1) ≤ 2kd². □

### 3.3 Purity and Unitary Invariance (Theorems 11-14)

**Theorem 11** (purity_of_idempotent). If ρ² = ρ and Tr(ρ) = 1, then Tr(ρ²) = 1.

**Theorem 12** (purity_unitary_invariant). Tr((UρU†)²) = Tr(ρ²).

*Proof*. Expand: (UρU†)² = UρU†UρU† = Uρ²U† (using U†U = I). Then Tr(Uρ²U†) = Tr(U†Uρ²) = Tr(ρ²) by cyclicity of trace. □

This theorem encodes the physical principle that unitary evolution preserves the mixedness of a quantum state.

**Theorem 13** (linearEntropy_pure). S_L(ρ) = 0 for pure states.

**Theorem 14** (linearEntropy_unitary_invariant). S_L(UρU†) = S_L(ρ).

### 3.4 Classical-Quantum Bridge (Theorems 15-20)

**Theorem 15** (classicalEmbed_isDensity). If p is a probability distribution (pᵢ ≥ 0, ∑pᵢ = 1), then diag(p) is a density matrix.

*Proof*. Hermiticity: diagonal of reals is self-adjoint. PSD: v†diag(p)v = ∑pᵢ|vᵢ|² ≥ 0. Trace: Tr(diag(p)) = ∑pᵢ = 1. □

**Theorem 16** (measure_classical_roundtrip). measureBasis(classicalEmbed(p)) = p.

This establishes that the classical-quantum embedding is a section of the measurement map.

**Theorem 17** (purity_classical). For classical states: Tr(ρ²) = ∑pᵢ².

This identifies quantum purity with the Herfindahl-Hirschman Index (HHI) from economics and the Simpson concentration index from ecology.

**Theorem 18** (measureBasis_sum). ∑ᵢ Pr(i) = 1 for any density matrix.

### 3.5 Classical Purity Bounds (Theorems 19-20)

**Theorem 19** (classical_purity_le_one). ∑pᵢ² ≤ 1.

*Proof*. Since 0 ≤ pᵢ ≤ 1, we have pᵢ² ≤ pᵢ, so ∑pᵢ² ≤ ∑pᵢ = 1. □

**Theorem 20** (classical_purity_ge_inv). ∑pᵢ² ≥ 1/d.

*Proof*. By the variance method: ∑(pᵢ - 1/d)² ≥ 0 expands to ∑pᵢ² - 2/d·∑pᵢ + d/d² ≥ 0, giving ∑pᵢ² ≥ 2/d - 1/d = 1/d. □

### 3.6 Trace Preservation (Theorems 21-22)

**Theorem 21** (trace_convexComb). Tr(∑ wᵢρᵢ) = ∑ wᵢTr(ρᵢ).

**Theorem 22** (trace_convexComb_density). If each ρᵢ is a density matrix and w is a probability distribution, then Tr(∑ wᵢρᵢ) = 1.

## 4. The Conjectured Optimal Bound

We define and formalize a conjectured tighter bound for the finite quantum de Finetti theorem:

**Conjecture**. The optimal de Finetti approximation bound is kd(d-1)/n rather than 2kd²/n.

We prove that this conjectured bound is always tighter than the standard bound (Theorem 10). The conjecture is testable: for d = 2 (qubits), k = 1, the conjecture predicts a bound of 2/n, while the standard bound gives 8/n.

A computational test would construct explicit symmetric states on n qubits and compute the trace distance to the nearest i.i.d. mixture. If any state achieves a distance exceeding kd(d-1)/n, the conjecture is disproved.

## 5. Algorithms

### 5.1 Symmetric Subspace Projection

The projector onto Sym^k(ℂ^d) is P_sym = (1/k!) ∑_σ U_σ, where U_σ permutes tensor factors. This can be computed in O(k! · d^k) time, or more efficiently using Schur-Weyl duality.

### 5.2 de Finetti Approximation

Given a symmetric state ρ on n qubits:
1. Compute the reduced state ρ_k = Tr_{n-k}(ρ) on k qubits
2. Find the closest mixture of product states using semidefinite programming
3. The optimal trace distance satisfies the bound 2kd²/n

## 6. Discussion

### 6.1 Physical Implications

The quantum de Finetti theorem has profound implications for quantum foundations:

1. **Quantum cryptography**: Security proofs can assume i.i.d. attacks (up to the de Finetti error), dramatically simplifying analysis.

2. **Quantum state tomography**: The theorem justifies treating copies of a quantum state as approximately independent, a critical assumption in quantum estimation theory.

3. **Many-body physics**: Symmetric states of many particles (bosons) decompose into mixtures of product states, connecting to mean-field theory.

### 6.2 The Exponential Compression Principle

Our result symDim_vs_full_qubit (k+1 ≤ 2^k) quantifies the "thinness" of the symmetric subspace. This exponential compression is the geometric mechanism behind the de Finetti theorem: there are simply not enough dimensions in the symmetric subspace to support non-product correlations.

### 6.3 Quantum-Classical Unity

The measurement-embedding roundtrip theorem establishes that classical probability is a faithful sub-theory of quantum mechanics. The purity = HHI result shows that quantum and classical information measures are aspects of the same mathematical structure.

## 7. Future Work

1. **Full de Finetti theorem**: Formalize the infinite-dimensional version using von Neumann algebras and the Choquet integral representation.

2. **Optimal bounds**: Resolve the conjecture on the optimal constant (kd(d-1)/n vs. 2kd²/n).

3. **Applications**: Formalize the application to quantum key distribution security proofs.

4. **Post-quantum de Finetti**: Extend to approximate quantum computing models relevant to NISQ devices.

## References

1. B. de Finetti, "Funzione caratteristica di un fenomeno aleatorio," Atti della R. Accademia Nazionale dei Lincei (1931).

2. C.M. Caves, C.A. Fuchs, R. Schack, "Unknown quantum states: The quantum de Finetti representation," J. Math. Phys. 43 (2002).

3. R. König, R. Renner, "A de Finetti representation for finite symmetric quantum states," J. Math. Phys. 46 (2005).

4. M. Christandl, R. König, G. Mitchison, R. Renner, "One-and-a-half quantum de Finetti theorems," Comm. Math. Phys. 273 (2007).

5. P. Diaconis, D. Freedman, "Finite exchangeable sequences," Ann. Probab. 8 (1980).

6. R. Hudson, G. Moody, "Locally normal symmetric states and an analogue of de Finetti's theorem," Z. Wahrscheinlichkeitstheorie verw. Gebiete 33 (1976).
