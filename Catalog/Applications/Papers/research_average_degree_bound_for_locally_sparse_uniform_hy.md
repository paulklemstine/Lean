# Representative-Vertex Deletion and an Average-Degree Independence Bound for Hypergraphs

**Author:** Aristotle
**Domain:** Bridges (Combinatorics / Probabilistic Method)
**Date:** 2026-06-19

## Abstract

We present a fully explicit, deterministic construction — *representative-vertex
deletion* — that, given a finite hypergraph `E` over a linearly ordered vertex
type and a vertex pool `S`, produces an independent subset of `S` of certified
size. The construction selects, for every hyperedge contained in `S`, a single
canonical representative (its minimum vertex) and deletes the set of all
representatives from `S`. We prove that the resulting set is contained in `S`, is
independent (contains no nonempty hyperedge), and has cardinality at least
`|S| − |E ∩ E(S)|`, where `E ∩ E(S)` is the set of hyperedges contained in `S`.
Via an incidence double-counting argument we bound the number of contained edges
by the total degree over `S`, and obtain the clean **average-degree form**: if
every hyperedge is nonempty and the average degree of `E` over `S` is at most δ,
then the construction yields an independent set of size at least `(1 − δ)·|S|`.
This deterministic engine is the constructive core underlying the probabilistic
deletion method and the locally-sparse independence-number refinements; we
discuss how it extends. All results stated here have been formalized and
machine-verified.

---

## 1. Introduction

### 1.1 Motivation

The independence number of a hypergraph — the size of the largest vertex set that
contains no hyperedge — is a central invariant of extremal and probabilistic
combinatorics. It governs problems ranging from frequency assignment and coding
to combinatorial discrepancy and the design of confounder-free experiments. Exact
computation is intractable in general, so the field is organized around
*guarantees*: lower bounds on the independence number that hold uniformly over all
hypergraphs satisfying mild density constraints.

The most flexible source of such guarantees is the **deletion method**: one
selects a candidate set (deterministically or at random), then repairs it into an
independent set by removing one vertex from every offending hyperedge. The
probabilistic incarnation samples a random subset and argues via linearity of
expectation that a good outcome exists. The argument is elegant but
non-constructive — it certifies existence, not an explicit witness.

### 1.2 Contribution

We isolate and prove the **deterministic skeleton** of the deletion method. Fixing
a linear order on the vertices makes the per-edge repair choice canonical: take
the minimum vertex of each contained edge. This yields a computable function from
`(E, S)` to an explicit independent set, with three provable guarantees
(containment, independence, size) and a clean average-degree corollary. The
deterministic version implies the probabilistic one by taking expectations
pointwise, and serves as the reusable base layer for first-moment, uniform, and
locally-sparse refinements.

### 1.3 Context

Lower bounds on hypergraph independence numbers form a long and active thread of
combinatorics. The probabilistic deletion (or *alteration*) method gives, for an
`r`-uniform hypergraph of average degree `d`, an independent set of size of order
`|V| / d^{1/(r-1)}`. For *uncrowded* hypergraphs — those avoiding Berge 2-, 3-, and
4-cycles — a celebrated semi-random ("nibble") argument improves this by a
logarithmic factor to order `(|V| / d^{1/(r-1)}) · (\log d)^{1/(r-1)}`. A natural
question, and the framing motivating this package, is how far the average-degree
improvement extends as the cycle restrictions are relaxed: from uncrowded to the
broader *locally sparse* class (forbidding only Berge 2- and 3-cycles), paralleling
the maximum-degree story. Every such refinement, however sophisticated its
fluctuation analysis, ultimately repairs a candidate set into an independent one by
deleting vertices from offending edges. It is exactly that repair step — stripped
of randomness and made canonical — that we formalize and certify here, so that the
harder analytic layers can be built on a verified foundation.

### 1.4 Organization

Section 2 fixes definitions. Section 3 states and sketches the proofs of the main
results. Section 4 gives algorithms and complexity. Section 5 discusses
applications and the relationship to the probabilistic method. Section 6 outlines
future directions.

---

## 2. Definitions

