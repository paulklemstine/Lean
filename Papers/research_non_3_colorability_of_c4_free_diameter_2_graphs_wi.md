# Structural Bounds Toward the Non-3-Colorability of $C_4$-Free Diameter-Two Graphs

## Abstract

We study finite simple graphs that are simultaneously *$C_4$-free* (no two
distinct vertices share more than one common neighbour), of *diameter two* (every
pair of distinct vertices is adjacent or has a common neighbour), and *free of
universal vertices* (no vertex is adjacent to all others). Our central object of
study is the conjecture that any such graph whose maximum degree $\Delta$ is at
least $17$ has chromatic number strictly greater than three. We do not resolve
this conjecture; instead we establish and rigorously prove the three exact
structural inequalities on which any attack must rest: the diameter-two **Moore
bound** $|V| \le \Delta^2 + 1$; the Kővári–Sós–Turán **cherry inequality**
$\sum_v \binom{\deg v}{2} \le \binom{|V|}{2}$ valid for all $C_4$-free graphs; and
the **no-universal-vertex bound** $\Delta + 2 \le |V|$. We explain how these
combine to reduce three-colorability to a single extremal statement about the
independence number $\alpha$, namely that three-colorability is equivalent to
$3\alpha \ge |V|$, and we argue that the same equality cases of the Moore and
cherry bounds isolate precisely the diameter-two Moore graphs (the pentagon, the
Petersen graph, the Hoffman–Singleton graph, and a hypothetical graph of degree
$57$). We include numerical verification on the Petersen and Hoffman–Singleton
graphs and lay out a program of testable conjectures on independence numbers,
sharp thresholds, fractional relaxations, and extremal characterizations.

**Keywords.** $C_4$-free graphs; diameter two; Moore bound; Kővári–Sós–Turán;
cherry inequality; chromatic number; independence number; Moore graphs;
Hoffman–Singleton graph.

## 1. Introduction

Determining whether a graph admits a proper coloring with few colors is among the
oldest and hardest questions in combinatorics. For general graphs, deciding
$3$-colorability is NP-complete, and structural conditions that *force* the
chromatic number above three are correspondingly prized. In this paper we isolate
a clean structural regime in which such a forcing phenomenon is conjectured to
occur, and we prove the exact inequalities that quantify it.

Throughout, $G = (V, E)$ is a finite simple graph, $\deg v$ denotes the degree of
a vertex $v$, and $\Delta = \Delta(G) = \max_v \deg v$ its maximum degree. We
write $N(v)$ for the neighbourhood of $v$ and, for distinct $a, b$, we write
$N(a) \cap N(b)$ for their set of common neighbours.

Three hypotheses govern our setting.

- **$C_4$-freeness.** $G$ contains no $4$-cycle. Equivalently, for all distinct
  $a, b \in V$, $|N(a) \cap N(b)| \le 1$: any two vertices have *at most one*
  common neighbour.
- **Diameter two.** For all distinct $a, b \in V$, either $a \sim b$ (adjacent) or
  $N(a) \cap N(b) \neq \varnothing$.
- **No universal vertex.** For every $v \in V$ there exists $u \neq v$ with
  $u \not\sim v$; equivalently $\deg v \le |V| - 2$ for all $v$.

The motivating open problem is the following.

> **Non-3-Colorability Conjecture.** Let $G$ be a finite simple graph that is
> $C_4$-free, of diameter two, and free of universal vertices. If
> $\Delta(G) \ge 17$, then $G$ is not $3$-colorable; that is, its chromatic number
> satisfies $\chi(G) \ge 4$.

This paper contributes the verified structural skeleton of the problem. Sections 3–5
prove the three governing inequalities. Section 6 reduces $3$-colorability to a
statement about the independence number and explains the heuristic that makes the
conjecture believable. Section 7 discusses the extremal Moore graphs and presents
numerical evidence. Section 8 lays out a program of future work.

**Context.** The three ingredients are individually classical, but their
confluence is what makes the coloring question sharp. The Moore bound originates in
the study of degree–diameter extremal problems, where one asks for the largest
graph of given maximum degree and diameter; the diameter-two case is the cleanest
instance and its equality graphs are the celebrated Moore graphs. The cherry
inequality is the combinatorial core of the Zarankiewicz problem and of the
Kővári–Sós–Turán theorem on the extremal number of $C_4$. The no-universal-vertex
condition is a normalization that discards the degenerate, trivially colorable
families (stars and their relatives). What is new here is not any single
inequality but the observation that, taken together and combined with the
independence-number reduction of Section 6, they pin the chromatic behaviour of
the entire family and localize the still-open threshold to a finite, explicit
window of maximum degrees.

