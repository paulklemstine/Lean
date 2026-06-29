# Clique Complexes, the One-Skeleton Adjunction, and Vietoris–Rips Filtrations

## Abstract

We develop, from first principles, a lightweight but complete theory of the
clique-complex construction relating simple graphs to abstract simplicial
complexes. Two functors — the clique complex `Δ`, which sends a graph to the
complex of its cliques, and the one-skeleton `sk`, which sends a complex to the
graph of its edges — are shown to form a **Galois connection** between the poset
of simple graphs (ordered by edge inclusion) and the poset of abstract
simplicial complexes (ordered by face inclusion). We prove that both functors
are monotone; that there is an unconditional unit `K ⊆ Δ(sk K)` requiring only
downward closure; that the composite `Δ ∘ sk` is a closure operator,
idempotent on the image of `Δ`; and that the adjunction `Δ G ⊆ K ⇔ G ≤ sk K`
holds in full on flag complexes containing all singletons. We characterize the
two extremes of the **Vietoris–Rips filtration** — a full simplex above the
diameter and a discrete complex below the minimum separation — and establish a
**complement duality** identifying the independence complex of a graph with the
clique complex of its complement, from which flagness is inherited for free.
A Turán-style upper bound `f_k(Δ(G)) ≤ C(n, k+1)` on the f-vector rounds out the
combinatorial picture. All results are stated and proved in full rigor and are
free of unverified assumptions.

**Keywords.** clique complex, flag complex, one-skeleton, Galois connection,
closure operator, Vietoris–Rips filtration, independence complex, topological
data analysis, simplicial complex, f-vector.

---

## 1. Introduction

A *simple graph* records pairwise relationships among a set of vertices. An
*abstract simplicial complex* records higher relationships: it specifies which
finite sets of vertices are "filled in" as cells, subject only to the rule that
faces are closed under taking subsets. The clique-complex construction is the
canonical bridge between the two: it fills in every clique of a graph as a face,
producing a simplicial complex whose topology encodes structural features of the
graph that pairwise data alone cannot express.

This construction is the foundation of the Vietoris–Rips complex, the workhorse
of topological data analysis (TDA). Given a finite collection of data points and
a dissimilarity measure, one connects points closer than a threshold `ε` and
fills in the cliques; varying `ε` produces a *filtration* whose persistent
homological features summarize the multi-scale shape of the data.

In this paper we give a self-contained development of the order-theoretic and
combinatorial backbone of this construction. Our central organizing principle is
that the clique complex `Δ` and the one-skeleton `sk` form a Galois connection,
and that the classical theorems characterizing clique and flag complexes are
precisely the unit, counit, closure, and adjunction laws of that connection. We
then analyze the Vietoris–Rips filtration at its extremes and record the
self-duality of the construction under graph complementation.

### 1.1 Contributions

1. **Monotonicity** of both functors `Δ` and `sk` (Theorem 4.1, 4.2).
2. The **unit** `K ⊆ Δ(sk K)`, requiring only downward closure (Theorem 5.1).
3. The **closure law** `Δ(sk(Δ G)) = Δ G` (Theorem 6.1).
4. The **Galois adjunction** `Δ G ⊆ K ⇔ G ≤ sk K` for flag complexes with all
   singletons (Theorem 7.1), with a counterexample showing the singleton
   hypothesis is necessary (Theorem 7.2).
5. The **two extremes of the Vietoris–Rips filtration**: full simplex above the
   diameter, discrete below the minimum separation (Theorems 8.2, 8.3).
6. The **complement duality** `independenceComplex G = Δ(Gᶜ)` and inherited
   flagness (Theorems 9.1, 9.2).
7. A **Turán-style bound** `f_k(Δ G) ≤ C(n, k+1)` on the f-vector (Theorem 10.1).

---

## 2. Preliminaries and Definitions

Throughout, `V` is a vertex type and `G, H` are simple graphs on `V` (irreflexive,
symmetric adjacency relations, written `u ~ v`). We write `u ≁ v` for
non-adjacency and `Gᶜ` for the complement graph, in which `u ~ v` in `Gᶜ` iff
`u ≠ v` and `u ≁ v` in `G`.

