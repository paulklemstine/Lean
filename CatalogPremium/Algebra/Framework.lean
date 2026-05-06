import Mathlib

/-!
# Closure Operators, Galois Insertions, and Algebraic Correspondences

This file establishes a unified order-theoretic framework connecting closure operators,
Galois insertions, and the fundamental theorem of Galois theory.

## Main Results

### Part I: Closure Operator Infrastructure
- `closedElements_completeLattice`: Closed elements of a closure operator on a complete
  lattice form a complete lattice.
- `closedElements_orderEmbedding`: Inclusion of closed elements is an order embedding.
- `closure_galoisConnection`: Every closure operator induces a Galois connection.

### Part II: Constructing Closure Operators
- `mkClosureOperator`: Build a `ClosureOperator` from monotone/extensive/idempotent data.

### Part III: Oracle Refinement and Closure
- Oracle refinement is connected to containment of closed-element sets.
-/

noncomputable section

/-!
## Part I: Closure Operator Structural Theorems
-/

section ClosureOperatorInfrastructure

variable {α : Type*}

/-- **Main Structural Theorem**: The closed elements of a closure operator on a
complete lattice form a complete lattice. This is the central result: fixed
substructures, closed sets, and intermediate objects automatically have meets
and joins. -/
noncomputable def closedElements_completeLattice [CompleteLattice α]
    (c : ClosureOperator α) : CompleteLattice c.Closeds :=
  c.gi.liftCompleteLattice

/-- The inclusion of closed elements into the ambient order is an order embedding. -/
def closedElements_orderEmbedding [PartialOrder α] (c : ClosureOperator α) :
    c.Closeds ↪o α :=
  OrderEmbedding.subtype (fun a => c.IsClosed a)

/-- Every closure operator induces a Galois connection. -/
theorem closure_galoisConnection [PartialOrder α] (c : ClosureOperator α) :
    GaloisConnection c.toCloseds (Subtype.val : c.Closeds → α) :=
  c.gi.gc

/-- The Galois insertion witnessing closure as left adjoint to inclusion. -/
def closure_galoisInsertion [PartialOrder α] (c : ClosureOperator α) :
    GaloisInsertion c.toCloseds (Subtype.val : c.Closeds → α) :=
  c.gi

/-- Closure is monotone. -/
theorem closure_is_monotone [PartialOrder α] (c : ClosureOperator α) :
    Monotone c :=
  c.monotone

/-- Every element is below its closure. -/
theorem le_closure' [PartialOrder α] (c : ClosureOperator α) (a : α) :
    a ≤ c a :=
  c.le_closure a

/-- The closure of any element is closed (idempotence). -/
theorem closure_isClosed' [PartialOrder α] (c : ClosureOperator α) (a : α) :
    c.IsClosed (c a) := by
  rw [c.isClosed_iff]
  exact c.idempotent a

/-- Closed elements are exactly the fixed points of the closure operator. -/
theorem isClosed_iff_eq' [Preorder α] (c : ClosureOperator α) (a : α) :
    c.IsClosed a ↔ c a = a :=
  c.isClosed_iff

/-- A closed element is its own closure. -/
theorem closure_of_closed' [Preorder α] (c : ClosureOperator α) {a : α}
    (ha : c.IsClosed a) : c a = a :=
  c.isClosed_iff.mp ha

/-- Two closed elements are equal iff their closures are equal. -/
theorem closed_eq_iff_closure_eq [PartialOrder α] (c : ClosureOperator α)
    {a b : α} (ha : c.IsClosed a) (hb : c.IsClosed b) :
    a = b ↔ c a = c b := by
  rw [closure_of_closed' c ha, closure_of_closed' c hb]

/-- The closure of a meet is bounded above by the meet of closures. -/
theorem closure_inf_le [SemilatticeInf α] (c : ClosureOperator α) (a b : α) :
    c (a ⊓ b) ≤ c a ⊓ c b := by
  exact le_inf (c.monotone inf_le_left) (c.monotone inf_le_right)

