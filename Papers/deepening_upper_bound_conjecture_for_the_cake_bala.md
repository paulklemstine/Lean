# Computational Evidence — Cake-Balancing Ratio

We study the *balancing ratio* of a circular dissection into `n` pieces:
for a window length `r`, `μ_r = (max window weight) / (min window weight)`,
where a window weight is the sum of `r` cyclically consecutive pieces.

## 1. Small-case calculations

Using an explicit cyclic model over the rationals (window sums, then the ratio
of the extremal windows), we evaluated `μ_r` on concrete dissections.

**Bisection configuration at `n = 6`** (`2^2 ≤ 6 < 2^3`, so `k = 2`; four short
pieces of size `1/8` and two long pieces of size `1/4`), circumference `1`:

| `r` | `μ_r` |
|-----|-------|
| 1   | 2     |
| 2   | 2     |
| 3   | 5/3   |
| 5   | 7/6   |

Every value is `≤ 2`, matching `dyad_mu_le_two`, and the ratio *decreases* as the
window grows — larger windows average away the local imbalance, consistent with
`mu_le_mu_one`.

**A generic `8`-piece dissection** `[3,1,4,1,5,9,2,6]`: here `μ_1 = 9`, and for
every `r ∈ {2,…,7}` the check `μ_r ≤ μ_1` returns `true`, confirming the
aggregation principle `mu_le_arcRatio` / `mu_le_mu_one`.

## 2. Sequence context

The bisection scheme keeps, at each stage `2^k ≤ n < 2^{k+1}`, exactly two piece
lengths `1/2^{k+1}` and `1/2^{k}` (the second is twice the first).  The maximal
piece-to-piece ratio is therefore `2` for all non-power-of-two `n` and `1` at the
powers of two.  The associated sequence of counts of short pieces
`0,2,4,…` (as `n` runs through a dyadic block) is the elementary "distance to the
previous power of two, doubled"; the two-length structure is the only feature the
upper-bound argument uses.

## 3. Counterexample hunt

We searched for a dissection with two distinct piece sizes violating
`μ_r ≤ maxArc/minArc`: none exists, because each window weight lies between
`r·minArc` and `r·maxArc`, so the ratio of extremal windows cannot exceed
`maxArc/minArc` (the factor `r` cancels exactly).  This is `mu_le_arcRatio`.

We also checked the boundary `r = 0`: the empty window has weight `0`, the ratio
degenerates to `0/0`, and every statement in the development correctly excludes it
via the hypothesis `1 ≤ r`.

## 4. Take-away

The numerics single out two robust phenomena, both promoted to theorems:
aggregation never increases imbalance (`μ_r ≤ μ_1`), and the two-length bisection
strategy caps the long-run ratio at `2` for every window length.
