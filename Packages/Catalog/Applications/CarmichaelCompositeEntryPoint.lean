import Applications.Pythagorean.RankOfApparition

/-! # Entry points and primitive Fibonacci divisors

The entry point of a prime is its least positive Fibonacci index of apparition.
This file derives its divisibility and primitivity properties from the general
rank-of-apparition theory.
-/

open Nat
open RankOfApparition

/-- The Fibonacci entry point of a prime. -/
noncomputable def entryPoint (p : ℕ) : ℕ := fibRank p

/-- A number `e` is the Fibonacci entry point of `p`. -/
def IsFibEntry (p e : ℕ) : Prop :=
  0 < e ∧ p ∣ Nat.fib e ∧ ∀ k, 0 < k → k < e → ¬ p ∣ Nat.fib k

/-- A prime is primitive at index `n` if it divides `F n` but no earlier positive value. -/
def FibPrimitivePrimeAt (n p : ℕ) : Prop :=
  Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k

private theorem prime_has_rank (p : ℕ) (hp : Nat.Prime p) : HasFibRank p :=
  hasFibRank_of_pos p hp.pos

/-- The entry point is positive for every prime. -/
theorem entryPoint_pos (p : ℕ) (hp : Nat.Prime p) : 0 < entryPoint p :=
  fibRank_pos (prime_has_rank p hp)

/-- A prime divides the Fibonacci number at its entry point. -/
theorem entryPoint_spec (p : ℕ) (hp : Nat.Prime p) :
    p ∣ Nat.fib (entryPoint p) :=
  dvd_fib_fibRank (prime_has_rank p hp)

/-- The entry point is no larger than any positive index at which the prime appears. -/
theorem entryPoint_minimal (p k : ℕ) (hp : Nat.Prime p)
    (hk : 0 < k) (hkfib : p ∣ Nat.fib k) : entryPoint p ≤ k := by
  by_contra h
  exact fibRank_min hk (Nat.lt_of_not_ge h) hkfib

/-- The entry point satisfies positivity, divisibility, and minimality. -/
theorem isFibEntry_entryPoint (p : ℕ) (hp : Nat.Prime p) :
    IsFibEntry p (entryPoint p) := by
  refine ⟨entryPoint_pos p hp, entryPoint_spec p hp, ?_⟩
  intro k hk hlt
  exact fibRank_min hk hlt

/-- A prime divides `F n` exactly when its entry point divides `n`. -/
theorem dvd_fib_iff_entryPoint_dvd (p n : ℕ) (hp : Nat.Prime p) (_hn : 0 < n) :
    p ∣ Nat.fib n ↔ entryPoint p ∣ n :=
  fibRank_dvd_iff (prime_has_rank p hp) n

/-- If a prime divides `F n`, its entry point divides `n`. -/
theorem entryPoint_divides (p n : ℕ) (hp : Nat.Prime p)
    (hn : 0 < n) (hpn : p ∣ Nat.fib n) : entryPoint p ∣ n :=
  (dvd_fib_iff_entryPoint_dvd p n hp hn).mp hpn

/-- A common prime divisor of two Fibonacci numbers divides the gcd-indexed value. -/
theorem prime_dvd_fib_gcd' (p m n : ℕ) (_hp : Nat.Prime p)
    (hm : p ∣ Nat.fib m) (hn : p ∣ Nat.fib n) :
    p ∣ Nat.fib (Nat.gcd m n) := by
  rw [Nat.fib_gcd]
  exact Nat.dvd_gcd hm hn

/-- Fibonacci divisibility follows index divisibility. -/
theorem fib_dvd_of_dvd' (m n : ℕ) (h : m ∣ n) : Nat.fib m ∣ Nat.fib n :=
  Nat.fib_dvd m n h

/-- Equality of the entry point with `n` gives the primitive avoidance property. -/
theorem primitive_of_entryPoint_eq (p n : ℕ) (hp : Nat.Prime p)
    (_hpn : p ∣ Nat.fib n) (heq : entryPoint p = n) (_hn : 0 < n) :
    ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k := by
  intro k hk hkn hpk
  have hle := entryPoint_minimal p k hp hk hpk
  omega

/-- A prime whose entry point is `n` is primitive at `n`. -/
theorem entry_point_gives_primitive (p n : ℕ) (hp : Nat.Prime p)
    (hpn : p ∣ Nat.fib n) (hn : 0 < n) (h_entry_eq : entryPoint p = n) :
    FibPrimitivePrimeAt n p :=
  ⟨hp, hpn, primitive_of_entryPoint_eq p n hp hpn h_entry_eq hn⟩

/-- A smaller entry point witnesses failure of primitivity at `n`. -/
theorem not_primitive_of_entryPoint_lt (p n : ℕ) (hp : Nat.Prime p)
    (hpn : p ∣ Nat.fib n) (hn : 0 < n) (h_entry_lt : entryPoint p < n) :
    ∃ d, d ∣ n ∧ 0 < d ∧ d < n ∧ p ∣ Nat.fib d :=
  ⟨entryPoint p, entryPoint_divides p n hp hn hpn, entryPoint_pos p hp,
    h_entry_lt, entryPoint_spec p hp⟩