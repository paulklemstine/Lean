/-
# The sharp constant of the EML polarisation product gate

This file settles the mission conjecture

> `sup_{[0,1]²} |prodGate h x y − x y| = h²/3 + O(h⁴)`, attained at the corner
> `(1,1)`; more generally the polarisation branches' quartic errors cancel to
> leading order, so the sharp constant is `((x+y)⁴ − (x−y)⁴)/24` in absolute
> value rather than the sum `((x+y)⁴ + (x−y)⁴)/24`.

for the width-`4` EML multiplication gate
`prodGate h x y = (S_h(x+y) − S_h(x−y))/4` of
`Applications/EMLDepthWidthTradeoff.lean`, where
`S_h(u) = (exp(hu) + exp(−hu) − 2)/h²`.

## The mechanism

Everything is driven by the *even* remainder function

`coshGap t = exp t + exp (−t) − 2 − t² = t⁴/12 + t⁶/360 + t⁸/20160 + …`

and by the exact identity (`prodGate_sub_eq`)

`prodGate h x y − x y = (coshGap (h(x+y)) − coshGap (h(x−y))) / (4h²)`.

Because `coshGap` is even with *non-negative* Taylor coefficients, the two
polarisation branches partially cancel: the difference is controlled by
`a⁴ − b⁴` (with `a = h(x+y)`, `b = h|x−y|`), never by `a⁴ + b⁴`.  The cancellation
is proved not by term-by-term estimates — which cannot see it, since they are
lossless only when `a = b` — but by *monotonicity* of the two slack functions

`t ↦ t⁴/6 − coshGap t`  and  `t ↦ coshGap t − t⁴/12`

on `[0,1]` (`upperSlack_monotoneOn`, `lowerSlack_monotoneOn`), each obtained from
a cubic Taylor bracket for `2 sinh`.

## Main results

* `coshGap_taylor` — `|coshGap t − t⁴/12 − t⁶/360| ≤ t⁸/17920` for `|t| ≤ 1`.
* `sinh_cubic_lower`, `sinh_cubic_upper` — the cubic bracket
  `t³/3 ≤ exp t − exp(−t) − 2t ≤ t³/2` on `[0,1]`.
* `coshGap_gap_upper`, `coshGap_gap_lower` — for `0 ≤ b ≤ a ≤ 1`,
  `(a⁴−b⁴)/12 ≤ coshGap a − coshGap b ≤ (a⁴−b⁴)/6`.
* `prodGate_error_polarised` — **the conjecture's shape, two-sided**: on `[0,1]²`,
  `h²((x+y)⁴−(x−y)⁴)/48 ≤ prodGate h x y − x y ≤ h²((x+y)⁴−(x−y)⁴)/24`.
  In particular the error is always `≥ 0`, and it vanishes identically on the
  axes — something the catalog's *sum* bound cannot express.
* `prodGate_error_sharp` — the genuinely sharp local constant is `/48`:
  `|prodGate h x y − x y − h² x y (x²+y²)/6| ≤ h⁴/21`.
* `prodGate_sSup_lower`, `prodGate_sSup_upper`, `prodGate_sSup_asymptotic` —
  **the conjecture**: `|sup_{[0,1]²} |prodGate h x y − x y| − h²/3| ≤ h⁴/21`,
  the supremum being attained at the corner `(1,1)`.
* `prodGate_corner_isGreatest` — `(1,1)` really is a maximiser, up to the `O(h⁴)`
  correction, and the corner value alone already exceeds the catalog's lower
  bound `2h²/7`.
* `coshGap_monotoneOn`, `prodGate_isGreatest`, `prodGate_sSup_exact` — §10 upgrades
  the sandwich to an **identity**, for *every* `h > 0` and with no Taylor
  expansion: the maximum is attained exactly at `(1,1)` and equals
  `(exp(2h) + exp(−2h) − 2 − 4h²)/(4h²)`.
* `prodGate_conjecture` — the three claims of the mission statement in one place.
* `sum_bound_not_sharp`, `polarised_lt_sum_bound` — the previously proved sum
  constant is strictly lossy.
* `quadForm_error_sharp` — the sharp constant propagates: every quadratic form is
  computed by one EML layer of width `4n²` with error `(h²/3 + h⁴/21)‖A‖₁`,
  a threefold improvement on the catalog's `h²‖A‖₁`.
* `no_scalar_debiasing` — §11: the `Θ(h²)` rate is a genuine barrier.  For *every*
  gain `lam`, the rescaled gate `lam · prodGate h` still errs by at least `h²/100`
  at one of the probe points `(1,1)`, `(1,1/2)`, because the leading error
  `h² x y (x²+y²)/6` is not proportional to `x y`.

Everything is proved from `import Mathlib` plus the catalog file; no `sorry`.
-/
import Mathlib
import Applications.EMLDepthWidthTradeoff

namespace EML.Polarisation

open Real Set EML.DepthWidth

noncomputable section

/-! ## 1. The even remainder `coshGap` -/

/-- The remainder of `2 cosh` after its quadratic Taylor polynomial:
`coshGap t = exp t + exp(−t) − 2 − t² = t⁴/12 + t⁶/360 + …`. -/
def coshGap (t : ℝ) : ℝ := Real.exp t + Real.exp (-t) - 2 - t ^ 2

@[simp] theorem coshGap_neg (t : ℝ) : coshGap (-t) = coshGap t := by
  simp only [coshGap, neg_neg]
  ring

theorem coshGap_abs (t : ℝ) : coshGap |t| = coshGap t := by
  rcases abs_choice t with h | h
  · rw [h]
  · rw [h, coshGap_neg]

@[simp] theorem coshGap_zero : coshGap 0 = 0 := by norm_num [coshGap]

