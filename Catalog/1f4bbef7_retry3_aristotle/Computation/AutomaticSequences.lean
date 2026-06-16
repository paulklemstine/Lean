/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Deterministic Finite Automata with Output and Automatic Sequences

## Overview

This file develops a minimal, self-contained theory of *deterministic finite
automata with output* (DFAOs) and the *automatic sequences* they generate.  The
emphasis is purely on finite-state arguments: nothing here depends on digit
arithmetic, Christol's theorem, or any notion of general computability.

A `DFAO k Q α` reads words over the alphabet `Fin k`, walks through a finite
state space `Q` starting from an initial state `q0` using a transition function
`step`, and labels each state with an output value in `α` via `out`.  The output
*produced* by a word `w` is the label of the state reached after reading `w`.

A function `f : ℕ → α` is `k`-automatic when there is a DFAO together with an
encoder `encode : ℕ → List (Fin k)` such that `f n` equals the output produced
by `encode n`.  The encoder is kept as an abstract parameter: the canonical
choice is the base-`k` digit expansion of `n`, but none of the finite-state
results below depend on that choice, so we avoid the digit-arithmetic layer
entirely.

## Main results

* `IsKAutomatic.range_finite` — a `k`-automatic sequence has finite range,
  because every value lies in the (finite) image of the output map.
* `DFAO.decidableOccurs` — for a fixed DFAO and target output `a`, the
  proposition "some word produces output `a`" is decidable, via a finite search
  over the reachable states.
* `Unary.eventuallyPeriodic` — the sequence `n ↦ out (next^[n] q0)` produced by
  a unary automaton is eventually periodic, by the finite-orbit repetition
  (pigeonhole) argument on iterates.
* `IsKAutomatic.not_of_range_infinite` / `not_isKAutomatic_id` — an obstruction:
  a sequence with infinite range is not automatic, so the identity sequence
  `n ↦ n` is not `k`-automatic for any `k`.
-/

import Mathlib

namespace Catalog.AutomaticSequences

universe u v

/-! ## Deterministic finite automata with output -/

/-- A deterministic finite automaton with output over the alphabet `Fin k`,
state space `Q`, and output alphabet `α`. -/
structure DFAO (k : ℕ) (Q : Type u) (α : Type v) where
  /-- The initial state. -/
  q0 : Q
  /-- The transition function: read one input symbol from a state. -/
  step : Q → Fin k → Q
  /-- The output label attached to each state. -/
  out : Q → α

namespace DFAO

variable {k : ℕ} {Q : Type u} {α : Type v}

/-- The state reached after reading the word `w` starting from the initial state. -/
def run (M : DFAO k Q α) (w : List (Fin k)) : Q :=
  w.foldl M.step M.q0

/-- The output produced by reading the word `w`. -/
def eval (M : DFAO k Q α) (w : List (Fin k)) : α :=
  M.out (M.run w)

@[simp] theorem run_nil (M : DFAO k Q α) : M.run [] = M.q0 := rfl

@[simp] theorem run_concat (M : DFAO k Q α) (w : List (Fin k)) (c : Fin k) :
    M.run (w ++ [c]) = M.step (M.run w) c := by
  simp [run]

@[simp] theorem eval_def (M : DFAO k Q α) (w : List (Fin k)) :
    M.eval w = M.out (M.run w) := rfl

/-! ### Reachable states -/

/-- A state is reachable when it is the result of reading some word. -/
inductive Reachable (M : DFAO k Q α) : Q → Prop
  | base : Reachable M M.q0
  | step {q : Q} (c : Fin k) : Reachable M q → Reachable M (M.step q c)

/-- Every state reached by a word is reachable. -/
theorem reachable_run (M : DFAO k Q α) (w : List (Fin k)) : M.Reachable (M.run w) := by
  induction w using List.reverseRecOn with
  | nil => simpa using Reachable.base
  | append_singleton w c ih => simpa using ih.step c

/-- Reachability is exactly being the result of reading some word. -/
theorem reachable_iff_exists_word (M : DFAO k Q α) (q : Q) :
    M.Reachable q ↔ ∃ w : List (Fin k), M.run w = q := by
  constructor
  · intro h
    induction h with
    | base => exact ⟨[], rfl⟩
    | step c _ ih =>
        obtain ⟨w, hw⟩ := ih
        exact ⟨w ++ [c], by simp [hw]⟩
  · rintro ⟨w, rfl⟩
    exact M.reachable_run w

