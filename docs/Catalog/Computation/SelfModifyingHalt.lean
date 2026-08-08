import Mathlib

/-!
# Halting for self-modifying machines

A *self-modifying* machine rewrites its own program while it runs: a step reads
the current program together with the current state and returns a new
program–state pair (or nothing, which is how a run halts).  This file develops
the elementary degree theory of such machines:

* `SelfModMachine`, `SelfModConfig`, `SelfModMachine.run`, `SelfModMachine.halts`;
* the *fixed-program* simulation `SelfModMachine.toStd`, a `StdMachine` on the
  product `P × S` that stores the changing code inside the state;
* `selfmod_halts_iff_standard`, the exact run-by-run correspondence between the
  two, and the resulting many-one reductions
  `selfmod_halting_reduces_to_standard` and `selfmod_halting_turing_equiv`.

The point of the correspondence is negative: unrestricted self-modification does
not raise the degree of the halting question, because the state can always carry
the code.
-/

namespace SelfModHalt

variable {α β γ : Sort*} {P S T : Type*}

/-- Many-one reducibility between predicates on arbitrary sorts: `A` reduces to
`B` when some function pulls `B` back to `A`. -/
def ManyOneReduces (A : α → Prop) (B : β → Prop) : Prop :=
  ∃ f : α → β, ∀ a, A a ↔ B (f a)

theorem ManyOneReduces.refl (A : α → Prop) : ManyOneReduces A A :=
  ⟨id, fun _ => Iff.rfl⟩

theorem ManyOneReduces.trans {A : α → Prop} {B : β → Prop} {C : γ → Prop}
    (hAB : ManyOneReduces A B) (hBC : ManyOneReduces B C) : ManyOneReduces A C := by
  obtain ⟨f, hf⟩ := hAB
  obtain ⟨g, hg⟩ := hBC
  exact ⟨g ∘ f, fun a => (hf a).trans (hg (f a))⟩

/-! ### Fixed-program machines -/

/-- A machine with a fixed program: a partial step function on configurations. -/
structure StdMachine (T : Type*) where
  /-- One computation step; `none` means the machine has stopped. -/
  step : T → Option T

/-- The configuration after `n` steps, if the machine is still running. -/
def StdMachine.run (m : StdMachine T) (t : T) : ℕ → Option T
  | 0 => some t
  | n + 1 => (m.run t n).bind m.step

/-- A fixed-program machine halts when some finite run is undefined. -/
def StdMachine.halts (m : StdMachine T) (t : T) : Prop := ∃ n, m.run t n = Option.none

/-- An exact Boolean decider for the halting problem of a fixed-program
machine. -/
def StdHaltingDecider (m : StdMachine T) (d : T → Bool) : Prop :=
  ∀ t, d t = true ↔ m.halts t

/-! ### Self-modifying machines -/

/-- A configuration of a self-modifying machine: the current program together
with the current state. -/
structure SelfModConfig (P S : Type*) where
  /-- The program currently being executed. -/
  prog : P
  /-- The current data state. -/
  state : S

/-- A self-modifying machine: one step may rewrite the program as well as the
state. -/
structure SelfModMachine (P S : Type*) where
  /-- One computation step; `none` means the machine has stopped. -/
  step : P → S → Option (P × S)

/-- The configuration after `n` steps, if the machine is still running. -/
def SelfModMachine.run (m : SelfModMachine P S) (cfg : SelfModConfig P S) :
    ℕ → Option (SelfModConfig P S)
  | 0 => some cfg
  | n + 1 => (m.run cfg n).bind fun c => (m.step c.prog c.state).map fun ps => ⟨ps.1, ps.2⟩

/-- A self-modifying machine halts when some finite run is undefined. -/
def SelfModMachine.halts (m : SelfModMachine P S) (cfg : SelfModConfig P S) : Prop :=
  ∃ n, m.run cfg n = Option.none

/-- **Storing the code in the state.**  The fixed-program simulation of a
self-modifying machine, running on the product `P × S`. -/
def SelfModMachine.toStd (m : SelfModMachine P S) : StdMachine (P × S) :=
  ⟨fun ps => m.step ps.1 ps.2⟩

/-- The two runs agree step by step, up to the bijection
`⟨p, s⟩ ↔ (p, s)`. -/
theorem run_toStd (m : SelfModMachine P S) (cfg : SelfModConfig P S) (n : ℕ) :
    m.run cfg n
      = (m.toStd.run (cfg.prog, cfg.state) n).map fun ps => ⟨ps.1, ps.2⟩ := by
  induction n with
  | zero => rfl
  | succ n ih =>
      rw [SelfModMachine.run, ih, StdMachine.run]
      cases h : m.toStd.run (cfg.prog, cfg.state) n with
      | none => simp
      | some ps => simp [SelfModMachine.toStd]

/-- **Exact simulation.**  A self-modifying machine halts precisely when its
fixed-program simulation does. -/
theorem selfmod_halts_iff_standard (m : SelfModMachine P S) (cfg : SelfModConfig P S) :
    m.halts cfg ↔ m.toStd.halts (cfg.prog, cfg.state) := by
  unfold SelfModMachine.halts StdMachine.halts
  constructor
  · rintro ⟨n, hn⟩
    refine ⟨n, ?_⟩
    rw [run_toStd] at hn
    exact Option.map_eq_none_iff.mp hn
  · rintro ⟨n, hn⟩
    exact ⟨n, by rw [run_toStd, hn]; rfl⟩

/-- The halting problem of a self-modifying machine many-one reduces to that of
its fixed-program simulation. -/
theorem selfmod_halting_reduces_to_standard (m : SelfModMachine P S) :
    ManyOneReduces m.halts m.toStd.halts :=
  ⟨fun cfg => (cfg.prog, cfg.state), selfmod_halts_iff_standard m⟩

/-- The one-program self-modifying machine that re-runs the fixed-program
simulation. -/
def stdAsSelfMod (m : SelfModMachine P S) : SelfModMachine Unit (P × S) :=
  ⟨fun _ ps => (m.step ps.1 ps.2).map fun q => ((), q)⟩

theorem run_stdAsSelfMod (m : SelfModMachine P S) (ps : P × S) (n : ℕ) :
    (stdAsSelfMod m).run ⟨(), ps⟩ n
      = (m.toStd.run ps n).map fun q => ⟨(), q⟩ := by
  induction n with
  | zero => rfl
  | succ n ih =>
      rw [SelfModMachine.run, ih, StdMachine.run]
      cases h : m.toStd.run ps n with
      | none => simp
      | some q =>
          simp only [stdAsSelfMod, SelfModMachine.toStd, Option.map_map]
          rfl

/-- **Turing equivalence.**  Self-modification and fixed-program computation
have the same halting degree: each halting problem reduces to the other. -/
theorem selfmod_halting_turing_equiv (m : SelfModMachine P S) :
    ManyOneReduces m.halts m.toStd.halts ∧
      ∃ m' : SelfModMachine Unit (P × S), ManyOneReduces m.toStd.halts m'.halts := by
  refine ⟨selfmod_halting_reduces_to_standard m, stdAsSelfMod m, fun ps => ⟨(), ps⟩, ?_⟩
  intro ps
  unfold SelfModMachine.halts StdMachine.halts
  constructor
  · rintro ⟨n, hn⟩
    exact ⟨n, by rw [run_stdAsSelfMod, hn]; rfl⟩
  · rintro ⟨n, hn⟩
    rw [run_stdAsSelfMod] at hn
    exact ⟨n, Option.map_eq_none_iff.mp hn⟩

end SelfModHalt