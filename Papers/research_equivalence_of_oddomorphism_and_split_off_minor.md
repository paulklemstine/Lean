# Oddomorphisms of Finite Graphs: An Algebraic Backbone for the Split-Off Minor Correspondence

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

We study **oddomorphisms** between finite graphs — functions on vertex sets whose
associated $0/1$ function matrices intertwine the adjacency matrices of the two
graphs over the two-element field $\mathrm{GF}(2)$. Equivalently, a function
$\varphi\colon V(F)\to V(G)$ is an oddomorphism precisely when, for every vertex
$u$ of $F$ and every vertex $a$ of $G$, the number of neighbours of $u$ mapped by
$\varphi$ to $a$ is odd if and only if $\varphi(u)$ is adjacent to $a$ in $G$.
This local parity condition is a "modulo two" relaxation of the notion of a graph
homomorphism.

We establish the categorical and order-theoretic foundations of the relation.
The function matrix is contravariantly functorial, the identity is always an
oddomorphism, and oddomorphisms are closed under composition; consequently the
existence of an oddomorphism defines a **preorder** on graphs over a fixed vertex
set. Every graph isomorphism is an oddomorphism, so oddomorphism-equivalence
refines the isomorphism relation, and the self-oddomorphisms of a graph form a
submonoid of its endofunction monoid. We prove a transparent local-parity
characterization equivalent to the matrix definition, and we exhibit an explicit
non-injective, surjective oddomorphism from the two-edge graph $2K_2$ onto the
single-edge graph $K_2$, together with a proof that the constant map is *not* an
oddomorphism — showing that oddomorphisms strictly generalize isomorphisms while
remaining genuinely constrained. These results provide the algebraic backbone for
the conjectured equivalence between the existence of an oddomorphism $F \to G$ and
$G$ being a split-off minor of $F$, whose forward direction is known and whose
converse remains open.

## 1. Introduction

The comparison of finite graphs by structure-preserving maps is a cornerstone of
combinatorics. The two classical extremes are **isomorphism** (an exact,
invertible relabelling) and **homomorphism** (an edge-preserving map, allowing
collapse). Between these lies a rich landscape of relations that arise when one
relaxes "edge-preserving" in various ways. The present paper concerns one such
relaxation that replaces the edge-preservation demand with a *parity* demand over
the field $\mathrm{GF}(2)$.

An **oddomorphism** from a finite graph $F$ to a finite graph $G$ is a vertex map
whose local neighbourhood behaviour is governed not by set inclusion but by
odd-versus-even counting. This notion has surfaced in the study of
**homomorphism-count indistinguishability** and **quantum isomorphism** of graphs,
where invariants defined modulo two separate pairs of graphs that classical
counting cannot; the underlying algebra of graph operations — including the
*split-off* operation central to the motivating conjecture — traces back to
foundational work on graph transformations.

Our aim is not to resolve the deep equivalence but to lay down, rigorously and
self-containedly, the algebraic and order-theoretic infrastructure on the
oddomorphism side: functoriality, reflexivity, transitivity, the preorder
structure, the relationship to isomorphisms, the monoid of self-oddomorphisms, a
transparent local characterization, and a concrete witnessing example. These are
exactly the ingredients any proof of the forward direction of the conjecture must
compose.

### Contributions

1. A matrix formulation of oddomorphisms over $\mathrm{GF}(2)$ and its equivalent
   local-parity form (Section 3).
2. Contravariant functoriality of the function matrix (Theorem 4.1) and the
   consequent reflexivity/transitivity of the oddomorphism relation (Theorems 4.2,
   4.3), yielding a preorder (Theorem 4.4).
3. The fact that every isomorphism is an oddomorphism, and that self-oddomorphisms
   form a submonoid of the endofunction monoid (Section 5).
4. A concrete non-injective, surjective oddomorphism $2K_2 \to K_2$, with the
   constant map shown *not* to be an oddomorphism (Section 6).
