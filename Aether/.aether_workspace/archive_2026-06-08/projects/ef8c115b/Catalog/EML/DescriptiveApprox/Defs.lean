import Mathlib

/-!
# EML Descriptive Approximation Theory — Core Definitions

This file introduces the **EML expression language** (Exponential-Multiplicative-Logarithmic),
a formal symbolic system for approximating real-valued functions using constants, variables,
addition, multiplication, exponentiation, and logarithm.

We define:
- `EMLExpr`: the inductive type of EML expressions
- `EMLExpr.size`, `EMLExpr.depth`: structural complexity measures
- `EMLExpr.eval`: evaluation of EML expressions
- `UniformApproxOn`: uniform approximation predicate on intervals
- `eml_description_complexity`: a resource-bounded symbolic Kolmogorov complexity surrogate
- `eml_min_depth`: minimum depth of an EML approximant
- `retained_symbolic_information`: information decay model
- `EMLExpr.ofCoeffs`: polynomial-to-EML conversion via Horner's method

This constitutes the foundation of **descriptive approximation theory for compositional
transcendental models**.
-/

noncomputable section

open Real Finset

/-! ## The EML Expression Language -/

/-- An EML (Exponential-Multiplicative-Logarithmic) expression.
This is a formal symbolic expression built from constants, variables,
addition, multiplication, exponentiation, and logarithm. -/
inductive EMLExpr where
  | const : ℝ → EMLExpr
  | var   : ℕ → EMLExpr
  | add   : EMLExpr → EMLExpr → EMLExpr
  | mul   : EMLExpr → EMLExpr → EMLExpr
  | exp   : EMLExpr → EMLExpr
  | log   : EMLExpr → EMLExpr
  deriving Inhabited

namespace EMLExpr

/-- The **size** (number of nodes) of an EML expression.
This serves as the primary structural complexity measure. -/
def size : EMLExpr → ℕ
  | const _ => 1
  | var _   => 1
  | add e₁ e₂ => e₁.size + e₂.size + 1
  | mul e₁ e₂ => e₁.size + e₂.size + 1
  | exp e => e.size + 1
  | log e => e.size + 1

/-- The **depth** (longest root-to-leaf path) of an EML expression.
Depth measures the compositional nesting and is the key parameter
for architecture efficiency. -/
def depth : EMLExpr → ℕ
  | const _ => 0
  | var _   => 0
  | add e₁ e₂ => max e₁.depth e₂.depth + 1
  | mul e₁ e₂ => max e₁.depth e₂.depth + 1
  | exp e => e.depth + 1
  | log e => e.depth + 1

/-- **Evaluation** of an EML expression in an environment `ρ : ℕ → ℝ`
mapping variable indices to real values. -/
def eval (ρ : ℕ → ℝ) : EMLExpr → ℝ
  | const c   => c
  | var i     => ρ i
  | add e₁ e₂ => e₁.eval ρ + e₂.eval ρ
  | mul e₁ e₂ => e₁.eval ρ * e₂.eval ρ
  | exp e     => Real.exp (e.eval ρ)
  | log e     => Real.log (e.eval ρ)

/-- Size is always positive. -/
theorem size_pos (e : EMLExpr) : 0 < e.size := by
  cases e <;> simp [size]

/-- Depth is bounded by size. -/
theorem depth_le_size (e : EMLExpr) : e.depth ≤ e.size := by
  induction e with
  | const _ => simp [depth, size]
  | var _ => simp [depth, size]
  | add _ _ ih₁ ih₂ => simp [depth, size]; omega
  | mul _ _ ih₁ ih₂ => simp [depth, size]; omega
  | exp e ih => simp [depth, size]; omega
  | log e ih => simp [depth, size]; omega

/-- Size of an add node. -/
@[simp] theorem size_add (e₁ e₂ : EMLExpr) : (add e₁ e₂).size = e₁.size + e₂.size + 1 := rfl

