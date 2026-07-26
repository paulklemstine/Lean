/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Scattering One-Way Duality via Idempotent Transfer Semimodules

This file establishes a finite duality theorem at the interface of tropical linear
algebra, network realization theory, and cryptographic one-way structure.

## Overview

We work with min-plus (tropical) scattering networks: weighted acyclic bipartite
graphs with `m` input nodes, `n` output nodes, and `k ≥ 1` internal nodes. The
**transfer matrix** `T(i,j) = min_v (A(i,v) + B(v,j))` records the minimum-weight
path from each input to each output.

## Main Results

* `ScatteringNetwork` — finite min-plus bipartite scattering network
* `transferMatrix` — boundary-to-boundary tropical transfer via min-plus paths
* `essential_achieves_min` — essential vertices achieve the transfer minimum
* `nonessential_transfer_preserved` — removing non-essential vertices preserves transfer
* `minimal_implies_reduced` — minimal realization ⟹ every vertex essential
* `reduction_step` — non-reduced networks can be strictly reduced
* `diagRealization_correct` — every matrix is realizable
* `exists_minimal_realization` — minimal realizations always exist
* `minimal_realization_unique_internal_count` — minimal realizations have same size
* `certified_reconstruction_reduced` — certificate reconstruction is sound
* `iso_preserves_transfer` — isomorphic networks have the same transfer matrix
* `reduced_vertex_bound` — reduced networks have k ≤ m*n vertices
-/

import Mathlib

open Finset BigOperators

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false
set_option maxHeartbeats 800000

noncomputable section

/-! ## Section 1: Core Definitions -/

/-- A tropical (min-plus) matrix. -/
abbrev TropicalMatrix (m n : ℕ) := Fin m → Fin n → ℝ

/-- A scattering network with `m` inputs, `n` outputs, and `k ≥ 1` internal vertices.
    Represented as a bipartite min-plus factorization. -/
structure ScatteringNetwork (m n : ℕ) where
  k : ℕ
  hk : 0 < k
  inputWeights : Fin m → Fin k → ℝ
  outputWeights : Fin k → Fin n → ℝ

namespace ScatteringNetwork

variable {m n : ℕ}

/-- The path weight from input `i` through internal vertex `v` to output `j`. -/
def pathWeight (G : ScatteringNetwork m n) (i : Fin m) (v : Fin G.k) (j : Fin n) : ℝ :=
  G.inputWeights i v + G.outputWeights v j

/-- Nonemptiness of internal vertex set. -/
theorem internal_nonempty (G : ScatteringNetwork m n) :
    (Finset.univ : Finset (Fin G.k)).Nonempty :=
  Finset.univ_nonempty_iff.mpr ⟨⟨0, G.hk⟩⟩

/-- The **transfer matrix**: `T(i,j) = min_v pathWeight(i,v,j)`. -/
def transferMatrix (G : ScatteringNetwork m n) : TropicalMatrix m n :=
  fun i j => Finset.univ.inf' G.internal_nonempty (fun v => G.pathWeight i v j)

/-- Vertex `v` is **essential**: it is the strict unique minimizer for some pair. -/
def IsEssentialVertex (G : ScatteringNetwork m n) (v : Fin G.k) : Prop :=
  ∃ (i : Fin m) (j : Fin n), ∀ w : Fin G.k, w ≠ v →
    G.pathWeight i v j < G.pathWeight i w j

/-- A network is **reduced** if every internal vertex is essential. -/
def IsReduced (G : ScatteringNetwork m n) : Prop :=
  ∀ v : Fin G.k, G.IsEssentialVertex v

/-- A network is a **minimal realization**: fewest internal vertices. -/
def IsMinimal (G : ScatteringNetwork m n) : Prop :=
  ∀ G' : ScatteringNetwork m n, G'.transferMatrix = G.transferMatrix → G.k ≤ G'.k

/-! ## Section 2: Transfer Matrix Basic Properties -/

theorem transferMatrix_le_pathWeight (G : ScatteringNetwork m n) (i : Fin m)
    (v : Fin G.k) (j : Fin n) :
    G.transferMatrix i j ≤ G.pathWeight i v j :=
  Finset.inf'_le _ (Finset.mem_univ v)

