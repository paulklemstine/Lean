/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Galois Insertion Closure Calculus for EML

This file develops the **structural consequences** of a Galois insertion
between generator sets and EML-closed classes.

The EML closure operator on `Set (ℝ → ℝ)` is defined inductively: starting from
a set of generators, close under constants, pointwise addition, pointwise
multiplication, and function composition. The resulting closure operator gives
rise to a Galois insertion, from which we derive:

1. **Closure operator structure**: extensivity, monotonicity, idempotence.
2. **Fixed-point characterization**: closed sets = fixed points of closure.
3. **Lattice transport**: preservation of joins and meets.
4. **Minimality/universality**: closure is the least closed set above the input.
5. **Cross-domain corollaries**: bound transport, intersection closure, etc.
-/

noncomputable section

open Set

/-! ## Core definitions (self-contained) -/

/-- `EMLGen S f` asserts that `f : ℝ → ℝ` is generated from `S` by finitely many
applications of EML operations: constants, addition, multiplication, composition. -/
inductive EMLGen (S : Set (ℝ → ℝ)) : (ℝ → ℝ) → Prop where
  | base : f ∈ S → EMLGen S f
  | const : (c : ℝ) → EMLGen S (fun _ => c)
  | add : EMLGen S f → EMLGen S g → EMLGen S (fun x => f x + g x)
  | mul : EMLGen S f → EMLGen S g → EMLGen S (fun x => f x * g x)
  | comp : EMLGen S f → EMLGen S g → EMLGen S (fun x => f (g x))

/-- The **EML closure** of a set `S` of real functions. -/
def EMLCl (S : Set (ℝ → ℝ)) : Set (ℝ → ℝ) := {f | EMLGen S f}

/-! ## Closure axioms -/

theorem subset_emlCl (A : Set (ℝ → ℝ)) : A ⊆ EMLCl A :=
  fun _ hf => EMLGen.base hf

theorem emlCl_mono {A B : Set (ℝ → ℝ)} (h : A ⊆ B) : EMLCl A ⊆ EMLCl B := by
  intro f hf
  induction hf with
  | base h' => exact EMLGen.base (h h')
  | const c => exact EMLGen.const c
  | add _ _ ihf ihg => exact EMLGen.add ihf ihg
  | mul _ _ ihf ihg => exact EMLGen.mul ihf ihg
  | comp _ _ ihf ihg => exact EMLGen.comp ihf ihg

theorem emlCl_monotone : Monotone (EMLCl : Set (ℝ → ℝ) → Set (ℝ → ℝ)) :=
  fun _ _ h => emlCl_mono h

theorem emlCl_idem_le (A : Set (ℝ → ℝ)) : EMLCl (EMLCl A) ⊆ EMLCl A := by
  intro f hf
  induction hf with
  | base h => exact h
  | const c => exact EMLGen.const c
  | add _ _ ihf ihg => exact EMLGen.add ihf ihg
  | mul _ _ ihf ihg => exact EMLGen.mul ihf ihg
  | comp _ _ ihf ihg => exact EMLGen.comp ihf ihg

theorem emlCl_idempotent (A : Set (ℝ → ℝ)) : EMLCl (EMLCl A) = EMLCl A :=
  le_antisymm (emlCl_idem_le A) (emlCl_mono (subset_emlCl A))

/-! ## The closure operator -/

/-- The EML closure operator as a Mathlib `ClosureOperator`. -/
def emlClOp : ClosureOperator (Set (ℝ → ℝ)) where
  toFun := EMLCl
  monotone' := fun _ _ h => emlCl_mono h
  le_closure' := subset_emlCl
  idempotent' := fun A => le_antisymm (emlCl_idem_le A) (emlCl_mono (subset_emlCl A))

/-- The Galois insertion from `Set (ℝ → ℝ)` to EML-closed sets. -/
def emlGI : GaloisInsertion emlClOp.toCloseds
    (Subtype.val : emlClOp.Closeds → Set (ℝ → ℝ)) :=
  emlClOp.gi

/-- The underlying Galois connection. -/
def emlGC : GaloisConnection emlClOp.toCloseds
    (Subtype.val : emlClOp.Closeds → Set (ℝ → ℝ)) :=
  emlGI.gc

/-! ## Complete lattice on closed sets -/

