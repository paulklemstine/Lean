/-! # CatalogBuild.EML.DerivativeLimitPairs

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 6
-/

import Mathlib
import EML.Barriers
import EML.Basic

noncomputable section

/-- The construction achieving any derivative limit pair (a, b):
f(x) = (a - b) · σ(x) + b · x -/
def sheffer_pair_fn (a b : ℝ) : ℝ → ℝ :=
  fun x => (a - b) * softplus x + b * x


/-- The pair function is in ShefferAlg. -/
theorem sheffer_pair_fn_mem (a b : ℝ) : sheffer_pair_fn a b ∈ ShefferAlg := by
  unfold sheffer_pair_fn
  have hmem := sheffer_affineComb softplus_mem_sheffer id_mem_sheffer (a - b) b 0
  convert hmem using 1
  ext x; ring


/-- The derivative of the pair function is (a-b)·S(x) + b. -/
theorem sheffer_pair_fn_hasDerivAt (a b x : ℝ) :
    HasDerivAt (sheffer_pair_fn a b) ((a - b) * logisticSigmoid x + b) x := by
  unfold sheffer_pair_fn
  have h1 := (hasDerivAt_softplus x).const_mul (a - b)
  have h2 := (hasDerivAt_id x).const_mul b
  convert h1.add h2 using 1
  ring


theorem sheffer_pair_deriv_tendsto_atTop (a b : ℝ) :
    Tendsto (fun x => (a - b) * logisticSigmoid x + b) atTop (𝓝 a) := by
  convert Filter.Tendsto.add ( tendsto_const_nhds.mul ( logisticSigmoid_tendsto_one ) ) tendsto_const_nhds using 2 ; ring


theorem sheffer_pair_deriv_tendsto_atBot (a b : ℝ) :
    Tendsto (fun x => (a - b) * logisticSigmoid x + b) atBot (𝓝 b) := by
  -- The logistic sigmoid function tends to 0 at -∞.
  have h_logisticSigmoid_neg_inf : Tendsto logisticSigmoid atBot (𝓝 0) := by
    exact?;
  simpa using Filter.Tendsto.add ( h_logisticSigmoid_neg_inf.const_mul ( a - b ) ) tendsto_const_nhds


/-- Q39 Resolved: Every (a, b) ∈ ℝ² is achievable as derivative limits. -/
theorem derivative_limit_pairs_surjective (a b : ℝ) :
    ∃ f ∈ ShefferAlg,
      ∃ f' : ℝ → ℝ, (∀ x, HasDerivAt f (f' x) x) ∧
        Tendsto f' atTop (𝓝 a) ∧ Tendsto f' atBot (𝓝 b) := by
  exact ⟨sheffer_pair_fn a b, sheffer_pair_fn_mem a b,
    fun x => (a - b) * logisticSigmoid x + b,
    sheffer_pair_fn_hasDerivAt a b,
    sheffer_pair_deriv_tendsto_atTop a b, sheffer_pair_deriv_tendsto_atBot a b⟩


end
