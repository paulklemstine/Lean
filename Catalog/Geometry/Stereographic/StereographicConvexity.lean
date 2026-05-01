import Geometry.Stereographic.Basic
import Mathlib

/-! # CatalogBuild.Geometry.Stereographic.StereographicConvexity

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 12
-/


noncomputable section

/-- The stereographic midpoint of two points -/
def stereoMidpoint {N : ℕ} (y z : Fin N → ℝ) : Fin N → ℝ :=
  fun i => (y i * stereoDenom z + z i * stereoDenom y) /
            (stereoDenom y + stereoDenom z)


/-- Midpoint is symmetric -/
theorem stereoMidpoint_comm {N : ℕ} (y z : Fin N → ℝ) :
    stereoMidpoint y z = stereoMidpoint z y := by
  ext i; unfold stereoMidpoint; ring


/-- [Section: # Convexity and Optimization on the Sphere via Stereographic Projection
## Main Results
* `stereoMidpoint_comm` — midpoint is symmetric
* `stereoMidpoint_self` — midpoint of a point with itself
* `chordalDistSq` — squared chordal distance definition
* `chordalDistSq_comm` — symmetry
* `chordalDistSq_self` — self-distance is zero
* `chordalDistSq_nonneg` — nonnegativity
* `chordalDistSq_le_four` — diameter bound
* `unit_ball_southern` — unit ball maps to southern hemisphere
* `stereoDenom_first_order` — first-order expansion] -/
theorem stereoMidpoint_self {N : ℕ} (y : Fin N → ℝ) :
    stereoMidpoint y y = y := by
  ext i; unfold stereoMidpoint; unfold stereoDenom; ring;
  linarith [ inv_mul_cancel_left₀ ( show ( 2 + sqNormFin y * 2 ) ≠ 0 by linarith [ show 0 ≤ sqNormFin y by exact Finset.sum_nonneg fun _ _ => sq_nonneg _ ] ) ( y i ) ]


/-- Squared chordal distance -/
def chordalDistSq {N : ℕ} (y z : Fin N → ℝ) : ℝ :=
  4 * (∑ i, (y i - z i)^2) / (stereoDenom y * stereoDenom z)


/-- Chordal distance is symmetric -/
theorem chordalDistSq_comm {N : ℕ} (y z : Fin N → ℝ) :
    chordalDistSq y z = chordalDistSq z y := by
  unfold chordalDistSq
  congr 1
  · congr 1; apply Finset.sum_congr rfl; intro i _; ring
  · ring


/-- Distance to self is zero -/
theorem chordalDistSq_self {N : ℕ} (y : Fin N → ℝ) :
    chordalDistSq y y = 0 := by
  unfold chordalDistSq; simp


/-- Chordal distance is nonneg -/
theorem chordalDistSq_nonneg {N : ℕ} (y z : Fin N → ℝ) :
    0 ≤ chordalDistSq y z := by
  unfold chordalDistSq
  apply div_nonneg
  · exact mul_nonneg (by positivity) (Finset.sum_nonneg fun i _ => sq_nonneg _)
  · exact (mul_pos (stereoDenom_pos y) (stereoDenom_pos z)).le


theorem chordalDistSq_le_four {N : ℕ} (y z : Fin N → ℝ) :
    chordalDistSq y z ≤ 4 := by
  unfold chordalDistSq;
  rw [ div_le_iff₀ ( mul_pos ( by exact add_pos_of_pos_of_nonneg zero_lt_one ( Finset.sum_nonneg fun _ hi => sq_nonneg _ ) ) ( by exact add_pos_of_pos_of_nonneg zero_lt_one ( Finset.sum_nonneg fun _ hi => sq_nonneg _ ) ) ) ] ; ring;
  norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul, stereoDenom ];
  -- By the Cauchy-Schwarz inequality, we have that for any vectors $u$ and $v$, $(u \cdot v)^2 \leq \|u\|^2 \|v\|^2$.
  have h_cauchy_schwarz : (∑ i, y i * z i) ^ 2 ≤ (∑ i, y i ^ 2) * (∑ i, z i ^ 2) := by
    exact?;
  norm_num [ ← Finset.sum_mul _ _ _, sqNormFin ];
  nlinarith [ sq_nonneg ( ∑ i, y i * z i + 1 ), show 0 ≤ ∑ i, y i ^ 2 from Finset.sum_nonneg fun _ _ => sq_nonneg _, show 0 ≤ ∑ i, z i ^ 2 from Finset.sum_nonneg fun _ _ => sq_nonneg _ ]


theorem kissing_number_constraint {N : ℕ} (y z : Fin N → ℝ)
    (h : chordalDistSq y z ≥ 1) :
    4 * ∑ i, (y i - z i) ^ 2 ≥ stereoDenom y * stereoDenom z := by
  rwa [ chordalDistSq, ge_iff_le, one_le_div ( mul_pos ( stereoDenom_pos _ ) ( stereoDenom_pos _ ) ) ] at h


theorem unit_ball_southern {N : ℕ} (y : Fin N → ℝ) (hy : sqNormFin y ≤ 1) :
    invStereoN y (lastIdx N) ≤ 0 := by
  -- Since $sqNormFin y \leq 1$, we have $sqNormFin y - 1 \leq 0$.
  have h_num_nonpos : sqNormFin y - 1 ≤ 0 := by
    linarith;
  unfold invStereoN lastIdx;
  norm_num [ div_nonpos_of_nonpos_of_nonneg, h_num_nonpos, stereoDenom_pos y |> le_of_lt ]


/-- Gradient descent preserves finiteness -/
theorem gradient_descent_denom_pos {N : ℕ} (y step : Fin N → ℝ) :
    0 < stereoDenom (fun i => y i - step i) :=
  stereoDenom_pos _


theorem stereoDenom_first_order {N : ℕ} (y v : Fin N → ℝ) (t : ℝ) :
    stereoDenom (fun i => y i + t * v i) =
    stereoDenom y + 2 * t * ∑ i, y i * v i + t^2 * sqNormFin v := by
  unfold stereoDenom sqNormFin;
  simp +decide only [add_sq, mul_comm, mul_left_comm, mul_assoc, sum_add_distrib, Finset.mul_sum _ _ _] ; ring


end