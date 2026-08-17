# Computational evidence — price of universality (minimax redundancy)

All formal claims live in `Catalog/MachineLearning/UniversalRedundancy/`.
This note records the numerical exploration that guided the theorems.

## 1. Exact small-case values (Lean-verified, exact rational arithmetic)

The Shtarkov / NML normalizer of the binary memoryless class,

`Cₛ(n) = ∑_{k=0}^{n} C(n,k) (k/n)^k ((n−k)/n)^{n−k}`,

is computed in exact rational arithmetic in
`Catalog/MachineLearning/UniversalRedundancy/Evidence.lean`:

| n | `Cₛ(n)` (exact) | `Cₛ(n)` (decimal) |
|---|-----------------|-------------------|
| 2 | 5/2             | 2.5               |
| 4 | 103/32          | 3.21875           |
| 8 | 556403/131072   | 4.245018          |

These values, and the sandwich checks `Cₛ² ≥ n/16` (equivalent to `Cₛ ≥ √n/4`)
and `Cₛ ≤ n+1`, are proved as theorems
(`shtarkovBernoulliQ_two/four/eight`, `shtarkovBernoulliQ_sandwich_checks`),
so they are verified rather than merely computed. Strict growth
`Cₛ(2) < Cₛ(4) < Cₛ(8)` is also a proved theorem.

## 2. Larger n (exploratory floating point — NOT verified)

Floating-point evaluation inside Lean (`#eval`, not part of any proof):

| n   | `Cₛ(n)` | `√(πn/2)` | lower bound `√n/4` | upper bound `n+1` |
|-----|---------|-----------|--------------------|-------------------|
| 2   | 2.500   | 1.772     | 0.354              | 3                 |
| 4   | 3.219   | 2.507     | 0.500              | 5                 |
| 8   | 4.245   | 3.545     | 0.707              | 9                 |
| 16  | 5.704   | 5.013     | 1.000              | 17                |
| 32  | 7.774   | 7.090     | 1.414              | 33                |
| 64  | 10.706  | 10.027    | 2.000              | 65                |
| 128 | 14.855  | 14.180    | 2.828              | 129               |
| 256 | 20.726  | 20.053    | 4.000              | 257               |

Reading: `Cₛ(n) − √(πn/2)` stays small and slowly varying (≈ 0.67 at n = 256),
matching the classical asymptotic `Cₛ ~ √(πn/2) + 2/3 + o(1)`. In bits,
`log₂ Cₛ ≈ ½ log₂ n + 0.33`, i.e. the Rissanen `(d/2) log₂ n` rate with `d = 1`.
This is exploratory evidence only; the proved statements are the two-sided
bounds `√n/4 ≤ Cₛ ≤ n+1`.

## 3. What the exploration decided

* The *lower* bound had to come from a two-sided Stirling estimate: crude
  bounds (`m! ≥ (m/e)^m`, `C(n,k) ≥ 2^{nH(k/n)}/(n+1)`) lose the `1/√n`
  per-type factor and only give `Cₛ ≥ 1`, which is vacuous. The table above
  shows the truth is `Θ(√n)`, so the `√` precision of Stirling is necessary —
  this is why `factorial_le_stirling_upper` (from the antitonicity of Mathlib's
  Stirling sequence) plus `Stirling.le_factorial_stirling` are used.
* The constant `1/(2√n)` per interior type is not tight (the truth is
  ≈ `√(n/(2πk(n−k)))`), but it is enough to reach the classical rate with the
  explicit constant `−2` bits.
* The upper bound `Cₛ ≤ n+1` is exactly the number of types; the general
  statistic bound `(n+1)^{#A}` is one power lossy for `#A = 2`, which the
  binary-specific `shtarkovSum_bernoulli_le` repairs.

## 4. Counterexample hunt

* Conjecture "the price of universality is bounded in `n`" is refuted by the
  proved lower bound (and visibly by the table).
* Conjecture "the price is `Θ(n)` for every class" is refuted by the proved
  upper bound `log₂ Cₛ ≤ log₂(n+1)` for the memoryless class.
* Conjecture "`Cₛ = #Θ` in general" fails for the memoryless class (`Θ` is
  infinite, `Cₛ ≤ n+1`); it holds exactly for mutually singular classes
  (`shtarkovSum_eq_card_of_disjoint_supports`, `shtarkovSum_deltaClass`).
