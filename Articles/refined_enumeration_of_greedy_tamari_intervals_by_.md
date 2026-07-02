# The Hidden Symmetry Between Mountain Ranges and Maps

## A counting coincidence that refuses to be a coincidence

Mathematics is full of surprises where two utterly different-looking families
of objects turn out to be counted by the very same numbers. When that happens,
mathematicians rarely shrug and move on. A matching pair of numbers is a
promise: somewhere, hidden beneath the surface, there is a *reason* — a
dictionary that translates one world into the other, object by object.

This is the story of one such promise, and of a single statistic — the humble
count of *valleys* in a mountain range — that turns out to be the secret
Rosetta Stone linking two of combinatorics' most beloved structures: the
**greedy Tamari order** on lattice paths, and **bipartite planar maps**, the
skeletons of surfaces cut into colored polygons.

## Mountain ranges made of grid steps

Begin with something you can draw on graph paper. A **Dyck path** of semilength
$n$ is a staircase walk that starts at the origin, takes exactly $n$ up-steps
$U = (1,1)$ and $n$ down-steps $D = (1,-1)$, ends back on the ground at
$(2n, 0)$, and never once dips below the horizontal axis. You can picture it as
a mountain range: it rises and falls, always staying at or above sea level, and
comes back to sea level at the end.

For example, with $n = 3$ one such path is $UUDUDD$: up, up, down, up, down,
down. It climbs to height two, comes partway down, climbs again, then descends
all the way home.

How many such mountain ranges are there? The answer is the **Catalan number**
$$C_n = \frac{1}{n+1}\binom{2n}{n},$$
one of the most famous sequences in all of mathematics: $1, 1, 2, 5, 14, 42,
132, \dots$. Catalan numbers count an almost absurd variety of things —
balanced strings of parentheses, triangulations of polygons, binary trees — and
Dyck paths are their purest incarnation.

Now zoom in on the *local shape* of a path. A **valley** is a spot where a
down-step is immediately followed by an up-step: the pattern $DU$, a little
V-shaped dip. A **peak** is the opposite, an up-step followed by a down-step,
the pattern $UD$, a little summit. Our example $UUDUDD$ has two peaks (at
positions $UD$ and $UD$) and one valley (the middle $DU$). This is no accident:
**every Dyck path has exactly one more peak than valley**, because peaks and
valleys must strictly alternate along the profile, beginning and ending with a
peak. If a path has $k$ valleys, it has $k+1$ peaks.

When you sort the Catalan-many Dyck paths by how many peaks they have, the
counts split into a gorgeous refinement called the **Narayana numbers**,
$$N(n,k) = \frac{1}{n}\binom{n}{k}\binom{n}{k-1},$$
the number of Dyck paths of semilength $n$ with exactly $k$ peaks. Summed over
$k$, the Narayana numbers rebuild the Catalan number: $\sum_k N(n,k) = C_n$.
They form a beautiful symmetric triangle, and they are the fingerprint of the
valley statistic.

## Turning a range into a lattice — the greedy way

Mountain ranges are more than a bag of shapes; they can be *ordered*. Imagine a
single elementary move: find a valley, and "rotate" the little dip to push the
path upward in a controlled way. Doing this repeatedly lets you climb from the
lowest possible path (a jagged zigzag $UDUD\cdots UD$) up to the highest (one
giant mountain $UU\cdots UDD\cdots D$). The classical version of this ordering is
the celebrated **Tamari lattice**, a structure that appears everywhere from
algebra to the geometry of associativity.

Recently attention has turned to a leaner, more rigid cousin called the
**greedy Tamari order** (here, the greedy $1$-Tamari order). It uses the same
raw material — Dyck paths — but a stricter, "greedy" rule for when one path sits
below another. The effect is to carve out a sparser set of comparabilities,
producing a poset whose *intervals* — the pairs $[x, y]$ with $x$ below $y$ —
have their own rich enumeration. An interval is simply a valid "from-here-to-
there" journey allowed by the order, and counting intervals is a classic way to
measure the fine structure of a partial order.

## Maps: gluing polygons into surfaces

Now leave the mountains behind and enter a completely different landscape. A
**planar map** is what you get when you draw a connected graph on the sphere (or,
equivalently, the plane) without any edges crossing, and then remember not just
the graph but the actual *drawing* — the cyclic order of edges around each
vertex, and the way the edges cut the surface into regions called **faces**. Maps
are the combinatorial DNA of surfaces; they are how physicists model random
geometry and how cartographers, in a sense, encode the structure of any
subdivided world.

A map is **bipartite** if its vertices can be painted in two colors — say black
and white — so that every edge joins a black vertex to a white one. Equivalently,
and this is the classical fact, a planar map is bipartite exactly when all its
faces have an even number of sides. To pin a map down rigidly and remove
symmetry, we **root** it by marking one oriented edge.

