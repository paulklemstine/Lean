/-
# The Computational Universe: Cellular Automata and Emergence

Rudy Rucker's later work, particularly "The Lifebox, the Seashell, and the Soul"
(2005), explores the idea that computation is fundamental to reality. He sees
cellular automata (CAs) as a key paradigm: simple local rules generating
complex global behavior.

This module formalizes basic properties of one-dimensional cellular automata
and related computational concepts.
-/

import Mathlib

namespace ComputationalUniverse

/-! ## One-Dimensional Cellular Automata

A 1D cellular automaton consists of a row of cells, each in one of finitely
many states, evolving according to a local rule. Rucker, influenced by
Wolfram, sees CAs as "the simplest possible models of computation." -/

/-- A 1D binary cellular automaton configuration is a function from ℤ to Bool. -/
def CAConfig := ℤ → Bool

/-- A neighborhood rule for a 1D CA with radius 1 looks at 3 cells. -/
def CArule := Bool → Bool → Bool → Bool

/-- Apply a CA rule to evolve one step. -/
def evolve (rule : CArule) (config : CAConfig) : CAConfig :=
  fun i => rule (config (i - 1)) (config i) (config (i + 1))

/-- Evolution is deterministic: same rule and initial config give same result. -/
theorem evolve_deterministic (rule : CArule) (c₁ c₂ : CAConfig)
    (h : c₁ = c₂) : evolve rule c₁ = evolve rule c₂ := by
  rw [h]

/-- Iterated evolution of a CA for n steps. -/
def evolve_n (rule : CArule) (config : CAConfig) : ℕ → CAConfig
  | 0 => config
  | n + 1 => evolve rule (evolve_n rule config n)

/-- Iterated evolution composes correctly. -/
theorem evolve_n_succ (rule : CArule) (config : CAConfig) (n : ℕ) :
    evolve_n rule config (n + 1) = evolve rule (evolve_n rule config n) :=
  rfl

/-! ## Shift Invariance

Rucker emphasizes that CAs are spatially homogeneous — the same rule
applies everywhere. This means evolution commutes with spatial shifts. -/

/-- Shift a configuration by k positions. -/
def shift (config : CAConfig) (k : ℤ) : CAConfig :=
  fun i => config (i + k)

/-- CA evolution commutes with spatial shifts — this formalizes
Rucker's observation about the "democratic" nature of CAs:
"every cell follows the same rule." -/
theorem evolve_shift_commute (rule : CArule) (config : CAConfig) (k : ℤ) :
    evolve rule (shift config k) = shift (evolve rule config) k :=
  funext fun x => by unfold evolve shift; ring_nf

/-! ## The Garden of Eden

Rucker discusses "Garden of Eden" configurations — states that cannot
arise from any predecessor. Their existence is a deep property of CAs. -/

/-- A Garden of Eden configuration has no predecessor under the given rule. -/
def is_garden_of_eden (rule : CArule) (config : CAConfig) : Prop :=
  ¬ ∃ prev : CAConfig, evolve rule prev = config

/-! ## Reversibility

Some CA rules are reversible (bijective on configurations). Rucker connects
this to the question of whether physics is fundamentally reversible. -/

/-- A CA rule is reversible if its evolution function is bijective. -/
def is_reversible (rule : CArule) : Prop :=
  Function.Bijective (evolve rule)

/-- A reversible CA has no Garden of Eden configurations. -/
theorem reversible_no_garden_of_eden (rule : CArule) (h : is_reversible rule) :
    ∀ config, ¬ is_garden_of_eden rule config := by
  intro config hgoe
  unfold is_garden_of_eden at hgoe
  exact hgoe ⟨_, (h.2 config).choose_spec⟩

/-! ## Decidability

Rucker discusses the Church-Turing thesis and the limits of computation.
We formalize some basic decidability results. -/

/-- The set of even natural numbers is decidable. -/
instance : DecidablePred (fun n : ℕ => n % 2 = 0) := inferInstance

end ComputationalUniverse
