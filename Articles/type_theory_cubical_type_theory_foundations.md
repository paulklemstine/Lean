# Building a Doughnut Out of Two Circles: A Tour of Cubical Geometry

## The shape of a piece of string

Take a single piece of string. Hold one end in your left hand and the other
end in your right hand. As it lies between your hands, it is the simplest
geometric object imaginable: an *interval*, a line segment that begins at one
point and ends at another. Mathematicians call the idealized version of this
the **unit interval**, the set of all real numbers $t$ with $0 \le t \le 1$.
Its two endpoints, $0$ and $1$, are genuinely different places — you can pinch
them, label them, and tell them apart.

Now bring your two hands together and tie the ends into a loop. Something
remarkable has happened. The two endpoints, which a moment ago were distinct,
are now *the same point*. The string has become a circle. You did not add any
material; you did not stretch it; you simply declared that two points should be
treated as one. The geometry of the circle is born entirely from a single act
of **gluing**.

This little experiment is the seed of an entire modern viewpoint on geometry
and logic called **cubical type theory**. The central slogan is disarmingly
simple: *spaces are built from intervals, and the interesting structure lives
in how the endpoints are glued together.* A path is just a map out of an
interval. A loop is a path whose two ends land on the same spot. A surface is a
map out of a square. And complicated spaces — circles, doughnuts, spheres — are
assembled by recording, very explicitly, which boundary pieces of these basic
cubes are to be identified.

This article tells the story of a small, self-contained mathematical world in
which exactly this philosophy is carried out with complete precision. We will
build the circle from an interval, build the torus (the surface of a doughnut)
from a square, and then prove a clean and satisfying fact: **the torus is
nothing more than two circles multiplied together.**

## Gluing as a mathematical operation

The everyday word "gluing" hides a precise mathematical machine called a
**quotient**. Suppose you have a collection of points and a rule that says
which points should be regarded as the same. The quotient is the new collection
you obtain after honoring that rule — every group of "to-be-identified" points
collapses into a single new point, and everything else is carried along
untouched.

To build the circle, we start with the interval and impose exactly one gluing
rule:

$$\text{glue the point } 0 \text{ to the point } 1.$$

We write this rule as a relation: the point $0$ is *related* to the point $1$,
and to nothing else. Forming the quotient of the interval by this relation
produces a brand-new space. We call it the **Circle**. Every point of the
interval becomes a point of the circle, but the two former endpoints now
coincide. Their shared image is a distinguished point we call the **base
point**.

There is a canonical way to view the original interval sitting inside the
circle: the map that sends each interval point $t$ to its image in the circle.
This map is the **loop**. It is the formal embodiment of "running once around
the circle." And it satisfies precisely the property we engineered:

$$\text{loop}(0) = \text{base} = \text{loop}(1).$$

In words: the loop starts at the base point and ends at the base point. The two
endpoints of the string have been tied together. Nothing else has been
identified — every interior point of the loop is still its own distinct place
on the circle.

## How to use a circle: the recursion principle

Building a space is only half the job. The other half is knowing how to *use*
it — how to define functions out of it. Here cubical thinking offers an elegant
and rigid answer, and it is worth pausing on because it is the real engine of
the subject.

Suppose you want to define a function from the circle to some target collection
$X$. The circle was built from the interval by gluing, so a function out of the
circle is "the same as" a function out of the interval — **provided** that
function respects the gluing. Concretely:

> **Recursion principle for the circle.** To define a map from the circle to a
> set $X$, it suffices to give a map $f$ from the interval to $X$ together with
> a single proof that the two endpoints agree, $f(0) = f(1)$. This data induces
> a unique map out of the circle.

This is a contract. The map $f$ tells you where every point of the loop should
go. The equation $f(0) = f(1)$ is the toll you must pay for the gluing: since
the circle identified $0$ with $1$, any function out of the circle is obliged
to send them to the same place. Pay the toll, and you get your function.

Two computation rules describe how the resulting function behaves. At the base
point it returns $f(0)$, and along the loop at any point $t$ it returns $f(t)$.
In symbols, if $g$ is the induced map then $g(\text{base}) = f(0)$ and
$g(\text{loop}(t)) = f(t)$. There is also a **uniqueness** guarantee: any two
functions out of the circle that agree along the entire loop are in fact the
*same* function. There is no hidden freedom, no secret extra point you forgot
about — the loop sees everything. (Formally: the loop is *surjective*; every
point of the circle is $\text{loop}(t)$ for some $t$.)

This trio — *construct by gluing, compute on the generators, and pin down by
uniqueness* — is the rhythm of the entire theory. Once you internalize it for
the circle, the torus follows the same beat one dimension up.

## From string to fabric: the torus

A circle came from gluing the two ends of a one-dimensional interval. A torus
comes from gluing the edges of a two-dimensional **square**.

Picture a flat square sheet of rubber. Its boundary consists of four edges: a
bottom and a top (the horizontal pair), and a left and a right (the vertical
pair). Now perform two gluings:

1. **Glue the bottom edge to the top edge.** Rolling the sheet so its bottom
   meets its top turns the square into a cylinder — a tube.
2. **Glue the left edge to the right edge.** Bending the tube around so its two
   circular ends meet turns the cylinder into a doughnut.

The result is the **Torus**, the surface of a doughnut. As with the circle, we
never added material; we only declared identifications. Formally, we take the
square — the set of pairs $(x, y)$ where both coordinates lie in the unit
interval — and impose two gluing rules:

$$ (x, 0) \sim (x, 1) \quad\text{for every } x \qquad\text{(top to bottom)},$$
$$ (0, y) \sim (1, y) \quad\text{for every } y \qquad\text{(left to right)}.$$

The quotient by these two families of relations is the torus. There is a
canonical map sending each square point $(x,y)$ to its image on the torus, and
it satisfies exactly the two gluing equations we imposed: the bottom and top
edges coincide, and the left and right edges coincide.

The torus comes with its own recursion principle, in the same spirit as the
circle's but now demanding **two** tolls instead of one:

> **Recursion principle for the torus.** To define a map from the torus to a
> set $X$, it suffices to give a map $f$ from the square to $X$ together with
> two proofs: that $f$ agrees on the horizontal edges, $f(x,0) = f(x,1)$ for
> all $x$, and that $f$ agrees on the vertical edges, $f(0,y) = f(1,y)$ for all
> $y$. This data induces a unique map out of the torus.

Again there is a computation rule (the induced map sends the image of $(x,y)$
to $f(x,y)$) and a uniqueness guarantee (any map that agrees with $f$ on every
square point is *the* induced map). The square map is surjective: every point
of the torus is the image of some point of the square.

## The punchline: a doughnut is two circles

Here is where the construction pays a genuine dividend. There is an old and
beautiful intuition that the torus is a "product" of two circles. Think of how
you might address a point on a doughnut: you need to know *how far around the
big loop* you are (the longitude) and *how far around the tube* you are (the
meridian). Each coordinate is an angle — a point on a circle. So a point on the
torus is exactly a pair of circle-points. The torus *is* the circle times the
circle.

In our gluing model this intuition becomes a precise, verified theorem:

$$\boxed{\; \text{Torus} \;\simeq\; \text{Circle} \times \text{Circle}. \;}$$

The symbol $\simeq$ means **equivalence**: a perfect dictionary translating
back and forth between the two spaces with no information lost. The
construction of this dictionary is wholly explicit and uses only the recursion
principles we have already met.

Going *from the torus to the pair of circles* is the natural move. Take a point
on the torus, lift it to a representative square point $(x, y)$, and send it to
the pair $(\text{loop}(x), \text{loop}(y))$ — its longitude and its meridian.
This is well defined precisely because the loop already glues its own
endpoints: the toll on the torus's horizontal edges is paid by the circle's
identity $\text{loop}(0) = \text{loop}(1)$, and likewise for the vertical
edges. The gluings of the torus are *exactly* the gluings the two circles
already perform, so the map descends cleanly to the quotient.

Going *back, from a pair of circles to the torus*, we feed each circle
coordinate through the circle's recursion principle, nesting one inside the
other to assemble the square point and then map it into the torus. The two
tolls of the torus recursor are once more discharged by the circle's endpoint
identifications.

Finally one checks the two round-trips. Start on the torus, travel to the pair
of circles, and come home: you are exactly where you began. Start with a pair
of circles, travel to the torus, and come home: again, exactly where you began.
Both checks reduce, after unfolding the definitions, to bookkeeping that the
computation rules settle automatically. The dictionary is faithful in both
directions, and the equivalence is sealed.

## Why this matters

It would be easy to dismiss all of this as an elaborate way of saying something
obvious. But the value lies in the *method*, not just the conclusion. Three
ideas deserve emphasis.

**Spaces from instructions.** We never needed the real numbers' geometry,
distances, or continuity to make the circle and the torus behave like a circle
and a torus. We needed only an interval, a square, and a precise list of which
boundary pieces to identify. This is the cubical creed: geometry is a record of
gluing instructions, and those instructions can be written down with the same
rigor as an arithmetic identity. It is geometry rebuilt as algebra.

**Recursion as the universal interface.** Every one of our spaces came packaged
with a recursion principle — a single, uniform rule for defining maps out of
it, gated by exactly the equations that the gluing imposes. This is what makes
the constructions *composable*. To build the torus-to-circles map we did not
reach into the guts of the quotient; we simply invoked the torus's recursion
principle and paid its tolls using facts we had already proved about circles.
Large structures grow from small ones without ever reopening the foundations.

**Equivalence as the right notion of sameness.** When we said the torus *is*
two circles, we did not mean they are literally the same set of points. We
meant there is a lossless translation between them. In the cubical world this
notion of "sameness up to perfect translation" is the protagonist. It is the
shadow, at the level of plain sets, of one of the deepest principles in the
modern foundations of mathematics — the idea that equivalent structures may be
*identified*, treated as genuinely equal for all purposes. Our humble
torus-equals-two-circles theorem is a hands-on rehearsal of that principle.

## The road ahead

The constructions here are deliberately minimal — a one-dimensional gluing for
the circle and a two-dimensional gluing for the torus — and that minimality is
a feature. It exposes the skeleton of the subject so cleanly that the next
steps almost suggest themselves.

One can ask for a *dependent* recursion principle, which would let the target
of a function vary from point to point across the space — the difference
between painting a circle a single color and wrapping it in a ribbon whose
pattern changes as you go around. One can ask to *fill in* the square of the
torus with genuine two-dimensional cells, capturing not just the edges but the
surface they bound. One can try to compute, combinatorially, the famous
**fundamental group** that detects how loops wind around a space. And one can
seek a single, uniform "pushout" recipe that produces the circle, the torus,
spheres, and wedges all as instances of one master gluing construction.

Each of these is a natural extension of the same idea we have followed from the
very first piece of string: a space is what you get when you decide, carefully
and explicitly, which points to glue. Tie the ends of a string and you have a
circle. Glue the edges of a square and you have a doughnut. And a doughnut, it
turns out, is just two circles holding hands.
