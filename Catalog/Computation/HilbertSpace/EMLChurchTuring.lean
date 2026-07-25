import Mathlib

/-!
# EML Single-Operator Church-Turing Thesis

We formalize the conjecture that `exp`, `log`, constants, and field operations
form a computationally universal basis for real-valued elementary functions.

## Main Definitions

* `EMLExpr` — An inductive type for expressions built from exp, log, constants,
  addition, multiplication, subtraction, division, and variable references.
* `EMLExpr.eval` — Evaluation of an EML expression given a variable assignment.
* `EMLExpr.depth` — The nesting depth of exp/log operations in an expression.
* `EMLClosed` — A closure property capturing EML-representable function classes.
* `EMLClass` — The smallest EML-closed set of functions.

## Main Results

* `product_via_exp_log` — `a * b = exp(log(a) + log(b))` for positive reals.
* `nat_power_via_exp_log` — `x^n = exp(n * log(x))` for positive reals.
* `reciprocal_via_exp_log` — `x⁻¹ = exp(-log(x))` for positive reals.
* `EMLExpr.eval_subst` — Substitution is semantically correct.
* `EMLExpr.depth_subst_le` — Depth of substituted expressions is bounded.
* `polynomial_in_EMLClass` — Polynomials are EML-representable.
* `depth_hierarchy_strict` — The EML depth hierarchy is strictly increasing.

## Conjectures

* `EMLUniversalApprox` — Every continuous function on a compact interval
  can be uniformly approximated by EML compositions.
-/

noncomputable section

open Real Set

/-! ## Core identities for EML reduction -/

