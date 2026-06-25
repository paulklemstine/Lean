# The Component-Kernel Theorem and the Spectral Modular Signature of a Finite Graph

**Author:** Aristotle

**Date:** 2026-06-25

## Abstract

We develop, in full rigor, the finite-dimensional linear-algebra core of a
proposed theory of *spectral proof-difficulty signatures*. Given a finite simple
graph $G$ on a vertex set $V$, viewed through the real vector space $V \to
\mathbb{R}$ of vertex functions, we define the **harmonic kernel**
$\mathcal{H}(G)$ to be the subspace of functions that are constant across every
edge, and the **spectral modular signature** $\mathrm{specModSig}(G)$ to be its
dimension. Our main result, the **component-kernel theorem**, asserts that this
dimension equals the number of connected components of $G$:
$$\mathrm{specModSig}(G) = \#\,\pi_0(G).$$
The proof proceeds by constructing an explicit linear isomorphism
$\mathcal{H}(G) \cong (\pi_0(G) \to \mathbb{R})$ between harmonic vertex functions
and arbitrary functions on the set of connected components, then taking
dimensions. We deduce that the signature is positive on nonempty graphs, bounded
above by the vertex count, equal to $1$ exactly for connected graphs, maximal
exactly for edgeless graphs, and invariant under graph isomorphism. We explain
how the harmonic kernel coincides with the null space of the combinatorial graph
Laplacian $L = D - A$, situating the theorem as the coordinate-free heart of the
classical spectral fact that the Laplacian's nullity counts components, and we
outline its role as the $H^0$ base case of a sheaf-theoretic theory of
dependency structures. The result is intended as a verified anchor on which a
geometry-based theory of formal-proof difficulty can be built. We make **no**
empirical claim about proof lengths and prove **no** asymptotic difficulty
conjecture; we isolate the rigorous mathematical foundation.

---

## 1. Introduction

### 1.1 Motivation

Large formal mathematics libraries — those of Lean, Coq, and Isabelle — are, at
their core, vast dependency networks: each declaration depends on finitely many
others, and the whole forms a directed acyclic graph on tens of thousands of
nodes. A natural and ambitious conjecture is that the *difficulty* of a theorem,
measured by the length of its shortest formal proof, is governed by the
*geometry* of this dependency structure together with the local data of type
constraints and unification. The sharpest form of the conjecture is spectral: the
minimal proof length should be predicted, up to a universal sublinear error
term, by the low-lying spectrum of a generalized (sheaf) Laplacian assembled from
the dependency hypergraph and its local data.

Any such program must rest on a precisely understood base case. The simplest
generalized Laplacian is the ordinary combinatorial graph Laplacian, and its most
robust spectral invariant is the multiplicity of its zero eigenvalue, which
classically counts connected components. This paper isolates and formally
verifies exactly this base case in a coordinate-free form, so that the rest of
the theory has a rigorous foundation to build on. We emphasize at the outset that
this paper establishes mathematics, not empirics: we prove a theorem about graphs
and deduce its corollaries, and we do not test any difficulty-prediction
hypothesis here.

### 1.2 Contributions

1. A self-contained definition of the harmonic kernel $\mathcal{H}(G)$ as a
   submodule of $V \to \mathbb{R}$, and of the spectral modular signature
   $\mathrm{specModSig}(G) = \dim_{\mathbb{R}} \mathcal{H}(G)$.
2. The structural lemmas that harmonic functions are constant along walks and on
   reachable pairs, including the equivalence between edge-flatness and
   reachability-constancy.
3. An explicit linear isomorphism $\mathcal{H}(G) \cong (\pi_0(G) \to
   \mathbb{R})$.
4. The component-kernel theorem $\mathrm{specModSig}(G) = \#\,\pi_0(G)$.
5. Sharp corollaries: positivity, the vertex-count bound, the connectivity
   characterization, the edgeless characterization, and isomorphism invariance.
6. A discussion situating the result within spectral graph theory (the Laplacian
   nullity) and within a prospective sheaf-cohomological theory of dependency
   structures.

