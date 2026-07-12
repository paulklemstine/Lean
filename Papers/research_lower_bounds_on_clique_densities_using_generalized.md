# Lower Bounds on Clique Densities via Codegrees and the Inclusion–Exclusion Inverse

## Abstract

We isolate a single elementary inequality — the *inclusion–exclusion inverse*
$\deg(u) + \deg(v) \le n + \operatorname{codeg}(u,v)$ relating the degrees of two
vertices, the order $n$ of the graph, and the number of their common neighbors — and
show that it simultaneously governs three classical phenomena in extremal graph
theory: the existence of triangles, the structure of extremal triangle-free graphs,
and the global count of triangles. From the inverse we derive, in one stroke: (i) a
codegree threshold guaranteeing a common neighbor, hence a **forced triangle**
whenever an edge is *over-heavy* ($\deg(u)+\deg(v) > n$); (ii) **Mantel's local
degree condition**, the contrapositive statement that every edge of a triangle-free
graph is degree-light; (iii) an exact identity expressing six times the triangle
count as a sum of codegrees over ordered adjacent pairs; and (iv) a **Goodman-type
global lower bound** on the triangle count in terms of the degree sequence, obtained
by summing the inverse. We emphasize that the additive formulation
$\deg(u)+\deg(v) \le n + \operatorname{codeg}(u,v)$ is strictly more robust than the
subtractive $\operatorname{codeg}(u,v) \ge \deg(u)+\deg(v)-n$, which becomes vacuous
once its right-hand side truncates to zero. The unifying viewpoint recovers, from one
line of counting, results usually attributed to Mantel (1907), Turán (1941), and
Goodman (1959), and situates them as the $r=3$ base case of the
Bollobás–Khadziivanov–Nikiforov complete-subgraph recursion.

## 1. Introduction

Extremal graph theory asks how a global constraint on a graph — a bound on the number
of edges, a forbidden subgraph, a prescribed density — forces or forbids local
structure. Among its foundational results are three that concern the humblest
nontrivial clique, the triangle:

- **Mantel's theorem (1907)**: a triangle-free graph on $n$ vertices has at most
  $\lfloor n^2/4 \rfloor$ edges, with equality only for the balanced complete
  bipartite graph.
- **Turán's theorem (1941)** and its refinements (Zykov 1949): the generalization to
  $K_r$-free graphs.
- **Goodman's bound (1959)**: a lower bound on the number of triangles in terms of
  the number of edges, showing that edge density forces clustering.

These are usually proved by separate arguments. The purpose of this paper is to show
that all three — in their $r=3$ form — descend from one elementary inequality, the
*inclusion–exclusion inverse*, and that the passage between them is a matter of
reading that inequality forward (existence), by contraposition (extremal structure),
or after summation (global counting).

Throughout, $G$ is a finite simple graph on a vertex set $V$ with $|V| = n$. For a
vertex $u$ we write $N(u)$ for its neighborhood and $\deg(u) = |N(u)|$ for its
degree. Our central auxiliary quantity is the codegree of an ordered pair.

## 2. Definitions

**Definition 2.1 (Codegree).** For vertices $u, v \in V$, the *codegree* of the
ordered pair $(u,v)$ is
$$\operatorname{codeg}(u,v) = |N(u) \cap N(v)|,$$
the number of common neighbors of $u$ and $v$.

The codegree is symmetric, $\operatorname{codeg}(u,v) = \operatorname{codeg}(v,u)$,
since intersection is commutative. Its combinatorial meaning is immediate: a vertex
$w \in N(u) \cap N(v)$ is precisely a vertex adjacent to both $u$ and $v$; if in
addition $u$ and $v$ are adjacent, then $\{u,v,w\}$ is a triangle. Thus for an edge
$uv$, the codegree $\operatorname{codeg}(u,v)$ counts exactly the triangles through
that edge. Codegrees are the local carriers of triangle density.

**Definition 2.2 (Over-heavy and degree-light edges).** An edge $uv$ is
*over-heavy* if $\deg(u) + \deg(v) > n$ and *degree-light* if
$\deg(u) + \deg(v) \le n$.

**Definition 2.3 (Triangle count).** We write $t(G)$ for the number of triangles
(unordered $3$-cliques) in $G$.

