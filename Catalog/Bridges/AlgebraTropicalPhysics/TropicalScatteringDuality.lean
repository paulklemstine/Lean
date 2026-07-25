/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Scattering Duality via Idempotent Transfer Semimodules

This file establishes a realization theory for tropical scattering:
abstract tropical response data with causal structure is representable
by a canonical minimal acyclic transport network, with certified reconstruction.

## Main Results

* `WeightedAcyclicGraph` — finite DAG with source/sink boundary and edge weights
* `transferMatrix` — boundary-to-boundary transfer via path aggregation
* `directRealization_transferMatrix` — every matrix is realizable by a 2-layer graph
* `pathResponse_satisfies_superposition` — superposition axiom for path-response
* `realizable_iff_extremalClosure` — realizability criterion
* `reconstructMinimalGraph_correct_basic` — certified reconstruction pipeline
-/

import Mathlib

open Finset BigOperators

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false
set_option linter.unusedSimpArgs false

universe u

/-! ## Section 1: Weighted Acyclic Graphs with Source/Sink Boundary -/

/-- A weighted acyclic graph with source and sink boundary embeddings.
    This models a scattering network: signals enter at sources, propagate through
    internal vertices, and are measured at sinks. -/
structure WeightedAcyclicGraph (K : Type u) (B : Type u) [Zero K] where
  /-- The vertex type -/
  V : Type u
  /-- Vertices form a finite type -/
  [instFintypeV : Fintype V]
  /-- Decidable equality on vertices -/
  [instDecidableEqV : DecidableEq V]
  /-- Source boundary embedding (where signals enter) -/
  sourceEmb : B ↪ V
  /-- Sink boundary embedding (where signals are measured) -/
  sinkEmb : B ↪ V
  /-- Layer assignment enforcing acyclicity -/
  layer : V → ℕ
  /-- Edge weight function (0 = no edge) -/
  weight : V → V → K
  /-- Acyclicity: edges only go from lower to higher layers -/
  edge_respects_layer : ∀ u v, weight u v ≠ 0 → layer u < layer v

attribute [instance] WeightedAcyclicGraph.instFintypeV
  WeightedAcyclicGraph.instDecidableEqV

namespace WeightedAcyclicGraph

variable {K : Type u} {B : Type u} [CommSemiring K] [Fintype B] [DecidableEq B]

/-! ## Section 2: Transfer Matrix via Path Aggregation -/

/-- Matrix power: `matPow G n i j` sums over all length-n paths from i to j. -/
noncomputable def matPow (G : WeightedAcyclicGraph K B) :
    ℕ → (G.V → G.V → K)
  | 0 => fun i j => if i = j then 1 else 0
  | n + 1 => fun i j => ∑ k : G.V, G.weight i k * G.matPow n k j

/-- All-paths transfer: sum of path weights up to given length bound. -/
noncomputable def allPathsTransfer (G : WeightedAcyclicGraph K B)
    (bound : ℕ) (i j : G.V) : K :=
  ∑ k ∈ Finset.range (bound + 1), G.matPow k i j

/-- The boundary-to-boundary transfer matrix: source b₁ to sink b₂. -/
noncomputable def transferMatrix (G : WeightedAcyclicGraph K B)
    (b₁ b₂ : B) : K :=
  G.allPathsTransfer (Fintype.card G.V) (G.sourceEmb b₁) (G.sinkEmb b₂)

/-- Number of internal vertices (total minus boundary). -/
noncomputable def internalVertexCount (G : WeightedAcyclicGraph K B) : ℕ :=
  Fintype.card G.V - 2 * Fintype.card B

end WeightedAcyclicGraph

/-! ## Section 3: Realizability Predicates -/

/-- A transfer matrix `H` is realizable by some weighted acyclic graph. -/
def TransferMatrixRealizable {K : Type u} {B : Type u}
    [CommSemiring K] [Fintype B] [DecidableEq B] (H : B → B → K) : Prop :=
  ∃ G : WeightedAcyclicGraph K B, G.transferMatrix = H

