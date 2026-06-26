# Computational Evidence — Quadratic irrational density in the ratio spectrum

This note records the small-case checks that guided the Lean formalization in
`MobiusQuadratic.lean` and `DeterminantSpectrum.lean`.  The formalized results are
the *algebraic backbone* of the Lagarias–Shallit ratio-spectrum program (closure
of the quadratic-irrational locus under integer Möbius maps, and the structure of
the target interval `[1/|det M|, |det M|]`).  The full `k(Mx)/k(x)` density
statement is recorded as a future direction; the evidence below covers what is
formalized.

## 1. Closure of quadratic irrationals under the integer Möbius action

`mobius p q r s x = (p x + q)/(r x + s)`.

* `x = √2`, root of `x² - 2 = 0` (so `(a,b,c) = (1,0,-2)`).
  Take `M = [[1,1],[1,0]]`, `det = -1`.  Then
  `y = mobius 1 1 1 0 (√2) = (√2 + 1)/√2 = 1 + 1/√2 = 1 + √2/2`.
  Minimal polynomial of `y`: `y - 1 = √2/2`, so `(y-1)² = 1/2`, i.e.
  `2(y-1)² = 1`, i.e. `2y² - 4y + 1 = 0`.  Leading coefficient `2 ≠ 0`; `y`
  irrational.  Matches `quadForm = a s² - b s r + c r²` with `(s,r) = (0,1)`:
  `1·0 - 0 + (-2)·1 = -2 ≠ 0` (the predicted leading coefficient, up to the
  overall `det²` scaling).

* `x = golden ratio φ`, root of `x² - x - 1 = 0` (`(a,b,c) = (1,-1,-1)`).
  `M = [[2,0],[0,1]]`, `det = 2`.  `y = 2φ`.  Then `φ = y/2` gives
  `(y/2)² - (y/2) - 1 = 0`, i.e. `y² - 2y - 4 = 0`.  Leading coeff `1 ≠ 0`,
  `y` irrational.  Confirms closure.

In every sampled `(x, M)` with `det M ≠ 0` the image was again a real quadratic
irrational, and the leading coefficient `quadForm` was nonzero — consistent with
`RatioSpectrum.quadForm_ne_zero` (anisotropy of the form, equivalently the
discriminant `b² - 4ac` is not a perfect square because `x` is irrational).

## 2. Anisotropy / discriminant non-square (counterexample hunt)

`quadForm_ne_zero` claims `a m² - b m n + c n² ≠ 0` for `(m,n) ≠ (0,0)` whenever
`x` is irrational.  Tested the boundary identity
`4a·(a m² - b m n + c n²) = (2 a m - b n)² - (b² - 4 a c) n²`
for `(a,b,c) = (1,0,-2)` (disc `8`, not a square): for all
`(m,n) ∈ [-5,5]² \ {0}` the form is nonzero.  A *rational* root example
`(a,b,c) = (1,0,-1)` (disc `4`, a perfect square; `x = 1` is rational) gives the
form `m² - n²`, which **does** vanish at `(m,n) = (1,1)` — confirming the
irrationality hypothesis is load-bearing, exactly as the Critic note records.

## 3. The target interval `[1/|det M|, |det M|]`

For integer `M` with `det M ≠ 0`, `|det M| ≥ 1`:

| `M`            | `det` | `|det|` | interval `[1/|det|, |det|]` |
|----------------|------:|--------:|-----------------------------|
| `[[1,1],[1,0]]`|  `-1` |   `1`   | `[1, 1]` (a point: `k` invariant) |
| `[[2,0],[0,1]]`|  `2`  |   `2`   | `[1/2, 2]`                  |
| `[[3,1],[0,1]]`|  `3`  |   `3`   | `[1/3, 3]`                  |

Each interval contains `1`, is nonempty, and its endpoints multiply to `1`
(`(1/|det|)·|det| = 1`).  These are exactly
`RatioSpectrum.one_mem_spectrum_interval`, `spectrum_lower_le_upper`, and
`spectrum_endpoints_mul`.  For `|det| = 1` (i.e. `M ∈ GL₂(ℤ)`) the interval
collapses to `{1}`, recovering the classical fact that `GL₂(ℤ)` preserves the
Lagrange constant.

## 4. Scaling / primitivity invariance

`mobius (k M) x = mobius M x` for `k ≠ 0`: e.g. `k = 3`, `M = [[2,0],[0,1]]`,
`x = φ`: `(6φ)/(3) = 2φ = mobius M x`.  Confirms
`RatioSpectrum.mobius_smul_invariant` and explains why the density statement is
phrased for *primitive* `M` (Smith-normal-form reduction divides out the gcd of
the entries without changing the action).

## 5. Composition / determinant multiplicativity

`mobius M (mobius N x) = mobius (M N) x` and `det (M N) = det M · det N` were
checked on random integer pairs; e.g. `M = [[1,1],[0,1]]`, `N = [[2,0],[1,1]]`,
`MN = [[3,1],[1,1]]`, `det 2`; numerics agree to machine precision.  Formalized
as `RatioSpectrum.mobius_comp` and `RatioSpectrum.det_mul`.

## Scope note

The Lagrange-constant function `k(·)` itself (a `limsup` over continued-fraction
convergents) is **not** in Mathlib, so the end-to-end density of `k(Mx)/k(x)` is
left as a future direction.  The formalized results isolate the purely algebraic
half of the program, which is a prerequisite for any density argument.
