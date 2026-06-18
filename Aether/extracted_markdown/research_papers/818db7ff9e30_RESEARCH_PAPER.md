# The Interleaving Metric is Geodesic: Constant-Speed Convex Paths in the Space of Filtrations

*Boltzmann Bridge IX*

## Abstract

The interleaving distance is the canonical metric of topological data analysis, governing the stability of persistent homology under perturbation of input data. While its metric structure on the space of filtrations is by now well understood — it is an extended pseudometric, separates points after closure, and is isometric to a supremum-of-coordinates ("sup") distance on weight functions — its *geometric* structure as a length space has remained unexamined in formalized form. This paper supplies the missing layer. We define the **convex-interpolation path** `lerp F G t` between two filtrations `F` and `G`, whose weight on each simplex is the convex combination `(1 − t)·F.weight σ + t·G.weight σ`, and we prove it is a valid filtration for every `t ∈ [0, 1]`. Our central result is the **constant-speed geodesic identity**

> `d(lerp F G s, lerp F G t) = |s − t| · d(F, G)`,

which establishes that `(Filtration α, d)` is a geodesic metric space and that convex interpolation is a constant-speed geodesic realizing the interleaving distance. We derive the linear endpoint law `d(F, lerp F G t) = t · d(F, G)` and the additive midpoint bisection `d(F, m) + d(m, G) = d(F, G)`. All results are fully formalized and machine-checked, depending only on the standard foundational axioms. We close with a program of conjectures — contractibility of the path space, classification of geodesics, geodesic convexity of the Vietoris–Rips locus, non-positive curvature, and a rigidity characterization of the sup-metric — that the identity makes precisely formulable.

**Keywords:** topological data analysis, persistent homology, interleaving distance, geodesic metric space, filtrations, convex interpolation, stability.

---

## 1. Introduction

Persistent homology summarizes a dataset as a *filtration*: a one-parameter increasing family of combinatorial objects indexed by a scale parameter, recording at what scale each topological feature appears. The comparison of two such summaries is governed by the **interleaving distance**, introduced by Chazal, Cohen-Steiner, Glisse, Guibas, and Oudot, whose defining property — the *stability theorem* — guarantees that the persistence summary is a 1-Lipschitz function of the input. This stability is the reason persistent homology is usable in practice: it certifies that noise in the data produces only proportional noise in the output.

The interleaving distance is, however, defined by an optimization that is awkward to manipulate directly: a shift `δ` *interleaves* two filtrations when sliding the scale of one by `δ` makes it contain the other, in both directions, at every scale, and the distance is the infimum of admissible shifts. The earlier installments of this development (the *Boltzmann Bridge*) progressively tamed this object:

- **(IV) Relational layer.** The interleaving relation `Interleaved F G δ` was established as a preorder-like structure (reflexive, symmetric, monotone in `δ`, and triangle-composable).
- **(V) Metric layer.** Moving the codomain to the extended reals `ℝ≥0∞ = [0,∞]` repaired the triangle inequality (the real-valued version failed because the empty infimum collapses to `0` in `ℝ`), yielding a genuine `PseudoEMetricSpace`.
- **(VII) Separation layer.** The infimum is attained at `0` exactly when the weight functions agree, upgrading the structure to a true extended metric.
- **(VIII) Isometry layer.** The interleaving distance was identified *exactly* with the sup-distance of weight functions:
  `d(F, G) = ⨆_σ |F.weight σ − G.weight σ|`.

The present work (IX) adds the **geometric** layer. A metric space being *geodesic* — every pair of points joined by a shortest path, traversable at constant speed — is a strictly stronger and more useful property than being merely a metric space. It is the gateway to homotopy theory, curvature, and optimization on the space itself. We prove that the space of filtrations under the interleaving distance is geodesic, exhibit the explicit geodesics (plain convex interpolation), and establish their constant-speed character.

---

## 2. Preliminaries and definitions

