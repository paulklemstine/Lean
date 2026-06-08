/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Non-Abelian Plünnecke-Ruzsa via Covering Calculus

This file develops a **covering-theoretic framework** for bounding iterated product
sets in groups, generalizing the classical Plünnecke-Ruzsa inequality from cardinality
bounds to covering number bounds.

## Central Idea

For a K-approximate subgroup H in a group G, the classical Plünnecke-Ruzsa inequality
gives |H^n| ≤ K^n · |H|. Our covering-theoretic analog replaces the cardinality bound
with a covering bound: H^n can be covered by at most K^(n-1) left translates of H.
This is sharper because it does not multiply by |H|.

## Main Definitions

* `SetPow` — The n-th iterated product set H^n
* `CanCoverBy` — Covering predicate: A can be covered by C left translates of B
* `IsKApproxSubgroupCov` — A finite symmetric set whose doubling is K-coverable
* `CoveringGrowthRate` — Whether cov(H^n, H) ≤ C

## Main Results

* `setPow_one_eq'` — H^1 = H
* `canCoverBy_self` — cov(H, H) ≤ 1
* `canCoverBy_compose` — Covering composition: bounds multiply
* `covering_inductive_step_comm` — Inductive covering bound (commutative)
* `setPow_cover_bound_comm` — cov(H^n, H) ≤ K^(n-1) (commutative, n ≥ 1)
* `covering_implies_card_bound` — Bridge to Plünnecke-Ruzsa
* `covering_entropy_bound` — Cross-domain: covering → entropy
* `canCoverBy_pos` — Nonempty sets need at least 1 translate
* `setPow_mono` — SetPow is monotone
* `setPow_increasing` — H^n ⊆ H^(n+1) when 1 ∈ H

## Catalog References

Builds on `Catalog/Pythagorean/BoundedPseudofiniteTransfer.lean`:
  - `CoversByLeftCosets`
  - `IsApproxSubgroupProxy`
  - `cosetCover_compose`
  - `bounded_cover_implies_product_cover`
-/

import Mathlib

open scoped Pointwise

/-! ## Section 1: Iterated Product Sets -/

/-- The **n-th iterated product set** H^n in a monoid.
  H^0 = {1}, H^(n+1) = H^n · H. -/
def SetPow {G : Type*} [Monoid G] (H : Set G) : ℕ → Set G
  | 0 => {1}
  | n + 1 => SetPow H n * H

@[simp]
theorem setPow_zero {G : Type*} [Monoid G] (H : Set G) :
    SetPow H 0 = {1} := rfl

@[simp]
theorem setPow_succ {G : Type*} [Monoid G] (H : Set G) (n : ℕ) :
    SetPow H (n + 1) = SetPow H n * H := rfl

/-- H^1 = H. -/
theorem setPow_one_eq' {G : Type*} [Group G] (H : Set G) :
    SetPow H 1 = H := by
  simp [SetPow]

/-! ## Section 2: Covering Predicate -/

/-- **Covering predicate**: A can be covered by at most C left translates of B.
    That is, there exists a set T with |T| ≤ C such that A ⊆ ⋃_{t ∈ T} t·B. -/
def CanCoverBy {G : Type*} [Group G] (A B : Set G) (C : ℕ) : Prop :=
  ∃ T : Finset G, T.card ≤ C ∧ A ⊆ ⋃ t ∈ (T : Set G), (fun x => t * x) '' B

/-! ## Section 3: Basic Properties of Covering -/

/-- Covering is monotone in the bound. -/
theorem canCoverBy_mono {G : Type*} [Group G] {A B : Set G} {C D : ℕ}
    (hCD : C ≤ D) (h : CanCoverBy A B C) : CanCoverBy A B D := by
  obtain ⟨T, hT, hcov⟩ := h
  exact ⟨T, le_trans hT hCD, hcov⟩

/-- Covering is monotone in the covered set (antitone in A). -/
theorem canCoverBy_mono_left {G : Type*} [Group G] {A₁ A₂ B : Set G} {C : ℕ}
    (hA : A₁ ⊆ A₂) (h : CanCoverBy A₂ B C) : CanCoverBy A₁ B C := by
  obtain ⟨T, hT, hcov⟩ := h
  exact ⟨T, hT, Set.Subset.trans hA hcov⟩

/-- The empty set is covered by 0 translates. -/
theorem canCoverBy_empty {G : Type*} [Group G] (B : Set G) :
    CanCoverBy ∅ B 0 :=
  ⟨∅, le_refl 0, Set.empty_subset _⟩

