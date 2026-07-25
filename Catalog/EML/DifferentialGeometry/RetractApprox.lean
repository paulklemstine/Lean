import Mathlib

/-!
# EML Stone–Weierstrass for Neighborhood Retract Codomains

This file proves that if a class of continuous maps `X → ℝⁿ` is dense
(in the uniform/sup-norm sense) among all continuous maps, then it also
suffices to uniformly approximate continuous maps into any compact
neighborhood retract `S ⊆ ℝⁿ`.

The key idea: approximate the Euclidean-embedded map, then retract back.
Compactness supplies the uniform tubular margin that keeps the approximant
inside the retraction domain, and uniform continuity of the retraction on
the compact image controls the final error.

## Main results

* `compact_subset_open_has_uniform_nhds` – a compact set inside an open set
  has a positive uniform thickening margin.
* `retract_near_compact_uniform` – a continuous retraction is uniformly
  controlled near a compact subset of its fixed-point set.
* `eml_uniform_approx_subtype_of_neighborhoodRetract` – the main
  approximation theorem for neighborhood-retract codomains.
-/

open Set Metric Filter Topology

noncomputable section

/-! ## Topological preliminaries -/

/-- A compact subset of an open set in Euclidean space has a positive uniform
thickening that stays inside the open set. -/
theorem compact_subset_open_has_uniform_nhds
    {n : ℕ} {K U : Set (Fin n → ℝ)}
    (hK : IsCompact K) (hU : IsOpen U) (hKU : K ⊆ U) :
    ∃ δ > 0, ∀ z, (∃ y ∈ K, ‖z - y‖ < δ) → z ∈ U := by
  obtain ⟨δ, hδ, h⟩ := IsCompact.exists_thickening_subset_open hK hU hKU
  exact ⟨δ, hδ, fun z hz => h <| Metric.mem_thickening_iff.2 hz⟩

/-- The range of a continuous map from a compact space into a subtype of
Euclidean space, viewed in the ambient space, is compact. -/
theorem isCompact_range_coe_of_continuous
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ} {S : Set (Fin n → ℝ)}
    (f : C(X, S)) :
    IsCompact (range (fun x => (f x : Fin n → ℝ))) :=
  isCompact_range f.continuous.subtype_val