/-- Product of positive reals via exp-log: `a * b = exp(log a + log b)`. -/
theorem product_via_exp_log (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    a * b = exp (log a + log b) := by
  rw [exp_add, exp_log ha, exp_log hb]

/-- Quotient of positive reals via exp-log: `a / b = exp(log a - log b)`. -/
theorem quotient_via_exp_log (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    a / b = exp (log a - log b) := by
  rw [exp_sub, exp_log ha, exp_log hb]

/-- The identity `x^n = exp(n * log x)` for positive `x`. -/
theorem nat_power_via_exp_log (x : ℝ) (n : ℕ) (hx : 0 < x) :
    x ^ n = exp (↑n * log x) := by
  rw [← rpow_natCast x n, rpow_def_of_pos hx, mul_comm]

/-- Reciprocal via exp-log: `1/x = exp(-log x)` for positive `x`. -/
theorem reciprocal_via_exp_log (x : ℝ) (hx : 0 < x) :
    x⁻¹ = exp (-log x) := by
  rw [exp_neg, exp_log hx]

/-
Square root via exp-log: `√x = exp(log(x)/2)` for positive `x`.
-/
theorem sqrt_via_exp_log (x : ℝ) (hx : 0 < x) :
    sqrt x = exp (log x / 2) := by
  rw [ Real.sqrt_eq_rpow, Real.rpow_def_of_pos hx ] ; ring

/-! ## EML Expression Language -/

/-- An expression in the EML (Exp-Mul-Log) language.
Variables are indexed by natural numbers. -/
inductive EMLExpr : Type where
  | var : ℕ → EMLExpr
  | const : ℝ → EMLExpr
  | add : EMLExpr → EMLExpr → EMLExpr
  | mul : EMLExpr → EMLExpr → EMLExpr
  | sub : EMLExpr → EMLExpr → EMLExpr
  | div : EMLExpr → EMLExpr → EMLExpr
  | exp : EMLExpr → EMLExpr
  | log : EMLExpr → EMLExpr
  deriving Inhabited

namespace EMLExpr

/-- Evaluate an EML expression given a variable assignment `σ : ℕ → ℝ`. -/
def eval (σ : ℕ → ℝ) : EMLExpr → ℝ
  | var i => σ i
  | const c => c
  | add e₁ e₂ => e₁.eval σ + e₂.eval σ
  | mul e₁ e₂ => e₁.eval σ * e₂.eval σ
  | sub e₁ e₂ => e₁.eval σ - e₂.eval σ
  | div e₁ e₂ => e₁.eval σ / e₂.eval σ
  | exp e => Real.exp (e.eval σ)
  | log e => Real.log (e.eval σ)

/-- The nesting depth of exp/log operations. Measures the "transcendental complexity"
of an EML expression — purely algebraic operations (add, mul, sub, div) do not
increase depth. -/
def depth : EMLExpr → ℕ
  | var _ => 0
  | const _ => 0
  | add e₁ e₂ => max e₁.depth e₂.depth
  | mul e₁ e₂ => max e₁.depth e₂.depth
  | sub e₁ e₂ => max e₁.depth e₂.depth
  | div e₁ e₂ => max e₁.depth e₂.depth
  | exp e => e.depth + 1
  | log e => e.depth + 1

/-- The number of nodes in an EML expression (its size). -/
def size : EMLExpr → ℕ
  | var _ => 1
  | const _ => 1
  | add e₁ e₂ => e₁.size + e₂.size + 1
  | mul e₁ e₂ => e₁.size + e₂.size + 1
  | sub e₁ e₂ => e₁.size + e₂.size + 1
  | div e₁ e₂ => e₁.size + e₂.size + 1
  | exp e => e.size + 1
  | log e => e.size + 1

/-- Size is always positive. -/
theorem size_pos (e : EMLExpr) : 0 < e.size := by
  induction e <;> simp only [size] <;> omega

/-- The number of exp/log nodes in an expression. -/
def transcCount : EMLExpr → ℕ
  | .var _ => 0
  | .const _ => 0
  | .add a b => a.transcCount + b.transcCount
  | .mul a b => a.transcCount + b.transcCount
  | .sub a b => a.transcCount + b.transcCount
  | .div a b => a.transcCount + b.transcCount
  | .exp a => a.transcCount + 1
  | .log a => a.transcCount + 1

end EMLExpr

/-! ## EML representations of specific functions -/

/-- The EML expression for `exp(x₀)`. -/
def emlExp : EMLExpr := .exp (.var 0)

/-- The EML expression for `log(x₀)`. -/
def emlLog : EMLExpr := .log (.var 0)

/-- The EML expression for `x₀ * x₁` via `exp(log(x₀) + log(x₁))`. -/
def emlMulViaExpLog : EMLExpr :=
  .exp (.add (.log (.var 0)) (.log (.var 1)))

/-- The EML expression for `x₀⁻¹` via `exp(-log(x₀))`. -/
def emlInvViaExpLog : EMLExpr :=
  .exp (.sub (.const 0) (.log (.var 0)))

/-- The EML expression for `x₀ ^ n` via `exp(n * log(x₀))`. -/
def emlPowerN (n : ℕ) : EMLExpr :=
  .exp (.mul (.const n) (.log (.var 0)))

/-- `emlExp` evaluates to `exp(x)`. -/
theorem emlExp_eval (σ : ℕ → ℝ) : emlExp.eval σ = Real.exp (σ 0) := by
  simp [emlExp, EMLExpr.eval]

/-- `emlLog` evaluates to `log(x)`. -/
theorem emlLog_eval (σ : ℕ → ℝ) : emlLog.eval σ = Real.log (σ 0) := by
  simp [emlLog, EMLExpr.eval]

/-- The exp-log multiplication formula evaluates correctly on positive inputs. -/
theorem emlMulViaExpLog_eval (σ : ℕ → ℝ) (h0 : 0 < σ 0) (h1 : 0 < σ 1) :
    emlMulViaExpLog.eval σ = σ 0 * σ 1 := by
  simp [emlMulViaExpLog, EMLExpr.eval]
  exact (product_via_exp_log (σ 0) (σ 1) h0 h1).symm

/-- The exp-log reciprocal formula evaluates correctly on positive inputs. -/
theorem emlInvViaExpLog_eval (σ : ℕ → ℝ) (h0 : 0 < σ 0) :
    emlInvViaExpLog.eval σ = (σ 0)⁻¹ := by
  simp [emlInvViaExpLog, EMLExpr.eval, zero_sub, exp_neg, exp_log h0]

/-- The power expression evaluates to `x ^ n` on positive inputs. -/
theorem emlPowerN_eval (σ : ℕ → ℝ) (n : ℕ) (h0 : 0 < σ 0) :
    (emlPowerN n).eval σ = (σ 0) ^ n := by
  simp [emlPowerN, EMLExpr.eval]
  exact (nat_power_via_exp_log (σ 0) n h0).symm

/-! ## EML Depth Analysis -/

/-- The depth of `emlExp` is 1. -/
theorem emlExp_depth : emlExp.depth = 1 := by
  simp [emlExp, EMLExpr.depth]

/-- The depth of the multiplication-via-exp-log encoding is 2. -/
theorem emlMulViaExpLog_depth : emlMulViaExpLog.depth = 2 := by
  simp [emlMulViaExpLog, EMLExpr.depth]

/-- The depth of `emlPowerN` is 2. -/
theorem emlPowerN_depth (n : ℕ) : (emlPowerN n).depth = 2 := by
  simp [emlPowerN, EMLExpr.depth]

/-- Depth of an algebraic combination is the max of constituent depths. -/
theorem depth_add_eq_max (e₁ e₂ : EMLExpr) :
    (EMLExpr.add e₁ e₂).depth = max e₁.depth e₂.depth := by
  simp [EMLExpr.depth]

theorem depth_mul_eq_max (e₁ e₂ : EMLExpr) :
    (EMLExpr.mul e₁ e₂).depth = max e₁.depth e₂.depth := by
  simp [EMLExpr.depth]

/-! ## Substitution and Composition -/

/-- Substitute variable `i` with expression `e'` in expression `e`. -/
def EMLExpr.subst (e : EMLExpr) (i : ℕ) (e' : EMLExpr) : EMLExpr :=
  match e with
  | .var j => if j = i then e' else .var j
  | .const c => .const c
  | .add a b => .add (a.subst i e') (b.subst i e')
  | .mul a b => .mul (a.subst i e') (b.subst i e')
  | .sub a b => .sub (a.subst i e') (b.subst i e')
  | .div a b => .div (a.subst i e') (b.subst i e')
  | .exp a => .exp (a.subst i e')
  | .log a => .log (a.subst i e')

/-- Substitution is semantically correct: evaluating a substituted expression
equals evaluating the original with the substituted variable's value. -/
theorem EMLExpr.eval_subst (e e' : EMLExpr) (σ : ℕ → ℝ) (i : ℕ) :
    (e.subst i e').eval σ = e.eval (Function.update σ i (e'.eval σ)) := by
  induction e with
  | var j =>
    simp [subst, eval, Function.update]
    split <;> simp [eval]
  | const c => simp [subst, eval]
  | add a b iha ihb => simp [subst, eval, iha, ihb]
  | mul a b iha ihb => simp [subst, eval, iha, ihb]
  | sub a b iha ihb => simp [subst, eval, iha, ihb]
  | div a b iha ihb => simp [subst, eval, iha, ihb]
  | exp a iha => simp [subst, eval, iha]
  | log a iha => simp [subst, eval, iha]

/-- Depth of a substitution is bounded by the sum of constituent depths. -/
theorem EMLExpr.depth_subst_le (e e' : EMLExpr) (i : ℕ) :
    (e.subst i e').depth ≤ e.depth + e'.depth := by
  induction e with
  | var j =>
    simp [subst, depth]
    split
    · omega
    · simp [depth]
  | const _ => simp [subst, depth]
  | add a b iha ihb => simp [subst, depth]; omega
  | mul a b iha ihb => simp [subst, depth]; omega
  | sub a b iha ihb => simp [subst, depth]; omega
  | div a b iha ihb => simp [subst, depth]; omega
  | exp a ih => simp [subst, depth]; omega
  | log a ih => simp [subst, depth]; omega

/-! ## EML Closure Class -/

/-- A set of real functions `ℝ → ℝ` is **EML-closed** if it is closed under
composition with exp, log, and field operations. -/
structure EMLClosed (S : Set (ℝ → ℝ)) : Prop where
  exp_mem : Real.exp ∈ S
  log_mem : Real.log ∈ S
  const_mem : ∀ c : ℝ, (fun _ => c) ∈ S
  id_mem : id ∈ S
  add_mem : ∀ ⦃f g⦄, f ∈ S → g ∈ S → (fun x => f x + g x) ∈ S
  mul_mem : ∀ ⦃f g⦄, f ∈ S → g ∈ S → (fun x => f x * g x) ∈ S
  comp_mem : ∀ ⦃f g⦄, f ∈ S → g ∈ S → f ∘ g ∈ S

/-- The smallest EML-closed set — the class of all functions
expressible via finite EML compositions. -/
def EMLClass : Set (ℝ → ℝ) :=
  ⋂ (S : Set (ℝ → ℝ)) (_ : EMLClosed S), S

/-- `EMLClass` is itself EML-closed. -/
theorem emlClass_closed : EMLClosed EMLClass := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> simp only [EMLClass, Set.mem_iInter]
  · intro S hS; exact hS.exp_mem
  · intro S hS; exact hS.log_mem
  · intro c S hS; exact hS.const_mem c
  · intro S hS; exact hS.id_mem
  · intro f g hf hg S hS; exact hS.add_mem (hf S hS) (hg S hS)
  · intro f g hf hg S hS; exact hS.mul_mem (hf S hS) (hg S hS)
  · intro f g hf hg S hS; exact hS.comp_mem (hf S hS) (hg S hS)

/-- `exp` is in `EMLClass`. -/
theorem exp_in_EMLClass : Real.exp ∈ EMLClass := emlClass_closed.exp_mem

/-- `log` is in `EMLClass`. -/
theorem log_in_EMLClass : Real.log ∈ EMLClass := emlClass_closed.log_mem

/-- Any constant function is in `EMLClass`. -/
theorem const_in_EMLClass (c : ℝ) : (fun _ => c) ∈ EMLClass := emlClass_closed.const_mem c

/-- The subtraction function `x ↦ f(x) - g(x)` is in `EMLClass` when `f, g` are. -/
theorem sub_in_EMLClass {f g : ℝ → ℝ} (hf : f ∈ EMLClass) (hg : g ∈ EMLClass) :
    (fun x => f x - g x) ∈ EMLClass := by
  have : (fun x => f x - g x) = (fun x => f x + ((fun _ => (-1 : ℝ)) x * g x)) := by
    ext x; ring
  rw [this]
  exact emlClass_closed.add_mem hf (emlClass_closed.mul_mem (const_in_EMLClass _) hg)

/-- `exp ∘ log` restricted to positive reals is the identity. -/
theorem exp_comp_log_eq_id_pos (x : ℝ) (hx : 0 < x) : exp (log x) = x :=
  exp_log hx

/-- `log ∘ exp` is the identity everywhere. -/
theorem log_comp_exp_eq_id (x : ℝ) : log (exp x) = x :=
  log_exp x

/-! ## Polynomial Representability -/

/-- The function `x ↦ x^n` is in `EMLClass` for all `n : ℕ`.
Proved by induction: x^0 = 1 (constant), x^(n+1) = x * x^n. -/
theorem pow_in_EMLClass (n : ℕ) : (fun x : ℝ => x ^ n) ∈ EMLClass := by
  induction n with
  | zero => simpa using const_in_EMLClass 1
  | succ k ih =>
    have heq : (fun x : ℝ => x ^ (k + 1)) = (fun x => (id x) * x ^ k) := by
      ext x; simp [pow_succ, mul_comm, id]
    rw [heq]
    exact emlClass_closed.mul_mem emlClass_closed.id_mem ih

/-- Any monomial `c * x^n` is in `EMLClass`. -/
theorem monomial_in_EMLClass (c : ℝ) (n : ℕ) :
    (fun x : ℝ => c * x ^ n) ∈ EMLClass :=
  emlClass_closed.mul_mem (const_in_EMLClass c) (pow_in_EMLClass n)

/-- A polynomial function is in `EMLClass`. This is proved by structural induction
on the polynomial, using that monomials are EML-representable and EMLClass is
closed under addition. -/
theorem polynomial_in_EMLClass (p : Polynomial ℝ) :
    (fun x : ℝ => p.eval x) ∈ EMLClass := by
  induction p using Polynomial.induction_on' with
  | add p q hp hq =>
    have heq : (fun x : ℝ => (p + q).eval x) = (fun x => p.eval x + q.eval x) := by
      ext x; simp [Polynomial.eval_add]
    rw [heq]; exact emlClass_closed.add_mem hp hq
  | monomial n c =>
    have heq : (fun x : ℝ => (Polynomial.monomial n c).eval x) = (fun x => c * x ^ n) := by
      ext x; simp [Polynomial.eval_monomial]
    rw [heq]; exact monomial_in_EMLClass c n

/-! ## The EML Universality Conjecture -/

/-- **EML Universality Conjecture**: Every continuous function `ℝ → ℝ`
can be uniformly approximated on compact intervals by functions in `EMLClass`.

This is a falsifiable conjecture. A counterexample would be a continuous function
for which the approximation error does not go to zero.

Note: Since EMLClass contains all polynomials and is closed under composition
with exp and log, it is a rich class. By Stone-Weierstrass, if it separates
points (which it does, since id ∈ EMLClass) and contains constants, then
the uniform closure of EMLClass on any compact set is all continuous functions.
-/
def EMLUniversalApprox : Prop :=
  ∀ (f : ℝ → ℝ) (_ : Continuous f) (a b : ℝ) (_ : a < b) (ε : ℝ) (_ : 0 < ε),
    ∃ g ∈ EMLClass, ∀ x ∈ Icc a b, |f x - g x| < ε

/-- If EML universal approximation holds, then in particular all
polynomials are approximable (a sanity check on the conjecture). -/
theorem eml_approx_implies_polynomial_approx :
    EMLUniversalApprox → ∀ (p : Polynomial ℝ) (a b : ℝ) (_ : a < b)
      (ε : ℝ) (_ : 0 < ε),
      ∃ g ∈ EMLClass, ∀ x ∈ Icc a b, |p.eval x - g x| < ε := by
  intro huniv p a b hab ε hε
  exact huniv (fun x => p.eval x) p.continuous_aeval a b hab ε hε

/-! ## EML Depth Hierarchy -/

/-- The set of EML expressions of depth at most `d`. -/
def EMLDepthClass (d : ℕ) : Set EMLExpr :=
  { e : EMLExpr | e.depth ≤ d }

/-- Depth 0 expressions are purely algebraic (no exp/log). -/
theorem depth_zero_algebraic (e : EMLExpr) (he : e ∈ EMLDepthClass 0) :
    e.depth = 0 := by
  simp [EMLDepthClass] at he; omega

/-- The depth classes form an increasing chain. -/
theorem depth_class_mono {d₁ d₂ : ℕ} (h : d₁ ≤ d₂) :
    EMLDepthClass d₁ ⊆ EMLDepthClass d₂ := by
  intro e he; simp [EMLDepthClass] at *; omega

/-- The depth hierarchy is strict: for each `d`, there exists an expression
of depth exactly `d + 1` not in `EMLDepthClass d`. Proved by constructing
iterated exp applications. -/
theorem depth_hierarchy_strict (d : ℕ) :
    ∃ e : EMLExpr, e.depth = d + 1 ∧ e ∉ EMLDepthClass d := by
  induction d with
  | zero =>
    exact ⟨.exp (.const 0), by simp [EMLExpr.depth], by simp [EMLDepthClass, EMLExpr.depth]⟩
  | succ k ih =>
    obtain ⟨e, he_depth, _⟩ := ih
    exact ⟨.exp e, by simp [EMLExpr.depth, he_depth],
           by simp [EMLDepthClass, EMLExpr.depth, he_depth]⟩

/-! ## Structural bounds -/

/-- Depth is at most the transcendental count. -/
theorem EMLExpr.depth_le_transcCount (e : EMLExpr) : e.depth ≤ e.transcCount := by
  induction e with
  | var _ => simp [depth, transcCount]
  | const _ => simp [depth, transcCount]
  | add a b iha ihb => simp only [depth, transcCount]; omega
  | mul a b iha ihb => simp only [depth, transcCount]; omega
  | sub a b iha ihb => simp only [depth, transcCount]; omega
  | div a b iha ihb => simp only [depth, transcCount]; omega
  | exp a ih => simp only [depth, transcCount]; omega
  | log a ih => simp only [depth, transcCount]; omega

/-- Transcendental count is at most the total size. -/
theorem EMLExpr.transcCount_le_size (e : EMLExpr) : e.transcCount ≤ e.size := by
  induction e with
  | var _ => simp [transcCount, size]
  | const _ => simp [transcCount, size]
  | add a b iha ihb => simp [transcCount, size]; omega
  | mul a b iha ihb => simp [transcCount, size]; omega
  | sub a b iha ihb => simp [transcCount, size]; omega
  | div a b iha ihb => simp [transcCount, size]; omega
  | exp a ih => simp [transcCount, size]; omega
  | log a ih => simp [transcCount, size]; omega

/-- Depth is at most the total size (transitive bound). -/
theorem EMLExpr.depth_le_size (e : EMLExpr) : e.depth ≤ e.size :=
  le_trans e.depth_le_transcCount e.transcCount_le_size

end