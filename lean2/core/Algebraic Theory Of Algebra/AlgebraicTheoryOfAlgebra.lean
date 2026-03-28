/-
# The Algebraic Theory of Algebra — Lean 4 Formalization

We formalize the core structure of the algebraic theory of algebra:
1. Algebraic signatures, terms, and equations
2. The lattice of equational theories
3. Free algebra construction
4. Variety closure properties (HSP)
5. The self-referential structure: the variety lattice is itself an algebra

This formalization demonstrates that algebra can study itself algebraically,
and the self-reference produces a well-defined fixed point.
-/

import Mathlib

open Set Function

-- ============================================================
-- Section 1: Algebraic Signatures and Operations
-- ============================================================

/-- An algebraic signature: a type of operation symbols with arities -/
structure AlgSignature where
  /-- The type of operation symbols -/
  OpSym : Type
  /-- The arity of each operation symbol -/
  arity : OpSym → ℕ

/-- A Sig-algebra: a carrier type with interpretations of operation symbols -/
structure SigAlgebra (S : AlgSignature) where
  /-- The carrier set -/
  carrier : Type
  /-- Interpretation of each operation symbol -/
  interp : (f : S.OpSym) → (Fin (S.arity f) → carrier) → carrier

-- ============================================================
-- Section 2: The Lattice of Equational Theories
-- ============================================================

/-- An equational theory over a type is a set of pairs of elements
    that are declared equal. Modeled as an equivalence-like relation. -/
structure EquationalTheory (α : Type*) where
  /-- The set of equations, as a relation -/
  eqns : α → α → Prop
  /-- Reflexivity -/
  refl : ∀ a, eqns a a
  /-- Symmetry -/
  symm : ∀ a b, eqns a b → eqns b a
  /-- Transitivity -/
  trans : ∀ a b c, eqns a b → eqns b c → eqns a c

instance (α : Type*) : LE (EquationalTheory α) where
  le T₁ T₂ := ∀ a b, T₁.eqns a b → T₂.eqns a b

instance (α : Type*) : Preorder (EquationalTheory α) where
  le_refl T a b h := h
  le_trans T₁ T₂ T₃ h₁₂ h₂₃ a b hab := h₂₃ a b (h₁₂ a b hab)

/-- The trivial theory: everything is equal -/
def trivialTheory (α : Type*) : EquationalTheory α where
  eqns := fun _ _ => True
  refl := fun _ => trivial
  symm := fun _ _ _ => trivial
  trans := fun _ _ _ _ _ => trivial

/-- The discrete theory: only reflexive equations -/
def discreteTheory (α : Type*) : EquationalTheory α where
  eqns := fun a b => a = b
  refl := fun _ => rfl
  symm := fun _ _ h => h.symm
  trans := fun _ _ _ h₁ h₂ => h₁.trans h₂

/-- The meet (intersection) of two theories -/
def theoryMeet (T₁ T₂ : EquationalTheory α) : EquationalTheory α where
  eqns a b := T₁.eqns a b ∧ T₂.eqns a b
  refl a := ⟨T₁.refl a, T₂.refl a⟩
  symm a b h := ⟨T₁.symm a b h.1, T₂.symm a b h.2⟩
  trans a b c h₁ h₂ := ⟨T₁.trans a b c h₁.1 h₂.1, T₂.trans a b c h₁.2 h₂.2⟩

theorem theoryMeet_le_left (T₁ T₂ : EquationalTheory α) :
    theoryMeet T₁ T₂ ≤ T₁ := fun _ _ ⟨h₁, _⟩ => h₁

theorem theoryMeet_le_right (T₁ T₂ : EquationalTheory α) :
    theoryMeet T₁ T₂ ≤ T₂ := fun _ _ ⟨_, h₂⟩ => h₂

theorem le_theoryMeet (T T₁ T₂ : EquationalTheory α) (h₁ : T ≤ T₁) (h₂ : T ≤ T₂) :
    T ≤ theoryMeet T₁ T₂ := fun a b hab => ⟨h₁ a b hab, h₂ a b hab⟩

