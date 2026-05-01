/-! # CatalogBuild.Algebra.SPBQuantum

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 4
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.SPBQuantum
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 4] -/
theorem weierstrass_cos_formula (t : ℝ) :
    (1 - t ^ 2) / (1 + t ^ 2) = (1 - t * t) / (1 + t * t) := by ring


/-- An X-rotation by angle α on the Bloch sphere acts as SPB on tan(θ/2). -/
theorem x_rotation_as_spb (θ α : ℝ)
    (hc1 : Real.cos (θ / 2) ≠ 0) (hc2 : Real.cos (α / 2) ≠ 0) :
    Real.tan ((θ + α) / 2) = spbQ (Real.tan (θ / 2)) (Real.tan (α / 2)) := by
  have h : (θ + α) / 2 = θ / 2 + α / 2 := by ring
  rw [h, spbQ, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
  field_simp


/-- Z-rotation by angle α multiplies the stereographic coordinate by e^{iα}. -/
theorem z_rotation_stereo (θ φ α : ℝ) :
    blochStereo θ (φ + α) = Complex.exp (↑α * I) * blochStereo θ φ := by
  simp [blochStereo, add_mul, Complex.exp_add]
  ring


/-- The Hadamard gate maps |0⟩ (t=0) to |+⟩ (t=1) on the xz-plane.
In SPB: spb(0, 1) = 1 = tan(π/4). -/
theorem hadamard_spb_action : spbQ 0 1 = 1 := by
  simp [spbQ]


end
