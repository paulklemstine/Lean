/-! # CatalogBuild.Speculative.RudyRucker.ComputationalUniverse

Auto-generated from theorem catalog database.
Domain: Speculative/RudyRucker
Declarations: 11
-/

import Mathlib

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


/-- Shift a configuration by k positions. -/
def shift (config : CAConfig) (k : ℤ) : CAConfig :=
  fun i => config (i + k)


/-- CA evolution commutes with spatial shifts — this formalizes
Rucker's observation about the "democratic" nature of CAs:
"every cell follows the same rule." -/
theorem evolve_shift_commute (rule : CArule) (config : CAConfig) (k : ℤ) :
    evolve rule (shift config k) = shift (evolve rule config) k :=
  funext fun x => by unfold evolve shift; ring_nf


/-- A Garden of Eden configuration has no predecessor under the given rule. -/
def is_garden_of_eden (rule : CArule) (config : CAConfig) : Prop :=
  ¬ ∃ prev : CAConfig, evolve rule prev = config


/-- A CA rule is reversible if its evolution function is bijective. -/
def is_reversible (rule : CArule) : Prop :=
  Function.Bijective (evolve rule)


/-- A reversible CA has no Garden of Eden configurations. -/
theorem reversible_no_garden_of_eden (rule : CArule) (h : is_reversible rule) :
    ∀ config, ¬ is_garden_of_eden rule config := by
  intro config hgoe
  unfold is_garden_of_eden at hgoe
  exact hgoe ⟨_, (h.2 config).choose_spec⟩