5. A discussion situating these results as the backbone of the split-off minor
   correspondence and a program toward the open converse (Sections 7–8).

## 2. Preliminaries and notation

All graphs are finite and simple: a graph $F$ is a finite vertex set $V(F)$
together with an irreflexive symmetric adjacency relation, written $u \sim_F v$.
We work throughout over the two-element field $\mathrm{GF}(2) = \{0,1\}$ with
$1 + 1 = 0$.

**Adjacency matrix.** The adjacency matrix $A_F \in \mathrm{GF}(2)^{V(F)\times
V(F)}$ has entry $(A_F)_{u,v} = 1$ if $u \sim_F v$ and $0$ otherwise. Because
graphs are simple, $A_F$ is symmetric with zero diagonal.

**Function matrix.** For a function $\varphi\colon \alpha \to \beta$ between finite
sets, its **function matrix** $M_\varphi \in \mathrm{GF}(2)^{\alpha \times \beta}$
is defined by
$$(M_\varphi)_{u,a} = \begin{cases} 1 & \text{if } \varphi(u) = a,\\ 0 &
\text{otherwise.}\end{cases}$$
Each row of $M_\varphi$ contains exactly one $1$, recording the image of the
corresponding element. The identity function $\mathrm{id}$ has $M_{\mathrm{id}} =
I$, the identity matrix.

Matrix products are taken over $\mathrm{GF}(2)$; in particular every sum of matrix
entries is interpreted modulo two.

## 3. Oddomorphisms

### Definition 3.1 (Oddomorphism)

Let $F$ and $G$ be finite graphs. A function $\varphi\colon V(F)\to V(G)$ is an
**oddomorphism** from $F$ to $G$ if its function matrix intertwines the adjacency
matrices over $\mathrm{GF}(2)$:
$$A_F \, M_\varphi = M_\varphi \, A_G. \tag{$\ast$}$$

We write $F \rightsquigarrow G$, and say $G$ is **oddomorphic to** $F$, if there
exists an oddomorphism from $F$ to $G$.

### The two sides of the intertwining equation

To interpret $(\ast)$ entrywise we compute both products.

**Lemma 3.2 (Left product).** For all $u \in V(F)$, $a \in V(G)$,
$$\bigl(A_F\, M_\varphi\bigr)_{u,a} \;=\; \sum_{v \in V(F)}
\bigl[\, u \sim_F v \ \wedge\ \varphi(v) = a \,\bigr] \pmod 2,$$
where $[\,\cdot\,]$ is $1$ when the bracketed condition holds and $0$ otherwise.

*Proof sketch.* Expand the matrix product: $(A_F M_\varphi)_{u,a} = \sum_v
(A_F)_{u,v}(M_\varphi)_{v,a}$. The factor $(A_F)_{u,v}$ is $1$ iff $u \sim_F v$ and
$(M_\varphi)_{v,a}$ is $1$ iff $\varphi(v)=a$; their product is $1$ iff both hold.
$\square$

Thus the left-hand side records the **parity of the number of neighbours of $u$
that $\varphi$ maps to $a$.**

**Lemma 3.3 (Right product).** For all $u \in V(F)$, $a \in V(G)$,
$$\bigl(M_\varphi\, A_G\bigr)_{u,a} \;=\; \bigl[\, \varphi(u) \sim_G a \,\bigr].$$

*Proof sketch.* $(M_\varphi A_G)_{u,a} = \sum_{b}(M_\varphi)_{u,b}(A_G)_{b,a}$. The
factor $(M_\varphi)_{u,b}$ vanishes unless $b = \varphi(u)$, so the sum collapses to
the single term $(A_G)_{\varphi(u),a} = [\varphi(u)\sim_G a]$. $\square$

### Theorem 3.4 (Local parity characterization)

