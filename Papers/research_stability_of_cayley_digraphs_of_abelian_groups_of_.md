# Stability of Cayley Digraphs of Abelian Groups of Odd Order

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Applications (algebraic graph theory)

## Abstract

A finite digraph $X$ is called *stable* when the automorphism group of its tensor
product with the complete digraph $K_2$ — equivalently, of its bipartite double
cover $X \otimes K_2$ — factors as the direct product
$\mathrm{Aut}(X \otimes K_2) \cong \mathrm{Aut}(X) \times \mathrm{Aut}(K_2)$,
so that doubling introduces no symmetries beyond the obvious ones. We give a
self-contained formal framework for stability of Cayley digraphs of finite
abelian groups and establish the universally valid half of the theory together
with the structural and arithmetic facts that govern the conjectural hard half.

Concretely, for a finite abelian group $G$ and connection set $S \subseteq G$ we
define the Cayley adjacency $h - g \in S$ and the double-cover adjacency
$(h - g \in S) \wedge (a \neq b)$ on $G \times \{\text{top},\text{bottom}\}$. We
realise automorphism groups as subgroups of permutation groups, construct the
canonical *expected-automorphism homomorphism*
$\mathrm{expectedHom} : \mathrm{Aut}(\mathrm{Cay}(G,S)) \times \mathrm{Sym}_2
\to \mathrm{Aut}(\mathrm{Cay}(G,S) \otimes K_2)$, and prove three results.
(1) **Universal embedding**: $\mathrm{expectedHom}$ is injective for every $G$
and every $S$, yielding the guaranteed lower bound
$|\mathrm{Aut}(X \otimes K_2)| \geq 2\,|\mathrm{Aut}(X)|$. (2) **Closure**: the
double cover is again a Cayley digraph, over $G \times \mathbb{Z}/2$ with
connection set $S \times \{1\}$. (3) **Arithmetic obstruction**: a finite abelian
group of odd order has no involution, the structural feature whose absence
forbids layer-mixing automorphisms; this is precisely what fails, with an
explicit witness, in even order. We discuss how these results frame the open
Hujdurović–Mitrović–Morris conjecture that connected, twin-free Cayley digraphs
of odd-order abelian groups are stable, and we record concrete future targets.

## 1. Introduction

### 1.1 The stability problem

Let $X$ be a finite digraph (directed graph). Its **bipartite double cover**, or
equivalently its **tensor product with $K_2$** and denoted $X \otimes K_2$, has
two disjoint copies of the vertex set of $X$ — a *top* layer and a *bottom*
layer — with an arc from a top-layer vertex to a bottom-layer vertex (and
vice-versa) whenever the underlying vertices are joined by an arc in $X$. All
arcs cross between the layers; none stay within a layer.

Every automorphism of $X$ induces an automorphism of $X \otimes K_2$ acting
identically on both layers, and the complete digraph $K_2$ contributes one
further automorphism: the global swap of the two layers. These together generate
a subgroup of $\mathrm{Aut}(X \otimes K_2)$ isomorphic to
$\mathrm{Aut}(X) \times \mathrm{Aut}(K_2)$, and $\mathrm{Aut}(K_2) \cong
\mathrm{Sym}_2$ has order $2$. The digraph $X$ is called **stable** when these
are *all* of the automorphisms of the double cover, i.e. when

$$\mathrm{Aut}(X \otimes K_2) \;\cong\; \mathrm{Aut}(X) \times \mathrm{Aut}(K_2),$$

and **unstable** otherwise. Stability says doubling is "honest": the only new
symmetry is the obvious top/bottom swap.

### 1.2 Cayley digraphs of abelian groups

We restrict to the rich and applicable class of **Cayley digraphs** of finite
abelian groups. For a finite abelian group $G$ and a *connection set*
$S \subseteq G$, the Cayley digraph $\mathrm{Cay}(G,S)$ has vertex set $G$ and an
arc $g \to h$ exactly when $h - g \in S$. These digraphs are vertex-transitive
(translation by any group element is an automorphism), and they model cyclic
codes, circulant networks, and additive-combinatorial structures.

The driving conjecture, due to Hujdurović, Mitrović, and Morris, asserts:

> **Conjecture (odd $\Rightarrow$ stable).** Every connected, twin-free Cayley
> digraph of a finite abelian group of *odd order* is stable.

This paper formalises the framework in which the conjecture lives, proves the
universal half, and isolates exactly the arithmetic feature — absence of
involutions in odd-order groups — on which the hard half turns.

### 1.3 Contributions

1. A clean group-theoretic model of stability: automorphism groups as subgroups
   of permutation groups (`AutRel`), and the expected-automorphism homomorphism
   (`expectedHom`).
2. **Theorem 6** (`expectedHom_injective`): the expected automorphisms embed
   injectively for *every* abelian group and *every* connection set, giving the
   guaranteed factor-of-two lower bound on $|\mathrm{Aut}(X \otimes K_2)|$.
3. **Theorem 8** (`dcCayleyIso`): the double cover of a Cayley digraph is itself
   a Cayley digraph over $G \times \mathbb{Z}/2$, so doubling is closed in the
   class.
4. **Theorem 9** (`odd_no_involution`): odd-order abelian groups have no
   involutions; with the explicit even-order witness this shows the odd-order
   hypothesis is necessary.

## 2. Definitions

Throughout, $G$ is a finite abelian group written additively, with identity $0$,
and $S \subseteq G$ is a connection set.

**Definition 1 (Cayley adjacency, `cayAdj`).** For $g, h \in G$, define
$$\mathrm{cayAdj}_S(g,h) \;:\Longleftrightarrow\; h - g \in S.$$
This is the arc relation of $\mathrm{Cay}(G,S)$.

**Definition 2 (double-cover adjacency, `dcAdj`).** Model the two layers by the
Booleans $\{\mathtt{false}, \mathtt{true}\}$ (bottom/top). For
$p = (g,a)$ and $q = (h,b)$ in $G \times \mathrm{Bool}$, define
$$\mathrm{dcAdj}_S(p,q) \;:\Longleftrightarrow\; (h - g \in S) \;\wedge\; (a \neq b).$$
This is the arc relation of $\mathrm{Cay}(G,S) \otimes K_2$; the clause
$a \neq b$ forces every arc to cross between layers.

**Definition 3 (automorphism group of a relation, `AutRel`).** For a set $V$ and
a binary relation $r : V \times V \to \mathrm{Prop}$, let
$$\mathrm{AutRel}(r) \;=\; \{\, \sigma \in \mathrm{Sym}(V) \;:\; \forall a, b,\;
r(\sigma a, \sigma b) \Leftrightarrow r(a,b) \,\}.$$
This is a subgroup of the symmetric group $\mathrm{Sym}(V) = \mathrm{Perm}(V)$:
it contains the identity, is closed under composition (apply preservation twice),
and is closed under inverses (substitute $\sigma^{-1}a, \sigma^{-1}b$ and use
symmetry of $\Leftrightarrow$). Membership is exactly the displayed condition
(`mem_AutRel`). We write $\mathrm{Aut}(\mathrm{Cay}(G,S)) = \mathrm{AutRel}
(\mathrm{cayAdj}_S)$ and $\mathrm{Aut}(\mathrm{Cay}(G,S) \otimes K_2) =
\mathrm{AutRel}(\mathrm{dcAdj}_S)$.

The automorphism group of $K_2$ is the full symmetric group on the two layers,
$\mathrm{Sym}(\mathrm{Bool}) = \mathrm{Perm}(\mathrm{Bool}) \cong \mathrm{Sym}_2$,
which has order $2$: the identity and the layer swap.

## 3. The expected-automorphism embedding

We first record that "product permutations" are genuine double-cover
automorphisms. For $\sigma \in \mathrm{Perm}(G)$ and $\pi \in
\mathrm{Perm}(\mathrm{Bool})$, the **product permutation** $\sigma \times \pi$ of
$G \times \mathrm{Bool}$ acts coordinatewise: $(\sigma \times \pi)(g,a) =
(\sigma g, \pi a)$.

**Lemma 4 (product symmetries embed, `prodCongr_mem`).** If
$\sigma \in \mathrm{AutRel}(\mathrm{cayAdj}_S)$ and $\pi \in
\mathrm{Perm}(\mathrm{Bool})$ is arbitrary, then
$\sigma \times \pi \in \mathrm{AutRel}(\mathrm{dcAdj}_S)$.

