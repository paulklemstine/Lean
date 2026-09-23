import Shared.PosetTheory.FibonacciApparitionSheaf

/-!
# Primitive prime divisors of Fibonacci numbers of composite index

## Note on the original contents of this file

As shipped, this file contained no Lean code at all: its entire contents were an
unapplied `diff` fragment (a `--- a/… +++ b/… @@ … @@` hunk) targeting a file
`Speculative/AutoResearch/Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers.lean`
which is not present in this repository.  Consequently the module could not be parsed and
broke the build.  The fragment is preserved verbatim in the block comment below; it is
*not* Lean source and cannot be compiled, and the `wall_base` lemma it refers to has no
surrounding context here.

-/

/- ORIGINAL FILE CONTENTS (an unapplied patch hunk, preserved verbatim):

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

-/

/-!
## Replacement contents

In place of the patch fragment we develop the part of the theory that the fragment was
reaching for and that can be established unconditionally: the *characterisation* of
primitive prime divisors by the rank of apparition (`Shared.PosetTheory.FibonacciApparitionSheaf`).

* `primitive_iff_fibRank_eq` — a prime `p` is a primitive divisor of `F n` exactly when
  `n` is its rank of apparition.
* `primitive_not_dvd_fib_of_proper_divisor` — for a *composite* index, a primitive prime
  divisor of `F n` divides `F d` for no proper divisor `d` of `n`; this is the statement
  that makes the composite case of Carmichael's theorem the hard one.
* `fib_twelve_no_primitive_divisor` — the classical exceptional index: `F 12 = 144` has no
  primitive prime divisor at all, since its only prime factors `2` and `3` already occur at
  indices `3` and `4`.  This is an honest counterexample showing that the composite case
  genuinely needs an exceptional-index hypothesis.

The deep Wall/lifting-the-exponent step alluded to by the patch fragment is *not* proved
here, and nothing below depends on it.
-/

namespace PrimitiveFibDivisors

open FibonacciApparitionSheaf

/-- `p` is a *primitive prime divisor* of `F n`: it divides `F n` but no earlier positive
Fibonacci number. -/
def IsPrimitiveAt (n p : ℕ) : Prop :=
  p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k

/-- **Primitivity is exactly "the index is the rank of apparition".** -/
theorem primitive_iff_fibRank_eq {p n : ℕ} (hp : Nat.Prime p) (hn : 0 < n) :
    IsPrimitiveAt n p ↔ fibRank p = n := by
  have hrank : HasFibRank p := hasFibRank_of_pos p hp.pos
  constructor
  · rintro ⟨hdvd, hmin⟩
    have hdvdn : fibRank p ∣ n := (fibRank_dvd_iff hrank n).mp hdvd
    have hle : fibRank p ≤ n := Nat.le_of_dvd hn hdvdn
    rcases lt_or_eq_of_le hle with hlt | heq
    · exact absurd (dvd_fib_fibRank hrank) (hmin _ (fibRank_pos hrank) hlt)
    · exact heq
  · intro heq
    refine ⟨heq ▸ dvd_fib_fibRank hrank, ?_⟩
    intro k hk hkn
    exact fibRank_min hk (heq ▸ hkn)

/-- A primitive prime divisor of `F n` divides `F d` for no proper divisor `d` of `n`.
For composite `n` this is a genuine restriction: it says the prime is new at *every*
factorisation of the index. -/
theorem primitive_not_dvd_fib_of_proper_divisor {p n d : ℕ}
    (hprim : IsPrimitiveAt n p) (hn : 0 < n) (hd : d ∣ n) (hd0 : 0 < d) (hdn : d ≠ n) :
    ¬ p ∣ Nat.fib d := by
  have hlt : d < n := lt_of_le_of_ne (Nat.le_of_dvd hn hd) hdn
  exact hprim.2 d hd0 hlt

/-- Conversely, a prime that divides `F d` for some proper positive divisor `d` of `n` is
not primitive at `n`. -/
theorem not_primitive_of_dvd_fib_proper_divisor {p n d : ℕ}
    (hd0 : 0 < d) (hdn : d < n) (hdvd : p ∣ Nat.fib d) : ¬ IsPrimitiveAt n p :=
  fun hprim => hprim.2 d hd0 hdn hdvd

/-- **The exceptional index.**  `F 12 = 144` has no primitive prime divisor: its prime
factors are `2 ∣ F 3` and `3 ∣ F 4`. -/
theorem fib_twelve_no_primitive_divisor :
    ¬ ∃ p, Nat.Prime p ∧ IsPrimitiveAt 12 p := by
  rintro ⟨p, hp, hdvd, hmin⟩
  have hf3 : Nat.fib 3 = 2 := by decide
  have hf4 : Nat.fib 4 = 3 := by decide
  have hf12 : Nat.fib 12 = 144 := by decide
  have h2 : ¬ p ∣ 2 := by
    have := hmin 3 (by norm_num) (by norm_num)
    rwa [hf3] at this
  have h3 : ¬ p ∣ 3 := by
    have := hmin 4 (by norm_num) (by norm_num)
    rwa [hf4] at this
  have h144 : p ∣ 144 := by rwa [hf12] at hdvd
  have h12 : p ∣ 12 := hp.dvd_of_dvd_pow (n := 2) (by norm_num at h144 ⊢; exact h144)
  have h26 : p ∣ 2 * 6 := by norm_num; exact h12
  rcases (Nat.Prime.dvd_mul hp).mp h26 with h | h
  · exact h2 h
  · rcases (Nat.Prime.dvd_mul hp).mp (show p ∣ 2 * 3 by norm_num; exact h) with h' | h'
    · exact h2 h'
    · exact h3 h'

end PrimitiveFibDivisors