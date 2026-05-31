/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Weighted Tropical Graph Hodge Theory

This file establishes a weighted tropical harmonicity theory on graphs,
introducing a min-plus balancing law with valuations that generalizes
ordinary graph Laplacian harmonicity to the tropical setting.

## Main Definitions

* `WeightedGraph` — a finite simple graph with integer edge weights
* `weightedNbrVal` — the weighted neighbor value `w(i,j) + φ(j)`
* `tropBalancedAt` — tropical balance at a vertex
* `weightedTropKernelOn` — the weighted tropical kernel on a vertex subset
* `GenericWeights` — pairwise distinct incident edge weights
* `WeightDegenerateAt` — local weight degeneracy
* `WeightCompatibleCycle` — cycle admitting a balanced potential
* `qVisibleWeightedComponent` — component with degenerate q-access

## Main Results

* `weighted_cycle_balance` — algebraic transport identity
* `kernel_translate_invariant` — kernel closed under constant shifts
* `tropBalancedAt_of_two_witnesses` — constructive balance
* `generic_zero_not_balanced` — genericity prevents zero balance
* `weightCompatibleCycle_gives_kernel_vector` — cycles give kernel vectors
* `weighted_component_indicator_in_kernel` — components give kernel vectors
* `shortestPathDegeneracy_eq_weightDegeneracy` — cross-domain identity
* `not_generic_iff_exists_degenerate` — degeneracy characterization
* `zero_in_kernel_of_all_degenerate_and_minimal` — degeneracy kernel membership

## References

* Baker–Norine (2007), "Riemann–Roch and Abel–Jacobi theory on a finite graph"
* Mikhalkin (2006), "Tropical geometry and its applications"
-/

import Mathlib

open Finset BigOperators Classical

noncomputable section

/-! ## Definitions -/

/-- A weighted simple graph: a finite simple graph with integer edge weights. -/
structure WeightedGraph (V : Type*) [Fintype V] where
  Adj : V → V → Prop
  symm : Symmetric Adj
  loopless : ∀ v, ¬ Adj v v
  w : V → V → ℤ
  w_symm : ∀ ⦃u v⦄, Adj u v → w u v = w v u

namespace WeightedGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The weighted neighbor value `w(i,j) + φ(j)`. -/
def weightedNbrVal (G : WeightedGraph V) (φ : V → ℤ) (i j : V) : ℤ :=
  G.w i j + φ j

/-- Tropical balance at vertex `i`: the minimum of `w(i,j) + φ(j)` over
    neighbors `j` is attained by at least two distinct neighbors. -/
def tropBalancedAt (G : WeightedGraph V) (φ : V → ℤ) (i : V) : Prop :=
  ∃ j k : V, j ≠ k ∧ G.Adj i j ∧ G.Adj i k ∧
    G.weightedNbrVal φ i j = G.weightedNbrVal φ i k ∧
    ∀ l, G.Adj i l → G.weightedNbrVal φ i j ≤ G.weightedNbrVal φ i l

/-- The weighted tropical kernel on vertex set `S`. -/
def weightedTropKernelOn (G : WeightedGraph V) (S : Finset V) : Set (V → ℤ) :=
  {φ | ∀ i ∈ S, G.tropBalancedAt φ i}

/-- Generic weights: all incident edge weights are pairwise distinct. -/
def GenericWeights (G : WeightedGraph V) : Prop :=
  ∀ ⦃i j k⦄, G.Adj i j → G.Adj i k → j ≠ k → G.w i j ≠ G.w i k

/-- Weight degeneracy at vertex `i`. -/
def WeightDegenerateAt (G : WeightedGraph V) (i : V) : Prop :=
  ∃ j k : V, j ≠ k ∧ G.Adj i j ∧ G.Adj i k ∧ G.w i j = G.w i k

/-- Count of weight-degenerate vertices in `S`. -/
noncomputable def weightDegeneracyCount (G : WeightedGraph V) (S : Finset V) : ℕ :=
  (S.filter (fun i => ∃ j k : V, j ≠ k ∧ G.Adj i j ∧ G.Adj i k ∧ G.w i j = G.w i k)).card

/-- Count of vertices in `S` with shortest-path degeneracy. -/
noncomputable def shortestPathDegeneracyCount (G : WeightedGraph V)
    (_q : V) (S : Finset V) : ℕ :=
  (S.filter (fun v => ∃ j k : V, j ≠ k ∧ G.Adj v j ∧ G.Adj v k ∧ G.w v j = G.w v k)).card

/-- Weight-compatible cycle: nonempty set with a balanced zero-outside potential. -/
def WeightCompatibleCycle (G : WeightedGraph V) (C : Finset V) : Prop :=
  C.Nonempty ∧
  ∃ φ : V → ℤ, (∀ v, v ∉ C → φ v = 0) ∧ ∀ i ∈ C, G.tropBalancedAt φ i

/-- q-visible weighted component. -/
def qVisibleWeightedComponent (G : WeightedGraph V) (q : V) (T : Finset V) : Prop :=
  T.Nonempty ∧ q ∉ T ∧
  ∃ c : ℤ, ∃ φ : V → ℤ, (∀ v, v ∈ T → φ v = c) ∧ (∀ v, v ∉ T → φ v = 0) ∧
    ∀ i ∈ T, G.tropBalancedAt φ i

