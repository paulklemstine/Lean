# Future Directions: Tropical Phase Transitions in Learning

## Synthesis of this cycle

This cycle laid the rigorous one-dimensional foundation for a tropical theory of
phase transitions in learning. A one-dimensional tropical polynomial is the
pointwise maximum of finitely many affine "monomials" `x ↦ aᵢ·x + bᵢ` — exactly
the function computed by a single-input ReLU layer. We proved, with zero `sorry`:

- **Convexity backbone** (`Convexity.lean`): every tropical monomial is convex
  (`tropMono_convexOn`); the binary tropical sum preserves convexity
  (`tropical_sum_two_convexOn`); and, by `Finset.Nonempty.cons_induction`,
  *every* finite tropical polynomial over an arbitrary index set is convex
  (`tropPoly_convexOn`) and continuous (`tropPoly_continuous`).
- **Crossover / bifurcation theory** (`Crossover.lean`): for two monomials with
  distinct exponents the co-dominance locus — the **1-D tropical hypersurface** —
  is exactly the single crossover point `x* = (b₁-b₂)/(a₂-a₁)`
  (`tropical_hypersurface_eq_crossover`), with the lower/higher-exponent monomial
  dominating below/above it (`crossover_left_dominant`, `crossover_right_dominant`).
  The crossover position is **strictly monotone in the coefficient gap**
  (`crossover_monotone_in_gap`), and in parameter space the dominant monomial
  switches as a coefficient crosses an explicit threshold
  (`bifurcation_threshold_left/right`).

These extend the catalog's `Catalog/Tropical/Core/TropicalPolynomials.lean`
(which only handled monotonicity of fixed degree-1/2 examples) to arbitrary
families and to the genuinely analytic invariants — convexity and the
phase-boundary geometry — that the conjectures below require.

## Results summary

| Theorem | Statement | File |
|---|---|---|
| `tropPoly_convexOn` | finite tropical polynomial is convex | Convexity |
| `tropical_sum_two_convexOn` | max of two monomials is convex | Convexity |
| `tropPoly_continuous` | tropical polynomial is continuous | Convexity |
| `tropical_hypersurface_eq_crossover` | 1-D tropical hypersurface = `{x*}` | Crossover |
| `crossover_left/right_dominant` | dominance below/above `x*` | Crossover |
| `crossover_monotone_in_gap` | `x*` strictly monotone in coefficient gap | Crossover |
| `bifurcation_threshold_left/right` | dominance switch in parameter space | Crossover |

---

## Direction 1 — Multi-dimensional tropical hypersurfaces and ReLU expressivity

Lift `tropPoly` from `ℝ` to `ℝⁿ`: a monomial becomes `x ↦ ⟨aᵢ, x⟩ + bᵢ` with
`aᵢ ∈ ℝⁿ`, and the tropical hypersurface is the set where the max is attained by
at least two monomials. **Conjecture:** a tropical polynomial with `m` monomials
in `ℝⁿ` has at most `m.choose 2` codimension-1 facets, each carried by a
hyperplane `⟨aᵢ - aⱼ, x⟩ = bⱼ - bᵢ`, and the bound is tight.

The key insight is that `tropical_hypersurface_eq_crossover` already exhibits the
`n = 1`, `m = 2` base case (`1.choose 2`... rather `2.choose 2 = 1` point), and
each higher facet is *exactly* a pairwise co-dominance set — so the whole
hypersurface is governed by the same affine equations `⟨aᵢ-aⱼ,x⟩ = bⱼ-bᵢ` that
define ReLU decision boundaries. Why now? The 1-D pairwise crossover is fully
formalized and the facet equations are literal `n`-dimensional copies of it;
Mathlib's affine-subspace and hyperplane-arrangement API makes the counting
argument (one facet per dominating pair) tractable.

## Direction 2 — Convex-duality form of tropical Legendre transform

