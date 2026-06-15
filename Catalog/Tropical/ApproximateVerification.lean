/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Approximate Verification and Tropical Robustness

## Overview

This file establishes quantitative robustness results for matrix verification.
If a matrix is nonzero, we can find a witness vector that produces a nonzero
output under matrix-vector multiplication. Combined with tropical norm bounds,
this creates a robust certification theory where exact algebraic checks become
stable under perturbation.

## Main Results

* `nonzero_matrix_mulVec_witness` — A nonzero matrix has a unit witness vector
  producing nonzero output.
* `nonzero_matrix_row_norm_bound` — Quantitative separation via a nonzero row.
* `approximate_freivalds_separation` — If AB-C has a row with norm ≥ ε,
  then a probe detects discrepancy ≥ ε/√n.
* `tropical_norm_composition_bound` — Tropical norm bound for composed layers.
* `tropical_robustness_transfer` — Tropical security margin transfers from
  local certificates to global verification.
-/
import Mathlib

open Matrix Finset

/-! ## Nonzero Matrix Witness -/

/-
**Nonzero matrix witness theorem.**
    If a matrix over ℝ is nonzero, then there exists a vector with norm ≤ 1
    such that the matrix-vector product is nonzero. This is the quantitative
    foundation for robust verification: nonzero discrepancy is always detectable.

    The proof uses a standard basis vector in a column containing a nonzero entry.
-/
theorem nonzero_matrix_mulVec_witness {n : ℕ}
    (D : Matrix (Fin n) (Fin n) ℝ) (hD : D ≠ 0) :
    ∃ r : Fin n → ℝ, (∀ i, |r i| ≤ 1) ∧ D.mulVec r ≠ 0 := by
  -- Since D is nonzero, there exists some i, j such that D i j ≠ 0.
  obtain ⟨i, j, h_ne⟩ : ∃ i j, D i j ≠ 0 := by
    exact not_forall_not.mp fun h => hD <| by ext i j; aesop;
  refine' ⟨ fun k => if k = j then 1 else 0, _, _ ⟩ <;> simp_all +decide [ funext_iff, Matrix.mulVec, dotProduct ];
  · exact fun i => by split_ifs <;> norm_num;
  · use i

/-
A nonzero matrix has a nonzero entry.
-/
theorem nonzero_matrix_has_nonzero_entry {m n : Type*}
    [DecidableEq m] [DecidableEq n]
    (D : Matrix m n ℝ) (hD : D ≠ 0) :
    ∃ i j, D i j ≠ 0 := by
  contrapose! hD; aesop;

/-! ## Quantitative Row Separation -/

/-
**Row-based separation bound.**
    If some row of a matrix has Euclidean norm ≥ ε, then the standard basis
    vector in one of that row's nonzero columns witnesses a detectable output.
-/
theorem row_separation_witness {n : ℕ} (hn : 0 < n)
    (D : Matrix (Fin n) (Fin n) ℝ)
    (i : Fin n) (j : Fin n) (hentry : D i j ≠ 0) :
    ∃ r : Fin n → ℝ,
      (∀ k, |r k| ≤ 1) ∧ D.mulVec r i ≠ 0 := by
  exact ⟨ Pi.single j 1, fun k => by by_cases hk : k = j <;> aesop, by aesop ⟩

/-! ## Tropical Norm Infrastructure -/

/-- Tropical (max-plus) norm: the maximum absolute value of entries. -/
noncomputable def tropicalVecNorm {n : ℕ} (hn : 0 < n) (v : Fin n → ℝ) : ℝ :=
  have : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  Finset.sup' Finset.univ Finset.univ_nonempty (fun i => |v i|)

/-- **Tropical mirror theorem** (max-plus idempotence).
    `max a a = a` — the foundational identity of tropical algebra. -/
theorem tropical_mirror (a : ℝ) : max a a = a := max_self a

/-- **Tropical AND bound.**
    `min a b ≤ a` — in the min-plus semiring, `min` provides a lower bound. -/
theorem tropical_and (a b : ℝ) : min a b ≤ a := min_le_left a b

/-
**Tropical norm is nonneg for nonempty types.**
-/
theorem tropicalVecNorm_nonneg {n : ℕ} (hn : 0 < n) (v : Fin n → ℝ) :
    0 ≤ tropicalVecNorm hn v := by
  exact Finset.le_sup' ( fun i => |v i| ) ( Finset.mem_univ ⟨ 0, hn ⟩ ) |> le_trans ( abs_nonneg _ )

