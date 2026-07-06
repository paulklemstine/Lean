# A Characterization of the Aharoni–Korman Property via Saturated Chains: Structural Lemmas and a Refutation of the Obstruction Direction

## Abstract

The **Aharoni–Korman conjecture** (the *fishbone conjecture*) asserts that every
partially ordered set with no infinite antichain contains a chain meeting every
maximal antichain. A natural strategy for the countable case is to seek a
concrete structural obstruction whose absence characterizes the property. This
paper studies one such proposal: that a countable poset satisfying the finite
antichain condition has the fishbone property **if and only if** it contains no
saturated chain $D$ such that $D$ or its order dual is a countable direct sum of
infinite co-wellfounded posets.

We make three contributions. First, we develop the structural foundations:
we prove that every infinite co-wellfounded chain contains an infinite strictly
descending sequence (a *Descent Theorem*, via an Erdős–Szekeres argument), that
a linear order which is simultaneously well-founded and co-wellfounded is finite,
and that a countably infinite disjoint sum of nonempty posets is never FAC.
Second, we establish the easy positive facts about chains: every chain is FAC,
and every nonempty chain has the fishbone property. Third, and centrally, we
**refute the obstruction direction** of the proposed characterization: the
lexicographic sum $\sum_{k\in\mathbb{N}} \mathbb{N}^{\mathrm{op}}$ of countably many copies of
the reversed naturals is a countable FAC poset that *is* the proposed
obstruction and yet satisfies the fishbone property. Consequently the proposed
"if and only if" fails as stated; we isolate precisely why, and explain that the
reverse implication remains an open form of the conjecture.

**Keywords.** partial order, chain, antichain, finite antichain condition,
Aharoni–Korman conjecture, fishbone conjecture, co-wellfounded order, saturated
chain, lexicographic sum, Erdős–Szekeres.

---

## 1. Introduction

### 1.1 Chains and antichains

Let $(P, \le)$ be a partially ordered set (**poset**). A subset $C \subseteq P$
is a **chain** if it is totally ordered by $\le$ (any two elements are
comparable), and a subset $A \subseteq P$ is an **antichain** if its elements
are pairwise incomparable (for distinct $x, y \in A$, neither $x \le y$ nor
$y \le x$). Chains and antichains are dual extremes: a chain is a maximally
"comparable" set, an antichain a maximally "incomparable" one.

A poset satisfies the **finite antichain condition** (is **FAC**) if every
antichain is finite; equivalently, it has no infinite antichain. FAC posets may
be arbitrarily tall and intricate but are constrained in width.

### 1.2 The Aharoni–Korman conjecture

An antichain $A$ is **maximal** if no antichain properly contains it: for every
antichain $B \supseteq A$ we have $B = A$. Maximal antichains serve as
cross-sections of a poset.

> **Aharoni–Korman conjecture (fishbone conjecture).** Every FAC poset contains
> a chain $C$ that meets every maximal antichain, i.e. $A \cap C \neq \varnothing$
> for every maximal antichain $A$.

We call a poset with this property a poset that **satisfies AK**. The name
"fishbone" evokes a single chain (the spine) threaded so as to touch every
maximal antichain (the ribs). The conjecture holds trivially for finite posets
and is a long-standing open problem for infinite ones.

A remark on the faithful reading: one cannot ask a chain to meet *every*
antichain, since the empty antichain and various small antichains can be
disjoint from any fixed chain. The correct and standard formulation uses
*maximal* antichains, which is what we adopt throughout.

### 1.3 The proposed characterization

For countable posets, one hopes to characterize the fishbone property by the
absence of a concrete obstruction. The proposal analyzed in this paper is:

> **Proposed characterization.** A countable FAC poset $P$ satisfies AK if and
> only if $P$ does not contain a saturated chain $D$ such that $D$ or its order
> dual $D^{\mathrm{op}}$ is a countable direct sum of infinite co-wellfounded
> posets.

We denote the property "$P$ contains such a saturated chain" by saying $P$ is an
**AK obstruction**. The characterization splits into two implications:

- **(Obstruction direction)** If $P$ is an AK obstruction, then $P$ does *not*
  satisfy AK.
