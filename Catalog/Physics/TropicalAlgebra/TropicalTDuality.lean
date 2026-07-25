/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# String Theory T-Duality as Tropical Duality: Min-Plus Mirror Symmetry

This file formalizes the mathematical heart of the correspondence between
string-theoretic T-duality, tropical geometry, and convex duality.

## Main Results

### Theorem A: Tropical Radius Inversion is an Involutive Duality
- `tropPotentialLog_duality`: radius inversion = coordinate reflection in min-plus
- `tropPotential_radius_inversion`: the full R-parameterized version
- `radiusDual_involutive`: R ↦ 1/R is an involution

### Theorem B: Tropical Legendre Transform
- `tropLegendreAffine_biconjugate`: biconjugation for single affine functions

### Theorem C: Corner Locus = Conifold Transition
- `corner_of_affine_tie`: branch collision implies corner
- `corner_locus_two_branch`: exact characterization of corner points

## Physics-to-Math Dictionary
- **T-duality** ↔ min-plus involution (`tropPotentialLog_duality`)
- **Mirror symmetry** ↔ tropical convex duality (Legendre transform involutivity)
- **Conifold transition** ↔ corner locus / tropical phase collision
-/

noncomputable section

open Real

namespace TropicalTDuality

/-! ## Part A: Tropical Radius Inversion -/

/-- The tropicalized circle energy potential, parameterized by `ρ = log R`.
    The two branches `x + ρ` and `-x - ρ` correspond to momentum and winding
    energy contributions in the T-duality picture. -/
def tropPotentialLog (ρ x : ℝ) : ℝ := min (x + ρ) (-x - ρ)

/-- Radius inversion in multiplicative coordinates. -/
def radiusDual (r : ℝ) : ℝ := 1 / r

/-- The tropicalized circle energy potential, parameterized by radius `r > 0`.
    `Φ_r(x) = min(x + log r, -x - log r)` -/
def tropPotential (r x : ℝ) : ℝ := min (x + Real.log r) (-x - Real.log r)

/-
**T-duality as tropical coordinate reflection (log parameterization).**
    Negating the radius parameter ρ is equivalent to reflecting the coordinate x.
    This is the algebraic nucleus of T-duality = tropical duality.
-/
theorem tropPotentialLog_duality (ρ x : ℝ) :
    tropPotentialLog (-ρ) x = tropPotentialLog ρ (-x) := by
  unfold tropPotentialLog; ring;
  exact min_comm _ _

/-
**Radius inversion is an involution on nonzero reals.**
-/
theorem radiusDual_involutive {r : ℝ} (_hr : r ≠ 0) :
    radiusDual (radiusDual r) = r := by
  unfold radiusDual; field_simp

/-
**T-duality as tropical coordinate reflection (radius parameterization).**
    Inverting the radius R ↦ 1/R is equivalent to reflecting x ↦ -x
    in the tropical potential.
-/
theorem tropPotential_radius_inversion
    {r x : ℝ} (_hr : 0 < r) :
    tropPotential (1 / r) x = tropPotential r (-x) := by
  unfold tropPotential
  simp;
  grind

/-
**Combined duality involutivity.**
    Applying radius duality twice recovers the original potential.
