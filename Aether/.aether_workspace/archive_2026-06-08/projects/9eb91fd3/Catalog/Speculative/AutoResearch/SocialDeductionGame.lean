/-
# Social Deduction Game: Random Elimination Probability Theory

This module formalizes the random elimination game underlying social deduction games
(Werewolf/Mafia). We define the win probability function `winProb v w` and prove
the Parity Paradox, Skip-Two Monotonicity, and probability bounds.
-/

import Mathlib

/-- A social deduction game configuration. -/
structure SocialDeductionGame where
  villagers : ℕ
  werewolves : ℕ
  valid : villagers + werewolves > 0

/-- Random elimination win probability for villagers.

Each round: day phase randomly eliminates one of v+w players,
then (if game continues) werewolves kill one villager at night.
Villagers win iff all werewolves are eliminated.
Werewolves win iff they reach majority (w ≥ v). -/
def winProb : ℕ → ℕ → ℚ
  | _, 0 => 1
  | v, w + 1 =>
    if v ≤ w + 1 then 0
    else
      (↑(w + 1) : ℚ) / (↑v + ↑(w + 1)) * (if w = 0 then 1 else winProb (v - 1) w)
      + (↑v : ℚ) / (↑v + ↑(w + 1)) * (if v ≤ w + 3 then 0 else winProb (v - 2) (w + 1))

-- ============================================================
-- § Base Cases
-- ============================================================

theorem winProb_zero_werewolves (v : ℕ) : winProb v 0 = 1 := by
  unfold winProb; rfl

theorem winProb_werewolves_majority (v w : ℕ) (h : v ≤ w) (hw : 0 < w) :
    winProb v w = 0 := by
  match w, hw with
  | w + 1, _ =>
    unfold winProb
    simp only [ite_eq_left_iff, not_le]
    omega

-- ============================================================
-- § Concrete Value Computations
-- ============================================================

theorem winProb_2_1 : winProb 2 1 = 1 / 3 := by native_decide
theorem winProb_3_1 : winProb 3 1 = 1 / 4 := by native_decide
theorem winProb_4_1 : winProb 4 1 = 7 / 15 := by native_decide
theorem winProb_5_1 : winProb 5 1 = 3 / 8 := by native_decide
theorem winProb_6_1 : winProb 6 1 = 19 / 35 := by native_decide

theorem winProb_3_2 : winProb 3 2 = 2 / 15 := by native_decide
theorem winProb_4_2 : winProb 4 2 = 1 / 12 := by native_decide
theorem winProb_5_2 : winProb 5 2 = 8 / 35 := by native_decide
theorem winProb_6_2 : winProb 6 2 = 5 / 32 := by native_decide

-- ============================================================
-- § The Parity Paradox
-- ============================================================

/-- **Parity Paradox for w=1**: P(3, 1) < P(2, 1). Adding a villager hurts!

The mechanism: with 2 villagers and 1 werewolf, the werewolf is caught
with probability 1/3. With 3 villagers, the direct catch probability drops
to 1/4, and if missed, two villagers are lost (one day, one night) leaving
(1,1) — an immediate loss. The dilution effect outweighs the safety margin. -/
theorem parity_paradox_w1 : winProb 3 1 < winProb 2 1 := by
  rw [winProb_3_1, winProb_2_1]; norm_num

theorem parity_paradox_w1_5v4 : winProb 5 1 < winProb 4 1 := by
  rw [winProb_5_1, winProb_4_1]; norm_num

/-- **Parity Paradox for w=2**: The phenomenon persists with two werewolves. -/
theorem parity_paradox_w2 : winProb 4 2 < winProb 3 2 := by
  rw [winProb_4_2, winProb_3_2]; norm_num

theorem parity_paradox_w2_6v5 : winProb 6 2 < winProb 5 2 := by
  rw [winProb_6_2, winProb_5_2]; norm_num

/-- Existential: the parity paradox is a real phenomenon. -/
theorem parity_paradox_existence :
    ∃ v w : ℕ, 0 < w ∧ winProb (v + 1) w < winProb v w :=
  ⟨2, 1, by omega, by rw [winProb_3_1, winProb_2_1]; norm_num⟩

