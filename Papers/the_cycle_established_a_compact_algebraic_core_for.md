# Computational Evidence — Four-Dimensional Algebraic Core

## 1. Alternating cube face sum and boundary Euler characteristic

Full alternating face sum of the `n`-cube, `∑_{k=0}^{n} (−1)^k C(n,k) 2^{n−k}`:

| n | Σ (full) | boundary Σ (k<n) | 1 − (−1)^n |
|---|----------|------------------|------------|
| 0 | 1        | 0 (empty sum)    | 0          |
| 1 | 1        | 2                | 2          |
| 2 | 1        | 0                | 0          |
| 3 | 1        | 2                | 2          |
| 4 | 1        | 0                | 0          |
| 5 | 1        | 2                | 2          |

The full sum is identically `1` (contractible solid cube); the boundary sum
alternates `0, 2, 0, 2, …`, matching `χ(S^{n−1}) = 1 − (−1)^n`. This is confirmed
in Lean by `#eval` producing `[0, 2, 0, 2, 0, 2]` for `n = 0..5`.

The sequence `1 − (−1)^n = 0,2,0,2,…` is OEIS A000034-adjacent (`1,2,1,2,…`
shifted) / the Euler characteristics of spheres; the "all faces = 1" collapse is
the binomial theorem at `(−1)+2 = 1`.

## 2. Clifford balance

For `a + b = 1` the identity `4ab = 1 − (a−b)²` gives the product `4ab`:

| a    | b    | 4ab   | 1−(a−b)² |
|------|------|-------|----------|
| 0.5  | 0.5  | 1.000 | 1.000    |
| 0.6  | 0.4  | 0.960 | 0.960    |
| 0.7  | 0.3  | 0.840 | 0.840    |
| 0.9  | 0.1  | 0.360 | 0.360    |

Maximum `1` occurs uniquely at `a = b = 0.5` (the balanced Clifford torus,
`r₁ = r₂ = 1/√2`). No counterexample to `4ab ≤ 1` was found on the constraint.

## 3. Complex structure J on ℝ⁴

`J(x₁,x₂,x₃,x₄) = (−x₂, x₁, −x₄, x₃)`.

- `J(1,0,0,0) = (0,1,0,0)`, `J(0,1,0,0) = (−1,0,0,0)`, so `J²(1,0,0,0) = (−1,0,0,0)`.
- `J²(1,2,3,4) = (−1,−2,−3,−4) = −I`. ✓
- Norm check: `‖J(1,2,3,4)‖² = 4+1+16+9 = 30 = ‖(1,2,3,4)‖²`. ✓
- Fixed-point hunt: `Jx = x` forces `−x₂ = x₁`, `x₁ = x₂ ⟹ x₁ = x₂ = 0`, similarly
  `x₃ = x₄ = 0`. No nonzero fixed point. ✓

## 4. Hopf sphere identity

For sample `(z,w)`: `|2z\bar w|² + (|z|²−|w|²)²` versus `(|z|²+|w|²)²`.

| z    | w    | LHS | (|z|²+|w|²)² |
|------|------|-----|--------------|
| 1    | 0    | 1   | 1            |
| 1    | 1    | 4   | 4            |
| 1+i  | 1    | 9   | 9            |
| 2    | 1    | 25  | 25           |

Exact agreement in all cases — this is `(a+b)² = 4ab + (a−b)²` with `a=|z|²`,
`b=|w|²`.

## 5. Four-ball volume derivative

`V(r) = (π²/2) r⁴`, `V'(r) = 2π² r³ = Area(S³_r)`. Numerically at `r=1`:
`V = π²/2 ≈ 4.9348`, `V' = 2π² ≈ 19.739`, matching the known three-sphere surface
constant `2π²`.

All checks are encoded and verified in `FourthDimensionAlgebraicCore.lean`; no
counterexamples were found to any of the universal claims.
