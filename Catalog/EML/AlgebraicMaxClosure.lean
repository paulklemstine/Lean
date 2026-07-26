import Mathlib

/-!
# Quantitative Algebraic-Compositional Universal Approximation Calculus

This file develops a **quantitative approximation calculus** for function approximation
on compact sets. We prove that approximation errors propagate through addition,
scalar multiplication, multiplication, and max with explicit, sharp bounds.

## Main results

### Elementary inequalities
* `max_lipschitz_add` — `|max a b - max c d| ≤ |a - c| + |b - d|`
* `mul_sub_mul_bound` — Leibniz product error: `|f·g - F·G| ≤ |f|·|g-G| + |G|·|f-F|`
* `mul_sub_mul_bounded` — Bounded Leibniz: `≤ Bf·εg + Mg·εf`

### Pointwise approximation closure
* `approx_add` — Addition preserves approximation with summed errors
* `approx_smul` — Scalar multiplication scales error by `|c|`
* `approx_mul` — Multiplication with Leibniz-type error bound
* `approx_max` — Max with sharp error bound

### Expression tree calculus
* `EMLExprR` — Expression trees built from variables, constants, add, mul, max
* `EMLExprR.eval` — Evaluation semantics
* `EMLExprR.boundVal` — Structural value bound propagation
* `EMLExprR.errBound` — Structural error bound propagation
* `approx_expr` — **Main theorem**: any expression in approximable generators
  is approximable with explicit propagated error and value bounds

### Log-sum-exp bridge
* `softmax_lower` / `softmax_upper` — Tropical-analytic bridge inequalities
* `softmax_error` — `|softmax(a,b) - max(a,b)| ≤ τ · log 2`
-/

open Finset BigOperators

noncomputable section

/-! ## Section 1: Elementary Real Inequalities -/

/-
Weaker but sometimes more convenient additive form of the max-Lipschitz bound.
Follows from `abs_max_sub_max_le_max` and `max ≤ sum`.
-/
theorem max_lipschitz_add (a b c d : ℝ) :
    |max a b - max c d| ≤ |a - c| + |b - d| := by
  cases max_cases a b <;> cases max_cases c d <;> cases abs_cases ( a - c ) <;> cases abs_cases ( b - d ) <;> cases abs_cases ( max a b - max c d ) <;> linarith

/-
**Leibniz product error bound (telescoping form).**
`|f·g - F·G| ≤ |f|·|g - G| + |G|·|f - F|`

Uses the decomposition `f·g - F·G = f·(g - G) + G·(f - F)`.
-/
theorem mul_sub_mul_bound (f g F G : ℝ) :
    |f * g - F * G| ≤ |f| * |g - G| + |G| * |f - F| := by
  rw [ ← abs_mul, ← abs_mul ];
  cases abs_cases ( f * g - F * G ) <;> cases abs_cases ( f * ( g - G ) ) <;> cases abs_cases ( G * ( f - F ) ) <;> linarith

/-
Symmetric Leibniz bound with cross-error term.
`|f·g - F·G| ≤ |F|·|g - G| + |g|·|f - F|`
-/
theorem mul_sub_mul_bound' (f g F G : ℝ) :
    |f * g - F * G| ≤ |F| * |g - G| + |g| * |f - F| := by
  rw [ ← abs_mul, ← abs_mul ];
  grind +locals

/-
**Fully expanded product error bound.**
Uses bounds on all four quantities:
`|f·g - F·G| ≤ Bf·εg + Mg·εf`
when `|f| ≤ Bf`, `|G| ≤ Mg`, `|f - F| ≤ εf`, `|g - G| ≤ εg`.
-/
theorem mul_sub_mul_bounded (f g F G Bf Mg εf εg : ℝ)
    (hBf : |f| ≤ Bf) (hMg : |G| ≤ Mg)
    (hεf : |f - F| ≤ εf) (hεg : |g - G| ≤ εg)
    (hBf_nn : 0 ≤ Bf) (hMg_nn : 0 ≤ Mg)
    (hεf_nn : 0 ≤ εf) (_hεg_nn : 0 ≤ εg) :
    |f * g - F * G| ≤ Bf * εg + Mg * εf := by
  exact le_trans ( mul_sub_mul_bound _ _ _ _ ) ( by gcongr )

