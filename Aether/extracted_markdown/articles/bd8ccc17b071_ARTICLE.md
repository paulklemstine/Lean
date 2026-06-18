# The Straight Road Between Shapes

## How a single idea turned the geometry of data into a landscape you can walk across

Imagine you are handed two photographs of the same coastline taken a century apart. The shapes are recognizably related — the same headlands, the same bays — but everything has shifted a little. Cliffs have eroded, sandbars have migrated, an inlet has silted up. You would like to say *how different* the two coastlines are, and, more ambitiously, you would like to describe a smooth, believable transformation that carries one into the other. Not a jump cut, but a slow morph: a continuous family of in-between coastlines, each a plausible snapshot from some intermediate decade.

This little fantasy is, surprisingly, the central problem of a field called **topological data analysis**. And a recent piece of formalized mathematics — the ninth installment in a project nicknamed the *Boltzmann Bridge* — answers the second, harder half of the fantasy with unexpected elegance. It shows that the space of all "data shapes," equipped with the natural notion of distance between them, is **geodesic**: between any two shapes there is a straight road, and you can walk it at constant speed, the distance to your destination ticking down in perfect proportion to how far you've gone.

Let me unpack what that means, why it was not obvious, and why it matters.

## Shapes as filtrations

The first thing we need is a precise notion of "data shape." In topological data analysis, the workhorse object is called a **filtration**. Strip away the jargon and a filtration is just a rule that assigns, to every possible cluster of data points, a *birth time* — the scale at which that cluster first appears as a meaningful feature.

Concretely, suppose your data lives in some universe of points. A *simplex* is just a finite set of those points — a pair, a triangle, a tetrahedron, or a larger cluster. A filtration `F` assigns to every simplex `σ` a real number, its **weight** `F.weight σ`, which you should read as "the scale at which this cluster becomes real." Two rules make this honest:

- **Grounding.** The empty cluster is always already present: `F.weight ∅ ≤ 0`.
- **Monotonicity.** A bigger cluster never appears before one of its sub-clusters: if `σ ⊆ τ`, then `F.weight σ ≤ F.weight τ`.

That second rule is the soul of the whole subject. It says features are *cumulative*: as you turn up a single dial — the scale parameter — clusters only ever switch on, never off. Watching that dial sweep from small to large, you see a movie of a shape being assembled, and the *persistence* of each feature (how long it survives as the dial turns) is what topological data analysis measures.

The most famous example is the **Vietoris–Rips construction**. Given a cloud of points with distances between them, you declare a cluster "born" at the scale equal to its **diameter** — the largest distance between any two of its members. Singletons and pairs of coincident points are born at scale zero; a far-flung trio is born late. This single recipe, `diamWeight σ = ` the largest pairwise distance inside `σ`, turns any point cloud into a filtration, and it is the bridge from raw geometry to the abstract world of shapes.

## How far apart are two shapes?

Now to the first half of our fantasy: measuring the difference between two filtrations `F` and `G`.

The classical answer is the **interleaving distance**, and it is subtle. The idea is to ask: by how much do I have to *shift the scale dial* of one filtration so that it contains the other, and vice versa? If I can slide `F`'s movie forward by `δ` and have it cover everything `G` shows, and slide `G` forward by `δ` to cover `F`, then `F` and `G` are said to be **`δ`-interleaved**. The interleaving distance is the smallest such `δ` that works.

Formally, write `F.sublevelFaces t` for the set of clusters alive in `F` by scale `t` — all simplices `σ` with `F.weight σ ≤ t`. Then `F` and `G` are `δ`-interleaved (for `δ ≥ 0`) when every feature of `F` at scale `t` reappears in `G` by scale `t + δ`, and symmetrically:

> `F.sublevelFaces t ⊆ G.sublevelFaces (t + δ)` and `G.sublevelFaces t ⊆ F.sublevelFaces (t + δ)`, for all scales `t`.

