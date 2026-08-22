# The Matrix That Refuses to Turn Around

## How a simple rule — never immediately retrace your step — turns a graph into a machine that counts its own cycles

Imagine you are wandering a city whose streets form a network: intersections joined by
roads. You may walk anywhere you like, subject to exactly one rule. When you arrive at an
intersection, you may leave by any road *except* the one you just came in on. No
U-turns. You must always press on.

This one prohibition, so mild it barely feels like a constraint, changes everything. It is
the difference between a random walk that dithers back and forth in a small neighbourhood
and one that genuinely explores. It is at the heart of how spectral algorithms detect
hidden communities in social networks, how zeta functions of graphs are defined, and how
one proves that certain graphs are as well-connected as it is mathematically possible for
a graph to be. And, as we shall see, it converts a graph into a bookkeeping device that
counts its own cycles with uncanny precision.

The purpose of this article is to explain one clean theorem — the *non-backtracking trace
formula* — and then to show how much combinatorial information falls out of it, almost for
free.

---

## From edges to darts

The first move is a small change of viewpoint that makes everything else work.

Take a finite simple graph $G$: a set $V$ of vertices, and a set $E$ of edges, each edge an
unordered pair of distinct vertices. No loops, no repeated edges.

Instead of edges, work with **darts**. A dart is an edge together with a choice of
direction: the pair $(u,v)$ with $u$ and $v$ joined by an edge. Every edge yields exactly
two darts, $(u,v)$ and $(v,u)$, so a graph with $|E|$ edges has $2|E|$ darts. If you prefer
a physical picture: a dart is an arrow drawn along an edge, and each edge carries two
arrows pointing opposite ways.

Why darts? Because the no-U-turn rule is not a rule about *where you are*; it is a rule
about *how you got there*. Standing at an intersection tells you nothing about which
street is forbidden. Standing at an intersection *having just travelled along a particular
street* tells you everything. The dart is precisely the amount of memory a
non-backtracking walker needs to carry.

So define a relation on darts. Say that the dart $e = (x,y)$ **may follow** the dart
$d = (u,v)$ when

$$v = x \quad\text{and}\quad y \neq u .$$

In words: the second arrow starts where the first one ends, and does not point straight
back to where the first one started. The first condition is composability; the second is
the no-U-turn rule.

This relation is recorded by a matrix. Index the rows and columns of a square array by the
$2|E|$ darts, and put a $1$ in position $(d, e)$ when $e$ may follow $d$, and a $0$
otherwise. The result is the **Hashimoto matrix** $B$ of the graph, also called the
non-backtracking matrix or the edge-adjacency matrix.

A crucial and slightly disorienting fact: $B$ is **not symmetric**. If $e$ may follow $d$,
it is generally false that $d$ may follow $e$ — indeed it is *never* true. (If $e$ follows
$d$ then $e$ ends somewhere new; for $d$ to follow $e$, $d$ would have to start there,
which forces a U-turn.) So $B$ is the adjacency matrix of a genuinely directed graph on
the darts, and none of the comfortable theory of symmetric matrices applies. This is not a
technicality to be waved away; it is the reason the standard machinery for counting walks
in undirected graphs has to be rebuilt from scratch here.

---

## The theorem

Here is the object we want to count. A **rooted closed non-backtracking walk of length
$n$** is a list of darts
$$d_0, d_1, \dots, d_n$$
such that each $d_{i+1}$ may follow $d_i$, and such that the list closes up:
$d_n = d_0$. "Rooted" means the starting dart is remembered — the same geometric loop
traversed from a different starting arrow counts as a different walk. "Closed" means you
finish where you began, pointing the way you were pointing when you set out.

> **The Non-Backtracking Trace Formula.** For every finite simple graph $G$ and every
> $n \ge 0$,
> $$\operatorname{trace}(B^n) \;=\; \#\{\text{rooted closed non-backtracking walks of length } n\}.$$

