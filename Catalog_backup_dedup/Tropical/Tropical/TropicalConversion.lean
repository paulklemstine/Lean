import Mathlib

/-! # Tropical Neural Network Conversion — Formal Foundations

This file formalizes the core mathematical guarantees for converting
classical neural network layers to tropical (max-plus) representations.

## Key Results

1. **`relu_is_tropical`** — ReLU(x) = max(x, 0) is a tropical operation.
2. **`tropMul_distrib_left`** — Tropical multiplication distributes over tropical addition.
3. **`relu_conversion_exact`** — Converting ReLU layers to tropical form is exact.
4. **`softmax_concentration`** — Softmax concentrates on the argmax as β → ∞.
5. **`convError_triangle`** — Composition errors compose via triangle inequality.
-/

noncomputable section

open Real Finset BigOperators

-- ═══════════════════════════════════════════════════════════════
-- Section 1: Tropical Semiring Operations
-- ═══════════════════════════════════════════════════════════════

/-- Tropical addition is max. -/
def tropAdd' (a b : ℝ) : ℝ := max a b

/-- Tropical multiplication is classical addition. -/
def tropMul' (a b : ℝ) : ℝ := a + b

theorem tropAdd'_comm (a b : ℝ) : tropAdd' a b = tropAdd' b a := max_comm a b

theorem tropAdd'_assoc (a b c : ℝ) :
    tropAdd' (tropAdd' a b) c = tropAdd' a (tropAdd' b c) := max_assoc _ _ _

theorem tropMul'_comm (a b : ℝ) : tropMul' a b = tropMul' b a := add_comm a b

theorem tropMul'_assoc (a b c : ℝ) :
    tropMul' (tropMul' a b) c = tropMul' a (tropMul' b c) := by
  simp [tropMul', add_assoc]

/-- Tropical multiplication distributes over tropical addition. -/
theorem tropMul'_distrib_left (a b c : ℝ) :
    tropMul' a (tropAdd' b c) = tropAdd' (tropMul' a b) (tropMul' a c) := by
  simp [tropMul', tropAdd']
  exact (max_add_add_left a b c).symm

-- ═══════════════════════════════════════════════════════════════
-- Section 2: ReLU is Tropical
-- ═══════════════════════════════════════════════════════════════

/-- ReLU function. -/
def reluFn (x : ℝ) : ℝ := max x 0

/-- ReLU is a tropical addition with the tropical additive identity. -/
theorem relu_is_tropical (x : ℝ) : reluFn x = tropAdd' x 0 := by
  simp [reluFn, tropAdd']

/-- ReLU is nonneg. -/
theorem relu_nonneg (x : ℝ) : 0 ≤ reluFn x := le_max_right x 0

/-- ReLU is idempotent. -/
theorem relu_idempotent (x : ℝ) : reluFn (reluFn x) = reluFn x := by
  simp [reluFn, max_def]
  split_ifs <;> simp_all

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Conversion Error Bounds
-- ═══════════════════════════════════════════════════════════════

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

/-
═══════════════════════════════════════════════════════════════
Section 5: Softmax Concentration (Tropical Limit)
═══════════════════════════════════════════════════════════════

Softmax converges to hardmax (tropical) as temperature → 0.
    For distinct scores, the argmax gets probability → 1.
    Here: exp(β·s₂) / (exp(β·s₁) + exp(β·s₂)) > 1/2 when s₂ > s₁.
-/
theorem softmax_concentration (s₁ s₂ : ℝ) (h : s₁ < s₂) (β : ℝ) (hβ : 0 < β) :
    1 / 2 < exp (β * s₂) / (exp (β * s₁) + exp (β * s₂)) := by
  rw [ div_lt_div_iff₀ ] <;> nlinarith [ Real.exp_pos ( β * s₁ ), Real.exp_lt_exp.2 ( mul_lt_mul_of_pos_left h hβ ) ]

end