import Mathlib

/-!
# Edge-spike censoring: why the steepness of a left-edge spike is a lower bound only

## Motivation (exp 594 / paper 245, round-88 identifiability audit)

A pooled positional histogram was fitted with a two-component profile,
*flat bulk + left-edge spike*, where the spike is an exponential law with rate
`b` truncated to the unit interval.  Empirically the fitted `b_edge` "rode the
cap": it landed at `40.000` when the optimiser was capped at `40` and at `40.46`
when capped at `80`, with a bootstrap CI `[15.25, 80.0]` whose upper end is the
cap itself.  The registered analysis therefore had to be amended to
*"left-edge spike with `b_edge ≳ 15`, **lower bound only**"*.

This file proves that this behaviour is **not** an artefact of the optimiser:
it is a theorem about the model class.  Once the observable is the *mass in the
edge bin* `[0, t]`, the map `b ↦` (edge mass) is strictly increasing but
bounded, and it approaches its ceiling at rate `exp (-b t)`.  Consequently:

* `EdgeSpike.binLogLik_cap_riding` — the binned log-likelihood is **strictly
  increasing in `b`** whenever the empirical edge fraction is at least the
  ceiling `edgeProbLimit`.  Hence for every cap `B` the constrained optimum sits
  exactly at `b = B`: cap-riding is forced.
* `EdgeSpike.no_finite_maximiser` — no finite maximiser exists, so no cap raise
  produces an interior optimum.
* `EdgeSpike.cap_gain_le` — the total remaining log-likelihood available above a
  cap `B` is at most `C · exp (-B t)`.  Raising the cap buys exponentially
  little: at the audited geometry this is why `dAICc` moved only from `-101.28`
  to `-101.33` between caps `40` and `80`.

The three statements together are the formal content of the verdict
`H0_SPIKE_STEEPNESS_UNIDENTIFIABLE`: the data censor the steepness parameter.
-/

namespace EdgeSpike

open Real Filter Topology

/-- CDF at `t` of the exponential law with rate `b` truncated to `[0,1]`;
this is the mass that a left-edge spike of steepness `b` puts in the edge bin
`[0, t]`. -/
noncomputable def truncExpCDF (b t : ℝ) : ℝ := (1 - exp (-(b * t))) / (1 - exp (-b))

/-- Edge-bin probability of the *flat bulk + left-edge spike* profile:
a fraction `1 - rho` of the mass is uniform on `[0,1]` and a fraction `rho`
follows the truncated exponential of steepness `b`. -/
noncomputable def edgeProb (rho t b : ℝ) : ℝ := (1 - rho) * t + rho * truncExpCDF b t

/-- The `b → ∞` ceiling of `edgeProb`: the spike degenerates to a point mass at
the left edge, i.e. the whole spike component lands in the edge bin. -/
noncomputable def edgeProbLimit (rho t : ℝ) : ℝ := (1 - rho) * t + rho

/-- Per-observation binned log-likelihood of the two-cell (edge vs. bulk) table
with empirical edge fraction `h` and model edge probability `p`. -/
noncomputable def binLogLik (h p : ℝ) : ℝ := h * log p + (1 - h) * log (1 - p)

section Basic

variable {b t : ℝ}

lemma one_sub_exp_neg_pos (hb : 0 < b) : 0 < 1 - exp (-b) := by
  have : exp (-b) < 1 := Real.exp_lt_one_iff.mpr (by linarith)
  linarith

lemma truncExpCDF_pos (hb : 0 < b) (ht : 0 < t) : 0 < truncExpCDF b t := by
  have hden := one_sub_exp_neg_pos hb
  have hnum : 0 < 1 - exp (-(b * t)) := by
    have : exp (-(b * t)) < 1 := Real.exp_lt_one_iff.mpr (by nlinarith)
    linarith
  exact div_pos hnum hden

lemma truncExpCDF_lt_one (hb : 0 < b) (ht1 : t < 1) :
    truncExpCDF b t < 1 := by
  have hden := one_sub_exp_neg_pos hb
  have hlt : exp (-b) < exp (-(b * t)) := by
    apply Real.exp_lt_exp.mpr; nlinarith
  unfold truncExpCDF
  rw [div_lt_one hden]
  linarith

