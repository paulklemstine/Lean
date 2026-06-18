# FUTURE_DIRECTIONS — Hausdorff Dimension as a Bi-Lipschitz and Affine Invariant

This cycle isolated the single structural hypothesis behind every "dimension is a
metric invariant" theorem in Mathlib. Both `Isometry.dimH_image` and
`ContinuousLinearEquiv.dimH_image` are corollaries of one weaker fact: a map that
is simultaneously **Lipschitz** and **antilipschitz** preserves `dimH` exactly
(`dimH_image_eq_of_biLipschitz`). From that single hinge we harvested scale
invariance (`dimH_smul_set_eq`), translation invariance (`dimH_vadd_set_eq`), and
hence invariance under the entire affine group (`dimH_affine_set_eq`). We pinned
down the boundary — a constant map (Lipschitz, but not antilipschitz) collapses
the line to a point (`dimH_const_image_lt`) — and crossed into number theory by
showing the logarithmic integer fractal `{1/log n}` (which contains the prime
fractal `{1/log p}` of `Physics/PrimeFractalDimension.lean`) keeps dimension `0`
under *every* bi-Lipschitz reshaping (`dimH_biLipschitz_image_logRange_eq_zero`).
The directions below extend that frontier.

## Direction 1 — Two-sided bi-Hölder dimension transform

**Conjecture.** If `f` is Hölder-`r` (`0 < r ≤ 1`) and its left inverse `g` is
Hölder-`r'` on `f '' s`, then `r' • dimH s ≤ dimH (f '' s) ≤ r⁻¹ • dimH s`; for a
bi-Hölder homeomorphism with matched exponents `r = r'`, dimension rescales
multiplicatively rather than being preserved.

**The key insight is** that `dimH_holder_image_le` already supplies the upper half
(`dimH (f '' s) ≤ dimH s / r`); the missing lower half is obtained by transporting
`AntilipschitzWith.le_dimH_image` through the Hölder regularity of the *inverse*,
exactly mirroring how this cycle built `dimH_smul_set_eq` from a Lipschitz inverse.

**Test.** Formalize the lower bound; falsify the naive equality with `x ↦ x²` on
`[0,1]`, whose inverse `√` is Hölder-`1/2`, forcing a genuine factor of `2`.

**Why now?** This cycle proved both the `r = 1` two-sided case
(`dimH_image_eq_of_biLipschitz`) and the one-sided Hölder bound
(`dimH_holder_image_le`); only the Hölder lower bound remains to close the square.

## Direction 2 — Self-similar attractors realize the similarity dimension

**Conjecture.** For a finite IFS of contracting similarities with ratios `rᵢ`
satisfying the open set condition, the attractor `K` has `dimH K = d` where `d`
solves the Moran equation `∑ rᵢ^d = 1`. Concrete first target: the middle-thirds
Cantor set, `d = log 2 / log 3`.

**The key insight is** that `dimH_smul_set_eq` turns each self-similar piece
`sᵢ '' K = rᵢ • (rotation/translation of K)` into a *dimension-preserving up to the
scale ratio* copy, so the geometric self-similarity equation becomes a numeric
equation in `d` once combined with `dimH` of finite unions (`dimH_iUnion`).

**Test.** Build `K` as the fixed point of the Hutchinson operator; derive the
scaling relation, then solve Moran. Disprove the clean value when the open set
condition fails (overlapping IFS).

**Why now?** Scale invariance (`dimH_smul_set_eq`) and affine invariance
(`dimH_affine_set_eq`) — both supplied this cycle — are precisely the tools that
convert similarity into a dimension identity.

## Direction 3 — Box-counting versus Hausdorff dimension: explaining the prime gap

**Conjecture.** For open-set-condition self-similar attractors, the upper
box-counting dimension `upperBoxDim` (defined in
`Physics/PrimeFractalDimension.lean`) equals `dimH`. By contrast, the prime
fractal has `dimH = 0` yet conjectured box dimension `1` — a *strict* gap.

**The key insight is** that this cycle's bi-Lipschitz invariance makes *both*
dimensions coordinate-free, so any equality or gap is a property of the set itself,
not of the chosen embedding; the prime fractal's gap is therefore attributable to
the failure of self-similarity, not to mere countability.

**Test.** Bound `upperBoxDim` above by the similarity dimension via cylinder covers
and below by `dimH`. Contrast with `logRange`, where `dimH = 0` is provable
(`dimH_logRange_eq_zero`) but box dimension is positive.

**Why now?** With dimension now known to be bi-Lipschitz intrinsic, the gap is a
well-posed structural question rather than an embedding artifact.

## Direction 4 — Dimension of Cartesian products (Marstrand/Besicovitch)

**Conjecture.** `dimH (s ×ˢ t) ≥ dimH s + dimH t`, with equality when one factor is
Ahlfors-regular; e.g. the Cantor dust `C × C` has dimension `2 log 2 / log 3`.

**The key insight is** that `dimH_image_eq_of_biLipschitz` identifies `ℝ^m × ℝ^n`
with `ℝ^{m+n}` bi-Lipschitzly, reducing the full-dimensional product statement to
the additivity of `finrank` already available via `dimH_univ_pi` in Mathlib.

**Test.** Formalize the product-measure lower bound for `s, t ⊆ ℝ`; locate the
Marstrand gap where `≥` is strict by dropping the regularity hypothesis.

**Why now?** Bi-Lipschitz invariance is exactly what lets the product be analyzed
in a canonical coordinate system, so the additivity reduces to known Mathlib facts.

## Direction 5 — The dimension-drop spectrum of Lipschitz maps

**Conjecture.** For `K`-Lipschitz `f : ℝ → ℝ`, the achievable values of
`dimH s − dimH (f '' s)` fill the whole interval `[0, dimH s]`; moreover
`dimH (f '' s) = dimH s` for *all* `s` iff `f` is locally antilipschitz off a
dimension-`0` set.

**The key insight is** that this cycle produced both extremes — exact preservation
(`dimH_image_eq_of_biLipschitz`) and total collapse (`dimH_const_image_lt`) — so the
spectrum between them is the natural quantitative interpolation, realizable by
piecewise-affine maps that are constant on fat subsets.

**Test.** Interpolate with explicit piecewise-affine `f`, computing
`dimH (f '' s)` via `dimH_union` and `dimH_smul_set_eq`. A forbidden gap in the
spectrum would be a rigidity theorem; a full interval would be a clean
characterization weaker than antilipschitzness.

**Why now?** Both endpoints are now formal theorems in this catalog, making the
intermediate regime the immediate next quantitative target.
