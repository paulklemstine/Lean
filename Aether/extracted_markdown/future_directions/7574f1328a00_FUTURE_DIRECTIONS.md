# Future Directions: From the Willmore–Gauss–Bonnet Bridge

## Synthesis

This cycle welded together two previously disjoint catalog packages —
`Geometry.WillmoreEnergy` (the measure-theoretic Willmore calculus) and
`Geometry.DiscreteGaussBonnet` (the combinatorial angle-defect Gauss–Bonnet
engine) — into a single exact decomposition file,
`Geometry.WillmoreGaussBonnetBridge`.

The conceptual pivot was to stop treating the Willmore inequality `∫K ≤ W` as
an inequality. The catalog's slack identity `W − ∫K = totalDefect` together with
the Gauss–Bonnet input `∫K = 2π·χ` forces the **exact** decomposition
`W = 2π·χ + totalDefect`, in which the entire excess of the Willmore energy over
its topological floor is *literally* the L² norm of the traceless second
fundamental form. Every downstream result — the genus-0 gap `W = 4π + defect`,
sphere rigidity `W = 4π ⟺ umbilic a.e.`, the strict inequality away from
umbilicity, and the discrete-to-smooth bridge `2π·χ(T) ≤ W` — is a corollary of
this one identity composed with the catalog's a.e.-umbilic rigidity and the
discrete Gauss–Bonnet theorem.

## Results Summary

- `willmore_decompose_of_gaussBonnet`: `W = 2π·χ + totalDefect` (exact).
- `willmore_genus_zero_gap` / `willmore_minus_fourPi_eq_defect`:
  `W = 4π + totalDefect`, `W − 4π = totalDefect`.
- `willmore_eq_fourPi_iff_umbilic`: sphere rigidity `W = 4π ⟺ k₁ = k₂` a.e.
- `willmore_strict_gt_of_not_umbilic`: non-umbilic ⟹ `2π·χ < W` strictly.
- `willmore_ge_discrete_eulerChar`: combinatorial floor `2π·χ(T) ≤ W`.
- `willmore_ge_fourPi_of_discrete_sphere`: genus-0 triangulation ⟹ `4π ≤ W`.
- `willmore_torus_floor_trivial`: genus-1 triangulation ⟹ only `0 ≤ W`,
  exposing the elementary method's blindness to the `2π²` torus minimum.

All main results carry zero `sorry` and depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. A quantitative stability ("almost-rigidity") theorem for the sphere

The rigidity statement `W = 4π ⟺ umbilic a.e.` is binary. The next step is a
*stable* version: there should be a modulus `ω` with
`W − 4π = totalDefect ≥ ω(‖k₁ − k₂‖_{L¹})`, so that energies close to `4π`
force the surface to be close to umbilic in a measured sense. The cleanest
falsifiable form is the L²-Chebyshev bound
`μ({ x : |k₁(x) − k₂(x)| ≥ t }) ≤ 4·(W − 4π)/t²`. **The key insight is** that
because `W − 4π` is exactly `∫((k₁−k₂)/2)²`, a Chebyshev/Markov inequality on
this nonnegative integrand converts the scalar energy gap directly into a
distributional bound on the umbilicity defect — no analysis beyond the
catalog's integral machinery is required. **Why now?** The exact decomposition
proved this cycle makes `W − 4π` *equal* to a single square integral, so the
stability estimate is now a one-line measure-theoretic consequence rather than
a hard PDE estimate; it is the natural and immediately reachable sharpening.

### 2. Conformal (Möbius) invariance of the umbilic defect integral

