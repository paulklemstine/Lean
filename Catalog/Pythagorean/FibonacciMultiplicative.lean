import Mathlib
import Speculative.AutoResearch.FibonacciApparition

/-! # Multiplicative Structure of the Fibonacci Rank of Apparition

Domain: Number Theory (cross-domain bridge from the catalog `FibonacciApparition`).

This file upgrades the **single-modulus law of apparition**
(`FibonacciApparition.fib_dvd_iff_fibEntry_dvd`: `m ∣ F k ↔ fibEntry m ∣ k`) to a statement
about how the rank of apparition `fibEntry` interacts with the *multiplicative structure of
the modulus*.

The central result is that `fibEntry` is an **lcm-homomorphism on the coprime-modulus monoid**:
for coprime `m, n > 0`,
`fibEntry (m * n) = lcm (fibEntry m) (fibEntry n)` (`fibEntry_mul_coprime`).
The proof is a clean local-to-global (CRT) argument: `m*n ∣ F k` splits into `m ∣ F k` and
`n ∣ F k` exactly when `m, n` are coprime, and each of those is the law of apparition for a
smaller modulus.

Coprimality is **necessary**, not cosmetic: at `m = n = 2` the formula already fails, because
`fibEntry 4 = 6` while `lcm (fibEntry 2) (fibEntry 2) = lcm 3 3 = 3`
(`fibEntry_mul_coprime_fails`). The factor-of-`2` gap is the prime-power "Wall delay" that the
lcm formula cannot see; this is the structural reason entry-point theory splits into a coprime
(CRT) part and a hard prime-power (Wall) part.

Supporting infrastructure:
* `fibEntry_dvd_of_dvd` — divisibility-monotonicity `a ∣ b → fibEntry a ∣ fibEntry b`, the
  "functorial" backbone that makes `fibEntry` a monotone map of divisibility lattices;
* `fibEntry_eq_of` — an evaluation principle pinning the *noncomputable* `fibEntry` (defined via
  `Nat.find` / `Classical`) from a "divides here, nowhere earlier" certificate.

As corollaries we obtain the divisibility-lattice morphism inequalities
`fibEntry_gcd_dvd` and `lcm_dvd_fibEntry_lcm`, and the base case of the prime-power
divisibility tower `fibEntry_dvd_prime_pow`.

The whole development rests only on the catalog file `FibonacciApparition`.
-/

namespace FibonacciApparition

open Nat

/-! ## §1. The functorial backbone: divisibility-monotonicity -/

/-
!-- From `a ∣ b` and `b ∣ F(fibEntry b)` we get `a ∣ F(fibEntry b)`; the law of apparition
then yields `fibEntry a ∣ fibEntry b`. -- !--

**Divisibility-monotonicity of the entry point.** If `a ∣ b` (with `b > 0`), then the rank
of apparition of `a` divides that of `b`. This is the "functorial" half of the theory: it makes
`fibEntry` a monotone map of divisibility lattices.
-/
lemma fibEntry_dvd_of_dvd {a b : ℕ} (hb : 0 < b) (hab : a ∣ b) :
    fibEntry a ∣ fibEntry b := by
  by_cases ha : 0 < a;
  · exact FibonacciApparition.fib_dvd_iff_fibEntry_dvd a ha ( fibEntry b ) |>.1 ( dvd_trans hab ( FibonacciApparition.fibEntry_dvd_fib b hb ) );
  · aesop

/-! ## §2. An evaluation principle for the noncomputable entry point -/

/-
!-- `fibEntry m ≤ k` by minimality and `k ≤ fibEntry m` because below the entry point nothing
is divisible; `le_antisymm` closes it. -- !--

**Evaluation principle.** If `m ∣ F k` for some `k > 0` and `m` divides no earlier positive
Fibonacci number, then `fibEntry m = k`. This converts the noncomputable `fibEntry` into honest
numeric values.
-/
lemma fibEntry_eq_of {m k : ℕ} (hm : 0 < m) (hk : 0 < k) (hdvd : m ∣ Nat.fib k)
    (hmin : ∀ j, 0 < j → j < k → ¬ m ∣ Nat.fib j) : fibEntry m = k := by
  exact le_antisymm ( fibEntry_le m k hk hdvd ) ( Nat.le_of_not_gt fun h => hmin _ ( fibEntry_pos m hm ) h ( fibEntry_dvd_fib m hm ) )

/-! ## §3. Concrete values (counterexample ingredients) -/

/-
!-- `F 3 = 2` is divisible by `2`, while `F 1 = F 2 = 1` are not; apply `fibEntry_eq_of`. -- !--

The smallest concrete entry point: `fibEntry 2 = 3`.
-/
lemma fibEntry_two : fibEntry 2 = 3 := by
  rw [ fibEntry_eq_of ] <;> norm_num;
  intro j hj₁ hj₂; interval_cases j <;> trivial;

/-
!-- `F 6 = 8` is divisible by `4`, while `F 1..5 ∈ {1,1,2,3,5}` are not; apply `fibEntry_eq_of`.
This is the first prime-power value exhibiting "Wall delay". -- !--

The first prime-power entry point exhibiting Wall delay: `fibEntry 4 = 6`.
-/
lemma fibEntry_four : fibEntry 4 = 6 := by
  apply fibEntry_eq_of;
  · norm_num;
  · norm_num;
  · decide;
  · intro j hj₁ hj₂; interval_cases j <;> trivial;

/-! ## §4. The headline result: lcm-homomorphism on coprime moduli -/

