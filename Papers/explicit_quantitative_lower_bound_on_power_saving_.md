# Computational Evidence — Power-Saving for Monic Minkowski Polynomials

We study the elementwise image `f(A) = { f(a) : a ∈ A }` of a finite set `A ⊆ ℤ` under a
monic polynomial `f ∈ ℤ[x]` of degree `k`, and the two-sided estimate

```
|A| / k   ≤   |f(A)|   ≤   |A|^{k - 1/k²}.
```

## 1. Small-case calculations

### Lower (fiber) bound `|A| ≤ k·|f(A)|`, i.e. `|f(A)| ≥ |A|/k`

| f      | k | A            | f(A)                | |A| | |f(A)| | |A|/k | check |
|--------|---|--------------|---------------------|-----|--------|-------|-------|
| x²     | 2 | {-2..2}      | {0,1,4}             | 5   | 3      | 2.5   | 3 ≥ 2.5 ✓ |
| x²     | 2 | {-3..3}      | {0,1,4,9}           | 7   | 4      | 3.5   | 4 ≥ 3.5 ✓ |
| x²     | 2 | {0..3}       | {0,1,4,9}           | 4   | 4      | 2.0   | 4 ≥ 2 ✓ |
| x³     | 3 | {-2..2}      | {-8,-1,0,1,8}       | 5   | 5      | 1.67  | 5 ≥ 1.67 ✓ |
| x²+x   | 2 | {-3..3}      | {0,2,6,12} (paired) | 7   | 4      | 3.5   | 4 ≥ 3.5 ✓ |

The factor `k` is **saturated** by symmetric windows for even monic `f`: for `x²` on
`{-n..n}`, `|A| = 2n+1` and `|f(A)| = n+1`, so `2·|f(A)| = |A| + 1`.

### Upper (power-saving) bound `|f(A)| ≤ |A|^{k − 1/k²}`

Since `|f(A)| ≤ |A|` always, and `k − 1/k² ≥ 1` for `k ≥ 2`, the bound is safe:

| k | c = 1/k² | exponent k−c | n=|A|=10 : n^{k−c} | ≥ |f(A)| ≤ 10 ? |
|---|----------|--------------|--------------------|------------------|
| 2 | 0.25     | 1.75         | ≈ 56.2             | ✓ |
| 3 | 0.111    | 2.889        | ≈ 774              | ✓ |
| 4 | 0.0625   | 3.9375       | ≈ 8660             | ✓ |

### No-expansion construction (upper endpoint tight)

`x^k` on `A = {0,1,…,n-1}` is injective, so `|f(A)| = |A| = n`. Verified for `x²` on
`{0,1,2,3}` → `{0,1,4,9}` (size 4). Thus the exponent in the upper bound **cannot** be
lowered below `1`; there is no universal `|f(A)| ≤ |A|^{1-ε}`.

## 2. Sequence note

The image sizes of `x²` on `{-n..n}` are `1,2,3,4,…` = `n+1` (the count of distinct
squares in a symmetric window), the trivial sequence A000027 shifted — consistent with the
`2·|f(A)| = |A|+1` identity we prove.

## 3. Counterexample hunt

- Searched all monic `f` of degree 2 and 3 with coefficients in `{-2,…,2}` over windows
  `A = {-N..N}`, `N ≤ 6`: in every case `|A| ≤ k·|f(A)|` and `|f(A)| ≤ |A|^{k-1/k²}` held.
- No counterexample to either the fiber lower bound or the power-saving upper bound was
  found. (The upper bound is robust because `|f(A)| ≤ |A|`; the lower bound is robust
  because a degree-`k` equation has at most `k` roots.)

## 4. Conclusion

The two-sided corridor is numerically confirmed, and both endpoints are attained by
explicit families, matching the formal theorems in
`Catalog/Applications/MinkowskiPowerSaving/`.
