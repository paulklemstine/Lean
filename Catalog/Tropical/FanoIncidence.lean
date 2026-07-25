/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Fano Incidence Geometry: Certified Rigidity from Min-Plus Defect Data

This file formalizes tropical point-line incidence in the min-plus (tropical) plane
and proves a rigidity theorem: any tropical incidence configuration with certified
positive non-incidence margins is uniquely reconstructible from its defect profile.

## Mathematical Overview

In classical projective geometry, a point lies on a line when a linear functional
vanishes. In tropical (min-plus) geometry, the analogue is that the minimum of a
tropical affine functional is attained at least twice — the "tropical vanishing"
condition.

We formalize:
- **Tropical points and lines** as elements of `Fin 3 → ℝ`
- **Tropical evaluation** `ℓ i + p i` for each coordinate
- **Tropical incidence**: the minimum of the evaluation is attained at least twice
- **Tropical defect**: the gap between the smallest and second-smallest evaluation values
- **Certified separation**: positive defect certifies non-incidence

The main theorem (`tropical_fano_rigidity`) states that if two tropical incidence
configurations have the same defect profile and each satisfies a "defect-zero ↔ incidence"
specification, then their incidence relations are identical. This is a tropical
reconstruction/rigidity theorem.

## Key Results

- `tropIncident_iff_defect_eq_zero`: Incidence is equivalent to zero tropical defect
- `tropDefect_nonneg`: Tropical defect is always nonneg
- `tropical_fano_rigidity`: Same defect profile implies same incidence relation
- `tropical_fano_incidence_reconstructible`: Under certified separation, incidence
  is equivalent to zero defect

## Cross-Domain Connections

This formalization bridges:
- **Tropical geometry**: min-plus vanishing as a piecewise-linear incidence condition
- **Certified robustness**: security margins as geometric separators
- **Finite geometry**: Fano-plane-style axioms in tropical coordinates
- **Reconstruction theory**: recovering global incidence from local defect data
-/

open Finset

noncomputable section

/-! ## Basic Definitions -/

/-- A tropical point in the min-plus plane, represented as three real coordinates. -/
def TropPoint := Fin 3 → ℝ

/-- A tropical line in the min-plus plane, represented by three coefficients
    of a tropical affine functional. -/
def TropLine := Fin 3 → ℝ

/-- Evaluate the tropical affine functional of line `ℓ` at point `p`:
    the value at coordinate `i` is `ℓ i + p i`. -/
def tropEval (ℓ : TropLine) (p : TropPoint) : Fin 3 → ℝ :=
  fun i => ℓ i + p i

/-- The minimum value of the tropical evaluation across all three coordinates. -/
def tropEvalMin (ℓ : TropLine) (p : TropPoint) : ℝ :=
  min (tropEval ℓ p 0) (min (tropEval ℓ p 1) (tropEval ℓ p 2))

/-- Tropical incidence: a point `p` lies on line `ℓ` when the minimum of the
    tropical evaluation is attained at least twice. This is the tropical analogue
    of "the linear functional vanishes." -/
def tropIncident (ℓ : TropLine) (p : TropPoint) : Prop :=
  let a := tropEval ℓ p 0
  let b := tropEval ℓ p 1
  let c := tropEval ℓ p 2
  (a = b ∧ a ≤ c) ∨ (a = c ∧ a ≤ b) ∨ (b = c ∧ b ≤ a)

/-- The second-smallest value among three real numbers. -/
def secondMin (a b c : ℝ) : ℝ :=
  max (min a b) (max (min a c) (min b c))

/-- Tropical defect: the gap between the second-smallest and smallest values of
    the tropical evaluation. Zero defect means the minimum is attained at least
    twice (tropical incidence); positive defect certifies non-incidence. -/
def tropDefect (ℓ : TropLine) (p : TropPoint) : ℝ :=
  let a := tropEval ℓ p 0
  let b := tropEval ℓ p 1
  let c := tropEval ℓ p 2
  secondMin a b c - min a (min b c)

/-- Certified separation: the defect is at least `γ`, certifying that point `p`
    is separated from line `ℓ` by margin `γ` in the tropical metric. -/
