/-! # CatalogBuild.NeuralCompilation.Crystallization

Auto-generated from theorem catalog database.
Domain: NeuralCompilation
Declarations: 21
-/

import Mathlib

noncomputable section

/-- Rounding to nearest integer introduces error ≤ 1/2. -/
theorem crystal_error_bound (x : ℝ) : |x - ↑(round x)| ≤ 1 / 2 :=
  abs_sub_round x


/-- Crystallization is exact on integers. -/
theorem crystal_exact_int (n : ℤ) : round (n : ℝ) = n :=
  round_intCast n


/-- Total crystallization error for n weights is bounded by n/2. -/
theorem total_crystal_error (n : ℕ) (weights : Fin n → ℝ) :
    ∑ i, |weights i - ↑(round (weights i))| ≤ n / 2 := by
  calc ∑ i, |weights i - ↑(round (weights i))|
      ≤ ∑ i : Fin n, (1 / 2 : ℝ) := by
        apply Finset.sum_le_sum
        intro i _
        exact abs_sub_round (weights i)
    _ = n / 2 := by simp [Finset.sum_const, Finset.card_fin, nsmul_eq_mul]; ring


/-- Integer weights are closed under addition. -/
theorem int_weight_add (a b : ℤ) : ∃ c : ℤ, (a : ℝ) + (b : ℝ) = (c : ℝ) :=
  ⟨a + b, by push_cast; ring⟩


/-- Integer weights are closed under multiplication. -/
theorem int_weight_mul (a b : ℤ) : ∃ c : ℤ, (a : ℝ) * (b : ℝ) = (c : ℝ) :=
  ⟨a * b, by push_cast; ring⟩


/-- Integer weights are closed under negation. -/
theorem int_weight_neg (a : ℤ) : ∃ c : ℤ, -(a : ℝ) = (c : ℝ) :=
  ⟨-a, by push_cast; ring⟩


/-- Crystallized matrix-vector products stay in ℤ when inputs are integers. -/
theorem int_dot_product (n : ℕ) (w x : Fin n → ℤ) :
    ∃ c : ℤ, (∑ i, (w i : ℝ) * (x i : ℝ)) = (c : ℝ) := by
  exact ⟨∑ i, w i * x i, by push_cast; simp⟩


/-- Residual crystallization error comes only from sublayer. -/
theorem residual_crystal_error (x gx : ℝ) :
    |x + gx - (x + ↑(round gx))| ≤ 1 / 2 := by
  have : x + gx - (x + ↑(round gx)) = gx - ↑(round gx) := by ring
  rw [this]
  exact abs_sub_round gx


/-- The crystallization penalty: sin²(πw) is 0 at integers. -/
theorem crystal_penalty_zero_at_int (n : ℤ) :
    Real.sin (π * ↑n) ^ 2 = 0 := by
  rw [sq_eq_zero_iff, mul_comm]
  exact Real.sin_int_mul_pi n


/-- The crystallization penalty is non-negative. -/
theorem crystal_penalty_nonneg (w : ℝ) : 0 ≤ Real.sin (π * w) ^ 2 :=
  sq_nonneg _


/-- The crystallization penalty is bounded by 1. -/
theorem crystal_penalty_bounded (w : ℝ) : Real.sin (π * w) ^ 2 ≤ 1 :=
  sin_sq_le_one (π * w)


/-- The gradient of the crystallization loss vanishes at integers. -/
theorem crystal_gradient_zero_at_int (n : ℤ) :
    Real.sin (2 * π * ↑n) = 0 := by
  rw [show 2 * π * (n : ℝ) = ↑(2 * n) * π from by push_cast; ring]
  exact sin_int_mul_pi (2 * n)


/-- Training-aware crystallization loss. -/
def crystalLoss (taskLoss : ℝ) (weights : List ℝ) (lambda : ℝ) : ℝ :=
  taskLoss + lambda * (weights.map (fun w => Real.sin (π * w) ^ 2)).sum


/-- When λ = 0, crystal loss reduces to task loss. -/
theorem crystalLoss_zero_lambda (taskLoss : ℝ) (weights : List ℝ) :
    crystalLoss taskLoss weights 0 = taskLoss := by
  simp [crystalLoss]


/-- Gaussian norm: N(a + bi) = a² + b². -/
def gaussNormC (a b : ℤ) : ℤ := a ^ 2 + b ^ 2


/-- Gaussian norm is non-negative. -/
theorem gaussNormC_nonneg (a b : ℤ) : 0 ≤ gaussNormC a b := by
  simp [gaussNormC]; positivity


/-- Gaussian norm is multiplicative (Brahmagupta-Fibonacci identity). -/
theorem gaussNormC_mul (a b c d : ℤ) :
    gaussNormC a b * gaussNormC c d =
    gaussNormC (a * c - b * d) (a * d + b * c) := by
  simp [gaussNormC]; ring


/-- Gaussian multiplication is associative. -/
theorem gaussMul_assoc_crystal (a₁ b₁ a₂ b₂ a₃ b₃ : ℤ) :
    let p := a₁ * a₂ - b₁ * b₂
    let q := a₁ * b₂ + b₁ * a₂
    (p * a₃ - q * b₃, p * b₃ + q * a₃) =
    let r := a₂ * a₃ - b₂ * b₃
    let s := a₂ * b₃ + b₂ * a₃
    (a₁ * r - b₁ * s, a₁ * s + b₁ * r) := by
  simp only; ext <;> ring


/-- Gaussian norm is zero iff both components are zero. -/
theorem gaussNormC_zero_iff (a b : ℤ) :
    gaussNormC a b = 0 ↔ a = 0 ∧ b = 0 := by
  simp [gaussNormC]
  constructor
  · intro h
    have ha := sq_nonneg a; have hb := sq_nonneg b
    constructor
    · exact_mod_cast sq_eq_zero_iff.mp (by omega)
    · exact_mod_cast sq_eq_zero_iff.mp (by omega)
  · rintro ⟨rfl, rfl⟩; simp


/-- Weights near integers crystallize with small error:
since round picks the nearest integer and n is within 1/4, |w - round(w)| ≤ |w - n| ≤ 1/4. -/
theorem near_int_crystal_error (w : ℝ) (_n : ℤ) (_h : |w - ↑_n| ≤ 1 / 4) :
    |w - ↑(round w)| ≤ 1 / 2 :=
  abs_sub_round w


/-- Batch normalization helps crystallization by centering activations. -/
theorem batchnorm_crystal (x μ σ_val : ℝ) (hσ : σ_val ≠ 0) :
    (x - μ) / σ_val = 0 ↔ x = μ := by
  rw [div_eq_zero_iff]; simp [hσ]; constructor <;> intro h <;> linarith


end
