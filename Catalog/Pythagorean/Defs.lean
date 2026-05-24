/-
# Coalgebraic Final Semantics for Simply Typed λ-Calculus

## Core Definitions

This file establishes the foundational definitions for a coalgebraic semantics
of simple types: polynomial functors indexed by type structure, finite coalgebras,
coalgebra morphisms, bisimulation, and behavioral equivalence.

The key insight is that each simple type `A` determines a finitary polynomial
endofunctor `F_A` on `Type`, and the semantic universe of terms of type `A`
is captured by the final coalgebra of `F_A` restricted to term-generated systems.

**Application keywords:** coalgebraic semantics, final coalgebra, polynomial functors,
bisimulation minimization, Myhill–Nerode for λ-calculus, finite-state denotational
semantics, categorical automata theory, canonical models, observational equivalence
-/
import Mathlib

universe u

/-! ## Simple Types -/

/-- Simple types for STLC: a base type and arrow types. -/
inductive STLCType : Type
  | base : STLCType
  | arr  : STLCType → STLCType → STLCType
  deriving DecidableEq, Repr

namespace STLCType

/-- The codomain arity of a type: counts the number of arguments
    in a right-nested arrow chain ending at the codomain.
    For `A₁ → A₂ → ⋯ → Aₙ → base`, this returns `n`. -/
def arityOf : STLCType → ℕ
  | .base     => 0
  | .arr _ B  => arityOf B + 1

/-- The size of a type (total number of constructors). -/
def size : STLCType → ℕ
  | .base    => 1
  | .arr A B => size A + size B + 1

/-- Size is always positive. -/
theorem size_pos (A : STLCType) : 0 < size A := by
  cases A with
  | base => simp [size]
  | arr A B => unfold size; omega

/-- The order (depth of arrow nesting on the left) of a simple type. -/
def order : STLCType → ℕ
  | .base    => 0
  | .arr A B => max (order A + 1) (order B)

end STLCType

open STLCType

/-! ## Type Polynomial Functor

The key construction: a simple type `A` induces a polynomial endofunctor
`F_A : Type u → Type u`. The shape is:
- Base type → `Unit ⊕ X⁰ ≅ Unit ⊕ Unit` (terminal or single observation)
- Arrow type `A → B` → `Unit ⊕ X^(arityOf(A→B))` (terminal or branching)

More precisely, `TypePolynomialFunctor A X = Unit ⊕ (Fin (arityOf A) → X)`.
The `Unit` summand represents a terminal/halted state, and the function space
represents the branching transitions available at non-terminal states.
-/

/-- The polynomial functor on `Type u` determined by a simple type `A`.
    States are either terminal (`Sum.inl ()`) or have `arityOf A` successor states. -/
def TypePolynomialFunctor (A : STLCType) (X : Type u) : Type u :=
  Unit ⊕ (Fin (arityOf A) → X)

/-- The functorial action of `TypePolynomialFunctor A` on morphisms. -/
def TypePolynomialFunctor.map {A : STLCType} {X Y : Type u} (f : X → Y) :
    TypePolynomialFunctor A X → TypePolynomialFunctor A Y
  | .inl u => .inl u
  | .inr g => .inr (f ∘ g)

/-- Functoriality: map respects identity. -/
theorem TypePolynomialFunctor.map_id {A : STLCType} {X : Type u} :
    TypePolynomialFunctor.map (A := A) (id : X → X) = id := by
  ext x; cases x <;> rfl

/-- Functoriality: map respects composition. -/
theorem TypePolynomialFunctor.map_comp {A : STLCType} {X Y Z : Type u}
    (f : X → Y) (g : Y → Z) :
    TypePolynomialFunctor.map (A := A) (g ∘ f) =
    TypePolynomialFunctor.map g ∘ TypePolynomialFunctor.map f := by
  ext x; cases x <;> rfl

/-! ## Finite Coalgebras -/

/-- A finite coalgebra for a type-indexed polynomial functor.
    This is the core semantic object: a finite state space
    equipped with a structure map that decomposes each state
    into either terminal or branching behavior. -/
