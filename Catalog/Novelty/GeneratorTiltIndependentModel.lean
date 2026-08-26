/-
# The deployed generator class, solved exactly

Cycles 1–2 (`Novelty.GeneratorTiltRatio`, `Novelty.GeneratorTiltWindowDesign`) reduced the
scan-order contest to the mean tilt of a pool and computed it for *ratio-uniform* pools,
finding them bottom-heavy for every window multiplier.  But a deployed generator does not
sample a ratio: it samples two primes **independently** from the same bit-length window and
takes whatever ratio comes out.  This file solves that model exactly.

Model.  Two values are drawn independently and uniformly from a dyadic window, normalised to
`[1, 2]`, and conditioned on `p ≤ q`.  Then:

* `ratioArea_eq` — the area of `{(p, q) ∈ [1,2]² : p ≤ q ≤ r p}` is exactly
  `5/2 - 2/r - r/2` (a genuinely two-dimensional computation, split at `p = 2/r`);
* `hasDerivAt_ratioArea`, `integral_ratioDensity` — differentiating and normalising by the
  total mass `1/2` gives the ratio density `f(r) = 4/r² - 1` on `[1, 2]`, a probability
  density.  It is *not* uniform: it concentrates at `r = 1`, which is exactly the observed
  "ratio concentration near 1";
* `mean_tilt_independent` — **the main result**: the mean tilt of this model is exactly
  `(9 - 5√2)/3 = 0.642963…`;
* `independent_model_top_heavy` — this exceeds `1/2`, so the independent same-bit-length
  model is *analytically* top-heavy: window-ascending loses, with no appeal to simulation;
* `mean_tilt_in_measured_interval`, `independent_predictor_in_measured_interval` — the exact
  value `0.642963…` lies inside the reported measurement `0.6356 [0.6150, 0.6562]`, and the
  induced tilt-only speedup `(5√2 - 6)/(9 - 5√2) = 0.55529…` lies inside the reported
  `0.5578 ± 0.0217`.

So the refutation is not an artefact of the sampler: the adversarial tilt of independent
same-bit-length primes is a theorem, and its value is `(9 - 5√2)/3`.
-/
import Novelty.GeneratorTiltRatio

namespace GeneratorTilt

open Real intervalIntegral

/-! ## The two-dimensional model and its ratio density -/

/-- Area of `{(p, q) ∈ [1,2]² : p ≤ q ≤ r p}`. -/
noncomputable def ratioArea (r : ℝ) : ℝ := 5/2 - 2/r - r/2

/-- The ratio density of two independent uniform draws from `[1,2]`, conditioned on `p ≤ q`. -/
noncomputable def ratioDensity (r : ℝ) : ℝ := 4/r^2 - 1

/-- **The two-dimensional computation.**  Slicing `{(p,q) ∈ [1,2]² : p ≤ q ≤ r p}` by `p` and
splitting the range at `p = 2/r` gives the area `5/2 - 2/r - r/2`. -/
theorem ratioArea_eq {r : ℝ} (h1 : 1 ≤ r) (h2 : r ≤ 2) :
    (∫ p in (1:ℝ)..2, (min (r * p) 2 - p)) = ratioArea r := by
  have hr0 : (0:ℝ) < r := by linarith
  set t : ℝ := 2 / r with ht
  have ht1 : 1 ≤ t := by rw [ht, le_div_iff₀ hr0]; linarith
  have ht2 : t ≤ 2 := by rw [ht, div_le_iff₀ hr0]; nlinarith
  have hA : (∫ p in (1:ℝ)..t, (min (r * p) 2 - p)) = ∫ p in (1:ℝ)..t, (r - 1) * p := by
    apply intervalIntegral.integral_congr
    intro x hx
    rw [Set.uIcc_of_le ht1] at hx
    have hle : r * x ≤ 2 := by
      have hx2 : x ≤ 2 / r := hx.2
      rw [le_div_iff₀ hr0] at hx2; linarith
    simp [min_eq_left hle]; ring
  have hB : (∫ p in t..(2:ℝ), (min (r * p) 2 - p)) = ∫ p in t..(2:ℝ), (2 - p) := by
    apply intervalIntegral.integral_congr
    intro x hx
    rw [Set.uIcc_of_le ht2] at hx
    have hge : 2 ≤ r * x := by
      have hx1 : 2 / r ≤ x := hx.1
      rw [div_le_iff₀ hr0] at hx1; linarith
    simp [min_eq_right hge]
  have hsplit : (∫ p in (1:ℝ)..t, (min (r * p) 2 - p)) + (∫ p in t..(2:ℝ), (min (r * p) 2 - p))
      = ∫ p in (1:ℝ)..2, (min (r * p) 2 - p) := by
    apply intervalIntegral.integral_add_adjacent_intervals
    · apply ContinuousOn.intervalIntegrable; fun_prop
    · apply ContinuousOn.intervalIntegrable; fun_prop
  rw [← hsplit, hA, hB, intervalIntegral.integral_const_mul, integral_id,
    intervalIntegral.integral_sub _root_.intervalIntegrable_const
      intervalIntegral.intervalIntegrable_id,
    intervalIntegral.integral_const, integral_id, ratioArea, ht]
  simp only [smul_eq_mul]
  field_simp
  ring

