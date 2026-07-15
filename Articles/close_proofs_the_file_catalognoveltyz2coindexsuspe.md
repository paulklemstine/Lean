# When Antipodes Meet Pigeonholes: A Finite Model of the Borsuk–Ulam Obstruction

Imagine a shape whose every point has a designated opposite. On a circle, antipodal points sit across the center; on an ordinary sphere, they lie at opposite ends of a diameter. Equivariant topology asks what maps can do when they are required to respect this pairing: opposites must always be sent to opposites.

That innocent rule creates powerful obstructions. The classical Borsuk–Ulam phenomenon says, in one guise, that a sphere cannot be compressed equivariantly into a sphere of lower dimension. Usually this belongs to continuous topology, where points vary through infinitely many positions. But for a particularly elegant family of triangulated spheres—the boundaries of cross-polytopes—the entire obstruction becomes finite. It reduces to a rule about coordinate axes, an injection, and ultimately the pigeonhole principle.

The result is a complete classification: an antipode-preserving simplicial map from the $m$-dimensional cross-polytope sphere to the $n$-dimensional one exists exactly when $m\le n$. It also reveals precisely why suspension raises the coindex by one and no more.

## Spheres made from signed coordinate directions

The $(n+1)$-dimensional cross-polytope is the convex hull of the signed coordinate vectors

$$
\pm e_0,\pm e_1,\ldots,\pm e_n.
$$

Its boundary is an $n$-dimensional triangulated sphere. For $n=0$ it is simply two points. For $n=1$ it is a diamond-shaped circle. For $n=2$ it is the surface of an octahedron. In every dimension its vertices can be written as pairs $(i,\varepsilon)$, where $i\in\{0,\ldots,n\}$ chooses a coordinate axis and $\varepsilon\in\{+1,-1\}$ chooses a sign.

The antipodal involution flips the sign:

$$
(i,\varepsilon)\longmapsto(i,-\varepsilon).
$$

A set of vertices spans a face exactly when it contains no antipodal pair. Thus a simplex may choose several axes and one sign on each, but it may never contain both $(i,+1)$ and $(i,-1)$.

Now consider a vertex map from the $m$-sphere of this kind to the $n$-sphere. It is **equivariant** if it respects antipodes, and **simplicial** if it carries every face to a face. Equivariance means that once the images of the positive source vertices $(i,+1)$ are known, all negative images are forced. If

$$
(i,+1)\longmapsto\bigl(a(i),\sigma(i)\bigr),
$$

then necessarily

$$
(i,-1)\longmapsto\bigl(a(i),-\sigma(i)\bigr).
$$

Here $a(i)$ is a target coordinate and $\sigma(i)$ is a freely chosen sign. The apparently topological question has therefore become a question about two finite pieces of data: a coordinate assignment $a$ and a sign assignment $\sigma$.

## The collision that explains everything

The central observation is the **Coordinate-Axis Lemma**: an equivariant vertex map is simplicial if and only if its coordinate assignment $a$ is injective.

Why must $a$ be injective? Suppose two distinct source axes $i$ and $j$ are sent to the same target axis. Their positive vertices may arrive with equal signs or opposite signs. If the signs are opposite, the two positive source vertices already form a legal source face but their images are antipodal, so the image is not a face. If the signs are equal, use the positive vertex from one source axis and the negative vertex from the other. Those source vertices are still not antipodal, yet their images are. Either way, a coordinate collision manufactures a forbidden antipodal target pair.

Conversely, suppose $a$ is injective. If two image vertices are antipodal, then they share a target coordinate. Injectivity forces their source coordinates to agree. Equivariance then forces their source signs to be opposite, so the source vertices were themselves antipodal. Therefore no legitimate source face can acquire a forbidden antipodal pair. The map is simplicial.

The signs do not obstruct existence at all. They decorate a map, but coordinate injectivity decides whether it is valid.

## A complete existence theorem

There are $m+1$ source axes and $n+1$ target axes. By the Coordinate-Axis Lemma, an equivariant simplicial map exists exactly when there is an injection

$$
\{0,1,\ldots,m\}\hookrightarrow\{0,1,\ldots,n\}.
$$

The pigeonhole principle now gives the **Exact Mapping Classification**:

> An equivariant simplicial map from the boundary of the $(m+1)$-cross-polytope to the boundary of the $(n+1)$-cross-polytope exists if and only if $m\le n$.

The forward implication is the obstruction: an injection of $m+1$ axes into $n+1$ axes requires $m+1\le n+1$. The reverse implication is constructive. When $m\le n$, send each source axis to the target axis with the same index and preserve signs. This is the standard equatorial inclusion.

A finite Borsuk–Ulam theorem follows immediately:

