import Mathlib

/-! # CatalogBuild.MachineLearning.Neural.DistillationLoss

Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 16
-/


noncomputable section

/-- Softmax function: maps logits to a probability distribution. -/
def softmax' (n : ℕ) (T : ℝ) (logits : Fin n → ℝ) (i : Fin n) : ℝ :=
  Real.exp (logits i / T) / ∑ j : Fin n, Real.exp (logits j / T)


/-- The softmax partition function is positive. -/
theorem softmax_partition_pos' (n : ℕ) (hn : 0 < n) (T : ℝ) (hT : 0 < T)
    (logits : Fin n → ℝ) :
    0 < ∑ j : Fin n, Real.exp (logits j / T) := by
  apply Finset.sum_pos
  · intro j _; exact Real.exp_pos _
  · haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
    exact Finset.univ_nonempty


/-- Each softmax output is non-negative. -/
theorem softmax_nonneg' (n : ℕ) (hn : 0 < n) (T : ℝ) (hT : 0 < T)
    (logits : Fin n → ℝ) (i : Fin n) :
    0 ≤ softmax' n T logits i := by
  apply div_nonneg (le_of_lt (Real.exp_pos _))
    (le_of_lt (softmax_partition_pos' n hn T hT logits))


/-- Softmax outputs sum to 1. -/
theorem softmax_sum_eq_one' (n : ℕ) (hn : 0 < n) (T : ℝ) (hT : 0 < T)
    (logits : Fin n → ℝ) :
    ∑ i : Fin n, softmax' n T logits i = 1 := by
  unfold softmax'
  rw [← Finset.sum_div]
  exact div_self (ne_of_gt (softmax_partition_pos' n hn T hT logits))


/-- [Section: ## Section 1: Softmax and Probability Distributions] -/
theorem softmax_le_one' (n : ℕ) (hn : 0 < n) (T : ℝ) (hT : 0 < T)
    (logits : Fin n → ℝ) (i : Fin n) :
    softmax' n T logits i ≤ 1 := by
  exact div_le_one_of_le₀ ( Finset.single_le_sum ( fun a _ => Real.exp_nonneg ( logits a / T ) ) ( Finset.mem_univ i ) ) ( Finset.sum_nonneg fun _ _ => Real.exp_nonneg _ )


/-- Each softmax output is strictly positive. -/
theorem softmax_pos' (n : ℕ) (hn : 0 < n) (T : ℝ) (hT : 0 < T)
    (logits : Fin n → ℝ) (i : Fin n) :
    0 < softmax' n T logits i := by
  apply div_pos (Real.exp_pos _) (softmax_partition_pos' n hn T hT logits)


/-- KL divergence between two discrete distributions over Fin n. -/
def klDiv' (n : ℕ) (p q : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, if p i = 0 then 0 else p i * Real.log (p i / q i)


/-- KL divergence of a distribution with itself is zero. -/
theorem klDiv_self' (n : ℕ) (p : Fin n → ℝ) (hp_pos : ∀ i, 0 < p i) :
    klDiv' n p p = 0 := by
  unfold klDiv'
  apply Finset.sum_eq_zero
  intro i _
  have hpi : p i ≠ 0 := ne_of_gt (hp_pos i)
  simp [hpi]


/-- The softmax of a constant vector is uniform. -/
theorem softmax_constant_is_uniform' (n : ℕ) (hn : 0 < n) (T : ℝ) (hT : 0 < T)
    (c : ℝ) (i : Fin n) :
    softmax' n T (fun _ => c) i = 1 / n := by
  unfold softmax'
  simp only
  rw [Finset.sum_const, Finset.card_fin, nsmul_eq_mul]
  field_simp


/-- The distillation loss: weighted combination of hard-label cross-entropy
and soft-label KL divergence from teacher. -/
def distillationLoss' (n : ℕ) (α : ℝ)
    (studentLogits teacherLogits : Fin n → ℝ)
    (trueLabel : Fin n) (T : ℝ) : ℝ :=
  let hardLoss := -Real.log (softmax' n 1 studentLogits trueLabel)
  let softLoss := klDiv' n (softmax' n T teacherLogits) (softmax' n T studentLogits)
  (1 - α) * hardLoss + α * T ^ 2 * softLoss


/-- When α = 0, distillation loss reduces to standard cross-entropy. -/
theorem distillationLoss_alpha_zero' (n : ℕ)
    (studentLogits teacherLogits : Fin n → ℝ)
    (trueLabel : Fin n) (T : ℝ) :
    distillationLoss' n 0 studentLogits teacherLogits trueLabel T =
    -Real.log (softmax' n 1 studentLogits trueLabel) := by
  simp [distillationLoss']


/-- When α = 1, distillation loss reduces to pure KD loss. -/
theorem distillationLoss_alpha_one' (n : ℕ)
    (studentLogits teacherLogits : Fin n → ℝ)
    (trueLabel : Fin n) (T : ℝ) :
    distillationLoss' n 1 studentLogits teacherLogits trueLabel T =
    T ^ 2 * klDiv' n (softmax' n T teacherLogits) (softmax' n T studentLogits) := by
  simp [distillationLoss']


/-- If student logits match teacher logits exactly, the soft KL loss is zero. -/
theorem logit_match_zero_kl' (n : ℕ) (hn : 0 < n) (T : ℝ) (hT : 0 < T)
    (logits : Fin n → ℝ) :
    klDiv' n (softmax' n T logits) (softmax' n T logits) = 0 := by
  apply klDiv_self'
  intro i; exact softmax_pos' n hn T hT logits i


/-- Quadratic bound on logit perturbation. -/
def logitPerturbationSqBound' (n : ℕ) (T ε : ℝ) : ℝ :=
  n * (ε / T) ^ 2


/-- The perturbation bound is non-negative. -/
theorem logitPerturbationSqBound_nonneg' (n : ℕ) (T ε : ℝ) :
    0 ≤ logitPerturbationSqBound' n T ε := by
  unfold logitPerturbationSqBound'; positivity


/-- The distillation loss is monotone in α when soft loss dominates. -/
theorem distillationLoss_mono_alpha'
    (hardLoss softLoss : ℝ) (T : ℝ)
    (α₁ α₂ : ℝ) (hα : α₁ ≤ α₂)
    (h_soft_dom : T ^ 2 * softLoss ≥ hardLoss) :
    (1 - α₁) * hardLoss + α₁ * T ^ 2 * softLoss ≤
    (1 - α₂) * hardLoss + α₂ * T ^ 2 * softLoss := by
  nlinarith


end
