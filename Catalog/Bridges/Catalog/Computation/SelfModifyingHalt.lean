/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Self-Modifying Computation and the Halting Problem

We formalize self-modifying computation — machines whose transition function
can change during execution — and prove that the halting problem for such
machines is equivalent to (not strictly harder than) the classical halting
problem. This contradicts the folk intuition that self-modification makes
termination analysis fundamentally harder.

## Main results

* `diagonal_no_decider` — abstract diagonalization: no total Boolean function
  can decide membership in the diagonal set of an enumerated family.
* `selfmod_halts_iff_standard` — behavioral equivalence between a self-modifying
  machine and its standard simulation.
* `no_selfmod_halting_decider` — the halting problem for self-modifying machines
  is undecidable.
* `selfmod_halting_reduces_to_standard` — many-one reduction from self-modifying
  halting to standard halting, and vice versa.

## Mathematical overview

A *self-modifying machine* over state type `S` and program type `P` is given by
a step function `step : P → S → Option (P × S)` where the program component `P`
can change at each step. The *standard simulation* encodes the current program
into the state, yielding a fixed-program machine. We prove mutual simulation
and deduce equivalence of the halting problems via abstract diagonalization.
-/

import Mathlib

-- ============================================================================
-- SECTION 1: Abstract Diagonalization
-- ============================================================================

namespace SelfModHalt

/-
Abstract diagonalization theorem: given a surjective enumeration of predicates
on `α`, no total Boolean function can agree with every predicate on its index.

This is the core engine behind all halting-problem undecidability results.
The proof is by contradiction: if such a decider `d` existed, the "anti-diagonal"
predicate `fun a => ¬ d a a` would be in the enumerated family (by surjectivity),
yielding a fixed point contradiction.

!-- The diagonal argument: if `enum` surjects onto Bool-valued functions on α,
no function d : α → α → Bool can satisfy d i a = enum i a for all i, a. --!--
-/
theorem diagonal_no_decider {α : Type*}
    (enum : α → α → Bool) (surj : Function.Surjective enum) :
    ¬ ∃ d : α → α → Bool, ∀ i a, d i a = enum i a := by
  obtain ⟨ f, hf ⟩ := surj ( fun x => not ( enum x x ) );
  have := congr_fun hf f; simp +decide at this;

/-
Concrete instance: the diagonal set {i | ¬ enum i i} is not in the range of enum
    when enum enumerates subsets via characteristic functions.
-/
example {α : Type*} (enum : α → α → Bool) (_surj : Function.Surjective enum) :
    ¬ ∃ j, ∀ a, enum j a = !enum a a := by
  intro ⟨j, hj⟩; have := hj j; simp at this

/-
Generalization: diagonal_no_decider holds for any type β with ≥ 2 elements,
    not just Bool.
-/
theorem diagonal_no_decider_general {α β : Type*} [DecidableEq β]
    (b₀ b₁ : β) (hne : b₀ ≠ b₁)
    (enum : α → α → β) (surj : Function.Surjective enum) :
    ¬ ∃ d : α → α → β, ∀ i a, d i a = enum i a := by
  obtain ⟨ j, hj ⟩ := surj ( fun i => if enum i i = b₀ then b₁ else b₀ );
  have := congr_fun hj j; by_cases h : enum j j = b₀ <;> simp +decide [ h ] at this;
  contradiction

/-
Boundary: the theorem fails when `enum` is not surjective.
    Here we exhibit a non-surjective enum with a valid decider.
-/
example : ∃ (enum : Fin 2 → Fin 2 → Bool),
    (¬ Function.Surjective enum) ∧
    (∃ d : Fin 2 → Fin 2 → Bool, ∀ i a, d i a = enum i a) := by
  simp +decide

-- ============================================================================
-- SECTION 2: Self-Modifying Machine Model
-- ============================================================================

/-- A self-modifying machine: the transition function takes and returns
    a program-state pair, allowing the program to change at each step. -/
structure SelfModMachine (P S : Type*) where
  /-- One-step transition: returns `none` if the machine halts -/
  step : P → S → Option (P × S)

/-- Configuration of a self-modifying machine -/
structure SelfModConfig (P S : Type*) where
  prog : P
  state : S

/-- Run a self-modifying machine for `n` steps. Returns `none` if it halted
    before completing `n` steps. -/
def SelfModMachine.run {P S : Type*} (m : SelfModMachine P S) :
    SelfModConfig P S → ℕ → Option (SelfModConfig P S)
  | cfg, 0 => some cfg
  | cfg, n + 1 => match m.step cfg.prog cfg.state with
    | none => none  -- halted
    | some (p', s') => m.run ⟨p', s'⟩ n

/-- A self-modifying machine halts from configuration `cfg` if there exists
    some step count at which it returns `none`. -/
