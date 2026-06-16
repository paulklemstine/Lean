# The Secret Geometry of Right Triangles

## A tree, a ruler that only knows powers of one-half, and the surprising place where ancient arithmetic meets modern algebra

Some of the oldest mathematics we know is about right triangles. Clay tablets
from Babylon, more than three and a half thousand years old, already list whole
numbers that fit together perfectly: a triangle with sides 3, 4, and 5, or 5,
12, and 13, where the two short sides squared add up to the long side squared.
We call them **Pythagorean triples**, and the smallest of them, (3, 4, 5), is so
clean it shows up in carpentry, surveying, and grade-school classrooms to this
day.

Here is a question that sounds innocent and turns out to be deep: *is there a
hidden order among all of these triples?* There are infinitely many of them.
Are they just scattered, an endless pile of arithmetic coincidences? Or is there
a master plan — some machine that produces every single one, exactly once, in a
predictable pattern?

The astonishing answer, discovered and rediscovered across the twentieth century,
is that there **is** such a machine. It is a tree. And once you see the tree, you
can do something no one expected: you can put a **ruler** on the space of all
right triangles and measure how "close" two triangles are to each other. That
ruler turns out to obey a strange and beautiful law — not the ordinary geometry
of the plane, but the geometry of *ultrametric spaces*, the same exotic distance
that governs the p-adic numbers, the branching of evolutionary trees, and the
clustering of data. This article is the story of that tree and that ruler, and of
the unexpected bridge they build between right triangles, a curious "min-plus"
arithmetic, and the complex numbers.

## One tree to grow them all

Start with the seed: the triangle (3, 4, 5). Now apply three simple
transformations. Each one takes a triple `(a, b, c)` and spits out a new triple
by mixing the three numbers in a fixed linear way. Written out, the three
"children" are:

- **Branch A:** `(a − 2b + 2c, 2a − b + 2c, 2a − 2b + 3c)`
- **Branch B:** `(a + 2b + 2c, 2a + b + 2c, 2a + 2b + 3c)`
- **Branch C:** `(−a + 2b + 2c, −2a + b + 2c, −2a + 2b + 3c)`

Feed (3, 4, 5) into these three formulas and you get three new triples:
(5, 12, 13), (21, 20, 29), and (15, 8, 17). Every one of them is again a genuine
Pythagorean triple — the squares still add up. Feed *those* into the same three
formulas, and you get nine more. Then twenty-seven. Then eighty-one. A ternary
tree blooms outward, every node a right triangle, every triangle the parent of
exactly three others.

The miracle, first proved in the 1960s and 70s, is that this tree contains
**every primitive Pythagorean triple exactly once** — every triangle whose three
sides share no common factor appears at precisely one address in the tree, and
none appears twice. The chaotic infinite pile is secretly a perfectly organized
genealogy descending from a single ancestor.

Why do the three formulas work? Because each is secretly a *symmetry*. If you
rewrite the Pythagorean condition `a² + b² = c²` as `a² + b² − c² = 0`, you are
looking at the equation of a cone — the "light cone" of a flat spacetime with two
space directions and one time direction. The three branch formulas are exactly
the integer-coordinate transformations that leave this cone fixed: discrete
Lorentz transformations, the same kind of symmetry that governs special
relativity, here quietly shuffling Pythagorean triples. Two of them preserve
orientation; one flips it. Each one preserves the quantity `a² + b² − c²` on the
nose, so a triangle on the cone stays on the cone forever.

## Naming triangles by their address

If every triangle has a unique place in the tree, then every triangle has a
unique **address**: the sequence of turns — A, B, or C — you take to walk from
the root down to it. (3, 4, 5) is the empty address, the root itself. (5, 12, 13)
is "A". (7, 24, 25) is "A, A". And so on.

Now let your imagination run off the edge of the finite tree. Instead of stopping
at some triangle, keep choosing turns forever: A, then C, then C, then B, then A,
… An *infinite* sequence of choices doesn't name a triangle; it names a **path**,
an idealized journey to infinity through ever-larger triangles. The collection of
all such infinite paths is the **boundary** of the tree. Mathematically it is
just the set of infinite sequences drawn from a three-letter alphabet — we can
write it as functions from the counting numbers into the set {0, 1, 2}, one
choice for each step. Call this space of addresses **Addr**.

