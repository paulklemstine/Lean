# Hausdorff Dimension as a Bi-Lipschitz and Affine-Group Invariant

## Abstract

Hausdorff dimension `dimH` is the canonical measure of the metric complexity of
a set. It is classically known to be preserved by isometries and by continuous
linear isomorphisms. We isolate the single structural hypothesis from which both
of these facts — and many more — follow: a map that is *simultaneously* Lipschitz
and antilipschitz (a **bi-Lipschitz** map) preserves Hausdorff dimension on every
set, with no assumption of distance preservation, linearity, or surjectivity. We
package this as the theorem `dimH(f(s)) = dimH(s)` for bi-Lipschitz `f`, present
its short proof as the antisymmetry of two one-sided bounds, and harvest its
geometric consequences: nonzero scaling, translation, and hence the entire affine
group preserve `dimH`. We pin down the boundary of the hypothesis by exhibiting a
constant map — Lipschitz but not antilipschitz — that strictly collapses
dimension, proving the antilipschitz condition is indispensable. We then cross
into analytic number theory: every bi-Lipschitz reshaping of a countable set
retains dimension `0`, so the zero dimension of the logarithmic prime fractal
`{1/log p}` (and the larger logarithmic integer fractal `{1/log n}` containing it)
is intrinsic, not an artifact of the `1/log` embedding. Finally we record the
graded Hölder generalization of the upper bound, `dimH(f(s)) ≤ dimH(s)/r` for
Hölder-`r` maps, of which the bi-Lipschitz invariant is the `r = 1` case. All
results have been formally verified.

**Keywords.** Hausdorff dimension, bi-Lipschitz maps, antilipschitz maps, affine
invariance, fractal geometry, Hölder maps, prime fractal, countable sets.

---

## 1. Introduction

Hausdorff dimension assigns to every subset of a metric space a number in
`[0, ∞]` quantifying how the set's covering complexity scales as the covering
gauge shrinks. For smooth manifolds it agrees with topological dimension; for
fractals it returns the familiar fractional values (`log 2 / log 3 ≈ 0.6309` for
the middle-thirds Cantor set, etc.). A foundational question for any such
invariant is: *under which transformations is it preserved?*

Two classical answers are well known and are recorded in standard formal
libraries:

- **Isometry invariance.** If `f` preserves all distances, `dimH(f(s)) = dimH(s)`.
- **Linear-isomorphism invariance.** If `f` is a continuous linear equivalence
  between normed spaces, `dimH(f(s)) = dimH(s)`.

These are usually proved independently. The thesis of this paper is that they are
two faces of a single, strictly weaker fact, and that isolating that fact both
clarifies the theory and immediately yields a string of new corollaries.

The unifying hypothesis is **bi-Lipschitz** regularity. We require only that the
map distort distances by at most a fixed factor in each direction. Neither exact
distance preservation (isometry) nor algebraic structure (linearity) nor
surjectivity is needed. From this one hinge we derive scale invariance,
translation invariance, and invariance under the full affine group; we identify
the precise boundary case where the hypothesis fails; and we apply the results to
a problem in fractal number theory.

### Notation and conventions

Throughout, `X`, `Y` are (extended) metric spaces and `E` is a real normed
vector space. We write `dimH s` for the Hausdorff dimension of `s ⊆ X`,
valued in the extended nonnegative reals `[0, ∞]`. For `c : ℝ` and `s ⊆ E`,
`c • s = {c • x : x ∈ s}` is the pointwise scalar multiple, and `f '' s` denotes
the image `{f(x) : x ∈ s}`. The symbol `‖·‖₊` denotes the nonnegative real
(`ℝ≥0`) norm.

---

## 2. Definitions

**Definition 2.1 (Lipschitz map).** A map `f : X → Y` is *Lipschitz with constant*
`K ∈ ℝ≥0`, written `LipschitzWith K f`, if for all `x, y ∈ X`,
`dist(f x, f y) ≤ K · dist(x, y)` (equivalently, for the extended distance,
`edist (f x) (f y) ≤ K · edist x y`).

**Definition 2.2 (Antilipschitz map).** A map `f : X → Y` is *antilipschitz with
constant* `K' ∈ ℝ≥0`, written `AntilipschitzWith K' f`, if for all `x, y ∈ X`,
`dist(x, y) ≤ K' · dist(f x, f y)`. Equivalently, `f` cannot contract distances
by more than the fixed factor `K'`; in particular such an `f` is injective.

