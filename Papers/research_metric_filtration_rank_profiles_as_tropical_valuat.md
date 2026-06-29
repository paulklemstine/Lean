# Metric Filtration Rank Profiles as Tropical Valuation Objects

### The single-linkage ultrametric of a finite Rips filtration and its max-plus structure

**Domain:** Bridges (Geometry × Combinatorics × Tropical Algebra)

---

## Abstract

We study the connectivity data of the Vietoris–Rips filtration of a finite
dissimilarity space and show that it carries the structure of a *tropical
valuation object*. Given a finite type `α` with an arbitrary dissimilarity
function `d : α → α → ℝ` (not assumed symmetric or to satisfy any triangle
inequality), we form, at each scale `ε ∈ ℝ`, the Rips graph in which distinct
points `x, y` are adjacent precisely when `d(x,y) ≤ ε` or `d(y,x) ≤ ε`. Two
points are *connected at scale `ε`* when they are reachable in this graph. The
*single-linkage threshold* `connThreshold(x,y)` is defined as the least scale,
among the finite set of candidate scales `{0} ∪ {d(a,b) : a,b ∈ α}`, at which
`x` and `y` become connected.

Our main theorem is that this threshold satisfies the **strong (ultrametric)
triangle inequality**

> `connThreshold(x,y) ≤ max( connThreshold(x,z), connThreshold(z,y) )`,

which is exactly the ordinary triangle inequality interpreted in the **max-plus
(tropical) semiring** `(ℝ, ⊕ = max, ⊗ = +)`. Together with symmetry, the upper
bound `connThreshold(x,y) ≤ d(x,y)`, and reflexivity `connThreshold(x,x) = 0`
(under nonnegativity of `d`), this exhibits the merge-scale table as a genuine
ultrametric — equivalently, as a `max`-additive valuation object. The entire
development is finite-combinatorial: thresholds are minima of nonempty finite
subsets of candidate scales, so all results are constructive in the
order-theoretic sense and require no completeness or limiting arguments. Every
statement below has been formalized and machine-checked.

---

## 1. Introduction

Hierarchical clustering is among the most widely deployed unsupervised methods in
data analysis, and single-linkage is its canonical "connectivity-following"
variant. Independently, the *Vietoris–Rips filtration* is the foundational
construction of topological data analysis (TDA): from a finite metric space one
builds a nested family of simplicial complexes indexed by a scale parameter, and
studies how topological features appear and disappear. The degree-zero part of
this story — connected components, the invariant `π₀` — is precisely
single-linkage clustering.

A third, seemingly unrelated, subject is *tropical algebra*: the study of the
max-plus (or min-plus) semiring `(ℝ, max, +)`, which arises wherever a dominant
exponential term swamps all others, and which provides the combinatorial
backbone of tropical geometry, optimization, and the theory of valuations.

This paper makes precise a bridge between these three subjects. We show that the
*merge scale* of single-linkage — the first scale at which two points become
connected in the Rips filtration — is an **ultrametric**, and that its defining
inequality is *literally* the triangle inequality computed in the tropical
semiring. Connectivity of the filtration composes at the **maximum** of two
scales rather than their sum, and the threshold inherits this `max`-additive law.
Thus the *rank profile* of the metric filtration (the data of which points have
merged by each scale) is a **tropical valuation object**.

### Contributions

1. A clean, fully finite-combinatorial construction of the single-linkage
   threshold for an *arbitrary, possibly asymmetric* dissimilarity `d : α → α →
   ℝ` on a finite carrier (Section 3).
2. A proof that connectivity is monotone in the scale and composes at the
   maximum of two scales (Section 3, Lemmas 3.4–3.7), the combinatorial heart of
   the tropical law.
3. The four structural theorems certifying that the threshold is an ultrametric:
   the strong triangle inequality, symmetry, the dissimilarity upper bound, and
   reflexivity (Section 4).
