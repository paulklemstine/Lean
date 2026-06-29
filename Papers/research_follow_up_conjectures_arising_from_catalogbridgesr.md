# A Tropical Threshold for Vietoris–Rips Completeness: One Scalar Governs Every Dimension

## Abstract

We study the Vietoris–Rips filtration of a finite pseudo-extended-metric space
through the lens of the max-plus (tropical) semiring. To each cloud we attach a
single scalar, the **tropical birth aggregate** `tropBirthSum`, defined as the
tropical sum — that is, the supremum — of the birth times `d(x, y)` of all
edges. Our central result is a *threshold theorem*: the Rips 1-skeleton is
complete at scale `ε` if and only if `tropBirthSum ≤ ε`. We then prove that the
*same* scalar governs completeness in every dimension: for any clique size `m`
with `2 ≤ m ≤ n`, all `m`-element cliques are present at scale `ε` if and only
if `tropBirthSum ≤ ε`. On the combinatorial side, the number of `m`-cliques is
monotone in `ε` and attains its maximum `C(n, m)` exactly at this same tropical
threshold, yielding a discrete-to-tropical reconstruction principle. We
catalogue the supporting structure — a finite extension lemma, monotonicity,
isometry invariance, identification with the metric diameter, and product
laws — and record falsifiable conjectures linking the completeness threshold to
the connectivity (single-linkage / spanning-tree minimax) threshold. All
results have been formally verified.

**Keywords.** Vietoris–Rips complex, tropical geometry, max-plus semiring,
persistent homology, topological data analysis, clique counting, metric
diameter, single-linkage clustering.

---

## 1. Introduction

### 1.1 Motivation

The Vietoris–Rips complex is the workhorse of computational topology. Given a
finite metric space `(α, d)` and a scale parameter `ε ≥ 0`, one forms a
simplicial complex `Rips(α, ε)` whose simplices are the finite subsets of
diameter at most `ε`. Letting `ε` increase produces a *filtration* — a nested
family of complexes — whose persistent homology is the central invariant of
topological data analysis (TDA).

Tropical geometry replaces ordinary arithmetic `(+, ×)` by the max-plus
semiring `(max, +)`. The two subjects meet whenever the *extremal* behavior of
a family of weights, rather than their aggregate sum or product, controls a
phenomenon. This paper makes that meeting precise for the *completeness* of the
Rips complex: the scale at which `Rips(α, ε)` becomes the full simplex on `α`.

### 1.2 Contributions

We prove, over an arbitrary finite *pseudo-extended-metric space* (distances in
`ℝ≥0∞ = [0, ∞]`, with `d(x, y) = 0` permitted for `x ≠ y`):

1. **Tropical birth aggregate** (Definition 3.1) and its **threshold
   characterization** (Theorem 4.1): completeness of the 1-skeleton ⇔
   `tropBirthSum ≤ ε`.
2. A **finite extension lemma** (Lemma 5.1) growing any edge to a clique of
   prescribed size.
3. The **same-threshold theorem** in all dimensions (Theorems 6.1–6.2): for
   `2 ≤ m ≤ n`, all `m`-cliques present ⇔ `tropBirthSum ≤ ε`.
4. **Monotonicity** of clique counts (Proposition 7.1) and the **saturation
   theorem** (Theorems 7.2–7.3): the `m`-clique count equals `C(n, m)` ⇔
   `tropBirthSum ≤ ε`, giving a discrete-to-tropical reconstruction.
5. Structural results: **isometry invariance**, **identification with the
   diameter**, and **product laws** (Section 8).
6. Falsifiable **conjectures** relating completeness to connectivity via
   spanning-tree minimax (Section 10).

All statements have been formalized and machine-checked, with no unproven
assumptions beyond the standard foundational axioms.

### 1.3 Context and perspective

The completeness threshold studied here sits at the far end of every
Vietoris–Rips filtration: it is the scale at which the persistence story ends,
the moment beyond which every homology class of every dimension has died and the
complex is a contractible simplex. Whereas the bulk of TDA is concerned with the
*birth* and *death* of features at intermediate scales, our object is the single
terminal scale, and the contribution is the observation that this scale is a
tropical quantity in the precise algebraic sense.

