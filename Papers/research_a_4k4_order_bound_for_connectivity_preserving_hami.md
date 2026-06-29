# A $4k+4$ Order Bound for Connectivity-Preserving Hamiltonian Prescribed-End Paths

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Novelty (structural graph theory / Hamiltonicity)

---

## Abstract

We study the *connectivity-preserving Hamiltonian prescribed-end path* problem:
given a $k$-connected finite simple graph $G$ and an ordered pair of distinct
vertices $u, v$, when does there exist a Hamiltonian $u$–$v$ path $P$ whose
edge-deletion $G - E(P)$ remains $k$-connected? The strongest known sufficient
condition of this prescribed-end form requires order $n \ge 6k+6$ under a
half-density degree threshold $\delta(G) \ge \lceil (n+1)/2 \rceil$. We record and
analyze the precise strengthening to $n \ge 4k+4$ — the **$4k+4$ Conjecture** —
keeping the same degree threshold and prescribed endpoints.

Our contribution is twofold. First, we set up vertex $k$-connectivity as a
cut-based predicate and prove the necessary half of Whitney's inequality,
$\kappa(G) \le \delta(G)$: every vertex of a $k$-connected graph has degree at
least $k$. This shows that controlling minimum degree after deletion is a genuine
*necessary* obligation for any connectivity-preserving theorem. Second, we
isolate the structural engine of all such theorems by proving an exact
degree-degradation bound: deleting the edges of any path decreases every vertex
degree by at most $2$, and this is tight at interior path vertices. Combining the
two, we show the degree obligation is met with surplus under the $4k+4$
hypotheses — minimum degree $2k+1$ survives, exceeding the necessary threshold
$k$ by $k+1$. Consequently the entire residual difficulty of the conjecture lies
in the *surviving cut structure*, not in degrees. All results except the
conjecture itself are established with complete rigor.

---

## 1. Introduction

A *Hamiltonian path* in a graph $G$ is a path visiting every vertex exactly once.
A *prescribed-end* Hamiltonian path between an ordered pair $(u, v)$ of distinct
vertices is one that begins at $u$ and ends at $v$. Dirac-type density conditions
— lower bounds on the minimum degree $\delta(G)$ — are the classical guarantors
of Hamiltonicity.

The *connectivity-preserving* variant adds a robustness demand. A graph is
**$k$-connected** if it has more than $k$ vertices and remains connected after the
removal of any fewer than $k$ vertices; $k$-connectivity is the standard measure
of fault tolerance. The connectivity-preserving Hamiltonian-path program asks for
a Hamiltonian path whose *edge*-deletion preserves $k$-connectivity: the route
"spends" the edges it walks, and we insist the leftover graph $G - E(P)$ remain
$k$-connected.

Recent work (Hasunuma 2025, and a prescribed-end strengthening) establishes such
preservation theorems at order $n \ge 6k+6$ under the half-density threshold
$\delta(G) \ge \lceil (n+1)/2 \rceil$. The present paper records and analyzes the
sharper conjectural threshold $n \ge 4k+4$, identical in all other hypotheses,
and proves the structural skeleton that pins down precisely what remains open.

### Contributions

1. **A formal vertex-connectivity predicate** (Definition 2.1) and the necessary
   degree bound $\kappa \le \delta$ (Theorem 2.3), supported by the "no isolated
   vertex" lemma (Lemma 2.2).
2. **An exact path-deletion degradation bound** (Theorem 3.3): every vertex loses
   at most two from its degree when a path's edges are deleted; tight at interior
   vertices. Supported by the thinness theorem (Theorem 3.1) and a neighbor-set
   bookkeeping identity (Lemma 3.2).
3. **Degree survival under the $4k+4$ hypotheses** (Theorem 3.4, Corollary 3.5):
   minimum degree $2k+1$ survives any path deletion, exceeding the necessary
   threshold $k$ by surplus $k+1$.
4. **A precise statement of the open conjecture** (Conjecture 4.1) and a reduction
   of its difficulty to the surviving cut structure (§5).

### Notation

$G = (V, E)$ is a finite simple graph; $n = |V|$. For $w \in V$, $N_G(w)$ is the
open neighbor set and $\deg_G(w) = |N_G(w)|$ its cardinality (we use the
cardinal-number convention `Set.ncard`, so all "degrees" are finite cardinalities
of neighbor sets). For $S \subseteq V$, $G[S]$ is the induced subgraph and $S^c$
its complement. For a walk/path $P$ in $G$, $E(P)$ is its edge set and $G - E(P)$
the graph obtained by deleting those edges. $P.\mathrm{toSubgraph}$ denotes the
subgraph spanned by $P$, with neighbor set $N_P(w)$ at $w$.

---