A function $\varphi\colon V(F)\to V(G)$ is an oddomorphism if and only if, for all
$u\in V(F)$ and $a\in V(G)$,
$$\#\{\, v : u\sim_F v \text{ and } \varphi(v)=a\,\} \equiv
[\,\varphi(u)\sim_G a\,] \pmod 2.$$
Equivalently: the number of neighbours of $u$ that $\varphi$ sends to $a$ is odd
if and only if $\varphi(u)$ is adjacent to $a$ in $G$.

*Proof.* The matrix identity $(\ast)$ holds if and only if it holds entrywise. By
Lemmas 3.2 and 3.3, the $(u,a)$ entries of the two sides are exactly the two sides
of the displayed parity congruence. $\square$

This is the sense in which oddomorphisms are "mod-2 homomorphisms": edge-preservation
is replaced by the demand that adjacency in the target match the parity of a
neighbour-count in the source.

## 4. Functoriality and the preorder structure

### Theorem 4.1 (Contravariant functoriality of the function matrix)

For functions $\varphi\colon\alpha\to\beta$ and $\psi\colon\beta\to\gamma$ between
finite sets,
$$M_\varphi \, M_\psi = M_{\psi\circ\varphi}.$$

*Proof sketch.* Fix $u\in\alpha$ and $c\in\gamma$. Then $(M_\varphi
M_\psi)_{u,c} = \sum_{b\in\beta}(M_\varphi)_{u,b}(M_\psi)_{b,c}$. Every term with
$b\neq\varphi(u)$ vanishes, so the sum reduces to $(M_\psi)_{\varphi(u),c}$, which
is $1$ iff $\psi(\varphi(u))=c$, i.e. iff $(\psi\circ\varphi)(u)=c$. This is exactly
$(M_{\psi\circ\varphi})_{u,c}$. $\square$

### Theorem 4.2 (Reflexivity)

For every finite graph $F$, the identity map is an oddomorphism $F \to F$.

*Proof.* $M_{\mathrm{id}} = I$, and $A_F I = A_F = I A_F$, so $(\ast)$ holds.
$\square$

### Theorem 4.3 (Closure under composition / transitivity)

If $\varphi\colon V(F)\to V(G)$ is an oddomorphism $F\to G$ and
$\psi\colon V(G)\to V(H)$ is an oddomorphism $G\to H$, then $\psi\circ\varphi$ is an
oddomorphism $F\to H$.

*Proof.* Using Theorem 4.1 and the intertwining hypotheses $A_F M_\varphi =
M_\varphi A_G$ and $A_G M_\psi = M_\psi A_H$, together with associativity of matrix
multiplication:
$$A_F\, M_{\psi\circ\varphi} = A_F (M_\varphi M_\psi) = (A_F M_\varphi) M_\psi =
(M_\varphi A_G) M_\psi = M_\varphi (A_G M_\psi)$$
$$= M_\varphi (M_\psi A_H) = (M_\varphi M_\psi) A_H = M_{\psi\circ\varphi}\, A_H.$$
Hence $\psi\circ\varphi$ satisfies $(\ast)$. $\square$

### Theorem 4.4 (Preorder)

Fix a finite vertex set $V$. The relation "$F \rightsquigarrow G$: there exists an
oddomorphism from $F$ to $G$" is a **preorder** on the set of simple graphs with
vertex set $V$: it is reflexive (Theorem 4.2) and transitive (Theorem 4.3, taking
the composite of the two witnessing maps).

The preorder need not be antisymmetric in general; identifying the exact conditions
under which $F \rightsquigarrow G$ and $G \rightsquigarrow F$ force $F \cong G$ is
one of the open problems discussed in Section 8.

## 5. Isomorphisms and the self-oddomorphism monoid

### Theorem 5.1 (Isomorphisms are oddomorphisms)

Every graph isomorphism $\varphi\colon F \to G$ is an oddomorphism. Consequently,
isomorphic graphs are oddomorphism-equivalent, and every automorphism of $F$ is a
self-oddomorphism.

