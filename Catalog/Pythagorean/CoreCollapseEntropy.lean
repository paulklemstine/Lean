/-
Copyright (c) 2025. All rights reserved.

# Core-Collapse Acceleration: Information-Theoretic Foundations

This file establishes the quantitative information-theoretic law underlying
semantic graph collapse: **low feature entropy forces metric concentration,
and metric concentration forces early complete-graph collapse**.

## Main Results

1. **Disagreement Identity** (`sum_symmDiff_eq_two_mul_sum_featureCount_compl`):
   `∑ₛ ∑ₜ |s △ t| = 2 · ∑_f n_f · (N - n_f)`

2. **Majority Core Distance** (`sum_dist_to_majorityCore_eq_sum_minorityCount`):
   `∑ₛ |s △ core| = ∑_f min(n_f, N - n_f)`

3. **Entropy-Driven Collapse** (`semanticGraph_complete_of_majorityCore_radius`):
   The semantic graph becomes complete at threshold `2 · coreRadius`.
-/

import Mathlib
import Speculative.ProofTheoreticTopology.Defs
import Speculative.ProofTheoreticTopology.Theorems

open Finset

/-! ## Feature Statistics Definitions -/

/-- The *feature support* (universe) of a finite family of feature sets. -/
def featureSupport {β : Type*} [DecidableEq β] (S : Finset (Finset β)) : Finset β :=
  S.biUnion id

/-- The *feature count* of feature `f` in family `S`:
the number of members of `S` that contain `f`. -/
def featureCount {β : Type*} [DecidableEq β]
    (S : Finset (Finset β)) (f : β) : ℕ :=
  (S.filter (fun s => f ∈ s)).card

/-- The *minority count* of feature `f` in family `S`:
`min(n_f, N - n_f)`. -/
def minorityCount {β : Type*} [DecidableEq β]
    (S : Finset (Finset β)) (f : β) : ℕ :=
  min (featureCount S f) (S.card - featureCount S f)

/-- The *minority mass numerator*: the sum of minority counts over
all features in the support. -/
def minorityMassNumerator {β : Type*} [DecidableEq β]
    (S : Finset (Finset β)) : ℕ :=
  ∑ f ∈ featureSupport S, minorityCount S f

/-- The *collision entropy numerator*: `∑_f n_f · (N - n_f)`. -/
def collisionEntropyNumerator {β : Type*} [DecidableEq β]
    (S : Finset (Finset β)) : ℕ :=
  ∑ f ∈ featureSupport S, featureCount S f * (S.card - featureCount S f)

/-- The *majority core* of a finite family: `f` belongs iff
strictly more than half of `S` contains `f`. -/
def majorityCore {β : Type*} [DecidableEq β]
    (S : Finset (Finset β)) : Finset β :=
  (featureSupport S).filter (fun f => 2 * featureCount S f > S.card)

/-- Core radius for possibly-empty families, defaulting to 0. -/
def coreRadius' {β : Type*} [DecidableEq β]
    (S : Finset (Finset β)) (c : Finset β) : ℕ :=
  S.sup (fun s => symmDiffCard s c)

/-! ## Basic Properties -/

theorem featureCount_le_card {β : Type*} [DecidableEq β]
    (S : Finset (Finset β)) (f : β) :
    featureCount S f ≤ S.card :=
  card_filter_le S _

theorem card_filter_not_mem {β : Type*} [DecidableEq β]
    (S : Finset (Finset β)) (f : β) :
    (S.filter (fun s => f ∉ s)).card = S.card - featureCount S f := by
  rw [ tsub_eq_of_eq_add ];
  unfold featureCount; rw [ add_comm, Finset.card_filter_add_card_filter_not ] ;

theorem featureCount_eq_zero_of_not_mem_support {β : Type*} [DecidableEq β]
    (S : Finset (Finset β)) (f : β) (hf : f ∉ featureSupport S) :
    featureCount S f = 0 := by
  exact Finset.card_eq_zero.mpr ( Finset.filter_eq_empty_iff.mpr fun s hs => fun h => hf <| Finset.mem_biUnion.mpr ⟨ s, hs, h ⟩ )

