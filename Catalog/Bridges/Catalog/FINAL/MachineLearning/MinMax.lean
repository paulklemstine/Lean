/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-! # Rayleigh Quotient and Min-Max Characterization of Eigenvalues

This file develops the Rayleigh quotient theory for Hermitian matrices and proves
variational characterizations of eigenvalues.

## Main results

* `hermitianForm` — The quadratic form `Re(x^* A x)` for a Hermitian matrix.
* `hermitianForm_im_eq_zero` — The quadratic form of a Hermitian matrix is real.
* `hermitianForm_eq_sum_eigenvalues_coeffs` — Equals a weighted sum of eigenvalues.
* `hermitianForm_le_max_eigenvalue_mul_norm_sq` — Upper bound by max eigenvalue.
* `hermitianForm_ge_min_eigenvalue_mul_norm_sq` — Lower bound by min eigenvalue.
* `rayleighQuotient_eigenvector` — The Rayleigh quotient of an eigenvector equals its eigenvalue.
* `max_rayleighQuotient_eq_max_eigenvalue` — The max Rayleigh quotient equals the max eigenvalue.

## Tags

Rayleigh quotient, min-max theorem, Courant-Fischer, eigenvalue bounds
-/

open Matrix Finset Complex

noncomputable section

namespace SpectralTheory

variable {n : Type*} [Fintype n] [DecidableEq n] [Nonempty n]

/-! ## Quadratic Form and Rayleigh Quotient -/

/-- The Hermitian quadratic form `Re(x^* A x)`. -/
def hermitianForm (A : Matrix n n ℂ) (x : n → ℂ) : ℝ :=
  (dotProduct (star x) (A.mulVec x)).re

/-- The Rayleigh quotient using the Euclidean (L2) norm via `dotProduct (star x) x`. -/
def rayleighQuotient (A : Matrix n n ℂ) (x : n → ℂ) : ℝ :=
  hermitianForm A x / (dotProduct (star x) x).re

/-
The quadratic form of a Hermitian matrix has zero imaginary part.
-/
theorem hermitianForm_im_eq_zero
    (A : Matrix n n ℂ) (hA : A.IsHermitian) (x : n → ℂ) :
    (dotProduct (star x) (A.mulVec x)).im = 0 := by
  -- Since $A$ is Hermitian, we have $\langle Ax, x \rangle = \langle x, Ax \rangle$.
  have h_herm : (star x) ⬝ᵥ A.mulVec x = star ((star x) ⬝ᵥ A.mulVec x) := by
    simp +decide [ dotProduct, Matrix.mulVec, Finset.mul_sum ];
    rw [ Finset.sum_comm ];
    exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by rw [ ← hA.apply ] ; simp +decide [ mul_assoc, mul_comm, mul_left_comm ] ;
  exact?

/-
The Rayleigh quotient of an eigenvector equals its eigenvalue.
-/
theorem rayleighQuotient_eigenvector
    (A : Matrix n n ℂ) (hA : A.IsHermitian)
    (v : n → ℂ) (μ : ℝ) (hv : v ≠ 0)
    (hev : A.mulVec v = (μ : ℂ) • v) :
    rayleighQuotient A v = μ := by
  refine' div_eq_iff _ |>.2 _;
  · simp_all +decide [ funext_iff, dotProduct ];
    exact fun h => hv.elim fun x hx => hx <| by norm_num [ Complex.ext_iff ] ; constructor <;> nlinarith [ Finset.single_le_sum ( fun a _ => add_nonneg ( mul_self_nonneg ( v a |> Complex.re ) ) ( mul_self_nonneg ( v a |> Complex.im ) ) ) ( Finset.mem_univ x ) ] ;
  · convert congr_arg Complex.re ( congrArg ( fun x => dotProduct ( star v ) x ) hev ) using 1 ; simp +decide [ hermitianForm ]

/-
The quadratic form of a PSD real matrix is nonneg.
-/
theorem quadraticForm_nonneg_of_posSemidef
    (A : Matrix n n ℝ) (hA : A.PosSemidef) (x : n → ℝ) :
    0 ≤ dotProduct (star x) (A.mulVec x) := by
  exact?

