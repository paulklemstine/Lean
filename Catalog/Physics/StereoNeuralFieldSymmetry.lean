import Mathlib
import Physics.StereoNeuralFieldCalculus
import Physics.StereoNeuralFieldHarmonics

/-!
# Stereographic neural fields IV: rotational variants, `N`-fold symmetry, Kelvin duality

The conjecture behind this development has three geometric clauses beyond the mode count:

1. the `2l+1` patterns of degree `l` are *rotational variants* of one another;
2. under inverse stereographic projection the sectoral patterns are *`N`-fold symmetric*
   patterns of the plane;
3. they *decay at infinity*.

This file proves precise versions of all three for the explicitly constructed patterns.

* `chartX_rot`, `chartY_rot`, `chartZ_rot`: the plane rotation of angle `θ` is conjugated by
  the chart to the rotation of `S²` about the polar axis; the degree-one pattern space is
  therefore an `SO(2)`-invariant three-dimensional space on which the rotation acts by the
  standard two-dimensional representation plus a trivial summand.  This is the concrete
  mechanism producing "rotational variants".
* `chartX_onefold`, `H2x2y2_twofold`, `H3a_threefold`, `H3b_threefold`: the sectoral pattern
  of degree `N` is invariant under the plane rotation of angle `2π/N` (for `N = 2, 3`,
  proved by exact algebra with `√3`), while the degree-one sectoral pattern is *odd* under
  the half-turn — its symmetry group is exactly one-fold.  This confirms clause 2 and pins
  the boundary case `N = 1`.
* `H3a_ray_decay`, `H2x2y2_ray_decay`: the sectoral patterns decay at infinity at the sharp
  polynomial rates `O(R^{-3})` and `O(R^{-2})`, confirming clause 3 *for the sectoral modes*
  (recall from `Physics.StereoNeuralFieldSelection` that the zonal modes do **not** decay).
* `kelvin_chartZ`: Kelvin inversion `p ↦ p/|p|²` of the plane is conjugated by the chart to
  the equatorial reflection `z ↦ -z` of the sphere, while fixing the two horizontal
  coordinates.  Hence the pattern space carries a second, discrete symmetry that pairs
  patterns of opposite polar parity.
-/

namespace StereoNeuralField

noncomputable section

open NExpr

/-! ## Plane rotations are polar rotations of the sphere -/

theorem W_rot {c s : ℝ} (hcs : c ^ 2 + s ^ 2 = 1) (x y : ℝ) :
    W (c * x - s * y) (s * x + c * y) = W x y := by
  unfold W
  congr 1
  nlinarith [hcs]

theorem chartX_rot {c s : ℝ} (hcs : c ^ 2 + s ^ 2 = 1) (x y : ℝ) :
    evalAt chartX (c * x - s * y) (s * x + c * y)
      = c * evalAt chartX x y - s * evalAt chartY x y := by
  simp only [evalAt_chartX, evalAt_chartY, W_rot hcs]
  ring

theorem chartY_rot {c s : ℝ} (hcs : c ^ 2 + s ^ 2 = 1) (x y : ℝ) :
    evalAt chartY (c * x - s * y) (s * x + c * y)
      = s * evalAt chartX x y + c * evalAt chartY x y := by
  simp only [evalAt_chartX, evalAt_chartY, W_rot hcs]
  ring

theorem chartZ_rot {c s : ℝ} (hcs : c ^ 2 + s ^ 2 = 1) (x y : ℝ) :
    evalAt chartZ (c * x - s * y) (s * x + c * y) = evalAt chartZ x y := by
  simp only [evalAt_chartZ, W_rot hcs]
  have h : (c * x - s * y) ^ 2 + (s * x + c * y) ^ 2 = x ^ 2 + y ^ 2 := by nlinarith [hcs]
  rw [h]

/-! ## Sectoral patterns and their exact rotational symmetry -/

/-- The degree-one sectoral pattern is **odd** under the half-turn: its symmetry group is
one-fold, exactly as predicted for `N = 1`. -/
theorem chartX_onefold (x y : ℝ) :
    evalAt chartX (-x) (-y) = -evalAt chartX x y := by
  simp only [evalAt_chartX, W]
  have h : 1 + (-x) ^ 2 + (-y) ^ 2 = 1 + x ^ 2 + y ^ 2 := by ring
  rw [h]
  ring

