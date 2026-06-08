/-
  Newton-Hodge Polygon Framework for 2-Dimensional Filtered φ-Modules

  This file establishes the foundational definitions for studying the interplay
  between Newton and Hodge polygons in the 2-dimensional setting. The key insight
  is that the monodromy defect δ = s₁ - w₁ serves as a universal parameter
  governing the space between ordinary and supersingular representations.

  In p-adic Hodge theory, a filtered φ-module encodes the Galois-theoretic data
  of a p-adic representation. The Newton polygon (from the Frobenius action)
  and the Hodge polygon (from the filtration) must satisfy the weak admissibility
  condition: Newton lies on or above Hodge with matching endpoints.

  In dimension 2, this entire theory collapses to a single real parameter δ ∈ [0, γ/2]
  where γ = w₂ - w₁ is the Hodge gap. This dimensional reduction reveals
  unexpected structure: the admissibility space is a tropical interval,
  and the polygon gap area equals the defect.
-/

import Mathlib

open Real

/-! ## Core Structures -/

/-- A 2-dimensional filtered φ-module, specified by its Hodge-Tate weights
    w₁ ≤ w₂ and Newton slopes s₁ ≤ s₂, with the endpoint matching condition
    s₁ + s₂ = w₁ + w₂ (which encodes that the determinant is crystalline). -/
structure FilteredPhiModule2 where
  w₁ : ℝ
  w₂ : ℝ
  s₁ : ℝ
  s₂ : ℝ
  hodge_le : w₁ ≤ w₂
  newton_le : s₁ ≤ s₂
  endpoint_match : s₁ + s₂ = w₁ + w₂

namespace FilteredPhiModule2

/-! ## Fundamental Invariants -/

/-- The monodromy defect δ = s₁ - w₁, measuring the gap between Newton and Hodge
    at the midpoint. This is the universal parameter of the theory. -/
noncomputable def defect (M : FilteredPhiModule2) : ℝ := M.s₁ - M.w₁

/-- The Hodge gap γ = w₂ - w₁, measuring the spread of Hodge-Tate weights. -/
noncomputable def hodgeGap (M : FilteredPhiModule2) : ℝ := M.w₂ - M.w₁

/-- The Newton spread σ = s₂ - s₁, measuring the spread of Newton slopes. -/
noncomputable def newtonSpread (M : FilteredPhiModule2) : ℝ := M.s₂ - M.s₁

/-- The Hodge polygon as a piecewise linear function on [0, 2].
    H(x) = w₁ · x for x ∈ [0,1] and w₁ + w₂ · (x - 1) for x ∈ [1,2]. -/
noncomputable def hodgePolygon (M : FilteredPhiModule2) (x : ℝ) : ℝ :=
  if x ≤ 1 then M.w₁ * x else M.w₁ + M.w₂ * (x - 1)

/-- The Newton polygon as a piecewise linear function on [0, 2].
    N(x) = s₁ · x for x ∈ [0,1] and s₁ + s₂ · (x - 1) for x ∈ [1,2]. -/
noncomputable def newtonPolygon (M : FilteredPhiModule2) (x : ℝ) : ℝ :=
  if x ≤ 1 then M.s₁ * x else M.s₁ + M.s₂ * (x - 1)

/-- The polygon gap function G(x) = N(x) - H(x), a tent function peaking at x = 1. -/
noncomputable def polygonGap (M : FilteredPhiModule2) (x : ℝ) : ℝ :=
  M.newtonPolygon x - M.hodgePolygon x

/-! ## Classification Predicates -/

/-- A module is weakly admissible if Newton ≥ Hodge (equivalently, δ ≥ 0). -/
def WeaklyAdmissible (M : FilteredPhiModule2) : Prop := M.w₁ ≤ M.s₁

/-- A module is ordinary if Newton = Hodge (equivalently, δ = 0). -/
def IsOrdinary (M : FilteredPhiModule2) : Prop := M.s₁ = M.w₁

/-- A module is supersingular if the Newton slopes are equal (equivalently, δ = γ/2). -/
def IsSupersingular (M : FilteredPhiModule2) : Prop := M.s₁ = M.s₂

/-! ## Defect Filtration -/

/-- The defect class of a module: ordinary (δ=0), generic (0 < δ < γ/2),
    or supersingular (δ = γ/2). This stratifies the admissibility space. -/
inductive DefectClass where
  | ordinary       : DefectClass
  | generic        : DefectClass
  | supersingular  : DefectClass
  deriving DecidableEq, Repr

/-- Classify a module by its defect relative to the Hodge gap.
    Uses classical logic since we're comparing real numbers. -/
noncomputable def classify (M : FilteredPhiModule2) : DefectClass :=
  if M.defect = 0 then DefectClass.ordinary
  else if M.defect = M.hodgeGap / 2 then DefectClass.supersingular
  else DefectClass.generic

/-! ## Tropical Structure -/

/-- The tropical distance between two filtered φ-modules (with possibly different
    Hodge weights) is the absolute difference of their defects.
    This measures how "differently positioned" they are in the Newton-Hodge gap. -/
noncomputable def tropicalDist (M₁ M₂ : FilteredPhiModule2) : ℝ :=
  |M₁.defect - M₂.defect|

/-- The normalized defect δ/γ ∈ [0, 1/2] (when γ > 0), giving the position
    within the admissibility interval as a fraction. -/
noncomputable def normalizedDefect (M : FilteredPhiModule2) : ℝ :=
  if M.hodgeGap = 0 then 0 else M.defect / M.hodgeGap

end FilteredPhiModule2