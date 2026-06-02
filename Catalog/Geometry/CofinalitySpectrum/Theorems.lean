/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Geometry.CofinalitySpectrum.Defs

/-!
# Cofinality Spectrum: Main Theorems

This file contains the main results of the cofinality spectrum theory:

1. **Bound Lemma**: Countable subsets below a wild point have strict upper bounds.
2. **P-Filter Theorem**: Fully wild points have the P-filter property.
3. **Tame–First-Countable Equivalence**: A point is tame iff its neighborhood
   filter is countably generated.
4. **Real Numbers are Tame**: Every real number is a tame point.

## Key Insight

Uncountable cofinality is not merely a "pathology" — it is a single, precisely
characterizable obstruction that *controls* all topological behavior. The P-filter
property shows that wild points have *stronger* convergence properties:
countable intersections of neighborhoods remain neighborhoods.
-/

namespace CofinalitySpectrum

open Set Filter Topology Classical

variable {α : Type*} [LinearOrder α] [TopologicalSpace α] [OrderTopology α]

/-! ### The Bound Lemma -/

/-- **Bound Lemma (Left)**: If `x` has uncountable left cofinality and `s` is
a countable subset of `Iio x`, then there exists `y < x` strictly above all
elements of `s`. Countably many approach attempts cannot exhaust an
uncountably-indexed approach direction. -/
theorem exists_strict_upper_bound_of_uncountable_left_cof {x : α}
    (hx : ¬HasCountableLeftCof x) (s : Set α) (hs : s.Countable) (hsub : s ⊆ Iio x) :
    ∃ y, y < x ∧ ∀ z ∈ s, z < y := by
  by_contra! h
  exact hx <| Or.inr ⟨s, hs, ⟨hsub, h⟩⟩

/-- **Bound Lemma (Right)**: Symmetric version for right cofinality. -/
theorem exists_strict_lower_bound_of_uncountable_right_cof {x : α}
    (hx : ¬HasCountableRightCof x) (s : Set α) (hs : s.Countable) (hsub : s ⊆ Ioi x) :
    ∃ y, x < y ∧ ∀ z ∈ s, y < z := by
  by_contra! h
  exact hx <| Or.inr ⟨s, hs, ⟨hsub, h⟩⟩

/-! ### The P-Filter Theorem -/

/-- **P-Filter Theorem**: Points with uncountable cofinality from both sides
have the P-filter property — countable intersections of neighborhoods remain
neighborhoods. This is the deepest result: wild points have *stronger*
convergence, not weaker. -/
theorem fully_wild_has_p_filter {x : α}
    (hleft : ¬HasCountableLeftCof x) (hright : ¬HasCountableRightCof x) :
    HasPFilterProperty x := by
  intro f hf
  -- Extract elements below and above x (exist since cofinality is uncountable)
  obtain ⟨a, ha⟩ : ∃ a, a < x := by
    by_contra h; push_neg at h; exact hleft (Or.inl h)
  obtain ⟨b, hb⟩ : ∃ b, x < b := by
    by_contra h; push_neg at h; exact hright (Or.inl h)
  -- Each f n contains an Ioo interval around x (by the order topology basis)
  have hbasis := nhds_basis_Ioo' ⟨a, ha⟩ ⟨b, hb⟩
  have h_int : ∀ n, ∃ a_n b_n : α, a_n < x ∧ x < b_n ∧ Ioo a_n b_n ⊆ f n := by
    intro n
    obtain ⟨⟨a_n, b_n⟩, ⟨ha_n, hb_n⟩, hsub⟩ := hbasis.mem_iff.mp (hf n)
    exact ⟨a_n, b_n, ha_n, hb_n, hsub⟩
  choose a_n b_n ha_n hb_n hsub using h_int
  -- By the Bound Lemma, the left endpoints have a strict upper bound below x
  obtain ⟨y, hy_lt, hy_bound⟩ := exists_strict_upper_bound_of_uncountable_left_cof
    hleft (range a_n) (countable_range _) (range_subset_iff.mpr ha_n)
  -- Similarly, right endpoints have a strict lower bound above x
  obtain ⟨w, hw_lt, hw_bound⟩ := exists_strict_lower_bound_of_uncountable_right_cof
    hright (range b_n) (countable_range _) (range_subset_iff.mpr hb_n)
  -- The interval (y, w) is contained in all f n
  have h_inter : Ioo y w ⊆ ⋂ n, f n :=
    subset_iInter fun n => (Ioo_subset_Ioo (le_of_lt (hy_bound (a_n n) (mem_range_self _)))
      (le_of_lt (hw_bound (b_n n) (mem_range_self _)))).trans (hsub n)
  exact mem_of_superset (Ioo_mem_nhds hy_lt hw_lt) h_inter

