/-! # CatalogBuild.MachineLearning.ShefferFunction.DerivativeLimitPairs

Auto-generated from theorem catalog database.
Domain: MachineLearning/ShefferFunction
Declarations: 3
-/

import EML.Barriers
import EML.Basic
import EML.Lean.AdvancedTheorems
import EML.Lean.OpenQuestions
import EML.Lean.ShefferAlgebra
import EML.Lean.SoftplusBasic
import EML.Lean.ThirdBarrier
import Mathlib

noncomputable section

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



/-- [Section: ## Achieving Arbitrary Derivative Limit Pairs] -/
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



end
