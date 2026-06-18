# Counting the Edges of Shape: How a Growing Graph Learns the Geometry of a Point Cloud

## A dot, a circle, and the problem of seeing

Imagine you are handed a fistful of pebbles and asked to throw them onto a table so that, from far away, they trace the outline of a circle. A friend across the room squints and says, "Yes — that's a ring." But how did your friend *know*? Each pebble is just a point. No single pebble is round. The "circle" is not in any one stone; it lives in the **relationships between them** — which stones are near which, and at what distance the whole arrangement suddenly hangs together as one connected loop rather than a scatter of islands.

This is the central puzzle of a field called *topological data analysis*: how do you recover the shape of something when all you are given is a cloud of disconnected points? The answer that has reshaped the field over the last two decades is disarmingly simple. **Don't pick one distance — try all of them, and watch what happens.**

This article tells the story of one precise, fully verified mathematical fact at the heart of that idea: as you slowly relax your notion of "nearby," the connections between your points can only ever *appear* — never vanish. The number of links grows, step by step, monotonically, and never reverses. That monotonic growth, humble as it sounds, is the scaffolding on which the entire theory of *persistence* is built. We will state it exactly, prove its companions, and show why this one-directional growth is the mathematical license that lets a computer say, with confidence, "that's a circle."

## The Vietoris–Rips graph: turning distance into connection

Start with a finite collection of points — a *finite metric space*. All this means is: a finite set of objects together with a rule, `dist(x, y)`, telling you how far apart any two of them are. The rule obeys the obvious sanity conditions (distances are never negative, the distance from a point to itself is zero, and the triangle inequality holds: no detour is ever shorter than going direct).

Now fix a *scale* — a threshold distance we will call `ε`. Build a graph by the following rule:

> **The Rips graph at scale `ε`.** Put one vertex for each point. Draw an edge between two distinct points `x` and `y` exactly when `dist(x, y) ≤ ε`.

In symbols, two distinct vertices `x` and `y` are adjacent precisely when `x ≠ y` and `dist(x, y) ≤ ε`. This is the *Vietoris–Rips graph* (or the 1-skeleton of the Vietoris–Rips complex), named for Leopold Vietoris and Eliyahu Rips. It is the simplest possible way to turn raw distances into a network of connections.

At a tiny scale, `ε` is smaller than the gap between any two points, and the graph is just a dust of isolated vertices — no edges at all. At an enormous scale, every pair is within reach, and the graph is *complete*: every point linked to every other. Between these two extremes lies all the interesting structure. As `ε` sweeps from small to large, edges switch on one by one, and the connectivity of the graph evolves. Somewhere along the way, a scattered cloud sampled from a circle becomes a single connected ring; push `ε` further and the ring fills in to a blob. The *scale at which features appear and disappear* is exactly the data that persistent homology records.

## The one rule that makes it all work: edges only ever appear

Here is the keystone observation. Suppose you have two scales, a smaller one `ε₁` and a larger one `ε₂`, with `ε₁ ≤ ε₂`. Take any edge present at the smaller scale. By definition its two endpoints satisfy `dist(x, y) ≤ ε₁`. But `ε₁ ≤ ε₂`, so automatically `dist(x, y) ≤ ε₂`, and the edge is present at the larger scale too. Nothing is lost. The graph at scale `ε₁` sits *inside* the graph at scale `ε₂` as a subgraph.

We can state this cleanly:

> **Monotonicity of the Rips graph.** If `ε₁ ≤ ε₂`, then `ripsGraph(ε₁) ≤ ripsGraph(ε₂)` — every edge of the smaller-scale graph is also an edge of the larger-scale graph.

The proof is the one-line argument above: `dist(x, y) ≤ ε₁ ≤ ε₂`. It is so simple it is almost embarrassing — and yet it is the load-bearing wall of the whole edifice. Without it, "features that persist across scales" would be a meaningless phrase, because there would be no guarantee that a connection, once made, stays made.