This boundary is where the real surprise lives.

## A ruler built from disagreement

How far apart are two infinite paths? Here is the idea, and it is the heart of
everything that follows. Walk down two paths side by side. As long as they make
the same choices, they travel together through the same triangles. At some point
they may diverge — one turns A where the other turns B. Call the step number where
they **first disagree** their *first-difference index*. Paths that stay together
for a long time before splitting are "close." Paths that split immediately are
"far."

We turn this into a number with a deliberately peculiar choice. Define the
distance between two distinct paths `x` and `y` as

> **d(x, y) = (1/2) raised to the power of their first-difference index.**

If they split at step 0 (different first move), the distance is (1/2)⁰ = 1 — the
maximum. If they agree for the first five steps and split at step 5, the distance
is (1/2)⁵ = 1/32 — quite close. And if two paths never disagree, they are the
same path, and the distance is 0. This `d` is a perfectly good notion of distance:
it is never negative, it is zero only between a path and itself, and it is
symmetric — `d(x, y) = d(y, x)` — because "where do they first disagree" doesn't
care which path you name first.

So far this looks like an ordinary ruler. It is not.

## The strange law: every triangle is isosceles

Ordinary distance obeys the *triangle inequality*: the direct route is no longer
than a detour, `d(x, z) ≤ d(x, y) + d(y, z)`. Our tree ruler obeys something
much stronger, the **ultrametric inequality**:

> **d(x, z) ≤ max( d(x, y), d(y, z) ).**

In words: the distance from `x` to `z` is no bigger than the *larger* of the two
distances through any waypoint `y`. Not the sum — the maximum. This single
strengthening changes geometry beyond recognition. One consequence: in an
ultrametric world, **every triangle is isosceles**, with the two longest sides
equal. There are no "scalene" triangles. Distances come in discrete tiers, like
nested Russian dolls, and any two balls of the same size are either identical or
completely disjoint — they never partially overlap the way circles do in the
plane.

Why does our ruler obey this stronger law? It comes down to a clean fact about
agreement. Suppose `x` and `y` agree for their first `m` steps, and `y` and `z`
agree for their first `n` steps. Then `x` and `z` must agree for at least the
first `min(m, n)` steps — if both `x` and `z` are still copying `y` up to step
`min(m,n)`, they are copying each other too. So the first-difference index of
`x` and `z` is at least the *minimum* of the other two indices. Now feed that
through our distance formula. The distance is (1/2) to a power, and raising 1/2
to a *larger* power makes a *smaller* number. So "first-difference index is at
least the minimum" flips into "distance is at most the maximum." The min over
indices becomes the max over distances. That flip — from minimum to maximum, from
agreement depth to distance — is the whole secret, and it is exactly the kind of
bookkeeping that mathematicians call **tropical**, or **min-plus**, arithmetic:
an algebra where you add by taking minimums.

## The three branches are perfect half-scalers

The three branches of the tree don't just generate triangles; they act on the
boundary too. Prepending the letter "A" to every path is a map from the boundary
to itself — it sends the path `x` to the path "A, then x." Call this operation
**cons**.

Here is a clean, exact fact. Take any letter `k` and any two paths `x` and `y`.
Prepending `k` to both shifts their first disagreement one step later (they now
agree at least on that shared first letter), so their first-difference index goes
up by exactly one. And going up by one in the exponent of 1/2 means multiplying
the distance by exactly 1/2. In symbols:

> **d(cons k x, cons k y) = (1/2) · d(x, y).**

Every branch is a perfect **half-scale similarity**: it shrinks every distance by
precisely the factor one-half, with no distortion at all. The three branches are
contractions with identical ratio 1/2 — the defining feature of a
self-similar fractal.

And they keep out of each other's way. If two paths start with *different*
letters, they disagree at step 0, so their distance is the maximum value, 1:

> **different first move ⟹ d(x, y) = 1.**

