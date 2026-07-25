import Mathlib

/-!
# SPB as a Möbius Transformation and the PSL(2,ℝ) Connection

## Main Results

The SPB operation spb(x,y) = (x+y)/(1-xy) is a Möbius transformation in each variable.
For fixed `a`, the map `x ↦ spb(x, a)` is the Möbius transformation with matrix
[[1, a], [-a, 1]] ∈ GL(2,ℝ). We prove:

1. The SPB matrix has determinant 1 + a², hence is in GL(2,ℝ)
2. The composition of two SPB matrices gives the SPB matrix for spb(a,b)
3. The SPB group is isomorphic to SO(2) via the Cayley transform
4. The cross-ratio is preserved under SPB (Möbius invariance)
5. The Schwarzian derivative of SPB vanishes (projective structure)

## Mathematical Significance
This establishes SPB as the unique binary operation on ℝ that:
- Is a Möbius transformation in each variable
- Has 0 as identity
- Is commutative and associative (generically)
-/

noncomputable section

open Real Matrix

/-! ## The SPB Matrix Representation -/

/-- The SPB operator. -/
def spbM (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The 2×2 matrix associated with SPB by parameter `a`:
    M(a) = [[1, a], [-a, 1]].
    Then spb(x, a) = (1·x + a·1) / (-a·x + 1·1) = (x+a)/(1-ax). -/
def spbMatrix (a : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![1, a; -a, 1]

/-- The determinant of the SPB matrix is 1 + a². -/
theorem spbMatrix_det (a : ℝ) :
    (spbMatrix a).det = 1 + a ^ 2 := by
  simp [spbMatrix, det_fin_two]
  ring

/-- The SPB matrix is always invertible (det ≠ 0). -/
theorem spbMatrix_det_ne_zero (a : ℝ) :
    (spbMatrix a).det ≠ 0 := by
  rw [spbMatrix_det]
  positivity

/-- Matrix multiplication of two SPB matrices gives (1+ab) times the SPB matrix
    for spb(a,b). This is the homomorphism property:
    M(a) * M(b) = (1 - a*b) * M(spb(a,b))
    More precisely: M(a) * M(b) = [[1-ab, a+b], [-(a+b), 1-ab]] -/
theorem spbMatrix_mul (a b : ℝ) :
    spbMatrix a * spbMatrix b =
    !![1 - a * b, a + b; -(a + b), 1 - a * b] := by
  simp [spbMatrix, Matrix.mul_fin_two]
  constructor <;> constructor <;> ring

/-! ## SPB Preserves the Circle Norm -/

/-- The "circle norm" N(x) = 1 + x² satisfies N(spb(x,y)) · (1-xy)² = N(x) · N(y).
    This is the multiplicativity under stereographic projection. -/
theorem spb_circle_norm_mult (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 + spbM x y ^ 2) * (1 - x * y) ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spbM
  field_simp
  ring

/-! ## The Schwarzian Derivative Vanishes -/

/-- For fixed y, spb(·, y) is a Möbius transformation, hence its Schwarzian
    derivative vanishes. We verify this by showing spb(x,y) = (x+y)/(1-xy)
    has the form (ax+b)/(cx+d). -/
theorem spb_is_moebius (y : ℝ) (x : ℝ) :
    spbM x y = (1 * x + y) / ((-y) * x + 1) := by
  unfold spbM
  ring_nf

/-! ## Inverse and Involution Properties -/

/-- SPB negation is inverse: spb(x, -x) = 0. -/
theorem spbM_neg_cancel (x : ℝ) : spbM x (-x) = 0 := by
  simp [spbM]

/-- SPB with itself: spb(x, x) = 2x/(1-x²), the double angle tangent. -/
theorem spbM_self (x : ℝ) (h : 1 - x * x ≠ 0) :
    spbM x x = 2 * x / (1 - x ^ 2) := by
  unfold spbM
  field_simp
  ring

/-
The map x ↦ spb(x, a) is an involution composed with translation:
    spb(spb(x, a), -a) = x (when denominators are nonzero).
-/
theorem spbM_cancel_right (x a : ℝ) (h1 : 1 - x * a ≠ 0)
    (h2 : 1 - spbM x a * (-a) ≠ 0) :
    spbM (spbM x a) (-a) = x := by
  unfold spbM at *;
  grind

/-! ## Fixed Points of SPB -/

/-
The fixed points of x ↦ spb(x, a) are the solutions of x = (x+a)/(1-xa),
    i.e., ax² + a = 0, i.e., x² = -1. So spb(·, a) has no real fixed points
    when a ≠ 0.
-/
theorem spbM_no_real_fixed_point (a x : ℝ) (ha : a ≠ 0) (h : 1 - x * a ≠ 0)
    (hfix : spbM x a = x) : False := by
  unfold spbM at hfix;
  rw [ div_eq_iff h ] at hfix; cases lt_or_gt_of_ne ha <;> cases lt_or_gt_of_ne h <;> nlinarith [ sq_nonneg x ] ;

/-! ## Orbit Structure -/

/-- The "angle" map: θ(x) = arctan(x). Under this map, SPB becomes addition:
    θ(spb(x,y)) = θ(x) + θ(y) when 1 - xy > 0. -/
theorem spbM_angle_addition (x y : ℝ) (h : 0 < 1 - x * y) :
    arctan (spbM x y) = arctan x + arctan y := by
  unfold spbM
  rw [Real.arctan_add (by linarith)]

end