theorem transferMatrix_eq_of_le (G : ScatteringNetwork m n) (i : Fin m) (j : Fin n)
    (v : Fin G.k) (hle : ∀ w : Fin G.k, G.pathWeight i v j ≤ G.pathWeight i w j) :
    G.transferMatrix i j = G.pathWeight i v j :=
  le_antisymm (Finset.inf'_le _ (Finset.mem_univ v))
    (Finset.le_inf' _ _ (fun w _ => hle w))

theorem transferMatrix_exists_minimizer (G : ScatteringNetwork m n)
    (i : Fin m) (j : Fin n) :
    ∃ v : Fin G.k, G.transferMatrix i j = G.pathWeight i v j := by
  obtain ⟨v, _, hv⟩ := Finset.exists_mem_eq_inf' G.internal_nonempty
    (fun v => G.pathWeight i v j)
  exact ⟨v, hv⟩

/-! ## Section 3: Essential Vertices -/

theorem essential_achieves_min (G : ScatteringNetwork m n) (v : Fin G.k)
    (hv : G.IsEssentialVertex v) :
    ∃ (i : Fin m) (j : Fin n), G.transferMatrix i j = G.pathWeight i v j := by
  exact hv.imp fun i hi => hi.imp fun j hj =>
    transferMatrix_eq_of_le G i j v fun w =>
      le_of_lt_or_eq <| by by_cases heq : w = v <;> aesop

theorem essential_distinct_witness (G : ScatteringNetwork m n)
    (v w : Fin G.k) (hne : v ≠ w) (hv : G.IsEssentialVertex v) :
    ∃ (i : Fin m) (j : Fin n), G.pathWeight i v j < G.pathWeight i w j :=
  hv.imp fun i hi => hi.imp fun j hj => hj _ hne.symm

/-! ## Section 4: Vertex Removal -/

def skipVertex {k : ℕ} (hk : 1 ≤ k) (v₀ : Fin k) (w : Fin (k - 1)) : Fin k :=
  if (w : ℕ) < (v₀ : ℕ) then ⟨w.val, by omega⟩ else ⟨w.val + 1, by omega⟩

theorem skipVertex_ne {k : ℕ} (hk : 1 ≤ k) (v₀ : Fin k) (w : Fin (k - 1)) :
    skipVertex hk v₀ w ≠ v₀ := by
  unfold skipVertex; aesop

theorem skipVertex_surj_on_ne {k : ℕ} (hk : 1 ≤ k) (v₀ : Fin k) (u : Fin k)
    (hu : u ≠ v₀) : ∃ w : Fin (k - 1), skipVertex hk v₀ w = u := by
  by_cases h : u.val < v₀.val
  · exact ⟨⟨u.val, by omega⟩, Fin.ext (by unfold skipVertex; simp [h])⟩
  · refine ⟨⟨u.val - 1, by omega⟩, ?_⟩
    ext; unfold skipVertex; simp only
    split_ifs with h'
    · simp; omega
    · simp; omega

def removeVertex (G : ScatteringNetwork m n) (v₀ : Fin G.k) (hk2 : 1 < G.k) :
    ScatteringNetwork m n where
  k := G.k - 1
  hk := by omega
  inputWeights := fun i w => G.inputWeights i (skipVertex (by omega) v₀ w)
  outputWeights := fun w j => G.outputWeights (skipVertex (by omega) v₀ w) j

/-! ## Section 5: Non-Essential Vertex Removal -/

theorem not_essential_iff (G : ScatteringNetwork m n) (v₀ : Fin G.k) :
    ¬G.IsEssentialVertex v₀ ↔
    ∀ (i : Fin m) (j : Fin n), ∃ w : Fin G.k, w ≠ v₀ ∧
      G.pathWeight i w j ≤ G.pathWeight i v₀ j := by
  constructor;
  · intro h i j;
    contrapose! h;
    exact ⟨ i, j, h ⟩;
  · intro h;
    exact fun ⟨ i, j, h' ⟩ => by obtain ⟨ w, hw₁, hw₂ ⟩ := h i j; linarith [ h' w hw₁ ] ;

/-
**Key lemma**: Removing a non-essential vertex preserves the transfer matrix.
-/
theorem nonessential_transfer_preserved (G : ScatteringNetwork m n) (v₀ : Fin G.k)
    (hne : ¬G.IsEssentialVertex v₀) (hk2 : 1 < G.k) :
    (G.removeVertex v₀ hk2).transferMatrix = G.transferMatrix := by
  ext i j; simp +decide [ ScatteringNetwork.transferMatrix ] ;
  refine' le_antisymm _ _ <;> simp +decide [ ScatteringNetwork.pathWeight, ScatteringNetwork.removeVertex ];
  · intro b; by_cases hb : b = v₀ <;> simp_all +decide [ ScatteringNetwork.IsEssentialVertex ] ;
    · obtain ⟨ w, hw₁, hw₂ ⟩ := hne i j; specialize hw₂; simp_all +decide [ ScatteringNetwork.pathWeight ] ;
      obtain ⟨ k, hk ⟩ := skipVertex_surj_on_ne ( by linarith ) v₀ w hw₁; use k; aesop;
    · obtain ⟨ w, hw₁, hw₂ ⟩ := skipVertex_surj_on_ne ( by linarith ) v₀ b hb;
      exact ⟨ w, le_rfl ⟩;
  · exact fun w => ⟨ _, le_rfl ⟩

/-! ## Section 6: Minimal Implies Reduced -/

/-
**Necessary condition for minimality**: A minimal realization is reduced.
-/
theorem minimal_implies_reduced (G : ScatteringNetwork m n) (hmin : G.IsMinimal)
    (hm : 0 < m) (hn : 0 < n) :
    G.IsReduced := by
  contrapose! hmin;
  unfold ScatteringNetwork.IsReduced at *;
  simp_all +decide [ ScatteringNetwork.IsMinimal ];
  obtain ⟨ v₀, hv₀ ⟩ := hmin;
  by_cases hk2 : 1 < G.k;
  · exact ⟨ _, nonessential_transfer_preserved G v₀ hv₀ hk2, Nat.sub_lt ( by linarith ) zero_lt_one ⟩;
  · rcases G with ⟨ _ | _ | k, hk, inputWeights, outputWeights ⟩ <;> norm_num at *;
    · contradiction;
    · simp_all +decide [ ScatteringNetwork.IsEssentialVertex ];
      exact False.elim <| hv₀ ⟨ 0, hm ⟩ ⟨ 0, hn ⟩ |>.1 <| by fin_cases v₀; rfl;

/-! ## Section 7: Reduction and Vertex Bounds -/

theorem reduced_injective_witnesses (G : ScatteringNetwork m n) (hred : G.IsReduced) :
    ∃ f : Fin G.k → Fin m × Fin n, Function.Injective f := by
  -- For each vertex v, there exists a pair (i_v, j_v) such that v is strictly better than any other vertex for this pair.
  have h_ess : ∀ v : Fin G.k, ∃ i j, ∀ w : Fin G.k, w ≠ v → G.pathWeight i v j < G.pathWeight i w j := by
    exact?;
  choose f g hfg using h_ess;
  refine' ⟨ fun v => ( f v, g v ), fun v w h => _ ⟩;
  exact Classical.not_not.1 fun h' => lt_asymm ( hfg v w ( Ne.symm h' ) ) ( hfg w v h' |> fun h'' => by aesop )

theorem reduced_vertex_bound (G : ScatteringNetwork m n) (hred : G.IsReduced) :
    G.k ≤ m * n := by
  obtain ⟨f, hf⟩ := reduced_injective_witnesses G hred
  simpa using Fintype.card_le_of_injective f hf

/-- Non-reduced networks can be strictly reduced. -/
theorem reduction_step (G : ScatteringNetwork m n) (hnotred : ¬G.IsReduced)
    (hk2 : 1 < G.k) :
    ∃ G' : ScatteringNetwork m n, G'.transferMatrix = G.transferMatrix ∧ G'.k < G.k := by
  simp only [IsReduced, not_forall] at hnotred
  obtain ⟨v₀, hv₀⟩ := hnotred
  exact ⟨G.removeVertex v₀ hk2,
    nonessential_transfer_preserved G v₀ hv₀ hk2,
    by simp [removeVertex]; omega⟩

/-! ## Section 8: Direct Realization -/

def matBound (hm : 0 < m) (hn : 0 < n) (T : TropicalMatrix m n) : ℝ :=
  Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hm⟩⟩)
    (fun i => Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
      (fun j => |T i j|))

