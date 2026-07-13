# Computational Evidence — Cone Colorful Carathéodory

We record the small-case exploration that guided the choice of hypotheses and the
sharp color threshold in `ConeColorfulCaratheodory.lean`.

## 1. Homogeneity of the origin

For the origin, "nonnegative combination equal to `0` with at least one positive
coefficient" and "convex combination equal to `0`" describe the same families.
Indeed, if `0 = Σ λ_i v_i` with `λ_i ≥ 0` and `S := Σ λ_i > 0`, then
`0 = Σ (λ_i / S) v_i` with coefficients summing to `1`; conversely a convex
combination is already a nontrivial nonnegative one. Small checks:

* `{1, -1} ⊆ ℝ`: `1·1 + 1·(-1) = 0`, `S = 2`; rescaled `½·1 + ½·(-1) = 0`. ✔
* `{(1,0), (-1,1), (0,-1)} ⊆ ℝ²`: `1·(1,0)+1·(-1,1)+1·(0,-1)=(0,0)`, convex
  version `⅓+⅓+⅓`. ✔

## 2. The color threshold is `r ≥ d + 1`, not `r ≥ d`

The optimistic reading "`r ≥ d` colors suffice" already fails in dimension one.

* `d = 1`, `r = 1`, single class `C₁ = {1, -1}`. The class captures the origin
  conically (`1·1 + 1·(-1) = 0`), but a colorful transversal picks a *single*
  real, whose conical cone is a half-line `{λx : λ ≥ 0}` and never contains the
  origin nontrivially. **Counterexample to `r ≥ d`.**

* `d = 1`, `r = 2`: with `C₁ = C₂ = {1, -1}`, choosing `+1` from color 1 and `-1`
  from color 2 gives `1·(+1) + 1·(-1) = 0`. If instead any class contains `0`,
  that single `0` already witnesses the origin. **The theorem holds at `r = 2 = d+1`.**

## 3. Sign dichotomy in dimension one

A finite `s ⊆ ℝ` captures the origin conically iff `0 ∈ s`, or `s` contains both a
strictly positive and a strictly negative element. Sampled checks:

| `s`          | captures 0 conically? | reason                     |
|--------------|-----------------------|----------------------------|
| `{2, 5}`     | no                    | all positive               |
| `{-3, -1}`   | no                    | all negative               |
| `{0, 4}`     | yes                   | contains `0`               |
| `{-2, 7}`    | yes                   | straddles the origin       |

This dichotomy is exactly `isConicZero_real_sign` and drives the two-case proof of
`colorful_cone_dim_one`.

## 4. Carathéodory bound in dimension `d`

For the origin, the conical Carathéodory number equals the affine one: at most
`d + 1` vectors are needed. Example in `ℝ²` (`d = 2`, bound `3`): the four vectors
`(1,0), (0,1), (-1,0), (0,-1)` capture the origin (`1·(1,0)+1·(-1,0)=0`), and
already the two-element subfamily `{(1,0), (-1,0)}` suffices — well within the
`d + 1 = 3` bound. The bound is achieved by "positive circuits" such as
`{(1,0),(-1,1),(0,-1)}` in `ℝ²`, whose every proper subfamily fails.

No counterexample to any stated theorem was found in the sampled cases; the search
instead falsified the over-optimistic `r ≥ d` threshold and fixed it at `r ≥ d+1`.