The interleaving distance `d(F, G)` is the infimum of all `δ` for which this holds. Because some pairs of filtrations are *never* interleaved at any finite shift, the cleanest home for this distance is the extended non-negative reals `[0, ∞]`, where "no finite shift works" is honestly recorded as the value `∞`.

This distance is famous for two reasons. First, it is *stable*: small perturbations of your data produce small changes in the shape, so noise cannot manufacture phantom features. Second, it is notoriously *hard to compute and reason about* — the definition is an optimization over all possible shifts, quantified over all scales, and it took a substantial chain of results just to prove it satisfies the triangle inequality.

## The breakthrough that made everything simple

Earlier installments of the Boltzmann Bridge cracked that hardness open with a beautiful collapse. They proved that the elaborate, shift-based interleaving distance is *exactly equal* to something embarrassingly concrete: the **largest gap between the two weight functions**. In symbols,

> **`d(F, G) = ⨆ σ, |F.weight σ − G.weight σ|`** (measured in the extended reals),

where the supremum runs over every possible cluster `σ`. This is the **isometry theorem**: the difference between two data shapes is simply the worst-case disagreement, over all clusters, about *when* that cluster is born. Two coastlines are far apart precisely to the extent that some single feature is dated very differently by the two of them.

This is the sup-distance — the same "biggest coordinate difference" rule that governs the `ℓ^∞` norm, the geometry of the maximum. And it transforms a quantification-heavy optimization into a single, sharp formula. Everything that follows rides on it.

## The straight road: convex interpolation

We now have the distance. The new result supplies the *path*.

Here is the construction, and its simplicity is the point. Given two filtrations `F` and `G` and a dial `t` running from `0` to `1`, define a new filtration `lerp F G t` — short for *linear interpolation* — whose weight on each cluster is just the weighted average of the two original weights:

> **`(lerp F G t).weight σ = (1 − t) · F.weight σ + t · G.weight σ`.**

At `t = 0` every cluster's birth time is exactly `F`'s, so `lerp F G 0 = F`. At `t = 1` it is exactly `G`'s, so `lerp F G 1 = G`. In between, every feature's birth time slides linearly from where `F` puts it to where `G` puts it. It is the most naive possible morph — a coordinate-by-coordinate cross-fade — and the first thing to check is that it is even *legal*: is each in-between average still a genuine filtration?

It is, and the reason is a small miracle of convexity. The grounding condition survives because a weighted average of two numbers that are both `≤ 0`, with non-negative weights `1 − t` and `t`, is again `≤ 0`. Monotonicity survives because if `F.weight σ ≤ F.weight τ` and `G.weight σ ≤ G.weight τ`, then the same averaging — again with non-negative weights — preserves the inequality. So for every `t` between `0` and `1`, `lerp F G t` is a bona fide data shape: a plausible intermediate snapshot. We have our continuous morph.

## The geodesic identity

Now the payoff. We have a road from `F` to `G`. How long is it, and how is distance distributed along it? The answer is as clean as one could possibly hope.

Pick any two waypoints on the road, at parameters `s` and `t`. How far apart are the corresponding shapes? Start from the isometry formula — distance is the worst-case weight gap — and compute the gap on a single cluster `σ`:

> `(lerp F G s).weight σ − (lerp F G t).weight σ = (t − s) · (F.weight σ − G.weight σ)`.

The algebra is a one-liner: the `F`-terms contribute `(1−s) − (1−t) = t − s`, and the `G`-terms contribute `s − t`, so the whole gap factors as `(t − s)` times the *original* gap between `F` and `G` on that cluster. Taking absolute values,

> `|(lerp F G s).weight σ − (lerp F G t).weight σ| = |s − t| · |F.weight σ − G.weight σ|`.

The magic is that the factor `|s − t|` is **the same for every cluster `σ`**. It does not depend on which feature you look at. So when you take the worst case over all clusters — the supremum that defines the distance — that common factor simply pulls straight out:

> **`d(lerp F G s, lerp F G t) = |s − t| · d(F, G)`.**