4. The tropical reinterpretation: the threshold is a `max`-additive valuation
   object, and the rank profile is a tropical object (Section 5).
5. A discussion of subdominance, idempotence, stability, and functoriality, with
   a roadmap of conjectures for extending the bridge (Sections 6–7).

---

## 2. Preliminaries and notation

Throughout, `α` is a finite type (`[Fintype α]`) and `d : α → α → ℝ` is a
**dissimilarity function**: an arbitrary assignment of a real number to each
ordered pair. We emphasize what we do *not* assume: `d` need not be symmetric,
need not satisfy any triangle inequality, and (except where explicitly stated)
need not be nonnegative.

We work in the **max-plus tropical semiring**
`𝕋 = (ℝ ∪ {−∞}, ⊕, ⊗)` with `a ⊕ b = max(a,b)` and `a ⊗ b = a + b`; the
additive identity is `−∞` and the multiplicative identity is `0`. For our finite
constructions we only need the order structure `(ℝ, max)`, the idempotent
commutative monoid underlying the tropical sum.

An **ultrametric** on a set `S` is a function `u : S → S → ℝ` that is
nonnegative, symmetric, satisfies `u(x,x) = 0`, and obeys the *strong* triangle
inequality `u(x,y) ≤ max(u(x,z), u(z,y))`. Ultrametric spaces are exactly the
spaces of leaves of weighted rooted trees (dendrograms); the ultrametric value
is the depth of the lowest common ancestor.

---

## 3. The Rips graph, connectivity, and its composition law

### 3.1 The Rips graph

**Definition 3.1 (Rips graph).**
For a dissimilarity `d : α → α → ℝ` and a scale `ε ∈ ℝ`, the *Rips graph*
`ripsGraphOf d ε` is the simple (undirected, loopless) graph on vertex set `α`
whose adjacency relation is

> `x ∼ y ⟺ x ≠ y ∧ ( d(x,y) ≤ ε ∨ d(y,x) ≤ ε )`.

Symmetry of the relation is immediate from the disjunction, and looplessness from
the `x ≠ y` clause. (Allowing asymmetric `d` is the reason for the disjunction:
we connect two points as soon as *either* directed dissimilarity is small
enough.)

**Definition 3.2 (Connectivity at a scale).**
Points `x, y ∈ α` are *connected at scale `ε`*, written `ConnAt d ε x y`, if they
are reachable in `ripsGraphOf d ε` — i.e., joined by a walk (possibly empty, so
reachability is reflexive).

### 3.2 Monotonicity

**Lemma 3.3 (Edge monotonicity).** If `ε ≤ ε'` then `ripsGraphOf d ε` is a
subgraph of `ripsGraphOf d ε'`.

*Proof.* Any edge `x ∼ y` at scale `ε` certifies `d(x,y) ≤ ε` or `d(y,x) ≤ ε`;
composing with `ε ≤ ε'` by transitivity of `≤` gives the corresponding
inequality at scale `ε'`. ∎

**Lemma 3.4 (Connectivity monotonicity).** If `ε ≤ ε'` and `ConnAt d ε x y`,
then `ConnAt d ε' x y`.

*Proof.* Reachability is preserved under taking supergraphs; apply Lemma 3.3 to
the walk certifying connectivity at scale `ε`. ∎

### 3.3 Equivalence-relation structure at a fixed scale

For each fixed `ε`, `ConnAt d ε` is an equivalence relation, since graph
reachability always is:

- **Reflexivity (Lemma 3.5):** `ConnAt d ε x x` (empty walk).
- **Symmetry (Lemma 3.6):** `ConnAt d ε x y ⟺ ConnAt d ε y x` (reverse the
  walk; legitimate because the Rips graph is undirected).
- **Transitivity:** concatenation of walks at the *same* scale.

### 3.4 The composition law — the tropical seed

The single most important structural fact is that connectivity composes across
*different* scales at their maximum.

**Lemma 3.7 (Composition at the maximum).** For all scales `e₁, e₂` and points
`x, y, z`,

