/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Holographic Reconstruction: Definitions and Basic Lemmas

This file develops a theory of **weighted closure systems** with tropical (min-plus)
boundary response. The central objects are:

* `WeightedClosureSystem X G` — a system where generators `g : G` produce outputs
  `out g : Finset X` at tropical cost `weight g : ℝ≥0∞`.
* `boundarySig B S g` — the boundary signature of generator `g`, restricting outputs to `B`.
* `propagationCost S s t` — the minimum cost to cover `t` starting from seed `s`.
* `boundaryKernel B S b` — the minimum cost to produce boundary element `b`.
* `boundaryEntropyProfile B S k` — the minimum cost to activate `≥ k` boundary elements.

## Main Results

* `propagationCost_self` — covering a subset of the seed costs 0.
* `propagationCost_mono_seed` — larger seeds have lower propagation costs.
* `boundaryKernel_le_weight` — kernel values are bounded by generator weights.
* `boundaryEntropyProfile_mono` — the entropy profile is monotone non-decreasing.
* `boundarySig_subset` — boundary signatures are subsets of the boundary.
* `Separating.isNormalForm` — separating systems are in normal form.
-/

noncomputable section

open Finset ENNReal

namespace TropicalHolography

variable {X : Type*} [DecidableEq X] [Fintype X]

/-! ## Core Structure -/

/-- A weighted closure system over state space `X` with generators `G`.
    Each generator `g` produces outputs `out g : Finset X` at tropical cost `weight g`. -/
structure WeightedClosureSystem (X : Type*) (G : Type*) [DecidableEq X] where
  /-- The output set of each generator. -/
  out : G → Finset X
  /-- The tropical weight (cost) of each generator. -/
  weight : G → ℝ≥0∞

variable {G : Type*} [DecidableEq G] [Fintype G]

/-! ## Boundary Signature -/

/-- The boundary signature of generator `g`: the subset of its outputs lying in `B`. -/
def boundarySig (B : Finset X) (S : WeightedClosureSystem X G) (g : G) : Finset X :=
  (S.out g).filter (· ∈ B)

omit [Fintype X] [DecidableEq G] [Fintype G] in
/-- Boundary signatures are subsets of the boundary. -/
theorem boundarySig_subset (B : Finset X) (S : WeightedClosureSystem X G) (g : G) :
    boundarySig B S g ⊆ B := by
  intro x hx
  simp [boundarySig, Finset.mem_filter] at hx
  exact hx.2

/-! ## Structural Predicates -/

/-- A system is **reduced** w.r.t. `B` if every generator affects the boundary. -/
def WeightedClosureSystem.Reduced (S : WeightedClosureSystem X G) (B : Finset X) : Prop :=
  ∀ g : G, (boundarySig B S g).Nonempty

/-- A system is **separating** w.r.t. `B` if distinct generators have
    distinct boundary signatures. -/
def WeightedClosureSystem.Separating (S : WeightedClosureSystem X G) (B : Finset X) : Prop :=
  Function.Injective (boundarySig B S)

/-- A system is in **normal form** w.r.t. `B` if the combined
    `(signature, weight)` map is injective. -/
def WeightedClosureSystem.IsNormalForm (S : WeightedClosureSystem X G) (B : Finset X) : Prop :=
  Function.Injective (fun g => (boundarySig B S g, S.weight g))

omit [Fintype X] [DecidableEq G] [Fintype G] in
/-- Separating implies normal form (signatures alone are injective,
    so the pair is also injective). -/
theorem WeightedClosureSystem.Separating.isNormalForm
    {S : WeightedClosureSystem X G} {B : Finset X}
    (h : S.Separating B) : S.IsNormalForm B := by
  intro g₁ g₂ heq
  exact h (Prod.ext_iff.mp heq).1

/-! ## Propagation Cost -/

/-- The propagation cost from seed `s` to target `t`: the minimum total
    generator weight needed so that `t ⊆ s ∪ ⋃_{g ∈ gs} out(g)`. -/
def propagationCost (S : WeightedClosureSystem X G) (s t : Finset X) : ℝ≥0∞ :=
  ⨅ (gs : Finset G) (_ : t ⊆ s ∪ gs.biUnion S.out), gs.sum S.weight

/-
Covering a subset of the seed costs 0.
-/
omit [Fintype X] [DecidableEq G] [Fintype G] in
theorem propagationCost_self (S : WeightedClosureSystem X G) (s t : Finset X) (h : t ⊆ s) :
    propagationCost S s t = 0 := by
  refine' le_antisymm _ _;
  · refine' ciInf_le_of_le _ _ _;
    exacts [ ⟨ 0, Set.forall_mem_range.2 fun _ => zero_le _ ⟩, ∅, by simp +decide [ h ] ];
  · exact zero_le _

