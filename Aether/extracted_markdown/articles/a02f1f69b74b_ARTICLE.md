# The Staircase and the Determinant: How Counting Walks on a Grid Unlocks an Entire Branch of Mathematics

Imagine you are standing at the bottom-left corner of a city laid out as a
perfect grid. You want to reach a friend who lives some blocks east and some
blocks north. To save time you only ever walk east or north — never backward.
How many different routes can you take?

This is one of the oldest questions in combinatorics, and at first glance it
looks like a children's puzzle. Yet pull on this single thread and an
astonishing amount of mathematics comes unspooling: Pascal's triangle, the
binomial theorem, election forecasting, the algebra of polynomials, and even a
deep nineteenth-century technique for counting *families* of routes that never
cross. This article tells the story of that thread, and of a small, sturdy
mathematical toolkit — a set of theorems about lattice paths — that ties the
whole tapestry together.

## A grid, two directions, and a surprising count

Let us name our destination. If your friend lives `m` blocks east and `n`
blocks north, write `pathCount(m, n)` for the number of east-north routes from
your corner to theirs. There is a beautifully simple way to compute this number
without drawing a single map.

Stand at any intersection. The very last step of your journey was either an
*East* step (so the step before it left you one block to the west) or a *North*
step (so the step before it left you one block to the south). Every route ends
in exactly one of these two ways, and the two possibilities never overlap. This
gives a recurrence — a rule that builds bigger answers from smaller ones:

> **Pascal's recurrence for paths.**
> `pathCount(m, 0) = 1`, `pathCount(0, n) = 1`, and
> `pathCount(m+1, n+1) = pathCount(m, n+1) + pathCount(m+1, n)`.

The boundary cases say there is exactly one way to walk in a straight line: if
you only need to go east, you march east; if you only need to go north, you
march north. The recurrence is just the "last step was E or N" observation
written in symbols.

Anyone who has seen Pascal's triangle will feel a tingle of recognition, and
the feeling is correct. The path count is exactly a **binomial coefficient**:

> **Theorem (paths are binomials).** `pathCount(m, n) = C(m+n, n)`,
> the number of ways to choose `n` items from `m+n`.

The reason is pure poetry. A route is just a sequence of `m+n` steps, of which
exactly `n` are North. To describe a route completely you only need to say
*which* of the `m+n` steps are the North ones — and choosing `n` positions out
of `m+n` is the very definition of `C(m+n, n)`. Counting routes and choosing
subsets are the same act in two disguises.

A second, almost trivial-looking fact hides a useful principle:

> **Theorem (symmetry).** `pathCount(m, n) = pathCount(n, m)`.

Of course it does — tilt your head, swap the meaning of "east" and "north," and
every route from the `(m, n)` problem becomes a route for the `(n, m)` problem.
This is our first encounter with a *bijection*: a perfect pairing between two
sets that proves they are the same size without ever counting either one. The
swap of East and North will return, in a more dramatic role, near the end of
the story.

## Crossing a meridian: the Vandermonde identity

Counting becomes powerful when you slice a problem into independent pieces. Draw
a vertical line `m` blocks east of your start. Every route to a destination
`m + n` blocks east in total must cross that line at some height `k`. Before the
line you walked from the corner up to height `k` inside an `m`-wide strip; after
the line you finished the climb inside an `n`-wide strip. The two halves are
completely independent, so the number of full routes through height `k` is a
product of two smaller path counts, and the grand total sums over all heights.

Translated into binomials, this is one of the most quoted identities in all of
combinatorics:

> **Vandermonde convolution.**
> `C(m+n, r) = Σ_{k=0}^{r} C(m, k) · C(n, r-k)`.

Probabilists use it constantly: it is exactly the statement that the sum of two
independent "counting" experiments behaves the way intuition demands. Here it
falls out of nothing more than drawing a line on a map and noticing that what
happens on the left of the line cannot affect what happens on the right.

## The algebra hiding in the triangle

Two more identities deserve a spotlight, because they are the quiet workhorses
behind a hundred proofs.

The first is the **absorption identity**:

> `(k+1) · C(n+1, k+1) = (n+1) · C(n, k)`.