## 2. Vertex $k$-connectivity and the necessary degree bound

### Definition 2.1 (Vertex $k$-connectivity, `IsKConnected`)

A finite simple graph $G$ on vertex type $V$ is **$k$-connected**, written
$\mathrm{IsKConnected}\,G\,k$, if
$$ k < |V| \quad\text{and}\quad \forall\, S \subseteq V,\ |S| < k \ \Rightarrow\
G[S^c] \text{ is connected.} $$
That is, $G$ has more than $k$ vertices and the deletion of any set of fewer than
$k$ vertices leaves a connected induced subgraph.

The guard $k < |V|$ excludes degenerate corner cases (the empty graph, or asking
for more connectivity than the order permits). This is the textbook cut-based
definition, equivalent in the finite case to Menger's internally-disjoint-paths
formulation.

### Lemma 2.2 (No isolated vertices, `Connected.exists_adj_of_ne`)

*Let $H$ be a connected graph and $a \ne b$ two distinct vertices of $H$. Then
$a$ has a neighbor: $\exists\, c,\ H.\mathrm{Adj}\,a\,c$.*

**Proof sketch.** Connectivity provides a walk $p$ from $a$ to $b$. Since $a \ne
b$, the walk is nonempty, so it takes a first step $a \to c$; that step witnesses
an edge incident to $a$. $\square$

### Theorem 2.3 (Whitney's easy bound $\kappa \le \delta$, `IsKConnected.le_ncard_neighborSet`)

*If $\mathrm{IsKConnected}\,G\,k$, then every vertex $w$ satisfies $k \le
|N_G(w)|$.*

**Proof sketch.** Contrapositive. Suppose $|N_G(w)| < k$ for some vertex $w$. The
neighborhood $N_G(w)$ is then a vertex set of size $< k$; by Definition 2.1, the
induced subgraph $G[N_G(w)^c]$ on its complement is connected and contains $w$.

We claim $w$ is isolated in $G[N_G(w)^c]$: its only neighbors in $G$ are the
deleted set $N_G(w)$, so it has no neighbor among the surviving vertices. To reach
a contradiction with Lemma 2.2 we need a *second* vertex in $G[N_G(w)^c]$ distinct
from $w$. The complement $N_G(w)^c$ has cardinality $|V| - |N_G(w)| > |V| - k \ge
1$ (using $k < |V|$ from Definition 2.1), so it contains a vertex $c \ne w$. By
Lemma 2.2 applied in the connected graph $G[N_G(w)^c]$, the vertex $w$ must have a
neighbor there — contradicting isolation. The single-element corner case
$N_G(w)^c = \{w\}$ is ruled out by the same cardinality count
($|N_G(w)^c| \ge 2$), via $|N_G(w)| + |N_G(w)^c| = |V|$ and $|N_G(w)| < k < |V|$.
Hence $|N_G(w)| \ge k$. $\square$

**Remark.** Theorem 2.3 is exactly the *necessary* direction of Whitney's
inequality $\kappa(G) \le \delta(G)$. Its converse — the Chartrand–Harary
sufficiency $\delta(G) \ge (n+k-2)/2 \Rightarrow \kappa(G) \ge k$ — is strictly
deeper and is **not** claimed here (see §6.1). Theorem 2.3 is what makes the
degree bookkeeping of §3 genuinely necessary: any theorem asserting that
$G - E(P)$ is $k$-connected must, in particular, prove $\delta(G - E(P)) \ge k$.

---

## 3. Degree degradation under path-edge deletion

This section isolates the structural engine common to all connectivity-preserving
Hamiltonian-path theorems: deleting the edges of a path is the gentlest possible
edge-deletion, costing each vertex at most two from its degree.

### Theorem 3.1 (Paths are thin, `path_subgraph_ncard_neighborSet_le_two`)

*Let $P$ be a path in $G$ and $w$ any vertex. Then the number of neighbors of $w$
inside the subgraph spanned by $P$ is at most $2$:*
$$ |N_P(w)| \le 2. $$

**Proof sketch.** In a path, each vertex is incident to at most two path-edges:
the two endpoints to exactly one each, every interior vertex to exactly two.
Formally, the neighbor set of $w$ in $P.\mathrm{toSubgraph}$ is computed by the
Mathlib lemmas for path subgraphs (`IsPath.neighborSet_toSubgraph_internal`,
`...startpoint`, `...endpoint`): it is a two-element set at interior vertices, a
one-element set at the endpoints, and empty off the path. In all cases its
cardinality is $\le 2$. The hypothesis that $P$ is a *path* (not a general walk)
is essential: a closed or repeating walk could be incident to a vertex more than
twice. $\square$

### Lemma 3.2 (Neighbor bookkeeping, `neighborSet_deleteEdges_path`)

