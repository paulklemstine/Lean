/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Pseudofinite Dimension and Stabilizer Rank Bounds

This file defines pseudofinite dimension for families of finite sets in
ultraproducts of finite groups, and proves its key properties:
invariance under a.e. equal cardinality, a finite coset cover cardinality
bound, and pointwise log-cardinality bounds.

## Main Results

* `pseudofiniteDim`: The pseudofinite dimension of a family of sets
* `pseudofiniteDim_congr`: Dimension is invariant under a.e. equal cardinality
* `cosetCover_card_bound`: If A is covered by C left cosets of H, then |A| ≤ C * |H|
* `normalizedLogCard_coset_bound`: Pointwise log-cardinality bound from coset covers
* `normalizedLogCard_mono`: Monotonicity of normalized log-cardinality
* `normalizedLogCard_nonneg`: Non-negativity of normalized log-cardinality
* `normalizedLogCard_le_one`: Upper bound of normalized log-cardinality
* `normalizedLogCard_univ`: Full group has dimension 1
* `normalizedLogCard_singleton`: Singletons have dimension 0
* `card_prod_eq`: Cardinality of product equals product of cardinalities
* `log_card_prod`: Log-additivity on products

## References

* Hrushovski, E. (2012). Stable group theory and approximate subgroups.
* Breuillard, E., Green, B., Tao, T. (2012). The structure of approximate groups.
-/

import Mathlib

namespace PseudofiniteDimension

open Filter Set Real Finset Pointwise

/-! ## Coset Cover Infrastructure

We reproduce the coset cover definition and key lemma from the catalog,
so that this file is self-contained. -/

/-- A set `A` is covered by at most `C` left cosets of `H`. -/
def CoversByLeftCosets {G : Type*} [Mul G] (A H : Set G) (C : ℕ) : Prop :=
  ∃ T : Finset G, T.card ≤ C ∧ A ⊆ ⋃ t ∈ (T : Set G), (fun x => t * x) '' H

/-! ## Section 1: Normalized Log-Cardinality -/

/-- The normalized log-cardinality of a subset A of a finite type G,
    defined as log|A| / log|G|. This is the pointwise building block
    for pseudofinite dimension. -/
noncomputable def normalizedLogCard (G : Type*) [Fintype G] (A : Set G) : ℝ :=
  Real.log (Nat.card A) / Real.log (Nat.card G)

/-- Normalized log-cardinality agrees on sets of equal cardinality. -/
theorem normalizedLogCard_eq_of_card_eq {G : Type*} [Fintype G]
    {A B : Set G} (h : Nat.card A = Nat.card B) :
    normalizedLogCard G A = normalizedLogCard G B := by
  simp [normalizedLogCard, h]

/-! ## Section 2: Pseudofinite Dimension -/

/-- The pseudofinite dimension of a family of definable sets in an ultraproduct
    of finite groups. Defined as the ultralimit of normalized log-cardinalities.
    When the groups G_i are finite and A_i ⊆ G_i, this captures the
    "asymptotic proportion" of A in G along the ultrafilter. -/
noncomputable def pseudofiniteDim
    {ι : Type*} (U : Ultrafilter ι)
    {G : ι → Type*} [∀ i, Fintype (G i)]
    (A : ∀ i, Set (G i)) : ℝ :=
  limUnder (U : Filter ι) (fun i => normalizedLogCard (G i) (A i))

/-! ## Section 3: Dimension Invariance -/

/-
**Dimension Invariance**: Pseudofinite dimension depends only on the
    cardinalities of the sets, not on their specific elements.
    If two families of sets have equal cardinalities U-almost everywhere,
    they have the same pseudofinite dimension.
