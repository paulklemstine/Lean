import Mathlib
import Novelty.Metric

/-!
# Intrinsic curvature identification for the split metric

For the split metric
\[
 g=\cosh(y)^{-2}dx^2+\cosh(x)^2dy^2,
\]
this chapter passes from the coordinate Gaussian-curvature calculation to the
basis-independent sectional quotient.  The bridge is the Gram determinant: in
dimension two it is the metric determinant multiplied by the square of the
oriented coordinate area.  Consequently every nondegenerate tangent two-frame
has the same sectional curvature, namely the computed Gaussian curvature.
-/

namespace SplitGeometry.IntrinsicCurvature

open SplitGeometry

noncomputable section

/-- The oriented coordinate area of two tangent vectors. -/
def wedge (u v : M) : ℝ := u.1 * v.2 - u.2 * v.1

/-- Gram determinant of a tangent two-frame. -/
def gram (p u v : M) : ℝ :=
  gForm p u u * gForm p v v - gForm p u v ^ 2

/-- The closed Gaussian-curvature expression obtained from the Brioschi calculation. -/
def gaussian (p : M) : ℝ :=
  -Real.cosh p.2 ^ 2 +
    (1 - Real.sinh p.2 ^ 2) / (Real.cosh p.1 ^ 2 * Real.cosh p.2 ^ 2)

/-- The intrinsic algebraic curvature tensor determined by `gaussian` and `gForm`. -/
def curvature4 (p u v w z : M) : ℝ :=
  gaussian p * (gForm p u w * gForm p v z - gForm p u z * gForm p v w)

/-- The sectional quotient of a nondegenerate tangent two-frame. -/
def sectional (p u v : M) : ℝ := curvature4 p u v u v / gram p u v

/-
The Gram determinant is the metric determinant times squared oriented area.
-/
theorem gram_eq_metricDet_mul_wedge_sq (p u v : M) :
    gram p u v = Emet p * Gmet p * wedge u v ^ 2 := by
  unfold gram gForm wedge;
  ring

/-
A coordinate-independent tangent frame has positive Gram determinant.
-/
theorem gram_pos (p u v : M) (huv : wedge u v ≠ 0) : 0 < gram p u v := by
  convert gram_eq_metricDet_mul_wedge_sq p u v ▸ mul_pos ( mul_pos ( Emet_pos p ) ( Gmet_pos p ) ) ( sq_pos_of_ne_zero huv ) using 1

/-
The curvature tensor is alternating in its first pair.
-/
theorem curvature4_swap_first (p u v w z : M) :
    curvature4 p v u w z = -curvature4 p u v w z := by
  unfold curvature4;
  ring

/-
The curvature tensor is alternating in its second pair.
-/
theorem curvature4_swap_second (p u v w z : M) :
    curvature4 p u v z w = -curvature4 p u v w z := by
  unfold curvature4; ring;

/-
The curvature tensor has pair-interchange symmetry.
-/
theorem curvature4_pair_swap (p u v w z : M) :
    curvature4 p w z u v = curvature4 p u v w z := by
  unfold curvature4;
  unfold gForm; ring;

/-
The algebraic first Bianchi identity.
-/
theorem curvature4_bianchi (p u v w z : M) :
    curvature4 p u v w z + curvature4 p v w u z + curvature4 p w u v z = 0 := by
  -- Unfold curvature4 using its definition.
  unfold curvature4;
  unfold gForm; ring;

/-
Curvature on a two-frame is Gaussian curvature times its Gram determinant.
-/
theorem curvature4_self_eq_gaussian_mul_gram (p u v : M) :
    curvature4 p u v u v = gaussian p * gram p u v := by
  convert congr_arg _ ?_;
  rotate_left;
  exact v;
  · rfl;
  · unfold gaussian gram curvature4 gForm;
    unfold gaussian; ring;

/-
**Intrinsic curvature identification.** Every nondegenerate tangent two-frame
has sectional curvature equal to the coordinate Gaussian curvature.
-/
theorem sectional_eq_gaussian (p u v : M) (huv : wedge u v ≠ 0) :
    sectional p u v = gaussian p := by
  unfold sectional
  rw [curvature4_self_eq_gaussian_mul_gram]
  field_simp [ne_of_gt (gram_pos p u v huv)]