Read it as a story about committees. On the left: choose a committee of `k+1`
people from a pool of `n+1`, then promote one of them to chair. On the right:
first appoint a chair from the `n+1` people, then fill out the remaining `k`
seats from the `n` who are left. Same committees, same chairs, counted two ways
— so the totals must agree. Its close cousin, `C(n, k+1) · (k+1) = C(n, k) · (n - k)`,
plays the same balancing trick and is the gear that makes induction proofs turn
smoothly.

The second is the **ballot identity**, and it carries real-world weight. In an
election, candidate A finishes with `m` votes and candidate B with `n` votes,
where `m ≥ n`. As the ballots are counted one by one, what is the chance that A
is *strictly ahead the entire time*, never once tied or trailing? The answer is
governed by an identity discovered through Désiré André's celebrated
**reflection principle** of 1887:

> **Ballot reflection identity (for `n ≤ m`).**
> `(m + n + 1) · ( C(m+n, n) − C(m+n, m+1) ) = (m + 1 − n) · C(m+n+1, n)`.

André's idea is breathtakingly visual. The "bad" counting orders — the ones
where the race is tied at some moment — can be put into perfect correspondence
with a set of *reflected* paths by flipping the route at the first moment of a
tie. Subtracting the bad routes from all routes leaves precisely the good ones,
and the algebra above is the residue of that geometric flip. Election-night
forecasting, queueing theory, and the statistics of random walks all rest on
this single reflection.

## Paths that refuse to cross: the Lindström–Gessel–Viennot lemma

So far we have counted single routes. The summit of this theory is counting
*families* of routes that never touch one another — and the tool that conquers
it is one of the most elegant results in modern combinatorics, the
**Lindström–Gessel–Viennot (LGV) lemma**, developed by Bernt Lindström in 1973
and by Ira Gessel and Gérard Viennot in 1985.

Here is the setup. Place several travelers at several starting corners, and
assign each a destination corner. We want to count the ways for all of them to
walk simultaneously so that no two paths ever share a point — like trains on a
network that must never collide. Counting such non-collision configurations
directly is a nightmare of case analysis.

The LGV lemma performs a magic trick. Build a small grid of plain path counts:
entry `(i, j)` records how many routes lead from start `i` to destination `j`,
ignoring all collisions. Then take the **determinant** of that grid — the same
determinant from linear algebra, an alternating sum of products. The lemma says:

> The determinant of the matrix of (uncrossed) path counts equals the signed
> number of *non-intersecting* path families.

All the messy collision cases cancel in perfect pairs inside the determinant's
alternating sum, leaving only the configurations that never cross. A hard
counting problem dissolves into a single determinant.

The smallest instance is already charming. Put two travelers at adjacent corners
`(0,0)` and `(0,1)`, sending them to the adjacent corners `(n,0)` and `(n,1)`.
The relevant determinant works out to

> **LGV 2×2 base case.** `C(n,0) · C(n+1,1) − C(n+1,0) · C(n,1) = 1`.

The value `1` is not an accident: there is *exactly one* way for the two
travelers to reach their destinations without crossing. The lower traveler must
march straight east; the upper traveler must step north once and then march
east. Any other choice forces a collision. The determinant has counted, with a
single subtraction, a configuration that is geometrically unique.

To make this kind of reasoning reusable, the underlying mathematics is packaged
into an abstract object — a **weighted path system**. Instead of fixing the
grid, you allow any directed network whose edges always increase a "rank," which
forbids cycles and guarantees that journeys are finite. Each edge may carry a
weight drawn from any reasonable number system. The ordinary grid is the special
case where every edge has weight one. With this abstraction, the LGV philosophy
applies far beyond city blocks: to weighted networks, to signed counts, and — as
we are about to see — to polynomials that record geometric information.

## Giving each path a fingerprint: the area under the staircase

Until now every route counted for exactly one. But routes have *shape*. A route
that hugs the bottom of the grid before climbing looks very different from one
that climbs first and then runs along the top. We can measure that difference
with **area**: the number of unit squares trapped between the staircase route and
the bottom edge of the grid.

Computing the area is a single sweep. Walk the route from the start; keep a
running tally of how high you currently are (how many North steps you have taken
so far). Every time you take an East step, you drag the entire column beneath you
along, adding the current height to the area. North steps build height; East
steps cash it in. That is the whole definition.

This sweeping description has a clean consequence about *starting higher up*. If
you begin the same route at height `h` instead of at the ground, every East step
is lifted by `h`, so the area grows by exactly `h` times the number of East
steps:

