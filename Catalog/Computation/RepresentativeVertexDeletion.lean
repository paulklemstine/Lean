/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Representative-vertex deletion for hypergraphs

## Overview

This file develops the *representative-vertex* (a.k.a. *deterministic deletion*)
construction used to find large independent sets in hypergraphs of bounded
average degree.

The setting is a finite hypergraph whose edge set is a `Finset (Finset V)` over a
vertex type `V`.  Fix a vertex subset `S : Finset V`.  Writing
`E(S) := edgeSet S` for the edge set of the *complete* hypergraph on `S` (i.e.
every subset of `S`), the hyperedges of `E` that live inside `S` are exactly the
elements of `E ∩ E(S)`, here called the **contained edges** of `S`.

The construction `deterministic_deletion E S` proceeds by *representative-vertex
deletion*: for every contained (nonempty) edge `e` we choose a single canonical
representative vertex — its minimum element `e.min'` — and we delete the whole set
of representatives from `S`.  Deleting at most one vertex per contained edge:

* removes every contained edge (each one loses its representative), so the
  surviving set is **independent**;
* discards at most `|E ∩ E(S)|` vertices, so the surviving set has size at least
  `|S| - |E ∩ E(S)|`.

This is the deterministic counterpart of the probabilistic deletion method: no
randomness is used, the representative function is a fixed, computable choice.

## Main results

* `deterministic_deletion_subset` — the constructed set `I` satisfies `I ⊆ S`.
* `deterministic_deletion_independent` — `I` is independent: it contains no
  nonempty edge of `E`.
* `deterministic_deletion_card_ge` — `|S| - |E ∩ E(S)| ≤ |I|`.
* `deterministic_deletion_spec` — packages the three properties above.
* `deterministic_deletion_card_ge_of_averageDegree` — the average-degree form:
  if every edge is nonempty and the average degree on `S` is at most `δ`, then
  `(1 - δ) * |S| ≤ |I|`.
-/

import Mathlib

open Finset

namespace Hypergraph

variable {V : Type*} [LinearOrder V]

/-! ## Contained edges: `E ∩ E(S)` -/

/-- `edgeSet S` is the edge set `E(S)` of the *complete* hypergraph on `S`:
every subset of `S` is an edge. -/
def edgeSet (S : Finset V) : Finset (Finset V) := S.powerset

/-- The hyperedges of `E` that are contained in `S`, namely `E ∩ E(S)`. -/
def containedEdges (E : Finset (Finset V)) (S : Finset V) : Finset (Finset V) :=
  E ∩ edgeSet S

@[simp] lemma mem_containedEdges {E : Finset (Finset V)} {S e : Finset V} :
    e ∈ containedEdges E S ↔ e ∈ E ∧ e ⊆ S := by
  simp [containedEdges, edgeSet, Finset.mem_inter, Finset.mem_powerset]

/-! ## Independence -/

/-- A vertex set `I` is **independent** for the hypergraph `E` when it contains
no nonempty hyperedge of `E`.  (The empty edge, if present, is unavoidable by
vertex deletion and is therefore excluded.) -/
def IsIndependent (E : Finset (Finset V)) (I : Finset V) : Prop :=
  ∀ e ∈ E, e.Nonempty → ¬ e ⊆ I

/-! ## The deletion construction -/

