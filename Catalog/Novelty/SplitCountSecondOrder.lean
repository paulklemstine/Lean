import Mathlib
import Novelty.SplitCountConstant

/-!
# The second-order term of the split-count channel

`Catalog/Novelty/SplitCountConstant.lean` proves
`L(n) := n² · Is n · log 2 − log n → 2` with the explicit rate `|L(n) − 2| ≤ 2/n`.
Numerically the deviation is `≈ −1/(2n)`, i.e. the approach to the constant `2`
is from *below* and at exactly half the guaranteed rate.

This file proves that:

* `log_two_term` / `log_one_term` : the two Taylor estimates used, both obtained
  from Mathlib's `Real.abs_log_sub_add_sum_range_le`;
* `Is_second_order_bound` : `|L(n) − 2 + 1/(2n)| ≤ 12/n²` for every `n ≥ 3`;
* `Is_second_order` : hence `n · (L(n) − 2) → −1/2`.

So the full second-order law of the channel is

`Is n = (log n + 2 − 1/(2n) + O(1/n²)) / (n² log 2)`.

The three contributions to the constant `−1/2` are: `−3/2` from the
"exactly one factor splits" cells (`3(1−x)(x + x²/2)/x = 3 − 3x/2 − 3x²/2`), and
`+1` from the majority-class cell (`−(1−2x)/(1−x) = −1 + x + O(x²)`), with
`x = 1/n`.
-/

namespace SplitCountSecondOrder

open Finset Real Filter SplitCountLaw SplitCountChannel SplitCountDecay SplitCountConstant

variable {n : ℝ}

/-- Second-order Taylor estimate: `|−log(1 − t) − (t + t²/2)| ≤ (3/2) t³` on `(0, 1/3]`. -/
lemma log_two_term {t : ℝ} (ht0 : 0 < t) (ht : t ≤ 1 / 3) :
    |(-Real.log (1 - t)) - (t + t ^ 2 / 2)| ≤ 3 / 2 * t ^ 3 := by
  have habs : |t| < 1 := by rw [abs_of_pos ht0]; linarith
  have h := Real.abs_log_sub_add_sum_range_le habs 2
  rw [abs_of_pos ht0] at h
  have hsum : (∑ i ∈ Finset.range 2, t ^ (i + 1) / ((i : ℝ) + 1)) = t + t ^ 2 / 2 := by
    simp [Finset.sum_range_succ]
    ring
  rw [hsum] at h
  have hrewrite : |(-Real.log (1 - t)) - (t + t ^ 2 / 2)| = |t + t ^ 2 / 2 + Real.log (1 - t)| := by
    rw [abs_sub_comm]
    congr 1
    ring
  have hden : t ^ 3 / (1 - t) ≤ 3 / 2 * t ^ 3 := by
    rw [div_le_iff₀ (by linarith)]
    nlinarith [pow_pos ht0 3]
  rw [hrewrite]
  linarith

