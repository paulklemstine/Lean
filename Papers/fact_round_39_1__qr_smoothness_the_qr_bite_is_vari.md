# Computational Evidence — QR-smoothness: variance, not mean (exp 471 / paper 139)

The Lean file is `Catalog/Novelty/QRSmoothnessVarianceNotMean.lean`.

Notation: `r_M(N) = #{x ∈ (ℤ/M)ˣ : x² ≡ N}`, which counts the residue classes of `x` with `M | x² − N`.

## 1. Small cases (exhaustive enumeration by a short Python script; not a Lean artifact)

For a single prime, p = 7, N = 1..6: r = 2, 2, 0, 2, 0, 0 (this is `1 + (N|7)`). So ∑ r = 6 and ∑ (r−1)² = 6.

| M | k = ω(M) | φ(M) | ∑ r | ∑ (r−1)² | φ(M)(2^k−1) | values of r | #{r≠0} | φ/2^k |
|---|---|---|---|---|---|---|---|---|
| 3 | 1 | 2 | 2 | 2 | 2 | {0,2} | 1 | 1 |
| 5 | 1 | 4 | 4 | 4 | 4 | {0,2} | 2 | 2 |
| 7 | 1 | 6 | 6 | 6 | 6 | {0,2} | 3 | 3 |
| 11 | 1 | 10 | 10 | 10 | 10 | {0,2} | 5 | 5 |
| 15 | 2 | 8 | 8 | 24 | 24 | {0,4} | 2 | 2 |
| 21 | 2 | 12 | 12 | 36 | 36 | {0,4} | 3 | 3 |
| 35 | 2 | 24 | 24 | 72 | 72 | {0,4} | 6 | 6 |
| 105 | 3 | 48 | 48 | 336 | 336 | {0,8} | 6 | 6 |
| 1155 | 4 | 480 | 480 | 7200 | 7200 | {0,16} | 30 | 30 |
| 15015 | 5 | 5760 | 5760 | 178560 | 178560 | {0,32} | 180 | 180 |
| 255255 | 6 | 92160 | 92160 | 5806080 | 5806080 | {0,64} | 1440 | 1440 |

At every depth k the mean is exactly 1. The variance is exactly 2^k − 1, and the weight is all-or-nothing. All of these are now Lean theorems (`qr_mean_variance_primeProd`, `card_support_primeProd`), so the table is only a sanity check.

## 2. Experimental context (exp 471, supplied by the research thread, not re-run here)

seed 20260821, 4 cells × 100k values:
- emp_x2 / emp_rnd ≈ 1 within noise. emp_x2 / mean-ρ is 0.87–0.99.
- QR-pool-restricted randoms are 21–56× lower, which refutes H1.
- corr(per-N rate, #QR odd primes ≤ 100) = 0.50 / 0.45 / 0.48 / 0.40.
- The decile spread is 2.4× at u = 2.5 and 9.3× at u = 3.5.

## 3. OEIS

φ(M)/2^k for M = 3·5·7·…: 1, 2, 6, 30, 180, 1440 = ∏ (p−1)/2. This counts the squares in (ℤ/M)ˣ. The listed terms are the partial products of (p−1)/2 = 1, 2, 3, 5, 6, 8, … (OEIS A005097, (odd primes − 1)/2). We did not do a live OEIS lookup.

## 4. Counterexample hunt

We searched for a counterexample to "mean = 1, variance = 2^k − 1, r ∈ {0, 2^k}" for squarefree odd M up to 255255 with k ≤ 6, and found none. The statement is now proved in general. The oddness hypothesis is needed. For M = 8, #{y² = 1} = 4, not 2^1. For odd prime powers such as M = 9 the count is still 2 = 2^ω, but the Lean theorem only covers squarefree M. The group-level theorem `sum_rootCount_sub_one_sq` holds for every finite abelian group.
