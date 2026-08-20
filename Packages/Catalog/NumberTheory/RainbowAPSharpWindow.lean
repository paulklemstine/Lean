import Mathlib
import Catalog.Shared.RainbowAPPairThreshold

/-!
# The sharp window: `T(N) = N log N + O(N)` and `T_k = 2 k² log k + O(k²)`

The two criteria are close enough that the threshold is pinned down to an additive window of
width `O(N)` around the coupon-collector value `N log N`; in the pair-spectrum normalisation
this says that the leading constant `2` in front of `k² log k` is exact and that the error is
`O(k²)`, i.e. a factor `log k` smaller than the main term.
-/

open Real

namespace RainbowAP

variable {α : Type*} [Fintype α] [DecidableEq α]

lemma log_succ_le (N : ℕ) (hN : 2 ≤ N) :
    Real.log ((N : ℝ) + 1) ≤ Real.log (N : ℝ) + 1 := by
  have hNge : (2 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN
  have hpos : (0 : ℝ) < ((N : ℝ) + 1) / (N : ℝ) := by positivity
  have hle := Real.log_le_sub_one_of_pos hpos
  have hdiv : Real.log (((N : ℝ) + 1) / (N : ℝ)) = Real.log ((N : ℝ) + 1) - Real.log (N : ℝ) := by
    rw [Real.log_div (by linarith) (by linarith)]
  have hval : ((N : ℝ) + 1) / (N : ℝ) - 1 = 1 / (N : ℝ) := by
    field_simp
    ring
  have h1 : 1 / (N : ℝ) ≤ 1 := by
    rw [div_le_one (by linarith)]
    linarith
  linarith [hle, hdiv.le, hdiv.ge, hval.le, hval.ge, h1]

/-- **Sharp window for a general alphabet.**  The full-spectrum threshold sits within an
additive `N log 2 + log N + 1` of the coupon-collector value `N log N`. -/
theorem spectrumThreshold_window (hN : 2 ≤ Fintype.card α) :
    |(spectrumThreshold α : ℝ) - (Fintype.card α : ℝ) * Real.log (Fintype.card α)|
      ≤ (Fintype.card α : ℝ) * Real.log 2 + Real.log (Fintype.card α) + 1 := by
  have hNge : (2 : ℝ) ≤ (Fintype.card α : ℝ) := by exact_mod_cast hN
  have hlogN : (0 : ℝ) ≤ Real.log (Fintype.card α) := Real.log_nonneg (by linarith)
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hlow := le_spectrumThreshold (α := α) hN
  have hupp := spectrumThreshold_le (α := α) hN
  have hsplit : Real.log (2 * (Fintype.card α : ℝ))
      = Real.log 2 + Real.log (Fintype.card α) := by
    rw [Real.log_mul (by norm_num) (by linarith)]
  rw [hsplit] at hupp
  have hmono : Real.log (Fintype.card α) ≤ Real.log ((Fintype.card α : ℝ) + 1) :=
    Real.log_le_log (by linarith) (by linarith)
  have hsucc := log_succ_le (Fintype.card α) hN
  have hlow' : (Fintype.card α : ℝ) * Real.log (Fintype.card α)
      - (Real.log (Fintype.card α) + 1) ≤ (spectrumThreshold α : ℝ) := by
    nlinarith [hlow, hmono, hsucc, hlogN, hNge]
  rw [abs_le]
  constructor
  · nlinarith [hlow', hlog2, hNge, hlogN]
  · nlinarith [hupp, hlogN, hlog2]

/-- **Sharp window for the rainbow pair-spectrum threshold.**
`T k = 2 k² log k + O(k²)`, so the constant `2` is the exact asymptotic constant. -/
theorem T_window (k : ℕ) (hk : 2 ≤ k) :
    |(T k : ℝ) - 2 * (k : ℝ) ^ 2 * Real.log k|
      ≤ (k : ℝ) ^ 2 * Real.log 2 + 2 * Real.log k + 1 := by
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hlogk : (0 : ℝ) ≤ Real.log k := Real.log_nonneg (by linarith)
  have hlow := T_lower_bound k hk
  have hupp := T_upper_bound k hk
  have hpos2 : (0 : ℝ) ≤ (k : ℝ) ^ 2 * Real.log 2 := by
    have : (0 : ℝ) ≤ Real.log 2 := Real.log_nonneg (by norm_num)
    positivity
  rw [abs_le]
  constructor <;> nlinarith [hlow, hupp, hlogk, hpos2]

/-- **Sharpened constants.** For `k ≥ 100` the constants can be taken within `10%` of the
optimal value `2`: `1.9 k² log k ≤ T k ≤ 2.2 k² log k`. -/
theorem T_theta_sharp (k : ℕ) (hk : 100 ≤ k) :
    1.9 * ((k : ℝ) ^ 2 * Real.log k) ≤ (T k : ℝ) ∧
      (T k : ℝ) ≤ 2.2 * ((k : ℝ) ^ 2 * Real.log k) := by
  have hkR : (100 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hk2 : 2 ≤ k := by omega
  have hlow := T_lower_bound k hk2
  have hupp := T_upper_bound k hk2
  have hlog2u : Real.log 2 < 0.6932 := by
    have := Real.log_two_lt_d9
    linarith
  have hlog2l : (0.6931 : ℝ) < Real.log 2 := by
    have := Real.log_two_gt_d9
    linarith
  have hlogk6 : 6 * Real.log 2 ≤ Real.log k := by
    have h64 : Real.log ((2 : ℝ) ^ (6 : ℕ)) ≤ Real.log k :=
      Real.log_le_log (by norm_num) (by norm_num; linarith)
    rwa [Real.log_pow] at h64
  have hlogk : (0 : ℝ) ≤ Real.log k := by linarith
  have hksq : (10000 : ℝ) ≤ (k : ℝ) ^ 2 := by nlinarith
  constructor
  · nlinarith [hlow, hlogk, hksq]
  · nlinarith [hupp, hlogk, hksq, hlog2u, hlogk6, hlog2l]

end RainbowAP