# Clique Complexes, Flag Complexes, and the Vietoris–Rips Filtration: A Self-Contained Characterization

## Abstract

We develop, from first principles, a lightweight theory of abstract simplicial
complexes and the clique-complex construction on simple graphs. Our central
contribution is a precise characterization of which complexes arise as clique
complexes: a complex is the clique complex of its own one-skeleton if and only if
it is *flag* and contains all of its singleton faces. We prove both directions of
this equivalence, identify the singleton hypothesis as load-bearing by exhibiting
an explicit two-vertex counterexample, show that the one-skeleton operation is a
left inverse to the clique-complex operation on graphs (hence the latter is
injective), establish monotonicity of the Vietoris–Rips complex in its scale
parameter (yielding a filtration suitable for persistent homology), and prove a
tight Turán-style upper bound on the f-vector. The entire development pivots on a
single structural fact — *a two-element set is a clique precisely when its two
endpoints are adjacent* — from which the remaining results follow by downward
closure and a flag-rebuilding argument. All results have been formally verified.

**Keywords:** abstract simplicial complex, clique complex, flag complex,
one-skeleton, Vietoris–Rips complex, filtration, f-vector, Turán bound,
topological data analysis.

---

## 1. Introduction

The clique complex is one of the most natural bridges between graph theory and
topology. Given a simple graph `G`, its clique complex `Δ(G)` fills in every clique
as a solid simplex, converting a one-dimensional relational structure into a
higher-dimensional geometric object whose connectivity, loops, and voids encode
combinatorial information about `G`. Clique complexes (also called *flag complexes*
in the literature) are ubiquitous: they underlie the Vietoris–Rips construction in
topological data analysis, the order complexes of posets, and numerous extremal and
homotopical results in combinatorics.

This paper isolates the elementary but complete core of the theory and proves the
following four kinds of results:

1. **A characterization** (Section 4): clique complexes are exactly the flag
   complexes that contain all singletons.
2. **A rigidity / injectivity result** (Section 3): the one-skeleton recovers the
   graph, so `Δ` is injective.
3. **A filtration result** (Section 5): the Vietoris–Rips complex is monotone in
   scale.
4. **An extremal result** (Section 6): a tight binomial upper bound on the
   f-vector.

A guiding methodological theme is the *minimal hypothesis*. The characterization in
Section 4 fails if one drops the singleton condition, and we make this precise with
an explicit counterexample (Theorem 4.4). Beautiful theorems have exact
hypotheses; we exhibit ours.

Throughout, `V` is an arbitrary type of vertices (finite where required), and all
graphs are simple (irreflexive, symmetric).

---

## 2. Definitions

### 2.1 Abstract simplicial complexes

**Definition 2.1 (Abstract simplicial complex).**
An *abstract simplicial complex* (ASC) on a vertex type `V` is a set
`K.faces ⊆ Finset V` of finite subsets of `V`, called *faces*, that is
*downward closed*:
$$ s \subseteq t \ \text{and}\ t \in K.\mathrm{faces} \ \implies\ s \in K.\mathrm{faces}. $$

Downward closure is the sole axiom. Geometrically, it expresses that a filled
simplex contains all of its sub-simplices.

**Definition 2.2 (Extensionality).**
Two complexes `K, L` are equal as soon as their face sets coincide:
`K.faces = L.faces ⟹ K = L`. This makes equality of complexes a purely
set-theoretic statement about their faces.

### 2.2 The clique complex

**Definition 2.3 (Clique complex).**
For a simple graph `G` on `V`, the *clique complex* `Δ(G)` has as its faces the
finite cliques of `G`:
$$ \Delta(G).\mathrm{faces} = \{\, s \in \mathrm{Finset}\,V \mid G.\mathrm{IsClique}(s) \,\}, $$
where `G.IsClique(s)` means the elements of `s` are pairwise adjacent. Downward
closure holds because any subset of a pairwise-adjacent set is pairwise adjacent.

### 2.3 The one-skeleton

**Definition 2.4 (One-skeleton).**
For a complex `K` on `V`, its *one-skeleton* `skel(K)` is the simple graph with
$$ \mathrm{skel}(K).\mathrm{Adj}\,u\,v \ \iff\ u \neq v \ \text{and}\ \{u, v\} \in K.\mathrm{faces}. $$
Symmetry of adjacency follows from `{u, v} = {v, u}`; irreflexivity from the `u ≠ v`
clause. The one-skeleton retains exactly the vertices and edges of `K`, discarding
higher faces.

