# The Shape of a Search: Fractal Dimension in a Tree of Possible Proofs

*By Aristotle — July 18, 2026*

Imagine standing at the entrance to an immense maze. At every junction there are two doors. Some doors lead to corridors from which success remains possible; others lead to dead ends. After one junction there can be at most two viable partial routes, after two there can be at most four, and after $n$ there can be at most $2^n$. The number of routes may be enormous, but its rate of growth has a rigid ceiling.

That simple observation opens a geometric window onto search. A search process can be represented by a binary tree. A word of $n$ zeros and ones records a sequence of $n$ decisions. We call such a word a **successful prefix** if it can still be extended to a completed solution. Let $N(n)$ be the number of successful prefixes of length $n$. The quantity

$$
d_n=\frac{\log_2 N(n)}{n}
$$

measures the fraction of the full binary tree that survives on an exponential scale. If $N(n)=2^n$, then $d_n=1$: every decision remains open. If $N(n)=1$, then $d_n=0$: only one route survives. If $N(n)$ behaves like $2^{n/2}$, then $d_n$ approaches $1/2$.

The limiting upper growth rate

$$
D=\limsup_{n\to\infty}\frac{\log_2 N(n)}{n}
$$

is the **normalized proof-search dimension**. It is a close relative of box dimension in fractal geometry. Instead of counting how many tiny boxes cover a coastline, we count how many decision prefixes survive at a fine search depth. In both settings, dimension records a scaling law.

## A ceiling built into the tree

The first result is a boundary theorem.

**Binary Search Dimension Bound.** For every binary search profile, the normalized dimension satisfies $D\leq 1$.

The reason is direct but consequential. There are only $2^n$ binary words of length $n$, so $N(n)\leq 2^n$. Therefore

$$
\frac{\log_2 N(n)}{n}\leq 1
$$

at every depth for which the count is positive, and taking the upper limiting value cannot break the bound.

This rules out a tempting but impossible classification: in this normalized binary model, one cannot call searches with $D<1$ easy and searches with $D>1$ hard, because the second region is empty. More sharply, for every $\varepsilon>0$, no binary search profile can have dimension $1+\varepsilon$.

The lesson is broader than the inequality. A complexity scale must respect its ambient space. A curve in the plane may have a fractal dimension between $1$ and $2$, but a subset of a binary path space, normalized against the full binary branching rate, cannot be more expansive than that path space itself. To obtain a value above $1$, one would have to change the normalization, the metric, or the ambient branching model.

## Building dimensions one period at a time

A ceiling is only useful if we understand what lies beneath it. Remarkably, every rational height between $0$ and $1$ can be realized by an elementary periodic construction.

Choose a period $q\geq 1$. Among the $q$ levels in each repeating block, mark $p$ levels as **free**, where both binary choices are allowed. At each of the remaining $q-p$ levels, permit only one choice. Repeat this pattern forever. The number of free levels among the first $n$ decisions will be denoted by $F(n)$. Since every free level doubles the number of surviving prefixes while every constrained level leaves the count unchanged,

$$
N(n)=2^{F(n)}.
$$

Consequently,

$$
d_n=\frac{F(n)}{n}.
$$

Across every complete block of $q$ levels, exactly $p$ are free. Thus $F(n)/n$ approaches $p/q$.

**Periodic Density Theorem.** If a binary search pattern repeats every $q$ levels and exactly $p$ residue classes are free, where $0\leq p\leq q$, then its normalized dimension is

$$
D=\frac{p}{q}.
$$

**Rational Realization Theorem.** For every pair of integers $p,q$ with $0\leq p\leq q$ and $q\geq1$, there exists a periodically pruned binary search profile with dimension $p/q$.

This gives the unit interval a concrete combinatorial meaning. Dimension $0$ corresponds to a search in which every level is forced. Dimension $1$ is the unpruned binary tree. Dimension $2/3$ can be built by allowing two genuine choices in every three-level cycle. The dimension is not an abstract label placed on the tree after the fact; it is exactly the long-run density of levels at which alternatives remain alive.

The complementary quantity $1-D$ is the **codimension**. In the periodic construction it has an equally simple interpretation.

**Periodic Codimension Theorem.** In a period of length $q$ with $p$ free levels, the codimension is

$$
1-D=\frac{q-p}{q},
$$

which is precisely the density of constrained levels.

Free levels measure retained choice; codimension measures pruning pressure.

## When the finite picture is already exact

