# Local-to-Global Gluing of Interleaving Geodesics

*A self-coherent field of geodesics on the space of filtrations under the
interleaving distance.*

## Abstract

The interleaving distance is the canonical metric for comparing the persistence
fingerprints of data. Prior work in this research arc established that the space of
**filtrations** — grounded, monotone weight functions on the simplices of a finite
index set — is an extended metric space under the interleaving distance
`eInterleavingDist`; that this distance is *isometric* to a supremum-of-pointwise-gaps
sup-distance on weight functions; and that the space is moreover **geodesic**, with
the convex-interpolation path `lerp F G t` (the pointwise average
`(1−t)·F.weight + t·G.weight`) a constant-speed geodesic along which the distance
varies *exactly linearly*. This paper promotes that single geodesic to a
**self-coherent field of geodesics**. The keystone is the affine **gluing law**

> `lerp (lerp F G s) (lerp F G t) r = lerp F G ((1 − r)·s + r·t)`,

which asserts that the geodesic joining two points *on* a geodesic is the same
geodesic, merely reparametrized — the local-to-global (sheaf-like) restriction axiom
of a geodesic structure. From the gluing law, together with the linear geodesic
identity and the additivity of `ENNReal.ofReal` on nonnegative parameter gaps, we
derive four metric corollaries: the distance to the far endpoint, exact additive
*betweenness* for ordered parameters, a *universal* additive split at every interior
point (generalizing the midpoint bisection to the full continuum), and
multiplicativity of geodesic speed under nesting. All results hold over an arbitrary
index type `α` and have been formally verified. We discuss applications to shape
interpolation, a path category of persistence data, and a cohomological obstruction
theory for global geodesic sections.

**Keywords:** persistent homology, interleaving distance, geodesic metric space,
filtration, convex interpolation, betweenness, local-to-global gluing.

---

## 1. Introduction

Persistent homology summarizes the multiscale shape of data by a **filtration**: a
monotone assignment of birth-scales to the simplices of a complex. The stability of
this summary is governed by the **interleaving distance** (equivalently, in the
bottleneck-stability picture, the bottleneck distance), the gold-standard metric on
persistence fingerprints.

A metric space is **geodesic** when any two points are joined by a path whose length
equals their distance, traversed at constant speed. Knowing that a space is geodesic
is far stronger than knowing it is merely a metric space: geodesics give canonical
interpolations, support convexity arguments, and are the substrate of homotopical
and obstruction-theoretic methods. The immediately preceding result in this arc
("Bridge IX") proved that the filtration space is geodesic, exhibiting an explicit
constant-speed geodesic `lerp F G`.

A *single* geodesic, however, is a curve; a *geodesic structure* is a coherent field
of curves that agree wherever they overlap. The present work ("Bridge X") supplies
that coherence. We prove the **affine gluing law** and deduce that the filtration
geodesics form a self-consistent system: every sub-segment of a geodesic is itself a
geodesic of the same family, distances add along ordered points, and reparametrizations
compose multiplicatively. The mathematical heart of the contribution is that all of
this is *affine* — it lives in the algebra of averaging averages — and the metric is
consulted only through a previously established isometry.

### Contributions

1. **The affine gluing law** (`lerp_lerp`): geodesics restrict consistently to
   sub-segments.
2. **Far-endpoint distance** (`eInterleavingDist_lerp_right`).
3. **Exact additive betweenness** for ordered parameters
   (`eInterleavingDist_lerp_betweenness`).
4. **Universal additive split** at every interior point
   (`eInterleavingDist_lerp_bisect`), generalizing the midpoint case.
5. **Multiplicativity of speed under nesting**
   (`eInterleavingDist_lerp_lerp`).

All five are proved without unproved assumptions, over an arbitrary index type `α`.

---

## 2. Definitions and inherited results

