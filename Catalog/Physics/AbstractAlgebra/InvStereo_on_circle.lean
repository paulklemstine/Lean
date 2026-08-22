-- Repaired copy: this module was a stale, non-compiling duplicate of `Shared.AbstractAlgebra.InvStereo_on_circle`.
-- Its content is synchronised with that (compiling) module.
import Mathlib

/-! # CatalogBuild.Shared.InvStereo_on_circle

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3
-/

noncomputable section

/-- Inverse stereographic projection: ℝ → S¹ ⊂ ℝ².
The encoding: a massive particle's state t maps to a photon state on S¹. -/
def invStereo (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))

/-- The denominator 1 + t² is always positive. -/
lemma invStereo_denom_pos (t : ℝ) : (0 : ℝ) < 1 + t ^ 2 := by positivity

/-- The encoding maps to S¹. -/
theorem invStereo_on_circle (t : ℝ) :
    (invStereo t).1 ^ 2 + (invStereo t).2 ^ 2 = 1 := by
  unfold invStereo
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp; ring

end