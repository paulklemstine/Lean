# Conformal Spectral Transfer: Eigenvalue Arithmetic of the Stereographic Fourier Transform

## Abstract

We introduce the **Conformal Spectral Transfer** framework, a novel mathematical structure that captures how eigenvalues of the Laplace-Beltrami operator transform under conformal maps between Riemannian manifolds. Applied to stereographic projection S^n → ℝ^n, we establish that the conformal Laplacian eigenvalues on S^n are "almost perfect squares": specifically, l(l+n-1) + n(n-2)/4 = (l + (n-1)/2)² - 1/4 for all l ≥ 0. We prove that the Yamabe correction n(n-2)/4 is uniquely determined by a spectral rigidity condition, vanishes precisely in dimension 2 (explaining conformal invariance of harmonic functions), and connects via an exact algebraic identity to the bottom of the continuous spectrum of the hyperbolic Laplacian. All results are machine-verified in Lean 4 with Mathlib, yielding 17 complete proofs with no axioms beyond the standard logical foundations.

**Keywords**: conformal geometry, spectral theory, spherical harmonics, stereographic projection, Yamabe operator, Plancherel weight, Lean 4 formalization

## 1. Introduction

### 1.1 Motivation

The interplay between the spectrum of the Laplacian on a Riemannian manifold and the underlying geometry is one of the central themes of geometric analysis. On the round sphere S^n, the eigenvalues of the Laplace-Beltrami operator are l(l+n-1), with well-known multiplicities given by binomial coefficients. On Euclidean space ℝ^n, the Fourier transform diagonalizes the Laplacian with continuous spectrum.

Stereographic projection provides a conformal diffeomorphism between S^n minus a point and ℝ^n, with conformal factor Ω(x) = 2/(1+|x|²). This conformal relationship suggests that spectral information should transfer between the two spaces, modulo correction terms arising from the curvature.

### 1.2 The Novel Structure

We define the **Conformal Spectral Transfer** as an algebraic structure consisting of:
- A dimension parameter n ≥ 1
- Source eigenvalues: λ_l^S = l(l+n-1)  (sphere Laplacian)
- Target eigenvalues: λ_l^T = (l + (n-1)/2)² - 1/4  (conformal Laplacian)
- A spectral shift: δ = n(n-2)/4  (Yamabe correction)
- The fundamental identity: λ_l^T = λ_l^S + δ  for all l ≥ 0

The key insight is that the transfer is not a scaling but an *additive shift* by a dimension-dependent constant. This constant has deep connections to the Yamabe problem, hyperbolic geometry, and spectral rigidity.

### 1.3 Summary of Results

We prove 17 theorems in Lean 4, organized into the following themes:

1. **Fundamental Identity** (Theorem 1): The almost-square formula
2. **Dimensional Special Cases** (Theorems 2, 7, 8): Yamabe vanishing, multiplicities
3. **Spectral Analysis** (Theorems 3, 4): Gap monotonicity, non-negativity
4. **Plancherel Weight** (Theorems 5-6, 9-11): Positivity, boundary values, inversion, monotonicity
5. **Radial Profiles** (Theorems 12-13): Origin behavior, non-negativity
6. **Construction** (Theorem 14): Existence of the transfer structure
7. **Cross-Domain Connections** (Theorems 15-17): Hyperbolic bridge, Weyl law, spectral rigidity

## 2. Definitions

### 2.1 Conformal Spectral Data

**Definition 1** (ConformalSpectralData). For a sphere S^n, the spectral data at degree l consists of:
- The eigenvalue: λ_l = l(l+n-1) ∈ ℤ
- The spectral shift: δ_n = n(n-2)/4 ∈ ℚ
- The transferred eigenvalue: μ_l = (l + (n-1)/2)² - 1/4 ∈ ℚ
- The multiplicity: m_l = C(n+l, l) - C(n+l-2, l-2) ∈ ℕ
- The Casimir value: c_l = l(l+n-1) ∈ ℕ

### 2.2 Plancherel Weight

