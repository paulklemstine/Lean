import Mathlib
import Tropical.ECMPlaneCompletion

/-!
# The measured ECM exponent is a window artefact: the subexponential arm has exponent `0`

Experiment 490 fits an *affine* profile `k ↦ c + α·k` to each factoring arm, `k = log₂ p`,
and reports `α_ECM = 0.761` (`B₁ = 50`) and `0.718` (`B₁ = 250`).  Section 3 of
`Catalog/Tropical/ECMPlaneCompletion.lean` explains those numbers structurally: a
stage-one bound `B = p^β` gives work exponent `1 − β`, so a *fixed* toy-scale bound
places ECM strictly inside the rho/trial-division bracket.

This file proves the complementary — and stronger — statement: **no affine profile
describes ECM asymptotically at all.**  The true ECM cost is subexponential,
`L_p(1/2, c) = exp(c √(log p · log log p))`, and we show

* `subexp_lt_power` — for every `c > 0` and every `a > 0`, eventually
  `log L(x) < a · log x`: the subexponential arm is eventually below **every** positive
  power, hence eventually below every arm of the measured plane;
* `subexp_exponent_tendsto_zero` — the fitted across-`k` exponent of the `L` arm tends to
  `0`, so any positive measured slope (`0.761`, `0.718`, …) is a property of the
  observation window and not of the arm;
* `subexp_doubling_slope_tendsto_zero` — the *two-point* chord slope actually used by
  the experiment, measured over a doubling window in `log₂ p`, also tends to `0`;
* `subexp_beats_every_arm` — bridging to the tropical plane of the previous file: every
  profile with positive exponent is eventually beaten by the `L` arm, so the `L` arm is
  the unique eventual leader of the whole five-method table;
* `log_subexp_tendsto_atTop` — and yet the `L` arm is **not** the exponent-`0`
  (constant-work) arm: its log-work diverges.  The affine plane is therefore not closed:
  the true ECM cost lies strictly between "exponent `0`" and "every positive exponent",
  which is precisely why a finite window produces a spurious interior slope.

Together with `ECMPlane.ecm_work_between_rho_and_td` this closes the ECM column: the
measured interior exponent is exactly what a *fixed* stage-one bound must produce, and it
must drift to `0` as the bound is allowed to grow with the target.
-/

namespace ECMSubexp

open Filter Asymptotics Real
open scoped Topology

/-- The subexponential cost function `L_x(1/2, c) = exp(c · √(log x · log log x))`, the
standard heuristic running time of ECM/QS-type arms. -/
noncomputable def Lfun (c x : ℝ) : ℝ := Real.exp (c * Real.sqrt (Real.log x * Real.log (Real.log x)))

@[simp] theorem log_Lfun (c x : ℝ) :
    Real.log (Lfun c x) = c * Real.sqrt (Real.log x * Real.log (Real.log x)) := by
  unfold Lfun; exact Real.log_exp _

/-! ## 1. `log log` is little-o of `log` -/

/-- `log (log x) = o(log x)` as `x → ∞`. -/
theorem logLog_isLittleO_log :
    (fun x : ℝ => Real.log (Real.log x)) =o[atTop] fun x : ℝ => Real.log x :=
  Real.isLittleO_log_id_atTop.comp_tendsto Real.tendsto_log_atTop

/-- Quantitative form: for every `ε > 0`, eventually `log log x ≤ ε · log x`, with
`log x` itself positive and at least `1`. -/
theorem eventually_logLog_le {eps : ℝ} (heps : 0 < eps) :
    ∀ᶠ x : ℝ in atTop, Real.log (Real.log x) ≤ eps * Real.log x ∧ 1 ≤ Real.log x := by
  have h1 : ∀ᶠ x : ℝ in atTop, ‖Real.log (Real.log x)‖ ≤ eps * ‖Real.log x‖ :=
    logLog_isLittleO_log.bound heps
  have h2 : ∀ᶠ x : ℝ in atTop, 1 ≤ Real.log x :=
    Real.tendsto_log_atTop.eventually_ge_atTop 1
  filter_upwards [h1, h2] with x hx hx1
  refine ⟨?_, hx1⟩
  have : Real.log (Real.log x) ≤ ‖Real.log (Real.log x)‖ := le_abs_self _
  have hnorm : ‖Real.log x‖ = Real.log x := abs_of_nonneg (by linarith)
  rw [hnorm] at hx
  linarith

