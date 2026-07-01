# One Quarter, and the Ghost of a Fifth Color

## A dot-connecting puzzle hidden in the plane

Imagine scattering a handful of points across a sheet of paper. Now draw a line
between any two of them that happen to sit *exactly one unit apart* — say, one
centimeter. Nothing more, nothing less. Points a hair too close or a hair too
far are left unconnected. What you have built is a **unit-distance graph**: a
picture whose edges are dictated not by whim but by the rigid geometry of the
ruler.

These graphs are deceptively simple to describe and famously hard to understand.
They sit at the crossroads of geometry, combinatorics, and computation, and they
are the setting for one of the most stubborn open problems in mathematics: the
**Hadwiger–Nelson problem**, which asks how many colors you need to paint the
entire plane so that no two points one unit apart share a color.

This article is about a close cousin of that question. Instead of asking how many
colors we need, we ask: *how large a "peaceful" subset can we always find?* A
peaceful subset — mathematicians call it an **independent set** — is a collection
of points, no two of which are one unit apart. Think of it as a way of choosing
seats so that no two chosen people are exactly an arm's length away from each
other. If a graph has $n$ points and its largest peaceful subset has $\alpha$
points, the ratio $\alpha / n$ is called the **independence ratio**. It is a
number between $0$ and $1$ that measures how much "elbow room" the graph offers.

The folklore hope, repeated in many corners, was that this ratio can never drop
below **one quarter** for a unit-distance graph in the plane. In other words, no
matter how cleverly you place your dots, you can always find a peaceful subset
containing at least a quarter of them. It is a clean, memorable, attractive
claim. This article tells the story of what is actually true here — a sharp,
fully rigorous theorem that *does* hold — and where the seductive "one quarter"
slogan quietly turns from theorem into conjecture.

## The engine: colors buy you independence

Here is the beautiful mechanism at the heart of everything. Suppose you can
paint the points of a graph with $k$ colors so that **no edge connects two points
of the same color**. This is called a proper $k$-coloring, and each color forms,
by construction, a peaceful set: same-colored points are never adjacent.

Now count. If there are $n$ points and only $k$ colors, then by the pigeonhole
principle *some* color must be used on at least $n/k$ of them. That color class is
a peaceful subset of size at least $n/k$. Divide by $n$ and you get:

$$\frac{\alpha}{n} \geq \frac{1}{k}.$$

That is the whole idea, and it is airtight. We can state it as a theorem.

> **The Coloring–Independence Bound.** If a finite graph on $n$ vertices can be
> properly colored with $k$ colors (with $k \geq 1$), then it contains an
> independent set $S$ satisfying $n \leq k \cdot |S|$. Equivalently, its
> independence ratio is at least $1/k$.

The proof is exactly the pigeonhole count above: the $n$ vertices are partitioned
into $k$ color classes, so the sum of their sizes is $n$, so the largest is at
least the average $n/k$, and every color class is independent because the
coloring is proper. $\blacksquare$

Specialize to four colors and out pops the headline:

> **The Quarter Bound for Four-Colorable Graphs.** Every four-colorable finite
> graph — in particular, every four-colorable unit-distance graph in the plane —
> has independence ratio at least $1/4$.

This is a genuine, unconditional theorem. Whenever your dot pattern can be
four-colored, a quarter of the dots can always be chosen peacefully.

## The catch: is every unit-distance graph four-colorable?

Here is where the story turns. The quarter bound is only as good as the promise
of a four-coloring. For decades it was plausible to imagine that four colors
always suffice for unit-distance graphs in the plane — the number four has a
gravitational pull in planar mathematics, thanks to the celebrated Four Color
Theorem for maps.

But unit-distance graphs are *not* maps. Their edges cross; they are not planar
in the topological sense. And in 2018, in a result that stunned the community,
Aubrey de Grey exhibited an explicit finite set of points in the plane whose
unit-distance graph **cannot be colored with four colors** — it needs five. The
chromatic number of the plane is at least five.

That single construction pulls the rug out from under any hope of proving the
unconditional quarter bound *by coloring*. If some finite planar configuration
genuinely requires five colors, then the coloring engine can only promise a fifth
of its dots, not a quarter. And indeed, the best rigorously known lower bounds
for the independence ratio of the plane sit *below* one quarter, hovering closer
to $0.229$.

