# Degree-Based Spilling Is Not Optimal on Chordal Interference Graphs

**Aristotle**  
**July 29, 2026**

## Abstract

Register allocation models simultaneously live program values as adjacent vertices of an interference graph and physical registers as colors. This model suggests two attractive but incorrect degree-based principles: that the register requirement should equal $\max(\Delta(G)+1,\omega(G))$, and that spilling a maximum-degree vertex should optimally reduce register pressure. We give a self-contained eight-vertex counterexample to both claims. The graph is the disjoint union $K_3\sqcup K_{1,4}$ of a triangle and a four-leaf star. It is chordal, as witnessed by an explicit perfect elimination ordering. Its maximum degree is $4$, its clique number and chromatic number are both $3$, and it is $3$-colorable despite the proposed value $\Delta(G)+1=5$. Under a two-register budget, deleting the unique maximum-degree vertex leaves the triangle and therefore fails, whereas deleting a degree-$2$ triangle vertex yields a bipartite graph and succeeds. The example shows that local edge incidence does not identify global coloring obstructions, even in the graph class most relevant to structured SSA interference. We formulate the appropriate chordal-graph perspective, give algorithms for checking the example and evaluating one-vertex spills, and discuss clique-sensitive and weighted alternatives.

## 1. Introduction

Register allocation assigns program values to a limited set of processor registers. Two values whose live ranges overlap cannot occupy the same register, because one assignment would destroy a value still needed later. This constraint is represented by an undirected interference graph: vertices are values and edges join pairs that are simultaneously live. Assigning registers is then proper vertex coloring.

This translation is valuable because it separates two questions. The first is feasibility: can all values remain in registers under a budget of $k$ registers? The second is repair: if not, which values should be spilled to memory so that the remaining graph becomes $k$-colorable? Both invite degree-based heuristics. A vertex of high degree conflicts with many others, while the universal greedy bound $\chi(G)\leq\Delta(G)+1$ relates maximum degree to colorability.

These observations can be overextended. One proposed exact formula is

$$
\chi(G)=\max(\Delta(G)+1,\omega(G)),
$$

where $\omega(G)$ is the largest clique size. Another proposed optimization rule is to spill a maximum-degree vertex. The first confuses an upper bound with an equality; the second confuses removal of many edges with removal of the obstruction that exceeds the register budget.

The distinction remains important for static single assignment, or SSA, programs. Their interference graphs are commonly studied through chordal structure. Chordal graphs admit perfect elimination orderings and satisfy the exact relation $\chi(G)=\omega(G)$. One might nevertheless wonder whether degree-based spilling becomes reliable in this restricted class. The answer is no.

We establish this with a concrete graph containing only eight vertices. One connected component is a triangle; the other is a star with four leaves. The star center has unique maximum degree, but it is irrelevant to the triangle that forces three colors. Spilling the center therefore fails to achieve two-colorability, whereas spilling any triangle vertex succeeds. The same construction separates the chromatic number $3$ from the degree-based value $5$.

The contribution is not merely a numerical observation. We state the graph exactly, exhibit its perfect elimination ordering, derive all degrees, provide explicit colorings, and prove the impossibility of two-coloring after the maximum-degree spill. The resulting diagnosis suggests a corrected empirical target for chordal interference graphs: measure $\chi(G)=\omega(G)$ and treat $\Delta(G)+1$ only as a general upper bound. For spilling, the example motivates clique-sensitive and cost-sensitive optimization rather than degree alone.

## 2. Graph-theoretic model

### 2.1 Interference and coloring

Let $G=(V,E)$ be a finite simple undirected graph. The vertices represent program values. An edge $\{u,v\}\in E$ means that $u$ and $v$ interfere and cannot share a register.

A **proper $k$-coloring** is a function

$$
c:V\longrightarrow\{0,1,\ldots,k-1\}
$$

such that $c(u)\neq c(v)$ whenever $\{u,v\}\in E$. The graph is **$k$-colorable** if such a function exists. Its **chromatic number** $\chi(G)$ is the least positive $k$ for which it is $k$-colorable. In the interference model, $\chi(G)$ is the minimum number of registers needed without spilling.