Throughout, `α` is an arbitrary type whose finite subsets index *simplices*; `Finset α` denotes the type of finite subsets.

### 2.1 Filtrations

**Definition 2.1 (Filtration).** A *filtration* on `α` is a structure consisting of a weight function `weight : Finset α → ℝ` subject to two axioms:

- **Grounding:** `weight ∅ ≤ 0`.
- **Monotonicity:** for all `σ τ : Finset α`, if `σ ⊆ τ` then `weight σ ≤ weight τ`.

We write `Filtration α` for the type of filtrations. The weight `F.weight σ` is interpreted as the *birth scale* of the simplex `σ`.

**Definition 2.2 (Sublevel complex).** For a filtration `F` and a scale `t : ℝ`,
`F.sublevelFaces t := { σ : Finset α | F.weight σ ≤ t }`
is the set of simplices alive by scale `t`. Monotonicity makes each `sublevelFaces t` downward-closed, hence an abstract simplicial complex (for `t ≥ 0`, when `∅` is born).

**Lemma 2.3 (Extensionality).** A filtration is determined by its weight: if `F.weight = G.weight` then `F = G`. *(`ext_weight`.)*

### 2.2 The Vietoris–Rips filtration

**Definition 2.4 (Diameter weight).** When `α` carries a metric, the *diameter weight* of a simplex `σ` is the largest pairwise distance among its vertices,
`diamWeight σ := sup' ( {0} ∪ { dist(p, q) : (p, q) ∈ σ × σ } )`,
taking the value `0` on the empty simplex and singletons. The diameter weights assemble into the **Vietoris–Rips filtration** `diamFiltration`, whose grounding is immediate and whose monotonicity follows because enlarging `σ` only adds pairwise distances to the supremum. This is the canonical functor `(\text{point cloud}) \mapsto (\text{filtration})`.

### 2.3 Interleaving and the interleaving distance

**Definition 2.5 (Interleaving).** For `δ : ℝ`, filtrations `F` and `G` are *`δ`-interleaved*, written `Interleaved F G δ`, when `0 ≤ δ` and, for every scale `t`,
`F.sublevelFaces t ⊆ G.sublevelFaces (t + δ)` and `G.sublevelFaces t ⊆ F.sublevelFaces (t + δ)`.

**Definition 2.6 (Interleaving distance).** The *extended interleaving distance* is the infimum of admissible shifts,
`d(F, G) := ⨅ { ENNReal.ofReal δ : Interleaved F G δ } ∈ ℝ≥0∞`,
with the convention that an empty index set yields `⊤ = ∞` (no finite interleaving). This `d` is a genuine extended pseudometric, and an extended metric on the point-separated space.

### 2.4 The isometry formula (Bridge VIII)

**Definition 2.7 (Weight sup-distance).** The *extended sup-distance* of two filtrations' weights is
`weightSupEDist F G := ⨆_σ ENNReal.ofReal |F.weight σ − G.weight σ|`.

**Theorem 2.8 (Isometry — Bridge VIII).** For all `F G : Filtration α`,
`d(F, G) = weightSupEDist F G = ⨆_σ ENNReal.ofReal |F.weight σ − G.weight σ|`.
*(`eInterleavingDist_eq_weightSupEDist`.)*

Theorem 2.8 is the engine of the present paper: it reduces every metric computation to manipulation of a supremum of pointwise absolute-value gaps, an `ℓ^∞`-type object.

### 2.5 Geodesic metric spaces

**Definition 2.9 (Constant-speed geodesic).** In a metric space `(X, d)`, a path `γ : [0, 1] → X` is a *constant-speed geodesic* from `x` to `y` if `γ(0) = x`, `γ(1) = y`, and for all `s, t ∈ [0, 1]`,
`d(γ(s), γ(t)) = |s − t| · d(x, y)`.
A space is *geodesic* if every pair of points is joined by such a path. Geodesy implies, in particular, that `d` is a *length* metric and that midpoints exist.

