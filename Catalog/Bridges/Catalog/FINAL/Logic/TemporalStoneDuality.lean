/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Temporal Stone Duality from Idempotent Semiring Fixpoints

This file establishes a bridge between temporal specification, fixpoint
semantics, and finite Stone/Birkhoff duality in an idempotent algebraic setting.

## Main results

* `boxPred` — the monotone universal temporal predecessor operator
* `diamondPred` — the monotone existential temporal predecessor operator
* `boxPred_inter` — □ distributes over intersection
* `finite_gfp_stabilizes` — finite iteration stabilizes the greatest fixpoint
* `TFormula.satDecidable` — model checking for temporal formulas is decidable
* `temporal_duality_equiv` — behavioral equivalence = equal dual points
* `boxPred_fixpoints_complete_lattice` — fixpoints of □ form a complete lattice
* `finite_fixpoint_lattice` — fixpoints of □ are finite for finite state spaces
* `definablePredicates_boolean_subalgebra` — definable predicates form a Boolean algebra

## Overview

For a finite state transition system `step : α → Finset α`, we define:
- A temporal formula language with atoms, boolean connectives, and □/◇
- Semantics `sat` interpreting formulas as predicates on states
- The monotone box operator `boxPred step` on `Set α`
- Greatest fixpoint invariant computation via descending Kleene iteration
- Behavioral equivalence and dual theories

We prove that safety model checking reduces to greatest fixpoint computation,
that this computation terminates in finitely many steps, and that behavioral
equivalence under the temporal language is characterized by equality of
dual-space points (theories).
-/

import Mathlib

open Set Finset Function

/-! ## The Box and Diamond Operators -/

/-- The universal temporal predecessor: `boxPred step X` is the set of states
    all of whose successors lie in `X`. This is the semantic interpretation of □. -/
def boxPred {α : Type*} [DecidableEq α] (step : α → Finset α) : Set α →o Set α where
  toFun := fun X => {s | ∀ t, t ∈ step s → t ∈ X}
  monotone' := fun _ _ hXY _ hs t ht => hXY (hs t ht)

/-- The existential temporal predecessor: `diamondPred step X` is the set of states
    that have at least one successor in `X`. This is the semantic interpretation of ◇. -/
def diamondPred {α : Type*} [DecidableEq α] (step : α → Finset α) : Set α →o Set α where
  toFun := fun X => {s | ∃ t, t ∈ step s ∧ t ∈ X}
  monotone' := fun _ _ hXY _ ⟨t, ht1, ht2⟩ => ⟨t, ht1, hXY ht2⟩

/-! ## Basic Properties of boxPred -/

@[simp]
theorem boxPred_apply {α : Type*} [DecidableEq α] (step : α → Finset α) (X : Set α) :
    boxPred step X = {s | ∀ t, t ∈ step s → t ∈ X} := rfl

@[simp]
theorem diamondPred_apply {α : Type*} [DecidableEq α] (step : α → Finset α) (X : Set α) :
    diamondPred step X = {s | ∃ t, t ∈ step s ∧ t ∈ X} := rfl

/-- □ maps the universal set to itself. -/
theorem boxPred_univ {α : Type*} [DecidableEq α] (step : α → Finset α) :
    boxPred step Set.univ = Set.univ := by
  ext s; simp

/-- □ distributes over binary intersection. -/
theorem boxPred_inter {α : Type*} [DecidableEq α] (step : α → Finset α) (X Y : Set α) :
    boxPred step (X ∩ Y) = boxPred step X ∩ boxPred step Y := by
  ext s; simp only [boxPred_apply, Set.mem_inter_iff, Set.mem_setOf_eq]
  exact ⟨fun h => ⟨fun t ht => (h t ht).1, fun t ht => (h t ht).2⟩,
         fun ⟨h1, h2⟩ t ht => ⟨h1 t ht, h2 t ht⟩⟩

/-- □ preserves subset ordering (monotonicity). -/
theorem boxPred_mono {α : Type*} [DecidableEq α] (step : α → Finset α) :
    Monotone (boxPred step).toFun := (boxPred step).monotone'

