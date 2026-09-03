/-
# Future Research Theorems: The Unary Sheffer Function Program

This file formalizes theorems from the Future Research Directions paper,
including composition bounds, separation results, and new softplus identities.

## Main Results

- **Theorem C**: Composition Bound — depth(f ∘ g) ≤ depth(f) + depth(g)
- **Theorem E**: Softplus is Non-Polynomial (independent proof)
- **Softplus Lipschitz**: softplus is 1-Lipschitz
- **Sigmoid properties**: monotonicity, complement identity
- **Temperature family**: parameterized softplus
- **Width/depth structural theorems**
-/

import Mathlib
-- import ShefferAI.Lean.SoftplusBasic
import MachineLearning.ShefferFunction.Lean.ShefferAlgebra

open Real

noncomputable section

/-! ## Theorem C: Composition Bound -/

/-- The depth of a composition is at most the sum of depths. -/
theorem sheffer_depth_comp_le (e₁ e₂ : ShefferExpr) :
    (ShefferExpr.comp e₁ e₂).depth ≤ e₁.depth + e₂.depth := by
  simp [ShefferExpr.depth]

/-- Composition Bound (Theorem C): If f has a Sheffer expression of depth d_f
    and g has a Sheffer expression of depth d_g, then f ∘ g has a Sheffer
    expression of depth at most d_f + d_g. -/
theorem sheffer_composition_depth_bound (e_f e_g : ShefferExpr) :
    ∃ e : ShefferExpr, (∀ x, e.eval x = e_f.eval (e_g.eval x)) ∧
      e.depth ≤ e_f.depth + e_g.depth :=
  ⟨ShefferExpr.comp e_f e_g, fun _ => rfl, le_refl _⟩

/-! ## Theorem E: Softplus is Non-Polynomial -/

/-
Softplus tends to zero as x → -∞
-/
theorem softplus_tendsto_zero_atBot :
    Filter.Tendsto softplus Filter.atBot (nhds 0) := by
  convert Filter.Tendsto.log ( tendsto_const_nhds.add ( Real.tendsto_exp_atBot ) ) _ using 2 <;> norm_num

/-
Softplus is not a polynomial function.
-/
theorem softplus_not_polynomial' :
    ¬ ∃ (p : Polynomial ℝ), ∀ x : ℝ, p.eval x = softplus x := by
  rintro ⟨ p, hp ⟩;
  have h_eval_neg_inf : Filter.Tendsto (fun x => |p.eval x|) Filter.atBot (nhds 0) := by
    simpa [ hp ] using Filter.Tendsto.abs ( softplus_tendsto_zero_atBot );
  by_cases h : 0 < p.degree <;> simp_all +decide [ Filter.not_tendsto_const_atTop ];
  · have h_abs_tendsto_atTop : Filter.Tendsto (fun x => |p.eval x|) Filter.atBot Filter.atTop := by
      have := Polynomial.abs_tendsto_atTop ( p.comp ( -Polynomial.X ) );
      convert this ( by erw [ Polynomial.degree_eq_natDegree ( by exact ne_of_apply_ne Polynomial.natDegree <| by erw [ Polynomial.natDegree_comp, Polynomial.natDegree_neg, Polynomial.natDegree_X ] ; erw [ Polynomial.degree_eq_natDegree ] at h <;> aesop ) ] ; erw [ Polynomial.natDegree_comp, Polynomial.natDegree_neg, Polynomial.natDegree_X ] ; erw [ Polynomial.degree_eq_natDegree ] at h <;> aesop ) |> Filter.Tendsto.comp <| Filter.tendsto_neg_atBot_atTop using 2 ; aesop;
    exact not_tendsto_atTop_of_tendsto_nhds h_eval_neg_inf ( by simpa only [ hp ] using h_abs_tendsto_atTop );
  · rw [ Polynomial.eq_C_of_degree_le_zero h ] at hp;
    exact absurd ( hp 0 ) ( by have := hp ( -1 ) ; have := hp 1 ; norm_num [ softplus ] at * ; linarith [ Real.log_pos one_lt_two, Real.log_lt_log ( by positivity ) ( by linarith [ Real.add_one_le_exp 1, Real.add_one_le_exp ( -1 ) ] : ( 1 + Real.exp 1 ) > 2 ) ] )

/-! ## Softplus Lipschitz Properties

`softplus_lipschitz` and `sigmoid_complement` are already provided by the imported
`MachineLearning.ShefferFunction.Lean.SoftplusBasic`, so the duplicate copies that used to
sit here (and which made this file fail to elaborate) have been removed.  The two auxiliary
identities that the rest of the file uses but that were missing are supplied instead. -/

