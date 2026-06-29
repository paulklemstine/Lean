# Set-Local Distortion of Hausdorff Dimension

## Abstract

The Hausdorff dimension is the canonical scale-invariant measure of the
"roughness" or fractal complexity of a subset of a metric space. Its behavior
under maps is governed by two complementary distortion principles: Lipschitz maps
cannot increase dimension, and antilipschitz maps cannot decrease it. These two
principles are, however, not stated at the same level of generality. The
upper-bound principle has a fully *set-local* form — it suffices for the map to be
Lipschitz on the set under consideration — whereas the lower-bound principle is
classically available only in a *global* form, requiring the map to be
antilipschitz on the entire ambient space. This asymmetry prevents the natural
conclusion that a map which reversibly deforms a set, while behaving arbitrarily
elsewhere, preserves that set's dimension.

We close the gap. We introduce the predicate `AntilipschitzOnWith K f s`,
asserting that a map `f` is `K`-antilipschitz when restricted to a set `s`, and we
prove the **set-local antilipschitz dimension lower bound**: if `f` is
antilipschitz on `s`, then `dimH(s) ≤ dimH(f(s))`. The proof proceeds by a
*subtype reduction*: on the subtype `s`, equipped with the induced metric,
set-local antilipschitzness becomes global antilipschitzness, the classical global
bound applies, and the conclusion is transported back along the isometric
inclusion `s ↪ X`. Combining this lower bound with the existing set-local upper
bound yields **set-local bilipschitz invariance** and **set-local isometry
invariance** of Hausdorff dimension. We also record the structural fact that a
set-locally antilipschitz map is injective on the set. All results are stated for
extended-metric (`EMetric`) spaces and hold without any global hypotheses on the
map.

**Keywords:** Hausdorff dimension, fractal geometry, antilipschitz maps,
bilipschitz invariance, metric geometry, set-local distortion.

---

## 1. Introduction

### 1.1 Hausdorff dimension and distortion

For a metric space `X` and a subset `s ⊆ X`, the *Hausdorff dimension* `dimH(s)`
is defined through the family of `d`-dimensional Hausdorff (outer) measures
`μ_H^d`. As `d` increases, `μ_H^d(s)` jumps from `+∞` to `0` at a single critical
value, and that critical value is the Hausdorff dimension:

> `dimH(s) = sup { d ≥ 0 : μ_H^d(s) = +∞ } = inf { d ≥ 0 : μ_H^d(s) = 0 }.`

It generalizes the topological notion of dimension, agreeing with it on smooth
objects (a curve has dimension 1, a surface dimension 2) but taking fractional
values on self-similar fractals such as the Cantor set (`log 2 / log 3 ≈ 0.6309`),
the Koch curve (`log 4 / log 3 ≈ 1.2619`), and the Sierpiński triangle
(`log 3 / log 2 ≈ 1.585`).

The central question of distortion theory is how `dimH` transforms under maps. Two
quantitative Lipschitz-type conditions provide sharp control.

**Lipschitz (no excessive expansion).** A map `f : X → Y` is *`K`-Lipschitz on
`s`*, written `LipschitzOnWith K f s`, if
`edist(f x, f y) ≤ K · edist(x, y)` for all `x, y ∈ s`.

**Antilipschitz (no excessive contraction).** A map `f : X → Y` is *globally
`K`-antilipschitz*, written `AntilipschitzWith K f`, if
`edist(x, y) ≤ K · edist(f x, f y)` for all `x, y ∈ X`.

(Throughout we work with the *extended distance* `edist` valued in `ℝ≥0∞`, the
natural setting for Hausdorff measure; `NNReal` constants `K` are written `K`.)

The classical distortion principles are:

> **(U) Upper bound.** `LipschitzOnWith K f s ⟹ dimH(f(s)) ≤ dimH(s)`.
>
> **(L) Lower bound.** `AntilipschitzWith K f ⟹ dimH(s) ≤ dimH(f(s))`.

### 1.2 The asymmetry

Principle (U) is *set-local*: its hypothesis constrains `f` only on `s`. This is
correct and unavoidable — `dimH(f(s))` depends on `f` only through its values on
`s`. Principle (L), however, is classically packaged with a *global* hypothesis:
`f` must be antilipschitz on all of `X`. This is strictly stronger than needed. The
value `dimH(f(s))` is again determined by `f|_s`, so the lower bound *ought* to
require only that `f` be antilipschitz on `s`.