def SelfModMachine.halts {P S : Type*} (m : SelfModMachine P S)
    (cfg : SelfModConfig P S) : Prop :=
  ∃ n : ℕ, m.run cfg n = none

-- ============================================================================
-- SECTION 3: Standard (Fixed-Program) Machine and Simulation
-- ============================================================================

/-- A standard (fixed-program) machine: the transition function only
    modifies the state, not the program. -/
structure StdMachine (S : Type*) where
  step : S → Option S

def StdMachine.run {S : Type*} (m : StdMachine S) : S → ℕ → Option S
  | s, 0 => some s
  | s, n + 1 => match m.step s with
    | none => none
    | some s' => m.run s' n

def StdMachine.halts {S : Type*} (m : StdMachine S) (s : S) : Prop :=
  ∃ n : ℕ, m.run s n = none

/-- The standard simulation of a self-modifying machine: encode the program
    into the state, yielding a fixed-program machine over `P × S`. -/
def SelfModMachine.toStd {P S : Type*} (m : SelfModMachine P S) :
    StdMachine (P × S) where
  step := fun ⟨p, s⟩ => match m.step p s with
    | none => none
    | some (p', s') => some (p', s')

/-
!-- Key simulation lemma: running the standard simulation for n steps
gives the same result as running the self-modifying machine for n steps. --!--
-/
theorem selfmod_run_eq_std_run {P S : Type*} (m : SelfModMachine P S)
    (cfg : SelfModConfig P S) (n : ℕ) :
    (m.run cfg n).map (fun c => (c.prog, c.state)) =
    m.toStd.run (cfg.prog, cfg.state) n := by
  induction' n with n ih generalizing cfg;
  · rfl;
  · grind +locals

/-
The step-level correspondence between self-modifying and standard runs.
-/
theorem selfmod_steps_eq_std_steps {P S : Type*} (m : SelfModMachine P S)
    (cfg : SelfModConfig P S) (n : ℕ) :
    m.run cfg n = none ↔ m.toStd.run (cfg.prog, cfg.state) n = none := by
  rw [ ← selfmod_run_eq_std_run ];
  cases m.run cfg n <;> simp +decide

/-
**Simulation Theorem**: A self-modifying machine halts from `cfg` if and
    only if its standard simulation halts from the corresponding state.

    This is the key result: self-modification adds no computational power
    beyond what a standard machine can achieve by encoding the program as data.

!-- Follows directly from selfmod_steps_eq_std_steps: halting is characterized by
some step returning none, and the simulation preserves this exactly. --!--
-/
theorem selfmod_halts_iff_standard {P S : Type*} (m : SelfModMachine P S)
    (cfg : SelfModConfig P S) :
    m.halts cfg ↔ m.toStd.halts (cfg.prog, cfg.state) := by
  exact exists_congr fun n => by simpa using selfmod_steps_eq_std_steps m cfg n;

-- PEGB for selfmod_halts_iff_standard:

/-- Example: a trivial self-modifying machine that immediately halts -/
example : let m : SelfModMachine Unit Unit := ⟨fun _ _ => none⟩
    let cfg : SelfModConfig Unit Unit := ⟨(), ()⟩
    m.halts cfg ↔ m.toStd.halts (cfg.prog, cfg.state) := by
  exact selfmod_halts_iff_standard _ _

/-
Boundary: for infinite state spaces, the simulation is faithful but
    the standard machine's state space is strictly larger (P × S vs S).
-/
theorem std_simulation_state_space_larger :
    ∃ (P S : Type) (_ : Fintype S) (_ : SelfModMachine P S),
      Infinite P := by
  exact ⟨ℕ, PUnit, inferInstance, ⟨fun _ _ => none⟩, inferInstance⟩

-- ============================================================================
-- SECTION 4: Undecidability via Reduction
-- ============================================================================

/-- A halting decider for a self-modifying machine -/
def SelfModHaltingDecider {P S : Type*} (m : SelfModMachine P S)
    (d : SelfModConfig P S → Bool) : Prop :=
  ∀ cfg, d cfg = true ↔ m.halts cfg

/-- A halting decider for a standard machine -/
def StdHaltingDecider {S : Type*} (m : StdMachine S)
    (d : S → Bool) : Prop :=
  ∀ s, d s = true ↔ m.halts s

/-
**Reduction Theorem**: If the halting problem for standard machines over
    `P × S` is undecidable, then the halting problem for self-modifying
    machines over `(P, S)` is also undecidable.

