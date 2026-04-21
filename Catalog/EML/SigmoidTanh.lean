/-! # CatalogBuild.EML.SigmoidTanh

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 5
-/

import Mathlib
import EML.Basic

noncomputable section

/-- log(S(x)) = x - σ(x). -/
theorem log_sigmoid_eq (x : ℝ) :
    Real.log (logisticSigmoid x) = x - softplus x := by
  unfold logisticSigmoid softplus
  rw [Real.log_div (ne_of_gt (Real.exp_pos x)) (ne_of_gt (one_plus_exp_pos x))]
  simp [Real.log_exp]


/-- [Section: ## The Sigmoid-Tanh Connection] -/
theorem log_sigmoid_eq' (x : ℝ) :
    Real.log (logisticSigmoid x) = -softplus (-x) := by
  convert log_sigmoid_eq x using 1
  simp [logisticSigmoid, softplus];
  rw [ show ( 1 + Real.exp ( -x ) ) = ( 1 + Real.exp x ) / Real.exp x by rw [ add_div, div_self <| ne_of_gt <| Real.exp_pos x ] ; rw [ Real.exp_neg ] ; ring, Real.log_div ( by positivity ) <| by positivity, Real.log_exp ] ; ring


/-- log(sigmoid) is in the Sheffer algebra. -/
theorem log_sigmoid_mem_sheffer :
    (fun x => Real.log (logisticSigmoid x)) ∈ ShefferAlg := by
  have h : (fun x => Real.log (logisticSigmoid x)) =
    fun x => 1 * (fun x => x) x + (-1) * softplus x + 0 := by
    ext x; simp [log_sigmoid_eq]; linarith
  rw [h]
  exact sheffer_affineComb id_mem_sheffer softplus_mem_sheffer 1 (-1) 0


/-- σ(x) - σ(x + c) is in ShefferAlg for any constant c. -/
theorem softplus_diff_shift_mem (c : ℝ) :
    (fun x => softplus x - softplus (x + c)) ∈ ShefferAlg := by
  have h : (fun x => softplus x - softplus (x + c)) =
    fun x => 1 * softplus x + (-1) * softplus (1 * x + c) + 0 := by
    ext x; ring
  rw [h]
  exact sheffer_affineComb softplus_mem_sheffer
    (sheffer_affinePrecomp softplus_mem_sheffer 1 c) 1 (-1) 0


theorem bounded_sheffer_exists :
    ∃ f ∈ ShefferAlg, (∃ M : ℝ, ∀ x, |f x| ≤ M) ∧ ¬(∃ c : ℝ, ∀ x, f x = c) := by
  refine' ⟨ fun x => softplus x - softplus ( x + 1 ), _, _, _ ⟩;
  · convert softplus_diff_shift_mem 1 using 1;
  · -- Use the fact that softplus is Lipschitz with constant 1.
    have h_lip : ∀ x y : ℝ, |softplus x - softplus y| ≤ |x - y| := by
      exact fun x y => by simpa using softplus_lipschitz.dist_le_mul x y;
    exact ⟨ 1, fun x => le_trans ( h_lip _ _ ) ( by norm_num ) ⟩;
  · norm_num +zetaDelta at *;
    intro x;
    by_contra! h;
    have := h 0; have := h ( -1 ) ; norm_num [ softplus ] at *;
    norm_num [ ← ‹log 2 - log ( 1 + Real.exp 1 ) = x› ] at this;
    apply_fun Real.exp at this ; norm_num [ Real.exp_sub, Real.exp_log, Real.exp_neg ] at this;
    rw [ Real.exp_log ( by positivity ), Real.exp_log ( by positivity ) ] at this;
    rw [ div_eq_div_iff ] at this <;> nlinarith [ Real.add_one_le_exp 1, mul_inv_cancel₀ ( ne_of_gt ( Real.exp_pos 1 ) ) ]


end
