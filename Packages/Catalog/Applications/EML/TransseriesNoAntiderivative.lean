import Applications.EML.TransseriesHardyField

/-!
# A Liouville-type obstruction inside the EML algebra

The EML algebra is closed under differentiation
(`EMLTS.emlDeriv`, `EMLTS.hasDerivAt_EMLFun`) but *not* under integration.  The first
obstruction sits one level above the familiar one:

* `1 / x` **does** have an antiderivative in `EMLAlg`, namely `log x`
  (`EMLTS.emlDeriv_log`);
* `1 / (x log x)` **does not** — its antiderivative `log log x` is not an EML function
  at all.

This file proves the negative statement.  The argument is asymptotic rather than
combinatorial: `log log x` grows, but slower than *every* growing transmonomial of the
EML scale, whereas the dominant-term theorem `EMLTS.tendsto_EMLFun_of_dominant` forces
every EML function tending to `+∞` to be asymptotic to a constant multiple of a single
growing transmonomial.  So `log log x` cannot be one.

## Main results

* `EMLTS.tendsto_loglog_div_rankFun_zero` : `log log x` is negligible against every
  growing transmonomial of the EML scale.
* `EMLTS.loglog_not_EMLFun` : `log log x + K` is never the germ of an EML function.
* `EMLTS.no_antiderivative_of_invXLog` : `1 / (x log x)` has no antiderivative in the
  EML algebra.
-/

noncomputable section

open Filter Asymptotics Real HahnSeries Set

open scoped Topology

namespace EMLTS

/-! ## Auxiliary growth comparisons -/

private theorem tendsto_atTop_of_pos_mul_add' {g h : ℝ → ℝ} {D : ℝ} (hD : 0 < D)
    (hg : Tendsto g atTop atTop) (hh : h =o[atTop] g) :
    Tendsto (fun x => D * g x + h x) atTop atTop := by
  have hbound := hh.bound (c := D / 2) (by positivity)
  have hgnn : ∀ᶠ x in atTop, 0 ≤ g x := hg.eventually_ge_atTop 0
  have hmono : ∀ᶠ x in atTop, (D / 2) * g x ≤ D * g x + h x := by
    filter_upwards [hbound, hgnn] with x hx hgx
    have h1 : |h x| ≤ (D / 2) * |g x| := by simpa using hx
    have h2 : |g x| = g x := abs_of_nonneg hgx
    rw [h2] at h1
    linarith [neg_abs_le (h x)]
  refine tendsto_atTop_mono' _ hmono ?_
  exact hg.const_mul_atTop (by positivity)

private theorem isLittleO_id_exp' : (fun x : ℝ => x) =o[atTop] Real.exp := by
  simpa using Real.isLittleO_pow_exp_atTop (n := 1)

private theorem isLittleO_log_exp' : Real.log =o[atTop] Real.exp :=
  Real.isLittleO_log_id_atTop.trans isLittleO_id_exp'

private theorem isLittleO_loglog_log' :
    (fun x : ℝ => Real.log (Real.log x)) =o[atTop] Real.log :=
  Real.isLittleO_log_id_atTop.comp_tendsto Real.tendsto_log_atTop

private theorem isLittleO_loglog_id' :
    (fun x : ℝ => Real.log (Real.log x)) =o[atTop] (fun x : ℝ => x) :=
  isLittleO_loglog_log'.trans Real.isLittleO_log_id_atTop

private theorem isLittleO_loglog_exp' :
    (fun x : ℝ => Real.log (Real.log x)) =o[atTop] Real.exp :=
  isLittleO_loglog_log'.trans isLittleO_log_exp'

/-- `log log x → ∞`. -/
theorem tendsto_loglog_atTop :
    Tendsto (fun x : ℝ => Real.log (Real.log x)) atTop atTop :=
  Real.tendsto_log_atTop.comp Real.tendsto_log_atTop

