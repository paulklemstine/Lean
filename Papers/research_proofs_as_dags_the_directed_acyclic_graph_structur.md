# Ranked Dependency Networks: Canonical Hierarchy, Width–Depth Tradeoffs, and Robustness

**Aristotle**  
**July 18, 2026**

## Abstract

Mathematical arguments can be represented by directed dependency networks whose vertices are statements and whose edges point from premises to statements using them. When circular justification is excluded, these networks are directed acyclic graphs. This paper isolates the consequences of acyclicity from additional empirical claims about theorem reuse. For a finite acyclic relation, we define the strict ancestors of a vertex as all vertices reaching it by a nonempty directed path and define its canonical rank as the number of those ancestors. We prove that rank strictly increases along reachability. We then establish a width–depth theorem: if a rank map into $L$ ordered levels strictly increases along reachability and the network has more than $L$ vertices, two distinct vertices on one level are mutually incomparable. Finally, we construct, for every size $n\ge 3$, an acyclic network that remains weakly connected after deletion of any single vertex. The construction is the strict total order, in which every pair of distinct vertices is joined by an edge in one orientation. These results show that hierarchy and a pigeonhole-based width principle follow from finite acyclicity, whereas power-law degree distributions, universal hub rankings, and single-hub fragility do not. We give algorithms for computing ranks, finding forced incomparable pairs, and testing deletion robustness, and formulate an empirical program that separates graph-theoretic invariants from corpus-dependent measurements.

## 1. Introduction

A proof rarely depends on only one earlier statement. Definitions, lemmas, and theorems form a many-to-many system of support that is naturally represented as a directed graph. A vertex denotes a mathematical statement, and a directed edge points from a premise to a statement that directly uses it. A directed path then records indirect dependence.

This representation motivates two kinds of question that should not be conflated. The first kind is structural: what must hold in every finite acyclic dependency network? The second is empirical: what patterns occur in a particular mathematical corpus under a particular rule for extracting dependencies? Acyclicity is structural. A proposed power law for theorem reuse, a list of historically dominant hubs, or a quantitative claim about damage caused by deleting a theorem is empirical.

The distinction is important because the phrase “proofs form a directed acyclic graph” can tempt one to import conclusions from familiar network models without proving that their hypotheses apply. Directed acyclic graphs encompass sparse trees, disjoint unions, layered networks, and dense total orders. Their degree distributions and robustness profiles can differ radically.

This paper proves three results that precisely mark the structural boundary.

1. Every finite acyclic dependency network has a canonical topological rank: the number of strict ancestors. Reachability strictly raises this rank.
2. If a strictly increasing rank uses only $L$ levels and there are more than $L$ vertices, two vertices are forced to be incomparable.
3. For every $n\ge 3$, there is an acyclic network on $n$ vertices that remains weakly connected after deletion of any single vertex.

The first theorem gives an intrinsic hierarchy rather than an arbitrarily chosen topological ordering. The second converts bounded depth into guaranteed width by the finite pigeonhole principle. The third supplies a robust null model showing that acyclicity alone cannot imply articulation-hub fragility.

The orientation convention throughout is from prerequisite to dependent statement. Connectivity after deletion is explicitly weak connectivity: edge orientation is ignored while traversing the surviving network. This avoids the ambiguity of asking whether a directed dependency network “disconnects.”

## 2. Definitions and setting

### 2.1 Dependency relations and reachability

Let $V$ be a finite nonempty set of vertices, and let $R\subseteq V\times V$ be a directed relation. We write $R(u,v)$ when there is a direct edge from $u$ to $v$. In the intended interpretation, $v$ directly uses $u$.

A **nonempty directed path** from $u$ to $v$ is a finite sequence

$$
u=v_0,v_1,\ldots,v_m=v.
$$

with $m\ge 1$ and $R(v_{i-1},v_i)$ for every $1\le i\le m$. We write $u\leadsto v$ when such a path exists. Thus $\leadsto$ is the nonreflexive transitive closure of $R$.

**Definition 2.1 (Acyclicity).** The relation $R$ is **acyclic** if no $v\in V$ satisfies $v\leadsto v$.

This definition excludes nonempty directed cycles. It allows isolated vertices and does not assume that the relation is transitively closed.

**Definition 2.2 (Strict ancestors).** The strict ancestor set of $v\in V$ is

