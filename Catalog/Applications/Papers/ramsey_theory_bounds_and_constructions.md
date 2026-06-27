# Computational Evidence — Probabilistic Ramsey Lower Bound

Evidence supporting the formalized results in
`Applications/RamseyProbabilisticLowerBound.lean`. All numbers below were computed
with Lean `#eval` over exact `ℕ` arithmetic (`Nat.choose`), so they are exact, not
floating point.

## 1. The first-moment threshold `2·C(n,k) < 2^{C(k,2)}`

The probabilistic method gives `R(k,k) > n` whenever `2·C(n,k) < 2^{C(k,2)}`
(`arrows_lower_bound_counting`). Evaluating the predicate
`chk n k := decide (2 * n.choose k < 2 ^ (k.choose 2))`:

| k | largest n with `chk n k = true` | conclusion |
|---|---|---|
| 5 | 11 | `R(5,5) > 11` (i.e. `≥ 12`) |
| 6 | 17 | `R(6,6) > 17` (i.e. `≥ 18`) |

(The true values are `R(5,5) ≥ 43`, `R(6,6) ≥ 102`; the first-moment bound is
correct but, as expected, far from optimal — see Future Direction 1, the deletion
method.)

## 2. The exponential corollary `R(2m, 2m) > 2^m`

`ramsey_diagonal_lower` requires `m ≥ 2`. Checking `chk (2^m) (2*m)`:

| m | n = 2^m | k = 2m | `2·C(n,k) < 2^{C(k,2)}` |
|---|---------|--------|--------------------------|
| 0 | 1  | 0  | false (vacuous, k=0) |
| 1 | 2  | 2  | false (2·1 = 2, 2^1 = 2) |
| 2 | 4  | 4  | **true** (2·1 = 2 < 64) |
| 3 | 8  | 6  | **true** |
| 4 | 16 | 8  | **true** |
| 5 | 32 | 10 | **true** |

The threshold `m ≥ 2` in the theorem is sharp for this argument: `m = 1` fails
(equality `2 = 2`), confirming the hypothesis `hm : 2 ≤ m` is necessary, not
cosmetic.

## 3. Bracketing the diagonal

Combining with the catalog's upper bound `R(k+1,k+1) ≤ 4^k`
(`Applications/RamseyDiagonalBound.arrows_diagonal_pow`), the diagonal Ramsey
number now satisfies, on the common `Arrows` framework,

```
2^{k/2}  <  R(k,k)  ≤  4^{k-1}.
```

For example `k = 4`: `2^2 = 4 < R(4,4) = 18 ≤ 4^3 = 64`, consistent with the exact
value `R(4,4) = 18` proved in `Applications/RamseyFourFour.lean`.

## 4. Van der Waerden small cases

`mono_three_AP` asserts a monochromatic 3-AP in every finite colouring of `ℕ`.
The least van der Waerden number `W(2,3) = 9`: every 2-colouring of `{0,…,8}` has a
monochromatic 3-term AP, and `{0,…,7}` admits the colouring `RRBBRRBB` with none —
classical small-case data consistent with the formalized infinite statement.

## Why this evidence is sufficient

The Lean theorems are exact and parameterized in `k`/`m`; the tables above only
confirm the hypotheses are satisfiable and the threshold `m ≥ 2` is tight. No
counterexample search is needed because the universal claims are *proved*, not
conjectured — the evidence is calibration, not verification.
