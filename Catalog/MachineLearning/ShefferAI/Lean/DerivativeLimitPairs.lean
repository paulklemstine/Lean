/-
# Derivative Limit Pairs: What Asymptotic Slopes are Achievable?

This file addresses Q39: what pairs (L₊, L₋) ∈ ℝ² can be achieved as
(lim_{x→+∞} f'(x), lim_{x→-∞} f'(x)) for f ∈ ShefferAlg?

**Answer: ALL pairs (a, b) ∈ ℝ² are achievable.**

The construction uses f(x) = (a-b)·σ(x) + b·x, which achieves:
- f'(x) = (a-b)·S(x) + b → (a-b)·1 + b = a at +∞
- f'(x) = (a-b)·S(x) + b → (a-b)·0 + b = b at -∞

## Main Results
- `softplus_deriv_limit_pair` : σ has derivative limits (1, 0)
- `id_deriv_limit_pair` : id has derivative limits (1, 1)
- `sheffer_achieves_pair` : Any (a, b) ∈ ℝ² is achievable
- `derivative_limit_pairs_surjective` : The map f ↦ (L₊, L₋) is surjective
-/

import Mathlib
import ShefferAI.Lean.SoftplusBasic
import ShefferAI.Lean.ShefferAlgebra
import ShefferAI.Lean.AdvancedTheorems
import ShefferAI.Lean.OpenQuestions
import ShefferAI.Lean.ThirdBarrier

open Real Filter

noncomputable section

/-! ## Basic Derivative Limit Pairs -/

/-- σ(x) has derivative limits (1, 0). -/
theorem softplus_deriv_limit_pair :
    Tendsto (deriv softplus) atTop (nhds 1) ∧
    Tendsto (deriv softplus) atBot (nhds 0) := by
  constructor
  · rw [show deriv softplus = logisticSigmoid from funext softplus_deriv]
    exact logisticSigmoid_tendsto_one
  · rw [show deriv softplus = logisticSigmoid from funext softplus_deriv]
    exact logisticSigmoid_tendsto_zero

/-- The identity function has derivative limits (1, 1). -/
theorem id_deriv_limit_pair :
    Tendsto (deriv (fun x : ℝ => x)) atTop (nhds 1) ∧
    Tendsto (deriv (fun x : ℝ => x)) atBot (nhds 1) := by
  simp

/-! ## Achieving Arbitrary Derivative Limit Pairs -/

/-
For any (a, b) ∈ ℝ², the function f(x) = (a-b)·σ(x) + b·x achieves
    derivative limits (a, b). This resolves Q39 completely.
-/
theorem sheffer_achieves_pair (a b : ℝ) :
    ∃ f ∈ ShefferAlgebra,
      Tendsto (deriv f) atTop (nhds a) ∧
      Tendsto (deriv f) atBot (nhds b) := by
  refine ⟨fun x => (a - b) * softplus x + b * x, ?_, ?_⟩
  · -- Membership: (a-b)·σ + b·id ∈ ShefferAlg
    exact sheffer_add_closed (sheffer_smul_closed softplus_mem_sheffer (a - b))
                              (sheffer_smul_closed id_mem_sheffer b)
  · -- Derivative limits
    -- By definition of $f$, we know that its derivative is $(a - b)\sigma(x) + b$.
    have h_deriv : ∀ x : ℝ, deriv (fun x => (a - b) * softplus x + b * x) x = (a - b) * logisticSigmoid x + b := by
      simp [softplus, logisticSigmoid];
      norm_num [ Real.differentiableAt_exp, mul_comm b, ne_of_gt ( add_pos zero_lt_one ( Real.exp_pos _ ) ) ];
    rw [ show deriv _ = _ from funext h_deriv ];
    exact ⟨ by convert Filter.Tendsto.add ( tendsto_const_nhds.mul logisticSigmoid_tendsto_one ) tendsto_const_nhds using 2 ; ring, by convert Filter.Tendsto.add ( tendsto_const_nhds.mul logisticSigmoid_tendsto_zero ) tendsto_const_nhds using 2 ; ring ⟩

/-- Every pair (L₊, L₋) ∈ ℝ² is achievable as derivative limits
    of some f ∈ ShefferAlg. This completely resolves Q39. -/
theorem derivative_limit_pairs_surjective :
    ∀ a b : ℝ, ∃ f ∈ ShefferAlgebra,
      Tendsto (deriv f) atTop (nhds a) ∧
      Tendsto (deriv f) atBot (nhds b) :=
  sheffer_achieves_pair

end