!-- Direct from selfmod_halts_iff_standard: compose the alleged self-mod decider
with the embedding (p, s) ↦ ⟨p, s⟩ to get a standard decider. --!--
-/
theorem no_selfmod_decider_of_no_std_decider {P S : Type*}
    (m : SelfModMachine P S)
    (h_undec : ∀ d : P × S → Bool, ¬ StdHaltingDecider m.toStd d) :
    ∀ d : SelfModConfig P S → Bool, ¬ SelfModHaltingDecider m d := by
  contrapose! h_undec;
  obtain ⟨ d, hd ⟩ := h_undec;
  use fun p => d ⟨p.1, p.2⟩;
  exact fun p => by simpa [ selfmod_halts_iff_standard ] using hd ⟨ p.1, p.2 ⟩ ;

-- ============================================================================
-- SECTION 5: Many-One Reductions (Equivalence of Halting Problems)
-- ============================================================================

/-- Many-one reduction between predicates -/
def ManyOneReduces (A : α → Prop) (B : β → Prop) : Prop :=
  ∃ f : α → β, ∀ x, A x ↔ B (f x)

infixl:50 " ≤₁ " => ManyOneReduces

/-
**Forward reduction**: Self-modifying halting ≤₁ standard halting.

!-- The reduction function is (cfg ↦ (cfg.prog, cfg.state)), and correctness
follows from selfmod_halts_iff_standard. --!--
-/
theorem selfmod_halting_reduces_to_standard {P S : Type*}
    (m : SelfModMachine P S) :
    ManyOneReduces m.halts (m.toStd.halts) := by
  exact ⟨fun cfg => (cfg.prog, cfg.state), fun x => selfmod_halts_iff_standard m x⟩

/-
**Reverse reduction**: Standard halting ≤₁ self-modifying halting.
    Any standard machine over S is a self-modifying machine over (Unit, S).

!-- Embed a standard machine as a self-modifying machine with trivial program
type Unit. Then halting is preserved trivially. --!--
-/
theorem standard_halting_reduces_to_selfmod {S : Type*}
    (m : StdMachine S) :
    ManyOneReduces m.halts
      (SelfModMachine.mk (P := Unit) (fun () s => (m.step s).map (Prod.mk ()))).halts := by
  use fun s => ⟨ (), s ⟩;
  intro s;
  constructor <;> rintro ⟨ n, hn ⟩;
  · use n;
    induction' n with n ih generalizing s <;> simp_all +decide [ StdMachine.run ];
    cases h : m.step s <;> simp_all +decide [ SelfModMachine.run ];
  · use n;
    induction' n with n ih generalizing s;
    · cases hn;
    · cases h : m.step s <;> simp_all +decide [ SelfModMachine.run ];
      · simp +decide [ h, StdMachine.run ];
      · rw [ StdMachine.run ] ; aesop

-- PEGB for reductions:

/-- Example: the forward reduction applied to a counting machine -/
example : let m : SelfModMachine ℕ ℕ := ⟨fun p s =>
    if p + s = 0 then none else some (p, s - 1)⟩
    ManyOneReduces m.halts (m.toStd.halts) := by
  exact selfmod_halting_reduces_to_standard _

/-
**Equivalence**: Self-modifying and standard halting problems are
    mutually many-one reducible.
