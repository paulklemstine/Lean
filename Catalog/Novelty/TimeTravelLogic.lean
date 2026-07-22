import Mathlib

/-!
# A small mathematics of causal loops and branching timelines

This file deliberately separates three notions which informal discussions often conflate:
periodicity, pointwise self-consistency, and existence of a fixed point.  For a deterministic
causal update `step`, a closed causal history is a periodic point.  Novikov consistency says
that every state visited by that history is unchanged by `step`.

The central result is a collapse theorem: if the causal update is idempotent, every nonempty
closed history collapses to a fixed point.  Idempotence is essential; Boolean negation gives a
closed history of every even length but has no fixed point.  This same example yields a precise
formal grandfather-paradox no-go theorem.

Finally, histories represented by finite lists give a minimal branching-timeline model.  A
traveller's intervention appends a new event, creating a strict descendant rather than changing
its ancestor.  Strict descent is irreflexive, so this construction cannot create a causal loop.
-/

namespace TimeTravel

/-- A deterministic causal law maps the present event-state to its causal successor. -/
abbrev CausalLaw (α : Type*) := α → α

/-- A state closes after `period` causal steps. -/
def ClosedOrbit (step : CausalLaw α) (period : ℕ) (start : α) : Prop :=
  step^[period] start = start

/-- Every event-state encountered before closure is itself stable under the causal law. -/
def NovikovConsistent (step : CausalLaw α) (period : ℕ) (start : α) : Prop :=
  ∀ k < period, step (step^[k] start) = step^[k] start

/-- The loop contains a fixed point among the states it visits. -/
def LoopHasFixedPoint (step : CausalLaw α) (period : ℕ) (start : α) : Prop :=
  ∃ k < period, step (step^[k] start) = step^[k] start

/-- Full Novikov consistency always supplies a fixed point in a nonempty loop. -/
theorem novikov_implies_loop_fixed_point {step : CausalLaw α} {period : ℕ} {start : α}
    (positive : 0 < period) (consistent : NovikovConsistent step period start) :
    LoopHasFixedPoint step period start := by
  exact ⟨0, positive, consistent 0 positive⟩

/-- If the starting event is fixed, every event in its finite orbit is the same fixed event. -/
theorem fixed_start_implies_novikov {step : CausalLaw α} {period : ℕ} {start : α}
    (fixed : step start = start) : NovikovConsistent step period start := by
  intro k hk
  have orbit : ∀ n : ℕ, step^[n] start = start := by
    intro n
    induction n with
    | zero => rfl
    | succ n ih => simp only [Function.iterate_succ_apply, ih, fixed]
  rw [orbit k, fixed]