Throughout, `α` is an arbitrary type; simplices are finite subsets `σ : Finset α`;
distances take values in the extended nonnegative reals `ℝ≥0∞`, and
`ENNReal.ofReal : ℝ → ℝ≥0∞` clamps a real to its nonnegative part.

### 2.1 Filtrations

**Definition 2.1 (Filtration).** A *filtration* on `α` is a function
`weight : Finset α → ℝ` satisfying

- **grounding:** `weight ∅ ≤ 0`, and
- **monotonicity:** `σ ⊆ τ ⟹ weight σ ≤ weight τ`.

We write `F.weight σ` for the birth-scale that filtration `F` assigns to simplex `σ`.

**Lemma 2.2 (Extensionality, `ext_weight`).** A filtration is determined by its
weight function: if `F.weight = G.weight` then `F = G`. (The grounding and
monotonicity fields are propositions, hence proof-irrelevant.)

### 2.2 The interleaving distance and the isometry

**Definition 2.3 (δ-interleaving).** For `δ ≥ 0`, filtrations `F` and `G` are
`δ`-interleaved when each one's sublevel family is contained in the other's after a
uniform scale shift by `δ`:
`F.sublevel(t) ⊆ G.sublevel(t + δ)` and `G.sublevel(t) ⊆ F.sublevel(t + δ)` for all
`t`, where `sublevel(t) = { σ : weight σ ≤ t }`.

**Definition 2.4 (Interleaving distance).**
`eInterleavingDist F G := ⨅ { ofReal δ : F and G are δ-interleaved }`.

The following two inherited results are the substrate of everything below.

**Theorem 2.5 (Isometry, "Bridge VIII", `eInterleavingDist_eq_weightSupEDist`).**
The interleaving distance equals the extended supremum-of-gaps distance:
> `eInterleavingDist F G = ⨆ σ : Finset α, ENNReal.ofReal |F.weight σ − G.weight σ|`.
We denote the right-hand side `weightSupEDist F G`.

**Definition 2.6 (Geodesic interpolation, "Bridge IX", `lerp`).** For `0 ≤ t ≤ 1`,
`lerp F G t` is the filtration with
> `(lerp F G t).weight σ = (1 − t)·F.weight σ + t·G.weight σ`.
It is a valid filtration because a convex combination of grounded, monotone weights
is grounded and monotone. Its endpoints are `lerp F G 0 = F` and `lerp F G 1 = G`.

**Theorem 2.7 (Constant-speed geodesic identity, "Bridge IX",
`eInterleavingDist_lerp`).** For `s, t ∈ [0,1]`,
> `eInterleavingDist (lerp F G s) (lerp F G t) = ENNReal.ofReal |s − t| · eInterleavingDist F G`.

Two consequences of Theorem 2.7 are used repeatedly:

- **Left distance** (`eInterleavingDist_lerp_left`):
  `eInterleavingDist F (lerp F G t) = ofReal t · eInterleavingDist F G`
  (from `F = lerp F G 0` and `|0 − t| = t`).
- **Midpoint bisection** (`eInterleavingDist_midpoint`):
  `eInterleavingDist F (lerp F G ½) + eInterleavingDist (lerp F G ½) G = eInterleavingDist F G`.

The present paper subsumes and generalizes the latter.

---

## 3. The affine gluing law

The keystone result requires no metric input at all; it is an identity of
filtrations.

**Theorem 3.1 (Affine gluing law, `lerp_lerp`).** Let `F, G` be filtrations and let
`r, s, t ∈ [0, 1]`. Then `(1 − r)·s + r·t ∈ [0, 1]`, and
> `lerp (lerp F G s) (lerp F G t) r = lerp F G ((1 − r)·s + r·t)`.

*Interpretation.* The geodesic joining two points `lerp F G s` and `lerp F G t` of
the geodesic `lerp F G` is the **same** geodesic, reparametrized affinely. This is
precisely the local-to-global coherence (restriction) axiom of a geodesic structure:
the global segment restricts consistently to every sub-interval.

