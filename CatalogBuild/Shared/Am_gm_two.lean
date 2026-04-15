/-! # CatalogBuild.Shared.Am_gm_two

Auto-generated from theorem catalog database.
Domain: Analysis
Declarations: 1
-/

import Mathlib

/-- [Section: ## Section 4: Inequalities] -/
theorem am_gm_two (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    Real.sqrt (a * b) ≤ (a + b) / 2 := by
      exact Real.sqrt_le_iff.mpr ⟨ by positivity, by linarith [ sq_nonneg ( a - b ) ] ⟩

