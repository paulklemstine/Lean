# Structural Register Allocation: Chordal Coloring, Degree Bounds, and Clique Spill Certificates

**Author:** Aristotle  
**Date:** July 19, 2026

## Abstract

Register allocation assigns simultaneously live program variables to a finite bank of processor registers. Modeling variables as vertices and simultaneous liveness as adjacency turns allocation into graph coloring, while spilling becomes vertex deletion before coloring. This paper separates three notions that are often conflated: maximum degree, clique number, and chromatic number. For every finite interference graph, a palette strictly larger than the maximum degree is sufficient, but this bound need not be exact. The three-vertex path already requires only two colors although its maximum degree plus one is three. Exactness is recovered under an explicit structural hypothesis: if the interference graph admits a perfect elimination ordering, then it is colorable with $k$ registers if and only if every clique has size at most $k$. Thus its chromatic number equals its clique number. We also establish a spill certificate: with $k$ available registers, a clique of size $m>k$ forces at least $m-k$ spills from that clique. These results support elimination-based allocation and clique-aware spill analysis while ruling out universal claims that maximum degree determines register demand or that spilling a maximum-degree vertex is always optimal.

## 1. Introduction

A processor register is a scarce, fast storage location. During compilation, each temporary value has a *live range*: the portion of execution during which its current value may still be needed. Two values whose live ranges overlap cannot safely occupy the same register. The register allocator must exploit non-overlap to reuse registers while preserving all required values.

The standard combinatorial model is an interference graph. Its vertices are variables or temporaries, and an edge joins two vertices when the associated values are simultaneously live. Registers become colors, and a valid allocation is a proper vertex coloring. If the processor offers fewer colors than the graph requires, selected values are *spilled* to memory; graph-theoretically, their vertices are deleted before coloring the remainder.

This model naturally suggests numerical summaries. The maximum degree measures the largest number of direct conflicts incident to one variable. The clique number measures the largest family of pairwise conflicting variables. The chromatic number measures the exact number of interchangeable registers required. These quantities satisfy general inequalities, but they are not interchangeable.

A particularly attractive but incorrect prediction is that the register requirement should equal the maximum degree plus one, perhaps modified by a clique term. The universal greedy bound does show that maximum degree plus one registers suffice. It does not show necessity. The distinction can be seen in the path on three vertices, where the middle vertex has two neighbors but the two endpoints can share a color. This graph requires two colors rather than three.

The constructive positive result comes from chordal structure. A perfect elimination ordering ensures that each local set of later conflicts forms a clique. Reverse greedy coloring then turns clique bounds into an allocation algorithm. Under this hypothesis, and not merely from degree information, clique number and chromatic number coincide.

The contributions are fourfold:

1. a palette-level characterization of register allocation for graphs with a perfect elimination ordering;
2. a universal degree-based sufficiency theorem, stated explicitly as an upper bound rather than an equality;
3. a minimal counterexample separating maximum degree plus one from exact register demand; and
4. a clique-based lower bound on the number of spills forced by a fixed register budget.

Together these results identify both a reliable allocation certificate and the boundary of degree-based reasoning.

## 2. Mathematical model

### 2.1 Interference graphs and colorings

A finite simple graph is a pair $G=(V,E)$, where $V$ is a finite vertex set and $E$ is a set of unordered pairs of distinct vertices. In an interference graph, vertices represent values and an edge $\{u,v\}\in E$ means that $u$ and $v$ are simultaneously live.

A *proper $k$-coloring* is a function

$$
c:V\longrightarrow \{1,2,\ldots,k\}
$$

such that $c(u)\neq c(v)$ whenever $\{u,v\}\in E$. The graph is *$k$-colorable* if such a function exists. Its *chromatic number* $\chi(G)$ is the least $k$ for which it is $k$-colorable. In the uniform-register model, $\chi(G)$ is the minimum number of registers required without spilling.

The neighborhood of a vertex $v$ is

$$
N(v)=\{u\in V:\{u,v\}\in E\}.
$$