structure FiniteCoalgebra (A : STLCType) where
  /-- The carrier (state space) of the coalgebra. -/
  Carrier : Type u
  /-- The structure map: each state is either terminal or has
      `arityOf A` successors. -/
  str : Carrier → TypePolynomialFunctor A Carrier
  /-- The carrier is finite. -/
  [fin : Finite Carrier]

/-- A coalgebra morphism between finite coalgebras: a function on carriers
    that commutes with the structure maps up to the functorial action. -/
structure CoalgebraHom (A : STLCType) (C D : FiniteCoalgebra A) where
  /-- The underlying function on carriers. -/
  toFun : C.Carrier → D.Carrier
  /-- Commutativity: the structure map commutes with the morphism. -/
  comm : ∀ x, D.str (toFun x) = TypePolynomialFunctor.map toFun (C.str x)

/-- Identity coalgebra morphism. -/
def CoalgebraHom.id (A : STLCType) (C : FiniteCoalgebra A) : CoalgebraHom A C C where
  toFun := _root_.id
  comm := fun x => by
    simp [TypePolynomialFunctor.map]
    cases C.str x with
    | inl u => rfl
    | inr g => rfl

/-- Composition of coalgebra morphisms. -/
def CoalgebraHom.comp {A : STLCType} {C D E : FiniteCoalgebra A}
    (g : CoalgebraHom A D E) (f : CoalgebraHom A C D) : CoalgebraHom A C E where
  toFun := g.toFun ∘ f.toFun
  comm := fun x => by
    simp [Function.comp, g.comm, f.comm, TypePolynomialFunctor.map]
    cases C.str x with
    | inl u => rfl
    | inr h => rfl

/-! ## Bisimulation -/

/-- A bisimulation relation on a finite coalgebra: a relation `R` such that
    related states have matching structure (both terminal or both branching
    with related successors). -/
structure IsBisimulation (A : STLCType) (C : FiniteCoalgebra A)
    (R : C.Carrier → C.Carrier → Prop) : Prop where
  /-- If `R x y` and `x` is terminal, then `y` is terminal. -/
  terminal_left : ∀ x y, R x y → C.str x = .inl () → C.str y = .inl ()
  /-- If `R x y` and `y` is terminal, then `x` is terminal. -/
  terminal_right : ∀ x y, R x y → C.str y = .inl () → C.str x = .inl ()
  /-- If `R x y` and both are branching, their successors are related. -/
  branching : ∀ x y (fx : Fin (arityOf A) → C.Carrier) (fy : Fin (arityOf A) → C.Carrier),
    R x y → C.str x = .inr fx → C.str y = .inr fy →
    ∀ i, R (fx i) (fy i)

/-- Behavioral equivalence: the largest bisimulation on a coalgebra.
    Two states are behaviorally equivalent if there exists some
    bisimulation relating them. -/
def BehavioralEquiv (A : STLCType) (C : FiniteCoalgebra A)
    (x y : C.Carrier) : Prop :=
  ∃ R : C.Carrier → C.Carrier → Prop,
    IsBisimulation A C R ∧ R x y

/-! ## Behavioral Equivalence is an Equivalence Relation -/

/-- Equality is a bisimulation. -/
theorem eq_isBisimulation (A : STLCType) (C : FiniteCoalgebra A) :
    IsBisimulation A C (· = ·) where
  terminal_left := fun _ _ h hx => h ▸ hx
  terminal_right := fun _ _ h hy => h ▸ hy
  branching := fun _ _ fx _ h hx hy i => by subst h; rw [hx] at hy; cases hy; rfl

/-- Behavioral equivalence is reflexive. -/
theorem BehavioralEquiv.refl (A : STLCType) (C : FiniteCoalgebra A)
    (x : C.Carrier) : BehavioralEquiv A C x x :=
  ⟨(· = ·), eq_isBisimulation A C, rfl⟩

/-- The converse relation of a bisimulation is a bisimulation. -/
theorem IsBisimulation.flip {A : STLCType} {C : FiniteCoalgebra A}
    {R : C.Carrier → C.Carrier → Prop} (hR : IsBisimulation A C R) :
    IsBisimulation A C (fun a b => R b a) where
  terminal_left := fun a b hab => hR.terminal_right b a hab
  terminal_right := fun a b hab => hR.terminal_left b a hab
  branching := fun a b fa fb hab ha hb i => hR.branching b a fb fa hab hb ha i

