import Mathlib

/-!
# Quadratic Residue Factoring and Smooth Number Theory (NEW)

## Main Results

* `qr_mul_qr` — Product of quadratic residues is a QR
* `fermat_factoring_identity` — 4ab = (a+b)² - (b-a)²
* `diff_of_squares_int` — x² - y² = (x-y)(x+y)
* `smooth_mul` — Products of smooth numbers are smooth
* `prime_pow_smooth` — p^k is p-smooth
-/

set_option maxHeartbeats 4000000

open Nat BigOperators Finset

/-! ### Quadratic Residues -/

def IsQuadraticResidue (a n : ℕ) : Prop :=
  ∃ x : ℕ, x ^ 2 % n = a % n

theorem one_is_qr (n : ℕ) : IsQuadraticResidue 1 n :=
  ⟨1, by simp⟩

theorem zero_is_qr (n : ℕ) : IsQuadraticResidue 0 n :=
  ⟨0, by simp⟩

theorem qr_mul_qr (a b n : ℕ) (ha : IsQuadraticResidue a n) (hb : IsQuadraticResidue b n) :
    IsQuadraticResidue (a * b) n := by
  obtain ⟨x, hx⟩ := ha
  obtain ⟨y, hy⟩ := hb
  exact ⟨x * y, by rw [mul_pow]; simp [Nat.mul_mod, hx, hy]⟩

/-! ### Difference of Squares -/

theorem fermat_factoring_identity (a b : ℤ) :
    4 * (a * b) = (a + b) ^ 2 - (b - a) ^ 2 := by ring

theorem diff_of_squares_int (x y : ℤ) :
    x ^ 2 - y ^ 2 = (x - y) * (x + y) := by ring

/-! ### Smooth Numbers -/

def IsSmooth (B n : ℕ) : Prop :=
  ∀ p, Nat.Prime p → p ∣ n → p ≤ B

theorem one_is_smooth (B : ℕ) : IsSmooth B 1 := by
  intro p hp hd
  have := hp.one_lt
  have := Nat.le_of_dvd one_pos hd
  omega

theorem smooth_mul (B a b : ℕ) (ha : IsSmooth B a) (hb : IsSmooth B b) :
    IsSmooth B (a * b) := by
  intro p hp hd
  rcases hp.dvd_mul.mp hd with h | h
  · exact ha p hp h
  · exact hb p hp h

theorem prime_pow_smooth (p k : ℕ) (hp : Nat.Prime p) : IsSmooth p (p ^ k) := by
  intro q hq hd
  have hdvd := hq.dvd_of_dvd_pow hd
  rcases hp.eq_one_or_self_of_dvd q hdvd with h | h
  · exact absurd h hq.ne_one
  · exact le_of_eq h
