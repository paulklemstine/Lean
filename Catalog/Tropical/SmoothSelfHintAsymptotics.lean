import Tropical.SmoothSelfHintClosedForm

/-!
# The sharp rate of the symmetric leak

`SmoothSelfHintClosedForm` proves that the symmetric divisibility statistic leaks exactly
`symMI d` bits in a group of order `d`, and that `symMI d = O(1/d²) → 0`.  This file
sharpens the rate to an exact constant:

`d² · symMI d → log₂ e - 1 = 0.442695…`

* `SmoothSelfHint.log_div_bounds` — the two-sided estimate
  `(a-b)/a ≤ log(a/b) ≤ (a-b)/b`, both directions of `log x ≤ x - 1`.
* `SmoothSelfHint.symMI_envelope` — an explicit envelope for `d² · symMI d` whose two
  ends converge to the same limit.
* `SmoothSelfHint.symMI_asymptotic` — **the sharp rate**.

Numerically `d²·symMI d = 1.2451, 0.5741, 0.5181, 0.4837, 0.4463, 0.4431` at
`d = 2, 4, 6, 10, 100, 1000`, in agreement with the limit.  Interpretation: the visible
half of the asymmetric/symmetric dichotomy is visible only at small moduli — the leak of
`N mod l` about the symmetric divisibility event behaves like `(log₂ e - 1)/(l-1)²`.
-/

open Finset Filter Topology

namespace SmoothSelfHint

/-- Two-sided logarithm estimate: `(a-b)/a ≤ log(a/b) ≤ (a-b)/b` for positive `a, b`.
Both directions come from `log x ≤ x - 1`, applied to `a/b` and to `b/a`. -/
theorem log_div_bounds {a b : ℝ} (ha : 0 < a) (hb : 0 < b) :
    (a - b) / a ≤ Real.log (a / b) ∧ Real.log (a / b) ≤ (a - b) / b := by
  constructor
  · have h := Real.log_le_sub_one_of_pos (x := b / a) (by positivity)
    have hinv : Real.log (b / a) = - Real.log (a / b) := by
      rw [← Real.log_inv]; congr 1; field_simp
    have hval : b / a - 1 = -((a - b) / a) := by field_simp; ring
    rw [hinv, hval] at h
    linarith
  · have h := Real.log_le_sub_one_of_pos (x := a / b) (by positivity)
    have hval : a / b - 1 = (a - b) / b := by field_simp
    linarith [h, hval.ge, hval.le]

/-- Clearing the denominator of the closed form. -/
theorem symMI_mul_sq_eq {d : ℝ} (hd : 0 < d) :
    d ^ 2 * symMI d = Real.logb 2 (d / (2 * d - 1)) + (d - 1) * Real.logb 2 (d / (d - 1))
      + 2 * (d - 1) * Real.logb 2 (2 * d / (2 * d - 1))
      + (d - 1) * (d - 2) * Real.logb 2 (d * (d - 2) / (d - 1) ^ 2) := by
  rw [symMI]; field_simp