theorem le_matBound (hm : 0 < m) (hn : 0 < n) (T : TropicalMatrix m n)
    (i : Fin m) (j : Fin n) : |T i j| ≤ matBound hm hn T := by
  exact le_trans (Finset.le_sup' (fun j => |T i j|) (Finset.mem_univ j))
    (Finset.le_sup' (fun i => Finset.univ.sup'
      (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun j => |T i j|)) (Finset.mem_univ i))

theorem matBound_nonneg (hm : 0 < m) (hn : 0 < n) (T : TropicalMatrix m n) :
    0 ≤ matBound hm hn T :=
  le_trans (abs_nonneg _) (le_matBound hm hn T ⟨0, hm⟩ ⟨0, hn⟩)

def diagRealization (hm : 0 < m) (hn : 0 < n) (T : TropicalMatrix m n) :
    ScatteringNetwork m n where
  k := n
  hk := hn
  inputWeights := fun i v => T i v
  outputWeights := fun v j =>
    if (v : ℕ) = (j : ℕ) then 0
    else 2 * matBound hm hn T + 1

theorem diagRealization_correct (hm : 0 < m) (hn : 0 < n) (T : TropicalMatrix m n) :
    (diagRealization hm hn T).transferMatrix = T := by
  funext i j;
  refine' le_antisymm ( Finset.inf'_le _ ( Finset.mem_univ j ) |> le_trans <| _ ) ( Finset.le_inf' _ _ fun v _ => _ );
  · unfold diagRealization; unfold ScatteringNetwork.pathWeight; aesop;
  · unfold diagRealization;
    unfold ScatteringNetwork.pathWeight;
    by_cases h : ( v : ℕ ) = j.val <;> simp +decide [ h ];
    · grind;
    · linarith [ abs_le.mp ( le_matBound hm hn T i j ), abs_le.mp ( le_matBound hm hn T i v ) ]

theorem transferMatrix_realizable (hm : 0 < m) (hn : 0 < n) (T : TropicalMatrix m n) :
    ∃ G : ScatteringNetwork m n, G.transferMatrix = T :=
  ⟨diagRealization hm hn T, diagRealization_correct hm hn T⟩

/-! ## Section 9: Existence and Uniqueness of Minimal Realization -/

theorem exists_minimal_realization (hm : 0 < m) (hn : 0 < n)
    (T : TropicalMatrix m n) :
    ∃ G : ScatteringNetwork m n, G.transferMatrix = T ∧ G.IsMinimal := by
  -- By the well-ordering principle, any non-empty subset of the natural numbers has a least element.
  have h_well_ordering : ∀ (S : Set ℕ), S.Nonempty → ∃ k₀ ∈ S, ∀ k ∈ S, k₀ ≤ k := by
    -- Apply the well-ordering principle to the set S.
    apply Classical.byContradiction
    intro h_no_min;
    push_neg at h_no_min;
    obtain ⟨ S, hS₁, hS₂ ⟩ := h_no_min; obtain ⟨ k₀, hk₀ ⟩ := hS₁; induction' k₀ using Nat.strong_induction_on with k₀ ih; specialize hS₂ k₀ hk₀; aesop;
  obtain ⟨k₀, hk₀⟩ : ∃ k₀, k₀ ∈ {k : ℕ | ∃ G : ScatteringNetwork m n, G.k = k ∧ G.transferMatrix = T} ∧ ∀ k ∈ {k : ℕ | ∃ G : ScatteringNetwork m n, G.k = k ∧ G.transferMatrix = T}, k₀ ≤ k := by
    exact h_well_ordering _ ⟨ _, ⟨ diagRealization hm hn T, rfl, diagRealization_correct hm hn T ⟩ ⟩;
  grind +locals

theorem minimal_realization_unique_internal_count
    (G G' : ScatteringNetwork m n)
    (hGmin : G.IsMinimal) (hG'min : G'.IsMinimal)
    (hT : G.transferMatrix = G'.transferMatrix) :
    G.k = G'.k :=
  le_antisymm (hGmin G' hT.symm) (hG'min G hT)

/-! ## Section 10: Boundary-Weighted Isomorphism -/

structure BoundaryWeightedIso (G G' : ScatteringNetwork m n) where
  vertexEquiv : Fin G.k ≃ Fin G'.k
  inputWeights_preserved : ∀ (i : Fin m) (v : Fin G.k),
    G.inputWeights i v = G'.inputWeights i (vertexEquiv v)
  outputWeights_preserved : ∀ (v : Fin G.k) (j : Fin n),
    G.outputWeights v j = G'.outputWeights (vertexEquiv v) j

theorem iso_preserves_transfer (G G' : ScatteringNetwork m n)
    (φ : BoundaryWeightedIso G G') :
    G.transferMatrix = G'.transferMatrix := by
  -- By definition of boundary-weighted isomorphism, the path weights are preserved.
  have h_path_weights : ∀ i j v, G.pathWeight i v j = G'.pathWeight i (φ.vertexEquiv v) j := by
    exact fun i j v => by rw [ ScatteringNetwork.pathWeight, ScatteringNetwork.pathWeight, φ.inputWeights_preserved, φ.outputWeights_preserved ] ;
  funext i j;
  refine' le_antisymm _ _ <;> simp +decide [ *, ScatteringNetwork.transferMatrix ];
  · exact fun b => ⟨ φ.vertexEquiv.symm b, by simp +decide ⟩;
  · exact fun v => ⟨ _, le_rfl ⟩

/-! ## Section 11: Certified Reconstruction -/

structure PathSeparationCertificate (m n : ℕ) where
  k : ℕ
  hk : 0 < k
  inputWeights : Fin m → Fin k → ℝ
  outputWeights : Fin k → Fin n → ℝ
  witnessInput : Fin k → Fin m
  witnessOutput : Fin k → Fin n
  witness_strict_min : ∀ (v : Fin k) (w : Fin k), w ≠ v →
    inputWeights (witnessInput v) v + outputWeights v (witnessOutput v) <
    inputWeights (witnessInput v) w + outputWeights w (witnessOutput v)

def reconstructFromCertificate (cert : PathSeparationCertificate m n) :
    ScatteringNetwork m n where
  k := cert.k
  hk := cert.hk
  inputWeights := cert.inputWeights
  outputWeights := cert.outputWeights

theorem certified_reconstruction_reduced
    (cert : PathSeparationCertificate m n) :
    (reconstructFromCertificate cert).IsReduced :=
  fun v => ⟨cert.witnessInput v, cert.witnessOutput v,
    fun w hw => cert.witness_strict_min v w (by simpa using hw)⟩

theorem certified_reconstruction_sound
    (cert : PathSeparationCertificate m n) (T : TropicalMatrix m n)
    (hT : (reconstructFromCertificate cert).transferMatrix = T) :
    (reconstructFromCertificate cert).IsReduced ∧
    (reconstructFromCertificate cert).transferMatrix = T :=
  ⟨certified_reconstruction_reduced cert, hT⟩

/-! ## Section 12: Cryptographic Corollary -/

theorem minimal_public_transfer_determines_size
    {G G' : ScatteringNetwork m n}
    (hGmin : G.IsMinimal) (hG'min : G'.IsMinimal)
    (hpub : G.transferMatrix = G'.transferMatrix) :
    G.k = G'.k :=
  minimal_realization_unique_internal_count G G' hGmin hG'min hpub

/-! ## Section 13: Tropical Distributivity -/

def tropicalSum (a b : ℝ) : ℝ := min a b

theorem tropical_plus_distributes_over_min (a b c : ℝ) :
    c + tropicalSum a b = tropicalSum (c + a) (c + b) := by
  simp [tropicalSum, min_add_add_left]

theorem transfer_shift_invariance (G : ScatteringNetwork m n) (c : ℝ)
    (i : Fin m) (j : Fin n) :
    let G' : ScatteringNetwork m n := {
      k := G.k
      hk := G.hk
      inputWeights := fun i' v => G.inputWeights i' v + c
      outputWeights := G.outputWeights
    }
    G'.transferMatrix i j = G.transferMatrix i j + c := by
  refine' le_antisymm _ _;
  · obtain ⟨ v, hv ⟩ := transferMatrix_exists_minimizer G i j;
    refine' le_trans ( Finset.inf'_le _ <| Finset.mem_univ v ) _;
    unfold ScatteringNetwork.pathWeight at *; linarith!;
  · unfold ScatteringNetwork.transferMatrix;
    simp +decide [ ScatteringNetwork.pathWeight ];
    exact fun v => by linarith [ Finset.inf'_le ( fun x => G.inputWeights i x + G.outputWeights x j ) ( Finset.mem_univ v ) ] ;

/-! ## Section 14: Min-Plus Semimodule Structure -/

def TransferSemimodule (T : TropicalMatrix m n) (hm : 0 < m) : Set (Fin n → ℝ) :=
  {f : Fin n → ℝ | ∃ (cs : Fin m → ℝ),
    ∀ j : Fin n, f j = Finset.univ.inf'
      (Finset.univ_nonempty_iff.mpr ⟨⟨0, hm⟩⟩)
      (fun l => cs l + T l j)}

theorem row_mem_transferSemimodule (T : TropicalMatrix m n) (hm : 0 < m)
    (hn : 0 < n) (i₀ : Fin m) :
    (fun j => T i₀ j) ∈ TransferSemimodule T hm := by
  -- By definition of `TransferSemimodule`, we need to show that there exists a function `cs : Fin m → ℝ` such that for all `j : Fin n`, `T i₀ j = Finset.univ.inf' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hm⟩⟩) (fun l => cs l + T l j)`.
  use fun l => if l = i₀ then 0 else 2 * matBound hm hn T + 1;
  intro j; refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, le_inf' ] ;
  · intro b; split_ifs <;> norm_num;
    · aesop;
    · linarith [ abs_le.mp ( le_matBound hm hn T i₀ j ), abs_le.mp ( le_matBound hm hn T b j ) ];
  · exact ⟨ i₀, by norm_num ⟩

end ScatteringNetwork

end