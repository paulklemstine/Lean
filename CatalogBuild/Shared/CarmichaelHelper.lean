/-! # CatalogBuild.Shared.CarmichaelHelper

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 1
-/

import Mathlib

/-- For prime n ≥ 13, every prime factor of F(n) is a primitive prime divisor.
This is because for prime n, gcd(n, k) = 1 for all 0 < k < n,
so if q | F(n) and q | F(k), then q | F(gcd(n,k)) = F(1) = 1, contradiction. -/
theorem fib_primitive_divisor_prime (n : ℕ) (hn : 13 ≤ n) (hp : Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  have hfn : 1 < Nat.fib n :=
    lt_of_lt_of_le (by native_decide : 1 < Nat.fib 13) (Nat.fib_mono hn)
  obtain ⟨q, hq_prime, hq_dvd⟩ := Nat.exists_prime_and_dvd hfn.ne'
  refine ⟨q, hq_prime, hq_dvd, fun k hk hkn hqk => ?_⟩
  have hcoprime : Nat.Coprime n k :=
    hp.coprime_iff_not_dvd.mpr (fun h => not_lt.mpr (Nat.le_of_dvd hk h) hkn)
  have hgcd : Nat.gcd n k = 1 := hcoprime
  have : q ∣ Nat.fib 1 := hgcd ▸ (Nat.fib_gcd n k ▸ Nat.dvd_gcd hq_dvd hqk)
  simp at this
  exact hq_prime.one_lt.ne' this

