/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# A Fixed-Point Bridge: Self-Modifying Halting ⟷ Lawvere/Cantor Diagonalization

This file builds a **cross-domain bridge** connecting two areas that, on the
surface, look unrelated:

* **Fixed-point theory / set theory** — Lawvere's fixed-point theorem and, as
  its contrapositive, Cantor's theorem (no set surjects onto its power set, and
  no type surjects onto its own Boolean predicates).

* **Computability of self-modifying code** — the halting problem for machines
  whose *program* can be rewritten during execution, together with Kleene's
  recursion theorem giving self-reproducing ("quine") programs.

The unifying observation is that both phenomena are governed by the *same*
diagonal fixed-point principle.  Concretely:

* `lawvere_fixed_point` — Lawvere's theorem: a point-surjection `A → (A → B)`
  forces every `f : B → B` to have a fixed point.
* `cantor_bool`, `cantor_powerset` — Cantor's theorem, obtained as the
  contrapositive (`Bool.not` and `¬` are fixed-point-free).
* `diagonal_no_decider` — the diagonalization engine behind halting-style
  undecidability, derived *directly* from Cantor/Lawvere.
* `diag_halts_iff` / `selfmod_halting_undecidable` — a **genuine,
  non-vacuous** undecidability result: an explicit self-modifying machine whose
  halting predicate is `Nat.Partrec.Code`'s halting problem, hence provably not
  computable (via `ComputablePred.halting_problem`).
* `selfmod_behavior_fixed_point` — Kleene's recursion theorem, read as: no
  computable self-modification rule can change the behavior of *every* program;
  some program is a behavioral fixed point of the rewrite.
* `selfmod_halts_iff_standard` — self-modification adds no computational power:
  a self-modifying machine halts iff its fixed-program simulation halts.

The two areas meet in `selfmod_std_halting_undecidable`, where the
set-theoretic impossibility (`cantor_bool`) and the computational impossibility
(`selfmod_halting_undecidable`) are exhibited side by side over the same
configuration space.

The file is self-contained: it re-declares the self-modifying machine model and
imports only Mathlib.
-/

import Mathlib

open Function

namespace SelfModLawvere

/-- Abbreviation for Mathlib's partial-recursive code type, our universal
programming language. -/
abbrev Code := Nat.Partrec.Code

/- ===========================================================================
## SECTION 1: Lawvere's fixed-point theorem and Cantor's theorem (set theory)
=========================================================================== -/

/-- **Lawvere's fixed-point theorem** (point-surjective form).  If `g` is a
point-surjection `A → (A → B)`, then every self-map `f : B → B` has a fixed
point.  This single lemma is the engine behind Cantor, Russell, Gödel, Turing
and the halting problem. -/
theorem lawvere_fixed_point {A B : Type*} (g : A → (A → B))
    (hg : Surjective g) (f : B → B) : ∃ b, f b = b := by
  obtain ⟨a, ha⟩ := hg (fun a => f (g a a))
  exact ⟨g a a, by conv_rhs => rw [ha]⟩

/-- Contrapositive of Lawvere: a fixed-point-free `f : B → B` obstructs every
point-surjection `A → (A → B)`. -/
theorem no_point_surjection {A B : Type*} (f : B → B) (hf : ∀ b, f b ≠ b) :
    ¬ ∃ g : A → (A → B), Surjective g := by
  rintro ⟨g, hg⟩
  obtain ⟨b, hb⟩ := lawvere_fixed_point g hg f
  exact hf b hb

/-- **Cantor's theorem, Boolean form**: no type point-surjects onto its own
Boolean predicates.  The witness is `Bool.not`, which has no fixed point. -/
theorem cantor_bool {A : Type*} : ¬ ∃ g : A → (A → Bool), Surjective g :=
  no_point_surjection Bool.not (by decide)

/-- **Cantor's theorem, power-set form**: no map `A → Set A` is surjective. -/
theorem cantor_powerset {A : Type*} (g : A → Set A) : ¬ Surjective g :=
  cantor_surjective g

/-- The **diagonalization engine**: if `enum` point-surjects onto the Boolean
predicates on `α`, no total table `d` can reproduce every value `enum i a`.
Derived directly from `cantor_bool`, exhibiting halting-style diagonalization
as a face of Cantor's theorem. -/
theorem diagonal_no_decider {α : Type*} (enum : α → α → Bool)
    (surj : Surjective enum) :
    ¬ ∃ d : α → α → Bool, ∀ i a, d i a = enum i a :=
  fun _ => cantor_bool ⟨enum, surj⟩

/- ===========================================================================
## SECTION 2: The self-modifying machine model
=========================================================================== -/

/-- A **self-modifying machine**: the transition takes and returns a
program-state pair, so the program component may change at every step.
`none` signals halting. -/
structure SelfModMachine (P S : Type*) where
  /-- One-step transition; `none` means halt. -/
  step : P → S → Option (P × S)

