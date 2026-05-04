import Mathlib
import Shared.FibonacciLTE

/-! # Entry-point bridge for composite-index Fibonacci primitive divisors

This file provides the key bridge theorems connecting entry-point theory
to the composite primitive-divisor infrastructure. The central results are:

* `entryPoint`: a noncomputable function returning the entry point of a prime `p`
  (the least positive `k` with `p ∣ F(k)`)
* `entryPoint_pos`, `entryPoint_spec`, `entryPoint_minimal`: the three basic
  properties of `entryPoint`
* `entryPoint_divides`: the fundamental divisibility theorem
  (`p ∣ F(n) → entryPoint p ∣ n`)
* `prime_dvd_fib_gcd`: if `p ∣ F(m)` and `p ∣ F(n)`, then `p ∣ F(gcd m n)`

These theorems serve as the bridge between the entry-point machinery in
`FibonacciLTE.lean` and the composite primitive-divisor proofs.

## Implementation notes

The entry point is constructed via `Nat.find` applied to the existence
theorem `prime_dvd_some_pos_fib`. The three properties (`pos`, `spec`, `minimal`)
are extracted from the `IsFibEntry` predicate.
-/

open Nat

set_option maxHeartbeats 800000

/-! ## The entry point function -/

/-- The **Fibonacci entry point** (rank of apparition) of a prime `p`:
the least positive `k` such that `p ∣ F(k)`. -/
noncomputable def entryPoint (p : ℕ) : ℕ :=
  if hp : Nat.Prime p then
    Nat.find (prime_dvd_some_pos_fib p hp)
  else 0

/-- The entry point is positive for any prime. -/
theorem entryPoint_pos (p : ℕ) (hp : Nat.Prime p) : 0 < entryPoint p := by
  simp only [entryPoint, hp, dite_true]
  exact (Nat.find_spec (prime_dvd_some_pos_fib p hp)).1

/-- The prime `p` divides `F(entryPoint p)`. -/
theorem entryPoint_spec (p : ℕ) (hp : Nat.Prime p) :
    p ∣ Nat.fib (entryPoint p) := by
  simp only [entryPoint, hp, dite_true]
  exact (Nat.find_spec (prime_dvd_some_pos_fib p hp)).2

/-- The entry point is minimal: no smaller positive index has `p ∣ F(k)`. -/
theorem entryPoint_minimal (p k : ℕ) (hp : Nat.Prime p)
    (hk : 0 < k) (hkfib : p ∣ Nat.fib k) :
    entryPoint p ≤ k := by
  simp only [entryPoint, hp, dite_true]
  exact Nat.find_min' _ ⟨hk, hkfib⟩

/-- The entry point gives an `IsFibEntry` witness. -/
theorem isFibEntry_entryPoint (p : ℕ) (hp : Nat.Prime p) :
    IsFibEntry p (entryPoint p) := by
  refine ⟨entryPoint_pos p hp, entryPoint_spec p hp, fun m hm hmz hpm => ?_⟩
  exact Nat.lt_irrefl m (lt_of_lt_of_le hmz (entryPoint_minimal p m hp hm hpm))

/-! ## The fundamental divisibility theorem -/

/-- **Entry-point divisibility**: if `p ∣ F(n)` then `entryPoint p ∣ n`.

This is the key bridge lemma connecting the entry-point concept to divisibility
of indices. The proof uses the Fibonacci gcd identity
`gcd(F(m), F(n)) = F(gcd(m, n))` to show that `gcd(entryPoint p, n)` is
a positive index where `p` divides the Fibonacci number. By minimality of the
entry point, `gcd(entryPoint p, n) = entryPoint p`, hence `entryPoint p ∣ n`. -/
theorem entryPoint_divides (p n : ℕ) (hp : Nat.Prime p)
    (hn : 0 < n) (hpn : p ∣ Nat.fib n) :
    entryPoint p ∣ n :=
  isFibEntry_dvd_of_dvd (isFibEntry_entryPoint p hp) hn hpn

/-- `p ∣ F(n) ↔ entryPoint p ∣ n` (for `n > 0`). -/
theorem dvd_fib_iff_entryPoint_dvd (p n : ℕ) (hp : Nat.Prime p)
    (hn : 0 < n) :
    p ∣ Nat.fib n ↔ entryPoint p ∣ n :=
  prime_dvd_fib_iff_entry_dvd hp (isFibEntry_entryPoint p hp) hn

/-! ## Auxiliary divisibility lemmas -/

/-- If `p ∣ F(m)` and `p ∣ F(n)`, then `p ∣ F(gcd m n)`. -/
theorem prime_dvd_fib_gcd' (p m n : ℕ) (hp : Nat.Prime p)
    (hm : p ∣ Nat.fib m) (hn : p ∣ Nat.fib n) :
    p ∣ Nat.fib (Nat.gcd m n) :=
  dvd_fib_gcd_of_dvd_fib hm hn

/-- `F(m) ∣ F(n)` whenever `m ∣ n`. -/
theorem fib_dvd_of_dvd' (m n : ℕ) (h : m ∣ n) : Nat.fib m ∣ Nat.fib n :=
  Nat.fib_dvd m n h

/-! ## Entry point and primitivity -/

/-- If `entryPoint p = n`, then `p` is a primitive prime divisor of `F(n)`. -/
theorem primitive_of_entryPoint_eq (p n : ℕ) (hp : Nat.Prime p)
    (hpn : p ∣ Nat.fib n) (heq : entryPoint p = n) (hn : 0 < n) :
    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  intro k hk hkn hpk
  have : entryPoint p ≤ k := entryPoint_minimal p k hp hk hpk
  omega

/-- For composite `n`, if a prime `p ∣ F(n)` has its entry point equal to `n`,
    then `p` is a primitive prime divisor. The entry point can't equal `n`
    and also divide a proper divisor `d < n` (since `n ∤ d`). -/
theorem entry_point_gives_primitive (p n : ℕ) (hp : Nat.Prime p)
    (hpn : p ∣ Nat.fib n) (hn : 0 < n)
    (h_entry_eq : entryPoint p = n) :
    FibPrimitivePrimeAt n p := by
  exact ⟨hp, hpn, primitive_of_entryPoint_eq p n hp hpn h_entry_eq hn⟩

/-- Conversely, if `p ∣ F(n)` and `entryPoint p < n`, then `p` is NOT primitive
    for `F(n)` — it divides `F(entryPoint p)` where `entryPoint p` is a proper
    divisor of `n`. -/
theorem not_primitive_of_entryPoint_lt (p n : ℕ) (hp : Nat.Prime p)
    (hpn : p ∣ Nat.fib n) (hn : 0 < n)
    (h_entry_lt : entryPoint p < n) :
    ∃ d, d ∣ n ∧ 0 < d ∧ d < n ∧ p ∣ Nat.fib d := by
  exact ⟨entryPoint p,
    entryPoint_divides p n hp hn hpn,
    entryPoint_pos p hp,
    h_entry_lt,
    entryPoint_spec p hp⟩