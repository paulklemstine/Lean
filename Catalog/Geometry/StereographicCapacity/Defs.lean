/-
Copyright (c) 2025. All rights reserved.
Stereographic Capacity Theory: Packing Bounds on Spheres via Plane Geometry

This module defines the core objects of stereographic capacity theory:
conformal factors, exclusion radii, cap areas, and packing bound predicates.
-/
import Mathlib

open Real Finset

/-! ## Core Definitions for Stereographic Capacity Theory -/

/-- The stereographic conformal factor at a point `x ∈ ℝ^n`.
This is the local scale factor `λ(x) = 2/(1 + ‖x‖²)` of stereographic
projection from the north pole of `S^n` to `ℝ^n`. -/
noncomputable def stereoFactor {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) : ℝ :=
  2 / (1 + ‖x‖ ^ 2)

/-- The weighted Euclidean exclusion radius induced by spherical radius `r`
at a projected point `x`. Under stereographic projection, a spherical cap
of geodesic radius `r` centered at a point projecting to `x` maps to a
Euclidean ball of approximately this radius. -/
noncomputable def stereoExclusionRadius {n : ℕ} (r : ℝ) (x : EuclideanSpace ℝ (Fin n)) : ℝ :=
  Real.tan r / stereoFactor x

/-- A finite set of projected points is `StereoSeparated` for radius `r`
if every pair satisfies the weighted exclusion condition. This is the
Euclidean counterpart of pairwise `2r`-separation on the sphere. -/
def StereoSeparated {n : ℕ}
    (r : ℝ) (s : Finset (EuclideanSpace ℝ (Fin n))) : Prop :=
  ∀ ⦃x y⦄, x ∈ s → y ∈ s → x ≠ y →
    stereoExclusionRadius r x + stereoExclusionRadius r y ≤ ‖x - y‖

/-- The area of the unit 2-sphere `S²`. Equals `4π`. -/
noncomputable def sphereArea (_ : ℕ) : ℝ := 4 * Real.pi

/-- The area of a spherical cap of geodesic radius `r` on the unit 2-sphere.
A cap of radius `r` on `S²` has area `2π(1 - cos r)`. -/
noncomputable def sphericalCapArea (r : ℝ) : ℝ := 2 * Real.pi * (1 - Real.cos r)

/-- `SphericalPackingBound n r B` asserts that every finite set of points on the
unit sphere `S^n` in `ℝ^{n+1}` with pairwise distance at least `2r` has at most
`⌈B⌉₊` elements. This predicate captures upper bounds on packing numbers. -/
def SphericalPackingBound (n : ℕ) (r B : ℝ) : Prop :=
  ∀ s : Finset (Metric.sphere (0 : EuclideanSpace ℝ (Fin (n + 1))) 1),
    (∀ ⦃x y⦄, x ∈ s → y ∈ s → (x : EuclideanSpace ℝ (Fin (n + 1))) ≠ y →
      2 * r ≤ dist (x : EuclideanSpace ℝ (Fin (n + 1))) (y : EuclideanSpace ℝ (Fin (n + 1)))) →
    s.card ≤ ⌈B⌉₊

/-- The stereographic distortion bound for dimension-2 packing.
This is the quantity `(2/cos r)² · (sphereArea 2 / sphericalCapArea r)`. -/
noncomputable def stereoBoundS2 (r : ℝ) : ℝ :=
  ((2 / Real.cos r) ^ 2) * (sphereArea 2 / sphericalCapArea r)

/-- Closed-form expression for the S² packing bound:
`8 / (cos²r · (1 - cos r))`. -/
noncomputable def stereoBoundS2Closed (r : ℝ) : ℝ :=
  8 / (Real.cos r ^ 2 * (1 - Real.cos r))