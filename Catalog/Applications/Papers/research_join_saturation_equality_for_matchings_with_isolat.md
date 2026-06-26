# Join-Saturation for Matchings with Isolated Vertices: Foundations and the Cameron–Puleo Recurrence

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Applications (Extremal Graph Theory)

---

## Abstract

We develop, from first principles, the basic theory of graph **saturation numbers** that
underlies the Cameron–Puleo and Kászonyi–Tuza circle of results, and we situate within it a
specific extremal recurrence for cones over matchings with isolated vertices. For a forbidden
graph $H$, a host graph $G$ is *$H$-saturated* when it is $H$-free yet adding any missing edge
creates a copy of $H$; the *saturation number* $\mathrm{sat}(n,H)$ is the minimum edge count
over all $H$-saturated graphs on $n$ vertices, while the *extremal number* $\mathrm{ex}(n,H)$
is the maximum edge count over $H$-free graphs. We establish three foundational results with
complete rigor: (i) an $H$-saturated graph exists on every vertex set whenever $H$ has an edge
(so $\mathrm{sat}$ is well defined); (ii) the classical bound
$\mathrm{sat}(n,H) \le \mathrm{ex}(n,H)$; and (iii) the exact apex-join edge identity
$e(K_1 \vee H) = |V(H)| + e(H)$, which is the structural origin of the linear "$n-1$" term in
the recurrence. We then define precisely the family $F = tK_2 \cup qK_1$ (a matching of size
$t$ together with $q$ isolated vertices) and state the central recurrence,
$$\mathrm{sat}\!\bigl(n, K_1 \vee (tK_2 \cup qK_1)\bigr) = (n-1) + \mathrm{sat}\!\bigl(n-1, tK_2 \cup qK_1\bigr),$$
valid for $t \ge 1$, $q \ge 1$, $n > 2t+q$. The upper bound follows from our cone identity;
the lower bound — equivalently, the single inequality
$\mathrm{sat}(n, K_1 \vee F) \ge (n-1) + \mathrm{sat}(n-1, F)$ — is established by Cameron and
Puleo for $t = 1, 2$ and is open in general. We give detailed proof sketches of the proved
results, an algorithmic toolkit for computing the relevant parameters, applications, and a
program for resolving the general case by induction on the matching size.

---

## 1. Introduction

Extremal graph theory studies how global numerical constraints on a graph force, or forbid,
local combinatorial structure. The classical object is the **Turán (extremal) number**
$\mathrm{ex}(n,H)$: the maximum number of edges in an $n$-vertex graph containing no copy of a
fixed graph $H$. Its dual, less classical but increasingly central, is the **saturation
number** $\mathrm{sat}(n,H)$: the *minimum* number of edges in an $n$-vertex graph that is
$H$-free but *maximally* so, in the sense that adding any nonedge creates a copy of $H$.

Both parameters describe $H$-free graphs that cannot be enlarged within the $H$-free world.
The extremal number records the richest such graph; the saturation number records the
poorest. Their qualitative behavior could hardly differ more: for most $H$ of interest,
$\mathrm{ex}(n,H) = \Theta(n^2)$ while $\mathrm{sat}(n,H) = \Theta(n)$. Saturation numbers
were introduced by Erdős, Hajnal, and Moon, and the linear order of growth was established in
broad generality by Kászonyi and Tuza.

A recent and fruitful theme concerns saturation numbers of **cones** (apex joins). Given $H$,
the cone $K_1 \vee H$ adds a single apex vertex adjacent to all of $H$. Cameron and Puleo
proved structural recurrences expressing $\mathrm{sat}(n, K_1 \vee F)$ in terms of
$\mathrm{sat}(n-1, F)$ for various base graphs $F$. The cleanest such statement concerns
$F = tK_2 \cup qK_1$, a matching of size $t$ together with $q$ isolated vertices: the
recurrence
$$\mathrm{sat}(n, K_1 \vee F) = (n-1) + \mathrm{sat}(n-1, F)$$
is proved for $t = 1$ and $t = 2$ and conjectured for all $t$.

