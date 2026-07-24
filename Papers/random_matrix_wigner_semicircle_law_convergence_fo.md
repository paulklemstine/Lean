# Computational Evidence: Wigner Semicircle Moments

## 1. Small-case calculations

### Catalan numbers = even moments of the standard (radius-2) semicircle law

The moments `m_{2k}` of the standard Wigner semicircle distribution (support
`[-2, 2]`) are the Catalan numbers `C_k`; all odd moments vanish.

| k | C_k = m_{2k} |
|---|--------------|
| 0 | 1            |
| 1 | 1            |
| 2 | 2            |
| 3 | 5            |
| 4 | 14           |
| 5 | 42           |
| 6 | 132          |

These match the direct integral computation
`m_{2k} = (1/2π) ∫_{-2}^{2} x^{2k} √(4 - x²) dx`:

- `m_0 = 1`, `m_2 = 1`, `m_4 = 2`, `m_6 = 5`, ... (Catalan).

### Catalan recurrence (Wigner moment recurrence)

`C_{n+1} = Σ_{i=0}^{n} C_i C_{n-i}`:

- `C_1 = C_0 C_0 = 1`
- `C_2 = C_0 C_1 + C_1 C_0 = 2`
- `C_3 = C_0 C_2 + C_1 C_1 + C_2 C_0 = 2 + 1 + 2 = 5`
- `C_4 = 5 + 2 + 2 + 5 = 14`

This is exactly the recurrence obtained from counting non-crossing pair
partitions / Dyck paths in the moment-method proof of Wigner's law.

### Radius-1 rescaling

Under `x ↦ x/2` the `n`-th moment scales by `2⁻ⁿ`, so the even moments of the
radius-1 semicircle law are `C_k / 4^k`:

| k | C_k / 4^k |
|---|-----------|
| 0 | 1         |
| 1 | 1/4       |
| 2 | 2/16 = 1/8|

These agree with the direct integrals of the radius-1 density
`f(x) = (2/π)√(1-x²)`:

- `∫_{-1}^{1} f = 1`               (verified in `Density.lean`)
- `∫_{-1}^{1} x·f = 0`             (odd, verified)
- `∫_{-1}^{1} x²·f = 1/4`          (verified via `∫ x²√(1-x²) = π/8`)

## 2. OEIS

The moment sequence `1, 1, 2, 5, 14, 42, 132, ...` is the Catalan numbers,
**OEIS A000108**.

## 3. Counterexample hunt

- Growth bound `C_k ≤ 4^k`: `1 ≤ 1`, `1 ≤ 4`, `2 ≤ 16`, `5 ≤ 64`, `14 ≤ 256`,
  `42 ≤ 1024`. No counterexample (proved in general as `scMoment_le_four_pow`).
  This exponential bound is what makes the semicircle moment problem determinate
  (Carleman's condition), guaranteeing uniqueness of the weak limit.
- Odd moments vanish: checked for all odd `n` (proved as `scMoment_odd`).

## 4. Summary

All finite checks are consistent with, and are subsumed by, the general theorems
proved in `Moments.lean`, `Density.lean`, and `Bridge.lean`.
