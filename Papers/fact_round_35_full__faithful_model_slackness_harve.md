# Computational Evidence — Round 35 (faithful-model slackness)

All numbers below were produced by `#eval` over the exact (`ℚ`) definitions in
`Catalog/Logic/HarveyFaithfulSlackness.lean` (exponent model `r = N^a`, `m = N^b`).
They are exploratory checks; the claims themselves are proved in that file.

## 1. Two-dimensional grid, `a, b ∈ {0, 1/80, …, 1/2}` (1681 points)

| quantity | value |
|---|---|
| min `faithfulExp` (four legs) | `1/5` |
| min `relaxExp` (catalog three-leg model) | `1/5` |
| grid argmin of `faithfulExp` | only `(1/5, 1/5)` |
| points with `pairLegExp a < 1/5` or `faithfulExp < 1/5` | 0 |

Consistent with `faithful_lower`, `faithful_unique_minimizer`, `pair_leg_lower`.

## 2. Fourth floor of weight `1/2`, `a, b, c ∈ {0, 1/72, …, 1/3}` (15625 points)

| model | grid minimum |
|---|---|
| relaxation (`relaxFourExp`, no `M`-leg) | `1/6` (attained at `a=b=c=1/6`) |
| faithful (`faithfulFourExp`, with `M`-leg) | `29/144 ≈ 0.2014` (grid nearest to `1/5`; `1/5` is not on this grid) |

So the "fourth floor ⇒ `1/6`" lever holds only in the relaxation; the `M`-leg keeps the
faithful model at `≥ 1/5` (`fourth_floor_blocked`).

## 3. Floor deletions (exact)

| deleted floor | optimum | penalty over `1/5` |
|---|---|---|
| baby-step `m` (`b = 0`) | `1/3` | `2/15` |
| pair `r` (`a = 0`) | `1/4` | `1/20` |

(`m_floor_deletion`, `pair_floor_deletion`, `deletion_penalties`.) `N^{1/20}` is the
pair-floor deletion, not the `m`-floor deletion.

## 4. Uniform `k`-level split penalty `√k` (`uniform_split_cost`)

| k | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| cost / single-level cost | 1.000 | 1.414 | 1.732 | 2.000 | 2.236 | 2.449 | 2.646 | 2.828 |

## OEIS
No integer sequence arises; OEIS search not applicable.

## Counterexample hunt
No counterexample to any stated inequality on any grid above.
