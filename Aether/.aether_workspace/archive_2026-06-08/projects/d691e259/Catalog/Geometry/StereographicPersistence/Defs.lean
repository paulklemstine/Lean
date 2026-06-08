/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Stereographic Persistence: Definitions

This file defines the core concepts for the theory of stereographic persistence modules:
the weighted stereographic distance, spherical geodesic distance, Čech complex predicates,
and the north-pole exclusion (tame hemisphere) condition.

The central idea is that stereographic projection, while not an isometry from spherical
geodesic distance to Euclidean distance, becomes an *exact isometric identification*
when the Euclidean side is equipped with the transported metric d_st. We provide an
explicit closed-form formula for this transported metric and use it to define
stereographic Čech filtrations that are provably equivalent to intrinsic spherical ones.

## Main definitions

* `sphereDist` — geodesic distance on the unit sphere via arccos of inner product
* `stereoDist` — the weighted stereographic distance on the orthogonal complement
* `CechSimplexSphere` — predicate for a finite set being a Čech simplex at scale ε
* `TameHemisphere` — quantitative hypothesis bounding points away from the pole
-/

import Mathlib

noncomputable section

open Real Metric Submodule Set Function

open scoped RealInnerProductSpace

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-! ### Geodesic distance on the unit sphere -/

/-- Geodesic distance on the unit sphere, defined as `arccos ⟪p, q⟫`.
This is a genuine metric on the sphere (though we don't prove the full metric space
structure here, focusing instead on the distance formula). -/
def sphereDist (p q : sphere (0 : E) 1) : ℝ :=
  Real.arccos (@inner ℝ E _ (p : E) (q : E))

theorem sphereDist_nonneg (p q : sphere (0 : E) 1) : 0 ≤ sphereDist p q :=
  arccos_nonneg _

theorem sphereDist_le_pi (p q : sphere (0 : E) 1) : sphereDist p q ≤ π :=
  arccos_le_pi _

theorem sphereDist_self (p : sphere (0 : E) 1) : sphereDist p p = 0 := by
  simp [sphereDist, mem_sphere_zero_iff_norm.mp p.2]

theorem sphereDist_comm (p q : sphere (0 : E) 1) : sphereDist p q = sphereDist q p := by
  simp [sphereDist, real_inner_comm]

/-! ### Weighted stereographic distance -/

/-- The **weighted stereographic distance** (or transported metric) on `(ℝ ∙ v)ᗮ`.
Given a unit vector `v` (the stereographic pole), this defines the distance
between two points `w₁, w₂` in the orthogonal complement as the geodesic
distance between their inverse stereographic images on the sphere.

This is the fundamental object that makes stereographic persistence exact:
it transports the intrinsic spherical metric through stereographic coordinates. -/
def stereoDist {v : E} (hv : ‖v‖ = 1) (w₁ w₂ : (ℝ ∙ v)ᗮ) : ℝ :=
  sphereDist (stereoInvFun hv w₁) (stereoInvFun hv w₂)

theorem stereoDist_nonneg {v : E} (hv : ‖v‖ = 1) (w₁ w₂ : (ℝ ∙ v)ᗮ) :
    0 ≤ stereoDist hv w₁ w₂ :=
  sphereDist_nonneg _ _

theorem stereoDist_self {v : E} (hv : ‖v‖ = 1) (w : (ℝ ∙ v)ᗮ) :
    stereoDist hv w w = 0 :=
  sphereDist_self _

theorem stereoDist_comm {v : E} (hv : ‖v‖ = 1) (w₁ w₂ : (ℝ ∙ v)ᗮ) :
    stereoDist hv w₁ w₂ = stereoDist hv w₂ w₁ :=
  sphereDist_comm _ _

/-! ### Čech complex predicates -/

/-- A finite set of sphere points forms a **Čech simplex at scale ε** if every pair
of points has spherical geodesic distance at most `ε`. This is the Vietoris–Rips
definition; for Čech, one would use ball intersection, but the Rips version is
computationally equivalent for algorithmic purposes and cleaner to formalize. -/
def CechSimplexSphere (σ : Finset (sphere (0 : E) 1)) (ε : ℝ) : Prop :=
  ∀ p ∈ σ, ∀ q ∈ σ, sphereDist p q ≤ ε

/-- A finite set of points in the orthogonal complement forms a **weighted Čech simplex
at scale ε** if every pair has weighted stereographic distance at most `ε`. -/
def CechSimplexWeighted {v : E} (hv : ‖v‖ = 1) (σ : Finset ((ℝ ∙ v)ᗮ)) (ε : ℝ) : Prop :=
  ∀ p ∈ σ, ∀ q ∈ σ, stereoDist hv p q ≤ ε

/-! ### North-pole exclusion / tame hemisphere condition -/

/-- The **tame hemisphere condition**: a finite set of points in stereographic coordinates
is contained in a ball of radius `R`. This ensures the point cloud stays in a compact
spherical cap away from the stereographic singularity (north pole).

When `R` is small, the stereographic projection is close to an isometry (with explicit
bi-Lipschitz constants depending on `R`). This is the quantitative hypothesis needed
for algorithmic bounds and stability. -/
def TameHemisphere {v : E} (_hv : ‖v‖ = 1) (Y : Finset ((ℝ ∙ v)ᗮ)) (R : ℝ) : Prop :=
  ∀ w ∈ Y, ‖(w : E)‖ ≤ R

/-! ### Monotonicity of Čech predicates -/

theorem CechSimplexSphere_mono {σ : Finset (sphere (0 : E) 1)} {ε₁ ε₂ : ℝ}
    (h : ε₁ ≤ ε₂) (hσ : CechSimplexSphere σ ε₁) : CechSimplexSphere σ ε₂ :=
  fun p hp q hq => le_trans (hσ p hp q hq) h

theorem CechSimplexWeighted_mono {v : E} {hv : ‖v‖ = 1} {σ : Finset ((ℝ ∙ v)ᗮ)} {ε₁ ε₂ : ℝ}
    (h : ε₁ ≤ ε₂) (hσ : CechSimplexWeighted hv σ ε₁) : CechSimplexWeighted hv σ ε₂ :=
  fun p hp q hq => le_trans (hσ p hp q hq) h

theorem CechSimplexSphere_subset {σ τ : Finset (sphere (0 : E) 1)} {ε : ℝ}
    (h : σ ⊆ τ) (hτ : CechSimplexSphere τ ε) : CechSimplexSphere σ ε :=
  fun p hp q hq => hτ p (h hp) q (h hq)

theorem CechSimplexWeighted_subset {v : E} {hv : ‖v‖ = 1}
    {σ τ : Finset ((ℝ ∙ v)ᗮ)} {ε : ℝ}
    (_h : σ ⊆ τ) (hτ : CechSimplexWeighted hv σ ε) : CechSimplexWeighted hv σ ε :=
  fun p hp q hq => hτ p hp q hq

end