/-- At ratio `1` the event is empty. -/
theorem ratioArea_one : ratioArea 1 = 0 := by unfold ratioArea; norm_num

/-- At ratio `2` the event is all of `{p ≤ q}`: half the square. -/
theorem ratioArea_two : ratioArea 2 = 1 / 2 := by unfold ratioArea; norm_num

/-- Differentiating the area gives half the ratio density (the conditioning constant `1/2`
is `ratioArea 2`). -/
theorem hasDerivAt_ratioArea {r : ℝ} (hr : 0 < r) :
    HasDerivAt ratioArea (ratioDensity r / 2) r := by
  have hne : r ≠ 0 := ne_of_gt hr
  have h1 : HasDerivAt (fun x : ℝ => 2 / x) (-(2 / r ^ 2)) r := by
    simpa using (hasDerivAt_inv hne).const_mul (2:ℝ)
  have h2 : HasDerivAt (fun x : ℝ => x / 2) (1 / 2) r := by
    simpa using (hasDerivAt_id r).div_const 2
  have := ((hasDerivAt_const r (5/2 : ℝ)).sub h1).sub h2
  convert this using 1
  unfold ratioDensity
  field_simp
  ring

theorem ratioDensity_nonneg {r : ℝ} (h1 : 1 ≤ r) (h2 : r ≤ 2) : 0 ≤ ratioDensity r := by
  unfold ratioDensity
  rw [sub_nonneg, le_div_iff₀ (by nlinarith)]
  nlinarith

/-- Cumulative mass of the ratio density up to `s`. -/
theorem integral_ratioDensity_le {s : ℝ} (hs : 1 ≤ s) :
    (∫ r in (1:ℝ)..s, ratioDensity r) = 5 - 4 / s - s := by
  have key : ∀ x ∈ Set.uIcc (1:ℝ) s,
      HasDerivAt (fun y : ℝ => -(4 / y) - y) (ratioDensity x) x := by
    intro x hx
    rw [Set.uIcc_of_le hs] at hx
    have hne : x ≠ 0 := ne_of_gt (by linarith [hx.1])
    have h1 : HasDerivAt (fun y : ℝ => 4 / y) (-(4 / x ^ 2)) x := by
      simpa using (hasDerivAt_inv hne).const_mul (4:ℝ)
    have := (h1.neg).sub (hasDerivAt_id x)
    convert this using 1
    unfold ratioDensity
    field_simp
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt key]
  · have hs0 : s ≠ 0 := by intro h; rw [h] at hs; linarith
    field_simp
    ring
  · apply ContinuousOn.intervalIntegrable
    rw [Set.uIcc_of_le hs]
    unfold ratioDensity
    have hne : ∀ x ∈ Set.Icc (1:ℝ) s, x ≠ 0 := fun x hx => ne_of_gt (by linarith [hx.1])
    fun_prop (disch := intro x hx; exact pow_ne_zero 2 (hne x hx))

/-- The ratio density is a probability density on the balance band. -/
theorem integral_ratioDensity : (∫ r in (1:ℝ)..2, ratioDensity r) = 1 := by
  rw [integral_ratioDensity_le (by norm_num)]; norm_num

