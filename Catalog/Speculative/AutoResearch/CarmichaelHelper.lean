import Mathlib

/-! # Carmichael's theorem, the prime-index case (helper file)

This file supplies the *prime* half of Carmichael's primitive–divisor theorem for the
Fibonacci sequence, the piece that the composite-case development
(`Shared.CarmichaelProof`, `Speculative.AutoResearch.CarmichaelComposite`) imports but
that was previously missing from the catalog.

The mathematical content is the classical **entry–point** (rank of apparition) argument:
if `p ∣ F n` and `p ∣ F k`, then `p ∣ F (gcd n k)` (because `Nat.fib_gcd` says
`F (gcd n k) = gcd (F n) (F k)`).  When the index `n` is prime, the gcd of `n` with any
smaller positive `k` is `1`, and `F 1 = 1`, so no prime can divide an earlier Fibonacci
number.  Hence **every** prime factor of `F n` is automatically a *primitive* prime
divisor when `n` is prime.

-- !-- Lab Notebook -- !--
Hypothesis : For prime index `n`, primitivity of prime divisors of `F n` should be
             *free* — it should not need any of the heavy machinery (coprime-part
             stripping, `native_decide` ranges) used in the composite case.
Result     : Confirmed.  `fib_primitive_divisor_prime` is proved with `sorry = 0` from
             only `Nat.fib_gcd`, `Nat.dvd_gcd`, and primality of the index.
Insight    : The entry point `α(p)` of a prime `p` always divides every index `n` with
             `p ∣ F n`; for prime `n` the only divisors are `1` and `n`, and `α(p) = 1`
             is impossible since `F 1 = 1`.  So `α(p) = n`, i.e. `p` is primitive.
Failure analysis : The naive bound `F n ≥ 2` must be justified; `Nat.fib_mono` with the
             concrete value `F 3 = 2` does it cleanly (no `decide` on large `fib`).
-- !-- Lab Notebook -- !--
-/

namespace CarmichaelHelper

-- !-- comment: `gcd`-compatibility of the entry point — the single workhorse lemma. -- !--
/-- If a number divides two Fibonacci numbers, it divides the Fibonacci number at their gcd. -/
lemma dvd_fib_gcd_of_dvd {p m k : ℕ} (hm : p ∣ Nat.fib m) (hk : p ∣ Nat.fib k) :
    p ∣ Nat.fib (Nat.gcd m k) := by
  rw [Nat.fib_gcd]; exact Nat.dvd_gcd hm hk

-- !-- comment: `F n ≥ 2` for `n ≥ 3`, so a prime divisor exists. -- !--
/-- For `n ≥ 3` the Fibonacci number `F n` is at least `2`. -/
lemma two_le_fib {n : ℕ} (hn : 3 ≤ n) : 2 ≤ Nat.fib n := by
  calc 2 = Nat.fib 3 := by decide
    _ ≤ Nat.fib n := Nat.fib_mono hn

end CarmichaelHelper

-- !-- comment: For prime `n`, *any* prime factor of `F n` is primitive: its entry point
--             divides the prime `n`, cannot be `1` (since `F 1 = 1`), hence equals `n`. -- !--
/-- **Carmichael, prime-index case.**  For a prime `n ≥ 13`, the Fibonacci number `F n`
has a primitive prime divisor: a prime `p ∣ F n` dividing no earlier `F k` (`0 < k < n`). -/
theorem fib_primitive_divisor_prime (n : ℕ) (hn : 13 ≤ n) (hnp : Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  -- `F n ≥ 2`, so it has a prime factor `p`.
  have hfn : 2 ≤ Nat.fib n := CarmichaelHelper.two_le_fib (by omega)
  obtain ⟨p, hp, hpn⟩ := Nat.exists_prime_and_dvd (n := Nat.fib n) (by omega)
  refine ⟨p, hp, hpn, ?_⟩
  intro k hk hkn hpk
  -- `p ∣ F (gcd n k)`; `gcd n k ∣ n` prime, and `gcd n k ≤ k < n`, so `gcd n k = 1`.
  have hg : p ∣ Nat.fib (Nat.gcd n k) := CarmichaelHelper.dvd_fib_gcd_of_dvd hpn hpk
  have hdvd : Nat.gcd n k ∣ n := Nat.gcd_dvd_left n k
  have hlt : Nat.gcd n k < n :=
    lt_of_le_of_lt (Nat.le_of_dvd hk (Nat.gcd_dvd_right n k)) hkn
  rcases (Nat.Prime.eq_one_or_self_of_dvd hnp _ hdvd) with h1 | hself
  · rw [h1] at hg; simp [Nat.fib_one] at hg; exact hp.ne_one hg
  · exact absurd hself (Nat.ne_of_lt hlt)