/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Structural Theorems for the Meeting-Time Filtration

This file proves the core structural theorems that establish the meeting-time filtration
as a well-behaved topological observable for finite trajectories. These form the
deterministic backbone of the persistent arithmetic dynamics program.

## Main Results

* `visitedSet_mono` — the visited set grows monotonically with time
* `meetEdge_mono` — edge monotonicity: once an edge appears, it persists
* `complete_graph_after_full_visit` — once all states have been seen, the graph is complete
* `visitedSet_leftTranslate` — equivariance of visited sets under left translation
* `meetEdge_leftTranslate_iff` — equivariance of edges under left translation
* `complete_after_full_cover_finite_group` — full coverage implies topological triviality
* `visitedSetCard_mono` — the visited-set cardinality is monotone
* `appearsBy_initial` — the initial state always appears by time 0

## Cross-Domain Significance

These theorems bridge:
- **Arithmetic groups ↔ TDA**: equivariance shows persistence is intrinsic to the walk law
- **Spectral graph theory ↔ Persistence collapse**: full coverage forces complete graphs
- **Geometric group theory ↔ Phase transitions**: coverage time controls collapse time
-/

import Mathlib
import Speculative.PersistentHomologyMixing.Defs

namespace PersistentHomologyMixing

/-! ## Monotonicity of the Visited Set -/

/-
The visited set is monotone: if `s ≤ t`, every state seen by time `s`
    has also been seen by time `t`.
-/
theorem visitedSet_mono {α : Type*} [DecidableEq α] {T : ℕ}
    (x : Fin (T + 1) → α) {s t : Fin (T + 1)} (hst : s ≤ t) :
    visitedSet x s ⊆ visitedSet x t := by
      exact Finset.image_subset_image fun i hi => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hi |>.1, le_trans ( Finset.mem_filter.mp hi |>.2 ) hst ⟩

/-
If a state appears by time `s`, it also appears by any later time `t ≥ s`.
-/
theorem appearsBy_mono {α : Type*} [DecidableEq α] {T : ℕ}
    (x : Fin (T + 1) → α) {s t : Fin (T + 1)} (hst : s ≤ t)
    {a : α} (ha : appearsBy x a s) : appearsBy x a t := by
      exact visitedSet_mono x hst ha

/-
The initial state `x 0` always appears at time 0.
-/
theorem appearsBy_initial {α : Type*} [DecidableEq α] {T : ℕ}
    (x : Fin (T + 1) → α) :
    appearsBy x (x ⟨0, Nat.zero_lt_succ T⟩) ⟨0, Nat.zero_lt_succ T⟩ := by
      exact Finset.mem_image_of_mem _ ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, le_rfl ⟩ )

/-
Every state visited at any point appears in the full visited set.
-/
theorem mem_fullVisitedSet_of_range {α : Type*} [DecidableEq α] {T : ℕ}
    (x : Fin (T + 1) → α) (i : Fin (T + 1)) :
    x i ∈ fullVisitedSet x := by
      exact Finset.mem_image_of_mem _ ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, le_top ⟩ )

/-! ## Edge Monotonicity -/

/-
**Theorem 1 (Edge Monotonicity)**: Once an edge appears in the meeting-time filtration,
    it persists at all later times. This is the fundamental monotonicity property that
    makes the construction a valid filtration for persistence theory.
-/
theorem meetEdge_mono {α : Type*} [DecidableEq α] {T : ℕ}
    (x : Fin (T + 1) → α) {s t : Fin (T + 1)} (hst : s ≤ t) :
    ∀ {a b : α}, meetEdge x s a b → meetEdge x t a b := by
      intros a b hab
      obtain ⟨hne, ha, hb⟩ := hab
      exact ⟨hne, appearsBy_mono x hst ha, appearsBy_mono x hst hb⟩

/-! ## Completeness After Full Visit -/

/-
**Theorem 2 (Completeness)**: If every state in the full visited set has appeared by
    time `t`, then the meeting-time graph at time `t` is the complete graph on the
    visited set. This is the deterministic mechanism behind barcode collapse.
-/
theorem complete_graph_after_full_visit {α : Type*} [DecidableEq α] {T : ℕ}
    (x : Fin (T + 1) → α) (t : Fin (T + 1))
    (hfull : ∀ a ∈ fullVisitedSet x, appearsBy x a t) :
    ∀ {a b : α}, a ∈ fullVisitedSet x → b ∈ fullVisitedSet x →
      a ≠ b → meetEdge x t a b := by
        exact fun { a b } ha hb hab => ⟨ hab, hfull a ha, hfull b hb ⟩

