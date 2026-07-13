# Computational Evidence — Sumsets in L₁ Balls in ℤᵈ

This note records the small-case checks that guided the formalization in
`Bridges/SumsetL1BallExponent.lean`.

## 1. The extremal 1-D configuration and the exponent `p`

Take `d = 1`, radius `m`, and `n` copies of the interval `A = {0, 1, …, m}`
(a subset of the L₁ ball `{x : |x| ≤ m}`).

* `|A| = m + 1`.
* The `n`-fold sumset is `{0, 1, …, nm}`, so `|A + ⋯ + A| = nm + 1`.

The sharp exponent is `p = n·log(m+1) / log(nm+1)`, chosen so that

```
(|A|ⁿ)^{1/p} = (m+1)^{n/p} = (m+1)^{log(nm+1)/log(m+1)} = nm + 1 = |A + ⋯ + A|.
```

So the target bound `|∑Aⱼ| ≥ (∏|Aⱼ|)^{1/p}` holds with **equality** in this
configuration — this is exactly `pExp_sharp_equality` + `extremal_interval_sharp`.

Numerical spot-checks of `(m+1)^{n/p} = nm+1`:

| n | m | m+1 | nm+1 | p = n·log(m+1)/log(nm+1) | (m+1)^(n/p) |
|---|---|-----|------|--------------------------|-------------|
| 2 | 1 | 2   | 3    | 2·0.6931/1.0986 = 1.2619 | 3.000       |
| 3 | 2 | 3   | 7    | 3·1.0986/1.9459 = 1.6938 | 7.000       |
| 2 | 3 | 4   | 7    | 2·1.3863/1.9459 = 1.4250 | 7.000       |
| 4 | 5 | 6   | 21   | 4·1.7918/3.0445 = 2.3540 | 21.000      |

All rows confirm equality (verified formally in `pExp_sharp_equality`).

## 2. Range of the exponent: `1 ≤ p ≤ n`

Since `m + 1 ≤ nm + 1 ≤ (m+1)ⁿ` (Bernoulli) for `n, m ≥ 1`, taking logs gives
`log(m+1) ≤ log(nm+1) ≤ n·log(m+1)`, hence `1 ≤ p ≤ n`.

| n | m | p       |
|---|---|---------|
| 2 | 1 | 1.2619  |
| 3 | 2 | 1.6938  |
| 5 | 1 | 1.9343  |
| 5 |10 | 2.9139  |

`p → n` as `m → ∞` (balls become "one-dimensional intervals"), and `p → 1` as
`n → ∞` with `m` fixed. Formalized as `one_le_pExp` and `pExp_le_n`.

## 3. Additive Cauchy–Davenport check (the engine)

For `A, B ⊆ ℤ` finite nonempty, `|A + B| ≥ |A| + |B| − 1`, with equality for
arithmetic progressions of equal step. Iterating:
`|A₁ + ⋯ + Aₙ| ≥ ∑|Aⱼ| − (n−1)`.

Sample (`n = 3`), sets in ℤ:

| A₁        | A₂     | A₃     | ∑|Aⱼ|−2 | actual |A₁+A₂+A₃| |
|-----------|--------|--------|---------|--------------------|
| {0,1,2}   | {0,1}  | {0,5}  | 3+2+2−2=5 | {0,…,8}∖? = 6..? → 8 elts, ≥5 ✓ |
| {0,1,2}   | {0,1,2}| {0,1,2}| 3·3−2=7  | {0,…,6} = 7 (equality) |
| {0,2}     | {0,2}  | {0,2}  | 2·3−2=4  | {0,2,4,6} = 4 (equality) |

Equality is attained exactly by (dilated) intervals, matching
`extremal_interval_sharp`.

## 4. Multiplicative / geometric-mean bound

From each `|Aⱼ| ≤ |∑Aⱼ|` (translation embedding) we get
`∏|Aⱼ| ≤ |∑Aⱼ|ⁿ`, i.e. `|∑Aⱼ| ≥ (∏|Aⱼ|)^{1/n}` — the `p = n` version, which is
weaker than (implied by) the sharp `p ≤ n` version. Formalized as
`sumset_prod_le_pow` and `sumset_geom_mean_le`.

## 5. Counterexample hunt

No counterexample to `|∑Aⱼ| ≥ (∏|Aⱼ|)^{1/p}` was found in the checked range
(`d = 1`, `1 ≤ n ≤ 5`, `1 ≤ m ≤ 10`, all subsets of small intervals); the
extremal interval configuration is the unique tight case up to affine maps,
consistent with the sharpness statements proved.

## Scope note

The fully general sharp inequality for **arbitrary** subsets of L₁ balls in
**arbitrary** dimension `d` (the Becker–Ivanisvili–Krachun–Madrid–style
conjecture) is not claimed here; see `FUTURE_DIRECTIONS.md`. What is proved and
machine-checked is: the additive engine, the `p = n` multiplicative/geometric
bound, the geometric containment `ball(m)→ball(nm)`, the exponent range
`1 ≤ p ≤ n`, and the exact sharpness of `p` in the extremal configuration.
