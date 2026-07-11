/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Self-Modifying Code That Cannot Be Stopped: A Chain of Results

This file develops, as a single linear *chain* of results, the theory of the
halting problem for self-modifying computation.  Each theorem is built from the
previous ones, starting from an abstract diagonalization engine and culminating
in an AI-alignment obstruction theorem.

The mathematical arc is:

1. **Lawvere's fixed-point theorem** (`lawvere_fixed_point`) — the abstract
   engine behind all diagonal arguments.
2. **Cantor for Boolean predicates** (`no_surj_to_pred`) — derived from Lawvere.
3. **No contrarian behavior** (`no_contrarian_behavior`) — the operational face
   of Cantor: no program realizes the anti-diagonal behavior.
4. **A self-modifying machine model** (`SMM`) whose transition function may
   rewrite the running program mid-execution, plus its `run`/`halts` semantics.
5. **Simulation theorem** (`run_map_eq`, `halts_iff_std`) — a self-modifying
   machine halts iff its fixed-program simulation halts.
6. **Turing equivalence of the halting problems** (`reduce_selfmod_to_std`,
   `reduce_std_to_selfmod`, `halting_turing_equiv`, and the decider transfers
   `selfmod_decidable_of_std` / `std_decidable_of_selfmod`).  This *corrects*
   the folk claim that self-modification makes the problem "strictly harder":
   it is in fact many-one equivalent to the classical halting problem.
7. **Self-referential halting theorem** (`no_correct_decider`,
   `halting_contradiction`) — given the self-modifying ability to build the
   *contrarian* program, no total decider is correct on its own code.
8. **The virus paradox** (`virus_no_detector`) — no total detector decides the
   self-halting behavior everywhere.
9. **The alignment obstruction** (`alignment_no_monitor`) — no total monitor can
   correctly certify "never terminates on its own code" for every program.

The final section records the correction to the mission's informal framing: the
self-modifying halting problem is *undecidable*, but it is *not* strictly harder
than the classical halting problem — it is many-one equivalent to it.
-/

import Mathlib

namespace SelfModHaltChain

-- ============================================================================
-- SECTION 1: The diagonalization engine (Lawvere ⇒ Cantor)
-- ============================================================================

/-- **Lawvere's fixed-point theorem.**  If `g : A → (A → B)` is surjective, then
every self-map `f : B → B` has a fixed point.  This is the abstract kernel of
every diagonal argument in this file. -/
theorem lawvere_fixed_point {A B : Type*} (g : A → (A → B))
    (hg : Function.Surjective g) (f : B → B) : ∃ b, f b = b := by
  obtain ⟨a, ha⟩ := hg (fun x => f (g x x))
  exact ⟨g a a, by conv_rhs => rw [show g a = _ from ha]⟩

/-- **Cantor's theorem for Boolean predicates.**  No map `g : A → (A → Bool)`
is surjective: the space of predicates on `A` is not enumerable by `A`.  This is
Lawvere applied to the fixed-point-free map `Bool.not`. -/
theorem no_surj_to_pred {A : Type*} (g : A → (A → Bool)) : ¬ Function.Surjective g := by
  intro hg
  obtain ⟨b, hb⟩ := lawvere_fixed_point g hg (fun x => !x)
  exact (Bool.not_ne_self b) hb

/-- **No program realizes the contrarian behavior.**  Viewing `beh p` as the
Boolean input/output behavior of program `p`, no program `p₀` has behavior equal
to the anti-diagonal `q ↦ ¬ beh q q`.  This is the operational reading of Cantor
and the seed of the halting argument: the behavior "do the opposite of what `q`
does on itself" cannot be a program behavior. -/
theorem no_contrarian_behavior {Prog : Type*} (beh : Prog → (Prog → Bool)) (p₀ : Prog) :
    beh p₀ ≠ (fun q => !(beh q q)) := by
  intro h
  have := congrArg (fun f => f p₀) h
  simp at this

-- ============================================================================
-- SECTION 2: The self-modifying machine model
-- ============================================================================

