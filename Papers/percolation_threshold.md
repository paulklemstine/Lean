# Computational evidence: three-site triangular self-duality

The formal target is the finite local crossing polynomial

\[
C(p)=p^3+3p^2(1-p)=3p^2-2p^3,
\]

the probability that at least two of three independent sites are open. This is
a finite calculation, not a numerical claim about the infinite square-lattice
site threshold.

## Small-case calculations

| `p` | `C(p)` |
|---:|---:|
| 0 | 0 |
| 1/4 | 5/32 = 0.15625 |
| 1/3 | 7/27 ≈ 0.25926 |
| 1/2 | 1/2 |
| 2/3 | 20/27 ≈ 0.74074 |
| 3/4 | 27/32 = 0.84375 |
| 1 | 1 |

The values pair to one under `p ↦ 1-p`, as predicted by
`C(1-p)=1-C(p)`.

## OEIS search

No integer sequence is central to this finite polynomial identity, so an OEIS
identifier is not applicable.

## Counterexample hunt

The complement identity was expanded symbolically. The fair-point equation
factors as

\[
C(p)-\tfrac12=(2p-1)\left(p(1-p)+\tfrac12\right).
\]

For `0 ≤ p ≤ 1`, the second factor is positive, so no counterexample to uniqueness
of `p=1/2` can occur in the Bernoulli parameter interval. The Lean development
proves this algebraically rather than relying on sampled values.

## Scope

The infinite square-lattice site-percolation threshold has no known closed
analytic form. Numerical evidence for that constant would not prove such a form,
and the present development does not claim one. It proves the exact local
self-duality calculation associated with triangular-site percolation and an
analogous one-face bond calculation.
