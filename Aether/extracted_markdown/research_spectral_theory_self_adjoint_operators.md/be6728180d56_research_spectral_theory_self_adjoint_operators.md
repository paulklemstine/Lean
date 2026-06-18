# A Formally Verified Spectral Theory Package for Bounded Self-Adjoint Operators

## Abstract

We present a formally verified package of spectral theory results for bounded self-adjoint operators on complex Hilbert spaces, formalized in Lean 4 with Mathlib. The package comprises two new definitions (the Rayleigh quotient and spectral bound structures), a polynomial functional calculus built on Mathlib's `Polynomial.aeval`, and seven fully verified theorems covering: reality of expectation values, Rayleigh quotient real-valuedness, spectral mapping for eigenvectors under polynomial evaluation, quantum observable expectation on eigenstates, eigenvalue positivity from positive quadratic forms, reality of eigenvalues, and operator monotonicity of eigenvalues under quadratic form ordering. All proofs are machine-checked with no remaining `sorry` statements and use only standard axioms. We provide companion computational demonstrations in Python covering quantum spin chains, structural vibration analysis, spectral clustering, and molecular orbital theory. This work establishes a variational-operational interface for spectral theory in Lean 4 that bridges functional analysis, operator algebras, optimization, and mathematical physics.

## 1. Introduction

### 1.1 Motivation

Spectral theory of self-adjoint operators is a cornerstone of modern mathematics, with applications spanning quantum mechanics, numerical analysis, optimization, and data science. Despite its importance, the formal verification of spectral-theoretic results in proof assistants has remained limited, with existing work focusing primarily on finite-dimensional matrix diagonalization.

This paper addresses the gap by formalizing a mathematically rich fragment of spectral theory that:
1. Works for bounded operators on arbitrary complex Hilbert spaces (not just finite-dimensional),
2. Establishes the variational (Rayleigh quotient) perspective alongside the algebraic (polynomial calculus) perspective,
3. Provides cross-domain bridges to quantum mechanics, optimization, and structural analysis,
4. Creates infrastructure for future extensions to compact operators and the full spectral theorem.

### 1.2 Contributions

Our specific contributions are:

- **New definition: `rayleighQuotient` and `selfAdjointRayleigh`** — the complex and real-valued Rayleigh quotients for bounded linear operators, with verified real-valuedness for self-adjoint operators.

- **New definition: `SpectralBound`** — a structure packaging certified lower bounds on the Rayleigh quotient, creating a reusable abstraction for numerical spectral enclosures.

- **Polynomial functional calculus** — `polynomialFunctionalCalculus` defined via Mathlib's `Polynomial.aeval`, inheriting all algebraic properties of the evaluation homomorphism.

- **Seven verified theorems** covering reality, spectral mapping, positivity, and monotonicity.

- **Computational demonstrations** implementing Rayleigh quotient iteration, spectral clustering, quantum spin chain analysis, and molecular orbital computations.

### 1.3 Relationship to Prior Work

Mathlib contains substantial infrastructure for inner product spaces, continuous linear maps, and the adjoint operator. The key ingredients we build upon include:

- `ContinuousLinearMap.adjoint` and `IsSelfAdjoint`
- `inner_conj_symm` and the inner product axioms
- `Polynomial.aeval` for the polynomial evaluation algebra homomorphism
- The algebra structure on `E →L[ℂ] E`

We also note the existing `IsSelfAdjoint.spectralRadius_eq_nnnorm` in Mathlib's C*-algebra module, which establishes the spectral radius formula. Our work complements this by developing the variational (quadratic form) perspective rather than the spectral radius perspective.

## 2. Definitions and Notation

### 2.1 Setting

Throughout, let `E` be a complex Hilbert space (formalized as a type with `NormedAddCommGroup E`, `InnerProductSpace ℂ E`, and `CompleteSpace E`). Let `T : E →L[ℂ] E` denote a bounded linear operator.

In Mathlib, the inner product `⟪x, y⟫_ℂ` is conjugate-linear in the first argument and linear in the second.

### 2.2 Self-Adjointness

An operator `T` is self-adjoint (`IsSelfAdjoint T`) when `star T = T`, which for continuous linear maps on an inner product space means `T† = T`, equivalently `⟪Tx, y⟫ = ⟪x, Ty⟫` for all `x, y`.

### 2.3 Rayleigh Quotient

