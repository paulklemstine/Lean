# Geometry Without Desargues: The Strange Worlds That Live at Order Nine

## A rule that isn't a rule

Draw two triangles on a sheet of paper. Position them so that the three lines
joining their corresponding corners all pass through a single point — as if both
triangles were shadows of the same object cast from one lamp. Now something
almost magical happens. Extend each pair of corresponding sides until they meet.
The three meeting points you get will always lie on a single straight line.

This is **Desargues' Theorem**, discovered by the French architect and engineer
Girard Desargues in the seventeenth century. It is one of the first deep facts of
projective geometry, the geometry of perspective and vanishing points that
Renaissance painters used to make flat canvases look three-dimensional. If two
triangles are *in perspective from a point*, then they are automatically *in
perspective from a line*.

For a long time it looked like a theorem — a consequence of more basic axioms.
And in the ordinary plane, and in every geometry you can build over a field of
numbers, it is exactly that: an inescapable law. But projective geometry can be
built more abstractly, from nothing but points, lines, and a single relation of
"lying on," obeying only three innocent-looking rules:

- any two distinct points lie on exactly one common line;
- any two distinct lines meet in exactly one common point;
- there exist four points, no three of which are collinear.

A finite structure obeying these rules is a **finite projective plane**. The
astonishing discovery of the twentieth century is that in this abstract world,
Desargues' theorem is *not* forced. There are perfectly consistent geometries —
finite, concrete, listable point-by-point — where you can find two triangles in
perspective from a point whose three side-intersections stubbornly refuse to line
up. These are the **non-Desarguesian planes**, and this article is about the two
smallest and most beautiful of them.

## Counting the smallest planes

Every finite projective plane has an **order** $n$: a single integer that
controls everything. A plane of order $n$ has exactly $n^2 + n + 1$ points and
the same number of lines; every line carries exactly $n+1$ points, and every
point lies on exactly $n+1$ lines. The familiar planes come from finite fields.
For each prime power $q = p^k$ there is a **Desarguesian plane** $PG(2,q)$, built
by taking the one-dimensional subspaces of a three-dimensional vector space over
the field with $q$ elements as its "points." These always satisfy Desargues'
theorem, because the underlying arithmetic — the field — is associative and
distributive and commutative, and those algebraic laws are exactly what the
geometric configuration secretly encodes.