- **(Reverse direction)** If $P$ is *not* an AK obstruction, then $P$ *does*
  satisfy AK.

Our central result (Section 5) is that the **obstruction direction is false**.
The reverse direction is untouched by our counterexample and remains open.

### 1.4 Contributions and organization

Section 2 fixes definitions. Section 3 proves the structural lemmas about
co-wellfounded orders (the Descent Theorem and the Finiteness Theorem).
Section 4 records the width threshold for disjoint sums and the easy positive
facts about chains. Section 5 presents the counterexample refuting the
obstruction direction and dissects the error. Section 6 discusses consequences,
the status of the reverse direction, and future directions.

---

## 2. Definitions

Throughout, $P, Q$ denote posets and $\alpha$ a linear order.

**Definition 2.1 (FAC).** A poset $P$ is **FAC** if every antichain
$A \subseteq P$ is finite.

**Definition 2.2 (Maximal antichain).** An antichain $A \subseteq P$ is
**maximal** if, for every antichain $B$ with $A \subseteq B$, we have $A = B$.

**Definition 2.3 (Satisfies AK).** $P$ **satisfies AK** if there exists a chain
$C \subseteq P$ such that $A \cap C \neq \varnothing$ for every maximal antichain
$A$.

**Definition 2.4 (Co-wellfounded).** A structure $(\alpha, <)$ is
**well-founded** if the relation $<$ is well-founded (no infinite strictly
descending sequence). It is **co-wellfounded** if the reverse relation $>$ is
well-founded (no infinite strictly ascending sequence). The reversed natural
numbers $\mathbb{N}^{\mathrm{op}} = (\cdots < 3 < 2 < 1 < 0)$ are the canonical infinite
co-wellfounded chain.

**Definition 2.5 (Direct/lexicographic sum).** Given a linearly ordered index
set $(\iota, \le)$ and, for each $i \in \iota$, a linear order $f(i)$, the
**direct sum** (lexicographic sum) $\sum_{i \in \iota} f(i)$ has underlying set
$\{(i, x) : i \in \iota,\ x \in f(i)\}$ ordered by
$$ (i, x) \le (j, y) \iff i < j \ \text{ or } \ (i = j \ \text{and}\ x \le_{f(i)} y). $$
It is a linear order. We say a linear order $C$ **is a direct sum of** the family
$f$ if $C$ is order-isomorphic to $\sum_{i\in\iota} f(i)$.

**Definition 2.6 (Countable direct sum of infinite co-wellfounded posets).** A
linear order $C$ **is a countable direct sum of infinite co-wellfounded posets**
if there exist a countable linearly ordered index set $\iota$ and a family
$\{f(i)\}_{i\in\iota}$ of linear orders such that each $f(i)$ is infinite and
co-wellfounded, and $C \cong \sum_{i\in\iota} f(i)$.

**Definition 2.7 (Saturated chain).** An order embedding $e : D \hookrightarrow P$
from a linear order $D$ **presents a saturated chain** if its image is a maximal
chain: for every $x \in P$, if $x$ is comparable to $e(d)$ for all $d \in D$
(that is, $e(d) \le x$ or $x \le e(d)$ for each $d$), then $x = e(d)$ for some
$d$.

**Definition 2.8 (AK obstruction).** A countable FAC poset $P$ **is an AK
obstruction** if there exists a linear order $D$ and an order embedding
$e : D \hookrightarrow P$ presenting a saturated chain such that $D$ or its dual
$D^{\mathrm{op}}$ is a countable direct sum of infinite co-wellfounded posets
(Definition 2.6).

---

## 3. Structural lemmas on co-wellfounded orders

The engine of the subject is a single fact: infinite one-directional orders
always contain a full copy of the reversed naturals.

### 3.1 The Descent Theorem

> **Theorem 3.1 (Descent Theorem).** Let $\alpha$ be an infinite linear order
> that is co-wellfounded. Then there is a strictly antitone map
> $f : \mathbb{N} \to \alpha$; equivalently, $\alpha$ contains an infinite
> strictly descending sequence.