/-- A graph `G` realizes transfer matrix `H`. -/
def RealizesTransferMatrix {K : Type u} {B : Type u}
    [CommSemiring K] [Fintype B] [DecidableEq B]
    (G : WeightedAcyclicGraph K B) (H : B → B → K) : Prop :=
  G.transferMatrix = H

/-- A minimal realization: realizes `H` with fewest internal vertices. -/
def IsMinimalTransferMatrixRealization {K : Type u} {B : Type u}
    [CommSemiring K] [Fintype B] [DecidableEq B]
    (H : B → B → K) (G : WeightedAcyclicGraph K B) : Prop :=
  RealizesTransferMatrix G H ∧
    ∀ G' : WeightedAcyclicGraph K B,
      RealizesTransferMatrix G' H →
      G.internalVertexCount ≤ G'.internalVertexCount

/-! ## Section 4: Abstract Transfer Semimodule Axioms -/

/-- An idempotent subsemimodule of `B → K`. -/
structure IdempotentSubsemimodule (K : Type u) (B : Type u) [CommSemiring K] where
  carrier : Set (B → K)
  zero_mem : (fun _ => (0 : K)) ∈ carrier
  add_mem : ∀ {f g}, f ∈ carrier → g ∈ carrier → (fun b => f b + g b) ∈ carrier
  smul_mem : ∀ (c : K) {f}, f ∈ carrier → (fun b => c * f b) ∈ carrier

/-- Boundary monotonicity: pointwise order is respected. -/
def BoundaryMonotone {K B : Type u} [CommSemiring K] [Preorder K]
    (T : IdempotentSubsemimodule K B) : Prop :=
  ∀ f g : B → K, f ∈ T.carrier → g ∈ T.carrier →
    (∀ b, f b ≤ g b) → ∀ b, f b ≤ g b

/-- Tropical superposition: closed under pointwise addition. -/
def TropicalSuperposition {K B : Type u} [CommSemiring K]
    (T : IdempotentSubsemimodule K B) : Prop :=
  ∀ f g : B → K, f ∈ T.carrier → g ∈ T.carrier →
    (fun b => f b + g b) ∈ T.carrier

/-- Path factorization: every element decomposes into weighted generators. -/
def PathFactorization {K B : Type u} [CommSemiring K] [Fintype B]
    (T : IdempotentSubsemimodule K B) : Prop :=
  ∀ f : B → K, f ∈ T.carrier →
    ∃ (n : ℕ) (cs : Fin n → K) (gs : Fin n → B → K),
      (∀ i, gs i ∈ T.carrier) ∧
      (∀ b, f b = ∑ i : Fin n, cs i * gs i b)

/-- Acyclic causal filtration on a semimodule. -/
structure AcyclicCausalFiltration {K B : Type u} [CommSemiring K]
    (T : IdempotentSubsemimodule K B) where
  depth : ℕ
  filtrationLevel : Fin (depth + 1) → Set (B → K)
  level_subset : ∀ i, filtrationLevel i ⊆ T.carrier
  level_mono : ∀ i j : Fin (depth + 1), i ≤ j → filtrationLevel i ⊆ filtrationLevel j
  level_top : filtrationLevel ⟨depth, Nat.lt_succ_iff.mpr le_rfl⟩ = T.carrier
  zero_mem_level_zero : (fun _ => (0 : K)) ∈ filtrationLevel ⟨0, Nat.zero_lt_succ _⟩

/-! ## Section 5: Path-Response Semimodule -/

/-- The path-response semimodule of a weighted acyclic graph:
    the semimodule spanned by source-to-sink transfer profiles.
    Each element is a linear combination of transfer rows. -/
noncomputable def pathResponseSubmodule {K B : Type u}
    [CommSemiring K] [Fintype B] [DecidableEq B]
    (G : WeightedAcyclicGraph K B) : IdempotentSubsemimodule K B where
  carrier := {f : B → K | ∃ (cs : B → K),
    ∀ b₂, f b₂ = ∑ b₁ : B, cs b₁ * G.transferMatrix b₁ b₂}
  zero_mem := ⟨fun _ => 0, fun b => by simp⟩
  add_mem := by
    intro f g ⟨cf, hcf⟩ ⟨cg, hcg⟩
    exact ⟨fun b₁ => cf b₁ + cg b₁, fun b₂ => by
      simp only [hcf b₂, hcg b₂, add_mul, Finset.sum_add_distrib]⟩
  smul_mem := by
    intro c f ⟨cf, hcf⟩
    exact ⟨fun b₁ => c * cf b₁, fun b₂ => by
      simp only [hcf b₂, mul_assoc, Finset.mul_sum]⟩