/-
**Theorem 3 (Full Coverage on Finite Groups)**: When the trajectory visits every
    element of a finite group, the filtration graph at time `T` is complete.
    This bridges group theory and topological collapse.
-/
theorem complete_after_full_cover_finite_group
    {G : Type*} [Fintype G] [Group G] [DecidableEq G] {T : ℕ}
    (x : Fin (T + 1) → G)
    (hcover : ∀ g : G, g ∈ fullVisitedSet x) :
    ∀ {a b : G}, a ≠ b → meetEdge x ⟨T, Nat.lt_succ_self T⟩ a b := by
      unfold meetEdge;
      aesop

/-! ## Group Equivariance -/

/-
**Theorem 4 (Visited-Set Equivariance)**: Left translation of a group-valued
    trajectory transforms the visited set by left multiplication. This is the first
    step in showing that persistence summaries depend only on the walk law, not on
    the labeling of group elements.
-/
theorem visitedSet_leftTranslate {G : Type*} [Group G] [DecidableEq G] {T : ℕ}
    (g : G) (x : Fin (T + 1) → G) (t : Fin (T + 1)) :
    visitedSet (leftTranslatePath g x) t = (visitedSet x t).image (g * ·) := by
      ext y; exact (by
      simp +decide [ visitedSet, leftTranslatePath ];
      simp +decide only [eq_inv_mul_iff_mul_eq])

/-
**Theorem 5 (Edge Equivariance)**: The meeting-time edge relation is equivariant
    under left translation. This is the key symmetry theorem: persistence summaries
    are intrinsic to the walk law, not to arbitrary group labels.

    Combined with completeness, this shows that the topological phase transition
    detected by the filtration is a genuine invariant of the generating measure.
-/
theorem meetEdge_leftTranslate_iff {G : Type*} [Group G] [DecidableEq G] {T : ℕ}
    (g : G) (x : Fin (T + 1) → G) (t : Fin (T + 1)) (a b : G) :
    meetEdge (leftTranslatePath g x) t (g * a) (g * b) ↔ meetEdge x t a b := by
      simp +decide only [meetEdge];
      simp +decide [ appearsBy, visitedSet_leftTranslate ]

/-! ## Cardinality Monotonicity -/

/-
The number of visited states is monotone in time.
-/
theorem visitedSetCard_mono {α : Type*} [DecidableEq α] {T : ℕ}
    (x : Fin (T + 1) → α) {s t : Fin (T + 1)} (hst : s ≤ t) :
    visitedSetCard x s ≤ visitedSetCard x t := by
      exact Finset.card_mono ( visitedSet_mono x hst )

/-
The visited set at time `t` contains `x t`.
-/
theorem self_mem_visitedSet {α : Type*} [DecidableEq α] {T : ℕ}
    (x : Fin (T + 1) → α) (t : Fin (T + 1)) :
    x t ∈ visitedSet x t := by
      exact Finset.mem_image_of_mem _ ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, le_rfl ⟩ )

/-
If `i ≤ t`, then `x i` is in the visited set at time `t`.
-/
theorem mem_visitedSet_of_le {α : Type*} [DecidableEq α] {T : ℕ}
    (x : Fin (T + 1) → α) {i t : Fin (T + 1)} (hit : i ≤ t) :
    x i ∈ visitedSet x t := by
      -- Since i is in the filter for t, we can use Finset.mem_image to conclude that x i is in � the� image of the filter.
      apply Finset.mem_image.mpr;
      aesop

/-
The full visited set equals the range of `x`.
-/
theorem fullVisitedSet_eq_image {α : Type*} [DecidableEq α] {T : ℕ}
    (x : Fin (T + 1) → α) :
    fullVisitedSet x = Finset.univ.image x := by
      apply Finset.eq_of_subset_of_card_le;
      · exact Finset.image_subset_iff.2 fun i _ => Finset.mem_image_of_mem _ ( Finset.mem_univ _ );
      · convert Finset.card_le_card _;
        exact Finset.image_subset_iff.mpr fun i _ => mem_fullVisitedSet_of_range x i

/-
Left translation is injective, so the visited-set cardinality is preserved.
-/
theorem visitedSetCard_leftTranslate {G : Type*} [Group G] [DecidableEq G] {T : ℕ}
    (g : G) (x : Fin (T + 1) → G) (t : Fin (T + 1)) :
    visitedSetCard (leftTranslatePath g x) t = visitedSetCard x t := by
      unfold visitedSetCard;
      rw [ visitedSet_leftTranslate ] ; exact Finset.card_image_of_injective _ ( mul_right_injective g ) ;

end PersistentHomologyMixing