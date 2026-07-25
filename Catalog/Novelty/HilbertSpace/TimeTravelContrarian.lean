/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Time-Travel Logic, Contrarian Edition: which hypotheses *force* self-consistency?

This file continues the study of causal loops and the **Novikov self-consistency
principle** begun in `Catalog/.../TimeTravelCausalConsistency.lean`.  There a causal
loop's one-traversal net effect is modelled by a self-map `evolve : X → X`, and a loop
is **self-consistent** exactly when `evolve` has a fixed point.

The mission here is *contrarian*: we state a batch of bold conjectures of the form
"such-and-such structural hypothesis on the loop forces a consistent history", and for
each we either **prove** it or exhibit an explicit **counterexample** (a disproof).

The verdicts:

* `not_bijective_forces_selfConsistent` — **DISPROVED.**  Reversibility of the causal
  step (the loop map being a bijection) does *not* force self-consistency: the
  grandfather flip `¬·` on `Bool` is a bijection with no fixed point.
* `exists_sq_consistent_not_consistent` — **DISPROVED** ("consistency does not descend").
  A loop whose *double* traversal is self-consistent need not itself be self-consistent.
* `exists_selfConsistent_comp_not_selfConsistent` — **DISPROVED** ("consistency is not
  compositional").  Two self-consistent loops sharing a state space can compose to a
  fixed-point-free (paradoxical) loop; explicit witnesses on `Fin 3`.
* `selfConsistent_iterate` — **PROVED** ("consistency ascends").  A self-consistent
  loop stays self-consistent under every number of repetitions.
* `contracting_unique_selfConsistent` — **PROVED** ("deterministic time travel").  If
  the loop map is a contraction on a complete state space, the consistent history exists
  and is *unique* (Banach).
* `involutive_consistentCount_parity` — **PROVED** (quantitative Novikov).  For a
  reversible-by-symmetry (involutive) loop on a finite state space, the number of
  consistent histories has the same parity as the number of states.
* `involutive_odd_selfConsistent` — **PROVED** corollary: an involutive loop on an
  odd-sized state space is always self-consistent (with an *odd* number of histories).
* `exists_iterate_selfConsistent` — **PROVED** ("eventual consistency").  On a finite
  non-empty state space, some positive number of repetitions of *any* loop is
  self-consistent.
* `grandfather_consistentCount` / `identity_consistentCount` — concrete counts.
-/

import Mathlib

namespace TimeTravelContrarian

open Function

variable {X : Type*}

/-! ## Core model -/

/-- A **causal loop** (closed timelike curve): `evolve x` is the world-state produced by
feeding the state `x` once around the loop. -/
structure CausalLoop (X : Type*) where
  /-- Net effect of one traversal of the loop on the world-state. -/
  evolve : X → X

/-- **Novikov self-consistency principle.**  A loop is *self-consistent* when some
world-state is reproduced by one traversal, i.e. `evolve` has a fixed point. -/
def CausalLoop.SelfConsistent (L : CausalLoop X) : Prop := ∃ x, L.evolve x = x

/-- The number of consistent histories of a loop on a finite state space: the number of
fixed points of the loop map. -/
def CausalLoop.consistentCount (L : CausalLoop X) [Fintype X] [DecidableEq X] : ℕ :=
  (Finset.univ.filter (fun x => L.evolve x = x)).card

lemma CausalLoop.selfConsistent_of_count_pos [Fintype X] [DecidableEq X]
    {L : CausalLoop X} (h : 0 < L.consistentCount) : L.SelfConsistent := by
  unfold CausalLoop.consistentCount at h
  rw [Finset.card_pos] at h
  obtain ⟨x, hx⟩ := h
  exact ⟨x, (Finset.mem_filter.mp hx).2⟩

/-! ## Disproofs: hypotheses that do **not** force self-consistency -/

/-- **DISPROOF — reversibility does not force consistency.**  It is *not* true that every
loop whose evolution is a bijection admits a consistent history: the grandfather flip
`¬·` on `Bool` is a bijection with no fixed point. -/
theorem not_bijective_forces_selfConsistent :
    ¬ (∀ (Y : Type) [Fintype Y] [Nonempty Y] (L : CausalLoop Y),
        Function.Bijective L.evolve → L.SelfConsistent) := by
  intro h
  obtain ⟨b, hb⟩ := h Bool ⟨Bool.not⟩ (by decide)
  cases b <;> simp_all

/-- **DISPROOF — consistency does not descend along repetition.**  A loop whose *double*
traversal is self-consistent need not itself be self-consistent: `¬·` traversed twice is
the identity (consistent everywhere) yet `¬·` alone is the grandfather paradox. -/
theorem exists_sq_consistent_not_consistent :
    ∃ (Y : Type) (L : CausalLoop Y),
      (CausalLoop.mk (L.evolve^[2])).SelfConsistent ∧ ¬ L.SelfConsistent := by
  refine ⟨Bool, ⟨Bool.not⟩, ?_, ?_⟩
  · exact ⟨true, by decide⟩
  · rintro ⟨b, hb⟩; cases b <;> simp_all

/-- **DISPROOF — consistency is not compositional.**  Two self-consistent loops on the
same state space can compose to a fixed-point-free (paradoxical) loop.  Witnesses on
`Fin 3`: `f = (0 1)` fixes `2`, `g = (1 2)` fixes `0`, but `f ∘ g` is the 3-cycle
`0 → 1 → 2 → 0`, which has no fixed point. -/
theorem exists_selfConsistent_comp_not_selfConsistent :
    ∃ (Y : Type) (f g : Y → Y),
      (CausalLoop.mk f).SelfConsistent ∧ (CausalLoop.mk g).SelfConsistent ∧
      ¬ (CausalLoop.mk (f ∘ g)).SelfConsistent := by
  refine ⟨Fin 3, ![1, 0, 2], ![0, 2, 1], ?_, ?_, ?_⟩
  · exact ⟨2, by decide⟩
  · exact ⟨0, by decide⟩
  · show ¬ ∃ x : Fin 3, (![1, 0, 2] ∘ ![0, 2, 1]) x = x
    decide

/-! ## Proofs: hypotheses that **do** force self-consistency -/

/-- **PROOF — consistency ascends along repetition.**  If a single traversal is
self-consistent, then so is every number `k` of repetitions: the same state is fixed by
every iterate. -/
theorem selfConsistent_iterate (L : CausalLoop X) (h : L.SelfConsistent) (k : ℕ) :
    (CausalLoop.mk (L.evolve^[k])).SelfConsistent := by
  obtain ⟨x, hx⟩ := h
  exact ⟨x, iterate_fixed hx k⟩

/-- **PROOF — deterministic time travel.**  If the loop map is a contraction on a
complete, non-empty state space, then a consistent history exists and is *unique*
(Banach fixed-point theorem).  This is the "determinism" regime: the past pins the
history down completely. -/
theorem contracting_unique_selfConsistent [MetricSpace X] [CompleteSpace X] [Nonempty X]
    {K : NNReal} (L : CausalLoop X) (hK : ContractingWith K L.evolve) :
    ∃! x, L.evolve x = x := by
  refine ⟨ContractingWith.fixedPoint L.evolve hK, hK.fixedPoint_isFixedPt, ?_⟩
  intro y hy
  exact ContractingWith.fixedPoint_unique' hK hy hK.fixedPoint_isFixedPt

/-
**PROOF — quantitative Novikov for involutive loops.**  If the loop map is an
involution (traversing the loop twice restores the state) on a finite state space, then
the number of consistent histories has the *same parity* as the number of states.  This
refines the mere existence result below to an exact parity count.
-/
theorem involutive_consistentCount_parity [Fintype X] [DecidableEq X] {f : X → X}
    (hf : Involutive f) :
    (CausalLoop.mk f).consistentCount ≡ Fintype.card X [MOD 2] := by
  -- Let σ be the permutation `Equiv.ofBijective f hf.bijective`.
  set σ : Equiv.Perm X := Equiv.ofBijective f ⟨Function.Involutive.injective hf, Function.Involutive.surjective hf⟩;
  -- By `Equiv.Perm.two_dvd_card_support`, the support of σ has even cardinality.
  have h_support_even : Even (Finset.card (σ.support)) := by
    convert Equiv.Perm.two_dvd_card_support ( show σ ^ 2 = 1 from ?_ ) using 1;
    · exact funext fun n => by simp +decide [ even_iff_two_dvd ] ;
    · ext x; simp +decide [ sq ] ;
      exact hf x;
  unfold CausalLoop.consistentCount; simp_all +decide [ Nat.ModEq, Nat.even_iff ] ;
  rw [ show Fintype.card X = Finset.card ( Finset.filter ( fun x => f x = x ) Finset.univ ) + Finset.card ( Finset.filter ( fun x => f x ≠ x ) Finset.univ ) by rw [ ← Finset.card_union_of_disjoint ( Finset.disjoint_filter.2 fun _ _ _ => by tauto ), Finset.filter_union_filter_not_eq ] ; simp +decide, add_comm ];
  rw [ show Finset.filter ( fun x => f x ≠ x ) Finset.univ = σ.support from ?_ ] ; simp_all +decide [ Nat.add_mod ];
  ext x; simp [σ]

/-- **PROOF — odd loops are self-consistent (with an odd number of histories).**  An
involutive loop on an odd-sized state space always admits a consistent history; in fact
the number of histories is odd, hence positive. -/
theorem involutive_odd_selfConsistent [Fintype X] [DecidableEq X] {f : X → X}
    (hf : Involutive f) (hodd : Odd (Fintype.card X)) :
    (CausalLoop.mk f).SelfConsistent := by
  apply CausalLoop.selfConsistent_of_count_pos
  have hpar := involutive_consistentCount_parity hf
  rw [Nat.ModEq] at hpar
  rw [Nat.odd_iff] at hodd
  omega

/-! ## Eventual consistency on finite state spaces -/

/-- On a finite non-empty state space, every self-map has a periodic point: some positive
iterate fixes some state. -/
lemma exists_iterate_fixed [Finite X] [Nonempty X] (g : X → X) :
    ∃ k, 0 < k ∧ ∃ x, g^[k] x = x := by
  obtain ⟨x0⟩ := (inferInstance : Nonempty X)
  obtain ⟨i, j, hne, hij⟩ := Finite.exists_ne_map_eq_of_infinite (fun n : ℕ => g^[n] x0)
  rcases lt_or_gt_of_ne hne with h | h
  · refine ⟨j - i, by omega, g^[i] x0, ?_⟩
    rw [← Function.iterate_add_apply, Nat.sub_add_cancel (le_of_lt h)]
    exact hij.symm
  · refine ⟨i - j, by omega, g^[j] x0, ?_⟩
    rw [← Function.iterate_add_apply, Nat.sub_add_cancel (le_of_lt h)]
    exact hij

/-- **PROOF — eventual consistency.**  On any finite non-empty state space, no matter
what the loop map is, some positive number `k` of repetitions is self-consistent.  Even a
paradoxical single loop becomes consistent once traversed enough times. -/
theorem exists_iterate_selfConsistent [Finite X] [Nonempty X] (L : CausalLoop X) :
    ∃ k, 0 < k ∧ (CausalLoop.mk (L.evolve^[k])).SelfConsistent := by
  obtain ⟨k, hk, x, hx⟩ := exists_iterate_fixed L.evolve
  exact ⟨k, hk, x, hx⟩

/-! ## Concrete counts -/

/-- The grandfather loop `¬·` on `Bool` has exactly zero consistent histories. -/
theorem grandfather_consistentCount :
    (CausalLoop.mk Bool.not).consistentCount = 0 := by decide

/-- The identity loop on `Bool` has exactly two consistent histories (every state is
consistent). -/
theorem identity_consistentCount :
    (CausalLoop.mk (id : Bool → Bool)).consistentCount = 2 := by decide

end TimeTravelContrarian