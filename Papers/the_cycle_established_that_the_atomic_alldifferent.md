# Computational Evidence: AllDifferent partition function and threshold

The central object is the partition function `partitionFn k m = k.descFactorial m`
(number of injective assignments of `m` demands into `k` resources).

## Small-case table of `k.descFactorial m` (rows k, cols m = 0..5)

```
k\m  0    1    2    3    4    5
0    1    0    0    0    0    0
1    1    1    0    0    0    0
2    1    2    2    0    0    0
3    1    3    6    6    0    0
4    1    4   12   24   24    0
5    1    5   20   60  120  120
```

Observations directly matching the formalized theorems:

- The zero/nonzero boundary is exactly the diagonal `m = k` (positive iff `m ≤ k`):
  `partitionFn_pos_iff`, `partitionFn_eq_zero_iff`.
- The diagonal value is `k!` (1, 1, 2, 6, 24, 120): `partitionFn_balance`.
- The first entry past the diagonal in each row is `0`:
  `partitionFn_above_threshold`.

The counts are the falling factorials / number of `m`-permutations of `k`, OEIS
**A008279** (triangle of `k!/(k-m)!`), first terms `1, 1, 1, 1, 2, 2, 1, 3, 6, 6, ...`.

## Sudoku line balance

For order `n`, a line has `m = k = n²`, so it sits on the diagonal:
`partitionFn (n²) (n²) = (n²)!`, positive, and `partitionFn (n²) (n²+1) = 0`.
E.g. `n = 2`: `partitionFn 4 4 = 24`, `partitionFn 4 5 = 0`. Matches
`sudoku_line_at_balance`.

## Cyclic square box failure (order n = 2, the 4×4 grid)

`L(i,j) = (i + j) mod 4`:

```
      j=0 j=1 j=2 j=3
i=0    0   1   2   3
i=1    1   2   3   0
i=2    2   3   0   1
i=3    3   0   1   2
```

Rows and columns are permutations of {0,1,2,3} (all-different). But the top-left
`2×2` box has entries `{0, 1, 1, 2}`: cells `(0,1)` and `(1,0)` both equal `1`.
This is the certified counterexample `cyclic_box_not_allDifferent`, showing the box
constraint is not implied by the row/column constraints.

## Counterexample hunt

The universal claims (`allDifferent_satisfiable_iff`, `partitionFn_pos_iff`) were
checked exhaustively over `0 ≤ k, m ≤ 6` before formalization; no counterexample
exists — the boundary is exactly `m ≤ k`, as the falling factorial dictates.
