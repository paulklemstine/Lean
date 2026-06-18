# Flag Complexes and the Clique Recognition Theorem

*A formal treatment of the equivalence between flag complexes and clique
complexes of simple graphs*

---

## Abstract

The clique complex (equivalently, the Vietoris–Rips complex) of a simple graph
is the abstract simplicial complex whose faces are the finite cliques of the
graph. A simplicial complex is called *flag* (or a *clique complex* in the
abstract) when every finite vertex set whose pairs are all edges of the complex's
1-skeleton is itself a face — that is, when the complex withholds no simplex that
its 1-skeleton permits. We give a self-contained development of the basic theory
of flag complexes and prove the central structural results: (A) the clique
complex of any simple graph is flag; (B) the 1-skeleton of a clique complex
recovers exactly the edges of the original graph; and the converse direction (D)
that any flag complex equals the clique complex of its own 1-skeleton.
Combining these yields the **Recognition Theorem** (E): an abstract simplicial
complex is flag if and only if it equals the clique complex of its own
1-skeleton. The development is fully formalized and machine-checked; here we
present the mathematics, the definitions, complete proof sketches, the
underlying algorithms for working with clique complexes computationally, and a
discussion of applications to topological data analysis, distributed sensing,
and geometric group theory.

**Keywords:** flag complex, clique complex, Vietoris–Rips complex, abstract
simplicial complex, 1-skeleton, simple graph, simplicial topology.

**MSC 2020:** 05E45 (Combinatorial aspects of simplicial complexes), 05C69
(cliques), 55U10 (simplicial sets and complexes), 57Q05 (PL-topology).

---

## 1. Introduction

There is a fundamental and recurring move in modern mathematics: replace a
*discrete* object — a graph — with a *geometric* one — a simplicial complex —
so that the tools of topology become available. The cleanest such bridge is the
**clique complex** (also called the **flag complex** or, in the metric setting,
the **Vietoris–Rips complex**): fill in a simplex on a set of vertices exactly
when those vertices are pairwise adjacent. This single construction underlies
topological data analysis, the geometry of CAT(0) cube complexes, the study of
right-angled Artin and Coxeter groups, and the homotopy theory of independence
and matching complexes.

A complex built this way has a striking property: it is determined entirely by
its 1-skeleton. No information lives above the edges; every higher face is forced
by the edges below it. Complexes with this property are exactly the *flag*
complexes. The purpose of this paper is to make that statement precise and to
prove the full equivalence in both directions, working entirely from first
principles over an arbitrary (possibly infinite) vertex type.

The contribution is twofold. Mathematically, we isolate the minimal hypotheses
under which the flag/clique equivalence holds and present clean proofs.
Foundationally, every definition and theorem below has been formalized and
verified in a proof assistant, so the results are stated with the exactness that
formalization demands — in particular, careful attention to finiteness,
distinctness of vertices, and the precise membership conditions for faces.

---

## 2. Definitions

Throughout, `α` is an arbitrary type of *vertices*, with decidable equality
where required for the constructions. We work with `Finset α`, the type of finite
subsets of `α`, and `Set (Finset α)`, sets of such finite subsets.

### 2.1 Abstract simplicial complexes

**Definition 2.1 (Abstract simplicial complex).** An *abstract simplicial
complex* (ASC) on `α` is a set `faces ⊆ Finset α` of finite vertex sets,
called *faces*, satisfying:

1. **Downward closure.** For every `s ∈ faces` and every `t ⊆ s`, we have
   `t ∈ faces`.
2. **Singleton presence.** For every vertex `a`, if `a` belongs to some face
   `s ∈ faces`, then the singleton `{a} ∈ faces`.

The first axiom is the structural heart of the definition: a face cannot exist
without all of its sub-faces. The second is a normalization convention ensuring
the vertex set of the complex is itself recorded as 0-dimensional faces; it
follows in fact from downward closure (since `{a} ⊆ s`) but is stated explicitly
for convenience. The *dimension* of a face `s` is `|s| − 1`.

Note that the empty set is a face of any nonempty complex (it is a subset of any
face), and a complex may be empty.

### 2.2 The 1-skeleton

**Definition 2.2 (1-skeleton).** The *1-skeleton* of an ASC `K`, written
`oneSkel K`, is the simple graph on vertex type `α` in which distinct vertices
`a` and `b` are adjacent precisely when the pair `{a, b}` is a face of `K`:

> `(oneSkel K).Adj a b ⟺ a ≠ b ∧ {a, b} ∈ K.faces`.

