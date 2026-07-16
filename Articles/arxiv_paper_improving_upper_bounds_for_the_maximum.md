# The Neighborhood Test That Makes Clique Search Smaller

## A global problem hidden inside local neighborhoods

A social network, a protein-interaction map, and a conflict graph from a scheduling problem can all be represented in the same spare language: vertices denote objects and edges denote pairwise compatibility. A **clique** is a set of vertices in which every two distinct vertices are adjacent. In a social network it is a group of mutual contacts; in a compatibility graph it is a collection of choices that can coexist; in a molecular network it may indicate a tightly interdependent complex.

Finding a largest clique is deceptively difficult. Checking a proposed group is easy: inspect every pair. Finding the largest one, however, may require navigating an enormous landscape of overlapping candidates. The practical art of maximum-clique computation therefore begins before the main search. One tries to remove vertices or patterns that cannot possibly participate in a clique large enough to matter.

The central idea developed here is simple but broad: **a partial clique can be extended only through vertices adjacent to every member of that partial clique**. If we possess any trustworthy upper estimate for the size of a clique inside that common neighborhood, then one arithmetic test can rule out the entire pattern.

This principle turns global information into local reduction rules. It strengthens the familiar core and truss viewpoints, explains why repeated peeling is safe, and allows independent bounding methods to be combined without sacrificing correctness.

## The oracle viewpoint

Let $G=(V,E)$ be a simple undirected graph: there are no loops, and adjacency is symmetric. For a vertex set $S\subseteq V$, imagine a function $U(S)$ that returns a nonnegative integer. We call $U$ a **clique upper-bound function** if every finite clique $C\subseteq S$ satisfies

$$
|C|\le U(S).
$$

The word “function” is deliberately permissive. The value could come from a coloring heuristic, a degeneracy calculation, a spectral estimate, an exact computation on a small subgraph, or the best of several methods. The mathematics needs only the displayed guarantee.

This abstraction separates correctness from implementation. A cheap bound may be loose but fast. A costly bound may be sharp enough to delete many more vertices. Both can enter the same reduction machinery.

There is also an immediate way to fuse two bounds. If $U_1$ and $U_2$ are valid, then

$$
U_{\min}(S)=\min\{U_1(S),U_2(S)\}
$$

is valid as well. Every clique is bounded by each estimate separately, hence by their minimum. This tiny observation matters computationally: independently designed bounding procedures can cooperate pointwise, with the stronger answer winning on every subproblem.

## The extension inequality

For a proposed pattern $D\subseteq V$, define its **common neighborhood** by

$$
N(D)=\{x\in V: x\text{ is adjacent to every vertex of }D\}.
$$

Now fix a current search region $S\subseteq V$. Suppose a finite clique $C\subseteq S$ contains $D$. The vertices of $C$ outside $D$ form the set $C\setminus D$. Because they lie in a clique, they remain mutually adjacent. Because each is adjacent to every member of $D$, they lie in $N(D)$. And because $C\subseteq S$, they lie in $S\cap N(D)$.

Thus $C\setminus D$ is itself a clique inside $S\cap N(D)$. Applying the upper bound gives

$$
|C\setminus D|\le U(S\cap N(D)).
$$

Since $C$ is the disjoint union of $D$ and $C\setminus D$, we obtain the **Clique Extension Bound**:

$$
|C|\le |D|+U(S\cap N(D)).
$$

This is the main structural result. Its proof is no more than a careful decomposition of a clique, but it supports a family of powerful conclusions.

Suppose the target is a clique of size at least $k$. If

$$
|D|+U(S\cap N(D))<k,
$$

then no clique of size at least $k$ contained in $S$ can contain $D$. This is the **Failed Extension Test**. It converts an upper estimate into an exclusion certificate: the pattern $D$ may be discarded from every relevant candidate.

The result does not claim that $D$ belongs to a clique when the test passes. Passing merely means that the upper bound has not ruled it out. Failing, by contrast, is decisive.

## Vertices: an upper-bound-enhanced core rule

Take $D=\{v\}$, a single vertex. Any clique $C\subseteq S$ containing $v$ and having size at least $k$ must satisfy

$$
k\le 1+U(S\cap N(\{v\})).
$$

The $1$ counts $v$ itself; every other clique vertex must lie in its neighborhood. Therefore, whenever

$$
1+U(S\cap N(\{v\}))<k,
$$

vertex $v$ cannot occur in any target-size clique and may be deleted.

The classical degree test is hidden inside this statement. If one uses the crude bound $U(X)=|X|$, the condition becomes $1+|S\cap N(v)|<k$, or degree less than $k-1$ in the current graph. A sharper clique bound can reject a vertex even when it has many neighbors: those neighbors may be plentiful but too poorly connected among themselves to support a large clique. The enhanced rule sees structure where degree sees only quantity.

This distinction is useful in real networks. A person can have many contacts who do not know one another; a software component can be compatible with many alternatives that are mutually incompatible. High degree alone does not imply membership in a large clique.

