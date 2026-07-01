# Four Colors Are Not Enough: A Tiny Graph That Tips the Balance

## A coloring puzzle that refuses to die

Imagine you are handed the infinite flat plane and a single, deceptively
simple instruction: color every point so that any two points *exactly one
unit apart* receive different colors. How many colors do you need?

This is the **Hadwiger–Nelson problem**, one of the most stubborn questions
in combinatorial geometry. It was posed in 1950, and for nearly seventy
years the answer was pinned only to the range "somewhere between $4$ and
$7$." Seven colors always suffice (a clever hexagonal tiling proves it),
and it was easy to show you need at least $4$. There the story stalled for
decades.

Then, in 2018, an amateur mathematician named Aubrey de Grey stunned the
field by exhibiting a finite constellation of points in the plane — a
so-called **unit-distance graph** — that cannot be colored with only $4$
colors. The chromatic number of the plane was at last known to be at least
$5$.

This article is about a quieter but equally sharp companion question. Not
"how many colors do you need to color every point exactly once," but a more
elastic, *fractional* version of the same puzzle — and a remarkably small
graph, just **29 points**, that settles it.

## Fractional coloring: sharing the colors

Ordinary coloring is rigid: each point gets exactly one color from a palette.
**Fractional coloring** relaxes this. Instead of assigning a single color, we
assign each point a *portion* of many colors, as long as the total portion
adds up to a full unit — and as long as points that must differ never share
any portion of the same color.

There is a beautifully clean way to formalize this. A color class in an
honest coloring is always an **independent set**: a collection of points, no
two of which are one unit apart. In the fractional world we hand out
nonnegative *weights* to independent sets, subject to one rule:

> Every point must be covered with total weight at least $1$ by the
> independent sets containing it.

The **cost** of such a scheme is the sum of all the weights, and the
**geometric fractional chromatic number** $\chi_f(G)$ of a graph $G$ is the
smallest achievable cost:
$$
\chi_f(G) \;=\; \inf\Big\{\textstyle\sum_S w(S) \;:\; w \ge 0,\ w
\text{ supported on independent sets},\ \sum_{S \ni v} w(S) \ge 1\ \forall v\Big\}.
$$

Fractional coloring is always at least as cheap as ordinary coloring, so
$\chi_f(G) \le \chi(G)$. That makes lower bounds on $\chi_f$ especially
powerful: if we can show the *fractional* number exceeds $4$, then so does
the ordinary one, and by extension the whole plane inherits the bound. The
fractional chromatic number of the plane is now known to exceed $4$ — and
the engine that drives this is astonishingly elementary.

## The one inequality that does all the work

Here is the heart of the matter, and it is nothing more than careful
counting. Suppose $G$ has $n$ vertices and its largest independent set has
size $\alpha(G)$ — this number is called the **independence number**. Then
for *any* valid fractional coloring with total weight $W$:
$$
n \;\le\; \alpha(G)\cdot W.
$$

Why? Count the incidences between vertices and weighted sets in two ways. On
one hand, every one of the $n$ vertices demands total covering weight at
least $1$, contributing at least $n$ in aggregate. On the other hand, each
weighted set $S$ contributes its weight $w(S)$ once per vertex it contains,
i.e. $|S|\cdot w(S)$ — and since only independent sets carry weight, every
such $S$ has $|S| \le \alpha(G)$. Summing, the total incidence is at most
$\alpha(G)\cdot W$. Comparing the two counts gives the inequality.

Rearranging, *every* fractional coloring costs at least $n/\alpha(G)$, so
$$
\chi_f(G) \;\ge\; \frac{n}{\alpha(G)}.
$$

This ratio $n/\alpha(G)$ is the **inverse independence ratio**. It is a lower
bound you get essentially for free, and it is the whole game. In particular:

> **If $4\,\alpha(G) < n$, then $\chi_f(G) > 4$.**

To beat $4$, you simply need a graph whose largest independent set is a
slightly-less-than-one-quarter slice of all its vertices.

## Twenty-nine points, independence number seven

Now the arithmetic becomes vivid. We want $4\,\alpha < n$. The cleanest way
to just barely cross the line is:
$$
\alpha = 7, \qquad n = 29, \qquad 4\cdot 7 = 28 < 29.
$$

Seven is more than a quarter of $28$ but *less* than a quarter of $29$. So a
$29$-vertex graph whose largest independent set has exactly $7$ points has
$$
\chi_f(G) \;\ge\; \frac{29}{7} \;=\; 4.142\ldots \;>\; 4.
$$

This is exactly the situation realized by a specific $29$-point unit-distance
configuration built by Matolcsi, Ruzsa, Varga, and Zsámboki. They start from
a $27$-point configuration with independence number $7$ — right at the
knife's edge, since $4\cdot 7 = 28 > 27$ and the bound $27/7 \approx 3.857$
is *below* $4$ — and then **augment it with two carefully chosen extra
points**. The two new points are placed so that they add no larger
independent set: the independence number stays fixed at $7$ while the vertex
count climbs from $27$ to $29$. That single step, from $27$ to $29$, flips
the inequality $4\alpha < n$ from false to true and pushes the fractional
chromatic number past $4$.