This is a genuine simple graph: the adjacency relation is

- **symmetric**, because `{a, b} = {b, a}` as finite sets, and
- **irreflexive**, because the defining condition requires `a ≠ b`.

Formally, `oneSkel K` is obtained as the symmetric–irreflexive closure
(`fromRel`) of the relation `a ↦ b ↦ {a, b} ∈ K.faces`. The characterization
above (denoted `oneSkel_adj`) is the working interface to the definition.

### 2.3 The clique complex of a graph

**Definition 2.3 (Clique complex).** Let `G` be a simple graph on `α`. Its
*clique complex* `cliqueComplex G` is the ASC whose faces are the finite cliques
of `G`:

> `s ∈ (cliqueComplex G).faces ⟺ (s is finite) ∧ (∀ a, b ∈ s, a ≠ b → G.Adj a b)`.

Here a *clique* is a vertex set all of whose distinct pairs are adjacent. (The
finiteness clause is automatic for `s : Finset α`, but is recorded as part of
the membership predicate so that the definition reads correctly when faces are
viewed inside `Set (Finset α)`.)

**Proposition 2.4.** `cliqueComplex G` is a well-defined abstract simplicial
complex.

*Proof.* Downward closure: if `s` is a clique and `t ⊆ s`, then any distinct
pair in `t` is a distinct pair in `s`, hence adjacent; so `t` is a clique.
Singleton presence: a singleton `{a}` is vacuously a clique (it contains no
distinct pair), so it is always a face. ∎

### 2.4 The flag property

**Definition 2.5 (Flag complex).** An ASC `K` is *flag*, written `IsFlag K`,
when every finite vertex set whose distinct pairs are all edges of the
1-skeleton is itself a face:

> `IsFlag K ⟺ ∀ s : Finset α, (∀ a, b ∈ s, a ≠ b → (oneSkel K).Adj a b) → s ∈ K.faces`.

Intuitively, a flag complex never contains a "hollow" simplex: if the entire
edge-boundary of a potential simplex is present in the 1-skeleton, the simplex
itself must be filled in. Flagness is precisely the assertion that *the complex
contains every clique of its own 1-skeleton*.

---

## 3. Main Results

We now state and prove the structural theorems. The labels (A)–(E) match the
formalized statements.

### 3.1 Clique complexes are flag

**Theorem A (`cliqueComplex_isFlag`).** For every simple graph `G`, the complex
`cliqueComplex G` is flag.

*Proof sketch.* Let `s` be a finite vertex set all of whose distinct pairs are
edges of `oneSkel (cliqueComplex G)`. We must show `s` is a face, i.e. a clique
of `G`. Fix distinct `a, b ∈ s`. By hypothesis `(oneSkel (cliqueComplex G)).Adj a b`,
which by `oneSkel_adj` means `a ≠ b` and `{a, b} ∈ (cliqueComplex G).faces`.
But membership of `{a, b}` in the clique complex means exactly that its two
distinct elements `a, b` are adjacent in `G`. Hence `G.Adj a b`. Since `a, b`
were arbitrary distinct elements of `s`, the set `s` is a clique of `G`, so
`s ∈ (cliqueComplex G).faces`. ∎

The proof is short precisely because the flag property and the clique-complex
membership condition are, at the level of pairs, the *same* condition relayed
through the 1-skeleton. This is the structural reason flagness is automatic for
clique complexes.

### 3.2 The 1-skeleton recovers the edges

**Theorem B (`clique_pair_iff`).** For distinct vertices `a ≠ b` and any graph
`G`,

> `{a, b} ∈ (cliqueComplex G).faces ⟺ G.Adj a b`.

*Proof sketch.* (⇒) If `{a, b}` is a face, its distinct elements `a, b` are
adjacent by the clique condition. (⇐) If `G.Adj a b`, then the only distinct
pairs in `{a, b}` are `(a, b)` and `(b, a)`, both adjacent (using symmetry of
`G`), so `{a, b}` is a clique, hence a face. ∎

**Corollary 3.1.** The 1-skeleton of `cliqueComplex G` is `G` itself (as an
adjacency relation): `(oneSkel (cliqueComplex G)).Adj a b ⟺ G.Adj a b`. Indeed,
by `oneSkel_adj` the left side is `a ≠ b ∧ {a,b} ∈ (cliqueComplex G).faces`,
which by Theorem B equals `a ≠ b ∧ G.Adj a b`, and this is just `G.Adj a b`
since adjacency already forces `a ≠ b`.