/-- **The envelope.**  For `d ≥ 3` the rescaled leak `d²·symMI d` is trapped between
`-1 + (1 - 1/(2d))·log₂ e` and `-1 + (1 + 1/(d-1))·log₂ e`. -/
theorem symMI_envelope {d : ℝ} (hd : 3 ≤ d) :
    -1 + (1 - 1 / (2 * d)) / Real.log 2 ≤ d ^ 2 * symMI d ∧
      d ^ 2 * symMI d ≤ -1 + (1 + 1 / (d - 1)) / Real.log 2 := by
  have hd0 : (0:ℝ) < d := by linarith
  have hd1 : (0:ℝ) < d - 1 := by linarith
  have hd2 : (0:ℝ) < d - 2 := by linarith
  have h2d1 : (0:ℝ) < 2 * d - 1 := by linarith
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hc1 : Real.logb 2 (d / (2 * d - 1)) = Real.logb 2 (2 * d / (2 * d - 1)) - 1 := by
    have hrw : d / (2 * d - 1) = (2 * d / (2 * d - 1)) / 2 := by field_simp
    rw [hrw, Real.logb_div (by positivity) (by norm_num)]
    simp
  obtain ⟨l2, u2⟩ := log_div_bounds (a := d) (b := d - 1) hd0 hd1
  rw [show d - (d - 1) = 1 from by ring] at l2 u2
  obtain ⟨l3, u3⟩ := log_div_bounds (a := 2 * d) (b := 2 * d - 1) (by linarith) h2d1
  rw [show 2 * d - (2 * d - 1) = 1 from by ring] at l3 u3
  obtain ⟨l4, u4⟩ := log_div_bounds (a := d * (d - 2)) (b := (d - 1) ^ 2)
    (by positivity) (by positivity)
  rw [show d * (d - 2) - (d - 1) ^ 2 = -1 from by ring] at l4 u4
  have hb2l : (1 / d) / Real.log 2 ≤ Real.logb 2 (d / (d - 1)) := by rw [Real.logb]; gcongr
  have hb2u : Real.logb 2 (d / (d - 1)) ≤ (1 / (d - 1)) / Real.log 2 := by
    rw [Real.logb]; gcongr
  have hb3l : (1 / (2 * d)) / Real.log 2 ≤ Real.logb 2 (2 * d / (2 * d - 1)) := by
    rw [Real.logb]; gcongr
  have hb3u : Real.logb 2 (2 * d / (2 * d - 1)) ≤ (1 / (2 * d - 1)) / Real.log 2 := by
    rw [Real.logb]; gcongr
  have hb4l : (-1 / (d * (d - 2))) / Real.log 2
      ≤ Real.logb 2 (d * (d - 2) / (d - 1) ^ 2) := by rw [Real.logb]; gcongr
  have hb4u : Real.logb 2 (d * (d - 2) / (d - 1) ^ 2) ≤ (-1 / (d - 1) ^ 2) / Real.log 2 := by
    rw [Real.logb]; gcongr
  have hA : ((d - 1) / d) / Real.log 2 ≤ (d - 1) * Real.logb 2 (d / (d - 1)) := by
    have hm := mul_le_mul_of_nonneg_left hb2l hd1.le
    calc ((d - 1) / d) / Real.log 2 = (d - 1) * ((1 / d) / Real.log 2) := by field_simp
      _ ≤ _ := hm
  have hA' : (d - 1) * Real.logb 2 (d / (d - 1)) ≤ 1 / Real.log 2 := by
    have hm := mul_le_mul_of_nonneg_left hb2u hd1.le
    calc (d - 1) * Real.logb 2 (d / (d - 1)) ≤ (d - 1) * ((1 / (d - 1)) / Real.log 2) := hm
      _ = 1 / Real.log 2 := by field_simp
  have hB : ((2 * d - 1) / (2 * d)) / Real.log 2
      ≤ (2 * d - 1) * Real.logb 2 (2 * d / (2 * d - 1)) := by
    have hm := mul_le_mul_of_nonneg_left hb3l h2d1.le
    calc ((2 * d - 1) / (2 * d)) / Real.log 2 = (2 * d - 1) * ((1 / (2 * d)) / Real.log 2) := by
          field_simp
      _ ≤ _ := hm
  have hB' : (2 * d - 1) * Real.logb 2 (2 * d / (2 * d - 1)) ≤ 1 / Real.log 2 := by
    have hm := mul_le_mul_of_nonneg_left hb3u h2d1.le
    calc (2 * d - 1) * Real.logb 2 (2 * d / (2 * d - 1))
        ≤ (2 * d - 1) * ((1 / (2 * d - 1)) / Real.log 2) := hm
      _ = 1 / Real.log 2 := by field_simp
  have hcoef : (0:ℝ) ≤ (d - 1) * (d - 2) := by nlinarith
  have hC : -(((d - 1) / d) / Real.log 2)
      ≤ (d - 1) * (d - 2) * Real.logb 2 (d * (d - 2) / (d - 1) ^ 2) := by
    have hm := mul_le_mul_of_nonneg_left hb4l hcoef
    refine le_trans ?_ hm
    have he : (d - 1) * (d - 2) * ((-1 / (d * (d - 2))) / Real.log 2)
        = -(((d - 1) / d) / Real.log 2) := by field_simp
    rw [he]
  have hC' : (d - 1) * (d - 2) * Real.logb 2 (d * (d - 2) / (d - 1) ^ 2)
      ≤ -(((d - 2) / (d - 1)) / Real.log 2) := by
    have hm := mul_le_mul_of_nonneg_left hb4u hcoef
    refine le_trans hm ?_
    have he : (d - 1) * (d - 2) * ((-1 / (d - 1) ^ 2) / Real.log 2)
        = -(((d - 2) / (d - 1)) / Real.log 2) := by field_simp
    rw [he]
  have hT : d ^ 2 * symMI d = -1 + (d - 1) * Real.logb 2 (d / (d - 1))
      + (2 * d - 1) * Real.logb 2 (2 * d / (2 * d - 1))
      + (d - 1) * (d - 2) * Real.logb 2 (d * (d - 2) / (d - 1) ^ 2) := by
    rw [symMI_mul_sq_eq hd0, hc1]; ring
  have eL : (1 - 1 / (2 * d)) / Real.log 2 = ((2 * d - 1) / (2 * d)) / Real.log 2 := by
    congr 1; field_simp
  have eU : (1 + 1 / (d - 1)) / Real.log 2
      = 1 / Real.log 2 + 1 / Real.log 2 - ((d - 2) / (d - 1)) / Real.log 2 := by
    field_simp; ring
  rw [hT, eL, eU]
  exact ⟨by linarith, by linarith⟩