/-- The type of EML-closed sets forms a complete lattice via the Galois insertion. -/
noncomputable instance emlCloseds_completeLattice :
    CompleteLattice emlClOp.Closeds :=
  emlGI.liftCompleteLattice

/-! ## Section 1: Closure operator structure (Theorem 1) -/

/-- **Extensivity**: every set is contained in its EML closure. -/
theorem eml_closed_closure_extensive (A : Set (ℝ → ℝ)) :
    A ⊆ EMLCl A :=
  emlClOp.le_closure A

/-- **Monotonicity**: EML closure preserves the subset relation. -/
theorem eml_closed_closure_monotone :
    Monotone (EMLCl : Set (ℝ → ℝ) → Set (ℝ → ℝ)) :=
  emlClOp.monotone

/-- **Idempotence**: closing an already-closed set does nothing. -/
theorem eml_closed_closure_idempotent (A : Set (ℝ → ℝ)) :
    EMLCl (EMLCl A) = EMLCl A :=
  emlClOp.idempotent A

/-- **Closure operator triple**: extensivity ∧ monotonicity ∧ idempotence. -/
theorem eml_closed_closure_operator_triple :
    (∀ A : Set (ℝ → ℝ), A ⊆ EMLCl A) ∧
    Monotone (EMLCl : Set (ℝ → ℝ) → Set (ℝ → ℝ)) ∧
    (∀ A : Set (ℝ → ℝ), EMLCl (EMLCl A) = EMLCl A) :=
  ⟨eml_closed_closure_extensive, eml_closed_closure_monotone,
   eml_closed_closure_idempotent⟩

/-! ## Section 2: Fixed-point characterization (Theorem 2) -/

/-- A set is EML-closed iff it is a fixed point of `EMLCl`. -/
theorem eml_isClosed_iff_fixed (A : Set (ℝ → ℝ)) :
    emlClOp.IsClosed A ↔ EMLCl A = A :=
  emlClOp.isClosed_iff

/-
The range of the upper adjoint (inclusion of closed sets) consists exactly
of the fixed points of the closure.
-/
theorem eml_mem_range_u_iff_fixed (A : Set (ℝ → ℝ)) :
    A ∈ Set.range (Subtype.val : emlClOp.Closeds → Set (ℝ → ℝ)) ↔
    EMLCl A = A := by
  constructor <;> intro h;
  · obtain ⟨ B, rfl ⟩ := h;
    exact B.2;
  · exact ⟨ ⟨ A, h ⟩, rfl ⟩

/-! ## Section 3: Lattice transport (Theorem 3) -/

/-- The lower adjoint preserves binary suprema. -/
theorem eml_lower_adjoint_preserves_sup (A B : Set (ℝ → ℝ)) :
    emlClOp.toCloseds (A ⊔ B) =
    emlClOp.toCloseds A ⊔ emlClOp.toCloseds B :=
  emlGC.l_sup

/-- The upper adjoint preserves binary infima. -/
theorem eml_upper_adjoint_preserves_inf (X Y : emlClOp.Closeds) :
    (X ⊓ Y : emlClOp.Closeds).val = X.val ⊓ Y.val :=
  emlGC.u_inf

/-
The lower adjoint preserves arbitrary suprema.
-/
theorem eml_lower_adjoint_preserves_sSup (S : Set (Set (ℝ → ℝ))) :
    emlClOp.toCloseds (sSup S) =
    sSup (emlClOp.toCloseds '' S) := by
  have := @emlGC.l_sSup;
  grind +suggestions

/-
The upper adjoint preserves arbitrary infima.
-/
theorem eml_upper_adjoint_preserves_sInf (T : Set emlClOp.Closeds) :
    (sInf T : emlClOp.Closeds).val = sInf (Subtype.val '' T) := by
  grind

/-! ## Section 4: Minimality and universality (Theorem 4) -/

/-- `EMLCl A` is below any closed set containing `A`. -/
theorem eml_closure_minimal (A C : Set (ℝ → ℝ))
    (hAC : A ⊆ C) (hC : EMLCl C = C) :
    EMLCl A ⊆ C := by
  calc EMLCl A ⊆ EMLCl C := emlCl_monotone hAC
  _ = C := hC

/-- Biconditional: `A ⊆ C ↔ EMLCl A ⊆ C` for closed `C`. -/
theorem eml_closure_least_closed (A C : Set (ℝ → ℝ))
    (hC : EMLCl C = C) :
    A ⊆ C ↔ EMLCl A ⊆ C := by
  constructor
  · exact fun h => eml_closure_minimal A C h hC
  · exact fun h => (subset_emlCl A).trans h

