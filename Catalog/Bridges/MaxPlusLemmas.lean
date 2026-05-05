import Mathlib
import Bridges.MaxPlusDefs

/-!
# Max-Plus Algebra: Structural Lemmas

Basic structural properties of max-plus matrix operations.
-/

noncomputable section

open Finset BigOperators

variable {n : ℕ}

/-- The zeroth tropical power is the all-zeros matrix. -/
theorem tropicalMatPow_zero (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    tropicalMatPow hn M 0 i j = 0 := by
  rfl

/-- Recurrence: `M^(k+1) = tropicalMatMul M (M^k)`. -/
theorem tropicalMatPow_succ (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) :
    tropicalMatPow hn M (k + 1) = tropicalMatMul hn M (tropicalMatPow hn M k) := by
  rfl

/-- Each summand in the tropical product is ≤ the sup. -/
theorem tropicalMatMul_entry_ge_summand (hn : 0 < n)
    (A B : Matrix (Fin n) (Fin n) ℝ) (i j k : Fin n) :
    A i k + B k j ≤ tropicalMatMul hn A B i j := by
  unfold tropicalMatMul
  exact Finset.le_sup' (f := fun m => A i m + B m j) (Finset.mem_univ k)

/-- Walk weight of a two-element walk is a single edge weight. -/
theorem walkWeight_pair (M : Matrix (Fin n) (Fin n) ℝ) (u v : Fin n) :
    walkWeight M [u, v] = M u v := by
  simp [walkWeight]

/-- Walk weight cons recurrence. -/
theorem walkWeight_cons (M : Matrix (Fin n) (Fin n) ℝ) (a b : Fin n) (rest : List (Fin n)) :
    walkWeight M (a :: b :: rest) = M a b + walkWeight M (b :: rest) := by
  rfl

/-- Max entry is ≥ any individual entry. -/
theorem le_maxEntry (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    M i j ≤ maxEntry hn M := by
  unfold maxEntry
  exact le_trans (Finset.le_sup' _ (Finset.mem_univ j))
    (Finset.le_sup' (fun i => Finset.sup' Finset.univ _ fun j => M i j)
      (Finset.mem_univ i))

/-- The diagonal entry `(M^(k+1)) i i` is at least `M i i + (M^k) i i`. -/
theorem tropicalMatPow_succ_diag_ge (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) (k : ℕ) :
    M i i + tropicalMatPow hn M k i i ≤ tropicalMatPow hn M (k + 1) i i := by
  exact tropicalMatMul_entry_ge_summand hn M (tropicalMatPow hn M k) i i i

/-
The diagonal entry `(M^k) i i ≥ k * M i i` (by self-loop path).
-/
theorem tropicalMatPow_diag_ge (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) (k : ℕ) :
    k * M i i ≤ tropicalMatPow hn M k i i := by
  induction' k with k ih;
  · norm_num [ tropicalMatPow_zero ];
  · have := tropicalMatPow_succ_diag_ge hn M i k;
    grind

/-
Every entry of the tropical product is at most `maxEntry A + maxEntry B`.
-/
theorem tropicalMatMul_entry_le (hn : 0 < n)
    (A B : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    tropicalMatMul hn A B i j ≤ maxEntry hn A + maxEntry hn B := by
  exact Finset.sup'_le _ _ fun x _ => add_le_add ( le_maxEntry hn A i x ) ( le_maxEntry hn B x j )

/-
Max entry of `M^k` is bounded by `k * maxEntry M` for `k ≥ 1`.
-/
theorem maxEntry_tropicalMatPow_le (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) (hk : 1 ≤ k) :
    maxEntry hn (tropicalMatPow hn M k) ≤ k * maxEntry hn M := by
  -- By the induction hypothesis, we have `maxEntry (tropicalMatPow hn M k) ≤ k * maxEntry hn M`.
  have h_ind : ∀ k : ℕ, 1 ≤ k → maxEntry hn (tropicalMatPow hn M k) ≤ k * maxEntry hn M := by
    intro k hk
    induction' k, Nat.succ_le_iff.mpr hk using Nat.le_induction with k ih;
    · simp +decide [ tropicalMatPow_succ, tropicalMatMul ];
      unfold maxEntry tropicalMatMul tropicalMatPow; norm_num;
    · -- By the properties of the maxEntry function, we have:
      have h_maxEntry_mul : maxEntry hn (tropicalMatPow hn M (k + 1)) ≤ maxEntry hn M + maxEntry hn (tropicalMatPow hn M k) := by
        exact Finset.sup'_le _ _ fun i hi => Finset.sup'_le _ _ fun j hj => by simpa using tropicalMatMul_entry_le hn M ( tropicalMatPow hn M k ) i j;
      grind +splitImp;
  exact_mod_cast h_ind _ hk

end