$$
A(v)=\{u\in V:u\leadsto v\}.
$$

The word “strict” emphasizes that $v$ itself is excluded in an acyclic network.

**Definition 2.3 (Canonical ancestor rank).** For finite $V$, the canonical ancestor rank of $v$ is

$$
\rho(v)=|A(v)|.
$$

This differs from longest-path depth. It counts all distinct upstream vertices, not merely the number of edges in a longest chain.

### 2.2 Comparability and rank levels

Two vertices $a,b\in V$ are **comparable by reachability** if $a\leadsto b$ or $b\leadsto a$. They are **mutually incomparable** if neither relation holds.

For a positive integer $L$, an **$L$-level strict rank map** is a function

$$
r:V\longrightarrow\{0,1,\ldots,L-1\}
$$

such that

$$
a\leadsto b\quad\Longrightarrow\quad r(a)<r(b).
$$

The definition can be adapted to $L=0$, but then no map exists from a nonempty vertex set. Our substantive applications use positive $L$.

### 2.3 Weak connectivity after deletion

Directed connectivity has several inequivalent meanings. Dependency graphs often lack directed paths from late results back to foundations, even when their underlying undirected structure is cohesive. We therefore use weak connectivity.

Fix a vertex $d\in V$ to be deleted. An **avoiding weak walk** from $a$ to $b$ is a sequence

$$
a=w_0,w_1,\ldots,w_t=b
$$

such that every $w_i\ne d$ and, for each step, either $R(w_i,w_{i+1})$ or $R(w_{i+1},w_i)$ holds. The case $t=0$ is allowed when $a=b\ne d$.

The network is **weakly connected after deletion of $d$** if every pair $a,b\ne d$ has an avoiding weak walk. It is **robust under single-vertex deletion** if this holds for every $d\in V$.

## 3. Ancestor growth and canonical hierarchy

The central set-theoretic fact is monotonicity of ancestor sets along reachability.

**Lemma 3.1 (Ancestor monotonicity).** If $a\leadsto b$, then $A(a)\subseteq A(b)$.

**Proof sketch.** Take $u\in A(a)$. By definition, $u\leadsto a$. Concatenating this path with a path from $a$ to $b$ gives $u\leadsto b$. Hence $u\in A(b)$. $\square$

Acyclicity strengthens containment to proper containment.

**Lemma 3.2 (Strict ancestor growth).** If $R$ is acyclic and $a\leadsto b$, then

$$
A(a)\subsetneq A(b).
$$

**Proof sketch.** Lemma 3.1 gives inclusion. Moreover, $a\in A(b)$ because $a\leadsto b$. If $a\in A(a)$, there would be a nonempty path from $a$ to itself, contradicting acyclicity. Thus $a$ belongs to the right-hand set but not the left-hand set. $\square$

We now obtain the canonical ranking result.

**Theorem 3.3 (Canonical Topological Rank Theorem).** Let $R$ be an acyclic relation on a finite set $V$. For all $a,b\in V$,

$$
a\leadsto b\quad\Longrightarrow\quad \rho(a)<\rho(b),
$$

where $\rho(v)=|A(v)|$.

**Proof sketch.** By Lemma 3.2, $A(a)$ is a proper subset of $A(b)$. Proper containment between finite sets implies strict inequality of cardinalities. $\square$

### 3.1 Consequences

The theorem gives an intrinsic topological numbering. In particular, every direct edge raises rank, because a direct edge is a nonempty path. Every longer path raises rank as well.

**Corollary 3.4 (No equal-rank reachability).** If $\rho(a)=\rho(b)$ and $a\ne b$, then neither $a\leadsto b$ nor $b\leadsto a$.

**Proof sketch.** Either reachability relation would force a strict inequality between equal integers by Theorem 3.3. $\square$

**Corollary 3.5 (Path-length bound).** If

$$
v_0\to v_1\to\cdots\to v_m
$$

is a directed path in a finite acyclic network, then

$$
0\le \rho(v_0)<\rho(v_1)<\cdots<\rho(v_m)\le |V|-1.
$$

Consequently, $m\le |V|-1$.

**Proof sketch.** Apply Theorem 3.3 at each step. An acyclic vertex cannot be its own ancestor, so every ancestor set has at most $|V|-1$ elements. A strictly increasing sequence of integers in this interval has at most $|V|$ terms. $\square$

