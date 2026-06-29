# Computational Evidence — Cusick's Sum-of-Digits Explicit Bound

Let `s₂(n)` be the number of `1`s in the binary expansion of `n`, and
`c_t = density { n : s₂(n + t) ≥ s₂(n) }`. Cusick's (now proved) theorem:
`c_t ≥ 1/2 + 2^{-(2·s₂(t) + 1)}`.

## 1. Finite-window densities

Counting, for each `t`, how many `n ∈ [0, 1024)` satisfy `s₂(n) ≤ s₂(n + t)`
(computed in Lean with `Nat.digits 2`):

| t | s₂(t) | #good / 1024 | finite density | conjectured bound 1/2 + 2^-(2s₂(t)+1) |
|---|-------|--------------|----------------|----------------------------------------|
| 1 | 1     | 768          | 0.7500         | 0.6250 |
| 2 | 1     | 768          | 0.7500         | 0.6250 |
| 3 | 2     | 704          | 0.6875         | 0.5313 |
| 4 | 1     | 768          | 0.7500         | 0.6250 |
| 5 | 2     | 640          | 0.6250         | 0.5313 |
| 6 | 2     | 704          | 0.6875         | 0.5313 |
| 7 | 3     | 688          | 0.6719         | 0.5078 |
| 8 | 1     | 768          | 0.7500         | 0.6250 |

Every row satisfies the bound, with comfortable slack. (Finite windows only
approximate the true asymptotic `c_t`; the table is corroborating, not a proof.)

## 2. The `t = 1` exact density

For `t = 1` the condition reduces, via Kummer's theorem, to `v₂(n+1) ≤ s₂(1) = 1`,
i.e. `n % 4 ≠ 3`. Over `[0, 4m)` exactly `3m` integers qualify, so

```
c₁ = 3/4 = 0.75   ≥   1/2 + 2^{-3} = 5/8 = 0.625.
```

This is proved exactly (no finite enumeration) in
`CusickDensityWitness.cusick_t1_density`. The finite window above (768/1024 = 3/4)
matches the proved value.

## 3. Powers of two

For `t = 2^j` (so `s₂(t) = 1`) the windows give density `3/4` (rows `t = 1,2,4,8`),
matching the heuristic `c_{2^j} = 1/2 + 1/4`: adding `2^j` carries iff the run of
`1`s starting at bit `j` has length `≥ 2`, which has density `1/4`.

## 4. Counterexample hunt

No `t ∈ [1, 8]` violates the bound on `[0, 1024)`. The carry reformulation
(`CusickCarry.cusick_reformulation`) shows the inequality is *exactly*
`#carries(n, t) ≤ s₂(t)`, so a violation of `c_t ≥ 1/2` would require the carry
count to exceed `s₂(t)` for a majority of `n` — ruled out heuristically by the
fact that the mean of `s₂` over a block is `k/2` (`CusickSumDigits.s2_block_sum`).

## OEIS pointers

* Binary digit sum `s₂(n)`: OEIS A000120 (0,1,1,2,1,2,2,3,...).
* `n` with `n % 4 = 3` (complement of the `t=1` good set): A004767 (3,7,11,...).
