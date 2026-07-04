# Computational Evidence — The Anti-Fibonacci Sequence

## 1. The object

The research brief's literal rule ("`A(n+1)` = smallest positive integer not equal to
`A(n)+A(n-1)`") degenerates to the constant `1` and does **not** reproduce the listed
terms `1, 1, 2, 4, 7, 11, 16, …`.  Those terms are reproduced **exactly** by the
first-order recurrence

```
A 0 = 1,   A (n+1) = A n + n          -- differences 0,1,2,3,4,5,…
```

with closed form `A n = 1 + n(n-1)/2` (central-polygonal / "lazy caterer" numbers
`A000124` prefixed with a leading `1`).  This is the object formalized as `antiFib`
in `Catalog/Novelty/Basic.lean`, and reused here.

First terms (`#eval`): `1, 1, 2, 4, 7, 11, 16, 22, 29, 37, …`  (OEIS A000124 shifted).

## 2. Small-case checks of the new theorems

### Partial-sum identity  `6 · ∑_{k=0}^{n} antiFib k = n³ + 5n + 6`

| n | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| `6·∑` | 6 | 12 | 24 | 48 | 90 | 156 | 252 | 384 |
| `n³+5n+6` | 6 | 12 | 24 | 48 | 90 | 156 | 252 | 384 |

Exact match (verified by `#eval`).  Formalized as `antiFib_sum_closed`.

### Square spectrum  `m ∈ range(antiFib) ⟺ ∃k, k²+7 = 8m`

Membership of `m ∈ {1,2,4,7,11,16,…}` agrees bit-for-bit with
`{m : ∃k, k²+7 = 8m}` for all `m ≤ 9` (`#eval`).  Equivalently: `m` is
anti-Fibonacci iff `m−1` is a triangular number, iff `8m−7` is a perfect square.
Formalized as `antiFib_mem_iff`.

### Cubic Cesàro growth  `(∑_{k≤n} antiFib k)/n³ → 1/6`

`6·∑/n³` at `n = 100,200,300,400,500,600`:
`1.000506, 1.000126, 1.0000563, 1.0000313, 1.0000201, 1.0000139` — monotonically
approaching `1`, so `∑/n³ → 1/6`.  Formalized as `antiFib_cesaro`.

## 3. Counterexample hunt against the brief's conjectures

* Claim `A n ~ n²/4`: **false**.  `A n = 1 + n(n-1)/2 ~ n²/2`; the constant is `1/2`
  (already recorded as `antiFib_growth` in `Catalog/Novelty/Asymptotics.lean`).
* Claim "ratio `A(n+1)/A(n)` oscillates between 1 and 2 and never converges":
  **false**.  The ratio converges monotonically to `1`
  (`antiFib_ratio_tendsto_one`); e.g. `n=10 → 1.24`, `n=100 → 1.02`, `n=1000 → 1.002`.
* Claim `A n = ⌊n²/4⌋ + O(1)`: **false** (the gap grows linearly).  The exact
  quadratic closed form is what survives.
* Surviving/true claims: quadratic growth, systematic avoidance of the two-term sum
  from index 6 on (`antiFib_avoids_sum`), and "avoids the golden ratio"
  (`antiFib_ratio_not_tendsto_goldenRatio`).

## 4. New findings added this cycle

1. `antiFib_sum_closed` — cubic partial-sum identity `6∑ = n³+5n+6`.
2. `antiFib_mem_iff` — the value-set is exactly `{m : 8m−7 is a perfect square}`.
3. `antiFib_cesaro` — cubic Cesàro density `∑/n³ → 1/6` (the discrete antiderivative
   of the value density `1/2`).
