import Mathlib
import Novelty.SplitCountDecay

/-!
# The exact second-order constant of the split-count channel

`Catalog/Novelty/SplitCountDecay.lean` proves the sandwich

`(1 + log n) / (n² log 2) ≤ Is n ≤ (3 + log n) / (n² log 2)`,

i.e. `1 ≤ n² · Is n · log 2 − log n ≤ 3` for every real `n ≥ 2`, and deduces the
sharp rate `n² · Is n / log₂ n → 1`.  The sandwich leaves the *additive*
constant undetermined; numerically it looked like `2`.

This file closes that gap (Conjecture 4 of the previous cycle): the constant is
**exactly 2**, and the convergence happens at rate `2/n`:

* `Is_const_bound` : `|n² · Is n · log 2 − log n − 2| ≤ 2/n` for every `n ≥ 3`;
* `Is_exact_constant` : hence `n² · Is n · log 2 − log n → 2`;
* `Is_exact_constant_bits` : equivalently `n² · Is n − log₂ n → 2 / log 2`.

The mechanism is the exact four-cell expansion `Is_eq_logSum`: after multiplying
by `n²` the middle cell contributes `log n` on the nose, the "exactly one factor
splits" cells contribute `3·n·(1−1/n)·(−log(1−1/n)) ∈ [3 − 3/n, 3]`, and the
majority-class cell contributes `n²(1−1/n)(1−2/n)·log((1−2/n)/(1−1/n)²)`, which
lies in `[−(1−1/n), −(1−2/n)/(1−1/n)]` because
`(1−2/n)/(1−1/n)² = 1 − (1/n²)/(1−1/n)²`.  So the two corrections do **not**
cancel: `3 − 1 = 2`.

Every estimate comes from the single inequality `log t ≤ t − 1`, used once for
`t` and once for `1/t`, so the rate `2/n` is completely explicit.
-/

namespace SplitCountConstant

open Finset Real Filter SplitCountLaw SplitCountChannel SplitCountDecay

variable {n : ℝ}

/-- The reverse form of `log t ≤ t − 1`: `1 − 1/t ≤ log t` for `t > 0`. -/
lemma one_sub_inv_le_log {z : ℝ} (hz : 0 < z) : 1 - 1 / z ≤ Real.log z := by
  have h := Real.log_le_sub_one_of_pos (show (0:ℝ) < 1 / z by positivity)
  rw [Real.log_div one_ne_zero (ne_of_gt hz), Real.log_one, zero_sub] at h
  linarith

/-- Multiplying the four-cell expansion by `n²` is pure algebra in the two
logarithms `A = −log(1 − 1/n)` and `C = log((1 − 2/n)/(1 − 1/n)²)`. -/
lemma scale_expansion (hne : n ≠ 0) (A C : ℝ) :
    n ^ 2 * (3 * (1 / n) * (1 - 1 / n) * A + (1 / n) ^ 2 * Real.log n
        + (1 - 1 / n) * (1 - 2 / n) * C) - Real.log n
      = 3 * n * (1 - 1 / n) * A + n ^ 2 * (1 - 1 / n) * (1 - 2 / n) * C := by
  field_simp
  ring