/-- The degree-two sectoral pattern `x²-y²` is invariant under the half-turn: two-fold
symmetry. -/
theorem H2x2y2_twofold (x y : ℝ) :
    evalAt H2x2y2 (-x) (-y) = evalAt H2x2y2 x y := by
  have hcs : ((-1 : ℝ)) ^ 2 + (0 : ℝ) ^ 2 = 1 := by norm_num
  have hx := chartX_rot hcs x y
  have hy := chartY_rot hcs x y
  have hx' : (-1 : ℝ) * x - 0 * y = -x := by ring
  have hy' : (0 : ℝ) * x + (-1 : ℝ) * y = -y := by ring
  rw [hx', hy'] at hx hy
  simp only [H2x2y2, evalAt_sub, evalAt_mul, hx, hy]
  ring

/-- Exact algebraic identity behind three-fold symmetry: the real part of a cube is
invariant under multiplication by a primitive cube root of unity. -/
theorem cubic_real_rot_invariant (A B t : ℝ) (ht : t ^ 2 = 3) :
    (-(1 / 2) * A - (t / 2) * B) ^ 3 - 3 * ((-(1 / 2) * A - (t / 2) * B) * ((t / 2) * A + (-(1 / 2)) * B) ^ 2)
      = A ^ 3 - 3 * (A * B ^ 2) := by
  linear_combination ((3 * A ^ 3 + 3 * t * A ^ 2 * B - 9 * A * B ^ 2 - t * B ^ 3) / 8) * ht

/-- Exact algebraic identity behind three-fold symmetry, imaginary part. -/
theorem cubic_imag_rot_invariant (A B t : ℝ) (ht : t ^ 2 = 3) :
    3 * ((t / 2 * A + (-(1 / 2)) * B) * (-(1 / 2) * A - (t / 2) * B) ^ 2)
        - ((t / 2) * A + (-(1 / 2)) * B) ^ 3
      = 3 * (B * A ^ 2) - B ^ 3 := by
  linear_combination ((-(t * A ^ 3) + 9 * A ^ 2 * B + 3 * t * A * B ^ 2 - 3 * B ^ 3) / 8) * ht

theorem sqrt_three_sq : (Real.sqrt 3) ^ 2 = 3 := Real.sq_sqrt (by norm_num)

theorem rot_third_unit : ((-(1 : ℝ) / 2)) ^ 2 + (Real.sqrt 3 / 2) ^ 2 = 1 := by
  have h := sqrt_three_sq
  nlinarith [h]

/-- **Three-fold symmetry.**  The degree-three sectoral pattern `x(x²-3y²)`, pulled back
through the chart, is invariant under the plane rotation of angle `2π/3`. -/
theorem H3a_threefold (x y : ℝ) :
    evalAt H3a ((-(1 : ℝ) / 2) * x - (Real.sqrt 3 / 2) * y)
        ((Real.sqrt 3 / 2) * x + (-(1 : ℝ) / 2) * y)
      = evalAt H3a x y := by
  have hcs := rot_third_unit
  have hx := chartX_rot hcs x y
  have hy := chartY_rot hcs x y
  simp only [H3a, evalAt_sub, evalAt_mul, evalAt_const, hx, hy]
  have h := cubic_real_rot_invariant (evalAt chartX x y) (evalAt chartY x y) (Real.sqrt 3)
    sqrt_three_sq
  linear_combination h

/-- **Three-fold symmetry**, second sectoral pattern `y(3x²-y²)`. -/
theorem H3b_threefold (x y : ℝ) :
    evalAt H3b ((-(1 : ℝ) / 2) * x - (Real.sqrt 3 / 2) * y)
        ((Real.sqrt 3 / 2) * x + (-(1 : ℝ) / 2) * y)
      = evalAt H3b x y := by
  have hcs := rot_third_unit
  have hx := chartX_rot hcs x y
  have hy := chartY_rot hcs x y
  simp only [H3b, evalAt_sub, evalAt_mul, evalAt_const, hx, hy]
  have h := cubic_imag_rot_invariant (evalAt chartX x y) (evalAt chartY x y) (Real.sqrt 3)
    sqrt_three_sq
  linear_combination h