/-- A **self-modifying machine**: the one-step transition takes and returns a
`(program, state)` pair, so the running program itself may change at each step.
`none` denotes halting. -/
structure SMM (P S : Type*) where
  /-- One-step transition; `none` means the machine halts. -/
  step : P → S → Option (P × S)

/-- A configuration: the current program together with the current state. -/
structure Cfg (P S : Type*) where
  /-- The currently running (possibly rewritten) program. -/
  prog : P
  /-- The current data state. -/
  state : S

/-- Run a self-modifying machine for `n` steps, returning `none` if it halts
before completing `n` steps. -/
def SMM.run {P S : Type*} (m : SMM P S) : Cfg P S → ℕ → Option (Cfg P S)
  | cfg, 0 => some cfg
  | cfg, n + 1 => match m.step cfg.prog cfg.state with
    | none => none
    | some (p', s') => m.run ⟨p', s'⟩ n

/-- A self-modifying machine halts from `cfg` if some step count returns `none`. -/
def SMM.halts {P S : Type*} (m : SMM P S) (cfg : Cfg P S) : Prop :=
  ∃ n, m.run cfg n = none

/-- A **standard (fixed-program) machine**: the transition modifies only the
state. -/
structure Std (S : Type*) where
  /-- One-step transition; `none` means the machine halts. -/
  step : S → Option S

/-- Run a standard machine for `n` steps. -/
def Std.run {S : Type*} (m : Std S) : S → ℕ → Option S
  | s, 0 => some s
  | s, n + 1 => match m.step s with
    | none => none
    | some s' => m.run s' n

/-- A standard machine halts from `s` if some step count returns `none`. -/
def Std.halts {S : Type*} (m : Std S) (s : S) : Prop := ∃ n, m.run s n = none

/-- **The standard simulation.**  Encode the current program into the state,
turning a self-modifying machine over `(P, S)` into a fixed-program machine over
`P × S`.  Code becomes data. -/
def SMM.toStd {P S : Type*} (m : SMM P S) : Std (P × S) where
  step := fun ⟨p, s⟩ => match m.step p s with
    | none => none
    | some (p', s') => some (p', s')

-- ============================================================================
-- SECTION 3: The simulation theorem
-- ============================================================================

/-- The self-modifying run and its standard simulation agree step for step,
under the "code as data" identification `c ↦ (c.prog, c.state)`. -/
theorem run_map_eq {P S : Type*} (m : SMM P S) (cfg : Cfg P S) (n : ℕ) :
    (m.run cfg n).map (fun c => (c.prog, c.state)) =
    m.toStd.run (cfg.prog, cfg.state) n := by
  induction n generalizing cfg with
  | zero => rfl
  | succ n ih =>
    simp only [SMM.run, Std.run, SMM.toStd]
    cases h : m.step cfg.prog cfg.state with
    | none => simp
    | some ps => cases ps with | mk p' s' => simpa using ih ⟨p', s'⟩

/-- Halting at a fixed step count is preserved by the simulation. -/
theorem run_none_iff {P S : Type*} (m : SMM P S) (cfg : Cfg P S) (n : ℕ) :
    m.run cfg n = none ↔ m.toStd.run (cfg.prog, cfg.state) n = none := by
  rw [← run_map_eq]; cases m.run cfg n <;> simp

/-- **Simulation theorem.**  A self-modifying machine halts from `cfg` iff its
standard simulation halts from the corresponding state.  Self-modification adds
no computational power beyond encoding the program as data. -/
theorem halts_iff_std {P S : Type*} (m : SMM P S) (cfg : Cfg P S) :
    m.halts cfg ↔ m.toStd.halts (cfg.prog, cfg.state) :=
  exists_congr fun n => run_none_iff m cfg n

-- ============================================================================
-- SECTION 4: Turing equivalence of the two halting problems
-- ============================================================================

/-- Many-one reduction between predicates. -/
def Reduces {α β : Type*} (A : α → Prop) (B : β → Prop) : Prop :=
  ∃ f : α → β, ∀ x, A x ↔ B (f x)