end DFAO

/-! ## Computing the reachable states of a finite DFAO -/

namespace DFAO

variable {k : ℕ} {Q : Type} {α : Type v}
variable [Fintype Q] [DecidableEq Q]

/-- One round of the breadth-first expansion: add every state directly reachable
in a single transition from the current set. -/
def expand (M : DFAO k Q α) (S : Finset Q) : Finset Q :=
  S ∪ S.biUnion (fun q => Finset.univ.image (fun c => M.step q c))

omit [Fintype Q] in
theorem subset_expand (M : DFAO k Q α) (S : Finset Q) : S ⊆ M.expand S :=
  Finset.subset_union_left

omit [Fintype Q] in
/-- If `q` is in the set and `c` is a symbol, then `step q c` is in the expansion. -/
theorem step_mem_expand (M : DFAO k Q α) {S : Finset Q} {q : Q} (hq : q ∈ S) (c : Fin k) :
    M.step q c ∈ M.expand S := by
  refine Finset.mem_union_right _ ?_
  exact Finset.mem_biUnion.2 ⟨q, hq, Finset.mem_image.2 ⟨c, Finset.mem_univ _, rfl⟩⟩

/-- The `n`-fold breadth-first expansion starting from the initial state. -/
def reach (M : DFAO k Q α) : ℕ → Finset Q
  | 0 => {M.q0}
  | n + 1 => M.expand (M.reach n)

omit [Fintype Q] in
theorem reach_mono_succ (M : DFAO k Q α) (n : ℕ) : M.reach n ⊆ M.reach (n + 1) :=
  M.subset_expand _

omit [Fintype Q] in
theorem reach_mono (M : DFAO k Q α) {m n : ℕ} (h : m ≤ n) : M.reach m ⊆ M.reach n := by
  induction h with
  | refl => exact Finset.Subset.refl _
  | step _ ih => exact ih.trans (M.reach_mono_succ _)

omit [Fintype Q] in
/-- Everything produced by the expansion is genuinely reachable. -/
theorem mem_reach_imp_reachable (M : DFAO k Q α) :
    ∀ (n : ℕ) {q : Q}, q ∈ M.reach n → M.Reachable q := by
  intro n
  induction n with
  | zero =>
      intro q hq
      rw [reach, Finset.mem_singleton] at hq
      subst hq
      exact Reachable.base
  | succ n ih =>
      intro q hq
      rw [reach, expand, Finset.mem_union] at hq
      rcases hq with hq | hq
      · exact ih hq
      · rw [Finset.mem_biUnion] at hq
        obtain ⟨p, hp, hpq⟩ := hq
        rw [Finset.mem_image] at hpq
        obtain ⟨c, _, rfl⟩ := hpq
        exact (ih hp).step c

omit [Fintype Q] in
/-- If the expansion stabilizes at stage `n`, it stays constant afterwards. -/
theorem reach_stable (M : DFAO k Q α) {n : ℕ} (h : M.reach (n + 1) = M.reach n) :
    ∀ m, n ≤ m → M.reach m = M.reach n := by
  intro m hm
  induction hm with
  | refl => rfl
  | step hk ih => rw [reach, ih, ← reach, h]

omit [Fintype Q] in
/-- If the expansion has not stabilized in any of the first `n` stages, then the
`n`-th stage already contains at least `n + 1` states. -/
theorem reach_card_ge (M : DFAO k Q α) :
    ∀ n, (∀ i < n, M.reach (i + 1) ≠ M.reach i) → n + 1 ≤ (M.reach n).card := by
  intro n
  induction n with
  | zero => intro _; simp [reach]
  | succ n ih =>
      intro h
      have hstep : M.reach (n + 1) ≠ M.reach n := h n (Nat.lt_succ_self n)
      have hsub : M.reach n ⊆ M.reach (n + 1) := M.reach_mono_succ n
      have hssub : M.reach n ⊂ M.reach (n + 1) :=
        ⟨hsub, fun hcon => hstep (Finset.Subset.antisymm hcon (M.reach_mono_succ n))⟩
      have hcard : (M.reach n).card < (M.reach (n + 1)).card :=
        Finset.card_lt_card hssub
      have hprev : n + 1 ≤ (M.reach n).card := ih fun i hi => h i (Nat.lt_succ_of_lt hi)
      omega

