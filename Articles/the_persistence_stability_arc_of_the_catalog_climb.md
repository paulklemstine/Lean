# The Shape of Data Has a Curvature — and It Bends the Right Way

## A road between two shapes

Imagine you are handed two clouds of points — two photographs of the same coastline taken a century apart, two snapshots of a protein folding, two scatterplots of customers in a market. Each cloud has a *shape*: clusters, loops, voids, the connective tissue that topology calls its "features." Comparing shapes is one of the oldest instincts in science, and topological data analysis (TDA) has turned that instinct into a measuring tape. It assigns to every dataset a fingerprint — a record of which holes are born at which scale and which die — and it equips the space of all such fingerprints with a notion of distance. Two datasets are close when their topological fingerprints are close.

That distance has a name: the **interleaving distance**. It is the central yardstick of TDA, and its fundamental property — proven again and again in the field's foundational theorems — is *stability*: nudge the data a little, and the fingerprint moves only a little. Persistence is robust. It does not panic at noise.

But here is a question that the stability theorems alone do not answer. Suppose I want to *morph* one shape continuously into another — to walk along a road from the first dataset to the second. What does that road look like? Is there a straight one? If two travelers set out from two different starting points and walk to two different destinations, keeping the same pace, do they ever swerve toward each other faster than they "should"? Does the landscape of shapes have hills and valleys, or is it, in some precise sense, *flat enough to never trap you*?

This article is about the answer to that last question. It turns out that the space of data shapes, measured by the interleaving distance, has a **curvature** — and the curvature is non-positive. The roads bend the kind way. Two travelers on parallel journeys can never drift together faster than the average of how far apart their endpoints are. In the language of geometry, the space is a **Busemann space**: a world without focusing, without the gravitational lensing that pulls geodesics together. This is the strongest possible "good behavior" you could ask of a metric space, and it is exactly what makes optimization, averaging, and interpolation over shapes tractable.

We are going to build this result from the ground up, in plain language, and then state it precisely. Everything below is self-contained: by the end you will know exactly what a filtration is, what the interleaving distance is, what a geodesic between shapes is, and what it means — and why it is true — that this geometry is non-positively curved.

## What a "shape" really is: the filtration

Strip away the pictures and a dataset's topological content is captured by a single bookkeeping device called a **filtration**. Think of building a shape gradually as you turn a dial labeled "scale."

Concretely, fix a set of building blocks — call them *simplices*. A simplex is just a finite collection of data points: a single point, a pair (an edge), a triple (a triangle), and so on. As you turn the scale dial up from zero, simplices "switch on" one by one. A point switches on immediately; an edge switches on once its two endpoints are close enough; a triangle switches on once all three of its edges are present. The shape at scale `t` is the collection of all simplices that have switched on by then.

The entire history of switch-on times is recorded by one function. To each simplex `σ` we assign a number, its **weight** `w(σ)`, the scale at which it is born. A filtration is exactly this weight function, subject to two utterly natural rules:

- **The empty collection costs nothing:** `w(∅) ≤ 0`. The "shape made of no points" is present from the very beginning.
- **Bigger faces are born no earlier than their parts:** if `σ ⊆ τ`, then `w(σ) ≤ w(τ)`. A triangle cannot appear before its edges; an edge cannot appear before its endpoints. This is *monotonicity*, and it is precisely what guarantees that the shape at each scale is a genuine, downward-closed simplicial complex.

That's it. A filtration is a weight function `w : (finite subsets) → ℝ` that is `≤ 0` on the empty set and monotone under inclusion. Every point cloud gives rise to one — the famous **Vietoris–Rips filtration**, where a simplex is born at the scale equal to its diameter (the largest distance between two of its points). But the definition stands on its own: a filtration is any such weight function, and the space of all filtrations is the space of all possible "shape histories."

## Measuring the distance between two shapes

Now take two filtrations, `F` and `G` — two shape histories. How far apart are they?

The classical answer is the interleaving distance, defined through *shifts*. We say `F` and `G` are **δ-interleaved** if each one's growing family of shapes is contained in the other's after sliding the scale dial by `δ`: everything born in `F` by scale `t` is born in `G` by scale `t + δ`, and vice versa. The interleaving distance is the smallest shift `δ` that makes this work:

> `d(F, G)` = the infimum of `δ ≥ 0` such that `F` and `G` are `δ`-interleaved.

This is the abstract, relational definition, and it is the one that makes stability theorems possible. But it hides a beautiful secret, established earlier in this line of work and which we take as our starting point. The shift-based distance is *exactly equal* to a far more transparent quantity: the largest disagreement between the two weight functions, simplex by simplex.

> **The isometry formula.** `d(F, G) = sup over all simplices σ of |w_F(σ) − w_G(σ)|.`