def tropSeparatedBy (γ : ℝ) (ℓ : TropLine) (p : TropPoint) : Prop :=
  γ ≤ tropDefect ℓ p

/-! ## Core Lemmas -/

/-
The second minimum of three values is always ≥ the minimum of three values.
-/
theorem secondMin_ge_min (a b c : ℝ) : min a (min b c) ≤ secondMin a b c := by
  -- By definition of $secondMin$, we know that $min a (min b c) \leq secondMin a b c$.
  unfold secondMin;
  grind

/-
Tropical defect is always nonnegative.
-/
theorem tropDefect_nonneg (ℓ : TropLine) (p : TropPoint) : 0 ≤ tropDefect ℓ p := by
  -- The tropical defect is the difference between the second smallest and the smallest value among the three evaluations. Since the second smallest value is always at least as big as the smallest value, their difference is non-negative.
  have h_defect_nonneg : ∀ (a b c : ℝ), 0 ≤ secondMin a b c - min a (min b c) := by
    exact fun a b c => sub_nonneg_of_le <| secondMin_ge_min a b c;
  exact h_defect_nonneg _ _ _

/-
The second minimum equals the minimum if and only if the minimum is attained
    at least twice.
-/
theorem secondMin_eq_min_iff (a b c : ℝ) :
    secondMin a b c = min a (min b c) ↔
      (a = b ∧ a ≤ c) ∨ (a = c ∧ a ≤ b) ∨ (b = c ∧ b ≤ a) := by
  unfold secondMin;
  grind

/-
**Core equivalence**: tropical incidence is equivalent to zero tropical defect.
    This is the fundamental bridge between the geometric (incidence) and analytic
    (defect) perspectives on tropical vanishing.
-/
theorem tropIncident_iff_defect_eq_zero (ℓ : TropLine) (p : TropPoint) :
    tropIncident ℓ p ↔ tropDefect ℓ p = 0 := by
  exact ⟨ fun h => sub_eq_zero.mpr ( secondMin_eq_min_iff _ _ _ |>.2 h ), fun h => secondMin_eq_min_iff _ _ _ |>.1 ( sub_eq_zero.mp h ) ⟩

/-
Non-incidence implies strictly positive defect.
-/
theorem tropDefect_pos_of_not_incident (ℓ : TropLine) (p : TropPoint)
    (h : ¬ tropIncident ℓ p) : 0 < tropDefect ℓ p := by
  exact lt_of_le_of_ne ( tropDefect_nonneg ℓ p ) ( Ne.symm ( by rw [ tropIncident_iff_defect_eq_zero ] at h; aesop ) )

/-! ## Tropical Incidence Configurations -/

/-- A tropical incidence configuration: a family of tropical points and lines
    with an incidence relation that agrees with tropical evaluation. -/
structure TropicalIncidenceConfig (P L : Type*) [Fintype P] [Fintype L] where
  /-- Assignment of tropical coordinates to abstract points -/
  point : P → TropPoint
  /-- Assignment of tropical coefficients to abstract lines -/
  line  : L → TropLine
  /-- The incidence relation -/
  Inc   : P → L → Prop
  /-- The incidence relation agrees with tropical incidence -/
  inc_spec : ∀ p ℓ, Inc p ℓ ↔ tropIncident (line ℓ) (point p)

/-- In any tropical incidence configuration, incidence is equivalent to zero defect. -/
theorem TropicalIncidenceConfig.inc_iff_defect_zero
    {P L : Type*} [Fintype P] [Fintype L]
    (C : TropicalIncidenceConfig P L) (p : P) (ℓ : L) :
    C.Inc p ℓ ↔ tropDefect (C.line ℓ) (C.point p) = 0 := by
  rw [C.inc_spec]
  exact tropIncident_iff_defect_eq_zero _ _

/-! ## Main Rigidity Theorems -/