> **Area shift.** `area-from-height-h(p) = area(p) + h · (East steps of p)`.

Now comes the most beautiful identity in the collection — and it features the
return of our East-North swap. Take any route `p`. Reflect it by swapping every
East step into a North step and vice versa; call the result `swap(p)`. Then:

> **Area complement.**
> `area(p) + area(swap(p)) = (East steps of p) · (North steps of p)`.

The proof is a gem of double-counting. Pair up each East step with each North
step. There are exactly `(East steps) · (North steps)` such pairs, and every
single pair contributes a `1` to exactly one of the two areas — to `area(p)` if
the North step comes first, and to `area(swap(p))` otherwise. Nothing is double
counted and nothing is missed, so the two areas must add up to the total number
of pairs. Swapping a path is an **involution** — do it twice and you return
exactly to where you started — which makes the pairing perfectly clean.

This humble equation is the seed of a famous symmetry: the area statistics of
lattice paths are *palindromic*. If you list how many routes have each possible
area, the list reads the same forwards and backwards. Beauty, it turns out, was
hiding in the bookkeeping all along.

## Polynomials that remember geometry: the Gaussian binomials

We can fold every route's area into a single algebraic object. Introduce a
formal variable `q` and, for each route, record `q` raised to that route's area.
Add these contributions over all routes from the corner to `(m, n)`. The result
is a polynomial in `q` called the **Gaussian binomial coefficient**, written
`[m+n choose n]_q`:

> `qBinomial(m, n) = Σ_{routes p to (m,n)} q^{area(p)}`.

These polynomials obey their own version of Pascal's recurrence — the *q-Pascal*
rule — where one of the two branches is weighted by a power of `q` to account for
the extra area created by an additional North step:

> `qBinomial(m+1, n+1) = qBinomial(m+1, n) + q^{n+1} · qBinomial(m, n+1)`.

What happens if we set `q = 1`? Every `q^{area}` collapses to `1`, so each route
again contributes a plain `1`, and we are simply counting routes once more:

> **Specialization at q = 1.** `qBinomial(m, n)` evaluated at `q = 1` equals
> `C(m+n, n)`.

The Gaussian binomial is therefore a richer, geometry-aware refinement of the
ordinary binomial — it remembers not just *how many* routes there are, but *how
they are shaped*, and forgets the shape only when you ask it to. Two small
examples make the idea concrete:

- `qBinomial(1, 1) = 1 + q`. There are two routes across a 1×1 block: "East then
  North" encloses zero squares (the `1`), and "North then East" encloses one (the
  `q`).
- `qBinomial(2, 1) = 1 + q + q²`. The three routes across a 2×1 strip enclose
  zero, one, and two squares respectively.

Set `q = 1` in either and you recover `2` and `3` — exactly the ordinary path
counts. The area-complement theorem from the previous section is precisely why
these polynomials are palindromic: read `1 + q + q²` backwards and it is
unchanged.

## Why this little grid matters

It is tempting to dismiss path counting as recreational. The opposite is true.
The same determinant trick that resolves two non-crossing travelers scales up to
prove hook-length formulas for the symmetry types of particles, to compute
volumes of geometric objects, and to power algorithms in statistical physics
where configurations of non-crossing paths model everything from polymers to ice.
Gaussian binomials are the entry point to *quantum groups* and to the algebra of
finite fields, where `[m+n choose n]_q` literally counts the lower-dimensional
slices sitting inside a higher-dimensional space. The reflection principle behind
the ballot identity underlies the modern theory of random walks and the pricing
of certain financial instruments.

A bolder frontier remains open. There is a tantalizing conjecture that the
*Alexander polynomial* — a classical fingerprint that distinguishes knotted loops
of string — can be written as a 2×2 LGV determinant of modified Gaussian
binomials, with paths forbidden from entering regions dictated by the knot's
diagram. For the simplest nontrivial knot, the trefoil, the prediction is sharp:
the determinant should reproduce the trefoil's signature polynomial `1 − t + t²`.
If the conjecture holds, it would reveal that even the tangledness of a knot is,
at bottom, a question about counting walks on a grid.

That is the quiet power of the staircase. A child's question about routes through
a city turns out to be a master key — opening doors onto algebra, probability,
geometry, and the deep structure of mathematical objects we never suspected were
related. Every one of the results above has been stated precisely and checked
down to the last symbol. The grid, it seems, has a great deal more to teach us.
