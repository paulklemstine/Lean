# When a Probability Threshold Is No Threshold at All

## Edges, triangles, and the hidden geometry of choosing pairs

A network can look complicated while being governed by a remarkably small collection of counting principles. Imagine a room of people, with an edge joining every pair who know each other. Or picture an airline map, a collaboration network, or a web of interacting proteins. Two questions arise immediately: how many connections are possible, and what can the observed patterns of connections force?

For a simple graph—an undirected network with no loops and no repeated edges—the answer to the first question begins with a binomial coefficient. If there are $n$ vertices, then there are

$$
\binom{n}{2}=\frac{n(n-1)}{2}
$$

possible unordered pairs, hence at most that many edges. This familiar count turns out to expose a deceptive “probability threshold” and, at the same time, opens a bridge from triangles to edges through one of extremal combinatorics’ central ideas: the shadow of a family of sets.

The resulting story has two movements. The first is contrarian: a proposed inequality that looks restrictive is automatically true for every genuine probability below one. The second is constructive: enough triangles force enough edges, and the precise relationship is controlled by the Kruskal–Katona principle.

## The ratio that looks more informative than it is

Let a graph have $m$ edges and $n$ non-isolated vertices. A vertex is non-isolated when it touches at least one edge. Consider the ratio

$$
T(n,m)=\frac{\binom{n}{2}}{m}.
$$

Call this the pair-to-edge threshold. Its numerator counts all pairs that could be edges; its denominator counts the pairs that actually are edges. At first sight, a condition such as

$$
p<T(n,m)
$$

seems to compare a probability $p$ with the density of the graph in a meaningful way. But the ratio is the reciprocal of edge density. Since a simple graph can never contain more than all available pairs,

$$
m\leq \binom{n}{2}.
$$

Whenever $m>0$, division gives the Threshold Lower Bound:

$$
1\leq T(n,m).
$$

This is the key reversal. A genuine probability in the usual strict range satisfies $p<1$. Therefore every such probability automatically obeys

$$
p<1\leq T(n,m).
$$

The proposed threshold does not separate sparse graphs from dense ones at all. It accepts every $p<1$, from a path-like network to a complete graph. The condition may be algebraically correct, but in the ordinary probability range it carries no discriminating power.

There is an equivalent way to see what it says. If $m>0$, multiplying the strict inequality $p<T(n,m)$ by $m$ yields the Edge-Budget Equivalence:

$$
pm<\binom{n}{2}.
$$

This merely says that the probability-weighted number of actual edges is smaller than the number of possible pairs. For $p<1$, that follows already from $pm<m\leq\binom{n}{2}$.

## Why non-isolated vertices still matter

The absence of isolated vertices does not strengthen the lower bound, but it does control the other end of the ratio. Every vertex has degree at least one, so summing degrees over all vertices gives at least $n$. The handshake identity says that this same sum equals twice the number of edges:

$$
\sum_v \deg(v)=2m.
$$

Consequently the No-Isolated-Vertices Handshake Bound is

$$
n\leq 2m.
$$

Combining this with the pair formula produces an upper bound on the threshold. Since $m\geq n/2$,

$$
T(n,m)=\frac{n(n-1)}{2m}\leq n-1.
$$

Thus every nonempty simple graph on $n$ non-isolated vertices satisfies the Threshold Interval Theorem:

$$
1\leq T(n,m)\leq n-1.
$$

Both endpoints tell a recognizable story. The complete graph has $m=\binom{n}{2}$ and reaches $T=1$. At the opposite extreme, when $n$ is even, a perfect matching gives every vertex exactly one neighbor, has $m=n/2$, and reaches $T=n-1$. The interval is therefore not a loose bookkeeping artifact: its endpoints are attained by natural graphs.

The elementary ingredients deserve to be stated clearly. The Pair Formula over the real numbers is

$$
2\binom{n}{2}=n(n-1).
$$

For $n\geq 2$, the Pair Positivity Lemma says

$$
\binom{n}{2}>0.
$$

Together with the simple-graph edge bound and the handshake identity, these facts account for the entire threshold analysis.

## From pairs to shadows

The same act of choosing pairs becomes more powerful when triangles enter the picture. A triangle is a set of three vertices whose three possible edges are all present. Suppose a graph on $n$ labeled vertices contains many triangles. How few edges could it have?

To answer this, stop viewing a triangle as a little drawing and view it as a three-element set. Collect all triangular vertex sets into a family $\mathcal{T}$. Now form the two-dimensional shadow $\partial\mathcal{T}$: for every triangle, delete one vertex in every possible way and retain the resulting two-element sets. Symbolically,

