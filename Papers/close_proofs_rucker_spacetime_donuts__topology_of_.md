# Computational Evidence — The Donut Universe

Concise numerical support for the claims formalized in
`Catalog/Physics/DonutUniverseGeodesics.lean`.

## 1. Closed timelike geodesics: Minkowski norms of integer directions

Working on the flat Lorentzian torus `𝕋^{1+d}` with quadratic form
`Q(v) = -v₀² + Σ vᵢ²` (coordinate `0` = time), an integer direction `v ∈ ℤ^{1+d}`
gives a closed geodesic of period one, and it is *timelike* exactly when `Q(v) < 0`.

| direction `v` (on `𝕋^{1+2}`) | `Q(v)`  | causal type | closed loop? |
|-------------------------------|---------|-------------|--------------|
| `(1,0,0)` (= e₀, pure time)   | `-1`    | timelike    | yes          |
| `(0,1,0)`                     | `+1`    | spacelike   | yes          |
| `(1,1,0)`                     | `0`     | null        | yes          |
| `(2,1,1)`                     | `-2`    | timelike    | yes          |
| `(1,1,1)`                     | `+1`    | spacelike   | yes          |

The pure-time direction `e₀` always satisfies `Q(e₀) = -1 < 0`, giving a closed
timelike geodesic in every dimension — this is the witness used in the existence
theorem.

## 2. Cassini's identity and the Fibonacci winding lattice

The signed Cassini identity `Fₙ·Fₙ₊₂ − Fₙ₊₁² = (−1)^{n+1}` is the determinant of
the winding matrix `[[Fₙ, Fₙ₊₁], [Fₙ₊₁, Fₙ₊₂]]`.

| `n` | `Fₙ` | `Fₙ₊₁` | `Fₙ₊₂` | `Fₙ·Fₙ₊₂ − Fₙ₊₁²` | `(−1)^{n+1}` |
|-----|------|--------|--------|--------------------|--------------|
| 0   | 0    | 1      | 1      | `0·1 − 1 = -1`     | `-1`         |
| 1   | 1    | 1      | 2      | `1·2 − 1 = +1`     | `+1`         |
| 2   | 1    | 2      | 3      | `1·3 − 4 = -1`     | `-1`         |
| 3   | 2    | 3      | 5      | `2·5 − 9 = +1`     | `+1`         |
| 4   | 3    | 5      | 8      | `3·8 − 25 = -1`    | `-1`         |
| 5   | 5    | 8      | 13     | `5·13 − 64 = +1`   | `+1`         |

The determinant is always `±1`, so consecutive Fibonacci winding vectors form a
`ℤ`-basis of the two-torus fundamental group `ℤ²` at every stage of the
recursion. OEIS: the Fibonacci numbers are A000045.

## 3. Fundamental group / winding lattice

For the `n`-torus, a point of the universal cover projects to the base point iff
all coordinates are integers, so the covering-translation group is exactly `ℤⁿ`.
Small checks: on `𝕋²`, `(0.5, 0)` is *not* in the kernel; `(1, -3)` *is*.
