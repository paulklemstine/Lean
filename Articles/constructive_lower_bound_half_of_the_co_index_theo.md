# How to Add Spheres: A Hidden Arithmetic of Symmetry

## A coffee-cup question

Imagine you are stirring a cup of coffee. At every instant, the surface of the
liquid is a smooth landscape of tiny hills and valleys. A classical and slightly
magical fact says that no matter how you stir, there are always two points on the
surface that are *exactly antipodal* — directly opposite through the center of the
cup — where the coffee has the same height and the same slope. You cannot get rid
of that coincidence. It is forced by symmetry alone.

This is the flavor of the **Borsuk–Ulam theorem**, one of the most quietly
powerful results in all of geometry. Its most famous cartoon version: at any
moment there are two antipodal points on Earth with identical temperature and
barometric pressure. The theorem is about *antipodal symmetry* — the operation
that sends every point to its mirror image through the center — and about what
that symmetry makes impossible.

This article is about a number that measures how much antipodal symmetry a shape
carries, and about a surprisingly clean piece of arithmetic that governs it.
We will discover that certain highly symmetric shapes can be *added together*,
and that when you add them, their symmetry numbers add too — plus a mysterious
extra $+1$. That little $+1$ is the whole story.

## Shapes that know their own mirror

Let us make the symmetry precise. A **space with antipodal symmetry** is a shape
$X$ together with a rule $a$ that pairs up its points: each point $v$ has a
partner $a(v)$, its antipode. We insist on two things.

- Applying the rule twice returns you home: $a(a(v)) = v$. The antipode of your
  antipode is you.
- No point is its own antipode: $a(v) \ne v$. Nothing sits fixed at the exact
  center; the symmetry is *free*, never pinning anything down.

The cleanest examples are spheres. The circle, the ordinary round sphere, and
their higher-dimensional cousins all carry the antipodal map "send $x$ to $-x$."
But for computation it is far more convenient to replace the smooth round sphere
with a crystalline skeleton that carries exactly the same symmetry: the
**octahedral sphere**.

Picture the ordinary octahedron — two pyramids glued base to base, with six
vertices sitting at $\pm e_1, \pm e_2, \pm e_3$ along the three coordinate axes.
Its surface is a combinatorial sphere, and the antipodal map simply flips the
sign of a vertex: $+e_i \leftrightarrow -e_i$. Generalizing, the
**$n$-dimensional octahedral sphere** $S^n$ has $2(n+1)$ vertices — a plus and a
minus along each of $n+1$ coordinate axes — and its "faces" are exactly the
collections of vertices that contain no opposite pair. You may pick $+e_i$ or
$-e_i$ for as many axes as you like, but never both. This is the boundary of the
cross-polytope, and it is a faithful crystalline model of the round $n$-sphere,
antipodal symmetry included.

## Maps that respect the mirror

To compare two symmetric shapes we use maps that *honor* the symmetry. A map
$f\colon X \to Y$ between spaces with antipodal symmetry is called **equivariant
and simplicial** if it satisfies two conditions.

- **It respects antipodes:** $f(a(v)) = a(f(v))$. Mirror images are sent to
  mirror images. The map cannot tell a point from its antipode more than the
  target already does.
- **It respects faces:** it never manufactures a forbidden opposite pair. If two
  vertices were *not* antipodal, their images are not antipodal either. Written
  compactly: whenever $f(p)$ and $f(q)$ land on antipodal vertices, the original
  $p$ and $q$ were already antipodal.

The second condition is the combinatorial ghost of continuity: it guarantees the
map sends genuine faces to genuine faces, so it really describes a continuous
antipodal map between spheres and not some torn-up impostor.

Here is the payoff. There is an equivariant simplicial map
$S^m \to S^n$ **if and only if** $m \le n$. You can always squeeze a small
symmetric sphere into a bigger one — just include the first $m+1$ axes into the
first $m+1$ of the $n+1$ available. But you can *never* map a big symmetric
sphere down into a smaller one. That impossibility is precisely Borsuk–Ulam in
combinatorial clothing: a symmetry-respecting map $S^n \to S^{n-1}$ would let you
comb the coffee cup flat, and you cannot.

## A number for symmetry

This suggests a way to measure the symmetric complexity of *any* space $X$ with a
free antipodal map. Ask: what is the largest sphere that fits inside $X$
symmetrically? Formally, the **symmetry index** (or **co-index**) of $X$ is

$$\operatorname{coind}(X) = \max\{\, m : \text{there is an equivariant simplicial map } S^m \to X \,\}.$$

It records the biggest amount of "sphere-like antipodal symmetry" that $X$ can
host. By the fit-or-fail principle above, the octahedral spheres calibrate the
scale perfectly:

$$\operatorname{coind}(S^n) = n.$$

A sphere's symmetry index is exactly its dimension. The measuring stick measures
itself correctly — always a reassuring sign.

## Adding spaces: the join

Now for the surprising arithmetic. There is a natural way to *combine* two
symmetric shapes into a bigger one, called the **join**, written $X \star Y$.

Combinatorially it could not be simpler: take all the vertices of $X$ and all the
vertices of $Y$, throw them into one pile, and keep each shape's own antipodal
rule on its own vertices. Geometrically this is richer than it sounds. The join
of two shapes is what you get by taking every point of $X$, every point of $Y$,
and *all the straight segments joining one to the other* — sweeping out a whole
new, higher-dimensional shape. The join of two points is a segment; the join of a
segment with a point is a triangle; the join of two circles is the $3$-sphere.