---

## 3. The convex-interpolation path

### 3.1 Construction

**Definition 3.1 (Lerp).** For filtrations `F, G` and a parameter `t` with `0 ≤ t ≤ 1`, define `lerp F G t` to be the filtration with weight
`(lerp F G t).weight σ := (1 − t) · F.weight σ + t · G.weight σ`.

**Proposition 3.2 (Well-definedness).** `lerp F G t` is a valid filtration.

*Proof sketch.* Both axioms are preserved by non-negatively weighted convex combination. Grounding: since `F.weight ∅ ≤ 0`, `G.weight ∅ ≤ 0`, and the coefficients `1 − t ≥ 0`, `t ≥ 0`, the combination `(1 − t)·F.weight ∅ + t·G.weight ∅ ≤ 0` (a direct `nlinarith`). Monotonicity: given `σ ⊆ τ`, combine `F.weight σ ≤ F.weight τ` and `G.weight σ ≤ G.weight τ` with the same non-negative coefficients. ∎

It is precisely the hypotheses `0 ≤ t` and `t ≤ 1` — i.e. that `(1 − t, t)` is a probability vector — that make the combination a legitimate filtration. Outside `[0, 1]` the coefficients can turn negative and monotonicity may fail.

### 3.2 Endpoints

**Proposition 3.3 (Endpoints).**
`lerp F G 0 = F` *(`lerp_zero`)* and `lerp F G 1 = G` *(`lerp_one`)*.

*Proof sketch.* At `t = 0` the weight is `1·F.weight σ + 0·G.weight σ = F.weight σ`; at `t = 1` it is `0·F.weight σ + 1·G.weight σ = G.weight σ`. Conclude by extensionality (Lemma 2.3). ∎

Thus `t ↦ lerp F G t` is a path from `F` to `G` in `Filtration α`.

---

## 4. Linearity of the metric along the path

The proof of the geodesic identity factors through two purely algebraic linearity statements, one pointwise and one for the sup-distance.

**Lemma 4.1 (Pointwise linear scaling of gaps).** For `s, t ∈ [0, 1]` and every simplex `σ`,
`|(lerp F G s).weight σ − (lerp F G t).weight σ| = |s − t| · |F.weight σ − G.weight σ|`.
*(`weight_lerp_sub`.)*

*Proof sketch.* Expand both weights and simplify:
`((1−s)F + sG) − ((1−t)F + tG) = (t − s)(F − G)` on each `σ` (the coefficient of `F.weight σ` is `(1−s) − (1−t) = t − s`, and of `G.weight σ` is `s − t = −(t−s)`). Taking absolute values and using `|t − s| = |s − t|` yields the claim. ∎

The decisive feature of Lemma 4.1 is that the scalar factor `|s − t|` is *independent of `σ`*. This is what allows it to commute past the supremum.

**Lemma 4.2 (Linearity of the sup-distance).** For `s, t ∈ [0, 1]`,
`weightSupEDist (lerp F G s) (lerp F G t) = ENNReal.ofReal |s − t| · weightSupEDist F G`.
*(`weightSupEDist_lerp`.)*

*Proof sketch.* Unfold `weightSupEDist` to a supremum over `σ` of `ENNReal.ofReal` of the gap. Pull the `σ`-independent constant `ENNReal.ofReal |s − t|` out of the supremum using the distributive law `ENNReal.mul_iSup` (valid since the factor is a fixed element of `ℝ≥0∞`). Then match termwise: `ENNReal.ofReal (|s − t| · |F.weight σ − G.weight σ|) = ENNReal.ofReal |s − t| · ENNReal.ofReal |F.weight σ − G.weight σ|` by `ENNReal.ofReal_mul` (the first factor is non-negative), invoking Lemma 4.1. ∎

