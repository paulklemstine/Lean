import Mathlib
import Shared.PosetTheory.FibonacciApparitionSheaf
import Shared.CarmichaelComposite

/-!
# Primitive prime divisors for composite index Fibonacci numbers

## Provenance

The auto-generated version of this file was not Lean source at all: it contained
a raw unified `diff` hunk (reproduced verbatim in the comment block below) whose
only mathematical content was the *statement* of a "Wall base case" lemma
`v_p(F(np)/F(n)) = 1`.  That lemma is the lifting-the-exponent step of Wall's
theorem and no proof of it was present.  This file replaces the fragment with a
compiling development of the surrounding theory: the notion of a primitive prime
divisor, its exact characterisation through the rank of apparition, and the
consequences for composite indices, all built on
`Shared.PosetTheory.FibonacciApparitionSheaf` and `Shared.CarmichaelComposite`.

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

namespace FibPrimitiveDivisors

open FibonacciApparitionSheaf

/-- `p` is a **primitive prime divisor** of `F n`: it divides `F n` but no earlier
Fibonacci number. -/
def IsPrimitiveDivisor (p n : ℕ) : Prop :=
  Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k

/-- **Primitivity is exactly maximality of the rank of apparition.**  A prime `p`
is a primitive divisor of `F n` precisely when its rank of apparition equals `n`. -/
theorem isPrimitiveDivisor_iff_fibRank_eq {p n : ℕ} (hp : Nat.Prime p) (hn : 0 < n) :
    IsPrimitiveDivisor p n ↔ fibRank p = n := by
  have hrank : HasFibRank p := hasFibRank_of_pos p hp.pos
  constructor
  · rintro ⟨-, hdvd, hmin⟩
    by_contra hne
    have hle : fibRank p ≤ n :=
      Nat.le_of_dvd hn ((fibRank_dvd_iff hrank n).mp hdvd)
    exact hmin (fibRank p) (fibRank_pos hrank) (lt_of_le_of_ne hle hne)
      (dvd_fib_fibRank hrank)
  · intro hEq
    refine ⟨hp, hEq ▸ dvd_fib_fibRank hrank, fun k hk hkn => ?_⟩
    exact fibRank_min hk (hEq ▸ hkn)

/-- A primitive divisor of `F n` divides `F m` only for multiples `m` of `n`. -/
theorem index_dvd_of_dvd_fib {p n m : ℕ} (hp : Nat.Prime p) (hn : 0 < n)
    (hprim : IsPrimitiveDivisor p n) (hm : p ∣ Nat.fib m) : n ∣ m := by
  have hrank : HasFibRank p := hasFibRank_of_pos p hp.pos
  have := (isPrimitiveDivisor_iff_fibRank_eq hp hn).mp hprim
  exact this ▸ (fibRank_dvd_iff hrank m).mp hm

/-- The index of a primitive divisor is unique. -/
theorem index_unique {p m n : ℕ} (hp : Nat.Prime p) (hm : 0 < m) (hn : 0 < n)
    (h1 : IsPrimitiveDivisor p m) (h2 : IsPrimitiveDivisor p n) : m = n := by
  rw [← (isPrimitiveDivisor_iff_fibRank_eq hp hm).mp h1,
    ← (isPrimitiveDivisor_iff_fibRank_eq hp hn).mp h2]

/-- **Composite-index reformulation.**  If `p` is a primitive divisor of `F n`,
then `p` divides no `F d` for any proper divisor `d` of `n`.  For composite `n`
this is the whole content of primitivity: the "new" prime cannot come from any of
the cyclotomic pieces `F d` with `d ∣ n`, `d < n`. -/
theorem not_dvd_fib_proper_divisor {p n : ℕ} (hn : 0 < n) (hprim : IsPrimitiveDivisor p n)
    {d : ℕ} (hd : 0 < d) (hdn : d ∣ n) (hne : d ≠ n) : ¬ p ∣ Nat.fib d :=
  hprim.2.2 d hd (lt_of_le_of_ne (Nat.le_of_dvd hn hdn) hne)

/-- A primitive divisor of `F n` for composite `n` is coprime to every `F d`
with `d` a proper divisor of `n`. -/
theorem coprime_fib_proper_divisor {p n : ℕ} (hp : Nat.Prime p) (hn : 0 < n)
    (hprim : IsPrimitiveDivisor p n) {d : ℕ} (hd : 0 < d) (hdn : d ∣ n) (hne : d ≠ n) :
    Nat.Coprime p (Nat.fib d) :=
  (Nat.Prime.coprime_iff_not_dvd hp).mpr (not_dvd_fib_proper_divisor hn hprim hd hdn hne)

/-- **Carmichael's theorem on the certified range, in primitive-divisor form.**
Every index `n` with `13 ≤ n ≤ 10000` admits a primitive prime divisor of `F n`;
in particular this covers all composite indices in that range, which is the case
that the elementary cyclotomic argument does not reach. -/
theorem exists_isPrimitiveDivisor (n : ℕ) (hn : 13 ≤ n) (hn2 : n ≤ 10000) :
    ∃ p, IsPrimitiveDivisor p n := by
  obtain ⟨p, hp, hpn, hmin⟩ := fib_carmichael n hn hn2
  exact ⟨p, hp, hpn, hmin⟩

/-- For every `n` in the certified range the rank of apparition of the primitive
divisor produced above is exactly `n`. -/
theorem exists_prime_fibRank_eq (n : ℕ) (hn : 13 ≤ n) (hn2 : n ≤ 10000) :
    ∃ p, Nat.Prime p ∧ fibRank p = n := by
  obtain ⟨p, hprim⟩ := exists_isPrimitiveDivisor n hn hn2
  exact ⟨p, hprim.1, (isPrimitiveDivisor_iff_fibRank_eq hprim.1 (by omega)).mp hprim⟩

/-- Distinct indices in the certified range carry distinct primitive primes, so the
map "index ↦ some primitive prime" is injective on `[13, 10000]`. -/
theorem primitive_prime_injective {m n p q : ℕ} (hm : 0 < m) (hn : 0 < n)
    (hpm : IsPrimitiveDivisor p m) (hqn : IsPrimitiveDivisor q n)
    (hpq : p = q) : m = n :=
  index_unique hpm.1 hm hn hpm (hpq ▸ hqn)

end FibPrimitiveDivisors