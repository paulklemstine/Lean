# Computational Evidence — Sun's truncated Legendre-symbol determinant

**Claim.** For a prime `p ≥ 7` with `p ≡ 3 (mod 4)`, set `m = (p-5)/2` and
`A j k = X + (j - k | p)` (`Fin m × Fin m`, entries in `ℤ[X]`).  Then
`det A = ((p-2)/3)^2 · X` over `ℤ[X]`.

Since `J` (all-ones) has rank one, `det A = det C + (det(C+J) - det C)·X` where
`C j k = (j-k | p)`.  So the claim splits into:

1. `det C = 0`  (constant term vanishes), and
2. `det(C+J) = ((p-2)/3)^2`  (linear coefficient).

## Small-case calculations (exact integer arithmetic, fraction-free Gaussian elim)

| p   | m  | det C | det(C+J) = coeff | ((p-2)/3)² | match |
|-----|----|-------|------------------|------------|-------|
| 7   | 1  | 0     | 1                | 1          | ✓ |
| 11  | 3  | 0     | 9                | 9          | ✓ |
| 19  | 7  | 0     | 25               | 25         | ✓ |
| 23  | 9  | 0     | 49               | 49         | ✓ |
| 31  | 13 | 0     | 81               | 81         | ✓ |
| 43  | 19 | 0     | 169              | 169        | ✓ |
| 47  | 21 | 0     | 225              | 225        | ✓ |
| 59  | 27 | 0     | 361              | 361        | ✓ |
| 67  | 31 | 0     | 441              | 441        | ✓ |
| 71  | 33 | 0     | 529              | 529        | ✓ |
| 79  | 37 | 0     | 625              | 625        | ✓ |
| 83  | 39 | 0     | 729              | 729        | ✓ |
| 103 | 49 | 0     | 1089             | 1089       | ✓ |
| 107 | 51 | 0     | 1225             | 1225       | ✓ |
| 127 | 61 | 0     | 1681             | 1681       | ✓ |
| 131 | 63 | 0     | 1849             | 1849       | ✓ |
| 139 | 67 | 0     | 2025             | 2025       | ✓ |
| 151 | 73 | 0     | 2401             | 2401       | ✓ |

All 18 admissible primes `7 ≤ p ≤ 151` satisfy the identity. **No counterexample
found.**  `det C = 0` holds in every case (consistent with the antisymmetric/
odd-order argument).  Note `m = (p-5)/2 = 2t-1` (with `p = 4t+3`) is always odd.

## Sequence

The coefficient sequence is `1, 9, 25, 49, 81, 169, 225, …`, i.e. the squares of
`1, 3, 5, 7, 9, 13, 15, …` = `((p-2)/3)` (integer division).  These are perfect
squares — the conspicuous structural fact verified by the data.

## Counterexample hunt (hypothesis robustness)

* `p ≡ 1 (mod 4)`: `C` is *symmetric*, not antisymmetric, so `det C` need not
  vanish; the clean monomial form fails.  This confirms the necessity of the
  `p ≡ 3 (mod 4)` hypothesis.
* The constant term `det C` is `0` in all `p ≡ 3 (mod 4)` cases, matching the
  general proof in `Basic.lean`.

## In-Lean verification

`native_decide` confirms `det(C+J)` for `p = 7, 11, 19` directly (used in
`Sun.lean`).  The `m × m` Leibniz expansion (`m!` terms) becomes infeasible inside
Lean's evaluator around `m = 9` (`p = 23`); larger primes are covered only by the
external table above.  The polynomial/linear-algebra scaffolding
(`det C = 0`, affine structure) is proved in Lean for **all** admissible `p`.
