# From Roots to Paths: How Local Counting Makes Every Vertex Distinct

A graph can look anonymous. Draw a web of dots and lines, erase the labels, and many vertices may seem interchangeable. Yet a surprisingly sensitive way to distinguish them is to count small journeys. Choose a path on three vertices—a pair of consecutive edges, shaped like a bent or straight piece of wire—and ask how many copies pass through each vertex. Better still, prescribe the role the vertex must play: does it sit in the middle of the path, or at one of its ends?

These questions turn a graph into a collection of numerical fingerprints. They also expose a subtle tension. Counting every three-vertex path through a vertex can distinguish all vertices even when counting only end roles cannot. Counting only middle roles, meanwhile, can never distinguish all vertices in any nontrivial finite simple graph. The reason is not geometric but arithmetic: middle-role counts know only a vertex’s degree.

Alongside this obstruction is a constructive principle of broad use. If many graph statistics vary affinely with a common parameter, and their slopes distinguish the vertices, then one sufficiently large parameter makes all those statistics injective at once. It is the familiar idea that different long-term growth rates eventually overwhelm bounded initial discrepancies—but sharpened into a uniform theorem for a finite family of statistics.

Together, these results provide a compact toolkit for designing graphs in which vertices are identifiable by the paths they support.

## Path counts as fingerprints

A **finite simple graph** consists of finitely many vertices joined by edges, with no loops and no multiple edges. The **degree** $d(v)$ of a vertex $v$ is the number of its neighbors. Let $P_3$ be the path with three vertices and two edges.

There are three natural statistics at a vertex $v$:

- the **central-root count** $C(v)$, the number of copies of $P_3$ in which $v$ is the middle vertex;
- the **end-root count** $E(v)$, the number of copies in which $v$ is an endpoint;
- the **ordinary count** $O(v)$, the number of copies containing $v$ in either role.

A statistic is called **irregular** when it assigns different values to every pair of distinct vertices. Thus ordinary $P_3$-irregularity means that the map $v\mapsto O(v)$ is injective; central-root irregularity and end-root irregularity are defined similarly.

The central count has an immediate formula. To create a path centered at $v$, choose two distinct neighbors of $v$. Therefore

$$
C(v)=\binom{d(v)}{2}.
$$

For an end-rooted path beginning at $v$, first choose a neighbor $u$, then continue from $u$ to any neighbor other than $v$. Hence

$$
E(v)=\sum_{u\sim v}\bigl(d(u)-1\bigr).
$$

Every copy of $P_3$ containing $v$ places it in exactly one of the two roles, so

$$
O(v)=C(v)+E(v).
$$

These three elementary identities contain the whole local story.

## Why the center can never label everyone

One might hope that central-root counts distinguish vertices in a sufficiently asymmetric graph. They cannot.

**Central-root obstruction.** In every finite simple graph with at least two vertices, two distinct vertices have the same central-root $P_3$ count. Consequently, no such graph is central-root $P_3$-irregular.

The proof begins with a classic degree collision. In a graph on $N$ vertices, degrees lie between $0$ and $N-1$. But degree $0$ and degree $N-1$ cannot both occur: a vertex adjacent to everyone cannot coexist with an isolated vertex. Thus only $N-1$ degree values are available for $N$ vertices. Two vertices $v\ne w$ must have $d(v)=d(w)$. The formula $C(x)=\binom{d(x)}2$ then gives $C(v)=C(w)$.

This is a structural impossibility, not a failure to search cleverly enough. The central root sees only the number of incident edges, not how the surrounding graph is arranged. Any statistic determined solely by degree inherits the same obstacle.

The lesson reaches beyond graph theory. A local sensor cannot identify every location if its reading compresses the environment into too small a set of possible values. To break symmetry, one must collect information from a wider neighborhood.

## Compensation: when one count collides, another must separate

The end-root count does look outward: it records the degrees of neighboring vertices. This creates a compensation law.

**Degree-collision compensation theorem.** Suppose the ordinary $P_3$ count is irregular. If two distinct vertices $v$ and $w$ have equal degree, then their end-root counts differ:

$$
d(v)=d(w)\quad\Longrightarrow\quad E(v)\ne E(w).
$$

Indeed, equal degrees imply equal central counts. If the end counts were also equal, then $O=C+E$ would give $O(v)=O(w)$, contradicting ordinary irregularity.

Combining this observation with the unavoidable repeated-degree pair gives a stronger statement.

**Compensating-pair theorem.** Every ordinary $P_3$-irregular finite simple graph with at least two vertices contains distinct vertices $v,w$ such that

$$
C(v)=C(w)\qquad\text{but}\qquad E(v)\ne E(w).
$$

The total fingerprint succeeds precisely because the end contribution repairs a collision in the central contribution. This is a useful design principle: when a statistic is assembled from components, injectivity of the total forces unresolved collisions in one component to be broken by another.

