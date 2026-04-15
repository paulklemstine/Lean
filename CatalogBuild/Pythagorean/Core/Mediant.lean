/-! # CatalogBuild.Pythagorean.Core.Mediant

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 3
-/

import Mathlib

theorem exists_rat_between {a b : ℝ} (hab : a < b) :
    ∃ r : ℚ, a < (r : ℝ) ∧ (r : ℝ) < b := by
  exact exists_rat_btwn hab

/-- Rational numbers are dense in ℝ (Mathlib version). -/

theorem rat_dense_in_real : DenseRange ((↑) : ℚ → ℝ) := by
  exact Rat.denseRange_cast

/-
PROBLEM
For any real number and any ε > 0, there exists a rational within ε.

PROVIDED SOLUTION
Use the density of rationals in reals. The ball of radius ε around x is open and nonempty, and since ℚ is dense in ℝ, there exists a rational in this ball. Alternatively use Metric.denseRange_iff or exists_rat_btwn on the interval (x - ε, x + ε).
-/

theorem rat_approx (x : ℝ) {ε : ℝ} (hε : 0 < ε) :
    ∃ r : ℚ, |x - (r : ℝ)| < ε := by
  obtain ⟨ r, hr ⟩ := exists_rat_btwn ( sub_lt_self x hε ) ; exact ⟨ r, abs_lt.mpr ⟨ by linarith, by linarith ⟩ ⟩ ;
