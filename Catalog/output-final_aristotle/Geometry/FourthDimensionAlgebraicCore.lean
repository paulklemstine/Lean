/-
# A Compact Algebraic Core for Four-Dimensional Geometry

A single sum-of-squares identity,
`(a + b)² = 4ab + (a − b)²`,
turns out to organize four apparently unrelated pieces of four-dimensional
geometry: the fixed-point-free complex structure `J` on `ℝ⁴`, the sphere-valued
Hopf map, the balanced radii of the Clifford torus, and the interplay between the
volume of the four-ball and the surface measure of the three-sphere.  Alongside
these we isolate the purely combinatorial companion identity
`∑ₖ (−1)ᵏ C(n,k) 2ⁿ⁻ᵏ = 1`,
which computes the Euler characteristic of the boundary of the `n`-cube as
`1 − (−1)ⁿ`.

## Main results

* `sum_of_squares_core` — the driving identity `(a+b)² = 4ab + (a−b)²`.
* `J4`, `J4_sq_eq_neg`, `J4_preserves_normSq`, `J4_fixedPointFree` — an explicit
  complex structure on `ℝ⁴`: it squares to `−I`, preserves the Euclidean norm,
  and has no nonzero fixed point (hence acts without fixed points on the sphere).
* `hopf`, `hopf_circle_invariant`, `hopf_image_on_sphere` — the Hopf map is
  constant on the diagonal circle orbits and lands on the two-sphere of radius
  `‖(z,w)‖²`; the sphere identity is a direct instance of the core identity.
* `clifford_balance`, `clifford_area_sq_le`, `clifford_balanced_iff` — on the
  radius constraint `r₁² + r₂² = 1` the product `4 r₁² r₂²` equals
  `1 − (r₁² − r₂²)²`, so it is maximized exactly at the balanced Clifford torus
  `r₁² = r₂² = ½`.
* `cube_alternating_face_sum`, `cube_boundary_euler` — the full `n`-cube has
  alternating face sum `1`, so its boundary sphere has Euler characteristic
  `1 − (−1)ⁿ`.
* `hasDerivAt_ball4_volume` — the four-ball volume `r ↦ (π²/2) r⁴` has derivative
  `2π² r³`, the surface measure of the bounding three-sphere.

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): the identity (a+b)² = 4ab + (a−b)² is the common
--   algebraic engine behind the Hopf map, the Clifford torus, and the
--   norm-preserving "rotation through the fourth dimension".  A separate binomial
--   identity should govern cube Euler characteristics.
-- Experiment (Experimenter): realized J as (x₁,x₂,x₃,x₄) ↦ (−x₂,x₁,−x₄,x₃) and
--   verified J² = −I, norm-preservation, and fixed-point freeness by `ring`/case
--   analysis.  Realized the Hopf map on ℂ² and proved circle-invariance from
--   |λ|² = 1, and the sphere identity as a direct instance of the core identity.
--   Proved the Clifford balance as `4ab = 1 − (a−b)²` on `a+b = 1`.  Proved the
--   alternating face sum from the binomial theorem with x = −1, y = 2.
-- Analysis (Analyst): every geometric statement collapses onto one of two
--   algebraic identities — the sum-of-squares identity (continuous side) and the
--   binomial theorem (discrete side).  The odd-dimensional fixed-point obstruction
--   appears here concretely: J − I is invertible because `Jx = x` forces `x = 0`.
-- Critique (Critic): guarded the Clifford result with the exact biconditional to
--   avoid a vacuous inequality; the derivative statement links volume and surface
--   constants honestly rather than asserting an unproved isoperimetric extremum.
-- Synthesis (PI): the four-dimensional "playground" is, at its core, two
--   identities; the file exhibits both and their geometric shadows.
-/

import Mathlib

namespace Geometry.FourthDimensionAlgebraicCore

open Finset Complex

/-! ## The algebraic core -/

/-- The sum-of-squares identity that drives the four-dimensional constructions. -/
theorem sum_of_squares_core (a b : ℝ) : (a + b) ^ 2 = 4 * a * b + (a - b) ^ 2 := by
  ring

/-! ## The complex structure `J` on `ℝ⁴`

We model `ℝ⁴` as `ℝ × ℝ × ℝ × ℝ` and write the squared Euclidean norm explicitly.
The map `J` rotates each of the two coordinate planes by a quarter turn; it is the
canonical fixed-point-free isometry realizing "rotation through the fourth
dimension". -/

/-- Squared Euclidean norm on `ℝ⁴`. -/
def normSq4 (x : ℝ × ℝ × ℝ × ℝ) : ℝ :=
  x.1 ^ 2 + x.2.1 ^ 2 + x.2.2.1 ^ 2 + x.2.2.2 ^ 2

/-- The canonical complex structure on `ℝ⁴`: a quarter turn in each plane. -/
def J4 (x : ℝ × ℝ × ℝ × ℝ) : ℝ × ℝ × ℝ × ℝ :=
  (-x.2.1, x.1, -x.2.2.2, x.2.2.1)