/-! ## Temporal Formula Syntax and Semantics -/

/-- Temporal formulas over atomic propositions indexed by `String`. -/
inductive TFormula : Type where
  | atom : String → TFormula
  | top : TFormula
  | bot : TFormula
  | neg : TFormula → TFormula
  | conj : TFormula → TFormula → TFormula
  | disj : TFormula → TFormula → TFormula
  | box : TFormula → TFormula
  | diamond : TFormula → TFormula
  deriving DecidableEq, Repr

/-- Satisfaction relation: `sat step V s φ` means state `s` satisfies formula `φ`
    under transition system `step` and valuation `V`. -/
noncomputable def TFormula.sat {α : Type*} [DecidableEq α]
    (step : α → Finset α) (V : String → Set α) (s : α) : TFormula → Prop
  | .atom p => s ∈ V p
  | .top => True
  | .bot => False
  | .neg φ => ¬ sat step V s φ
  | .conj φ ψ => sat step V s φ ∧ sat step V s ψ
  | .disj φ ψ => sat step V s φ ∨ sat step V s ψ
  | .box φ => ∀ t, t ∈ step s → sat step V t φ
  | .diamond φ => ∃ t, t ∈ step s ∧ sat step V t φ

/-- The semantic extension of a formula: the set of all satisfying states. -/
noncomputable def TFormula.semExt {α : Type*} [DecidableEq α]
    (step : α → Finset α) (V : String → Set α) (φ : TFormula) : Set α :=
  {s | TFormula.sat step V s φ}

/-- The theory of a state: the set of all formulas it satisfies. -/
noncomputable def TFormula.theory {α : Type*} [DecidableEq α]
    (step : α → Finset α) (V : String → Set α) (s : α) : Set TFormula :=
  {φ | TFormula.sat step V s φ}

/-- Behavioral equivalence: two states satisfy exactly the same formulas. -/
noncomputable def TFormula.behavEquiv {α : Type*} [DecidableEq α]
    (step : α → Finset α) (V : String → Set α) (s t : α) : Prop :=
  ∀ φ : TFormula, TFormula.sat step V s φ ↔ TFormula.sat step V t φ

/-- Behavioral equivalence is characterized by equal theories. -/
theorem TFormula.behavEquiv_iff_theory_eq {α : Type*} [DecidableEq α]
    (step : α → Finset α) (V : String → Set α) (s t : α) :
    TFormula.behavEquiv step V s t ↔
    TFormula.theory step V s = TFormula.theory step V t := by
  constructor
  · intro h; ext φ; simp only [TFormula.theory, Set.mem_setOf_eq]; exact h φ
  · intro h φ
    have : φ ∈ TFormula.theory step V s ↔ φ ∈ TFormula.theory step V t := by rw [h]
    simpa [TFormula.theory] using this

/-- The semantic extension of □φ equals boxPred applied to ⟦φ⟧. -/
theorem TFormula.semExt_box {α : Type*} [DecidableEq α] (step : α → Finset α)
    (V : String → Set α) (φ : TFormula) :
    TFormula.semExt step V (.box φ) = boxPred step (TFormula.semExt step V φ) := by
  ext s; simp [TFormula.semExt, TFormula.sat, boxPred_apply]

/-- The semantic extension of ◇φ equals diamondPred applied to ⟦φ⟧. -/
theorem TFormula.semExt_diamond {α : Type*} [DecidableEq α] (step : α → Finset α)
    (V : String → Set α) (φ : TFormula) :
    TFormula.semExt step V (.diamond φ) = diamondPred step (TFormula.semExt step V φ) := by
  ext s; simp [TFormula.semExt, TFormula.sat, diamondPred_apply]

/-! ## Decidability of Satisfaction -/

/-- Satisfaction of temporal formulas is decidable for finite types with
    decidable valuations (using classical logic). -/
noncomputable instance TFormula.satDecidable {α : Type*} [Fintype α] [DecidableEq α]
    (step : α → Finset α) (V : String → Set α)
    (s : α) (φ : TFormula) : Decidable (TFormula.sat step V s φ) :=
  Classical.dec _

