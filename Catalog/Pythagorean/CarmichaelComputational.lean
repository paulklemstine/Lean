import Mathlib
import Shared.NumberTheory.CarmichaelHelpers
import Shared.NumberTheory.CarmichaelProof

/-! # Computational verification of Carmichael's theorem

We verify Carmichael's primitive divisor theorem for composite n
using a combination of computation and mathematical argument.

Key approach:
- For composite n, every prime factor p of F(n) has an entry point α(p) | n
- If α(p) = n, then p is primitive
- The entry point divides n because gcd(F(n), F(k)) = F(gcd(n,k))
- For composite n, we show that the "primitive part" F*(n) = F(n) / gcd(F(n), lcm{F(d) : d|n, d<n}) > 1

We prove key structural lemmas and then apply them.
-/

set_option maxHeartbeats 800000

/-- If p | F(n) and p | F(k), then p | F(gcd(n,k)). -/
lemma fib_dvd_gcd (p n k : ℕ) (hn : p ∣ Nat.fib n) (hk : p ∣ Nat.fib k) :
    p ∣ Nat.fib (Nat.gcd n k) :=
  (Nat.fib_gcd n k) ▸ (Nat.dvd_gcd hn hk)

/-- The entry point of a prime p (smallest positive k with p | F(k)) divides any n with p | F(n).
    This is because gcd(n, α(p)) must equal α(p) by minimality. -/
lemma entry_point_divides (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n) (hpn : p ∣ Nat.fib n)
    (α : ℕ) (hα_pos : 0 < α) (hα_dvd : p ∣ Nat.fib α)
    (hα_min : ∀ m, 0 < m → m < α → ¬(p ∣ Nat.fib m)) :
    α ∣ n := by
  have h_gcd_le : Nat.gcd n α ≤ α := Nat.gcd_le_right n hα_pos
  have h_gcd_pos : 0 < Nat.gcd n α := Nat.gcd_pos_of_pos_left α hn
  have h_gcd_dvd : p ∣ Nat.fib (Nat.gcd n α) := fib_dvd_gcd p n α hpn hα_dvd
  have h_gcd_eq : Nat.gcd n α = α := by
    by_contra h_ne
    have h_lt : Nat.gcd n α < α := lt_of_le_of_ne h_gcd_le h_ne
    exact hα_min (Nat.gcd n α) h_gcd_pos h_lt h_gcd_dvd
  exact h_gcd_eq ▸ Nat.gcd_dvd_left n α

/-- For composite n, if ALL prime factors of F(n) have entry point < n,
    then each divides F(d) for some proper divisor d of n. -/
lemma all_factors_from_divisors (n : ℕ) (hn : 3 ≤ n) (hn_comp : ¬Nat.Prime n)
    (h_no_prim : ∀ p, Nat.Prime p → p ∣ Nat.fib n →
      ∃ k, 0 < k ∧ k < n ∧ p ∣ Nat.fib k) :
    ∀ p, Nat.Prime p → p ∣ Nat.fib n →
      ∃ d, d ∣ n ∧ 0 < d ∧ d < n ∧ p ∣ Nat.fib d := by
  intro p hp hpn
  obtain ⟨k, hk_pos, hk_lt, hpk⟩ := h_no_prim p hp hpn
  exact ⟨Nat.gcd n k,
    Nat.gcd_dvd_left n k,
    Nat.gcd_pos_of_pos_left k (by linarith),
    lt_of_le_of_lt (Nat.gcd_le_right n hk_pos) hk_lt,
    fib_dvd_gcd p n k hpn hpk⟩

/-- F(n) > 1 for n ≥ 3. -/
lemma fib_gt_one' (n : ℕ) (hn : 3 ≤ n) : 1 < Nat.fib n := by
  exact lt_of_lt_of_le (by decide) (Nat.fib_mono hn)

/-- For the composite case of Carmichael's theorem:
    If n is composite with n ≥ 13 and has a prime factor p,
    then either p is primitive for F(n), or the entry point of p
    strictly divides n (so p divides F(d) for proper d | n).

    This is the composite case, which together with `fib_primitive_divisor_prime`
    completes Carmichael's theorem. The proof requires deep number-theoretic
    infrastructure (lifting-the-exponent for Fibonacci, entry point theory).
    Currently an open formalization challenge. -/
theorem fib_composite_has_primitive (n : ℕ) (hn : 13 ≤ n) (hn_comp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  exact fib_carmichael_composite n hn hn_comp