import Shared.PosetTheory.FibonacciApparitionSheaf

/-!
# Primitive prime divisors of Fibonacci numbers, via the rank of apparition

A prime `p` is a **primitive prime divisor** of `F n` if it divides `F n` but divides no
earlier Fibonacci number `F k` with `0 < k < n`.  This file characterises primitivity in
terms of the rank of apparition `fibRank` developed in
`Shared.PosetTheory.FibonacciApparitionSheaf`:

* `isPrimitive_iff_fibRank_eq` — `p` is primitive at `n` exactly when `fibRank p = n`;
* `dvd_fib_iff_of_primitive` — a primitive prime divisor of `F n` divides `F m` exactly when
  `n ∣ m`, so its whole set of Fibonacci multiples is the arithmetic progression `nℕ`;
* `index_unique_of_primitive` — a prime can be primitive at **at most one** index, so distinct
  indices with primitive prime divisors carry distinct primes;
* `primitive_dvd_of_dvd_of_lt` — the contrapositive form: if `p ∣ F n` and `p` is primitive at
  `m ≤ n`, then `m ∣ n`.

The original content of this file was a stray unified-diff fragment (not Lean source); it is
retained verbatim in the comment below.

Original fragment, retained for the record:

```
--- a/Speculative/AutoResearch/Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers.lean
+++ b/Speculative/AutoResearch/Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers.lean
@@ -99,6 +99,9 @@
     (show p ∣ Nat.fib (n + 1) from by rwa [← ZMod.natCast_eq_zero_iff]))
     (by aesop)

+/-- Key helper: F(np)/F(n) ≡ p · F(n+1)^{p-1} (mod p²).
+    Since gcd(F(n+1), p) = 1, Fermat gives F(n+1)^{p-1} ≡ 1 (mod p),
+    so F(np)/F(n) ≡ p (mod p²), hence v_p(F(np)/F(n)) = 1. -/
 -- Wall base case: v_p(F(np)/F(n)) = 1 for odd prime p | F(n)
 lemma wall_base (n p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2)
     (hpn : p ∣ Nat.fib n) (hn : 2 ≤ n) :
```
-/

namespace PrimitiveFibonacciDivisors

open FibonacciApparitionSheaf

/-- `p` is a primitive prime divisor of `F n`. -/
def IsPrimitivePrimeDivisor (n p : ℕ) : Prop :=
  Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k

/-- **Primitivity is exactly the rank of apparition.** -/
theorem isPrimitive_iff_fibRank_eq {n p : ℕ} (hp : Nat.Prime p) (hn : 0 < n) :
    IsPrimitivePrimeDivisor n p ↔ p ∣ Nat.fib n ∧ fibRank p = n := by
  have hrank : HasFibRank p := hasFibRank_of_pos p hp.pos
  constructor
  · rintro ⟨-, hdvd, hmin⟩
    refine ⟨hdvd, ?_⟩
    have hle : fibRank p ≤ n := Nat.sInf_le ⟨hn, hdvd⟩
    rcases lt_or_eq_of_le hle with hlt | heq
    · exact absurd (dvd_fib_fibRank hrank) (hmin _ (fibRank_pos hrank) hlt)
    · exact heq
  · rintro ⟨hdvd, heq⟩
    refine ⟨hp, hdvd, fun k hk hkn hdk => ?_⟩
    exact fibRank_min hk (heq ▸ hkn) hdk

/-- A primitive prime divisor of `F n` divides exactly the Fibonacci numbers whose index is a
multiple of `n`. -/
theorem dvd_fib_iff_of_primitive {n p : ℕ} (hn : 0 < n) (h : IsPrimitivePrimeDivisor n p)
    (m : ℕ) : p ∣ Nat.fib m ↔ n ∣ m := by
  have hp : Nat.Prime p := h.1
  have hrank : HasFibRank p := hasFibRank_of_pos p hp.pos
  have heq : fibRank p = n := ((isPrimitive_iff_fibRank_eq hp hn).mp h).2
  rw [fibRank_dvd_iff hrank m, heq]

/-- A prime is primitive at **at most one** index. -/
theorem index_unique_of_primitive {m n p : ℕ} (hm : 0 < m) (hn : 0 < n)
    (hpm : IsPrimitivePrimeDivisor m p) (hpn : IsPrimitivePrimeDivisor n p) : m = n := by
  have hp : Nat.Prime p := hpm.1
  have h1 : fibRank p = m := ((isPrimitive_iff_fibRank_eq hp hm).mp hpm).2
  have h2 : fibRank p = n := ((isPrimitive_iff_fibRank_eq hp hn).mp hpn).2
  rw [← h1, h2]

/-- If `p` is primitive at `m` and divides `F n`, then `m ∣ n`; in particular `m ≤ n` for
`n > 0`. -/
theorem primitive_dvd_of_dvd {m n p : ℕ} (hm : 0 < m) (hpm : IsPrimitivePrimeDivisor m p)
    (hdvd : p ∣ Nat.fib n) : m ∣ n :=
  (dvd_fib_iff_of_primitive hm hpm n).mp hdvd

/-- Distinct indices cannot share a primitive prime divisor: the primitive primes of `F m` and
`F n` are disjoint for `m ≠ n`. -/
theorem primitive_primes_disjoint {m n p : ℕ} (hm : 0 < m) (hn : 0 < n) (hmn : m ≠ n) :
    ¬(IsPrimitivePrimeDivisor m p ∧ IsPrimitivePrimeDivisor n p) := by
  rintro ⟨h1, h2⟩
  exact hmn (index_unique_of_primitive hm hn h1 h2)

end PrimitiveFibonacciDivisors