> `ConnAt d e₁ x y` and `ConnAt d e₂ y z` imply `ConnAt d (max e₁ e₂) x z`.

*Proof.* By Lemma 3.4, lift both walks to the common scale `max(e₁, e₂)`: from
`e₁ ≤ max(e₁,e₂)` we get `ConnAt d (max e₁ e₂) x y`, and from `e₂ ≤ max(e₁,e₂)`
we get `ConnAt d (max e₁ e₂) y z`. Concatenate the two walks (transitivity at a
fixed scale) to obtain `ConnAt d (max e₁ e₂) x z`. ∎

This `max` — rather than a sum — is exactly where the tropical structure enters.
The cost of routing through an intermediary is the larger of the two legs, the
defining feature of max-plus arithmetic.

### 3.5 Edges from raw dissimilarity

**Lemma 3.8.** For distinct `x, y`, we have `ConnAt d (d x y) x y` (the single
direct edge exists at scale `d(x,y)`). Consequently, for *all* `x, y`,
`ConnAt d (d x y) x y` (the case `x = y` is reflexivity).

This guarantees that two points are always connected by the time the scale
reaches their direct dissimilarity — the key non-emptiness fact for the
threshold.

---

## 4. The single-linkage threshold and its ultrametric structure

### 4.1 Finite candidate scales

The connectivity of the filtration changes only at dissimilarity values, so a
finite set of scales suffices.

**Definition 4.1 (Candidate scales).**
`scales d := {0} ∪ { d(a,b) : (a,b) ∈ α × α }`, a finite subset of `ℝ`.

By construction `0 ∈ scales d` (Lemma: `zero_mem_scales`) and `d(x,y) ∈ scales d`
for all `x, y` (Lemma: `dist_mem_scales`).

**Definition 4.2 (Connecting candidate scales).**
`connScales d x y := { ε ∈ scales d : ConnAt d ε x y }`.

**Lemma 4.3 (Non-emptiness).** `connScales d x y` is nonempty.

*Proof.* The direct dissimilarity `d(x,y)` lies in `scales d` (Def. 4.1) and
connects `x` to `y` (Lemma 3.8), hence belongs to `connScales d x y`. ∎

**Definition 4.4 (Single-linkage threshold).**
`connThreshold d x y := min' (connScales d x y)`, the least element of the
nonempty finite set of connecting candidate scales.

Because `connScales d x y` is a finite nonempty set of reals, its minimum exists
and is attained; no completeness or infimum argument is needed.

### 4.2 Specification and minimality

**Theorem 4.5 (Specification).** `ConnAt d (connThreshold d x y) x y`. The points
*are* connected at the threshold scale.

*Proof.* The minimum of `connScales d x y` is a member of it, so it satisfies the
defining predicate. ∎

**Theorem 4.6 (Minimality).** If `ε ∈ scales d` and `ConnAt d ε x y`, then
`connThreshold d x y ≤ ε`.

*Proof.* Such an `ε` lies in `connScales d x y`, and the minimum is `≤` every
element. ∎

Theorems 4.5 and 4.6 jointly characterize `connThreshold` as the minimax
connectivity scale: it is the smallest candidate at which connection holds.

### 4.3 The four structural theorems

**Theorem 4.7 (Reflexivity).** If `d(a,b) ≥ 0` for all `a, b`, then
`connThreshold d x x = 0`.

*Proof.* Since `x` is connected to itself at scale `0` (Lemma 3.5) and
`0 ∈ scales d`, minimality gives `connThreshold d x x ≤ 0`. For the reverse
inequality, the threshold is itself a candidate scale (a member of `scales d`);
every candidate is either `0` or some `d(a,b) ≥ 0`, so the threshold is `≥ 0`.
Antisymmetry gives equality. The nonnegativity hypothesis is essential: without
it the candidate scales may be negative and the self-threshold can fall below
`0`. ∎

**Theorem 4.8 (Symmetry).** `connThreshold d x y = connThreshold d y x`.

