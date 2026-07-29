import Pythagorean.CharacterTwistedSchaffer

/-!
# Verified small cases for character-twisted power sums

The calculations in this file provide kernel-checked computational evidence
for the exact formulas proved in `CharacterTwistedSchaffer`.
-/

namespace CharacterTwistedSchaffer

/-- The first four complete periods of the linear sum have values
`-2, -4, -6, -8`, independently of `x`. -/
theorem chiFour_linear_first_four_periods (x : ℤ) :
    twistedPowerSum chiFour 1 4 x = -2 ∧
    twistedPowerSum chiFour 1 8 x = -4 ∧
    twistedPowerSum chiFour 1 12 x = -6 ∧
    twistedPowerSum chiFour 1 16 x = -8 := by
  constructor
  · simpa using chiFour_linear_four_mul 1 x
  constructor
  · simpa using chiFour_linear_four_mul 2 x
  constructor
  · simpa using chiFour_linear_four_mul 3 x
  · simpa using chiFour_linear_four_mul 4 x

/-- At `x = 0`, the first four complete periods of the quadratic sum have
values `-8, -32, -72, -128`. -/
theorem chiFour_quadratic_first_four_periods :
    twistedPowerSum chiFour 2 4 0 = -8 ∧
    twistedPowerSum chiFour 2 8 0 = -32 ∧
    twistedPowerSum chiFour 2 12 0 = -72 ∧
    twistedPowerSum chiFour 2 16 0 = -128 := by
  constructor
  · simpa using chiFour_quadratic_four_mul 1 0
  constructor
  · simpa using chiFour_quadratic_four_mul 2 0
  constructor
  · simpa using chiFour_quadratic_four_mul 3 0
  · simpa using chiFour_quadratic_four_mul 4 0

/-- A finite counterexample check: for each of the first four complete periods,
the linear twisted sum cannot be an even power. -/
theorem no_even_power_linear_first_four_periods {n : ℕ} (hn : Even n)
    (q : ℕ) (hq : q ∈ Finset.Icc 1 4) (x y : ℤ) :
    twistedPowerSum chiFour 1 (4 * q) x ≠ y ^ n := by
  exact no_even_power_chiFour_linear (by simpa using (Finset.mem_Icc.mp hq).1) hn x y

/-- A finite counterexample check in the quadratic case at `x = 0`: for each
of the first four complete periods, the sum cannot be an even power. -/
theorem no_even_power_quadratic_first_four_periods {n : ℕ} (hn : Even n)
    (q : ℕ) (hq : q ∈ Finset.Icc 1 4) (y : ℤ) :
    twistedPowerSum chiFour 2 (4 * q) 0 ≠ y ^ n := by
  have hqpos : 0 < q := by simpa using (Finset.mem_Icc.mp hq).1
  apply no_even_power_chiFour_quadratic hqpos hn
  have hqz : 0 < (q : ℤ) := by exact_mod_cast hqpos
  linarith

end CharacterTwistedSchaffer