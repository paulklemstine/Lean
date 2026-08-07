import Mathlib

/-!
# Deriving the grokking delay from weight-decayed training dynamics

In `Catalog/MachineLearning/GrokkingPhaseTransition.lean` the delay of the
two-layer ReLU network is *prescribed*: the bias is `-delay` by fiat.  This file
carries out Future Direction 2 (training dynamics) and part of Direction 6
(connection theorem): the delay is *derived* as the crossing time of a
weight-decayed gradient flow / gradient descent, and the bifurcation parameter of
the saddle-node normal form becomes an explicit function of the weight-decay
strength.

Main results.

* `wdFlow_hasDerivAt`, `wdFlow_isGradientFlow`, `wdFlow_init`: the explicit
  trajectory `w(t) = s/λ + (w₀ - s/λ) e^{-λ t}` is *the* gradient flow of the
  weight-decayed loss `λ w²/2 - s w`.
* `wdFlow_strictMono`, `wdFlow_lt_limit`: the trained weight increases strictly
  towards, but never reaches, the regularized optimum `s/λ`.
* `wdFlow_gt_threshold_iff`: the trajectory exceeds a fixed activation threshold
  `θ` *exactly* after the explicit time `crossTime = λ⁻¹ log((s/λ-w₀)/(s/λ-θ))`.
* `trained_relu_delayed_transition`: consequently the trained ReLU unit outputs
  exactly `0` up to `crossTime` and is strictly positive afterwards — the
  catalog's delayed transition, now with a *derived* delay.
* `crossing_exists_iff_subcritical_decay`: the threshold is crossed at all iff
  the weight decay is subcritical, `λ < λ_c := s/θ`, i.e. iff the saddle-node
  parameter `bifParam := s/λ - θ` is positive.  This is the promised connection
  between the optimization/regularization parameter and the normal form.
* `crossTime_diverges_at_criticality`: the delay is unbounded as the weight decay
  approaches its critical value — the grokking time diverges at the bifurcation.
* `gdSeq_closed_form`, `gd_delay_lower_bound`: the discrete weight-decayed
  gradient-descent iteration has the analogous closed form, and the number of
  steps before the threshold is crossed grows like `log(1/gap)`.
-/

namespace GrokkingTraining

open Real

/-! ### The weight-decayed loss and its gradient flow -/

/-- Weight-decayed (ridge) training loss for a single scalar weight: the data
term pushes the weight up with force `s`, the decay term pulls it back. -/
noncomputable def wdLoss (lam s w : ℝ) : ℝ := lam / 2 * w ^ 2 - s * w

/-- The explicit solution of the weight-decayed gradient flow with initial
weight `w₀`. -/
noncomputable def wdFlow (lam s w0 t : ℝ) : ℝ :=
  s / lam + (w0 - s / lam) * Real.exp (-(lam * t))

/-- The gradient of the weight-decayed loss. -/
theorem wdLoss_hasDerivAt (lam s w : ℝ) :
    HasDerivAt (wdLoss lam s) (lam * w - s) w := by
  have h1 : HasDerivAt (fun y : ℝ => lam / 2 * y ^ 2) (lam / 2 * (2 * w)) w := by
    simpa using ((hasDerivAt_id w).pow 2).const_mul (lam / 2)
  have h2 : HasDerivAt (fun y : ℝ => s * y) (s * 1) w := (hasDerivAt_id w).const_mul s
  have h := h1.sub h2
  have heq : lam / 2 * (2 * w) - s * 1 = lam * w - s := by ring
  rw [heq] at h
  exact h

/-- `wdFlow` starts at `w₀`. -/
theorem wdFlow_init (lam s w0 : ℝ) : wdFlow lam s w0 0 = w0 := by
  simp [wdFlow]