/-- Within `Fintype.card Q` stages the expansion must stabilize. -/
theorem exists_reach_stable (M : DFAO k Q α) :
    ∃ n ≤ Fintype.card Q, M.reach (n + 1) = M.reach n := by
  by_contra h
  push_neg at h
  have hbig : Fintype.card Q + 1 ≤ (M.reach (Fintype.card Q)).card :=
    M.reach_card_ge (Fintype.card Q) (fun i hi => h i (le_of_lt hi))
  have hle : (M.reach (Fintype.card Q)).card ≤ Fintype.card Q :=
    (Finset.card_le_univ _).trans_eq (Finset.card_univ)
  omega

/-- The reachable-state finset: the expansion taken to a guaranteed fixed point. -/
def reachSet (M : DFAO k Q α) : Finset Q := M.reach (Fintype.card Q)

/-- `reachSet` is a fixed point of `expand`. -/
theorem expand_reachSet (M : DFAO k Q α) : M.expand M.reachSet = M.reachSet := by
  obtain ⟨n, hn, hstable⟩ := M.exists_reach_stable
  have heqN : M.reach (Fintype.card Q) = M.reach n :=
    M.reach_stable hstable (Fintype.card Q) hn
  have hfix : M.expand (M.reach n) = M.reach n := by
    have h2 := hstable
    rwa [reach] at h2
  rw [reachSet, heqN]
  exact hfix

theorem q0_mem_reachSet (M : DFAO k Q α) : M.q0 ∈ M.reachSet := by
  apply M.reach_mono (Nat.zero_le _)
  simp [reach]

/-- Every reachable state lies in `reachSet`. -/
theorem reachable_mem_reachSet (M : DFAO k Q α) {q : Q} (h : M.Reachable q) :
    q ∈ M.reachSet := by
  induction h with
  | base => exact M.q0_mem_reachSet
  | step c _ ih =>
      have := M.step_mem_expand ih c
      rwa [M.expand_reachSet] at this

/-- `reachSet` consists of exactly the reachable states. -/
theorem mem_reachSet_iff (M : DFAO k Q α) (q : Q) :
    q ∈ M.reachSet ↔ M.Reachable q :=
  ⟨fun h => M.mem_reach_imp_reachable _ h, fun h => M.reachable_mem_reachSet h⟩

/-! ### Decidability of occurrence -/

/-- The output `a` is produced by some word iff some reachable state outputs `a`. -/
theorem occurs_iff (M : DFAO k Q α) (a : α) :
    (∃ w : List (Fin k), M.eval w = a) ↔ ∃ q ∈ M.reachSet, M.out q = a := by
  constructor
  · rintro ⟨w, hw⟩
    refine ⟨M.run w, ?_, hw⟩
    exact M.reachable_mem_reachSet (M.reachable_run w)
  · rintro ⟨q, hq, hout⟩
    obtain ⟨w, hw⟩ := (M.reachable_iff_exists_word q).1 ((M.mem_reachSet_iff q).1 hq)
    exact ⟨w, by simp [eval, hw, hout]⟩

/-- For a finite DFAO and a target output `a` with decidable equality on outputs,
it is decidable whether some word produces output `a`.  The decision is a finite
search over the reachable states. -/
instance decidableOccurs (M : DFAO k Q α) [DecidableEq α] (a : α) :
    Decidable (∃ w : List (Fin k), M.eval w = a) :=
  decidable_of_iff _ (M.occurs_iff a).symm

end DFAO

/-! ## Automatic sequences -/

/-- A function `f : ℕ → α` is `k`-automatic when there is a finite-state DFAO and
an encoder `encode : ℕ → List (Fin k)` such that `f n` is the output produced by
the DFAO on `encode n`.  The encoder is an abstract parameter (the canonical
choice being base-`k` digits); the finite-state results do not depend on it. -/
def IsKAutomatic (k : ℕ) {α : Type v} (f : ℕ → α) : Prop :=
  ∃ (Q : Type) (_ : Fintype Q) (M : DFAO k Q α) (encode : ℕ → List (Fin k)),
    ∀ n, f n = M.eval (encode n)

variable {α : Type v}

