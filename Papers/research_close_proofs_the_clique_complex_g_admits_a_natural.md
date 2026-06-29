# The Integral Simplicial Chain Complex of a Clique Complex: An Order-Theoretic Construction

## Abstract

The clique complex Δ(G) of a simple graph G is the abstract simplicial complex
whose k-faces are the (k+1)-cliques of G. Choosing a linear order on the vertex
set turns the collection of finite cliques into an *ordered* simplicial complex,
and the classical alternating-sum boundary operator endows the free abelian
groups on faces with the structure of a chain complex of ℤ-modules. We present a
fully self-contained, order-theoretic development of this construction. Working
on the free ℤ-module on *all* finite vertex subsets — of which the clique complex
is a downward-closed sub-object — we define an orientation sign function, a
single-simplex boundary, and its linear extension, and we prove the defining
chain-complex identity ∂ ∘ ∂ = 0. The proof avoids all heavy homological-algebra
infrastructure: it rests on a sign-reversing involution on ordered pairs of
vertices, governed by a single sign-swap identity proved by trichotomy. We then
connect the construction back to graphs: cliques are downward closed, every face
of the boundary of a clique is again a clique, and consequently the boundary
operator restricts to a genuine chain complex of Δ(G). The development is
complete and machine-checked, with no unproven assumptions.

**Keywords.** Clique complex, simplicial homology, chain complex, boundary
operator, sign-reversing involution, Vietoris–Rips complex, topological data
analysis.

---

## 1. Introduction

A *simple graph* G on a vertex set V is a symmetric, irreflexive adjacency
relation. A *clique* is a set of vertices that are pairwise adjacent. The
**clique complex** (also called the *flag complex*) Δ(G) is the abstract
simplicial complex whose simplices are exactly the finite cliques of G: a vertex
is a 0-simplex, an edge a 1-simplex, a triangle a 2-simplex, and in general a
(k+1)-clique is a k-simplex.

The clique complex is one of the most important constructions linking
combinatorics to algebraic topology. It is the engine behind the
Vietoris–Rips complex of topological data analysis, behind coverage criteria in
sensor networks, and behind topological models of neural activity. In every such
application, the geometric content of the graph is extracted through *simplicial
homology*, and the entire homological apparatus depends on one foundational
identity: the boundary of a boundary is zero, ∂² = 0.

This paper develops the integral chain complex of Δ(G) from first principles and
gives a clean, self-contained proof of ∂² = 0. The novelty is methodological:
rather than importing a general simplicial-homology library, we work directly
with the free ℤ-module `Finsupp` on finite vertex subsets, define orientation
signs by counting order-predecessors, and prove ∂² = 0 through an explicit
sign-reversing involution. The argument is short, elementary, and transfers
verbatim to the clique complex via downward closure of cliques.

Throughout, V is a type equipped with a linear order, and we write `Finset V` for
the type of finite subsets of V and `Finset V →₀ ℤ` for the free ℤ-module on
`Finset V` (finitely supported integer-valued functions on finite subsets).

---

## 2. Definitions

### 2.1 The orientation sign

The orientation of a face within an ordered simplex is recorded by a sign.

**Definition 2.1 (Orientation sign).** For a vertex `x ∈ V` and a finite set
`s : Finset V`, the *orientation sign* of `x` in `s` is

> sgn(x, s) := (−1)^{ | { y ∈ s : y < x } | } ∈ ℤ.

Equivalently, sgn(x, s) is (−1) raised to the *rank* of `x` — the number of
elements of `s` strictly below `x` in the linear order, i.e. the position of `x`
in the increasing enumeration of `s` (counting from 0).

This is the function `sgn` of the formal development:
`sgn x s = (-1) ^ (s.filter (· < x)).card`.

### 2.2 The boundary operator

**Definition 2.2 (Single-simplex boundary).** For `s : Finset V`, the
*boundary* of the oriented simplex `s` is the chain

> ∂(s) := Σ_{x ∈ s} sgn(x, s) · ⟦ s ∖ {x} ⟧ ∈ (Finset V →₀ ℤ),

where ⟦ t ⟧ denotes the basis element associated to the face `t` (formally
`Finsupp.single t 1`). In the formal text this is

