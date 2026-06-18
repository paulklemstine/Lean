# Representation and Edge-Realization of the Interleaving Isometry for Sublevel and Vietoris–Rips Filtrations

## Abstract

We study the metric geometry of one-parameter sublevel filtrations on abstract
simplicial complexes and of the Vietoris–Rips filtrations built from explicit
distance matrices. Building on an *isometry theorem* — that the (extended)
interleaving distance between two filtrations equals the supremum, over all
simplices, of the absolute difference of their birth-time (weight) functions — we
establish two sharpenings.

First, a **representation theorem**: the weight map is not merely an isometric
embedding of the space of filtrations into the space of real-valued functions on
simplices, but an isometric *bijection* onto the explicitly characterized cone of
*grounded, monotone* weight functions (`w(∅) ≤ 0` and `σ ⊆ τ ⇒ w(σ) ≤ w(τ)`). The
interleaving distance is transported verbatim across this bijection into the
supremum-distance of functions.

Second, an **edge-realization theorem** for Vietoris–Rips filtrations: for genuine
distance matrices (nonnegative, symmetric, zero diagonal), the simplex-indexed
supremum in the isometry formula collapses onto the *edge*-indexed supremum,
yielding
`interleavingDistance(VR(d₁), VR(d₂)) = sup_{x,y} |d₁(x,y) − d₂(x,y)|`. The
Vietoris–Rips interleaving distance is therefore *exactly* the ℓ∞ distance of the
underlying distance matrices, reducing an exact computation over `2^n` simplices to
one over `O(n²)` pairs. As a corollary, a previously-only-bounded certificate for
two concrete three-point clouds is sharpened to the exact value `1/10`.

All results have been formally verified in the Lean 4 proof assistant with
Mathlib; the proofs depend only on the standard foundational axioms
(`propext`, `Classical.choice`, `Quot.sound`).

**Keywords:** persistent homology, topological data analysis, interleaving
distance, stability, Vietoris–Rips, isometry, representation theorem, formal
verification.

---

## 1. Introduction

Persistent homology summarizes the multiscale topology of a data set as a barcode.
The pipeline is: (i) a finite data set induces a one-parameter nested family of
simplicial complexes — a *filtration*; (ii) homology applied to the filtration
yields a persistence module; (iii) the persistence module is decomposed into
intervals — the *barcode*. The central robustness guarantee of the field is the
**stability theorem**: a perturbation of the input induces a controlled
perturbation of the barcode, measured by the *interleaving* (equivalently
*bottleneck*) distance.

Classical stability is an *inequality*: the interleaving distance is bounded above
by the perturbation size. This paper is part of a line of work establishing that,
at the filtration level, the inequality is in fact an *equality*, and then drawing
out the structural and computational consequences of that exactness.

### 1.1 Context: the isometry theorem

A filtration is encoded by its *weight function* `w : Finset α → ℝ`, where `w(σ)`
is the birth scale of the simplex σ. The sublevel set at scale `t` is
`{σ : w(σ) ≤ t}`. Two filtrations `F`, `G` are *δ-interleaved* (for `δ ≥ 0`) when
each one's sublevel family, shifted up by `δ`, contains the other's. The extended
interleaving distance `eInterleavingDist(F, G) ∈ [0, ∞]` is the infimum of
admissible shifts (taken in `ℝ≥0∞`, so that "no interleaving" gives the correct
value `⊤`).

The **isometry theorem** (the immediate predecessor of this work) states:

> **Theorem (Isometry).** For all filtrations `F`, `G`,
> `eInterleavingDist(F, G) = sup_{σ : Finset α} ofReal |w_F(σ) − w_G(σ)|`.

Here `ofReal : ℝ → ℝ≥0∞` is the truncation-at-zero coercion. The engine of the
isometry is the equivalence

> `Interleaved(F, G, δ) ↔ (0 ≤ δ ∧ ∀ σ, |w_F(σ) − w_G(σ)| ≤ δ)`,

i.e. a δ-interleaving is *exactly* uniform δ-closeness of the weights in the
sup-norm; the interleaving infimum is therefore an infimum of sup-norm bounds and
collapses to the explicit supremum.

### 1.2 Contributions

This paper deepens the isometry theorem along two axes.

- **Direction A (Representation).** We characterize the *range* of the weight map.
  The map is an isometric bijection onto the cone of grounded, monotone weight
  functions, and the interleaving distance is transported across the bijection
  (Section 3).