/-- **Finite range.**  A `k`-automatic sequence takes only finitely many values,
because each value lies in the finite image of the output map. -/
theorem IsKAutomatic.range_finite {k : ℕ} {f : ℕ → α} (h : IsKAutomatic k f) :
    (Set.range f).Finite := by
  obtain ⟨Q, hQ, M, encode, hf⟩ := h
  have hsub : Set.range f ⊆ Set.range M.out := by
    rintro x ⟨n, rfl⟩
    exact ⟨M.run (encode n), by simp [hf n, DFAO.eval]⟩
  exact (Set.finite_range M.out).subset hsub

/-! ## Unary automata and eventual periodicity -/

namespace Unary

/-- A unary automaton: a finite state space `Q` with a self-map `next`, an initial
state `q0`, and an output map `out`.  Equivalently a DFAO over a one-symbol
alphabet. -/
structure UnaryDFAO (Q : Type u) (α : Type v) where
  /-- The initial state. -/
  q0 : Q
  /-- The (single) transition: advance one step. -/
  next : Q → Q
  /-- The output label of each state. -/
  out : Q → α

variable {Q : Type u} {α : Type v}

/-- The sequence generated by a unary automaton: the output of the `n`-th iterate. -/
def UnaryDFAO.seq (M : UnaryDFAO Q α) (n : ℕ) : α := M.out (M.next^[n] M.q0)

/-- A sequence `s : ℕ → α` is eventually periodic. -/
def EventuallyPeriodic (s : ℕ → α) : Prop :=
  ∃ (pre p : ℕ), 0 < p ∧ ∀ n, pre ≤ n → s (n + p) = s n

/-- On a finite type the orbit of any point under iteration repeats: there are
`i < j` with equal iterates. -/
theorem exists_iterate_eq [Finite Q] (g : Q → Q) (x : Q) :
    ∃ i j, i < j ∧ g^[i] x = g^[j] x := by
  obtain ⟨a, b, hab, hgab⟩ := Finite.exists_ne_map_eq_of_infinite (fun n : ℕ => g^[n] x)
  rcases lt_or_gt_of_ne hab with h | h
  · exact ⟨a, b, h, hgab⟩
  · exact ⟨b, a, h, hgab.symm⟩

/-- A single coincidence of iterates `g^[i] x = g^[j] x` (with `i < j`) propagates:
from index `i` onwards the orbit is periodic with period `j - i`. -/
theorem iterate_periodic_of_eq (g : Q → Q) (x : Q) {i j : ℕ} (hij : i < j)
    (h : g^[i] x = g^[j] x) :
    ∀ n, i ≤ n → g^[n + (j - i)] x = g^[n] x := by
  intro n hn
  have hp : n + (j - i) = (n - i) + j := by omega
  have hni : n = (n - i) + i := by omega
  calc g^[n + (j - i)] x = g^[(n - i) + j] x := by rw [hp]
    _ = g^[n - i] (g^[j] x) := by rw [Function.iterate_add_apply]
    _ = g^[n - i] (g^[i] x) := by rw [h]
    _ = g^[(n - i) + i] x := by rw [Function.iterate_add_apply]
    _ = g^[n] x := by rw [← hni]

/-- **Eventual periodicity of unary automata.**  The sequence produced by a unary
automaton on a finite state space is eventually periodic. -/
theorem eventuallyPeriodic [Finite Q] (M : UnaryDFAO Q α) :
    EventuallyPeriodic M.seq := by
  obtain ⟨i, j, hij, heq⟩ := exists_iterate_eq M.next M.q0
  refine ⟨i, j - i, by omega, ?_⟩
  intro n hn
  have hper := iterate_periodic_of_eq M.next M.q0 hij heq n hn
  simp only [UnaryDFAO.seq]
  rw [hper]

end Unary

/-! ## An obstruction: infinite range forbids automaticity -/

/-- **Obstruction lemma.**  A sequence with infinite range cannot be
`k`-automatic. -/
theorem IsKAutomatic.not_of_range_infinite {k : ℕ} {f : ℕ → α}
    (h : (Set.range f).Infinite) : ¬ IsKAutomatic k f :=
  fun hk => h hk.range_finite

/-- The identity sequence `n ↦ n` is not `k`-automatic for any `k`. -/
theorem not_isKAutomatic_id (k : ℕ) : ¬ IsKAutomatic k (fun n : ℕ => n) := by
  apply IsKAutomatic.not_of_range_infinite
  apply Set.infinite_range_of_injective
  exact fun a b h => h

end Catalog.AutomaticSequences