/-- Run a self-modifying machine for `n` steps; `none` if it has already
halted. -/
def SelfModMachine.run {P S : Type*} (m : SelfModMachine P S) :
    P × S → ℕ → Option (P × S)
  | ps, 0 => some ps
  | ps, n + 1 => match m.step ps.1 ps.2 with
    | Option.none => Option.none
    | Option.some ps' => m.run ps' n

/-- The machine halts from `ps` if some finite run returns `none`. -/
def SelfModMachine.halts {P S : Type*} (m : SelfModMachine P S)
    (ps : P × S) : Prop :=
  ∃ n : ℕ, m.run ps n = Option.none

/-- A **standard (fixed-program) machine**: only the state changes. -/
structure StdMachine (S : Type*) where
  /-- One-step transition; `none` means halt. -/
  step : S → Option S

/-- Run a standard machine for `n` steps. -/
def StdMachine.run {S : Type*} (m : StdMachine S) : S → ℕ → Option S
  | s, 0 => some s
  | s, n + 1 => match m.step s with
    | Option.none => Option.none
    | Option.some s' => m.run s' n

/-- The standard machine halts from `s` if some finite run returns `none`. -/
def StdMachine.halts {S : Type*} (m : StdMachine S) (s : S) : Prop :=
  ∃ n : ℕ, m.run s n = Option.none

/-- The **standard simulation**: encode the program into the state, turning a
self-modifying machine into a fixed-program machine over `P × S`. -/
def SelfModMachine.toStd {P S : Type*} (m : SelfModMachine P S) :
    StdMachine (P × S) where
  step := fun ps => match m.step ps.1 ps.2 with
    | Option.none => Option.none
    | Option.some ps' => Option.some ps'

/- ===========================================================================
## SECTION 3: Self-modification adds no power (simulation equivalence)
=========================================================================== -/

/-- Running the standard simulation for `n` steps agrees with running the
self-modifying machine for `n` steps. -/
theorem selfmod_run_eq_std_run {P S : Type*} (m : SelfModMachine P S)
    (ps : P × S) (n : ℕ) :
    m.run ps n = m.toStd.run ps n := by
  induction n generalizing ps with
  | zero => rfl
  | succ n ih =>
    rw [SelfModMachine.run, StdMachine.run]
    have : m.toStd.step ps = m.step ps.1 ps.2 := by
      cases h : m.step ps.1 ps.2 <;> simp [SelfModMachine.toStd, h]
    rw [this]
    cases h : m.step ps.1 ps.2 with
    | none => rfl
    | some ps' => simpa using ih ps'

/-- **Simulation theorem**: a self-modifying machine halts iff its standard
(fixed-program) simulation halts.  Self-modification is behaviorally reducible
to encoding the program as data. -/
theorem selfmod_halts_iff_standard {P S : Type*} (m : SelfModMachine P S)
    (ps : P × S) :
    m.halts ps ↔ m.toStd.halts ps := by
  unfold SelfModMachine.halts StdMachine.halts
  exact exists_congr fun n => by rw [selfmod_run_eq_std_run]

/- ===========================================================================
## SECTION 4: A genuine (non-vacuous) undecidable self-modifying machine
=========================================================================== -/

/-- An explicit self-modifying machine over programs `Code` and state `ℕ` (a
step counter).  On program `c` and counter `s` it checks whether the universal
evaluator `evaln` has produced an output for `c` on input `n` within `s`
steps; if so it halts, otherwise it advances the counter.  (Its program never
actually changes here — a fixed-program machine is a special self-modifying
one — so this is a *lower bound* on the difficulty of self-modifying halting.) -/
def diagMachine (n : ℕ) : SelfModMachine Code ℕ :=
  ⟨fun c s => if (Nat.Partrec.Code.evaln s c n).isSome
    then Option.none else Option.some (c, s + 1)⟩

/-- A run of `diagMachine` halts within `N` steps starting at counter `s` iff
`evaln` succeeds at some counter value below `s + N`. -/
theorem diag_run (n : ℕ) (c : Code) (s N : ℕ) :
    (diagMachine n).run (c, s) N = Option.none ↔
      ∃ i, i < N ∧ (Nat.Partrec.Code.evaln (s + i) c n).isSome := by
  induction N generalizing s with
  | zero => simp [SelfModMachine.run]
  | succ N ih =>
    rw [SelfModMachine.run]
    have hstep : (diagMachine n).step c s
        = if (Nat.Partrec.Code.evaln s c n).isSome
          then Option.none else Option.some (c, s + 1) := rfl
    rw [hstep]
    by_cases h : (Nat.Partrec.Code.evaln s c n).isSome = true
    · rw [if_pos h]; dsimp only
      exact ⟨fun _ => ⟨0, by omega, by simpa using h⟩, fun _ => rfl⟩
    · rw [if_neg h]; dsimp only; rw [ih]
      constructor
      · rintro ⟨i, hi, hs⟩
        refine ⟨i + 1, by omega, ?_⟩
        have : s + (i + 1) = s + 1 + i := by omega
        rw [this]; exact hs
      · rintro ⟨i, hi, hs⟩
        cases i with
        | zero => simp only [Nat.add_zero] at hs; exact absurd hs h
        | succ j =>
          refine ⟨j, by omega, ?_⟩
          have : s + 1 + j = s + (j + 1) := by omega
          rw [this]; exact hs