/-- Any nonempty set covers itself with 1 translate (using t = 1). -/
theorem canCoverBy_self {G : Type*} [Group G] (H : Set G) :
    CanCoverBy H H 1 := by
  refine ⟨{1}, ?_, ?_⟩
  · simp
  · intro x hx
    simp only [Finset.coe_singleton, Set.mem_iUnion, Set.mem_singleton_iff]
    exact ⟨1, rfl, x, hx, one_mul x⟩

/-- If A is nonempty and covered by C translates, then C ≥ 1. -/
theorem canCoverBy_pos {G : Type*} [Group G]
    {A B : Set G} {C : ℕ}
    (hne : A.Nonempty)
    (hcov : CanCoverBy A B C) :
    0 < C := by
  obtain ⟨T, hT, hcov⟩ := hcov
  obtain ⟨a, ha⟩ := hne
  have ha' := hcov ha
  simp only [Set.mem_iUnion, Set.mem_image, Finset.mem_coe] at ha'
  obtain ⟨t, ht, _, _, _⟩ := ha'
  exact Nat.lt_of_lt_of_le (Finset.card_pos.mpr ⟨t, ht⟩) hT

/-! ## Section 4: Covering Composition -/

/-
**Covering composition**: If A can be covered by C translates of H, and
    H can be covered by D translates of K, then A can be covered by C·D translates
    of K. This is the key multiplicativity property.
-/
theorem canCoverBy_compose {G : Type*} [Group G]
    (A H K : Set G) (C D : ℕ)
    (hAH : CanCoverBy A H C)
    (hHK : CanCoverBy H K D) :
    CanCoverBy A K (C * D) := by
  revert hAH hHK;
  intro hAh hHk;
  constructor;
  refine' ⟨ _, _ ⟩;
  convert Finset.card_image_le.trans ( Finset.card_product _ _ |> le_of_eq ) |> le_trans <| Nat.mul_le_mul ?_ ?_;
  exact fun p => p.1 * p.2;
  exact Classical.decEq G;
  exact hAh.choose;
  exact hHk.choose;
  · exact hAh.choose_spec.1;
  · exact hHk.choose_spec.1;
  · intro a ha;
    have := hAh.choose_spec.2 ha;
    simp +zetaDelta at *;
    obtain ⟨ i, hi, hi' ⟩ := this; have := hHk.choose_spec.2 hi'; simp_all +decide [ Set.mem_mul, mul_assoc ] ;
    grind

/-! ## Section 5: K-Approximate Subgroup (Covering Sense) -/

/-- A **K-approximate subgroup** in the covering sense: H is a nonempty symmetric
    finite subset whose product set H·H can be covered by K left translates of H. -/
structure IsKApproxSubgroupCov {G : Type*} [Group G] (H : Set G) (K : ℕ) : Prop where
  nonempty : H.Nonempty
  symmetric : ∀ h, h ∈ H → h⁻¹ ∈ H
  one_mem : (1 : G) ∈ H
  doubling_cover : CanCoverBy (H * H) H K

/-! ## Section 6: Structural Properties of SetPow -/

/-- SetPow is monotone: if A ⊆ B then SetPow A n ⊆ SetPow B n. -/
theorem setPow_mono {G : Type*} [Monoid G] {A B : Set G} (hAB : A ⊆ B) :
    ∀ n : ℕ, SetPow A n ⊆ SetPow B n := by
  intro n
  induction n with
  | zero => exact le_refl _
  | succ n ih =>
    simp only [SetPow]
    exact Set.mul_subset_mul ih hAB

/-- SetPow with 1 ∈ H is increasing: H^n ⊆ H^(n+1). -/
theorem setPow_increasing {G : Type*} [Group G] {H : Set G}
    (h1 : (1 : G) ∈ H) :
    ∀ n : ℕ, SetPow H n ⊆ SetPow H (n + 1) := by
  intro n x hx
  simp only [SetPow]
  exact ⟨x, hx, 1, h1, mul_one x⟩

