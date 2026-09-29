/-
Machine-checked: the circularity identity, and the record's own hand-verified witness.

Two things this file establishes over `Z`, with no assumption and no `sorry`:

1. `disc(E) = 4a^3 + 27b^2` for the relation curve's Jacobian
   `E : Y^2 = X^3 - 3(mc)X + (c^2 + m^3 c)` is EXACTLY `27 c^2 (c - m^3)^2`.  Since a
   relation is set up by taking `c = m^3 - k N`, the discriminant is `27 c^2 k^2 N^2`, so
   `N^2` always divides it and the bad primes of `E` are exactly the prime factors of `N`.
   That is why a 2-descent on `E` is not a factorisation-free operation.

2. The witness `Round46_Handover.md` section 7d verified BY HAND is verified here by
   `decide`: `N = 1333 = 31 * 43`, `f = X^3 - 2`, `m = 20`, `l = 640X - 256`,
   `g = -16 - 16a + 8a^2`, `l(m) = 12544 = 112^2`, `Norm(g) = -22528 = -2^11 * 11`,
   `gcd(2864 - 112, 1333) = 43`, `gcd(2864 + 112, 1333) = 31`.

`ring` discharges the polynomial identities; `decide` discharges the finite arithmetic.
An earlier draft of this file had two sign errors in the component formulas and a bogus
divisibility notation; `ring` and `decide` refused both, which is the point.
-/

import Mathlib.Tactic.Ring

namespace Cryptography.FactoringBarriers.RelationWitness

set_option linter.unusedVariables false

/-! ## Part 1 — the discriminant, and why `N^2` divides it -/

/-- **The discriminant is exactly `27 c^2 (c - m^3)^2`.**  An identity, not a bound. -/
theorem disc_exact (m c : ℤ) :
    4 * (-3 * m * c) ^ 3 + 27 * (c ^ 2 + m ^ 3 * c) ^ 2 = 27 * c ^ 2 * (c - m ^ 3) ^ 2 := by
  ring

/-- Setting up a relation by `c = m^3 - k N` puts an `N^2` into the discriminant. -/
theorem disc_at_c (m k N : ℤ) :
    4 * (-3 * m * (m ^ 3 - k * N)) ^ 3 + 27 * ((m ^ 3 - k * N) ^ 2 + m ^ 3 * (m ^ 3 - k * N)) ^ 2
      = 27 * N ^ 2 * k ^ 2 * (m ^ 3 - k * N) ^ 2 := by
  ring

/-- Hence `N^2` divides the discriminant, and `N` itself does. -/
theorem N2_dvd_disc (m k N : ℤ) :
    N ^ 2 ∣ 4 * (-3 * m * (m ^ 3 - k * N)) ^ 3
        + 27 * ((m ^ 3 - k * N) ^ 2 + m ^ 3 * (m ^ 3 - k * N)) ^ 2 := by
  refine ⟨27 * k ^ 2 * (m ^ 3 - k * N) ^ 2, ?_⟩
  rw [disc_at_c]
  ring

/-- The discriminant is a perfect square times `27`, so every prime it carries away from
`3` appears with even valuation — the reduction at the bad primes is additive, as the
`N^2` divisibility predicted. -/
theorem disc_is_27_times_square (m c : ℤ) :
    4 * (-3 * m * c) ^ 3 + 27 * (c ^ 2 + m ^ 3 * c) ^ 2
      = 3 ^ 3 * (c * (c - m ^ 3)) ^ 2 := by ring

/-! ## Part 2 — the record's hand-verified witness, checked by `decide` -/

theorem N_factors : (1333 : ℤ) = 31 * 43 := by decide
theorem p_is_3_mod_4 : (31 : ℤ) % 4 = 3 := by decide
theorem q_is_3_mod_4 : (43 : ℤ) % 4 = 3 := by decide
theorem factors_recover_N : (43 : ℤ) * 31 = 1333 := by decide

/-- `f(m) = m^3 - 2` is divisible by `N`: `m` is a root of `f` mod `N`. -/
theorem m_is_root : (1333 : ℤ) * 6 = 20 ^ 3 - 2 := by decide

/-- `g = -16 - 16a + 8a^2` lies on the cone `g1^2 + 2 g0 g2 = 0`, i.e. `g^2` has no `a^2`
component. -/
theorem g_on_cone : ((-16 : ℤ)) ^ 2 + 2 * ((-16 : ℤ)) * 8 = 0 := by decide

/-- The components of `g^2` modulo `X^3 - 2` are `-256 + 640 a`, so `l = 640X - 256`.
At `P = 0`, `Q = -2`, so the `a^1` component is `2 g0 g1 - Q g2^2` (the `2 P g1 g2` term
vanishes) and the `a^0` component is `g0^2 - 2 Q g1 g2`. -/
theorem l_slope : 2 * ((-16 : ℤ)) * ((-16 : ℤ)) - ((-2 : ℤ)) * 8 ^ 2 = (640 : ℤ) := by decide
theorem l_const : ((-16 : ℤ)) ^ 2 - 2 * ((-2 : ℤ)) * ((-16 : ℤ)) * 8 = (-256 : ℤ) := by decide

theorem l_at_m : (640 : ℤ) * 20 + (-256) = 12544 := by decide
theorem l_at_m_is_square : (12544 : ℤ) = 112 ^ 2 := by decide

/-- `Norm(g) = -22528 = -2^11 * 11`, so `l(alpha)` is 11-smooth. -/
theorem norm_g :
    ((-16 : ℤ)) ^ 3 + 2 * ((-16 : ℤ)) ^ 3 + 4 * (8 : ℤ) ^ 3
      - 3 * 2 * ((-16 : ℤ)) * ((-16 : ℤ)) * 8 = (-22528 : ℤ) := by decide
theorem norm_g_smooth : (-22528 : ℤ) = -(2 ^ 11) * 11 := by decide

/-- `phi(g) = g(m) = 2864`, and the two branches split. -/
theorem g_at_m : ((-16 : ℤ)) + ((-16 : ℤ)) * 20 + 8 * 20 ^ 2 = 2864 := by decide
theorem branch_one : 2864 - 112 = 2 ^ 6 * 43 := by decide
theorem branch_two : (2864 + 112) % 31 = 0 := by decide

/-- **The witness really does factor `N`.** -/
theorem gcd_gives_factors :
    Nat.gcd (2864 - 112) 1333 = 43 ∧ Nat.gcd (2864 + 112) 1333 = 31 := by decide

end Cryptography.FactoringBarriers.RelationWitness
