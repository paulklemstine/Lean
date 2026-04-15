/-! # CatalogBuild.Pythagorean.Core.SumOfSquares

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 22
-/

import Mathlib

/-- A natural number is a sum of two squares. -/
def NatSumTwoSq (n : ℕ) : Prop :=
  ∃ a b : ℕ, a ^ 2 + b ^ 2 = n

/-- 0 is a sum of two squares. -/

theorem natS2S_zero : NatSumTwoSq 0 := ⟨0, 0, by ring⟩

/-- 1 is a sum of two squares. -/

theorem natS2S_one : NatSumTwoSq 1 := ⟨0, 1, by ring⟩

/-- 2 is a sum of two squares. -/

theorem natS2S_two : NatSumTwoSq 2 := ⟨1, 1, by ring⟩

/-- 5 is a sum of two squares. -/

theorem natS2S_five : NatSumTwoSq 5 := ⟨1, 2, by ring⟩

/-- Every perfect square is a sum of two squares. -/

theorem sq_is_natS2S (n : ℕ) : NatSumTwoSq (n ^ 2) := ⟨0, n, by ring⟩

/-
3 is NOT a sum of two squares.
-/

theorem not_natS2S_three : ¬ NatSumTwoSq 3 := by
  exact fun ⟨ a, b, h ⟩ => by nlinarith [ show a ≤ 1 by nlinarith, show b ≤ 1 by nlinarith ] ;

/-
6 is NOT a sum of two squares.
-/

theorem not_natS2S_six : ¬ NatSumTwoSq 6 := by
  exact fun ⟨ a, b, h ⟩ ↦ by have := Nat.le_of_lt_succ ( show a < 3 by nlinarith ) ; have := Nat.le_of_lt_succ ( show b < 3 by nlinarith ) ; interval_cases a <;> interval_cases b <;> trivial;

/-
7 is NOT a sum of two squares.
-/

theorem not_natS2S_seven : ¬ NatSumTwoSq 7 := by
  exact fun ⟨ a, b, h ⟩ ↦ by have := Nat.le_of_lt_succ ( show a < 3 by nlinarith ) ; have := Nat.le_of_lt_succ ( show b < 3 by nlinarith ) ; interval_cases a <;> interval_cases b <;> trivial;

-- ═══════════════════════════════════════════════════════════════════════════════
--  §2: THE BRAHMAGUPTA-FIBONACCI IDENTITY
-- ═══════════════════════════════════════════════════════════════════════════════

/-- The Brahmagupta-Fibonacci identity over integers. -/

