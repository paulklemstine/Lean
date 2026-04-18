import Mathlib

/-! # CatalogBuild.Geometry.Stereographic.StereographicLens

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 15
-/


noncomputable section

/-- Stereographic projection from the unit circle S¹ ⊂ ℝ² to ℝ.
Projects from the north pole (0, 1) through a point (x, y) on the circle
to the x-axis. The formula is: σ(x, y) = x / (1 - y). -/
def circleStereographic (p : ℝ × ℝ) : ℝ :=
  p.1 / (1 - p.2)



/-- Inverse stereographic projection from ℝ to the unit circle S¹ ⊂ ℝ².
Maps t ∈ ℝ to the point ((2t)/(t²+1), (t²-1)/(t²+1)) on the circle. -/
def circleStereographicInv (t : ℝ) : ℝ × ℝ :=
  (2 * t / (t ^ 2 + 1), (t ^ 2 - 1) / (t ^ 2 + 1))



/-- [Section: # CatalogBuild.Geometry.Stereographic.StereographicLens
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 15] -/
theorem circleStereographicInv_on_circle (t : ℝ) :
    let p := circleStereographicInv t
    p.1 ^ 2 + p.2 ^ 2 = 1 := by
      -- Expand the definitions of `circleStereographicInv` and simplify the expression.
      simp [circleStereographicInv]
      field_simp
      ring



theorem circleStereographic_inv_left (t : ℝ) :
    circleStereographic (circleStereographicInv t) = t := by
      unfold circleStereographic circleStereographicInv;
      -- Combine and simplify the fractions in the expression.
      field_simp
      ring



theorem circleStereographic_inv_right (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1)
    (hy : y ≠ 1) :
    circleStereographicInv (circleStereographic (x, y)) = (x, y) := by
      unfold circleStereographicInv circleStereographic;
      grind



theorem idempotent_lens_circle (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) (hy : y ≠ 1) :
    let L := circleStereographicInv ∘ circleStereographic
    L (L (x, y)) = L (x, y) := by
      -- By definition of L, we have L(x, y) = (x, y).
      simp [circleStereographic_inv_right x y hcirc hy]



theorem idempotent_dual_lens_circle (t : ℝ) :
    let L' := circleStereographic ∘ circleStereographicInv
    L' (L' t) = L' t := by
      convert circleStereographic_inv_left ( circleStereographic ( circleStereographicInv t ) ) using 1



theorem circleStereographic_deriv_ne_zero (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1)
    (hy : y ≠ 1) (hx : x ≠ 0) :
    (1 : ℝ) / (1 - y) ≠ 0 := by
      exact one_div_ne_zero <| sub_ne_zero_of_ne <| Ne.symm hy



/-- The Fourier-like parity operator on ℝ: P(t) = -t.
This is the analogue of F² in the circle/line setting. -/
def parityOp : ℝ → ℝ := fun t => -t



theorem parity_involution (t : ℝ) : parityOp (parityOp t) = t := by
  exact neg_neg t



theorem stereographic_antipodal (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1)
    (hy : y ≠ 1) (hny : y ≠ -1) :
    circleStereographic (-x, -y) = -(1 / circleStereographic (x, y)) := by
      rw [ circleStereographic, circleStereographic ] ; ring_nf;
      grind



theorem onepoint_real_compact : CompactSpace (OnePoint ℝ) := by
  infer_instance



theorem onepoint_real_connected : ConnectedSpace (OnePoint ℝ) := by
  refine' ⟨ _ ⟩;
  exact ⟨ OnePoint.some 0 ⟩



/-- A point on the circle is a "fixed point of the lens" if its stereographic
image equals its x-coordinate. This characterizes self-referential points. -/
def isLensFixedPoint (x y : ℝ) : Prop :=
  x ^ 2 + y ^ 2 = 1 ∧ y ≠ 1 ∧ circleStereographic (x, y) = x



theorem lens_fixed_points (x y : ℝ) :
    isLensFixedPoint x y ↔
      (x = 1 ∧ y = 0) ∨ (x = -1 ∧ y = 0) ∨ (x = 0 ∧ y = -1) := by
        grind +locals



end
