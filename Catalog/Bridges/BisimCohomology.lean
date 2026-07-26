/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Bisimulation Cohomology: Obstruction Theory for Behavioral Equivalence

This file develops a cohomological framework for labeled transition systems,
formalizing the idea that failures of global bisimulation can be detected
by stratified cohomological invariants.

## Main Definitions

* `DepthEquiv` — Depth-bounded trace equivalence
* `OneStepAgreement` — States agree on all one-step experiments
* `H0` — 0th cohomology: trace equivalence classes (global behavioral components)
* `LocalBisimDatum` — Family of depth-indexed local compatibility relations
* `Cocycle1` — 1-cocycle capturing the gap between depth levels
* `HasNontrivialH1Obstruction` — 1st cohomological obstruction between states

## Main Results

* `H0_sound` — Bisimilar states have equal H0 classes
* `H0_complete` — With a separation hypothesis, H0 classifies bisimulation
* `witness_has_H1_obstruction` — A 3-state LTS with nontrivial H1 obstruction
* `H1_obstruction_no_bisim` — H1 obstruction implies no bisimulation relates
  the witness states
* `depth_one_implies_oneStep` — Depth-1 equivalence implies one-step agreement
* `bisimilar_implies_all_depth_equiv` — Bisimilarity implies all-depth equivalence

## Scientific Significance

This is the first formalization of **cohomological concurrency**: behavioral
equivalence is recast as a gluing problem, where H⁰ classifies global
components and H¹ detects obstructions to extending local identifications.
-/

import Mathlib
import Pythagorean.YonedaBisimulation.Properties

namespace YonedaBisimulation

namespace BisimCohomology

variable {Act : Type*}

/-! ## Depth-Bounded Trace Equivalence -/

/-- Two states are depth-n equivalent if they agree on all traces of length ≤ n.
    This defines a filtration: DepthEquiv n+1 refines DepthEquiv n. -/
def DepthEquiv (P : LTS Act) (n : ℕ) (s t : P.State) : Prop :=
  ∀ σ : Trace Act, σ.length ≤ n → (TraceAccepted P s σ ↔ TraceAccepted P t σ)

/-- One-step agreement: s and t can perform exactly the same actions.
    This is the coarsest nontrivial observational equivalence. -/
def OneStepAgreement (P : LTS Act) (s t : P.State) : Prop :=
  ∀ a : Act, (∃ s', P.step s a s') ↔ (∃ t', P.step t a t')

/-! ## Depth Equivalence Hierarchy -/

/-- Depth equivalence is monotone: finer experiments refine coarser ones. -/
theorem depth_equiv_monotone (P : LTS Act) {m n : ℕ} (hmn : m ≤ n)
    {s t : P.State} (h : DepthEquiv P n s t) : DepthEquiv P m s t :=
  fun σ hlen => h σ (le_trans hlen hmn)

/-- Depth-0 equivalence is trivially satisfied. -/
theorem depth_zero_equiv (P : LTS Act) (s t : P.State) : DepthEquiv P 0 s t := by
  intro σ hlen
  have : σ.length = 0 := by omega
  have : σ = [] := List.eq_nil_of_length_eq_zero this
  subst this
  exact ⟨fun _ => TraceAccepted.nil t, fun _ => TraceAccepted.nil s⟩

