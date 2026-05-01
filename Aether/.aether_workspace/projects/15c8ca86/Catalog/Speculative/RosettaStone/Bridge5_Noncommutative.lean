import Mathlib

/-! # CatalogBuild.Speculative.RosettaStone.Bridge5_Noncommutative

Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 5
-/

/-- The commutator [A, B] = AB - BA. -/
def commutator (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  A * B - B * A

/-- Diagonal matrices commute. -/
theorem diagonal_commute (f g : Fin n → ℝ) :
    commutator (Matrix.diagonal f) (Matrix.diagonal g) = 0 := by
  simp [commutator, Matrix.diagonal_mul_diagonal, mul_comm, sub_self]

/-- Commuting idempotents have idempotent product. -/
theorem commuting_projections_product
    (P Q : Matrix (Fin n) (Fin n) ℝ)
    (hP : P * P = P) (hQ : Q * Q = Q)
    (hcomm : P * Q = Q * P) :
    (P * Q) * (P * Q) = P * Q := by
  rw [Matrix.mul_assoc, ← Matrix.mul_assoc Q P, ← hcomm,
      Matrix.mul_assoc P Q, hQ, ← Matrix.mul_assoc, hP]

/-- Diagonal matrices form a commutative subalgebra. -/
theorem diagonal_mul_comm (f g : Fin n → ℝ) :
    Matrix.diagonal f * Matrix.diagonal g =
    Matrix.diagonal g * Matrix.diagonal f := by
  simp [Matrix.diagonal_mul_diagonal, mul_comm]

/-- Tr([A,B]) = 0. -/
theorem trace_commutator_zero (A B : Matrix (Fin n) (Fin n) ℝ) :
    (commutator A B).trace = 0 := by
  have h := Matrix.trace_mul_comm A B
  have hsub : (A * B - B * A).trace = (A * B).trace - (B * A).trace := by
    simp [Matrix.trace]
  rw [commutator, hsub, h, sub_self]