/-- The set of deleted *representative* vertices: for each contained edge we
delete its minimum element (its canonical representative).  Empty edges
contribute nothing. -/
def deletedVertices (E : Finset (Finset V)) (S : Finset V) : Finset V :=
  (containedEdges E S).biUnion (fun e => if h : e.Nonempty then {e.min' h} else ∅)

/-- The representative-vertex deletion construction: remove from `S` every chosen
representative vertex. -/
def deterministic_deletion (E : Finset (Finset V)) (S : Finset V) : Finset V :=
  S \ deletedVertices E S

/-- Every contained nonempty edge has its representative among the deleted
vertices. -/
lemma min'_mem_deletedVertices {E : Finset (Finset V)} {S e : Finset V}
    (he : e ∈ containedEdges E S) (hne : e.Nonempty) :
    e.min' hne ∈ deletedVertices E S := by
  refine' Finset.mem_biUnion.2 ⟨ e, he, _ ⟩ ; aesop

/-- The deletion construction keeps us inside `S`. -/
lemma deterministic_deletion_subset (E : Finset (Finset V)) (S : Finset V) :
    deterministic_deletion E S ⊆ S := by
  grind +locals

/-- At most one vertex is deleted per contained edge. -/
lemma deletedVertices_card_le (E : Finset (Finset V)) (S : Finset V) :
    (deletedVertices E S).card ≤ (containedEdges E S).card := by
  refine' le_trans ( Finset.card_biUnion_le ) _;
  exact le_trans ( Finset.sum_le_sum fun x hx => show _ ≤ 1 by aesop ) ( by simp +decide )

/-- **Independence.** The constructed set contains no nonempty edge of `E`,
because every contained edge lost its representative. -/
theorem deterministic_deletion_independent (E : Finset (Finset V)) (S : Finset V) :
    IsIndependent E (deterministic_deletion E S) := by
  intro e he hne hsub; simp_all +decide [ Finset.subset_iff ] ;
  exact absurd ( hsub ( Finset.min'_mem e hne ) ) ( by rw [ deterministic_deletion ] ; exact Finset.notMem_sdiff_of_mem_right ( min'_mem_deletedVertices ( by rw [ mem_containedEdges ] ; exact ⟨ he, fun y hy => by have := hsub hy; rw [ deterministic_deletion ] at this; aesop ⟩ ) hne ) )

/-- **Size bound.** The constructed set has size at least `|S| - |E ∩ E(S)|`. -/
theorem deterministic_deletion_card_ge (E : Finset (Finset V)) (S : Finset V) :
    S.card - (containedEdges E S).card ≤ (deterministic_deletion E S).card := by
  convert Nat.sub_le_sub_left ( deletedVertices_card_le E S ) ( Finset.card S ) using 1;
  refine' eq_tsub_of_add_eq ( Finset.card_sdiff_add_card_eq_card _ );
  intro x hx;
  obtain ⟨ e, he, hx ⟩ := Finset.mem_biUnion.mp hx;
  split_ifs at hx <;> simp_all +decide [ containedEdges ];
  exact Finset.mem_powerset.mp he.2 ( Finset.min'_mem _ ‹_› )

/-- **Specification of representative-vertex deletion.**  For any finite
hypergraph `E` and vertex subset `S`, the deterministic deletion construction
produces a set `I ⊆ S` that is independent and has size at least
`|S| - |E ∩ E(S)|`. -/
theorem deterministic_deletion_spec (E : Finset (Finset V)) (S : Finset V) :
    deterministic_deletion E S ⊆ S ∧
      IsIndependent E (deterministic_deletion E S) ∧
      S.card - (containedEdges E S).card ≤ (deterministic_deletion E S).card :=
  ⟨deterministic_deletion_subset E S, deterministic_deletion_independent E S,
    deterministic_deletion_card_ge E S⟩

/-! ## Average-degree form

We now connect the size bound to the *average degree* of the hypergraph on `S`,
the regime in which the representative-vertex construction is typically used. -/

/-- The degree of a vertex `v` in `E`: the number of hyperedges containing `v`. -/
def degree (E : Finset (Finset V)) (v : V) : ℕ := (E.filter (fun e => v ∈ e)).card

/-- The average degree of the hypergraph `E` over the vertex set `S`. -/
noncomputable def averageDegree (E : Finset (Finset V)) (S : Finset V) : ℚ :=
  (∑ v ∈ S, (degree E v : ℚ)) / S.card

/-
Double counting: when every edge is nonempty, the number of contained edges
is at most the total degree summed over `S`.
-/
lemma containedEdges_card_le_sum_degree (E : Finset (Finset V)) (S : Finset V)
    (hne : ∀ e ∈ E, e.Nonempty) :
    (containedEdges E S).card ≤ ∑ v ∈ S, degree E v := by
  -- By definition of containedEdges, every nonempty edge in containedEdges is a subset of S and contains at least one vertex from S.
  have h_subset : ∀ e ∈ containedEdges E S, e.Nonempty → ∃ v ∈ S, v ∈ e := by
    exact fun e he he' => by obtain ⟨ v, hv ⟩ := he'; exact ⟨ v, Finset.mem_of_subset ( Finset.mem_inter.mp he |>.2 |> Finset.mem_powerset.mp ) hv, hv ⟩ ;
  have h_card : (containedEdges E S).card ≤ Finset.card (Finset.biUnion S (fun v => Finset.filter (fun e => v ∈ e) (containedEdges E S))) := by
    refine Finset.card_le_card ?_;
    intro e he; specialize h_subset e he; by_cases he' : e.Nonempty <;> aesop;
  refine' le_trans h_card ( Finset.card_biUnion_le.trans _ );
  exact Finset.sum_le_sum fun v hv => Finset.card_le_card fun e he => by aesop;

/-
**Average-degree size bound.**  If every hyperedge is nonempty and the
average degree of `E` on `S` is at most `δ`, then representative-vertex deletion
keeps at least a `(1 - δ)`-fraction of `S`.
-/
theorem deterministic_deletion_card_ge_of_averageDegree
    (E : Finset (Finset V)) (S : Finset V) {δ : ℚ}
    (hne : ∀ e ∈ E, e.Nonempty) (hδ : averageDegree E S ≤ δ) :
    (1 - δ) * S.card ≤ (deterministic_deletion E S).card := by
  by_cases hS : S.Nonempty;
  · have h₁ : (S.card : ℚ) ≤ (deterministic_deletion E S).card + (containedEdges E S).card := by
      norm_cast;
      have := @deterministic_deletion_card_ge V _ E S;
      rwa [ tsub_le_iff_right ] at this;
    have h₂ : (containedEdges E S).card ≤ (∑ v ∈ S, (degree E v : ℚ)) := by
      exact_mod_cast containedEdges_card_le_sum_degree E S hne;
    unfold averageDegree at hδ;
    rw [ div_le_iff₀ ] at hδ <;> first | linarith | aesop;
  · aesop

end Hypergraph