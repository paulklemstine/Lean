/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Block Diagonal Matrix Verification — Sheaf-Style Gluing

## Overview

This file establishes that matrix identity verification for block-diagonal
matrices reduces to independent verification of each block. This is the
deterministic "gluing" pillar of the local-to-global verification paradigm.

## Main Results

* `block_diagonal_mul_eq_iff` — Block diagonal product equals block diagonal
  iff each block product equals the corresponding block.
* `block_diagonal_eq_zero_iff` — Block diagonal matrix is zero iff each block is zero.
* `block_diagonal_failure_detection` — Global block failure implies local block failure.
* `block_diagonal_mulVec_eq_iff` — mulVec on block diagonal reduces to local mulVec.
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
  · intro h
    exact fun i => congr_fun (blockDiagonal_injective h) i
  · intro h
    congr 1
    funext i
    exact h i

/-
Block diagonal matrix is zero iff each block is zero.
-/
theorem block_diagonal_eq_zero_iff
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {R : Type*} [Zero R]
    {m n : Type*} [DecidableEq m] [DecidableEq n]
    (M : ι → Matrix m n R) :
    blockDiagonal M = 0 ↔ ∀ i, M i = 0 := by
  constructor <;> intro h;
  · rw [ ← Matrix.ext_iff ] at *;
    intro i; ext x y; specialize h ( x, i ) ( y, i ) ; simp_all +decide [ blockDiagonal_apply ] ;
  · ext i j k l; simp +decide [ h, Matrix.blockDiagonal_apply ] ;

/-
**Block diagonal failure detection.**
    If the block diagonal product `AB` differs from `C`, then some block
    must witness the failure. This is the contrapositive of gluing,
    establishing that global failure implies local failure.
-/
theorem block_diagonal_failure_detection
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {R : Type*} [CommSemiring R]
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B C : ι → Matrix n n R)
    (hneq : blockDiagonal A * blockDiagonal B ≠ blockDiagonal C) :
    ∃ i, A i * B i ≠ C i := by
  exact not_forall.mp fun h => hneq <| by simp +decide [ h, block_diagonal_mul_eq_iff ] ;

/-
**Block diagonal mulVec decomposition.**
    Applying `mulVec` with a block-diagonal matrix decomposes into
    independent local `mulVec` applications on each block.
-/
theorem block_diagonal_mulVec_components
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {R : Type*} [CommSemiring R]
    {n : Type*} [Fintype n] [DecidableEq n]
    (M : ι → Matrix n n R) (v : n × ι → R) (j : n) (k : ι) :
    (blockDiagonal M).mulVec v (j, k) = (M k).mulVec (fun i => v (i, k)) j := by
  -- By definition of matrix multiplication, we can expand the left-hand side.
  simp [Matrix.mulVec, Matrix.blockDiagonal];
  simp +decide [ dotProduct, Finset.sum_ite ];
  refine' Finset.sum_bij ( fun x _ => x.1 ) _ _ _ _ <;> aesop

/-! ## Layer Certificate Infrastructure -/

/-- Definition of a simple linear layer evaluation via matrix-vector product. -/
noncomputable def layerEval {n m : ℕ} (W : Matrix (Fin m) (Fin n) ℝ) (x : Fin n → ℝ) :
    Fin m → ℝ :=
  W.mulVec x

/-- **Linear layer certificate.**
    If two weight matrices agree on an input via `mulVec`, then they produce
    the same layer output. This is the foundational certificate for neural
    network layer verification. -/
theorem linear_layer_certificate
    {n m : ℕ}
    (W W' : Matrix (Fin m) (Fin n) ℝ)
    (x : Fin n → ℝ)
    (h : W.mulVec x = W'.mulVec x) :
    layerEval W x = layerEval W' x := h

/-- Definition of network evaluation on block-diagonal layers. -/
noncomputable def networkEval
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : Type*} [Fintype n] [DecidableEq n]
    (M : Matrix (n × ι) (n × ι) ℝ) (x : n × ι → ℝ) :
    n × ι → ℝ :=
  M.mulVec x

/-
**Block network certificate.**
    If each block's weight matrix agrees with an alternative on its input,
    then the full block-diagonal network produces the same output.
-/
theorem block_network_certificate
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : Type*} [Fintype n] [DecidableEq n]
    (W W' : ι → Matrix n n ℝ)
    (x : n × ι → ℝ)
    (hlocal : ∀ i, (W i).mulVec (fun j => x (j, i)) =
                    (W' i).mulVec (fun j => x (j, i))) :
    networkEval (blockDiagonal W) x = networkEval (blockDiagonal W') x := by
  ext ⟨ j, i ⟩;
  convert congr_arg ( fun y => y j ) ( hlocal i ) using 1 ;
  · convert block_diagonal_mulVec_components W x j i using 1;
  · convert block_diagonal_mulVec_components W' x j i using 1