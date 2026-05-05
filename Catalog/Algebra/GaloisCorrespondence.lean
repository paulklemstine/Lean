import Mathlib
import Algebra.ClosureGalois.Framework

/-!
# Galois Correspondence as Closure Operator and Order Isomorphism

This file formalizes the deep connection between the Galois correspondence of field theory
and the abstract closure operator framework. We prove:

1. The round-trip `fixedField ∘ fixingSubgroup` is a closure operator on intermediate fields
   (without any Galois hypothesis — this is a universal property).
2. For Galois extensions, every intermediate field is closed (the closure is the identity).
3. The Galois correspondence transports lattice operations: top ↔ bottom, meets ↔ joins.

## Main Results

- `galoisClosureOperator`: The Galois closure on intermediate fields.
- `isGalois_all_closed`: Every intermediate field of a Galois extension is Galois-closed.
- `galois_top_eq_bot`, `galois_bot_eq_top`: Top/bottom transport.
- `galois_inf_corresponds_sup`, `galois_sup_corresponds_inf`: Meet/join transport.

## Key Insight

The Galois correspondence is not an ad hoc bijection: it arises from the universal
closure operator `fixedField ∘ fixingSubgroup`, whose closed elements are the
"Galois-closed" intermediate fields. For finite Galois extensions, every intermediate
field is closed, making the closure operator trivial (the identity) and yielding the
classical bijection.
-/

noncomputable section

open IsGalois OrderDual

/-!
## Part I: The Galois Closure Operator
-/

section GaloisClosure

variable {F E : Type*} [Field F] [Field E] [Algebra F E]

/-- The Galois closure: the round-trip `fixedField ∘ fixingSubgroup` on intermediate fields.
This is always a closure operator, with no Galois hypothesis needed. -/
def galoisClosure : IntermediateField F E → IntermediateField F E :=
  IntermediateField.fixedField ∘ IntermediateField.fixingSubgroup

/-- Every intermediate field is contained in its Galois closure. -/
theorem le_galoisClosure (K : IntermediateField F E) :
    K ≤ galoisClosure K :=
  (IntermediateField.le_iff_le K.fixingSubgroup K).mpr fun ⦃_⦄ a => a

/-- The Galois closure is monotone. -/
theorem galoisClosure_monotone :
    Monotone (galoisClosure : IntermediateField F E → IntermediateField F E) :=
  fun _ _ hKL => IntermediateField.fixedField_le (IntermediateField.fixingSubgroup_le hKL)

/-- The Galois closure is idempotent. This is a universal fact: the composition of
two antitone Galois connections always yields an idempotent closure. -/
theorem galoisClosure_idempotent (K : IntermediateField F E) :
    galoisClosure (galoisClosure K) = galoisClosure K := by
  apply le_antisymm
  · apply IntermediateField.fixedField_le
    exact (IntermediateField.le_iff_le _ _).mp le_rfl
  · exact (IntermediateField.le_iff_le _ _).mpr fun ⦃_⦄ a => a

/-- **The Galois closure operator**: the round-trip `fixedField ∘ fixingSubgroup`
is a closure operator on the lattice of intermediate fields. No Galois hypothesis
is needed — this is a universal property of the adjunction between fields and
automorphism subgroups. -/
def galoisClosureOperator :
    ClosureOperator (IntermediateField F E) :=
  mkClosureOperator galoisClosure galoisClosure_monotone le_galoisClosure galoisClosure_idempotent

@[simp]
theorem galoisClosureOperator_apply (K : IntermediateField F E) :
    galoisClosureOperator K = galoisClosure K := rfl

/-- For a finite Galois extension, every intermediate field is Galois-closed.
This is the content of the fundamental theorem: the closure operator is the
identity, so the Galois correspondence is a bijection. -/
theorem isGalois_all_closed [FiniteDimensional F E] [IsGalois F E]
    (K : IntermediateField F E) :
    galoisClosureOperator.IsClosed K := by
  rw [ClosureOperator.isClosed_iff]
  show galoisClosure K = K
  simp only [galoisClosure, Function.comp]
  exact IsGalois.fixedField_fixingSubgroup K

/-- The closed elements of the Galois closure operator on intermediate fields
of a Galois extension form a complete lattice. -/
noncomputable instance galoisClosedCompleteLattice [FiniteDimensional F E] [IsGalois F E] :
    CompleteLattice (galoisClosureOperator (F := F) (E := E)).Closeds :=
  galoisClosureOperator.gi.liftCompleteLattice

