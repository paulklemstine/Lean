/-! # CatalogBuild.MachineLearning.Neural.TropicalConversion

Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 11
-/

import Mathlib

noncomputable section

theorem tropMul'_comm (a b : ℝ) : tropMul' a b = tropMul' b a := add_comm a b


theorem tropMul'_assoc (a b c : ℝ) :
    tropMul' (tropMul' a b) c = tropMul' a (tropMul' b c) := by
  simp [tropMul', add_assoc]


/-- Conversion error between two functions. -/
def convError (f g : ℝ → ℝ) (x : ℝ) : ℝ := |f x - g x|


/-- Conversion error is nonneg. -/
theorem convError_nonneg (f g : ℝ → ℝ) (x : ℝ) : 0 ≤ convError f g x :=
  abs_nonneg _


/-- Conversion error is zero when functions agree. -/
theorem convError_zero_of_eq (f g : ℝ → ℝ) (x : ℝ) (h : f x = g x) :
    convError f g x = 0 := by simp [convError, h]


/-- Conversion error is symmetric. -/
theorem convError_symm (f g : ℝ → ℝ) (x : ℝ) :
    convError f g x = convError g f x := abs_sub_comm _ _


/-- Triangle inequality for conversion errors through an intermediate. -/
theorem convError_triangle (f g h : ℝ → ℝ) (x : ℝ) :
    convError f h x ≤ convError f g x + convError g h x := by
  simp only [convError]
  exact abs_sub_le _ _ _


/-- Converting a ReLU layer to tropical form is exact (zero error). -/
theorem relu_conversion_exact (x : ℝ) :
    convError reluFn (fun y => tropAdd' y 0) x = 0 := by
  simp [convError, reluFn, tropAdd']

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Quantization Error
-- ═══════════════════════════════════════════════════════════════


/-- Quantization rounds to the nearest integer. -/
theorem quant_error_bound' (w : ℝ) : |w - ↑(round w)| ≤ 1 / 2 :=
  abs_sub_round w


/-- Total quantization error for n weights. -/
theorem total_quant_error' (n : ℕ) (ws : Fin n → ℝ) :
    ∑ i, |ws i - ↑(round (ws i))| ≤ n / 2 := by
  calc ∑ i, |ws i - ↑(round (ws i))|
      ≤ ∑ _i : Fin n, (1 / 2 : ℝ) := by
        apply Finset.sum_le_sum; intro i _; exact abs_sub_round _
    _ = n / 2 := by simp [Finset.sum_const, nsmul_eq_mul]; ring


theorem softmax_concentration (s₁ s₂ : ℝ) (h : s₁ < s₂) (β : ℝ) (hβ : 0 < β) :
    1 / 2 < exp (β * s₂) / (exp (β * s₁) + exp (β * s₂)) := by
  rw [ div_lt_div_iff₀ ] <;> nlinarith [ Real.exp_pos ( β * s₁ ), Real.exp_lt_exp.2 ( mul_lt_mul_of_pos_left h hβ ) ]


end
