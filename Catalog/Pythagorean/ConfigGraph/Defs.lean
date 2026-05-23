/-
Copyright (c) 2025. All rights reserved.
Configuration Graph Pathwidth — A Graph-Theoretic Theory of Proof Memory

This file defines the core objects for studying resolution proof complexity
through the lens of graph pathwidth. The central insight is that clause space
(the memory required for a resolution refutation) corresponds to a graph
layout parameter of the proof-state transition system.
-/
import Mathlib

open Finset List

/-! ## Path Decompositions

A path decomposition of a finite graph is a sequence of "bags" (finite sets of vertices)
satisfying three axioms: vertex coverage, edge coverage, and the interval property
(bags containing any fixed vertex form a contiguous subsequence).
-/

/-- A `PathDecomposition` of a graph with vertex type `α` is a nonempty list of bags (finite
sets of vertices). Validity conditions are stated separately. -/
structure PathDecomposition (α : Type*) [DecidableEq α] where
  /-- The bags of the decomposition, indexed linearly. -/
  bags : List (Finset α)
  /-- The bag list is nonempty. -/
  bags_nonempty : bags ≠ []

namespace PathDecomposition

variable {α : Type*} [DecidableEq α]

/-- The width of a path decomposition is the maximum bag size minus one. -/
noncomputable def width (P : PathDecomposition α) : ℕ :=
  (P.bags.map Finset.card).foldr max 0 - 1

/-- Maximum bag cardinality. -/
noncomputable def maxBagSize (P : PathDecomposition α) : ℕ :=
  (P.bags.map Finset.card).foldr max 0

theorem width_eq_maxBagSize_sub_one (P : PathDecomposition α) :
    P.width = P.maxBagSize - 1 := rfl

/-- The union of all bags — the vertex set covered by the decomposition. -/
def vertexSet (P : PathDecomposition α) : Finset α :=
  P.bags.foldr (· ∪ ·) ∅

/-- The interval (running intersection) property: for each vertex v, the indices
of bags containing v form a contiguous interval. -/
def HasIntervalProperty (P : PathDecomposition α) : Prop :=
  ∀ (v : α) (i j k : ℕ)
    (_ : i ≤ j) (_ : j ≤ k)
    (hi : i < P.bags.length) (hj : j < P.bags.length) (hk : k < P.bags.length),
    v ∈ P.bags.get ⟨i, hi⟩ → v ∈ P.bags.get ⟨k, hk⟩ → v ∈ P.bags.get ⟨j, hj⟩

/-- Edge coverage: every pair of adjacent vertices (under the given relation)
appears together in some bag. -/
def CoversEdges (P : PathDecomposition α) (adj : α → α → Prop) : Prop :=
  ∀ u v, adj u v →
    ∃ i, ∃ (hi : i < P.bags.length), u ∈ P.bags.get ⟨i, hi⟩ ∧ v ∈ P.bags.get ⟨i, hi⟩

/-- Vertex coverage: every vertex in the given set appears in some bag. -/
def CoversVertices (P : PathDecomposition α) (V : Finset α) : Prop :=
  ∀ v ∈ V, ∃ i, ∃ (hi : i < P.bags.length), v ∈ P.bags.get ⟨i, hi⟩

/-- A path decomposition is valid for a given vertex set and adjacency relation. -/
structure IsValidFor (P : PathDecomposition α) (V : Finset α) (adj : α → α → Prop) : Prop where
  covers_vertices : P.CoversVertices V
  covers_edges : P.CoversEdges adj
  interval_property : P.HasIntervalProperty

end PathDecomposition

/-! ## Co-occurrence Graph

Given a list of finite sets (e.g., configurations in a resolution trace),
the co-occurrence graph connects two elements that appear in the same set. -/

/-- Two elements are co-occurring if they both belong to some common set in the list. -/
def CoOccurrenceAdj (bags : List (Finset α)) [DecidableEq α] (u v : α) : Prop :=
  u ≠ v ∧ ∃ B ∈ bags, u ∈ B ∧ v ∈ B

/-! ## Resolution Traces and Configurations

A resolution trace models the memory states during a resolution refutation.
Each state is a finite set of clauses (a "configuration"). -/

/-- A configuration is a finite set of clauses currently in memory. -/
abbrev Configuration (α : Type*) := Finset α

/-- A resolution trace is a nonempty sequence of configurations. -/
structure ResolutionTrace (α : Type*) where
  /-- The sequence of configurations visited during the refutation. -/
  configs : List (Finset α)
  /-- The trace is nonempty. -/
  configs_nonempty : configs ≠ []

namespace ResolutionTrace

variable {α : Type*}

/-- The configuration at step i (returns ∅ if out of bounds). -/
def configAt (π : ResolutionTrace α) (i : ℕ) : Finset α :=
  π.configs[i]?.getD ∅

/-- The length of the trace. -/
def length (π : ResolutionTrace α) : ℕ := π.configs.length

/-- The clause space of a trace: the maximum configuration size. -/
noncomputable def clauseSpace [DecidableEq α] (π : ResolutionTrace α) : ℕ :=
  (π.configs.map Finset.card).foldr max 0

