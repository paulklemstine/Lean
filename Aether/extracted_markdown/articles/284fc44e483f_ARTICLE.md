# The Shape of Change: How Data Shapes Travel Along Straight Lines

## A world of shapes hiding inside numbers

Imagine you scatter a handful of points across a tabletop — sensor readings, the
pixels of a galaxy, the genes that switch on inside a cell. At first glance there
is no shape at all, only a cloud of dots. But shape is patient. If you let each
point grow into a tiny disk, and then let those disks swell larger and larger,
something remarkable happens: the disks begin to touch, then overlap, then fuse.
Holes open up between them, persist for a while as the disks grow, and finally
close. A doughnut-shaped cloud reveals its hole; two separated clusters reveal the
gap between them.

This is the central idea of *topological data analysis*. Instead of asking "what
does this data look like at one fixed resolution?", we ask "how does its shape
evolve as we change the resolution?" The answer is a kind of biography — a record
of every feature (every connected piece, every loop, every cavity) together with
the exact moment it was born and the exact moment it died. The biography is robust:
small wiggles in the data produce only small changes in the story. That robustness
is what makes the method trustworthy in the presence of noise, and it is the reason
topological data analysis is now used to study everything from the folding of
proteins to the large-scale structure of the cosmos.

The bookkeeping device that records this growing-disk process is called a
**filtration**. This article is about a surprisingly beautiful geometric fact:
the *space of all filtrations* is itself a geometric object — a space in which you
can measure distances, draw straight lines, and even speak of "curvature." And the
straight lines, it turns out, are not just metaphors. They are honest geodesics,
the shortest possible paths, and they behave with a precision that would make a
Euclidean geometer smile.

## What is a filtration, really?

Strip away the pictures and a filtration is a simple thing. You have a collection
of possible "simplices" — points, edges, triangles, tetrahedra, and their
higher-dimensional cousins, each one just a finite set of vertices. To each such
simplex you assign a single number: the *scale at which it is born*. We call this
number its **weight**.

There are only two rules. First, the empty simplex (the trivial "nothing" shape)
should already exist before we start, so its weight is at most zero. Second — and
this is the heart of the matter — a face must be born no later than any larger
shape that contains it. You cannot have a triangle before you have its three edges.
This single condition, **monotonicity**, is what guarantees that as you turn the
resolution dial, shapes only ever appear, never vanish and reappear. Formally, a
filtration `F` is a function `weight` from finite sets of vertices to real numbers
satisfying:

- `weight(∅) ≤ 0` (the empty simplex is born by scale zero), and
- if `σ ⊆ τ` then `weight(σ) ≤ weight(τ)` (faces are born first).

That is the entire definition. Everything that follows is squeezed out of these two
modest rules.

## Measuring the distance between two shapes-in-the-making

Suppose you have two filtrations, `F` and `G` — perhaps the same experiment run on
two different days, or a true signal versus a noisy measurement. How different are
they? The classical answer, the *interleaving distance*, asks: by how much do I
have to shift the resolution dial of one filtration so that its growing complex is
always sandwiched inside the other's, and vice versa? The smallest such shift `δ`
is the distance. Two filtrations are **δ-interleaved** when, for every scale `t`,
everything alive in `F` at scale `t` is alive in `G` by scale `t + δ`, and the
reverse holds too. The **interleaving distance** is the infimum of all valid `δ`.

This definition is elegant but slippery to compute — it quantifies over every
possible scale at once. Here a clean miracle rescues us. One can prove that the
interleaving distance is *exactly* the largest disagreement between the two weight
functions, simplex by simplex:

> **The isometry theorem.** The interleaving distance between `F` and `G` equals
> the supremum, over all simplices `σ`, of `|weight_F(σ) − weight_G(σ)|`.

