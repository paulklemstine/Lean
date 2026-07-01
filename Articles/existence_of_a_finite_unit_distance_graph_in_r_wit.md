# The One-Quarter Frontier: How a Single Fraction Governs the Colours of the Plane

## A game of dots and distances

Imagine scattering a handful of dots on an infinite sheet of paper. Now connect
two dots with a line whenever they sit *exactly* one inch apart. What you have
built is called a **unit-distance graph**: the dots are its vertices, and the
"exactly one inch" pairs are its edges. These innocent-looking pictures hide one
of the most stubborn open problems in all of mathematics.

The problem is this. Suppose you want to colour *every* point of the plane so
that no two points one inch apart ever receive the same colour. How many colours
do you need? This is the famous **Hadwiger–Nelson problem**, first asked in
1950. For nearly seventy years the answer was pinned only to the range "somewhere
between $4$ and $7$." In 2018 the amateur mathematician Aubrey de Grey stunned
the community by building a finite unit-distance graph that needs *five* colours,
proving the true answer is at least $5$.

But there is a subtler cousin of this question — the **fractional** chromatic
number — where the frontier of knowledge sits at a beautiful, sharp threshold:
the fraction $1/4$. This article is about why that one fraction carries so much
weight, and about the clean piece of combinatorics that turns a geometric fact
into a colouring bound.

## Independent dots

Before colours, we need the idea of *independence*. In any graph, a set of
vertices is called **independent** if no two of them are joined by an edge. In
the world of unit-distance graphs, an independent set is a collection of dots no
two of which are exactly one inch apart. The **independence number** $\alpha(G)$
of a finite graph $G$ is the size of its largest independent set.

Now comes the quantity at the heart of our story. If $G$ has $n$ vertices, its
**independence ratio** is

$$ i(G) = \frac{\alpha(G)}{n}. $$

It measures the largest fraction of the dots you can select while avoiding every
"one-inch" pair. A large ratio means the graph is loosely connected and easy to
pick from; a small ratio means the edges are so pervasive that any large
selection is forced to include a forbidden pair.

Here is the simplest possible example. Take three points forming an equilateral
triangle with side length one inch. Every pair is exactly one inch apart, so all
three edges are present — this is the complete graph on three vertices, usually
written $K_3$. The largest independent set is a single point, because any two of
the three are joined. So the independence ratio of the unit equilateral triangle
is exactly

$$ i(K_3) = \frac{1}{3}. $$

That number, $1/3$, is comfortably larger than $1/4$. Keep it in mind: it is the
first data point in a search for graphs whose ratio dips *below* one quarter.

## From independence to colours: the pigeonhole engine

Why should a small independence ratio have anything to do with colours? The link
is one of the most reliable tools in combinatorics: the **pigeonhole
principle**.

Suppose you have properly coloured a graph $G$ with $k$ colours — "properly"
meaning no edge ever has both endpoints the same colour. Group the vertices by
colour. Each group is a set of vertices that share a colour, and since no edge
joins two same-coloured vertices, *every colour class is an independent set*.
Therefore no colour class can be larger than the independence number $\alpha(G)$.

If all $k$ colour classes together account for all $n$ vertices, and none exceeds
$\alpha(G)$ in size, then

$$ n \le k \cdot \alpha(G). $$

This is the whole engine, stated as a theorem.

> **Colour-class bound.** If a finite graph $G$ on $n$ vertices admits a proper
> colouring with $k$ colours, then $n \le k\,\alpha(G)$.

Rearranged, it says $k \ge n/\alpha(G) = 1/i(G)$: *the number of colours you
need is at least the reciprocal of the independence ratio.* A graph that is hard
to select independently is exactly a graph that is hard to colour.

Now watch the threshold appear. Suppose a finite graph has independence ratio
strictly below one quarter, $i(G) < 1/4$. Could it be coloured with just four
colours? If it could, the bound would give $n \le 4\,\alpha(G)$, i.e.
$\alpha(G)/n \ge 1/4$, contradicting $i(G) < 1/4$. So it cannot.

> **Four is not enough.** If a finite graph has independence ratio $i(G) < 1/4$,
> then it cannot be coloured with four colours, and its chromatic number
> satisfies $\chi(G) > 4$.

The magic number $1/4$ is nothing mysterious: it is simply the reciprocal of
$4$. The inequality $\alpha/n < 1/4$ is precisely the statement $n/\alpha > 4$.

## The bound is sharp

One might worry the "$1/4$" is loose — perhaps four-colourable graphs always
have a much larger independence ratio. They do not. Consider the complete graph
$K_k$, in which every pair of the $k$ vertices is joined by an edge. It can be
coloured with $k$ colours (give every vertex its own), and its largest
independent set is a single vertex, so its independence ratio is exactly $1/k$.

> **Sharpness.** For every $k \ge 1$, the complete graph $K_k$ is
> $k$-colourable and has independence ratio exactly $1/k$.

Taking $k = 4$, the graph $K_4$ is four-colourable with independence ratio
exactly $1/4$. The threshold is touched from above but not crossed: this is why
the frontier for "cannot be four-coloured" sits precisely at ratios *below*
$1/4$, not at or below.