The degree of $v$ is $\deg(v)=|N(v)|$, and the maximum degree is

$$
\Delta(G)=\max_{v\in V}\deg(v).
$$

A *clique* is a set $S\subseteq V$ such that every two distinct members of $S$ are adjacent. The clique number $\omega(G)$ is the maximum cardinality of a clique in $G$.

Every clique needs distinct colors at all of its vertices. Therefore every finite graph satisfies

$$
\omega(G)\leq \chi(G).
$$

### 2.2 Elimination structure

An ordering $v_1,v_2,\ldots,v_n$ of the vertices is a *perfect elimination ordering* if, for each index $i$, the later neighbors

$$
N_i^+(v_i)=\{v_j:j>i\text{ and }\{v_i,v_j\}\in E\}
$$

form a clique.

A graph is *chordal* if every cycle of length at least four contains a chord, meaning an edge between two nonconsecutive vertices of that cycle. Finite chordal graphs are precisely the finite graphs admitting a perfect elimination ordering. For the arguments below, the ordering itself is the useful certificate: it specifies the order in which local clique structure becomes visible.

Interval graphs provide a common source of chordality. Given intervals on a line, create one vertex per interval and join two vertices when the intervals intersect. Choose an interval whose right endpoint is earliest. Every neighbor that remains active at that endpoint contains the same point, so those neighbors pairwise intersect. Repeating this operation yields a perfect elimination ordering. Thus interval-shaped live ranges have exactly the structure required by the main allocation theorem.

### 2.3 Spilling

Fix a register budget $k$. A *spill set* is a subset $R\subseteq V$ whose vertices are removed from register assignment. It is valid when the induced graph on $V\setminus R$ is $k$-colorable. If each spilled variable has unit cost, the objective is to minimize $|R|$. In a weighted model, each vertex has a nonnegative cost $w(v)$ and the objective is to minimize

$$
\sum_{v\in R}w(v).
$$

The present spill theorem gives a local lower bound for every valid spill set. It does not assert that a particular heuristic always achieves that bound globally.

## 3. Universal bounds and their limitation

### Theorem 1 (Degree-budget sufficiency)

Let $G$ be a finite interference graph. If the number of available registers $k$ satisfies

$$
\Delta(G)<k,
$$

then $G$ is $k$-colorable. Equivalently,

$$
\chi(G)\leq \Delta(G)+1.
$$

#### Proof sketch

Order the vertices arbitrarily and color them one at a time. When a vertex $v$ is reached, at most $\deg(v)\leq\Delta(G)$ of its neighbors have colors. Those neighbors can forbid at most $\Delta(G)$ colors. Since $k>\Delta(G)$, at least one color remains available. Assign such a color and continue. The resulting coloring is proper because every edge is checked when its later endpoint is colored.

The theorem is universal and constructive, but one-sided. It states sufficiency, not exactness.

### Proposition 2 (Smaller coloring excludes the degree formula)

Let $G$ be a finite graph. If $G$ is $k$-colorable for some

$$
k<\Delta(G)+1,
$$

then

$$
\chi(G)\neq\Delta(G)+1.
$$

#### Proof sketch

By definition of chromatic number, a $k$-coloring implies $\chi(G)\leq k$. Combining this with $k<\Delta(G)+1$ gives $\chi(G)<\Delta(G)+1$, so equality is impossible.

### Theorem 3 (Three-vertex separation)

Let $P_3$ be the path with vertices $a,b,c$ and edges $\{a,b\}$ and $\{b,c\}$. Then

$$
\chi(P_3)=2,
\qquad
\Delta(P_3)=2,
$$

and hence

$$
\chi(P_3)=2<3=\Delta(P_3)+1.
$$

#### Proof sketch

The graph has an edge, so one color cannot suffice. Two colors do suffice: color $a$ and $c$ with color $1$ and color $b$ with color $2$. The middle vertex $b$ has two neighbors, while each endpoint has one, so the maximum degree is $2$.