/-
`EMLCl A` is the infimum of all closed sets containing `A`.
-/
theorem eml_closure_is_least_closed_above (A : Set (ℝ → ℝ)) :
    EMLCl A = sInf {C : Set (ℝ → ℝ) | A ⊆ C ∧ EMLCl C = C} := by
  -- By definition of infimum, we know that $EMLCl A \subseteq C$ for any $C$ such that $A \subseteq C$ and $EMLCl C = C$.
  apply le_antisymm;
  · exact Set.subset_sInter fun C hC => eml_closure_minimal A C hC.1 hC.2;
  · exact sInf_le ⟨ subset_emlCl A, eml_closed_closure_idempotent A ⟩

/-! ## Section 5: Cross-domain corollaries -/

/-- **Semantic bound transport**: if `A ⊆ C` and `C` is closed, then
`EMLCl A ⊆ C`. -/
theorem eml_closure_preserves_subset_bound (A C : Set (ℝ → ℝ))
    (hAC : A ⊆ C) (hC : EMLCl C = C) :
    EMLCl A ⊆ C :=
  eml_closure_minimal A C hAC hC

/-
Fixed points are closed under intersection.
-/
theorem eml_fixedPoint_inter_closed (A B : Set (ℝ → ℝ))
    (hA : EMLCl A = A) (hB : EMLCl B = B) :
    EMLCl (A ∩ B) = A ∩ B := by
  apply Set.eq_of_subset_of_subset _;
  · exact subset_emlCl (A ∩ B)
  · exact Set.subset_inter ( eml_closure_minimal _ _ Set.inter_subset_left hA ) ( eml_closure_minimal _ _ Set.inter_subset_right hB )

/-- The `le_closure_iff` principle: `A ⊆ EMLCl B ↔ EMLCl A ⊆ EMLCl B`. -/
theorem eml_le_closure_iff (A B : Set (ℝ → ℝ)) :
    A ⊆ EMLCl B ↔ EMLCl A ⊆ EMLCl B :=
  emlClOp.le_closure_iff

/-
Closure distributes over union up to re-closure.
-/
theorem eml_closure_union (A B : Set (ℝ → ℝ)) :
    EMLCl (A ∪ B) = EMLCl (EMLCl A ∪ EMLCl B) := by
  refine' le_antisymm _ _;
  · exact emlCl_mono ( Set.union_subset_union ( subset_emlCl _ ) ( subset_emlCl _ ) );
  · -- Since $EMLCl A \cup EMLCl B \subseteq EMLCl (A \cup B)$, we have $EMLCl (EMLCl A \cup EMLCl B) \subseteq EMLCl (EMLCl (A \cup B))$.
    have h_subset : EMLCl A ∪ EMLCl B ⊆ EMLCl (A ∪ B) := by
      exact Set.union_subset ( emlCl_mono <| Set.subset_union_left ) ( emlCl_mono <| Set.subset_union_right );
    exact le_trans ( emlCl_mono h_subset ) ( by rw [ eml_closed_closure_idempotent ] )

/-
The closure of the empty set consists exactly of the constant functions.
This is a concrete structural result specific to EML.
-/
theorem eml_closure_empty :
    EMLCl ∅ = {f : ℝ → ℝ | ∃ c : ℝ, f = fun _ => c} := by
  apply Set.eq_of_subset_of_subset;
  · intro f hf;
    induction hf;
    · contradiction;
    · exact ⟨ _, rfl ⟩;
    · aesop;
    · aesop;
    · aesop;
  · rintro f ⟨ c, rfl ⟩ ; exact EMLGen.const c;

/-
EML-closed sets are closed under arbitrary intersection.
-/
theorem eml_closed_sInter (S : Set (Set (ℝ → ℝ)))
    (hS : ∀ C ∈ S, EMLCl C = C) (_hne : S.Nonempty) :
    EMLCl (⋂₀ S) = ⋂₀ S := by
  apply Set.eq_of_subset_of_subset;
  · exact fun f hf => Set.mem_sInter.2 fun C hC => hS C hC ▸ emlCl_mono ( Set.sInter_subset_of_mem hC ) hf;
  · exact Set.subset_def.mpr fun x hx => EMLGen.base hx

end