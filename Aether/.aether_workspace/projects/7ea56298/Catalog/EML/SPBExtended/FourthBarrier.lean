import EML.Lean.AdvancedTheorems
import EML.Lean.OpenQuestions
import EML.Lean.ShefferAlgebra
import EML.Lean.SoftplusBasic
import EML.Lean.ThirdBarrier
import Mathlib

/-! # CatalogBuild.MachineLearning.ShefferFunction.FourthBarrier

Auto-generated from theorem catalog database.
Domain: MachineLearning/ShefferFunction
Declarations: 5
-/


noncomputable section

/-- [Section: ## Sigmoid-Tanh Equivalence (Q36 ⟺ Q38)] -/
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



/-- [Section: # CatalogBuild.MachineLearning.ShefferFunction.FourthBarrier
Auto-generated from theorem catalog database.
Domain: MachineLearning/ShefferFunction
Declarations: 5] -/
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



/-- [Section: ## No Higher-Degree Polynomial in ShefferAlg] -/
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



end