The three branch-images sit at distance exactly 1 from one another — three
disjoint clopen "continents" tiling the whole boundary, each a shrunken half-size
copy of the entire space. This is the signature of a classical fractal, the
ternary cousin of the Cantor set, and it pins down the boundary's fractal
dimension as the ratio log 3 / log 2 ≈ 1.585 — the same dimension as the Sierpiński-like
self-similar dust built from three half-size copies.

## Size and depth grow hand in hand

There is also a concrete arithmetic payoff that ties the abstract boundary back to
the triangles themselves. Follow the all-B path — turn B at every step. The
hypotenuses of the triangles you pass through grow geometrically, and we can pin
the growth between two clean walls. At each B-step the hypotenuse at least
triples and at most multiplies by seven. Starting from hypotenuse 5 at the root,
after `n` steps the hypotenuse `c` is trapped in a two-sided window:

> **5 · 3ⁿ ≤ c ≤ 5 · 7ⁿ.**

The lower wall comes from the fact that the B-branch's new hypotenuse is always at
least three times the old one; the upper wall, from the fact that it is at most
seven times the old one (as long as the legs don't exceed the hypotenuse, which on
the cone they never do). The upshot is a *logarithmic* law: to reach a triangle
with hypotenuse `c` you only need about `log c` steps down the tree. Depth in the
tree and the *logarithm* of triangle size are the same quantity up to constants —
which is exactly why an ultrametric, where distance is `(1/2)` to the depth, is the
natural ruler. A ball of radius `2⁻ⁿ` in our metric corresponds to a whole *scale
window* of hypotenuse sizes. The geometry of the boundary literally measures the
arithmetic of the triangles.

## A complex-number bridge

There is one more thread, and it reaches into the complex numbers. Every primitive
Pythagorean triple can be written using two whole numbers `m` and `n` as
`(m² − n², 2mn, m² + n²)`. That is no accident: it is exactly what you get by
**squaring the complex number m + n·i**, where `i` is the square root of −1. The
real part of `(m + n i)²` is `m² − n²`, the imaginary part is `2mn`, and the
*size* (the squared modulus) of `m + n i` is `m² + n²` — which is precisely the
hypotenuse. Right triangles are squares of Gaussian integers, the whole-number
grid of the complex plane.

This gives the boundary ruler a multiplicative companion. The Gaussian "size"
function is multiplicative: the size of a product is the product of the sizes.
Multiplicativity on the arithmetic side and the min-plus disagreement law on the
geometric side fit together into a single structure — the same abstract gadget,
viewed two ways. The size function reading off hypotenuses, and the
first-disagreement ruler reading off tree depth, are two faces of one
"valuation," and one can be reconstructed from the other. Arithmetic and geometry
turn out to be the same data wearing different clothes.

## Why this is more than a curiosity

The ingredients here — a self-similar tree, an ultrametric boundary, a min-plus
law, a multiplicative norm — are exactly the ingredients of some of the most
active areas of modern mathematics. Ultrametric spaces are how number theorists
think about the p-adic numbers; how biologists encode evolutionary trees, where
the distance between two species is set by their most recent common ancestor; how
computer scientists organize hierarchical data and nearest-neighbor search.
Min-plus (tropical) arithmetic is the backbone of shortest-path algorithms,
scheduling, and a whole "tropical geometry" that linearizes hard nonlinear
problems. And the bridge to Gaussian integers is a doorway from elementary
triangle arithmetic into the rich world of algebraic number theory.

What makes the Pythagorean story special is that all of these ideas appear at once,
in their cleanest possible form, anchored to an object every schoolchild meets:
the 3-4-5 triangle. The infinite family of right triangles is not a heap. It is a
tree. The tree has a boundary. The boundary has a ruler. The ruler obeys the law
of the most-recent-common-ancestor. And that law, in turn, is the geometry of
trees, the arithmetic of the tropics, and the algebra of the complex plane, all
speaking with one voice.

Three thousand years after someone first noticed that 3² + 4² = 5², the humble
right triangle still has secrets to give up — and they look, of all things, like
a fractal.
