import Mathlib.Tactic

/-!
# Self-modifying machines and the halting predicate

This file supplies the operational model used by
`Novelty.SelfModifyingUndecidability`.

A *self-modifying machine* carries its program in the configuration: a step
takes the current program `p` and the current state `s` and produces a **new
program together with a new state**, or `none` (the machine has halted).  A
*standard machine* is the special case in which the transition function only
sees a single carrier.

The point of the file is the elementary but structurally important observation
that "code is data": pairing the mutable program with the state turns a
self-modifying machine into a standard machine on `P × S` whose runs agree
step for step (`run_toStd`).  Consequently the two halting predicates are
many-one interreducible (`selfmod_halting_turing_equiv`), so unrestricted
self-modification does not raise the degree of unsolvability of termination.
-/

namespace SelfModHalt

universe u v

variable {P : Type u} {S : Type v} {α β : Type*}

/-- A machine whose transition may rewrite its own program. -/
structure SelfModMachine (P : Type u) (S : Type v) where
  /-- One step: from program `p` and state `s`, either halt or move to a new
  program/state pair. -/
  step : P → S → Option (P × S)

/-- A configuration of a self-modifying machine: the current program together
with the current state. -/
abbrev SelfModConfig (P : Type u) (S : Type v) : Type max u v := P × S

/-- A machine with a fixed program: the transition sees only the carrier. -/
structure StdMachine (α : Type*) where
  /-- One step: either halt or move to a new carrier element. -/
  step : α → Option α

namespace StdMachine

/-- `M.run a n` is the configuration reached after `n` steps, or `none` if the
machine halted at some point along the way. -/
def run (M : StdMachine α) (a : α) : ℕ → Option α
  | 0 => some a
  | n + 1 => (M.run a n).bind M.step

@[simp] theorem run_zero (M : StdMachine α) (a : α) : M.run a 0 = some a := rfl

@[simp] theorem run_succ (M : StdMachine α) (a : α) (n : ℕ) :
    M.run a (n + 1) = (M.run a n).bind M.step := rfl

/-- The machine halts from `a` when some finite run is undefined. -/
def halts (M : StdMachine α) (a : α) : Prop := ∃ n, M.run a n = Option.none

end StdMachine

/-- An exact Boolean decider for the halting problem of a standard machine. -/
def StdHaltingDecider (M : StdMachine α) (d : α → Bool) : Prop :=
  ∀ a, d a = true ↔ M.halts a

/-- Non-effective many-one reduction: `A` reduces to `B` when there is a map of
instances translating membership faithfully.  (Effectivity is deliberately not
required: the results below are about degrees of definability of the halting
predicates, not about their complexity.) -/
def ManyOneReduces {α β : Sort*} (A : α → Prop) (B : β → Prop) : Prop :=
  ∃ f : α → β, ∀ a, A a ↔ B (f a)

theorem ManyOneReduces.refl {α : Sort*} (A : α → Prop) : ManyOneReduces A A :=
  ⟨id, fun _ => Iff.rfl⟩

theorem ManyOneReduces.trans {α β γ : Sort*} {A : α → Prop} {B : β → Prop}
    {C : γ → Prop} (hAB : ManyOneReduces A B) (hBC : ManyOneReduces B C) :
    ManyOneReduces A C := by
  obtain ⟨f, hf⟩ := hAB
  obtain ⟨g, hg⟩ := hBC
  exact ⟨g ∘ f, fun a => (hf a).trans (hg (f a))⟩

namespace SelfModMachine

/-- `m.run cfg n` is the configuration reached after `n` steps of the
self-modifying machine, or `none` if it halted earlier. -/
def run (m : SelfModMachine P S) (cfg : SelfModConfig P S) :
    ℕ → Option (SelfModConfig P S)
  | 0 => some cfg
  | n + 1 => (m.run cfg n).bind fun c => m.step c.1 c.2

@[simp] theorem run_zero (m : SelfModMachine P S) (cfg : SelfModConfig P S) :
    m.run cfg 0 = some cfg := rfl

