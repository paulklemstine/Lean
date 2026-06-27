# Computational Evidence — Average Stack-Sorting Depth

All data below was produced by `#eval` on the executable definitions in
`Catalog/Applications/StackSortingDepth.lean` (West's one-pass stack-sorting map
`stackSort`, the iteration count `depth`, and the permutation enumerator `permsN`).
Every claim that became a theorem in the Lean file is marked ✅ (machine-checked there,
by `native_decide`).

## 1. Algorithm sanity checks

| input        | `stackSort` output | note                                   |
|--------------|--------------------|----------------------------------------|
| `[2,3,1]`    | `[2,1,3]`          | matches West's recursive `s(LnR)=s(L)s(R)n` ✅ |
| `[3,2,1]`    | `[1,2,3]`          | decreasing word sorts in ONE pass ✅    |
| `[4,3,2,1]`  | `[1,2,3,4]`        | `depth = 1` ✅                          |

Insight: the reverse identity is *not* the hardest input — it avoids the pattern 231 and
is 1-stack-sortable.

## 2. Depth distribution over `S_n`

Counts `[#depth=0, #depth=1, #depth=2, …]`:

| n | distribution                  | n!  | Σ depth | average |
|---|-------------------------------|-----|---------|---------|
| 2 | `[1, 1]`                      | 2   | 1       | 0.5000  |
| 3 | `[1, 4, 1]`                   | 6   | 6       | 1.0000  |
| 4 | `[1, 13, 8, 2]`              | 24  | 35      | 1.4583  |
| 5 | `[1, 41, 49, 23, 6]`        | 120 | 232     | 1.9333  |
| 6 | `[1, 131, 276, 198, 90, 24]`| 720 | 1757    | 2.4403  |
| 7 | (sum only)                   | 5040| 14982   | 2.9726  |

Observations:
- `#depth = 0` is always `1` (only the identity).  ✅ (`depth_sorted`)
- maximal depth equals `n-1`.  ✅ (`maxdepth_value_6`)

## 3. Cumulative counts and OEIS identification

`#{w ∈ S_n : depth(w) ≤ t}` = number of *t-stack-sortable* permutations.

| t | n=1..6 cumulative counts       | closed form                                   | OEIS    |
|---|--------------------------------|-----------------------------------------------|---------|
| 1 | `1, 2, 5, 14, 42, 132`        | Catalan `C_n = binom(2n,n)/(n+1)`             | A000108 |
| 2 | `1, 2, 6, 22, 91, 408`        | West `W₂(n) = 2·(3n)!/((n+1)!(2n+1)!)`        | A000139 |

Both identifications are exact for all tested `n ≥ 1` and are recorded as theorems
(`catalan_law_4/5/6`, `twostack_law_4/5/6`). ✅

## 4. Maximal-depth count

`#{w ∈ S_n : depth(w) = n-1}` for n=3..6: `1, 2, 6, 24` = `(n-2)!` (A000142 shifted).
Recorded as `maxdepth_law_4/5/6`. ✅

## 5. Sum of depths (numerator of the average)

`Σ_{w∈S_n} depth(w)` for n=0..7: `0, 0, 1, 6, 35, 232, 1757, 14982`.
This integer sequence was not identified with an OEIS entry with certainty, so no ID is
asserted. The induced averages (column "average" above) grow steadily and slightly below
`(n-1)/2`; pinning down the exact asymptotic constant is the open target carried into
`FUTURE_DIRECTIONS.md`.

## 6. Counterexample hunt

The two universal lemmas proved abstractly — `stackSort` is a permutation of its input
(`stackSort_perm`) and a strictly increasing list is a fixed point
(`stackSort_strictSorted_eq`) — were also spot-checked on all permutations of `[n]`,
`n ≤ 7`: no counterexample. The `(n-2)!`, Catalan, and `W₂` laws were tested over the full
`S_n` for `n ≤ 6` with no exception.
