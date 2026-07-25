/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Freivalds Verification — Probabilistic Local-to-Global Detection

## Overview

This file formalizes Freivalds' algorithm for probabilistic matrix identity
verification over finite fields. The key insight is that if `A * B ≠ C`,
then a random vector `r` detects this failure with probability ≥ 1 - 1/|F|.

The proof proceeds by reducing to a counting argument on the kernel of a
nonzero linear form, establishing that the set of "accepting" (i.e.,
non-detecting) random vectors is at most |F|^(n-1) out of |F|^n total.

## Main Results

* `nonzero_matrix_has_nonzero_row` — A nonzero matrix has a nonzero row.
* `freivalds_accepting_is_ker` — The accepting set equals the kernel of mulVecLin.
* `ker_finrank_lt_of_ne_zero` — Kernel of a nonzero matrix has dimension < n.
* `freivalds_soundness_bound` — The core cardinality bound for Freivalds.
* `freivalds_detection_probability` — The probabilistic corollary.
-/
import Mathlib

open Matrix Finset Function

noncomputable section

open Classical in
attribute [local instance] Subtype.fintype

variable {F : Type*} [Field F] [Fintype F] [DecidableEq F]

/-! ## Nonzero Matrix Row Extraction -/

/-
A nonzero matrix has at least one nonzero row (as a function).
-/
theorem nonzero_matrix_has_nonzero_row {m n : Type*} [Fintype m] [Fintype n]
    (D : Matrix m n F) (hD : D ≠ 0) :
    ∃ i, D i ≠ 0 := by
  exact not_forall.mp fun h => hD <| funext h

/-! ## Accepting Set Characterization -/

/-
The set of "accepting" vectors for Freivalds' algorithm
    (those that fail to detect the discrepancy `D = AB - C`)
    is exactly the kernel of `D.mulVecLin`.
-/
theorem freivalds_accepting_is_ker {n : ℕ}
    (D : Matrix (Fin n) (Fin n) F)
    (r : Fin n → F) :
    D.mulVec r = 0 ↔ r ∈ LinearMap.ker D.mulVecLin := by
  -- By definition of $mulVecLin$, we know that if $r$ is in the kernel of $mulVecLin$, then $mulVecLin r = 0$. This follows directly from the definition of the kernel.
  simp [LinearMap.mem_ker]

/-! ## Core Dimension Bound -/

/-
If a matrix `D` is nonzero, then `D.mulVecLin` is nonzero as a linear map.
-/
theorem mulVecLin_ne_zero_of_ne_zero {n : ℕ}
    (D : Matrix (Fin n) (Fin n) F) (hD : D ≠ 0) :
    D.mulVecLin ≠ 0 := by
  -- Assume that the linear map is zero and derive that D must be zero, which contradicts hD.
  by_contra h_contra
  have hD_zero : D = 0 := by
    exact Matrix.ext fun i j => by simpa using congr_fun ( LinearMap.congr_fun h_contra ( Pi.single j 1 ) ) i;
  contradiction

/-
If a matrix over a finite field is nonzero, then the kernel of its
    mulVecLin has finrank strictly less than n.
-/
theorem ker_finrank_lt_of_ne_zero {n : ℕ} (hn : 0 < n)
    (D : Matrix (Fin n) (Fin n) F) (hD : D ≠ 0) :
    Module.finrank F (LinearMap.ker D.mulVecLin) < n := by
  have h_rank_nullity : Module.finrank F ↥(LinearMap.range (Matrix.mulVecLin D)) + Module.finrank F ↥(LinearMap.ker (Matrix.mulVecLin D)) = n := by
    rw [ LinearMap.finrank_range_add_finrank_ker ] ; aesop;
  -- Since $D \neq 0$, we have $\text{range}(D.mulVecLin) \neq 0$, implying $\text{finrank}(\text{range}(D.mulVecLin)) \geq 1$.
  have h_range_nonzero : Module.finrank F ↥(LinearMap.range (Matrix.mulVecLin D)) ≥ 1 := by
    by_contra h_contra;
    simp_all +decide [ Submodule.eq_bot_iff ];
    exact hD ( Matrix.ext fun i j => by simpa using congr_fun ( h_contra ( Pi.single j 1 ) ) i );
  linarith

