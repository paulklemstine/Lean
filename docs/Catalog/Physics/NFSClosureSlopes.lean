import Mathlib

/-!
# NFS closure, channel 3: the "inversion" headline is refuted by its own slopes

Round 44's sparse-linear-algebra miner claimed an *inversion*: that relation surplus
outgrows matrix width, so extra consumption eventually pays for itself.  Refuter B used the
miner's own numbers: surplus grew by a factor `7.94` while the width grew by `5.30`, giving
the log–log slope `log 7.94 / log 5.30 = 1.242`, against a width cost `~ W ^ 1.819`.

This file proves:

* `loglog_slope_of_powerLaw` : on an exact power law `a W^s`, the two-point log–log slope is
  exactly `s` (so the refuters' slope estimator is the right one);
* `surplus_slope_bounds` : `6/5 < log 7.94 / log 5.30 < 5/4` — rigorously, from
  `7.94^4 < 5.3^5` and `5.3^6 < 7.94^5`;
* `surplus_slope_lt_width_slope` : hence the surplus slope is strictly below `1.819`;
* `no_inversion` : for power laws `S = a W^s`, `C = b W^t` with `0 < s < t` (both positive,
  cost steeper) the ratio `S / C` is strictly decreasing; once the cost catches the surplus
  at some width, it stays ahead at every larger width — **there is no inversion at any
  consumption level** — and `S / C → 0`.
* `round44_no_inversion` : the instance `s = log 7.94 / log 5.30`, `t = 1.819`.
-/

namespace Physics.NFSClosure

open Filter Real
open scoped Topology

/-- A two-point log–log slope estimator. -/
noncomputable def loglogSlope (W₁ W₂ S₁ S₂ : ℝ) : ℝ :=
  Real.log (S₂ / S₁) / Real.log (W₂ / W₁)

/-- On an exact power law the two-point log–log slope recovers the exponent. -/
theorem loglog_slope_of_powerLaw {a s W₁ W₂ : ℝ} (ha : 0 < a) (h₁ : 0 < W₁) (h₂ : 0 < W₂)
    (hne : W₁ ≠ W₂) : loglogSlope W₁ W₂ (a * W₁ ^ s) (a * W₂ ^ s) = s := by
  unfold loglogSlope
  have hq : 0 < W₂ / W₁ := div_pos h₂ h₁
  have hratio : a * W₂ ^ s / (a * W₁ ^ s) = (W₂ / W₁) ^ s := by
    rw [Real.div_rpow h₂.le h₁.le]
    field_simp
  have hlog : Real.log (W₂ / W₁) ≠ 0 := by
    intro h0
    rcases Real.log_eq_zero.mp h0 with h | h | h
    · linarith
    · exact hne ((div_eq_one_iff_eq h₁.ne').mp h).symm
    · linarith
  rw [hratio, Real.log_rpow hq, mul_div_assoc, div_self hlog, mul_one]

/-- The surplus slope reported in round 44. -/
noncomputable def surplusSlope : ℝ := Real.log (794 / 100) / Real.log (53 / 10)

/-- The width-cost exponent reported in round 44. -/
noncomputable def widthSlope : ℝ := 1819 / 1000

/-- **Rigorous bracket of the surplus slope**: `6/5 < log 7.94 / log 5.30 < 5/4`. -/
theorem surplus_slope_bounds : 6 / 5 < surplusSlope ∧ surplusSlope < 5 / 4 := by
  have hW : 0 < Real.log (53 / 10 : ℝ) := Real.log_pos (by norm_num)
  have hup : 4 * Real.log (794 / 100 : ℝ) < 5 * Real.log (53 / 10 : ℝ) := by
    have h1 := Real.log_pow (794 / 100 : ℝ) 4
    have h2 := Real.log_pow (53 / 10 : ℝ) 5
    have h3 : Real.log ((794 / 100 : ℝ) ^ 4) < Real.log ((53 / 10 : ℝ) ^ 5) :=
      Real.log_lt_log (by norm_num) (by norm_num)
    push_cast at h1 h2
    linarith
  have hlo : 6 * Real.log (53 / 10 : ℝ) < 5 * Real.log (794 / 100 : ℝ) := by
    have h1 := Real.log_pow (53 / 10 : ℝ) 6
    have h2 := Real.log_pow (794 / 100 : ℝ) 5
    have h3 : Real.log ((53 / 10 : ℝ) ^ 6) < Real.log ((794 / 100 : ℝ) ^ 5) :=
      Real.log_lt_log (by norm_num) (by norm_num)
    push_cast at h1 h2
    linarith
  unfold surplusSlope
  constructor
  · rw [lt_div_iff₀ hW]; linarith
  · rw [div_lt_iff₀ hW]; linarith

/-- Both slopes are positive (surplus *and* width grow) and the width is strictly dearer. -/
theorem surplus_slope_lt_width_slope : 0 < surplusSlope ∧ surplusSlope < widthSlope := by
  obtain ⟨h1, h2⟩ := surplus_slope_bounds
  unfold widthSlope
  constructor <;> linarith

/-- **No inversion.**  Surplus `a W^s` and cost `b W^t` with `0 < s < t`, `a, b > 0`:
(1) both grow strictly; (2) the surplus-to-cost ratio strictly decreases;
(3) once the cost reaches the surplus it stays ahead forever; (4) the ratio tends to `0`. -/
theorem no_inversion {a b s t : ℝ} (ha : 0 < a) (hb : 0 < b) (hs : 0 < s) (hst : s < t) :
    (∀ W₁ W₂ : ℝ, 0 < W₁ → W₁ < W₂ → a * W₁ ^ s < a * W₂ ^ s ∧ b * W₁ ^ t < b * W₂ ^ t) ∧
    (∀ W₁ W₂ : ℝ, 0 < W₁ → W₁ < W₂ →
        a * W₂ ^ s / (b * W₂ ^ t) < a * W₁ ^ s / (b * W₁ ^ t)) ∧
    (∀ W₀ W : ℝ, 0 < W₀ → W₀ ≤ W → a * W₀ ^ s ≤ b * W₀ ^ t → a * W ^ s ≤ b * W ^ t) ∧
    Tendsto (fun W => a * W ^ s / (b * W ^ t)) atTop (𝓝 0) := by
  have ht : 0 < t := lt_trans hs hst
  have hratio : ∀ W : ℝ, 0 < W → a * W ^ s / (b * W ^ t) = (a / b) * W ^ (-(t - s)) := by
    intro W hW
    rw [Real.rpow_neg hW.le, Real.rpow_sub hW]
    have := Real.rpow_pos_of_pos hW s
    have := Real.rpow_pos_of_pos hW t
    field_simp
  have hdec : ∀ W₁ W₂ : ℝ, 0 < W₁ → W₁ < W₂ →
      a * W₂ ^ s / (b * W₂ ^ t) < a * W₁ ^ s / (b * W₁ ^ t) := by
    intro W₁ W₂ h₁ h₁₂
    have h₂ : 0 < W₂ := lt_trans h₁ h₁₂
    rw [hratio W₁ h₁, hratio W₂ h₂]
    apply mul_lt_mul_of_pos_left _ (div_pos ha hb)
    rw [Real.rpow_neg h₁.le, Real.rpow_neg h₂.le]
    exact inv_strictAnti₀ (Real.rpow_pos_of_pos h₁ _)
      (Real.rpow_lt_rpow h₁.le h₁₂ (by linarith))
  refine ⟨?_, hdec, ?_, ?_⟩
  · intro W₁ W₂ h₁ h₁₂
    exact ⟨mul_lt_mul_of_pos_left (Real.rpow_lt_rpow h₁.le h₁₂ hs) ha,
      mul_lt_mul_of_pos_left (Real.rpow_lt_rpow h₁.le h₁₂ ht) hb⟩
  · intro W₀ W h₀ h₀W hcatch
    have hW : 0 < W := lt_of_lt_of_le h₀ h₀W
    have hC0 : 0 < b * W₀ ^ t := mul_pos hb (Real.rpow_pos_of_pos h₀ t)
    have hC : 0 < b * W ^ t := mul_pos hb (Real.rpow_pos_of_pos hW t)
    have h1 : a * W₀ ^ s / (b * W₀ ^ t) ≤ 1 := (div_le_one hC0).mpr hcatch
    rcases h₀W.lt_or_eq with hlt | heq
    · have := hdec W₀ W h₀ hlt
      exact (div_le_one hC).mp (by linarith)
    · rw [← heq]; exact hcatch
  · have hlim : Tendsto (fun W : ℝ => (a / b) * W ^ (-(t - s))) atTop (𝓝 0) := by
      have := (tendsto_rpow_neg_atTop (by linarith : 0 < t - s)).const_mul (a / b)
      simpa using this
    refine hlim.congr' ?_
    filter_upwards [eventually_gt_atTop (0:ℝ)] with W hW
    rw [hratio W hW]

/-- **Round-44 instance of no inversion**: with the miner's own surplus slope
`log 7.94 / log 5.30` and width exponent `1.819`, the surplus-to-cost ratio decreases
strictly and tends to `0`, for every choice of positive prefactors. -/
theorem round44_no_inversion {a b : ℝ} (ha : 0 < a) (hb : 0 < b) :
    (∀ W₁ W₂ : ℝ, 0 < W₁ → W₁ < W₂ →
        a * W₂ ^ surplusSlope / (b * W₂ ^ widthSlope) <
          a * W₁ ^ surplusSlope / (b * W₁ ^ widthSlope)) ∧
    Tendsto (fun W => a * W ^ surplusSlope / (b * W ^ widthSlope)) atTop (𝓝 0) := by
  obtain ⟨hs, hst⟩ := surplus_slope_lt_width_slope
  obtain ⟨-, h2, -, h4⟩ := no_inversion ha hb hs hst
  exact ⟨h2, h4⟩

end Physics.NFSClosure