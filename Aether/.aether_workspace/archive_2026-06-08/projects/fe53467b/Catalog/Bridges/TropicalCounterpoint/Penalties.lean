/-
  # Penalty Nonnegativity and Zero-Cost Characterization

  We prove that each local penalty is nonneg, and that the total cost
  is zero iff the composition is first-species legal.
-/
import Mathlib
import Bridges.TropicalCounterpoint.Defs

open Finset BigOperators

/-! ## Nonnegativity of local penalties -/

/-
The forbidden vertical penalty is nonneg.
-/
theorem forbiddenVerticalPenalty_nonneg (k : ℤ) :
    0 ≤ forbiddenVerticalPenalty k := by
  -- By definition of forbiddenVerticalPenalty, we know that it is either 0 or 1.
  unfold forbiddenVerticalPenalty;
  split_ifs <;> norm_num

/-
The melodic leap penalty is nonneg.
-/
theorem melodicLeapPenalty_nonneg (x y : ℤ) :
    0 ≤ melodicLeapPenalty x y := by
  exact le_max_left _ _

/-
The parallel perfect penalty is nonneg.
-/
theorem parallelPerfectPenalty_nonneg {n : ℕ} (u v : Melody (n + 1)) (i : Fin n) :
    0 ≤ parallelPerfectPenalty u v i := by
  -- By definition, parallelPerfectPenalty is 1 if both intervals are perfect consonances and 0 otherwise. Hence, it is nonneg.
  unfold parallelPerfectPenalty
  aesop

/-! ## Zero characterization of each penalty -/

theorem forbiddenVerticalPenalty_eq_zero_iff (k : ℤ) :
    forbiddenVerticalPenalty k = 0 ↔ consonant k := by
  -- By definition of `consonant`, we know that `forbiddenVerticalPenalty k = 0` if and only if `consonant k` is true.
  simp [consonant, forbiddenVerticalPenalty];
  tauto

theorem melodicLeapPenalty_eq_zero_iff (x y : ℤ) :
    melodicLeapPenalty x y = 0 ↔ (Int.natAbs (y - x)) ≤ 2 := by
  -- By definition of melodicLeapPenalty, we have melodicLeapPenalty x y = max 0 ((Int.natAbs (y - x) : ℝ) - 2).
  simp [melodicLeapPenalty];
  norm_cast;
  norm_num [ ← Int.ofNat_le, Int.natAbs_eq_iff ]

theorem parallelPerfectPenalty_eq_zero_iff {n : ℕ} (u v : Melody (n + 1)) (i : Fin n) :
    parallelPerfectPenalty u v i = 0 ↔
      ¬(perfectConsonance (verticalInterval u v ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩) ∧
        perfectConsonance (verticalInterval u v ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩)) := by
  unfold parallelPerfectPenalty; split_ifs <;> simp_all +decide ;

/-! ## Total cost nonnegativity -/

theorem totalCost_nonneg {n : ℕ} (u v : Melody (n + 1)) :
    0 ≤ totalCost u v := by
  exact add_nonneg ( add_nonneg ( Finset.sum_nonneg fun _ _ => forbiddenVerticalPenalty_nonneg _ ) ( Finset.sum_nonneg fun _ _ => melodicLeapPenalty_nonneg _ _ ) ) ( Finset.sum_nonneg fun _ _ => parallelPerfectPenalty_nonneg _ _ _ )

/-! ## The Main Equivalence: First Species ↔ Zero Cost -/

/-
**Theorem 1**: First-species counterpoint legality is equivalent to
    the total contrapuntal cost being zero. This identifies species
    counterpoint as the exact feasibility locus of a tropical weighted CSP.
-/
theorem firstSpecies_iff_zeroCost {n : ℕ} (u v : Melody (n + 1)) :
    FirstSpeciesLegal u v ↔ totalCost u v = 0 := by
  constructor <;> intro h;
  · unfold totalCost;
    rw [ Finset.sum_eq_zero, Finset.sum_eq_zero, Finset.sum_eq_zero ] <;> intros <;> simp_all +decide [ FirstSpeciesLegal ];
    · unfold parallelPerfectPenalty; aesop;
    · exact max_eq_left ( sub_nonpos_of_le ( mod_cast h.2.2 _ ) );
    · exact if_pos ( h.1 _ );
  · unfold FirstSpeciesLegal totalCost at *;
    rw [ add_eq_zero_iff_of_nonneg ] at h;
    · rw [ add_eq_zero_iff_of_nonneg ] at h;
      · simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, forbiddenVerticalPenalty_nonneg, melodicLeapPenalty_nonneg, parallelPerfectPenalty_nonneg ];
        simp_all +decide [ forbiddenVerticalPenalty_eq_zero_iff, melodicLeapPenalty_eq_zero_iff, parallelPerfectPenalty_eq_zero_iff ];
      · exact Finset.sum_nonneg fun _ _ => forbiddenVerticalPenalty_nonneg _;
      · exact Finset.sum_nonneg fun _ _ => melodicLeapPenalty_nonneg _ _;
    · exact add_nonneg ( Finset.sum_nonneg fun _ _ => forbiddenVerticalPenalty_nonneg _ ) ( Finset.sum_nonneg fun _ _ => melodicLeapPenalty_nonneg _ _ );
    · exact Finset.sum_nonneg fun _ _ => parallelPerfectPenalty_nonneg _ _ _