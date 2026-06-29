# How Many Friendships Can a Triangle-Free World Hold?

Imagine a vast social network — millions of people, each connected to some
of the others. Now add one strange rule: **no three people may all know each
other.** No closed triangles of mutual acquaintance. In the language of
mathematics, the *friendship graph* must be *triangle-free*.

It feels like a mild restriction. Surely you can still pack in an enormous
number of friendships? The surprising answer, discovered by the Hungarian
mathematician Pál Turán in the 1940s and anticipated by Willem Mantel decades
earlier, is that this single innocent rule slashes the maximum number of
possible connections roughly in half — and pins the answer to an astonishingly
precise number. This is the story of **extremal graph theory**: the science of
how much structure a network can hold before a forbidden pattern is forced to
appear.

## The cast of characters

A **graph** is just a collection of dots (**vertices**) joined by lines
(**edges**). Vertices are people, edges are friendships. The **degree** of a
vertex is the number of edges touching it — your number of friends. A
**triangle** is three vertices that are all pairwise connected, and a
**clique** of size *r* (written *K_r*) is *r* vertices that are *all* pairwise
connected — a perfectly cliquey friend group where everyone knows everyone.

A graph is **K_r-free** if it contains no such group of size *r*. Triangle-free
means *K_3*-free. The central question of extremal graph theory is deceptively
simple:

> If a graph on *n* vertices forbids a certain clique, how many edges can it
> possibly have?

## Mantel's theorem: the half-and-half world

Here is the headline result, and it is exact.

> **Mantel's Theorem.** A triangle-free graph on *n* vertices has at most
> ⌊*n²*/4⌋ edges.

In our formalization this appears as the clean inequality

> **4 · |E| ≤ n²,**

where |E| is the number of edges. For *n* = 100 people, that is at most 2,500
friendships, out of the 4,950 that would be possible if everyone knew everyone.
Forbidding triangles costs you almost exactly half of all possible
connections.

And the bound is not just an abstract ceiling — it is *achievable*. Split your
*n* people into two equal-sized camps and let everyone befriend everyone in the
*other* camp, but no one in their own. This **complete bipartite graph** has no
triangles (any triangle would need two vertices on the same side, who are not
connected) and it realizes exactly ⌊*n²*/4⌋ edges. The extremal world is a
perfectly polarized one: two factions, total mutual admiration across the
divide, total indifference within.

## The trick: two friends can't crowd the room

Why is the answer exactly a quarter of *n²*? The proof is a small masterpiece
of *double counting*, and it rests on one vivid observation.

In a triangle-free graph, **two friends can have no friend in common.** If
Alice and Bob are friends, and they both knew Carol, then Alice, Bob, and Carol
would form a triangle — forbidden! So the friend-circles of any two connected
people are completely disjoint. We proved exactly this:

> **Disjoint neighborhoods.** In a triangle-free graph, if *u* and *v* are
> adjacent, then their neighborhoods *N(u)* and *N(v)* share no vertex.

Since these two disjoint friend-circles both live inside the same population of
*n* people, their sizes can't add up to more than *n*:

> **Degree bound on an edge.** For any edge {*u*, *v*} in a triangle-free
> graph, deg(*u*) + deg(*v*) ≤ *n*.

Now comes the accounting. Sum that inequality over every edge. On the
right-hand side you simply get *n* times the number of edges. On the left, a
clever rearrangement shows the total equals the **degree energy** of the graph
— the sum of every vertex's degree *squared*:

> **Degree energy is bounded.** In a triangle-free graph,
> ∑ deg(*v*)² ≤ *n* · |E|.

The phrase "degree energy" is borrowed from physics: squaring rewards
concentration, the way kinetic energy rewards speed. This quantity turns up
everywhere in network science, from measuring how "hub-dominated" a network is
to bounding how fast information spreads.

## The other half of the scissors: Cauchy–Schwarz

We now have an *upper* bound on degree energy. To finish, we need a *lower*
bound, and it comes from one of the most reliable tools in all of mathematics:
the **Cauchy–Schwarz inequality**. Applied to degrees, it says:

> **Degree-energy lower bound.** For any graph,
> *n* · ∑ deg(*v*)² ≥ (∑ deg(*v*))².

This is just the statement that the average of the squares is at least the
square of the average — spreading degrees out unevenly can only *increase* the
energy. Combine it with the **Handshaking Lemma**, the oldest fact in graph
theory, which says that summing everyone's number of friends double-counts
every friendship:

> **Handshaking Lemma.** ∑ deg(*v*) = 2 · |E|.

Chaining the pieces together is pure poetry:

(2|E|)² = (∑ deg)²  ≤  *n* · ∑ deg²  ≤  *n* · (*n* · |E|) = *n²* · |E|.

Cancel one factor of |E| and you are left with 4|E| ≤ *n²* — Mantel's theorem,
exactly. The lower bound from Cauchy–Schwarz and the upper bound from
triangle-freeness close like a pair of scissors on the single true answer.

