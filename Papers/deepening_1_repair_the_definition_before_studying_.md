# Computational evidence: globally repaired anti-Fibonacci rule

## Small cases

The repaired rule starts at 1, requires the next term to be larger, and excludes every sum of two terms already seen (repeated summands allowed).

| stage | previous values | excluded relevant sums | least larger admissible value |
|---:|---|---|---:|
| 0 | 1 | 2 | 3 |
| 1 | 1, 3 | 2, 4, 6 | 5 |
| 2 | 1, 3, 5 | 2, 4, 6, 8, 10 | 7 |
| 3 | 1, 3, 5, 7 | 2, 4, 6, 8, 10, 12, 14 | 9 |
| 4 | 1, 3, 5, 7, 9 | all even values from 2 through 18 | 11 |

Thus the observed values are `1, 3, 5, 7, 9, 11, 13, ...`.

## Sequence identification

This is the sequence of positive odd integers. No OEIS lookup is needed for the proof, and no external sequence identification is used.

## Counterexample hunt

The proposed exact law is `a(n) = 2n+1`. At each tested stage through the table above:

* every prior pair sum is even, so the next odd integer is admissible;
* the sole intervening integer is even and equals `1 + a(n)`, so it is forbidden.

No counterexample appears. The Lean development proves these two observations for every natural-number stage and derives uniqueness, rather than relying on the finite test.
