/-
  Propositional Logic — Syntax and Semantics

  A minimal, self-contained development of the syntax of propositional formulas
  together with a Boolean-valuation semantics.  This file is the *syntax* layer
  used by the proof-refinement system (`Learning.ProofRefinement`); proof terms
  are syntactic trees whose nodes are annotated by the `Formula`s they assert.

  * `Formula`            : the abstract syntax of propositional formulas.
  * `Formula.eval`       : truth-value under a Boolean valuation `v : ℕ → Bool`.
  * `Formula.SemEq`      : two formulas are semantically equal when they evaluate
                           identically under every valuation.
  * `Formula.Tautology`  : a formula true under every valuation.

  `SemEq` is proved to be an equivalence relation; equal formulas are `SemEq`.
-/
import Mathlib

namespace Logic.Propositional

/-- Abstract syntax of propositional formulas. -/
inductive Formula where
  | atom : ℕ → Formula
  | fls  : Formula
  | imp  : Formula → Formula → Formula
  | conj : Formula → Formula → Formula
  | disj : Formula → Formula → Formula
deriving DecidableEq, Repr

namespace Formula

/-- Truth value of a formula under a Boolean valuation of the atoms. -/
def eval (v : ℕ → Bool) : Formula → Bool
  | atom n   => v n
  | fls      => false
  | imp a b  => (! eval v a) || eval v b
  | conj a b => eval v a && eval v b
  | disj a b => eval v a || eval v b

/-- Structural size of a formula (number of nodes). -/
def size : Formula → ℕ
  | atom _   => 1
  | fls      => 1
  | imp a b  => 1 + size a + size b
  | conj a b => 1 + size a + size b
  | disj a b => 1 + size a + size b

/-- Two formulas are semantically equal when they agree under every valuation. -/
def SemEq (f g : Formula) : Prop := ∀ v, eval v f = eval v g

/-- A formula that is true under every valuation. -/
def Tautology (f : Formula) : Prop := ∀ v, eval v f = true

@[refl]
theorem SemEq.refl (f : Formula) : SemEq f f := fun _ => rfl

theorem SemEq.symm {f g : Formula} (h : SemEq f g) : SemEq g f :=
  fun v => (h v).symm

theorem SemEq.trans {f g h : Formula} (h₁ : SemEq f g) (h₂ : SemEq g h) :
    SemEq f h := fun v => (h₁ v).trans (h₂ v)

/-- Equal formulas are semantically equal. -/
theorem semEq_of_eq {f g : Formula} (h : f = g) : SemEq f g := by
  subst h; rfl

theorem SemEq.equivalence : Equivalence SemEq :=
  ⟨SemEq.refl, SemEq.symm, SemEq.trans⟩

end Formula

end Logic.Propositional