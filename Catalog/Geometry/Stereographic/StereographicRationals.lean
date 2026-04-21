/-! # CatalogBuild.Geometry.Stereographic.StereographicRationals

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 13
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Geometry.Stereographic.StereographicRationals
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 14] -/
theorem stereo_on_circle (t : ℚ) : (stereoX t)^2 + (stereoY t)^2 = 1 := by
  -- By definition of $stereoX$ and $stereoY$, we know that $(stereoX t)^2 + (stereoY t)^2 = \frac{(1-t^2)^2 + (2t)^2}{(1+t^2)^2}$.
  have h_def : (stereoX t)^2 + (stereoY t)^2 = ((1 - t^2)^2 + (2 * t)^2) / (1 + t^2)^2 := by
    unfold stereoX stereoY; ring;
    grind;
  rw [ h_def, div_eq_iff ] <;> ring ; positivity;




/-- [Section: # CatalogBuild.Geometry.Stereographic.StereographicRationals
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 14] -/
theorem stereo_injective : Function.Injective (fun t : ℚ => (stereoX t, stereoY t)) := by
  intro a b h; have := congr_arg Prod.fst h; ((have := congr_arg Prod.snd h; ((simp_all +decide [ stereoX, stereoY ])))) ;
  rw [ div_eq_div_iff, div_eq_div_iff ] at h <;> nlinarith [ sq_nonneg ( a - b ), mul_self_nonneg a, mul_self_nonneg b ]




/-- The inverse map: from a rational point (x,y) on the circle (with x ≠ -1) back to ℚ -/
noncomputable def stereoInv (x y : ℚ) (hx : x ≠ -1) : ℚ := y / (1 + x)




theorem stereo_inv_left (t : ℚ) :
    stereoInv (stereoX t) (stereoY t) (by
      unfold stereoX
      intro h
      have := one_plus_sq_ne_zero t
      field_simp at h
      linarith [sq_nonneg t]) = t := by
        unfold stereoX stereoY stereoInv
        field_simp
        ring_nf




/-- Clearing denominators in the stereographic map produces integer triples.
For t = p/q, we get the Pythagorean triple (q² - p², 2pq, q² + p²). -/
def pythagorean_from_params (p q : ℤ) : ℤ × ℤ × ℤ :=
  (q^2 - p^2, 2 * p * q, q^2 + p^2)




theorem pythagorean_triple_parametric (p q : ℤ) :
    let (a, b, c) := pythagorean_from_params p q
    a^2 + b^2 = c^2 := by
      unfold pythagorean_from_params; ring;




/-- The circle group law transported to ℚ via stereographic projection.
This is the "addition" that the rationals are secretly performing. -/
noncomputable def circleAdd (t₁ t₂ : ℚ) (h : t₁ * t₂ ≠ 1) : ℚ :=
  (t₁ + t₂) / (1 - t₁ * t₂)




theorem circle_add_stereo_x (t₁ t₂ : ℚ) (h : t₁ * t₂ ≠ 1) :
    stereoX (circleAdd t₁ t₂ h) =
    stereoX t₁ * stereoX t₂ - stereoY t₁ * stereoY t₂ := by
      unfold stereoX stereoY circleAdd;
      field_simp
      ring;
      grind




theorem circle_add_stereo_y (t₁ t₂ : ℚ) (h : t₁ * t₂ ≠ 1) :
    stereoY (circleAdd t₁ t₂ h) =
    stereoX t₁ * stereoY t₂ + stereoY t₁ * stereoX t₂ := by
      unfold stereoX stereoY circleAdd;
      field_simp;
      grind




/-- A 2×2 rational rotation matrix determined by stereographic parameter t -/
noncomputable def ratRotation (t : ℚ) : Matrix (Fin 2) (Fin 2) ℚ :=
  !![stereoX t, -(stereoY t); stereoY t, stereoX t]




theorem ratRotation_det_one (t : ℚ) :
    Matrix.det (ratRotation t) = 1 := by
      convert stereo_on_circle t using 1 ; unfold ratRotation ; norm_num [ Matrix.det_fin_two ] ; ring




/-- The mediant of two rational numbers, expressed via numerator/denominator -/
def mediant (p₁ q₁ p₂ q₂ : ℤ) (hq : q₁ + q₂ ≠ 0) : ℚ :=
  (p₁ + p₂ : ℤ) / (q₁ + q₂ : ℤ)




/-- The norm of a Gaussian integer pair -/
def gaussNorm (a b : ℤ) : ℤ := a^2 + b^2




end
