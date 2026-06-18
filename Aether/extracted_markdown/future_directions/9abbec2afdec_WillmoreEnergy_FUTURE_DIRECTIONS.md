# Future Directions: Willmore Energy and Genus Lower Bounds

The file `Catalog/Geometry/WillmoreEnergy.lean` establishes the **Willmore
conjecture for tori of revolution** as a fully rigorous, `sorry`-free variational
inequality: every torus of revolution `W(R,r) = π²R²/(r√(R²−r²))` satisfies
`W ≥ 2π²`, with equality exactly for the Clifford torus `R = √2·r`. It also pins
the genus-0 value `W(sphere) = 4π` and proves the strict gap `4π < 2π²`. These
results were obtained by reducing the geometry to the single perfect-square
inequality `(r − √(R²−r²))² ≥ 0` (AM–GM) and the standard angular integral
`∫₀^{2π} dφ/(R + r cos φ) = 2π/√(R²−r²)`. They connect naturally to the catalog
files `Geometry.GenusFormula` and `Geometry.DiscreteGaussBonnet`, which already
encode genus and curvature-integral data. The following directions push toward
the higher-genus frontier targeted by the Marques–Neves program.

## 1. The angular integral as an independent, reusable lemma

The closed form `W(R,r) = π²R²/(r√(R²−r²))` rests on
`∫₀^{2π} dφ/(R + r cos φ) = 2π/√(R²−r²)` for `0 < r < R`. Formalizing this
Poisson-type integral in Mathlib (via the Weierstrass `t = tan(φ/2)`
substitution or residue calculus) would let us **derive** `willmoreTorus` from an
honest surface integral `∫ H² dA` rather than positing the closed form. The key
insight is that the entire torus-of-revolution Willmore energy collapses, after
polynomial division of the integrand, to this one rational trigonometric
integral plus a vanishing `∫ cos φ` term — so a single integration lemma unlocks
the geometric definition. Why now? Mathlib's `MeasureTheory` and
`intervalIntegral` APIs already support the substitution machinery and
`∫₀^{2π} cos = 0`, making this the lowest-hanging step toward a definitionally
geometric (not formula-based) Willmore energy.

## 2. Stereographic transport: tori of revolution ↔ Clifford-type tori in S³

The Willmore energy is conformally invariant, and our `R = √2·r` minimizer is the
stereographic image of the Clifford torus in `S³`. A testable conjecture: define
the flat tori `T_{a,b} ⊂ S³` of radii `(a,b)` with `a²+b²=1`, give their energy
`Ŵ(a,b)`, and prove `Ŵ(a,b) = willmoreTorus(R(a,b), r(a,b))` under stereographic
projection, so that the `S³` minimum at `a=b=1/√2` matches our Clifford torus.
The key insight is that conformal invariance turns a hard min–max problem on `S³`
into the elementary single-variable calculus we already solved on `ℝ³`. Why now?
We have the `ℝ³` side completely formalized and sorry-free, so only the explicit
algebraic change-of-variables remains — a finite computation, not an analytic
estimate.

## 3. Genus-monotone lower-bound ladder `β_g`

Let `β_g` denote the infimum of Willmore energy over genus-`g` surfaces. Known
facts: `β_0 = 4π` (Willmore's theorem) and `β_1 = 2π²` (Marques–Neves), and our
file proves the strict instance `β_0 = 4π < 2π² = β_1`. Conjecture to formalize:
the *monotone-then-saturating* ladder `4π = β_0 < β_1 < β_2 < … < 8π` with
`β_g → 8π` as `g → ∞`. The key insight is that connect-summing two genus-`g₁` and
genus-`g₂` minimizers gives `β_{g₁+g₂} < β_{g₁} + β_{g₂} − 4π`, a subadditivity
recursion that forces both strict monotonicity and the `8π` ceiling. Why now? The
recursion is a purely combinatorial inequality over `ℕ` once the connect-sum
energy-defect constant `4π` is taken as a hypothesis, so it can be stated and
proved in Lean today as a clean induction, independent of the deep geometry that
supplies the base estimates.

## 4. Quantitative rigidity / stability of the Clifford minimizer

Our `willmoreTorus_eq_two_pi_sq_iff` gives qualitative rigidity (equality ⟺
`R = √2·r`). The natural strengthening is a **stability estimate**: there is
`c > 0` with `willmoreTorus(R,r) − 2π² ≥ c·(R/r − √2)²` for `R/r` near `√2`. The
key insight is that the energy excess equals `π²(r−s)²/(r·s)` with
`s = √(R²−r²)`, an exact perfect square, so the stability constant is not merely
existential but computable in closed form. Why now? The excess identity follows
directly from the AM–GM step already in our proof of `ratio_ge_two`; promoting
that inequality to the exact identity `W − 2π² = π²(r−s)²/(rs)` is a one-line
`field_simp; ring` strengthening that immediately yields a sharp quadratic
stability bound.

## 5. Helfrich generalization: spontaneous curvature and constrained minima

Membrane biophysics uses the Helfrich energy `∫ (H − H₀)² dA` with spontaneous
curvature `H₀` and area/volume constraints. For tori of revolution this again
reduces to a one-variable rational-trigonometric integral. Conjecture: the
constrained minimizer's radius ratio `R/r` solves an explicit algebraic equation
in `H₀` that degenerates to `√2` as `H₀ → 0`, recovering Willmore. The key
insight is that `(H − H₀)²` expands as `H² − 2H₀H + H₀²`, and the cross term
`∫ H dA` for a torus of revolution is itself an elementary integral (the total
mean curvature), so the whole Helfrich functional stays inside the same
closed-form regime we already control. Why now? With the Willmore (`H₀ = 0`) case
fully formalized, adding the linear-in-`H` correction is an incremental algebraic
extension that turns a sorry-free baseline into a one-parameter family of
biophysically meaningful sharp inequalities.
