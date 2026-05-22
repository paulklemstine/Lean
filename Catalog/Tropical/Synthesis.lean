/-
Copyright (c) 2025 Harmonic. All rights reserved.

# Decomposable Verification Synthesis

## Overview

This file proves the cross-domain synthesis theorems connecting the three
pillars of decomposable verification:
1. **Probabilistic** (Freivalds local certification)
2. **Structural** (block diagonal gluing)
3. **Robustness** (tropical/approximate stability)

## Main Results

* `block_freivalds_soundness` — Block failure implies global failure (structural → probabilistic).
* `enhanced_trichotomy_over_reals` — Over ℝ, block failure provides both structural
  detection and a bounded-norm witness.
* `block_robustness_detection` — Block discrepancy implies bounded-norm witness
  (structural → robustness).
* `freivalds_tropical_bridge` — Nonzero discrepancy has a standard basis witness
  (probabilistic ↔ robustness).
* `certified_layer_detection` — Certified ML layer verification from algebraic certificates.
-/
import Tropical.DecomposableVerification.BlockGluing
import Tropical.DecomposableVerification.FreivaldsLocal
import Tropical.DecomposableVerification.ApproximateRobustness

open Matrix Finset BigOperators

noncomputable section

/-! ## Block Freivalds Soundness -/

/-- **Block Freivalds soundness.**
    If some block of a block-diagonal product fails, then the global
    product fails. This connects structural decomposition with
    probabilistic certification. -/
theorem block_freivalds_soundness
    {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B C : ι → Matrix n n F)
    (hneq : ∃ i, A i * B i ≠ C i) :
    blockDiagonal A * blockDiagonal B ≠ blockDiagonal C := by
  intro h
  obtain ⟨i, hi⟩ := hneq
  exact hi ((block_diagonal_mul_eq_iff A B C).mp h i)

/-! ## Local-to-Global Detection -/

/-
**Enhanced trichotomy over ℝ.**
    Over the reals, block failure implies both structural detection AND
    a bounded-norm witness for the full block-diagonal system.
-/
theorem enhanced_trichotomy_over_reals
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : ℕ}
    (A B C : ι → Matrix (Fin n) (Fin n) ℝ)
    (hfail : blockDiagonal A * blockDiagonal B ≠ blockDiagonal C) :
    -- Both structural AND witness detection succeed
    (∃ i, A i * B i ≠ C i) ∧
    (∃ r : (Fin n) × ι → ℝ, (∀ k, |r k| ≤ 1) ∧
      (blockDiagonal A * blockDiagonal B).mulVec r ≠
      (blockDiagonal C).mulVec r) := by
  refine' ⟨ _, _ ⟩;
  · apply block_diagonal_failure_detection A B C hfail;
  · -- Since $D \neq 0$, there exists some $i$ and $j$ such that $D_{ij} \neq 0$.
    obtain ⟨i, j, hij⟩ : ∃ i j, (blockDiagonal A * blockDiagonal B - blockDiagonal C) i j ≠ 0 := by
      exact not_forall_not.mp fun h => hfail <| sub_eq_zero.mp <| by ext i j; aesop;
    refine' ⟨ Pi.single j 1, _, _ ⟩ <;> simp_all +decide [ funext_iff, Matrix.mulVec ];
    · grind;
    · exact ⟨ i.1, i.2, fun h => hij <| sub_eq_zero.mpr h ⟩

/-! ## Block Robustness Detection -/

/-
**Block robustness detection over ℝ.**
    If some block's weight matrices differ, the full block-diagonal system
    admits a bounded-norm witness detecting the discrepancy.
-/
theorem block_robustness_detection
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : ℕ}
    (W W' : ι → Matrix (Fin n) (Fin n) ℝ)
    (hneq : ∃ i, W i ≠ W' i) :
    ∃ x : (Fin n) × ι → ℝ, (∀ k, |x k| ≤ 1) ∧
      (blockDiagonal W).mulVec x ≠ (blockDiagonal W').mulVec x := by
  -- From hneq, get i₀ with W i₀ ≠ W' i₀.
  obtain ⟨i₀, hi₀⟩ : ∃ i₀, W i₀ ≠ W' i₀ := hneq;
  -- Since $W i₀ - W' i₀ ≠ 0$, there exist $p, q$ such that $(W i₀ - W' i₀) p q ≠ 0$.
  obtain ⟨p, q, hpq⟩ : ∃ p q, (W i₀ - W' i₀) p q ≠ 0 := by
    exact not_forall_not.mp fun h => hi₀ <| sub_eq_zero.mp <| by ext p q; aesop;
  refine' ⟨ Pi.single ( q, i₀ ) 1, _, _ ⟩ <;> simp_all +decide [ funext_iff, Matrix.mulVec, dotProduct ];
  · intro a b; by_cases ha : a = q <;> by_cases hb : b = i₀ <;> simp +decide [ ha, hb, Pi.single_apply ] ;
  · refine' ⟨ p, i₀, _ ⟩ ; simp_all +decide [ blockDiagonal ];
    exact fun h => hpq <| sub_eq_zero.mpr h

/-! ## Freivalds-Tropical Bridge -/

/-- **Freivalds-tropical bridge.**
    Over ℝ, a nonzero discrepancy matrix has a standard basis witness. -/
theorem freivalds_tropical_bridge
    {n : ℕ}
    (A B C : Matrix (Fin n) (Fin n) ℝ)
    (hneq : A * B ≠ C) :
    ∃ j : Fin n, (A * B - C).mulVec (Pi.single j 1) ≠ 0 :=
  nonzero_matrix_has_basis_witness (A * B - C) (sub_ne_zero.mpr hneq)

/-! ## Certified ML Layer Detection -/

/-- **Certified layer detection.**
    If a block-diagonal network layer differs between two weight
    configurations, then:
    1. Some block is responsible (structural detection).
    2. There is a bounded-norm input detecting the discrepancy (robustness). -/
theorem certified_layer_detection
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : ℕ}
    (W W' : ι → Matrix (Fin n) (Fin n) ℝ)
    (hneq : blockDiagonal W ≠ blockDiagonal W') :
    -- Structural: some block differs
    (∃ i, W i ≠ W' i) ∧
    -- Robustness: bounded witness exists
    (∃ x : (Fin n) × ι → ℝ, (∀ k, |x k| ≤ 1) ∧
      networkEval (blockDiagonal W) x ≠ networkEval (blockDiagonal W') x) := by
  have h_block : ∃ i, W i ≠ W' i := by
    by_contra h; push_neg at h
    exact hneq (congr_arg blockDiagonal (funext h))
  constructor
  · exact h_block
  · obtain ⟨x, hx_bound, hx_ne⟩ := block_robustness_detection W W' h_block
    exact ⟨x, hx_bound, hx_ne⟩

end