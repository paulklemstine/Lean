# Computational Evidence — Row Sum Fibonacci Property of the Pascal-like Riordan Array

## Object

Riordan array `(1/(1-x), x/(1-x)^2)` with entries `t_{n,k} = C(n+k, 2k)`.
Row sum `A(n) = Σ_{k≥0} C(n+k, 2k)`.

## Small-case calculations

| n | row entries C(n+k,2k), k=0.. | A(n) = row sum | fib(2n+1) |
|---|------------------------------|----------------|-----------|
| 0 | 1                            | 1              | 1         |
| 1 | 1, 1                         | 2              | 2         |
| 2 | 1, 3, 1                      | 5              | 5         |
| 3 | 1, 6, 5, 1                   | 13             | 13        |
| 4 | 1, 10, 15, 7, 1             | 34             | 34        |
| 5 | 1, 15, 35, 28, 9, 1        | 89             | 89        |
| 6 | ...                          | 233            | 233       |
| 7 | ...                          | 610            | 610       |

Computed in Lean (`#eval`): `A(n)` matches `Nat.fib (2*n+1)` for n = 0..7. ✓

## A companion sequence

Define `B(n) = Σ_{k≥0} C(n+k, 2k+1)`. Computation gives
`B(n) = 0, 1, 3, 8, 21, 55, 144, 377` = `fib(2n)`. ✓

## OEIS

- Row sums `1, 2, 5, 13, 34, 89, 233, 610, ...` = odd-indexed Fibonacci numbers, OEIS A001519.
- The array `C(n+k,2k)` is OEIS A085478 (triangle of `C(n+k,2k)`).
- The generating function of the row sums is `(1-x)/(1-3x+x^2)`, the g.f. of A001519,
  reflecting the recurrence `A(n+1) = 3 A(n) - A(n-1)`.

## Recurrence verified computationally

Two coupled Pascal recurrences, checked for n = 0..5 in Lean:
- `B(n+1) = A(n) + B(n)`   (pure additive Pascal, no reindexing)
- `A(n+1) = A(n) + B(n+1)` (reindexing of the lower-odd diagonal)

Both hold for all tested n. These reduce, with `A(0)=1=fib 1`, `B(0)=0=fib 0`, to a
simultaneous induction giving `A(n)=fib(2n+1)`, `B(n)=fib(2n)`. Combining the two yields
`A(n+1) = 3 A(n) - A(n-1)`, matching the g.f. `(1-x)/(1-3x+x^2)`.

## Counterexample hunt

No counterexample to `A(n) = fib(2n+1)` found in n = 0..7 (exact, exhaustive).
