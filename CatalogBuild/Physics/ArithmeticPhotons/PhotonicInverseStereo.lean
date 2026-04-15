/-! # CatalogBuild.Physics.ArithmeticPhotons.PhotonicInverseStereo

Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 10
-/

import Mathlib

noncomputable section

def fwdStereo2D (x y z : ℝ) : ℝ × ℝ :=
  (x / (1 - z), y / (1 - z))

/-- The conformal factor of inverse stereographic projection at point (u, v).
    This is the Jacobian determinant of the map, measuring local area distortion.
    λ²(u,v) = 4 / (1 + u² + v²)² -/

theorem conformal_factor_at_unit_circle (u v : ℝ) (h : u ^ 2 + v ^ 2 = 1) :
    conformalFactor u v = 1 := by
  unfold conformalFactor;
  grind

/-
PROBLEM
The conformal factor is at most 4 everywhere.

PROVIDED SOLUTION
conformalFactor u v = 4/(1+u²+v²)². Since u²+v² ≥ 0, 1+u²+v² ≥ 1, so (1+u²+v²)² ≥ 1, thus 4/(1+u²+v²)² ≤ 4/1 = 4. Use div_le_div and sq_nonneg.
-/

theorem conformal_factor_le_four (u v : ℝ) :
    conformalFactor u v ≤ 4 := by
  exact div_le_self ( by norm_num ) ( one_le_pow₀ ( by nlinarith ) )

/-! ## Part 3: Geodesic Distance -/

/-- The chordal distance between two points on the sphere, lifted from the plane.
    This is √(2 - 2·cos(d_geodesic)), related to the geodesic distance. -/

def chordalDistSq (u₁ v₁ u₂ v₂ : ℝ) : ℝ :=
  let p₁ := invStereo2D u₁ v₁
  let p₂ := invStereo2D u₂ v₂
  (p₁.1 - p₂.1) ^ 2 + (p₁.2.1 - p₂.2.1) ^ 2 + (p₁.2.2 - p₂.2.2) ^ 2

/-
PROBLEM
The squared chordal distance between inverse-stereographically projected points
    equals 4|p₁ - p₂|² / ((1+|p₁|²)(1+|p₂|²)). This is the key formula relating
    plane distances to spherical distances through the PISPD.

PROVIDED SOLUTION
Unfold chordalDistSq and invStereo2D, then field_simp to clear all denominators, then ring to verify the polynomial identity.
-/

theorem chordal_distance_formula (u₁ v₁ u₂ v₂ : ℝ) :
    chordalDistSq u₁ v₁ u₂ v₂ =
      4 * ((u₁ - u₂) ^ 2 + (v₁ - v₂) ^ 2) /
        ((1 + u₁ ^ 2 + v₁ ^ 2) * (1 + u₂ ^ 2 + v₂ ^ 2)) := by
  unfold chordalDistSq invStereo2D;
  field_simp;
  grind +splitImp

/-! ## Part 4: Photonic Energy Model -/

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

/-
PROBLEM
Photon energy E = hc/λ is positive for positive wavelength and intensity.

PROVIDED SOLUTION
div_pos hI hW
-/

theorem pispd_fundamental_identity (u v : ℝ) :
    (2 * u) ^ 2 + (2 * v) ^ 2 + (u ^ 2 + v ^ 2 - 1) ^ 2 =
      (u ^ 2 + v ^ 2 + 1) ^ 2 := by
  grind

/-
PROBLEM
The dot product of two inverse-stereographically projected points.
    Given on the plane at (u₁,v₁) and (u₂,v₂), their dot product on the sphere is:
    ⟨σ⁻¹(p₁), σ⁻¹(p₂)⟩ = (4u₁u₂ + 4v₁v₂ + (r₁²-1)(r₂²-1)) / ((r₁²+1)(r₂²+1))

PROVIDED SOLUTION
Unfold invStereo2D, field_simp to clear denominators, then ring.
-/

theorem invStereo_dot_product (u₁ v₁ u₂ v₂ : ℝ) :
    let p₁ := invStereo2D u₁ v₁
    let p₂ := invStereo2D u₂ v₂
    p₁.1 * p₂.1 + p₁.2.1 * p₂.2.1 + p₁.2.2 * p₂.2.2 =
      (4 * u₁ * u₂ + 4 * v₁ * v₂ + (u₁^2 + v₁^2 - 1) * (u₂^2 + v₂^2 - 1)) /
        ((u₁^2 + v₁^2 + 1) * (u₂^2 + v₂^2 + 1)) := by
  unfold invStereo2D; field_simp; ring;

/-
PROBLEM
When a photon at the origin is paired with one at distance r,
    their spherical separation is 2·arctan(r). This is the "PISPD lens formula".

PROVIDED SOLUTION
Unfold invStereo2D, simplify with u₁=0, v₁=0, u₂=r, v₂=0. The dot product becomes (0*2r/(r²+1) + 0*0 + (-1)*(r²-1)/(r²+1)) = (1-r²)/(1+r²). Use simp and field_simp and ring.
-/

theorem pispd_lens_formula (r : ℝ) (hr : r ≥ 0) :
    let p₀ := invStereo2D 0 0
    let pᵣ := invStereo2D r 0
    p₀.1 * pᵣ.1 + p₀.2.1 * pᵣ.2.1 + p₀.2.2 * pᵣ.2.2 =
      (1 - r ^ 2) / (1 + r ^ 2) := by
  unfold invStereo2D; norm_num; ring;


end
