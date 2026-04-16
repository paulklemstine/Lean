/-! # CatalogBuild.Physics.ArithmeticPhotons.PhotonicInverseStereo

Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 10
-/

import Mathlib

noncomputable section

/-- Forward stereographic projection from S² \ {N} to ℝ².
Maps (x, y, z) with z ≠ 1 to (x/(1-z), y/(1-z)). -/
def fwdStereo2D (x y z : ℝ) : ℝ × ℝ :=
  (x / (1 - z), y / (1 - z))



/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonicInverseStereo
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 10] -/
theorem conformal_factor_at_unit_circle (u v : ℝ) (h : u ^ 2 + v ^ 2 = 1) :
    conformalFactor u v = 1 := by
  unfold conformalFactor;
  grind



theorem conformal_factor_le_four (u v : ℝ) :
    conformalFactor u v ≤ 4 := by
  exact div_le_self ( by norm_num ) ( one_le_pow₀ ( by nlinarith ) )



/-- The chordal distance between two points on the sphere, lifted from the plane.
This is √(2 - 2·cos(d_geodesic)), related to the geodesic distance. -/
def chordalDistSq (u₁ v₁ u₂ v₂ : ℝ) : ℝ :=
  let p₁ := invStereo2D u₁ v₁
  let p₂ := invStereo2D u₂ v₂
  (p₁.1 - p₂.1) ^ 2 + (p₁.2.1 - p₂.2.1) ^ 2 + (p₁.2.2 - p₂.2.2) ^ 2



theorem chordal_distance_formula (u₁ v₁ u₂ v₂ : ℝ) :
    chordalDistSq u₁ v₁ u₂ v₂ =
      4 * ((u₁ - u₂) ^ 2 + (v₁ - v₂) ^ 2) /
        ((1 + u₁ ^ 2 + v₁ ^ 2) * (1 + u₂ ^ 2 + v₂ ^ 2)) := by
  unfold chordalDistSq invStereo2D;
  field_simp;
  grind +splitImp



/-- A photon in the PISPD model: has a position on the detector plane,
intensity, and wavelength. -/
structure PISPDPhoton where
  u : ℝ        -- position on plane (u-coordinate)
  v : ℝ        -- position on plane (v-coordinate)
  intensity : ℝ -- photon intensity ∈ [0, 1]
  wavelength : ℝ -- wavelength in appropriate units



/-- The conformal energy of a single photon: intensity weighted by the
conformal factor at its position. -/
def photonConformalEnergy (p : PISPDPhoton) : ℝ :=
  p.intensity * conformalFactor p.u p.v



theorem pispd_fundamental_identity (u v : ℝ) :
    (2 * u) ^ 2 + (2 * v) ^ 2 + (u ^ 2 + v ^ 2 - 1) ^ 2 =
      (u ^ 2 + v ^ 2 + 1) ^ 2 := by
  grind



theorem invStereo_dot_product (u₁ v₁ u₂ v₂ : ℝ) :
    let p₁ := invStereo2D u₁ v₁
    let p₂ := invStereo2D u₂ v₂
    p₁.1 * p₂.1 + p₁.2.1 * p₂.2.1 + p₁.2.2 * p₂.2.2 =
      (4 * u₁ * u₂ + 4 * v₁ * v₂ + (u₁^2 + v₁^2 - 1) * (u₂^2 + v₂^2 - 1)) /
        ((u₁^2 + v₁^2 + 1) * (u₂^2 + v₂^2 + 1)) := by
  unfold invStereo2D; field_simp; ring;



theorem pispd_lens_formula (r : ℝ) (hr : r ≥ 0) :
    let p₀ := invStereo2D 0 0
    let pᵣ := invStereo2D r 0
    p₀.1 * pᵣ.1 + p₀.2.1 * pᵣ.2.1 + p₀.2.2 * pᵣ.2.2 =
      (1 - r ^ 2) / (1 + r ^ 2) := by
  unfold invStereo2D; norm_num; ring;



end
