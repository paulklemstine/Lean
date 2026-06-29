# The Tallest Staircase: How Far Can a Gentle Landscape Rise?

Imagine you are standing at the corner of a vast checkerboard city, laid out as a
perfectly regular grid of blocks. The city has $m$ rows running north and $n$
columns running east. To each intersection you assign a height — the elevation of
a hill, the floor number of a building, the water level of a flooded street. There
is only one rule, and it is a rule about *gentleness*: as you step from one
intersection to an adjacent one, the height may change by at most one unit. No
cliffs, no sudden drops. Just a smooth, walkable terrain.

There is also one fixed reference point. The southwest corner of the city, the
intersection at coordinates $(0,0)$, is set to sea level: its height is exactly
zero.

Now the question. If you add up the absolute heights of *every* intersection in
the city — the total "mass" of elevation packed into your gentle landscape — how
high can that total possibly be? What is the tallest, heaviest terrain the rules
allow?

This is a deceptively simple puzzle, and it has a beautiful, exact answer. The
total mass can never exceed

$$n\cdot\frac{m(m-1)}{2} + m\cdot\frac{n(n-1)}{2},$$

and this maximum is achieved by one wonderfully natural shape: a staircase that
climbs steadily away from the corner.

## The rules, made precise

Let us name things carefully. A *height function* is an assignment $f(i,j)$ of an
integer height to each intersection $(i,j)$, where $i$ ranges over the rows
$0,1,\dots,m-1$ and $j$ ranges over the columns $0,1,\dots,n-1$. The two rules are:

1. **Anchored at the origin:** $f(0,0) = 0$.
2. **Gentle (1-Lipschitz on grid edges):** for any two intersections joined by a
   single grid edge — that is, horizontally or vertically adjacent — the heights
   differ by at most one: $|f(p) - f(q)| \le 1$.

The quantity we care about is the **total absolute mass**,

$$\text{mass}(f) = \sum_{i=0}^{m-1}\sum_{j=0}^{n-1} |f(i,j)|.$$

We want the largest possible value of this sum over all gentle, anchored height
functions. The answer, our **main theorem**, is that

$$\text{mass}(f) \;\le\; n\cdot\frac{m(m-1)}{2} + m\cdot\frac{n(n-1)}{2},$$

with equality achieved. That right-hand side is just two *triangular numbers* in
disguise — the famous sums $1 + 2 + \cdots + (m-1) = m(m-1)/2$ that the young Gauss
reputedly added up in seconds.

## Why distance is the secret

The heart of the argument is a single, intuitive observation: **a gentle terrain
can never rise faster than your feet can carry you.**

Start at the corner, where the height is zero. To reach the intersection $(i,j)$,
you must take at least $i$ steps north and $j$ steps east — a total of $i + j$
steps. Each step changes the height by at most one. So by the time you arrive, the
height can have moved away from zero by at most $i + j$ units. In symbols, for
every intersection,

$$|f(i,j)| \le i + j.$$

This is the whole game. The right-hand side $i+j$ is precisely the *grid distance*
from the corner — the number of city blocks you must walk, with no diagonal
shortcuts allowed. The inequality says the absolute height at any point is bounded
by how far that point sits from the anchored corner.

The proof of this "distance bound" is a tidy two-step walk. First you stroll east
along the bottom row: at $(0,0)$ the height is $0$; each eastward step changes it
by at most $1$, so $|f(i,0)| \le i$. Then, from any point on the bottom row, you
climb straight north: each northward step again changes the height by at most $1$,
adding at most $j$ more, so $|f(i,j)| \le i + j$. It is the triangle inequality,
applied one edge at a time along an L-shaped path. Mathematicians call this kind of
step-by-step accumulation *telescoping*, because the intermediate terms cancel like
the segments of a collapsing telescope.

A striking feature emerges here. The bound holds *simultaneously in every single
cell*. We are not balancing a surplus in one place against a deficit in another;
each intersection independently obeys $|f(i,j)| \le i+j$. That means the total mass
is bounded simply by adding up the local bounds:

$$\text{mass}(f) = \sum_{i,j} |f(i,j)| \;\le\; \sum_{i,j} (i+j).$$

## Adding up the staircase

Now we just have to compute that last sum — the total grid distance of every
intersection from the corner. This is pure bookkeeping, but it lands exactly on
our magic number.

Split $i+j$ into its two pieces. Summing the $i$ part over all $n$ columns and all
rows gives $n$ copies of $0+1+\cdots+(m-1) = m(m-1)/2$. Summing the $j$ part over
all $m$ rows and all columns gives $m$ copies of $0+1+\cdots+(n-1) = n(n-1)/2$.
Together,

$$\sum_{i=0}^{m-1}\sum_{j=0}^{n-1} (i+j) = n\cdot\frac{m(m-1)}{2} + m\cdot\frac{n(n-1)}{2}.$$

That is our bound, derived from nothing but the gentleness rule and the geometry of
the grid.

