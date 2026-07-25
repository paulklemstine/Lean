import Mathlib

/-!
# Hilbert's Sixth Problem: An Axiomatic Foundation for Probability

This file gives a fully self-contained, abstract formalization of Kolmogorov's
axiomatization of probability — the probabilistic half of Hilbert's sixth problem
("the axiomatization of those physical sciences in which mathematics plays an
important role").  Rather than reusing Mathlib's measure-theoretic
`MeasureTheory.IsProbabilityMeasure`, we axiomatize a *finitely additive*
probability assignment directly on the Boolean algebra of subsets of a sample
space `Ω`, and derive the classical laws of probability purely from the axioms.

The point of this exercise is foundational: we exhibit the minimal set of axioms
(non-negativity, normalization, finite additivity on disjoint events) and show
that the entire elementary calculus of probability — the complement rule,
monotonicity, the modular / valuation law, and Boole's inequality for arbitrary
finite families of events — follows.  We also prove the axiom system is
*consistent* by exhibiting an explicit model (the Dirac point mass).

## Main definitions
- `KolmogorovSpace Ω`: a finitely additive probability assignment on `Set Ω`.
- `KolmogorovAxioms.diracSpace ω₀`: the Dirac point-mass model.

## Main theorems
- `KolmogorovSpace.prob_empty`: the impossible event has probability 0.
- `KolmogorovSpace.prob_compl`: the complement rule `P Aᶜ = 1 - P A`.
- `KolmogorovSpace.prob_mono`: monotonicity of probability.
- `KolmogorovSpace.prob_le_one`: every event has probability at most 1.
- `KolmogorovSpace.prob_modular`: the modular / valuation law
  `P (A ∪ B) + P (A ∩ B) = P A + P B`, the bridge to lattice-theoretic and
  topos-theoretic valuations.
- `KolmogorovSpace.prob_union_le`: two-event Boole inequality (subadditivity).
- `KolmogorovSpace.prob_biUnion_le`: Boole's inequality for an arbitrary finite
  family of events.
- `KolmogorovAxioms.kolmogorov_consistent`: consistency — the axiom system is
  inhabited for nonempty `Ω` via the Dirac model.
-/

namespace KolmogorovAxioms

open scoped BigOperators

/-- **Kolmogorov's axioms** (finitely additive form).  A `KolmogorovSpace` on a
sample space `Ω` assigns to every event `A : Set Ω` a real "probability" `P A`
subject to:
* (K1) non-negativity: `0 ≤ P A`;
* (K2) normalization: the certain event has probability `1`;
* (K3) finite additivity: disjoint events have additive probability. -/
structure KolmogorovSpace (Ω : Type*) where
  /-- The probability assignment. -/
  P : Set Ω → ℝ
  /-- Axiom K1: probabilities are non-negative. -/
  nonneg : ∀ A, 0 ≤ P A
  /-- Axiom K2: the certain event has probability 1. -/
  prob_univ : P Set.univ = 1
  /-- Axiom K3: finite additivity on disjoint events. -/
  additive : ∀ A B, Disjoint A B → P (A ∪ B) = P A + P B

namespace KolmogorovSpace

variable {Ω : Type*} (K : KolmogorovSpace Ω)

-- !-- Lab Notebook: prob_empty -- !--
-- !-- Hypothesis: P ∅ = 0 should follow because ∅ is disjoint from itself. -- !--
-- !-- Result: P ∅ = P (∅ ∪ ∅) = P ∅ + P ∅ ⇒ P ∅ = 0. -- !--
-- !-- Insight: idempotence of ∅ under union + additivity forces the unit of the monoid. -- !--
-- !-- Failure analysis: none; one-line consequence of additivity applied to ∅, ∅. -- !--
-- !-- End Lab Notebook -- !--
/-- The impossible event has probability `0`. -/
theorem prob_empty : K.P ∅ = 0 := by
  simpa using K.additive ∅ ∅

-- !-- Proof sketch -- !--
-- !-- univ = A ∪ Aᶜ disjointly, so 1 = P A + P Aᶜ by K2 + K3, hence P Aᶜ = 1 - P A. -- !--
-- !-- End sketch -- !--
/-- The complement rule `P Aᶜ = 1 - P A`. -/
theorem prob_compl (A : Set Ω) : K.P Aᶜ = 1 - K.P A := by
  have h := K.additive A Aᶜ disjoint_compl_right
  rw [Set.union_compl_self, K.prob_univ] at h
  linarith

-- !-- Proof sketch -- !--
-- !-- B = A ∪ (B \ A) disjointly, so P B = P A + P (B\A) ≥ P A by K1. -- !--
-- !-- End sketch -- !--
/-- Probability is monotone with respect to inclusion of events. -/
theorem prob_mono {A B : Set Ω} (h : A ⊆ B) : K.P A ≤ K.P B := by
  have h_union : B = A ∪ (B \ A) := by rw [Set.union_diff_cancel h]
  have h_disjoint : Disjoint A (B \ A) := disjoint_sdiff_self_right
  rw [h_union, K.additive _ _ h_disjoint]
  linarith [K.nonneg (B \ A)]

-- !-- Proof sketch -- !--
-- !-- A ⊆ univ and prob_univ = 1 with monotonicity. -- !--
-- !-- End sketch -- !--
/-- Every event has probability at most `1`. -/
theorem prob_le_one (A : Set Ω) : K.P A ≤ 1 :=
  K.prob_univ ▸ K.prob_mono (Set.subset_univ A)

-- !-- Lab Notebook: prob_modular -- !--
-- !-- Hypothesis: P(A∪B)+P(A∩B)=P A+P B — probability is a *valuation* on the Boolean algebra. -- !--
-- !-- Result: decompose A∪B = A ⊔ (B\A) and B = (A∩B) ⊔ (B\A), both disjoint, then subtract. -- !--
-- !-- Insight: This modular law is exactly the defining condition of a lattice valuation; -- !--
-- !-- it is the precise bridge from Kolmogorov probability to topos/locale-theoretic valuations. -- !--
-- !-- Failure analysis: a single additive split is insufficient; two complementary -- !--
-- !-- disjoint decompositions sharing the term P(B\A) are needed to cancel. -- !--
-- !-- End Lab Notebook -- !--
/-- The **modular / valuation law**: `P (A ∪ B) + P (A ∩ B) = P A + P B`. -/
theorem prob_modular (A B : Set Ω) :
    K.P (A ∪ B) + K.P (A ∩ B) = K.P A + K.P B := by
  have h1 : K.P (A ∪ B) = K.P A + K.P (B \ A) := by
    rw [← K.additive] <;> norm_num [Set.disjoint_sdiff_right]
  have h2 : K.P B = K.P (A ∩ B) + K.P (B \ A) := by
    rw [← K.additive]
    · exact congr_arg _ (by ext x; by_cases hx : x ∈ A <;> simp +decide [hx])
    · exact Set.disjoint_left.mpr fun x => by aesop
  linarith

-- !-- Proof sketch -- !--
-- !-- From prob_modular, P(A∪B) = P A + P B - P(A∩B) ≤ P A + P B since P(A∩B) ≥ 0. -- !--
-- !-- End sketch -- !--
/-- Two-event **Boole inequality** (finite subadditivity). -/
theorem prob_union_le (A B : Set Ω) : K.P (A ∪ B) ≤ K.P A + K.P B := by
  linarith [K.prob_modular A B, K.nonneg (A ∩ B)]

-- !-- Lab Notebook: prob_biUnion_le -- !--
-- !-- Hypothesis: Boole's inequality P(⋃ i∈s, A i) ≤ Σ_{i∈s} P(A i) for any finite index set s. -- !--
-- !-- Result: Finset induction; base uses prob_empty, step uses two-event prob_union_le. -- !--
-- !-- Insight: subadditivity bootstraps from 2 events to arbitrary finite families with no -- !--
-- !-- disjointness hypothesis — the workhorse "union bound" of probabilistic combinatorics. -- !--
-- !-- Failure analysis: a direct n-fold additive decomposition fails without disjointness; -- !--
-- !-- the inductive subadditive bound is the correct route. -- !--
-- !-- End Lab Notebook -- !--
/-- **Boole's inequality** for an arbitrary finite family of events. -/
theorem prob_biUnion_le {ι : Type*} (s : Finset ι) (A : ι → Set Ω) :
    K.P (⋃ i ∈ s, A i) ≤ ∑ i ∈ s, K.P (A i) := by
  classical
  induction s using Finset.induction with
  | empty => simp [K.prob_empty]
  | insert a s ha ih =>
    rw [Finset.set_biUnion_insert, Finset.sum_insert ha]
    exact le_trans (K.prob_union_le _ _) (by linarith)

end KolmogorovSpace

/-! ## Consistency: an explicit model of the axioms (the Dirac point mass) -/

-- !-- Lab Notebook: diracSpace / kolmogorov_consistent -- !--
-- !-- Hypothesis: the axioms are consistent — they have a model. -- !--
-- !-- Result: the Dirac mass at ω₀ (P A = 1 if ω₀∈A else 0) satisfies K1–K3. -- !--
-- !-- Insight: consistency of an axiom system is established by exhibiting a model; -- !--
-- !-- the Dirac mass is the canonical deterministic ("classical point particle") model, -- !--
-- !-- linking the probabilistic axioms to deterministic mechanics. -- !--
-- !-- Failure analysis: additivity needed the disjointness fact that ω₀ cannot lie in -- !--
-- !-- both events; Set.disjoint_left supplies exactly this. -- !--
-- !-- End Lab Notebook -- !--
open Classical in
/-- The Dirac point-mass probability space at a point `ω₀`. -/
noncomputable def diracSpace {Ω : Type*} (ω₀ : Ω) : KolmogorovSpace Ω where
  P A := if ω₀ ∈ A then 1 else 0
  nonneg A := by split_ifs <;> norm_num
  prob_univ := by simp
  additive A B h := by
    by_cases hA : ω₀ ∈ A
    · have hB : ω₀ ∉ B := fun hB => (Set.disjoint_left.mp h hA) hB
      simp [Set.mem_union, hA, hB]
    · by_cases hB : ω₀ ∈ B <;> simp [Set.mem_union, hA, hB]

/-- **Consistency of Kolmogorov's axioms**: for any nonempty sample space the
axiom system has a model, hence is consistent. -/
theorem kolmogorov_consistent {Ω : Type*} [Nonempty Ω] : Nonempty (KolmogorovSpace Ω) :=
  ⟨diracSpace (Classical.arbitrary Ω)⟩

end KolmogorovAxioms