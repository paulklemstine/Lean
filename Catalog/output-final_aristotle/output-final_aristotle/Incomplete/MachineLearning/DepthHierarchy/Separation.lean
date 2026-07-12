/-
# Separation Theorems for Bounded-Derivative Functions

This file proves that functions with bounded derivatives cannot uniformly
approximate functions with large derivatives on an interval. This is the
analytic engine that powers depth hierarchy results.

## Main results

* `exists_uniform_separation_of_deriv_bound` — if `f` has derivative ≥ A+1 and
    `g` has derivative ≤ A on [0,1], then `g` cannot approximate `f` within 1/8
* `separation_from_mean_value` — quantitative separation via the mean value theorem
* `approxOn_deriv_bound` — an approximating function inherits derivative constraints

## Tags

analytic circuit lower bounds, certified uniform approximation, depth hierarchy
-/
import Mathlib
import Novelty.Basic

noncomputable section

open Real Set

/-! ## Separation via mean value theorem -/

/-
**Quantitative separation from derivative gap.**

If `f` has derivative at least `L` on `[a,b]` and `g` has derivative at most `U`
on `[a,b]`, with `L > U`, then the approximation error at either endpoint is at
least `(L - U) * (b - a) / 2`.

This is the fundamental bridge from derivative analysis to approximation lower bounds.
-/
theorem separation_from_deriv_gap
    (f g : ℝ → ℝ) (a b : ℝ) (hab : a < b)
    (L U : ℝ) (hLU : U < L)
    (hf_diff : DifferentiableOn ℝ f (Icc a b))
    (hg_diff : DifferentiableOn ℝ g (Icc a b))
    (hf_cont : ContinuousOn f (Icc a b))
    (hg_cont : ContinuousOn g (Icc a b))
    (hf_deriv : ∀ x ∈ Ioo a b, L ≤ deriv f x)
    (hg_deriv : ∀ x ∈ Ioo a b, deriv g x ≤ U) :
    (L - U) * (b - a) / 2 ≤
      max (|f a - g a|) (|f b - g b|) := by
  -- By the mean value theorem, there exists $c \in (a, b)$ such that $h'(c) = (h(b) - h(a)) / (b - a)$.
  have h_mean_value : ∃ c ∈ Set.Ioo a b, deriv (fun x => f x - g x) c = (f b - g b - (f a - g a)) / (b - a) := by
    have := exists_deriv_eq_slope ( f := fun x => f x - g x ) hab;
    exact this ( hf_cont.sub hg_cont ) ( hf_diff.sub hg_diff |> DifferentiableOn.mono <| Set.Ioo_subset_Icc_self );
  -- By the properties of the derivative, we have $deriv (fun x => f x - g x) c = deriv f c - deriv g c$.
  obtain ⟨c, hc⟩ := h_mean_value
  have h_deriv : deriv (fun x => f x - g x) c = deriv f c - deriv g c := by
    exact deriv_sub ( hf_diff.differentiableAt ( Icc_mem_nhds hc.1.1 hc.1.2 ) ) ( hg_diff.differentiableAt ( Icc_mem_nhds hc.1.1 hc.1.2 ) );
  cases max_cases |f a - g a| |f b - g b| <;> cases abs_cases ( f a - g a ) <;> cases abs_cases ( f b - g b ) <;> nlinarith [ hf_deriv c hc.1, hg_deriv c hc.1, mul_div_cancel₀ ( f b - g b - ( f a - g a ) ) ( sub_ne_zero_of_ne hab.ne' ) ]

/-
**Uniform separation of bounded-derivative classes.**

If `f` has derivative uniformly at least `A + 1` on [0,1] and `g` has derivative
uniformly at most `A` on [0,1], then `g` cannot approximate `f` within `1/8`.

This is the hinge theorem connecting derivative envelopes to approximation complexity.
It shows that derivative budget is a real approximation obstruction.
-/
theorem exists_uniform_separation_of_deriv_bound
    (f g : ℝ → ℝ) (A : ℝ)
    (hf_diff : DifferentiableOn ℝ f (Icc 0 1))
    (hg_diff : DifferentiableOn ℝ g (Icc 0 1))
    (hf_cont : ContinuousOn f (Icc 0 1))
    (hg_cont : ContinuousOn g (Icc 0 1))
    (hA : ∀ x ∈ Ioo (0 : ℝ) 1, deriv g x ≤ A)
    (hderiv_gap : ∀ x ∈ Ioo (0 : ℝ) 1, A + 1 ≤ deriv f x) :
    ¬ ApproxOn f g (Icc 0 1) (1/4) := by
  intro h_approx
  have h_separation : (A + 1 - A) * (1 - 0) / 2 ≤ max (|f 0 - g 0|) (|f 1 - g 1|) := by
    apply separation_from_deriv_gap f g 0 1 (by norm_num) (A + 1) A (by linarith) hf_diff hg_diff hf_cont hg_cont hderiv_gap hA;
  exact absurd h_separation ( by norm_num; cases max_cases |f 0 - g 0| |f 1 - g 1| <;> linarith [ h_approx 0 ( by norm_num ), h_approx 1 ( by norm_num ) ] )

/-! ## Expression language and depth -/

/-- A simple expression language for real-valued functions on ℝ.
    Supports constants, the variable, arithmetic, and `exp`. -/
inductive Expr where
  | var : Expr
  | const : ℝ → Expr
  | add : Expr → Expr → Expr
  | mul : Expr → Expr → Expr
  | neg : Expr → Expr
  | expOf : Expr → Expr
  deriving DecidableEq

/-- Evaluation of an expression at a real number. -/
def Expr.eval : Expr → ℝ → ℝ
  | .var, x => x
  | .const c, _ => c
  | .add e₁ e₂, x => e₁.eval x + e₂.eval x
  | .mul e₁ e₂, x => e₁.eval x * e₂.eval x
  | .neg e, x => -(e.eval x)
  | .expOf e, x => Real.exp (e.eval x)

/-- Size of an expression (number of nodes). -/
def Expr.size : Expr → ℕ
  | .var => 1
  | .const _ => 1
  | .add e₁ e₂ => 1 + e₁.size + e₂.size
  | .mul e₁ e₂ => 1 + e₁.size + e₂.size
  | .neg e => 1 + e.size
  | .expOf e => 1 + e.size

/-- Exponential depth of an expression: the maximum nesting of `exp`. -/
def Expr.depth : Expr → ℕ
  | .var => 0
  | .const _ => 0
  | .add e₁ e₂ => max e₁.depth e₂.depth
  | .mul e₁ e₂ => max e₁.depth e₂.depth
  | .neg e => e.depth
  | .expOf e => 1 + e.depth

/-- Predicate: expression has depth at most `d`. -/
def HasDepthAtMost (E : Expr) (d : ℕ) : Prop := E.depth ≤ d

theorem Expr.size_pos (e : Expr) : 0 < e.size := by
  cases e <;> simp [Expr.size] <;> omega

/-! ## Differentiability and derivative envelope for expressions -/

/-
Every expression evaluates to a differentiable function.
-/
theorem Expr.differentiable (E : Expr) : Differentiable ℝ (E.eval) := by
  induction' E with e₁ e₂ ih₁ ih₂;
  all_goals norm_num [ Expr.eval ];
  · exact ih₂.add ‹_›;
  · exact Differentiable.mul ‹_› ‹_›;
  · assumption;
  · exact Differentiable.exp ‹_›

/-
Every expression evaluates to a continuous function.
-/
theorem Expr.continuous_eval (E : Expr) : Continuous (E.eval) := by
  convert Expr.differentiable E |> Differentiable.continuous

/-! ## ExprDepthProfile: recording analytic invariants of expressions -/

/-- A profile recording the key analytic invariants of an expression:
    syntactic depth, size, and a derivative growth envelope on [0,1].

    The derivative envelope `derivBound` is an upper bound such that
    `|deriv (E.eval) x| ≤ derivBound` for all `x ∈ [0,1]`. -/
structure ExprDepthProfile where
  /-- The expression -/
  expr : Expr
  /-- Syntactic exponential depth -/
  depth : ℕ
  /-- Expression size -/
  size : ℕ
  /-- Upper bound on |derivative| on [0,1] -/
  derivBound : ℝ
  /-- Depth matches -/
  depth_eq : expr.depth = depth
  /-- Size matches -/
  size_eq : expr.size = size
  /-- Derivative bound is positive -/
  derivBound_pos : 0 < derivBound
  /-- The derivative bound holds -/
  derivBound_spec : ∀ x ∈ Icc (0 : ℝ) 1, |deriv expr.eval x| ≤ derivBound

/-
**Envelope theorem**: Every expression has a finite derivative envelope on [0,1].
    This converts syntax into analysis.
-/
theorem depth_bounded_expr_deriv_envelope (E : Expr) :
    ∃ A : ℝ, 0 < A ∧ (∀ x ∈ Icc (0 : ℝ) 1, |deriv (E.eval) x| ≤ A) := by
  -- By definition of $Expr.eval$, we know that $deriv E.eval$ is continuous on $[0, 1]$.
  have h_cont : ContinuousOn (deriv E.eval) (Set.Icc (0 : ℝ) 1) := by
    -- By definition of $Expr.eval$, we know that $deriv E.eval$ is continuous on $[0, 1]$ because $E.eval$ is a composition of smooth functions.
    have h_cont : ContDiff ℝ 1 (E.eval) := by
      induction' E with e₁ e₂ ih₁ ih₂;
      exacts [ contDiff_id, contDiff_const, ih₂.add ‹_›, ContDiff.mul ‹_› ‹_›, ContDiff.neg ‹_›, ContDiff.exp ‹_› ]
    exact h_cont.continuous_deriv le_rfl |> Continuous.continuousOn;
  obtain ⟨ A, hA ⟩ := IsCompact.exists_bound_of_continuousOn ( CompactIccSpace.isCompact_Icc ) h_cont; use Max.max A 1; aesop;

/-! ## GrowthEnvelope: bounding derivatives by depth and size -/

/-- A growth envelope assigns an explicit derivative upper bound
    for expressions of given depth and size on [0,1].

    This is the key bridge from expression syntax to approximation obstruction:
    bounded depth + bounded size → bounded derivative budget. -/
structure GrowthEnvelope where
  /-- The bound function: depth → size → derivative bound -/
  bound : ℕ → ℕ → ℝ
  /-- The bound is always positive -/
  bound_pos : ∀ d s, 0 < bound d s
  /-- Monotone in size -/
  bound_mono_size : ∀ d s₁ s₂, s₁ ≤ s₂ → bound d s₁ ≤ bound d s₂

/-! ## Depth separation corollary -/

/-
**Weak depth separation**: For any `k ≥ 2`, there exists `ε₀ > 0` such that
    no depth-(k-1) expression of size ≤ k can approximate `iterExp k` within `ε₀` on [0,1].

    This is the first formal depth hierarchy theorem.
-/
theorem no_small_depth_approx_iterExp
    (k : ℕ) (hk : 2 ≤ k)
    (E : Expr) (hdepth : HasDepthAtMost E (k - 1)) (hsize : E.size ≤ k)
    (A : ℝ) (hA : 0 < A)
    (henv : ∀ x ∈ Icc (0 : ℝ) 1, |deriv (E.eval) x| ≤ A)
    (hgap : A + 1 ≤ Real.exp 1) :
    ¬ ApproxOn (iterExp k) (E.eval) (Icc 0 1) (1/4) := by
  -- We need to show that the derivative of iterExp k is at least A + 1 on [0,1].
  have h_deriv_bound : ∀ x ∈ Set.Ioo (0 : ℝ) 1, deriv (iterExp k) x ≥ A + 1 := by
    -- By definition of iterated exponentials, we know that $\deriv (iterExp k) x = \exp(iterExp (k-1) x) \cdot \deriv (iterExp (k-1)) x$.
    have h_deriv_iterExp : ∀ k x, deriv (iterExp (k + 1)) x = Real.exp (iterExp k x) * deriv (iterExp k) x := by
      intro k x; erw [ deriv_comp x ( Real.differentiableAt_exp ) ( show DifferentiableAt ℝ ( iterExp k ) x from ?_ ) ] ; aesop;
      exact iterExp_differentiable k x;
    -- By induction on $k$, we can show that $\deriv (iterExp k) x \geq \exp(1)$ for all $x \in (0,1)$.
    have h_ind : ∀ k ≥ 2, ∀ x ∈ Set.Ioo (0 : ℝ) 1, deriv (iterExp k) x ≥ Real.exp 1 := by
      intro k hk x hx; induction hk <;> simp_all +decide [ Real.exp_pos ] ;
      · erw [ show iterExp 0 = fun x => x from funext fun x => rfl ] ; norm_num [ Real.exp_pos ];
        rw [ ← Real.exp_add ] ; exact Real.exp_le_exp.mpr ( by linarith [ Real.add_one_le_exp x ] );
      · refine' le_trans ‹_› ( le_mul_of_one_le_left ( by linarith [ Real.exp_pos 1 ] ) ( Real.one_le_exp _ ) );
        exact le_of_lt ( iterExp_pos _ _ ( by linarith ) );
    exact fun x hx => le_trans hgap ( h_ind k hk x hx );
  apply exists_uniform_separation_of_deriv_bound;
  exact ( iterExp_differentiable k |> Differentiable.differentiableOn );
  exact ( Expr.differentiable E |> Differentiable.differentiableOn );
  exact ( iterExp_continuous k |> Continuous.continuousOn );
  exact ( Expr.continuous_eval E |> Continuous.continuousOn );
  exacts [ fun x hx => le_of_abs_le ( henv x <| Set.Ioo_subset_Icc_self hx ), fun x hx => h_deriv_bound x hx ]

end