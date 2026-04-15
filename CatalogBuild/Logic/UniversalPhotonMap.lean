/-! # CatalogBuild.Logic.UniversalPhotonMap

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 26
-/

import Mathlib

noncomputable section

/-- A vertex in the photon graph: a spacetime event. -/
structure PhotonVertex where
  x : ℤ
  y : ℤ
  t : ℤ
  deriving DecidableEq, Repr

/-- A directed edge: a photon worldline from emission to absorption. -/

structure PhotonArc where
  source : PhotonVertex
  target : PhotonVertex
  null_condition : (target.x - source.x)^2 + (target.y - source.y)^2 =
                   (target.t - source.t)^2
  causal : source.t < target.t

/-- The universal photon graph. -/

structure PhotonGraph where
  vertices : Finset PhotonVertex
  arcs : Finset PhotonArc
  source_mem : ∀ a ∈ arcs, a.source ∈ vertices
  target_mem : ∀ a ∈ arcs, a.target ∈ vertices

/-! ## Section 2: How Photons Connect -/

/-- Two arcs are connected if one's target is the other's source. -/

def PhotonArc.connectedTo (a₁ a₂ : PhotonArc) : Prop :=
  a₁.target = a₂.source

/-- A photon path: a sequence of connected arcs. -/

inductive PhotonPath : PhotonVertex → PhotonVertex → Prop where
  | single (a : PhotonArc) : PhotonPath a.source a.target
  | cons (a : PhotonArc) {v : PhotonVertex}
    (rest : PhotonPath a.target v) : PhotonPath a.source v

/-- Time is strictly monotone along any photon path. -/

theorem PhotonPath.time_monotone {u v : PhotonVertex} (p : PhotonPath u v) :
    u.t < v.t := by
  induction p with
  | single a => exact a.causal
  | cons a _ ih => linarith [a.causal]

/-- **The graph is a DAG**: No vertex can reach itself. -/

theorem photon_graph_acyclic (v : PhotonVertex) : ¬ PhotonPath v v := by
  intro h; have := h.time_monotone; omega

/-! ## Section 3: Graph Structure -/

/-- The in-degree of a vertex. -/

noncomputable def PhotonGraph.inDegree (G : PhotonGraph) (v : PhotonVertex) : ℕ :=
  (G.arcs.filter (fun a => a.target = v)).card

/-- The out-degree of a vertex. -/

noncomputable def PhotonGraph.outDegree (G : PhotonGraph) (v : PhotonVertex) : ℕ :=
  (G.arcs.filter (fun a => a.source = v)).card

/-- A scattering event has both incoming and outgoing photons. -/

def PhotonGraph.isScatteringEvent (G : PhotonGraph) (v : PhotonVertex) : Prop :=
  G.inDegree v > 0 ∧ G.outDegree v > 0

/-! ## Section 4: The Photon Graph IS a Map -/

/-- The state at a time slice: all active photons. -/

def PhotonGraph.stateAtTime (G : PhotonGraph) (time : ℤ) : Finset PhotonArc :=
  G.arcs.filter (fun a => a.source.t ≤ time ∧ time < a.target.t)

/-- **The photon graph IS a map**: it defines a unique state at each time. -/

theorem photon_graph_is_map (G : PhotonGraph) (t : ℤ) :
    ∃! s : Finset PhotonArc, s = G.stateAtTime t :=
  ⟨G.stateAtTime t, rfl, fun _ h => h⟩

/-! ## Section 5: The Big Graph — Connectivity -/

/-- Two photons are adjacent if they share a spacetime event. -/

def photonsAdjacent (a₁ a₂ : PhotonArc) : Prop :=
  a₁.target = a₂.source ∨ a₂.target = a₁.source

/-- Adjacency is symmetric. -/

theorem photonsAdjacent_symm (a₁ a₂ : PhotonArc) :
    photonsAdjacent a₁ a₂ → photonsAdjacent a₂ a₁ := by
  intro h; rcases h with h | h
  · exact Or.inr h
  · exact Or.inl h

/-- The undirected photon graph. -/

structure UndirectedPhotonGraph where
  photons : Finset PhotonArc
  adj : PhotonArc → PhotonArc → Prop
  adj_symm : ∀ a₁ a₂, adj a₁ a₂ → adj a₂ a₁

/-- Convert directed → undirected. -/

