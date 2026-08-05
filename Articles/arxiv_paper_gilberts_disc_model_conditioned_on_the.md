# One Dot Per Tile: When Does a Randomly Speckled Grid Become One Big Web?

## A city of one house per block

Imagine an infinite city laid out on perfect graph paper. Every unit square — every
city block — contains exactly one house, but nobody agreed on where in the block to
build it. One house hugs the north-west corner of its block, its neighbour sits dead
centre, a third is pressed against the southern kerb.

Now give every house a radio with range $R$. Two houses can talk directly if the
straight-line distance between them is less than $R$. Radios relay: if $A$ can reach
$B$ and $B$ can reach $C$, then $A$ and $C$ are in the same conversation, however far
apart they are on the map.

The question that drives everything below is disarmingly simple.

> **How big does the radio range $R$ have to be before the network stops being a
> scatter of little gossip circles and becomes a single infinite web?**

This is a *conditioned* version of one of the oldest and most studied objects in
probability, **Gilbert's disc model**. In Gilbert's original 1961 model the points are
thrown down completely at random across the plane — a Poisson process — and one asks
for the critical density at which an infinite cluster appears. That threshold is
famously not known in closed form; it is a stubborn number determined by simulation to
be around $\lambda_c r^2 \approx 0.3591$.

The model here is Gilbert's model with a strong constraint layered on top: **exactly one
point per unit cell of the grid $\mathbb{Z}^2$**. Conditioning a Poisson process to be
this well-behaved changes the geometry completely. Clumping is forbidden; so are large
empty deserts. The randomness that survives is purely *local jitter* — where inside its
own block each house sits.

And that local jitter turns out to be enough to make the problem sharp, geometric, and
in several places completely solvable by hand.

## Three different thresholds

The moment you fix the "one point per cell" rule, a single critical radius splinters
into several, because you can now ask questions about *all* placements at once. Write
a **placement** for a choice, for every cell $(i,j)$ of the integer grid, of one point
inside the closed square $[i,i+1]\times[j,j+1]$. Three thresholds present themselves.

**The optimist's threshold $R_{\min}$.** The smallest range such that *some* placement
of the houses produces an infinite chain. Here you are allowed to be the architect: you
place every house yourself, conspiring to build the longest possible network with the
weakest possible radios.

**The connector's threshold $R_{\mathrm{conn}}$.** The smallest range such that *some*
placement makes **every** house reachable from every other — not just an infinite
component, but one single component containing everything.

**The pessimist's threshold $R_{\mathrm{full}}$.** The smallest range such that **every**
placement, including the most adversarial one imaginable, connects all the houses. Above
this range, no arrangement of houses can hide a disconnection anywhere in the infinite
plane.

Clearly $R_{\min}\le R_{\mathrm{conn}} \le R_{\mathrm{full}}$: connecting everything is
harder than merely producing one infinite component, and doing it for all placements is
harder than doing it for one. The genuine content is in the numbers, and in the geometric
constructions that pin them down.

## Building the longest chain from the weakest radios

Start with the optimist. How small can $R$ be if you get to place every point yourself?

Here is a beautiful construction. Look only at the two rows of cells $j=0$ and $j=1$. In
each cell $(i,0)$ of the bottom row, place the point at $(i+\tfrac34,\,1)$ — pushed as far
*up* as it can go, on the very top edge of the cell, three-quarters of the way across.
In each cell $(i,1)$ of the top row, place the point at $(i+\tfrac14,\,1)$ — pushed as far
*down* as it can go, one-quarter of the way across.

Every one of these points now lies on the single horizontal line $y=1$. Reading them left
to right, their $x$-coordinates are
$$\ldots,\quad i+\tfrac14,\quad i+\tfrac34,\quad i+1+\tfrac14,\quad i+1+\tfrac34,\quad\ldots$$
Consecutive points are at distance exactly $\tfrac12$: the point of cell $(i,1)$ at
$i+\tfrac14$ and the point of cell $(i,0)$ at $i+\tfrac34$ are half a unit apart, and the
point of cell $(i,0)$ is half a unit from the point of cell $(i+1,1)$ at $i+1+\tfrac14$.

So the moment $R>\tfrac12$, this zig-zag chain lights up all the way to infinity in both
directions. The whole double row $\mathbb{Z}\times\{0,1\}$ becomes one infinite cluster.

> **Theorem (existence of a percolating placement).** For every $R>\tfrac12$ there is a
> placement of one point per cell whose graph has an infinite connected component.
> Consequently $R_{\min}\le\tfrac12$.

Why can't you do better than $\tfrac12$? This is the crux of the problem. Intuitively:
to make progress rightward, your chain must keep crossing vertical grid lines $x=K$, and
each crossing costs you geometry. If two consecutive points sit on opposite sides of the
line $x=K$ and both within distance $R$ of each other, then both are within $R$ of the
line itself. But between crossings, the chain has to *traverse* a whole cell of width
one. The tension between "always near the line you just crossed" and "advance a full unit
of width" is exactly what makes progress impossible for small $R$. Making that tension
into a proof is the heart of the next result.