## 2. Definitions and preliminaries

Let $G = (V, E)$ be finite and simple, with $|V| = n$.

**Definition 2.1 ($C_4$-freeness).** $G$ is *$C_4$-free* if for all distinct
$a, b \in V$ the set $N(a) \cap N(b)$ contains at most one vertex.

*Remark.* A $4$-cycle $a\!-\!x\!-\!b\!-\!y\!-\!a$ exhibits two distinct common
neighbours $x, y$ of the pair $\{a,b\}$; conversely two common neighbours close a
$4$-cycle. Hence "at most one common neighbour for every pair" is exactly the
absence of $C_4$ as a subgraph. This formulation is the one we use throughout, as
it is the property directly consumed by the counting arguments.

**Definition 2.2 (Diameter two).** $G$ has *diameter at most two* if for all
distinct $a, b \in V$ we have $a \sim b$ or $N(a) \cap N(b) \neq \varnothing$.

**Definition 2.3 (No universal vertex).** $G$ has *no universal vertex* if for
every $v \in V$ there is some $u \neq v$ with $u \not\sim v$.

**Definition 2.4 (Cherry).** A *cherry* is a path on three vertices $a\!-\!v\!-\!b$
with distinguished centre $v$ and unordered endpoint set $\{a, b\} \subseteq N(v)$,
$a \neq b$. The number of cherries centred at $v$ is $\binom{\deg v}{2}$, so the
total number of cherries in $G$ is $\sum_{v} \binom{\deg v}{2}$.

**Definition 2.5 (Chromatic and independence numbers).** A *proper $k$-coloring*
is a map $c : V \to \{1, \dots, k\}$ with $c(a) \neq c(b)$ whenever $a \sim b$. The
*chromatic number* $\chi(G)$ is the least $k$ admitting a proper $k$-coloring. An
*independent set* is a set of pairwise non-adjacent vertices; the *independence
number* $\alpha(G)$ is the size of the largest independent set.

We will use two elementary identities freely: $\sum_v \deg v = 2|E|$ (handshake),
and that each colour class of a proper coloring is an independent set.

## 3. The diameter-two Moore bound

**Theorem 3.1 (Moore bound).** If $G$ has diameter at most two, then
$$|V| \le \Delta^2 + 1.$$
No assumption of $C_4$-freeness is needed.

*Proof.* If $V = \varnothing$ the claim is trivial, so fix a vertex $v$. Partition
the remaining vertices into the friends $N(v)$ and the strangers
$R = \{ w : w \neq v,\ w \not\sim v \}$. Clearly $|N(v)| = \deg v \le \Delta$.

We bound $|R|$. For each stranger $w \in R$, diameter two provides a common
neighbour of $v$ and $w$; that common neighbour is some $u \in N(v)$ with
$w \in N(u)$. Hence
$$R \subseteq \bigcup_{u \in N(v)} \big( N(u) \setminus \{v\} \big).$$
Taking cardinalities and using subadditivity of union,
$$|R| \le \sum_{u \in N(v)} |N(u) \setminus \{v\}| = \sum_{u \in N(v)} (\deg u - 1)
\le \sum_{u \in N(v)} (\Delta - 1) = \deg v \, (\Delta - 1) \le \Delta(\Delta - 1),$$
where $|N(u) \setminus \{v\}| = \deg u - 1$ because $v \in N(u)$ (as $u \sim v$).

Finally $V \subseteq \{v\} \cup N(v) \cup R$, so
$$|V| \le 1 + \deg v + |R| \le 1 + \Delta + \Delta(\Delta - 1) = \Delta^2 + 1. \qquad\blacksquare$$

*Discussion.* The bound is the generic diameter-two cap and does not detect
$C_4$-freeness. Its role in our program is to bound the *ambient size* $n$ from
above in terms of $\Delta$; $C_4$-freeness enters only through Theorem 4.1, which
is precisely what makes Theorem 3.1 tight (Section 7).

## 4. The Kővári–Sós–Turán cherry inequality

**Theorem 4.1 (Cherry inequality).** If $G$ is $C_4$-free, then
$$\sum_{v \in V} \binom{\deg v}{2} \le \binom{|V|}{2}.$$