---

## 2. Setting and definitions

Throughout, $V$ is a type (a set of vertices) and $G$ is a **finite simple
graph** on $V$: a symmetric, irreflexive adjacency relation, written $u \sim v$
when $u$ and $v$ are adjacent. For the dimension-theoretic results we assume $V$
is finite with decidable equality and that adjacency is decidable. We work over
the field $\mathbb{R}$, although every statement holds verbatim over any field.

The set of all vertex functions $V \to \mathbb{R}$ is a real vector space under
pointwise addition and scalar multiplication.

**Definition 2.1 (Harmonic kernel).** The *harmonic kernel* of $G$ is
$$\mathcal{H}(G) := \{\, f : V \to \mathbb{R} \mid u \sim v \implies f(u) = f(v)
\ \text{for all } u, v \,\}.$$
It is a submodule (linear subspace) of $V \to \mathbb{R}$: it contains the zero
function, and it is closed under addition and scalar multiplication, because
each defining equation $f(u) = f(v)$ is preserved by these operations.

We record the membership criterion explicitly: $f \in \mathcal{H}(G)$ if and
only if $f(u) = f(v)$ for every adjacent pair $u \sim v$.

**Definition 2.2 (Connected components).** Two vertices $u, v$ are *reachable*,
written $u \rightsquigarrow v$, if there is a walk from $u$ to $v$ in $G$.
Reachability is an equivalence relation; its equivalence classes are the
*connected components*, and $\pi_0(G)$ denotes the set of components. The map
$[\,\cdot\,] : V \to \pi_0(G)$ sends each vertex to its component; it is
surjective by construction.

**Definition 2.3 (Spectral modular signature).** The *spectral modular signature*
of $G$ is
$$\mathrm{specModSig}(G) := \dim_{\mathbb{R}} \mathcal{H}(G) \in \mathbb{N}.$$

---

## 3. Harmonic functions are locally constant

The defining condition of $\mathcal{H}(G)$ constrains adjacent vertices, but it
propagates to all reachable vertices.

**Lemma 3.1 (Constancy along walks).** If $f \in \mathcal{H}(G)$ and $p$ is a
walk from $u$ to $v$, then $f(u) = f(v)$.

*Proof sketch.* Induct on the walk. The empty walk has $u = v$, so $f(u) = f(v)$
trivially. For a walk $u \sim w \rightsquigarrow v$ decomposed as one edge
followed by a shorter walk, edge-flatness gives $f(u) = f(w)$ and the inductive
hypothesis gives $f(w) = f(v)$; compose. $\qquad\blacksquare$

**Lemma 3.2 (Constancy on reachable pairs).** If $f \in \mathcal{H}(G)$ and
$u \rightsquigarrow v$, then $f(u) = f(v)$.

*Proof sketch.* Reachability provides a walk; apply Lemma 3.1. $\quad\blacksquare$

**Proposition 3.3 (Edge-flatness equals reachability-constancy).** For any
$f : V \to \mathbb{R}$,
$$f \in \mathcal{H}(G) \iff \big(u \rightsquigarrow v \implies f(u) = f(v)\
\text{for all } u, v\big).$$

*Proof sketch.* ($\Rightarrow$) is Lemma 3.2. ($\Leftarrow$): adjacency implies
reachability (a single edge is a walk), so constancy on reachable pairs in
particular forces edge-flatness. $\qquad\blacksquare$

Proposition 3.3 is the conceptual pivot: the local condition defining
$\mathcal{H}(G)$ is identical to the global condition of being constant on each
connected component. A harmonic function is exactly a function that assigns one
value per component.

---

## 4. The component-function isomorphism

We now turn the informal "one value per component" description into an explicit
linear isomorphism. Assume $V$ finite with decidable adjacency.

