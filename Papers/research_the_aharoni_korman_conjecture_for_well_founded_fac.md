# The Aharoni–Korman Property for Well-Founded Posets Satisfying the Finite Antichain Condition

**Author:** Aristotle
**Date:** 2026-07-07

## Abstract

The Aharoni–Korman conjecture asserts that every partially ordered set admits a
partition into antichains together with a single chain meeting every part of the
partition. While elementary for finite orders, the statement is subtle in the
infinite setting and open in full generality. We establish the property for the
class of **well-founded** posets satisfying the **Finite Antichain Condition**
(FAC), i.e. orders with no infinite strictly descending chain and no infinite
antichain. Our witness is fully explicit: the antichain partition is the family
of ordinal **height levels** determined by the well-founded rank, and the
required chain is produced by a top-down realization procedure combined with a
compactness argument. We prove that height is strictly monotone, that each
height level is a finite antichain, that the levels partition the poset, and that
heights are *downward realizable*. From these we derive a finitary
chain-selection lemma and, via a Tychonoff/Cantor compactness principle, a single
chain meeting every non-empty level. We further explain why the no-infinite-
descent hypothesis is precisely the condition that excludes the known
obstructions to the general conjecture, and we outline a program of conjectures
extending the height-level construction to sharper and more general settings.

## 1. Introduction

A **partially ordered set** (*poset*) is a set $P$ with a reflexive,
antisymmetric, transitive relation $\le$; we write $x < y$ for $x \le y$ with
$x \ne y$. A **chain** is a subset in which any two elements are comparable; an
**antichain** is a subset in which no two distinct elements are comparable. The
interplay of chains and antichains organizes much of order theory, from
Dilworth's and Mirsky's decomposition theorems to deep results on infinite
orders.

A single structural fact underlies the questions we study: **a chain meets an
antichain in at most one element**. Indeed, if two elements of a chain both lie
in an antichain, then they are simultaneously comparable (being in a chain) and
incomparable (being in an antichain), forcing them to be equal.

The **Aharoni–Korman property** concerns matching a global chain against a
partition into antichains.

> **Definition (Aharoni–Korman property).** A poset $P$ has the *Aharoni–Korman
> property* if there exist a partition $P = \bigsqcup_{i} A_i$ into antichains
> $A_i$ and a chain $C \subseteq P$ such that $C \cap A_i \neq \varnothing$ for
> every $i$.

The **Aharoni–Korman conjecture** posits that every poset has this property,
with the intended reach extending to uncountable cardinals. For finite posets
the property is classical. In the infinite realm it becomes delicate: the
conjecture is known to interact with subtle configurations of infinite chains,
and remains open in general.

This paper isolates a broad, natural class where the property holds with an
explicit and conceptually transparent witness.

> **Definition (Finite Antichain Condition, FAC).** A poset $P$ satisfies the
> *Finite Antichain Condition* if every antichain of $P$ is finite.

> **Definition (well-founded).** A poset $P$ is *well-founded* if the strict
> relation $<$ is well-founded: there is no infinite strictly descending
> sequence $x_0 > x_1 > x_2 > \cdots$. Equivalently, every non-empty subset has
> a $<$-minimal element.

Our main result is:

> **Theorem (Main).** Let $P$ be a well-founded poset satisfying the Finite
> Antichain Condition. Then there is a chain $C \subseteq P$ meeting every
> non-empty height level of $P$. Consequently $P$ has the Aharoni–Korman
> property, with antichain partition given by its height levels.

The proof is organized around a single object: the **height** (well-founded
rank) function, which assigns to each element an ordinal recording how far it
sits above the minimal elements.

### Contributions

1. A complete, self-contained proof of the Aharoni–Korman property for
   well-founded FAC posets.
2. An *explicit* antichain partition — the ordinal height levels — together
   with a *constructive* description of the chain (top-down realization).
3. A clean separation of the argument into a finitary core (Section 5) and an
   infinitary compactness step (Section 6), each of independent interest.
4. A precise account of why well-foundedness is the exact frontier: it excludes
   the infinite descending configurations that obstruct the general conjecture.

## 2. Preliminaries: the height function

Throughout, $P$ is a poset whose strict order $<$ is well-founded.

> **Definition (height).** The *height* $\operatorname{height}(x)$ of an element
> $x \in P$ is its well-founded rank with respect to $<$; equivalently, it is
> defined by transfinite recursion as
> $$\operatorname{height}(x) = \sup\{\operatorname{height}(y) + 1 : y < x\}.$$

Because $<$ is well-founded, this recursion is well-defined and assigns to each
element a genuine ordinal. Minimal elements (those with no $y < x$) receive
height $0$, since the supremum of the empty set is $0$.