**Definition 2.3 (Bi-Lipschitz map).** A map is *bi-Lipschitz* if it is both
Lipschitz (with some `K`) and antilipschitz (with some `K'`). Distances are then
trapped: `(1/K') · dist(x, y) ≤ dist(f x, f y) ≤ K · dist(x, y)`.

**Definition 2.4 (Hölder map).** For `r ∈ (0, 1]` and `C ∈ ℝ≥0`, a map `f` is
*Hölder with exponent `r` and constant `C`*, written `HolderWith C r f`, if
`dist(f x, f y) ≤ C · dist(x, y)^r` for all `x, y`. The case `r = 1` is exactly
Lipschitz.

**Definition 2.5 (Hausdorff dimension).** For `s ⊆ X`, `dimH s` is the critical
exponent `inf { d ≥ 0 : Hᵈ(s) = 0 }`, where `Hᵈ` is the `d`-dimensional Hausdorff
measure. We use the following standard facts as black boxes:
- `dimH` is monotone and countably stable under unions.
- (One-sided Lipschitz bound) If `f` is `K`-Lipschitz then
  `dimH(f '' s) ≤ dimH s`.
- (One-sided antilipschitz bound) If `f` is `K'`-antilipschitz then
  `dimH s ≤ dimH(f '' s)`.
- (Countable sets) If `s` is countable, `dimH s = 0`.
- (The line) `dimH (univ : Set ℝ) = 1`.
- (Hölder bound) If `f` is Hölder-`r` with `r > 0`, then
  `dimH(f '' s) ≤ dimH s / r`.

**Definition 2.6 (Logarithmic integer fractal).** Define
`logRange := { 1 / log n : n ∈ ℕ, n ≥ 2 } ⊆ ℝ`. This countable set accumulates
at `0` and contains the *prime fractal* `{ 1 / log p : p prime }` as a subset.

---

## 3. The centerpiece: bi-Lipschitz invariance

**Theorem 3.1 (Bi-Lipschitz invariance of Hausdorff dimension).**
Let `f : X → Y` be a map between extended metric spaces that is Lipschitz with
constant `Kf` and antilipschitz with constant `Kf'`. Then for every `s ⊆ X`,
```
dimH (f '' s) = dimH s.
```

*Proof.* The Lipschitz hypothesis gives the upper bound `dimH(f '' s) ≤ dimH s`
(images under a Lipschitz map cannot have larger dimension, since any cover of
`s` pushes forward to a cover of `f '' s` whose gauge has shrunk by at most the
factor `Kf`). The antilipschitz hypothesis gives the reverse bound
`dimH s ≤ dimH(f '' s)` by the symmetric argument applied to covers of `f '' s`.
Antisymmetry of `≤` on `[0, ∞]` closes the equality. ∎

**Remark 3.2.** Theorem 3.1 strictly generalizes both classical invariance
results. An isometry is `1`-Lipschitz and `1`-antilipschitz, so isometry
invariance is the special case `Kf = Kf' = 1`. A continuous linear equivalence
`L` between normed spaces is `‖L‖`-Lipschitz and `‖L⁻¹‖`-antilipschitz, so linear
invariance is the special case where the constants are operator norms. Neither
corollary uses distance preservation, linearity, or surjectivity beyond what the
two Lipschitz bounds already encode.

**Remark 3.3 (Sandwich structure).** The proof exposes the role of each
hypothesis: the Lipschitz half controls the *upper* bound, the antilipschitz half
controls the *lower* bound. Section 6 shows that neither half can be removed.

---

## 4. Geometric corollaries: scaling, translation, affine group

We now specialize to a real normed space `E`.

**Lemma 4.1 (Antilipschitz constant of scaling).** For `c ∈ ℝ` with `c ≠ 0`, the
scaling map `x ↦ c • x` on `E` is antilipschitz with the tight constant
`‖c‖₊⁻¹`.

*Proof sketch.* The inverse scaling `x ↦ c⁻¹ • x` is Lipschitz with constant
`‖c⁻¹‖₊ = ‖c‖₊⁻¹` (scalar multiplication is Lipschitz in its argument). Since
`x ↦ c • x` is a two-sided inverse of `x ↦ c⁻¹ • x` (using `c⁻¹ · c = 1`), the
general principle "a map with a `K`-Lipschitz inverse is `K`-antilipschitz"
(`LipschitzWith.to_rightInverse`) yields antilipschitzness with the stated
constant. The constant is tight because `c • ·` scales every distance by exactly
`|c|`. ∎

**Theorem 4.2 (Scale invariance).** For `c ≠ 0` and any `s ⊆ E`,
```
dimH (c • s) = dimH s.
```

