# Branch-Set Minors, Chromatic Complexity, and the Wagner Bridge

**Aristotle**  
**July 31, 2026**

## Abstract

Hadwiger’s conjecture predicts that every finite loopless graph $G$ contains a complete minor whose order is at least the chromatic number of $G$. This paper develops a self-contained branch-set framework for the conjecture. We define minor models and the Hadwiger number, prove reflexivity, the inclusion of spanning subgraphs as minors, monotonicity under adding edges, and the passage from cliques to complete minors. We establish the zero- and one-color indexed cases: every nonempty graph has a $K_1$ minor, and every graph that is not one-colorable has a $K_2$ minor. We also prove that every finite $k$-degenerate graph is $(k+1)$-colorable by a greedy elimination argument. At the five-vertex threshold, we identify the logical equivalence between the assertion that every non-four-colorable graph contains a $K_5$ minor and its contrapositive, that every $K_5$-minor-free graph is four-colorable. This immediately yields the Four Color Theorem for graphs characterized as excluding both $K_5$ and $K_{3,3}$ minors. We conclude with exhaustive-search algorithms for small graphs, the density perspective represented by the Kostochka–Thomason statement, applications, and a precise account of the remaining structural steps.

## 1. Introduction

A proper coloring of a graph assigns colors to vertices so that adjacent vertices receive different colors. A graph minor, by contrast, is obtained by deleting vertices or edges and contracting edges. These operations appear to describe different aspects of a network: coloring measures global incompatibility, while contraction reveals coarse connectivity. Hadwiger’s conjecture proposes a universal relation between them.

Let $K_t$ denote the complete graph on $t$ vertices and let $\chi(G)$ denote the chromatic number of a finite graph $G$. Hadwiger’s conjecture states that if $\chi(G)\ge t$, then $G$ contains $K_t$ as a minor. Equivalently, if $h(G)$ denotes the largest $t$ for which $K_t$ is a minor of $G$, then

$$
\chi(G)\le h(G).
$$

The conjecture should not be confused with the easy statement that a visible clique requires distinct colors. Every clique of size $t$ forces $\chi(G)\ge t$, but the chromatic number may greatly exceed the clique number. Hadwiger’s claim is that the missing complete graph nevertheless exists after connected parts of $G$ are compressed.

Contraction also complicates any naive monotonicity argument: it can increase chromatic number. Thus the conjecture does not follow from a principle that minors are easier to color. Its content is instead structural: sufficiently high chromatic number forces a complete pattern of contacts among disjoint connected regions.

The purpose of this paper is to present a precise branch-set foundation and the consequences that follow directly from it. The full conjecture remains open and is not asserted here. Likewise, the deep density theorem discussed in Section 8 is stated for context rather than proved. All proved results are accompanied by proof sketches that expose their mathematical mechanism.

## 2. Graphs, colorings, and complete graphs

Throughout, a **graph** means a simple undirected graph $G=(V,E)$: the vertex set $V$ is finite when coloring is discussed, edges are unordered pairs of distinct vertices, loops are absent, and multiple edges are ignored. We write $x\sim_G y$ when $x$ and $y$ are adjacent.

A **proper $q$-coloring** is a function

$$
c:V\longrightarrow\{0,1,\ldots,q-1\}
$$

such that $c(x)\ne c(y)$ whenever $x\sim_G y$. The graph is **$q$-colorable** if such a function exists. Its **chromatic number** $\chi(G)$ is the least $q$ for which it is $q$-colorable.

The **complete graph** $K_t$ has $t$ vertices and an edge between every pair of distinct vertices. A **clique** in $G$ is a set of pairwise adjacent vertices. The largest clique size is the clique number $\omega(G)$. Since all vertices of a clique must receive different colors,

$$
\omega(G)\le \chi(G).
$$

The **complete bipartite graph** $K_{r,s}$ has two disjoint vertex classes of sizes $r$ and $s$, every vertex in one class adjacent to every vertex in the other, and no edges within either class.

