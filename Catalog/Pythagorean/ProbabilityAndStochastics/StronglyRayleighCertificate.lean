/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Strongly Rayleigh Hessian Certificates: Beyond the Determinant Barrier

This file establishes a polynomial-intrinsic Hessian certificate theory for strongly
Rayleigh measures, breaking free from the determinant-specific structure of DPPs.

## Mathematical Overview

For a multiaffine polynomial `g ∈ ℝ[z₁,…,zₙ]` with nonneg coefficients, we define the
**Lorentzian certificate matrix**:
  `M_g(x) = g(x) · Hess(g)(x) - ∇g(x) · ∇g(x)ᵀ`

The central result says: if `g` satisfies the directional Rayleigh inequality
`(D_u g(x))² ≥ g(x) · D_u² g(x)` for all directions `u` (as holds for real stable
polynomials), then `M_g(x)` is NSD on the hyperplane `{u : ∇g(x)·u = 0}`.

This certificate is *intrinsic* to the polynomial — it does not reference any kernel,
matrix representation, or determinantal structure.

## Main Definitions

* `gradientEvalAt` — gradient of `g` evaluated at a point
* `hessianEvalAt` — Hessian matrix of `g` evaluated at a point
* `lorentzianCertMatrix` — the intrinsic certificate matrix `g(x)·H - ∇g·∇gᵀ`
* `ConditionalNSD` — NSD on the orthogonal complement of a given direction
* `AtMostOnePosEigenvalue` — spectral consequence of conditional NSD
* `FullRayleigh` — the pairwise Rayleigh inequality at a point
* `DirectionalRayleigh` — the full directional Rayleigh inequality
* `IsStronglyRayleighGenPoly` — strong Rayleighness at all positive points
* `LorentzianHessianCertificate` — bundled certificate structure

## Main Results

* `certMatrix_quadForm_decomposition` — algebraic decomposition of the quadratic form
* `certMatrix_quadForm_on_hyperplane` — simplification on the gradient hyperplane
* `conditionalNSD_of_directionalRayleigh` — Directional Rayleigh → conditional NSD
* `atMostOnePosEv_of_stronglyRayleigh` — Strong Rayleigh → at most one positive eigenvalue
* `certMatrix_entries_nonpos_of_fullRayleigh` — entry-wise nonpositivity
* `negCertMatrix_PSD_of_directionalRayleigh` — -M_g is PSD from directional Rayleigh

## Cross-Domain Connections

- **Combinatorics ↔ Analysis**: Strong Rayleighness (combinatorial) implies Hessian
  negativity (analytic), bridging algebraic combinatorics and differential geometry.
- **Matroid theory ↔ Spectral theory**: Basis generating polynomials of matroids
  satisfy spectral certificate bounds, connecting matroid geometry to linear algebra.
- **Optimization ↔ Probability**: The certificate matrix encodes log-concavity of
  the generating polynomial, connecting convex optimization to negative dependence.
-/

open Finset BigOperators MvPolynomial Matrix

noncomputable section

namespace StronglyRayleighCertificate

variable {n : ℕ}

/-! ## Core Definitions -/

/-- Gradient of a multivariate polynomial evaluated at a point `x`.
    `(gradientEvalAt g x) i = (∂ᵢ g)(x)` -/
