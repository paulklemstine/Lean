/-! # CatalogBuild.Shared.InvStereo_on_circle

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 3
-/

import Mathlib

noncomputable section

theorem invStereo_on_circle (t : ℝ) :
    (invStereo t).1 ^ 2 + (invStereo t).2 ^ 2 = 1 := by
  unfold invStereo
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp; ring

/-- **THE IDEMPOTENCE IDENTITY**: Decode ∘ Encode = Identity.
    The universe, viewed as the process of encoding (into a photon) and then
    decoding (back to a particle), is the identity map. This IS idempotence. -/

def invStereo (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))

/-- Forward stereographic projection: S¹ \ {south pole} → ℝ.
    The decoding: a photon state maps back to a massive particle state. -/

lemma invStereo_denom_pos (t : ℝ) : (0 : ℝ) < 1 + t ^ 2 := by positivity

/-- The encoding maps to S¹. -/

end