Rooted bipartite planar maps are counted by another famous set of numbers. If
you tally them by their number of edges, you recover a sequence discovered by
Tutte in his mid-century census of planar maps — and, strikingly, the count of
rooted bipartite planar maps with $n+1$ edges lands right back on the same
enumerative territory occupied by our greedy Tamari intervals. Two worlds,
mountains and maps, producing the same totals.

## The statistic that binds them

Total counts agreeing is tantalizing, but it is the *refined* statement that
turns a coincidence into a theorem. Here it is, stated plainly.

> **Main Theorem.** For every pair of natural numbers $n$ and $k$, the number of
> intervals $[x, y]$ in the greedy $1$-Tamari order on Dyck paths of semilength
> $n$ whose lower endpoint $x$ has exactly $k$ valleys is equal to the number of
> rooted bipartite planar maps with $n+1$ edges and exactly $k$ black vertices.

Read that again slowly, because it is doing something delicate. On the left, we
are not just counting intervals — we are counting them *sorted by a geometric
feature of the bottom path*, namely how many V-shaped dips it has. On the right,
we are not just counting maps — we are counting them *sorted by how many black
vertices they carry*. The claim is that these two gradings agree not merely when
you add everything up, but **cell by cell**, for every single value of $k$.

The valley count, in other words, is the shadow of a vertex-coloring. Follow the
greedy rotation rule that builds the order, read a Dyck path as the contour walk
of a tree, and each valley of the minimal endpoint becomes a black vertex of an
associated map. What looked like innocent bookkeeping — "how many little dips
does this path have?" — is revealed to be the same information as "how many black
vertices does this surface skeleton have?" The two distributions must therefore
match term by term.

## Why the refinement is the whole point

To feel why a *graded* match is so much stronger than a match of totals,
consider a homely analogy. Two boxes might each contain 100 coins. That is a
coincidence of totals. But if you sort each box by denomination and find that
each has exactly 37 pennies, 22 nickels, 19 dimes, and 22 quarters — matching
across every denomination — then you begin to suspect the two boxes were filled
by the same process. The Main Theorem is that stronger, denomination-by-
denomination agreement. It says the process filling the "mountain range" box and
the process filling the "map" box are secretly the same machine wearing two
costumes.

This refinement also lets us *decompose* the mystery into two cleaner pieces.
The lower endpoints, taken on their own, are distributed by valleys exactly
according to the Narayana triangle — the pure, symmetric fingerprint we met
earlier. The passage to intervals then attaches a *multiplicity* to each
endpoint: roughly, how many paths sit above it in the greedy order. So the full
bipartite black-vertex distribution factors as
$$\text{(Narayana endpoint distribution)} \times \text{(interval multiplicity weight)},$$
neatly separating the geometry of *where you start* from the geometry of *how far
you can go*. Understanding that single multiplicity weight is, in a precise
sense, the last unknown in the whole picture.

## A boundary echo

There is one more thread worth pulling, because it hints at how deep the
dictionary runs. Recall the tiny, sturdy fact that every Dyck path has exactly
one more peak than valley. That looks like a curiosity about staircases, but it
is really a special case of a general truth about *words*: for any string built
from two letters, the number of "descents" minus the number of "ascents" is
completely determined by the first and last letters — everything in the middle
cancels. Peaks-minus-valleys is exactly this telescoping identity applied to the
$UD$-word of a path.

Transport that boundary invariant across the mountain-to-map dictionary and it
should reincarnate as a rigid relationship between black and white vertices,
read off the boundary of the map's root face. The parity pattern of that boundary
— a two-letter word in its own right — ought to obey the same "descents minus
ascents equals endpoints" law, now speaking about colors instead of steps. The
same little cancellation, echoing across two worlds.

## Why it matters

At first glance this is a story about arcane combinatorial gadgets. But the
instinct driving it — *equal numbers demand an explanation* — is one of the most
productive engines in mathematics. Bijections born this way have unified vast
territories: they connect algebra to geometry, tie the counting of maps to the
physics of two-dimensional gravity, and turn opaque formulas into transparent
pictures. Planar maps in particular are a cornerstone of modern probability,
where random maps model the fluctuating geometry of space itself, and every new
statistic-preserving correspondence sharpens the tools for studying them.

The greedy Tamari order is a newcomer, only recently isolated as the rigid
companion of the classical Tamari lattice. That its intervals should march in
lockstep with bipartite maps, valley-count matching black-vertex-count at every
step, is exactly the kind of unexpected bridge that makes combinatorics feel less
like a catalog of curiosities and more like a single connected landscape — one
where a walk in the mountains and a journey across a map can turn out to be the
very same trip.
