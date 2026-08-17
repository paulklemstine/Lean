/-
# The calibration defect's exact constant: `defect r · √r → 1/(2√π)`

Conjecture **E1** of `FUTURE_DIRECTIONS.md`, limit half.  Cycle 4 pinned the calibration defect
of an even seed ensemble between `1/(2√(4r+1))` and `1/(2√(3r+1))`, hence
`defect r · √r ∈ [1/(2√5), 1/(2√3)] = [0.2236, 0.2887]` for every `r ≥ 1`
(`SeedStirling.defect_sqrt_bracket`), but left the constant unidentified.  This file identifies
it: the limit is the Wallis constant `1/(2√π) = 0.28209…`.

Main results.

* `SeedWallis.stirling_ratio_eq` — the exact algebraic identity behind the asymptotics: for
  `r ≥ 1`, `stirlingSeq (2r) / (stirlingSeq r)^2 = C(2r,r)·√r/4^r`, where `stirlingSeq` is
  Mathlib's Stirling sequence.  No analysis: the factorials cancel through
  `Nat.centralBinom`.
* `SeedWallis.centralBinom_sqrt_limit` — consequently `C(2r,r)·√r/4^r → 1/√π`.
* `SeedWallis.defect_sqrt_tendsto` — **the constant of the defect**:
  `defect r · √r → 1/(2√π)`.
* `SeedWallis.limit_in_bracket` — the two cycles agree: the limit lies inside cycle 4's proved
  window `[1/(2√5), 1/(2√3)]`, which is exactly the statement `3 ≤ π ≤ 5` read off the
  ensemble ladder rather than the circle.
* `SeedWallis.defect_asymptotic` — the deployment form: for every `ε > 0` the defect of a
  `2r`-seed ensemble is eventually within `ε·r^(-1/2)` of `1/(2√(π r))`.
-/

import Mathlib
import Probability.SeedCentralBinomSandwich

namespace SeedWallis

open Filter Real SeedQuota
open scoped Topology Nat

/-! ## 1.  The exact identity -/

private theorem factorial_ne_zero (r : ℕ) : ((r ! : ℝ)) ≠ 0 := by
  exact_mod_cast Nat.factorial_ne_zero r

/-- The central binomial coefficient factors the factorials of the Stirling sequence. -/
theorem centralBinom_mul_factorial_sq (r : ℕ) :
    ((2 * r)! : ℝ) = (Nat.centralBinom r : ℝ) * (r ! : ℝ) ^ 2 := by
  have h := Nat.choose_mul_factorial_mul_factorial (Nat.le_mul_of_pos_left r (by norm_num : 0 < 2))
  have h2 : 2 * r - r = r := by omega
  rw [h2] at h
  have hc : Nat.centralBinom r = (2 * r).choose r := by
    simp [Nat.centralBinom, two_mul]
  rw [hc]
  have := congrArg (fun t : ℕ => (t : ℝ)) h
  push_cast at this
  rw [← this]
  ring

/-- **The exact identity.**  For `r ≥ 1` the ratio of Stirling sequences at `2r` and `r` is the
normalised central binomial coefficient.  All the factorials and all the `(·/e)` powers
cancel. -/
theorem stirling_ratio_eq {r : ℕ} (hr : 1 ≤ r) :
    Stirling.stirlingSeq (2 * r) / (Stirling.stirlingSeq r) ^ 2
      = (Nat.centralBinom r : ℝ) * Real.sqrt r / 4 ^ r := by
  have hr0 : (0 : ℝ) < r := by exact_mod_cast hr
  have hfac : ((r ! : ℝ)) ≠ 0 := factorial_ne_zero r
  have hA : ((r : ℝ) / Real.exp 1) ^ r ≠ 0 := by positivity
  -- the two square roots
  have hs2 : Real.sqrt (2 * ((2 * r : ℕ) : ℝ)) = 2 * Real.sqrt r := by
    have h : ((2 * ((2 * r : ℕ)) : ℝ)) = 2 ^ 2 * r := by push_cast; ring
    rw [h, Real.sqrt_mul (by positivity), Real.sqrt_sq (by norm_num)]
  have hsr : Real.sqrt (2 * (r : ℝ)) = Real.sqrt 2 * Real.sqrt r := Real.sqrt_mul (by norm_num) _
  -- the two `(·/e)` powers
  have hpw : (((2 * r : ℕ) : ℝ) / Real.exp 1) ^ (2 * r)
      = 4 ^ r * (((r : ℝ) / Real.exp 1) ^ r) ^ 2 := by
    have h1 : (((2 * r : ℕ) : ℝ) / Real.exp 1) = 2 * ((r : ℝ) / Real.exp 1) := by push_cast; ring
    have h2 : (2 : ℝ) ^ (2 * r) = 4 ^ r := by rw [pow_mul]; norm_num
    rw [h1, mul_pow, h2, ← pow_mul]
    ring_nf
  have h2sq : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hrsq : Real.sqrt (r : ℝ) ^ 2 = r := Real.sq_sqrt hr0.le
  have hrpos : Real.sqrt (r : ℝ) ≠ 0 := by positivity
  rw [Stirling.stirlingSeq, Stirling.stirlingSeq, hs2, hpw, centralBinom_mul_factorial_sq, hsr]
  field_simp
  nlinarith [h2sq, hrsq, sq_nonneg (Real.sqrt r)]