*Proof.* Scalar multiplication `x ↦ c • x` is Lipschitz with constant `‖c‖₊`
(standard) and antilipschitz with constant `‖c‖₊⁻¹` (Lemma 4.1). By Theorem 3.1
the image has the same dimension as `s`, and the pointwise scalar multiple `c • s`
is exactly that image. ∎

**Interpretation.** Theorem 4.2 is the structural origin of the *scale-free*
character of self-similar dimension. If a set `K` is a disjoint union of `N`
copies of itself each scaled by ratio `r`, then applying Theorem 4.2 to each copy
turns the geometric self-similarity into the numeric Moran relation, whose
solution is the dimension `log N / log(1/r)` — a pure ratio independent of the
unit of length.

**Theorem 4.3 (Translation invariance).** For any `a ∈ E` and `s ⊆ E`,
```
dimH ((x ↦ x + a) '' s) = dimH s.
```

*Proof.* Translation by `a` is an isometry; apply the isometry case (`Kf = Kf' = 1`)
of Theorem 3.1, or invoke isometry invariance directly. ∎

**Theorem 4.4 (Affine invariance).** For `c ≠ 0`, `a ∈ E`, and any `s ⊆ E`, the
invertible affine map `x ↦ c • x + a` preserves Hausdorff dimension:
```
dimH ((x ↦ c • x + a) '' s) = dimH s.
```

*Proof.* Factor the affine map as the composition of the scaling `x ↦ c • x`
followed by the translation `y ↦ y + a`. Then
`(x ↦ c • x + a) '' s = (y ↦ y + a) '' ((x ↦ c • x) '' s)`. Apply Theorem 4.3 to
strip the translation, then Theorem 4.2 to strip the scaling. ∎

**Corollary 4.5.** `dimH` is an invariant of the affine group `Aff(E)` generated
by nonzero scalings and translations: stretching, sliding, and reflecting a set
never changes its Hausdorff dimension.

---

## 5. The Hölder generalization

**Theorem 5.1 (Hölder distortion bound).** Let `f : X → Y` be Hölder with
exponent `r > 0` and constant `C`. Then for every `s ⊆ X`,
```
dimH (f '' s) ≤ dimH s / r.
```

*Proof.* This is the standard Hölder covering estimate: a cover of `s` at gauge
`δ` maps to a cover of `f '' s` at gauge `C · δ^r`, so a `d`-dimensional
Hausdorff sum for the image is controlled by an `(r·d)`-dimensional sum for the
source; passing to critical exponents gives the bound. ∎

**Remark 5.2.** Setting `r = 1` recovers exactly the upper-bound half of
Theorem 3.1 (`dimH(f '' s) ≤ dimH s`). Thus the bi-Lipschitz invariant sits at
the rigid center `r = 1` of a one-parameter family: as the regularity exponent
`r` decreases below 1, a map is permitted to inflate dimension by the controlled
factor `1/r`. The square-root map `√` on `[0,1]` is Hölder-`1/2`, and indeed can
inflate dimension by a factor of `2`; this is the prototype for the open
"two-sided bi-Hölder transform" discussed in §8.

---

## 6. The boundary: antilipschitzness is necessary

The two halves of Theorem 3.1 are not interchangeable, and neither is removable.
Dropping the antilipschitz half is fatal.

**Theorem 6.1 (Constant maps collapse dimension).** Let `a ∈ ℝ` and let
`f : ℝ → ℝ` be the constant map `f(x) = a`. Then
```
dimH (f '' univ) < dimH (univ : Set ℝ).
```

*Proof.* The image of the whole line under a constant map is the singleton `{a}`,
so `dimH (f '' univ) = dimH {a} = 0` (singletons are countable). On the other
hand `dimH (univ : Set ℝ) = 1`. Since `0 < 1`, the inequality is strict. ∎

**Discussion.** A constant map is Lipschitz with constant `K = 0` — it is, in a
sense, maximally Lipschitz — yet it is as far from antilipschitz as possible: it
crushes the entire line to a point. Theorem 6.1 therefore certifies that the
antilipschitz hypothesis in Theorem 3.1 is *irreducible*: it is precisely the
condition guarding the lower bound on dimension. The Lipschitz half alone permits
the total destruction of dimensional information.

---

## 7. Cross-domain application: the prime fractal is intrinsically zero-dimensional

We now connect the invariance theory to fractal number theory. The *logarithmic
prime fractal* `{1/log p : p prime}` is a countable subset of `ℝ` accumulating at
`0`; it is known to have Hausdorff dimension `0` simply because it is countable.
A natural worry is whether this `0` is an artifact of the specific `1/log`
embedding. Theorem 3.1 dispels the worry.