`bdSingle s = ∑ x ∈ s, Finsupp.single (s.erase x) (sgn x s)`.

Expanding the sign, this is the familiar alternating sum: if
`s = {x₀ < x₁ < ⋯ < x_k}`, then
∂(s) = Σ_{i=0}^{k} (−1)^i ⟦ s ∖ {xᵢ} ⟧.

**Definition 2.3 (Boundary on chains).** The *boundary operator* on the free
ℤ-module of chains is the unique ℤ-linear extension of ∂:

> ∂ : (Finset V →₀ ℤ) → (Finset V →₀ ℤ),    ∂ := Finsupp.linearCombination ℤ (bdSingle).

This is `bd`, a `ℤ`-linear map. By construction it satisfies, on a basis chain
`c · ⟦s⟧`,

> ∂(c · ⟦s⟧) = c · ∂(s)        (Lemma `bd_single`).

### 2.3 Faces of a graph's clique complex

**Definition 2.4 (Face).** For a simple graph G on V and `s : Finset V`, we say
`s` is a *face* of Δ(G), written `IsFace G s`, when `s` is a clique of G:

> IsFace(G, s) :⇔ G.IsClique (s : Set V).

---

## 3. Main results

### 3.1 The chain-complex identity

The central theorem is the defining property of a chain complex.

**Theorem 3.1 (∂² = 0 on chains).** For every chain `z : Finset V →₀ ℤ`,

> ∂(∂(z)) = 0.

Formally, `boundary_sq_zero : bd (bd z) = 0`. Equivalently, as an identity of
linear maps,

**Theorem 3.2 (Chain-complex identity).** `∂ ∘ ∂ = 0`, i.e.
`boundary_comp_self : (bd).comp bd = 0`.

The pair (Finset V →₀ ℤ, ∂) is therefore a chain complex of ℤ-modules.

### 3.2 Downward closure and restriction to Δ(G)

**Theorem 3.3 (Faces are downward closed).** If `t ⊆ s` and `s` is a face of
Δ(G), then `t` is a face of Δ(G). (`isFace_downward_closed`.)

**Proposition 3.4 (Trivial faces).** The empty set is a face (`empty_isFace`),
and every singleton `{v}` is a face (`singleton_isFace`).

**Theorem 3.5 (Boundary preserves faces).** If `s` is a face of Δ(G), then every
face in the support of ∂(s) is again a face of Δ(G). (`bdSingle_support_isFace`.)

Theorem 3.5, together with Theorem 3.1, shows that the construction restricts to
a genuine chain complex on the subcomplex of clique-chains: the boundary never
leaves the clique complex, and ∂² = 0 holds there a fortiori.

---

## 4. Proof sketches

### 4.1 Sign bookkeeping under erasure

The whole argument is controlled by how the sign of a vertex `y` changes when a
different vertex `x` is erased from `s`. There are two cases.

**Lemma 4.1 (Erasing a non-predecessor preserves the sign).** If `¬ (x < y)`,
then `sgn(y, s ∖ {x}) = sgn(y, s)`. (`sgn_erase_not_lt`.)

*Sketch.* The sign of `y` counts the elements of `s` below `y`. Erasing `x`
removes from this count only if `x < y`. Since `x` is not below `y`, the filtered
set `{ z ∈ s : z < y }` is unchanged by erasing `x` (`Finset.filter_erase`), so
the cardinality, and hence the sign, is unchanged. ∎

**Lemma 4.2 (Erasing a predecessor flips the sign).** If `x ∈ s` and `x < y`,
then `sgn(y, s ∖ {x}) = − sgn(y, s)`. (`sgn_erase_lt`.)

*Sketch.* Here `x` *is* counted among the predecessors of `y` in `s`. Erasing it
decreases that count by exactly one; the count is positive because it contains
`x`. Hence the exponent of (−1) drops by one, and using
(−1)^{n+1} = −(−1)^n the sign flips. ∎

### 4.2 The sign-swap identity

**Lemma 4.3 (Sign swap).** For distinct `x, y ∈ s`,

> sgn(x, s) · sgn(y, s ∖ {x}) = − [ sgn(y, s) · sgn(x, s ∖ {y}) ].
> (`sgn_swap`.)

*Sketch.* By trichotomy on the linear order, either `x < y` or `y < x`.

