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


theorem PhotonState.identity_fuse (p : PhotonState) :
    (PhotonState.identity.fuse p).px = p.px ∧
    (PhotonState.identity.fuse p).py = p.py ∧
    (PhotonState.identity.fuse p).energy = p.energy := by
  unfold PhotonState.fuse PhotonState.identity ; aesop;


theorem light_cone_triangulation (x₁ x₂ r₁ r₂ x y : ℝ)
    (h1 : (x - x₁)^2 + y^2 = r₁^2)
    (h2 : (x - x₂)^2 + y^2 = r₂^2)
    (hne : x₁ ≠ x₂) :
    x = (r₁^2 - r₂^2 + x₂^2 - x₁^2) / (2 * (x₂ - x₁)) := by
  rw [ eq_div_iff ] <;> cases lt_or_gt_of_ne hne <;> nlinarith
