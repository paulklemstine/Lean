# Computational Evidence — Negative-Dimensional Topology

We model virtual graded spaces as `VS = ℤ[T; T⁻¹]`, with the Euler
characteristic the ring homomorphism `χ : T ↦ -1`, so `χ(Tⁿ) = (-1)ⁿ` and
`χ(∑ aₙ Tⁿ) = ∑ aₙ (-1)ⁿ`.

## Small-case calculations

| space `X`            | `χ(X)`        | notes                              |
|----------------------|---------------|------------------------------------|
| `1 = T⁰` (point)     | `1`           | `χ(point) = 1`                     |
| `T¹`                 | `-1`          | suspension of a point              |
| `T⁻¹` (dim `-1`)     | `-1`          | title case, `k = 1`                |
| `k·T⁻¹`              | `-k`          | `chi_dim_neg_one`                  |
| `T⁻²` (dim `-2`)     | `+1`          | even codimension ⇒ positive        |
| `k·T⁻ⁿ`              | `(-1)ⁿ·k`     | `chi_pure_neg`                     |
| `T⁰ + T²`            | `2`           | additivity                         |
| `T¹ · T¹ = T²`       | `1`           | multiplicativity (Künneth)         |

## Duality check (`D : Tᵈ ↦ T⁻ᵈ`)

| `X`   | `DX`  | `χ(X)` | `χ(DX)` |
|-------|-------|--------|---------|
| `T²`  | `T⁻²` | `1`    | `1`     |
| `T¹`  | `T⁻¹` | `-1`   | `-1`    |
| `T³`  | `T⁻³` | `-1`   | `-1`    |

In every case `χ(DX) = χ(X)`: since `(-1)⁻ᵈ = (-1)ᵈ`, Spanier–Whitehead duality
preserves the Euler characteristic (`chi_dual`).

## Non-injectivity / refinement

`χ` only sees parity of the dimension:

* `χ(T⁰) = 1 = χ(T²)` but `T⁰ ≠ T²`  ⇒  `χ` is not injective.
* The top-degree invariant separates them: `topDim(T⁰) = 0 ≠ 2 = topDim(T²)`.

This is exactly `disproof_chi_not_injective` and `refined_separates_collision`.

## Counterexample hunt

* *"Every negative-dimensional space has negative `χ`."* **False.** `T⁻²` has
  `χ = 1 > 0` (`disproof_all_neg_chi`); all even codimensions give positive `χ`.
* *"`χ` determines the space."* **False**, as above.

## Sequence note

Along pure suspensions `Tⁿ`, `χ(Tⁿ) = (-1)ⁿ = 1, -1, 1, -1, …`, the alternating
sign sequence (OEIS A033999, `a(n) = (-1)ⁿ`). No further sequence search was
needed: all quantities here are closed-form `(-1)ⁿ·k`.

All statements above are proved in `Core.lean`; the evidence table matches the
formal theorems exactly.