/-
!-- `lcm ∣ fibEntry (m*n)` from `fibEntry_dvd_of_dvd` applied to `m ∣ m*n`, `n ∣ m*n`.
Conversely `m, n ∣ F(lcm)` by the law of apparition, so (coprime) `m*n ∣ F(lcm)`, giving
`fibEntry (m*n) ∣ lcm`. `dvd_antisymm` finishes. -- !--

**The rank of apparition is an lcm-homomorphism on coprime moduli.** For coprime `m, n > 0`,
`fibEntry (m * n) = lcm (fibEntry m) (fibEntry n)`. This is the Chinese-Remainder upgrade of the
law of apparition `FibonacciApparition.fib_dvd_iff_fibEntry_dvd`.
-/
theorem fibEntry_mul_coprime {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (hco : Nat.Coprime m n) :
    fibEntry (m * n) = Nat.lcm (fibEntry m) (fibEntry n) := by
  refine' Nat.dvd_antisymm _ _;
  · apply FibonacciApparition.fib_dvd_iff_fibEntry_dvd (m * n) (by positivity) (Nat.lcm (fibEntry m) (fibEntry n)) |>.1;
    refine' Nat.Coprime.mul_dvd_of_dvd_of_dvd hco _ _;
    · exact dvd_trans ( fibEntry_dvd_fib m hm ) ( Nat.fib_dvd _ _ ( Nat.dvd_lcm_left _ _ ) );
    · exact FibonacciApparition.fib_dvd_iff_fibEntry_dvd n hn _ |>.2 ( Nat.dvd_lcm_right _ _ );
  · exact Nat.lcm_dvd ( fibEntry_dvd_of_dvd ( by positivity ) ( by exact dvd_mul_right _ _ ) ) ( fibEntry_dvd_of_dvd ( by positivity ) ( by exact dvd_mul_left _ _ ) )

/-! ## §5. Coprimality is necessary (disproof of the naive generalization) -/

/-
!-- `fibEntry (2*2) = fibEntry 4 = 6` but `lcm (fibEntry 2) (fibEntry 2) = lcm 3 3 = 3`. -- !--

**Coprimality is essential.** The lcm formula already fails at `m = n = 2`, where the two
sides differ by exactly the prime-power Wall delay (a factor of `2`).
-/
theorem fibEntry_mul_coprime_fails :
    fibEntry (2 * 2) ≠ Nat.lcm (fibEntry 2) (fibEntry 2) := by
  rw [ fibEntry_four, fibEntry_two ] ; decide

/-! ## §6. The divisibility-lattice morphism corollaries (Direction 3) -/

/-
!-- `gcd a b ∣ a`, so `fibEntry_dvd_of_dvd` gives `fibEntry (gcd a b) ∣ fibEntry a`, and
likewise for `b`; hence it divides their gcd. -- !--

`fibEntry` of a gcd divides the gcd of the `fibEntry`s.
-/
theorem fibEntry_gcd_dvd {a b : ℕ} (ha : 0 < a) (hb : 0 < b) :
    fibEntry (Nat.gcd a b) ∣ Nat.gcd (fibEntry a) (fibEntry b) := by
  exact Nat.dvd_gcd ( fibEntry_dvd_of_dvd ha ( Nat.gcd_dvd_left _ _ ) ) ( fibEntry_dvd_of_dvd hb ( Nat.gcd_dvd_right _ _ ) )

/-
!-- `a ∣ lcm a b`, so `fibEntry_dvd_of_dvd` gives `fibEntry a ∣ fibEntry (lcm a b)`, and
likewise for `b`; hence their lcm divides `fibEntry (lcm a b)`. -- !--

The lcm of the `fibEntry`s divides `fibEntry` of the lcm.
-/
theorem lcm_dvd_fibEntry_lcm {a b : ℕ} (ha : 0 < a) (hb : 0 < b) :
    Nat.lcm (fibEntry a) (fibEntry b) ∣ fibEntry (Nat.lcm a b) := by
  refine' Nat.lcm_dvd _ _;
  · exact fibEntry_dvd_of_dvd ( Nat.lcm_pos ha hb ) ( Nat.dvd_lcm_left _ _ );
  · exact fibEntry_dvd_of_dvd ( Nat.lcm_pos ha hb ) ( Nat.dvd_lcm_right _ _ )

/-! ## §7. Base case of the prime-power divisibility tower (Direction 2) -/

/-
!-- `p ∣ p^2`, so `fibEntry_dvd_of_dvd` applies directly. -- !--

**Base case of the prime-power tower.** For a prime `p`, `fibEntry p ∣ fibEntry (p^2)`.
-/
theorem fibEntry_dvd_prime_pow {p : ℕ} (hp : Nat.Prime p) :
    fibEntry p ∣ fibEntry (p ^ 2) := by
  exact fibEntry_dvd_of_dvd ( pow_pos hp.pos 2 ) ( dvd_pow_self _ two_ne_zero )

/-! ## §8. Demonstrations -/

example : fibEntry 2 = 3 := fibEntry_two
example : fibEntry 4 = 6 := fibEntry_four

-- The lcm-homomorphism in action on coprime moduli `2` and `3` (so `fibEntry 6 = lcm 3 4 = 12`).
example : fibEntry 6 = Nat.lcm (fibEntry 2) (fibEntry 3) := by
  have := fibEntry_mul_coprime (m := 2) (n := 3) (by norm_num) (by norm_num) (by decide)
  simpa using this

end FibonacciApparition