The canonical rank need not use consecutive values, and equal rank does not mean that vertices have identical ancestor sets. Its merit is invariance: it is fixed by the reachability relation itself.

## 4. A width–depth theorem

The next result applies to any bounded strict rank, not only ancestor rank.

**Theorem 4.1 (Width–Depth Incomparability Theorem).** Let $V$ be a finite set, let $R$ be a directed relation on $V$, and let

$$
r:V\longrightarrow\{0,1,\ldots,L-1\}
$$

be a rank map that strictly increases along every nonempty directed path. If

$$
L<|V|,
$$

then there exist distinct vertices $a,b\in V$ such that

$$
\neg(a\leadsto b)\qquad\text{and}\qquad\neg(b\leadsto a).
$$

**Proof sketch.** Since more than $L$ vertices are assigned to only $L$ levels, the pigeonhole principle gives distinct $a,b$ with $r(a)=r(b)$. If $a\leadsto b$, strict rank increase would imply $r(a)<r(b)$, contradicting equality. The reverse path is ruled out identically. $\square$

The theorem can be read as a minimal width statement. If “depth” is encoded by the number of available ordered levels, then excess population forces at least one pair of parallel, mutually unreachable vertices.

**Corollary 4.2 (Canonical-rank collision).** In a finite acyclic network, if the canonical ancestor rank assumes fewer distinct values than there are vertices, then the network contains a mutually incomparable pair.

**Proof sketch.** Relabel the distinct rank values in increasing order to obtain a bounded strict rank map, then apply Theorem 4.1. Equivalently, two vertices share a canonical rank and Corollary 3.4 applies. $\square$

### 4.1 A quantitative extension by counting

Although the principal theorem guarantees only a pair, the same counting argument yields a larger level set. If $N=|V|$ vertices occupy $L$ levels, some level contains at least

$$
\left\lceil\frac{N}{L}\right\rceil
$$

vertices. Since vertices on one strict rank level cannot reach one another, that entire level is an antichain under reachability.

**Proposition 4.3 (Rank-level antichain bound).** Under the hypotheses of Theorem 4.1, there is a set of at least $\lceil |V|/L\rceil$ pairwise mutually incomparable vertices.

**Proof sketch.** Choose a largest fiber of $r$. The pigeonhole principle bounds its size below by $\lceil |V|/L\rceil$. Any two distinct members have equal rank and hence cannot be related in either direction. $\square$

This proposition clarifies the width–depth tradeoff: compressing many vertices into few legal levels creates a broad antichain, not merely an isolated incomparable pair.

## 5. A robust acyclic family

We now show that acyclicity does not imply vulnerability to single-vertex deletion.

For $n\ge 1$, let

$$
V_n=\{0,1,\ldots,n-1\}
$$

and define the strict total-order network $T_n$ by

$$
R_n(i,j)\quad\Longleftrightarrow\quad i<j.
$$

Thus every pair of distinct vertices has exactly one edge between them, oriented from the smaller index to the larger.

**Theorem 5.1 (Acyclicity of the Strict Total-Order Network).** For every $n$, the network $T_n$ is acyclic.

**Proof sketch.** Every directed edge strictly increases the integer label. By transitivity, every nonempty directed path from $i$ to $j$ satisfies $i<j$. A path from $i$ back to $i$ would imply $i<i$, which is impossible. $\square$

**Theorem 5.2 (Robustness After Arbitrary Single-Vertex Deletion).** Let $d,a,b\in V_n$ with $a\ne d$ and $b\ne d$. Then there is an avoiding weak walk from $a$ to $b$ in $T_n$. Therefore deleting any one vertex leaves all surviving vertices weakly connected.

**Proof sketch.** If $a=b$, use the zero-step walk at $a$. If $a\ne b$, then either $a<b$ or $b<a$. In the first case there is a direct edge $a\to b$; in the second there is a direct edge $b\to a$, which can be traversed in the reverse direction by a weak walk. Both endpoints survive, so the one-step walk avoids $d$. $\square$

**Corollary 5.3 (Infinite Robust Acyclic Family).** For every $n\ge 3$, there exists an acyclic dependency network on $n$ vertices, containing at least three distinct vertices, that remains weakly connected after deletion of any single vertex.

**Proof sketch.** Use $T_n$. The vertices $0$, $1$, and $2$ are distinct because $n\ge 3$. Apply Theorems 5.1 and 5.2. $\square$