**Proof sketch.** Since $\alpha$ is infinite, fix an injection
$g_0 : \mathbb{N} \hookrightarrow \alpha$ enumerating distinct elements. Apply the
Erdős–Szekeres / infinite Ramsey principle for monotone subsequences: there is a
strictly increasing index map $g : \mathbb{N} \to \mathbb{N}$ such that the
subsequence $n \mapsto g_0(g(n))$ is either

1. **weakly increasing throughout**, $m < n \Rightarrow g_0(g(m)) \le g_0(g(n))$, or
2. **weakly decreasing throughout**, $m < n \Rightarrow g_0(g(n)) \le g_0(g(m))$.

Because $g_0$ is injective and $g$ strictly increasing, the composite
$n \mapsto g_0(g(n))$ is injective, so all the weak inequalities are strict:
case (1) yields a strictly increasing subsequence and case (2) a strictly
decreasing one.

A strictly increasing sequence $g_0(g(0)) < g_0(g(1)) < \cdots$ is an infinite
strictly ascending sequence, which co-wellfoundedness forbids (equivalently, it
contradicts the well-foundedness of $>$ via the "no strictly monotone map into a
well-founded-by-$>$ order" principle). Hence case (1) is impossible, and case (2)
provides the required strictly antitone $f = g_0 \circ g$. $\qquad\blacksquare$

The theorem is sharp: the finiteness hypothesis "infinite" cannot be dropped
(finite chains have no infinite descending sequence), and co-wellfoundedness is
exactly what rules out the ascending alternative.

### 3.2 The Finiteness Theorem

> **Theorem 3.2 (Finiteness Theorem).** A linear order $\alpha$ that is both
> well-founded and co-wellfounded is finite.

**Proof.** Contrapositive. Suppose $\alpha$ is infinite. By Theorem 3.1 (using
co-wellfoundedness), $\alpha$ contains an infinite strictly descending sequence
$f : \mathbb{N} \to \alpha$ with $f(0) > f(1) > f(2) > \cdots$. This is an
infinite strictly descending sequence, contradicting well-foundedness. Hence
$\alpha$ must be finite. $\qquad\blacksquare$

Theorem 3.2 gives a crisp criterion: a linear order is finite **iff** it forbids
both infinite ascent and infinite descent. It is the linear-order shadow of the
principle that finiteness equals boundedness in every direction of infinity, and
it is the base case for a hoped-for extension to all posets via a chain-or-
antichain dichotomy (Section 6).

---

## 4. Width thresholds and the easy positive facts

### 4.1 The width threshold for disjoint sums

Call a family $\{P_i\}_{i \in \iota}$ arranged as a **disjoint sum** if the
underlying set is $\bigsqcup_i P_i$ and elements from different summands are
mutually incomparable, while each summand keeps its own order. (This is the
"antichain of blocks" construction, in contrast to the linear direct sum of
Definition 2.5.)

> **Theorem 4.1 (Width threshold).** A disjoint sum of countably infinitely many
> nonempty posets is not FAC.

**Proof.** For each $i \in \iota$ (with $\iota$ countably infinite), choose an
element $a_i \in P_i$ (possible since each $P_i$ is nonempty). The set
$T = \{a_i : i \in \iota\}$ is a **transversal**. For $i \neq j$, the elements
$a_i \in P_i$ and $a_j \in P_j$ lie in different summands and are therefore
incomparable. Thus $T$ is an antichain, and $|T| = |\iota|$ is infinite. So $P$
has an infinite antichain and is not FAC. $\qquad\blacksquare$

This pins the exact boundary of the FAC condition from the "wide" side: the
moment infinitely many nonempty pieces sit side by side without comparisons, an
infinite antichain is forced. Finitely many pieces, by contrast, add their
widths and preserve FAC (see Section 6, Direction 2).

### 4.2 Chains are the easy case of the fishbone property

> **Theorem 4.2.** Every chain (linear order) is FAC.

**Proof.** In a linear order any two distinct elements are comparable, so any
antichain has at most one element. In particular every antichain is finite.
$\qquad\blacksquare$

> **Theorem 4.3.** Every nonempty chain satisfies AK.

**Proof.** Let $C = P$ be the entire (nonempty) chain, which is a chain in
itself. Let $A$ be any maximal antichain. By Theorem 4.2, $A$ has at most one
element; maximality together with nonemptiness of $P$ forces $A$ to be a
singleton $\{a\}$ with $a \in P = C$. Hence $A \cap C = \{a\} \neq \varnothing$.
Thus $C$ meets every maximal antichain, and $P$ satisfies AK. $\qquad\blacksquare$

Theorems 4.2–4.3 say chains always win the fishbone game trivially. This is the
seed of the counterexample: a chain can simultaneously *be* the proposed
obstruction and *satisfy* AK.

---

## 5. The obstruction direction is false

### 5.1 The counterexample

Consider the linear order
$$ D \;=\; \sum_{k \in \mathbb{N}} \mathbb{N}^{\mathrm{op}}, $$
the lexicographic (direct) sum, along the index order $\mathbb{N}$, of countably
many copies of the reversed naturals $\mathbb{N}^{\mathrm{op}}$. Concretely, the underlying
set is $\mathbb{N} \times \mathbb{N}$ with
$$ (k, n) \le (k', n') \iff k < k' \ \text{ or } \ \big(k = k' \ \text{and}\ n \ge n'\big). $$
Block $k$ is the copy $\{k\} \times \mathbb{N}^{\mathrm{op}}$; smaller block indices come
first, and within a block the second coordinate is reversed.

> **Theorem 5.1 (Refutation of the obstruction direction).** There is a
> countable FAC poset $P$ that is an AK obstruction and yet satisfies AK.
> Consequently, the implication "AK obstruction $\Rightarrow$ not AK" is false,
> and the proposed characterization fails as stated.

**Proof.** Take $P = D$ as above, with its linear order. We verify all four
claims.

*$P$ is countable.* Its underlying set is $\mathbb{N}\times\mathbb{N}$, which is
countable.

*$P$ is FAC.* $P$ is a linear order, so by Theorem 4.2 it is FAC.

*$P$ satisfies AK.* $P$ is a nonempty chain, so by Theorem 4.3 it satisfies AK
(take $C = P$; every maximal antichain is a singleton lying in $P$).

*$P$ is an AK obstruction.* Take $D = P$ itself and $e = \mathrm{id}_P$, an order
embedding. Its image is all of $P$, which is vacuously a maximal chain (there is
no element outside the image), so $e$ presents a saturated chain (Definition
2.7). Moreover $D = \sum_{k\in\mathbb{N}} \mathbb{N}^{\mathrm{op}}$ is by construction a
countable direct sum (index set $\mathbb{N}$, countable) of the orders
$f(k) = \mathbb{N}^{\mathrm{op}}$, each of which is infinite and co-wellfounded (its reverse
$>$ is well-founded, being order-isomorphic to the standard $<$ on
$\mathbb{N}$). Hence $D$ is a countable direct sum of infinite co-wellfounded
posets, and $P$ is an AK obstruction by Definition 2.8.

Thus $P$ is countable, FAC, an AK obstruction, and satisfies AK — all four at
once. The obstruction direction claims an AK obstruction fails AK; $P$ is a
counterexample. $\qquad\blacksquare$

### 5.2 Anatomy of the error

Why does a well-motivated proposal fail so cleanly? The obstruction was meant to
capture a chain welded from one-directional (co-wellfounded) blocks so that
infinite ascending sequences appear across the welding seams and disrupt the
poset's structure relative to its antichains. That is a genuine and useful
phenomenon — *when the chain sits inside a wider poset with nontrivial
antichains crossing it.*

The defect is that Definition 2.8 permits the obstructing saturated chain to be
the *entire* poset. When $P$ is itself a chain:

1. every maximal antichain is a singleton (Theorem 4.2), and
2. the whole chain trivially meets every singleton (Theorem 4.3).

So there are no cross-sectional antichains for the obstruction to spoil, and the
fishbone property holds for free. The statement conflated two roles a chain can
play: as an *ambient poset* (where a saturated chain being the whole space makes
AK trivial) versus as a *thread inside a genuinely two-dimensional poset* (where
welding artifacts can matter). The counterexample exploits precisely the first
role.

The repair is therefore structural rather than cosmetic: the obstruction must be
required to interact with the poset's antichains — e.g. by insisting that $P$
itself not be a chain, or, more robustly, that the saturated chain be crossed by
infinitely many distinct maximal antichains. Formulating the "right" side
condition is exactly the content of the open reverse direction.

### 5.3 What remains open

The counterexample refutes only the obstruction direction. The **reverse
direction** —

> if a countable FAC poset is *not* an AK obstruction, then it satisfies AK

— is not contradicted by any chain example (a chain is never a counterexample to
AK, since it always satisfies AK). This implication is a genuine, still-open form
of the Aharoni–Korman conjecture for countable posets, and it is where future
effort should concentrate.

---

## 6. Discussion and future directions

Refuting one direction of a proposed characterization sharpens rather than
closes the program: it tells us exactly which hypothesis was too weak and points
to the structural facts a corrected statement must respect. We close with four
concrete directions, each rooted in the lemmas above.

**1. The two-sided failure of welded co-wellfounded chains.** Weld countably
many infinite reverse-well-ordered chains end to end, in order type indexed by
the natural numbers, to obtain a single saturated chain. Then neither this chain
nor its reverse is well-founded, and the ascending sequences responsible for the
failure live entirely across the welding seams rather than inside any block. The
key insight is that co-wellfoundedness is a strictly one-directional property, so
gluing one-directional pieces along a second direction inevitably manufactures
the missing infinite ascending sequence at the block boundaries. This is now
within reach because the Descent Theorem (3.1) isolates the atomic fact that
every infinite co-wellfounded chain carries a copy of $\mathbb{N}^{\mathrm{op}}$ — exactly what
a block-wise gluing argument needs.

**2. Additivity of the finite antichain condition under finite direct sums.**
Combining finitely many FAC posets again yields an FAC poset, and the largest
antichain of the combination is exactly the sum of the largest antichains of the
parts. The key insight is that any antichain of a disjoint combination splits as
the union of its restrictions to the individual parts, so finiteness and size add
across finitely many parts and diverge only once infinitely many parts appear.
This is the natural positive counterpart to the negative Width Threshold
(Theorem 4.1), which fixes where FAC must fail.

**3. A chain-or-antichain dichotomy sharpening the monotone-sequence theorem.**
Every infinite poset contains either an infinite chain or an infinite antichain,
and a poset is finite if and only if it simultaneously forbids infinite
ascending sequences, infinite descending sequences, and infinite antichains. The
key insight is that the two-colouring of pairs by "comparable versus
incomparable" turns the classical monotone-subsequence argument into a Ramsey
statement whose monochromatic sets are precisely chains and antichains. The
Finiteness Theorem (3.2) already handles the linear case via a two-way monotone
dichotomy; adding the incomparable colour lifts it to all posets using standard
infinite Ramsey machinery.

**4. Unique co-wellfounded segmentation of saturated chains.** Inside any
countable FAC poset, every saturated chain breaks canonically into consecutive
segments, each of which is well-founded or co-wellfounded, and the obstruction to
the fibre-partition property is the presence of infinitely many infinite
co-wellfounded segments. A structure theory of this kind would translate the
corrected obstruction into a decidable-looking segmentation invariant, bringing
the reverse direction of the characterization within analytic reach.

---

## 7. Conclusion

We studied a proposed structural characterization of the countable Aharoni–Korman
property and found that its obstruction direction is false: the lexicographic sum
$\sum_{k\in\mathbb{N}} \mathbb{N}^{\mathrm{op}}$ is a countable FAC poset that is an AK obstruction
yet satisfies AK. The refutation rests on the elementary but decisive facts that
every chain is FAC and every nonempty chain satisfies AK, combined with the
observation that a chain can literally be a countable direct sum of infinite
co-wellfounded blocks. Along the way we developed the structural bedrock — the
Descent Theorem, the Finiteness Theorem, and the Width Threshold — that both
explains the failure and equips the next attempt. The reverse direction remains
open and, we believe, is the right place to press further.