The trace, recall, is the sum of the diagonal entries. Why should the sum of $2|E|$ numbers
know anything about walks?

The mechanism is the oldest trick in algebraic combinatorics. Multiplying $B$ by itself and reading off the entry in row $d$, column $e$ gives
$$ (B^2)_{d,e} = \sum_{f} B_{d,f} B_{f,e} , $$
and each term in that sum is $1$ exactly when $f$ may follow $d$ *and* $e$ may follow
$f$. So $(B^2)_{d,e}$ counts the length-two non-backtracking walks from $d$ to $e$.
Inductively, $(B^n)_{d,e}$ counts the length-$n$ ones. Setting $e = d$ and summing over
all darts $d$ — that is, taking the trace — counts exactly the walks that return to their
starting dart, with the starting dart remembered. The theorem is nothing more than this
observation, executed carefully.

"Executed carefully" is doing real work, though: the correspondence must be built as an
explicit bijection between walks and terms of an iterated sum. Because the successor
relation is not symmetric, one has to develop walk-counting for an arbitrary directed
relation on a finite set and specialise at the end.

There is a second, more economical way to package the same information, and it will be
useful. Rather than a list of $n+1$ darts whose first and last agree, one can drop the
redundant final entry and keep a list of $n$ darts arranged in a **cycle**: each dart may
be followed by the next, and — this is the "seam" condition — the first dart may follow the
last. The two encodings are in bijection, so

$$\operatorname{trace}(B^n) \;=\; \#\{\text{cyclic non-backtracking words of } n \text{ darts}\}.$$

And there is a third form, purely in terms of vertices. A cyclic word of darts is the same
thing as a cyclic sequence of vertices $u_1, u_2, \dots, u_n$ in which consecutive vertices
are adjacent (reading indices around the circle) and, crucially, $u_{i+2} \ne u_i$ for
every $i$. That last inequality *is* the no-U-turn rule, expressed with no darts in sight:
never return to where you were two steps ago. So

$$\operatorname{trace}(B^n) = \#\{(u_1,\dots,u_n) : u_i \sim u_{i+1} \text{ and } u_{i+2} \ne u_i \text{ cyclically}\}.$$

This vertex form is the one to reach for when you want to think, and the dart form is the
one to reach for when you want to compute.

---

## What the theorem immediately tells you

Now the harvest. Each of the following is a statement about graphs, proved by a statement
about matrices — or the other way round, depending on which side you find easier.

**Nothing happens at lengths one and two.** A closed non-backtracking walk of length $1$
would be a dart that may follow itself, which would require a U-turn. A closed one of
length $2$ is a dart $d$, a dart $f$ following it, and then $d$ again following $f$; but
"$d$ follows $f$" after "$f$ follows $d$" is exactly a U-turn. Hence
$$\operatorname{trace}(B) = \operatorname{trace}(B^2) = 0$$
for every graph whatsoever. Compare the ordinary adjacency matrix $A$, where
$\operatorname{trace}(A^2) = 2|E|$ counts the there-and-back walks. Non-backtracking has
swept all of that away.

**Length three counts triangles.** A closed non-backtracking walk of length $3$ traverses
three vertices $a \to b \to c \to a$, and the constraints force these to be distinct — it
is an *ordered triangle*. Consequently
$$\operatorname{trace}(B^3) = \#\{(a,b,c) : a \sim b,\ b \sim c,\ c \sim a\} = 6 \cdot \#\{\text{triangles}\},$$
the factor $6$ being the three rotations times the two orientations. For the complete
graph $K_4$, which has four triangles, this gives $\operatorname{trace}(B^3) = 24$.

**The trace at zero is the number of darts.** $B^0$ is the identity on darts, so
$\operatorname{trace}(B^0) = 2|E| = \sum_{v} \deg(v)$. It is pleasing that even the trivial
case of the formula says something: the "walks of length $0$" are just the darts
themselves.

