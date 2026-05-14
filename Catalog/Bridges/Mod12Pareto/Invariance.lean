/-
  Mod-12 Pareto Rigidity: Invariance Theorems
  =============================================

  Main results establishing that Pareto optimality of voice leadings
  is invariant under transposition in ZMod 12.

  **Cross-domain connections:**
  - The transposition invariance connects to discrete optimal transport on cyclic groups
  - The normalization theorem provides a bridge to rate-distortion theory where
    distortion is measured by cyclic displacement
  - The Pareto structure interfaces with tropical optimization via min-plus costs
-/
import Mathlib
import Bridges.Mod12Pareto.Defs
import Bridges.Mod12Pareto.MetricLemmas

open Finset BigOperators

/-! ## Voice-leading cost invariance -/

/-
Voice-leading cost is invariant under transposition: shifting all voices
    by the same pitch class preserves the total cost.
-/
theorem voiceLeadCost_transposition_invariant
    (n : ℕ) (t : pc) (x y : Fin n → pc) :
    voiceLeadCost n (transposeConfig n t x) (transposeConfig n t y) =
    voiceLeadCost n x y := by
  exact Finset.sum_congr rfl fun i _ => cycDist_add_right_invariant _ _ _

/-! ## Dominance invariance -/

/-
Dominance is invariant under transposition.
-/
theorem dominates_transposition_invariant
    (n : ℕ) (t : pc) (x y z : Fin n → pc) :
    Dominates n x y z ↔
    Dominates n (transposeConfig n t x) (transposeConfig n t y) (transposeConfig n t z) := by
  -- Unfold the definition of Dominates and transposeConfig.
  simp [Dominates, transposeConfig, cycDist_add_right_invariant, *]

/-! ## Pareto minimality invariance -/

/-
**Main Theorem (Pareto Rigidity):** Pareto minimality of a voice leading
    is invariant under transposition. This establishes that harmonic optimality
    in mod-12 is a property of the quotient space under the transposition action.
-/
theorem pareto_minimal_transposition_invariant
    (n : ℕ) (t : pc) (x y : Fin n → pc) :
    ParetoMinimal n x y ↔
    ParetoMinimal n (transposeConfig n t x) (transposeConfig n t y) := by
  constructor <;> intro h;
  · intro ⟨ z, hz ⟩;
    refine' h ⟨ fun i => z i - t, _ ⟩;
    convert dominates_transposition_invariant n t x y ( fun i => z i - t ) |>.2 _ using 1;
    unfold Dominates transposeConfig at *; aesop;
  · contrapose! h;
    obtain ⟨ z, hz ⟩ := not_not.mp h;
    exact fun h => h ⟨ fun i => z i + t, dominates_transposition_invariant n t x y z |>.1 hz ⟩

/-! ## Normal-form reduction for 3-voice configurations -/

/-
Every 3-voice Pareto minimality question reduces to normalized coordinates
    where the first voice of the source is at pitch class 0.
-/
theorem pareto_minimal_normalize3
    (x y : Fin 3 → pc) :
    ParetoMinimal 3 x y ↔
    ParetoMinimal 3 (normalizeConfig3 x) (fun i => y i - x 0) := by
  convert pareto_minimal_transposition_invariant 3 ( -x 0 ) x y using 2;
  · exact funext fun i => by simp +decide [ normalizeConfig3, transposeConfig ] ; ring;
  · -- By definition of subtraction in the finite field ZMod 12, we have y i - x 0 = y i + (-x 0).
    funext i; simp [sub_eq_add_neg];
    rfl

/-! ## Voice-leading cost depends only on differences -/

/-
Voice-leading cost depends only on the pairwise differences y_i - x_i.
-/
theorem voiceLeadCost_depends_on_differences
    (n : ℕ) (x y x' y' : Fin n → pc)
    (h : ∀ i, y i - x i = y' i - x' i) :
    voiceLeadCost n x y = voiceLeadCost n x' y' := by
  unfold voiceLeadCost;
  unfold cycDist;
  unfold rawDist;
  exact Finset.sum_congr rfl fun i _ => by rw [ show x i - y i = x' i - y' i by linear_combination -h i ] ;