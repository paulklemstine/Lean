import Mathlib

/-! # Self-modifying machines and their halting problem

This module supplies the machine model used by
`Novelty.SelfModifyingUndecidability`, whose own import of it was lost from the catalog
snapshot: a *self-modifying* machine carries its program inside the configuration and
may rewrite it at every step, whereas a *standard* machine has a fixed transition
function on a state space.

The main content is the simulation lemma `selfmod_halts_iff_standard` ("code is data"):
storing the changing program in the state turns a self-modifying machine into an
ordinary one with the *same* halting behaviour, so self-modification does not raise the
degree of the halting problem.
-/

namespace SelfModHalt

/-- Many-one reducibility between predicates on arbitrary types: `A` reduces to `B` when
there is a map `f` with `A x ↔ B (f x)`. -/
def ManyOneReduces {α β : Sort*} (A : α → Prop) (B : β → Prop) : Prop :=
  ∃ f : α → β, ∀ x, A x ↔ B (f x)

theorem ManyOneReduces.refl {α : Sort*} (A : α → Prop) : ManyOneReduces A A :=
  ⟨id, fun _ => Iff.rfl⟩

theorem ManyOneReduces.trans {α β γ : Sort*} {A : α → Prop} {B : β → Prop} {C : γ → Prop}
    (hAB : ManyOneReduces A B) (hBC : ManyOneReduces B C) : ManyOneReduces A C := by
  obtain ⟨f, hf⟩ := hAB
  obtain ⟨g, hg⟩ := hBC
  exact ⟨g ∘ f, fun x => (hf x).trans (hg (f x))⟩

/-- A configuration of a self-modifying machine: the current program together with the
current state. -/
structure SelfModConfig (P S : Type*) where
  /-- The current (rewritable) program. -/
  prog : P
  /-- The current state. -/
  state : S

/-- A self-modifying machine: one step may rewrite the program as well as the state, and
returns `none` when the machine halts. -/
structure SelfModMachine (P S : Type*) where
  /-- The one-step transition; `none` means "halted". -/
  step : SelfModConfig P S → Option (SelfModConfig P S)

/-- A machine with a fixed program: one step transforms the state, and returns `none`
when the machine halts. -/
structure StdMachine (X : Type*) where
  /-- The one-step transition; `none` means "halted". -/
  step : X → Option X

variable {P S X : Type*}

/-- `n` steps of a self-modifying machine; `none` records that the run has halted. -/
def SelfModMachine.run (m : SelfModMachine P S) (cfg : SelfModConfig P S) :
    ℕ → Option (SelfModConfig P S)
  | 0 => some cfg
  | n + 1 => (m.run cfg n).bind m.step

/-- `n` steps of a fixed-program machine. -/
def StdMachine.run (M : StdMachine X) (x : X) : ℕ → Option X
  | 0 => some x
  | n + 1 => (M.run x n).bind M.step

/-- A self-modifying machine halts on a configuration when some finite run is undefined. -/
def SelfModMachine.halts (m : SelfModMachine P S) (cfg : SelfModConfig P S) : Prop :=
  ∃ n, m.run cfg n = none

/-- A fixed-program machine halts on a state when some finite run is undefined. -/
def StdMachine.halts (M : StdMachine X) (x : X) : Prop :=
  ∃ n, M.run x n = none

/-- `d` decides the halting problem of the fixed-program machine `M`. -/
def StdHaltingDecider (M : StdMachine X) (d : X → Bool) : Prop :=
  ∀ x, d x = true ↔ M.halts x

/-- The fixed-program simulation of a self-modifying machine: the program is stored in
the state, so the transition function is fixed. -/
def SelfModMachine.toStd (m : SelfModMachine P S) : StdMachine (P × S) :=
  ⟨fun x => (m.step ⟨x.1, x.2⟩).map (fun c => (c.prog, c.state))⟩

/-- Step-for-step simulation: the fixed-program run is the self-modifying run, read
through the "code is data" bijection. -/
theorem toStd_run (m : SelfModMachine P S) (cfg : SelfModConfig P S) (n : ℕ) :
    m.toStd.run (cfg.prog, cfg.state) n
      = (m.run cfg n).map (fun c => (c.prog, c.state)) := by
  induction n with
  | zero => rfl
  | succ n ih =>
      rw [StdMachine.run, ih, SelfModMachine.run]
      cases h : m.run cfg n with
      | none => simp
      | some c => simp [SelfModMachine.toStd]

/-- **Code is data.**  A self-modifying machine halts exactly when its fixed-program
simulation halts. -/
theorem selfmod_halts_iff_standard (m : SelfModMachine P S) (cfg : SelfModConfig P S) :
    m.halts cfg ↔ m.toStd.halts (cfg.prog, cfg.state) := by
  constructor
  · rintro ⟨n, hn⟩
    exact ⟨n, by rw [toStd_run, hn]; rfl⟩
  · rintro ⟨n, hn⟩
    refine ⟨n, ?_⟩
    rw [toStd_run] at hn
    cases h : m.run cfg n with
    | none => rfl
    | some c => rw [h] at hn; exact absurd hn (by simp)

/-- The halting problem of a self-modifying machine reduces to that of its
fixed-program simulation. -/
theorem selfmod_halting_reduces_to_standard (m : SelfModMachine P S) :
    ManyOneReduces m.halts m.toStd.halts :=
  ⟨fun cfg => (cfg.prog, cfg.state), selfmod_halts_iff_standard m⟩

/-- Every fixed-program machine is a self-modifying machine with a one-element program
type, with the same halting behaviour. -/
def StdMachine.toSelfMod (M : StdMachine X) : SelfModMachine Unit X :=
  ⟨fun c => (M.step c.state).map (fun y => ⟨(), y⟩)⟩

theorem toSelfMod_run (M : StdMachine X) (x : X) (n : ℕ) :
    M.toSelfMod.run ⟨(), x⟩ n = (M.run x n).map (fun y => ⟨(), y⟩) := by
  induction n with
  | zero => rfl
  | succ n ih =>
      rw [SelfModMachine.run, ih, StdMachine.run]
      cases h : M.run x n with
      | none => simp
      | some y => simp [StdMachine.toSelfMod]

theorem std_halts_iff_selfmod (M : StdMachine X) (x : X) :
    M.halts x ↔ M.toSelfMod.halts ⟨(), x⟩ := by
  constructor
  · rintro ⟨n, hn⟩
    exact ⟨n, by rw [toSelfMod_run, hn]; rfl⟩
  · rintro ⟨n, hn⟩
    refine ⟨n, ?_⟩
    rw [toSelfMod_run] at hn
    cases h : M.run x n with
    | none => rfl
    | some y => rw [h] at hn; exact absurd hn (by simp)

/-- **Mutual reducibility.**  Self-modifying halting and fixed-program halting are
many-one interreducible: the rewrite capability changes the operational presentation but
not the computability degree. -/
theorem selfmod_halting_turing_equiv (m : SelfModMachine P S) :
    ManyOneReduces m.halts m.toStd.halts ∧
      ∃ m' : SelfModMachine Unit (P × S), ManyOneReduces m.toStd.halts m'.halts :=
  ⟨selfmod_halting_reduces_to_standard m,
    m.toStd.toSelfMod, fun x => ⟨(), x⟩, std_halts_iff_selfmod m.toStd⟩

end SelfModHalt