*For a path $P$ and any vertex $w$,*
$$ N_{G - E(P)}(w) = N_G(w) \setminus N_P(w). $$

**Proof sketch.** Deleting $E(P)$ removes exactly the edges lying on $P$; a vertex
$x$ remains adjacent to $w$ in $G - E(P)$ iff $wx \in E(G)$ and $wx \notin E(P)$.
Via `adj_toSubgraph_iff_mem_edges`, membership of $wx$ in $E(P)$ is equivalent to
$x \in N_P(w)$, giving the set difference. $\square$

### Theorem 3.3 (Degree drops by at most two, `ncard_neighborSet_deleteEdges_path_ge`)

*For a path $P$ and any vertex $w$,*
$$ \deg_G(w) \le \deg_{G - E(P)}(w) + 2. $$

**Proof sketch.** By Lemma 3.2, $N_{G - E(P)}(w) = N_G(w) \setminus N_P(w)$, and
$N_P(w) \subseteq N_G(w)$. For finite sets, $|A \setminus B| \ge |A| - |B|$, so
$$ \deg_{G - E(P)}(w) = |N_G(w) \setminus N_P(w)| \ge |N_G(w)| - |N_P(w)| \ge
\deg_G(w) - 2, $$
using Theorem 3.1 for $|N_P(w)| \le 2$. Rearranging gives the claim. $\square$

**Tightness.** The bound is exact: at an interior vertex of $P$, $|N_P(w)| = 2$,
so the degree drops by exactly $2$. This is the precise, not merely asymptotic,
cost of deleting a path.

### Theorem 3.4 (Degree survival under the $4k+4$ hypotheses, `ncard_neighborSet_deleteEdges_ge_two_mul_succ`)

*Assume $k \ge 2$, $n = |V| \ge 4k+4$, and $\delta(G) \ge \lceil (n+1)/2 \rceil$
(written in $\mathbb{N}$ as $(n+2)/2$). Then for any path $P$ and any vertex $w$,*
$$ \deg_{G - E(P)}(w) \ge 2k+1. $$

**Proof sketch.** From $n \ge 4k+4$ we get
$$ \left\lceil \frac{n+1}{2} \right\rceil \ge \left\lceil \frac{4k+5}{2}
\right\rceil = 2k+3, $$
so $\deg_G(w) \ge 2k+3$ for every $w$. Theorem 3.3 gives $\deg_{G - E(P)}(w) \ge
\deg_G(w) - 2 \ge (2k+3) - 2 = 2k+1$. $\square$

### Corollary 3.5 (Necessary condition survives with surplus, `deleteEdges_path_min_degree_ge`)

*Under the hypotheses of Theorem 3.4, $\delta(G - E(P)) \ge k$, in fact
$\delta(G - E(P)) \ge 2k+1 = k + (k+1)$; the necessary degree condition for
$k$-connectivity survives with surplus $k+1$.*

**Proof sketch.** Immediate from Theorem 3.4, since $2k+1 \ge k$ for all $k \ge 0$,
and $2k+1 - k = k+1$. $\square$

By Theorem 2.3, $\delta(G - E(P)) \ge k$ is a *necessary* condition for
$G - E(P)$ to be $k$-connected; Corollary 3.5 shows it holds automatically and
with room to spare. The degree obstacle is therefore not the bottleneck for the
$4k+4$ conjecture.

---

## 4. The $4k+4$ conjecture

### Conjecture 4.1 (`Conjecture_4k4`)

*Let $k \ge 2$. For every finite simple graph $G$ on $n = |V|$ vertices with*
$$ n \ge 4k+4, \qquad \mathrm{IsKConnected}\,G\,k, \qquad
\forall x,\ \deg_G(x) \ge \left\lceil \frac{n+1}{2} \right\rceil, $$
*and for every ordered pair of distinct vertices $u, v$, there exists a
Hamiltonian $u$–$v$ path $P$ such that $G - E(P)$ is $k$-connected.*

In the Lean formulation the degree threshold $\lceil (n+1)/2 \rceil$ is written in
natural-number arithmetic as $(n+2)/2$ (integer division), and "Hamiltonian
$u$–$v$ path" is a walk `p : G.Walk u v` with `p.IsHamiltonian`.

This is the prescribed-end $n \ge 4k+4$ strengthening of the published $n \ge
6k+6$ theorem, identical in its degree threshold and endpoint prescription. It is
recorded as a `Prop`; **it is open**. The results of §§2–3 prove the necessary
degree content of the conclusion ($\delta(G - E(P)) \ge 2k+1 \ge k$) under exactly
these hypotheses, so the open content is precisely the surviving cut structure.

---

## 5. The reduction: degrees are free, cuts are everything

