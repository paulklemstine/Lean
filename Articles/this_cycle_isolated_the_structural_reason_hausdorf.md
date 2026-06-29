# The Shape of Dimension: Why Fractals Don't Care How You Look at Them

## A number that survives every distortion

Hold a coastline in your mind. Zoom in on a rocky inlet and you find smaller
inlets; zoom in on those and you find smaller ones still. The coastline never
smooths out into a tidy line, and it never fills up a patch of the plane. It
lives somewhere *in between* — and mathematicians have a number for that
in-between-ness. They call it the **Hausdorff dimension**.

A smooth curve has dimension 1. A filled square has dimension 2. A coastline,
or the famous Cantor "dust," or a snowflake's crinkled boundary, sits at a
*fractional* value — 1.26, or 0.63, or 1.5 — a single number that captures how
roughly a set crowds into space.

Here is the question that this article is about, and it is more subtle than it
first appears: **if you stretch, squeeze, tilt, slide, or otherwise reshape a
fractal, does its dimension change?**

Intuitively, you'd hope not. Photographing a coastline from a different angle,
or printing the map at a different scale, shouldn't alter how rough the
coastline *is*. Roughness feels like an intrinsic property of the thing itself,
not of the lens you happen to view it through. The central result we'll explore
makes that hope into a theorem — and, just as importantly, it tells you exactly
when the hope *fails*.

## What "reshaping" really means

To make the question precise we need to say what counts as a legitimate
reshaping. The key idea is to control how a map can distort *distances*.

A map `f` is called **Lipschitz** with constant `K` if it never stretches any
distance by more than a factor of `K`:

> for all points `x` and `y`,  `dist(f(x), f(y)) ≤ K · dist(x, y)`.

Lipschitz maps are the "no sudden tearing" maps. They can shrink things, they
can stretch things by a bounded amount, but they can't blow a finite gap up to
infinity. Crucially, a Lipschitz map can *collapse* distances — it can squash
two far-apart points right on top of each other.

To forbid that collapsing, we add a second condition. A map `f` is
**antilipschitz** with constant `K'` if it never *shrinks* distances by more
than a bounded factor:

> for all points `x` and `y`,  `dist(x, y) ≤ K' · dist(f(x), f(y))`.

An antilipschitz map keeps things that are apart, apart. Combine the two and
you get a **bi-Lipschitz** map: one that is simultaneously Lipschitz and
antilipschitz, so distances are pinned between two fixed multiples of their
originals,

> `(1/K') · dist(x, y) ≤ dist(f(x), f(y)) ≤ K · dist(x, y)`.

A bi-Lipschitz map is the mathematical version of "reshaping without tearing
and without crushing." It can bend a rubber sheet, but it can't rip it and it
can't pinch any region down to a point.

## The centerpiece

The heart of this work is a single clean statement:

> **Bi-Lipschitz invariance of Hausdorff dimension.** If `f` is bi-Lipschitz,
> then for *every* set `s`, the reshaped set `f(s)` has exactly the same
> Hausdorff dimension as `s`.

In symbols, `dimH(f(s)) = dimH(s)`.

What makes this beautiful is not just that it's true, but how *little* it asks.
Mathematicians already knew two special cases. They knew dimension is preserved
by **isometries** — rigid motions that keep every distance exactly the same,
like rotations and reflections. And they knew it's preserved by invertible
**linear** maps that are continuous both ways. Both of these are famous, useful
facts.

But notice: an isometry preserves distances *exactly*, and a linear map carries
a rigid algebraic structure. The theorem above throws all of that away. It
doesn't ask the map to preserve any distance. It doesn't ask the map to respect
addition or scaling. It doesn't even ask the map to be onto. It asks only that
distances stay trapped between two fixed multiples — and that turns out to be
the entire reason dimension is preserved. Both older theorems fall out as
immediate corollaries of this one weaker hypothesis.