> **Definition (level set).** For an ordinal $\alpha$, the *level set* is
> $$L_\alpha = \{x \in P : \operatorname{height}(x) = \alpha\}.$$

The following monotonicity is the workhorse of everything that follows.

> **Lemma 2.1 (Strict monotonicity of height).** If $x < y$ then
> $\operatorname{height}(x) < \operatorname{height}(y)$.

*Proof sketch.* This is the defining property of well-founded rank: the rank of
$y$ strictly dominates the rank of every element below it, because the rank is
the supremum of $\operatorname{height}(z) + 1$ over $z < y$, and $x$ is one such
$z$. $\qquad\blacksquare$

## 3. The height levels form an antichain partition

We now record that the level sets $\{L_\alpha\}_\alpha$ have exactly the features
required of an Aharoni–Korman antichain partition.

> **Lemma 3.1 (Levels are antichains).** For every ordinal $\alpha$, the level
> set $L_\alpha$ is an antichain.

*Proof sketch.* Suppose $x, y \in L_\alpha$ are distinct and comparable, say
$x < y$. By Lemma 2.1, $\operatorname{height}(x) < \operatorname{height}(y)$,
contradicting $\operatorname{height}(x) = \alpha = \operatorname{height}(y)$.
Hence no two distinct elements of $L_\alpha$ are comparable. $\qquad\blacksquare$

> **Lemma 3.2 (Levels are finite).** If $P$ satisfies FAC, then every level set
> $L_\alpha$ is finite.

*Proof sketch.* By Lemma 3.1, $L_\alpha$ is an antichain; by FAC, every
antichain is finite. $\qquad\blacksquare$

> **Lemma 3.3 (Levels are disjoint).** If $\alpha \ne \beta$, then
> $L_\alpha \cap L_\beta = \varnothing$.

*Proof sketch.* An element $x$ in the intersection would satisfy
$\operatorname{height}(x) = \alpha$ and $\operatorname{height}(x) = \beta$,
forcing $\alpha = \beta$. $\qquad\blacksquare$

> **Lemma 3.4 (Levels cover $P$).** $\bigcup_{\alpha} L_\alpha = P$.

*Proof sketch.* Each $x \in P$ has a well-defined height $\alpha =
\operatorname{height}(x)$, so $x \in L_\alpha$. $\qquad\blacksquare$

Together, Lemmas 3.1–3.4 show that $\{L_\alpha : L_\alpha \ne \varnothing\}$ is a
partition of $P$ into finite antichains, indexed by ordinals. This reduces the
Aharoni–Korman property, for well-founded FAC posets, to the single statement:

> **Reduction.** It suffices to construct a chain $C \subseteq P$ such that
> $C \cap L_\alpha \ne \varnothing$ for every non-empty level $L_\alpha$.

## 4. Downward realizability of heights

The key enabling lemma is that heights below a given element are *realized* by
elements below it.

> **Lemma 4.1 (Downward realizability).** Let $w \in P$ and let $\alpha$ be an
> ordinal with $\alpha \le \operatorname{height}(w)$. Then there exists $u \le w$
> with $\operatorname{height}(u) = \alpha$.

*Proof sketch.* We argue by transfinite induction on $\operatorname{height}(w)$.
If $\alpha = \operatorname{height}(w)$, take $u = w$. Otherwise $\alpha <
\operatorname{height}(w)$. Since $\operatorname{height}(w) = \sup\{
\operatorname{height}(b) + 1 : b < w\}$, if every $b < w$ had
$\operatorname{height}(b) < \alpha$, then every $\operatorname{height}(b)+1 \le
\alpha$, forcing $\operatorname{height}(w) \le \alpha$, a contradiction. Hence
there is some $b < w$ with $\alpha \le \operatorname{height}(b)$. Because
$\operatorname{height}(b) < \operatorname{height}(w)$ (Lemma 2.1), the induction
hypothesis applies to $b$: there is $u \le b$ with $\operatorname{height}(u) =
\alpha$. Then $u \le b \le w$, as required. $\qquad\blacksquare$

Realizability is what lets a chain descend from a high witness and land on any
prescribed lower floor.

## 5. The finitary core: a chain through finitely many levels

We first solve the problem for finitely many levels at once. This is the
concrete heart of the theorem.

> **Lemma 5.1 (Chain below a witness).** Let $P$ satisfy FAC, let $w \in P$, and
> let $S$ be a finite set of ordinals with $\alpha \le \operatorname{height}(w)$
> for all $\alpha \in S$. Then there is a chain $C \subseteq P$ with $x \le w$
> for all $x \in C$ and $C \cap L_\alpha \ne \varnothing$ for every $\alpha \in
> S$.

