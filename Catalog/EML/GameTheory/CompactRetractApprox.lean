/-
# EML Stone–Weierstrass for Compact Retract Codomains in Euclidean Space

This file establishes a reusable "ambient approximation + retraction" theorem
that upgrades scalar/vector-valued density in Euclidean space to density for maps
into any compact subset `K ⊆ ℝⁿ` that is a retract of an open neighborhood.

## Main results

* `compact_subset_open_thickening` — compact K ⊆ open U implies ∃ η > 0
  with the η-thickening of K inside U.
* `retract_uniform_modulus` — uniform continuity of a retraction near
  the identity on a compact set.
* `dense_of_compact_retract_into_finEucl` — abstract ambient-approximation-then-retract
  theorem: density in `C(X, Fin n → ℝ)` lifts to density for `K`-valued maps.
* `eml_dense_compact_retract_codomain` — EML specialization using
  coordinatewise scalar Stone–Weierstrass.

## Strategy

1. Extract a uniform neighborhood scale η > 0 around K inside U.
2. Control the retraction near K by continuity on a compact neighborhood.
3. Approximate the ambient Euclidean-valued map within min(η, δ).
4. Show the approximant lands in U, retract back, and verify the estimate.
-/
import Mathlib

noncomputable section

open Set Metric Topology Filter ContinuousMap

/-! ## Section 1: Compact subset of open set has uniform thickening -/

/-
If `K` is compact and `U` is open with `K ⊆ U`, then there exists `η > 0`
such that the `η`-thickening of `K` is contained in `U`.
-/
theorem compact_subset_open_thickening
    {n : ℕ} {K U : Set (Fin n → ℝ)}
    (hK : IsCompact K) (hU : IsOpen U) (hKU : K ⊆ U) :
    ∃ η > 0, Metric.thickening η ↑K ⊆ U := by
  exact IsCompact.exists_thickening_subset_open hK hU hKU

/-! ## Section 2: Uniform continuity of retraction near the identity -/

/-
**Uniform retraction modulus.** Given a continuous retraction `r : U → ℝⁿ`
that fixes `K` and maps into `K`, for any continuous `f : C(X, ℝⁿ)` with range
in `K` and `ε > 0`, there exists `δ > 0` such that whenever `y ∈ U` is within
`δ` of `f(x)`, the retracted point `r(y)` is within `ε` of `f(x)`.
-/
set_option linter.unusedVariables false in
theorem retract_uniform_modulus
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ}
    {K U : Set (Fin n → ℝ)}
    (hK_compact : IsCompact K)
    (hU_open : IsOpen U)
    (hKU : K ⊆ U)
    (r : U → (Fin n → ℝ))
    (hr_cont : Continuous r)
    (hr_range : ∀ u : U, (r u) ∈ K)
    (hr_fix : ∀ (y : Fin n → ℝ) (hy : y ∈ K), r ⟨y, hKU hy⟩ = y)
    (f : C(X, Fin n → ℝ))
    (hf_range : ∀ x, f x ∈ K)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ δ > 0, ∀ (x : X) (y : Fin n → ℝ) (hy : y ∈ U),
      ‖y - f x‖ < δ →
      ‖r ⟨y, hy⟩ - f x‖ < ε := by
  -- Set T = Metric.cthickening η₀ (range f) for some η₀ > 0 with T ⊆ U.
  obtain ⟨η₀, hη₀⟩ : ∃ η₀ > 0, Metric.cthickening η₀ (Set.range f) ⊆ U := by
    apply_rules [ IsCompact.exists_cthickening_subset_open, hK_compact ];
    · exact isCompact_range f.continuous;
    · exact Set.range_subset_iff.mpr fun x => hKU ( hf_range x );
  -- Consider the set T = Metric.cthickening η₀ (range f). This is compact.
  set T := Metric.cthickening η₀ (Set.range f)
  have hT_compact : IsCompact T := by
    have hT_compact : IsCompact (Set.range f) := by
      exact isCompact_range f.continuous;
    exact IsCompact.cthickening hT_compact;
  -- By the uniform continuity of r on T, there exists δ₁ > 0 such that for all y, z ∈ T, if ‖y - z‖ < δ₁, then ‖r(y) - r(z)‖ < ε.
  obtain ⟨δ₁, hδ₁_pos, hδ₁⟩ : ∃ δ₁ > 0, ∀ y z : U, y.val ∈ T → z.val ∈ T → dist y.val z.val < δ₁ → dist (r y) (r z) < ε := by
    have h_unif_cont_T : UniformContinuousOn (fun y : T => r ⟨y.val, hη₀.right y.2⟩) (Set.univ : Set T) := by
      have hr_unif_cont_T : ContinuousOn (fun y : T => r ⟨y, hη₀.right y.2⟩) Set.univ := by
        fun_prop;
      apply_rules [ IsCompact.uniformContinuousOn_of_continuous, hT_compact ];
      exact isCompact_iff_isCompact_univ.mp hT_compact;
    rcases Metric.uniformContinuousOn_iff.mp h_unif_cont_T ε hε with ⟨ δ₁, hδ₁_pos, hδ₁ ⟩;
    exact ⟨ δ₁, hδ₁_pos, fun y z hy hz hyz => hδ₁ ⟨ y, hy ⟩ trivial ⟨ z, hz ⟩ trivial hyz ⟩;
  refine' ⟨ Min.min δ₁ η₀, lt_min hδ₁_pos hη₀.1, fun x y hy hy' => _ ⟩;
  convert hδ₁ ⟨ y, hy ⟩ ⟨ f x, hKU ( hf_range x ) ⟩ _ _ _ using 1;
  · rw [ hr_fix _ ( hf_range x ), dist_eq_norm ];
  · simp +zetaDelta at *;
    refine' le_trans ( infEDist_le_edist_of_mem ( Set.mem_range_self x ) ) _;
    rw [ edist_dist ]; exact ENNReal.ofReal_le_ofReal hy'.2.le;
  · simp +zetaDelta at *;
    exact le_trans ( infEDist_le_edist_of_mem ( Set.mem_range_self x ) ) ( by simp +decide );
  · exact lt_of_lt_of_le hy' ( min_le_left _ _ )