- **Direction B (Edge-realization).** We collapse the simplex-indexed supremum of
  the isometry formula onto an edge-indexed supremum for Vietoris–Rips filtrations
  over genuine distance matrices (Section 4), and sharpen a concrete certificate
  from inequality to exact equality (Section 5).

All statements correspond to formally verified Lean theorems; Section 6 records the
formal status and Section 7 the discussion and future directions.

---

## 2. Definitions

Throughout, `α` is a type ("vertices"), and `Finset α` is the type of finite
subsets ("simplices"). We write `ℝ≥0∞ = [0, ∞]` for the extended nonnegative
reals, and `ofReal : ℝ → ℝ≥0∞` for the order-preserving map `x ↦ max(x, 0)`
embedded in `ℝ≥0∞`.

**Definition 2.1 (Filtration).** A *filtration* on `α` is a structure consisting of
a weight function `w : Finset α → ℝ` together with two properties:
- *grounded:* `w(∅) ≤ 0`;
- *monotone:* for all `σ, τ`, if `σ ⊆ τ` then `w(σ) ≤ w(τ)`.

The defining data is the function `w`; the two properties are propositions. Two
filtrations are equal iff their weight functions are equal.

**Definition 2.2 (Sublevel family).** The *sublevel faces* of `F` at scale `t ∈ ℝ`
are `sublevelFaces(F, t) := {σ : w_F(σ) ≤ t}`. Monotonicity makes each sublevel set
downward closed (an abstract simplicial complex for `t ≥ 0`), and the family is
nested in `t`.

**Definition 2.3 (Interleaving).** For `δ ∈ ℝ`, `F` and `G` are *δ-interleaved*,
written `Interleaved(F, G, δ)`, when:
`0 ≤ δ`, and for all `t`, `sublevelFaces(F, t) ⊆ sublevelFaces(G, t + δ)` and
`sublevelFaces(G, t) ⊆ sublevelFaces(F, t + δ)`.

The relation is reflexive (`δ = 0`), symmetric, monotone in `δ`, and additive:
a `δ`-interleaving composed with a `δ'`-interleaving is a `(δ + δ')`-interleaving.

**Definition 2.4 (Extended interleaving distance).**
`eInterleavingDist(F, G) := inf_{δ : Interleaved(F, G, δ)} ofReal(δ) ∈ ℝ≥0∞`, with
the convention that the infimum over the empty set is `⊤`. Additivity of
interleaving yields the unconditional triangle inequality, and
`eInterleavingDist` makes `Filtration α` an extended pseudometric space; in fact a
genuine extended metric space, since `eInterleavingDist(F, G) = 0 ⇔ F = G`.

**Definition 2.5 (Weight sup-distance).**
`weightSupEDist(F, G) := sup_{σ : Finset α} ofReal |w_F(σ) − w_G(σ)| ∈ ℝ≥0∞`. The
index `Finset α` is nonempty (it contains `∅`).

**Definition 2.6 (Diameter weight and VR filtration).** For a matrix
`d : α → α → ℝ`, the *diameter weight* of a simplex σ is
`diamWeightOf(d, σ) := max( {0} ∪ { d(x, y) : (x, y) ∈ σ × σ } )`,
the largest pairwise entry over the vertices of σ (with `0` adjoined so that ∅ and
singletons receive weight `0`). The map `σ ↦ diamWeightOf(d, σ)` is grounded and
monotone, hence defines the *Vietoris–Rips filtration* `diamFiltrationOf(d)`.

**Definition 2.7 (Distance matrix).** A function `d : α → α → ℝ` is a *distance
matrix*, written `IsDistMatrix(d)`, when it is nonnegative (`0 ≤ d(i, j)`), has zero
diagonal (`d(i, i) = 0`), and is symmetric (`d(i, j) = d(j, i)`). No triangle
inequality is assumed.

---

## 3. Direction A: the representation bijection

### 3.1 Statement

Let `W := { w : Finset α → ℝ | w(∅) ≤ 0 ∧ ∀ σ τ, σ ⊆ τ → w(σ) ≤ w(τ) }` be the
*cone of admissible weights*: the grounded, monotone real functions on simplices.

**Theorem 3.1 (Representation bijection, `filtrationEquivWeight`).** The weight map
`F ↦ w_F` is a bijection `Filtration α ≃ W`. Its inverse sends an admissible weight
`w ∈ W` to the filtration with weight function `w` (the grounded and monotone
properties of `w` being exactly the two filtration axioms).

