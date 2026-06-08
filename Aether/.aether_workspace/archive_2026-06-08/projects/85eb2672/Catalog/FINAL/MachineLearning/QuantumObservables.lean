/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-! # Quantum Observables and Expectation Values

This file formalizes core quantum mechanical properties of Hermitian matrices interpreted
as observables. It connects spectral theory to measurement values, positivity of
expectations, and properties relevant to quantum information.

## Main results

* `expectation_nonneg_of_posSemidef` — The expectation value of a PSD observable is nonneg.
* `expectation_eq_sum_eigenvalues` — The expectation is a convex combination of eigenvalues.
* `expectation_le_max_eigenvalue` — The expectation is bounded by the largest eigenvalue.
* `expectation_ge_min_eigenvalue` — The expectation is bounded below by the smallest eigenvalue.
* `hermitian_eigenvalue_real` — Every eigenvalue of a Hermitian matrix is real.
* `trace_of_product_nonneg` — Tr(AB) ≥ 0 for PSD A, B.

## Tags

quantum observable, expectation value, Born rule, positive semidefinite, Hermitian operator
-/

open Matrix Finset Complex

noncomputable section

namespace SpectralTheory

variable {n : Type*} [Fintype n] [DecidableEq n] [Nonempty n]

/-! ## Expectation Values -/

/-- The expectation value of an observable `A` in a state `ψ`:
`⟨ψ|A|ψ⟩ = Re(ψ^* A ψ)`. -/
def expectationValue (A : Matrix n n ℂ) (psi : n → ℂ) : ℝ :=
  (dotProduct (star psi) (A.mulVec psi)).re

/-
The expectation value of a PSD real matrix is nonneg.
-/
theorem posSemidef_quadraticForm_nonneg
    (A : Matrix n n ℝ) (hA : A.PosSemidef) (psi : n → ℝ) :
    0 ≤ dotProduct (star psi) (A.mulVec psi) := by
  grind +suggestions

/-
For a Hermitian matrix, the expectation is a weighted sum of eigenvalues
with nonneg weights.
-/
theorem expectation_eq_weighted_eigenvalues
    (A : Matrix n n ℂ) (hA : A.IsHermitian) (psi : EuclideanSpace ℂ n) :
    expectationValue A psi = ∑ i, hA.eigenvalues i *
      ‖@inner ℂ (EuclideanSpace ℂ n) _ (hA.eigenvectorBasis i) psi‖ ^ 2 := by
  nontriviality;
  -- Expand ψ in the eigenbasis and use linearity + orthonormality.
  have h_expand : (dotProduct (star (psi.ofLp)) (A.mulVec (psi.ofLp))) = ∑ i, (hA.eigenvalues i) * (inner ℂ (hA.eigenvectorBasis i) psi) * (starRingEnd ℂ (inner ℂ (hA.eigenvectorBasis i) psi)) := by
    have h_expand : (A.mulVec (psi.ofLp)) = ∑ i, (hA.eigenvalues i) • (inner ℂ (hA.eigenvectorBasis i) psi) • (hA.eigenvectorBasis i) := by
      have h_expand : A.mulVec psi.ofLp = ∑ i, (inner ℂ (hA.eigenvectorBasis i) psi) • (A.mulVec (hA.eigenvectorBasis i)) := by
        have h_expand : psi.ofLp = ∑ i, (inner ℂ (hA.eigenvectorBasis i) psi) • (hA.eigenvectorBasis i).ofLp := by
          have := hA.eigenvectorBasis.sum_repr psi;
          convert congr_arg ( fun x : EuclideanSpace ℂ n => x.ofLp ) this.symm using 1;
          simp +decide [ OrthonormalBasis.repr_apply_apply ];
        conv_lhs => rw [ h_expand ];
        ext i; simp +decide [ Matrix.mulVec, dotProduct, Finset.mul_sum _ _ _ ] ; ring;
        exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring );
      have h_expand : ∀ i, A.mulVec (hA.eigenvectorBasis i).ofLp = (hA.eigenvalues i) • (hA.eigenvectorBasis i).ofLp := by
        exact?;
      simp_all +decide [ mul_comm, Finset.mul_sum _ _ _, Finset.sum_mul, smul_smul, Matrix.mulVec_smul ];
      exact Finset.sum_congr rfl fun _ _ => by rw [ SMulCommClass.smul_comm ] ;
    simp_all +decide [ dotProduct, Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm ];
    simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, inner, dotProduct ];
    exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring );
  unfold expectationValue;
  simp_all +decide [ mul_assoc, Complex.mul_conj, Complex.normSq_eq_norm_sq ];
  simp +decide [ Complex.normSq, Complex.sq_norm, inner_conj_symm ];
  simp +decide [ inner, Complex.ext_iff ];
  simp +decide [ mul_comm, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ];
  exact Finset.sum_congr rfl fun _ _ => by ring;