/-! ## 2. The subexponential arm is eventually below every positive power -/

/-- **The core estimate.**  For every `c > 0` and every exponent `a > 0`,
`log L(x) < a · log x` for all large `x`: the subexponential arm eventually undercuts
every power law, however small its exponent. -/
theorem subexp_lt_power {c a : ℝ} (hc : 0 < c) (ha : 0 < a) :
    ∀ᶠ x : ℝ in atTop, Real.log (Lfun c x) < a * Real.log x := by
  have heps : 0 < a ^ 2 / (2 * c ^ 2) := by positivity
  filter_upwards [eventually_logLog_le heps] with x hx
  obtain ⟨hbound, hL1⟩ := hx
  have hLpos : 0 < Real.log x := by linarith
  have hLL0 : 0 ≤ Real.log (Real.log x) := Real.log_nonneg hL1
  rw [log_Lfun]
  -- reduce to a comparison of squares
  have hkey : Real.log x * Real.log (Real.log x) < (a / c) ^ 2 * Real.log x ^ 2 := by
    have h1 : Real.log x * Real.log (Real.log x) ≤ Real.log x * (a ^ 2 / (2 * c ^ 2) * Real.log x) :=
      mul_le_mul_of_nonneg_left hbound hLpos.le
    have h2 : Real.log x * (a ^ 2 / (2 * c ^ 2) * Real.log x)
        < (a / c) ^ 2 * Real.log x ^ 2 := by
      have hpos : 0 < Real.log x ^ 2 := by positivity
      have : a ^ 2 / (2 * c ^ 2) < (a / c) ^ 2 := by
        rw [div_pow, div_lt_div_iff₀ (by positivity) (by positivity)]
        nlinarith [sq_nonneg a, sq_nonneg c, pow_pos hc 2, pow_pos ha 2]
      nlinarith [this, hpos]
    linarith
  have hsqrt : Real.sqrt (Real.log x * Real.log (Real.log x)) < (a / c) * Real.log x := by
    have hrhs : 0 < (a / c) * Real.log x := by positivity
    rw [show ((a / c) * Real.log x) = Real.sqrt (((a / c) * Real.log x) ^ 2) from
      (Real.sqrt_sq hrhs.le).symm]
    apply Real.sqrt_lt_sqrt (mul_nonneg hLpos.le hLL0)
    calc Real.log x * Real.log (Real.log x) < (a / c) ^ 2 * Real.log x ^ 2 := hkey
      _ = ((a / c) * Real.log x) ^ 2 := by ring
  calc c * Real.sqrt (Real.log x * Real.log (Real.log x))
      < c * ((a / c) * Real.log x) := by exact mul_lt_mul_of_pos_left hsqrt hc
    _ = a * Real.log x := by field_simp

/-- **The fitted exponent of the subexponential arm is `0`.**  The across-`k` slope
`log L(x)/log x` tends to `0`, so every positive measured slope — `0.761`, `0.718`, or
any other — is an artefact of the finite observation window. -/
theorem subexp_exponent_tendsto_zero {c : ℝ} (hc : 0 < c) :
    Tendsto (fun x : ℝ => Real.log (Lfun c x) / Real.log x) atTop (𝓝 0) := by
  rw [NormedAddCommGroup.tendsto_nhds_zero]
  intro eps heps
  filter_upwards [subexp_lt_power hc heps, Real.tendsto_log_atTop.eventually_ge_atTop 1]
    with x hx hL1
  have hLpos : (0 : ℝ) < Real.log x := by linarith
  have hnn : 0 ≤ Real.log (Lfun c x) := by
    rw [log_Lfun]; positivity
  rw [Real.norm_eq_abs, abs_of_nonneg (by positivity)]
  rw [div_lt_iff₀ hLpos]
  linarith [hx]

