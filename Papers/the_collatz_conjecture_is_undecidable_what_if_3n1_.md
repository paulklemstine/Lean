# Computational Evidence — Collatz Map Dynamics and the Min-Plus Stopping Time

## 1. Small-case calculations

The Collatz map is `T(n) = n/2` for even `n` and `3n+1` for odd `n`.
Total stopping times `σ(n)` (least number of steps to reach `1`) for small `n`:

| n  | orbit (until 1)                                   | σ(n) |
|----|---------------------------------------------------|------|
| 1  | 1                                                 | 0    |
| 2  | 2 → 1                                              | 1    |
| 3  | 3 → 10 → 5 → 16 → 8 → 4 → 2 → 1                    | 7    |
| 4  | 4 → 2 → 1                                          | 2    |
| 7  | 7 → 22 → 11 → 34 → 17 → 52 → 26 → 13 → 40 → 20 → 10 → 5 → 16 → 8 → 4 → 2 → 1 | 16 |
| 27 | (peaks at 9232)                                   | 111  |

## 2. Powers of two (exact stopping time)

`σ(2^m) = m` exactly, since `T(2^m) = 2^{m-1}`. Verified for `m = 0..9`:
`[σ(1),σ(2),…,σ(512)] = [0,1,2,3,4,5,6,7,8,9]`.
This is proved unconditionally as `collatz_iterate_pow_two`.

## 3. Min-plus recurrence check

The stopping time satisfies the tropical (min-plus) shortest-path law
`σ(n) = 1 + σ(T n)` for `n ≠ 1`. Spot checks:
`σ(3) = 1 + σ(10) = 1 + 6 = 7`, `σ(7) = 1 + σ(22) = 1 + 15 = 16`,
`σ(27) = 1 + σ(82) = 1 + 110 = 111`. This is proved as `stoppingTime_rec`.

## 4. Counterexample hunt

The universal claim `Collatz` (every positive `n` reaches `1`) was tested on
`n = 1..2000` by iterating the map; every orbit reached `1`. No counterexample
was found (consistent with verification to `2^68` in the literature). Accordingly
the file proves only the *unconditional* structural facts and the concrete finite
orbits, never assuming `Collatz` itself.

## 5. Sequence identification

`σ(n)` is OEIS **A006577** ("number of halving and tripling steps to reach 1"),
first terms `0, 1, 7, 2, 5, 8, 16, 3, 19, 6, 14, 9, …`.