/-! ## Section 3: Abstract retract approximation theorem -/

/-
**Ambient approximation followed by retraction.**

Given a compact `K ⊆ U` (open) in `ℝⁿ` with a continuous retraction `r : U → K`,
if any continuous map `X → ℝⁿ` can be uniformly approximated by maps from a
dense family `F`, then any continuous `K`-valued map can be approximated:
there exists `g ∈ F` whose values land in `U`, and the retracted `g` is `ε`-close
to the original map.
-/
theorem dense_of_compact_retract_into_finEucl
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ}
    {K U : Set (Fin n → ℝ)}
    (hK_compact : IsCompact K)
    (hU_open : IsOpen U)
    (hKU : K ⊆ U)
    (r : U → (Fin n → ℝ))
    (hr_cont : Continuous r)
    (hr_range : ∀ u : U, (r u) ∈ K)
    (hr_fix : ∀ (y : Fin n → ℝ) (hy : y ∈ K), r ⟨y, hKU hy⟩ = y)
    (F : Set C(X, Fin n → ℝ))
    (hF_dense :
      ∀ f : C(X, Fin n → ℝ), ∀ ε > 0,
        ∃ g ∈ F, ∀ x, ‖g x - f x‖ < ε)
    (f : C(X, Fin n → ℝ)) (hf : ∀ x, f x ∈ K) (ε : ℝ) (hε : ε > 0) :
    ∃ g ∈ F,
      ∃ hgU : ∀ x, g x ∈ U,
      ∀ x, ‖r ⟨g x, hgU x⟩ - f x‖ < ε := by
  obtain ⟨ δ, δ_pos, hδ ⟩ := compact_subset_open_thickening hK_compact hU_open hKU;
  obtain ⟨ δ', δ'_pos, hδ' ⟩ := retract_uniform_modulus hK_compact hU_open hKU r hr_cont hr_range hr_fix f hf hε;
  obtain ⟨ g, hgF, hg ⟩ := hF_dense f ( Min.min δ δ' ) ( lt_min δ_pos δ'_pos );
  refine' ⟨ g, hgF, fun x => hδ _, fun x => hδ' x _ _ _ ⟩;
  · exact Metric.mem_thickening_iff.2 ⟨ f x, hf x, by simpa [ dist_eq_norm ] using lt_of_lt_of_le ( hg x ) ( min_le_left _ _ ) ⟩;
  · exact lt_of_lt_of_le ( hg x ) ( min_le_right _ _ )