> **Definition 2.1 (Abstract simplicial complex).** An *abstract simplicial
> complex* (ASC) on `V` is a pair `K = (faces, down_closed)` where `faces` is a
> set of finite subsets of `V` and `down_closed` is the property that `s ⊆ t`
> and `t ∈ faces` imply `s ∈ faces`. Two complexes are equal iff their face sets
> coincide.

We order complexes by inclusion of face sets: `K ⊆ L` means every face of `K` is
a face of `L`. We order graphs by `G ≤ H`, meaning every edge of `G` is an edge
of `H`. Both `(ASC V, ⊆)` and `(SimpleGraph V, ≤)` are posets (indeed complete
lattices).

> **Definition 2.2 (Clique).** A set `S ⊆ V` is a *clique* of `G` if its
> elements are pairwise adjacent: for all `u, v ∈ S` with `u ≠ v`, `u ~ v`.

> **Definition 2.3 (Clique complex).** The *clique complex* `Δ(G)` is the ASC
> whose faces are exactly the finite cliques of `G`:
> `Δ(G).faces = { s : finite subset of V | s is a clique of G }`.
> Downward closure holds because any subset of a clique is a clique.

> **Definition 2.4 (One-skeleton).** The *one-skeleton* `sk(K)` of a complex `K`
> is the simple graph with adjacency
> `u ~ v in sk(K)  ⇔  u ≠ v and {u, v} ∈ K.faces`.
> Symmetry and irreflexivity are immediate.

> **Definition 2.5 (Flag complex).** A complex `K` is a *flag complex* if every
> finite set `s` all of whose singletons `{u}` (for `u ∈ s`) and all of whose
> pairs `{u, v}` (for distinct `u, v ∈ s`) are faces, is itself a face.

> **Definition 2.6 (Vietoris–Rips graph and complex).** Given a dissimilarity
> `d : V × V → ℝ` (not assumed symmetric) and a scale `ε ∈ ℝ`, the
> *Vietoris–Rips graph* has adjacency
> `u ~ v  ⇔  u ≠ v and d(u,v) ≤ ε and d(v,u) ≤ ε`.
> The *Vietoris–Rips complex* is `VR(d, ε) := Δ(VRgraph(d, ε))`.

> **Definition 2.7 (Independence complex).** The *independence complex* of `G`
> has as faces the finite *independent* sets of `G` (sets with no two adjacent
> vertices). Equivalently (Theorem 9.1) it is `Δ(Gᶜ)`.

> **Definition 2.8 (f-vector).** For finite `V` with `|V| = n`, the *f-vector*
> of a complex `K` is `f_k(K) = #{ faces of K of cardinality k+1 }`, counting the
> `k`-dimensional faces.

---

## 3. The Structural Pivot

The entire theory rests on a single elementary identification.

> **Theorem 3.1 (2-cliques are edges).** For distinct `u, v ∈ V`,
> the pair `{u, v}` is a clique of `G` iff `u ~ v`.

*Proof sketch.* A clique on `{u, v}` is precisely the pairwise-adjacency
condition on a two-element set, which (since the only distinct pair is `(u,v)`)
reduces to `u ~ v`. Conversely, if `u ~ v`, symmetry of adjacency makes `{u, v}`
pairwise adjacent. ∎

From Theorem 3.1 one derives both the reconstruction `sk(Δ G) = G` and the flag
property below.

> **Theorem 3.2 (Reconstruction).** For every graph `G`, `sk(Δ(G)) = G`.

*Proof sketch.* Edges of `sk(Δ G)` are pairs `{u,v}` with `u ≠ v` that are faces
of `Δ G`, i.e. 2-cliques, i.e. edges of `G` by Theorem 3.1; conversely each edge
`u ~ v` forces `u ≠ v` and `{u,v} ∈ Δ G`. ∎

In categorical language, Theorem 3.2 says `sk ∘ Δ = id`, the *counit is an
isomorphism*: `Δ` is a full embedding of graphs into complexes.

---

## 4. Monotonicity

> **Theorem 4.1 (`Δ` is monotone).** If `G ≤ H` then `Δ(G).faces ⊆ Δ(H).faces`.

