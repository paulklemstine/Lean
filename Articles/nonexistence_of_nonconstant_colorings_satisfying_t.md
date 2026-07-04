# The Colors That Refuse to Blend

Imagine a city map where every neighborhood is painted a shade of gray, from
pure black to brilliant white. Now impose one rule, and only one: the shade of
each neighborhood must be exactly the *average* of the shades you can walk to
from it — weighted by how much traffic flows along each road. A busy avenue
counts for a lot; a quiet alley barely counts at all. The question is deceptively
simple: **how many ways can you paint the city so that this averaging rule holds
everywhere at once?**

The answer, it turns out, is startlingly rigid. If the road network is *strongly
connected* — if you can drive from any neighborhood to any other — then there is
essentially only one way to paint the city: **you must use a single flat color.**
Every neighborhood the same shade. No gradients, no patterns, no maps of light
and dark. The moment you insist that every color is the traffic-weighted average
of its neighbors, and that the city hangs together as one connected whole, all
the color drains out into perfect uniformity.

This article is about *why* that happens, why it is not obvious, and where the
one crack in the argument lies — the single assumption you cannot remove.

## The setup, precisely

Let us make the picture exact. We have a finite collection of points — call them
vertices — which you can think of as the neighborhoods. Between them run directed
roads with weights. Write $w(i,j) \ge 0$ for the weight of the road *from* $i$
*to* $j$. A weight of zero means there is no road at all. We insist that the
weights leaving each vertex sum to one:
$$\sum_j w(i,j) = 1.$$
This is the "traffic-weighted average" condition in disguise: the outgoing
weights from any vertex form a set of proportions, a probability distribution
over where you might go next.

A **coloring** is just a number $c(i)$ attached to each vertex — its shade of
gray. The coloring satisfies the **blend condition** if, at every vertex,
$$c(i) = \sum_j w(i,j)\, c(j).$$
In words: my color is the weighted average of the colors I point to. Because the
weights are nonnegative and sum to one, this is a genuine *convex combination* —
$c(i)$ can never be larger than the largest neighbor's color, nor smaller than
the smallest. A blend is a compromise; it always lands somewhere in the middle.

Finally, the network is **strongly connected** if, starting from any vertex, you
can reach any other by following roads of positive weight, possibly through many
intermediate stops. Nothing is stranded; the whole graph is one piece, and you
can always find a route home.

## The theorem

> **Blend Collapse Theorem.** On a finite, strongly connected network whose
> outgoing weights sum to one at every vertex, every coloring satisfying the
> blend condition is constant. Equivalently, there is *no* blend coloring that
> assigns two vertices different colors.

That is the whole story in one line. The rest is understanding why it is forced.

## The idea: chase the brightest neighborhood

Here is the argument, and it is beautiful precisely because it uses almost
nothing. Since there are only finitely many vertices, some vertex is painted the
brightest — it attains the maximum shade $m = \max_i c(i)$. Pick such a vertex
$i$, a place where $c(i) = m$.

Now read the blend condition at $i$:
$$m = c(i) = \sum_j w(i,j)\, c(j).$$
Every color on the right is at most $m$, and the weights sum to one. So the
right-hand side is an average of numbers, none exceeding $m$, that somehow lands
*exactly on* $m$. The only way an average of things $\le m$ can equal $m$ is if
every term that carries any weight is *itself* equal to $m$. Rearranging,
$$\sum_j w(i,j)\,\bigl(m - c(j)\bigr) = 0,$$
and this is a sum of nonnegative terms — each factor $w(i,j) \ge 0$ and each
$m - c(j) \ge 0$. A sum of nonnegative terms vanishes only if each term
vanishes. Therefore, for **every** neighbor $j$ with $w(i,j) > 0$, we must have
$c(j) = m$.

This is the crux, the single reusable step: *maximality is contagious along
roads*. If a vertex is at the maximum, all of its positive-weight successors are
too. We call it the local maximum principle.

But now strong connectivity finishes the job with no effort at all. Maximality
has spread from $i$ to all of its out-neighbors; by the same reasoning it spreads
from them to *their* out-neighbors, and so on. Since you can reach every vertex
from $i$ along positive-weight roads, the brightness $m$ floods the entire graph.
Every vertex is painted $m$. The coloring is constant. $\blacksquare$

There is a satisfying inevitability here. The maximum tries to be special, to
stand out — but the averaging rule immediately forces its neighbors to match it,
and connectivity turns that local infection into a global epidemic of sameness.

## Why the connectivity really matters

Every hypothesis in a good theorem earns its keep, and this one is no exception.
What breaks if we drop strong connectivity?

Consider the simplest possible failure: two vertices, $0$ and $1$, each with a
single road looping back to itself. Formally $w(i,j) = 1$ when $i = j$ and $0$
otherwise. The blend condition at vertex $0$ reads $c(0) = 1 \cdot c(0)$, which
is true no matter what — and likewise at vertex $1$. So we are free to paint
$0$ black and $1$ white:
$$c(0) = 0, \qquad c(1) = 1.$$
A perfectly valid, gloriously non-constant blend coloring. What went wrong? The
network is *not* strongly connected: there is no road from $0$ to $1$ or back.
Each vertex is its own little island, free to choose its own shade. This example
is sharp — it shows that strong connectivity is not a convenience we assumed for
comfort; it is the exact dividing line between rigidity and freedom.