This is a minimal nontrivial diagnostic. A graph with fewer than three vertices cannot simultaneously have maximum degree $2$ and exhibit this separation. The example also refutes the claim that spilling must occur whenever the register budget is below $\Delta(G)+1$: $P_3$ has budget $2<3$ and needs no spill.

The structural reason is that the two neighbors of $b$ are not adjacent. Degree counts them separately, but coloring permits them to reuse a color.

## 4. Exact allocation under perfect elimination

### Theorem 4 (Chordal Register Palette Theorem)

Let $G$ be a finite interference graph equipped with a perfect elimination ordering, and let $k$ be a nonnegative integer. The following conditions are equivalent:

1. $G$ admits a proper coloring with $k$ registers.
2. Every clique $S$ in $G$ satisfies $|S|\leq k$.

Consequently,

$$
\chi(G)=\omega(G).
$$

#### Proof sketch

Assume first that $G$ has a proper $k$-coloring. Every pair of vertices in a clique is adjacent, so all vertices of any clique receive distinct colors. Since only $k$ colors are available, every clique has size at most $k$.

Conversely, suppose every clique has size at most $k$. Let $v_1,\ldots,v_n$ be a perfect elimination ordering and color vertices in reverse order, beginning with $v_n$. When coloring $v_i$, all already colored neighbors belong to the later-neighbor set $N_i^+(v_i)$. By the defining property of the ordering, this set is a clique. Moreover, $N_i^+(v_i)\cup\{v_i\}$ is also a clique, so it has at most $k$ vertices. Therefore $N_i^+(v_i)$ has at most $k-1$ vertices and forbids at most $k-1$ colors. One of the $k$ colors remains for $v_i$. Induction completes the coloring.

For the final identity, the general clique lower bound gives $\omega(G)\leq\chi(G)$. Applying the equivalence with $k=\omega(G)$ yields a coloring with $\omega(G)$ colors, so $\chi(G)\leq\omega(G)$ as well.

### Corollary 5 (No-spill criterion)

For an interference graph with a perfect elimination ordering, a register budget $k$ permits spill-free allocation if and only if no clique contains more than $k$ vertices.

This criterion is both necessary and sufficient. A maximal clique is a simultaneous pressure certificate, while the elimination ordering is an explicit allocation certificate.

### Corollary 6 (Interval-liveness exactness)

If each live range is an interval on a line and interference means interval overlap, then the required number of registers equals the largest number of pairwise overlapping live ranges:

$$
\chi(G)=\omega(G).
$$

#### Proof sketch

The interval intersection graph admits a perfect elimination ordering obtained by repeatedly choosing an interval with earliest finishing time. Apply Theorem 4.

This corollary must be used with semantic care. Real control-flow liveness need not be representable by intervals on one line. More general connected-subtree models are promising, but the graph structure must follow from an explicit liveness representation rather than from a syntactic program label alone.

## 5. Clique pressure and unavoidable spills

### Theorem 7 (Clique Spill Bound)

Let $G=(V,E)$ be a finite interference graph, let $S\subseteq V$ be a clique of size $m$, and suppose the machine provides $k<m$ registers. For every spill set $R\subseteq V$ such that the unspilled graph $G[V\setminus R]$ is $k$-colorable,

$$
|S\cap R|\geq m-k.
$$

In words, at least $m-k$ members of the clique must be spilled.

#### Proof sketch

The unspilled clique members form the set $S\setminus R$. They remain pairwise adjacent, so a proper coloring assigns them distinct registers. Hence $|S\setminus R|\leq k$. Since

$$
|S|=|S\setminus R|+|S\cap R|,
$$

we obtain

$$
|S\cap R|=m-|S\setminus R|\geq m-k.
$$

### Corollary 8 (Global lower bound from a clique)

Under the assumptions of Theorem 7, every valid spill set has size at least $m-k$:

$$
|R|\geq m-k.
$$

The stronger theorem records where these forced spills occur: they must come from the overloaded clique itself.

### Weighted interpretation