/-! ## Decay of the sectoral patterns -/

theorem chart_ray_bound (u v R : ℝ) (huv : u ^ 2 + v ^ 2 = 1) (hR : 0 < R) :
    |evalAt chartX (R * u) (R * v)| ≤ 2 / R ∧ |evalAt chartY (R * u) (R * v)| ≤ 2 / R := by
  have hden : 1 + (R * u) ^ 2 + (R * v) ^ 2 = 1 + R ^ 2 := by nlinarith [huv]
  have hpos : (0 : ℝ) < 1 + R ^ 2 := by positivity
  have hu : |u| ≤ 1 := by nlinarith [abs_nonneg u, sq_abs u, sq_nonneg v]
  have hv : |v| ≤ 1 := by nlinarith [abs_nonneg v, sq_abs v, sq_nonneg u]
  have habs : ∀ w : ℝ, |2 * (R * w) * (1 + R ^ 2)⁻¹| = 2 * R * |w| / (1 + R ^ 2) := by
    intro w
    rw [abs_mul, abs_mul, abs_inv, abs_of_pos hpos, abs_mul, abs_of_pos hR,
      abs_of_nonneg (by norm_num : (0:ℝ) ≤ 2), div_eq_mul_inv]
    ring
  have hmain : ∀ w : ℝ, |w| ≤ 1 → 2 * R * |w| / (1 + R ^ 2) ≤ 2 / R := by
    intro w hw
    have h2 : 2 * R / (1 + R ^ 2) ≤ 2 / R := by
      rw [div_le_div_iff₀ hpos hR]; nlinarith
    have h1 : 2 * R * |w| ≤ 2 * R := by nlinarith [abs_nonneg w, hR.le]
    calc 2 * R * |w| / (1 + R ^ 2) ≤ 2 * R / (1 + R ^ 2) := by gcongr
      _ ≤ 2 / R := h2
  constructor
  · simp only [evalAt_chartX, W, hden]
    rw [habs u]
    exact hmain u hu
  · simp only [evalAt_chartY, W, hden]
    rw [habs v]
    exact hmain v hv

theorem sectoral_cube_bound {a b k : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b) (hk : 0 ≤ k)
    (hak : a ≤ k) (hbk : b ≤ k) : a ^ 3 + 3 * (a * b ^ 2) ≤ 4 * k ^ 3 := by
  nlinarith [sq_nonneg (k - a), sq_nonneg (k - b), mul_nonneg ha hb, sq_nonneg a, sq_nonneg b]

/-- **Decay of the three-fold pattern.**  Along every ray the degree-three sectoral pattern
decays like `R⁻³`. -/
theorem H3a_ray_decay (u v R : ℝ) (huv : u ^ 2 + v ^ 2 = 1) (hR : 0 < R) :
    |evalAt H3a (R * u) (R * v)| ≤ 32 / R ^ 3 := by
  obtain ⟨hx, hy⟩ := chart_ray_bound u v R huv hR
  set A := evalAt chartX (R * u) (R * v) with hA
  set B := evalAt chartY (R * u) (R * v) with hB
  have hval : evalAt H3a (R * u) (R * v) = A ^ 3 - 3 * (A * B ^ 2) := by
    simp only [H3a, evalAt_sub, evalAt_mul, evalAt_const, hA, hB]
    ring
  rw [hval]
  have h1 : |A ^ 3 - 3 * (A * B ^ 2)| ≤ |A ^ 3| + |3 * (A * B ^ 2)| := abs_sub _ _
  have h2 : |A ^ 3| = |A| ^ 3 := by rw [abs_pow]
  have h3 : |3 * (A * B ^ 2)| = 3 * (|A| * |B| ^ 2) := by
    rw [abs_mul, abs_mul, abs_pow]
    norm_num
  have h4 : |A| ^ 3 + 3 * (|A| * |B| ^ 2) ≤ 4 * (2 / R) ^ 3 :=
    sectoral_cube_bound (abs_nonneg A) (abs_nonneg B) (by positivity) hx hy
  have h5 : 4 * (2 / R) ^ 3 = 32 / R ^ 3 := by
    field_simp; norm_num
  rw [h2, h3] at h1
  linarith

