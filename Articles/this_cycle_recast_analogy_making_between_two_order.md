# From Triangles to Prime Divisors: How Local Structure Forces Global Complexity

Mathematics often advances by discovering that an object is carrying more information than it first appears to contain. A triangle in a network is not merely a three-way connection: it certifies the existence of three edges. A prime dividing a Fibonacci number is not merely a factor: if it has never appeared earlier in the sequence, it marks the arrival of genuinely new arithmetic structure.

These two observations live in different neighborhoods of mathematics. One belongs to extremal graph theory, where one asks how densely a network must be connected to support a prescribed number of patterns. The other belongs to number theory, where one follows the prime factors appearing along a recurrence. Yet they share a common narrative. Repeated local evidence eventually forces a global resource: many triangles force many edges, while sufficiently late Fibonacci terms in a large explicit range force a new prime divisor.

This article develops both statements from first principles. The first is a conceptual bridge between set systems and graphs. The second is a precise finite-range form of Carmichael’s primitive-divisor phenomenon.

## The shadow cast by a triangle

A finite simple graph consists of vertices joined by undirected edges, with no loops and no repeated edges. A **clique** is a set of vertices in which every two distinct vertices are adjacent. Thus a two-vertex clique is exactly an edge, and a three-vertex clique is exactly a triangle.

Now forget the graph for a moment and think only about sets. If $\mathcal{A}$ is a family of $r$-element sets, its **lower shadow** is the family

$$
\partial \mathcal{A}=\{T: |T|=r-1\text{ and }T\subseteq S\text{ for some }S\in\mathcal{A}\}.
$$

The name is apt. Each set in $\mathcal{A}$ sheds one element in every possible way, casting a collection of smaller sets beneath it. For a family of triangles, the shadow consists of all vertex pairs obtained by deleting one vertex from one of those triangles.

Here is the key structural fact: **the shadow of the triangle family is contained in the edge family**. Indeed, take any triangle $a,b,c$. Deleting $a$ leaves the pair $b,c$; because all pairs in a triangle are adjacent, that pair is an edge. The same is true after deleting either of the other vertices.

That sounds almost too simple to matter. But it gives access to one of extremal combinatorics’ central principles: the Kruskal–Katona theorem. In the form needed here, it says that if a family of three-element sets has at least

$$
\binom{k}{3}
$$

members, then its lower shadow has at least

$$
\binom{k}{2}
$$

members. The complete collection of triples on $k$ points shows why these binomial coefficients are natural: it contains exactly $\binom{k}{3}$ triples, and its shadow contains exactly $\binom{k}{2}$ pairs.

Combining the shadow theorem with the structural observation produces a clean graph-theoretic result.

**Triangle–edge theorem.** Let $G$ be a finite simple graph on $n$ vertices. If $3\le k\le n$ and $G$ contains at least $\binom{k}{3}$ triangles, then $G$ contains at least $\binom{k}{2}$ edges.

The proof is a three-step pipeline. Form the family $\mathcal{A}$ of all triangles of $G$. This is a uniform family of three-element sets. Kruskal–Katona gives $|\partial\mathcal{A}|\ge\binom{k}{2}$. Every member of $\partial \mathcal{A}$ is an edge, so the graph has at least that many edges.

The bound is exact. The complete graph on $k$ vertices, together with any number of isolated vertices, has exactly $\binom{k}{3}$ triangles and $\binom{k}{2}$ edges. No universal improvement is possible.

## Why a shadow is better than counting three times

A first attempt might count triangle-edge incidences. Every triangle contains three edges, so $T$ triangles produce $3T$ incidences. But a single edge can belong to many triangles—up to $n-2$ of them—yielding only

$$
|E(G)|\ge \frac{3T}{n-2}.
$$

When $T=\binom{k}{3}$ and $n$ is much larger than $k$, this estimate can be far weaker than $\binom{k}{2}$. It is distracted by vertices that play no role. The shadow argument instead detects the concentrated geometry of the triangles. It says that the smallest possible collection of supporting edges occurs when the triangles bunch together as though they came from a complete graph.

This matters in network science. Triangles are used as signatures of clustering: three people who all know one another, three proteins with pairwise interactions, or three computers with redundant communication links. The theorem converts a threshold of local clustering into a guaranteed infrastructure cost. If a network realizes at least $\binom{k}{3}$ distinct triangular motifs, then at least $\binom{k}{2}$ pairwise links must be present, regardless of how many irrelevant isolated vertices surround the active core.