To pin down the two extremes, we also record the boundary behavior. At a *negative* scale, no edge can exist, because distances are never negative — there is nothing for `dist(x, y) ≤ ε < 0` to satisfy. And in a genuine metric space (one where distinct points are always a positive distance apart), even at scale exactly `ε = 0` the graph is empty: an edge at scale 0 would force `dist(x, y) ≤ 0`, hence `dist(x, y) = 0`, hence `x = y`, contradicting the requirement that the endpoints be distinct. So the filtration starts, cleanly, from nothing.

## From a graph to a number: the edge-count profile

Monotonicity of graphs is elegant, but to *measure* the growth of shape we want a number we can plot. The most natural one is the simplest: **count the edges.**

For a finite metric space with `α` as its set of points, define, for each whole-number threshold `r`,

> **The edge-count profile.** `edgeCountProfile(r)` is the number of edges of the Rips graph at scale `r` — the size of its edge set.

(Edges are unordered pairs of distinct points, so they live naturally in the set of two-element subsets, written `Sym2(α)`. Counting them is just taking the cardinality of the graph's edge set.)

This turns the entire growing-graph story into a single staircase function on the integers. And the graph monotonicity above translates directly into a statement about this number:

> **Theorem (edge counts only grow).** If `r ≤ s`, then `edgeCountProfile(r) ≤ edgeCountProfile(s)`.

Why? Because the smaller-scale graph is a subgraph of the larger-scale one, its edge set is a *subset* of the larger edge set, and a subset of a finite set can never be larger than the set containing it. The profile is **monotone**: it climbs, plateaus, climbs again, but never descends. As an order-theoretic statement, this is exactly `Monotone(edgeCountProfile)` — the profile is a monotone (order-preserving) map from thresholds to counts.

Two further facts complete the picture and serve as honest "endpoints" for the staircase:

> **Theorem (it starts at zero).** `edgeCountProfile(0) = 0`. At threshold zero, the metric Rips graph is empty, so it has zero edges.

> **Theorem (it never overshoots).** For every threshold `r`, `edgeCountProfile(r) ≤ card(Sym2(α))`. The number of edges can never exceed the total number of unordered pairs of points, because every edge *is* such a pair.

So the profile is a non-decreasing staircase, starting at `0` and capped at the number of point-pairs, climbing one plateau at a time as the threshold passes each pairwise distance in the cloud.

## Why a single monotone staircase is so powerful

It is worth dwelling on what we have built, because its very plainness disguises its reach.

A finite metric space is a complicated object: `n` points come with `n(n−1)/2` pairwise distances, an entire web of geometric relationships. The edge-count profile compresses all of that into one monotone function `ℕ → ℕ`. Crucially, the compression is **structure-respecting in two directions at once.**

First, *within* a single space, the profile respects the order of scales: bigger threshold, more edges. That is the monotonicity theorem.

Second — and this is the deeper "bridge" — the profile behaves predictably *between* spaces. The natural maps between metric spaces are the *non-expanding* ones: functions that never stretch distances (a 1-Lipschitz map, `dist(f(x), f(y)) ≤ dist(x, y)`). If you map a space into another without stretching, near pairs stay near, so edges of the source are forced to map to edges of the target. The growing-graph construction therefore turns *maps of spaces* into *comparisons of profiles*. In categorical language, the assignment

> finite metric space  ⟼  its monotone edge-count profile

is a **functor**: it sends objects (spaces) to objects (monotone staircases) and morphisms (non-expanding maps) to morphisms (domination relations between staircases). The target of this functor is an *ordered, idempotent ("tropical") world*: the world where the only operations that matter are "take the larger" and "compare," precisely the operations that govern how features accumulate as scale increases. Monotonicity is what makes the assignment land in that ordered world at all. The title of this work — *Rips graph monotonicity as a functor into tropical valuation objects* — is exactly this bridge between the geometry of point clouds and the order theory of monotone valuations.

The profile is, in a real sense, the **discrete derivative of the distance distribution**. Each upward jump in the staircase happens exactly at a scale where one or more new pairs of points come within range. Reading off where the jumps are, and how big they are, recovers the histogram of pairwise distances. The flat stretches — the long plateaus where the count refuses to budge — are the *persistent* features: configurations stable across a wide band of scales, and therefore likely to be real signal rather than sampling noise. This is the same instinct that lets your friend across the room call a scatter of pebbles a "ring": the ring is the feature that persists.

## A second bridge: when shape moves

Geometry rarely sits still. Point clouds drift, dynamical systems iterate, images get nudged. A companion thread of this work formalizes how *continuous motion* interacts with the structures above — a bridge between topology, the algebra of repeated application, and computation.

The setting is a continuous self-map `f` of a space: a rule that moves each point to a new point, without tearing the space. Apply it once, twice, `n` times; the `n`-fold composition `f^[n]` is the *iterate*. Three facts anchor the theory.

> **Iterates stay continuous.** Every iterate `f^[n]` of a continuous map `f` is again continuous. Continuity, once you have it, survives any amount of repetition.

> **The orbit map is continuous.** Bundle the first `N` snapshots of a point's trajectory into a single vector `x ⟼ (x, f(x), f²(x), …, f^{N−1}(x))`. This *orbit map* into the product space is continuous. A nonlinear, time-evolving process is thereby repackaged as one continuous *feature map* — a clean handle for analysis and computation.

> **Geometry is transported.** Iterating a continuous map preserves the qualitative shape of any region it acts on: the image of a *compact* set stays compact, and the image of a *connected* set stays connected. Wholeness and boundedness are conserved quantities of the dynamics.

A final layer concerns *symmetry*. When two maps **commute** — `f∘g = g∘f` — the symmetry `g` passes through every iterate of `f`: `g∘f^[n] = f^[n]∘g`. More generally, a *semiconjugacy* `h∘f = g∘h` (a structure-preserving dictionary between two systems) automatically intertwines all iterates: `h∘f^[n] = g^[n]∘h`. So the orbit of a translated point is the translation of the orbit; the dynamics factor cleanly through the symmetry. These commutation laws are the algebraic seeds of *orbit factorization* — the principle that lets us reduce a complicated system to a simpler quotient by dividing out its symmetries.

Together, the two bridges share a single moral. **Monotone, structure-preserving maps are the glue of mathematics.** Whether you are growing a graph by relaxing a threshold, or evolving a space by iterating a map, the results worth proving are the ones that say: *the structure you started with is carried, faithfully and predictably, into the structure you end with.*

## What this buys the working scientist

These are not abstractions for their own sake. The edge-count profile is the computational kernel of modern shape analysis. When a biologist studies the branching pattern of a neuron, a cosmologist maps the filamentary web of galaxies, or a materials scientist characterizes the pore structure of a foam, the workhorse is exactly this: sweep a scale parameter, watch the connectivity grow, and read the persistent features off the monotone profile. Monotonicity is what guarantees the resulting "barcode" is well-defined — that a feature has an unambiguous birth and death scale, with birth never after death.

And because the profile is monotone, it is *cheap to store and fast to compare*. Two datasets can be ranked by their profiles; a profile can be summarized by its jump locations; an entire database of shapes can be indexed by these staircases. The order-theoretic, tropical character of the target — where "max" and "compare" are the only operations — is exactly what makes these summaries composable and queryable at scale.

What began as a one-line inequality, `dist(x, y) ≤ ε₁ ≤ ε₂`, ends as a complete, certified theory: a monotone functor carrying the unruly geometry of a finite point cloud into the clean, ordered, comparable world of tropical valuations. The pebbles on the table really do spell "circle" — and now we can prove, exactly and without exception, that the proof never runs backward.