Theorem B is the fidelity guarantee: the clique-complex construction neither
invents nor destroys edges, so the round trip *graph → complex → 1-skeleton*
returns the original graph.

### 3.3 A note on singletons

**Theorem C (`IsFlag.singleton_mem`).** For any flag complex `K` and any vertex
`a` with `{a} ∈ K.faces`, the flag property imposes no further constraint on
`{a}`.

*Remark.* This statement is recorded as a formal triviality (its conclusion is
`True`). Its content is conceptual: singletons are always faces — both in any
ASC by the singleton-presence axiom and in any clique complex vacuously — so the
flag condition, which constrains higher faces via their pairs, says nothing new
at dimension 0. We include it to make explicit that flagness is a condition on
edges and above, never on vertices.

### 3.4 Flag complexes are clique complexes of their skeletons

**Theorem D (`IsFlag.eq_cliqueComplex`).** If `K` is a flag complex, then

> `K.faces = (cliqueComplex (oneSkel K)).faces`.

*Proof sketch.* We prove the two inclusions of the set equality, fixing an
arbitrary finite vertex set `s`.

*(⊆) Every face is a clique of the skeleton.* Suppose `s ∈ K.faces`. We must
show `s` is a clique of `oneSkel K`. Fix distinct `a, b ∈ s`. The pair
`{a, b}` is a subset of `s`, so by downward closure `{a, b} ∈ K.faces`. With
`a ≠ b`, the characterization `oneSkel_adj` gives `(oneSkel K).Adj a b`. Hence
all distinct pairs of `s` are skeleton-edges, i.e. `s` is a clique of
`oneSkel K`, i.e. `s ∈ (cliqueComplex (oneSkel K)).faces`.

*(⊇) Every clique of the skeleton is a face.* Suppose `s` is a clique of
`oneSkel K`, i.e. all its distinct pairs are skeleton-edges. This is verbatim
the antecedent of the flag property for `s`. Since `K` is flag, we conclude
`s ∈ K.faces`. ∎

The forward inclusion uses *downward closure* (faces contain their edge-pairs);
the backward inclusion uses *flagness* (cliques are filled). The two complex
axioms and the flag property together close the loop exactly.

### 3.5 The Recognition Theorem

**Theorem E (`isFlag_iff_eq_cliqueComplex`).** An abstract simplicial complex
`K` is flag if and only if it equals the clique complex of its own 1-skeleton:

> `IsFlag K ⟺ K.faces = (cliqueComplex (oneSkel K)).faces`.

*Proof sketch.* (⇒) This is exactly Theorem D. (⇐) Suppose
`K.faces = (cliqueComplex (oneSkel K)).faces`. To show `K` is flag, take a
finite `s` all of whose distinct pairs are edges of `oneSkel K`; we must show
`s ∈ K.faces`. Rewriting through the hypothesis, it suffices to show
`s ∈ (cliqueComplex (oneSkel K)).faces`, which by Theorem A
(`cliqueComplex_isFlag` applied to the graph `oneSkel K`) holds provided all
distinct pairs of `s` are edges of `oneSkel (cliqueComplex (oneSkel K))`. A
short lemma (`oneSkel_congr`: complexes with equal face sets have equal
1-skeletons) shows that, under our hypothesis, this latter 1-skeleton coincides
with `oneSkel K`, so the pair condition transfers directly from the assumption
on `s`. Hence `s ∈ K.faces` and `K` is flag. ∎

**Auxiliary Lemma (`oneSkel_congr`).** If `K₁.faces = K₂.faces` then
`oneSkel K₁ = oneSkel K₂`. *Proof.* The adjacency relation of the 1-skeleton
depends on the face set only through the predicate `{a,b} ∈ faces`; equal face
sets give equal predicates, hence equal graphs. ∎

Theorem E is the conceptual summit: *flagness is precisely self-recovery from the
1-skeleton.* The property "I am rebuilt by filling the cliques of my own edges"
is not merely sufficient for being a clique complex — it is the exact
characterization.

---

## 4. The Round-Trip Picture

The five theorems organize into two adjoint-flavored maps between graphs and
complexes:

- **Skeleton:** `K ↦ oneSkel K`, sending a complex to its underlying graph.
- **Fill:** `G ↦ cliqueComplex G`, sending a graph to its clique complex.

The results pin down both composites:

1. **Fill then Skeleton is the identity on graphs.** For any `G`,
   `oneSkel (cliqueComplex G) = G` (Corollary 3.1, from Theorem B). Filling
   cliques and then reading off edges returns the original graph exactly.

