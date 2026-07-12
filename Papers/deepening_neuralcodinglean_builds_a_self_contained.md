# Computational Evidence — Weight Distribution of Binary Neural Codes

We model a neural code on `N` neurons as a binary activity pattern and let the
**weight** be the number of active neurons. Regarding all `2^N` patterns as
equally likely, the weight is a random variable. This note records the
small-case data that motivated and confirmed the closed forms proved in
`NeuralWeightConcentration.lean`.

## 1. Exact moment sums (brute force over all `2^N` patterns)

For each `N` we enumerated all `2^N` patterns and summed the weight and the
squared weight.

| N | ∑ weight | N·2^(N-1) | 4·∑ weight² | 2^N·N(N+1) |
|---|----------|-----------|-------------|------------|
| 0 | 0        | 0         | 0           | 0          |
| 1 | 1        | 1         | 4           | 4          |
| 2 | 4        | 4         | 24          | 24         |
| 3 | 12       | 12        | 96          | 96         |
| 4 | 32       | 32        | 320         | 320        |
| 5 | 80       | 80        | 960         | 960        |

Both closed forms match exactly for every `N` tested:

* First moment: `∑ weight = N·2^(N-1)`, i.e. mean `= N/2`.
* Second moment: `4·∑ weight² = 2^N·N(N+1)`, i.e. `E[weight²] = N(N+1)/4`.

## 2. Centred second moment and variance

| N | ∑ (weight − N/2)² | N·2^N/4 | variance = (∑ …)/2^N | N/4 |
|---|-------------------|---------|----------------------|-----|
| 0 | 0                 | 0       | 0                    | 0   |
| 1 | 0.5               | 0.5     | 0.25                 | 0.25|
| 2 | 2                 | 2       | 0.5                  | 0.5 |
| 3 | 6                 | 6       | 0.75                 | 0.75|
| 4 | 16                | 16      | 1                    | 1   |
| 5 | 40                | 40      | 1.25                 | 1.25|

The variance is exactly `N/4` in every case — the Binomial `N·p·(1−p)`
variance at `p = 1/2`.

## 3. Sequence identification

The average-weight numerators `0, 1, 4, 12, 32, 80, …` are `N·2^(N-1)`
(OEIS A001787). The second-moment numerators `0, 1, 6, 24, 80, 240, …`
follow `2^(N-2)·N·(N+1)`. Both are elementary and index cleanly, so no deeper
sequence search was needed.

## 4. Counterexample hunt

We searched for any `N ≤ 12` violating `4·∑ weight² = 2^N·N(N+1)` or
`variance = N/4`; none was found. The `√N`-window fraction
`#{|weight − N/2| < √N} / 2^N` was checked to stay above `3/4` for
`1 ≤ N ≤ 12`, consistent with the Chebyshev corollary.

All closed forms are therefore supported by exhaustive small-case data before
being established in general.
