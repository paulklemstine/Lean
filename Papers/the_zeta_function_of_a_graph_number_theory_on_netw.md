# Computational evidence

## Small-case calculation

For the local Ihara factor with parameters `λ = 2`, `q = 2`, let `S₀ = 2`, `S₁ = λ`, and

`Sₙ₊₂ = λ Sₙ₊₁ - q Sₙ`.

The first eight values are:

| n | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---:|---:|---:|---:|---:|---:|---:|---:|
| Sₙ | 2 | 2 | 0 | -4 | -8 | -8 | 0 | 16 |

This table is encoded and kernel-checked in `GraphZetaPrimeCycle.example`.

The quadratic is `1 - 2u + 2u²`. Its reciprocal roots are `1 ± i`, so each zero is `(1 ± i)/2` and has modulus `1/√2`, matching the critical-circle theorem. The recurrence values also equal `(1+i)ⁿ + (1-i)ⁿ`.

## OEIS search

No OEIS identifier is asserted. This specialized signed Lucas sequence can be derived directly from the standard Lucas power-sum recurrence; an online OEIS query was not available in the formal verification environment, so guessing an identifier would be unreliable.

## Counterexample hunt

The universal theorem was checked symbolically, rather than by floating-point sampling. Its hypotheses are essential:

- With `q = 2`, `λ = 2`, the Ramanujan inequality `λ² ≤ 4q` holds and both zeros have modulus `1/√2`.
- With `q = 2`, `λ = 3`, the inequality fails (`9 > 8`). The zeros of `1 - 3u + 2u²` are `1` and `1/2`, neither of which has modulus `1/√2`.

Thus dropping the Ramanujan bound produces an immediate counterexample, while the formal theorem proves there is no counterexample under its stated assumptions.

## Relevant comparison

The finite explicit formula proved in Lean is an exact polynomial identity for every truncation index `N`; therefore numerical plots would add little evidence. A meaningful plot for primitive cycle counts requires the global non-backtracking matrix and Möbius inversion, which are listed as future work rather than silently approximated here.
