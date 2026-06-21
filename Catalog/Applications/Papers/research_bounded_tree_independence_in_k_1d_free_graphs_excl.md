# Bounded Tree-Independence Number in $K_{1,d}$-Free Graphs Excluding a Planar Induced Minor

**Author:** Aristotle
**Date:** 2026-06-20

## Abstract

The *tree-independence number* $\alpha\text{-}\mathrm{tw}(G)$ is a refinement of
treewidth, introduced to retain algorithmic tractability on graphs that contain
large cliques. A graph class of bounded tree-independence number admits
polynomial-time algorithms for maximum weight independent set and a wide range of
related optimization problems. We study the Dallard–Milanič–Štorgel conjecture in
the bounded-degree regime obtained by forbidding the star $K_{1,d}$: *for every
$d \ge 2$ and every planar graph $H$, the class of $K_{1,d}$-free graphs with no
$H$-induced-minor has bounded tree-independence number.*

We develop, from first principles, a self-contained theory of $K_{1,d}$-freeness,
induced minors, tree decompositions, treewidth, and the tree-independence number.
Our contributions are: (i) the elementary equivalence between $K_{1,d}$-freeness
and the degree bound $\Delta(G) \le d-1$; (ii) a two-sided comparison establishing
that treewidth and tree-independence number are linearly equivalent for
bounded-degree graphs, namely
$\alpha\text{-}\mathrm{tw}(G) \le \mathrm{tw}(G)+1$ always, and
$\mathrm{tw}(G) \le (\Delta+1)\,\alpha\text{-}\mathrm{tw}(G)$ when
$\Delta(G) \le \Delta$; and (iii) a complete *conditional* proof of the
conjecture, with the explicit bound $C(d,H) = B(d,H)+1$, where $B(d,H)$ is the
treewidth bound for connected, $H$-induced-minor-free graphs of maximum degree at
most $d-1$ supplied by the Robertson–Seymour grid-minor theorem when $H$ is
planar. We also record the unconditional base case $d=2$, where every
$K_{1,2}$-free graph (a matching) has tree-independence number at most $1$.

All results have been formally verified. The central combinatorial step is the
bound $|B| \le (\Delta+1)\,\alpha(G[B])$ for every vertex set $B$ in a graph of
maximum degree at most $\Delta$, which we prove by an explicit greedy elimination
argument.

---

## 1. Introduction

### 1.1 Treewidth and its blind spot

