# Computational Evidence — Finite Height ↔ Newton Concentration

All checks are over `𝔖 = ℚ[X]`, `E = X` (the special divisor `V(X)`), with the
finite-height criterion `FiniteHeight(A) ↔ ∃ N, det A ∣ X^N` from
`FiniteHeightConverse.lean`. A polynomial divides some `X^N` iff its only irreducible
factor is `X`, i.e. it is a unit times `X^k`.

## Small-case table (rank 1, `A = [a]`, `det = a`)

| `a`        | `det A ∣ X^N` ?            | finite height? | minimal height |
|------------|---------------------------|----------------|----------------|
| `1`        | yes (`N = 0`)             | yes (étale)    | `0`            |
| `X`        | yes (`N = 1`)             | yes            | `1`            |
| `X^2`      | yes (`N = 2`)             | yes            | `2`            |
| `2X^3`     | yes (`N = 3`, unit `2`)   | yes            | `3`            |
| `X + 1`    | no (root at `-1`)         | **no**         | —              |
| `X^2 + X`  | no (`= X(X+1)`)           | **no**         | —              |

The minimal height matches `v_X(det A)` in every rank-1 case (consistent with C4 since
rank-1 modules are cyclic). Verified in Lean: `example_finiteHeight` (`[X^2]`),
`example_etale` (`[1]`), `example_not_finiteHeight` (`[X+1]`).

## Counterexample hunt for the converse direction

The converse `det A ∣ X^N ⟹ FiniteHeight` is proved unconditionally
(`newton_implies_finiteHeight`); no counterexample exists. The *forward* bound
`N = h · rank` is not always sharp: for `A = diag(X, X)` (rank 2, height `1`) the forward
construction gives `N = 2`, while `det A = X^2` already certifies via `N = 2` — equal here,
but for `A = diag(X, 1)` height is `1` yet `det A = X` gives `N = 1 < h·rank = 2`, showing
the determinant bound can beat the naive `h·rank`. This motivates C4 (sharp height).

## Sequence note

The minimal heights of `diag(X^{a_1}, …, X^{a_n})` are `max_i a_i`, while `v_X(det)` is
`∑_i a_i`. The gap `∑ a_i − max a_i` is exactly the "non-cyclicity defect" probed by C4.
No OEIS lookup is needed (the relevant quantities are `max` and `sum` of exponent vectors).