The single most important example is joining with $S^0$. The zero-dimensional
sphere $S^0$ is just two antipodal points. Joining any shape with those two
points builds two cones over it, glued along their common base — this is exactly
the classical **suspension**. Suspension is the engine that manufactures the
whole tower of spheres: suspend a circle and you get the $2$-sphere, suspend that
and you get the $3$-sphere, and so on. In our arithmetic, $S^0 = S^0$, and
suspending means joining with it.

## The main theorem: symmetry adds, with a bonus

We can now state the heart of the matter. Join two symmetric shapes and their
symmetry indices combine — and not merely additively, but with an extra unit:

> **The Join Law (lower bound).** For any two spaces $K$ and $L$ with free
> antipodal symmetry,
> $$\operatorname{coind}(K \star L) \ \ge\ \operatorname{coind}(K) + \operatorname{coind}(L) + 1.$$

Why should there be a $+1$? Because the join does more than sit the two shapes
side by side — it *fuses* them with a full slab of new connecting segments, and
that connective tissue is itself a fresh dimension of symmetry. Two symmetric
spheres, joined, yield strictly more symmetry than the sum of their parts.

The proof is completely constructive, and its mechanism is the prettiest part of
the theory. Suppose we have a symmetric copy of $S^a$ living inside $K$ and a
symmetric copy of $S^b$ living inside $L$. We want to exhibit a symmetric copy of
$S^{a+b+1}$ inside $K \star L$. The trick is a perfect coordinate bookkeeping
identity for the octahedral spheres:

$$S^m \star S^n \ \cong\ S^{m+n+1}.$$

This is an *exact isomorphism*, not an approximation. Its recipe is to simply
concatenate the coordinate axes: the $m+1$ axes of the first sphere followed by
the $n+1$ axes of the second give $m+n+2$ axes in total — exactly the axis count
of $S^{m+n+1}$ — with all the plus/minus signs carried along untouched. Line up
the axes, keep the signs, and the join of two octahedral spheres *is* a single
larger octahedral sphere on the nose.

Chaining these facts together gives the theorem. Take the big sphere
$S^{a+b+1}$, split it into $S^a \star S^b$ by the coordinate identity, push
$S^a$ into $K$ and $S^b$ into $L$ by the maps we were handed, and land inside
$K \star L$. Every step honors the antipodal symmetry, so the composite is the
symmetric $S^{a+b+1}$ we sought. The $+1$ is precisely the seam where the two
coordinate blocks meet.

## Sharpness: an exact addition table

The lower bound is one-directional — it guarantees *at least* this much symmetry.
On the octahedral spheres themselves we can pin down the answer exactly, because
there the coordinate identity is a genuine isomorphism in both directions:

> **Sharp Join Law.** For all $m, n \ge 0$,
> $$\operatorname{coind}(S^m \star S^n) = m + n + 1 = \operatorname{coind}(S^m) + \operatorname{coind}(S^n) + 1.$$

Here the abstract $+1$ becomes a hard equality. The spheres form a perfect
**addition table** under the join: the operation "$\star$" behaves like ordinary
addition shifted by one. Setting $L = S^0$ recovers the classical fact that
suspension bumps the symmetry index up by exactly one,
$\operatorname{coind}(K \star S^0) = \operatorname{coind}(K) + 1$ — the single
step that builds the sphere tower rung by rung.

Because ordinary addition is commutative and associative, so is the join on the
level of symmetry: joining $S^m$ then $S^n$ gives the same index as joining
$S^n$ then $S^m$, and grouping three spheres either way,
$(S^m \star S^n) \star S^k$ or $S^m \star (S^n \star S^k)$, yields the same value
$m + n + k + 2$. The octahedral spheres form a clean, commutative, associative
**monoid** — an algebraic gadget as tidy as the natural numbers themselves,
hiding inside the geometry of symmetric shapes.

## Why it matters

This little arithmetic is not a curiosity. The symmetry index is a standard tool
for proving that things *cannot* be done — that a graph cannot be colored with
too few colors, that a necklace cannot be fairly split among thieves with too few
cuts, that certain data cannot be embedded without collisions. All these
applications reduce to producing symmetric maps into or out of spheres and joins.
Every time you can lower-bound a symmetry index by exhibiting a concrete
equivariant map, you get an impossibility theorem for free. The Join Law is a
machine for building those maps: it lets you assemble complicated symmetric
spaces out of simple sphere pieces and read off their symmetry budget by simple
addition.

There is also something philosophically satisfying here. We began with a
theorem about coffee cups and the impossibility of combing a sphere flat. We end
with an addition table. The geometry of symmetric spaces, which seems soft and
topological, turns out to conceal a rigid piece of counting — join two spheres,
add their dimensions, remember the extra seam. Symmetry, it turns out, obeys an
arithmetic all its own.

## The road ahead

Three questions remain irresistibly open. First, is the Join Law an equality for
*every* pair of symmetric spaces, not just the spheres? The lower bound holds
universally; the matching upper bound calls for a subtler obstruction that can
measure symmetry from above. Second, can we engineer shapes whose symmetry index
falls *short* of their dimension by a prescribed amount, and watch a single
suspension close the gap? The join gives us a dial to separate dimension from
symmetry, exactly the freedom such constructions need. Third, when we suspend a
shape over and over, its "symmetry deficit" can only shrink and must eventually
vanish — a saturation phenomenon waiting to be proved. Each of these is a door,
and the coordinate arithmetic of the join is the key we now hold in hand.
