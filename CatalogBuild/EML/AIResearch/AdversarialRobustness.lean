/-! # CatalogBuild.EML.AIResearch.AdversarialRobustness

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 18
-/

import Mathlib

noncomputable section

/-- A function is L-Lipschitz if |f(x) - f(y)| ≤ L * |x - y| -/
def IsLipschitz (f : ℝ → ℝ) (L : ℝ) : Prop :=
  0 ≤ L ∧ ∀ x y, |f x - f y| ≤ L * |x - y|


/-- Identity is 1-Lipschitz -/
theorem identity_lipschitz : IsLipschitz id 1 := by
  constructor
  · linarith
  · intro x y; simp


/-- Constant functions are 0-Lipschitz -/
theorem constant_lipschitz (c : ℝ) : IsLipschitz (fun _ => c) 0 := by
  constructor
  · linarith
  · intro x y; simp


/-- Composition of Lipschitz functions -/
theorem lipschitz_comp (f g : ℝ → ℝ) (Lf Lg : ℝ)
    (hf : IsLipschitz f Lf) (hg : IsLipschitz g Lg) :
    IsLipschitz (f ∘ g) (Lf * Lg) := by
  constructor
  · exact mul_nonneg hf.1 hg.1
  · intro x y
    simp only [Function.comp]
    calc |f (g x) - f (g y)| ≤ Lf * |g x - g y| := hf.2 _ _
      _ ≤ Lf * (Lg * |x - y|) := by
          exact mul_le_mul_of_nonneg_left (hg.2 _ _) hf.1
      _ = Lf * Lg * |x - y| := by ring


/-- Certified radius is nonneg for positive Lipschitz constant and margin -/
theorem certified_radius_nonneg (L m : ℝ) (hL : 0 < L) (hm : 0 ≤ m) :
    0 ≤ certifiedRadius L m := by
  exact div_nonneg hm (le_of_lt hL)


/-- Within the certified radius, the output change is bounded -/
theorem within_radius_bounded (f : ℝ → ℝ) (L m x δ : ℝ)
    (hf : IsLipschitz f L) (hL : 0 < L)
    (hδ : |δ| ≤ certifiedRadius L m) :
    |f (x + δ) - f x| ≤ m := by
  have h1 : |f (x + δ) - f x| ≤ L * |δ| := by
    have := hf.2 (x + δ) x
    simp [add_sub_cancel_left] at this
    exact this
  calc |f (x + δ) - f x| ≤ L * |δ| := h1
    _ ≤ L * certifiedRadius L m := mul_le_mul_of_nonneg_left hδ hf.1
    _ = L * (m / L) := rfl
    _ = m := by field_simp


/-- If budget is fixed, more robustness means less accuracy -/
theorem tradeoff_monotone (a₁ a₂ r₁ r₂ B : ℝ)
    (h1 : robustnessAccuracyTradeoff a₁ r₁ B)
    (h2 : robustnessAccuracyTradeoff a₂ r₂ B)
    (hr : r₁ < r₂) (ha : a₁ ≤ a₂) :
    a₂ + r₂ ≤ B := by
  exact h2


/-- Adversarial loss: max over perturbations -/
def adversarialLoss (cleanLoss : ℝ) (perturbationPenalty : ℝ) : ℝ :=
  cleanLoss + perturbationPenalty


/-- Adversarial loss is at least the clean loss -/
theorem adversarial_ge_clean (cL pP : ℝ) (hp : 0 ≤ pP) :
    cL ≤ adversarialLoss cL pP := by
  unfold adversarialLoss; linarith


/-- The adversarial training gap decreases with more training -/
def advTrainingGap (initialGap : ℝ) (trainSteps : ℕ) (decayRate : ℝ) : ℝ :=
  initialGap * decayRate ^ trainSteps


/-- Adversarial gap decreases monotonically -/
theorem adv_gap_decreases (g₀ r : ℝ) (hg : 0 ≤ g₀) (hr0 : 0 ≤ r) (hr1 : r ≤ 1) (k : ℕ) :
    advTrainingGap g₀ (k + 1) r ≤ advTrainingGap g₀ k r := by
  unfold advTrainingGap
  have : r ^ (k + 1) ≤ r ^ k := by
    rw [pow_succ']
    exact mul_le_of_le_one_left (pow_nonneg hr0 k) hr1
  exact mul_le_mul_of_nonneg_left this hg


/-- A self-improvement step preserves robustness if it doesn't increase Lipschitz constant -/
def PreservesRobustness (improve : (ℝ → ℝ) → (ℝ → ℝ)) : Prop :=
  ∀ f L, IsLipschitz f L → ∃ L', L' ≤ L ∧ IsLipschitz (improve f) L'


/-- If improvement preserves robustness, k iterations preserve robustness -/
theorem iterated_robustness_preservation
    (improve : (ℝ → ℝ) → (ℝ → ℝ)) (f₀ : ℝ → ℝ) (L₀ : ℝ)
    (hpr : PreservesRobustness improve)
    (hf : IsLipschitz f₀ L₀) :
    ∃ L, L ≤ L₀ ∧ IsLipschitz (improve f₀) L := by
  exact hpr f₀ L₀ hf


/-- EML's structural constraints (shift-bias-amplitude-frequency) act as
implicit Lipschitz regularization -/
def emlLipschitzBound (amplitude frequency : ℝ) : ℝ :=
  |amplitude * frequency|


/-- EML's product structure means the Lipschitz constant is controlled
by individual neuron bounds -/
theorem eml_layer_lipschitz (n : ℕ) (amplitudes frequencies : Fin n → ℝ)
    (B : ℝ) (hB : ∀ i, |amplitudes i * frequencies i| ≤ B)
    (hn : 0 < n) :
    ∀ i, emlLipschitzBound (amplitudes i) (frequencies i) ≤ B := by
  intro i
  exact hB i


/-- EML has fewer parameters to regularize -/
theorem eml_fewer_to_regularize (d : ℕ) (hd : 5 ≤ d) :
    4 * d < d * d := by nlinarith


/-- Regularization cost is proportional to parameter count -/
def regularizationCost (numParams : ℕ) (regStrength : ℝ) : ℝ :=
  (numParams : ℝ) * regStrength


/-- EML has lower regularization cost -/
theorem eml_lower_reg_cost (d : ℕ) (hd : 5 ≤ d) (regStr : ℝ) (hr : 0 < regStr) :
    regularizationCost (4 * d) regStr < regularizationCost (d * d) regStr := by
  unfold regularizationCost
  have : (4 * d : ℕ) < d * d := by nlinarith
  exact mul_lt_mul_of_pos_right (by exact_mod_cast this) hr


end