/-
Propagation cost is anti-monotone in the seed: larger seeds yield lower costs.
-/
omit [Fintype X] [DecidableEq G] [Fintype G] in
theorem propagationCost_mono_seed (S : WeightedClosureSystem X G) {s₁ s₂ t : Finset X}
    (h : s₁ ⊆ s₂) : propagationCost S s₂ t ≤ propagationCost S s₁ t := by
  refine' iInf_mono' _;
  intro gs; use gs; simp +decide;
  exact fun ht => iInf_le_of_le ( Finset.Subset.trans ht ( Finset.union_subset_union h ( Finset.Subset.refl _ ) ) ) le_rfl

/-
Propagation cost is monotone in the target: larger targets cost at least as much.
-/
omit [Fintype X] [DecidableEq G] [Fintype G] in
theorem propagationCost_mono_target (S : WeightedClosureSystem X G) {s t₁ t₂ : Finset X}
    (h : t₁ ⊆ t₂) : propagationCost S s t₁ ≤ propagationCost S s t₂ := by
  refine' le_iInf₂ fun gs hgs => iInf₂_le gs _;
  exact Finset.Subset.trans h hgs

/-! ## Boundary Kernel -/

/-- The boundary kernel at element `b`: the minimum weight of any generator
    whose boundary signature contains `b`. -/
def boundaryKernel (B : Finset X) (S : WeightedClosureSystem X G) (b : X) : ℝ≥0∞ :=
  ⨅ (g : G) (_ : b ∈ boundarySig B S g), S.weight g

/-
The boundary kernel at `b` is bounded by the weight of any generator covering `b`.
-/
omit [Fintype X] [DecidableEq G] [Fintype G] in
theorem boundaryKernel_le_weight (B : Finset X) (S : WeightedClosureSystem X G)
    {b : X} {g : G} (hb : b ∈ boundarySig B S g) :
    boundaryKernel B S b ≤ S.weight g := by
  exact iInf₂_le g hb

/-! ## Boundary Entropy Profile -/

/-- The boundary entropy profile at `k`: minimum generator weight among those
    whose boundary signature has cardinality `≥ k`. -/
def boundaryEntropyProfile (B : Finset X) (S : WeightedClosureSystem X G) (k : ℕ) : ℝ≥0∞ :=
  ⨅ (g : G) (_ : k ≤ (boundarySig B S g).card), S.weight g

/-
The entropy profile is monotone: larger `k` gives higher (or equal) cost.
-/
omit [Fintype X] [DecidableEq G] [Fintype G] in
theorem boundaryEntropyProfile_mono (B : Finset X) (S : WeightedClosureSystem X G)
    {k₁ k₂ : ℕ} (h : k₁ ≤ k₂) :
    boundaryEntropyProfile B S k₁ ≤ boundaryEntropyProfile B S k₂ := by
  apply_rules [ iInf_mono ];
  intro g; rw [ ciInf_eq_ite, ciInf_eq_ite ] ; split_ifs <;> simp_all +decide ;
  linarith

/-
At `k = 0`, the entropy profile is the infimum over all generator weights.
-/
omit [Fintype X] [DecidableEq G] [Fintype G] in
theorem boundaryEntropyProfile_zero (B : Finset X) (S : WeightedClosureSystem X G) :
    boundaryEntropyProfile B S 0 = ⨅ (g : G), S.weight g := by
  -- By definition of boundary entropy profile, we have:
  unfold boundaryEntropyProfile;
  simp +decide

/-
The entropy profile at `k` is at most the weight of any generator
    with sufficiently large boundary signature.
-/
omit [Fintype X] [DecidableEq G] [Fintype G] in
theorem boundaryEntropyProfile_le_weight (B : Finset X) (S : WeightedClosureSystem X G)
    {k : ℕ} {g : G} (hk : k ≤ (boundarySig B S g).card) :
    boundaryEntropyProfile B S k ≤ S.weight g := by
  refine' ciInf_le_of_le _ _ _;
  exacts [ ⟨ 0, Set.forall_mem_range.2 fun _ => zero_le _ ⟩, g, by simp +decide [ hk ] ]

/-! ## Boundary Data -/

/-- The boundary data of a system: the Finset of `(signature, weight)` pairs. -/
def boundaryDataSet (B : Finset X) (S : WeightedClosureSystem X G) :
    Finset (Finset X × ℝ≥0∞) :=
  Finset.univ.image (fun g => (boundarySig B S g, S.weight g))

omit [Fintype X] [DecidableEq G] in
/-- Every `(signature, weight)` pair of a generator appears in the boundary data. -/
theorem mem_boundaryDataSet (B : Finset X) (S : WeightedClosureSystem X G) (g : G) :
    (boundarySig B S g, S.weight g) ∈ boundaryDataSet B S :=
  Finset.mem_image_of_mem _ (Finset.mem_univ g)

omit [Fintype X] [DecidableEq G] in
/-- In normal form, the cardinality of boundary data equals the number of generators. -/
theorem card_boundaryDataSet_of_normalForm (B : Finset X) (S : WeightedClosureSystem X G)
    (hnf : S.IsNormalForm B) :
    (boundaryDataSet B S).card = Fintype.card G := by
  convert Finset.card_image_of_injective _ hnf

end TropicalHolography