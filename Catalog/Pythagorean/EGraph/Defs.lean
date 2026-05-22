import Mathlib

/-!
# E-Graph Extraction as Approximate Quotient Section — Definitions

This file establishes the foundational definitions for formalizing e-graph extraction
as a section of a quotient map, connecting equality saturation to universal algebra
via Galois connections.

## Overview

An e-graph computes a **congruence relation** `~` on a term algebra. Extraction selects
a "best" representative from each equivalence class. The correctness of extraction
reduces to a single lattice-theoretic inclusion: if `~` is *sound* for an equational
theory `E` (meaning `t₁ ~ t₂ → E ⊢ t₁ = t₂`), then extraction preserves evaluation
in every model of `E`.

## Main Definitions

- `EGraph.Sig` — A simple algebraic signature with constants and binary operations
- `EGraph.Term` — Free term algebra over a signature
- `EGraph.Interp` — An interpretation (algebra) for a signature
- `EGraph.Term.eval` — Evaluation of terms in an interpretation
- `SoundCongruence` — A congruence relation with a soundness certificate
- `ExtractionSection` — A section of the quotient map `α → α/~`
- `CostExtractionSection` — An extraction section with cost-optimality
- `CongruenceOf` — The congruence induced by a class of evaluation functions
-/

noncomputable section

open Classical

namespace EGraph

/-! ## Term Algebra -/

/-- A simple signature for a term algebra: a set of constants and binary operations. -/
structure Sig where
  /-- Constants of the signature -/
  const : Type
  /-- Binary operation symbols -/
  binop : Type

/-- The free term algebra over a signature `S`. -/
inductive Term (S : Sig) : Type where
  | const : S.const → Term S
  | binop : S.binop → Term S → Term S → Term S

/-- An interpretation of a signature `S` into a carrier type `α`. -/
structure Interp (S : Sig) (α : Type*) where
  /-- Interpretation of constants -/
  interpConst : S.const → α
  /-- Interpretation of binary operations -/
  interpBinop : S.binop → α → α → α

/-- Evaluate a term in an interpretation. -/
def Term.eval {S : Sig} {α : Type*} (A : Interp S α) : Term S → α
  | .const c => A.interpConst c
  | .binop f t₁ t₂ => A.interpBinop f (t₁.eval A) (t₂.eval A)

/-! ## Term Algebra Size (Cost Function) -/

/-- The size of a term (number of nodes in the AST). -/
def Term.size {S : Sig} : Term S → ℕ
  | .const _ => 1
  | .binop _ t₁ t₂ => 1 + t₁.size + t₂.size

/-- Size is always positive. -/
theorem Term.size_pos {S : Sig} (t : Term S) : 0 < t.size := by
  cases t <;> simp [Term.size]

end EGraph

/-! ## Congruence Relations -/

/-- A **sound congruence** on a type `α` with respect to an evaluation function `eval : α → β`.
    This captures the essential property of an e-graph: related terms evaluate to the same value.

    This is the novel mathematical structure at the core of the formalization:
    it bundles an equivalence relation with a soundness certificate stating that
    the relation is contained in the kernel of the evaluation function. -/
structure SoundCongruence (α β : Type*) where
  /-- The underlying relation -/
  rel : α → α → Prop
  /-- The relation is an equivalence relation -/
  isEquiv : Equivalence rel
  /-- The evaluation function -/
  eval : α → β
  /-- Soundness: related elements evaluate to the same value -/
  sound : ∀ a₁ a₂, rel a₁ a₂ → eval a₁ = eval a₂

/-- The setoid induced by a sound congruence. -/
def SoundCongruence.toSetoid {α β : Type*} (C : SoundCongruence α β) : Setoid α :=
  ⟨C.rel, C.isEquiv⟩

/-! ## Extraction Sections -/

/-- An **extraction section** selects a canonical representative from each equivalence class,
    certified to be a section of the quotient map (i.e., the extracted element is in the
    same equivalence class as the original).

    This is the formal abstraction of e-graph extraction: the `extract` function picks
    one term from each e-class, and `section_prop` certifies that it picks from the
    correct class. -/
structure ExtractionSection (α : Type*) (rel : α → α → Prop) (equiv : Equivalence rel) where
  /-- The extraction function on the quotient -/
  extract : @Quotient α ⟨rel, equiv⟩ → α
  /-- Section property: extraction picks an element from the same class -/
  section_prop : ∀ a : α, rel (extract (@Quotient.mk _ ⟨rel, equiv⟩ a)) a

/-- A **cost-optimal extraction section**: not only picks a representative, but picks
    the cheapest one according to a cost function. This models the optimization aspect
    of e-graph extraction where we seek the smallest/fastest equivalent program. -/
structure CostExtractionSection (α : Type*) (rel : α → α → Prop) (equiv : Equivalence rel) extends
    ExtractionSection α rel equiv where
  /-- Cost function on elements -/
  cost : α → ℕ
  /-- The extracted element has minimal cost in its equivalence class -/
  optimal : ∀ (a : α), cost (extract (@Quotient.mk _ ⟨rel, equiv⟩ a)) ≤ cost a

/-! ## Congruence Induced by Evaluation Functions -/

/-- The congruence on `α` induced by a family of evaluation functions:
    two elements are related iff they evaluate to the same value under every function.
    This is the semantic side of the Galois connection. -/
def CongruenceOf {α : Type*} {ι : Type*} {β : ι → Type*} (fs : ∀ i, α → β i) :
    α → α → Prop :=
  fun a₁ a₂ => ∀ i, fs i a₁ = fs i a₂

theorem congruenceOf_equiv {α : Type*} {ι : Type*} {β : ι → Type*}
    (fs : ∀ i, α → β i) : Equivalence (CongruenceOf fs) where
  refl _ _ := rfl
  symm h i := (h i).symm
  trans h₁ h₂ i := (h₁ i).trans (h₂ i)

/-- The model class of a congruence: the set of evaluation functions that validate it.
    This is the syntactic-to-semantic direction of the Galois connection. -/
def ModelClass {α β : Type*} (rel : α → α → Prop) : Set (α → β) :=
  {f | ∀ a₁ a₂, rel a₁ a₂ → f a₁ = f a₂}

/-! ## Congruence Refinement Order -/

/-- One congruence refines another if it identifies fewer elements.
    `CongruenceRefines rel₁ rel₂` means `rel₁ ⊆ rel₂` (rel₁ is finer). -/
def CongruenceRefines {α : Type*} (rel₁ rel₂ : α → α → Prop) : Prop :=
  ∀ a₁ a₂, rel₁ a₁ a₂ → rel₂ a₁ a₂

theorem congruenceRefines_refl {α : Type*} (rel : α → α → Prop) :
    CongruenceRefines rel rel :=
  fun _ _ h => h

theorem congruenceRefines_trans {α : Type*} {r₁ r₂ r₃ : α → α → Prop}
    (h₁₂ : CongruenceRefines r₁ r₂) (h₂₃ : CongruenceRefines r₂ r₃) :
    CongruenceRefines r₁ r₃ :=
  fun _ _ h => h₂₃ _ _ (h₁₂ _ _ h)

end