/-! ## Section 2: Pointwise Approximation on Sets -/

variable {α : Type*}

/-- Pointwise approximation predicate: `f` is `ε`-close to `F` on `K`
with `F` bounded by `M`. -/
structure PointwiseApprox (K : Set α) (f F : α → ℝ) (ε M : ℝ) : Prop where
  err : ∀ x ∈ K, |f x - F x| ≤ ε
  bnd : ∀ x ∈ K, |F x| ≤ M

/-
**Addition closure.** If `f ≈ F ± εf` and `g ≈ G ± εg` on `K`, then
`f + g ≈ (F + G) ± (εf + εg)` on `K`, with bound `Mf + Mg`.
-/
theorem approx_add {K : Set α} {f g F G : α → ℝ} {εf εg Mf Mg : ℝ}
    (hf : PointwiseApprox K f F εf Mf)
    (hg : PointwiseApprox K g G εg Mg) :
    PointwiseApprox K (fun x => f x + g x) (fun x => F x + G x) (εf + εg) (Mf + Mg) := by
  constructor;
  · exact fun x hx => abs_le.mpr ⟨ by linarith [ abs_le.mp ( hf.err x hx ), abs_le.mp ( hg.err x hx ) ], by linarith [ abs_le.mp ( hf.err x hx ), abs_le.mp ( hg.err x hx ) ] ⟩;
  · grind +splitIndPred

/-
**Scalar multiplication closure.** If `f ≈ F ± ε` on `K`, then
`c·f ≈ c·F ± (|c|·ε)` on `K`, with bound `|c|·M`.
-/
theorem approx_smul {K : Set α} {f F : α → ℝ} {ε M c : ℝ}
    (hf : PointwiseApprox K f F ε M) :
    PointwiseApprox K (fun x => c * f x) (fun x => c * F x) (|c| * ε) (|c| * M) := by
  constructor;
  · exact fun x hx => by rw [ ← mul_sub, abs_mul ] ; exact mul_le_mul_of_nonneg_left ( hf.err x hx ) ( abs_nonneg c ) ;
  · exact fun x hx => by rw [ abs_mul ] ; exact mul_le_mul_of_nonneg_left ( hf.bnd x hx ) ( abs_nonneg c ) ;

/-
**Negation closure.** If `f ≈ F ± ε` on `K`, then
`-f ≈ -F ± ε` on `K`, with bound `M`.
-/
theorem approx_neg {K : Set α} {f F : α → ℝ} {ε M : ℝ}
    (hf : PointwiseApprox K f F ε M) :
    PointwiseApprox K (fun x => -f x) (fun x => -F x) ε M := by
  constructor;
  · exact fun x hx => abs_le.mpr ⟨ by linarith [ abs_le.mp ( hf.err x hx ) ], by linarith [ abs_le.mp ( hf.err x hx ) ] ⟩;
  · simpa using hf.bnd

/-
**Subtraction closure.**
-/
theorem approx_sub {K : Set α} {f g F G : α → ℝ} {εf εg Mf Mg : ℝ}
    (hf : PointwiseApprox K f F εf Mf)
    (hg : PointwiseApprox K g G εg Mg) :
    PointwiseApprox K (fun x => f x - g x) (fun x => F x - G x) (εf + εg) (Mf + Mg) := by
  constructor;
  · exact fun x hx => abs_le.mpr ⟨ by linarith [ abs_le.mp ( hf.err x hx ), abs_le.mp ( hg.err x hx ) ], by linarith [ abs_le.mp ( hf.err x hx ), abs_le.mp ( hg.err x hx ) ] ⟩;
  · exact fun x hx => le_trans ( abs_sub _ _ ) ( add_le_add ( hf.bnd x hx ) ( hg.bnd x hx ) )

