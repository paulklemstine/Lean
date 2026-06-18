# Future Directions: Spectral Theory Infrastructure

## Overview

This document outlines 5 concrete next-step theorems that build on the spectral toolkit formalized in this project. Each direction is selected for its breakthrough potential in connecting spectral theory to other domains.

---

## Direction 1: Courant–Fischer Min-Max for All Eigenvalues

### Precise Theorem Statement
For a Hermitian matrix `A` with eigenvalues `λ₁ ≤ λ₂ ≤ ⋯ ≤ λₙ`, the *k*-th eigenvalue satisfies:

```
λₖ = min_{dim(V)=k} max_{x ∈ V, ‖x‖=1} x*Ax
   = max_{dim(W)=n-k+1} min_{x ∈ W, ‖x‖=1} x*Ax
```

### Lean Target Signature
```lean
theorem courant_fischer
    {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℂ) (hA : A.IsHermitian)
    (k : Fin (Fintype.card n)) :
    hA.eigenvalues₀ k = iInf (fun V : {S : Submodule ℂ (EuclideanSpace ℂ n) //
      FiniteDimensional.finrank ℂ S = k.val + 1} =>
      iSup (fun x : {v : V.val // ‖(v : EuclideanSpace ℂ n)‖ = 1} =>
        hermitianForm A x))
```

### Why It Is Breakthrough-Level
Courant-Fischer is the *computational* spectral theorem: it transforms eigenvalue computation into optimization. It directly yields:
- Interlacing inequalities for matrix minors
- Weyl's perturbation bounds
- Eigenvalue monotonicity under PSD addition
- Spectral partitioning guarantees for graph Laplacians

### Proof Strategies
1. **Induction on dimension**: Restrict A to the orthogonal complement of the first k-1 eigenvectors. Apply the max Rayleigh quotient result to this restricted operator. Show the min over subspaces is attained by the span of the first k eigenvectors.

2. **Direct variational argument**: For any k-dimensional subspace V, show that V must contain a vector with nontrivial component in the span of eigenvectors with eigenvalue ≥ λₖ, yielding max R(A,x) ≥ λₖ. Show the span of the first k eigenvectors achieves equality.

### Cross-Domain Impact
- **Numerical analysis**: Foundation for finite element eigenvalue bounds
- **Graph theory**: Spectral partitioning, Cheeger inequality, expansion
- **Quantum chemistry**: Variational principle for ground/excited state energies
- **Optimization**: SDP relaxation quality bounds
- **Random matrix theory**: Eigenvalue interlacing and concentration

---

## Direction 2: Spectral Theorem for Compact Self-Adjoint Operators

### Precise Theorem Statement
Let `T : E →ₗ[ℂ] E` be a compact self-adjoint operator on a separable Hilbert space `E`. Then there exists a (possibly countable) orthonormal set `{eᵢ}` of eigenvectors with real eigenvalues `{λᵢ}` converging to 0, such that:

```
T x = ∑ᵢ λᵢ ⟨eᵢ, x⟩ eᵢ
```

for all `x ∈ E`, where the sum converges in norm.

### Lean Target Signature
```lean
theorem compact_selfAdjoint_spectral
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E] [CompleteSpace E]
    (T : E →L[ℂ] E)
    (hT : IsSelfAdjoint T) (hK : IsCompact (T '' Metric.closedBall 0 1)) :
    ∃ (ι : Type*) [Countable ι] (e : ι → E) (λ : ι → ℝ),
      Orthonormal ℂ e ∧
      Filter.Tendsto λ Filter.cofinite (nhds 0) ∧
      ∀ x, T x = ∑' i, (λ i : ℂ) • inner (e i) x • e i
```

### Why It Is Breakthrough-Level
This extends spectral theory from matrices to operators on function spaces, enabling:
- Rigorous PDE spectral analysis (Laplacian eigenvalues on domains)
- Quantum mechanics on infinite-dimensional Hilbert spaces
- Integral equation theory (Fredholm alternative)
- Sturm-Liouville theory