When two graphs $H$ and $G$ share a vertex set, we write $H\subseteq G$ and call $H$ a **spanning subgraph** if every edge of $H$ is an edge of $G$. This restricted subgraph relation is sufficient for the monotonicity results below.

## 3. Minor models by branch sets

The branch-set description packages deletion and contraction into a single certificate.

**Definition 3.1 (Minor model).** Let $G$ and $H$ be simple graphs. An **$H$-minor model in $G$** assigns to every vertex $u\in V(H)$ a set $B_u\subseteq V(G)$ satisfying:

1. **Nonemptiness:** $B_u\ne\varnothing$ for every $u$.
2. **Disjointness:** $B_u\cap B_v=\varnothing$ whenever $u\ne v$.
3. **Connectivity:** the subgraph of $G$ induced by $B_u$ is connected.
4. **Edge realization:** whenever $uv\in E(H)$, there exist $x\in B_u$ and $y\in B_v$ with $xy\in E(G)$.

The sets $B_u$ are called **branch sets**. We say that $H$ is a **minor** of $G$ if such a model exists.

Contracting each connected branch set to one vertex and discarding unused vertices and edges produces $H$. Conversely, a sequence of deletions and contractions determines branch sets consisting of the original vertices merged into each surviving target vertex. The branch-set formulation is especially useful because a certificate can be checked without choosing an order of contractions.

**Definition 3.2 (Hadwiger number).** The **Hadwiger number** of $G$ is

$$
h(G)=\sup\{t\in\mathbb N:K_t\text{ is a minor of }G\}.
$$

For finite $G$, no minor can have more branch sets than $G$ has vertices, so the supremum is a maximum. Allowing an extended natural value is convenient for a definition that also applies without a finiteness restriction.

**Conjecture 3.3 (Hadwiger).** Every finite simple graph satisfies

$$
\chi(G)\le h(G).
$$

An equivalent indexed statement is useful.

**Definition 3.4 (Indexed Hadwiger coloring case).** For $k\ge0$, the $k$th indexed case is the assertion that every finite graph that is not $k$-colorable contains $K_{k+1}$ as a minor.

If $\chi(G)=r$, taking $k=r-1$ in the indexed assertion produces a $K_r$ minor. Conversely, the inequality $\chi(G)\le h(G)$ implies each indexed case.

## 4. Structural properties of the minor relation

The elementary properties below validate the branch-set notion and supply reusable constructions.

**Lemma 4.1 (Singleton connectivity).** For every vertex $v$ of a graph $G$, the induced graph on $\{v\}$ is connected.

**Proof sketch.** The induced graph has one vertex. The only pair of vertices to connect is the vertex with itself, joined by a path of length zero. $\square$

**Theorem 4.2 (Reflexivity).** Every graph $G$ is a minor of itself.

**Proof sketch.** For each $v\in V(G)$ choose $B_v=\{v\}$. The sets are nonempty and pairwise disjoint, and Lemma 4.1 gives connectivity. If $uv$ is an edge of the target $G$, the same edge joins the singleton branch sets in the host $G$. $\square$

**Theorem 4.3 (Spanning subgraphs are minors).** If $H\subseteq G$ on a common vertex set, then $H$ is a minor of $G$.

**Proof sketch.** Again take $B_v=\{v\}$. Every edge required by $H$ belongs to $G$ by the subgraph hypothesis. All remaining branch-set conditions are immediate. $\square$

**Corollary 4.4 (Empty spanning graph).** The graph on $V(G)$ with no edges is a minor of $G$.

**Proof sketch.** It is a spanning subgraph of $G$, so Theorem 4.3 applies. $\square$

**Theorem 4.5 (Monotonicity under adding edges).** Let $H\subseteq G$ be graphs on the same vertex set. If $K$ is a minor of $H$, then $K$ is a minor of $G$.

**Proof sketch.** Retain the branch sets of the $K$-model in $H$. They remain nonempty and disjoint. A path in $H$ is also a path in $G$, so each branch set remains connected. Every edge between branch sets used by the model in $H$ is present in $G$. Hence the same family is a $K$-model in $G$. $\square$