def PhotonGraph.toUndirected (G : PhotonGraph) : UndirectedPhotonGraph where
  photons := G.arcs
  adj := photonsAdjacent
  adj_symm := photonsAdjacent_symm

/-- Reachability in the undirected graph. -/

inductive UndirectedReachable (G : UndirectedPhotonGraph) :
    PhotonArc → PhotonArc → Prop where
  | refl (a : PhotonArc) : UndirectedReachable G a a
  | step (a b c : PhotonArc) :
    a ∈ G.photons → b ∈ G.photons →
    G.adj a b → UndirectedReachable G b c → UndirectedReachable G a c

/-- Reachability is transitive. -/

theorem UndirectedReachable.trans (G : UndirectedPhotonGraph)
    {a b c : PhotonArc}
    (hab : UndirectedReachable G a b)
    (hbc : UndirectedReachable G b c) :
    UndirectedReachable G a c := by
  induction hab with
  | refl => exact hbc
  | step a' b' _ ha hb hadj _ ih => exact .step a' b' _ ha hb hadj (ih hbc)

/-- A connected photon graph: all photons can reach each other. -/

def PhotonGraph.isConnected (G : PhotonGraph) : Prop :=
  ∀ a₁ a₂, a₁ ∈ G.arcs → a₂ ∈ G.arcs →
    UndirectedReachable G.toUndirected a₁ a₂

/-- **Is the universe one big connected graph?**
    If the photon graph is connected, all photons are reachable from each other. -/

theorem universe_connectivity_principle (G : PhotonGraph) (hconn : G.isConnected)
    (a₁ a₂ : PhotonArc) (h₁ : a₁ ∈ G.arcs) (h₂ : a₂ ∈ G.arcs) :
    UndirectedReachable G.toUndirected a₁ a₂ :=
  hconn a₁ a₂ h₁ h₂

/-! ## Section 6: Graph Morphisms -/

/-- A photon graph morphism. -/

structure PhotonGraphMorphism (G₁ G₂ : PhotonGraph) where
  onVertices : PhotonVertex → PhotonVertex
  onArcs : PhotonArc → PhotonArc
  arcs_mem : ∀ a ∈ G₁.arcs, onArcs a ∈ G₂.arcs
  preserves_source : ∀ a ∈ G₁.arcs, (onArcs a).source = onVertices a.source
  preserves_target : ∀ a ∈ G₁.arcs, (onArcs a).target = onVertices a.target

/-- The identity morphism. -/

def PhotonGraphMorphism.id' (G : PhotonGraph) : PhotonGraphMorphism G G where
  onVertices := id
  onArcs := id
  arcs_mem := fun _ ha => ha
  preserves_source := fun _ _ => rfl
  preserves_target := fun _ _ => rfl

/-- Composition of morphisms. -/

def PhotonGraphMorphism.comp' {G₁ G₂ G₃ : PhotonGraph}
    (f : PhotonGraphMorphism G₁ G₂) (g : PhotonGraphMorphism G₂ G₃) :
    PhotonGraphMorphism G₁ G₃ where
  onVertices := g.onVertices ∘ f.onVertices
  onArcs := g.onArcs ∘ f.onArcs
  arcs_mem := fun a ha => g.arcs_mem _ (f.arcs_mem a ha)
  preserves_source := fun a ha => by
    simp [Function.comp, f.preserves_source a ha, g.preserves_source _ (f.arcs_mem a ha)]
  preserves_target := fun a ha => by
    simp [Function.comp, f.preserves_target a ha, g.preserves_target _ (f.arcs_mem a ha)]

/-! ## Section 7: Equilibrium and Idempotence -/

/-- A photon graph is in equilibrium if the state is constant. -/

def PhotonGraph.inEquilibrium (G : PhotonGraph) (t₁ t₂ : ℤ) : Prop :=
  G.stateAtTime t₁ = G.stateAtTime t₂

/-- Equilibrium is reflexive. -/

theorem equilibrium_refl (G : PhotonGraph) (t : ℤ) :
    G.inEquilibrium t t := rfl

/-- Equilibrium is transitive (idempotent propagation). -/

theorem propagator_idempotent_at_equilibrium (G : PhotonGraph)
    (t₁ t₂ t₃ : ℤ)
    (h₁₂ : G.inEquilibrium t₁ t₂) (h₂₃ : G.inEquilibrium t₂ t₃) :
    G.inEquilibrium t₁ t₃ := by
  exact h₁₂.trans h₂₃


end