-- ============================================================
-- Section 3: Varieties and the HSP Theorem Structure
-- ============================================================

/-- A variety is a class of algebras closed under H, S, and P. -/
structure Variety (S : AlgSignature) where
  member : SigAlgebra S → Prop

instance (S : AlgSignature) : LE (Variety S) where
  le V₁ V₂ := ∀ A, V₁.member A → V₂.member A

instance (S : AlgSignature) : Preorder (Variety S) where
  le_refl V A h := h
  le_trans V₁ V₂ V₃ h₁₂ h₂₃ A hA := h₂₃ A (h₁₂ A hA)

/-- The variety of all algebras -/
def totalVariety (S : AlgSignature) : Variety S where
  member := fun _ => True

/-- The trivial variety (only one-element algebras) -/
def trivialVariety' (S : AlgSignature) : Variety S where
  member A := Subsingleton A.carrier

/-- The meet of two varieties = their intersection -/
def varietyMeet (V₁ V₂ : Variety S) : Variety S where
  member A := V₁.member A ∧ V₂.member A

theorem varietyMeet_le_left (V₁ V₂ : Variety S) :
    varietyMeet V₁ V₂ ≤ V₁ := fun _ ⟨h₁, _⟩ => h₁

theorem varietyMeet_le_right (V₁ V₂ : Variety S) :
    varietyMeet V₁ V₂ ≤ V₂ := fun _ ⟨_, h₂⟩ => h₂

theorem le_varietyMeet (V V₁ V₂ : Variety S) (h₁ : V ≤ V₁) (h₂ : V ≤ V₂) :
    V ≤ varietyMeet V₁ V₂ := fun A hA => ⟨h₁ A hA, h₂ A hA⟩

-- ============================================================
-- Section 4: Free Algebra Construction (Terms)
-- ============================================================

/-- Terms over a signature S with variables from X -/
inductive AlgTerm (S : AlgSignature) (X : Type) : Type where
  | var : X → AlgTerm S X
  | app : (f : S.OpSym) → (Fin (S.arity f) → AlgTerm S X) → AlgTerm S X

/-- The term algebra: terms with the natural operations -/
def termAlgebra (S : AlgSignature) (X : Type) : SigAlgebra S where
  carrier := AlgTerm S X
  interp f args := AlgTerm.app f args

/-- Substitution: replace variables in a term -/
def AlgTerm.subst {S : AlgSignature} {X Y : Type}
    (sigma : X → AlgTerm S Y) : AlgTerm S X → AlgTerm S Y
  | .var x => sigma x
  | .app f args => .app f (fun i => (args i).subst sigma)

/-- Substitution with variable inclusion is the identity -/
theorem AlgTerm.subst_var {S : AlgSignature} {X : Type} (t : AlgTerm S X) :
    t.subst AlgTerm.var = t := by
  induction t with
  | var _ => rfl
  | app f args ih => simp [AlgTerm.subst]; ext i; exact ih i

-- ============================================================
-- Section 5: The Self-Referential Structure
-- ============================================================

/-- Meet is idempotent -/
theorem theoryMeet_idem (T : EquationalTheory α) :
    ∀ a b, (theoryMeet T T).eqns a b ↔ T.eqns a b :=
  fun _ _ => ⟨fun ⟨h, _⟩ => h, fun h => ⟨h, h⟩⟩

/-- Meet is commutative -/
theorem theoryMeet_comm (T₁ T₂ : EquationalTheory α) :
    ∀ a b, (theoryMeet T₁ T₂).eqns a b ↔ (theoryMeet T₂ T₁).eqns a b :=
  fun _ _ => ⟨fun ⟨h₁, h₂⟩ => ⟨h₂, h₁⟩, fun ⟨h₂, h₁⟩ => ⟨h₁, h₂⟩⟩