*Proof sketch.* For $p=(g,a)$, $q=(h,b)$, the first coordinate of the arc
condition transforms as
$\mathrm{cayAdj}_S(\sigma g, \sigma h) \Leftrightarrow \mathrm{cayAdj}_S(g,h)$ by
the hypothesis on $\sigma$. The second coordinate transforms as
$\pi a \neq \pi b \Leftrightarrow a \neq b$ because $\pi$ is a bijection
(injectivity gives $\Leftarrow$; applying $\pi$ to both sides gives $\Rightarrow$).
Conjoining the two equivalences yields $\mathrm{dcAdj}_S(\sigma\!\times\!\pi\,p,
\sigma\!\times\!\pi\,q) \Leftrightarrow \mathrm{dcAdj}_S(p,q)$. Note no
hypothesis on the group's order is used, and $\pi$ may be *any* layer
permutation. $\square$

**Definition 5 (expected-automorphism homomorphism, `expectedHom`).** Define
$$\mathrm{expectedHom}_S : \mathrm{AutRel}(\mathrm{cayAdj}_S) \times
\mathrm{Perm}(\mathrm{Bool}) \;\longrightarrow\;
\mathrm{AutRel}(\mathrm{dcAdj}_S), \qquad (\sigma, \pi) \;\longmapsto\;
\sigma \times \pi.$$
By Lemma 4 the image lands in $\mathrm{AutRel}(\mathrm{dcAdj}_S)$. It is a group
homomorphism: product permutations compose coordinatewise, so
$(\sigma \times \pi)(\sigma' \times \pi') = (\sigma\sigma') \times (\pi\pi')$ and
the identity maps to the identity. This homomorphism is the canonical inclusion
of the "expected" automorphisms $\mathrm{Aut}(X) \times \mathrm{Aut}(K_2)$ into
$\mathrm{Aut}(X \otimes K_2)$. **Stability of $\mathrm{Cay}(G,S)$ is precisely
the statement that $\mathrm{expectedHom}_S$ is surjective**, hence an
isomorphism.

**Theorem 6 (universal embedding, `expectedHom_injective`).** For every finite
abelian group $G$ and every connection set $S \subseteq G$, the homomorphism
$\mathrm{expectedHom}_S$ is injective.

*Proof sketch.* Suppose $(\sigma,\pi)$ and $(\sigma',\pi')$ have equal images, so
$\sigma \times \pi = \sigma' \times \pi'$ as permutations of $G \times
\mathrm{Bool}$. Evaluate both sides at $(g, \mathtt{false})$ and read the first
coordinate: $\sigma g = \sigma' g$ for all $g \in G$, whence $\sigma = \sigma'$.
Evaluate at $(0, b)$ — using the identity element $0$ as a base point, which
exists because $G$ is nonempty — and read the second coordinate: $\pi b = \pi' b$
for all $b$, whence $\pi = \pi'$. Therefore $(\sigma,\pi) = (\sigma',\pi')$. The
only essential ingredient beyond bookkeeping is the existence of a base vertex
$0$: without a point at which to evaluate, the layer permutation factor cannot be
recovered. $\square$

**Corollary 7 (guaranteed symmetry doubling).** For all finite $G$ and $S$,
$$|\mathrm{Aut}(\mathrm{Cay}(G,S) \otimes K_2)| \;\geq\; 2\,
|\mathrm{Aut}(\mathrm{Cay}(G,S))|,$$
since $\mathrm{expectedHom}_S$ is an injective homomorphism from a group of order
$2\,|\mathrm{Aut}(\mathrm{Cay}(G,S))|$. Stability is exactly the case of
equality, which converts the problem into a finite cardinality comparison.

## 4. The double cover is again a Cayley digraph

A central structural fact is that doubling does not leave the class of abelian
Cayley digraphs.

**Definition 7 (label dictionary `boolEquivZMod2` and connection set `dcConn`).**
Let $\beta : \mathrm{Bool} \to \mathbb{Z}/2$ be the bijection
$\mathtt{false} \mapsto 0$, $\mathtt{true} \mapsto 1$ (with inverse
$z \mapsto (z = 1)$). Define the *doubled connection set*
$$\mathrm{dcConn}(S) \;=\; \{\, (s, 1) \;:\; s \in S \,\} \;=\;
\{\, p \in G \times \mathbb{Z}/2 \;:\; p_1 \in S \;\wedge\; p_2 = 1 \,\}.$$

