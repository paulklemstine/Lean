/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Density Preservation Under Continuous Retraction

This file proves that uniform approximation density is preserved when composing with
a continuous retraction. This is a key bridge theorem for tropical EML approximation:
if we can approximate a target function in ambient tropical space, composing with a
continuous retraction onto a tropical polytope preserves the approximation (with a
controlled error depending on the modulus of uniform continuity of the retraction).

## Main Results

* `dense_under_continuous_retraction` — If `A` is uniformly ε-dense around `g₀` in
  `X → Y`, then `r ∘ A` is uniformly ε'-dense around `r ∘ g₀` in `X → Z`, where the
  error bound comes from the uniform continuity of `r`.

* `dense_under_lipschitz_retraction` — A sharper version when `r` is Lipschitz.
-/

open Set Metric TopologicalSpace Filter
open scoped Topology

/-! ### Abstract density preservation under retraction -/

/-- If `g₀ : X → Y` can be uniformly approximated by elements of `A`, and `r : Y → Z`
is uniformly continuous, then `r ∘ g₀` can be uniformly approximated by elements
of `r ∘ A`. -/
theorem dense_under_continuous_retraction
    {X Y Z : Type*}
    [TopologicalSpace X] [CompactSpace X]
    [PseudoMetricSpace Y] [PseudoMetricSpace Z]
    (A : Set (X → Y))
    (r : Y → Z)
    (hr_unif : UniformContinuous r)
    (f : X → Z)
    (g0 : X → Y)
    (hf : f = r ∘ g0)
    (hdense : ∀ ε > 0, ∃ g ∈ A, ∀ x, dist (g x) (g0 x) ≤ ε) :
    ∀ ε > 0, ∃ h ∈ (fun g => r ∘ g) '' A, ∀ x, dist (h x) (f x) ≤ ε := by
  intro ε hε
  rw [Metric.uniformContinuous_iff] at hr_unif
  obtain ⟨δ, hδ_pos, hδ⟩ := hr_unif ε hε
  obtain ⟨g, hgA, hg_close⟩ := hdense (δ / 2) (by linarith)
  refine ⟨r ∘ g, ⟨g, hgA, rfl⟩, fun x => ?_⟩
  subst hf
  have h1 : dist (g x) (g0 x) < δ := by linarith [hg_close x]
  exact le_of_lt (hδ h1)

/-- Variant with explicit set description. -/
theorem dense_under_continuous_retraction'
    {X Y Z : Type*}
    [TopologicalSpace X] [CompactSpace X]
    [PseudoMetricSpace Y] [PseudoMetricSpace Z]
    (A : Set (X → Y))
    (r : Y → Z)
    (hr_unif : UniformContinuous r)
    (S : Set (X → Z))
    (hS : S = (fun g => r ∘ g) '' A)
    (f : X → Z)
    (g0 : X → Y)
    (hf : f = r ∘ g0)
    (hdense : ∀ ε > 0, ∃ g ∈ A, ∀ x, dist (g x) (g0 x) ≤ ε) :
    ∀ ε > 0, ∃ h ∈ S, ∀ x, dist (h x) (f x) ≤ ε := by
  subst hS
  exact dense_under_continuous_retraction A r hr_unif f g0 hf hdense

/-- If `r` is Lipschitz with constant `C`, the retraction preserves density with
a linear error amplification factor. -/
theorem dense_under_lipschitz_retraction
    {X Y Z : Type*}
    [PseudoMetricSpace Y] [PseudoMetricSpace Z]
    (A : Set (X → Y))
    (r : Y → Z)
    (C : ℝ)
    (hC : 0 ≤ C)
    (hr_lip : LipschitzWith ⟨C, hC⟩ r)
    (f : X → Z)
    (g0 : X → Y)
    (hf : f = r ∘ g0)
    (hdense : ∀ ε > 0, ∃ g ∈ A, ∀ x, dist (g x) (g0 x) ≤ ε) :
    ∀ ε > 0, ∃ h ∈ (fun g => r ∘ g) '' A, ∀ x, dist (h x) (f x) ≤ C * ε := by
  intro ε hε
  obtain ⟨g, hgA, hg_close⟩ := hdense ε hε
  refine ⟨r ∘ g, ⟨g, hgA, rfl⟩, fun x => ?_⟩
  subst hf
  show dist (r (g x)) (r (g0 x)) ≤ C * ε
  have h1 := hr_lip.dist_le_mul (g x) (g0 x)
  simp only [NNReal.coe_mk] at h1
  exact h1.trans (mul_le_mul_of_nonneg_left (hg_close x) hC)

/-- A retraction onto `K` ensures the approximant maps into `K`. -/
theorem retraction_approximant_maps_into
    {X Y : Type*}
    (K : Set Y)
    (r : Y → Y)
    (hr_maps : MapsTo r univ K)
    (g : X → Y) :
    MapsTo (r ∘ g) univ K := by
  intro x _
  exact hr_maps (mem_univ _)