Two features make the present account unusually clean. First, working over
`ℝ≥0∞` rather than `ℝ` removes all corner cases: the empty supremum is a genuine
bottom element, infinite and pseudo distances are handled uniformly, and no
side-conditions on non-degeneracy are needed. Second, the entire argument
factors through a single supremum identity (the universal property of `⨆`) and a
single finite-combinatorics lemma (the extension lemma). This minimal-input
structure is what lets the same scalar control completeness, clique saturation,
and the full skeleton in every dimension at once, and what makes every statement
amenable to complete formal verification.

The dictionary "tropical addition = max, tropical multiplication = +" is the
organizing metaphor throughout: the threshold theorem reads `tropBirthSum` as a
tropical sum, the `ℓ∞` product law reads metric products as tropical sums, and
the `ℓ¹` product law reads them as tropical products. The Rips construction
thereby becomes a (lax) monoidal functor into the max-plus semiring.

---

## 2. Preliminaries

### 2.1 Pseudo-extended-metric spaces

Throughout, `α` is a finite type with a **pseudo-extended-metric**: a function
`edist : α × α → ℝ≥0∞` (the extended nonnegative reals `[0, ∞]`) that is
symmetric, satisfies the triangle inequality, and has `edist x x = 0`. We do
*not* assume `edist x y = 0 ⟹ x = y` (the "pseudo" relaxation) nor finiteness
of distances (the "extended" relaxation). We write `n = |α|` for the number of
points and `C(n, m)` for the binomial coefficient `n choose m`.

Working in `ℝ≥0∞` rather than `ℝ` is a deliberate choice: it makes the
supremum below always well-defined (the tropical zero `−∞` of the real model
becomes the genuine bottom element `0`-of-the-empty-supremum in `ℝ≥0∞`), and it
covers extended and pseudo distances uniformly.

### 2.2 The max-plus semiring

The **tropical** (max-plus) semiring on `ℝ≥0∞` has tropical addition `a ⊕ b =
max(a, b)` and tropical multiplication `a ⊗ b = a + b`. Tropical addition is
commutative, associative, and idempotent; tropical multiplication distributes
over it because `a + max(b, c) = max(a + b, a + c)`. The tropical *sum* of a
finite family is its supremum. We use only this structural fact: the tropical
sum of a family of extended reals equals their supremum.

### 2.3 The Vietoris–Rips complex

For a scale `ε ∈ ℝ≥0∞`, a finite subset `s ⊆ α` is a **simplex** of
`Rips(α, ε)` when its diameter is at most `ε`, i.e. `edist x y ≤ ε` for all
`x, y ∈ s`. The 1-skeleton consists of the edges `{x, y}` with `edist x y ≤
ε`. The complex is **complete** at scale `ε` when every pair of distinct points
is an edge — equivalently, when `Rips(α, ε)` is the full simplex on `α`.

---

## 3. The tropical birth aggregate

> **Definition 3.1 (tropical birth aggregate).** The **tropical birth
> aggregate** of `α` is the tropical (max-plus) sum of the edge birth times,
> i.e. the supremum
> ```
> tropBirthSum α  :=  ⨆ {x, y : α | x ≠ y}  edist x y
> ```
> taken over all ordered (equivalently, unordered) pairs of distinct points.
> When `|α| ≤ 1` the index set is empty and the supremum is the bottom element
> `0` of `ℝ≥0∞`; in the real `WithBot ℝ` model this is the tropical zero `⊥ =
> −∞`.

Two immediate remarks. First, `tropBirthSum` depends only on the multiset of
pairwise distances, hence is intrinsic to the metric space. Second, because the
supremum is over distinct pairs, adding diagonal terms `edist x x = 0` would
not change its value when a distinct pair exists; this is the source of the
diameter identification in Section 8.

> **Definition 3.2 (Rips clique).** For a scale `ε ∈ ℝ≥0∞`, a finite set `s ⊆
> α` is a **Rips clique at scale `ε`**, written `IsRipsClique ε s`, when
> ```
> ∀ x y ∈ s, x ≠ y ⟹ edist x y ≤ ε.
> ```

> **Definition 3.3 (clique count).** The **`m`-clique count** at scale `ε` is
> ```
> cliqueCount m ε  :=  | { s ⊆ α : |s| = m and IsRipsClique ε s } |,
> ```
> the number of `m`-element Rips cliques at scale `ε`. Formally it is the
> cardinality of the filter of `IsRipsClique ε` over the `m`-element subsets of
> the universe.

---

## 4. The threshold theorem

