# The Shape of Change: How One Straight Line Knows All of Its Pieces

Imagine you are watching a cloud of points slowly morph from one arrangement into
another — a swarm of starlings rearranging itself, a protein folding, a network of
friendships rewiring over a decade. At every instant the cloud has a *shape*: not
just where the points are, but how they cluster, what loops they enclose, what
voids they surround. Mathematicians have learned to summarize that shape in a
remarkably stable fingerprint. The technology is called **persistent homology**,
and over the last twenty years it has quietly become one of the most powerful tools
for finding structure in messy, high-dimensional data.

This article is about a small but beautiful piece of the theory of how those
fingerprints *change* — and about a single equation that turns out to be the secret
keeping a whole family of changes honest with one another.

## Fingerprints of shape, and the distance between them

Start with the fingerprint. To a data scientist, a "shape" is captured by a
**filtration**: a rule that tells you, for every possible cluster of data points
(every *simplex*, in the jargon — an edge between two points, a triangle among
three, a tetrahedron among four, and so on), the *scale* at which that cluster first
appears. As you dial a single knob — call it the scale, or the resolution, or the
"time" — more and more clusters switch on. Small, tight groups appear first; loose,
sprawling ones appear later. The record of *when* each feature is born and dies is
the persistence fingerprint.

Formally, a filtration is just a function `w` that assigns to each finite set of
data points `σ` a real number `w(σ)`, the birth scale of that simplex. Two rules
make it sensible:

- **Grounding:** the empty set is born at the beginning, `w(∅) ≤ 0`.
- **Monotonicity:** if one cluster sits inside a bigger one (`σ ⊆ τ`), then the
  smaller one is born no later than the bigger one, `w(σ) ≤ w(τ)`.

That's it. A filtration is a *grounded, monotone weight function*.

Now, the entire point of persistence is that the fingerprint is **stable**: if you
nudge the data a little, the fingerprint moves only a little. To make that precise
you need a *distance* between two filtrations `F` and `G`. The natural one is called
the **interleaving distance**, written `d(F, G)`. Its definition is subtle — it asks
for the smallest scale-shift `δ` so that everything born in `F` by scale `t` is born
in `G` by scale `t + δ` and vice versa — but a beautiful theorem (one of the earlier
results in this research arc) collapses all that subtlety into something you can
almost compute by hand:

> **The interleaving distance is a supremum of pointwise gaps.**
> `d(F, G) = sup over all clusters σ of |F.weight(σ) − G.weight(σ)|.`

In words: to compare two shape-fingerprints, walk over every possible cluster, ask
how differently the two filtrations date its birth, and take the worst case. The
distance is the largest disagreement, anywhere. This is the "isometry" that makes
everything downstream tractable: the abstract relational definition becomes an
honest sup-norm.

## A straight line between two shapes

Here is where the story becomes geometric. If `F` and `G` are two filtrations, is
there a *path* between them — a continuous movie of intermediate shapes that morphs
`F` into `G`? And among all such paths, is there a *straightest possible* one, a
geodesic, that gets from `F` to `G` without wasting a single inch of distance?

The answer is yes, and it is almost embarrassingly simple. Just **average the two
filtrations**, weighting the average by a dial `t` running from `0` to `1`:

> **`lerp F G t`** is the filtration whose birth-scale for each cluster `σ` is
> `(1 − t)·F.weight(σ) + t·G.weight(σ).`