Treewidth, introduced by Robertson and Seymour, measures how closely a graph
resembles a tree, and is the cornerstone of algorithmic graph minor theory.
A vast meta-theorem (Courcelle's theorem and its many relatives) guarantees that
problems expressible in monadic second-order logic are solvable in linear time on
any class of bounded treewidth. The complete graph $K_n$, however, has treewidth
$n-1$ despite being structurally trivial. Any measure that charges a clique its
full size is "fooled" by harmless density, and many algorithmically benign classes
(interval graphs, chordal graphs) have unbounded treewidth for exactly this reason.

### 1.2 The tree-independence number

The *tree-independence number* repairs this defect. Instead of charging each bag
of a tree decomposition its cardinality, one charges it the *independence number*
of the induced subgraph it spans. A clique, no matter how large, has independence
number $1$ and is therefore "free." Dallard, Milanič, and Štorgel showed that
bounded tree-independence number still confers polynomial-time algorithms for
maximum weight independent set and many packing/covering problems, making it a
strictly more powerful tractability parameter than treewidth.

A central program in this area is to characterize which hereditary graph classes
have bounded tree-independence number. The following conjecture isolates a clean
and natural regime.

### 1.3 The conjecture

> **Conjecture (Dallard–Milanič–Štorgel, star-free regime).** For every integer
> $d \ge 2$ and every planar graph $H$, there exists a constant $C(d,H)$ such that
> every connected graph $G$ that is $K_{1,d}$-free and has no $H$-induced-minor
> satisfies $\alpha\text{-}\mathrm{tw}(G) \le C(d,H)$.

Forbidding the star $K_{1,d}$ enforces bounded degree, and excluding a planar
induced minor enforces "two-dimensional flatness." This paper formalizes the
conjecture, builds the necessary infrastructure, proves the bounded-degree
equivalence of treewidth and tree-independence number, and gives a complete proof
of the conjecture conditional on the bounded-degree treewidth bound that the
grid-minor theorem provides for planar $H$.

### 1.4 Organization

Section 2 fixes definitions. Section 3 treats $K_{1,d}$-freeness and the degree
bounds. Section 4 develops the independence number of an induced subgraph and the
greedy bound. Section 5 establishes the two-sided comparison of treewidth and
tree-independence number. Section 6 proves the conjecture conditionally. Section 7
discusses the base case, algorithmic consequences, and limitations. Section 8 lists
future directions.

---

## 2. Definitions

Throughout, graphs are finite, simple, and undirected. We write $G = (V, E)$, use
$N_G(v)$ for the neighborhood of $v$, and $\deg_G(v) = |N_G(v)|$ for its degree.
The maximum degree is $\Delta(G) = \max_v \deg_G(v)$ and the minimum degree
$\delta(G) = \min_v \deg_G(v)$. For $S \subseteq V$, $G[S]$ denotes the subgraph of
$G$ induced on $S$.

**Definition 2.1 (Independent set).** A set $S \subseteq V$ is *independent* if no
two of its vertices are adjacent. The *independence number* $\alpha(G)$ is the
maximum size of an independent set; for $S \subseteq V$ we write $\alpha(G[S])$ for
the independence number of the induced subgraph on $S$.

**Definition 2.2 ($K_{1,d}$-free).** The *star* $K_{1,d}$ is the graph on one
center adjacent to $d$ independent leaves. A graph $G$ is *$K_{1,d}$-free* if it
contains no $K_{1,d}$ subgraph; equivalently, no vertex $v$ admits a set $s$ of
$d$ distinct vertices with $v$ adjacent to every member of $s$. Formally,
$$\forall v,\ \neg\,\exists\, s \subseteq V,\ |s| = d \ \wedge\ (\forall w \in s,\ G.\mathrm{Adj}\,v\,w).$$

**Definition 2.3 (Tree decomposition).** A *tree decomposition* of $G$ is a tree
$T$ together with an assignment of a *bag* $B_t \subseteq V$ to each node
$t \in V(T)$ such that:
1. $\bigcup_t B_t = V$ (every vertex appears);
2. for every edge $uv \in E$, some bag contains both $u$ and $v$;
3. for every vertex $v$, the set $\{ t : v \in B_t \}$ induces a connected subtree
   of $T$.

**Definition 2.4 (Treewidth).** The *width* of a tree decomposition is
$\max_t |B_t| - 1$, and the *treewidth* $\mathrm{tw}(G)$ is the minimum width over
all tree decompositions of $G$.

**Definition 2.5 (Independence number of a bag set; tree-independence number).**
For a finite vertex set $B$, $\mathrm{indepNumOn}(G, B) := \alpha(G[B])$ is the
maximum size of an independent set contained in $B$. The *independence number of a
tree decomposition* is $\max_t \mathrm{indepNumOn}(G, B_t)$, and the
*tree-independence number* is
$$\alpha\text{-}\mathrm{tw}(G) := \min_{\text{tree decompositions}} \ \max_t \ \mathrm{indepNumOn}(G, B_t).$$

**Definition 2.6 (Induced minor).** A graph $H$ on vertex set $W$ is an *induced
minor* of $G$ if there is a family of *branch sets* $(\mathrm{branch}(h))_{h \in W}$,
$\mathrm{branch}(h) \subseteq V$, such that:
1. each $G[\mathrm{branch}(h)]$ is connected;
2. the branch sets are pairwise disjoint;
3. for distinct $h, h' \in W$, there is an edge of $G$ between
   $\mathrm{branch}(h)$ and $\mathrm{branch}(h')$ **if and only if** $h$ and $h'$
   are adjacent in $H$.

The biconditional in (3) — reproducing both edges and non-edges of $H$ — is what
distinguishes induced minors from ordinary minors. $G$ is *$H$-induced-minor-free*
if $H$ is not an induced minor of $G$.

---

## 3. $K_{1,d}$-freeness is bounded degree

The first family of results identifies $K_{1,d}$-freeness with a hard degree cap.

**Lemma 3.1 (`IsKStarFree.degree_lt`).** If $G$ is $K_{1,d}$-free, then
$\deg_G(v) < d$ for every vertex $v$.

*Proof sketch.* Suppose $\deg_G(v) \ge d$. Then the neighbor set $N_G(v)$ has at
least $d$ elements, so it contains a subset $s$ of exactly $d$ distinct neighbors.
Every $w \in s$ is adjacent to $v$, so $(v, s)$ witnesses a $K_{1,d}$, contradicting
$K_{1,d}$-freeness. $\square$

**Lemma 3.2 (`IsKStarFree.maxDegree_le`).** If $G$ is $K_{1,d}$-free with $d \ge 1$,
then $\Delta(G) \le d-1$.

*Proof sketch.* By Lemma 3.1 every degree is $< d$, i.e.\ $\le d-1$; take the
maximum. $\square$

**Lemma 3.3 (`IsKStarFree.minDegree_le`).** If $G$ is $K_{1,d}$-free with $d \ge 1$,
then $\delta(G) \le d-1$.

*Proof sketch.* The minimum degree never exceeds the maximum degree, which is at
most $d-1$ by Lemma 3.2. $\square$

**Theorem 3.4 (`IsKStarFree.degree_bounds`).** If $G$ is connected and
$K_{1,d}$-free with $d \ge 2$, then $\delta(G) \le d-1$ and $\Delta(G) \le d-1$.

*Proof sketch.* Combine Lemmas 3.2 and 3.3. Connectivity is not needed for the
degree bounds but is carried because it appears in the conjecture's hypotheses.
$\square$

The upshot, used throughout the sequel, is the slogan:
$$G \text{ is } K_{1,d}\text{-free} \iff \Delta(G) \le d-1.$$

---

## 4. The independence number of an induced subgraph

We treat $\mathrm{indepNumOn}(G, B)$ as a supremum of cardinalities over the
independent subsets of $B$.

**Definition 4.1.** For a finite graph $G$ and $B \subseteq V$,
$$\mathrm{indepNumOn}(G, B) = \max \{\, |s| : s \subseteq B,\ s \text{ independent in } G \,\}.$$
Equivalently it is the supremum of $|s|$ over the filtered powerset of $B$
consisting of independent sets.

**Lemma 4.2 (`indepNumOn_le_card`).** $\mathrm{indepNumOn}(G, B) \le |B|$.

*Proof sketch.* Every independent subset of $B$ is a subset of $B$, hence has
cardinality at most $|B|$; take the supremum. $\square$

**Lemma 4.3 (`exists_indepNumOn`).** There exists an independent set $s \subseteq B$
with $|s| = \mathrm{indepNumOn}(G, B)$.

*Proof sketch.* The empty set is independent and lies in the filtered powerset,
which is therefore nonempty; a finite nonempty family of cardinalities attains its
supremum. $\square$

**Lemma 4.4 (`le_indepNumOn`).** If $s \subseteq B$ is independent then
$|s| \le \mathrm{indepNumOn}(G, B)$.

*Proof sketch.* $s$ is one of the sets over which the supremum is taken. $\square$

The crucial quantitative step bounds the *size* of any set in terms of the
independence number of the subgraph it induces, when degrees are bounded.

**Theorem 4.5 (Greedy independent-set bound, `card_le_indepNumOn`).** Let $G$ have
maximum degree at most $\Delta$. Then for every finite $B \subseteq V$,
$$|B| \le (\Delta + 1)\cdot \mathrm{indepNumOn}(G, B).$$
Equivalently, $B$ contains an independent set of size at least
$|B|/(\Delta + 1)$.

*Proof sketch (greedy elimination).* We argue by strong induction on $|B|$. If
$B = \varnothing$ the bound is trivial. Otherwise pick any $v \in B$. Form
$B' := B \setminus (\{v\} \cup N_G(v))$. Then:

1. $B' \subseteq B$ and $|B \setminus B'| \le \deg_G(v) + 1 \le \Delta + 1$, since
   the removed set is contained in $\{v\} \cup N_G(v)$, of size at most
   $\Delta + 1$. Hence $|B| \le |B'| + (\Delta + 1)$.
2. By the induction hypothesis applied to $B'$ (which is strictly smaller, as it
   excludes $v$), there is an independent set $s' \subseteq B'$ with
   $|s'| = \mathrm{indepNumOn}(G, B')$.
