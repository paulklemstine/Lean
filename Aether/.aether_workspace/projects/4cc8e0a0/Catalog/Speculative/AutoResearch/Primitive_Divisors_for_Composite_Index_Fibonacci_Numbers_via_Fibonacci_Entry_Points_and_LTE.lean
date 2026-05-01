import Mathlib

open scoped BigOperators
open Nat

set_option maxHeartbeats 800000000
set_option maxRecDepth 4000

/-! # Carmichael's Theorem on Primitive Divisors of Fibonacci Numbers -/

/-- Reduction: a prime dividing F_n that doesn't divide F_d for any proper positive
    divisor d of n is primitive. -/
lemma primitive_of_not_dvd_proper_divisors {n p : ℕ} (_hp : p.Prime)
    (hpn : p ∣ Nat.fib n) (hn : 0 < n)
    (h : ∀ d, 0 < d → d < n → d ∣ n → ¬(p ∣ Nat.fib d)) :
    ∀ m, 0 < m → m < n → ¬(p ∣ Nat.fib m) := by
  intro m hm₁ hm₂
  exact fun hpm => h (Nat.gcd m n) (Nat.gcd_pos_of_pos_right _ hn)
    (lt_of_le_of_lt (Nat.le_of_dvd hm₁ (Nat.gcd_dvd_left _ _)) hm₂)
    (Nat.gcd_dvd_right _ _)
    (by simpa [Nat.fib_gcd] using Nat.dvd_gcd hpm hpn)

/-- F_a and F_b are coprime when gcd(a,b) = 1. -/
lemma fib_coprime_of_coprime {a b : ℕ} (hab : Nat.Coprime a b) :
    Nat.Coprime (Nat.fib a) (Nat.fib b) := by
  contrapose! hab
  exact fun h => hab <| by rw [← Nat.fib_gcd, h, Nat.fib_one]

/-- Carmichael's theorem for composite indices. -/
theorem fib_composite_has_primitive {n : ℕ} (hn : n ≠ 1) (hcomp : ¬n.Prime) (h12 : 12 < n) :
    ∃ p : ℕ, p.Prime ∧ p ∣ Nat.fib n ∧ ∀ m, 0 < m → m < n → ¬p ∣ Nat.fib m := by
  suffices h : ∃ p : ℕ, p.Prime ∧ p ∣ Nat.fib n ∧
      ∀ d, 0 < d → d < n → d ∣ n → ¬p ∣ Nat.fib d by
    obtain ⟨p, hp, hpn, hd⟩ := h
    exact ⟨p, hp, hpn, fun m hm₁ hm₂ hpm =>
      hd (Nat.gcd m n) (Nat.gcd_pos_of_pos_right _ (by omega))
        (lt_of_le_of_lt (Nat.le_of_dvd hm₁ (Nat.gcd_dvd_left _ _)) hm₂)
        (Nat.gcd_dvd_right _ _)
        (by simpa [Nat.fib_gcd] using Nat.dvd_gcd hpm hpn)⟩
  sorry