*Proof sketch.* First, the new parameter `u := (1 − r)·s + r·t` is a convex
combination of `s` and `t` with weights `1 − r, r ≥ 0` summing to `1`; since
`s, t ∈ [0,1]`, also `u ∈ [0,1]`. (Concretely, `u ≥ 0` because it is a sum of the
nonnegative products `(1−r)s` and `rt`; and `1 − u = (1−r)(1−s) + r(1−t) ≥ 0`
likewise.) For the equation, by extensionality (Lemma 2.2) it suffices to check
weights pointwise at each `σ`. Expanding the left side,
```
(1 − r)·[(1 − s)F + sG] + r·[(1 − t)F + tG]
   = [(1 − r)(1 − s) + r(1 − t)]·F + [(1 − r)s + r t]·G
   = (1 − u)·F + u·G,
```
which is exactly the weight of `lerp F G u`. The coefficient of `G` is `u` by
definition, and the coefficient of `F` is `(1 − r)(1 − s) + r(1 − t) = 1 − u`. Both
manipulations are ring identities in the parameters. ∎

The proof is purely algebraic; the metric is never consulted. This is the decisive
structural fact, and the source of the word *affine* in the title.

---

## 4. Metric corollaries

We now feed the gluing law (and Theorem 2.7) into the isometry. The recurring engine
is the additivity of `ENNReal.ofReal` on nonnegative reals:
`ofReal a + ofReal b = ofReal (a + b)` when `a, b ≥ 0`, together with `ofReal 1 = 1`.

### 4.1 Distance to the far endpoint

**Theorem 4.1 (`eInterleavingDist_lerp_right`).** For `t ∈ [0,1]`,
> `eInterleavingDist (lerp F G t) G = ENNReal.ofReal (1 − t) · eInterleavingDist F G`.

*Proof sketch.* Write `G = lerp F G 1` and apply Theorem 2.7 to the pair
`(lerp F G t, lerp F G 1)`, giving `ofReal |t − 1| · d(F,G)`. Since `t ≤ 1`,
`|t − 1| = 1 − t`. ∎

This is the mirror image of the inherited left-distance identity; together they say
`F` sits at ruler-position `0` and `G` at ruler-position `d(F, G)`, with `lerp F G t`
at position `t · d(F, G)`.

### 4.2 Exact additive betweenness

**Theorem 4.2 (`eInterleavingDist_lerp_betweenness`).** For
`s ≤ u ≤ t` in `[0,1]`,
> `eInterleavingDist (lerp F G s) (lerp F G u) + eInterleavingDist (lerp F G u) (lerp F G t) = eInterleavingDist (lerp F G s) (lerp F G t)`.

*Interpretation.* The interior point `lerp F G u` lies metrically **between**
`lerp F G s` and `lerp F G t`. In a general metric space the triangle inequality
gives only `≤`; here, because `u` is genuinely between `s` and `t`, betweenness is an
**equation**.

*Proof sketch.* Apply Theorem 2.7 to each of the three distances, obtaining
`ofReal |s − u| · d`, `ofReal |u − t| · d`, and `ofReal |s − t| · d` with
`d = d(F,G)`. The ordering `s ≤ u ≤ t` collapses the absolute values to
`u − s`, `t − u`, and `t − s`, all nonnegative. Factor out `d` and use additivity of
`ofReal`: `(u − s) + (t − u) = t − s`. ∎

The mathematical content is that the additive order structure of the interval
`[0,1]` is transported *exactly* through the isometry into the geometry of
filtrations.

### 4.3 Universal additive split (constant-speed bisection)

**Theorem 4.3 (`eInterleavingDist_lerp_bisect`).** For *every* `t ∈ [0,1]`,
> `eInterleavingDist F (lerp F G t) + eInterleavingDist (lerp F G t) G = eInterleavingDist F G`.