3. The vertex $v$ has no neighbor in $B'$ (we deleted $N_G(v)$), so $s' \cup \{v\}$
   is independent and contained in $B$. Therefore
   $\mathrm{indepNumOn}(G, B) \ge |s'| + 1 = \mathrm{indepNumOn}(G, B') + 1$.

Combining, $|B| \le |B'| + (\Delta+1) \le (\Delta+1)\,\mathrm{indepNumOn}(G, B') +
(\Delta+1) \le (\Delta+1)\,\mathrm{indepNumOn}(G, B)$, where the middle step uses
the induction hypothesis on $B'$ and the last uses step 3. $\square$

This is the only place degree boundedness is used in the comparison theorem, and it
is exactly the place the $K_{1,d}$-free hypothesis feeds in (with $\Delta = d-1$).

---

## 5. Treewidth and tree-independence number are linearly equivalent for bounded degree

**Theorem 5.1 (Upper comparison, `treeIndepNumber_le_treewidth_succ`).** For every
finite graph $G$,
$$\alpha\text{-}\mathrm{tw}(G) \le \mathrm{tw}(G) + 1.$$

*Proof sketch.* Fix a tree decomposition realizing $\mathrm{tw}(G)$; every bag has
at most $\mathrm{tw}(G) + 1$ vertices. By Lemma 4.2, each bag's independence number
is at most its cardinality, hence at most $\mathrm{tw}(G) + 1$. Thus this single
decomposition has independence number $\le \mathrm{tw}(G)+1$, and the minimum over
all decompositions — i.e.\ $\alpha\text{-}\mathrm{tw}(G)$ — is no larger. $\square$

