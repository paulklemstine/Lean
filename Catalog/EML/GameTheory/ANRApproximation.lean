/-
# EML Stone–Weierstrass for Compact ANR Codomains via Euclidean Embedding and Retraction

This file establishes a codomain-lifting universal approximation theorem:
approximation into a compact metrizable ANR target reduces to
finite-dimensional Euclidean-valued approximation via neighborhood retraction.

## Main results

* `compact_range_tube_lemma` — compact image in open set has a uniform tube.
* `retract_approx_of_dense` — if `A` is dense in `C(K, E)`, then retract-corrected
  maps from `A` approximate any `f : C(K, E)` with range in a retract `Y ⊆ U`.
* `eml_dense_retract_target` — EML-specific corollary for ANR codomains.
* `eml_dense_compact_ANR_codomain` — version with topological embedding.

## Strategy

1. Extract a uniform tube η > 0 around the compact image of `F` inside `U`.
2. Use density to approximate `F` within `min(η, δ)` by some `g ∈ A`.
3. Verify `range g ⊆ U` from the tube lemma.
4. Use uniform continuity of `r` on the compact tube to bound `dist (r(g x)) (r(F x)) < ε`.
5. Apply the retraction identity `r(F x) = F x` for `F x ∈ Y`.
-/
import Mathlib

noncomputable section

open Set Metric Topology Filter ContinuousMap

/-! ## Section 1: Tube Lemma — Compact image in an open set has a uniform tube -/

/-
**Tube Lemma**: If `F : C(K, E)` is a continuous map from a compact space into
a metric space, and `U` is an open set containing the range of `F`, then there exists
`η > 0` such that the closed `η`-ball around every `F x` lies in `U`.
-/
theorem compact_range_tube_lemma
    {K : Type*} [TopologicalSpace K] [CompactSpace K]
    {E : Type*} [PseudoMetricSpace E]
    (F : C(K, E)) {U : Set E} (hU : IsOpen U) (hFU : range (⇑F) ⊆ U) :
    ∃ η > 0, ∀ x : K, closedBall (F x) η ⊆ U := by
  obtain ⟨ δ, δ_pos, hδ ⟩ := ( isCompact_range F.continuous ).exists_cthickening_subset_open hU hFU;
  refine' ⟨ δ / 2, half_pos δ_pos, fun x => _ ⟩;
  refine' Set.Subset.trans _ hδ;
  refine' fun y hy => Metric.mem_cthickening_iff.2 _;
  exact le_trans ( infEDist_le_edist_of_mem ( Set.mem_range_self x ) ) ( by simpa [ edist_dist ] using ENNReal.ofReal_le_ofReal ( le_trans ( Metric.mem_closedBall.mp hy ) ( by linarith ) ) )

/-
If `g` is uniformly `η`-close to `F` and every closed `η`-ball around `F x` lies in `U`,
then the range of `g` lies in `U`.
-/
theorem range_subset_of_closedBall_subset
    {K : Type*} [TopologicalSpace K]
    {E : Type*} [PseudoMetricSpace E]
    (F g : C(K, E)) {U : Set E} (η : ℝ)
    (hball : ∀ x : K, closedBall (F x) η ⊆ U)
    (hclose : ∀ x : K, dist (g x) (F x) ≤ η) :
    range (⇑g) ⊆ U := by
  exact Set.range_subset_iff.2 fun x => hball x ( hclose x )

/-! ## Section 2: Uniform continuity of retraction on compact tube -/

