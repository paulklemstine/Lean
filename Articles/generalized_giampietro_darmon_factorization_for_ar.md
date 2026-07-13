# The Shape of a Ratio: How Four Points Encode a Hidden Geometry

## A number that refuses to change

Take any four distinct points on a line — call them $a$, $b$, $c$, and $d$ — and
form the peculiar-looking combination

$$
(a,b;c,d) = \frac{(a-c)(b-d)}{(a-d)(b-c)}.
$$

This is the **cross-ratio**, one of the oldest and most stubborn quantities in
mathematics. Its magic is that it is *invariant*: slide, stretch, or project the
four points through any transformation of the classic projective kind, and the
cross-ratio comes out unchanged. Renaissance painters used its cousin to make
railway tracks converge convincingly to a vanishing point. Astronomers used it
to compare star positions across distorted telescopes. It is the fingerprint of
four points that survives almost any deformation you can throw at it.

What is far less obvious — and what this article is about — is that the
cross-ratio has a secret *arithmetic* life. When the four points are not just
dots on a line but arithmetically special points on a curved space, the
cross-ratio stops being a single number and becomes a bookkeeping device that
counts how those points collide, prime by prime. And when you try to push this
counting story from the simplest curved spaces to more complicated ones, a
genuine obstruction appears — an obstruction with a name, a shape, and a precise
mathematical identity. This article tells the story of that obstruction and of
the three clean facts that pin it down.

## From distance to divisibility

To see the arithmetic hiding inside the cross-ratio, we need a different notion
of "distance" between two numbers. The everyday distance between $x$ and $y$ is
$|x-y|$. But number theorists have a whole family of alternative rulers, one for
each prime $p$, called the **$p$-adic** rulers. In the $p$-adic world, two
numbers are *close* not when their difference is small in the ordinary sense, but
when their difference is highly divisible by $p$. The number $1000$ is very close
to $0$ in the $5$-adic sense (it is divisible by $5^3$), while $1$ and $2$ are as
far apart as can be.

We measure this with the **$p$-adic valuation** $v_p(x-y)$: the exponent of the
largest power of $p$ dividing $x - y$. The bigger the valuation, the closer the
two numbers are in the $p$-adic sense. In the geometry of arithmetic, this
valuation has a beautiful interpretation. When two special points on a curve
"reduce to the same point" modulo a prime — that is, when they crash into each
other after you look at the curve through the lens of arithmetic modulo $p$ — the
valuation of their difference measures *how hard* they collide. This is the
**local intersection multiplicity**:

$$
m(x,y) = v_p(x-y).
$$

Think of it as a tally of how many arithmetic layers deep two points touch.

## The factorization: the whole from its collisions

Here is the first of our three central results. The $p$-adic valuation of the
cross-ratio — a single global number — breaks apart perfectly into a signed sum
of four local collision counts:

> **The Cross-Ratio Factorization.** For four distinct rational points
> $a,b,c,d$ and any prime $p$,
> $$
> v_p\!\big((a,b;c,d)\big) = m(a,c) + m(b,d) - m(a,d) - m(b,c).
> $$

The reasoning is honest and direct: the valuation of a product is the sum of the
valuations, and the valuation of a quotient is the difference. Writing the
cross-ratio as $(a-c)(b-d)$ over $(a-d)(b-c)$ and applying these rules termwise
turns the tangled ratio into a clean alternating sum. The four terms $m(a,c)$,
$m(b,d)$, $m(a,d)$, $m(b,c)$ are exactly the four ways the numerator and
denominator pair up the points; the plus and minus signs simply record which
pairs live upstairs and which live downstairs.

This is the arithmetic skeleton of a much deeper theorem about special points —
*CM points* and their *Heegner divisors* — on certain highly symmetric curved
spaces. In the simplest such spaces, the ones with no "holes" (mathematicians say
**genus $0$**), this factorization is the whole story: the global cross-ratio is
completely determined by local collision data, and nothing is left over.

## A tempting shortcut — and why it fails

Once you believe that global quantities decompose into local collisions, a
seductive conjecture presents itself. Surely, you might think, these collision
counts *add up along a chain*. If $x$ meets $y$ with multiplicity $m(x,y)$, and
$y$ meets $z$ with multiplicity $m(y,z)$, then walking from $x$ to $z$ through $y$
ought to give

$$
m(x,z) \stackrel{?}{=} m(x,y) + m(y,z).
$$

If true, this "chain additivity" would make the whole theory purely
combinatorial: you could compute any collision from a handful of neighboring
ones, and no deeper correction would ever be needed. It is exactly the kind of
clean rule one hopes for.

It is false, and it fails at the smallest possible example. Take the prime
$p = 2$ and the three points $0$, $1$, $2$. Then $m(0,1) = v_2(1) = 0$ and
$m(1,2) = v_2(1) = 0$ — neither pair collides $2$-adically. But
$m(0,2) = v_2(2) = 1$: the outer pair *does* collide, one layer deep. So

$$
m(0,2) = 1 \ne 0 = m(0,1) + m(1,2).
$$

Additivity is dead on arrival. What replaces it is one of the most characteristic
laws of the $p$-adic world, the **ultrametric** (or *strong triangle*)
inequality:

