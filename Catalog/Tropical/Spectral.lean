/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Spectral Theory: From Subadditivity to Cycle Means

This file extends the tropical matrix power theory from `MinPlus.lean` with
results toward tropical eigenvalue theory:

- `tropMulS_symm`: symmetry of tropical product for symmetric matrices
- `tropPowS_mono`: monotonicity of tropical powers
- `tropMulS_assoc`: associativity of tropical multiplication
- `tropPowS_add`: power splitting for tropical powers
- `tropPow_min_diag_le_individual`: min diagonal bounded by individual subadditive bound

These results are stepping stones toward the tropical eigenvalue theorem
(Karp's theorem), which states that the minimum cycle mean equals the
tropical spectral radius.
-/
import Mathlib

open BigOperators

variable {n : ℕ}

/-- Min-plus (tropical) matrix multiplication. -/
noncomputable def tropMulS (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => ⨅ k : Fin n, (A i k + B k j)

/-- Tropical matrix power (0-indexed): `tropPowS A m` = A^⊗(m+1). -/
noncomputable def tropPowS (A : Matrix (Fin n) (Fin n) ℝ) : ℕ → Matrix (Fin n) (Fin n) ℝ
  | 0 => A
  | m + 1 => tropMulS (tropPowS A m) A

theorem tropMulS_le_witness [Nonempty (Fin n)]
    (A B : Matrix (Fin n) (Fin n) ℝ) (i j k : Fin n) :
    tropMulS A B i j ≤ A i k + B k j :=
  ciInf_le (Finite.bddBelow_range fun x => A i x + B x j) k

/-- Diagonal entries of the tropical product are bounded by off-diagonal paths. -/
theorem tropMulS_diag_le [Nonempty (Fin n)]
    (A B : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    tropMulS A B i i ≤ A i i + B i i :=
  tropMulS_le_witness A B i i i

/-- For symmetric cost matrices, the tropical square is symmetric. -/
theorem tropMulS_symm [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : ∀ i j, A i j = A j i) :
    ∀ i j, tropMulS A A i j = tropMulS A A j i := by
  intro i j
  simp only [tropMulS]
  congr 1
  ext k
  rw [hA i k, hA k j, add_comm]

/-- Tropical multiplication is monotone: if A ≤ B entrywise, then A^⊗n ≤ B^⊗n. -/
theorem tropPowS_mono [Nonempty (Fin n)]
    (A B : Matrix (Fin n) (Fin n) ℝ)
    (hAB : ∀ i j, A i j ≤ B i j) :
    ∀ m i j, tropPowS A m i j ≤ tropPowS B m i j := by
  intro m
  induction m with
  | zero => exact fun i j => hAB i j
  | succ m ih =>
    intro i j
    simp only [tropPowS, tropMulS]
    apply ciInf_mono
    · exact Finite.bddBelow_range _
    · intro k
      exact add_le_add (ih i k) (hAB k j)

/-! ## Associativity of tropical multiplication -/

/-
Tropical multiplication is associative.
-/
theorem tropMulS_assoc [Nonempty (Fin n)]
    (A B C : Matrix (Fin n) (Fin n) ℝ) :
    tropMulS (tropMulS A B) C = tropMulS A (tropMulS B C) := by
  nontriviality;
  -- Expand both sides: LHS at (i,j) = ⨅ k, (⨅ l, A i l + B l k) + C k j = ⨅ k, ⨅ l, (A i l + B l k + C k j). RHS at (i,j) = ⨅ l, A i l + (⨅ k, B l k + C k j) = ⨅ l, ⨅ k, (A i l + B l k + C k j). Both double infima are over the same expression, just in different order.
  have h_expand : ∀ i j, (tropMulS (tropMulS A B) C) i j = ⨅ k, ⨅ l, (A i l + B l k + C k j) ∧ (tropMulS A (tropMulS B C)) i j = ⨅ l, ⨅ k, (A i l + B l k + C k j) := by
    unfold tropMulS ; simp +decide [ tropMulS, add_assoc ] ;
    simp +decide [ ← add_assoc, add_comm, add_left_comm, add_assoc, ciInf_add, add_ciInf ];
  ext i j;
  rw [ h_expand i j |>.1, h_expand i j |>.2 ];
  apply_rules [ le_antisymm ];
  · refine' le_ciInf fun l => _;
    refine' le_ciInf fun k => _;
    refine' le_trans ( ciInf_le _ k ) _;
    · exact Set.finite_range _ |> Set.Finite.bddBelow;
    · exact ciInf_le ( Finite.bddBelow_range fun l => A i l + B l k + C k j ) l;
  · refine' le_ciInf fun k => _;
    exact ciInf_mono ( Finite.bddBelow_range _ ) fun l => ciInf_le ( Finite.bddBelow_range _ ) k

/-! ## Power splitting -/

/-
Power splitting: `tropPowS A (m + k + 1) = tropMulS (tropPowS A m) (tropPowS A k)`.
-/
theorem tropPowS_add [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) (m k : ℕ) :
    tropPowS A (m + k + 1) = tropMulS (tropPowS A m) (tropPowS A k) := by
  -- We proceed by induction on $k$.
  induction' k with k ih;
  · rfl;
  · -- By the associativity of tropical multiplication and the definition of tropPowS, we can rewrite the goal using the induction hypothesis.
    have h_assoc : tropMulS (tropPowS A (m + k + 1)) A = tropMulS (tropPowS A m) (tropPowS A (k + 1)) := by
      rw [ ih, tropMulS_assoc ];
      rfl;
    exact h_assoc

/-! ## Subadditivity consequences -/

/-- The minimum diagonal entry of a tropical power is bounded by any
    individual diagonal's subadditive bound. -/
theorem tropPow_min_diag_le_individual [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) (m k : ℕ) (i : Fin n) :
    (⨅ j : Fin n, tropPowS A (m + k + 1) j j) ≤
    tropPowS A m i i + tropPowS A k i i := by
  calc (⨅ j, tropPowS A (m + k + 1) j j)
      ≤ tropPowS A (m + k + 1) i i := ciInf_le (Finite.bddBelow_range _) i
    _ = tropMulS (tropPowS A m) (tropPowS A k) i i := by rw [tropPowS_add]
    _ ≤ tropPowS A m i i + tropPowS A k i i := tropMulS_diag_le _ _ i