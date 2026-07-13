# Computational Evidence: The Fourth Dimension

Concise numerical checks performed before formalising the main results.

## 1. Volume of the unit ball across dimensions

Unit-ball volume `V_n = π^{n/2} / Γ(n/2 + 1)`:

| n | V_n (exact)      | V_n (approx) |
|---|------------------|--------------|
| 1 | 2                | 2.000        |
| 2 | π                | 3.142        |
| 3 | 4π/3             | 4.189        |
| 4 | π²/2             | 4.935        |
| 5 | 8π²/15           | 5.264        |
| 6 | π³/6             | 5.168        |

The value `V_4 = π²/2 ≈ 4.935` matches the formalised theorem
`volume_ball_fin_four` (scaling by `r⁴`). The table confirms the peak of the
sequence sits near `n = 5`, consistent with future direction #4.

## 2. Tesseract face vector

Hypercube `k`-face counts `f_k = 2^{n-k} · C(n,k)` for `n = 4`:

`f = (16, 32, 24, 8, 1)`  — vertices, edges, squares, cubes, cell.

- Solid Euler characteristic: `16 − 32 + 24 − 8 + 1 = 1`  ✓ (`cube_euler`).
- Boundary (S³) Euler characteristic: `16 − 32 + 24 − 8 = 0`  ✓
  (`tesseract_boundary_euler`), matching `χ(S³) = 0`.

Cross-check for other `n` via `1 - (-1)^n`:
`n=2` (square boundary, a circle): `1 - 1 = 0` ✓;
`n=3` (cube boundary, S²): `1 - (-1) = 2` ✓.

## 3. Hopf map lands on the sphere

For sampled unit vectors `(z, w)` with `|z|² + |w|² = 1`, the image
`(2 z w̄, |z|² − |w|²)` was checked to have squared norm `1`:

| z            | w            | ‖image‖² |
|--------------|--------------|----------|
| 1, 0         | 0            | 1        |
| 1/√2         | 1/√2         | 1        |
| 1/√2         | i/√2         | 1        |
| √0.3         | √0.7         | 1        |

All equal `1`, as forced by `4ab + (a−b)² = (a+b)²`; formalised in
`hopf_mem_sphere`. Scaling `(z,w)` by any unit `λ` left every image unchanged
(spot-checked with `λ = i`, `λ = (1+i)/√2`), matching `hopf_fiber_eq`.

## 4. Clifford torus and 4D rotations

- `clifford s t` sampled at several `(s,t)`: sum of squares `= 1` and each
  coordinate pair contributes exactly `1/2` (`clifford_on_sphere`,
  `clifford_radii`).
- `rot4 θ` sampled at random `(θ,a,b,c,d)`: sum of squares invariant to
  floating-point tolerance (`rot4_norm`); composing angles `θ, φ` reproduced the
  single rotation by `θ+φ` (`rot4_comp`).

No counterexamples were found in any sample; all universal claims were
subsequently proved without additional hypotheses.
