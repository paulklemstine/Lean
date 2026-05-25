/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Morse Theory for Graph Neural Networks — Definitions

This file establishes the foundational definitions for tropical Morse theory
applied to edge-weighted graphs, connecting tropical geometry with topological
data analysis and graph neural network expressiveness theory.

## Main Definitions

* `EdgeWeightedGraph` — A finite graph with rational edge weights
* `CriticalEventType` — Birth, merge, or cycle-death events in the filtration
* `MorseEvent` — A critical value paired with its event type
* `sublevelEdgeSet` — Edges with weight ≤ threshold
* `TMSpectrum` — Tropical Morse spectrum
* `WL1Equiv` — 1-WL equivalence via degree multiset

## References

* Baker–Norine (2007), Cohen-Steiner–Edelsbrunner–Harer (2007), Cai–Fürer–Immerman (1992)
-/

import Mathlib

open Finset BigOperators

namespace TropicalMorse

/-! ### Critical Event Types -/

/-- Critical event types in the tropical Morse weight filtration. -/
inductive CriticalEventType where
  | birth      : CriticalEventType
  | merge      : CriticalEventType
  | cycleDeath : CriticalEventType
  deriving DecidableEq, Inhabited

/-- A Morse event: a critical value paired with its event type. -/
structure MorseEvent where
  value : ℚ
  eventType : CriticalEventType
  deriving DecidableEq

/-! ### Edge-Weighted Graphs -/

/-- An edge-weighted graph on `n` vertices with rational edge weights. -/
structure EdgeWeightedGraph (n : ℕ) where
  adj : Fin n → Fin n → Bool
  adj_symm : ∀ i j, adj i j = adj j i
  adj_irrefl : ∀ i, adj i i = false
  weight : Fin n → Fin n → ℚ
  weight_symm : ∀ i j, weight i j = weight j i

/-- The set of edges as pairs (i, j) with i < j. -/
def EdgeWeightedGraph.edges {n : ℕ} (G : EdgeWeightedGraph n) : Finset (Fin n × Fin n) :=
  Finset.univ.filter fun p => p.1 < p.2 ∧ G.adj p.1 p.2 = true

def EdgeWeightedGraph.edgeCount {n : ℕ} (G : EdgeWeightedGraph n) : ℕ := G.edges.card

/-! ### Sublevel Sets -/

/-- The sublevel edge set: edges with weight at most `t`. -/
def sublevelEdgeSet {n : ℕ} (G : EdgeWeightedGraph n) (t : ℚ) : Finset (Fin n × Fin n) :=
  G.edges.filter fun e => G.weight e.1 e.2 ≤ t

/-- The sublevel adjacency relation induced by threshold `t`. -/
def sublevelAdj {n : ℕ} (G : EdgeWeightedGraph n) (t : ℚ) (i j : Fin n) : Bool :=
  G.adj i j && decide (G.weight i j ≤ t)

theorem sublevelAdj_symm {n : ℕ} (G : EdgeWeightedGraph n) (t : ℚ) (i j : Fin n) :
    sublevelAdj G t i j = sublevelAdj G t j i := by
  simp [sublevelAdj, G.adj_symm, G.weight_symm]

theorem sublevelAdj_irrefl {n : ℕ} (G : EdgeWeightedGraph n) (t : ℚ) (i : Fin n) :
    sublevelAdj G t i i = false := by
  simp [sublevelAdj, G.adj_irrefl]

/-! ### Monotonicity of Sublevel Sets -/

theorem sublevel_mono {n : ℕ} (G : EdgeWeightedGraph n) {s t : ℚ} (hst : s ≤ t) (i j : Fin n) :
    sublevelAdj G s i j = true → sublevelAdj G t i j = true := by
  simp [sublevelAdj]; intro hadj hw; exact ⟨hadj, le_trans hw hst⟩