For $v\in V$, the **neighborhood** $N(v)$ is the set of vertices adjacent to $v$, and the **degree** is $\deg(v)=|N(v)|$. The maximum degree is

$$
\Delta(G)=\max_{v\in V}\deg(v).
$$

A **clique** is a subset $C\subseteq V$ whose distinct vertices are pairwise adjacent. The **clique number** $\omega(G)$ is the maximum cardinality of a clique. Every clique requires distinct colors, giving

$$
\omega(G)\leq\chi(G).
$$

Greedy coloring gives the complementary general bound

$$
\chi(G)\leq\Delta(G)+1.
$$

Indeed, color vertices in any order. At the moment a vertex is colored, at most $\Delta(G)$ colors occur among its colored neighbors, so one of $\Delta(G)+1$ colors remains available. This argument proves sufficiency, not necessity.

### 2.2 Spilling

Let $S\subseteq V$ be a set of spilled vertices. Their values are treated as residing in memory, and colors assigned to them are irrelevant. The surviving interference graph is the induced subgraph $G-S$ on $V\setminus S$.

We say that $G$ is **$k$-colorable except for $S$** if there exists a map $c:V\to\{0,\ldots,k-1\}$ such that every edge whose endpoints both lie outside $S$ has differently colored endpoints. Equivalently, $G-S$ is $k$-colorable.

For one-vertex spilling under register budget $k$, the feasibility question is whether $G-v$ is $k$-colorable. If each vertex has a spill cost $w(v)>0$, the broader optimization problem is to find $S$ minimizing

$$
\sum_{v\in S}w(v)
$$

subject to $\chi(G-S)\leq k$. The unweighted one-vertex comparison studied here isolates whether maximum degree alone identifies a successful choice.

### 2.3 Chordality and elimination

A cycle of length at least four has a **chord** if two nonconsecutive vertices on the cycle are adjacent. A graph is **chordal** if every cycle of length at least four has a chord.

A vertex ordering $v_1,\ldots,v_n$ is a **perfect elimination ordering** in the earlier-neighbor convention if, for every $v_i$, the set

$$
N^-(v_i)=\{v_j:j<i\text{ and }\{v_i,v_j\}\in E\}
$$

is a clique. Reversing the order converts this to the equally common later-neighbor convention. A finite graph is chordal exactly when it has a perfect elimination ordering.

Chordal graphs are perfect: every induced subgraph $H$ satisfies $\chi(H)=\omega(H)$. For the present analysis, the main consequence is that clique number, rather than maximum degree, supplies the exact register requirement for chordal interference graphs.

## 3. The counterexample

### 3.1 Construction

Let

$$
V=\{0,1,2,3,4,5,6,7\}.
$$

Place all three edges among $0,1,2$, forming a triangle. Join vertex $3$ to each of $4,5,6,7$, forming a four-leaf star. Add no other edges. Thus

$$
E=\bigl\{\{0,1\},\{0,2\},\{1,2\},
\{3,4\},\{3,5\},\{3,6\},\{3,7\}\bigr\},
$$

and

$$
G=K_3\sqcup K_{1,4}.
$$

The graph has eight vertices and seven edges. Its disconnected form is a feature rather than a loophole: it cleanly separates a component with high degree from a component with high coloring demand.

### 3.2 Chordal structure

**Theorem 1 (Perfect elimination).** *The natural ordering $0,1,2,3,4,5,6,7$ is a perfect elimination ordering of $G$. Consequently, $G$ is chordal.*

**Proof sketch.** The earlier-neighbor sets are

$$
\begin{aligned}
N^-(0)&=\varnothing, & N^-(1)&=\{0\}, & N^-(2)&=\{0,1\},\\
N^-(3)&=\varnothing, & N^-(4)&=\{3\}, & N^-(5)&=\{3\},\\
N^-(6)&=\{3\}, & N^-(7)&=\{3\}.&&
\end{aligned}
$$

Every empty set and singleton is a clique, and $\{0,1\}$ is a clique because $0$ and $1$ are adjacent. Hence every earlier-neighbor set is a clique. The ordering is perfect, and the standard elimination characterization implies chordality. $\square$