*Proof sketch.* A filtration *is* a weight function together with two
propositional fields; an element of `W` *is* a weight function together with two
propositional fields. The two encodings carry the same data, so both round-trips
are the identity on the underlying function. Formally, `left_inv` and `right_inv`
hold by `rfl` (subtype/structure eta and proof irrelevance of the side
conditions). ∎

**Theorem 3.2 (Distance transported, `eInterleavingDist_eq_repr_supEDist`).** Under
the bijection of Theorem 3.1, the extended interleaving distance becomes the
extended sup-distance of the represented weight functions:
`eInterleavingDist(F, G) = sup_{σ} ofReal |w_F(σ) − w_G(σ)|`, where `w_F`, `w_G` are
the images of `F`, `G` in `W`.

*Proof sketch.* The image of `F` under the bijection has underlying function
definitionally equal to `w_F`. Hence the right-hand side is literally
`weightSupEDist(F, G)`, and the claim is the isometry theorem of Section 1.1. ∎

### 3.2 Significance

Theorem 3.1 upgrades "isometric embedding" to "isometric bijection onto an
explicitly described set." Two consequences are worth isolating.

- **The range is the admissible cone.** The image of the persistence map is not an
  opaque subset of function space; it is exactly `W`, a convex cone closed under
  pointwise maxima and minima with constants. Any constructive procedure on
  functions that preserves groundedness and monotonicity (e.g. pointwise maximum
  of two filtrations, or truncation) automatically yields a filtration.

- **Transport of structure.** Because the bijection is an isometry, every metric
  notion (geodesics, balls, completeness, the Hausdorff/Lipschitz toolbox) may be
  computed in the concrete function model `(W, sup-distance)` and read back into
  the abstract filtration model with no loss.

---

## 4. Direction B: edge-realization for Vietoris–Rips

We now restrict to Vietoris–Rips filtrations of distance matrices and collapse the
simplex-supremum of the isometry onto an edge-supremum.

**Definition 4.1 (Edge sup-distance).**
`edgeSupEDist(d₁, d₂) := sup_{(x,y) : α × α} ofReal |d₁(x, y) − d₂(x, y)|`.

### 4.1 The key lemma: edges are realized by simplices

**Lemma 4.2 (Edge-realization of the diameter, `diamWeightOf_pair`).** For a
distance matrix `d` (i.e. `IsDistMatrix(d)`) and vertices `x, y`,
`diamWeightOf(d, {x, y}) = d(x, y)`.

*Proof sketch.* By antisymmetry. The simplex `{x, y}` has vertex-pair set
`{x, y} × {x, y}`, whose `d`-values are `d(x, x) = 0`, `d(x, y)`,
`d(y, x) = d(x, y)`, and `d(y, y) = 0`. Each is `≤ d(x, y)` (using `diag`, `symm`,
and `nonneg`), so the max over `{0} ∪ {…}` is `≤ d(x, y)` (`sup'_le`). Conversely,
`d(x, y)` itself occurs in the set (the pair `(x, y) ∈ {x, y} × {x, y}`), so the
max is `≥ d(x, y)` (`le_sup'`). The case `x = y` gives `0 = 0`. ∎

Lemma 4.2 is precisely what links the edge supremum to a *simplex* supremum: the
maximizing edge is itself the diameter of an honest two-vertex simplex.

### 4.2 The two halves

**Theorem 4.3 (Upper half / 1-Lipschitz estimate,
`weightSupEDist_diam_le_edgeSup`).** For *arbitrary* `d₁, d₂ : α → α → ℝ`
(no hypotheses),
`weightSupEDist(diamFiltrationOf(d₁), diamFiltrationOf(d₂)) ≤ edgeSupEDist(d₁, d₂)`.

*Proof sketch.* If `edgeSupEDist(d₁, d₂) = ⊤` the bound is trivial. Otherwise set
`E := edgeSupEDist(d₁, d₂)`. For each pair `(x, y)`, `ofReal |d₁(x,y) − d₂(x,y)| ≤ E`
(by `le_iSup`), hence `|d₁(x,y) − d₂(x,y)| ≤ E.toReal`. The diameter is
1-Lipschitz in the matrix entries restricted to the simplex's vertices
(`diamWeightOf_dist_le`): every simplex gap
`|diamWeightOf(d₁, σ) − diamWeightOf(d₂, σ)|` is bounded by the worst edge gap
over the vertices of σ, hence by `E.toReal`. Taking `ofReal` and the supremum over
σ (`iSup_le`), and using `ofReal(E.toReal) = E`, gives the bound. ∎

