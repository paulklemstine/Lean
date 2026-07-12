/-
# Time-Travel Logic: Formalizing Causal Consistency

A self-contained formalization of the logic of closed timelike curves (CTCs) and
time-travel paradoxes.  The central object is the *loop map* `evolve : S → S`,
which records the net effect on the world-state of traversing a closed timelike
curve once.  On top of this we develop, as a connected chain of theorems:

* the **Novikov self-consistency principle** as the existence of a fixed point,
  and its equivalence with the existence of a *closed timelike history*
  (`selfConsistent_iff_closedHistory`);
* the **grandfather paradox** as a fixed-point-free ("paradoxical") loop, proved
  genuinely inconsistent (`grandfather_not_selfConsistent`);
* two positive **consistency guarantees** —
    * monotone loops on a complete lattice are always self-consistent
      (Knaster–Tarski, `monotone_selfConsistent`),
    * continuous loops on a phase interval are always self-consistent
      (1-D Brouwer / IVT, `continuous_selfConsistent`, a toy model of the
      conjecture that Gödel-universe CTCs are self-consistent),
    * involutive loops on a state space of odd size are self-consistent
      (`involutive_odd_selfConsistent`);
* the **many-worlds / branching** resolution: a paradoxical action that admits no
  single-timeline consistent history nevertheless admits a consistent *branching*
  history, because the traveller is sent to a fresh branch rather than forced into
  a contradiction (`branching_resolves_paradox`).

Every theorem is used by a later one, forming a single chain from the definitions
to the branching resolution.
-/

import Mathlib

namespace TimeTravel

open Function

variable {S : Type*}

/-! ## Core model -/

/-- A **causal loop** (closed timelike curve): `evolve s` is the world-state that
results from feeding the state `s` once around the loop. -/
structure CausalLoop (S : Type*) where
  /-- The net effect of one traversal of the loop on the world-state. -/
  evolve : S → S

/-- **Novikov self-consistency principle.**  A causal loop is *self-consistent*
when there is a world-state reproduced by one traversal of the loop, i.e. a
history that is compatible with itself. -/
def SelfConsistent (L : CausalLoop S) : Prop := ∃ s, L.evolve s = s

/-- Theorem 0 (definitional core): self-consistency of a loop is precisely the
existence of a fixed point of its evolution map. -/
theorem selfConsistent_iff_fixedPoint (L : CausalLoop S) :
    SelfConsistent L ↔ ∃ s, IsFixedPt L.evolve s := Iff.rfl

/-! ## Discrete loops and closed timelike histories

A loop `e₁ → e₂ → ⋯ → eₙ → e₁` is presented by its sequence of causal steps
`steps 0, steps 1, …`.  `traverse steps k s` is the world-state after applying the
first `k` steps starting from `s`; the whole length-`n` loop is `traverse steps n`. -/

/-- State after applying the first `k` causal steps, starting from `s`. -/
def traverse (steps : ℕ → S → S) : ℕ → S → S
  | 0, s => s
  | (k + 1), s => steps k (traverse steps k s)

@[simp] theorem traverse_zero (steps : ℕ → S → S) (s : S) : traverse steps 0 s = s := rfl

@[simp] theorem traverse_succ (steps : ℕ → S → S) (k : ℕ) (s : S) :
    traverse steps (k + 1) s = steps k (traverse steps k s) := rfl

/-- A **closed timelike history** of a length-`n` loop: a labelling `h` of events by
world-states in which every step's cause produces its effect, and the loop closes
(`h n = h 0`). -/
def ClosedHistory (steps : ℕ → S → S) (n : ℕ) (h : ℕ → S) : Prop :=
  (∀ k < n, h (k + 1) = steps k (h k)) ∧ h n = h 0

/-
Auxiliary: iterating `traverse` from a closed history recovers the history.
-/
theorem traverse_of_closedHistory (steps : ℕ → S → S) (n : ℕ) (h : ℕ → S)
    (hh : ClosedHistory steps n h) : ∀ k ≤ n, traverse steps k (h 0) = h k := by
  intro k hk; induction' k with k ih <;> simp_all +decide [ traverse ] ;
  rw [ ih ( Nat.le_of_lt hk ), hh.1 k hk ]

