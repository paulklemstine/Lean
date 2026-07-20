# Computational evidence

The formal development studies the explicit mean-field model

\[
C_\kappa(x;c)=\sqrt{\kappa\max(x-c,0)}.
\]

This evidence checks examples of the model; it does **not** provide empirical evidence that
mathematical history follows the model or that 10,000 is a data-derived threshold.

## Small cases

For `κ = 1` and `c = 4`, exact values of `C²` are:

| connections `x` | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 8 | 13 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `C(x)²` | 0 | 0 | 0 | 0 | 0 | 1 | 2 | 4 | 9 |
| `C(x)` | 0 | 0 | 0 | 0 | 0 | 1 | √2 | 2 | 3 |

For the stated model threshold `c = 10000` and `κ = 1`:

| edges | 9999 | 10000 | 10001 | 10004 | 10100 |
|---:|---:|---:|---:|---:|---:|
| `C²` | 0 | 0 | 1 | 4 | 100 |
| `C` | 0 | 0 | 1 | 2 | 10 |

## Sequence search

No OEIS search is applicable: after squaring, the integer samples are simply the positive
part of a shifted linear sequence; this is a model definition rather than a newly observed
integer sequence.

## Counterexample hunt

The formal claims reduce to standard identities and inequalities for `sqrt` and `max`.
Boundary checks at `x=c`, zero coupling, and positive coupling below/above threshold agree
with the statements. Negative coupling was intentionally excluded from square-law and
monotonicity claims; without that assumption the radicand need not represent the intended
order parameter.

## Interpretation

The table displays continuous onset and square-root growth. It cannot validate the empirical
premise, estimate a real critical edge count, or establish that theorem networks undergo a
physical phase transition. Those require a specified dataset and statistical model.
