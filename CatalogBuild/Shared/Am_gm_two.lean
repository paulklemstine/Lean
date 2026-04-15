/-! # CatalogBuild.Shared.Am_gm_two

Auto-generated from theorem catalog database.
Domain: Analysis
Declarations: 1
-/

import Mathlib

theorem am_gm_two (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    Real.sqrt (a * b) ≤ (a + b) / 2 := by
      exact Real.sqrt_le_iff.mpr ⟨ by positivity, by linarith [ sq_nonneg ( a - b ) ] ⟩

/-
PROBLEM
Cauchy-Schwarz inequality (finite sum form).

PROVIDED SOLUTION
Use Finset.inner_mul_le_norm_sq or inner_mul_le_norm_mul_sq from Mathlib applied to EuclideanSpace.
-/