The proof is almost suspiciously short, and worth seeing in outline because it
reveals the mechanism. Hausdorff dimension is built from *covers*: you blanket
your set with tiny pieces and track how the total "size" of the cover scales as
the pieces shrink. A Lipschitz map can only shrink the pieces of a cover, so it
can never *increase* the dimension: `dimH(f(s)) ≤ dimH(s)`. An antilipschitz
map runs the same argument backward — because it can't crush distances, it
can't lose any of the fine structure, so it can never *decrease* the dimension:
`dimH(f(s)) ≥ dimH(s)`. Trap a number between `≤` and `≥` and it is forced to be
equal. The two halves of "bi-Lipschitz" are precisely the two halves of the
sandwich.

## The two halves do different jobs

That sandwich structure has a punchline that's easy to miss: the upper bound
and the lower bound are doing genuinely different work, and you can't drop
either one.

Consider the most boring map imaginable: the **constant map**, which sends every
single point of the real line to one fixed location `a`. Is it Lipschitz? Yes —
gloriously so. It never stretches anything; you can take its Lipschitz constant
to be `K = 0`. But it is the opposite of antilipschitz: it takes the entire
line, an object of dimension 1, and crushes it down to a single point, an object
of dimension 0.

> **The constant map collapses dimension.** The image of the real line under a
> constant map is a single point, so its dimension drops strictly from 1 to 0.

This humble example is the proof that antilipschitzness is *not optional*. It is
the irreducible half of the hypothesis — the half that guards against collapse,
the half responsible for the lower bound. Lipschitz alone lets you destroy a
fractal; you need the antilipschitz condition to protect it.

## Harvesting the consequences: scaling, sliding, and the whole affine group

Once you have the centerpiece, a cascade of geometric facts falls into your lap
for free, because the most common reshapings are all bi-Lipschitz.

**Scaling.** Multiply every point of a set by a nonzero number `c` — zoom in or
zoom out. Zooming is Lipschitz (with constant `|c|`) and, because `c ≠ 0`, its
inverse zoom is too, which makes it antilipschitz (with the tight constant
`1/|c|`). So scaling is bi-Lipschitz, and:

> **Scale invariance.** For any nonzero `c`, the scaled set `c·s` has the same
> Hausdorff dimension as `s`.

This is the deep reason a fractal's dimension is a *scale-free ratio*. A
self-similar fractal is built from shrunken copies of itself, and dimension
can't tell the copies from the original. That's why the dimension of such a set
comes out as a pure logarithm ratio, `log N / log(1/r)` — `N` pieces, each
scaled by `r` — with no units and no preferred magnification.

**Sliding.** Translating a set — sliding it bodily by a vector `a` — is an
isometry: it keeps every distance exactly the same. So it certainly preserves
dimension.

> **Translation invariance.** Sliding a set by any vector leaves its Hausdorff
> dimension unchanged.

**Putting them together: the affine group.** An invertible affine map is exactly
a scaling followed by a slide: `x ↦ c·x + a` with `c ≠ 0`. Chain the two
results above and you get the grand consequence:

> **Affine invariance.** Every invertible affine map `x ↦ c·x + a` preserves
> Hausdorff dimension.

Dimension is therefore an invariant not just of rigid motions, and not just of
linear maps, but of the *entire affine group*: stretch, shear, slide, flip — the
roughness number doesn't budge.

## A surprising trip into the prime numbers

Here is where the story takes an unexpected turn, from geometry into number
theory.

Take the prime numbers `2, 3, 5, 7, 11, …` and build a set of points on the
real line by the recipe `1/log p` — one over the natural logarithm of each
prime. As the primes march off to infinity their logarithms grow, so these
points pile up toward zero, getting denser and denser near the origin. They form
a genuine fractal-looking dust, the **prime fractal**. A natural question:
what is its Hausdorff dimension?