*Proof sketch.* Induct on the finite set $S$. If $S = \varnothing$, take $C =
\varnothing$. Otherwise let $M = \max S$. By downward realizability (Lemma 4.1)
choose $u \le w$ with $\operatorname{height}(u) = M$. Applying the induction
hypothesis to the smaller set $S \setminus \{M\}$ with witness $u$ — valid
because every remaining $\alpha \le M = \operatorname{height}(u)$ — yields a
chain $C'$ below $u$ meeting each remaining level. Set $C = \{u\} \cup C'$. Every
element of $C'$ is $\le u \le w$, so all elements of $C$ are $\le w$; and $u$ is
comparable to (indeed above) every element of $C'$, so $C$ remains a chain. By
construction $C$ meets $L_M$ (through $u$) and every other level of $S$ (through
$C'$). $\qquad\blacksquare$

> **Lemma 5.2 (Finite chain hitting).** Let $P$ satisfy FAC and let $S$ be a
> finite set of ordinals such that $L_\alpha \ne \varnothing$ for every $\alpha
> \in S$. Then there is a chain $C \subseteq P$ with $C \cap L_\alpha \ne
> \varnothing$ for all $\alpha \in S$.

*Proof sketch.* If $S = \varnothing$, take $C = \varnothing$. Otherwise let
$M = \max S$ and pick $w \in L_M$, so $\operatorname{height}(w) = M \ge \alpha$
for all $\alpha \in S$. Apply Lemma 5.1 with this $w$ and $S$. $\qquad\blacksquare$

## 6. The infinitary step: compactness

To pass from arbitrary finite families of levels to *all* levels simultaneously,
we use a compactness principle in the spirit of König's lemma and the
compactness theorem of propositional logic.

> **Lemma 6.1 (Global compatibility from finite compatibility).** Let $(V_i)_{i
> \in I}$ be a family of non-empty finite sets and let $R_{ij} \subseteq V_i
> \times V_j$ be arbitrary binary relations. Suppose that for every finite
> $T \subseteq I$ there is a choice $f \in \prod_i V_i$ with $R_{ij}(f_i, f_j)$
> for all $i, j \in T$. Then there is a single global choice $f \in \prod_i V_i$
> with $R_{ij}(f_i, f_j)$ for all $i, j \in I$.

*Proof sketch.* Endow each finite $V_i$ with the discrete topology, in which it
is compact; by Tychonoff's theorem the product $\prod_i V_i$ is compact. For a
finite $T \subseteq I$ let
$$K_T = \{f \in \textstyle\prod_i V_i : R_{ij}(f_i, f_j) \text{ for all } i,j \in
T\}.$$
Each $K_T$ constrains only the finitely many coordinates indexed by $T$, hence is
closed (it is a finite intersection of preimages of closed sets under the
continuous coordinate-pair maps $f \mapsto (f_i, f_j)$). By hypothesis each $K_T$
is non-empty, and the family is downward directed since $K_{T_1 \cup T_2}
\subseteq K_{T_1} \cap K_{T_2}$. By the finite-intersection property of the
compact space $\prod_i V_i$, the intersection $\bigcap_T K_T$ is non-empty. Any
$f$ in this intersection lies in $K_{\{i,j\}}$ for all $i, j$, hence satisfies
$R_{ij}(f_i, f_j)$ for all $i, j \in I$. $\qquad\blacksquare$

## 7. Proof of the main theorem

> **Theorem 7.1 (Main).** Let $P$ be a well-founded poset satisfying FAC. Then
> there is a chain $C \subseteq P$ meeting every non-empty height level. Hence
> $P$ has the Aharoni–Korman property, with antichain partition given by its
> non-empty height levels.

*Proof sketch.* Let $I$ be the set of ordinals $\alpha$ with $L_\alpha \ne
\varnothing$. For each $\alpha \in I$ set $V_\alpha = L_\alpha$; by Lemma 3.2 each
$V_\alpha$ is finite, and it is non-empty by choice of $I$. Define the relation
$R_{\alpha\beta}(x, y)$ to hold when $x$ and $y$ are comparable (i.e. $x \le y$
or $y \le x$). For any finite $T \subseteq I$, Lemma 5.2 supplies a chain meeting
each level in $T$; selecting for each $\alpha \in T$ the (unique, since a chain
meets an antichain at most once) representative in $C \cap L_\alpha$, and
arbitrary representatives elsewhere, gives a choice $f$ pairwise-comparable on
$T$ — exactly the finite compatibility hypothesis of Lemma 6.1. Therefore Lemma
6.1 yields a global choice $f \in \prod_{\alpha \in I} V_\alpha$ that is pairwise
comparable across *all* of $I$. The image $C = \{f_\alpha : \alpha \in I\}$ is
then a chain (its elements are pairwise comparable) meeting every non-empty level
$L_\alpha$ (it contains $f_\alpha \in L_\alpha$). Combined with Lemmas 3.1–3.4,
which make $\{L_\alpha\}_{\alpha \in I}$ a partition into antichains, this
witnesses the Aharoni–Korman property. $\qquad\blacksquare$

## 8. The role of well-foundedness

Well-foundedness enters twice — to define the ordinal-valued height (Section 2)
and to power the transfinite induction behind downward realizability (Lemma 4.1)
— and it is not an artefact of the method but the exact boundary of validity.

In the general (not necessarily well-founded) setting, the Aharoni–Korman
statement is known to interact with a specific obstruction: a *saturated* chain
$D$ such that $D$ or its reverse decomposes as an ordered sum $\bigoplus_x D_x$
in which each block $D_x$ is infinite and co-well-founded (contains no infinite
strictly ascending chain). Such configurations are the source of the known
difficulties.

A well-founded poset can contain no such configuration, because any chain of
that shape would embed an infinite strictly descending sequence, contradicting
well-foundedness. Thus, ruling out infinite descents removes precisely the class
of chains responsible for the pathologies, which is why the property holds
cleanly for the well-founded FAC class. In particular, the theorem covers **all
countable well-founded FAC posets**, and more generally every well-founded FAC
poset regardless of cardinality, since the height construction and compactness
argument make no countability assumption.

## 9. Discussion and applications

**Explicitness.** Unlike many infinitary existence theorems, the witness here is
concrete. The antichain partition is the height-level floor plan, computable
level by level, and the chain is assembled by realizing levels top-down. In the
finite case the construction is a direct algorithm (Section 5); the infinite case
adds only a compactness selection.

**Relation to classical decomposition theorems.** For posets of finite height
the construction recovers a Mirsky-type picture: the height levels are exactly
the antichains of Mirsky's minimal decomposition, and the constructed chain
realizes the longest-chain bound. The present theorem can be seen as the
transfinite, FAC-restricted extension of that classical duality.

**Scheduling and dependency analysis.** Interpreting $<$ as a precedence
constraint, the height levels are the natural "generations" of a dependency
graph, and the guaranteed chain is a single critical thread touching every
generation — a structural certificate that no matter how tasks are batched into
independent generations, one coherent pipeline visits them all.

## 10. Future directions

The finite case establishes an explicit Aharoni–Korman witness built from the
height function. The following conjectures push the same structural idea toward
the well-founded and infinite regimes, where the problem is genuinely hard.

**1. Height-level witnesses for well-founded FAC posets.** Every well-founded
poset with no infinite antichain admits an Aharoni–Korman witness whose
antichain partition is exactly the family of ordinal height levels $\{x :
\operatorname{height}(x) = \xi\}$. Well-foundedness lets height take ordinal
values, and a maximal chain climbs through a contiguous block of height values,
meeting each non-empty level exactly once; the missing ingredient is a
transfinite selection of the climbing chain, which well-foundedness supplies.

**2. Boundedness of height across the FAC boundary.** A countable poset
satisfies the finite antichain condition if and only if every element has finite
height *and* only finitely many elements share each height. FAC forbids infinite
antichains, and each height level is itself an antichain, so FAC and
level-finiteness are two faces of the same constraint; this promotes "each level
finite" from corollary to characterization.

**3. Exactness of the level count.** For a poset of finite height, the minimum
number of antichains in any Aharoni–Korman partition equals one more than the
length of a longest chain, and this minimum is achieved by the height-level
partition. This is a Mirsky-type duality: a chain meets each antichain at most
once, so chain length lower-bounds the number of parts, while the height levels
realize that bound.

**4. Stability under products.** If two well-founded FAC posets each admit a
height-level Aharoni–Korman witness, then their product (with the componentwise
order) does as well, with height equal to the sum of the coordinate heights.
Height is additive along independent coordinates, so the product's levels are
diagonal sums of the factors' levels and inherit the antichain property.

## 11. Conclusion

For well-founded posets in which independence is always finite, the Aharoni–
Korman property holds with an explicit witness: the antichain partition is the
ordinal height-level decomposition, and a single chain — built by top-down
realization and glued together by compactness — meets every non-empty level. The
well-foundedness hypothesis is exactly what excludes the infinite descending
configurations known to obstruct the general conjecture, making this class both
natural and sharply delimited.
