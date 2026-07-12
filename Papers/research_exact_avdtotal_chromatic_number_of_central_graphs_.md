# Adjacent-Vertex-Distinguishing Total Colourings of Central Graphs of Regular Graphs

## Abstract

For a finite simple graph $G$, the *central graph* $C(G)$ is obtained by subdividing every edge of $G$ exactly once and then joining every pair of vertices that are non-adjacent in $G$. We study the *adjacent-vertex-distinguishing (AVD) total chromatic number* $\chi''_a(C(G))$ when $G$ is regular. A guiding conjecture in the literature predicts $\chi''_a(C(G)) = d+3$ for every $d$-regular non-complete graph $G$ (with $\chi''_a(C(K_{d+1})) = d+2$). We show this conjecture is false in general. The key structural fact is that every original vertex of $C(G)$ has degree $|V(G)|-1$, so any two vertices that are non-adjacent in $G$ become adjacent maximum-degree vertices in $C(G)$. A general obstruction — two adjacent vertices of equal maximum degree cannot be distinguished with only $\Delta+1$ colours — then yields the unconditional lower bound
$$\chi''_a(C(G)) \ge |V(G)| + 1$$
for every non-complete graph $G$. Writing $n = |V(G)|$, for regular non-complete $G$ we have $n \ge d+2$, so this bound meets $d+3$ only at the boundary $n = d+2$ and strictly exceeds it whenever $n > d+2$; the pentagon $C_5$ is an explicit counterexample with $\chi''_a(C(C_5)) \ge 6 > 5$. In the complete case $C(K_n)$ the original (maximum-degree) vertices form an independent set, which is precisely the structural reason the argument does not apply. Collecting both cases, we conjecture the unified exact value $\chi''_a(C(G)) = n+1$ for all regular $G$, and confirm it on small instances, e.g. $\chi''_a(C(K_3)) = 4$. We prove the lower-bound half in full and isolate the missing upper-bound constructions as the remaining open problem.

**Keywords:** total colouring, adjacent-vertex-distinguishing total colouring, central graph, regular graph, chromatic number, graph subdivision.

## 1. Introduction

Colouring problems that treat vertices and edges *simultaneously* occupy a central place in graph theory. A **total colouring** of a graph $H$ assigns colours to both the vertices and the edges of $H$ so that (i) adjacent vertices receive distinct colours, (ii) adjacent edges (edges sharing an endpoint) receive distinct colours, and (iii) incident vertex–edge pairs receive distinct colours. The **total chromatic number** $\chi''(H)$ is the least number of colours in a total colouring. The celebrated *Total Colouring Conjecture* of Behzad and Vizing asserts $\chi''(H) \le \Delta(H) + 2$, where $\Delta(H)$ is the maximum degree; it remains open in general.

A refinement adds a *distinguishing* requirement. Given a total colouring, the **colour set** of a vertex $w$ is
$$S(w) = \{\, \text{colour of } w \,\} \cup \{\, \text{colour of } e : e \text{ is incident to } w \,\}.$$
A total colouring is **adjacent-vertex-distinguishing (AVD)** if $S(u) \ne S(v)$ for every edge $uv$. The **AVD total chromatic number** $\chi''_a(H)$ is the least number of colours in an AVD total colouring. Because in any proper total colouring the colours appearing on a vertex and its incident edges are pairwise distinct (they form a clique in the associated "total graph", see §3), we always have $|S(w)| = \deg(w) + 1$; the distinguishing constraint forces neighbours to differ as *sets*, which can be expensive precisely when neighbours have equal degree.

The **central graph** $C(G)$ of a graph $G$ is a classical derived graph obtained by subdividing each edge once and then adding an edge between each pair of vertices that are non-adjacent in $G$. Central graphs of standard families (paths, cycles, complete graphs, complete bipartite graphs, wheels, and so on) have been extensively studied for various colouring parameters. For the AVD total chromatic number of central graphs of *regular* graphs, the following conjecture has circulated:

> **Conjecture (guiding).** For every $d$-regular graph $G$ with $d \ge 2$ that is not complete, $\chi''_a(C(G)) = d+3$; and $\chi''_a(C(K_{d+1})) = d+2$.

Our purpose is threefold: (1) to develop a small self-contained theory of total and AVD total colourings; (2) to compute the degree structure of central graphs and derive an unconditional lower bound; and (3) to show that the guiding conjecture is incorrect once $|V(G)| > d + 2$, replacing it with a cleaner conjecture governed by $n = |V(G)|$ rather than $d$.

## 2. Definitions

