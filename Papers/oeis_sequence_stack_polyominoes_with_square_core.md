# Computational Evidence — Stack polyominoes with a square core

Target sequence (given in the mission statement, 32 terms):

```
1, 1, 0, 0, 1, 2, 3, 4, 5, 7, 9, 13, 17, 24, 31, 42, 54, 71, 90, 117, 147, 188,
236, 298, 371, 466, 576, 716, 882, 1088, 1331, 1633
```

## 1. Structural model and the counting formula

A *stack polyomino* of area `n` is a bottom-justified column-convex polyomino whose column
heights `h₁,…,h_r ≥ 1` sum to `n` and form a **unimodal** sequence.  Its *core* is the
plateau of maximal height `k`; the core is **square** when that plateau has exactly `k`
columns, i.e. the top block is a `k × k` square.

Slicing a square-core stack as `(left slope) ++ (k × k square) ++ (right slope)`, where the
two slopes are partitions into parts `≤ k-1` (weakly increasing on the left, weakly
decreasing on the right), gives

```
a(n) = Σ_{k² ≤ n} Σ_{i+j = n-k²} p_{≤k-1}(i) · p_{≤k-1}(j),
```

equivalently the generating function `Σ_k x^{k²} / ∏_{i=1}^{k-1} (1-x^i)²`.

## 2. Small-case calculations

**(a) The formula reproduces all 32 catalogued terms.**  Evaluating the formula (in Python
and, independently, by `#eval`/`decide` inside Lean) for `n = 0,…,31` gives exactly the list
above.  The Lean statement `stackSC_table` in `Catalog/Physics/StackSquareCoreBasic.lean`
proves this equality by `decide`, so the agreement is machine-checked, not merely observed.

**(b) Brute-force enumeration.**  Enumerating *all* compositions `(h₁,…,h_r)` of `n` with
`h_i ≥ 1`, keeping those that are unimodal and whose maximum `k` occurs exactly `k` times,
gives for `n = 1,…,17`

```
1, 0, 0, 1, 2, 3, 4, 5, 7, 9, 13, 17, 24, 31, 42, 54, 71
```

which agrees with the formula on the whole range.  The bijection underlying (a) is proved
formally in `Catalog/Physics/StackSquareCoreStacks.lean`
(`card_squareCoreStacks`: the Finset of genuine height-lists has cardinality `stackSC n`),
so this is a check of the formalization rather than of the mathematics.

## 3. Regularity of the sequence

First differences `a(n+1) - a(n)`, `n = 0,…,30`:

```
0, -1, 0, 1, 1, 1, 1, 1, 2, 2, 4, 4, 7, 7, 11, 12, 17, 19, 27, 30, 41, 48, 62, 73,
95, 110, 140, 166, 206, 243, 302
```

Second differences, `n = 0,…,29`:

```
-1, 1, 1, 0, 0, 0, 0, 1, 0, 2, 0, 3, 0, 4, 1, 5, 2, 8, 3, 11, 7, 14, 11, 22, 15,
30, 26, 40, 37, 59
```

All second differences are `≥ 0` from `n = 2` onwards (checked numerically up to `n = 200`),
and this is now a theorem: `stackSC_convex` in
`Catalog/Physics/StackSquareCoreConvexity.lean`.

*Counterexample hunt (log-concavity).*  The natural companion property `a(n)² ≥
a(n-1)a(n+1)` **fails**: the first counterexample is `n = 8`, where
`a(8)² = 25 < 28 = a(7)·a(9)`.  This is recorded as the theorem
`stackSC_not_logConcave`.

## 4. Growth data

| `n`   | `log a(n) / √n` |
|-------|-----------------|
| 16    | 0.9972 |
| 64    | 1.6186 |
| 100   | 1.7650 |
| 400   | 2.0976 |
| 900   | 2.2268 |
| 1600  | 2.2971 |
| 2500  | 2.3419 |