The step `ENNReal.mul_iSup` is exactly where the *maximum* nature of the metric matters: a common multiplicative factor distributes over a supremum without loss, which is *not* a property a sum (an `ℓ^1` aggregation) would share in the same clean way at the level of the geodesic identity.

---

## 5. The geodesic identity and its corollaries

**Theorem 5.1 (Constant-speed geodesic identity).** For all `F, G : Filtration α` and `s, t ∈ [0, 1]`,
> `d(lerp F G s, lerp F G t) = ENNReal.ofReal |s − t| · d(F, G)`.
*(`eInterleavingDist_lerp`.)*

*Proof sketch.* Rewrite both occurrences of the interleaving distance via the isometry Theorem 2.8: `d(lerp F G s, lerp F G t) = weightSupEDist(lerp F G s, lerp F G t)` and `d(F, G) = weightSupEDist(F, G)`. Apply Lemma 4.2. ∎

**Corollary 5.2 (Geodesy).** `(Filtration α, d)` is a geodesic metric space, and for each pair `F, G` the path `t ↦ lerp F G t` is a constant-speed geodesic from `F` to `G` in the sense of Definition 2.9 (with the distance valued in `ℝ≥0∞`).

**Corollary 5.3 (Linear endpoint law).** For `t ∈ [0, 1]`,
`d(F, lerp F G t) = ENNReal.ofReal t · d(F, G)`.
*(`eInterleavingDist_lerp_left`.)*

*Proof sketch.* Write `F = lerp F G 0` (Prop. 3.3) and apply Theorem 5.1 with `s = 0`: the scalar is `|0 − t| = t` since `t ≥ 0`. ∎

**Corollary 5.4 (Additive midpoint bisection).** The midpoint `m := lerp F G ½` satisfies
`d(F, m) + d(m, G) = d(F, G)`,
with each summand equal to `½ · d(F, G)`.
*(`eInterleavingDist_midpoint`.)*

*Proof sketch.* By Corollary 5.3, `d(F, m) = ENNReal.ofReal(½) · d(F, G)`. By Theorem 5.1 with `s = ½`, `t = 1`, and `lerp F G 1 = G`, `d(m, G) = ENNReal.ofReal|½ − 1| · d(F, G) = ENNReal.ofReal(½) · d(F, G)`. Summing, `ENNReal.ofReal(½) + ENNReal.ofReal(½) = ENNReal.ofReal 1 = 1`, so the total is `1 · d(F, G) = d(F, G)`. ∎

Corollary 5.4 is the metric witness of constant speed: the midpoint is *exactly*, additively, halfway — a stronger statement than the generic triangle inequality (`d(F, m) + d(m, G) ≥ d(F, G)`), which is here saturated to equality.

---

## 6. Algorithms

The mathematics is constructive and yields directly executable procedures. We summarize them; complete typed implementations appear in the accompanying demonstrations.

### 6.1 Filtration interpolation

**Input:** weight tables of `F` and `G` (dictionaries `σ ↦ weight`), parameter `t ∈ [0, 1]`.
**Output:** the weight table of `lerp F G t`.
**Method:** for each simplex `σ`, emit `(1 − t)·F[σ] + t·G[σ]`. Complexity `O(N)` for `N` recorded simplices.

### 6.2 Interleaving distance via the isometry

**Input:** weight tables of `F` and `G`.
**Output:** `d(F, G) = max_σ |F[σ] − G[σ]|` (or `∞` if supports differ in a way forcing infinite gap).
**Method:** a single linear scan over the union of supports, taking the maximum absolute gap. Complexity `O(N)`. This replaces the naïve definition's optimization over shifts.

### 6.3 Geodesic verification

**Input:** `F`, `G`, parameters `s, t`.
**Output:** numerical confirmation that `d(lerp_s, lerp_t) = |s − t|·d(F, G)`.
**Method:** compute both sides via 6.1 and 6.2 and compare within tolerance. Empirically saturates the identity to machine precision.

### 6.4 Vietoris–Rips interpolation experiment