## Nothing escapes a $3\times 3$ box

> **Theorem (deterministic non-percolation).** Suppose $R<\tfrac13$. Then for **every**
> placement of the points, and every cell $c$, every cell reachable from $c$ differs from
> $c$ by at most one in each coordinate. In particular every connected component lies
> inside a $3\times3$ block of cells, and no placement produces an infinite component.
> Consequently $R_{\min}\ge\tfrac13$.

Note how strong this is: it is not a statement about a typical random placement, it is a
statement about *all* placements simultaneously — a purely geometric fact about the unit
grid. The proof is a lovely piece of bookkeeping and worth walking through, because it
shows exactly where the constant $\tfrac13$ comes from.

**Step 1: an edge is a line-crossing certificate.** If two joined points lie in cells with
different columns, those columns must be adjacent (an edge cannot have horizontal extent
$\ge R$, and $R<1$). Let $x=K$ be the vertical grid line separating the two columns. Then
the left point lies in $[K-1,K]$ and the right point in $[K,K+1]$, and they are less than
$R$ apart, so **both points are within distance $R$ of the line $x=K$**. The same holds
for rows and horizontal lines.

**Step 2: you can only ever be near one line.** Two distinct integers are at distance at
least $1$. So if the current point is within $2R<\tfrac23<1$ of the line $x=K$, then no
*other* integer line $x=K'$ can be within $R$ of it. Whatever vertical line the walk
crosses next, it must be the same line $K$.

**Step 3: a travelling invariant.** Follow a self-avoiding chain. Track two integers $K$
and $J$ — the only vertical and the only horizontal grid lines the chain will ever cross —
and maintain, at each step with previous cell $p$ and current cell $c$:

- the columns of $p$ and $c$ both lie in $\{K-1,K\}$, and their rows both in $\{J-1,J\}$;
- the current point is within $2R$ of the line $x=K$, and within the tighter distance $R$
  if the last step actually changed the column; symmetrically for $y$ and $J$.

**Step 4: the invariant survives every step.** Suppose the chain moves from $c$ to a new
cell $c'$ different from the previous cell $p$. There are three cases. If the step changes
the row only, the crossed horizontal line must be $J$ (Step 2) and the new point lands
within $R$ of it; the horizontal slack degrades from $R$ to at most $2R$ by the triangle
inequality, since the point moved less than $R$. If the step changes the column only, the
mirror argument applies. If it changes both, both slacks are refreshed to the tight value
$R$. The one thing that could break the bookkeeping is a step that changes *neither* the
column nor the row — impossible, since it would mean $c'=c$ — or a step that repeatedly
declines to refresh a coordinate; and here the argument closes elegantly: if the chain
takes two consecutive steps that both leave the column unchanged, then both steps cross the
*same* horizontal line $J$, so the chain steps from row $J$ to row $J-1$ and straight back,
returning to its previous cell. A self-avoiding chain cannot do that.

**Step 5: assemble.** Two steps suffice to install the invariant with $K\in\{c_0^{(1)},
c_0^{(1)}+1\}$ and $J\in\{c_0^{(2)},c_0^{(2)}+1\}$, where $c_0$ is the starting cell. From
then on every cell of the chain has column in $\{K-1,K\}$ and row in $\{J-1,J\}$ — a
$2\times2$ block that, together with the two allowed choices of $K$ and $J$, sits inside a
$3\times3$ block around the start. Done.

The number $\tfrac13$ enters at Step 2: the argument needs $3R<1$ so that the "loose"
slack $2R$ plus a further step of length $R$ cannot reach a *different* integer line. The
truth is almost certainly $\tfrac12$ — see below — but $\tfrac13$ is what this clean
argument buys, unconditionally and for every placement at once.

## Connecting everything: the number $\sqrt5$

Now the pessimist's question. How large must $R$ be so that **no** placement, however
malicious, can disconnect the network?

The upper bound is a one-liner. Take two cells that share an edge, say $(i,j)$ and
$(i+1,j)$. Their points can be at most $2$ apart horizontally (one at the far left of the
left cell, the other at the far right of the right cell) and at most $1$ apart vertically.
So their distance is at most $\sqrt{2^2+1^2}=\sqrt5$. The same for vertically adjacent
cells. Hence:

> **Theorem (universal connectivity above $\sqrt5$).** For every $R>\sqrt5$ and every
> placement, all points are connected: the graph contains the entire nearest-neighbour grid
> of $\mathbb{Z}^2$, which is connected. Consequently $R_{\mathrm{full}}\le\sqrt5\approx
> 2.2360$.

Is $\sqrt5$ sharp? To show it is not much smaller, we need an adversarial placement — a
*cut*. Here is one. Push every point in every row $j\ge1$ to the **top** edge of its cell,
at $(i+\tfrac12,\,j+1)$, and every point in every row $j\le0$ to the **bottom-left**
corner of its cell, at $(i,\,j)$.

