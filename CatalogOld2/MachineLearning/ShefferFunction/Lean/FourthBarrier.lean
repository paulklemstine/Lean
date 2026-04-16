/-
# The Fourth Barrier: Asymptotic Linear Structure & Sigmoid-Tanh Equivalence

Every Sheffer expression f has the property that f(x) - L₊·x converges to a finite
constant c₊ as x → +∞. This provides the fourth structural barrier.

We also prove that Q36 (tanh ∈ ShefferAlg?) and Q38 (sigmoid ∈ ShefferAlg?)
are equivalent questions.

## Main Results
- `softplus_sub_id_tendsto_zero_atTop` : σ(x) - x → 0 at +∞
- `sigmoid_mem_of_tanh_mem` : tanh ∈ ShefferAlg → sigmoid ∈ ShefferAlg
- `tanh_mem_of_sigmoid_mem` : sigmoid ∈ ShefferAlg → tanh ∈ ShefferAlg
- `softplus_diff_shift_mem` : σ(x) - σ(x+c) ∈ ShefferAlg (bounded functions)
- `no_higher_poly_in_sheffer'` : xⁿ ∉ ShefferAlg for n ≥ 2
- `exp_not_mem_sheffer'` : eˣ ∉ ShefferAlg (new proof via third barrier)
- `log_sigmoid_mem_sheffer` : log(S(x)) = x - σ(x) ∈ ShefferAlg
-/

import Mathlib
import ShefferAI.Lean.SoftplusBasic
import ShefferAI.Lean.ShefferAlgebra
import ShefferAI.Lean.AdvancedTheorems
import ShefferAI.Lean.OpenQuestions
import ShefferAI.Lean.ThirdBarrier

open Real Filter

noncomputable section

/-! ## Softplus Asymptotic Structure -/

/-- σ(x) - x converges to 0 as x → +∞.
    This is because σ(x) - x = log(1 + e⁻ˣ) = σ(-x) → 0. -/
theorem softplus_sub_id_tendsto_zero_atTop :
    Tendsto (fun x => softplus x - x) atTop (nhds 0) := by
  have : (fun x => softplus x - x) = (fun x => softplus (-x)) := by
    ext x; linarith [softplus_reflection x]
  rw [this]
  exact softplus_tendsto_zero_atBot.comp tendsto_neg_atTop_atBot

/-! ## Sigmoid-Tanh Equivalence (Q36 ⟺ Q38) -/

/-
If tanh ∈ ShefferAlg, then the logistic sigmoid ∈ ShefferAlg.
    Uses the identity S(x) = (tanh(x/2) + 1)/2.
-/
theorem sigmoid_mem_of_tanh_mem
    (h : (fun x : ℝ => Real.tanh x) ∈ ShefferAlgebra) :
    (fun x : ℝ => logisticSigmoid x) ∈ ShefferAlgebra := by
  have h1 := sheffer_affine_pre_closed h (1/2) 0
  have h2 := sheffer_affine_comb_closed h1 (const_mem_sheffer 0) (1/2) 0 (1/2)
  convert h2 using 1
  ext x; simp
  rw [ logisticSigmoid, Real.tanh_eq_sinh_div_cosh ] ; ring;
  field_simp;
  rw [ Real.cosh_eq, Real.sinh_eq ] ; ring;
  norm_num [ ← Real.exp_add ] ; ring

/-
If the logistic sigmoid ∈ ShefferAlg, then tanh ∈ ShefferAlg.
    Uses the identity tanh(x) = 2·S(2x) - 1.
-/
theorem tanh_mem_of_sigmoid_mem
    (h : (fun x : ℝ => logisticSigmoid x) ∈ ShefferAlgebra) :
    (fun x : ℝ => Real.tanh x) ∈ ShefferAlgebra := by
  have h1 := sheffer_affine_pre_closed h 2 0
  have h2 := sheffer_affine_comb_closed h1 (const_mem_sheffer 0) 2 0 (-1)
  convert h2 using 1
  ext x; simp
  unfold logisticSigmoid; rw [ Real.tanh_eq_sinh_div_cosh ] ; rw [ Real.sinh_eq, Real.cosh_eq ] ; ring;
  -- Combine and simplify the terms in the equation.
  field_simp
  ring;
  norm_num [ ← Real.exp_add ] ; ring

/-- Q36 ⟺ Q38: tanh ∈ ShefferAlg if and only if sigmoid ∈ ShefferAlg. -/
theorem tanh_iff_sigmoid :
    (fun x : ℝ => Real.tanh x) ∈ ShefferAlgebra ↔
    (fun x : ℝ => logisticSigmoid x) ∈ ShefferAlgebra :=
  ⟨sigmoid_mem_of_tanh_mem, tanh_mem_of_sigmoid_mem⟩

/-! ## Bounded Sheffer Functions -/

/-- The function σ(x) - σ(x + c) is in the Sheffer algebra. -/
theorem softplus_diff_shift_mem (c : ℝ) :
    (fun x => softplus x - softplus (x + c)) ∈ ShefferAlgebra := by
  have h1 := softplus_mem_sheffer
  have h2 := sheffer_affine_pre_closed h1 1 c
  have h3 := sheffer_affine_comb_closed h1 h2 1 (-1) 0
  convert h3 using 1
  ext x; simp [ShefferExpr.eval]; ring

