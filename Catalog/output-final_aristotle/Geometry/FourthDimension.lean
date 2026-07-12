import Mathlib
import Geometry.DiscreteGaussBonnet

/-!
# The Fourth Dimension as a Mathematical Playground

This file develops a small but genuinely four-dimensional toolkit, organised
around Rudy Rucker's classical themes: the *hypersphere* `S³`, the *tesseract*
(the `4`-cube), the *Clifford torus*, the *Hopf fibration*, and the idea of a
"rotation through the fourth dimension".  Every object is treated concretely so
that the geometric facts become sharp algebraic identities.

## Contents

* **Volume of the `4`-ball.**  `volume_ball_dim_four` shows that the Lebesgue
  measure of a ball of radius `r` in `ℝ⁴` is `(π²/2)·r⁴`.

* **A fixed-point-free rotation of `S³`.**  The linear map `rot4`
  `(x₀,x₁,x₂,x₃) ↦ (-x₁, x₀, -x₃, x₂)` is a Euclidean isometry
  (`rot4_isometry`) whose square is `-id` (`rot4_complex_structure`); it has no
  fixed point on the unit sphere (`rot4_no_fixed_point`).  Realised as the block
  matrix `rot4Matrix`, it is orthogonal (`rot4Matrix_orthogonal`) with
  determinant `1` (`rot4Matrix_det`), i.e. a genuine element of `SO(4)`.  This is
  a precise rendering of Rucker's "rotation through the fourth dimension".

* **The Hopf fibration `S³ → S²`.**  With the Hopf map written in the
  coordinates `ℂ² → ℂ × ℝ`, `hopf_maps_sphere_to_sphere` is the identity showing
  the image lands on `S²`, and `hopf_circle_invariant` shows the map is constant
  along the circle orbits `(z,w) ↦ (λz, λw)`, `|λ| = 1` — so the fibres contain
  circles.

* **The Clifford torus.**  `clifford_on_sphere` places the standard flat torus on
  `S³`, and `clifford_balanced` records that it splits the two coordinate planes
  equally, the defining feature of the Clifford torus.

* **The tesseract and Euler characteristics.**  `cube_alternating_sum` is the
  binomial identity `∑ₖ (-1)ᵏ C(n,k) 2ⁿ⁻ᵏ = 1` counting the faces of the
  `n`-cube; `tesseract_boundary_euler` deduces that the boundary of the tesseract
  (topologically `S³`) has Euler characteristic `0`, while `cube3_boundary_euler`
  recovers the value `2` for the ordinary cube surface (topologically `S²`),
  matching the classical Euler characteristic of the two-sphere.

