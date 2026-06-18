# The Shape of Distortion: How Maps Bend Fractals Without Breaking Their Dimension

## A number that survives stretching

Imagine you hand a coastline to a cartographer who is allowed to stretch, squeeze,
and warp the map however they like — but with one rule: nowhere are they allowed
to crush two distinct points onto the same spot, and nowhere are they allowed to
blow distances up infinitely or collapse them to zero. Their distortion is bounded.
After all their warping, you compare the original coastline to the new one. Has
anything survived the abuse?

Surprisingly, yes. There is a single number attached to the coastline — its
**Hausdorff dimension** — that the cartographer cannot change, as long as their
distortion stays bounded both ways. The coastline of Britain has a Hausdorff
dimension of roughly 1.25; it is "more than a line but less than a filled-in
region." No amount of bounded, two-sided stretching can turn that 1.25 into a 1.30.
The number is an invariant. It is, in a precise sense, the fingerprint of the
fractal.

This article is about a piece of mathematics that pins down *exactly when* and
*exactly how* such warping preserves — or controllably distorts — that fingerprint.
And it is about a subtle but crucial generalization: what happens when the
cartographer behaves well only on **part** of the map?

## What is dimension, really?

We learn in school that a line is one-dimensional, a square two-dimensional, a cube
three-dimensional. That intuition works for smooth, tidy shapes. But the world is
not tidy. A coastline, a lightning bolt, a snowflake's edge, the branching of a
lung, the cratered surface of the moon — these are *rough*. They wiggle at every
scale. Zoom in on a coastline and you find smaller bays nested inside bigger bays,
forever. Such an object is somehow "thicker" than a line but "thinner" than a
region.

Hausdorff dimension captures this with a beautiful idea. To measure the size of a
set, cover it with tiny balls of radius `r`, and ask: how does the number of balls
you need grow as `r` shrinks? For a line segment, halving the ball size doubles the
count — that scaling exponent is `1`. For a square, halving the ball size
quadruples the count — exponent `2`. For a coastline, you might find the count
grows like `r^{-1.25}`, and we say its dimension is `1.25`. Fractals are precisely
the objects whose dimension is not a whole number.

The Hausdorff dimension, written `dimH S`, makes this rigorous by measuring the
"critical exponent" at which the set transitions from having infinite measure to
zero measure. It is one of the central invariants of modern geometry.

## The cartographer's rulebook: Lipschitz and beyond

To talk about "bounded distortion" precisely, mathematicians use the language of
**Lipschitz maps**. A map `f` is *Lipschitz* with constant `K` if it never
stretches distances by more than a factor of `K`:

> `distance(f(x), f(y)) ≤ K · distance(x, y)` for all points `x, y`.

A Lipschitz map cannot tear or explode the space — it is a controlled deformation.
A foundational fact is that **Lipschitz maps never increase Hausdorff dimension**.
Squeezing things can only make them simpler, never more complex.

The mirror image is the **antilipschitz** (or co-Lipschitz) condition: a map that
never *contracts* distances by more than a factor `K`:

> `distance(x, y) ≤ K · distance(f(x), f(y))` for all points `x, y`.

An antilipschitz map cannot collapse the space; it keeps points spread apart. And
the mirror fact holds: **antilipschitz maps never decrease Hausdorff dimension.**

Put the two together — a map that is both Lipschitz and antilipschitz is called
**bi-Lipschitz** — and you get the cartographer of our opening parable: bounded
distortion in both directions. Such a map is forced to preserve Hausdorff dimension
*exactly*. This is the precise statement of "the fingerprint survives."

## The catch: real fractals are only well-behaved locally

Here is where the textbook story runs out. The classical theorems above are
**global**: they demand good behavior *everywhere*, at every pair of points in the
entire space. But the objects mathematicians actually care about — the attractors of
iterated function systems, the boundaries of fractal sets, the images under
quasi-symmetric maps — rarely cooperate everywhere. They cooperate only on the
*relevant piece*, the subset `s` where the action happens.

A map might stretch wildly near the edges of a region but behave perfectly on the
fractal sitting in the middle. The global theorems are silent here. They simply do
not apply. What you need is a **set-local** theory: invariance and distortion
results that ask only for good behavior on the subset `s`, and conclude something
about the image of `s`.

This is exactly the gap that the mathematics described here fills. It rebuilds the
entire chain of dimension-distortion results from the ground up, demanding control
only on a subset, and it introduces the right local vocabulary to state them
cleanly.

## The four pillars

The theory rests on four results, each strengthening a global classic into a
set-local one. Let me state them plainly.

### Pillar 1: A good inverse forces dimension up

Suppose `f` maps a set `s` somewhere, and suppose there is a partner map `g` that
**undoes** `f` on `s` — formally, `g(f(x)) = x` for every `x` in `s` — and suppose
this partner `g` is Lipschitz on the image `f(s)`. Then:

> **`dimH s ≤ dimH (f(s))`.**

The image cannot be simpler than the original. The intuition is clean: because `g`
is a Lipschitz left inverse, applying it to the image `f(s)` recovers `s` exactly,
and since Lipschitz maps don't increase dimension, the dimension of the image must
have been at least as large as the dimension of `s` to begin with. A good inverse is
a witness that no complexity was lost.

### Pillar 2: Set-local bi-Lipschitz invariance