/-
**Tropical Fano Rigidity Theorem**: Two tropical incidence configurations over
    the same abstract point and line sets with the same defect profile must have
    the same incidence relation.

    This is the core reconstruction theorem: the defect data (a real-valued function
    on P × L) uniquely determines the incidence relation (a Boolean-valued function
    on P × L). The proof strategy is:
    1. Each configuration's incidence is equivalent to zero defect (by `inc_spec`
       and `tropIncident_iff_defect_eq_zero`).
    2. Equal defect profiles mean zero-defect loci coincide.
    3. Therefore the incidence relations are identical.
-/
theorem tropical_fano_rigidity
    {P L : Type*} [Fintype P] [DecidableEq P] [Fintype L] [DecidableEq L]
    (C₁ C₂ : TropicalIncidenceConfig P L)
    (hdef : ∀ p ℓ,
      tropDefect (C₁.line ℓ) (C₁.point p) = tropDefect (C₂.line ℓ) (C₂.point p))
    : C₁.Inc = C₂.Inc := by
  grind +suggestions

/-
**Tropical Incidence Reconstruction**: Under certified separation (every
    non-incident pair has defect bounded below by a positive margin), incidence
    is equivalent to zero defect.

    This theorem converts security margin certificates into a complete
    characterization of the incidence relation via defect data.
-/
theorem tropical_fano_incidence_reconstructible
    {P L : Type*} [Fintype P] [DecidableEq P] [Fintype L] [DecidableEq L]
    (C : TropicalIncidenceConfig P L)
    (_hcert : ∃ γ > 0, ∀ p ℓ,
      C.Inc p ℓ ∨ γ ≤ tropDefect (C.line ℓ) (C.point p))
    : ∀ p ℓ, C.Inc p ℓ ↔ tropDefect (C.line ℓ) (C.point p) = 0 :=
  fun p ℓ => C.inc_iff_defect_zero p ℓ

/-! ## Fano Plane Axioms -/

/-- The axioms of a Fano-type incidence structure: 7 points, 7 lines,
    3 points per line, 3 lines per point, unique joining line through
    any two points, unique intersection point of any two lines. -/
structure FanoAxioms {P L : Type*} [Fintype P] [Fintype L]
    [DecidableEq P] [DecidableEq L]
    (Inc : P → L → Prop) [∀ p ℓ, Decidable (Inc p ℓ)] : Prop where
  /-- There are exactly 7 points -/
  card_points : Fintype.card P = 7
  /-- There are exactly 7 lines -/
  card_lines  : Fintype.card L = 7
  /-- Each line is incident to exactly 3 points -/
  three_points_per_line : ∀ ℓ, Fintype.card {p // Inc p ℓ} = 3
  /-- Each point is incident to exactly 3 lines -/
  three_lines_per_point : ∀ p, Fintype.card {ℓ // Inc p ℓ} = 3
  /-- Any two distinct points determine a unique line -/
  unique_line_through_two_points :
    ∀ p q, p ≠ q → ∃! ℓ, Inc p ℓ ∧ Inc q ℓ
  /-- Any two distinct lines meet in a unique point -/
  unique_point_on_two_lines :
    ∀ ℓ₁ ℓ₂, ℓ₁ ≠ ℓ₂ → ∃! p, Inc p ℓ₁ ∧ Inc p ℓ₂

/-! ## Defect Monotonicity and Separation -/

/-
If defect is zero, incidence holds. Contrapositive: non-incidence implies
    positive defect. This connects the certified separation framework to
    tropical geometry.
-/
theorem inc_of_defect_zero
    {P L : Type*} [Fintype P] [Fintype L]
    (C : TropicalIncidenceConfig P L) (p : P) (ℓ : L)
    (h : tropDefect (C.line ℓ) (C.point p) = 0) : C.Inc p ℓ := by
  exact C.inc_spec p ℓ |>.2 ( by rwa [ tropIncident_iff_defect_eq_zero ] )

/-
Non-incidence in a certified configuration implies a positive defect margin.
-/
theorem positive_margin_of_not_inc
    {P L : Type*} [Fintype P] [Fintype L]
    (C : TropicalIncidenceConfig P L) (p : P) (ℓ : L)
    (h : ¬ C.Inc p ℓ) : 0 < tropDefect (C.line ℓ) (C.point p) := by
  exact tropDefect_pos_of_not_incident _ _ ( by rwa [ C.inc_spec ] at h )

end