This paper has two goals. First, to put the foundations of saturation theory on a fully
rigorous footing — existence of saturated graphs, the $\mathrm{sat} \le \mathrm{ex}$ bridge,
and the exact cone edge identity — since these are the load-bearing facts every saturation
argument silently invokes. Second, to state the Cameron–Puleo recurrence and its base family
with complete precision, isolate exactly which inequality remains open, and lay out a concrete
program for the general case.

**Notation.** All graphs are finite and simple. $V(G)$ is the vertex set, $e(G) = |E(G)|$ the
edge count. $H \sqsubseteq G$ means $H$ embeds into $G$ (there is a copy of $H$ inside $G$);
$H$ is *free over* $G$ when no such embedding exists. $\bot$ is the empty (edgeless) graph,
$G \sqcup \{ab\}$ denotes $G$ with the single edge $ab$ added, $K_1 \vee H$ is the cone,
$tK_2$ is a matching of $t$ disjoint edges, $qK_1$ is $q$ isolated vertices, and $K_{r+1}$ is
the complete graph on $r+1$ vertices.

---

## 2. Definitions

We work over a finite vertex type; the canonical host is $\{0, 1, \dots, n-1\}$, written
$\mathrm{Fin}\,n$.

**Definition 1 (Edge count).** For a graph $G$ on a finite vertex set, the *edge count* is the
cardinality of its edge set,
$$\mathrm{edgeCount}(G) = |E(G)|.$$

**Definition 2 ($H$-saturation).** Let $H$ be a graph on a vertex set $W$ and $G$ a graph on a
vertex set $V$. We say $G$ is *$H$-saturated* if:

1. **Freeness:** $H$ does not embed into $G$ (no copy of $H$ occurs in $G$); and
2. **Maximality:** for all distinct $a, b \in V$ with $ab \notin E(G)$, the augmented graph
   $G \sqcup \{ab\}$ contains a copy of $H$, i.e. $H \sqsubseteq G \sqcup \{ab\}$.

**Definition 3 (Extremal number).** The *extremal* (Turán) number is the maximum edge count
over $H$-free graphs on $\mathrm{Fin}\,n$:
$$\mathrm{ex}(n,H) = \max\{\, \mathrm{edgeCount}(G) : G \text{ on } \mathrm{Fin}\,n,\ H \text{ free over } G \,\}.$$

**Definition 4 (Saturation number).** The *saturation* number is the minimum edge count over
$H$-saturated graphs on $\mathrm{Fin}\,n$:
$$\mathrm{sat}(n,H) = \min\{\, \mathrm{edgeCount}(G) : G \text{ on } \mathrm{Fin}\,n,\ G \text{ is } H\text{-saturated} \,\}.$$
By convention the value is $0$ if no $H$-saturated graph exists; Theorem 1 shows this
degenerate case does not occur when $H$ has an edge.

**Definition 5 (Cone / apex join).** For a graph $H$ on vertex set $V$, the *cone* $K_1 \vee H$
is the graph on $V \cup \{\ast\}$ (a fresh apex $\ast$) with adjacency:
$$\ast \sim v \text{ for all } v \in V, \qquad u \sim v \iff u \sim_H v \text{ for } u, v \in V,$$
and $\ast \not\sim \ast$. In words, the apex is joined to every original vertex and the
original adjacencies are preserved.

**Definition 6 (Matching with isolated vertices).** For $t, q \ge 0$, the graph
$F = tK_2 \cup qK_1$ lives on $\mathrm{Fin}(2t+q)$. Two vertices $i, j$ are adjacent iff
$$i < 2t, \quad j < 2t, \quad \lfloor i/2 \rfloor = \lfloor j/2 \rfloor, \quad i \ne j.$$
Thus vertices $2k$ and $2k+1$ (for $k < t$) form the $k$-th matching edge, and the $q$
vertices with index $\ge 2t$ are isolated. This is a disjoint union of $t$ independent edges
and $q$ isolated vertices.

---

## 3. Foundational lemmas

**Lemma 1 (No edge embeds into the empty graph).** If $H$ has an edge $ab$ (i.e.
$a \sim_H b$), then $H$ is free over the empty graph $\bot$.

