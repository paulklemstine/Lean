# Computational evidence

The formal target is the finite identity

\[
P_k(X)=\sum_{n=1}^k \mu(n)\lfloor k/n\rfloor X^n
      =\sum_{m=1}^k R_m(X),\qquad
R_m(X)=\sum_{n\mid m}\mu(n)X^n.
\]

## Small cases

The following table was obtained by direct integer arithmetic. Zero coefficients
are omitted.

| k | `P_k(X)` | `R_k(X)` |
|---:|---|---|
| 1 | `X` | `X` |
| 2 | `2X-X^2` | `X-X^2` |
| 3 | `3X-X^2-X^3` | `X-X^3` |
| 4 | `4X-2X^2-X^3` | `X-X^2` |
| 5 | `5X-2X^2-X^3-X^5` | `X-X^5` |
| 6 | `6X-3X^2-2X^3-X^5+X^6` | `X-X^2-X^3+X^6` |
| 10 | `10X-5X^2-3X^3-2X^5+X^6-X^7+X^10` | `X-X^2-X^5+X^10` |

For every `1 ≤ k ≤ 10`, accumulating the displayed divisor polynomials gives
exactly `P_k`. The checked identity is stronger than these samples and is
proved for every coefficient function in `PolynomialBridge.lean`; thus these
calculations are exploratory evidence, not the verification.

## OEIS search

No new one-dimensional sequence is asserted here. The coefficients form a
two-parameter triangular array `μ(n)⌊k/n⌋`, while the discrete increments are
the divisibility-incidence array `μ(n)·1_{n∣k}`. Consequently no OEIS ID is
claimed.

## Counterexample hunt

Direct calculation for `1 ≤ k ≤ 10` found no counterexample. Edge cases were
also considered: at `k=0` both finite sums are empty, and the coefficient at
`n=0` is absent because all indexing intervals begin at one.

## Structural observation

The coefficient of `X^n` in the cumulative divisor side is
`μ(n)` times the number of multiples of `n` in `{1,…,k}`, namely
`μ(n)⌊k/n⌋`. Equivalently, the discrete jump
`⌊(k+1)/n⌋-⌊k/n⌋` is the indicator of `n ∣ k+1`. This is the mechanism used by
the Lean proof.
