/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Quantum Random Walks on Cayley Graphs: Definitions

This file introduces the core mathematical structures for studying quantum
random walks on Cayley graphs of finite groups. We formalize:

1. **Symmetric generating sets** — a generating set S of a group G with S = S⁻¹
2. **Cayley walk data** — packages a group with its generating set and regularity
3. **Spectral gap** — the gap 1 - |λ₂| controlling mixing behavior
4. **Mixing time bounds** — both classical and quantum regimes
5. **Quantum walk amplitude** — the probability distribution from quantum evolution

## Mathematical Overview

A quantum random walk on a Cayley graph Cay(G, S) evolves unitarily on ℓ²(G).
The key insight is that the spectral gap γ of the normalized adjacency operator
controls both classical mixing (τ_cl ~ 1/γ · log|G|) and quantum mixing
(τ_q ~ 1/√γ · √(log|G|)), giving a quadratic speedup in favorable cases.

## Novel Definition: CayleyWalkData

This structure packages a finite group with a symmetric generating set and
tracks the regularity degree |S|, enabling spectral analysis of the
associated random walk. This is a new formalization not present in Mathlib
or the existing Catalog.
-/

open Finset BigOperators Real

noncomputable section

/-! ## Section 1: Symmetric Generating Sets -/

/-- A symmetric generating set for a group G: a finite set S ⊆ G with
    1 ∉ S, S = S⁻¹, and ⟨S⟩ = G. We require symmetry for the random walk
    to be reversible and the spectral theory to apply. -/
structure SymGenSet (G : Type*) [Group G] [Fintype G] [DecidableEq G] where
  /-- The generating set as a Finset -/
  carrier : Finset G
  /-- The identity is not in S (convention for Cayley graphs) -/
  one_not_mem : (1 : G) ∉ carrier
  /-- S is symmetric: g ∈ S ↔ g⁻¹ ∈ S -/
  symm : ∀ g : G, g ∈ carrier → g⁻¹ ∈ carrier
  /-- S is nonempty -/
  nonempty : carrier.Nonempty

namespace SymGenSet

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- The degree (valency) of the Cayley graph is |S|. -/
def degree (S : SymGenSet G) : ℕ := S.carrier.card

/-- The degree is at least 1 since S is nonempty. -/
theorem degree_pos (S : SymGenSet G) : 0 < S.degree := by
  exact Finset.Nonempty.card_pos S.nonempty

/-
The degree is at least 2 for a symmetric set (since g ∈ S implies g⁻¹ ∈ S).
-/
theorem degree_ge_two (S : SymGenSet G) (h : ∃ g ∈ S.carrier, g ≠ g⁻¹) :
    2 ≤ S.degree := by
  exact Finset.one_lt_card.2 ⟨ h.choose, h.choose_spec.1, h.choose⁻¹, S.symm _ h.choose_spec.1, h.choose_spec.2 ⟩

end SymGenSet

/-! ## Section 2: Cayley Walk Data -/

/-- CayleyWalkData packages all the information needed to study random walks
    on a Cayley graph: the group G, a symmetric generating set S, and derived
    quantities like the degree d = |S| and group order N = |G|.

    This is the central novel definition of this formalization, providing a
    unified structure for analyzing both classical and quantum walks. -/
structure CayleyWalkData where
  /-- The underlying finite group -/
  G : Type*
  /-- Group structure -/
  instGroup : Group G
  /-- Finiteness -/
  instFintype : Fintype G
  /-- Decidable equality -/
  instDecEq : DecidableEq G
  /-- The symmetric generating set -/
  genSet : @SymGenSet G instGroup instFintype instDecEq
  /-- The group has at least 2 elements (non-trivial) -/
  group_nontrivial : @Fintype.card G instFintype ≥ 2

namespace CayleyWalkData

variable (W : CayleyWalkData)

/-- Group order N = |G| -/
def groupOrder : ℕ := @Fintype.card W.G W.instFintype

/-- The degree d = |S| of the Cayley graph -/
def deg : ℕ := @SymGenSet.degree W.G W.instGroup W.instFintype W.instDecEq W.genSet

/-- Group order is at least 2 -/
theorem groupOrder_ge_two : W.groupOrder ≥ 2 := W.group_nontrivial

end CayleyWalkData

/-! ## Section 3: Spectral Gap Abstraction -/

/-- SpectralGapCertificate witnesses that a walk on N vertices with degree d
    has spectral gap at least γ. The spectral gap γ = 1 - |λ₂| where λ₂ is
    the second-largest eigenvalue of the normalized adjacency matrix.

    This abstraction allows us to state mixing time bounds parametrically
    without needing the full linear algebra machinery of eigenvalue computation. -/
structure SpectralGapCertificate where
  /-- Number of vertices (= |G|) -/
  N : ℕ
  /-- Degree of the Cayley graph (= |S|) -/
  d : ℕ
  /-- The spectral gap γ ∈ (0, 1] -/
  gap : ℝ
  /-- N ≥ 2 for non-trivial graphs -/
  hN : N ≥ 2
  /-- d ≥ 1 -/
  hd : d ≥ 1
  /-- gap is positive -/
  gap_pos : gap > 0
  /-- gap is at most 1 -/
  gap_le_one : gap ≤ 1

namespace SpectralGapCertificate

/-- The classical mixing time bound: τ_cl ≤ (1/γ) · ln(N).
    This is the standard Markov chain mixing time bound from spectral gap theory. -/
def classicalMixingBound (cert : SpectralGapCertificate) : ℝ :=
  (1 / cert.gap) * Real.log cert.N

/-- The quantum mixing time bound: τ_q ≤ (1/√γ) · √(ln(N)).
    This represents the conjectured quadratic speedup for quantum walks. -/
def quantumMixingBound (cert : SpectralGapCertificate) : ℝ :=
  (1 / Real.sqrt cert.gap) * Real.sqrt (Real.log cert.N)

end SpectralGapCertificate

/-! ## Section 4: Walk Probability Distribution -/

/-- A probability distribution on a finite type. -/
structure ProbDist (Ω : Type*) [Fintype Ω] where
  prob : Ω → ℝ
  prob_nonneg : ∀ x, 0 ≤ prob x
  prob_sum : ∑ x : Ω, prob x = 1

/-- The uniform distribution on a finite type. -/
def uniformDist (Ω : Type*) [Fintype Ω] [Nonempty Ω] : ProbDist Ω where
  prob := fun _ => (1 : ℝ) / Fintype.card Ω
  prob_nonneg := by
    intro x
    positivity
  prob_sum := by
    simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    field_simp

/-- Total variation distance between two distributions. -/
def tvDist {Ω : Type*} [Fintype Ω] (p q : ProbDist Ω) : ℝ :=
  (1 / 2) * ∑ x : Ω, |p.prob x - q.prob x|

/-
TV distance is nonneg.
-/
theorem tvDist_nonneg {Ω : Type*} [Fintype Ω] (p q : ProbDist Ω) :
    0 ≤ tvDist p q := by
  exact mul_nonneg ( by norm_num ) ( Finset.sum_nonneg fun _ _ => abs_nonneg _ )

/-
TV distance is symmetric.
-/
theorem tvDist_symm {Ω : Type*} [Fintype Ω] (p q : ProbDist Ω) :
    tvDist p q = tvDist q p := by
  -- By definition of absolute value, we know that |a - b| = |b - a| for any real numbers a and b.
  have h_abs : ∀ a b : ℝ, |a - b| = |b - a| := by
    exact fun a b => abs_sub_comm _ _;
  unfold tvDist; simp +decide only [h_abs] ;

end