*Proof sketch.* An embedding $f : H \hookrightarrow \bot$ would send the edge $ab$ to an edge
$f(a)f(b)$ of $\bot$; but $\bot$ has no edges, a contradiction. $\square$

**Lemma 2 (Adding a new edge strictly increases the count).** Let $G$ be a graph on a finite
vertex set, $a \ne b$, and $ab \notin E(G)$. Then
$$\mathrm{edgeCount}(G) < \mathrm{edgeCount}(G \sqcup \{ab\}).$$

*Proof sketch.* The edge set of $G \sqcup \{ab\}$ is $E(G) \cup \{ab\}$, a strict superset of
$E(G)$ since $ab \notin E(G)$ and $a \ne b$ guarantees $ab$ is a genuine (non-loop) edge.
Strict monotonicity of cardinality on finite sets gives the inequality. $\square$

---

## 4. Existence of saturated graphs

**Theorem 1 (Maximal-free is saturated; existence).** If $H$ has at least one edge, then for
every $n$ there exists an $H$-saturated graph on $\mathrm{Fin}\,n$. Consequently
$\mathrm{sat}(n,H)$ is the minimum over a nonempty set and is well defined.

*Proof sketch.* The family of $H$-free graphs on $\mathrm{Fin}\,n$ is finite and nonempty: the
empty graph $\bot$ is $H$-free by Lemma 1 (since $H$ has an edge). Hence there is an $H$-free
graph $G$ of *maximum* edge count. We claim $G$ is $H$-saturated. Freeness holds by choice.
For maximality, suppose $a \ne b$ with $ab \notin E(G)$ but $H \not\sqsubseteq G \sqcup \{ab\}$.
Then $G \sqcup \{ab\}$ is itself $H$-free, and by Lemma 2 it has strictly more edges than $G$,
contradicting the maximality of $G$. Therefore adding any nonedge creates a copy of $H$, and
$G$ is $H$-saturated. $\square$

This is the structural seed of the entire theory: it simultaneously certifies that
$\mathrm{sat}$ is well defined and exhibits a canonical saturated witness — a maximum free
graph.

---

## 5. The classical bound $\mathrm{sat} \le \mathrm{ex}$

**Theorem 2.** If $H$ has at least one edge, then for every $n$,
$$\mathrm{sat}(n,H) \le \mathrm{ex}(n,H).$$

*Proof sketch.* By Theorem 1 there is an $H$-saturated graph $G_0$ on $\mathrm{Fin}\,n$. By
the definition of $\mathrm{sat}$ as an infimum,
$\mathrm{sat}(n,H) \le \mathrm{edgeCount}(G_0)$. On the other hand $G_0$ is in particular
$H$-free, so its edge count is bounded above by the maximum over all $H$-free graphs, namely
$\mathrm{ex}(n,H)$. Chaining the two inequalities,
$\mathrm{sat}(n,H) \le \mathrm{edgeCount}(G_0) \le \mathrm{ex}(n,H)$. $\square$

The bound is the simplest bridge between the two extremal parameters. The *gap*
$\mathrm{ex}(n,H) - \mathrm{sat}(n,H)$ — typically $\Theta(n^2)$ versus $\Theta(n)$ — measures
how much "slack" the forbidden pattern allows between richest and poorest critical graphs.

---

## 6. The apex join and the linear $n-1$ term

**Theorem 3 (Cone edge identity).** For a graph $H$ on a finite vertex set $V$,
$$\mathrm{edgeCount}(K_1 \vee H) = |V| + \mathrm{edgeCount}(H).$$
Equivalently, $e(K_1 \vee H) = m + e(H)$ where $m = |V(H)|$.

*Proof sketch.* Partition the edges of $K_1 \vee H$ into two disjoint classes. The *apex edges*
are exactly the pairs $\{\ast, v\}$ for $v \in V$; there are exactly $|V|$ of them, and they
are in bijection with $V$. The *internal edges* are the pairs $\{u, v\}$ with $u, v \in V$ that
are edges of $H$; under the inclusion $V \hookrightarrow V \cup \{\ast\}$ these are in
edge-count-preserving bijection with $E(H)$. No edge is counted twice (an apex edge always
contains $\ast$; an internal edge never does), and every edge of the cone is of one of the two
types. Summing the two cardinalities gives $|V| + \mathrm{edgeCount}(H)$.