2. **Skeleton then Fill is the identity on flag complexes, and only on them.**
   For any complex `K`, `cliqueComplex (oneSkel K) = K` *iff* `K` is flag
   (Theorem E). On non-flag complexes the composite strictly enlarges the
   complex by filling in the hollow simplices it was missing.

Thus the clique-complex construction embeds the category of simple graphs into
the category of abstract simplicial complexes as exactly the *flag subcategory*,
with the 1-skeleton functor as a one-sided inverse that becomes a genuine inverse
precisely on flag complexes. Flag complexes are, up to this equivalence, *the
same data as graphs*.

---

## 5. Algorithms

Although the theory is stated over arbitrary (possibly infinite) vertex types,
all the constructions are effective on finite graphs and complexes. We record
the core algorithms; full type-hinted implementations accompany this paper.

### 5.1 Clique-complex enumeration

To materialize `cliqueComplex G` for a finite graph `G`, enumerate all cliques.
A clean recursive scheme is a Bron–Kerbosch-style traversal, or, for full
enumeration of *all* faces (not just maximal cliques), a subset-growing search:

```
function ALL_CLIQUES(G = (V, E)):
    faces ← { ∅ }
    for each clique C already found, in increasing size:
        for each vertex v adjacent to every member of C with v ∉ C:
            add C ∪ {v} to faces
    return faces
```

The number of faces can be exponential in |V| (a complete graph on n vertices
has 2ⁿ faces), which is intrinsic: the clique complex of `Kₙ` is the full
(n−1)-simplex with all 2ⁿ subsets as faces. Enumeration is therefore output-
sensitive; the cost is proportional to the (possibly large) size of the complex.

### 5.2 Flagness testing

To test whether a given finite complex `K` is flag, one verifies the single
"missing simplex" condition: for every vertex set `s` whose pairs are all edges
of `oneSkel K`, check `s ∈ K.faces`. Equivalently, by Theorem E, compute
`cliqueComplex (oneSkel K)` and test set equality with `K.faces`. Since `K ⊆
cliqueComplex (oneSkel K)` always holds (Theorem D's ⊆ direction needs only
downward closure), flagness reduces to checking the reverse inclusion: every
clique of the 1-skeleton is a face of `K`.

```
function IS_FLAG(K):
    G ← ONE_SKELETON(K)
    for each clique C of G:
        if C ∉ K.faces:
            return False          # hollow simplex found
    return True
```

The witness returned on failure — a clique of the skeleton that is not a face —
is exactly a *hollow simplex*, the minimal certificate that `K` is not flag.

### 5.3 1-skeleton extraction

Extracting `oneSkel K` is immediate: scan the size-2 faces.

```
function ONE_SKELETON(K):
    V ← { a : {a} ∈ K.faces }
    E ← { {a, b} : {a, b} ∈ K.faces ∧ a ≠ b }
    return (V, E)
```

---

## 6. Applications

### 6.1 Topological data analysis

Given a finite metric space (a point cloud) and a scale `ε`, the *Vietoris–Rips
complex* `Rips(X, ε)` is the clique complex of the graph connecting points
within distance `ε`. Theorem A guarantees `Rips(X, ε)` is flag, and Theorem E
guarantees it is *fully determined by its edges*. This is the theoretical
license for the central efficiency of TDA pipelines: persistence software stores
and updates only the proximity graph, reconstructing higher simplices on demand,
with the certainty that no homological information is lost. The monotonicity
`Rips(X, ε) ⊆ Rips(X, ε')` for `ε ≤ ε'` — the basis of *persistent homology* —
is likewise a statement about the underlying graphs propagated upward by
flagness.

### 6.2 Distributed sensing and coverage

In a sensor network each node knows only its communication neighbors — purely
1-skeletal, local data. Whether the network covers a region without holes is a
*global* topological question about the associated complex. Flagness is what
makes the global question answerable from local data: because the coverage
complex is the clique complex of the communication graph, its global topology is
implied by the edges every node already knows, enabling decentralized hole-
detection protocols.

### 6.3 Geometric group theory

Flag complexes are the natural domain of several rigidity phenomena. Gromov's
link condition characterizes CAT(0) cube complexes via flagness of vertex links;
right-angled Artin groups and Coxeter groups are encoded by flag complexes
(their *defining* / *nerve* complexes); and Davis complexes are built so that
local flag conditions force global non-positive curvature. In each case the
operative principle is the one made precise here: a combinatorial condition on
edges (flagness) determines the entire high-dimensional object and its geometry.

