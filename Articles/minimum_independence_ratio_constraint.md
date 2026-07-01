# A Quarter of the Plane: When Distance Forbids Crowds

## A game played with points

Imagine scattering a handful of dots on a sheet of paper. Now play a game: you
want to select as many of these dots as possible, but with one rule — no two of
your chosen dots may be *exactly* one inch apart. Dots that are closer are fine.
Dots that are farther are fine. Only the precise distance of one inch is
forbidden between any pair you keep.

How large a selection can you always guarantee? If an adversary hands you the
nastiest possible arrangement of $n$ dots, engineered to make your life hard, how
big a "conflict-free" collection can you still carve out?

This deceptively playful puzzle sits at the crossroads of geometry, combinatorics,
and one of the most famous open problems in mathematics — the coloring of the
plane. The central quantity is called the **independence ratio**: the fraction of
the dots you can keep. This article tells the story of a clean, sharp lower bound
on that ratio, and why the magic number turns out to be **one quarter**.

## The language of unit distances

Let us make the game precise. Take a finite set of points in the plane. Draw a
line — an *edge* — between two points whenever they are exactly one unit apart.
The resulting object is a **unit-distance graph**: its vertices are the points,
its edges join the pairs at the forbidden distance.

An **independent set** is a collection of points with no edges among them — no two
at unit distance. Its size, at its largest, is the **independence number**
$\alpha(G)$. The **independence ratio** of a configuration on $n$ points is simply

$$i(G) = \frac{\alpha(G)}{n},$$

the fraction of the whole you can safely keep. A large ratio means the geometry is
forgiving; a small ratio means unit distances are so densely woven through the
configuration that every large subset is forced to contain a forbidden pair.

The question that drives everything: **how small can $i(G)$ be?** Can an adversary
drive the ratio arbitrarily close to zero, or is there a floor beneath which no
finite configuration can sink?

## Coloring: the hidden partner

The secret to the floor is a classical idea from graph theory: **coloring**.
Assign a color to every point so that no two points at unit distance share a color.
The smallest number of colors that suffices is the **chromatic number** $\chi(G)$.

Coloring and independence are two sides of one coin. If you can color the points
with $k$ colors, then each color class is, by definition, an independent set — no
two of its members are a unit apart. And the $k$ color classes together account for
all $n$ points. So the largest color class must contain at least $n/k$ points,
which means

$$\alpha(G) \;\ge\; \frac{n}{k}, \qquad\text{equivalently}\qquad i(G) \;\ge\; \frac{1}{k}.$$

This is the pigeonhole principle in its purest dress: if you sort $n$ objects into
$k$ boxes, some box holds at least $n/k$ of them. Rearranged, the same inequality
reads $n \le k \cdot \alpha(G)$. This single identity is the hinge of the entire
theory. It says the independence ratio can never fall below the reciprocal of the
number of colors you need:

$$\boxed{\;i(G) \;\ge\; \frac{1}{\chi(G)}.\;}$$

The independence ratio is the *reciprocal shadow* of the chromatic number.

## The greedy engine

The reciprocal bound is only as useful as our control over $\chi(G)$. Here a
wonderfully simple algorithm delivers. Suppose no point in the configuration has
more than $\Delta$ others at unit distance — that is, the **maximum degree** of the
graph is $\Delta$. Then we can color the whole thing with at most $\Delta + 1$
colors, and we can do it *constructively*.

Process the points one at a time in any order. When you reach a point, look at the
neighbors already colored. There are at most $\Delta$ of them, so they use at most
$\Delta$ colors. With a palette of $\Delta + 1$ colors on hand, at least one color
is always free — assign it. Move on. At the end, no two adjacent points share a
color, because whenever two points are joined by an edge, the later of the two was
colored *after* seeing the earlier one, and deliberately avoided its color.

This yields the **greedy coloring bound**:

$$\chi(G) \;\le\; \Delta(G) + 1.$$

Combined with the reciprocal shadow, we get a floor governed entirely by *local*
crowding:

$$i(G) \;\ge\; \frac{1}{\Delta(G) + 1}.$$

If no point is too popular, no adversary can make the independence ratio too small.

## The quarter emerges

Now specialize to the plane. A remarkable rigidity of Euclidean geometry enters:
in the plane, you cannot place four points so that all six pairwise distances equal
one. There is no unit-distance $K_4$ — no equilateral "tetrahedron" fits flat on a
page. Unit-distance graphs in the plane are therefore locally sparse in a strong
sense.