/-- **The two-point slope of the experiment also collapses.**  The experiment does not
fit a limit, it fits a chord: it compares two target sizes and divides.  Taking the
doubling window `log₂ p ↦ 2 log₂ p` (i.e. `x ↦ x²`), the measured chord slope of the
subexponential arm still tends to `0`.  No window placed far enough out can report a
positive exponent. -/
theorem subexp_doubling_slope_tendsto_zero {c : ℝ} (hc : 0 < c) :
    Tendsto (fun x : ℝ =>
        (Real.log (Lfun c (x ^ 2)) - Real.log (Lfun c x)) / (Real.log (x ^ 2) - Real.log x))
      atTop (𝓝 0) := by
  rw [NormedAddCommGroup.tendsto_nhds_zero]
  intro eps heps
  have hsq : Tendsto (fun x : ℝ => x ^ 2) atTop atTop := tendsto_pow_atTop (by norm_num)
  have h4 : (0 : ℝ) < eps / 4 := by linarith
  have h2 : (0 : ℝ) < eps / 2 := by linarith
  filter_upwards [hsq.eventually (subexp_lt_power hc h4), subexp_lt_power hc h2,
    Real.tendsto_log_atTop.eventually_ge_atTop 1,
    eventually_gt_atTop (0 : ℝ)] with x hxsq hx hL1 hx0
  have hLpos : (0 : ℝ) < Real.log x := by linarith
  have hden : Real.log (x ^ 2) - Real.log x = Real.log x := by
    rw [Real.log_pow]; push_cast; ring
  have hnn1 : 0 ≤ Real.log (Lfun c x) := by rw [log_Lfun]; positivity
  have hnn2 : 0 ≤ Real.log (Lfun c (x ^ 2)) := by rw [log_Lfun]; positivity
  have hupper : Real.log (Lfun c (x ^ 2)) < (eps / 2) * Real.log x := by
    have : Real.log (x ^ 2) = 2 * Real.log x := by rw [Real.log_pow]; push_cast; ring
    rw [this] at hxsq
    linarith
  have hepsL : 0 < eps * Real.log x := by positivity
  rw [hden, Real.norm_eq_abs, abs_div, abs_of_pos hLpos, div_lt_iff₀ hLpos, abs_lt]
  constructor <;> linarith

/-! ## 3. Bridge to the tropical plane: the `L` arm is the eventual leader -/

/-- **Every affine arm with positive exponent is eventually beaten.**  For any profile
`M` of the measured plane with `M.slope > 0` — trial division, Fermat, rho, both ECM
columns — the subexponential arm is eventually cheaper, in the common currency of bits,
whatever the intercepts. -/
theorem subexp_beats_every_arm {c : ℝ} (hc : 0 < c) (M : ECMPlane.Profile)
    (hM : 0 < M.slope) :
    ∀ᶠ x : ℝ in atTop,
      Real.logb 2 (Lfun c x) < ECMPlane.work M (Real.logb 2 x) := by
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hhalf : 0 < M.slope / 2 := by linarith
  have hgrow : ∀ᶠ x : ℝ in atTop, 0 ≤ M.icept * Real.log 2 + (M.slope / 2) * Real.log x := by
    have := Real.tendsto_log_atTop.eventually_ge_atTop
      ((2 / M.slope) * |M.icept * Real.log 2|)
    filter_upwards [this] with x hx
    have h1 : |M.icept * Real.log 2| ≤ (M.slope / 2) * Real.log x := by
      have h := mul_le_mul_of_nonneg_left hx hhalf.le
      have hid : (M.slope / 2) * (2 / M.slope * |M.icept * Real.log 2|)
          = |M.icept * Real.log 2| := by
        field_simp
      rw [hid] at h
      linarith
    have := neg_abs_le (M.icept * Real.log 2)
    linarith
  filter_upwards [subexp_lt_power hc hhalf, hgrow] with x hx hx2
  have hkey : Real.log (Lfun c x) < M.icept * Real.log 2 + M.slope * Real.log x := by
    linarith
  unfold ECMPlane.work Real.logb
  rw [div_lt_iff₀ hlog2]
  have : (M.icept + M.slope * (Real.log x / Real.log 2)) * Real.log 2
      = M.icept * Real.log 2 + M.slope * Real.log x := by field_simp
  rw [this]
  exact hkey

