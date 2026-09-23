import Cryptography.NonabelianTypeChannel.SplitType

/-!
# Closed forms for the `log₂` of the integers occurring in the channel tables

Every entropy in this development is a rational combination of `log₂ n` for the
cell counts `n` of a finite table.  Because all those counts are `2^a · 3^b · 5^c`,
each entropy is a rational combination of `1`, `log₂ 3` and `log₂ 5`.  This file
records the needed values once and for all.
-/

namespace TypeChannel

open Real

/-- The single-cell entropy identity, in real-variable form: this is the only step
needed to turn a table of counts into a closed-form entropy. -/
lemma neg_prob_logb_real (a n : ℝ) (ha : 0 < a) (hn : 0 < n) :
    -((a / n) * logb 2 (a / n)) = (a / n) * (logb 2 n - logb 2 a) := by
  rw [Real.logb_div (ne_of_gt ha) (ne_of_gt hn)]; ring

lemma logb2_pow (k : ℕ) : logb 2 ((2:ℝ)^k) = k := by
  rw [Real.logb_pow]; simp

lemma logb2_pow_mul (k : ℕ) (m : ℝ) (hm : 0 < m) :
    logb 2 ((2:ℝ)^k * m) = k + logb 2 m := by
  rw [Real.logb_mul (by positivity) (ne_of_gt hm), logb2_pow]

lemma logb2_nine : logb 2 (9:ℝ) = 2 * logb 2 3 := by
  rw [show (9:ℝ) = 3 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num)]; ring

lemma logb2_five_pos : 0 < logb 2 5 := Real.logb_pos (by norm_num) (by norm_num)

lemma logb2_five_gt_two : 2 < logb 2 5 := by
  have h := Real.logb_lt_logb (b := 2) (x := 4) (y := 5) (by norm_num) (by norm_num)
    (by norm_num)
  linarith [logb2_four]

lemma logb2_sixteen : logb 2 (16:ℝ) = 4 := by
  rw [show (16:ℝ) = 2^(4:ℕ) by norm_num, logb2_pow]; norm_num

lemma logb2_thirtytwo : logb 2 (32:ℝ) = 5 := by
  rw [show (32:ℝ) = 2^(5:ℕ) by norm_num, logb2_pow]; norm_num

lemma logb2_sixtyfour : logb 2 (64:ℝ) = 6 := by
  rw [show (64:ℝ) = 2^(6:ℕ) by norm_num, logb2_pow]; norm_num

lemma logb2_eighteen : logb 2 (18:ℝ) = 1 + 2 * logb 2 3 := by
  rw [show (18:ℝ) = 2^(1:ℕ) * 9 by norm_num, logb2_pow_mul _ _ (by norm_num), logb2_nine]
  norm_num

lemma logb2_thirtysix : logb 2 (36:ℝ) = 2 + 2 * logb 2 3 := by
  rw [show (36:ℝ) = 2^(2:ℕ) * 9 by norm_num, logb2_pow_mul _ _ (by norm_num), logb2_nine]
  norm_num

lemma logb2_fortyeight : logb 2 (48:ℝ) = 4 + logb 2 3 := by
  rw [show (48:ℝ) = 2^(4:ℕ) * 3 by norm_num, logb2_pow_mul _ _ (by norm_num)]
  norm_num

lemma logb2_seventytwo : logb 2 (72:ℝ) = 3 + 2 * logb 2 3 := by
  rw [show (72:ℝ) = 2^(3:ℕ) * 9 by norm_num, logb2_pow_mul _ _ (by norm_num), logb2_nine]
  norm_num

lemma logb2_ninetysix : logb 2 (96:ℝ) = 5 + logb 2 3 := by
  rw [show (96:ℝ) = 2^(5:ℕ) * 3 by norm_num, logb2_pow_mul _ _ (by norm_num)]
  norm_num

lemma logb2_onefortyfour : logb 2 (144:ℝ) = 4 + 2 * logb 2 3 := by
  rw [show (144:ℝ) = 2^(4:ℕ) * 9 by norm_num, logb2_pow_mul _ _ (by norm_num), logb2_nine]
  norm_num

lemma logb2_twoeightyeight : logb 2 (288:ℝ) = 5 + 2 * logb 2 3 := by
  rw [show (288:ℝ) = 2^(5:ℕ) * 9 by norm_num, logb2_pow_mul _ _ (by norm_num), logb2_nine]
  norm_num

lemma logb2_fiveseventysix : logb 2 (576:ℝ) = 6 + 2 * logb 2 3 := by
  rw [show (576:ℝ) = 2^(6:ℕ) * 9 by norm_num, logb2_pow_mul _ _ (by norm_num), logb2_nine]
  norm_num

end TypeChannel