import Mathlib

/-! # CatalogBuild.Geometry.Stereographic.UnifiedLightTheory

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 39
-/


noncomputable section

/-- [Section: # CatalogBuild.Geometry.Stereographic.UnifiedLightTheory
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 39] -/
theorem weierstrass_differential (t : ℝ) :
    HasDerivAt (fun t => 2 * Real.arctan t) (2 / (1 + t ^ 2)) t := by
  simpa using HasDerivAt.const_mul 2 ( Real.hasDerivAt_arctan t )




/-- [Section: # CatalogBuild.Geometry.Stereographic.UnifiedLightTheory
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 39] -/
theorem one_plus_tan_sq (θ : ℝ) (hcos : Real.cos (θ / 2) ≠ 0) :
    1 + Real.tan (θ / 2) ^ 2 = 1 / Real.cos (θ / 2) ^ 2 := by
  rw [ ← Real.inv_one_add_tan_sq hcos, one_div ];
  norm_num




/-- The conformal factor of inverse stereographic projection ℝ → S¹. -/
def conformalFactor1D (t : ℝ) : ℝ := 2 / (1 + t ^ 2)




/-- The conformal factor is always positive. -/
theorem conformalFactor1D_pos (t : ℝ) : 0 < conformalFactor1D t := by
  unfold conformalFactor1D; positivity




/-- The conformal factor at 0 is 2 (maximum stretching: south pole). -/
theorem conformalFactor1D_at_zero : conformalFactor1D 0 = 2 := by
  unfold conformalFactor1D; norm_num




/-- The conformal factor at ±1 is 1 (isometric equator). -/
theorem conformalFactor1D_at_one : conformalFactor1D 1 = 1 := by
  unfold conformalFactor1D; norm_num




theorem conformalFactor1D_at_neg_one : conformalFactor1D (-1) = 1 := by
  unfold conformalFactor1D; norm_num




/-- The conformal factor is symmetric: λ(t) = λ(-t). -/
theorem conformalFactor1D_even (t : ℝ) :
    conformalFactor1D (-t) = conformalFactor1D t := by
  unfold conformalFactor1D; ring_nf




theorem total_arc_length_is_2pi :
    ∫ t : ℝ, conformalFactor1D t = 2 * Real.pi := by
  unfold conformalFactor1D;
  simp +decide [ div_eq_mul_inv, MeasureTheory.integral_const_mul ]




/-- The antipodal map on ℝ: t ↦ -1/t. -/
def antipodalMap (t : ℝ) : ℝ := -1 / t




theorem antipodal_no_fixed_points (t : ℝ) (ht : t ≠ 0) :
    antipodalMap t ≠ t := by
  exact fun h => ht <| by rw [ antipodalMap ] at h; rw [ div_eq_iff ht ] at h; nlinarith;




theorem stereo_antipodal (t : ℝ) (ht : t ≠ 0) :
    let x := 2 * t / (1 + t ^ 2)
    let y := (1 - t ^ 2) / (1 + t ^ 2)
    let x' := 2 * (-1/t) / (1 + (-1/t) ^ 2)
    let y' := (1 - (-1/t) ^ 2) / (1 + (-1/t) ^ 2)
    x' = -x ∧ y' = -y := by
  grind




/-- The inverse scalar Cayley transform: z ↦ i(1+z)/(1-z) maps S¹\{1} → ℝ. -/
def cayleyInverse (z : ℂ) : ℂ :=
  Complex.I * (1 + z) / (1 - z)




theorem cayley_on_unit_circle (t : ℝ) :
    Complex.normSq (cayleyTransform t) = 1 := by
  unfold cayleyTransform
  simp [Complex.normSq];
  nlinarith




theorem cayley_at_zero : cayleyTransform 0 = -1 := by
  unfold cayleyTransform; norm_num;




theorem cayley_round_trip (t : ℝ) :
    cayleyInverse (cayleyTransform t) = ↑t := by
  unfold cayleyTransform cayleyInverse; ring_nf ;
  by_cases h : Complex.I + t = 0 <;> simp_all +decide [ sq, mul_assoc, mul_left_comm, mul_comm ];
  · norm_num [ Complex.ext_iff ] at h;
  · field_simp [h] ; ring_nf ; aesop;




