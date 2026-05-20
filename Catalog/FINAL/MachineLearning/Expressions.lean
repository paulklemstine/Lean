import Mathlib
import Speculative.DerivDepth.IterExp

/-!
# Expression Derivative Bounds and Depth Separation

This file defines a smooth expression language (the exp-fragment) and establishes
that derivative growth is controlled by compositional depth via tower bounds.

## Main Definitions

- `SmoothExpr`: expression type with var, const, add, mul, exp
- `SmoothExpr.eval`: total evaluation semantics
- `SmoothExpr.depth`: syntactic depth
- `SmoothExpr.allBoundedOn`: subexpression boundedness predicate
- `SmoothExpr.certDerivBound`: certified recursive derivative upper bound
- `towerExpr`: canonical depth-k iterated exponential expression

## Main Results

- `SmoothExpr.eval_differentiable`: all expressions are differentiable
- `SmoothExpr.eval_hasDerivAt`: exact derivative by structural recursion
- `certDerivBound_sound`: the certified bound is sound
- `certDerivBound_le_depthMajorant_exp_fragment`: for the exp-fragment,
  the certified bound is ≤ the tower majorant
- `not_representable_of_deriv_exceeds`: depth separation via derivative obstruction
-/

noncomputable section
open Real Finset

/-! ## Expression Language -/

/-- A smooth expression over ℝ supporting constants, the variable,
    addition, multiplication, and exponentiation. -/
inductive SmoothExpr where
  | var   : SmoothExpr
  | const : ℝ → SmoothExpr
  | add   : SmoothExpr → SmoothExpr → SmoothExpr
  | mul   : SmoothExpr → SmoothExpr → SmoothExpr
  | exp   : SmoothExpr → SmoothExpr

namespace SmoothExpr

/-! ## Evaluation Semantics -/

/-- Total evaluation of a smooth expression at a real number. -/
def eval : SmoothExpr → ℝ → ℝ
  | .var, x => x
  | .const c, _ => c
  | .add e₁ e₂, x => e₁.eval x + e₂.eval x
  | .mul e₁ e₂, x => e₁.eval x * e₂.eval x
  | .exp e, x => Real.exp (e.eval x)

@[simp] theorem eval_var (x : ℝ) : (SmoothExpr.var).eval x = x := rfl
@[simp] theorem eval_const (c x : ℝ) : (SmoothExpr.const c).eval x = c := rfl
@[simp] theorem eval_add (e₁ e₂ : SmoothExpr) (x : ℝ) :
    (SmoothExpr.add e₁ e₂).eval x = e₁.eval x + e₂.eval x := rfl
@[simp] theorem eval_mul (e₁ e₂ : SmoothExpr) (x : ℝ) :
    (SmoothExpr.mul e₁ e₂).eval x = e₁.eval x * e₂.eval x := rfl
@[simp] theorem eval_exp (e : SmoothExpr) (x : ℝ) :
    (SmoothExpr.exp e).eval x = Real.exp (e.eval x) := rfl

/-! ## Depth -/

/-- Syntactic depth of a smooth expression. -/
def depth : SmoothExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add e₁ e₂ => 1 + max e₁.depth e₂.depth
  | .mul e₁ e₂ => 1 + max e₁.depth e₂.depth
  | .exp e => 1 + e.depth

/-! ## Subexpression Boundedness -/

/-- Predicate: expression and all its subexpressions have eval bounded by `M`
    (in absolute value) on the interval `I`. -/
def allBoundedOn (E : SmoothExpr) (I : Set ℝ) (M : ℝ) : Prop :=
  (∀ x ∈ I, |E.eval x| ≤ M) ∧
  match E with
  | .var => True
  | .const _ => True
  | .add e₁ e₂ => e₁.allBoundedOn I M ∧ e₂.allBoundedOn I M
  | .mul e₁ e₂ => e₁.allBoundedOn I M ∧ e₂.allBoundedOn I M
  | .exp e => e.allBoundedOn I M

/-- Convenience: subexpression boundedness on `[0,1]`. -/
abbrev SubexprBoundedOn (E : SmoothExpr) (M : ℝ) : Prop :=
  E.allBoundedOn (Set.Icc 0 1) M

/-- Subexpression boundedness implies the expression itself is bounded. -/
theorem allBoundedOn_self {E : SmoothExpr} {I : Set ℝ} {M : ℝ}
    (h : E.allBoundedOn I M) : ∀ x ∈ I, |E.eval x| ≤ M := by
  unfold allBoundedOn at h; exact h.1

