# Future Directions — Willmore Conjecture Generalizations

## Synthesis

This cycle built the *algebraic and combinatorial skeleton* of the Willmore
conjecture inside Lean 4, in a self-contained discrete measured-surface model
(`Catalog/Geometry/WillmoreEnergy.lean`). The model represents a closed surface
as a finite family of curvature "patches", each carrying two principal
curvatures and a nonnegative area weight, turning the surface integral
`W(Σ) = ∫_Σ H² dA` into a weighted finite sum. This is the principal-curvature
companion to the angle-defect model already in
`Catalog/Geometry/DiscreteGaussBonnet.lean`, and the two are joined through
total Gaussian curvature via Gauss–Bonnet `∫ K = 2π·χ`.

The structural insight that emerged is a clean separation of *what is
algebra* from *what is genuine geometry*. The pointwise identity
`H² − K = (κ₁−κ₂)²/4` is pure algebra and instantly yields the elementary
bound `W ≥ ∫ K` together with a sharp equality/rigidity statement: equality
holds exactly when every positive-area patch is umbilic. Through Gauss–Bonnet
this gives the sharp `W ≥ 4π` for genus `0`, but is *vacuous* for genus `≥ 1`
because `χ = 2−2g ≤ 0`. The cycle isolates the single geometric input that
repairs this gap: the positive-curvature mass `∫ max(K,0)` is genus-independent
and satisfies `∫ K₊ ≥ 4π` (Gauss-map degree / convex-hull argument). Feeding
this in yields the universal bound `W ≥ 4π` for *all* genera. The round sphere
attains it, proving sharpness.

What this makes vivid is precisely *why* Marques–Neves needed minimax theory:
Gauss–Bonnet alone cannot see past `4π`, yet the torus bound is the strictly
larger `2π²`. The deficit decomposition `∫ K₊ = ∫ K + ∫ K₋` proven here is the
natural place to inject the missing curvature-concentration estimate that
distinguishes higher genus. The directions below target the next layer of that
structure.

## Results Summary

- `meanCurv_sq_sub_gaussCurv`: proved — the pointwise identity `H² − K = (κ₁−κ₂)²/4` that powers every Willmore lower bound.
- `meanCurv_sq_ge_gaussCurv`: proved — pointwise `H² ≥ K`, the umbilic-deficit inequality.
- `willmore_ge_total_gauss`: proved — the elementary Willmore bound `W ≥ ∫ K`.
- `willmore_eq_total_gauss_iff_umbilic`: proved — equality holds iff every positive-area patch is umbilic (sphere rigidity).
- `positiveGauss_decomposition`: proved — deficit decomposition `∫ K₊ = ∫ K + ∫ K₋`.
- `willmore_ge_positive_gauss`: proved — the sharper, genus-independent `W ≥ ∫ max(K,0)`.
- `willmore_ge_four_pi`: proved — the universal Willmore bound `W ≥ 4π` from the Gauss-map input `∫ K₊ ≥ 4π`.
- `willmore_ge_gaussBonnet` / `willmore_genus_bound`: proved — the genus form `W ≥ 2π(2−2g)`, sharp at `g=0`, vacuous at `g≥1`.
- `roundSphere_willmore`: proved — the round sphere attains `W = 4π` (sharpness).
- `roundSphere_umbilic`: proved — the sphere lies in the equality case, witnessing minimization.

## Research Directions

### Direction 1: A discrete Li–Yau threshold for self-intersections
**Hypothesis**: In the patch model, if the surface "covers a point with
multiplicity `m`" (formalized as `m` disjoint patch-subfamilies each with
positive-curvature mass `≥ 4π`), then `W ≥ 4π·m`. Consequently `W < 8π`
forces an embedding (multiplicity `1`).
**Test**: Strengthen `willmore_ge_positive_gauss` to a disjoint-family sum:
prove `W ≥ ∑_j ∫_{A_j} K₊` over disjoint patch sets `A_j`, then specialize
each integral to `≥ 4π`.
**Why now**: `positiveGauss_decomposition` and the termwise `Finset.sum_le_sum`
structure already express `W` as a sum of nonnegative local contributions —
the only new ingredient is partitioning the index set, which is finitary.
**If true**: Formalizes the Li–Yau multiplicity bound, the exact tool that
makes `8π` the embeddedness threshold underlying Marques–Neves.
**If false**: The counterexample would reveal that area weighting can
concentrate curvature without raising `W`, sharpening what "multiplicity"
must mean discretely.

