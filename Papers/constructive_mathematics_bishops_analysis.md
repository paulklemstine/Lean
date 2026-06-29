# Computational Evidence — Bishop Constructive Analysis

This note records the small computations that motivated the formal development in
`BishopReals.lean`, `BishopIVT.lean`, and `BishopComparison.lean`.

## 1. Bisection produces an explicit modulus (constructive IVT)

We take `f x = x² - 2` on `[1,2]` (so `f 1 = -1 ≤ 0 ≤ 2 = f 2`) and run the
classical bisection. The intervals `[aₙ, bₙ]` and their widths `bₙ - aₙ`:

```
n :  (aₙ,           bₙ,          bₙ-aₙ)
0 :  (1,            2,           1)
1 :  (1,            3/2,         1/2)
2 :  (5/4,          3/2,         1/4)
3 :  (11/8,         3/2,         1/8)
4 :  (11/8,         23/16,       1/16)
5 :  (45/32,        23/16,       1/32)
6 :  (45/32,        91/64,       1/64)
7 :  (181/128,      91/64,       1/128)
```

The width is exactly `2⁻ⁿ`, an **explicit** rate. The midpoints

```
3/2, 5/4, 11/8, 23/16, 45/32, 91/64, 181/128, 363/256, …
```

are rational approximants of `√2` whose error is bounded by `2⁻ⁿ`. This is the
constructive content the formalization isolates: the root is not merely asserted
to exist, it is a *constructive real* (limit of an explicit regular sequence).

## 2. Regular sequences and the `1/(n+1)` modulus

For the formal `IsRegular` predicate we use the symmetric modulus
`|x m - x n| ≤ 1/(m+1) + 1/(n+1)` (Bishop's "regular sequence"). Any sequence
with `|x n - r| ≤ 1/(n+1)` (e.g. `xₙ = round(r·(n+1))/(n+1)`) satisfies it by the
triangle inequality, and the limit error collapses to exactly `1/(n+1)` once the
`m → ∞` term `1/(m+1)` vanishes — confirmed in `regular_converges`.

## 3. Counterexample hunt (boundary of `root_approx_eval`)

The residual-control lemma `|f (xₙ)| ≤ K/(n+1)` was initially stated *without*
`0 ≤ K`. Testing the degenerate case `xₙ = r` (so `|xₙ - r| = 0`, `f xₙ = 0`)
with `K < 0` gives `0 ≤ K/(n+1) < 0`, a contradiction: the claim is **false** for
negative `K`. This counterexample forced the hypothesis `0 ≤ K` (a Lipschitz
constant is non-negative), which is now part of the theorem.

## 4. OEIS

The bisection numerators `3, 5, 11, 23, 45, 91, 181, 363` (midpoints with
denominators `2ⁿ`) follow `aₙ₊₁ = 2aₙ ± 1`; the specific sign pattern is an
artifact of the `f m ≤ 0` test and is not a named OEIS sequence of independent
interest, so no OEIS identifier is claimed.