/-! ## Exp Fragment -/

/-- Predicate: expression is in the exp-composition fragment (var, const, exp only). -/
inductive InExpFragment : SmoothExpr → Prop where
  | var : InExpFragment .var
  | const (c : ℝ) : InExpFragment (.const c)
  | exp {e : SmoothExpr} : InExpFragment e → InExpFragment (.exp e)

/-! ## Canonical Tower Expression -/

/-- The canonical depth-`k` tower expression: `exp(exp(...exp(var)...))` with `k` layers. -/
def towerExpr : ℕ → SmoothExpr
  | 0 => .var
  | n + 1 => .exp (towerExpr n)

@[simp] theorem towerExpr_zero : towerExpr 0 = .var := rfl
@[simp] theorem towerExpr_succ (k : ℕ) : towerExpr (k + 1) = .exp (towerExpr k) := rfl

/-- The tower expression evaluates to `iterExp k`. -/
theorem towerExpr_eval (k : ℕ) (x : ℝ) : (towerExpr k).eval x = iterExp k x := by
  induction k with
  | zero => simp [iterExp]
  | succ n ih => simp [iterExp, ih]

/-- The depth of `towerExpr k` is exactly `k`. -/
theorem towerExpr_depth (k : ℕ) : (towerExpr k).depth = k := by
  induction k with
  | zero => rfl
  | succ n ih => simp [towerExpr, depth, ih]; omega

/-- `towerExpr k` is in the exp fragment. -/
theorem towerExpr_inExpFragment (k : ℕ) : InExpFragment (towerExpr k) := by
  induction k with
  | zero => exact InExpFragment.var
  | succ n ih => exact InExpFragment.exp ih

/-! ## Differentiability -/

/-- Every smooth expression defines a differentiable function. -/
theorem eval_differentiable (E : SmoothExpr) : Differentiable ℝ E.eval := by
  induction E with
  | var => exact differentiable_id
  | const c => exact differentiable_const c
  | add e₁ e₂ ih₁ ih₂ => exact ih₁.add ih₂
  | mul e₁ e₂ ih₁ ih₂ => exact ih₁.mul ih₂
  | exp e ih => exact ih.exp

/-! ## Exact Derivative by Structural Recursion -/

/-- The syntactic derivative of a smooth expression, computed recursively. -/
def evalDeriv : SmoothExpr → ℝ → ℝ
  | .var, _ => 1
  | .const _, _ => 0
  | .add e₁ e₂, x => e₁.evalDeriv x + e₂.evalDeriv x
  | .mul e₁ e₂, x => e₁.evalDeriv x * e₂.eval x + e₁.eval x * e₂.evalDeriv x
  | .exp e, x => Real.exp (e.eval x) * e.evalDeriv x

/-
The structural derivative formula is correct: `HasDerivAt E.eval (E.evalDeriv x) x`.
-/
theorem eval_hasDerivAt (E : SmoothExpr) (x : ℝ) :
    HasDerivAt E.eval (E.evalDeriv x) x := by
  induction' E with e₁ e₂ ih₁ ih₂;
  · convert hasDerivAt_id x using 1;
  · convert hasDerivAt_const x e₁ using 1;
  · convert HasDerivAt.add ih₂ ‹_› using 1;
  · rename_i e₁ e₂ ih₁ ih₂;
    convert HasDerivAt.mul ih₁ ih₂ using 1;
  · convert HasDerivAt.exp ‹_› using 1

/-- Corollary: the Lean `deriv` of `E.eval` equals `E.evalDeriv`. -/
theorem eval_deriv_eq (E : SmoothExpr) (x : ℝ) :
    deriv E.eval x = E.evalDeriv x :=
  (E.eval_hasDerivAt x).deriv

/-! ## Certified Derivative Bound -/

/-- A recursive upper bound on `|E.evalDeriv x|`, assuming all subexpression
    values are bounded by `M`. This is the core of the certified derivative algorithm. -/
def certDerivBound : SmoothExpr → ℝ → ℝ
  | .var, _ => 1
  | .const _, _ => 0
  | .add e₁ e₂, M => e₁.certDerivBound M + e₂.certDerivBound M
  | .mul e₁ e₂, M => M * e₂.certDerivBound M + e₁.certDerivBound M * M
  | .exp e, M => M * e.certDerivBound M

/-
**Soundness**: The certified bound is a valid upper bound on the derivative norm,
    assuming subexpression boundedness.