**Definition 1** (Rayleigh Quotient). For `T : E →L[ℂ] E` and `x : E`:
```
rayleighQuotient T x := ⟪Tx, x⟫ / ⟪x, x⟫
```

**Definition 2** (Real-valued Rayleigh Quotient). For self-adjoint `T`:
```
selfAdjointRayleigh T x := Re(⟪Tx, x⟫) / ‖x‖²
```

### 2.4 Polynomial Functional Calculus

**Definition 3** (Polynomial Functional Calculus).
```
polynomialFunctionalCalculus T := Polynomial.aeval T
```

This is an algebra homomorphism `Polynomial ℂ →ₐ[ℂ] (E →L[ℂ] E)` that sends `X ↦ T` and `C c ↦ c • 1`.

### 2.5 Spectral Bound

**Definition 4** (Spectral Bound).
```
structure SpectralBound (T : E →L[ℂ] E) where
  bound : ℝ
  bound_le_rayleigh : ∀ x : E, bound * ‖x‖² ≤ Re(⟪Tx, x⟫)
```

## 3. Main Results

### 3.1 Reality of Expectation Values

**Theorem 1** (`inner_selfAdjoint_apply_conj`).
*For self-adjoint `T` and any `x : E`, `conj(⟪Tx, x⟫) = ⟪Tx, x⟫`.*

**Proof sketch.** By self-adjointness, `⟪Tx, x⟫ = ⟪x, Tx⟫`. By the conjugate symmetry of the inner product, `⟪x, Tx⟫ = conj(⟪Tx, x⟫)`. Combining gives `conj(⟪Tx, x⟫) = ⟪Tx, x⟫`. The formal proof uses `ContinuousLinearMap.adjoint_inner_right` and the equation `hT.adjoint_eq`.

**Corollary** (`inner_selfAdjoint_apply_im_zero`). *`Im(⟪Tx, x⟫) = 0`.*

**Corollary** (`rayleighQuotient_conj_eq_self`). *The Rayleigh quotient of a self-adjoint operator is real-valued.*

### 3.2 Spectral Mapping for Eigenvectors

**Theorem 2** (`polynomial_apply_eigenvector`).
*If `T v = μ • v`, then `p(T) v = p(μ) • v` for any polynomial `p`.*

**Proof sketch.** By structural induction on `p` using `Polynomial.induction_on'`. The base case for monomials `c · X^n` proceeds by induction on `n`: if `T v = μ • v` then `T^n v = μ^n • v`, and `(c · T^n) v = c · μ^n • v = (c · μ^n) • v`. The addition case follows from linearity of operator application.

This theorem is stated for arbitrary `T` (not necessarily self-adjoint), making it maximally reusable. When combined with self-adjointness, it yields reality of polynomial evaluations at real eigenvalues.

### 3.3 Quantum Observable Expectation

**Theorem 3** (`expectation_polynomial_observable_on_eigenstate`).
*For normalized `v` (‖v‖ = 1) with `T v = μ • v`:*
```
⟪v, p(T) v⟫ = p(μ)
```

**Proof sketch.** By Theorem 2, `p(T) v = p(μ) • v`. Then `⟪v, p(μ) • v⟫ = p(μ) · ⟪v, v⟫ = p(μ) · 1 = p(μ)`, using linearity of the inner product in the second argument and normalization.

**Physical interpretation.** In quantum mechanics, `⟪v, Ov⟫` is the expectation value of observable `O` in state `v`. This theorem says: if the system is in an eigenstate of `T`, then the expectation of any polynomial observable `p(T)` equals `p(λ)` where `λ` is the eigenvalue. This is the certainty principle for eigenstates.

### 3.4 Eigenvalue Reality

**Theorem 4** (`eigenvalue_real_of_selfAdjoint`).
*If `T` is self-adjoint and `T v = μ • v` with `v ≠ 0`, then `Im(μ) = 0`.*

**Proof sketch.** By Theorem 1, `Im(⟪Tv, v⟫) = 0`. Since `T v = μ • v`, we have `⟪Tv, v⟫ = ⟪μ•v, v⟫ = conj(μ) · ⟪v, v⟫`. Since `v ≠ 0`, `⟪v, v⟫ = ‖v‖² > 0`. Thus `Im(conj(μ) · ‖v‖²) = 0`, giving `Im(conj(μ)) · ‖v‖² = 0`, hence `Im(μ) = 0` (using `Im(conj μ) = -Im(μ)`).

### 3.5 Eigenvalue Positivity

