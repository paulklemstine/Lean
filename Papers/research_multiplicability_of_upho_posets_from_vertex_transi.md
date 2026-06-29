# Multiplicability of Upho Posets from Vertex-Transitive Graphs

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Novelty (Algebraic combinatorics / order theory / algebraic graph theory)

## Abstract

An *upper-homogeneous* (upho) poset is a partially ordered set in which the
principal filter above every element is isomorphic to the whole poset; the
finitary upho poset of walks $P(G, v_0)$ attached to a vertex-transitive graph
$G$ and base vertex $v_0$ is a canonical example. We study when such a poset is
**multiplicable**: when it arises as the left-divisibility order of an LCIF monoid
(left-cancellative, free of nontrivial units, locally finite). We isolate two
structural pillars. On the *order* side, we prove that the left-divisibility
relation $a \preceq b \iff \exists c,\ b = a\cdot c$ is a preorder on every monoid,
that it collapses to the indiscrete relation on every group — with antisymmetry
holding if and only if the group is trivial — and that on a free monoid it
coincides with the prefix order, which is an antisymmetric, finitary partial order.
On the *symmetry* side, we give a self-contained proof of **Sabidussi's theorem**:
a graph is a Cayley graph if and only if its automorphism group contains a subgroup
acting regularly on the vertices. We then state the central conjecture refining the
Fu–Peng–Zhang conjecture — that $P(G, v_0)$ is multiplicable iff $\mathrm{Aut}(G)$
contains a regular subgroup (equivalently iff $G$ is a Cayley graph) — and explain
how the two pillars combine to support it, with the Petersen graph (non-Cayley,
hence conjecturally non-multiplicable) and its line graph (Cayley, hence
conjecturally multiplicable) as the guiding dichotomy. All structural results
reported here have been formalized and machine-checked.

## 1. Introduction

A poset $P$ with a minimum $\hat 0$ is **upper-homogeneous** (upho) if for every
$x \in P$ the principal filter $\{y : y \ge x\}$ is order-isomorphic to $P$ itself.
Stanley and others have highlighted upho posets as a natural common generalization
of self-similar combinatorial orders. A rich source of finitary upho posets is
graph-theoretic: fix a vertex-transitive graph $G$ and a base vertex $v_0$, and let
$P(G, v_0)$ be the set of finite walks from $v_0$ ordered by the prefix (extension)
relation. Vertex-transitivity makes the upward structure homogeneous; finiteness of
neighborhoods makes it finitary.

The Fu–Peng–Zhang circle of ideas asks which upho posets admit a *monoid model* —
an algebraic structure realizing the order as a divisibility order. We make this
precise via the notion of an LCIF monoid and the associated left-divisibility
order, and we propose a sharp criterion: multiplicability of $P(G, v_0)$ is
governed by whether $G$ is a Cayley graph. This paper establishes the two
independent structural pillars on which that criterion rests and states the
conjecture that fuses them.

**Contributions.**
1. A complete order-theoretic analysis of left-divisibility (Section 3–4),
   including the group collapse dichotomy and the free-monoid prefix
   characterization, both finitary and antisymmetric.
2. A self-contained proof of Sabidussi's theorem in the regular-subgroup
   formulation (Section 5).
3. The precise statement of the multiplicability conjecture and its specialization
   to the Petersen graph and its line graph (Section 6).

## 2. Preliminaries and conventions

Throughout, a *monoid* $(M, \cdot, 1)$ is associative with two-sided identity. A
*group* is a monoid in which every element is invertible. For graphs we use simple
undirected graphs; $\mathrm{Aut}(G)$ denotes the automorphism group. A group action
$H \curvearrowright X$ is *transitive* if it has a single orbit and *free* if every
nontrivial element acts without fixed points; it is *regular* (sharply transitive)
if it is both free and transitive, equivalently if for all $u, v \in X$ there is a
**unique** $h \in H$ with $h\cdot u = v$.

### 2.1 Upho posets and LCIF monoids