### Proof Strategies
1. **Iterative extraction**: Show the Rayleigh quotient attains its supremum on the unit ball (by compactness). The maximizer is an eigenvector. Restrict to its orthogonal complement and repeat. Show eigenvalues converge to 0 by compactness of T.

2. **Spectral measure approach**: Construct the spectral measure from the resolvent. Show compactness implies discrete spectrum with finite multiplicities and unique accumulation point at 0.

### Cross-Domain Impact
- **PDE theory**: Eigenfunction expansions for elliptic operators
- **Quantum mechanics**: Bound state spectral theory, scattering theory
- **Machine learning**: Kernel PCA, Mercer's theorem
- **Functional analysis**: Fredholm theory, trace-class operators

---

## Direction 3: Weyl's Perturbation Inequality

### Precise Theorem Statement
For Hermitian matrices `A, B` with eigenvalues `α₁ ≤ ⋯ ≤ αₙ` and `β₁ ≤ ⋯ ≤ βₙ`:

```
max_i |αᵢ - βᵢ| ≤ ‖A - B‖_op
```

### Lean Target Signature
```lean
theorem weyl_perturbation
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ) (hA : A.IsHermitian) (hB : B.IsHermitian) :
    ∀ (k : Fin (Fintype.card n)),
      |hA.eigenvalues₀ k - hB.eigenvalues₀ k| ≤ ‖A - B‖
```

### Why It Is Breakthrough-Level
Perturbation bounds are essential for:
- Numerical stability of eigenvalue algorithms
- Quantum error analysis
- Robust statistics (effect of outliers on PCA)
- Certification of computed eigenvalues

### Proof Strategies
1. **Via Courant-Fischer**: Express both eigenvalues via min-max. For fixed subspace V, the max Rayleigh quotients differ by at most ‖A-B‖_op (by the Cauchy-Schwarz inequality for the perturbation). Take the min over V.

2. **Via eigenvalue interlacing**: Use the spectral theorem to write A = UDU*, B = UDU* + E where E = B-A. Apply Cauchy interlacing to the perturbed diagonal + perturbation.

### Cross-Domain Impact
- **Numerical analysis**: Backward stability of QR, SVD
- **Quantum computing**: Error bounds for approximate Hamiltonians
- **Statistics**: Perturbation of covariance eigenvalues under noise
- **Network science**: Stability of spectral clustering under edge perturbations

---

## Direction 4: Löwner Order and Matrix Monotonicity

### Precise Theorem Statement
For the Löwner partial order `A ≤_L B ⟺ B - A is PSD`:

1. If `A ≤_L B` then `λₖ(A) ≤ λₖ(B)` for all k.
2. If `f : ℝ → ℝ` is operator monotone, then `A ≤_L B ⟹ f(A) ≤_L f(B)`.
3. `x ↦ x^{1/2}` is operator monotone on PSD matrices.

### Lean Target Signature
```lean
theorem loewner_eigenvalue_monotone
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℝ) (hA : A.IsHermitian) (hB : B.IsHermitian)
    (h : (B - A).PosSemidef) (i : n) :
    hA.eigenvalues i ≤ hB.eigenvalues i

theorem sqrt_operator_monotone
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℝ)
    (hA : A.PosSemidef) (hB : B.PosSemidef)
    (h : (B - A).PosSemidef) :
    (continuousFunctionalCalculus A hA.isHermitian (fun x => Real.sqrt x) -
     continuousFunctionalCalculus B hB.isHermitian (fun x => Real.sqrt x)).PosSemidef
```

### Why It Is Breakthrough-Level
Matrix monotonicity is the foundation of:
- Semidefinite programming duality
- Quantum channel theory (complete positivity)
- Matrix inequalities (Golden-Thompson, Lieb-Thirring)
- Operator means and geometric programming

### Proof Strategies
1. **Via Courant-Fischer**: For eigenvalue monotonicity, use the min-max characterization. If A ≤_L B, then the Rayleigh quotient of B dominates that of A on every subspace.