/-! ## Eigenvalue Bounds via Rayleigh Quotient -/

/-
The quadratic form in the eigenbasis: `x^* A x = ∑ᵢ λᵢ |⟨eᵢ, x⟩|²`.
-/
theorem hermitianForm_eq_sum_eigenvalues_coeffs
    (A : Matrix n n ℂ) (hA : A.IsHermitian) (x : EuclideanSpace ℂ n) :
    hermitianForm A x = ∑ i, hA.eigenvalues i *
      ‖@inner ℂ (EuclideanSpace ℂ n) _ (hA.eigenvectorBasis i) x‖ ^ 2 := by
  -- By definition of $A$ being Hermitian, we know that its eigenvectors form an orthonormal basis.
  have h_orthonormal_basis : ∀ x : EuclideanSpace ℂ n, x = ∑ i, inner ℂ (hA.eigenvectorBasis i) x • hA.eigenvectorBasis i := by
    exact?;
  -- By definition of $A$ being Hermitian, we know that its eigenvectors form an orthonormal basis, so we can expand $A x$ in this basis.
  have h_expand_Ax : A.mulVec (x.ofLp) = ∑ i, (hA.eigenvalues i) • (inner ℂ (hA.eigenvectorBasis i) x) • (hA.eigenvectorBasis i).ofLp := by
    convert congr_arg ( fun y => A.mulVec y ) ( show x.ofLp = ∑ i, inner ℂ ( hA.eigenvectorBasis i ) x • ( hA.eigenvectorBasis i ).ofLp from ?_ ) using 1;
    · have h_expand_Ax : ∀ i, A.mulVec (hA.eigenvectorBasis i).ofLp = (hA.eigenvalues i) • (hA.eigenvectorBasis i).ofLp := by
        grind +suggestions;
      simp +decide [ funext_iff, Matrix.mulVec, dotProduct, Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, Finset.sum_mul ];
      intro i; rw [ Finset.sum_comm ] ; congr; ext j; simp +decide [ ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, ← Matrix.mulVec_mulVec, h_expand_Ax ] ;
      have := congr_fun ( h_expand_Ax j ) i; simp +decide [ Matrix.mulVec, dotProduct, Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm ] at this ⊢;
      simp +decide [ ← mul_assoc, ← Finset.sum_mul, this ];
    · convert congr_arg ( fun y => y.ofLp ) ( h_orthonormal_basis x ) using 1;
      induction' ( Finset.univ : Finset n ) using Finset.induction <;> simp +decide [ Finset.sum_insert, Finset.sum_singleton ] at *;
  unfold hermitianForm;
  simp +decide [ h_expand_Ax, dotProduct, Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, mul_comm ];
  rw [ Finset.sum_comm ];
  refine' Finset.sum_congr rfl fun i _ => _;
  simp +decide [ ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, Complex.normSq, Complex.sq_norm ];
  simp +decide [ inner, Finset.sum_add_distrib, mul_add, add_mul, mul_assoc, mul_comm, mul_left_comm ];
  simp +decide [ ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, ← Finset.sum_comm ] ; ring_nf ; norm_num