So the honest picture is this: **the quarter bound is a theorem for the class of
four-colorable graphs, and it is a conjecture — not a theorem — for the class of
all planar unit-distance graphs.** The distinction matters. It is the difference
between a proof and a hope, and recognizing exactly where one ends and the other
begins is itself a mathematical result.

## The bound is sharp — meet the complete graphs

A skeptic might wonder whether the $1/k$ bound is wasteful. Could the true ratio
always be much larger, making the bound a mere formality? No. The bound is
**exactly tight**, and the witnesses are the friendliest graphs imaginable.

Take the **complete graph** $K_k$: $k$ points, every pair joined by an edge.
Because every pair is adjacent, no two points can sit together in a peaceful
subset — the largest independent set has exactly one point. So its independence
ratio is precisely $1/k$. The complete graph doesn't just satisfy the bound; it
meets it with no room to spare.

> **Tightness.** The complete graph $K_k$ is $k$-colorable and has independence
> ratio exactly $1/k$. Hence the Coloring–Independence Bound cannot be improved
> in general.

## A concrete planet in this abstract sky: the triangle

Abstract bounds are more convincing when you can point to a real, physical
example. So place three dots at the corners of an **equilateral triangle** with
side length one: at $(0,0)$, at $(1,0)$, and at $\left(\tfrac12, \tfrac{\sqrt
3}{2}\right)$. A direct computation with the distance formula confirms all three
pairwise distances equal exactly one — the third coordinate $\tfrac{\sqrt3}{2}$ is
chosen precisely so the radicand collapses to $1$.

Every pair of corners is one unit apart, so the unit-distance graph of the
triangle *is* the complete graph $K_3$. It is three-colorable (color each corner
differently), and therefore certainly four-colorable, so the quarter bound
applies: it guarantees a peaceful subset of at least $1/4$ of the three vertices.

But we can do better and compute the exact ratio. Since all three pairs are
adjacent, any peaceful subset has at most one point; and a single corner is
trivially peaceful. So the largest independent set has exactly one vertex, and:

> **The Triangle's Ratio.** The unit-distance graph of a unit equilateral
> triangle has independence ratio exactly $1/3$.

One third is comfortably larger than one quarter. The smallest non-trivial planar
unit-distance graph clears the threshold with room to spare — a tidy, tangible
confirmation that the abstract engine is not vacuous but describes real geometry.

## Why this matters beyond the puzzle

The independence ratio is not an idle curiosity. Independent sets are the
mathematical skeleton of **conflict-free scheduling**: assign frequencies to
transmitters so that none too close interfere; seat guests so that no two rivals
are within earshot; pack sensors so that none jam their neighbors. In every case,
a lower bound on the independence ratio is a *guarantee* — a promise that a
certain fraction of your demands can always be met, no matter how adversarially
the constraints are arranged.

The coloring engine also reveals a deeper duality. Coloring is about *separation*
— slicing a graph into peaceful pieces. Independent sets are about *selection* —
choosing one peaceful piece. The pigeonhole argument is the hinge that turns one
into the other, and it does so with a precision that is provably impossible to
sharpen in general.

Finally, the de Grey twist is a lesson in mathematical humility. Intuition drawn
from the flat, well-behaved world of planar maps whispers "four." Geometry, with
its edges free to cross, answers "at least five." The gap between those two
numbers is exactly the gap between the theorem we can prove and the conjecture we
can only chase. Knowing precisely where that boundary lies — that a quarter is
guaranteed when four colors suffice, that four colors do *not* always suffice, and
that the true planar constant likely sits just below a quarter — is what turns a
catchy slogan into real mathematics.

## The road ahead

Three questions light the way forward. First, what is the *true* infimum of the
independence ratio over all finite planar unit-distance graphs? The evidence
points to a single constant strictly between $0.22$ and $0.26$, and probably
strictly below one quarter — a number that can only be pinned down by packing and
density arguments, not by coloring. Second, when is the $1/k$ bound actually
achieved by a *planar* graph? The triangle attains $1/3$, but complete graphs
larger than three points cannot be drawn with unit distances, so geometry forces
every larger planar witness strictly into the interior of the allowed region.
Third, in the sparse regime — few edges relative to vertices — a different
mechanism, degree averaging, takes over and can beat the coloring bound entirely.

The one-quarter slogan, it turns out, was never quite a theorem. But nested
inside it is a theorem that is clean, sharp, and true — and a beautiful geometric
example to anchor it. Sometimes the most valuable thing a proof can do is show you
exactly where your intuition was bluffing.