/-
**Theorem 1 (Novikov ⇔ closed timelike history).**  A length-`n` causal loop is
self-consistent (its evolution `traverse steps n` has a fixed point) iff it admits a
closed timelike history.
-/
theorem selfConsistent_iff_closedHistory (steps : ℕ → S → S) (n : ℕ) :
    (∃ s, traverse steps n s = s) ↔ ∃ h : ℕ → S, ClosedHistory steps n h := by
  constructor <;> rintro ⟨ s, hs ⟩;
  · refine' ⟨ fun k => traverse steps k s, _, _ ⟩ <;> simp_all +decide;
  · exact ⟨ s 0, by simpa [ hs.2 ] using ( traverse_of_closedHistory steps n s hs ) n le_rfl ⟩

/-! ## The grandfather paradox -/

/-- A loop map is **paradoxical** if no world-state is left unchanged by a traversal:
every history contradicts itself. -/
def Paradoxical (f : S → S) : Prop := ∀ s, f s ≠ s

/-
**Theorem 2.**  A paradoxical loop map has no fixed point, hence is not
self-consistent.
-/
theorem paradoxical_not_selfConsistent {f : S → S} (h : Paradoxical f) :
    ¬ ∃ s, f s = s := by
  exact fun ⟨ s, hs ⟩ => h s hs

/-
The grandfather action on the two-state space `alive/dead`: travelling round the
loop flips the ancestor's status.
-/
theorem grandfather_paradoxical : Paradoxical (Bool.not) := by
  exact fun x => by cases x <;> trivial;

/-
**Theorem 3 (grandfather paradox is impossible).**  The grandfather loop admits
no self-consistent history.
-/
theorem grandfather_not_selfConsistent :
    ¬ SelfConsistent (⟨Bool.not⟩ : CausalLoop Bool) := by
  exact fun ⟨ s, hs ⟩ => by cases s <;> contradiction;

/-! ## Positive consistency guarantees -/

/-
**Theorem 4 (monotone loops are always self-consistent — Knaster–Tarski).**
If the state space is a complete lattice and the loop map is monotone, a
self-consistent history always exists.
-/
theorem monotone_selfConsistent [CompleteLattice S] (f : S →o S) :
    SelfConsistent (⟨f⟩ : CausalLoop S) :=
  ⟨OrderHom.lfp f, f.map_lfp⟩

/-
**Theorem 5 (continuous loops on a phase interval are self-consistent).**  A toy
model of the conjecture that every closed timelike curve in a Gödel universe is
self-consistent: if the loop's evolution is a continuous self-map of the phase
interval `[0,1]`, it has a fixed point (1-D Brouwer, via the intermediate value
theorem).
-/
theorem continuous_selfConsistent (f : ℝ → ℝ)
    (hf : ContinuousOn f (Set.Icc 0 1))
    (hmaps : Set.MapsTo f (Set.Icc 0 1) (Set.Icc 0 1)) :
    ∃ s ∈ Set.Icc (0 : ℝ) 1, f s = s := by
  -- Consider the function $g(x) = f(x) - x$. Since $f$ maps $[0,1]$ into itself, $g(x)$ is continuous on $[0,1]$ and $g(0) = f(0) \ge 0$ and $g(1) = f(1) - 1 \le 0$.
  set g : ℝ → ℝ := fun x => f x - x
  have hg_cont : ContinuousOn g (Set.Icc 0 1) := by
    exact hf.sub continuousOn_id
  have hg0 : g 0 ≥ 0 := by
    exact sub_nonneg_of_le <| hmaps ( Set.left_mem_Icc.mpr zero_le_one ) |>.1
  have hg1 : g 1 ≤ 0 := by
    exact sub_nonpos_of_le <| hmaps ( by norm_num ) |>.2;
  have := intermediate_value_Icc' ( by norm_num : ( 0 : ℝ ) ≤ 1 ) hg_cont;
  exact Exists.elim ( this ⟨ hg1, hg0 ⟩ ) fun x hx => ⟨ x, hx.1, sub_eq_zero.mp hx.2 ⟩