The practical cost of the asymmetry is real. Consider a map that reversibly
reshapes a fractal `s` but, outside `s`, collapses distinct points or contracts
violently. Such a map is not globally antilipschitz, so (L) does not apply, and one
cannot conclude `dimH(s) ≤ dimH(f(s))` — even though, intuitively and in truth,
the dimension of `s` is untouched. Consequently the desired conclusion that a
*locally bilipschitz* map preserves dimension is unavailable from (U) and (L) as
stated.

### 1.3 Contribution

We restore the symmetry. The contributions are:

1. **Definition.** A set-local antilipschitz predicate `AntilipschitzOnWith K f s`,
   the companion of the set-local `LipschitzOnWith`.
2. **Headline theorem.** The set-local lower bound
   `AntilipschitzOnWith K f s ⟹ dimH(s) ≤ dimH(f(s))`, strictly generalizing (L).
3. **Invariance.** Set-local bilipschitz invariance
   `dimH(f(s)) = dimH(s)` for maps Lipschitz-and-antilipschitz on `s`, and its
   isometry corollary.
4. **Structure.** Injectivity on `s` of a set-locally antilipschitz map, plus a
   small supporting API (monotonicity in the set, specialization from the global
   predicate, and the subtype-reduction lemma).

The unifying technical device is a **subtype reduction**, explained in Section 4,
which converts every set-local distortion statement into the corresponding global
statement on the metric subspace `s`. Because the extended distance on the subtype
is *definitionally* the ambient one, the reduction is essentially free, and the
transport back to `X` uses only that the inclusion `s ↪ X` is an isometry.

---

## 2. Setting and notation

We fix two extended-metric spaces `X` and `Y` (`EMetricSpace X`,
`EMetricSpace Y`). Distances are extended-valued, `edist : X → X → ℝ≥0∞`. Constants
`K, K' : ℝ≥0` are nonnegative reals. We write `f : X → Y` for a map and
`s, t : Set X` for subsets, and `f '' s` for the image of `s` under `f`.

For a set `s : Set X`, the *subtype* `↥s` (written `s` when unambiguous) is the
type of pairs `⟨x, hx⟩` with `x ∈ s`, carrying the induced extended-metric
structure. The key fact we exploit is:

> **(Sub)** For `x, y : ↥s`, `edist x y = edist x.val y.val`,

i.e. the subtype distance *is* the ambient distance of the underlying points; the
inclusion `Subtype.val : ↥s → X` is an isometric embedding, `isometry_subtype_coe`.

We rely on the following results from the standard theory of Hausdorff dimension:

- `LipschitzOnWith.dimH_image_le` : `LipschitzOnWith K f s → dimH (f '' s) ≤ dimH s`.
  *(set-local upper bound)*
- `AntilipschitzWith.le_dimH_image` : `AntilipschitzWith K f → dimH s ≤ dimH (f '' s)`.
  *(global lower bound)*
- `Isometry.dimH_image` : an isometry preserves the Hausdorff dimension of images.
- `isometry_subtype_coe` : `Subtype.val : ↥s → X` is an isometry.
- `Subtype.coe_image_univ` : `Subtype.val '' (univ : Set ↥s) = s`.

---

## 3. The set-local antilipschitz predicate

### 3.1 Definition

> **Definition 3.1 (`AntilipschitzOnWith`).** For `K : ℝ≥0`, `f : X → Y`, and
> `s : Set X`, define
>
> `AntilipschitzOnWith K f s  :⟺  ∀ x ∈ s, ∀ y ∈ s, edist x y ≤ K · edist (f x) (f y).`

This is the exact set-local mirror of `LipschitzOnWith`, and the natural companion
that the standard library lacked: the global predicate `AntilipschitzWith K f`
quantifies over *all* `x, y : X`, whereas `AntilipschitzOnWith K f s` restricts the
quantifiers to `s`.

### 3.2 Elementary properties

> **Proposition 3.2 (Specialization).**
> `AntilipschitzWith K f → AntilipschitzOnWith K f s` for every `s`.
>
> *Proof.* The global inequality holds for all points, in particular for points of
> `s`. ∎

> **Proposition 3.3 (Monotonicity).**
> If `AntilipschitzOnWith K f s` and `t ⊆ s`, then `AntilipschitzOnWith K f t`.
>
> *Proof.* Membership in `t` implies membership in `s` by `t ⊆ s`; apply the
> hypothesis to the included points. ∎