-- ============================================================
-- § Skip-Two Monotonicity
-- ============================================================

theorem skip_two_w1_4v2 : winProb 2 1 < winProb 4 1 := by
  rw [winProb_2_1, winProb_4_1]; norm_num

theorem skip_two_w1_5v3 : winProb 3 1 < winProb 5 1 := by
  rw [winProb_3_1, winProb_5_1]; norm_num

theorem skip_two_w1_6v4 : winProb 4 1 < winProb 6 1 := by
  rw [winProb_4_1, winProb_6_1]; norm_num

theorem skip_two_w2_5v3 : winProb 3 2 < winProb 5 2 := by
  rw [winProb_3_2, winProb_5_2]; norm_num

theorem skip_two_w2_6v4 : winProb 4 2 < winProb 6 2 := by
  rw [winProb_4_2, winProb_6_2]; norm_num

-- ============================================================
-- § Diagonal Monotonicity (trading werewolf for villager)
-- ============================================================

/-- Diagonal: P(4,1) > P(3,2). Trading a werewolf for a villager helps. -/
theorem diagonal_4_1_vs_3_2 : winProb 3 2 < winProb 4 1 := by
  rw [winProb_3_2, winProb_4_1]; norm_num

theorem diagonal_5_1_vs_4_2 : winProb 4 2 < winProb 5 1 := by
  rw [winProb_4_2, winProb_5_1]; norm_num

theorem diagonal_6_1_vs_5_2 : winProb 5 2 < winProb 6 1 := by
  rw [winProb_5_2, winProb_6_1]; norm_num

-- ============================================================
-- § Dominance Preorder
-- ============================================================

/-- Dominance: (v₁, w₁) dominates (v₂, w₂) if villagers win at least as often. -/
def GameDominates (v₁ w₁ v₂ w₂ : ℕ) : Prop :=
  winProb v₂ w₂ ≤ winProb v₁ w₁

theorem gameDominates_refl (v w : ℕ) : GameDominates v w v w :=
  le_refl _

theorem gameDominates_trans {v₁ w₁ v₂ w₂ v₃ w₃ : ℕ}
    (h₁ : GameDominates v₁ w₁ v₂ w₂) (h₂ : GameDominates v₂ w₂ v₃ w₃) :
    GameDominates v₁ w₁ v₃ w₃ :=
  le_trans h₂ h₁

-- ============================================================
-- § Win Probability Bounds
-- ============================================================

/-- The win probability is always non-negative. -/
theorem winProb_nonneg (v w : ℕ) : 0 ≤ winProb v w := by
  induction v, w using winProb.induct with
  | case1 v => rw [winProb_zero_werewolves]; norm_num
  | case2 v w hle => rw [winProb_werewolves_majority v (w+1) hle (by omega)]
  | case3 v w hgt ih_ww ih_vv =>
    unfold winProb
    simp only [show ¬(v ≤ w + 1) from hgt]
    simp only [if_false]
    apply add_nonneg <;> apply mul_nonneg
    · positivity
    · split_ifs <;> [norm_num; exact ih_ww]
    · positivity
    · split_ifs <;> [exact le_refl 0; exact ih_vv (by assumption)]