private theorem isLittleO_logloglog_loglog :
    (fun x : ℝ => Real.log (Real.log (Real.log x))) =o[atTop]
      (fun x : ℝ => Real.log (Real.log x)) :=
  Real.isLittleO_log_id_atTop.comp_tendsto tendsto_loglog_atTop

private theorem isLittleO_logloglog_log :
    (fun x : ℝ => Real.log (Real.log (Real.log x))) =o[atTop] Real.log :=
  isLittleO_logloglog_loglog.trans isLittleO_loglog_log'

private theorem isLittleO_logloglog_id :
    (fun x : ℝ => Real.log (Real.log (Real.log x))) =o[atTop] (fun x : ℝ => x) :=
  isLittleO_logloglog_log.trans Real.isLittleO_log_id_atTop

private theorem isLittleO_logloglog_exp :
    (fun x : ℝ => Real.log (Real.log (Real.log x))) =o[atTop] Real.exp :=
  isLittleO_logloglog_log.trans isLittleO_log_exp'

/-! ## `log log x` is negligible against every growing transmonomial -/

/-- The key growth estimate: for a *positive* rank `r`, the quantity
`rd r · e^x + ra r · x + rb r · log x + rc r · log log x − log log log x`
still tends to `+∞`.  This is `EMLTS.tendsto_rankFun_zero` sharpened by a
triple-logarithmic correction. -/
private theorem tendsto_rank_sub_logloglog {r : Rank} (hr : 0 < r) :
    Tendsto (fun x => rd r * Real.exp x + ra r * x + rb r * Real.log x
      + rc r * Real.log (Real.log x) - Real.log (Real.log (Real.log x))) atTop atTop := by
  rcases rank_pos_iff.mp hr with hd | ⟨hd, hcase⟩
  · have := tendsto_atTop_of_pos_mul_add' (g := Real.exp)
      (h := fun x => ra r * x + rb r * Real.log x + rc r * Real.log (Real.log x)
        - Real.log (Real.log (Real.log x))) hd
      Real.tendsto_exp_atTop
      ((((isLittleO_id_exp'.const_mul_left (ra r)).add
        (isLittleO_log_exp'.const_mul_left (rb r))).add
        (isLittleO_loglog_exp'.const_mul_left (rc r))).sub isLittleO_logloglog_exp)
    exact this.congr fun x => by ring
  · rcases hcase with ha | ⟨ha, hcase⟩
    · have := tendsto_atTop_of_pos_mul_add' (g := fun x : ℝ => x)
        (h := fun x => rb r * Real.log x + rc r * Real.log (Real.log x)
          - Real.log (Real.log (Real.log x))) ha
        tendsto_id
        (((Real.isLittleO_log_id_atTop.const_mul_left (rb r)).add
          (isLittleO_loglog_id'.const_mul_left (rc r))).sub isLittleO_logloglog_id)
      exact this.congr fun x => by rw [hd]; ring
    · rcases hcase with hb | ⟨hb, hc⟩
      · have := tendsto_atTop_of_pos_mul_add' (g := Real.log)
          (h := fun x => rc r * Real.log (Real.log x)
            - Real.log (Real.log (Real.log x))) hb
          Real.tendsto_log_atTop
          ((isLittleO_loglog_log'.const_mul_left (rc r)).sub isLittleO_logloglog_log)
        exact this.congr fun x => by rw [hd, ha]; ring
      · have := tendsto_atTop_of_pos_mul_add'
          (g := fun x : ℝ => Real.log (Real.log x))
          (h := fun x => -Real.log (Real.log (Real.log x))) hc
          tendsto_loglog_atTop
          (isLittleO_logloglog_loglog.neg_left)
        exact this.congr fun x => by rw [hd, ha, hb]; ring

/-- **`log log x` is flat against the EML scale.**  For every growing transmonomial
(i.e. every rank `g < 0`), the ratio `log log x / rankFun g x` tends to `0`. -/
theorem tendsto_loglog_div_rankFun_zero {g : Rank} (hg : g < 0) :
    Tendsto (fun x => Real.log (Real.log x) / rankFun g x) atTop (𝓝 0) := by
  have hr : (0 : Rank) < -g := neg_pos.mpr hg
  have key := tendsto_rank_sub_logloglog hr
  have hneg : Tendsto (fun x => -(rd (-g) * Real.exp x + ra (-g) * x + rb (-g) * Real.log x
      + rc (-g) * Real.log (Real.log x) - Real.log (Real.log (Real.log x)))) atTop atBot :=
    tendsto_neg_atTop_atBot.comp key
  have hexp := Real.tendsto_exp_atBot.comp hneg
  refine Tendsto.congr' ?_ hexp
  have hdn : rd (-g) = -rd g := rfl
  have han : ra (-g) = -ra g := rfl
  have hbn : rb (-g) = -rb g := rfl
  have hcn : rc (-g) = -rc g := rfl
  filter_upwards [eventually_gt_atTop (Real.exp 1)] with x hx
  have hlog1 : (1 : ℝ) < Real.log x := by
    have := Real.log_lt_log (Real.exp_pos 1) hx
    simpa using this
  have hL2 : 0 < Real.log (Real.log x) := Real.log_pos hlog1
  have hrank : rankFun g x = Real.exp (rd (-g) * Real.exp x + ra (-g) * x
      + rb (-g) * Real.log x + rc (-g) * Real.log (Real.log x)) := by
    simp only [rankFun, rankLog, hdn, han, hbn, hcn]
    congr 1
    ring
  rw [Function.comp_apply, hrank, neg_sub, Real.exp_sub, Real.exp_log hL2]

/-! ## `log log x` is not an EML function -/

/-- **A germ obstruction.**  No EML function has the germ of `log log x + K` at `+∞`. -/
theorem loglog_not_EMLFun (p : EMLAlg) (K : ℝ) :
    ¬ (∀ᶠ x in atTop, EMLFun p x = Real.log (Real.log x) + K) := by
  classical
  intro h
  have hlim : Tendsto (fun x : ℝ => Real.log (Real.log x) + K) atTop atTop :=
    tendsto_loglog_atTop.atTop_add tendsto_const_nhds
  have heq : (EMLFun p) =ᶠ[atTop] fun x : ℝ => Real.log (Real.log x) + K := h
  have hp : Tendsto (EMLFun p) atTop atTop := Tendsto.congr' heq.symm hlim
  have hp0 : p ≠ 0 := by
    rintro rfl
    have hconst : EMLFun (0 : EMLAlg) = fun _ : ℝ => (0 : ℝ) := by
      funext x; simp [EMLFun]
    rw [hconst] at hp
    exact absurd hp (not_tendsto_atTop_of_tendsto_nhds tendsto_const_nhds)
  have hne : p.support.Nonempty := Finsupp.support_nonempty_iff.mpr hp0
  rcases tendsto_EMLFun_of_dominant hne with ⟨_, hz⟩ | ⟨_, hz⟩ | ⟨hg0, hc, _⟩ | ⟨_, _, hbot⟩
  · exact not_tendsto_nhds_of_tendsto_atTop hp _ hz
  · exact not_tendsto_nhds_of_tendsto_atTop hp _ hz
  · set g0 := p.support.min' hne with hg0def
    have hdiv : Tendsto (fun x => EMLFun p x / rankFun g0 x) atTop (𝓝 (p g0)) :=
      tendsto_EMLFun_div hne
    have hK : Tendsto (fun x => K / rankFun g0 x) atTop (𝓝 0) := by
      have hpos : (0 : Rank) < -g0 := neg_pos.mpr hg0
      have h0 := (tendsto_rankFun_zero hpos).const_mul K
      rw [mul_zero] at h0
      refine h0.congr fun x => ?_
      rw [rankFun_neg, div_eq_mul_inv]
    have hzero : Tendsto (fun x => EMLFun p x / rankFun g0 x) atTop (𝓝 0) := by
      have hsum := (tendsto_loglog_div_rankFun_zero hg0).add hK
      rw [add_zero] at hsum
      refine Tendsto.congr' ?_ hsum
      filter_upwards [h] with x hx
      rw [← add_div, ← hx]
    have : p g0 = 0 := tendsto_nhds_unique hdiv hzero
    exact absurd this hc.ne'
  · exact absurd hbot (hp.not_tendsto disjoint_atBot_atTop.symm)

/-! ## No antiderivative for `1 / (x log x)` -/

private theorem hasDerivAt_loglog {x : ℝ} (hx : 1 < x) :
    HasDerivAt (fun y : ℝ => Real.log (Real.log y)) ((Real.log x)⁻¹ * x⁻¹) x := by
  have hx0 : (0 : ℝ) < x := lt_trans zero_lt_one hx
  have hlog : 0 < Real.log x := Real.log_pos hx
  exact (Real.hasDerivAt_log hlog.ne').comp x (Real.hasDerivAt_log hx0.ne')

private theorem rankFun_rInvXLog {x : ℝ} (hx : 1 < x) :
    rankFun rInvXLog x = (Real.log x)⁻¹ * x⁻¹ := by
  have hx0 : (0 : ℝ) < x := lt_trans zero_lt_one hx
  have hlog : 0 < Real.log x := Real.log_pos hx
  rw [rankFun, rankLog]
  simp only [rInvXLog, rd_rk, ra_rk, rb_rk, rc_rk]
  rw [show -(0 * Real.exp x + 0 * x + 1 * Real.log x + 1 * Real.log (Real.log x))
      = -(Real.log (Real.log x) + Real.log x) by ring, Real.exp_neg, Real.exp_add,
    Real.exp_log hlog, Real.exp_log hx0, mul_inv]

/-- **The EML algebra is not closed under integration.**  There is no EML expression whose
derivative is the transmonomial `1 / (x log x)`; equivalently, `log log x` lies outside the
EML scale even though `1 / (x log x)` lies inside it. -/
theorem no_antiderivative_of_invXLog :
    ¬ ∃ p : EMLAlg, emlDeriv p = AddMonoidAlgebra.single rInvXLog (1 : ℝ) := by
  rintro ⟨p, hp⟩
  set f : ℝ → ℝ := fun x => EMLFun p x - Real.log (Real.log x) with hf
  have hderiv : ∀ x : ℝ, 1 < x → HasDerivAt f 0 x := by
    intro x hx
    have h1 : HasDerivAt (EMLFun p) ((Real.log x)⁻¹ * x⁻¹) x := by
      have := hasDerivAt_EMLFun p hx
      rwa [hp, EMLFun_single, one_mul, rankFun_rInvXLog hx] at this
    have h2 := hasDerivAt_loglog hx
    simpa [hf] using h1.sub h2
  have hconst : ∀ x : ℝ, 2 ≤ x → f x = f 2 := by
    intro x hx
    have hcont : ContinuousOn f (Icc 2 x) := fun y hy =>
      ((hderiv y (by linarith [hy.1])).continuousAt).continuousWithinAt
    have hd : ∀ y ∈ Ico (2 : ℝ) x, HasDerivWithinAt f 0 (Ici y) y := fun y hy =>
      (hderiv y (by linarith [hy.1])).hasDerivWithinAt
    exact constant_of_has_deriv_right_zero hcont hd x (right_mem_Icc.mpr hx)
  refine loglog_not_EMLFun p (f 2) ?_
  filter_upwards [eventually_ge_atTop (2 : ℝ)] with x hx
  have := hconst x hx
  rw [hf] at this
  simp only at this
  linarith

end EMLTS