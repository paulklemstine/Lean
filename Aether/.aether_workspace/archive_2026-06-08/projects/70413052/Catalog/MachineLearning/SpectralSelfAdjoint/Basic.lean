/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Spectral Theory of Self-Adjoint Operators

This file develops core spectral theory for bounded self-adjoint operators on
complex Hilbert spaces, including:

* The Rayleigh quotient and its real-valuedness for self-adjoint operators
* A polynomial functional calculus via `Polynomial.aeval`
* Spectral mapping for eigenvectors under polynomial evaluation
* Quantum-mechanical expectation value principles
* Eigenvalue positivity from positive-definite quadratic forms
-/

import Mathlib

noncomputable section

open scoped InnerProductSpace ComplexOrder

namespace SpectralSelfAdjoint

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E] [CompleteSpace E]

/-! ## Rayleigh Quotient -/

/-- The Rayleigh quotient of a bounded linear operator `T` at a vector `x`,
defined as `⟪Tx, x⟫ / ⟪x, x⟫`. For self-adjoint operators this is always real. -/
def rayleighQuotient (T : E →L[ℂ] E) (x : E) : ℂ :=
  @inner ℂ E _ (T x) x / @inner ℂ E _ x x

/-- The real-valued Rayleigh quotient for a self-adjoint operator, obtained by
taking the real part of the complex inner product quotient. For nonzero vectors
and self-adjoint operators, this equals the complex Rayleigh quotient. -/
def selfAdjointRayleigh (T : E →L[ℂ] E) (x : E) : ℝ :=
  Complex.re (@inner ℂ E _ (T x) x) / ‖x‖ ^ 2

/-! ## Reality of Expectation Values -/

/-- **Reality of self-adjoint expectation values.**
For a self-adjoint bounded operator `T`, the expectation value `⟪Tx, x⟫` is
real-valued, i.e., it equals its own complex conjugate. This is the formal
gateway from abstract operators to physical observables. -/
theorem inner_selfAdjoint_apply_conj
    (T : E →L[ℂ] E) (hT : IsSelfAdjoint T) (x : E) :
    (starRingEnd ℂ) (@inner ℂ E _ (T x) x) = @inner ℂ E _ (T x) x := by
  have h_symm : ∀ x y : E, ⟪T x, y⟫_ℂ = ⟪x, T y⟫_ℂ := by
    intro x y; rw [← ContinuousLinearMap.adjoint_inner_right]; simp +decide [hT.adjoint_eq]
  rw [inner_conj_symm, h_symm]

/-- The imaginary part of `⟪Tx, x⟫` vanishes for self-adjoint `T`. -/
theorem inner_selfAdjoint_apply_im_zero
    (T : E →L[ℂ] E) (hT : IsSelfAdjoint T) (x : E) :
    Complex.im (@inner ℂ E _ (T x) x) = 0 := by
  convert RCLike.conj_eq_iff_im.mp (inner_selfAdjoint_apply_conj T hT x)

/-- The expectation value of a self-adjoint operator can be expressed as a
real number cast to `ℂ`. -/
theorem inner_selfAdjoint_apply_ofReal
    (T : E →L[ℂ] E) (hT : IsSelfAdjoint T) (x : E) :
    @inner ℂ E _ (T x) x = (↑(Complex.re (@inner ℂ E _ (T x) x)) : ℂ) := by
  have h_im_zero := inner_selfAdjoint_apply_im_zero T hT x
  exact Complex.ext rfl (by simp [h_im_zero])

/-- The Rayleigh quotient of a self-adjoint operator is real-valued. -/
theorem rayleighQuotient_conj_eq_self
    (T : E →L[ℂ] E) (hT : IsSelfAdjoint T) (x : E) :
    (starRingEnd ℂ) (rayleighQuotient T x) = rayleighQuotient T x := by
  convert congr_arg₂ (· / ·) (inner_selfAdjoint_apply_conj T hT x) (inner_conj_symm x x) using 1
  exact map_div₀ _ _ _

/-! ## Polynomial Functional Calculus -/

/-- The polynomial functional calculus for a bounded operator `T`,
defined as `p ↦ p(T)` using `Polynomial.aeval`. This is an algebra homomorphism
from `Polynomial ℂ` to `E →L[ℂ] E`. -/
def polynomialFunctionalCalculus (T : E →L[ℂ] E) :
    Polynomial ℂ →ₐ[ℂ] (E →L[ℂ] E) :=
  Polynomial.aeval T

omit [CompleteSpace E] in
@[simp]
theorem polynomialFunctionalCalculus_X (T : E →L[ℂ] E) :
    polynomialFunctionalCalculus T Polynomial.X = T :=
  Polynomial.aeval_X T

omit [CompleteSpace E] in
@[simp]
theorem polynomialFunctionalCalculus_C (T : E →L[ℂ] E) (c : ℂ) :
    polynomialFunctionalCalculus T (Polynomial.C c) = c • 1 := by
  simp [polynomialFunctionalCalculus, Algebra.algebraMap_eq_smul_one]

/-! ## Spectral Mapping for Eigenvectors -/

/-- **Spectral mapping for eigenvectors under polynomial evaluation.**
If `T v = μ • v` (i.e., `v` is an eigenvector of `T` with eigenvalue `μ`),
then `p(T) v = p(μ) • v` for any polynomial `p`. This is the seed of the
continuous and Borel functional calculus. -/
theorem polynomial_apply_eigenvector
    (T : E →L[ℂ] E) (p : Polynomial ℂ) {v : E} {μ : ℂ}
    (hTv : T v = μ • v) :
    (polynomialFunctionalCalculus T p) v = Polynomial.eval μ p • v := by
  induction' p using Polynomial.induction_on' with p q hp hq generalizing v μ <;>
    simp_all +decide [hTv]
  · rw [hp hTv, hq hTv, add_smul]
  · rename_i k c
    induction' k with k ih <;>
      simp_all +decide [pow_succ, mul_assoc]
    simp_all +decide [pow_succ, ← mul_assoc, ← Polynomial.C_mul_X_pow_eq_monomial,
      polynomialFunctionalCalculus]
    rw [smul_smul, mul_comm]