> **Proposition 3.4 (Injectivity on the set).**
> `AntilipschitzOnWith K f s → Set.InjOn f s`.
>
> *Proof.* Let `x, y ∈ s` with `f x = f y`. Then `edist (f x) (f y) = 0`, so the
> defining inequality gives `edist x y ≤ K · 0 = 0`, hence `edist x y = 0` and
> therefore `x = y` (`edist_le_zero`). ∎

Proposition 3.4 is the qualitative shadow of the quantitative no-contraction
condition: a map that never crushes distances can never identify two distinct
points of `s`.

---

## 4. The subtype reduction

The engine of the paper is the observation that set-local antilipschitzness on `s`
*is* global antilipschitzness on the metric subspace `↥s`.

> **Lemma 4.1 (Subtype reduction).** If `AntilipschitzOnWith K f s`, then the
> restricted map
> `f̃ : ↥s → Y,  f̃ ⟨x, hx⟩ = f x`
> is *globally* antilipschitz: `AntilipschitzWith K f̃`.
>
> *Proof.* Let `x, y : ↥s`. By (Sub), `edist x y = edist x.val y.val` and
> `edist (f̃ x) (f̃ y) = edist (f x.val) (f y.val)`. Applying the hypothesis to the
> points `x.val, y.val ∈ s` gives
> `edist x.val y.val ≤ K · edist (f x.val) (f y.val)`,
> which is exactly the global antilipschitz inequality for `f̃`. ∎

The proof is "essentially free" precisely because of (Sub): no distances are
recomputed, only re-read. This lemma is the reusable template for *every*
set-local distortion statement: define the set-local predicate, restrict to the
subtype to obtain the global predicate, invoke the global theorem, and transport.

---

## 5. Main results

### 5.1 The headline lower bound

> **Theorem 5.1 (Set-local antilipschitz lower bound).**
> If `AntilipschitzOnWith K f s`, then `dimH s ≤ dimH (f '' s)`.

*Proof sketch.* Let `f̃ : ↥s → Y` be the subtype restriction from Lemma 4.1, which
is globally `K`-antilipschitz. The global lower bound `AntilipschitzWith.le_dimH_image`
applied to `f̃` and the set `univ : Set ↥s` yields

> `dimH (univ : Set ↥s) ≤ dimH (f̃ '' univ)`.

It remains to identify the two sides with `dimH s` and `dimH (f '' s)`.

- *Right side.* `f̃ '' univ = { f x.val : x ∈ univ } = f '' s` because the
  underlying points `x.val` range over exactly `s` (using `Subtype.coe_image_univ`).
  Hence `dimH (f̃ '' univ) = dimH (f '' s)`.

- *Left side.* The inclusion `ι = Subtype.val : ↥s → X` is an isometry
  (`isometry_subtype_coe`), and isometries preserve the Hausdorff dimension of
  images (`Isometry.dimH_image`). Thus
  `dimH (univ : Set ↥s) = dimH (ι '' univ) = dimH s`,
  again using `ι '' univ = s` (`Subtype.coe_image_univ`).

Substituting both identifications into the inequality gives
`dimH s ≤ dimH (f '' s)`. ∎

Theorem 5.1 strictly contains the global principle (L): if `f` is globally
antilipschitz, Proposition 3.2 supplies `AntilipschitzOnWith K f s` for every `s`,
recovering `dimH s ≤ dimH (f '' s)`. The converse fails — `f` may contract or even
collapse points *outside* `s` and the bound still holds — so the gain is genuine.

### 5.2 Set-local bilipschitz invariance

Pairing Theorem 5.1 with the set-local upper bound yields exact preservation.

> **Theorem 5.2 (Set-local bilipschitz invariance).**
> If `LipschitzOnWith K f s` and `AntilipschitzOnWith K' f s`, then
> `dimH (f '' s) = dimH s`.
>
> *Proof.* The upper bound `LipschitzOnWith.dimH_image_le` gives
> `dimH (f '' s) ≤ dimH s`; Theorem 5.1 gives `dimH s ≤ dimH (f '' s)`. Antisymmetry
> of `≤` concludes. ∎

This is the precise statement that Hausdorff dimension is a *set-local bilipschitz
invariant*, not merely a global one — the conceptual payload of the development.

### 5.3 Set-local isometry invariance

The cleanest specialization is to distance-preserving maps on `s`.

> **Lemma 5.3 (Isometry-on is bilipschitz-on).**
> If `edist (f x) (f y) = edist x y` for all `x, y ∈ s`, then
> `LipschitzOnWith 1 f s` and `AntilipschitzOnWith 1 f s`.
>
> *Proof.* With `K = 1`, both `edist (f x) (f y) ≤ 1 · edist x y` and
> `edist x y ≤ 1 · edist (f x) (f y)` are equalities under the hypothesis. ∎

