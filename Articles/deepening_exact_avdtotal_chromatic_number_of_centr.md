# When the Neighbourhood, Not the Crowd, Sets the Rules: Colouring Central Graphs

## A puzzle about paint

Imagine you run a small conference. Every participant must wear a coloured
badge, and every *conversation* between two participants must be assigned a
coloured ribbon that both parties clip onto their badge. There are two rules.
First, no two people who are talking to each other may wear the same badge
colour, no badge may match a ribbon it touches, and no two ribbons sharing a
person may match. That is the familiar demand of a *proper total colouring*:
people and conversations together must be painted so that nothing that touches
anything else shares a colour.

The second rule is subtler and it is where the story really begins. Look at any
person. They carry a little bundle of colours: their own badge, plus every
ribbon clipped to it. Call this their **palette signature**. The second rule
says that any two people who are talking must have *different* palette
signatures — not merely different badges, but different *sets* of colours
overall. This is the **adjacent-vertex-distinguishing** (AVD) condition. It
forces the colouring to encode, in each person's bundle of colours, enough
information to tell neighbours apart at a glance.

The natural question is: how many colours do you need? Too few and you cannot
even satisfy the first rule; a few more and you can be proper but not
distinguishing; more still and everything works. The smallest palette that
achieves a proper *and* distinguishing total colouring is the graph's
**AVD-total chromatic number**, written $\chi''_a$.

This article is about one specific, beautiful family of graphs where the answer
turns out to be governed by a quantity nobody initially expected — not by how
*busy* the graph is, but by how *big* it is.

## Building a central graph

Start with any finite simple graph $G$ — a set of vertices with some edges. The
**central graph** $C(G)$ is built by two moves applied at once:

1. **Subdivide every edge.** Drop a new vertex into the middle of each edge of
   $G$. So an edge $e = \{u, w\}$ becomes a little path $u - m_e - w$, with a
   fresh *subdivision vertex* $m_e$ in the middle.
2. **Join every non-adjacent pair.** For any two *original* vertices $u$ and $w$
   that were **not** joined in $G$, add a brand new edge between them.

The result has vertex set $V \sqcup E$: the original vertices together with one
vertex per original edge. Its adjacency structure is striking:

- Each subdivision vertex $m_e$ touches exactly the two endpoints of its edge,
  so it has degree $2$, always.
- Each original vertex $v$ is now joined to *every other original vertex* —
  either it was non-adjacent in $G$ (and we just added the edge) or it was
  adjacent in $G$ (and now they share a subdivision vertex, which keeps them at
  distance two but, crucially, the direct comparison is via the new edges). In
  the central graph, **every original vertex has degree $|V| - 1$**, where $|V|$
  is the number of vertices of $G$.

That last fact is the crux of everything. No matter how sparse or dense $G$ was,
in $C(G)$ all the original vertices become *equal-degree* vertices, each sitting
at the maximum degree $|V| - 1$.

## The old wisdom, and why it is incomplete

A natural first guess, and one that appears in the literature for regular
graphs, is that the AVD-total chromatic number of $C(G)$ should be controlled by
the **degree** $d$ of $G$. If $G$ is $d$-regular (every vertex has exactly $d$
neighbours), a bound of the shape
$$\chi''_a(C(G)) \ge d + 3$$
can be proved. Degree is the classical currency of colouring theory — the more
neighbours a vertex has, the more colours it tends to demand — so pinning the
answer to $d$ feels right.

But it is the wrong currency here. The central graph launders away the degree of
$G$: it turns *every* original vertex into a maximum-degree vertex of order
$|V| - 1$. And here is the twist that makes the whole thing sing. Take two
vertices $a$ and $b$ that were **non-adjacent** in $G$. In $C(G)$ we deliberately
joined them. So $a$ and $b$ are now **adjacent**, and they have the **same
degree** $|V| - 1$. They are an *adjacent equal-degree pair*, and such pairs are
precisely the hardest thing for a distinguishing colouring to cope with.

## The heart of the argument

Why are adjacent equal-degree pairs so troublesome? Here is the clean reason,
and it needs no computation.

Consider any vertex $w$ of degree $\Delta$. Look at the little "star" consisting
of $w$ itself together with all $\Delta$ edges meeting $w$. In a total colouring
these $\Delta + 1$ objects are pairwise touching — the vertex touches each of its
edges, and any two of its edges share the endpoint $w$. So they form a *clique*:
all $\Delta + 1$ must get distinct colours. This already tells us a palette needs
at least $\Delta + 1$ colours.

Now suppose we work with *exactly* $\Delta + 1$ colours. Then at the vertex $w$,
the $\Delta + 1$ objects of its star must use $\Delta + 1$ distinct colours out
of a palette of size $\Delta + 1$ — they are forced to use **all** of them. In
other words, the palette signature of $w$ is the *entire* palette. Every
maximum-degree vertex, coloured with exactly $\Delta + 1$ colours, ends up with
the same signature: everything.

That is fatal for distinguishing. If $u$ and $v$ are **adjacent** and both have
degree $\Delta$, then with only $\Delta + 1$ colours their signatures are both
"the whole palette," hence *equal* — violating the AVD rule. So:

> **Adjacent equal-degree obstruction.** If two adjacent vertices share the same
> degree $\Delta$, then no distinguishing total colouring can succeed with only
> $\Delta + 1$ colours.

Apply this inside $C(G)$. Whenever $G$ is *not* complete, it has a non-adjacent
pair $a, b$; these become an adjacent equal-degree pair in $C(G)$ with common
degree $|V| - 1$. So a palette of exactly $|V|$ colours (which is
$(|V|-1) + 1$) cannot distinguish them. A palette of *fewer* than $|V|$ colours
is even worse: one can always pad a smaller successful colouring up to $|V|$
colours by leaving the extra colours unused, without ever creating a collision
or merging two signatures — so if $|V|$ colours fail, so does anything smaller.
Putting the pieces together gives the sharp, order-driven bound at the centre of
this work.

> **Main Theorem.** For every finite simple graph $G$ that is *not* complete,
> $$\chi''_a\big(C(G)\big) \ge |V| + 1,$$
> where $|V|$ is the number of vertices of $G$.

## Why the new bound beats the old one

The order bound doesn't just replace the degree bound — it *contains* it. If $G$
is $d$-regular and not complete, pick a non-adjacent pair $a, b$. The vertex $a$,
the vertex $b$, and the $d$ distinct neighbours of $a$ are all different vertices
(since $b$ is not among $a$'s neighbours), so
$$|V| \ge d + 2, \quad\text{hence}\quad |V| + 1 \ge d + 3.$$
The classical degree bound $d + 3$ falls straight out as a corollary. And the
inequality $|V| \ge d + 2$ is strict as soon as $G$ has even one vertex beyond
the minimum $d + 2$ — that is, essentially always. Whenever $|V| > d + 2$, the
order bound is **strictly larger**, and the old degree bound is provably not
sharp.

## The smallest witness: the five-cycle

Nothing convinces like a concrete example. Take $C_5$, the cycle on five
vertices $0 - 1 - 2 - 3 - 4 - 0$. It is $2$-regular, so $d = 2$ and the classical
degree bound reads $d + 3 = 5$. But $C_5$ is not complete: for instance $0$ and
$2$ are not joined. So the order bound applies with $|V| = 5$:
$$\chi''_a\big(C(C_5)\big) \ge |V| + 1 = 6.$$
Six colours, not five. In the central graph $C(C_5)$, vertices $0$ and $2$ (once
non-adjacent, now joined) both have degree $4$; with only five colours their
palette signatures would both be the entire five-colour palette and could never
be told apart. The five-cycle is the *smallest* graph where the order bound
strictly beats the degree bound — a tidy minimal counterexample to the old
wisdom.

## The exceptional case, and why it is exactly one case

There is a single family where the argument politely steps aside: the
**complete** graphs $K_n$. If $G = K_n$, then *every* pair of vertices is
adjacent, so there is no non-adjacent pair to promote into an adjacent
equal-degree pair. The central-graph construction turns the original vertices
into an *independent* set instead of a clique, the obstruction never fires, and
the AVD-total chromatic number drops to a smaller value determined separately.
This is not a gap in the theorem; it is the theorem telling us precisely where
its engine — the non-adjacent pair — lives. Completeness is the one and only way
to switch that engine off.

## A shift in perspective

The moral of the story is a small but genuine change of viewpoint. In classical
colouring theory, *degree* is king: local crowding drives colour demand. But the
central-graph construction is a machine for erasing degree information and
replacing it with sheer *size*. Once every original vertex is forced up to the
maximum degree $|V| - 1$, and once non-adjacency is converted into adjacency, the
relevant invariant is no longer how many friends a vertex has but how many
vertices there are at all. The number that matters is the *order* of the graph.

This is the kind of clarification that makes a subject feel more honest. A
conjecture predicting the answer $d + 3$ was not exactly wrong — it is a valid
*lower* bound — but it measured the wrong thing. The true first-order invariant
is $|V| + 1$, and it reduces to the old bound only in the borderline case where
size and degree nearly coincide. Chasing the sharp bound revealed that the
question had been quietly asking about the crowd when it should have been asking
about the neighbourhood.

## What comes next

The lower bound $|V| + 1$ is now firmly in place. The natural companion is a
matching *upper* bound: an explicit recipe that colours $C(G)$ with exactly
$|V| + 1$ colours for every non-complete $G$, which would pin the exact value to
$\chi''_a(C(G)) = |V| + 1$. The strategy is appealing — with one colour to spare
beyond the $|V|$ forced at each maximum-degree vertex, that single surplus colour
can be routed around the graph to break every adjacent equal-degree tie at once.
Beyond that lie tantalising extensions: proving that complete graphs are the
*unique* exceptions, pinning the ordinary (non-distinguishing) total chromatic
number of $C(G)$ to exactly $|V|$, and iterating the central-graph construction
to see how the order-driven bound compounds. Each of these turns on the same
central insight uncovered here: in the world of central graphs, it is the size of
the crowd, funnelled through the neighbourhood, that sets the rules.