/-! ## The exact mean tilt of the independent model -/

/-- Antiderivative of the expanded integrand `4r^{-5/2} - r^{-1/2} - 4c r^{-2} + c`. -/
noncomputable def tiltAntideriv (c : ℝ) (r : ℝ) : ℝ :=
  -8/3 * r ^ (-(3:ℝ)/2) - 2 * r ^ ((1:ℝ)/2) + 4 * c * r ^ (-(1:ℝ)) + c * r

theorem hasDerivAt_tiltAntideriv (c : ℝ) {r : ℝ} (hr : 0 < r) :
    HasDerivAt (tiltAntideriv c)
      (4 * r ^ (-(5:ℝ)/2) - r ^ (-(1:ℝ)/2) - 4 * c * r ^ (-(2:ℝ)) + c) r := by
  have hx : r ≠ 0 := ne_of_gt hr
  have h1 : HasDerivAt (fun x : ℝ => x ^ (-(3:ℝ)/2)) ((-(3:ℝ)/2) * r ^ (-(3:ℝ)/2 - 1)) r :=
    Real.hasDerivAt_rpow_const (Or.inl hx)
  have h2 : HasDerivAt (fun x : ℝ => x ^ ((1:ℝ)/2)) (((1:ℝ)/2) * r ^ ((1:ℝ)/2 - 1)) r :=
    Real.hasDerivAt_rpow_const (Or.inl hx)
  have h3 : HasDerivAt (fun x : ℝ => x ^ (-(1:ℝ))) ((-(1:ℝ)) * r ^ (-(1:ℝ) - 1)) r :=
    Real.hasDerivAt_rpow_const (Or.inl hx)
  have h4 : HasDerivAt (fun x : ℝ => c * x) c r := by
    simpa using (hasDerivAt_id r).const_mul c
  have := (((h1.const_mul (-8/3 : ℝ)).sub (h2.const_mul (2:ℝ))).add (h3.const_mul (4 * c))).add h4
  convert this using 1
  norm_num
  ring

theorem integral_tilt_combo (c : ℝ) :
    (∫ r in (1:ℝ)..2, (4 * r ^ (-(5:ℝ)/2) - r ^ (-(1:ℝ)/2) - 4 * c * r ^ (-(2:ℝ)) + c))
      = tiltAntideriv c 2 - tiltAntideriv c 1 := by
  apply intervalIntegral.integral_eq_sub_of_hasDerivAt
  · intro x hx
    rw [Set.uIcc_of_le (by norm_num)] at hx
    exact hasDerivAt_tiltAntideriv c (by linarith [hx.1])
  · apply ContinuousOn.intervalIntegrable
    rw [Set.uIcc_of_le (by norm_num)]
    have hne : ∀ x ∈ Set.Icc (1:ℝ) 2, x ≠ 0 := fun x hx => ne_of_gt (by linarith [hx.1])
    have hrp : ∀ p : ℝ, ContinuousOn (fun r : ℝ => r ^ p) (Set.Icc (1:ℝ) 2) := fun p =>
      ContinuousOn.rpow_const continuousOn_id (fun x hx => Or.inl (hne x hx))
    exact ((((hrp _).const_smul (4:ℝ)).sub (hrp _)).sub ((hrp _).const_smul (4 * c))).add
      continuousOn_const

theorem tiltAntideriv_diff :
    tiltAntideriv (1 / Real.sqrt 2) 2 - tiltAntideriv (1 / Real.sqrt 2) 1
      = (9 - 5 * Real.sqrt 2) / 3 * (1 - 1 / Real.sqrt 2) := by
  have hw0 : (0:ℝ) < Real.sqrt 2 := sqrt_two_pos'
  have h2 : Real.sqrt 2 * Real.sqrt 2 = 2 := sqrt_two_sq
  have e1 : (2:ℝ) ^ ((1:ℝ)/2) = Real.sqrt 2 := (Real.sqrt_eq_rpow 2).symm
  have e2 : (2:ℝ) ^ (-(3:ℝ)/2) = 1 / (2 * Real.sqrt 2) := by
    rw [show -(3:ℝ)/2 = -((1:ℝ) + 1/2) by ring, Real.rpow_neg (by norm_num),
      Real.rpow_add (by norm_num), Real.rpow_one, e1]
    simp
  have e3 : (2:ℝ) ^ (-(1:ℝ)) = 1 / 2 := by
    rw [Real.rpow_neg_one]; norm_num
  unfold tiltAntideriv
  rw [e1, e2, e3, Real.one_rpow, Real.one_rpow, Real.one_rpow]
  have hne : Real.sqrt 2 ≠ 0 := ne_of_gt hw0
  field_simp
  nlinarith [h2, hw0]

