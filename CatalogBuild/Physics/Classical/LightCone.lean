/-! # CatalogBuild.Physics.Classical.LightCone

Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 4
-/

import Mathlib

theorem PhotonState.fuse_assoc (p q r : PhotonState) :
    ((p.fuse q).fuse r).px = (p.fuse (q.fuse r)).px ∧
    ((p.fuse q).fuse r).py = (p.fuse (q.fuse r)).py ∧
    ((p.fuse q).fuse r).energy = (p.fuse (q.fuse r)).energy := by
  unfold PhotonState.fuse;
  grind +ring

/-- The identity photon: (1, 0, 1) representing a photon
    traveling purely in the x-direction.
    Note: (0,1,1) is NOT the identity under Gaussian product;
    (1,0,1) is, since (1+0i)(a+bi) = a+bi. -/

def PhotonState.identity : PhotonState where
  px := 1
  py := 0
  energy := 1
  on_cone := by norm_num
  energy_pos := by norm_num

/-
PROBLEM
The identity photon is a left identity for fusion

PROVIDED SOLUTION
Unfold fuse and identity. px = 1*p.px - 0*p.py = p.px, py = 1*p.py + 0*p.px = p.py, energy = 1*p.energy = p.energy. Use simp/ring.
-/

theorem PhotonState.identity_fuse (p : PhotonState) :
    (PhotonState.identity.fuse p).px = p.px ∧
    (PhotonState.identity.fuse p).py = p.py ∧
    (PhotonState.identity.fuse p).energy = p.energy := by
  unfold PhotonState.fuse PhotonState.identity ; aesop;

/-
PROBLEM
Light cone intersection: two light cones from positions (x₁,0) and (x₂,0)
    with radii r₁ and r₂ intersect at a point determined by:
    (x - x₁)² + y² = r₁² and (x - x₂)² + y² = r₂²
    Subtracting: x = (r₁² - r₂² + x₂² - x₁²) / (2(x₂ - x₁))

PROVIDED SOLUTION
Subtract h2 from h1: (x-x₁)² - (x-x₂)² = r₁² - r₂². Expand: x²-2x·x₁+x₁² - x²+2x·x₂-x₂² = r₁²-r₂². So 2x(x₂-x₁) + x₁²-x₂² = r₁²-r₂². Then 2x(x₂-x₁) = r₁²-r₂²+x₂²-x₁². Divide by 2(x₂-x₁). Use field_simp and linarith/ring.
-/

theorem light_cone_triangulation (x₁ x₂ r₁ r₂ x y : ℝ)
    (h1 : (x - x₁)^2 + y^2 = r₁^2)
    (h2 : (x - x₂)^2 + y^2 = r₂^2)
    (hne : x₁ ≠ x₂) :
    x = (r₁^2 - r₂^2 + x₂^2 - x₁^2) / (2 * (x₂ - x₁)) := by
  rw [ eq_div_iff ] <;> cases lt_or_gt_of_ne hne <;> nlinarith
