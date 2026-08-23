# Computational Evidence — Escape Criterion Iteration

All experiments concern the quadratic family `f_c(z) = z² + c` and the escape radius
`R(c) = max(2, |c|)`, which is the radius used in the Lean development
(`Catalog/Novelty/EscapeCriterionIteration.lean`).

## 1. The escape test itself (20 000 random pairs)

Sampled `c, z₀` uniformly from the square `[-3,3]²` (as complex numbers). Iterated up to 60
steps; whenever an orbit point satisfied `|z_k| > R(c)`, 50 further iterations were run.

| test | violations |
|---|---|
| "crossing `max(2,\|c\|)` implies divergence (\|z\| > 10⁶ after 50 more steps)" | 0 / 20000 |
| one-step growth bound `\|z² + c\| ≥ (\|z\| − 1)\|z\|` in the escaping region | 0 / 20000 |
| critical orbits with `\|c\| ≤ 2` that exceed 2 yet stay bounded | 0 / 20000 |

The second row is the one-step estimate `qmap_norm_ge_mul`; the third is the radius-2
characterisation `mem_Mandelbrot_iff`.

## 2. Geometric growth rate

For `z` with `|z| = 2 + ε` and `|c| ≤ |z|`, the predicted lower bound is
`|z_n| ≥ (|z| − 1)^n |z|`. Sample (c = 0.3 + 0.1i, z₀ = 2.5):

| n | actual \|z_n\| | bound `(\|z₀\|−1)^n \|z₀\|` |
|---|---|---|
| 0 | 2.500 | 2.500 |
| 1 | 6.551 | 3.750 |
| 2 | 43.216 | 5.625 |
| 3 | 1867.9 | 8.438 |
| 4 | 3.489·10⁶ | 12.656 |

The bound is valid but very lossy after a few steps — as expected, since the true growth is
doubly exponential (`log|z_n| ≈ 2ⁿ G`). This is exactly why the second file
(`EscapeRateGreenFunction.lean`) renormalises by `2^{-n}`.

## 3. Escape-time bound

`escape_time_bound` predicts `|z_n| ≥ B` as soon as `n ≥ B/(ε|z₀|)` when `|z₀| ≥ 2 + ε`.
For `z₀ = 2.5` (ε = 0.5), `B = 10⁶`: the predicted sufficient `n` is `800000`, while the
actual escape time is `4`. The bound is therefore *sound but far from sharp* — it is a linear
(Bernoulli) bound deliberately chosen because it is provable with elementary estimates, and
because it is enough to make the escape-time test terminating.

## 4. Escape rate (Green's function) `G_c(z) = lim 2^{-n} log|z_n|`

Numerically the normalised sequence stabilises within a handful of steps.

| c | z₀ | `2^{-n} log\|z_n\|`, n = 0..5 | limit |
|---|---|---|---|
| 0 | 2.5 | 0.9163, 0.9163, 0.9163, 0.9163, 0.9163, 0.9163 | log 2.5 = 0.9163 |
| 0.3+0.1i | 2.5 | 0.9163, 0.9398, 0.9415, 0.9416, 0.9416, 0.9416 | 0.94157 |
| −1 | 3.0 | 1.0986, 1.0397, 1.0358, 1.0358, 1.0358, 1.0358 | 1.03580 |

In each sample `|G − log|z₀|| ≤ 1` (`abs_escapeRate_sub_log_le_one`), `G > 0`
(`escapeRate_pos`), and `G_c(f_c z₀) = 2 G_c(z₀)` holds to 10 significant digits
(`escapeRate_functional_equation`); e.g. for `c = 0.3+0.1i`, `z₀ = 2.5`:
`G(z₀) = 0.9415703`, `G(z₀²+c) = 1.8831407 = 2·G(z₀)`.

## 5. Sharpness of the radius 2

`c = −2` has critical orbit `0, −2, 2, 2, 2, …`, bounded, with `|z_n| = 2` for `n ≥ 1`.
So no radius `R < 2` gives a sound test, which is `escapeRadius_sharp`. Similarly `c = 1/4`
(the cusp) has critical orbit increasing to the fixed point `1/2`, staying inside the disk.

## 6. OEIS

No integer sequence is naturally attached to these real-analytic quantities; the only
candidate, the number of period-`n` hyperbolic components of `M` (A000740-adjacent counts),
is not used in this development, so no OEIS identification is claimed.

## Status of the evidence

These are floating-point experiments run outside Lean and are **not** verification. Every
statement listed above that is asserted as a result was subsequently proved in Lean with no
`sorry`; the numerics only guided the choice of statements (in particular the strict
inequality `> R(c)` rather than `≥`, which item 5 shows to be necessary).
