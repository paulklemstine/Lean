import Mathlib

/-! # CatalogBuild.Pythagorean.Quadruples.FiveTuples

Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 4
-/

/-- Peel identity channel 1: (a₅ - a₁)(a₅ + a₁) = a₂² + a₃² + a₄² -/
theorem five_tuple_peel_first (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (h : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅) :
    (a₅ - a₁) * (a₅ + a₁) = a₂^2 + a₃^2 + a₄^2 := by
  unfold IsPythagorean5Tuple at h; nlinarith

/-- Peel identity channel 2: (a₅ - a₂)(a₅ + a₂) = a₁² + a₃² + a₄² -/
theorem five_tuple_peel_second (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (h : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅) :
    (a₅ - a₂) * (a₅ + a₂) = a₁^2 + a₃^2 + a₄^2 := by
  unfold IsPythagorean5Tuple at h; nlinarith

/-- Peel identity channel 3: (a₅ - a₃)(a₅ + a₃) = a₁² + a₂² + a₄² -/
theorem five_tuple_peel_third (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (h : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅) :
    (a₅ - a₃) * (a₅ + a₃) = a₁^2 + a₂^2 + a₄^2 := by
  unfold IsPythagorean5Tuple at h; nlinarith

/-- Peel identity channel 4: (a₅ - a₄)(a₅ + a₄) = a₁² + a₂² + a₃² -/
theorem five_tuple_peel_fourth (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (h : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅) :
    (a₅ - a₄) * (a₅ + a₄) = a₁^2 + a₂^2 + a₃^2 := by
  unfold IsPythagorean5Tuple at h; nlinarith

