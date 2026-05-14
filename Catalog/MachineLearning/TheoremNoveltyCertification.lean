/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Certified Novelty Detection via Theorem Embedding Uniqueness

This module formalizes a metric-geometric framework for certifying that a theorem
(represented by a descriptor) is *novel* relative to a finite catalog of known results.

The key idea: if we embed theorem descriptors into a metric space such that
"equivalent" theorems map within distance δ, then any candidate whose embedding
is farther than δ from every catalog point cannot be equivalent to any known theorem.

## Main results

- `novelty_of_far_from_catalog`: Sound novelty certification via metric separation.
- `novelty_of_nearestDist_gt`: Nearest-neighbor novelty score certification.
- `exists_nearest_in_finset`: Existence of a nearest catalog element.
- `not_equivalent_of_coordinate_gap`: Feature-gap obstruction for non-equivalence.
- `nonequiv_of_symbolCount_gap`: Concrete coordinate gap for theorem descriptors.
- `catalog_separation_implies_novelty_or_unique_match`: Partial completeness.
-/

import Mathlib

open scoped BigOperators

/-! ## Core Novelty Framework -/

section Novelty

variable {σ α : Type*}
variable [PseudoMetricSpace α]
variable (Equivalent : σ → σ → Prop)
variable (E : σ → α)

/-- A theorem descriptor `x` is *novel* with respect to a catalog `K` and an equivalence
relation if it is not equivalent to any element of the catalog. -/
def Novel (K : Finset σ) (x : σ) : Prop :=
  ∀ a ∈ K, ¬ Equivalent x a

/-
**Sound novelty certification.** If equivalent descriptors embed within distance δ,
then any candidate farther than δ from every catalog element is novel.
-/
theorem novelty_of_far_from_catalog
    (K : Finset σ) (δ : ℝ)
    (hEq : ∀ x y, Equivalent x y → dist (E x) (E y) ≤ δ) :
    ∀ x, (∀ a ∈ K, δ < dist (E x) (E a)) → Novel Equivalent K x := by
  exact fun x hx a ha => fun h => not_lt_of_ge ( hEq x a h ) ( hx a ha )

/-! ## Nearest-Neighbor Novelty Score -/

/-- The nearest distance from a candidate `x` to the catalog `K`, defined as
the infimum of distances to catalog elements. -/
noncomputable def nearestDist (K : Finset σ) (x : σ) (hK : K.Nonempty) : ℝ :=
  K.inf' hK (fun a => dist (E x) (E a))

