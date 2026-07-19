# When Variables Compete: The Hidden Geometry of Register Allocation

A processor can perform billions of operations per second, but its fastest workspace is remarkably small. At any instant, a program may have many intermediate values waiting to be used, while the processor offers only a limited number of registers in which to keep them. The compiler must decide which values may share a register and which must remain separate. A poor decision causes a *spill*: a value is moved to slower memory and later loaded again. Enough spills can turn elegant source code into a traffic jam of memory operations.

This practical problem has a clean combinatorial heart. Draw one vertex for every program variable. Join two vertices when the corresponding values are simultaneously live—that is, when both values must still be available at the same moment. The resulting *interference graph* records exactly which variables cannot occupy the same register. Assigning registers is then the same as coloring the vertices so that adjacent vertices receive different colors. A palette of $k$ colors represents $k$ registers.

This translation is powerful, but it also warns us against an appealing mistake. The most connected variable does not, by itself, determine the number of registers required. The right answer depends not merely on how many conflicts each variable has, but on how those conflicts fit together.

## Three measures of pressure

Three numbers organize the story.

The *chromatic number* $\chi(G)$ is the smallest number of colors needed for a proper coloring of a graph $G$. In compiler language, it is the optimal register requirement when all registers are interchangeable.

The *maximum degree* $\Delta(G)$ is the largest number of neighbors of any vertex. It measures the worst local congestion: one variable may conflict with $\Delta(G)$ others.

The *clique number* $\omega(G)$ is the largest size of a clique, a set of vertices every pair of which is adjacent. A clique of size $m$ represents $m$ variables that are pairwise in conflict. They must occupy $m$ distinct registers, so

$$
\omega(G) \leq \chi(G).
$$

Maximum degree gives pressure of a different kind. If every vertex has at most $\Delta(G)$ neighbors, then a greedy procedure can color the graph using $\Delta(G)+1$ colors: when a vertex is colored, its neighbors can forbid at most $\Delta(G)$ colors. Thus

$$
\chi(G) \leq \Delta(G)+1.
$$

It is tempting to turn this upper bound into an equality. That temptation must be resisted.

## The three-vertex warning

Consider the smallest path with three vertices:

$$
A \;—\; B \;—\; C.
$$

The middle vertex $B$ has degree $2$, so $\Delta(G)+1=3$. Yet two colors suffice: give $A$ and $C$ the same color and give $B$ the other. Consequently,

$$
\chi(G)=2<3=\Delta(G)+1.
$$

This tiny graph overturns two broad claims at once. First, the maximum degree plus one is not an exact formula for register demand. Second, a program with fewer than $\Delta(G)+1$ registers need not spill. The path needs only two registers even though the degree bound offers three.

The lesson is conceptual. Degree counts how many separate conflicts touch one variable. A clique records simultaneous mutual conflict. In the path, $B$ conflicts with both $A$ and $C$, but $A$ and $C$ do not conflict with each other. They can therefore reuse a register. Local congestion is not the same as collective congestion.

## The structure that makes cliques decisive

There is, however, an important family of graphs for which clique pressure tells the whole story. A graph is *chordal* if every cycle of length at least four has a chord—an edge joining two nonconsecutive vertices of the cycle. Chordal graphs can also be recognized through a *perfect elimination ordering*.

A perfect elimination ordering lists the vertices so that, for every vertex, all of its neighbors appearing later in the list form a clique. Imagine repeatedly removing a vertex whose remaining neighbors already know one another. This produces a remarkably useful coloring certificate.

The central result is the following.

**Chordal Register Palette Theorem.** Suppose an interference graph has a perfect elimination ordering. Then it can be allocated using $k$ registers if and only if every clique in the graph has at most $k$ vertices.

One direction is unavoidable: if a clique contains more than $k$ variables, pairwise interference forces more than $k$ distinct registers. The other direction is the structural gift of the elimination ordering. Process the vertices in reverse elimination order. When a vertex is reached, its already colored neighbors form a clique. By assumption that clique has at most $k$ vertices; because the current vertex itself joins that clique, at most $k-1$ colors can be forbidden. At least one of the $k$ registers remains available.

Taking the smallest possible $k$ gives the exact identity

$$
\chi(G)=\omega(G)
$$

for every graph with a perfect elimination ordering. Here maximum degree remains a safe engineering bound, but clique size becomes the exact mathematical demand.