> **Ultrametric law.** For distinct points $x, z$,
> $$
> m(x,z) \ge \min\big(m(x,y),\, m(y,z)\big).
> $$

In words: the outer collision is at least as deep as the shallower of the two
inner collisions. And there is a sharp companion to this: when the two inner
collisions have *different* depths, the outer one is exactly the smaller of them,

> **Isosceles law.** If $m(x,y) \ne m(y,z)$, then
> $$
> m(x,z) = \min\big(m(x,y),\, m(y,z)\big).
> $$

The name is apt. In $p$-adic geometry every triangle is isosceles: two of its
three side-lengths are always equal, and the third is never longer. This is not a
quirk; it is the deep local reason the naive additive picture cannot survive into
more complicated spaces. Collisions do not accumulate like distances on a road.
They behave like altitudes on a landscape of nested valleys.

## Higher genus and the price of complexity

Now push the story to richer spaces — those with holes, of **higher genus**.
Here the natural home for collision data is no longer a plain line but the
*Jacobian*, an abstract torus that packages the curve's holes into an algebraic
group. Points on the Jacobian can be added and subtracted, and they carry a
notion of size: the **canonical height** (also called the Néron–Tate height), a
way of measuring how arithmetically complex a point is.

The height comes with a pairing — a way to measure not just the size of one point
but the *correlation* between two, written $\langle D, E\rangle$. This pairing is
a genuine inner product: symmetric, and positive in the sense that
$\langle D, D\rangle \ge 0$ always, with equality only for the "trivial"
(torsion) classes. It is, in effect, the geometry of the space of holes.

When you try to factor the global cross-ratio into local collisions on a
higher-genus space, the factorization no longer closes up exactly. A leftover
term appears — a **global obstruction** — and its size is governed entirely by
this height pairing. The natural way to measure the obstruction attached to two
collision classes $D$ and $E$ is their **Gram determinant**:

$$
\mathrm{Obs}(D, E) = \langle D, D\rangle\,\langle E, E\rangle - \langle D, E\rangle^2.
$$

This single quantity carries the whole story of when the clean local picture
succeeds and when it must be corrected. Three facts make it precise.

**First, the obstruction is never negative.** This is the celebrated
Cauchy–Schwarz inequality in disguise: for any inner product,
$\langle D, E\rangle^2 \le \langle D, D\rangle\,\langle E, E\rangle$, so
$\mathrm{Obs}(D,E) \ge 0$. Geometrically, the Gram determinant is the squared
area of the parallelogram spanned by $D$ and $E$; an area cannot be negative.

**Second, the obstruction vanishes exactly in the simple case.** If one of the
divisors, say $D$, is a torsion class — height zero, $\langle D, D\rangle = 0$ —
then $\mathrm{Obs}(D, E) = 0$ for every $E$. This is the mathematical fingerprint
of the genus-$0$ world reappearing inside the general theory: no height, no
obstruction, exact factorization. The two stories agree precisely where they
should.

**Third, the obstruction vanishes for parallel divisors.** If $D$ is a scalar
multiple of $E$ — the two collision classes point in the same direction, $D = tE$
— then the parallelogram they span is degenerate, its area is zero, and
$\mathrm{Obs}(D, E) = 0$. The obstruction, then, measures precisely the *failure
of two divisors to be proportional*: it is large exactly when $D$ and $E$ explore
genuinely independent directions in the space of holes.

## Why this is a satisfying picture

Step back and look at the arc. A single invariant — the cross-ratio — turns out
to be a global summary of local collisions. In the simplest spaces those
collisions tell the whole tale. A naive attempt to make the local law additive
collapses at once, and is replaced by the sterner, truer ultrametric law, where
every triangle is isosceles. And when we move to spaces with holes, the price of
that complexity is a single, tangible obstruction: the Gram determinant of the
height pairing, always nonnegative, vanishing exactly for trivial or parallel
classes, and otherwise measuring how independently two families of special points
spread through the geometry.

There is a pleasing unity here. Cauchy–Schwarz, a fact usually met in a first
linear-algebra course, turns out to be the guarantee that a deep arithmetic
factorization can only ever be *helped*, never sabotaged, by the height pairing —
the obstruction can slow the story down but can never make it inconsistent. The
same inequality that says a shadow is never longer than the stick that casts it
tells us that the geometry of an elliptic curve's holes cannot conspire against
the local collision counts. It can only add a nonnegative correction.

## The bigger picture

The cross-ratio began as a tool for painters and surveyors, a number that refused
to change. Follow it into the arithmetic of curves and it becomes something
richer: a ledger of prime-by-prime collisions, governed locally by the strange
and rigid ultrametric geometry, and globally by a height pairing whose Gram
determinant is the exact toll charged for leaving the simplest spaces behind.

What makes the story worth telling is not any single formula but the way the
pieces lock together. The local law explains *why* a global obstruction must
exist — additivity fails, so something has to absorb the discrepancy. The height
pairing explains *what* the obstruction is. And Cauchy–Schwarz explains why the
whole edifice is stable: the correction is real, but it always points the same
way. Four points, one ratio, and a hidden geometry that reaches from
Renaissance perspective drawings to the arithmetic of curves.
