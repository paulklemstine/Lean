import Mathlib

/-!
# Erdős–Faber–Lovász Conjecture: Definitions

This file establishes the foundational definitions for the Erdős–Faber–Lovász (EFL)
conjecture and related hypergraph theory.

## Main Definitions

* `EFL.System` — A k-uniform linear hypergraph with k edges (the EFL setting)
* `EFL.System.degree` — The degree of a vertex (number of edges containing it)
* `EFL.System.vertexSet` — The set of vertices appearing in at least one edge
* `EFL.System.incidenceCount` — Total vertex-edge incidences
* `EFL.System.IsStrongColoring` — A coloring where each edge receives all k colors
* `EFL.System.IsKColorable` — Existence of a strong k-coloring

## Mathematical Context

The Erdős–Faber–Lovász conjecture (1972) states that if k copies of k-cliques
pairwise share at most one vertex, then the union graph can be properly
vertex-colored with k colors. Equivalently, any k-uniform linear hypergraph
with k edges has chromatic number at most k.

This was proved for sufficiently large k by Kang–Kelly–Kühn–Methuku–Osthus (2021).
-/

open Finset Function

namespace EFL

/-- An EFL system is a k-uniform linear hypergraph with exactly k edges.
    - `k` is the uniformity parameter (each edge has exactly k vertices)
    - `edges` maps each index in `Fin k` to a set of vertices
    - `uniform` ensures each edge has exactly k vertices
    - `linear` ensures any two distinct edges share at most one vertex -/
structure System (V : Type*) [DecidableEq V] [Fintype V] where
  /-- The uniformity parameter -/
  k : ℕ
  /-- The edge family, indexed by `Fin k` -/
  edges : Fin k → Finset V
  /-- Each edge has exactly k vertices -/
  uniform : ∀ i, (edges i).card = k
  /-- Any two distinct edges share at most one vertex (linearity) -/
  linear : ∀ i j, i ≠ j → (edges i ∩ edges j).card ≤ 1

/-- The degree of a vertex v is the number of edges containing v. -/
def System.degree {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) (v : V) : ℕ :=
  (Finset.univ.filter (fun i => v ∈ S.edges i)).card

/-- The vertex set of an EFL system is the union of all edges. -/
def System.vertexSet {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) : Finset V :=
  Finset.univ.biUnion S.edges

/-- The total number of vertex-edge incidences. -/
def System.incidenceCount {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) : ℕ :=
  ∑ i : Fin S.k, (S.edges i).card

/-- A strong coloring of an EFL system assigns colors from `Fin k` to vertices
    such that each edge receives all k distinct colors (i.e., is rainbow). -/
def System.IsStrongColoring {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) (c : V → Fin S.k) : Prop :=
  ∀ i : Fin S.k, Set.InjOn c (↑(S.edges i) : Set V)

/-- An EFL system is k-colorable if there exists a strong coloring with k colors. -/
def System.IsKColorable {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) : Prop :=
  ∃ c : V → Fin S.k, S.IsStrongColoring c

/-- A near-pencil EFL system: all edges share a common vertex (the "center").
    This is the extremal configuration for the EFL conjecture. -/
def System.IsNearPencil {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) : Prop :=
  ∃ v : V, ∀ i : Fin S.k, v ∈ S.edges i

/-- A general hypergraph structure, more flexible than the EFL-specific System. -/
structure Hypergraph (V : Type*) [DecidableEq V] [Fintype V] where
  /-- The edge family as a finite set of finite sets -/
  edgeSet : Finset (Finset V)

/-- A hypergraph is k-uniform if every edge has exactly k vertices. -/
def Hypergraph.IsKUniform {V : Type*} [DecidableEq V] [Fintype V]
    (H : Hypergraph V) (k : ℕ) : Prop :=
  ∀ e ∈ H.edgeSet, e.card = k

/-- A hypergraph is intersecting if any two edges share at least one vertex. -/
def Hypergraph.IsIntersecting {V : Type*} [DecidableEq V] [Fintype V]
    (H : Hypergraph V) : Prop :=
  ∀ e₁ ∈ H.edgeSet, ∀ e₂ ∈ H.edgeSet, (e₁ ∩ e₂).Nonempty

/-- A hypergraph is linear if any two distinct edges share at most one vertex. -/
def Hypergraph.IsLinear {V : Type*} [DecidableEq V] [Fintype V]
    (H : Hypergraph V) : Prop :=
  ∀ e₁ ∈ H.edgeSet, ∀ e₂ ∈ H.edgeSet, e₁ ≠ e₂ → (e₁ ∩ e₂).card ≤ 1

/-- A proper hypergraph coloring: no edge is monochromatic. -/
def Hypergraph.IsProperColoring {V : Type*} [DecidableEq V] [Fintype V]
    (H : Hypergraph V) {c : ℕ} (f : V → Fin c) : Prop :=
  ∀ e ∈ H.edgeSet, 2 ≤ e.card → ¬∀ v ∈ e, ∀ w ∈ e, f v = f w

/-- The chromatic number of a hypergraph: the minimum number of colors
    for a proper coloring. Returns 0 for edgeless hypergraphs. -/
noncomputable def Hypergraph.chromaticNumber {V : Type*} [DecidableEq V] [Fintype V]
    (H : Hypergraph V) : ℕ :=
  sInf {c : ℕ | ∃ f : V → Fin c, H.IsProperColoring f}

/-- The degree of a vertex in a general hypergraph. -/
def Hypergraph.degree {V : Type*} [DecidableEq V] [Fintype V]
    (H : Hypergraph V) (v : V) : ℕ :=
  (H.edgeSet.filter (fun e => v ∈ e)).card

/-- The maximum degree of a hypergraph. -/
noncomputable def Hypergraph.maxDegree {V : Type*} [DecidableEq V] [Fintype V]
    (H : Hypergraph V) : ℕ :=
  Finset.sup Finset.univ (H.degree)

/-- A sunflower in a hypergraph: a collection of edges that pairwise
    intersect in the same set (the "core"). -/
structure Hypergraph.Sunflower {V : Type*} [DecidableEq V] [Fintype V]
    (H : Hypergraph V) where
  /-- The petals of the sunflower -/
  petals : Finset (Finset V)
  /-- All petals are edges -/
  petals_subset : petals ⊆ H.edgeSet
  /-- The core: intersection of all petals -/
  core : Finset V
  /-- The core is contained in each petal -/
  core_sub : ∀ p ∈ petals, core ⊆ p
  /-- Distinct petals intersect exactly in the core -/
  pairwise_inter : ∀ p₁ ∈ petals, ∀ p₂ ∈ petals, p₁ ≠ p₂ → p₁ ∩ p₂ = core

/-- Convert an EFL system to a general hypergraph. -/
def System.toHypergraph {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) : Hypergraph V where
  edgeSet := Finset.univ.image S.edges

end EFL