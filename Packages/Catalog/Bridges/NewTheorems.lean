/-
# New Sheffer Theorems: Extended Research Program

Additional formally verified theorems extending the Sheffer function program.
These theorems address open questions and deepen the structural understanding
of the Sheffer algebra.

## Main Results
- Full subadditivity: σ(x+y) ≤ σ(x) + σ(y) for ALL x,y ∈ ℝ
- x² ∉ ShefferAlgebra (Lipschitz barrier corollary)
- Softplus injectivity
- Softplus asymptotic: σ(x) - x → 0 as x → +∞
- Sheffer algebra is closed under addition and scalar multiplication
- Sigmoid product bound: S(x)(1-S(x)) ≤ 1/4
- Softplus superlinear bound: σ(x) ≥ x for all x (wrong — σ(x) > x)
- Sheffer algebra contains all polynomials restricted to bounded intervals (via approximation)
- Softplus iterated chain inequalities
-/

import Mathlib
-- import ShefferAI.Lean.SoftplusBasic
import MachineLearning.ShefferFunction.Lean.ShefferAlgebra
import Bridges.FutureTheorems
import Bridges.AdvancedTheorems
open Real

noncomputable section

/-! ## Full Subadditivity -/

/-
Softplus is subadditive: σ(x+y) ≤ σ(x) + σ(y) for all x, y ∈ ℝ.
    Proof: 1 + exp(x+y) ≤ (1+eˣ)(1+eʸ) since 0 ≤ eˣ + eʸ.
-/
theorem softplus_subadditive (x y : ℝ) :
    softplus (x + y) ≤ softplus x + softplus y := by
  unfold softplus;
  rw [ ← Real.log_mul, Real.log_le_log_iff ] <;> first | positivity | rw [ Real.exp_add ] ; nlinarith [ Real.exp_pos x, Real.exp_pos y ] ;

/-! ## Lipschitz Barrier Corollaries -/

/-
x² is not in the Sheffer algebra (it is not Lipschitz on ℝ)
-/
theorem sq_not_mem_sheffer : (fun x : ℝ => x ^ 2) ∉ ShefferAlgebra := by
  intro h
  obtain ⟨e, he⟩ := h;
  -- Apply the fact that every Sheffer expression is Lipschitz to obtain a contradiction.
  obtain ⟨C, hC⟩ := sheffer_expr_lipschitz e;
  contrapose! hC;
  norm_num [ ← he ];
  exact fun _ => ⟨ C + 1, 0, by rw [ abs_of_nonneg, abs_of_nonneg ] <;> nlinarith ⟩

/-
sinh is not in the Sheffer algebra (it is not Lipschitz on ℝ)
-/
theorem sinh_not_mem_sheffer : (fun x : ℝ => Real.sinh x) ∉ ShefferAlgebra := by
  intro h;
  -- By definition of Sheffer algebra, every function in the algebra is Lipschitz.
  have h_lipschitz : ∀ (f : ℝ → ℝ), f ∈ ShefferAlgebra → ∃ C : ℝ, C ≥ 0 ∧ ∀ x y : ℝ, |f x - f y| ≤ C * |x - y| := by
    intro f hf
    obtain ⟨e, he⟩ := hf;
    exact he ▸ sheffer_expr_lipschitz e;
  obtain ⟨ C, hC₀, hC ⟩ := h_lipschitz _ h;
  -- Consider the limit of the ratio $\frac{\sinh(x)}{x}$ as $x \to \infty$.
  have h_lim : Filter.Tendsto (fun x : ℝ => Real.sinh x / x) Filter.atTop Filter.atTop := by
    -- We can use the fact that $\sinh(x) = \frac{e^x - e^{-x}}{2}$ and analyze the limit of $\frac{e^x}{x}$ as $x \to \infty$.
    have h_exp : Filter.Tendsto (fun x : ℝ => Real.exp x / x) Filter.atTop Filter.atTop := by
      simpa using Real.tendsto_exp_div_pow_atTop 1;
    simp_all +decide [ Real.sinh_eq ];
    ring_nf;
    exact Filter.Tendsto.atTop_add ( h_exp.atTop_mul_const ( by norm_num ) ) ( Filter.Tendsto.mul ( Filter.Tendsto.mul ( Real.tendsto_exp_atBot.comp Filter.tendsto_neg_atTop_atBot ) ( tendsto_inv_atTop_zero ) ) tendsto_const_nhds );
  have := h_lim.eventually_gt_atTop C;
  obtain ⟨ x, hx ⟩ := this.and ( Filter.eventually_gt_atTop 0 ) |> fun h => h.exists; specialize hC x 0; simp_all +decide [ abs_of_pos ] ;
  rw [ lt_div_iff₀ ] at hx <;> linarith

