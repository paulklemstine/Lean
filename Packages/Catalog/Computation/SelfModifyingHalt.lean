import Mathlib

/-!
# Self-modifying machines and their fixed-program simulation

`Novelty/SelfModifyingUndecidability.lean` builds on this module, but the module
itself was missing from the catalog, which broke the build of the `Novelty`
library.  It is supplied here.

A *self-modifying machine* is a transition system whose configuration carries
both a program `P` and a data state `S`, and whose single step may rewrite the
program as well as the state.  The point of the file is that this apparent extra
power is illusory: pairing the (changing) program with the state produces an
ordinary fixed-program machine on `P × S` whose runs are in step-for-step
bijection with the runs of the self-modifying one.  Consequently the two halting
predicates are many-one interreducible, and — in the other direction — every
fixed-program machine is a self-modifying machine over a one-element program
type.

Main results:

* `SelfModMachine.run_toStd` — step-for-step simulation;
* `selfmod_halts_iff_standard` — the two halting predicates agree pointwise;
* `selfmod_halting_reduces_to_standard`, `selfmod_halting_turing_equiv` —
  many-one interreducibility.
-/

namespace SelfModHalt

/-- Many-one reducibility for predicates on arbitrary (not necessarily encodable)
sorts: `A` reduces to `B` when a total map converts instances of `A` into
equivalent instances of `B`. -/
def ManyOneReduces {α β : Sort*} (A : α → Prop) (B : β → Prop) : Prop :=
  ∃ f : α → β, ∀ a, A a ↔ B (f a)

theorem ManyOneReduces.refl {α : Sort*} (A : α → Prop) : ManyOneReduces A A :=
  ⟨id, fun _ => Iff.rfl⟩

theorem ManyOneReduces.trans {α β γ : Sort*} {A : α → Prop} {B : β → Prop} {C : γ → Prop}
    (h₁ : ManyOneReduces A B) (h₂ : ManyOneReduces B C) : ManyOneReduces A C := by
  obtain ⟨f, hf⟩ := h₁
  obtain ⟨g, hg⟩ := h₂
  exact ⟨g ∘ f, fun a => (hf a).trans (hg (f a))⟩

/-- A configuration of a self-modifying machine: the current program together
with the current data state. -/
structure SelfModConfig (P S : Type*) where
  /-- The program currently being executed (and possibly rewritten). -/
  prog : P
  /-- The data state. -/
  state : S

/-- A self-modifying machine: a partial step function on configurations, which
may rewrite the program.  `none` means the machine has halted. -/
structure SelfModMachine (P S : Type*) where
  /-- One step of execution; `none` signals termination. -/
  step : SelfModConfig P S → Option (SelfModConfig P S)

/-- An ordinary fixed-program machine: a partial step function on states. -/
structure StdMachine (X : Type*) where
  /-- One step of execution; `none` signals termination. -/
  step : X → Option X

variable {P S X : Type*}

/-- The configuration reached after `n` steps, if the machine has not halted. -/
def SelfModMachine.run (m : SelfModMachine P S) (cfg : SelfModConfig P S) :
    ℕ → Option (SelfModConfig P S)
  | 0 => some cfg
  | n + 1 => (m.run cfg n).bind m.step

/-- The state reached after `n` steps, if the machine has not halted. -/
def StdMachine.run (M : StdMachine X) (x : X) : ℕ → Option X
  | 0 => some x
  | n + 1 => (M.run x n).bind M.step

/-- A self-modifying machine halts on a configuration when some finite run is
undefined. -/
def SelfModMachine.halts (m : SelfModMachine P S) (cfg : SelfModConfig P S) : Prop :=
  ∃ n, m.run cfg n = Option.none

/-- A fixed-program machine halts on a state when some finite run is undefined. -/
def StdMachine.halts (M : StdMachine X) (x : X) : Prop :=
  ∃ n, M.run x n = Option.none

/-- An exact Boolean decider for the halting problem of a fixed-program machine. -/
def StdHaltingDecider (M : StdMachine X) (d : X → Bool) : Prop :=
  ∀ x, d x = true ↔ M.halts x

/-- Flattening a configuration into a plain pair. -/
def flat (cfg : SelfModConfig P S) : P × S := (cfg.prog, cfg.state)

