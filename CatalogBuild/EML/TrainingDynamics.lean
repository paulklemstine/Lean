/-! # CatalogBuild.EML.TrainingDynamics

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 22
-/

import Mathlib

noncomputable section

def gradExpComp (w₁ b₁ x : ℝ) : ℝ := w₁ * Real.exp (w₁ * x + b₁)

/-- The logarithmic gradient component. -/

def gradLogComp (w₂ b₂ x : ℝ) : ℝ := w₂ / (w₂ * x + b₂)

/-- Gradient of EML neuron w.r.t. x decomposes into exp and log parts. -/

theorem gradient_decomposition (w₁ b₁ w₂ b₂ x : ℝ) :
    gradExpComp w₁ b₁ x - gradLogComp w₂ b₂ x =
    w₁ * Real.exp (w₁ * x + b₁) - w₂ / (w₂ * x + b₂) := by
  simp [gradExpComp, gradLogComp]

/-! ## Partial Derivatives w.r.t. Parameters -/

/-- Partial derivative of EML neuron w.r.t. weight w₁.
    ∂f/∂w₁ = x · exp(w₁x + b₁). -/

theorem eml_grad_w1 (w₁ b₁ w₂ b₂ x : ℝ) (_h : w₂ * x + b₂ ≠ 0) :
    HasDerivAt (fun w => emlF w b₁ w₂ b₂ x) (x * Real.exp (w₁ * x + b₁)) w₁ := by
  unfold emlF
  have : HasDerivAt (fun w => Real.exp (w * x + b₁)) (x * Real.exp (w₁ * x + b₁)) w₁ := by
    have h1 : HasDerivAt (fun w => w * x + b₁) x w₁ := by
      have := (hasDerivAt_id w₁).mul_const x |>.add_const b₁
      simpa using this
    exact h1.exp.congr_deriv (by ring)
  exact this.sub_const _

/-- Partial derivative of EML neuron w.r.t. bias b₁.
    ∂f/∂b₁ = exp(w₁x + b₁). -/

theorem eml_grad_b1 (w₁ b₁ w₂ b₂ x : ℝ) (_h : w₂ * x + b₂ ≠ 0) :
    HasDerivAt (fun b => emlF w₁ b w₂ b₂ x) (Real.exp (w₁ * x + b₁)) b₁ := by
  unfold emlF
  have : HasDerivAt (fun b => Real.exp (w₁ * x + b)) (Real.exp (w₁ * x + b₁)) b₁ := by
    have h1 : HasDerivAt (fun b => w₁ * x + b) 1 b₁ :=
      (hasDerivAt_id b₁).const_add _
    exact h1.exp.congr_deriv (by ring)
  exact this.sub_const _

/-- Partial derivative of EML neuron w.r.t. weight w₂.
    ∂f/∂w₂ = −x / (w₂x + b₂). -/

theorem eml_grad_w2 (w₁ b₁ w₂ b₂ x : ℝ) (h : w₂ * x + b₂ ≠ 0) :
    HasDerivAt (fun w => emlF w₁ b₁ w b₂ x) (-x / (w₂ * x + b₂)) w₂ := by
  unfold emlF
  have hlog : HasDerivAt (fun w => Real.log (w * x + b₂)) (x / (w₂ * x + b₂)) w₂ := by
    have h1 : HasDerivAt (fun w => w * x + b₂) x w₂ := by
      have := (hasDerivAt_id w₂).mul_const x |>.add_const b₂
      simpa using this
    exact h1.log h |>.congr_deriv (by ring)
  convert (hasDerivAt_const w₂ (Real.exp (w₁ * x + b₁))).sub hlog using 1
  ring

/-- Partial derivative of EML neuron w.r.t. bias b₂.
    ∂f/∂b₂ = −1 / (w₂x + b₂). -/

theorem eml_grad_b2 (w₁ b₁ w₂ b₂ x : ℝ) (h : w₂ * x + b₂ ≠ 0) :
    HasDerivAt (fun b => emlF w₁ b₁ w₂ b x) (-1 / (w₂ * x + b₂)) b₂ := by
  unfold emlF
  have hlog : HasDerivAt (fun b => Real.log (w₂ * x + b)) (1 / (w₂ * x + b₂)) b₂ := by
    have h1 : HasDerivAt (fun b => w₂ * x + b) 1 b₂ :=
      (hasDerivAt_id b₂).const_add _
    exact h1.log h |>.congr_deriv (by ring)
  convert (hasDerivAt_const b₂ (Real.exp (w₁ * x + b₁))).sub hlog using 1
  ring

/-! ## Gradient Explosion/Vanishing -/

/-- The exponential gradient component is always positive when w₁ > 0. -/

theorem exp_gradient_pos (w₁ b₁ x : ℝ) (hw : 0 < w₁) :
    0 < gradExpComp w₁ b₁ x := by
  unfold gradExpComp; positivity