theorem sublevelEdgeSet_mono {n : ℕ} (G : EdgeWeightedGraph n) {s t : ℚ} (hst : s ≤ t) :
    sublevelEdgeSet G s ⊆ sublevelEdgeSet G t := by
  intro e he
  unfold sublevelEdgeSet at he ⊢
  rw [Finset.mem_filter] at he ⊢
  exact ⟨he.1, le_trans he.2 hst⟩

/-! ### Tropical Morse Spectrum -/

/-- The tropical Morse spectrum: an ordered list of Morse events. -/
structure TMSpectrum where
  events : List MorseEvent
  sorted : events.Pairwise (fun a b => a.value ≤ b.value)
  deriving DecidableEq

def TMSpectrum.countType (tms : TMSpectrum) (et : CriticalEventType) : ℕ :=
  tms.events.countP (fun e => e.eventType == et)

def TMSpectrum.mergeCount (tms : TMSpectrum) : ℕ := tms.countType .merge
def TMSpectrum.cycleCount (tms : TMSpectrum) : ℕ := tms.countType .cycleDeath

/-! ### 1-WL Color Refinement -/

def EdgeWeightedGraph.degree {n : ℕ} (G : EdgeWeightedGraph n) (v : Fin n) : ℕ :=
  (Finset.univ.filter (fun u => G.adj v u = true)).card

def EdgeWeightedGraph.degreeMultiset {n : ℕ} (G : EdgeWeightedGraph n) : Multiset ℕ :=
  Finset.univ.val.map G.degree

/-- Two graphs are 1-WL equivalent if they have the same degree multiset. -/
def WL1Equiv {n : ℕ} (G₁ G₂ : EdgeWeightedGraph n) : Prop :=
  G₁.degreeMultiset = G₂.degreeMultiset

/-! ### Euler Characteristic and Betti Numbers -/

/-- The cycle rank (first Betti number): β₁ = edges - vertices + components. -/
def cycleRank (n m c : ℕ) : ℤ := (m : ℤ) - (n : ℤ) + (c : ℤ)

/-- The Euler characteristic: vertices - edges. -/
def eulerChar (n m : ℕ) : ℤ := (n : ℤ) - (m : ℤ)

/-- Euler characteristic equals components minus cycle rank. -/
theorem euler_eq_components_minus_cycleRank (n m c : ℕ) :
    eulerChar n m = (c : ℤ) - cycleRank n m c := by
  simp only [eulerChar, cycleRank]; ring

/-! ### Filtration Step -/

/-- A filtration step records the change when adding one edge.
    When adding an edge:
    - Same component → cycle rank +1, components unchanged (cycleDeath event)
    - Different components → components -1, cycle rank unchanged (merge event) -/
structure FiltrationStep where
  edgeWeight : ℚ
  sameComponent : Bool

/-- Convert a filtration step to a Morse event. -/
def FiltrationStep.toMorseEvent (fs : FiltrationStep) : MorseEvent where
  value := fs.edgeWeight
  eventType := if fs.sameComponent then .cycleDeath else .merge

/-- The component delta for a filtration step. -/
def FiltrationStep.componentDelta (fs : FiltrationStep) : ℤ :=
  if fs.sameComponent then 0 else -1

/-- The cycle rank delta for a filtration step. -/
def FiltrationStep.cycleRankDelta (fs : FiltrationStep) : ℤ :=
  if fs.sameComponent then 1 else 0

/-- Complementarity: component delta + cycle rank delta = 0 for merges, 1 for cycles. -/
theorem FiltrationStep.complementary (fs : FiltrationStep) :
    fs.componentDelta + fs.cycleRankDelta = if fs.sameComponent then 1 else -1 := by
  simp [componentDelta, cycleRankDelta]
  cases fs.sameComponent <;> simp

/-! ### Expressiveness -/

def StrictlyMoreExpressivePair {n : ℕ} (G₁ G₂ : EdgeWeightedGraph n)
    (tms₁ tms₂ : TMSpectrum) : Prop :=
  WL1Equiv G₁ G₂ ∧ tms₁ ≠ tms₂

end TropicalMorse