The answer is `0`. And there's a clean reason: the set is **countable** — you can
list its points one by one — and any countable set has Hausdorff dimension 0. A
countable scatter of points, no matter how cleverly arranged, is simply too thin
to register any positive roughness.

But a skeptic might object: *maybe the dimension is 0 only because of the
particular `1/log` lens you chose to view the primes through. Pick a different
embedding and perhaps the dust would thicken into something positive-dimensional.*

The bi-Lipschitz theorem answers the skeptic decisively. Because dimension
survives every bi-Lipschitz reshaping, and because a countable set stays
countable no matter how you reshape it, we get:

> **Robustness of zero dimension.** Any bi-Lipschitz reshaping of a countable
> set still has dimension 0.

We can sharpen this to the prime fractal's own neighborhood. Consider the larger
**logarithmic integer fractal** `{1/log n : n ≥ 2}`, which contains the prime
fractal as a subset. It, too, is countable, so it has dimension 0 — and that 0
is bulletproof under any bi-Lipschitz change of coordinates. Rescale it by 5,
tilt it, slide it, bend it without tearing: dimension stays 0. The conclusion is
philosophical as much as mathematical: the prime fractal's zero dimension is an
*intrinsic* property of the primes' sparseness, not an artifact of the chart we
drew it on.

## When stretching is allowed to misbehave: the Hölder world

Bi-Lipschitz maps are the gold standard, but the framework gracefully degrades.
What if a map is allowed to stretch *more violently* near some points — not by a
bounded factor, but by a power law?

A map is **Hölder** with exponent `r` (between 0 and 1) if

> `dist(f(x), f(y)) ≤ C · dist(x, y)^r`.

When `r = 1` this is just Lipschitz. When `r < 1` the map can stretch small
distances disproportionately — the square-root function `√x` near zero is the
classic example, with `r = 1/2`. Hölder maps are wilder, and they are *allowed*
to inflate dimension. But not without limit:

> **Hölder distortion bound.** A Hölder-`r` map can increase Hausdorff dimension
> by at most the factor `1/r`:  `dimH(f(s)) ≤ dimH(s) / r`.

Setting `r = 1` recovers the upper-bound half of the bi-Lipschitz theorem,
showing the whole story lives on a single dial. Turn the regularity dial down
from 1 and dimension is allowed to swell by a controlled amount; turn it up to
1 and dimension is locked in place. The bi-Lipschitz invariant is the rigid
center of a flexible family.

## Why this matters

It is easy to admire fractal pictures; it is harder to say precisely what about
them is *real*. The bi-Lipschitz invariance theorem draws that line. It says:
the dimension of a set is a property of the set's intrinsic geometry, immune to
the enormous group of distortions that don't tear or crush. That is exactly the
license a working scientist needs.

A geologist measuring the roughness of a coastline doesn't have to worry that a
different map projection will report a different fractal dimension — projections
are (locally) bi-Lipschitz, so the number is safe. A physicist studying the
strange attractor of a chaotic system can change coordinates freely, confident
that the attractor's dimension — a fingerprint of the underlying dynamics —
won't be an accident of bookkeeping. An image analyst comparing the texture of
two materials by their fractal dimension is comparing something genuine, not an
artifact of resolution or framing.

And the theory is honest about its own boundaries. The constant map shows you
can destroy dimension if you allow collapse; the Hölder bound shows you can
inflate dimension if you allow power-law stretching. In between sits the
bi-Lipschitz regime, where dimension is exactly, provably, perfectly preserved.

The grand lesson is one of the recurring joys of mathematics: a tangle of known
results — dimension is preserved by rotations, by reflections, by linear
isomorphisms, by scaling, by translation, by the whole affine group — turns out
to be the shadow of a single, simpler truth. Don't preserve distance. Don't
preserve structure. Just don't tear and don't crush. Do that much, and the
roughness of a fractal travels with it, unchanged, wherever you take it.