> **Theorem 4.1 (completeness ⇔ tropical threshold).** For every `ε ∈ ℝ≥0∞`,
> ```
> (∀ x y : α, x ≠ y ⟹ edist x y ≤ ε)   ⇔   tropBirthSum α ≤ ε.
> ```

**Proof sketch.** This is the equivalence `tropBirthSum_le_iff` together with
case analysis on `x = y`. The supremum of a family is `≤ ε` if and only if
every member of the family is `≤ ε` (the defining universal property of
`⨆`). Specializing: `tropBirthSum α ≤ ε` iff `edist x y ≤ ε` for all distinct
`x, y`. The forward direction of the stated equivalence drops the (trivially
satisfied) diagonal case `x = y`, where `edist x x = 0 ≤ ε`; the backward
direction reinstates it. ∎

This is the keystone. The supremum encodes a universal quantifier: the single
inequality `tropBirthSum ≤ ε` is logically equivalent to the conjunction of all
pairwise edge constraints. We record the geometric restatement.

> **Corollary 4.2 (completeness corollary).** The Rips 1-skeleton is complete at
> scale `ε` (all distinct pairs within `ε`) iff `tropBirthSum α ≤ ε`. ∎

---

## 5. The finite extension lemma

The passage from "all `m`-cliques present" back to "all edges present" rests on
the ability to enlarge an edge to a clique of prescribed size while keeping its
endpoints.

> **Lemma 5.1 (finite extension).** Let `x ≠ y` in `α`, and let `m` satisfy
> `2 ≤ m ≤ n`. Then there exists a finite set `s ⊆ α` with `|s| = m`, `x ∈ s`,
> and `y ∈ s`.

**Proof sketch.** The pair `{x, y}` has cardinality `2` (since `x ≠ y`). By the
superset-of-prescribed-cardinality principle (`Finset.exists_superset_card_eq`),
since `2 ≤ m ≤ n`, there is a superset `s ⊇ {x, y}` with `|s| = m`. Both `x`
and `y` lie in `s` because they lie in `{x, y} ⊆ s`. ∎

This is the unique place where finiteness of `α` (via the bound `m ≤ n`) is
essential; everything else is supremum bookkeeping.

---

## 6. The same-threshold theorem in all dimensions

> **Theorem 6.1 (all `m`-cliques ⇔ complete 1-skeleton).** For `2 ≤ m ≤ n`,
> ```
> (∀ s ⊆ α, |s| = m ⟹ IsRipsClique ε s)   ⇔   (∀ x y : α, x ≠ y ⟹ edist x y ≤ ε).
> ```

**Proof sketch.** (⇒) Given distinct `x, y`, use Lemma 5.1 to obtain an
`m`-set `s` containing both. By hypothesis `s` is a clique, so `edist x y ≤ ε`.
(⇐) Any `m`-set `s` is a clique because every distinct pair in it is a distinct
pair of `α`, hence within `ε` by hypothesis. ∎

Combining with Theorem 4.1 gives the central statement.

> **Theorem 6.2 (same tropical threshold in every dimension).** For `2 ≤ m ≤
> n`,
> ```
> (∀ s ⊆ α, |s| = m ⟹ IsRipsClique ε s)   ⇔   tropBirthSum α ≤ ε.
> ```

**Proof sketch.** Chain Theorem 6.1 with Theorem 4.1. ∎

**Discussion.** The content is that the threshold is *independent of `m`*. A
clique of any size requires all of its internal edges; the binding constraint
is always the single longest edge anywhere in the cloud, whose value is exactly
`tropBirthSum`. Thus at the instant `ε` reaches `tropBirthSum`, every clique of
every admissible size appears simultaneously, and the entire Vietoris–Rips
complex (all dimensions at once) becomes the full simplex. There is no
dimension-by-dimension cascade; the high-dimensional complex collapses to a
single tropical scalar at the completeness scale.

---

## 7. Counting, monotonicity, and saturation

> **Proposition 7.1 (monotonicity).** If `ε₁ ≤ ε₂` then every Rips clique at
> scale `ε₁` is a Rips clique at scale `ε₂`; consequently `cliqueCount m ε₁ ≤
> cliqueCount m ε₂`.

**Proof sketch.** `IsRipsClique_mono`: if `edist x y ≤ ε₁ ≤ ε₂` then `edist x y
≤ ε₂`, so the cliqueness predicate is monotone in `ε`. Cardinality is monotone
under the resulting inclusion of filtered subsets. ∎

