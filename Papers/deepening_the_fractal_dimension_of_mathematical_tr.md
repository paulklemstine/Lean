# Computational Evidence — Density Theories and Their Fractal Dimension

We model a statement of length `n` as a binary string `Fin n → Bool`. A *theory*
`T` accepts a finite set of strings at each length; its fractal (box-counting)
dimension is `limsup_n log₂(count T n) / n`.

A **periodic density theory** `densityTheory m R` frees coordinate `i` exactly
when `i mod m ∈ R`, and forces the others to `false`. The number of free
coordinates below `n` is `freeCount m R n`, and the exact counting law is
`count = 2 ^ freeCount`.

## 1. Small-case free-coordinate counts

Modulus `m = 2`, admissible residue `R = {0}` (free = even coordinate):

| n         | 0 | 1 | 2 | 3 | 4 | 5 |
|-----------|---|---|---|---|---|---|
| freeCount | 0 | 1 | 1 | 2 | 2 | 3 |

`freeCount 2 {0} n = ⌈n/2⌉`, so `freeCount/n → 1/2`.

Modulus `m = 3`, admissible residue `R = {0}` (density `1/3`):

| n         | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|-----------|---|---|---|---|---|---|---|---|---|
| freeCount | 0 | 1 | 1 | 1 | 2 | 2 | 2 | 3 | 3 |

`freeCount 3 {0} n = ⌈n/3⌉`, so `freeCount/n → 1/3`.

Both tables are reproduced by the in-file `#eval` checks
`(List.range 6).map (freeCount 2 {0})` and `(List.range 9).map (freeCount 3 {0})`.

## 2. The counting law, checked numerically

For `m = 2`, `R = {0}`, `n = 4`: `freeCount 2 {0} 4 = 2`, and the theory accepts
`2 ^ 2 = 4` strings (the four assignments of the two even coordinates, the two
odd coordinates forced to `false`). The `#eval 2 ^ freeCount 2 {0} 4` confirms
the value `4`.

## 3. The dimension sandwich

The finite estimate is `dimEstimate n = freeCount m R n / n`. Using
`R.card·⌊n/m⌋ ≤ freeCount ≤ R.card·⌊n/m⌋ + R.card` together with
`m·⌊n/m⌋ ≤ n < m·⌊n/m⌋ + m`, one gets for `n ≥ 1`

    |dimEstimate n − R.card/m| ≤ R.card / n,

so the estimates converge to `R.card / m` at rate `O(1/n)`. Numerically, for
`m = 2, R = {0}`: `dimEstimate n = ⌈n/2⌉/n = 1/2 + O(1/n)`.

## 4. Realizability sample

Choosing `m = q` and `R = {0,…,p−1}` gives dimension `p/q`. Spot checks:

| target p/q | (m, R)          | dimension |
|------------|-----------------|-----------|
| 0/1        | (1, ∅)          | 0         |
| 1/3        | (3, {0})        | 1/3       |
| 1/2        | (2, {0})        | 1/2       |
| 2/3        | (3, {0,1})      | 2/3       |
| 1/1        | (1, {0})        | 1         |

Each is a fully proved statement in the accompanying development
(`boxDim_empty`, `boxDim_half`, `boxDim_full`, and the two `example`s).

## 5. Counterexample hunt

We tested whether any density theory could exceed dimension `1` or drop below `0`:
none can, since `0 ≤ freeCount/n ≤ 1` for all `n` (there are at most `n` free
coordinates among the first `n`). The universal bounds `0 ≤ boxDim ≤ 1` are
therefore attained but never violated, matching `boxDim_full` and `boxDim_empty`.

## OEIS note

`freeCount 2 {0} = 0,1,1,2,2,3,3,4,…` is `⌈n/2⌉` (OEIS A004526 shifted), and
`freeCount 3 {0} = 0,1,1,1,2,2,2,3,3,…` is `⌈n/3⌉` (OEIS A002264 shifted). The
appearance of `⌈n/k⌉` families is exactly the linear-density signature that forces
dimension `1/k`.
