/-
# The extremal fork on a balanced two-coset partition

`ForkPinningCore.mutualInfo_eq_entropy_sub_condEntropy` expresses the information a congruence
observable carries about a fork as the entropy defect of the induced partition.  Conjecture
**C1** of `FUTURE_DIRECTIONS.md` asked for the *extremal* half: among all forks of a given
density, which one is pinned best by a two-element abelianization?  This file answers it.

For a balanced binary observable `X` (the sign character, or any index-two congruence condition)
and a fork `Y` of density `d ≤ 1/2`, the mutual information is bounded by the closed form

`I(X ; Y) ≤ binEntropy d − binEntropy (2d) / 2`,

and the bound is **attained exactly** by the forks supported inside a single coset (`Y ω = true`
only when `X ω = true`).  So the best-pinned fork of a given density is the single-coset one, as
conjectured; the proof is the sub-additivity of the binary entropy, which is in turn the
concavity of `x ↦ -x log x` anchored at `negMulLog 1 = 0`.

Main results:

* `ForkPinning.negMulLog_add_le` : `negMulLog (a+b) ≤ negMulLog a + negMulLog b`.
* `ForkPinning.negMulLog_one_sub_add` : the complementary inequality, from concavity.
* `ForkPinning.binEntropy_add_le` : **sub-additivity of the binary entropy** on `a + b ≤ 1`.
* `ForkPinning.mutualInfo_balanced_eq` : the exact two-coset decomposition of `I(X;Y)`.
* `ForkPinning.mutualInfo_le_singleCoset` : the extremal bound above.
* `ForkPinning.mutualInfo_singleCoset_eq` : single-coset forks attain it.
-/

import Probability.ForkPinningCapacity
import Probability.ForkPinningSemiprimeGeneral

namespace ForkPinning

open Finset Real

/-! ## Sub-additivity of the binary entropy -/

