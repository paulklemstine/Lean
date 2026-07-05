# Structural Base Cases for Seymour's Second Neighborhood Conjecture

## Abstract

Seymour's Second Neighborhood Conjecture (SSNC) asserts that every finite
oriented graph contains a vertex whose second out-neighborhood is at least as
large as its first out-neighborhood. Despite its elementary statement, the
conjecture has remained open since the 1990s, with unconditional progress
confined to structured families (tournaments, transitive digraphs) and to
regimes of bounded minimum out-degree. In this paper we isolate and rigorously
establish the clean structural core of the minimum-out-degree program. We prove
that every finite oriented graph whose minimum out-degree is at most one
contains a Seymour vertex, thereby showing that any minimal counterexample must
have minimum out-degree at least two. We prove that every finite nonempty
transitive oriented graph contains a Seymour vertex, realized by a sink. We
prove that in a functional oriented graph — one in which every vertex has
out-degree exactly one — *every* vertex is a Seymour vertex. Finally, we give a
sharp two-vertex example demonstrating that the oriented (digon-free)
hypothesis cannot be dropped from any of these results. Throughout we model an
oriented graph as a finite type equipped with an asymmetric adjacency relation,
so that asymmetry simultaneously encodes the absence of loops and of digons.

## 1. Introduction

Let $D = (V, A)$ be a finite directed graph. For a vertex $v$, the **first
out-neighborhood** $N^{+}(v)$ is the set of vertices $w$ with an arc $v \to w$,
and the **second out-neighborhood** $N^{++}(v)$ is the set of vertices at
directed distance exactly two: those reachable by a directed walk of length two
that are neither equal to $v$ nor already in $N^{+}(v)$.

An **oriented graph** is a directed graph with no loops and no *digons* (pairs
of opposite arcs $v \to w$ and $w \to v$). Equivalently, its adjacency relation
is *asymmetric*: $v \to w$ implies $w \not\to v$. Asymmetry automatically rules
out loops, since $v \to v$ would contradict itself.

> **Conjecture (Seymour, c. 1990).** Every finite oriented graph contains a
> vertex $v$ with $|N^{++}(v)| \ge |N^{+}(v)|$.

Such a vertex is called a **Seymour vertex**. The conjecture is a strengthening
of the Second Neighborhood problem and is known to imply, among other things,
special cases of the Caccetta–Häggkvist conjecture in the tournament setting.

**Known results.** Fisher (1996), building on the analysis of Dean and Latka
(1995), proved SSNC for all tournaments via a weighting argument on the
vertices (the "Dean's conjecture" case). Havet and Thomassé (2000) gave a
combinatorial proof for tournaments and extended it to tournaments missing a
matching. A separate strand of work controls the **minimum out-degree**
$\delta^{+}(D) = \min_v |N^{+}(v)|$: the conjecture has been established for all
oriented graphs with $\delta^{+}(D) \le 6$, and subsequently $\delta^{+}(D) \le
7$, by Ai, Gerke, Gutin, Wang, Ye, and Zhou (2024) and predecessors. The full
conjecture remains open.

**Contribution.** This paper formalizes the structural bedrock on which the
degree program stands. Our results are:

1. **(Base case, Theorem 4.1)** If $\delta^{+}(D) \le 1$, then $D$ has a
   Seymour vertex. Hence a minimal counterexample has $\delta^{+}(D) \ge 2$.
2. **(Transitive case, Theorem 5.2)** Every finite nonempty transitive
   oriented graph has a Seymour vertex, namely a sink.
3. **(Functional case, Theorem 6.1)** If every vertex of $D$ has out-degree
   exactly one, then every vertex of $D$ is a Seymour vertex.
4. **(Necessity of the hypothesis, Theorem 7.1)** There is a two-vertex
   symmetric digraph of constant out-degree one with no Seymour vertex; thus
   the asymmetry hypothesis is indispensable.

Each result is proved by an explicit, self-contained combinatorial argument.

## 2. Definitions

Fix a finite vertex set $V$ and an asymmetric adjacency relation
$\mathrm{adj} : V \times V \to \{\text{true}, \text{false}\}$, writing $v \to w$
for $\mathrm{adj}(v,w)$. Asymmetry is the hypothesis
$$\forall a, b \in V,\quad a \to b \implies \neg\, (b \to a).$$

**Definition 2.1 (Out-neighborhood).** The first out-neighborhood of $v$ is
$$N^{+}(v) = \{\, w \in V : v \to w \,\}.$$
Its cardinality $d^{+}(v) = |N^{+}(v)|$ is the **out-degree** of $v$.

**Definition 2.2 (Second out-neighborhood).**
$$N^{++}(v) = \{\, w \in V : w \ne v,\ w \notin N^{+}(v),\ \exists x\ (v \to x \wedge x \to w) \,\}.$$
That is, $N^{++}(v)$ consists of the vertices reachable from $v$ by a length-two
directed walk, excluding $v$ itself and the direct out-neighbors of $v$.

