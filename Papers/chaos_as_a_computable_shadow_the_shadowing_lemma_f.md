# Computational Evidence: Shadowing of Pseudo-Orbits

This note records the small-case numerics that motivated and sanity-checked the
formal statements in `Contraction.lean` and `Hyperbolic.lean`.

## 1. The error recursion (contractions)

For a Lipschitz map `f` with constant `L` and a `δ`-pseudo-orbit `x`, the distance
`eₙ = dist(xₙ, f^[n] x₀)` from the true orbit through `x₀` satisfies

```
e₀ = 0,      eₙ₊₁ ≤ δ + L · eₙ.
```

Unrolling gives the closed form used in `contraction_error_geometric`:

```
eₙ ≤ δ · (1 - Lⁿ)/(1 - L)   ≤   δ/(1 - L).
```

### Table for `f(x) = x/2` (so `L = 1/2`, bound `δ/(1-L) = 2δ`), with `δ = 1`:

| n | worst-case eₙ = (1 - (1/2)ⁿ)/(1/2) = 2(1 - 2⁻ⁿ) |
|---|---|
| 0 | 0.000 |
| 1 | 1.000 |
| 2 | 1.500 |
| 3 | 1.750 |
| 4 | 1.875 |
| 5 | 1.9375 |
| ∞ | 2.000  (= δ/(1-L)) |

The sequence increases monotonically to the uniform bound `2δ` and never exceeds
it — matching `contraction_error_bound`. Because the bound is uniform in `n`, the
shadowing time is **infinite**: one true orbit shadows the whole pseudo-orbit.

Numerical interpretation: a program iterating `x ↦ x/2` with rounding error
`δ = 10⁻¹⁶` stays within `2·10⁻¹⁶` of a genuine orbit for **all** iterates, which is
far below the `10⁻¹⁰` accuracy target in the mission statement.

## 2. Why the expanding case needs a finite window

For an expanding map (e.g. `u ↦ 2u`, `L = 2`) the forward recursion
`eₙ₊₁ ≤ δ + 2·eₙ` **diverges**: `eₙ ≈ δ·(2ⁿ - 1)`. So forward-anchored shadowing
fails and there is **no** uniform-in-`n` bound. This is a genuine obstruction, not
a proof artifact.

The remedy, realised in `expanding_finite_shadowing`, is to anchor at the *last*
point `x_N` and iterate the inverse `g(u) = u/2` **backwards**. The backward error
`ẽₘ = dist(x_{N-m}, g^[m] x_N)` obeys `ẽₘ₊₁ ≤ μδ + μ·ẽₘ` with `μ = 1/2 < 1`, giving

```
ẽₘ ≤ δ·μ·(1 - μᵐ)/(1 - μ) ≤ δ·μ/(1-μ) = δ.
```

### Table for `g(u) = u/2` (`μ = 1/2`), `δ = 1`, backward bound `δμ/(1-μ) = 1`:

| m | worst-case ẽₘ = (1/2)(1 - 2⁻ᵐ)/(1/2) = 1 - 2⁻ᵐ |
|---|---|
| 0 | 0.000 |
| 1 | 0.500 |
| 2 | 0.750 |
| 3 | 0.875 |
| ∞ | 1.000 |

## 3. Hyperbolic combination

For the linear hyperbolic map `(s,u) ↦ (s/2, 2u)` the product (sup) metric bound is

```
max( δ/(1 - 1/2), δ·(1/2)/(1 - 1/2) ) = max(2δ, δ) = 2δ,
```

exactly the constant proved in `hyperbolicLinear_shadowing`.

## 4. Counterexample hunt

* **Uniform (infinite-time) shadowing of expanding maps:** *fails* — see §2. This
  is why `Hyperbolic.lean` states expanding/hyperbolic shadowing only on a finite
  window `{0,…,N}`. No counterexample exists to the finite-window statements
  themselves; the numeric recursions above saturate but never violate the bounds.
* **Contraction shadowing:** no counterexample found; the explicit orbit
  `n ↦ f^[n] x₀` always works, tested on `x ↦ x/2` and `x ↦ x/3` for random
  pseudo-orbits with `δ ∈ {0.1, 0.01}`; observed errors matched the `δ/(1-L)`
  envelope.

All quantitative claims here are proved in Lean; the tables are the concrete
specialisations of the closed-form bounds.
