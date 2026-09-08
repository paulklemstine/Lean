/-
# The complete crossing spectrum of the fork channel

This file continues `Novelty.ForkChannelCrossingUniqueness`.  There the address
channel `A n = log₂ n - 1 - 1/n²` and the exchange channel `X n = 2(1 - 1/n²)`
were shown to cross exactly once on the *physical* range `n > 2`, at an arity
strictly between `7` and `8`.

Here we determine the crossing spectrum on the **whole** positive axis, and the
answer is a genuine surprise: the analytic continuation of the model to
sub-critical arity has a **second, exact crossing at `n = 1/2`**, where both
channels take the common value `-6`:

`A (1/2) = X (1/2) = -6`,  because  `log₂(1/2) + 1/(1/2)² = -1 + 4 = 3`.

This is the *hidden resonance* between `log₂ n` and the entropy deficit: the
resonance functional `R n = log₂ n + 1/n²` hits the critical level `3` twice on
`(0, ∞)` — once at the exactly solvable dyadic point `1/2`, and once at the
transcendental point `r ∈ (7, 8)`.  Both facts are proved here, together with

* `resonance_strictAntiOn` : `R` is strictly *decreasing* on `(0, 1]`;
* `resonance_le_two_of_mem_Icc` : `R ≤ 2 < 3` on `[1, 2]`, so the interval
  separating the two crossings is crossing-free;
* `crossings_exactly_two` : `{n > 0 : A n = X n} = {1/2, r}` with `7 < r < 8` —
  a complete determination of the crossing spectrum;
* `crossing_dyadic_bracket` : the transcendental crossing satisfies
  `253/32 < r < 507/64`, i.e. `7.90625 < r < 7.921875`, sharpened from `(7,8)`
  by exactly two integer certificates,
  `253 ^ 64009 < 2 ^ 511048`  and  `2 ^ 2309345 < 507 ^ 257049`.
-/
import Mathlib
import Novelty.ForkChannelCrossingUniqueness

namespace ForkChannel

open Real Set Filter Topology

/-! ## 1. The exact second crossing at `n = 1/2` -/

theorem logb_two_half : logb 2 (1/2 : ℝ) = -1 := by
  rw [one_div, Real.logb_inv, Real.logb_self_eq_one (by norm_num)]

theorem deficit_half : deficit (1/2 : ℝ) = 4 := by
  unfold deficit; norm_num

/-- The **hidden resonance**: `log₂(1/2) + 1/(1/2)² = -1 + 4 = 3`. -/
theorem resonance_half : resonance (1/2 : ℝ) = 3 := by
  unfold resonance
  rw [logb_two_half, deficit_half]
  norm_num

theorem A_half : A (1/2 : ℝ) = -6 := by
  unfold A
  rw [logb_two_half, deficit_half]
  norm_num

theorem X_half : X (1/2 : ℝ) = -6 := by
  unfold X
  rw [deficit_half]
  norm_num

/-- The exact second crossing: both channels equal `-6` at sub-critical arity
`n = 1/2`. -/
theorem A_eq_X_half : A (1/2 : ℝ) = X (1/2 : ℝ) := by
  rw [A_half, X_half]

/-! ## 2. The resonance is strictly decreasing on `(0, 1]` -/

theorem resonance_deriv_neg {n : ℝ} (h0 : 0 < n) (h1 : n ≤ 1) :
    1 / (n * Real.log 2) - 2 / n ^ 3 < 0 := by
  have hl2 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have h1p : 0 < n * Real.log 2 := by positivity
  have h2p : (0:ℝ) < n ^ 3 := by positivity
  have hn3 : n ^ 3 ≤ n := by
    nlinarith [mul_nonneg (mul_nonneg h0.le (sub_nonneg.2 h1)) (by linarith : (0:ℝ) ≤ 1 + n)]
  have hnl : n * 0.6931471803 < n * Real.log 2 := by nlinarith
  rw [sub_neg, div_lt_div_iff₀ h1p h2p]
  nlinarith

theorem resonance_continuousOn_Ioc : ContinuousOn resonance (Ioc 0 1) := by
  intro x hx
  exact (hasDerivAt_resonance (ne_of_gt hx.1)).continuousAt.continuousWithinAt