Throughout, graphs are finite and simple. For a graph $H$ we write $V(H)$, $E(H)$, $\deg_H$, and $\Delta(H)$ for its vertex set, edge set, degree function, and maximum degree.

**Definition 2.1 (Total graph).** The *total graph* $T(H)$ has vertex set $V(H) \sqcup E(H)$ (the disjoint union of the vertices and the edges of $H$). Two elements are adjacent in $T(H)$ when
- both are vertices of $H$ and are adjacent in $H$; or
- both are edges of $H$ and share an endpoint; or
- one is a vertex $x$ and the other is an edge $e$ with $x \in e$ (incidence).

A total colouring of $H$ is exactly a proper vertex colouring of $T(H)$, and $\chi''(H) = \chi(T(H))$.

**Definition 2.2 (Colour set, AVD).** Given a proper colouring $c$ of $T(H)$, the *colour set* of a vertex $w \in V(H)$ is $S(w) = \{c(w)\} \cup \{ c(e) : e \in E(H),\ w \in e \}$. The colouring is *adjacent-vertex-distinguishing* if $S(u) \ne S(v)$ for every edge $uv \in E(H)$. Then $\chi''_a(H)$ is the least number of colours in an AVD total colouring.

**Definition 2.3 (Central graph).** The *central graph* $C(G)$ has vertex set $V(G) \sqcup E(G)$; we call the elements of $V(G)$ *original vertices* and the elements of $E(G)$ *subdivision vertices*. Adjacency is:
- two original vertices $u, w$ are adjacent in $C(G)$ iff $u \ne w$ and $uw \notin E(G)$ (i.e. non-adjacent in $G$);
- an original vertex $u$ and a subdivision vertex $e$ are adjacent iff $u \in e$;
- two subdivision vertices are never adjacent.

## 3. The star clique and the total-chromatic lower bound

Fix a graph $H$ and a vertex $w \in V(H)$. The **closed star** of $w$ consists of $w$ together with all edges incident to $w$. Inside $T(H)$ these are pairwise adjacent: $w$ is incident to each of its edges, and any two edges at $w$ share the endpoint $w$.

**Lemma 3.1 (Star clique).** For every vertex $w$, the closed star of $w$ is a clique of $T(H)$ of size $\deg_H(w) + 1$.

*Proof sketch.* There are $\deg_H(w)$ edges incident to $w$, plus $w$ itself, giving $\deg_H(w)+1$ elements. Pairwise adjacency in $T(H)$ is checked by cases: vertex–edge pairs are incident; two edges at $w$ share $w$. $\square$

**Corollary 3.2 (Maximum-degree lower bound).** $\chi''(H) = \chi(T(H)) \ge \deg_H(w)+1$ for every $w$; in particular $\chi''(H) \ge \Delta(H)+1$.

*Proof sketch.* A clique of size $k$ forces at least $k$ colours in any proper colouring. $\square$

**Lemma 3.3 (Palette saturation).** If a proper colouring of $T(H)$ uses exactly $\deg_H(w)+1$ colours, then $S(w)$ equals the entire palette.

*Proof sketch.* The $\deg_H(w)+1$ elements of the closed star are pairwise adjacent, hence receive pairwise distinct colours; there are exactly that many colours available, so all of them occur on the star, i.e. $S(w)$ is everything. $\square$

## 4. The adjacent equal-degree obstruction

The following is the crux. It expresses why *distinguishing* neighbours of equal maximum degree costs an extra colour.

**Theorem 4.1 (Adjacent equal-degree obstruction).** Let $u, v$ be adjacent vertices of $H$ with $\deg_H(u) = \deg_H(v) = \Delta(H)$. Then no AVD total colouring of $H$ uses only $\Delta(H)+1$ colours. Equivalently, $\chi''_a(H) \ge \Delta(H) + 2$.

*Proof.* Suppose a proper colouring of $T(H)$ uses exactly $\Delta(H)+1 = \deg_H(u)+1 = \deg_H(v)+1$ colours. By Lemma 3.3 applied to $u$ and to $v$, both $S(u)$ and $S(v)$ equal the full palette, so $S(u) = S(v)$. Since $u$ and $v$ are adjacent, the AVD condition is violated. Hence any AVD total colouring needs at least $\Delta(H)+2$ colours. $\square$

## 5. Degree structure of the central graph

We now specialise to $H = C(G)$, with $n = |V(G)|$.

**Theorem 5.1 (Subdivision degree).** Every subdivision vertex of $C(G)$ has degree $2$.

*Proof sketch.* A subdivision vertex $e = \{a,b\}$ is adjacent exactly to the two original vertices $a$ and $b$ (its endpoints), and to no other vertex (subdivision vertices are mutually non-adjacent, and $e$ is incident to no original vertex outside $\{a,b\}$). $\square$