-/
theorem certDerivBound_sound (E : SmoothExpr) (M : ℝ)
    (hM : 0 ≤ M) (hbdd : E.SubexprBoundedOn M) :
    ∀ x ∈ Set.Icc (0 : ℝ) 1,
      |E.evalDeriv x| ≤ E.certDerivBound M := by
  -- By induction on the structure of E, we can show that the certified derivative bound is valid.
  induction' E with e₁ e₂ ih₁ ih₂ generalizing M;
  · exact fun x hx => by rw [ show var.evalDeriv x = 1 by rfl ] ; rw [ show var.certDerivBound M = 1 by rfl ] ; norm_num;
  · exact fun x _ => by erw [ show ( const e₁ ).evalDeriv x = 0 by rfl ] ; norm_num [ SmoothExpr.certDerivBound ] ;
  · grind +locals;
  · rename_i e₁ e₂ ih₁ ih₂;
    intro x hx;
    -- By definition of `SubexprBoundedOn`, we know that `e₁` and `e₂` are bounded by `M`.
    have h_bdd₁ : e₁.SubexprBoundedOn M := by
      exact hbdd.2.1
    have h_bdd₂ : e₂.SubexprBoundedOn M := by
      exact hbdd.2.2;
    have h_bdd₁ : ∀ x ∈ Set.Icc 0 1, |e₁.eval x| ≤ M := by
      grind +suggestions
    have h_bdd₂ : ∀ x ∈ Set.Icc 0 1, |e₂.eval x| ≤ M := by
      grind +suggestions;
    simp_all +decide [ SmoothExpr.evalDeriv, SmoothExpr.certDerivBound ];
    exact abs_le.mpr ⟨ by nlinarith [ abs_le.mp ( ih₁ M hM ‹_› x hx.1 hx.2 ), abs_le.mp ( ih₂ M hM ‹_› x hx.1 hx.2 ), abs_le.mp ( h_bdd₁ x hx.1 hx.2 ), abs_le.mp ( h_bdd₂ x hx.1 hx.2 ) ], by nlinarith [ abs_le.mp ( ih₁ M hM ‹_› x hx.1 hx.2 ), abs_le.mp ( ih₂ M hM ‹_› x hx.1 hx.2 ), abs_le.mp ( h_bdd₁ x hx.1 hx.2 ), abs_le.mp ( h_bdd₂ x hx.1 hx.2 ) ] ⟩;
  · intro x hx;
    cases' hbdd with hbdd₁ hbdd₂;
    rename_i e ih;
    simp_all +decide [ SmoothExpr.evalDeriv, SmoothExpr.certDerivBound ];
    exact mul_le_mul ( hbdd₁ x hx.1 hx.2 ) ( ih M hM hbdd₂ x hx.1 hx.2 ) ( by positivity ) ( by positivity )

/-- **Corollary**: The norm of `deriv E.eval` is bounded by `certDerivBound`. -/
theorem deriv_norm_le_certDerivBound (E : SmoothExpr) (M : ℝ)
    (hM : 0 ≤ M) (hbdd : E.SubexprBoundedOn M) :
    ∀ x ∈ Set.Icc (0 : ℝ) 1,
      ‖deriv E.eval x‖ ≤ E.certDerivBound M := by
  intro x hx
  rw [E.eval_deriv_eq, Real.norm_eq_abs]
  exact E.certDerivBound_sound M hM hbdd x hx

/-! ## CertDerivBound ≤ DepthMajorant for Exp Fragment -/