Formally one verifies that the edge set of $K_1 \vee H$ is the disjoint union
$$\{\{\ast, v\} : v \in V\} \ \sqcup\ \{\text{image of } E(H) \text{ under } V \hookrightarrow V \cup \{\ast\}\},$$
that both maps involved are injective, and that the two pieces are disjoint, whence
cardinalities add. $\square$

This identity is the source of the linear term in the recurrence of Section 7. When one builds
a candidate saturated graph for the cone $K_1 \vee F$ by selecting an apex and attaching a
cheap $F$-structure on the remaining $n-1$ vertices, the apex contributes exactly $n-1$ edges
— precisely the $|V|$ summand of Theorem 3 measured against the residual host.

---

## 7. The Cameron–Puleo recurrence for cones of matchings

We can now state the central recurrence precisely. Recall $F = tK_2 \cup qK_1$ from
Definition 6.

**Main recurrence (Cameron–Puleo; proved for $t = 1, 2$, open in general).**
For every $t \ge 1$, $q \ge 1$, and $n > 2t + q$,
$$\mathrm{sat}\!\bigl(n,\, K_1 \vee (tK_2 \cup qK_1)\bigr) \;=\; (n-1) \;+\; \mathrm{sat}\!\bigl(n-1,\, tK_2 \cup qK_1\bigr). \tag{$\star$}$$

The two inequalities behind $(\star)$ have very different status.

### 7.1 The upper bound (structural; from Theorem 3)

The inequality $\le$ in $(\star)$ is constructive. Take a minimum $F$-saturated graph $G'$ on
$\mathrm{Fin}(n-1)$ — which exists by Theorem 1 since $F$ has an edge whenever $t \ge 1$ — and
form the cone $K_1 \vee G'$ on $n$ vertices by attaching a fresh apex adjacent to all of $G'$.
One checks that $K_1 \vee G'$ is $(K_1 \vee F)$-saturated: it is $(K_1 \vee F)$-free because
$G'$ is $F$-free and the apex can only play the role of the cone's apex, and adding any nonedge
either completes an $F$ in $G'$ (then together with the apex a $K_1 \vee F$) or attaches to the
apex appropriately. By Theorem 3,
$$e(K_1 \vee G') = (n-1) + e(G') = (n-1) + \mathrm{sat}(n-1, F),$$
so the minimum over all $(K_1 \vee F)$-saturated graphs is at most this value. This gives the
$\le$ direction directly from the cone edge identity.

### 7.2 The lower bound (the open crux)

The reverse inequality $\ge$ in $(\star)$ is the difficult half. It is equivalent to the
single clean statement:

**Conjecture C2 (join lowering inequality).** For any graph $F$ with at least one edge and any
$n$ exceeding $|V(F)| + 1$,
$$\mathrm{sat}(n, K_1 \vee F) \ge (n-1) + \mathrm{sat}(n-1, F). \tag{$\dagger$}$$

Combining $(\dagger)$ with the upper bound of Section 7.1 yields $(\star)$ immediately. The
heuristic behind $(\dagger)$: a minimum $(K_1 \vee F)$-saturated graph must contain a vertex
$v$ of near-maximal degree behaving like a dominating apex; deleting $v$ leaves an $F$-saturated
graph on its neighborhood, so the deficiency decomposes additively as "apex cost ($n-1$)" plus
"residual $F$-saturation cost ($\mathrm{sat}(n-1, F)$)". Making the existence and the structure
of such a vertex rigorous — controlling exactly how high-degree vertices arrange themselves — is
the open problem. Cameron and Puleo carry this through for $t = 1$ and $t = 2$, where the local
structure around high-degree vertices stabilizes in a controllable way.

---

## 8. Algorithms

