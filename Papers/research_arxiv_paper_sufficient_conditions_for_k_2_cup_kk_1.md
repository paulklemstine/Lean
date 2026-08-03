# Common Antineighborhoods in Graphs Forbidding an Edge and Independent Vertices

**Aristotle**  
**August 3, 2026**

## Abstract

For a nonnegative integer $k$, consider finite simple graphs containing no induced subgraph isomorphic to the disjoint union $K_2\cup kK_1$ of one edge and $k$ isolated vertices. We develop an exact local description of this hereditary restriction. For a vertex set $A$, its common antineighborhood $\overline N(A)$ consists of the vertices adjacent to no member of $A$. We prove that a graph is $(K_2\cup kK_1)$-free if and only if the common antineighborhood of every independent $k$-vertex set is independent. More strongly, in such a graph the common antineighborhood of every independent set of cardinality at least $k$ is independent. We derive a no-edge formulation, monotonicity in the parameter, the exact characterization at $k=0$, and the singleton consequence at $k=1$. We also present exhaustive recognition and witness-extraction algorithms, discuss complexity, and explain how the local theorem supplies a structural step in path-exchange approaches to Hamilton-connectedness. The arguments are elementary but establish a clean interface between a forbidden induced configuration and local adjacency constraints.

## 1. Introduction

Forbidden induced subgraphs are a central language for describing graph classes. Their definitions are concise, but they can be awkward inside constructive arguments: a proof about paths, separators, or degree conditions must repeatedly translate local adjacency information into the existence of a prescribed induced graph. The purpose of this paper is to carry out that translation for one configuration that occurs naturally in Hamiltonian graph theory.

Let $K_2$ denote a single edge and let $kK_1$ denote $k$ isolated vertices. Their disjoint union $K_2\cup kK_1$ has $k+2$ vertices and exactly one edge. A graph is $(K_2\cup kK_1)$-free when no vertex subset induces that graph. Thus a violation consists of an edge whose endpoints are both anticomplete to an independent set of size $k$.

This description suggests fixing the independent set rather than the edge. Given a set $A$ of vertices, consider all vertices with no neighbor in $A$. We call this set the common antineighborhood of $A$. The defining forbidden pattern exists exactly when the common antineighborhood of some independent $k$-set contains an edge. Consequently, the forbidden-subgraph property has an exact local characterization: every such common antineighborhood is independent.

The principal contribution is the systematic statement of this equivalence and its consequences. The large-set form shows that an independent set of size at least $k$ has an independent common antineighborhood. Parameter monotonicity shows that freedom at $k$ implies freedom at every larger parameter. The boundary $k=0$ gives precisely edgeless graphs, while $k=1$ says that the nonneighbors of each vertex form an independent set.

These facts are relevant to Hamilton-connectedness. A graph is Hamilton-connected if every ordered choice of two distinct endpoints admits a spanning path. Longest-path and path-exchange arguments often construct a large independent set together with an edge anticomplete to it. In the graph class considered here, the local characterization rules out this terminal configuration immediately. Our scope is the structural foundation itself; no global Hamilton-connectedness criterion is asserted here.

## 2. Preliminaries

Throughout, $G=(V,E)$ is a finite simple undirected graph. Simplicity means that edges are unordered pairs of distinct vertices, so loops and parallel edges are absent. Two vertices $u,v\in V$ are **adjacent**, written $u\sim v$, when $\{u,v\}\in E$.

For $X\subseteq V$, the induced subgraph $G[X]$ has vertex set $X$ and contains exactly those edges of $G$ whose endpoints both lie in $X$. A set $I\subseteq V$ is **independent** if no two distinct members of $I$ are adjacent. Equivalently, $G[I]$ is edgeless.

The graph $K_1$ consists of one vertex, and $K_2$ consists of two adjacent vertices. For $k\geq 0$, the graph $kK_1$ is the disjoint union of $k$ copies of $K_1$. Hence $K_2\cup kK_1$ consists of vertices

$$
\{u,v,x_1,\ldots,x_k\}
$$

with $uv$ as its only edge. For $k=0$, this notation reduces to $K_2$.

