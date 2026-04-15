/-! # CatalogBuild.Pythagorean.Agents.AgentEpsilon_Synthesis

Auto-generated from theorem catalog database.
Domain: Pythagorean/Agents
Declarations: 23
-/

import Mathlib

/-- A Pythagorean triple gives a rational point on the unit circle. -/
theorem rational_circle_point (a b c : ℤ) (hc : c ≠ 0) (h : a^2 + b^2 = c^2) :
    (a : ℚ) / c * ((a : ℚ) / c) + (b : ℚ) / c * ((b : ℚ) / c) = 1 := by
  have hcq : (c : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hc
  field_simp
  exact_mod_cast h


/-- Stereographic projection parametrizes the unit circle by ℚ. -/
theorem stereographic_parametrization (t : ℚ) (ht : 1 + t ^ 2 ≠ 0) :
    ((1 - t^2) / (1 + t^2))^2 + (2 * t / (1 + t^2))^2 = 1 := by
  field_simp
  ring


theorem stereographic_euclid (m n : ℤ) (hm : m ≠ 0) (hmn : m^2 + n^2 ≠ 0) :
    let t : ℚ := (n : ℚ) / m
    (1 - t^2) / (1 + t^2) = (m^2 - n^2 : ℤ) / (m^2 + n^2 : ℤ) := by
  -- Substitute $t = \frac{n}{m}$ into the expression.
  field_simp [hm];
  push_cast; ring;


/-- Berggren M₁ preserves the Lorentz form for ALL vectors (not just Pythagorean triples). -/
theorem berggren_M1_lorentz_full (x y z : ℤ) :
    (x - 2*y + 2*z)^2 + (2*x - y + 2*z)^2 - (2*x - 2*y + 3*z)^2 =
    x^2 + y^2 - z^2 := by ring


/-- Berggren M₂ preserves the Lorentz form. -/
theorem berggren_M2_lorentz_full (x y z : ℤ) :
    (x + 2*y + 2*z)^2 + (2*x + y + 2*z)^2 - (2*x + 2*y + 3*z)^2 =
    x^2 + y^2 - z^2 := by ring


/-- Berggren M₃ preserves the Lorentz form. -/
theorem berggren_M3_lorentz_full (x y z : ℤ) :
    (-x + 2*y + 2*z)^2 + (-2*x + y + 2*z)^2 - (-2*x + 2*y + 3*z)^2 =
    x^2 + y^2 - z^2 := by ring


/-- −1 is a quadratic residue mod 17. -/
theorem neg_one_qr_mod17 : ∃ x : ZMod 17, x ^ 2 = -1 := ⟨4, by decide⟩


/-- −1 is a quadratic residue mod 29. -/
theorem neg_one_qr_mod29 : ∃ x : ZMod 29, x ^ 2 = -1 := ⟨12, by decide⟩


/-- −1 is NOT a quadratic residue mod 3 (since 3 ≡ 3 mod 4). -/
theorem neg_one_nqr_mod3 : ¬ ∃ x : ZMod 3, x ^ 2 = -1 := by decide


/-- −1 is NOT a quadratic residue mod 7. -/
theorem neg_one_nqr_mod7 : ¬ ∃ x : ZMod 7, x ^ 2 = -1 := by decide


/-- −1 is NOT a quadratic residue mod 11. -/
theorem neg_one_nqr_mod11 : ¬ ∃ x : ZMod 11, x ^ 2 = -1 := by decide


/-- −1 is NOT a quadratic residue mod 19. -/
theorem neg_one_nqr_mod19 : ¬ ∃ x : ZMod 19, x ^ 2 = -1 := by decide


/-- Euler's four squares identity (quaternion norm multiplicativity). -/
theorem euler_four_sq (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    ∃ c₁ c₂ c₃ c₄ : ℤ,
    c₁^2 + c₂^2 + c₃^2 + c₄^2 =
    (a₁^2 + a₂^2 + a₃^2 + a₄^2) * (b₁^2 + b₂^2 + b₃^2 + b₄^2) :=
  ⟨a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄,
   a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃,
   a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂,
   a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁,
   by ring⟩


/-- For positive Pythagorean triples, a + b > c (triangle inequality). -/
theorem pythagorean_triangle_ineq (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a^2 + b^2 = c^2) : a + b > c := by
  nlinarith [sq_nonneg (a - b)]


/-- For Pythagorean triples, c > a and c > b (hypotenuse is longest). -/
theorem pythagorean_hyp_largest_a (a b c : ℤ) (hb : 0 < b) (hc : 0 < c)
    (h : a^2 + b^2 = c^2) : a < c := by
  nlinarith [sq_nonneg b]


theorem pythagorean_hyp_largest_b (a b c : ℤ) (ha : 0 < a) (hc : 0 < c)
    (h : a^2 + b^2 = c^2) : b < c := by
  nlinarith [sq_nonneg a]


/-- Two distinct sum-of-two-squares representations of a product. -/
theorem two_representations (a b c d : ℤ) :
    (a*c - b*d)^2 + (a*d + b*c)^2 = (a*c + b*d)^2 + (a*d - b*c)^2 := by ring

-- **EPSILON'S INSIGHT**: The two representations are the same iff ad = bc or ac = bd.
-- This means: they're different precisely when a/b ≠ c/d and a/b ≠ d/c
-- (the Gaussian integers aren't associates).


/-- The first few hypotenuses in the Berggren tree are all products of primes ≡ 1 (mod 4):
5, 13, 17, 25, 29, 37, 41, ... -/
theorem hyp_5_mod4 : 5 % 4 = 1 := by decide

theorem hyp_13_mod4 : 13 % 4 = 1 := by decide

theorem hyp_17_mod4 : 17 % 4 = 1 := by decide

theorem hyp_29_mod4 : 29 % 4 = 1 := by decide

theorem hyp_25_mod4 : 25 % 4 = 1 := by decide

theorem hyp_37_mod4 : 37 % 4 = 1 := by decide