-/
theorem pseudofiniteDim_congr
    {ι : Type*} {U : Ultrafilter ι}
    {G : ι → Type*} [∀ i, Fintype (G i)]
    {A B : ∀ i, Set (G i)}
    (h : ∀ᶠ i in (U : Filter ι), Nat.card (A i) = Nat.card (B i)) :
    pseudofiniteDim U A = pseudofiniteDim U B := by
  refine' Filter.Tendsto.limUnder_eq _;
  convert Filter.Tendsto.congr' _ ( show Filter.Tendsto ( fun i => normalizedLogCard ( G i ) ( B i ) ) U ( nhds ( pseudofiniteDim U B ) ) from ?_ ) using 1;
  · filter_upwards [ h ] with i hi using normalizedLogCard_eq_of_card_eq hi.symm;
  · unfold pseudofiniteDim;
    have h_bounded : ∀ i, abs (normalizedLogCard (G i) (B i)) ≤ 1 := by
      intro i
      unfold normalizedLogCard
      simp [abs_div];
      refine' div_le_one_of_le₀ _ ( abs_nonneg _ );
      by_cases hi : ( B i ).ncard = 0 <;> simp_all +decide [ Set.ncard_eq_toFinset_card' ];
      rw [ abs_of_nonneg ( Real.log_nonneg ( mod_cast Nat.one_le_iff_ne_zero.mpr hi ) ), abs_of_nonneg ( Real.log_nonneg ( mod_cast Fintype.card_pos_iff.mpr ⟨ Classical.choose ( Set.nonempty_of_ncard_ne_zero hi ) ⟩ ) ) ] ; exact Real.log_le_log ( mod_cast Nat.one_le_iff_ne_zero.mpr hi ) ( mod_cast Set.ncard_le_ncard ( Set.subset_univ _ ) |> le_trans <| by simp +decide [ Set.ncard_univ ] ) ;
    have h_compact : IsCompact (Set.Icc (-1 : ℝ) 1) := by
      exact CompactIccSpace.isCompact_Icc;
    have := h_compact.ultrafilter_le_nhds ( U.map ( fun i => normalizedLogCard ( G i ) ( B i ) ) ) ?_;
    · obtain ⟨ x, hx₁, hx₂ ⟩ := this;
      convert hx₂ using 1;
      rw [ Filter.Tendsto.limUnder_eq ];
      convert hx₂ using 1;
    · exact Filter.le_principal_iff.mpr ( Filter.mem_map.mpr ( Filter.Eventually.of_forall fun i => ⟨ neg_le_of_abs_le ( h_bounded i ), le_of_abs_le ( h_bounded i ) ⟩ ) )

/-! ## Section 4: Finite Coset Cover Cardinality Bound -/

/-
In a group, left multiplication by a fixed element is injective.
-/
theorem mul_left_injective_group {G : Type*} [Group G] (t : G) :
    Function.Injective (fun x => t * x : G → G) := by
  exact mul_right_injective t

/-
The cardinality of a left translate tH equals the cardinality of H.
-/
theorem card_left_coset_eq {G : Type*} [Group G]
    (t : G) (H : Set G) :
    Nat.card ((fun x => t * x) '' H) = Nat.card H := by
  rw [ Nat.card_image_of_injective ];
  exact mul_left_injective_group t

/-
**Coset Cover Cardinality Bound**: If a set A in a finite group is
    covered by at most C left cosets of H, then |A| ≤ C · |H|.
    This is the fundamental finite combinatorial inequality underlying
    the pseudofinite dimension coset cover bound.
-/
theorem cosetCover_card_bound {G : Type*} [Group G] [Fintype G]
    {A H : Set G} {C : ℕ}
    (hcov : CoversByLeftCosets A H C) :
    Nat.card A ≤ C * Nat.card H := by
  obtain ⟨ T, hT₁, hT₂ ⟩ := hcov;
  have h_card_union : (Nat.card (⋃ t ∈ T, (fun x => t * x) '' H)) ≤ T.card * Nat.card H := by
    have h_card_union : ∀ t ∈ T, Nat.card ((fun x => t * x) '' H) = Nat.card H := by
      intro t ht; rw [ Nat.card_image_of_injective ] ; aesop_cat;
    have h_card_union : (Nat.card (⋃ t ∈ T, (fun x => t * x) '' H)) ≤ ∑ t ∈ T, Nat.card ((fun x => t * x) '' H) := by
      simp +zetaDelta at *;
      exact?;
    exact h_card_union.trans ( by rw [ Finset.sum_congr rfl ‹_› ] ; simp +decide );
  exact le_trans ( Set.ncard_le_ncard hT₂ ) ( h_card_union.trans ( Nat.mul_le_mul_right _ hT₁ ) )

/-! ## Section 5: Normalized Log-Cardinality Coset Bound -/

/-
**Log-Cardinality Coset Bound**: If A is covered by C left cosets of H
    in a finite group with |G| ≥ 2, then
    log|A| / log|G| ≤ log|H| / log|G| + log C / log|G|.
    This is the pointwise version of the pseudofinite dimension coset bound.
-/
theorem normalizedLogCard_coset_bound {G : Type*} [Group G] [Fintype G]
    {A H : Set G} {C : ℕ}
    (hG : 2 ≤ Nat.card G)
    (hA : 0 < Nat.card A)
    (hcov : CoversByLeftCosets A H C) :
    normalizedLogCard G A ≤ normalizedLogCard G H + Real.log C / Real.log (Nat.card G) := by
  have h_log_card : Real.log (Nat.card A) ≤ Real.log (Nat.card H) + Real.log C := by
    rcases C with ( _ | C ) <;> simp_all +decide;
    · obtain ⟨ T, hT₁, hT₂ ⟩ := hcov; simp_all +decide [ Set.subset_def ] ;
      exact absurd hA ( by rw [ show A = ∅ by ext; aesop ] ; simp +decide );
    · have h_log_card : Real.log (Nat.card A) ≤ Real.log ((C + 1) * Nat.card H) := by
        gcongr;
        exact_mod_cast cosetCover_card_bound hcov;
      by_cases hH : Nat.card H = 0 <;> simp_all +decide [ add_comm ];
      · exact h_log_card.trans ( Real.log_nonneg ( by linarith ) );
      · rwa [ Real.log_mul ( by positivity ) ( by positivity ) ] at h_log_card;
  unfold normalizedLogCard;
  rw [ ← add_div ] ; gcongr

/-! ## Section 6: Subset Monotonicity -/

/-
**Subset Monotonicity of Normalized Log-Cardinality**:
    If A ⊆ B then log|A| / log|G| ≤ log|B| / log|G|.
-/
theorem normalizedLogCard_mono {G : Type*} [Fintype G]
    {A B : Set G} (h : A ⊆ B) (hG : 2 ≤ Nat.card G) :
    normalizedLogCard G A ≤ normalizedLogCard G B := by
  by_cases hA : A.Nonempty <;> by_cases hB : B.Nonempty <;> simp_all +decide [ normalizedLogCard ];
  · gcongr;
    · exact Nat.cast_pos.mpr ( by rw [ Set.ncard_eq_toFinset_card _ ] ; exact Finset.card_pos.mpr ⟨ hA.some, by simpa using hA.choose_spec ⟩ );
    · exact Set.toFinite B;
  · exact False.elim ( hB <| hA.mono h );
  · simp_all +decide [ Set.not_nonempty_iff_eq_empty.mp hA ];
    exact div_nonneg ( Real.log_nonneg ( mod_cast hB.ncard_pos ) ) ( Real.log_nonneg ( mod_cast hG.trans' ( by decide ) ) );
  · simp_all +decide [ Set.not_nonempty_iff_eq_empty.mp hA, Set.not_nonempty_iff_eq_empty.mp hB ]

/-! ## Section 7: Normalized Log-Cardinality of Full Group and Singletons -/

/-
The normalized log-cardinality of the full group is 1.
-/
theorem normalizedLogCard_univ {G : Type*} [Fintype G] (hG : 2 ≤ Nat.card G) :
    normalizedLogCard G Set.univ = 1 := by
  unfold normalizedLogCard;
  rw [ div_eq_iff ] <;> norm_num;
  exact ⟨ by linarith [ show Fintype.card G ≥ 2 by simpa using hG ], by linarith [ show Fintype.card G ≥ 2 by simpa using hG ], by linarith ⟩

/-
The normalized log-cardinality of a singleton is 0 when |G| ≥ 2.
-/
theorem normalizedLogCard_singleton {G : Type*} [Fintype G]
    (hG : 2 ≤ Nat.card G) (g : G) :
    normalizedLogCard G {g} = 0 := by
  -- Since $g \in G$, we have $\text{Nat.card} \{g\} = 1$.
  simp [normalizedLogCard]

/-! ## Section 8: Product Cardinality -/

/-
The cardinality of a product set equals the product of cardinalities.
-/
theorem card_prod_eq {α β : Type*} (A : Set α) (B : Set β) :
    Nat.card (A ×ˢ B) = Nat.card A * Nat.card B := by
  rw [ ← Nat.card_prod ];
  fapply Nat.card_congr;
  exact ⟨ fun x => ⟨ ⟨ x.val.1, x.prop.1 ⟩, ⟨ x.val.2, x.prop.2 ⟩ ⟩, fun x => ⟨ ⟨ x.1.val, x.2.val ⟩, x.1.prop, x.2.prop ⟩, fun x => rfl, fun x => rfl ⟩

/-
**Log-Additivity on Products**: For product sets A × B,
    the log-cardinality satisfies log|A × B| = log|A| + log|B|.
-/
theorem log_card_prod {α β : Type*} (A : Set α) (B : Set β)
    (hA : 0 < Nat.card A) (hB : 0 < Nat.card B) :
    Real.log (Nat.card (A ×ˢ B) : ℝ) =
    Real.log (Nat.card A : ℝ) + Real.log (Nat.card B : ℝ) := by
  convert Real.log_mul ?_ ?_ <;> aesop

/-! ## Section 9: Dimension Bounds -/

/-
The normalized log-cardinality is non-negative when |A| ≥ 1 and |G| ≥ 2.
-/
theorem normalizedLogCard_nonneg {G : Type*} [Fintype G]
    {A : Set G} (hA : 0 < Nat.card A) (hG : 2 ≤ Nat.card G) :
    0 ≤ normalizedLogCard G A := by
  apply div_nonneg; apply Real.log_nonneg; exact_mod_cast hA; apply Real.log_nonneg; exact_mod_cast hG.trans' (by norm_num)

/-
The normalized log-cardinality is at most 1 when |G| ≥ 2.
-/
theorem normalizedLogCard_le_one {G : Type*} [Fintype G]
    {A : Set G} (hG : 2 ≤ Nat.card G) :
    normalizedLogCard G A ≤ 1 := by
  refine' div_le_one_of_le₀ _ ( Real.log_nonneg <| mod_cast hG.trans' ( by decide ) );
  -- Since $A$ is a subset of $G$, we have $|A| \leq |G|$.
  have h_card_le : Nat.card A ≤ Nat.card G := by
    exact Set.ncard_le_ncard ( Set.subset_univ _ ) |> le_trans <| by simp +decide ;
  by_cases hA : Nat.card A = 0 <;> simp_all +decide;
  · exact Real.log_nonneg ( mod_cast hG.trans' ( by decide ) );
  · exact Real.log_le_log ( Nat.cast_pos.mpr ( Nat.pos_of_ne_zero hA ) ) ( Nat.cast_le.mpr h_card_le )

end PseudofiniteDimension