/-- `wdFlow` solves the linear ODE `w' = s - λ w`. -/
theorem wdFlow_hasDerivAt (lam s w0 t : ℝ) (hlam : lam ≠ 0) :
    HasDerivAt (wdFlow lam s w0) (s - lam * wdFlow lam s w0 t) t := by
  have hexp : HasDerivAt (fun u : ℝ => Real.exp (-(lam * u)))
      (Real.exp (-(lam * t)) * -(lam * 1)) t := by
    exact (((hasDerivAt_id t).const_mul lam).neg).exp
  have h := (hexp.const_mul (w0 - s / lam)).const_add (s / lam)
  have heq : (w0 - s / lam) * (Real.exp (-(lam * t)) * -(lam * 1))
      = s - lam * wdFlow lam s w0 t := by
    simp only [wdFlow]
    field_simp
    ring
  rw [heq] at h
  exact h

/-- **The trajectory is the gradient flow of the weight-decayed loss.** -/
theorem wdFlow_isGradientFlow (lam s w0 t : ℝ) (hlam : lam ≠ 0) :
    HasDerivAt (wdFlow lam s w0) (-(deriv (wdLoss lam s) (wdFlow lam s w0 t))) t := by
  have hd := (wdLoss_hasDerivAt lam s (wdFlow lam s w0 t)).deriv
  rw [hd]
  have := wdFlow_hasDerivAt lam s w0 t hlam
  convert this using 1
  ring

/-! ### Monotone approach to the regularized optimum -/

/-- Below the regularized optimum the trained weight increases strictly. -/
theorem wdFlow_strictMono (lam s w0 : ℝ) (hlam : 0 < lam) (hw0 : w0 < s / lam) :
    StrictMono (wdFlow lam s w0) := by
  intro a b hab
  have hgap : 0 < s / lam - w0 := by linarith
  have hexp : Real.exp (-(lam * b)) < Real.exp (-(lam * a)) := by
    apply Real.exp_lt_exp.mpr
    have : lam * a < lam * b := by nlinarith
    linarith
  simp only [wdFlow]
  nlinarith
/-- The trained weight never reaches the regularized optimum `s/λ`. -/
theorem wdFlow_lt_limit (lam s w0 t : ℝ) (hw0 : w0 < s / lam) :
    wdFlow lam s w0 t < s / lam := by
  have hgap : 0 < s / lam - w0 := by linarith
  have hexp : 0 < Real.exp (-(lam * t)) := Real.exp_pos _
  simp only [wdFlow]
  nlinarith

/-! ### The crossing time: an explicit, derived delay -/

/-- The time at which the weight-decayed gradient flow reaches the activation
threshold `θ`. -/
noncomputable def crossTime (lam s w0 theta : ℝ) : ℝ :=
  (1 / lam) * Real.log ((s / lam - w0) / (s / lam - theta))

/-- **Exact crossing law.**  The trained weight exceeds the threshold `θ`
precisely after the explicit time `crossTime`. -/
theorem wdFlow_gt_threshold_iff (lam s w0 theta t : ℝ) (hlam : 0 < lam)
    (hw0 : w0 < theta) (hth : theta < s / lam) :
    theta < wdFlow lam s w0 t ↔ crossTime lam s w0 theta < t := by
  have hA : 0 < s / lam - w0 := by linarith
  have hB : 0 < s / lam - theta := by linarith
  have hlog : Real.log ((s / lam - theta) / (s / lam - w0))
      = -Real.log ((s / lam - w0) / (s / lam - theta)) := by
    rw [← Real.log_inv]
    congr 1
    field_simp
  constructor
  · intro h
    simp only [wdFlow] at h
    have hexp : Real.exp (-(lam * t)) < (s / lam - theta) / (s / lam - w0) := by
      rw [lt_div_iff₀ hA]
      nlinarith
    have hpos : 0 < (s / lam - theta) / (s / lam - w0) := div_pos hB hA
    have hlt : -(lam * t) < Real.log ((s / lam - theta) / (s / lam - w0)) :=
      (Real.lt_log_iff_exp_lt hpos).mpr hexp
    rw [hlog] at hlt
    simp only [crossTime]
    rw [div_mul_eq_mul_div, one_mul, div_lt_iff₀ hlam]
    nlinarith
  · intro h
    simp only [crossTime] at h
    rw [div_mul_eq_mul_div, one_mul, div_lt_iff₀ hlam] at h
    have hlt : -(lam * t) < Real.log ((s / lam - theta) / (s / lam - w0)) := by
      rw [hlog]; nlinarith
    have hpos : 0 < (s / lam - theta) / (s / lam - w0) := div_pos hB hA
    have hexp : Real.exp (-(lam * t)) < (s / lam - theta) / (s / lam - w0) := by
      have := Real.exp_lt_exp.mpr hlt
      rwa [Real.exp_log hpos] at this
    rw [lt_div_iff₀ hA] at hexp
    simp only [wdFlow]
    nlinarith