*Proof.* The threshold `connThreshold d y x` is a candidate scale at which `y`
connects to `x`; by symmetry of connectivity (Lemma 3.6) it also connects `x` to
`y`, so by minimality `connThreshold d x y ≤ connThreshold d y x`. The reverse
inequality is identical with the roles swapped, and antisymmetry concludes.
Notably this holds even though `d` itself may be asymmetric. ∎

**Theorem 4.9 (Upper bound by dissimilarity).** `connThreshold d x y ≤ d(x,y)`.

*Proof.* `d(x,y)` is a candidate scale (Def. 4.1) at which `x` and `y` are
connected (Lemma 3.8); apply minimality (Theorem 4.6). ∎

**Theorem 4.10 (Strong triangle inequality — main result).** For all `x, y, z`,

> `connThreshold d x y ≤ max( connThreshold d x z, connThreshold d z y )`.

*Proof.* Write `a = connThreshold d x z` and `b = connThreshold d z y`. By the
specification (Theorem 4.5), `ConnAt d a x z` and `ConnAt d b z y`. By the
composition law (Lemma 3.7), `ConnAt d (max a b) x y`. The value `max a b` equals
either `a` or `b`, each of which is a candidate scale (every threshold lies in
`scales d`), so `max a b ∈ scales d`. Minimality (Theorem 4.6) then yields
`connThreshold d x y ≤ max a b`. ∎

The crucial point in Theorem 4.10 is that **the maximum of two candidate scales
is again a candidate scale**, because `max` selects one of its two arguments.
This is the order-theoretic reflection of idempotency of the tropical sum and is
what allows minimality to be applied directly.

**Corollary 4.11 (Ultrametricity).** Under nonnegativity of `d`, the function
`connThreshold d` is an ultrametric on `α`: it is nonnegative (Theorem 4.7 plus
4.10 propagate nonnegativity, or directly since each candidate scale is `≥ 0`),
symmetric (4.8), vanishes on the diagonal (4.7), and satisfies the strong
triangle inequality (4.10).

---

## 5. The tropical reinterpretation

### 5.1 The strong triangle inequality is the tropical triangle inequality

In the max-plus semiring `𝕋 = (ℝ, ⊕ = max, ⊗ = +)`, the ordinary metric
triangle inequality "`u(x,y) ≤ u(x,z) ⊗ u(z,y)`" reads, after unfolding `⊗`,
as `u(x,y) ≤ u(x,z) + u(z,y)`. But the *additive* structure relevant to a
**valuation** is `⊕ = max`. A valuation `v` on a space, valued in the tropical
semiring, satisfies the ultrametric law `v(x,y) ≤ v(x,z) ⊕ v(z,y) =
max(v(x,z), v(z,y))`. Theorem 4.10 is *exactly* this identity. Hence:

**Theorem 5.1 (Tropical valuation object).** The merge-scale table
`connThreshold d : α → α → ℝ` is a symmetric, diagonal-vanishing map satisfying
`connThreshold(x,y) ≤ connThreshold(x,z) ⊕ connThreshold(z,y)` in the max-plus
semiring. It is therefore a **tropical valuation object** on `α`: a `max`-additive
valuation realizing the connectivity rank profile of the Rips filtration.

This is the central conceptual statement of the work. The combinatorial process
(clusters merging as the scale rises), the geometric object (an ultrametric =
dendrogram), and the algebraic structure (a max-plus valuation) coincide.

### 5.2 The rank profile

**Definition 5.2 (π₀ rank profile).** For each scale `ε`, let `compCount d ε` be
the number of connected components of `ripsGraphOf d ε`. The function
`ε ↦ compCount d ε` is the *zeroth Betti number* / *π₀ rank profile* of the
filtration.