/-- **…and yet the `L` arm is not the constant arm.**  Its log-work diverges, so
"exponent `0`" does not mean "bounded work": the affine plane of profiles is not closed
under the true ECM cost.  This is the structural reason a finite window is forced to
report a spurious interior exponent. -/
theorem log_subexp_tendsto_atTop {c : ℝ} (hc : 0 < c) :
    Tendsto (fun x : ℝ => Real.log (Lfun c x)) atTop atTop := by
  have hcomp : Tendsto (fun x : ℝ => c * Real.sqrt (Real.log x)) atTop atTop := by
    have h1 : Tendsto (fun x : ℝ => Real.sqrt (Real.log x)) atTop atTop :=
      tendsto_sqrt_atTop.comp Real.tendsto_log_atTop
    exact Filter.Tendsto.const_mul_atTop hc h1
  apply tendsto_atTop_mono' atTop _ hcomp
  filter_upwards [Real.tendsto_log_atTop.eventually_ge_atTop (Real.exp 1)] with x hx
  have hLpos : (0 : ℝ) < Real.log x := lt_of_lt_of_le (Real.exp_pos 1) hx
  have hLL : 1 ≤ Real.log (Real.log x) := by
    have := Real.log_le_log (Real.exp_pos 1) hx
    rwa [Real.log_exp] at this
  have hmono : Real.sqrt (Real.log x) ≤ Real.sqrt (Real.log x * Real.log (Real.log x)) := by
    apply Real.sqrt_le_sqrt
    nlinarith [hLpos, hLL]
  rw [log_Lfun]
  exact mul_le_mul_of_nonneg_left hmono hc.le

/-- **The exponent hierarchy is strict at `0`.**  Combining the two previous results: the
subexponential arm has fitted exponent `0` but unbounded work, while any affine arm with
exponent `0` has bounded work.  No profile of the plane can therefore represent it. -/
theorem no_profile_represents_subexp {c : ℝ} (hc : 0 < c) :
    ¬ ∃ M : ECMPlane.Profile,
        ∀ᶠ x : ℝ in atTop, Real.logb 2 (Lfun c x) = ECMPlane.work M (Real.logb 2 x) := by
  rintro ⟨M, hM⟩
  rcases lt_trichotomy M.slope 0 with hneg | hzero | hpos
  · -- a negative exponent would make the affine arm tend to `-∞`, the `L` arm to `+∞`
    have hdiv : Tendsto (fun x : ℝ => Real.logb 2 (Lfun c x)) atTop atTop := by
      unfold Real.logb
      exact Tendsto.atTop_div_const (Real.log_pos (by norm_num)) (log_subexp_tendsto_atTop hc)
    have hneg' : Tendsto (fun x : ℝ => ECMPlane.work M (Real.logb 2 x)) atTop atBot := by
      unfold ECMPlane.work
      have hlogb : Tendsto (fun x : ℝ => Real.logb 2 x) atTop atTop :=
        tendsto_logb_atTop (by norm_num)
      exact tendsto_atBot_add_const_left _ _ (hlogb.const_mul_atTop_of_neg hneg)
    have h1 : ∀ᶠ x : ℝ in atTop, (0 : ℝ) ≤ Real.logb 2 (Lfun c x) := hdiv.eventually_ge_atTop 0
    have h2 : ∀ᶠ x : ℝ in atTop, ECMPlane.work M (Real.logb 2 x) ≤ -1 :=
      hneg'.eventually_le_atBot (-1)
    rcases (h1.and (h2.and hM)).exists with ⟨x, hx1, hx2, hx3⟩
    rw [hx3] at hx1
    linarith
  · -- exponent `0`: bounded work, contradicting divergence
    have hdiv : Tendsto (fun x : ℝ => Real.logb 2 (Lfun c x)) atTop atTop := by
      unfold Real.logb
      exact Tendsto.atTop_div_const (Real.log_pos (by norm_num)) (log_subexp_tendsto_atTop hc)
    have hbdd : ∀ x : ℝ, ECMPlane.work M (Real.logb 2 x) = M.icept := by
      intro x; simp [ECMPlane.work, hzero]
    have h1 : ∀ᶠ x : ℝ in atTop, M.icept + 1 ≤ Real.logb 2 (Lfun c x) :=
      hdiv.eventually_ge_atTop (M.icept + 1)
    rcases (h1.and hM).exists with ⟨x, hx1, hx2⟩
    rw [hx2, hbdd x] at hx1
    linarith
  · -- positive exponent: the `L` arm is eventually strictly cheaper
    rcases ((subexp_beats_every_arm hc M hpos).and hM).exists with ⟨x, hx1, hx2⟩
    rw [hx2] at hx1
    exact lt_irrefl _ hx1

end ECMSubexp