/-- **The exact constant, with an explicit rate.**  For every real `n ≥ 3`,
`n² · Is n · log 2 − log n` differs from `2` by at most `2/n`. -/
theorem Is_const_bound (hn : 3 ≤ n) :
    |n ^ 2 * (Is n * Real.log 2) - Real.log n - 2| ≤ 2 / n := by
  have hn0 : (0:ℝ) < n := by linarith
  have hne : n ≠ 0 := ne_of_gt hn0
  have hn1 : n - 1 ≠ 0 := by intro h; rw [sub_eq_zero] at h; linarith
  have hn2 : n - 2 ≠ 0 := by intro h; rw [sub_eq_zero] at h; linarith
  have hA : (0:ℝ) < 1 - 1 / n := by rw [sub_pos, div_lt_one hn0]; linarith
  have hB : (0:ℝ) < 1 - 2 / n := by rw [sub_pos, div_lt_one hn0]; linarith
  -- the two logarithms of the expansion
  have expand : n ^ 2 * (Is n * Real.log 2) - Real.log n
      = 3 * n * (1 - 1 / n) * (-Real.log (1 - 1 / n))
        + n ^ 2 * (1 - 1 / n) * (1 - 2 / n) * Real.log ((1 - 2 / n) / (1 - 1 / n) ^ 2) := by
    rw [Is_eq_logSum (by linarith : (2:ℝ) ≤ n)]
    exact scale_expansion hne _ _
  have hL1 : 1 / n ≤ -Real.log (1 - 1 / n) := by
    have h := Real.log_le_sub_one_of_pos hA
    linarith
  have hL2 : -Real.log (1 - 1 / n) ≤ (1 / n) / (1 - 1 / n) := by
    have h := one_sub_inv_le_log hA
    have e : 1 - 1 / (1 - 1 / n) = -((1 / n) / (1 - 1 / n)) := by
      field_simp; ring
    rw [e] at h
    linarith
  have hzpos : (0:ℝ) < (1 - 2 / n) / (1 - 1 / n) ^ 2 := by positivity
  have hM1 : Real.log ((1 - 2 / n) / (1 - 1 / n) ^ 2) ≤ -((1 / n ^ 2) / (1 - 1 / n) ^ 2) := by
    have h := Real.log_le_sub_one_of_pos hzpos
    have e : (1 - 2 / n) / (1 - 1 / n) ^ 2 - 1 = -((1 / n ^ 2) / (1 - 1 / n) ^ 2) := by
      field_simp; ring
    linarith [e ▸ h]
  have hM2 : -((1 / n ^ 2) / (1 - 2 / n)) ≤ Real.log ((1 - 2 / n) / (1 - 1 / n) ^ 2) := by
    have h := one_sub_inv_le_log hzpos
    have e : 1 - 1 / ((1 - 2 / n) / (1 - 1 / n) ^ 2) = -((1 / n ^ 2) / (1 - 2 / n)) := by
      rw [one_div_div]
      field_simp; ring
    linarith [e ▸ h]
  -- the "exactly one factor splits" cells: between `3 - 3/n` and `3`
  have hc1 : (0:ℝ) ≤ 3 * n * (1 - 1 / n) :=
    mul_nonneg (by linarith) (le_of_lt hA)
  have hT1lo : 3 - 3 * (1 / n) ≤ 3 * n * (1 - 1 / n) * (-Real.log (1 - 1 / n)) := by
    have h := mul_le_mul_of_nonneg_left hL1 hc1
    have e : 3 * n * (1 - 1 / n) * (1 / n) = 3 - 3 * (1 / n) := by
      field_simp
    linarith [e ▸ h]
  have hT1hi : 3 * n * (1 - 1 / n) * (-Real.log (1 - 1 / n)) ≤ 3 := by
    have h := mul_le_mul_of_nonneg_left hL2 hc1
    have e : 3 * n * (1 - 1 / n) * ((1 / n) / (1 - 1 / n)) = 3 := by
      field_simp
    linarith [e ▸ h]
  -- the majority-class cell: between `-(1 - 1/n)` and `-(1 - 2/n)/(1 - 1/n)`
  have hc2 : (0:ℝ) ≤ n ^ 2 * (1 - 1 / n) * (1 - 2 / n) :=
    mul_nonneg (mul_nonneg (by positivity) (le_of_lt hA)) (le_of_lt hB)
  have hT2hi : n ^ 2 * (1 - 1 / n) * (1 - 2 / n) * Real.log ((1 - 2 / n) / (1 - 1 / n) ^ 2)
      ≤ -((1 - 2 / n) / (1 - 1 / n)) := by
    have h := mul_le_mul_of_nonneg_left hM1 hc2
    have e : n ^ 2 * (1 - 1 / n) * (1 - 2 / n) * -((1 / n ^ 2) / (1 - 1 / n) ^ 2)
        = -((1 - 2 / n) / (1 - 1 / n)) := by
      field_simp
    linarith [e ▸ h]
  have hT2lo : -(1 - 1 / n)
      ≤ n ^ 2 * (1 - 1 / n) * (1 - 2 / n) * Real.log ((1 - 2 / n) / (1 - 1 / n) ^ 2) := by
    have h := mul_le_mul_of_nonneg_left hM2 hc2
    have e : n ^ 2 * (1 - 1 / n) * (1 - 2 / n) * -((1 / n ^ 2) / (1 - 2 / n))
        = -(1 - 1 / n) := by
      field_simp
    linarith [e ▸ h]
  -- `(1 - 2/n)/(1 - 1/n) ≥ 1 - 2/n`, because the denominator is `< 1`
  have h1n : (0:ℝ) ≤ 1 / n := by positivity
  have hratio : 1 - 2 / n ≤ (1 - 2 / n) / (1 - 1 / n) := by
    rw [le_div_iff₀ hA]
    nlinarith [mul_nonneg hB.le h1n]
  -- normalise the atoms `2/n` so that `linarith` can combine the cells
  have e2 : 2 / n = 2 * (1 / n) := by ring
  rw [abs_le]
  constructor
  · rw [expand]; linarith
  · rw [expand]; linarith

/-- **Conjecture 4 of the previous cycle, now a theorem.**
`n² · Is n · log 2 − log n → 2`: the additive constant in the sharp decay law is
exactly `2`, namely the `+3` of the three "exactly one factor splits" cells plus
the `−1` of the majority-class cell. -/
theorem Is_exact_constant :
    Tendsto (fun x : ℝ => x ^ 2 * (Is x * Real.log 2) - Real.log x) atTop (nhds 2) := by
  have hb : Tendsto (fun x : ℝ => 2 / x) atTop (nhds 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds tendsto_id
  have h : Tendsto (fun x : ℝ => x ^ 2 * (Is x * Real.log 2) - Real.log x - 2) atTop (nhds 0) := by
    refine squeeze_zero_norm' ?_ hb
    filter_upwards [eventually_ge_atTop (3:ℝ)] with x hx
    simpa [Real.norm_eq_abs] using Is_const_bound hx
  have h2 := h.add_const 2
  simpa using h2

/-- The same law in bits: `n² · Is n − log₂ n → 2 / log 2 ≈ 2.885`. -/
theorem Is_exact_constant_bits :
    Tendsto (fun x : ℝ => x ^ 2 * Is x - Real.logb 2 x) atTop (nhds (2 / Real.log 2)) := by
  have hl2 : Real.log 2 ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
  have h := Is_exact_constant.div_const (Real.log 2)
  refine h.congr fun x => ?_
  rw [Real.logb]
  field_simp

end SplitCountConstant