This theorem is one-sided: it proves compatibility with enlarging a host graph on a fixed vertex set. Full transitivity of branch-set minors requires composing two families of branch sets and proving that the resulting unions are connected and disjoint; that stronger result is reserved for future work.

**Theorem 4.6 (Cliques yield complete minors).** If $G$ contains a clique $S$ of size $t$, then $K_t$ is a minor of $G$.

**Proof sketch.** Index the vertices of $S$ by the vertices of $K_t$ and use each indexed vertex as a singleton branch set. Distinct branch sets are disjoint, and every pair is joined because $S$ is a clique. $\square$

**Corollary 4.7.** For every graph $G$,

$$
\omega(G)\le h(G).
$$

**Corollary 4.8.** For every $t\ge0$,

$$
h(K_t)\ge t.
$$

**Proof sketch.** Apply reflexivity to $K_t$, or apply Theorem 4.6 to its full vertex set. $\square$

These statements isolate the easy direction of the theory. Every literal complete subgraph is a complete minor; the conjecture becomes interesting precisely when $\chi(G)>\omega(G)$.

## 5. The first indexed cases

The smallest target graphs admit direct branch-set models.

**Proposition 5.1 (The empty complete minor).** Every graph contains $K_0$ as a minor.

**Proof sketch.** The target has no vertices, so there are no branch sets and all four model conditions are vacuous. $\square$

**Proposition 5.2 (The one-vertex complete minor).** Every graph with a nonempty vertex set contains $K_1$ as a minor.

**Proof sketch.** Choose any host vertex $v$ and use $\{v\}$ as the sole branch set. No edge-realization condition is required because $K_1$ has no edges. $\square$

**Proposition 5.3 (An edge yields $K_2$).** If $G$ contains an edge $uv$, then $K_2$ is a minor of $G$.

**Proof sketch.** Use $\{u\}$ and $\{v\}$ as the two branch sets. The edge $uv$ realizes the unique edge of $K_2$. $\square$

**Theorem 5.4 (Zero-color indexed case).** Every finite graph that is not zero-colorable contains $K_1$ as a minor.

**Proof sketch.** A graph is zero-colorable exactly when its vertex set is empty. Failure of a zero-coloring therefore supplies a vertex, and Proposition 5.2 applies. $\square$

**Theorem 5.5 (One-color indexed case).** Every finite graph that is not one-colorable contains $K_2$ as a minor.

**Proof sketch.** A graph with no edges is one-colorable by assigning the sole color to every vertex. Consequently a graph that is not one-colorable has an edge. Proposition 5.3 then gives a $K_2$ minor. $\square$

The next indexed case says that every non-bipartite graph contains a $K_3$ minor. Its standard route passes through the characterization of non-bipartite graphs by odd cycles, followed by a contraction of an odd cycle into three branch sets. This extension is not assumed in the results above.

## 6. Degeneracy and a constructive coloring theorem

Minor structure and coloring are also linked through sparse elimination.

**Definition 6.1 (Degeneracy).** A finite graph $G$ is **$k$-degenerate** if every nonempty subset $S\subseteq V(G)$ contains a vertex with at most $k$ neighbors in $S$.

Equivalently, every nonempty induced subgraph has minimum degree at most $k$. The definition yields an elimination ordering: repeatedly choose a vertex of current degree at most $k$ and delete it.

**Theorem 6.2 (Degeneracy coloring theorem).** Every finite $k$-degenerate graph is $(k+1)$-colorable.

**Proof sketch.** Induct on the number of vertices. The empty graph is trivially colorable. For a nonempty graph, degeneracy supplies a vertex $v$ of degree at most $k$. The induced graph $G-v$ is still $k$-degenerate: every nonempty subset of its vertices is also a subset of $V(G)$ and therefore contains a vertex of internal degree at most $k$. By induction, color $G-v$ with $k+1$ colors. At most $k$ colors occur on the neighbors of $v$, so at least one of the $k+1$ colors is available for $v$. Assign that color to $v$. $\square$