/-! ## 2.  The limit -/

theorem tendsto_stirlingSeq_two_mul :
    Tendsto (fun r : ℕ => Stirling.stirlingSeq (2 * r)) atTop (𝓝 (Real.sqrt π)) := by
  refine Stirling.tendsto_stirlingSeq_sqrt_pi.comp ?_
  exact Filter.tendsto_atTop_mono (fun r => Nat.le_mul_of_pos_left r (by norm_num)) tendsto_id

/-- **The normalised central binomial coefficient converges to `1/√π`.** -/
theorem centralBinom_sqrt_limit :
    Tendsto (fun r : ℕ => (Nat.centralBinom r : ℝ) * Real.sqrt r / 4 ^ r) atTop
      (𝓝 (1 / Real.sqrt π)) := by
  have hpi : Real.sqrt π ≠ 0 := by positivity
  have hlim : Tendsto
      (fun r : ℕ => Stirling.stirlingSeq (2 * r) / (Stirling.stirlingSeq r) ^ 2) atTop
      (𝓝 (Real.sqrt π / (Real.sqrt π) ^ 2)) :=
    tendsto_stirlingSeq_two_mul.div (Stirling.tendsto_stirlingSeq_sqrt_pi.pow 2) (by positivity)
  have hval : Real.sqrt π / (Real.sqrt π) ^ 2 = 1 / Real.sqrt π := by
    rw [sq]
    field_simp
  rw [hval] at hlim
  refine hlim.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with r hr using stirling_ratio_eq hr

/-- **The calibration defect's exact constant.**  `defect r · √r → 1/(2√π)`: the `r^(-1/2)`
rate proved in cycle 4 has Wallis' constant, and the even-ensemble bias is asymptotically
`1/(2√(π r))`. -/
theorem defect_sqrt_tendsto :
    Tendsto (fun r : ℕ => defect r * Real.sqrt r) atTop (𝓝 (1 / (2 * Real.sqrt π))) := by
  have h := centralBinom_sqrt_limit.const_mul (1 / 2 : ℝ)
  have hval : (1 / 2 : ℝ) * (1 / Real.sqrt π) = 1 / (2 * Real.sqrt π) := by
    field_simp
  rw [hval] at h
  refine h.congr fun r => ?_
  unfold defect
  have h4 : (2 : ℝ) ^ (2 * r + 1) = 2 * 4 ^ r := by
    rw [pow_succ, pow_mul]
    norm_num [mul_comm]
  rw [h4]
  have hc : ((2 * r).choose r : ℝ) = (Nat.centralBinom r : ℝ) := by
    simp [Nat.centralBinom, two_mul]
  rw [hc]
  field_simp

/-! ## 3.  Consistency with the proved window, and the deployment form -/

/-- **The two cycles agree.**  The Wallis constant lies inside the window cycle 4 proved by pure
induction: `1/(2√5) ≤ 1/(2√π) ≤ 1/(2√3)`.  Read backwards this is `3 ≤ π ≤ 5`, obtained here
from the calibration defects of seed ensembles rather than from the circle. -/
theorem limit_in_bracket :
    1 / (2 * Real.sqrt 5) ≤ 1 / (2 * Real.sqrt π) ∧
      1 / (2 * Real.sqrt π) ≤ 1 / (2 * Real.sqrt 3) := by
  constructor
  · refine le_of_tendsto_of_tendsto tendsto_const_nhds defect_sqrt_tendsto ?_
    filter_upwards [eventually_ge_atTop 1] with r hr using (SeedStirling.defect_sqrt_bracket hr).1
  · refine le_of_tendsto_of_tendsto defect_sqrt_tendsto tendsto_const_nhds ?_
    filter_upwards [eventually_ge_atTop 1] with r hr using (SeedStirling.defect_sqrt_bracket hr).2

/-- **Deployment form.**  For every tolerance `ε > 0` the calibration defect of a `2r`-seed
ensemble is eventually within `ε` of `1/(2√(π r))` after rescaling by `√r`: the bias of an even
ensemble is `(1 + o(1))/(2√(π r))`. -/
theorem defect_asymptotic {ε : ℝ} (hε : 0 < ε) :
    ∀ᶠ r : ℕ in atTop, |defect r * Real.sqrt r - 1 / (2 * Real.sqrt π)| < ε := by
  have h := defect_sqrt_tendsto
  rw [Metric.tendsto_atTop] at h
  obtain ⟨N, hN⟩ := h ε hε
  filter_upwards [eventually_ge_atTop N] with r hr
  simpa [Real.dist_eq] using hN r hr

end SeedWallis