lemma truncExpCDF_le_one (hb : 0 < b) (ht1 : t ≤ 1) : truncExpCDF b t ≤ 1 := by
  have hden := one_sub_exp_neg_pos hb
  have hlt : exp (-b) ≤ exp (-(b * t)) := by
    apply Real.exp_le_exp.mpr; nlinarith
  unfold truncExpCDF
  rw [div_le_one hden]
  linarith

end Basic

section Convexity

/-- Strict convexity of `exp` on `[0, b]`: the chord inequality that drives the
monotonicity of the censored edge mass. -/
lemma exp_mul_lt (b t : ℝ) (hb : 0 < b) (ht0 : 0 < t) (ht1 : t < 1) :
    exp (b * t) - 1 < t * (exp b - 1) := by
  have hne : b ≠ (0 : ℝ) := ne_of_gt hb
  have h := strictConvexOn_exp.2 (Set.mem_univ b) (Set.mem_univ (0 : ℝ)) hne ht0
    (show (0 : ℝ) < 1 - t by linarith) (show t + (1 - t) = 1 by ring)
  simp only [smul_eq_mul, mul_zero, add_zero, Real.exp_zero, mul_one] at h
  rw [mul_comm b t]
  nlinarith [h]

end Convexity

section Monotone

variable {t : ℝ}

lemma hasDerivAt_truncExpCDF (b t : ℝ) (hb : 0 < b) :
    HasDerivAt (fun x => truncExpCDF x t)
      ((t * exp (-(b * t)) * (1 - exp (-b)) - (1 - exp (-(b * t))) * exp (-b)) /
        (1 - exp (-b)) ^ 2) b := by
  have hden : (1 : ℝ) - exp (-b) ≠ 0 := ne_of_gt (one_sub_exp_neg_pos hb)
  have hnum : HasDerivAt (fun x : ℝ => 1 - exp (-(x * t))) (t * exp (-(b * t))) b := by
    have h1 : HasDerivAt (fun x : ℝ => -(x * t)) (-t) b := by
      simpa using ((hasDerivAt_id b).mul_const t).neg
    have h2 := h1.exp
    have h3 := h2.const_sub (1 : ℝ)
    convert h3 using 1
    ring
  have hd : HasDerivAt (fun x : ℝ => 1 - exp (-x)) (exp (-b)) b := by
    have h1 : HasDerivAt (fun x : ℝ => -x) (-1 : ℝ) b := by simpa using (hasDerivAt_id b).neg
    have h2 := h1.exp
    have h3 := h2.const_sub (1 : ℝ)
    convert h3 using 1
    ring
  exact hnum.div hd hden

/-- The numerator of `d/db (truncExpCDF b t)` is positive: this is exactly the
strict convexity inequality `exp (b t) - 1 < t (exp b - 1)`. -/
lemma truncExpCDF_deriv_num_pos (b t : ℝ) (hb : 0 < b) (ht0 : 0 < t) (ht1 : t < 1) :
    0 < t * exp (-(b * t)) * (1 - exp (-b)) - (1 - exp (-(b * t))) * exp (-b) := by
  have hconv := exp_mul_lt b t hb ht0 ht1
  have hA : (0 : ℝ) < exp (b * t) := Real.exp_pos _
  have hB : (0 : ℝ) < exp b := Real.exp_pos _
  have e1 : exp (-(b * t)) = (exp (b * t))⁻¹ := by rw [Real.exp_neg]
  have e2 : exp (-b) = (exp b)⁻¹ := by rw [Real.exp_neg]
  rw [e1, e2]
  rw [show t * (exp (b * t))⁻¹ * (1 - (exp b)⁻¹) - (1 - (exp (b * t))⁻¹) * (exp b)⁻¹ =
      (t * (exp b - 1) - (exp (b * t) - 1)) / (exp (b * t) * exp b) by
    field_simp]
  exact div_pos (by linarith) (mul_pos hA hB)

lemma truncExpCDF_deriv_pos (b t : ℝ) (hb : 0 < b) (ht0 : 0 < t) (ht1 : t < 1) :
    0 < deriv (fun x => truncExpCDF x t) b := by
  rw [(hasDerivAt_truncExpCDF b t hb).deriv]
  have hden : (0 : ℝ) < (1 - exp (-b)) ^ 2 := by
    have := one_sub_exp_neg_pos hb; positivity
  exact div_pos (truncExpCDF_deriv_num_pos b t hb ht0 ht1) hden

