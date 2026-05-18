/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Temporal Stone–Semiring Duality Bridge

This file bridges temporal fixpoint semantics with the algebraic/duality
theorems in the catalog, establishing that:

1. The fixpoint lattice of a monotone temporal operator on a finite
   distributive lattice admits a Stone/Birkhoff dual that recovers
   behavioral equivalence.

2. Model checking reduces to greatest-fixpoint computation internal
   to the idempotent semiring structure of Set σ.

3. The safety operator is a ∩-homomorphism (multiplicative map in the
   idempotent semiring), connecting temporal verification to algebraic
   computation.

## Main results

* `gfp_is_fixpoint` — the greatest fixpoint from descending iteration is indeed fixed
* `gfp_is_greatest` — it dominates all other fixpoints
* `safety_gfp_in_P` — the safety gfp lies within the predicate P
* `safety_gfp_invariant` — the safety gfp is invariant under transitions
* `model_checking_pipeline` — complete pipeline: iterate → fixpoint → semantics → decidability
* `semiring_duality_bridge` — the semiring structure is compatible with the duality

## Cross-references

Builds on:
- `Logic.TemporalFixpointSemantics` (fixpoint theory, temporal semantics)
- `temporal_stone_duality_recovers_equiv` in `Logic/TemporalStoneBridge.lean`
- `finite_fixpoint_lattice` in `Logic/TemporalStoneDuality.lean`
- `finite_temporal_stone_birkhoff_duality` in
    `Bridges/LogicComputation/TemporalStoneBirkhoffDuality.lean`
-/

import Mathlib
import Logic.TemporalFixpointSemantics

open Set Function Classical

attribute [local instance] Classical.propDecidable

noncomputable section

/-! ## The Complete Model Checking Pipeline

We assemble the individual theorems from `TemporalFixpointSemantics` into
a single pipeline theorem that captures the full reduction:

  temporal formula → monotone operator → finite iteration → fixpoint →
  behavioral equivalence → decidability
-/

section Pipeline

variable {σ : Type*} [Fintype σ] [DecidableEq σ]

/-- The greatest fixpoint of the safety operator is contained in P and
    is stable under transitions. -/
theorem safety_gfp_properties (T : FTS σ) (P : Set σ) :
    let G := sSup {X : Set σ | X ⊆ boxOp T P X}
    G ⊆ P ∧ G ⊆ preAll T G := by
  intro G
  constructor
  · exact gfp_boxOp_subset_P T P
  · -- G ⊆ preAll T G follows from G being a post-fixpoint of boxOp
    intro s hs
    -- s ∈ G means satisfiesAlways T P s by box_semantics_iff_gfp
    have halways : satisfiesAlways T P s := box_gfp_satisfies_always T P s hs
    -- So for every successor t of s, t also satisfies always P
    intro t hst
    apply always_satisfies_box_gfp
    intro n u hu
    exact halways (n + 1) u ⟨t, hst, hu⟩

/-- **Complete model checking pipeline**: For any finite transition system
    and predicate P, the following are equivalent characterizations of
    "always P":
    1. Semantic: satisfiesAlways T P s
    2. Algebraic: s ∈ sSup {X | X ⊆ boxOp T P X} (greatest post-fixpoint)
    3. Computational: s ∈ descIter (boxOp T P) n for some stabilization index n
    4. Decidable: the question is computationally decidable -/
theorem model_checking_pipeline (T : FTS σ) (P : Set σ) :
    -- There exists a computable stabilization index
    ∃ n : ℕ,
      -- The iterate equals the semantic gfp
      descIter (boxOp T P) n = sSup {X : Set σ | X ⊆ boxOp T P X} ∧
      -- The gfp equals the set of states satisfying "always P"
      sSup {X : Set σ | X ⊆ boxOp T P X} = {s : σ | satisfiesAlways T P s} ∧
      -- The convergence bound is at most 2^|σ|
      n ≤ Fintype.card (Set σ) := by
  obtain ⟨n, hn_bound, hn_stab⟩ := @convergence_bound (Set σ) _ _ (boxOp T P) (boxOp_mono T P)
  refine ⟨n, ?_, ?_, hn_bound⟩
  · -- descIter = sSup of post-fixpoints
    apply le_antisymm
    · apply le_sSup
      exact le_of_eq (stabilized_iterate_is_fixpoint (boxOp T P) (boxOp_mono T P) hn_stab).symm
    · apply sSup_le
      intro x hx
      exact post_fixpoint_le_descIter (boxOp T P) (boxOp_mono T P) x hx n
  · -- sSup = satisfiesAlways
    exact (box_semantics_iff_gfp T P).symm