In words: to compare two filtrations you do not need to slide resolution dials at
all. You simply look at each simplex, see how far apart its two birth-times are,
and take the worst case. The abstract interleaving distance collapses into a plain
"largest coordinate-wise gap" — the so-called supremum distance. This is more than
a computational convenience; it tells us that the space of filtrations sits
*isometrically* inside an ordinary space of functions, the way a flat sheet of
paper sits inside three-dimensional space without any stretching or wrinkling.

## Drawing a straight line between two shapes

Once you can measure distance, the next natural question is: can you *travel*? Given
two filtrations `F` and `G`, is there a continuous path of filtrations that begins
at `F`, ends at `G`, and never wastes a step — a genuine shortest path?

The answer is yes, and the construction is the most natural thing imaginable. Blend
the two weight functions. For any blending fraction `t` between 0 and 1, define a
new filtration `lerp(F, G, t)` — "linear interpolation" — whose weight on each
simplex `σ` is the weighted average

> `weight(σ) = (1 − t) · weight_F(σ) + t · weight_G(σ)`.

At `t = 0` this is exactly `F`; at `t = 1` it is exactly `G`; and in between it is a
gradual morph from one shape-biography into the other. Crucially, the blend is still
a *legitimate* filtration: averaging two monotone, grounded weight functions with
nonnegative coefficients keeps both properties intact. (This is precisely why we
demand `0 ≤ t ≤ 1`: stray outside that interval and a positive coefficient on a
negative endpoint can flip a sign and break the rules. The path is a genuine
*segment*, not an infinite line.)

And here is the payoff that makes the line "straight." As you slide `t` along the
path, the interleaving distance grows at a perfectly constant rate:

> **The constant-speed law.** The distance between two points `lerp(F,G,s)` and
> `lerp(F,G,t)` on the path equals `|s − t|` times the total distance from `F` to
> `G`.

Travel a tenth of the way and you have covered exactly a tenth of the distance.
This is the defining property of a *constant-speed geodesic*: the shortest path,
walked at uniform pace. The space of filtrations is therefore a **geodesic space** —
between any two of its points there is a straight line realizing their distance.

## The new chapter: the world of paths

A single straight line is a fine thing. But the deeper question — the one this work
answers — is what happens when you study *all* the lines at once, the entire
**path space** of filtrations. Three different faces of this path space emerge, and
they are independent enough that each could belong to a different branch of
mathematics.

### Lines made of lines (the algebraic face)

Pick two points on the `F`–`G` line, say `lerp(F,G,a)` and `lerp(F,G,b)`. Now draw
the straight line *between those two points*. Where does it go? You might fear a
tangle of new paths. Instead, something tidy happens:

> **Reparametrisation closure.** The line between `lerp(F,G,a)` and `lerp(F,G,b)`,
> traversed by fraction `t`, is again a point on the original `F`–`G` line — namely
> the point at fraction `(1 − t)·a + t·b`.

A line of lines is just the original line, re-labeled. Sub-paths of a geodesic are
geodesics; the geodesics are closed under blending and re-timing. This is the
combinatorial skeleton of what topologists call a *fundamental groupoid* — the
algebra of how paths compose. Paths multiply into paths and never escape the family.
(As a tiny but telling special case, the line from a filtration to *itself* never
moves: `lerp(F, F, t) = F` for every `t` — the degenerate geodesic.)

### The law of the in-between point (the metric face)

On any honest straight line, a point in the middle splits the journey exactly. If
you stop at an intermediate fraction `u` between `s` and `t`, the distance you have
already walked plus the distance still to go should add up to the whole. The path
space obeys this perfectly:

> **The geodesic-segment law.** For `s ≤ u ≤ t`, the distance from `lerp(F,G,s)` to
> `lerp(F,G,u)`, plus the distance from `lerp(F,G,u)` to `lerp(F,G,t)`, equals the
> distance from `lerp(F,G,s)` to `lerp(F,G,t)`.

The intermediate point lies *metrically between* the endpoints — no detour, no
slack. This is the full additivity law of a geodesic segment, generalizing the
simpler fact that the midpoint bisects the distance into two equal halves.

