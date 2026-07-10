# Computational Evidence — Poincaré Conjecture for Data

All experiments were run inside Lean 4 (`#eval`) so the numbers below are reproducible
and consistent with the formalized theorems in `Algebra/PoincareData*.lean`.

## 1. The `n^{-1/d}` packing exponent (Chebyshev cube model)

We model a sampled `d`-dimensional object as the discrete cube `{0,…,m-1}^d` and a point
cloud as a set `S` of samples; the scale is the ℓ^∞ (Chebyshev) radius `r`. A single ball of
radius `r` covers at most `(2r+1)^d` grid points, so an `r`-cover needs

    n = |S| ≥ m^d / (2r+1)^d,     i.e.   (2r+1) ≥ m · n^{-1/d}.

Small cases (minimal number of radius-`r` balls to cover the `m=7` line, `d=1`):

| radius r | 2r+1 | #balls = ⌈7/(2r+1)⌉ |
|---------:|-----:|--------------------:|
| 0        | 1    | 7                   |
| 1        | 3    | 3                   |
| 2        | 5    | 2                   |
| 3        | 7    | 1                   |

The product `#balls · (2r+1)` stays `≥ 7 = m`, matching the lower bound
`m ≤ n^{1/d}·(2r+1)` (`covering_radius_scaling`). When `(2r+1) ∣ m` the bound is *tight*:
e.g. `m=6, r=1` needs exactly `2 = 6/3` balls, and in `d` dimensions exactly `t^d`
(`exact_cover_exists` + `min_cover_card`). This pins the exponent at `-1/d`.

## 2. The threshold is a STEP function (disproof of the exact power law)

Minimal covering radius `r_⋆(n)` for `n` samples on the `m=7` line:

| n         | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|-----------|---|---|---|---|---|---|---|
| r_⋆(n)    | 3 | 2 | 1 | 1 | 1 | 1 | 0 |

`r_⋆` is **constant** on `{3,4,5,6}`. Any exact law `ε_⋆(n) = C·n^{-1/d}` (here `d=1`,
so `C/n`) is strictly decreasing/injective, so it cannot reproduce `r_⋆(3)=r_⋆(4)=1`.
This is exactly `no_exact_inverse_power_law`: `C/3 = C/4 = 1` forces `C=3` and `C=4`,
a contradiction. Hence the conjecture holds only *up to constants* (as `≍`), never as an
equality.

## 3. Where the conjecture's `d^{1/2}` factor comes from

The clean packing bound lives in the Chebyshev (ℓ^∞) metric, while the Vietoris–Rips
scale and the sphere `S^d ⊂ ℝ^{d+1}` are measured in Euclidean (ℓ²) distance. The sharp
comparison is `‖x‖_∞ ≤ ‖x‖_2 ≤ √d·‖x‖_∞`, with `√d` attained by the all-ones vector
(`sqrt_d_is_sharp`). Converting an ℓ^∞ covering radius to Euclidean therefore introduces
exactly the `d^{1/2}` prefactor — it is a *metric artifact*, not intrinsic topology.

## 4. Counterexample hunt summary

* The `n^{-1/d}` scaling survives every finite check (Section 1) and is proved as a
  two-sided bound.
* The exact-constant power law fails already at `m=7` (Section 2): a genuine disproof.
* No OEIS sequence is relevant; the objects are covering/packing numbers, not an integer
  sequence to identify.