- If `x < y`: erasing `x` flips the sign of `y` (Lemma 4.2), so the left side is
  `−sgn(x,s)·sgn(y,s)`. On the right, `y > x` means erasing `y` does *not* change
  the sign of `x` (Lemma 4.1), so the right side equals `−sgn(y,s)·sgn(x,s)`.
  The two expressions agree.
- If `y < x`: symmetric, with the roles of the two lemmas exchanged.

In both cases the identity holds by elementary ring manipulation. ∎

Lemma 4.3 is the algebraic incarnation of the geometric fact that the two orders
of removing the unordered pair {x, y} carry opposite orientations.

### 4.3 Vanishing of the double boundary on a single simplex

**Lemma 4.4 (∂² = 0 on a simplex).** For every `s : Finset V`,
`∂(∂(s)) = 0`. (`bd_bdSingle`.)

*Sketch.* Expanding both boundaries gives a double sum over ordered pairs (x, y)
with `x ∈ s` and `y ∈ s ∖ {x}`, of terms supported on the face
`(s ∖ {x}) ∖ {y}` with coefficient `sgn(x, s) · sgn(y, s ∖ {x})`. The key
geometric observation is that erasure commutes:

> (s ∖ {x}) ∖ {y} = (s ∖ {y}) ∖ {x}        (`Finset.erase_right_comm`).

Thus the term indexed by (x, y) and the term indexed by (y, x) land on the *same*
face. Their coefficients are, by Lemma 4.3, negatives of one another. Reindexing
the double sum over the sigma-set `Σ_{x ∈ s} (s ∖ {x})` and applying the bijection
(x, y) ↦ (y, x) shows that the sum equals its own negative — equivalently, the
sum and its swapped copy add to zero termwise (the `h_pair` step), so the total
is zero. ∎

This is exactly the *sign-reversing involution* argument: the pairing
(x, y) ↦ (y, x) is a fixed-point-free involution on the index set that negates
every summand, forcing the sum to vanish.

### 4.4 From one simplex to all chains

**Proof of Theorem 3.1.** By `Finsupp.induction` on `z`. The zero chain maps to
zero. For a chain `Finsupp.single a b + f` with the result holding for `f`, use
linearity of `∂` (`bd_single`, `map_add`) to reduce the double boundary to
`b · ∂(∂(a)) + ∂(∂(f))`, which vanishes by Lemma 4.4 and the induction
hypothesis. ∎

**Proof of Theorem 3.2.** Two linear maps are equal iff they agree on every
input; apply Theorem 3.1 pointwise (`LinearMap.ext`). ∎

### 4.5 The clique-theoretic side

**Proof of Theorem 3.3.** A clique is a set of pairwise-adjacent vertices; the
adjacency relation restricted to a subset `t ⊆ s` of a clique `s` is still
total, so `t` is a clique. Formally this is `SimpleGraph.IsClique.subset`
applied to the coercion `t ⊆ s`. ∎

**Proof of Proposition 3.4.** The empty set and singletons are vacuously
cliques: there are no two distinct vertices to check adjacency for. ∎

**Proof of Theorem 3.5.** Every element of the support of ∂(s) is of the form
`s ∖ {x}` for some `x ∈ s` (the only faces appearing in the defining sum). Since
`s ∖ {x} ⊆ s` and `s` is a face, downward closure (Theorem 3.3) yields that
`s ∖ {x}` is a face. ∎

---

## 5. Algorithms

The construction is entirely computable when V has decidable order and finite
cliques are enumerable. We record the core procedures.

### 5.1 Computing the orientation sign

```
function sgn(x, s):
    rank ← count of y in s with y < x
    return (-1) ^ rank
```

### 5.2 Computing the boundary of a simplex

```
function boundary(s):                       # returns a map face ↦ coefficient
    chain ← empty integer-valued map
    for x in s:
        face ← s without x
        chain[face] += sgn(x, s)
    return chain
```

### 5.3 Composing two boundaries (to verify ∂² = 0)

```
function boundary2(s):
    total ← empty integer-valued map
    for (face1, c1) in boundary(s):
        for (face2, c2) in boundary(face1):
            total[face2] += c1 * c2
    return total                             # provably all-zero
```

### 5.4 Reduced Euler characteristic of Δ(G)