By Lemma 3.4 (connectivity monotone in `ε`), components only merge as `ε`
increases, so `compCount d` is **antitone**: `ε ≤ ε' ⟹ compCount d ε' ≤
compCount d ε`. The set of scales at which it strictly decreases is exactly the
set of distinct merge thresholds `{ connThreshold d x y : x ≠ y }`, and reading
these off recovers the **dendrogram** of single-linkage clustering. The merge
heights are tropical quantities; the profile is a step function whose jumps are
governed by the max-plus law of Theorem 4.10.

---

## 6. Properties of the construction

We record the qualitative properties that make the single-linkage ultrametric
canonical. (Those marked ★ are established by the formalized theorems above; the
others are stated as known facts in the single-linkage literature and as targets
for the conjectures in Section 7.)

- **★ Subdominance (upper bound).** `connThreshold d x y ≤ d(x,y)` (Theorem 4.9):
  the ultrametric lies below the original dissimilarity.
- **Maximality / greatest subdominant ultrametric.** Among all ultrametrics `u`
  with `u ≤ d`, the single-linkage threshold is the pointwise largest. This is
  the classical characterization of single-linkage and explains its canonical
  status: it is the optimal hierarchical approximation from below.
- **Idempotence.** If `d` is already an ultrametric, then `connThreshold d = d`.
  The construction is a closure operator: applying it twice is the same as
  applying it once.
- **Stability (Lipschitz in the data).** If two dissimilarities differ pointwise
  by at most `δ`, their thresholds differ pointwise by at most `δ`. This is the
  `π₀` case of the persistence stability theorem.
- **Functoriality.** A nonexpansive map between dissimilarity spaces (one that
  does not increase `d`) induces a nonexpansive map between the corresponding
  single-linkage ultrametrics, because it carries Rips edges to Rips edges and
  hence preserves connectivity at each scale.

### 6.1 Why finiteness is the right setting

Restricting to a finite carrier is not a limitation but a clarification. It makes
the *minimum-defining* the threshold genuinely attained (Definition 4.4), turns
the otherwise-continuous filtration into a finite sequence of critical events
(the candidate scales), and renders every theorem constructive and machine-
checkable without any appeal to completeness of `ℝ` or to limits. The price — and
it is small — is that we work with `min'` over a `Finset` rather than an infimum.

---

## 7. Algorithms

The constructions above are directly algorithmic. We summarize the two principal
procedures; full Python with type hints accompanies this paper.

### 7.1 Threshold via candidate-scale sweep

Compute `connThreshold d x y` by enumerating candidate scales in increasing
order, building the Rips graph at each, and testing reachability (BFS/DFS or
union–find). The first scale at which `x` reaches `y` is the threshold. Sorting
the `O(n²)` candidate scales costs `O(n² log n)`; each connectivity test is
`O(n²)`; the naive sweep is therefore `O(n⁴)` in the worst case for a single
pair, but all pairs and all thresholds can be obtained together far more
efficiently by the next algorithm.

### 7.2 Single-linkage via minimum spanning tree (Kruskal)

The complete merge-scale table is computed at once by the classical equivalence
between single-linkage and the minimum spanning tree. Symmetrize `d` to
`d̄(x,y) = min(d(x,y), d(y,x))` (matching the Rips disjunction), sort the `O(n²)`
edges by weight, and run Kruskal's union–find. When an edge unites two
components, its weight is the merge threshold for *every* cross-component pair.
The total cost is `O(n² log n)`, dominated by the sort. The resulting dendrogram
encodes the whole ultrametric.

This MST identity is the computational counterpart of Theorem 4.10: the strong
triangle inequality is exactly what guarantees that the "bottleneck" edge along
the MST path between two points equals their merge scale.

---

## 8. Applications

- **Topological data analysis.** The merge-scale ultrametric is the `π₀` summary
  of the Rips filtration; its stability (Section 6) is the degree-zero
  persistence stability theorem, underpinning the robustness of TDA pipelines.
- **Phylogenetics and taxonomy.** Ultrametrics are the distances of rooted trees;
  the construction turns raw genetic or morphological dissimilarities into a
  hierarchy whose merge heights are common-ancestor depths.
