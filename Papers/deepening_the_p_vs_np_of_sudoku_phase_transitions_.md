# Computational Evidence: The Constraint-Satisfaction Threshold of Sudoku

This note records the small-case exploration that motivated the formal results in
`SudokuConstraintThreshold.lean`.

## 1. The AllDifferent atom: cells `m` vs. symbols `k`

A block of `m` cells demanding pairwise-distinct symbols from an alphabet of size
`k` is satisfiable exactly when `m ≤ k`. Enumerating injective assignments (the
"partition function" `numProper m k = k^{\underline m}`, the falling factorial):

| `m \ k` | 1 | 2 | 3 | 4 |
|--------:|--:|--:|--:|--:|
| 0       | 1 | 1 | 1 | 1 |
| 1       | 1 | 2 | 3 | 4 |
| 2       | 0 | 2 | 6 | 12 |
| 3       | 0 | 0 | 6 | 24 |
| 4       | 0 | 0 | 0 | 24 |

The zero/non-zero boundary is exactly the line `m = k`: strictly positive on and
below the diagonal, identically zero above it. This is the sharp phase
transition, and the diagonal (`m = k`) is criticality — the last satisfiable row.

## 2. Sudoku lines sit on the diagonal

An order-`n` Sudoku grid is `n² × n²`; every row, column and box has `n²` cells
drawn from `n²` symbols, i.e. `m = k = n²`. So each line lies exactly on the
critical diagonal:

| order `n` | grid | cells/line `m` | symbols `k` | completions of one line `= (n²)!` |
|----------:|-----:|---------------:|------------:|----------------------------------:|
| 2         | 4×4  | 4              | 4           | 24 |
| 3         | 9×9  | 9              | 9           | 362880 |
| 4         | 16×16| 16             | 16          | 16! = 20922789888000 |

Adding a single extra distinct demand (`m = n² + 1`) collapses the count to `0`:
`numProper 10 9 = 0`. Sudoku is engineered to sit one step from the cliff.

## 3. Density reading

Writing the constraint density as `d = m / k`, satisfiability is exactly
`d ≤ 1`, so the critical density is `d_c = 1`. Sudoku lines have `d = n²/n² = 1`
for every order `n`, independent of `n` — the grid is scale-invariantly critical.

## 4. Counterexample hunt

We probed the tempting stronger claim "criticality is strict, `m = k` is
unsatisfiable". It is **false**: `numProper k k = k! > 0`. The boundary is closed
from below (the critical case is satisfiable), which is why full Sudoku solutions
exist at all. The formal statement therefore places `m = k` on the satisfiable
side, with the first failure at `m = k + 1`.

## 5. OEIS anchor

The diagonal counts `numProper k k = k!` are the factorials
(OEIS A000142: 1, 1, 2, 6, 24, 120, ...); the off-diagonal columns are falling
factorials / the triangle of A008279. The vanishing of A008279 above the
diagonal is the enumerative signature of the transition.

All tabulated values are reproduced by the `#eval` checks at the end of the Lean
source.