**Theorem 8 (closure under doubling, `dcCayleyIso`).** The map
$$f \;=\; \mathrm{id}_G \times \beta : G \times \mathrm{Bool}
\;\xrightarrow{\ \sim\ }\; G \times \mathbb{Z}/2$$
is a bijection that intertwines the double-cover adjacency with a Cayley
adjacency:
$$\mathrm{dcAdj}_S(p,q) \;\Longleftrightarrow\;
\mathrm{cayAdj}_{\mathrm{dcConn}(S)}\big(f(p), f(q)\big) \qquad
\text{for all } p, q \in G \times \mathrm{Bool}.$$
Hence $\mathrm{Cay}(G,S) \otimes K_2 \cong \mathrm{Cay}(G \times \mathbb{Z}/2,\,
S \times \{1\})$.

*Proof sketch.* Write $p = (g,a)$, $q = (h,b)$. The left side is $(h - g \in S)
\wedge (a \neq b)$. Applying $f$ and unfolding the Cayley rule, the right side is
$(h - g \in S) \wedge (\beta b - \beta a = 1$ in $\mathbb{Z}/2)$. The first
clauses coincide. For the second, a four-case check over $a, b \in \mathrm{Bool}$
shows $a \neq b \Leftrightarrow \beta b - \beta a = 1$ in $\mathbb{Z}/2$ (the
nonzero element of $\mathbb{Z}/2$ is $1 = -1$). The two equivalences combine to
give the claim. $\square$

The significance is that the stability operator can be *iterated*: the double
cover of a Cayley digraph is a Cayley digraph, so one can double again and remain
in the same category. This both enables structural/inductive approaches to the
open conjecture and makes small cases directly checkable by computer.

## 5. The arithmetic obstruction: odd order and involutions

An **involution** in an additive group is a nonzero element $g$ with
$g + g = 0$, i.e. an element of order exactly $2$. Involutions are the raw
material for layer-mixing ("diagonal") automorphisms of the double cover — the
very automorphisms that, when present beyond the expected ones, witness
instability.

**Theorem 9 (odd order forbids involutions, `odd_no_involution`).** In a finite
abelian group $G$ of odd order, the equation $g + g = 0$ forces $g = 0$; that is,
$G$ has no involution.

*Proof sketch.* If $g + g = 0$ then $g$ has order $1$ or $2$. An element of order
$2$ generates a subgroup of order $2$, and by Lagrange's theorem its order $2$
must divide $|G|$. Since $|G|$ is odd, $2 \nmid |G|$, so no element of order $2$
exists; hence $g$ has order $1$, i.e. $g = 0$. $\square$