$$
\partial\mathcal{T}
=
\{A: |A|=2\text{ and }A\subseteq B\text{ for some }B\in\mathcal{T}\}.
$$

Every member of this shadow is an edge. Indeed, deleting one vertex from a triangle leaves two vertices that were adjacent. Hence

$$
\partial\mathcal{T}\subseteq E,
$$

where $E$ is the graph’s edge set. This Shadow-to-Edge Lemma is the geometric heart of the argument.

A deep and beautiful set-family theorem now supplies the counting force. The Kruskal–Katona principle describes how small the shadow of a uniform family can be. In the form needed here, if a family of three-element subsets contains at least $\binom{k}{3}$ members, where $3\leq k\leq n$, then its two-element shadow contains at least $\binom{k}{2}$ members.

Apply this to the triangle family. If the graph has at least $\binom{k}{3}$ triangles, then

$$
|\partial\mathcal{T}|\geq \binom{k}{2}.
$$

Because the shadow sits inside the edge set, the Triangle-to-Edge Theorem follows:

> For integers $3\leq k\leq n$, every simple graph on $n$ vertices with at least $\binom{k}{3}$ triangles has at least $\binom{k}{2}$ edges.

In equations,

$$
|\mathcal{T}|\geq \binom{k}{3}
\quad\Longrightarrow\quad
|E|\geq \binom{k}{2}.
$$

The complete graph on $k$ vertices shows why these numbers belong together: it has exactly $\binom{k}{3}$ triangles and $\binom{k}{2}$ edges. The theorem says that no graph can support that many triangles using fewer edges.

## A small example with a large lesson

Take $k=5$. Since $\binom{5}{3}=10$ and $\binom{5}{2}=10$, any graph containing at least ten triangles must contain at least ten edges. A complete graph on five vertices attains equality. If extra vertices are present, they do not permit a cheaper realization of those ten triangles: dispersing triangles cannot beat the compact complete configuration’s shadow.

For $k=6$, the theorem reads

$$
20\text{ triangles force at least }15\text{ edges}.
$$

This is not obtained by counting three edges per triangle, because a single edge can belong to many triangles. Naive incidence counting overcounts badly. The shadow method handles overlap exactly where it matters: it asks how many distinct pairs are required to support a given number of distinct triples.

That perspective has real-world resonance. In a social network, triangles model tightly knit groups of three, while edges model pairwise relationships. The theorem places an unavoidable infrastructure cost on clustering. In a communication network, three-way redundant routes cannot proliferate without enough physical links. In a data set of co-occurring triples, the shadow records all pairwise co-occurrences; many distinct triples force a substantial vocabulary of pairs.

## Two complementary cautions

The threshold result and the triangle result teach opposite but complementary habits of thought.

First, normalize carefully. A ratio can look sophisticated while collapsing under a universal bound. Here $T(n,m)$ is always at least one, so comparing it with a probability below one reveals nothing. To obtain a meaningful probabilistic criterion, one would need a conclusion sensitive to graph structure, or a threshold scaled into the interval $[0,1]$, such as the edge density

$$
\rho=\frac{m}{\binom{n}{2}}.
$$

Second, choose the right combinatorial representation. Triangles are not merely pictures; they are three-element sets, and edges are their two-element shadows. Once represented this way, a graph problem becomes a set-family problem, and a sharp extremal theorem becomes available.

The broad lesson is methodological. Some inequalities become transparent when translated into density. Others become sharp when translated into shadows. In both cases, the decisive move is not heavier calculation but a better point of view.

That lesson travels well beyond graph theory. Whenever data describe interactions of several sizes, one should ask which lower-dimensional relationships those interactions necessarily contain. Shadows make that descent explicit. Whenever a ratio is called a threshold, one should first compare it with the natural scale of the parameter it is meant to constrain.

## What remains to explore

The truncated threshold claim that motivated the analysis did not specify what consequence was supposed to follow from $p<T(n,m)$. That missing conclusion matters. Since the inequality is automatic for every $p<1$, no nontrivial structural conclusion can follow from it alone. Future versions must add information—perhaps connectedness, a minimum-degree condition, regularity, or a particular random-graph model.

The triangle bridge suggests richer directions. One can ask for analogous bounds in which copies of a larger clique force lower-dimensional cliques, or investigate stability: if a graph nearly attains the minimum edge count for its number of triangles, must it resemble a complete graph concentrated on a small vertex set? One can also compare the shadow bound with density-based estimates in random and pseudorandom networks.

At the center of all these questions is the same elementary object, $\binom{n}{2}$. It counts possible edges, limits probability ratios, and appears as the shadow forced by a critical mass of triangles. A simple count of pairs can expose a vacuous condition—and, viewed from the right angle, reveal the rigid architecture hidden inside a crowded network.
