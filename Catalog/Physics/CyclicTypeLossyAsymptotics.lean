import Catalog.Physics.CyclicTypeTwoAdic

/-!
# The root-count readout dies: quantitative lossiness

`Catalog.Physics.CyclicTypeRootCountLossy` shows that the binary "splits completely or not"
readout `nr` is strictly lossier than the full splitting type at every composite cyclic order.
Here we make the loss quantitative and, along the 2-adic tower, total.

The binary readout has occupation numbers `[1, n−1]`, so its entropy is the binary entropy of
`1/n`; we bound it by `(log₂ n + 2)/n` and deduce that it vanishes as the cyclic order grows.
Combined with the 2-adic saturation `H(T)(2^k) → 2` this shows that along the `2`-tower the
root count eventually reports *none* of the two bits carried by the splitting type.

## Main results

* `CyclicType.Hnr_nonneg` : the binary readout has nonnegative entropy.
* `CyclicType.Hnr_le_bound` : `H(nr)(n) ≤ (log₂ n + 2)/n` for `n ≥ 2`.
* `CyclicType.Hnr_tendsto_zero` : `H(nr)(n) → 0`.
* `CyclicType.HT_sub_Hnr_two_pow_tendsto` : along the 2-adic tower the information *lost* by
  the root-count readout converges to the full two bits.
-/

set_option maxHeartbeats 1000000

namespace CyclicType

open Filter

variable {n : ℕ}