It is a wonderful illustration of a recurring theme in extremal geometry:
the decisive move is not a grand construction but a *surgical augmentation*,
two points that tip a delicate balance.

## A faithful miniature you can hold in your hand

The geometric configuration lives in the Euclidean plane with all its
unit-distance intricacy. But the *reason* it works is purely combinatorial:
$29$ vertices, independence number $7$. To make that reason crisp and
completely verifiable, one can build the smallest honest witness of the same
certificate — a graph that isn't the literal geometric object but shares its
essential arithmetic.

Take **seven disjoint cliques** (a clique is a set of mutually adjacent
vertices, so any independent set can contain at most one vertex from each).
Give them sizes summing to $29$ — for instance six cliques of size $4$ and
one of size $5$, since $6\cdot 4 + 5 = 29$. Any independent set picks at most
one vertex per clique, so its size is at most $7$; and picking exactly one
vertex from each clique achieves $7$. Hence
$$
n = 29, \qquad \alpha = 7,
$$
precisely the certificate of the geometric configuration. Feeding this into
the counting inequality yields $\chi_f > 4$ with total transparency. The
miniature captures the exact mechanism the geometry exploits, stripped to its
combinatorial skeleton.

## Why the ratio $1/4$ matters

The number $1/4$ is not arbitrary. It is the reciprocal of the target value
$4$ we are trying to exceed. The **independence ratio** $\alpha(G)/n$ measures
how large a "conflict-free" fraction of the vertices you can grab at once. A
ratio at or above $1/4$ keeps the fractional chromatic number at $4$ or
below; a ratio *strictly below* $1/4$ breaks through.

The $29$-vertex graph has independence ratio $7/29 \approx 0.2414$, a hair
under $0.25$. That hair's-breadth is exactly what separates "four colors, in
the generous fractional sense, suffice" from "they do not." Small margins,
big consequences.

It is worth pausing on how sharp the boundary is. Had the augmentation added
only *one* point instead of two, we would have $28$ vertices and independence
number $7$, giving $4\cdot 7 = 28 = 28$: a dead tie. The bound would read
$\chi_f \ge 28/7 = 4$ exactly, which does not clear the bar of *strictly*
exceeding $4$. It is the second point — the one that makes $29$ out of $28$ —
that converts an equality into a strict inequality. In this problem, a single
point is the difference between "just barely four" and "provably more than
four." The same phenomenon explains why $27$ points are not enough on their
own: there $4\cdot 7 = 28 > 27$, and the ratio $27/7 \approx 3.857$ sits below
the target entirely. The augmentation walks the configuration across the line
in two deliberate steps.

One can even sketch the whole landscape as a ladder. Fix the target value we
want to beat and ask for the smallest configuration that beats it with a given
independence number. For independence number $\alpha$, the smallest vertex
count that opens the strict gate is always $4\alpha + 1$: the first integer
larger than $4\alpha$. For $\alpha = 7$ that is $29$; for $\alpha = 8$ it is
$33$; for $\alpha = 9$ it is $37$. Each rung of this ladder corresponds to a
different independence ratio creeping up toward $1/4$ from below, and each
rung, if realized by a genuine planar unit-distance graph, would furnish an
independent certificate that four colors do not suffice.

## The bigger picture

Why should anyone outside pure mathematics care about coloring an infinite
plane? Coloring problems are the mathematical backbone of *conflict
avoidance*: scheduling exams so no student sits two at once, assigning radio
frequencies so nearby towers don't interfere, allocating registers in a
compiler so computations don't collide. Fractional coloring is the natural
model when resources can be *shared over time* — a frequency used part of the
day here, part of the day there. The independence-ratio bound is the sharpest
elementary tool for proving that a certain amount of sharing is genuinely
unavoidable.

And the Hadwiger–Nelson problem itself endures because it sits at the meeting
point of geometry, combinatorics, and logic, tantalizingly simple to state
and famously hard to close. Each small graph that nudges a bound upward — de
Grey's for the ordinary chromatic number, the $29$-vertex configuration for
the fractional one — is a hard-won piece of the puzzle. The most striking
lesson is how little machinery the fractional breakthrough requires: one
double-counting inequality, and a single pair of extra points that turn
$27$ into $29$.

## The takeaway

Strip away the scenery and the story is this. There is a single arithmetic
gate, $4\,\alpha(G) < n$, and once a graph passes through it, its fractional
chromatic number is forced above $4$. A $29$-point unit-distance
configuration with independence number $7$ passes through that gate by the
narrowest of margins — $28 < 29$ — and in doing so certifies that four
colors, even generously shared, are not enough for the plane. Sometimes the
whole weight of a famous problem comes to rest on two well-placed points and
one inequality you could check on the back of an envelope.