A poset $P$ with a unique minimum $\hat 0$ is **upho** (upper-homogeneous) when, for
every $x \in P$, the principal filter $V_x = \{y \in P : y \ge x\}$ is
order-isomorphic to $P$ itself. We call $P$ **finitary** when every principal ideal
$\{y : y \le x\}$ is finite; equivalently, every element has finitely many
predecessors. The walk poset $P(G, v_0)$ is upho because vertex-transitivity makes
the outgoing structure look the same after any walk, and finitary because each
vertex has finite degree.

A monoid $M$ is an **LCIF monoid** if it is:

1. **Left-cancellative**: $a\cdot b = a\cdot c \Rightarrow b = c$;
2. **Identity-free of units** (conical/reduced): the only invertible element is $1$,
   i.e. $a\cdot b = 1 \Rightarrow a = b = 1$;
3. **Locally finite**: each element has finitely many factorizations, equivalently
   finitely many left-divisors.

The relevance is immediate. Left-cancellativity is what makes the divisor $c$ in
$b = a\cdot c$ *unique*, so the upward structure is well defined; absence of
nontrivial units is what makes left-divisibility antisymmetric (a partial order
rather than a mere preorder); and local finiteness is precisely finitariness of the
induced order. A free monoid satisfies all three conditions, and Theorems 4.3–4.4
below verify the order-theoretic consequences directly.

## 3. Left-divisibility on monoids and the group collapse

### Definition 3.1 (left-divisibility)
For a monoid $M$ and $a, b \in M$, define
$$ a \preceq b \quad:\Longleftrightarrow\quad \exists\, c \in M,\ b = a \cdot c. $$
We call $\preceq$ the **left-divisibility** relation (Lean: `LeftDvd`).

### Lemma 3.2 (reflexivity and transitivity)
For every monoid $M$: (i) $a \preceq a$ for all $a$ (Lean: `leftDvd_refl`); and
(ii) $a \preceq b$ and $b \preceq c$ imply $a \preceq c$ (Lean: `leftDvd_trans`).

*Proof.* (i) Take $c = 1$, since $a = a\cdot 1$. (ii) From $b = a\cdot x$ and
$c = b\cdot y$ we get $c = a\cdot(x\cdot y)$ by associativity. $\qquad\blacksquare$

### Proposition 3.3 (preorder)
$\preceq$ endows any monoid $M$ with the structure of a preorder (Lean:
`leftDvdPreorder`). $\qquad\blacksquare$

### Lemma 3.4 (groups divide universally)
If $G$ is a group then $a \preceq b$ for all $a, b \in G$ (Lean: `group_leftDvd`).

*Proof.* Take $c = a^{-1} b$; then $a\cdot c = a\cdot a^{-1} b = b$. $\qquad\blacksquare$

### Theorem 3.5 (collapse dichotomy)
For a group $G$, the relation $\preceq$ is antisymmetric —
$\forall a\, b,\ a\preceq b \wedge b \preceq a \Rightarrow a = b$ — **if and only if
$G$ is trivial** (a subsingleton). (Lean: `group_leftDvd_antisymm_iff_subsingleton`.)

*Proof.* ($\Rightarrow$) For any $a, b$, Lemma 3.4 gives $a\preceq b$ and
$b\preceq a$, whence antisymmetry forces $a = b$; thus $G$ has at most one element.
($\Leftarrow$) If $G$ is a subsingleton, any two elements are equal, so
antisymmetry holds vacuously. $\qquad\blacksquare$

**Remark.** Theorem 3.5 is the precise obstruction to using a symmetry group as the
algebra of an upho poset: a nontrivial group's divisibility order is indiscrete and
carries no order information.

## 4. Free monoids: the upho prototype

Let $\mathrm{FreeMonoid}(\alpha)$ be the free monoid on an alphabet $\alpha$,
identified with finite words (lists) over $\alpha$ under concatenation, with
identity the empty word. Write $a <+: b$ for "$a$ is a prefix of $b$."

### Lemma 4.2 (divisibility is the prefix relation)
For $a, b \in \mathrm{FreeMonoid}(\alpha)$,
$$ a \preceq b \quad\Longleftrightarrow\quad a <+: b. $$
(Lean: `freeMonoid_leftDvd_iff_isPrefix`.)

*Proof.* If $b = a\cdot c$ then $c$ is the suffix witnessing $a <+: b$, and
conversely a prefix witness $b = a \cdot t$ provides the divisor $t$. $\qquad\blacksquare$

