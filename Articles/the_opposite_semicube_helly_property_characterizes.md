# When Pairs Are Enough: The Surprising Simplicity of Halfspaces in a Cube

## A puzzle about agreement

Imagine a committee of experts, each of whom cares about exactly one feature of a
proposal and insists it take a particular value. One expert demands *"the budget
must be approved."* Another insists *"the budget must be rejected."* A third says
*"the deadline must be in spring."* A fourth wants *"the venue downtown."* Each
expert, on their own, is easy to satisfy: there are plenty of proposals meeting any
single demand. The interesting question is whether **all** the experts can be
satisfied *at once*.

There is an obvious obstruction. If one expert wants the budget approved and another
wants it rejected, no proposal can please both — their demands are flatly
contradictory. But here is the striking fact this article is about: *that is the only
way things can go wrong.* If you can satisfy every **pair** of experts
simultaneously, then you can satisfy **all** of them simultaneously. Two-at-a-time
consistency automatically upgrades to all-at-once consistency.

This is a small miracle of geometry, and it is exact, provable, and — as we'll see —
part of a much larger story about how complicated spaces can be broken into simple,
independent pieces.

## The cube as a universe of choices

To make the puzzle precise, picture every proposal as a string of yes/no answers.
With $n$ binary features, a proposal is a point in the **$n$-dimensional cube** $Q_n$:
the set of all binary strings of length $n$. For $n = 2$ this is a square with corners
$00, 01, 10, 11$; for $n = 3$ it is an ordinary cube with eight corners; for larger
$n$ it is the higher-dimensional analogue, with $2^n$ corners in all. Two corners are
neighbors precisely when they differ in a single coordinate, so the cube is not just a
set of points but a graph — a network of proposals connected by "flip one feature"
moves.

It is convenient to describe a corner by the *set of features it turns on*. A corner
of $Q_n$ is then simply a subset $s$ of the coordinate set $\{1, 2, \dots, n\}$: the
coordinates in $s$ are the "yes" answers, and the rest are "no." This bookkeeping —
corners as subsets — will make everything below clean.

## Semicubes: the natural halfspaces

Each expert's demand carves the cube in half. Fix a coordinate $i$ and a bit
$b \in \{\text{yes}, \text{no}\}$. The **semicube** $H(i, b)$ is the set of all corners
whose $i$-th coordinate equals $b$:

$$H(i, b) = \{\, s : \text{coordinate } i \text{ of } s \text{ equals } b \,\}.$$

A semicube is exactly one of the two opposite faces of the cube perpendicular to the
$i$-th direction. It contains half the corners — $2^{n-1}$ of them. Semicubes are the
cube's version of *halfspaces*, the fundamental convex slabs out of which everything
else is built. An expert's demand "feature $i$ must equal $b$" is precisely the request
that the chosen proposal lie in the semicube $H(i, b)$.

Two facts about semicubes are immediate but worth stating, because the whole theory
rests on them.

**Opposite semicubes are disjoint.** For a single coordinate $i$, the two semicubes
$H(i, \text{yes})$ and $H(i, \text{no})$ share no corner at all:

$$H(i, \text{yes}) \cap H(i, \text{no}) = \varnothing.$$

A corner cannot have its $i$-th coordinate be both yes and no. This is the geometric
form of the contradictory-experts obstruction.

**Different coordinates are independent.** If two semicubes concern *different*
coordinates $i \neq j$, they always overlap. Whatever the demands on features $i$ and
$j$, there is a corner meeting both — just set coordinate $i$ and coordinate $j$ to the
requested values and fill in the rest arbitrarily. Cross-coordinate demands never
conflict.

## The main theorem: pairs decide everything

We can now state the result cleanly. A family of demands is nothing but a finite
collection $F$ of pairs $(i, b)$ — coordinate and requested bit. We say the family is
**pairwise satisfiable** if for every two demands in $F$ there is a corner meeting both.

> **Helly Number Two for Semicubes.** *Let $F$ be any finite family of semicubes in the
> cube $Q_n$. If every pair of semicubes in $F$ has a common corner, then all of the
> semicubes in $F$ share a common corner.*

The name comes from a classical theme in geometry. **Helly's theorem** says that among
convex sets in $d$-dimensional Euclidean space, if every $d+1$ of them intersect, then
all of them intersect; the number $d+1$ is the *Helly number* of that family. The
theorem above says the Helly number of the semicubes of a cube is just **2**, no matter
how large the dimension $n$ is. This is remarkable: a $1000$-dimensional cube, with its
astronomically many corners and thousands of independent directions, still needs only
*pairwise* consistency to guarantee global consistency. Dimension does not inflate the
threshold at all.

### Why it is true

The proof is as transparent as the statement. Suppose every pair of demands in $F$ can
be met simultaneously. We build one corner that meets *all* of them, by the most naive
recipe imaginable.