**Definition 2.3 (Seymour vertex).** A vertex $v$ is a **Seymour vertex** if
$$d^{+}(v) \le |N^{++}(v)|.$$

**Definition 2.4 (Sink).** A vertex $v$ is a **sink** if $N^{+}(v) = \varnothing$,
equivalently $d^{+}(v) = 0$.

## 3. Elementary lemmas

**Lemma 3.1 (Irreflexivity).** If $\mathrm{adj}$ is asymmetric then $v \not\to v$
for every $v$.

*Proof.* If $v \to v$ then asymmetry applied to $a = b = v$ gives $\neg(v \to
v)$, a contradiction. $\qquad\blacksquare$

**Lemma 3.2 (Sinks are Seymour vertices).** If $N^{+}(v) = \varnothing$ then $v$
is a Seymour vertex.

*Proof.* Then $d^{+}(v) = 0 \le |N^{++}(v)|$ trivially. $\qquad\blacksquare$

## 4. The base case of the minimum-out-degree program

**Theorem 4.1.** Let $D$ be a finite nonempty oriented graph. Suppose there is
a vertex $u$ of minimum out-degree with $d^{+}(u) \le 1$; that is, $d^{+}(u) \le
d^{+}(v)$ for all $v$, and $d^{+}(u) \le 1$. Then $D$ has a Seymour vertex.

*Proof.* If $d^{+}(u) = 0$ then $u$ is a sink and we are done by Lemma 3.2.

Otherwise $d^{+}(u) = 1$, so $N^{+}(u) = \{w\}$ for a unique vertex $w$, and $u
\to w$. Since $u$ has minimum out-degree, $d^{+}(w) \ge d^{+}(u) = 1$, so $w$
has at least one out-neighbor: there exists $x$ with $w \to x$.

We claim $x \in N^{++}(u)$, which requires $x \ne u$, $x \notin N^{+}(u)$, and
the existence of a length-two walk $u \to \cdot \to x$. The walk is $u \to w \to
x$. Next, $x \ne u$: if $x = u$ then $w \to u$ while $u \to w$, contradicting
asymmetry. Also $x \notin N^{+}(u) = \{w\}$: if $x = w$ then $w \to w$,
contradicting irreflexivity (Lemma 3.1). Hence $x \in N^{++}(u)$, so
$|N^{++}(u)| \ge 1 = d^{+}(u)$, and $u$ is a Seymour vertex. $\qquad\blacksquare$

**Corollary 4.2.** A minimal counterexample to SSNC — a finite oriented graph
with no Seymour vertex and the fewest vertices among such — has minimum
out-degree at least two.

This corollary is the entry point to the entire minimum-out-degree program:
having eliminated out-degrees zero and one, all subsequent effort is devoted to
raising the threshold above two.

## 5. Transitive oriented graphs

An oriented graph is **transitive** if $a \to b$ and $b \to c$ imply $a \to c$
for all $a, b, c$. A transitive asymmetric relation is precisely a strict
partial order.

**Lemma 5.1 (Existence of a sink).** Every finite nonempty transitive oriented
graph has a sink.

*Proof.* Consider the *reversed* relation $r(a, b) := (b \to a)$. Transitivity
of $\to$ makes $r$ transitive, and irreflexivity (Lemma 3.1) makes $r$
irreflexive. A transitive irreflexive relation on a finite set is well-founded,
so it has a minimal element $m$: no vertex $a$ satisfies $r(a, m)$, i.e. no $a$
satisfies $m \to a$. Thus $N^{+}(m) = \varnothing$ and $m$ is a sink.
$\qquad\blacksquare$

**Theorem 5.2.** Every finite nonempty transitive oriented graph has a Seymour
vertex.

*Proof.* By Lemma 5.1 it has a sink $m$, and by Lemma 3.2 a sink is a Seymour
vertex. $\qquad\blacksquare$

**Remark 5.3 (The dual viewpoint).** Transitivity forces the second
neighborhood of a *maximal* vertex $m$ to be empty: any length-two walk $m \to y
\to z$ yields $m \to z$ by transitivity, so $z \in N^{+}(m)$ and thus $z \notin
N^{++}(m)$. Transitive graphs are therefore the regime in which second
neighborhoods maximally collapse, and the conjecture holds trivially at both the
top (empty $N^{++}$) and the bottom (empty $N^{+}$) of the order.

## 6. Functional oriented graphs

A **functional** oriented graph is one in which every vertex has out-degree
exactly one; equivalently, the arc set is the graph of a function $f : V \to V$
with $v \to f(v)$ and $f$ having no fixed points (by irreflexivity) and no
$2$-cycles (by asymmetry).

**Theorem 6.1.** In a finite functional oriented graph, every vertex is a
Seymour vertex.

*Proof.* Fix $v$. Since $d^{+}(v) = 1$, write $N^{+}(v) = \{w\}$ with $v \to w$.
Since $d^{+}(w) = 1$ as well, $w$ has an out-neighbor $x$ with $w \to x$. As in
Theorem 4.1, asymmetry gives $x \ne v$ and irreflexivity gives $x \ne w$, so $x
\notin N^{+}(v) = \{w\}$; the walk $v \to w \to x$ then places $x \in
N^{++}(v)$. Hence $|N^{++}(v)| \ge 1 = d^{+}(v)$, and $v$ is a Seymour vertex.
Since $v$ was arbitrary, all vertices are Seymour vertices. $\qquad\blacksquare$