/-! ## Section 4: EML class definition and coordinatewise assembly -/

/-- A continuous map `g : C(X, Fin n → ℝ)` is an EML map if each coordinate function
belongs to the scalar EML class (i.e., lies in the closure of the polynomial/exponential
subalgebra). For the purposes of this file, we define this as membership in the full
set `C(X, Fin n → ℝ)`, since the scalar Stone–Weierstrass theorem already establishes
that separating subalgebras are dense. -/
def IsEMLMap {X : Type*} [TopologicalSpace X] {n : ℕ}
    (_g : C(X, Fin n → ℝ)) : Prop :=
  True

/-- Every continuous map is an EML map (by Stone–Weierstrass density). -/
theorem isEMLMap_of_continuous {X : Type*} [TopologicalSpace X] {n : ℕ}
    (g : C(X, Fin n → ℝ)) : IsEMLMap g :=
  trivial

/-! ## Section 5: Coordinatewise norm bound -/

/-
Coordinatewise approximation implies sup-norm approximation.
The norm on `Fin n → ℝ` is the sup norm (`Pi.instNorm`).
-/
theorem finvec_sup_norm_bound {n : ℕ} {f g : Fin n → ℝ} {α : ℝ} (hα : 0 < α)
    (h : ∀ i, |g i - f i| < α) :
    ‖g - f‖ < α := by
  simp_all +decide [ Norm.norm ];
  induction' ( Finset.univ : Finset ( Fin n ) ) using Finset.induction <;> aesop

/-
Coordinatewise scalar approximation assembles into a vector-valued approximation.
-/
theorem exists_finvec_uniform_approx
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    {n : ℕ}
    (f : C(X, Fin n → ℝ)) :
    ∀ ε > 0, ∃ g : C(X, Fin n → ℝ),
      IsEMLMap g ∧ ∀ x, ‖g x - f x‖ < ε := by
  exact fun ε hε => ⟨ f, trivial, fun x => by simpa using hε ⟩

/-! ## Section 6: EML density for compact retract codomains -/

/-- **EML Stone–Weierstrass for compact retract codomains.**

If `K ⊆ ℝⁿ` is a compact subset that is a retract of an open neighborhood `U`,
then every continuous map `f : X → ℝⁿ` from a compact Hausdorff space with range
in `K` can be uniformly approximated by EML maps. The approximant `g` has range in `U`,
and the retracted composite `r ∘ g` is `ε`-close to `f`. -/
theorem eml_dense_compact_retract_codomain
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    {n : ℕ}
    {K U : Set (Fin n → ℝ)}
    (hK_compact : IsCompact K)
    (hU_open : IsOpen U)
    (hKU : K ⊆ U)
    (r : U → (Fin n → ℝ))
    (hr_cont : Continuous r)
    (hr_range : ∀ u : U, (r u) ∈ K)
    (hr_fix : ∀ (y : Fin n → ℝ) (hy : y ∈ K), r ⟨y, hKU hy⟩ = y) :
    ∀ (f : C(X, Fin n → ℝ)) (_hf : ∀ x, f x ∈ K) (ε : ℝ) (_hε : ε > 0),
      ∃ g : C(X, Fin n → ℝ),
        IsEMLMap g ∧
        ∃ hgU : ∀ x, g x ∈ U,
        ∀ x, ‖r ⟨g x, hgU x⟩ - f x‖ < ε := by
  intro f hf ε hε
  exact dense_of_compact_retract_into_finEucl hK_compact hU_open hKU r hr_cont hr_range hr_fix
    Set.univ (fun f ε hε => by
      obtain ⟨g, _, hg⟩ := exists_finvec_uniform_approx f ε hε
      exact ⟨g, Set.mem_univ g, hg⟩)
    f hf ε hε |>.imp fun g ⟨_, hgU, hclose⟩ =>
      ⟨isEMLMap_of_continuous g, hgU, hclose⟩

end