> **Theorem 7.2 (saturation ⇔ all cliques).** For every `m`,
> ```
> cliqueCount m ε = C(n, m)   ⇔   (∀ s ⊆ α, |s| = m ⟹ IsRipsClique ε s).
> ```

**Proof sketch.** The number of `m`-element subsets of `α` is `C(n, m)` (this
is `Finset.card_powersetCard` with `|α| = n`). The clique count is the
cardinality of the *filter* of `IsRipsClique ε` over those subsets. A filtered
finset has the same cardinality as the original finset iff the predicate holds
on every element (`Finset.filter_card_eq` / `Finset.filter_true_of_mem`). Hence
the count attains its maximum iff every `m`-subset is a clique. ∎

> **Theorem 7.3 (counting form of the tropical bridge).** For `2 ≤ m ≤ n`,
> ```
> cliqueCount m ε = C(n, m)   ⇔   tropBirthSum α ≤ ε.
> ```

**Proof sketch.** Chain Theorem 7.2 with Theorem 6.2. ∎

**Reconstruction principle.** Theorem 7.3 says the *integer* invariant
`cliqueCount m (·)` saturates at precisely the scale where the *tropical*
invariant `tropBirthSum` clears `ε`. Because clique counts are monotone
(Proposition 7.1) and integer-valued, observing the staircase
`ε ↦ cliqueCount m ε` and reading off the least `ε` at which it reaches
`C(n, m)` recovers `tropBirthSum` exactly. A counting functor reconstructs a
tropical scalar — a discrete-to-tropical reconstruction theorem in miniature.

---

## 8. Structural properties

We summarize three further properties established for `tropBirthSum`. They
certify it as a bona fide invariant of finite metric spaces.

### 8.1 Monotonicity / functoriality

The simplex (edge) count `simplexCount : ℝ → ℕ` is monotone in the scale
(`simplexCount_monotone`), exhibiting the Rips construction as a functor on the
poset `(ℝ, ≤)`. Under a `1`-Lipschitz surjection between finite spaces the
tropical aggregate is monotone (`tropBirthSum_mono_of_lipschitz_surj`),
expressing one-sided functoriality of `X ↦ tropBirthSum X`.

### 8.2 Isometry invariance

> **Theorem 8.1 (isometry invariance).** An isometric bijection `f : α → β`
> (i.e. `edist (f x) (f y) = edist x y` for all `x, y`, with `f` bijective)
> induces an equality `tropBirthSum α = tropBirthSum β`. The same holds for the
> edge count `simplexCount`.

This upgrades one-sided functoriality to genuine invariance: `tropBirthSum` is
an isometry invariant. Since it is built from pairwise distances alone, it
cannot distinguish clouds equal up to a distance-preserving relabeling.

### 8.3 Identification with the diameter

> **Theorem 8.2 (diameter identification).** For a finite pseudometric space
> with at least two points,
> ```
> tropBirthSum α  =  diam (univ),
> ```
> the metric diameter (the supremum of pairwise distances). The supremum over
> `univ.offDiag` (distinct pairs) differs from the diameter's supremum only by
> diagonal `0`-terms, which do not affect the value once a distinct pair exists.

Thus the tropical invariant *is* the most classical metric invariant; the whole
theory is a tropical re-reading of the diameter.

### 8.4 Product laws

> **Theorem 8.3 (`ℓ∞` product law).** For finite pseudometric spaces `α, β`
> equipped with the sup (`ℓ∞`) product metric,
> ```
> tropBirthSum (α × β)  =  max( tropBirthSum α, tropBirthSum β )
>                       =  tropBirthSum α  ⊕  tropBirthSum β,
> ```
> i.e. the tropical aggregate of an `ℓ∞`-product is the tropical *sum* of the
> factors. For the `ℓ¹` product metric one has only the upper bound
> `tropBirthSum (α × β) ≤ tropBirthSum α + tropBirthSum β`, the tropical
> *product*.

This turns the "tropical addition = max, tropical multiplication = +"
dictionary into a metric product law: `X ↦ tropBirthSum X` is a (lax) monoidal
functor from finite metric spaces with product to the max-plus semiring.

---

## 9. Algorithms

We record the elementary algorithms implied by the theory. Let `D` be the
`n × n` matrix of pairwise distances.

### 9.1 Tropical birth aggregate