```
function euler_characteristic(G):
    chi ← 0
    for k from 0 upward while (k+1)-cliques exist:
        chi += (-1)^k * number_of_cliques_of_size(k+1, G)
    return chi
```

---

## 6. Applications

**Topological data analysis.** The Vietoris–Rips complex of a finite metric space
at scale ε is precisely the clique complex of the graph connecting points within
distance ε. The homology computed from the chain complex of §2–3 — well-defined
because ∂² = 0 — is the foundation of persistent homology, which extracts loops,
voids, and clusters from point-cloud data.

**Sensor networks.** With sensors as vertices and overlapping coverage as edges,
the homology of the clique complex detects coverage holes intrinsically, without
coordinate data. A nonzero first homology class is a region that the sensor field
fails to cover.

**Combinatorial invariants.** The reduced Euler characteristic of §5.4 is the
alternating sum of clique counts. Because ∂² = 0 makes homology well-defined, the
Euler–Poincaré principle equates this combinatorial number with the alternating
sum of homology ranks; it is therefore an invariant of the clique complex up to
homotopy.

**Neuroscience.** Cliques of co-active neurons assemble into a clique complex
whose homology distinguishes structured (low-dimensional, geometric) activity
from unstructured noise.

---

## 7. Discussion

The contribution here is a maximally elementary, machine-checked construction of
the integral chain complex of a clique complex, with ∂² = 0 proved by a single
sign-reversing involution rather than by appeal to a general homology library.
The proof's economy is its point: the only ingredients are (i) a linear order,
(ii) the rank-counting sign function, and (iii) the commutativity of erasure. The
sign-swap identity (Lemma 4.3) localizes the cancellation to unordered pairs of
vertices, and the involution (x, y) ↦ (y, x) globalizes it.

A deliberate design choice is to define the boundary on the free module over
*all* finite subsets and then to certify (Theorem 3.5) that it preserves cliques,
rather than to build the boundary on the clique subcomplex from the outset. This
decouples the purely combinatorial identity ∂² = 0 — which has nothing to do with
graphs — from the graph-theoretic fact that cliques are downward closed. The
result is that the same ∂² = 0 proof serves *every* downward-closed family of
faces, of which clique complexes are the canonical example.

A limitation of the present development is that it stops at the chain level: it
provides the chain complex and the restriction property, but does not yet package
the clique-chains as a formal submodule, nor define the homology groups
themselves. These are the natural next steps, outlined below.

---

## 8. Future work

1. **An honest endomorphism of the clique subcomplex.** Package the
   clique-chains as the submodule `cliqueChains G = Finsupp.supported ℤ ℤ {s | IsFace G s}`
   and prove ∂ maps it into itself, yielding a genuine ℤ-chain complex
   `(cliqueChains G, ∂)` and hence well-defined homology groups Hₖ(Δ(G); ℤ). The
   downward closure of cliques (Theorem 3.3) is precisely the algebraic condition
   that makes `Finsupp.supported` invariant under ∂; the only missing glue is the
   restriction lemma, a direct corollary of Theorem 3.5.

2. **Euler characteristic as a homotopy invariant.** Define the reduced Euler
   characteristic χ(Δ(G)) = Σ_k (−1)^k · |{(k+1)-cliques}| via cliqueFinset, and
   prove the Euler–Poincaré identity equating it with the alternating sum of
   homology ranks. The same sign bookkeeping that kills ∂² controls the
   rank-counting identity.

3. **Functoriality.** Show that a graph homomorphism inducing an injection on
   cliques yields a chain map, making Δ(–) a functor into chain complexes, and
   deduce homotopy invariance of homology under clique-complex isomorphism.

4. **Computation.** Use the computable boundary to build a verified Smith-normal-form
   homology calculator for small graphs, with machine-checked outputs.

---

## 9. Conclusion

From a single order-theoretic idea — assign each vertex the sign (−1) raised to
the number of its predecessors — we obtain the full integral chain complex of a
clique complex and a transparent proof that ∂² = 0. The proof is a sign-reversing
involution on ordered pairs, and it descends to the clique complex because cliques
are downward closed. This places the homological foundation of clique complexes on
an elementary, fully verified footing, ready to support homology groups, Euler
characteristics, and the applications that depend on them.