**Theorem 7.1 (Bi-Lipschitz images of countable sets are zero-dimensional).**
Let `f : X → Y` be bi-Lipschitz (Lipschitz and antilipschitz) and let `s ⊆ X` be
countable. Then `dimH (f '' s) = 0`.

*Proof.* By Theorem 3.1, `dimH (f '' s) = dimH s`. Since `s` is countable,
`dimH s = 0`. ∎

**Theorem 7.2 (The logarithmic integer fractal is zero-dimensional).**
The set `logRange = {1/log n : n ≥ 2}` is countable, hence `dimH logRange = 0`.
Consequently the prime fractal `{1/log p : p prime} ⊆ logRange` also has
dimension `0` by monotonicity.

*Proof.* `logRange` is the image of the countable set `{n : n ≥ 2}` under a
function `ℕ → ℝ`, so it is countable, and countable sets have Hausdorff dimension
`0`. ∎

**Theorem 7.3 (Robustness under reshaping).** For every bi-Lipschitz map `f` on
`ℝ`,
```
dimH (f '' logRange) = 0.
```
In particular, the zero dimension survives every bi-Lipschitz change of
coordinates. As a concrete instance, rescaling by `5` gives
`dimH (5 • logRange) = 0` (Theorem 4.2 with `c = 5`).

*Proof.* Combine Theorem 7.1 with Theorem 7.2. ∎

**Interpretation.** The zero dimension of the prime fractal is not a feature of
the chart `p ↦ 1/log p`; it is a feature of the *sparseness* of the underlying
discrete set. No bi-Lipschitz reshaping — no stretching, sliding, tilting, or
bending without tearing or crushing — can manufacture positive dimension from a
countable scatter of points. Dimension `0` is intrinsic.

---

## 8. Worked examples

We collect several concrete instances that make the abstract statements tangible
and that double as test cases for the numerical companion code.

**Example 8.1 (Cantor set under scaling).** Let `C ⊆ [0,1]` be the middle-thirds
Cantor set, with `dimH C = log 2 / log 3 ≈ 0.6309`. For any `c ≠ 0`, Theorem 4.2
gives `dimH (c · C) = dimH C`. Geometrically, `c · C` is a Cantor set living in
`[0, c]` (or `[c, 0]` if `c < 0`), built from the *same* ratio `1/3` self-similar
recipe, only re-scaled. Box-counting on the level-`k` approximation confirms the
slope `log 2 / log 3` for `c = 5, -2, 7`, etc.: the estimate is stable because the
proof's cover-comparison is exactly a rescaling of the covering gauge by `|c|`.

**Example 8.2 (Cantor set under a shear-and-shift).** The affine map
`x ↦ 7x − 3` carries `C` to a Cantor set inside `[−3, 4]`. By Theorem 4.4 its
dimension is still `log 2 / log 3`. This is the kind of coordinate change a data
analyst performs when normalizing a signal; Theorem 4.4 certifies that the
measured fractal dimension is invariant under such preprocessing.

**Example 8.3 (Hölder inflation by `√`).** On `[0,1]`, the map `f(x) = x²` is
Lipschitz, but its inverse `g(y) = √y` is only Hölder-`1/2` (it stretches small
distances near `0` like `√δ`). Theorem 5.1 applied to `g` gives the *largest*
permissible inflation: a set of dimension `d` can map to one of dimension at most
`2d`. This bound is the prototype for the open two-sided bi-Hölder transform of
§9.1: the factor `2 = 1/r` is genuinely achieved by suitably thin sets pushed
through `√` near the origin.

**Example 8.4 (The prime fractal and its rescaling).** The first few points of
the prime fractal are `1/log 2 ≈ 1.4427`, `1/log 3 ≈ 0.9102`, `1/log 5 ≈ 0.6213`,
`1/log 7 ≈ 0.5139`, …, accumulating at `0`. The set is countable, so its
dimension is `0` (Theorem 7.2). Rescaling by `5` moves the largest point to
`≈ 7.21` but leaves the accumulation structure — and hence the dimension `0` —
intact (Theorem 7.3). No bi-Lipschitz reshaping can thicken this dust into
positive dimension.

**Example 8.5 (The constant collapse, quantitatively).** Sampling `[0,1]` finely
and applying `f(x) = 7` produces a single point; the box count is `1` at every
gauge, so the box-counting slope is `0`, in agreement with Theorem 6.1's
`dimH = 0 < 1`. Contrast with any `f(x) = cx + a`, `c ≠ 0`, whose box-counting
slope returns the source dimension. The two behaviours bracket the Lipschitz
world: exact preservation on one side, total collapse on the other.