/-- The binary root-count readout has nonnegative entropy. -/
theorem Hnr_nonneg (hn : 0 < n) : 0 ≤ Hnr n := by
  rw [Hnr_eq_binary_entropy hn]
  rcases eq_or_lt_of_le (Nat.one_le_iff_ne_zero.2 hn.ne') with h1 | h2
  · rw [← h1]; norm_num
  have hn2 : 2 ≤ n := h2
  have hcast : ((n - 1 : ℕ) : ℝ) = (n : ℝ) - 1 := by
    have : 1 ≤ n := by omega
    push_cast [this]; ring
  rw [hcast]
  have hnR : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn2
  have hpos : (0 : ℝ) < (n : ℝ) := by linarith
  have hlogle : Real.logb 2 ((n : ℝ) - 1) ≤ Real.logb 2 (n : ℝ) :=
    Real.logb_le_logb_of_le (by norm_num) (by linarith) (by linarith)
  have hlognn : 0 ≤ Real.logb 2 ((n : ℝ) - 1) :=
    Real.logb_nonneg (by norm_num) (by linarith)
  have hw : ((n : ℝ) - 1) / (n : ℝ) ≤ 1 := by
    rw [div_le_one hpos]; linarith
  nlinarith

/-- **Quantitative lossiness.**  The binary readout carries at most `(log₂ n + 2)/n` bits. -/
theorem Hnr_le_bound (hn : 2 ≤ n) : Hnr n ≤ (Real.logb 2 n + 2) / (n : ℝ) := by
  have hnpos : 0 < n := by omega
  rw [Hnr_eq_binary_entropy hnpos]
  have hcast : ((n - 1 : ℕ) : ℝ) = (n : ℝ) - 1 := by
    have : 1 ≤ n := by omega
    push_cast [this]; ring
  rw [hcast]
  have hnR : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hpos : (0 : ℝ) < (n : ℝ) := by linarith
  have hm1 : (0 : ℝ) < (n : ℝ) - 1 := by linarith
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  -- the log-difference is at most `1/((n-1) log 2)`
  have hdiff : Real.logb 2 (n : ℝ) - Real.logb 2 ((n : ℝ) - 1)
      ≤ 1 / (((n : ℝ) - 1) * Real.log 2) := by
    have ht : (0 : ℝ) < (n : ℝ) / ((n : ℝ) - 1) := by positivity
    have hlog := Real.log_le_sub_one_of_pos ht
    have hexp : Real.log ((n : ℝ) / ((n : ℝ) - 1)) = Real.log n - Real.log ((n : ℝ) - 1) := by
      rw [Real.log_div (by positivity) hm1.ne']
    have hval : (n : ℝ) / ((n : ℝ) - 1) - 1 = 1 / ((n : ℝ) - 1) := by
      field_simp
      ring
    rw [hexp, hval] at hlog
    rw [Real.logb, Real.logb, div_sub_div_same, div_le_div_iff₀ hlog2 (by positivity)]
    have h2 : (0 : ℝ) < ((n : ℝ) - 1) := hm1
    have h3 : (Real.log n - Real.log ((n : ℝ) - 1)) * ((n : ℝ) - 1) ≤ 1 := by
      rw [← le_div_iff₀ h2]
      exact hlog
    nlinarith [mul_le_mul_of_nonneg_right h3 hlog2.le]
  -- rewrite the binary entropy in the "gain" form
  have hsplit : Real.logb 2 (n : ℝ) - ((n : ℝ) - 1) / (n : ℝ) * Real.logb 2 ((n : ℝ) - 1)
      = (1 / (n : ℝ)) * Real.logb 2 (n : ℝ)
        + (((n : ℝ) - 1) / (n : ℝ))
          * (Real.logb 2 (n : ℝ) - Real.logb 2 ((n : ℝ) - 1)) := by
    field_simp
    ring
  rw [hsplit]
  have hwpos : (0 : ℝ) < ((n : ℝ) - 1) / (n : ℝ) := by positivity
  have hstep : (((n : ℝ) - 1) / (n : ℝ))
      * (Real.logb 2 (n : ℝ) - Real.logb 2 ((n : ℝ) - 1))
      ≤ (((n : ℝ) - 1) / (n : ℝ)) * (1 / (((n : ℝ) - 1) * Real.log 2)) :=
    mul_le_mul_of_nonneg_left hdiff hwpos.le
  have hsimp : (((n : ℝ) - 1) / (n : ℝ)) * (1 / (((n : ℝ) - 1) * Real.log 2))
      = 1 / ((n : ℝ) * Real.log 2) := by
    field_simp
  rw [hsimp] at hstep
  have hlog2big : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hfinal : 1 / ((n : ℝ) * Real.log 2) ≤ 2 / (n : ℝ) := by
    rw [div_le_div_iff₀ (by positivity) hpos]
    nlinarith
  have hrw : (Real.logb 2 n + 2) / (n : ℝ)
      = (1 / (n : ℝ)) * Real.logb 2 (n : ℝ) + 2 / (n : ℝ) := by
    field_simp
  rw [hrw]
  linarith

/-- **The root-count readout dies.**  As the cyclic order grows the binary readout carries
vanishing information — all the structure lives in the multi-state splitting type. -/
theorem Hnr_tendsto_zero : Tendsto (fun n : ℕ => Hnr n) atTop (nhds 0) := by
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  -- `log x / x → 0` on the reals, transported to `ℕ`
  have hreal : Tendsto (fun x : ℝ => Real.log x / x) atTop (nhds 0) :=
    Real.isLittleO_log_id_atTop.tendsto_div_nhds_zero
  have hnat : Tendsto (fun n : ℕ => Real.log (n : ℝ) / (n : ℝ)) atTop (nhds 0) :=
    hreal.comp tendsto_natCast_atTop_atTop
  have hinv : Tendsto (fun n : ℕ => (2 : ℝ) / (n : ℝ)) atTop (nhds 0) := by
    simpa using (tendsto_natCast_atTop_atTop (R := ℝ)).inv_tendsto_atTop.const_mul (2 : ℝ)
  have hbound : Tendsto (fun n : ℕ => (Real.logb 2 n + 2) / (n : ℝ)) atTop (nhds 0) := by
    have hfun : (fun n : ℕ => (Real.logb 2 n + 2) / (n : ℝ))
        = fun n : ℕ => (Real.log 2)⁻¹ * (Real.log (n : ℝ) / (n : ℝ)) + 2 / (n : ℝ) := by
      funext n
      rw [Real.logb]
      ring
    rw [hfun]
    simpa using (hnat.const_mul (Real.log 2)⁻¹).add hinv
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hbound ?_ ?_
  · filter_upwards [eventually_ge_atTop 1] with n hn
    exact Hnr_nonneg (by omega)
  · filter_upwards [eventually_ge_atTop 2] with n hn
    exact Hnr_le_bound hn

/-- **Total loss along the 2-adic tower.**  The information discarded by the root-count
readout converges to the full two bits carried by the 2-primary type channel. -/
theorem HT_sub_Hnr_two_pow_tendsto :
    Tendsto (fun k : ℕ => HT (2 ^ k) - Hnr (2 ^ k)) atTop (nhds 2) := by
  have hpow : Tendsto (fun k : ℕ => 2 ^ k) atTop atTop :=
    tendsto_pow_atTop_atTop_of_one_lt (by norm_num)
  have h2 : Tendsto (fun k : ℕ => Hnr (2 ^ k)) atTop (nhds 0) :=
    Hnr_tendsto_zero.comp hpow
  simpa using HT_two_pow_tendsto.sub h2

end CyclicType