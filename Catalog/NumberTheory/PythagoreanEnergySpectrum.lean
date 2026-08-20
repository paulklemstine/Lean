import Mathlib
import Catalog.Shared.CatalogbuildSharedIspythtriple.IsPythTriple

/-!
# A Pythagorean energy spectrum for factor certificates

This module isolates the exact algebraic core needed by an energy-based search on
Pythagorean triples.  The energy is the sum of two squared residuals: the
Pythagorean residual and the factorization residual.  Its zero set therefore
consists exactly of triples that are simultaneously Pythagorean and encode a
factorization of `N`.

The principal result, `energy_strictly_convex`, is a discrete strict-convexity
identity in the target coordinate.  In particular, every nonzero symmetric step
has strictly positive second difference.  This formulation is integral and so
avoids replacing the factorization problem by a real-valued relaxation.
-/

namespace PythagoreanEnergySpectrum

/-- Sum-of-squares energy measuring failure of a triple to be Pythagorean and
failure of its two legs to multiply to the target. -/
def energy (a b c N : ℤ) : ℤ :=
  (a * a + b * b - c * c) ^ 2 + (a * b - N) ^ 2

/-- The energy is nonnegative. -/
theorem energy_nonneg (a b c N : ℤ) : 0 ≤ energy a b c N := by
  unfold energy
  positivity

/-- The energy is symmetric in the two legs of the triple. -/
theorem energy_swap (a b c N : ℤ) : energy b a c N = energy a b c N := by
  unfold energy
  ring

/-- Exact second-difference formula for the energy spectrum in its target
coordinate. -/
theorem energy_secondDifference (a b c N h : ℤ) :
    energy a b c (N + h) + energy a b c (N - h) - 2 * energy a b c N =
      2 * h ^ 2 := by
  unfold energy
  ring

/-- **Strict convexity of the integral energy spectrum.**  At every nonzero
symmetric displacement, the midpoint energy is strictly below the average of
its two neighbours. -/
theorem energy_strictly_convex (a b c N h : ℤ) (hh : h ≠ 0) :
    2 * energy a b c N <
      energy a b c (N - h) + energy a b c (N + h) := by
  have hsquare : 0 < h ^ 2 := sq_pos_of_ne_zero hh
  have hid := energy_secondDifference a b c N h
  nlinarith

/-- Unit steps have constant positive second difference. -/
theorem energy_unit_secondDifference (a b c N : ℤ) :
    energy a b c (N + 1) + energy a b c (N - 1) - 2 * energy a b c N = 2 := by
  simpa using energy_secondDifference a b c N 1

/-- A zero-energy point supplies both equations represented by the two squared
residuals. -/
theorem energy_eq_zero_iff (a b c N : ℤ) :
    energy a b c N = 0 ↔ IsPythTriple a b c ∧ a * b = N := by
  unfold energy IsPythTriple
  constructor
  · intro h
    have h₁ : a * a + b * b - c * c = 0 := by
      nlinarith [sq_nonneg (a * a + b * b - c * c), sq_nonneg (a * b - N)]
    have h₂ : a * b - N = 0 := by
      nlinarith [sq_nonneg (a * a + b * b - c * c), sq_nonneg (a * b - N)]
    constructor <;> nlinarith
  · rintro ⟨hpt, hfactor⟩
    nlinarith

/-- Any Pythagorean factor certificate realizes the global minimum zero. -/
theorem energy_minimum_exists_of_certificate (a b c N : ℤ)
    (hpt : IsPythTriple a b c) (hfactor : a * b = N) :
    energy a b c N = 0 ∧ ∀ x y z : ℤ, energy a b c N ≤ energy x y z N := by
  have hz : energy a b c N = 0 := (energy_eq_zero_iff a b c N).2 ⟨hpt, hfactor⟩
  refine ⟨hz, ?_⟩
  intro x y z
  rw [hz]
  exact energy_nonneg x y z N

/-- A positive zero-energy certificate yields a nontrivial divisor whenever its
first leg lies strictly between `1` and `N`. -/
theorem nontrivial_factor_of_energy_eq_zero {a b c N : ℤ}
    (hzero : energy a b c N = 0) (ha : 1 < a) (haN : a < N) :
    a ∣ N ∧ 1 < a ∧ a < N := by
  have hfactor : a * b = N := (energy_eq_zero_iff a b c N).1 hzero |>.2
  refine ⟨?_, ha, haN⟩
  exact ⟨b, hfactor.symm⟩

/-- The root Berggren triple gives a concrete zero-energy factor certificate
for `12`; its first leg is the nontrivial factor `3`. -/
theorem root_certificate :
    energy 3 4 5 12 = 0 ∧ (3 : ℤ) ∣ 12 ∧ 1 < (3 : ℤ) ∧ (3 : ℤ) < 12 := by
  have hzero : energy 3 4 5 12 = 0 := by norm_num [energy]
  exact ⟨hzero, nontrivial_factor_of_energy_eq_zero hzero (by norm_num) (by norm_num)⟩

/-- For a fixed triple, the target coordinate has the unique integral energy
minimum at the product of the two legs. -/
theorem target_unique_minimizer (a b c N : ℤ) :
    energy a b c (a * b) ≤ energy a b c N ∧
      (energy a b c N = energy a b c (a * b) ↔ N = a * b) := by
  constructor
  · unfold energy
    nlinarith [sq_nonneg (a * b - N)]
  · unfold energy
    constructor
    · intro h
      have : (a * b - N) ^ 2 = 0 := by nlinarith
      nlinarith [sq_nonneg (a * b - N)]
    · rintro rfl
      rfl

end PythagoreanEnergySpectrum