/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Exact compilation to the catalog's single EML operator

This file builds on `EMLExpr` and `EMLOnlyExpr` from the existing catalog.  It
proves that every finite expression made from real constants, variables, field
operations, `Real.exp`, and Mathlib's total `Real.log` can be compiled to an
expression whose only transcendental node is

`eml(a,b) = exp(a) - log(b)`.

This is an exact syntactic compilation theorem, not a claim about all computable
real functions.  In particular, real `sin` and `cos` are deliberately not added
to the source grammar: their exact definability by finite real exp-log terms is
not a consequence of the elementary identities proved here.
-/
import EML.HilbertSpace.SingleOperatorRepresentability

noncomputable section

namespace EMLSingleOperator

open EMLExpr EMLOnlyExpr

/-- Compile the catalog's two-transcendental grammar to its single-operator
grammar.  The two important clauses are
`exp(a) = eml(a,1)` and `log(b) = 1 - eml(0,b)`. -/
def compile : EMLExpr → EMLOnlyExpr
  | .const c => .const c
  | .var n => .var n
  | .add p q => .add (compile p) (compile q)
  | .mul p q => .mul (compile p) (compile q)
  | .neg p => .neg (compile p)
  | .inv p => .inv (compile p)
  | .exp p => .eml (compile p) (.const 1)
  | .log p => .add (.const 1) (.neg (.eml (.const 0) (compile p)))

/-- Compilation preserves denotation for every environment, including at the
totalized exceptional inputs of inverse and logarithm. -/
theorem compile_eval (e : EMLExpr) (env : ℕ → ℝ) :
    (compile e).eval env = e.eval env := by
  induction e with
  | const c => rfl
  | var n => rfl
  | add p q hp hq => simp [compile, EMLExpr.eval, EMLOnlyExpr.eval, hp, hq]
  | mul p q hp hq => simp [compile, EMLExpr.eval, EMLOnlyExpr.eval, hp, hq]
  | neg p hp => simp [compile, EMLExpr.eval, EMLOnlyExpr.eval, hp]
  | inv p hp => simp [compile, EMLExpr.eval, EMLOnlyExpr.eval, hp]
  | exp p hp => simp [compile, EMLExpr.eval, EMLOnlyExpr.eval, hp]
  | log p hp => simp [compile, EMLExpr.eval, EMLOnlyExpr.eval, hp]

/-- Every function represented by a finite exp-log-field expression is
represented by a finite expression using only the catalog's EML transcendental
node and field operations. -/
theorem representable_to_single_operator {n : ℕ} {f : (Fin n → ℝ) → ℝ}
    (hf : EMLRepresentable f) : EMLOnlyRepresentable f := by
  rcases hf with ⟨e, he⟩
  refine ⟨compile e, ?_⟩
  intro x
  rw [compile_eval, he]

/-- Embed a single-operator expression back into the exp-log grammar. -/
def expand : EMLOnlyExpr → EMLExpr
  | .const c => .const c
  | .var n => .var n
  | .add p q => .add (expand p) (expand q)
  | .mul p q => .mul (expand p) (expand q)
  | .neg p => .neg (expand p)
  | .inv p => .inv (expand p)
  | .eml p q => .add (.exp (expand p)) (.neg (.log (expand q)))

/-- Expansion also preserves denotation. -/
theorem expand_eval (e : EMLOnlyExpr) (env : ℕ → ℝ) :
    (expand e).eval env = e.eval env := by
  induction e with
  | const c => rfl
  | var n => rfl
  | add p q hp hq => simp [expand, EMLExpr.eval, EMLOnlyExpr.eval, hp, hq]
  | mul p q hp hq => simp [expand, EMLExpr.eval, EMLOnlyExpr.eval, hp, hq]
  | neg p hp => simp [expand, EMLExpr.eval, EMLOnlyExpr.eval, hp]
  | inv p hp => simp [expand, EMLExpr.eval, EMLOnlyExpr.eval, hp]
  | eml p q hp hq =>
      simp [expand, EMLExpr.eval, EMLOnlyExpr.eval, hp, hq, sub_eq_add_neg]

