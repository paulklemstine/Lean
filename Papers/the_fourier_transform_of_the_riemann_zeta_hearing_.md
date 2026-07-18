# Computational Evidence

The central issue is structural rather than a large finite search. The checked Lean development supplies exact small cases and universal identities.

## Small cases

For the Fourier convention `exp(-2π i w t)`, the formal cancellation identity gives the following exact resonant centers:

| Dirichlet term | center |
|---|---|
| `n = 2` | `-log(2)/(2π)` |
| `n = 3` | `-log(3)/(2π)` |
| `n = 4` | `-log(4)/(2π) = -2 log(2)/(2π)` |
| `n = 5` | `-log(5)/(2π)` |

At each center, a rectangular window `[-T,T]` has exact response `2T`, as proved by `windowedFourier_at_resonance`. The multiplicative/additive relation in the row for 4 follows from `logFrequency_mul`.

## Counterexample hunt

The first composite candidate already defeats the claim that the elementary zeta Dirichlet expansion produces only prime peaks: `n = 4` is not prime while its coefficient `1/sqrt(4)` is nonzero. This is machine-checked by `composite_four_has_nonzero_weight`.

The positive-frequency formulation is also refuted uniformly, not merely numerically: for every `n > 1`, `-logFrequency n` differs from `logFrequency n`, and the actual resonant frequency is negative.

## OEIS search

No OEIS search is applicable. The relevant object is the real-valued sequence `log(n)/(2π)`, and the proved phenomenon concerns its Fourier sign and multiplicative-to-additive structure rather than an integer sequence.

## Scope

No million-zero computation was performed. Zeros are not samples of `ζ(1/2+it)`, and the unwindowed integral in the prompt is not an ordinary integrable Fourier transform. A numerical test should first specify a sampling interval and window, as described in `FUTURE_DIRECTIONS.md`.
