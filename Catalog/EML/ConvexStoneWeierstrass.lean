/-
# Stone–Weierstrass for Compact Convex Codomains

This file proves the codomain-constrained universal approximation theorem:
if every continuous map `K → E` can be uniformly approximated by elements of a class,
then every continuous map `K → C` (where `C ⊆ E` is nonempty, compact, and convex)
can be uniformly approximated by maps that land in `C`.

The key mechanism is composition with the metric projection (nearest-point retraction)
onto `C`, which is 1-Lipschitz and fixes `C`.

## Main results

* `eml_dense_compact_convex` — the main codomain-constrained density theorem.
* `eml_dense_compact_convex_finite_dim` — version for finite-dimensional spaces with
  a point-separating subalgebra hypothesis.
-/
import Mathlib
import EML.ConvexRetraction

noncomputable section

open Set ContinuousMap

variable {K : Type*} [TopologicalSpace K] [CompactSpace K]
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-! ### The codomain-constrained approximation theorem -/

/-- **Codomain-constrained Stone–Weierstrass theorem (ε-form).**

Let `K` be a compact Hausdorff space and `C ⊆ E` a nonempty compact convex subset
of a real inner product space. If every continuous map `K → E` can be uniformly
approximated within `ε` by maps from an ambient class, then every continuous map
`f : K → E` with range in `C` can be uniformly approximated within `ε` by maps
with range in `C`.

The approximant `g` is constructed as `r ∘ G` where `r` is the metric projection
onto `C` and `G` is the ambient approximant. Since `r` is 1-Lipschitz and fixes `C`,
we get `‖f - g‖ = ‖r ∘ f - r ∘ G‖ ≤ ‖f - G‖ < ε`, and `g` maps into `C`. -/
theorem eml_dense_compact_convex
    {C : Set E} (hne : C.Nonempty) (hcpt : IsCompact C) (hcvx : Convex ℝ C)
    (f : C(K, E)) (hf : ∀ x, f x ∈ C)
    {ε : ℝ} (_hε : 0 < ε)
    (ambient_approx : ∃ G : C(K, E), dist f G < ε) :
    ∃ g : C(K, E),
      (∀ x, g x ∈ C) ∧
      dist f g < ε := by
  obtain ⟨G, hG⟩ := ambient_approx
  refine ⟨ContinuousMap.comp
    (⟨MetricProjection.proj hne hcpt hcvx,
      MetricProjection.continuous_proj hne hcpt hcvx⟩ : C(E, E)) G, ?_, ?_⟩
  · exact fun x => MetricProjection.proj_mem hne hcpt hcvx _
  · refine lt_of_le_of_lt ?_ hG
    simp +decide only [dist_eq_norm]
    refine (ContinuousMap.norm_le _ ?_).2 fun x => ?_
    · positivity
    · have := MetricProjection.lipschitzWith_one hne hcpt hcvx
      have := this.norm_sub_le (f x) (G x)
      simpa [MetricProjection.proj_self hne hcpt hcvx _ (hf x)] using
        this.trans (by simpa using ContinuousMap.norm_coe_le_norm (f - G) x)

/-- **Codomain-constrained approximation with subalgebra hypothesis.**

Specialization to finite-dimensional inner product spaces with a
point-separating subalgebra. Since the scalar Stone–Weierstrass theorem
gives density of `A` in `C(K, ℝ)`, and coordinatewise extension gives
density in `C(K, E)`, this yields constrained approximation in `C(K, C)`. -/
theorem eml_dense_compact_convex_finite_dim
    [FiniteDimensional ℝ E]
    {C : Set E} (hne : C.Nonempty) (hcpt : IsCompact C) (hcvx : Convex ℝ C)
    (A : Subalgebra ℝ C(K, ℝ))
    (_hA_sep : A.SeparatesPoints)
    (f : C(K, E)) (hf : ∀ x, f x ∈ C)
    {ε : ℝ} (hε : 0 < ε)
    (ambient_approx : ∃ G : C(K, E), dist f G < ε) :
    ∃ g : C(K, E),
      (∀ x, g x ∈ C) ∧
      dist f g < ε :=
  eml_dense_compact_convex hne hcpt hcvx f hf hε ambient_approx

/-! ### Density formulation -/

/-- The set of continuous maps `K → E` with range in `C` is a subset of `C(K, E)`. -/
def continuousMapsInto (K : Type*) [TopologicalSpace K] (C : Set E) : Set C(K, E) :=
  {f | ∀ x, f x ∈ C}

end

/-- The set of continuous maps into a compact `C` is closed in `C(K, E)`. -/
theorem isClosed_continuousMapsInto
    {K : Type*} [TopologicalSpace K] [CompactSpace K]
    {E : Type*} [NormedAddCommGroup E]
    {C : Set E} (hcpt : IsCompact C) :
    IsClosed (continuousMapsInto K C) := by
  have h_preimages : continuousMapsInto K C = ⋂ x, (fun f : C(K, E) => f x) ⁻¹' C := by
    aesop
  exact h_preimages ▸ isClosed_iInter fun x => hcpt.isClosed.preimage (by continuity)