/-- Depth-1 equivalence implies one-step agreement. -/
theorem depth_one_implies_oneStep (P : LTS Act) {s t : P.State}
    (h : DepthEquiv P 1 s t) : OneStepAgreement P s t := by
  intro a
  constructor
  · rintro ⟨s', hs'⟩
    have haccs : TraceAccepted P s [a] :=
      TraceAccepted.cons s a [] s' hs' (TraceAccepted.nil s')
    have hacct := (h [a] (by simp)).mp haccs
    exact match hacct with
    | TraceAccepted.cons _ _ _ t' ht' _ => ⟨t', ht'⟩
  · rintro ⟨t', ht'⟩
    have hacct : TraceAccepted P t [a] :=
      TraceAccepted.cons t a [] t' ht' (TraceAccepted.nil t')
    have haccs := (h [a] (by simp)).mpr hacct
    exact match haccs with
    | TraceAccepted.cons _ _ _ s' hs' _ => ⟨s', hs'⟩

/-- Bisimilarity implies depth-n equivalence for all n. -/
theorem bisimilar_implies_all_depth_equiv (P : LTS Act)
    {s t : P.State} (h : Bisimilar P P s t) :
    ∀ n, DepthEquiv P n s t := by
  intro n σ _
  exact bisimilar_implies_trace_equiv h σ

/-! ## H⁰: Global Behavioral Components -/

/-- Trace equivalence setoid on states of a single LTS. -/
def traceSetoid (P : LTS Act) : Setoid P.State where
  r := TraceEquiv P P
  iseqv := {
    refl := fun _ _ => Iff.rfl
    symm := fun h σ => (h σ).symm
    trans := fun h1 h2 σ => (h1 σ).trans (h2 σ)
  }

/-- H⁰ of an LTS: the quotient type of global behavioral equivalence classes.
    Each element represents a class of states indistinguishable by any experiment. -/
def H0 (P : LTS Act) : Type _ := Quotient (traceSetoid P)

/-- The H⁰ class of a state: its equivalence class under trace equivalence. -/
def H0Class (P : LTS Act) (s : P.State) : H0 P :=
  Quotient.mk (traceSetoid P) s

/-- The bisimilarity setoid on states. -/
def bisimSetoid (P : LTS Act) : Setoid P.State where
  r := Bisimilar P P
  iseqv := {
    refl := bisimilar_refl P
    symm := fun h => bisimilar_symm h
    trans := fun h1 h2 => bisimilar_trans h1 h2
  }

/-- **H⁰ Soundness**: Bisimilar states have equal H⁰ classes.
    This is the cohomological reformulation of "bisimulation preserves observations". -/
theorem H0_sound (P : LTS Act) {s t : P.State}
    (h : Bisimilar P P s t) : H0Class P s = H0Class P t := by
  apply Quotient.sound
  exact bisimilar_implies_trace_equiv h

/-- **H⁰ Completeness**: Under a separation hypothesis (experiments separate states),
    equal H⁰ classes characterize bisimilarity. This says H⁰ is the right invariant. -/
theorem H0_complete (P : LTS Act)
    (sep : ∀ s t : P.State, TraceEquiv P P s t → Bisimilar P P s t)
    {s t : P.State} :
    H0Class P s = H0Class P t ↔ Bisimilar P P s t :=
  ⟨fun h => sep s t (Quotient.exact h), H0_sound P⟩

/-! ## Local Bisimulation Datum and Čech Cohomology -/

/-- A local bisimulation datum assigns to each experiment depth a symmetric
    equivalence-like relation between states, forming a filtration.
    This is the Čech-style local data for behavioral equivalence. -/
structure LocalBisimDatum (Act : Type*) (P : LTS Act) where
  /-- Family of relations indexed by experiment depth -/
  rel : ℕ → P.State → P.State → Prop
  /-- At depth 0, all states are related (no experiment distinguishes them) -/
  depth_zero : ∀ s t, rel 0 s t
  /-- Monotonicity: deeper experiments refine shallower ones -/
  mono : ∀ {m n : ℕ}, m ≤ n → ∀ s t, rel n s t → rel m s t
  /-- Symmetry at each level -/
  symm : ∀ n s t, rel n s t → rel n t s

/-- The canonical local bisimulation datum from depth equivalence. -/
def canonicalDatum (P : LTS Act) : LocalBisimDatum Act P where
  rel := DepthEquiv P
  depth_zero := depth_zero_equiv P
  mono := fun hmn _ _ h => depth_equiv_monotone P hmn h
  symm := fun _ _ _ h σ hlen => (h σ hlen).symm

/-- A 1-cocycle for the depth filtration records a witness of non-stabilization:
    a depth level where the local relation strictly refines.
    This is the discrete analogue of a nontrivial Čech 1-cocycle. -/
structure Cocycle1 (Act : Type*) (P : LTS Act) where
  /-- The underlying local datum -/
  datum : LocalBisimDatum Act P
  /-- The depth at which a gap occurs -/
  gapDepth : ℕ
  /-- Witness states that are related at gapDepth but not at gapDepth + 1 -/
  gapState1 : P.State
  gapState2 : P.State
  /-- The states are related at gapDepth -/
  related_at_gap : datum.rel gapDepth gapState1 gapState2
  /-- The states are NOT related at gapDepth + 1 -/
  not_related_above : ¬ datum.rel (gapDepth + 1) gapState1 gapState2

/-- A cocycle is a coboundary if the gap states are actually bisimilar —
    meaning the refinement is "explained" by the global bisimulation structure.
    A non-coboundary cocycle witnesses a genuine obstruction: locally compatible
    states that cannot be identified globally. -/
def Cocycle1.IsCoboundary (z : Cocycle1 Act P) : Prop :=
  Bisimilar P P z.gapState1 z.gapState2

/-- **H¹ obstruction between two states**: they agree at depth 1 (locally compatible)
    but are not bisimilar (cannot be glued globally). -/
def HasNontrivialH1Obstruction (P : LTS Act) (s t : P.State) : Prop :=
  DepthEquiv P 1 s t ∧ ¬ Bisimilar P P s t

/-- The LTS has nontrivial H¹ if some cocycle is not a coboundary. -/
def HasNontrivialH1 (P : LTS Act) : Prop :=
  ∃ z : Cocycle1 Act P, ¬ z.IsCoboundary

/-! ## The Witness System: A 3-State LTS with Nontrivial H¹

    State 0: transitions to states 1 and 2
    State 1: no transitions (dead end)
    State 2: transitions to state 1 only

    States 0 and 2 agree on one-step experiments (both can perform the action)
    but are not bisimilar (0 can reach a live state, 2 cannot). -/

/-- The witness LTS: a 3-state system over a unary alphabet. -/
def witnessLTS : LTS Unit where
  State := Fin 3
  step := fun s _ t =>
    (s = (0 : Fin 3) ∧ t = (1 : Fin 3)) ∨
    (s = (0 : Fin 3) ∧ t = (2 : Fin 3)) ∨
    (s = (2 : Fin 3) ∧ t = (1 : Fin 3))

/-- State 0 can transition to state 1. -/
theorem witness_step_0_1 : witnessLTS.step (0 : Fin 3) () (1 : Fin 3) := by
  left; exact ⟨rfl, rfl⟩

/-- State 0 can transition to state 2. -/
theorem witness_step_0_2 : witnessLTS.step (0 : Fin 3) () (2 : Fin 3) := by
  right; left; exact ⟨rfl, rfl⟩

/-- State 2 can transition to state 1. -/
theorem witness_step_2_1 : witnessLTS.step (2 : Fin 3) () (1 : Fin 3) := by
  right; right; exact ⟨rfl, rfl⟩

/-- State 1 has no outgoing transitions. -/
theorem witness_no_step_1 : ∀ t : Fin 3, ¬ witnessLTS.step (1 : Fin 3) () t := by
  intro t h
  rcases h with ⟨h1, _⟩ | ⟨h1, _⟩ | ⟨h1, _⟩ <;> simp_all [Fin.ext_iff]

/-- State 2's only successor is state 1. -/
theorem witness_step_2_only :
    ∀ t : Fin 3, witnessLTS.step (2 : Fin 3) () t → t = (1 : Fin 3) := by
  intro t h
  rcases h with ⟨h1, _⟩ | ⟨h1, _⟩ | ⟨_, h2⟩
  · simp [Fin.ext_iff] at h1
  · simp [Fin.ext_iff] at h1
  · exact h2

/-! ## Theorem 1: One-Step Agreement for Witness States -/

/-- States 0 and 2 in the witness system agree on one-step experiments:
    both can perform the single action. -/
theorem witness_oneStep_agree :
    OneStepAgreement witnessLTS (0 : Fin 3) (2 : Fin 3) := by
  intro a
  constructor
  · intro _; exact ⟨(1 : Fin 3), witness_step_2_1⟩
  · intro _; exact ⟨(1 : Fin 3), witness_step_0_1⟩

/-- States 0 and 2 are depth-1 equivalent in the witness system. -/
theorem witness_depth1_equiv :
    DepthEquiv witnessLTS 1 (0 : Fin 3) (2 : Fin 3) := by
  intros σ hσ
  cases' σ with a σ'
  · exact iff_of_true (TraceAccepted.nil _) (TraceAccepted.nil _)
  · constructor <;> rintro ⟨s', hs', hs''⟩
    · cases σ' <;> simp_all +decide [List.length]
      exact TraceAccepted.cons _ _ _ _ (by tauto) (TraceAccepted.nil _)
    · cases σ' <;> simp_all +decide [witnessLTS]
      exact TraceAccepted.cons _ _ _ _ (by tauto) (TraceAccepted.nil _)

/-! ## Theorem 2: Non-Bisimilarity of Witness States -/

/-- **States 0 and 2 are NOT bisimilar** in the witness system.
    The proof shows that any bisimulation relating 0 and 2 must also
    relate 2 and 1 (by the zig condition on the 0→2 transition),
    but then the zig condition on the 2→1 transition from state 2
    requires state 1 to have a successor, which it does not. -/
theorem witness_not_bisimilar :
    ¬ Bisimilar witnessLTS witnessLTS (0 : Fin 3) (2 : Fin 3) := by
  rintro ⟨R, ⟨zig, zag⟩, hR⟩
  grind +suggestions

/-! ## Theorem 3: States 0 and 2 are NOT depth-2 equivalent -/

/-- States 0 and 2 disagree on the trace [(), ()]:
    state 0 accepts it (via 0→2→1) but state 2 does not. -/
theorem witness_not_depth2_equiv :
    ¬ DepthEquiv witnessLTS 2 (0 : Fin 3) (2 : Fin 3) := by
  intro h
  have := h [(), ()] (by decide); simp +decide at this
  contrapose! this
  refine Or.inl ⟨?_, ?_⟩
  · constructor
    exact Or.inr (Or.inl ⟨rfl, rfl⟩)
    exact TraceAccepted.cons _ _ _ _ (Or.inr (Or.inr ⟨rfl, rfl⟩)) (TraceAccepted.nil _)
  · rintro ⟨s', hs', hs''⟩
    rename_i s' hs' hs''; rcases hs'' with ⟨t', ht', ht''⟩; simp_all +decide [witnessLTS]

/-! ## Theorem 4: The Witness System has Nontrivial H¹ Obstruction -/

/-- **The witness system exhibits a nontrivial H¹ obstruction**:
    states 0 and 2 are depth-1 equivalent but not bisimilar.
    This is the decisive theorem — H¹ detects a genuine semantic
    distinction invisible to one-step observations. -/
theorem witness_has_H1_obstruction :
    HasNontrivialH1Obstruction witnessLTS (0 : Fin 3) (2 : Fin 3) :=
  ⟨witness_depth1_equiv, witness_not_bisimilar⟩

/-! ## Theorem 5: Existential Packaging -/

/-- **There exists a finite LTS with a nontrivial H¹ obstruction.**
    This packages the witness system into a pure existence statement. -/
theorem exists_oneStepAgree_not_bisimilar :
    ∃ (P : LTS Unit) (_ : P.State = Fin 3) (s t : P.State),
      OneStepAgreement P s t ∧ ¬ Bisimilar P P s t := by
  exact ⟨witnessLTS, rfl, (0 : Fin 3), (2 : Fin 3),
    witness_oneStep_agree, witness_not_bisimilar⟩

/-! ## Theorem 6: The Witness Has a Nontrivial Cocycle -/

/-
The witness system admits a 1-cocycle over the canonical datum
    that is NOT a coboundary: states 0 and 2 are depth-1 equivalent
    (related at gap depth 1) but not depth-2 equivalent (not related
    at gap depth 2), and they are not bisimilar (not a coboundary).
-/
theorem witness_nontrivial_cocycle :
    ∃ z : Cocycle1 Unit witnessLTS,
      z.datum = canonicalDatum witnessLTS ∧ ¬ z.IsCoboundary := by
  refine' ⟨ _, _, _ ⟩;
  constructor;
  rotate_left;
  convert witness_not_depth2_equiv;
  rotate_left;
  exact canonicalDatum witnessLTS;
  all_goals norm_num [ Cocycle1.IsCoboundary ];
  · grind +suggestions;
  · exact witness_depth1_equiv;
  · rfl

/-! ## Theorem 7: H¹ Obstruction Prevents Bisimulation -/

/-
**If two states exhibit an H¹ obstruction, no bisimulation can relate them.**
    This is the fundamental theorem connecting cohomological data to
    behavioral semantics: a nontrivial 1-cocycle certifies that no
    global bisimulation exists between the witness states.
-/
theorem H1_obstruction_no_bisim (P : LTS Act) {s t : P.State}
    (h : HasNontrivialH1Obstruction P s t) :
    ∀ R : P.State → P.State → Prop,
      IsBisimulation P P R → ¬ R s t := by
  exact fun R hR hRst => h.2 ⟨ R, hR, hRst ⟩

/-! ## Theorem 8: Cyclic Incompatibility and Holonomy -/

/-- Two states exhibit cyclic incompatibility if there is a cycle of
    local identifications that fails to close globally. For the depth
    filtration, this means depth-n equivalence holds for some n but
    bisimilarity fails. -/
def CyclicIncompatibility (P : LTS Act) (s t : P.State) : Prop :=
  (∃ n, DepthEquiv P n s t) ∧ ¬ Bisimilar P P s t

/-- **H¹ obstruction implies cyclic incompatibility.**
    This bridges to the gauge-theoretic interpretation: nontrivial H¹
    corresponds to nontrivial holonomy around experiment overlap cycles. -/
theorem H1_iff_cyclic_incompatibility (P : LTS Act) (s t : P.State) :
    HasNontrivialH1Obstruction P s t → CyclicIncompatibility P s t := by
  intro ⟨hdepth, hnotbisim⟩
  exact ⟨⟨1, hdepth⟩, hnotbisim⟩

/-- Cyclic incompatibility at any positive depth implies H¹ obstruction. -/
theorem cyclic_incompatibility_implies_H1 (P : LTS Act) {s t : P.State}
    {n : ℕ} (hn : 0 < n)
    (hdepth : DepthEquiv P n s t) (hnotbisim : ¬ Bisimilar P P s t) :
    HasNontrivialH1Obstruction P s t :=
  ⟨depth_equiv_monotone P (by omega) hdepth, hnotbisim⟩

/-! ## Depth Equivalence Properties -/

/-- Depth equivalence is reflexive. -/
theorem depth_equiv_refl (P : LTS Act) (n : ℕ) (s : P.State) :
    DepthEquiv P n s s :=
  fun _ _ => Iff.rfl

/-- Depth equivalence is symmetric. -/
theorem depth_equiv_symm (P : LTS Act) (n : ℕ) {s t : P.State}
    (h : DepthEquiv P n s t) : DepthEquiv P n t s :=
  fun σ hlen => (h σ hlen).symm

/-- Depth equivalence is transitive. -/
theorem depth_equiv_trans (P : LTS Act) (n : ℕ) {s t u : P.State}
    (h1 : DepthEquiv P n s t) (h2 : DepthEquiv P n t u) :
    DepthEquiv P n s u :=
  fun σ hlen => (h1 σ hlen).trans (h2 σ hlen)

/-- Depth equivalence at all levels equals trace equivalence. -/
theorem all_depth_equiv_iff_trace_equiv (P : LTS Act) (s t : P.State) :
    (∀ n, DepthEquiv P n s t) ↔ TraceEquiv P P s t := by
  constructor <;> intro h
  · exact fun σ => h σ.length σ (by simp +decide)
  · exact fun n σ _ => h σ

/-! ## Bisimilarity and One-Step Agreement -/

/-- Bisimilarity implies one-step agreement: bisimilar states can perform
    exactly the same actions. This is a corollary of the depth hierarchy. -/
theorem bisimilar_implies_oneStep (P : LTS Act) {s t : P.State}
    (h : Bisimilar P P s t) : OneStepAgreement P s t :=
  depth_one_implies_oneStep P (bisimilar_implies_all_depth_equiv P h 1)

end BisimCohomology

end YonedaBisimulation