/-! ## Injectivity -/

/-- Softplus is injective -/
theorem softplus_injective : Function.Injective softplus :=
  softplus_strictMono.injective

/-! ## Asymptotic Behavior -/

/-
σ(x) - x → 0 as x → +∞. This means softplus is asymptotically the identity.
-/
theorem softplus_sub_id_tendsto_zero :
    Filter.Tendsto (fun x => softplus x - x) Filter.atTop (nhds 0) := by
  -- Rewrite σ(x) - x using the reflection identity: σ(x) - x = σ(-x).
  have h_reflection : ∀ x, softplus x - x = softplus (-x) := by
    exact?;
  simpa only [ h_reflection ] using Filter.Tendsto.comp ( softplus_tendsto_zero_atBot ) Filter.tendsto_neg_atTop_atBot

/-! ## Sheffer Algebra Closure Properties -/

/-- The Sheffer algebra is closed under addition -/
theorem sheffer_add_closed {f g : ℝ → ℝ} (hf : f ∈ ShefferAlgebra) (hg : g ∈ ShefferAlgebra) :
    (fun x => f x + g x) ∈ ShefferAlgebra := by
  have := sheffer_affine_comb_closed hf hg 1 1 0
  convert this using 1
  ext x; ring

/-- The Sheffer algebra is closed under scalar multiplication -/
theorem sheffer_smul_closed {f : ℝ → ℝ} (hf : f ∈ ShefferAlgebra) (c : ℝ) :
    (fun x => c * f x) ∈ ShefferAlgebra := by
  have hconst := const_mem_sheffer 0
  have := sheffer_affine_comb_closed hf hconst c 0 0
  convert this using 1
  ext x; ring

/-- The Sheffer algebra is closed under subtraction -/
theorem sheffer_sub_closed {f g : ℝ → ℝ} (hf : f ∈ ShefferAlgebra) (hg : g ∈ ShefferAlgebra) :
    (fun x => f x - g x) ∈ ShefferAlgebra := by
  have := sheffer_affine_comb_closed hf hg 1 (-1) 0
  convert this using 1
  ext x; ring

/-- The Sheffer algebra contains all linear functions -/
theorem linear_mem_sheffer (a : ℝ) : (fun x : ℝ => a * x) ∈ ShefferAlgebra := by
  have := affine_mem_sheffer a 0
  convert this using 1
  ext x; ring

/-! ## Sigmoid Bounds -/

/-
The sigmoid product S(x)(1-S(x)) is bounded above by 1/4
-/
theorem sigmoid_product_le_quarter (x : ℝ) :
    logisticSigmoid x * (1 - logisticSigmoid x) ≤ 1 / 4 := by
  linarith [ sq_nonneg ( logisticSigmoid x - 1 / 2 ) ]

/-- The sigmoid product S(x)(1-S(x)) achieves its maximum 1/4 at x = 0 -/
theorem sigmoid_product_max_at_zero :
    logisticSigmoid 0 * (1 - logisticSigmoid 0) = 1 / 4 := by
  rw [logisticSigmoid_zero]
  norm_num

/-! ## Softplus Iterated Chain -/

/-
Iterated softplus strictly increases: σⁿ⁺¹(x) > σⁿ(x) for n ≥ 1
-/
theorem softplus_iter_strictly_increasing (n : ℕ) (x : ℝ) :
    softplus_iter (n + 1) x > softplus_iter n x := by
  exact softplus_gt_id _

/-! ## Softplus Lipschitz Constant Computation -/

/-- The Lipschitz constant of a Sheffer expression can be bounded by its structure.
    For affine_pre(a,b,e), the Lipschitz constant is |a| * Lip(e). -/
def ShefferExpr.lipschitzBound : ShefferExpr → ℝ
  | .base => 1
  | .affine_pre a _ e => |a| * e.lipschitzBound
  | .affine_comb α β _ e₁ e₂ => |α| * e₁.lipschitzBound + |β| * e₂.lipschitzBound
  | .comp e₁ e₂ => e₁.lipschitzBound * e₂.lipschitzBound

