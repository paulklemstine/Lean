/-
  # Knot Diagram Definitions for the Jones Polynomial

  Combinatorial model of link diagrams, smoothing states,
  Reidemeister moves, and the algebraic framework for the
  Kauffman bracket and Jones polynomial.

  ## Mathematical Framework

  A link diagram with `n` crossings is modeled by the function
  `loops : (Fin n → Smoothing) → ℕ` that counts the number of
  resulting circles when each crossing is resolved by either
  an A-smoothing or a B-smoothing. This state-sum approach
  captures the full combinatorial content of the Kauffman bracket.
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
@[simp] theorem flip_A : Smoothing.A.flip = Smoothing.B := rfl
@[simp] theorem flip_B : Smoothing.B.flip = Smoothing.A := rfl

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

@[simp] theorem toInt_pos : CrossingSign.pos.toInt = 1 := rfl
@[simp] theorem toInt_neg : CrossingSign.neg.toInt = -1 := rfl

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
noncomputable def numA {n : ℕ} (s : KState n) : ℕ :=
  (Finset.univ.filter (fun i => s i = Smoothing.A)).card

/-- Number of B-smoothings in a state -/
noncomputable def numB {n : ℕ} (s : KState n) : ℕ :=
  (Finset.univ.filter (fun i => s i = Smoothing.B)).card

/-! ## Oriented link diagrams -/

/-- An oriented link diagram: unoriented diagram plus crossing signs. -/
structure OrientedLinkDiagram (n : ℕ) extends LinkDiagram n where
  sign : Fin n → CrossingSign

/-- The writhe: sum of crossing signs. -/
noncomputable def writhe {n : ℕ} (D : OrientedLinkDiagram n) : ℤ :=
  ∑ i : Fin n, (D.sign i).toInt

/-! ## Reidemeister moves -/

/-- Reidemeister I (positive kink): D₁ has n+1 crossings with a positive kink
    at the last crossing. -/
structure ReidemeisterI {n : ℕ} (D₁ : OrientedLinkDiagram (n + 1))
    (D₂ : OrientedLinkDiagram n) : Prop where
  kink_sign : D₁.sign (Fin.last n) = CrossingSign.pos
  sign_agree : ∀ (i : Fin n), D₁.sign (i.castSucc) = D₂.sign i
  loops_A : ∀ (s : KState n),
    D₁.loops (Fin.snoc s Smoothing.A) = D₂.loops s + 1
  loops_B : ∀ (s : KState n),
    D₁.loops (Fin.snoc s Smoothing.B) = D₂.loops s

/-- Negative Reidemeister I -/
structure ReidemeisterI_neg {n : ℕ} (D₁ : OrientedLinkDiagram (n + 1))
    (D₂ : OrientedLinkDiagram n) : Prop where
  kink_sign : D₁.sign (Fin.last n) = CrossingSign.neg
  sign_agree : ∀ (i : Fin n), D₁.sign (i.castSucc) = D₂.sign i
  loops_A : ∀ (s : KState n),
    D₁.loops (Fin.snoc s Smoothing.A) = D₂.loops s
  loops_B : ∀ (s : KState n),
    D₁.loops (Fin.snoc s Smoothing.B) = D₂.loops s + 1

/-- Reidemeister II: D₁ has n+2 crossings forming a cancelling pair. -/
structure ReidemeisterII {n : ℕ} (D₁ : LinkDiagram (n + 2))
    (D₂ : LinkDiagram n) : Prop where
  loops_AA : ∀ (s : KState n),
    D₁.loops (Fin.snoc (Fin.snoc s Smoothing.A) Smoothing.A) = D₂.loops s + 1
  loops_AB : ∀ (s : KState n),
    D₁.loops (Fin.snoc (Fin.snoc s Smoothing.A) Smoothing.B) = D₂.loops s
  loops_BA : ∀ (s : KState n),
    D₁.loops (Fin.snoc (Fin.snoc s Smoothing.B) Smoothing.A) = D₂.loops s
  loops_BB : ∀ (s : KState n),
    D₁.loops (Fin.snoc (Fin.snoc s Smoothing.B) Smoothing.B) = D₂.loops s + 1

/-- Reidemeister III: same crossing count with state bijection. -/
structure ReidemeisterIII {n : ℕ} (D₁ D₂ : LinkDiagram n) : Prop where
  state_bijection : ∃ (f : KState n → KState n),
    Function.Bijective f ∧
    (∀ s, numA s = numA (f s)) ∧
    (∀ s, D₁.loops s = D₂.loops (f s))

/-- Oriented Reidemeister III preserves writhe. -/
structure OrientedReidemeisterIII {n : ℕ}
    (D₁ D₂ : OrientedLinkDiagram n) : Prop where
  unoriented : ReidemeisterIII D₁.toLinkDiagram D₂.toLinkDiagram
  writhe_eq : writhe D₁ = writhe D₂

/-! ## Reidemeister equivalence -/

/-- Two oriented link diagrams (possibly with different crossing counts)
    are Reidemeister equivalent if they are related by a sequence of moves. -/
inductive ReidemeisterEquiv : (Σ n, OrientedLinkDiagram n) → (Σ n, OrientedLinkDiagram n) → Prop
  | refl (D : Σ n, OrientedLinkDiagram n) : ReidemeisterEquiv D D
  | symm {D₁ D₂} : ReidemeisterEquiv D₁ D₂ → ReidemeisterEquiv D₂ D₁
  | trans {D₁ D₂ D₃} : ReidemeisterEquiv D₁ D₂ → ReidemeisterEquiv D₂ D₃ →
      ReidemeisterEquiv D₁ D₃
  | ri_pos {n} {D₁ : OrientedLinkDiagram (n + 1)} {D₂ : OrientedLinkDiagram n} :
      ReidemeisterI D₁ D₂ → ReidemeisterEquiv ⟨n + 1, D₁⟩ ⟨n, D₂⟩
  | ri_neg {n} {D₁ : OrientedLinkDiagram (n + 1)} {D₂ : OrientedLinkDiagram n} :
      ReidemeisterI_neg D₁ D₂ → ReidemeisterEquiv ⟨n + 1, D₁⟩ ⟨n, D₂⟩
  | riii {n} {D₁ D₂ : OrientedLinkDiagram n} :
      OrientedReidemeisterIII D₁ D₂ → ReidemeisterEquiv ⟨n, D₁⟩ ⟨n, D₂⟩

/-! ## Concrete diagrams -/

/-- The unknot diagram: zero crossings, one loop. -/
def unknotDiagram : LinkDiagram 0 where
  loops := fun _ => 1
  loops_pos := fun _ => Nat.one_pos

/-- The oriented unknot. -/
def orientedUnknot : OrientedLinkDiagram 0 where
  toLinkDiagram := unknotDiagram
  sign := Fin.elim0

end Knot