*Proof sketch.* A clique of `G` is pairwise adjacent in `G`, hence (since
`G ≤ H`) pairwise adjacent in `H`, hence a clique of `H`. ∎

> **Theorem 4.2 (`sk` is monotone).** If `K.faces ⊆ L.faces` then
> `sk(K) ≤ sk(L)`.

*Proof sketch.* An edge of `sk K` is a pair `{u,v}` with `u ≠ v` and
`{u,v} ∈ K.faces ⊆ L.faces`, hence an edge of `sk L`. ∎

Monotonicity of both functors is the first requirement of a Galois connection.

---

## 5. The Unit

> **Theorem 5.1 (Unit).** For every complex `K`, `K.faces ⊆ Δ(sk(K)).faces`.

*Proof sketch.* Let `s ∈ K.faces`. To show `s` is a clique of `sk K`, take
distinct `u, v ∈ s`. We need `{u,v}` to be an edge of `sk K`, i.e.
`{u,v} ∈ K.faces`. But `{u,v} ⊆ s`, so by downward closure `{u,v} ∈ K.faces`.
Hence `s` is a clique. ∎

The proof uses *only* downward closure — no flag axiom, no singletons. This is
the surprising content: the unit of the adjunction is unconditional, because
shrinking a face to one of its pairs is always legal.

---

## 6. The Closure Operator

> **Theorem 6.1 (Idempotence / closure law).**
> `Δ(sk(Δ(G))) = Δ(G)` for every graph `G`.

*Proof.* Immediate from Theorem 3.2: `sk(Δ G) = G`, so
`Δ(sk(Δ G)) = Δ(G)`. ∎

Combined with the unit (Theorem 5.1) and monotonicity (Theorem 4.1), this shows
`c := Δ ∘ sk` is a **closure operator** on the poset of complexes: it is
inflationary (`K ⊆ c K`), monotone, and idempotent on the image of `Δ`. Its
fixed points among complexes containing all singletons are precisely the flag
complexes (Section 11, Future Direction 1).

---

## 7. The Galois Adjunction

We now assemble the adjunction. Recall a *Galois connection* between posets `P`
and `Q` is a pair of monotone maps `F : P → Q`, `U : Q → P` with
`F p ≤ q ⇔ p ≤ U q`. Here `P` is graphs, `Q` is complexes, `F = Δ`, `U = sk`.

> **Theorem 7.1 (Galois adjunction).** Let `K` be a flag complex containing all
> singletons (`{v} ∈ K.faces` for every `v`). Then for every graph `G`,
> `Δ(G).faces ⊆ K.faces  ⇔  G ≤ sk(K)`.

*Proof sketch.*
- (⇒) Suppose `Δ G ⊆ K`. Given an edge `u ~ v` of `G`, the pair `{u,v}` is a
  2-clique (Theorem 3.1), hence a face of `Δ G ⊆ K`, hence an edge of `sk K`.
  Thus `G ≤ sk K`.
- (⇐) Suppose `G ≤ sk K`. Let `s ∈ Δ G`, i.e. a clique of `G`. Every pair
  `{u,v} ⊆ s` is an edge of `G`, hence of `sk K` (by `G ≤ sk K`), hence a face
  of `K`. All singletons of `s` are faces by hypothesis. The flag axiom then
  rebuilds `s` itself as a face of `K`. Thus `Δ G ⊆ K`. ∎

The forward direction needs only Theorem 3.1; the reverse direction is exactly
where the flag axiom and the singleton hypothesis are consumed. This makes
transparent the slogan: **downward closure powers the unit, flagness powers the
adjunction.**

The singleton hypothesis cannot be removed:

> **Theorem 7.2 (Necessity of singletons).** Let `V = Bool` and let `K` be the
> trivial complex whose only face is `∅`. Then `K` is a flag complex, but
> `K ≠ Δ(sk(K))`.

*Proof sketch.* `K` is vacuously flag: the only set all of whose singletons are
faces is `∅` itself (since no singleton is a face of `K`), and `∅ ∈ K`. Its
one-skeleton is the empty graph, whose clique complex contains every singleton,
e.g. `{true}`. But `{true} ∉ K`. Hence `K ≠ Δ(sk K)`. ∎