/-- **Bridge lemma**: the self-modifying machine `diagMachine n` halts from the
initial configuration `(c, 0)` iff the program `c` halts on input `n` in the
universal model.  This ties our self-modifying halting predicate to Mathlib's
`Nat.Partrec.Code` semantics. -/
theorem diag_halts_iff (n : ℕ) (c : Code) :
    (diagMachine n).halts (c, 0) ↔ (c.eval n).Dom := by
  rw [SelfModMachine.halts, Part.dom_iff_mem]
  constructor
  · rintro ⟨N, hN⟩
    rw [diag_run] at hN
    obtain ⟨i, _, hi⟩ := hN
    obtain ⟨x, hx⟩ := Option.isSome_iff_exists.mp hi
    exact ⟨x, Nat.Partrec.Code.evaln_sound (by rw [hx]; exact rfl)⟩
  · rintro ⟨x, hx⟩
    obtain ⟨k, hk⟩ := Nat.Partrec.Code.evaln_complete.mp hx
    refine ⟨k + 1, ?_⟩
    rw [diag_run]
    exact ⟨k, by omega,
      by rw [Nat.zero_add]; exact Option.isSome_iff_exists.mpr ⟨x, by simpa using hk⟩⟩

/-- **Main undecidability theorem** (computability side of the bridge).  The
halting predicate of the self-modifying machine `diagMachine n` is *not*
computable.  This is a genuine, non-vacuous undecidability result: it reduces
to Mathlib's `ComputablePred.halting_problem`. -/
theorem selfmod_halting_undecidable (n : ℕ) :
    ¬ ComputablePred (fun c : Code => (diagMachine n).halts (c, 0)) := by
  have hcongr : (fun c : Code => (diagMachine n).halts (c, 0))
      = (fun c : Code => (c.eval n).Dom) := by
    funext c; exact propext (diag_halts_iff n c)
  rw [hcongr]
  exact ComputablePred.halting_problem n

/-- The same undecidability, transported to the **standard simulation** via the
simulation theorem: the fixed-program encoding of a self-modifying machine has
an undecidable halting problem too.  (Self-modification is no harder — and no
easier — than the classical halting problem.) -/
theorem selfmod_std_halting_undecidable (n : ℕ) :
    ¬ ComputablePred (fun c : Code => (diagMachine n).toStd.halts (c, 0)) := by
  have hcongr : (fun c : Code => (diagMachine n).toStd.halts (c, 0))
      = (fun c : Code => (diagMachine n).halts (c, 0)) := by
    funext c; exact propext (selfmod_halts_iff_standard _ _).symm
  rw [hcongr]
  exact selfmod_halting_undecidable n

/- ===========================================================================
## SECTION 5: Kleene's recursion theorem — self-reproducing self-modification
=========================================================================== -/

/-- **Self-modification fixed-point theorem** (Kleene's recursion theorem).
No computable self-modification rule `modify : Code → Code` can alter the
behavior of *every* program: there is always a program `c` whose rewritten
version `modify c` computes the very same partial function.  Read
operationally, `c` is a self-reproducing / quine-like program that the rewrite
`modify` cannot behaviorally "stop" or change. -/
theorem selfmod_behavior_fixed_point {modify : Code → Code}
    (h : Computable modify) : ∃ c : Code, (modify c).eval = c.eval :=
  Nat.Partrec.Code.fixed_point h

/-- Concrete corollary: the identity self-modification (do nothing) trivially
has a behavioral fixed point, illustrating that the hypothesis of
`selfmod_behavior_fixed_point` is satisfiable. -/
theorem selfmod_behavior_fixed_point_id :
    ∃ c : Code, (id c).eval = c.eval :=
  selfmod_behavior_fixed_point Computable.id

/- ===========================================================================
## SECTION 6: The bridge, stated as one theorem
=========================================================================== -/

/-- **The cross-domain bridge, in one statement.**  Over any configuration
space three impossibilities coincide, all instances of the diagonal
fixed-point principle:

1. *(set theory / Lawvere–Cantor)* no configuration space point-surjects onto
   its own Boolean predicates;
2. *(computability)* the self-modifying halting predicate is not computable;
3. *(computability, standard form)* neither is its fixed-program simulation.

The first is `cantor_bool`; the second and third are the reductions to the
universal halting problem. -/
theorem lawvere_halting_bridge (n : ℕ) :
    (¬ ∃ g : Code → (Code → Bool), Surjective g) ∧
    (¬ ComputablePred (fun c : Code => (diagMachine n).halts (c, 0))) ∧
    (¬ ComputablePred (fun c : Code => (diagMachine n).toStd.halts (c, 0))) :=
  ⟨cantor_bool, selfmod_halting_undecidable n, selfmod_std_halting_undecidable n⟩

end SelfModLawvere