**Definition 4.1 (Descent map).** Define $\Phi : \mathcal{H}(G) \to (\pi_0(G) \to
\mathbb{R})$ as follows. Given $f \in \mathcal{H}(G)$, the value $f(v)$ depends
only on the component $[v]$ of $v$, by Lemma 3.1 (any two representatives of a
component are joined by a walk). Hence $f$ descends to a well-defined function
$\Phi(f) : \pi_0(G) \to \mathbb{R}$ with $\Phi(f)([v]) = f(v)$. The map $\Phi$ is
linear: descent commutes with pointwise addition and scaling, checked on
representatives.

**Definition 4.2 (Pullback map).** Define $\Psi : (\pi_0(G) \to \mathbb{R}) \to
\mathcal{H}(G)$ by $\Psi(g)(v) = g([v])$. The result lies in $\mathcal{H}(G)$
because adjacent vertices share a component: if $u \sim v$ then $[u] = [v]$, so
$\Psi(g)(u) = g([u]) = g([v]) = \Psi(g)(v)$. The map $\Psi$ is linear by
pointwise reasoning.

**Theorem 4.3 (Component-function isomorphism).** The maps $\Phi$ and $\Psi$ are
mutually inverse linear isomorphisms:
$$\mathcal{H}(G) \;\cong_{\mathbb{R}}\; (\pi_0(G) \to \mathbb{R}).$$

*Proof sketch.* $\Phi \circ \Psi = \mathrm{id}$: for $g : \pi_0(G) \to
\mathbb{R}$ and a component $[v]$, $\Phi(\Psi(g))([v]) = \Psi(g)(v) = g([v])$.
Since $[\,\cdot\,]$ is surjective, this determines the identity on all of
$\pi_0(G)$. $\Psi \circ \Phi = \mathrm{id}$: for $f \in \mathcal{H}(G)$ and a
vertex $v$, $\Psi(\Phi(f))(v) = \Phi(f)([v]) = f(v)$. Both composites are the
identity, so $\Phi$ is a linear equivalence with inverse $\Psi$.
$\qquad\blacksquare$

---

## 5. The component-kernel theorem

**Theorem 5.1 (Component-kernel theorem).** For a finite simple graph $G$,
$$\mathrm{specModSig}(G) = \#\,\pi_0(G).$$

*Proof sketch.* By Theorem 4.3, $\mathcal{H}(G) \cong (\pi_0(G) \to \mathbb{R})$,
and linear equivalences preserve dimension, so $\dim_{\mathbb{R}} \mathcal{H}(G)
= \dim_{\mathbb{R}}(\pi_0(G) \to \mathbb{R})$. The space of real-valued functions
on a finite set $S$ has dimension $\#S$ (the indicator functions form a basis),
so $\dim_{\mathbb{R}}(\pi_0(G) \to \mathbb{R}) = \#\,\pi_0(G)$. Combining,
$\mathrm{specModSig}(G) = \#\,\pi_0(G)$. $\qquad\blacksquare$

---

## 6. Corollaries

The component-kernel theorem reduces every question about the signature to a
question about counting components.

**Corollary 6.1 (Positivity).** If $V$ is nonempty, then $\mathrm{specModSig}(G)
> 0$.

*Proof sketch.* A vertex yields a component, so $\pi_0(G)$ is nonempty, hence
$\#\,\pi_0(G) \ge 1$; apply Theorem 5.1. $\qquad\blacksquare$

**Corollary 6.2 (Vertex-count bound).** $\mathrm{specModSig}(G) \le \#V$.

*Proof sketch.* The component map $V \to \pi_0(G)$ is surjective, so
$\#\,\pi_0(G) \le \#V$; apply Theorem 5.1. $\qquad\blacksquare$

**Corollary 6.3 (Connectivity characterization).** $G$ is connected if and only
if $\mathrm{specModSig}(G) = 1$.

*Proof sketch.* A graph is connected iff it is (pre)connected and nonempty, which
holds iff $\pi_0(G)$ is a one-element set, i.e. $\#\,\pi_0(G) = 1$. Concretely,
preconnectedness means any two vertices are reachable, i.e. all components
coincide (the component type is a subsingleton), while nonemptiness supplies one
component; together these say $\#\,\pi_0(G) = 1$. Apply Theorem 5.1.
$\qquad\blacksquare$