**Definition 2.1 ($(K_2\cup kK_1)$-freeness).** A graph $G$ is **$(K_2\cup kK_1)$-free** if there do not exist adjacent vertices $u,v$ and an independent set $I$ with $|I|=k$ such that

$$
u\not\sim x\quad\text{and}\quad v\not\sim x
\qquad\text{for every }x\in I.
$$

This is equivalent to saying that $G$ has no induced subgraph isomorphic to $K_2\cup kK_1$. The selected vertices $u,v$ contribute the unique edge, independence removes all edges within $I$, and the displayed nonadjacencies remove every edge between $I$ and $\{u,v\}$.

**Definition 2.2 (common antineighborhood).** For $A\subseteq V$, the **common antineighborhood** of $A$ is

$$
\overline N_G(A)=\{v\in V: v\not\sim a\text{ for every }a\in A\}.
$$

We omit the subscript $G$ when the graph is clear. Notice that this definition does not require $v\notin A$. If $A$ is independent, then every member of $A$ lies in $\overline N(A)$. Also, if $A\subseteq B$, then

$$
\overline N(B)\subseteq\overline N(A),
$$

because avoiding every vertex of the larger set is the stronger condition.

A pair of sets $A,B\subseteq V$ is **anticomplete** if no edge has one endpoint in $A$ and the other in $B$. Thus $v\in\overline N(A)$ exactly when $\{v\}$ is anticomplete to $A$.

## 3. The structural theorem

We begin with the large-independent-set formulation, which is the strongest direct consequence needed below.

**Theorem 3.1 (Common Antineighborhood Theorem).** Let $k\geq 0$, and let $G$ be a $(K_2\cup kK_1)$-free graph. If $I$ is an independent set with $|I|\geq k$, then $\overline N(I)$ is independent.

**Proof sketch.** Assume that $\overline N(I)$ is not independent. Then it contains adjacent vertices $u$ and $v$. Since $|I|\geq k$, choose a subset $J\subseteq I$ with $|J|=k$. The set $J$ is independent because it is contained in $I$. Since $u,v\in\overline N(I)$, both $u$ and $v$ are nonadjacent to every member of $J$. Therefore $G[J\cup\{u,v\}]$ has exactly one edge, namely $uv$, and is isomorphic to $K_2\cup kK_1$. This contradicts the assumed forbidden-subgraph condition. Hence $\overline N(I)$ is independent. $\square$

The theorem can be expressed in a form tailored to contradiction arguments.

**Corollary 3.2 (No Edge Anticomplete to a Large Independent Set).** Let $G$ be $(K_2\cup kK_1)$-free, and let $I$ be independent with $|I|\geq k$. If $u$ and $v$ are each anticomplete to $I$, then $u$ and $v$ are nonadjacent.

**Proof sketch.** The hypotheses place $u$ and $v$ in $\overline N(I)$. By Theorem 3.1 this common antineighborhood is independent, so it cannot contain the edge $uv$. $\square$

The converse to the size-$k$ case also holds, yielding an exact characterization rather than merely a necessary condition.

**Theorem 3.3 (Exact Local Characterization).** For every $k\geq 0$, a graph $G$ is $(K_2\cup kK_1)$-free if and only if $\overline N(I)$ is independent for every independent set $I$ with $|I|=k$.

**Proof sketch.** If $G$ is $(K_2\cup kK_1)$-free, apply Theorem 3.1 to each independent $k$-set. Conversely, suppose every independent $k$-set has independent common antineighborhood. If $G$ contained an induced $K_2\cup kK_1$, let $I$ be the $k$ isolated vertices in that induced subgraph and let $u,v$ be the endpoints of its unique edge. Then $I$ is independent, while both $u$ and $v$ belong to $\overline N(I)$. The edge $uv$ contradicts the asserted independence of $\overline N(I)$. $\square$

The proof identifies a bijective correspondence at the level of witnesses: every forbidden induced copy supplies an independent $k$-set whose common antineighborhood contains an edge, and every such set-edge pair supplies a forbidden induced copy. Different witnesses can describe the same induced copy only through a reordering of the edge endpoints or the vertices in the independent set; as vertex subsets, the construction is canonical.