The ratio is increasing and appears to approach the Hardy–Ramanujan constant
`π√(2/3) = 2.5651…`; a saddle-point computation on the generating function
`Σ_k x^{k²} ∏_{i<k}(1-x^i)^{-2}` predicts exactly that constant, with the dominant core size
`k ≈ (log 2/π)√(6n) ≈ 0.5404 √n`.  The observed dominant layer is `k = 6` at `n = 100`
(predicted `5.40`) and `k = 8` at `n = 200` (predicted `7.64`).

The proved bounds bracket this behaviour:
`((√n − 2)/2)·log 2 ≤ log a(n) ≤ 30 √n` for `n ≥ 100`
(`stackSC_log_sqrt_sharp`), i.e. `log a(n) ≍ √n` — the two `IsBigO` statements
`log_stackSC_isBigO_sqrt` and `sqrt_isBigO_log_stackSC`.

## 5. Comparison with the partition function

Numerically `a(n) ≤ p(n)` for all `n ≤ 200`, with `log a(n)/log p(n)` equal to
`0.8834, 0.9258, 0.9515` at `n = 50, 100, 200`.  The inequality is explained by the Durfee
square identity `Σ_k x^{k²} ∏_{i≤k}(1-x^i)^{-2} = ∏_{i≥1}(1-x^i)^{-1}`: the generating
function of `a` is the same sum with the products truncated one step earlier, hence
coefficientwise smaller.  This is not yet formalized and appears as a future direction.

## 6. Divergence of the increments

The increment sequence `g(n) = a(n+1) − a(n)` (`n = 0,…,30`) is

```
0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 4, 4, 7, 7, 11, 12, 17, 19, 27, 30, 41, 48,
62, 73, 95, 110, 140, 166, 206, 243, 302
```

(computed over `ℕ`, so the single negative difference `a(2) − a(1)` truncates to `0`).
The sequence is non-decreasing from `n = 1` on — exactly the content of the convexity
theorem — and the telescoping inequality `a(j+2) ≤ j·(a(j+2) − a(j+1))` holds for every
`j ≤ 29` in the table.  Combined with superpolynomial growth this forces `g(n) → ∞`,
which is the proved statement `stackSC_gap_tendsto_atTop`
(with the explicit form `g(n) ≥ n` once `a(n+1) ≥ (n+1)²`, `stackSC_gap_ge`).

## 7. The third core layer and the third differences

The layer `k = 3` is governed by `conv 2 m = Σ_{i+j=m} p_{≤2}(i)p_{≤2}(j)`, whose first
values (`m = 0,…,10`) are

```
1, 2, 5, 8, 14, 20, 30, 40, 55, 70, 91
```

matching the quasi-polynomial `24·conv 2 (2s) = (2s+2)(2s+3)(2s+4)` and
`24·conv 2 (2s+1) = (2s+2)(2s+4)(2s+6)` for every `s ≤ 8` (checked by direct evaluation, and
proved in `Catalog/Physics/StackSquareCoreLayerThree.lean`).  Its differences are

```
Δ  : 1, 3, 3, 6, 6, 10, 10, 15, 15, 21
Δ² : 2, 0, 3, 0, 4, 0, 5, 0, 6
Δ³ : -2, 3, -3, 4, -4, 5, -5, 6
```

so the third difference alternates with period two and linearly growing amplitude — an
infinite family of failures of 3-convexity, now a theorem rather than an observation.

For the counting function itself, the third differences `Δ³a(n)` for `n = 0,…,31` are

```
2, 0, -1, 0, 0, 0, 1, -1, 2, -2, 3, -3, 4, -3, 4, -3, 6, -5, 8, -4, 7, -3, 11, -7,
15, -4, 14, -3, 22, -7, 29, -3
```

which is strictly negative at every odd `n ≥ 7` and strictly positive at every even `n ≥ 8`
in the computed range; the entry `Δ³a(7) = -1` is the counterexample formalized as
`stackSC_not_three_convex`, and the parity pattern is Direction 3 of `FUTURE_DIRECTIONS.md`.

*(All numerical values in this file were produced by direct evaluation of the recursions;
every statement that is claimed as *proved* above is backed by a `sorry`-free Lean theorem in
`Catalog/Physics/`.)*
