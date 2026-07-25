/-
Copyright (c) 2025 Harmonic. All rights reserved.

# Block Diagonal Matrix Verification — Sheaf-Style Gluing

## Overview

This file establishes the structural pillar of decomposable verification:
matrix identity verification for block-diagonal matrices reduces to
independent verification of each block.

## Main Results

* `block_diagonal_mul_eq_iff` — Block diagonal product equals block diagonal
  iff each block product equals the corresponding block.
* `block_diagonal_eq_zero_iff` — Block diagonal matrix is zero iff each block is zero.
* `block_diagonal_failure_detection` — Global block failure implies local block failure.
* `block_diagonal_mulVec_components` — mulVec on block diagonal reduces to
  local mulVec applications.
* `layerEval` / `networkEval` — Neural layer and block network evaluation.
* `linear_layer_certificate` — mulVec agreement implies layer output agreement.
* `block_network_certificate` — Local mulVec agreement implies global network agreement.
-/
import Mathlib

open Matrix Finset

/-! ## Block Diagonal Multiplication Gluing -/

/-- **Block diagonal multiplication gluing theorem.**
    A block diagonal product equals a block diagonal target if and only if
    each block satisfies the corresponding identity. This is the deterministic
    analogue of local-to-global verification: global identity = conjunction of
    local identities on independent blocks.

    This is the structural foundation for compositional matrix verification. -/
theorem block_diagonal_mul_eq_iff
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {R : Type*} [CommSemiring R]
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B C : ι → Matrix n n R) :
    blockDiagonal A * blockDiagonal B = blockDiagonal C
      ↔ ∀ i, A i * B i = C i := by
  rw [← blockDiagonal_mul]
  constructor
  · intro h; exact fun i => blockDiagonal_injective h ▸ rfl
  · intro h; congr 1; funext i; exact h i

/-- Block diagonal matrix is zero iff each block is zero. -/
theorem block_diagonal_eq_zero_iff
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {R : Type*} [Zero R]
    {m n : Type*} [DecidableEq m] [DecidableEq n]
    (M : ι → Matrix m n R) :
    blockDiagonal M = 0 ↔ ∀ i, M i = 0 := by
  constructor
  · intro h i
    ext x y
    have := congr_fun₂ h (x, i) (y, i)
    simp [blockDiagonal_apply] at this
    exact this
  · intro h
    ext ⟨x, i⟩ ⟨y, j⟩
    simp [blockDiagonal_apply, h]

/-- **Block diagonal failure detection.**
    If the block diagonal product `AB` differs from `C`, then some block
    must witness the failure. -/
theorem block_diagonal_failure_detection
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {R : Type*} [CommSemiring R]
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B C : ι → Matrix n n R)
    (hneq : blockDiagonal A * blockDiagonal B ≠ blockDiagonal C) :
    ∃ i, A i * B i ≠ C i := by
  exact not_forall.mp fun h => hneq ((block_diagonal_mul_eq_iff A B C).mpr h)

/-- **Block diagonal mulVec decomposition.**
    Applying `mulVec` with a block-diagonal matrix decomposes into
    independent local `mulVec` applications on each block. -/
theorem block_diagonal_mulVec_components
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {R : Type*} [NonUnitalNonAssocSemiring R]
    {n : Type*} [Fintype n] [DecidableEq n]
    (M : ι → Matrix n n R) (v : n × ι → R) (j : n) (k : ι) :
    (blockDiagonal M).mulVec v (j, k) = (M k).mulVec (fun i => v (i, k)) j := by
  simp only [mulVec, dotProduct, blockDiagonal_apply]
  rw [Fintype.sum_prod_type]
  simp only [ite_mul, zero_mul]
  congr 1; ext i
  simp

/-! ## Layer Certificate Infrastructure -/

/-- Simple linear layer evaluation via matrix-vector product. -/
noncomputable def layerEval {n m : ℕ} (W : Matrix (Fin m) (Fin n) ℝ) (x : Fin n → ℝ) :
    Fin m → ℝ :=
  W.mulVec x

/-- **Linear layer certificate.**
    If two weight matrices agree on an input via `mulVec`, then they produce
    the same layer output. -/
theorem linear_layer_certificate
    {n m : ℕ}
    (W W' : Matrix (Fin m) (Fin n) ℝ)
    (x : Fin n → ℝ)
    (h : W.mulVec x = W'.mulVec x) :
    layerEval W x = layerEval W' x := h

/-- Network evaluation on block-diagonal layers. -/
noncomputable def networkEval
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : Type*} [Fintype n] [DecidableEq n]
    (M : Matrix (n × ι) (n × ι) ℝ) (x : n × ι → ℝ) :
    n × ι → ℝ :=
  M.mulVec x

/-- **Block network certificate.**
    If each block's weight matrix agrees with an alternative on its input,
    then the full block-diagonal network produces the same output. -/
theorem block_network_certificate
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : Type*} [Fintype n] [DecidableEq n]
    (W W' : ι → Matrix n n ℝ)
    (x : n × ι → ℝ)
    (hlocal : ∀ i, (W i).mulVec (fun j => x (j, i)) =
                    (W' i).mulVec (fun j => x (j, i))) :
    networkEval (blockDiagonal W) x = networkEval (blockDiagonal W') x := by
  ext ⟨j, i⟩
  simp only [networkEval]
  rw [block_diagonal_mulVec_components W x j i,
      block_diagonal_mulVec_components W' x j i]
  exact congr_fun (hlocal i) j

/-! ## Block Diagonal Subtraction and Discrepancy -/

/-- The discrepancy of a block-diagonal product decomposes block-wise. -/
theorem block_diagonal_discrepancy_iff
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {R : Type*} [CommRing R]
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B C : ι → Matrix n n R) :
    blockDiagonal A * blockDiagonal B - blockDiagonal C = 0
      ↔ ∀ i, A i * B i - C i = 0 := by
  rw [sub_eq_zero, ← blockDiagonal_mul]
  constructor
  · intro h i; have := blockDiagonal_injective h; rw [funext_iff] at this; exact sub_eq_zero.mpr (this i)
  · intro h; congr 1; funext i; exact sub_eq_zero.mp (h i)

/-- **Two-block gluing**: if both halves of a 2-block diagonal system verify,
    then the global system verifies. Specialization for the common case. -/
theorem two_block_gluing
    {R : Type*} [CommSemiring R]
    {n₁ n₂ : Type*} [Fintype n₁] [DecidableEq n₁] [Fintype n₂] [DecidableEq n₂]
    (A₁ B₁ C₁ : Matrix n₁ n₁ R)
    (A₂ B₂ C₂ : Matrix n₂ n₂ R)
    (h₁ : A₁ * B₁ = C₁) (h₂ : A₂ * B₂ = C₂) :
    Matrix.fromBlocks A₁ 0 0 A₂ * Matrix.fromBlocks B₁ 0 0 B₂ =
    Matrix.fromBlocks C₁ 0 0 C₂ := by
  simp [fromBlocks_multiply, h₁, h₂]