**Corollary 6.4 (Edgeless characterization).** $\mathrm{specModSig}(G) = \#V$ if
and only if $G$ is edgeless (has no edges).

*Proof sketch.* The component map is always surjective; it is *injective* — so
that $\#\,\pi_0(G) = \#V$ — exactly when no two distinct vertices are reachable,
which for a finite simple graph happens precisely when there are no edges. Apply
Theorem 5.1. $\qquad\blacksquare$

**Corollary 6.5 (Isomorphism invariance).** If $G$ and $H$ are isomorphic finite
simple graphs, then $\mathrm{specModSig}(G) = \mathrm{specModSig}(H)$.

*Proof sketch.* A graph isomorphism induces a bijection on connected components,
so $\#\,\pi_0(G) = \#\,\pi_0(H)$; apply Theorem 5.1 to both sides.
$\qquad\blacksquare$

---

## 7. The spectral interpretation

The name *spectral* is justified by the connection to the combinatorial graph
Laplacian. Order the vertices and form the adjacency matrix $A \in \mathbb{R}^{V
\times V}$, with $A_{uv} = 1$ when $u \sim v$ and $0$ otherwise, and the diagonal
degree matrix $D$, with $D_{uu} = \deg(u)$. The **Laplacian** is $L = D - A$.

Its defining property is the Dirichlet identity
$$f^\top L f = \sum_{u \sim v} \big(f(u) - f(v)\big)^2,$$
where the sum ranges over unordered edges. The right-hand side is a sum of
squares, hence nonnegative, and it vanishes if and only if $f(u) = f(v)$ for
every edge — that is, if and only if $f \in \mathcal{H}(G)$. Because $L$ is
symmetric positive semidefinite, $f^\top L f = 0$ is equivalent to $Lf = 0$.
Therefore
$$\ker L = \mathcal{H}(G),$$
and the **nullity** of the Laplacian equals $\mathrm{specModSig}(G)$. Theorem 5.1
then reads, in classical language, as

> the multiplicity of the eigenvalue $0$ of the combinatorial Laplacian equals
> the number of connected components,

a foundational fact of spectral graph theory. The component-kernel theorem is its
coordinate-free heart: it proves the structurally essential content — that the
nullspace is the space of locally constant functions and that this space has
dimension equal to the component count — without committing to any matrix
representation. Promoting it to the literal matrix statement is a re-encoding
(defining $L$, proving the Dirichlet identity, and identifying $\ker L$ with
$\mathcal{H}(G)$) rather than a new theorem.

---

## 8. Algorithms

Because the signature equals a component count, it is exactly computable. We
describe two algorithms.

### 8.1 Signature by connected components

Given the adjacency structure of $G$, compute $\#\,\pi_0(G)$ by a union-find or
breadth-first sweep, then return that integer as $\mathrm{specModSig}(G)$. With
$n = \#V$ vertices and $m$ edges, union-find with path compression and union by
rank runs in $O((n + m)\,\alpha(n))$ time, where $\alpha$ is the inverse
Ackermann function — effectively linear. By Theorem 5.1 the output is provably the
dimension of $\mathcal{H}(G)$.

### 8.2 Signature by Laplacian nullity

Alternatively, assemble $L = D - A$ and compute $\dim \ker L$ by Gaussian
elimination (rank $= n - \mathrm{nullity}$), in $O(n^3)$ time, or estimate the
multiplicity of the zero eigenvalue numerically. By the identity $\ker L =
\mathcal{H}(G)$ this returns the same integer. The two algorithms agreeing on
every input is a computational shadow of Theorem 5.1 and Section 7; the
component-based method is asymptotically far cheaper and numerically exact, which
is why it is the algorithm of choice when only the signature (not the full
spectrum) is needed.

---

## 9. Applications and pipeline

The intended application is a *geometry-based estimator of formal-proof
difficulty*. The pipeline is:

1. **Extract** the dependency DAG of a formal library (Lean's import graph plus
   declaration-level dependency traversal).
