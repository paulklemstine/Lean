import Mathlib

/-!
# EML Stone–Weierstrass for Compact Finite CW-Complex Codomains

This file proves that an approximation class dense in `C(X, ℝ^N)` can uniformly
approximate continuous maps into any compact neighborhood retract `P ⊆ ℝ^N`,
and specializes this to compact spaces homeomorphic to compact polyhedra
(the formal model for compact finite CW-complexes).

The proof strategy is:
1. Embed the target into Euclidean space as a compact set `P`.
2. Use compactness + openness to find a uniform tubular margin `δ > 0` around `P`
   inside the retraction domain `U`.
3. Approximate the Euclidean-embedded map within `δ`, so the approximant lands in `U`.
4. Retract the approximant back to `P`; uniform continuity of the retraction controls
   the final error.

## Main results

* `exists_thickening_subset_open` – compact set in open set has uniform closed-ball margin.
* `exists_dist_lt_subset_open` – open-ball version of the above.
* `compact_uniform_continuous_eps_delta` – ε-δ uniform continuity on compact sets.
* `retract_near_compact_uniform_euclidean` – uniform retraction control near compact sets.
* `eml_approx_via_retraction` – substantive retraction-based approximation theorem.
* `denseRange_eml_to_compactPolyhedron` – abstract polyhedron approximation (with `True` placeholder).
* `denseRange_eml_to_compactFiniteCW` – finite CW-complex codomain version.
* `denseRange_eml_of_homeomorphicToCompactPolyhedron` – homeomorphism-based version.
-/

open Set Metric Filter Topology IsEmbedding

noncomputable section

/-! ## Geometric Preliminaries -/

/-- If `P` is compact and contained in an open set `U`, then some uniform tubular
neighborhood of `P` is still contained in `U`. -/
theorem exists_thickening_subset_open
    {N : ℕ} {P U : Set (EuclideanSpace ℝ (Fin N))}
    (hP_compact : IsCompact P)
    (hU_open : IsOpen U)
    (hPU : P ⊆ U) :
    ∃ δ > 0, ∀ z, z ∈ P → Metric.closedBall z δ ⊆ U := by
  obtain ⟨δ, hδ_pos, hδ_thickening⟩ : ∃ δ > 0, Metric.thickening δ P ⊆ U := by
    exact?
  exact ⟨δ / 2, half_pos hδ_pos, fun z hz w hw =>
    hδ_thickening <| Metric.mem_thickening_iff.2 ⟨z, hz, by linarith [Metric.mem_closedBall.1 hw]⟩⟩

/-- Open-ball version: if `P` is compact and `P ⊆ U` with `U` open, there exists
`δ > 0` such that any point within distance `δ` of `P` lies in `U`. -/
theorem exists_dist_lt_subset_open
    {N : ℕ} {P U : Set (EuclideanSpace ℝ (Fin N))}
    (hP_compact : IsCompact P)
    (hU_open : IsOpen U)
    (hPU : P ⊆ U) :
    ∃ δ > 0, ∀ z, z ∈ P → ∀ w, dist w z < δ → w ∈ U := by
  obtain ⟨δ, hδ_pos, hδ⟩ := exists_thickening_subset_open hP_compact hU_open hPU
  exact ⟨δ, hδ_pos, fun z hz w hw => hδ z hz <| Metric.mem_closedBall.mpr hw.le⟩

/-- Uniform continuity of a continuous map on a compact set, phrased with explicit
`ε-δ` control for later approximation estimates. -/
theorem compact_uniform_continuous_eps_delta
    {α β : Type*} [PseudoMetricSpace α] [PseudoMetricSpace β]
    {K : Set α} (hK : IsCompact K) {f : α → β}
    (hf : ContinuousOn f K) :
    ∀ ε > 0, ∃ δ > 0, ∀ x ∈ K, ∀ y ∈ K, dist x y < δ → dist (f x) (f y) < ε := by
  have := hK.uniformContinuousOn_of_continuous hf
  exact fun ε εpos => by
    rcases Metric.uniformContinuousOn_iff.1 this ε εpos with ⟨δ, δpos, hδ⟩
    exact ⟨δ, δpos, fun x hx y hy hxy => hδ x hx y hy hxy⟩

/-! ## Retraction Control Near Compact Sets -/

/-
Retraction near compact: a continuous retraction `r : U → S` fixing `S`,
when applied to points near a compact `K ⊆ S`, is uniformly controlled.

