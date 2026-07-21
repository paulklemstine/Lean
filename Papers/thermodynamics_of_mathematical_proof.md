# Computational evidence

## Small cases

For depth `n`, the model predicts `2^n` certificates and `2^n - 1` erased rejection flags.

| n | certificates | erased flags | created choices | erased / created |
|---:|---:|---:|---:|---:|
| 0 | 1 | 0 | 0 | — |
| 1 | 2 | 1 | 1 | 1.00 |
| 2 | 4 | 3 | 2 | 1.50 |
| 3 | 8 | 7 | 3 | 2.33 |
| 4 | 16 | 15 | 4 | 3.75 |
| 5 | 32 | 31 | 5 | 6.20 |
| 6 | 64 | 63 | 6 | 10.50 |
| 8 | 256 | 255 | 8 | 31.875 |

The recurrence `E(n+1) = 2 E(n) + 1` holds in every displayed row.

## Sequence identification

The erased-flag sequence begins `0, 1, 3, 7, 15, 31, 63, 127, ...`, the Mersenne numbers `2^n - 1` (OEIS A000225).

## Counterexample hunt

The proposed strict inequality `2n < 2^n - 1` fails at `n = 0,1,2` and first holds at `n = 3` (`6 < 7`). The formal theorem conservatively assumes `4 ≤ n` so it can be chained directly with the intended “more than twice creation” regime without boundary discussion. The non-strict inequality `n ≤ 2^n - 1` holds in all tested cases and is formally proved for every natural `n`.

A conceptual counterexample to an overbroad interpretation is also important: structured proof systems need not inspect all syntactically possible certificates. Thus the formal result is explicitly restricted to exhaustive verification with one rejection flag per discarded candidate.