Throughout, `V` is a type equipped with a linear order, and a *hypergraph* is a
finite set of hyperedges `E : Finset (Finset V)`; each hyperedge is itself a
finite set of vertices. A vertex pool is a finite set `S : Finset V`. We write
`|X|` for the cardinality of a finite set `X`.

**Definition 2.1 (Complete edge set, `edgeSet`).**
For a pool `S`, the edge set of the *complete* hypergraph on `S` is
`E(S) := edgeSet S := S.powerset`, the family of all subsets of `S`.

**Definition 2.2 (Contained edges, `containedEdges`).**
The hyperedges of `E` that live inside `S` are
`containedEdges E S := E ∩ E(S)`. Equivalently (Lemma 3.1),
`e ∈ containedEdges E S` iff `e ∈ E` and `e ⊆ S`.

**Definition 2.3 (Independence, `IsIndependent`).**
A vertex set `I` is *independent* for `E` when it contains no nonempty hyperedge:
`IsIndependent E I :⇔ ∀ e ∈ E, e.Nonempty → ¬ (e ⊆ I)`.
The empty edge, if present, cannot be removed by vertex deletion and is therefore
excluded by fiat; all bounds concern nonempty edges.

**Definition 2.4 (Deleted representatives, `deletedVertices`).**
For each contained edge we delete its canonical representative, the minimum vertex
under the linear order:
`deletedVertices E S := ⋃_{e ∈ containedEdges E S} (if e.Nonempty then {min' e} else ∅)`,
where the union is a `Finset.biUnion`. Empty edges contribute nothing.

**Definition 2.5 (Representative-vertex deletion, `deterministic_deletion`).**
The construction removes all representatives from the pool:
`deterministic_deletion E S := S \ deletedVertices E S`.
We abbreviate the resulting set as `I := deterministic_deletion E S`.

**Definition 2.6 (Degree, `degree`).**
The degree of a vertex `v` in `E` is the number of hyperedges containing it:
`degree E v := |{ e ∈ E : v ∈ e }|`.

**Definition 2.7 (Average degree, `averageDegree`).**
The average degree of `E` over `S` is the rational number
`averageDegree E S := (∑_{v ∈ S} degree E v) / |S|`.

---

## 3. Main results

### 3.1 Basic membership and the deletion mechanism

**Lemma 3.1 (`mem_containedEdges`).**
For all `e`, `e ∈ containedEdges E S ↔ e ∈ E ∧ e ⊆ S`.

*Proof sketch.* Unfold `containedEdges = E ∩ edgeSet S` and `edgeSet S =
S.powerset`; membership in `S.powerset` is exactly `e ⊆ S`, and membership in an
intersection is the conjunction. ∎

**Lemma 3.2 (`min'_mem_deletedVertices`).**
If `e ∈ containedEdges E S` and `e` is nonempty, then `min' e ∈ deletedVertices E S`.

*Proof sketch.* `min' e` is the witness of the `e`-summand `{min' e}` of the
`biUnion` defining `deletedVertices`; membership of `e` in `containedEdges E S`
licenses that summand, so `min' e` lies in the union. ∎

### 3.2 The three guarantees

**Theorem 3.3 (Containment, `deterministic_deletion_subset`).**
`deterministic_deletion E S ⊆ S`.

*Proof sketch.* The construction is `S \ deletedVertices E S`, a set difference, so
it is contained in `S` immediately. ∎

**Lemma 3.4 (Deletion cost, `deletedVertices_card_le`).**
`|deletedVertices E S| ≤ |containedEdges E S|`.

*Proof sketch.* `deletedVertices` is a `biUnion` over `containedEdges E S` whose
each summand is a singleton (or empty). By the union-cardinality bound,
`|⋃ f| ≤ ∑ |f|`, and each `|f(e)| ≤ 1`; hence the total is at most the number of
summands, `|containedEdges E S|`. ∎

**Theorem 3.5 (Independence, `deterministic_deletion_independent`).**
`IsIndependent E (deterministic_deletion E S)`.

*Proof sketch.* Let `e ∈ E` be nonempty with `e ⊆ I`, aiming for a contradiction.
From `e ⊆ I ⊆ S` we get `e ∈ containedEdges E S` (Lemma 3.1). Then `min' e` is one
of the deleted representatives (Lemma 3.2), so `min' e ∉ I = S \ deletedVertices E
S`. But `min' e ∈ e ⊆ I` (the minimum of a nonempty finite set is a member),
contradiction. Hence no nonempty edge is contained in `I`. ∎

