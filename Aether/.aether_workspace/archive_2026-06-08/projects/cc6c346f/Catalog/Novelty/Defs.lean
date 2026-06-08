/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Erdős–Faber–Lovász Conjecture: Definitions and Core Structures

The EFL conjecture (proved for large k by Kang–Kelly–Kühn–Methuku–Osthus, 2021) states:
  If k complete graphs K_k pairwise share at most one vertex,
  then the chromatic number of their union is at most k.

Equivalently, in hypergraph terms:
  If F₁, ..., Fₖ are k-element sets with |Fᵢ ∩ Fⱼ| ≤ 1 for i ≠ j,
  then the vertices can be colored with k colors so that each Fᵢ is rainbow.
-/
import Mathlib

open Finset Function

namespace EFL

/-- An EFL system consists of k edges, each of size k, over a vertex type V,
    such that any two distinct edges share at most one vertex (linearity). -/
structure System (V : Type*) [DecidableEq V] [Fintype V] where
  /-- The number of edges (and edge size) -/
  k : ℕ
  /-- The edges, indexed by `Fin k` -/
  edges : Fin k → Finset V
  /-- Each edge has exactly k elements (k-uniformity) -/
  uniform : ∀ i, (edges i).card = k
  /-- Any two distinct edges share at most one vertex (linearity) -/
  linear : ∀ i j, i ≠ j → (edges i ∩ edges j).card ≤ 1

/-- The vertex set of an EFL system: the union of all edges. -/
def System.vertexSet {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) : Finset V :=
  Finset.univ.biUnion (fun i => S.edges i)

/-- The degree of a vertex in an EFL system: number of edges containing it. -/
def System.degree {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) (v : V) : ℕ :=
  (Finset.univ.filter (fun i => v ∈ S.edges i)).card

/-- A strong (rainbow) coloring of an EFL system:
    a function c : V → ℕ such that c is injective on each edge. -/
def System.IsStrongColoring {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) (c : V → ℕ) : Prop :=
  ∀ i : Fin S.k, Set.InjOn c (↑(S.edges i) : Set V)

/-- An EFL system is k-colorable if it admits a strong coloring using
    colors in {0, 1, ..., k-1}, i.e., with range contained in Fin k. -/
def System.IsKColorable {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) : Prop :=
  ∃ c : V → ℕ, S.IsStrongColoring c ∧ ∀ v ∈ S.vertexSet, c v < S.k

/-- The EFL Conjecture for a specific system: it is k-colorable. -/
def EFLConjecture {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) : Prop :=
  S.IsKColorable

/-! ## Near-Pencil Configuration

The near-pencil is the conjectured extremal configuration for EFL.
It consists of k edges that all share a single "center" vertex,
with the remaining k-1 vertices in each edge being unique to that edge.
Total vertices: 1 + k*(k-1) = k² - k + 1.

The near-pencil is the hardest case for EFL: it requires exactly k colors. -/

/-- A near-pencil EFL system: one center vertex shared by all k edges,
    with disjoint petals of size k-1. -/
structure NearPencilData (k : ℕ) where
  /-- The center vertex (in all edges) -/
  center : Fin (k * (k - 1) + 1)
  /-- The petal vertices, indexed by edge and position within petal -/
  petals : Fin k → Fin (k - 1) → Fin (k * (k - 1) + 1)
  /-- Center is not a petal vertex -/
  center_not_petal : ∀ i j, petals i j ≠ center
  /-- Petals are injective within each edge -/
  petals_inj : ∀ i, Injective (petals i)
  /-- Petals from different edges are disjoint -/
  petals_disjoint : ∀ i₁ i₂, i₁ ≠ i₂ → ∀ j₁ j₂, petals i₁ j₁ ≠ petals i₂ j₂

/-! ## Dual Degree Properties -/

/-- The incidence count of an EFL system: total number of (vertex, edge) incidence pairs. -/
def System.incidenceCount {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) : ℕ :=
  ∑ i : Fin S.k, (S.edges i).card

/-- The degree sum of an EFL system from the vertex side. -/
def System.degreeSum {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) : ℕ :=
  ∑ v : V, S.degree v

/-! ## Linear Hypergraph (General) -/

/-- A general linear hypergraph: a family of Finsets where
    any two distinct edges share at most one vertex. -/
structure LinearHypergraph (V : Type*) [DecidableEq V] where
  /-- The set of edges -/
  edges : Finset (Finset V)
  /-- Any two distinct edges share at most one vertex -/
  linear : ∀ e₁ ∈ edges, ∀ e₂ ∈ edges, e₁ ≠ e₂ → (e₁ ∩ e₂).card ≤ 1

/-- The dual adjacency relation: two edges are dual-adjacent
    iff they share a vertex. -/
def LinearHypergraph.dualAdjacent {V : Type*} [DecidableEq V]
    (H : LinearHypergraph V) (e₁ e₂ : Finset V) : Prop :=
  e₁ ∈ H.edges ∧ e₂ ∈ H.edges ∧ e₁ ≠ e₂ ∧ (e₁ ∩ e₂).Nonempty

/-! ## Sunflower Core -/

/-- The edges through a vertex v form the "star" of v. -/
def System.star {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) (v : V) : Finset (Fin S.k) :=
  Finset.univ.filter (fun i => v ∈ S.edges i)

end EFL