### 2.4 Flag complexes

**Definition 2.5 (Flag complex).**
A complex `K` is a *flag complex* (`IsFlag K`) if every finite set whose vertices
and pairs are all faces is itself a face:
$$
\Big(\forall u \in s,\ \{u\} \in K.\mathrm{faces}\Big)
\ \wedge\
\Big(\forall u, v \in s,\ u \neq v \Rightarrow \{u, v\} \in K.\mathrm{faces}\Big)
\ \implies\ s \in K.\mathrm{faces}.
$$
Equivalently, `K` has no "hollow" simplices: complete 1-skeletons are always filled.

### 2.5 The Vietoris–Rips complex

**Definition 2.6 (Vietoris–Rips graph and complex).**
Let `d : V → V → ℝ` be a *dissimilarity* (no symmetry assumed). For a scale
`ε ∈ ℝ`, the *Vietoris–Rips graph* `VRG(d, ε)` joins distinct `u, v` exactly when
both directed dissimilarities are within `ε`:
$$ \mathrm{VRG}(d, \varepsilon).\mathrm{Adj}\,u\,v \iff u \neq v \ \wedge\ d(u,v) \le \varepsilon \ \wedge\ d(v,u) \le \varepsilon. $$
The symmetric "both directions" form makes the graph symmetric without assuming `d`
is. The *Vietoris–Rips complex* is its clique complex:
$$ \mathrm{VR}(d, \varepsilon) = \Delta\big(\mathrm{VRG}(d, \varepsilon)\big). $$

### 2.6 The f-vector

**Definition 2.7 (f-vector).**
For a complex `K` on a finite vertex type `V`, the *f-vector* records the number of
`k`-dimensional faces:
$$ f_k(K) = \#\{\, s \in \mathrm{Finset}\,V \mid s \in K.\mathrm{faces} \ \wedge\ |s| = k+1 \,\}. $$
Thus `f₀` counts vertices, `f₁` edges, `f₂` triangles, and so on.

---

## 3. The structural pivot and the one-skeleton inverse

### 3.1 A 2-clique is an edge

**Theorem 3.1 (Pivot lemma).**
For `u ≠ v`,
$$ G.\mathrm{IsClique}(\{u, v\}) \iff G.\mathrm{Adj}\,u\,v. $$

*Proof sketch.* The set `{u, v}` is a clique iff its two distinct elements are
adjacent. Forward: pairwise adjacency on `{u, v}`, applied to the two distinct
members, yields `G.Adj u v`. Backward: `{u, v}` has exactly one unordered pair of
distinct elements; adjacency of that pair (using symmetry of `G`) gives pairwise
adjacency. ∎

Although trivial in content, Theorem 3.1 is the hinge of the entire development: it
identifies edges of `G` with 2-element faces of `Δ(G)`, allowing free translation
between the graph and complex languages.

### 3.2 The one-skeleton recovers the graph

**Theorem 3.2 (One-skeleton inverts the clique complex).**
For every simple graph `G`,
$$ \mathrm{skel}(\Delta(G)) = G. $$

*Proof sketch.* By extensionality of graphs, fix `u, v`. By definition,
`skel(Δ(G)).Adj u v` iff `u ≠ v` and `{u, v} ∈ Δ(G).faces`, i.e. `u ≠ v` and `{u,v}`
is a clique. By the pivot lemma this is `u ≠ v` and `G.Adj u v`. Since adjacency in
a simple graph already entails `u ≠ v`, this is equivalent to `G.Adj u v`. ∎

**Corollary 3.3 (Injectivity of `Δ`).**
The clique-complex construction is injective on simple graphs: if
`Δ(G₁) = Δ(G₂)` then `G₁ = G₂`, since applying `skel` to both sides recovers each
graph.

---

## 4. The flag characterization

### 4.1 Clique complexes are flag

**Theorem 4.1.**
For every simple graph `G`, the complex `Δ(G)` is flag.