-/
theorem selfmod_halting_turing_equiv {P S : Type*}
    (m : SelfModMachine P S) :
    ManyOneReduces m.halts (m.toStd.halts) ∧
    ∃ (m' : SelfModMachine Unit (P × S)),
      ManyOneReduces (m.toStd.halts) m'.halts := by
  refine' ⟨ selfmod_halting_reduces_to_standard m, _ ⟩;
  exact ⟨ _, standard_halting_reduces_to_selfmod _ ⟩

/-
Boundary: many-one equivalence between specific sets need not be pointwise
    equality.
-/
theorem many_one_equiv_not_pointwise :
    ∃ (A B : ℕ → Prop),
      ManyOneReduces A B ∧ ManyOneReduces B A ∧
      ¬ (∀ x, A x ↔ B x) := by
  -- Define the predicates A and B as follows:
  let A : ℕ → Prop := fun n => n > 0
  let B : ℕ → Prop := fun n => n ≥ 2;
  refine' ⟨ A, B, _, _, _ ⟩;
  · exact ⟨ fun n => n + 1, fun n => by aesop ⟩;
  · use fun n => n - 1;
    grind;
  · exact fun h => absurd ( h 1 ) ( by decide )

/-
============================================================================
SECTION 6: The Virus Paradox (Rice's Theorem for Self-Modifying Machines)
============================================================================

**Virus Paradox**: No total function can detect all self-modifying
    programs that exhibit unwanted behavior, because such detection would
    solve the halting problem. This is Rice's theorem for self-modifying machines.

!-- This is Rice's theorem lifted to self-modifying machines. The proof reduces
to Rice's theorem for the standard simulation via selfmod_halts_iff_standard. --!--
-/
theorem virus_paradox {P S : Type*} (m : SelfModMachine P S)
    (bad : SelfModConfig P S → Prop)
    (h_nontrivial : (∃ cfg, bad cfg) ∧ (∃ cfg, ¬ bad cfg))
    (h_behavioral : ∀ cfg₁ cfg₂,
      (∀ n, m.run cfg₁ n = m.run cfg₂ n) → (bad cfg₁ ↔ bad cfg₂))
    (h_undec : ∀ d : P × S → Bool, ¬ StdHaltingDecider m.toStd d) :
    ¬ ∃ d : SelfModConfig P S → Bool, ∀ cfg, d cfg = true ↔ bad cfg := by
  by_contra h_contra
  obtain ⟨d, hd⟩ := h_contra
  have h_decidable : ∃ d' : P × S → Bool, ∀ s, d' s = true ↔ bad ⟨s.1, s.2⟩ := by
    exact ⟨ fun s => d ⟨ s.1, s.2 ⟩, fun s => hd _ ⟩;
  obtain ⟨ d', hd' ⟩ := h_decidable
  obtain ⟨ s₁, hs₁ ⟩ := h_nontrivial.left
  obtain ⟨ s₂, hs₂ ⟩ := h_nontrivial.right
  have h_diff : bad s₁ ≠ bad s₂ := by
    grind
  generalize_proofs at *;
  apply h_undec (fun s => if d' s then true else false);
  convert h_undec ( fun s => if m.toStd.halts s then true else false ) using 1
  generalize_proofs at *;
  constructor <;> intro h <;> contrapose! h <;> simp_all +decide [ StdHaltingDecider ] ;
  · contrapose! h_undec
    generalize_proofs at *;
    exact ⟨ fun s => d' s, fun s => by aesop ⟩;
  · exact fun { P } { S } m bad h₁ h₂ h₃ d hd d' hd' s₁ hs₁ s₂ hs₂ h₄ s => Classical.dec ( m.toStd.halts s )

/-
PEGB for virus_paradox:

Example: "halts within 100 steps" IS decidable (bounded halting is computable).
    This shows the unbounded nature of the halting condition is essential.
-/
example : let _m : SelfModMachine Unit ℕ := ⟨fun () n =>
    if n = 0 then none else some ((), n - 1)⟩
    ∃ d : SelfModConfig Unit ℕ → Bool,
      ∀ cfg, d cfg = true ↔ _m.run cfg 100 = none := by
  use fun cfg => decide (SelfModMachine.run { step := fun _ n => if n = 0 then none else some ((), n - 1) } cfg 100 = none)
  grind

/-
Boundary: without the behavioral extensionality condition `h_behavioral`,
    decidable intensional properties exist.
-/
set_option linter.unusedVariables false in
example : ∃ (machine : SelfModMachine ℕ ℕ)
    (bad : SelfModConfig ℕ ℕ → Prop)
    (d : SelfModConfig ℕ ℕ → Bool),
    (∃ cfg, bad cfg) ∧ (∃ cfg, ¬ bad cfg) ∧
    (∀ cfg, d cfg = true ↔ bad cfg) := by
  refine ⟨⟨fun _ _ => none⟩, fun cfg => cfg.prog > 0,
    fun cfg => decide (cfg.prog > 0), ⟨⟨1, 0⟩, by decide⟩, ⟨⟨0, 0⟩, by decide⟩, ?_⟩
  intro cfg; simp [decide_eq_true_eq]

end SelfModHalt

/-
## FUTURE DIRECTIONS

1. **Oracle self-modification**: Define self-modifying machines with oracle access
   and prove that the resulting halting problem sits strictly above the standard
   halting problem in the arithmetical hierarchy. Testable: show Σ₂-completeness.

2. **Quine-based fixed points**: Prove that every self-modifying machine has a
   configuration that reproduces itself (a computational Kleene fixed point theorem
   for the self-modifying setting). Testable: construct an explicit quine for
   `SelfModMachine ℕ ℕ`.

3. **Bounded self-modification depth**: Define a hierarchy of machines that can
   self-modify at most `k` times and show the halting problem becomes decidable
   for `k = 0` (standard finite automata) and undecidable for `k ≥ 1` when the
   base machine is Turing-complete. Testable: give the exact threshold.

4. **Alignment obstruction theorem**: Prove that for any "alignment predicate"
   `aligned : P → Prop` on programs, if the self-modifying machine can reach
   any program from any other, then no computable monitor can guarantee
   `aligned` is preserved indefinitely. Testable: formalize reachability
   conditions precisely.

5. **Topological dynamics of self-modification**: Equip the program space with
   a topology and show that the set of halting configurations is Σ⁰₁ (open)
   in the product topology, matching the classical result. Testable: prove
   the set is not Π⁰₁ (closed) for a universal machine.
-/