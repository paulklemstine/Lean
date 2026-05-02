import Mathlib

/-! # CatalogBuild.MachineLearning.Consciousness.Autopoiesis

Auto-generated from theorem catalog database.
Domain: MachineLearning/Consciousness
Declarations: 11
-/


/-- A production network: components that produce other components -/
structure ProductionNetwork where
  Component : Type
  produces : Component → Component → Prop
  productive : ∀ c, ∃ c', produces c' c




/-- An autopoietic system: a network that produces itself -/
structure AutopoieticSystem extends ProductionNetwork where
  boundary : Set Component
  boundary_maintained : ∀ c ∈ boundary, ∃ c', produces c' c
  operationally_closed : ∀ c₁ c₂, produces c₁ c₂ → ∃ c₃, produces c₃ c₁




/-- [Section: # CatalogBuild.MachineLearning.Consciousness.Autopoiesis
Auto-generated from theorem catalog database.
Domain: MachineLearning/Consciousness
Declarations: 11] -/
theorem autopoietic_self_producing (A : AutopoieticSystem) :
    ∀ c : A.Component, ∃ c', A.produces c' c := by
  exact A.productive




/-- A system is operationally closed -/
def operationallyClosed (A : AutopoieticSystem) : Prop :=
  ∀ c₁ c₂ : A.Component, A.produces c₁ c₂ → ∃ c₃, A.produces c₃ c₁




/-- [Section: # CatalogBuild.MachineLearning.Consciousness.Autopoiesis
Auto-generated from theorem catalog database.
Domain: MachineLearning/Consciousness
Declarations: 11] -/
theorem autopoietic_implies_closed (A : AutopoieticSystem) :
    operationallyClosed A := by
  -- By definition of autopoietic system, we know that it has an operationally closed property.
  apply A.operationally_closed




/-- Structural coupling: how an autopoietic system interacts with its environment -/
structure StructuralCoupling where
  system : AutopoieticSystem
  Environment : Type
  perturb : Environment → system.Component → system.Component
  maintains_organization : ∀ env c₁ c₂,
    system.produces c₁ c₂ → system.produces (perturb env c₁) (perturb env c₂)




theorem structural_coupling_preserves (SC : StructuralCoupling) (env : SC.Environment) :
    ∀ c₁ c₂ : SC.system.Component,
      SC.system.produces c₁ c₂ →
      SC.system.produces (SC.perturb env c₁) (SC.perturb env c₂) := by
  intro c₁ c₂ hc
  apply SC.maintains_organization env c₁ c₂ hc




/-- The organization of an autopoietic system is a fixed point of its own dynamics -/
structure AutopoieticFixedPoint where
  State : Type
  dynamics : State → State
  organization : State → Prop
  org_preserved : ∀ s, organization s → organization (dynamics s)




theorem organization_invariant (A : AutopoieticFixedPoint)
    (s : A.State) (h : A.organization s) (n : ℕ) :
    A.organization (A.dynamics^[n] s) := by
  induction n <;> simp_all +decide [ Function.iterate_succ_apply' ];
  exact A.org_preserved _ ‹_›




/-- Enactivism: consciousness is enacted, not represented -/
structure Enactivism where
  Organism : Type
  World : Type
  enact : Organism → World
  shape : World → Organism
  circular : ∀ o, shape (enact o) = o → enact (shape (enact o)) = enact o




theorem enactive_codetermination (E : Enactivism) (o : E.Organism)
    (h : E.shape (E.enact o) = o) :
    E.enact (E.shape (E.enact o)) = E.enact o := by
  rw [ h ]