theorem int_s2s_mul_closed (a b c d : ℤ) :
    ∃ x y : ℤ, (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = x ^ 2 + y ^ 2 :=
  ⟨a * c - b * d, a * d + b * c, by ring⟩

-- ═══════════════════════════════════════════════════════════════════════════════
--  §3: GAUSSIAN INTEGER NORM
-- ═══════════════════════════════════════════════════════════════════════════════

/-- The norm of a Gaussian integer z = a + bi equals a² + b². -/

theorem gaussInt_norm_formula (a b : ℤ) :
    Zsqrtd.norm (⟨a, b⟩ : GaussianInt) = a * a + b * b := by
  simp [Zsqrtd.norm]

/-- The norm is multiplicative for Gaussian integers. -/

theorem gaussInt_norm_mul (z w : GaussianInt) :
    Zsqrtd.norm (z * w) = Zsqrtd.norm z * Zsqrtd.norm w :=
  Zsqrtd.norm_mul z w

/-
═══════════════════════════════════════════════════════════════════════════════
§4: QUADRATIC RESIDUE OBSTRUCTIONS
═══════════════════════════════════════════════════════════════════════════════

A sum of two squares mod 4 is 0, 1, or 2. It is never 3 mod 4.
-/

theorem s2s_mod4_ne_3 (a b : ℤ) : (a ^ 2 + b ^ 2) % 4 ≠ 3 := by
  rcases Int.even_or_odd' a with ⟨ x, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ y, rfl | rfl ⟩ <;> ring_nf <;> norm_num

/-- A number ≡ 3 (mod 4) is never a sum of two squares over ℤ. -/

theorem not_s2s_if_3_mod4 {n : ℤ} (hn : n % 4 = 3) :
    ∀ a b : ℤ, a ^ 2 + b ^ 2 ≠ n := by
  intro a b hab
  have := s2s_mod4_ne_3 a b
  omega

/-
Primes ≡ 3 (mod 4) are NOT sums of two squares (over ℕ).
-/

theorem prime_3_mod4_not_s2s {p : ℕ} (hmod : p % 4 = 3) :
    ¬ NatSumTwoSq p := by
  rintro ⟨ a, b, h ⟩;
  exact absurd ( congr_arg ( · % 4 ) h ) ( by norm_num [ Nat.add_mod, Nat.pow_mod, hmod ] ; have := Nat.mod_lt a zero_lt_four; have := Nat.mod_lt b zero_lt_four; interval_cases a % 4 <;> interval_cases b % 4 <;> trivial )

/-
═══════════════════════════════════════════════════════════════════════════════
§5: SUM OF FOUR SQUARES — SPECIAL CASES
═══════════════════════════════════════════════════════════════════════════════

Every natural number less than 10 is a sum of four squares.
-/

theorem sum_four_squares_small (n : ℕ) (hn : n < 10) :
    ∃ a b c d : ℕ, a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = n := by
  interval_cases n <;> [ exists 0, 0, 0, 0; exists 1, 0, 0, 0; exists 1, 1, 0, 0; exists 1, 1, 1, 0; exists 2, 0, 0, 0; exists 2, 1, 0, 0; exists 2, 1, 1, 0; exists 2, 1, 1, 1; exists 2, 2, 0, 0; exists 3, 0, 0, 0 ]

/-- 7 is a sum of four squares (but not two). -/

theorem seven_sum_four_sq : ∃ a b c d : ℕ, a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = 7 :=
  ⟨1, 1, 1, 2, by norm_num⟩

/-- 15 is a sum of four squares. -/

theorem fifteen_sum_four_sq : ∃ a b c d : ℕ, a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = 15 :=
  ⟨1, 1, 2, 3, by norm_num⟩

-- ═══════════════════════════════════════════════════════════════════════════════
--  §6: SCALING OF SUMS OF SQUARES
-- ═══════════════════════════════════════════════════════════════════════════════

/-- Scaling a sum of two squares. -/

theorem s2s_descent_helper (a b k : ℕ) :
    (k * a) ^ 2 + (k * b) ^ 2 = k ^ 2 * (a ^ 2 + b ^ 2) := by ring

-- ═══════════════════════════════════════════════════════════════════════════════
--  §7: CONNECTION TO PYTHAGOREAN TRIPLES
-- ═══════════════════════════════════════════════════════════════════════════════

/-- Every hypotenuse² of a Pythagorean triple is a sum of two squares. -/

theorem pyth_hyp_is_s2s (a b c : ℕ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    NatSumTwoSq (c ^ 2) :=
  ⟨a, b, h⟩

/-- Every multiple of 5 that is ≥ 5 is a hypotenuse of a Pythagorean triple. -/

theorem mult5_is_hypotenuse (k : ℕ) (hk : 0 < k) :
    ∃ a b : ℕ, a > 0 ∧ b > 0 ∧ a ^ 2 + b ^ 2 = (5 * k) ^ 2 :=
  ⟨3 * k, 4 * k, by omega, by omega, by ring⟩

/-- Every multiple of 13 is a hypotenuse. -/

theorem mult13_is_hypotenuse (k : ℕ) (hk : 0 < k) :
    ∃ a b : ℕ, a > 0 ∧ b > 0 ∧ a ^ 2 + b ^ 2 = (13 * k) ^ 2 :=
  ⟨5 * k, 12 * k, by omega, by omega, by ring⟩
