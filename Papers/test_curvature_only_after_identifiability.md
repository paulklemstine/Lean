# Computational Evidence

Numerical evidence gathered *before* and *alongside* the Lean formalisation, used to
choose the models, to guess the closed forms of the metric / Christoffel symbols, and
to cross-check the final theorems by a completely independent route.

**Method.** A small pure-Python script computes, for a two-parameter model
`θ ↦ p(θ) ∈ Δ_{m-1}`, the Fisher metric `g_ij = Σ_a p_a ∂_i log p_a ∂_j log p_a`, then
`∂_k g_ij`, then the Christoffel symbols `Γ^k_{ij} = ½ g^{km}(∂_i g_{mj} + ∂_j g_{mi} − ∂_m g_{ij})`,
then `∂_d Γ^k_{ij}`, and finally the Gauss curvature
`K = (Σ_l R^l{}_{101} g_{l0}) / det g` — all derivatives by central finite differences with
step `h = 10⁻⁴`, starting only from the raw probability functions. Nothing from the Lean
development is reused, so agreement is a genuine independent check of the closed forms.

**Caveat.** Everything in this file is *numerical*, hence **not** formally verified.
The formally verified statements are exactly the theorems in
`Catalog/Combinatorics/*.lean`; the numbers below only agree with them.

---

## 1. Trinomial simplex `p = (x, y, 1 − x − y)`

Finite-difference curvature at five interior points:

| (x, y) | (0.2, 0.3) | (0.5, 0.25) | (0.1, 0.1) | (0.4, 0.4) | (0.05, 0.6) |
|---|---|---|---|---|---|
| `K` | 0.250000 | 0.250000 | 0.250000 | 0.250000 | 0.250000 |

Constant `+1/4`, to six digits, at every sampled point. This is the numerical shadow of
the formal theorem `TrinomialFisher.gaussianCurvature_eq : gaussianCurvature x y = 1/4`.

The value `1/4` is exactly what the isometry `p ↦ 2√p` onto the sphere of radius `2`
predicts (`K = 1/r² = 1/4`); the isometry itself is formalised as
`FisherIdentifiability.pullback_eq_fisher`.

**α-family.** Replacing `Γ` by `(1+α)Γ` and recomputing gives, for
`α ∈ {−1, −0.5, 0, 0.5, 1, 2}`, the values `0, 0.1875, 0.25, 0.1875, 0, −0.75`, i.e.
`(1 − α²)/4` — formalised as `TrinomialFisher.alphaCurv_eq`.

## 2. Poincaré half-plane control `g = diag(1/y², 1/y²)`

Run through the *same* `riemann`/`sectional` code path, the half-plane returns `K = −1`.
This was used purely as a **sign-convention calibration**: it certifies that the machinery
that reports `+1/4` for the simplex is the one that reports `−1` for the standard model of
constant negative curvature, so the positive sign of the simplex is not an artefact of an
index convention. Formalised as `HyperbolicControl.hyperbolicCurvature_eq`.

## 3. 2×2 independence model `p = (uv, u(1−v), (1−u)v, (1−u)(1−v))`

| (u, v) | (0.3, 0.4) | (0.5, 0.5) | (0.1, 0.8) | (0.7, 0.2) |
|---|---|---|---|---|
| `K` | −6.2·10⁻¹⁰ | 0.0 | 1.2·10⁻¹⁰ | −1.8·10⁻⁹ |

Zero to finite-difference noise. Formalised (exactly, for all `u, v`) as
`IndependenceModel.indepCurvature_eq_zero`.

## 4. Tied two-group model `p = ((1−s)t, (1−s)(1−t), s t², s(1−t²))`

This model was found by a **counterexample hunt**: the search was for a four-outcome,
two-parameter model whose curvature is not of one sign. Curvature table (rows `s`, columns `t`):

| `s \ t` | 0.1 | 0.3 | 0.5 | 0.7 | 0.9 |
|---|---|---|---|---|---|
| **0.1** | 0.1463 | 0.0156 | −0.0622 | −0.1132 | −0.1491 |
| **0.3** | 0.1111 | 0.0082 | −0.0255 | −0.0388 | −0.0444 |
| **0.5** | 0.0544 | 0.0004 | 0.0051 | 0.0149 | 0.0239 |
| **0.7** | −0.0456 | −0.0078 | 0.0309 | 0.0549 | 0.0709 |
| **0.9** | −0.2480 | −0.0164 | 0.0528 | 0.0855 | 0.1047 |

Both signs occur, and the zero set is a curve through the square, so the curvature is
neither constant nor of one sign. Two entries were promoted to exact rational statements
and formalised:

| point | finite difference | exact rational | formal theorem |
|---|---|---|---|
| `(1/10, 1/2)` | −0.062175 | `−239/3844 = −0.0621748…` | `TiedTwoGroup.tiedCurvature_at_half` |
| `(1/10, 1/10)` | 0.146315 | `6209/42436 = 0.1463144…` | `TiedTwoGroup.tiedCurvature_at_tenth` |

Agreement to 5–6 digits in both cases.

## 5. What the counterexample hunt did *not* find

No four-outcome two-parameter model in the sample had **constant negative** curvature.
A sweep of 300 randomly generated two-parameter exponential families on 4, 5 or 6 outcomes
(sufficient statistics drawn uniformly from `[-2,2]²`, evaluated at a random interior point)
produced curvatures as low as `K ≈ −0.44`, so negative Fisher curvature is common; but in
every sampled case the curvature varied with the parameter. This is the numerical origin
of Conjecture 1 in `FUTURE_DIRECTIONS.md` (no finite-support two-parameter model carries a
constant negative Fisher curvature). It is a *conjecture*: it has **not** been proved and is
not among the Lean theorems.

## 6. OEIS

No integer sequence arises in this project — the objects are rational functions of two real
parameters, not counting sequences — so no OEIS lookup applies. The rational curvature values
(`1/4`, `0`, `−1`, `−239/3844`, `6209/42436`) are isolated constants, not a sequence.