## Edges: an upper-bound-enhanced truss rule

Now take $D=\{u,v\}$ with $u\ne v$. If an edge $uv$ belongs to a clique $C\subseteq S$ of size at least $k$, every remaining vertex of $C$ must be adjacent to both endpoints. Hence

$$
k\le 2+U(S\cap N(\{u,v\})).
$$

The $2$ counts the endpoints. If the right-hand side is smaller than $k$, no target-size clique can contain that pair.

With the cardinality bound $U(X)=|X|$, this resembles the familiar triangle-support test: an edge in a $k$-clique has at least $k-2$ common neighbors. The upper-bound version is stronger. It asks not merely how many common neighbors exist, but how large a clique those common neighbors could contain. A large crowd around an edge is irrelevant if that crowd is internally fragmented.

Although vertex deletion is the iterative process proved safe here, the edge theorem supplies the mathematical certificate required for an analogous truss-style edge reduction. It also reveals that core and truss rules are not isolated tricks. They are the singleton and pair cases of one pattern-extension theorem.

## Why repeated peeling remains safe

A reduction rule becomes an algorithm when applied repeatedly. Start with a search set $S_0$. If a vertex $v_0\in S_0$ fails the enhanced core test, delete it to obtain

$$
S_1=S_0\setminus\{v_0\}.
$$

Recompute neighborhoods and bounds in $S_1$, delete another certified vertex, and continue:

$$
S_0\supseteq S_1\supseteq S_2\supseteq\cdots\supseteq S_t.
$$

Could a sequence of individually reasonable deletions accidentally destroy a large clique? The **Core Peeling Preservation Theorem** says no. If $C$ is any finite clique with $C\subseteq S_0$ and $|C|\ge k$, then

$$
C\subseteq S_i
$$

for every stage $i$, and in particular $C\subseteq S_t$.

The proof follows the algorithm. At one step, suppose the deleted vertex belonged to $C$. The singleton extension inequality would force it to pass the test, contradicting the certificate used to delete it. Thus the deleted vertex is outside $C$. Induction over the sequence proves the claim.

This theorem is stronger than preservation of one optimum chosen in advance. It preserves **every** clique at or above the target size. Consequently, if the purpose is to decide whether such a clique exists, enumerate all such cliques, or continue an exact optimization search above an incumbent lower bound, the peeling process loses no relevant solution.

## A small example

Let the target be $k=5$. Suppose a vertex $v$ has eight neighbors in the current search set. Degree alone cannot delete it, because $8\ge 4$. But assume a coloring routine colors the graph induced by those neighbors with three colors. A clique contains at most one vertex of each color, so $U(S\cap N(v))=3$. Then

$$
1+U(S\cap N(v))=4<5,
$$

and $v$ is safely removed. The rule has converted a structural fact—three-colorability of the neighborhood—into a decisive certificate.

For an edge $uv$, suppose there are six common neighbors, but they form a bipartite graph. Its clique number is at most $2$, so

$$
2+U(S\cap N(\{u,v\}))\le 4<5.
$$

No $5$-clique can use that edge, despite its substantial triangle support.

## Cost, strength, and the design of solvers

The mathematics does not prescribe one upper bound. That freedom creates a practical spectrum. Cardinality is almost free but weak. Greedy coloring is usually inexpensive and often much sharper. Exact clique computation in each neighborhood may be prohibitive, yet it can be attractive for tiny residual subgraphs. The minimum theorem lets a solver layer methods: compute a cheap estimate first, invoke a stronger estimate only when useful, and retain the best valid value.

Reduction and bounding then form a feedback loop. Better bounds permit more deletions. Deletions shrink neighborhoods, which can improve later bounds. Those improved values trigger further deletions. Peeling continues until no vertex fails, leaving a fixed point that is smaller but equivalent for all cliques meeting the target.

The same pattern extends beyond single vertices and edges. For any proposed set $D$, the quantity

$$
|D|+U(S\cap N(D))
$$

measures the largest clique containing $D$ that the bound still allows. Larger patterns may yield stronger exclusions but cost more to enumerate and evaluate. This is a general algorithmic trade-off: invest more local computation to save more global search.

## The broader lesson

Maximum clique is global, but every clique extension is constrained by a common neighborhood. The extension inequality makes that constraint quantitative. It says that a pattern brings its own vertices, while all additional vertices must come from a tightly specified region; an upper bound on that region limits the whole clique.

From this one statement follow safe vertex pruning, safe pair exclusion, and safe repeated peeling. Independent upper bounds combine by taking their minimum. Classical degree and common-neighbor rules appear as coarse special cases, while coloring, degeneracy, or other structural estimates produce stronger variants.

The enduring idea is not tied to one data set or one implementation. It is a way of designing reductions: identify what any completion must look like, bound the completion region, and delete a pattern only when the resulting arithmetic makes the target impossible. In difficult combinatorial searches, a short impossibility certificate can be worth more than exploring millions of possibilities. Here, the certificate is local, composable, and strong enough to protect every large clique while the surrounding graph is peeled away.