(The name `lerp` is borrowed from computer graphics, short for "linear
interpolation.") At `t = 0` you get back `F`; at `t = 1` you get `G`; in between you
get a genuine new shape — a perfectly valid filtration, because a weighted average
of two grounded, monotone functions is still grounded and monotone. As `t` slides
from `0` to `1`, the shape continuously transforms.

And it travels at *constant speed*. The previous bridge in this research arc proved
the constant-speed geodesic identity:

> **`d(lerp F G s, lerp F G t) = |s − t| · d(F, G)`.**

Read that carefully: the distance between two snapshots of the movie is *exactly*
proportional to how far apart their dial settings are. Not "at most" — *exactly*.
Move the dial halfway and you have traveled exactly half the distance. The path is a
true geodesic, the shortest route between two shapes, and it never dawdles or
sprints. This is the launching point for the result described here.

## The keystone: a straight line is made of straight lines

Now ask a question that sounds almost too obvious to be interesting. Take the
geodesic from `F` to `G`. Pick two intermediate snapshots on it — say the one at
dial setting `s` and the one at dial setting `t`. Draw the geodesic *between those
two snapshots*. Where does it go?

If geodesics are to deserve their name, the answer had better be: **it lies along
the original line.** The shortest path between two points on a straight road should
be a stretch of that same road. If it veered off, the geometry would be incoherent —
the "straight line" would not actually be straight when you zoomed in.

The keystone theorem of this work — call it the **affine gluing law** — proves
exactly this, as a clean algebraic identity:

> **`lerp (lerp F G s) (lerp F G t) r = lerp F G ((1 − r)·s + r·t)`.**

Unpack it. On the left, you build a new geodesic whose endpoints are themselves two
points on the original geodesic, and you slide *its* dial to `r`. On the right, you
slide the *original* dial to the value `(1 − r)·s + r·t` — which is just the point a
fraction `r` of the way from `s` to `t`. The two sides are **the same filtration**.
The geodesic between two points on a geodesic *is* the original geodesic, merely
relabeled.

This is the mathematical content of "local-to-global coherence." A single global
line restricts consistently to every one of its sub-segments. In the language of
sheaves — the bookkeeping device geometers use to glue local data into global data —
this is the gluing axiom itself. The geodesic is not a collection of disconnected
shortcuts; it is one self-consistent object that looks the same at every scale of
magnification. And, satisfyingly, the proof is pure arithmetic: expand both sides,
collect the coefficient of `G` (it is `(1−r)s + rt` on both sides) and the
coefficient of `F` (it is `1 − ((1−r)s + rt)` on both sides), and they match. No
analysis, no limits — just the algebra of averaging averages.

## What the keystone buys you

Once the gluing law is in hand, a cascade of geometric facts falls out, each a
direct consequence of one humble principle: **distances along the line add up like
lengths on a ruler.** Because the distance from dial `s` to dial `t` is exactly
`|s − t|` times the total `d(F, G)`, the geodesic behaves like a tape measure with
`F` at `0` and `G` at the far end.

**Distance to the far endpoint.** The distance from the snapshot at dial `t` to the
destination `G` is
> `d(lerp F G t, G) = (1 − t)·d(F, G).`
A snapshot three-quarters of the way along has one quarter of the journey left.
Obvious for a ruler; now proven for the space of shapes.

**Betweenness is an equation, not an inequality.** In any metric space the triangle
inequality says `d(a, c) ≤ d(a, b) + d(b, c)` — going through a waypoint is never
shorter. On a geodesic, when the waypoint genuinely lies between, the inequality
becomes an *equality*. For three ordered dial settings `s ≤ u ≤ t`:
> `d(lerp s, lerp u) + d(lerp u, lerp t) = d(lerp s, lerp t).`
The middle snapshot loses nothing. It is exactly, provably, *between* the other two —
the additive structure of the interval `[0, 1]` faithfully transported into the
geometry of shapes.

**Every interior point bisects the journey.** A special, universal case: for *any*
dial setting `t`,
> `d(F, lerp F G t) + d(lerp F G t, G) = d(F, G).`
The first stretch plus the last stretch equals the whole. The previous bridge had
proved this only for the exact midpoint, `t = ½`; here it holds for the entire
continuum of intermediate shapes, which is the very definition of a constant-speed
geodesic — no point on it is a detour.

**Speeds multiply when you nest.** Finally, if you build a geodesic *inside* a
geodesic — interpolating between `lerp F G s` and `lerp F G t` at rate `a` and `b` —
the distances multiply cleanly:
> `d(...) = |a − b| · (|s − t| · d(F, G)).`
A sub-journey covering fraction `|s − t|` of the line, traversed at fraction
`|a − b|`, covers the product of the fractions. Reparametrization composes exactly,
the way gears multiply ratios.

## Why this matters beyond the equation

It is tempting to dismiss all of this as "obvious facts about straight lines." But
the points on these lines are not numbers or vectors — they are **entire shapes of
data**, living in a space with no coordinates, no inner product, no built-in notion
of "between." The interleaving distance is defined by an infimum over scale-shifts
and only *afterwards* revealed to be a supremum over clusters. That such an exotic
space turns out to be geodesic — and not merely geodesic, but *coherently* geodesic,
with every sub-line agreeing with the whole — is genuinely surprising, and it is the
kind of structure that unlocks further theory.

Three doors swing open. First, **interpolation of data**: given two shapes, the
geodesic gives a principled, distance-optimal morph between them — a "shape average"
you can compute, useful for animation, for filling gaps in time-series of shapes,
for regularizing noisy measurements. Second, **a homotopy theory of data**: with a
coherent notion of paths that compose, one can start asking whether the space of
shapes has holes of its own, building a "fundamental groupoid" whose objects are
filtrations and whose morphisms are geodesics — a shape-space *of* shape-spaces.
Third, **obstruction theory**: the fact that betweenness is an exact equation, not a
mere inequality, means one can ask precisely when a whole family of shapes, in a
prescribed order, can be threaded onto a single global geodesic — and measure the
failure with the tools of cohomology, exactly as one measures when local patches
refuse to glue.

## The moral

The deepest results in mathematics are often the ones that prove the obvious — but
prove it in a place where "obvious" had no right to hold. Here, in a space whose
points are the shapes of data sets, we have shown that straight lines are made of
straight lines: that a geodesic between two points of a geodesic is the same
geodesic, and that as a consequence distances add and multiply along it exactly as
they do on a child's ruler. One short algebraic identity — averaging an average is
averaging — turns out to carry the entire geometric coherence of the space on its
back.

The shape of change, it turns out, knows all of its own pieces.