## 4. Parameter behavior and boundary cases

The forbidden classes are nested as the number of required isolated vertices grows.

**Theorem 4.1 (Parameter Monotonicity).** Let $0\leq k\leq \ell$. If $G$ is $(K_2\cup kK_1)$-free, then $G$ is $(K_2\cup \ell K_1)$-free.

**Proof sketch.** Suppose instead that $G$ contains an induced $K_2\cup \ell K_1$. Its isolated part is an independent set $I$ of size $\ell$, anticomplete to the endpoints of the unique edge. Choose any $k$-element subset $J\subseteq I$. The edge together with $J$ induces $K_2\cup kK_1$, contradicting the hypothesis. $\square$

Thus the classes satisfy

$$
\mathcal F_0\subseteq\mathcal F_1\subseteq\mathcal F_2\subseteq\cdots,
$$

where $\mathcal F_k$ denotes the class of $(K_2\cup kK_1)$-free graphs. The inclusions can be strict. For example, the graph $K_2\cup kK_1$ fails membership in $\mathcal F_k$ but belongs to $\mathcal F_{k+1}$ because it has too few vertices to contain $K_2\cup(k+1)K_1$.

The zero parameter clarifies the starting point of the hierarchy.

**Theorem 4.2 (Zero-Parameter Characterization).** A graph is $(K_2\cup 0K_1)$-free if and only if it is edgeless.

**Proof sketch.** Since $K_2\cup0K_1=K_2$, any edge is itself a forbidden induced subgraph. Conversely, an edgeless graph contains no copy of $K_2$. In antineighborhood language, the unique independent set of size zero is $\varnothing$, and $\overline N(\varnothing)=V$. The local characterization therefore requires the entire vertex set to be independent. $\square$

At parameter one, every independent set under consideration is a singleton.

**Corollary 4.3 (Singleton Antineighborhood Property).** If $G$ is $(K_2\cup K_1)$-free, then for every vertex $a$, the set

$$
\overline N(\{a\})=\{v\in V:v\not\sim a\}
$$

is independent.

**Proof sketch.** The singleton $\{a\}$ is independent and has cardinality one, so Theorem 3.1 applies with $k=1$. $\square$

Because graphs are loopless, $a$ itself belongs to this common antineighborhood. Thus the assertion includes the already known absence of loops and, more substantially, says that any two distinct nonneighbors of $a$ are nonadjacent to one another.

## 5. Recognition and certificate algorithms

Theorem 3.3 gives a direct finite recognition algorithm. Let $n=|V|$ and assume the graph is represented by an adjacency matrix, so adjacency queries take constant time.

**Algorithm 5.1 (Local Antineighborhood Recognition).** Enumerate every $k$-element subset $I\subseteq V$. Discard $I$ if it is not independent. Otherwise compute $A=\overline N(I)$ and search $G[A]$ for an edge. If an edge $uv$ is found, return the witness $(I,u,v)$. If all independent $k$-sets are processed without finding an edge, declare the graph $(K_2\cup kK_1)$-free.

**Correctness sketch.** If the algorithm returns $(I,u,v)$, then $I$ is independent, $u$ and $v$ avoid every member of $I$, and $uv$ is an edge. Hence these vertices induce $K_2\cup kK_1$. If the algorithm returns “free,” every independent $k$-set has an independent common antineighborhood; Theorem 3.3 then proves the claimed property. $\square$

Testing whether one candidate $I$ is independent takes $O(k^2)$ adjacency queries. Computing its antineighborhood takes $O(nk)$ queries, and searching that antineighborhood for an edge takes $O(n^2)$ in the worst case. The total running time is therefore

$$
O\!\left(\binom{n}{k}(n^2+nk+k^2)\right)=O\!\left(\binom{n}{k}n^2\right).
$$

For each fixed $k$, this is $O(n^{k+2})$. The memory requirement beyond the adjacency matrix is $O(n)$ for the current subset and antineighborhood. This is not intended as an optimal recognition method for large $k$; its value is transparency and exact witness extraction.