/-- The two catalog notions of finite representability coincide exactly. -/
theorem representable_iff_single_operator {n : ℕ} {f : (Fin n → ℝ) → ℝ} :
    EMLRepresentable f ↔ EMLOnlyRepresentable f := by
  constructor
  · exact representable_to_single_operator
  · rintro ⟨e, he⟩
    refine ⟨expand e, ?_⟩
    intro x
    rw [expand_eval, he]

/-- A source expression for the monomial `x_k ^ m`. -/
def monomialExpr (k : ℕ) : ℕ → EMLExpr
  | 0 => .const 1
  | m + 1 => .mul (.var k) (monomialExpr k m)

/-- The monomial syntax has its expected semantics. -/
theorem monomialExpr_eval (k m : ℕ) (env : ℕ → ℝ) :
    (monomialExpr k m).eval env = env k ^ m := by
  induction m with
  | zero => rfl
  | succ m ih =>
      simp [monomialExpr, EMLExpr.eval, ih, pow_succ, mul_comm]

/-- Horner syntax for a coefficient list in ascending order.  Thus
`[a₀,a₁,...,aₘ]` denotes `a₀ + x(a₁ + x(... + xaₘ))`. -/
def polynomialExpr (k : ℕ) : List ℝ → EMLExpr
  | [] => .const 0
  | a :: as => .add (.const a) (.mul (.var k) (polynomialExpr k as))

/-- Numerical Horner evaluation for the same ascending coefficient convention. -/
def polynomialValue (x : ℝ) : List ℝ → ℝ
  | [] => 0
  | a :: as => a + x * polynomialValue x as

/-- Every coefficient-list polynomial is computed exactly by its source syntax. -/
theorem polynomialExpr_eval (k : ℕ) (as : List ℝ) (env : ℕ → ℝ) :
    (polynomialExpr k as).eval env = polynomialValue (env k) as := by
  induction as with
  | nil => rfl
  | cons a as ih => simp [polynomialExpr, polynomialValue, EMLExpr.eval, ih]

/-- Every univariate coefficient-list polynomial has an explicit compiled
single-operator expression. -/
theorem polynomial_single_operator (as : List ℝ) :
    EMLOnlyRepresentable (fun x : Fin 1 → ℝ => polynomialValue (x 0) as) := by
  refine ⟨compile (polynomialExpr 0 as), ?_⟩
  intro x
  rw [compile_eval, polynomialExpr_eval]
  have hx : emlEnv x 0 = x (0 : Fin 1) := emlEnv_coe x (0 : Fin 1)
  rw [hx]

/-- Real exponential is represented by one EML node. -/
theorem exp_single_operator :
    EMLOnlyRepresentable (fun x : Fin 1 → ℝ => Real.exp (x 0)) := by
  refine ⟨.eml (.var 0) (.const 1), ?_⟩
  intro x
  have hx : emlEnv x 0 = x (0 : Fin 1) := emlEnv_coe x (0 : Fin 1)
  simp [EMLOnlyExpr.eval, hx]

/-- Mathlib's total real logarithm is represented by one EML node plus field
operations. -/
theorem log_single_operator :
    EMLOnlyRepresentable (fun x : Fin 1 → ℝ => Real.log (x 0)) := by
  refine ⟨.add (.const 1) (.neg (.eml (.const 0) (.var 0))), ?_⟩
  intro x
  have hx : emlEnv x 0 = x (0 : Fin 1) := emlEnv_coe x (0 : Fin 1)
  simp [EMLOnlyExpr.eval, hx]

/-- The compiler is extensionally a retraction after expansion: compiling an
expanded single-operator term does not change its value. -/
theorem compile_expand_eval (e : EMLOnlyExpr) (env : ℕ → ℝ) :
    (compile (expand e)).eval env = e.eval env := by
  rw [compile_eval, expand_eval]

/-! ## The product primitive from the mission statement

The catalog name `eml` denotes `exp(a) - log(b)`.  The mission statement also
mentions the different primitive `exp(a) * log(b)`.  The following syntax and
compiler verify that version independently, without changing the established
catalog definition. -/