/-- If a closed deterministic loop contains one fixed event, closure forces its starting event
to be that same fixed event. -/
theorem loop_fixed_point_forces_fixed_start {step : CausalLaw α} {period : ℕ} {start : α}
    (closed : ClosedOrbit step period start) (hasFixed : LoopHasFixedPoint step period start) :
    step start = start := by
  obtain ⟨k, hk, hfixed⟩ := hasFixed
  have tail : ∀ n : ℕ, step^[n] (step^[k] start) = step^[k] start := by
    intro n
    induction n with
    | zero => rfl
    | succ n ih => rw [Function.iterate_succ_apply', ih, hfixed]
  have decomposition : step^[period] start = step^[period - k] (step^[k] start) := by
    rw [← Function.iterate_add_apply]
    congr 1
    omega
  have period_eq_point : step^[period] start = step^[k] start :=
    decomposition.trans (tail (period - k))
  have point_eq_start : step^[k] start = start := (closed.symm.trans period_eq_point).symm
  rw [← point_eq_start]
  exact hfixed

/-- **Novikov fixed-point equivalence.** On any nonempty deterministic closed causal loop,
pointwise self-consistency is equivalent to the loop containing a fixed point. -/
theorem novikov_iff_loop_has_fixed_point {step : CausalLaw α} {period : ℕ} {start : α}
    (positive : 0 < period) (closed : ClosedOrbit step period start) :
    NovikovConsistent step period start ↔ LoopHasFixedPoint step period start := by
  constructor
  · exact novikov_implies_loop_fixed_point positive
  · intro hasFixed
    exact fixed_start_implies_novikov (loop_fixed_point_forces_fixed_start closed hasFixed)

/-- A causal law is idempotent when applying it twice has the same effect as once. -/
def Idempotent (step : CausalLaw α) : Prop := ∀ x, step (step x) = step x

/-- Under an idempotent causal law, taking at least one step always lands at a fixed point. -/
theorem iterate_fixed_of_idempotent {step : CausalLaw α}
    (idempotent : Idempotent step) {n : ℕ} (positive : 0 < n) (start : α) :
    step (step^[n] start) = step^[n] start := by
  have after_first : ∀ m : ℕ, step^[m] (step start) = step start := by
    intro m
    induction m with
    | zero => rfl
    | succ m ih => rw [Function.iterate_succ_apply', ih, idempotent]
  obtain ⟨m, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (Nat.ne_of_gt positive)
  rw [Function.iterate_succ_apply, after_first, idempotent]

/-- **Causal-loop collapse.** An idempotent deterministic law admits no nontrivial closed
orbit: every positive-period closed orbit starts at a fixed point. -/
theorem closed_orbit_collapses {step : CausalLaw α}
    (idempotent : Idempotent step) {period : ℕ} (positive : 0 < period) {start : α}
    (closed : ClosedOrbit step period start) : step start = start := by
  have stable := iterate_fixed_of_idempotent idempotent positive start
  rw [closed] at stable
  exact stable

/-- In the idempotent setting, Novikov consistency, a fixed starting point, and a fixed point
somewhere on a positive closed loop are equivalent. -/
theorem novikov_iff_fixed_point_of_idempotent {step : CausalLaw α}
    (idempotent : Idempotent step) {period : ℕ} (positive : 0 < period) {start : α}
    (closed : ClosedOrbit step period start) :
    NovikovConsistent step period start ↔
      step start = start ∧ LoopHasFixedPoint step period start := by
  constructor
  · intro h
    have fixed := closed_orbit_collapses idempotent positive closed
    exact ⟨fixed, novikov_implies_loop_fixed_point positive h⟩
  · rintro ⟨fixed, _⟩
    exact fixed_start_implies_novikov fixed

section Grandfather

/-- The minimal grandfather intervention flips whether the ancestor survives. -/
def grandfatherStep : Bool → Bool := fun alive => !alive

/-- The grandfather update has no self-consistent state. -/
theorem grandfather_no_fixed_point : ¬ ∃ state, grandfatherStep state = state := by
  intro h
  obtain ⟨state, hstate⟩ := h
  cases state <;> simp [grandfatherStep] at hstate

/-- An even number of grandfather interventions restores the original state. -/
theorem grandfather_even_iterate (k : ℕ) (state : Bool) :
    grandfatherStep^[2 * k] state = state := by
  induction k with
  | zero => rfl
  | succ k ih =>
      rw [Nat.mul_succ, Function.iterate_add_apply]
      have two_steps : grandfatherStep^[2] state = state := by
        cases state <;> rfl
      rw [two_steps]
      exact ih

/-- A stronger no-go statement: no odd number of grandfather interventions can close a loop. -/
theorem grandfather_odd_period_impossible {period : ℕ} (odd : Odd period) (state : Bool) :
    ¬ ClosedOrbit grandfatherStep period state := by
  rintro closed
  obtain ⟨k, rfl⟩ := odd
  unfold ClosedOrbit at closed
  rw [show 2 * k + 1 = 1 + 2 * k by omega,
    Function.iterate_add_apply, grandfather_even_iterate] at closed
  cases state <;> simp [grandfatherStep] at closed

/-- Even periodicity alone does not imply consistency: two flips return to the initial state. -/
theorem grandfather_two_step_closed (state : Bool) :
    ClosedOrbit grandfatherStep 2 state := by
  simpa [ClosedOrbit] using grandfather_even_iterate 1 state

/-- Nevertheless that two-step loop is not Novikov-consistent. -/
theorem grandfather_two_step_inconsistent (state : Bool) :
    ¬ NovikovConsistent grandfatherStep 2 state := by
  intro h
  have hzero := h 0 (by omega)
  cases state <;> simp [grandfatherStep] at hzero

/-- Consequently the grandfather law is not idempotent, pinpointing why the collapse theorem's
hypothesis cannot be omitted. -/
theorem grandfather_not_idempotent : ¬ Idempotent grandfatherStep := by
  intro h
  have := h false
  simp [grandfatherStep] at this

end Grandfather

section Branching

/-- A timeline is its finite sequence of events. Different continuations of one history are
literally different list values. -/
abbrev Timeline (Event : Type*) := List Event

/-- Time travel does not overwrite the source history: it creates a child branch. -/
def travel (source : Timeline Event) (intervention : Event) : Timeline Event :=
  source ++ [intervention]

/-- `ancestor a b` means that `a` is an initial segment of `b`. -/
def Ancestor (a b : Timeline Event) : Prop := a <+: b

/-- Proper causal descent is prefix descent together with inequality. -/
def StrictDescendant (child parent : Timeline Event) : Prop :=
  Ancestor parent child ∧ parent ≠ child

/-- A travel event preserves the entire source timeline as an ancestor. -/
theorem source_ancestor_of_travel (source : Timeline Event) (intervention : Event) :
    Ancestor source (travel source intervention) := by
  exact ⟨[intervention], rfl⟩

/-- The new branch has exactly one more event than its source. -/
theorem travel_length (source : Timeline Event) (intervention : Event) :
    (travel source intervention).length = source.length + 1 := by
  simp [travel]

/-- Thus a traveller creates a genuinely new branch, never the same timeline. -/
theorem travel_creates_new_branch (source : Timeline Event) (intervention : Event) :
    travel source intervention ≠ source := by
  intro equal
  have lengths := congrArg List.length equal
  simp [travel] at lengths

/-- The created branch is a strict causal descendant of the source. -/
theorem travel_strict_descendant (source : Timeline Event) (intervention : Event) :
    StrictDescendant (travel source intervention) source := by
  exact ⟨source_ancestor_of_travel source intervention,
    (travel_creates_new_branch source intervention).symm⟩

/-- Strict branch descent is transitive. -/
theorem strictDescendant_trans {a b c : Timeline Event}
    (hab : StrictDescendant b a) (hbc : StrictDescendant c b) : StrictDescendant c a := by
  rcases hab with ⟨hab, habne⟩
  rcases hbc with ⟨hbc, hbcne⟩
  constructor
  · exact hab.trans hbc
  · intro hac
    subst c
    have lenAB := List.IsPrefix.length_le hab
    have lenBA := List.IsPrefix.length_le hbc
    have : a.length = b.length := Nat.le_antisymm lenAB lenBA
    exact habne (List.IsPrefix.eq_of_length hab this)

/-- No timeline can be its own strict descendant. This is the acyclicity invariant that replaces
paradoxical history-overwriting in the branching model. -/
theorem no_branching_causal_loop (history : Timeline Event) :
    ¬ StrictDescendant history history := by
  intro h
  exact h.2 rfl

/-- Two distinct interventions from the same source create distinct sibling branches. -/
theorem distinct_interventions_create_distinct_branches
    (source : Timeline Event) {x y : Event} (different : x ≠ y) :
    travel source x ≠ travel source y := by
  intro equal
  have tails : [x] = [y] := List.append_cancel_left equal
  exact different (List.singleton_inj.mp tails)

/-- Sibling branches cannot be ancestors of one another: equal-length prefix histories coincide. -/
theorem sibling_branches_incomparable
    (source : Timeline Event) {x y : Event} (different : x ≠ y) :
    (Ancestor (travel source x) (travel source y) → False) ∧
    (Ancestor (travel source y) (travel source x) → False) := by
  constructor
  · intro hpre
    have equal := List.IsPrefix.eq_of_length hpre (by simp [travel])
    exact distinct_interventions_create_distinct_branches source different equal
  · intro hpre
    have equal := List.IsPrefix.eq_of_length hpre (by simp [travel])
    exact distinct_interventions_create_distinct_branches source different equal.symm

end Branching

end TimeTravel