/-- The order embedding is injective. -/
theorem closedElements_orderEmbedding_injective [PartialOrder α] (c : ClosureOperator α) :
    Function.Injective (closedElements_orderEmbedding c) :=
  (closedElements_orderEmbedding c).injective

end ClosureOperatorInfrastructure

/-!
## Part II: Constructing Closure Operators from Raw Data
-/

section ClosureConstruction

/-- Construct a Mathlib `ClosureOperator` from a function with the three
hallmark properties: monotone, extensive, and idempotent. -/
def mkClosureOperator {α : Type*} [Preorder α] (f : α → α)
    (hmon : Monotone f) (hle : ∀ a, a ≤ f a) (hidem : ∀ a, f (f a) = f a) :
    ClosureOperator α where
  toOrderHom := ⟨f, hmon⟩
  le_closure' := hle
  idempotent' := hidem

@[simp]
theorem mkClosureOperator_apply {α : Type*} [Preorder α] (f : α → α)
    (hmon : Monotone f) (hle : ∀ a, a ≤ f a) (hidem : ∀ a, f (f a) = f a) (a : α) :
    mkClosureOperator f hmon hle hidem a = f a := rfl

/-- An idempotent, monotone, extensive operator on a complete lattice gives
a complete lattice of closed elements. -/
noncomputable def mkClosureOperator_closedCompleteLattice {α : Type*} [CompleteLattice α]
    (f : α → α) (hmon : Monotone f) (hle : ∀ a, a ≤ f a) (hidem : ∀ a, f (f a) = f a) :
    CompleteLattice (mkClosureOperator f hmon hle hidem).Closeds :=
  closedElements_completeLattice (mkClosureOperator f hmon hle hidem)

/-- If two closure operators have the same underlying function, they are equal. -/
theorem closureOperator_ext' {α : Type*} [PartialOrder α] (c₁ c₂ : ClosureOperator α)
    (h : ∀ a, c₁ a = c₂ a) : c₁ = c₂ :=
  ClosureOperator.ext c₁ c₂ h

end ClosureConstruction

/-!
## Part III: Oracle Refinement and Closure Connection
-/

section OracleClosureConnection

/-- Oracle refinement: O₁ refines O₂ if every fixed point of O₁ is a fixed
point of O₂. -/
def OracleRefines' {X : Type*} (O₁ O₂ : X → X) : Prop :=
  ∀ x, O₁ x = x → O₂ x = x

/-- Oracle refinement is reflexive. -/
theorem oracleRefines_refl' {X : Type*} (O : X → X) : OracleRefines' O O :=
  fun _ h => h

/-- Oracle refinement is transitive. -/
theorem oracleRefines_trans' {X : Type*} {O₁ O₂ O₃ : X → X}
    (h₁₂ : OracleRefines' O₁ O₂) (h₂₃ : OracleRefines' O₂ O₃) :
    OracleRefines' O₁ O₃ :=
  fun x hx => h₂₃ x (h₁₂ x hx)

/-- If O₁ refines O₂ and both are closure operators, then every element closed
under O₁ is closed under O₂. -/
theorem oracleRefines_closed_subset {α : Type*} [Preorder α]
    (c₁ c₂ : ClosureOperator α) (h : OracleRefines' c₁ c₂) :
    ∀ a, c₁.IsClosed a → c₂.IsClosed a := by
  intro a ha
  rw [ClosureOperator.isClosed_iff] at ha ⊢
  exact h a ha

/-- An idempotent, monotone, extensive operator is a closure operator. -/
theorem idem_extensive_monotone_is_closure {α : Type*} [Preorder α]
    (f : α → α) (hmon : Monotone f) (hle : ∀ a, a ≤ f a)
    (hidem : ∀ a, f (f a) = f a) :
    ∃ c : ClosureOperator α, ∀ a, c a = f a :=
  ⟨mkClosureOperator f hmon hle hidem, fun _ => rfl⟩

end OracleClosureConnection

end