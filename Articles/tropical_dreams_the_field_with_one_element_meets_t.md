# Tropical Dreams: When the Field with One Element Learned to Count

## A field that shouldn't exist

Mathematicians have a habit of falling in love with objects that do not exist.
The most famous of these ghosts is called **the field with one element**, written
$\mathbb{F}_1$. It has haunted number theory for more than half a century.

The trouble started with a beautiful accident. When you count solutions to
equations over a finite field with $q$ elements, the answers arrange themselves
into tidy formulas — the celebrated Weil conjectures. Take the projective line:
over the field with $q$ elements it has exactly $q + 1$ points. A projective
plane has $q^2 + q + 1$. In general, projective $n$-space has

$$
1 + q + q^2 + \cdots + q^n = \frac{q^{n+1} - 1}{q - 1}
$$

points. Now do something forbidden: set $q = 1$. The formula collapses to
$n + 1$. Somehow, mysteriously, the "number of points of projective $n$-space
over a field with one element" wants to be $n + 1$ — even though no field with a
single element can exist, because in any field the additive zero and the
multiplicative one must be different.

For decades $\mathbb{F}_1$ was a slogan without a definition. It was the name we
gave to a pattern we could see but not touch: the shadow that finite fields cast
as $q$ slides down toward $1$. Everyone agreed the shadow was real. Nobody could
agree on what was casting it.

## A different world where plus means minimum

Meanwhile, in a neighboring part of mathematics, a strange arithmetic was
quietly reshaping algebraic geometry. It is called the **tropical semiring**, and
it is defined on the real numbers together with a point at infinity,
$\mathbb{R} \cup \{\infty\}$, by two deceptively simple rules:

$$
a \oplus b = \min(a, b), \qquad a \odot b = a + b.
$$

Addition becomes *taking the smaller of two numbers*. Multiplication becomes
*ordinary addition*. This is not a game; it is the arithmetic that governs
optimization, scheduling, the shortest path through a network, and the limiting
behavior of polynomials as their coefficients are stretched to extremes.

The tropical world has one feature that feels like a defect until you realize it
is a fingerprint. Its addition is **idempotent**:

$$
a \oplus a = \min(a, a) = a.
$$

Adding something to itself changes nothing. And there is no subtraction — you
cannot undo a minimum, because once you have thrown away the larger of two
numbers, it is gone forever. There are no additive inverses.

Now look back at $\mathbb{F}_1$. What would a "field" with one element have to
look like? It would have a multiplication but no genuine addition, because
addition is exactly the structure that forces zero and one apart. The tropical
semiring has a rich multiplication (ordinary $+$) and an addition so degenerate
($\min$) that it barely deserves the name. **The defect of the tropical world is
precisely the defect that** $\mathbb{F}_1$ **was supposed to have.**

This is the dream that organizes everything below: *the field with one element is
tropical, and tropical geometry is the geometry of $\mathbb{F}_1$.* The two
ghosts are the same ghost.

## From polytopes to varieties, and back

To turn a dream into mathematics you need a dictionary, and the dictionary here
runs through convex polytopes — the higher-dimensional cousins of polygons and
polyhedra.

A tropical variety, in its simplest incarnation, is encoded by a **polytope**
$P$: a bounded region cut out by finitely many flat faces, like a triangle, a
square, a tetrahedron, or a cube. This polytope is the tropical / $\mathbb{F}_1$
object. It knows nothing yet about complex numbers or classical geometry; it is
pure combinatorics, a shape with vertices, edges, and faces.

Then comes **base change**. There is a classical machine, older than tropical
geometry, that turns a lattice polytope into an honest geometric space — a
**toric variety**. You can think of base change as "tensoring up to $\mathbb{Z}$":
you take the skeletal $\mathbb{F}_1$-shape and pour in the integers, and out comes
a genuine variety $X_P$ over the usual numbers, one that carries topology,
cohomology, and all the classical invariants. The simplest example: the standard
$n$-dimensional simplex $\Delta^n$ (a triangle when $n = 2$, a tetrahedron when
$n = 3$) base-changes to projective $n$-space $\mathbb{P}^n$.

So we have a two-sided picture:

- **The $\mathbb{F}_1$ side:** a polytope $P$, a purely combinatorial object.
- **The classical side:** the toric variety $X_P$, obtained by base change to
  $\mathbb{Z}$.

The whole conjecture is that these two sides carry *the same information*. And
information, to be compared, must be counted.

## The two ways of counting must agree

Here is where the story becomes a theorem. Each side has a natural notion of
"size," and the claim is that they coincide.

**Counting on the** $\mathbb{F}_1$ **side.** The $\mathbb{F}_1$-points of the
polytope $P$ are its **vertices** — the corners. A triangle has $3$; a square has
$4$; a tetrahedron has $4$; a cube has $8$. This is the tropical cardinality: how
many corners does the shape have?

**Counting on the classical side.** Every geometric space has an **Euler
characteristic**, $\chi$, the most robust integer you can attach to a shape. For
a surface it is (vertices) $-$ (edges) $+$ (faces); in general it is the
alternating sum of Betti numbers,

$$
\chi(X) = \sum_{i} (-1)^i b_i(X),
$$

where $b_i$ counts the $i$-dimensional holes. The Euler characteristic is the
number that survives cutting, gluing, and deforming; it is the arithmetic
signature of a space's topology.

> **Main correspondence.** For the toric varieties considered here, the Euler
> characteristic of the base change equals the number of $\mathbb{F}_1$-points:
> $$ \chi(X_P) = \#\{\text{vertices of } P\} = \#\mathbb{F}_1\text{-points}. $$