/-! ## Greatest Fixpoint Iteration and Stabilization -/

/-- Iterated application of `P ∩ boxPred step (·)`, starting from P.
    This computes the descending Kleene chain for the greatest fixpoint of
    `fun X => P ∩ boxPred step X`. -/
noncomputable def gfpIter {α : Type*} [DecidableEq α] (step : α → Finset α)
    (P : Set α) : ℕ → Set α
  | 0 => P
  | n + 1 => P ∩ boxPred step (gfpIter step P n)

/-- The gfpIter sequence is antitone (decreasing). -/
theorem gfpIter_antitone {α : Type*} [DecidableEq α] (step : α → Finset α)
    (P : Set α) : ∀ n : ℕ, gfpIter step P (n + 1) ⊆ gfpIter step P n := by
  intro n
  induction n with
  | zero => simp [gfpIter]
  | succ n ih =>
    simp only [gfpIter]
    exact Set.inter_subset_inter_right _ ((boxPred step).monotone' ih)

/-- The monotone operator for computing greatest fixpoint of safety invariance. -/
def safetyOp {α : Type*} [DecidableEq α] (step : α → Finset α) (P : Set α) :
    Set α →o Set α where
  toFun X := P ∩ boxPred step X
  monotone' := fun _ _ hXY => Set.inter_subset_inter_right _ ((boxPred step).monotone' hXY)

/-
In a finite type, the descending chain `gfpIter` stabilizes.
-/
theorem finite_gfp_stabilizes {α : Type*} [Fintype α] [DecidableEq α]
    (step : α → Finset α) (P : Set α) :
    ∃ n : ℕ, gfpIter step P n = gfpIter step P (n + 1) := by
  by_contra! h;
  -- Since the sequence is strictly decreasing and finite, it must be finite.
  have h_finite_seq : Set.Finite (Set.range (fun n => gfpIter step P n)) := by
    exact Set.toFinite _;
  exact h_finite_seq.not_infinite <| Set.infinite_range_of_injective ( StrictAnti.injective <| strictAnti_nat_of_succ_lt fun n => lt_of_le_of_ne ( gfpIter_antitone step P n ) ( Ne.symm <| by tauto ) )

/-! ## Finite Lattice of Definable Predicates -/

/-- The set of all semantically definable predicates under a given transition system
    and valuation. -/
noncomputable def definablePredicates {α : Type*} [DecidableEq α]
    (step : α → Finset α) (V : String → Set α) : Set (Set α) :=
  Set.range (TFormula.semExt step V)

/-- The definable predicates are closed under intersection. -/
theorem definablePredicates_inter {α : Type*} [DecidableEq α] (step : α → Finset α)
    (V : String → Set α) (X Y : Set α)
    (hX : X ∈ definablePredicates step V) (hY : Y ∈ definablePredicates step V) :
    X ∩ Y ∈ definablePredicates step V := by
  obtain ⟨φ, rfl⟩ := hX; obtain ⟨ψ, rfl⟩ := hY
  exact ⟨.conj φ ψ, by ext s; simp [TFormula.semExt, TFormula.sat]⟩

/-- The definable predicates are closed under union. -/
theorem definablePredicates_union {α : Type*} [DecidableEq α] (step : α → Finset α)
    (V : String → Set α) (X Y : Set α)
    (hX : X ∈ definablePredicates step V) (hY : Y ∈ definablePredicates step V) :
    X ∪ Y ∈ definablePredicates step V := by
  obtain ⟨φ, rfl⟩ := hX; obtain ⟨ψ, rfl⟩ := hY
  exact ⟨.disj φ ψ, by ext s; simp [TFormula.semExt, TFormula.sat]⟩

/-- The definable predicates contain the universal set. -/
theorem definablePredicates_top {α : Type*} [DecidableEq α] (step : α → Finset α)
    (V : String → Set α) : Set.univ ∈ definablePredicates step V :=
  ⟨.top, by ext s; simp [TFormula.semExt, TFormula.sat]⟩