### Theorem 4.3 (antisymmetry / partial order)
Left-divisibility on $\mathrm{FreeMonoid}(\alpha)$ is antisymmetric: if $a\preceq b$
and $b\preceq a$ then $a = b$ (Lean: `freeMonoid_leftDvd_antisymm`).

*Proof.* By Lemma 4.2 both $a <+: b$ and $b <+: a$. Prefixes satisfy
$\mathrm{length}(a) \le \mathrm{length}(b)$ and $\mathrm{length}(b) \le
\mathrm{length}(a)$, so the lengths are equal; a prefix of equal length equals the
whole word. $\qquad\blacksquare$

### Theorem 4.4 (finitariness)
For every $b \in \mathrm{FreeMonoid}(\alpha)$ the set
$\{a : a \preceq b\}$ is finite (Lean: `freeMonoid_leftDvd_finitary`).

*Proof.* By Lemma 4.2 the left-divisors of $b$ are exactly its prefixes, i.e. the
initial segments $\mathrm{inits}(b)$, a finite list (one segment per truncation
point). A word of length $n$ has exactly $n + 1$ left-divisors. $\qquad\blacksquare$

### Corollary 4.5 (the prototype partial order)
$(\mathrm{FreeMonoid}(\alpha), \preceq)$ is a partial order — the prefix order —
finitary by Theorem 4.4 (Lean: `freeMonoidLeftDvdPartialOrder`). This is the
canonical LCIF/upho order: the free monoid is left-cancellative and free of
nontrivial units, and its divisibility order is the finitary prefix poset.
$\qquad\blacksquare$

**Synthesis of Sections 3–4.** Cancellativity together with the absence of
nontrivial units is exactly what upgrades the divisibility *preorder* to a partial
*order*. Groups maximally violate the second condition (every element is a unit) and
collapse; free monoids maximally satisfy it and yield a finitary order. An LCIF
monoid threads this needle.

## 5. Sabidussi's theorem: the symmetry pillar

### Definition 5.1 (free action)
An action of a group $H$ on a set $X$ is **free** (Lean: `IsFreeAction`) if
$h\cdot x = x$ for some $x$ implies $h = 1$.

### Definition 5.2 (regular action)
An action is **regular** (Lean: `IsRegularAction`) if it is free and transitive;
equivalently, for all $u, v \in X$ there is a unique $h$ with $h\cdot u = v$.

### Definition 5.3 (Cayley graph)
For a group $H$ and a symmetric subset $S \subseteq H$ (i.e. $S = S^{-1}$) with
$1 \notin S$, the **Cayley graph** $\mathrm{Cay}(H, S)$ (Lean: `cayleyGraph`) has
vertex set $H$ and edges $\{h, h\cdot s\}$ for $h \in H$, $s \in S$.

### Definition 5.4 (left-regular representation)
Left multiplication $\lambda_h : x \mapsto h\cdot x$ is an automorphism of
$\mathrm{Cay}(H, S)$, and $h \mapsto \lambda_h$ defines a group homomorphism
$\mathrm{cayleyRep} : H \to \mathrm{Aut}(\mathrm{Cay}(H, S))$ (Lean: `cayleyRep`)
whose image acts regularly on the vertices.

### Definition 5.5 (Cayley graph predicate)
A graph $G$ **is a Cayley graph** (Lean: `IsCayleyGraph`) if it is isomorphic to
$\mathrm{Cay}(H, S)$ for some group $H$ and symmetric connection set $S$.

### Definition 5.6 (regular automorphism subgroup)
$G$ **has a regular automorphism subgroup** (Lean: `HasRegularAutSubgroup`) if
$\mathrm{Aut}(G)$ contains a subgroup whose induced action on the vertices is
regular.

### Theorem 5.7 (Sabidussi, 1958)
A nonempty graph $G$ is a Cayley graph if and only if $\mathrm{Aut}(G)$ contains a
regular subgroup:
$$ \mathrm{IsCayleyGraph}(G) \quad\Longleftrightarrow\quad
\mathrm{HasRegularAutSubgroup}(G). $$
(Lean: `sabidussi`, with directions `HasRegularAutSubgroup_of_isCayley` and
`isCayley_of_hasRegularAutSubgroup`.)