### Convexity, and a whisper of curvature (the analytic face)

Now bring in a third filtration `H`, a fixed observer standing off to the side, and
watch how its distance to the moving point `lerp(F,G,t)` changes as `t` runs from 0
to 1. Does the distance jump around? No — it stays *below the straight-line average*
of the two endpoint distances:

> **Busemann convexity.** The distance from `H` to `lerp(F,G,t)` is at most
> `(1 − t)·d(H,F) + t·d(H,G)`.

This is a *convexity* inequality, and convexity of distance functions is the
signature of *non-positive curvature* — the gentle, saddle-shaped, "spread-apart"
geometry of hyperbolic space, the geometry where triangles are thinner than their
Euclidean counterparts and where straight lines, once they diverge, never reconverge
in surprising ways. The space of data shapes carries a faint echo of this benign
geometry, inherited directly from the supremum distance through the isometry theorem.

## The single thread tying it together

There is one elegant insight that organizes the whole picture: **geodesy is the
sharp face of convexity.** Strip everything down to a single simplex and the entire
story becomes the humble convexity of the absolute value: the distance from an
observer to a blended birth-time is never more than the blend of the two distances,
with *equality exactly when the two gaps point the same way*. The interleaving
distance then takes the worst case — a supremum — over all simplices. Whether the
global statement is an equality or a strict inequality comes down to a single
question: *is the worst-case simplex shared?*

When you compare points on the *same* line, it is. Every simplex moves along its own
little straight line at its own constant rate, all in lockstep, so one fixed simplex
(the one with the largest endpoint gap) stays the worst case for every pair of
parameters. The worst case marches in step with the motion, the scaling factor pulls
cleanly out of the supremum, and you get an *exact* equality — the constant-speed law
and the in-between law. But bring in an off-line observer `H`, and different
simplices can each "win" the worst case for different comparisons; their
disagreements no longer line up, a genuine gap opens, and the equality relaxes into
the convexity inequality. One asymmetry — shared worst-case versus competing
worst-cases — explains all three faces at once, and it is also why the shortest path
is not unique: the simplices that are *not* the worst case carry slack that can be
nudged around without changing any distance, so many different straight lines all
realize the same shortest length.

## Why any of this matters

It is tempting to treat the space of all filtrations as an abstraction too rarefied
to touch the real world. The opposite is true. The moment you can draw geodesics
between data shapes, a toolbox opens up:

- **Averaging shapes.** The midpoint of a geodesic is a principled "average" of two
  datasets' topologies — a way to summarize an ensemble of noisy measurements
  without smearing away their structure.
- **Interpolation and morphing.** A constant-speed path is a controlled morph from
  one shape-biography into another, useful for animating how a structure deforms or
  for filling in missing time-steps between snapshots.
- **Optimization on shape space.** Convexity of the distance function is exactly the
  property that makes optimization well-behaved. Want to find the filtration closest
  to a whole cloud of observed ones — a topological "barycenter"? Convexity tells
  you the landscape has no spurious traps along geodesics.
- **A geometry to reason in.** Non-positive curvature is the friendliest possible
  setting for algorithms: unique projections, contracting averages, provable
  convergence. The faint hyperbolic flavour of shape space is a license to import a
  century of geometric machinery.

## The takeaway

We began with a cloud of dots and a question about shape. We end with something
unexpected: the *collection* of all possible shape-biographies is itself a clean
geometric world. It has a distance you can compute by a simple worst-case
comparison. It has straight lines — honest geodesics — between any two of its
points. Those lines are closed under blending, they obey the in-between law of
genuine segments, and the distances within the space are convex along them, carrying
a quiet signature of non-positive curvature. And all of it flows from a single
asymmetry: that a shared worst case turns an inequality into an equality.

The shapes hiding inside data, it turns out, do not merely exist. They travel — and
they travel in straight lines.