/-- First-order Taylor estimate: `|log(1 − w) + w| ≤ (4/3) w²` on `[0, 1/4]`. -/
lemma log_one_term {w : ℝ} (hw0 : 0 ≤ w) (hw : w ≤ 1 / 4) :
    |Real.log (1 - w) + w| ≤ 4 / 3 * w ^ 2 := by
  rcases eq_or_lt_of_le hw0 with h | hw0'
  · simp [← h]
  have habs : |w| < 1 := by rw [abs_of_pos hw0']; linarith
  have h := Real.abs_log_sub_add_sum_range_le habs 1
  rw [abs_of_pos hw0'] at h
  have hsum : (∑ i ∈ Finset.range 1, w ^ (i + 1) / ((i : ℝ) + 1)) = w := by
    simp
  rw [hsum] at h
  have hrewrite : |Real.log (1 - w) + w| = |w + Real.log (1 - w)| := by rw [add_comm]
  have hden : w ^ 2 / (1 - w) ≤ 4 / 3 * w ^ 2 := by
    rw [div_le_iff₀ (by linarith)]
    nlinarith [sq_nonneg w]
  rw [hrewrite]
  linarith

set_option maxHeartbeats 1000000 in
/-- **The second-order law, with an explicit rate.**  For every real `n ≥ 3`,
`n² · Is n · log 2 − log n` differs from `2 − 1/(2n)` by at most `12/n²`. -/
theorem Is_second_order_bound (hn : 3 ≤ n) :
    |n ^ 2 * (Is n * Real.log 2) - Real.log n - 2 + 1 / 2 * (1 / n)| ≤ 12 * (1 / n) ^ 2 := by
  have hn0 : (0:ℝ) < n := by linarith
  have hne : n ≠ 0 := ne_of_gt hn0
  have hn1 : n - 1 ≠ 0 := by intro h; rw [sub_eq_zero] at h; linarith
  have hn2 : n - 2 ≠ 0 := by intro h; rw [sub_eq_zero] at h; linarith
  have hx0 : (0:ℝ) < 1 / n := by positivity
  have hx3 : (1:ℝ) / n ≤ 1 / 3 := by
    rw [div_le_div_iff₀ hn0 (by norm_num)]; linarith
  have hA : (0:ℝ) < 1 - 1 / n := by linarith
  have hB : (0:ℝ) < 1 - 2 / n := by
    rw [sub_pos, div_lt_one hn0]; linarith
  -- the expansion, multiplied by `n²`
  have expand : n ^ 2 * (Is n * Real.log 2) - Real.log n
      = 3 * n * (1 - 1 / n) * (-Real.log (1 - 1 / n))
        + n ^ 2 * (1 - 1 / n) * (1 - 2 / n) * Real.log ((1 - 2 / n) / (1 - 1 / n) ^ 2) := by
    rw [Is_eq_logSum (by linarith : (2:ℝ) ≤ n)]
    exact scale_expansion hne _ _
  -- ## the "exactly one factor splits" cells
  have hTaylor := log_two_term hx0 hx3
  have hcoef : (0:ℝ) ≤ 3 * n * (1 - 1 / n) := mul_nonneg (by linarith) (le_of_lt hA)
  have hstep1 : |3 * n * (1 - 1 / n) * (-Real.log (1 - 1 / n))
      - (3 - 3 / 2 * (1 / n) - 3 / 2 * (1 / n) ^ 2)| ≤ 9 / 2 * (1 / n) ^ 2 := by
    have hmain : 3 * n * (1 - 1 / n) * ((1 / n) + (1 / n) ^ 2 / 2)
        = 3 - 3 / 2 * (1 / n) - 3 / 2 * (1 / n) ^ 2 := by
      field_simp
      ring
    have hdiff : 3 * n * (1 - 1 / n) * (-Real.log (1 - 1 / n))
        - (3 - 3 / 2 * (1 / n) - 3 / 2 * (1 / n) ^ 2)
        = 3 * n * (1 - 1 / n) * ((-Real.log (1 - 1 / n)) - ((1 / n) + (1 / n) ^ 2 / 2)) := by
      rw [← hmain]; ring
    rw [hdiff, abs_mul, abs_of_nonneg hcoef]
    have hb : 3 * n * (1 - 1 / n) * |(-Real.log (1 - 1 / n)) - ((1 / n) + (1 / n) ^ 2 / 2)|
        ≤ 3 * n * (1 - 1 / n) * (3 / 2 * (1 / n) ^ 3) :=
      mul_le_mul_of_nonneg_left hTaylor hcoef
    have he : 3 * n * (1 - 1 / n) * (3 / 2 * (1 / n) ^ 3)
        = 9 / 2 * (1 / n) ^ 2 - 9 / 2 * (1 / n) ^ 3 := by
      field_simp
      ring
    have hpos : (0:ℝ) ≤ 9 / 2 * (1 / n) ^ 3 := by positivity
    linarith [he ▸ hb]
  -- ## the majority-class cell
  set w : ℝ := (1 / n) ^ 2 / (1 - 1 / n) ^ 2 with hwdef
  have hw0 : 0 ≤ w := by rw [hwdef]; positivity
  have hwq : w ≤ 1 / 4 := by
    rw [hwdef, div_le_div_iff₀ (by positivity) (by norm_num)]
    nlinarith [hx3, hx0, sq_nonneg (1 / n)]
  have hshape : (1 - 2 / n) / (1 - 1 / n) ^ 2 = 1 - w := by
    rw [hwdef]
    field_simp
    ring
  have hTaylor2 := log_one_term hw0 hwq
  have hK : (0:ℝ) ≤ n ^ 2 * (1 - 1 / n) * (1 - 2 / n) :=
    mul_nonneg (mul_nonneg (by positivity) (le_of_lt hA)) (le_of_lt hB)
  have hKw : n ^ 2 * (1 - 1 / n) * (1 - 2 / n) * w = (1 - 2 / n) / (1 - 1 / n) := by
    rw [hwdef]
    field_simp
  have hstep2 : |n ^ 2 * (1 - 1 / n) * (1 - 2 / n) * Real.log ((1 - 2 / n) / (1 - 1 / n) ^ 2)
      + (1 - 2 / n) / (1 - 1 / n)| ≤ 9 / 2 * (1 / n) ^ 2 := by
    have hdiff : n ^ 2 * (1 - 1 / n) * (1 - 2 / n) * Real.log ((1 - 2 / n) / (1 - 1 / n) ^ 2)
        + (1 - 2 / n) / (1 - 1 / n)
        = n ^ 2 * (1 - 1 / n) * (1 - 2 / n) * (Real.log (1 - w) + w) := by
      rw [hshape, ← hKw]; ring
    rw [hdiff, abs_mul, abs_of_nonneg hK]
    have hb : n ^ 2 * (1 - 1 / n) * (1 - 2 / n) * |Real.log (1 - w) + w|
        ≤ n ^ 2 * (1 - 1 / n) * (1 - 2 / n) * (4 / 3 * w ^ 2) :=
      mul_le_mul_of_nonneg_left hTaylor2 hK
    have he : n ^ 2 * (1 - 1 / n) * (1 - 2 / n) * (4 / 3 * w ^ 2)
        = 4 / 3 * ((1 - 2 / n) / (1 - 1 / n)) * w := by
      rw [← hKw]; ring
    have hbound : 4 / 3 * ((1 - 2 / n) / (1 - 1 / n)) * w ≤ 9 / 2 * (1 / n) ^ 2 := by
      have h1 : (1 - 2 / n) / (1 - 1 / n) ≤ 1 := by
        rw [div_le_one hA]
        have : (2:ℝ) / n = 2 * (1 / n) := by ring
        linarith [this]
      have hge : (2:ℝ) / 3 ≤ 1 - 1 / n := by linarith
      have hsq : (4:ℝ) / 9 ≤ (1 - 1 / n) ^ 2 := by nlinarith
      have h2 : w ≤ 9 / 4 * (1 / n) ^ 2 := by
        rw [hwdef, div_le_iff₀ (by positivity)]
        nlinarith [mul_le_mul_of_nonneg_left hsq (show (0:ℝ) ≤ 9 / 4 * (1 / n) ^ 2 by positivity)]
      have hsqn : (0:ℝ) ≤ (1 / n) ^ 2 := by positivity
      calc 4 / 3 * ((1 - 2 / n) / (1 - 1 / n)) * w
          ≤ 4 / 3 * 1 * w := by
            have := mul_le_mul_of_nonneg_right h1 hw0
            nlinarith [this]
        _ = 4 / 3 * w := by ring
        _ ≤ 4 / 3 * (9 / 4 * (1 / n) ^ 2) := by linarith
        _ ≤ 9 / 2 * (1 / n) ^ 2 := by linarith
    linarith [he ▸ hb]
  -- ## the elementary expansion of `(1 - 2x)/(1 - x)`
  have hstep3 : |(1 - 2 / n) / (1 - 1 / n) - (1 - 1 / n)| ≤ 3 / 2 * (1 / n) ^ 2 := by
    have he : (1 - 2 / n) / (1 - 1 / n) - (1 - 1 / n) = -((1 / n) ^ 2 / (1 - 1 / n)) := by
      field_simp
      ring
    rw [he, abs_neg, abs_of_nonneg (by positivity : (0:ℝ) ≤ (1 / n) ^ 2 / (1 - 1 / n))]
    rw [div_le_iff₀ hA]
    nlinarith [hx3, hx0, sq_nonneg (1 / n)]
  -- ## combine
  have e2 : 2 / n = 2 * (1 / n) := by ring
  have b1 := abs_le.mp hstep1
  have b2 := abs_le.mp hstep2
  have b3 := abs_le.mp hstep3
  rw [abs_le]
  constructor
  · rw [expand]; linarith [b1.1, b1.2, b2.1, b2.2, b3.1, b3.2]
  · rw [expand]; linarith [b1.1, b1.2, b2.1, b2.2, b3.1, b3.2]

/-- **The second-order limit.**  `n · (n² · Is n · log 2 − log n − 2) → −1/2`:
the constant `2` is approached from below, at exactly half the rate guaranteed
by `Is_const_bound`. -/
theorem Is_second_order :
    Tendsto (fun x : ℝ => x * (x ^ 2 * (Is x * Real.log 2) - Real.log x - 2)) atTop
      (nhds (-(1 / 2))) := by
  have hb : Tendsto (fun x : ℝ => 12 / x) atTop (nhds 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds tendsto_id
  have h : Tendsto
      (fun x : ℝ => x * (x ^ 2 * (Is x * Real.log 2) - Real.log x - 2) - -(1 / 2)) atTop
      (nhds 0) := by
    refine squeeze_zero_norm' ?_ hb
    filter_upwards [eventually_ge_atTop (3:ℝ)] with x hx
    have hx0 : (0:ℝ) < x := by linarith
    have hkey := Is_second_order_bound hx
    have heq : x * (x ^ 2 * (Is x * Real.log 2) - Real.log x - 2) - -(1 / 2)
        = x * (x ^ 2 * (Is x * Real.log 2) - Real.log x - 2 + 1 / 2 * (1 / x)) := by
      field_simp
      ring
    have hmul : |x * (x ^ 2 * (Is x * Real.log 2) - Real.log x - 2 + 1 / 2 * (1 / x))|
        ≤ x * (12 * (1 / x) ^ 2) := by
      rw [abs_mul, abs_of_pos hx0]
      exact mul_le_mul_of_nonneg_left hkey (le_of_lt hx0)
    have hval : x * (12 * (1 / x) ^ 2) = 12 / x := by
      field_simp
    rw [Real.norm_eq_abs, heq]
    linarith [hval ▸ hmul]
  have h2 := h.add_const (-(1 / 2))
  simpa using h2

end SplitCountSecondOrder