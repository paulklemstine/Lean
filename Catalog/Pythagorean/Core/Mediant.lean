import Mathlib

/-! # CatalogBuild.Pythagorean.Core.Mediant

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 3
-/

/-- [Section: # CatalogBuild.Pythagorean.Core.Mediant
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 3] -/
theorem exists_rat_between {a b : ℝ} (hab : a < b) :
    ∃ r : ℚ, a < (r : ℝ) ∧ (r : ℝ) < b := by
  exact exists_rat_btwn hab

/-- Rational numbers are dense in ℝ (Mathlib version). -/
theorem rat_dense_in_real : DenseRange ((↑) : ℚ → ℝ) := by
  exact Rat.denseRange_cast

/-- [Section: # CatalogBuild.Pythagorean.Core.Mediant
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 3] -/
theorem rat_approx (x : ℝ) {ε : ℝ} (hε : 0 < ε) :
    ∃ r : ℚ, |x - (r : ℝ)| < ε := by
  obtain ⟨ r, hr ⟩ := exists_rat_btwn ( sub_lt_self x hε ) ; exact ⟨ r, abs_lt.mpr ⟨ by linarith, by linarith ⟩ ⟩ ;