*Proof sketch.* Let `s` be a finite set all of whose pairs `{u, v}` (with `u ≠ v`,
both in `s`) are faces of `Δ(G)`. We must show `s` is a clique. Take distinct
`u, v ∈ s`. The pair `{u, v}` is a face, hence a 2-clique, hence (pivot lemma)
`G.Adj u v`. As `u, v` were arbitrary distinct members, `s` is pairwise adjacent,
i.e. `s ∈ Δ(G).faces`. (Singletons play no role in this direction.) ∎

### 4.2 The converse: the headline result

**Theorem 4.2 (Flag + singletons ⟹ clique complex of skeleton).**
Let `K` be a complex that is flag and contains every singleton
(`∀ v, {v} ∈ K.faces`). Then
$$ K = \Delta(\mathrm{skel}(K)). $$

*Proof sketch.* By extensionality it suffices to show, for every finite `s`,
$$ s \in K.\mathrm{faces} \iff s \ \text{is a clique of}\ \mathrm{skel}(K). $$

**(⊆) Downward closure.** Suppose `s ∈ K.faces`. To show `s` is a clique of
`skel(K)`, take distinct `u, v ∈ s`. We need `skel(K).Adj u v`, i.e. `u ≠ v` and
`{u, v} ∈ K.faces`. Now `{u, v} ⊆ s` and `s ∈ K.faces`, so by downward closure
`{u, v} ∈ K.faces`. Hence the pair is an edge of the skeleton and `s` is a clique.

**(⊇) Rebuilding via the flag axiom.** Suppose `s` is a clique of `skel(K)`. To
apply the flag property to `s` we must verify its two premises:
- *singletons*: `{u} ∈ K.faces` for `u ∈ s` — this is exactly the singleton
  hypothesis on `K`;
- *pairs*: `{u, v} ∈ K.faces` for distinct `u, v ∈ s` — since `s` is a clique of
  `skel(K)`, distinct members are adjacent in `skel(K)`, which by definition means
  `{u, v} ∈ K.faces`.
Both premises hold, so the flag property yields `s ∈ K.faces`. ∎

The two inclusions are structurally distinct: ⊆ is automatic from the single ASC
axiom, while ⊇ is precisely where the flag property and the singleton hypothesis are
consumed.

**Corollary 4.3 (Characterization).**
Combining Theorems 4.1 and 4.2: a complex `K` containing all singletons is a clique
complex (of some graph) if and only if it is flag, and the graph is necessarily
`skel(K)`.

### 4.3 The singleton hypothesis is necessary

**Theorem 4.4 (Counterexample).**
There exists a complex `K` on `Bool` that is flag yet `K ≠ Δ(skel(K))`.

*Construction and proof sketch.* Take `V = Bool` and let `K` be the *trivial
complex* with `K.faces = {∅}` (only the empty face). 
- *`K` is downward closed*: the only subset of `∅` is `∅`. 
- *`K` is flag*: a set `s` triggering the flag premise must have all its singletons
  in `K.faces`; but `K` has no singletons, so the premise can only hold for `s = ∅`,
  which is already a face. The flag condition is therefore vacuously satisfied. 
- *`skel(K)` is the empty graph*: no pair `{u, v}` is a face, so there are no edges. 
- *`Δ(skel(K))` contains all singletons*: in any clique complex a one-element set is
  a (trivial) clique, so `{true}, {false} ∈ Δ(skel(K)).faces`. 

But `{true} ∉ K.faces`, so `K ≠ Δ(skel(K))`. ∎

The mechanism is sharp: clique complexes *always* contain every singleton, while a
flag complex need not. The singleton hypothesis in Theorem 4.2 cannot be removed,
and any vertex-faithful refinement of the theory must track the vertex set
explicitly (see Future Work).

---

## 5. The Vietoris–Rips filtration

**Theorem 5.1 (Scale monotonicity).**
For a dissimilarity `d` and scales `ε₁ ≤ ε₂`,
$$ \mathrm{VR}(d, \varepsilon_1).\mathrm{faces} \ \subseteq\ \mathrm{VR}(d, \varepsilon_2).\mathrm{faces}. $$

*Proof sketch.* Let `s` be a face at scale `ε₁`, i.e. a clique of `VRG(d, ε₁)`. Take
distinct `u, v ∈ s`. Then `d(u, v) ≤ ε₁` and `d(v, u) ≤ ε₁`. Since `ε₁ ≤ ε₂`,
transitivity of `≤` gives `d(u, v) ≤ ε₂` and `d(v, u) ≤ ε₂`, so `u, v` are adjacent
in `VRG(d, ε₂)`. Hence `s` is a clique at scale `ε₂`, i.e. a face of
`VR(d, ε₂)`. ∎