/-
For the exp fragment, the certified bound on `towerExpr k` equals `M^k`.
-/
theorem certDerivBound_towerExpr (k : ℕ) (M : ℝ) :
    (towerExpr k).certDerivBound M = M ^ k := by
  induction k <;> simp_all +decide [ pow_succ' ];
  · rfl;
  · simp [certDerivBound, *]

/-
Key inequality: `M^k ≤ iterExp k M` for `M ≥ 1`.
-/
theorem pow_le_iterExp (k : ℕ) (M : ℝ) (hM : 1 ≤ M) :
    M ^ k ≤ iterExp k M := by
  induction' k with k ih generalizing M;
  · simp [iterExp]; linarith;
  · rw [ pow_succ' ];
    refine' le_trans ( mul_le_mul_of_nonneg_left ( ih M hM ) ( by positivity ) ) _;
    exact mul_le_exp_of_le _ _ ( by linarith ) ( by linarith [ iterExp_ge_self k M ( by linarith ) ] )

/-- **Depth majorant bound for the exp fragment**: For `towerExpr k` with
    subexpressions bounded by `M ≥ 1`, the certified derivative bound
    is at most `depthMajorant k M`. -/
theorem certDerivBound_le_depthMajorant_towerExpr (k : ℕ) (M : ℝ) (hM : 1 ≤ M) :
    (towerExpr k).certDerivBound M ≤ depthMajorant k M := by
  rw [certDerivBound_towerExpr]
  exact pow_le_iterExp k M hM

/-
For any exp-fragment expression E, the certified derivative bound is at most
    `depthMajorant E.depth M`. This is the general version.
-/
theorem certDerivBound_le_depthMajorant_expFragment (E : SmoothExpr) (M : ℝ)
    (hM : 1 ≤ M) (hfrag : E.InExpFragment) :
    E.certDerivBound M ≤ depthMajorant E.depth M := by
  nontriviality;
  induction' hfrag with E hE ih;
  · exact show 1 ≤ M from hM;
  · exact le_trans ( by norm_num [ SmoothExpr.certDerivBound ] ) ( show 0 ≤ iterExp 0 M from by exact le_trans ( by positivity ) ( iterExp_ge_self 0 M ( by positivity ) ) );
  · -- By the induction hypothesis, we have `certDerivBound hE M ≤ depthMajorant hE.depth M`.
    have ih_step : M * hE.certDerivBound M ≤ M * depthMajorant hE.depth M := by
      exact mul_le_mul_of_nonneg_left ‹_› ( by positivity );
    -- By the properties of the exponential function and the induction hypothesis, we have `M * depthMajorant hE.depth M ≤ depthMajorant (hE.depth + 1) M`.
    have ih_exp : M * depthMajorant hE.depth M ≤ depthMajorant (hE.depth + 1) M := by
      convert mul_le_exp_of_le M ( depthMajorant hE.depth M ) ( by positivity ) ( iterExp_ge_self _ _ ( by positivity ) ) using 1;
    convert ih_step.trans ih_exp using 1;
    exact congr_arg₂ _ ( by rw [ show hE.exp.depth = 1 + hE.depth from rfl ] ; ring ) rfl

/-! ## Depth Separation Theorem -/

/-
**Semantic depth separation via derivative obstruction.**

    If a function `f` has derivative exceeding the depth-`d` tower majorant
    somewhere on `[0,1]`, then `f` cannot be the evaluation of any smooth expression
    of depth ≤ `d` with subexpressions bounded by `M`.

    This converts analytic measurements into structural lower bounds on syntax depth.
-/
theorem not_representable_of_deriv_exceeds
    (f : ℝ → ℝ) (d : ℕ) (M : ℝ)
    (hM : 1 ≤ M)
    (hexceed : ∃ x ∈ Set.Icc (0 : ℝ) 1,
      depthMajorant d M < |deriv f x|) :
    ¬ ∃ E : SmoothExpr,
        E.depth ≤ d ∧
        E.InExpFragment ∧
        E.SubexprBoundedOn M ∧
        (∀ x, E.eval x = f x) := by
  contrapose! hexceed;
  intros x hx
  obtain ⟨E, hE_depth, hE_frag, hE_bdd, hE_eval⟩ := hexceed
  have h_deriv : deriv f x = deriv E.eval x := by
    rw [ show f = E.eval from funext fun x => hE_eval x ▸ rfl ];
  rw [ h_deriv, eval_deriv_eq ];
  exact le_trans ( certDerivBound_sound E M ( by linarith ) hE_bdd x hx ) ( le_trans ( certDerivBound_le_depthMajorant_expFragment E M hM hE_frag ) ( depthMajorant_mono_depth _ _ hE_depth M ( by linarith ) ) )

/-
**Internal depth lower bound**: if the derivative of an exp-fragment expression
    exceeds the tower bound, the expression's depth must exceed `d`.
-/
theorem depth_lower_bound_from_derivative
    (E : SmoothExpr) (d : ℕ) (M : ℝ)
    (hM : 1 ≤ M)
    (hfrag : E.InExpFragment)
    (hexceed : ∃ x ∈ Set.Icc (0 : ℝ) 1,
      depthMajorant d M < |deriv E.eval x|)
    (hbounded : E.SubexprBoundedOn M) :
    d < E.depth := by
  contrapose! hexceed;
  intro x hx;
  convert le_trans _ ( depthMajorant_mono_depth _ _ hexceed _ _ );
  · convert certDerivBound_sound E M ( by linarith ) hbounded x hx |> le_trans <| certDerivBound_le_depthMajorant_expFragment E M hM hfrag using 11;
    exact funext fun x => eval_deriv_eq E x;
  · grind +qlia

end SmoothExpr

end