## Beyond triangles: Turán's grand generalization

What if we forbid not triangles but *four*-cliques, or *five*-cliques? Turán
answered this completely, and the extremal graph is a thing of beauty: the
**Turán graph** *T(n, p)*. Split *n* vertices into *p* groups as evenly as
possible, and connect two vertices exactly when they live in *different*
groups. In our formalization the groups are simply the residue classes modulo
*p*: vertices *x* and *y* are friends precisely when *x* and *y* leave different
remainders when divided by *p*.

This graph is the densest possible *K_{p+1}*-free graph, and the reason it
contains no clique of size *p+1* is a one-line application of the
**pigeonhole principle**:

> **Turán graph clique-freeness.** The Turán graph *T(n, p)* is *K_{p+1}*-free.

Pick any *p + 1* vertices. They fall into only *p* groups, so by pigeonhole two
of them must land in the *same* group — and same-group vertices are never
connected. So your *p + 1* chosen vertices can never all know each other. No
*(p+1)*-clique can exist. Mantel's theorem is exactly the case *p = 2*: two
groups, no triangles.

## Climbing the ladder, one neighborhood at a time

How do you *prove* the general Turán bound? The engine is an elegant inductive
device that we isolated as a stand-alone lemma:

> **Neighborhood clique-free lemma.** If a graph is *K_r*-free, then the
> subgraph induced on the neighborhood of *any* vertex *v* is *K_{r-1}*-free.

The reasoning is irresistible. Suppose *v*'s friends contained a clique of size
*r − 1* — a tight little group who all know each other. Every one of them is,
by definition, a friend of *v*. So add *v* to the group: now you have *r*
people who all know each other, a *K_r*. But the graph was *K_r*-free.
Contradiction. The forbidden clique must shrink by one every time you descend
into a neighborhood, and this controlled descent is what lets induction climb
the entire Turán ladder.

## When triangles slip in: a repair certificate

Real networks are messy; they *do* contain triangles. A natural engineering
question follows: if I must make a network triangle-free, how many friendships
do I have to cut? We proved a constructive, quantitative answer.

> **Greedy triangle removal.** For any graph *G*, there exists a triangle-free
> graph *H* obtained from *G* by deleting edges, with the number of deleted
> edges at most the number of triangles in *G*.

The algorithm is the obvious greedy one: while a triangle remains, pick it and
delete one of its three edges; repeat. Each deletion kills at least one
triangle, so you never delete more edges than there were triangles to begin
with. The theorem certifies that this naive strategy is *provably* economical —
the "edit distance" from any graph to triangle-freeness is bounded by its
triangle count. This is the kind of guarantee that matters in **property
testing**, where algorithms must decide whether a giant network is close to or
far from having a desired structure, by sampling only a tiny piece of it.

To make "how far apart are two networks?" precise, we use **edge edit
distance** — the number of friendships you'd have to add or remove to turn one
graph into the other. We verified the two sanity checks any notion of distance
must satisfy: it is **symmetric** (the cost of going from *G* to *H* equals the
cost of going from *H* to *G*) and a graph is at distance **zero** from itself.

## A bridge to set theory: shadows

Extremal thinking is not confined to graphs. Consider a family of sets, all of
the same size — say, committees of five people. The **lower shadow** of the
family is the collection of all four-person subcommittees you can get by
dropping one member. Shadows are the heart of the Kruskal–Katona theorem, one
of the crown jewels of extremal set theory, which pins down exactly how small a
shadow can be. As a foundational building block we verified the most basic
structural fact:

> **Shadow monotonicity.** If one family of sets is contained in another, then
> its shadow is contained in the other's shadow.

Bigger families cast bigger shadows. It sounds obvious — and it is — but it is
exactly the kind of bedrock lemma on which the towering results of the field
are built.

## Why it matters

These results are over half a century old, yet they remain astonishingly
alive. The same double-counting and energy arguments that bound triangles in a
toy graph underlie modern bounds on the spread of epidemics through contact
networks, the capacity of communication channels, the security of certain
cryptographic constructions, and the design of error-correcting codes. The
degree-energy quantity that powered Mantel's proof is a cousin of the
*spectral* quantities that govern how fast a random walk mixes — the
mathematics behind everything from Google's PageRank to the shuffling of a deck
of cards.

But the deepest reason to care is the one Turán himself would have given. There
is something profound in the discovery that a *qualitative* prohibition — "no
triangles" — forces a sharp *quantitative* limit, and that the unique world
living at that limit is the perfectly balanced, perfectly polarized bipartite
graph. Forbid a small pattern, and you do not merely thin the network; you
dictate its global shape. That tension between local rules and global structure
is the soul of extremal combinatorics, and it is as beautiful today as it was
the day Mantel first counted his edges.
