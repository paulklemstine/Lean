# Future Directions — Split Geometry

## Synthesis

We set out to formalize the "Impossible Geometry" concept: a metric on ℝ²,
`ds² = dx²/cosh²y + cosh²x·dy²`, advertised as *simultaneously elliptic and
hyperbolic*, with Gaussian curvature `K = sech²x − sech²y` changing sign across
the diagonals `y = ±x`, producing flat "phase boundaries" and bounded geodesic
crossings.

Carrying the Brioschi orthogonal-metric curvature computation through to a
**rigorous closed form** in Lean overturned that story. The genuine curvature is

```
K(x,y) = −cosh²y + (2 − cosh²y) / (cosh²x · cosh²y),
```

which our machine-checked theorems show is **non-positive everywhere** and
**vanishes only at the origin**. There is no elliptic region, no flat diagonal,
and no phase boundary; the whole plane is (variably) hyperbolic with a single
degenerate flat point. The published formula `sech²x − sech²y` is correct only
on the x-axis (`y = 0`) and is refuted off-axis.

This is the value of formalization: a plausible cross-domain conjecture
("curvature is the difference of the two directional weights") was a *partial
linearization* that dropped the dominant `−cosh²y` second-derivative term, and
only a faithful computation exposed the gap.

## Results Summary (all `sorry`-free, standard axioms)

- `split_riemannian` — the metric is positive definite at every point (`E,G>0`,
  `det g = E·G > 0`): the Split Geometry is a genuine Riemannian manifold.
- `Wfun_eq_sqrt` — `W = √(E·G)`, certifying the Brioschi curvature definition.
- `deriv_Gcoef_apply`, `deriv_Ecoef_apply` — exact metric-coefficient derivatives.
- `christoffel_1_12`, `christoffel_2_12` — Levi-Civita connection coefficients
  `Γ¹₁₂ = −tanh y`, `Γ²₁₂ = tanh x`.
- `brioschi_inner_x`, `brioschi_inner_y` — the two inner Brioschi derivative terms.
- `Kcurv_eq` — the rigorous closed form of the Gaussian curvature.
- `Kcurv_nonpos` — `K ≤ 0` everywhere (the headline refutation).
- `Kcurv_eq_zero_iff` — `K = 0 ↔ (x,y) = (0,0)` (the flat locus is one point).
- `split_conjecture_refuted` — `sech²x − sech²y` is false off-axis (witness `(0,1)`).

## Bold, Falsifiable Research Directions

### 1. Total curvature and Gauss–Bonnet for the Split metric
Conjecture: the total curvature `∫∫_{ℝ²} K dA` (with `dA = √(EG) dx dy = W dx dy`)
**converges to a finite negative value**, and equals `−2π·χ_eff` for an effective
Euler characteristic determined by the asymptotic cone structure of the metric.
The key insight is that `K·W = (−cosh²y + (2−cosh²y)/(cosh²x cosh²y))·(cosh x/cosh y)`
factors into an `x`-only times `y`-only integrable profile, so the double integral
separates. Why now? We already have `Kcurv_eq` and `Wfun_eq_sqrt` in closed form;
the integrand is explicit and the separation reduces the claim to two 1-D
integrals tractable with Mathlib's `MeasureTheory`/`integral` API.

### 2. Strict negativity away from the origin and a curvature lower bound
Conjecture: `K(x,y) < 0` for all `(x,y) ≠ (0,0)`, and moreover `K` is bounded:
there is no finite lower bound (it `→ −∞` as `|y| → ∞`), but along any horizontal
line `y = c` it is bounded below by `−cosh²c`. The key insight is that the proven
identity `K = −(a·b² + b − 2)/(a·b)` with `a = cosh²x ≥ 1`, `b = cosh²y ≥ 1`
makes both the strict sign and the rational asymptotics elementary. Why now?
`Kcurv_nonpos` and `Kcurv_eq_zero_iff` already isolate this rational form, so
upgrading `≤ 0` to strict `< 0` off-origin and adding directional bounds is a
short extension rather than new theory.

### 3. The Split metric is (geodesically) complete and CAT(0)
Conjecture: since `K ≤ 0` everywhere and the metric is smooth and complete,
the Split Geometry is a Hadamard surface — simply connected, complete, non-positively
curved — hence CAT(0), so geodesics are unique and the "geodesics cross the phase
boundary at most twice" claim is **vacuously stronger**: there is no boundary to
cross. The key insight is that our non-positivity theorem `Kcurv_nonpos` is exactly
the hypothesis of the Cartan–Hadamard theorem. Why now? With curvature sign settled,
completeness is the only remaining ingredient, and it follows from the explicit
`cosh` growth of the metric coefficients bounding arc length from below.

### 4. Spectral / dual portrait via the separable structure
Conjecture: because `E` depends only on `y` and `G` only on `x`, the
Laplace–Beltrami operator `Δ_g` admits a **partial separation of variables**,
and its `L²(ℝ², dA)` spectrum is purely continuous with an explicit spectral
density built from 1-D Pöschl–Teller (`sech²`) operators. The key insight is that
`sech²` potentials are exactly the reflectionless/solvable Schrödinger potentials,
so the dual (spectral) side of this geometry is completely diagonalizable. Why now?
This realizes the engine's duality mandate (geometry ↔ spectrum) on an object whose
metric coefficients are already the canonical solvable profiles.

### 5. A one-parameter family interpolating hyperbolic and split geometries
Conjecture: the family `ds²_t = dx²/cosh²(t y) + cosh²(t x) dy²` has curvature
`K_t(x,y) = t²·[−cosh²(t y) + (2 − cosh²(t y))/(cosh²(t x) cosh²(t y))]`, which is
`≤ 0` for every `t`, and as `t → 0` converges (after rescaling) to the flat plane,
while the catalog's constant-curvature `HyperbolicDisk` model arises as a distinct
`sech`-conformal limit. The key insight is that the proven closed form `Kcurv_eq`
is *homogeneous under coordinate scaling*, so the entire family inherits
non-positivity from a single rescaling lemma. Why now? `Kcurv_eq` and `Kcurv_nonpos`
already give the `t = 1` case in closed form; the scaling argument turns one theorem
into an infinite family bridging this file to `Geometry/HyperbolicDisk/Core.lean`.