> **Theorem 5.4 (Set-local isometry invariance).**
> If `edist (f x) (f y) = edist x y` for all `x, y ∈ s`, then
> `dimH (f '' s) = dimH s`.
>
> *Proof.* Apply Lemma 5.3 and then Theorem 5.2. ∎

Theorem 5.4 is the set-local form of the classical fact that isometries preserve
Hausdorff dimension; here `f` need only be an isometry *on `s`*, with no constraint
elsewhere.

---

## 5.4 Worked examples

To make the statements concrete, we record several illustrative instances over the
Euclidean plane `ℝ²` with the usual metric (a special case of an `EMetricSpace`),
taking `s` to be a fractal such as the Sierpiński gasket `G` (`dimH G = log 3 / log 2`).

**Example A (rotation, isometry-on).** Let `f` be rotation by any angle `θ`. Then
`dist(f x, f y) = dist(x, y)` everywhere, in particular on `G`, so the hypothesis of
Theorem 5.4 holds with equality. Conclusion: `dimH(f(G)) = dimH(G) = log 3 / log 2`.
The rotated gasket has exactly the same fractal complexity, as expected.

**Example B (anisotropic scaling, bilipschitz-on).** Let
`f(x, y) = (a x, b y)` with `a, b > 0`. For all points,
`min(a, b) · dist(p, q) ≤ dist(f p, f q) ≤ max(a, b) · dist(p, q)`. Hence `f` is
Lipschitz-on `G` with `K = max(a, b)` and antilipschitz-on `G` with
`K' = 1 / min(a, b)`. By Theorem 5.2, `dimH(f(G)) = dimH(G)`, even though `f` distorts
shapes and is not an isometry. Stretching a fractal unevenly changes its appearance but
not its dimension.

**Example C (shear, bilipschitz-on).** Let `f(x, y) = (x + c y, y)`. The matrix has
determinant `1` and finite operator norm, so `f` is bilipschitz globally and, a fortiori,
bilipschitz-on `G`; Theorem 5.2 again gives `dimH(f(G)) = dimH(G)`.

**Example D (the decisive case: collapse off `s`).** Define `f` to equal a rotation on
the unit square (which contains `G`) but to send *every* point outside the square to a
single fixed point `o`. Globally `f` collapses infinitely many distinct pairs to
distance `0`, so it is **not** antilipschitz on `ℝ²`, and the classical global lower
bound (L) does not apply. Yet on `G` itself `f` coincides with the rotation, hence is an
isometry-on `G`. Theorem 5.4 therefore still yields `dimH(f(G)) = dimH(G)`. This is the
example that the global theory cannot reach and the set-local theory handles cleanly; it
is the conceptual reason the localization matters.

**Example E (non-applicability witness).** Let `f(x, y) = (x, 0)` be orthogonal
projection onto the `x`-axis. On `G`, `f` collapses any two points with the same
`x`-coordinate, so `f` is *not* antilipschitz on `G` (no finite `K'` exists) and is not
injective on `G` (contrapositive of Proposition 3.4). The lower bound does not apply, and
indeed projection can lower dimension. This shows the antilipschitz-on hypothesis is not
vacuous: it is exactly what rules out dimension-collapsing maps.

---

## 6. Algorithms and computation

Although the theorems are qualitative, they license concrete *numerical*
workflows: when one verifies a finite-sample bilipschitz-on bound, one obtains a
certified two-sided sandwich on the dimension. We isolate two reusable
computational procedures.

### 6.1 Empirical distortion constants

Given a finite sample `P = {p_1, …, p_n} ⊆ s` and a map `f`, the smallest valid
Lipschitz-on and antilipschitz-on constants *on the sample* are the extremal ratios
of pairwise distances:

> `K_Lip   = max_{i<j}  d(f p_i, f p_j) / d(p_i, p_j)`
> `K_anti  = max_{i<j}  d(p_i, p_j)   / d(f p_i, f p_j)`

If both are finite, the sample exhibits bilipschitz-on behavior with constants
`(K_Lip, K_anti)`; by Theorem 5.2 the limiting set's dimension is preserved when
these constants remain bounded as the sample refines. The procedure runs in
`O(n²)` distance evaluations.

### 6.2 Box-counting dimension estimate