Because clique complexes always contain every singleton (a single vertex is a
clique), the connection is a *Galois insertion* onto the flag complexes that
contain all singletons — not a bijection with all flag complexes.

The reconstruction theorem for flag complexes is the equality case of the
adjunction:

> **Theorem 7.3 (Flag reconstruction).** A flag complex `K` containing all
> singletons equals `Δ(sk(K))`.

*Proof sketch.* `⊆` is the unit (Theorem 5.1). For `⊇`, a clique `s` of `sk K`
has all pairs as faces of `K` and (by hypothesis) all singletons as faces, so
the flag axiom gives `s ∈ K`. ∎

---

## 8. The Vietoris–Rips Filtration

The Vietoris–Rips complex `VR(d, ε) = Δ(VRgraph(d, ε))` is built from a
dissimilarity `d` at scale `ε`. We first note it is a filtration.

> **Theorem 8.1 (Monotonicity in scale).** If `ε₁ ≤ ε₂` then
> `VR(d, ε₁).faces ⊆ VR(d, ε₂).faces`.

*Proof sketch.* A face at scale `ε₁` is a clique of `VRgraph(d, ε₁)`. For each
edge, the inequalities `d(u,v) ≤ ε₁` and `d(v,u) ≤ ε₁` give `≤ ε₂` by
transitivity with `ε₁ ≤ ε₂`. Hence the set is a clique at scale `ε₂`. ∎

We now pin down the two extremes.

> **Theorem 8.2 (Full simplex above the diameter).** If `d(u,v) ≤ ε` for all
> `u, v`, then every finite set `s ⊆ V` is a face of `VR(d, ε)`.

*Proof sketch.* For distinct `u, v ∈ s`, both `d(u,v) ≤ ε` and `d(v,u) ≤ ε`
hold by hypothesis, and `u ≠ v`, so `u ~ v` in `VRgraph(d, ε)`. Thus `s` is a
clique, i.e. a face. ∎

> **Theorem 8.3 (Discrete below the minimum separation).** If
> `ε < d(u,v)` for all distinct `u, v`, then the faces of `VR(d, ε)` are exactly
> the sets of cardinality `≤ 1` (the empty set and the singletons).

*Proof sketch.* Any singleton or `∅` is a face trivially (no distinct pair to
check). Conversely, a face of cardinality `≥ 2` contains distinct `u, v` that
must be adjacent, requiring `d(u,v) ≤ ε`, contradicting `ε < d(u,v)`. Hence no
face has two or more elements. ∎

The strictness in Theorem 8.3 is essential: with only `ε ≤ d(u,v)` a boundary
pair at the critical scale could still be an edge.

Together with Theorem 8.1, these results fully determine the qualitative shape
of the filtration: it interpolates monotonically between the discrete complex
(below `sep := min_{u≠v} d(u,v)`) and the full simplex (above
`diam := max_{u,v} d(u,v)`). Because face membership is a finite conjunction of
inequalities `d(u,v) ≤ ε`, the complex changes value only when `ε` crosses one
of the finitely many values `d(u,v)`; the filtration is piecewise constant with
critical scales contained in `{ d(u,v) }` (Section 11, Future Direction 2).

---

## 9. Complement Duality

> **Theorem 9.1 (Independence = clique of complement).** A finite set `s` is a
> face of the independence complex of `G` iff `s` is a clique of `Gᶜ`; that is,
> `independenceComplex(G) = Δ(Gᶜ)`.

*Proof sketch.* `s` is independent in `G` iff no two distinct elements are
adjacent in `G`, iff every two distinct elements are adjacent in `Gᶜ` (by the
definition of complement), iff `s` is a clique of `Gᶜ`. ∎

> **Theorem 9.2 (Flagness of independence complexes).** For every graph `G`, the
> independence complex of `G` is a flag complex.

*Proof.* By Theorem 9.1 it equals `Δ(Gᶜ)`, and every clique complex is a flag
complex (the flag property of `Δ`, proved as in Theorem 7.3's `⊇` direction with
`G = Gᶜ`). ∎

Since complementation is an involution (`Gᶜᶜ = G`), Theorem 9.1 mechanically
dualizes every clique-complex theorem into an independence-complex theorem by the
substitution `G ↦ Gᶜ`, yielding a complete dual library at no extra proof cost.

