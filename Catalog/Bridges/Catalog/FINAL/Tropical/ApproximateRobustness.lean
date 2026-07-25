/-
Copyright (c) 2025 Harmonic. All rights reserved.

# Approximate Verification and Tropical Robustness

## Overview

This file establishes quantitative robustness results for matrix verification.
If a matrix identity fails, a bounded-norm witness vector can detect it.
Combined with tropical composition bounds, this creates a robust certification
theory where exact algebraic checks become stable under perturbation.

## Main Results

* `operator_norm_witness_of_matrix_neq_zero` — A nonzero matrix has a
  unit-bounded witness producing nonzero output.
* `nonzero_matrix_has_basis_witness` — Standard basis witness for nonzero matrices.
* `tropical_mulVec_entrywise_bound` — Entrywise bound for matrix-vector products.
* `tropical_robustness_margin` — Nonzero discrepancy is always detectable.
-/
import Mathlib

open Matrix Finset

noncomputable section

/-! ## Operator Norm Witness -/

/-
**Operator norm witness theorem.**
    If a matrix over ℝ is nonzero, then there exists a unit-bounded vector
    such that the matrix-vector product is nonzero.
-/
theorem operator_norm_witness_of_matrix_neq_zero
    {n : ℕ}
    (D : Matrix (Fin n) (Fin n) ℝ)
    (hD : D ≠ 0) :
    ∃ r : Fin n → ℝ, (∀ i, |r i| ≤ 1) ∧ D.mulVec r ≠ 0 := by
  simp_all +decide [ funext_iff, Matrix.mulVec, dotProduct ];
  -- Since $D$ is not the zero matrix, there exists some $x$ such that $D x \neq 0$.
  obtain ⟨x, hx⟩ : ∃ x : Fin n, ∃ y : Fin n, D x y ≠ 0 := by
    exact not_forall_not.mp fun h => hD <| by ext i j; aesop;
  exact ⟨ fun i => if i = hx.choose then 1 else 0, fun i => by aesop, x, by simpa [ hx.choose_spec ] ⟩

/-
Standard basis witness for nonzero matrices.
-/
theorem nonzero_matrix_has_basis_witness
    {n : ℕ}
    (D : Matrix (Fin n) (Fin n) ℝ)
    (hD : D ≠ 0) :
    ∃ j : Fin n, D.mulVec (Pi.single j 1) ≠ 0 := by
  contrapose! hD;
  exact Matrix.ext fun i j => by simpa using congr_fun ( hD j ) i;

/-
Operator norm witness for rectangular matrices.
-/
theorem operator_norm_witness_rectangular
    {m n : ℕ}
    (D : Matrix (Fin m) (Fin n) ℝ)
    (hD : D ≠ 0) :
    ∃ r : Fin n → ℝ, (∀ i, |r i| ≤ 1) ∧ D.mulVec r ≠ 0 := by
  -- Since $D$ is nonzero, there exists some $i$ such that $D$'s $i$-th column is nonzero.
  obtain ⟨i, hi⟩ : ∃ i : Fin n, (D.mulVec (Pi.single i 1)) ≠ 0 := by
    contrapose! hD;
    ext i j; specialize hD j; replace hD := congr_fun hD i; aesop;
  exact ⟨ Pi.single i 1, fun j => by by_cases h : j = i <;> aesop, hi ⟩

/-! ## Tropical Norm Infrastructure -/

/-- Tropical (max-plus) norm for vectors: maximum absolute value. -/
noncomputable def tropicalVecNorm' {n : ℕ} (v : Fin n → ℝ) : ℝ :=
  if h : 0 < n then
    Finset.sup' Finset.univ ⟨⟨0, h⟩, Finset.mem_univ _⟩ (fun i => |v i|)
  else 0

/-- **Tropical mirror theorem** (max-plus idempotence). -/
theorem tropical_mirror' (a : ℝ) : max a a = a := max_self a

/-- **Tropical AND bound**: min provides a lower bound. -/
theorem tropical_and' (a b : ℝ) : min a b ≤ a := min_le_left a b

/-! ## Tropical Composition Bounds -/

/-
**Tropical norm bound for matrix-vector product.**
    Each entry of D·r is bounded by n · max|D_ij| · max|r_k|.
-/
theorem tropical_mulVec_entrywise_bound {n : ℕ}
    (D : Matrix (Fin n) (Fin n) ℝ) (r : Fin n → ℝ)
    (D_max : ℝ) (hD : ∀ i j, |D i j| ≤ D_max)
    (r_max : ℝ) (hr : ∀ i, |r i| ≤ r_max)
    (hD_nn : 0 ≤ D_max) :
    ∀ i, |D.mulVec r i| ≤ n * D_max * r_max := by
  intro i; simp +decide only [mulVec, dotProduct];
  exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( le_trans ( Finset.sum_le_sum fun _ _ => show |D i _ * r _| ≤ D_max * r_max by simpa only [ abs_mul ] using mul_le_mul ( hD i _ ) ( hr _ ) ( by positivity ) hD_nn ) ( by norm_num; linarith ) )

/-
**Tropical robustness margin.**
    If two weight matrices differ, there exists a bounded-norm input
    that detects the discrepancy.
-/
theorem tropical_robustness_margin' {n : ℕ}
    (W W' : Matrix (Fin n) (Fin n) ℝ)
    (hneq : W ≠ W') :
    ∃ x : Fin n → ℝ, (∀ i, |x i| ≤ 1) ∧ W.mulVec x ≠ W'.mulVec x := by
  -- Use operator_norm_witness_of_matrix_neq_zero on D = W - W'. Since hneq, D ≠ 0 (sub_ne_zero.mpr hneq).
  have hD_ne_zero : W - W' ≠ 0 := by
    exact sub_ne_zero_of_ne hneq;
  obtain ⟨ r, hr₁, hr₂ ⟩ := operator_norm_witness_of_matrix_neq_zero _ hD_ne_zero;
  exact ⟨ r, hr₁, fun h => hr₂ <| by simpa [ sub_eq_zero, Matrix.sub_mulVec ] using h ⟩

/-! ## Tropical Security Composition -/

/-- **Tropical security margin composition.**
    If two independent sub-systems have positive detection margins,
    the combined system also has positive margin. -/
theorem tropical_security_composition
    (δ₁ δ₂ : ℝ) (h₁ : 0 < δ₁) (h₂ : 0 < δ₂) :
    0 < min δ₁ δ₂ :=
  lt_min h₁ h₂

/-
**Combined certificate from finitely many local certificates.**
-/
theorem combined_tropical_certificate
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (margins : ι → ℝ) (h_pos : ∀ i, 0 < margins i) :
    0 < Finset.inf' Finset.univ Finset.univ_nonempty margins := by
  exact lt_of_lt_of_le ( h_pos ( Classical.choose ( Finset.exists_min_image Finset.univ ( fun i => margins i ) ⟨ Classical.arbitrary ι, Finset.mem_univ _ ⟩ ) ) ) ( Finset.le_inf' _ _ fun i _ => Classical.choose_spec ( Finset.exists_min_image Finset.univ ( fun i => margins i ) ⟨ Classical.arbitrary ι, Finset.mem_univ _ ⟩ ) |>.2 i ‹_› )

end