/-! ## Quantum Observable Expectation on Eigenstates -/

/-- **Quantum expectation of polynomial observable on eigenstate.**
For a normalized eigenstate `v` of `T` with eigenvalue `μ`, the expectation
value of the polynomial observable `p(T)` equals `p(μ)`. This uses the
convention `⟪v, p(T) v⟫` (linear in second argument in Mathlib).
Measuring the observable `p(T)` on the eigenstate `v` yields `p(μ)` with certainty. -/
theorem expectation_polynomial_observable_on_eigenstate
    (T : E →L[ℂ] E) (p : Polynomial ℂ)
    {v : E} {μ : ℂ}
    (hv1 : ‖v‖ = 1) (hTv : T v = μ • v) :
    @inner ℂ E _ v ((polynomialFunctionalCalculus T p) v) = Polynomial.eval μ p := by
  convert congr_arg (fun x => ⟪v, x⟫_ℂ) (polynomial_apply_eigenvector T p hTv) using 1
  norm_num [inner_smul_right, hv1]

/-! ## Eigenvalue Positivity from Positive Quadratic Form -/

/-- **Eigenvalue positivity criterion.**
If a self-adjoint operator `T` has nonneg real part of expectation for all vectors,
then every eigenvalue has nonneg real part. Combined with reality of eigenvalues
(for self-adjoint operators), this shows eigenvalues are nonneg reals. -/
theorem eigenvalue_nonneg_of_inner_nonneg
    (T : E →L[ℂ] E) (_hT : IsSelfAdjoint T)
    (hpos : ∀ x : E, 0 ≤ Complex.re (@inner ℂ E _ (T x) x))
    {μ : ℂ} {v : E} (hv : v ≠ 0) (hTv : T v = μ • v) :
    0 ≤ μ.re := by
  have := hpos v
  simp_all +decide [inner_self_eq_norm_sq_to_K]
  norm_cast at this
  nlinarith [norm_pos_iff.mpr hv, mul_self_pos.mpr (norm_ne_zero_iff.mpr hv)]

/-- Eigenvalues of a self-adjoint operator are real. -/
theorem eigenvalue_real_of_selfAdjoint
    (T : E →L[ℂ] E) (hT : IsSelfAdjoint T)
    {μ : ℂ} {v : E} (hv : v ≠ 0) (hTv : T v = μ • v) :
    μ.im = 0 := by
  have h_real : (starRingEnd ℂ) (inner ℂ (T v) v) = inner ℂ (T v) v := by
    convert inner_selfAdjoint_apply_conj T hT v using 1
  simp_all +decide [Complex.ext_iff, mul_comm]
  norm_cast at h_real; simp_all +decide [sq]
  nlinarith [norm_pos_iff.mpr hv, mul_pos (norm_pos_iff.mpr hv) (norm_pos_iff.mpr hv)]

/-! ## Spectral Bounds -/

/-- A `SpectralBound` captures a certified lower bound on the Rayleigh quotient
of a self-adjoint operator. This creates a reusable abstraction for numerical
spectral enclosures and quantum energy bounds. -/
structure SpectralBound (T : E →L[ℂ] E) where
  /-- The lower bound value -/
  bound : ℝ
  /-- Proof that the bound holds for all vectors -/
  bound_le_rayleigh : ∀ x : E, bound * ‖x‖ ^ 2 ≤ Complex.re (@inner ℂ E _ (T x) x)

/-- A spectral lower bound implies nonnegativity of `T - bound • id` in the
quadratic form sense. -/
theorem SpectralBound.shift_nonneg
    (T : E →L[ℂ] E) (_hT : IsSelfAdjoint T) (b : SpectralBound T) :
    ∀ x : E, 0 ≤ Complex.re (@inner ℂ E _ ((T - (b.bound : ℂ) • 1) x) x) := by
  intro x
  have := b.bound_le_rayleigh x
  simp at this ⊢
  norm_cast

/-! ## Cross-Domain Bridge: Operator Monotonicity -/

/-- **Operator monotonicity of eigenvalues under quadratic form ordering.**
If two self-adjoint operators satisfy `re⟪Ax, x⟫ ≤ re⟪Bx, x⟫` for all `x`,
then for any common eigenvector, the eigenvalues respect the same ordering.
This bridges spectral theory to optimization and variational principles. -/
theorem eigenvalue_monotone_of_quadform_le
    (A B : E →L[ℂ] E) (_hA : IsSelfAdjoint A) (_hB : IsSelfAdjoint B)
    (hle : ∀ x : E, Complex.re (@inner ℂ E _ (A x) x) ≤ Complex.re (@inner ℂ E _ (B x) x))
    {μA μB : ℂ} {v : E} (hv : v ≠ 0)
    (hAv : A v = μA • v) (hBv : B v = μB • v) :
    μA.re ≤ μB.re := by
  convert div_le_div_of_nonneg_right (hle v) (sq_nonneg (‖v‖)) using 1
  · simp +decide [hAv, inner_self_eq_norm_sq_to_K]
    norm_cast; simp +decide [hv, sq]
  · simp +decide [hBv, div_eq_inv_mul, sq, mul_assoc, mul_left_comm, hv]

end SpectralSelfAdjoint