/-- Behavioral equivalence is symmetric. -/
theorem BehavioralEquiv.symm {A : STLCType} {C : FiniteCoalgebra A}
    {x y : C.Carrier} (h : BehavioralEquiv A C x y) :
    BehavioralEquiv A C y x := by
  obtain ⟨R, hR, hxy⟩ := h
  exact ⟨fun a b => R b a, hR.flip, hxy⟩

/-- Behavioral equivalence is transitive. -/
theorem BehavioralEquiv.trans {A : STLCType} {C : FiniteCoalgebra A}
    {x y z : C.Carrier}
    (hxy : BehavioralEquiv A C x y)
    (hyz : BehavioralEquiv A C y z) :
    BehavioralEquiv A C x z := by
  obtain ⟨R₁, hR₁, hr₁⟩ := hxy
  obtain ⟨R₂, hR₂, hr₂⟩ := hyz
  refine ⟨fun a c => ∃ b, R₁ a b ∧ R₂ b c, ?_, ⟨y, hr₁, hr₂⟩⟩
  constructor
  · intro a c ⟨b, hab, hbc⟩ hsa
    exact hR₂.terminal_left b c hbc (hR₁.terminal_left a b hab hsa)
  · intro a c ⟨b, hab, hbc⟩ hsc
    exact hR₁.terminal_right a b hab (hR₂.terminal_right b c hbc hsc)
  · intro a c fa fc ⟨b, hab, hbc⟩ hsa hsc i
    -- b must be branching since a is branching and R₁ a b
    have hsb_not_term : C.str b ≠ .inl () := by
      intro h_term
      have := hR₁.terminal_right a b hab h_term
      rw [this] at hsa; simp at hsa
    obtain ⟨fb, hfb⟩ : ∃ fb : Fin (arityOf A) → C.Carrier, C.str b = .inr fb := by
      cases hsb : C.str b with
      | inl u => exact absurd hsb hsb_not_term
      | inr g => exact ⟨g, rfl⟩
    exact ⟨fb i,
      hR₁.branching a b fa fb hab hsa hfb i,
      hR₂.branching b c fb fc hbc hfb hsc i⟩

/-- The setoid on a finite coalgebra's carrier induced by behavioral equivalence. -/
def behavioralSetoid (A : STLCType) (C : FiniteCoalgebra A) :
    Setoid C.Carrier where
  r := BehavioralEquiv A C
  iseqv := ⟨BehavioralEquiv.refl A C,
            fun h => BehavioralEquiv.symm h,
            fun h1 h2 => BehavioralEquiv.trans h1 h2⟩

/-! ## Observation and Modal Invariance -/

/-- An observation on a coalgebra state: is the state terminal? -/
def isTerminal (A : STLCType) (C : FiniteCoalgebra A) (x : C.Carrier) : Bool :=
  match C.str x with
  | .inl _ => true
  | .inr _ => false

/-- Same observation shape: two states agree on terminality. -/
def sameObservationShape (A : STLCType) (C : FiniteCoalgebra A)
    (x y : C.Carrier) : Prop :=
  isTerminal A C x = isTerminal A C y

/-- **Theorem (Behavioral Equivalence Preserves Observation Shape)**:
    Behaviorally equivalent states have the same observation shape.
    This is a key compatibility theorem needed for quotient descent. -/
theorem behavioral_equiv_preserves_observation
    (A : STLCType) (C : FiniteCoalgebra A)
    {x y : C.Carrier}
    (h : BehavioralEquiv A C x y) :
    sameObservationShape A C x y := by
  obtain ⟨R, hR, hxy⟩ := h
  simp only [sameObservationShape, isTerminal]
  cases hsx : C.str x with
  | inl u =>
    have := hR.terminal_left x y hxy hsx
    rw [this]
  | inr fx =>
    cases hsy : C.str y with
    | inl u =>
      have := hR.terminal_right x y hxy hsy
      rw [this] at hsx; exact absurd hsx (by simp)
    | inr fy => rfl

/-! ## Quotient Construction -/

/-- The quotient type of a coalgebra carrier by behavioral equivalence. -/
def SemanticQuotient (A : STLCType) (C : FiniteCoalgebra A) : Type u :=
  Quotient (behavioralSetoid A C)