> For every $n\ge0$, there is no equivariant simplicial map from the $(n+1)$-dimensional cross-polytope sphere to the $n$-dimensional cross-polytope sphere.

Indeed, such a map would require injecting $n+2$ source axes into only $n+1$ target axes. The familiar low-dimensional impossibilities are merely the first cases: the diamond-shaped circle cannot map antipodally and simplicially to two points, and the octahedral sphere cannot map in this fashion to the diamond-shaped circle. The same single collision argument handles every dimension.

## Coindex: measuring how large a sphere fits

For a space with a free antipodal symmetry, its $\mathbb Z_2$-coindex measures the largest dimension of an antipodal sphere that maps equivariantly into it. In this finite setting, define the coindex of the $n$-dimensional cross-polytope sphere to be the largest $m$ for which an equivariant simplicial map from the $m$-dimensional cross-polytope sphere exists.

The classification says that the admissible dimensions are exactly

$$
0,1,\ldots,n.
$$

Therefore the coindex is exactly $n$. The lower bound is visible through equatorial inclusions; the upper bound is the axis-counting obstruction. Neither half is dispensable: explicit maps show what can be done, while injectivity proves that nothing larger is possible.

## Suspension adds exactly one

Suspension takes a space, adds a north pole and a south pole, and joins every old point to both poles. For cross-polytope spheres, suspension has an especially concrete meaning: it adds one new signed coordinate axis. Suspending the $m$-dimensional cross-polytope sphere produces the $(m+1)$-dimensional one.

If a map uses an injection from $m+1$ source axes to $n+1$ target axes, its suspension extends that injection by sending the new source axis to the new target axis. So suspension carries valid maps to valid maps.

More strikingly, existence also reflects backward. The **Suspension Existence Theorem** states

> An equivariant simplicial map from the suspended $m$-sphere to the suspended $n$-sphere exists if and only if an equivariant simplicial map from the original $m$-sphere to the original $n$-sphere exists.

Numerically, both statements reduce to the same inequality:

$$
(m+1)\le(n+1)\quad\Longleftrightarrow\quad m\le n.
$$

Thus suspension raises the coindex by exactly one. It cannot create a mysterious excess. The new dimension comes from one—and only one—new coordinate axis.

## Why this finite picture matters

Cross-polytopes appear wherever the geometry of the $\ell^1$ norm matters: optimization, sparse representations, and signed-coordinate models all inherit their sharp corners and axis-based structure. The theorem does not claim that every such application is secretly topological. It shows something subtler: when a problem combines signed coordinates with a rule preserving opposites, dimension becomes a resource that can be counted. Each independent source axis needs its own target channel. Reusing a channel is not harmless compression; it creates a detectable antipodal conflict.

This also changes how one might explain Borsuk–Ulam phenomena. Instead of beginning with a global paradox on a smooth sphere, one can begin with an octahedron and ask students to label opposite vertices oppositely. The inevitable failed edge is visible by inspection. Higher dimensions add no new mystery, only more axes. The finite model therefore provides both an intuition pump and a rigorous theorem in its own right.

This model shows how a topological obstruction can hide a discrete invariant. The geometric language involves spheres, antipodes, faces, and suspension. Beneath it lies a bipartite matching problem: assign distinct target axes to source axes. A failed map has a short certificate—two source axes that collide—and the collision can always be converted into a forbidden antipodal image pair.

That viewpoint connects the result to algorithms. To test a proposed map, one need only record the target coordinate selected by each positive source vertex and check for duplicates. With $m+1$ axes, a hash table gives expected linear time, while sorting gives deterministic time $O(m\log m)$. Constructing a map when $m\le n$ is immediate. The obstruction is not merely existential; it is computationally transparent.

The same idea hints at richer classifications. Because signs are independent once coordinates are injective, valid maps should be counted by choosing an ordered injection and then choosing one sign per source axis. This predicts

$$
2^{m+1}\frac{(n+1)!}{(n-m)!}
$$

maps when $m\le n$, and none otherwise. Symmetries of the cross-polytope—signed coordinate permutations—should then identify all such maps with the standard inclusion up to changes of coordinates.

There are also natural extensions. Joining two cross-polytope spheres concatenates their axis systems, suggesting an additive coindex formula with a one-dimensional shift. For general free involutive complexes, coordinate axes disappear, but Tucker-type labelings may replace them and turn the failure of a map into a finite combinatorial certificate.

The essential lesson is already complete. In cross-polytope spheres, antipodal topology is governed by an exact finite law: distinct source axes require distinct target axes. From that one law come the mapping classification, the all-dimensional Borsuk–Ulam obstruction, the exact coindex, and the sharp behavior of suspension. A theorem about spheres ends as a theorem about pigeonholes—but the route between them explains both.