**Definition 2** (PlancherelWeight). The Plancherel weight function for the stereographic Fourier transform in dimension n is:
  W_n(r²) = (2/(1+r²))^n

This arises as the Jacobian of the stereographic change of variables: the volume element transforms as dσ_{S^n} = W_n(|y|²) · d^n y.

### 2.3 Conformal Spectral Transfer

**Definition 3** (ConformalSpectralTransfer). A conformal spectral transfer of dimension n is a tuple (n, δ, λ^S, λ^T) where:
- n ≥ 1 is the dimension
- δ = n(n-2)/4 is the Yamabe shift
- λ^S_l = l(l+n-1) are the source eigenvalues
- λ^T_l = (l + (n-1)/2)² - 1/4 are the target eigenvalues
- λ^T_l = λ^S_l + δ for all l (the fundamental identity)

### 2.4 Radial Profile

**Definition 4** (RadialProfile). The radial profile of the stereographic Fourier transform of the l-th spherical harmonic is:
  R_l(r) = r^l / (1 + r²)^{l + n/2}

### 2.5 Auxiliary Functions

**Definition 5**. We define:
- sphereEigenvalue(n, l) = l(l+n-1) ∈ ℚ
- yamabeCorrection(n) = n(n-2)/4 ∈ ℚ
- conformalLaplacianEigenvalue(n, l) = l(l+n-1) + n(n-2)/4 ∈ ℚ

## 3. Main Results

### 3.1 The Fundamental Almost-Square Identity

**Theorem 1** (conformal_eigenvalue_almost_square). For all n, l ∈ ℕ:
  l(l+n-1) + n(n-2)/4 = (l + (n-1)/2)² - 1/4

*Proof sketch*: Direct algebraic expansion. Both sides equal l² + l(n-1) + (n-1)²/4 - 1/4.

**PEGB Analysis**:
- **Proof**: Complete in Lean via `ring` after unfolding definitions
- **Example**: n=3, l=2: LHS = 2·4 + 3·1/4 = 8 + 3/4 = 35/4. RHS = (2+1)² - 1/4 = 9 - 1/4 = 35/4. ✓
- **Generalization**: The identity holds over any commutative ring (proved over ℚ but algebraically universal)
- **Boundary**: At l=0, gives n(n-2)/4 = ((n-1)/2)² - 1/4, which equals (n²-2n)/4 = (n²-2n)/4. ✓. At n=1, gives l(l) - 1/4 = l² - 1/4, the Yamabe correction is -1/4 < 0, reflecting that S¹ has no "spectral gap" in the conformal Laplacian.

### 3.2 Dimension 2 Vanishing

**Theorem 2** (yamabe_correction_vanishes_dim2). yamabeCorrection(2) = 0.

This explains the exceptional role of dimension 2 in conformal geometry. In 2D, conformal = holomorphic, and harmonic functions are preserved exactly under conformal maps.

### 3.3 Spectral Gap Monotonicity

**Theorem 3** (conformal_eigenvalue_gap). For n ≥ 1:
  μ_{l+1} - μ_l = 2l + n

The spectral gaps are linearly increasing, reflecting the growing "angular momentum barrier" at higher degrees.

**PEGB Analysis**:
- **Proof**: `ring` after unfolding
- **Example**: n=2: gaps are 2, 4, 6, 8, ... (arithmetic progression with common difference 2)
- **Generalization**: The gap formula 2l + n is affine in both l and n
- **Boundary**: At l=0, the first gap is n, matching the well-known result that the first nonzero eigenvalue of S^n is n

### 3.4 Non-negativity

**Theorem 4** (conformal_eigenvalue_nonneg). For n ≥ 2 and all l ≥ 0:
  0 ≤ l(l+n-1) + n(n-2)/4

*Proof sketch*: By the almost-square formula, this equals (l + (n-1)/2)² - 1/4 ≥ (1/2)² - 1/4 = 0 since l + (n-1)/2 ≥ 1/2 when n ≥ 2.

### 3.5 Plancherel Weight Properties

**Theorem 5** (plancherel_weight_pos). W_n(r²) > 0 for r² ≥ 0, n ≥ 1.