Consider the natural regime where each point has at most three unit-distance
neighbors, so $\Delta \le 3$. The greedy engine colors the configuration with at
most four colors, and the reciprocal shadow immediately gives

$$i(G) \;\ge\; \frac{1}{4}.$$

**A quarter of the points can always be kept.** No matter how the adversary
arranges points in the plane, as long as no single point sits at unit distance from
more than three others, you are guaranteed a conflict-free selection comprising at
least a quarter of the whole. More generally, *any* four-colorable configuration —
in the plane or beyond — obeys the same quarter floor. This is the **Minimum
Independence Ratio Constraint**: the ratio of a four-colorable configuration cannot
fall below $1/4$, and any purported example claiming a smaller ratio must therefore
require five or more colors.

## Is the bound sharp?

A lower bound is only satisfying if it cannot be improved for free. The reciprocal
shadow is sharp — and beautifully so. Take three points forming an equilateral
triangle of side one. Every pair is at unit distance, so it is a triangle in the
graph sense, $K_3$. Its chromatic number is $3$, its independence number is $1$
(any two of the three vertices conflict), and its independence ratio is exactly

$$i(K_3) = \frac{1}{3} = \frac{1}{\chi(K_3)}.$$

The inequality $i(G) \ge 1/\chi(G)$ is met with equality. In general, equality holds
precisely for *balanced complete multipartite graphs*, where the point set splits
into equal-sized independent blocks with every cross-pair conflicting. These are the
worst cases — the configurations that squeeze the ratio down to its reciprocal floor
and no lower.

## The frontier: the true color of the plane

The quarter floor for degree-three configurations is a theorem. But it points
toward one of the great open questions of combinatorial geometry. If you allow
arbitrarily many unit-distance neighbors, how small can the independence ratio of a
planar configuration become? Equivalently — through the reciprocal dictionary — how
many colors does the entire plane require?

This is the celebrated **Hadwiger–Nelson problem**: color every point of the plane
so that no two points a unit apart share a color. For decades the number of
necessary colors was known to lie between four and seven. In 2018 an amateur
mathematician, Aubrey de Grey, stunned the field by exhibiting a finite
configuration needing five colors, lifting the lower bound. The upper bound of
seven, from a clever hexagonal tiling, still stands. The plane's chromatic number
is five, six, or seven — nobody yet knows which.

The independence-ratio picture mirrors this drama. The record-holding "hard"
configurations sit tantalizingly above a quarter but refuse to reach it. The
**Moser spindle**, a rigid seven-point gadget, has independence number two and
therefore ratio $2/7 \approx 0.286$. The **Golomb graph**, ten points built around a
central triangle, has independence number three and ratio $3/10 = 0.3$. Both hover
above $1/4$, and every known trick to push the ratio lower stalls out before
reaching the floor.

This suggests two bold conjectures. First, that a quarter is *universal*: **every**
finite planar configuration, no matter how densely it is stitched with unit
distances, keeps an independent quarter. This is the reciprocal image of the belief
that the plane's *fractional* chromatic number — a linear-programming relaxation of
coloring — sits at or below four. Second, that a quarter is never actually
*attained* by any finite configuration: the value $1/4$ is an infimum approached
only in the limit, a horizon the finite world can see but never touch. Attaining it
exactly would demand a perfect four-way partition into maximum independent sets,
a rigidity the missing unit-distance $K_4$ seems to forbid at finite size.

## Why it matters

Beneath the recreational surface, this circle of ideas is a working model of how
*local* constraints propagate to *global* structure. The rule "no two chosen points
one unit apart" is entirely local — it speaks only of pairs. Yet it forces a global
guarantee: a fixed fraction of any configuration can always be salvaged. The bridge
is coloring, and the currency of exchange is a single pigeonhole inequality,
$n \le \chi(G)\cdot\alpha(G)$, read forward to bound colors and backward to bound
independence.

Constraints of exactly this shape appear far beyond dots on paper. In wireless
networks, transmitters that are too close interfere, and one seeks the largest set
that can broadcast simultaneously — an independence problem. In scheduling, tasks
that conflict cannot share a slot, and the minimum number of slots is a chromatic
number. In statistical physics, hard-sphere models forbid particles from occupying
overlapping positions. In every case the same duality holds: the fraction you can
keep is the reciprocal shadow of the number of classes you need.

The story of the quarter is, at heart, the story of that duality made sharp. A
simple game with dots and a forbidden distance leads to a clean theorem — a quarter
is always safe when crowding is bounded — and opens onto a frontier where the true
color of the plane still waits to be discovered.
