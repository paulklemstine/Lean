import Mathlib

/-! # CatalogBuild.EML.SPBDynamics

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 8
-/

noncomputable section

/-- The SPB operator -/
def spbD (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The SPB iteration map T_a(x) = spb(x, a). -/
def spbIter (a : ℝ) (x : ℝ) : ℝ := spbD x a

/-- If T_a fixes every point, then a = 0. -/
theorem spb_periodicity_condition (a : ℝ)
    (h : ∀ x : ℝ, 1 - x * a ≠ 0 → spbIter a x = x) :
    a = 0 := by
  by_contra ha
  exact spb_no_fixed_point a 0 ha (by simp) (h 0 (by simp))

/-- The SPB infinitesimal generator is 1 + x² > 0. -/
theorem spb_infinitesimal (x : ℝ) : (1 : ℝ) + x ^ 2 > 0 := by positivity

/-- The n-th iterate of T_a starting from 0 is tan(n·arctan(a)). -/
def spbOrbit (a : ℝ) (n : ℕ) : ℝ := Real.tan (↑n * Real.arctan a)

/-- The 0-th iterate is 0. -/
theorem spbOrbit_zero (a : ℝ) : spbOrbit a 0 = 0 := by
  simp [spbOrbit, Real.tan_zero]

/-- The 1st iterate is a. -/
theorem spbOrbit_one (a : ℝ) : spbOrbit a 1 = a := by
  simp [spbOrbit, Real.tan_arctan]

/-- SPB is strictly increasing in the second variable. -/
theorem spb_strict_mono_snd (a b c : ℝ)
    (h1 : 0 < 1 - a * b) (h2 : 0 < 1 - a * c) (hbc : b < c) :
    spbD a b < spbD a c := by
  have hdiff := spb_difference a c b (by linarith) (by linarith)
  have hpos : (c - b) * (1 + a ^ 2) / ((1 - a * c) * (1 - a * b)) > 0 :=
    div_pos (mul_pos (by linarith) (by positivity)) (mul_pos h2 h1)
  linarith

end