import Mathlib
import Logic.StrangeLoops.Core

/-! # CatalogBuild.Bridges.MatrixRepresentation

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 13
-/

noncomputable section

open Matrix

/-- The hyperbolic speed-addition law.  (Supplied here.) -/
def spbH (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-- The SPB matrix for parameter a. -/
def spbMat (a : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![1, a; a, 1]

/-- Determinant of the SPB matrix: det(M(a)) = 1 - a². -/
theorem spbMat_det (a : ℝ) : (spbMat a).det = 1 - a ^ 2 := by
  unfold spbMat; simp [det_fin_two]; ring

/-- Trace of the SPB matrix: tr(M(a)) = 2. -/
theorem spbMat_trace (a : ℝ) : (spbMat a).trace = 2 := by
  unfold spbMat trace; simp [Fin.sum_univ_two]; norm_num

/-- The SPB matrix is symmetric. -/
theorem spbMat_symmetric (a : ℝ) : (spbMat a)ᵀ = spbMat a := by
  unfold spbMat; ext i j; fin_cases i <;> fin_cases j <;> simp

/-- M(0) is the identity matrix. -/
theorem spbMat_zero : spbMat 0 = 1 := by
  unfold spbMat; ext i j; fin_cases i <;> fin_cases j <;> simp

/-- Matrix product: M(a) · M(b) = [[1+ab, a+b], [a+b, 1+ab]]. -/
theorem spbMat_mul (a b : ℝ) :
    spbMat a * spbMat b = !![1 + a * b, a + b; a + b, 1 + a * b] := by
  unfold spbMat; ext i j
  fin_cases i <;> fin_cases j <;> simp [mul_apply, Fin.sum_univ_two] <;> ring

/-- [Section: # SPB Matrix Representation and PSL(2,ℝ) Connection
The SPB operation spb(x,a) corresponds to the Möbius transformation
z ↦ (z + a)/(1 - az) with matrix M(a) = [[1, a], [a, 1]].
## Main Results
- Matrix determinant formula: det = 1 - a²
- Matrix product encodes SPB composition
- Trace = 2, characteristic polynomial
- Eigenvalue analysis
- Inverse via M(-a)] -/
theorem spbMat_mul_scalar (a b : ℝ) (h : 1 + a * b ≠ 0) :
    spbMat a * spbMat b = (1 + a * b) • spbMat (spbH a b) := by
  ext i j; fin_cases i <;> fin_cases j <;> norm_num [ spbMat, spbH ] <;> ring;
  · grind;
  · grind

/-- Determinant multiplicativity. -/
theorem spbMat_det_mul (a b : ℝ) :
    (spbMat a * spbMat b).det = (spbMat a).det * (spbMat b).det := det_mul _ _

/-- [Section: # CatalogBuild.Bridges.MatrixRepresentation
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 13] -/
theorem spbMat_char_poly (a : ℝ) :
    spbMat a * spbMat a - (2 : ℝ) • spbMat a + (1 - a ^ 2) • (1 : Matrix (Fin 2) (Fin 2) ℝ) = 0 := by
  ext i j ; fin_cases i <;> fin_cases j <;> norm_num [ spbMat ] <;> ring

/-- Eigenvalue product: (1+a)(1-a) = 1-a² = det(M(a)). -/
theorem eigenvalue_product (a : ℝ) : (1 + a) * (1 - a) = 1 - a ^ 2 := by ring

/-- Eigenvalue sum: (1+a)+(1-a) = 2 = tr(M(a)). -/
theorem eigenvalue_sum (a : ℝ) : (1 + a) + (1 - a) = 2 := by ring

/-- M(a)² = [[1+a², 2a], [2a, 1+a²]]. -/
theorem spbMat_sq_explicit (a : ℝ) :
    spbMat a * spbMat a = !![1 + a ^ 2, 2 * a; 2 * a, 1 + a ^ 2] := by
  rw [spbMat_mul]; ext i j; fin_cases i <;> fin_cases j <;> simp <;> ring

theorem spbMat_mul_neg (a : ℝ) :
    spbMat a * spbMat (-a) = (1 - a ^ 2) • (1 : Matrix (Fin 2) (Fin 2) ℝ) := by
  ext i j ; fin_cases i <;> fin_cases j <;> norm_num [ spbMat ] <;> ring

end