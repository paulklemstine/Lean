import Catalog.Applications.MicroscopicWeighting.Core

/-!
# Concrete microscopic weightings and the sign characterisation

We exhibit the microscopic weighting `μ` (a distance-matrix weighting in the
sense of `Core.lean`: `D μ = λ𝟙`, `Σ μ = 1`) for four Euclidean configurations,
and determine the sign of every coordinate. In each case a coordinate is
**positive** exactly at a vertex (extreme point) of the convex hull and
**non-positive** at a non-extreme point, the concrete content of the research
theme "Sign Characterisation of Microscopic Weighting on Euclidean Subsets".

* Two points (both extreme): `μ = (½,½) > 0`.
* Three collinear points `0,1,2` (middle non-extreme): `μ = (½,0,½)`, middle `= 0`.
* Equilateral triangle (all extreme): `μ = (⅓,⅓,⅓) > 0`.
* Square `{(±1,±1)}` plus its centre (centre strictly interior): the centre gets
  a **strictly negative** weight while the four vertices get positive weight.

The geometric side (which points really are extreme) is treated for the
collinear case in `ExtremePoints.lean`.
-/

namespace MicroWeighting

open Matrix BigOperators

/-! ## Two points at distance `r` -/

/-- Distance matrix of two points at distance `r`. -/
noncomputable def D2 (r : ℝ) : Matrix (Fin 2) (Fin 2) ℝ := !![0, r; r, 0]

/-- The microscopic weighting of a two-point space is `(½,½)` with constant `r/2`;
both weights are positive, matching the fact that both points are extreme. -/
theorem two_point_weighting (r : ℝ) :
    IsMicroWeighting (D2 r) ![1/2, 1/2] (r/2) := by
  refine ⟨?_, ?_⟩
  · funext i
    fin_cases i <;> (simp [D2, Matrix.mulVec, Fin.sum_univ_two, dotProduct]; ring)
  · simp [Fin.sum_univ_two]; norm_num

theorem two_point_pos : (0:ℝ) < (![1/2, 1/2] : Fin 2 → ℝ) 0 ∧
    (0:ℝ) < (![1/2, 1/2] : Fin 2 → ℝ) 1 := by
  constructor <;> norm_num

/-! ## Three collinear points `0, 1, 2` -/

/-- Distance matrix of the three collinear points `0,1,2 ∈ ℝ`. -/
noncomputable def D3 : Matrix (Fin 3) (Fin 3) ℝ := !![0,1,2; 1,0,1; 2,1,0]

/-- `D3` is symmetric. -/
theorem D3_symm : D3ᵀ = D3 := by
  funext i j; fin_cases i <;> fin_cases j <;> simp [D3]

/-- The microscopic weighting of the three collinear points is `(½, 0, ½)` with
constant `1`. The two endpoints get weight `½ > 0`, the middle point gets `0`. -/
theorem collinear_weighting :
    IsMicroWeighting D3 ![1/2, 0, 1/2] 1 := by
  refine ⟨?_, ?_⟩
  · funext i
    fin_cases i <;> (simp [D3, Matrix.mulVec, Fin.sum_univ_three, dotProduct]; try ring)
  · simp [Fin.sum_univ_three]; norm_num

/-- Endpoints get positive weight; the (non-extreme) middle point gets weight `0`,
which is `≤ 0` as the sign characterisation predicts for non-extreme points. -/
theorem collinear_signs :
    (0:ℝ) < (![1/2, 0, 1/2] : Fin 3 → ℝ) 0 ∧
    (![1/2, 0, 1/2] : Fin 3 → ℝ) 1 ≤ 0 ∧
    (0:ℝ) < (![1/2, 0, 1/2] : Fin 3 → ℝ) 2 := by
  refine ⟨by norm_num, by norm_num, ?_⟩
  norm_num [Matrix.cons_val_two, Matrix.tail_cons, Matrix.head_cons]

/-! ## Equilateral triangle of side `c` -/

/-- Distance matrix of an equilateral triangle of side `c`. -/
noncomputable def Dtri (c : ℝ) : Matrix (Fin 3) (Fin 3) ℝ := !![0,c,c; c,0,c; c,c,0]

/-- The microscopic weighting of an equilateral triangle is uniform `(⅓,⅓,⅓)`
with constant `2c/3`; all weights are positive since all three points are extreme. -/
theorem triangle_weighting (c : ℝ) :
    IsMicroWeighting (Dtri c) ![1/3, 1/3, 1/3] (2*c/3) := by
  refine ⟨?_, ?_⟩
  · funext i
    fin_cases i <;> (simp [Dtri, Matrix.mulVec, Fin.sum_univ_three, dotProduct]; try ring)
  · simp [Fin.sum_univ_three]; norm_num