**Theorem 4.4 (Lower half,
`edgeSup_le_weightSupEDist_diam`).** For a pair of distance matrices `d₁, d₂`
(`IsDistMatrix(d₁)`, `IsDistMatrix(d₂)`),
`edgeSupEDist(d₁, d₂) ≤ weightSupEDist(diamFiltrationOf(d₁), diamFiltrationOf(d₂))`.

*Proof sketch.* It suffices to bound each edge term by the simplex supremum. Fix
`(x, y)`. By Lemma 4.2, `diamWeightOf(dᵢ, {x, y}) = dᵢ(x, y)` for `i = 1, 2`, so
`|d₁(x,y) − d₂(x,y)| = |diamWeightOf(d₁, {x,y}) − diamWeightOf(d₂, {x,y})|`, which
is the weight gap of the *single* simplex `σ = {x, y}`. Hence
`ofReal |d₁(x,y) − d₂(x,y)| ≤ sup_σ ofReal |…| = weightSupEDist(…)` (`le_iSup`).
Taking the supremum over `(x, y)` finishes. ∎

### 4.3 The main theorem

**Theorem 4.5 (Edge-realization of the isometry,
`vr_eInterleavingDist_eq_edgeSup`).** For distance matrices `d₁, d₂`,
> `eInterleavingDist(diamFiltrationOf(d₁), diamFiltrationOf(d₂)) = sup_{x,y} ofReal |d₁(x,y) − d₂(x,y)|`.

*Proof sketch.* The isometry theorem rewrites the left side as
`weightSupEDist(diamFiltrationOf(d₁), diamFiltrationOf(d₂))`. Theorem 4.3 gives
`≤ edgeSupEDist(d₁, d₂)` and Theorem 4.4 gives `≥ edgeSupEDist(d₁, d₂)`; by
antisymmetry the two are equal, and `edgeSupEDist(d₁, d₂)` is the right side. ∎

### 4.4 Interpretation and complexity

Theorem 4.5 says the Vietoris–Rips interleaving distance is *literally* the ℓ∞
(max-entry) distance of the distance matrices. The exact computation of the
filtration distance — naively a supremum over the `2^{|α|}` simplices — reduces to
a supremum over the `|α|²` ordered pairs. For a finite point set of size `n`, this
is the difference between an intractable `O(2^n)` enumeration and a trivial `O(n²)`
scan of two matrices, with *no loss of exactness*.

The asymmetry between the two halves is instructive: the upper bound (Theorem 4.3)
needs *no* assumptions on the matrices — it is pure Lipschitz bookkeeping — whereas
the lower bound (Theorem 4.4) requires the `IsDistMatrix` hypotheses, used solely
through Lemma 4.2 to realize an edge as a simplex diameter.

---

## 5. A concrete exact certificate

Consider two distance matrices on three points (`α = Fin 3`):
- `cloud₁(i, j) = 0` if `i = j`, else `1` (a unit-distance triangle);
- `cloud₂(i, j) = 0` if `i = j`, else `11/10` (the same triangle inflated by 10%).

Both are distance matrices in the sense of Definition 2.7. Every off-diagonal entry
differs by exactly `11/10 − 1 = 1/10`, and diagonal entries agree, so
`edgeSupEDist(cloud₁, cloud₂) = ofReal(1/10)`.

**Theorem 5.1 (Exact cloud certificate, `cloud_eInterleavingDist_eq`).**
> `eInterleavingDist(diamFiltrationOf(cloud₁), diamFiltrationOf(cloud₂)) = ofReal(1/10)`.

*Proof sketch.* Apply Theorem 4.5 to the two distance matrices and evaluate the
edge supremum: it is the maximum over the nine ordered pairs of
`ofReal |cloud₁(i, j) − cloud₂(i, j)|`, which is `ofReal(1/10)` (attained on every
off-diagonal pair, `0` on the diagonal). ∎

This upgrades the earlier stability *bound* `≤ 1/10` (which followed from the
1-Lipschitz CESH estimate) to an exact *equality* `= 1/10`. The worst-case
guarantee was tight, and Theorem 4.5 makes that tightness provable.

---

## 6. Formal verification