Notice, too, what the theorem does *not* need. It never assumes the roads are
symmetric — that a road from $i$ to $j$ is matched by an equally weighted road
back. It never assumes any kind of reversibility or balance. Pure one-way
streets are fine. All that matters is that the whole graph is reachable and that
each vertex's outgoing weights form an average.

## The directed cycle: a family of witnesses

To see the theorem bite on a genuinely non-trivial network, consider the
**directed $n$-cycle**: vertices $0, 1, \dots, n-1$ arranged in a ring, with a
single road from each vertex $i$ to the next vertex $i+1$ (indices wrapping
around modulo $n$), carrying all the weight:
$$w(i, j) = \begin{cases} 1 & \text{if } j = i + 1 \pmod n, \\ 0 & \text{otherwise.}\end{cases}$$
This is strongly connected — starting anywhere and walking forward, you visit
every vertex before returning home. The blend condition becomes stark: each
vertex's color must *equal* the color of the single vertex it points to,
$$c(i) = c(i+1) \quad \text{for all } i.$$
Following the ring around, $c(0) = c(1) = \dots = c(n-1) = c(0)$, so all colors
coincide. The Blend Collapse Theorem predicts constancy, and here you can see it
directly: a cycle of "copy your successor" constraints leaves no room for
variation. This works for every $n \ge 1$, giving an infinite family of concrete
networks on which the collapse is visible to the naked eye.

## The same truth in disguise: harmonic functions and random walks

Mathematicians will recognize this collapse under several older names, and the
connections are what make it worth telling.

**A discrete maximum principle.** In the theory of the Laplace equation, a
*harmonic function* — one whose value at each point equals the average of its
values on any small sphere around that point — cannot attain a strict interior
maximum. Our blend condition is exactly a discrete harmonicity: $c$ is harmonic
for the weighted graph. The collapse to a constant is the discrete cousin of
**Liouville's theorem**: a bounded harmonic function on all of space is constant.
On a finite strongly connected graph, *every* function is bounded, so *every*
harmonic function is constant.

**A random walk reaching equilibrium.** Read the weights $w(i,j)$ as transition
probabilities: from vertex $i$, jump to $j$ with probability $w(i,j)$. Then the
blend condition says $c(i) = \mathbb{E}[c(\text{next vertex})]$ — the color is
unchanged in expectation by one step of the walk. Such functions are called
*harmonic* for the Markov chain, and strong connectivity is exactly the chain's
*irreducibility*: every state can reach every other. A classical fact of Markov
chain theory is that the only harmonic functions of a finite irreducible chain
are the constants. Our theorem is a self-contained, elementary proof of precisely
this.

**An averaging dynamic that homogenizes.** Picture repeatedly *updating* every
color to the weighted average of its neighbors — a round of gossip in which each
neighborhood recolors itself to match the traffic-weighted opinion of the places
it points to. The blend colorings are the fixed points of this process. The
theorem says the only fixed points are flat. And in fact, on a strongly
connected graph, this repeated averaging drives *any* starting coloring toward
the flat one: differences of opinion get smoothed away, and consensus is the only
stable outcome. The blend condition characterizes exactly the states that gossip
can never disturb — the states where everyone already agrees.

## Beyond the number line

One of the pleasures of a clean proof is discovering how little it truly used.
Look again at the argument: we needed only that a *maximum* is an extreme value,
and that an *average* cannot exceed it. Nothing about the argument cared that
colors were real numbers on a line.

This hints at a far broader truth. Suppose colors live not on a line but in some
richer space — points in the plane, vectors in high dimensions, even locations on
a curved surface — and "average" means the natural weighted center of mass. As
long as the geometry is *strictly convex*, so that extreme points are genuinely
extreme and cannot be reproduced as nontrivial averages of other points, the same
collapse occurs: extremality is contagious, connectivity spreads it, and every
blend coloring is constant. For colors that are vectors, one simply runs the
real-number argument in each coordinate separately, and the conclusion follows
immediately. The Blend Collapse Theorem is not really a fact about numbers at
all; it is a fact about **convexity meeting connectivity**.

## Why it matters

The moral is broader than graphs. Whenever a system demands that every part be a
compromise between its neighbors, and the parts are all linked together into one
irreducible whole, the system has no choice but to become uniform. Local
averaging plus global connectivity equals consensus. It is the mathematics behind
why heat spreads until temperature is even, why gossip on a well-connected
network converges to a single shared belief, why an electrical network with no
sources settles to a single potential, and why a random walker's long-run
statistics forget where it started.

And the single crack — the escape hatch — is always the same: break the
connectivity. Carve the world into isolated islands, and each is free to hold its
own color forever. Strong connectivity is the exact price of consensus. Pay it,
and diversity of color is impossible; withhold it, and diversity is the only thing
that survives.
