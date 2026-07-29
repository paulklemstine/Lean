import Mathlib

/-!
# Character-twisted power sums

This file formalizes elementary algebraic features of the character-twisted
power sums occurring in the character analogue of Schäffer's equation. It
also gives an exact evaluation for the primitive quadratic character modulo
four in degree one and derives a concrete nonexistence theorem for perfect
powers.
-/

namespace CharacterTwistedSchaffer

/-- The finite character-twisted power sum
`χ(1)(x+1)^k + ⋯ + χ(m)(x+m)^k`. -/
def twistedPowerSum (χ : ℕ → ℤ) (k m : ℕ) (x : ℤ) : ℤ :=
  ∑ i ∈ Finset.range m, χ (i + 1) * (x + (i + 1 : ℕ)) ^ k

/-- Appending one term gives the expected recurrence for twisted power sums. -/
theorem twistedPowerSum_succ (χ : ℕ → ℤ) (k m : ℕ) (x : ℤ) :
    twistedPowerSum χ k (m + 1) x =
      twistedPowerSum χ k m x + χ (m + 1) * (x + (m + 1 : ℕ)) ^ k := by
  simp [twistedPowerSum, Finset.sum_range_succ]

/-- Translating `x` by `t` is the same as translating every summand. -/
theorem twistedPowerSum_translate (χ : ℕ → ℤ) (k m : ℕ) (x t : ℤ) :
    twistedPowerSum χ k m (x + t) =
      ∑ i ∈ Finset.range m, χ (i + 1) * (x + (t + (i + 1 : ℕ))) ^ k := by
  simp only [twistedPowerSum]
  congr 1
  ext i
  ring

/-- The primitive quadratic Dirichlet character modulo four, on natural numbers. -/
def chiFour (a : ℕ) : ℤ :=
  if a % 4 = 1 then 1 else if a % 4 = 3 then -1 else 0

/-- The four values in every complete block of the character modulo four. -/
theorem chiFour_block (j : ℕ) :
    chiFour (4 * j + 1) = 1 ∧ chiFour (4 * j + 2) = 0 ∧
      chiFour (4 * j + 3) = -1 ∧ chiFour (4 * j + 4) = 0 := by
  simp [chiFour, Nat.add_mod]

/-- A complete block contributes `-2` to the degree-one twisted sum,
independently of the starting value `x`. -/
theorem chiFour_linear_block (j : ℕ) (x : ℤ) :
    ∑ r ∈ Finset.Icc 1 4,
        chiFour (4 * j + r) * (x + (4 * j + r : ℕ)) = -2 := by
  norm_num [chiFour, Finset.sum_Icc_succ_top, Nat.add_mod]
  ring

/-- Exact evaluation of the degree-one twisted sum over `q` complete periods. -/
theorem chiFour_linear_four_mul (q : ℕ) (x : ℤ) :
    twistedPowerSum chiFour 1 (4 * q) x = -2 * (q : ℤ) := by
  induction q with
  | zero => simp [twistedPowerSum]
  | succ q ih =>
      rw [show 4 * (q + 1) = (((4 * q) + 1) + 1) + 1 + 1 by omega]
      rw [twistedPowerSum_succ, twistedPowerSum_succ,
        twistedPowerSum_succ, twistedPowerSum_succ, ih]
      simp [chiFour, Nat.add_mod]
      ring

/-- For a nonempty collection of complete periods, the degree-one twisted sum
for the quadratic character modulo four is negative. -/
theorem chiFour_linear_four_mul_neg {q : ℕ} (hq : 0 < q) (x : ℤ) :
    twistedPowerSum chiFour 1 (4 * q) x < 0 := by
  rw [chiFour_linear_four_mul]
  omega

/-- Consequently, the degree-one character-twisted Schäffer equation over a
positive number of complete periods has no solution whose exponent is even. -/
theorem no_even_power_chiFour_linear {q n : ℕ} (hq : 0 < q) (hn : Even n)
    (x y : ℤ) : twistedPowerSum chiFour 1 (4 * q) x ≠ y ^ n := by
  rw [chiFour_linear_four_mul]
  intro h
  obtain ⟨r, rfl⟩ := hn
  rw [pow_add] at h
  have hnonneg : 0 ≤ y ^ r * y ^ r := mul_self_nonneg _
  omega

/-- Exact evaluation of the quadratic twisted sum over complete periods.
Unlike the linear case, the result retains a linear dependence on `x`. -/
theorem chiFour_quadratic_four_mul (q : ℕ) (x : ℤ) :
    twistedPowerSum chiFour 2 (4 * q) x =
      -4 * (q : ℤ) * (x + 2 * (q : ℤ)) := by
  induction q with
  | zero => simp [twistedPowerSum]
  | succ q ih =>
      rw [show 4 * (q + 1) = (((4 * q) + 1) + 1) + 1 + 1 by omega]
      rw [twistedPowerSum_succ, twistedPowerSum_succ,
        twistedPowerSum_succ, twistedPowerSum_succ, ih]
      simp [chiFour, Nat.add_mod]
      ring

/-- If `x + 2q` is positive, the quadratic twisted sum over `q` complete
periods is negative. -/
theorem chiFour_quadratic_four_mul_neg {q : ℕ} (hq : 0 < q) (x : ℤ)
    (hx : -(2 * (q : ℤ)) < x) : twistedPowerSum chiFour 2 (4 * q) x < 0 := by
  rw [chiFour_quadratic_four_mul]
  have hqz : 0 < (q : ℤ) := by exact_mod_cast hq
  nlinarith

/-- In the positive range `x > -2q`, the quadratic character-twisted
Schäffer equation has no solutions with an even exponent. -/
theorem no_even_power_chiFour_quadratic {q n : ℕ} (hq : 0 < q) (hn : Even n)
    (x y : ℤ) (hx : -(2 * (q : ℤ)) < x) :
    twistedPowerSum chiFour 2 (4 * q) x ≠ y ^ n := by
  intro h
  have hneg := chiFour_quadratic_four_mul_neg hq x hx
  rw [h] at hneg
  obtain ⟨r, rfl⟩ := hn
  rw [pow_add] at hneg
  exact (not_lt_of_ge (mul_self_nonneg (y ^ r))) hneg

end CharacterTwistedSchaffer