This distinction matters for compiler design. A degree-based allocator asks, “How many conflicts touch this variable?” An elimination-based allocator asks, “Which conflicts must coexist at this stage, and do they form a clique?” The latter question sees register reuse that the former can miss.

## Why interval lifetimes often help

Many scheduling problems describe each resource by an interval of time. Two jobs conflict when their intervals overlap. Their intersection graph is an *interval graph*, and interval graphs are chordal. The geometric reason is intuitive: among a collection of intervals, choose one that ends first. Every later-overlapping interval contains that earliest endpoint, so those neighbors all overlap one another and form a clique. Repeating the argument yields a perfect elimination ordering.

When variable live ranges truly behave like intervals, the largest number of mutually overlapping ranges gives the exact register requirement. More elaborate program control flow may produce tree-like rather than linear lifetimes, and additional semantic work is needed before chordality may be assumed. Merely labeling a program as being in a particular intermediate representation does not automatically prove that its interference graph has the required structure. The liveness model must justify it.

## Spilling as deletion

If only $k$ registers are available and the graph is not $k$-colorable, the allocator removes some vertices from the coloring problem. Operationally, those variables are spilled to memory. The graph asks: which vertices should be deleted so that the remainder can be colored with $k$ colors?

Cliques immediately impose a quantitative lower bound.

**Clique Spill Bound.** Let $S$ be a clique of size $m$, and suppose only $k<m$ registers are available. Every valid allocation must spill at least $m-k$ vertices of $S$.

The proof is a counting argument. Any unspilled members of $S$ remain pairwise adjacent, so at most $k$ of them can receive the $k$ available colors. Of the original $m$ clique members, at least $m-k$ must therefore be removed.

For example, a clique of size $7$ facing a budget of $4$ registers forces at least $3$ spills from that clique, regardless of what happens elsewhere in the program. This is not merely a heuristic warning; it is a certificate of unavoidable cost.

The bound also clarifies what a useful spilling algorithm must do. It must respond to overlapping clique constraints, not just rank vertices by degree. A high-degree vertex may touch many conflicts without belonging to the most expensive bottleneck. Conversely, a modest-degree vertex may lie in several critical cliques or may be cheap to spill. If variables have different execution frequencies or memory costs, degree alone ignores precisely the information that defines the objective.

## A small numerical laboratory

These principles can be tested on familiar graph families.

For a path with $n\geq 2$ vertices, the chromatic number is $2$, the clique number is $2$, and the maximum degree is $2$ once $n\geq 3$. The equality $\chi=\omega$ holds, while $\chi=\Delta+1$ fails.

For a complete graph on $n$ vertices, every variable conflicts with every other, so

$$
\chi(G)=\omega(G)=n=\Delta(G)+1.
$$

Here the degree bound is exact because local and collective congestion coincide.

For a tree with at least one edge, two colors always suffice, and its largest clique has size $2$. A star with many leaves may have enormous maximum degree, yet it still needs only two registers: all leaves may reuse one register while the center uses another. This dramatic separation shows why degree is a ceiling, not a demand forecast.

Finally, odd cycles expose the boundary of clique reasoning. A cycle of odd length at least five has no triangle, so $\omega(G)=2$, but it requires three colors. Such a cycle is not chordal. Without an elimination structure, pairwise clique pressure no longer captures every coloring obstruction.

## From rule of thumb to structural certificate

The best outcome is not a universal slogan such as “maximum degree tells us the answer.” It is a hierarchy of statements, each used where it belongs.

For every finite interference graph, $\Delta(G)+1$ registers are sufficient. For graphs with a perfect elimination ordering, $\omega(G)$ registers are necessary and sufficient. If the budget is smaller than a clique of size $m$, at least $m-k$ members of that clique must spill. And no degree-only rule can generally promise optimal spilling, especially when costs differ.

This hierarchy turns graph structure into actionable compiler knowledge. A perfect elimination ordering is more than a proof that coloring will work: it is an explicit schedule for assigning registers. A large clique is more than evidence of difficulty: it is a certificate of how many registers or spills are unavoidable. A counterexample as small as a three-vertex path is more than a curiosity: it prevents an upper bound from being mistaken for an exact law.

Behind the compiler’s rapid choices lies a broader principle of combinatorics. Counting neighbors measures local pressure. Understanding their arrangement reveals global possibility. The difference between those two views is exactly where efficient reuse lives.