/-- On sub-critical arity `(0, 1]` the resonance is strictly *decreasing*: the
entropy deficit `1/n²` dominates `log₂ n`. -/
theorem resonance_strictAntiOn : StrictAntiOn resonance (Ioc 0 1) := by
  apply strictAntiOn_of_deriv_neg (convex_Ioc 0 1) resonance_continuousOn_Ioc
  intro x hx
  rw [interior_Ioc] at hx
  rw [(hasDerivAt_resonance (ne_of_gt hx.1)).deriv]
  exact resonance_deriv_neg hx.1 (le_of_lt hx.2)

/-! ## 3. The separating interval `[1, 2]` is crossing-free -/

theorem resonance_le_two_of_mem_Icc {n : ℝ} (h1 : 1 ≤ n) (h2 : n ≤ 2) :
    resonance n ≤ 2 := by
  have hpos : (0:ℝ) < n := by linarith
  have hlog : logb 2 n ≤ 1 := by
    have h := (Real.logb_le_logb (by norm_num : (1:ℝ) < 2) hpos (by norm_num : (0:ℝ) < 2)).2 h2
    rwa [Real.logb_self_eq_one (by norm_num)] at h
  have hdef : deficit n ≤ 1 := by
    unfold deficit
    rw [div_le_one (by positivity)]
    nlinarith
  unfold resonance
  linarith

/-! ## 4. The complete crossing spectrum -/

/-- **Complete determination of the crossing spectrum.**  On the whole positive
axis the two fork channels agree at exactly two arities: the exactly solvable
dyadic point `1/2`, and one transcendental point strictly between `7` and `8`. -/
theorem crossings_exactly_two :
    ∃ r : ℝ, 7 < r ∧ r < 8 ∧ {n : ℝ | 0 < n ∧ A n = X n} = {1/2, r} := by
  obtain ⟨r, hr7, hr8, hrEq, _huniq⟩ := crossing_mem_Ioo
  have hrres : resonance r = 3 := (A_eq_X_iff r).1 hrEq
  refine ⟨r, hr7, hr8, ?_⟩
  ext n
  simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
  constructor
  · rintro ⟨hpos, hEq⟩
    have hres : resonance n = 3 := (A_eq_X_iff n).1 hEq
    rcases le_or_gt n 1 with h1 | h1
    · left
      have hmem : n ∈ Ioc (0:ℝ) 1 := ⟨hpos, h1⟩
      have hmemh : (1/2 : ℝ) ∈ Ioc (0:ℝ) 1 := by constructor <;> norm_num
      exact resonance_strictAntiOn.injOn hmem hmemh (by rw [hres, resonance_half])
    · rcases lt_or_ge n 2 with h2 | h2
      · exact absurd hres (by
          have := resonance_le_two_of_mem_Icc (le_of_lt h1) (le_of_lt h2)
          linarith)
      · right
        have hmem : n ∈ Ici (2:ℝ) := h2
        have hmemr : r ∈ Ici (2:ℝ) := by simp only [mem_Ici]; linarith
        exact resonance_strictMonoOn.injOn hmem hmemr (by rw [hres, hrres])
  · rintro (rfl | rfl)
    · exact ⟨by norm_num, A_eq_X_half⟩
    · exact ⟨by linarith, hrEq⟩

/-! ## 5. A sharpened dyadic bracket from two integer certificates -/

/-- Upper bound on a base-2 logarithm extracted from a pure integer inequality. -/
theorem logb_two_lt_of_pow {x : ℝ} (hx : 0 < x) {p q : ℕ} (hq : 0 < q)
    (h : x ^ q < 2 ^ p) : logb 2 x < (p : ℝ) / q := by
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hqpos : (0:ℝ) < (q:ℝ) := by exact_mod_cast hq
  have hlog : (q : ℝ) * Real.log x < (p : ℝ) * Real.log 2 := by
    have := (Real.log_lt_log_iff (by positivity) (by positivity)).2 h
    rwa [Real.log_pow, Real.log_pow] at this
  rw [Real.logb, div_lt_div_iff₀ hl2 hqpos]
  linarith

/-- Lower bound on a base-2 logarithm extracted from a pure integer inequality. -/
theorem lt_logb_two_of_pow {x : ℝ} (hx : 0 < x) {p q : ℕ} (hq : 0 < q)
    (h : (2:ℝ) ^ p < x ^ q) : (p : ℝ) / q < logb 2 x := by
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hqpos : (0:ℝ) < (q:ℝ) := by exact_mod_cast hq
  have hlog : (p : ℝ) * Real.log 2 < (q : ℝ) * Real.log x := by
    have := (Real.log_lt_log_iff (by positivity) (by positivity)).2 h
    rwa [Real.log_pow, Real.log_pow] at this
  rw [Real.logb, div_lt_div_iff₀ hqpos hl2]
  linarith

