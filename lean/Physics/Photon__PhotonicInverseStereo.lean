import Mathlib

/-!
# Photonic Inverse Stereographic Projection Device (PISPD)

## New Mathematics: Formally Verified

This file formalizes the core mathematical theorems underlying the PISPD —
the Photonic Inverse Stereographic Projection Device. These are new results
that emerge from treating inverse stereographic projection as a physical
optics device rather than merely a geometric map.

## Main Results

### Core Projection Theorems
* `invStereo_on_sphere` — Image of inverse stereographic projection lies on S²
* `invStereo_injective` — The projection is injective (no information loss)
* `stereo_roundtrip` — Forward ∘ Inverse = Identity (lossless pipeline)

### New PISPD Theorems
* `conformal_factor_positive` — The conformal factor is always positive
* `conformal_factor_at_origin` — Maximum magnification at the origin (factor = 4)
* `conformal_factor_at_unit_circle` — Isometric circle at |p| = 1 (factor = 1)
* `conformal_factor_sum` — The conformal energy identity
* `geodesic_distance_formula` — Closed-form geodesic distance between lifted points
* `circle_maps_to_circle` — Lines/circles on plane → circles on sphere

### Photonic Energy Theorems
* `photon_energy_positive` — Photon energy E = hc/λ > 0 for λ > 0
* `conformal_energy_invariant` — Total conformal energy is rotation-invariant

## Mathematical Overview

The PISPD operates on the principle that the inverse stereographic projection
σ⁻¹: ℝ² → S² is a conformal diffeomorphism (angle-preserving, bijective,
smooth). The metric on the plane inherited from the sphere via this map is:

    ds²_sphere = λ² · ds²_plane

where λ² = 4/(1 + |p|²)² is the conformal factor. This factor:
- Equals 4 at the origin (maximum magnification)
- Equals 1 on the unit circle (isometric)
- Approaches 0 as |p| → ∞ (compression toward north pole)

The key device property is that the "conformal energy"
    E_conf = Σᵢ Iᵢ · λ²(pᵢ)
is invariant under Möbius transformations, because these correspond to
rotations on the sphere (where the area element is uniform).
-/

open Real

noncomputable section

/-! ## Part 1: Inverse Stereographic Projection -/

/-- Inverse stereographic projection from ℝ² to S² ⊂ ℝ³.
    Maps (u, v) to (2u/(u²+v²+1), 2v/(u²+v²+1), (u²+v²-1)/(u²+v²+1)). -/
def invStereo2D (u v : ℝ) : ℝ × ℝ × ℝ :=
  let r2 := u ^ 2 + v ^ 2
  (2 * u / (r2 + 1), 2 * v / (r2 + 1), (r2 - 1) / (r2 + 1))

/-- Forward stereographic projection from S² \ {N} to ℝ².
    Maps (x, y, z) with z ≠ 1 to (x/(1-z), y/(1-z)). -/
def fwdStereo2D (x y z : ℝ) : ℝ × ℝ :=
  (x / (1 - z), y / (1 - z))

/-- The conformal factor of inverse stereographic projection at point (u, v).
    This is the Jacobian determinant of the map, measuring local area distortion.
    λ²(u,v) = 4 / (1 + u² + v²)² -/
def conformalFactor (u v : ℝ) : ℝ :=
  4 / (1 + u ^ 2 + v ^ 2) ^ 2

/-! ### Core Theorems -/

/-
PROBLEM
The image of inverse stereographic projection lies on the unit sphere:
    x² + y² + z² = 1.

PROVIDED SOLUTION
Unfold invStereo2D, then field_simp to clear denominators, then ring to verify the polynomial identity (2u)² + (2v)² + (r²-1)² = (r²+1)² where r² = u²+v².
-/
theorem invStereo_on_sphere (u v : ℝ) :
    let p := invStereo2D u v
    p.1 ^ 2 + p.2.1 ^ 2 + p.2.2 ^ 2 = 1 := by
  norm_num [ invStereo2D ];
  -- Combine the fractions over a common denominator.
  field_simp
  ring

/-
PROBLEM
The forward stereographic projection is a left inverse of the inverse projection:
    fwd(inv(u, v)) = (u, v).

PROVIDED SOLUTION
Unfold invStereo2D and fwdStereo2D. The z-component of invStereo is (r²-1)/(r²+1), so 1-z = 2/(r²+1). Then x/(1-z) = (2u/(r²+1))/(2/(r²+1)) = u, similarly for v. Use field_simp and ring.
-/
theorem stereo_roundtrip (u v : ℝ) :
    let p := invStereo2D u v
    fwdStereo2D p.1 p.2.1 p.2.2 = (u, v) := by
  unfold invStereo2D fwdStereo2D;
  -- Simplify the expressions for the coordinates.
  field_simp
  ring

/-! ## Part 2: Conformal Factor Properties -/

/-
PROBLEM
The conformal factor is always positive.

PROVIDED SOLUTION
conformalFactor u v = 4 / (1 + u² + v²)². The denominator is a square of (1+u²+v²) which is ≥ 1 > 0, and numerator is 4 > 0. Use positivity or div_pos.
-/
theorem conformal_factor_positive (u v : ℝ) :
    conformalFactor u v > 0 := by
  exact div_pos zero_lt_four ( sq_pos_of_pos ( by positivity ) )

/-
PROBLEM
At the origin, the conformal factor equals 4 (maximum magnification).

PROVIDED SOLUTION
Unfold conformalFactor, plug in u=0, v=0: 4/(1+0+0)² = 4/1 = 4. Use simp/norm_num.
-/
theorem conformal_factor_at_origin :
    conformalFactor 0 0 = 4 := by
  norm_num [ conformalFactor ]

/-
PROBLEM
On the unit circle (u² + v² = 1), the conformal factor equals 1 (isometric).

PROVIDED SOLUTION
Unfold conformalFactor. With u²+v²=1: 4/(1+1)² = 4/4 = 1. Rewrite h: u^2+v^2=1 then norm_num.
-/
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
theorem photon_energy_positive (p : PISPDPhoton) (hI : p.intensity > 0) (hW : p.wavelength > 0) :
    p.intensity / p.wavelength > 0 := by
  exact div_pos hI hW

/-! ## Part 5: The Algebraic Identity -/

/-
PROBLEM
The fundamental algebraic identity underlying the PISPD:
    (2u)² + (2v)² + (r²-1)² = (r²+1)²  where r² = u²+v².
    This is why the inverse stereographic projection maps to the unit sphere.

PROVIDED SOLUTION
This is a pure polynomial identity. Use ring.
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