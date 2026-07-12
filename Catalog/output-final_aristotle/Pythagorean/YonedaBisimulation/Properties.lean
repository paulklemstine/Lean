import Mathlib

/-!
# Labeled Transition Systems, Traces, and Bisimulation

This file provides the foundational theory of labeled transition systems (LTS),
their trace semantics, and (strong) bisimulation, used as the semantic base for
the cohomological analysis of behavioral equivalence.

## Main Definitions

* `LTS` — a labeled transition system: a state type together with a labeled
  transition relation.
* `Trace` — a finite sequence of actions.
* `TraceAccepted` — the predicate that a state can perform a given trace.
* `TraceEquiv` — trace (language) equivalence between states of two systems.
* `IsBisimulation` — the (symmetric) transfer property of a relation.
* `Bisimilar` — existence of a bisimulation relating two states.

## Main Results

* `bisimilar_refl`, `bisimilar_symm`, `bisimilar_trans` — bisimilarity is an
  equivalence relation on the states of a single system.
* `bisimilar_implies_trace_equiv` — bisimilar states are trace equivalent.
-/

namespace YonedaBisimulation

/-- A labeled transition system over an action alphabet `Act`. -/
structure LTS (Act : Type*) where
  /-- The type of states. -/
  State : Type*
  /-- The labeled transition relation `step s a t`: from `s`, on action `a`, to `t`. -/
  step : State → Act → State → Prop

/-- A trace is a finite word of actions. -/
abbrev Trace (Act : Type*) := List Act

variable {Act : Type*}

/-- `TraceAccepted P s σ` holds when the state `s` can perform the whole trace `σ`,
    following the transition relation of `P` step by step. -/
inductive TraceAccepted (P : LTS Act) : P.State → Trace Act → Prop
  /-- Every state accepts the empty trace. -/
  | nil (s : P.State) : TraceAccepted P s []
  /-- If `s` steps to `s'` on `a` and `s'` accepts `rest`, then `s` accepts `a :: rest`. -/
  | cons (s : P.State) (a : Act) (rest : Trace Act) (s' : P.State)
      (hstep : P.step s a s') (hrest : TraceAccepted P s' rest) :
      TraceAccepted P s (a :: rest)

/-- Two states (possibly of different systems) are trace equivalent if they accept
    exactly the same traces. -/
def TraceEquiv (P Q : LTS Act) (s : P.State) (t : Q.State) : Prop :=
  ∀ σ : Trace Act, TraceAccepted P s σ ↔ TraceAccepted Q t σ

/-- A relation `R` between the states of `P` and `Q` is a bisimulation if it satisfies
    the symmetric transfer ("zig"/"zag") conditions. -/
def IsBisimulation (P Q : LTS Act) (R : P.State → Q.State → Prop) : Prop :=
  (∀ s t a s', R s t → P.step s a s' → ∃ t', Q.step t a t' ∧ R s' t') ∧
  (∀ s t a t', R s t → Q.step t a t' → ∃ s', P.step s a s' ∧ R s' t')

/-- Two states are bisimilar if some bisimulation relates them. -/
def Bisimilar (P Q : LTS Act) (s : P.State) (t : Q.State) : Prop :=
  ∃ R : P.State → Q.State → Prop, IsBisimulation P Q R ∧ R s t

/-- Bisimilarity is reflexive: equality is a bisimulation. -/
theorem bisimilar_refl (P : LTS Act) : ∀ s : P.State, Bisimilar P P s s := by
  intro s
  refine ⟨Eq, ⟨?_, ?_⟩, rfl⟩
  · rintro s t a s' rfl hstep; exact ⟨s', hstep, rfl⟩
  · rintro s t a t' rfl hstep; exact ⟨t', hstep, rfl⟩

/-- Bisimilarity is symmetric. -/
theorem bisimilar_symm {P : LTS Act} {s t : P.State}
    (h : Bisimilar P P s t) : Bisimilar P P t s := by
  obtain ⟨R, ⟨zig, zag⟩, hst⟩ := h
  refine ⟨fun a b => R b a, ⟨?_, ?_⟩, hst⟩
  · intro s' t' a s'' hR hstep
    obtain ⟨u, hu, hRu⟩ := zag t' s' a s'' hR hstep
    exact ⟨u, hu, hRu⟩
  · intro s' t' a t'' hR hstep
    obtain ⟨u, hu, hRu⟩ := zig t' s' a t'' hR hstep
    exact ⟨u, hu, hRu⟩

/-- Bisimilarity is transitive. -/
theorem bisimilar_trans {P : LTS Act} {s t u : P.State}
    (h1 : Bisimilar P P s t) (h2 : Bisimilar P P t u) : Bisimilar P P s u := by
  obtain ⟨R1, ⟨zig1, zag1⟩, h1st⟩ := h1
  obtain ⟨R2, ⟨zig2, zag2⟩, h2tu⟩ := h2
  refine ⟨fun a c => ∃ b, R1 a b ∧ R2 b c, ⟨?_, ?_⟩, ⟨t, h1st, h2tu⟩⟩
  · rintro a c act a' ⟨b, hR1, hR2⟩ hstep
    obtain ⟨b', hb', hR1'⟩ := zig1 a b act a' hR1 hstep
    obtain ⟨c', hc', hR2'⟩ := zig2 b c act b' hR2 hb'
    exact ⟨c', hc', b', hR1', hR2'⟩
  · rintro a c act c' ⟨b, hR1, hR2⟩ hstep
    obtain ⟨b', hb', hR2'⟩ := zag2 b c act c' hR2 hstep
    obtain ⟨a', ha', hR1'⟩ := zag1 a b act b' hR1 hb'
    exact ⟨a', ha', b', hR1', hR2'⟩

/-- Bisimilar states are trace equivalent. -/
theorem bisimilar_implies_trace_equiv {P Q : LTS Act} {s : P.State} {t : Q.State}
    (h : Bisimilar P Q s t) : TraceEquiv P Q s t := by
  obtain ⟨R, ⟨zig, zag⟩, hst⟩ := h
  intro σ
  induction σ generalizing s t with
  | nil => exact ⟨fun _ => TraceAccepted.nil t, fun _ => TraceAccepted.nil s⟩
  | cons a rest ih =>
    constructor
    · rintro (_ | ⟨_, _, _, s', hstep, hrest⟩)
      obtain ⟨t', ht', hR'⟩ := zig s t a s' hst hstep
      exact TraceAccepted.cons t a rest t' ht' ((ih hR').mp hrest)
    · rintro (_ | ⟨_, _, _, t', hstep, hrest⟩)
      obtain ⟨s', hs', hR'⟩ := zag s t a t' hst hstep
      exact TraceAccepted.cons s a rest s' hs' ((ih hR').mpr hrest)

end YonedaBisimulation