The topological invariant on the classical side is nothing but the corner-count
on the combinatorial side. The dream now has a number attached to it, and the
number checks out.

## Why it is true: two clean mechanisms

The result rests on two structural facts, and understanding them is more
satisfying than the statement itself.

**Mechanism 1: odd holes vanish.** For projective space, and for the varieties we
build from it, the odd-dimensional Betti numbers are all zero — there are no
odd-dimensional holes. Projective $n$-space has exactly one even hole in each
dimension $0, 2, 4, \dots, 2n$ and nothing in between. Its list of Betti numbers
reads $1, 0, 1, 0, 1, \dots$. This is why its **Poincaré polynomial**, the
bookkeeping device $\sum_i b_i\, t^i$, is

$$
P_{\mathbb{P}^n}(t) = 1 + t^2 + t^4 + \cdots + t^{2n}.
$$

When the odd terms vanish, a small miracle occurs. The Euler characteristic is
the Poincaré polynomial evaluated at $t = -1$, while the **total Betti number**
(the sum of *all* the holes, with no signs) is the polynomial evaluated at
$t = +1$. If every odd coefficient is zero, the minus signs never fire, and the
two evaluations agree:

$$
\chi(X) = P_X(-1) = P_X(1) = \sum_i b_i(X).
$$

The alternating sum stops alternating. For $\mathbb{P}^n$ this common value is
$n + 1$ — exactly the number of vertices of the simplex $\Delta^n$.

**Mechanism 2: products multiply.** The interesting toric varieties are built as
**products** of projective spaces, $\mathbb{P}^{n_1} \times \cdots \times
\mathbb{P}^{n_k}$, which correspond to **product polytopes** $\Delta^{n_1} \times
\cdots \times \Delta^{n_k}$. Two facts click together here.

On the combinatorics side, the vertices of a product polytope are exactly the
tuples of vertices of the factors, so the corners simply multiply:

$$
\#\text{vertices}(P \times Q) = \#\text{vertices}(P) \cdot \#\text{vertices}(Q).
$$

On the topology side, the Poincaré polynomial of a product is the **product** of
the Poincaré polynomials (a Künneth-type convolution — a Cauchy product of the
Betti sequences). Because each factor has only even holes, so does the product,
and Mechanism 1 applies again. Evaluating the product polynomial at $t = 1$ gives
the product of the total Betti numbers:

$$
\chi\big(\textstyle\prod_i \mathbb{P}^{n_i}\big)
= \prod_i (n_i + 1)
= \prod_i \#\text{vertices}(\Delta^{n_i})
= \#\text{vertices}\big(\textstyle\prod_i \Delta^{n_i}\big).
$$

The two counts march in lockstep because both are *multiplicative*, and they
start from the same base case $\chi(\mathbb{P}^n) = n + 1$. That is the whole
proof, in spirit: a shared base case propagated by a shared product rule.

And notice what powers the argument at bottom. The reason the alternating sum
degenerates into a plain sum — the reason $\chi$ counts vertices rather than
some signed combination of them — traces back to idempotency, the very
fingerprint of the tropical world. No additive inverses on the tropical side; no
cancellation on the topological side. The absence of subtraction in
$\mathbb{F}_1$ is the absence of minus signs in the Euler characteristic.

## A worked example

Take $\mathbb{P}^2 \times \mathbb{P}^1$, the toric variety of the prism
$\Delta^2 \times \Delta^1$ (a triangle times a segment).

- **Corners.** The triangle has $3$ vertices, the segment has $2$, so the prism
  has $3 \times 2 = 6$ vertices. Six $\mathbb{F}_1$-points.
- **Topology.** The Poincaré polynomials are $1 + t^2 + t^4$ and $1 + t^2$. Their
  product is
  $$
  (1 + t^2 + t^4)(1 + t^2) = 1 + 2t^2 + 2t^4 + t^6.
  $$
  Every exponent is even. Evaluating at $t = 1$ gives $1 + 2 + 2 + 1 = 6$, and at
  $t = -1$ the same $6$, because nothing cancels.

Euler characteristic $6$, vertex count $6$. The classical invariant and the
combinatorial invariant are the same integer, arrived at by completely different
routes.

## What it means

Reading the correspondence from left to right, it says that a purely
combinatorial gadget — the corners of a polytope, a thing a child could count —
predicts a deep topological invariant of a complex algebraic variety. Reading it
from right to left, it says that the topology of these varieties is, at heart,
combinatorics in disguise; the holes are bookkeeping for corners.

But the deepest reading is the one we started with. The reason the accounting
works is that both worlds are built on the same broken arithmetic — an addition
with no inverse, a $\min$ that cannot be undone, a $+$ that has forgotten how to
subtract. That brokenness is not a bug. It is the signature of the field with one
element, and it is written identically in the idempotent semiring of tropical
geometry and in the sign-free Euler characteristics of toric varieties.

The field with one element was never a field. It was a way of counting corners.
And tropical geometry, all along, was the place where that counting lives. Two
ghosts, one shadow.

## The road ahead

The correspondence proved here covers products of projective spaces, where the
two load-bearing mechanisms — no odd holes, multiplicativity — are cleanest. The
natural horizon is every smooth projective toric variety: there a classical cell
decomposition attaches one even-dimensional cell to each torus-fixed point, so
odd holes again vanish and the Euler characteristic degenerates to a fixed-point
count, matching the vertices of the moment polytope. Refining the scalar count
into the full Poincaré polynomial turns the combinatorial *h*-vector of the
polytope into the Betti numbers of the variety, and the classical symmetry of
that vector — the Dehn–Sommerville relations — becomes Poincaré duality. The
corner-counting dream, it seems, has room to grow.
