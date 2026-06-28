# Computational Evidence — Ramsey number function `R(s,t)`

This cycle introduces `ramseyNumber s t = sInf {n | Arrows n s t}` and proves
its exact small values, order properties, the Erdős–Szekeres bounds, and a
diagonal sandwich. Below is the numerical sanity-checking that guided the
formalization.

## 1. Exact small values (known, all formalized this cycle)

| R(s,t) | t=1 | t=2 | t=3 | t=4 |
|--------|-----|-----|-----|-----|
| s=1    | 1   | 1   | 1   | 1   |
| s=2    | 1   | 2   | 3   | 4   |
| s=3    | 1   | 3   | 6   | 9   |
| s=4    | 1   | 4   | 9   | 18  |

The shaded diagonal/off-diagonal entries proved as `ramseyNumber_* = …`:
`R(3,3)=6`, `R(3,4)=9`, `R(4,3)=9`, `R(4,4)=18`, and `R(2,t+1)=t+1`.
These match OEIS A212954 (table of two-colour Ramsey numbers) and the classical
small-Ramsey survey values.

## 2. Erdős–Szekeres binomial bound `R(s,t) ≤ C(s+t-2, s-1)`

Spot checks against the exact table (the bound is tight at small `s` or `t`,
loose on the diagonal):

| (s,t) | R(s,t) | C(s+t-2,s-1) |
|-------|--------|--------------|
| (2,4) | 4      | C(4,1)=4 (tight) |
| (3,3) | 6      | C(4,2)=6 (tight) |
| (3,4) | 9      | C(5,2)=10 |
| (4,4) | 18     | C(6,3)=20 |

All rows satisfy `R ≤ C(...)`, confirming `ramseyNumber_le_choose`.

## 3. Erdős–Szekeres recursion `R(s,t) ≤ R(s-1,t) + R(s,t-1)`

- `R(3,3)=6 ≤ R(2,3)+R(3,2) = 3+3 = 6` (tight).
- `R(3,4)=9 ≤ R(2,4)+R(3,3) = 4+6 = 10`.
- `R(4,4)=18 ≤ R(3,4)+R(4,3) = 9+9 = 18` (tight).

Tightness at `(3,3)` and `(4,4)` is the well-known phenomenon; the proved lemma
`ramseyNumber_recursion` is the (shifted, non-degenerate) inequality.

## 4. Diagonal sandwich `2^m < R(2m,2m) ≤ 4^(2m-1)` (m ≥ 2)

| m | 2^m | R(2m,2m) | 4^(2m-1) |
|---|-----|----------|----------|
| 2 | 4   | R(4,4)=18 | 4^3 = 64 |
| 3 | 8   | R(6,6) ∈ [102,160] | 4^5 = 1024 |

For `m=2` the bracket `4 < 18 ≤ 64` is verified directly against the exact value
`R(4,4)=18`. The general statement is `ramseyNumber_diagonal_sandwich`.

## 5. Counterexample hunt

The universal claims under test — symmetry `R(s,t)=R(t,s)`, monotonicity, and the
two bounds — were checked on every entry of the `s,t ≤ 4` table with no violation.
No counterexample found; all became theorems.