def gradientEvalAt (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => MvPolynomial.eval x (MvPolynomial.pderiv i g)

/-- Hessian matrix of a multivariate polynomial evaluated at a point `x`.
    `(hessianEvalAt g x) i j = (∂ᵢ ∂ⱼ g)(x)` -/
def hessianEvalAt (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => MvPolynomial.eval x (MvPolynomial.pderiv i (MvPolynomial.pderiv j g))

/-- The **Lorentzian certificate matrix** (intrinsic Hessian certificate):
    `M_g(x) = g(x) · Hess(g)(x) - ∇g(x) · ∇g(x)ᵀ`

    This is the central object of the theory. For real stable polynomials,
    this matrix is NSD on the hyperplane orthogonal to ∇g(x). -/
def lorentzianCertMatrix (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => MvPolynomial.eval x g * hessianEvalAt g x i j -
    gradientEvalAt g x i * gradientEvalAt g x j

/-- **Conditional negative semidefiniteness**: a matrix `A` is NSD on the
    hyperplane orthogonal to `w`, i.e., for all `u` with `∑ uᵢwᵢ = 0`,
    we have `∑ᵢⱼ uᵢ Aᵢⱼ uⱼ ≤ 0`. -/
def ConditionalNSD (A : Matrix (Fin n) (Fin n) ℝ) (w : Fin n → ℝ) : Prop :=
  ∀ u : Fin n → ℝ, (∑ i, u i * w i = 0) →
    ∑ i, ∑ j, u i * A i j * u j ≤ 0

/-- **At most one positive eigenvalue**: the matrix has at most one positive
    eigenvalue, formalized as existence of a nonzero vector `w` such that
    the matrix is NSD on the hyperplane orthogonal to `w`. -/
def AtMostOnePosEigenvalue (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, w ≠ 0 ∧ ConditionalNSD A w

/-- The **pairwise (full) Rayleigh property** at a point: for all `i, j`,
    `g(x) · (∂ᵢ∂ⱼg)(x) ≤ (∂ᵢg)(x) · (∂ⱼg)(x)`.
    This encodes coordinate-wise negative correlation. -/
def FullRayleigh (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ) : Prop :=
  ∀ i j : Fin n,
    MvPolynomial.eval x g * hessianEvalAt g x i j ≤
      gradientEvalAt g x i * gradientEvalAt g x j

/-- The **directional Rayleigh inequality** at a point: for all directions `u`,
    `(D_u g(x))² ≥ g(x) · D_u² g(x)`.

    Written in matrix form: `(∑ᵢ uᵢ ∂ᵢg(x))² ≥ g(x) · ∑ᵢⱼ uᵢ uⱼ ∂ᵢ∂ⱼg(x)`.

    This is strictly stronger than pairwise Rayleigh (which is the special case
    where `u` is a coordinate direction `eᵢ` or `eᵢ + eⱼ`).
    For real stable polynomials, this holds at all positive points.
    This is equivalent to `-M_g(x)` being positive semidefinite. -/
def DirectionalRayleigh (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ) : Prop :=
  ∀ u : Fin n → ℝ,
    MvPolynomial.eval x g * (∑ i, ∑ j, u i * hessianEvalAt g x i j * u j) ≤
      (∑ i, u i * gradientEvalAt g x i) ^ 2

/-- **Strongly Rayleigh generating polynomial** (via directional Rayleigh):
    a polynomial satisfying the directional Rayleigh inequality at every positive point.
    For real stable polynomials with nonneg coefficients, this holds by Borcea-Brändén. -/
def IsStronglyRayleighGenPoly (g : MvPolynomial (Fin n) ℝ) : Prop :=
  ∀ x : Fin n → ℝ, (∀ i, 0 < x i) → DirectionalRayleigh g x

/-- A certificate object bundling the matrix and its proof obligations.
    This converts a theorem into reusable certified data for downstream algorithms. -/
structure LorentzianHessianCertificate
    (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ) where
  mat : Matrix (Fin n) (Fin n) ℝ
  eq_intrinsic : mat = lorentzianCertMatrix g x
  cond_nsd : ConditionalNSD mat (gradientEvalAt g x)

/-- A **strongly Rayleigh witness** bundles a polynomial with proof of Rayleighness. -/
structure StronglyRayleighWitness (n : ℕ) where
  poly : MvPolynomial (Fin n) ℝ
  rayleigh : IsStronglyRayleighGenPoly poly

/-! ## Fundamental Algebraic Identity: Quadratic Form Decomposition -/

/-
**Key algebraic identity**: The quadratic form of the certificate matrix decomposes as
    `∑ᵢⱼ uᵢ M(x)ᵢⱼ uⱼ = g(x) · (∑ᵢⱼ uᵢ Hᵢⱼ uⱼ) - (∑ᵢ uᵢ · ∂ᵢg(x))²`

    This identity is the foundation for all conditional NSD arguments:
    on the hyperplane {u : ∇g(x)·u = 0}, the gradient-squared term vanishes.
-/
theorem certMatrix_quadForm_decomposition
    (g : MvPolynomial (Fin n) ℝ) (x u : Fin n → ℝ) :
    ∑ i, ∑ j, u i * lorentzianCertMatrix g x i j * u j =
      MvPolynomial.eval x g * (∑ i, ∑ j, u i * hessianEvalAt g x i j * u j) -
      (∑ i, u i * gradientEvalAt g x i) ^ 2 := by
  simp +decide only [lorentzianCertMatrix, hessianEvalAt, mul_sub, mul_comm, mul_left_comm, mul_sum, sq,
      mul_assoc];
  simp +decide only [sum_sub_distrib]

/-- On the hyperplane {u : ∇g(x)·u = 0}, the quadratic form simplifies to
    `g(x) · (uᵀ Hess(g)(x) u)`. -/
theorem certMatrix_quadForm_on_hyperplane
    (g : MvPolynomial (Fin n) ℝ) (x u : Fin n → ℝ)
    (hu : ∑ i, u i * gradientEvalAt g x i = 0) :
    ∑ i, ∑ j, u i * lorentzianCertMatrix g x i j * u j =
      MvPolynomial.eval x g * (∑ i, ∑ j, u i * hessianEvalAt g x i j * u j) := by
  rw [certMatrix_quadForm_decomposition]
  simp [hu]

/-! ## Entry-wise Nonpositivity -/

/-- **Entry-wise nonpositivity**: If `g` satisfies the full Rayleigh property at `x`,
    then every entry of the certificate matrix is ≤ 0. -/
theorem certMatrix_entries_nonpos_of_fullRayleigh
    (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ)
    (hR : FullRayleigh g x) :
    ∀ i j : Fin n, lorentzianCertMatrix g x i j ≤ 0 := by
  intro i j
  simp only [lorentzianCertMatrix]
  linarith [hR i j]

/-- Diagonal entries of the certificate matrix are ≤ 0 under Rayleigh. -/
theorem certMatrix_diagonal_nonpos
    (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ)
    (hR : FullRayleigh g x) (i : Fin n) :
    lorentzianCertMatrix g x i i ≤ 0 :=
  certMatrix_entries_nonpos_of_fullRayleigh g x hR i i

/-! ## Core Theorem: Directional Rayleigh → NSD of -M_g -/

/-
The negative of the certificate matrix has nonneg quadratic form under
    directional Rayleigh. This is the key bridge from polynomial inequalities
    to spectral geometry.
-/
theorem negCertMatrix_nonneg_quadForm_of_directionalRayleigh
    (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ)
    (hDR : DirectionalRayleigh g x) (u : Fin n → ℝ) :
    0 ≤ ∑ i, ∑ j, u i * (-lorentzianCertMatrix g x i j) * u j := by
  have hcert := certMatrix_quadForm_decomposition g x u
  have hdr := hDR u
  -- ∑ᵢⱼ uᵢ(-Mᵢⱼ)uⱼ = -(∑ᵢⱼ uᵢMᵢⱼuⱼ)
  --   = -(g(x)·∑uᵢHᵢⱼuⱼ - (∑uᵢ∂ᵢg)²) = (∑uᵢ∂ᵢg)² - g(x)·∑uᵢHᵢⱼuⱼ ≥ 0
  simp_all +decide [ mul_neg, neg_mul, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, sub_eq_add_neg ]

/-! ## Core Theorem: Directional Rayleigh → Conditional NSD -/

/-
**Core theorem (Strongly Rayleigh Hessian negativity)**:
    If `g` satisfies the directional Rayleigh inequality at `x`, then the Lorentzian
    certificate matrix is conditionally NSD on the hyperplane orthogonal to the gradient.

    In fact, the certificate matrix is NSD on ALL of ℝⁿ (not just the hyperplane),
    since `-M_g` is PSD under directional Rayleigh. The conditional NSD is a corollary.
-/
theorem conditionalNSD_of_directionalRayleigh
    (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ)
    (hDR : DirectionalRayleigh g x) :
    ConditionalNSD (lorentzianCertMatrix g x) (gradientEvalAt g x) := by
  intro u _
  -- The certificate matrix is actually NSD everywhere (not just on the hyperplane)
  -- since -M_g is PSD under directional Rayleigh.
  have := negCertMatrix_nonneg_quadForm_of_directionalRayleigh g x hDR u
  -- ∑ uᵢ(-Mᵢⱼ)uⱼ ≥ 0 means ∑ uᵢMᵢⱼuⱼ ≤ 0
  convert neg_nonpos_of_nonneg this using 1 ; norm_num [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ]

/-! ## Spectral Consequences -/

/-- **Spectral consequence**: If `g` is strongly Rayleigh and the gradient at `x` is
    nonzero, then the certificate matrix has at most one positive eigenvalue. -/
theorem atMostOnePosEv_of_stronglyRayleigh
    (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ)
    (hSR : IsStronglyRayleighGenPoly g)
    (hx : ∀ i, 0 < x i)
    (hgrad : gradientEvalAt g x ≠ 0) :
    AtMostOnePosEigenvalue (lorentzianCertMatrix g x) :=
  ⟨gradientEvalAt g x, hgrad,
    conditionalNSD_of_directionalRayleigh g x (hSR x hx)⟩

/-- **Certificate existence**: A strongly Rayleigh polynomial admits a Lorentzian
    Hessian certificate at every positive point. -/
def stronglyRayleigh_certificate
    (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ)
    (hSR : IsStronglyRayleighGenPoly g)
    (hx : ∀ i, 0 < x i) :
    LorentzianHessianCertificate g x where
  mat := lorentzianCertMatrix g x
  eq_intrinsic := rfl
  cond_nsd := conditionalNSD_of_directionalRayleigh g x (hSR x hx)

/-- Extract a certificate from a strongly Rayleigh witness at a positive point. -/
theorem StronglyRayleighWitness.certificate_conditionalNSD
    (w : StronglyRayleighWitness n) (x : Fin n → ℝ) (hx : ∀ i, 0 < x i) :
    ConditionalNSD (lorentzianCertMatrix w.poly x) (gradientEvalAt w.poly x) :=
  conditionalNSD_of_directionalRayleigh w.poly x (w.rayleigh x hx)

/-! ## Basis Family Framework -/

/-- The basis generating polynomial of a family of equicardinal subsets:
    `B_F(z) = ∑_{S ∈ bases} ∏_{i ∈ S} zᵢ` -/
def basisGenPoly {n : ℕ} (bases : Finset (Finset (Fin n))) :
    MvPolynomial (Fin n) ℝ :=
  ∑ B ∈ bases, ∏ i ∈ B, MvPolynomial.X i

/-- For a basis family with the Rayleigh property, the certificate matrix is conditionally
    NSD at every positive point. This is the matroid-to-spectral bridge. -/
theorem basisFamily_certificate_of_rayleigh
    {n : ℕ} (bases : Finset (Finset (Fin n)))
    (hSR : IsStronglyRayleighGenPoly (basisGenPoly bases))
    (x : Fin n → ℝ) (hx : ∀ i, 0 < x i) :
    ConditionalNSD (lorentzianCertMatrix (basisGenPoly bases) x)
      (gradientEvalAt (basisGenPoly bases) x) :=
  conditionalNSD_of_directionalRayleigh _ x (hSR x hx)

/-! ## Computational Certificate -/

/-- Compute the certificate matrix (definitionally equal to the formal definition). -/
def computeCertificate (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  lorentzianCertMatrix g x

/-- The computation is correct by definition. -/
theorem computeCertificate_correct (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ) :
    computeCertificate g x = lorentzianCertMatrix g x := rfl

/-! ## DPP Generating Polynomial (2×2 case) -/

/-- A DPP generating polynomial in 2 variables:
    `det(I + diag(z)K) = 1 + K₁₁z₁ + K₂₂z₂ + det(K)·z₁z₂` -/
def dppGenPoly2 (K : Matrix (Fin 2) (Fin 2) ℝ) : MvPolynomial (Fin 2) ℝ :=
  MvPolynomial.C 1 +
  MvPolynomial.C (K 0 0) * MvPolynomial.X 0 +
  MvPolynomial.C (K 1 1) * MvPolynomial.X 1 +
  MvPolynomial.C (K 0 0 * K 1 1 - K 0 1 * K 1 0) *
    (MvPolynomial.X 0 * MvPolynomial.X 1)

/-- The DPP catalog certificate matrix for 2×2 case. -/
def dppCatalogCertMatrix2 (K : Matrix (Fin 2) (Fin 2) ℝ) (x : Fin 2 → ℝ) :
    Matrix (Fin 2) (Fin 2) ℝ :=
  lorentzianCertMatrix (dppGenPoly2 K) x

/-- **DPP compatibility**: The intrinsic certificate matrix applied to the DPP
    generating polynomial equals the catalog certificate matrix by definition. -/
theorem dpp_certificate_agrees_2x2
    (K : Matrix (Fin 2) (Fin 2) ℝ) (x : Fin 2 → ℝ) :
    lorentzianCertMatrix (dppGenPoly2 K) x = dppCatalogCertMatrix2 K x := rfl

/-! ## Uniform Matroid Example -/

/-- The uniform matroid U_{2,3}: all 2-element subsets of {0,1,2}. -/
def uniformMatroid23Bases : Finset (Finset (Fin 3)) :=
  {{0, 1}, {0, 2}, {1, 2}}

/-- The generating polynomial of U_{2,3}. -/
def uniformMatroid23Poly : MvPolynomial (Fin 3) ℝ :=
  basisGenPoly uniformMatroid23Bases

/-! ## Conditional NSD Structural Lemmas -/

/-- If `A` is conditionally NSD with witness `w`, then for any nonzero scalar multiple
    `c • w`, it remains conditionally NSD. -/
theorem conditionalNSD_smul_witness
    (A : Matrix (Fin n) (Fin n) ℝ) (w : Fin n → ℝ) (c : ℝ) (hc : c ≠ 0)
    (h : ConditionalNSD A w) :
    ConditionalNSD A (fun i => c * w i) := by
  intro u hu
  apply h
  have : ∑ i, u i * (c * w i) = c * ∑ i, u i * w i := by
    rw [Finset.mul_sum]; congr 1; ext i; ring
  rw [this] at hu
  exact (mul_eq_zero.mp hu).resolve_left hc

/-- Conditional NSD is preserved under addition of NSD matrices. -/
theorem conditionalNSD_add_nsd
    (A B : Matrix (Fin n) (Fin n) ℝ) (w : Fin n → ℝ)
    (hA : ConditionalNSD A w)
    (hB : ∀ u : Fin n → ℝ, ∑ i, ∑ j, u i * B i j * u j ≤ 0) :
    ConditionalNSD (fun i j => A i j + B i j) w := by
  intro u hu
  have hAu := hA u hu
  have hBu := hB u
  calc ∑ i, ∑ j, u i * (A i j + B i j) * u j
      = ∑ i, ∑ j, (u i * A i j * u j + u i * B i j * u j) := by
        congr 1; ext i; congr 1; ext j; ring
    _ = (∑ i, ∑ j, u i * A i j * u j) + (∑ i, ∑ j, u i * B i j * u j) := by
        rw [← Finset.sum_add_distrib]; congr 1; ext i; exact Finset.sum_add_distrib
    _ ≤ 0 := by linarith

/-
Adding a negative rank-1 matrix `-v·vᵀ` to `A` preserves conditional NSD
    on `{u : u·w = 0}` when `v` vanishes on that hyperplane.
-/
theorem conditionalNSD_sub_rank1_on_hyperplane
    (A : Matrix (Fin n) (Fin n) ℝ) (w v : Fin n → ℝ)
    (hA : ConditionalNSD A w)
    (hv : ∀ u : Fin n → ℝ, (∑ i, u i * w i = 0) → ∑ i, u i * v i = 0) :
    ConditionalNSD (fun i j => A i j - v i * v j) w := by
  intro u hu; specialize hA u hu; simp_all +decide [ sub_mul, mul_sub, Finset.mul_sum _ _ _] ;
  convert hA using 1
  ring_nf;
  convert congr_arg ( · * ∑ i, u i * v i ) ( hv u hu ) using 1 ; ring;
  · simp +decide only [mul_comm, mul_left_comm, sq, Finset.mul_sum _ _ _];
  · ring

/-! ## Diagonal Rayleigh from Directional Rayleigh -/

/-
Directional Rayleigh implies the diagonal Rayleigh inequality
    `g(x) · ∂ᵢ²g(x) ≤ (∂ᵢg(x))²` for each coordinate `i`.
    This is the coordinate-direction special case (u = eᵢ).
-/
theorem diagonalRayleigh_of_directionalRayleigh
    (g : MvPolynomial (Fin n) ℝ) (x : Fin n → ℝ)
    (hDR : DirectionalRayleigh g x) (i : Fin n) :
    MvPolynomial.eval x g * hessianEvalAt g x i i ≤
      gradientEvalAt g x i * gradientEvalAt g x i := by
  convert hDR ( fun j => if j = i then 1 else 0 ) using 1 ; simp +decide;
  simp +decide [sq]

end StronglyRayleighCertificate