/-- `J² = −I`: `J4` is a genuine complex structure. -/
theorem J4_sq_eq_neg (x : ℝ × ℝ × ℝ × ℝ) :
    J4 (J4 x) = (-x.1, -x.2.1, -x.2.2.1, -x.2.2.2) := by
  rfl

/-- `J4` preserves the Euclidean norm: it is a linear isometry. -/
theorem J4_preserves_normSq (x : ℝ × ℝ × ℝ × ℝ) : normSq4 (J4 x) = normSq4 x := by
  simp only [normSq4, J4]
  ring

/-- `J4` has no nonzero fixed point: `Jx = x` forces `x = 0`.  This is the concrete
form of the odd-dimensional eigenvalue obstruction — `J` has no eigenvalue `1`. -/
theorem J4_fixedPointFree (x : ℝ × ℝ × ℝ × ℝ) (h : J4 x = x) : x = (0, 0, 0, 0) := by
  obtain ⟨x1, x2, x3, x4⟩ := x
  simp only [J4, Prod.mk.injEq] at h
  obtain ⟨h1, h2, h3, h4⟩ := h
  -- h1 : -x2 = x1, h2 : x1 = x2, h3 : -x4 = x3, h4 : x3 = x4
  have hx1 : x1 = 0 := by linarith
  have hx2 : x2 = 0 := by linarith
  have hx3 : x3 = 0 := by linarith
  have hx4 : x4 = 0 := by linarith
  simp [hx1, hx2, hx3, hx4]

/-- On the unit sphere `J4` acts without fixed points. -/
theorem J4_noFixedPoint_onSphere (x : ℝ × ℝ × ℝ × ℝ) (hx : normSq4 x = 1) :
    J4 x ≠ x := by
  intro h
  have : x = (0, 0, 0, 0) := J4_fixedPointFree x h
  rw [this] at hx
  simp [normSq4] at hx

/-! ## The Hopf map

We realize `S³ ⊆ ℂ²` and send `(z,w)` to `(2 z \bar w, |z|² − |w|²) ∈ ℂ × ℝ`. -/

/-- The Hopf map from `ℂ²` to `ℂ × ℝ`. -/
def hopf (z w : ℂ) : ℂ × ℝ :=
  (2 * z * (starRingEnd ℂ) w, Complex.normSq z - Complex.normSq w)

/-- The Hopf map is constant on the diagonal circle orbits `(z,w) ↦ (λz, λw)` with
`|λ| = 1`: the Hopf fibres are exactly these circles. -/
theorem hopf_circle_invariant (z w l : ℂ) (hl : Complex.normSq l = 1) :
    hopf (l * z) (l * w) = hopf z w := by
  have hll : l * (starRingEnd ℂ) l = 1 := by
    rw [Complex.mul_conj]; exact_mod_cast hl
  refine Prod.ext ?_ ?_
  · simp only [hopf, map_mul]
    calc 2 * (l * z) * ((starRingEnd ℂ) l * (starRingEnd ℂ) w)
        = 2 * (l * (starRingEnd ℂ) l) * z * (starRingEnd ℂ) w := by ring
      _ = 2 * z * (starRingEnd ℂ) w := by rw [hll]; ring
  · simp only [hopf, Complex.normSq_mul, hl]; ring

/-- The Hopf image lies on the two-sphere of radius `|z|² + |w|²`.  This is a direct
instance of the sum-of-squares core identity with `a = |z|², b = |w|²`. -/
theorem hopf_image_on_sphere (z w : ℂ) :
    Complex.normSq (2 * z * (starRingEnd ℂ) w) + (Complex.normSq z - Complex.normSq w) ^ 2
      = (Complex.normSq z + Complex.normSq w) ^ 2 := by
  have h2 : Complex.normSq (2 : ℂ) = 4 := by simp [Complex.normSq]; norm_num
  simp only [Complex.normSq_mul, Complex.normSq_conj, h2]
  ring

/-! ## The Clifford torus balance

For the flat-torus embedding
`(θ,φ) ↦ (r₁cosθ, r₁sinθ, r₂cosφ, r₂sinφ)`
on `S³` the constraint is `r₁² + r₂² = 1`.  Writing `a = r₁², b = r₂²`, the area
element is proportional to `√(4ab)`, and the core identity gives
`4ab = 1 − (a − b)²`, maximal exactly at the balanced torus `a = b = ½`. -/

/-- The Clifford balance identity: on `a + b = 1` we have `4ab = 1 − (a − b)²`. -/
theorem clifford_balance (a b : ℝ) (h : a + b = 1) : 4 * a * b = 1 - (a - b) ^ 2 := by
  nlinarith [sum_of_squares_core a b, h]

/-- On the radius constraint the product `4 r₁² r₂²` never exceeds `1`. -/
theorem clifford_area_sq_le (a b : ℝ) (h : a + b = 1) : 4 * a * b ≤ 1 := by
  rw [clifford_balance a b h]
  nlinarith [sq_nonneg (a - b)]