/-- Degree-`8` Taylor bracket for `coshGap`. -/
theorem coshGap_taylor (t : ℝ) (ht : |t| ≤ 1) :
    |coshGap t - (t ^ 4 / 12 + t ^ 6 / 360)| ≤ t ^ 8 / 17920 := by
  have h1 := Real.exp_bound ht (n := 8) (by norm_num)
  have h2 := Real.exp_bound (x := -t) (by rwa [abs_neg]) (n := 8) (by norm_num)
  rw [abs_neg] at h2
  norm_num [Finset.sum_range_succ, Nat.factorial] at h1 h2
  have h8 : |t| ^ 8 = t ^ 8 := by rw [← abs_pow]; exact abs_of_nonneg (by positivity)
  rw [h8] at h1 h2
  rw [abs_le] at h1 h2 ⊢
  simp only [coshGap]
  constructor <;> nlinarith [h1.1, h1.2, h2.1, h2.2]

/-- `coshGap t` agrees with its leading term `t⁴/12` to order `t⁶`. -/
theorem coshGap_quartic_approx (t : ℝ) (ht : |t| ≤ 1) :
    |coshGap t - t ^ 4 / 12| ≤ t ^ 6 / 350 := by
  have hT := coshGap_taylor t ht
  have h6 : (0:ℝ) ≤ t ^ 6 := by positivity
  have ht2 : t ^ 2 ≤ 1 := by
    have := abs_nonneg t
    nlinarith [sq_abs t]
  have h86 : t ^ 8 ≤ t ^ 6 := by nlinarith
  rw [abs_le] at hT ⊢
  constructor <;> linarith [hT.1, hT.2]

/-! ## 2. A cubic bracket for `2 sinh` -/