/-- A trace reaches contradiction if the last configuration is empty. -/
def isRefutation (π : ResolutionTrace α) : Prop :=
  π.configs.getLast (π.configs_nonempty) = ∅

/-- The initial configuration of a trace. -/
def initial (π : ResolutionTrace α) : Finset α :=
  π.configs.head (π.configs_nonempty)

end ResolutionTrace

/-! ## Visited Configuration Graph

The visited configuration graph of a trace has the visited configurations as vertices,
with edges between consecutively visited configurations. -/

/-- Two configurations are adjacent in the visited graph if they appear consecutively
in the trace. -/
def TraceAdj [DecidableEq α] (π : ResolutionTrace α) (C₁ C₂ : Finset α) : Prop :=
  C₁ ≠ C₂ ∧ ∃ i, i + 1 < π.configs.length ∧
    ∃ (hi : i < π.configs.length) (hi1 : i + 1 < π.configs.length),
    ((π.configs.get ⟨i, hi⟩ = C₁ ∧ π.configs.get ⟨i+1, hi1⟩ = C₂) ∨
     (π.configs.get ⟨i, hi⟩ = C₂ ∧ π.configs.get ⟨i+1, hi1⟩ = C₁))

/-- The set of configurations visited by a trace. -/
def visitedConfigs [DecidableEq α] [DecidableEq (Finset α)] (π : ResolutionTrace α) :
    Finset (Finset α) :=
  π.configs.toFinset

/-! ## Bounded Configuration Graph

The bounded configuration graph BConfGraph(F, s) has as vertices all configurations
of clauses with at most s clauses, with edges connecting configurations that differ
by a single element (add or remove one clause). -/

/-- Two configurations are adjacent in the bounded configuration graph if they differ
by exactly one element (add or remove one clause). -/
def BoundedConfigAdj [DecidableEq α] (s : ℕ) (C₁ C₂ : Finset α) : Prop :=
  C₁ ≠ C₂ ∧ C₁.card ≤ s ∧ C₂.card ≤ s ∧
  ((∃ c, C₂ = C₁ ∪ {c} ∧ c ∉ C₁) ∨
   (∃ c, C₁ = C₂ ∪ {c} ∧ c ∉ C₂))

/-
`BoundedConfigAdj` is symmetric.
-/
theorem boundedConfigAdj_symm [DecidableEq α] (s : ℕ) (C₁ C₂ : Finset α) :
    BoundedConfigAdj s C₁ C₂ → BoundedConfigAdj s C₂ C₁ := by
  intro h
  unfold BoundedConfigAdj at h ⊢
  simp [h];
  grind +ring

/-! ## Clause Space Invariants -/

/-- The minimum clause space over a set of refutations. -/
noncomputable def minClauseSpace [DecidableEq α] (R : Set (ResolutionTrace α)) : ℕ :=
  sInf (ResolutionTrace.clauseSpace '' R)

/-! ## Interval Trace Property

A key property of traces: each clause's presence in configurations forms
a contiguous interval of trace indices. This is the "no re-derivation" property. -/

/-- A trace has the interval property if whenever a clause appears in configurations
at positions i and k (with i ≤ k), it also appears in all intermediate configurations. -/
def ResolutionTrace.hasIntervalProperty [DecidableEq α] (π : ResolutionTrace α) : Prop :=
  ∀ (c : α) (i j k : ℕ)
    (_ : i ≤ j) (_ : j ≤ k)
    (hi : i < π.configs.length) (hj : j < π.configs.length) (hk : k < π.configs.length),
    c ∈ π.configs.get ⟨i, hi⟩ → c ∈ π.configs.get ⟨k, hk⟩ →
    c ∈ π.configs.get ⟨j, hj⟩

/-! ## Trace-Induced Path Decomposition Constructor

Given a trace with the interval property, we construct a path decomposition
of the clause co-occurrence graph. -/

/-- Construct a path decomposition from a resolution trace by using each configuration
as a bag. -/
def traceToPathDecomposition [DecidableEq α] (π : ResolutionTrace α) :
    PathDecomposition α where
  bags := π.configs
  bags_nonempty := π.configs_nonempty

/-! ## Trace Memory Number -/

/-- The trace memory number: minimum (width + 1) over all trace-compatible
valid path decompositions of visited configuration graphs. -/
noncomputable def traceMemoryNumber [DecidableEq α] [DecidableEq (Finset α)]
    (R : Set (ResolutionTrace α)) : ℕ :=
  sInf ((fun p => p.1.width + 1) ''
    {p : PathDecomposition (Finset α) × ResolutionTrace α |
      p.2 ∈ R ∧
      p.1.IsValidFor (visitedConfigs p.2) (TraceAdj p.2) })

/-! ## Monotonicity of Bounded Configuration Graph -/

/-
The bounded configuration adjacency relation is monotone in the bound:
if s ≤ t, then any edge in the s-bounded graph is also an edge in the t-bounded graph.
-/
theorem boundedConfigAdj_mono [DecidableEq α] {s t : ℕ} (hst : s ≤ t)
    {C₁ C₂ : Finset α} (h : BoundedConfigAdj s C₁ C₂) : BoundedConfigAdj t C₁ C₂ := by
  exact ⟨ h.1, hst.trans' h.2.1, hst.trans' h.2.2.1, h.2.2.2 ⟩