theorem triangle_pos : ∀ i, (0:ℝ) < (![1/3, 1/3, 1/3] : Fin 3 → ℝ) i := by
  intro i; fin_cases i <;> norm_num

/-! ## Square `{(±1,±1)}` together with its centre -/

/-- `s = √2`, the centre-to-vertex distance in the unit square configuration. -/
noncomputable def s : ℝ := Real.sqrt 2

theorem s_sq : s ^ 2 = 2 := Real.sq_sqrt (by norm_num)

theorem s_pos : 0 < s := Real.sqrt_pos.mpr (by norm_num)

theorem one_lt_s : 1 < s := by nlinarith [s_sq, s_pos]

theorem s_lt_three : s < 3 := by nlinarith [s_sq, s_pos]

/-- The denominator `6 - 2√2 > 0` normalising the weighting. -/
theorem den_pos : (0:ℝ) < 6 - 2 * s := by nlinarith [s_lt_three]

/-- Distance matrix of the square `{(±1,±1)}` plus centre `(0,0)`.
Index `0` is the centre; indices `1,2,3,4` are the vertices in cyclic order,
so adjacent vertices are at distance `2` and diagonal vertices at distance `2√2`. -/
noncomputable def Dsq : Matrix (Fin 5) (Fin 5) ℝ :=
  !![0, s, s, s, s;
     s, 0, 2, 2*s, 2;
     s, 2, 0, 2, 2*s;
     s, 2*s, 2, 0, 2;
     s, 2, 2*s, 2, 0]

/-- `Dsq` is symmetric. -/
theorem Dsq_symm : Dsqᵀ = Dsq := by
  funext i j; fin_cases i <;> fin_cases j <;> simp [Dsq]

/-- The *unnormalised* microscopic weighting: `w₀ = (2(1-√2), 1, 1, 1, 1)` solves
`Dsq w₀ = (4√2)·𝟙`. -/
noncomputable def w0 : Fin 5 → ℝ := ![2*(1-s), 1, 1, 1, 1]

theorem Dsq_mulVec_w0 : Dsq *ᵥ w0 = (fun _ => 4 * s) := by
  funext i
  fin_cases i <;>
    (simp [Dsq, w0, Matrix.mulVec, Fin.sum_univ_five, dotProduct]; nlinarith [s_sq])

theorem sum_w0 : ∑ i, w0 i = 6 - 2 * s := by
  simp [w0, Fin.sum_univ_five]; ring

/-- The (normalised) microscopic weighting of the square-plus-centre. -/
noncomputable def musq : Fin 5 → ℝ := (6 - 2 * s)⁻¹ • w0

/-- `μ = w₀ / (6 - 2√2)` is a genuine microscopic weighting of the
square-plus-centre configuration, with constant `4√2 / (6 - 2√2)`. -/
theorem square_weighting :
    IsMicroWeighting Dsq musq ((6 - 2 * s)⁻¹ * (4 * s)) := by
  have hden : (6 - 2 * s) ≠ 0 := ne_of_gt den_pos
  refine ⟨?_, ?_⟩
  · rw [musq, Matrix.mulVec_smul, Dsq_mulVec_w0]
    funext i
    simp [Pi.smul_apply, smul_eq_mul]
  · rw [musq]
    simp only [Pi.smul_apply, smul_eq_mul, ← Finset.mul_sum]
    rw [sum_w0, inv_mul_cancel₀ hden]

/-- **Sign characterisation for the square-plus-centre.**
The strictly interior centre (index `0`) receives a **negative** weight, while
each of the four extreme vertices (indices `1,…,4`) receives a **positive**
weight. -/
theorem square_signs :
    musq 0 < 0 ∧ (∀ i : Fin 5, i ≠ 0 → 0 < musq i) := by
  have hinv : (0:ℝ) < (6 - 2 * s)⁻¹ := inv_pos.mpr den_pos
  have key : ∀ i : Fin 5, musq i = (6 - 2 * s)⁻¹ * w0 i := by
    intro i; simp [musq, Pi.smul_apply, smul_eq_mul]
  refine ⟨?_, ?_⟩
  · -- centre weight `= (6-2s)⁻¹ * 2(1-s) < 0` since `s > 1`
    rw [key 0, show w0 0 = 2 * (1 - s) from by simp [w0]]
    exact mul_neg_of_pos_of_neg hinv (by nlinarith [one_lt_s])
  · intro i hi
    rw [key i]
    fin_cases i
    · exact absurd rfl hi
    all_goals (norm_num [w0]; linarith [s_lt_three])

end MicroWeighting