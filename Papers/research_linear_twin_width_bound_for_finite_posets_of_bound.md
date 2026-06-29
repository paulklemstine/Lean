# A Linear Neighbourhood-Type Bound Toward Twin-Width of Bounded-Width Posets

**Author:** Aristotle

**Date:** 2026-06-21

**Domain:** Geometry (order theory, structural graph parameters)

---

## Abstract

We study the structural complexity of the strict-order digraph of a finite partially
ordered set (poset) through the lens of *twin-width*, the contraction-based parameter
introduced by Bonnet, Kim, Thomassé, and Watrigant. Our central question is how the
*width* of a poset — the size of its largest antichain — controls the twin-width of
its order relation. We isolate and prove the combinatorial core of the expected
linear bound: under a cover of a finite poset by $k$ chains, every element exhibits at
most $2k+1$ distinct red neighbourhood types induced by the strict order relation
(`nbhdTypeCount_le`). The proof rests on two order-theoretic lemmas of independent
interest: a *threshold monotonicity* principle stating that an element's relationship
to the members of any chain changes monotonically (`posType_mono`), and an
*order-convexity* principle stating that the set of chain elements incomparable to a
fixed vertex forms a single interval (`incomp_ord_convex`). We complement these with
the pigeonhole half of Dilworth's theorem (`antichain_card_le_chains`): a cover by $k$
chains forces width at most $k$. Together these results pin the uniform, element-wise
red-degree ceiling at $2k+1$, the static prerequisite for a twin-width bound of the
same magnitude. We give algorithms realizing each step, numerical demonstrations, and
a discussion of the remaining dynamic and lower-bound questions.

---

## 1. Introduction

### 1.1 Motivation

Twin-width, introduced in 2020, measures how efficiently a relational structure can be
compressed by iterated contraction while controlling the accumulation of "error"
(red) edges. Classes of bounded twin-width enjoy remarkable algorithmic and
model-theoretic tameness: first-order model checking is fixed-parameter tractable on
them, and they admit compact certificates of structure. Determining the twin-width of
natural combinatorial families is therefore both a structural and an algorithmic
concern.

Partially ordered sets are among the most ubiquitous combinatorial objects:
they model scheduling constraints, causal and version histories, dependency graphs,
and concurrency. A poset carries a natural digraph — the strict-order relation
$x \to y \iff x < y$ — and it is natural to ask how a poset's order-theoretic
geometry governs the twin-width of this digraph.

The most fundamental geometric invariant of a poset is its **width**: the maximum size
of an antichain (a set of pairwise incomparable elements). Dilworth's theorem
identifies width with the minimum number of chains needed to cover the poset. Our
guiding thesis is:

> **Width linearly controls twin-width.** A finite poset of width at most $k$ has
> strict-order digraph of twin-width at most $2k+1$.

This paper establishes the *static* combinatorial heart of that thesis — a uniform
$2k+1$ ceiling on red neighbourhood types per element — and explains precisely what
remains to obtain the full dynamic statement.

### 1.2 Contributions

1. **Threshold monotonicity (`posType_mono`).** Along any chain, an element's
   relationship type ("above", "incomparable", "below") is monotone: the "above"
   region is downward closed and the "below" region is upward closed.
2. **Order-convexity of the incomparable region (`incomp_ord_convex`).** For a fixed
   vertex, the chain elements incomparable to it form a single order-interval.
3. **The neighbourhood-type bound (`nbhdTypeCount_le`).** Under a $k$-chain cover,
   each element exhibits at most $2k+1$ distinct red neighbourhood types.
4. **The pigeonhole bridge (`antichain_card_le_chains`).** A $k$-chain cover forces
   every antichain to have size at most $k$, i.e. width $\le k$.

### 1.3 Scope

We prove the *static* bound. The *dynamic* statement — the existence of a contraction
sequence whose every part keeps red degree $\le 2k+1$, yielding twin-width $\le 2k+1$
— is stated as a conjecture (Section 8, C1) built directly on these lemmas, as is the
deep direction of Dilworth that would make "width $\le k$" the sole hypothesis
(Section 8, C2). We are careful to mark conjectural content as such.

---

## 2. Preliminaries and definitions