The same conclusion is visible directly: neither component has a cycle of length at least four, so no induced long cycle can occur. The elimination proof is more useful algorithmically because it provides an ordering that can drive coloring.

### 3.3 Degree data

**Lemma 2 (Degree profile).** *The degrees in $G$ are*

$$
\deg(0)=\deg(1)=\deg(2)=2,
\qquad
\deg(3)=4,
\qquad
\deg(4)=\cdots=\deg(7)=1.
$$

*In particular, $\Delta(G)=4$, and vertex $3$ is the unique maximum-degree vertex.*

**Proof sketch.** Each triangle vertex is adjacent to the other two triangle vertices. The star center is adjacent to its four leaves. Each leaf is adjacent only to the center. No cross-component edges exist. Taking the largest value yields $\Delta(G)=4$. $\square$

### 3.4 Chromatic and clique numbers

**Theorem 3 (Failure of the degree formula).** *The graph $G$ satisfies*

$$
\omega(G)=\chi(G)=3,
\qquad
\Delta(G)+1=5.
$$

*Consequently,*

$$
\chi(G)\neq\max(\Delta(G)+1,\omega(G)).
$$

**Proof sketch.** The vertices $0,1,2$ form a clique of size $3$, so $\omega(G)\geq3$ and $\chi(G)\geq3$. No clique can contain vertices from both connected components. The star has clique number $2$, and the triangle has clique number $3$, so $\omega(G)=3$.

For an upper bound, color $0,1,2$ with colors $0,1,2$, respectively. Color the star center $3$ with color $0$ and all leaves $4,5,6,7$ with color $1$. Every edge has differently colored endpoints, so $G$ is $3$-colorable and $\chi(G)\leq3$. Therefore $\chi(G)=3$. Lemma 2 gives $\Delta(G)+1=5$, and the maximum of $5$ and $3$ is $5$, not $3$. $\square$

This theorem identifies the conceptual defect in the proposed equality. A high-degree vertex can have an independent neighborhood, as the star center does. Such a neighborhood uses a single color, so its size need not force many colors. Degree records the number of constraints incident to a vertex but not the dependencies among those constraints.

## 4. Failure of maximum-degree spilling

Fix a budget of two registers. Before spilling, the triangle prevents a two-coloring. We compare the unique maximum-degree candidate $3$ with the lower-degree candidate $0$.

**Lemma 4 (The maximum-degree spill fails).** *The graph $G-3$ is not $2$-colorable.*

**Proof sketch.** Deleting $3$ removes the four star edges and leaves $4,5,6,7$ isolated. It does not alter the triangle on $0,1,2$. In any two-coloring, vertex $0$ must differ from both $1$ and $2$. With only two colors, this forces $1$ and $2$ to receive the same color, contradicting their adjacency. Thus the surviving triangle cannot be two-colored. $\square$

**Lemma 5 (A lower-degree spill succeeds).** *The graph $G-0$ is $2$-colorable.*

**Proof sketch.** After deleting $0$, the triangle component becomes the edge $\{1,2\}$. The star component is unchanged. Assign color $0$ to vertices $1$ and $3$, and assign color $1$ to vertices $2,4,5,6,7$. The edge $\{1,2\}$ is properly colored, and every star edge joins $3$ of color $0$ to a leaf of color $1$. Hence this is a proper two-coloring of $G-0$. $\square$

Combining the structural and coloring statements gives the central result.

**Theorem 6 (Maximum-degree spilling is not optimal, even on a chordal graph).** *There exists a chordal graph $G$ and vertices $x,y$ such that $x$ has maximum degree, $\deg(y)<\deg(x)$, $G-x$ is not $2$-colorable, and $G-y$ is $2$-colorable. Specifically, for $G=K_3\sqcup K_{1,4}$ one may take $x=3$ and $y=0$, with $\deg(x)=4$ and $\deg(y)=2$.*