The converse is false in a revealing way. Ordinary irregularity does not force the end count to distinguish *every* pair—only pairs whose central contributions coincide.

Consider the graph on vertices $0,1,2,3,4,5$ with edges

$$
\{0,2\},\ \{0,3\},\ \{0,5\},\ \{1,2\},\ \{1,4\},\ \{2,3\}.
$$

Its degree sequence is

$$
(3,2,3,2,1,1),
$$

so its central counts are

$$
(3,1,3,1,0,0).
$$

The end-root counts are

$$
(3,2,4,4,1,2),
$$

and therefore the ordinary counts are

$$
(6,3,7,5,1,2).
$$

All six ordinary counts are distinct, but the end-root count $4$ occurs twice, at vertices $2$ and $3$. Their central counts, $3$ and $1$, compensate in the opposite direction, leaving ordinary counts $7$ and $5$. This example marks the exact boundary of the compensation theorem.

## The affine engine

How can one arrange simultaneous irregularity for not just one statistic, but many rooted and ordinary path counts? A common construction strategy introduces a large integer parameter $t$: perhaps branches are repeated, stretched, or weighted according to $t$. Each count then often takes the affine form

$$
A_{i,v}(t)=c_{i,v}+t\,m_{i,v},
$$

where $i$ labels the statistic, $v$ labels the vertex, $c_{i,v}$ is an intercept, and $m_{i,v}$ is a slope.

The intercept records bounded background effects. The slope records the feature amplified by the construction. If slopes differ from vertex to vertex, amplification eventually makes the fingerprints distinct.

**Simultaneous affine separation theorem.** Let $I$ and $V$ be finite sets. For every statistic $i\in I$ and object $v\in V$, let $c_{i,v}$ and $m_{i,v}$ be nonnegative integers. Assume:

1. there is a common bound $B$ such that $c_{i,v}\le B$ for all $i,v$;
2. for each fixed $i$, the slopes $m_{i,v}$ are pairwise distinct as $v$ varies.

Then for every integer $t>B$, each map

$$
v\longmapsto c_{i,v}+t\,m_{i,v}
$$

is injective, simultaneously for all $i\in I$.

To see why, order two unequal slopes as $m_{i,v}<m_{i,w}$. Their gap is at least $1$, so multiplication by $t$ gives the larger slope an advantage of at least $t$. The smaller profile can receive at most $B$ units of intercept, while the larger profile has a nonnegative intercept. Since $t>B$,

$$
c_{i,v}+t m_{i,v}<c_{i,w}+t m_{i,w}.
$$

Finiteness matters because it allows one common bound $B$ to control all intercepts. The theorem then separates every vertex for every chosen statistic with a single choice of $t$.

The strict threshold is essential. At $t=B$, a one-unit slope advantage can be canceled exactly by an intercept difference of $B$. For example, the profiles $B+t\cdot 0$ and $0+t\cdot 1$ coincide when $t=B$. “Large enough” here means strictly beyond the entire intercept range.

## From a local identity to a construction program

The affine theorem does not by itself build a graph. Instead, it tells a graph designer exactly what to target. For each rooted position and each path length under consideration, derive the path count as an affine profile in a shared parameter. Bound every intercept uniformly. Then make the leading slopes injective across vertices. Once these tasks are complete, one threshold separates all profiles at once.

This division of labor is powerful. The graph-theoretic work is local: calculate how attachments contribute to paths. The final simultaneous conclusion is algebraic and uniform. It avoids proving pairwise inequalities separately for every vertex, root position, and path length.

Longer paths will often produce polynomial rather than affine profiles. That suggests comparing the first coefficient at which two profiles differ, much as one compares numbers lexicographically. Rooted trees offer another direction: their embeddings decompose recursively over branches, so attachment constructions may turn local counts into sums and products of simpler profiles.

The exceptional center of $P_3$ remains a warning sign. Root position matters. A root orbit whose count is forced to depend only on degree can never produce complete irregularity in a nontrivial finite graph, while an endpoint can inspect enough of the neighborhood to escape that obstruction.

## A broader picture

Path counts are small, but the philosophy is large. Networks are often understood through local signatures: communication routes through a router, short molecular chains through an atom, motifs around a neuron, or bounded itineraries through a state graph. A signature assembled from several roles can be more discriminating than any one role alone. When one component is blind to a symmetry, another may compensate.

The mathematics gives three crisp messages. First, central three-vertex paths are degree statistics and therefore inevitably collide. Second, ordinary irregularity forces end-root separation exactly where equal degree makes the center blind, though it need not make end-root counts globally injective. Third, a finite family of affine fingerprints with bounded intercepts and injective slopes becomes simultaneously separating beyond one explicit threshold.

In short: roots determine what a path can see, decomposition reveals how different views cooperate, and growth rates provide a scalable route from local asymmetry to global identification.