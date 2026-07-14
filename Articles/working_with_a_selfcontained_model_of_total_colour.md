# When Two Rules Agree: The Hidden Balance Point of Colouring Central Graphs

## A puzzle about colouring

Imagine you are handed a map — not of countries, but of a network. There are
some points, and some lines connecting them. Your job is to paint everything:
every point, and every line. There is one catch, and then a second, sneakier one.

The first catch is the rule of good manners that anyone who has coloured a map
knows: things that touch must look different. Two lines meeting at a point should
not share a colour. A point should not match the lines running into it, nor any
neighbouring point.

The second catch is subtler and is where the real story begins. Look at any point
and gather up its *palette*: the colour of the point itself, together with the
colours of all the lines emanating from it. This little bundle of colours is the
point's signature. The extra rule — the **adjacent-vertex-distinguishing** rule,
or AVD for short — insists that any two points which are directly connected must
have *different signatures*. It is not enough that the individual colours differ;
the whole *set* of colours around one point must differ from the whole set around
its neighbour.

This is a demanding requirement, and it forces a natural question: what is the
smallest number of colours that lets you finish the job? That minimum is called
the **AVD-total chromatic number**, written $\chi''_a$. Computing it, even for
tidy families of networks, turns out to be a surprisingly deep game of counting
and constraint.

## The graphs we colour: central graphs

The networks in this story are not arbitrary. They are built from ordinary graphs
by a specific recipe that produces what is called the **central graph**.

Start with any graph $G$ — a collection of vertices with edges between some pairs.
The central graph $C(G)$ is manufactured in two moves:

1. **Subdivide every edge.** Each original edge $uv$ gets a brand-new vertex
   planted in its middle, splitting the edge into two. In effect, every edge of
   $G$ becomes a little vertex of its own in $C(G)$, connected to the two
   endpoints it used to join.
2. **Join every non-adjacent pair.** Take any two original vertices that were
   *not* connected in $G$, and connect them in $C(G)$.

So $C(G)$ has two kinds of vertices: the *original* vertices of $G$, and one new
*edge-vertex* for each edge of $G$. An original vertex $u$ is joined in $C(G)$ to
(a) every original vertex it was *not* joined to in $G$, and (b) every edge-vertex
sitting on an edge that touched $u$. Two edge-vertices are never joined to each
other.

This construction has a beautiful and consequential side effect. In $C(G)$, an
original vertex is now connected to *all the vertices it used to avoid*. If $G$
has $n$ vertices, then every single original vertex in $C(G)$ ends up with degree
exactly $n - 1$: it is joined to all but itself. The original vertices become the
"hubs" of the central graph, each maximally connected among its own kind.

## Two ways to say "you need more colours"

When we try to AVD-total-colour the central graph of a *regular* graph — one in
which every vertex has the same degree $d$ — two completely different arguments
each place a floor under how many colours we must use.

**The first floor comes from the degree $d$.** Suppose $G$ is $d$-regular but not
complete, meaning at least one pair of vertices is non-adjacent. A short counting
argument shows such a graph must have at least $d + 2$ vertices. From there one can
show that $d + 2$ colours can *never* suffice for an AVD-total colouring of $C(G)$,
and so at least $d + 3$ colours are required. Call this the **$d$-governed bound**:

$$\chi''_a\big(C(G)\big) \ge d + 3.$$

**The second floor comes from the number of vertices $|V|$.** Recall that every
original vertex of $C(G)$ has degree $n - 1$. Now take two vertices of $G$ that
were not adjacent; in $C(G)$ they *are* adjacent, and they have *equal degree*
$n - 1$. Here the AVD rule bites hard. Around a vertex of degree $n-1$ there are
$n$ things to colour (the vertex plus its $n-1$ neighbours in its star), and with
only $n$ colours available every one of those colours must appear — so the
signature is the *entire* palette. But if two adjacent, equal-degree vertices both
have the full palette as their signature, their signatures are identical, breaking
the AVD rule. Hence $n$ colours are not enough, and we need at least $n + 1$. Call
this the **$|V|$-governed bound**:

$$\chi''_a\big(C(G)\big) \ge |V(G)| + 1.$$

## The race between the two bounds

Now we have two lower bounds, and a natural instinct is to ask: which one wins?

Because any non-complete $d$-regular graph has $|V| \ge d + 2$, a single line of
arithmetic shows

$$d + 3 \;\le\; |V(G)| + 1.$$

The $|V|$-governed bound is *always at least as strong* as the $d$-governed bound.
The number of vertices, not the degree, is the sharper constraint. This immediately
tempers a tempting conjecture. One might guess that the answer is always exactly
$d + 3$; but whenever $G$ has more than $d + 2$ vertices, the true value is forced
strictly higher. The clean equality $\chi''_a(C(G)) = d + 3$ can hold *only* when
the two bounds tie:

$$d + 3 = |V(G)| + 1 \quad\Longleftrightarrow\quad |V(G)| = d + 2.$$

This is the **extremal regime**: the razor's edge where the degree-bound and the
vertex-bound agree perfectly. Off this edge, the vertex-bound quietly dominates and
the naive $d+3$ answer is simply wrong.

## What lives on the razor's edge?

The most satisfying discovery is that the extremal graphs — the ones with exactly
$d + 2$ vertices — have a crisp, memorable identity.

There is a general fact worth stating: the complement of a $d$-regular graph on
$n$ vertices (the graph you get by swapping edges for non-edges) is itself regular,
of degree $n - 1 - d$. Feeding in $n = d + 2$ gives a complement of degree
$(d+2) - 1 - d = 1$. A graph in which every vertex has degree exactly $1$ is a
**perfect matching**: the vertices pair off into disjoint couples.

So the extremal graphs are precisely those whose complement is a perfect matching —
equivalently, the complete graph $K_{d+2}$ with a perfect matching *deleted*. These
are the celebrated **cocktail-party graphs**: picture $d+2$ guests at a party where
everyone chats with everyone *except* the one partner they arrived with. This
characterisation is exact and reversible:

> **Extremal Characterisation.** For a $d$-regular graph $G$ that is not complete,
> $|V(G)| = d + 2$ if and only if the complement of $G$ is $1$-regular — that is,
> if and only if $G$ is a cocktail-party graph.

On this family, and only this family, the two bounds collapse into one sharp
number: every AVD-total colouring of $C(G)$ needs at least $d + 3 = |V| + 1$
colours, with no daylight between the two arguments.

## Small worlds: the four-cycle and the five-cycle

Nothing clarifies a theorem like the smallest example that obeys it — and the
smallest that flouts it.

Consider the **four-cycle** $C_4$, a square: four vertices in a ring. It is
$2$-regular, and it has $4 = 2 + 2$ vertices, so it sits *exactly* on the extremal
edge. Its complement pairs up opposite corners into two disjoint edges — a perfect
matching, exactly as the characterisation predicts. And indeed, any AVD-total
colouring of its central graph $C(C_4)$ requires at least $5$ colours, the sharp
value $d + 3 = |V| + 1 = 5$.

Now take one step up to the **five-cycle** $C_5$, a pentagon. It too is
$2$-regular, but it has $5$ vertices — and $5 \ne 2 + 2$. The five-cycle is *not*
extremal. Its complement is $2$-regular (degree $5 - 1 - 2 = 2$), another pentagon,
not a matching. Here the two bounds separate: the $d$-governed bound says $5$, but
the $|V|$-governed bound says $6$, and the vertex-bound wins. The pentagon is the
smallest witness that the naive "$d + 3$" answer is genuinely too small once you
leave the extremal family.

The square and the pentagon, side by side, tell the whole story in miniature: on
the edge, the bounds agree; one step off, they diverge.

## Why this matters

Total colourings are not a mere curiosity. They model scheduling problems where both
*tasks* (vertices) and *transitions between tasks* (edges) need to be assigned
non-conflicting resources — time slots, frequencies, machines. The
adjacent-vertex-distinguishing refinement adds a layer of *identifiability*: not
only must the assignment be conflict-free, but neighbouring units must be
*distinguishable* by their whole local pattern of resources. That is exactly the
kind of constraint that arises in fault-detection and in labelling schemes where
each node must broadcast a locally unique fingerprint.

The lesson of the central-graph story is a general one about optimisation with
competing constraints. It is tempting to fixate on one obvious parameter — here,
the degree $d$ — and conjecture a clean formula in terms of it. But a second,
less obvious parameter — the sheer number of vertices — silently governs the
truth almost everywhere, and the tidy formula survives only on a thin, perfectly
characterisable boundary. Finding that boundary, naming the graphs that live on it,
and exhibiting the smallest example on each side is how a vague conjecture becomes
precise mathematics.

## What comes next

The results here pin down the *lower* half of the story on the extremal family:
at least $d + 3$ colours are necessary. The natural next chapter is the matching
*upper* bound — an explicit recipe using exactly $d + 3$ colours on the
cocktail-party graphs, which would prove the equality $\chi''_a(C(G)) = d + 3$
outright on that family. Beyond that lie the exact values for the central graphs of
all cycles (conjecturally $n + 1$ for the $n$-cycle) and a general vertex-governed
upper bound for every regular graph. The razor's edge has been located and named;
the work ahead is to build, colour by colour, the constructions that meet it.