**Proof sketch.** Theorem 1 establishes chordality. Lemma 2 establishes the degree comparison and maximum-degree status of $3$. Lemma 4 proves failure after deleting $3$, while Lemma 5 supplies a successful coloring after deleting $0$. $\square$

The theorem compares feasibility, not merely a surrogate score. Deleting $3$ removes four edges but leaves chromatic number $3$; deleting $0$ removes two edges and lowers chromatic number to $2$. Thus maximizing the number of deleted incident edges can be strictly worse than targeting a smaller obstruction.

## 5. Algorithms and reproducible numerical checks

### 5.1 Exhaustive chromatic-number computation

For a small graph, the chromatic number can be found by backtracking. Order vertices by nonincreasing degree. For $k=1,2,\ldots$, recursively assign one of $k$ colors to each vertex, rejecting a partial assignment as soon as an edge has equal-colored endpoints. The first feasible $k$ is $\chi(G)$.

If $n=|V|$, the worst-case search for a fixed $k$ examines $O(k^n)$ assignments, with $O(n+|E|)$ preprocessing and constant- or degree-dependent checks per extension. This exponential method is appropriate for demonstrations and small extracted interference graphs; production allocators use stronger structural or heuristic methods.

Applied to the present graph, the algorithm rejects $k=1$ and $k=2$ because of the triangle, then accepts $k=3$. It reports $\chi(G)=3$.

### 5.2 Verification of a perfect elimination ordering

Given an ordering, build the earlier-neighbor set of each vertex and test whether every pair in that set is adjacent. With an adjacency matrix, this takes $O(n^3)$ time in a direct implementation and $O(n+m)$ time with specialized chordality algorithms. On the natural ordering, the only earlier-neighbor set of size greater than one is $\{0,1\}$ for vertex $2$, and its members are adjacent. The ordering therefore passes.

### 5.3 One-vertex spill evaluation

For each candidate $v$, delete $v$ and test $k$-colorability of the survivor. At $k=2$, a linear-time bipartiteness test suffices: perform breadth-first search in each connected component, assigning alternating colors and rejecting an edge whose endpoints acquire the same color. Evaluating every candidate independently costs $O(n(n+m))$ time.

For this graph, deleting any of $0,1,2$ succeeds because it breaks the triangle. Deleting any of $3,4,5,6,7$ fails because the complete triangle remains. In particular, the unique maximum-degree candidate belongs to the failing set.

## 6. Implications for compiler optimization

### 6.1 The corrected exact target

For arbitrary graphs, $\Delta(G)+1$ is a robust upper bound. It can guide capacity planning but should not be interpreted as an exact count. For chordal graphs, the exact count is governed by cliques:

$$
\chi(G)=\omega(G).
$$

A perfect elimination ordering makes this equality constructive. Color in the reverse of such an order. When a vertex is reached, its already colored neighbors form a clique and therefore have distinct colors. Assign the smallest absent color. The number of colors used is bounded by the largest clique and cannot be smaller than that clique, so the coloring is optimal.

Accordingly, empirical studies of SSA interference should compare measured chromatic and clique numbers, while recording maximum degree separately. Testing $\chi(G)=\Delta(G)+1$ would reject many benign graphs for the wrong reason.

### 6.2 Clique lower bounds for spilling

Suppose the register budget is $k$ and $C$ is a clique of size $m>k$. At most $k$ vertices of $C$ can survive, because surviving clique vertices require distinct colors. Therefore every feasible spill set $S$ satisfies

$$
|S\cap C|\geq m-k.
$$

In the counterexample, $C=\{0,1,2\}$, $m=3$, and $k=2$. Every successful spill set must contain at least one triangle vertex. The maximum-degree vertex $3$ lies outside $C$, so deleting it cannot satisfy this necessary condition. This explains the failure before any coloring search is run.

For chordal graphs, where cliques determine chromatic number, oversized cliques are not merely lower-bound witnesses; collectively they characterize the obstacles to a $k$-coloring. Spill selection can therefore be viewed as a constrained hitting problem: remove enough vertices from every clique larger than $k$, while minimizing cost.

### 6.3 Weighted costs and practical heuristics

