# Computational evidence — reproducibility audit of the cyclic type channel

All numbers below were produced by direct enumeration of the finite model
(`typ n x = n / gcd(n, x)` on `ℤ/n`, unordered type pairs, norm classes `x + y = c`),
i.e. the same pipeline that the catalog files formalise. Entries marked **[proved]** are backed by
a `sorry`-free Lean theorem in `Catalog/Computation/`; entries marked *(evidence only)* are
exploratory computations that have **not** been machine-verified.

## 1. The 2-adic tower of type entropies

| `k` | `n = 2^k` | enumerated `H(T)` | law `2 - 2/2^k` |
|---|---|---|---|
| 1 | 2 | 1.0000000000 | 1 |
| 2 | 4 | 1.5000000000 | 3/2 |
| 3 | 8 | 1.7500000000 | 7/4 |
| 4 | 16 | 1.8750000000 | 15/8 |
| 5 | 32 | 1.9375000000 | 31/16 |
| 6 | 64 | 1.9687500000 | 63/32 |
| 7 | 128 | 1.9843750000 | 127/64 |
| 8 | 256 | 1.9921875000 | 255/128 |

The pattern suggested by the four recorded rows (`k ≤ 4`) continues exactly.
**[proved]** `CyclicType.Audit.HT_two_pow` : `HT (2^k) = 2 - 2/2^k` for every `k`, with
strict monotonicity, the ceiling `< 2`, and convergence to `2` bits.

## 2. The pair-channel 2-adic law, beyond the recorded range

| `k` | enumerated `I_pair(2^k)` | `(4/3)(1 - 4^{-k})` |
|---|---|---|
| 1 | 1.0 | 1 |
| 2 | 1.25 | 5/4 |
| 3 | 1.3125 | 21/16 |
| 4 | 1.328125 | 85/64 |
| 5 | 1.33203125 | 341/256 |
| 6 | 1.3330078125 | 1365/1024 |
| 7 | 1.333251953125 | 5461/4096 |

The catalog proves this law for `1 ≤ k ≤ 4` (`CyclicType.Ipair_two_pow_law`). The rows `k = 5,6,7`
are *evidence only* — they are the basis of Direction 1 in `FUTURE_DIRECTIONS.md`.

## 3. Rational vs irrational strata of the record

| order `n` | enumerated `H(T)` | closed form | stratum |
|---|---|---|---|
| 3 | 0.9182958341 | `log₂ 3 - 2/3` | irrational **[proved]** |
| 5 | 0.7219280949 | `log₂ 5 - 8/5` | irrational **[proved]** |
| 15 | 1.6402239289 | `log₂ 15 - 34/15` | irrational **[proved]** |
| 4 | 1.5 | `3/2` | dyadic **[proved]** |
| 8 | 1.75 | `7/4` | dyadic **[proved]** |
| 16 | 1.875 | `15/8` | dyadic **[proved]** |

The orders `3, 5, 15, 17, …` are exactly the non-2-power *constructible* orders (products of
distinct Fermat primes times a power of two): every totient in their divisor lattice is a power of
two, so the Euler-φ sum contributes a rational and the whole entropy sits at
`log₂ n − rational`. **[proved]** `CyclicType.Audit.irrational_HT_of_totient_two_pow`.

## 4. Four-decimal separation experiment

* `1/100 = 0.0100000000`, `1/101 = 0.0099009901`, difference `9.901 × 10⁻⁵ < 10⁻⁴`.
  Two *distinct* rationals with denominators just above 100 are indistinguishable at four
  decimals. **[proved]** `CyclicType.Audit.four_decimal_certificate_sharp`.
* For denominators `≤ 70`, the minimal separation is `1/4900 ≈ 2.04 × 10⁻⁴ > 10⁻⁴`, so a
  four-decimal match is a *proof* of equality. **[proved]**
  `CyclicType.Audit.eq_of_agree_four_decimals`; general form `1/Q²` in
  `CyclicType.Audit.eq_of_agree_of_den_le`.
