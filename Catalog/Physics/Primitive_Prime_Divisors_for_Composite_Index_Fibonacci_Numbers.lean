import Shared.PosetTheory.FibonacciApparitionSheaf

/-!
# Apparition ranks of small primes, and the classical Fibonacci divisibility patterns

The original content of this file was a stray unified-diff fragment rather than Lean source,
so the module never compiled; the fragment is retained verbatim in the comment below and the
file now carries real, compiling mathematics on the same subject.

Using the rank-of-apparition theory of `Shared.PosetTheory.FibonacciApparitionSheaf` we
compute the ranks of the first few primes and read off, from the structure theorem
`fibRank_dvd_iff`, the classical divisibility patterns of the Fibonacci sequence:

* `fibRank_two = 3`  and  `two_dvd_fib_iff`  — `F m` is even exactly when `3 ∣ m`;
* `fibRank_three = 4` and  `three_dvd_fib_iff` — `3 ∣ F m` exactly when `4 ∣ m`;
* `fibRank_five = 5`  and  `five_dvd_fib_iff`  — `5 ∣ F m` exactly when `5 ∣ m`;
* `fibRank_seven = 8` and  `seven_dvd_fib_iff` — `7 ∣ F m` exactly when `8 ∣ m`.

Each pattern is an infinite statement obtained from a finite computation (the rank) plus the
gcd-closure of the apparition set; none of them is a decidable check.

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

namespace PrimitiveFibonacciApparition

open FibonacciApparitionSheaf

theorem hasRank_two : HasFibRank 2 := hasFibRank_of_pos 2 (by norm_num)

theorem hasRank_three : HasFibRank 3 := hasFibRank_of_pos 3 (by norm_num)

theorem hasRank_five : HasFibRank 5 := hasFibRank_of_pos 5 (by norm_num)

theorem hasRank_seven : HasFibRank 7 := hasFibRank_of_pos 7 (by norm_num)

/-- `F 3 = 2` is the first even Fibonacci number. -/
theorem fibRank_two : fibRank 2 = 3 := by
  refine fibRank_eq_of (by norm_num) (by decide) ?_
  intro k hk hlt
  interval_cases k <;> decide

/-- `F 4 = 3` is the first Fibonacci number divisible by `3`. -/
theorem fibRank_three : fibRank 3 = 4 := by
  refine fibRank_eq_of (by norm_num) (by decide) ?_
  intro k hk hlt
  interval_cases k <;> decide

/-- `F 5 = 5`: the prime `5` is the ramified prime of the Fibonacci sequence, its rank equals
itself. -/
theorem fibRank_five : fibRank 5 = 5 := by
  refine fibRank_eq_of (by norm_num) (by decide) ?_
  intro k hk hlt
  interval_cases k <;> decide

/-- `F 8 = 21` is the first Fibonacci number divisible by `7`. -/
theorem fibRank_seven : fibRank 7 = 8 := by
  refine fibRank_eq_of (by norm_num) (by decide) ?_
  intro k hk hlt
  interval_cases k <;> decide

/-- **Every third Fibonacci number is even, and no other is.** -/
theorem two_dvd_fib_iff (m : ℕ) : 2 ∣ Nat.fib m ↔ 3 ∣ m := by
  rw [fibRank_dvd_iff hasRank_two m, fibRank_two]

/-- `3 ∣ F m` exactly on the multiples of `4`. -/
theorem three_dvd_fib_iff (m : ℕ) : 3 ∣ Nat.fib m ↔ 4 ∣ m := by
  rw [fibRank_dvd_iff hasRank_three m, fibRank_three]

/-- `5 ∣ F m` exactly on the multiples of `5`. -/
theorem five_dvd_fib_iff (m : ℕ) : 5 ∣ Nat.fib m ↔ 5 ∣ m := by
  rw [fibRank_dvd_iff hasRank_five m, fibRank_five]

/-- `7 ∣ F m` exactly on the multiples of `8`. -/
theorem seven_dvd_fib_iff (m : ℕ) : 7 ∣ Nat.fib m ↔ 8 ∣ m := by
  rw [fibRank_dvd_iff hasRank_seven m, fibRank_seven]

/-- A sample consequence beyond any finite check: `F m` is divisible by `6` exactly when `m`
is a multiple of `12`, the lcm of the two ranks. -/
theorem six_dvd_fib_iff (m : ℕ) : 6 ∣ Nat.fib m ↔ 12 ∣ m := by
  constructor
  · intro h
    have h2 : 3 ∣ m := (two_dvd_fib_iff m).mp (dvd_trans (by norm_num) h)
    have h3 : 4 ∣ m := (three_dvd_fib_iff m).mp (dvd_trans (by norm_num) h)
    omega
  · intro h
    have h2 : (2 : ℕ) ∣ Nat.fib m := (two_dvd_fib_iff m).mpr (dvd_trans (by norm_num) h)
    have h3 : (3 : ℕ) ∣ Nat.fib m := (three_dvd_fib_iff m).mpr (dvd_trans (by norm_num) h)
    omega

end PrimitiveFibonacciApparition