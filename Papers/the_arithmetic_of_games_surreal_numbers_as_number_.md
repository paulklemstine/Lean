# Computational evidence

The relevant finite computations are symbolic rather than floating-point approximations. For the canonical dyadic surreal `powHalf n`, the formal recurrence is

| `n` | surreal value | left options | right options | birthday |
|---:|---:|---|---|---:|
| 0 | `1` | `{0}` | empty | 1 |
| 1 | `1/2` | `{0}` | `{1}` | 2 |
| 2 | `1/4` | `{0}` | `{1/2}` | 3 |
| 3 | `1/8` | `{0}` | `{1/4}` | 4 |
| 4 | `1/16` | `{0}` | `{1/8}` | 5 |
| 5 | `1/32` | `{0}` | `{1/16}` | 6 |

These instances suggest, and the Lean development proves for every natural `n`, that the birthday is `n + 1` and that the values form a strictly decreasing positive sequence.

For uniqueness, sample cross-product checks agree with the proved criterion:

* `1/2 = 2/4` because `1·4 = 2·2`.
* `3/8 = 6/16` because `3·16 = 6·8`.
* `1/2 ≠ 3/4` because `1·4 ≠ 3·2`.
* `-3/8 = -6/16` because `(-3)·16 = (-6)·8`.

A counterexample hunt against the prompt's “subfield” wording finds the immediate obstruction `1/3`: if `m/2ⁿ` were an inverse of `3`, then `3m = 2ⁿ`, impossible since no power of two is divisible by three. This obstruction is also proved in Lean as `DyadicLocalization.three_has_no_inverse`.

No OEIS search is relevant: the sequences of values `2⁻ⁿ` and birthdays `n+1` are elementary closed-form sequences, and no combinatorial sequence identification is needed for the theorem.
