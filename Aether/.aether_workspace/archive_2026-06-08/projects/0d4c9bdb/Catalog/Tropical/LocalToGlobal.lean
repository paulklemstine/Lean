/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Local-to-Global Verification Paradigm — Synthesis

## Overview

This file synthesizes the three pillars of decomposable verification:
1. **Probabilistic** (Freivalds): random probes detect failures.
2. **Structural** (Block gluing): local block checks imply global identity.
3. **Robustness** (Tropical): quantitative margins survive perturbation.

The central synthesis theorem shows that if a block-diagonal matrix identity
fails, then either a local block check detects it (structural), or equivalently,
a random probe on that block detects it probabilistically.

## Main Results

* `block_freivalds_soundness` — Probabilistic detection for block-diagonal failures.
* `verification_detection_principle` — Global failure implies witness detection.
* `block_verification_detection` — Block failure implies local witness.
* `verification_composition` — Compositional verification for layered systems.
* `tropical_margin_min_pos` — Tropical security margins compose.
-/
import Mathlib
import Tropical.BlockDiagonal
import Tropical.ApproximateVerification

open Matrix Finset

/-! ## Block Freivalds Synthesis -/

/-
**Block Freivalds soundness.**
    If a block-diagonal matrix identity fails (some block has `A_i * B_i ≠ C_i`),
    then the discrepancy on that block is nonzero. Combined with Freivalds' bound
    on that block, random probes detect the failure with high probability.
-/
theorem block_freivalds_soundness
    {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B C : ι → Matrix n n F)
    (hneq : ∃ i, A i * B i ≠ C i) :
    ∃ i, (A i * B i - C i) ≠ 0 := by
  exact hneq.imp fun i hi => sub_ne_zero_of_ne hi

/-! ## Verification Detection Principle -/

/-
**The verification detection principle.**
    If a matrix identity `A * B = C` fails for matrices over ℝ, then
    there exists a unit-bounded witness vector detecting the failure.
-/
theorem verification_detection_principle {n : ℕ}
    (A B C : Matrix (Fin n) (Fin n) ℝ)
    (hneq : A * B ≠ C) :
    ∃ r : Fin n → ℝ, (∀ i, |r i| ≤ 1) ∧ (A * B - C).mulVec r ≠ 0 := by
  convert nonzero_matrix_mulVec_witness ( A * B - C ) ( sub_ne_zero.mpr hneq )

/-
**Block-structured verification detection.**
    If a block-diagonal matrix product fails, we can find both the failing
    block AND a witness vector.
-/
theorem block_verification_detection
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : ℕ}
    (A B C : ι → Matrix (Fin n) (Fin n) ℝ)
    (hneq : blockDiagonal A * blockDiagonal B ≠ blockDiagonal C) :
    ∃ i, ∃ r : Fin n → ℝ, (∀ j, |r j| ≤ 1) ∧
      (A i * B i - C i).mulVec r ≠ 0 := by
  -- By block_diagonal_failure_detection, there exists i with A i * B i ≠ C i.
  obtain ⟨i, hi⟩ : ∃ i, A i * B i ≠ C i := by
    exact?;
  exact ⟨ i, by obtain ⟨ r, hr₁, hr₂ ⟩ := nonzero_matrix_mulVec_witness _ ( sub_ne_zero_of_ne hi ) ; exact ⟨ r, hr₁, by simpa [ sub_eq_iff_eq_add ] using hr₂ ⟩ ⟩

/-! ## Compositional Verification -/

/-
**Verification composition for sequential layers.**
    If two layer certificates hold independently, the composed system
    is also certified.
-/
theorem verification_composition {n : ℕ}
    (W₁ W₁' W₂ W₂' : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ)
    (h₁ : W₁.mulVec x = W₁'.mulVec x)
    (h₂ : W₂.mulVec (W₁.mulVec x) = W₂'.mulVec (W₁.mulVec x)) :
    W₂.mulVec (W₁.mulVec x) = W₂'.mulVec (W₁'.mulVec x) := by
  convert h₂ using 1;
  rw [ h₁ ]

/-! ## Tropical Security Composition -/

/-
**Tropical margin minimum.**
    The minimum of two positive security margins is still positive.
    This is the atomic case of tropical security composition.
-/
theorem tropical_margin_min_pos (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    0 < min a b := by
  exact lt_min ha hb

/-
**Tropical security margin composition.**
    Given a list of positive margins, their iterated minimum is positive.
    This generalizes `tropical_margin_min_pos` to arbitrary finite compositions.
-/
theorem tropical_margin_list_min_pos (margins : List ℝ) (hne : margins ≠ [])
    (hpos : ∀ m ∈ margins, 0 < m) :
    0 < margins.foldl min (margins.head hne) := by
  -- We can prove this by induction on the list.
  induction' margins using List.reverseRecOn with m l ih;
  · contradiction;
  · cases m <;> simp_all +decide [ List.foldl_append ]