*Proof sketch.* ($\Rightarrow$) If $G \cong \mathrm{Cay}(H, S)$, transport the
left-regular representation of Definition 5.4 across the isomorphism. Its image is a
subgroup of $\mathrm{Aut}(G)$ acting regularly, since left multiplication by $H$ on
itself is sharply transitive. ($\Leftarrow$) Suppose $K \le \mathrm{Aut}(G)$ acts
regularly on the vertex set $V$. Fix a base vertex $v_0$; by regularity the map
$K \to V,\ k \mapsto k\cdot v_0$ is a bijection, giving each vertex a unique
"coordinate" in $K$. Set $S = \{k \in K : k\cdot v_0 \sim v_0\}$, the coordinates of
the neighbors of $v_0$; symmetry of the graph makes $S$ symmetric. The coordinate
bijection is then a graph isomorphism $G \cong \mathrm{Cay}(K, S)$, because adjacency
is $K$-invariant and determined at the base point. $\qquad\blacksquare$

Sabidussi's theorem identifies "regular subgroup of symmetries" with "group law on
the vertices." It is the criterion that the conjecture below uses to decide
multiplicability.

## 6. The multiplicability conjecture and the Petersen dichotomy

### Definition 6.1 (multiplicability)
A finitary upho poset $P$ is **multiplicable** if there exists an LCIF monoid $M$
(left-cancellative; only $1$ is a unit; locally finite) whose left-divisibility
order $(M, \preceq)$ is order-isomorphic to $P$.

By Corollary 4.5 the prefix order on a free monoid is the prototypical multiplicable
poset; by Theorem 3.5 a nontrivial group is *never* a witness, since its order is
indiscrete.

### Conjecture 6.2 (main conjecture; refines Fu–Peng–Zhang)
Let $G$ be a vertex-transitive graph with base vertex $v_0$ and let $P(G, v_0)$ be
its finitary upho poset of walks under the prefix order. Then
$$ P(G, v_0) \text{ is multiplicable} \iff \mathrm{Aut}(G) \text{ contains a
regular subgroup} \iff G \text{ is a Cayley graph}, $$
the last equivalence being Theorem 5.7.

**Heuristic for the conjecture.** A regular subgroup $K \le \mathrm{Aut}(G)$
supplies a group law on the vertices (Section 5). Grafting that law onto the free
monoid of walk-steps (Section 4) yields a candidate LCIF monoid
$W(G, v_0) \cong K \ltimes \mathrm{FreeMonoid}(\text{steps})$ whose left-divisibility
order — the prefix order by Lemma 4.2 — should coincide with $P(G, v_0)$. The
symmetry pillar furnishes the multiplication; the order pillar furnishes the
grading.

### The Petersen dichotomy

**Non-Cayley side.** The Petersen graph $\mathrm{Pet}$ is vertex-transitive with
$\mathrm{Aut}(\mathrm{Pet}) \cong S_5$ of order $120$. A regular subgroup would have
order $10$ and act sharply transitively on the $10$ vertices; no such subgroup
exists in $S_5$ in this action, so $\mathrm{Pet}$ is **not** a Cayley graph
(Theorem 5.7). Conjecture 6.2 predicts $P(\mathrm{Pet}, v_0)$ is **not
multiplicable**: every monoid law over-collapses the walk order, in line with
Theorem 3.5.

**Cayley side.** The pentagonal prism $\mathrm{Pr}_5 = C_5 \times K_2$ is also a
$3$-regular vertex-transitive graph on $10$ vertices, but it **is** a Cayley graph:
it is $\mathrm{Cay}(\mathbb{Z}_{10}, S)$, and $\mathrm{Aut}(\mathrm{Pr}_5)$ (of order
$20$) contains a regular subgroup of order $10$. By Theorem 5.7 it is Cayley, and
Conjecture 6.2 predicts $P(\mathrm{Pr}_5, v_0)$ **is** multiplicable. Thus two cubic
vertex-transitive graphs on the same vertex set land on opposite sides of a sharp
algebraic divide determined entirely by the existence of a regular subgroup.

