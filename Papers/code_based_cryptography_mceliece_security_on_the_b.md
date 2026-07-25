# Computational evidence

The formal result is mostly structural, so finite experiments are secondary. The relevant concrete arithmetic is summarized below and is also proved in Lean without `native_decide`.

## Small-case calculations

The reusable bound is

`b^t ≤ choose(n,t)` whenever `(b+1)t ≤ n+1`.

Representative exact small cases:

| `b` | `t` | `n` | side condition | lower bound | exact `choose(n,t)` |
|---:|---:|---:|---:|---:|---:|
| 2 | 2 | 5 | 6 ≤ 6 | 4 | 10 |
| 2 | 3 | 8 | 9 ≤ 9 | 8 | 56 |
| 3 | 3 | 11 | 12 ≤ 12 | 27 | 165 |
| 5 | 4 | 23 | 24 ≤ 24 | 625 | 8855 |

For the selected McEliece parameters, `6·119 = 714 ≤ 6961`, hence `5^119 ≤ choose(6960,119)`. Lean also checks `2^256 ≤ 5^119`, giving `2^256 ≤ choose(6960,119)`.

## OEIS search

No OEIS lookup is relevant: the principal object is a single parameterized binomial coefficient and the theorem is a general inequality rather than a newly observed integer sequence.

## Counterexample hunt

The side condition is essential. For example, dropping it permits `b=3`, `t=2`, `n=2`, where `3^2 = 9` but `choose(2,2)=1`. The formal theorem retains the condition.

The game-hop theorem is a direct triangle inequality and has no finite exceptional cases. The quantum statement explicitly assumes the quadratic-search criterion and does not extrapolate it to all quantum algorithms.

## Numerical table

| Quantity | Certified comparison |
|---|---|
| Error-pattern space | `2^256 ≤ choose(6960,119)` |
| Query threshold | `q < 2^128` |
| Quadratic coverage | `q^2 < choose(6960,119)` |

These comparisons are kernel-checked in `McElieceConnector.lean`.