## 3. The inclusion–exclusion inverse

**Theorem 3.1 (Inclusion–Exclusion Inverse).** For all $u, v \in V$,
$$\deg(u) + \deg(v) \ \le\ n + \operatorname{codeg}(u,v).$$

*Proof.* The inclusion–exclusion identity for two finite sets gives
$$|N(u) \cup N(v)| + |N(u) \cap N(v)| = |N(u)| + |N(v)| = \deg(u) + \deg(v).$$
Since $N(u) \cup N(v) \subseteq V$, we have $|N(u) \cup N(v)| \le n$. Substituting,
$$\deg(u) + \deg(v) = |N(u) \cup N(v)| + \operatorname{codeg}(u,v) \le n + \operatorname{codeg}(u,v). \qquad \blacksquare$$

**Remark 3.2 (Additive vs. subtractive form).** Rearranged over the integers, Theorem
3.1 reads $\operatorname{codeg}(u,v) \ge \deg(u) + \deg(v) - n$. When
$\deg(u)+\deg(v) \le n$ the right-hand side is nonpositive and the subtractive bound
is vacuous. The additive form $\deg(u)+\deg(v) \le n + \operatorname{codeg}(u,v)$
carries information at every degree profile and is the form used in all subsequent
results; it also sidesteps the pitfalls of truncated subtraction over the natural
numbers.

## 4. Existence: forced triangles

**Theorem 4.1 (Codegree threshold ⇒ common neighbor).** If
$\deg(u) + \deg(v) > n$, then $u$ and $v$ have a common neighbor; that is, there
exists $w$ with $w \in N(u) \cap N(v)$.

*Proof.* By Theorem 3.1, $\operatorname{codeg}(u,v) \ge \deg(u)+\deg(v)-n > 0$, so the
set $N(u) \cap N(v)$ is nonempty. Any of its elements is a common neighbor.
$\blacksquare$

**Theorem 4.2 (Forced Triangle).** If $uv$ is an edge with $\deg(u)+\deg(v) > n$,
then $G$ contains a triangle; in particular $G$ is not triangle-free.

*Proof.* By Theorem 4.1 there is a vertex $w$ adjacent to both $u$ and $v$. Since $uv$
is an edge and $w$ is adjacent to $u$ and to $v$, the three vertices $\{u,v,w\}$ are
pairwise adjacent and form a triangle. $\blacksquare$

**Remark 4.3 (Non-vacuity).** The hypothesis $\deg(u)+\deg(v) > n$ is satisfiable: in
any sufficiently dense graph — for instance a graph with an edge whose endpoints each
have degree exceeding $n/2$ — over-heavy edges exist, and Theorem 4.2 then produces a
genuine triangle. This is the $r=3$ base case of the Bollobás–Khadziivanov–Nikiforov
recursion, in which the same overlap argument applied inside a common neighborhood
forces successively larger complete subgraphs.

## 5. Extremal structure: Mantel's local condition