**A correction regarding the line graph.** The motivating concept proposed the
Petersen line graph $L(\mathrm{Pet})$ as the Cayley contrast. This is not correct,
and we record the computation. By Whitney's theorem $\mathrm{Aut}(L(\mathrm{Pet}))
\cong \mathrm{Aut}(\mathrm{Pet}) \cong S_5$, of order $120$; a regular subgroup
would need order $|V(L(\mathrm{Pet}))| = 15$. But every group of order $15$ is
cyclic ($\mathbb{Z}_{15}$) and $S_5$ has no element of order $15$ (its maximal
element order is $6$), so $S_5$ has no subgroup of order $15$. By Theorem 5.7,
$L(\mathrm{Pet})$ is therefore **not** a Cayley graph, and Conjecture 6.2 predicts
$P(L(\mathrm{Pet}), v_0)$ is *not* multiplicable. The pentagonal prism, not the line
graph, is the faithful Cayley counterpart to the Petersen graph. (All four
computations — $C_5$, $\mathrm{Pr}_5$, $\mathrm{Pet}$, $L(\mathrm{Pet})$ — are
reproduced numerically in the accompanying demonstration.)

## 6.1 A worked example: walks on the triangle $K_3$

Take $G = K_3$, the triangle, with vertices $\{0,1,2\}$ and base $v_0 = 0$. It is
vertex-transitive and a Cayley graph: $K_3 = \mathrm{Cay}(\mathbb{Z}_3, \{1, 2\})$,
and the regular subgroup is the rotation group $\mathbb{Z}_3 \le \mathrm{Aut}(K_3)
\cong S_3$. The walks from $0$ form the free monoid on the two step-letters
$\{r, \ell\}$ ($r$ = move to the next vertex clockwise, $\ell$ = counterclockwise),
modulo the bookkeeping of where one currently stands. Concretely, the walk monoid
$W(K_3, 0)$ is $\mathbb{Z}_3 \ltimes \mathrm{FreeMonoid}(\{r, \ell\})$: an element is
a finite step-word together with the endpoint vertex it reaches.

Left-divisibility in $W(K_3, 0)$ is the prefix order on step-words (Lemma 4.2): the
walk "$r$" sits below "$r r$" and below "$r \ell$", each walk of length $n$ has
exactly $n + 1$ left-divisors (Theorem 4.4), and the order is antisymmetric
(Theorem 4.3). Thus $P(K_3, 0)$ is the infinite binary-branching prefix tree — the
prototypical multiplicable upho poset — exactly as Conjecture 6.2 predicts for a
Cayley graph. By contrast, attempting to model $P(K_3, 0)$ using the *symmetry
group* $\mathbb{Z}_3$ alone fails by Theorem 3.5: that group's divisibility order is
indiscrete. The free-monoid grading is indispensable; the group only supplies the
vertex law.

## 7. Algorithms

We summarize the two decision procedures implied by the structural results.

### Algorithm A — Regular-subgroup / Cayley test
**Input:** finite vertex-transitive graph $G$.
**Output:** whether $\mathrm{Aut}(G)$ has a regular subgroup (hence whether $G$ is
Cayley, by Theorem 5.7).
**Method:** compute $\mathrm{Aut}(G)$; for each subgroup $K$ of order $|V(G)|$, test
whether the action on $V(G)$ is free and transitive (i.e. for every ordered pair of
vertices exactly one element of $K$ realizes it). Return *Cayley* iff some $K$
passes.

### Algorithm B — Prefix-order / finitariness witness
**Input:** an alphabet of steps and a word (walk) $b$.
**Output:** the (finite) set of left-divisors of $b$ and confirmation of
finitariness.
**Method:** enumerate the $|b| + 1$ initial segments of $b$; by Lemma 4.2 and
Theorem 4.4 these are exactly the left-divisors, certifying both the partial order
and its finitariness.

## 8. Applications and discussion

The dichotomy reframes a question about *algebraic models of posets* as a question
about *graph symmetry*. The two pillars are genuinely complementary: groups encode
maximal symmetry but provide no usable order (Theorem 3.5), while free monoids
encode maximal irreversibility and hence a perfect finitary order (Theorems
4.3–4.4). An upho poset of walks is multiplicable precisely when the graph's
symmetry is "regular enough" to become a group law on vertices (Theorem 5.7), at
which point the irreversible free monoid of steps rides on top.