In words: the interleaving distance between two shapes is just the worst-case difference in birth times, over all simplices. Two shapes are within `δ` of each other exactly when every single feature is born within `δ` of the same scale in both. This is the *sup-distance*, the ℓ^∞ metric, the "maximum coordinate gap" — the same distance a chess king travels, just in infinitely many dimensions. It turns the abstract space of shapes into a concrete sup-normed space of functions, and every geometric question about shapes becomes a question about that supremum.

## A straight road between two shapes

With a distance in hand we can ask for the *shortest road*. In a metric space, a **geodesic** between `F` and `G` is a path that realizes the distance at constant speed: at the halfway point you have covered exactly half the distance, at one-quarter you've covered one-quarter, and so on, with no detours.

For shapes there is an obvious candidate, and it works. Just average the weight functions. Define, for each `t` between `0` and `1`, the filtration

> `lerp(F, G, t)` with weight `w(σ) = (1 − t)·w_F(σ) + t·w_G(σ)`.

(The name `lerp` is the computer-graphics term for "linear interpolation.") At `t = 0` this is `F`; at `t = 1` it is `G`; in between it is a genuine filtration — the convex average of two monotone weight functions is still monotone, and still `≤ 0` on the empty set, so the two rules survive. As `t` slides from `0` to `1`, you watch each simplex's birth time glide linearly from its `F`-value to its `G`-value. And — this is the geodesic property established in the prior chapter of this work — the interleaving distance traversed is exactly proportional to `t`. The straight line of weight functions *is* a constant-speed shortest path between the shapes.

So far, so good: between any two shapes there is a straight road, and we can drive it at constant speed. Now comes the new question, and the heart of this article.

## Parallel journeys and the meaning of curvature

Take *two* roads. Traveler A drives from `F` to `G`. Traveler B drives from `F′` to `G′`. They synchronize their watches and drive at the same fractional pace: at time `t`, A is at `lerp(F, G, t)` and B is at `lerp(F′, G′, t)`. The question of curvature is simply: **how far apart are the two travelers at time `t`?**

In flat space — think of two cars driving in straight lines across an infinite parking lot — the gap between them changes *linearly*. If they start `5` meters apart and end `11` meters apart, then a third of the way through they are exactly `7` meters apart: the gap is the straight-line interpolation `(1−t)·5 + t·11`.

In a space of *positive* curvature — the surface of a sphere — geodesics bend toward each other. Two travelers heading from near the equator toward the poles find themselves pulled together; the gap shrinks faster than the linear prediction. This is the focusing that makes great circles cross.

In a space of *non-positive* curvature — a saddle, a tree, hyperbolic space — geodesics spread apart, or at worst keep pace, but never focus. The gap between parallel travelers never *exceeds* the linear prediction. This is the defining inequality of what geometers call a **Busemann space**, after Herbert Busemann who isolated convexity of the distance function as the metric essence of non-positive curvature.

The new theorem says the space of shapes is of exactly this kind.

> **The convex geodesic bicombing inequality (Busemann convexity).** For two synchronized geodesics and any time `t ∈ [0, 1]`,
> `d( lerp(F, G, t), lerp(F′, G′, t) ) ≤ (1 − t)·d(F, F′) + t·d(G, G′).`

Read it slowly. The left side is the gap between the two travelers at time `t`. The right side is the linear interpolation between the gap at the start (`d(F, F′)`) and the gap at the end (`d(G, G′)`). The theorem guarantees the actual gap never rises above that line. Two synchronized journeys through the space of shapes never drift together — and never bulge apart — faster than the average of their endpoint gaps. The landscape of data shapes has no hills that trap you and no lenses that focus you. It bends the kind way.

A "convex geodesic bicombing" is the technical name for a *whole consistent field* of such well-behaved geodesics: a chosen straight road between every pair of points, all obeying this convexity inequality together. The function `lerp` is precisely such a bicombing, and the theorem certifies its defining property.

## Why it's true: a triangle inequality, amplified

The most satisfying part is how *simple* the engine is. There is no heavy machinery, no curvature tensor, no comparison triangle. The entire result is a single grade-school fact about absolute values, broadcast across infinitely many simplices through the isometry formula.

Here is the one fact. For real numbers `a` and `b` and any weight `t ∈ [0,1]`:

> `|(1 − t)·a + t·b| ≤ (1 − t)·|a| + t·|b|.`

This is just the triangle inequality, applied to a convex combination: the size of an average is at most the average of the sizes. It is the convexity of the absolute-value function, the humblest fact in analysis.

Now watch it amplify. Fix a single simplex `σ`. Let `a = w_F(σ) − w_{F′}(σ)` be how much `F` and `F′` disagree on `σ`, and let `b = w_G(σ) − w_{G′}(σ)` be how much `G` and `G′` disagree on it. Because `lerp` averages weights linearly, the disagreement between the two travelers *on this simplex* at time `t` is exactly `(1 − t)·a + t·b`. The grade-school inequality says its absolute value is at most `(1 − t)·|a| + t·|b|`.

