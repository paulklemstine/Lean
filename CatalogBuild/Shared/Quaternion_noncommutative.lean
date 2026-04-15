/-! # CatalogBuild.Shared.Quaternion_noncommutative

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 4
-/

import Mathlib

/-- Quaternion multiplication is not commutative. -/
theorem quaternion_noncommutative :
    ∃ (a b : Quaternion ℝ), a * b ≠ b * a := by
  use ⟨0, 1, 0, 0⟩, ⟨0, 0, 1, 0⟩
  simp [Quaternion.ext_iff]
  norm_num


/-- The quaternion norm is multiplicative: N(ab) = N(a)·N(b).
This is the algebraic foundation of quaternion-based factoring. -/
theorem quaternion_norm_sq_mul (a b : Quaternion ℝ) :
    Quaternion.normSq (a * b) = Quaternion.normSq a * Quaternion.normSq b :=
  map_mul Quaternion.normSq a b


/-- The explicit formula for quaternion multiplication. -/
theorem quaternion_mul_components (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℝ) :
    (⟨a₁, a₂, a₃, a₄⟩ : Quaternion ℝ) * ⟨b₁, b₂, b₃, b₄⟩ =
    ⟨a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄,
     a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃,
     a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂,
     a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁⟩ := by
  ext <;> simp <;> ring


/-- Quaternion norm is non-negative. -/
theorem quaternion_normSq_nonneg (q : Quaternion ℝ) :
    0 ≤ Quaternion.normSq q := by
  simp [Quaternion.normSq_def']
  positivity