/-
The quadratic form is bounded above by the max eigenvalue times the L2 norm squared.
-/
theorem hermitianForm_le_max_eigenvalue_mul_norm_sq
    (A : Matrix n n ℂ) (hA : A.IsHermitian) (x : EuclideanSpace ℂ n) :
    hermitianForm A x ≤
      (Finset.univ.sup' Finset.univ_nonempty hA.eigenvalues) * ‖x‖ ^ 2 := by
  -- Apply the bound for the rayleigh quotient to each term in the sum.
  have h_bound : hermitianForm A x.ofLp ≤ ∑ i, (Finset.univ.sup' (Finset.univ_nonempty) hA.eigenvalues) * ‖@inner ℂ (EuclideanSpace ℂ n) _ (hA.eigenvectorBasis i) x‖ ^ 2 := by
    rw [ hermitianForm_eq_sum_eigenvalues_coeffs A hA ];
    exact Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_right ( Finset.le_sup' ( fun i => hA.eigenvalues i ) ( Finset.mem_univ i ) ) ( sq_nonneg _ );
  -- Using Parseval's identity for orthonormal bases, we have:
  have h_parseval : ∑ i, ‖@inner ℂ (EuclideanSpace ℂ n) _ (hA.eigenvectorBasis i) x‖ ^ 2 = ‖x‖ ^ 2 := by
    exact?
  simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ]

/-
The quadratic form is bounded below by the min eigenvalue times the L2 norm squared.
-/
theorem hermitianForm_ge_min_eigenvalue_mul_norm_sq
    (A : Matrix n n ℂ) (hA : A.IsHermitian) (x : EuclideanSpace ℂ n) :
    (Finset.univ.inf' Finset.univ_nonempty hA.eigenvalues) * ‖x‖ ^ 2 ≤
      hermitianForm A x := by
  have := @hermitianForm_eq_sum_eigenvalues_coeffs n;
  rw [ this A hA x, EuclideanSpace.norm_eq ];
  -- By Parseval's identity, we know that $\sum_{i} |\langle e_i, x \rangle|^2 = \|x\|^2$.
  have h_parseval : ∑ i, ‖inner ℂ (hA.eigenvectorBasis i) x‖ ^ 2 = ∑ i, ‖x i‖ ^ 2 := by
    have := hA.eigenvectorBasis.sum_inner_mul_inner x x;
    convert congr_arg Complex.re this using 1 <;> simp +decide [ Complex.mul_conj, Complex.normSq_eq_norm_sq, inner_self_eq_norm_sq_to_K ];
    · simp +decide [ ← Finset.sum_sub_distrib, Complex.normSq, Complex.sq_norm ];
      simp +decide [ inner, Complex.ext_iff ];
      simp +decide [ mul_comm, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, sub_eq_add_neg ];
      rw [ ← Finset.sum_neg_distrib ] ; congr ; ext ; ring;
    · norm_cast ; simp +decide [ EuclideanSpace.norm_eq ];
      rw [ Real.sq_sqrt ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ];
  rw [ Real.sq_sqrt ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ), ← h_parseval, Finset.mul_sum _ _ _ ];
  exact Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_right ( Finset.inf'_le _ ( Finset.mem_univ i ) ) ( sq_nonneg _ )

/-
The max Rayleigh quotient equals the max eigenvalue, attained by an eigenvector.
-/
theorem max_rayleighQuotient_eq_max_eigenvalue
    (A : Matrix n n ℂ) (hA : A.IsHermitian) :
    ∃ v : EuclideanSpace ℂ n, v ≠ 0 ∧
      rayleighQuotient A v = Finset.univ.sup' Finset.univ_nonempty hA.eigenvalues ∧
      ∀ w : EuclideanSpace ℂ n, w ≠ 0 →
        rayleighQuotient A w ≤
          Finset.univ.sup' Finset.univ_nonempty hA.eigenvalues := by
  -- Set v = hA.eigenvectorBasis j. Then v ≠ 0 (orthonormal basis vectors are nonzero).
  obtain ⟨j, hj⟩ : ∃ j : n, (Finset.univ.sup' Finset.univ_nonempty hA.eigenvalues) = hA.eigenvalues j := by
    have := Finset.exists_max_image Finset.univ hA.eigenvalues Finset.univ_nonempty;
    exact ⟨ this.choose, le_antisymm ( Finset.sup'_le _ _ fun x _ => this.choose_spec.2 x ( Finset.mem_univ x ) ) ( Finset.le_sup' _ this.choose_spec.1 ) ⟩;
  refine' ⟨ _, _, _, _ ⟩;
  exact hA.eigenvectorBasis j;
  · exact hA.eigenvectorBasis.orthonormal.ne_zero j;
  · -- By definition of eigenvector, we know that $A * hA.eigenvectorBasis j = hA.eigenvalues j * hA.eigenvectorBasis j$.
    have h_eigenvec : A.mulVec (hA.eigenvectorBasis j) = (hA.eigenvalues j : ℂ) • (hA.eigenvectorBasis j) := by
      convert hA.mulVec_eigenvectorBasis j;
    convert rayleighQuotient_eigenvector A hA _ _ _ h_eigenvec;
    exact ne_of_apply_ne ( fun x => ‖x‖ ) ( by simp +decide [ hA.eigenvectorBasis.orthonormal.ne_zero ] );
  · intro w hw_ne;
    convert div_le_iff₀ ?_ |>.2 ( hermitianForm_le_max_eigenvalue_mul_norm_sq A hA w ) using 1;
    · simp +decide [ rayleighQuotient, EuclideanSpace.norm_eq ];
      simp +decide [ dotProduct, Complex.normSq, Complex.sq_norm ];
      rw [ Real.sq_sqrt ( Finset.sum_nonneg fun _ _ => add_nonneg ( mul_self_nonneg _ ) ( mul_self_nonneg _ ) ) ];
    · exact sq_pos_of_pos ( norm_pos_iff.mpr hw_ne )

/-
The min Rayleigh quotient equals the min eigenvalue, attained by an eigenvector.
-/
theorem min_rayleighQuotient_eq_min_eigenvalue
    (A : Matrix n n ℂ) (hA : A.IsHermitian) :
    ∃ v : EuclideanSpace ℂ n, v ≠ 0 ∧
      rayleighQuotient A v = Finset.univ.inf' Finset.univ_nonempty hA.eigenvalues ∧
      ∀ w : EuclideanSpace ℂ n, w ≠ 0 →
        Finset.univ.inf' Finset.univ_nonempty hA.eigenvalues ≤
          rayleighQuotient A w := by
  -- By definition of infimum, there exists an eigenvalue $\lambda_j$ such that $\lambda_j = \inf \{ \lambda_i \mid i \in \text{univ} \}$.
  obtain ⟨j, hj⟩ : ∃ j : n, hA.eigenvalues j = Finset.univ.inf' Finset.univ_nonempty hA.eigenvalues := by
    have := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) hA.eigenvalues; aesop;
  have h_min_eigenvalue : ∀ w : EuclideanSpace ℂ n, w ≠ 0 → Finset.univ.inf' Finset.univ_nonempty hA.eigenvalues ≤ rayleighQuotient A w := by
    intro w hw_ne;
    have := hermitianForm_ge_min_eigenvalue_mul_norm_sq A hA w;
    rw [ rayleighQuotient, le_div_iff₀ ];
    · convert this using 2;
      simp +decide [ EuclideanSpace.norm_eq, Complex.normSq, Complex.sq_norm ];
      rw [ Real.sq_sqrt ( Finset.sum_nonneg fun _ _ => add_nonneg ( mul_self_nonneg _ ) ( mul_self_nonneg _ ) ) ] ; simp +decide [ dotProduct, Complex.mul_conj, Complex.normSq_apply, sq ];
    · simp +decide [ hw_ne, dotProduct, Complex.ext_iff ];
      contrapose! hw_ne;
      ext i; simp_all +decide [ Complex.ext_iff, Finset.sum_eq_zero_iff_of_nonneg, add_nonneg, mul_self_nonneg ] ;
      exact ⟨ by nlinarith only [ hw_ne, Finset.single_le_sum ( fun x _ => add_nonneg ( mul_self_nonneg ( w.ofLp x |> Complex.re ) ) ( mul_self_nonneg ( w.ofLp x |> Complex.im ) ) ) ( Finset.mem_univ i ) ], by nlinarith only [ hw_ne, Finset.single_le_sum ( fun x _ => add_nonneg ( mul_self_nonneg ( w.ofLp x |> Complex.re ) ) ( mul_self_nonneg ( w.ofLp x |> Complex.im ) ) ) ( Finset.mem_univ i ) ] ⟩;
  have h_eigenvector : A.mulVec (hA.eigenvectorBasis j) = (hA.eigenvalues j : ℂ) • hA.eigenvectorBasis j := by
    convert hA.mulVec_eigenvectorBasis j using 1;
  refine' ⟨ hA.eigenvectorBasis j, _, _, h_min_eigenvalue ⟩;
  · exact hA.eigenvectorBasis.orthonormal.ne_zero j;
  · convert rayleighQuotient_eigenvector A hA _ _ _ h_eigenvector;
    · exact hj.symm;
    · exact ne_of_apply_ne ( fun x => ‖x‖ ) ( by simp +decide [ hA.eigenvectorBasis.orthonormal.ne_zero ] )

end SpectralTheory