/-- SetPow 2 equals H * H. -/
theorem setPow_two {G : Type*} [Group G] (H : Set G) :
    SetPow H 2 = H * H := by
  show SetPow H 1 * H = H * H
  rw [setPow_one_eq']

/-! ## Section 7: Commutative Inductive Covering Step -/

/-
**Inductive covering step (commutative groups)**: If SetPow H (n+1) can be
    covered by C translates of H, and H·H can be covered by K translates of H,
    then SetPow H (n+2) can be covered by C·K translates of H.
-/
theorem covering_inductive_step_comm {G : Type*} [CommGroup G]
    (H : Set G) (n C K : ℕ)
    (hcov_n : CanCoverBy (SetPow H (n + 1)) H C)
    (hHH : CanCoverBy (H * H) H K) :
    CanCoverBy (SetPow H (n + 2)) H (C * K) := by
  revert hcov_n hHH;
  -- Assume we have $C$ left translates of $H$ for $SetPow H {n+1}$.
  intro hcov_n hHH
  obtain ⟨T, hT_card, hT_cover⟩ := hcov_n;
  -- By definition of $SetPow$, we have $SetPow H (n + 2) = (SetPow H (n + 1)) * H$.
  have h_setPow_succ : SetPow H (n + 2) = (SetPow H (n + 1)) * H := by
    rfl;
  -- Since $(SetPow H (n + 1)) * H$ is covered by $C$ left translates of $H * H$, we can use the composition lemma.
  have h_cover : CanCoverBy ((SetPow H (n + 1)) * H) (H * H) C := by
    refine' ⟨ T, hT_card, _ ⟩;
    simp_all +decide [ Set.subset_def, Set.mem_mul ];
    grind +splitImp;
  exact canCoverBy_compose (SetPow H (n + 2)) (H * H) H C K h_cover hHH

/-
**Main theorem (commutative case)**: For a K-approximate subgroup H in a
    commutative group, SetPow H (n+1) can be covered by K^n left translates of H.
-/
theorem setPow_cover_bound_comm {G : Type*} [CommGroup G]
    (H : Set G) (K : ℕ) (hH : IsKApproxSubgroupCov H K)
    (n : ℕ) :
    CanCoverBy (SetPow H (n + 1)) H (K ^ n) := by
  induction' n with n ih;
  · simpa [ setPow_one_eq' ] using canCoverBy_self H;
  · convert covering_inductive_step_comm H n ( K ^ n ) K ih hH.doubling_cover using 1

/-! ## Section 8: Covering-to-Cardinality Bridge -/

/-
**Cardinality bound from covering**: If A can be covered by C translates of B,
    and both are finite, then |A| ≤ C · |B|. This connects the covering calculus
    to the classical Plünnecke-Ruzsa cardinality inequality.
-/
theorem covering_implies_card_bound {G : Type*} [Group G] [DecidableEq G]
    (A B : Set G) (C : ℕ)
    (hA : A.Finite) (hB : B.Finite)
    (hcov : CanCoverBy A B C) :
    hA.toFinset.card ≤ C * hB.toFinset.card := by
  obtain ⟨ T, hTC, hT ⟩ := hcov;
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact Finset.biUnion T ( fun t => Finset.image ( fun x => t * x ) hB.toFinset );
  · intro x hx; specialize hT ( hA.mem_toFinset.mp hx ) ; aesop;
  · exact le_trans ( Finset.card_biUnion_le ) ( le_trans ( Finset.sum_le_sum fun _ _ => Finset.card_image_le ) ( by simpa using Nat.mul_le_mul_right _ hTC ) )

/-! ## Section 9: Cross-Domain Connection — Covering and Entropy -/

/-
**Cross-domain connection (Information Theory / Additive Combinatorics)**:
    The logarithm of the covering number serves as an entropy analog.
    log(K^(n-1)) = (n-1)·log(K), showing linear growth of covering entropy.
-/
theorem covering_entropy_bound (K : ℕ) (n : ℕ) (_hK : 1 ≤ K) (hn : 1 ≤ n) :
    Real.log ((K : ℝ) ^ (n - 1)) = ((n : ℝ) - 1) * Real.log (K : ℝ) := by
  cases n <;> aesop

/-! ## Section 10: Falsifiable Conjecture -/

/-- **Non-Abelian Covering Conjecture (Sharp)**: For any K-approximate
    subgroup H in a group G, SetPow H (n+1) can be covered by K^n
    left translates of H, for all n.

    **Test**: Verify computationally in S₃, S₄, GL(2,F₃) for n = 4,5,6.
    **Falsification**: Find G, H, K, n with cov(H^n, H) > K^(n-1). -/
def NonAbelianCoveringConjecture : Prop :=
  ∀ (G : Type*) [Group G] (H : Set G) (K : ℕ),
    IsKApproxSubgroupCov H K →
    ∀ n : ℕ, CanCoverBy (SetPow H (n + 1)) H (K ^ n)