**Step 1 — Each coordinate speaks with one voice.** Take any coordinate $i$ that appears
in the family. Could the family contain *both* the demand $(i, \text{yes})$ and the
demand $(i, \text{no})$? If it did, those two demands would form a pair with no common
corner — because opposite semicubes are disjoint — contradicting pairwise
satisfiability. So for every coordinate mentioned by $F$, all demands about that
coordinate ask for the *same* bit. The family assigns each coordinate a well-defined
value; there is no internal disagreement.

**Step 2 — Read off the answer.** Define a single corner $v$ by the rule: coordinate
$i$ of $v$ is "yes" exactly when the family contains the demand $(i, \text{yes})$; every
other coordinate is set to "no." Because Step 1 guarantees no coordinate is demanded to
be both yes and no, this rule is unambiguous. And $v$ meets every demand in $F$ by
construction: if $(i, b)$ is in the family, then coordinate $i$ of $v$ was set to $b$.
So $v$ lies in every semicube of $F$, which is exactly the common corner we needed.

That is the entire argument. The only obstruction to global agreement is a single
coordinate pulled in two directions at once, and pairwise consistency rules that out.
Everything else takes care of itself, because distinct coordinates never interfere.

## Products, and where the story turns subtle

The independence of distinct coordinates has a beautiful structural consequence. A cube
$Q_{m+n}$ is a **Cartesian product** $Q_m \times Q_n$: a corner of the big cube is just
a pair consisting of a corner of the first factor and a corner of the second. The
coordinates split cleanly into "left" coordinates and "right" coordinates, and — as we
saw — a left demand and a right demand can never conflict. So the Helly property of the
product reduces, for free, to the Helly property of each factor separately. *Cross
pairs are never the problem.* This is why the theorem scales to any dimension: adding
independent directions adds no new obstructions.

But cubes are only the simplest members of a richer family called **partial cubes** —
graphs that embed into a cube without distorting distances, so that the graph distance
between two vertices equals the number of coordinates in which they differ. Trees, grid
graphs, the skeleta of many polytopes, and the "flip graphs" that appear throughout
combinatorics are all partial cubes. In a partial cube the role of a coordinate is
played by a **$\Theta$-class**: a bundle of parallel edges that, when cut, splits the
graph into two halves — the two opposite semicubes of that class. The theory of
semicubes and their Helly numbers extends verbatim to this world.

Here the plot thickens in an appealing way. Suppose we do not merely hand out a family
of demands, but *close it under opposites*: whenever a demand $(i, b)$ is present, we
also allow its mirror image $(i, \bar b)$ to enter the conversation. Now the single
contradictory-pair obstruction transforms into a **parity** obstruction. A coordinate
can be sidestepped only when its two opposite semicubes are genuinely interchangeable —
when swapping the two halves is a symmetry of the structure. That interchangeability has
a name: **harmonic-evenness**. A partial cube is harmonic-even when every $\Theta$-class
divides the vertices into two equal halves, and this balance persists inside every
convex piece of the graph.

This leads to a bold conjecture that grows directly out of the cube result:

> **Conjecture.** *A Cartesian product of two partial cubes satisfies the
> opposite-semicube Helly property — every pairwise-intersecting family that is closed
> under passing to opposites has a common vertex — if and only if both factors are
> harmonic-even.*

The intuition is exactly the intuition of this article, sharpened. In the plain cube,
distinct coordinates are free and only opposite pairs obstruct, so pairwise consistency
suffices. Once we close families under opposites, the factors of a product can no longer
coast: each must supply its own balance, its own harmonic-evenness, for the global
property to hold. The single-pair obstruction of the plain theorem becomes a balance
condition on each factor. The plain cube is the extreme case where balance is automatic
and the Helly number collapses to two.

## Why any of this matters

Beyond its elegance, "pairwise implies global" is exactly the kind of statement that
makes computation tractable. Checking whether a huge family of constraints is jointly
satisfiable is, in general, hard. But when the constraints are semicubes, you never have
to look at more than two at a time: scan the pairs, confirm no coordinate is demanded in
both directions, and read off the answer. A global question with exponentially many
potential witnesses is settled by a handful of local checks — linear in the number of
demands.

This local-to-global principle echoes across mathematics and its applications: in
constraint satisfaction, where the goal is to certify consistency cheaply; in
distributed systems, where independent agents want to reach agreement without
negotiating everything jointly; and in the geometry of "median" spaces and CAT(0) cube
complexes, where the same halfspace structure organizes everything from phylogenetic
trees to models of computation. The humble cube, sliced into its halves, turns out to be
a place where consistency is astonishingly cheap — and understanding exactly *why* it is
cheap points the way to the finer, balance-sensitive theory of products and their
factors.

The moral is one worth carrying to any problem built out of independent binary choices:
when the only way two demands can clash is by targeting the same feature in opposite
directions, checking pairs is not a shortcut — it is the whole story.