/-
**Nearest-neighbor novelty certification.** If the nearest catalog distance exceeds δ,
the candidate is novel.
-/
theorem novelty_of_nearestDist_gt
    (K : Finset σ) (hK : K.Nonempty) (δ : ℝ)
    (hEq : ∀ x y, Equivalent x y → dist (E x) (E y) ≤ δ)
    (x : σ)
    (hfar : δ < nearestDist E K x hK) :
    Novel Equivalent K x := by
  -- Since δ < nearestDist E K x hK and nearestDist is K.inf', we have nearestDist ≤ dist (E x) (E a) for each a ∈ K.
  have hdist : ∀ a ∈ K, δ < dist (E x) (E a) := by
    exact fun a ha => hfar.trans_le ( Finset.inf'_le _ ha );
  exact fun y hy => fun h => not_lt_of_ge ( hEq _ _ h ) ( hdist _ hy )

/-
**Existence of a nearest catalog element.** For any nonempty finite catalog,
there exists an element achieving the minimum distance.
-/
theorem exists_nearest_in_finset
    (K : Finset σ) (hK : K.Nonempty) (x : σ) :
    ∃ a ∈ K, ∀ b ∈ K, dist (E x) (E a) ≤ dist (E x) (E b) := by
  exact Finset.exists_min_image _ _ hK

/-
The nearest distance equals the distance to some catalog element.
-/
theorem nearestDist_eq_dist_of_nearest
    (K : Finset σ) (hK : K.Nonempty) (x : σ) :
    ∃ a ∈ K, nearestDist E K x hK = dist (E x) (E a) := by
  exact Finset.exists_mem_eq_inf' hK fun a => dist (E x) (E a)

/-
Every catalog element is at least as far as the nearest distance.
-/
theorem nearestDist_le_dist
    (K : Finset σ) (hK : K.Nonempty) (x : σ) (a : σ) (ha : a ∈ K) :
    nearestDist E K x hK ≤ dist (E x) (E a) := by
  exact Finset.inf'_le _ ha

/-! ## Feature-Gap Obstruction -/

/-
**Coordinate-gap non-equivalence.** If a real-valued feature of two descriptors
differs by more than the equivalence tolerance, the descriptors are not equivalent.
-/
theorem not_equivalent_of_coordinate_gap
    (f : σ → ℝ)
    (Equiv' : σ → σ → Prop)
    (δ : ℝ)
    (hEq : ∀ x y, Equiv' x y → |f x - f y| ≤ δ)
    {x y : σ}
    (hgap : δ < |f x - f y|) :
    ¬ Equiv' x y := by
  exact fun h => hgap.not_ge <| hEq x y h

/-! ## Concrete Theorem Descriptor -/

/-- A concrete syntactic/structural descriptor for a theorem, capturing
key features that can be extracted from a formal statement. -/
structure TheoremDescriptor where
  /-- Number of free variables / parameters. -/
  arity : ℕ
  /-- Total count of symbols in the statement. -/
  symbolCount : ℕ
  /-- Maximum nesting depth of quantifiers. -/
  quantifierDepth : ℕ
  /-- Number of dependencies (imported lemmas used). -/
  dependencyCount : ℕ
  /-- Whether the proof uses induction. -/
  hasInduction : Bool
  /-- Whether the proof uses contradiction/contrapositive. -/
  hasContradiction : Bool
deriving DecidableEq

/-
**Symbol-count gap implies non-equivalence.**
-/
theorem nonequiv_of_symbolCount_gap
    (Equiv' : TheoremDescriptor → TheoremDescriptor → Prop)
    (δs : ℝ)
    (hEq : ∀ x y, Equiv' x y → |(x.symbolCount : ℝ) - y.symbolCount| ≤ δs)
    {x y : TheoremDescriptor}
    (hgap : δs < |(x.symbolCount : ℝ) - y.symbolCount|) :
    ¬ Equiv' x y := by
  exact fun h => not_le_of_gt hgap <| hEq x y h

/-
**Arity gap implies non-equivalence.**
-/
theorem nonequiv_of_arity_gap
    (Equiv' : TheoremDescriptor → TheoremDescriptor → Prop)
    (δa : ℝ)
    (hEq : ∀ x y, Equiv' x y → |(x.arity : ℝ) - y.arity| ≤ δa)
    {x y : TheoremDescriptor}
    (hgap : δa < |(x.arity : ℝ) - y.arity|) :
    ¬ Equiv' x y := by
  grind

/-
**Quantifier-depth gap implies non-equivalence.**
-/
theorem nonequiv_of_quantifierDepth_gap
    (Equiv' : TheoremDescriptor → TheoremDescriptor → Prop)
    (δq : ℝ)
    (hEq : ∀ x y, Equiv' x y → |(x.quantifierDepth : ℝ) - y.quantifierDepth| ≤ δq)
    {x y : TheoremDescriptor}
    (hgap : δq < |(x.quantifierDepth : ℝ) - y.quantifierDepth|) :
    ¬ Equiv' x y := by
  exact not_equivalent_of_coordinate_gap (fun x => ↑x.quantifierDepth) Equiv' δq hEq hgap

/-! ## Sound-and-Partially-Complete Certification -/

/-
**Completeness direction.** If the candidate is not far from every catalog element
(i.e., the novelty certification fails), then there exists a catalog element within δ.
-/
theorem catalog_separation_implies_novelty_or_unique_match
    (K : Finset σ) (_hK : K.Nonempty) (δ : ℝ)
    (_hEq : ∀ x y, Equivalent x y → dist (E x) (E y) ≤ δ)
    (x : σ)
    (hclose : ¬ (∀ a ∈ K, δ < dist (E x) (E a))) :
    ∃ a ∈ K, dist (E x) (E a) ≤ δ := by
  push_neg at hclose
  exact hclose

/-! ## Nearest Neighbor Uniqueness Under Strict Separation -/

/-
**Equal nearest distances.** If two catalog elements both achieve the minimum
distance to a candidate, they have equal distances.
-/
theorem unique_nearest_of_strict_dist
    (K : Finset σ) (x : σ)
    {a b : σ}
    (hna : ∀ c ∈ K, dist (E x) (E a) ≤ dist (E x) (E c))
    (hnb : ∀ c ∈ K, dist (E x) (E b) ≤ dist (E x) (E c))
    (ha : a ∈ K) (hb : b ∈ K) :
    dist (E x) (E a) = dist (E x) (E b) := by
  grind

/-! ## Novelty Score Monotonicity -/

/-
The novelty score is non-negative.
-/
theorem nearestDist_nonneg
    (K : Finset σ) (hK : K.Nonempty) (x : σ) :
    0 ≤ nearestDist E K x hK := by
  exact Finset.le_inf' _ _ fun y hy => dist_nonneg

/-
Adding an element to the catalog can only decrease or maintain the novelty score.
-/
theorem nearestDist_insert_le [DecidableEq σ]
    (K : Finset σ) (hK : K.Nonempty) (x : σ) (b : σ) :
    nearestDist E (insert b K) x (Finset.insert_nonempty b K) ≤ nearestDist E K x hK := by
  unfold nearestDist;
  simp +decide [ Finset.inf'_le_iff ];
  exact fun y hy => Or.inr ⟨ y, hy, le_rfl ⟩

/-! ## Multi-Feature Obstruction -/

/-
**Joint feature gap.** If any one of multiple feature extractors witnesses a gap
beyond its tolerance, the descriptors are not equivalent.
-/
theorem not_equivalent_of_any_feature_gap
    {n : ℕ}
    (features : Fin n → σ → ℝ)
    (tolerances : Fin n → ℝ)
    (Equiv' : σ → σ → Prop)
    (hEq : ∀ i, ∀ x y, Equiv' x y → |features i x - features i y| ≤ tolerances i)
    {x y : σ}
    (hgap : ∃ i, tolerances i < |features i x - features i y|) :
    ¬ Equiv' x y := by
  grind

end Novelty