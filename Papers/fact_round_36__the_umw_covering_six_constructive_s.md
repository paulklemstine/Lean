# Computational Evidence — UMW covering frontier (round 36)

Exploratory Python runs (not machine-verified; the formal statements are in
`Catalog/Cryptography/FactoringBarriers/UMWCoveringFrontier.lean`).

## 1. The counting wall, numerically
`ln lcm(1..n)` against the bound used in the Lean proof (`ln C(2k,k)` with `k = ⌊n/2⌋`) and the
final explicit bound `(n-1) ln 2 - ln n` from `real_wall`:

| n | ln lcm(1..n) | ln C(2k,k) | (n-1) ln 2 − ln n |
|---|---|---|---|
| 10 | 7.83 | 5.53 | 3.94 |
| 20 | 19.27 | 12.13 | 10.17 |
| 50 | 49.49 | 32.47 | 30.05 |
| 100 | 94.05 | 66.78 | 64.02 |
| 200 | 206.15 | 135.75 | 132.64 |
| 500 | 501.65 | 343.24 | 339.67 |
| 1000 | 996.68 | 689.47 | 685.55 |

All three grow linearly in `n` (ratio ≈ ln 2 / 1 ≈ 0.69 for the binomial bound). The constant is
not needed for the exponent constraint: only linear growth matters.

## 2. Smallest two-sided coverings (`|S| = |T| = 2`), exhaustive search
Smallest `M = max S` such that `S, T ⊆ [0, M]`, `|S| = |T| = 2`, and every `i ≤ n` divides a
positive difference `s − t`:

| n | M | witness (S, T) |
|---|---|---|
| 2 | 2 | ({1,2},{0,1}) |
| 5 | 5 | ({3,5},{0,1}) |
| 8 | 8 | ({6,8},{0,1}) |
| 9 | 18 | ({7,18},{0,2}) |
| 10 | 20 | ({16,20},{0,2}) |

Every witness clears the wall `lcm(1..n) ≤ ∏(s−t)` (e.g. `n = 8`: `840 ≤ 6·8·5·7 = 1680`).
No counterexample to `counting_wall` was found (none can exist, since it is proved).

## 3. Counterexample hunt
* Overlapping `S ∩ T ≠ ∅` with the zero difference allowed covers every `n` at once —
  formalised as `overlap_trivializes`; this is why the disjoint guard is essential.
* Empirical frontier point `(α,β) = (1/2, 2/3)`: already strictly inside the region the
  trivial covering reaches (`α = 1 − β = 1/3` at `β = 2/3`), formalised as
  `empirical_point_dominated`.

No OEIS lookup was relevant (`lcm(1..n)` is A003418; not otherwise used).