/-
**Multiplication closure with Leibniz error.**
If `f ≈ F ± εf` with `|f| ≤ Bf` and `g ≈ G ± εg` with `|G| ≤ Mg`, then
`f·g ≈ F·G ± (Bf·εg + Mg·εf)` with bound `Mf·Mg`.
-/
theorem approx_mul {K : Set α} {f g F G : α → ℝ} {εf εg Mf Mg Bf : ℝ}
    (hf : PointwiseApprox K f F εf Mf)
    (hg : PointwiseApprox K g G εg Mg)
    (hBf : ∀ x ∈ K, |f x| ≤ Bf)
    (hεf_nn : 0 ≤ εf) (hεg_nn : 0 ≤ εg)
    (hMg_nn : 0 ≤ Mg) (hBf_nn : 0 ≤ Bf)
    (hMf_nn : 0 ≤ Mf) :
    PointwiseApprox K (fun x => f x * g x) (fun x => F x * G x)
      (Bf * εg + Mg * εf) (Mf * Mg) := by
  constructor;
  · exact fun x hx => mul_sub_mul_bounded _ _ _ _ _ _ _ _ ( hBf x hx ) ( hg.bnd x hx ) ( hf.err x hx ) ( hg.err x hx ) hBf_nn hMg_nn hεf_nn hεg_nn;
  · exact fun x hx => by rw [ abs_mul ] ; exact mul_le_mul ( hf.bnd x hx ) ( hg.bnd x hx ) ( by positivity ) ( by positivity ) ;

/-
**Max closure with sharp error.**
If `f ≈ F ± εf` and `g ≈ G ± εg` on `K`, then
`max(f,g) ≈ max(F,G) ± max(εf, εg)` on `K`, with bound `max(Mf, Mg)`.
-/
theorem approx_max {K : Set α} {f g F G : α → ℝ} {εf εg Mf Mg : ℝ}
    (hf : PointwiseApprox K f F εf Mf)
    (hg : PointwiseApprox K g G εg Mg)
    (hεf_nn : 0 ≤ εf) (hεg_nn : 0 ≤ εg) :
    PointwiseApprox K (fun x => max (f x) (g x)) (fun x => max (F x) (G x))
      (max εf εg) (max Mf Mg) := by
  have := @hg.bnd;
  constructor;
  · exact fun x hx => le_trans ( abs_max_sub_max_le_max ( f x ) ( g x ) ( F x ) ( G x ) ) ( max_le_max ( hf.1 x hx ) ( hg.1 x hx ) );
  · exact fun x hx => abs_le.mpr ⟨ by cases max_cases ( F x ) ( G x ) <;> linarith [ abs_le.mp ( hf.bnd x hx ), abs_le.mp ( this x hx ), le_max_left Mf Mg, le_max_right Mf Mg ], by cases max_cases ( F x ) ( G x ) <;> linarith [ abs_le.mp ( hf.bnd x hx ), abs_le.mp ( this x hx ), le_max_left Mf Mg, le_max_right Mf Mg ] ⟩

/-
**Constant function approximation.** A constant is its own 0-error approximant.
-/
theorem approx_const {K : Set α} (c : ℝ) :
    PointwiseApprox K (fun _ => c) (fun _ => c) 0 |c| := by
  constructor <;> aesop

/-! ## Section 3: Expression Trees and Compositional Closure -/

/-- Expression trees built from variables, constants, addition, multiplication, and max.
This is the syntax of the "approximation algebra". -/
inductive EMLExprR (ι : Type*)
  | var : ι → EMLExprR ι
  | const : ℝ → EMLExprR ι
  | add : EMLExprR ι → EMLExprR ι → EMLExprR ι
  | mul : EMLExprR ι → EMLExprR ι → EMLExprR ι
  | smul : ℝ → EMLExprR ι → EMLExprR ι
  | maxOp : EMLExprR ι → EMLExprR ι → EMLExprR ι