`tropBirthSum` is the maximum off-diagonal entry of `D`:
```
tropBirthSum(D) = max_{i < j} D[i][j].
```
Complexity `O(n²)`, one pass over the upper triangle. By Theorem 8.2 this is the
diameter.

### 9.2 Completeness threshold query

To decide completeness at scale `ε`: return `tropBirthSum(D) ≤ ε` (Theorem
4.1). `O(n²)` precomputation, `O(1)` per query. By Theorem 6.2 the same answer
resolves completeness in every dimension `m`.

### 9.3 Clique count and saturation

For fixed `m`, `cliqueCount(m, ε)` enumerates the `C(n, m)` subsets and tests
the clique predicate, `O(C(n, m) · m²)`. By Theorem 7.3 the count equals
`C(n, m)` iff `ε ≥ tropBirthSum`, so saturation is detectable in `O(n²)` without
enumeration — the expensive count is only needed *below* the threshold.

### 9.4 Connectivity threshold (single-linkage)

For contrast (Section 10), the connectivity threshold is the spanning-tree
minimax `min_T max_{e ∈ T} D[e]`, computed as the largest edge of a minimum
spanning tree (Kruskal/Prim), `O(n² log n)`. It is the bottleneck of
single-linkage clustering and is generally strictly smaller than
`tropBirthSum`.

---

## 10. Conjectures and future work

The following statements are bold, falsifiable, and directly formalizable; they
emerged from the formal development above.

**Conjecture A (connectivity threshold = tropical minimax / single-linkage).**
For a finite pseudometric space with `n ≥ 2`, the connectivity threshold
`εc = inf { ε : Rips(α, ε) is connected }` equals the tropical minimax over
spanning trees, `εc = min_T max_{e ∈ T} d(e)` — the bottleneck (largest edge of
the minimum spanning tree). Completeness uses `max` over *all* edges;
connectivity uses `min`-over-trees of the `max` edge. Both are tropical
reductions of the same distance data. For `{0, 1, 3, 7} ⊂ ℝ`, `εc = 4` (the
largest edge `3↦7` of the minimum spanning tree) while `tropBirthSum = 7`.

**Conjecture B (`tropBirthSum` is exactly the diameter).** For `n ≥ 2`,
`tropBirthSum α = diam(univ)`. (Established as Theorem 8.2 in the present
development; restated here as the anchor identifying the tropical invariant with
the most classical one and, combined with isometry invariance, certifying it as
the canonical scalar invariant of the cloud.)

**Conjecture 2 (product law — established).** `ℓ∞`: `tropBirthSum(α × β) =
max(tropBirthSum α, tropBirthSum β)` (Theorem 8.3). `ℓ¹`: only `≤
tropBirthSum α + tropBirthSum β`. Monoidal-functor statement for Rips →
Tropical.

**Conjecture 3 (monotone count determines the threshold — established).**
`tropBirthSum α = inf { ε : simplexCount α ε = #univ.offDiag }` via saturation
plus right-continuity of `simplexCount` (the edge-count specialization of
Theorem 7.3).

**Conjecture 4 (functor laws — established).** Isometric bijections induce
`tropBirthSum α = tropBirthSum β` (Theorem 8.1), and the contraction bound
composes through `1`-Lipschitz surjections, upgrading one-sided functoriality
to invariance.

**Conjecture 5 (higher simplices — established).** For every `k`,
`cliqueCount α k` is monotone in `ε` (Proposition 7.1), and the full
`k`-skeleton is present at scale `ε` iff `tropBirthSum α ≤ ε` (Theorem 6.2):
the same tropical scalar governs every dimension.

The principal open problem is **Conjecture A**, the contrast between the
completeness threshold (`max` over edges) and the connectivity threshold
(`min`-over-trees of the `max` edge). Proving it would realize single-linkage
clustering inside the tropical semiring and exhibit both tropical operations
acting on a single metric input.

---

## 11. Conclusion

The Vietoris–Rips complex of a finite metric space, despite its
high-dimensional combinatorial richness, has a completeness threshold governed
by a single tropical scalar. The tropical birth aggregate `tropBirthSum` — the
max-plus sum (supremum) of edge birth times — equals the metric diameter, is an
isometry invariant, combines by tropical addition under `ℓ∞` products, and
simultaneously controls completeness, clique saturation, and the full-skeleton
threshold in every dimension. Beneath the foliage of topological data analysis
runs a tropical root, and it is a maximum.
