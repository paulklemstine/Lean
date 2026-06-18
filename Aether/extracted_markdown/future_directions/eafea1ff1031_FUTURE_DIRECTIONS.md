# FUTURE_DIRECTIONS — Fractal Topology: Hausdorff Dimension as a Bi-Lipschitz Invariant

## Synthesis

This cycle isolated the structural reason Hausdorff dimension behaves like a
*topological/metric invariant*. Mathlib records that `dimH` is preserved by
isometries (`Isometry.dimH_image`) and by continuous linear equivalences
(`ContinuousLinearEquiv.dimH_image`), but both are corollaries of a single,
weaker hypothesis. A map that is simultaneously **Lipschitz** (upper bound, via
`LipschitzWith.dimH_image_le`) and **antilipschitz** (lower bound, via
`AntilipschitzWith.le_dimH_image`) preserves `dimH` exactly — no metric
preservation, linearity, or surjectivity required. We packaged this as
`dimH_image_eq_of_biLipschitz` (in `Catalog/Geometry/HausdorffBiLipschitz.lean`),
the centerpiece, and then harvested its consequences: nonzero scaling, translation,
and hence the **entire affine group** preserve Hausdorff dimension. This is
precisely the invariance that makes the dimension of a self-similar attractor a
pure scale-free ratio `log N / log(1/r)`.

The cross-domain payoff connects this geometry to the catalog's *fractal number
theory* (`Catalog/Physics/PrimeFractalDimension.lean`, where the logarithmic prime
set `{1/log p}` is shown to have `dimH = 0`). In
`Catalog/Bridges/FractalDimensionBridge.lean` we proved the more robust statement
that **any** bi-Lipschitz reshaping of a countable set — in particular the
logarithmic integer fractal `{1/log n}` that contains the prime fractal `{1/log p}`
— keeps dimension `0`. So dimension `0` is an *intrinsic* feature of the prime
fractal, not an artifact of the `1/log` embedding chosen in the catalog; it
survives every bi-Lipschitz change of coordinates.

The Critic supplied the sharp boundary: the constant map (Lipschitz with `K = 0`,
but **not** antilipschitz) collapses the real line — dimension `1` — to a point of
dimension `0` (`dimH_const_image_lt`). This shows antilipschitzness is the
irreducible half of the hypothesis; it is what controls the lower bound on
dimension. The generalization loop then relaxed Lipschitz to Hölder-`r`, recovering
the graded bound `dimH (f '' s) ≤ dimH s / r` (`dimH_holder_image_le`), of which the
bi-Lipschitz invariant is the `r = 1` case. The two-sided bi-Hölder dimension
*transform* remains the natural open frontier.

## Results Summary (all proved this cycle, `sorry`-free, kernel-checked)

- `dimH_image_eq_of_biLipschitz` — bi-Lipschitz maps preserve Hausdorff dimension,
  strictly generalizing `Isometry.dimH_image` (the centerpiece).
- `antilipschitzWith_smul_nonzero` — multiplication by a nonzero scalar is
  antilipschitz with the tight constant `‖c‖₊⁻¹`.
- `dimH_smul_set_eq` — `dimH (c • s) = dimH s` for `c ≠ 0`; the self-similarity
  (scale) invariance underlying fractal dimension.
- `dimH_translate_set_eq` — translation preserves Hausdorff dimension (isometry case).
- `dimH_affine_set_eq` — every invertible affine map `x ↦ c • x + a` preserves
  Hausdorff dimension; `dimH` is an affine-group invariant.
- `dimH_const_image_lt` (Critic) — a constant map strictly drops dimension
  (`ℝ` → point), proving antilipschitzness is necessary in the centerpiece.
- `dimH_holder_image_le` (generalization) — a Hölder-`r` map inflates dimension by
  at most the factor `1/r`; `r = 1` recovers the centerpiece's upper bound.
- `dimH_biLipschitz_image_countable_eq_zero` — bi-Lipschitz images of countable
  sets have dimension `0`.
- `dimH_biLipschitz_image_logRange_eq_zero` (cross-domain) — every bi-Lipschitz
  reshaping of the logarithmic integer fractal `{1/log n}` (⊇ the prime fractal
  `{1/log p}`) keeps dimension `0`.
- `dimH_smul_logRange_eq_zero` — concrete instance: rescaling the logarithmic
  fractal by `5` leaves dimension `0`.

## Research Directions

### Direction 1: Two-sided bi-Hölder dimension transform
**Hypothesis.** If `f` is Hölder-`r` (`0 < r ≤ 1`) and its inverse `g = f⁻¹` is
Hölder-`r'`, then `r' • dimH s ≤ dimH (f '' s) ≤ r⁻¹ • dimH s`; in particular a
bi-Hölder homeomorphism with matched exponents `r = r'` rescales dimension
multiplicatively.
**Test.** Formalize the lower bound by transporting `AntilipschitzWith.le_dimH_image`
through `HolderWith` of the inverse (the upper half is already supplied by
`dimH_holder_image_le`). Disprove the naive equality with `x ↦ x²` on `[0,1]`.
**The key insight is** that the two halves of `dimH_image_eq_of_biLipschitz`
decouple: the Lipschitz half generalizes to a Hölder *upper* bound (done), so the
only missing piece to "close the square" is the Hölder *lower* bound, obtained by
applying the upper-bound machinery to the inverse map.
**Why now?** This cycle already proved the `r = 1` two-sided case
(`dimH_image_eq_of_biLipschitz`) and the one-sided Hölder upper bound
(`dimH_holder_image_le`); only the Hölder lower bound is missing.
**If true:** a complete dictionary for how singular reparametrizations (e.g. devil's
staircase coordinates) deform Hausdorff dimension. **If false:** the counterexample
localizes exactly which regularity assumption forces the lower bound.

