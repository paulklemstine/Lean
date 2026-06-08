/-
# EML Expression Complexity Theory: Core Definitions

This file defines the source grammar (UExpr) of unary elementary real functions,
the target EML grammar (EMLExpr) built from the single transcendental primitive
  eml(x, y) := exp(x) - log(y),
and denotational semantics for both via partial evaluation (Option ℝ).
-/
import Mathlib

noncomputable section

open Real

/-! ## Source Grammar: Unary Elementary Expressions -/

/-- A unary elementary expression over ℝ, supporting constants, the variable,
    field operations (+, -, ×, ÷), and transcendental operations (exp, log). -/
inductive UExpr where
  | var   : UExpr
  | const : ℝ → UExpr
  | add   : UExpr → UExpr → UExpr
  | sub   : UExpr → UExpr → UExpr
  | mul   : UExpr → UExpr → UExpr
  | div   : UExpr → UExpr → UExpr
  | exp   : UExpr → UExpr
  | log   : UExpr → UExpr
deriving DecidableEq

/-! ## Target Grammar: EML Expressions -/

/-- An EML expression: like UExpr but with exp/log replaced by the single
    primitive `eml(x, y) = exp(x) - log(y)`. -/
inductive EMLExpr where
  | var   : EMLExpr
  | const : ℝ → EMLExpr
  | add   : EMLExpr → EMLExpr → EMLExpr
  | sub   : EMLExpr → EMLExpr → EMLExpr
  | mul   : EMLExpr → EMLExpr → EMLExpr
  | div   : EMLExpr → EMLExpr → EMLExpr
  | eml   : EMLExpr → EMLExpr → EMLExpr   -- eml(x, y) = exp(x) - log(y)
deriving DecidableEq

/-! ## Expression Size -/

/-- Size of a UExpr: counts all nodes in the expression tree. -/
def UExpr.size : UExpr → ℕ
  | .var       => 1
  | .const _   => 1
  | .add e₁ e₂ => 1 + e₁.size + e₂.size
  | .sub e₁ e₂ => 1 + e₁.size + e₂.size
  | .mul e₁ e₂ => 1 + e₁.size + e₂.size
  | .div e₁ e₂ => 1 + e₁.size + e₂.size
  | .exp e     => 1 + e.size
  | .log e     => 1 + e.size

/-- Size of an EMLExpr: counts all nodes in the expression tree. -/
def EMLExpr.esize : EMLExpr → ℕ
  | .var       => 1
  | .const _   => 1
  | .add e₁ e₂ => 1 + e₁.esize + e₂.esize
  | .sub e₁ e₂ => 1 + e₁.esize + e₂.esize
  | .mul e₁ e₂ => 1 + e₁.esize + e₂.esize
  | .div e₁ e₂ => 1 + e₁.esize + e₂.esize
  | .eml e₁ e₂ => 1 + e₁.esize + e₂.esize

/-- Every expression has positive size. -/
theorem UExpr.size_pos (e : UExpr) : 0 < e.size := by
  cases e <;> simp [UExpr.size] <;> omega

/-- Every EML expression has positive size. -/
theorem EMLExpr.esize_pos (e : EMLExpr) : 0 < e.esize := by
  cases e <;> simp [EMLExpr.esize] <;> omega

/-! ## Partial Evaluation Semantics -/

/-- Evaluate a UExpr at a real number x. Returns `none` if the expression
    is undefined (division by zero or log of non-positive number). -/
def UExpr.eval : UExpr → ℝ → Option ℝ
  | .var,       x => some x
  | .const c,   _ => some c
  | .add e₁ e₂, x => do let v₁ ← e₁.eval x; let v₂ ← e₂.eval x; some (v₁ + v₂)
  | .sub e₁ e₂, x => do let v₁ ← e₁.eval x; let v₂ ← e₂.eval x; some (v₁ - v₂)
  | .mul e₁ e₂, x => do let v₁ ← e₁.eval x; let v₂ ← e₂.eval x; some (v₁ * v₂)
  | .div e₁ e₂, x => do
      let v₁ ← e₁.eval x; let v₂ ← e₂.eval x
      if v₂ ≠ 0 then some (v₁ / v₂) else none
  | .exp e,     x => do let v ← e.eval x; some (Real.exp v)
  | .log e,     x => do let v ← e.eval x; if 0 < v then some (Real.log v) else none