**Theorem 3.6 (Size bound, `deterministic_deletion_card_ge`).**
`|S| − |containedEdges E S| ≤ |deterministic_deletion E S|`.

*Proof sketch.* Since `deletedVertices E S ⊆ S` (each representative is the
minimum of an edge `⊆ S`), the set-difference cardinality identity gives
`|S \ deletedVertices E S| = |S| − |deletedVertices E S|`. Combine with Lemma 3.4
(`|deletedVertices E S| ≤ |containedEdges E S|`) and monotonicity of truncated
subtraction. ∎

**Theorem 3.7 (Specification, `deterministic_deletion_spec`).**
The set `I := deterministic_deletion E S` simultaneously satisfies:
(i) `I ⊆ S`; (ii) `IsIndependent E I`; (iii) `|S| − |containedEdges E S| ≤ |I|`.

*Proof sketch.* The conjunction of Theorems 3.3, 3.5, and 3.6. ∎

### 3.3 The average-degree form

**Lemma 3.8 (Incidence bound, `containedEdges_card_le_sum_degree`).**
If every hyperedge of `E` is nonempty, then
`|containedEdges E S| ≤ ∑_{v ∈ S} degree E v`.

*Proof sketch.* Every contained edge `e` is nonempty and satisfies `e ⊆ S`, so it
contains at least one vertex `v ∈ S`. Thus the map sending `e` to the family of
contained edges through each `v ∈ S` exhibits `containedEdges E S` as a subset of
`⋃_{v ∈ S} { e ∈ containedEdges E S : v ∈ e }`. Apply `|⋃| ≤ ∑ |·|` and note that
`|{ e ∈ containedEdges E S : v ∈ e }| ≤ |{ e ∈ E : v ∈ e }| = degree E v`. ∎

**Theorem 3.9 (Average-degree independence bound,
`deterministic_deletion_card_ge_of_averageDegree`).**
If every hyperedge of `E` is nonempty and `averageDegree E S ≤ δ`, then
`(1 − δ)·|S| ≤ |deterministic_deletion E S|`.

*Proof sketch.* By Definition 2.7, `∑_{v∈S} degree E v = averageDegree E S · |S| ≤
δ·|S|`. By Lemma 3.8, `|containedEdges E S| ≤ ∑_{v∈S} degree E v ≤ δ·|S|`.
Substitute into Theorem 3.6:
`|I| ≥ |S| − |containedEdges E S| ≥ |S| − δ·|S| = (1 − δ)·|S|`.
(The casts between natural-number cardinalities and the rational/real average are
handled at the boundary; the inequality is stated over an ordered field.) ∎

This is the headline result: a uniform, explicit, randomness-free lower bound on
the independence number of `S`, controlled by a single scalar, the average degree.

### 3.4 A worked example

To see the chain of results operate concretely, take the pool `S = {1, …, 16}`
(so `|S| = 16`) and the 3-uniform hypergraph with two edges,
`E = { {1,2,3}, {4,5,6} }`. Both edges are subsets of `S`, so
`containedEdges E S = E` and `|containedEdges E S| = 2`. The canonical
representatives are the minima `1` and `4`, so
`deletedVertices E S = {1, 4}` and
`deterministic_deletion E S = {2,3,5,6,7,8,…,16}`, a set of size `14`.

Let us audit the guarantees. Containment (Theorem 3.3) is visible: every survivor
is one of the original sixteen vertices. Independence (Theorem 3.5) holds because
`{1,2,3}` lost vertex `1` and `{4,5,6}` lost vertex `4`; neither edge is fully
present. The size bound (Theorem 3.6) predicts `|I| ≥ 16 − 2 = 14`, met exactly.
For the average-degree form, each of the six vertices `1,…,6` has degree `1` and
the other ten have degree `0`, so the total degree over `S` is `6` and
`averageDegree E S = 6/16 = 3/8`. Lemma 3.8 confirms `|containedEdges E S| = 2 ≤ 6`.
With `δ = 3/8`, Theorem 3.9 certifies `|I| ≥ (1 − 3/8)·16 = 10`, and indeed
`14 ≥ 10`. The construction beats its own worst-case promise here because the two
edges are vertex-disjoint, so no representative is shared and no two contributions
overlap; the bound `(1 − δ)|S|` is the guarantee, not necessarily the exact value.