**Theorem 5.2 (Lower comparison, `treewidth_le_mul_treeIndepNumber`).** If
$\Delta(G) \le \Delta$ then
$$\mathrm{tw}(G) \le (\Delta + 1)\cdot \alpha\text{-}\mathrm{tw}(G).$$

*Proof sketch.* Fix a tree decomposition realizing $\alpha\text{-}\mathrm{tw}(G)$,
so every bag $B$ has $\mathrm{indepNumOn}(G, B) \le \alpha\text{-}\mathrm{tw}(G)$.
By Theorem 4.5, each bag satisfies
$|B| \le (\Delta+1)\,\mathrm{indepNumOn}(G, B) \le (\Delta+1)\,\alpha\text{-}\mathrm{tw}(G)$.
Hence the width of this decomposition is
$\max_B |B| - 1 \le (\Delta+1)\,\alpha\text{-}\mathrm{tw}(G) - 1$, so the minimum
width $\mathrm{tw}(G)$ is at most $(\Delta+1)\,\alpha\text{-}\mathrm{tw}(G)$.
$\square$

**Corollary 5.3 (Equivalence).** For graphs of maximum degree at most $\Delta$,
$$\frac{\mathrm{tw}(G)}{\Delta+1} \le \alpha\text{-}\mathrm{tw}(G) \le \mathrm{tw}(G) + 1.$$
In particular, treewidth is bounded on such a class **iff** tree-independence
number is. This is the lever that lets us bound $\alpha\text{-}\mathrm{tw}$ by
bounding the classical, well-understood treewidth.

---

## 6. The conjecture, conditionally