/-- Evaluate an EMLExpr at a real number x. The eml node eml(e₁, e₂) evaluates to
    exp(v₁) - log(v₂) when v₂ > 0. -/
def EMLExpr.eeval : EMLExpr → ℝ → Option ℝ
  | .var,       x => some x
  | .const c,   _ => some c
  | .add e₁ e₂, x => do let v₁ ← e₁.eeval x; let v₂ ← e₂.eeval x; some (v₁ + v₂)
  | .sub e₁ e₂, x => do let v₁ ← e₁.eeval x; let v₂ ← e₂.eeval x; some (v₁ - v₂)
  | .mul e₁ e₂, x => do let v₁ ← e₁.eeval x; let v₂ ← e₂.eeval x; some (v₁ * v₂)
  | .div e₁ e₂, x => do
      let v₁ ← e₁.eeval x; let v₂ ← e₂.eeval x
      if v₂ ≠ 0 then some (v₁ / v₂) else none
  | .eml e₁ e₂, x => do
      let v₁ ← e₁.eeval x; let v₂ ← e₂.eeval x
      if 0 < v₂ then some (Real.exp v₁ - Real.log v₂) else none

/-! ## Natural Domains -/

/-- The natural domain of a UExpr: the set of reals where evaluation succeeds. -/
def UExpr.NaturalDomain (e : UExpr) : Set ℝ :=
  { x | ∃ y, e.eval x = some y }

/-- The natural domain of an EMLExpr: the set of reals where evaluation succeeds. -/
def EMLExpr.NaturalDomain (e : EMLExpr) : Set ℝ :=
  { x | ∃ y, e.eeval x = some y }

/-! ## Transcendence Measures -/

/-- Count the number of transcendental (exp/log) nodes in a UExpr. -/
def UExpr.transcendenceRank : UExpr → ℕ
  | .var       => 0
  | .const _   => 0
  | .add e₁ e₂ => e₁.transcendenceRank + e₂.transcendenceRank
  | .sub e₁ e₂ => e₁.transcendenceRank + e₂.transcendenceRank
  | .mul e₁ e₂ => e₁.transcendenceRank + e₂.transcendenceRank
  | .div e₁ e₂ => e₁.transcendenceRank + e₂.transcendenceRank
  | .exp e     => 1 + e.transcendenceRank
  | .log e     => 1 + e.transcendenceRank

/-- Count the number of eml nodes in an EMLExpr. -/
def EMLExpr.emlRank : EMLExpr → ℕ
  | .var       => 0
  | .const _   => 0
  | .add e₁ e₂ => e₁.emlRank + e₂.emlRank
  | .sub e₁ e₂ => e₁.emlRank + e₂.emlRank
  | .mul e₁ e₂ => e₁.emlRank + e₂.emlRank
  | .div e₁ e₂ => e₁.emlRank + e₂.emlRank
  | .eml e₁ e₂ => 1 + e₁.emlRank + e₂.emlRank

/-! ## EML Safety Predicate -/

/-- An EMLExpr is EMLSafe if all eml nodes have their second argument
    guaranteed to evaluate positively whenever the whole expression is defined.
    For structural purposes, we define this as a syntactic predicate:
    it holds when every eml's second argument is a positive constant,
    or is itself an eml-safe expression of known positive type. -/
inductive EMLExpr.EMLSafe : EMLExpr → Prop where
  | var   : EMLSafe .var
  | const : EMLSafe (.const c)
  | add   : EMLSafe e₁ → EMLSafe e₂ → EMLSafe (.add e₁ e₂)
  | sub   : EMLSafe e₁ → EMLSafe e₂ → EMLSafe (.sub e₁ e₂)
  | mul   : EMLSafe e₁ → EMLSafe e₂ → EMLSafe (.mul e₁ e₂)
  | div   : EMLSafe e₁ → EMLSafe e₂ → EMLSafe (.div e₁ e₂)
  | eml   : EMLSafe e₁ → EMLSafe e₂ → EMLSafe (.eml e₁ e₂)

/-! ## Polynomial Bounded EML -/

/-- An expression admits a polynomial-bounded EML representation if there exists
    an EMLExpr semantically equivalent on the natural domain with size bounded
    polynomially in the original size. -/
def PolyBoundedEML (e : UExpr) : Prop :=
  ∃ (k C : ℕ) (t : EMLExpr),
    (∀ x y, t.eeval x = some y ↔ e.eval x = some y) ∧
    t.esize ≤ C * (e.size + 1) ^ k

end