/-- Expressions whose sole transcendental primitive is
`productEML(a,b) = exp(a) * log(b)`. -/
inductive ProductEMLExpr : Type where
  | const (c : ℝ)
  | var (n : ℕ)
  | add (p q : ProductEMLExpr)
  | mul (p q : ProductEMLExpr)
  | neg (p : ProductEMLExpr)
  | inv (p : ProductEMLExpr)
  | productEML (p q : ProductEMLExpr)
  deriving Inhabited

namespace ProductEMLExpr

/-- Total denotational semantics of the product-primitive grammar. -/
def eval : ProductEMLExpr → (ℕ → ℝ) → ℝ
  | .const c, _ => c
  | .var n, env => env n
  | .add p q, env => p.eval env + q.eval env
  | .mul p q, env => p.eval env * q.eval env
  | .neg p, env => -(p.eval env)
  | .inv p, env => (p.eval env)⁻¹
  | .productEML p q, env => Real.exp (p.eval env) * Real.log (q.eval env)

end ProductEMLExpr

/-- Compile exp-log-field expressions to the product primitive.  Here
`log(b) = productEML(0,b)` and
`exp(a) = productEML(a,exp(1))`, since `log(exp(1)) = 1`. -/
def compileProduct : EMLExpr → ProductEMLExpr
  | .const c => .const c
  | .var n => .var n
  | .add p q => .add (compileProduct p) (compileProduct q)
  | .mul p q => .mul (compileProduct p) (compileProduct q)
  | .neg p => .neg (compileProduct p)
  | .inv p => .inv (compileProduct p)
  | .exp p => .productEML (compileProduct p) (.const (Real.exp 1))
  | .log p => .productEML (.const 0) (compileProduct p)

/-- The product-primitive compiler preserves the value of every expression. -/
theorem compileProduct_eval (e : EMLExpr) (env : ℕ → ℝ) :
    (compileProduct e).eval env = e.eval env := by
  induction e with
  | const c => rfl
  | var n => rfl
  | add p q hp hq => simp [compileProduct, ProductEMLExpr.eval, EMLExpr.eval, hp, hq]
  | mul p q hp hq => simp [compileProduct, ProductEMLExpr.eval, EMLExpr.eval, hp, hq]
  | neg p hp => simp [compileProduct, ProductEMLExpr.eval, EMLExpr.eval, hp]
  | inv p hp => simp [compileProduct, ProductEMLExpr.eval, EMLExpr.eval, hp]
  | exp p hp =>
      simp [compileProduct, ProductEMLExpr.eval, EMLExpr.eval, hp]
  | log p hp =>
      simp [compileProduct, ProductEMLExpr.eval, EMLExpr.eval, hp]

/-- Representability using the product primitive. -/
def ProductEMLRepresentable {n : ℕ} (f : (Fin n → ℝ) → ℝ) : Prop :=
  ∃ e : ProductEMLExpr, ∀ x : Fin n → ℝ, e.eval (emlEnv x) = f x

/-- Every function in the exp-log-field grammar is exactly representable using
`exp(a) * log(b)` as its only transcendental primitive. -/
theorem representable_to_product_operator {n : ℕ} {f : (Fin n → ℝ) → ℝ}
    (hf : EMLRepresentable f) : ProductEMLRepresentable f := by
  rcases hf with ⟨e, he⟩
  refine ⟨compileProduct e, ?_⟩
  intro x
  rw [compileProduct_eval, he]

/-- In particular, every coefficient-list polynomial has a product-primitive
representation. -/
theorem polynomial_product_operator (as : List ℝ) :
    ProductEMLRepresentable (fun x : Fin 1 → ℝ => polynomialValue (x 0) as) := by
  refine ⟨compileProduct (polynomialExpr 0 as), ?_⟩
  intro x
  rw [compileProduct_eval, polynomialExpr_eval]
  have hx : emlEnv x 0 = x (0 : Fin 1) := emlEnv_coe x (0 : Fin 1)
  rw [hx]

end EMLSingleOperator