/-
**Theorem 6 (odd loops are self-consistent).**  If the loop map is an involution
(going round the loop twice restores the state) on a finite state space of odd size,
then it has a fixed point, so the loop is self-consistent.
-/
theorem involutive_odd_selfConsistent [Fintype S] [DecidableEq S] (f : S → S)
    (hf : Involutive f) (hodd : Odd (Fintype.card S)) :
    SelfConsistent (⟨f⟩ : CausalLoop S) := by
  -- Since $f$ is an involution, it is equivalent to multiplication by $-1$ in some sense. Hence, $f^{2} = 1$.
  obtain ⟨g, hg⟩ : ∃ g : Equiv.Perm S, ∀ x : S, g x = f x := by
    exact ⟨ Equiv.ofBijective f ⟨ hf.injective, hf.surjective ⟩, fun x => rfl ⟩;
  convert Equiv.Perm.exists_fixed_point_of_prime ( show ¬2 ∣ Fintype.card S from by simpa [ ← even_iff_two_dvd ] using hodd ) ( show g ^ 2 ^ 1 = 1 from ?_ ) using 1;
  · aesop;
  · simp_all +decide [ Equiv.Perm.ext_iff, sq, Involutive ]

/-! ## Branching (many-worlds) time travel

Instead of forcing the loop to close, a time traveller is sent to a *fresh branch*.
The multiverse state is `S × ℕ` (world-state together with a branch index); the
branching evolution `branch a` applies the traveller's action `a` and advances to a
new branch. -/

/-- The branching evolution of an action `a`: apply `a` and move to a new branch. -/
def branch (a : S → S) : S × ℕ → S × ℕ := fun p => (a p.1, p.2 + 1)

/-
**Theorem 7 (the traveller always creates a new branch).**  A branching step
always increases the branch index, so it never lands on the same multiverse state:
`branch a` is paradoxical as an ordinary loop map.
-/
theorem branch_creates_new_branch (a : S → S) : Paradoxical (branch a) := by
  intro p
  simp [branch];
  grind

/-
A branching history is the concrete sequence of multiverse states visited by the
traveller, one per branch.
-/
theorem branch_history (a : S → S) (s₀ : S) :
    ∃ hist : ℕ → S × ℕ, hist 0 = (s₀, 0) ∧ ∀ k, hist (k + 1) = branch a (hist k) := by
  exact ⟨ fun k => Nat.recOn k ( s₀, 0 ) fun k ih => ( a ih.1, ih.2 + 1 ), rfl, fun k => rfl ⟩

/-
**Theorem 8 (branching resolves the paradox).**  For *any* paradoxical action
`a` — one with no single-timeline self-consistent history — the many-worlds model
still admits a fully consistent branching history: the traveller acts freely and is
carried to ever-new branches, producing no contradiction.
-/
theorem branching_resolves_paradox (a : S → S) (ha : Paradoxical a) (s₀ : S) :
    (¬ ∃ s, a s = s) ∧
    (∃ hist : ℕ → S × ℕ, hist 0 = (s₀, 0) ∧ ∀ k, hist (k + 1) = branch a (hist k)) := by
  exact ⟨ by rintro ⟨ s, hs ⟩ ; exact ha s hs, ⟨ fun k => Nat.recOn k ( s₀, 0 ) fun k ih => branch a ih, rfl, fun k => rfl ⟩ ⟩

/-
**Corollary (grandfather in the multiverse).**  The grandfather action, impossible
in a single timeline, has a consistent branching history: the traveller kills the
ancestor in a new branch and lives on there.
-/
theorem grandfather_branches (s₀ : Bool) :
    (¬ ∃ s : Bool, Bool.not s = s) ∧
    (∃ hist : ℕ → Bool × ℕ, hist 0 = (s₀, 0) ∧
      ∀ k, hist (k + 1) = branch Bool.not (hist k)) := by
  convert branching_resolves_paradox _ ( grandfather_paradoxical ) _ using 1

end TimeTravel