### Direction 2: Self-similar attractors realize the similarity dimension
**Hypothesis.** For a finite IFS of contracting similarities with ratios `rᵢ`
satisfying the open set condition, the attractor `K` has `dimH K = d`, where `d` is
the unique solution of `∑ rᵢ^d = 1` (the Moran/similarity dimension).
**Test.** Build the attractor as a fixed point of the Hutchinson operator; use
`dimH_smul_set_eq` and `dimH_bUnion` to get `dimH K = max_i dimH (sᵢ '' K)` and the
scaling relation, then solve the Moran equation. Start with the middle-thirds Cantor
set (`d = log 2 / log 3`).
**The key insight is** that `dimH_smul_set_eq` turns the geometric self-similarity
equation `K = ⋃ᵢ sᵢ(K)` directly into a numerical dimension equation, because each
similarity `sᵢ` is affine and hence dimension-preserving on every piece.
**Why now?** `dimH_smul_set_eq` (scale invariance) and `dimH_affine_set_eq` are
exactly the tools that convert the self-similarity equation into a dimension
equation; this cycle supplied them. **If true:** first formal proof in this catalog
that a nontrivial fractal attains its expected fractional dimension. **If false**
(e.g. without the open set condition): pinpoints how overlap deforms measured dimension.

### Direction 3: Box-counting equals Hausdorff dimension for self-similar sets
**Hypothesis.** For the attractors of Direction 2 (open set condition), the upper
box-counting dimension `upperBoxDim` (defined in
`Catalog/Physics/PrimeFractalDimension.lean`) equals `dimH`.
**Test.** Bound `upperBoxDim` above by the similarity dimension via the natural
cover by cylinder sets, and below by `dimH` (using `dimH ≤ upperBoxDim` in general).
Contrast with the catalog's prime fractal, where `dimH = 0 < 1 =` conjectured box
dimension — a *strict* gap.
**The key insight is** that bi-Lipschitz invariance makes *both* dimensions
coordinate-free, so the equality (for self-similar sets) versus the strict gap (for
the prime fractal) is a statement about the set's internal structure, not its
embedding.
**Why now?** This cycle's bi-Lipschitz invariance makes both dimensions
coordinate-free. **If true:** explains *why* the prime fractal's dimension gap
(`dimH = 0`, box `= 1`) is special — it is the failure of self-similarity, not of
countability alone. **If false:** reveals a self-similar set where the two dimensions
diverge, a strong structural surprise.

### Direction 4: Dimension and Cartesian products (Marstrand/Besicovitch)
**Hypothesis.** `dimH (s ×ˢ t) ≥ dimH s + dimH t`, with equality when one factor is
"dimension-regular" (e.g. Ahlfors regular).
**Test.** The lower bound follows from the product Hausdorff measure; formalize it
for `s, t ⊆ ℝ` and combine with `dimH_univ_pi` (in Mathlib:
`dimH (univ : Set (Fin n → ℝ)) = n`). Use bi-Lipschitz invariance to reduce to a
canonical embedding of the product.
**The key insight is** that `dimH_image_eq_of_biLipschitz` lets us identify
`ℝ^m × ℝ^n` with `ℝ^{m+n}` bi-Lipschitzly, converting the product statement into the
additivity of `finrank`, already in Mathlib for the full-dimensional case.
**Why now?** The bi-Lipschitz identification machinery now exists in the catalog.
**If true:** opens the door to product fractals (e.g. Cantor dust `C × C`, dimension
`2 log 2 / log 3`). **If false:** the gap between `≥` and `=` is exactly the Marstrand
phenomenon and identifies which regularity hypothesis does the work.

### Direction 5: Lipschitz (not bi-Lipschitz) maps and the dimension-drop spectrum
**Hypothesis.** For a `K`-Lipschitz `f : ℝ → ℝ`, the set of achievable values of
`dimH s − dimH (f '' s)` over all `s` is the full interval `[0, dimH s]`; moreover
`dimH (f '' s) = dimH s` for *every* `s` iff `f` is locally antilipschitz off a
dimension-`0` set.
**Test.** `dimH_const_image_lt` already realizes the extreme drop `dimH s − 0`.
Interpolate with piecewise-affine `f` constant on a fat subset; compute
`dimH (f '' s)` via `dimH_union` and `dimH_smul_set_eq`.
**The key insight is** that this cycle produced *both* endpoints of the spectrum —
exact preservation (bi-Lipschitz) and total collapse (constant) — so the quantitative
intermediate regime is the natural next question, governed by *local* antilipschitzness.
**Why now?** Both endpoints are formalized. **If true:** a clean characterization of
dimension-preserving Lipschitz maps, weaker than antilipschitz. **If false:** a
forbidden gap in the drop spectrum would be a striking rigidity theorem.
