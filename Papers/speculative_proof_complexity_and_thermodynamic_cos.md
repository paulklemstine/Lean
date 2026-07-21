# Computational Evidence

## Small cases

For the canonical binary description length `Nat.size x`, summing over `x < 2^n` gives:

| `n` | lengths by blocks | total | average |
|---:|---|---:|---:|
| 1 | `0, 1` | 1 | 1/2 |
| 2 | previous, then two length-2 codes | 5 | 5/4 |
| 3 | previous, then four length-3 codes | 17 | 17/8 |
| 4 | previous, then eight length-4 codes | 49 | 49/16 |

These values agree with the formally proved formulas
`total = (n - 1) * 2^n + 1` and `average = n - 1 + 2⁻ⁿ`.

## Counterexample hunt

The proposed exponential-average claim already fails at `n = 4` in this canonical uniform model:
`49/16 < 8 = 2^(4-1)`. This exact counterexample is proved in Lean as
`exponential_average_claim_false`; it is not an unchecked numerical experiment.

Raw-length monotonicity was also tested against padding. An empty payload with no padding and the same payload with one padding bit have raw lengths 0 and 1 but identical modeled complexity and cost. Lean proves this uniformly for every temperature in `padding_refutes_raw_length_cost`.

## OEIS search

No OEIS identification is asserted. The total sequence is elementary and is derived exactly in the Lean development, so an external sequence match is unnecessary.

## Scope

The phrase “random true statement” has no canonical distribution. The table uses all fixed-width binary words uniformly and serves as a countermodel to a distribution-independent exponential claim, not as evidence about every possible theorem distribution.
