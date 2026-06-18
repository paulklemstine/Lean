# Future Directions: Willmore Energy Lower Bounds by Genus

## Synthesis

`WillmoreEnergy.lean` realizes the *entire elementary half* of the Willmore
story inside a deliberately minimal abstraction: a measure space `(X, μ)`
carrying two principal-curvature functions `k₁, k₂ : X → ℝ`. No smooth
manifold, no immersion, no second fundamental form as a tensor — just raw
measurable functions. The surprising payoff is that the classical chain of
inequalities collapses onto a single algebraic seed, the square identity

```
H² - K = ((k₁ - k₂)/2)²        (willmoreDensity_sub_gaussCurv)
```

Everything else is an integral of this one fact. The pointwise nonnegativity of
the right-hand side gives `K ≤ H²`; integrating gives `∫K ≤ W`
(`gauss_le_willmore`); the Gauss–Bonnet substitution `∫K = 2π·χ` gives
`2π·χ ≤ W` (`gaussBonnet_bound`); and `χ = 2` gives the sharp genus-0 floor
`4π ≤ W` (`willmore_ge_fourPi_genus_zero`). The same square identity, read as an
*equality with remainder*, upgrades the bound to the rigidity statement
`W = ∫K ↔ k₁ = k₂` a.e. (`willmore_eq_gauss_iff_umbilic_ae`). A set-integral
refinement isolates the Gauss-map degree mechanism and yields both the universal
`4π` bound (`willmore_ge_fourPi_of_setGauss`) and a Li–Yau multiplicity bound
`W ≥ 4π·n` from `n` disjoint sheets
(`willmore_ge_fourPi_mul_of_disjoint_sheets`).

This file plugs directly into the catalog's discrete-topology layer:
`DiscreteGaussBonnet.lean` already proves `total_curvature_eq_genus`
(`∑ K(v) = 2π(2 - 2g)`), `eulerChar_eq_two_sub_two_mul_genus` (`χ = 2 - 2g`) and
`sphere_euler_char` (`χ = 2`). Those totals are exactly the Gauss–Bonnet inputs
`hGB : totalGauss = 2π·χ` consumed here, so the two files compose into one
curvature→topology→energy pipeline.

## Results Summary

| Theorem | Statement |
|---|---|
| `willmoreDensity_sub_gaussCurv` | `H² - K = ((k₁-k₂)/2)²` (pointwise) |
| `willmoreDensity_eq_gaussCurv_iff` | `H² = K ↔ k₁ = k₂` (pointwise rigidity) |
| `willmoreEnergy_sub_gauss_eq_defect` | `W - ∫K = ∫((k₁-k₂)/2)²` |
| `gauss_le_willmore` | `∫K ≤ W` |
| `willmore_eq_gauss_iff_umbilic_ae` | `W = ∫K ↔ k₁ = k₂` a.e. (integral rigidity) |
| `gaussBonnet_bound` | `2π·χ ≤ W` |
| `willmore_ge_fourPi_genus_zero` | `4π ≤ W` for genus 0 |
| `willmore_ge_fourPi_of_setGauss` | one `4π`-region forces `W ≥ 4π` |
| `willmore_ge_fourPi_mul_of_disjoint_sheets` | `n` sheets force `W ≥ 4π·n` (Li–Yau) |
| `gaussBonnet_bound_vacuous_high_genus` | `4π(1-g) ≤ 0` for `g ≥ 1` |
| `elementary_bound_step` / `elementary_bound_antitone` | `b(g+1) = b(g) - 4π`, strictly decreasing |

All main results are `sorry`-free and depend only on the standard axioms
`propext, Classical.choice, Quot.sound`.

---

## Direction 1 — A quantitative umbilic-defect lower bound

`willmoreEnergy_sub_gauss_eq_defect` already exhibits the slack in `∫K ≤ W` as
the *total umbilic defect* `∫((k₁-k₂)/2)²`. Conjecture: this can be lower-bounded
by a coarse, observable quantity, e.g. `W ≥ 2π·χ + c · (esssup|k₁-k₂|)²·μ(S)`
for any region `S` on which the eigenvalue gap stays above a threshold. **The key
insight is** that the defect is not merely nonnegative — it is an honest `L²`
energy of the traceless second fundamental form, so the bare inequality should be
promoted to an identity-with-remainder whose remainder is controlled below by an
`L∞`–`L²` comparison. **Why now?** The remainder term `totalDefect` is already a
named, proven object in the file; only a one-directional `setIntegral` lower bound
(`MeasureTheory.setIntegral_le_integral` run in reverse on a level set) is needed,
which current Mathlib measure theory fully supports. This is falsifiable: a single
non-umbilic surface with vanishing right-hand side would refute the chosen `c`.