/-! ### Tame ↔ First-Countable Equivalence -/

/-
A tame point has a countably generated neighborhood filter.
-/
theorem nhds_countably_generated_of_tame {x : α} (hx : IsTame x) :
    (𝓝 x).IsCountablyGenerated := by
  -- Decompose the neighborhood filter into the infimum of left and right parts.
  have h_decomp : (𝓝 x) = (⨅ a ∈ Iio x, Filter.principal (Set.Ioi a)) ⊓ (⨅ b ∈ Ioi x, Filter.principal (Set.Iio b)) := by
    convert nhds_eq_order x;
  -- Show that the left and right parts are countably generated.
  have h_left : (⨅ a ∈ Iio x, Filter.principal (Set.Ioi a)).IsCountablyGenerated := by
    rcases hx.1 with ( hx | ⟨ s, hs, hs' ⟩ );
    · simp_all +decide [ IsBot ];
      infer_instance;
    · refine' ⟨ _, _, _ ⟩;
      exact { Ioi a | a ∈ s };
      · exact hs.image _;
      · refine' le_antisymm _ _;
        · simp +decide [ Filter.le_generate_iff ];
          rintro _ ⟨ a, ha, rfl ⟩;
          exact Filter.mem_iInf_of_mem a ( Filter.mem_iInf_of_mem ( hs'.1 ha ) ( Filter.mem_principal_self _ ) );
        · simp +decide [ Filter.le_def, Filter.mem_iInf ];
          intro i hi x hx;
          rcases hs' with ⟨ hs₁, hs₂ ⟩;
          rcases hs₂ i hi with ⟨ z, hz₁, hz₂ ⟩;
          exact Filter.mem_of_superset ( Filter.mem_generate_of_mem ⟨ z, hz₁, rfl ⟩ ) ( fun y hy => hx <| lt_of_le_of_lt hz₂ hy )
  have h_right : (⨅ b ∈ Ioi x, Filter.principal (Set.Iio b)).IsCountablyGenerated := by
    obtain ⟨s, hs_countable, hs⟩ : ∃ s : Set α, s.Countable ∧ s ⊆ Ioi x ∧ ∀ y, x < y → ∃ z ∈ s, z ≤ y := by
      rcases hx.2 with ( hx | ⟨ s, hs_countable, hs ⟩ );
      · exact ⟨ ∅, Set.countable_empty, Set.empty_subset _, fun y hy => False.elim <| hy.not_ge <| hx y ⟩;
      · exact ⟨ s, hs_countable, hs.1, hs.2 ⟩;
    refine' ⟨ _, _, _ ⟩;
    exact Set.image ( fun z => Set.Iio z ) s;
    · exact hs_countable.image _;
    · refine' le_antisymm _ _;
      · simp +decide [ Filter.le_generate_iff ];
        intro z hz;
        exact Filter.mem_iInf_of_mem z ( Filter.mem_iInf_of_mem ( hs.1 hz ) ( Filter.mem_principal_self _ ) );
      · simp +decide [ Filter.le_def, Filter.mem_iInf ];
        intro y hy x hx; rcases hs.2 y hy with ⟨ z, hz, hz' ⟩ ; exact Filter.mem_of_superset ( Filter.mem_generate_of_mem ( Set.mem_image_of_mem _ hz ) ) ( Set.Subset.trans ( Set.Iio_subset_Iio hz' ) hx ) ;
  rw [h_decomp];
  grind +suggestions

/-
If nhds is countably generated, x has countable left cofinality.
Uses `exists_Ioc_subset_of_mem_nhds` to extract interval endpoints from
the antitone basis, yielding a countable cofinal set.
-/
theorem hasCountableLeftCof_of_nhds_countably_generated {x : α}
    (hcg : (𝓝 x).IsCountablyGenerated) : HasCountableLeftCof x := by
  obtain ⟨V, hV⟩ : ∃ V : ℕ → Set α, (∀ n, V n ∈ 𝓝 x) ∧ (∀ y ∈ Iio x, ∃ n, V n ⊆ Ioi y) := by
    have := Filter.exists_antitone_basis ( 𝓝 x );
    obtain ⟨ V, hV ⟩ := this;
    exact ⟨ V, fun n => hV.mem n, fun y hy => hV.mem_iff.mp ( Ioi_mem_nhds hy ) ⟩;
  by_cases hx : ∃ a₀, a₀ < x <;> simp_all +decide [ IsBot ];
  · choose l hl using fun n => exists_Ioc_subset_of_mem_nhds ( hV.1 n ) hx;
    refine' Or.inr ⟨ Set.range l, Set.countable_range l, _, _ ⟩;
    · exact Set.range_subset_iff.mpr fun n => hl n |>.1;
    · intro y hy
      obtain ⟨n, hn⟩ := hV.2 y hy
      use l n
      simp [hn];
      contrapose! hn;
      exact Set.not_subset.2 ⟨ y, hl n |>.2 ⟨ hn, hy.le ⟩, by simp +decide ⟩;
  · exact Or.inl hx

/-
If nhds is countably generated, x has countable right cofinality.
Follows from the left version by order duality.
-/
theorem hasCountableRightCof_of_nhds_countably_generated {x : α}
    (hcg : (𝓝 x).IsCountablyGenerated) : HasCountableRightCof x := by
  have h_dual : HasCountableLeftCof (OrderDual.toDual x) := by
    convert hasCountableLeftCof_of_nhds_countably_generated ( show ( 𝓝 ( OrderDual.toDual x ) ).IsCountablyGenerated from ?_ );
    convert hcg;
  unfold HasCountableLeftCof at h_dual; unfold HasCountableRightCof; aesop;

/-- If the neighborhood filter at `x` is countably generated, then `x` is tame. -/
theorem tame_of_nhds_countably_generated {x : α}
    (hx : (𝓝 x).IsCountablyGenerated) : IsTame x :=
  ⟨hasCountableLeftCof_of_nhds_countably_generated hx,
   hasCountableRightCof_of_nhds_countably_generated hx⟩

/-- **Main Equivalence**: A point in a linearly ordered topological space is tame
if and only if its neighborhood filter is countably generated. -/
theorem tame_iff_nhds_countably_generated (x : α) :
    IsTame x ↔ (𝓝 x).IsCountablyGenerated :=
  ⟨nhds_countably_generated_of_tame, tame_of_nhds_countably_generated⟩

/-! ### Example: All Real Numbers are Tame -/

/-- Every real number has countable left cofinality, witnessed by `x - 1/(n+1)`. -/
theorem real_has_countable_left_cof (x : ℝ) :
    @HasCountableLeftCof ℝ _ x := by
  refine Or.inr ⟨range (fun n : ℕ => x - 1 / (↑n + 1)), countable_range _, ?_⟩
  refine ⟨?_, ?_⟩
  · exact range_subset_iff.mpr fun n => by norm_num; linarith
  · exact fun y hy => by
      rcases exists_nat_one_div_lt (sub_pos.mpr hy) with ⟨n, hn⟩
      exact ⟨_, ⟨n, rfl⟩, by norm_num at *; linarith⟩

/-- Every real number has countable right cofinality, witnessed by `x + 1/(n+1)`. -/
theorem real_has_countable_right_cof (x : ℝ) :
    @HasCountableRightCof ℝ _ x := by
  refine Or.inr ⟨range (fun n : ℕ => x + 1 / (↑n + 1)), countable_range _, ?_⟩
  constructor
  · exact range_subset_iff.mpr fun n =>
      show x < x + 1 / ((n : ℝ) + 1) by linarith [show (0 : ℝ) < 1 / ((n : ℝ) + 1) from by positivity]
  · exact fun y hy => by
      rcases exists_nat_one_div_lt (sub_pos.mpr hy) with ⟨n, hn⟩
      exact ⟨_, ⟨n, rfl⟩, by norm_num at *; linarith⟩

/-- **All Reals are Tame**: Every real number is a tame point. -/
theorem real_all_tame (x : ℝ) : @IsTame ℝ _ x :=
  ⟨real_has_countable_left_cof x, real_has_countable_right_cof x⟩

end CofinalitySpectrum