@[simp] theorem run_succ (m : SelfModMachine P S) (cfg : SelfModConfig P S)
    (n : ℕ) :
    m.run cfg (n + 1) = (m.run cfg n).bind fun c => m.step c.1 c.2 := rfl

/-- The self-modifying machine halts from `cfg` when some finite run is
undefined. -/
def halts (m : SelfModMachine P S) (cfg : SelfModConfig P S) : Prop :=
  ∃ n, m.run cfg n = Option.none

/-- **Code is data.**  Storing the mutable program inside the carrier turns a
self-modifying machine into an ordinary fixed-program machine on `P × S`. -/
def toStd (m : SelfModMachine P S) : StdMachine (P × S) :=
  ⟨fun c => m.step c.1 c.2⟩

@[simp] theorem toStd_step (m : SelfModMachine P S) (c : P × S) :
    m.toStd.step c = m.step c.1 c.2 := rfl

end SelfModMachine

/-- The simulation is exact: runs of `m` and of its fixed-program simulation
agree at every length. -/
theorem run_toStd (m : SelfModMachine P S) (cfg : SelfModConfig P S) (n : ℕ) :
    m.run cfg n = m.toStd.run cfg n := by
  induction n with
  | zero => rfl
  | succ n ih => simp [SelfModMachine.run, StdMachine.run, ih]

/-- Halting of a self-modifying machine is *literally* halting of its
fixed-program simulation. -/
theorem selfmod_halts_iff_standard (m : SelfModMachine P S)
    (cfg : SelfModConfig P S) : m.halts cfg ↔ m.toStd.halts cfg := by
  simp only [SelfModMachine.halts, StdMachine.halts, run_toStd]

/-- Consequently self-modifying halting many-one reduces to standard halting,
with the identity translation. -/
theorem selfmod_halting_reduces_to_standard (m : SelfModMachine P S) :
    ManyOneReduces m.halts m.toStd.halts :=
  ⟨id, fun cfg => selfmod_halts_iff_standard m cfg⟩

/-- A standard machine on `α` viewed as a self-modifying machine with a
one-element (hence never really modified) program type. -/
def StdMachine.toSelfMod (M : StdMachine α) : SelfModMachine Unit α :=
  ⟨fun _ s => (M.step s).map fun s' => ((), s')⟩

theorem run_toSelfMod (M : StdMachine α) (a : α) (n : ℕ) :
    M.toSelfMod.run ((), a) n = (M.run a n).map fun s => ((), s) := by
  induction n with
  | zero => rfl
  | succ n ih =>
      simp only [SelfModMachine.run_succ, StdMachine.run_succ, ih]
      cases M.run a n with
      | none => rfl
      | some s =>
          cases M.step s <;> rfl

theorem toSelfMod_halts_iff (M : StdMachine α) (a : α) :
    M.halts a ↔ M.toSelfMod.halts ((), a) := by
  constructor
  · rintro ⟨n, hn⟩
    exact ⟨n, by rw [run_toSelfMod, hn]; rfl⟩
  · rintro ⟨n, hn⟩
    rw [run_toSelfMod] at hn
    exact ⟨n, by simpa using hn⟩

/-- **Mutual reducibility.**  Self-modifying halting reduces to fixed-program
halting, and fixed-program halting reduces back to the halting problem of a
self-modifying machine.  Hence self-modification is not a source of extra
undecidability. -/
theorem selfmod_halting_turing_equiv (m : SelfModMachine P S) :
    ManyOneReduces m.halts m.toStd.halts ∧
      ∃ m' : SelfModMachine Unit (P × S),
        ManyOneReduces m.toStd.halts m'.halts := by
  refine ⟨selfmod_halting_reduces_to_standard m, m.toStd.toSelfMod, ?_⟩
  exact ⟨fun c => ((), c), fun c => toSelfMod_halts_iff m.toStd c⟩

end SelfModHalt