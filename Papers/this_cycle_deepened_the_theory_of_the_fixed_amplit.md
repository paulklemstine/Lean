# Computational Evidence

Small, directly relevant numerical checks supporting the formalized results in
`Computation/FixedAmplitudeSpectrum.lean`.

## 1. Line-locking (spectrum lies on `ℝ·z`)

For `A = z • B` with `B` Hermitian, every eigenvalue is `z` times a real number.
Concrete check with `z = i` (rotation by 90°) and the path graph `P₃` indicator

```
B = [[0,1,0],[1,0,1],[0,1,0]]   (Hermitian, real symmetric)
```

Eigenvalues of `B`: `{ -√2, 0, √2 }` (all real). Eigenvalues of `A = i·B`:
`{ -√2·i, 0, √2·i }` — all on the imaginary axis `ℝ·i`, confirming line-locking.
Rotating `z` by any phase rotates the whole spectrum rigidly; it never fills a 2D region.
This matches `line_locking` / `spectrum_on_line`.

## 2. Complete-graph mean-direction eigenvalue and outlier

`Kₙ` indicator matrix has constant row sum `n − 1` (checked):

| n | row sum `n−1` |
|---|---------------|
| 3 | 2 |
| 4 | 3 |
| 5 | 4 |

So `(n−1)·z` is an eigenvalue of `z • Kₙ` (all-ones eigenvector). This is `complete_eigenvalue`.

Outlier escapes the naive radius `√n·‖z‖` iff `(n−1) > √n`, i.e. `(n−1)² − n > 0`:

| n | `(n−1)² − n` | escapes? |
|---|--------------|----------|
| 1 | −1 | no |
| 2 | −1 | no |
| 3 |  1 | yes |
| 4 |  5 | yes |
| 5 | 11 | yes |
| 6 | 19 | yes |
| 7 | 29 | yes |

The quantity is negative for `n ≤ 2` and strictly positive (and increasing) for `n ≥ 3`,
so the threshold `n ≥ 3` in `complete_outlier_escapes` is sharp. No counterexample found.

## 3. Determinant / singularity invariance

`det(z·B) = zⁿ·det(B)`. Example `n = 2`, `B = [[0,1],[1,0]]`, `det B = −1`:
`det(z·B) = z²·(−1) = −z²`, which is zero iff `z = 0`. For `z ≠ 0`, singularity of `z•B`
coincides with `det B = 0`, independent of `z` — matching `det_weighted` and
`weighted_singular_iff`. The bipartite complete graph `K_{n,n}` (odd `n` on each side of a
perfect-matching count) illustrates the combinatorial origin of `det B = 0` referenced in
Conjecture 4.

## Method note

These checks are finite spectral / determinant computations on explicit small matrices;
the general statements they support are proved in Lean, so exhaustive computational search
is unnecessary beyond confirming the threshold `n ≥ 3` and the sign pattern above.
