import Mathlib

/-! Minimal propositional syntax and semantics used by the proof-refinement development. -/

namespace Logic.Propositional

/-- Propositional formulas over natural-numbered atoms. -/
inductive Formula where
  | atom : ℕ → Formula
  | imp : Formula → Formula → Formula
deriving DecidableEq, Repr

namespace Formula

/-- Evaluation of a formula under a Boolean valuation. -/
def eval (v : ℕ → Bool) : Formula → Bool
  | atom n => v n
  | imp p q => !eval v p || eval v q

/-- Semantic equivalence under every valuation. -/
def SemEq (p q : Formula) : Prop := ∀ v, eval v p = eval v q

/-- Syntactically equal formulas are semantically equivalent. -/
theorem semEq_of_eq {p q : Formula} (h : p = q) : SemEq p q := by
  subst q
  intro v
  rfl

end Formula
end Logic.Propositional