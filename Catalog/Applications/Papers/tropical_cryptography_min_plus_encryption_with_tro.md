# Computational Evidence — Tropical Magnitude Leak & Global-Min Superadditivity

This note records the small-case computations that motivated the formal results in
`Tropical/TropicalMagnitudeLeak.lean` and `Tropical/TropicalGminSuperadditive.lean`.
All computations were done over ℚ with an explicit `min`-`plus` model of the tropical
matrix product (so they are exact, not floating point).

## Model

```
mm A B   i j = min (A i 0 + B 0 j) (A i 1 + B 1 j)        -- min-plus product (2×2)
mpow A k     = A ⊗ A ⊗ ... ⊗ A  ((k+1) factors)           -- matches `tropMatPow A k`
```

## 1. Entrywise linear sandwich

Test matrix `A = [[1,3],[3,1]]`, so global min `amin = 1`, global max `amax = 3`.

| k | A^{⊗(k+1)} entries (00,01,10,11) |
|---|----------------------------------|
| 0 | (1, 3, 3, 1) |
| 1 | (2, 4, 4, 2) |
| 2 | (3, 5, 5, 3) |
| 3 | (4, 6, 6, 4) |
| 4 | (5, 7, 7, 5) |
| 5 | (6, 8, 8, 6) |

For every `k ≤ 7` and every entry `e` of `A^{⊗(k+1)}` the check
`(k+1)*amin ≤ e ≤ (k+1)*amax`, i.e. `(k+1) ≤ e ≤ 3(k+1)`, returns `true`.
This is the universal sandwich proved formally as `tropMatPow_entry_lower` /
`tropMatPow_entry_upper`.

**Cryptanalytic reading.** From any entry `e = B i j` of the public key
`B = A^{⊗(k+1)}` the adversary reads off `e/amax ≤ k+1 ≤ e/amin` — a computable
interval for the secret exponent *with no eigenvector and no `λ ≠ 0` assumption*.
For the diagonal entries above the interval is `[e/3, e]`; its integer points pin `k`
to a short list, and when `amin = amax` (a constant matrix) the interval collapses to a
point (`tdlp_constant_exact`).

## 2. Magnitude no-leak boundary

Zero matrix `Z = [[0,0],[0,0]]`:

| k | Z^{⊗(k+1)} (00, 11) |
|---|---------------------|
| 0..5 | (0,0) for all k |

Every power is the zero matrix, so the magnitude channel carries **no** information
about `k` (`magnitude_no_leak`). This is the magnitude-channel analogue of the
`λ = 0` eigenvalue boundary in `EigenzeroNoLeak.lean`.

## 3. Global-min superadditivity

Define `g(m) = min_{i,j} (A^{⊗(m+1)})_{i,j}`. For `A = [[1,3],[3,1]]` the table above
gives `g(0)=1, g(1)=2, g(2)=3, ...`, i.e. `g(m) = m+1`, which satisfies the
superadditive law `g(a+b+1) ≥ g(a) + g(b)` (here with equality). The general
inequality `gmin (A ⊗ B) ≥ gmin A + gmin B` was checked on several random ℚ matrices
and is proved formally as `gmin_tropMatMul_superadd` / `gmin_tropMatPow_superadd`.

## OEIS

The diagonal sequence `1,2,3,4,5,6,...` (A000027) and off-diagonal `3,4,5,6,...`
(A000027 shifted) are linear, consistent with the predicted slope = the minimum cycle
mean (here the diagonal self-loop weight `1`). No exotic sequence appears; the point is
precisely the *linearity*, which is what makes the exponent leak.