The degenerate extremes are equally instructive. If `δ = 0` (no vertex of `S` lies
in any edge), the bound returns the entire pool, which is correct: with no
contained edge there is nothing to delete. As `δ → 1`, the bound returns `0`,
reflecting that a pool whose vertices each lie, on average, in a full edge may be
genuinely hard to thin into a large independent set. The estimate therefore tells
the truth at both ends of the density spectrum.

---

## 4. Algorithms and complexity

### 4.1 Representative-Vertex Deletion (constructive independence)

**Input.** A hypergraph `E` (a list of vertex sets) and a pool `S`.
**Output.** An independent set `I ⊆ S` with `|I| ≥ |S| − |containedEdges E S|`.

```
function DETERMINISTIC_DELETION(E, S):
    contained ← { e ∈ E : e ⊆ S }
    reps ← ∅
    for each e ∈ contained:
        if e ≠ ∅:
            reps ← reps ∪ { min(e) }      # canonical representative
    return S \ reps
```

**Correctness.** Independence is Theorem 3.5; the size bound is Theorem 3.6.

**Complexity.** Let `m = |E|`, `n = |S|`, and `k` the maximum edge size. Computing
`contained` costs `O(m·k)` membership checks; choosing minima costs `O(Σ|e|)`; the
final difference costs `O(n + |reps|)`. Overall `O(m·k + n)` time and `O(n)` extra
space — linear in the input. The construction is deterministic and reproducible.

### 4.2 Average-Degree Certification

**Input.** A hypergraph `E`, a pool `S`.
**Output.** The average degree δ over `S` and the certified bound `(1 − δ)·|S|`.

```
function AVERAGE_DEGREE_BOUND(E, S):
    total ← 0
    for each v ∈ S:
        total ← total + |{ e ∈ E : v ∈ e }|     # degree of v
    delta ← total / |S|
    return delta, (1 - delta) * |S|
```

By Lemma 3.8 and Theorem 3.9 the returned value is a valid lower bound on the size
of the independent set produced by `DETERMINISTIC_DELETION`, *provided every edge
is nonempty*. Complexity is `O(n·m·k)` in the naive form, `O(Σ|e| + n)` with an
incidence index.

---

## 5. Applications and discussion

### 5.1 Relationship to the probabilistic deletion method

The classical probabilistic deletion method samples each vertex independently with
probability `p`, forming a random pool `S`. The expected pool size is `p·|V|`, and
the expected number of contained edges is `Σ_{e∈E} p^{|e|}`. Because Theorem 3.6
holds for *every* realized pool `S`, taking expectations and using linearity gives,
with no further combinatorics,
`E[independence] ≥ E[|S|] − E[|containedEdges E S|] = p·|V| − Σ_{e∈E} p^{|e|}`.
Thus the deterministic guarantee implies the probabilistic one pointwise: the
deterministic construction is exactly the witness whose existence the
expectation argument asserts.

### 5.2 Uniform hypergraphs

For an `r`-uniform hypergraph (every edge has exactly `r` vertices), an edge
survives random sampling with probability `p^r`, so the first-moment bound becomes
`p·|V| − |E|·p^r`. Optimizing over `p` recovers the classical
`Ω(|V| / d^{1/(r-1)})` independence bound in terms of the average degree `d` — a
self-contained calculus exercise sitting directly on top of Theorem 3.6.

### 5.3 Locally sparse refinements

When the hypergraph is *linear* (no two edges share more than one vertex — i.e. no
Berge 2-cycles) and additionally forbids Berge 3-cycles (*locally sparse*) or
Berge 4-cycles (*uncrowded*), one can control the *variance* of the contained-edge
count and apply a second-moment / alteration argument to improve the first-moment
bound by a logarithmic factor, of the form
`Ω((|V| / d^{1/(r-1)}) · (log d)^{1/(r-1)})`. Theorem 3.6 remains the deterministic
core; the sparsity hypotheses enter only to bound fluctuations, not to change the
repair mechanism.