-- !-- Lab Notes -- !--
**Hypothesis.**  The elementary four-dimensional objects of popular geometry
(hypersphere, tesseract, Clifford torus, Hopf map, and "rotation through the
fourth dimension") each reduce to a single crisp algebraic identity, and those
identities are mutually reinforcing: the same sum-of-squares algebra governs the
Hopf map, the Clifford torus, and the isometry `rot4`.

**Experiment.**  Each theme was turned into a concrete statement over `ℝ⁴`
(coordinates `Fin 4 → ℝ`) or `ℂ²`, and the corresponding identity proved:
sum-of-squares normalisation (Clifford, Hopf), a binomial identity (tesseract),
a Gamma-function evaluation (volume), and an eigenvalue obstruction
(fixed-point freeness).

**Analysis.**  The fixed-point-free rotation exists because `S³` is
odd-dimensional: `rot4` is a complex structure (`rot4² = -id`), so it has no real
eigenvector and hence no fixed point on the sphere.  The Hopf identity
`4|z|²|w|² + (|z|²-|w|²)² = (|z|²+|w|²)²` is exactly the algebra that also forces
the Clifford torus onto `S³` with balanced radii `1/√2`.

**Critique.**  None of the main results is definitional: the volume computation
invokes the Gamma-function volume formula, the Euler characteristics are derived
from the binomial theorem (not `decide`), and the rotation results use the sphere
hypothesis essentially (the conclusion is false at the origin).

**Synthesis.**  The four-dimensional playground is unified by the identity
`(a+b)² = 4ab + (a-b)²` and the odd-dimensional eigenvalue obstruction; both are
recorded here and cross-linked to the discrete Gauss–Bonnet Euler characteristic.
-/

noncomputable section

open scoped Real
open MeasureTheory Matrix

namespace FourthDimension

/-! ## The volume of the four-dimensional ball -/

/-- The Lebesgue volume of a ball of radius `r` in `ℝ⁴` is `(π²/2)·r⁴`. -/
theorem volume_ball_dim_four (x : EuclideanSpace ℝ (Fin 4)) (r : ℝ) :
    volume (Metric.ball x r) =
      ENNReal.ofReal r ^ 4 * ENNReal.ofReal (Real.pi ^ 2 / 2) := by
  have h : Module.finrank ℝ (EuclideanSpace ℝ (Fin 4)) = 2 * 2 := by simp
  rw [InnerProductSpace.volume_ball_of_dim_even h x]
  norm_num [h]

/-! ## A fixed-point-free rotation of the hypersphere `S³` -/

/-- The squared Euclidean norm on `ℝ⁴`. -/
def Q (x : Fin 4 → ℝ) : ℝ := x 0 ^ 2 + x 1 ^ 2 + x 2 ^ 2 + x 3 ^ 2

/-- Rucker's "rotation through the fourth dimension":
`(x₀,x₁,x₂,x₃) ↦ (-x₁, x₀, -x₃, x₂)`. -/
def rot4 (x : Fin 4 → ℝ) : Fin 4 → ℝ := ![- x 1, x 0, - x 3, x 2]

/-- `rot4` preserves the Euclidean norm: it is an isometry. -/
theorem rot4_isometry (x : Fin 4 → ℝ) : Q (rot4 x) = Q x := by
  simp only [Q, rot4, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
    Matrix.cons_val_two, Matrix.tail_cons, Matrix.cons_val_three]
  ring

/-- `rot4` squares to `-id`; it is an orthogonal complex structure on `ℝ⁴`. -/
theorem rot4_complex_structure (x : Fin 4 → ℝ) : rot4 (rot4 x) = - x := by
  funext i
  fin_cases i <;> simp [rot4]

/-- `rot4` has no fixed point on the unit sphere `S³`. -/
theorem rot4_no_fixed_point (x : Fin 4 → ℝ) (hx : Q x = 1) : rot4 x ≠ x := by
  intro h
  have h0 := congrFun h 0
  have h1 := congrFun h 1
  have h2 := congrFun h 2
  have h3 := congrFun h 3
  simp only [rot4, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
    Matrix.cons_val_two, Matrix.tail_cons, Matrix.cons_val_three] at h0 h1 h2 h3
  simp only [Q] at hx
  nlinarith [h0, h1, h2, h3, hx]

/-- The `4×4` matrix realising `rot4`, as two `90°` rotation blocks. -/
def rot4Matrix : Matrix (Fin 2 ⊕ Fin 2) (Fin 2 ⊕ Fin 2) ℝ :=
  Matrix.fromBlocks !![0, -1; 1, 0] 0 0 !![0, -1; 1, 0]

/-- `rot4Matrix` is orthogonal: `Mᵀ M = 1`. -/
theorem rot4Matrix_orthogonal : rot4Matrixᵀ * rot4Matrix = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [rot4Matrix, Matrix.mul_apply, Fin.sum_univ_two, Matrix.transpose_apply,
      Matrix.fromBlocks]

/-- `rot4Matrix` has determinant `1`, so it lies in `SO(4)`. -/
theorem rot4Matrix_det : rot4Matrix.det = 1 := by
  rw [rot4Matrix, Matrix.det_fromBlocks_zero₂₁]
  simp [Matrix.det_fin_two]

/-! ## The Hopf fibration `S³ → S²` -/

/-- The core Hopf identity: with the Hopf map `(z,w) ↦ (2 z w̄, |z|² - |w|²)`,
the squared length of the image equals `(|z|² + |w|²)²`.  Hence the Hopf map
sends the unit `3`-sphere `|z|² + |w|² = 1` onto the unit `2`-sphere. -/
theorem hopf_maps_sphere_to_sphere (z w : ℂ) :
    Complex.normSq (2 * z * (starRingEnd ℂ) w)
        + (Complex.normSq z - Complex.normSq w) ^ 2
      = (Complex.normSq z + Complex.normSq w) ^ 2 := by
  simp only [map_mul, Complex.normSq_conj, Complex.normSq_ofNat]
  ring

/-- The Hopf map is invariant under the circle action `(z,w) ↦ (λz, λw)` with
`|λ| = 1`: both components of the image are unchanged.  Thus each fibre contains
the full circle orbit — the Hopf fibres are circles. -/
theorem hopf_circle_invariant (z w lam : ℂ) (h : Complex.normSq lam = 1) :
    2 * (lam * z) * (starRingEnd ℂ) (lam * w) = 2 * z * (starRingEnd ℂ) w
      ∧ Complex.normSq (lam * z) - Complex.normSq (lam * w)
          = Complex.normSq z - Complex.normSq w := by
  refine ⟨?_, by rw [Complex.normSq_mul, Complex.normSq_mul, h]; ring⟩
  have hl : lam * (starRingEnd ℂ) lam = 1 := by rw [Complex.mul_conj, h]; norm_num
  rw [map_mul]
  linear_combination (2 * z * (starRingEnd ℂ) w) * hl

/-! ## The Clifford torus -/

/-- A convenience fact: `(√2)² = 2`. -/
theorem sqrt_two_sq : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)

