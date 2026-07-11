# Computational Evidence: the dimension ladder toward `⊤`

The central object is a nested tower of isometric Euclidean stages inside the
sequence Hilbert space `ℓ²`. The relevant quantities are exact and finite at
each stage, and the limit is `⊤`.

## Small-case dimensions

For the standard `n`-dimensional Euclidean space `ℝⁿ`, the Hausdorff dimension
of the whole space equals `n` exactly (a special case of the general fact that a
finite-dimensional normed real vector space has Hausdorff dimension equal to its
linear dimension).

| stage `n` | `dimH (univ : ℝⁿ)` | isometric image in `ℓ²`? |
|-----------|--------------------|--------------------------|
| 0         | 0                  | yes (the origin)         |
| 1         | 1                  | yes (first axis)         |
| 2         | 2                  | yes (first two axes)     |
| 3         | 3                  | yes (first three axes)   |
| ...       | ...                | ...                      |
| `n`       | `n`                | yes (first `n` axes)     |

Because each stage embeds isometrically into `ℓ²` via the map placing a vector
into its first `n` coordinates, the dimension of the ambient `ℓ²` dominates
every entry of the left column. The supremum of the sequence `0, 1, 2, 3, …`
in the extended nonnegative reals is `⊤`, which is exactly the value proved for
`dimH (univ : ℓ²)`.

## Counterexample hunt

The universal claim under test is: *a set of infinite Hausdorff dimension has no
antilipschitz map into a finite-dimensional space.* We searched for a
counterexample of the form "a distance-expanding map from `ℓ²` into `ℝᵐ`". None
can exist for any finite `m`: such a map would force `⊤ ≤ m`, which fails for
every natural number `m`. The same reasoning rules out any bi-Lipschitz or
isometric embedding, since these are antilipschitz.

## Why a heavier computation is unnecessary

The phenomena here are exact and qualitative rather than approximate: the
dimension of each finite stage is an integer, the obstruction is a strict
inequality `⊤ ≤ m` that is impossible for finite `m`, and the limit value `⊤`
is forced by the unbounded integer ladder. There is no floating-point regime,
random sampling, or asymptotic constant to estimate, so the evidence is fully
captured by the exact table above and is discharged in full generality by the
accompanying proofs.