/-- Lower cubic bound: `t³/3 ≤ exp t − exp(−t) − 2t` on `[0,1]`. -/
theorem sinh_cubic_lower (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    t ^ 3 / 3 ≤ Real.exp t - Real.exp (-t) - 2 * t := by
  have h1 := Real.sum_le_exp_of_nonneg ht0 6
  have h2 := Real.exp_bound (x := -t) (by rw [abs_neg, abs_of_nonneg ht0]; exact ht1)
    (n := 6) (by norm_num)
  rw [abs_neg, abs_of_nonneg ht0] at h2
  norm_num [Finset.sum_range_succ, Nat.factorial] at h1 h2
  rw [abs_le] at h2
  nlinarith [h1, h2.2, pow_nonneg ht0 5, pow_nonneg ht0 6]

/-- Upper cubic bound: `exp t − exp(−t) − 2t ≤ t³/2` on `[0,1]`. -/
theorem sinh_cubic_upper (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    Real.exp t - Real.exp (-t) - 2 * t ≤ t ^ 3 / 2 := by
  have h1 := Real.exp_bound (x := t) (by rw [abs_of_nonneg ht0]; exact ht1) (n := 4) (by norm_num)
  have h2 := Real.exp_bound (x := -t) (by rw [abs_neg, abs_of_nonneg ht0]; exact ht1)
    (n := 4) (by norm_num)
  rw [abs_neg, abs_of_nonneg ht0] at h2
  rw [abs_of_nonneg ht0] at h1
  norm_num [Finset.sum_range_succ, Nat.factorial] at h1 h2
  rw [abs_le] at h1 h2
  nlinarith [h1.2, h2.1, pow_nonneg ht0 3, pow_nonneg ht0 4]

/-! ## 3. Monotonicity of the two slack functions -/

theorem coshGap_hasDerivAt (t : ℝ) :
    HasDerivAt coshGap (Real.exp t - Real.exp (-t) - 2 * t) t := by
  have d1 : HasDerivAt Real.exp (Real.exp t) t := Real.hasDerivAt_exp t
  have d2 : HasDerivAt (fun s : ℝ => Real.exp (-s)) (-Real.exp (-t)) t := by
    simpa using (Real.hasDerivAt_exp (-t)).comp t (hasDerivAt_neg t)
  have d3 : HasDerivAt (fun s : ℝ => s ^ 2) (2 * t) t := by
    simpa using hasDerivAt_pow 2 t
  have key := ((d1.add d2).sub_const 2).sub d3
  have hfun : coshGap = fun s : ℝ => Real.exp s + Real.exp (-s) - 2 - s ^ 2 := rfl
  rw [hfun]
  convert key using 1

/-- `t ↦ t⁴/6 − coshGap t` is monotone on `[0,1]`: this is the *cancellation*
that the naive triangle-inequality estimate cannot see. -/
theorem upperSlack_monotoneOn :
    MonotoneOn (fun t : ℝ => t ^ 4 / 6 - coshGap t) (Icc (0:ℝ) 1) := by
  have hd : ∀ t : ℝ, HasDerivAt (fun s : ℝ => s ^ 4 / 6 - coshGap s)
      (2 * t ^ 3 / 3 - (Real.exp t - Real.exp (-t) - 2 * t)) t := by
    intro t
    have d1 : HasDerivAt (fun s : ℝ => s ^ 4 / 6) (4 * t ^ 3 / 6) t := by
      simpa using (hasDerivAt_pow 4 t).div_const 6
    have := d1.sub (coshGap_hasDerivAt t)
    convert this using 1
    ring
  refine monotoneOn_of_deriv_nonneg (convex_Icc 0 1)
    (fun t _ => ((hd t).differentiableAt).continuousAt.continuousWithinAt)
    (fun t _ => ((hd t).differentiableAt).differentiableWithinAt) ?_
  intro t ht
  rw [interior_Icc] at ht
  rw [(hd t).deriv]
  have := sinh_cubic_upper t ht.1.le ht.2.le
  nlinarith [pow_nonneg ht.1.le 3]

/-- `t ↦ coshGap t − t⁴/12` is monotone on `[0,1]`. -/
theorem lowerSlack_monotoneOn :
    MonotoneOn (fun t : ℝ => coshGap t - t ^ 4 / 12) (Icc (0:ℝ) 1) := by
  have hd : ∀ t : ℝ, HasDerivAt (fun s : ℝ => coshGap s - s ^ 4 / 12)
      ((Real.exp t - Real.exp (-t) - 2 * t) - t ^ 3 / 3) t := by
    intro t
    have d1 : HasDerivAt (fun s : ℝ => s ^ 4 / 12) (4 * t ^ 3 / 12) t := by
      simpa using (hasDerivAt_pow 4 t).div_const 12
    have := (coshGap_hasDerivAt t).sub d1
    convert this using 1
    ring
  refine monotoneOn_of_deriv_nonneg (convex_Icc 0 1)
    (fun t _ => ((hd t).differentiableAt).continuousAt.continuousWithinAt)
    (fun t _ => ((hd t).differentiableAt).differentiableWithinAt) ?_
  intro t ht
  rw [interior_Icc] at ht
  rw [(hd t).deriv]
  linarith [sinh_cubic_lower t ht.1.le ht.2.le]

/-! ### Global monotonicity of `coshGap` on the half-line -/

/-- `coshGap` has non-negative derivative on `[0,∞)`: this is `sinh t ≥ t`. -/
theorem coshGap_deriv_nonneg {t : ℝ} (ht : 0 ≤ t) :
    0 ≤ Real.exp t - Real.exp (-t) - 2 * t := by
  rcases eq_or_lt_of_le ht with rfl | htp
  · norm_num
  · have hs : t < Real.sinh t := Real.self_lt_sinh_iff.mpr htp
    rw [Real.sinh_eq] at hs
    linarith

/-- `coshGap` is monotone on the non-negative half-line — no radius restriction. -/
theorem coshGap_monotoneOn : MonotoneOn coshGap (Ici (0:ℝ)) := by
  refine monotoneOn_of_deriv_nonneg (convex_Ici 0)
    (fun t _ => (coshGap_hasDerivAt t).differentiableAt.continuousAt.continuousWithinAt)
    (fun t _ => (coshGap_hasDerivAt t).differentiableAt.differentiableWithinAt) ?_
  intro t ht
  rw [interior_Ici] at ht
  rw [(coshGap_hasDerivAt t).deriv]
  exact coshGap_deriv_nonneg (le_of_lt ht)

theorem coshGap_le_of_le {s t : ℝ} (hs : 0 ≤ s) (hst : s ≤ t) : coshGap s ≤ coshGap t :=
  coshGap_monotoneOn (mem_Ici.mpr hs) (mem_Ici.mpr (hs.trans hst)) hst

/-- `coshGap` is non-negative everywhere (by evenness and monotonicity from `0`). -/
theorem coshGap_nonneg (t : ℝ) : 0 ≤ coshGap t := by
  rw [← coshGap_abs]
  have h := coshGap_le_of_le (le_refl (0:ℝ)) (abs_nonneg t)
  rwa [coshGap_zero] at h

/-- **Upper cancellation estimate.**  For `0 ≤ b ≤ a ≤ 1` the *difference* of the
two branch remainders is controlled by `a⁴ − b⁴`, not by `a⁴ + b⁴`. -/
theorem coshGap_gap_upper {a b : ℝ} (hb : 0 ≤ b) (hba : b ≤ a) (ha : a ≤ 1) :
    coshGap a - coshGap b ≤ (a ^ 4 - b ^ 4) / 6 := by
  have h := upperSlack_monotoneOn ⟨hb, hba.trans ha⟩ ⟨hb.trans hba, ha⟩ hba
  simp only at h
  linarith

/-- **Lower cancellation estimate**, the matching half of `coshGap_gap_upper`. -/
theorem coshGap_gap_lower {a b : ℝ} (hb : 0 ≤ b) (hba : b ≤ a) (ha : a ≤ 1) :
    (a ^ 4 - b ^ 4) / 12 ≤ coshGap a - coshGap b := by
  have h := lowerSlack_monotoneOn ⟨hb, hba.trans ha⟩ ⟨hb.trans hba, ha⟩ hba
  simp only at h
  linarith

/-! ## 4. The exact error identity for the gate -/

/-- **Exact error identity.**  The gate's error is the polarised difference of a
single even remainder. -/
theorem prodGate_sub_eq (h x y : ℝ) (hh : h ≠ 0) :
    prodGate h x y - x * y
      = (coshGap (h * (x + y)) - coshGap (h * (x - y))) / (4 * h ^ 2) := by
  rw [prodGate, sqLayer_eval h hh, sqLayer_eval h hh]
  simp only [coshGap]
  field_simp
  ring

/-- The two polarisation arguments, in the normalised form `0 ≤ b ≤ a ≤ 1`. -/
theorem prodGate_sub_eq_abs (h x y : ℝ) (hh : 0 < h) :
    prodGate h x y - x * y
      = (coshGap (h * (x + y)) - coshGap (h * |x - y|)) / (4 * h ^ 2) := by
  rw [prodGate_sub_eq h x y hh.ne']
  congr 2
  rw [← coshGap_abs (h * (x - y)), abs_mul, abs_of_pos hh]

/-! ## 5. The conjecture: polarised two-sided error bounds -/

/-- **Main polarised bound (the conjecture's shape, two-sided).**  On the unit
square the gate's error is non-negative and sandwiched between
`h²((x+y)⁴−(x−y)⁴)/48` and `h²((x+y)⁴−(x−y)⁴)/24`.  The *difference* of fourth
powers, not the sum, is the correct shape: in particular the error vanishes
identically on the two axes. -/
theorem prodGate_error_polarised (h x y : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2)
    (hx : x ∈ Icc (0:ℝ) 1) (hy : y ∈ Icc (0:ℝ) 1) :
    h ^ 2 * ((x + y) ^ 4 - (x - y) ^ 4) / 48 ≤ prodGate h x y - x * y ∧
      prodGate h x y - x * y ≤ h ^ 2 * ((x + y) ^ 4 - (x - y) ^ 4) / 24 := by
  obtain ⟨hx0, hx1⟩ := hx
  obtain ⟨hy0, hy1⟩ := hy
  set a := h * (x + y) with ha_def
  set b := h * |x - y| with hb_def
  have hb0 : 0 ≤ b := by positivity
  have hba : b ≤ a := by
    have : |x - y| ≤ x + y := abs_sub_le_iff.mpr ⟨by linarith, by linarith⟩
    exact mul_le_mul_of_nonneg_left this hh0.le
  have ha1 : a ≤ 1 := by
    have : x + y ≤ 2 := by linarith
    nlinarith
  have hb4 : b ^ 4 = h ^ 4 * (x - y) ^ 4 := by
    rw [hb_def, mul_pow, ← abs_pow, abs_of_nonneg (by positivity : (0:ℝ) ≤ (x - y) ^ 4)]
  have ha4 : a ^ 4 = h ^ 4 * (x + y) ^ 4 := by rw [ha_def, mul_pow]
  have hpos : (0:ℝ) < 4 * h ^ 2 := by positivity
  rw [prodGate_sub_eq_abs h x y hh0, ← ha_def, ← hb_def]
  constructor
  · rw [le_div_iff₀ hpos]
    have := coshGap_gap_lower hb0 hba ha1
    have hexp : h ^ 2 * ((x + y) ^ 4 - (x - y) ^ 4) / 48 * (4 * h ^ 2)
        = (a ^ 4 - b ^ 4) / 12 := by
      rw [ha4, hb4]; ring
    rw [hexp]; exact this
  · rw [div_le_iff₀ hpos]
    have := coshGap_gap_upper hb0 hba ha1
    have hexp : h ^ 2 * ((x + y) ^ 4 - (x - y) ^ 4) / 24 * (4 * h ^ 2)
        = (a ^ 4 - b ^ 4) / 6 := by
      rw [ha4, hb4]; ring
    rw [hexp]; exact this

/-- The gate never *under*-shoots the product on the whole positive quadrant —
no restriction on `h` and no restriction to the unit square. -/
theorem prodGate_error_nonneg (h x y : ℝ) (hh0 : 0 < h) (hx : 0 ≤ x) (hy : 0 ≤ y) :
    0 ≤ prodGate h x y - x * y := by
  rw [prodGate_sub_eq_abs h x y hh0]
  refine div_nonneg ?_ (by positivity)
  have hb0 : 0 ≤ h * |x - y| := by positivity
  have hba : h * |x - y| ≤ h * (x + y) :=
    mul_le_mul_of_nonneg_left (abs_sub_le_iff.mpr ⟨by linarith, by linarith⟩) hh0.le
  linarith [coshGap_le_of_le hb0 hba]

/-- **The conjecture in absolute value**: the sharp constant has the shape
`((x+y)⁴ − (x−y)⁴)/24`, replacing the catalog's sum
`((x+y)⁴ + (x−y)⁴)/24`. -/
theorem prodGate_error_abs_polarised (h x y : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2)
    (hx : x ∈ Icc (0:ℝ) 1) (hy : y ∈ Icc (0:ℝ) 1) :
    |prodGate h x y - x * y| ≤ h ^ 2 * ((x + y) ^ 4 - (x - y) ^ 4) / 24 := by
  rw [abs_of_nonneg (prodGate_error_nonneg h x y hh0 hx.1 hy.1)]
  exact (prodGate_error_polarised h x y hh0 hh hx hy).2

/-! ## 6. The genuinely sharp leading constant is `/48` -/

set_option maxHeartbeats 800000 in
/-- **Sharp asymptotics.**  The leading error is exactly
`h² x y (x²+y²)/6 = h²((x+y)⁴−(x−y)⁴)/48`, with a uniform `O(h⁴)` remainder.
So the conjecture's constant `/24` is correct in shape but a factor `2` lossy;
the true constant is `/48`. -/
theorem prodGate_error_sharp (h x y : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2)
    (hx : x ∈ Icc (0:ℝ) 1) (hy : y ∈ Icc (0:ℝ) 1) :
    |prodGate h x y - x * y - h ^ 2 * (x * y * (x ^ 2 + y ^ 2)) / 6| ≤ h ^ 4 / 21 := by
  obtain ⟨hx0, hx1⟩ := hx
  obtain ⟨hy0, hy1⟩ := hy
  set a := h * (x + y) with ha_def
  set b := h * |x - y| with hb_def
  have hb0 : 0 ≤ b := by positivity
  have hba : b ≤ a := by
    have : |x - y| ≤ x + y := abs_sub_le_iff.mpr ⟨by linarith, by linarith⟩
    exact mul_le_mul_of_nonneg_left this hh0.le
  have ha1 : a ≤ 1 := by
    have : x + y ≤ 2 := by linarith
    nlinarith
  have haa : |a| ≤ 1 := by rw [abs_of_nonneg (hb0.trans hba)]; exact ha1
  have hbb : |b| ≤ 1 := by rw [abs_of_nonneg hb0]; linarith
  have Ea := coshGap_quartic_approx a haa
  have Eb := coshGap_quartic_approx b hbb
  have ha4 : a ^ 4 = h ^ 4 * (x + y) ^ 4 := by rw [ha_def, mul_pow]
  have hb4 : b ^ 4 = h ^ 4 * (x - y) ^ 4 := by
    rw [hb_def, mul_pow, ← abs_pow, abs_of_nonneg (by positivity : (0:ℝ) ≤ (x - y) ^ 4)]
  have ha6 : a ^ 6 = h ^ 6 * (x + y) ^ 6 := by rw [ha_def, mul_pow]
  have hb6 : b ^ 6 = h ^ 6 * (x - y) ^ 6 := by
    rw [hb_def, mul_pow, ← abs_pow, abs_of_nonneg (by positivity : (0:ℝ) ≤ (x - y) ^ 6)]
  have hpos : (0:ℝ) < 4 * h ^ 2 := by positivity
  have hid : prodGate h x y - x * y - h ^ 2 * (x * y * (x ^ 2 + y ^ 2)) / 6
      = ((coshGap a - a ^ 4 / 12) - (coshGap b - b ^ 4 / 12)) / (4 * h ^ 2) := by
    rw [prodGate_sub_eq_abs h x y hh0, ← ha_def, ← hb_def, ha4, hb4]
    field_simp
    ring
  rw [hid, abs_div, abs_of_pos hpos, div_le_iff₀ hpos]
  have htri : |(coshGap a - a ^ 4 / 12) - (coshGap b - b ^ 4 / 12)|
      ≤ a ^ 6 / 350 + b ^ 6 / 350 := (abs_sub _ _).trans (add_le_add Ea Eb)
  -- geometric bounds on the sixth powers over the unit square
  have hs6 : (x + y) ^ 6 ≤ 64 :=
    calc (x + y) ^ 6 ≤ 2 ^ 6 := pow_le_pow_left₀ (by linarith) (by linarith) 6
      _ = 64 := by norm_num
  have hd6 : (x - y) ^ 6 ≤ 1 := by
    have h1 : |x - y| ≤ 1 := abs_sub_le_iff.mpr ⟨by linarith, by linarith⟩
    have h2 : |x - y| ^ 6 ≤ 1 := pow_le_one₀ (abs_nonneg _) h1
    rwa [← abs_pow, abs_of_nonneg (by positivity : (0:ℝ) ≤ (x - y) ^ 6)] at h2
  have h6pos : (0:ℝ) ≤ h ^ 6 := by positivity
  have key : a ^ 6 / 350 + b ^ 6 / 350 ≤ h ^ 4 / 21 * (4 * h ^ 2) := by
    rw [ha6, hb6]
    have e1 : h ^ 6 * (x + y) ^ 6 ≤ h ^ 6 * 64 := mul_le_mul_of_nonneg_left hs6 h6pos
    have e2 : h ^ 6 * (x - y) ^ 6 ≤ h ^ 6 * 1 := mul_le_mul_of_nonneg_left hd6 h6pos
    have hr : h ^ 4 / 21 * (4 * h ^ 2) = 4 * h ^ 6 / 21 := by ring
    rw [hr]
    linarith
  linarith [htri, key]

/-! ## 7. The supremum over the unit square -/

/-- The corner value already exceeds `h²/3`. -/
theorem prodGate_corner_lower (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    h ^ 2 / 3 ≤ prodGate h 1 1 - 1 * 1 := by
  have := (prodGate_error_polarised h 1 1 hh0 hh ⟨by norm_num, le_refl 1⟩
    ⟨by norm_num, le_refl 1⟩).1
  norm_num at this ⊢
  linarith

/-- A strict improvement on the catalog's corner bound `2h²/7`. -/
theorem prodGate_corner_beats_catalog (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    2 * h ^ 2 / 7 < h ^ 2 / 3 ∧ h ^ 2 / 3 ≤ |prodGate h 1 1 - 1 * 1| := by
  refine ⟨by nlinarith [pow_pos hh0 2], ?_⟩
  exact (prodGate_corner_lower h hh0 hh).trans (le_abs_self _)

/-- Uniform upper bound of the conjectured shape `h²/3 + O(h⁴)`. -/
theorem prodGate_error_le_third (h x y : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2)
    (hx : x ∈ Icc (0:ℝ) 1) (hy : y ∈ Icc (0:ℝ) 1) :
    |prodGate h x y - x * y| ≤ h ^ 2 / 3 + h ^ 4 / 21 := by
  obtain ⟨hx0, hx1⟩ := hx
  obtain ⟨hy0, hy1⟩ := hy
  have hsharp := prodGate_error_sharp h x y hh0 hh ⟨hx0, hx1⟩ ⟨hy0, hy1⟩
  rw [abs_le] at hsharp
  have hxy : x * y * (x ^ 2 + y ^ 2) ≤ 2 := by
    have h1 : x * y ≤ 1 := by nlinarith
    have h2 : x ^ 2 + y ^ 2 ≤ 2 := by nlinarith
    nlinarith [mul_nonneg hx0 hy0, sq_nonneg x, sq_nonneg y]
  have hxy0 : 0 ≤ x * y * (x ^ 2 + y ^ 2) := by positivity
  have hh2 : (0:ℝ) ≤ h ^ 2 := sq_nonneg h
  rw [abs_le]
  constructor <;> nlinarith [hsharp.1, hsharp.2, pow_nonneg hh0.le 4]

/-- The set of gate errors over the unit square. -/
def errSet (h : ℝ) : Set ℝ :=
  (fun p : ℝ × ℝ => |prodGate h p.1 p.2 - p.1 * p.2|) '' (Icc (0:ℝ) 1 ×ˢ Icc (0:ℝ) 1)

theorem errSet_nonempty (h : ℝ) : (errSet h).Nonempty :=
  ⟨_, ⟨(0, 0), ⟨⟨le_refl 0, zero_le_one⟩, ⟨le_refl 0, zero_le_one⟩⟩, rfl⟩⟩

theorem errSet_bddAbove (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    BddAbove (errSet h) := by
  refine ⟨h ^ 2 / 3 + h ^ 4 / 21, ?_⟩
  rintro _ ⟨⟨x, y⟩, ⟨hx, hy⟩, rfl⟩
  exact prodGate_error_le_third h x y hh0 hh hx hy

theorem prodGate_sSup_upper (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    sSup (errSet h) ≤ h ^ 2 / 3 + h ^ 4 / 21 := by
  refine csSup_le (errSet_nonempty h) ?_
  rintro _ ⟨⟨x, y⟩, ⟨hx, hy⟩, rfl⟩
  exact prodGate_error_le_third h x y hh0 hh hx hy

theorem prodGate_sSup_lower (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    h ^ 2 / 3 ≤ sSup (errSet h) := by
  have hmem : |prodGate h 1 1 - 1 * 1| ∈ errSet h :=
    ⟨(1, 1), ⟨⟨zero_le_one, le_refl 1⟩, ⟨zero_le_one, le_refl 1⟩⟩, rfl⟩
  exact ((prodGate_corner_beats_catalog h hh0 hh).2).trans
    (le_csSup (errSet_bddAbove h hh0 hh) hmem)

/-- **The mission conjecture, proved.**
`sup_{[0,1]²} |prodGate h x y − x y| = h²/3 + O(h⁴)`, with the explicit constant
`1/21` in the remainder; the numerically observed remainder constant is
`2/45 ≈ 0.0444`. -/
theorem prodGate_sSup_asymptotic (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    |sSup (errSet h) - h ^ 2 / 3| ≤ h ^ 4 / 21 := by
  rw [abs_le]
  refine ⟨by linarith [prodGate_sSup_lower h hh0 hh, pow_pos hh0 4], ?_⟩
  linarith [prodGate_sSup_upper h hh0 hh]

/-- **The supremum is attained at the corner `(1,1)`, up to `O(h⁴)`.**  The corner
value is within `h⁴/21` of the supremum, and no interior point can beat it by
more than that. -/
theorem prodGate_corner_isGreatest (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    sSup (errSet h) - |prodGate h 1 1 - 1 * 1| ≤ h ^ 4 / 21 := by
  have h1 := prodGate_sSup_upper h hh0 hh
  have h2 := prodGate_corner_lower h hh0 hh
  have h3 : h ^ 2 / 3 ≤ |prodGate h 1 1 - 1 * 1| := h2.trans (le_abs_self _)
  linarith

/-! ## 8. The catalog's sum constant is strictly lossy -/

/-- Off the diagonal the polarised constant is strictly smaller than the sum
constant proved in the catalog. -/
theorem polarised_lt_sum_bound (h x y : ℝ) (hh0 : 0 < h) (hxy : x ≠ y) :
    h ^ 2 * ((x + y) ^ 4 - (x - y) ^ 4) / 24
      < h ^ 2 * ((x + y) ^ 4 + (x - y) ^ 4) / 24 := by
  have hd : (0:ℝ) < (x - y) ^ 4 := by
    have : x - y ≠ 0 := sub_ne_zero_of_ne hxy
    positivity
  have hh2 : (0:ℝ) < h ^ 2 := by positivity
  nlinarith

/-- On the axis `y = 0` the gate is **exact**, whereas the catalog's sum bound is
strictly positive — the sharpest possible witness that the sum shape is wrong. -/
theorem prodGate_axis_exact (h x : ℝ) : prodGate h x 0 - x * 0 = 0 := by
  simp [prodGate]

theorem sum_bound_lossy_on_axis (h x : ℝ) (hh0 : 0 < h) (hx : x ≠ 0) :
    |prodGate h x 0 - x * 0| < h ^ 2 * ((x + 0) ^ 4 + (x - 0) ^ 4) / 24 := by
  rw [prodGate_axis_exact h x, abs_zero]
  have hx4 : (0:ℝ) < x ^ 4 := by positivity
  have hh2 : (0:ℝ) < h ^ 2 := by positivity
  nlinarith

/-- Even at the corner — where the two constants have the same shape — the sum
bound `2h²/3` overshoots the true error `≈ h²/3` by a factor of nearly `2`. -/
theorem sum_bound_not_sharp (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    |prodGate h 1 1 - 1 * 1| ≤ h ^ 2 / 3 + h ^ 4 / 21 ∧
      h ^ 2 / 3 + h ^ 4 / 21 < h ^ 2 * (((1:ℝ) + 1) ^ 4 + ((1:ℝ) - 1) ^ 4) / 24 := by
  refine ⟨prodGate_error_le_third h 1 1 hh0 hh ⟨zero_le_one, le_refl 1⟩
    ⟨zero_le_one, le_refl 1⟩, ?_⟩
  have hh2 : (0:ℝ) < h ^ 2 := by positivity
  have hsq : h ^ 2 ≤ 1 / 4 := by nlinarith
  have hh4 : h ^ 4 ≤ h ^ 2 / 4 := by nlinarith [sq_nonneg h]
  have hrhs : h ^ 2 * (((1:ℝ) + 1) ^ 4 + ((1:ℝ) - 1) ^ 4) / 24 = 2 * h ^ 2 / 3 := by ring
  rw [hrhs]
  linarith

/-! ## 9. Propagation: quadratic forms with the sharp constant -/

/-- **Sharp quadratic-form error.**  Replacing every product by the width-`4`
gate computes an arbitrary quadratic form on `[0,1]ⁿ` with error
`(h²/3 + h⁴/21)·‖A‖₁` — a threefold improvement over the catalog's `h²·‖A‖₁`,
uniform in the dimension. -/
theorem quadForm_error_sharp {n : ℕ} (A : Fin n → Fin n → ℝ) (x : Fin n → ℝ)
    (hx : ∀ i, x i ∈ Icc (0:ℝ) 1) (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    |(∑ i, ∑ j, A i j * prodGate h (x i) (x j)) - ∑ i, ∑ j, A i j * (x i * x j)|
      ≤ (h ^ 2 / 3 + h ^ 4 / 21) * ∑ i, ∑ j, |A i j| := by
  set C := h ^ 2 / 3 + h ^ 4 / 21 with hC
  have hC0 : 0 ≤ C := by rw [hC]; positivity
  have hid : (∑ i, ∑ j, A i j * prodGate h (x i) (x j))
      - ∑ i, ∑ j, A i j * (x i * x j)
      = ∑ i, ∑ j, A i j * (prodGate h (x i) (x j) - x i * x j) := by
    rw [← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun j _ => by ring
  rw [hid]
  have hstep : ∀ i : Fin n, |∑ j, A i j * (prodGate h (x i) (x j) - x i * x j)|
      ≤ ∑ j, C * |A i j| := by
    intro i
    refine (Finset.abs_sum_le_sum_abs _ _).trans (Finset.sum_le_sum fun j _ => ?_)
    rw [abs_mul]
    have hb := prodGate_error_le_third h (x i) (x j) hh0 hh (hx i) (hx j)
    calc |A i j| * |prodGate h (x i) (x j) - x i * x j| ≤ |A i j| * C :=
          mul_le_mul_of_nonneg_left hb (abs_nonneg _)
      _ = C * |A i j| := by ring
  calc |∑ i, ∑ j, A i j * (prodGate h (x i) (x j) - x i * x j)|
      ≤ ∑ i, |∑ j, A i j * (prodGate h (x i) (x j) - x i * x j)| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, ∑ j, C * |A i j| := Finset.sum_le_sum fun i _ => hstep i
    _ = C * ∑ i, ∑ j, |A i j| := by
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl fun i _ => (Finset.mul_sum _ _ _).symm

/-! ## 10.  The supremum, exactly

The `O(h⁴)` sandwich of §7 can be upgraded to an *identity*, for **every** `h > 0`
and with no Taylor expansion at all.  The only input is that `coshGap` is monotone
on `[0,∞)` (`coshGap_monotoneOn`), which by the exact identity `prodGate_sub_eq_abs`
forces the error to be maximal exactly where `x + y` is maximal and `|x − y|` is
minimal — that is, at the corner `(1,1)`. -/

/-- The corner error in closed form. -/
theorem prodGate_corner_value (h : ℝ) (hh0 : 0 < h) :
    prodGate h 1 1 - 1 * 1 = coshGap (2 * h) / (4 * h ^ 2) := by
  have h1 : h * ((1:ℝ) + 1) = 2 * h := by ring
  have h2 : h * |(1:ℝ) - 1| = 0 := by norm_num
  rw [prodGate_sub_eq_abs h 1 1 hh0, h1, h2, coshGap_zero, sub_zero]

/-- **The corner dominates, exactly.**  For every `h > 0` the error at any point of
the unit square is at most the corner error. -/
theorem prodGate_error_le_corner (h x y : ℝ) (hh0 : 0 < h)
    (hx : x ∈ Icc (0:ℝ) 1) (hy : y ∈ Icc (0:ℝ) 1) :
    |prodGate h x y - x * y| ≤ coshGap (2 * h) / (4 * h ^ 2) := by
  obtain ⟨hx0, hx1⟩ := hx
  obtain ⟨hy0, hy1⟩ := hy
  rw [abs_of_nonneg (prodGate_error_nonneg h x y hh0 hx0 hy0),
    prodGate_sub_eq_abs h x y hh0]
  have hbranch : coshGap (h * (x + y)) ≤ coshGap (2 * h) :=
    coshGap_le_of_le (by positivity) (by nlinarith)
  have hrest : 0 ≤ coshGap (h * |x - y|) := coshGap_nonneg _
  have hnum : coshGap (h * (x + y)) - coshGap (h * |x - y|) ≤ coshGap (2 * h) := by
    linarith
  gcongr

/-- **The supremum is attained at `(1,1)`.**  Not merely up to `O(h⁴)`: the corner
value *is* the maximum of the error over the unit square, for every `h > 0`. -/
theorem prodGate_isGreatest (h : ℝ) (hh0 : 0 < h) :
    IsGreatest (errSet h) (coshGap (2 * h) / (4 * h ^ 2)) := by
  constructor
  · refine ⟨(1, 1), ⟨⟨zero_le_one, le_refl 1⟩, ⟨zero_le_one, le_refl 1⟩⟩, ?_⟩
    simp only
    rw [abs_of_nonneg (prodGate_error_nonneg h 1 1 hh0 zero_le_one zero_le_one),
      prodGate_corner_value h hh0]
  · rintro _ ⟨⟨x, y⟩, ⟨hx, hy⟩, rfl⟩
    exact prodGate_error_le_corner h x y hh0 hx hy

/-- **Closed form for the supremum.**  For every `h > 0`,
`sup_{[0,1]²} |prodGate h x y − x y| = (exp(2h) + exp(−2h) − 2 − 4h²)/(4h²)`. -/
theorem prodGate_sSup_exact (h : ℝ) (hh0 : 0 < h) :
    sSup (errSet h)
      = (Real.exp (2 * h) + Real.exp (-(2 * h)) - 2 - 4 * h ^ 2) / (4 * h ^ 2) := by
  rw [(prodGate_isGreatest h hh0).csSup_eq]
  congr 1
  simp only [coshGap]
  ring

/-- Consistency of §7 and §10: the closed form really is `h²/3 + O(h⁴)`.  Read as a
statement about `2 cosh`, this says
`|(2 cosh(2h) − 2 − 4h²)/(4h²) − h²/3| ≤ h⁴/21` for `0 < h ≤ 1/2`. -/
theorem coshGap_corner_asymptotic (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    |coshGap (2 * h) / (4 * h ^ 2) - h ^ 2 / 3| ≤ h ^ 4 / 21 := by
  have hs := prodGate_sSup_asymptotic h hh0 hh
  rwa [(prodGate_isGreatest h hh0).csSup_eq] at hs

/-- **Final form of the mission conjecture.**  For `0 < h ≤ 1/2` the supremum of the
gate's error over `[0,1]²` is attained at the corner `(1,1)`, equals
`(exp(2h) + exp(−2h) − 2 − 4h²)/(4h²)` exactly, and differs from `h²/3` by at most
`h⁴/21`. -/
theorem prodGate_conjecture (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    IsGreatest (errSet h) |prodGate h 1 1 - 1 * 1| ∧
      sSup (errSet h)
        = (Real.exp (2 * h) + Real.exp (-(2 * h)) - 2 - 4 * h ^ 2) / (4 * h ^ 2) ∧
      |sSup (errSet h) - h ^ 2 / 3| ≤ h ^ 4 / 21 := by
  refine ⟨?_, prodGate_sSup_exact h hh0, prodGate_sSup_asymptotic h hh0 hh⟩
  have hval : |prodGate h 1 1 - 1 * 1| = coshGap (2 * h) / (4 * h ^ 2) := by
    rw [abs_of_nonneg (prodGate_error_nonneg h 1 1 hh0 zero_le_one zero_le_one),
      prodGate_corner_value h hh0]
  rw [hval]
  exact prodGate_isGreatest h hh0

/-! ## 11.  The `Θ(h²)` barrier is intrinsic: no scalar debiasing

The exact leading term `h² x y (x²+y²)/6` is *not* proportional to `x y`, because of
the factor `x² + y²`.  Consequently no rescaling of the gate's output — however
cleverly chosen, and even allowed to depend on `h` — can remove the second-order
error.  The obstruction is exposed by two probe points, `(1,1)` and `(1,1/2)`,
whose leading errors `h²/3` and `5h²/48` are *not* in the ratio of their products
`1 : 1/2`. -/

/-- Leading error at the probe point `(1,1)`. -/
theorem prodGate_probe_corner (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    |prodGate h 1 1 - 1 - h ^ 2 / 3| ≤ h ^ 4 / 21 := by
  have hone : (1:ℝ) ∈ Icc (0:ℝ) 1 := ⟨zero_le_one, le_refl 1⟩
  have hs := prodGate_error_sharp h 1 1 hh0 hh hone hone
  rwa [show prodGate h 1 1 - 1 * 1 - h ^ 2 * (1 * 1 * ((1:ℝ) ^ 2 + 1 ^ 2)) / 6
      = prodGate h 1 1 - 1 - h ^ 2 / 3 from by ring] at hs

/-- Leading error at the probe point `(1,1/2)`. -/
theorem prodGate_probe_half (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    |prodGate h 1 (1/2) - 1/2 - 5 * h ^ 2 / 48| ≤ h ^ 4 / 21 := by
  have hone : (1:ℝ) ∈ Icc (0:ℝ) 1 := ⟨zero_le_one, le_refl 1⟩
  have hhalf : (1:ℝ)/2 ∈ Icc (0:ℝ) 1 := ⟨by norm_num, by norm_num⟩
  have hs := prodGate_error_sharp h 1 (1/2) hh0 hh hone hhalf
  rwa [show prodGate h 1 (1/2) - 1 * (1/2)
        - h ^ 2 * (1 * (1/2) * ((1:ℝ) ^ 2 + (1/2 : ℝ) ^ 2)) / 6
      = prodGate h 1 (1/2) - 1/2 - 5 * h ^ 2 / 48 from by ring] at hs

/-- **No scalar debiasing.**  For *every* real gain `lam` (possibly depending on
`h`), the rescaled gate `lam · prodGate h` still misses the product by at least
`h²/100` at one of the two probe points.  Hence the `Θ(h²)` accuracy of the width-4
EML multiplication gate cannot be improved by any read-out rescaling: the sharp
constant of §6 is a genuine barrier, not an artefact of normalisation. -/
theorem no_scalar_debiasing (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) (lam : ℝ) :
    h ^ 2 / 100
      ≤ max |lam * prodGate h 1 1 - 1 * 1| |lam * prodGate h 1 (1/2) - 1 * (1/2)| := by
  have k1 := prodGate_probe_corner h hh0 hh
  have k2 := prodGate_probe_half h hh0 hh
  set E1 := prodGate h 1 1
  set E2 := prodGate h 1 (1/2)
  rw [abs_le] at k1 k2
  have hsq : h ^ 2 ≤ 1 / 4 := by nlinarith
  have h4 : h ^ 4 ≤ h ^ 2 / 4 := by nlinarith [sq_nonneg h]
  have hpos : (0:ℝ) < h ^ 2 := by positivity
  set A := lam * E1 - 1 * 1 with hA
  set B := lam * E2 - 1 * (1/2) with hB
  have hMA : |A| ≤ max |A| |B| := le_max_left _ _
  have hMB : |B| ≤ max |A| |B| := le_max_right _ _
  rcases le_or_gt lam (1/2) with hl | hl
  · -- a small gain already ruins the corner value
    have hE1 : 1 ≤ E1 := by nlinarith [k1.1, k1.2]
    have hE1' : E1 ≤ 11/10 := by nlinarith [k1.1, k1.2]
    have hAneg : A ≤ -(45/100) := by nlinarith
    have hAbig : (45:ℝ)/100 ≤ |A| := by rw [le_abs]; right; linarith
    linarith
  · -- a large gain cannot match both probes, since 1/3 ≠ 2·(5/48)
    have hd : 5 * h ^ 2 / 56 ≤ (E1 - 1) - 2 * (E2 - 1/2) := by nlinarith [k1.1, k2.2]
    have hid : A - 2 * B = lam * ((E1 - 1) - 2 * (E2 - 1/2)) := by rw [hA, hB]; ring
    have hlow : 5 * h ^ 2 / 112 ≤ A - 2 * B := by rw [hid]; nlinarith
    have htri : A - 2 * B ≤ |A| + 2 * |B| := by
      have h1 : A ≤ |A| := le_abs_self A
      have h2 : -B ≤ |B| := neg_le_abs B
      linarith
    linarith

end

end EML.Polarisation