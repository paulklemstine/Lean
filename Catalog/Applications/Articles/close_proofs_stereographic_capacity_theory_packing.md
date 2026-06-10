# Packing Oranges on a Sphere — by Flattening It First

## A very old question, and a new way to ask it

How many friends can you seat around a campfire so that no two are closer than
arm's length? Stand them on a flat field and the answer is a familiar puzzle in
plane geometry. Now bend the field into a globe and the puzzle becomes one of the
oldest and most stubborn problems in mathematics: **how many non-overlapping caps
of a given size can you fit on the surface of a sphere?**

This is not an idle game. Each "cap" can be thought of as the cone of directions
that one signal, one antenna beam, or one codeword can occupy without being
confused for its neighbors. The maximum number of caps that fit is, quite
literally, the size of the largest error-correcting code of a certain type — the
backbone of reliable digital communication, from deep-space probes to the Wi-Fi
in your kitchen. Mathematicians call these *spherical codes*, and counting them
exactly is famously hard. Even the simplest version on an ordinary globe resists
clean answers.

This article tells the story of a clean, geometric strategy for *bounding* that
count from above — for proving statements of the form "you cannot possibly fit
more than this many." The trick is disarmingly simple to state: **don't study the
sphere. Flatten it, study the flat picture, and carry the answer back.** The
flattening is an old friend called *stereographic projection*, and the careful
bookkeeping of how it distorts distances is what we'll call **stereographic
capacity theory**.

## How to flatten a sphere without lying too much

Picture a globe sitting on a table, touching it at the South Pole. Put a tiny
lamp at the North Pole. Every point on the globe (except the North Pole itself)
casts a shadow somewhere on the infinite tabletop. That shadow map is
stereographic projection: it turns the whole sphere, minus one point, into the
entire flat plane.

Stereographic projection has a magical property that map-makers have prized for
centuries: it is *conformal*. It preserves angles perfectly. A small circle drawn
on the globe casts a shadow that is still a small circle, never an ellipse. What
it does **not** preserve is size. Near the South Pole — directly under the
table-contact point — shadows are nearly true to scale. Out toward the equator and
beyond, shadows stretch and balloon, and points near the North Pole are flung off
toward infinity.

The entire art of stereographic capacity theory is to track that stretching with a
single number at each location. We call it the **conformal factor**, written
`λ(x)`, where `x` is a point on the flat plane:

> **Definition (conformal factor).** At a plane point `x`,
> `λ(x) = 2 / (1 + ‖x‖²)`,
> where `‖x‖` is the distance of `x` from the origin.

This little formula is the dictionary between the round world and the flat one. A
tiny step of length `ds` on the plane near `x` corresponds to a step of length
roughly `λ(x) · ds` on the sphere. Where `λ` is large, the sphere is "denser" than
the plane; where `λ` is small, it is sparser.

Our first results pin down exactly how this factor behaves.

> **Theorem 1 (the factor is well-behaved).** For every point `x`:
> 1. `λ(x) > 0` — the factor is always strictly positive;
> 2. `λ(x) ≤ 2` — it never exceeds 2;
> 3. `λ(x) = 2` exactly when `x = 0`, the origin.

In plain words: the dictionary never breaks (you never divide by zero, never get a
negative scale), the stretching is bounded — the sphere is never *more* than twice
as dense as the plane — and the maximum density, the factor of exactly 2, happens
at one special spot: the point under the South Pole, the place where the globe
kisses the table. There the map is least distorted and the local scale is at its
peak. Move away in any direction and `λ` strictly decreases, draining toward zero
as you race off to infinity (the North Pole). It is a clean, gentle, fully
predictable distortion — exactly the kind a mathematician can build an argument on.

## From spherical caps to flat exclusion zones

Now we use the dictionary. Place a "guard radius" `r` on the sphere: we want every
pair of chosen points to be at least a geodesic distance `2r` apart, so their caps
of radius `r` never overlap. Project the chosen points down to the plane. Each one
should now be surrounded by a flat *exclusion zone* — a forbidden disk that no
other point may enter. How big is that disk?

Because the sphere stretches by `λ(x)`, a spherical radius `r` translates into a
flat radius obtained by dividing out the local scale. The result is strikingly
clean:

> **Theorem 2 (exclusion radius, closed form).** The flat exclusion radius
> required at plane point `x` to enforce a spherical guard radius `r` is
> `exclusion(r, x) = tan(r) · (1 + ‖x‖²) / 2`.