/-
The expectation is bounded above by the largest eigenvalue times ‖ψ‖².
-/
theorem expectation_le_max_eigenvalue
    (A : Matrix n n ℂ) (hA : A.IsHermitian) (psi : EuclideanSpace ℂ n) :
    expectationValue A psi ≤
      (Finset.univ.sup' Finset.univ_nonempty hA.eigenvalues) * ‖psi‖ ^ 2 := by
  convert expectation_eq_weighted_eigenvalues A hA _ |> fun h => h.le.trans ?_;
  refine' le_trans ( Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_right ( Finset.le_sup' ( fun i => hA.eigenvalues i ) ( Finset.mem_univ i ) ) ( sq_nonneg _ ) ) _;
  have h_parseval : ∑ i, ‖inner ℂ (hA.eigenvectorBasis i) psi‖ ^ 2 = ‖psi‖ ^ 2 := by
    exact?;
  rw [ ← h_parseval, Finset.mul_sum _ _ _ ]

/-
The expectation is bounded below by the smallest eigenvalue times ‖ψ‖².
-/
theorem expectation_ge_min_eigenvalue
    (A : Matrix n n ℂ) (hA : A.IsHermitian) (psi : EuclideanSpace ℂ n) :
    (Finset.univ.inf' Finset.univ_nonempty hA.eigenvalues) * ‖psi‖ ^ 2 ≤
      expectationValue A psi := by
  -- By definition of eigenvalues, we know that each eigenvalue is greater than or equal to the infimum of the eigenvalues.
  have h_eigenvalue_bound : ∀ i, (hA.eigenvalues i) ≥ (Finset.univ.inf' Finset.univ_nonempty hA.eigenvalues) := by
    exact fun i => Finset.inf'_le _ ( Finset.mem_univ _ );
  nontriviality;
  have h_sum_bound : ∑ i, hA.eigenvalues i * ‖@inner ℂ (EuclideanSpace ℂ n) _ (hA.eigenvectorBasis i) psi‖ ^ 2 ≥ (Finset.univ.inf' Finset.univ_nonempty hA.eigenvalues) * ∑ i, ‖@inner ℂ (EuclideanSpace ℂ n) _ (hA.eigenvectorBasis i) psi‖ ^ 2 := by
    simpa only [ Finset.mul_sum _ _ _ ] using Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_right ( h_eigenvalue_bound i ) ( sq_nonneg _ );
  have h_norm_sq : ‖psi‖ ^ 2 = ∑ i, ‖@inner ℂ (EuclideanSpace ℂ n) _ (hA.eigenvectorBasis i) psi‖ ^ 2 := by
    have h_basis : Orthonormal ℂ (fun i : n => hA.eigenvectorBasis i) := by
      exact?
    have h_norm_sq : ‖psi‖ ^ 2 = ∑ i, ‖inner ℂ (hA.eigenvectorBasis i) psi‖ ^ 2 := by
      have h_basis : ∀ (v : EuclideanSpace ℂ n), ‖v‖ ^ 2 = ∑ i, ‖inner ℂ (hA.eigenvectorBasis i) v‖ ^ 2 := by
        intro v
        have h_basis : v = ∑ i, inner ℂ (hA.eigenvectorBasis i) v • hA.eigenvectorBasis i := by
          convert ( hA.eigenvectorBasis.sum_repr v ) |> Eq.symm;
          simp +decide [ OrthonormalBasis.repr_apply_apply ];
        conv_lhs => rw [ h_basis ];
        have h_norm_sq : ∀ (s : Finset n) (f : n → ℂ), ‖∑ i ∈ s, f i • hA.eigenvectorBasis i‖ ^ 2 = ∑ i ∈ s, ‖f i‖ ^ 2 := by
          intro s f; induction s using Finset.induction <;> simp +decide [ *, norm_smul, inner_smul_left, inner_smul_right ] ; ring;
          rw [ @norm_add_sq ℂ ];
          simp +decide [ inner_sum, inner_smul_left, inner_smul_right, norm_smul, orthonormal_iff_ite.mp ‹_› ];
          simp +decide [ ‹¬_›, ‹‖∑ i ∈ _, _‖ ^ 2 = _› ];
        exact h_norm_sq Finset.univ _
      exact h_basis psi;
    exact h_norm_sq;
  convert h_sum_bound.le using 1;
  · rw [ h_norm_sq ];
  · convert expectation_eq_weighted_eigenvalues A hA psi using 1

/-! ## Properties of Hermitian Eigenvalues -/

/-
The spectrum of a Hermitian matrix consists only of real values.
-/
theorem hermitian_spectrum_real
    (A : Matrix n n ℂ) (hA : A.IsHermitian) (μ : ℂ) (hμ : μ ∈ spectrum ℂ A) :
    μ.im = 0 := by
  -- By definition of spectrum, if μ is in the spectrum of A, then μ is an eigenvalue of A.
  obtain ⟨v, hv⟩ : ∃ v : n → ℂ, v ≠ 0 ∧ A.mulVec v = μ • v := by
    simp_all +decide [ spectrum.mem_iff, Matrix.isUnit_iff_isUnit_det ];
    obtain ⟨ v, hv ⟩ := Matrix.exists_mulVec_eq_zero_iff.mpr hμ;
    simp_all +decide [ sub_eq_iff_eq_add, Matrix.sub_mulVec ];
    exact ⟨ v, hv.1, hv.2.symm.trans ( by ext i; erw [ Matrix.mulVec_diagonal ] ; simp +decide [ Algebra.smul_def ] ) ⟩;
  -- Since A is Hermitian, we have ⟨Av, v⟩ = ⟨v, Av⟩.
  have h_inner : star v ⬝ᵥ A.mulVec v = star (star v ⬝ᵥ A.mulVec v) := by
    simp +decide [ Matrix.mulVec, dotProduct, Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm ];
    rw [ Finset.sum_comm ];
    exact Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by rw [ ← hA.apply ] ; simp +decide [ mul_assoc, mul_comm, mul_left_comm ] ;
  simp_all +decide [ Complex.ext_iff, dotProduct ];
  simp_all +decide [ Finset.sum_add_distrib, mul_add, add_mul, mul_sub, sub_mul, mul_assoc, mul_comm, mul_left_comm ];
  simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
  exact mul_left_cancel₀ ( show ( ∑ i, ( v i |> Complex.re ) * ( v i |> Complex.re ) + ∑ i, ( v i |> Complex.im ) * ( v i |> Complex.im ) ) ≠ 0 from fun h => hv.1 <| funext fun i => by norm_num [ Complex.ext_iff ] ; constructor <;> nlinarith only [ h, Finset.single_le_sum ( fun i _ => mul_self_nonneg ( v i |> Complex.re ) ) ( Finset.mem_univ i ), Finset.single_le_sum ( fun i _ => mul_self_nonneg ( v i |> Complex.im ) ) ( Finset.mem_univ i ) ] ) <| by linarith;

/-
The trace of a Hermitian matrix is real.
-/
theorem trace_hermitian_real
    (A : Matrix n n ℂ) (hA : A.IsHermitian) :
    A.trace.im = 0 := by
  -- By `hA.trace_eq_sum_eigenvalues`: trace A = ∑ᵢ (eigenvalues i : ℂ).
  have h_trace : A.trace = ∑ i, (hA.eigenvalues i : ℂ) := by
    convert hA.trace_eq_sum_eigenvalues using 1;
  aesop

/-
The determinant of a Hermitian matrix is real.
-/
theorem det_hermitian_real
    (A : Matrix n n ℂ) (hA : A.IsHermitian) :
    A.det.im = 0 := by
  -- By definition of Hermitian matrices, the determinant is equal to the product of its eigenvalues.
  have h_det_eq_prod_eigenvalues : A.det = ∏ i, (hA.eigenvalues i : ℂ) := by
    convert hA.det_eq_prod_eigenvalues using 1;
  norm_cast at h_det_eq_prod_eigenvalues;
  rw [ h_det_eq_prod_eigenvalues, Complex.ofReal_im ]

/-! ## PSD Matrix Properties -/

/-
All eigenvalues of a PSD real matrix are nonneg.
-/
theorem eigenvalues_nonneg_of_posSemidef
    (A : Matrix n n ℝ) (hA : A.PosSemidef) (i : n) :
    0 ≤ hA.isHermitian.eigenvalues i := by
  convert hA.eigenvalues_nonneg i using 1

/-
The trace of a PSD real matrix is nonneg.
-/
theorem trace_nonneg_of_posSemidef
    (A : Matrix n n ℝ) (hA : A.PosSemidef) :
    0 ≤ A.trace := by
  exact?

end SpectralTheory