The argument is also an example of a broad mathematical strategy: translate a problem into the language where the right theorem already sees its shape. A graph’s triangles become a uniform set family; its edges become the family that contains the shadow. Once translated, the inequality is nearly inevitable.

## New primes along the Fibonacci sequence

The second story begins with the Fibonacci numbers

$$
F_0=0,\qquad F_1=1,\qquad F_{n+2}=F_{n+1}+F_n.
$$

The sequence starts

$$
0,1,1,2,3,5,8,13,21,34,55,89,144,\ldots.
$$

A prime $p$ is called a **primitive prime divisor** of $F_n$ if

$$
p\mid F_n
$$

but

$$
p\nmid F_j\qquad\text{for every }1\le j<n.
$$

Such a prime is new at stage $n$: it has not divided any earlier positive-index Fibonacci number. For example, $13$ is a primitive prime divisor of $F_7=13$. The prime $2$ divides $F_6=8$, but it is not primitive there because it already divides $F_3=2$.

Primitive divisors measure arithmetic novelty. Fibonacci numbers inherit factors from earlier terms in a highly organized way. In particular,

$$
\gcd(F_m,F_n)=F_{\gcd(m,n)}.
$$

Thus divisibility relationships among indices create divisibility relationships among terms. A primitive divisor is a factor that cannot be explained by this inherited history.

The established finite-range result is the following.

**Fibonacci primitive-divisor theorem on the range $13\le n\le 10000$.** For every integer $n$ satisfying $13\le n\le 10000$, there exists a prime $p$ such that $p\mid F_n$ and $p\nmid F_j$ for every $1\le j<n$.

The upper endpoint is part of the statement. This theorem makes no claim about indices above $10000$. Within its stated range, however, every term possesses a genuinely new prime witness.

The proof naturally divides according to whether the index $n$ is prime or composite. At prime indices, standard Fibonacci divisibility properties isolate a primitive factor once $n$ is at least $13$. Composite indices require more care because factors inherited from proper divisors of $n$ may account for a substantial part of $F_n$.

To organize that issue, remove from $F_n$ all prime-power contributions whose primes have already appeared in earlier positive-index Fibonacci numbers. Call what remains the **primitive part** of $F_n$. If this primitive part exceeds $1$, it has a prime divisor. By construction, any such prime divides $F_n$ and no earlier $F_j$, so it is primitive.

For each composite $n$ in the interval $14\le n\le10000$, the primitive part is greater than $1$. Consequently a primitive prime divisor exists. The prime-index and composite-index arguments then combine to cover every $n$ from $13$ through $10000$.

A few examples make the definition tangible. Since

$$
F_{13}=233,
$$

and $233$ is prime, it is primitive at index $13$. Next,

$$
F_{14}=377=13\cdot29.
$$

The factor $13$ appeared at index $7$, but $29$ did not divide an earlier positive-index term, so $29$ is primitive at index $14$. Also,

$$
F_{15}=610=2\cdot5\cdot61.
$$

The primes $2$ and $5$ appeared earlier, while $61$ is new, making it the primitive divisor at index $15$.

## Two kinds of unavoidable novelty

The graph theorem and the Fibonacci theorem are not instances of one technical framework, and they should not be forced into one. Their kinship is methodological.

In the graph problem, one strips a triangle down to its two-element faces. The shadow retains exactly the supporting structure that must be present. In the Fibonacci problem, one strips a term of inherited prime contributions. The primitive part retains exactly the new arithmetic structure that must be present.

Both constructions separate what is forced by the past from what is newly demanded by the present. The shadow asks: which edges must exist because these triangles exist? The primitive part asks: which factors remain after all earlier appearances have been accounted for?

There is also a shared extremal flavor. The complete graph on $k$ vertices is the most economical support for $\binom{k}{3}$ triangles, using exactly $\binom{k}{2}$ edges. A Fibonacci term at index $n$ carries inherited factors as economically as its divisibility history permits, yet throughout the stated range that inheritance never exhausts the term: at least one new prime remains.

For computation, the two conclusions lead to transparent experiments. Given a finite graph, enumerate its triples, retain those whose three pairs are edges, and compare the triangle count with binomial thresholds. Given an index $n$, generate Fibonacci numbers, factor $F_n$, and test each prime factor against all earlier terms. These are not substitutes for the arguments, but they expose the mechanisms and make small cases visible.

The larger lesson is that local patterns can carry certificates of global complexity. Sometimes the certificate is geometric: a triangle’s faces. Sometimes it is arithmetic: a prime appearing for the first time. In either case, the right act of subtraction—deleting a vertex or removing inherited factors—reveals what the object could not have avoided creating.