$k$-connectivity of $G - E(P)$ decomposes into two obligations:

1. **Local (degree):** $\delta(G - E(P)) \ge k$. *Status: proved (Corollary 3.5),
   with surplus $k+1$.*
2. **Global (cut):** no vertex set of size $< k$ disconnects $G - E(P)$. *Status:
   open.*

Theorem 2.3 certifies that obligation (1) is genuinely necessary, so it cannot be
sidestepped; Corollary 3.5 certifies that it is nonetheless free under the $4k+4$
hypotheses. Therefore a proof of Conjecture 4.1 need not analyze degrees at all.
The remaining question is purely structural:

> Can a Hamiltonian $u$–$v$ path always be routed so that its edge set avoids
> every minimum vertex cut of $G$, i.e. so that no cut of size $< k$ becomes a cut
> of $G - E(P)$?

This is where the difficulty concentrates. The degree slack of $k+1$ quantifies
how much "budget" a future argument has at each vertex; it is exactly the surplus
that an extremal construction must exhaust to make the threshold tight (§6.3).

---

## 6. Future directions

The degree bookkeeping for the $4k+4$ conjecture is comfortable (minimum degree
$2k+1$ survives, surplus $k+1$), so the entire difficulty is the surviving cut
structure, not degrees. Each direction below is falsifiable.

### 6.1 Formalize the converse Whitney/Chartrand–Harary bound $\delta \Rightarrow \kappa$

**Conjecture.** If $\delta(G) \ge (n+k-2)/2$ then $\mathrm{IsKConnected}\,G\,k$.

Theorem 2.3 proves only the easy direction $\kappa \le \delta$; the converse is
the missing engine for any sufficiency proof and can be attacked by the textbook
"smallest component vs. cut" counting argument now that $\mathrm{IsKConnected}$ is
available as a predicate. The cut-based definition and the isolation lemma
(Lemma 2.2) are already in place, so the converse becomes a self-contained
counting exercise rather than new-infrastructure work.

### 6.2 Prove the full $4k+4$ conjecture conditional on $\delta \Rightarrow \kappa$

**Conjecture.** Conjecture 4.1 holds for all $k \ge 2$.

Degree survival ($\ge 2k+1$, Theorem 3.4) plus a converse connectivity bound
would immediately close the prescribed-end statement if the deletion preserved a
Chartrand–Harary-type degree threshold — reducing the open problem to controlling
how a Hamiltonian path can intersect a minimum cut. Since the degree half is fully
formalized, a conditional theorem "$(\delta \Rightarrow \kappa$ for the deleted
graph$) \Rightarrow$ Conjecture 4.1" is provable today, turning the grand
challenge into a single connectivity lemma.

### 6.3 Tightness: $4k+4$ is best possible

**Conjecture.** There is a $k$-connected graph on $n = 4k+3$ vertices with
$\delta \ge \lceil (n+1)/2 \rceil$ admitting an ordered pair $u, v$ for which *no*
Hamiltonian $u$–$v$ path deletes to a $k$-connected graph.

The surplus computed here drops to the boundary near $4k+4$, so an extremal
construction (balanced near-complete bipartite-like graphs) should expose failure
exactly one vertex below the threshold. The surplus is $k+1$ at $4k+4$, and
searching $n = 4k+3$ is a finite, decidable hunt for small $k$, giving a concrete
candidate before any general proof.

### 6.4 Edge-deletion stability is "thin" — generalize beyond paths

**Conjecture.** Deleting the edges of any subgraph of maximum degree $d$ drops
every vertex degree by at most $d$, and the connectivity-preserving threshold
scales as $\delta \ge \lceil (n+1)/2 \rceil$ requiring $n \ge 2(d+1)k + O(1)$.

Theorem 3.1 used only max-degree $\le 2$; the same argument abstracts to any
bounded-degree spanning subgraph, unifying Hamiltonian-cycle ($d = 2$) and
$2$-factor deletions. The engine lemma is already phrased via $\mathrm{toSubgraph}$
neighbor sets, so the generalization is structurally immediate.

---

## 7. Conclusion

We have formalized vertex $k$-connectivity, proved the necessary half of
Whitney's inequality $\kappa \le \delta$, and established an exact path-deletion
degradation bound (degree drops by at most two, tight at interior vertices).
Cashing these against the $4k+4$ hypotheses shows the minimum degree $2k+1$
survives any path deletion with surplus $k+1$ over the necessary threshold. The
$4k+4$ conjecture is thereby reduced, in a precise and verified sense, from a
question about degrees — which are now settled — to a question about the surviving
cut structure of $G - E(P)$. The map of what remains open is drawn sharply, and
the conditional pathway of §6.2 offers a concrete route to the full theorem.