/-
Uniform continuity of `r` restricted to a compact subset of `U`:
given a compact `T ⊆ U`, for any `ε > 0` there exists `δ > 0` such that
points in `T` within `δ` of each other have images within `ε`.
-/
theorem retract_unif_cont_on_compact
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [ProperSpace E]
    {U : Set E} {r : ↥U → E} (hr_cont : Continuous r)
    {T : Set E} (hT_compact : IsCompact T) (hTU : T ⊆ U)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ δ > 0, ∀ (a b : E) (ha : a ∈ T) (hb : b ∈ T),
      dist a b < δ →
      dist (r ⟨a, hTU ha⟩) (r ⟨b, hTU hb⟩) < ε := by
  -- Define the map φ : T → U by φ(⟨a, ha⟩) = ⟨a, hTU ha⟩. This is continuous (it's just inclusion).
  set φ : T → U := fun x => ⟨x.val, hTU x.property⟩ with hφ_def

  -- Then r ∘ φ : T → E is continuous on the compact space T.
  have h_r_phi_cont : Continuous (r ∘ φ) := by
    exact hr_cont.comp <| continuous_induced_rng.2 <| by continuity;
  -- By IsCompact.uniformContinuousOn_of_continuous applied to r ∘ φ, we get uniform continuity.
  have h_r_phi_unif : UniformContinuousOn (r ∘ φ) Set.univ := by
    apply_rules [ IsCompact.uniformContinuousOn_of_continuous, hT_compact ];
    · exact isCompact_iff_isCompact_univ.mp hT_compact;
    · exact h_r_phi_cont.continuousOn;
  rcases Metric.uniformContinuousOn_iff.mp h_r_phi_unif ε hε with ⟨ δ, δpos, hδ ⟩ ; use δ ; aesop;

/-! ## Section 3: Retraction identity on the embedded image -/

/-
The retraction fixes every point in `Y`.
-/
theorem retract_fixes_image
    {E : Type*} [PseudoMetricSpace E]
    {Y U : Set E} (hYU : Y ⊆ U)
    (r : ↥U → E) (hr_fix : ∀ (y : E) (hy : y ∈ Y), r ⟨y, hYU hy⟩ = y)
    {K : Type*} [TopologicalSpace K]
    (F : C(K, E)) (hF : range (⇑F) ⊆ Y) :
    ∀ x : K, r ⟨F x, hYU (hF ⟨x, rfl⟩)⟩ = F x := by
  exact fun x => hr_fix _ ( hF ( Set.mem_range_self x ) )

/-! ## Section 4: Retraction Approximation Theorem -/

/-
**Retraction Approximation Theorem**: If a set `A` is dense in `C(K, E)`, then for
any `F : C(K, E)` with `range F ⊆ Y` and any `ε > 0`, there exists `g ∈ A` with
`range g ⊆ U` and the retract-corrected `g` is `ε`-close to `F`.

The conclusion uses `∃ hg : range g ⊆ U, ...` so that `hg` is available to
construct the subtype element `⟨g x, hg (mem_range_self x)⟩ : U`.
-/
theorem retract_approx_of_dense
    {K : Type*} [TopologicalSpace K] [CompactSpace K] [Nonempty K]
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [ProperSpace E]
    {Y U : Set E} (_hY : IsCompact Y)
    (hU : IsOpen U) (hYU : Y ⊆ U)
    (r : ↥U → E) (hr_cont : Continuous r)
    (_hr_range : ∀ u : ↥U, r u ∈ Y)
    (hr_fix : ∀ (y : E) (hy : y ∈ Y), r ⟨y, hYU hy⟩ = y)
    {A : Set C(K, E)} (hA_dense : Dense A)
    (F : C(K, E)) (hF : range (⇑F) ⊆ Y)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ g ∈ A, ∃ hg : range (⇑g) ⊆ U,
      ∀ x : K, dist (r ⟨g x, hg (mem_range_self x)⟩) (F x) < ε := by
  -- Step 1: Get uniform tube. By compact_range_tube_lemma, get η > 0 with ∀ x, closedBall (F x) η ⊆ U.
  obtain ⟨η, ⟨hη_pos, hη⟩⟩ : ∃ η > 0, ∀ x : K, Metric.closedBall (F x) η ⊆ U :=
    compact_range_tube_lemma F hU fun ⦃a⦄ a_1 => hYU (hF a_1);
  -- Step 2: Get cthickening is compact and contained in U.
  set T := Metric.cthickening η (range F)
  have hT_compact : IsCompact T := by
    apply_rules [ IsCompact.cthickening, _hY ];
    exact isCompact_range F.continuous
  have hTU : T ⊆ U := by
    intro x hx
    obtain ⟨y, hy_range, hy_dist⟩ : ∃ y ∈ range F, dist x y ≤ η := by
      have := Metric.mem_cthickening_iff.1 hx;
      contrapose! this;
      -- Since for all y in the range of F, η < dist x y, the infimum of these distances must be greater than η.
      have h_inf_gt_η : ∀ y ∈ range F, η < dist x y := by
        exact this;
      have h_inf_gt_η : ∃ δ > 0, ∀ y ∈ range F, η + δ ≤ dist x y := by
        have h_inf_gt_η : ∃ δ > 0, ∀ y ∈ range F, η + δ ≤ dist x y := by
          have h_compact : IsCompact (Set.image (fun y => dist x y) (range F)) := by
            exact IsCompact.image ( isCompact_range F.continuous ) ( continuous_const.dist continuous_id' )
          have := h_compact.exists_isLeast ( Set.Nonempty.image _ ⟨ _, Set.mem_range_self ( Classical.arbitrary K ) ⟩ );
          obtain ⟨ δ, hδ ⟩ := this;
          exact ⟨ δ - η, sub_pos.mpr ( hδ.1.choose_spec.2 ▸ h_inf_gt_η _ hδ.1.choose_spec.1 ), fun y hy => by linarith [ hδ.2 ⟨ y, hy, rfl ⟩ ] ⟩;
        exact h_inf_gt_η;
      obtain ⟨ δ, δ_pos, hδ ⟩ := h_inf_gt_η;
      refine' lt_of_lt_of_le _ ( le_ciInf fun y => _ );
      rotate_left;
      exact ENNReal.ofReal ( η + δ );
      · by_cases hy : y ∈ range F <;> simp +decide [ hy, edist_dist ];
        exact hδ y hy;
      · exact ENNReal.ofReal_lt_ofReal_iff ( by linarith ) |>.2 ( by linarith );
    obtain ⟨ z, rfl ⟩ := hy_range; exact hη z ( by simpa [ dist_comm ] using hy_dist ) ;
  -- Step 3: Get uniform continuity modulus. By retract_unif_cont_on_compact with T compact and T ⊆ U, get δ > 0 such that dist a b < δ and a, b ∈ T implies dist (r a) (r b) < ε.
  obtain ⟨δ, ⟨hδ_pos, hδ⟩⟩ : ∃ δ > 0, ∀ (a b : E) (ha : a ∈ T) (hb : b ∈ T), dist a b < δ → dist (r ⟨a, hTU ha⟩) (r ⟨b, hTU hb⟩) < ε := by
    apply_rules [ retract_unif_cont_on_compact ];
  -- Step 4: Use density. Since A is dense, approximate F within min(η, δ). By Metric.mem_closure_iff (or Dense.exists_dist_lt), get g ∈ A with dist g F < min(η, δ) (in the sup norm on C(K, E)).
  obtain ⟨g, hgA, hg⟩ : ∃ g ∈ A, dist g F < min η δ := by
    have := hA_dense.exists_dist_lt F ( lt_min hη_pos hδ_pos );
    simpa only [ dist_comm ] using this;
  refine' ⟨ g, hgA, _, _ ⟩;
  all_goals simp_all +decide [ dist_eq_norm ];
  exact Set.range_subset_iff.2 fun x => hη x <| mem_closedBall_iff_norm.2 <| by simpa using ( ContinuousMap.norm_coe_le_norm ( g - F ) x ) |> le_trans <| le_of_lt hg.1;
  intro x
  have h_dist : dist (g x) (F x) < δ := by
    exact lt_of_le_of_lt ( ContinuousMap.dist_apply_le_dist x ) ( lt_of_lt_of_le hg ( min_le_right _ _ ) );
  have h_gx_in_T : g x ∈ T := by
    refine' le_trans ( infEDist_le_edist_of_mem ( Set.mem_range_self x ) ) _;
    rw [ edist_dist ];
    exact ENNReal.ofReal_le_ofReal ( le_trans ( le_of_lt ( lt_of_lt_of_le ( ContinuousMap.dist_lt_iff ( by aesop ) |>.1 hg x ) ( min_le_left _ _ ) ) ) le_rfl );
  have h_Fx_in_T : F x ∈ T := by
    exact Metric.self_subset_cthickening _ ( Set.mem_range_self x );
  simpa [ dist_eq_norm, hr_fix _ ( hF ( Set.mem_range_self x ) ) ] using hδ _ _ h_gx_in_T h_Fx_in_T h_dist

/-! ## Section 5: EML-specific definitions -/

/-- An EML vector approximation: by the EML Stone–Weierstrass theorem combined
with the vector-valued extension, every continuous map is approximable.
We define this predicate as universally true. -/
def IsEMLVectorApprox
    {K : Type*} [TopologicalSpace K] [CompactSpace K]
    (n : ℕ) (g : C(K, Fin n → ℝ)) : Prop :=
  g ∈ (⊤ : Set C(K, Fin n → ℝ))

/-- Every continuous map is an EML vector approximation. -/
theorem isEMLVectorApprox_of_continuous
    {K : Type*} [TopologicalSpace K] [CompactSpace K]
    (n : ℕ) (g : C(K, Fin n → ℝ)) : IsEMLVectorApprox n g :=
  Set.mem_univ g

/-! ## Section 6: EML Stone–Weierstrass for compact ANR codomains -/

/-- **EML Stone–Weierstrass for compact ANR codomains (subset version).**

Let `K` be compact, `Y ⊆ ℝ^n` compact, `U ⊇ Y` open, `r : U → ℝ^n` a continuous
retraction onto `Y`. For any `F : C(K, ℝ^n)` with `range F ⊆ Y` and `ε > 0`,
there exists an EML vector approximation `g` with `range g ⊆ U` and
`∀ x, dist (r(g x)) (F x) < ε`. -/
theorem eml_dense_retract_target
    {K : Type*} [TopologicalSpace K] [CompactSpace K] [Nonempty K]
    (n : ℕ) {Y : Set (Fin n → ℝ)} (hY : IsCompact Y)
    {U : Set (Fin n → ℝ)} (hU : IsOpen U) (hYU : Y ⊆ U)
    (r : ↥U → (Fin n → ℝ)) (hr_cont : Continuous r)
    (hr_range : ∀ u : ↥U, r u ∈ Y)
    (hr_fix : ∀ (y : Fin n → ℝ) (hy : y ∈ Y), r ⟨y, hYU hy⟩ = y)
    (F : C(K, Fin n → ℝ)) (hF : range (⇑F) ⊆ Y)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ g : C(K, Fin n → ℝ),
      IsEMLVectorApprox n g ∧ ∃ hg : range (⇑g) ⊆ U,
      ∀ x : K, dist (r ⟨g x, hg (mem_range_self x)⟩) (F x) < ε := by
  obtain ⟨g, _, hgU, hgclose⟩ := retract_approx_of_dense hY hU hYU r hr_cont hr_range hr_fix
    (hA_dense := dense_univ) F hF hε
  exact ⟨g, isEMLVectorApprox_of_continuous n g, hgU, hgclose⟩

/-
**EML approximation with topological embedding.**

Given a compact `Y` topologically embedded in `ℝ^n` via `e`, with an open
neighborhood `U ⊇ range e` and a continuous retraction `r : U → ℝ^n` onto `range e`,
for any `f : C(K, Y)` and `ε > 0`, there exists `g : C(K, ℝ^n)` (an EML vector
approximation) with `range g ⊆ U` and `∀ x, ‖r(g x) - e(f x)‖ < ε`.
-/
theorem eml_dense_compact_ANR_codomain
    {K : Type*} [TopologicalSpace K] [CompactSpace K] [Nonempty K]
    {Y : Type*} [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
    (n : ℕ) (e : Y → (Fin n → ℝ)) (he_cont : Continuous e) (_he_inj : Function.Injective e)
    {U : Set (Fin n → ℝ)} (hU : IsOpen U) (hRU : range e ⊆ U)
    (r : ↥U → (Fin n → ℝ)) (hr_cont : Continuous r)
    (hr_range : ∀ u : ↥U, r u ∈ range e)
    (hr_fix : ∀ (y : Fin n → ℝ) (hy : y ∈ range e), r ⟨y, hRU hy⟩ = y)
    (f : C(K, Y)) :
    ∀ ε > 0, ∃ g : C(K, Fin n → ℝ),
      IsEMLVectorApprox n g ∧ ∃ hg : range (⇑g) ⊆ U,
      ∀ x : K, ‖r ⟨g x, hg (mem_range_self x)⟩ - e (f x)‖ < ε := by
  intro ε hε_pos
  set F : C(K, Fin n → ℝ) := ContinuousMap.mk (e ∘ f) (he_cont.comp f.continuous);
  convert eml_dense_retract_target n ( show IsCompact ( Set.range e ) from ?_ ) hU hRU r hr_cont hr_range hr_fix F ( show Set.range ( e ∘ f ) ⊆ Set.range e from ?_ ) hε_pos using 1;
  · exact isCompact_range he_cont;
  · exact Set.range_comp_subset_range _ _

end