That holds for *every* simplex. Take the supremum over all of them. The isometry formula says the supremum of the left side is the distance between the travelers; the supremum of the right side is bounded by `(1 − t)` times the distance `d(F, F′)` plus `t` times the distance `d(G, G′)`. The Busemann inequality drops out. A one-line fact about two real numbers, transported coordinatewise through a supremum, becomes a statement about the global curvature of the space of all data shapes.

This is why the geometry is exactly *flat-convex*: it inherits its curvature from the sup-norm, and the sup-norm bends precisely at the breakeven boundary of non-positive curvature. The inequality is sharp — it holds with the optimal convex coefficients — but it is never strict in the way a sphere's is. The space of shapes is the gentlest kind of curved: never focusing, never trapping, the convexity holding with equality whenever a single simplex happens to dominate both endpoint distances.

## Two corollaries you get for free

Once you have the master inequality, two familiar facts fall out as special cases.

**Standing still is free.** If you interpolate a shape with *itself*, you never move:

> `lerp(F, F, t) = F` for every `t`.

The average of a weight function with itself is the same weight function. A "constant geodesic" is a point that just sits there. Trivial — but it is the lever for the next corollary.

**Distance to a landmark is convex along any road.** Pin a fixed reference shape `H` — a landmark on the horizon. As a single traveler drives the geodesic from `F` to `G`, how does their distance to `H` change? Specialize the master inequality by letting the second traveler stand still at `H` the whole time (`F′ = G′ = H`, so their "geodesic" is the constant point `H`). Out comes:

> `d( lerp(F, G, t), H ) ≤ (1 − t)·d(F, H) + t·d(G, H).`

The distance to any fixed landmark is a **convex function** of how far along the road you are. It can dip below the straight-line interpolation, but it can never rise above it. This is the ordinary, single-geodesic notion of convexity — and it is exactly what makes *averaging shapes* well-posed. To find the "center" of a collection of datasets you minimize the sum of squared distances; convexity of those distances along geodesics is what guarantees the minimization behaves, that gradient descent over shapes does not get lost in a thicket of false valleys.

There is also a quiet symmetry worth naming. The road from `F` to `G` and the road from `G` to `F` are the *same road*, traversed in opposite directions:

> `lerp(F, G, t) = lerp(G, F, 1 − t).`

Running the clock backward from the far endpoint traces identical points. Geodesics in this world are honest two-way streets.

## Why this matters beyond the theorem

It is tempting to file "non-positive curvature of the interleaving metric" under abstract geometry and move on. But the payoff is intensely practical, because non-positive curvature is the property that makes a metric space *computationally friendly*.

In a Busemann space:

- **Averages exist and are unique.** The "Fréchet mean" — the shape that minimizes total squared distance to a collection of shapes — is well defined and unique. You can speak of *the* average of a hundred datasets' topologies, not merely *an* average.
- **Optimization converges.** Convex functions along geodesics have no spurious local minima. Gradient-style methods over the space of shapes find the global optimum. This is the bedrock under any algorithm that *learns* a topological summary, fits a model to persistence data, or interpolates between observed shapes.
- **Interpolation is principled.** Want a continuous morph from one dataset to another that is provably the shortest such morph and provably stable to perturbation? The `lerp` bicombing gives it, and the bicombing inequality guarantees that nearby morphs stay nearby.
- **The space is contractible.** A consistent convex bicombing means the whole space can be continuously shrunk to a point along its geodesics. There are no topological obstructions hiding inside the space of shapes itself.

In short: the comparison metric at the foundation of topological data analysis is not merely *a* metric, and not merely a stable one. It is a metric of the best possible geometric character — flat-convex, non-positively curved, geodesic, with a coherent field of shortest roads obeying the convexity inequality that geometers spent a century learning to prize. And the proof of all this rests on the single observation that the size of an average is at most the average of the sizes, broadcast through a supremum.

## The view from the bridge

There is a pleasing inevitability to how this fits together. The space of data shapes began as a relational notion — one shape "interleaves" another after a shift. That relation hardened into a distance. The distance turned out to *equal* a transparent sup-norm: the worst-case gap in birth times. The sup-norm gave straight roads — convex averages of weight functions — that traverse the distance at constant speed. And now the same sup-norm gives those roads their curvature: non-positive, flat-convex, Busemann.

Each step inherited its content from the one before, and every geometric fact about shapes turned out to be an elementary fact about real numbers, amplified through a supremum. The curvature of the space of shapes is not exotic. It is the curvature of the absolute-value function, written infinitely many times at once. That a measuring tape invented to detect holes in data should, when you ask after its geometry, answer with the gentlest curvature a space can have — that is the quiet elegance worth carrying away.