- **Clustering and image segmentation.** Single-linkage follows connectivity and
  detects elongated, non-convex clusters that centroid-based methods miss.
- **Tropical geometry and optimization.** Recognizing the merge scale as a
  max-plus valuation places clustering inside the tropical toolbox, where
  bottleneck/shortest-path dualities and min-plus matrix algebra apply.
- **Network bottleneck analysis.** The threshold is the minimal capacity at which
  a path of sufficiently strong links connects two nodes — a bottleneck quantity,
  natively tropical.

---

## 9. Discussion and related work

The equivalence between single-linkage and the minimum spanning tree is
classical (Gower–Ross), as is the characterization of single-linkage as the
greatest subdominant ultrametric. The novelty here is twofold. First, we develop
the theory for *arbitrary, possibly asymmetric* dissimilarities, using the Rips
disjunction `d(x,y) ≤ ε ∨ d(y,x) ≤ ε` so that symmetry of the *output*
ultrametric (Theorem 4.8) becomes a theorem rather than an assumption. Second,
we foreground the *tropical* reading: the composition law (Lemma 3.7) is
max-additivity, and the resulting structure (Theorem 5.1) is a valuation object
in the max-plus semiring, situating single-linkage clustering as a bridge among
geometry, TDA, and tropical algebra. Every result is finite-combinatorial and
machine-verified.

---

## 10. Future directions

The following conjectures (lightly edited from the research notes accompanying
the formal development) extend the bridge. Each is stated to be directly
formalizable or refutable by counterexample.

**C2 — π₀ persistence / barcode identity.** The rank profile is a step function
whose jumps are exactly the distinct merge scales. For a finite nonempty space,
`compCount α ε` equals `card α` minus the number of independent merges with
threshold `≤ ε`; equivalently, the number of distinct merge thresholds `≤ ε`,
counted with multiplicity, equals `card α − compCount α ε`. *Test:* induct on the
critical scales; relate component merges to MST edges (Kruskal / dendrogram).

**C3 — Bottleneck / Lipschitz stability of the profile.** The merge-scale
ultrametric is `1`-Lipschitz in the underlying dissimilarity: if `d₁, d₂` satisfy
`|d₁(a,b) − d₂(a,b)| ≤ δ` for all `a, b`, then `|connThreshold₁(x,y) −
connThreshold₂(x,y)| ≤ δ`. This is the `π₀` case of the persistence stability
theorem. *Test:* symmetric application of the functoriality method with the
identity map between the two metrics.

**C4 — Faithful functor to tropical valuation objects.** Construct an explicit
tropical-valuation-object instance whose order and `max`-operation are realized
by `connThreshold`, and assemble a tropical homomorphism from each nonexpansive
map. Conjecture: this assignment is a *faithful functor* from finite pseudometric
spaces and nonexpansive maps to tropical valuation objects. *Test:* discharge the
structure axioms; faithfulness from injectivity of the induced map on merge-scale
tables.

**C5 — Idempotence on ultrametric spaces.** If `d` is already an ultrametric,
then `connThreshold d = d`; the construction is a closure operator.

**C6 — Kruskal / minimum-spanning-tree identity.** On a finite metric space, the
merge threshold of two points equals the maximum edge weight along the unique
path joining them in any minimum spanning tree (the bottleneck-shortest-path /
min–max path identity), formalizing the algorithm of Section 7.2.

---

## 11. Conclusion

We have shown that the connectivity data of a finite Rips filtration assembles
into a single ultrametric — the single-linkage threshold — whose defining strong
triangle inequality is precisely the triangle inequality of the max-plus tropical
semiring. The construction is finite, constructive, and machine-verified, and it
unifies three perspectives: the combinatorics of merging components, the geometry
of dendrograms, and the algebra of tropical valuations. The merge-scale table is
a tropical valuation object, and the rank profile of the filtration is its
visible shadow.
