import Mathlib

/-!
# Inverse Stereographic Renormalization Group

This file gives an exact, deliberately modest bridge between the zero-field
one-dimensional Ising decimation map and conformal geometry.

Use the high-temperature coupling `g = tanh K`.  Decimating alternate spins
sends `g` to `g²`.  Inverse stereographic projection compactifies the coupling
line to the unit circle.  The main theorem proves that Ising decimation is
conjugate to an explicit rational self-map of that circle.

This does not identify the perturbative beta function of four-dimensional
`phi^4` theory with stereographic differentiation; that broader conjecture
needs additional physical hypotheses and is not asserted here.
-/

noncomputable section

namespace InverseStereographicRG

/-- Inverse stereographic projection from the real coupling line to the circle. -/
def invStereo (g : ℝ) : ℝ × ℝ :=
  (2 * g / (1 + g ^ 2), (1 - g ^ 2) / (1 + g ^ 2))

/-- The exact zero-field 1D Ising decimation map in `g = tanh K` coordinates. -/
def isingRG (g : ℝ) : ℝ := g ^ 2

/-- The discrete beta observable (one RG step minus the original coupling). -/
def beta (g : ℝ) : ℝ := isingRG g - g

/-- The rational circle map induced by Ising decimation through stereography. -/
def circleRG (p : ℝ × ℝ) : ℝ × ℝ :=
  (p.1 ^ 2 / (2 - p.1 ^ 2), 2 * p.2 / (1 + p.2 ^ 2))

/-- Inverse stereographic projection lands on the unit circle. -/
theorem invStereo_on_circle (g : ℝ) :
    (invStereo g).1 ^ 2 + (invStereo g).2 ^ 2 = 1 := by
  unfold invStereo
  dsimp
  field_simp [show 1 + g ^ 2 ≠ 0 by positivity]
  ring

/-- **Connector theorem.** 1D Ising decimation and the rational circle map are
exactly conjugate by inverse stereographic projection. -/
theorem isingRG_stereographic_conjugacy (g : ℝ) :
    invStereo (isingRG g) = circleRG (invStereo g) := by
  unfold invStereo isingRG circleRG
  apply Prod.ext <;> dsimp
  · field_simp [show 1 + g ^ 2 ≠ 0 by positivity,
        show 1 + g ^ 4 ≠ 0 by positivity]
    rw [show (1 + g ^ 2) ^ 2 - 2 * g ^ 2 = 1 + g ^ 4 by ring]
    field_simp [show 1 + g ^ 4 ≠ 0 by positivity]
  · field_simp [show 1 + g ^ 2 ≠ 0 by positivity,
        show 1 + g ^ 4 ≠ 0 by positivity]
    ring

/-- The Ising beta observable has precisely the finite fixed couplings `0` and
`1`. (The physical high-temperature coordinate usually restricts to `[0,1)`.) -/
theorem beta_eq_zero_iff (g : ℝ) : beta g = 0 ↔ g = 0 ∨ g = 1 := by
  unfold beta isingRG
  constructor
  · intro h
    rcases mul_eq_zero.mp (by nlinarith : g * (g - 1) = 0) with h0 | h1
    · exact Or.inl h0
    · exact Or.inr (by linarith)
  · rintro (rfl | rfl) <;> norm_num

/-- The linearized RG eigenvalue is the derivative of the stereographic chart
coordinate update: both are `2g`. -/
theorem isingRG_hasDerivAt (g : ℝ) : HasDerivAt isingRG (2 * g) g := by
  simpa [isingRG, two_mul] using (hasDerivAt_id g).pow 2

/-- Consequently, the derivative of the discrete beta observable is `2g - 1`. -/
theorem beta_hasDerivAt (g : ℝ) : HasDerivAt beta (2 * g - 1) g := by
  simpa [beta] using (isingRG_hasDerivAt g).sub (hasDerivAt_id g)

/-- A machine-checked small-case table for the proposed RG map. -/
theorem computational_evidence :
    isingRG 0 = 0 ∧
    isingRG (1 / 4 : ℝ) = 1 / 16 ∧
    isingRG (1 / 2 : ℝ) = 1 / 4 ∧
    isingRG (3 / 4 : ℝ) = 9 / 16 ∧
    isingRG 1 = 1 := by
  norm_num [isingRG]

end InverseStereographicRG