*Proof sketch.* By the inherited left-distance identity,
`d(F, lerp F G t) = ofReal t · d`; by Theorem 4.1,
`d(lerp F G t, G) = ofReal (1 − t) · d`. Sum and factor:
`ofReal t + ofReal (1 − t) = ofReal (t + (1 − t)) = ofReal 1 = 1`, and `1 · d = d`. ∎

This is the metric witness that `lerp` is a constant-speed geodesic: *no* interior
point is a detour. It generalizes the inherited midpoint bisection (the `t = ½`
case) to the entire continuum.

### 4.4 Multiplicativity of speed under nesting

**Theorem 4.4 (`eInterleavingDist_lerp_lerp`).** For `a, b, s, t ∈ [0,1]`,
> `eInterleavingDist (lerp (lerp F G s) (lerp F G t) a) (lerp (lerp F G s) (lerp F G t) b) = ENNReal.ofReal |a − b| · (ENNReal.ofReal |s − t| · eInterleavingDist F G)`.

*Proof sketch.* Apply Theorem 2.7 to the *outer* interpolation (parameters `a, b`):
the distance equals `ofReal |a − b| · d(lerp F G s, lerp F G t)`. Apply Theorem 2.7
once more to the inner distance to rewrite it as `ofReal |s − t| · d(F, G)`. ∎

*Interpretation.* Reparametrizing a geodesic inside a geodesic multiplies the speed
factors. Equivalently, via the gluing law (Theorem 3.1), the nested geodesic is
literally `lerp F G` reparametrized at rate `|s − t|`; the metric simply reads off the
product of the two scaling factors, exactly as composed gear ratios multiply.

---

## 5. Algorithms

Although the theorems are about an arbitrary, possibly infinite index type `α`, all
quantities are exactly computable when the relevant weights are finitely supported
(e.g. simplices of a finite complex). We record two procedures used in the
accompanying demonstrations.

### 5.1 Interleaving distance via the isometry

By Theorem 2.5, computing `eInterleavingDist F G` reduces to a finite maximum:
```
INPUT  filtrations F, G as maps σ ↦ weight on a finite simplex set S
OUTPUT d(F, G) = max over σ in S of |F.weight σ − G.weight σ|
1.  best ← 0
2.  for σ in S:
3.      best ← max(best, |F.weight(σ) − G.weight(σ)|)
4.  return best
```
Complexity `O(|S|)` in arithmetic operations. This is the *isometry algorithm*: it
turns the defining infimum-over-scale-shifts into a single sweep over simplices.

### 5.2 Geodesic interpolation and its reparametrization

```
INPUT  F, G, parameter t in [0,1]
OUTPUT filtration lerp(F,G,t) with weight σ ↦ (1−t)·F.weight σ + t·G.weight σ
```
The gluing law (Theorem 3.1) provides an `O(1)` reparametrization rule: to evaluate
the inner geodesic `lerp(lerp(F,G,s), lerp(F,G,t), r)` one need not build the two
intermediate filtrations; it equals `lerp(F, G, (1−r)·s + r·t)` directly. This is the
computational shadow of local-to-global coherence.

---

## 5.3 A worked numerical example

We make the theorems concrete on a small finite complex. Take the vertex set
`{0, 1, 2, 3}` and consider the two **Vietoris–Rips diameter filtrations** arising
from two metrics on those four points. Recall that a diameter filtration assigns to
each simplex `σ` the largest pairwise distance among its vertices (and `0` to
vertices and the empty set); this is automatically grounded and monotone, since
adding a vertex can only enlarge a diameter.

Let the two edge-length tables be

| edge | `{0,1}` | `{0,2}` | `{0,3}` | `{1,2}` | `{1,3}` | `{2,3}` |
|------|--------:|--------:|--------:|--------:|--------:|--------:|
| `F`  | 1.0 | 2.0 | 3.0 | 1.5 | 2.5 | 1.0 |
| `G`  | 2.0 | 1.0 | 4.0 | 3.0 | 1.0 | 2.0 |

