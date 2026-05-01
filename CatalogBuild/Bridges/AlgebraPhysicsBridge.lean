/-! # CatalogBuild.Bridges.AlgebraPhysicsBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 3
-/

import Mathlib

noncomputable section

/-- [Section: # Algebra-Physics Bridge: Hilbert-Schmidt Norm
Formal bridge between Algebra and Physics domains.] -/
def hilbertSchmidtNorm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Real.sqrt (∑ i : Fin n, ∑ j : Fin n, A i j ^ 2)


theorem hilbertSchmidt_norm_nonneg {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
    0 ≤ hilbertSchmidtNorm A := by
  unfold hilbertSchmidtNorm; apply Real.sqrt_nonneg


theorem hilbertSchmidt_norm_zero_matrix {n : ℕ} :
    hilbertSchmidtNorm (0 : Matrix (Fin n) (Fin n) ℝ) = 0 := by
  unfold hilbertSchmidtNorm
  have : ∑ i : Fin n, ∑ j : Fin n, (0 : Matrix (Fin n) (Fin n) ℝ) i j ^ 2 = 0 := by
    simp [Matrix.zero_apply]
  rw [this, Real.sqrt_zero]


end