/-- The Clifford torus is the unique balanced critical point: on `a + b = 1` the
area is extremal (`4ab = 1`) iff the radii are balanced (`a = b`). -/
theorem clifford_balanced_iff (a b : ℝ) (h : a + b = 1) :
    4 * a * b = 1 ↔ a = b := by
  rw [clifford_balance a b h]
  constructor
  · intro hh
    have : (a - b) ^ 2 = 0 := by linarith
    have := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp this
    linarith
  · intro hh
    rw [hh]; ring

/-! ## The alternating face sum of the `n`-cube -/

/-- The alternating face sum of the `n`-cube equals `1`: this is the binomial
theorem evaluated at `x = −1, y = 2`, and it is the Euler characteristic of the
(contractible) solid cube. -/
theorem cube_alternating_face_sum (n : ℕ) :
    ∑ k ∈ Finset.range (n + 1), ((-1 : ℤ)) ^ k * 2 ^ (n - k) * (n.choose k) = 1 := by
  have hbin := add_pow (-1 : ℤ) 2 n
  simp at hbin
  rw [← hbin]

/-- The Euler characteristic of the boundary of the `n`-cube is `1 − (−1)ⁿ`,
obtained from the full alternating face sum by deleting the single top-dimensional
(interior) cell. -/
theorem cube_boundary_euler (n : ℕ) :
    ∑ k ∈ Finset.range n, ((-1 : ℤ)) ^ k * 2 ^ (n - k) * (n.choose k) = 1 - (-1) ^ n := by
  have hfull := cube_alternating_face_sum n
  rw [Finset.sum_range_succ] at hfull
  simp only [Nat.sub_self, pow_zero, Nat.choose_self, Nat.cast_one, mul_one] at hfull
  linarith [hfull]

/-! ## Four-ball volume and three-sphere surface area

The four-ball of radius `r` has volume `(π²/2) r⁴`, and its boundary three-sphere
has surface measure `2π² r³`.  These are not independent: differentiating the
volume in the radius returns exactly the surface measure — the four-dimensional
instance of the "onion" (coarea) relation `dV/dr = area(∂B)`. -/

/-- The four-ball volume as a function of the radius. -/
noncomputable def ball4Volume (r : ℝ) : ℝ := (Real.pi ^ 2 / 2) * r ^ 4

/-- The three-sphere surface measure as a function of the radius. -/
noncomputable def sphere3Area (r : ℝ) : ℝ := 2 * Real.pi ^ 2 * r ^ 3

/-- The derivative of the four-ball volume is the three-sphere surface measure. -/
theorem hasDerivAt_ball4_volume (r : ℝ) :
    HasDerivAt ball4Volume (sphere3Area r) r := by
  have hpow : HasDerivAt (fun r : ℝ => r ^ 4) (4 * r ^ 3) r := by
    simpa using hasDerivAt_pow 4 r
  have h := hpow.const_mul (Real.pi ^ 2 / 2)
  unfold ball4Volume sphere3Area
  convert h using 1
  ring

/-- The volume constant `π²/2` is scale-covariant of degree four. -/
theorem ball4Volume_scale (t r : ℝ) : ball4Volume (t * r) = t ^ 4 * ball4Volume r := by
  unfold ball4Volume; ring

/-! ## Examples, generalizations, and boundaries (PEGB) -/

-- Examples: concrete instantiations of the definitions and theorems.
example : normSq4 (1, 0, 0, 0) = 1 := by simp [normSq4]
example : J4 (1, 0, 0, 0) = (0, 1, 0, 0) := by simp [J4]
example : J4 (J4 (1, 2, 3, 4)) = (-1, -2, -3, -4) := by rfl
#check @hopf_circle_invariant
#check @clifford_balanced_iff
#check @hasDerivAt_ball4_volume
#eval (List.range 6).map (fun n =>
  (∑ k ∈ Finset.range n, ((-1 : ℤ)) ^ k * 2 ^ (n - k) * (n.choose k)))
-- boundary Euler characteristics 1 - (-1)^n for n = 0..5 : [0, 2, 0, 2, 0, 2]

/-
### Generalization
`J4` is the `n = 2` instance of the block-diagonal complex structure on `ℝ^{2n}`
that pairs coordinates and rotates each pair by a quarter turn; `J4_sq_eq_neg`,
`J4_preserves_normSq`, and `J4_fixedPointFree` all extend block-by-block, giving
the fixed-point-free isometry on every odd sphere `S^{2n-1}`.  The Clifford
balance extends to the `(r₁,…,r_m)`-family on `S^{2m-1}` with the balanced point
`r_i² = 1/m` as the symmetric critical point.

### Boundary / limit cases
The Clifford result is sharp: dropping the constraint `a + b = 1` breaks
`clifford_area_sq_le` (take `a = b = 1`, then `4ab = 4 > 1`).  The fixed-point
freeness is genuinely odd-dimensional: on `ℝ²` (the `n = 1` block) the same `J`
still has no real eigenvalue, but the *even*-dimensional obstruction fails for a
single real coordinate, where every isometry `±1` has a fixed axis.  The boundary
Euler characteristic alternates `0, 2, 0, 2, …`, vanishing for odd `n` (odd
spheres are boundaries of even-dimensional cells with `χ = 0`).
-/

end Geometry.FourthDimensionAlgebraicCore