Hausdorff dimension is computationally delicate, but for self-similar fractals it
coincides with the *box-counting dimension*, estimated from the slope of
`log N(ε)` against `log(1/ε)`, where `N(ε)` is the number of grid boxes of side `ε`
meeting the set. Comparing the estimate before and after applying a verified
bilipschitz-on map provides an empirical check of Theorems 5.2 and 5.4.

Pseudocode and reference implementations of both procedures are provided in the
accompanying demonstration code.

---

## 7. Applications

- **Texture analysis (imaging).** Fractal dimension is a texture descriptor:
  rough textures (bark, sand, trabecular bone, tumor margins) score higher than
  smooth ones. Theorems 5.2 and 5.4 certify that geometric re-registration which is
  bilipschitz *only on the analyzed patch* leaves the descriptor invariant — global
  good behavior of the warp is not required.

- **Strange attractors (dynamics).** The dimension of a chaotic attractor is a
  fundamental complexity diagnostic. Coordinate changes, Poincaré sections, and
  projections are reliable only near the attractor. The set-local invariance
  principle is exactly the license needed to call the measured dimension
  coordinate-independent.

- **Intrinsic dimension (data science).** Datasets concentrated on a curved
  manifold have an intrinsic dimension estimated via dimension-like statistics.
  Feature maps and embeddings are, at best, bilipschitz on the data manifold;
  Theorem 5.2 guarantees the estimate is stable under such maps.

---

## 8. Discussion

The mathematical content of the work is the recognition that the lower-bound
distortion principle was packaged with an unnecessarily global hypothesis, and the
correction of that mismatch via the right definition and the right reduction. The
subtype reduction of Section 4 is more than a proof trick: it is a *design
pattern*. Any distortion statement currently available only in global form —
Hölder lower bounds, Assouad-type estimates, conformal dimension comparisons — can
in principle be localized by the same three-step recipe (restrict to the subtype,
apply the global theorem, transport along the isometric inclusion), provided the
corresponding global theorem and the definitional `edist` identification (Sub) are
in place.

A subtlety worth flagging: the development is carried out for extended-metric
spaces, so distances may be `+∞`. This is the correct generality for Hausdorff
measure and means the results apply to disconnected and unbounded configurations
without special casing. The constants `K, K'` are genuine `NNReal` values; the
isometry results are the `K = 1` corner.

---

## 9. Future directions

### Direction 1 — Set-local Hölder lower bound (`AntiholderOnWith`)

The set-local upper bound `HolderOnWith.dimH_image_le` gives
`dimH (f '' s) ≤ dimH s / r` for a Hölder-on map with exponent `r`. The matching
lower bound should read: if `f` satisfies a *reverse* Hölder estimate on `s`,
`edist x y ≤ C · edist (f x) (f y) ^ r` for all `x, y ∈ s`, then
`dimH s ≤ dimH (f '' s) / r`, equivalently `r · dimH s ≤ dimH (f '' s)`. The same
subtype reduction applies verbatim once `AntiholderOnWith` is defined, reducing the
set-local statement to a global reverse-Hölder dimension bound. The isometric
inclusion transport is already in place; the only new ingredient is the
reverse-Hölder measure estimate, making this the lowest-hanging generalization.

### Direction 2 — Exact dimension via two-sided localization

With both a set-local Hölder upper bound and a set-local reverse-Hölder lower
bound, one obtains exact `dimH` transformation laws for quasiconformal and
snowflake-type maps localized to a set, unifying the bilipschitz corner (`r = 1`)
with genuinely fractional distortion exponents.

### Further directions

- **Set-local Assouad and conformal dimension** via the same reduction pattern.
- **Measure-level localization:** set-local versions of `hausdorffMeasure_image`
  comparisons, beyond the dimension shadow.
- **Quantitative injectivity:** modulus-of-injectivity refinements of Proposition
  3.4 with explicit separation bounds in terms of `K`.

---

## 10. Conclusion

By introducing the set-local antilipschitz predicate `AntilipschitzOnWith` and
proving `dimH s ≤ dimH (f '' s)` from it, we have restored the missing symmetry in
the distortion theory of Hausdorff dimension: both the upper and lower bounds are
now available in set-local form. The immediate consequences — set-local
bilipschitz and isometry invariance — formalize the intuition that the fractal
roughness of a set is intrinsic to the set, depending only on the map's behavior
on the set itself and on nothing in the surrounding space. The subtype-reduction
technique that powers the proofs is a reusable template for localizing the broader
family of metric distortion theorems.
