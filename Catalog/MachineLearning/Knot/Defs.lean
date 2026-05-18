/-
  # Knot Diagram Definitions

  Combinatorial model of unoriented and oriented link diagrams,
  Reidemeister moves, and state assignments for the Kauffman bracket.
-/
import Mathlib

namespace Knot

/-! ## Smoothing types -/

/-- A smoothing choice at a crossing: A-resolution or B-resolution. -/
inductive Smoothing : Type
  | A : Smoothing
  | B : Smoothing
  deriving DecidableEq, Fintype, Repr, Inhabited

namespace Smoothing

def flip : Smoothing → Smoothing
  | .A => .B
  | .B => .A

@[simp] theorem flip_flip (s : Smoothing) : s.flip.flip = s := by cases s <;> rfl

end Smoothing

/-! ## Sign type for oriented crossings -/

inductive CrossingSign : Type
  | pos : CrossingSign
  | neg : CrossingSign
  deriving DecidableEq, Fintype, Repr, Inhabited

namespace CrossingSign

def toInt : CrossingSign → ℤ
  | .pos => 1
  | .neg => -1

end CrossingSign

/-! ## Link diagrams -/

/-- An unoriented link diagram with `n` crossings.
For each smoothing state, `loops` gives the number of resulting circles. -/
structure LinkDiagram (n : ℕ) where
  loops : (Fin n → Smoothing) → ℕ
  loops_pos : ∀ s, 0 < loops s

/-- A state assigns a smoothing to each crossing. -/
abbrev KState (n : ℕ) := Fin n → Smoothing

/-- Number of A-smoothings in a state -/
noncomputable def numAS (n : ℕ) (s : KState n) : ℕ :=
  (Finset.univ.filter (fun i => s i = Smoothing.A)).card

/-- Number of B-smoothings in a state -/
noncomputable def numBS (n : ℕ) (s : KState n) : ℕ :=
  (Finset.univ.filter (fun i => s i = Smoothing.B)).card

/-! ## Oriented link diagrams -/

/-- An oriented link diagram: unoriented diagram plus crossing signs. -/
structure OrientedLinkDiagram (n : ℕ) extends LinkDiagram n where
  sign : Fin n → CrossingSign

/-- The writhe: sum of crossing signs. -/
noncomputable def writhe {n : ℕ} (D : OrientedLinkDiagram n) : ℤ :=
  ∑ i : Fin n, (D.sign i).toInt

/-! ## Reidemeister moves -/

/-- Reidemeister I (positive kink) -/
structure ReidemeisterI {n : ℕ} (D₁ : OrientedLinkDiagram (n + 1))
    (D₂ : OrientedLinkDiagram n) : Prop where
  kink_sign : D₁.sign (Fin.last n) = CrossingSign.pos
  sign_agree : ∀ (i : Fin n), D₁.sign (i.castSucc) = D₂.sign i
  loops_A : ∀ (s : KState n),
    D₁.loops (Fin.snoc s Smoothing.A) = D₂.loops s + 1
  loops_B : ∀ (s : KState n),
    D₁.loops (Fin.snoc s Smoothing.B) = D₂.loops s

/-- Reidemeister III -/
structure ReidemeisterIII {n : ℕ} (D₁ D₂ : LinkDiagram n) : Prop where
  state_bijection : ∃ (f : KState n → KState n),
    Function.Bijective f ∧
    (∀ s, numAS n s = numAS n (f s)) ∧
    (∀ s, D₁.loops s = D₂.loops (f s))

/-! ## Concrete diagrams -/

/-- The unknot diagram: zero crossings, one loop -/
def unknotDiagram : LinkDiagram 0 where
  loops := fun _ => 1
  loops_pos := fun _ => Nat.one_pos

/-- The oriented unknot -/
def orientedUnknot : OrientedLinkDiagram 0 where
  toLinkDiagram := unknotDiagram
  sign := Fin.elim0

end Knot