# Future Directions: Finiteness of the Yamabe Constant

## Synthesis

This cycle formalised, in Lean 4, the *finiteness theorem* for the Yamabe
invariant `Y(M,[g]) = inf_u E(u)` of a conformal class on a compact manifold,
where

    E(u) = ( D(u) + C(u) ) / N(u),
    D(u) = a·‖∇u‖²₂   (Dirichlet energy),
    C(u) = ∫_M R_g·u²  (curvature energy),
    N(u) = ‖u‖²_p      (critical Lᵖ normalisation, p = 2n/(n-2)).

The classical statement — `Y(M,[g])` is a *finite real number* — was split into
two structurally independent halves and both were proved with `sorry = 0`:

* **Analytic core** (`Applications/Yamabe/CurvatureEnergy.lean`):
  `integral_curvature_lower_bound` and `integral_curvature_upper_bound` show that
  a pointwise scalar-curvature bound `R₀ ≤ R_g ≤ R₁` transfers to the integral
  curvature energy: `R₀·∫u² ≤ ∫R_g·u² ≤ R₁·∫u²`. These hold over an *arbitrary*
  measure space, assuming only integrability of `u²` and `R_g·u²`.

* **Order-theoretic core** (`Applications/Yamabe/Quotient.lean`):
  `quotient_lower_bound` proves the uniform bound `E(u) ≥ min 0 (R₀·K)` for every
  test function, combining `D ≥ 0`, the curvature bound above, and the
  finite-measure Hölder comparison `‖u‖²₂ ≤ K·‖u‖²_p` (`K = Vol(M)^{2/n}`).
  `bddBelow_range_quotient` and `yamabe_constant_finite` then trap
  `Y := sInf (range E)` in the interval `[min 0 (R₀·K), E(u₀)]` for any single
  test function `u₀`, certifying `Y` is neither `-∞` nor `+∞`.

A single bound `min 0 (R₀·K)` handles both signs of scalar curvature uniformly,
which is precisely why the Yamabe constant can be negative (hyperbolic geometry)
yet never `-∞`.

## Results Summary

| Theorem | File | Statement |
|---|---|---|
| `integral_curvature_lower_bound` | CurvatureEnergy.lean | `R₀ ≤ R ⟹ R₀·∫u² ≤ ∫R·u²` |
| `integral_curvature_upper_bound` | CurvatureEnergy.lean | `R ≤ R₁ ⟹ ∫R·u² ≤ R₁·∫u²` |
| `quotient_lower_bound` | Quotient.lean | `E(u) ≥ min 0 (R₀·K)` for all `u` |
| `bddBelow_range_quotient` | Quotient.lean | `BddBelow (range E)` |
| `yamabe_constant_finite` | Quotient.lean | `min 0 (R₀·K) ≤ sInf(range E) ≤ E(u₀)` |

All five depend only on `propext, Classical.choice, Quot.sound`.

## Research Directions

### 1. From Hölder hypothesis to an internalised finite-measure inequality

Right now the comparison `‖u‖²₂ ≤ K·‖u‖²_p` enters `quotient_lower_bound` as an
explicit hypothesis. The next cycle should *prove* it for `IsFiniteMeasure μ` and
`2 ≤ p`, instantiating `K = (μ univ)^{1 - 2/p}` via Mathlib's
`MeasureTheory.lintegral`/`Lp` Hölder machinery, and feed it directly into
`yamabe_constant_finite` so the only remaining inputs are geometric
(`R₀ = min_M R_g`) and the Dirichlet energy. **The key insight is** that
boundedness-below of the Yamabe functional needs only the *cheap* Hölder
comparison of `L²` against `Lᵖ` on a finite-volume space — not the deep Sobolev
embedding `‖u‖_p ≤ S(‖∇u‖₂ + ‖u‖₂)` that the *existence of minimisers* requires.
**Why now?** The curvature half is already fully internalised over abstract
measure spaces; closing the Hölder gap removes the last hand-supplied inequality
and yields an unconditional finiteness theorem over `IsFiniteMeasure`.

