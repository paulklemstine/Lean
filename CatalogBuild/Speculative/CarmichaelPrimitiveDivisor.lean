/-! # CatalogBuild.Speculative.CarmichaelPrimitiveDivisor

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 5
-/

import Mathlib
import Shared.CarmichaelComposite

/-- If p | F(n) and p | F(k), then p | F(gcd(n,k)). -/
lemma fib_prime_dvd_gcd' (p n k : ℕ) (hpn : p ∣ Nat.fib n) (hpk : p ∣ Nat.fib k) :
    p ∣ Nat.fib (Nat.gcd n k) := by
  exact Nat.fib_gcd n k ▸ Nat.dvd_gcd hpn hpk


/-- F(n) > 1 for n ≥ 3. -/
lemma fib_gt_one_spec (n : ℕ) (hn : 3 ≤ n) : 1 < Nat.fib n := by
  match n, hn with
  | 3, _ => decide
  | n + 4, _ =>
    have := @Nat.fib_add_two (n + 2)
    have := Nat.fib_pos.mpr (show 0 < n + 3 by omega)
    have := Nat.fib_pos.mpr (show 0 < n + 2 by omega)
    linarith


/-- F(n) has a prime factor for n ≥ 3. -/
lemma fib_has_prime_factor' (n : ℕ) (hn : 3 ≤ n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n := by
  have := fib_gt_one_spec n hn
  exact ⟨Nat.minFac (Nat.fib n), Nat.minFac_prime (by omega), Nat.minFac_dvd _⟩


/-- If p is a prime factor of F(n) that is NOT primitive, then p | F(d)
for some d with d | n and 0 < d < n. -/
lemma non_primitive_to_proper_divisor (p n : ℕ) (_hp : Nat.Prime p)
    (hpn : p ∣ Nat.fib n) (hn : 0 < n)
    (k : ℕ) (hk_pos : 0 < k) (hk_lt : k < n) (hpk : p ∣ Nat.fib k) :
    ∃ d, 0 < d ∧ d ∣ n ∧ d < n ∧ p ∣ Nat.fib d := by
  refine ⟨Nat.gcd n k, ?_, Nat.gcd_dvd_left n k, ?_, fib_prime_dvd_gcd' p n k hpn hpk⟩
  · exact Nat.pos_of_ne_zero (by intro h; simp [Nat.gcd_eq_zero_iff] at h; omega)
  · calc Nat.gcd n k ≤ k := Nat.gcd_le_right n hk_pos
    _ < n := hk_lt


/-- Carmichael's theorem: For n ≥ 13, F(n) has a primitive prime divisor. -/
theorem fib_primitive_divisor (n : ℕ) (hn : 13 ≤ n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  exact fib_carmichael n hn

