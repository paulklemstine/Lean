import Mathlib

/-! # CatalogBuild.Bridges.EntropyTropicalDuality

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 30
-/

noncomputable section

open Real

/-- The two-argument log-sum-exp ("soft max"). -/
def lse2 (x y : ℝ) : ℝ := Real.log (Real.exp x + Real.exp y)

/-- LogSumExp is associative. -/
theorem lse2_assoc (x y z : ℝ) :
    lse2 (lse2 x y) z = lse2 x (lse2 y z) := by
  simp only [lse2]
  congr 1
  rw [Real.exp_log (by positivity), Real.exp_log (by positivity)]
  ring

/-- The fundamental lower bound: max ≤ LSE. -/
theorem lse2_ge_max (x y : ℝ) : max x y ≤ lse2 x y := by
  rw [lse2, max_le_iff]
  constructor <;> rw [Real.le_log_iff_exp_le (by positivity)]
  · linarith [exp_pos y]
  · linarith [exp_pos x]

/-- The fundamental upper bound: LSE ≤ max + log 2. -/
theorem lse2_le_max_add_log2 (x y : ℝ) : lse2 x y ≤ max x y + Real.log 2 := by
  rw [lse2, Real.log_le_iff_le_exp (by positivity), Real.exp_add,
      Real.exp_log (by positivity : (0:ℝ) < 2)]
  have hx := le_max_left x y
  have hy := le_max_right x y
  linarith [Real.exp_le_exp.2 hx, Real.exp_le_exp.2 hy]

/-- The tropical-entropy gap is bounded by [0, log 2]. -/
theorem lse2_tropical_error (x y : ℝ) :
    0 ≤ lse2 x y - max x y ∧ lse2 x y - max x y ≤ Real.log 2 := by
  constructor
  · linarith [lse2_ge_max x y]
  · linarith [lse2_le_max_add_log2 x y]

/-- Softmax function for two arguments. -/
def softmax2_fst (x y : ℝ) : ℝ := Real.exp x / (Real.exp x + Real.exp y)

/-- [Section: # CatalogBuild.Bridges.EntropyTropicalDuality
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 30] -/
def softmax2_snd (x y : ℝ) : ℝ := Real.exp y / (Real.exp x + Real.exp y)

/-- Softmax components are non-negative. -/
theorem softmax2_fst_nonneg (x y : ℝ) : 0 ≤ softmax2_fst x y :=
  div_nonneg (le_of_lt (exp_pos x)) (by positivity)

/-- [Section: # CatalogBuild.Bridges.EntropyTropicalDuality
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 30] -/
theorem softmax2_snd_nonneg (x y : ℝ) : 0 ≤ softmax2_snd x y :=
  div_nonneg (le_of_lt (exp_pos y)) (by positivity)

/-- Softmax components sum to 1. -/
theorem softmax2_sum_one (x y : ℝ) :
    softmax2_fst x y + softmax2_snd x y = 1 := by
  simp only [softmax2_fst, softmax2_snd]
  rw [div_add_div_same, div_self (ne_of_gt (by positivity : (0:ℝ) < exp x + exp y))]

/-- Softmax components are at most 1. -/
theorem softmax2_fst_le_one (x y : ℝ) : softmax2_fst x y ≤ 1 := by
  rw [softmax2_fst, div_le_one (by positivity)]
  linarith [exp_pos y]

theorem softmax2_monotone (x y : ℝ) (h : x ≤ y) :
    softmax2_fst x y ≤ softmax2_snd x y := by
  exact div_le_div_of_nonneg_right ( Real.exp_le_exp.mpr h ) ( by positivity )

/-- At equal inputs, softmax gives uniform distribution. -/
theorem softmax2_equal (x : ℝ) : softmax2_fst x x = 1 / 2 := by
  simp only [softmax2_fst]
  rw [← two_mul]
  field_simp

theorem softmax_respects_order (x y : ℝ) (h : x < y) :
    softmax2_fst x y < softmax2_snd x y := by
  exact div_lt_div_iff_of_pos_right ( by positivity ) |>.2 ( Real.exp_lt_exp.2 h )