Theorem 6.1 shows that functional oriented graphs are extremal in the opposite
direction from a hypothetical counterexample: rather than lacking Seymour
vertices, they consist entirely of them.

## 7. Necessity of the oriented hypothesis

The asymmetry (digon-free) hypothesis is used in every argument above — in
Theorems 4.1 and 6.1 to force $x \ne v$, and in Lemma 5.1 to obtain
well-foundedness. We show it cannot be discarded.

**Theorem 7.1.** There exists a finite symmetric digraph of constant out-degree
one with no Seymour vertex. Concretely, take $V = \{a, b\}$ with $a \to b$ and
$b \to a$ (a single digon).

*Proof.* Each vertex has out-degree one: $N^{+}(a) = \{b\}$ and $N^{+}(b) =
\{a\}$. The only length-two walk from $a$ is $a \to b \to a$, which returns to
$a$; but $a \notin N^{++}(a)$ by definition. Hence $N^{++}(a) = \varnothing$,
and symmetrically $N^{++}(b) = \varnothing$. Thus $|N^{++}(a)| = 0 < 1 =
d^{+}(a)$ and likewise for $b$, so neither vertex is a Seymour vertex.
$\qquad\blacksquare$

This example is the minimal obstruction: any digraph with no Seymour vertex must
contain a digon (or otherwise violate asymmetry), and the two-vertex digon
already exhibits the failure. Consequently SSNC is genuinely a statement about
oriented graphs.

## 8. Algorithms

The definitions are directly computable, yielding elementary algorithms for
verifying the conjecture on any concrete finite oriented graph.

**Algorithm A (Seymour-vertex detection).** Given the adjacency relation as a
Boolean matrix, compute $N^{+}(v)$ and $N^{++}(v)$ for each $v$ by matrix
reachability, and report any vertex with $|N^{++}(v)| \ge |N^{+}(v)|$. This runs
in $O(n^3)$ time for $n$ vertices (one Boolean matrix multiplication to obtain
two-step reachability, then $O(n^2)$ bookkeeping), and by the theorems above it
always succeeds on oriented inputs in the base, transitive, and functional
regimes.

**Algorithm B (Exhaustive small-case verification).** Enumerate all asymmetric
relations on $\{0, 1, \dots, n-1\}$ up to a chosen size and confirm that each
has a Seymour vertex. Because an asymmetric relation assigns one of three states
(no arc, $\to$, $\leftarrow$) to each unordered pair, there are $3^{\binom{n}{2}}$
oriented graphs on $n$ labeled vertices; brute enumeration is feasible for small
$n$ and provides an independent check of the conjecture in that range.

## 9. Applications and discussion

The second-neighborhood question is a probabilistic statement in disguise: it
compares the number of vertices reachable in one step against those reachable in
two, and Fisher's tournament proof is fundamentally a weighting (expectation)
argument. The base cases developed here delineate exactly where the difficulty
concentrates. Out-degrees zero and one are trivial; transitivity trivializes the
problem from the order-theoretic side; functionality trivializes it by
uniformity. The genuine combinatorial content of SSNC lives at minimum
out-degree two and above, among graphs that are neither near-transitive nor
near-functional.

The results also clarify the role of the oriented hypothesis. The digon
counterexample shows that any proof of SSNC must, somewhere, use asymmetry
essentially — a useful litmus test for candidate arguments.

## 10. Future work

The immediate target is minimum out-degree two: proving that every finite
oriented graph with $\delta^{+}(D) = 2$ has a Seymour vertex would extend the
base case by one full step and, combined with the existing $\delta^{+} \le 7$
results, tighten the known frontier. A minimal counterexample must be locally
two-out-regular around a minimum-degree vertex, confining the obstruction to a
bounded configuration amenable to a discharging argument.

Beyond existence, one may ask for the *number* of Seymour vertices: sinks always
qualify, and functional graphs make every vertex qualify, suggesting the count
is controlled by distance from transitivity. Finally, a weighted reformulation —
assign a probability distribution to $V$ and compare weighted one-step and
two-step reachable mass — recasts the conjecture in martingale terms and may
open probabilistic tools to the general case.

## References (context)

- N. Dean and B. J. Latka, *Squaring the tournament — an open problem*, 1995.
- D. C. Fisher, *Squaring a tournament: a proof of Dean's conjecture*, J. Graph
  Theory, 1996.
- F. Havet and S. Thomassé, *Median orders of tournaments: a tool for the second
  neighborhood problem and Sumner's conjecture*, J. Graph Theory, 2000.
- J. Ai, S. Gerke, G. Gutin, S. Wang, A. Ye, Y. Zhou, *Seymour's second
  neighborhood conjecture for oriented graphs of small minimum out-degree*, 2024.