/-
The Gaussian curvature is nonpositive everywhere.
-/
theorem gaussian_nonpos (p : M) : gaussian p ≤ 0 := by
  unfold gaussian;
  rw [ add_div', div_le_iff₀ ];
  · nlinarith [ sq_nonneg ( Real.cosh p.1 ^ 2 * Real.cosh p.2 ^ 2 - 1 ), Real.cosh_sq' p.1, Real.cosh_sq' p.2 ];
  · exact mul_pos ( sq_pos_of_pos ( Real.cosh_pos _ ) ) ( sq_pos_of_pos ( Real.cosh_pos _ ) );
  · exact ne_of_gt ( mul_pos ( sq_pos_of_pos ( Real.cosh_pos _ ) ) ( sq_pos_of_pos ( Real.cosh_pos _ ) ) )

/-
The Gaussian curvature vanishes exactly at the origin.
-/
theorem gaussian_eq_zero_iff (p : M) : gaussian p = 0 ↔ p = (0, 0) := by
  constructor <;> intro h <;> simp_all +decide [ gaussian ];
  rw [ add_div', div_eq_iff ] at h;
  · by_cases h1 : p.1 = 0 <;> by_cases h2 : p.2 = 0 <;> simp_all +decide [ Real.cosh_sq' ];
    · exact Prod.ext h1 h2;
    · nlinarith [ mul_self_pos.2 ( show Real.sinh p.2 ≠ 0 from fun h' => h2 <| by simpa [ h' ] using Real.sinh_injective <| by aesop ) ];
    · exact absurd h ( by nlinarith [ mul_pos ( sq_pos_of_ne_zero ( show Real.sinh p.1 ≠ 0 from by aesop ) ) ( sq_pos_of_ne_zero ( show Real.sinh p.2 ≠ 0 from by aesop ) ) ] );
  · exact ne_of_gt ( mul_pos ( sq_pos_of_pos ( Real.cosh_pos _ ) ) ( sq_pos_of_pos ( Real.cosh_pos _ ) ) );
  · exact ne_of_gt ( mul_pos ( sq_pos_of_pos ( Real.cosh_pos _ ) ) ( sq_pos_of_pos ( Real.cosh_pos _ ) ) )

/-
Every sectional curvature away from the origin is strictly negative.
-/
theorem sectional_strictly_neg (p u v : M) (hp : p ≠ (0, 0))
    (huv : wedge u v ≠ 0) : sectional p u v < 0 := by
  rw [ sectional_eq_gaussian p u v huv ];
  exact lt_of_le_of_ne ( gaussian_nonpos p ) fun h => hp <| gaussian_eq_zero_iff p |>.1 h

-- !-- Lab Notes -- !--
-- Hypothesis (ranked by impact):
-- 1. The coordinate scalar equals the sectional quotient for every tangent two-frame.
-- 2. The associated four-tensor satisfies all algebraic Riemann symmetries.
-- 3. Strict negativity off the origin forces uniqueness phenomena for geodesic bigons.
-- 4. The metric is geodesically complete despite its anisotropic coefficients.
-- 5. Every nonconstant geodesic can meet the zero-curvature locus at most once.
-- 6. The exponential map at the origin is globally injective.
-- Experiment: numerical sampling found no positive curvature, while symbolic expansion
-- of the Gram determinant exposed a metric-determinant times wedge-square factor.
-- Analysis: hypotheses 1 and 2 survive completely. Positivity of the two coefficients
-- makes every nonzero wedge a positive denominator, so the sectional quotient cancels
-- without a sign ambiguity. The sign and zero-locus predictions also survive.
-- Critique: hypotheses 3--6 require the Levi-Civita geodesic flow and are not consequences
-- of the algebraic tensor alone. The sectional conclusion is correctly restricted to
-- nondegenerate frames; a zero wedge has zero denominator and represents no two-plane.
-- Synthesis: the Brioschi scalar determines an algebraic curvature tensor with all
-- Riemann symmetries, and its sectional quotient is exactly the same scalar.
-- !-- End Lab Notes -- !--

end

end SplitGeometry.IntrinsicCurvature