Look at the horizontal seam between row $0$ and row $1$. A point above the seam has
$y$-coordinate at least $2$; a point below has $y$-coordinate at most $0$. So any crossing
edge has vertical extent at least $2$. And the horizontal stagger of $\tfrac12$ guarantees
that its horizontal extent is at least $\tfrac12$, since the $x$-coordinates above are
half-integers-plus-a-half and below are integers. Therefore the shortest possible crossing
edge has length at least
$$\sqrt{2^2+\left(\tfrac12\right)^2}=\frac{\sqrt{17}}{2}\approx 2.0616 .$$

> **Theorem (a stubborn cut).** For every $R\le\tfrac{\sqrt{17}}2$ there is a placement
> whose graph is disconnected: no chain of points crosses the seam, so the upper half plane
> and the lower half plane never communicate. Consequently
> $R_{\mathrm{full}}\ge\tfrac{\sqrt{17}}2$.

Together: $\tfrac{\sqrt{17}}2 \le R_{\mathrm{full}} \le \sqrt5$, that is
$2.0616\le R_{\mathrm{full}}\le 2.2360$. A gap of about $0.17$ separates the best known
adversary from the best known guarantee.

## The middle threshold, and the honest centre

Between the two lies $R_{\mathrm{conn}}$, the range at which *some* placement connects
everything. The natural candidate placement is the most symmetric one: put every point at
the exact centre of its cell, at $(i+\tfrac12,\,j+\tfrac12)$. Then points of edge-adjacent
cells are at distance exactly $1$, so for every $R>1$ the whole grid is connected in one
component.

Conversely, if a placement connects everything, it certainly percolates, so the
non-percolation theorem applies:

> **Theorem (bounds for the connecting threshold).** $\tfrac13\le R_{\mathrm{conn}}\le1$,
> and the three thresholds obey $R_{\min}\le R_{\mathrm{conn}}\le R_{\mathrm{full}}$.

Here the gap is at its widest, and the truth is genuinely interesting: to connect
*everything* you must serve every cell, including cells whose neighbours you have already
committed elsewhere. Whether one can beat the centred configuration — connect all points
with some clever placement using a range below $1$ — is open.

## Where the answers stand

| Threshold | Meaning | Known bounds |
|---|---|---|
| $R_{\min}$ | some placement percolates | $\tfrac13\le R_{\min}\le\tfrac12$ |
| $R_{\mathrm{conn}}$ | some placement connects everything | $\tfrac13\le R_{\mathrm{conn}}\le1$ |
| $R_{\mathrm{full}}$ | every placement connects everything | $\tfrac{\sqrt{17}}2\le R_{\mathrm{full}}\le\sqrt5$ |

The conjecture, supported by extensive numerical search over periodic chains, is that
$R_{\min}=\tfrac12$ exactly — that the zig-zag double-row chain is genuinely optimal, and
that no cleverer periodic pattern squeezes an infinite path out of a smaller radius. An
exhaustive optimisation over all drifting periodic chains of period at most $4$, and a
random search over periods $5$ through $8$, never found a pattern whose longest edge dipped
below $\tfrac12$. Refuting the conjecture requires only one counterexample: a single
periodic pattern with nonzero drift and every edge shorter than a half.

A companion conjecture concerns *how* subcritical the model is below $\tfrac12$. The
theorem above gives a component diameter of $3$ once $R<\tfrac13$; the slack recursion
buried in its proof — each column advance eats $1-2R$ of your budget — suggests that for
$R<\tfrac12$ components should have diameter of order $(1-2R)^{-1}$, blowing up only as $R$
climbs to a half. Proving that would give a complete quantitative picture of the
subcritical phase.

And for full connectivity the conjecture is $R_{\mathrm{full}}=\sqrt5$: that the worst
placement really is the "push everything to the boundary" one, and that some cut always
survives below $\sqrt5$.

## Why the constraint matters

There is a broader lesson in this model, and it is why conditioned point processes are
attracting attention across probability, statistical physics, and materials science.

Real physical systems are rarely Poisson. Atoms repel; trees compete for light; base
stations are planned, not sprinkled. A **hyperuniform** point process — one whose density
fluctuations are anomalously suppressed at large scales — behaves quite differently from a
Poisson cloud, and the lattice-conditioned model here is about as hyperuniform as it gets:
the number of points in any large region is determined to within the boundary error, since
it equals the number of cells the region meets.

The consequences are visible in every result above. Poisson percolation has no analogue of
$R_{\mathrm{full}}$ at all — with probability one there are arbitrarily large empty
regions, so no finite radius connects everything. It has no analogue of $R_{\min}$ either,
since a Poisson realisation is not something you choose. Conditioning replaces a single
mysterious constant with a family of crisp, geometric constants, several of which are
exactly computable and all of which are bracketed by explicit constructions.

The proofs, too, change character. Poisson percolation is analysed with correlation
inequalities, renormalisation, and duality. The conditioned model on the lattice yields to
something more elementary and more visual: crossing lemmas, invariants that travel along a
path, and a few carefully drawn extremal pictures. A zig-zag on a line. Points pushed
against the boundary of their cells. Half a unit of stagger across a seam.

That is the pleasure of this problem. It is a percolation question whose answers you can
almost see.