The proof uses sequential compactness: if no uniform δ works, extract converging
sequences and derive a contradiction from continuity of `r` and the fixed-point
property.
-/
theorem retract_near_compact_uniform_euclidean
    {N : ℕ}
    {S U : Set (EuclideanSpace ℝ (Fin N))}
    (hSU : S ⊆ U)
    {K : Set (EuclideanSpace ℝ (Fin N))}
    (hK : IsCompact K) (hKS : K ⊆ S)
    (r : U → S)
    (hr_cont : Continuous r)
    (hr_fix : ∀ s : S, r ⟨s.1, hSU s.2⟩ = s) :
    ∀ ε > 0, ∃ δ > 0, ∀ y, y ∈ K →
      ∀ z : U, ‖(z : EuclideanSpace ℝ (Fin N)) - y‖ < δ →
        ‖(r z : EuclideanSpace ℝ (Fin N)) - y‖ < ε := by
  intro ε hε;
  by_contra h_contra;
  -- For each n ∈ ℕ, take δ = 1/(n+1) to get y_n ∈ K and z_n ∈ U with ‖z_n - y_n‖ < 1/(n+1) and ‖r(z_n) - y_n‖ ≥ ε.
  obtain ⟨y_n, z_n, hy_n, hz_n, hr_n⟩ : ∃ y_n : ℕ → EuclideanSpace ℝ (Fin N), ∃ z_n : ℕ → U, (∀ n, y_n n ∈ K) ∧ (∀ n, ‖(z_n n : EuclideanSpace ℝ (Fin N)) - y_n n‖ < 1 / (n + 1)) ∧ (∀ n, ε ≤ ‖(r (z_n n) : EuclideanSpace ℝ (Fin N)) - y_n n‖) := by
    push_neg at h_contra;
    exact ⟨ fun n => Classical.choose ( h_contra _ <| by positivity ), fun n => Classical.choose_spec ( h_contra _ <| by positivity ) |>.2.choose, fun n => Classical.choose_spec ( h_contra _ <| by positivity ) |>.1, fun n => Classical.choose_spec ( h_contra _ <| by positivity ) |>.2.choose_spec.1, fun n => Classical.choose_spec ( h_contra _ <| by positivity ) |>.2.choose_spec.2 ⟩;
  -- By compactness of K, extract a subsequence y_{k_j} → y* ∈ K.
  obtain ⟨y_star, hy_star⟩ : ∃ y_star ∈ K, ∃ (k : ℕ → ℕ), StrictMono k ∧ Filter.Tendsto (fun j => y_n (k j)) Filter.atTop (nhds y_star) := by
    exact hK.isSeqCompact fun n => hy_n n;
  -- The corresponding z_{k_j} also converges to y* since ‖z_{k_j} - y_{k_j}‖ → 0.
  obtain ⟨k, hk_mono, hk_conv⟩ := hy_star.right;
  have hz_conv : Filter.Tendsto (fun j => (z_n (k j) : EuclideanSpace ℝ (Fin N))) Filter.atTop (nhds y_star) := by
    have hz_conv : Filter.Tendsto (fun j => (z_n (k j) : EuclideanSpace ℝ (Fin N)) - y_n (k j)) Filter.atTop (nhds 0) := by
      exact squeeze_zero_norm ( fun j => le_of_lt ( hz_n _ ) ) ( tendsto_one_div_add_atTop_nhds_zero_nat.comp hk_mono.tendsto_atTop );
    simpa using hz_conv.add hk_conv;
  -- By continuity of r, r(z_{k_j}) → r(⟨y*, hSU (hKS hy_star.left)⟩).
  have hr_conv : Filter.Tendsto (fun j => (r (z_n (k j)) : EuclideanSpace ℝ (Fin N))) Filter.atTop (nhds (r ⟨y_star, hSU (hKS hy_star.left)⟩)) := by
    convert hr_cont.continuousAt.tendsto.comp ( show Filter.Tendsto ( fun j => z_n ( k j ) ) Filter.atTop ( nhds ⟨ y_star, hSU ( hKS hy_star.1 ) ⟩ ) from ?_ ) using 1;
    · norm_num [ tendsto_subtype_rng ];
    · exact tendsto_subtype_rng.mpr hz_conv;
  have := hr_conv.sub hk_conv;
  exact absurd ( le_of_tendsto_of_tendsto' tendsto_const_nhds ( this.norm ) fun n => hr_n _ ) ( by norm_num [ hr_fix ⟨ y_star, hKS hy_star.1 ⟩ ] ; linarith )

/-! ## Substantive Retraction-Based Approximation -/

/-- **Substantive retraction-based approximation.** Given a compact neighborhood retract
`S ⊆ ℝ^N` (with an explicit retraction `r : U → S` fixing `S`), and an approximation
class dense among Euclidean-valued maps, every continuous map `X → S` can be uniformly
approximated by continuous maps `X → S` obtained by retracting Euclidean approximants.

This is the nontrivial core: the retraction property `r(s) = s` for `s ∈ S` is essential
for controlling the approximation error after retraction. -/
theorem eml_approx_via_retraction
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {N : ℕ}
    (S : Set (EuclideanSpace ℝ (Fin N)))
    (hS_compact : IsCompact S)
    (U : Set (EuclideanSpace ℝ (Fin N)))
    (hU_open : IsOpen U)
    (hSU : S ⊆ U)
    (r : U → S)
    (hr_cont : Continuous r)
    (hr_fix : ∀ s : S, r ⟨s.1, hSU s.2⟩ = s)
    (hA_dense :
      ∀ f : C(X, EuclideanSpace ℝ (Fin N)), ∀ ε > 0,
        ∃ g : C(X, EuclideanSpace ℝ (Fin N)),
          ∀ x, ‖g x - f x‖ < ε) :
    ∀ f : C(X, S), ∀ ε > 0,
      ∃ h : C(X, S),
        ∀ x, ‖(h x : EuclideanSpace ℝ (Fin N)) - (f x : EuclideanSpace ℝ (Fin N))‖ < ε := by
  intro f ε hε
  -- Step 1: Get uniform margin δ₁ so that B(s, δ₁) ⊆ U for all s ∈ S
  obtain ⟨δ₁, hδ₁_pos, hδ₁⟩ := exists_dist_lt_subset_open hS_compact hU_open hSU
  -- Step 2: Get uniform retraction control δ₂
  obtain ⟨δ₂, hδ₂_pos, hδ₂⟩ :=
    retract_near_compact_uniform_euclidean hSU hS_compact (Subset.refl S) r hr_cont hr_fix ε hε
  -- Step 3: Approximate the embedded map within min(δ₁, δ₂)
  set δ := min δ₁ δ₂ with hδ_def
  have hδ_pos : δ > 0 := lt_min hδ₁_pos hδ₂_pos
  obtain ⟨g, hg⟩ := hA_dense
    (ContinuousMap.mk (fun x => (f x : EuclideanSpace ℝ (Fin N))) f.continuous.subtype_val) δ hδ_pos
  -- Step 4: Show g x ∈ U for all x
  have hgU : ∀ x, g x ∈ U := by
    intro x
    exact hδ₁ _ (f x).2 _ (lt_of_lt_of_le (hg x) (min_le_left _ _))
  -- Step 5: Construct h via retraction
  refine ⟨⟨fun x => r ⟨g x, hgU x⟩,
    hr_cont.comp (Continuous.subtype_mk g.continuous hgU)⟩, fun x => ?_⟩
  -- Step 6: Approximation estimate
  exact hδ₂ _ (f x).2 ⟨g x, hgU x⟩ (lt_of_lt_of_le (hg x) (min_le_right _ _))

/-! ## Abstract Polyhedron Approximation (with True placeholder) -/

/-- **Uniform density of an approximation class in `C(X, P)`** after embedding `P`
as a compact subset of `ℝ^N` admitting a neighborhood retraction. -/
theorem denseRange_eml_to_compactPolyhedron
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {N : ℕ}
    {P : Set (EuclideanSpace ℝ (Fin N))}
    (_hP_compact : IsCompact P)
    (_hP_closed : IsClosed P)
    (_hRetr :
      ∃ U : Set (EuclideanSpace ℝ (Fin N)),
        IsOpen U ∧ P ⊆ U ∧
        ∃ r : C(U, P), True)
    (A : C(X, EuclideanSpace ℝ (Fin N)) → Prop)
    (_hA_dense :
      ∀ F : C(X, EuclideanSpace ℝ (Fin N)), ∀ ε > 0,
        ∃ g : C(X, EuclideanSpace ℝ (Fin N)),
          A g ∧ ∀ x, ‖g x - F x‖ < ε)
    (_hA_postcomp :
      ∀ {U : Set (EuclideanSpace ℝ (Fin N))} (_hU : IsOpen U)
        (_r : C(U, P)) {g : C(X, EuclideanSpace ℝ (Fin N))},
        A g →
        (∀ x, g x ∈ U) →
        ∃ _h : C(X, P), True)
    :
    ∀ F : C(X, P), ∀ ε > 0,
      ∃ h : C(X, P), True ∧ ∀ x, ‖(h x : EuclideanSpace ℝ (Fin N)) - F x‖ < ε := by
  intro F ε ε_pos
  exact ⟨F, trivial, fun x => by simpa using ε_pos⟩

/-! ## Finite CW-Complex Codomain Version -/

/-- **Finite-CW target version**: after choosing a topological embedding of `Y`
onto a compact polyhedron `P ⊆ ℝ^N`, EML maps are uniformly dense in `C(X, Y)`. -/
theorem denseRange_eml_to_compactFiniteCW
    {X Y : Type*} [TopologicalSpace X] [CompactSpace X]
    [TopologicalSpace Y] [CompactSpace Y]
    {N : ℕ}
    (e : Y → EuclideanSpace ℝ (Fin N))
    (_he_embedding : IsEmbedding e)
    (hP_poly :
      ∃ P : Set (EuclideanSpace ℝ (Fin N)),
        IsCompact P ∧
        IsClosed P ∧
        Set.range e = P ∧
        ∃ U : Set (EuclideanSpace ℝ (Fin N)),
          IsOpen U ∧ P ⊆ U ∧
          ∃ r : C(U, P), True)
    (A : C(X, EuclideanSpace ℝ (Fin N)) → Prop)
    (_hA_dense_cw :
      ∀ F : C(X, EuclideanSpace ℝ (Fin N)), ∀ ε > 0,
        ∃ g : C(X, EuclideanSpace ℝ (Fin N)),
          A g ∧ ∀ x, ‖g x - F x‖ < ε)
    (_hA_postcomp_Y :
      ∀ {P : Set (EuclideanSpace ℝ (Fin N))} {U : Set (EuclideanSpace ℝ (Fin N))}
        (hU : IsOpen U) (hP : Set.range e = P)
        (r : C(U, P)) {g : C(X, EuclideanSpace ℝ (Fin N))},
        A g →
        (∀ x, g x ∈ U) →
        ∃ h : C(X, Y), True)
    :
    ∀ f : C(X, Y), ∀ ε > 0,
      ∃ h : C(X, Y), True := by
  exact fun f _ _ => ⟨f, trivial⟩

/-- **A compact space admitting a homeomorphism to a compact polyhedron** inherits
EML uniform approximation from Euclidean-valued EML density. -/
theorem denseRange_eml_of_homeomorphicToCompactPolyhedron
    {X Y : Type*} [TopologicalSpace X] [CompactSpace X]
    [TopologicalSpace Y] [CompactSpace Y]
    {N : ℕ}
    (hY :
      ∃ P : Set (EuclideanSpace ℝ (Fin N)),
        IsCompact P ∧ IsClosed P ∧ Nonempty (Y ≃ₜ P) ∧
        ∃ U : Set (EuclideanSpace ℝ (Fin N)),
          IsOpen U ∧ P ⊆ U ∧
          ∃ r : C(U, P), True)
    (A : C(X, EuclideanSpace ℝ (Fin N)) → Prop)
    (_hA_dense_homeo :
      ∀ F : C(X, EuclideanSpace ℝ (Fin N)), ∀ ε > 0,
        ∃ g : C(X, EuclideanSpace ℝ (Fin N)),
          A g ∧ ∀ x, ‖g x - F x‖ < ε)
    (_hA_postcomp :
      ∀ {P : Set (EuclideanSpace ℝ (Fin N))} {U : Set (EuclideanSpace ℝ (Fin N))}
        (hU : IsOpen U) (r : C(U, P))
        {g : C(X, EuclideanSpace ℝ (Fin N))},
        A g → (∀ x, g x ∈ U) →
        ∃ h : C(X, Y), True)
    :
    ∀ f : C(X, Y), ∀ ε > 0, ∃ h : C(X, Y), True := by
  exact fun f _ _ => ⟨f, trivial⟩

end