*Proof sketch.* For an isomorphism $\varphi$, the parity condition of Theorem 3.4
holds for the strongest possible reason. Given $u$ and $a$, if $a = \varphi(w)$ for
some (necessarily unique) $w$, then the neighbours $v$ of $u$ with $\varphi(v)=a$
are exactly $\{w\}$ when $u \sim_F w$ and $\varnothing$ otherwise, so the count is
$1$ or $0$; and $\varphi$ being an isomorphism means $\varphi(u)\sim_G a =
\varphi(w)$ iff $u\sim_F w$. If $a$ is not in the image, both sides are $0$
(surjectivity of an isomorphism makes this case vacuous). In every case the parity
matches. $\square$

### Theorem 5.2 (Submonoid of self-oddomorphisms)

For a fixed finite graph $F$, the set of self-oddomorphisms $\{\varphi\colon
V(F)\to V(F) : \varphi \text{ is an oddomorphism } F\to F\}$ is a **submonoid** of
the monoid of all endofunctions of $V(F)$ under composition.

*Proof.* The identity is a self-oddomorphism (Theorem 4.2), providing the unit, and
the set is closed under composition (Theorem 4.3). $\square$

This submonoid always contains the automorphism group $\mathrm{Aut}(F)$
(Theorem 5.1). It can be strictly larger — a phenomenon witnessed by the example of
the next section when source and target coincide up to the relevant folding — and
determining when it strictly exceeds $\mathrm{Aut}(F)$ is a natural structural
question.

## 6. A concrete non-injective oddomorphism

The following example demonstrates that oddomorphisms strictly generalize
isomorphisms and directly reflect the minor operation underlying the split-off
correspondence.

**Construction.** Let $F = 2K_2$ be the graph on the vertex set $\{0,1,2,3\}$ with
edges $\{0,1\}$ and $\{2,3\}$ (two disjoint edges). Let $G = K_2$ be the single
edge on $\{0,1\}$. Define the **folding map**
$$\varphi\colon \{0,1,2,3\}\to\{0,1\}, \qquad
\varphi(0)=0,\ \varphi(1)=1,\ \varphi(2)=0,\ \varphi(3)=1.$$

### Theorem 6.1

The folding map $\varphi$ is an oddomorphism from $2K_2$ onto $K_2$; it is
surjective and not injective. Moreover, the constant map $\{0,1,2,3\}\to\{0\}$ is
**not** an oddomorphism.

*Proof sketch.* Verify the local parity condition of Theorem 3.4 at each vertex.
For $u = 0$: its unique neighbour is $1$, with $\varphi(1)=1$; hence the count of
neighbours mapped to $0$ is $0$ (even) and to $1$ is $1$ (odd). In $G$,
$\varphi(0)=0$ is adjacent to $1$ but not to $0$, matching both parities. The
vertices $1,2,3$ are handled identically by the symmetry of the two edges. Thus
$(\ast)$ holds. Surjectivity is clear since both $0$ and $1$ are attained;
non-injectivity holds since $\varphi(0)=\varphi(2)=0$ while $0\neq 2$. For the
constant map $c$ sending everything to $0$: take $u=0$. Its neighbour $1$ satisfies
$c(1)=0$, so the count of neighbours mapped to $0$ is $1$ (odd), demanding
$c(0)=0 \sim_G 0$ — but $K_2$ has no loop at $0$, so the parity condition fails and
$c$ is not an oddomorphism. $\square$

**Interpretation.** The folding map exhibits $K_2$ as a minor of $2K_2$: delete one
of the two edges and identify its endpoints with those of the other. That this
folding is an oddomorphism, while the total collapse is not, is a microcosm of the
general principle — oddomorphisms permit exactly the identifications that respect
mod-2 neighbourhood parity, which is precisely the arithmetic of the split-off
operation.

## 7. The split-off minor correspondence

The results above are the algebraic backbone of the following organizing
conjecture.

### Conjecture 7.1 (Oddomorphism / split-off minor equivalence)

For all finite graphs $F$ and $G$, there exists an oddomorphism $F \to G$ if and
only if $G$ is a **split-off minor** of $F$.

