/-
  # Eccentricity-Energy Relation

  The fundamental identity connecting dynamical invariants (E, l) to
  geometric invariants (e): e² = 1 + 2El²/(mk²).
-/
import Mathlib
import Pythagorean.KeplerDefs

open Real

/-- The eccentricity-energy-angular momentum relation:
    e² = 1 + 2El²/(mk²) is the fundamental identity connecting
    dynamical invariants (E, l) to geometric invariants (e).

    When E < 0, the quantity 1 + 2El²/(mk²) is nonneg (for bound orbits
    above the minimum energy), and squaring the sqrt recovers the identity. -/
theorem eccentricity_energy_relation {m k E l : ℝ}
    (_hm : m > 0) (_hk : k > 0) (_hl : l > 0)
    (hbound : 0 ≤ 1 + 2 * E * l ^ 2 / (m * k ^ 2)) :
    (keplerEccentricity m k E l) ^ 2 = 1 + 2 * E * l ^ 2 / (m * k ^ 2) := by
  unfold keplerEccentricity
  rw [sq_sqrt hbound]

/-- For bound orbits, the eccentricity is nonneg. -/
theorem keplerEccentricity_nonneg (m k E l : ℝ) :
    0 ≤ keplerEccentricity m k E l := by
  unfold keplerEccentricity
  exact Real.sqrt_nonneg _

/-- The eccentricity squared minus 1 equals 2El²/(mk²). This is the key identity
    that links the sign of energy to the orbit type. -/
theorem eccentricity_sq_sub_one {m k E l : ℝ}
    (hm : m > 0) (hk : k > 0) (hl : l > 0)
    (hbound : 0 ≤ 1 + 2 * E * l ^ 2 / (m * k ^ 2)) :
    (keplerEccentricity m k E l) ^ 2 - 1 = 2 * E * l ^ 2 / (m * k ^ 2) := by
  rw [eccentricity_energy_relation hm hk hl hbound]
  ring