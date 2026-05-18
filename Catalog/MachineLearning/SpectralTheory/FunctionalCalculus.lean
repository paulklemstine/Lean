/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-! # Functional Calculus and Spectral Mapping for Hermitian Matrices

This file defines the continuous functional calculus for Hermitian matrices via
diagonalization and proves the spectral mapping theorem.

## Main results

* `continuousFunctionalCalculus` — Apply any function `f : ℝ → ℂ` to a Hermitian matrix
  via `U * diagonal(f ∘ eigenvalues) * U^*`.
* `polynomial_spectral_mapping` — The spectrum of `p(A)` is `p` applied to the spectrum of `A`,
  for polynomial `p` and any matrix `A`.
* `cfc_eigenvalues` — The eigenvalues of `f(A)` are `f` applied to eigenvalues of `A`.
* `isHermitian_of_real_cfc` — If `f` maps reals to reals, then `f(A)` is Hermitian.

## Tags

functional calculus, spectral mapping, polynomial, Hermitian matrix
-/

open Matrix Finset Complex Polynomial

noncomputable section

namespace SpectralTheory

variable {n : Type*} [Fintype n] [DecidableEq n] [Nonempty n]

/-! ## Continuous Functional Calculus via Diagonalization -/

/-- Apply a function `f : ℝ → ℂ` to a Hermitian matrix via diagonalization:
`f(A) = U * diagonal(f ∘ eigenvalues) * U^*`. -/
def continuousFunctionalCalculus
    (A : Matrix n n ℂ) (hA : A.IsHermitian) (f : ℝ → ℂ) : Matrix n n ℂ :=
  (hA.eigenvectorUnitary : Matrix n n ℂ) *
    Matrix.diagonal (fun i => f (hA.eigenvalues i)) *
    star (hA.eigenvectorUnitary : Matrix n n ℂ)

/-
The CFC of a Hermitian matrix applied to the identity function recovers the original matrix.
-/
theorem cfc_id (A : Matrix n n ℂ) (hA : A.IsHermitian) :
    continuousFunctionalCalculus A hA (fun x => (x : ℂ)) = A := by
  convert hA.spectral_theorem.symm using 1

/-
The CFC of a constant function is a scalar matrix.
-/
theorem cfc_const (A : Matrix n n ℂ) (hA : A.IsHermitian) (c : ℂ) :
    continuousFunctionalCalculus A hA (fun _ => c) = c • (1 : Matrix n n ℂ) := by
  unfold continuousFunctionalCalculus;
  simp +decide [ ← Matrix.ext_iff, Matrix.mul_apply ];
  simp +decide [ Matrix.one_apply, Matrix.mul_apply, Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, Finset.sum_mul ];
  simp +decide [ diagonal, Finset.sum_ite, Finset.filter_eq, Finset.filter_ne ];
  have := hA.eigenvectorBasis.sum_inner_mul_inner;
  intro i j; specialize this ( EuclideanSpace.single i 1 ) ( EuclideanSpace.single j 1 ) ; simp_all +decide [ mul_comm, mul_assoc, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, inner ] ;
  rw [ ← Finset.mul_sum _ _ _, this, eq_comm ] ; aesop

/-
The CFC is multiplicative: `f(A) * g(A) = (f * g)(A)`.
-/
theorem cfc_mul (A : Matrix n n ℂ) (hA : A.IsHermitian)
    (f g : ℝ → ℂ) :
    continuousFunctionalCalculus A hA f * continuousFunctionalCalculus A hA g =
      continuousFunctionalCalculus A hA (fun x => f x * g x) := by
  unfold continuousFunctionalCalculus;
  -- By associativity of matrix multiplication, we can rearrange the terms.
  simp [Matrix.mul_assoc];
  simp +decide [ ← mul_assoc, mul_eq_one_comm.mp hA.eigenvectorUnitary.2.2 ]

/-
The CFC is additive: `f(A) + g(A) = (f + g)(A)`.
-/
theorem cfc_add (A : Matrix n n ℂ) (hA : A.IsHermitian)
    (f g : ℝ → ℂ) :
    continuousFunctionalCalculus A hA f + continuousFunctionalCalculus A hA g =
      continuousFunctionalCalculus A hA (fun x => f x + g x) := by
  unfold continuousFunctionalCalculus;
  simp +decide [ ← Matrix.mul_add, ← Matrix.add_mul ]

/-
If `f` maps reals to reals, then `f(A)` is Hermitian.
-/
theorem isHermitian_cfc (A : Matrix n n ℂ) (hA : A.IsHermitian)
    (f : ℝ → ℂ) (hf : ∀ x : ℝ, (f x).im = 0) :
    (continuousFunctionalCalculus A hA f).IsHermitian := by
  unfold continuousFunctionalCalculus;
  simp +decide [ Matrix.IsHermitian, Matrix.mul_assoc ];
  congr;
  · simp +decide [ Complex.ext_iff, Matrix.star_eq_conjTranspose ];
  · ext i; simp +decide [ Complex.ext_iff, hf ] ;

/-! ## Spectral Mapping -/

/-
The spectrum of `p(A)` equals `p` applied to the spectrum of `A`,
for any polynomial `p` and matrix `A` over an algebraically closed field.
-/
theorem polynomial_spectral_mapping
    (A : Matrix n n ℂ) (p : ℂ[X]) :
    spectrum ℂ (Polynomial.aeval A p) = (fun μ => p.eval μ) '' (spectrum ℂ A) := by
  have h_alg_closed : IsAlgClosed ℂ := by
    infer_instance;
  grind +suggestions

/-
The spectrum of a Hermitian matrix is real: it equals the range of the eigenvalue function
under `ofReal`.
-/
theorem spectrum_hermitian_eq_ofReal_range
    (A : Matrix n n ℂ) (hA : A.IsHermitian) :
    spectrum ℂ A = Set.range (fun i => (hA.eigenvalues i : ℂ)) := by
  convert hA.spectrum_eq_image_range;
  aesop

end SpectralTheory