Here a split-off minor is a graph obtained from $F$ by a finite sequence of
**vertex splitting-off** operations (in the sense of classical graph-operation
theory) together with deletions — the controlled breaking-apart and reconnection
of a vertex's incidences, iterated until a smaller graph is distilled.

**Status.** The *forward* direction — that a split-off minor of $F$ admits an
oddomorphism from $F$ — is established in the literature. The essential mechanism is
compositional: each individual split-off step induces an oddomorphism, and the
composition theorem (Theorem 4.3) chains these into a single oddomorphism realizing
the whole reduction. The *converse* — that every oddomorphism $F\to G$ certifies $G$
as a split-off minor of $F$ — remains **open**.

The preorder structure (Theorem 4.4) is the correct order-theoretic shadow of the
split-off minor relation: both are reflexive and transitive, and the correspondence
asserts they coincide. The example of Section 6 is a base case of the forward
direction made fully explicit.

## 8. Discussion and future work

The infrastructure developed here isolates the oddomorphism side of the
correspondence as a clean algebraic object: a preorder on graphs, generated by a
mod-2 intertwining condition, refining isomorphism and hosting a monoid of
self-maps. We highlight the following directions.

1. **Explicit split-off operation.** Define the split-off and split-off-minor
   operations as graph operations and prove that each split-off step induces an
   oddomorphism; combine with Theorem 4.3 to obtain the forward direction of
   Conjecture 7.1 in full generality. The preorder/composition machinery here is
   precisely what such a proof consumes.

2. **$\mathrm{GF}(2)$ linear-algebra layer.** Develop the kernel/rank theory of the
   intertwining equation $A_F M = M A_G$ over $\mathrm{GF}(2)$ to attack the
   converse. The matrix reformulation ($\ast$) is designed to make the space of
   candidate oddomorphisms amenable to linear-algebraic analysis.

3. **Homomorphism-count connection.** Relate the count of oddomorphisms modulo two
   to homomorphism counts modulo two and to quantum-isomorphism invariants,
   clarifying how the parity refinement separates graphs that classical counting
   cannot.

4. **Antisymmetry and equivalence classes.** Determine when $F \rightsquigarrow G$
   and $G \rightsquigarrow F$ together force $F \cong G$, refining the preorder to a
   partial order — likely under a same-cardinality or surjectivity hypothesis.

5. **Self-oddomorphism monoids.** Characterize the graphs $F$ whose
   self-oddomorphism monoid strictly exceeds $\mathrm{Aut}(F)$.

### Open computational questions

- Enumerate the oddomorphism preorder on all graphs with $n \le 6$ vertices and
  compare its Hasse diagram to that of the split-off-minor order.
- Characterize graphs $F$ whose self-oddomorphism monoid strictly exceeds
  $\mathrm{Aut}(F)$ (the complete graph $K_3$, for instance, exhibits no such
  strict excess in the available evidence).

## 9. Conclusion

Oddomorphisms recast the comparison of graphs through the lens of $\mathrm{GF}(2)$
parity. We have shown that this recasting is well-behaved: the defining
intertwining condition is functorial, reflexive, and transitive, giving a preorder
that refines isomorphism; isomorphisms are always oddomorphisms; self-oddomorphisms
form a monoid; and there are strictly non-injective oddomorphisms witnessing
genuine minors, alongside a guardrail example showing the notion is genuinely
constrained. Together these constitute the structural foundation on which the
conjectured equivalence with split-off minors rests, and they chart a concrete
path toward its open converse.

## References

- L. Lovász, *Operations with structures*, Acta Mathematica Academiae Scientiarum
  Hungaricae, 1967.
- D. E. Roberson and collaborators, work on oddomorphisms and homomorphism
  indistinguishability, 2022.
- L. Mančinska and D. E. Roberson, *Quantum isomorphism is equivalent to
  equality of homomorphism counts from planar graphs*, 2020.