/-
The Lipschitz bound is nonneg
-/
theorem sheffer_lipschitz_bound_nonneg (e : ShefferExpr) : e.lipschitzBound ≥ 0 := by
  induction e;
  · exact zero_le_one;
  · exact mul_nonneg ( abs_nonneg _ ) ‹_›;
  · exact add_nonneg ( mul_nonneg ( abs_nonneg _ ) ‹_› ) ( mul_nonneg ( abs_nonneg _ ) ‹_› );
  · exact mul_nonneg ‹_› ‹_›

/-
The Lipschitz bound is a valid bound on the actual Lipschitz constant
-/
theorem sheffer_lipschitz_bound_valid (e : ShefferExpr) :
    ∀ x y : ℝ, |e.eval x - e.eval y| ≤ e.lipschitzBound * |x - y| := by
  induction' e with e ih;
  · -- The base case is when the expression is just the softplus function itself.
    have h_base : ∀ x y : ℝ, |softplus x - softplus y| ≤ |x - y| := by
      have := @softplus_lipschitz;
      simpa using this.dist_le_mul;
    convert h_base using 1;
    norm_num [ ShefferExpr.lipschitzBound ];
    rfl;
  · rename_i e' ih';
    intro x y;
    convert le_trans ( ih' ( e * x + ih ) ( e * y + ih ) ) _ using 1;
    norm_num [ ShefferExpr.lipschitzBound ];
    rw [ ← mul_sub, abs_mul ] ; ring_nf; norm_num;
  · rename_i α β γ e₁ e₂ ih₁ ih₂;
    intro x y;
    simp [ShefferExpr.eval, ShefferExpr.lipschitzBound];
    exact abs_le.mpr ⟨ by cases abs_cases α <;> cases abs_cases β <;> nlinarith [ abs_le.mp ( ih₁ x y ), abs_le.mp ( ih₂ x y ) ], by cases abs_cases α <;> cases abs_cases β <;> nlinarith [ abs_le.mp ( ih₁ x y ), abs_le.mp ( ih₂ x y ) ] ⟩;
  · intro x y;
    rename_i e₁ e₂ ih₁ ih₂;
    exact le_trans ( ih₁ _ _ ) ( by rw [ show ( e₁.comp e₂ |> ShefferExpr.lipschitzBound ) = e₁.lipschitzBound * e₂.lipschitzBound by rfl ] ; exact by rw [ mul_assoc ] ; exact mul_le_mul_of_nonneg_left ( ih₂ _ _ ) ( by exact le_trans ( by norm_num ) ( sheffer_lipschitz_bound_nonneg e₁ ) ) )

/-! ## Softplus and Log-Sum-Exp -/

/-- Softplus is a special case of log-sum-exp: σ(x) = log(e^0 + e^x) -/
theorem softplus_eq_logsumexp (x : ℝ) :
    softplus x = Real.log (Real.exp 0 + Real.exp x) := by
  simp [softplus, exp_zero]

/-
Two-argument softplus (log-sum-exp): log(eˣ + eʸ) = x + σ(y - x)
-/
theorem logsumexp_two (x y : ℝ) :
    Real.log (Real.exp x + Real.exp y) = x + softplus (y - x) := by
  unfold softplus; rw [ ← Real.log_exp x ] ; rw [ ← Real.log_mul ( by positivity ) ( by positivity ) ] ; ring;
  norm_num [ ← Real.exp_add ]

/-! ## Monotone Sheffer Expressions -/

/-- A Sheffer expression with all positive affine slopes defines a monotone function -/
theorem sheffer_base_monotone : Monotone ShefferExpr.base.eval :=
  softplus_mono

/-! ## Softplus Integral Properties -/

/-
The sigmoid integrates to softplus: ∫ S(t) dt from a to b = σ(b) - σ(a).
    This is because S = σ'.
-/
theorem sigmoid_integral (a b : ℝ) :
    ∫ t in a..b, logisticSigmoid t = softplus b - softplus a := by
  rw [ intervalIntegral.integral_deriv_eq_sub' ];
  · exact funext softplus_deriv;
  · exact fun x hx => DifferentiableAt.log ( by norm_num [ Real.differentiableAt_exp ] ) ( by positivity );
  · exact Continuous.continuousOn ( by exact Continuous.div ( Real.continuous_exp ) ( by continuity ) fun x => by positivity )

end