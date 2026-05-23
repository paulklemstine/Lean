/-
  # Compositional Phase Gauge Systems: Core Definitions

  This module defines the foundational structures for a compositional theory
  of discrete lattice gauge systems with phase observables.

  ## Mathematical Context

  In lattice gauge theory, gauge fields are modeled as edge-labelings by a group G.
  Holonomy around a plaquette (elementary closed loop) is a product of edge labels.
  Phase observables are obtained by composing holonomy with a character (group homomorphism
  to an abelian phase group Φ).

  The central insight: when gauge groups and phase characters decompose over products,
  all gauge observables — holonomies, phases, partition functions — factorize accordingly.
  This is a discrete analogue of Künneth-type decomposition in gauge field theory.

  ## Key Definitions

  - `PhaseGaugeSystem`: abstract gauge system with plaquette phases and gauge invariance
  - `FinitePhaseGaugeSystem`: finite version with explicit holonomy and phase map
  - `prodSystem`: product of two finite phase gauge systems
  - `phasePartitionFunction`: finite partition sum over all gauge configurations
  - `totalPhase`: product of all plaquette phases for a configuration
-/
import Mathlib

open Finset BigOperators

/-! ## Core Gauge System Structures -/

/-- A `PhaseGaugeSystem` models a discrete lattice gauge theory with phase observables.
    - `G` is the gauge group (edge labels)
    - `Φ` is the phase group (observable values)
    - `V` is the vertex set
    - `E` is the edge set
    - `P` is the plaquette (elementary loop) set
    The key axiom is gauge invariance: vertex gauge transformations do not change
    plaquette phase observables. -/
structure PhaseGaugeSystem (G Φ V E P : Type*) [Group G] [CommMonoid Φ] where
  /-- Computes the phase observable for a plaquette given a gauge field configuration -/
  plaquettePhase : (E → G) → P → Φ
  /-- Applies a vertex gauge transformation to a gauge field configuration -/
  gaugeAction : (V → G) → (E → G) → (E → G)
  /-- Fundamental gauge invariance: plaquette phases are unchanged under gauge transformations -/
  gauge_invariant :
    ∀ (γ : V → G) (A : E → G) (p : P),
      plaquettePhase (gaugeAction γ A) p = plaquettePhase A p

/-- A `FinitePhaseGaugeSystem` is a concrete finite gauge system where:
    - Holonomy computes the group element around each plaquette
    - Phase maps holonomy values to an abelian phase group
    - Gauge transformations act on edge configurations
    - Holonomy is gauge-invariant (the key physical axiom) -/