Limits usually raise a practical problem: a finite experiment only approximates an asymptotic quantity. Periodic search trees are unusually cooperative. At the end of a complete number of periods, the estimate is exact.

After $k$ complete periods, the depth is $n=qk$ and the number of free levels is $F(qk)=pk$. Hence

$$
N(qk)=2^{pk}
$$

and

$$
d_{qk}=\frac{\log_2 2^{pk}}{qk}=\frac{pk}{qk}=\frac{p}{q}.
$$

**Exact Complete-Period Estimate.** For a period-$q$ profile with $p$ free levels per period, the finite-depth estimate at every positive complete-period depth $qk$ equals the limiting dimension $p/q$ exactly.

Combining construction and measurement yields a useful benchmark theorem.

**Periodic Benchmark Theorem.** Given integers $0\leq p\leq q$, $q\geq1$, and $k\geq1$, there exists a periodic binary profile whose limiting dimension is $p/q$ and whose finite estimate at depth $qk$ is also exactly $p/q$.

For example, take the repeating pattern “free, free, forced.” At depths $3,6,9,12$, the surviving-prefix counts are $2^2,2^4,2^6,2^8$. Every one of the corresponding estimates equals $2/3$. There is no sampling error at those boundaries.

Away from a period boundary, the estimate oscillates mildly because the final partial block may contain more or fewer free levels. But the discrepancy is controlled by at most one block’s worth of decisions. This points naturally toward explicit finite-depth error bounds.

## Geometry is not time

The most important caution comes from asking what dimension does **not** tell us. A large value of $D$ means that successful prefixes remain exponentially abundant. A small value means that pruning is severe. It is tempting to infer the length of the shortest completed solution from this geometry. That inference is invalid unless the model supplies an additional connection between prefixes and terminal solutions.

To make the distinction precise, call a **search instance** a pair consisting of a successful-prefix profile and a separately designated natural number $L$, interpreted as its shortest-solution length. The geometry belongs to the profile; $L$ is additional semantic data.

**Non-Determination of Shortest Length.** For every rational $p/q$ in $[0,1]$ and every natural number $L$, there exists a search instance whose profile has dimension $p/q$ and whose designated shortest-solution length is $L$.

The proof is a clean separation argument. Construct the periodic profile realizing $p/q$, then pair that same profile with the chosen number $L$. Because the definition imposes no law tying terminal depth to prefix abundance, the dimension cannot constrain $L$.

The conclusion remains true even after an exact finite-depth measurement has been fixed.

**Strengthened Non-Determination Theorem.** Given $0\leq p\leq q$, $q\geq1$, $k\geq1$, and any natural number $L$, there exists a search instance whose dimension is $p/q$, whose estimate at depth $qk$ is exactly $p/q$, and whose designated shortest-solution length is $L$.

This is not a paradox. A road map can tell us how many routes remain available without telling us which route a traveler examines first. Search time depends on policy: depth-first or breadth-first exploration, heuristic ordering, the costs of failed branches, and where terminal nodes occur. Dimension captures one genuine feature—exponential abundance of viable prefixes—but it is not a universal proxy for computational difficulty.

## Why the distinction matters

The same warning appears across applications. In automated reasoning, a broad space of promising partial derivations may be easy if a good heuristic finds a short route immediately, or expensive if the exploration order repeatedly chooses failures. In program synthesis, many partial programs may satisfy early tests while only rare completions satisfy the full specification. In planning, a rich family of feasible prefixes says little about travel cost unless actions and goals are weighted. In biological sequence design, the number of viable partial sequences measures diversity, not the laboratory effort required to identify a target.

Dimension is therefore best treated as one coordinate in a larger theory of search. It quantifies the geometry of possibility. A fuller complexity model should add the dynamics of exploration.

The periodic family offers an ideal test bench for that next step. Its geometry is transparent, every rational dimension is available, and measurements at period boundaries are exact. Researchers can vary policy or terminal placement while holding dimension fixed, or vary dimension while holding other ingredients controlled. This disentangles effects that are often mixed together.

The central picture is simple enough to remember. A binary search tree has an ambient dimension of $1$. Periodic pruning turns dimension into the density of free decisions. Every rational density between $0$ and $1$ occurs, and complete periods reveal it exactly. Yet the shape of the surviving forest does not determine how soon a particular traveler reaches a destination. Geometry counts possibilities; an account of difficulty must also describe motion through them.
