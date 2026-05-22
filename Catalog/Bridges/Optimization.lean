/-
  # Optimization Theorems

  Theorem 2: Large forbidden-penalty regime forces legality of minimizers.
  If all penalty weights are positive and a legal witness exists,
  then every minimizer of weighted cost must satisfy strict counterpoint rules.
-/
import Mathlib
import Bridges.TropicalCounterpoint.Defs
import Bridges.TropicalCounterpoint.Penalties

open Finset BigOperators

/-! ## Tropical optimum over finite sets -/

/-- The tropical optimum (minimum cost) over a nonempty finite set of melodies exists. -/
theorem tropical_optimum_exists {n : ℕ} (S : Finset (Melody (n + 1)))
    (hS : S.Nonempty) (u : Melody (n + 1)) :
    ∃ v ∈ S, ∀ w ∈ S, totalCost u v ≤ totalCost u w :=
  Finset.exists_min_image _ _ hS

/-- The tropical optimum for weighted cost also exists. -/
theorem weighted_tropical_optimum_exists {n : ℕ} (S : Finset (Melody (n + 1)))
    (hS : S.Nonempty) (u : Melody (n + 1)) (A B C : ℝ) :
    ∃ v ∈ S, ∀ w ∈ S, weightedTotalCost A B C u v ≤ weightedTotalCost A B C u w :=
  Finset.exists_min_image _ _ hS

/-! ## Helper: weightedTotalCost of a legal melody is zero -/

theorem weightedTotalCost_legal_eq_zero {n : ℕ} (A B C : ℝ)
    (u w : Melody (n + 1)) (hw : FirstSpeciesLegal u w) :
    weightedTotalCost A B C u w = 0 := by
  unfold weightedTotalCost;
  -- Since `w` is FirstSpeciesLegal, by `firstSpecies_iff_zeroCost`, we have `totalCost u w = 0`.
  have h_totalCost : totalCost u w = 0 := by
    exact?;
  unfold totalCost at h_totalCost;
  rw [ add_eq_zero_iff_of_nonneg, add_eq_zero_iff_of_nonneg ] at h_totalCost;
  · aesop;
  · exact Finset.sum_nonneg fun _ _ => forbiddenVerticalPenalty_nonneg _;
  · exact Finset.sum_nonneg fun _ _ => melodicLeapPenalty_nonneg _ _;
  · exact add_nonneg ( Finset.sum_nonneg fun _ _ => forbiddenVerticalPenalty_nonneg _ ) ( Finset.sum_nonneg fun _ _ => melodicLeapPenalty_nonneg _ _ );
  · exact Finset.sum_nonneg fun _ _ => parallelPerfectPenalty_nonneg _ _ _

/-! ## Helper: weightedTotalCost nonneg when A, B, C ≥ 0 -/

theorem weightedTotalCost_nonneg {n : ℕ} (A B C : ℝ)
    (hA : 0 ≤ A) (hB : 0 ≤ B) (hC : 0 ≤ C)
    (u v : Melody (n + 1)) :
    0 ≤ weightedTotalCost A B C u v := by
  apply_rules [ add_nonneg, mul_nonneg, Finset.sum_nonneg ];
  · exact?;
  · exact fun _ _ => le_max_left _ _;
  · exact?

/-! ## Helper: if weightedTotalCost = 0 with A,B,C > 0 then legal -/

theorem legal_of_weightedTotalCost_zero {n : ℕ}
    (A B C : ℝ) (hA : 0 < A) (hB : 0 < B) (hC : 0 < C)
    (u v : Melody (n + 1))
    (hzero : weightedTotalCost A B C u v = 0) :
    FirstSpeciesLegal u v := by
  -- Since $A * S1 = 0$, $B * S2 = 0$, and $C * S3 = 0$, and $A$, $B$, and $C$ are positive, it follows that $S1 = 0$, $S2 = 0$, and $S3 = 0$.
  have h_sums_zero : (∑ i : Fin (n + 1), forbiddenVerticalPenalty (verticalInterval u v i)) = 0 ∧
                     (∑ i : Fin n, melodicLeapPenalty (v ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩) (v ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩)) = 0 ∧
                     (∑ i : Fin n, parallelPerfectPenalty u v i) = 0 := by
                       refine' ⟨ _, _, _ ⟩ <;> contrapose! hzero;
                       · exact ne_of_gt ( add_pos_of_pos_of_nonneg ( add_pos_of_pos_of_nonneg ( mul_pos hA ( lt_of_le_of_ne ( Finset.sum_nonneg fun _ _ => forbiddenVerticalPenalty_nonneg _ ) ( Ne.symm hzero ) ) ) ( mul_nonneg hB.le ( Finset.sum_nonneg fun _ _ => melodicLeapPenalty_nonneg _ _ ) ) ) ( mul_nonneg hC.le ( Finset.sum_nonneg fun _ _ => parallelPerfectPenalty_nonneg _ _ _ ) ) );
                       · exact ne_of_gt ( add_pos_of_pos_of_nonneg ( add_pos_of_nonneg_of_pos ( mul_nonneg hA.le ( Finset.sum_nonneg fun _ _ => forbiddenVerticalPenalty_nonneg _ ) ) ( mul_pos hB ( lt_of_le_of_ne ( Finset.sum_nonneg fun _ _ => melodicLeapPenalty_nonneg _ _ ) ( Ne.symm hzero ) ) ) ) ( mul_nonneg hC.le ( Finset.sum_nonneg fun _ _ => parallelPerfectPenalty_nonneg _ _ _ ) ) );
                       · exact ne_of_gt ( add_pos_of_nonneg_of_pos ( add_nonneg ( mul_nonneg hA.le ( Finset.sum_nonneg fun _ _ => forbiddenVerticalPenalty_nonneg _ ) ) ( mul_nonneg hB.le ( Finset.sum_nonneg fun _ _ => melodicLeapPenalty_nonneg _ _ ) ) ) ( mul_pos hC ( lt_of_le_of_ne ( Finset.sum_nonneg fun _ _ => parallelPerfectPenalty_nonneg _ _ _ ) ( Ne.symm hzero ) ) ) );
  convert firstSpecies_iff_zeroCost u v |>.2 _;
  unfold totalCost; aesop;

/-! ## Theorem 2: Strict-style dominance -/

/-
**Theorem 2 (Strict-Style Dominance)**: If all penalty weights are positive
    and a legal witness exists, then any minimizer of weighted cost must be
    first-species legal.
-/
theorem minimizer_is_legal {n : ℕ} (S : Finset (Melody (n + 1)))
    (u : Melody (n + 1))
    (A B C : ℝ) (hA : 0 < A) (hB : 0 < B) (hC : 0 < C)
    (hlegal_exists : ∃ w ∈ S, FirstSpeciesLegal u w)
    {v : Melody (n + 1)} (_hvS : v ∈ S)
    (hmin : ∀ w ∈ S, weightedTotalCost A B C u v ≤ weightedTotalCost A B C u w) :
    FirstSpeciesLegal u v := by
  apply legal_of_weightedTotalCost_zero A B C hA hB hC u v;
  obtain ⟨ w, hwS, hwleg ⟩ := hlegal_exists; linarith [ hmin w hwS, weightedTotalCost_legal_eq_zero A B C u w hwleg, weightedTotalCost_nonneg A B C hA.le hB.le hC.le u v ] ;