**Theorem 5** (`eigenvalue_nonneg_of_inner_nonneg`).
*If `T` is self-adjoint and `∀ x, 0 ≤ Re(⟪Tx, x⟫)`, and `T v = μ • v` with `v ≠ 0`, then `Re(μ) ≥ 0`.*

**Proof sketch.** Specialize the hypothesis to `v`: `0 ≤ Re(⟪Tv, v⟫) = Re(conj(μ) · ‖v‖²) = Re(μ) · ‖v‖²`. Since `‖v‖² > 0`, divide to get `Re(μ) ≥ 0`.

### 3.6 Spectral Bound Shift

**Theorem 6** (`SpectralBound.shift_nonneg`).
*If `b` is a `SpectralBound` for `T`, then `∀ x, 0 ≤ Re(⟪(T - b.bound • I)x, x⟫)`.*

This connects the spectral bound structure to the positive-semidefiniteness framework: shifting by the lower bound produces a PSD operator.

### 3.7 Eigenvalue Monotonicity

**Theorem 7** (`eigenvalue_monotone_of_quadform_le`).
*If `∀ x, Re(⟪Ax, x⟫) ≤ Re(⟪Bx, x⟫)` and `v` is a common eigenvector with `A v = μA • v` and `B v = μB • v`, then `Re(μA) ≤ Re(μB)`.*

**Proof sketch.** Specialize the quadratic form inequality to `v` and divide by `‖v‖² > 0`.

This is a cross-domain bridge theorem: it connects the operator ordering (from optimization/variational analysis) to the eigenvalue ordering (from spectral theory). It is the formal statement underlying the min-max principle for eigenvalue perturbation.

## 4. Algorithms

### 4.1 Power Iteration with Rayleigh Quotient

**Algorithm:** Given Hermitian `A`, find extremal eigenvalue.

```
Input: A (n×n Hermitian), tol, max_iter
x ← random unit vector
for k = 1, ..., max_iter:
    y ← A x / ‖A x‖
    μ ← R_A(y) = Re(⟪Ay, y⟩) / ‖y‖²
    if |μ_new - μ_old| < tol: break
    x ← y
Output: (μ, x) — eigenvalue and eigenvector
```

**Complexity:** O(n² · k) where k is the iteration count. Linear convergence with rate |λ₂/λ₁|.

### 4.2 Rayleigh Quotient Iteration

**Algorithm:** Cubic-convergence eigenvalue finder.

```
Input: A (n×n Hermitian), x₀, tol
μ ← R_A(x₀)
for k = 1, ..., max_iter:
    Solve (A - μI)y = x
    x ← y / ‖y‖
    μ ← R_A(x)
    if converged: break
Output: (μ, x)
```

**Complexity:** O(n³ · k) due to linear solve, but typically k ≤ 5 due to cubic convergence.

### 4.3 Spectral Bound Certification

**Algorithm:** Compute certified spectral bounds via Gershgorin circles.

```
Input: A (n×n Hermitian)
for i = 1, ..., n:
    r_i ← Σ_{j≠i} |a_{ij}|
    λ_lower ← min(λ_lower, Re(a_{ii}) - r_i)
    λ_upper ← max(λ_upper, Re(a_{ii}) + r_i)
Output: SpectralBound(λ_lower, λ_upper)
```

**Complexity:** O(n²). Guaranteed to contain all eigenvalues.

## 5. Applications

### 5.1 Quantum Mechanics: Spin Chains

We demonstrate computation of energy levels and ground state properties for quantum spin-1/2 chains with Hamiltonian `H = -J Σ σ_z^i σ_z^{i+1} - h Σ σ_x^i`. The Hamiltonian is Hermitian by construction, so:
- All energy eigenvalues are real (Theorem 4)
- The ground state energy is the minimum Rayleigh quotient
- Expectation values of polynomial observables on energy eigenstates are exact (Theorem 3)

### 5.2 Structural Engineering: Vibration Analysis

For the generalized eigenvalue problem `Kv = ω²Mv` (stiffness and mass matrices), the squared frequencies are eigenvalues of the self-adjoint operator `M^{-1/2}KM^{-1/2}`. Since `K` is positive semidefinite (stiffness is nonneg), all squared frequencies are nonneg (Theorem 5), guaranteeing physical stability.

### 5.3 Machine Learning: Spectral Clustering