**Every trace is even, and here is why.** Reverse a closed non-backtracking walk: read the
darts backwards and flip each arrow. The result is again a closed non-backtracking walk of
the same length — the no-U-turn condition is symmetric under this operation — and doing it
twice returns you to where you started. So reversal is an involution on the set of walks.
Moreover it has **no fixed points**: a walk equal to its own reversal would have to have
its first dart equal to the flip of its last, and the last dart of a closed walk is the
first, giving $d = d^{-1}$, impossible since a dart never equals its own reverse. An
involution without fixed points partitions a finite set into pairs. Therefore

$$\operatorname{trace}(B^n) \text{ is even for every } n .$$

The algebraic shadow of this argument is elegant. Let $J$ be the permutation matrix that
sends each dart to its reverse. Then
$$J B J = B^{\mathsf T} .$$
Dart reversal conjugates the non-backtracking matrix into its own transpose. So although
$B$ is not symmetric, it is *similar* to its transpose by an explicit involution — which
already tells you that its spectrum is closed under the symmetries you would expect, and
that traces of powers are unchanged by transposition, as of course they must be.

**Row sums, and how fast walks proliferate.** How many darts may follow the dart $(u,v)$?
Every dart leaving $v$, except the one going back to $u$. That is $\deg(v) - 1$. So the
row of $B$ indexed by $(u,v)$ sums to $\deg(v) - 1$. In a $(q+1)$-regular graph — every
vertex having exactly $q+1$ neighbours — every row sums to the same number $q$, and then
every row of $B^n$ sums to $q^n$. Since the trace is at most the sum of all entries,
$$\operatorname{trace}(B^n) \;\le\; 2|E| \cdot q^n .$$
The number $q$ is the *branching factor* of the non-backtracking walk: at each step you
have $q$ genuine choices, having burned one on the road you came in by. This exponential
rate $q^n$, rather than $(q+1)^n$, is exactly why non-backtracking walks are the natural
object on regular graphs, and why the number $\sqrt{q}$ turns up in the
Alon–Boppana bound and the definition of a Ramanujan graph.

---

## The trace sequence sees the cycles — and only the cycles

Here is where the formula stops being a convenience and starts being a tool. Consider the
whole sequence
$$\operatorname{trace}(B^1), \operatorname{trace}(B^2), \operatorname{trace}(B^3), \dots$$
as a fingerprint of the graph. What does it see?

**It vanishes identically precisely on forests.**

> **Acyclicity Criterion.** A finite simple graph $G$ contains no cycle if and only if
> $\operatorname{trace}(B^n) = 0$ for every $n \ge 1$.

One direction is intuitive and the other is a genuine argument.

If $G$ *does* contain a cycle, take a shortest closed walk along it. Its vertex sequence
$u_1, \dots, u_m$ is a cyclic sequence of $m \ge 3$ distinct adjacent vertices, and
distinctness gives $u_{i+2} \ne u_i$ for free. So it is a closed non-backtracking walk, and
by the vertex form of the theorem $\operatorname{trace}(B^m) \ge 1$. Cycles produce
positive traces.

Conversely, suppose $G$ is a forest and, for contradiction, that some closed
non-backtracking walk exists. Reassemble the darts into an honest walk in the graph. The
no-U-turn condition says exactly that consecutive edges of this walk are distinct. But in a
forest, a walk whose consecutive edges are distinct cannot repeat a vertex — it must be a
*path*. A closed path has length $0$. Contradiction, since our walk has positive length.
Forests are exactly the graphs whose non-backtracking trace sequence is identically zero.

That already sharpens into something quantitative.

**The first nonzero term reveals the girth.** The *girth* of a graph is the length of its
shortest cycle. It is the single most basic measure of local structure: high girth means
the graph looks like a tree when viewed from close up.

> **Girth Criterion.** If $G$ contains a cycle, then
> $$\operatorname{girth}(G) = \min\{\, n \ge 1 : \operatorname{trace}(B^n) \ne 0 \,\}.$$