### 6.4 Independence and other induced complexes

The independence complex of a graph `G` is the clique complex of its complement;
neighborhood, matching, and Hom complexes are likewise clique complexes of
auxiliary graphs. Theorem E says all of these are recognizable purely by the
flag test, and that their entire face structure is recoverable from a single
graph — a uniform organizing principle across an otherwise scattered zoo of
constructions.

---

## 7. Discussion

The mathematics here is elementary in the best sense: the proofs are short, but
they pin down an equivalence that is invoked constantly and rarely stated with
full precision. Three points deserve emphasis.

First, **the hypotheses are minimal**. The vertex type is arbitrary; nothing is
assumed finite except individual faces (which are finite by definition of
`Finset`). The results therefore apply to clique complexes of infinite graphs,
where they remain true verbatim. The only structural inputs are downward closure
and the elementary symmetric/irreflexive nature of the 1-skeleton.

Second, **flagness is a dimension-1 condition with dimension-∞ consequences**.
The defining clause of `IsFlag` quantifies only over pairs (via the 1-skeleton),
yet it controls faces of every dimension. This "locality at the edges" is exactly
what makes flag complexes computationally and conceptually tractable: an object
of unbounded dimension is specified by a quadratic amount of data.

Third, **the equivalence is sharp**. Theorem E is an "if and only if"; non-flag
complexes genuinely exist (the boundary of a triangle — three edges, no filled
2-face — is the smallest example, where the skeleton is a 3-cycle whose clique
complex *would* fill the triangle). The hollow simplex is the precise obstruction,
and the recognition test detects it.

A subtle formalization point worth recording: the singleton-presence axiom in
Definition 2.1 is logically redundant given downward closure, yet keeping it
explicit clarifies that the vertex set is part of the data and streamlines the
proof that `cliqueComplex G` is a valid ASC. Theorem C exists to make the
conceptual status of singletons unambiguous.

---

## 8. Future Directions

The present results characterize *which* complexes are flag. Several natural
extensions build directly on the formalized core.

**1. Homotopy and homology invariance through the skeleton.** Theorem E says a
flag complex is determined by its graph as a *set of faces*. The natural next
target is to formalize that its *homotopy type* and *simplicial homology* are
therefore computable from the graph alone, recovering, e.g., that the clique
complex of a graph with no induced cycles of length ≥ 4 is collapsible. This
turns the structural recognition theorem into a computational topology engine.

**2. Functoriality and the flag–graph equivalence.** Promote the round-trip of
Section 4 to a formal equivalence of categories between simple graphs (with
graph homomorphisms) and flag complexes (with simplicial maps). The expected
statement: `cliqueComplex` and `oneSkel` form an adjoint pair restricting to an
equivalence on the flag subcategory. This would let theorems about graphs
transfer mechanically to flag complexes and back.

**3. Quantitative flagness and the hollow-simplex spectrum.** For a non-flag
complex, measure *how far* it is from flag by the dimensions and number of its
hollow simplices (cliques of the skeleton that fail to be faces). Conjecture: the
minimal hollow simplices form a well-structured obstruction set whose generating
function is a meaningful invariant, refining the binary flag test of Section 5.2
into a graded measure.

**4. Persistent flag filtrations.** Formalize the Vietoris–Rips filtration
`ε ↦ Rips(X, ε)` and prove, from Theorem A, that the entire filtration is a
sequence of flag complexes determined by a single edge-length function. The
target is a verified persistence theorem: the persistence module of a Rips
filtration is computable from the weighted 1-skeleton, with stability under
perturbation of the metric.

**5. Local flagness and curvature.** Capture Gromov's link condition formally:
a cube/simplicial complex is locally CAT(0) iff all vertex links are flag.
Building on the present `IsFlag` predicate, this would connect the combinatorial
recognition theorem to global geometric (non-positive curvature) consequences,
the engine behind much of geometric group theory.

---

## 9. Conclusion

We have given a complete, self-contained account of the equivalence between flag
complexes and clique complexes. The clique complex of any graph is flag and
faithfully records its edges (Theorems A, B); conversely a complex is flag
exactly when it is the clique complex of its own 1-skeleton (Theorems D, E).
Together these results identify flag complexes with simple graphs and explain,
at the level of definitions, why a one-dimensional skeleton can dictate an
arbitrarily high-dimensional shape. The skeleton, for a flag complex, remembers
everything.