/-- **The censored edge mass is strictly increasing in the steepness.** -/
theorem truncExpCDF_strictMonoOn (ht0 : 0 < t) (ht1 : t < 1) :
    StrictMonoOn (fun x => truncExpCDF x t) (Set.Ioi 0) := by
  apply strictMonoOn_of_deriv_pos (convex_Ioi 0)
  · intro x hx
    exact ((hasDerivAt_truncExpCDF x t hx).continuousAt).continuousWithinAt
  · intro x hx
    rw [interior_Ioi] at hx
    exact truncExpCDF_deriv_pos x t hx ht0 ht1

end Monotone

section Censoring

variable {b t : ℝ}

/-- **Hard censoring bound.**  The edge mass is within `2 exp (-b t)` of its
ceiling `1`: beyond `b ≈ 1/t` the data can no longer see the steepness. -/
theorem one_sub_truncExpCDF_le (hb : 1 ≤ b) (ht1 : t ≤ 1) :
    1 - truncExpCDF b t ≤ 2 * exp (-(b * t)) := by
  have hb0 : (0 : ℝ) < b := lt_of_lt_of_le zero_lt_one hb
  have hden := one_sub_exp_neg_pos hb0
  have hhalf : (1 : ℝ) / 2 ≤ 1 - exp (-b) := by
    have h1 : exp (-b) ≤ exp (-1 : ℝ) := Real.exp_le_exp.mpr (by linarith)
    have h2 : exp (-1 : ℝ) < 1 / 2 := by
      rw [Real.exp_neg]
      have he : (2 : ℝ) < exp 1 := by
        have := Real.exp_one_gt_d9
        linarith
      rw [inv_lt_comm₀ (Real.exp_pos _) (by norm_num)]
      linarith
    linarith
  have key : 1 - truncExpCDF b t = (exp (-(b * t)) - exp (-b)) / (1 - exp (-b)) := by
    unfold truncExpCDF
    field_simp
    ring
  rw [key, div_le_iff₀ hden]
  have hnn : 0 ≤ exp (-(b * t)) - exp (-b) := by
    have : exp (-b) ≤ exp (-(b * t)) := Real.exp_le_exp.mpr (by nlinarith)
    linarith
  nlinarith [Real.exp_pos (-(b * t)), Real.exp_pos (-b)]

/-- The edge mass tends to its ceiling as the steepness grows. -/
theorem truncExpCDF_tendsto (ht0 : 0 < t) (ht1 : t ≤ 1) :
    Tendsto (fun b => truncExpCDF b t) atTop (𝓝 1) := by
  have hrhs : Tendsto (fun b : ℝ => 2 * exp (-(b * t))) atTop (𝓝 0) := by
    have h1 : Tendsto (fun b : ℝ => -(b * t)) atTop atBot := by
      have h2 : Tendsto (fun b : ℝ => b * t) atTop atTop :=
        Filter.Tendsto.atTop_mul_const ht0 tendsto_id
      exact tendsto_neg_atTop_atBot.comp h2
    simpa using (Real.tendsto_exp_atBot.comp h1).const_mul 2
  have hsq : Tendsto (fun b : ℝ => 1 - truncExpCDF b t) atTop (𝓝 0) := by
    apply squeeze_zero' (g := fun b : ℝ => 2 * exp (-(b * t)))
    · filter_upwards [eventually_ge_atTop (1 : ℝ)] with b hb
      have hb0 : (0 : ℝ) < b := lt_of_lt_of_le zero_lt_one hb
      have := truncExpCDF_le_one hb0 ht1
      linarith
    · filter_upwards [eventually_ge_atTop (1 : ℝ)] with b hb
      exact one_sub_truncExpCDF_le hb ht1
    · exact hrhs
  have hfin := hsq.const_sub (1 : ℝ)
  simpa using hfin

end Censoring

section Likelihood

variable {h p q rho t b : ℝ}