/-- The sigmoid reflection identity `S(-x) = 1 - S(x)`.  (Supplied here: referenced but
missing.) -/
theorem logisticSigmoid_symmetry (x : ℝ) : logisticSigmoid (-x) = 1 - logisticSigmoid x := by
  have := sigmoid_complement x
  linarith

/-- `exp (softplus x) = 1 + exp x`.  (Supplied here: referenced but missing.) -/
theorem softplus_exp_identity (x : ℝ) : Real.exp (softplus x) = 1 + Real.exp x := by
  rw [softplus, Real.exp_log (one_add_exp_pos x)]

/-! ## Sigmoid Additional Properties -/

/-
Sigmoid is strictly monotone increasing
-/
theorem sigmoid_strictMono : StrictMono logisticSigmoid := by
  intro a b hab;
  rw [ logisticSigmoid, logisticSigmoid, div_lt_div_iff₀ ] <;> nlinarith [ Real.exp_pos a, Real.exp_lt_exp.2 hab ]

/-- Sigmoid product identity: S(x) · S(-x) = S(x)(1 - S(x)) -/
theorem sigmoid_product_identity (x : ℝ) :
    logisticSigmoid x * logisticSigmoid (-x) = logisticSigmoid x * (1 - logisticSigmoid x) := by
  congr 1
  linarith [logisticSigmoid_symmetry x]

/-! ## Softplus Algebraic Identities -/

/-- σ(x) + σ(-x) = 2σ(x) - x -/
theorem softplus_sum_identity (x : ℝ) :
    softplus x + softplus (-x) = 2 * softplus x - x := by
  have := softplus_reflection x
  linarith

/-- exp(σ(x) + σ(y)) = (1 + eˣ)(1 + eʸ) -/
theorem softplus_exp_sum (x y : ℝ) :
    exp (softplus x + softplus y) = (1 + exp x) * (1 + exp y) := by
  rw [exp_add, softplus_exp_identity, softplus_exp_identity]

/-- σ(x) = log(eˣ + e⁰) -/
theorem softplus_as_logsumexp (x : ℝ) :
    softplus x = Real.log (exp x + exp 0) := by
  simp [softplus, exp_zero, add_comm]

/-! ## Sheffer Degree Properties -/

/-- Softplus has Sheffer degree at most 1 -/
theorem softplus_sheffer_degree_le : shefferDegree softplus ≤ 1 := by
  unfold shefferDegree
  apply iInf_le_of_le ShefferExpr.base
  apply iInf_le_of_le rfl
  simp [ShefferExpr.depth]

/-! ## Continuous Properties -/

/-
Softplus is uniformly continuous (since it's 1-Lipschitz)
-/
theorem softplus_uniformContinuous : UniformContinuous softplus := by
  convert softplus_lipschitz.uniformContinuous using 1

/-! ## Temperature Family -/

/-- The temperature-scaled softplus: σ_β(x) = (1/β) · log(1 + exp(βx)) -/
def softplus_temp (β : ℝ) (x : ℝ) : ℝ := (1 / β) * Real.log (1 + Real.exp (β * x))

/-- For β = 1, the temperature softplus equals standard softplus -/
theorem softplus_temp_one : softplus_temp 1 = softplus := by
  ext x
  simp [softplus_temp, softplus]

/-- The temperature softplus is positive for β > 0 -/
theorem softplus_temp_pos {β : ℝ} (hβ : β > 0) (x : ℝ) : softplus_temp β x > 0 := by
  unfold softplus_temp
  apply mul_pos
  · exact div_pos one_pos hβ
  · exact Real.log_pos (by linarith [exp_pos (β * x)])

/-! ## Depth-Width Tradeoff -/

/-- Width of an affine combination is the sum of widths -/
theorem sheffer_width_affine_comb (α β γ : ℝ) (e₁ e₂ : ShefferExpr) :
    (ShefferExpr.affine_comb α β γ e₁ e₂).width = e₁.width + e₂.width := by
  simp [ShefferExpr.width]

/-- Width of a composition is the sum of widths -/
theorem sheffer_width_comp (e₁ e₂ : ShefferExpr) :
    (ShefferExpr.comp e₁ e₂).width = e₁.width + e₂.width := by
  simp [ShefferExpr.width]

/-- Affine pre-composition preserves width -/
theorem sheffer_width_affine_pre (a b : ℝ) (e : ShefferExpr) :
    (ShefferExpr.affine_pre a b e).width = e.width := by
  simp [ShefferExpr.width]

/-- Affine pre-composition preserves depth -/
theorem sheffer_depth_affine_pre (a b : ℝ) (e : ShefferExpr) :
    (ShefferExpr.affine_pre a b e).depth = e.depth := by
  simp [ShefferExpr.depth]

end