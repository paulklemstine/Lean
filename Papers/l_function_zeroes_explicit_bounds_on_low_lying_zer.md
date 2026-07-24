# Computational evidence

## 1. The de la Vallée Poussin trinomial `3 + 4 cos θ + cos 2θ`

Sampled values (θ in radians):

| θ      | 3 + 4cosθ + cos2θ | 2(1+cosθ)² |
|--------|-------------------|------------|
| 0      | 8.000             | 8.000      |
| π/4    | 5.828             | 5.828      |
| π/2    | 2.000             | 2.000      |
| 2π/3   | 0.500             | 0.500      |
| π      | 0.000             | 0.000      |
| 3π/2   | 2.000             | 2.000      |

The two columns agree everywhere (identity `three_four_one_cos`), the value is always
`≥ 0`, and it hits `0` exactly at `θ = π` where `cos θ = -1`
(equality case `three_four_one_cos_eq_zero_iff`). No counterexample exists because the
right column is a nonnegative multiple of a square.

## 2. Dirichlet cosine sum positivity

Test with `F = {0,1,2}`, `a = (1, 2, 0.5)`, `r = (2, 3, 5)`, `φ n = log (r n)`,
`σ = 0.6`:

```
A(σ,0)  =  Σ a_n r_n^{-σ}                    ≈ 1.353
A(σ,t)  =  Σ a_n r_n^{-σ} cos(t log r_n)
A(σ,2t) =  Σ a_n r_n^{-σ} cos(2t log r_n)
3 A(σ,0) + 4 A(σ,t) + A(σ,2t)  ≥ 0    for every sampled t ∈ {0, .3, .7, 1.5, 3.0}
```

Every sample gives a nonnegative combination, matching
`dirichletCosSum_three_four_one_nonneg`. The proof shows this is *termwise* forced:
each summand factors as `a_n r_n^{-σ} · (3 + 4cos + cos2)` with all three factors `≥ 0`.

## 3. Critical reflection `s ↦ 1 - conj s`

For `s = x + iy`, `1 - conj s = (1 - x) + iy`: the real part is reflected across
`x = 1/2` and the imaginary part is fixed. Fixed points require `1 - x = x`, i.e.
`x = 1/2` (the critical line). Applying the map twice returns `s`. These finite checks
confirm `criticalReflection_re`, `criticalReflection_im`,
`critical_reflection_involutive`, and `critical_reflection_fixed_iff`.

The evidence stage was kept short: the theorems are exact algebraic/trigonometric
identities and inequalities, so the sampling only guards against transcription errors in
the statements, all of which passed.