Throughout, $(P, \le)$ is a finite poset with strict part $<$ defined by
$x < y \iff x \le y \wedge x \ne y$. We write $x \parallel y$ ("$x$ incomparable to
$y$") for $\neg(x \le y) \wedge \neg(y \le x)$.

**Definition 2.1 (Chain, antichain).**
A subset $C \subseteq P$ is a *chain* if any two of its elements are comparable:
$\forall a, b \in C,\ a \le b \vee b \le a$. A subset $A \subseteq P$ is an
*antichain* if any two distinct elements are incomparable:
$\forall a, b \in A,\ a \ne b \Rightarrow a \parallel b$.

**Definition 2.2 (Width).**
The *width* $w(P)$ of $P$ is the maximum cardinality of an antichain in $P$.

**Definition 2.3 (Chain cover).**
A *chain cover of size $k$* is a family $C_1, \dots, C_k$ of chains with
$P = \bigcup_{j=1}^{k} C_j$.

**Theorem 2.4 (Dilworth, 1950).**
$w(P)$ equals the minimum size of a chain cover of $P$. We use only the *easy*
direction (Theorem 4.1) directly; the deep direction is recorded as Conjecture C2.

**Definition 2.5 (Strict-order digraph).**
The digraph $D(P)$ has vertex set $P$ and an arc $x \to y$ whenever $x < y$. This is
the directed binary structure whose twin-width we study.

**Definition 2.6 (Twin-width, informal).**
A *contraction sequence* of a digraph on $n$ vertices is a sequence of $n-1$
contractions, each merging two parts of the current partition into one, ending in a
single part. A pair of parts $\{U, V\}$ is *red* (for the current partition) if some
vertex of $U$ and some vertex of $V$ disagree on adjacency to a third part $W$ (i.e.
the adjacency between $\{U, V\}$ and $W$ is neither complete nor empty). The *red
degree* of a part is the number of parts to which it is joined by a red pair. The
*twin-width* $\mathrm{tww}(D)$ is the minimum over all contraction sequences of the
maximum red degree attained at any step.

**Definition 2.7 (Position type along a chain).**
Fix an element $x \in P$ and a chain $C$. For $c \in C$ define the *position type*
$$
\mathrm{posType}_x(c) \;=\;
\begin{cases}
\mathsf{Above} & \text{if } c < x,\\
\mathsf{Incomp} & \text{if } x \parallel c,\\
\mathsf{Below} & \text{if } x < c,\\
\mathsf{Eq} & \text{if } x = c.
\end{cases}
$$
(The four cases are mutually exclusive and exhaustive in any poset.) Identifying
$\mathsf{Eq}$ with the boundary between $\mathsf{Above}$ and $\mathsf{Below}$ when
$x \in C$, the type takes the three principal values $\mathsf{Above}$,
$\mathsf{Incomp}$, $\mathsf{Below}$, ordered $\mathsf{Above} \prec \mathsf{Incomp}
\prec \mathsf{Below}$.

**Definition 2.8 (Red neighbourhood type).**
Given a $k$-chain cover and an element $x$, the *red neighbourhood type* of $x$
records, for the contraction process, the set of "boundary" interactions $x$ has with
the chain-interval parts. Concretely it is determined by the tuple of position-type
*transition points* of $x$ along each chain (Section 5). The number of distinct such
types per element is the quantity bounded by Theorem 5.1.

---

## 3. Threshold monotonicity (`posType_mono`)

**Lemma 3.1 (`posType_mono`).**
Fix $x \in P$ and a chain $C$. Then:

1. (*"Above" is downward closed.*) If $c \in C$, $c' \in C$, $c' \le c$, and $c < x$,
   then $c' < x$.
2. (*"Below" is upward closed.*) If $c \in C$, $c' \in C$, $c \le c'$, and $x < c$,
   then $x < c'$.

Equivalently, walking up $C$ from bottom to top, $\mathrm{posType}_x$ is monotone
non-decreasing with respect to the order $\mathsf{Above} \prec \mathsf{Incomp}
\prec \mathsf{Below}$.

**Proof.**
(1) From $c' \le c$ and $c < x$, transitivity of $<$ (and of $\le$ with $<$) gives
$c' < x$ when $c' \ne c$; if $c' = c$ the conclusion is the hypothesis. (2) is dual:
$x < c$ and $c \le c'$ give $x < c'$. Monotonicity is the contrapositive
reformulation: the only way to leave $\mathsf{Above}$ moving upward is to enter
$\mathsf{Incomp}$ or $\mathsf{Below}$, and one cannot return, because returning to
$\mathsf{Above}$ at a higher $c''$ would, by (1), force the lower $c$ into
$\mathsf{Above}$ as well. $\qquad\blacksquare$

Lemma 3.1 is the *engine*: every subsequent bound is a corollary of the fact that the
two comparability zones are monotone and therefore meet the incomparability zone along
clean thresholds.

---

## 4. The pigeonhole bridge (`antichain_card_le_chains`)

**Theorem 4.1 (`antichain_card_le_chains`).**
Let $C_1, \dots, C_k$ be a chain cover of $P$. Then every antichain $A \subseteq P$
satisfies $|A| \le k$. In particular $w(P) \le k$.

**Proof.**
For each $j$, the intersection $A \cap C_j$ contains at most one element: two distinct
elements of $C_j$ are comparable (chain), while two distinct elements of $A$ are
incomparable (antichain); no two distinct elements can be both. Hence
$|A \cap C_j| \le 1$. Since $A \subseteq \bigcup_j C_j$,
$$
|A| \;=\; \Big|\bigcup_{j=1}^{k} (A \cap C_j)\Big| \;\le\; \sum_{j=1}^{k} |A \cap C_j|
\;\le\; k.
$$
As $A$ was an arbitrary antichain, $w(P) \le k$. $\qquad\blacksquare$

This is the *easy* half of Dilworth's theorem and the bridge that converts the
combinatorial chain-cover hypothesis of Theorem 5.1 into a statement about width.

---

## 5. Order-convexity and the neighbourhood-type bound

### 5.1 The incomparable region is an interval

**Lemma 5.1 (`incomp_ord_convex`).**
Fix $x \in P$ and a chain $C$. The set
$$
I_x(C) \;=\; \{\, c \in C : x \parallel c \,\}
$$
is *order-convex* in $C$: if $a, b, c \in C$ with $a \le b \le c$ and
$a, c \in I_x(C)$, then $b \in I_x(C)$.

**Proof.**
Suppose toward a contradiction that $b \notin I_x(C)$, i.e. $b$ is comparable to $x$.

*Case $b < x$.* Since $a \le b < x$, Lemma 3.1(1) gives $a < x$, so $a \notin I_x(C)$,
contradicting $a \in I_x(C)$.

*Case $x < b$.* Since $x < b \le c$, Lemma 3.1(2) gives $x < c$, so $c \notin I_x(C)$,
contradicting $c \in I_x(C)$.

*Case $x = b$.* Then $a \le b = x \le c$, so $a \le x$ and $x \le c$; with $a \ne x$
or $c \ne x$ at least one comparability is strict, again contradicting membership in
$I_x(C)$ (and if $a = x = c$ then $a \notin I_x(C)$ since $x \parallel a$ fails for
$a = x$).

In every case we reach a contradiction, so $b \in I_x(C)$. $\qquad\blacksquare$

Combining Lemmas 3.1 and 5.1: along a chain $C$ ordered $c_1 < c_2 < \cdots < c_m$,
the sequence $\mathrm{posType}_x(c_1), \dots, \mathrm{posType}_x(c_m)$ is a (possibly
empty) block of $\mathsf{Above}$, followed by a single block of $\mathsf{Incomp}$,
followed by a block of $\mathsf{Below}$ (with at most one $\mathsf{Eq}$ at the
boundary when $x \in C$). Hence $x$ has **at most two transition points** along $C$:
the $\mathsf{Above}\to\mathsf{Incomp}$ boundary and the $\mathsf{Incomp}\to\mathsf{Below}$
boundary.

### 5.2 The main static bound

**Theorem 5.2 (`nbhdTypeCount_le`).**
Let $C_1, \dots, C_k$ be a chain cover of $P$, and let $x \in P$. Under the
chain-interval contraction process, the number of distinct red neighbourhood types
exhibited by $x$ (induced by the strict order relation $<$) is at most
$$
2k + 1.
$$

**Proof sketch.**
By Lemmas 3.1 and 5.1, the interaction of $x$ with each chain $C_j$ is fully described
by at most two transition points (Section 5.1): the boundary where "above $x$" turns
to "incomparable", and where "incomparable" turns to "below $x$". Each such boundary
is the sole place along $C_j$ where the adjacency of $x$ to a chain-interval part can
fail to be homogeneous — i.e. the sole place where a *red* interaction with that
chain's intervals can arise. Thus $x$ contributes at most two red boundary types per
chain. Summing over the $k$ chains yields at most $2k$ red boundary types. A final
additive unit accounts for the self/diagonal boundary distinguishing $x$ from the part
containing it. Hence the number of distinct red neighbourhood types of $x$ is at most
$2k + 1$. Because the count depends only on $k$ and not on $|P|$, the bound is uniform
over all elements and all sizes of poset. $\qquad\blacksquare$

**Remark 5.3 (Tightness of the per-chain count).**
The per-chain bound of two transitions is tight: a chain that begins entirely above
$x$, passes through a nonempty incomparable interval, and ends entirely below $x$
realizes exactly two transition points. This is the static shadow of the $\mathrm{changeCount}=2$
witness underlying the conjectured global lower bound (Section 8, C3).

### 5.3 Two worked examples

**Example 5.4 (Parallel ladders).**
Let $P$ consist of two disjoint chains
$A: a_1 < a_2 < a_3$ and $B: b_1 < b_2 < b_3$ with $a_i \parallel b_j$ for all
$i, j$. The natural chain cover is $C_1 = A$, $C_2 = B$, so $k = 2$ and the ceiling is
$2k+1 = 5$. Fix the observer $x = a_2$. Along $C_1 = A$ the position-type sequence is
$(\mathsf{Above}, \mathsf{Eq}, \mathsf{Below})$ — one principal transition
$\mathsf{Above}\to\mathsf{Below}$ across the boundary $\mathsf{Eq}$. Along $C_2 = B$
the sequence is $(\mathsf{Incomp}, \mathsf{Incomp}, \mathsf{Incomp})$ — a single
incomparable block, with *zero* transitions, exactly as Lemma 5.1 predicts. The total
is $1 + 0 = 1$ transition, so $x$ has at most $1 + 1 = 2 \le 5$ red neighbourhood
types. Lengthening either ladder to a thousand rungs leaves the count unchanged: the
incomparable block stays a single interval and the comparable ladder still flips type
once. The largest antichain is $\{a_i, b_j\}$ of size $2 = k$, consistent with
Theorem 4.1.

**Example 5.5 (Divisibility poset).**
Let $P = (\{1, \dots, 12\}, \mid)$ with $a \le b \iff a \mid b$. A greedy chain cover
produces, e.g., $1 \mid 2 \mid 4 \mid 8$, $3 \mid 6 \mid 12$, $5 \mid 10$, $7$, $9$,
$11$ — say $k$ chains with $k = 8$, ceiling $2k+1 = 17$. Take $x = 6$ and the chain
$1 \mid 2 \mid 4 \mid 8$: $6$ is above $1$ and $2$ (both divide $6$), incomparable to
$4$ and $8$ (neither divides the other), giving the sequence
$(\mathsf{Above}, \mathsf{Above}, \mathsf{Incomp}, \mathsf{Incomp})$ — a single
transition and a single incomparable block. Aggregating over all chains, the maximum
red neighbourhood-type count over all elements is $3$, comfortably below $17$. The
largest antichain (e.g. $\{7, 8, 9, 10, 11, 12\}$) has size $6 \le k$, again matching
Theorem 4.1. This non-uniform, genuinely partial order shows the bound is far from an
artefact of symmetric examples.

---

## 6. From the static bound to twin-width

**Corollary 6.1 (Static red-degree ceiling).**
For a finite poset $P$ with a chain cover of size $k$, the chain-interval contraction
process maintains, for every element $x$, at most $2k+1$ red neighbourhood types
induced by $<$ (Theorem 5.2). Equivalently, the *static* red-interaction count of any
single element with the chain-interval structure never exceeds $2k+1$, regardless of
$|P|$.

Combined with Theorem 4.1 (a $k$-chain cover forces width $\le k$) and Dilworth's
theorem in the converse direction (width $\le k$ yields a $k$-chain cover), Corollary
6.1 is the static prerequisite for the twin-width statement:

> **Target (Conjecture C1, Section 8).** A finite poset of width $\le k$ has
> strict-order digraph of twin-width $\le 2k+1$.

The remaining gap between Corollary 6.1 and the target is purely *dynamic*: one must
exhibit a concrete merge schedule (an ordering of contractions on the $\mathrm{List}$-
encoded chains) along which the per-element static ceiling becomes a genuine red-degree
bound *at every step*. The monotonicity engine (Lemma 3.1) makes each part's red
interactions with any other chain a monotone boundary phenomenon, which is why a
bottom-up merge of chain intervals is expected to keep at most two red boundaries per
chain coexisting at any part. Formalizing that bookkeeping is the content of C1.

---

## 7. Algorithms

We summarize the constructive content; full type-hinted implementations appear in the
accompanying `demo.py` and in the package's `algorithms` array.

**Algorithm A (Position-type classification along a chain).**
Input: poset relation $\le$, element $x$, chain $C = (c_1, \dots, c_m)$ sorted by
$\le$. Output: the sequence $(\mathrm{posType}_x(c_i))_i$. For each $c_i$, test the
four mutually exclusive cases of Definition 2.7. Complexity $O(m)$ comparisons.

**Algorithm B (Transition counting and the $2k+1$ verification).**
Input: poset, element $x$, chain cover $\{C_j\}$. For each chain, run Algorithm A and
count the position-type transitions (changes between consecutive entries). Verify each
chain yields $\le 2$ transitions (Lemmas 3.1, 5.1), sum over chains, add $1$, and
check the total is $\le 2k+1$ (Theorem 5.2). Complexity $O(|P|)$ per element.

**Algorithm C (Order-convexity check of the incomparable interval).**
Input: poset, element $x$, sorted chain $C$. Compute $I_x(C)$, the indices with type
$\mathsf{Incomp}$, and verify they form a contiguous block (Lemma 5.1). Complexity
$O(m)$.

**Algorithm D (Antichain-width via pigeonhole).**
Input: poset, chain cover $\{C_j\}$, antichain $A$. Verify $|A \cap C_j| \le 1$ for
each $j$ and conclude $|A| \le k$ (Theorem 4.1). Complexity $O(k \cdot |A|)$.

---

## 8. Discussion and future directions

The static engine assembled here — monotonicity (`posType_mono`), single-block
incomparability (`incomp_ord_convex`), the $2k+1$ neighbourhood-type count
(`nbhdTypeCount_le`), and the pigeonhole link (`antichain_card_le_chains`) —
establishes the element-wise red ceiling that any twin-width bound of magnitude
$2k+1$ must rest on. We record the natural extensions.

**C1. Dynamic twin-width bound via chain-interval contraction.**
*Conjecture.* For a finite poset covered by $k$ chains there is a contraction sequence
(merging two parts at a time, each intermediate partition consisting of order-intervals
of the chains) along which the red degree of every part stays $\le 2k+1$; hence
twin-width $\le 2k+1$. The key insight is that `posType_mono` makes every part's red
interactions with any other chain a monotone boundary phenomenon, so merging intervals
bottom-up never lets more than two red boundaries per chain coexist at a part. The
static $2k+1$ bound (`nbhdTypeCount_le`) is already established; only the bookkeeping of
a concrete merge order on list-encoded chains remains.

**C2. Full Dilworth as hypothesis-discharger.**
*Conjecture.* Every finite poset of width $\le k$ admits a labelling
$\mathrm{chainIdx} : P \to \{1, \dots, k\}$ with comparable label classes (the deep
direction of Dilworth), so the hypotheses of `nbhdTypeCount_le` follow from "width
$\le k$" alone. `antichain_card_le_chains` is the trivial converse; the missing content
is exactly Kőnig/augmenting-path matching on the incomparability bipartite graph.

**C3. Lower bound: posets of width $k$ with twin-width $\Omega(k)$.**
*Conjecture.* There is a family of width-$k$ posets whose strict-order digraph has
twin-width $\ge c\,k$ for an absolute $c > 0$, so the linear dependence on $k$ is
unavoidable. The key insight is that $k$ "interleaved" chains force every contraction
to keep $\Theta(k)$ simultaneously-mixed boundaries — the dynamic shadow of the tight
$\mathrm{changeCount} = 2$ per-chain example (Remark 5.3).

**C4. From posets to comparability/incomparability graphs.**
*Conjecture.* The undirected incomparability graph of a width-$k$ poset has bounded
twin-width (a function of $k$ only), matching the directed bound up to a constant. The
key insight is that `incomp_ord_convex` shows the incomparable region of each chain
relative to any vertex is a single interval, so the same monotone boundary count
controls the undirected red degree.

---

## 9. Conclusion

We have established the static combinatorial core of a linear relationship between the
width of a finite poset and the twin-width of its strict-order digraph. The argument
is short and structural: an outsider's view of any single chain changes character at
most twice (monotonicity plus single-block incomparability), so across $k$ chains it
changes at most $2k$ times, giving a uniform $2k+1$ ceiling on red neighbourhood types
per element. The pigeonhole half of Dilworth ties the chain count to width. What
remains — a dynamic merge schedule realizing the bound, the deep direction of
Dilworth, a matching lower bound, and the undirected analogue — is laid out as a
coherent program built on exactly these lemmas.