/-- **Main result of cycle 3.**  For two primes drawn independently from the same bit-length
window (normalised model: `p, q` uniform on `[1,2]`, conditioned on `p ≤ q`), the mean tilt
of the small factor in the canonical window is exactly `(9 - 5√2)/3 = 0.642963…`. -/
theorem mean_tilt_independent :
    (∫ r in (1:ℝ)..2, zOfRatio r * ratioDensity r) = (9 - 5 * Real.sqrt 2) / 3 := by
  have hw0 : (0:ℝ) < Real.sqrt 2 := sqrt_two_pos'
  have hd : (1:ℝ) - 1 / Real.sqrt 2 ≠ 0 := one_sub_inv_sqrt_two_ne
  set c : ℝ := 1 / Real.sqrt 2 with hc
  have hcongr : ∀ r ∈ Set.uIcc (1:ℝ) 2, zOfRatio r * ratioDensity r
      = (1 - c)⁻¹ * (4 * r ^ (-(5:ℝ)/2) - r ^ (-(1:ℝ)/2) - 4 * c * r ^ (-(2:ℝ)) + c) := by
    intro r hr
    rw [Set.uIcc_of_le (by norm_num)] at hr
    have hr0 : (0:ℝ) < r := by linarith [hr.1]
    have hsr : Real.sqrt r ≠ 0 := ne_of_gt (Real.sqrt_pos.mpr hr0)
    have p1 : r ^ (-(1:ℝ)/2) = 1 / Real.sqrt r := by
      rw [show -(1:ℝ)/2 = -(1/2) by ring, Real.rpow_neg hr0.le, ← Real.sqrt_eq_rpow, one_div]
    have p2 : r ^ (-(5:ℝ)/2) = 1 / (r ^ 2 * Real.sqrt r) := by
      rw [show -(5:ℝ)/2 = -((2:ℝ) + 1/2) by ring, Real.rpow_neg hr0.le,
        Real.rpow_add hr0, ← Real.sqrt_eq_rpow]
      rw [show ((2:ℝ)) = ((2:ℕ) : ℝ) by norm_num, Real.rpow_natCast]
      simp
    have p3 : r ^ (-(2:ℝ)) = 1 / r ^ 2 := by
      rw [show -(2:ℝ) = -((2:ℕ) : ℝ) by norm_num, Real.rpow_neg hr0.le, Real.rpow_natCast]
      simp
    unfold zOfRatio ratioDensity
    rw [p1, p2, p3, ← hc]
    have hr2 : r ^ 2 ≠ 0 := pow_ne_zero 2 (ne_of_gt hr0)
    field_simp
    ring
  rw [intervalIntegral.integral_congr hcongr, intervalIntegral.integral_const_mul,
    integral_tilt_combo, tiltAntideriv_diff, ← hc]
  field_simp

/-! ## Consequences: the analytic refutation -/

theorem mean_tilt_independent_value :
    (0.6429 : ℝ) < (9 - 5 * Real.sqrt 2) / 3 ∧ (9 - 5 * Real.sqrt 2) / 3 < 0.6430 := by
  constructor
  · nlinarith [sqrt_two_ub]
  · nlinarith [sqrt_two_lb]

/-- **The independent same-bit-length model is analytically top-heavy.**  Its mean tilt
`(9 - 5√2)/3 = 0.642963…` exceeds `1/2`, so by
`GeneratorTilt.descending_wins_iff_top_heavy` the sqrt-descending order wins: the
Λ-channel advantage is absent for this generator class as a matter of theorem, not
simulation. -/
theorem independent_model_top_heavy : 1 / 2 < (9 - 5 * Real.sqrt 2) / 3 := by
  nlinarith [sqrt_two_ub]