/-- Super-additivity of `x ↦ -x log x`, in two-term form. -/
lemma negMulLog_add_le (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    negMulLog (a + b) ≤ negMulLog a + negMulLog b := by
  rcases eq_or_lt_of_le ha with h | ha'
  · simp [← h]
  rcases eq_or_lt_of_le hb with h | hb'
  · simp [← h]
  have hs : 0 < a + b := by linarith
  have h1 : a * Real.log ((a + b) / a) ≥ 0 := by
    have h1' : 1 ≤ (a + b) / a := (one_le_div ha').mpr (by linarith)
    have := Real.log_nonneg h1'
    positivity
  have h2 : b * Real.log ((a + b) / b) ≥ 0 := by
    have h2' : 1 ≤ (a + b) / b := (one_le_div hb').mpr (by linarith)
    have := Real.log_nonneg h2'
    positivity
  have e1 : a * Real.log ((a + b) / a) = a * Real.log (a + b) - a * Real.log a := by
    rw [Real.log_div (ne_of_gt hs) (ne_of_gt ha')]; ring
  have e2 : b * Real.log ((a + b) / b) = b * Real.log (a + b) - b * Real.log b := by
    rw [Real.log_div (ne_of_gt hs) (ne_of_gt hb')]; ring
  simp only [negMulLog]
  nlinarith [h1, h2, e1, e2]

/-- The complementary inequality: `-x log x` evaluated on the *complements* is super-additive
as well, by concavity anchored at `negMulLog 1 = 0`. -/
lemma negMulLog_one_sub_add (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) (hab : a + b ≤ 1) :
    negMulLog (1 - (a + b)) ≤ negMulLog (1 - a) + negMulLog (1 - b) := by
  rcases eq_or_lt_of_le (by linarith : (0 : ℝ) ≤ a + b) with h0 | h0
  · have ha0 : a = 0 := by linarith
    have hb0 : b = 0 := by linarith
    simp [ha0, hb0]
  have hconc := Real.strictConcaveOn_negMulLog.concaveOn
  have key : ∀ x : ℝ, 0 ≤ x → x ≤ a + b →
      (x / (a + b)) * negMulLog (1 - (a + b)) ≤ negMulLog (1 - x) := by
    intro x hx hxs
    have hw1 : 0 ≤ x / (a + b) := by positivity
    have hw2 : 0 ≤ 1 - x / (a + b) := by
      have : x / (a + b) ≤ 1 := (div_le_one h0).mpr hxs
      linarith
    have hsum : x / (a + b) + (1 - x / (a + b)) = 1 := by ring
    have h := hconc.2 (x := 1 - (a + b)) (y := 1) (by simp; linarith) (by simp) hw1 hw2 hsum
    have harg : (x / (a + b)) • (1 - (a + b)) + (1 - x / (a + b)) • (1 : ℝ) = 1 - x := by
      simp only [smul_eq_mul]
      field_simp
      ring
    rw [harg] at h
    simpa using h
  have h1 := key a ha (by linarith)
  have h2 := key b hb (by linarith)
  have hsplit : (a / (a + b)) * negMulLog (1 - (a + b)) + (b / (a + b)) * negMulLog (1 - (a + b))
      = negMulLog (1 - (a + b)) := by
    field_simp
  linarith [h1, h2, hsplit]

/-- **Sub-additivity of the binary entropy.**  Splitting a mass `a + b ≤ 1` into two parts never
decreases the total binary entropy. -/
theorem binEntropy_add_le (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) (hab : a + b ≤ 1) :
    Real.binEntropy (a + b) ≤ Real.binEntropy a + Real.binEntropy b := by
  rw [Real.binEntropy_eq_negMulLog_add_negMulLog_one_sub,
    Real.binEntropy_eq_negMulLog_add_negMulLog_one_sub,
    Real.binEntropy_eq_negMulLog_add_negMulLog_one_sub]
  linarith [negMulLog_add_le a b ha hb, negMulLog_one_sub_add a b ha hb hab]

/-! ## The two-coset decomposition of the mutual information -/

section TwoCoset

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

omit [Nonempty Ω] in
/-- On a fibre of positive probability the conditional law of a binary fork is `(p, 1 − p)`. -/
lemma condPrb_false_eq (X Y : Ω → Bool) (k : Bool) (hk : 0 < prb X k) :
    condPrb X Y k false = 1 - condPrb X Y k true := by
  have hsum : prb (joint X Y) (k, false) + prb (joint X Y) (k, true) = prb X k := by
    have h := sum_prb_joint X Y k
    simpa [Fintype.sum_bool, add_comm] using h
  rw [condPrb, condPrb, eq_sub_iff_add_eq, ← add_div, hsum]
  exact div_self (ne_of_gt hk)

omit [Nonempty Ω] in
/-- The fibrewise entropy of a binary fork is the binary entropy of its conditional density. -/
lemma condEntropyAt_bool (X Y : Ω → Bool) (k : Bool) (hk : 0 < prb X k) :
    condEntropyAt X Y k = Real.binEntropy (condPrb X Y k true) := by
  rw [condEntropyAt, Real.binEntropy_eq_negMulLog_add_negMulLog_one_sub]
  rw [Fintype.sum_bool, condPrb_false_eq X Y k hk]

/-- **The two-coset decomposition.**  For a balanced observable the information about a fork is
the fork's binary entropy minus the average of the two conditional binary entropies. -/
theorem mutualInfo_balanced_eq (X Y : Ω → Bool) (hX : prb X true = 1 / 2) :
    mutualInfo X Y = Real.binEntropy (prb Y true)
      - (Real.binEntropy (condPrb X Y true true)
          + Real.binEntropy (condPrb X Y false true)) / 2 := by
  have hXf : prb X false = 1 / 2 := by
    have := prb_true_add_false X
    linarith [hX]
  have hpt : (0 : ℝ) < prb X true := by rw [hX]; norm_num
  have hpf : (0 : ℝ) < prb X false := by rw [hXf]; norm_num
  have hHY : H Y = Real.binEntropy (prb Y true) := by
    rw [H_bool Y, Real.binEntropy_eq_negMulLog_add_negMulLog_one_sub]
    have hfalse : prb Y false = 1 - prb Y true := by
      have := prb_true_add_false Y
      linarith
    rw [hfalse]
    ring
  rw [mutualInfo_eq_entropy_sub_condEntropy, hHY, Fintype.sum_bool,
    condEntropyAt_bool X Y true hpt, condEntropyAt_bool X Y false hpf, hX, hXf]
  ring

/-- The two conditional densities average to the fork's density. -/
lemma condPrb_add_eq (X Y : Ω → Bool) (hX : prb X true = 1 / 2) :
    condPrb X Y true true + condPrb X Y false true = 2 * prb Y true := by
  have hXf : prb X false = 1 / 2 := by
    have := prb_true_add_false X
    linarith [hX]
  have hmarg : prb (joint X Y) (true, true) + prb (joint X Y) (false, true) = prb Y true := by
    have h := sum_prb_joint_right X Y true
    simpa [Fintype.sum_bool] using h
  rw [condPrb, condPrb, hX, hXf]
  field_simp
  linarith [hmarg]

/-- **C1, the extremal half.**  For a balanced congruence observable, a fork of density
`d ≤ 1/2` can never be pinned better than the single-coset fork of the same density. -/
theorem mutualInfo_le_singleCoset (X Y : Ω → Bool) (hX : prb X true = 1 / 2)
    (hd : prb Y true ≤ 1 / 2) :
    mutualInfo X Y
      ≤ Real.binEntropy (prb Y true) - Real.binEntropy (2 * prb Y true) / 2 := by
  have hsum := condPrb_add_eq X Y hX
  have ha : 0 ≤ condPrb X Y true true :=
    div_nonneg (prb_nonneg _ _) (prb_nonneg _ _)
  have hb : 0 ≤ condPrb X Y false true :=
    div_nonneg (prb_nonneg _ _) (prb_nonneg _ _)
  have hab : condPrb X Y true true + condPrb X Y false true ≤ 1 := by
    rw [hsum]; linarith
  have hsub := binEntropy_add_le (condPrb X Y true true) (condPrb X Y false true) ha hb hab
  rw [hsum] at hsub
  rw [mutualInfo_balanced_eq X Y hX]
  linarith [hsub]

/-- **The bound is attained.**  A fork supported inside the coset `{X = true}` realises the
extremal value: single-coset forks are exactly the best-pinned forks of their density. -/
theorem mutualInfo_singleCoset_eq (X Y : Ω → Bool) (hX : prb X true = 1 / 2)
    (hsupp : ∀ ω, Y ω = true → X ω = true) :
    mutualInfo X Y
      = Real.binEntropy (prb Y true) - Real.binEntropy (2 * prb Y true) / 2 := by
  have hzero : prb (joint X Y) (false, true) = 0 := by
    have hempty : fiber (joint X Y) (false, true) = ∅ := by
      rw [fiber, Finset.filter_eq_empty_iff]
      intro ω _ hcon
      have h1 : X ω = false := congrArg Prod.fst hcon
      have h2 : Y ω = true := congrArg Prod.snd hcon
      rw [hsupp ω h2] at h1
      exact Bool.noConfusion h1
    rw [prb, hempty]
    simp
  have hbzero : condPrb X Y false true = 0 := by
    rw [condPrb, hzero, zero_div]
  have hsum := condPrb_add_eq X Y hX
  rw [hbzero, add_zero] at hsum
  rw [mutualInfo_balanced_eq X Y hX, hbzero, hsum]
  simp [Real.binEntropy_zero]

end TwoCoset

end ForkPinning