/-
  # Provability Logic GL — Definitions

  This file establishes the Kripke-semantic foundation for provability logic GL.
  GL (Gödel-Löb logic) is the modal logic of formal provability, where □φ is
  interpreted as "φ is provable." The key semantic feature is that GL frames
  have a transitive, converse well-founded accessibility relation — corresponding
  to the well-foundedness of the provability ordering on theories.
-/

import Mathlib

open Classical

namespace ProvabilityLogic

/-- A GL frame is a Kripke frame (W, R) where R is transitive and
    converse well-founded (no infinite ascending R-chains).
    This captures the essential structure of the provability relation. -/
structure GLFrame where
  W : Type
  R : W → W → Prop
  trans : ∀ w v u, R w v → R v u → R w u
  wf : WellFounded (fun v w => R w v)

/-- Modal formulas over a type of propositional variables. -/
inductive MFormula (Var : Type) where
  | var : Var → MFormula Var
  | bot : MFormula Var
  | imp : MFormula Var → MFormula Var → MFormula Var
  | box : MFormula Var → MFormula Var
  deriving Inhabited

namespace MFormula

variable {Var : Type}

/-- Negation: ¬φ := φ → ⊥ -/
def neg (φ : MFormula Var) : MFormula Var := imp φ bot

/-- Top: ⊤ := ¬⊥ -/
def top : MFormula Var := neg bot

/-- Diamond: ◇φ := ¬□¬φ -/
def dia (φ : MFormula Var) : MFormula Var := neg (box (neg φ))

end MFormula

/-- A modal valuation assigns a truth value to each propositional variable at each world. -/
def MValuation (W Var : Type) := W → Var → Prop

/-- The Kripke forcing relation: w ⊩ φ under valuation V in frame F. -/
def Forces {Var : Type} (F : GLFrame) (V : MValuation F.W Var) :
    F.W → MFormula Var → Prop
  | w, .var p => V w p
  | _, .bot => False
  | w, .imp φ ψ => Forces F V w φ → Forces F V w ψ
  | w, .box φ => ∀ v, F.R w v → Forces F V v φ

/-- A formula is valid in a frame if it holds at every world under every valuation. -/
def FrameValid {Var : Type} (F : GLFrame) (φ : MFormula Var) : Prop :=
  ∀ (V : MValuation F.W Var) (w : F.W), Forces F V w φ

/-- A world is GL-sound if □φ → φ holds for all formulas.
    This is the semantic analogue of ω-consistency / soundness. -/
def GLSound {Var : Type} (F : GLFrame) (V : MValuation F.W Var) (w : F.W) : Prop :=
  ∀ φ, Forces F V w (.box φ) → Forces F V w φ

/-- A world w has no accessible successors. -/
def HasNoSuccessors (F : GLFrame) (w : F.W) : Prop := ∀ v, ¬F.R w v

/-- The consistency formula: ¬□⊥, i.e., "the system is consistent." -/
def ConFormula (Var : Type) : MFormula Var := MFormula.neg (.box .bot)

/-- A world forces the consistency formula. -/
def ForcesConsistency {Var : Type} (F : GLFrame) (V : MValuation F.W Var) (w : F.W) : Prop :=
  Forces F V w (ConFormula Var)

/-- A world internalizes soundness: it forces □(□φ → φ) for all φ. -/
def InternalizesSoundness {Var : Type} (F : GLFrame) (V : MValuation F.W Var) (w : F.W) : Prop :=
  ∀ φ, Forces F V w (.box (.imp (.box φ) φ))

/-- GL irreflexivity: no world accesses itself (follows from transitivity + well-foundedness). -/
theorem gl_irrefl (F : GLFrame) (w : F.W) : ¬F.R w w := by
  obtain ⟨ v, hv ⟩ := F.wf.has_min { w } ⟨ w, by simp +decide ⟩ ; aesop;

end ProvabilityLogic