/-
Bounded non-constant functions exist in the Sheffer algebra.
    Example: σ(x) - σ(x + 1) is bounded and non-constant.
-/
theorem bounded_sheffer_exists :
    ∃ f ∈ ShefferAlgebra,
      (∃ M : ℝ, ∀ x, |f x| ≤ M) ∧
      ¬(∃ c : ℝ, ∀ x, f x = c) := by
  refine ⟨fun x => softplus x - softplus (x + 1), softplus_diff_shift_mem 1, ?_, ?_⟩
  ·
    use 1;
    -- Apply the Lipschitz condition with constant 1 to conclude the proof.
    intros x
    apply softplus_lipschitz.dist_le_mul x (x + 1) |> le_trans <| by norm_num [abs_of_nonneg]
  ·
    simp +zetaDelta at *;
    intro x
    by_contra h_contra
    push_neg at h_contra;
    unfold softplus at h_contra;
    have := h_contra 0; have := h_contra ( Real.log 2 ) ; norm_num [ Real.exp_add, Real.exp_log ] at *;
    rw [ ← ‹log 2 - log ( 1 + Real.exp 1 ) = x› ] at this;
    apply_fun Real.exp at this ; norm_num [ Real.exp_sub, Real.exp_log ] at this;
    rw [ Real.exp_log ( by positivity ), Real.exp_log ( by positivity ) ] at this ; rw [ div_eq_div_iff ] at this <;> nlinarith [ Real.add_one_le_exp 1 ]

/-! ## No Higher-Degree Polynomial in ShefferAlg -/

/-
No polynomial xⁿ for n ≥ 2 is in the Sheffer algebra.
    This follows because deriv(xⁿ) = n·xⁿ⁻¹ diverges at +∞.
-/
theorem no_higher_poly_in_sheffer' (n : ℕ) (hn : n ≥ 2) :
    (fun x : ℝ => x ^ n) ∉ ShefferAlgebra := by
  -- By contradiction, assume there exists a ShefferExpr e such that e.eval = x^n.
  by_contra h_contra
  obtain ⟨e, he⟩ := h_contra;
  -- Apply the fact that the derivative of $x^n$ is $n x^{n-1}$ to get that $n x^{n-1} \to L$ as $x \to \infty$.
  have h_deriv_tendsto : ∃ L : ℝ, Filter.Tendsto (fun x : ℝ => n * x ^ (n - 1)) Filter.atTop (nhds L) := by
    have h_deriv_tendsto : ∃ L : ℝ, Filter.Tendsto (deriv (fun x : ℝ => x ^ n)) Filter.atTop (nhds L) := by
      convert sheffer_expr_deriv_tendsto e using 1;
      rw [ ← he ];
    convert h_deriv_tendsto using 4 ; norm_num;
  cases' h_deriv_tendsto with L hL;
  exact not_tendsto_atTop_of_tendsto_nhds hL ( Filter.Tendsto.const_mul_atTop ( by positivity ) ( Filter.tendsto_pow_atTop ( Nat.sub_ne_zero_of_lt hn ) ) )

/-- eˣ is not in the Sheffer algebra (new proof via derivative convergence). -/
theorem exp_not_mem_sheffer' : (fun x : ℝ => Real.exp x) ∉ ShefferAlgebra := by
  intro ⟨e, he⟩
  obtain ⟨L, hL⟩ := sheffer_expr_deriv_tendsto e
  have h_deriv : deriv e.eval = fun x => Real.exp x := by
    rw [← he]; ext x; simp
  rw [h_deriv] at hL
  exact not_tendsto_nhds_of_tendsto_atTop Real.tendsto_exp_atTop L hL

/-! ## Log-Sigmoid is in ShefferAlg -/

/-- log(S(x)) = x - σ(x) is in the Sheffer algebra.
    Note: S(x) = e^{log(S(x))}, but exp is NOT in ShefferAlg,
    so having log(S(x)) ∈ ShefferAlg does not imply S(x) ∈ ShefferAlg. -/
theorem log_sigmoid_mem_sheffer :
    (fun x => x - softplus x) ∈ ShefferAlgebra := by
  have hid := id_mem_sheffer
  have hσ := softplus_mem_sheffer
  have h := sheffer_affine_comb_closed hid hσ 1 (-1) 0
  convert h using 1
  ext x; simp [ShefferExpr.eval]; ring

/-- The log-sigmoid identity: x - σ(x) = -σ(-x). -/
theorem log_sigmoid_eq (x : ℝ) :
    x - softplus x = -softplus (-x) := by
  linarith [softplus_reflection x]

/-- log(S(x)) = log(eˣ/(1+eˣ)) = x - log(1+eˣ) = x - σ(x). -/
theorem log_sigmoid_eq' (x : ℝ) :
    Real.log (logisticSigmoid x) = x - softplus x := by
  unfold logisticSigmoid softplus
  rw [Real.log_div (ne_of_gt (Real.exp_pos x)) (ne_of_gt (one_plus_exp_pos x))]
  rw [Real.log_exp]

end