# Two Colors, No Surrender: How Counting Beats Coloring

## A puzzle with paint

Imagine a committee of friends divided into overlapping clubs. You want to
paint every person either **red** or **blue** so that no single club ends up
entirely one color. Every club should contain at least one red member and at
least one blue member — a little internal disagreement in every room. When can
you guarantee that such a peaceful coloring exists?

This is not just a party game. It is one of the oldest and most beautiful
questions in combinatorics, and its answer reveals a surprising truth: you can
often prove that a solution *exists* without ever finding one. You simply count.

The clubs form what mathematicians call a **hypergraph**. In an ordinary graph,
an edge joins exactly two vertices. In a hypergraph, an *edge* can be any set of
vertices — a club of any size. Our question becomes: can we split the vertices
into two color classes so that no edge is **monochromatic** (all one color)? A
hypergraph that admits such a split is said to have **Property B**, named after
the mathematician Felix Bernstein who studied it over a century ago.

## The magic of "on average"

Here is the idea that changed mathematics. Suppose every club has at least $k$
members, and suppose there are not too many clubs. Instead of cleverly designing
a coloring, imagine coloring each person red or blue by flipping a fair coin.
Now ask: *what is the chance that some club turns out monochromatic?*

Fix one club with exactly $k$ people. For it to be all red, every one of its $k$
coin flips must come up red — probability $1/2^k$. It could also be all blue,
another $1/2^k$. So the chance that this one club is monochromatic is at most
$2 \cdot 2^{-k} = 2^{-(k-1)}$.

If there are $m$ clubs, the chance that *at least one* of them is monochromatic
is at most $m \cdot 2^{-(k-1)}$ — we simply add up the individual risks (the
"union bound"). Now watch the punchline: if

$$m < 2^{k-1},$$

then this total probability is strictly less than $1$. A bad outcome happens
less than all the time — so a good outcome must happen *some* of the time. There
exists a coloring with no monochromatic club. We have proved existence purely by
arithmetic, without exhibiting a single coloring.

This is the celebrated **probabilistic method**, pioneered by Paul Erdős. The
argument above is his 1963 theorem on Property B.

> **Theorem (Erdős, 1963).** If every edge of a hypergraph has at least $k \ge 1$
> vertices and the hypergraph has fewer than $2^{k-1}$ edges, then it has
> Property B: there is a red/blue coloring of the vertices with no monochromatic
> edge.

The largest number $m(k)$ such that *every* hypergraph with $k$-element edges and
at most $m(k)-1$ edges is two-colorable is called the **Property B function**.
Erdős's theorem says $m(k) \ge 2^{k-1}$.

## Counting without probability

There is a way to state the same argument that uses no probability at all — only
finite counting — and it is arguably even more transparent.

Suppose the vertex set has $N$ people. Then there are exactly $2^N$ possible
red/blue colorings (each person independently chooses a color). Think of a
coloring as the set $R$ of red vertices.

For a single edge $e$ with $|e|$ vertices, how many colorings make it entirely
red? The vertices of $e$ are forced to be red, and the remaining $N - |e|$
vertices are free — so exactly $2^{N-|e|}$ colorings. This is a special case of a
clean counting fact about the lattice of subsets:

> **Lemma (interval counts).** Fix a ground set $G$ with a subset $S \subseteq G$.
> The number of subsets $A \subseteq G$ that *contain* $S$ equals $2^{|G|-|S|}$,
> and the number of subsets $A \subseteq G$ that are *disjoint* from $S$ also
> equals $2^{|G|-|S|}$.

The first count fixes the elements of $S$ to be "in" and lets the rest vary; the
second fixes them to be "out." Both leave $|G|-|S|$ free choices. (The two counts
are mirror images of each other under the complement map $A \mapsto G \setminus A$.)

Applying this with $G$ the whole vertex set and $S = e$: since $|e| \ge k$, at
most $2^{N-k}$ colorings make $e$ all red, and at most $2^{N-k}$ make it all blue.
So at most $2 \cdot 2^{N-k} = 2^{N-k+1}$ colorings are bad *because of edge $e$*.

Summing over fewer than $2^{k-1}$ edges, the number of bad colorings is strictly
less than

$$2^{k-1} \cdot 2^{N-k+1} = 2^{N}.$$

But there are $2^N$ colorings in all. Fewer than $2^N$ of them are bad, so at
least one is good. The exact same conclusion, reached by pure enumeration.

## How sharp is it?

A lower bound is only half the story. Is $2^{k-1}$ the *right* threshold, or
could every hypergraph with even more edges still be two-colorable?

The answer is that the threshold is genuinely near the truth, and for small $k$
we can pin it down exactly. Consider $k = 2$, ordinary graphs. Erdős's bound says
any graph with fewer than $2^{2-1} = 2$ edges is two-colorable — a modest claim.
But what is the *smallest* graph that is **not** two-colorable? A graph is
two-colorable in this sense precisely when it is bipartite, and the smallest
non-bipartite graph is the **triangle**: three vertices $\{0,1,2\}$ with the three
edges $\{0,1\}$, $\{1,2\}$, $\{0,2\}$.

No matter how you two-color three vertices with two colors, some two of them
share a color — and if you are unlucky enough that the shared pair happens to be
an edge, that edge is monochromatic. Checking all $2^3 = 8$ colorings confirms
the triangle can never be properly two-colored: every coloring leaves at least
one edge monochromatic. So the triangle is a **non-two-colorable** $2$-uniform
hypergraph with exactly $3$ edges. This means $m(2) \le 3$, and together with the
easy fact that any two-edge graph is bipartite, we get the exact value

$$m(2) = 3.$$

The same story continues: the smallest non-two-colorable $3$-uniform hypergraph
is the famous **Fano plane** with $7$ edges, giving $m(3) = 7$.

## The contrapositive: a lower bound on stubborn hypergraphs

Turning the theorem around gives an equally useful statement. Call a hypergraph
**non-two-colorable** if *every* coloring leaves some edge monochromatic. The
theorem says these stubborn hypergraphs cannot be too sparse:

> **Corollary.** If a hypergraph is non-two-colorable and every edge has at least
> $k \ge 1$ vertices, then it has at least $2^{k-1}$ edges.

In other words, to defeat two colors you need to pay a price that grows
exponentially in the edge size. The triangle ($k=2$, $3 \ge 2^{1}$) and the Fano
plane ($k=3$, $7 \ge 2^{2}$) both respect this toll.

## Why it matters

The Property B theorem is a jewel because it distills the entire philosophy of
the probabilistic method into a single line of arithmetic. The same template —
color, count the bad cases, show they miss covering everything — powers Erdős's
lower bound on **Ramsey numbers** (that you cannot always avoid large monochromatic
cliques), constructions of high-girth high-chromatic graphs, error-correcting
codes, and countless results where an explicit construction is unknown or
hopeless but a random one provably works.

There is a deeper lesson here for anyone who has ever been told that mathematics
is about finding answers. Sometimes the most powerful thing you can prove is that
an answer is *out there*, hidden among exponentially many possibilities, without
ever laying eyes on it. You take a haystack, you count the needles you're afraid
of, and if there are fewer of them than there is hay, you know a safe straw
exists. That is the quiet genius of counting: it lets you win a search you never
have to run.