The proof gives an explicit algorithm. First compute the elimination order, then process it backwards with greedy coloring. With adjacency lists, maintaining current degrees and a stack of vertices of degree at most $k$ takes $O(|V|+|E|)$ time when $k$ is fixed and a valid degeneracy bound is supplied. Greedy reconstruction also takes $O(|V|+|E|)$ time.

The contrapositive is often informative: if $\chi(G)\ge k+2$, then $G$ is not $k$-degenerate. Hence some nonempty induced subgraph has minimum degree at least $k+1$. Chromatic difficulty therefore forces a locally dense core, a first step toward the stronger complete-minor conclusion.

## 7. The Wagner bridge and four colors

At $K_5$, Hadwiger’s conjecture meets planar graph coloring. We adopt the following combinatorial definition.

**Definition 7.1 (Planarity by forbidden minors).** A finite graph $G$ is called **planar** when it has neither $K_5$ nor $K_{3,3}$ as a minor.

This is the forbidden-minor characterization of ordinary geometric planarity. It is particularly well suited to the present discussion because exclusion of a $K_5$ minor is built into the definition.

**Statement 7.2 (Four Color Theorem).** Every finite planar graph is four-colorable.

Now isolate the order-five Hadwiger assertion.

**Statement 7.3 ($K_5$ Hadwiger coloring statement).** Every finite graph that is not four-colorable contains $K_5$ as a minor.

In the indexing of Definition 3.4, this is the case $k=4$, because the target is $K_{4+1}=K_5$.

**Statement 7.4 (Wagner minor-free coloring statement).** Every finite graph with no $K_5$ minor is four-colorable.

**Theorem 7.5 (Wagner contrapositive equivalence).** The $K_5$ Hadwiger coloring statement and the Wagner minor-free coloring statement are logically equivalent.

**Proof sketch.** Assume Statement 7.3. If a graph $G$ has no $K_5$ minor and were not four-colorable, Statement 7.3 would produce the forbidden minor, a contradiction; hence $G$ is four-colorable. Conversely, assume Statement 7.4. If $G$ is not four-colorable and had no $K_5$ minor, Statement 7.4 would color it with four colors, again a contradiction. Therefore $G$ has a $K_5$ minor. $\square$

**Theorem 7.6 (Wagner forward implication).** The $K_5$ Hadwiger coloring statement implies the Four Color Theorem.

**Proof sketch.** Let $G$ be planar. By Definition 7.1 it has no $K_5$ minor. Theorem 7.5 converts Statement 7.3 into Statement 7.4, which gives a four-coloring of $G$. Directly, if $G$ were not four-colorable, Statement 7.3 would force a $K_5$ minor, contradicting planarity. $\square$

**Corollary 7.7.** The indexed Hadwiger coloring case $k=4$ implies the Four Color Theorem.

Only the forward logical bridge is established by this argument. The substantive reverse connection requires a structural theorem describing $K_5$-minor-free graphs in terms of planar graphs and the Wagner graph, assembled through clique-sums. That decomposition is not a consequence of contraposition alone and is not claimed here.

The role of $K_{3,3}$ deserves emphasis. It is needed in Definition 7.1 to characterize planarity, but Theorem 7.6 uses only the first half of the definition: every planar graph is $K_5$-minor-free. Thus any theorem four-coloring all $K_5$-minor-free graphs is automatically stronger than four-coloring planar graphs.

## 8. Average degree and the density perspective

For a finite graph $G$ with vertex set $V$, define its **average degree** by

$$
\overline d(G)=
\begin{cases}
0,& |V|=0,\\[4pt]
\displaystyle\frac{1}{|V|}\sum_{v\in V}\deg_G(v),& |V|>0.
\end{cases}
$$

By the handshake identity, $\sum_v\deg(v)=2|E|$, so for a nonempty graph

$$
\overline d(G)=\frac{2|E|}{|V|}.
$$

The following deep theorem gives the asymptotically correct scale at which average degree forces complete minors.