**Theorem 6** (plancherel_weight_at_origin). W_n(0) = 2^n.

**Theorem 7** (plancherel_weight_at_unit). W_n(1) = 1. The equator maps to the unit sphere.

**Theorem 8** (plancherel_weight_inversion). W_n(1/r²) = r^{2n} · W_n(r²) for r > 0. This reflects the involutive nature of stereographic inversion.

**PEGB for Theorem 8**:
- **Proof**: `field_simp; ring` after unfolding
- **Example**: n=1, r²=4: W(1/4) = (2/(5/4))¹ = 8/5; r²·W(4) = 4·(2/5) = 8/5. ✓
- **Generalization**: This is a consequence of the general conformal covariance W(f(r²)) = |J_f|^{n/2} · W(r²) where J_f is the Jacobian of the inversion
- **Boundary**: As r² → ∞, W → 0 and r^{2n} · W → finite (the weight at the antipode)

**Theorem 9** (plancherel_weight_antitone). W_n is strictly decreasing on [0, ∞) for n ≥ 1.

### 3.6 Radial Profile Properties

**Theorem 10** (radial_profile_at_origin_zero). R_l(0) = 0 for l ≥ 1.

**Theorem 11** (radial_profile_nonneg). R_l(r) ≥ 0 for r ≥ 0.

### 3.7 Multiplicity Formulas

**Theorem 12** (multiplicity_dim2). On S², mult(l) = 2l + 1.

This is the well-known (2l+1)-dimensional irreducible representation of SO(3), corresponding to the magnetic quantum numbers m = -l, ..., +l.

**Theorem 13** (multiplicity_dim1). On S¹, mult(l) = 2 for l ≥ 1 (sin and cos).

### 3.8 Construction of the Transfer

**Theorem 14** (spectral_transfer_exists). For every n ≥ 1, there exists a ConformalSpectralTransfer with the specified properties.

*Proof sketch*: Explicit construction. The transfer_identity follows from the algebraic identity (l+(n-1)/2)² - 1/4 = l(l+n-1) + n(n-2)/4, which is proved by `ring`.

### 3.9 Hyperbolic Spectral Connection

**Theorem 15** (hyperbolic_spectral_connection). For n ≥ 2:
  n(n-2)/4 + n/2 = (n/2)²

The Yamabe correction on S^n plus n/2 gives the bottom of the continuous spectrum of the Laplacian on hyperbolic space H^{n+1}.

**PEGB Analysis**:
- **Proof**: `ring` after unfolding
- **Example**: n=3: 3·1/4 + 3/2 = 3/4 + 6/4 = 9/4 = (3/2)². ✓
- **Generalization**: This connects the three constant-curvature geometries (sphere, Euclidean, hyperbolic) through a single algebraic relation
- **Boundary**: At n=2: 0 + 1 = 1 = (1)². The hyperbolic bottom in 3D is 1.

### 3.10 Weyl Law

**Theorem 16** (weyl_law_dim2). ∑_{i=0}^L (2i+1) = (L+1)².

This Weyl-type counting formula gives the total number of spherical harmonics up to degree L on S².

### 3.11 Spectral Rigidity

**Theorem 17** (yamabe_correction_unique_square). The Yamabe correction n(n-2)/4 is the *unique* rational constant C such that there exist integers a, b with b = a + 2 and:
- 4C + 1 = a²
- 4(n + C) + 1 = b²

*Proof sketch*: From b = a + 2, we get b² - a² = (a+2)² - a² = 4a + 4 = 4n, so a = n-1. Then C = (a² - 1)/4 = ((n-1)² - 1)/4 = n(n-2)/4.

**PEGB Analysis**:
- **Proof**: Algebraic manipulation using `nlinarith` after `obtain` and `push_cast`
- **Example**: n=5: C = 5·3/4 = 15/4. Check: 4(15/4)+1 = 16 = 4², 4(5+15/4)+1 = 36 = 6². a=4, b=6, b-a=2. ✓
- **Generalization**: This rigidity result says the conformal spectral structure is not an artifact of the definition but is *forced* by arithmetic constraints
- **Boundary**: At n=2: C = 0. 4(0)+1 = 1 = 1², 4(2+0)+1 = 9 = 3². a=1, b=3, b-a=2. ✓