/-- The rectifier. -/
noncomputable def relu (x : ℝ) : ℝ := max x 0

/-- **Delayed transition with a derived delay.**  The ReLU unit driven by the
weight-decayed gradient flow is exactly silent up to `crossTime` and strictly
active afterwards.  This is the catalog's `delayed_generalization`, but the
delay is now produced by the training dynamics rather than assumed. -/
theorem trained_relu_delayed_transition (lam s w0 theta : ℝ) (hlam : 0 < lam)
    (hw0 : w0 < theta) (hth : theta < s / lam) :
    (∀ t ≤ crossTime lam s w0 theta, relu (wdFlow lam s w0 t - theta) = 0) ∧
      (∀ t, crossTime lam s w0 theta < t → 0 < relu (wdFlow lam s w0 t - theta)) := by
  constructor
  · intro t ht
    have hle : wdFlow lam s w0 t ≤ theta := by
      by_contra hcon
      push_neg at hcon
      exact absurd ((wdFlow_gt_threshold_iff lam s w0 theta t hlam hw0 hth).mp hcon)
        (not_lt.mpr ht)
    simp only [relu]
    exact max_eq_right (by linarith)
  · intro t ht
    have hgt := (wdFlow_gt_threshold_iff lam s w0 theta t hlam hw0 hth).mpr ht
    simp only [relu]
    exact lt_max_of_lt_left (by linarith)

/-! ### The weight decay as bifurcation parameter -/

/-- The saddle-node bifurcation parameter attached to a weight-decay strength:
the signed gap between the regularized optimum and the activation threshold. -/
noncomputable def bifParam (lam s theta : ℝ) : ℝ := s / lam - theta

/-- The critical weight decay: `λ_c = s/θ`. -/
noncomputable def criticalDecay (s theta : ℝ) : ℝ := s / theta

/-- The bifurcation parameter is positive exactly below the critical weight
decay. -/
theorem bifParam_pos_iff (lam s theta : ℝ) (hlam : 0 < lam) (hth : 0 < theta) :
    0 < bifParam lam s theta ↔ lam < criticalDecay s theta := by
  simp only [bifParam, criticalDecay, sub_pos]
  rw [lt_div_iff₀ hlam, lt_div_iff₀ hth]
  constructor <;> intro h <;> nlinarith

/-- **Connection theorem (regularization ↦ normal form).**  The activation
threshold is reached at some forward training time iff the weight decay is
subcritical, `λ < λ_c = s/θ`, i.e. iff the saddle-node parameter
`bifParam = s/λ - θ` is positive, i.e. iff the normal form `μ - x²` possesses
the two equilibrium branches `±√μ`. -/
theorem crossing_exists_iff_subcritical_decay (lam s w0 theta : ℝ) (hlam : 0 < lam)
    (hth : 0 < theta) (hw0 : w0 < theta) :
    (∃ t : ℝ, 0 ≤ t ∧ theta < wdFlow lam s w0 t) ↔ lam < criticalDecay s theta := by
  rw [← bifParam_pos_iff lam s theta hlam hth]
  simp only [bifParam, sub_pos]
  constructor
  · rintro ⟨t, ht0, ht⟩
    by_contra hcon
    push_neg at hcon
    have hE0 : 0 < Real.exp (-(lam * t)) := Real.exp_pos _
    have hE1 : Real.exp (-(lam * t)) ≤ 1 :=
      Real.exp_le_one_iff.mpr (by nlinarith)
    simp only [wdFlow] at ht
    nlinarith [mul_nonneg (sub_nonneg.mpr hE1) (sub_nonneg.mpr hcon),
      mul_pos hE0 (sub_pos.mpr hw0)]
  · intro h
    refine ⟨max 0 (crossTime lam s w0 theta) + 1, by positivity, ?_⟩
    refine (wdFlow_gt_threshold_iff lam s w0 theta _ hlam hw0 h).mpr ?_
    have := le_max_right 0 (crossTime lam s w0 theta)
    linarith