### 2. The conformal-invariance identity for the quotient

Conjecture: under a conformal change `g̃ = u^{4/(n-2)} g`, the Yamabe energy is the
quotient transformation `E_g(uw) = E_{g̃}(w)` (up to the standard conformal
Laplacian identity `L_g(uw) = u^{(n+2)/(n-2)} L_{g̃}(w)`), so that `inf E` is a
genuine invariant of the conformal class. **The key insight is** that the entire
`u`-dependence collapses into a single algebraic substitution on the abstract
triple `(D, C, N)` once the conformal Laplacian relation is granted, so the
invariance is provable at the same abstract level as `quotient_lower_bound`
without any PDE. **Why now?** We already have the quotient as a first-class object;
adding a `conformalChange` action on `(D, C, N)` and proving `sInf` is preserved
is a natural, self-contained extension that turns "finite" into "invariant".

### 3. Sign trichotomy of the Yamabe invariant

Conjecture (Yamabe sign trichotomy): the sign of `Y(M,[g])` is a conformal
invariant determined by whether the conformal class admits a metric of positive,
zero, or negative scalar curvature; concretely `sign(Y) = sign(λ₁(L_g))`, the
first eigenvalue of the conformal Laplacian. A falsifiable abstract version: with
`D ≥ 0` and `C(u) ≥ R₀·N(u)`, if there exists `u₊` with `D(u₊)+C(u₊) > 0` then
`Y ≥ 0` cannot be improved to `Y > 0` without a spectral gap hypothesis. **The key
insight is** that the trichotomy is *exactly* the statement that `min 0 (R₀·K)`
saturates only in the negative branch, so the eigenvalue `λ₁` is what upgrades the
crude `min 0 (R₀·K)` bound to a sharp sign. **Why now?** Our lower bound already
exposes the `min 0 (·)` dichotomy; introducing an abstract Rayleigh quotient and
its first eigenvalue lets us test where the crude bound is and is not sharp.

### 4. Attainment of the infimum below the round-sphere threshold

Conjecture (Aubin's threshold, abstract form): if there exists a test function
`u*` with `E(u*) < Y(Sⁿ)` (the round-sphere Yamabe constant, the universal upper
bound), then `sInf (range E)` is *attained* — i.e. it is a minimum, not merely an
infimum. **The key insight is** that strict inequality against the conformally
critical threshold restores the compactness lost at the critical Sobolev exponent,
which at the abstract level means the sublevel sets of `E` become `IsCompact` and
`sInf` is realised. **Why now?** We have proved `BddBelow (range E)`; the very next
order-theoretic question is attainment, and framing Aubin's threshold as a
`IsClosed`/`IsCompact` condition on sublevel sets is provable independently of the
elliptic regularity that the full PDE proof uses.

### 5. Discrete (graph) Yamabe constant as a finite computable model

Conjecture: on a finite weighted graph `(V, w)` with combinatorial Laplacian `L`
and "curvature" `R : V → ℝ`, the discrete Yamabe quotient
`E(u) = (⟪u, Lu⟫ + Σ R_i w_i u_i²) / (Σ w_i u_i^p)^{2/p}` satisfies the *same*
finiteness theorem, with the Hölder step replaced by the elementary discrete power-
mean inequality `Σ w_i u_i² ≤ (Σ w_i)^{1-2/p} (Σ w_i u_i^p)^{2/p}`. **The key
insight is** that every analytic ingredient of the Yamabe finiteness proof has a
purely finite, `#eval`-able combinatorial avatar, so the theorem becomes
*computable* and the bound `min 0 (R₀·K)` can be checked numerically against
`sInf`. **Why now?** Our abstract `quotient` already takes arbitrary real-valued
`D, C, N`; instantiating them on `Fin n → ℝ` with a graph Laplacian gives a
zero-PDE, fully verified, *and executable* model that stress-tests the abstract
theorems and seeds a discrete-geometry research line.