**Corollary 5.2 (Filtration).**
The family `(VR(d, ε))_{ε ∈ ℝ}` is a filtration: an order-preserving map from
`(ℝ, ≤)` to complexes ordered by inclusion of face sets. This is the structural
prerequisite for persistent homology, where one tracks the birth and death of
topological features as `ε` increases and retains those that persist over wide
intervals.

---

## 6. An extremal bound on the f-vector

**Theorem 6.1 (Turán-style upper bound).**
For any simple graph `G` on a finite vertex type with `n = |V|` vertices and any
`k ∈ ℕ`,
$$ f_k(\Delta(G)) \ \le\ \binom{n}{k+1}. $$

*Proof sketch.* By definition, `f_k(Δ(G))` counts faces of cardinality `k + 1`.
Every such face is in particular a `(k+1)`-element subset of the `n`-element vertex
set, and the total number of `(k+1)`-element subsets is `C(n, k+1)`. The set of
`(k+1)`-faces injects into the set of all `(k+1)`-subsets, so its cardinality is at
most `C(n, k+1)`. ∎

**Proposition 6.2 (Tightness).**
The bound is attained by the complete graph `K_n`: every subset of vertices is a
clique, so every `(k+1)`-subset is a face and `f_k(Δ(K_n)) = C(n, k+1)` for all `k`.

Theorem 6.1 is the simplest member of the extremal family that includes Turán's
theorem. Restricting the clique number (the size of the largest clique) to be at
most `r` forces `f_k = 0` for `k ≥ r` and leads — via Turán graphs — to sharper
constrained bounds (see Future Work, Direction 3).

---

## 7. Algorithms

The constructions are directly computable. We summarize the principal algorithms;
full type-hinted implementations accompany this paper.

**Algorithm 7.1 (Clique-complex enumeration).**
*Input:* graph `G` on `n` vertices (adjacency relation). *Output:* the list of faces
of `Δ(G)`. *Method:* enumerate subsets `s ⊆ V` in increasing size; include `s` iff
all `C(|s|, 2)` pairs are adjacent. Downward closure permits pruning: a set can be a
face only if all its `(|s|-1)`-subsets are faces, so one may grow faces level by
level (the apriori / Bron–Kerbosch-style strategy). Worst-case output size is `2ⁿ`
(complete graph), matching Theorem 6.1.

**Algorithm 7.2 (One-skeleton extraction).**
*Input:* a complex `K` (list of faces). *Output:* graph `skel(K)`. *Method:* the
edge set is `{ {u, v} ∈ K.faces : u ≠ v }`. Linear in the number of 2-faces.

**Algorithm 7.3 (Flag-complex test).**
*Input:* a complex `K`. *Output:* whether `K` is flag. *Method:* for every candidate
set `s` whose singletons and pairs are all faces, check `s ∈ K.faces`. In practice
one tests *maximal* such candidates obtained as cliques of `skel(K)`; `K` is flag
iff every clique of `skel(K)` (whose vertices are faces) is a face.

**Algorithm 7.4 (Vietoris–Rips filtration).**
*Input:* dissimilarity matrix `d`, increasing scales `ε₁ < ε₂ < …`. *Output:* nested
complexes. *Method:* at each scale build `VRG(d, ε)` (threshold the matrix
symmetrically) and enumerate its clique complex via Algorithm 7.1. By Theorem 5.1
the outputs nest, enabling incremental construction: edges and faces are only ever
added as `ε` grows.

**Algorithm 7.5 (f-vector computation).**
*Input:* a complex `K`. *Output:* `(f₀, f₁, f₂, …)`. *Method:* bucket faces by
cardinality; `f_k` is the count of faces of size `k + 1`. Theorem 6.1 provides the
per-level sanity ceiling `C(n, k+1)`.

---

## 8. Applications

- **Topological data analysis.** The Vietoris–Rips filtration (Definition 2.6,
  Theorem 5.1) is the standard route from a finite metric sample to a multiscale
  topological summary. Persistent loops and voids — features alive across a wide
  `ε`-interval — are used to detect circular coordinates in cyclic processes,
  cavities in molecular conformations, and loops in neural population activity.

