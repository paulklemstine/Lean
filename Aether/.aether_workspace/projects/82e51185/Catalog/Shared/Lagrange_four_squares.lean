import Mathlib

/-! # CatalogBuild.Shared.Lagrange_four_squares

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 1
-/

/-- [Section: # CatalogBuild.Shared.Lagrange_four_squares
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 1] -/
theorem lagrange_four_squares (n : ℕ) :
    ∃ a b c d : ℤ, (n : ℤ) = a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 := by
  have := Nat.sum_four_squares n;
  exact ⟨ this.choose, this.choose_spec.choose, this.choose_spec.choose_spec.choose, this.choose_spec.choose_spec.choose_spec.choose, mod_cast this.choose_spec.choose_spec.choose_spec.choose_spec.symm ⟩

