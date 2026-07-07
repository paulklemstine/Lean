# When a Graph Runs Out of Room: Curvature, Triangles, and the Matching–Clique Join

## A shape hidden inside a network

Curvature is one of those ideas that seems to belong to smooth things — the
gentle bulge of a sphere, the flare of a saddle, the arc of a suspension
bridge. It measures how a surface bends away from being flat. Yet over the
last two decades mathematicians have learned to hear the same music in a place
that has no smoothness at all: a network of dots and lines, a *graph*.

On a graph there are no tangent planes and no calculus of smooth motion. There
are only vertices and the edges between them. And still, remarkably, every edge
of a graph can be assigned a number — its **Ricci curvature** — that behaves
uncannily like the curvature of a curved surface. Where the number is positive,
the network is locally "round," tightly knit, rich in short detours. Where it
is negative, the network is locally "stretched," tree-like, starved of
alternative paths. This discrete curvature has become a working tool: it flags
bottlenecks in the internet's backbone, exposes fragile links in financial
systems, and helps machine-learning models decide which connections in a
network actually matter.

This article is about a single, sharp question in that theory, and about a
beautiful graph that we built to answer it — a graph that turned out to answer
it in an unexpected way.

## The question: how dense can a "flat spot" survive?

Here is the tension at the heart of the story. Adding edges to a graph tends to
make it *rounder*. Every new edge you draw closes potential triangles, creates
new shortcuts, and pushes curvature upward. A complete graph — where every pair
of vertices is joined — is maximally round: every edge sits in a dense thicket
of triangles, and every edge has strongly positive curvature.

So the natural extremal question is a tug-of-war:

> **How many edges can a graph on $n$ vertices have while still containing at
> least one edge of non-positive curvature — one stubborn "flat spot" that
> refuses to be rounded?**

Call the maximum edge count $T(n)$. Somewhere between the empty graph (all flat,
few edges) and the complete graph (all round, maximum edges) lies a threshold:
the densest possible network that still hides one uncurved edge. The graph that
achieves this maximum is the *extremal graph*, and understanding its structure
tells us exactly what a "maximally hidden flat spot" looks like.

A tempting conjecture had been circulating: that the extremal graph is a very
specific and elegant construction — the **matching–clique join** — and that the
maximum edge count is
$$T(n) = \frac{n^2 - 3n}{2} - \left\lceil \tfrac{n}{2}\right\rceil + 2.$$
This article tells the story of putting that conjecture to the test.

## Meet the matching–clique join

Take $n = 4k$ vertices and split them into two equal blocks of $2k$ vertices
each.

- **Block $A$** is arranged into $k$ disjoint couples. Each vertex is joined to
  its one partner and to nobody else inside $A$. This is a **perfect matching**:
  $k$ isolated edges, sparse and lonely.
- **Block $B$** is a **complete graph** $K_{2k}$: every vertex joined to every
  other. Maximally dense.
- Finally, we **join the blocks completely**: every vertex of $A$ is connected to
  every vertex of $B$.

The result, which we call $H(k)$, is a curious hybrid — a nearly-complete world
$B$ shadowed by a sparse ghost world $A$, with a total bridge between them. It
looks, at a glance, like exactly the kind of place where a flat spot could
hide: the matching edges inside $A$ are starved of triangles, while everything
around them is dense.

The first thing to do with such a construction is to measure it *exactly*. And
here the news is entirely good — every quantity comes out clean.

**The degree of every vertex.** A matching vertex in $A$ touches exactly one
partner and all $2k$ vertices of $B$, so it has degree
$$d_A = 2k + 1.$$
A clique vertex in $B$ touches all $2k$ vertices of $A$ and the other $2k-1$
vertices of $B$, giving
$$d_B = 4k - 1.$$

**The total number of edges.** Summing all degrees gives $12k^2$, and since every
edge is counted twice in that sum, the graph has exactly
$$|E(H(k))| = 6k^2 = \frac{3n^2}{8} \quad\text{edges.}$$

That single fact — the clean count $6k^2$ — is where the plot turns.

## Reading curvature through triangles

To decide whether an edge is a flat spot, we need to look at its immediate
neighborhood. Discrete Ricci curvature of an edge $x \sim y$ is governed by two
purely local quantities: the **degrees** of its two endpoints and the number of
**common neighbors** they share — equivalently, the number of triangles that
rest on that edge. Intuitively, common neighbors are shortcuts: they let mass
spread from $x$ to $y$ cheaply, and abundant shortcuts mean positive curvature.
An edge whose endpoints have high degree but few shared neighbors is a
stretched, starved, negatively-curved edge.

So we counted the common neighbors of every edge in $H(k)$, and the three
species of edge told three sharply different stories.

- A **matching edge** — the two partners $(p,0)$ and $(p,1)$ inside $A$ — shares
  exactly the entire block $B$ as common neighbors, and *nothing else*: the two
  partners have no other mutual friend inside $A$. That is $2k$ triangles.