/-- Evaluation of an expression tree given variable assignments. -/
def EMLExprR.eval {ι : Type*} (v : ι → α → ℝ) : EMLExprR ι → α → ℝ
  | .var i => v i
  | .const c => fun _ => c
  | .add e₁ e₂ => fun x => e₁.eval v x + e₂.eval v x
  | .mul e₁ e₂ => fun x => e₁.eval v x * e₂.eval v x
  | .smul c e => fun x => c * e.eval v x
  | .maxOp e₁ e₂ => fun x => max (e₁.eval v x) (e₂.eval v x)

/-- Structural value bound for an expression, given per-variable value bounds.
Computes a bound on `|expr(v, x)|` when each `|v i x| ≤ B i`. -/
noncomputable def EMLExprR.boundVal {ι : Type*} (B : ι → ℝ) : EMLExprR ι → ℝ
  | .var i => B i
  | .const c => |c|
  | .add e₁ e₂ => e₁.boundVal B + e₂.boundVal B
  | .mul e₁ e₂ => e₁.boundVal B * e₂.boundVal B
  | .smul c e => |c| * e.boundVal B
  | .maxOp e₁ e₂ => max (e₁.boundVal B) (e₂.boundVal B)

/-- Structural error bound for an expression, given per-variable errors and value bounds.
Computes the worst-case propagated error through the expression tree.
Uses `boundVal` for the intermediate value bounds needed by the multiplication rule. -/
noncomputable def EMLExprR.errBound {ι : Type*} (ε B : ι → ℝ) : EMLExprR ι → ℝ
  | .var i => ε i
  | .const _ => 0
  | .add e₁ e₂ => e₁.errBound ε B + e₂.errBound ε B
  | .mul e₁ e₂ =>
      e₁.boundVal B * e₂.errBound ε B + e₂.boundVal B * e₁.errBound ε B
  | .smul c e => |c| * e.errBound ε B
  | .maxOp e₁ e₂ => max (e₁.errBound ε B) (e₂.errBound ε B)

/-
Value bounds are nonneg when inputs are nonneg.
-/
theorem EMLExprR.boundVal_nonneg {ι : Type*} (B : ι → ℝ) (hB : ∀ i, 0 ≤ B i)
    (e : EMLExprR ι) : 0 ≤ e.boundVal B := by
  induction e;
  all_goals repeat' apply_rules [ add_nonneg, mul_nonneg, abs_nonneg, hB ];
  exact le_max_of_le_left ‹_›

/-
Error bounds are nonneg when inputs are nonneg.
-/
theorem EMLExprR.errBound_nonneg {ι : Type*} (ε B : ι → ℝ)
    (hε : ∀ i, 0 ≤ ε i) (hB : ∀ i, 0 ≤ B i)
    (e : EMLExprR ι) : 0 ≤ e.errBound ε B := by
  induction' e with e₁ e₂ ih₁ ih₂;
  all_goals norm_num [ errBound ] at *;
  · exact hε e₁;
  · linarith;
  · exact add_nonneg ( mul_nonneg ( EMLExprR.boundVal_nonneg B hB _ ) ‹_› ) ( mul_nonneg ( EMLExprR.boundVal_nonneg B hB _ ) ‹_› );
  · positivity;
  · exact Or.inl ‹_›

/-
The value bound controls the actual value of the expression.
-/
theorem EMLExprR.eval_le_boundVal {ι : Type*} {K : Set α}
    (v : ι → α → ℝ) (B : ι → ℝ)
    (hBv : ∀ i x, x ∈ K → |v i x| ≤ B i)
    (_hB : ∀ i, 0 ≤ B i)
    (e : EMLExprR ι) :
    ∀ x ∈ K, |e.eval v x| ≤ e.boundVal B := by
  induction' e with i c e₁ e₂ ih₁ ih₂ e c ih;
  all_goals norm_num [ eval, boundVal ];
  · exact hBv i;
  · grind;
  · exact fun x hx => mul_le_mul ( ih x hx ) ( by solve_by_elim ) ( abs_nonneg _ ) ( by exact le_trans ( abs_nonneg _ ) ( ih x hx ) );
  · exact fun x hx => mul_le_mul_of_nonneg_left ( by solve_by_elim ) ( abs_nonneg _ );
  · grind