**Input:** two distance matrices `D₁, D₂` on a common vertex set.
**Output:** comparison of `lerp(diamFiltration D₁, diamFiltration D₂, t)` against `diamFiltration((1−t)D₁ + t D₂)` per simplex.
**Method:** build both filtrations and compare weight tables; the (generic) discrepancy quantifies the gap between *combinatorial* interpolation of filtrations and *geometric* interpolation of distances (Future Direction 3).

---

## 7. Applications

**Stability-respecting morphs.** Because the path realizes the interleaving distance at constant speed, it provides a principled way to *interpolate between datasets* in feature space: every intermediate `lerp F G t` is a legitimate filtration whose distance to either endpoint is known exactly. This is directly useful for visualizing dataset drift, for animating persistence-based morphologies, and for generating calibrated synthetic intermediates.

**Barycenters and averaging.** Geodesy is the prerequisite for defining means in a metric space (Fréchet/Karcher means). The explicit geodesics and the additive midpoint law are the first ingredients of a theory of *averages of filtrations* under the interleaving distance, an object of persistent interest in TDA where one wishes to summarize a population of persistence diagrams.

**Optimization on filtration space.** Constant-speed geodesics make gradient-like and proximal methods meaningful on `(Filtration α, d)`: one can move along geodesics with predictable distance budgets, enabling line search and trust-region reasoning directly in shape space.

**Curvature-aware analysis.** The sup-metric heritage (Theorem 2.8) suggests `ℓ^∞`-type geometry — Busemann non-positive curvature but not `CAT(0)` — which, once established (Future Direction 4), would import convexity tools for the above optimization and barycenter problems.

---

## 8. Discussion

The result reframes the interleaving distance from a *measured* quantity to a *navigable* geometry. Three structural points deserve emphasis.

First, the geodesic is the *naïve* one. Convex interpolation of coordinates is the first thing one would try; that it is exactly optimal (equality, not inequality, in Theorem 5.1) is a non-trivial alignment, and it is downstream of the isometry collapse: in a sup-of-coordinates metric, a common linear motion in every coordinate produces a common linear motion in the maximum.

Second, geodesy here is *not* uniqueness. Because the distance is a supremum (a maximum), only the maximizing simplices constrain the path; non-maximizing simplices may follow any route that stays within the dominant envelope. Hence the space is geodesic but *not uniquely geodesic* — the convex path is one member of a convex family of geodesics (Future Direction 2). This is the characteristic signature of `ℓ^∞`-geometry and distinguishes the space sharply from `ℓ^2`/Hilbertian (uniquely geodesic) settings.

Third, the identity is the *base case* of a curvature statement. Corollary 5.4 is precisely the `F = G` instance of the Busemann convexity inequality `d(lerp F G ½, lerp F H ½) ≤ ½ d(G, H)`; generalizing one endpoint is the minimal next step toward a curvature classification.

---

## 9. Future directions

The following program is enabled and sharpened by the geodesic identity.

**Direction 1 — Contractibility of the path space.** For any basepoint `F₀`, the straight-line map `H(G, t) = lerp G F₀ t` is conjectured to be a continuous (indeed 1-Lipschitz-in-`t`) contraction of `(Filtration α, d)` onto `F₀`, rendering the space contractible with trivial fundamental groupoid. Theorem 5.1 already supplies `d(H(G,t), H(G,t')) = |t−t'|·d(G,F₀)`, and 1-Lipschitzness of `lerp` in its moving endpoint follows from the same `weight_lerp_sub` factorization; joint continuity is then a pure `ENNReal` estimate.

**Direction 2 — Classification of geodesics.** Conjecture: a path `γ` from `F` to `G` is a constant-speed geodesic iff, for every simplex `σ`, the scalar path `t ↦ γ(t).weight σ` stays monotonically between `F.weight σ` and `G.weight σ`, and the supremum over `σ` of the gap travels at constant speed. Then `lerp` is one geodesic in a convex family, and the space is geodesic but not uniquely geodesic. Testable by perturbing `lerp` on a single non-maximizing simplex and re-running the supremum argument.

