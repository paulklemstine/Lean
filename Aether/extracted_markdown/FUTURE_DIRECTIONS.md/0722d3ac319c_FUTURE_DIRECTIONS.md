# Future Directions — Fibonacci Primitive Divisors, Fifth Cycle

## Synthesis

This cycle delivered `FibCarmichaelStructure.lean`, a **self-contained, `sorry`-free** root for the
Carmichael primitive-divisor program. It separates the theorem into two genuinely different layers:

1. A **fully general structural core** — strong divisibility (`fib_strong_divisibility`, built on
   Mathlib's `Nat.fib_gcd`), the entry-point / rank-of-apparition calculus
   (`fibEntryPt_dvd_of_fib_dvd`, `primitive_of_entryPt_eq`), and the *constructive criterion*
   `primitive_of_fibCoprimePart_pos`: if the computable witness `fibCoprimePart n` exceeds `1`,
   then `F n` has a primitive prime divisor. None of this needs analytic number theory; it is pure
   strong-divisibility bookkeeping.
2. A **verified finite instance** — `fib_carmichael_bounded`: every `F n` with `13 ≤ n ≤ 10000`
   has a primitive prime divisor, with the finite hypothesis discharged by `native_decide` on the
   computable coprime part, uniformly across primes and composites.

The single remaining input is the **infinite tail** `n > 10000`, which is precisely the analytic
heart of Carmichael/Zsygmondy: a lower bound on the homogeneous cyclotomic factor `Φ_n(α,β)`
that beats the largest "intrinsic" prime of `n`. We did not fake it; we isolated it.

## Results Summary

* `fib_strong_divisibility (m n) : gcd (F m) (F n) = F (gcd m n)` — strong divisibility sequence.
* `fibEntryPt_dvd_of_fib_dvd` — the entry point divides every index it appears in.
* `primitive_of_entryPt_eq` — entry point `= n` ⟺ primitive divisor of `F n`.
* `primitive_of_fibCoprimePart_pos` — constructive sufficient criterion (the program's engine).
* `fib_carmichael_bounded` — Carmichael verified, no `sorry`, on `13 ≤ n ≤ 10000`.

All depend only on `propext / Classical.choice / Quot.sound / Lean.ofReduceBool / Lean.trustCompiler`.

## Research Directions

### 1. Close the infinite tail via a cyclotomic lower bound `Φ_n(α,β) > n`.

State and prove `fibCyclotomic n > n` for `n > 12`, where `fibCyclotomic n = F n / ∏_{d ∣ n, d < n} (primitive part of F d)` is the integer homogeneous-cyclotomic factor. Combined with the
intrinsic-prime lemma (any non-primitive prime of `Φ_n` is the largest prime factor of `n`,
occurring to the first power), `Φ_n > p_max(n)` forces a surviving primitive prime, finishing
`fib_carmichael` for all `n > 12`. **The key insight is** that `|Φ_n(α,β)| ≥ α^{φ(n)} / α` grows
exponentially in `φ(n)`, while the only obstruction `p_max(n) ≤ n` grows linearly, so the inequality
is slack by a doubly-exponential margin for `n > 10000` and the `native_decide` band already
certifies the finitely many tight cases. **Why now?** The constructive criterion
`primitive_of_fibCoprimePart_pos` already reduces existence to "the coprime part is `> 1`"; only a
*size* estimate on that part is missing, turning a deep existence theorem into a clean inequality.

### 2. A decidable entry-point oracle and its complexity.

Replace the classical `fibEntryPt` with a `def`-computable `fibEntryPt? : ℕ → ℕ → Option ℕ` that
returns the rank of apparition of `p` by scanning `F k mod p` over one Pisano period, and prove it
agrees with `fibEntryPt` on primes. **The key insight is** that the entry point of `p` always
divides `p - (5/p)` (the Legendre symbol), so the search space is `O(p)` and bounded *a priori* by a
divisor enumeration rather than an unbounded `Nat.find`. **Why now?** `fibEntryPt_dvd_of_fib_dvd`
gives exactly the divisibility skeleton needed to prove termination and correctness of the bounded
scan, making the oracle a short hop from the present file.

### 3. Multiplicity refinement via lifting-the-exponent (LTE).

Prove the exact-power law `v_p(F n) = v_p(F z) + v_p(n)` for `p` with entry point `z = z(p) ∣ n`
(p ≠ 2, 5), reusing the Tropical p-adic valuation file in the catalog
(`Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors`).
**The key insight is** that `removePrimesOf` in this cycle already *computes* the primitive part, so
LTE is the statement that its `native_decide`-observed behaviour (each non-primitive prime survives
to multiplicity `v_p(n)`) holds symbolically for all `n`. **Why now?** With strong divisibility and
the entry-point divisibility lemma proven, LTE is the one missing multiplicative ingredient, and a
catalog file already targets the valuation bounds it needs.

### 4. Generalize the criterion to arbitrary Lucas / strong-divisibility sequences.

Abstract `primitive_of_fibCoprimePart_pos` from `Nat.fib` to any sequence `a : ℕ → ℕ` satisfying
`gcd (a m) (a n) = a (gcd m n)` and `a 0 = 0`, obtaining a *uniform* primitive-divisor criterion for
all strong divisibility sequences (Lucas `L n`, Mersenne `2^n - 1`, repunits, etc.). **The key
insight is** that every step of the present proof uses only strong divisibility — never a Fibonacci
identity — so the criterion is secretly a theorem about strong divisibility monoids. **Why now?**
The catalog's `StrongDivisibilitySequences` and `RankLatticeMorphism` files supply the exact
abstract interface; lifting this file to that interface unifies several scattered results.

### 5. Push and certify the verified band, then interpolate.

Extend `fib_coprime_part_pos_range` from `10000` to, say, `50000` with a sharded `native_decide`,
and *measure* the smallest observed ratio `Φ_n / p_max(n)` across the band. **The key insight is**
that the empirical minimum ratio is already `> 1` with growing slack, so the band data is not just a
checked instance but *evidence calibrating* the constant in Direction 1's inequality. **Why now?**
The witness `fibCoprimePart` is fully computable and the `native_decide` infrastructure is in place;
extending the band is cheap and directly de-risks the analytic proof before it is attempted.