### Direction 2: Strict gap above `4π` for non-umbilic surfaces
**Hypothesis**: If some positive-area patch is non-umbilic (`κ₁ ≠ κ₂`) by a
definite amount `δ`, then `W ≥ ∫ K + c·δ²` for an explicit `c > 0` depending
on the umbilic-patch's area; hence `W > ∫ K` strictly.
**Test**: Refine `willmore_eq_total_gauss_iff_umbilic` from an iff into a
quantitative lower bound by keeping the deficit term
`area·(κ₁−κ₂)²/4` instead of discarding it.
**Why now**: The proof of the equality case already exhibits the deficit as an
explicit nonnegative sum; retaining one term gives the quantitative version
for free.
**If true**: Gives a stability/rigidity estimate — surfaces near a sphere in
`W` are near-umbilic — the discrete shadow of Willmore-energy stability theorems.
**If false**: Would mean curvature anisotropy can hide at zero area cost,
flagging a needed nondegeneracy hypothesis.

### Direction 3: Linking the two curvature models
**Hypothesis**: There is a faithful comparison map from
`DiscreteGaussBonnet.TriangulatedSurface` to `WillmoreEnergy.DiscreteSurface`
under which the angle-defect total curvature equals `totalGaussCurv`, so
`discrete_gauss_bonnet` instantiates `willmore_genus_bound` with `χ = 2−2g`.
**Test**: Define `TriangulatedSurface → DiscreteSurface` sending vertex
curvatures to patch Gaussian curvatures and prove
`totalGaussCurv (toSurface T) = ∑_v vertexCurvature v`, then chain with
`total_curvature_eq_genus`.
**Why now**: Both files are now in the catalog with matching Gauss–Bonnet
statements; only the translation lemma is missing.
**If true**: Produces a genuinely cross-domain bridge (combinatorial topology →
curvature energy) and a fully discrete derivation of `W ≥ 2π(2−2g)`.
**If false**: The mismatch pinpoints where angle-defect curvature and
principal-curvature products genuinely diverge.

### Direction 4: The Marques–Neves constant `2π²` as a model bound
**Hypothesis** (conjecture): There is a definable subclass of genus-1
patch surfaces (a discrete Clifford-torus family) on which `W ≥ 2π²`, and the
discrete Clifford torus attains it, with `2π² > 4π`.
**Test**: Construct an explicit two-curvature Clifford-torus patch family,
compute its `W` symbolically, and prove the numeric inequality `2π² > 4π`
(equivalently `π > 2`). The lower bound itself stays a `conjecture`.
**Why now**: `roundSphere_willmore` shows the machinery for evaluating `W` on
explicit single-/few-patch surfaces; the Clifford torus is the next concrete
target, and `π > 2` is already provable in Mathlib.
**If true**: Even establishing the *attainment* value `2π²` and the strict
ordering `4π < 2π² < 8π` formalizes the numerology of the Willmore conjecture
hierarchy.
**If false**: A wrong attainment value would expose an error in the discrete
Clifford-torus encoding.

### Direction 5: Monotone genus-indexed lower-bound ladder
**Hypothesis** (conjecture): Define `β : ℕ → ℝ` by the conjectured Willmore
minima (`β 0 = 4π`, `β 1 = 2π²`, `β g ↑ 8π`). Then `β` is strictly increasing
and bounded above by `8π`, and any closed genus-`g` patch surface satisfies
`W ≥ β g`.
**Test**: As a first rigorous step, define a *provable* monotone lower-bound
ladder `b g := 4π` (constant, from `willmore_ge_four_pi`) and prove
`W ≥ b g` for all `g`; then state the sharp `β` ladder as a conjecture with
the monotonicity `β g < β (g+1) ≤ 8π` as the falsifiable core.
**Why now**: `willmore_ge_four_pi` already gives the flat floor for every
genus; the research question is exactly how much the floor can rise with `g`.
**If true**: Captures the full conjectural Willmore hierarchy as a single
monotone sequence — the organizing principle of the whole problem.
**If false**: Non-monotonicity of the true minima would be a major surprise and
would redirect the entire program.