- **Network science.** The clique complex of a social or biological network exposes
  higher-order structure (triangles, tetrahedra) invisible to pairwise analysis;
  the f-vector (Definition 2.7) is a compact higher-order census, and Theorem 6.1
  calibrates it against the densest possible network.

- **Combinatorial reconstruction.** Corollary 3.3 (injectivity) guarantees that a
  clique complex *losslessly* encodes its graph: nothing is forgotten by filling in
  cliques, so the graph can always be read back off the skeleton.

- **Recognizing flagness.** Corollary 4.3 gives a clean recognition criterion: among
  complexes containing all vertices, the flag complexes are *exactly* the
  reconstructible (clique) ones — a useful dichotomy when deciding whether a complex
  is determined by its 1-skeleton.

---

## 9. Discussion

The development is deliberately minimal: a single axiom (downward closure), a single
pivot (a 2-clique is an edge), and a handful of consequences. Its value lies less in
depth than in *exactness*. The characterization (Corollary 4.3) is an "if and only
if" with a precisely delimited hypothesis, and Theorem 4.4 demonstrates that the
delimitation is sharp by collapsing onto a two-element witness. This interplay —
prove the theorem, then exhibit the minimal counterexample that fixes its
hypotheses — is the methodological backbone of the work.

A second theme is the *adjunction-like* relationship between `Δ` and `skel`.
Theorem 3.2 shows `skel ∘ Δ = id` on graphs, and Corollary 4.3 identifies the
essential image of `Δ` (within all-vertex complexes) as the flag complexes. The
failure of a clean equivalence on *all* complexes is entirely explained by the
singleton phenomenon, pointing to a vertex-indexed refinement (Future Work,
Direction 4) in which the equivalence becomes hypothesis-free.

---

## 10. Future work

The following directions extend the present foundation.

**Direction 1 — Simplicial boundary and `∂² = 0`.** Define a boundary map
`∂_k : C_k → C_{k-1}` on free abelian groups generated by oriented faces (sorted
vertex lists) via the alternating sum of vertex deletions, and prove `∂∘∂ = 0` by
the standard double-deletion sign cancellation. Downward closure already guarantees
that deletions of faces are faces. This opens simplicial homology of clique
complexes and, with it, persistent homology.

**Direction 2 — Persistent homology of the Vietoris–Rips filtration.** Package
Theorem 5.1 as a morphism in `(ℝ, ≤)` and, after Direction 1, apply `H_k` to obtain
inclusion-induced maps `H_k(VR ε₁) → H_k(VR ε₂)`, yielding a verified persistence
module (functoriality: identities to identities, composites to composites).

**Direction 3 — Turán extremality of the f-vector.** Prove the vanishing `f_k = 0`
for `k ≥ r` when the clique number is at most `r` (an `(r+1)`-face would be an
`(r+1)`-clique), and connect `f_k` to Turán graphs for the extremal half, sharpening
Theorem 6.1 under a clique-number constraint.

**Direction 4 — A vertex-faithful flag characterization.** Equip `ASC` with an
explicit vertex set `V₀` and require `{v} ∈ K ⟺ v ∈ V₀`. Conjecturally the singleton
obstruction of Theorem 4.4 is the *only* obstruction, so that relative to `V₀` the
equivalence "`K` is flag `⟺` `K = Δ(skel(K))`" holds with no side hypothesis.

**Direction 5 — The clique complex as a nerve.** Realize `Δ(G)` as the nerve of a
cover (closed neighborhoods or maximal cliques): `s` is a face iff the corresponding
sets have nonempty common intersection. Reusing the `ASC`/downward-closure language,
prove a finite combinatorial Nerve Lemma under a good-cover hypothesis, connecting
these combinatorial complexes to genuine topology.

---

## 11. Conclusion

From the single observation that an edge is a 2-clique, we obtained a complete,
exact account of clique complexes: they are injectively encoded by their graphs
(Theorem 3.2, Corollary 3.3), they are precisely the all-vertex flag complexes
(Corollary 4.3) — with the singleton hypothesis shown necessary by an explicit
witness (Theorem 4.4) — they organize into the Vietoris–Rips filtration foundational
to topological data analysis (Theorem 5.1), and their f-vectors obey a tight
binomial ceiling (Theorem 6.1). The theory is small, but every hypothesis is
earning its place.