An edge-first algorithm is equally natural. Enumerate every edge $uv$, form

$$
A_{uv}=\{x\in V:x\not\sim u\text{ and }x\not\sim v\},
$$

and test whether $G[A_{uv}]$ contains an independent set of size $k$. This formulation can exploit specialized independent-set routines, but for variable $k$ it exposes the expected combinatorial difficulty. The set-first algorithm better mirrors the local theorem.

The large-set consequence can also be checked constructively.

**Algorithm 5.2 (Quiet-Zone Inspection).** Given a graph $G$, a parameter $k$, and an independent set $I$ with $|I|\geq k$, compute $\overline N(I)$ and list its internal edges. If the graph is known to be $(K_2\cup kK_1)$-free, the list must be empty. If it is nonempty, choose one listed edge and any $k$ vertices from $I$ to obtain an explicit forbidden induced subgraph.

This algorithm does not need to search all $k$-sets. It explains one supplied independent set and gives either confirmation of its quiet zone or a compact counterexample to the ambient graph-class claim.

## 6. Examples and sharpness

Complete graphs satisfy the condition for every $k\geq1$. Indeed, they have no independent set of size $k$ when $k\geq2$, while for $k=1$ the common antineighborhood of a singleton contains only that vertex. They also contain no induced disconnected graph on at least three vertices.

Edgeless graphs satisfy the condition for every $k\geq0$, since no forbidden pattern can occur without its $K_2$ edge. Their common antineighborhoods are the whole vertex set, which is independent.

The graph $K_2\cup kK_1$ itself demonstrates exactness. Let $I$ be its isolated part. Then $|I|=k$, and its common antineighborhood contains both endpoints of the edge. Hence the local condition fails. For any independent set larger than $k$, Theorem 3.1 still applies in every graph satisfying the hypothesis; the cardinality threshold cannot be lowered uniformly, because a graph may be free of $K_2\cup kK_1$ while containing $K_2\cup(k-1)K_1$.

For a concrete $k=2$ example, begin with vertices $a,b,u,v$ and only the edge $uv$. The set $I=\{a,b\}$ is independent, and $u,v\in\overline N(I)$, so the graph violates the property. Adding the edge $au$ destroys this particular induced witness because $u$ is no longer anticomplete to $I$, although another witness might remain elsewhere in a larger graph. This illustrates why recognition must inspect all candidate sets or otherwise control all possible witnesses.

## 7. Relation to Hamilton-connectedness

A Hamilton path is a path containing every vertex exactly once. A graph is Hamilton-connected when every two distinct vertices are endpoints of some Hamilton path. This is stronger than Hamiltonicity and stronger than the existence of a single Hamilton path.

Several global invariants arise in sufficient conditions for Hamilton-connectedness. The **minimum degree** $\delta(G)$ is the least vertex degree. The **independence number** $\alpha(G)$ is the largest cardinality of an independent set. A graph is $r$-connected if deleting fewer than $r$ vertices leaves it connected, subject to the standard order convention. For a noncomplete graph, its **toughness** is

$$
\tau(G)=\min\left\{\frac{|S|}{\omega(G-S)}:S\subseteq V,\ \omega(G-S)\geq2\right\},
$$

where $\omega(G-S)$ is the number of connected components remaining after deletion of $S$. Complete graphs are assigned $\tau(G)=\infty$.

The structural results proved here interact with these notions through proof architecture rather than through a direct numerical inequality. A typical longest-path argument assumes that a desired spanning path does not exist and chooses a maximal counterexample. Failed insertion and rotation operations impose nonadjacency relations. Connectivity and minimum-degree hypotheses provide enough neighbors to continue the analysis; toughness constrains the number of components created by separators; independence-number bounds control how many mutually nonadjacent vertices can accumulate.

At a decisive stage, such reasoning may produce an independent set $I$ of size at least $k$ and an edge $uv$ whose endpoints are anticomplete to $I$. Corollary 3.2 rules this out immediately in a $(K_2\cup kK_1)$-free graph. Equivalently, Theorem 3.1 says that after the independent set has been identified, its common antineighborhood has no internal edge available to support the alleged obstruction.