@[simp] theorem flat_mk (p : P) (s : S) : flat (⟨p, s⟩ : SelfModConfig P S) = (p, s) := rfl

/-- The fixed-program simulation: store the changing program inside the state. -/
def SelfModMachine.toStd (m : SelfModMachine P S) : StdMachine (P × S) where
  step := fun p => (m.step ⟨p.1, p.2⟩).map flat

/-- **Step-for-step simulation.**  The run of the simulation is the flattened run
of the self-modifying machine. -/
theorem SelfModMachine.run_toStd (m : SelfModMachine P S) (cfg : SelfModConfig P S) (n : ℕ) :
    m.toStd.run (flat cfg) n = (m.run cfg n).map flat := by
  induction n with
  | zero => rfl
  | succ n ih =>
    show (m.toStd.run (flat cfg) n).bind m.toStd.step = ((m.run cfg n).bind m.step).map flat
    rw [ih]
    cases h : m.run cfg n with
    | none => simp
    | some c =>
      simp only [Option.map_some, Option.bind_some, SelfModMachine.toStd]
      cases c
      rfl

/-- The two halting predicates agree pointwise. -/
theorem selfmod_halts_iff_standard (m : SelfModMachine P S) (cfg : SelfModConfig P S) :
    m.halts cfg ↔ m.toStd.halts (cfg.prog, cfg.state) := by
  constructor
  · rintro ⟨n, hn⟩
    exact ⟨n, by rw [show (cfg.prog, cfg.state) = flat cfg from rfl,
      SelfModMachine.run_toStd, hn]; rfl⟩
  · rintro ⟨n, hn⟩
    rw [show (cfg.prog, cfg.state) = flat cfg from rfl, SelfModMachine.run_toStd] at hn
    exact ⟨n, Option.map_eq_none_iff.mp hn⟩

/-- Halting of a self-modifying machine many-one reduces to halting of its
fixed-program simulation. -/
theorem selfmod_halting_reduces_to_standard (m : SelfModMachine P S) :
    ManyOneReduces m.halts m.toStd.halts :=
  ⟨flat, fun cfg => selfmod_halts_iff_standard m cfg⟩

/-- The self-modifying machine over a one-element program type that carries out a
given fixed-program computation. -/
def ofStd (M : StdMachine X) : SelfModMachine Unit X where
  step := fun cfg => (M.step cfg.state).map (fun y => ⟨(), y⟩)

theorem run_ofStd (M : StdMachine X) (x : X) (n : ℕ) :
    (ofStd M).run ⟨(), x⟩ n = (M.run x n).map (fun y => ⟨(), y⟩) := by
  induction n with
  | zero => rfl
  | succ n ih =>
    show ((ofStd M).run ⟨(), x⟩ n).bind (ofStd M).step
        = ((M.run x n).bind M.step).map (fun y => (⟨(), y⟩ : SelfModConfig Unit X))
    rw [ih]
    cases h : M.run x n with
    | none => simp
    | some y =>
      simp only [Option.map_some, Option.bind_some, ofStd]

theorem ofStd_halts_iff (M : StdMachine X) (x : X) :
    (ofStd M).halts ⟨(), x⟩ ↔ M.halts x := by
  constructor
  · rintro ⟨n, hn⟩
    rw [run_ofStd] at hn
    exact ⟨n, Option.map_eq_none_iff.mp hn⟩
  · rintro ⟨n, hn⟩
    exact ⟨n, by rw [run_ofStd, hn]; rfl⟩

/-- **Interreducibility.**  Self-modification does not raise the degree of the
halting problem: each direction is a many-one reduction, the second one through
a self-modifying machine with a one-element program type. -/
theorem selfmod_halting_turing_equiv (m : SelfModMachine P S) :
    ManyOneReduces m.halts m.toStd.halts ∧
      ∃ m' : SelfModMachine Unit (P × S), ManyOneReduces m.toStd.halts m'.halts := by
  refine ⟨selfmod_halting_reduces_to_standard m, ofStd m.toStd, ?_⟩
  exact ⟨fun x => ⟨(), x⟩, fun x => (ofStd_halts_iff m.toStd x).symm⟩

end SelfModHalt