## The fractional twist

The story becomes richer when we allow colours to be shared *fractionally*.
Instead of assigning one colour to each vertex, imagine handing out
**weights** — nonnegative numbers — to the independent sets of the graph, with
the rule that the weights covering any single vertex must add up to at least $1$.
Think of each independent set as a "colour" that you are allowed to use in
partial amounts. The **value** of such a scheme is the total weight handed out,
and the smallest achievable value is the **fractional chromatic number**
$\chi_f(G)$.

An ordinary $k$-colouring is the special case where you place a full weight of
$1$ on each of $k$ colour classes; its value is $k$. Because fractional schemes
are more flexible, $\chi_f(G)$ is always at most the ordinary chromatic number,
and it can be strictly smaller. It is the "relaxed" version of colouring, and it
is exactly the version where the $1/4$ threshold speaks most cleanly.

The same double-counting that powered the pigeonhole engine now gives a *lower*
bound on every fractional scheme. Sum, over all vertices, the total weight
covering that vertex; the covering rule forces this grand total to be at least
$n$. But the same sum can be reorganised by independent set: each set $s$ of
weight $w(s)$ contributes $w(s)\cdot|s|$, and since $s$ is independent, $|s| \le
\alpha(G)$. Hence

$$ n \;\le\; \sum_v (\text{weight covering } v) \;=\; \sum_s w(s)\,|s| \;\le\; \alpha(G)\sum_s w(s) \;=\; \alpha(G)\cdot\text{value}. $$

Dividing gives the linear-programming lower bound.

> **Fractional lower bound.** Every fractional colouring of a finite graph $G$
> on $n$ vertices has value at least $n/\alpha(G)$. Consequently
> $\chi_f(G) \ge n/\alpha(G) = 1/i(G)$.

And now the fractional threshold follows verbatim: if $i(G) < 1/4$ then *every*
fractional colouring has value strictly greater than $4$.

> **The fractional frontier.** If a finite graph has independence ratio
> $i(G) < 1/4$, then its fractional chromatic number satisfies $\chi_f(G) > 4$.

This is strictly stronger than the ordinary statement, because the fractional
chromatic number is the smaller, more delicate quantity. It is also exactly the
quantity that matters for the plane.

## Why the plane cares

Return to the infinite sheet of paper. The fractional chromatic number of the
plane, written $\chi_f(\mathbb{R}^2)$, is the fractional colouring cost of the
entire Euclidean plane under the "one inch apart forbids same colour" rule. It
has long been conjectured to be exactly $4$ — and a matching family of
conjectures predicted that no finite unit-distance graph could ever dip below
independence ratio $1/4$.

The reduction above is the lever that connects the two. A single **finite**
unit-distance graph living inside the plane, if it has independence ratio below
$1/4$, immediately forces $\chi_f(\mathbb{R}^2) > 4$, because any fractional
colouring of the whole plane restricts to a fractional colouring of the finite
gadget, and the gadget already costs more than $4$. One finite picture, correctly
built, overturns a conjecture about the infinite plane.

The threshold is razor-sharp in a very precise sense: $1/4$ is exactly the
reciprocal of the conjectured value $\chi_f(\mathbb{R}^2) = 4$. A ratio of
exactly $1/4$ is consistent with the conjecture; anything strictly below breaks
it. This is why the number $1/4$ — not $1/3$, not $1/5$ — is the frontier.

## The amplifier

There is one last twist that makes the ratio so valuable to optimise. The map
"ratio $\mapsto$ colour bound" is the reciprocal $x \mapsto 1/x$, and the
reciprocal is a magnifier near small values. If someone builds a finite planar
gadget with independence ratio at most $1/4 - \varepsilon$ for some fixed
$\varepsilon > 0$, the reciprocal bound gives

$$ \chi_f(\mathbb{R}^2) \;\ge\; \frac{1}{\,1/4 - \varepsilon\,} \;=\; 4 + \frac{4\varepsilon}{1 - 4\varepsilon}. $$

A tiny additive improvement in the ratio produces a strictly larger additive gain
in the lower bound for the plane. Every fraction shaved off the independence
ratio is amplified into progress on a seventy-year-old problem. That is why, in
this corner of geometry, the independence ratio is the single most valuable
number to push downward — and why the humble fraction $1/4$ stands as the
gateway between "the plane needs four colours" and "the plane needs more."

## The shape of the argument

Step back and admire how little machinery this required. Two counting arguments —
one integral, one fractional — each a single pass of the pigeonhole principle,
convert a statement about *selecting dots* into a statement about *colouring
them*. The equilateral triangle anchors the scale at $1/3$; the complete graph
$K_4$ shows the threshold at $1/4$ is exactly sharp; and the reciprocal map turns
every geometric gadget below that threshold into a quantitative theorem about the
plane. The deep difficulty of the Hadwiger–Nelson world lives entirely in
*constructing* the geometric witness. Once such a witness exists, the bridge from
its shape to the colouring of the plane is short, sturdy, and — as this story
shows — built from nothing more than careful counting.
