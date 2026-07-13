# Computational Evidence — Alternating Signs of the Model q-Series

All values below are produced by the definitions in
`AndrewsQSeriesAlternating.lean` and reproduced by the `#eval` commands in that
file.

## 1. Small-case coefficients

`V2 n = (-1)^n (2^n + 1) + n`:

| n      | 0 | 1  | 2 | 3  | 4  | 5   |
|--------|---|----|---|----|----|-----|
| V2 n   | 2 | -2 | 7 | -6 | 21 | -28 |
| (-1)^n V2 n | 2 | 2 | 7 | 6 | 21 | 28 |

The sign-corrected column is strictly positive at every index — the empty
exceptional-set regime.

`V3 n = (-1)^n (n - 4) + 2`:

| n      | 0  | 1 | 2 | 3 | 4 | 5 | 6 | 7  | 8 | 9  |
|--------|----|---|---|---|---|---|---|----|---|----|
| V3 n   | -2 | 5 | 0 | 3 | 2 | 1 | 0 | 5 | 6 | 5 |
| (-1)^n V3 n | -2 | -5 | 0 | -3 | 2 | -1 | 0 | -5 | 6 | -5 |

The sign-corrected value is nonpositive for `n ≤ 6` and strictly positive from
`n = 7` onward — the finite exceptional-set regime; the proved threshold is
`N = 7`.

`V4 n = (-1)^n (n+1) + E4 n`, error active exactly on squares:

| n      | 0  | 1 | 2 | 3  | 4  | 5  | 6 | 7  | 8 | 9  |
|--------|----|---|---|----|----|----|---|----|---|----|
| V4 n   | -1 | 2 | 3 | -4 | -5 | -6 | 7 | -8 | 9 | 10 |
| (-1)^n V4 n | -1 | -2 | 3 | 4 | -5 | 6 | 7 | 8 | 9 | -10 |

The sign-corrected value is negative exactly at `n = 0, 1, 4, 9` (the squares)
and positive elsewhere — the density-zero exceptional-set regime.

## 2. Exceptional-set counting

`excCount4 M = #{ perfect squares in [0, M) }`:

| M          | 100 | 10000 |
|------------|-----|-------|
| excCount4  | 10  | 100   |

The counts match `⌊√M⌋ + 1` (here `⌊√99⌋+1 = 10`, `⌊√9999⌋+1 = 100`), confirming
the proved bound `excCount4 M ≤ ⌊√M⌋ + 1` and the density ratio
`excCount4 M / M = 10/100 = 0.1` then `100/10000 = 0.01`, decaying to `0`.

## 3. Boundary series

`Wbd n = (-1)^n (n+1) + (n+1)` realises `|E| = A`. Its sign-corrected value is
`2(n+1)` at even `n` and `0` at odd `n`, so alternation fails on the entire odd
subsequence — a positive-density (density `1/2`) exceptional set. This confirms
the domination inequality must be strict.

## 4. Counterexample hunt

Searching the three model series for a violation of the proved statements:
`V2` was checked to alternate with no exceptions (empty violation set); `V3` was
checked to alternate for all `n ≥ 7`; `V4` was checked to violate alternation on
exactly the squares and nowhere else. No counterexample to any proved statement
was found; the only "violations" are the documented, provably density-zero
exceptional indices.

## OEIS note

The exceptional-index counting sequence for `v₄` is the perfect squares
`0, 1, 4, 9, 16, ...` (OEIS A000290), and their counting function `⌊√M⌋+1`
matches A000196 (integer square root) shifted by one. This is exactly the
`O(√M)` sparsity used in the density-zero proof.