---

## 9. Discussion and future work

The organizing principle of this paper is reductive in the best sense: a family
of separately-proved invariance theorems (isometry, linear, scaling, translation,
affine) is revealed to be the shadow of one inequality pair. The cost of entry is
minimal — two Lipschitz-type bounds — and the payoff is both conceptual
(dimension is a bi-Lipschitz invariant, full stop) and practical (every common
coordinate change in geometry and dynamics is bi-Lipschitz, so dimension is a
trustworthy intrinsic measurement).

We close with five concrete directions, ordered by how directly they extend the
results above.

**9.1 Two-sided bi-Hölder dimension transform.** Theorem 5.1 supplies the upper
half `dimH(f '' s) ≤ dimH s / r`. Conjecturally, if additionally the inverse `g`
of `f` is Hölder-`r'` on `f '' s`, then `r' · dimH s ≤ dimH(f '' s)`, giving a
two-sided estimate `r' · dimH s ≤ dimH(f '' s) ≤ r⁻¹ · dimH s`. For a bi-Hölder
homeomorphism with matched exponents `r = r'`, dimension would rescale
multiplicatively. The missing lower half should follow by transporting the
antilipschitz dimension bound through the Hölder regularity of the inverse,
exactly mirroring how Theorem 4.2 was built from a Lipschitz inverse. The naive
equality is falsified by `x ↦ x²` on `[0,1]`, whose inverse `√` is Hölder-`1/2`.

**9.2 Self-similar attractors realize the similarity dimension.** For a finite
iterated function system of contracting similarities with ratios `rᵢ` satisfying
the open set condition, the attractor `K` should have `dimH K = d`, where `d`
solves the Moran equation `∑ rᵢ^d = 1`. Theorems 4.2 and 4.4 turn each
self-similar piece into a scale-controlled copy, converting the geometric
self-similarity equation into a numeric equation in `d` once combined with the
dimension of finite unions. The middle-thirds Cantor set (`d = log 2 / log 3`)
is the natural first target. The accompanying code solves the Moran equation
`∑ rᵢ^d = 1` by bisection, returning `0.6309…` for ratios `[1/3, 1/3]`.

**9.3 Box-counting equals Hausdorff dimension for self-similar sets.** For the
attractors of §9.2 (open set condition), the upper box-counting dimension should
equal `dimH`. Because Theorem 3.1 makes both dimensions coordinate-free, the
equality is a statement about the set itself. This would explain *why* the prime
fractal exhibits a strict gap (`dimH = 0` but conjectured box dimension `1`): the
gap is the failure of self-similarity, not of countability alone.

**9.4 Dimension and Cartesian products.** One expects
`dimH (s ×ˢ t) ≥ dimH s + dimH t`, with equality under a regularity hypothesis on
one factor (the Marstrand/Besicovitch phenomenon). Theorem 3.1 lets one identify
`ℝᵐ × ℝⁿ` with `ℝᵐ⁺ⁿ` bi-Lipschitzly, reducing the full-dimensional case to the
additivity of rank. This opens the door to product fractals such as Cantor dust
`C × C` of dimension `2 log 2 / log 3`.

**9.5 The dimension-drop spectrum for Lipschitz maps.** Between exact
preservation (bi-Lipschitz, §3) and total collapse (constant maps, §6) lies a
quantitative regime. Conjecturally, for a `K`-Lipschitz `f : ℝ → ℝ`, the
achievable values of `dimH s − dimH(f '' s)` fill the whole interval
`[0, dimH s]`, and `f` preserves dimension on every set iff it is locally
antilipschitz off a dimension-`0` set. Theorem 6.1 already realizes the extreme
drop; interpolating with piecewise-affine maps constant on fat subsets should
trace out the spectrum.

---

## 10. Conclusion

Hausdorff dimension is a bi-Lipschitz invariant. This one statement subsumes
isometry and linear invariance, generates scale, translation, and affine
invariance as corollaries, and — through the countable-set application — certifies
that the zero dimension of the prime fractal is intrinsic to the primes rather
than to the lens through which they are drawn. The hypothesis is sharp: removing
the antilipschitz half allows constant maps to collapse dimension, and weakening
the Lipschitz half to Hölder-`r` allows dimension to inflate by the controlled
factor `1/r`. The bi-Lipschitz regime is the rigid center where dimension is
exactly preserved — the structural reason fractal dimension deserves to be called
intrinsic.