/-! ### Divergence of the delay at criticality -/

/-- A lower bound on the delay in terms of the bifurcation parameter: the
crossing time is at least `λ⁻¹ log((θ - w₀)/μ)` with `μ = s/λ - θ`. -/
theorem crossTime_lower_bound (lam s w0 theta : ℝ) (hlam : 0 < lam)
    (hw0 : w0 < theta) (hth : theta < s / lam) :
    (1 / lam) * Real.log ((theta - w0) / bifParam lam s theta)
      ≤ crossTime lam s w0 theta := by
  have hB : 0 < s / lam - theta := by linarith
  have hnum : 0 < theta - w0 := by linarith
  have hle : (theta - w0) / bifParam lam s theta
      ≤ (s / lam - w0) / (s / lam - theta) := by
    simp only [bifParam]
    gcongr
  have hlog := Real.log_le_log (by simp only [bifParam]; positivity) hle
  have hinv : (0 : ℝ) < 1 / lam := by positivity
  simp only [crossTime]
  exact mul_le_mul_of_nonneg_left hlog hinv.le

/-- **The grokking delay diverges at the critical weight decay.**  For any target
time `T` there is a subcritical weight-decay strength whose crossing time
exceeds `T`; equivalently, the delay is unbounded as `λ ↑ λ_c`. -/
theorem crossTime_diverges_at_criticality (s theta w0 : ℝ) (hth : 0 < theta)
    (hw0 : w0 < theta) (hs : 0 < s) (T : ℝ) :
    ∃ lam : ℝ, 0 < lam ∧ lam < criticalDecay s theta ∧
      T < crossTime lam s w0 theta := by
  have hgap : 0 < theta - w0 := by linarith
  set c : ℝ := criticalDecay s theta with hc
  have hcpos : 0 < c := by simp only [hc, criticalDecay]; positivity
  obtain ⟨mu, hmupos, hmusmall, hmuhalf⟩ :
      ∃ mu : ℝ, 0 < mu ∧ mu < (theta - w0) * Real.exp (-(c * T)) ∧
        mu ≤ (theta - w0) / 2 := by
    refine ⟨min ((theta - w0) * Real.exp (-(c * T)) / 2) ((theta - w0) / 2), ?_, ?_, ?_⟩
    · exact lt_min (by positivity) (by positivity)
    · have h1 : 0 < (theta - w0) * Real.exp (-(c * T)) := by positivity
      exact lt_of_le_of_lt (min_le_left _ _) (by linarith)
    · exact min_le_right _ _
  refine ⟨s / (theta + mu), by positivity, ?_, ?_⟩
  · simp only [hc, criticalDecay]
    exact div_lt_div_of_pos_left hs hth (by linarith)
  · set lam : ℝ := s / (theta + mu) with hlamdef
    have hlampos : 0 < lam := by positivity
    have hquot : s / lam = theta + mu := by
      simp only [hlamdef]; field_simp
    have hthlt : theta < s / lam := by rw [hquot]; linarith
    have hlb := crossTime_lower_bound lam s w0 theta hlampos hw0 hthlt
    have hbif : bifParam lam s theta = mu := by simp only [bifParam, hquot]; ring
    rw [hbif] at hlb
    have hlamle : lam ≤ c := by
      simp only [hlamdef, hc, criticalDecay]
      exact div_le_div_of_nonneg_left hs.le hth (by linarith)
    have hratio : 1 ≤ (theta - w0) / mu := by
      rw [le_div_iff₀ hmupos]; linarith
    have hlogpos : 0 ≤ Real.log ((theta - w0) / mu) := Real.log_nonneg hratio
    have hlog : c * T < Real.log ((theta - w0) / mu) := by
      have hlt : Real.exp (c * T) < (theta - w0) / mu := by
        rw [lt_div_iff₀ hmupos]
        have hexp : Real.exp (c * T) * Real.exp (-(c * T)) = 1 := by
          rw [← Real.exp_add]; simp
        nlinarith [Real.exp_pos (c * T)]
      have hh := Real.log_lt_log (Real.exp_pos (c * T)) hlt
      rwa [Real.log_exp] at hh
    have hTlt : T < (1 / c) * Real.log ((theta - w0) / mu) := by
      have hmul := mul_lt_mul_of_pos_left hlog (show (0 : ℝ) < 1 / c by positivity)
      have hid : (1 / c) * (c * T) = T := by field_simp
      linarith [hmul, hid.le, hid.ge]
    have hcompare : (1 / c) * Real.log ((theta - w0) / mu)
        ≤ (1 / lam) * Real.log ((theta - w0) / mu) :=
      mul_le_mul_of_nonneg_right (one_div_le_one_div_of_le hlampos hlamle) hlogpos
    linarith

