# Computational Evidence — Siegel–Weil for the E₈ theta series

All claims below are additionally verified symbolically in
`SiegelWeilE8ThetaMoebius.lean`.

## 1. Small-case representation numbers `r(n) = 240·σ₃(n)`

| n | σ₃(n) = Σ_{d|n} d³ | r(n) = 240·σ₃(n) |
|---|--------------------|------------------|
| 1 | 1                  | 240              |
| 2 | 1 + 8 = 9          | 2160             |
| 3 | 1 + 27 = 28        | 6720             |
| 4 | 1 + 8 + 64 = 73    | 17520            |
| 5 | 1 + 125 = 126      | 30240            |

These reproduce the known E₈ vector counts (240 roots, then 2160, 6720, 17520,
30240 vectors of squared length 4, 6, 8, 10).

## 2. Eigenform defect at prime squares: `σ₃(p²) = σ₃(p)² − p³`

| p | σ₃(p) | σ₃(p)² | σ₃(p²)        | defect = p³ |
|---|-------|--------|---------------|-------------|
| 2 | 9     | 81     | 1+8+64 = 73   | 8           |
| 3 | 28    | 784    | 1+27+729 = 757| 27          |
| 5 | 126   | 15876  | 1+125+15625 = 15751 | 125   |

The defect is always positive, confirming `σ₃(p²) < σ₃(p)²`: the coefficient
system is multiplicative but never completely multiplicative.

## 3. Möbius inversion recovers cubes: `Σ_{d·e=n} μ(d)·σ₃(e) = n³`

| n | divisor pairs (d,e) with μ(d)≠0 | signed sum | n³ |
|---|---------------------------------|-----------|----|
| 2 | (1,2):+9, (2,1):−1              | 8         | 8  |
| 3 | (1,3):+28, (3,1):−1            | 27        | 27 |
| 4 | (1,4):+73, (2,2):−9, (4,1):0  | 64        | 64 |
| 6 | (1,6):+σ₃(6)=252, (2,3):−28, (3,2):−9, (6,1):+1 | 216 | 216 |

Each row returns exactly `n³`, as predicted by dividing the Eisenstein
L-function by ζ.

## 4. Closed Euler-factor form: `σ₃(pʳ)·(p³−1) = p^{3(r+1)}−1`

For p = 2: σ₃(2²)·7 = 73·7 = 511 = 2⁹ − 1 = 512 − 1. ✓
For p = 3, r = 1: σ₃(3)·26 = 28·26 = 728 = 3⁶ − 1 = 729 − 1. ✓

## 5. OEIS

The sequence `240·σ₃(n)` (240, 2160, 6720, 17520, 30240, ...) is the theta series
of the E₈ lattice, OEIS A004009 (with the constant term 1 for n = 0). The divisor
cube sum σ₃(n) is OEIS A001158.

## Counterexample hunt

No counterexample to `r(n) = 240·σ₃(n)`, to the eigenform defect inequality, or to
the Möbius-inversion identity was found in the tested range `1 ≤ n ≤ 200`.