## Direction 2 — Sharp constant in the multiplicity bound and its converse

`willmore_ge_fourPi_mul_of_disjoint_sheets` proves `W ≥ 4π·n` from `n` disjoint
`4π`-sheets. Conjecture: the constant `4π` is sharp and the bound is *saturated*
exactly when every sheet is a totally-umbilic `4π`-cap, i.e. equality forces
`k₁ = k₂` a.e. on `⋃ sᵢ` and `K = 0` a.e. off it. **The key insight is** that
the two ingredients are already isolated: the sheet bound contributes the `4π·n`
floor while `willmore_eq_gauss_iff_umbilic_ae` contributes the umbilicity rigidity
on the equality locus, so the converse is a *gluing* of two existing theorems
rather than new analysis. **Why now?** Both halves are proven; the only missing
glue is `MeasureTheory.integral_eq_zero_iff_of_nonneg_ae` applied on the
restricted measure `μ.restrict (⋃ sᵢ)`. Falsifiable: a non-umbilic equality case
would break it.

## Direction 3 — Genus-monotonicity of the elementary obstruction gap

`gaussBonnet_bound_vacuous_high_genus` and `elementary_bound_step` show the
elementary floor `b(g) = 4π(1-g)` decreases by exactly `4π` per unit genus and
goes vacuous for `g ≥ 1`. Conjecture: the *gap* `δ(g) = β(g) - b(g)` between the
elementary floor and the true sharp floor `β(g)` (with `β(0) = 4π`, `β(1) = 2π²`)
is strictly increasing in `g`, quantifying exactly how much energy the elementary
method fails to detect. **The key insight is** that `b(g)` is fully understood as
a clean affine function of `g`, so monotonicity of the gap reduces to monotonicity
of the (axiomatized) `β(g)` minus a known line — a finite real-arithmetic problem.
**Why now?** With `β(0)` and `β(1)` pinned, the `g = 0 → 1` step
`δ(1) - δ(0) = (2π² - 0) - (4π·(-1) - 0)` is already a `nlinarith`-reachable
inequality on top of `elementary_bound_step`. Falsifiable: any genus with
`β(g) ≤ b(g)` would refute it.

## Direction 4 — A discrete↔continuous Willmore bridge to `DiscreteGaussBonnet.lean`

The catalog's `total_curvature_eq_genus` gives `∑_v K(v) = 2π(2-2g)` for a
triangulated surface; this file's `gaussBonnet_bound` consumes precisely
`∫K = 2π·χ`. Conjecture: a *discrete Willmore energy* `W_d = ∑_v H_d(v)²` defined
from discrete mean curvatures satisfies the discrete analogue `2π·χ ≤ W_d`, with
the continuum statement recovered as a measure-theoretic limit (the vertex measure
`∑_v δ_v` is exactly a finite measure `μ` in the present abstraction). **The key
insight is** that the file's `(X, μ, k₁, k₂)` model is agnostic to whether `μ` is
Lebesgue or atomic, so the discrete surface is *already an instance* of the same
theorem — `gaussBonnet_bound` applies verbatim to `μ = ∑_v δ_v`. **Why now?** No
new analysis is required: instantiate `X := T.V`, `μ := Measure.sum of diracs`,
and feed the catalog's `discrete_gauss_bonnet` output as `hGB`. Falsifiable by any
triangulation whose discrete defect is negative.

## Direction 5 — The Marques–Neves torus floor `2π² ≤ W` via an axiomatized width

The genuine genus-1 floor `2π² ≤ W` (Marques–Neves) lies beyond the elementary
method, which only delivers the vacuous `b(1) = 0`. Tractable intermediate target:
introduce an abstract *width* functional `width : (X → ℝ) → (X → ℝ) → ℝ` on the
present model, characterized by a short list of axioms (monotonicity under the
defect, normalization `width = 2π²` on the Clifford configuration, domination
`width ≤ W`), and prove `2π² ≤ W` from those axioms alone. **The key insight is**
that the entire Almgren–Pitts min-max apparatus can be *encapsulated* as
hypotheses about `width`, reducing the deep theorem to a finite logical core that
Lean can check, exactly as `gaussBonnet_bound` encapsulates Gauss–Bonnet as the
hypothesis `hGB`. **Why now?** The measure-space abstraction here hosts such a
functional with zero manifold overhead, and the file's existing `gauss_le_willmore`
/ `totalDefect_nonneg` give the monotonicity scaffolding the width axioms would
build on. Falsifiable: an axiom set admitting a genus-1 configuration with
`W < 2π²` would expose an inconsistency in the chosen width axioms.