### 5.1 Interpretation

The family $T_n$ is deliberately extreme: it is the densest possible acyclic orientation of a complete graph. That extremity is useful. A universal implication from acyclicity to deletion fragility would have to hold for every acyclic network, including $T_n$. Since $T_n$ is robust, no such implication exists.

This does not show that observed proof networks are robust. It shows that robustness must be measured or derived from additional hypotheses. In particular, degree alone is insufficient. Internal vertex-disjoint paths, articulation structure in the underlying undirected graph, and redundancy of support are more directly connected to deletion damage.

## 6. Algorithms

### 6.1 Canonical ancestor ranks

Given an acyclic graph with $N$ vertices and $M$ edges, canonical ranks can be computed by topological dynamic programming with bit sets.

1. Compute a topological ordering.
2. Initialize an empty ancestor bit set $B(v)$ for each vertex.
3. Process vertices in topological order.
4. For every edge $u\to v$, update

$$
B(v)\leftarrow B(v)\cup B(u)\cup\{u\}.
$$

5. Return $\rho(v)=|B(v)|$.

With arbitrary sets, the worst-case running time is $O(NM)$ and storage is $O(N^2)$. With machine-word bit sets of word size $w$, unions give a typical bound of $O(MN/w)$ word operations after topological sorting, whose cost is $O(N+M)$.

Correctness follows by induction over the topological ordering. Every ancestor of $v$ reaches some immediate predecessor $u$ and is therefore contributed by $B(u)\cup\{u\}$. Conversely, every inserted vertex reaches $v$.

### 6.2 Finding an incomparable pair from a rank bound

Given ranks in $L$ levels, store the first vertex seen at each level. On encountering a second vertex with the same rank, return the pair. If the rank is known to increase along reachability, the pair is automatically mutually incomparable.

The running time is $O(N+L)$ with an array, or expected $O(N)$ with a hash map; storage is $O(L)$. Under $L<N$, success is guaranteed.

### 6.3 Testing deletion robustness

For each candidate deleted vertex $d$, run breadth-first search in the underlying undirected graph induced by $V\setminus\{d\}$. If all survivors are reached, deletion preserves weak connectivity. Repeating this for all $d$ costs $O(N(N+M))$ time and $O(N+M)$ working storage.

For the total-order family, the general test is unnecessary: every surviving pair has a direct edge in one orientation, so robustness follows immediately. For empirical corpora, standard articulation-point algorithms can identify all vulnerable vertices in $O(N+M)$ time on the underlying undirected graph.

## 7. Numerical examples

Consider the chain $0\to1\to2\to3$. Its ancestor sets have sizes $0,1,2,3$, so canonical rank strictly increases at every step. There are four levels for four vertices and no forced rank collision.

Now consider the diamond with edges

$$
0\to1,\quad 0\to2,\quad 1\to3,\quad 2\to3.
$$

The ancestor sets are

$$
A(0)=\varnothing,\quad A(1)=A(2)=\{0\},\quad A(3)=\{0,1,2\}.
$$

Thus the ranks are $0,1,1,3$. Vertices $1$ and $2$ collide in rank and are mutually incomparable, illustrating the width–depth mechanism.

For $T_5$, the canonical ranks are $0,1,2,3,4$, because vertex $j$ has exactly the ancestors $0,\ldots,j-1$. Delete vertex $2$. The survivors $0,1,3,4$ remain pairwise adjacent in the underlying undirected graph. The same is true no matter which vertex is deleted.

These examples also show that canonical rank and fragility are different attributes. Both the chain and $T_5$ have ranks $0$ through $4$, but deleting an interior vertex disconnects the underlying chain while no single deletion disconnects $T_5$.

## 8. What acyclicity does not imply

### 8.1 No universal power law

A scale-free hypothesis commonly takes the form

$$
P(K=k)\sim Ck^{-\gamma}
$$

for large degree $k$, where $K$ might denote direct reuse count, transitive reuse count, or another centrality measure. Acyclicity imposes no such distribution. A directed chain, a balanced tree, and a strict total order are all acyclic and have incompatible degree profiles.

A valid empirical study must specify the sampled units, edge extraction, direction of degree, treatment of definitions, lower-tail cutoff, estimation method, uncertainty, and competing distributions. An exponent near a particular value cannot be inferred from graph type.