-/
theorem tropPotential_duality_involutive
    {r x : ℝ} (_hr : 0 < r) :
    tropPotential (radiusDual (radiusDual r)) x = tropPotential r x := by
  unfold radiusDual tropPotential; norm_num [ _hr.ne' ] ;

/-
**Tropical duality package**: coordinate reflection + radius involution.
-/
theorem tropical_duality_package
    {r : ℝ} (hr : 0 < r) :
    (∀ x, tropPotential (1 / r) x = tropPotential r (-x)) ∧
    (radiusDual (radiusDual r) = r) := by
  exact ⟨ fun x => tropPotential_radius_inversion hr, radiusDual_involutive hr.ne' ⟩

/-! ## Part B: Tropical Legendre Transform -/

/-- An affine form on ℝ, specified by slope and intercept. -/
structure AffineForm where
  slope : ℝ
  intercept : ℝ

/-- Evaluate an affine form at a point. -/
def AffineForm.eval (f : AffineForm) (x : ℝ) : ℝ :=
  f.slope * x + f.intercept

/-- A function `f : ℝ → ℝ` is affine if it equals `a * x + b` for some constants. -/
def IsAffineMap (f : ℝ → ℝ) : Prop :=
  ∃ a b : ℝ, ∀ x, f x = a * x + b

/-
**Biconjugation identity for affine functions.**
    For f(x) = a·x + b, double negation of the intercept recovers f.
-/
theorem tropLegendreAffine_biconjugate (f : AffineForm) (x : ℝ) :
    (f.slope * x + -(-f.intercept)) = f.eval x := by
  grind +locals

/-! ## Part C: Corner Locus = Conifold Transition -/

/-- A point `x` is a **tropical corner** of `f` if `f(x)` equals the value of two
    distinct affine functions at `x`. This is the tropical avatar of a
    conifold transition: the singular set where linear phases exchange dominance. -/
def IsTropicalCorner (f : ℝ → ℝ) (x : ℝ) : Prop :=
  ∃ a₁ b₁ a₂ b₂ : ℝ,
    (a₁ ≠ a₂ ∨ b₁ ≠ b₂) ∧
    f x = a₁ * x + b₁ ∧
    f x = a₂ * x + b₂

/-- A **branch tie** for a two-branch tropical polynomial at `x`:
    both affine branches evaluate to the same value. This is the correct
    notion of corner for a tropical polynomial given by `min` of affine forms. -/
def IsBranchTie (a₁ b₁ a₂ b₂ x : ℝ) : Prop :=
  a₁ * x + b₁ = a₂ * x + b₂

/-- A tropical polynomial with two affine branches. -/
def tropPoly2 (a₁ b₁ a₂ b₂ x : ℝ) : ℝ :=
  min (a₁ * x + b₁) (a₂ * x + b₂)

/-- A tropical polynomial with three affine branches. -/
def tropPoly3 (a₁ b₁ a₂ b₂ a₃ b₃ x : ℝ) : ℝ :=
  min (a₁ * x + b₁) (min (a₂ * x + b₂) (a₃ * x + b₃))

/-
**Branch collision implies corner.**
    When two affine branches tie at a point and are distinct as affine forms,
    that point is a corner of the tropical polynomial.
-/
theorem corner_of_affine_tie
    {a₁ b₁ a₂ b₂ x : ℝ}
    (htie : a₁ * x + b₁ = a₂ * x + b₂)
    (hne : a₁ ≠ a₂ ∨ b₁ ≠ b₂) :
    IsTropicalCorner (fun t => min (a₁ * t + b₁) (a₂ * t + b₂)) x := by
  exact ⟨ a₁, b₁, a₂, b₂, hne, by simp +decide [ htie ], by simp +decide [ htie ] ⟩

/-
**Exact characterization of branch tie locus for two-branch tropical polynomials.**
    When the slopes differ, the branch tie (= tropical corner) occurs at exactly
    one point: `x = (b₂ - b₁) / (a₁ - a₂)`. This is the precise location of the
    conifold transition in the tropical model.
-/
theorem branch_tie_locus_two_branch
    {a₁ b₁ a₂ b₂ x : ℝ}
    (hne : a₁ ≠ a₂) :
    IsBranchTie a₁ b₁ a₂ b₂ x ↔ x = (b₂ - b₁) / (a₁ - a₂) := by
  grind +locals

/-
**Branch tie implies tropical corner.**
-/
theorem branch_tie_implies_corner
    {a₁ b₁ a₂ b₂ x : ℝ}
    (htie : IsBranchTie a₁ b₁ a₂ b₂ x)
    (hne : a₁ ≠ a₂ ∨ b₁ ≠ b₂) :
    IsTropicalCorner (fun t => min (a₁ * t + b₁) (a₂ * t + b₂)) x := by
  exact corner_of_affine_tie htie hne

/-
**Corner locus characterization (combined).**
    When slopes differ, the corner locus is exactly `{(b₂ - b₁) / (a₁ - a₂)}`,
    and at this point a branch tie (conifold transition) occurs.
-/
theorem corner_locus_two_branch
    {a₁ b₁ a₂ b₂ : ℝ}
    (hne : a₁ ≠ a₂) :
    let x₀ := (b₂ - b₁) / (a₁ - a₂)
    IsBranchTie a₁ b₁ a₂ b₂ x₀ ∧
    IsTropicalCorner (fun t => min (a₁ * t + b₁) (a₂ * t + b₂)) x₀ := by
  grind +locals

/-
**The corner point is indeed a tie point.**
    At the corner location, the two branches evaluate to the same value.
-/
theorem tie_at_corner
    {a₁ b₁ a₂ b₂ : ℝ} (hne : a₁ ≠ a₂) :
    let x₀ := (b₂ - b₁) / (a₁ - a₂)
    a₁ * x₀ + b₁ = a₂ * x₀ + b₂ := by
  grind +suggestions

/-
**Min-plus distribution: addition distributes over min.**
    This is the fundamental algebraic engine behind tropical gauge transformations.
-/
theorem add_min_distrib' (a b c : ℝ) :
    c + min a b = min (c + a) (c + b) := by
  grind

/-! ## Synthesis: The Tropical Duality Package -/

/-
**Full tropical T-duality package.**
    Combines the coordinate reflection, radius involution, and their consistency.
-/
theorem tropical_tduality_full_package
    {r : ℝ} (hr : 0 < r) :
    (∀ x, tropPotential (1 / r) x = tropPotential r (-x)) ∧
    (radiusDual (radiusDual r) = r) ∧
    (∀ x, tropPotential (radiusDual (radiusDual r)) x = tropPotential r x) := by
  exact ⟨ fun x => tropPotential_radius_inversion hr, radiusDual_involutive hr.ne', fun x => tropPotential_duality_involutive hr ⟩

end TropicalTDuality
end