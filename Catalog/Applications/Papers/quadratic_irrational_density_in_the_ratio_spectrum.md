# Computational Evidence — Quadratic Ratio Spectrum

Supports `Catalog/Computation/QuadraticRatioSpectrum.lean`.

## 1. Metallic ratios `μ_n = (n + √(n²+4))/2`

| n | μ_n (≈)  | μ_n² − n·μ_n − 1 | name        |
|---|----------|------------------|-------------|
| 1 | 1.618034 | 0                | golden      |
| 2 | 2.414214 | 0                | silver      |
| 3 | 3.302776 | 0                | bronze      |
| 4 | 4.236068 | 0                | —           |
| 5 | 5.192582 | 0                | —           |

Confirms `μ_n² = n·μ_n + 1` (verified symbolically in `metallicRatio_sq`) and
strict monotonicity / unboundedness (`metallicRatio_strictMono`,
`metallicRatio_tendsto_atTop`).

Gaps `μ_{n+1} − μ_n`: 0.796, 0.889, 0.933, 0.957, … → 1, and `μ_n − n`:
0.618, 0.414, 0.303, 0.236, 0.193, … → 0 (motivates Conjectures 1–2).

## 2. `n²+4` is never a perfect square for `n ≥ 1`

n=1..10 → 5, 8, 13, 20, 29, 40, 53, 68, 85, 104 — none is a perfect square.
Proof of the universal claim is `notSquare_sq_add_four` (the only candidate `n=1`
gives 5; for `n ≥ 2` the value lies strictly between `n²` and `(n+1)²`).

## 3. OEIS

- Metallic ratios / `x² = n·x + 1`: discriminants `n²+4` are A087475 / related to
  A005451; for `n=1` the convergents are the Fibonacci ratios (A000045).
- `n²+4`: A087475-style "n^2+4" sequence (5, 8, 13, 20, 29, …).

## 4. Density counterexample hunt

Tested `quadIrr_dense` construction `r + √2` against random targets `x` with
`ε = 10⁻⁶`: in every sample the returned `r + √2` is irrational (rational + √2)
and satisfies `d²y² − 2pd·y + (p²−2d²) = 0`. No counterexample to the density
claim was found; the universal statement is proved in `quadIrr_dense`.

## 5. Note

All numerical claims above are *also* discharged symbolically/exactly in the Lean
file, so the evidence here is illustrative rather than load-bearing.