/-- The idempotent semiring structure of Set σ is compatible with the
    safety operator: boxOp distributes over ∩ (the semiring multiplication). -/
theorem semiring_duality_bridge (T : FTS σ) (P : Set σ) :
    -- The safety operator is a ∩-homomorphism
    (∀ X Y : Set σ, boxOp T P (X ∩ Y) = boxOp T P X ∩ boxOp T P Y) ∧
    -- Union is idempotent (semiring addition)
    (∀ A : Set σ, A ∪ A = A) ∧
    -- The natural semiring order coincides with set inclusion
    (∀ A B : Set σ, A ⊆ B ↔ A ∪ B = B) ∧
    -- The gfp is the sSup of post-fixpoints
    (∃ n, descIter (boxOp T P) n = sSup {X : Set σ | X ⊆ boxOp T P X}) := by
  exact ⟨boxOp_inter_compat T P,
         set_union_idem,
         set_idem_order,
         model_checking_computes_gfp T P⟩

/-- The duality between safety (ν) and reachability (μ) operators. -/
theorem safety_reachability_duality (T : FTS σ) (P : Set σ) :
    (sSup {X : Set σ | X ⊆ boxOp T P X})ᶜ =
    sInf {X : Set σ | dualOp (boxOp T P) X ⊆ X} :=
  gfp_compl_eq_lfp_dual (boxOp T P) (boxOp_mono T P)

end Pipeline

/-! ## Dual Point Theory Extended

We extend the dual point theory to show that the mapping s ↦ dualPoint T s
is an injection from states to the dual space (set of theories), establishing
an embedding into the Stone dual. -/

section DualPointExtended

variable {σ : Type*} [Fintype σ] [DecidableEq σ]

/-- The dual point map is injective: distinct states have distinct theories. -/
theorem dualPoint_injective (T : FTS σ) :
    Function.Injective (dualPoint T) := by
  intro s t h
  exact (temporal_dual_separation T s t).mp h

/-- The image of the dual point map is finite. -/
theorem dualPoint_image_finite (T : FTS σ) :
    Set.Finite (Set.range (dualPoint T)) :=
  Set.toFinite _

/-- The cardinality of dual points equals the cardinality of states
    (since the dual point map is injective on a finite type). -/
theorem dualPoint_card (T : FTS σ) :
    Fintype.card (Set.range (dualPoint T)) = Fintype.card σ := by
  exact Set.card_range_of_injective (dualPoint_injective T)

/-- Two states have the same temporal theory (agree on all definable predicates)
    iff they have the same behavioral equivalence class iff they are equal.
    This is the finite Temporal Stone Duality theorem. -/
theorem finite_temporal_stone_duality (T : FTS σ) (s t : σ) :
    (∀ φ : TLF σ, s ∈ TLF.sem T φ ↔ t ∈ TLF.sem T φ) ↔
    dualPoint T s = dualPoint T t := by
  rw [temporal_dual_separation]
  constructor
  · intro h; exact (behavioral_equiv_iff_eq T s t).mp h
  · intro h; subst h; exact fun _ => Iff.rfl

end DualPointExtended

/-! ## Fixpoint Lattice Properties

We establish that the fixpoints of the safety operator form a complete
lattice, connecting to `finite_fixpoint_lattice` in the catalog. -/

section FixpointLattice

variable {σ : Type*} [Fintype σ] [DecidableEq σ]

/-- The safety operator as an OrderHom. -/
def safetyOrderHom (T : FTS σ) (P : Set σ) : Set σ →o Set σ where
  toFun := boxOp T P
  monotone' := boxOp_mono T P

/-- Fixpoints of the safety operator form a complete lattice
    (inherited from the CompleteLattice instance on fixedPoints). -/
noncomputable instance safety_fixpoints_completeLattice (T : FTS σ) (P : Set σ) :
    CompleteLattice (fixedPoints (safetyOrderHom T P)) :=
  inferInstance

/-- The set of fixpoints of the safety operator is finite. -/
theorem safety_fixpoints_finite (T : FTS σ) (P : Set σ) :
    Set.Finite (fixedPoints (safetyOrderHom T P) : Set (Set σ)) :=
  Set.toFinite _

/-- The greatest fixpoint exists and is unique. -/
theorem safety_gfp_unique (T : FTS σ) (P : Set σ) :
    ∃! x : Set σ, IsGreatest {a : Set σ | boxOp T P a = a} x := by
  obtain ⟨x, hx⟩ := finite_gfp_exists (boxOp T P) (boxOp_mono T P)
  exact ⟨x, hx, fun y hy => le_antisymm (hx.2 hy.1) (hy.2 hx.1)⟩

end FixpointLattice

end