structure FinitePhaseGaugeSystem (G Φ V E P : Type*)
    [Fintype G] [DecidableEq G] [Group G]
    [Fintype Φ] [DecidableEq Φ] [CommMonoid Φ]
    [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    [Fintype P] [DecidableEq P] where
  /-- Computes the holonomy (product of edge labels) around a plaquette -/
  holonomy : (E → G) → P → G
  /-- Maps a holonomy value to a phase observable -/
  phase : G → Φ
  /-- Applies a vertex gauge transformation to edge configurations -/
  gaugeAction : (V → G) → (E → G) → (E → G)
  /-- Holonomy is invariant under gauge transformations -/
  holonomy_gauge_invariant :
    ∀ (γ : V → G) (A : E → G) (p : P),
      holonomy (gaugeAction γ A) p = holonomy A p

namespace FinitePhaseGaugeSystem

variable {G Φ V E P : Type*}
  [Fintype G] [DecidableEq G] [Group G]
  [Fintype Φ] [DecidableEq Φ] [CommMonoid Φ]
  [Fintype V] [DecidableEq V]
  [Fintype E] [DecidableEq E]
  [Fintype P] [DecidableEq P]

/-- The plaquette phase observable: composition of holonomy and phase map. -/
def plaquettePhase (S : FinitePhaseGaugeSystem G Φ V E P) (A : E → G) (p : P) : Φ :=
  S.phase (S.holonomy A p)

/-- A `FinitePhaseGaugeSystem` gives rise to a `PhaseGaugeSystem`. -/
def toPhaseGaugeSystem (S : FinitePhaseGaugeSystem G Φ V E P) :
    PhaseGaugeSystem G Φ V E P where
  plaquettePhase := S.plaquettePhase
  gaugeAction := S.gaugeAction
  gauge_invariant γ A p := by
    simp [plaquettePhase, S.holonomy_gauge_invariant γ A p]

end FinitePhaseGaugeSystem

/-! ## Product System Construction -/

/-- The product of two finite phase gauge systems on the same lattice (V, E, P).
    The gauge group is `G₁ × G₂`, and the phase monoid is `Φ`.
    Phase values combine multiplicatively: `phase_prod g = phase₁ g.1 * phase₂ g.2`. -/
def prodSystem
    {G₁ G₂ Φ V E P : Type*}
    [Fintype G₁] [DecidableEq G₁] [Group G₁]
    [Fintype G₂] [DecidableEq G₂] [Group G₂]
    [Fintype Φ] [DecidableEq Φ] [CommMonoid Φ]
    [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    [Fintype P] [DecidableEq P]
    (S₁ : FinitePhaseGaugeSystem G₁ Φ V E P)
    (S₂ : FinitePhaseGaugeSystem G₂ Φ V E P) :
    FinitePhaseGaugeSystem (G₁ × G₂) Φ V E P where
  holonomy A p := (S₁.holonomy (fun e => (A e).1) p, S₂.holonomy (fun e => (A e).2) p)
  phase g := S₁.phase g.1 * S₂.phase g.2
  gaugeAction γ A e := (S₁.gaugeAction (fun v => (γ v).1) (fun e => (A e).1) e,
                         S₂.gaugeAction (fun v => (γ v).2) (fun e => (A e).2) e)
  holonomy_gauge_invariant γ A p := by
    simp only [Prod.mk.injEq]
    exact ⟨S₁.holonomy_gauge_invariant (fun v => (γ v).1) (fun e => (A e).1) p,
           S₂.holonomy_gauge_invariant (fun v => (γ v).2) (fun e => (A e).2) p⟩

/-! ## Partition Function and Total Phase -/

/-- The total phase of a gauge configuration: the product of phase observables
    over all plaquettes. This is the "Boltzmann weight" of the configuration
    in the multiplicative formulation. -/
noncomputable def totalPhase
    {G Φ V E P : Type*}
    [Group G] [CommMonoid Φ]
    [Fintype P]
    (S : PhaseGaugeSystem G Φ V E P) (A : E → G) : Φ :=
  ∏ p : P, S.plaquettePhase A p

/-- The phase partition function: product over all gauge field configurations
    of the total phase weight. In multiplicative notation, this is
    `∏_A ∏_p phase(holonomy(A, p))`. -/
noncomputable def phasePartitionFunction
    {G Φ V E P : Type*}
    [Fintype G] [DecidableEq G] [Group G]
    [Fintype Φ] [DecidableEq Φ] [CommMonoid Φ]
    [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    [Fintype P] [DecidableEq P]
    (S : FinitePhaseGaugeSystem G Φ V E P) : Φ :=
  ∏ A : (E → G), ∏ p : P, S.plaquettePhase A p

/-- The total phase using a finite phase gauge system. -/
noncomputable def finiteTotalPhase
    {G Φ V E P : Type*}
    [Fintype G] [DecidableEq G] [Group G]
    [Fintype Φ] [DecidableEq Φ] [CommMonoid Φ]
    [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    [Fintype P] [DecidableEq P]
    (S : FinitePhaseGaugeSystem G Φ V E P) (A : E → G) : Φ :=
  ∏ p : P, S.plaquettePhase A p

/-! ## Gauge-Invariant Observable -/

/-- A gauge-invariant observable is a function on gauge configurations
    that is invariant under all gauge transformations. -/
structure GaugeInvariantObservable (G Φ V E : Type*) [Group G] [CommMonoid Φ] where
  /-- The observable function -/
  obs : (E → G) → Φ
  /-- Gauge action on configurations -/
  act : (V → G) → (E → G) → (E → G)
  /-- Invariance under gauge transformations -/
  invariant : ∀ (γ : V → G) (A : E → G), obs (act γ A) = obs A

/-! ## Equivalence for Product Function Types -/

/-- The canonical equivalence between functions into a product and pairs of functions.
    This is fundamental for decomposing product gauge configurations. -/
def funProdEquiv (E G₁ G₂ : Type*) : (E → G₁ × G₂) ≃ (E → G₁) × (E → G₂) where
  toFun f := (fun e => (f e).1, fun e => (f e).2)
  invFun p := fun e => (p.1 e, p.2 e)
  left_inv f := by ext e <;> simp
  right_inv p := by ext <;> simp

/-! ## Profinite Approximation -/

/-- A profinite phase approximation models an inverse system of finite gauge groups
    with compatible phase maps. This is the mathematical bridge from finite
    combinatorial gauge models to continuous/profinite gauge physics. -/
structure ProfinitePhaseApproximation (ι : Type*) [Preorder ι] where
  /-- The gauge group at each level -/
  G : ι → Type*
  /-- Each level has a group structure -/
  instGroup : ∀ i, Group (G i)
  /-- Projection maps between levels -/
  proj : ∀ {i j : ι}, i ≤ j → G j →* G i
  /-- Projections compose correctly -/
  compat : ∀ {i j k : ι} (hij : i ≤ j) (hjk : j ≤ k),
    (proj hij).comp (proj hjk) = proj (le_trans hij hjk)