This is the **constant-speed geodesic identity**. Read it slowly. It says the distance between two points on the road is *exactly* their parameter-gap `|s − t|` times the total length `d(F, G)`. There is no slack, no shortcut, no detour — the inequality you might expect (distance *at most* the straight-line bound) is in fact an *equality*. The morph travels at perfectly constant speed and takes the shortest possible route. The road is a true geodesic: a straight line in the geometry of data shapes.

Two immediate corollaries make the picture vivid. The distance from the starting shape `F` to the waypoint `lerp F G t` is exactly `t · d(F, G)` — you are precisely a fraction `t` of the way there. And the **midpoint** `lerp F G ½` bisects the journey perfectly:

> `d(F, lerp F G ½) + d(lerp F G ½, G) = d(F, G)`,

with each half-distance equal to `½ · d(F, G)`. The midpoint is genuinely, metrically, halfway between the two shapes — not just nominally, but in the exact additive sense the triangle inequality usually leaves as mere "at most."

## Why this is more than a tidy formula

It is tempting to file all this under "obvious in hindsight." A linear average travels at linear speed — what else would it do? But the surprise is structural, and it has real consequences.

First, **geodesy is a strong property and not every metric space has it.** A space can be perfectly reasonable as a notion of distance yet have *gaps* — pairs of points with no shortest path between them, only ever-shorter near-misses. (The rationals on the number line are like this: between two of them there is always a shorter route through a third, but no route is shortest.) To prove a space is geodesic, you must *exhibit* an actual shortest path, and prove it is shortest. The result above does exactly that, and the path it exhibits is the most natural object imaginable — plain averaging. That the naive morph is also the optimal one is a genuine alignment of intuition and truth.

Second, **it is the first explicit path in this entire world of shapes.** Up to now, the geometry of filtrations was known only *relationally* and *metrically*: you could say how far apart two shapes were, but you could not *travel* between them along a named, controllable route. The interpolation path changes the subject from measurement to motion. It is, quite literally, a homotopy between data shapes — a continuous deformation of one dataset's topological signature into another's — that you can write down, differentiate, and reason about.

Third, **it opens the door to a topology *of* topological data analysis.** Once you have paths, you can ask the questions that paths make possible. Can every shape be continuously shrunk to a single basepoint, making the whole space *contractible*? (The conjecture is yes: the straight-line contraction `H(G, t) = lerp G F₀ t` pulls everything to a chosen shape `F₀`.) Is the straight road the *only* geodesic, or are there others? (There are others: because distance is a *maximum* over clusters, the non-maximizing clusters have slack to wander, so the space is geodesic but not *uniquely* geodesic.) What is the *curvature* of this space? (The sup-distance heritage suggests it is flat-but-cornered, like the `ℓ^∞` geometry — non-positively curved in Busemann's sense, but with the sharp corners that keep it from being a textbook `CAT(0)` space.)

These are not idle speculations; they are the natural sequel, and the geodesic identity is the lemma that makes each of them a precise, attackable question rather than a vague hope.

## The view from the bridge

Step back and look at the arc. It began with a *relation* — the bare statement that two shapes are within `δ` of each other. It passed through a *distance* — a number, eventually a well-behaved extended metric satisfying the triangle inequality. It sharpened that distance into an *exact formula* — the worst-case weight gap, an isometry onto a sup-space. And now it has added *motion*: a straight road between any two shapes, traveled at constant speed, realizing the distance with no waste.

Each step made the geometry of data more like ordinary geometry — more like a place you could live in, navigate, and explore. The latest step is the one that turns a ruler into a map. We can now not only say that two coastlines are a certain distance apart; we can draw the line between them, mark the halfway point with confidence, and watch one shore morph steadily into the other, each intermediate frame a legitimate shape in its own right, the destination drawing nearer at a perfectly even pace.

The fantasy we started with — a believable, continuous morph between two snapshots of a changing world — turns out not to be a fantasy at all. It is a theorem. And the road between shapes, it turns out, is straight.