/-- **The sharp rate.**  `d² · symMI d → log₂ e - 1 = 0.442695…`: the symmetric leak is
asymptotically `(log₂ e - 1)/d²` bits, so at modulus `l` it decays like `1/(l-1)²`. -/
theorem symMI_asymptotic :
    Tendsto (fun d : ℝ => d ^ 2 * symMI d) atTop (nhds (Real.logb 2 (Real.exp 1) - 1)) := by
  have hlogb : Real.logb 2 (Real.exp 1) = 1 / Real.log 2 := by
    rw [Real.logb, Real.log_exp]
  have hlow : Tendsto (fun d : ℝ => -1 + (1 - 1 / (2 * d)) / Real.log 2) atTop
      (nhds (-1 + 1 / Real.log 2)) := by
    have h1 : Tendsto (fun d : ℝ => 1 / (2 * d)) atTop (nhds 0) :=
      Filter.Tendsto.div_atTop tendsto_const_nhds
        (Filter.Tendsto.const_mul_atTop (by norm_num) tendsto_id)
    have h2 : Tendsto (fun d : ℝ => (1 - 1 / (2 * d)) / Real.log 2) atTop
        (nhds ((1 - 0) / Real.log 2)) := (tendsto_const_nhds.sub h1).div_const _
    simpa using h2.const_add (-1)
  have hup : Tendsto (fun d : ℝ => -1 + (1 + 1 / (d - 1)) / Real.log 2) atTop
      (nhds (-1 + 1 / Real.log 2)) := by
    have h1 : Tendsto (fun d : ℝ => 1 / (d - 1)) atTop (nhds 0) :=
      Filter.Tendsto.div_atTop tendsto_const_nhds
        (tendsto_atTop_add_const_right atTop (-1) tendsto_id)
    have h2 : Tendsto (fun d : ℝ => (1 + 1 / (d - 1)) / Real.log 2) atTop
        (nhds ((1 + 0) / Real.log 2)) := (tendsto_const_nhds.add h1).div_const _
    simpa using h2.const_add (-1)
  have hgoal : Real.logb 2 (Real.exp 1) - 1 = -1 + 1 / Real.log 2 := by
    rw [hlogb]; ring
  rw [hgoal]
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow hup ?_ ?_
  · filter_upwards [eventually_ge_atTop (3:ℝ)] with d hd using (symMI_envelope hd).1
  · filter_upwards [eventually_ge_atTop (3:ℝ)] with d hd using (symMI_envelope hd).2

end SmoothSelfHint