**Theorem 8.1 (Kostochka–Thomason density theorem, stated).** There exists a universal constant $c>0$ such that for every positive integer $t$ and every finite graph $G$,

$$
\overline d(G)\ge c\,t\sqrt{\log t}
$$

implies that $G$ contains $K_t$ as a minor.

No proof of Theorem 8.1 is supplied here; it is recorded to place the branch-set theory in its density context. Its message is that complete minors can be forced without a visible clique. Dense connectivity can be routed through connected branch sets even when pairwise adjacency among individual vertices is absent.

Degeneracy provides a complementary elementary lens. If every induced subgraph has a low-degree vertex, greedy coloring succeeds. Conversely, a graph requiring many colors contains an induced subgraph of large minimum degree. The density theorem suggests how such a dense core may eventually yield a large complete minor, although bridging the exact chromatic threshold of Hadwiger’s conjecture remains much more delicate.

## 9. Algorithms and finite experiments

Although exhaustive computation does not settle a universal conjecture, it clarifies definitions, produces certificates, and tests small cases.

### 9.1 Exact chromatic number

An exact coloring algorithm tries $q=0,1,\ldots,n$ and performs backtracking for each $q$. At each step it chooses an uncolored vertex, preferably one with many colored neighbors, and assigns a color not used by an adjacent colored vertex. The first feasible $q$ equals $\chi(G)$.

In the worst case, fixed-$q$ search examines $q^n$ assignments, and trying all $q$ remains exponential. Ordering heuristics substantially reduce the search for small examples but do not alter worst-case complexity.

### 9.2 Verification of a branch-set certificate

Given candidate sets $B_1,\ldots,B_t$, a verifier checks:

1. every $B_i$ is nonempty;
2. no vertex appears in two branch sets;
3. a breadth-first or depth-first search inside each $B_i$ reaches all of it;
4. for every $i\ne j$, at least one host edge joins $B_i$ to $B_j$.

If $n=|V|$ and $m=|E|$, these checks can be implemented in polynomial time, for example $O(t(n+m)+t^2m)$ in a direct implementation and faster with precomputed adjacency information. Thus the existence search may be hard, but a proposed complete-minor model is efficiently checkable.

### 9.3 Exhaustive branch-set search

To search for a $K_t$ minor, assign every host vertex one of $t+1$ labels: label $0$ means unused, and labels $1$ through $t$ indicate branch-set membership. This gives at most $(t+1)^n$ assignments. Reject assignments with empty, overlapping, disconnected, or nonadjacent branch sets. Symmetry breaking—such as requiring the least vertex of branch set $i$ to precede that of branch set $i+1$—avoids many equivalent permutations.

Combining exact coloring and minor search tests whether $K_{\chi(G)}$ appears. There are

$$
2^{\binom n2}
$$

labeled simple graphs on $n$ vertices, so complete enumeration grows doubly exponentially in the natural vertex parameter of the combined experiment. It remains practical only for small $n$.

### 9.4 Demonstrative families

Several families make useful sanity checks.

- For the empty graph on $n>0$ vertices, $\chi(G)=1$ and $K_1$ is witnessed by any singleton.
- For a graph consisting of one edge and isolated vertices, $\chi(G)=2$ and the edge endpoints witness $K_2$.
- For $K_t$, the chromatic number is $t$ and singleton branch sets witness a $K_t$ minor.
- For a cycle of odd length at least three, $\chi(G)=3$; three connected arcs can be chosen so that every pair touches by an edge, giving a $K_3$ minor.
- A tree with at least one edge has chromatic number $2$ and contains $K_2$, while it cannot contain $K_3$ as a minor because deletions and contractions preserve acyclicity.

These examples separate visible cliques from hidden complete minors and expose the role of connected branch sets.

## 10. Applications and conceptual consequences

Graph coloring models resource conflicts: adjacent tasks may need different time slots, frequencies, registers, or labels. A large clique is an obvious obstruction because all its vertices compete pairwise. A complete minor is a more distributed obstruction. Each branch set may represent a connected subsystem, and pairwise contact among subsystems records a robust pattern of interaction after internal details are compressed.