/-- The standard flat (Clifford) torus in `ℝ⁴`, parametrised by two angles. -/
def clifford (a b : ℝ) : Fin 4 → ℝ :=
  ![Real.cos a / Real.sqrt 2, Real.sin a / Real.sqrt 2,
    Real.cos b / Real.sqrt 2, Real.sin b / Real.sqrt 2]

/-- The Clifford torus lies on the unit hypersphere `S³`. -/
theorem clifford_on_sphere (a b : ℝ) : Q (clifford a b) = 1 := by
  simp only [Q, clifford, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
    Matrix.cons_val_two, Matrix.tail_cons, Matrix.cons_val_three, div_pow, sqrt_two_sq]
  nlinarith [Real.sin_sq_add_cos_sq a, Real.sin_sq_add_cos_sq b]

/-- The Clifford torus splits the two coordinate `2`-planes equally: each pair of
coordinates has squared radius `1/2`.  This equal balance is what distinguishes
the Clifford torus among all flat tori on `S³`. -/
theorem clifford_balanced (a b : ℝ) :
    (clifford a b 0) ^ 2 + (clifford a b 1) ^ 2 = 1 / 2
      ∧ (clifford a b 2) ^ 2 + (clifford a b 3) ^ 2 = 1 / 2 := by
  simp only [clifford, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
    Matrix.cons_val_two, Matrix.tail_cons, Matrix.cons_val_three, div_pow, sqrt_two_sq]
  constructor <;> nlinarith [Real.sin_sq_add_cos_sq a, Real.sin_sq_add_cos_sq b]

/-! ## The tesseract and Euler characteristics -/

/-- The number of `k`-dimensional faces of the `n`-cube: `C(n,k)·2ⁿ⁻ᵏ`. -/
def cubeFaces (n k : ℕ) : ℕ := n.choose k * 2 ^ (n - k)