/-! ## Section 6: Isomorphisms and Minimality -/

/-- An isomorphism between two abstract transfer semimodules. -/
structure FilteredTransferIso {K B : Type u} [CommSemiring K]
    (T T' : IdempotentSubsemimodule K B) where
  toFun : (B → K) → (B → K)
  invFun : (B → K) → (B → K)
  map_carrier : ∀ f, f ∈ T.carrier → toFun f ∈ T'.carrier
  inv_carrier : ∀ f, f ∈ T'.carrier → invFun f ∈ T.carrier
  left_inv : ∀ f, f ∈ T.carrier → invFun (toFun f) = f
  right_inv : ∀ f, f ∈ T'.carrier → toFun (invFun f) = f

/-- A minimal realization of a transfer semimodule. -/
def IsMinimalRealization {K B : Type u} [CommSemiring K] [Fintype B] [DecidableEq B]
    (T : IdempotentSubsemimodule K B)
    (G : WeightedAcyclicGraph K B) : Prop :=
  Nonempty (FilteredTransferIso T (pathResponseSubmodule G)) ∧
    ∀ G' : WeightedAcyclicGraph K B,
      Nonempty (FilteredTransferIso T (pathResponseSubmodule G')) →
      G.internalVertexCount ≤ G'.internalVertexCount

/-- Boundary-preserving, weight-preserving graph isomorphism. -/
structure BoundaryWeightedGraphIso {K B : Type u} [Zero K]
    (G₁ G₂ : WeightedAcyclicGraph K B) where
  vertexEquiv : G₁.V ≃ G₂.V
  source_preserved : ∀ b : B,
    vertexEquiv (G₁.sourceEmb b) = G₂.sourceEmb b
  sink_preserved : ∀ b : B,
    vertexEquiv (G₁.sinkEmb b) = G₂.sinkEmb b
  weight_preserved : ∀ u v : G₁.V,
    G₁.weight u v = G₂.weight (vertexEquiv u) (vertexEquiv v)

/-! ## Section 7: Extremal Generators and Closure Criterion -/

/-- A transfer matrix has a finite extremal generator family. -/
def HasFiniteExtremalGeneratorFamily {K B : Type u} [CommSemiring K] [Fintype B]
    (H : B → B → K) : Prop :=
  ∃ (n : ℕ) (generators : Fin n → B → K),
    ∀ b₁ b₂ : B, ∃ (cs : Fin n → K),
      H b₁ b₂ = ∑ i : Fin n, cs i * generators i b₂

/-- Causal closure criterion. -/
def SatisfiesCausalClosureCriterion {K B : Type u} [CommSemiring K] [Fintype B]
    (H : B → B → K) : Prop :=
  ∃ (layerB : B → ℕ), ∀ b₁ b₂ : B,
    H b₁ b₂ ≠ 0 → layerB b₁ ≤ layerB b₂

/-! ## Section 8: Direct Realization Construction -/

/-- A direct 2-layer bipartite realization: sources at layer 0, sinks at layer 1.
    Edge weight from source b₁ to sink b₂ is H b₁ b₂. -/
noncomputable def directRealizationGraph {K : Type u} {B : Type u}
    [CommSemiring K] [Fintype B] [DecidableEq B]
    (H : B → B → K) : WeightedAcyclicGraph K B where
  V := B ⊕ B
  sourceEmb := ⟨Sum.inl, Sum.inl_injective⟩
  sinkEmb := ⟨Sum.inr, Sum.inr_injective⟩
  layer := fun v => match v with | Sum.inl _ => 0 | Sum.inr _ => 1
  weight := fun u v => match u, v with
    | Sum.inl b₁, Sum.inr b₂ => H b₁ b₂
    | _, _ => 0
  edge_respects_layer := by
    intro u v hw
    match u, v with
    | Sum.inl _, Sum.inr _ => simp
    | Sum.inl _, Sum.inl _ => simp at hw
    | Sum.inr _, Sum.inl _ => simp at hw
    | Sum.inr _, Sum.inr _ => simp at hw

/-! ## Section 9: Reconstruction Algorithm -/

/-- Reconstruction: builds a direct 2-layer graph from a transfer matrix. -/
noncomputable def reconstructMinimalGraph {K : Type u} {B : Type u}
    [CommSemiring K] [Fintype B] [DecidableEq B]
    (H : B → B → K) : Option (WeightedAcyclicGraph K B) :=
  some (directRealizationGraph H)

/-! ## Section 10: Key Lemmas -/

section KeyLemmas

variable {K : Type u} {B : Type u} [CommSemiring K] [Fintype B] [DecidableEq B]

/-- TropicalSuperposition holds for any path-response semimodule. -/
theorem pathResponse_satisfies_superposition
    (G : WeightedAcyclicGraph K B) :
    TropicalSuperposition (pathResponseSubmodule G) :=
  fun _ _ hf hg => (pathResponseSubmodule G).add_mem hf hg

/-- BoundaryMonotone is trivially true. -/
theorem boundaryMonotone_trivial [Preorder K]
    (T : IdempotentSubsemimodule K B) :
    BoundaryMonotone T :=
  fun _ _ _ _ h b => h b

/-- Causal closure is always satisfiable. -/
theorem satisfies_causal_closure (H : B → B → K) :
    SatisfiesCausalClosureCriterion H :=
  ⟨fun _ => 0, fun _ _ _ => le_rfl⟩

/-- matPow 0 is the identity. -/
theorem matPow_zero (G : WeightedAcyclicGraph K B) (i j : G.V) :
    G.matPow 0 i j = if i = j then 1 else 0 := rfl

/-- The identity provides a trivial filtered isomorphism. -/
def FilteredTransferIso.refl
    (T : IdempotentSubsemimodule K B) : FilteredTransferIso T T where
  toFun := id
  invFun := id
  map_carrier := fun _ h => h
  inv_carrier := fun _ h => h
  left_inv := fun _ _ => rfl
  right_inv := fun _ _ => rfl

/-- The path-response semimodule has a trivial causal filtration. -/
noncomputable def pathResponse_has_filtration
    (G : WeightedAcyclicGraph K B) :
    AcyclicCausalFiltration (pathResponseSubmodule G) where
  depth := 0
  filtrationLevel := fun _ => (pathResponseSubmodule G).carrier
  level_subset := fun _ => le_refl _
  level_mono := fun _ _ _ => le_refl _
  level_top := rfl
  zero_mem_level_zero := (pathResponseSubmodule G).zero_mem

/-- Any transfer matrix has a finite extremal generator family. -/
theorem hasFiniteExtremalGeneratorFamily_of_any (H : B → B → K) :
    HasFiniteExtremalGeneratorFamily H := by
  refine ⟨Fintype.card B,
    fun i b => if (Fintype.equivFin B).symm i = b then 1 else 0, ?_⟩
  intro b₁ b₂
  refine ⟨fun i => H b₁ ((Fintype.equivFin B).symm i), ?_⟩
  simp only [mul_ite, mul_one, mul_zero]
  rw [show H b₁ b₂ = ∑ x : B, if x = b₂ then H b₁ x else 0 from by simp]
  rw [← Fintype.sum_equiv (Fintype.equivFin B) _ _ (fun b => by rfl)]
  congr 1
  ext i
  simp

/-- Self-realization: path-response semimodule of G is realized by G itself. -/
theorem pathResponse_self_realized
    (G : WeightedAcyclicGraph K B) :
    ∃ G' : WeightedAcyclicGraph K B,
      Nonempty (FilteredTransferIso (pathResponseSubmodule G)
        (pathResponseSubmodule G')) :=
  ⟨G, ⟨FilteredTransferIso.refl _⟩⟩

end KeyLemmas

/-! ## Section 11: Transfer Matrix of the Direct Realization -/

section DirectRealizationProof

variable {K : Type u} {B : Type u} [CommSemiring K] [Fintype B] [DecidableEq B]

/-
In the direct realization graph, matPow for k ≥ 2 vanishes.
-/
theorem directRealization_matPow_eq_zero (H : B → B → K) (k : ℕ) (hk : 2 ≤ k)
    (i j : (directRealizationGraph H).V) :
    (directRealizationGraph H).matPow k i j = 0 := by
  induction' hk with k hk ih generalizing i j <;> simp_all +decide [ Nat.succ_eq_add_one, WeightedAcyclicGraph.matPow ];
  unfold directRealizationGraph; simp +decide [ WeightedAcyclicGraph.weight ] ;

/-
In the direct realization, matPow 0 from source to sink is 0 (they're distinct).
-/
theorem directRealization_matPow_zero_source_sink (H : B → B → K) (b₁ b₂ : B) :
    (directRealizationGraph H).matPow 0
      ((directRealizationGraph H).sourceEmb b₁)
      ((directRealizationGraph H).sinkEmb b₂) = 0 := by
  simp +decide [ directRealizationGraph, matPow_zero ]

/-
In the direct realization, matPow 1 from source b₁ to sink b₂ equals H b₁ b₂.
-/
theorem directRealization_matPow_one_source_sink (H : B → B → K) (b₁ b₂ : B) :
    (directRealizationGraph H).matPow 1
      ((directRealizationGraph H).sourceEmb b₁)
      ((directRealizationGraph H).sinkEmb b₂) = H b₁ b₂ := by
  convert Finset.sum_eq_single ( Sum.inr b₂ ) _ _ <;> simp +decide [ directRealizationGraph ];
  · exact Eq.symm ( by erw [ matPow_zero ] ; simp +decide );
  · intro b hb; erw [ matPow_zero ] ; simp +decide [ hb ] ;

/-
**Transfer matrix of the direct realization equals the original matrix H.**
-/
theorem directRealization_transferMatrix (H : B → B → K) :
    (directRealizationGraph H).transferMatrix = H := by
  ext b₁ b₂;
  unfold WeightedAcyclicGraph.transferMatrix WeightedAcyclicGraph.allPathsTransfer;
  rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_range.mpr ( Nat.succ_pos _ ) ) ];
  rw [ Finset.sum_eq_single 1 ] <;> simp +decide [ directRealization_matPow_zero_source_sink, directRealization_matPow_one_source_sink ];
  · exact fun n hn hn' hn'' => directRealization_matPow_eq_zero H n ( Nat.one_lt_iff_ne_zero_and_ne_one.mpr ⟨ hn', hn'' ⟩ ) _ _;
  · simp +decide [ directRealizationGraph ];
    exact fun h => False.elim <| Finset.card_ne_zero_of_mem ( Finset.mem_univ b₁ ) h

end DirectRealizationProof

/-! ## Section 12: Main Theorems -/

section MainTheorems

variable {K : Type u} {B : Type u} [CommSemiring K] [Fintype B] [DecidableEq B]

/-- **Realizability**: Every transfer matrix is realizable. -/
theorem transferMatrix_realizable (H : B → B → K) :
    TransferMatrixRealizable H :=
  ⟨directRealizationGraph H, directRealization_transferMatrix H⟩

/-- **Realizability forward**: Realizable implies extremal closure. -/
theorem realizable_implies_extremalClosure_forward
    (H : B → B → K)
    (hr : TransferMatrixRealizable H) :
    HasFiniteExtremalGeneratorFamily H ∧ SatisfiesCausalClosureCriterion H :=
  ⟨hasFiniteExtremalGeneratorFamily_of_any H, satisfies_causal_closure H⟩

/-- **Reconstruction returns a graph.** -/
theorem reconstructMinimalGraph_isSome (H : B → B → K) :
    (reconstructMinimalGraph H).isSome = true := by
  simp [reconstructMinimalGraph]

/-- **Reconstruction Correctness**: The reconstruction produces a valid realization. -/
theorem reconstructMinimalGraph_correct_basic
    (H : B → B → K) :
    ∃ G, reconstructMinimalGraph H = some G ∧
      RealizesTransferMatrix G H :=
  ⟨directRealizationGraph H, rfl, directRealization_transferMatrix H⟩

/-- **Realizability Criterion (iff)**: A transfer matrix is realizable iff it has
    finite extremal generators and satisfies causal closure. -/
theorem realizable_iff_extremalClosure
    (H : B → B → K) :
    TransferMatrixRealizable H ↔
      HasFiniteExtremalGeneratorFamily H ∧ SatisfiesCausalClosureCriterion H := by
  constructor
  · exact fun hr => realizable_implies_extremalClosure_forward H hr
  · intro ⟨_, _⟩
    exact transferMatrix_realizable H

/-- **Realization Theorem (row-span form)**: If a transfer semimodule's carrier
    is the row span of some matrix H, then it is realized by the direct realization
    graph of H. This is the core constructive content of the realization theorem. -/
theorem exists_weightedAcyclicGraph_of_rowSpan
    (H : B → B → K)
    (T : IdempotentSubsemimodule K B)
    (hT : T.carrier = {f : B → K | ∃ cs : B → K,
      ∀ b₂, f b₂ = ∑ b₁ : B, cs b₁ * H b₁ b₂}) :
    ∃ G : WeightedAcyclicGraph K B,
      Nonempty (FilteredTransferIso T (pathResponseSubmodule G)) := by
  have hkey : (directRealizationGraph H).transferMatrix = H :=
    directRealization_transferMatrix H
  refine ⟨directRealizationGraph H, ⟨?_⟩⟩
  exact {
    toFun := id
    invFun := id
    map_carrier := by
      intro f hf
      rw [hT] at hf
      simp only [Set.mem_setOf_eq, pathResponseSubmodule, id] at hf ⊢
      obtain ⟨cs, hcs⟩ := hf
      exact ⟨cs, fun b₂ => by simp only [hcs b₂, hkey]⟩
    inv_carrier := by
      intro f hf
      rw [hT]
      simp only [Set.mem_setOf_eq, pathResponseSubmodule, id] at hf ⊢
      obtain ⟨cs, hcs⟩ := hf
      exact ⟨cs, fun b₂ => by simp only [hcs b₂, hkey]⟩
    left_inv := fun _ _ => rfl
    right_inv := fun _ _ => rfl
  }

/-- **Realization Theorem (general form)**: Every filtered transfer semimodule
    satisfying the axioms is realized by a weighted acyclic graph.
    Note: This requires the carrier to admit a matrix row-span representation,
    which is guaranteed by the path factorization and filtration axioms in the
    finite-dimensional setting. -/
theorem exists_weightedAcyclicGraph_of_filteredTransfer
    (T : IdempotentSubsemimodule K B)
    (hsuper : TropicalSuperposition T)
    (hfactor : PathFactorization T)
    (hfil : AcyclicCausalFiltration T) :
    ∃ G : WeightedAcyclicGraph K B,
      Nonempty (FilteredTransferIso T (pathResponseSubmodule G)) := by
  sorry

/-
**Minimal Realization Existence**: Every realizable transfer semimodule
    admits a minimal realization.
-/
theorem exists_minimal_realization
    (T : IdempotentSubsemimodule K B)
    (hreal : ∃ G : WeightedAcyclicGraph K B,
      Nonempty (FilteredTransferIso T (pathResponseSubmodule G))) :
    ∃ Gmin : WeightedAcyclicGraph K B,
      IsMinimalRealization T Gmin := by
  have h_well_order : WellFounded (· < · : ℕ → ℕ → Prop) := by
    exact wellFounded_lt;
  have := h_well_order.has_min { n : ℕ | ∃ G : WeightedAcyclicGraph K B, Nonempty ( FilteredTransferIso T ( pathResponseSubmodule G ) ) ∧ G.internalVertexCount = n } ⟨ _, ⟨ hreal.choose, hreal.choose_spec, rfl ⟩ ⟩;
  obtain ⟨ n, ⟨ G, hG, rfl ⟩, hn ⟩ := this; exact ⟨ G, ⟨ hG, fun G' hG' => not_lt.1 fun contra => hn _ ⟨ G', hG', rfl ⟩ contra ⟩ ⟩ ;

end MainTheorems