# Computational Evidence — Generalized Gawron–Miska–Ulas unboundedness

We study `T_{b,m}(n)` = coefficient of `x^n` in `∏_{i=0}^{∞} (1 - x^{b^i})^m`,
equivalently in the finite polynomial `∏_{i=0}^{n} (1 - x^{b^i})^m`.

## 1. Small-case calculations (max |T| over n ≤ 300)

| b | m | max\|T\| in range | attained at n |
|---|---|---|---|
| 2 | 2 | 256 | 255 = 11111111₂ |
| 2 | 3 | 4096 | 255 |
| 3 | 2 | 32 | 121 = 11111₃ |
| 4 | 2 | 16 | 85 = 1111₄ |
| 5 | 2 | 16 | 156 = 1111₅ |
| 2 | 4 | 186544 | 286 |

The in-range maxima for `m = 2` occur exactly at the **base-`b` repunits**
`R_k = (b^k − 1)/(b − 1) = 1 + b + … + b^{k-1}` (the number written `11…1` with
`k` ones in base `b`).

## 2. The decisive pattern (m = 2, every base b ≥ 2)

Computing `T_{b,2}(R_k)` for `b = 2,…,7` and `k = 1,…,6`:

```
b=2: R_k = 1,3,7,15,31,63      T = -2, 4, -8, 16, -32, 64
b=3: R_k = 1,4,13,40,121,364   T = -2, 4, -8, 16, -32, 64
b=4: R_k = 1,5,21,85,341,1365  T = -2, 4, -8, 16, -32, 64
b=5: R_k = 1,6,31,156,781,3906 T = -2, 4, -8, 16, -32, 64
b=6: R_k = 1,7,43,259,1555,... T = -2, 4, -8, 16, -32, 64
b=7: R_k = 1,8,57,400,2801,... T = -2, 4, -8, 16, -32, 64
```

**Conjecture (proved in `GawronMiskaUlasBase.lean`):**
for every base `b ≥ 2`,
`T_{b,2}(R_k) = (−2)^k`, hence `|T_{b,2}(R_k)| = 2^k → ∞`.

This proves the Gawron–Miska–Ulas unboundedness conjecture **for `m = 2` and
all bases `b ≥ 2`** — a slice complementary to the paper's `b = 2` (all `m`) result.

## 3. Why the pattern holds (mechanism)

The finite products satisfy a Mahler-type functional equation
`Q_{N+1}(x) = (1 − x)^m · Q_N(x^b)` where `Q_N = ∏_{i=0}^{N}(1−x^{b^i})^m`.
For `m = 2`, `(1 − x)^2 = 1 − 2x + x^2`, and at `n = R_{k+1} = b·R_k + 1`:

- `R_{k+1} ≡ 1 (mod b)`, so the `1`-term of `(1−x)^2` (degree `R_{k+1}`) needs `b ∣ R_{k+1}`: false → 0.
- the `−2x`-term picks coefficient at `R_{k+1} − 1 = b·R_k`, divisible by `b`,
  contributing `−2 · T_{b,2}(R_k)`.
- the `x^2`-term picks coefficient at `R_{k+1} − 2 = b·R_k − 1 ≡ −1 (mod b)`: false → 0.

Hence `T_{b,2}(R_{k+1}) = −2 · T_{b,2}(R_k)`, and `T_{b,2}(R_0) = T_{b,2}(0) = 1`.

## 4. Counterexample hunt

No counterexample to `T_{b,2}(R_k) = (−2)^k` was found for `2 ≤ b ≤ 7`,
`0 ≤ k ≤ 6`. The `m = 1` case is *bounded* (`|T_{b,1}(n)| ≤ 1`, base-`b`
restricted-digit representation is unique), confirming `m ≥ 2` is necessary.
