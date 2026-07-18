# Computational evidence

## Small cases

The primes beginning at 2 are

`2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73`.

Their initial gaps are

`1, 2, 2, 4, 2, 4, 2, 4, 6, 2, 6, 4, 2, 4, 6, 6, 2, 6, 4, 2`.

This agrees with OEIS A001223 and motivates the parity theorem formalized in
`Catalog/Physics/PrimeGapCrossword.lean`.

## OEIS

The prime-gap sequence is OEIS A001223. No new integer sequence is claimed here.

## Counterexample hunt

The suggested forcing assertion for the prefix `(6,4,2,6)` is false. A concrete
counterexample is

`5431, 5437, 5441, 5443, 5449, 5471`,

whose consecutive gaps are `(6,4,2,6,22)`. The primality of all endpoints and
nonprimality of every intervening integer are proved in Lean by
`gap_pattern_6_4_2_6_does_not_force_4`; this counterexample is therefore
machine-checked rather than merely an exploratory computation.

For context only, an independent sieve exploration (not part of the formal
verification) found 137 occurrences of `(6,4,2,6)` below `10^7`; their following
gaps included `4, 10, 12, 18, 22, 24, 28, 30, 34, 40, 42, 48, 52, 54, 58, 64`.
Thus the prefix does not determine the following gap.

## Scope of the numerical test

The requested comparison through `10^8` was not presented as a theorem because
“conditional probability given all primes up to p” requires a specified sample
space or averaging window, and “approximately” requires an explicit error metric.
Without those choices there is no single reproducible statistic to verify. More
importantly, the stated Hardy--Littlewood asymptotic is conjectural, so finite data
cannot prove it. Future work should specify bins, normalization, and confidence
intervals before implementing that experiment.
