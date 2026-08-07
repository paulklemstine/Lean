/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Catalog.Novelty.NeuralCoding

/-!
# The neural manifold hypothesis for smooth behavioural parametrisations

`Catalog/Novelty/NeuralCoding.lean` proves `neural_manifold_dim_le_dof`: if the
population activity in `ℝ^N` is driven **linearly** by `d` behavioural degrees of
freedom, the reachable activity spans at most `d` dimensions.  Neural
parametrisations are however smooth, not linear, and this file settles what
survives.

Three different numbers must be distinguished for a smooth
`f : ℝ^d → ℝ^N`:

* the **tangent rank** at a point, `finrank (range (fderiv ℝ f x))`;
* the dimension of the **linear span** of the image, `finrank (span ℝ (range f))`;
* the (topological) dimension of the image itself.

## Results

1. `tangent_rank_le_dof` — **the local rank bound.**  The tangent rank of a
   smooth behavioural parametrisation is at most `d` at every point; this is the
   correct smooth generalisation of the linear theorem.
2. `span_image_le_of_fderiv_const` — if the derivative is *constant* (the affine
   case) the span of the image has dimension at most `d + 1`, the extra
   dimension coming from the offset.
3. `exists_smooth_span_gt_dof` — **the linear theorem does not extend to spans.**
   There is a `C^∞` curve (`d = 1`) in `ℝ²` whose image spans a `2`-dimensional
   subspace.  So a low-dimensional behavioural parametrisation does *not* bound
   the linear dimension of the recorded activity; only the tangent rank is
   controlled.
-/

namespace Catalog.Probability.NeuralCoding.Manifold

open Module Submodule

/-- **Local rank bound (smooth neural manifold hypothesis).**  If population
activity is a smooth function of `d` behavioural degrees of freedom, then at
every behavioural state the tangent space to the reachable activity has
dimension at most `d`. -/
theorem tangent_rank_le_dof (d N : ℕ) (f : (Fin d → ℝ) → (Fin N → ℝ)) (x : Fin d → ℝ) :
    finrank ℝ (LinearMap.range (fderiv ℝ f x).toLinearMap) ≤ d := by
  have h := LinearMap.finrank_range_le (fderiv ℝ f x).toLinearMap
  simpa using h

/-- **Affine parametrisations.**  If the derivative of the behavioural
parametrisation is the same linear map `L` at every state, the linear span of the
reachable activity has dimension at most `d + 1`: the behavioural degrees of
freedom plus one for the offset. -/
theorem span_image_le_of_fderiv_const (d N : ℕ) (f : (Fin d → ℝ) → (Fin N → ℝ))
    (L : (Fin d → ℝ) →L[ℝ] (Fin N → ℝ)) (hf : Differentiable ℝ f)
    (hL : ∀ x, fderiv ℝ f x = L) :
    finrank ℝ (span ℝ (Set.range f)) ≤ d + 1 := by
  -- `f` is affine: `f x = f 0 + L x`
  have hconst : ∀ x, f x - L x = f 0 - L 0 := by
    have hg : ∀ x, fderiv ℝ (fun y => f y - L y) x = 0 := by
      intro x
      have h1 : fderiv ℝ (fun y => f y - L y) x
          = fderiv ℝ f x - fderiv ℝ (fun y => L y) x :=
        fderiv_sub (hf x) L.differentiableAt
      have h2 : fderiv ℝ (fun y => L y) x = L := L.hasFDerivAt.fderiv
      rw [h1, h2, hL x, sub_self]
    have := is_const_of_fderiv_eq_zero (f := fun y => f y - L y)
      (by exact hf.sub L.differentiable) hg
    intro x
    exact this x 0
  have hL0 : L 0 = 0 := by simp
  have hf_eq : ∀ x, f x = f 0 + L x := by
    intro x
    have := hconst x
    rw [hL0, sub_zero] at this
    linear_combination (norm := module) this
  -- the image lies in the range of a linear map from a `(d+1)`-dimensional space
  let M : (ℝ × (Fin d → ℝ)) →ₗ[ℝ] (Fin N → ℝ) :=
    (LinearMap.fst ℝ ℝ (Fin d → ℝ)).smulRight (f 0) +
      L.toLinearMap.comp (LinearMap.snd ℝ ℝ (Fin d → ℝ))
  have hrange : Set.range f ⊆ ↑(LinearMap.range M) := by
    rintro y ⟨x, rfl⟩
    refine ⟨(1, x), ?_⟩
    simp only [M, LinearMap.add_apply, LinearMap.smulRight_apply, LinearMap.fst_apply,
      LinearMap.coe_comp, Function.comp_apply, LinearMap.snd_apply,
      ContinuousLinearMap.coe_coe, one_smul]
    exact (hf_eq x).symm
  have hspan : span ℝ (Set.range f) ≤ LinearMap.range M := span_le.mpr hrange
  calc finrank ℝ (span ℝ (Set.range f)) ≤ finrank ℝ (LinearMap.range M) :=
        Submodule.finrank_mono hspan
    _ ≤ finrank ℝ (ℝ × (Fin d → ℝ)) := LinearMap.finrank_range_le M
    _ = d + 1 := by simp [add_comm]

/-- The moment curve `t ↦ (t, t²)`, a smooth one-parameter behavioural
parametrisation of activity in `ℝ²`. -/
noncomputable def momentCurve : ℝ → (Fin 2 → ℝ) := fun t i => t ^ (i.val + 1)

theorem contDiff_momentCurve : ContDiff ℝ (⊤ : ℕ∞) momentCurve := by
  rw [contDiff_pi]
  intro i
  exact contDiff_id.pow _

/-- **The linear neural-manifold theorem fails for spans of smooth images.**
There is a `C^∞` curve — one behavioural degree of freedom — whose image in `ℝ²`
spans a subspace of dimension `2 > 1`.  Hence for smooth parametrisations only
the *tangent* rank (`tangent_rank_le_dof`) is bounded by the number of degrees of
freedom, not the dimension of the linear span of the recorded activity. -/
theorem exists_smooth_span_gt_dof :
    ∃ f : ℝ → (Fin 2 → ℝ), ContDiff ℝ (⊤ : ℕ∞) f ∧
      1 < finrank ℝ (span ℝ (Set.range f)) := by
  refine ⟨momentCurve, contDiff_momentCurve, ?_⟩
  have hli : LinearIndependent ℝ ![momentCurve 1, momentCurve 2] := by
    rw [LinearIndependent.pair_iff]
    intro s t hst
    have h0 := congrFun hst 0
    have h1 := congrFun hst 1
    simp only [momentCurve, Pi.add_apply, Pi.smul_apply, Pi.zero_apply, smul_eq_mul] at h0 h1
    norm_num at h0 h1
    constructor <;> linarith
  have hcard : finrank ℝ (span ℝ (Set.range ![momentCurve 1, momentCurve 2])) = 2 := by
    rw [finrank_span_eq_card hli]
    simp
  have hsub : span ℝ (Set.range ![momentCurve 1, momentCurve 2]) ≤
      span ℝ (Set.range momentCurve) := by
    apply span_le.mpr
    rintro y ⟨i, rfl⟩
    fin_cases i
    · exact subset_span ⟨1, rfl⟩
    · exact subset_span ⟨2, rfl⟩
  have := Submodule.finrank_mono hsub
  omega

end Catalog.Probability.NeuralCoding.Manifold