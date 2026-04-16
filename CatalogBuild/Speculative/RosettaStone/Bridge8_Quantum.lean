/-! # CatalogBuild.Speculative.RosettaStone.Bridge8_Quantum

Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 10
-/

import Mathlib

/-- A projection matrix P satisfies P² = P. -/
def IsProjection (P : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  P * P = P



/-- The zero matrix is a projection. -/
theorem zero_is_projection : IsProjection (0 : Matrix (Fin n) (Fin n) ℝ) := by
  simp [IsProjection]



/-- The identity matrix is a projection. -/
theorem one_is_projection : IsProjection (1 : Matrix (Fin n) (Fin n) ℝ) := by
  simp [IsProjection]



/-- If P is a projection, then I - P is a projection. -/
theorem complement_projection {P : Matrix (Fin n) (Fin n) ℝ} (hP : IsProjection P) :
    IsProjection (1 - P) := by
  simp only [IsProjection] at *
  have h1 : (1 - P) * P = 0 := by rw [sub_mul, one_mul, hP, sub_self]
  calc (1 - P) * (1 - P) = 1 - P - (1 - P) * P := by rw [mul_sub, mul_one]
    _ = 1 - P - 0 := by rw [h1]
    _ = 1 - P := by rw [sub_zero]



/-- P(I-P) = 0. -/
theorem projection_orthogonal_complement {P : Matrix (Fin n) (Fin n) ℝ}
    (hP : IsProjection P) :
    P * (1 - P) = 0 := by
  simp only [IsProjection] at *
  rw [mul_sub, mul_one, hP, sub_self]



/-- (I-P)P = 0. -/
theorem complement_projection_orthogonal {P : Matrix (Fin n) (Fin n) ℝ}
    (hP : IsProjection P) :
    (1 - P) * P = 0 := by
  simp only [IsProjection] at *
  rw [sub_mul, one_mul, hP, sub_self]



/-- Measurement stability: P² = P. -/
theorem measurement_stability {P : Matrix (Fin n) (Fin n) ℝ}
    (hP : IsProjection P) : P * P = P := hP



/-- Sum of orthogonal projections is a projection. -/
theorem sum_orthogonal_projections {P Q : Matrix (Fin n) (Fin n) ℝ}
    (hP : IsProjection P) (hQ : IsProjection Q)
    (hPQ : P * Q = 0) (hQP : Q * P = 0) :
    IsProjection (P + Q) := by
  simp only [IsProjection] at *
  rw [mul_add, add_mul, add_mul, hP, hPQ, hQP, hQ, add_zero, zero_add]



/-- Diagonal projections are projections. -/
theorem diagonal_projection_is_projection (S : Finset (Fin n)) :
    IsProjection (diagonalProjection S) := by
  simp only [IsProjection, diagonalProjection, Matrix.diagonal_mul_diagonal]
  congr 1; ext i; split <;> simp



/-- Diagonal projections commute (= classical measurements). -/
theorem diagonal_projections_commute (S T : Finset (Fin n)) :
    diagonalProjection S * diagonalProjection T =
    diagonalProjection T * diagonalProjection S := by
  simp [diagonalProjection, Matrix.diagonal_mul_diagonal, mul_comm]