Both inequalities have to be checked. That the girth is an *upper* bound follows because
the shortest cycle produces a nonzero trace at its own length, as above. That it is a
*lower* bound is the harder half: if $\operatorname{trace}(B^n) \ne 0$, there exists a
closed non-backtracking walk of length $n$, and a walk with distinct consecutive edges,
however wildly it wanders, must contain a cycle of length at most $n$ inside the subgraph
it traverses. So no trace can be nonzero below the girth. The girth of a graph is, quite
literally, *the moment the non-backtracking trace wakes up*.

**And it wakes up loudly.** The first nonzero term is not merely positive; it is at least
$2 \cdot \operatorname{girth}(G)$:
$$2\,\operatorname{girth}(G) \;\le\; \operatorname{trace}\!\left(B^{\operatorname{girth}(G)}\right).$$
The reason is a small orbit count. A single cycle of length $m$ gives rise not to one
closed non-backtracking walk but to $2m$ of them: you may start at any of the $m$ darts
along it ($m$ rotations), and you may traverse it in either of $2$ directions. Because the
cycle's vertices are distinct, all $2m$ of these walks are different. This factor
$2m$ is a recurring signature. For the pentagon $C_5$, whose only cycle is itself, the
trace sequence is $0,0,0,0,10,0,0,0,0,10,\dots$ — and $10 = 2 \cdot 5$, on the nose. For
the Petersen graph, which has girth $5$ and exactly $12$ pentagons, one computes
$\operatorname{trace}(B^5) = 120 = 2 \cdot 5 \cdot 12$: every shortest cycle,
each counted $2m$ times, and nothing else.

**Adding edges never decreases the count.** If $H$ is a subgraph of $G$ on the same
vertices, then every closed non-backtracking walk of $H$ is one of $G$, and distinct walks
stay distinct. Hence
$$\operatorname{trace}(B_H^{\,n}) \;\le\; \operatorname{trace}(B_G^{\,n}) \quad\text{for all } n .$$
This is obvious combinatorially and completely opaque matrix-theoretically: the matrices
$B_H$ and $B_G$ do not even have the same size, and entrywise domination of non-symmetric
matrices does not in general survive taking powers. The combinatorial reading of the trace
does the work.

---

## Three graphs in full

Small examples make the machine visible.

**The triangle $K_3$.** Six darts. From each dart there is *exactly one* legal
continuation — you arrive somewhere, you cannot go back, and there is only one other place
to go. So $B$ is a permutation matrix, and since the triangle closes after three steps in
each direction, $B^3 = I$. Therefore
$$\operatorname{trace}(B^n) = \begin{cases} 6 & \text{if } 3 \mid n, \\ 0 & \text{otherwise.}\end{cases}$$
Six is $2 \cdot 3$: the three rotations times the two orientations of the single triangle,
exactly as the multiplicity principle predicts.

**The pentagon $C_5$.** Ten darts, and again each has a unique continuation; $B$ is a
permutation of order five (two $5$-cycles, one per orientation), so $B^5 = I$ and
$$\operatorname{trace}(B^n) = \begin{cases} 10 & \text{if } 5 \mid n, \\ 0 & \text{otherwise.}\end{cases}$$
The first nonvanishing index is $5$, which is the girth; the value there is
$10 = 2 \cdot 5$, meeting the lower bound with equality.

**The complete graph $K_4$.** Twelve darts, four triangles, three four-cycles. The
predictions are $\operatorname{trace}(B^3) = 6 \cdot 4 = 24$ ordered triangles, and
$\operatorname{trace}(B^4) = 8 \cdot 3 = 24$: each quadrilateral contributes
$2 \cdot 4 = 8$. Both are confirmed by direct computation. Note that at length $4$ the
count is *purely* cyclic — you might think a walk of length four could go around a triangle
and then take one more step, but it cannot close up if it does.

**A path.** For the path $0 - 1 - 2$, the matrix satisfies $B^2 = 0$: the non-backtracking
matrix of a tree is nilpotent, and every trace vanishes, as the acyclicity criterion demands.