* The recorded dyadic keystones have denominators `4, 16, 64, 2` (`Ipair 4`, `Ipair 8`,
  `Ipair 16`, `HT 4`), all `≤ 70`, hence all certifiable.

## 5. Enclosure of the irrational keystone

`log₂ 3 = 1.5849625007…`, with convergents

* `1054/665 = 1.5849624060…` and `2^1054 < 3^665` (checked by kernel evaluation in Lean),
* `485/306 = 1.5849673203…` and `3^306 < 2^485`,

giving `1.58496 < log₂ 3 < 1.58497` **[proved]** (`CyclicType.Audit.logb_two_three_bounds`) and
hence `|Ipair 6 − 1.4738| < 10⁻⁴` **[proved]**, while `Ipair 6 = 1.4738513896…` is irrational
**[proved]** — no rounded record can ever *equal* it.

## 6. Collision identity for the pair entropy *(evidence only)*

| `n` | enumerated `H(Π)` | `2·H(T) − (1 − Σ p²)` |
|---|---|---|
| 2 | 1.50000000 | 1.50000000 |
| 3 | 1.39214722 | 1.39214722 |
| 4 | 2.37500000 | 2.37500000 |
| 5 | 1.12385619 | 1.12385619 |
| 6 | 3.11436945 | 3.11436945 |
| 8 | 2.84375000 | 2.84375000 |
| 12 | 4.04492500 | 4.04492500 |

Agreement on every tested order; this is Direction 5 in `FUTURE_DIRECTIONS.md` and is **not** yet
machine-verified.

## 7. Gap structure of the dyadic tower

Consecutive rows of the tower differ by `H(T)(2^{k+1}) − H(T)(2^k) = 2^{-k}`, so the rows are
isolated far more strongly than their denominators suggest. **[proved]**
`CyclicType.Audit.HT_two_pow_gap`, `HT_two_pow_isolated`, and `HT_two_pow_certified_gap`
(a four-decimal record identifies the row for every `k ≤ 13`).

## 8. OEIS

The numerators of the `H(T)` tower, `1, 3, 7, 15, 31, 63, 127, 255`, are the Mersenne numbers
`2^k − 1` (A000225); the `I_pair` numerators `1, 5, 21, 85, 341, 1365, 5461` are the Jacobsthal
numbers `(4^k − 1)/3` (A002450). The second identification is evidence only, being based on the
seven enumerated rows above.

## 9. Unit orbits versus gcd classes, and the pair-orbit count *(new cycle)*

Enumeration in `ℤ/n` of the orbits of the unit action `x ↦ u·x`:

| `n` | orbits of the unit action equal the `gcd` classes? |
|---|---|
| 1–16 | yes on every order tested |

This is now **[proved]** for all `n > 0` in
`Catalog/Computation/ReproducibilityGaloisConverse.lean`
(`CyclicType.Audit.unit_orbit_of_gcd_eq`, `unit_orbit_of_typ_eq`), so a readout is invariant under
every change of generator exactly when it factors through the splitting type
(`unit_invariant_iff_typ_invariant`, `exists_factor_through_typ`).

For the *diagonal* action on ordered pairs the orbits are strictly finer than the type pair —
e.g. in `ℤ/8` the pairs `(1,3)` and `(1,7)` carry the same types but lie in different orbits, since
the first coordinate already pins `u = 1`. The orbit count matches the Burnside average
`(1/φ(n)) Σ_{u ∈ (ℤ/n)ˣ} gcd(n, u−1)²`:

| `n` | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| enumerated pair-orbits | 1 | 4 | 5 | 10 | 7 | 20 | 9 | 22 | 17 | 28 | 13 | 50 | 15 |
| Burnside formula | 1 | 4 | 5 | 10 | 7 | 20 | 9 | 22 | 17 | 28 | 13 | 50 | 15 |

Agreement on every order tested; this is Direction 4 of `FUTURE_DIRECTIONS.md` in its new form and
is **evidence only** — it is not yet machine-verified.
