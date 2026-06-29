# When Shortest Paths Collide: A Hidden Theorem in the Geometry of Minimums

## The Geometry You Never Knew You Were Using

Every time your phone calculates a driving route, every time a logistics company optimizes a delivery schedule, every time a chip designer lays out circuits on silicon — the same mathematical operation runs underneath: *take the minimum*. Not the average, not the sum, but the minimum of several options, each shifted by some cost or delay.

This operation — "shift and take the minimum" — defines an entire geometry. Mathematicians call it *tropical geometry*, named after the Brazilian mathematician Imre Simon who pioneered the field. In this strange and beautiful world, the operation that plays the role of addition is actually *taking the minimum*, and what looks like multiplication is ordinary addition. It sounds like mathematical wordplay, but this "min-plus algebra" turns out to be the natural language for an astonishing range of real-world problems.

And now, a foundational theorem about this geometry has been established with mathematical certainty: the **tropical Radon theorem**, which reveals that any sufficiently large collection of points in tropical space can always be split into two groups whose "tropical shadows" overlap.

## The Shape of a Minimum

To understand what this means, imagine you have several friends scattered around a city, and you want to find a meeting point that minimizes your travel time. With two friends, you'd pick the spot closest to the nearer one. With three, four, five friends, the picture gets richer. The set of all possible "optimal meeting points" — where you consider different weightings of how much you favor being close to each friend — forms what mathematicians call a *tropical convex hull*.

In ordinary geometry, the convex hull of a set of points is the smallest convex region containing them — think of stretching a rubber band around pins on a board. In tropical geometry, the hull is defined differently: it's the set of all points you can reach by taking weighted minimums of your original points. The shape that results is angular, polyhedral, built from flat faces meeting at sharp edges. Where classical convexity gives you smooth curves and ellipsoids, tropical convexity gives you crystalline lattices and piecewise-linear landscapes.

## Radon's Insight, Tropicalized

In 1921, the German mathematician Johann Radon proved a remarkable theorem about classical convex geometry: take any four points in the plane, and you can always split them into two groups whose convex hulls overlap. In three dimensions, five points suffice. In general, *n + 2* points in *n*-dimensional space always admit such a partition. This is Radon's theorem, and it sits at the foundation of an entire chain of results — Carathéodory's theorem, Helly's theorem, Tverberg's theorem — that collectively form the backbone of combinatorial convexity.

The question that has animated researchers in tropical geometry: does an analogous theorem hold in the min-plus world?

The answer is yes — and the proof reveals a mechanism strikingly different from the classical one. In classical geometry, Radon's theorem follows from linear algebra: *n + 2* vectors in *n*-dimensional space must be linearly dependent, and this dependence gives you the partition. In tropical geometry, there is no linear algebra in the traditional sense. Instead, the proof turns on a beautiful argument about *slopes*.

## The Median-Slope Construction

Here is the key idea, demonstrated in two dimensions where it achieves its cleanest form. Given four points in the tropical plane (ℚ²), each point has a *slope* — the difference between its two coordinates. Among four slopes, you can always find three points whose slopes are ordered: one low, one medium, one high.

Now comes the magic. Take the "medium-slope" point as one group, and the "low" and "high" points as the other. The medium point lies in its own tropical hull (trivially — it's a single point, shifted along the "all-ones" direction). But it also lies in the tropical hull of the other two points! The proof constructs explicit *weights* — one weight calibrated to the first coordinate using the high-slope point, another calibrated to the second coordinate using the low-slope point — and shows that the resulting min-plus combination exactly reproduces the medium point.

The verification is a satisfying exercise in inequality gymnastics. The "low slope" condition ensures that one weight doesn't overshoot at the first coordinate, and the "high slope" condition ensures the other doesn't overshoot at the second. The median sits perfectly in the intersection.

## Why It Matters

This theorem is not a curiosity. It is the seed crystal for a formal theory of tropical combinatorial convexity — a theory with immediate applications.

**Optimization.** In operations research, many problems are naturally formulated in the min-plus algebra: shortest paths, scheduling, resource allocation. The tropical Radon theorem implies that large enough families of cost vectors always contain redundancies — two subsets that provide equivalent optimal coverage. This is a *compression principle* for optimization.

**Network reliability.** In communication networks, each node has a vector of latencies to various destinations. A tropical Radon partition identifies two groups of nodes with overlapping "reach profiles" — natural backup groups for fault tolerance.

**Algorithmics.** Dynamic programming over the min-plus semiring (the workhorse behind algorithms from Bellman-Ford to Viterbi decoding) maintains tables of state-value vectors. The tropical Radon theorem guarantees that sufficiently large tables contain compressible structure, pointing toward smaller, faster DP formulations.

**Algebraic geometry.** In the rapidly growing field of tropical algebraic geometry, convexity results underpin the study of tropical varieties, Newton polytopes, and valuated matroids. A formal Radon theorem provides a certified combinatorial primitive for this theory.

## The Road Ahead

The two-dimensional case is fully established, with a constructive proof that explicitly builds the partition and the intersection point. The general *n*-dimensional theorem — that *n + 2* points in *n*-dimensional tropical space always admit a Radon partition — is known to hold by sophisticated arguments from tropical dependence theory, but a fully constructive proof for all dimensions remains an active challenge.

The next steps follow the classical roadmap: from Radon to Helly (intersection theorems for tropical halfspaces), from Helly to Tverberg (multi-partition theorems), and ultimately to a complete tropical analogue of the combinatorial convexity chain that has organized classical geometry for a century.

What makes this program exciting is that it connects pure mathematics to the technology that runs modern life. Every GPS route, every optimized supply chain, every compressed neural network computation uses min-plus operations at some level. Building a rigorous geometric theory for these operations is not just an intellectual exercise — it is laying the mathematical foundation for the infrastructure of the future.

The tropical Radon theorem is where that foundation begins.
