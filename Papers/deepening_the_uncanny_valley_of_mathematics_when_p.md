# Computational Evidence: The Uncanny Valley of Prime-Generating Formulas

## 1. Small-case calculations for Euler's polynomial `E(n) = n² + n + 41`

| n  | E(n) | prime? |
|----|------|--------|
| 0  | 41   | yes |
| 1  | 43   | yes |
| 2  | 47   | yes |
| 3  | 53   | yes |
| 4  | 61   | yes |
| 5  | 71   | yes |
| 10 | 151  | yes |
| 20 | 461  | yes |
| 30 | 971  | yes |
| 39 | 1601 | yes |
| **40** | **1681 = 41²** | **NO** |

The formula is prime for all 40 inputs `n = 0, …, 39` and first fails at `n = 40`,
where `E(40) = 1600 + 40 + 41 = 1681 = 41²`. This is the archetypal "uncanny
valley" formula: astonishingly accurate over a finite window, yet not a genuine
prime formula. Note the mechanism: `E(40) = 40² + 40 + 41`, and modulo `41` we
have `E(40) ≡ 40² + 40 + 41 ≡ (-1)² + (-1) + 0 = 0`, so `41 ∣ E(40)` — a direct
instance of the divisibility engine `E(a) ∣ E(a + k·E(a))` with `a = 0`,
`E(0) = 41`, `k = 1`, giving input `0 + 1·41 = 41`... and more sharply,
`41 ∣ E(40)` because `40 ≡ -1 (mod 41)`.

## 2. The general obstruction, illustrated

For any integer polynomial `f` with `f(a) = p` prime, the identity
`f(a) ∣ f(a + k·p)` forces `p` to divide `f` along the whole arithmetic
progression `a, a+p, a+2p, …`. The only escape at a given progression point is
for the value to be exactly `±p`, which a nonconstant polynomial can do only
finitely often. Hence:

* the run of primes is always finite;
* in fact the non-prime inputs are *infinite* (theorem `infinitely_many_non_prime`).

## 3. Other classic "uncanny valley" polynomials (sanity spot-checks)

| polynomial | prime run length (from n=0) | first failure |
|------------|-----------------------------|---------------|
| `n² + n + 41`  | 40 | n = 40 (= 41²) |
| `n² + n + 17`  | 16 | n = 16 (= 17²) |
| `n² + n + 11`  | 10 | n = 10 (= 11²) |
| `2n² + 29`     | 29 | n = 29 (= 29·59) |

Each fails exactly where the divisibility engine predicts: at an input congruent
to the "seed prime" behaviour. No polynomial escapes.

## 4. Counterexample hunt for the main theorem

We searched for a nonconstant integer polynomial that is prime at every integer
input. None exists, and the proof explains why: any candidate would have to take
one of only two values (`±p`) on an infinite set, forcing constancy. The claim
survived the hunt and is proved in full generality in
`PrimeGeneratingPolynomials.lean`.