/-
**Main compositional approximation theorem.**

Given:
- Variable functions `f i` each approximated by `F i` with error `ε i`
- Each `|f i x| ≤ B i` on `K`, each `|F i x| ≤ M i` on `K`
- An expression `φ` built from `var`, `const`, `add`, `mul`, `smul`, `maxOp`

Then `φ.eval f` is approximated by `φ.eval F` with error at most
`φ.errBound ε (fun i => max (B i) (M i))`.

The error bound propagates structurally through the expression tree,
giving an explicit, compositional approximation calculus.
-/
theorem approx_expr {ι : Type*} {K : Set α}
    (φ : EMLExprR ι) (f F : ι → α → ℝ)
    (ε M B : ι → ℝ)
    (_hε : ∀ i, 0 ≤ ε i)
    (hM : ∀ i, 0 ≤ M i)
    (hB : ∀ i, 0 ≤ B i)
    (herr : ∀ i x, x ∈ K → |f i x - F i x| ≤ ε i)
    (hboundF : ∀ i x, x ∈ K → |F i x| ≤ M i)
    (hboundf : ∀ i x, x ∈ K → |f i x| ≤ B i) :
    ∀ x ∈ K,
      |φ.eval f x - φ.eval F x| ≤ φ.errBound ε (fun i => max (B i) (M i)) := by
  -- By induction on the structure of the expression tree.
  induction' φ with i e₁ e₂ ih₁ ih₂ e₁ e₂ ih₁ ih₂ c e ih;
  all_goals norm_num [ EMLExprR.eval, EMLExprR.errBound ];
  · exact herr i;
  · exact fun x hx => abs_le.mpr ⟨ by linarith [ abs_le.mp ( ih₂ x hx ), abs_le.mp ( e₁ x hx ) ], by linarith [ abs_le.mp ( ih₂ x hx ), abs_le.mp ( e₁ x hx ) ] ⟩;
  · intro x hx;
    refine' le_trans ( mul_sub_mul_bound _ _ _ _ ) _;
    gcongr;
    any_goals solve_by_elim;
    · exact EMLExprR.boundVal_nonneg _ ( fun i => le_max_of_le_left ( hB i ) ) _;
    · apply EMLExprR.eval_le_boundVal;
      exacts [ fun i x hx => le_trans ( hboundf i x hx ) ( le_max_left _ _ ), fun i => le_max_of_le_left ( hB i ), hx ];
    · exact EMLExprR.boundVal_nonneg _ ( fun i => le_max_of_le_left ( hB i ) ) _;
    · apply EMLExprR.eval_le_boundVal;
      exacts [ fun i x hx => le_trans ( hboundF i x hx ) ( le_max_right _ _ ), fun i => le_max_of_le_right ( hM i ), hx ];
  · exact fun x hx => by rw [ ← mul_sub, abs_mul ] ; exact mul_le_mul_of_nonneg_left ( by solve_by_elim ) ( abs_nonneg e ) ;
  · grind

/-! ## Section 4: Concrete Corollaries -/

/-
**Two-function addition corollary.**
-/
theorem approx_two_add {K : Set α} {f g F G : α → ℝ} {εf εg : ℝ}
    (herrf : ∀ x ∈ K, |f x - F x| ≤ εf)
    (herrg : ∀ x ∈ K, |g x - G x| ≤ εg) :
    ∀ x ∈ K, |(f x + g x) - (F x + G x)| ≤ εf + εg := by
  exact fun x hx => abs_le.mpr ⟨ by linarith [ abs_le.mp ( herrf x hx ), abs_le.mp ( herrg x hx ) ], by linarith [ abs_le.mp ( herrf x hx ), abs_le.mp ( herrg x hx ) ] ⟩

