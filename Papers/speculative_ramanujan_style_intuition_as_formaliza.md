# Computational evidence: the accuracy barrier for oracles

We model statements as bit-positions and an *oracle* / *truth pattern* on a block
of `N` statements as an element of `{0,1}^N`. An oracle `r` predicts a truth
pattern `t` "to within `d` errors" when the Hamming distance `dist(r,t) ≤ d`.

## Small-case ball sizes

The number of truth patterns an oracle predicts within `d` errors on a block of
size `N` is the binomial partial sum `B(N,d) = ∑_{k=0}^{d} C(N,k)`.

| N   | d (errors) | accuracy ≥ | B(N,d)          | 2^N            | fraction covered |
|-----|-----------|-----------|-----------------|----------------|------------------|
| 20  | 1  (95%)  | 19/20     | 21              | 1,048,576      | 2.0e-5           |
| 20  | 5  (75%)  | 15/20     | 21700           | 1,048,576      | 0.021            |
| 100 | 5  (95%)  | 95/100    | 79,375,496      | 1.27e30        | 6.2e-23          |
| 100 | 50 (50%)  | 50/100    | ≈ 2^99          | 1.27e30        | ≈ 0.5            |

So at 95% accuracy the ball covers a vanishing fraction of all patterns; the
number of oracles needed to cover everything (`2^N / B(N,d)`) is astronomically
large. This is exactly the threshold appearing in `exists_defeating_truth`.

## Defeat threshold sanity checks

`exists_defeating_truth` says: any family `F` with `|F| · B(N,d) < 2^N` is
defeated by some pattern. Checks:

* `N=20, d=1`: any family with `|F| < 1048576/21 ≈ 49932` oracles is defeated at
  95% accuracy. A "small computable pool" (a handful of short programs) is trivially
  below this.
* `N=100, d=5`: threshold `≈ 1.6e22`; no realistic enumeration of programs reaches
  it. High accuracy on a length-100 block is therefore impossible for any small pool.

## Non-vacuity

For `d < N` a singleton family satisfies the hypothesis, since a proper Hamming
ball misses at least the antipodal pattern (`ball_card_lt`): `B(N,d) < 2^N`.

## Counterexample hunt

The universal claims are the diagonal statements (Parts A/B); a counterexample
would be an enumeration hitting every oracle, which the diagonal construction
`n ↦ ¬ f(n)(n)` refutes directly. No counterexample exists.
