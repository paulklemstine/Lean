# Computational evidence — degree-11 rung of the abelian ladder

All numbers below were produced by direct enumeration (sieve of primes `p < 200000`,
`p ≠ 23`, residue degrees computed as the order of `p` in `(Z/23)ˣ/{±1}`).  They
are *evidence*, not proof; every claim that survived into the Lean files is
proved there without `sorry` and without `native_decide`.

## 1. Splitting densities in `Q(ζ₂₃)⁺`

| quantity | measured (`p < 2·10⁵`) | predicted |
|---|---|---|
| number of primes considered | 17 982 | — |
| primes with residue degree 1 | 1 639 | — |
| density of totally split primes | 0.091147 | `1/11 = 0.090909` |
| residue degrees observed | only `{1, 11}` | `{1, 11}` (prime degree dichotomy) |
| empirical `H(T)` (bits) | 0.440286 | `log₂ 11 − (10/11) log₂ 10 = 0.4394970` |

Every totally split prime in the sample satisfies `p ≡ ±1 (mod 23)`, and no other
prime does: this is the pinning law proved as `realDeg_23_prime_iff`.

## 2. Independence from the quadratic character

Joint counts of (Legendre symbol `(p|23)`, residue degree):

| | degree 1 | degree 11 |
|---|---|---|
| `(p\|23) = +1` | 812 | 8 151 |
| `(p\|23) = −1` | 827 | 8 192 |

Measured `H(T | Legendre) = 0.4402832`, hence `I = 2.6·10⁻⁶` bits — zero to
sampling accuracy.  In the uniform (exponent) model this is *exactly* zero, which
is the theorem `quadratic_character_carries_no_information`; the CRT reason is
`gcd(2, 11) = 1`.

Note the sharpness caveat that the raw statistic hides: `2` is a quadratic
residue mod 23 (`5² = 25 = 2`) but is inert in `Q(ζ₂₃)⁺`.  So the Legendre channel
is *strictly lossy* for the type (`legendre_pinning_fails`), even though the
information it carries is exactly `0`.

## 3. Semiprime split count

Over the `11² = 121` exponent pairs `(a, b) ∈ (Z/11)²` the number of totally split
factors is distributed as

| split count | pairs | `121 · Bin(2, 1/11)` |
|---|---|---|
| 0 | 100 | 100 |
| 1 | 20 | 20 |
| 2 | 1 | 1 |

exactly the binomial profile; proved in general for prime degree `q` as
`card_splitCount_zero / _one / _two` and specialised in `splitCount_deg11`.

## 4. The ladder of prime degrees (safe primes `f = 2q + 1`)

| degree `q` | field | `H(T_q)` (bits) |
|---|---|---|
| 2 | `Q(ζ₅)⁺` | 1.000000 |
| 3 | `Q(ζ₇)⁺` | 0.918296 |
| 5 | `Q(ζ₁₁)⁺` | 0.721928 |
| 11 | `Q(ζ₂₃)⁺` | 0.439497 |
| 23 | `Q(ζ₄₇)⁺` | 0.258019 |
| 29 | `Q(ζ₅₉)⁺` | 0.216397 |
| 41 | `Q(ζ₈₃)⁺` | 0.165427 |
| 53 | `Q(ζ₁₀₇)⁺` | 0.135036 |

The decay is captured by the proved sandwich
`log₂ q / q ≤ H(T_q) ≤ (log₂ q + 1/ln 2)/q`
(`typeEntropy_prime_sandwich`); at `q = 11` this reads `0.3145 ≤ 0.4395 ≤ 0.4456`,
and the sharper certificate `0.4394 < H < 0.4396` is `typeEntropy_eleven_bracket`,
proved from the integer inequalities `2²⁴¹⁷·10⁵⁰⁰⁰ < 11⁵⁵⁰⁰` and
`11²²⁰⁰ < 2⁹⁶⁷·10²⁰⁰⁰`.

## 5. The split-count channel `Is(11)` — a failed prediction

Brute-force enumeration over all `121` exponent pairs, with the catalog's
definitions (`sProj ∘ typePair` read against `prodRes`):

| quantity | value |
|---|---|
| `H(split count)` | 0.7137047 |
| `H(split count \| N mod 23)` | 0.6618074 |
| `Isplit 11` | **0.0518973** |
| reported `Is(11)` | 0.116 |

The exact closed form, proved as `Isplit_eleven_value`, is

`Isplit 11 = log₂ 11 + (180 log₂ 3 − 210 log₂ 5 − 210)/121`,

certified between `0.0516` and `0.0521` (`Isplit_eleven_bracket`) from the integer
inequalities `2⁸⁶⁵·5⁸⁴⁰ < 11⁴⁸⁴·3⁷²⁰` and `11¹²¹⁰·3¹⁸⁰⁰ < 2²¹⁶³·5²¹⁰⁰`.  The
reported value `0.116` is therefore not reproduced under this reading of the
statistic; the other degree-11 predictions of the round are confirmed.

## 6. Counterexample hunt

* Searched for a prime `p < 2·10⁵` with residue degree ∉ {1, 11}: none (as forced
  by primality of 11).
* Searched for a totally split prime with `p ≢ ±1 (mod 23)`: none.
* Searched for a *coarsening* of the sign class that still pins the type: the
  quadratic character fails (see §2); the general obstruction is the criterion
  `condEnt_eq_zero_iff_determines`, which shows that pinning fails exactly when a
  split class is merged with an inert one.

## 7. Strict decay of the rungs (closing cycle)

The interpolation `h(x) = log₂ x − ((x−1)/x) log₂(x−1)` evaluated at the prime degrees:

| q | H(T_q) | q·H(T_q) − log₂ q |
|---|---|---|
| 2 | 1.000000 | 1.000000 |
| 3 | 0.918296 | 1.169925 |
| 5 | 0.721928 | 1.287712 |
| 7 | 0.591673 | 1.334355 |
| 11 | 0.439497 | 1.375035 |
| 13 | 0.391244 | 1.385727 |
| 23 | 0.258019 | 1.410867 |
| 29 | 0.216397 | 1.417530 |

The second column decreases strictly; the third increases strictly towards
`1/ln 2 = 1.442695…`.  The first fact is now the theorem `typeEntropy_strict_decay`
(via the derivative `−log(x−1)/(x² log 2)`, which is `0` at `x = 2` and negative
beyond); the second is recorded as an open direction.
