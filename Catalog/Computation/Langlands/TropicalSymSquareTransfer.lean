import Mathlib
import Tropical.Langlands.SatakeIsomorphism

/-!
# Tropical shadow of the Sym² transfer GL₂ → GL₃

This file connects the symmetric-square Satake transfer to the catalog's
tropical Satake combinatorics (`Tropical.Langlands.SatakeIsomorphism`).

In tropical (max-plus) Satake coordinates `(x₁, x₂) = (log α, log β)`, the Sym²
lift `{α, β} ↦ {α², αβ, β²}` becomes the additive map
`{x₁, x₂} ↦ {2x₁, x₁+x₂, 2x₂}`.  We show that the tropical first and total
elementary symmetric functions of the *lifted* parameters are scalar multiples of
those of the *original* parameters, reusing `TropicalSatake.tropE1` (max) and
`TropicalSatake.tropE2` (sum) from the catalog:

* `tropical_sym2_e1`  — `max(2x₁, x₁+x₂, 2x₂) = 2 · tropE1(x₁,x₂)`.
* `tropical_sym2_total` — `(2x₁)+(x₁+x₂)+(2x₂) = 3 · tropE2(x₁,x₂)`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): the Sym² Satake transfer should have a clean tropical
limit in which the multiplicative parameter map becomes the additive doubling
`x ↦ 2x` on max-plus coordinates, and the catalog's tropical symmetric functions
should transform by simple scalars.
EXPERIMENT (Experimenter): computed the max and the sum of `{2x₁, x₁+x₂, 2x₂}`;
found `max = 2·max(x₁,x₂)` and `sum = 3·(x₁+x₂)`.
ANALYSIS (Analyst): the factor `2` (resp. `3`) is the *degree* of `Sym²` acting
on `tropE1` (resp. on the total `tropE2`); the maximum is governed by the largest
original coordinate doubled, mirroring the dominance of `α²` (or `β²`) among the
classical Satake parameters of the lift.
CRITIQUE (Critic): the `e1` identity is genuinely nonlinear (a `max` of three
affine forms) and needs a case split on `x₁ ≤ x₂`; it is not a definitional
rewrite, so it survives the anti-trivial guardrail while reusing real catalog
definitions.
SYNTHESIS (PI): the GL₂→GL₃ Sym² transfer is compatible with the catalog
tropical Satake isomorphism: it acts by degree-scaling on tropical symmetric
functions.
-- !-- end Lab Notes -- !--
-/

namespace Langlands.TropicalSymSquare

/-- **Tropical Sym² transfer, first symmetric function.** The tropical max of the
Sym² parameters `{2x₁, x₁+x₂, 2x₂}` equals twice the catalog tropical first
elementary symmetric function `TropicalSatake.tropE1 = max`. -/
theorem tropical_sym2_e1 (x₁ x₂ : ℝ) :
    max (max (2 * x₁) (x₁ + x₂)) (2 * x₂) = 2 * TropicalSatake.tropE1 x₁ x₂ := by
  unfold TropicalSatake.tropE1
  rcases le_total x₁ x₂ with h | h
  · have hx : max x₁ x₂ = x₂ := max_eq_right h
    rw [hx, max_eq_right (by linarith : 2 * x₁ ≤ x₁ + x₂),
      max_eq_right (by linarith : x₁ + x₂ ≤ 2 * x₂)]
  · have hx : max x₁ x₂ = x₁ := max_eq_left h
    rw [hx, max_eq_left (by linarith : x₁ + x₂ ≤ 2 * x₁),
      max_eq_left (by linarith : 2 * x₂ ≤ 2 * x₁)]

/-- **Tropical Sym² transfer, total degree.** The sum of the Sym² parameters
`{2x₁, x₁+x₂, 2x₂}` equals three times the catalog tropical second elementary
symmetric function `TropicalSatake.tropE2 = (· + ·)`. -/
theorem tropical_sym2_total (x₁ x₂ : ℝ) :
    (2 * x₁) + (x₁ + x₂) + (2 * x₂) = 3 * TropicalSatake.tropE2 x₁ x₂ := by
  unfold TropicalSatake.tropE2
  ring

end Langlands.TropicalSymSquare