/-- On `(0, h]` the two-cell log-likelihood is strictly increasing in the model
edge probability. -/
theorem binLogLik_lt (hh0 : 0 < h) (hh1 : h < 1) (hp : 0 < p) (hpq : p < q)
    (hqh : q ≤ h) : binLogLik h p < binLogLik h q := by
  have hq0 : 0 < q := lt_trans hp hpq
  have hq1 : q < 1 := lt_of_le_of_lt hqh hh1
  have hp1 : p < 1 := lt_trans hpq hq1
  have hq0' : q ≠ 0 := ne_of_gt hq0
  have hp0' : p ≠ 0 := ne_of_gt hp
  have hq1' : (1 : ℝ) - q ≠ 0 := by intro hc; linarith
  have hp1' : (1 : ℝ) - p ≠ 0 := by intro hc; linarith
  -- strict logarithmic lower bounds on both increments
  have hL : (q - p) / q < log q - log p := by
    have hx : (0 : ℝ) < p / q := div_pos hp hq0
    have hne : p / q ≠ 1 := by
      intro hc
      rw [div_eq_one_iff_eq hq0'] at hc
      linarith
    have hlog := Real.log_lt_sub_one_of_pos hx hne
    rw [Real.log_div hp0' hq0'] at hlog
    have hqq : p / q - 1 = -((q - p) / q) := by field_simp; ring
    rw [hqq] at hlog
    linarith
  have hM : -((q - p) / (1 - q)) < log (1 - q) - log (1 - p) := by
    have hx : (0 : ℝ) < (1 - p) / (1 - q) := div_pos (by linarith) (by linarith)
    have hne : (1 - p) / (1 - q) ≠ 1 := by
      intro hc
      rw [div_eq_one_iff_eq hq1'] at hc
      linarith
    have hlog := Real.log_lt_sub_one_of_pos hx hne
    rw [Real.log_div hp1' hq1'] at hlog
    have hqq : (1 - p) / (1 - q) - 1 = (q - p) / (1 - q) := by field_simp; ring
    rw [hqq] at hlog
    linarith
  -- the first-order terms already have the right sign, because `q ≤ h`
  have hcmp : (1 - h) * ((q - p) / (1 - q)) ≤ h * ((q - p) / q) := by
    rw [show (1 - h) * ((q - p) / (1 - q)) = ((1 - h) * (q - p)) / (1 - q) by ring,
      show h * ((q - p) / q) = (h * (q - p)) / q by ring,
      div_le_div_iff₀ (show (0 : ℝ) < 1 - q by linarith) hq0]
    nlinarith [mul_nonneg (sub_pos.mpr hpq).le (sub_nonneg.mpr hqh)]
  have hA : h * ((q - p) / q) < h * (log q - log p) := mul_lt_mul_of_pos_left hL hh0
  have hB : (1 - h) * (-((q - p) / (1 - q))) < (1 - h) * (log (1 - q) - log (1 - p)) :=
    mul_lt_mul_of_pos_left hM (by linarith)
  unfold binLogLik
  nlinarith [hA, hB, hcmp]

lemma edgeProb_lt_limit (hrho : 0 < rho) (hb : 0 < b) (ht1 : t < 1) :
    edgeProb rho t b < edgeProbLimit rho t := by
  unfold edgeProb edgeProbLimit
  have := truncExpCDF_lt_one hb ht1
  nlinarith

lemma edgeProb_pos (hrho0 : 0 < rho) (hrho1 : rho < 1) (hb : 0 < b) (ht0 : 0 < t) :
    0 < edgeProb rho t b := by
  unfold edgeProb
  have := truncExpCDF_pos hb ht0
  nlinarith

lemma edgeProb_strictMonoOn (hrho : 0 < rho) (ht0 : 0 < t) (ht1 : t < 1) :
    StrictMonoOn (fun b => edgeProb rho t b) (Set.Ioi 0) := by
  intro x hx y hy hxy
  have hmono : truncExpCDF x t < truncExpCDF y t :=
    truncExpCDF_strictMonoOn ht0 ht1 hx hy hxy
  show edgeProb rho t x < edgeProb rho t y
  unfold edgeProb
  nlinarith

/-- **Cap-riding is forced.**  If the empirical edge fraction is at least the
`b → ∞` ceiling of the model, then the binned log-likelihood is strictly
increasing in the steepness `b`; hence, for any cap `B`, the constrained
maximiser is the cap itself. -/
theorem binLogLik_cap_riding (hrho0 : 0 < rho) (hrho1 : rho < 1) (ht0 : 0 < t)
    (ht1 : t < 1) (hh : edgeProbLimit rho t ≤ h) (hh1 : h < 1) {b B : ℝ}
    (hb : 0 < b) (hbB : b < B) :
    binLogLik h (edgeProb rho t b) < binLogLik h (edgeProb rho t B) := by
  have hB : 0 < B := lt_trans hb hbB
  have hmono : edgeProb rho t b < edgeProb rho t B :=
    edgeProb_strictMonoOn hrho0 ht0 ht1 (Set.mem_Ioi.mpr hb) (Set.mem_Ioi.mpr hB) hbB
  have hpos := edgeProb_pos hrho0 hrho1 hb ht0
  have hBlt : edgeProb rho t B < edgeProbLimit rho t := edgeProb_lt_limit hrho0 hB ht1
  have hLpos : 0 < edgeProbLimit rho t := by
    unfold edgeProbLimit; nlinarith
  exact binLogLik_lt (lt_of_lt_of_le hLpos hh) hh1 hpos hmono
    (le_trans hBlt.le hh)

/-- **No finite maximiser.**  Every steepness value is beaten by a larger one:
the MLE does not exist in `(0, ∞)`, so no cap raise can produce an interior
optimum — only a new boundary solution. -/
theorem no_finite_maximiser (hrho0 : 0 < rho) (hrho1 : rho < 1) (ht0 : 0 < t)
    (ht1 : t < 1) (hh : edgeProbLimit rho t ≤ h) (hh1 : h < 1) (hb : 0 < b) :
    ∃ b' > b, binLogLik h (edgeProb rho t b) < binLogLik h (edgeProb rho t b') :=
  ⟨b + 1, by linarith,
    binLogLik_cap_riding hrho0 hrho1 ht0 ht1 hh hh1 hb (by linarith)⟩

/-- **Exponentially small cap gains.**  All the log-likelihood that remains
above a cap `b` is bounded by `C · exp (-b t)` with
`C = 2 rho / min ((1-rho) t) (1 - edgeProbLimit rho t)`.  Raising the cap
therefore buys exponentially little, whatever the data. -/
theorem cap_gain_le (hrho0 : 0 < rho) (hrho1 : rho < 1) (ht0 : 0 < t) (ht1 : t < 1)
    (hh0 : 0 ≤ h) (hh1 : h ≤ 1) (hb : 1 ≤ b) :
    binLogLik h (edgeProbLimit rho t) - binLogLik h (edgeProb rho t b) ≤
      (2 * rho / min ((1 - rho) * t) (1 - edgeProbLimit rho t)) * exp (-(b * t)) := by
  have hb0 : (0 : ℝ) < b := lt_of_lt_of_le zero_lt_one hb
  set p := edgeProb rho t b with hpdef
  set P := edgeProbLimit rho t with hPdef
  have hPlt : P < 1 := by rw [hPdef]; unfold edgeProbLimit; nlinarith
  have hlow : (1 - rho) * t ≤ p := by
    rw [hpdef]; unfold edgeProb
    have := truncExpCDF_pos hb0 ht0
    nlinarith
  have hlowpos : 0 < (1 - rho) * t := by nlinarith
  have hppos : 0 < p := lt_of_lt_of_le hlowpos hlow
  have hpP : p < P := edgeProb_lt_limit hrho0 hb0 ht1
  have hdiff : P - p ≤ 2 * rho * exp (-(b * t)) := by
    rw [hpdef, hPdef]; unfold edgeProb edgeProbLimit
    have hcen := one_sub_truncExpCDF_le hb ht1.le
    nlinarith
  have hdiffnn : 0 ≤ P - p := by linarith
  set m := min ((1 - rho) * t) (1 - P) with hmdef
  have hmpos : 0 < m := lt_min hlowpos (by linarith)
  have hm1 : m ≤ p := le_trans (min_le_left _ _) hlow
  have hm2 : m ≤ 1 - P := min_le_right _ _
  have hlog1 : log P - log p ≤ (P - p) / m := by
    have hx : 0 < P / p := div_pos (lt_trans hppos hpP) hppos
    have hlog := Real.log_le_sub_one_of_pos hx
    rw [Real.log_div (ne_of_gt (lt_trans hppos hpP)) (ne_of_gt hppos)] at hlog
    have h2 : P / p - 1 = (P - p) / p := by field_simp
    rw [h2] at hlog
    exact le_trans hlog (div_le_div_of_nonneg_left hdiffnn hmpos hm1)
  have hlog2 : log (1 - P) - log (1 - p) ≤ (P - p) / m := by
    have hmono : log (1 - P) ≤ log (1 - p) :=
      Real.log_le_log (by linarith) (by linarith)
    have hnn : 0 ≤ (P - p) / m := div_nonneg hdiffnn hmpos.le
    linarith
  have hbound : (P - p) / m ≤ (2 * rho / m) * exp (-(b * t)) := by
    rw [show (2 * rho / m) * exp (-(b * t)) = (2 * rho * exp (-(b * t))) / m by ring,
      div_le_div_iff₀ hmpos hmpos]
    nlinarith [mul_le_mul_of_nonneg_right hdiff hmpos.le]
  have hsum : binLogLik h P - binLogLik h p ≤ (P - p) / m := by
    unfold binLogLik
    have hA : h * (log P - log p) ≤ h * ((P - p) / m) :=
      mul_le_mul_of_nonneg_left hlog1 hh0
    have hB : (1 - h) * (log (1 - P) - log (1 - p)) ≤ (1 - h) * ((P - p) / m) :=
      mul_le_mul_of_nonneg_left hlog2 (by linarith)
    nlinarith [hA, hB]
  linarith [hsum, hbound]

end Likelihood

section IdentifiedSet

variable {rho t : ℝ}

/-- **The identified set contains a ray.**  If the observed edge mass `v` sits
within the tolerance `eps` of the ceiling, then *every* steepness above a
threshold `B₀` (any `B₀ ≥ 1` with `2 rho exp (-B₀ t) ≤ eps`) is compatible with
the data: there is no finite upper confidence limit for `b`. -/
theorem identified_ray (hrho0 : 0 < rho) (hrho1 : rho < 1) (ht0 : 0 < t) (ht1 : t < 1)
    {v eps B₀ b : ℝ} (hv1 : edgeProbLimit rho t - eps ≤ v)
    (hv2 : v ≤ edgeProbLimit rho t) (hB0 : 1 ≤ B₀)
    (hB0' : 2 * rho * exp (-(B₀ * t)) ≤ eps) (hb : B₀ ≤ b) :
    |edgeProb rho t b - v| ≤ eps := by
  have hb1 : (1 : ℝ) ≤ b := le_trans hB0 hb
  have hb0 : (0 : ℝ) < b := lt_of_lt_of_le zero_lt_one hb1
  have hple : edgeProb rho t b < edgeProbLimit rho t := edgeProb_lt_limit hrho0 hb0 ht1
  have hcen := one_sub_truncExpCDF_le hb1 ht1.le
  have hgap : edgeProbLimit rho t - edgeProb rho t b ≤ 2 * rho * exp (-(b * t)) := by
    unfold edgeProb edgeProbLimit
    nlinarith
  have hmono : exp (-(b * t)) ≤ exp (-(B₀ * t)) :=
    Real.exp_le_exp.mpr (by nlinarith)
  have hsmall : edgeProbLimit rho t - edgeProb rho t b ≤ eps := by
    have : 2 * rho * exp (-(b * t)) ≤ 2 * rho * exp (-(B₀ * t)) := by nlinarith
    linarith
  rw [abs_le]
  constructor <;> linarith

/-- Such a threshold always exists: the identified set is genuinely unbounded
above. -/
theorem exists_ray_threshold (ht0 : 0 < t) {eps : ℝ} (heps : 0 < eps) :
    ∃ B₀ : ℝ, 1 ≤ B₀ ∧ 2 * rho * exp (-(B₀ * t)) ≤ eps := by
  have hlim : Tendsto (fun b : ℝ => 2 * rho * exp (-(b * t))) atTop (𝓝 0) := by
    have h1 : Tendsto (fun b : ℝ => -(b * t)) atTop atBot := by
      have h2 : Tendsto (fun b : ℝ => b * t) atTop atTop :=
        Filter.Tendsto.atTop_mul_const ht0 tendsto_id
      exact tendsto_neg_atTop_atBot.comp h2
    simpa using (Real.tendsto_exp_atBot.comp h1).const_mul (2 * rho)
  have hev : ∀ᶠ b : ℝ in atTop, 2 * rho * exp (-(b * t)) < eps :=
    hlim.eventually (Iio_mem_nhds heps)
  obtain ⟨B, hB⟩ := (hev.and (eventually_ge_atTop (1 : ℝ))).exists
  exact ⟨B, hB.2, hB.1.le⟩

/-- **Lower bounds do survive.**  Any steepness whose edge mass falls short of
the observed value by more than the tolerance is excluded, and by strict
monotonicity so is every smaller steepness.  Together with `identified_ray`
this is the amended verdict: the identified set for `b` is of the form
"`b ≳ b₁`", with no upper limit. -/
theorem below_threshold_excluded (hrho0 : 0 < rho) (ht0 : 0 < t) (ht1 : t < 1)
    {v eps b b₁ : ℝ} (heps : 0 ≤ eps) (hb : 0 < b) (hbb : b ≤ b₁)
    (hexcl : edgeProb rho t b₁ + eps < v) :
    eps < |edgeProb rho t b - v| := by
  have hb1 : 0 < b₁ := lt_of_lt_of_le hb hbb
  have hmono : edgeProb rho t b ≤ edgeProb rho t b₁ := by
    rcases eq_or_lt_of_le hbb with h | h
    · rw [h]
    · exact (edgeProb_strictMonoOn hrho0 ht0 ht1 (Set.mem_Ioi.mpr hb)
        (Set.mem_Ioi.mpr hb1) h).le
  have hlt : edgeProb rho t b + eps < v := by linarith
  have : eps < v - edgeProb rho t b := by linarith
  calc eps < v - edgeProb rho t b := this
    _ = |edgeProb rho t b - v| := by
        rw [abs_sub_comm, abs_of_pos (by linarith)]

/-- **Population identification does hold.**  Whenever the observed edge mass is
bracketed by two model values, exactly one steepness reproduces it.  So the
non-identifiability audited here is a *tolerance* phenomenon (the ray of
`identified_ray`), not a failure of the population map: the model is injective
in `b`, but its image is exponentially compressed near the ceiling. -/
theorem unique_steepness_of_bracket (hrho0 : 0 < rho) (ht0 : 0 < t) (ht1 : t < 1)
    {v b₀ b₁ : ℝ} (hb0 : 0 < b₀) (hb01 : b₀ ≤ b₁)
    (h1 : edgeProb rho t b₀ ≤ v) (h2 : v ≤ edgeProb rho t b₁) :
    ∃! b : ℝ, b ∈ Set.Icc b₀ b₁ ∧ edgeProb rho t b = v := by
  have hcont : ContinuousOn (fun b => edgeProb rho t b) (Set.Icc b₀ b₁) := by
    intro x hx
    have hx0 : 0 < x := lt_of_lt_of_le hb0 hx.1
    have hca : ContinuousAt (fun b => edgeProb rho t b) x := by
      have h := (hasDerivAt_truncExpCDF x t hx0).continuousAt
      unfold edgeProb
      exact continuousAt_const.add (continuousAt_const.mul h)
    exact hca.continuousWithinAt
  obtain ⟨b, hbmem, hbv⟩ := intermediate_value_Icc hb01 hcont ⟨h1, h2⟩
  refine ⟨b, ⟨hbmem, hbv⟩, ?_⟩
  rintro b' ⟨hb'mem, hb'v⟩
  have hinj := (edgeProb_strictMonoOn hrho0 ht0 ht1).injOn
  exact hinj (Set.mem_Ioi.mpr (lt_of_lt_of_le hb0 hb'mem.1))
    (Set.mem_Ioi.mpr (lt_of_lt_of_le hb0 hbmem.1)) (by simpa using hb'v.trans hbv.symm)

end IdentifiedSet

end EdgeSpike