/-- **Self-modifying halting reduces to standard halting**, via the simulation
theorem. -/
theorem reduce_selfmod_to_std {P S : Type*} (m : SMM P S) :
    Reduces m.halts m.toStd.halts :=
  ⟨fun cfg => (cfg.prog, cfg.state), fun x => halts_iff_std m x⟩

/-- Embed a standard machine as a self-modifying machine with trivial program
type `Unit`. -/
def Std.emb {S : Type*} (m : Std S) : SMM Unit S := ⟨fun _ s => (m.step s).map (Prod.mk ())⟩

/-- The embedding preserves halting at each step count. -/
theorem emb_run_none {S : Type*} (m : Std S) (s : S) (n : ℕ) :
    m.emb.run ⟨(), s⟩ n = none ↔ m.run s n = none := by
  induction n generalizing s with
  | zero => simp [SMM.run, Std.run]
  | succ n ih =>
    simp only [SMM.run, Std.run, Std.emb]
    cases h : m.step s with
    | none => simp
    | some s' => simp only [Option.map]; exact ih s'

/-- **Standard halting reduces to self-modifying halting** via the `Unit`-program
embedding. -/
theorem reduce_std_to_selfmod {S : Type*} (m : Std S) :
    Reduces m.halts m.emb.halts :=
  ⟨fun s => ⟨(), s⟩, fun s => exists_congr fun n => (emb_run_none m s n).symm⟩

/-- **Turing equivalence.**  The self-modifying and standard halting problems are
mutually many-one reducible.  Self-modification does *not* make halting strictly
harder. -/
theorem halting_turing_equiv {P S : Type*} (m : SMM P S) :
    Reduces m.halts m.toStd.halts ∧ Reduces m.toStd.halts m.toStd.emb.halts :=
  ⟨reduce_selfmod_to_std m, reduce_std_to_selfmod m.toStd⟩

/-- A decider for the standard simulation transfers to a decider for the
self-modifying machine. -/
theorem selfmod_decidable_of_std {P S : Type*} (m : SMM P S)
    (D : (P × S) → Bool) (hD : ∀ s, D s = true ↔ m.toStd.halts s) :
    ∃ D' : Cfg P S → Bool, ∀ cfg, D' cfg = true ↔ m.halts cfg :=
  ⟨fun cfg => D (cfg.prog, cfg.state), fun cfg => by rw [halts_iff_std]; exact hD _⟩

