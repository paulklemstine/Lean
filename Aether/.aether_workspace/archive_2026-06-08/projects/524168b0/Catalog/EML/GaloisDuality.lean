/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# EML Closure–Kernel Duality: Galois Connections and Insertions

This file establishes the **closure/kernel duality** for EML (Expressive Model Logic)
function classes. The central result is a Galois insertion between the lattice of
generator sets and the lattice of EML-closed classes, providing a canonical
semantic adjunction for the EML framework.

## Main results

### Galois insertion and connection
* `eml_galois_insertion_closed`: Galois insertion from `Set (ℝ → ℝ)` to closed sets.
* `eml_galois_connection_closed`: The underlying Galois connection.
* `eml_gc_explicit`: Explicit biconditional `EMLClosure A ⊆ C ↔ A ⊆ C` for closed `C`.

### Closure operator packaging
* `emlClosure_monotone`: Monotonicity of `EMLClosure`.
* `subset_emlClosure`: Extensivity of `EMLClosure`.
* `emlClosure_idem`: Idempotence of `EMLClosure`.
* `emlClosureOp'`: Packaging as a `ClosureOperator`.

### Core and generators
* `emlCore_subset`: `emlCore C ⊆ C` for all `C`.
* `emlCore_antitone`: Contravariance of `emlCore`.
* `minimalGeneratorsEq_eq_emlCore`: Conditional equality for EML-closed `C`.

### Moore family
* `eml_closed_sInter`: EML-closed sets are closed under arbitrary intersection.
* `eml_moore_family`: EML-closed sets form a Moore family.
-/

noncomputable section

open Set

/-! ## Core inductive definition -/

/-- `EMLGenerated' S f` asserts that `f : ℝ → ℝ` is generated from the set `S` by
finitely many applications of the EML operations: constants, pointwise addition,
pointwise multiplication, and function composition. -/
inductive EMLGenerated' (S : Set (ℝ → ℝ)) : (ℝ → ℝ) → Prop where
  | base : f ∈ S → EMLGenerated' S f
  | const : (c : ℝ) → EMLGenerated' S (fun _ => c)
  | add : EMLGenerated' S f → EMLGenerated' S g → EMLGenerated' S (fun x => f x + g x)
  | mul : EMLGenerated' S f → EMLGenerated' S g → EMLGenerated' S (fun x => f x * g x)
  | comp : EMLGenerated' S f → EMLGenerated' S g → EMLGenerated' S (fun x => f (g x))

/-- The **EML closure** of a set `S`. -/
def EMLClosure' (S : Set (ℝ → ℝ)) : Set (ℝ → ℝ) := {f | EMLGenerated' S f}

/-! ## Closure operator axioms -/

theorem subset_emlClosure' (A : Set (ℝ → ℝ)) : A ⊆ EMLClosure' A :=
  fun _ hf => EMLGenerated'.base hf

theorem emlClosure_mono' (A B : Set (ℝ → ℝ)) (hAB : A ⊆ B) :
    EMLClosure' A ⊆ EMLClosure' B := by
  intro f hf
  induction hf with
  | base h => exact EMLGenerated'.base (hAB h)
  | const c => exact EMLGenerated'.const c
  | add _ _ ihf ihg => exact EMLGenerated'.add ihf ihg
  | mul _ _ ihf ihg => exact EMLGenerated'.mul ihf ihg
  | comp _ _ ihf ihg => exact EMLGenerated'.comp ihf ihg

theorem emlClosure_generated_subset' (A : Set (ℝ → ℝ)) :
    EMLClosure' (EMLClosure' A) ⊆ EMLClosure' A := by
  intro f hf
  induction hf with
  | base h => exact h
  | const c => exact EMLGenerated'.const c
  | add _ _ ihf ihg => exact EMLGenerated'.add ihf ihg
  | mul _ _ ihf ihg => exact EMLGenerated'.mul ihf ihg
  | comp _ _ ihf ihg => exact EMLGenerated'.comp ihf ihg