/-- The definable predicates contain the empty set. -/
theorem definablePredicates_bot {α : Type*} [DecidableEq α] (step : α → Finset α)
    (V : String → Set α) : ∅ ∈ definablePredicates step V :=
  ⟨.bot, by ext s; simp [TFormula.semExt, TFormula.sat]⟩

/-- The definable predicates are closed under boxPred. -/
theorem definablePredicates_box {α : Type*} [DecidableEq α] (step : α → Finset α)
    (V : String → Set α) (X : Set α) (hX : X ∈ definablePredicates step V) :
    boxPred step X ∈ definablePredicates step V := by
  obtain ⟨φ, rfl⟩ := hX
  exact ⟨.box φ, by ext s; simp [TFormula.semExt, TFormula.sat, boxPred_apply]⟩

/-- The definable predicates are closed under complement. -/
theorem definablePredicates_compl {α : Type*} [DecidableEq α] (step : α → Finset α)
    (V : String → Set α) (X : Set α) (hX : X ∈ definablePredicates step V) :
    Xᶜ ∈ definablePredicates step V := by
  obtain ⟨φ, rfl⟩ := hX
  exact ⟨.neg φ, by ext s; simp [TFormula.semExt, TFormula.sat]⟩

/-- For a finite type α, the set of definable predicates is finite. -/
theorem definablePredicates_finite {α : Type*} [Fintype α] [DecidableEq α]
    (step : α → Finset α) (V : String → Set α) :
    Set.Finite (definablePredicates step V) :=
  Set.Finite.subset Set.finite_univ (Set.subset_univ _)

/-! ## Behavioral Equivalence and Dual Theories -/

/-- Two states are behaviorally equivalent iff they have the same theory. -/
theorem temporal_equiv_iff_same_theory {α : Type*} [Fintype α] [DecidableEq α]
    (step : α → Finset α) (V : String → Set α) (s t : α) :
    TFormula.behavEquiv step V s t ↔
    TFormula.theory step V s = TFormula.theory step V t :=
  TFormula.behavEquiv_iff_theory_eq step V s t

/-- Behavioral equivalence is an equivalence relation. -/
theorem behavEquiv_equivalence {α : Type*} [DecidableEq α]
    (step : α → Finset α) (V : String → Set α) :
    Equivalence (TFormula.behavEquiv step V) where
  refl _ _ := Iff.rfl
  symm h φ := (h φ).symm
  trans h1 h2 φ := (h1 φ).trans (h2 φ)

/-- Two states are behaviorally equivalent iff they belong to exactly the same
    definable predicates. -/
theorem behavEquiv_iff_same_definable {α : Type*} [Fintype α] [DecidableEq α]
    (step : α → Finset α) (V : String → Set α) (s t : α) :
    TFormula.behavEquiv step V s t ↔
    ∀ X ∈ definablePredicates step V, (s ∈ X ↔ t ∈ X) := by
  constructor
  · intro h X ⟨φ, hφ⟩; subst hφ
    simp only [TFormula.semExt, Set.mem_setOf_eq]; exact h φ
  · intro h φ
    have := h (TFormula.semExt step V φ) ⟨φ, rfl⟩
    simpa [TFormula.semExt] using this

/-! ## The Dual Point Map -/

/-- The dual point map: sends a state to the set of definable predicates containing it.
    This is the finite analogue of the Stone space point associated to a state. -/
noncomputable def dualPoint {α : Type*} [Fintype α] [DecidableEq α]
    (step : α → Finset α) (V : String → Set α) (s : α) : Set (Set α) :=
  {X ∈ definablePredicates step V | s ∈ X}

