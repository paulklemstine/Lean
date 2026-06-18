# Straight Lines Between Shapes: The Geometry of Persistence

## A puzzle about distance

Imagine you are handed two photographs of the same coastline taken a century apart.
At a glance you can say they are "close" or "far" — but how far, exactly? And if
you wanted to *morph* one into the other, what would the most economical
intermediate pictures look like? Would the morph pass through pictures that are
themselves valid coastlines, or would it drift through impossible, ghostly shapes
on the way?

These questions sound artistic, but they sit at the heart of a branch of modern
data analysis called **topological data analysis**, or TDA. The objects that TDA
compares are not photographs but *shapes of data* — the loops, voids, and clusters
that a cloud of points forms as you zoom out from it. This article is about a
recently completed chain of results that answers, for one precise and important
notion of "shape," exactly the questions above: How far apart are two shapes? What
does the cheapest morph between them look like? And what is the hidden geometry of
the *space of all morphs*?

The answers turn out to be unexpectedly clean. The space of shapes is **geodesic**:
between any two shapes there is a straight-line path that realizes their distance at
constant speed. That path is *convex*, in a sense that mathematicians associate with
non-positive curvature. The whole space of paths is **contractible** — it has no
holes, no loops, nothing topologically interesting hiding inside it. And the maps
that relabel or merge the underlying data points carry straight-line morphs to
straight-line morphs, never stretching them. Every one of these statements has been
checked, line by line, with full mathematical rigor.

## What is a "shape of data," really?

Start with a finite set of objects — call them vertices. They could be cities,
genes, pixels, or sensors. Now imagine recording, for every possible *group* of
these objects, a single number: the "scale" at which that group first acts as a
unit. A pair of nearby cities might fuse into a unit at a small scale; a triple of
cities scattered across a continent only counts as a unit at a very large scale.

Mathematically, we package this as a function `w` that assigns a real number to
every finite subset `σ` of the vertices. We call `w(σ)` the **weight** of `σ`. Two
modest rules make this function a **filtration**:

1. **Grounding:** the empty set has weight at most zero, `w(∅) ≤ 0`. (The trivial
   group is there from the very start.)
2. **Monotonicity:** if one group `σ` is contained in a larger group `τ`, then
   `w(σ) ≤ w(τ)`. (A bigger group can only appear at a coarser scale.)

That is the entire definition. A *filtration* is just a grounded, monotone
assignment of scales to subsets. It is the combinatorial fingerprint of a shape: as
you sweep a single scale parameter from small to large, the groups switch on one by
one in the order their weights dictate, and out of that switching-on process emerge
the loops and voids that TDA studies.

## Measuring the gap between two shapes

Suppose `F` and `G` are two filtrations on the same vertices. How far apart are
they? The natural answer — and the one used throughout this work — is the
**interleaving distance**. Stripped to its essence, it is breathtakingly simple:
look at every group `σ`, measure how much its two weights disagree, `|F(σ) − G(σ)|`,
and take the **largest** disagreement over all groups:

> **d(F, G) = the supremum over all groups σ of |F(σ) − G(σ)|.**

This is the "sup distance," the same `ℓ∞` yardstick that says two functions are
close when they are close *everywhere*. (Behind the scenes, the interleaving
distance is defined more abstractly, via "shifts" that slide one filtration past
the other; a cornerstone theorem — the *isometry formula* — proves that this
abstract definition coincides exactly with the simple supremum above. Everything in
this article rests on that identification.)

The interleaving distance is the gold standard in TDA precisely because it is
**stable**: small changes in your data produce only small changes in the measured
shape. It is the reason topological summaries can be trusted as real features rather
than noise.

## The straight line between two shapes

Now for the morphs. Given two filtrations `F` and `G`, define, for each blending
fraction `t` between 0 and 1, a new filtration `lerp F G t` — short for *linear
interpolation* — by simply averaging their weights:

> **(lerp F G t)(σ) = (1 − t)·F(σ) + t·G(σ).**

At `t = 0` you recover `F`; at `t = 1` you recover `G`; in between you get a smooth
blend. The first thing to check is that this blend is *itself a legitimate shape* —
and it is. Averaging two grounded, monotone weight functions with non-negative
coefficients keeps them grounded and monotone. So `lerp F G t` is a genuine
filtration for every `t` in `[0, 1]`. The morph never leaves the world of valid
shapes.

The real surprise is how the distance behaves along this path. One might expect the
interleaving distance to wobble as `t` varies. It does not. It moves at **perfectly
constant speed**:

> **d(lerp F G s, lerp F G t) = |s − t| · d(F, G).**

This single identity — the *constant-speed geodesic identity* — is the keystone.
It says the interpolation path is the metric equivalent of a straight line traversed
at uniform velocity. Halfway along (`t = ½`) you are exactly halfway in distance;
the two halves of the journey add up perfectly to the whole:

> **d(F, midpoint) + d(midpoint, G) = d(F, G).**

A space in which any two points are joined by such a constant-speed shortest path is
called a **geodesic space**. So the space of all shapes, under the interleaving
distance, is geodesic. There is always a best morph, and we can write it down
explicitly: just average the weights.

Why does the speed stay constant? Here is the intuition. Every individual group `σ`
travels its own little straight line, from `F(σ)` to `G(σ)`, and it does so at a
rate proportional to its own gap `|F(σ) − G(σ)|`. The overall distance is the
*largest* of these gaps. But scaling every gap by the same factor `|s − t|` does not
change *which* gap is largest — it just multiplies the winner by that factor. A
supremum of constant-rate motions is itself constant-rate. The geometry of the whole
inherits the uniform motion of its coordinates.

## The shape of the space of morphs