Define the tropical Legendre dual of `f(x) = maxᵢ (aᵢ·x + bᵢ)` by
`f*(y) = -min { bᵢ : aᵢ = y }` on the finite slope-set, `+∞` elsewhere.
**Conjecture:** `f*` is the restriction of the classical convex conjugate of `f`
to the slopes actually realized, and the double dual `f** = f` recovers exactly
the *non-redundant* monomials (those that dominate on a nonempty interval).

The key insight is that `tropPoly_convexOn` makes `f` a genuine convex function,
so Fenchel–Moreau biconjugation `f** = f` applies verbatim, and the crossover
analysis pins down precisely which monomials are non-redundant: monomial `i`
survives iff its dominance interval (between adjacent crossovers from
`crossover_monotone_in_gap`) is nonempty. Why now? Convexity is the exact
hypothesis Fenchel–Moreau needs, and it is now proved; the catalog's
`FenchelMoreau` file supplies the abstract conjugation machinery to specialize.

## Direction 3 — Counting kinks: a tropical Descartes bound

For a 1-D tropical polynomial with `m` monomials of *distinct* exponents, the
graph is piecewise affine. **Conjecture:** it has at most `m - 1` kinks
(non-differentiability points), each a pairwise crossover, and after discarding
redundant monomials the number of kinks equals (number of surviving monomials) − 1;
the surviving exponents are exactly the vertices of the lower convex hull of the
points `(aᵢ, -bᵢ)` (the Newton-polygon/`upper hull` picture).

The key insight is that each kink is a co-dominance point and
`tropical_hypersurface_eq_crossover` shows pairwise co-dominance is a single
point, so the kink set injects into the `m.choose 2` crossovers but is pruned by
convexity (`tropPoly_convexOn`) down to the hull vertices. Why now? The crossover
location and its monotone dependence on coefficients are formalized, giving a
direct handle on which crossovers are "active" (on the graph) versus hidden below
the max. The Newton-polygon reformulation connects to the catalog's
`Tropical/Bezout.lean` and `PolynomialBridge.lean`.

## Direction 4 — Gradient-flow dwell-time near a shrinking gap (grokking seed)

Model a tropical loss `L(θ) = maxᵢ fᵢ(θ)` with `fᵢ` affine in a parameter `θ`.
Subgradient flow is a piecewise-linear dynamical system whose switches are the
parameter-space thresholds of `bifurcation_threshold_left/right`.
**Conjecture:** the flow crosses at most `k - 1` phase boundaries before
converging, and the dwell time spent within distance `ε` of a boundary with
co-dominance gap `g` scales like `Θ(ε / g)` — so an exponentially small gap
produces an exponentially long plateau (a tropical model of delayed
generalization / grokking).

The key insight is that `crossover_monotone_in_gap` already establishes the
*static* `Θ(1/g)` sensitivity of the boundary position to the gap; the dynamic
dwell time is its time-integral, and the monotone, Lipschitz dependence proven
here is exactly the regularity needed to bound trajectory residence near the
boundary. Why now? The monotone boundary law and the explicit threshold are
formalized; integrating them along the (piecewise-linear) flow is the next
concrete step and needs only Mathlib's ODE/Lipschitz-flow lemmas, not new
geometry.

## Direction 5 — Depth separation via composition of tropical polynomials

A two-layer ReLU network computes a tropical *rational* function (a difference of
two tropical polynomials). **Conjecture:** depth-`(d+1)` width-`w` tropical
circuits strictly contain depth-`d` width-`w` circuits for all `d ≥ 1`, `w ≥ 2`,
and the separation is witnessed by a function whose number of kinks (Direction 3)
grows multiplicatively under composition — exceeding the additive growth any
fixed-depth circuit can achieve.

The key insight is that `tropical_sum_two_convexOn` shows a single tropical layer
keeps convexity (kinks add), whereas composition breaks convexity and lets kinks
*multiply*; the kink-count invariant of Direction 3 therefore serves as a
depth-lower-bound certificate. Why now? With convexity preservation under one
layer proven and the kink count made precise, the remaining task is to track how
the kink count transforms under one explicit composition step — a finite,
checkable combinatorial identity rather than an asymptotic estimate.