/-! ## Theorem 1: Disagreement Identity -/

/-
**Disagreement identity.**
`∑_{s ∈ S} ∑_{t ∈ S} |s △ t| = 2 · ∑_{f ∈ U(S)} n_f · (N - n_f)`

This is the finite-feature analogue of the variance decomposition identity.
It converts an information statistic (collision entropy numerator) into
a graph-geometric observable (total pairwise distance).
-/
theorem sum_symmDiff_eq_two_mul_sum_featureCount_compl
    {β : Type*} [DecidableEq β]
    (S : Finset (Finset β)) :
    ∑ s ∈ S, ∑ t ∈ S, symmDiffCard s t
      = 2 * collisionEntropyNumerator S := by
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ s ∈ S, ∑ t ∈ S, symmDiffCard s t = ∑ f ∈ featureSupport S, ∑ s ∈ S, ∑ t ∈ S, (if f ∈ s \ t ∨ f ∈ t \ s then 1 else 0) := by
    rw [ Finset.sum_comm, Finset.sum_congr rfl ];
    rw [ Finset.sum_comm ];
    intro s hs;
    rw [ Finset.sum_comm, Finset.sum_congr rfl ];
    intro t ht
    simp [symmDiffCard];
    rw [ ← Finset.card_union_of_disjoint ];
    · congr with x ; simp +decide [ featureSupport ];
      grind;
    · exact disjoint_sdiff_sdiff;
  -- For each feature $f$, the number of pairs $(s, t)$ such that $f$ is in the symmetric difference of $s$ and $t$ is $2 \cdot n_f \cdot (N - n_f)$.
  have h_pairs : ∀ f ∈ featureSupport S, ∑ s ∈ S, ∑ t ∈ S, (if f ∈ s \ t ∨ f ∈ t \ s then 1 else 0) = 2 * (featureCount S f) * (S.card - featureCount S f) := by
    intro f hf
    have h_pairs_f : ∑ s ∈ S, ∑ t ∈ S, (if f ∈ s \ t ∨ f ∈ t \ s then 1 else 0) = (∑ s ∈ S, (if f ∈ s then 1 else 0)) * (∑ t ∈ S, (if f ∉ t then 1 else 0)) + (∑ s ∈ S, (if f ∉ s then 1 else 0)) * (∑ t ∈ S, (if f ∈ t then 1 else 0)) := by
      simp +decide only [Finset.sum_mul _ _ _, mul_sum];
      simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_congr rfl fun x hx => Finset.sum_congr rfl fun y hy => by by_cases hx' : f ∈ x <;> by_cases hy' : f ∈ y <;> simp +decide [ hx', hy' ] ;
    simp_all +decide [ two_mul, Finset.sum_ite ];
    rw [ show # ( { x ∈ S | f ∈ x } ) = featureCount S f from ?_, show # ( { x ∈ S | f ∉ x } ) = S.card - featureCount S f from ?_ ];
    · ring;
    · convert card_filter_not_mem S f using 1;
    · rfl;
  rw [ h_fubini, Finset.sum_congr rfl h_pairs, collisionEntropyNumerator ];
  simp +decide only [mul_assoc, Finset.mul_sum _ _ _]

/-! ## Theorem 2: Majority Core Distance Identity -/

/-
**Majority core distance identity.**
`∑_{s ∈ S} |s △ majorityCore(S)| = ∑_{f ∈ U(S)} min(n_f, N - n_f)`

The majority core acts as an `ℓ¹`-Fréchet median on the Boolean hypercube.
-/
theorem sum_dist_to_majorityCore_eq_sum_minorityCount
    {β : Type*} [DecidableEq β]
    (S : Finset (Finset β)) :
    ∑ s ∈ S, symmDiffCard s (majorityCore S)
      = minorityMassNumerator S := by
  -- Express symmDiffCard s (majorityCore S) as a sum over features.
  have h_symmDiffCard : ∀ s ∈ S, symmDiffCard s (majorityCore S) = ∑ f ∈ featureSupport S, (if f ∈ s then if 2 * featureCount S f ≤ S.card then 1 else 0 else if 2 * featureCount S f > S.card then 1 else 0) := by
    unfold symmDiffCard majorityCore; simp +decide [ Finset.sum_ite ] ;
    intro s hs; congr 1;
    · refine' Finset.card_bij ( fun x hx => x ) _ _ _ <;> simp +contextual [ Finset.mem_sdiff, Finset.mem_filter ];
      exact fun a ha ha' => ⟨ Finset.mem_biUnion.mpr ⟨ s, hs, ha ⟩, ha' ( Finset.mem_biUnion.mpr ⟨ s, hs, ha ⟩ ) ⟩;
    · exact congr_arg Finset.card ( by ext; aesop );
  rw [ Finset.sum_congr rfl h_symmDiffCard, Finset.sum_comm ];
  refine' Finset.sum_congr rfl fun f hf => _;
  simp +decide [ Finset.sum_ite, minorityCount ];
  split_ifs <;> simp_all +decide [ featureCount ];
  · linarith;
  · exact le_tsub_of_add_le_left ( by linarith );
  · grind +suggestions

/-! ## Theorem 3: Entropy-Driven Complete-Graph Collapse -/

/-
Every element of S has distance to center bounded by `coreRadius'`.
-/
theorem symmDiffCard_le_coreRadius' {β : Type*} [DecidableEq β]
    (S : Finset (Finset β)) (c : Finset β) (s : Finset β) (hs : s ∈ S) :
    symmDiffCard s c ≤ coreRadius' S c := by
  -- By definition of supremum, for any element s in S, the distance from s to c is less than or equal to the supremum of the distances from elements of S to c.
  apply Finset.le_sup hs

/-- **Complete-graph collapse from majority core radius.**
If every element's feature set lies within radius `r` of the majority core,
then the semantic graph is complete at threshold `2r`. -/
theorem semanticGraph_complete_of_majorityCore_radius
    {α β : Type*} [Fintype α] [DecidableEq α] [DecidableEq β]
    (F : α → Finset β) (r : ℕ)
    (hball : ∀ x, symmDiffCard (F x) (majorityCore (Finset.univ.image F)) ≤ r) :
    ∀ x y, x ≠ y → (semanticGraph F (2 * r)).Adj x y :=
  semanticGraph_complete_of_common_core F _ r hball

/-! ## Corollaries -/

/-- **Coding theory bridge.** Semantic distance equals symmetric-difference
cardinality, i.e., Hamming distance on feature-set codewords. -/
theorem semanticDist_eq_symmDiffCard {α β : Type*} [DecidableEq β]
    (F : α → Finset β) (x y : α) :
    semanticDist F x y = symmDiffCard (F x) (F y) := rfl

/-
Minority count is at most half the family size.
-/
theorem minorityCount_le_half {β : Type*} [DecidableEq β]
    (S : Finset (Finset β)) (f : β) :
    minorityCount S f ≤ S.card / 2 := by
  grind +locals

/-
`min(a, b) ≤ a * b` when `max(a, b) ≥ 1`, hence minority count
is bounded by the corresponding collision entropy term.
-/
theorem minorityCount_le_featureCount_mul {β : Type*} [DecidableEq β]
    (S : Finset (Finset β)) (f : β) :
    minorityCount S f ≤ featureCount S f * (S.card - featureCount S f) := by
  by_cases h' : S.card - featureCount S f = 0 <;> simp_all +decide [ minorityCount ];
  exact Or.inl ( Nat.le_mul_of_pos_right _ ( Nat.pos_of_ne_zero h' ) )

/-
**Minority mass ≤ collision entropy numerator.**
-/
theorem minorityMass_le_collisionEntropy {β : Type*} [DecidableEq β]
    (S : Finset (Finset β)) :
    minorityMassNumerator S ≤ collisionEntropyNumerator S := by
  exact Finset.sum_le_sum fun x hx => minorityCount_le_featureCount_mul S x;