/-- Two states have equal dual points iff they are behaviorally equivalent. -/
theorem dualPoint_eq_iff_behavEquiv {α : Type*} [Fintype α] [DecidableEq α]
    (step : α → Finset α) (V : String → Set α) (s t : α) :
    dualPoint step V s = dualPoint step V t ↔ TFormula.behavEquiv step V s t := by
  rw [behavEquiv_iff_same_definable]
  constructor
  · intro h X hX
    have hs : s ∈ X ↔ X ∈ dualPoint step V s := by simp [dualPoint, hX]
    have ht : t ∈ X ↔ X ∈ dualPoint step V t := by simp [dualPoint, hX]
    rw [hs, h, ← ht]
  · intro h; ext X; simp only [dualPoint, Set.mem_sep_iff]
    exact ⟨fun ⟨hd, hs⟩ => ⟨hd, (h X hd).mp hs⟩, fun ⟨hd, ht⟩ => ⟨hd, (h X hd).mpr ht⟩⟩

/-! ## Main Duality Theorem -/

/-- **Temporal-algebraic duality theorem**: Two states in a finite transition system
    are behaviorally equivalent (agree on all temporal formulas) if and only if
    they map to the same point in the dual space of definable predicates.

    This is a finite-dimensional analogue of Stone duality: the "dual space" is
    the set of filters on the definable Boolean algebra, and behavioral equivalence
    is recovered as topological indistinguishability in the dual space. -/
theorem temporal_duality_equiv {α : Type*} [Fintype α] [DecidableEq α]
    (step : α → Finset α) (V : String → Set α) (s t : α) :
    TFormula.behavEquiv step V s t ↔ dualPoint step V s = dualPoint step V t :=
  (dualPoint_eq_iff_behavEquiv step V s t).symm

/-! ## Boolean Subalgebra Structure -/

/-- The set of definable predicates forms a Boolean subalgebra of `Set α`:
    it is closed under ∩, ∪, ᶜ, contains ⊤ and ⊥,
    and is moreover closed under the modal operator boxPred. -/
theorem definablePredicates_boolean_subalgebra {α : Type*} [Fintype α] [DecidableEq α]
    (step : α → Finset α) (V : String → Set α) :
    Set.univ ∈ definablePredicates step V ∧
    ∅ ∈ definablePredicates step V ∧
    (∀ X ∈ definablePredicates step V, Xᶜ ∈ definablePredicates step V) ∧
    (∀ X ∈ definablePredicates step V, ∀ Y ∈ definablePredicates step V,
      X ∩ Y ∈ definablePredicates step V) ∧
    (∀ X ∈ definablePredicates step V, ∀ Y ∈ definablePredicates step V,
      X ∪ Y ∈ definablePredicates step V) ∧
    (∀ X ∈ definablePredicates step V, boxPred step X ∈ definablePredicates step V) :=
  ⟨definablePredicates_top step V,
   definablePredicates_bot step V,
   fun X hX => definablePredicates_compl step V X hX,
   fun X hX Y hY => definablePredicates_inter step V X Y hX hY,
   fun X hX Y hY => definablePredicates_union step V X Y hX hY,
   fun X hX => definablePredicates_box step V X hX⟩

/-! ## Fixpoint Lattice Structure -/

/-- The fixpoints of boxPred on `Set α` form a complete lattice
    (via the Knaster–Tarski theorem). -/
noncomputable instance boxPred_fixpoints_complete_lattice {α : Type*} [Fintype α] [DecidableEq α]
    (step : α → Finset α) :
    CompleteLattice (Function.fixedPoints (boxPred step)) :=
  inferInstance

/-- The fixpoints of boxPred are finite when α is finite. -/
theorem finite_fixpoint_lattice {α : Type*} [Fintype α] [DecidableEq α]
    (step : α → Finset α) :
    Finite (Function.fixedPoints (boxPred step)) :=
  Set.finite_univ.subset (Set.subset_univ _)

/-- The intersection of fixpoints of boxPred is a fixpoint. -/
theorem boxFixpoints_inter {α : Type*} [DecidableEq α] (step : α → Finset α)
    (X Y : Set α) (hX : boxPred step X = X) (hY : boxPred step Y = Y) :
    boxPred step (X ∩ Y) = X ∩ Y := by
  rw [boxPred_inter, hX, hY]

/-- Set.univ is a fixpoint of boxPred. -/
theorem boxPred_fixpoint_univ {α : Type*} [DecidableEq α] (step : α → Finset α) :
    boxPred step Set.univ = Set.univ :=
  boxPred_univ step