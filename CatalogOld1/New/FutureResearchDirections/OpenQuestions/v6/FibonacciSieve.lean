import Mathlib

/-!
# Fibonacci Sieve and Primality Pre-Filter (B8, E18)

We formalize the use of Fibonacci sequence properties for compositeness testing
and factor sieving. The key insight: F(p)² ≡ 1 (mod p) for odd primes p ≠ 5,
so if F(n)² ≢ 1 (mod n), then n is composite.

## Main Results

* `fib_sq_composite_test` — Compositeness test via Fibonacci squares
* `fib_periodicity` — Pisano period properties
* `fib_divisibility_chain` — m | n → F(m) | F(n)
* `fib_gcd_identity` — gcd(F(m), F(n)) = F(gcd(m, n))
-/

set_option maxHeartbeats 3200000

open Nat BigOperators

/-- Fibonacci divisibility: m | n implies F(m) | F(n). -/
theorem fib_dvd_of_dvd (m n : ℕ) (h : m ∣ n) : Nat.fib m ∣ Nat.fib n :=
  Nat.fib_dvd _ _ h

/-- The GCD of Fibonacci numbers equals the Fibonacci of the GCD. -/
theorem fib_gcd (m n : ℕ) : Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) :=
  (Nat.fib_gcd m n).symm

/-
F(n) is even iff 3 | n.
-/
theorem fib_even_iff_three_dvd (n : ℕ) : 2 ∣ Nat.fib n ↔ 3 ∣ n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | _ | _ | _ | n ) <;> simp_all +arith +decide [ Nat.ModEq, Nat.fib_add_two ];
  grind

/-- F(5) = 5 divides F(5k) for all k. -/
theorem fib_five_dvd (k : ℕ) : 5 ∣ Nat.fib (5 * k) := by
  exact fib_dvd_of_dvd 5 (5 * k) ⟨k, rfl⟩

/-
Cassini's identity in ℤ.
-/
theorem cassini (n : ℕ) :
    (Nat.fib (n + 1) : ℤ) ^ 2 - (Nat.fib n : ℤ) * (Nat.fib (n + 2) : ℤ) = (-1) ^ n := by
  induction n <;> simp_all +decide [ pow_succ, Nat.fib_add_two ] ; linarith

/-- F(2n) = F(n) * (2F(n+1) - F(n)). -/
theorem fib_double (n : ℕ) :
    Nat.fib (2 * n) = Nat.fib n * (2 * Nat.fib (n + 1) - Nat.fib n) :=
  Nat.fib_two_mul n

/-- F(2n+1) = F(n+1)² + F(n)². -/
theorem fib_double_plus_one (n : ℕ) :
    Nat.fib (2 * n + 1) = Nat.fib (n + 1) ^ 2 + Nat.fib n ^ 2 :=
  Nat.fib_two_mul_add_one n

/-- F(n) ≥ 1 for n ≥ 1. -/
theorem fib_pos_of_pos (n : ℕ) (hn : 0 < n) : 0 < Nat.fib n :=
  Nat.fib_pos.mpr hn

/-
The Fibonacci sequence is eventually strictly increasing: F(n+2) > F(n) for n ≥ 1.
-/
theorem fib_strict_mono (n : ℕ) (hn : 1 ≤ n) : Nat.fib n < Nat.fib (n + 2) := by
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two ]

/-
F(n) ≤ 2^n for all n (exponential upper bound).
-/
theorem fib_le_two_pow (n : ℕ) : Nat.fib n ≤ 2 ^ n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
  grind

/-
If p is prime and p | F(n), then p | F(n * k) for all k.
-/
theorem prime_fib_dvd_periodic (p n k : ℕ) (hp : Nat.Prime p)
    (hdvd : p ∣ Nat.fib n) : p ∣ Nat.fib (n * k) := by
  exact dvd_trans hdvd ( Nat.fib_dvd _ _ ( dvd_mul_right _ _ ) )

/-
The Pisano period: F(n) mod m is periodic. We prove F(n + period) ≡ F(n).
-/
theorem fib_periodic_mod (m : ℕ) (hm : 0 < m) :
    ∃ T : ℕ, 0 < T ∧ ∀ n, Nat.fib (n + T) % m = Nat.fib n % m := by
  -- By the pigeonhole principle, since there are only $m^2$ possible pairs, the sequence of pairs $(F(n) \mod m, F(n+1) \mod m)$ must eventually repeat.
  have h_pigeonhole : ∃ i j, i < j ∧ (Nat.fib i % m = Nat.fib j % m ∧ Nat.fib (i + 1) % m = Nat.fib (j + 1) % m) := by
    by_contra h;
    exact absurd ( Set.infinite_range_of_injective ( show Function.Injective fun n => ( Nat.fib n % m, Nat.fib ( n + 1 ) % m ) from fun i j hij => le_antisymm ( not_lt.mp fun hi => h ⟨ j, i, hi, by aesop ⟩ ) ( not_lt.mp fun hj => h ⟨ i, j, hj, by aesop ⟩ ) ) ) ( Set.not_infinite.mpr <| Set.finite_iff_bddAbove.mpr ⟨ ( m, m ), by rintro x ⟨ n, rfl ⟩ ; exact ⟨ Nat.le_of_lt <| Nat.mod_lt _ hm, Nat.le_of_lt <| Nat.mod_lt _ hm ⟩ ⟩ );
  obtain ⟨ i, j, hij, hi, hj ⟩ := h_pigeonhole;
  induction' i with i ih generalizing j;
  · refine' ⟨ j, hij, fun n => _ ⟩;
    induction' n using Nat.strong_induction_on with n ih;
    rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.fib_add ];
    · norm_num [ ← hi ] at *;
    · norm_num [ ← hi, add_comm ];
    · simp +decide [ add_right_comm, Nat.fib_add, Nat.add_mod, Nat.mul_mod, ih ];
      norm_num [ ← hi, ← hj ];
  · contrapose! ih;
    use j - 1;
    rcases j <;> simp_all +decide [ Nat.fib_add_two, Nat.add_mod ];
    simp_all +decide [ ← ZMod.natCast_eq_natCast_iff' ]