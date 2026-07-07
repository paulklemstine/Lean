# Computational Evidence: Log-Concavity of Total d-Hoggatt Numbers

This note records the small-case computations that guided the formal development
in `HoggattLogConcavity.lean`.

## 1. The three benchmark total sequences

The total d-Hoggatt numbers `H_d(n) = ∑_{k} H_d(n,k)` specialize as follows.

| d | total sequence `H_d(n)`            | first terms                          | OEIS    |
|---|-------------------------------------|--------------------------------------|---------|
| 1 | powers of two                       | 1, 2, 4, 8, 16, 32, 64, …            | A000079 |
| 2 | Catalan numbers                     | 1, 1, 2, 5, 14, 42, 132, 429, …      | A000108 |
| 3 | Baxter numbers                      | 1, 1, 2, 6, 22, 92, 422, 2074, …     | A001181 |

## 2. Log-concavity test `a_{n+1}² ≥ a_n · a_{n+2}` (log-concave)

For each sequence we compute `Δ_n = a_{n+1}² − a_n · a_{n+2}`.  Log-concavity
requires `Δ_n ≥ 0`; log-convexity means `Δ_n ≤ 0`.

### d = 1 (powers of two): `Δ_n ≡ 0`
```
n :        0     1     2     3     4
a_{n+1}² : 4    16    64   256  1024
a_n·a_{n+2}: 4  16    64   256  1024
Δ_n :      0     0     0     0     0
```
A geometric progression is *log-linear*: `Δ_n = 0`, hence trivially log-concave,
and every iterate of the log-concavity operator vanishes → **infinitely
log-concave** (proved: `twoPow_infLogConcave`).

### d = 2 (Catalan): `Δ_n < 0` for all n — strictly LOG-CONVEX
```
n :          0    1     2      3       4
a_{n+1}² :   1    4    25    196    1764
a_n·a_{n+2}: 2    5    28    210    1848
Δ_n :       -1   -1    -3    -14     -84
```
Every entry is negative: the Catalan totals are **strictly log-convex**, not
log-concave (proved: `catalan_logConvex`, `catalan_not_logConcave`).  The exact
ratio is `C_n C_{n+2} / C_{n+1}² = (n+2)(2n+3) / ((2n+1)(n+3)) > 1`.

### d = 3 (Baxter): `Δ_n < 0` for all tested n — LOG-CONVEX
```
n :          0    1     2      3        4
a_{n+1}² :   1    4    36    484     8464
a_n·a_{n+2}: 2    6    44    552     9284
Δ_n :       -1   -2    -8    -68     -820
```
The Baxter totals are also log-convex on every tested index, mirroring the
Catalan behaviour.

## 3. Counterexample hunt

The mission statement conjectures that the *totals* are infinitely log-concave.
The very first nontrivial case already refutes the naive reading:
`C_2² = 4 < 5 = C_1 · C_3`, so the Catalan totals fail *ordinary* log-concavity
(the `k = 1` level of infinite log-concavity).  No search beyond `n = 1` is
needed to falsify the totals version for `d = 2` and, empirically, `d = 3`.

## 4. Structural reading

Rows of the d-Hoggatt triangle are log-concave, but **summation does not
preserve log-concavity**: a sum of log-concave sequences (over `k`, indexed by
`n`) can be log-convex.  The correct home of (infinite) log-concavity is the
triangle's rows and columns, not the row sums.  This is the pivot that
reorients the formal development away from a false statement and toward the
sharp `d = 1` (log-linear) vs. `d ≥ 2` (log-convex) dichotomy.