**Direction 3 — Geodesic convexity of the Vietoris–Rips locus.** Conjecture: the image of `d ↦ diamFiltration d` is geodesically convex — the `lerp` of two diameter-filtrations is again a diameter-filtration of the interpolated distance matrix `(1−t)d₁ + t d₂`, provided that interpolation remains a pseudometric. Since the diameter weight is a pointwise supremum of edge distances, and suprema commute with convex combinations only up to inequality, this pins down when persistence interpolation is geometric versus merely combinatorial.

**Direction 4 — Curvature.** Conjecture: `(Filtration α, d)` satisfies the Busemann non-positive curvature inequality `d(lerp F G ½, lerp F H ½) ≤ ½ d(G, H)` (metric convexity along `lerp`-geodesics), inherited from the sup-metric structure, but is *not* `CAT(0)` in general (sup-metrics are flat-but-cornered, like `ℓ^∞`). The midpoint lemma is the `F = G` instance; generalizing one endpoint yields the curvature statement via the same `mul_iSup` machinery.

**Direction 5 — Rigidity of the sup-metric.** Conjecture: among all translation-invariant metrics on weight functions `Finset α → ℝ` for which every `lerp`-segment is a constant-speed geodesic with the same per-simplex speeds, the sup-distance is the unique one arising from an interleaving-type stability relation; i.e. the geodesic law plus 1-Lipschitz stability forces the sup-formula of Theorem 2.8. Falsifiable by exhibiting a different metric (e.g. an `ℓ^p` weight-distance, `p < ∞`) that also makes `lerp` geodesic yet arises from a stability relation.

---

## 10. Conclusion

We have established that the space of filtrations under the interleaving distance is a geodesic metric space, with convex interpolation of weights furnishing explicit constant-speed geodesics. The constant-speed geodesic identity `d(lerp F G s, lerp F G t) = |s − t|·d(F, G)`, together with its linear endpoint law and additive midpoint bisection, converts the metric theory of persistence stability into a genuine geometry of motion. This is the first explicit path of filtrations in the development and the natural launch point for a homotopical and curvature-theoretic study of the space of data shapes.

---

## Appendix A. Notation

| Symbol | Meaning |
|---|---|
| `Finset α` | finite subsets of `α` (simplices) |
| `F.weight σ` | birth scale of simplex `σ` in filtration `F` |
| `F.sublevelFaces t` | simplices alive by scale `t` |
| `Interleaved F G δ` | `F`, `G` are `δ`-interleaved |
| `d(F, G)` | extended interleaving distance, in `ℝ≥0∞` |
| `weightSupEDist F G` | `⨆_σ ofReal\|F.weight σ − G.weight σ\|` |
| `lerp F G t` | convex-interpolation filtration |
| `diamFiltration` | Vietoris–Rips filtration from a metric |

## Appendix B. Dependency map of the main result

```
HigherPersistence (Filtration, sublevelFaces, diamFiltration)
        │
PersistenceStability (set-inclusion interleavings)
        │
BottleneckStability (Interleaved relation, WeightCloseBy)
        │
InterleavingMetric (eInterleavingDist, triangle, PseudoEMetric)
        │
InterleavingClosure (ext_weight, point separation, EMetric)
        │
InterleavingIsometry (Theorem 2.8: d = weightSupEDist)   ◄── engine
        │
InterleavingGeodesic (THIS WORK)
   lerp ─► lerp_zero/one ─► weight_lerp_sub ─► weightSupEDist_lerp
        └─► eInterleavingDist_lerp (Thm 5.1)
                 ├─► eInterleavingDist_lerp_left (Cor 5.3)
                 └─► eInterleavingDist_midpoint (Cor 5.4)
```