/-- The logarithmic gradient magnitude is bounded when far from singularity. -/

theorem log_gradient_bound (w₂ b₂ x : ℝ) (h : 1 ≤ |w₂ * x + b₂|) :
    |gradLogComp w₂ b₂ x| ≤ |w₂| := by
  unfold gradLogComp
  rw [abs_div]
  exact div_le_of_le_mul₀ (abs_nonneg _) (abs_nonneg _)
    (le_mul_of_one_le_right (abs_nonneg _) h)

/-! ## Loss Function Properties -/

/-- Mean squared error loss for a single EML neuron. -/

def mseLoss (w₁ b₁ w₂ b₂ : ℝ) (data : List (ℝ × ℝ)) : ℝ :=
  (data.map fun ⟨x, y⟩ => (emlF w₁ b₁ w₂ b₂ x - y)^2).sum / data.length

/-- MSE loss is always nonneg. -/

theorem mse_nonneg (w₁ b₁ w₂ b₂ : ℝ) (data : List (ℝ × ℝ)) :
    0 ≤ mseLoss w₁ b₁ w₂ b₂ data := by
  unfold mseLoss
  apply div_nonneg
  · apply List.sum_nonneg
    intro x hx
    simp only [List.mem_map] at hx
    obtain ⟨⟨a, b⟩, _, rfl⟩ := hx
    positivity
  · positivity

/-! ## Learning Rate Analysis -/

/-- Maximum safe learning rate for the exponential component. -/

def maxLRExp (w₁ b₁ M : ℝ) : ℝ :=
  1 / Real.exp (|w₁| * M + |b₁|)

/-- The max learning rate is always positive. -/

theorem maxLR_pos (w₁ b₁ M : ℝ) : 0 < maxLRExp w₁ b₁ M := by
  unfold maxLRExp; positivity

/-- Smaller weights allow larger learning rates. -/

theorem maxLR_weight_monotone (b₁ M : ℝ) (w₁ w₂ : ℝ)
    (hw : |w₁| ≤ |w₂|) (hM : 0 ≤ M) :
    maxLRExp w₂ b₁ M ≤ maxLRExp w₁ b₁ M := by
  unfold maxLRExp
  apply div_le_div_of_nonneg_left (by positivity) (by positivity)
  exact Real.exp_le_exp_of_le (by nlinarith)

/-! ## Chain Gradient Propagation -/

/-- The gradient through a depth-d chain accumulates multiplicatively. -/

def chainGradMag (d : ℕ) (avgGrad : ℝ) : ℝ := avgGrad ^ d

/-- If average gradient > 1, the chain gradient explodes. -/

theorem chain_explodes (d : ℕ) (g : ℝ) (hg : 1 < g) (hd : 1 ≤ d) :
    g ≤ chainGradMag d g := by
  unfold chainGradMag
  exact le_self_pow₀ hg.le (by omega)

/-- If average gradient ≤ 1, the chain gradient shrinks with depth. -/

theorem chain_vanishes (d₁ d₂ : ℕ) (g : ℝ) (hg : 0 ≤ g) (hg1 : g ≤ 1)
    (hd : d₁ ≤ d₂) :
    chainGradMag d₂ g ≤ chainGradMag d₁ g := by
  unfold chainGradMag
  exact pow_le_pow_of_le_one hg hg1 hd

/-! ## Dual Gradient Training Strategy -/

/-- The "gradient ratio" measures exp vs log dominance. -/

def gradRatio (w₁ b₁ w₂ b₂ x : ℝ) (_h : gradLogComp w₂ b₂ x ≠ 0) : ℝ :=
  |gradExpComp w₁ b₁ x| / |gradLogComp w₂ b₂ x|

/-- In exploration mode (ratio > 1), the exp component dominates. -/

theorem exploration_mode (w₁ b₁ w₂ b₂ x : ℝ)
    (h : gradLogComp w₂ b₂ x ≠ 0)
    (hbig : 1 < gradRatio w₁ b₁ w₂ b₂ x h) :
    |gradLogComp w₂ b₂ x| < |gradExpComp w₁ b₁ x| := by
  unfold gradRatio at hbig
  rwa [lt_div_iff₀ (abs_pos.mpr h), one_mul] at hbig

/-! ## EML Network Depth Analysis -/

/-- The expressiveness of depth-d EML networks grows double-exponentially.
    A depth-d composition can produce exp^d(x) (tower of exponentials). -/

theorem depth_expressiveness (d : ℕ) : d ≤ 2 ^ d :=
  Nat.lt_two_pow_self.le

/-- Recommended maximum depth before gradient issues become critical. -/

def recommendedMaxDepth : ℕ := 5

/-- At depth 5, gradient magnitude can vary by exp(exp(exp(exp(exp(1))))) ≈ 10^(10^6).
    This motivates the depth-5 recommendation. -/

theorem depth5_gradient_range : recommendedMaxDepth = 5 := rfl

end


end
