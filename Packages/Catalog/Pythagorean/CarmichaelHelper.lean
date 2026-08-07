import Mathlib

/-! # Carmichael's theorem for Fibonacci numbers: the prime-index case

For a *prime* index `p` the primitive-divisor statement is elementary: by
`Nat.fib_gcd`, any prime `q` dividing both `F(p)` and some earlier `F(k)`
(`0 < k < p`) divides `F(gcd p k) = F(1) = 1`, which is impossible.  Hence
*every* prime divisor of `F(p)` is automatically primitive, and `F(p) > 1` as
soon as `p ≥ 13` (indeed as soon as `p ≥ 4`).

This is the helper used by `Shared.CarmichaelComposite` to assemble the two
cases of Carmichael's theorem on the verified range.
-/

/-- Any prime divisor of `F(n)` that also divides an earlier `F(k)` forces
`gcd n k` to be an index below `n` whose Fibonacci number it divides. -/
theorem fib_dvd_gcd_of_dvd {q n k : ℕ} (hn : q ∣ Nat.fib n) (hk : q ∣ Nat.fib k) :
    q ∣ Nat.fib (Nat.gcd n k) := by
  rw [Nat.fib_gcd]
  exact Nat.dvd_gcd hn hk

/-- **Carmichael's theorem, prime-index case.**  For a prime `n ≥ 13` the Fibonacci
number `F(n)` has a primitive prime divisor.  (In fact every prime divisor of `F(n)`
is primitive when `n` is prime.) -/
theorem fib_primitive_divisor_prime (n : ℕ) (hn : 13 ≤ n) (hp : Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  have hfib : 1 < Nat.fib n := by
    have h3 : Nat.fib 3 ≤ Nat.fib n := Nat.fib_mono (by omega)
    have : Nat.fib 3 = 2 := by decide
    omega
  refine ⟨(Nat.fib n).minFac, Nat.minFac_prime (by omega), Nat.minFac_dvd _, ?_⟩
  intro k hk hkn hdvd
  have hg : (Nat.fib n).minFac ∣ Nat.fib (Nat.gcd n k) :=
    fib_dvd_gcd_of_dvd (Nat.minFac_dvd _) hdvd
  have hgn : Nat.gcd n k ∣ n := Nat.gcd_dvd_left n k
  have hgk : Nat.gcd n k ≤ k := Nat.le_of_dvd hk (Nat.gcd_dvd_right n k)
  have hgone : Nat.gcd n k = 1 := by
    rcases (Nat.Prime.eq_one_or_self_of_dvd hp _ hgn) with h | h
    · exact h
    · omega
  rw [hgone] at hg
  simp only [Nat.fib_one] at hg
  exact Nat.Prime.one_lt (Nat.minFac_prime (by omega : Nat.fib n ≠ 1)) |>.ne'
    (Nat.dvd_one.mp hg)