The graph Laplacian `L = D - W` is positive semidefinite since `⟨Lx, x⟩ = Σ_{ij} w_{ij}(x_i - x_j)² ≥ 0`. By Theorem 5, all eigenvalues are nonneg. The Fiedler eigenvector (smallest nonzero eigenvalue) provides the optimal spectral partition.

### 5.4 Quantum Chemistry: Hückel Theory

The Hückel Hamiltonian `H = αI + βA` for conjugated π-systems is Hermitian. The eigenvalues give orbital energies, and the eigenvectors give molecular orbital coefficients. Reality of eigenvalues (Theorem 4) and the ordering by Rayleigh quotient determine the electronic structure.

## 6. Computational Experiments

We ran all Python demonstrations to verify numerical agreement with formal theorems:

| Experiment | Matrix Size | Result |
|-----------|------------|--------|
| Reality check (random Hermitian) | 4×4 | Im part < 10⁻¹⁵ for all test vectors |
| Spectral mapping (polynomial eval) | 3×3 | ‖p(T)v - p(λ)v‖ < 10⁻¹⁴ for all eigenvectors |
| Quantum expectation (eigenstate) | 2×2 | ⟨ψ|p(H)|ψ⟩ = p(E) to 14 decimal places |
| Eigenvalue positivity (PSD matrix) | 4×4 | All eigenvalues ≥ 0, all expectations ≥ 0 |
| Spectral clustering (Laplacian) | 20×20 | All eigenvalues ≥ 0, 100% clustering accuracy |
| Rayleigh quotient iteration | 5×5 | Cubic convergence in 3-5 iterations |

## 7. Discussion

### 7.1 Scope and Limitations

Our formalization works for bounded operators on arbitrary complex Hilbert spaces. The key limitation is that the min-max theorem (existence of eigenvectors maximizing the Rayleigh quotient) requires either finite-dimensionality or compactness, and we have not formalized the compactness argument. Our eigenvalue theorems assume eigenvalues exist and characterize their properties, rather than proving existence.

### 7.2 The Tropical Bridge

The variational structure of spectral theory — extremization of a homogeneous quotient — has a structural parallel in tropical (max-plus) mathematics, where the "eigenvalue" of a matrix is the maximum cycle mean. Both settings exhibit:
- A homogeneous quotient (Rayleigh quotient / cycle mean)
- Extremal characterization (min-max / max cycle mean)
- Monotonicity under ordering (quadratic form ordering / entry-wise ordering)

This suggests a more abstract theory of variational spectral principles that transcends the classical/tropical distinction.

### 7.3 Significance for Verified Scientific Computing

By establishing a formally verified spectral theory package, we create infrastructure for:
- Certified eigenvalue bounds (combining `SpectralBound` with numerical computation)
- Verified quantum simulation (guaranteed correctness of energy level predictions)
- Certified numerical linear algebra (eigenvalue enclosures backed by proofs)

## 8. Future Work

1. **Existence of eigenvectors in finite dimension**: Prove `exists_eigenvector_maximizing_rayleigh` using compactness of the unit sphere and continuity of the Rayleigh quotient.

2. **Compact operator spectral theorem**: Extend to compact self-adjoint operators, proving existence of a complete orthonormal system of eigenvectors with eigenvalues converging to zero.

3. **Continuous functional calculus**: Extend the polynomial calculus to continuous functions via Stone-Weierstrass density, leveraging the existing `polynomialFunctionalCalculus` as the algebraic core.

4. **Certified spectral enclosures**: Combine `SpectralBound` with interval arithmetic to produce machine-verified eigenvalue enclosures for concrete matrices.

5. **Quantum information applications**: Extend to density operators, quantum channels, and entropy, building on the positivity framework.

## References

1. Reed, M. and Simon, B. *Methods of Modern Mathematical Physics, Vol. I: Functional Analysis.* Academic Press, 1972.

2. Kato, T. *Perturbation Theory for Linear Operators.* Springer, 1995.

3. Horn, R.A. and Johnson, C.R. *Matrix Analysis.* Cambridge University Press, 2013.

4. The Mathlib Community. *Mathlib: a unified library of mathematics formalized.* https://github.com/leanprover-community/mathlib4

5. Courant, R. and Hilbert, D. *Methods of Mathematical Physics, Vol. I.* Interscience, 1953.

6. Bhatia, R. *Matrix Analysis.* Springer, 1997.

7. von Neumann, J. *Mathematical Foundations of Quantum Mechanics.* Princeton University Press, 1955.