---

## Why anyone cares

The non-backtracking matrix is not a curiosity. Three currents converge on it.

**Zeta functions of graphs.** Ihara associated to a finite graph a zeta function
$$\zeta_G(u) = \prod_{[\gamma]} \left(1 - u^{\ell(\gamma)}\right)^{-1},$$
the product running over equivalence classes of primitive closed non-backtracking cycles —
a direct combinatorial analogue of Euler's product over primes. The bridge from that
product to a *finite determinant* is exactly the trace formula: taking logarithms turns the
product over cycles into a sum over closed non-backtracking walks, which by our theorem is
$\sum_n \operatorname{trace}(B^n) u^n / n$, which is $-\log \det (I - uB)$. Ihara's theorem
then says that for a $(q+1)$-regular graph this determinant collapses to a much smaller
one built from the ordinary adjacency matrix,
$$\det(I - uB) = (1-u^2)^{|E|-|V|} \det\!\left(I - uA + qu^2 I\right).$$
The counting theorem is the combinatorial heart of that chain.

**Spectral algorithms and community detection.** In sparse random graphs, the ordinary
adjacency matrix is a poor guide: its top eigenvectors localise on high-degree vertices,
which are noise rather than signal. The non-backtracking matrix does not suffer from this,
because a walker that cannot U-turn cannot loiter around a hub. This observation underlies
the modern spectral method for the stochastic block model, which provably detects planted
communities right down to the information-theoretic threshold where detection becomes
possible at all — a threshold at which adjacency-based spectral methods fail outright.

**Expanders and the Ramanujan bound.** For a $(q+1)$-regular graph, the eigenvalues of $B$
are constrained by the geometry of non-backtracking walks, and the graph is *Ramanujan* —
optimally expanding, in the Alon–Boppana sense — exactly when the spectrum of $B$ outside a
trivial part lies on the circle of radius $\sqrt{q}$. That $\sqrt{q}$, the square root of
the branching factor we met in the row-sum bound, is the graph-theoretic Riemann
hypothesis.

In every one of these stories, the fundamental fact being used, sometimes silently, is
that powers of $B$ count non-backtracking walks and their traces count the closed ones.

---

## The shape of the idea

Step back and notice the pattern. We began with a rule about behaviour — *don't turn
around* — and found that the rule was not expressible in terms of where the walker is. So
we enlarged the state space, replacing vertices by darts, and in the enlarged space the
rule became local: a plain condition on consecutive states. Once local, it became a matrix.
Once a matrix, its powers counted walks and its traces counted loops, and every
combinatorial question we could ask — is there a cycle? how short? how many? does adding
edges help? — turned into a question about a sequence of integers.

That move, *pay for locality with a bigger state space*, is one of the durable ideas in
mathematics: it is the same move as passing from a second-order differential equation to a
first-order system, or from a non-Markovian process to a Markov one on histories. Here it
costs a factor of two in the size of the matrix, and buys a complete dictionary between the
linear algebra of $B$ and the cycle structure of $G$.

The dictionary reads, in summary:

| Property of the trace sequence | Property of the graph |
|---|---|
| $\operatorname{trace}(B^0) = 2\lvert E\rvert$ | number of darts |
| $\operatorname{trace}(B^1) = \operatorname{trace}(B^2) = 0$ | always |
| $\operatorname{trace}(B^3)$ | six times the number of triangles |
| every term even | dart reversal pairs walks up |
| identically zero | the graph is a forest |
| first nonzero index | the girth |
| value at the girth, $\ge 2\cdot\text{girth}$ | shortest cycles, each counted $2m$ times |
| monotone under adding edges | more edges, more cycles |

Every entry in that table is a theorem, and every one of them is a consequence of a single
sentence: *the trace of the $n$-th power of the non-backtracking matrix is the number of
rooted closed non-backtracking walks of length $n$*.

The rule was to never turn around. The reward is a graph that counts itself.