### 5.4 Worked optimization for the uniform bound

It is worth carrying the uniform-hypergraph computation of §5.2 to its conclusion,
since it shows precisely how Theorem 3.6 feeds a classical estimate. Let `E` be
`r`-uniform on `N := |V|` vertices with `|E| = M` edges, and sample each vertex
independently with probability `p`. The expected pool size is `pN`; an edge is
contained precisely when all `r` of its vertices are sampled, with probability
`p^r`, so the expected number of contained edges is `M p^r`. Applying Theorem 3.6
pointwise and taking expectations,
`E[independence] ≥ pN − M p^r`. Writing the average degree as `d = rM/N`, so
`M = dN/r`, the right-hand side is `pN − (dN/r) p^r`. Differentiating in `p` and
setting the derivative to zero gives `p = (1/d)^{1/(r-1)}` (up to the constant
`r^{1/(r-1)}`), at which point the bound is of order `N / d^{1/(r-1)}`. This is the
textbook independent-set lower bound for uniform hypergraphs of bounded average
degree, and every step after Theorem 3.6 is elementary single-variable calculus.

### 5.5 Why determinism is valuable

Beyond philosophical cleanliness, the deterministic construction is *auditable*:
the output independent set can be exhibited and independently verified edge by
edge. This matters for applications such as code construction, experimental design,
and certified combinatorial optimization, where an explicit witness — not merely an
existence proof — is required. Determinism also makes the result *composable*: the
same fixed representative function can be applied to a random pool, to a
greedily-chosen pool, or to a structured pool arising from another algorithm, and
the three guarantees of Theorem 3.7 hold verbatim in each case.

### 5.6 Design choices and scope

Three modeling decisions deserve comment. First, the *linear order* on `V` is used
only to make the per-edge representative canonical; any fixed choice function would
yield the same three guarantees, but a linear order gives a concrete, computable,
reproducible rule (`min'`) with no appeal to choice. Second, *empty edges* are
excluded from the notion of independence: a vertex-deletion method can never
destroy the empty edge, so including it would make every set dependent and the
theory vacuous; the nonemptiness hypothesis in Lemma 3.8 and Theorem 3.9 is
therefore essential and not cosmetic. Third, the *contained-edge* abstraction
(`E ∩ E(S)`) cleanly separates the edges that can possibly be violated inside `S`
from those that stick out; this is what allows the same lemma to serve both the
deterministic and probabilistic regimes, since the random pool only ever changes
which edges are contained, not the repair mechanism.

---

## 6. Future directions

1. **Bernoulli first-moment bound.** Formalize random vertex sampling with
   inclusion probability `p`, and bound the expected independent-set size below by
   `E[|S|] − E[|containedEdges E S|]` via pointwise application of Theorem 3.6 and
   linearity of expectation. The deletion lemma already exposes the two
   cardinalities whose expectations are needed.

2. **Uniform hypergraph average-degree bound.** Specialize the first-moment bound
   to `r`-uniform hypergraphs, where edge survival probability collapses to `p^r`,
   and optimize `p` to obtain `Ω(|V| / d^{1/(r-1)})`.

3. **Formal Berge-cycle theory.** Develop `Linear` and `BergeThreeCycle`: prove
   linearity equivalent to the absence of Berge 2-cycles and establish codegree
   counting lemmas controlling pairwise edge intersections.

4. **Second-moment / locally sparse refinement.** Use linearity and forbidden
   Berge 3-cycles to bound the variance of `|containedEdges E S|` and upgrade the
   first-moment bound to the locally-sparse estimate
   `Ω((|V|/d^{1/(r-1)}) · (log d)^{1/(r-1)})`.

---

## 7. Conclusion

Representative-vertex deletion distills the deletion method to its deterministic
essence: choose one canonical vertex per contained hyperedge, delete the
representatives, keep the rest. Three short arguments establish that the result is
inside the pool, independent, and large; a single incidence count turns the size
bound into the clean average-degree guarantee `(1 − δ)·|S|`. The construction is
linear-time, fully explicit, and forms the reusable base layer for the
probabilistic, uniform, and locally-sparse refinements that constitute modern
hypergraph independence-number theory.
