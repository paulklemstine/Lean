# Counting the Ways a Sphere Can Fold Onto Itself

## A puzzle about symmetry

Take a rubber ball and imagine you are allowed to squash, stretch, and fold it—
but with one unbreakable rule: whatever you do to a point on the ball, you must do
the exact mirror-image operation to the point directly opposite. If the north pole
travels somewhere, the south pole must travel to the mirror-image spot. This is the
rule of *antipodal symmetry*, and it is one of the oldest and most surprising sources
of rigidity in all of mathematics.

The most famous consequence is the **Borsuk–Ulam theorem**: at any instant there are
two points on exactly opposite sides of the Earth with the same temperature *and* the
same barometric pressure. You cannot escape it. No matter how the weather churns, the
antipodal rule forces a coincidence. The reason is that a symmetric map of a sphere
cannot "unfold" the sphere onto something of lower dimension without tearing it.

This article is about a clean, combinatorial way to make that rigidity completely
explicit—so explicit that we can literally *count* the number of symmetric ways one
sphere can be folded onto another, and watch a single invariant, the **coindex**,
climb by exactly one every time we add a dimension.

## Spheres made of axes

Forget the smooth rubber ball for a moment. There is a beautifully economical way to
build a sphere out of nothing but coordinate axes.

Start in the plane with the two axes $x$ and $y$. Mark the four unit points
$+x, -x, +y, -y$ and connect neighboring ones. You get a diamond—a square standing on
its corner. Its boundary is a loop, a combinatorial circle. We call it $S^1$.

Now go to three dimensions with axes $x, y, z$. The six points
$\pm x, \pm y, \pm z$ are the corners of an **octahedron**, and its triangular surface
is a combinatorial sphere $S^2$. Push this into $n+1$ dimensions and you get the
**cross-polytope**: the $2(n+1)$ points $\pm e_0, \pm e_1, \dots, \pm e_n$, one
positive and one negative point on each of $n+1$ axes. The surface of this shape is
the combinatorial sphere $S^n$.

The payoff of this austere model is that every vertex is just a pair: *which axis*
and *which sign*. Write a vertex as $(i, s)$, where $i \in \{0, 1, \dots, n\}$ names
an axis and $s \in \{+, -\}$ names a sign. The antipodal map—the mirror rule—could
not be simpler: it flips the sign, $(i, +) \leftrightarrow (i, -)$, and leaves the
axis alone. A "face" of the sphere is a set of vertices lying on *distinct* axes; you
are never allowed to use both a point and its own antipode in the same face.

## Symmetric maps are secretly just relabelings of axes

A symmetric map—technically a **$\mathbb{Z}_2$-map**—from $S^m$ to $S^n$ is a way of
sending vertices to vertices that (a) respects the antipodal rule and (b) sends faces
to faces without collapsing them. It is the combinatorial stand-in for a continuous
antipodal-preserving map.

Here is the heart of the whole story, and it is remarkably simple. Because a face is
just a set of *distinct axes*, sending faces to faces means: **distinct axes must go
to distinct axes.** And respecting the antipodal rule means: once you decide where the
positive point of an axis goes, the negative point is forced to the opposite. So a
symmetric map is completely described by two independent pieces of data:

- an **injection** $\varphi$ of the source axes $\{0, \dots, m\}$ into the target
  axes $\{0, \dots, n\}$ (distinct axes to distinct axes), and
- a free choice of **sign** $\sigma(i) \in \{+, -\}$ for each source axis, saying
  whether that axis is sent "straight" or "flipped."

That's it. A symmetric antipodal map of these spheres is *exactly* an injection of
coordinate axes with independent signs. Every subtle topological constraint has
dissolved into elementary combinatorics.

This single insight has an immediate, almost startling, consequence. An injection of
$\{0, \dots, m\}$ into $\{0, \dots, n\}$ exists **if and only if** $m \le n$. So:

> A symmetric map $S^m \to S^n$ exists precisely when $m \le n$.

There is no way to symmetrically map a big sphere into a smaller one, for the most
mundane of reasons: you cannot fit more axes than you have room for. This is the
Borsuk–Ulam phenomenon, stripped to its combinatorial bones. In particular there is
**no** symmetric map $S^{n+1} \to S^n$—the pigeonhole principle forbids squeezing
$n+2$ axes into $n+1$ slots.

## The coindex: how big a sphere fits inside

Every space with an antipodal symmetry carries a number that measures how "big" it is
from the symmetric point of view. The **coindex** of a space $X$ is the largest $n$
such that some sphere $S^n$ admits a symmetric map *into* $X$:
$$\operatorname{coind}(X) = \max\{\, n : \text{there is a } \mathbb{Z}_2\text{-map } S^n \to X \,\}.$$
It is the size of the largest symmetric sphere you can wrap around inside $X$.

From the rule above, the coindex of a combinatorial sphere is no mystery at all:
$$\operatorname{coind}(S^n) = n.$$
A sphere $S^m$ maps symmetrically into $S^n$ exactly when $m \le n$, so the largest
one that fits is $S^n$ itself. The coindex simply *is* the dimension. Two little
base cases anchor the whole tower and can be checked entirely by hand: there is no
symmetric map $S^1 \to S^0$ (two axes will not fit into one), giving
$\operatorname{coind}(S^0) = 0$; and no symmetric map $S^2 \to S^1$ (three axes will
not fit into two), giving $\operatorname{coind}(S^1) = 1$.

## Four ways to build new maps from old

What makes this world a genuine *structure* rather than a list of facts is that the
symmetric maps compose and combine like the morphisms of a category. There are four
fundamental construction moves, and each one is a transparent operation on the
underlying axis-injections.

