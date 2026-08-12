# Computational evidence: three structural barriers to integer factorization

All numbers below were produced with `#eval` inside the project's Lean toolchain
(exact integer arithmetic, no floating point). The sweep enumerates every semiprime
`N = p·q` with `p < q < 60`, i.e. **136 moduli**, and evaluates candidate invariants
on each. The concrete instances of these observations are re-verified as theorems in
`Catalog/Pythagorean/FactoringBarriers/LabNotes.lean`.

## 1. Barrier I: `gcd(f(N), N) = gcd(f(0), N)`

Seven integer polynomials (given by coefficient lists, lowest degree first) were tested
against all 136 semiprimes — **952 checks, all passed**:

```
f ∈ { x²+5x+6, x³−7x+12, 3x⁵+2x−30, x²+1, x, x⁴+x, x²+210 }
∀ f, ∀ N : gcd(f(N), N) = gcd(f(0), N)        -->  [true, true, true, true, true, true, true]
```

## 2. Which semiprimes are split, and by which primes

| invariant `f` | `f(0)` | semiprimes split (of 136) | distinct primes revealed |
|---|---|---|---|
| `x² + 5x + 6`  | `6`   | 30 | `{2, 3}` |
| `x³ − 7x + 12` | `12`  | 30 | `{2, 3}` |
| `3x⁵ + 2x − 30`| `−30` | 42 | `{2, 3, 5}` |
| `x² + 1`       | `1`   | 0  | `∅` |
| `x`            | `0`   | 0  | `∅` (witness `= N`, never a proper factor) |
| `x⁴ + x`       | `0`   | 0  | `∅` |
| `x² + 210`     | `210` | 52 | `{2, 3, 5, 7}` |

The revealed primes are in every case **exactly** the prime factors of `f(0)`, and
never depend on `N`. This is the experimental content of
`polyWitness_eq_gcd_const`, `mem_revealedPrimes_of_splits_prime` and the quantitative
bound `card_revealedPrimes_le_log` (`|{2,3,5,7}| = 4 ≤ log₂ 210 = 7`).

## 3. Counterexample hunt for the universal-witness claim

No polynomial in the sample split a semiprime both of whose primes exceeded `|f(0)|`
— consistent with the sharp theorem `splits_imp_small_prime_factor`
(`min p q ≤ |f(0)|` whenever `f` splits `p·q`). The hunt for a counterexample failed,
and the theorem explains why it must.

## 4. The `p − 1` escape and its two failure modes

Number of the 136 semiprimes split by the witness `gcd(2^m − 1 mod N, N)`:

| exponent `m` | 2 | 4 | 6 | 12 | 24 | 120 | 8! = 40320 |
|---|---|---|---|---|---|---|---|
| semiprimes split | 16 | 30 | 30 | 52 | 60 | 72 | 60 |

Two observations, both now theorems:

* growing `m` helps at first (`pollard_splits`: if `p−1 ∣ m`, `p ∤ a`, `q ∤ a^m − 1`,
  the witness *is* the prime `p`);
* but it then hurts — at `m = 8!` the count drops back to 60, because for many moduli
  both `p−1` and `q−1` divide `m` and the witness returns all of `N`
  (`pollard_fails_when_both_smooth`).

For any **fixed** `m` the quantity `2^m − 1` is a constant, i.e. a constant polynomial,
so Barrier I applies verbatim: `no_universal_fixed_exponent_pollard`. The measured
growth of the split count with `m` is therefore not a counterexample to Barrier I; it
is the signature of an invariant whose *size grows with the input*, which is exactly
the loophole the barrier leaves open (`escape_requires_growing_exponent`).

## 5. OEIS

No new integer sequence is produced by this work; the counting data above is a
function of the sample range and of `|f(0)|`, not a canonical sequence, so no OEIS
identification is claimed.
