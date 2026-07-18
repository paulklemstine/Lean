# Computational evidence

The formal target is an exact finite Bernoulli model, so the relevant calculations are rational rather than empirical astronomy.

## Small cases

For `p = 1/10`, direct expansion gives:

| candidates `N` | empty probability `(1-p)^N` | nonempty probability | union bound `Np` |
|---:|---:|---:|---:|
| 1 | 0.9 | 0.1 | 0.1 |
| 2 | 0.81 | 0.19 | 0.2 |
| 3 | 0.729 | 0.271 | 0.3 |
| 4 | 0.6561 | 0.3439 | 0.4 |
| 5 | 0.59049 | 0.40951 | 0.5 |

These instances support `1-(1-p)^N ≤ Np`; the Lean theorem proves it for every natural `N` and real `0 ≤ p ≤ 1`.

For the explicit Drake-style factors used in the formal file,
`(1/10)(1/100)(1/100)(1/1,000,000) = 1/100,000,000,000`.
With `10,000,000,000` candidates, the expected count is exactly `1/10`, and the theorem yields empty probability at least `9/10`.

## OEIS search

No OEIS search is applicable: the object is a two-parameter family of rational probabilities, not a newly conjectured integer sequence.

## Counterexample hunt

The tempting universal inference “expected count below one implies the count is certainly zero” fails. A count equal to one with probability `9/10` and zero with probability `1/10` has expectation `9/10 < 1`, yet is nonzero with positive probability. This countermodel is proved exactly in Lean.

Boundary checks: `p=0` makes the bound an equality `0 ≤ 0`; `N=0` also makes it an equality; `p=1` gives `1 ≤ N` for positive `N` (and equality for `N=1`). No counterexample exists under the theorem’s stated interval assumptions, by the formal proof.
