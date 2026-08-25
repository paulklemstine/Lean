# Computational evidence — edge-kernel refinement of a positional profile

All numbers below come from small floating-point calculations with the closed form

```
F(b,t) = ((1+t)^(1-b) - 1) / (2^(1-b) - 1)        (b ≠ 1),
F(1,t) = log(1+t)/log 2,
```

which is the normalised cumulative mass of the kernel `(1+x)^(-b)` on the window `x ∈ [0,1]`.
The closed form itself is **proved in Lean** (`Pythagorean.EdgeKernel.edgeFrac_eq`), so the
numerics below only illustrate the theorems; they are *not* a substitute for them. Anything
labelled "numerical" here is exploratory and is not a verified claim.

## 1. Left-decile prediction of a single power law

| exponent `b` | `F(b, 0.1)` (left-decile mass) |
|---|---|
| 0.573 (flat bulk) | 0.12059 |
| 1.097 | 0.14152 |
| 1.104 | 0.14182 |
| 1.570 | 0.16200 |

So a single power law with the reported bulk-like exponent `b ≈ 1.10` predicts a left-decile
mass near `0.1415`, well below a measured `0.1620`; a *single* law can still reach `0.1620`,
but only by steepening to `b ≈ 1.57`. This is exactly the situation described by the theorems:

* `edgeFrac_strictMono` — `b ↦ F(b,t)` is strictly increasing, so the value `0.1620`
  determines a unique matching exponent;
* `exists_edgeFrac_eq` — such a matching exponent always exists, hence a single decile number
  can never by itself refute a power law.

## 2. A bulk+spike mixture reproduces the left decile

With flat bulk `b₁ = 0.573`, spike weight `w = 0.086`:

| spike exponent `b₂` | mixture left-decile `(1-w)F(b₁,0.1) + w F(b₂,0.1)` |
|---|---|
| 10.6 | 0.16184 |
| 22.54 | 0.18519 |

A narrow spike carrying ≈8.6% of the mass lifts a *flat* bulk (which alone gives 0.1206) to
≈0.162 — the mechanism formalised by `mixFrac_gt_bulk` and quantified in the limit
`b₂ → ∞` by `mixFrac_tendsto_spike` (limit value `w + (1-w)F(b₁,t)` = 0.1902 here).

## 3. Window dependence of the fitted exponent (numerical)

Effective exponent `b_eff(t)` solving `F(b_eff(t), t) = mixFrac(0.086, 0.573, 22.54, t)`:

| window `t` | 0.05 | 0.1 | 0.2 | 0.3 | 0.5 | 0.7 | 0.9 |
|---|---|---|---|---|---|---|---|
| `b_eff(t)` | 2.591 | 2.071 | 1.524 | 1.265 | 1.031 | 0.925 | 0.863 |

The fitted exponent drifts monotonically downward as the window widens: refitting on a
narrow left window returns a much steeper law than the pooled fit. Non-constancy of this
function is **proved** (`effective_exponent_window_dependent`, using `mixFrac_ne_single` and
`exists_effective_exponent`); strict monotonicity in `t` is *not* proved and is listed as
Conjecture 1 in `FUTURE_DIRECTIONS.md`.

## 4. Multiplicative convexity check

For `f(x) = (1+x)^(-0.5) + 0.3 (1+x)^(-12)` and geometric triples
`1+x₁ = sqrt((1+x₀)(1+x₂))`, the ratio `f(x₀)f(x₂)/f(x₁)²` over
`x₀ ∈ {0, .05, .2, .4}`, `x₂ ∈ {.5, .7, 1}` lies in `[1.00067, 1.28576]` — strictly above 1
in every case, as `twoComp_mul_gt_sq` proves in general. The corresponding two-point slope
measurements are strictly steeper on the left half of each triple, e.g.

| triple `(x₀, x₁, x₂)` | left slope | right slope |
|---|---|---|
| (0, 0.4142, 1) | 1.241 | 0.516 |
| (0, 0.1832, 0.4) | 1.807 | 0.715 |
| (0.3, 0.5716, 0.9) | 0.568 | 0.508 |

matching `localExponent_strictAnti`.

## 5. Counterexample hunt

* Attempted counterexamples to strict monotonicity of `b ↦ F(b,t)` over
  `b ∈ [-5, 60]`, `t ∈ {0.05, …, 0.95}`: none found (and the statement is now a theorem).
* Attempted counterexamples to `f(x₁)² < f(x₀)f(x₂)` for two-component profiles on geometric
  triples: none found; equality is approached only as `b₁ → b₂` or `A K → 0`, precisely the
  degenerate cases excluded in the hypotheses.
* No OEIS sequence is involved: all objects here are continuous-parameter families.