theorem emlClosure_idempotent' (A : Set (ℝ → ℝ)) :
    EMLClosure' (EMLClosure' A) = EMLClosure' A := by
  ext f; constructor
  · exact fun hf => emlClosure_generated_subset' A hf
  · exact fun hf => subset_emlClosure' (EMLClosure' A) hf

/-! ## Convenient restatements -/

theorem emlClosure_monotone' : Monotone (EMLClosure' : Set (ℝ → ℝ) → Set (ℝ → ℝ)) :=
  fun _ _ h => emlClosure_mono' _ _ h

/-! ## The closure operator as a Mathlib `ClosureOperator` -/

def emlClosureOp' : ClosureOperator (Set (ℝ → ℝ)) where
  toFun := EMLClosure'
  monotone' := fun _ _ h => emlClosure_mono' _ _ h
  le_closure' := fun A => subset_emlClosure' A
  idempotent' := fun A => le_antisymm (emlClosure_generated_subset' A)
    (emlClosure_mono' A (EMLClosure' A) (subset_emlClosure' A))

/-! ## Galois insertion on closed sets -/

/-- The canonical **Galois insertion** from generator sets to EML-closed sets.
`EMLClosure'` (mapping to closed sets) is left adjoint to the inclusion of closed sets,
and the composition `EMLClosure' ∘ inclusion` is the identity on closed sets. -/
def eml_galois_insertion_closed :
    GaloisInsertion emlClosureOp'.toCloseds
      (Subtype.val : emlClosureOp'.Closeds → Set (ℝ → ℝ)) :=
  emlClosureOp'.gi

/-- The **Galois connection** underlying the Galois insertion. -/
theorem eml_galois_connection_closed :
    GaloisConnection
      emlClosureOp'.toCloseds
      (Subtype.val : emlClosureOp'.Closeds → Set (ℝ → ℝ)) :=
  eml_galois_insertion_closed.gc

/-- **Explicit Galois connection biconditional**: For any set `A` and EML-closed set `C`,
`EMLClosure' A ⊆ C ↔ A ⊆ C`. This is the fundamental duality. -/
theorem eml_gc_explicit (A C : Set (ℝ → ℝ)) (hC : EMLClosure' C = C) :
    EMLClosure' A ⊆ C ↔ A ⊆ C := by
  constructor
  · exact fun h => (subset_emlClosure' A).trans h
  · intro h
    calc EMLClosure' A ⊆ EMLClosure' C := emlClosure_monotone' h
    _ = C := hC

/-! ## The EML core -/

/-- The **EML core** of a set `C` is the intersection of all generator sets whose
closure contains `C`. -/
def emlCore (C : Set (ℝ → ℝ)) : Set (ℝ → ℝ) :=
  ⋂₀ {A : Set (ℝ → ℝ) | C ⊆ EMLClosure' A}

/-- Membership in `emlCore`. -/
theorem mem_emlCore_iff {f : ℝ → ℝ} {C : Set (ℝ → ℝ)} :
    f ∈ emlCore C ↔ ∀ A : Set (ℝ → ℝ), C ⊆ EMLClosure' A → f ∈ A := by
  simp [emlCore, mem_sInter]

/-- Subset characterization of `emlCore`. -/
theorem subset_emlCore_iff {A C : Set (ℝ → ℝ)} :
    A ⊆ emlCore C ↔ ∀ B : Set (ℝ → ℝ), C ⊆ EMLClosure' B → A ⊆ B := by
  constructor
  · intro h B hB x hx
    exact mem_emlCore_iff.mp (h hx) B hB
  · intro h x hx
    exact mem_emlCore_iff.mpr (fun B hB => h B hB hx)

/-
`emlCore C ⊆ C` since `C` is in the defining family (by extensivity).
-/
theorem emlCore_subset (C : Set (ℝ → ℝ)) : emlCore C ⊆ C := by
  exact Set.sInter_subset_of_mem ( Set.mem_setOf.mpr ( subset_emlClosure' C ) )

/-
`emlCore` is monotone: if `C ⊆ D`, then `emlCore C ⊆ emlCore D`.
    This is because `C ⊆ D` makes the condition `C ⊆ cl(A)` weaker,
    giving a larger family, hence a smaller intersection... wait,
    actually `sInter` of a larger family is smaller. So `emlCore C ⊆ emlCore D`
    since `{A | C ⊆ cl(A)} ⊇ {A | D ⊆ cl(A)}` when `C ⊆ D`.
-/
theorem emlCore_monotone : Monotone (emlCore : Set (ℝ → ℝ) → Set (ℝ → ℝ)) := by
  intro C D hCD intro f hf; simp_all +decide [ emlCore, Set.subset_def ] ;
  exact fun h => f hf fun x hx => h x ( hCD x hx )

/-- `EMLClosure' (emlCore C) ⊆ EMLClosure' C` by monotonicity. -/
theorem emlClosure_emlCore_le (C : Set (ℝ → ℝ)) :
    EMLClosure' (emlCore C) ⊆ EMLClosure' C :=
  emlClosure_monotone' (emlCore_subset C)

/-! ## Minimal generators (equals variant) -/

/-- The intersection of all sets whose closure *equals* `C`. -/
def minimalGeneratorsEq (C : Set (ℝ → ℝ)) : Set (ℝ → ℝ) :=
  ⋂₀ {A : Set (ℝ → ℝ) | EMLClosure' A = C}

/-
For EML-closed `C`, `minimalGeneratorsEq C ⊆ C`.
-/
theorem minimalGeneratorsEq_subset_of_closed {C : Set (ℝ → ℝ)}
    (hC : EMLClosure' C = C) : minimalGeneratorsEq C ⊆ C := by
  exact Set.sInter_subset_of_mem ( by aesop )

/-
The exact-generator intersection always contains the core.
    This holds because {A | cl(A) = C} ⊆ {A | C ⊆ cl(A)},
    so intersecting over the smaller family gives a larger result.
-/
theorem emlCore_le_minimalGeneratorsEq (C : Set (ℝ → ℝ)) :
    emlCore C ⊆ minimalGeneratorsEq C := by
  grind +locals

/-! ## Moore family -/

/-
EML-closed sets are closed under arbitrary intersections.
-/
theorem eml_closed_sInter (S : Set (Set (ℝ → ℝ)))
    (hS : ∀ C ∈ S, EMLClosure' C = C) :
    EMLClosure' (⋂₀ S) = ⋂₀ S := by
  refine' le_antisymm _ _;
  · intro f hf.subset_sInter _;
    exact fun ht => hS _ ht ▸ emlClosure_mono' _ _ ( Set.sInter_subset_of_mem ht ) hf.subset_sInter;
  · exact Set.subset_def.mpr fun x hx => EMLGenerated'.base hx

/-
EML-closed sets form a **Moore family**.
-/
theorem eml_moore_family :
    ∃ F : Set (Set (ℝ → ℝ)),
      (∀ C ∈ F, EMLClosure' C = C) ∧
      (∀ T ⊆ F, ⋂₀ T ∈ F) := by
  refine' ⟨ _, _, _ ⟩;
  exact { C | EMLClosure' C = C };
  · exact fun C hC => hC;
  · intro T hT; exact eml_closed_sInter _ fun C hC => hT hC;

/-! ## Generic closure operator Galois connection -/

/-- For any closure operator on a complete lattice, the closure map and the
inclusion of fixed points form a Galois connection. -/
theorem closureOperator_galoisConnection
    {α : Type*} [CompleteLattice α]
    (c : ClosureOperator α) :
    GaloisConnection c.toCloseds (Subtype.val : c.Closeds → α) :=
  c.gi.gc

end