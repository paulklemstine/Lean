import Mathlib

/-! # CatalogBuild.Shared.QuatNorm

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3
-/

/-- The norm of a quaternion (a, b, c, d) is a² + b² + c² + d². -/
def quatNorm (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2

/-- [Section: # CatalogBuild.Shared.QuatNorm
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 3] -/
theorem quatNorm_zero_iff (a b c d : ℤ) :
    quatNorm a b c d = 0 ↔ a = 0 ∧ b = 0 ∧ c = 0 ∧ d = 0 := by
  unfold quatNorm
  constructor
  · intro h; exact ⟨by nlinarith, by nlinarith, by nlinarith, by nlinarith⟩
  · rintro ⟨rfl, rfl, rfl, rfl⟩; ring

/-- [Section: # CatalogBuild.Shared.QuatNorm
Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3] -/
theorem quatNorm_nonneg (a b c d : ℤ) : 0 ≤ quatNorm a b c d := by
  unfold quatNorm; positivity