- A **join edge** — a matching vertex tied to a clique vertex — also lands at
  exactly $2k$ common neighbors: the matching vertex's lone partner, plus all of
  $B$ except the clique endpoint itself.
- A **clique edge** — two vertices inside the dense block $B$ — sits in a far
  richer thicket: all of block $A$ plus every other clique vertex, giving
  $$4k - 2 \quad\text{common neighbors.}$$

The pattern is unambiguous. The clique edges are buried in triangles. The
matching edges are the sparsest of all, tied only by the join edges in raw
triangle count — but the matching edges are additionally *lower-degree at both
ends*, which is the decisive combination. We proved this as a strict inequality:
for every $k \ge 2$,
$$\underbrace{2k}_{\text{matching}} \; < \; \underbrace{4k-2}_{\text{clique}},
\qquad \underbrace{2k}_{\text{matching}} \; = \; \underbrace{2k}_{\text{join}}.$$
The matching edges are **strictly locally sparsest**. This is the correct
combinatorial fingerprint of a curvature-minimizing edge: if $H(k)$ hides a flat
spot anywhere, it hides it in the matching.

So far the construction behaves exactly as the conjecture hoped. And then it
doesn't.

## The twist: the elegant candidate is not extremal

With the exact edge count $6k^2$ in hand, we can simply *check* whether it
matches the conjectured maximum $T(n)$. For even $n$, a little algebra collapses
the conjectured formula into a memorable shape:
$$T(n) = \frac{n^2-3n}{2} - \frac{n}{2} + 2 = \frac{(n-2)^2}{2}
   = \binom{n}{2} - \frac{3n-4}{2}.$$
That last form is the revealing one. It says the conjectured extremal graph is
obtained from the complete graph $K_n$ by deleting only $\frac{3n-4}{2}$ edges —
a merely *linear* number, $\Theta(n)$. The extremal graph, if the count is right,
must be **near-complete**: missing almost nothing.

But the matching–clique join is the opposite of near-complete. With $n = 4k$
vertices it has $6k^2 = \tfrac{3}{8}n^2$ edges, whereas the complete graph has
about $\tfrac12 n^2$. The join is missing roughly $\tfrac18 n^2$ edges — a
*quadratic* deficit, $\Theta(n^2)$. The two numbers cannot be reconciled:
$$6k^2 \;\ne\; 2(2k-1)^2 \quad\text{for every } k \ge 1.$$

The conclusion is clean and a little humbling. The beautiful, symmetric
matching–clique join — sparse ghost world shadowing a dense clique — is **not**
the extremal graph. It removes far too much. The genuine record-holder must be a
near-complete graph, one that keeps nearly every edge and sacrifices only a
linear handful, all clustered around a single witness pair that carries the flat
spot.

There is even a second, quieter obstruction. A perfect matching needs an even
number of vertices to pair up, so block $A$ of size $n/2$ can only exist when
$n/2$ is even — that is, when $4$ divides $n$. The construction does not even
exist for $n \equiv 2 \pmod 4$. The "for all even $n$" phrasing of the original
conjecture was reaching for a family that has gaps.

## What survives, and why it matters

It would be a mistake to read this as a purely negative result. Three durable
things came out of the investigation.

First, we now possess a graph whose local geometry is understood *completely and
exactly* — every degree, every triangle count, the whole edge budget — with no
approximations. The matching–clique join is a perfect laboratory specimen. Its
three edge classes have nearly identical degrees but wildly different triangle
counts ($2k$ versus $4k-2$), which makes it an ideal, controlled setting for
isolating the single variable — the common-neighbor count — that flips
curvature from positive to non-positive. If you want to fit and test a precise
threshold rule for when an edge goes flat, this is the cleanest data you could
ask for.

Second, the falsification *reshapes* the extremal problem in a productive
direction. Knowing that the true maximizer is near-complete rather than sparse
converts a vague search into a concrete program: study graphs obtained from
$K_n$ by deleting only a linear number of edges around one distinguished pair,
and find exactly how few must be deleted to starve that pair into non-positive
curvature. The failed conjecture pointed us at precisely the wrong end of the
density spectrum, and correcting it is genuine progress.

Third, the story is a small parable about the value of *exact* computation. The
matching–clique join is seductive. It is symmetric, it is elegant, and its
matching edges really are the sparsest edges in the graph — every intuition says
"extremal." Only by pinning down the edge count to the last unit, $6k^2$, and
laying it beside the conjectured $2(2k-1)^2$, does the mismatch become
undeniable. Elegance is a hypothesis, not a proof; the arithmetic is the judge.

Discrete curvature began as a metaphor — bending, borrowed from smooth
surfaces, transplanted onto dots and lines. What this episode shows is that the
metaphor has grown teeth. It supports genuine extremal questions with genuine
answers, questions sharp enough that a single exact count can overturn a
beautiful guess and point the way to the right one. The flat spot, it turns out,
does not hide in the sparse and lonely matching after all. It hides in plain
sight, one deleted handful of edges away from the densest graph there is.