If vertices carry spill costs, the cardinality bound still constrains feasible solutions, but it does not determine minimum cost. Within an overloaded clique, at least $m-k$ vertices must be spilled; a local cost lower bound is therefore the sum of the $m-k$ smallest costs in that clique. Overlapping cliques complicate the global problem because one spilled vertex may relieve several clique constraints simultaneously.

This interaction explains why maximum-degree spilling has no universal optimality guarantee. Degree does not encode execution frequency, spill cost, or the overlap pattern among critical cliques. Even in an unweighted setting, deleting one high-degree vertex can alter several neighborhoods in ways that a static ranking fails to predict.

## 6. Algorithms

### 6.1 Greedy coloring from a perfect elimination ordering

Given a perfect elimination ordering $v_1,\ldots,v_n$ and a palette of $k$ registers, process vertices from $v_n$ down to $v_1$. For each vertex, collect colors already used by its later neighbors and choose any unused color. If the maximum clique size is at most $k$, the proof of Theorem 4 guarantees success.

With adjacency sets, the coloring phase takes $O(|V|+|E|)$ time after the ordering is known: every vertex is visited once and every edge is inspected a constant number of times. Standard chordality-recognition methods can also produce an elimination ordering in linear time. The algorithm therefore turns structural recognition into a direct allocation pipeline.

### 6.2 Exact coloring for numerical demonstrations

For small arbitrary graphs, exact chromatic number can be computed by backtracking. Try palette sizes $k=1,2,\ldots,|V|$. For each $k$, recursively choose an uncolored vertex—preferably one of high degree—and assign a color not used by its colored neighbors. The first successful palette size is $\chi(G)$.

This method has exponential worst-case complexity, as expected for general graph coloring, but it is transparent and adequate for small examples. It is useful for contrasting paths, complete graphs, stars, and odd cycles and for checking that degree and clique statistics play different roles.

### 6.3 Clique spill certificates

Given a clique $S$ and register budget $k$, compute $b=\max(0,|S|-k)$. If $b>0$, report that every feasible allocation must spill at least $b$ vertices from $S$. Verifying that a proposed set is a clique requires checking all pairs, which takes $O(|S|^2)$ adjacency queries. Once clique status is known, the numerical bound is constant-time.

The certificate is local and composable. Multiple cliques provide multiple valid lower bounds, though combining overlapping certificates without double counting requires additional optimization machinery.

## 7. Examples and boundary cases

### 7.1 Paths and trees

Every tree with at least one edge is bipartite, hence $2$-colorable, and every clique in a tree has size at most $2$. Trees are chordal because they contain no cycles. Therefore

$$
\chi(T)=\omega(T)=2
$$

for every nontrivial tree $T$.

A star with $r$ leaves has maximum degree $r$ but still has chromatic number $2$. Thus the gap between $\Delta(G)+1$ and $\chi(G)$ can grow arbitrarily large even within chordal graphs. Chordality equates chromatic number with clique number, not with maximum degree plus one.

### 7.2 Complete graphs

For the complete graph $K_n$, every pair of vertices interferes. Consequently,

$$
\chi(K_n)=\omega(K_n)=n
$$

and $\Delta(K_n)=n-1$. Here the degree bound is exact:

$$
\chi(K_n)=\Delta(K_n)+1.
$$

This is the extreme case in which every local conflict participates in one global clique.

### 7.3 Odd cycles

For an odd cycle $C_{2r+1}$ with $r\geq2$, the largest clique has size $2$, but the graph is not bipartite and needs three colors:

$$
\omega(C_{2r+1})=2<3=\chi(C_{2r+1}).
$$

Odd cycles of length at least five are not chordal. They demonstrate that clique number alone does not control coloring outside an appropriate perfect graph class.

### 7.4 Spill arithmetic

Suppose seven variables form a clique and only four registers are available. Theorem 7 gives

$$
7-4=3,
$$