## The terrain that touches the ceiling

A bound is only half a story. Is it the *best* possible bound, or could the true
maximum be smaller? To prove an inequality is sharp, you must exhibit a terrain
that actually reaches it.

Meet the **diagonal staircase**:

$$f(i,j) = i + j.$$

It assigns to each intersection exactly its grid distance from the corner. Check
the rules: at the corner, $f(0,0) = 0$, so it is anchored. Stepping north or east
changes $i + j$ by exactly one, so it is perfectly gentle — every edge difference is
$\pm 1$, never more. It is a legal terrain.

And because every height is non-negative, $|f(i,j)| = i + j$ in every cell. The
distance bound is met with equality everywhere at once, so the total mass equals
$\sum_{i,j}(i+j)$ — precisely the magic number. The staircase doesn't just approach
the ceiling; it presses flat against it.

There is a mirror-image champion, too. The **reflected staircase**
$f(i,j) = -(i+j)$ descends into a valley instead of climbing a hill. It is equally
legal and, since absolute values ignore the sign, it carries exactly the same total
mass. So the extremal landscape comes in two flavors: a hill and its perfect
reflection.

## A concrete city

Let's make it tangible with a small example: a $3 \times 3$ grid, so $m = n = 3$.

The staircase heights are:

$$
\begin{array}{ccc}
2 & 3 & 4 \\
1 & 2 & 3 \\
0 & 1 & 2
\end{array}
$$

(reading the bottom-left corner as $(0,0) = 0$). Add them up: the total is $18$.
Now check the formula:

$$3\cdot\frac{3\cdot 2}{2} + 3\cdot\frac{3\cdot 2}{2} = 3\cdot 3 + 3\cdot 3 = 18.$$

They match exactly. No gentle, corner-anchored terrain on a $3\times 3$ grid can
carry more than $18$ units of total elevation, and the staircase carries precisely
that.

## Why the anchor cannot be removed

It is worth pausing on the role of that one fixed reference point at the corner.
Without it, the whole question collapses into nonsense.

Consider the laziest possible terrain: the **constant** height function, where
every intersection sits at the same elevation $C$. It is impeccably gentle —
neighboring heights differ by *zero*, comfortably under the limit. But its total
mass is

$$\sum_{i,j} |C| = m\cdot n \cdot |C|,$$

and by cranking $C$ up to a billion we can make that total as large as we please.
With no anchor, there is no bound at all; the mass runs off to infinity.

This is not a flaw in the theorem — it is the theorem telling us something true.
The anchoring condition $f(0,0) = 0$ is *load-bearing*: it is exactly the
ingredient that converts an unbounded free-floating problem into a sharp, finite
estimate. Pin one corner to sea level, and the gentleness rule does the rest,
forcing the entire landscape to live within a precisely measured envelope.

## From toy grids to folded paper

Why would anyone care how high a gentle grid can rise? The answer comes from an
unexpected place: the mathematics of *folding paper*.

A celebrated origami pattern called the **Miura-ori** — used to pack solar panels
for spacecraft and to fold maps that open with a single tug — can be described,
remarkably, by exactly this kind of integer height function on a grid. Each valid
flat-folded state corresponds to a gentle, anchored terrain, and you can transform
one folding into another by a sequence of small local moves called *flips*. A
natural question is: how many flips does it take, in the worst case, to get from any
folding to any other? This worst-case count is the *diameter* of the
"flip graph."

Here is the bridge. The number of flips separating two foldings is governed by how
much their height functions differ — measured by total absolute difference, exactly
the mass we have been studying. Our sharp bound says the mass can climb as high as
$n\,m(m-1)/2 + m\,n(n-1)/2$, on the order of $m^2 n + m n^2$, and the explicit
staircase shows that this height is genuinely reachable. That construction supplies
a concrete *lower bound* on the flip-graph diameter: there really are foldings far
apart in flip distance. And because the same mass quantity also *caps* how far
apart any two foldings can be, the staircase bound is precisely the estimate needed
to squeeze the diameter from both sides — turning a one-sided construction into a
matching two-sided answer.

So a puzzle about how high a gentle checkerboard can rise turns out to measure how
tangled a folded sheet of paper can get. The tallest staircase and the most twisted
origami are, in the end, the same extremal object.

## The shape of the idea

Strip away the scenery and the argument is astonishingly compact. One geometric
truth — *a gentle climb cannot outrun your steps*, $|f(i,j)| \le i+j$ — proved by
walking an L-shaped path from the corner. One Gauss-style summation that turns the
local bounds into the global ceiling. One explicit staircase that touches that
ceiling, plus its reflection. And one cautionary constant terrain that shows why
the corner must be anchored.

That is the entire story: a sharp inequality, both its directions, and the precise
boundary of its truth. It is the kind of result that feels, once seen, like it
could not have been otherwise — the mathematics of gentleness, measured to the last
unit.
