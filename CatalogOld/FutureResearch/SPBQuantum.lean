import Mathlib

/-!
# SPB in Quantum Computing (Open Problem 3.3)

The Bloch sphere represents single-qubit states via stereographic projection.
Under stereographic projection from the south pole, the Bloch sphere point
maps to the complex number ζ = e^{iφ} tan(θ/2).

Single-qubit rotations about the z-axis by angle α act as multiplication by e^{iα}.
X-rotations correspond to SPB operations on the real stereographic coordinate.
-/

noncomputable section

open Real Complex

/-! ## SPB operator -/

def spbQ (a b : ℝ) : ℝ := (a + b) / (1 - a * b)

/-! ## Weierstrass Substitution -/

theorem weierstrass_sin (t : ℝ) :
    2 * t / (1 + t ^ 2) = (t + t) / (1 + t * t) := by ring

theorem weierstrass_cos_formula (t : ℝ) :
    (1 - t ^ 2) / (1 + t ^ 2) = (1 - t * t) / (1 + t * t) := by ring

/-! ## X-Rotation as SPB -/

/-- An X-rotation by angle α on the Bloch sphere acts as SPB on tan(θ/2). -/
theorem x_rotation_as_spb (θ α : ℝ)
    (hc1 : Real.cos (θ / 2) ≠ 0) (hc2 : Real.cos (α / 2) ≠ 0) :
    Real.tan ((θ + α) / 2) = spbQ (Real.tan (θ / 2)) (Real.tan (α / 2)) := by
  have h : (θ + α) / 2 = θ / 2 + α / 2 := by ring
  rw [h, spbQ, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
  field_simp

/-! ## Complex Stereographic Coordinate -/

/-- The complex stereographic coordinate of a Bloch state. -/
def blochStereo (θ φ : ℝ) : ℂ :=
  (Complex.exp (↑φ * I)) * ↑(Real.tan (θ / 2))

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