Read this formula slowly, because it tells the whole geometric story. The factor
`tan(r)` is the same everywhere — it encodes the size of the cap. But the factor
`(1 + ‖x‖²)/2`, which is exactly `1/λ(x)`, *grows* as you move away from the
origin. Points projected near the center need only a small exclusion disk; points
projected far out — corresponding to spots near the North Pole, where the sphere
was barely sampled by the plane — need huge ones. The flat picture must "pay back"
the distortion the projection introduced. This is the bookkeeping that makes a
plane-geometry argument honest about its spherical origins.

A finite collection of plane points is called **stereo-separated** for radius `r`
when every pair sits farther apart than the sum of their two exclusion radii.
This is the exact flat shadow of "the caps don't overlap on the sphere," and it is
a condition you can check with nothing but the distances and norms of points in the
plane.

## A sharp, honest bound on the simplest sphere

For the ordinary 2-sphere `S²` — the surface of a globe — we can turn the
area-versus-distortion accounting into a concrete ceiling on how many caps fit. The
ingredients are textbook: the whole sphere has area `4π`, and a single cap of
geodesic radius `r` has area `2π(1 − cos r)`. The naive ratio of these areas is a
first guess at the packing number, but it ignores distortion. Folding in the worst
the conformal factor can do (a `(2/cos r)²` correction) and simplifying yields a
single, memorable closed form.

> **Theorem 3 (the S² distortion bound).** For radii `r` with `cos r ≠ 0` and
> `cos r ≠ 1`, the stereographic distortion bound collapses to
> `Bound(r) = 8 / (cos²r · (1 − cos r))`.

What began as a product of four awkward pieces — two squared secants, a total
area, a cap area — becomes one fraction. As the caps shrink (`r → 0`), the
denominator goes to zero and the bound blows up, correctly predicting that
arbitrarily many tiny caps can fit. As the caps grow toward a hemisphere, the
bound tightens toward the small handful of large caps that geometry allows. The
formula is not just compact; it is differentiable, plottable, and ready to be
compared against real packing numbers — which is exactly what a working bound
should be.

## When the answer is "just one"

Mathematics earns trust by getting the extreme cases exactly right, and capacity
theory does. Suppose the guard radius is enormous — bigger than `1`. The unit
sphere has diameter only `2` (the distance straight across through its center). If
we demand that every pair of chosen points be at least `2r > 2` apart, we are
demanding the impossible for any two distinct points: no two points on the sphere
are ever farther apart than the diameter `2`.

> **Theorem 4 (degenerate packing).** If `r > 1`, then any set of points on the
> unit sphere that are pairwise at distance at least `2r` contains **at most one
> point**.

The proof is a single line of honest geometry: any two points `a` and `b` on the
unit sphere satisfy `‖a − b‖ ≤ ‖a‖ + ‖b‖ = 1 + 1 = 2`, by the triangle
inequality, so they can never reach the required separation `2r > 2`. Hence the
"packing number" for such a radius is exactly `1`: you can place one point, and
nowhere is there room for a second. This is the sharp boundary where the problem
stops being interesting — and our framework hits it precisely, certifying the bound
`SphericalPackingBound n r 1` for every dimension `n` whenever `r > 1`.

One more small but useful fact rounds out the toolkit: bounds are **monotone**. If
you have proven that no packing exceeds some budget `B`, then the same packing
certainly does not exceed any larger budget `B′ ≥ B`. Looser claims follow for
free from tighter ones — obvious, but exactly the kind of plumbing a usable theory
needs in place.

## Why flatten at all?

It is fair to ask: if the sphere is the real object, why detour through the plane?
The answer is that the plane is where our sharpest tools live. Plane geometry has
centuries of machinery — distances, norms, disks, packing arguments — that are far
easier to wield than their curved counterparts. Stereographic projection lets us
borrow all of it, *provided* we keep an honest ledger of the distortion. The
conformal factor `λ(x)`, the exclusion radius `tan(r)(1+‖x‖²)/2`, and the closed
bound `8/(cos²r(1−cos r))` are exactly that ledger, written out and checked. They
turn a question about a curved world into one about a flat world that we already
know how to answer.

That is the quiet promise of this circle of ideas. Sphere packing connects to the
codes that protect every bit you send and receive, to the way molecules arrange
themselves, to the geometry of high-dimensional data. Each of those lives,
ultimately, on a sphere. And each, with the right dictionary, can be studied on a
sheet of paper. Flatten the world, do the bookkeeping, and carry the answer home.