/-- The self-information function: -x·log(x). -/
def negXLogX (x : ℝ) : ℝ := -(x * Real.log x)

/-- At p = 0, the self-information is 0. -/
theorem negXLogX_zero : negXLogX 0 = 0 := by simp [negXLogX]

/-- At p = 1, the self-information is 0. -/
theorem negXLogX_one : negXLogX 1 = 0 := by simp [negXLogX]

/-- Young's inequality: x·y ≤ x²/2 + y²/2. -/
theorem young_ineq_sq_half (x y : ℝ) :
    x * y ≤ x ^ 2 / 2 + y ^ 2 / 2 := by nlinarith [sq_nonneg (x - y)]

/-- The conjugate of x²/2 is bounded by y²/2. -/
theorem sq_half_self_dual_bound (x y : ℝ) :
    x * y - x ^ 2 / 2 ≤ y ^ 2 / 2 := by nlinarith [sq_nonneg (x - y)]

/-- A function is tropically convex if f(max(x,y)) ≤ max(f(x), f(y)). -/
def TropicallyConvex (f : ℝ → ℝ) : Prop :=
  ∀ x y, f (max x y) ≤ max (f x) (f y)

theorem monotone_tropically_convex {f : ℝ → ℝ} (hf : Monotone f) :
    TropicallyConvex f := by
  intro x y; cases le_total x y <;> simp +decide [ * ] ;

/-- The identity function is tropically convex. -/
theorem id_tropically_convex : TropicallyConvex id := by
  intro x y; simp

theorem tropically_convex_comp {f g : ℝ → ℝ}
    (hf : TropicallyConvex f) (hg : Monotone g) :
    TropicallyConvex (g ∘ f) := by
  intro x y; cases max_cases x y <;> simp +decide [ * ] ;

/-- Temperature-scaled LogSumExp. -/
def lse2_temp (T : ℝ) (x y : ℝ) : ℝ := T * Real.log (Real.exp (x/T) + Real.exp (y/T))

/-- At T = 1, temperature-scaled LSE reduces to standard LSE. -/
theorem lse2_temp_one (x y : ℝ) : lse2_temp 1 x y = lse2 x y := by
  simp [lse2_temp, lse2]

/-- Gibbs free energy for two states. -/
def gibbsFreeEnergy (T : ℝ) (E₁ E₂ : ℝ) : ℝ :=
  -T * Real.log (Real.exp (-E₁/T) + Real.exp (-E₂/T))

/-- Gibbs free energy at T=1 for equal energies: F = E - log 2. -/
theorem gibbs_equal_energies (E : ℝ) :
    gibbsFreeEnergy 1 E E = E - Real.log 2 := by
  simp only [gibbsFreeEnergy, neg_mul, one_mul, div_one]
  rw [← two_mul, Real.log_mul (by positivity) (exp_pos (-E)).ne']
  rw [Real.log_exp]; ring

/-- Binary log is positive. -/
theorem info_content_of_uniform_pair : Real.log 2 > 0 := Real.log_pos one_lt_two

theorem uniform_entropy_eq_log (n : ℕ) (hn : 1 ≤ n) :
    (n : ℝ) * (-(1 / (n : ℝ)) * Real.log (1 / (n : ℝ))) = Real.log n := by
  simp +zetaDelta at *;
  rw [ ← mul_assoc, mul_inv_cancel₀ ( by positivity ), one_mul ]

/-- The dequantization cost: the error from replacing quantum with tropical. -/
theorem dequantization_cost (x y : ℝ) :
    0 ≤ lse2 x y - max x y ∧ lse2 x y - max x y ≤ Real.log 2 :=
  lse2_tropical_error x y

/-- ReLU ∘ softmax preserves non-negativity. -/
theorem relu_softmax_nonneg (x y : ℝ) :
    0 ≤ max (softmax2_fst x y) 0 := le_max_right _ _

end