Reading off triangle and tetrahedron weights as the max over their edges, the
largest pointwise gap occurs at the simplices `{1,2}` (where `F = 1.5`, `G = 3.0`)
and the tetrahedron `{0,1,2,3}` (where both equal their respective maxima `4.0`),
giving `d(F, G) = 1.5`. The *maximizing simplices* are those realizing this worst
case; all distance content of the geodesic is carried by them.

Now sample the geodesic. By Theorem 2.7, `d(F, lerp F G t) = t · 1.5`, so at
`t = 0.25, 0.5, 0.75` we get `0.375, 0.75, 1.125`. Theorem 4.1 predicts the
complementary distances `d(lerp F G t, G) = (1 − t)·1.5 = 1.125, 0.75, 0.375`, and
indeed each pair sums to the constant `1.5` — Theorem 4.3, the universal additive
split. For the ordered triple `s = 0.2`, `u = 0.55`, `t = 0.9`, Theorem 4.2 gives
`d(s,u) + d(u,t) = (0.35 + 0.35)·1.5 = 0.525 = (0.7)·1.5 = d(s,t)`. Finally, the
gluing law (Theorem 3.1) is exact to machine precision: building the geodesic
between `lerp F G 0.2` and `lerp F G 0.9` and evaluating it at `r = 0.5` returns the
same filtration as `lerp F G (0.55)`, since `(1 − 0.5)·0.2 + 0.5·0.9 = 0.55`. The
accompanying demonstration script confirms all five laws over a dense grid of
parameters.

This example also previews the Rips-locus subtlety (Future Work, item 4): because
diameter is a *maximum* over edges, the convex combination `lerp F G t` of two
diameter filtrations need not itself be the diameter filtration of any single metric —
a convex combination of maxima exceeds the maximum of the convex combination unless
the two metrics are comonotone. The geodesic is always a valid *filtration*; it is
the narrower property of being a *diameter* filtration that can fail.

## 6. Applications

**Distance-optimal shape morphing.** Given two persistence fingerprints `F` and `G`,
`lerp F G t` is a canonical, distance-optimal interpolation — a "shape average" with
the guarantee (Theorem 4.3) that the partial journeys sum to the whole. This is
directly useful for animating between data shapes, imputing missing frames in a
temporal sequence of shapes, and regularizing noisy fingerprints.

**A path category of persistence data.** The gluing law is the only nontrivial
coherence needed to assemble geodesics into a category whose objects are filtrations
and whose morphisms are geodesics up to reparametrization. With `lerp F G` and
`lerp G F` mutually inverse, this is a groupoid: a `1`-truncated homotopy type of
persistence data.

**Exact betweenness as a cocycle.** Because Theorem 4.2 makes betweenness an
*equation* `d(i,j) + d(j,k) = d(i,k)`, the question "can a prescribed ordered family
of filtrations be threaded onto a single global geodesic?" becomes a cocycle
condition. Its failure is an honest (Čech-style) cohomology class — an exact, not
merely lax, obstruction.

---

## 7. Discussion

The conceptual surprise is not that the filtration space is geodesic — that was
Bridge IX — but that its geodesics are *coherent as a field*, and that the proof of
this coherence is entirely affine. The metric, defined by an infimum over scale
shifts, is reached only through the Bridge VIII isometry, after which every statement
becomes either a ring identity (Theorem 3.1) or bookkeeping with `ENNReal.ofReal` on
nonnegative gaps (Theorems 4.1–4.4). The supremum over simplices, which makes the
metric look formidable, factors out as a single scalar because a constant pulls
straight out of a supremum.

A notable subtlety, inherited from Bridge IX, is that the geodesic is **not unique**:
since the distance is a supremum over simplices, the weights on non-maximizing
simplices may wander within the sup bound without changing any distance. Thus `lerp`
is one geodesic among a convex family. The exact betweenness equation we prove
controls geometry on the *maximizing* simplices; the slack elsewhere is exactly the
locus of non-uniqueness.