The Willmore energy's deepest classical property is invariance under conformal
transformations of the ambient space. In the measure model this should appear
as invariance of `totalDefect` under a class of rescalings
`(k₁, k₂) ↦ (λ·k₁ + c, λ·k₂ + c)` combined with a measure reweighting
`μ ↦ λ⁻²·μ`. The falsifiable claim: there is an explicit group action on the
pair `(kᵢ, μ)` leaving `totalDefect`, and hence `W − ∫K`, invariant. **The key
insight is** that the traceless part `(k₁ − k₂)/2` is unchanged by adding a
common shift `c` to both curvatures, so conformal invariance of the *defect*
reduces to the algebra of the difference together with a compensating power of
the measure — entirely inside the existing `umbilicDefect`/`totalDefect`
calculus. **Why now?** With `W − ∫K` now identified as a standalone invariant
quantity (not just a slack term), it becomes a concrete object whose symmetry
group can be stated and proved, opening the catalog's first conformal-geometry
thread.

### 3. A genus-additive Li–Yau floor from disjoint multiplicity sheets

The catalog already proves `4π·n ≤ W` from `n` disjoint `4π`-sheets
(`willmore_ge_fourPi_mul_of_disjoint_sheets`). Combined with this cycle's exact
decomposition, one should get a *strict* and *defect-quantified* multiplicity
bound: `W ≥ 4π·n + (defect outside the sheets)`, hence `W = 4π·n` forces
umbilicity off the sheets. The falsifiable target:
`W − 4π·n = totalDefect_on(Uᶜ) + Σᵢ (∫_{sᵢ} H² − 4π) ≥ 0` with equality iff each
sheet is a round `4π` piece and the complement is umbilic. **The key insight is**
that set-additivity of the integral lets the global decomposition be localized
sheet-by-sheet, so the multiplicity bound inherits the same "floor + explicit
nonnegative remainder" shape. **Why now?** Both ingredients — the disjoint-sheet
bound and the exact decomposition — now live in the same namespace and share the
same integrability hypotheses, so their fusion is purely a bookkeeping exercise
in `setIntegral` additivity.

### 4. Bridging to the discrete *vertex-level* Willmore energy

The bridge `willmore_ge_discrete_eulerChar` currently matches only the *total*
curvatures of the smooth and discrete models. A finer bridge would define a
discrete Willmore density at each vertex (e.g. via the squared mean of incident
dihedral angles) and prove a per-vertex `K(v) ≤ H²(v)` mirroring the pointwise
`gaussCurv_le_willmoreDensity`. The falsifiable claim: there is a discrete
`willmoreVertex` on `TriangulatedSurface` with
`∑_v K(v) ≤ ∑_v willmoreVertex v` and equality iff every vertex is discretely
umbilic. **The key insight is** that the pointwise square identity
`H² − K = ((k₁−k₂)/2)²` is dimension-free and combinatorial in spirit, so it
should have an exact analogue at each vertex of a triangulation, making the
discrete Gauss–Bonnet sum dominated term-by-term. **Why now?** The discrete
Gauss–Bonnet package supplies a ready `vertexCurvature`, and this cycle showed
the smooth side is governed entirely by a square identity; transplanting that
identity to vertices is the obvious next structural extension and would make the
bridge an *intrinsic* discrete theorem rather than a hypothesis-matched one.

### 5. The genus-1 gap: encoding the missing `2π²` as an explicit obstruction

For the torus the elementary floor collapses (`willmore_torus_floor_trivial`).
The honest next move is not to *prove* the `2π²` Marques–Neves bound (which needs
min-max), but to formalize *exactly what extra hypothesis* upgrades the trivial
`0 ≤ W` to `2π² ≤ W`. The falsifiable target: state a "conformal volume ≥ 2"
hypothesis `Hcv` as a clean inequality on `(k₁, k₂, μ)` and prove
`Hcv → 2π² ≤ W` while exhibiting a Clifford-torus-like model saturating it.
**The key insight is** that the gap between the topological floor `0` and the
true floor `2π²` is precisely a *non-pointwise* quantity (it cannot be a square
integral, since those are already accounted for in `totalDefect`), so isolating
it pinpoints the exact place where elementary methods must yield to min-max.
**Why now?** Having proved that the elementary method gives *only* `0 ≤ W` for
the torus, we have a sharp, documented boundary of the technique; the most
valuable next contribution is to name the missing input precisely rather than to
chase a proof the catalog cannot yet support.
