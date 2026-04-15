/-! # CatalogBuild.MachineLearning.Consciousness.Autopoiesis

Auto-generated from theorem catalog database.
Domain: MachineLearning/Consciousness
Declarations: 11
-/

import Mathlib

/-- A production network: components that produce other components -/
structure ProductionNetwork where
  Component : Type
  produces : Component → Component → Prop
  productive : ∀ c, ∃ c', produces c' c

/-! ## Autopoietic Organization -/

/-- An autopoietic system: a network that produces itself -/

structure AutopoieticSystem extends ProductionNetwork where
  boundary : Set Component
  boundary_maintained : ∀ c ∈ boundary, ∃ c', produces c' c
  operationally_closed : ∀ c₁ c₂, produces c₁ c₂ → ∃ c₃, produces c₃ c₁

/-
PROBLEM
An autopoietic system is self-producing

PROVIDED SOLUTION
This is exactly A.productive from the ProductionNetwork.
-/

theorem autopoietic_self_producing (A : AutopoieticSystem) :
    ∀ c : A.Component, ∃ c', A.produces c' c := by
  exact A.productive

/-! ## Operational Closure -/

/-- A system is operationally closed -/

def operationallyClosed (A : AutopoieticSystem) : Prop :=
  ∀ c₁ c₂ : A.Component, A.produces c₁ c₂ → ∃ c₃, A.produces c₃ c₁

/-
PROBLEM
Operational closure follows from autopoietic organization

PROVIDED SOLUTION
This is exactly A.operationally_closed.
-/

theorem autopoietic_implies_closed (A : AutopoieticSystem) :
    operationallyClosed A := by
  -- By definition of autopoietic system, we know that it has an operationally closed property.
  apply A.operationally_closed

/-! ## Structural Coupling -/

/-- Structural coupling: how an autopoietic system interacts with its environment -/

structure StructuralCoupling where
  system : AutopoieticSystem
  Environment : Type
  perturb : Environment → system.Component → system.Component
  maintains_organization : ∀ env c₁ c₂,
    system.produces c₁ c₂ → system.produces (perturb env c₁) (perturb env c₂)

/-
PROBLEM
Under structural coupling, the autopoietic organization is preserved

PROVIDED SOLUTION
This is exactly SC.maintains_organization env.
-/

theorem structural_coupling_preserves (SC : StructuralCoupling) (env : SC.Environment) :
    ∀ c₁ c₂ : SC.system.Component,
      SC.system.produces c₁ c₂ →
      SC.system.produces (SC.perturb env c₁) (SC.perturb env c₂) := by
  intro c₁ c₂ hc
  apply SC.maintains_organization env c₁ c₂ hc

/-! ## The Autopoietic Fixed Point -/

/-- The organization of an autopoietic system is a fixed point of its own dynamics -/

structure AutopoieticFixedPoint where
  State : Type
  dynamics : State → State
  organization : State → Prop
  org_preserved : ∀ s, organization s → organization (dynamics s)

/-
PROBLEM
The organization is an invariant set

PROVIDED SOLUTION
Induction on n. Base case: n=0, dynamics^[0] s = s, so org holds by h. Inductive step: dynamics^[n+1] s = dynamics (dynamics^[n] s), apply A.org_preserved to the IH.
-/

theorem organization_invariant (A : AutopoieticFixedPoint)
    (s : A.State) (h : A.organization s) (n : ℕ) :
    A.organization (A.dynamics^[n] s) := by
  induction n <;> simp_all +decide [ Function.iterate_succ_apply' ];
  exact A.org_preserved _ ‹_›

/-! ## Enactivism -/

/-- Enactivism: consciousness is enacted, not represented -/

structure Enactivism where
  Organism : Type
  World : Type
  enact : Organism → World
  shape : World → Organism
  circular : ∀ o, shape (enact o) = o → enact (shape (enact o)) = enact o

/-
PROBLEM
In an enactive system, experience and world are co-determined

PROVIDED SOLUTION
Apply E.circular o h.
-/

theorem enactive_codetermination (E : Enactivism) (o : E.Organism)
    (h : E.shape (E.enact o) = o) :
    E.enact (E.shape (E.enact o)) = E.enact o := by
  rw [ h ]