It is worth stressing *why* the betweenness statement is an equation rather than the
usual triangle inequality. In a general geodesic metric space, three collinear points
satisfy additivity only because one genuinely lies on a shortest path between the
other two; verifying this typically requires constructing the path and measuring its
length. Here the construction is free — the path is `lerp` itself — and the length is
read off coordinatewise through the isometry. The supremum, which in a worst-case
analysis would normally destroy additivity (the maximizing coordinate could switch
between segments), does *not* destroy it, because every coordinate moves affinely in
the single parameter and absolute values of affine functions of one variable with a
common zero-crossing structure add along monotone parameter intervals. The supremum
of these per-coordinate additive motions is therefore itself additive. This is the
precise sense in which the metric "only sees" a single scalar factor.

A second observation concerns extreme behaviour. The interpolation parameter is
intrinsically confined to `[0, 1]`: outside this interval a positive coefficient on a
negative endpoint weight can violate the grounding condition `weight ∅ ≤ 0`, so the
geodesic is a genuine *segment*, not a bi-infinite line. The space is therefore
geodesic but not, in any naive sense, a normed space; the affine structure is exactly
the convex one, and the gluing law respects that by mapping `[0,1] × [0,1]` into
`[0,1]` under the convex combination `(1 − r)s + rt`.

---

## 8. Future work

The five theorems open several concrete programs.

1. **Chart the convex family of non-unique geodesics.** Conjecture: the constant-speed
   geodesics from `F` to `G` are exactly the paths `P` with `P 0 = F`, `P 1 = G`, and
   `|P(t).weight σ − (lerp F G t).weight σ| ≤ slack(σ)` for every non-maximizing `σ`.
   The isometry reduces this to finite/`iSup` bookkeeping.

2. **Geodesic convexity of the distance functional.** Conjecture: for fixed `H`,
   `t ↦ d(lerp F G t, H)` is convex on `[0,1]`. Under the isometry this is pointwise
   convexity of `σ ↦ |(1−t)F(σ) + tG(σ) − H(σ)|` (an absolute value of an affine
   function) commuting with the supremum; the gluing law supplies the affine
   substitution for midpoint-convexity.

3. **A fundamental groupoid of filtrations.** Concatenate geodesics; show the path
   category is a groupoid with `lerp F G`, `lerp G F` inverse. The gluing law already
   supplies the only nontrivial coherence; associativity and inverses reduce to
   arithmetic in `[0,1]`.

4. **Realizing geodesics inside the Vietoris–Rips locus.** Diameter filtrations are
   maxima over edges, and a convex combination of maxima is not the max of the convex
   combination. Conjecture: `lerp` of two diameter filtrations stays a diameter
   filtration exactly when the two metrics are comonotone on simplices; otherwise the
   geodesic leaves the Rips locus — a concrete, falsifiable edge-weight inequality.

5. **Cohomological obstruction to global geodesic sections.** Treat threading a
   prescribed ordered family onto one global geodesic as a local-to-global extension
   problem; with betweenness an exact equation, the gluing obstruction is the failure
   of the cocycle `d(i,j) + d(j,k) = d(i,k)`, a class in a Čech-style cohomology of
   the betweenness relation over the indexing poset.

---

## 9. Conclusion

We have shown that the geodesics of the interleaving-distance space of filtrations
form a self-coherent field: a geodesic between two points of a geodesic is the same
geodesic, reparametrized (the affine gluing law). From this single algebraic identity
flow the far-endpoint distance, exact additive betweenness, a universal additive split
at every interior point, and multiplicativity of speed under nesting. The space of
shape fingerprints is therefore not merely geodesic but *coherently* geodesic — a
foundation for interpolation, a homotopy theory, and an obstruction theory of
persistence data.