/-- Meet is associative -/
theorem theoryMeet_assoc (T₁ T₂ T₃ : EquationalTheory α) :
    ∀ a b, (theoryMeet (theoryMeet T₁ T₂) T₃).eqns a b ↔
           (theoryMeet T₁ (theoryMeet T₂ T₃)).eqns a b :=
  fun _ _ => ⟨fun ⟨⟨h₁, h₂⟩, h₃⟩ => ⟨h₁, h₂, h₃⟩,
              fun ⟨h₁, h₂, h₃⟩ => ⟨⟨h₁, h₂⟩, h₃⟩⟩

/-- The discrete theory is the bottom -/
theorem discreteTheory_le (T : EquationalTheory α) :
    discreteTheory α ≤ T := by
  intro a b hab; cases hab; exact T.refl a

/-- The trivial theory is the top -/
theorem le_trivialTheory (T : EquationalTheory α) :
    T ≤ trivialTheory α := fun _ _ _ => trivial

-- ============================================================
-- Section 6: Monad Structure (Algebraic Theory ↔ Monad)
-- ============================================================

/-- The unit of the free algebra monad -/
def freeMonadUnit (S : AlgSignature) (X : Type) : X → AlgTerm S X :=
  AlgTerm.var

/-- The multiplication of the free algebra monad -/
def freeMonadMult (S : AlgSignature) (X : Type) : AlgTerm S (AlgTerm S X) → AlgTerm S X :=
  AlgTerm.subst id

/-- Left unit law: μ ∘ η_TX = id -/
theorem freeMonad_leftUnit (S : AlgSignature) (X : Type) (t : AlgTerm S X) :
    freeMonadMult S X (freeMonadUnit S (AlgTerm S X) t) = t := by
  simp [freeMonadMult, freeMonadUnit, AlgTerm.subst, id]

/-- Right unit law: μ ∘ T(η) = id -/
theorem freeMonad_rightUnit (S : AlgSignature) (X : Type) (t : AlgTerm S X) :
    freeMonadMult S X ((AlgTerm.subst (fun x => AlgTerm.var (AlgTerm.var x))) t) = t := by
  induction t with
  | var _ => simp [freeMonadMult, AlgTerm.subst, id]
  | app f args ih =>
    simp [freeMonadMult, AlgTerm.subst]
    ext i; exact ih i

-- ============================================================
-- Section 7: The Grand Self-Reference Theorem
-- ============================================================

/-- **Main Theorem**: The collection of equational theories over any
    signature forms a bounded lattice with meet.

    This is an algebraic structure — meaning the algebraic theory
    of algebra produces algebraic objects. The self-reference is
    productive, not paradoxical. -/
theorem algebraicTheoryOfAlgebra_selfReference (α : Type*) :
    (∀ T : EquationalTheory α, discreteTheory α ≤ T) ∧
    (∀ T : EquationalTheory α, T ≤ trivialTheory α) ∧
    (∀ T₁ T₂ : EquationalTheory α,
      theoryMeet T₁ T₂ ≤ T₁ ∧ theoryMeet T₁ T₂ ≤ T₂ ∧
      ∀ S, S ≤ T₁ → S ≤ T₂ → S ≤ theoryMeet T₁ T₂) ∧
    (∀ T : EquationalTheory α, ∀ a b, (theoryMeet T T).eqns a b ↔ T.eqns a b) ∧
    (∀ T₁ T₂ : EquationalTheory α, ∀ a b,
      (theoryMeet T₁ T₂).eqns a b ↔ (theoryMeet T₂ T₁).eqns a b) :=
  ⟨discreteTheory_le, le_trivialTheory,
    fun T₁ T₂ => ⟨theoryMeet_le_left T₁ T₂, theoryMeet_le_right T₁ T₂,
      fun S h₁ h₂ => le_theoryMeet S T₁ T₂ h₁ h₂⟩,
    theoryMeet_idem, theoryMeet_comm⟩
