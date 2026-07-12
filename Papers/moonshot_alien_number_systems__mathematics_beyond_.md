# Computational Evidence — Alien Number Systems

Concise numerical support for the two formalized systems: **base `-2`** (negabinary)
and **base `φ`** (the golden-ratio system).

## 1. Negabinary (base `-2`)

Value of a bit list, least-significant bit first: `value = Σ dᵢ·(-2)ⁱ`.
Canonical form = no trailing `0` (list does not end in `false`).

| n  | canonical bits (LSB→MSB) | standard "digit string" | check |
|----|--------------------------|-------------------------|-------|
| 0  | `[]`                     | `0`                     | 0 |
| 1  | `[1]`                    | `1`                     | 1 |
| 2  | `[0,1,1]`                | `110`                   | 0 − 2 + 4 = 2 |
| 3  | `[1,1,1]`                | `111`                   | 1 − 2 + 4 = 3 |
| 4  | `[0,0,1]`                | `100`                   | 4 = 4 |
| −1 | `[1,1]`                  | `11`                    | 1 − 2 = −1 |
| −2 | `[0,1]`                  | `10`                    | 0 − 2 = −2 |
| −3 | `[1,0,1,1]`              | `1101`                  | 1 + 0 + 4 − 8 = −3 |

**Observations.**
* Both positive and negative integers appear with digits `{0,1}` only — no sign.
* Every integer in the sample has exactly one canonical representation, matching the
  proved bijection `negabinary_unique_rep`.
* **Counterexample hunt (uniqueness).** Dropping canonicality breaks uniqueness:
  `[]`, `[0]`, `[0,0]` all evaluate to `0`. This is why the "no trailing `0`"
  condition is mandatory; the proof `nvalue_eq_zero_of_canonical` isolates exactly
  this failure mode.
* **OEIS.** Negabinary representations of `0,1,2,…` are catalogued as A039724.

## 2. Base `φ` (golden-ratio system)

`φ = (1+√5)/2`, `φ² = φ + 1`, and `φ⁻² = 2 − φ`.

Phinary expansions (digit strings, radix point separating non-negative and negative
exponents):

| n | base-`φ` string | powers used | check |
|---|-----------------|-------------|-------|
| 1 | `1`        | φ⁰               | 1 |
| 2 | `10.01`    | φ¹ + φ⁻²         | φ + (2−φ) = 2 |
| 3 | `100.01`   | φ² + φ⁻²         | (φ+1) + (2−φ) = 3 |
| 4 | `101.01`   | φ² + φ⁰ + φ⁻²    | (φ+1) + 1 + (2−φ) = 4 |

**Observations.**
* No expansion contains two consecutive `1`s — the positional shadow of the collapse
  rule `φⁿ + φⁿ⁺¹ = φⁿ⁺²` (formalized as `phiPow_carry`, i.e. `011 = 100`).
* Values with only non-negative exponents always lie in `ℤ + ℤ·φ` with Fibonacci
  coordinates (`phiSum_fib`); genuine integers require the symmetric ± exponent
  pattern (`phi_repr_three` gives `3 = φ² + φ⁻²`).
* Coordinate uniqueness of `a·φ + b` over `ℚ` is a consequence of the irrationality
  of `φ` (`phi_coord_unique`) — over `ℝ` it would fail.
