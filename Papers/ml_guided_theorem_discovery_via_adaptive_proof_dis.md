# Computational Evidence — Exact Finite Realizability by Single-Activation Networks

This note gives small-case evidence for the central claim of the cycle: a
point-separating subalgebra of continuous functions (in particular the read-out
algebra of a single-activation network) does not merely *approximate* a finite
dataset — it *interpolates it exactly*, and therefore realizes any Boolean
labeling of the sample points on the nose, with unit output margin.

## 1. Small-case Lagrange indicators

Take three distinct inputs `x₀ < x₁ < x₂` and the separating generator `h = id`
(the coordinate feature). The Lagrange indicators used in the proof are

```
e_i(t) = ∏_{j ≠ i} (t - x_j) / (x_i - x_j).
```

Concretely with `x = (0, 1, 2)`:

```
e₀(t) = (t-1)(t-2)/2
e₁(t) = -(t)(t-2)
e₂(t) = (t)(t-1)/2
```

Check the indicator property `e_i(x_j) = δ_ij`:

| i \ j | 0 | 1 | 2 |
|-------|---|---|---|
| e₀    | 1 | 0 | 0 |
| e₁    | 0 | 1 | 0 |
| e₂    | 0 | 0 | 1 |

All 9 entries verified by direct substitution. Hence for any targets
`t = (t₀, t₁, t₂)` the combination `f = t₀ e₀ + t₁ e₁ + t₂ e₂` satisfies
`f(x_j) = t_j` exactly.

## 2. Boolean concept realization with margin

For a Boolean labeling `ℓ : {0,1,2} → {true,false}` take targets
`t_i = +1` if `ℓ(i) = true`, else `t_i = -1`. The interpolant `f` then satisfies
`f(x_i) = ±1`, so:

* `sign f(x_i)` reproduces `ℓ(i)` exactly, and
* the output margin `|f(x_i)| = 1` at every sample point.

Example: `ℓ = (true, false, true)` gives `t = (1, -1, 1)` and

```
f(t) = e₀(t) - e₁(t) + e₂(t) = (t-1)(t-2)/2 + t(t-2) + t(t-1)/2.
```

Evaluations: `f(0) = 1`, `f(1) = -1`, `f(2) = 1`. Sign pattern `(+,-,+)` matches
`(true,false,true)`; margin `1` everywhere. ✓

## 3. Counterexample hunt (necessity of injectivity)

The construction requires the *inputs* to be distinct; equivalently, that the
feature separate them. If two inputs collapse to the same feature value, *no*
polynomial read-out can distinguish them (this is exactly the sharpness result
`activation_not_separates` in the catalog). A quick hunt confirms the boundary:
with a non-injective feature `g(t) = t²` and inputs `x = (-1, +1)`, both map to
feature value `1`, so every read-out gives `f(-1) = f(+1)`; the labeling
`ℓ = (true, false)` is unrealizable. This matches the injectivity hypothesis used
throughout and shows it cannot be dropped.

## 4. Scope of the evidence

The theorems proved this cycle are *existence* statements over arbitrary compact
domains, so exhaustive numerical search is not the right validation tool; the
worked Lagrange computation above is the faithful finite witness. The one
genuine corner case, `n = 0` (empty dataset), makes every statement hold
trivially and truthfully, and is included in the formal statements without a
side condition.