## 4. Algorithms

### 4.1 Conformal Eigenvalue Computation

**Algorithm 1**: Given dimension n and degree l, compute the conformal Laplacian eigenvalue.

```
Input: n ≥ 1, l ≥ 0
Output: μ_l = l(l+n-1) + n(n-2)/4
```

Time complexity: O(1). Space complexity: O(1).

### 4.2 Plancherel Weight Computation

**Algorithm 2**: Compute the Plancherel weight W_n(r²) = (2/(1+r²))^n.

For numerical stability with large n, use log-space:
```
log W_n(r²) = n · (log 2 - log(1 + r²))
```

### 4.3 Multiplicity Computation

**Algorithm 3**: Compute mult(n, l) = C(n+l, l) - C(n+l-2, l-2).

For S² (n=2), this simplifies to 2l+1. For general n, use the recursive formula for binomial coefficients.

## 5. Falsifiable Conjecture

**Conjecture (Spectral Transfer Completeness)**. The conformal spectral transfer extends to an *isometric* map T: L²(S^n) → L²(ℝ^n, W_n · dλ) defined by:

T(f)(k) = ∫_{S^n} f(x) · Ω(φ(x))^{n/2} · e^{-2πi φ(x)·k} dσ(x)

where φ is the stereographic projection and Ω is the conformal factor.

**Computational test**: For n=2, l=1, compute T(Y₁⁰) and verify it equals a Hermite-type function with radial profile r/(1+r²)² up to normalization.

**Status**: Not yet formally verified. The algebraic framework (spectral shift, Plancherel weight) is fully proved; the analytic isometry statement requires measure-theoretic machinery beyond the current formalization.

## 6. Discussion

### 6.1 Relation to Prior Work

The conformal Laplacian and Yamabe operator are classical objects in differential geometry (Yamabe 1960, Schoen 1984). The spectral theory of the sphere is textbook material (Stein & Weiss 1971). Our contribution is:

1. **The Conformal Spectral Transfer as a formal structure**, axiomatizing the eigenvalue relationship and proving its existence
2. **The spectral rigidity theorem**, showing the Yamabe correction is uniquely determined
3. **The hyperbolic connection theorem**, providing a clean algebraic link between sphere and hyperbolic spectral theory
4. **Complete machine verification** of all results

### 6.2 Connection to Catalog Results

Our `conformal_eigenvalue_almost_square` generalizes and deepens the `conformal_laplacian_identity` from the existing catalog (Geometry/StereographicNeuralField.lean), which treated the 1D case. The Plancherel weight properties extend `conformal_factor_bounded'` from Geometry/InverseStereoUniverse.lean to arbitrary dimensions with sharp equality cases.

### 6.3 Limitations

Our formalization works at the algebraic/arithmetic level — we prove identities about eigenvalues, multiplicities, and weight functions. The full analytic statement (that the stereographic Fourier transform is an isometry between appropriate L² spaces) requires measure theory and functional analysis that we leave to future work.

## 7. Future Work

See FUTURE_DIRECTIONS.md for detailed research directions. Key avenues include:
1. Extending to the Lorentzian setting (de Sitter space)
2. Proving the full isometry theorem using Mathlib's measure theory
3. Connecting to the Selberg trace formula via the spectral rigidity result
4. Computational applications to fast spherical harmonic transforms

## References

- Branson, T. (1995). Sharp inequalities, the functional determinant, and the complementary series. *Trans. AMS*.
- Schoen, R. (1984). Conformal deformation of a Riemannian metric to constant scalar curvature. *J. Diff. Geom.*
- Stein, E. & Weiss, G. (1971). *Introduction to Fourier Analysis on Euclidean Spaces*. Princeton.
- Yamabe, H. (1960). On a deformation of Riemannian structures on compact manifolds. *Osaka Math. J.*