**Identity and composition.** The do-nothing map is a symmetric map, and two symmetric
maps in a row give a symmetric map. (Injections compose to injections; signs multiply.)

**The equatorial inclusion.** Every sphere sits inside the next one up as its equator:
$S^n \hookrightarrow S^{n+1}$ simply keeps all the old axes and ignores the brand-new
one. This is the map that witnesses $\operatorname{coind}(S^n) \ge n$ climbing the
tower.

**Suspension.** This is the geometric engine of the whole subject. To *suspend* a map
is to add one new axis to both the source and the target—a new pair of poles—map the
new source pole straight to the new target pole, and act by the old map on everything
else:
$$\operatorname{susp}: (S^m \to S^n) \;\longmapsto\; (S^{m+1} \to S^{n+1}).$$
Because it always adds one axis to a genuine injection, suspension turns an injection
into an injection. It faithfully lifts the entire theory one dimension at a time.

**Join.** The most powerful move fuses two maps into one. If we have a symmetric map on
one block of axes and another on a second, disjoint block, we can run them side by side.
Topologically the *join* of two spheres is again a sphere—glue a cross-polytope on
$a+1$ axes to one on $c+1$ axes and you get a cross-polytope on $(a+1)+(c+1)$ axes,
which is $S^{a+c+1}$. On maps, the join places the first map's axis-injection into the
low block of the target and the second map's into a *shifted* high block, so their
ranges never collide. A block sum of two injections into disjoint ranges is again an
injection—so the join of two symmetric maps is a symmetric map:
$$(S^a \to S^b) \ \text{and}\ (S^c \to S^d) \ \longmapsto\ (S^{a+c+1} \to S^{b+d+1}).$$

Suspension, it turns out, is just the join with the smallest sphere of all, the
$0$-sphere: joining with $S^0$ adds exactly one axis. Join adds a whole block; suspension
adds a single pole. They are two faces of one idea.

## The exact laws

Once you see symmetric maps as axis-injections with signs, three exact laws fall out,
and they are the mathematical spine of this work.

**The suspension increment is exactly one.** Suspension raises the coindex by precisely
one at every level:
$$\operatorname{coind}(S^{n+1}) = \operatorname{coind}(S^n) + 1.$$
Not "at least one," not "roughly one"—exactly one. The lower bound comes from the
suspension construction (we can always add an axis), and the matching upper bound comes
from the pigeonhole obstruction (we can never fit an extra axis). Anchored by the two
hand-checked base cases, the increment marches up the tower without slack.

**The join is coindex-additive, plus one.** For combinatorial spheres,
$$\operatorname{coind}(S^a * S^c) = \operatorname{coind}(S^a) + \operatorname{coind}(S^c) + 1,$$
which for spheres reads $a + c + 1 = a + c + 1$. The "plus one" is the new shared
dimension created when two spheres are joined. This is the sharp, exact instance of a
famous general inequality, $\operatorname{coind}(X * Y) \ge \operatorname{coind}(X) +
\operatorname{coind}(Y) + 1$, which governs symmetric spaces throughout topology.

**Symmetric maps multiply under join.** Because a joined map remembers each of its two
factors—read off the low block to recover the first, the high block to recover the
second—distinct pairs of maps give distinct joins. So the *number* of symmetric maps is
supermultiplicative under join:
$$\#\{S^a \to S^b\} \cdot \#\{S^c \to S^d\} \ \le\ \#\{S^{a+c+1} \to S^{b+d+1}\}.$$
And we can count these numbers outright. A symmetric map $S^m \to S^n$ is an injection
of $m+1$ axes into $n+1$ slots (there are $\tfrac{(n+1)!}{(n-m)!}$ of them when
$m \le n$, and none otherwise) together with an independent sign on each of the $m+1$
source axes ($2^{m+1}$ choices). So there are exactly
$$\frac{(n+1)!}{(n-m)!}\cdot 2^{\,m+1}$$
symmetric maps $S^m \to S^n$ when $m \le n$. The rigidity of Borsuk–Ulam becomes a
tidy formula you can evaluate on a calculator.

## Why the austere model is honest

It is fair to ask whether this stripped-down world of axes and signs really captures
the topology, or whether it has quietly assumed away the hard part. It has not. The
local rule "distinct axes go to distinct axes" is genuinely equivalent to the global
"faces go to faces" for cross-polytopes—no information is lost. The lower bounds are
*constructed*, not postulated: the suspension and join are actual maps you can write
down, not existence claims pulled from the air. And the obstructions—no
$S^{n+1} \to S^n$—are real Borsuk–Ulam phenomena, honest pigeonhole facts about fitting
axes into slots, not vacuous technicalities. Every theorem here is a statement with
content, and every construction is something you could hand to a student to check.

## Where the real drama begins

For spheres, the story is exact and complete: the coindex equals the dimension, the
suspension increment is one, and the join is additive. But spheres are the *rigid* case.
A second invariant lurks in the background—the **index**, the smallest sphere you can
symmetrically map a space *out* onto. For spheres the index and coindex coincide, which
is exactly why everything is so clean. The moment you leave the world of spheres and
consider general spaces with a free antipodal symmetry, the two invariants can pull
apart, and their difference—the **excess**—becomes a subtle new quantity to measure.

The tools built here—suspension, join, and the dictionary between symmetric maps and
axis-injections—are exactly the instruments needed to explore that gap. When does the
join inequality become *strict*? Can we engineer spaces whose excess grows by any
amount we choose? Does suspension preserve the excess while join adds it? These are the
open frontiers, and the coordinate-injection picture gives us a concrete, countable
way to attack them.

What began as a puzzle about temperatures on opposite sides of the Earth has become a
combinatorial machine—one where the deepest rigidity in symmetric topology is just the
humble impossibility of pouring more axes into fewer slots.