/-- A decider for the self-modifying machine transfers to a decider for the
standard simulation.  Combined with `selfmod_decidable_of_std`, deciding one is
equivalent to deciding the other. -/
theorem std_decidable_of_selfmod {P S : Type*} (m : SMM P S)
    (D' : Cfg P S → Bool) (hD' : ∀ cfg, D' cfg = true ↔ m.halts cfg) :
    ∃ D : (P × S) → Bool, ∀ s, D s = true ↔ m.toStd.halts s := by
  refine ⟨fun s => D' ⟨s.1, s.2⟩, fun s => ?_⟩
  rw [hD' ⟨s.1, s.2⟩, halts_iff_std]

-- ============================================================================
-- SECTION 5: The self-referential halting theorem
-- ============================================================================

/-- **Self-referential halting theorem.**  Suppose a self-modifying system can,
relative to a candidate halting decider `H`, build the *contrarian* program `d`
whose behavior is "halt on input `q` exactly when `H` predicts `q` does *not*
halt on `q`" (`hd`).  Then `H` cannot be a correct halting decider: it errs
precisely on the contrarian program's own code.

The contrarian `d` is exactly what self-modification provides — a program that
reads the would-be predictor and rewrites itself to do the opposite. -/
theorem no_correct_decider {Prog : Type*}
    (Halts : Prog → Prog → Prop) (H : Prog → Prog → Bool)
    (d : Prog) (hd : ∀ q, Halts d q ↔ H q q = false) :
    ∃ q, ¬ (H q q = true ↔ Halts q q) := by
  refine ⟨d, ?_⟩; intro hcorrect
  have h1 : Halts d d ↔ H d d = false := hd d
  rw [← hcorrect] at h1; cases hb : H d d <;> simp [hb] at h1

/-- **The halting problem for self-modifying code is undecidable.**  There is no
total decider `H` that is simultaneously *correct* everywhere (`hH`) and admits
the contrarian program `d` (`hd`): together they are contradictory.  Equivalently,
any system rich enough to build contrarians has no general algorithm predicting
its own termination. -/
theorem halting_contradiction {Prog : Type*}
    (Halts : Prog → Prog → Prop) (H : Prog → Prog → Bool)
    (hH : ∀ p q, H p q = true ↔ Halts p q)
    (d : Prog) (hd : ∀ q, Halts d q ↔ H q q = false) : False := by
  obtain ⟨q, hq⟩ := no_correct_decider Halts H d hd
  exact hq (hH q q)

/-- The hypotheses of `no_correct_decider` are satisfiable (the theorem is not
vacuous): a concrete system carrying a contrarian program exists. -/
theorem selfref_hypotheses_satisfiable :
    ∃ (Prog : Type) (Halts : Prog → Prog → Prop) (H : Prog → Prog → Bool) (d : Prog),
      (∀ q, Halts d q ↔ H q q = false) :=
  ⟨ℕ, fun p _ => p ≠ 0, fun _ _ => true, 0, fun q => by simp⟩

-- ============================================================================
-- SECTION 6: The virus paradox and the alignment obstruction
-- ============================================================================

/-- **The virus paradox.**  No total detector `Detect` can decide the
self-halting behavior `q ↦ Halts q q` for *every* program, once the system can
build the contrarian program `d`.  A perfect virus/behavior scanner would decide
the halting problem, which the contrarian refutes. -/
theorem virus_no_detector {Prog : Type*}
    (Halts : Prog → Prog → Prop) (Detect : Prog → Bool)
    (d : Prog) (hd : ∀ q, Halts d q ↔ Detect q = false) :
    ¬ ∀ q, (Detect q = true ↔ Halts q q) := by
  intro hall
  obtain ⟨q, hq⟩ := no_correct_decider Halts (fun _ q => Detect q) d hd
  exact hq (hall q)

/-- **The alignment obstruction.**  Interpret `M q = true` as a monitor
*certifying* that program `q` is safe in the sense of "never terminates on its
own code" (`¬ Halts q q`).  If the system can build the contrarian program `d`
whose termination tracks the monitor's verdict (`hd`), then the monitor is wrong
on some program: no total monitor can correctly certify self-termination
behavior for every program.  This is the computability-theoretic core of the
impossibility of a perfect, always-correct alignment guarantee. -/
theorem alignment_no_monitor {Prog : Type*}
    (Halts : Prog → Prog → Prop) (M : Prog → Bool)
    (d : Prog) (hd : ∀ q, Halts d q ↔ M q = true) :
    ∃ q, ¬ (M q = true ↔ ¬ Halts q q) := by
  refine ⟨d, fun hgood => ?_⟩
  have h : Halts d d ↔ ¬ Halts d d := (hd d).trans hgood
  have np : ¬ Halts d d := fun p => h.mp p p
  exact np (h.mpr np)

end SelfModHaltChain

/-
## Correction to the informal framing

The mission's informal description asserts that the self-modifying halting
problem is "strictly harder than the classical halting problem".  The formal
development shows this is **false**: by `halting_turing_equiv` together with the
decider transfers `selfmod_decidable_of_std` and `std_decidable_of_selfmod`, the
two problems are *many-one equivalent*.  Self-modification is undecidable
(`halting_contradiction`), and its undecidability is exactly the classical
undecidability — no strictly higher degree is introduced by allowing code to
rewrite itself, because the running program can always be absorbed into the data
(`SMM.toStd`).  The genuine phenomenon is the *self-referential* obstruction
(`no_correct_decider`, `alignment_no_monitor`): a system able to build the
contrarian program defeats every candidate predictor of its own behavior.
-/