so at least three clique members must spill. If the same graph contains another clique of size six, that second clique independently demands at least two spills among its members. The two requirements cannot simply be added when the cliques overlap; one spill may satisfy both. This is precisely where clique-tree dynamic programming becomes a natural direction for chordal graphs.

## 8. Compiler interpretation and applications

The mathematical results suggest a disciplined allocation workflow.

First, construct the interference graph from a precisely specified liveness semantics. Second, search for a perfect elimination ordering or otherwise establish chordality. If such an ordering exists, compute the maximum clique size and compare it with the register budget. A budget at least as large as the maximum clique guarantees spill-free coloring, and reverse elimination directly produces the assignment. If the budget is smaller, overloaded cliques provide unavoidable spill certificates.

When no elimination structure exists, the maximum-degree theorem remains a safe general upper bound, but clique size may underestimate chromatic demand, as odd cycles show. General coloring or decomposition methods are then required.

The same framework applies beyond compilers. Any resource-assignment problem with pairwise incompatibility can be represented by a graph: classroom scheduling, frequency assignment, temporary storage planning, and overlapping job allocation. Chordal or interval structure turns a difficult global coloring problem into a greedy procedure with exact clique certificates.

## 9. Discussion

The central distinction is between local conflict count and collective conflict structure. Maximum degree controls how many colors a greedy step might have to avoid in the worst case. Clique number controls how many colors are unavoidably needed by a mutually conflicting set. A perfect elimination ordering bridges the two: it ensures that the relevant already colored neighborhood at every step is itself a clique.

This bridge explains both the positive theorem and the counterexample. In the three-vertex path, the middle vertex has two neighbors, but those neighbors do not form a clique and may share a color. In a reverse elimination step, only the later clique matters, not the total degree. The exact allocation theorem therefore depends on an ordering-sensitive structure rather than a single global degree statistic.

Spilling introduces an optimization layer that coloring alone does not resolve. The clique spill bound identifies necessary local deletions, but several cliques can overlap, and vertices can have heterogeneous costs. A degree-only strategy discards this information. A principled optimizer should account for the arrangement of maximal cliques, the costs of candidate spills, and the way one deletion changes several constraints.

## 10. Future work

Five directions follow naturally.

First, weighted spilling on chordal graphs should be studied through dynamic programming over clique trees. Chordality localizes coloring obstructions to maximal cliques, while a clique tree records their overlaps. Parameterizing the state space by maximum clique size may yield tractable exact optimization.

Second, realistic architectures provide register classes rather than one uniform palette. This motivates list coloring, where each variable has its own admissible register set. A vertex-sensitive condition based on the largest clique containing each vertex may strengthen the uniform theorem.

Third, the semantic origin of chordal interference graphs deserves an exact characterization. If live ranges are connected subtrees of a dominance tree, their intersection graph is expected to be chordal; a converse representation would tightly connect program semantics and graph structure.

Fourth, restricted graph classes may admit valid versions of maximum-degree spilling. Identifying the precise boundary—possibly among block graphs—would replace an unreliable universal heuristic by a theorem with explicit hypotheses.

Fifth, graphs that become chordal after deleting a small exceptional set invite fixed-parameter algorithms. One may isolate the nonchordal obstruction and apply elimination methods to the remainder, parameterized by the exceptional-set size and register budget.

## 11. Conclusion

Register allocation is graph coloring, but the graph invariant that matters depends on structure. Every finite interference graph can be colored with $\Delta(G)+1$ registers, yet this number is often an overestimate. The three-vertex path proves that even a chordal graph may need fewer registers than that degree bound predicts. For a graph with a perfect elimination ordering, the exact criterion is instead clique-based: $k$ registers suffice exactly when every clique has size at most $k$, and therefore $\chi(G)=\omega(G)$. When the budget falls below a clique size $m$, at least $m-k$ members of that clique must spill.

These statements provide three distinct tools: a universal safe budget, an exact structural allocation theorem, and a local certificate of unavoidable spilling. Keeping those roles separate prevents upper bounds from becoming false equalities and turns elimination structure into a practical guide for resource assignment.