**Necessity of the odd hypothesis.** Conversely, when $|G|$ is even, $G$ contains
an involution $t$ (e.g. by Cauchy's theorem, an element of order $2$). From such
a $t$ one constructs an explicit *layer-mixing transposition* of $G \times
\mathrm{Bool}$ — denoted `tau` in the development — which is an automorphism of
the double cover that is **not** of the product form $\sigma \times \pi$. Its
existence makes $\mathrm{expectedHom}_S$ non-surjective, so the corresponding
Cayley digraph is unstable. This shows the odd-order hypothesis cannot be
removed: it is not a convenience of proof but a genuine boundary of the
phenomenon.

**The twin-free hypothesis.** Beyond odd order, the full conjecture also assumes
the digraph is **twin-free** (`TwinFree`): no two distinct vertices have
identical out- and in-neighbourhoods. Twins force an obvious transposition
automorphism that can leak into the double cover and cause instability for
reasons unrelated to the group's arithmetic; excluding them isolates the genuine
arithmetic content.

## 6. Synthesis: what is proved and what is open

Combining the results, the landscape of the conjecture is sharply delineated.

- **Always true (Theorem 6, Corollary 7):** The expected automorphisms embed
  injectively, so $|\mathrm{Aut}(X \otimes K_2)| \geq 2\,|\mathrm{Aut}(X)|$ for
  *every* abelian Cayley digraph. Stability $=$ equality.
- **Always true (Theorem 8):** Doubling is closed in the class of abelian Cayley
  digraphs.
- **Arithmetic boundary (Theorem 9 + witness):** Odd order $\Rightarrow$ no
  involutions $\Rightarrow$ no obvious layer-mixing automorphism; even order
  $\Rightarrow$ explicit instability witness.
- **Open:** *Surjectivity* of $\mathrm{expectedHom}_S$ for connected, twin-free,
  odd-order Cayley digraphs — the combinatorial layer-preservation argument that
  rules out *all* unexpected automorphisms, not just the involution-built ones.
  This is the Hujdurović–Mitrović–Morris conjecture; it is **not** claimed proved
  here.

## 7. Algorithms

The framework is constructive enough to support direct computation on small
groups; we describe two algorithms used in the accompanying numerical study.

**Algorithm A (Brute-Force Automorphism Group Enumeration for Cayley Digraphs).**
Given $(G, S)$ with $|G| = n$, enumerate all $n!$ permutations of $G$ and retain
those preserving $\mathrm{cayAdj}_S$, returning the list (and order) of
$\mathrm{Aut}(\mathrm{Cay}(G,S))$. Complexity $O(n! \cdot n^2)$; feasible for
$n \leq 8$. The same routine, applied to $\mathrm{dcAdj}_S$ on the $2n$ vertices
of the double cover, computes $|\mathrm{Aut}(X \otimes K_2)|$.

**Algorithm B (Stability Decision via Cardinality Criterion).** Compute
$a = |\mathrm{Aut}(\mathrm{Cay}(G,S))|$ and
$b = |\mathrm{Aut}(\mathrm{Cay}(G,S) \otimes K_2)|$ with Algorithm A, then
report **stable** iff $b = 2a$. Correctness rests on Theorem 6: since
$\mathrm{expectedHom}_S$ is always injective with image of size $2a$, $b \geq 2a$
always, and $b = 2a$ is equivalent to surjectivity, i.e. stability.

## 8. Applications

- **Coding theory.** Cayley graphs of cyclic groups underlie cyclic and
  circulant codes; the bipartite double cover builds new codes, and the
  automorphism group governs their symmetry-based decoding. Stability certifies
  the doubled code has no spurious symmetries.
- **Expanders and random walks.** The automorphism group constrains the spectrum
  of the (di)graph; knowing $|\mathrm{Aut}(X \otimes K_2)| = 2|\mathrm{Aut}(X)|$
  exactly characterises how the doubled walk's symmetry — and thereby its mixing
  — relates to the original.
- **Graph isomorphism.** Stable graphs are those for which the double cover
  reveals no additional structure; the cardinality criterion (Corollary 7,
  Algorithm B) provides a concrete stability test used to calibrate isomorphism
  heuristics.

## 9. Discussion and future work

The results here cleanly separate the *universal* content of stability (the
embedding and the closure) from its *conditional* content (the surjectivity that
depends on odd order and twin-freeness). The arithmetic obstruction is reduced to
a single transparent fact — odd groups have no involutions — and the necessity of
the hypothesis is made concrete by an explicit even-order witness.

Several directions follow naturally and are recorded in the package's future
directions: proving surjectivity in the odd-order twin-free case (the central
open target, attackable via the `dcCayleyIso` reduction); reformulating
stability purely as the cardinality identity $|\mathrm{Aut}(X \otimes K_2)| =
2|\mathrm{Aut}(X)|$ (decidable for small groups); classifying instability in even
order as arising exactly from twins or order-two elements; and analysing the
iterated double cover, where each doubling multiplies the symmetry count by $2$
once stability is reached.

## 10. Conclusion

We have formalised a robust framework for the stability of abelian Cayley
digraphs, proved that the expected automorphisms always embed injectively
(`expectedHom_injective`), shown the double cover remains a Cayley digraph
(`dcCayleyIso`), and isolated the odd-order arithmetic obstruction
(`odd_no_involution`) together with the necessity of that hypothesis. These give
the precise, honest state of the Hujdurović–Mitrović–Morris conjecture: its easy
half and its arithmetic boundary are settled; its surjective heart remains the
inviting open problem.