/-! ### Discrete weight-decayed gradient descent -/

/-- Weight-decayed gradient descent with learning rate `η`. -/
noncomputable def gdSeq (eta lam s w0 : ℝ) : ℕ → ℝ
  | 0 => w0
  | k + 1 => gdSeq eta lam s w0 k - eta * (lam * gdSeq eta lam s w0 k - s)

/-- Closed form of the weight-decayed gradient-descent iteration. -/
theorem gdSeq_closed_form (eta lam s w0 : ℝ) (hlam : lam ≠ 0) (k : ℕ) :
    gdSeq eta lam s w0 k = s / lam + (w0 - s / lam) * (1 - eta * lam) ^ k := by
  induction k with
  | zero => simp [gdSeq]
  | succ k ih =>
      simp only [gdSeq, ih, pow_succ]
      field_simp
      ring

/-- **Logarithmic delay for gradient descent.**  If the iterate has crossed the
threshold `θ` at step `k`, then `k` is at least `log(gap ratio) / log(1-ηλ)`;
as `θ` approaches the regularized optimum `s/λ` this bound diverges. -/
theorem gd_delay_lower_bound (eta lam s w0 theta : ℝ) (hlam : 0 < lam)
    (heta : 0 < eta) (hrho : eta * lam < 1) (hw0 : w0 < theta) (hth : theta < s / lam)
    (k : ℕ) (hk : theta < gdSeq eta lam s w0 k) :
    Real.log ((s / lam - theta) / (s / lam - w0)) / Real.log (1 - eta * lam) < k := by
  have hA : 0 < s / lam - w0 := by linarith
  have hB : 0 < s / lam - theta := by linarith
  have hrhopos : 0 < 1 - eta * lam := by nlinarith
  have hrholt : 1 - eta * lam < 1 := by nlinarith
  rw [gdSeq_closed_form eta lam s w0 (ne_of_gt hlam) k] at hk
  have hpow : (1 - eta * lam) ^ k < (s / lam - theta) / (s / lam - w0) := by
    rw [lt_div_iff₀ hA]
    nlinarith
  have hlogrho : Real.log (1 - eta * lam) < 0 := Real.log_neg hrhopos hrholt
  have hlogpow : (k : ℝ) * Real.log (1 - eta * lam)
      < Real.log ((s / lam - theta) / (s / lam - w0)) := by
    have h1 : Real.log ((1 - eta * lam) ^ k) < Real.log ((s / lam - theta) / (s / lam - w0)) :=
      Real.log_lt_log (by positivity) hpow
    rwa [Real.log_pow] at h1
  rw [div_lt_iff_of_neg hlogrho]
  linarith

end GrokkingTraining