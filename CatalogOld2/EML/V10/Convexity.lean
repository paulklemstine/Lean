/-! # CatalogBuild.EML.V10.Convexity

Auto-generated from theorem catalog database.
Domain: EML/V10
Declarations: 17
-/

import Mathlib

noncomputable section

/-- EML is convex in x for fixed y. -/
theorem eml_convex_x (y : ℝ) : ConvexOn ℝ Set.univ (fun x => eml x y) := by
  show ConvexOn ℝ Set.univ (fun x => Real.exp x + (-Real.log y))
  exact convexOn_exp.add (convexOn_const _ convex_univ)


/-- EML is convex in y on (0,∞) for fixed x. -/
theorem eml_convex_y (x : ℝ) : ConvexOn ℝ (Set.Ioi 0) (fun y => eml x y) := by
  constructor
  · exact convex_Ioi 0
  · intro a ha b hb t s ht hs hts
    simp only [eml, smul_eq_mul]
    have hapos : (0:ℝ) < a := ha; have hbpos : (0:ℝ) < b := hb
    have hmix : (0:ℝ) < t * a + s * b := by
      rcases (ht.lt_or_eq) with ht' | ht'
      · exact add_pos_of_pos_of_nonneg (mul_pos ht' hapos) (mul_nonneg hs hbpos.le)
      · rw [← ht'] at hts; simp at hts; rw [← ht', hts]; simp; exact hbpos
    have hconv := convexOn_exp.2 (Set.mem_univ (Real.log a))
      (Set.mem_univ (Real.log b)) ht hs hts
    simp at hconv
    rw [Real.exp_log hapos, Real.exp_log hbpos] at hconv
    have hlog : t * Real.log a + s * Real.log b ≤ Real.log (t * a + s * b) := by
      rw [← Real.exp_le_exp]; exact le_trans hconv (Real.exp_log hmix).symm.le
    have key : t * (Real.exp x - Real.log a) + s * (Real.exp x - Real.log b) =
      Real.exp x - (t * Real.log a + s * Real.log b) := by
      have : t * Real.exp x + s * Real.exp x = Real.exp x := by
        linear_combination Real.exp x * hts
      linarith
    linarith


/-- EML is jointly convex on ℝ × (0,∞). -/
theorem eml_jointly_convex :
    ConvexOn ℝ (Set.univ ×ˢ Set.Ioi 0)
      (fun p : ℝ × ℝ => eml p.1 p.2) := by
  constructor
  · exact convex_univ.prod (convex_Ioi 0)
  · intro p hp q hq t s ht hs hts
    simp only [eml, Prod.smul_fst, Prod.smul_snd, smul_eq_mul, Prod.fst_add, Prod.snd_add]
    have hp2 : (0:ℝ) < p.2 := (Set.mem_prod.mp hp).2
    have hq2 : (0:ℝ) < q.2 := (Set.mem_prod.mp hq).2
    have hmix : (0:ℝ) < t * p.2 + s * q.2 := by
      rcases (ht.lt_or_eq) with ht' | ht'
      · exact add_pos_of_pos_of_nonneg (mul_pos ht' hp2) (mul_nonneg hs hq2.le)
      · rw [← ht'] at hts; simp at hts; rw [← ht', hts]; simp; exact hq2
    have hexp := convexOn_exp.2 (Set.mem_univ p.1) (Set.mem_univ q.1) ht hs hts
    simp at hexp
    have hconv := convexOn_exp.2 (Set.mem_univ (Real.log p.2))
      (Set.mem_univ (Real.log q.2)) ht hs hts
    simp at hconv; rw [Real.exp_log hp2, Real.exp_log hq2] at hconv
    have hlog : t * Real.log p.2 + s * Real.log q.2 ≤ Real.log (t * p.2 + s * q.2) := by
      rw [← Real.exp_le_exp]; exact le_trans hconv (Real.exp_log hmix).symm.le
    linarith [show t * Real.exp p.1 + s * Real.exp q.1 -
      (t * Real.log p.2 + s * Real.log q.2) =
      t * (Real.exp p.1 - Real.log p.2) + s * (Real.exp q.1 - Real.log q.2) from by ring]


/-- σ(x) ≥ 1 for all x. -/
theorem emlSelfPair_ge_one (x : ℝ) : emlSelfPair x ≥ 1 := by
  unfold emlSelfPair; linarith [Real.add_one_le_exp x]


/-- σ(x) = 1 iff x = 0. -/
theorem emlSelfPair_eq_one_iff (x : ℝ) : emlSelfPair x = 1 ↔ x = 0 := by
  unfold emlSelfPair; constructor
  · intro h; by_contra hne; linarith [Real.add_one_lt_exp hne]
  · intro h; subst h; simp


/-- σ is strictly convex. -/
theorem emlSelfPair_strict_convex : StrictConvexOn ℝ Set.univ emlSelfPair := by
  apply strictConvexOn_of_deriv2_pos (convex_univ)
  · exact (Real.continuous_exp.sub continuous_id).continuousOn
  · intro x _
    show 0 < (deriv ∘ deriv) emlSelfPair x
    simp only [Function.comp]
    have h1 : deriv emlSelfPair = fun x => Real.exp x - 1 := by
      ext y; exact (Real.hasDerivAt_exp y).sub (hasDerivAt_id y)
        |>.congr_deriv (by ring) |>.deriv
    rw [h1]
    have h2 : deriv (fun x => Real.exp x - 1) x = Real.exp x := by
      exact ((Real.hasDerivAt_exp x).sub (hasDerivAt_const x 1)
        |>.congr_deriv (by ring)).deriv
    rw [h2]; exact Real.exp_pos x


/-- σ'(x) = eˣ − 1. -/
theorem emlSelfPair_hasDerivAt (x : ℝ) :
    HasDerivAt emlSelfPair (Real.exp x - 1) x := by
  unfold emlSelfPair
  exact (Real.hasDerivAt_exp x).sub (hasDerivAt_id x) |>.congr_deriv (by ring)


/-- σ is strictly monotone on [0,∞). -/
theorem emlSelfPair_strictMono_nonneg : StrictMonoOn emlSelfPair (Set.Ici 0) := by
  apply strictMonoOn_of_deriv_pos (convex_Ici 0)
  · exact (Real.continuous_exp.sub continuous_id).continuousOn
  · intro x hx; rw [interior_Ici] at hx
    have : deriv emlSelfPair x = Real.exp x - 1 :=
      ((Real.hasDerivAt_exp x).sub (hasDerivAt_id x) |>.congr_deriv (by ring)).deriv
    rw [this]; linarith [show Real.exp x > 1 from by rw [← Real.exp_zero]; exact Real.exp_lt_exp.mpr hx]


/-- σ is strictly antitone on (−∞, 0]. -/
theorem emlSelfPair_strictAnti_nonpos : StrictAntiOn emlSelfPair (Set.Iic 0) := by
  apply strictAntiOn_of_deriv_neg (convex_Iic 0)
  · exact (Real.continuous_exp.sub continuous_id).continuousOn
  · intro x hx; rw [interior_Iic] at hx
    have : deriv emlSelfPair x = Real.exp x - 1 :=
      ((Real.hasDerivAt_exp x).sub (hasDerivAt_id x) |>.congr_deriv (by ring)).deriv
    rw [this]; linarith [show Real.exp x < 1 from by rw [← Real.exp_zero]; exact Real.exp_lt_exp.mpr hx]


/-- ∂eml/∂x = exp(x). -/
theorem eml_deriv_x (x y : ℝ) :
    HasDerivAt (fun x' => eml x' y) (Real.exp x) x := by
  unfold eml
  exact (Real.hasDerivAt_exp x).sub (hasDerivAt_const x (Real.log y))
    |>.congr_deriv (by ring)


/-- ∂eml/∂y = −1/y for y > 0. -/
theorem eml_deriv_y (x y : ℝ) (hy : 0 < y) :
    HasDerivAt (fun y' => eml x y') (-y⁻¹) y := by
  unfold eml
  exact ((hasDerivAt_const y (Real.exp x)).sub (Real.hasDerivAt_log hy.ne'))
    |>.congr_deriv (by ring)


/-- D_exp(x,y) = 0 iff x = y. -/
theorem bregman_exp_zero_iff (x y : ℝ) :
    Real.exp x - Real.exp y - Real.exp y * (x - y) = 0 ↔ x = y := by
  constructor
  · intro h
    by_contra hne
    rw [show x = y + (x - y) by ring, Real.exp_add] at h
    have := Real.add_one_lt_exp (show x - y ≠ 0 from sub_ne_zero.mpr hne)
    nlinarith [Real.exp_pos y]
  · intro h; subst h; ring


/-- The critical point of σ: eˣ = 1 iff x = 0. -/
theorem emlSelfPair_critical_point (x : ℝ) :
    Real.exp x - 1 = 0 ↔ x = 0 := by
  constructor
  · intro h; exact (Real.exp_eq_one_iff x).mp (by linarith)
  · intro h; subst h; simp


/-- Newton's method step for σ. -/
theorem emlSelfPair_newton_step (x : ℝ) :
    x - (Real.exp x - 1) / Real.exp x = x - 1 + Real.exp (-x) := by
  rw [Real.exp_neg]; field_simp; ring


/-- σ(x) ≥ exp(x)/2 for x ≥ 0. -/
theorem emlSelfPair_growth (x : ℝ) (hx : 0 ≤ x) :
    emlSelfPair x ≥ Real.exp x / 2 := by
  unfold emlSelfPair
  suffices h : Real.exp x ≥ 2 * x by linarith
  have h5 : Real.exp x ≥ 1 + x + x ^ 2 / 2 := by
    rw [Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]
    exact le_trans (by norm_num [Finset.sum_range_succ])
      (Summable.sum_le_tsum (Finset.range 3)
        (fun i _ => by positivity) (Real.summable_pow_div_factorial x))
  nlinarith [sq_nonneg (x - 1)]


/-- σ → ∞ as x → ∞. -/
theorem emlSelfPair_tendsto_top :
    Filter.Tendsto emlSelfPair Filter.atTop Filter.atTop := by
  rw [Filter.tendsto_atTop_atTop]
  intro b; use max b 2
  intro x hx; unfold emlSelfPair
  have hx2 : x ≥ 2 := le_trans (le_max_right b 2) hx
  have hxb : x ≥ b := le_trans (le_max_left b 2) hx
  have h5 : Real.exp x ≥ 1 + x + x ^ 2 / 2 := by
    rw [Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]
    exact le_trans (by norm_num [Finset.sum_range_succ])
      (Summable.sum_le_tsum (Finset.range 3)
        (fun i _ => by positivity) (Real.summable_pow_div_factorial x))
  nlinarith [sq_nonneg (x - 1)]


/-- σ → ∞ as x → −∞. -/
theorem emlSelfPair_tendsto_top_neg :
    Filter.Tendsto emlSelfPair Filter.atBot Filter.atTop := by
  apply Filter.tendsto_atTop.mpr; intro b
  simp only [Filter.eventually_atBot]
  use min (-b) 0; intro x hx; unfold emlSelfPair
  linarith [Real.exp_pos x, le_trans hx (min_le_left _ _), le_trans hx (min_le_right _ _)]


end