/-
**Two-function multiplication corollary.**
-/
theorem approx_two_mul {K : Set α} {f g F G : α → ℝ} {εf εg Bf Mg : ℝ}
    (herrf : ∀ x ∈ K, |f x - F x| ≤ εf)
    (herrg : ∀ x ∈ K, |g x - G x| ≤ εg)
    (hBf : ∀ x ∈ K, |f x| ≤ Bf)
    (hMg : ∀ x ∈ K, |G x| ≤ Mg)
    (hBf_nn : 0 ≤ Bf) (hMg_nn : 0 ≤ Mg)
    (hεf_nn : 0 ≤ εf) (hεg_nn : 0 ≤ εg) :
    ∀ x ∈ K, |f x * g x - F x * G x| ≤ Bf * εg + Mg * εf := by
  exact fun x hx =>
    mul_sub_mul_bounded (f x) (g x) (F x) (G x) Bf Mg εf εg (hBf x hx) (hMg x hx) (herrf x hx)
      (herrg x hx) hBf_nn hMg_nn hεf_nn hεg_nn

/-
**Two-function max corollary with sharp bound.**
-/
theorem approx_two_max {K : Set α} {f g F G : α → ℝ} {εf εg : ℝ}
    (_hεf : 0 ≤ εf) (_hεg : 0 ≤ εg)
    (herrf : ∀ x ∈ K, |f x - F x| ≤ εf)
    (herrg : ∀ x ∈ K, |g x - G x| ≤ εg) :
    ∀ x ∈ K, |max (f x) (g x) - max (F x) (G x)| ≤ max εf εg := by
  grind

/-
**Scalar multiplication corollary.**
-/
theorem approx_scalar_mul {K : Set α} {f F : α → ℝ} {ε c : ℝ}
    (herr : ∀ x ∈ K, |f x - F x| ≤ ε) :
    ∀ x ∈ K, |c * f x - c * F x| ≤ |c| * ε := by
  exact fun x hx => by rw [ ← mul_sub, abs_mul ] ; exact mul_le_mul_of_nonneg_left ( herr x hx ) ( abs_nonneg c ) ;

/-! ## Section 5: The log-sum-exp bridge to tropical structure -/

/-
**Soft-max lower bound.**
For `τ > 0`: `max(a,b) ≤ τ * log(exp(a/τ) + exp(b/τ))`.
-/
theorem softmax_lower (a b τ : ℝ) (hτ : 0 < τ) :
    max a b ≤ τ * Real.log (Real.exp (a / τ) + Real.exp (b / τ)) := by
  rw [ ← div_le_iff₀' hτ ];
  rw [ Real.le_log_iff_exp_le ( by positivity ) ];
  cases max_cases a b <;> simp +decide [ *, Real.exp_nonneg ]

/-
**Soft-max upper bound.**
For `τ > 0`: `τ * log(exp(a/τ) + exp(b/τ)) ≤ max(a,b) + τ * log 2`.
-/
theorem softmax_upper (a b τ : ℝ) (hτ : 0 < τ) :
    τ * Real.log (Real.exp (a / τ) + Real.exp (b / τ)) ≤ max a b + τ * Real.log 2 := by
  -- We'll use that exp(a/τ) + exp(b/τ) ≤ 2 * exp(max(a,b)/τ) since each exp term ≤ exp(max(a,b)/τ).
  have h_exp_bound : Real.exp (a / τ) + Real.exp (b / τ) ≤ 2 * Real.exp (max a b / τ) := by
    rw [ two_mul ] ; gcongr <;> aesop;
  have := Real.log_le_log ( by positivity ) h_exp_bound;
  rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] at this ; nlinarith [ mul_div_cancel₀ ( max a b ) hτ.ne' ]

/-
**Soft-max error bound.** The soft-max approximation has error at most `τ * log 2`.
-/
theorem softmax_error (a b τ : ℝ) (hτ : 0 < τ) :
    |τ * Real.log (Real.exp (a / τ) + Real.exp (b / τ)) - max a b| ≤ τ * Real.log 2 := by
  rw [ abs_le ];
  constructor <;> nlinarith [ softmax_lower a b τ hτ, softmax_upper a b τ hτ ]

end