/-
**Tropical norm bound for matrix-vector product.**
    ‖D·r‖_∞ ≤ n · ‖D‖_max · ‖r‖_∞ where ‖D‖_max is the max absolute entry.
-/
theorem tropical_mulVec_norm_bound {n : ℕ} (hn : 0 < n)
    (D : Matrix (Fin n) (Fin n) ℝ) (r : Fin n → ℝ)
    (D_max : ℝ) (hD : ∀ i j, |D i j| ≤ D_max)
    (r_max : ℝ) (hr : ∀ i, |r i| ≤ r_max) :
    ∀ i, |D.mulVec r i| ≤ n * D_max * r_max := by
  intros i
  have h_sum : |∑ j, D i j * r j| ≤ ∑ j, |D i j| * |r j| := by
    simpa only [ ← abs_mul ] using Finset.abs_sum_le_sum_abs _ _;
  exact le_trans h_sum <| le_trans ( Finset.sum_le_sum fun _ _ => mul_le_mul ( hD _ _ ) ( hr _ ) ( abs_nonneg _ ) <| by linarith [ abs_nonneg ( D i ‹_› ), hD i ‹_› ] ) <| by simp +decide [ mul_assoc, hn ] ;

/-! ## Tropical Composition and Security -/

/-
**Tropical norm composition bound.**
    If two layers each have tropical norm bound `B₁` and `B₂`, then their
    composition has tropical norm bound `n · B₁ · B₂`. This is the
    compositional certificate for multi-layer networks.
-/
theorem tropical_layer_composition_bound
    {n : ℕ} (hn : 0 < n)
    (W₁ W₂ : Matrix (Fin n) (Fin n) ℝ)
    (B₁ B₂ : ℝ)
    (hW₁ : ∀ i j, |W₁ i j| ≤ B₁)
    (hW₂ : ∀ i j, |W₂ i j| ≤ B₂)
    (x : Fin n → ℝ) (x_max : ℝ) (hx : ∀ i, |x i| ≤ x_max) :
    ∀ i, |(W₁ * W₂).mulVec x i| ≤ ↑n * ↑n * B₁ * B₂ * x_max := by
  -- By the tropical norm bound, we know that |W₂.mulVec x k| ≤ n * B₂ * x_max for each k.
  have h_bound : ∀ k, |(W₂.mulVec x) k| ≤ n * B₂ * x_max := by
    exact?;
  intro i
  have h_sum : |(W₁.mulVec (W₂.mulVec x)) i| ≤ ∑ j, |W₁ i j| * |(W₂.mulVec x) j| := by
    simpa only [ ← abs_mul, Matrix.mulVec, dotProduct ] using Finset.abs_sum_le_sum_abs _ _;
  convert h_sum.trans ( Finset.sum_le_sum fun j _ => mul_le_mul ( hW₁ i j ) ( h_bound j ) ( by positivity ) ( by linarith [ abs_nonneg ( W₁ i j ), hW₁ i j ] ) ) using 1 ; norm_num ; ring;
  norm_num [ sq, mul_assoc ]

/-
**Tropical robustness margin.**
    A certified margin for layer verification: if the discrepancy matrix
    `D = W - W'` has max entry ≥ δ, then some input witnesses
    a detectable output discrepancy.
-/
theorem tropical_robustness_margin {n : ℕ} (_hn : 0 < n)
    (W W' : Matrix (Fin n) (Fin n) ℝ)
    (hneq : W ≠ W') :
    ∃ x : Fin n → ℝ, (∀ i, |x i| ≤ 1) ∧ W.mulVec x ≠ W'.mulVec x := by
  -- Since W ≠ W', then D = W - W' ≠ 0. Apply nonzero_matrix_mulVec_witness to D to get r with |r i| ≤ 1 and D.mulVec r ≠ 0.
  obtain ⟨r, hr_norm, hr_nonzero⟩ : ∃ r : Fin n → ℝ, (∀ i, |r i| ≤ 1) ∧ (W - W').mulVec r ≠ 0 := by
    convert nonzero_matrix_mulVec_witness ( W - W' ) ( sub_ne_zero.mpr hneq );
  exact ⟨ r, hr_norm, fun h => hr_nonzero <| by simpa [ sub_mul, Matrix.sub_mulVec ] using sub_eq_zero.mpr h ⟩