/-- A continuous retraction on a subtype, when applied near a compact
subset of the fixed-point set, is uniformly controlled: for every `ε > 0`
there exists `δ > 0` such that if `y ∈ K ⊆ S` and `‖z - y‖ < δ` (with
`z ∈ U`), then `‖r(z) - y‖ < ε`. Here `r` fixes points of `S`. -/
theorem retract_near_compact_uniform
    {n : ℕ}
    {S U : Set (Fin n → ℝ)}
    (hSU : S ⊆ U)
    {K : Set (Fin n → ℝ)}
    (hK : IsCompact K) (hKS : K ⊆ S)
    (r : U → S)
    (hr_cont : Continuous r)
    (hr_fix : ∀ s : S, r ⟨s.1, hSU s.2⟩ = s) :
    ∀ ε > 0, ∃ δ > 0, ∀ y, y ∈ K →
      ∀ z : U, ‖(z : Fin n → ℝ) - y‖ < δ →
        ‖(r z : Fin n → ℝ) - y‖ < ε := by
  intro ε hε
  by_contra h_contra
  have h_neg : ∀ δ > 0, ∃ y ∈ K, ∃ z : U, ‖z.val - y‖ < δ ∧ ‖(r z).val - y‖ ≥ ε := by
    grind
  obtain ⟨y_seq, z_seq, hy_seq, hz_seq, hr_seq⟩ :
      ∃ y_seq : ℕ → (Fin n → ℝ), (∀ k, y_seq k ∈ K) ∧
      ∃ z_seq : ℕ → U, (∀ k, ‖z_seq k - y_seq k‖ < 1 / (k + 1)) ∧
        (∀ k, ‖(r (z_seq k)).val - y_seq k‖ ≥ ε) := by
    exact ⟨fun k => Classical.choose (h_neg (1 / (k + 1)) (by positivity)),
      fun k => Classical.choose_spec (h_neg (1 / (k + 1)) (by positivity)) |>.1,
      fun k => Classical.choose_spec (h_neg (1 / (k + 1)) (by positivity)) |>.2.choose,
      fun k => Classical.choose_spec (h_neg (1 / (k + 1)) (by positivity)) |>.2.choose_spec.1,
      fun k => Classical.choose_spec (h_neg (1 / (k + 1)) (by positivity)) |>.2.choose_spec.2⟩
  obtain ⟨y, hy⟩ : ∃ y ∈ K, ∃ subseq : ℕ → ℕ,
      StrictMono subseq ∧ Tendsto (fun j => y_seq (subseq j)) atTop (nhds y) := by
    exact hK.isSeqCompact fun k => z_seq k
  obtain ⟨subseq, hsubseq_mono, hsubseq_conv⟩ := hy.right
  have hz_conv : Tendsto (fun j => (hy_seq (subseq j)).val) atTop (nhds y) := by
    have : Tendsto (fun j => (hy_seq (subseq j)).val - y_seq (subseq j)) atTop (nhds 0) :=
      squeeze_zero_norm (fun j => le_of_lt (hz_seq _))
        (tendsto_one_div_add_atTop_nhds_zero_nat.comp hsubseq_mono.tendsto_atTop)
    simpa using this.add hsubseq_conv
  have hr_conv : Tendsto (fun j => (r (hy_seq (subseq j))).val) atTop
      (nhds (r ⟨y, hSU (hKS hy.left)⟩).val) := by
    convert Tendsto.comp (continuous_subtype_val.continuousAt.tendsto.comp
      hr_cont.continuousAt) (show Tendsto (fun j => hy_seq (subseq j)) atTop
        (nhds ⟨y, hSU (hKS hy.1)⟩) from ?_) using 1
    exact tendsto_subtype_rng.mpr hz_conv
  have := hr_conv.sub hsubseq_conv
  exact absurd (le_of_tendsto_of_tendsto' tendsto_const_nhds this.norm fun j => hr_seq _)
    (by norm_num [hr_fix ⟨y, hKS hy.1⟩]; linarith)

/-! ## Main theorem -/

/-- **EML approximation for neighborhood-retract codomains.**

Let `X` be a compact Hausdorff space, `S` a compact subset of `ℝⁿ` that is a
neighborhood retract (there exist open `U ⊇ S` and continuous `r : U → S`
fixing `S` pointwise). If a set `A` of continuous maps `X → ℝⁿ` is dense in
the sup-norm topology, then every continuous map `X → S` can be uniformly
approximated by continuous maps `X → S`.

This is the key technical engine for extending Stone–Weierstrass-type
approximation results from Euclidean codomains to manifold-valued maps. -/
theorem eml_uniform_approx_subtype_of_neighborhoodRetract
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    {n : ℕ}
    (S : Set (Fin n → ℝ))
    (hS_compact : IsCompact S)
    (U : Set (Fin n → ℝ))
    (hU_open : IsOpen U)
    (hSU : S ⊆ U)
    (r : U → S)
    (hr_cont : Continuous r)
    (hr_fix : ∀ s : S, r ⟨s.1, hSU s.2⟩ = s)
    (A : Set (C(X, Fin n → ℝ)))
    (hA_dense :
      ∀ f : C(X, Fin n → ℝ), ∀ ε > 0,
        ∃ g ∈ A, ∀ x, ‖g x - f x‖ < ε) :
    ∀ f : C(X, S), ∀ ε > 0,
      ∃ g : C(X, S),
        ∀ x, ‖(g x : Fin n → ℝ) - (f x : Fin n → ℝ)‖ < ε := by
  intros f ε hε_pos
  obtain ⟨δ₁, hδ₁_pos, hδ₁⟩ := compact_subset_open_has_uniform_nhds hS_compact hU_open hSU
  obtain ⟨δ₂, hδ₂_pos, hδ₂⟩ :=
    retract_near_compact_uniform hSU hS_compact (Subset.refl S) r hr_cont hr_fix ε hε_pos
  set δ := min δ₁ δ₂
  obtain ⟨g0, hg0⟩ : ∃ g0 ∈ A, ∀ x, ‖g0 x - (f x : Fin n → ℝ)‖ < δ :=
    hA_dense (ContinuousMap.comp ⟨Subtype.val, continuous_subtype_val⟩ f) δ
      (lt_min hδ₁_pos hδ₂_pos)
  refine ⟨⟨fun x => r ⟨g0 x, hδ₁ _ ⟨f x, f x |>.2,
    lt_of_lt_of_le (hg0.2 x) (min_le_left _ _)⟩⟩,
    hr_cont.comp (Continuous.subtype_mk g0.continuous fun x =>
      hδ₁ _ ⟨f x, f x |>.2, lt_of_lt_of_le (hg0.2 x) (min_le_left _ _)⟩)⟩,
    fun x => hδ₂ _ (f x |>.2) _ (lt_of_lt_of_le (hg0.2 x) (min_le_right _ _))⟩

end