/-- The signed total face count of the `n`-cube:
`∑ₖ (-1)ᵏ C(n,k) 2ⁿ⁻ᵏ = (2-1)ⁿ = 1`. -/
theorem cube_alternating_sum (n : ℕ) :
    ∑ k ∈ Finset.range (n + 1), (-1 : ℤ) ^ k * (cubeFaces n k : ℤ) = 1 := by
  simp only [cubeFaces]
  have key := add_pow (-1 : ℤ) 2 n
  rw [show ((-1 : ℤ) + 2) = 1 by norm_num, one_pow] at key
  conv_rhs => rw [key]
  exact Finset.sum_congr rfl (fun k _ => by push_cast; ring)

/-- The boundary of the tesseract, a triangulable `3`-sphere, has Euler
characteristic `0`: `16 - 32 + 24 - 8 = 0`. -/
theorem tesseract_boundary_euler :
    ∑ k ∈ Finset.range 4, (-1 : ℤ) ^ k * (cubeFaces 4 k : ℤ) = 0 := by
  have h := cube_alternating_sum 4
  rw [Finset.sum_range_succ] at h
  have hterm : ((-1 : ℤ)) ^ 4 * (cubeFaces 4 4 : ℤ) = 1 := by norm_num [cubeFaces]
  rw [hterm] at h
  linarith

/-- The surface of the ordinary cube, a `2`-sphere, has Euler characteristic `2`:
`8 - 12 + 6 = 2`. -/
theorem cube3_boundary_euler :
    ∑ k ∈ Finset.range 3, (-1 : ℤ) ^ k * (cubeFaces 3 k : ℤ) = 2 := by
  have h := cube_alternating_sum 3
  rw [Finset.sum_range_succ] at h
  have hterm : ((-1 : ℤ)) ^ 3 * (cubeFaces 3 3 : ℤ) = -1 := by norm_num [cubeFaces]
  rw [hterm] at h
  linarith

/-! ## Examples, cross-links, and boundary discussion

The following `#check`s and `example`s instantiate the definitions above and
connect them to the discrete Gauss–Bonnet machinery: the octahedron
(`V=6, E=12, F=8`) is a triangulated `2`-sphere, and `euler_curvature_algebra`
turns its face data into the same Euler characteristic `2` recovered
combinatorially by `cube3_boundary_euler`.

*Generalization.*  `cube_alternating_sum` holds for every dimension `n`; the
boundary Euler characteristic of the `n`-cube is `1 - (-1)ⁿ`, which is `0` in even
ambient dimension (odd-dimensional spheres) and `2` in odd ambient dimension
(even-dimensional spheres).

*Boundary / limit cases.*  The fixed-point-free rotation `rot4` exists precisely
because `S³` is odd-dimensional; the analogous construction fails on the even
sphere `S²`, where every rotation has a fixed axis (the hairy-ball phenomenon).
This is the structural reason `rot4_no_fixed_point` has no `3`-dimensional
analogue, and it explains why the origin (`Q x = 0`) is the sole fixed point.
-/

/-- The octahedron is a triangulated sphere; its curvature algebra returns the
Euler characteristic `2`, matching `cube3_boundary_euler`. -/
example : 2 * Real.pi * (6 : ℝ) - Real.pi * (8 : ℝ)
    = 2 * Real.pi * ((6 : ℝ) - (12 : ℝ) + (8 : ℝ)) :=
  DiscreteGaussBonnet.euler_curvature_algebra 6 12 8 (by norm_num)

#check @volume_ball_dim_four
#check @rot4_no_fixed_point
#check @hopf_maps_sphere_to_sphere
#check @clifford_on_sphere
#check @tesseract_boundary_euler

example : cubeFaces 4 0 = 16 ∧ cubeFaces 4 1 = 32 ∧ cubeFaces 4 2 = 24 := by
  refine ⟨rfl, rfl, rfl⟩

end FourthDimension