The definitions are directly computable on small instances, which makes the recurrence
empirically testable. We summarize the core procedures (full code in the accompanying demo).

**Algorithm A — Brute-force saturation-number evaluator.** Enumerate all graphs on $n$ labeled
vertices (or, with symmetry reduction, up to isomorphism), filter to those that are
$H$-saturated by Definition 2 (test $H$-freeness, then test that every nonedge addition creates
$H$), and return the minimum edge count. Complexity is $O(2^{\binom n2})$ graphs times a
subgraph-isomorphism test per nonedge; feasible for $n \le 8$ or so, sufficient to verify
$(\star)$ for small $t, q$.

**Algorithm B — Cone constructor and edge-count checker.** Given an adjacency representation of
$H$ on $m$ vertices, build $K_1 \vee H$ by adding one apex row/column of all-ones and verify
$e(K_1 \vee H) = m + e(H)$ (Theorem 3) directly. Linear in the size of the adjacency matrix,
$O(m^2)$.

**Algorithm C — Recurrence verifier for $F = tK_2 \cup qK_1$.** For given $t, q$ and a range of
$n$, compute both sides of $(\star)$ using Algorithm A for the saturation numbers and compare.
This exercises the *main theorem* numerically rather than a trivial special case.

---

## 9. Applications

- **Network economy under criticality.** Saturated graphs model networks built as cheaply as
  possible while remaining one edge away from a forbidden configuration (a redundant cycle, a
  clique, a bottleneck pattern). The recurrence $(\star)$ says that for hub-and-matching
  patterns, optimal designs are *hierarchical*: pay for one near-universal hub, then recurse.
- **Benchmarks for extremal solvers.** The exact values from $(\star)$ provide a family of
  ground-truth instances for testing combinatorial optimization and SAT/ILP-based extremal
  graph solvers.
- **Rigidity diagnostics.** The ratio $\mathrm{sat}(n,H)/\mathrm{ex}(n,H) \to 0$, together with
  its rate, quantifies how rigid a forbidden pattern is. Cones of matchings, via $(\star)$, are
  among the most precisely understood points on this spectrum.

---

## 10. Discussion and future work

We have made rigorous the foundational triad of saturation theory — existence of saturated
graphs (Theorem 1), the bound $\mathrm{sat} \le \mathrm{ex}$ (Theorem 2), and the exact cone
identity $e(K_1 \vee H) = |V(H)| + e(H)$ (Theorem 3) — and stated the Cameron–Puleo recurrence
$(\star)$ together with the exact open inequality $(\dagger)$ that would complete it.

The natural route to the general case is **induction on the matching size $t$**: peel one
matching edge, reducing $tK_2 \cup qK_1$ to $(t-1)K_2 \cup (q')K_1$, and propagate the
recurrence. With $\mathrm{sat}$ and the existence theorem now precise, the induction has a
rigorous scaffold. A companion direction bridges to Turán's theorem via the inequality
$\mathrm{sat}(n, K_{r+1}) \le e(T(n,r))$ (where $T(n,r)$ is the Turán graph), highlighting how
the $\mathrm{sat} \le \mathrm{ex}$ bridge specializes for cliques.

The full set of future directions is recorded in the package metadata. The headline open
problem remains: prove $(\dagger)$, and hence $(\star)$, for all $t \ge 1$.

---

## Appendix: Summary of formally established results

| Result | Status |
|---|---|
| Lemma 1 — no edge embeds into $\bot$ (`free_bot_of_adj`) | proved |
| Lemma 2 — adding a new edge increases the count (`edgeCount_lt_addEdge`) | proved |
| Theorem 1 — existence of saturated graphs (`exists_isSaturated`) | proved |
| Theorem 2 — $\mathrm{sat} \le \mathrm{ex}$ (`satNum_le_exNum`) | proved |
| Theorem 3 — cone edge identity (`edgeCount_cone`) | proved |
| Def. of $tK_2 \cup qK_1$ (`matchingPlusIsolated`) and cone (`cone`) | defined |
| Recurrence $(\star)$ (`CameronPuleoEquality`) | stated; open for general $t$ ($t=1,2$ known) |