**Theorem 5.1 (Mantel's Local Degree Condition).** If $G$ is triangle-free, then
every edge $uv$ is degree-light:
$$\deg(u) + \deg(v) \le n.$$

*Proof.* This is the contrapositive of Theorem 4.2. If some edge $uv$ had
$\deg(u)+\deg(v) > n$, then $G$ would contain a triangle, contradicting
triangle-freeness. $\blacksquare$

**Corollary 5.2 (Mantel's theorem).** A triangle-free graph on $n$ vertices has at
most $\lfloor n^2/4 \rfloor$ edges.

*Proof sketch.* Summing the local condition over all edges $uv \in E(G)$ gives
$\sum_{uv \in E} (\deg(u)+\deg(v)) \le n \cdot |E|$. The left-hand side equals
$\sum_{w} \deg(w)^2$ (each vertex $w$ contributes $\deg(w)$ to the degree sum of each
of its $\deg(w)$ incident edges), and by the Cauchy–Schwarz inequality
$\sum_w \deg(w)^2 \ge (\sum_w \deg(w))^2 / n = (2|E|)^2 / n$. Combining,
$(2|E|)^2/n \le n|E|$, hence $|E| \le n^2/4$. Equality analysis forces the balanced
complete bipartite graph $K_{\lfloor n/2\rfloor, \lceil n/2 \rceil}$. $\blacksquare$

Theorem 5.1 is thus the local heart of Mantel's theorem, and by the same route the
$r=3$ case of the Turán/Zykov extremal bound: to keep every edge degree-light while
maximizing edges, one routes all adjacencies across a single balanced cut.

## 6. Global counting: the codegree–triangle identity and Goodman's bound

We now sum the local data over the whole graph.

**Theorem 6.1 (Ordered-Triangle Codegree Identity).** The total codegree over
ordered adjacent pairs counts ordered triples of mutually adjacent vertices, i.e.
$$\sum_{u \in V}\ \sum_{v \in N(u)} \operatorname{codeg}(u,v) \ =\ 6 \, t(G).$$

*Proof.* Expand the left-hand side. For fixed $u$ and $v \in N(u)$,
$\operatorname{codeg}(u,v) = \sum_{w \in N(u) \cap N(v)} 1$. Thus the triple sum
$$\sum_{u}\ \sum_{v \in N(u)}\ \sum_{w \in N(u)\cap N(v)} 1$$
counts ordered triples $(u,v,w)$ such that $v \in N(u)$, $w \in N(u)$, and
$w \in N(v)$ — equivalently, ordered triples of pairwise-adjacent vertices, i.e.
ordered triangles. Each unordered triangle $\{a,b,c\}$ arises from exactly
$3! = 6$ such ordered triples. Hence the sum equals $6\,t(G)$. $\blacksquare$

**Theorem 6.2 (Goodman-type Codegree Lower Bound).** Summing the inclusion–exclusion
inverse over all ordered adjacent pairs yields
$$\sum_{u \in V}\ \sum_{v \in N(u)} \bigl(\deg(u) + \deg(v)\bigr) \ \le\ \Bigl(\sum_{u \in V}\ \sum_{v \in N(u)} n\Bigr) + 6\, t(G).$$

*Proof.* Apply Theorem 3.1 termwise: for each ordered adjacent pair $(u,v)$,
$\deg(u)+\deg(v) \le n + \operatorname{codeg}(u,v)$. Summing over all such pairs and
invoking Theorem 6.1 to replace $\sum_u \sum_{v\in N(u)} \operatorname{codeg}(u,v)$ by
$6\,t(G)$ gives the claim. $\blacksquare$

**Remark 6.3 (Recovering Goodman's classical form).** The inner constant sum is
explicit: $\sum_u \sum_{v \in N(u)} n = n \sum_u \deg(u) = 2n|E|$. The left-hand side
is $\sum_u \sum_{v\in N(u)} (\deg u + \deg v) = \sum_u \deg(u)^2 + \sum_u \sum_{v \in
N(u)} \deg(v) = 2\sum_u \deg(u)^2$ (both terms equal $\sum_w \deg(w)^2$ by symmetry of
adjacency). Hence Theorem 6.2 reads $2\sum_w \deg(w)^2 \le 2n|E| + 6\,t(G)$, i.e.
$$t(G) \ \ge\ \frac{1}{3}\Bigl(\sum_{w} \deg(w)^2 - n|E|\Bigr).$$
Applying Cauchy–Schwarz ($\sum_w \deg(w)^2 \ge 4|E|^2/n$) gives the familiar Goodman
lower bound
$$t(G) \ \ge\ \frac{|E|\,(4|E| - n^2)}{3n},$$
which is positive — forcing triangles — as soon as $|E| > n^2/4$, precisely the
Mantel threshold. The qualitative existence statement and the quantitative counting
statement thus meet at the same critical density.

## 7. Algorithms

The results above are constructive and translate directly into efficient procedures.
We record three.

**Algorithm A (Codegree matrix).** Compute $\operatorname{codeg}(u,v)$ for all pairs
by intersecting adjacency bitsets. For a graph on $n$ vertices with adjacency rows
stored as $n$-bit words, each intersection cardinality costs $O(n/w)$ machine words,
giving $O(n^3/w)$ overall — the standard cost of a bitset triangle routine.

**Algorithm B (Over-heavy edge scan / triangle certificate).** Scan every edge $uv$;
if $\deg(u)+\deg(v) > n$, Theorem 4.1 guarantees a common neighbor, which is found by
scanning $N(u) \cap N(v)$ for its first element $w$, yielding an explicit triangle
$\{u,v,w\}$. This is a linear-time-per-edge witness generator that certifies
non-triangle-freeness.

**Algorithm C (Goodman bound evaluator).** From the degree sequence alone, compute
the lower bound $\frac{1}{3}(\sum_w \deg(w)^2 - n|E|)$ and its Cauchy–Schwarz
weakening $\frac{|E|(4|E|-n^2)}{3n}$, and compare against the exact triangle count
obtained from the codegree identity of Theorem 6.1.

## 8. Applications

**Clustering guarantees in networks.** In a social or communication network with $n$
nodes, any pair of hubs whose combined degree exceeds $n$ is guaranteed a common
contact — a triadic closure that no adversary can avoid. The Goodman bound quantifies
this at scale: a network with more than $n^2/4$ links must contain a positive,
computable number of triangles, so high connectivity mechanically produces
clustering.

**Certifying density thresholds.** The over-heavy-edge scan gives a fast one-sided
test: finding a single over-heavy edge certifies a triangle without enumerating
triples. This is useful as a cheap pre-filter before expensive clique searches.

**Extremal design.** Mantel's local condition tells a designer wishing to *avoid*
triangles that every link must be placed so that its endpoints' degrees sum to at most
$n$; the balanced bipartite construction is the unique way to do this at maximum
density.

## 9. Discussion

The organizing principle of this work is that a single inequality, obtained by
inverting inclusion–exclusion against the trivial ceiling $|N(u)\cup N(v)| \le n$,
controls existence, extremal structure, and counting for triangles. Its three uses
are logically distinct — a forward implication, a contrapositive, and a summation —
but mathematically identical in content. The additive formulation is essential: it
remains informative precisely where the subtractive codegree bound goes vacuous, and
it interfaces cleanly with summation because no truncation intervenes.

The framework also clarifies *where the slack lives*. The only inequality invoked is
$|N(u) \cup N(v)| \le n$; equality holds exactly when the two neighborhoods cover the
whole vertex set. Consequently the deficit in the Goodman bound is governed by the
average gap $n - |N(u)\cup N(v)|$ over adjacent pairs, a quantity that vanishes when
neighborhoods overlap as in a quasi-random graph.

## 10. Future work

Four directions extend the codegree-centered viewpoint. First, a **codegree tensor
inverse** for $K_r$: for each $r \ge 3$ one seeks an $(r-1)$-linear inequality
bounding the number of common neighbors of an $(r-1)$-clique below by an alternating
sum of sub-clique degrees, with signs given by the Möbius function of the intersection
lattice of neighborhoods; the pairwise inverse is the $r=3$ slice. Second,
**stability of the forced-triangle threshold**: a triangle-free graph possessing an
edge on the equality locus $\deg(u)+\deg(v)=n$ must, we conjecture, be within bounded
edit distance of a complete bipartite graph, since equality forces $N(u)\cup N(v)$ to
cover $V$. Third, **tightness of the Goodman bound along a spectral family**: the
bound should be attained up to lower-order terms exactly by near-regular quasi-random
graphs, with deficit proportional to the variance of the degree sequence. Fourth,
**threshold cascades for higher cliques**: a degree-sum overshoot iterated across
nested common neighborhoods should force a $K_r$ whose order grows with the size of
the overshoot, giving effective "book" lower bounds.

## References

- W. Mantel, *Problem 28*, Wiskundige Opgaven **10** (1907), 60–61.
- P. Turán, *On an extremal problem in graph theory*, Mat. Fiz. Lapok **48** (1941),
  436–452.
- A. A. Zykov, *On some properties of linear complexes*, Mat. Sbornik **24** (1949),
  163–188.
- A. W. Goodman, *On sets of acquaintances and strangers at any party*, Amer. Math.
  Monthly **66** (1959), 778–783.
- B. Bollobás, *On complete subgraphs of different orders*, Math. Proc. Cambridge
  Philos. Soc. **79** (1976), 19–24.
- N. Khadziivanov and V. Nikiforov, *Solution of a problem of P. Erdős about the
  maximum number of triangles*, (1978).