### 8.2 No universal hub list

The identity of the most reused theorem depends on the corpus and its conventions. A theorem may appear as an explicit dependency in one domain but be hidden inside a library abstraction in another. Domain size, theorem age, naming practices, and foundational choices all affect counts. Historical prominence and graph centrality are related questions, not interchangeable definitions.

### 8.3 No universal deletion fragility

The robust family in Section 5 directly refutes any claim that every nontrivial acyclic network has a critical vertex whose deletion destroys weak connectivity. More generally, high degree does not imply articulation. A high-degree vertex surrounded by alternate paths may be harmless to remove, while a low-degree bridge may be structurally essential.

## 9. Applications and empirical protocol

The structural results support a disciplined workflow for studying proof dependencies.

First, create a versioned corpus and publish the extraction policy. At least three graphs are useful: direct explicit references, transitive references, and references after collapsing definitional expansions. Second, verify acyclicity or document and resolve cycles introduced by mutually recursive packaging or coarse aggregation. Third, compute canonical ancestor ranks and rank-level widths. Fourth, estimate degree tails separately by rank and domain rather than fitting only a global mixture. Fifth, evaluate deletion damage and compare predictors including degree, articulation status, and internally vertex-disjoint path counts.

The width–depth theorem offers a corpus statistic that does not presuppose a generative network model. Rank histograms reveal how many statements occupy each structural layer. Large fibers are certified antichains under reachability and can indicate parallel development.

Robustness tests have practical applications to knowledge organization. If a theorem serves as a pedagogical bottleneck, alternate derivations may improve resilience even when the logical corpus remains unchanged. In automated theorem retrieval, canonical rank can constrain search direction: prerequisites must lie at lower rank than their dependents. In modular exposition, broad antichain layers suggest topics that can be taught or processed in parallel.

## 10. Discussion

The canonical rank $\rho(v)=|A(v)|$ is global: adding a remote upstream dependency can alter ranks throughout a downstream region. This sensitivity is not a defect when the goal is to measure accumulated support, but it means ranks should be compared only within a fixed, versioned graph.

The width–depth theorem is elementary in proof but substantial in interpretation. It states exactly what bounded hierarchy forces and no more. It does not claim semantic independence: incomparable statements may concern the same objects or even be logically equivalent. It claims only absence of a recorded directed dependency path in either direction.

Similarly, weak connectivity is intentionally modest. A surviving network can be weakly connected while losing all directed derivations from some foundations to some conclusions. Other robustness notions—including preservation of reachability pairs, strongly connected structure, or derivability under alternate premise sets—may be appropriate for different questions. The present choice addresses the common but ambiguous claim that deleting a hub “disconnects” the network.

The main methodological conclusion is that universal structure and empirical regularity should be reported separately. Hierarchy follows from acyclicity and finiteness. Width follows when the hierarchy is bounded relative to population. Fragility and heavy tails require data and additional assumptions.

## 11. Future work

Several directions follow naturally. Tail exponents should be tested for stability under direct, transitive, and definition-collapsed dependency policies. Width growth can be studied across domains by comparing rank histograms as corpora expand. Deletion damage should be modeled using redundant path counts rather than degree alone. Hub rankings should be stratified by field and normalized for age and corpus size. Finally, heavy-tail estimation should be conditioned on canonical rank to determine whether a global tail is genuine or merely a mixture of heterogeneous layers.

A further theoretical question is to characterize the strongest robustness conclusions obtainable from combinations of acyclicity, minimum underlying degree, bounded width, and path redundancy. Another is to compare ancestor-count rank with longest-path depth and determine which statistic is more stable under corpus extension.

## 12. Conclusion

Finite acyclic dependency networks possess a canonical hierarchy: the number of strict ancestors rises along every dependency path. Any legal hierarchy with fewer levels than vertices forces mutually incomparable statements, and indeed a rank level of size at least $\lceil |V|/L\rceil$. Yet acyclicity does not imply fragility. Strict total-order networks form an infinite family that remains weakly connected after every single-vertex deletion.

These theorems establish a clean boundary. Hierarchy and a width–depth tradeoff are universal order-theoretic consequences. Power laws, historical hubs, and deletion damage are corpus-dependent hypotheses. Treating that boundary explicitly turns the network metaphor into a rigorous and testable research program.