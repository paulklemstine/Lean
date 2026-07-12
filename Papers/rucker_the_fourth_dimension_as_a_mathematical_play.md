# Computational Evidence: The Fourth Dimension

Concise numerical checks performed before formalising the identities.

## 1. Volume of the 4-ball

The dimension-`n` ball volume is `V_n(r) = π^{n/2} / Γ(n/2 + 1) · r^n`.
For `n = 4`: `Γ(3) = 2! = 2`, so `V_4(r) = π² / 2 · r⁴`.

| n | V_n(1)          |
|---|-----------------|
| 2 | π ≈ 3.14159     |
| 3 | 4π/3 ≈ 4.18879  |
| 4 | π²/2 ≈ 4.93480  |
| 5 | 8π²/15 ≈ 5.2638 |

The peak of `V_n(1)` near `n = 5` and the exact `π²/2` at `n = 4` match the
formula; confirms the target constant.

## 2. Fixed-point-free rotation `rot4`

`J(x₀,x₁,x₂,x₃) = (-x₁, x₀, -x₃, x₂)`.
* `J·J = (-x₀,-x₁,-x₂,-x₃) = -x`  ⟹ eigenvalues `±i`, no eigenvalue `1`.
* Sample `x = (1,0,0,0)`: `Jx = (0,1,0,0) ≠ x`, `‖Jx‖ = 1 = ‖x‖`. ✓
* Sample `x = (1,1,1,1)/2` (on `S³`): `Jx = (-1,1,-1,1)/2 ≠ x`, norm preserved. ✓
No unit vector satisfies `Jx = x` because that forces `x = 0`.

## 3. Hopf identity

`4|z|²|w|² + (|z|²-|w|²)² = (|z|²+|w|²)²` — checked as a polynomial identity in
`a = |z|², b = |w|²`: `4ab + (a-b)² = a² + 2ab + b² = (a+b)²`. ✓
Numeric sample `z = 1, w = i`: `|z|²=1, |w|²=1`, LHS `= 4·1 + 0 = 4 = (2)²`. ✓

## 4. Clifford torus

`clifford(a,b) = (cos a, sin a, cos b, sin b)/√2`.
`Q = (cos²a + sin²a)/2 + (cos²b + sin²b)/2 = 1/2 + 1/2 = 1`. ✓
Each coordinate pair contributes exactly `1/2`.

## 5. Tesseract / cube face counts `C(n,k)·2^{n-k}` (OEIS A013609 rows)

| n\k | 0  | 1  | 2  | 3 | 4 | Σ(-1)ᵏ (proper) |
|-----|----|----|----|---|---|-----------------|
| 3   | 8  | 12 | 6  | 1 |   | 8-12+6 = 2      |
| 4   | 16 | 32 | 24 | 8 | 1 | 16-32+24-8 = 0  |

Full alternating sums `∑_{k=0}^{n} (-1)ᵏ C(n,k) 2^{n-k} = (2-1)ⁿ = 1` for all n.
Boundary (proper-face) sums give `χ(S^{n-1}) = 1 - (-1)ⁿ`: `2` for `S²`, `0` for
`S³`. Matches the classical Euler characteristics. No counterexample found in a
scan of `n = 1..10`.