Now combine the two directions. If `f` is Lipschitz on `s` (so it can't raise the
dimension) **and** it has a Lipschitz inverse `g` on `f(s)` (so by Pillar 1 it
can't lower it either), then the dimension is trapped from both sides:

> **`dimH (f(s)) = dimH s`.**

This is the local cartographer's theorem. Bounded distortion in both directions,
*even if only on the piece `s`*, preserves the fractal fingerprint exactly. This is
the workhorse for proving that two fractals are "the same size" by exhibiting a
two-sided bounded deformation between them.

### Pillar 3: The two-sided Hölder squeeze

What if the distortion is not Lipschitz but something rougher? Many natural maps —
the coding maps of fractal attractors, the building blocks of quasi-symmetric
geometry — satisfy a weaker condition called a **Hölder estimate**. A map is Hölder
with exponent `r` (where `0 < r ≤ 1`) if

> `distance(f(x), f(y)) ≤ C · distance(x, y)^r`.

When `r = 1` this is just Lipschitz; when `r < 1`, the map is allowed to stretch
small distances much more aggressively, and such maps genuinely *change* dimension.
The remarkable thing is that the change is *quantitatively controlled*. If `f` is
Hölder with exponent `rf > 0` on `s`, and its inverse `g` is Hölder with exponent
`rg > 0` on the image, then the dimension is squeezed:

> **`dimH (f(s)) ≤ dimH s / rf`** and **`dimH s ≤ dimH (f(s)) / rg`.**

This single statement interpolates the entire spectrum. At `rf = rg = 1` it collapses
to the exact invariance of Pillar 2. For smaller exponents it gives explicit
"distortion bars" on how far the dimension can drift. This is the dimension-theoretic
heart of *quasi-symmetric distortion* — the phenomenon that powers the theory of
**conformal dimension**, where one asks how much a fractal's dimension can be reduced
by warping it.

### Pillar 4: The right local vocabulary — `AntilipschitzOnWith`

To make Pillars 1–3 sing, the theory introduces a new predicate, the set-local
analogue of the antilipschitz condition:

> **`AntilipschitzOnWith K f s`** means: for all `x, y` in `s`,
> `distance(x, y) ≤ K · distance(f(x), f(y))`.

This compact definition packs a punch. From it alone, three things follow
automatically:

1. **Injectivity on `s`.** If `f(x) = f(y)`, the right-hand side is zero, forcing
   `distance(x, y) = 0`, so `x = y`. A map that doesn't contract distances cannot
   glue points together.

2. **A canonical Lipschitz inverse.** Because `f` is injective on `s`, it has a
   well-defined inverse on `f(s)`, and the antilipschitz bound is *exactly* the
   statement that this inverse is Lipschitz with the same constant `K`.

3. **The lower bound for free.** Feeding that canonical inverse into Pillar 1 gives
   `dimH s ≤ dimH (f(s))` — the set-local version of the classical "antilipschitz
   maps don't decrease dimension."

And finally, the cleanest form of the invariance theorem: if `f` is *both* Lipschitz
on `s` and `AntilipschitzOnWith` on `s`, then `dimH (f(s)) = dimH s`. No external
inverse needs to be supplied — the antilipschitz condition manufactures its own.

## Why this matters

These results are not abstract for abstraction's sake. They are precisely the tools
the modern study of fractal geometry has been asking for.

**Iterated function systems.** The Sierpiński triangle, the Cantor set, the Koch
snowflake, Barnsley's fern — all are *attractors* of iterated function systems
(IFS): finite collections of contracting maps whose repeated application converges to
a fractal. The dimension of such an attractor is governed by a famous formula
involving the contraction ratios. The standard proof routes through a **coding map**
from an abstract sequence space onto the fractal — a map that is Hölder, and, under a
geometric hypothesis called the *open set condition*, has a Hölder inverse on a large
piece. Pillar 3, the two-sided Hölder squeeze, is *exactly* the engine that turns
that coding map into the dimension formula.

**Quasi-symmetric maps and conformal dimension.** Quasi-symmetric maps generalize
bi-Lipschitz maps by letting the distortion vary with scale. They are the natural
maps of *conformal geometry* on fractals, and unlike bi-Lipschitz maps they can
genuinely change dimension. The smallest dimension a fractal can be warped down to,
over all quasi-symmetric deformations, is its **conformal dimension** — a deep
invariant studied in connection with hyperbolic groups and the geometry of
boundaries. The bi-Lipschitz invariance of Pillar 2 is the special case (linear
modulus) that anchors the whole quasi-symmetric edifice; the conformal dimension is
"what remains after you quotient out by quasi-symmetric sameness."

**The honest subtlety.** It would be tempting to guess that *any* nice map can only
shrink dimension. That guess is **false**, and beautifully so. Quasi-symmetric maps
really do change dimension — and the fact that they do is the entire reason conformal
dimension is an interesting and hard invariant rather than a triviality. The
two-sided Hölder squeeze is the precise accounting of how much change is possible.

## The art of the local

If there is a single lesson in this work, it is the power of *localization*. A
theorem that demands perfect behavior everywhere is brittle: the moment one corner of
your space misbehaves, the theorem evaporates. A theorem that demands good behavior
only on the subset you care about is robust: it survives contact with the messy,
realistic objects of actual mathematics.

Fractals are messy by nature. They are defined by self-similarity that holds across
scales but interacts unpredictably with any particular coordinate system. The
set-local theory of dimension distortion meets them on their own terms. It says: tell
me how your map behaves *on the fractal*, and I will tell you precisely what happens
to its dimension — whether it is preserved exactly, or distorted within sharp,
explicit bounds.

The coastline survives the cartographer. The Cantor set's `log 2 / log 3` is etched
into it permanently. And now we have the local, scale-aware toolkit to prove it — not
just for the tidy global maps of the textbook, but for the rough, partial, real maps
of the fractal world.

That number — that stubborn, fractional, immovable fingerprint — turns out to be one
of the most durable things in mathematics. And understanding exactly what it takes to
move it, or to keep it still, is understanding the very shape of distortion itself.