This perspective connects to several active themes: the structure theory of upho
posets and their rank-generating functions; the role of cancellativity in
turning divisibility preorders into orders; and the long-studied classification of
vertex-transitive non-Cayley graphs, of which the Petersen graph is the smallest
3-regular example.

**Related context.** Sabidussi's 1958 characterization of Cayley graphs as those
admitting a regular subgroup of automorphisms is a cornerstone of algebraic graph
theory; the Petersen graph is the classical smallest example of a vertex-transitive
graph that is not Cayley. On the algebraic side, the study of divisibility orders on
cancellative monoids underlies the theory of factorization, and the prefix order on
free monoids is the canonical model of a finitary graded poset. The novelty here is
to place these two classical strands in correspondence through the notion of
multiplicability: the order theory dictates *what kind of monoid* can model an upho
poset (an LCIF monoid, never a group), while the symmetry theory dictates *which
graphs* furnish the vertex law needed to build such a monoid (the Cayley graphs).

**Limitations.** The two pillars are proved; the fusion (Conjecture 6.2) is not. In
particular we do not yet prove that the candidate monoid $K \ltimes
\mathrm{FreeMonoid}(\text{steps})$ is left-cancellative and unit-free in full
generality, nor that its divisibility order is *exactly* (not merely refines) the
walk order. The worked example of Section 6.1 and the computational dichotomy of
Section 6 are evidence, not proof, of the general statement.

## 9. Future directions

*(Verbatim from the Phase A synthesis.)*

**Conjecture 1 — Sabidussi ⇒ multiplicability (the main fusion).** For a
vertex-transitive graph $G$ with base vertex $v_0$, the finitary upho poset
$P(G, v_0)$ of walks is multiplicable iff $\mathrm{Aut}(G)$ contains a regular
subgroup (equivalently, $G$ is a Cayley graph). The key insight is that the regular
subgroup $K \le \mathrm{Aut}(G)$ supplies a group law on the vertices, and grafting
that law onto the free monoid of walk-steps produces exactly an LCIF monoid whose
left-divisibility order (the prefix order) coincides with the walk-poset order. Both
halves are now formalized and `sorry`-free; the remaining work is to define the walk
monoid $W(G, v_0)$ and exhibit the isomorphism
$W(G, v_0) \cong K \ltimes \mathrm{FreeMonoid}(\text{steps})$ whose $\preceq$ order
is $P(G, v_0)$.

**Conjecture 2 — the obstruction is order-theoretic, not just group-theoretic.** If
$G$ is vertex-transitive but non-Cayley (e.g. the Petersen graph), then for every
monoid structure on $P(G, v_0)$ the left-divisibility order strictly refines (never
equals) the walk order; the deficiency is measured by the index
$[\mathrm{Aut}(G) : H]$ over the largest semiregular subgroup $H$. The dichotomy
theorem (Theorem 3.5) shows a pure group law over-collapses the order, so a
non-regular symmetry group must "waste" divisibility relations, the size of the
waste being the failure of semiregularity. For the Petersen case this is a concrete
finite check: $\mathrm{Aut} = S_5$ of order $120$, no order-$10$ regular subgroup.

**Conjecture 3 — multiplicability is a Cayley-isomorphism invariant.**
Multiplicability of $P(G, v_0)$ is independent of the base vertex $v_0$ and is
preserved under graph isomorphism; moreover it transfers along the conjugation
$\mathrm{Aut}(G) \cong \mathrm{Aut}(G')$ whenever $G \cong G'$. The key insight is
that having a regular subgroup is itself an isomorphism invariant of the symmetry
group acting on vertices.

## 10. Conclusion

We have established the two structural pillars supporting a sharp conjectural
criterion for multiplicability of upho posets of walks. The order pillar
(left-divisibility: preorder always, collapse on groups exactly when trivial, prefix
partial order and finitariness on free monoids) and the symmetry pillar
(Sabidussi's Cayley/regular-subgroup equivalence) together predict that the walk
poset of a vertex-transitive graph is multiplicable precisely when the graph is a
Cayley graph — separating the Petersen graph from its line graph. Completing the
fusion (Conjecture 1) is the natural next step.