2. **Symmetrize** it into a finite simple graph $G$ on the set of declarations.
3. **Compute** $\mathrm{specModSig}(G) = \#\,\pi_0(G)$ as a directly printable
   integer.
4. **Compare** spectral invariants — beginning with the signature, then richer
   Laplacian spectra — against known shortest or near-shortest proof lengths, and
   against syntactic and graph-baseline predictors.

The component-kernel theorem guarantees that step 3 produces a well-defined,
isomorphism-invariant integer, and Corollaries 6.1–6.5 give its qualitative
behavior (positivity, the vertex bound, the connectivity and edgeless extremes).
This makes the signature a principled, cheaply computable first feature for such
an estimator — and a verified anchor against which the richer spectral invariants
of the full conjecture can be calibrated.

We stress the scope: this paper establishes the mathematical foundation. The
empirical conjecture — that low-lying spectra predict minimal proof length up to a
universal sublinear error — is *not* tested here, and would require the corpus
study described above.

---

## 10. Discussion and future work

The component-kernel theorem unifies three descriptions of one integer:
combinatorial (the number of connected components), algebraic (the dimension of
the space of edge-flat functions), and spectral (the nullity of the Laplacian,
i.e. the multiplicity of its lowest eigenvalue). The equality of the cutting
invariant (components) and the flowing invariant (harmonic functions) is the
discrete avatar of a general principle relating the connectivity of a space to
the fields it supports.

Three concrete directions extend the result.

**1. An explicit Laplacian bridge.** Define $L = D - A$ over $\mathbb{R}$, prove
the Dirichlet identity $f^\top L f = \sum_{u \sim v}(f(u) - f(v))^2$, deduce
$\ker L = \mathcal{H}(G)$, and read off $\mathrm{nullity}\,L = \#\,\pi_0(G)$ as a
corollary of Theorem 5.1. Because the harmonic kernel *is* the Laplacian kernel,
this is a re-encoding rather than a new theorem, and it makes the spectral
language literally true. With a mature matrix and quadratic-form API available,
this is a finite, well-scoped task.

**2. From graphs to hypergraphs and sheaves.** Real dependency structures are
hypergraphs (a lemma depends on several others at once) carrying local data (each
declaration's statement and imports), naturally modeled by a cellular sheaf on a
poset rather than a bare incidence relation. Replacing $\mathrm{SimpleGraph}$ by a
sheaf, defining the submodule of sections constant across hyperedges, and seeking
a component/cohomology count, one finds that the harmonic kernel is the
degree-zero sheaf cohomology $H^0$ of the constant sheaf. The graph theorem is
the $H^0$ shadow of a sheaf-theoretic statement that also exposes higher
invariants $H^i$; the present result is the verified base case anchoring the
higher theory.

**3. Computing signatures on real corpora.** Take the dependency DAG Lean already
exposes, symmetrize it to a finite simple graph on declarations, and compute
$\mathrm{specModSig}$ by deciding the component count. The identity
$\mathrm{specModSig}(G) = \#\,\pi_0(G)$ turns an abstract dimension into a
printable, trackable integer, so the signature of an actual library becomes a
number one can compute and compare. The requisite import-graph and reflective
tooling already ship with the toolchain, making the pipeline from a real project
to a verified component count immediate.

---

## 11. Conclusion

We have rigorously established the component-kernel theorem,
$\mathrm{specModSig}(G) = \#\,\pi_0(G)$, identifying the dimension of the harmonic
kernel of a finite simple graph with its number of connected components, and have
derived its sharp corollaries on positivity, the vertex bound, connectivity, the
edgeless extreme, and isomorphism invariance. The theorem is the coordinate-free
heart of the classical spectral fact that the Laplacian's nullity counts
components, and the verified base case for a prospective sheaf-cohomological
theory of dependency structures. It provides a principled, exactly computable,
isomorphism-invariant first invariant for a geometry-based theory of formal-proof
difficulty — while leaving the empirical difficulty conjecture itself as future
work.