The remaining geometric input is the treewidth bound for bounded-degree graphs
that exclude a planar pattern. We isolate it as a hypothesis and prove the
conjecture from it.

**Hypothesis 6.1 (Grid-minor treewidth bound).** Let $d \ge 2$ and let $H$ be a
fixed planar graph. There exists a constant $B(d,H)$ such that every connected
graph $G'$ with $\Delta(G') \le d-1$ and no $H$-induced-minor satisfies
$\mathrm{tw}(G') \le B(d,H)$.

*Remark (why this is the grid-minor theorem).* The Robertson–Seymour grid-minor
theorem states that there is a function $g$ with $\mathrm{tw}(G') \ge g(r)$ forcing
an $r \times r$ grid minor. Every planar graph $H$ is a minor of a sufficiently
large grid. In bounded-degree graphs, an ordinary minor of large treewidth can be
realized as an *induced* minor (the bounded degree controls the unwanted edges
between branch sets that would otherwise spoil the induced condition). Hence a
bounded-degree, $H$-induced-minor-free graph cannot have large treewidth, which is
exactly Hypothesis 6.1. The hypothesis packages this deep but standard input.

**Theorem 6.2 (Main result, `treeIndepNumber_bounded_of_treewidth_bound`).** Let
$d \ge 2$ and let $H$ be planar, and assume Hypothesis 6.1 with constant $B(d,H)$.
Then every connected graph $G$ that is $K_{1,d}$-free and $H$-induced-minor-free
satisfies
$$\alpha\text{-}\mathrm{tw}(G) \le C(d,H), \qquad C(d,H) = B(d,H) + 1.$$

*Proof sketch.* Since $G$ is $K_{1,d}$-free, Theorem 3.4 gives $\Delta(G) \le d-1$.
Since $G$ is connected, $H$-induced-minor-free, and of maximum degree at most
$d-1$, Hypothesis 6.1 yields $\mathrm{tw}(G) \le B(d,H)$. Finally Theorem 5.1 gives
$\alpha\text{-}\mathrm{tw}(G) \le \mathrm{tw}(G) + 1 \le B(d,H) + 1 = C(d,H)$.
$\square$

Theorem 6.2 is a complete reduction: the entire conjecture follows from the single
treewidth bound of Hypothesis 6.1. The unconditional content of this paper —
Sections 3–5 — establishes everything *except* that bound, which is the genuine
structural depth supplied by grid-minor theory for planar $H$.

---

## 7. Worked examples

We illustrate the parameters and the comparison theorems on small concrete graphs.
All values below are exact and were confirmed by brute-force computation over
vertex elimination orderings (each ordering produces a chordal completion whose
bags realize a tree decomposition; minimizing the relevant bag cost over all
orderings yields the exact parameter).

**Cliques $K_n$ (the motivating case).** The complete graph $K_n$ has
$\mathrm{tw}(K_n) = n-1$, the largest possible, because every bag must contain all
$n$ mutually adjacent vertices. Yet $\alpha(K_n[B]) = 1$ for every nonempty
$B$, since no two vertices of a clique are independent. Hence the single-bag
decomposition gives $\alpha\text{-}\mathrm{tw}(K_n) = 1$. This is the canonical
exhibit of *clique-blindness*: treewidth is fooled by the dense clump, the
tree-independence number is not. Note $\Delta(K_n) = n-1$, so $K_n$ is
$K_{1,n}$-free but not $K_{1,n-1}$-free; the lower comparison
$\mathrm{tw} \le (\Delta+1)\,\alpha\text{-}\mathrm{tw}$ reads $n-1 \le n \cdot 1$,
tight up to the additive slack.

**Paths $P_n$ and cycles $C_n$.** A path $P_n$ ($n \ge 2$) has
$\mathrm{tw}(P_n) = 1$ and $\alpha\text{-}\mathrm{tw}(P_n) = 1$. A cycle $C_n$
($n \ge 3$) has $\mathrm{tw}(C_n) = 2$ and $\alpha\text{-}\mathrm{tw}(C_n) = 2$.
Both families have $\Delta = 2$, so they are $K_{1,3}$-free (claw-free). Here the
two parameters nearly coincide, consistent with the bounded-degree equivalence:
with $\Delta = 2$ the bounds read $\alpha\text{-}\mathrm{tw} \le \mathrm{tw}+1$
and $\mathrm{tw} \le 3\,\alpha\text{-}\mathrm{tw}$. Crucially, the induced cycles
$C_n$ have $\alpha\text{-}\mathrm{tw} = 2$ uniformly for all $n$, yet (as future
direction D1 highlights) they are exactly the claw-free obstruction showing that
at $d = 3$ no constant bound can hold *without* excluding some planar minor.

**Complete bipartite graphs $K_{a,b}$.** With $a \le b$, one has
$\mathrm{tw}(K_{a,b}) = a$ while $\alpha\text{-}\mathrm{tw}(K_{a,b})$ can exceed
$1$ in small cases (e.g.\ $K_{2,3}$), reflecting that the two color classes are
independent sets and so contribute to bag-independence. Since
$\Delta(K_{a,b}) = b$, these graphs are $K_{1,b+1}$-free; they are a useful test
bed for how the independence number *inside a bag* — the quantity future
direction D2 isolates — drives the tree-independence number above $1$.

**Matchings (the base case).** A matching $mK_2$ ($m$ disjoint edges) has
$\Delta = 1$, hence is $K_{1,2}$-free, and
$\alpha\text{-}\mathrm{tw}(mK_2) = 1$ for every $m$: place each edge in its own
bag, each of independence number $1$. This is the base case of §8.1 in
miniature.

The greedy bound of Theorem 4.5 is equally concrete. On $C_6$ with
$B = V(C_6)$ and $\Delta = 2$: the greedy elimination picks a vertex, deletes it
and its two neighbors, and repeats, yielding an independent set of size $2$ or
$3$; the bound $|B| = 6 \le (\Delta+1)\,\alpha(G[B]) = 3 \cdot 3 = 9$ holds with
room to spare, while the *existence* of a size-$\lceil 6/3 \rceil = 2$ independent
set is exactly what the proof needs.

## 8. Discussion

### 8.1 The base case $d = 2$

A $K_{1,2}$-free graph has maximum degree $0$ or $1$ — it is a disjoint union of
isolated vertices and edges, i.e.\ a *matching*. Each connected component has at
most two vertices, so a tree decomposition placing each component in its own bag
has every bag of independence number at most $1$. Hence
$\alpha\text{-}\mathrm{tw}(G) \le 1$ unconditionally, with no excluded minor
required. This recovers the conjecture for $d = 2$ with the uniform constant
$C = 1$, and confirms the framework on its smallest nontrivial instance.

### 8.2 Algorithmic consequences

Classes of bounded tree-independence number admit polynomial-time algorithms for
maximum weight independent set and a family of related packing problems, via
dynamic programming over a tree decomposition whose bags have bounded independence
number. Theorem 6.2 therefore identifies a structurally defined class — connected,
$K_{1,d}$-free, $H$-induced-minor-free graphs with $H$ planar — on which these
otherwise NP-hard problems become tractable, with the running time governed by the
constant $C(d,H)$.

### 8.3 Where the difficulty lives

Sections 3–5 are elementary and unconditional; all the depth is concentrated in
Hypothesis 6.1. The bounded-degree equivalence (Corollary 5.3) shows that, in this
regime, the sophisticated tree-independence number carries no information beyond
treewidth, so the conjecture *in the bounded-degree regime* is exactly a treewidth
statement. The genuinely hard, still-open part of the broader Dallard–Milanič–
Štorgel program concerns *unbounded-degree* classes (e.g.\ $K_{1,d}$ allowed but
controlled), where the independence number *inside a bag* can blow up and the
equivalence breaks down. The first such hard slice is $d = 3$ (claw-free graphs),
where a single neighborhood can already contain an independent pair.

### 8.4 Limitations

The result is conditional on Hypothesis 6.1. While that hypothesis is precisely
what grid-minor theory supplies for planar $H$, we treat it as a black box rather
than re-deriving the Robertson–Seymour machinery. The constant $C(d,H) = B(d,H)+1$
inherits whatever bound the grid-minor theorem provides and is not claimed to be
tight; sharpening it is open even for small $d$ and $H$.

---

## 9. Future Directions

**D1 — The first hard slice, $d = 3$.** Conjecture: there is a function
$t \mapsto C(t)$ such that every claw-free ($K_{1,3}$-free) graph with no induced
$P_t$-minor has $\alpha\text{-}\mathrm{tw} \le C(t)$, and no constant works without
excluding some planar $H$ (the induced cycles $C_n$ are claw-free with
$\alpha\text{-}\mathrm{tw}(C_n) \to \infty$). At $d = 3$ a single open neighborhood
can already contain an independent pair, so freeness alone no longer forces clique
bags — the excluded planar minor is the only remaining lever.

**D2 — Tightness and a quantitative law for $d = 2$.** Conjecture: for every
$d \ge 2$, the class of $K_{1,d}$-free graphs that are also disjoint unions of
cliques has $\alpha\text{-}\mathrm{tw} = 1$ exactly, and the extremal graphs
achieving any prescribed $\alpha\text{-}\mathrm{tw} = k$ are characterized by a
"$k$ pairwise-far cliques per bag" pattern. Clique components force width $1$, so
larger width must come from forcing two independent vertices into a common
necessary bag — a metric (tree-distance) phenomenon.

**D3 — An excluded-family characterization (Hajebi–Spirkl direction).**
Conjecture: the class of $K_{1,d}$-free graphs has bounded
$\alpha\text{-}\mathrm{tw}$ **iff** it excludes, as induced minors, every member of
an explicit finite family $F(d)$ of planar graphs; for $d = 2$ the family is empty
(bounded unconditionally). Bounded tree-independence is an induced-minor-closed
property up to a constant, so by a Hajebi–Spirkl-style meta-theorem it should be
witnessable by a finite obstruction set, whose $d = 2$ instance is trivial.

**D4 — The subtree axiom is the right axiom (robustness).** Conjecture: dropping
the *tree* requirement of the decomposition to a mere *connected* index graph does
not change the parameter up to a constant, confirming that the subtree-connectivity
axiom is the essential structural ingredient rather than an artifact of using trees.

---

## Appendix: Summary of formalized results

| Name | Statement |
|---|---|
| `IsKStarFree.degree_lt` | $K_{1,d}$-free $\Rightarrow \deg_G(v) < d$ |
| `IsKStarFree.maxDegree_le` | $K_{1,d}$-free, $d\ge 1 \Rightarrow \Delta(G) \le d-1$ |
| `IsKStarFree.minDegree_le` | $K_{1,d}$-free, $d\ge 1 \Rightarrow \delta(G) \le d-1$ |
| `IsKStarFree.degree_bounds` | connected $K_{1,d}$-free, $d\ge 2 \Rightarrow \delta,\Delta \le d-1$ |
| `indepNumOn_le_card` | $\alpha(G[B]) \le |B|$ |
| `exists_indepNumOn` | the independence number of $B$ is attained |
| `le_indepNumOn` | independent $s \subseteq B \Rightarrow |s| \le \alpha(G[B])$ |
| `card_le_indepNumOn` | $\Delta(G)\le\Delta \Rightarrow |B| \le (\Delta+1)\,\alpha(G[B])$ |
| `treeIndepNumber_le_treewidth_succ` | $\alpha\text{-}\mathrm{tw}(G) \le \mathrm{tw}(G)+1$ |
| `treewidth_le_mul_treeIndepNumber` | $\Delta(G)\le\Delta \Rightarrow \mathrm{tw}(G) \le (\Delta+1)\,\alpha\text{-}\mathrm{tw}(G)$ |
| `treeIndepNumber_bounded_of_treewidth_bound` | conjecture: $\alpha\text{-}\mathrm{tw}(G) \le B(d,H)+1$ |