This role should be stated carefully. The local theorem does not imply Hamilton-connectedness on its own. Edgeless graphs satisfy the forbidden condition but are not Hamilton-connected except in trivial orders. Additional assumptions such as connectivity, degree bounds, toughness, or restrictions on $\alpha(G)$ are indispensable. The theorem instead provides a reusable reduction: it turns the forbidden induced-subgraph hypothesis into the exact local contradiction needed by path-exchange arguments.

## 8. Discussion

The main equivalence is elementary, yet it has several methodological advantages.

First, it separates the combinatorics of the forbidden pattern from the rest of an argument. Once an independent set is in hand, one need only know that its common antineighborhood is independent. There is no need to reconstruct the induced graph each time.

Second, it strengthens without extra work from sets of size exactly $k$ to sets of size at least $k$. This is important because structural arguments often produce “enough” independent vertices without controlling their number exactly. Subset selection bridges that mismatch.

Third, the parameter hierarchy becomes immediate. An obstruction with more isolated vertices contains one with fewer, so a stronger small-$k$ restriction implies every larger-$k$ restriction.

Fourth, the local characterization supplies explicit certificates in both mathematical and computational reasoning. Failure is witnessed by an independent set and one edge in its common antineighborhood. This witness has only $k+2$ vertices and can be checked directly.

There are also limitations. Exhaustive recognition has a binomial factor and is practical mainly for small fixed $k$ or modest graph order. More importantly, the theorem addresses only the forbidden-induced-subgraph component of Hamilton-connectedness arguments. Developing a complete theory requires compatible treatments of vertex deletion, components, toughness, connectivity, spanning paths, and path rotations.

## 9. Future work

A first direction is to integrate the local condition with a fully explicit induced-copy framework, including graph isomorphisms and disjoint unions. Although Definition 2.1 is transparently equivalent to induced $K_2\cup kK_1$ avoidance, a general interface would make comparisons with other hereditary classes easier.

A second direction is algorithmic. Bitset representations can accelerate antineighborhood intersections and edge tests. For sparse graphs, edge-first search may outperform subset enumeration. Parameterized analyses could clarify whether recognition is fixed-parameter tractable under useful secondary parameters such as degeneracy, independence number, or complement degree.

A third direction is structural. The common antineighborhood theorem should be combined with separator inequalities implied by toughness greater than one. Complete graphs require separate handling because their toughness is conventionally infinite. The resulting lemmas can then feed longest-path extension and endpoint-exchange arguments.

The principal target is a sufficient condition asserting Hamilton-connectedness under a combination of $(K_2\cup kK_1)$-freeness, connectivity, minimum degree at least $2k$, and toughness greater than one. Related variants replace or supplement toughness assumptions with bounds involving the independence number, graph order, and $k$-connectivity. Establishing these results requires significantly more machinery than the local theorem, but the forbidden-configuration step is now reduced to a single exact principle.

Finally, exhaustive enumeration of small graphs can serve as a regression laboratory for definitions and conjectured inequalities. It can reveal off-by-one errors in connectivity conventions, test component counts after deletion, compare toughness conventions, and generate minimal witnesses when proposed Hamilton-connectedness conditions are insufficient.

## 10. Conclusion

Forbidding the induced graph $K_2\cup kK_1$ is exactly the same as requiring the common antineighborhood of every independent $k$-set to be independent. This equivalence extends to a useful large-set theorem: every independent set of size at least $k$ has an edgeless common antineighborhood. It yields the no-edge corollary, monotonicity in $k$, the edgeless characterization at $k=0$, and the singleton antineighborhood property at $k=1$.

The result gives a compact local language for a disconnected forbidden configuration. Its principal value in Hamiltonian graph theory is as a bridge: global hypotheses may force an independent set and a putative edge into the same antineighborhood, while the local theorem shows that they cannot coexist. That precise contradiction is a natural building block for future Hamilton-connectedness arguments.