/-- The exact model value lies inside the reported measurement interval
`0.6356 [0.6150, 0.6562]`. -/
theorem mean_tilt_in_measured_interval :
    (0.6150 : ℝ) < (9 - 5 * Real.sqrt 2) / 3 ∧ (9 - 5 * Real.sqrt 2) / 3 < 0.6562 := by
  constructor
  · nlinarith [sqrt_two_ub]
  · nlinarith [sqrt_two_lb]

/-- Closed form of the tilt-only speedup predictor for the independent model. -/
theorem independent_predictor_eq :
    (1 - (9 - 5 * Real.sqrt 2) / 3) / ((9 - 5 * Real.sqrt 2) / 3)
      = (5 * Real.sqrt 2 - 6) / (9 - 5 * Real.sqrt 2) := by
  have hne : (9:ℝ) - 5 * Real.sqrt 2 ≠ 0 := by nlinarith [sqrt_two_ub, sqrt_two_lb]
  field_simp
  ring

/-- The predicted speedup `(5√2 - 6)/(9 - 5√2) = 0.55529…` lies inside the reported
measurement `0.5578 ± 0.0217`, i.e. window-ascending loses about `45%` of the work. -/
theorem independent_predictor_in_measured_interval :
    (0.5361 : ℝ) < (5 * Real.sqrt 2 - 6) / (9 - 5 * Real.sqrt 2) ∧
      (5 * Real.sqrt 2 - 6) / (9 - 5 * Real.sqrt 2) < 0.5795 := by
  have hpos : (0:ℝ) < 9 - 5 * Real.sqrt 2 := by nlinarith [sqrt_two_ub]
  constructor
  · rw [lt_div_iff₀ hpos]; nlinarith [sqrt_two_lb]
  · rw [div_lt_iff₀ hpos]; nlinarith [sqrt_two_ub]

/-! ## How often does the descending order win? -/

theorem criticalRatio_bracket :
    (1.37248 : ℝ) < criticalRatio ∧ criticalRatio < 1.37264 := by
  unfold criticalRatio
  constructor
  · nlinarith [sqrt_two_ub]
  · nlinarith [sqrt_two_lb]

/-- **Frequency of the inversion.**  Under the independent same-bit-length model the
probability that a key's ratio falls below the critical ratio — equivalently, that the
sqrt-descending order wins on that key — is `5 - 4/r★ - r★`, a number in `(0.712, 0.714)`.
So the inversion is not a tail effect: it holds for about `71%` of deployed-style keys
individually, on top of holding for the pool mean. -/
theorem prob_descending_wins_bracket :
    (0.712 : ℝ) < (∫ r in (1:ℝ)..criticalRatio, ratioDensity r) ∧
      (∫ r in (1:ℝ)..criticalRatio, ratioDensity r) < 0.714 := by
  have hb := criticalRatio_bracket
  rw [integral_ratioDensity_le (by linarith [hb.1])]
  have hpos : (0:ℝ) < criticalRatio := by linarith [hb.1]
  constructor
  · rw [show (0.712 : ℝ) < 5 - 4 / criticalRatio - criticalRatio ↔
        4 / criticalRatio < 5 - 0.712 - criticalRatio by constructor <;> intro h <;> linarith,
      div_lt_iff₀ hpos]
    nlinarith [hb.1, hb.2]
  · rw [show 5 - 4 / criticalRatio - criticalRatio < (0.714 : ℝ) ↔
        5 - 0.714 - criticalRatio < 4 / criticalRatio by constructor <;> intro h <;> linarith,
      lt_div_iff₀ hpos]
    nlinarith [hb.1, hb.2]

/-- The deployed model sits strictly *below* the critical ratio in tilt terms while the
ratio-uniform control sits strictly above it: the two pools land on opposite sides of the
tie, which is the entire content of the scope boundary. -/
theorem independent_vs_uniform_control :
    Real.sqrt 2 - 1 < 1 / 2 ∧ 1 / 2 < (9 - 5 * Real.sqrt 2) / 3 :=
  ⟨by linarith [sqrt_two_ub], independent_model_top_heavy⟩

end GeneratorTilt