For orders $2, 3, 4, 5, 7, 8$ the Desarguesian plane is the *only* projective
plane, full stop. Order $6$ has no plane at all (a consequence of the
Bruck–Ryser theorem and Euler's old problem of the thirty-six officers). So the
first moment where geometry can break free of the field is at

$$n = 9 = 3^2.$$

At order nine, alongside the classical $PG(2,9)$, there live genuinely new
worlds. And the way they are built is a story about **algebra losing its
manners**.

## Coordinates that misbehave

Here is the central bridge between geometry and algebra. Just as René Descartes
taught us to put coordinates on the ordinary plane and turn geometry into the
arithmetic of a field, one can put coordinates on *any* projective plane. But the
coordinate system you extract need not be a field. It is a weaker gadget called a
**planar ternary ring**, and the precise algebraic laws it satisfies mirror,
exactly, the precise geometric configurations that hold in the plane.

The dictionary reads like this:

- If the coordinate algebra is a full field, the plane is Desarguesian.
- If multiplication is **associative** and both distributive laws hold, but you
  do *not* require commutativity, you get a division ring — and by a famous
  theorem all *finite* division rings are fields, so no new finite planes here.
- To escape, you must break either **associativity** or **distributivity**.

An algebraic system that keeps enough structure to coordinatize a plane, but is
allowed to sacrifice these laws, is called a **quasifield**. A quasifield is a
set with an addition making it a commutative group, and a multiplication with a
two-sided identity, such that every equation $a\cdot x = b$ (with $a \neq 0$) has
a unique solution, one distributive law holds, and a certain uniqueness axiom
holds — but associativity and the *other* distributive law are optional. Whenever
one of those optional laws genuinely fails, the plane it coordinatizes is
non-Desarguesian.

At order nine there are exactly two ways this failure can happen, and each is
realized by a specific, hand-computable algebra of nine elements. They are the
two heroes of this story.

## The first world: the Hall system, where multiplication forgets how to group

Take the field $\mathbb{F}_9$ with nine elements. It is built from the field
$\mathbb{F}_3 = \{0,1,2\}$ (arithmetic modulo three) by adjoining a root $i$ of
an irreducible quadratic — say $x^2 = x + 1$ — so that every element is written
$a + bi$ with $a, b \in \mathbb{F}_3$. In $\mathbb{F}_9$, everything is
beautifully associative and distributive.

The **Hall system** of order nine keeps the same nine elements and the same
addition, but *rewrites the multiplication*. For elements that lie in the base
field the product is unchanged; but for a genuinely "two-dimensional" element $u$
— one not in $\mathbb{F}_3$ — the new product $u * v$ is defined by a twisted
rule that pulls in the coefficients of the irreducible polynomial. The upshot is
a multiplication that still has an identity, in which you can still always divide,
and in which one distributive law survives — but for which

$$ (a * b) * c \neq a * (b * c) $$

for some triples $a, b, c$. Associativity is gone.

This is not a defect of bookkeeping; it is the whole point. The failure of
associativity is *localized* in a precise algebraic invariant called the
**nucleus** — the set of elements that still associate with everything. In a
field the nucleus is the entire field. In the Hall system the nucleus shrinks
down to the little base field $\mathbb{F}_3$. That shrinkage is the fingerprint
of non-Desargues: the Hall plane of order nine, coordinatized by this system,
contains triangles in perspective from a point whose sides do not meet on a line.

## The second world: the Dickson nearfield, where the distributive law collapses

The second hero fails in the *opposite* way. Leonard Dickson, at the dawn of the
twentieth century, discovered how to keep multiplication perfectly associative
while breaking distributivity instead. His recipe, the **Dickson nearfield** of
order nine, again starts from the nine elements $a + bi$ of $\mathbb{F}_9$ with
their ordinary addition. Now multiplication is twisted by the **Frobenius
automorphism** $x \mapsto x^3$ (the map that cubes every element, which in
characteristic three is a genuine symmetry of the field). The twisted product
looks at whether the *left* factor is a perfect square and, if it is not, cubes
the right factor before multiplying:

$$ x \circ y = \begin{cases} x\,y & \text{if } x \text{ is a nonzero square},\\ x\,y^{3} & \text{if } x \text{ is a non-square},\\ \end{cases} $$

with $x \circ 0 = 0 \circ y = 0$. One checks patiently that this operation is
**associative** and that every nonzero element has a two-sided inverse:
multiplicatively, the nonzero elements form a group. What breaks is the *right*
distributive law:

$$ (x + y) \circ z \neq (x \circ z) + (y \circ z) $$

for suitable $x, y, z$. So the nearfield is an associative system whose nucleus
is *full* — everything associates — yet it is still non-Desarguesian, because
geometry cares about distributivity too.

And here the story delivers a genuine surprise. Look at the multiplicative group
of the eight nonzero elements of the Dickson nearfield of order nine. In the
ordinary field $\mathbb{F}_9$ that group is cyclic of order eight — a single
rotation repeated. But the Frobenius twist rewires the multiplication so that the
group becomes the **quaternion group** $Q_8$:

$$ Q_8 = \{\pm 1, \pm i, \pm j, \pm k\}, \qquad i^2 = j^2 = k^2 = ijk = -1. $$

This is the group Hamilton carved into a Dublin bridge — the algebra of
three-dimensional rotations, of spin in quantum mechanics — surfacing
unexpectedly inside a finite geometry. It has a single element of order two (a
unique "$-1$"), and every other non-identity element has order four. The twist
that destroys distributivity is exactly the twist that forces this unique central
involution.

## Two failures, one order

So at the very first order where geometry can break free of arithmetic, it breaks
free in two logically independent ways at once:

- The **Hall system** is *non-associative* (its nucleus has collapsed to
  $\mathbb{F}_3$) but retains a distributive law.
- The **Dickson nearfield** is *fully associative* (its nucleus is everything)
  but has lost the right distributive law, and pays for it by turning its
  multiplicative group into the quaternion group $Q_8$.

These are not two descriptions of the same object. They are algebraically
independent coordinatizations, sitting at the same order $9$, failing Desargues'
theorem for different reasons. One might have guessed that "how badly a plane
fails Desargues" is a single dial. It is not. Associativity and distributivity
are separate knobs, and each can be turned without the other.

## Why the symmetry shrinks

There is a second, quieter theme running underneath. A Desarguesian plane is
extraordinarily symmetric: its group of **collineations** — the
incidence-preserving shufflings of points and lines — is as large as it can
possibly be, essentially the projective linear group $PGL$ acting on
coordinates. Symmetry, here, is the visible shadow of good algebra. The more laws
your coordinate system obeys, the more ways you can rearrange the plane without
disturbing its structure.

When the algebra loses a law, the plane loses symmetry. Both the Hall plane and
the nearfield plane of order nine have collineation groups **strictly smaller**
than that of the classical plane. But — and this is the third surprise — the
*amount* of symmetry lost is not predicted by the nucleus. The nearfield plane
has a *full* nucleus (perfect associativity) and yet is less symmetric than the
classical plane. So "size of the nucleus" and "size of the symmetry group" are
genuinely different invariants. You cannot read one off from the other. A plane
can be algebraically well-behaved in one sense while being geometrically rigid in
another.

## The view from the summit

Why should anyone outside pure geometry care? Because non-Desarguesian planes are
the cleanest example of a phenomenon that recurs across mathematics: **the axioms
you take for granted are often independent of one another**, and dropping one
reveals a whole hidden zoo. Just as non-Euclidean geometry was born when
mathematicians dared to drop the parallel postulate, non-Desarguesian geometry is
born when we drop the assumption that our coordinates form a field. The result is
not chaos but a new taxonomy — planes classified by *which* algebraic law they
sacrifice.

They also connect outward. Finite projective planes are the backbone of
combinatorial design theory, error-correcting codes, and certain cryptographic
constructions; the non-Desarguesian ones supply designs and codes with symmetry
profiles unavailable from fields. The quaternion group appearing inside the
nearfield is a small echo of a large truth: the same non-commutative,
non-distributive structures that govern the geometry of order nine also govern
the algebra of rotations and the mathematics of quantum spin.

At order nine, geometry and algebra hold a mirror up to each other, and for the
first time the reflection is not a field. Two small, explicit, nine-element
worlds — one that forgot how to associate, one that forgot how to distribute —
stand as proof that Desargues' theorem was never a theorem of the abstract axioms
at all. It was a gift from arithmetic, and at order nine, we learn to live
without it.
