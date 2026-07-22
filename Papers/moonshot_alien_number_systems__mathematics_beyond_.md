# Computational Evidence

## Small-case calculations

Negabinary extraction uses the parity digit `r = n mod 2` and next state
`q = (r − n)/2`. The first representative values are:

| Integer | Canonical base `−2` word |
|---:|:---|
| −5 | `1111` |
| −4 | `1100` |
| −3 | `1101` |
| −2 | `10` |
| −1 | `11` |
| 0 | `0` (empty internal word) |
| 1 | `1` |
| 2 | `110` |
| 3 | `111` |
| 4 | `100` |
| 5 | `101` |
| 13 | `11101` |
| −13 | `110111` |

The displayed words are most-significant digit first; the formal evaluator stores
digits in the reverse order. The checked example evaluates `[1,1,1,0,1,1]` to `−13`.

For Fibonacci numeration, the first examples include
`10 = 8 + 2 = F₆ + F₃` and `100 = 89 + 8 + 3 = F₁₁ + F₆ + F₄`.
The indices differ by at least two, so no selected Fibonacci numbers are consecutive.

## OEIS signal

The negabinary numeral sequence for nonnegative integers is commonly indexed as OEIS
A039724. The Fibonacci/Zeckendorf digit language is tied to Fibonacci word counts:
binary words of length `k` with no adjacent ones are counted by `F_{k+2}`.
These signals motivated treating both systems through canonical local normalization.

## Counterexample hunt and boundary cases

The naive termination claim `|q| < |n|` fails at `n = −1`, because extraction sends
`−1` to `1`. This counterexample forced the signed interleaving measure used in the
existence proof.

Negabinary uniqueness fails if leading zeroes are allowed: the empty word, `[0]`, and
`[0,0]` all evaluate to zero. Canonicality excludes exactly this ambiguity.

For base `φ`, nonnegative powers alone do not provide the advertised representation of
all integers. Since every such finite sum has coordinates in `ℤ + ℤφ`, cancellation of
the irrational coordinate is restrictive. General phinary integer expansions require
negative exponents; accordingly, the proved result uses the exact Zeckendorf boundary
and records the full phinary statement as a future target.

## Carry table

The local golden-ratio rewrite is independent of position:

| Local digits | Value | Normalized digits |
|:---:|:---|:---:|
| `011` at positions `n,n+1,n+2` | `φⁿ + φⁿ⁺¹` | `100` |

This follows from `φ² = φ + 1` after multiplication by `φⁿ`.