end GaloisClosure

/-!
## Part II: Galois Correspondence Transport Theorems

The Galois correspondence `intermediateFieldEquivSubgroup` is an `OrderIso` from
intermediate fields to the opposite of the subgroup lattice. We derive explicit
transport theorems showing how lattice operations correspond.
-/

section GaloisTransport

variable {F E : Type*} [Field F] [Field E] [Algebra F E]
  [FiniteDimensional F E] [IsGalois F E]

/-- **Fundamental Theorem of Galois Theory** (order-theoretic packaging):
There is an order-reversing isomorphism between intermediate fields and
subgroups of the Galois group. -/
theorem galois_orderIso :
    Nonempty (IntermediateField F E ≃o (Subgroup (E ≃ₐ[F] E))ᵒᵈ) :=
  ⟨intermediateFieldEquivSubgroup⟩

/-- The Galois correspondence sends ⊤ (= E) to ⊥ (= trivial subgroup). -/
theorem galois_top_eq_bot :
    intermediateFieldEquivSubgroup (⊤ : IntermediateField F E) =
      OrderDual.toDual (⊥ : Subgroup (E ≃ₐ[F] E)) :=
  intermediateFieldEquivSubgroup.map_top

/-- The Galois correspondence sends ⊥ (= F) to ⊤ (= full Galois group). -/
theorem galois_bot_eq_top :
    intermediateFieldEquivSubgroup (⊥ : IntermediateField F E) =
      OrderDual.toDual (⊤ : Subgroup (E ≃ₐ[F] E)) :=
  intermediateFieldEquivSubgroup.map_bot

/-- Meets of intermediate fields correspond to joins of subgroups:
E₁ ⊓ E₂ maps to Gal(E/E₁) ⊔ Gal(E/E₂). -/
theorem galois_inf_corresponds_sup (E₁ E₂ : IntermediateField F E) :
    (intermediateFieldEquivSubgroup (E₁ ⊓ E₂)).ofDual =
      (intermediateFieldEquivSubgroup E₁).ofDual ⊔
      (intermediateFieldEquivSubgroup E₂).ofDual := by
  have h := intermediateFieldEquivSubgroup.map_inf E₁ E₂
  rw [h]; rfl

/-- Joins of intermediate fields correspond to meets of subgroups:
E₁ ⊔ E₂ maps to Gal(E/E₁) ⊓ Gal(E/E₂). -/
theorem galois_sup_corresponds_inf (E₁ E₂ : IntermediateField F E) :
    (intermediateFieldEquivSubgroup (E₁ ⊔ E₂)).ofDual =
      (intermediateFieldEquivSubgroup E₁).ofDual ⊓
      (intermediateFieldEquivSubgroup E₂).ofDual := by
  have h := intermediateFieldEquivSubgroup.map_sup E₁ E₂
  rw [h]; rfl

/-- The inverse correspondence: from subgroups back to intermediate fields. -/
theorem galois_inverse_fixedField (H : Subgroup (E ≃ₐ[F] E)) :
    intermediateFieldEquivSubgroup.symm (OrderDual.toDual H) =
      IntermediateField.fixedField H :=
  intermediateFieldEquivSubgroup_symm_apply_toDual H

/-- The round-trip: fixing subgroup then fixed field recovers the original. -/
theorem galois_roundtrip (K : IntermediateField F E) :
    IntermediateField.fixedField K.fixingSubgroup = K :=
  IsGalois.fixedField_fixingSubgroup K

set_option linter.unusedSectionVars false in
/-- The reverse round-trip: fixed field then fixing subgroup recovers the original.
Note: this holds without the `IsGalois` hypothesis. -/
theorem galois_roundtrip_reverse (H : Subgroup (E ≃ₐ[F] E)) :
    (IntermediateField.fixedField H).fixingSubgroup = H :=
  IntermediateField.fixingSubgroup_fixedField H

/-- The Galois correspondence is antitone: larger fields have smaller fixing subgroups. -/
theorem galois_antitone :
    Antitone (fun K : IntermediateField F E =>
      (intermediateFieldEquivSubgroup K).ofDual) :=
  fun _ _ hKL => intermediateFieldEquivSubgroup.monotone hKL

end GaloisTransport

end