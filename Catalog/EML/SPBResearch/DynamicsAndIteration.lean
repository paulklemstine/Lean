import Mathlib

/-! # SPB Dynamics and Iteration Theory -/

noncomputable section

open Real

/-- The SPB operator -/
def spbDyn (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The n-th orbit point starting from 0 -/
def spbOrbitDyn (a : ℝ) (n : ℕ) : ℝ := tan (↑n * arctan a)

/-- The 0-th iterate is 0 -/
theorem spbOrbitDyn_zero (a : ℝ) : spbOrbitDyn a 0 = 0 := by simp [spbOrbitDyn]

/-- The 1st iterate is a -/
theorem spbOrbitDyn_one (a : ℝ) : spbOrbitDyn a 1 = a := by simp [spbOrbitDyn]

/-- The SPB has no fixed points when a ≠ 0 -/
theorem spb_no_fixed_pts (a x : ℝ) (ha : a ≠ 0) (hd : 1 - x * a ≠ 0) :
    spbDyn x a ≠ x := by
  unfold spbDyn; intro heq
  have : (x + a) = x * (1 - x * a) := by rw [div_eq_iff hd] at heq; linarith
  have : a * (1 + x ^ 2) = 0 := by nlinarith
  have := mul_eq_zero.mp this
  rcases this with h | h
  · exact ha h
  · linarith [sq_nonneg x]

/-- The SPB vector field is always positive -/
theorem spb_vector_field_pos (x : ℝ) : (1 : ℝ) + x ^ 2 > 0 := by positivity

/-- The flow at time t -/
def spbFlow (x₀ t : ℝ) : ℝ := tan (arctan x₀ + t)

/-- The flow at t=0 returns to x₀ -/
theorem spbFlow_zero (x₀ : ℝ) : spbFlow x₀ 0 = x₀ := by simp [spbFlow]

/-- SPB doubling: spb(x,x) = 2x/(1-x²) -/
theorem spb_doubling (x : ℝ) : spbDyn x x = 2 * x / (1 - x ^ 2) := by
  unfold spbDyn; ring

/-- SPB tripling formula -/
theorem spb_tripling (x : ℝ) (h1 : 1 - x ^ 2 ≠ 0) (h2 : 1 - spbDyn x x * x ≠ 0) :
    spbDyn (spbDyn x x) x = (3 * x - x ^ 3) / (1 - 3 * x ^ 2) := by
  unfold spbDyn at *; field_simp at *; ring

/-- The derivative of T_a(x) = spb(x,a) is (1+a²)/(1-xa)² -/
theorem spb_deriv_pos' (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + a ^ 2) / (1 - x * a) ^ 2 > 0 := by positivity

end
