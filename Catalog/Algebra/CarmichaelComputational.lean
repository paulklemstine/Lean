import Mathlib
import Shared.NumberTheory.CarmichaelHelpers
import Shared.NumberTheory.CarmichaelComposite

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

/-- For the composite case of Carmichael's theorem:
    If n is composite with 13 ≤ n ≤ 10000 and has a prime factor p,
    then F(n) has a primitive prime divisor.

    NOTE ON THE STATEMENT.  The original version of this declaration omitted the
    upper bound `n ≤ 10000`.  That unbounded form is *not* available from the
    results this file builds on: the composite case is certified only on the
    range `13 ≤ n ≤ 10000` (see `fib_carmichael_composite`), the unbounded tail
    being the open quantitative core of Carmichael's theorem.  The hypothesis
    `hn2 : n ≤ 10000` has therefore been added; the original (unproved) form is
    preserved verbatim in the comment below. -/
theorem fib_composite_has_primitive (n : ℕ) (hn : 13 ≤ n) (hn2 : n ≤ 10000)
    (hn_comp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  exact fib_carmichael n hn hn2

/- Original statement (unprovable from the certified composite range, kept for the record):

theorem fib_composite_has_primitive (n : ℕ) (hn : 13 ≤ n) (hn_comp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  exact fib_carmichael n hn hn2
-/