2. **Via integral representation**: Operator monotone functions have an integral representation f(t) = a + bt + ∫(t/(1+st) - 1/(1+s))dμ(s). Show each integrand is operator monotone and use linearity.

### Cross-Domain Impact
- **Quantum information**: Entanglement measures, channel capacities
- **Optimization**: SDP feasibility, interior point methods
- **Statistics**: Monotonicity of Fisher information
- **Control theory**: Lyapunov stability

---

## Direction 5: Spectral Projections and the Born Rule

### Precise Theorem Statement
For a Hermitian matrix `A` with eigenvalues `{λᵢ}`, define the spectral projection onto eigenvalue `λ`:

```
P_λ = ∑_{i : eigenvalues i = λ} |eᵢ⟩⟨eᵢ|
```

Then:
1. `P_λ` is an orthogonal projection: `P_λ² = P_λ`, `P_λ* = P_λ`
2. Completeness: `∑_λ P_λ = I`
3. Orthogonality: `P_λ P_μ = 0` for `λ ≠ μ`
4. Spectral resolution: `A = ∑_λ λ P_λ`
5. Born rule: For state `ψ`, `Prob(measuring λ) = ‖P_λ ψ‖²`

### Lean Target Signature
```lean
noncomputable def spectralProjection
    {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℂ) (hA : A.IsHermitian) (lambda : ℝ) : Matrix n n ℂ :=
  ∑ i in Finset.univ.filter (fun i => hA.eigenvalues i = lambda),
    Matrix.col (hA.eigenvectorBasis i) * Matrix.row (star (hA.eigenvectorBasis i))

theorem spectral_resolution
    (A : Matrix n n ℂ) (hA : A.IsHermitian) :
    A = ∑ lambda in Finset.image hA.eigenvalues Finset.univ,
      (lambda : ℂ) • spectralProjection A hA lambda

theorem born_rule_probability_sum
    (A : Matrix n n ℂ) (hA : A.IsHermitian) (psi : EuclideanSpace ℂ n) (hpsi : ‖psi‖ = 1) :
    ∑ lambda in Finset.image hA.eigenvalues Finset.univ,
      ‖(spectralProjection A hA lambda).mulVec psi‖^2 = 1
```

### Why It Is Breakthrough-Level
Spectral projections are the mathematical formalization of quantum measurement:
- They define what it means to "measure" a quantum observable
- The Born rule follows directly from their properties
- They enable the definition of quantum channels and POVMs
- They are the bridge between spectral theory and quantum information theory

### Proof Strategies
1. **Direct construction**: Define projections from the eigenbasis. Use orthonormality to verify idempotency and orthogonality. Completeness follows from the eigenbasis being complete.

2. **Via functional calculus**: Define `P_λ = cfc(A, 1_{λ})` where `1_{λ}` is the indicator function of `{λ}`. All projection properties follow from functional calculus multiplicativity and the spectral mapping theorem.

### Cross-Domain Impact
- **Quantum computing**: Gate design, error correction, measurement
- **Quantum information**: Entanglement, teleportation, channel capacities
- **Foundations of physics**: Measurement problem, decoherence
- **Mathematical physics**: Von Neumann algebras, quantum logic

---

## Research Roadmap

### Phase 1 (Immediate): Courant-Fischer + Spectral Projections
These build directly on the current toolkit with minimal new infrastructure.

### Phase 2 (Medium-term): Weyl Perturbation + Löwner Order
Requires Courant-Fischer as foundation. Opens up numerical analysis and optimization.

### Phase 3 (Long-term): Compact Operator Spectral Theorem
Requires significant new Mathlib infrastructure (compact operators, summability in Hilbert spaces). Transforms the toolkit from finite to infinite dimensions.

### Cross-cutting Theme: Tropical Spectral Theory
The variational structure of Courant-Fischer (min-max of Rayleigh quotients) has a natural tropical analogue where:
- Addition → Maximum
- Multiplication → Addition
- Eigenvalues → Critical values of a tropical Rayleigh quotient
- Subspaces → Tropical linear spaces

This connects classical spectral theory to combinatorial optimization and polyhedral geometry. A formal development would be pioneering.
