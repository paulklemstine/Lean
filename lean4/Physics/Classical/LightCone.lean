/-
# Light Cone Geometry and Photon Triangulation

The light cone in Minkowski space is defined by x² + y² + z² = (ct)².
For a 2D photon with momentum (a, b) and energy c, the light cone
condition is exactly the Pythagorean relation a² + b² = c².

## Key Results
1. Light cone intersection determines position (triangulation)
2. The light cone lattice points are exactly the Pythagorean triples
3. Primitive photon counting: #{primitive triples with c ≤ N} ~ N/(2π)
-/
import Mathlib

/-- A photon state is a Pythagorean triple -/
structure PhotonState where
  px : ℤ  -- x-momentum
  py : ℤ  -- y-momentum
  energy : ℤ  -- energy (hypotenuse)
  on_cone : px^2 + py^2 = energy^2
  energy_pos : 0 < energy

/-
PROBLEM
The Gaussian product of two photon states

PROVIDED SOLUTION
on_cone: (px₁*px₂ - py₁*py₂)² + (px₁*py₂ + py₁*px₂)² = (px₁² + py₁²)(px₂² + py₂²) = e₁²*e₂² = (e₁*e₂)² by Brahmagupta-Fibonacci (ring). energy_pos: product of positives is positive, use mul_pos.
-/
def PhotonState.fuse (p q : PhotonState) : PhotonState where
  px := p.px * q.px - p.py * q.py
  py := p.px * q.py + p.py * q.px
  energy := p.energy * q.energy
  on_cone := by
    linear_combination' p.on_cone * q.on_cone - 2 * 0 * p.energy * q.energy - 0 * p.energy ^ 2 - 0 * q.energy ^ 2 + 0 * p.energy ^ 2 * q.energy ^ 2 - 0 * p.energy ^ 3 - 0 * q.energy ^ 3 + 0 * p.energy ^ 3 * q.energy ^ 3 + 0 * p.energy ^ 4 + 0 * q.energy ^ 4 - 0 * p.energy ^ 4 * q.energy ^ 4 + 0 * p.energy ^ 5 - 0 * q.energy ^ 5 + 0 * p.energy ^ 5 * q.energy ^ 5 + 0 * p.energy ^ 6 - 0 * q.energy ^ 6 + 0 * p.energy ^ 6 * q.energy ^ 6 + 0 * p.energy ^ 7 - 0 * q.energy ^ 7 + 0 * p.energy ^ 7 * q.energy ^ 7 + 0 * p.energy ^ 8 - 0 * q.energy ^ 8;
  energy_pos := mul_pos p.energy_pos q.energy_pos

/-
PROBLEM
Photon fusion is commutative

PROVIDED SOLUTION
Unfold fuse. px: a*c - b*d vs c*a - d*b, which are equal by mul_comm. Similarly for py and energy. Use constructor and ring/mul_comm.
-/
theorem PhotonState.fuse_comm (p q : PhotonState) :
    (p.fuse q).px = (q.fuse p).px ∧
    (p.fuse q).py = (q.fuse p).py ∧
    (p.fuse q).energy = (q.fuse p).energy := by
  exact ⟨ by unfold PhotonState.fuse; ring, by unfold PhotonState.fuse; ring, by unfold PhotonState.fuse; ring ⟩

/-
PROBLEM
Photon fusion is associative

PROVIDED SOLUTION
Unfold fuse twice on each side. All three components are polynomial identities in the underlying integers. Use ring for each.
-/
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