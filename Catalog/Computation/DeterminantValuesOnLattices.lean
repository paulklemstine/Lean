import Mathlib

/-!
# Determinant values on matrix lattices: exact algebraic foundations

This file formalizes the algebraic and Euclidean identities underlying the
`d = 2` case of determinant-value counting.  In two dimensions the determinant
is an indefinite quadratic form of signature `(2,2)`.  Its homogeneity and the
quadratic scaling of square energy explain why a determinant window is naturally
counted on the `T²` scale.

The analytic lattice-point asymptotic from the paper requires homogeneous
dynamics and quantitative equidistribution not presently encoded here.  The
results below isolate its exact finite-dimensional input using Mathlib's matrix
determinant.
-/

open scoped BigOperators
open Matrix

namespace DeterminantValues

/-- The square of the Frobenius norm, written without a square root. -/
def squareEnergy {m n : Type*} [Fintype m] [Fintype n]
    (M : Matrix m n ℝ) : ℝ :=
  ∑ i, ∑ j, (M i j) ^ 2

/-- Square energy is nonnegative. -/
theorem squareEnergy_nonneg {m n : Type*} [Fintype m] [Fintype n]
    (M : Matrix m n ℝ) : 0 ≤ squareEnergy M := by
  exact Finset.sum_nonneg fun _ _ ↦ Finset.sum_nonneg fun _ _ ↦ sq_nonneg _

/-- Scalar dilation acts quadratically on square energy. -/
theorem squareEnergy_smul {m n : Type*} [Fintype m] [Fintype n]
    (r : ℝ) (M : Matrix m n ℝ) :
    squareEnergy (r • M) = r ^ 2 * squareEnergy M := by
  simp only [squareEnergy, smul_apply, smul_eq_mul, mul_pow]
  rw [Finset.mul_sum]
  congr 1
  funext i
  rw [Finset.mul_sum]

/-- The determinant is homogeneous of degree `d`. -/
theorem det_smul_degree (d : ℕ) (r : ℝ) (M : Matrix (Fin d) (Fin d) ℝ) :
    (r • M).det = r ^ d * M.det := by
  simp [Fintype.card_fin]

/-- Explicit square energy of a real `2 × 2` matrix. -/
theorem squareEnergy_fin_two (M : Matrix (Fin 2) (Fin 2) ℝ) :
    squareEnergy M = M 0 0 ^ 2 + M 0 1 ^ 2 + M 1 0 ^ 2 + M 1 1 ^ 2 := by
  simp [squareEnergy, Fin.sum_univ_two]
  ring

/-- The determinant on `M₂(ℝ)` is the quadratic form of signature `(2,2)`
after the displayed invertible linear change of coordinates.  This is the
precise bridge to the signature `(2,2)` quantitative Oppenheim problem. -/
theorem det_as_signature_two_two (M : Matrix (Fin 2) (Fin 2) ℝ) :
    M.det =
      ((M 0 0 + M 1 1) / 2) ^ 2 + ((M 0 1 - M 1 0) / 2) ^ 2
      - ((M 0 0 - M 1 1) / 2) ^ 2 - ((M 0 1 + M 1 0) / 2) ^ 2 := by
  rw [Matrix.det_fin_two]
  ring

/-- Sharp Frobenius-energy control of the `2 × 2` determinant.  Equality is
attained, for example, by scalar multiples of the identity. -/
theorem two_mul_abs_det_le_squareEnergy (M : Matrix (Fin 2) (Fin 2) ℝ) :
    2 * |M.det| ≤ squareEnergy M := by
  rw [det_fin_two, squareEnergy_fin_two]
  set a := M 0 0 with ha
  set b := M 0 1 with hb
  set c := M 1 0 with hc
  set d := M 1 1 with hd
  nlinarith [sq_nonneg (a - d), sq_nonneg (a + d), sq_nonneg (b - c), sq_nonneg (b + c),
             sq_nonneg (a * c + b * d), sq_nonneg (a * b + c * d), sq_nonneg (a - b), sq_nonneg (c - d),
             sq_nonneg (a * d - b * c), sq_nonneg (a * d + b * c), abs_mul_abs_self (a * d - b * c)]

/-- Consequently, a nonzero determinant forces positive square energy. -/
theorem squareEnergy_pos_of_det_ne_zero (M : Matrix (Fin 2) (Fin 2) ℝ)
    (hdet : M.det ≠ 0) : 0 < squareEnergy M := by
  have habs : 0 < |M.det| := abs_pos.mpr hdet
  have hbound := two_mul_abs_det_le_squareEnergy M
  linarith

/-- Integral matrices have integral real determinant values.  Thus the standard
integer matrix lattice is an example of the arithmetic/discrete determinant
case excluded by the paper's non-arithmetic hypothesis. -/
theorem integer_matrix_real_det
    (M : Matrix (Fin 2) (Fin 2) ℤ) :
    (M.map (Int.castRingHom ℝ)).det = (M.det : ℝ) := by
  rw [Matrix.det_fin_two, Matrix.det_fin_two]
  simp [Matrix.map_apply]

/-- The determinant-energy inequality is sharp on scalar matrices. -/
theorem scalar_identity_attains_energy_bound (r : ℝ) :
    2 * |(r • (1 : Matrix (Fin 2) (Fin 2) ℝ)).det| =
      squareEnergy (r • (1 : Matrix (Fin 2) (Fin 2) ℝ)) := by
  rw [det_smul_degree, Matrix.det_one, squareEnergy_smul, squareEnergy_fin_two]
  simp
  nlinarith [sq_nonneg r]

/-- Scalar dilation preserves the determinant-zero cone. -/
theorem det_smul_eq_zero_iff {d : ℕ} (r : ℝ) (hr : r ≠ 0)
    (M : Matrix (Fin d) (Fin d) ℝ) :
    (r • M).det = 0 ↔ M.det = 0 := by
  rw [det_smul_degree]
  exact mul_eq_zero_iff_left (pow_ne_zero d hr)

end DeterminantValues