/-- "Projecting to heaven": t = 0 maps to the north pole (0, 1). -/
theorem project_to_heaven :
    (2 * (0 : ℝ) / (1 + 0 ^ 2), (1 - (0 : ℝ) ^ 2) / (1 + 0 ^ 2)) = (0, 1) := by
  norm_num




theorem project_to_hell_x :
    Filter.Tendsto (fun t : ℝ => 2 * t / (1 + t ^ 2)) Filter.atTop (nhds 0) := by
  rw [ Metric.tendsto_nhds ];
  exact fun ε hε => Filter.eventually_atTop.2 ⟨ ε⁻¹ * 2, fun x hx => abs_lt.2 ⟨ by rw [ lt_sub_iff_add_lt ] ; rw [ lt_div_iff₀ ] <;> nlinarith [ inv_pos.2 hε, mul_inv_cancel₀ hε.ne' ], by rw [ sub_lt_iff_lt_add' ] ; rw [ div_lt_iff₀ ] <;> nlinarith [ inv_pos.2 hε, mul_inv_cancel₀ hε.ne' ] ⟩ ⟩




theorem project_to_hell_y :
    Filter.Tendsto (fun t : ℝ => (1 - t ^ 2) / (1 + t ^ 2)) Filter.atTop (nhds (-1)) := by
  rw [ Metric.tendsto_nhds ];
  exact fun ε ε_pos => Filter.eventually_atTop.2 ⟨ ε⁻¹ + 1, fun x hx => abs_lt.2 ⟨ by rw [ lt_sub_iff_add_lt ] ; rw [ lt_div_iff₀ ] <;> nlinarith [ inv_pos.2 ε_pos, mul_inv_cancel₀ ε_pos.ne' ], by rw [ sub_lt_iff_lt_add' ] ; rw [ div_lt_iff₀ ] <;> nlinarith [ inv_pos.2 ε_pos, mul_inv_cancel₀ ε_pos.ne' ] ⟩ ⟩




/-- The midpoint between heaven and hell: t = 1 maps to (1, 0). -/
theorem equator_point :
    (2 * (1 : ℝ) / (1 + 1 ^ 2), (1 - (1 : ℝ) ^ 2) / (1 + 1 ^ 2)) = (1, 0) := by
  norm_num




/-- The other equator: t = -1 maps to (-1, 0). -/
theorem equator_point_neg :
    (2 * (-1 : ℝ) / (1 + (-1) ^ 2), (1 - (-1 : ℝ) ^ 2) / (1 + (-1) ^ 2)) = (-1, 0) := by
  norm_num




/-- The "stereographic addition" on ℝ, corresponding to rotation on S¹.
This is also the relativistic velocity addition formula (in units where c = 1). -/
def stereoAdd (t₁ t₂ : ℝ) : ℝ := (t₁ + t₂) / (1 - t₁ * t₂)




/-- stereoAdd has identity element 0. -/
theorem stereoAdd_zero_right (t : ℝ) : stereoAdd t 0 = t := by
  unfold stereoAdd; simp




theorem stereoAdd_zero_left (t : ℝ) : stereoAdd 0 t = t := by
  unfold stereoAdd; simp




/-- stereoAdd is commutative. -/
theorem stereoAdd_comm (t₁ t₂ : ℝ) : stereoAdd t₁ t₂ = stereoAdd t₂ t₁ := by
  unfold stereoAdd; ring_nf




/-- The inverse under stereoAdd is negation. -/
theorem stereoAdd_neg (t : ℝ) : stereoAdd t (-t) = 0 := by
  unfold stereoAdd; simp




theorem stereoAdd_assoc (a b c : ℝ)
    (h1 : 1 - a * b ≠ 0) (h2 : 1 - b * c ≠ 0)
    (h3 : 1 - stereoAdd a b * c ≠ 0)
    (h4 : 1 - a * stereoAdd b c ≠ 0) :
    stereoAdd (stereoAdd a b) c = stereoAdd a (stereoAdd b c) := by
  unfold stereoAdd at *;
  grind




theorem tan_half_add_is_stereoAdd (α β : ℝ)
    (hα : Real.cos (α / 2) ≠ 0) (hβ : Real.cos (β / 2) ≠ 0)
    (hαβ : Real.cos ((α + β) / 2) ≠ 0)
    (hprod : 1 - Real.tan (α / 2) * Real.tan (β / 2) ≠ 0) :
    Real.tan ((α + β) / 2) = stereoAdd (Real.tan (α / 2)) (Real.tan (β / 2)) := by
  rw [ show ( α + β ) / 2 = α / 2 + β / 2 by ring, Real.tan_add ] ; simp_all +decide [ Real.tan_eq_sin_div_cos ] ; ring;
  · unfold stereoAdd; ring;
  · simp_all +decide [ Real.cos_eq_zero_iff ]




theorem stereo_circle_identity (t : ℝ) :
    (2 * t / (1 + t ^ 2)) ^ 2 + ((1 - t ^ 2) / (1 + t ^ 2)) ^ 2 = 1 := by
  field_simp
  ring




/-- The stereographic x-coordinate is the conformal factor times t.
x(t) = λ(t) · t where λ is the conformal factor. -/
theorem stereo_x_is_conformal_times_t (t : ℝ) :
    2 * t / (1 + t ^ 2) = conformalFactor1D t * t := by
  unfold conformalFactor1D; ring




/-- The "Pythagorean parametrization" from stereographic projection.
For any integers p, q, the triple (q²-p², 2pq, q²+p²) is Pythagorean. -/
theorem pythagorean_from_rational (p q : ℤ) :
    (q ^ 2 - p ^ 2) ^ 2 + (2 * p * q) ^ 2 = (q ^ 2 + p ^ 2) ^ 2 := by
  ring




theorem arc_length_zero_to_one :
    ∫ t in Set.Icc (0 : ℝ) 1, conformalFactor1D t = Real.pi / 2 := by
  rw [ MeasureTheory.integral_Icc_eq_integral_Ioc, ← intervalIntegral.integral_of_le ] <;> norm_num;
  unfold conformalFactor1D; ring;
  norm_num ; ring




theorem pi_over_four_is_arctan_one : Real.pi / 4 = Real.arctan 1 := by
  rw [ Real.arctan_one ]




/-- The stereographic inverse map ℝ → S¹ ⊂ ℝ². -/
def stereoInvMap (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))




/-- The stereographic forward map S¹ \ {N} → ℝ. -/
def stereoFwdMap (p : ℝ × ℝ) : ℝ := p.1 / (1 + p.2)




theorem light_embedding (t : ℝ) :
    let p := stereoInvMap t
    p.1 ^ 2 + p.2 ^ 2 = 1 := by
  -- By definition of $stereoInvMap$, we have $p = (2t / (1 + t^2), (1 - t^2) / (1 + t^2))$.
  simp [stereoInvMap];
  rw [ div_pow, div_pow, ← add_div, div_eq_iff ] <;> nlinarith




theorem mirror_theorem (t : ℝ) :
    stereoFwdMap (stereoInvMap t) = t := by
  unfold stereoFwdMap stereoInvMap ; ring;
  -- Simplify the expression to verify it equals $t$.
  field_simp
  ring




theorem reflection_theorem (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) (hy : y ≠ -1) :
    stereoInvMap (stereoFwdMap (x, y)) = (x, y) := by
  unfold stereoInvMap stereoFwdMap; norm_num [ hcirc, hy ] ; ring;
  grind




theorem stereoAdd_is_rotation (t₁ t₂ : ℝ) (h : 1 - t₁ * t₂ ≠ 0)
    (h1 : (1 + t₁ ^ 2) ≠ 0) (h2 : (1 + t₂ ^ 2) ≠ 0) :
    let p₁ := stereoInvMap t₁
    let p₂ := stereoInvMap t₂
    let s := stereoInvMap (stereoAdd t₁ t₂)
    s.1 = p₁.1 * p₂.2 + p₁.2 * p₂.1 := by
  unfold stereoInvMap stereoAdd; field_simp [ h1, h2, h ] ; ring;




end