/-- **Decay of the two-fold pattern.**  Along every ray the degree-two sectoral pattern
decays like `R⁻²`. -/
theorem H2x2y2_ray_decay (u v R : ℝ) (huv : u ^ 2 + v ^ 2 = 1) (hR : 0 < R) :
    |evalAt H2x2y2 (R * u) (R * v)| ≤ 8 / R ^ 2 := by
  obtain ⟨hx, hy⟩ := chart_ray_bound u v R huv hR
  set A := evalAt chartX (R * u) (R * v) with hA
  set B := evalAt chartY (R * u) (R * v) with hB
  have hval : evalAt H2x2y2 (R * u) (R * v) = A ^ 2 - B ^ 2 := by
    simp only [H2x2y2, evalAt_sub, evalAt_mul, hA, hB]
    ring
  rw [hval]
  have h1 : |A ^ 2 - B ^ 2| ≤ |A ^ 2| + |B ^ 2| := abs_sub _ _
  have h2 : |A ^ 2| = |A| ^ 2 := by rw [abs_pow]
  have h3 : |B ^ 2| = |B| ^ 2 := by rw [abs_pow]
  have h4 : |A| ^ 2 + |B| ^ 2 ≤ 2 * (2 / R) ^ 2 := by
    nlinarith [abs_nonneg A, abs_nonneg B, hx, hy, div_nonneg (by norm_num : (0:ℝ) ≤ 2) hR.le]
  have h5 : 2 * (2 / R) ^ 2 = 8 / R ^ 2 := by field_simp; ring
  rw [h2, h3] at h1
  linarith

/-! ## Kelvin inversion is the equatorial reflection -/

/-- Kelvin inversion fixes the first chart coordinate. -/
theorem kelvin_chartX {x y : ℝ} (h : x ^ 2 + y ^ 2 ≠ 0) :
    evalAt chartX (x / (x ^ 2 + y ^ 2)) (y / (x ^ 2 + y ^ 2)) = evalAt chartX x y := by
  have hpos : (0 : ℝ) < 1 + x ^ 2 + y ^ 2 := by positivity
  simp only [evalAt_chartX, W]
  field_simp
  ring

/-- Kelvin inversion fixes the second chart coordinate. -/
theorem kelvin_chartY {x y : ℝ} (h : x ^ 2 + y ^ 2 ≠ 0) :
    evalAt chartY (x / (x ^ 2 + y ^ 2)) (y / (x ^ 2 + y ^ 2)) = evalAt chartY x y := by
  have hpos : (0 : ℝ) < 1 + x ^ 2 + y ^ 2 := by positivity
  simp only [evalAt_chartY, W]
  field_simp
  ring

/-- **Kelvin duality.**  Inversion of the plane in the unit circle is conjugated by the
stereographic chart to the equatorial reflection `z ↦ -z` of the sphere. -/
theorem kelvin_chartZ {x y : ℝ} (h : x ^ 2 + y ^ 2 ≠ 0) :
    evalAt chartZ (x / (x ^ 2 + y ^ 2)) (y / (x ^ 2 + y ^ 2)) = -evalAt chartZ x y := by
  have hpos : (0 : ℝ) < 1 + x ^ 2 + y ^ 2 := by positivity
  simp only [evalAt_chartZ, W]
  field_simp
  ring

/-- The zonal quadrupole is Kelvin-invariant (even polar parity). -/
theorem kelvin_H2z2 {x y : ℝ} (h : x ^ 2 + y ^ 2 ≠ 0) :
    evalAt H2z2 (x / (x ^ 2 + y ^ 2)) (y / (x ^ 2 + y ^ 2)) = evalAt H2z2 x y := by
  simp only [H2z2, evalAt_sub, evalAt_mul, evalAt_const, kelvin_chartZ h]
  ring

/-- The zonal octupole is Kelvin-anti-invariant (odd polar parity). -/
theorem kelvin_H3g {x y : ℝ} (h : x ^ 2 + y ^ 2 ≠ 0) :
    evalAt H3g (x / (x ^ 2 + y ^ 2)) (y / (x ^ 2 + y ^ 2)) = -evalAt H3g x y := by
  simp only [H3g, evalAt_sub, evalAt_mul, evalAt_const, kelvin_chartZ h]
  ring

end

end StereoNeuralField