Once you have straight lines, you can ask about the geometry they trace out. Three
features stand out.

**Betweenness.** Pick three parameters `s ≤ u ≤ t`. The middle point `lerp F G u`
lies *exactly* between the other two, in the strongest possible sense: the distance
from the first to the middle plus the distance from the middle to the last equals
the distance from first to last. No detours, no slack. This is the full
*geodesic-segment law*, and it confirms that the interpolation really is a single
unbending segment.

**Convexity.** Fix any third shape `H` as an observer. As you walk along the morph
from `F` to `G`, how does your distance to `H` change? It is **convex**:

> **d(H, lerp F G t) ≤ (1 − t)·d(H, F) + t·d(H, G).**

In words: your distance to the observer never bulges above the straight-line
interpolation of the two endpoint distances. This is the **Busemann convexity**
inequality, the metric signature of spaces that curve non-positively — spaces like
the flat plane or the saddle, never the sphere. It is what makes the space feel
"open" and well-behaved: shortest paths spread apart rather than reconverging.

**The sharp diagonal.** Here is the most elegant observation of the whole arc. The
convexity inequality above is, in general, *strict* — there is genuine slack —
because the group that is hardest to reconcile with `H` need not be the same as the
group hardest to reconcile with `F` or with `G`. But take the observer to *be* one
of the endpoints, say `H = F`. Then `d(F, F) = 0`, and the inequality collapses into
an exact equality:

> **d(F, lerp F G t) = (1 − t)·d(F, F) + t·d(F, G) = t · d(F, G).**

So the constant-speed geodesic identity is nothing more than the **equality case of
the convexity inequality, restricted to the endpoints' own line.** Convexity is the
general inequality; geodesy is its sharp diagonal. One asymmetry — that the
worst-case group can migrate as you move the observer — organizes the entire
landscape: it is the source of the slack in convexity, and its vanishing on the
diagonal is the source of the exact constant speed.

## No holes: the space of paths is contractible

If the space of shapes is geodesic and convex, what does its *topology* look like —
are there loops you cannot shrink, voids you cannot fill? The answer is reassuringly
dull, and that dullness is a theorem.

Take any path `γ` wandering through the space of shapes — any continuous family of
filtrations — and pick a basepoint `F`. Now build a two-parameter family of shapes:

> **H(s, r) = lerp F (γ(r)) s.**

Read this as: for each point `γ(r)` along the path, draw the straight line from the
basepoint `F` out to `γ(r)`, and let `s` slide along it. At `s = 0` every one of
these lines sits at `F`, so the whole path has been crushed to a single point. At
`s = 1` the family reproduces the original path `γ`. As `s` runs from 1 down to 0,
the path is reeled smoothly back into the basepoint — and, by the constant-speed
identity, each strand is reeled in at uniform velocity.

This is a **contraction**. Its existence means every path — every loop, in
particular — can be continuously shrunk to a point. The space of shapes is
**contractible**: it has no fundamental group, no higher homotopy, nothing. And
crucially, the contraction is built entirely out of the same `lerp` operation: it
never leaves the algebra of straight lines. The topology is trivial *because* the
geometry is straight.

## Relabeling never stretches

The final piece connects the geometry back to the data. Often we want to *transform*
our vertices: merge two sensors into one, project a high-dimensional dataset onto
fewer coordinates, or simply rename things. Any map `f` from one vertex set to
another induces a **pullback** on filtrations: to weigh a group `σ` in the new
world, you push it forward through `f` and read off the weight of its image in the
old world,

> **(pullback f F)(σ) = F(f(σ)).**

Two facts make this transformation a perfect citizen of the geometry. First, it
**commutes with straight lines**:

> **pullback f (lerp F G t) = lerp (pullback f F) (pullback f G) t.**

Pulling back a morph gives exactly the morph between the pulled-back endpoints. The
reason is almost a tautology once you see it: both pullback and interpolation are
*affine* operations on the weights — pullback re-reads the weights through a fixed
reindexing, interpolation averages them — and affine operations always commute.
"Affine commutes with affine" is, remarkably, the same one-line fact that powers the
contraction above.

Second, pullback **never stretches**:

> **d(pullback f F, pullback f G) ≤ d(F, G),**

and therefore the transported morph travels no faster than the original. Relabeling,
merging, projecting — none of these can manufacture distance. Combined with the
commutation law, this says the assignment "vertices ↦ their space of shapes-and-
morphs" is a *functor into the category of geodesic spaces*: it respects not just the
points but the entire straight-line geometry, and it does so without distortion.

## Why it matters

It is easy to lose sight of the stakes amid the abstraction, so let us bring them
back. Topological data analysis is used to study the folding of proteins, the
large-scale structure of the cosmos, the firing patterns of neurons, and the shape
of financial markets. In every one of these applications, the key practical
questions are: *Are these two datasets meaningfully different? Can I interpolate
between them? If I simplify my data, do I corrupt its shape?*

The results sketched here give those questions clean, provable answers for the
filtration model of shape. There is always a canonical, explicit, best morph between
two datasets — just average their weights. The distance moves at constant speed
along it, so "halfway between" is unambiguous. The geometry is non-positively curved
and the space of morphs has no hidden topology, which means optimization and
averaging behave the way our intuition from flat space expects. And simplifying the
data can only contract distances, never inflate them, so coarse-graining is always
safe.

What is perhaps most striking is how *little* machinery the proofs require. The deep
behavior — geodesy, convexity, contractibility, functoriality — all flows from two
humble facts about averaging: that the average of two valid shapes is a valid shape,
and that averaging commutes with everything else affine. The richness of the
geometry was hiding in plain sight, inside the arithmetic of the weighted average.
Sometimes the straightest line really is the simplest one.
