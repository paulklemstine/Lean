/-
  # Transseries: Asymptotic Expansions Beyond Power Series

  We formalize a novel hierarchy of transseries — formal asymptotic expansions
  that extend classical power series by incorporating iterated exponentials
  and logarithms. The key mathematical insight: the asymptotic behavior of
  exp-log-monomial (EML) functions is captured by a well-ordered "level"
  structure that governs dominance among terms.

  ## Novel Structure: TransLevel and Transseries

  A `TransLevel` classifies the asymptotic growth rate of a monomial:
  - `Var` represents the identity function x
  - `Exp n` represents the n-fold iterated exponential exp^(n+1)(x)
  - `Log n` represents the n-fold iterated logarithm log^(n+1)(x)

  A `TransMonomial` pairs a level with a real exponent α, representing
  functions like x^α, exp(x)^α, log(log(x))^α.

  A `Transseries` is a finitely-supported formal sum of such monomials,
  providing a canonical asymptotic expansion for EML functions.
-/
import Mathlib


namespace Transseries

/-! ## Level Structure

The `TransLevel` type classifies the asymptotic growth rate of monomials.
The key property: there is a natural total ordering on levels corresponding
to asymptotic dominance, where Exp levels dominate Var, which dominates Log levels.
-/

/-- A level in the transseries hierarchy, encoded as an integer.
  Negative values represent iterated logs, zero represents x,
  positive values represent iterated exponentials.
  E.g., -2 = log(log(x)), -1 = log(x), 0 = x, 1 = exp(x), 2 = exp(exp(x)). -/
def TransLevel := ℤ

instance : DecidableEq TransLevel := inferInstanceAs (DecidableEq ℤ)
instance : LinearOrder TransLevel := inferInstanceAs (LinearOrder ℤ)
instance : Add TransLevel := inferInstanceAs (Add ℤ)
instance : Neg TransLevel := inferInstanceAs (Neg ℤ)
instance : Zero TransLevel := inferInstanceAs (Zero ℤ)
instance : One TransLevel := inferInstanceAs (One ℤ)
instance : Repr TransLevel := inferInstanceAs (Repr ℤ)

namespace TransLevel

/-- The variable level x. -/
def var : TransLevel := (0 : ℤ)

/-- The n-th iterated exponential level exp^n(x). -/
def expLevel (n : ℕ) : TransLevel := (n : ℤ)

/-- The n-th iterated logarithm level log^n(x). -/
def logLevel (n : ℕ) : TransLevel := -(n : ℤ)

/-- Successor level: one more layer of exp. -/
def succ (l : TransLevel) : TransLevel := l + 1

/-- Predecessor level: one more layer of log. -/
def pred (l : TransLevel) : TransLevel := l + (-1)

/-- The depth (absolute nesting) of a level. -/
def depth (l : TransLevel) : ℕ := Int.natAbs l

/-- Evaluate a TransLevel at a real number x.
  Level k means: apply exp k times (if k > 0) or log |k| times (if k < 0) to x. -/
noncomputable def eval : TransLevel → ℝ → ℝ :=
  fun l x =>
    if l = (0 : ℤ) then x
    else if (0 : ℤ) < l then
      -- positive level: apply exp l times
      Nat.iterate Real.exp l.toNat x
    else
      -- negative level: apply log |l| times
      Nat.iterate Real.log (Int.natAbs l) x

end TransLevel

/-! ## Trans-Monomials

A `TransMonomial` pairs a level with a real exponent α, representing
functions like x^α, exp(x)^β, log(log(x))^γ.
-/

/-- A monomial in the transseries expansion.
  `(level, exponent)` represents (eval_level(x))^exponent.
  E.g., level=0, exponent=2 means x², level=1, exponent=1 means exp(x). -/
structure TransMonomial where
  level : TransLevel
  exponent : ℝ

namespace TransMonomial

/-- Dominance: first by level, then by exponent within the same level. -/
noncomputable def domRel (m₁ m₂ : TransMonomial) : Prop :=
  m₁.level < m₂.level ∨ (m₁.level = m₂.level ∧ m₁.exponent < m₂.exponent)

/-- Evaluate a monomial at x > 1. -/
noncomputable def eval (m : TransMonomial) (x : ℝ) : ℝ :=
  (TransLevel.eval m.level x) ^ m.exponent

end TransMonomial

/-! ## Transseries Expansion

A `TransseriesExpansion` is a list of (coefficient, monomial) pairs
in strictly decreasing dominance order. This provides the canonical
form for asymptotic expansions.
-/

/-- A single term in a transseries: coefficient times monomial. -/
structure TransTerm where
  coeff : ℝ
  monomial : TransMonomial

/-- A transseries is a finite list of terms, conceptually in
  decreasing order of asymptotic dominance. -/
structure FormalTransseries where
  terms : List TransTerm

namespace FormalTransseries

/-- The zero transseries. -/
def zero : FormalTransseries := ⟨[]⟩

/-- Number of terms. -/
def length (T : FormalTransseries) : ℕ := T.terms.length

/-- Leading term (first in the list). -/
def leadingTerm? (T : FormalTransseries) : Option TransTerm :=
  T.terms.head?

/-- Leading level. -/
def leadingLevel? (T : FormalTransseries) : Option TransLevel :=
  T.leadingTerm?.map (·.monomial.level)

/-- Evaluate the transseries at a point (finite sum). -/
noncomputable def eval (T : FormalTransseries) (x : ℝ) : ℝ :=
  (T.terms.map (fun t => t.coeff * t.monomial.eval x)).sum

/-- Scaling a transseries by a constant. -/
noncomputable def scale (c : ℝ) (T : FormalTransseries) : FormalTransseries :=
  ⟨T.terms.map (fun t => ⟨c * t.coeff, t.monomial⟩)⟩

/-- Adding two transseries (naive concatenation — not canonical form). -/
def add (T₁ T₂ : FormalTransseries) : FormalTransseries :=
  ⟨T₁.terms ++ T₂.terms⟩

/-- A pure monomial transseries. -/
def ofMonomial (c : ℝ) (level : TransLevel) (exp : ℝ) : FormalTransseries :=
  ⟨[⟨c, ⟨level, exp⟩⟩]⟩

/-- A pure power of x: c · x^α. -/
def powerOfX (c α : ℝ) : FormalTransseries :=
  ofMonomial c TransLevel.var α

/-- A pure exponential term: c · exp(x)^α. -/
def expTerm (c α : ℝ) : FormalTransseries :=
  ofMonomial c (TransLevel.expLevel 1) α

/-- A pure logarithmic term: c · log(x)^α. -/
def logTerm (c α : ℝ) : FormalTransseries :=
  ofMonomial c (TransLevel.logLevel 1) α

end FormalTransseries

/-! ## Well-ordering and Dominance Theorems -/

/-- The set of levels appearing in a transseries. -/
def FormalTransseries.levels (T : FormalTransseries) : List TransLevel :=
  T.terms.map (·.monomial.level)

/-- A transseries is well-ordered if levels appear in strictly decreasing order. -/
def FormalTransseries.isWellOrdered (T : FormalTransseries) : Prop :=
  T.levels.IsChain (· > ·)

/-- A transseries is normalized if it is well-ordered and all coefficients are nonzero. -/
def FormalTransseries.isNormalized (T : FormalTransseries) : Prop :=
  T.isWellOrdered ∧ ∀ t ∈ T.terms, t.coeff ≠ 0

end Transseries