This interpretation matters in network simplification. Contraction is a natural coarse-graining operation in transportation, circuit, and communication networks. The Hadwiger number measures the largest all-to-all interaction pattern recoverable under such coarse-graining. Unlike the clique number, it can detect complexity routed through paths and connected regions.

The degeneracy theorem has direct algorithmic value. Sparse networks often admit low-degeneracy orderings, producing fast colorings with a guaranteed palette. The same ordering is useful in triangle enumeration, sparse linear algebra, and incremental graph processing because each vertex has few later neighbors.

The Wagner bridge shows that map coloring is not isolated. The Four Color Theorem sits at the $K_5$ threshold of a broader conjecture about chromatic number and minors. The short forward implication also explains why proving the $K_5$ case for all finite graphs is at least as strong as proving four-colorability for planar graphs.

## 11. Discussion of scope

The results proved here form a foundation rather than a proof of Hadwiger’s conjecture in general. In particular:

- Reflexivity, spanning-subgraph inclusion, and monotonicity under edge addition are established, but full minor transitivity is not included.
- The indexed cases $k=0$ and $k=1$ are established. The cases $k=2$ and above are not inferred from them.
- The equivalence in Theorem 7.5 is logical contraposition between two $K_5$ formulations. It does not supply Wagner’s structural decomposition.
- The implication from the $K_5$ case to the Four Color Theorem is established. The reverse implication requires additional structural graph theory.
- The Kostochka–Thomason theorem is stated to frame the role of density; its proof lies beyond the present elementary development.

These distinctions are mathematically important. They prevent a logical reformulation from being mistaken for a structural equivalence and a contextual theorem statement from being mistaken for a derived result.

## 12. Future work

Five directions naturally extend the framework.

1. **Branch-set minor transitivity.** Given a model of $H$ in $G$ and a model of $K$ in $H$, replace each branch set of the second model by the union of the corresponding branch sets of the first. One must prove these unions are nonempty, pairwise disjoint, connected in $G$, and joined whenever required. This would make the minor relation a preorder.

2. **The triangle case.** Prove that every finite graph with no proper two-coloring has a $K_3$ branch-set minor. A concrete route is to establish the odd-cycle characterization of non-bipartite graphs and partition an odd cycle into three nonempty connected arcs with the required pairwise contacts.

3. **The four-clique case.** Prove that every finite graph with no proper three-coloring has a $K_4$ branch-set minor. This should proceed through the classical low-order Hadwiger theorem rather than finite enumeration.

4. **Wagner’s structural bridge.** Show that every finite $K_5$-minor-free graph can be reduced, using clique-sums, to planar graphs and the Wagner graph, and derive the implication from the Four Color Theorem to the $K_5$ Hadwiger statement. Together with Theorem 7.6, this would yield the substantive Wagner equivalence.

5. **Known cases through six colors.** Establish every indexed case $k\le5$. The endpoint $k=5$ asserts that every finite graph that is not five-colorable contains a $K_6$ minor; its proof should explicitly identify the use of the Four Color Theorem.

## 13. Conclusion

The branch-set model turns graph minors into concrete geometric certificates: disjoint connected territories linked according to a target graph. Within this language, every graph is its own minor, spanning subgraphs are minors, adding host edges preserves models, and every clique supplies a complete minor. These constructions establish the first two indexed coloring cases and clarify the basic inequality $\omega(G)\le h(G)$.

Degeneracy supplies a separate constructive bridge from local sparsity to global colorability. At order five, contraposition identifies the statement “non-four-colorable implies a $K_5$ minor” with “$K_5$-minor-free implies four-colorable,” and planarity then gives the Four Color Theorem immediately.

Hadwiger’s conjecture remains compelling because it predicts a universal conversion between two kinds of complexity. Chromatic number records how many mutually incompatible labels a graph demands. The Hadwiger number records how large a complete interaction pattern survives after connected regions are compressed. The conjecture says the second always dominates the first: every difficult coloring problem contains, in geometric disguise, a complete graph of matching order.
