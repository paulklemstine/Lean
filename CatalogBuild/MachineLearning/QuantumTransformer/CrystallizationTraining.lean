/-! # CatalogBuild.MachineLearning.QuantumTransformer.CrystallizationTraining

Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 13
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.MachineLearning.QuantumTransformer.CrystallizationTraining
Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 13] -/
def entry_crystal_loss (p : ℝ) : ℝ := p * (1 - p)





/-- [Section: # CatalogBuild.MachineLearning.QuantumTransformer.CrystallizationTraining
Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 13] -/
def row_crystal_loss {n : ℕ} (w : Fin n → ℝ) : ℝ :=
  ∑ i, entry_crystal_loss (w i)





/-- [Section: # CatalogBuild.MachineLearning.QuantumTransformer.CrystallizationTraining
Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 13] -/
theorem crystal_regularizer_nonneg {n : ℕ} (w : Fin n → ℝ)
    (hw : ∀ i, 0 ≤ w i ∧ w i ≤ 1) :
    0 ≤ row_crystal_loss w := by
  unfold row_crystal_loss entry_crystal_loss
  apply Finset.sum_nonneg
  intro i _
  exact mul_nonneg (hw i).1 (by linarith [(hw i).2])





theorem entry_loss_bounded (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    entry_crystal_loss p ≤ 1 / 4 := by
  unfold entry_crystal_loss
  nlinarith [sq_nonneg (p - 1 / 2)]





theorem crystal_regularizer_zero_iff_binary {n : ℕ} (w : Fin n → ℝ)
    (hw : ∀ i, 0 ≤ w i ∧ w i ≤ 1) :
    row_crystal_loss w = 0 ↔ ∀ i, w i = 0 ∨ w i = 1 := by
  unfold row_crystal_loss entry_crystal_loss
  constructor
  · intro h
    have h' := Finset.sum_eq_zero_iff_of_nonneg (fun i _ =>
      mul_nonneg (hw i).1 (by linarith [(hw i).2])) |>.mp h
    intro i
    have := h' i (Finset.mem_univ i)
    rcases mul_eq_zero.mp this with h1 | h1
    · left; exact h1
    · right; linarith
  · intro h
    apply Finset.sum_eq_zero
    intro i _
    rcases h i with h1 | h1 <;> simp [entry_crystal_loss, h1]





def geometric_anneal (tau_0 alpha : ℝ) (t : ℕ) : ℝ := tau_0 * alpha ^ t





theorem anneal_pos (tau_0 alpha : ℝ) (htau : 0 < tau_0) (halpha : 0 < alpha) (t : ℕ) :
    0 < geometric_anneal tau_0 alpha t := by
  unfold geometric_anneal
  exact mul_pos htau (pow_pos halpha t)





theorem anneal_decreasing (tau_0 alpha : ℝ) (htau : 0 < tau_0) (halpha0 : 0 < alpha) (halpha1 : alpha < 1) (t : ℕ) :
    geometric_anneal tau_0 alpha (t + 1) ≤ geometric_anneal tau_0 alpha t := by
  unfold geometric_anneal
  rw [pow_succ]
  calc tau_0 * (alpha ^ t * alpha) = (tau_0 * alpha ^ t) * alpha := by ring
    _ ≤ (tau_0 * alpha ^ t) * 1 := by
        apply mul_le_mul_of_nonneg_left halpha1.le
        exact mul_nonneg htau.le (pow_nonneg halpha0.le t)
    _ = tau_0 * alpha ^ t := by ring





theorem anneal_converges (tau_0 alpha : ℝ) (htau : 0 < tau_0) (halpha0 : 0 < alpha) (halpha1 : alpha < 1) :
    Filter.Tendsto (geometric_anneal tau_0 alpha) Filter.atTop (nhds 0) := by
  unfold geometric_anneal
  have h1 : Filter.Tendsto (fun t => alpha ^ t) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one halpha0.le halpha1
  have h2 : Filter.Tendsto (fun t => tau_0 * alpha ^ t) Filter.atTop (nhds (tau_0 * 0)) :=
    Filter.Tendsto.const_mul tau_0 h1
  simpa using h2





def combined_loss (L_task L_cryst lambda_reg : ℝ) : ℝ :=
  L_task + lambda_reg * L_cryst





theorem combined_loss_ge_task (L_task L_cryst lambda_reg : ℝ)
    (hc : 0 ≤ L_cryst) (hlambda : 0 ≤ lambda_reg) :
    L_task ≤ combined_loss L_task L_cryst lambda_reg := by
  unfold combined_loss
  linarith [mul_nonneg hlambda hc]





theorem combined_loss_nonneg (L_task L_cryst lambda_reg : ℝ)
    (ht : 0 ≤ L_task) (hc : 0 ≤ L_cryst) (hlambda : 0 ≤ lambda_reg) :
    0 ≤ combined_loss L_task L_cryst lambda_reg := by
  unfold combined_loss
  linarith [mul_nonneg hlambda hc]





/-- At equilibrium, the task gradient balances the crystallization gradient. -/
theorem equilibrium_condition (p grad_task : ℝ) :
    grad_task + (1 - 2 * p) = 0 ↔ p = (1 + grad_task) / 2 := by
  constructor <;> intro h <;> linarith





end