Real spill costs are heterogeneous. A value used inside a hot loop may be expensive to reload, whereas a constant may be cheaply rematerialized. Let $w(v)$ encode this cost. The objective becomes minimum-weight deletion subject to $k$-colorability. Degree has no access to $w$, so even a graph class on which degree happened to predict feasibility would require additional information for cost optimality.

A practical heuristic may combine degree, estimated execution frequency, live-range length, rematerialization cost, and clique participation. The theorem rules out only the universal optimality of pure maximum-degree choice. It leaves room for degree as a feature or tie-breaker when supported by measured workloads.

### 6.4 Connected variants and scope

The disconnected construction is deliberately transparent: chromatic number of a disjoint union is the maximum of component chromatic numbers, while maximum degree is likewise the maximum over components, allowing different components to control the two statistics. Compiler interference graphs need not be connected, so this is already a valid operational scenario; independent groups of values can arise in different regions or functions.

Further work may seek minimal connected chordal counterexamples or characterize subclasses where degree-based deletion is safe. Such refinements do not change the present conclusion: chordality alone is insufficient to guarantee maximum-degree spill optimality.

## 7. Discussion

The counterexample separates local density from global obstruction. The star center has four incident edges, but its neighbors are mutually nonadjacent. They can all share one register. A triangle vertex has only two incident edges, but its two neighbors interfere with each other, creating a three-way simultaneous demand. Register pressure depends not only on how many conflicts a value has but on how those conflicts interact.

This distinction also clarifies the role of classical coloring bounds. The inequality $\chi(G)\leq\Delta(G)+1$ answers a worst-case sufficiency question: how many colors always suffice given only maximum degree? It does not claim that every graph attains the bound. Exact equality is exceptional, not automatic. In contrast, the clique lower bound can be exact on structurally restricted classes such as chordal graphs.

The spill result is stronger than a mere tie-breaking anomaly. Vertex $3$ is the unique maximum-degree choice, and it fails outright under the specified register budget. A lower-degree choice succeeds. No alternative selection among maximum-degree vertices can rescue the heuristic.

The example also distinguishes edge reduction from chromatic reduction. An algorithm that chooses the vertex deleting the greatest number of edges selects $3$. Yet those four edges belong to a bipartite component already compatible with two registers. The two edges removed by deleting $0$ belong to the unique odd cycle and destroy the decisive obstruction. Optimization criteria must align with the target property.

## 8. Future work

Several directions follow naturally.

First, one can characterize graph classes or local conditions under which deleting a maximum-degree vertex does minimize register deficit. Trees, threshold graphs, and restricted chordal families are plausible starting points.

Second, weighted spilling should be studied directly: minimize total cost subject to $k$-colorability of the unspilled induced graph. Clique constraints provide lower bounds and may support dynamic programming on elimination structures.

Third, a compiler-facing account should connect SSA dominance and live ranges to perfect elimination orderings, making precise when the chordal model applies.

Fourth, reverse-elimination greedy coloring can be implemented as a certified optimal allocator for chordal inputs, producing both a coloring and a largest-clique certificate.

Fifth, the clique bound $|S\cap C|\geq |C|-k$ should be developed into stronger spill lower bounds and approximation methods.

Finally, exhaustive classification can determine the smallest chordal counterexamples, including connected examples and variants with weighted costs. Such a classification would map the exact boundary between safe and unsafe degree rules.

## 9. Conclusion

The eight-vertex graph $K_3\sqcup K_{1,4}$ supplies a complete counterexample to two degree-based claims about register allocation. It is chordal and has a perfect elimination ordering. Its maximum degree is $4$, yet it needs only $3$ colors, not $5$. Under a two-register budget, spilling its unique maximum-degree vertex leaves an uncolorable triangle, while spilling a degree-$2$ triangle vertex yields an explicit two-coloring.

The mathematical lesson is direct: maximum degree measures local incidence, whereas coloring and spilling are controlled by the structure of global obstructions. For chordal interference graphs, clique number is the right exact measure of register demand. Degree remains useful as an inexpensive bound or heuristic feature, but neither exact chromatic prediction nor optimal spill selection follows from it alone.