All definitions and theorems above are formalized in Lean 4 with Mathlib. The
salient correspondences are:

| Paper result | Lean name |
| --- | --- |
| Thm 3.1 representation bijection | `filtrationEquivWeight` |
| Thm 3.2 distance transported | `eInterleavingDist_eq_repr_supEDist` |
| Lem 4.2 edge-realization of diameter | `diamWeightOf_pair` |
| Def 4.1 edge sup-distance | `edgeSupEDist` |
| Thm 4.3 upper half (1-Lipschitz) | `weightSupEDist_diam_le_edgeSup` |
| Thm 4.4 lower half | `edgeSup_le_weightSupEDist_diam` |
| Thm 4.5 edge-realization isometry | `vr_eInterleavingDist_eq_edgeSup` |
| Thm 5.1 exact cloud certificate | `cloud_eInterleavingDist_eq` |

The supporting metric theory (interleaving relation, extended distance, triangle
inequality, the isometry theorem) is supplied by the predecessor developments
(`BottleneckStability`, `InterleavingMetric`, `InterleavingClosure`,
`InterleavingIsometry`). Every proof is `sorry`-free and uses only the standard
foundational axioms `propext`, `Classical.choice`, and `Quot.sound`.

---

## 7. Discussion and future directions

### 7.1 Discussion

Three structural themes emerge.

1. **Exactness as accountability.** Stability theorems in TDA are usually
   inequalities; the upgrade to exact identities (the isometry, then its edge
   realization) means the interleaving distance is *fully accounted for* by the
   input. There is no hidden slack: a practitioner can read the precise
   sensitivity of Vietoris–Rips persistence to measurement error directly off the
   ℓ∞ distance of distance matrices.

2. **Representation as a bridge.** The bijection with the admissible-weight cone
   lets the entire toolkit of function spaces act on filtrations. Operations such
   as pointwise maxima/minima, averaging, and constrained projection are now
   first-class on filtrations via transport.

3. **Collapse to a low-dimensional witness.** The exponential simplex supremum
   collapses to a quadratic edge supremum because the extremal simplex is realized
   by an edge. This is a recurring mechanism by which exact quantities become
   cheaply computable.

### 7.2 Future directions (from the development's own program)

> **Direction 1 — Higher-clique realization: from edges to k-faces.** Bridge IX
> realizes the persistence supremum at a single edge (a two-vertex simplex).
> Conjecture: for a weight built as the maximum of a `k`-ary symmetric kernel
> `κ : (Fin k → α) → ℝ` over the injections of a simplex (the genuine *higher*
> Vietoris–Rips / clique weight), the interleaving supremum collapses onto an
> indexing by `k`-faces — generalizing `diamWeightOf_pair`
> (`k = 2`) to a `diamWeightOf_kface` realizing the kernel value on a single
> `k`-simplex. This would give an exact `O(n^k)` formula for the persistence
> distance of higher-order kernels, with the edge case `k = 2` recovered here.

Further natural continuations suggested by the present results:

- **Completeness and geodesics in the weight model.** Use Theorem 3.2 to study
  geodesics, midpoints, and completeness of the filtration space directly in
  `(W, sup-distance)`, transporting back via `filtrationEquivWeight`.

- **Quotient by the distance-zero kernel.** Combine the representation with the
  separation quotient to obtain a genuine extended-metric (T0) space of
  persistence content, and characterize its closed/convex subsets through the
  admissible-weight cone.

- **Algorithmic exact bottleneck via edge realization.** Theorem 4.5 reduces the
  exact Vietoris–Rips interleaving distance to an `O(n²)` matrix comparison;
  formalize the corresponding algorithm and certify its output equals the
  filtration distance for arbitrary finite clouds.

- **Stability of derived invariants.** Push the exact isometry through homology to
  obtain exact (not merely Lipschitz) statements about barcodes/diagrams for
  structured perturbations.

---

## 8. Conclusion

We have sharpened the interleaving isometry for sublevel and Vietoris–Rips
filtrations in two complementary ways: a representation bijection identifying
filtrations with the cone of grounded, monotone weight functions and transporting
the metric verbatim; and an edge-realization theorem reducing the exact
Vietoris–Rips interleaving distance to the ℓ∞ distance of distance matrices,
witnessed concretely by the exact value `1/10` on a three-point example. Together
they turn the qualitative robustness of persistence into a precise, computable, and
formally verified law.