/-- Size of a mul node. -/
@[simp] theorem size_mul (e₁ e₂ : EMLExpr) : (mul e₁ e₂).size = e₁.size + e₂.size + 1 := rfl

/-- Evaluation of add is sum of evaluations. -/
@[simp] theorem eval_add (ρ : ℕ → ℝ) (e₁ e₂ : EMLExpr) :
    (add e₁ e₂).eval ρ = e₁.eval ρ + e₂.eval ρ := rfl

/-- Evaluation of mul is product of evaluations. -/
@[simp] theorem eval_mul (ρ : ℕ → ℝ) (e₁ e₂ : EMLExpr) :
    (mul e₁ e₂).eval ρ = e₁.eval ρ * e₂.eval ρ := rfl

/-- Evaluation of const is the constant. -/
@[simp] theorem eval_const (ρ : ℕ → ℝ) (c : ℝ) : (const c).eval ρ = c := rfl

/-- Evaluation of var is the environment lookup. -/
@[simp] theorem eval_var (ρ : ℕ → ℝ) (i : ℕ) : (var i).eval ρ = ρ i := rfl

/-! ## Polynomial-to-EML Conversion (Horner's Method)

We define a conversion from a coefficient function to an EML expression
using Horner's method:
  `ofCoeffs n c` represents `c 0 + x * (c 1 + x * (c 2 + ... + x * c n))`.
-/

/-- Convert a polynomial given by coefficients `c 0, c 1, ..., c n` into an
EML expression via Horner's method. The result evaluates to
`∑ i in range (n+1), c i * x ^ i` when the environment maps variable 0 to x. -/
def ofCoeffs : ℕ → (ℕ → ℝ) → EMLExpr
  | 0, c => .const (c 0)
  | n + 1, c => .add (.const (c 0)) (.mul (.var 0) (ofCoeffs n (fun i => c (i + 1))))

end EMLExpr

/-! ## Approximation Predicates -/

/-- **Uniform approximation** of `f` by `g` on the interval `[a, b]` to within `eps`. -/
def UniformApproxOn (f g : ℝ → ℝ) (a b eps : ℝ) : Prop :=
  ∀ x, a ≤ x → x ≤ b → |f x - g x| ≤ eps

/-- The standard environment for single-variable EML expressions:
variable 0 is mapped to x, all others to 0. -/
def stdEnv (x : ℝ) : ℕ → ℝ := fun i => if i = 0 then x else 0

/-- Shorthand for evaluating a single-variable EML expression at x. -/
def EMLExpr.eval1 (e : EMLExpr) (x : ℝ) : ℝ := e.eval (stdEnv x)

/-! ## Complexity Measures -/

/-- The **EML description complexity** of a function `f` on `[a, b]` at precision `eps`.
This is the infimum of expression sizes over all EML approximants — a resource-bounded
symbolic Kolmogorov complexity surrogate.

When no approximant exists, the value is 0 (by convention of `sInf ∅` for `ℕ`). -/
def eml_description_complexity (f : ℝ → ℝ) (a b eps : ℝ) : ℕ :=
  sInf {n : ℕ | ∃ e : EMLExpr, e.size ≤ n ∧ UniformApproxOn f e.eval1 a b eps}

/-- The **minimum EML depth** needed to approximate `f` on `[a, b]` to precision `eps`. -/
def eml_min_depth (f : ℝ → ℝ) (a b eps : ℝ) : ℕ :=
  sInf {n : ℕ | ∃ e : EMLExpr, e.depth ≤ n ∧ UniformApproxOn f e.eval1 a b eps}

/-! ## Information-Theoretic Definitions -/

/-- The **retained symbolic information** after `l` layers of an EML architecture
with per-layer contraction factor `alpha`, starting from `K` bits of description complexity.
Models exponential information decay through depth. -/
def retained_symbolic_information (alpha : ℝ) (l K : ℕ) : ℝ :=
  alpha ^ l * (K : ℝ)

end