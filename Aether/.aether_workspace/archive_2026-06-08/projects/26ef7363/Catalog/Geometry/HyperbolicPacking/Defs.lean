/-
Copyright (c) 2025. All rights reserved.
Hyperbolic Conformal Packing Theory: Core Definitions

This module defines the fundamental objects for analyzing packing density
in the Poincaré ball model of hyperbolic space:
- The Poincaré conformal factor λ_H(x) = 2/(1 - ‖x‖²)
- Hyperbolic weighted volume (conformal volume)
- Radial distortion between inf and sup of λ^n on a cap
- Euclidean subball radius inside a hyperbolic ball
- Abstract packing predicates

These definitions support a curvature-aware packing inequality that
quantifies how conformal distortion constrains packing density in
negatively curved spaces.
-/
import Mathlib

open Real MeasureTheory Finset

/-! ## The Poincaré Ball and Conformal Factor -/

/-- The open unit ball in `EuclideanSpace ℝ (Fin n)`, serving as the carrier
of the Poincaré disk/ball model of hyperbolic space. -/
def poincareBall (n : ℕ) : Set (EuclideanSpace ℝ (Fin n)) :=
  {x | ‖x‖ < 1}

/-- The Poincaré conformal factor `λ_H(x) = 2 / (1 - ‖x‖²)`.
This is the local scale factor of the hyperbolic metric on the Poincaré ball:
the hyperbolic metric tensor is `g_H = λ_H(x)² · g_E` where `g_E` is the
Euclidean metric. The conformal factor blows up as `‖x‖ → 1`, reflecting the
infinite extent of hyperbolic space near the ideal boundary. -/
noncomputable def poincareCF {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) : ℝ :=
  2 / (1 - ‖x‖ ^ 2)

/-- The hyperbolic weighted volume of a measurable set `Ω ⊆ B^n`.
Defined as `∫_Ω λ_H(x)^n dx`, this gives the n-dimensional hyperbolic
volume up to a constant involving the volume of the unit ball. -/
noncomputable def hyperbolicWeightedVolume
    {n : ℕ} (Ω : Set (EuclideanSpace ℝ (Fin n))) : ℝ :=
  ∫ x in Ω, (poincareCF x) ^ n

/-- The radial distortion factor for the conformal factor on a cap `‖x‖ ≤ ρ`.
Equals `(sup λ^n) / (inf λ^n) = (2/(1-ρ²))^n / 2^n = 1/(1-ρ²)^n`.
This quantifies how much the conformal weight varies across the cap. -/
noncomputable def radialDistortion {n : ℕ} (ρ : ℝ) : ℝ :=
  (1 / (1 - ρ ^ 2)) ^ n

/-- The Euclidean subball radius: a lower bound on the Euclidean radius of a
hyperbolic `r`-ball centered at a point `c` with `‖c‖ ≤ ρ < 1`.
The formula is `R(ρ,r) = (1 - ρ²) · tanh(r/2) / (1 + ρ · tanh(r/2))`.

In the Poincaré ball model, a hyperbolic ball is also a Euclidean ball
(with different center and radius). This gives the worst-case (smallest)
Euclidean radius over all centers in the cap `‖c‖ ≤ ρ`. -/
noncomputable def euclideanSubballRadius (ρ r : ℝ) : ℝ :=
  ((1 - ρ ^ 2) * Real.tanh (r / 2)) / (1 + ρ * Real.tanh (r / 2))

/-- Structure encoding a conformal metric on a subset of Euclidean space.
Consists of a carrier set, a positive conformal factor, and a proof of
positivity. This is the abstract framework that can be instantiated for
Euclidean (cf ≡ 1), spherical (stereographic), or hyperbolic (Poincaré)
geometries. -/
structure ConformalBallMetric (n : ℕ) where
  /-- The carrier set (open domain in Euclidean space). -/
  carrier : Set (EuclideanSpace ℝ (Fin n))
  /-- The conformal factor function. -/
  cf : EuclideanSpace ℝ (Fin n) → ℝ
  /-- The conformal factor is positive on the carrier. -/
  cf_pos : ∀ ⦃x⦄, x ∈ carrier → 0 < cf x

/-- The Poincaré ball as a `ConformalBallMetric`. -/
noncomputable def poincareMetric (n : ℕ) : ConformalBallMetric n where
  carrier := poincareBall n
  cf := poincareCF
  cf_pos := by
    intro x hx
    simp only [poincareBall, Set.mem_setOf_eq] at hx
    simp only [poincareCF]
    have h1 : ‖x‖ ^ 2 < 1 := by nlinarith [norm_nonneg x]
    have h2 : 0 < 1 - ‖x‖ ^ 2 := by linarith
    exact div_pos (by norm_num) h2

/-- Abstract predicate: `S` is a set of packing centers for radius `δ` inside `Ω`
if the Euclidean balls of radius `δ` centered at points of `S` are pairwise
disjoint and each center lies in `Ω`. This abstracts away the hyperbolic metric
and works purely with the Euclidean subball radii. -/
structure IsEuclideanPackingIn {n : ℕ}
    (Ω : Set (EuclideanSpace ℝ (Fin n)))
    (δ : ℝ) (S : Finset (EuclideanSpace ℝ (Fin n))) : Prop where
  /-- Every center lies in the domain. -/
  centers_mem : ∀ c ∈ S, c ∈ Ω
  /-- The balls are pairwise disjoint (centers are at least `2δ` apart). -/
  pairwise_disjoint : ∀ c₁ ∈ S, ∀ c₂ ∈ S, c₁ ≠ c₂ → 2 * δ ≤ dist c₁ c₂