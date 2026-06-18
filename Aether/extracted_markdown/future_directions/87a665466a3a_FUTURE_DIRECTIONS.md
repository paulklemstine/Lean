# Future Directions — Topological Quantum Codes from Homology

Derived from the Phase A research cycle that produced `Homology.lean`
(homological logical-qubit count `k = 2g`) and `SystoleDistance.lean`
(distance = systole, `d = O(√g)`). Each conjecture below is bold, falsifiable,
and ready to be formalized in the same `SystolicSurfaceCode` / `CSSSurfaceCode`
framework.

## 1. Hyperbolic surface codes break the `√g` ceiling

**Conjecture.** Replace the *balanced* hypothesis `faces ≤ A · genus` (constant
cells per handle) by a hyperbolic tessellation in which `faces ≥ c · genus` *and*
the systole grows logarithmically: there is a family with
`k = Θ(n)` (constant rate) and `distance = Ω(log n)`.

**The key insight is** that the `d = O(√g)` ceiling proved in
`SystolicSurfaceCode.distance_sq_le_genus` is an artifact of the *balanced*
assumption `F ≤ A·g`; hyperbolic surfaces violate it (`F` grows faster than `g`),
so the systolic inequality `d² ≤ C·F` no longer forces `d² ≤ C·A·g`.

**Why now?** Our framework already isolates the exact hypothesis (`balanced`)
that produces the ceiling, so flipping it to `c·genus ≤ faces` and adding a
logarithmic systole field is a one-structure edit — the obstruction is precisely
located, not hand-waved.

## 2. The tradeoff `k · d² ≤ (C·A) · n` is asymptotically tight in *both* directions

**Conjecture.** Among all `SystolicSurfaceCode`s with fixed `C, A`, the toric
family is order-optimal: no family achieves `k · d² ≥ (1+ε)(C·A)·n` infinitely
often, and the toric family achieves `k · d² = n` exactly.

**The key insight is** that `bpt_tradeoff` already gives the upper direction
`k·d² ≤ (C·A)·k·g` and `toricDistanceCode_tradeoff` gives the saturating
instance `k·d² = n`; the missing piece is a matching lower bound over the whole
class, which would turn the inequality into a genuine asymptotic equality.

**Why now?** Both endpoints are formalized and compile; the conjecture is the
statement that they bracket the whole class, a finite-combinatorics extremal
problem rather than an open geometric one.

## 3. The plane-curve bridge yields an explicit infinite code family of unbounded rate-distance product

**Conjecture.** The codes `planeCurveSurfaceCode d` (genus `(d−1)(d−2)/2`,
`k = 2·planeCurveGenus d`) admit cellulations whose distance grows like the
degree `d`, so that `k · d_code² = Θ(d⁴)` while physical qubits scale like the
number of cells `Θ(d²)` — a quadratic rate-distance advantage over the square
torus.

**The key insight is** that algebraic degree controls *both* genus (hence `k`,
via `planeCurveSurfaceCode_logical`) *and* the natural cell count of a generic
projection, decoupling the logical count from the qubit count along a single
integer parameter.

**Why now?** The bridge `Catalog.Geometry.GenusFormula → CSSSurfaceCode` is
already proved (`planeCurveSurfaceCode_logical`, `quartic_code_logical`), so the
remaining work is purely the distance side, reusing the existing
`SystolicSurfaceCode` distance machinery.

## 4. Color codes are `H₁` of a 3-colorable 2-complex with the *same* `k = 2g` law

**Conjecture.** A triangulated, 3-face-colorable genus-`g` surface (the color-code
setting) obeys the identical logical count `k = 2g`, but with a *doubled*
stabilizer structure that changes the constant in the systolic inequality, not
its `√g` exponent.

**The key insight is** that color codes and surface codes share the same first
homology `H₁(Σ_g)`, so the `numLogicalQubits_eq_two_genus` computation transfers
verbatim once the Euler relation is supplied; only the geometric `C` differs.

**Why now?** `CSSSurfaceCode` is defined purely from `(V,E,F,g)` and the Euler
relation — it is already color-code-agnostic — so proving the color-code instance
is a matter of supplying a 3-colorable cellulation's combinatorics.

## 5. Mesh refinement is a strict resource monotone

**Conjecture.** Subdividing a cellulation (barycentric refinement) leaves `k`
invariant (`logical_mesh_independent`) while *non-strictly increasing* the
distance, and strictly increasing it whenever the refinement lengthens the
systole — giving a constructive route to distance amplification at fixed `k`.

**The key insight is** that `logical_mesh_independent` already proves `k` is a
topological invariant under any genus-preserving recellulation, so distance is
the *only* free parameter left to optimize by refinement.

**Why now?** With `k`-invariance formalized, the conjecture isolates distance as
the sole refinement-sensitive quantity, making "refine to amplify distance" a
precise, testable monotonicity statement rather than folklore.