**Theorem 5.2 (Original-vertex degree).** Every original vertex $u$ of $C(G)$ has degree $n-1$; equivalently $\deg_{C(G)}(u) + 1 = n$.

*Proof.* Partition the other $n-1$ original vertices $w \ne u$ into neighbours and non-neighbours of $u$ in $G$. If $w$ is a non-neighbour of $u$ in $G$, then $uw$ is an edge of $C(G)$, contributing one incidence. If $w$ is a neighbour of $u$ in $G$, then $u$ is adjacent in $C(G)$ to the subdivision vertex $\{u,w\}$; distinct neighbours $w$ give distinct subdivision vertices. Thus $u$ has exactly $|\{w : uw \notin E(G)\}|$ original-vertex neighbours and exactly $\deg_G(u)$ subdivision-vertex neighbours, totalling $(n-1-\deg_G(u)) + \deg_G(u) = n-1$. $\square$

**Corollary 5.3 (Maximum degree).** For $n \ge 3$, $\Delta(C(G)) = n-1$, attained by every original vertex.

*Proof sketch.* Original vertices have degree $n-1 \ge 2$, subdivision vertices have degree $2$; the maximum is $n-1$. $\square$

**Theorem 5.4 (Complete-graph independence).** In $C(K_n)$ the original vertices form an independent set.

*Proof.* Any two distinct original vertices are adjacent in $K_n$, hence non-adjacent in $C(K_n)$ by Definition 2.3. $\square$

## 6. Lower bounds for central graphs

**Theorem 6.1 (Total lower bound).** For any $G$ with $n = |V(G)| \ge 1$ and any vertex, $\chi''(C(G)) \ge n$.

*Proof.* By Corollary 3.2 applied to an original vertex $u$, $\chi''(C(G)) \ge \deg_{C(G)}(u)+1 = n$ using Theorem 5.2. $\square$

**Theorem 6.2 (Main AVD lower bound).** If $G$ is not complete — that is, there exist distinct $a, b \in V(G)$ with $ab \notin E(G)$ — then
$$\chi''_a(C(G)) \ge n + 1.$$

*Proof.* Since $ab \notin E(G)$, the original vertices $a$ and $b$ are adjacent in $C(G)$ by Definition 2.3. By Theorem 5.2 both have degree $n-1 = \Delta(C(G))$ (Corollary 5.3). Theorem 4.1 with $u=a$, $v=b$ then gives $\chi''_a(C(G)) \ge (n-1)+2 = n+1$. $\square$

**Corollary 6.3 (Refutation of the guiding conjecture).** Let $G$ be $d$-regular ($d \ge 2$) and not complete, with $n = |V(G)|$. Then $\chi''_a(C(G)) \ge n+1$. Since regularity and non-completeness force $n \ge d+2$, the guiding value $d+3$ is correct at best only in the boundary case $n = d+2$, and is strictly too small whenever $n > d+2$.

*Proof.* Each vertex of a $d$-regular non-complete $G$ has at least one non-neighbour, so $n - 1 - d \ge 1$, i.e. $n \ge d+2$ and $n+1 \ge d+3$, with equality iff $n = d+2$. Theorem 6.2 supplies $\chi''_a(C(G)) \ge n+1$. $\square$

**Example 6.4 (The pentagon).** For $G = C_5$ (the $5$-cycle, $2$-regular, $n=5$), the guiding conjecture predicts $\chi''_a(C(C_5)) = d+3 = 5$. Each vertex of $C_5$ has two non-neighbours, so Theorem 6.2 gives $\chi''_a(C(C_5)) \ge 6 > 5$: no AVD total colouring of $C(C_5)$ uses only $5$ colours, contradicting the conjecture.

## 7. A unified conjecture and small-case evidence

Theorem 5.4 explains why complete graphs escape the obstruction: the maximum-degree (original) vertices are mutually non-adjacent, so Theorem 4.1 never applies to a pair of them. This is exactly the hypothesis "$G$ is not complete" of Theorem 6.2. Moreover, for $K_{d+1}$ we have $n = d+1$, and the classically expected value $d+2$ equals $n+1$. Both the non-complete lower bound and the complete case therefore point to the same quantity:

> **Conjecture 7.1 (Unified exact value).** For every regular graph $G$ with $n = |V(G)| \ge 3$,
> $$\chi''_a(C(G)) = n + 1.$$