/-
The win probability is at most 1.
-/
theorem winProb_le_one (v w : ℕ) : winProb v w ≤ 1 := by
  induction' w using Nat.strong_induction_on with w ih generalizing v; induction' v using Nat.strong_induction_on with v ih';
  unfold winProb;
  rcases w with ( _ | w ) <;> rcases v with ( _ | v ) <;> norm_num;
  split_ifs <;> norm_num;
  · rw [ div_le_iff₀ ] <;> norm_cast <;> linarith;
  · subst_vars; norm_num at *;
    rw [ inv_eq_one_div, div_mul_eq_mul_div, div_add_div_same, div_le_iff₀ ] <;> nlinarith! [ show ( v : ℚ ) ≥ 3 by norm_cast, ih' ( v - 1 ) ( Nat.sub_le _ _ ), show ( winProb ( v - 1 ) 1 : ℚ ) ≤ 1 by exact_mod_cast ih' ( v - 1 ) ( Nat.sub_le _ _ ) ];
  · exact le_trans ( mul_le_of_le_one_right ( by positivity ) ( ih _ ( Nat.lt_succ_self _ ) _ ) ) ( div_le_one_of_le₀ ( by norm_cast; linarith ) ( by positivity ) );
  · exact le_trans ( add_le_add ( mul_le_of_le_one_right ( by positivity ) ( ih _ ( by linarith ) _ ) ) ( mul_le_of_le_one_right ( by positivity ) ( ih' _ ( by omega ) ) ) ) ( by rw [ ← add_div, div_le_iff₀ ] <;> linarith )

/-
============================================================
§ Recursion for w = 1
============================================================

For w = 1 and v ≥ 4: P(v, 1) = 1/(v+1) + v/(v+1) · P(v-2, 1).
-/
theorem winProb_w1_recursion (v : ℕ) (hv : 4 ≤ v) :
    winProb v 1 = 1 / (↑v + 1) + ↑v / (↑v + 1) * winProb (v - 2) 1 := by
  rw [ winProb ] ; ring ; norm_num;
  grind

-- ============================================================
-- § Phase Alignment
-- ============================================================

/-- Phase alignment ratio between P(2,1) and P(3,1) is exactly 4/3. -/
theorem phase_alignment_ratio : winProb 2 1 / winProb 3 1 = 4 / 3 := by
  rw [winProb_2_1, winProb_3_1]; norm_num

/-- The even-to-odd gap shrinks as v increases:
    P(4,1)/P(5,1) < P(2,1)/P(3,1). -/
theorem parity_gap_shrinks :
    winProb 4 1 / winProb 5 1 < winProb 2 1 / winProb 3 1 := by
  rw [winProb_2_1, winProb_3_1, winProb_4_1, winProb_5_1]; norm_num

-- ============================================================
-- § Novel Definition: Parity Defect
-- ============================================================

/-- The **parity defect** measures how much the parity paradox costs:
    it is the ratio P(v, w) / P(v+1, w), which is > 1 when the paradox occurs.
    This quantity captures the "phase misalignment penalty" in a single number. -/
noncomputable def parityDefect (v w : ℕ) : ℚ :=
  if winProb (v + 1) w = 0 then 0
  else winProb v w / winProb (v + 1) w

theorem parityDefect_2_1 : parityDefect 2 1 = 4 / 3 := by
  unfold parityDefect
  rw [winProb_2_1, winProb_3_1]
  norm_num

theorem parityDefect_4_1 : parityDefect 4 1 = 56 / 45 := by
  unfold parityDefect
  rw [winProb_4_1, winProb_5_1]
  norm_num

/-- The parity defect decreases: the paradox weakens for larger games. -/
theorem parityDefect_decreasing_w1 : parityDefect 4 1 < parityDefect 2 1 := by
  rw [parityDefect_2_1, parityDefect_4_1]; norm_num

-- ============================================================
-- § Conjectures (sorry'd for future work)
-- ============================================================

/-- **Skip-Two Monotonicity Conjecture**: Adding two villagers always helps. -/
theorem skip_two_conjecture (v w : ℕ) (hv : v ≥ w + 2) (hw : w ≥ 1) :
    winProb v w ≤ winProb (v + 2) w := by
  sorry

/-- **Diagonal Monotonicity Conjecture**: Trading a werewolf for a villager helps. -/
theorem diagonal_conjecture (v w : ℕ) (hv : v ≥ w + 2) (hw : w ≥ 2) :
    winProb v w ≤ winProb (v + 1) (w - 1) := by
  sorry

/-- **Parity Defect Convergence**: The defect → 1 as v → ∞ for fixed w. -/
theorem parityDefect_convergence (w : ℕ) (hw : 1 ≤ w) (ε : ℚ) (hε : 0 < ε) :
    ∃ N : ℕ, ∀ v : ℕ, N ≤ v → v ≥ w + 2 → |parityDefect v w - 1| < ε := by
  sorry