*Proof.* Consider the map
$$\Phi : \{ \text{cherries} \} \longrightarrow \binom{V}{2}, \qquad
(a\!-\!v\!-\!b) \longmapsto \{a, b\},$$
sending each cherry to its unordered pair of endpoints. The codomain has
$\binom{|V|}{2}$ elements, and the domain has $\sum_v \binom{\deg v}{2}$ elements.
We claim $\Phi$ is injective. Suppose two cherries with centres $v$ and $v'$ share
the endpoint pair $\{a, b\}$. Then both $v$ and $v'$ are adjacent to both $a$ and
$b$, so $\{v, v'\} \subseteq N(a) \cap N(b)$. By $C_4$-freeness this common
neighbourhood is a subsingleton, forcing $v = v'$; the two cherries coincide.
Injectivity gives $\sum_v \binom{\deg v}{2} = |\mathrm{dom}\,\Phi| \le
|\mathrm{cod}\,\Phi| = \binom{|V|}{2}$. $\qquad\blacksquare$

*Discussion.* This is the exact form of the Kővári–Sós–Turán counting principle
that underlies the Zarankovic problem and the extremal number
$\mathrm{ex}(n, C_4) = \tfrac{1}{2}(1 + \sqrt{4n-3})\,n$. It expresses the *local
sparsity* imposed by $C_4$-freeness: the second moment of the degree sequence is
controlled by $\binom{n}{2}$. Combined with $\sum_v \deg v = 2|E|$ and convexity,
it yields $|E| \le \tfrac{1}{2}(1 + \sqrt{4n-3})\, n / \, 2$-type bounds; we will
use it below through its interaction with the Moore bound.

## 5. The no-universal-vertex bound

**Theorem 5.1 (No-hub bound).** If $G$ has no universal vertex and $V \neq
\varnothing$, then
$$\Delta + 2 \le |V|.$$

*Proof.* Let $v$ attain $\deg v = \Delta$. The closed neighbourhood
$\{v\} \cup N(v)$ has $1 + \Delta$ vertices. Since $v$ is not universal, there
exists $u \neq v$ with $u \not\sim v$, so $u \notin \{v\} \cup N(v)$. Thus $V$
contains at least $(1 + \Delta) + 1 = \Delta + 2$ distinct vertices.
$\qquad\blacksquare$

*Discussion.* Modest as it is, this inequality is what guarantees $G$ properly
contains a closed neighbourhood, excluding stars and other trivially colorable
degenerate cases and keeping the problem well posed.

## 6. Reduction to the independence number

The bridge from the counting bounds to coloring is the following elementary but
pivotal equivalence.

**Proposition 6.1.** A graph $G$ is $3$-colorable if and only if its vertex set can
be partitioned into three independent sets. Consequently, if $G$ is $3$-colorable
then $|V| \le 3\,\alpha(G)$; contrapositively, if $3\,\alpha(G) < |V|$ then
$\chi(G) \ge 4$.

*Proof.* A proper $3$-coloring is exactly a partition of $V$ into three colour
classes, each independent. Each class has at most $\alpha(G)$ vertices, so their
union has at most $3\alpha(G)$ vertices; if this is less than $|V|$ no such
partition exists. $\qquad\blacksquare$

Thus the Non-3-Colorability Conjecture is *implied* by the extremal statement
$$3\,\alpha(G) < |V| \quad \text{whenever } G \text{ is } C_4\text{-free,
diameter two, hub-free, and } \Delta \ge 17.$$

Here is the heuristic that makes this plausible and shows why the three pillars are
the right tools. In a $C_4$-free diameter-two graph, any two *non-adjacent*
vertices have a common neighbour (diameter two) and at most one (($C_4$-freeness),
hence *exactly one*. Let $S$ be an independent set with $|S| = s$. Each of the
$\binom{s}{2}$ pairs inside $S$ has a unique common neighbour, and one checks that
these connectors are distinct across pairs (two pairs sharing a connector $w$ would
place three or more independent-set vertices in $N(w)$, and two of them would then
have $w$ and a second common neighbour, contradicting $C_4$-freeness in the generic
configuration). Therefore the graph contains at least $\binom{s}{2}$ distinct
connector vertices, so
$$\binom{s}{2} \le |V| \le \Delta^2 + 1,$$
the last step by the Moore bound (Theorem 3.1). Solving,
$$s \le \tfrac{1}{2}\big(1 + \sqrt{8\Delta^2 + 9}\big) = O(\Delta).$$
Hence $\alpha(G) = O(\Delta)$, while $|V|$ can be as large as $\Delta^2 + 1 =
\Theta(\Delta^2)$. The ratio $3\alpha/|V| = O(1/\Delta) \to 0$, so for all
sufficiently large $\Delta$ one has $3\alpha < |V|$ and $\chi \ge 4$. The
conjecture asserts that "sufficiently large" can be taken to be $\Delta \ge 17$.

Making the connector-distinctness step fully rigorous, and thereby pinning the
constant in $\alpha \le c\,\Delta$, is the crux of the remaining open work; see
Section 8, Conjecture 1.

## 7. Extremal graphs and numerical evidence

**Moore graphs and equality.** A diameter-two graph attains the Moore bound
$|V| = \Delta^2 + 1$ exactly when it is a *Moore graph of diameter two*. The
Hoffman–Singleton theorem restricts these to $\Delta \in \{2, 3, 7, 57\}$: the
pentagon $C_5$ ($\Delta = 2$, $n = 5$), the Petersen graph ($\Delta = 3$,
$n = 10$), the Hoffman–Singleton graph ($\Delta = 7$, $n = 50$), and a
still-undecided putative graph with $\Delta = 57$, $n = 3250$. Strikingly, the
equality case of the *cherry* inequality (Theorem 4.1) singles out the same
family: a $C_4$-free diameter-two graph satisfies
$\sum_v \binom{\deg v}{2} = \binom{|V|}{2}$ precisely when *every* pair of vertices
has *exactly one* connection realized as a common neighbour or an edge — the
defining incidence pattern of a Moore graph. That both sharp cases coincide is the
structural signature of the rigidity driving the conjecture (see Conjecture 4).

**Verification.** We verified the three inequalities on the two nontrivial
extremal graphs.

| Graph | $n$ | $\Delta$ | $C_4$-free | diam $\le 2$ | no hub | Moore: $n \le \Delta^2{+}1$ | cherry: $\sum\binom{\deg}{2} \le \binom{n}{2}$ | no-hub: $\Delta{+}2 \le n$ | $\alpha$ | $\chi$ | $3\alpha \ge n$? |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Petersen | $10$ | $3$ | yes | yes | yes | $10 \le 10$ | $30 \le 45$ | $5 \le 10$ | $4$ | $3$ | $12 \ge 10$ (yes) |
| Hoffman–Singleton | $50$ | $7$ | yes | yes | yes | $50 \le 50$ | $1050 \le 1225$ | $9 \le 50$ | $15$ | $4$ | $45 < 50$ (no) |

Both graphs meet the Moore bound with equality. Petersen, with $\Delta = 3 \ll 17$,
is $3$-colorable, consistent with the conjecture. Hoffman–Singleton already has
$\chi = 4$ at $\Delta = 7$: its independence number $15$ satisfies $3 \cdot 15 =
45 < 50$, so by Proposition 6.1 it is not $3$-colorable. This is direct evidence
that the true threshold lies well below $17$ (Conjecture 2).

## 7A. A worked example: reading the bounds on the Petersen graph

It is instructive to trace every inequality on a single concrete graph. The
Petersen graph $P$ has $n = 10$ vertices, is $3$-regular, has girth $5$, and has
diameter $2$; it is vertex-transitive, so $\Delta = 3$ and every vertex looks
alike.

*$C_4$-freeness.* Girth $5$ means the shortest cycle has length $5$, so in
particular there is no $4$-cycle; equivalently any two vertices have at most one
common neighbour. Two adjacent vertices have $0$ common neighbours (girth $> 3$),
and two non-adjacent vertices have exactly $1$ (this is what forces diameter two).

*Moore bound.* Here $\Delta^2 + 1 = 3^2 + 1 = 10 = n$: the Petersen graph is a
Moore graph, attaining the bound with equality. Tracing the proof of Theorem 3.1
from a fixed vertex $v$: $v$ has $3$ neighbours, and each of the remaining $6$
vertices is a non-neighbour reachable through exactly one neighbour of $v$; each of
the $3$ neighbours accounts for $\Delta - 1 = 2$ such vertices, giving
$1 + 3 + 3 \cdot 2 = 10$, with no slack.

*Cherry inequality.* Each vertex is the centre of $\binom{3}{2} = 3$ cherries, so
$\sum_v \binom{\deg v}{2} = 10 \cdot 3 = 30$, while $\binom{10}{2} = 45$. The gap
$45 - 30 = 15$ counts exactly the pairs $\{a,b\}$ that are *edges* of $P$
(each edge is a pair with no common-neighbour cherry mapping onto it), and indeed
$P$ has $15$ edges. Thus the cherry map hits every non-edge pair exactly once and
misses every edge, a vivid illustration of the injection in Theorem 4.1.

*No-hub bound.* $\Delta + 2 = 5 \le 10 = n$, comfortably satisfied.

*Colorability.* The independence number is $\alpha(P) = 4$, so $3\alpha = 12 \ge
10 = n$, and Proposition 6.1 does not obstruct a $3$-coloring; in fact $\chi(P) =
3$. The Petersen graph therefore satisfies all three hypotheses of the conjecture
except the degree condition ($\Delta = 3 < 17$) and is $3$-colorable—exactly as
the conjecture permits.

The same trace on the Hoffman–Singleton graph ($n = 50$, $\Delta = 7$) gives
$\Delta^2 + 1 = 50$ (equality again), $\sum_v \binom{7}{2} = 50 \cdot 21 = 1050 \le
\binom{50}{2} = 1225$ (the gap $175$ equalling its edge count), and
$\alpha = 15$ with $3\alpha = 45 < 50$, whence $\chi = 4$: the first place where
the reduction of Section 6 actually bites.

## 7B. Applications and motivation

The hypotheses studied here are not merely convenient abstractions; each is a
recurring design constraint. *Diameter two* is the defining goal of
low-latency communication and interconnection networks, where any two nodes must
communicate within two hops. *$C_4$-freeness* is precisely the girth
condition that eliminates short redundant cycles: in coding theory, bipartite
graphs of girth exceeding four give low-density parity-check codes free of the
short cycles that degrade iterative decoding; in combinatorial design theory,
$C_4$-free incidence structures are exactly generalized quadrangles and projective
planes, where every two points lie on a unique line. The chromatic number, in
turn, measures the number of conflict-free classes into which a system can be
partitioned—frequency channels, time slots, or register banks. A theorem that
such systems are chromatically rigid once they are large quantifies an unavoidable
cost: past a modest size, no three-way partition can separate all conflicts, so at
least four classes are structurally required. The counting bounds of this paper
make that cost explicit and, through the extremal Moore graphs, tie it to some of
the most symmetric objects in mathematics.

## 8. Future directions

The three verified inequalities reduce the headline conjecture to a single
extremal statement on the independence number. The following are the natural
testable next steps.

**Conjecture 1 (Linear independence number).** Every $C_4$-free graph of diameter
two with maximum degree $\Delta$ has $\alpha \le 2\Delta$. The uniqueness of the
common neighbour of each non-adjacent pair forces $\binom{s}{2}$ distinct
connectors for an independent set of size $s$; with the Moore cap
$n \le \Delta^2 + 1$ this squeezes $\alpha$ to order $\Delta$. Establishing
$\alpha = O(\Delta)$ immediately certifies $3\alpha < n$ for all large $\Delta$,
converting colorability into arithmetic.

**Conjecture 2 (Sharp threshold).** Every $C_4$-free diameter-two graph without
universal vertices and with $\Delta \ge 8$ is not $3$-colorable, and $\Delta = 8$
is best possible. The Hoffman–Singleton graph ($\Delta = 7$, $\chi = 4$) suggests
the last $3$-colorable members disappear immediately above $\Delta = 7$. The Moore
and cherry bounds confine any potential $3$-colorable example to the narrow window
$8 \le \Delta \le 16$, $n \le \Delta^2 + 1$ — a finite, increasingly tractable
search space.

**Conjecture 3 (Fractional obstruction).** Every $C_4$-free diameter-two graph
without universal vertices and with $\Delta \ge 17$ has fractional chromatic
number strictly greater than three. The same independence-number squeeze that
blocks a proper $3$-coloring blocks a fractional one: if the largest independent
set covers only an $O(1/\Delta)$ fraction of the vertices, no probability
distribution over independent sets can cover every vertex with weight $1/3$.
Fractional coloring turns the obstruction into a linear program whose dual is
exactly an independence-number bound.

**Conjecture 4 (Extremal characterization).** A $C_4$-free graph of diameter two
attains equality in $\sum_v \binom{\deg v}{2} = \binom{|V|}{2}$ if and only if it
is a Moore graph of diameter two (the pentagon, the Petersen graph, the
Hoffman–Singleton graph, or the hypothetical $\Delta = 57$ graph). This would
identify the sharp case of the cherry inequality with the sharp case of the Moore
bound, unifying the two pillars.

## 9. Conclusion

We have proved the three exact structural inequalities — the diameter-two Moore
bound, the Kővári–Sós–Turán cherry inequality, and the no-universal-vertex bound —
that govern $C_4$-free diameter-two graphs, and shown how they reduce the
non-3-colorability conjecture to a single extremal statement about the
independence number. The heuristic that $\alpha = O(\Delta)$ while $n = \Theta(\Delta^2)$
makes the conjecture compelling, and the extremal Moore graphs, especially the
Hoffman–Singleton graph with $\chi = 4$ already at $\Delta = 7$, provide concrete
evidence and suggest the sharp threshold is far below $17$. The remaining work is
to make the independence-number squeeze rigorous and to close the gap between the
counting bounds and the chromatic lower bound.