The results of §§3–6 establish the lower-bound inequality $\chi''_a(C(G)) \ge n+1$ for all non-complete $G$ (and $\ge n$ for the total chromatic number in general). What remains is the matching upper bound: an explicit AVD total colouring of $C(G)$ with $n+1$ colours. Such constructions typically require Behzad/Vizing-style total-colouring machinery adapted to the two-layer structure of $C(G)$.

**Example 7.2 (An exact small value).** For $G = K_3$, the central graph $C(K_3)$ has no non-adjacent pair to complete, three subdivision vertices, and each original vertex of degree $2$; in fact $C(K_3)$ is isomorphic to the $6$-cycle $C_6$. An exhaustive search over proper total colourings shows that its AVD total chromatic number is exactly $4$, matching $n+1 = 4$. This is consistent with the complete-case value $d+2 = 4$ (here $d = 2$), confirming the two descriptions coincide.

## 8. Algorithms

We describe the three procedures underlying the computational demonstrations.

**Algorithm A (Central-graph construction).** Given $G = (V, E)$, output $C(G)$: create tagged vertices for each $v \in V$ and each $e \in E$; add an edge between original $u, w$ iff $\{u,w\} \notin E$; add an edge between original $u$ and subdivision $e$ iff $u \in e$. Complexity $O(n^2 + |E|)$.

**Algorithm B (Total-graph and star-clique certificate).** Given a graph $H$, build $T(H)$ by the three adjacency rules of Definition 2.1; for a chosen vertex $w$, extract its closed star and verify it is a clique, certifying the lower bound $\chi''(H) \ge \deg_H(w)+1$. Complexity $O(|E(H)|^2)$ dominated by the edge–edge adjacency test.

**Algorithm C (Exact AVD-total chromatic number).** For increasing $k = 1, 2, \dots$, attempt to properly colour $T(H)$ with $k$ colours by backtracking (ordering total-graph vertices by descending degree, with a next-fresh-colour symmetry break), and at each complete proper colouring test the AVD condition $S(u) \ne S(v)$ on every edge $uv$ of $H$. Return the first $k$ that succeeds. This is exponential in the worst case but exact and effective on the small central graphs used for verification.

## 9. Applications

Total colourings model conflict-free assignment of a shared resource (colour, frequency, or time-slot) to both the units of a system (vertices) and the interactions between them (edges); the AVD refinement additionally guarantees that neighbouring units are distinguishable purely from their local colour footprint, a property relevant to fault localisation and to symmetry breaking in distributed computation. Central graphs provide a canonical, highly symmetric expansion of a base network and are a standard testbed for how colouring parameters behave under subdivision-and-completion. The message of this paper — that the controlling parameter for $\chi''_a(C(G))$ is the vertex count $n$, not the regularity $d$ — is a concrete example of how derived-graph constructions can silently reshape the degree sequence and invalidate parameter-specific conjectures.

## 10. Discussion and future work

We have shown that the natural degree bookkeeping of central graphs promotes every original vertex to maximum degree $n-1$, and that adjacency of any two such vertices (guaranteed by any non-adjacent pair of $G$) forces $\chi''_a(C(G)) \ge n+1$ via the adjacent equal-degree obstruction. This refutes the $d$-based conjecture for all $n > d+2$ and supports the unified value $n+1$.

Open problems and next steps:

1. **Exact value $= n+1$ for non-complete regular $G$.** Prove the matching upper bound by constructing an explicit AVD total colouring of $C(G)$ with $n+1$ colours. This requires a constructive colouring scheme and Behzad/Vizing-style total-colouring tools tailored to the two-layer structure.
2. **The complete case $C(K_n)$.** Determine $\chi''_a(C(K_n))$ exactly. The independent-set structure of the maximum-degree vertices (Theorem 5.4) is the key input, but the tight value again needs an explicit colouring.
3. **General total-colouring toolkit.** A reusable formalisation of the total graph, total chromatic number, the AVD colour-set predicate, and the Total Colouring Conjecture would benefit this and related problems; the present development supplies a usable nucleus (total graph, colour set, AVD predicate).
4. **Upper bounds via edge/total colourings.** Establish $\chi''(H) \le \Delta(H)+2$ for specific graph classes to complement the lower bounds proved here.

## 11. Conclusion

The AVD total chromatic number of the central graph of a regular graph is governed by the number of vertices, not the degree. The lower bound $\chi''_a(C(G)) \ge n+1$ is unconditional for non-complete $G$, refuting the guiding $d+3$ conjecture whenever $n > d+2$, while the complete case is set apart by the independence of its maximum-degree vertices. These facts point to the clean conjectural law $\chi''_a(C(G)) = n+1$ for all regular $G$, of which the lower half is proved and the upper half — an explicit optimal colouring — is the principal task ahead.
