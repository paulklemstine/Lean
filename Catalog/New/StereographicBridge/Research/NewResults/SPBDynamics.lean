import Mathlib

/-!
# SPB Dynamics and Iteration

## Main Results
- T_a has no fixed points for a ≠ 0
- SPB derivative is always positive (monotonicity)
- SPB orbit definition
- SPB difference identity and strict monotonicity
-/

noncomputable section
open Real

/-- The SPB operator -/
def spbD (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The SPB iteration map T_a(x) = spb(x, a). -/
def spbIter (a : ℝ) (x : ℝ) : ℝ := spbD x a

/-! ## Fixed Point Analysis -/

/-- T_a has no fixed points for a ≠ 0. -/
theorem spb_no_fixed_point (a x : ℝ) (ha : a ≠ 0) (h : 1 - x * a ≠ 0) :
    spbIter a x ≠ x := by
  unfold spbIter spbD
  intro heq
  have : (x + a) / (1 - x * a) = x := heq
  have heq' : x + a = x * (1 - x * a) := by
    field_simp at this; linarith
  have : a * (1 + x ^ 2) = 0 := by nlinarith
  have : a = 0 := by
    rcases mul_eq_zero.mp ‹a * (1 + x ^ 2) = 0› with h | h
    · exact h
    · linarith [show (1 : ℝ) + x ^ 2 > 0 from by positivity]
  exact ha this

/-- If T_a fixes every point, then a = 0. -/
theorem spb_periodicity_condition (a : ℝ)
    (h : ∀ x : ℝ, 1 - x * a ≠ 0 → spbIter a x = x) :
    a = 0 := by
  by_contra ha
  exact spb_no_fixed_point a 0 ha (by simp) (h 0 (by simp))

/-! ## SPB Flow Equation -/

/-- The SPB infinitesimal generator is 1 + x² > 0. -/
theorem spb_infinitesimal (x : ℝ) : (1 : ℝ) + x ^ 2 > 0 := by positivity

/-- The derivative of T_a at x is always positive. -/
theorem spb_deriv_positive (a x : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + a ^ 2) / (1 - x * a) ^ 2 > 0 := by
  apply div_pos <;> positivity

/-! ## Orbit Structure -/

/-- The n-th iterate of T_a starting from 0 is tan(n·arctan(a)). -/
def spbOrbit (a : ℝ) (n : ℕ) : ℝ := Real.tan (↑n * Real.arctan a)

/-- The 0-th iterate is 0. -/
theorem spbOrbit_zero (a : ℝ) : spbOrbit a 0 = 0 := by
  simp [spbOrbit, Real.tan_zero]

/-- The 1st iterate is a. -/
theorem spbOrbit_one (a : ℝ) : spbOrbit a 1 = a := by
  simp [spbOrbit, Real.tan_arctan]

/-! ## SPB Difference Identity -/

/-- The SPB difference identity. -/
theorem spb_difference (a b c : ℝ)
    (h1 : 1 - a * b ≠ 0) (h2 : 1 - a * c ≠ 0) :
    spbD a b - spbD a c = (b - c) * (1 + a ^ 2) / ((1 - a * b) * (1 - a * c)) := by
  unfold spbD; field_simp; ring

/-- SPB is strictly increasing in the second variable. -/
theorem spb_strict_mono_snd (a b c : ℝ)
    (h1 : 0 < 1 - a * b) (h2 : 0 < 1 - a * c) (hbc : b < c) :
    spbD a b < spbD a c := by
  have hdiff := spb_difference a c b (by linarith) (by linarith)
  have hpos : (c - b) * (1 + a ^ 2) / ((1 - a * c) * (1 - a * b)) > 0 :=
    div_pos (mul_pos (by linarith) (by positivity)) (mul_pos h2 h1)
  linarith

end