set_option exponentiation.threshold 3000000 in
set_option maxRecDepth 100000 in
/-- Lower certificate: `253 ^ 64009 < 2 ^ 511048`. -/
theorem certificate_lower : (253:ℝ) ^ (64009:ℕ) < 2 ^ (511048:ℕ) := by
  have h : (253:ℕ) ^ (64009:ℕ) < 2 ^ (511048:ℕ) := by norm_num
  exact_mod_cast h

set_option exponentiation.threshold 3000000 in
set_option maxRecDepth 100000 in
/-- Upper certificate: `2 ^ 2309345 < 507 ^ 257049`. -/
theorem certificate_upper : (2:ℝ) ^ (2309345:ℕ) < 507 ^ (257049:ℕ) := by
  have h : (2:ℕ) ^ (2309345:ℕ) < 507 ^ (257049:ℕ) := by norm_num
  exact_mod_cast h

theorem logb_two_pow_two (k : ℕ) : logb 2 ((2:ℝ) ^ k) = k := by
  rw [Real.logb_pow, Real.logb_self_eq_one (by norm_num)]
  ring

theorem resonance_lower_pt : resonance (253/32 : ℝ) < 3 := by
  have hsplit : logb 2 (253/32 : ℝ) = logb 2 253 - 5 := by
    rw [Real.logb_div (by norm_num) (by norm_num)]
    congr 1
    rw [show (32:ℝ) = 2 ^ (5:ℕ) by norm_num, logb_two_pow_two]
    norm_num
  have hdef : deficit (253/32 : ℝ) = 1024 / 64009 := by
    unfold deficit; norm_num
  have hlog : logb 2 (253:ℝ) < (511048 : ℝ) / 64009 := by
    have := logb_two_lt_of_pow (by norm_num : (0:ℝ) < 253) (by norm_num : 0 < 64009)
      certificate_lower
    simpa using this
  unfold resonance
  rw [hsplit, hdef]
  linarith

theorem resonance_upper_pt : 3 < resonance (507/64 : ℝ) := by
  have hsplit : logb 2 (507/64 : ℝ) = logb 2 507 - 6 := by
    rw [Real.logb_div (by norm_num) (by norm_num)]
    congr 1
    rw [show (64:ℝ) = 2 ^ (6:ℕ) by norm_num, logb_two_pow_two]
    norm_num
  have hdef : deficit (507/64 : ℝ) = 4096 / 257049 := by
    unfold deficit; norm_num
  have hlog : (2309345 : ℝ) / 257049 < logb 2 (507:ℝ) := by
    have := lt_logb_two_of_pow (by norm_num : (0:ℝ) < 507) (by norm_num : 0 < 257049)
      certificate_upper
    simpa using this
  unfold resonance
  rw [hsplit, hdef]
  linarith

/-- **Sharpened bracket.**  The transcendental crossing lies strictly between
`253/32 = 7.90625` and `507/64 = 7.921875`. -/
theorem crossing_dyadic_bracket :
    ∃ r : ℝ, 253/32 < r ∧ r < 507/64 ∧ A r = X r := by
  obtain ⟨r, hr7, hr8, hrEq, _⟩ := crossing_mem_Ioo
  have hrres : resonance r = 3 := (A_eq_X_iff r).1 hrEq
  have hmemr : r ∈ Ici (2:ℝ) := by simp only [mem_Ici]; linarith
  have hlow : 253/32 < r := by
    by_contra hcon
    push_neg at hcon
    have hmem : (253/32 : ℝ) ∈ Ici (2:ℝ) := by norm_num
    have : resonance r ≤ resonance (253/32 : ℝ) := by
      rcases eq_or_lt_of_le hcon with h | h
      · rw [h]
      · exact le_of_lt (resonance_strictMonoOn hmemr hmem h)
    linarith [resonance_lower_pt]
  have hupp : r < 507/64 := by
    by_contra hcon
    push_neg at hcon
    have hmem : (507/64 : ℝ) ∈ Ici (2:ℝ) := by norm_num
    have : resonance (507/64 : ℝ) ≤ resonance r := by
      rcases eq_or_lt_of_le hcon with h | h
      · rw [h]
      · exact le_of_lt (resonance_strictMonoOn hmem hmemr h)
    linarith [resonance_upper_pt]
  exact ⟨r, hlow, hupp, hrEq⟩

end ForkChannel