# Computational Evidence

## Small-case calculations

For nonzero integer `n`, the proposal evaluates to

`|n| * (2 * (1/2 + 1/(2n)) - 1) = |n| / n`.

| `n` | proposed coordinate `x` | scale `|n|` | represented value |
|---:|---:|---:|---:|
| -3 | 1/3 | 3 | -1 |
| -2 | 1/4 | 2 | -1 |
| -1 | 0 | 1 | -1 |
| 1 | 1 | 1 | 1 |
| 2 | 3/4 | 2 | 1 |
| 3 | 2/3 | 3 | 1 |
| 6 | 7/12 | 6 | 1 |

The expression is undefined at `n = 0` as written because it contains `1/(2n)`. Lean's totalized rational division assigns a value, but that convention is not the proposed geometric embedding and is not used to validate the zero case.

Factor checks:

| claim | result |
|---|---|
| `6 = 2 * 3` | true |
| `-6 = (-2) * (-3)` | false; RHS is `6` |
| `-6 = 2 * 3 * (-1)` | true |

Representative-independence checks use `(0,1) ~ (1,-1)`:

* Multiplying both representatives coordinatewise gives `(0,1)` and `(1,1)`, which are not equivalent (the endpoint rule would require the second fiber coordinate to be `-1`).
* Adding both representatives coordinatewise gives `(0,2)` and `(2,-2)`, which are not equivalent because `2` is not an endpoint coordinate.

## OEIS search

No OEIS search is applicable: no new integer sequence is asserted. The observed represented-value pattern is simply the sign function on nonzero integers.

## Counterexample hunt

The smallest useful counterexamples already invalidate the universal structural claims:

* Two equivalent pairs of representatives show multiplication is not well-defined.
* The same pairs show addition is not well-defined.
* `n = 2` shows the represented scalar is `1`, not `2`.
* `(-2)(-3) = 6` refutes the proposed negative factorization.
* `-1` is a unit, refuting its proposed primality.

All mathematical claims retained in this report are mirrored by kernel-checked theorems in `Speculative/MoebiusArithmetic.lean`; the tables are explanatory rather than the source of verification.