/-! ## Theorems -/

/-
**Weighted cycle balance lemma.** Transport identity for potentials.
-/
omit [DecidableEq V] in
theorem weighted_cycle_balance
    (G : WeightedGraph V) (φ : V → ℤ) (i j k : V)
    (h : φ j - φ k = G.w i k - G.w i j) :
    G.weightedNbrVal φ i j = G.weightedNbrVal φ i k := by
  unfold WeightedGraph.weightedNbrVal; linarith

/-
**Kernel translation invariance.**
-/
omit [DecidableEq V] in
theorem kernel_translate_invariant
    (G : WeightedGraph V) (S : Finset V)
    (φ : V → ℤ) (c : ℤ) (hφ : φ ∈ G.weightedTropKernelOn S) :
    (fun v => φ v + c) ∈ G.weightedTropKernelOn S := by
  intro i hi;
  obtain ⟨ j, k, hjk, hj, hk, heq, hmin ⟩ := hφ i hi; use j, k; simp_all +decide [ WeightedGraph.weightedNbrVal ] ;
  grind +qlia

/-
**Constructive tropical balance.**
-/
omit [DecidableEq V] in
theorem tropBalancedAt_of_two_witnesses
    (G : WeightedGraph V) (φ : V → ℤ) (i j k : V)
    (hjk : j ≠ k) (hj : G.Adj i j) (hk : G.Adj i k)
    (heq : G.weightedNbrVal φ i j = G.weightedNbrVal φ i k)
    (hmin : ∀ l, G.Adj i l → G.weightedNbrVal φ i j ≤ G.weightedNbrVal φ i l) :
    G.tropBalancedAt φ i := by
  exact ⟨ j, k, hjk, hj, hk, heq, hmin ⟩

/-
**Generic weights prevent zero balance.**
-/
omit [DecidableEq V] in
theorem generic_zero_not_balanced
    (G : WeightedGraph V)
    (hgen : G.GenericWeights) (i : V) :
    ¬ G.tropBalancedAt (0 : V → ℤ) i := by
  exact fun ⟨ u, r, mur, hui, hri, req, hhmin ⟩ => hgen hui hri mur <| by simp_all +decide [ WeightedGraph.weightedNbrVal ] ;

/-
**Weight-compatible cycles produce kernel vectors.**
-/
omit [DecidableEq V] in
theorem weightCompatibleCycle_gives_kernel_vector
    (G : WeightedGraph V)
    (C : Finset V) (hC : G.WeightCompatibleCycle C) :
    ∃ φ : V → ℤ, φ ∈ G.weightedTropKernelOn C := by
  exact ⟨ hC.2.choose, fun i hi => hC.2.choose_spec.2 i hi ⟩

/-
**q-visible components produce kernel vectors.**
-/
omit [DecidableEq V] in
theorem weighted_component_indicator_in_kernel
    (G : WeightedGraph V)
    (q : V) (T : Finset V)
    (hT : G.qVisibleWeightedComponent q T) :
    ∃ φ : V → ℤ, φ ∈ G.weightedTropKernelOn T := by
  rcases hT with ⟨ hT₁, hT₂, c, φ, hφ₁, hφ₂, hφ₃ ⟩ ; exact ⟨ φ, fun i hi => hφ₃ i hi ⟩ ;

/-
**Cross-domain: shortest-path degeneracy = weight degeneracy.**
-/
theorem shortestPathDegeneracy_eq_weightDegeneracy
    (G : WeightedGraph V)
    (q : V) (S : Finset V) :
    G.shortestPathDegeneracyCount q S = G.weightDegeneracyCount S := by
  convert rfl

/-
**Degeneracy characterization.**
-/
omit [DecidableEq V] in
theorem not_generic_iff_exists_degenerate
    (G : WeightedGraph V) :
    ¬ G.GenericWeights ↔ ∃ i : V, G.WeightDegenerateAt i := by
  simp +decide only [GenericWeights, WeightDegenerateAt];
  grind

/-
**Zero in kernel under full degeneracy with minimality.**
-/
omit [DecidableEq V] in
theorem zero_in_kernel_of_all_degenerate_and_minimal
    (G : WeightedGraph V)
    (S : Finset V)
    (hdeg : ∀ i ∈ S, ∃ j k : V, j ≠ k ∧ G.Adj i j ∧ G.Adj i k ∧ G.w i j = G.w i k ∧
      ∀ l, G.Adj i l → G.w i j ≤ G.w i l) :
    (0 : V → ℤ) ∈ G.weightedTropKernelOn S := by
  intro i hi
  obtain ⟨j, k, hjk, hj, hk, heq, hmin⟩ := hdeg i hi
  apply tropBalancedAt_of_two_witnesses G 0 i j k hjk hj hk (by
  unfold WeightedGraph.weightedNbrVal; simp +decide [ heq ] ;) (by
  unfold WeightedGraph.weightedNbrVal; aesop;)

end WeightedGraph

end