/-
The cardinality of a submodule of `Fin n → F` equals `|F|^finrank`.
-/
theorem card_submodule_eq_pow_finrank {n : ℕ}
    (S : Submodule F (Fin n → F)) :
    Nat.card S = (Fintype.card F) ^ (Module.finrank F S) := by
  have := Module.finBasis F S;
  convert Module.card_fintype this;
  convert Nat.card_eq_fintype_card;
  · exact?;
  · simp +decide

/-! ## Main Theorem -/

/-
**Freivalds soundness bound (cardinality form).**
    If `A * B ≠ C` over a finite field `F`, then the number of vectors
    `r ∈ F^n` satisfying `(A*B - C).mulVec r = 0` is at most `|F|^(n-1)`.

    This means a uniformly random `r` detects the failure with probability
    at least `1 - 1/|F|`.
-/
theorem freivalds_soundness_bound {n : ℕ} (hn : 0 < n)
    (A B C : Matrix (Fin n) (Fin n) F)
    (hneq : A * B ≠ C) :
    Nat.card (LinearMap.ker (A * B - C).mulVecLin) ≤
      (Fintype.card F) ^ (n - 1) := by
  -- By the properties of finite fields and linear algebra, if $D = AB - C$ is nonzero, then the kernel of $D.mulVecLin$ has dimension less than $n$.
  have h_ker_dim_lt_n : (Module.finrank F (LinearMap.ker (A * B - C).mulVecLin)) < n := by
    exact ker_finrank_lt_of_ne_zero hn _ ( sub_ne_zero.mpr hneq );
  -- Since the finrank of the kernel is less than n, it must be at most n-1.
  have h_ker_finrank_le_n_minus_1 : Module.finrank F (LinearMap.ker (A * B - C).mulVecLin) ≤ n - 1 := by
    exact Nat.le_pred_of_lt h_ker_dim_lt_n;
  convert Nat.pow_le_pow_right ( Fintype.card_pos ) h_ker_finrank_le_n_minus_1;
  · convert card_submodule_eq_pow_finrank _;
    infer_instance;
  · exact ⟨ 0 ⟩

/-! ## Probabilistic Corollary -/

/-
**Freivalds detection probability.**
    If `A * B ≠ C` over a finite field, the fraction of random vectors
    that fail to detect the discrepancy is at most `1/|F|`.
-/
theorem freivalds_detection_probability {n : ℕ} (hn : 0 < n)
    [NeZero (Fintype.card F)]
    (A B C : Matrix (Fin n) (Fin n) F)
    (hneq : A * B ≠ C) :
    (Nat.card (LinearMap.ker (A * B - C).mulVecLin) : ℚ) /
      (Fintype.card (Fin n → F) : ℚ) ≤ 1 / (Fintype.card F : ℚ) := by
  -- Use the fact that the cardinality of the kernel is at most |F|^(n-1).
  have h_card_ker : (Nat.card (LinearMap.ker (A * B - C).mulVecLin)) ≤ (Fintype.card F) ^ (n - 1) := by
    convert freivalds_soundness_bound hn A B C hneq using 1;
  rw [ div_le_div_iff₀ ] <;> norm_cast <;> simp_all +decide [ Fintype.card_pi ];
  · exact le_trans ( Nat.mul_le_mul_right _ h_card_ker ) ( by rw [ ← pow_succ, Nat.sub_add_cancel hn ] );
  · exact pow_pos ( Fintype.card_pos ) _;
  · exact Fintype.card_pos_iff.mpr ⟨ 0 ⟩

end