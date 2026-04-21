/-! # CatalogBuild.MachineLearning.Consciousness.GlobalWorkspace

Auto-generated from theorem catalog database.
Domain: MachineLearning/Consciousness
Declarations: 7
-/

import Mathlib

/-- A processor in the global workspace architecture -/
structure GWProcessor where
  LocalState : Type
  Domain : Type
  process : LocalState → LocalState
  relevance : LocalState → ℝ




/-- A coalition of processors -/
structure Coalition (n : ℕ) where
  processors : Fin n → GWProcessor
  members : Finset (Fin n)
  strength : ℝ




/-- The global workspace: a broadcast channel -/
structure GlobalWorkspace (n : ℕ) where
  Content : Type
  processors : Fin n → GWProcessor
  currentContent : Content
  broadcast : Content → Fin n → GWProcessor → GWProcessor




/-- The ignition event: when a coalition wins and broadcasts -/
structure Ignition (n : ℕ) where
  workspace : GlobalWorkspace n
  content : workspace.Content
  global_access : ∀ i : Fin n, True




/-- [Section: # CatalogBuild.MachineLearning.Consciousness.GlobalWorkspace
Auto-generated from theorem catalog database.
Domain: MachineLearning/Consciousness
Declarations: 7] -/
theorem broadcasting_theorem {n : ℕ} (ign : Ignition n) (i : Fin n) :
    ign.global_access i = trivial := by
  rfl




/-- The "spotlight of attention" selects content for the global workspace. -/
structure Spotlight where
  Contents : Type
  inSpotlight : Contents → Prop
  narrow : ∃ c, ¬ inSpotlight c
  nonempty : ∃ c, inSpotlight c




/-- [Section: # CatalogBuild.MachineLearning.Consciousness.GlobalWorkspace
Auto-generated from theorem catalog database.
Domain: MachineLearning/Consciousness
Declarations: 7] -/
theorem spotlight_always_on (sp : Spotlight) : ∃ c, sp.inSpotlight c := by
  exact sp.nonempty



