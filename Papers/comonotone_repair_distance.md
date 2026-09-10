# Computational evidence — comonotone repair distance vs. discordance mass

All numbers below were produced by `#eval` inside Lean 4 (exact rational arithmetic, `ℚ`),
on the same definitions that the formal theorems use:

* `Δ = discordanceMass x y = ∑_{i,j} max(−(xᵢ−x_j)(yᵢ−y_j), 0)` (ordered pairs),
* `δ = repairDist x y = inf { ‖d‖₁ : (x, y+d) comonotone }`.

For the search, `δ` was computed by exhaustive minimisation of `‖z − y‖₁` over all
isotonic candidate vectors `z` whose entries are drawn from the multiset of `y`-values.
That restriction is the standard normal form for ℓ¹ isotonic regression; it is a *search
heuristic here*, not a proved fact, so the numbers below are labelled "computed δ".  For
every population that appears in the formal files, the computed value coincides with the
value proved in Lean (upper bound by an exhibited repair, lower bound by the discordant-pair
certificate `violation_le_repairDist`).

## 1. Small-case table

| x | y | Δ (computed) | δ (computed) | δ proved in Lean | g·δ / Δ | Δ / (R·δ) |
|---|---|---|---|---|---|---|
| (0,1) | (3,0) | 6 | 3 | `repairDist_vx_vy` = 3 | 1/2 | 6 |
| (0,1,2) | (1,0,0) | 6 | 1 | `repairDist_wx_wy` = 1 | 1/6 | 3 |
| (0,1,2) | (0,1,0) | 2 | 1 | `repairDist_wx_wy'` = 1 | 1/2 | 1 |
| (0,1,2,3) | (1,0,1,0) | 10 | 2 | — | 1/5 | 5/3 |
| (0,1,2,3) | (3,0,0,0) | 36 | 3 | — | 1/12 | 4 |
| (0,1,2,3,4) | (1,0,0,0,0) | 20 | 1 | `famRepairDist` = 1 | 1/20 | 5 |

Here `g = 1` is the footprint separation and `R = max|xᵢ−x_j|` the range.
The last family row matches the closed form proved in
`famDiscordanceMass`: `Δ = n(n−1) = 5·4 = 20`.

## 2. Exhaustive sweep (81 populations)

`x = (0,1,2,3)` (so `g = 1`, `R = 3`, `n = 4`), `y` ranging over all of `{0,1,2}⁴`:

| claim | violations found |
|---|---|
| `g·δ ≤ Δ` (proved, `repairDist_le_discordanceMass`) | 0 / 81 |
| `2·g·δ ≤ Δ` (proved, `two_gap_repairDist_le_discordanceMass`) | 0 / 81 |
| `Δ ≤ 2·n·R·δ` (proved, `discordanceMass_le_repairDist`) | 0 / 81 |
| `Δ ≤ 2·δ·R` (the literal conjecture) | **22 / 81** |
| `δ² ≤ Δ` (the literal conjecture) | 0 / 81 on this bounded sweep |

Extremal ratios observed on the sweep:

* `max (g·δ / Δ) = 1/2`, attained — exactly the constant proved optimal in
  `optimal_constant_attained`.  This measurement is what prompted the upgrade of the
  lower bound from `g·δ ≤ Δ` to the sharp `2·g·δ ≤ Δ`.
* `max (Δ / (R·δ)) = 4 = n`, i.e. exactly half of the proved bound `2n`.  This matches
  `upper_bound_sharp_up_to_two`, which shows the outlier family attains `Δ = n·R·δ`.

## 3. Counterexample hunt

The literal conjecture `δ² ≤ Δ` survives sweeps with small bounded rates, because both
sides are then of comparable size; it fails as soon as the *amplitude* of the rates grows.
Since `Δ` and `δ` are both positively homogeneous of degree one in `y`
(`discordanceMass_smul`, `repairDist_smul`), the ratio `δ²/Δ` scales like `t`, so failure
is unavoidable for large `t`.  The smallest witness found:

```
x = (0,1), y = (3,0):  δ = 3, δ² = 9 > 6 = Δ
```

formalised as `no_quadratic_lower_bound`, and generalised to an unbounded family in
`no_superlinear_comparison`.

The dimension-free upper bound `Δ ≤ 2·δ·range(x)` fails already for three keys
(`x = (0,1,2)`, `y = (1,0,0)`: `Δ = 6 > 4`), and the sweep shows the failure is generic
(22 of 81 populations).  Formalised as `no_dimension_free_upper_bound`, with the
asymptotic version `no_bound_linear_in_range`.

## 4. Non-identifiability

`x = (0,1,2)` with `y = (1,0,0)` and `y' = (0,1,0)` both have `δ = 1`, but `Δ = 6` and
`Δ = 2`.  So `Δ` is not a function of `δ`: no ℓ¹ repair statistic can replace the pairwise
discordance data (`discordance_not_determined_by_repairDist`).

## 5. OEIS

The discordance masses of the outlier family are `Δ(n) = n(n−1) = 2, 6, 12, 20, 30, …`
(A002378, oblong/pronic numbers) — the closed form is proved in `famDiscordanceMass`, so
the OEIS match is a sanity check rather than evidence.