---

## 10. A Turán-Style Bound on the f-vector

> **Theorem 10.1 (Binomial upper bound).** For finite `V` with `|V| = n` and any
> graph `G`, `f_k(Δ(G)) ≤ C(n, k+1)` for all `k`, with equality for every `k`
> when `G` is complete.

*Proof sketch.* The `k`-faces of `Δ G` are a subset of all `(k+1)`-element
subsets of `V`, of which there are exactly `C(n, k+1)`. The bound follows by
monotonicity of cardinality under subset; equality for the complete graph holds
because every subset is then a clique. ∎

The equality case is conjecturally a *characterization* of completeness:
`f_k(Δ G) = C(n, k+1)` for some `k ≥ 1` iff `G` is complete (Section 11, Future
Direction 4).

---

## 11. Discussion and Future Work

The development above is deliberately minimal: a handful of definitions and a
single structural pivot (Theorem 3.1) generate the entire theory. Recasting the
classical clique/flag correspondence as a Galois connection clarifies *why* the
side conditions appear precisely where they do — downward closure for the unit,
flagness plus singletons for the adjunction — and organizes the results into the
canonical unit/closure/adjunction pattern.

Several natural extensions present themselves:

1. **Fixed-point characterization.** Restricted to complexes containing all
   singletons, the fixed points of the closure operator `c = Δ ∘ sk` should be
   exactly the flag complexes: `c K = K ⇔ K` is flag. The reconstruction theorem
   gives one direction; the unit gives one containment of the other. This would
   upgrade the adjunction to a genuine Galois *insertion* onto flag complexes.

2. **Critical scales of the filtration.** For finite `V`, the Vietoris–Rips
   filtration should change value only at finitely many critical scales, all in
   the finite set `{ d(u,v) }`, and be constant on each open interval between
   consecutive critical values. This quantitative refinement is fully
   computable.

3. **Complementation as an order-reversing involution.** Making complementation
   first-class would give `independenceComplex(Gᶜ) = Δ(G)`,
   `sk(independenceComplex G) = Gᶜ`, and an order-*reversing* analogue of the
   adjunction `G ≤ H ⇔ independenceComplex(H) ⊆ independenceComplex(G)`,
   converting the single duality bridge into a free functorial dictionary.

4. **Sharp Turán equality criterion.** Conjecture: `f_k(Δ G) = C(n, k+1)` for
   some `k ≥ 1` iff `G` is complete. A size-`(k+1)` clique forces all its
   `C(k+1, 2)` edges, so saturating the bound at any positive dimension forces
   every edge.

5. **Joins.** For graphs `G` on `V` and `H` on `W`, the graph join `G ⋆ H`
   (disjoint union plus all cross edges) should satisfy
   `Δ(G ⋆ H) = Δ(G) ⋆ Δ(H)` as simplicial joins, since a set is a clique in the
   join iff its two projections are cliques and every cross-pair is an edge. A
   join theorem is the gateway to inductive computation of homotopy type and
   connectivity of clique complexes.

---

## 12. Conclusion

We have given a complete, self-contained account of the clique-complex
construction as a Galois connection between graphs and complexes, characterized
the extremes of the Vietoris–Rips filtration, and established the complement
duality with independence complexes. The theory's economy — one pivot lemma
unfolding into monotonicity, unit, closure, adjunction, filtration extremes, and
duality — reflects the underlying order-theoretic structure, and provides a
rigorous foundation for the simplicial constructions at the heart of topological
data analysis.

---

## Appendix A. Notation

| Symbol | Meaning |
| --- | --- |
| `G ≤ H` | `H` has every edge of `G` |
| `u ~ v` | `u` adjacent to `v` |
| `Gᶜ` | complement graph |
| `Δ(G)` | clique complex of `G` |
| `sk(K)` | one-skeleton graph of `K` |
| `K ⊆ L` | every face of `K` is a face of `L` |
| `VR(d, ε)` | Vietoris–Rips complex at scale `ε` |
| `f_k(K)` | number of `k`-dimensional faces |
| `C(n, m)` | binomial coefficient |
