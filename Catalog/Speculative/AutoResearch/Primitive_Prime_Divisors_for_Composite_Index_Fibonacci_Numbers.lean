import Shared.PosetTheory.FibonacciApparitionSheaf

/-! # Primitive prime divisors of Fibonacci numbers at composite indices

A prime `p` is *primitive* at index `n` when `p ∣ F n` but `p ∤ F k` for every
`0 < k < n`.  Everything about primitivity is controlled by the rank of apparition
`fibRank p` developed in `Shared.PosetTheory.FibonacciApparitionSheaf`:
`p ∣ F k ↔ fibRank p ∣ k`.  Consequently

* `p` is primitive at `n` exactly when `fibRank p = n`;
* primitivity — an a priori infinite condition over all `k < n` — is equivalent to the
  finite condition that `p` divides no `F d` for a **proper divisor** `d` of `n`.  This is
  what makes the composite-index case checkable at all;
* a prime is primitive for at most one index.

The file previously contained a truncated unified-diff fragment of an abandoned
lifting-the-exponent argument (a `wall_base` lemma with no proof).  Since it was never
Lean source and cannot be compiled, it is preserved verbatim in the comment block below
and replaced by the rank-of-apparition development, which is complete and sorry-free.

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

open FibonacciApparitionSheaf

namespace PrimitiveFibDivisors

/-- `p` is a primitive divisor of `F n`: it divides `F n` and no earlier positive
Fibonacci number. -/
def IsPrimitiveAt (n p : ℕ) : Prop :=
  p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k

/-- Primitivity at `n` is exactly the statement that the rank of apparition equals `n`. -/
theorem isPrimitiveAt_iff_fibRank_eq {p n : ℕ} (hp : 0 < p) (hn : 0 < n) :
    IsPrimitiveAt n p ↔ fibRank p = n := by
  have hrank : HasFibRank p := hasFibRank_of_pos p hp
  constructor
  · rintro ⟨hdvd, hmin⟩
    have hdd : fibRank p ∣ n := (fibRank_dvd_iff hrank n).mp hdvd
    have hle : fibRank p ≤ n := Nat.le_of_dvd hn hdd
    rcases lt_or_eq_of_le hle with hlt | heq
    · exact absurd (dvd_fib_fibRank hrank) (hmin _ (fibRank_pos hrank) hlt)
    · exact heq
  · intro heq
    refine ⟨heq ▸ dvd_fib_fibRank hrank, ?_⟩
    intro k hk hlt
    exact fibRank_min hk (heq ▸ hlt)

/-- **Primitivity is a finite condition.**  A prime dividing `F n` is primitive there as
soon as it divides no `F d` for a *proper divisor* `d` of `n`; the infinitely many
intermediate indices `k < n` that are not divisors of `n` need not be inspected. -/
theorem primitive_iff_proper_divisors {p n : ℕ} (hp : 0 < p)
    (hpn : p ∣ Nat.fib n) :
    (∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k) ↔
      (∀ d, d ∣ n → 0 < d → d < n → ¬ p ∣ Nat.fib d) := by
  have hrank : HasFibRank p := hasFibRank_of_pos p hp
  constructor
  · intro h d _ hd hlt
    exact h d hd hlt
  · intro h k hk hlt hdvd
    have hdd : fibRank p ∣ n := (fibRank_dvd_iff hrank n).mp hpn
    have hkr : fibRank p ∣ k := (fibRank_dvd_iff hrank k).mp hdvd
    have hrlt : fibRank p < n := lt_of_le_of_lt (Nat.le_of_dvd hk hkr) hlt
    exact h (fibRank p) hdd (fibRank_pos hrank) hrlt (dvd_fib_fibRank hrank)

/-- A prime is primitive for at most one Fibonacci index. -/
theorem primitive_index_unique {p m n : ℕ} (hp : 0 < p) (hm : 0 < m) (hn : 0 < n)
    (hpm : IsPrimitiveAt m p) (hpn : IsPrimitiveAt n p) : m = n := by
  rw [isPrimitiveAt_iff_fibRank_eq hp hm] at hpm
  rw [isPrimitiveAt_iff_fibRank_eq hp hn] at hpn
  omega

/-- At a composite index `n = a * b` (with `1 < a, 1 < b`), a primitive divisor divides
neither `F a` nor `F b`, even though both `F a` and `F b` divide `F n`. -/
theorem primitive_avoids_factors {p a b : ℕ} (ha : 1 < a) (hb : 1 < b)
    (hprim : IsPrimitiveAt (a * b) p) :
    ¬ p ∣ Nat.fib a ∧ ¬ p ∣ Nat.fib b := by
  obtain ⟨-, hmin⟩ := hprim
  have ha' : a < a * b := by nlinarith
  have hb' : b < a * b := by nlinarith
  exact ⟨hmin a (by omega) ha', hmin b (by omega) hb'⟩

/-- Conversely, the Fibonacci numbers at proper divisors of a composite index always
divide `F n`, so their prime divisors are exactly the *imprimitive* ones. -/
theorem fib_proper_divisor_dvd {d n : ℕ} (h : d ∣ n) : Nat.fib d ∣ Nat.fib n :=
  Nat.fib_dvd d n h

/-- A prime dividing `F d` for some earlier positive index `d` (in particular for a proper
divisor `d` of `n`) is never primitive at `n`. -/
theorem not_primitive_of_dvd_lt {p n d : ℕ} (hdpos : 0 < d) (hlt : d < n)
    (hpd : p ∣ Nat.fib d) : ¬ IsPrimitiveAt n p := by
  rintro ⟨-, hmin⟩
  exact hmin d hdpos hlt hpd

end PrimitiveFibDivisors