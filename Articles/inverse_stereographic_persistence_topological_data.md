# Measuring Shape on a Sphere Without Flattening It Away

## A corrected route from stereographic maps to persistent topology

A telescope does not hand us a flat cloud of data. Directions in the sky live on a sphere. Nor is every molecular data set naturally planar: orientations, rotations, and directional features often occupy curved spaces. Yet many of the standard tools of topological data analysis begin with points in ordinary Euclidean space, where distance is measured by a ruler.

This creates an enticing possibility. Stereographic projection turns a sphere with one point removed into a plane. Why not project spherical data, run familiar Euclidean algorithms, and translate the answer back?

The broad idea is sound, but only if distance is translated exactly. Stereographic projection preserves angles, not lengths. Near the omitted pole it stretches the sphere dramatically. A formula depending only on the planar separation of two projected points therefore cannot, in general, recover their spherical separation. The location of each endpoint matters.

The central result developed here identifies the correct endpoint-dependent weight, proves that it transports two standard topological filtrations exactly, and gives a simple counterexample to a tempting but incorrect radial shortcut.

## Two ways to measure separation on a sphere

Let $S^n$ be the unit sphere in $\mathbb R^{n+1}$. There are two common spherical distances. The **chordal distance** between points $p,q\in S^n$ is the ordinary Euclidean length of the chord joining them:

$$
c(p,q)=\lVert p-q\rVert.
$$

The **geodesic distance** is the length of the shorter great-circle arc between them. If that arc subtends an angle $\theta\in[0,\pi]$, then chord and arc satisfy

$$
c=2\sin(\theta/2),
\qquad
\theta=2\arcsin(c/2).
$$

Thus chordal and geodesic distance contain the same pairwise information, but use different scales.

Now remove the north pole and identify the remainder of $S^n$ with $\mathbb R^n$ by stereographic projection. If $x,y\in\mathbb R^n$ are planar coordinates and $P(x),P(y)\in S^n$ their inverse stereographic images, direct calculation gives

$$
\lVert P(x)-P(y)\rVert
=
\frac{2\lVert x-y\rVert}
{\sqrt{(1+\lVert x\rVert^2)(1+\lVert y\rVert^2)}}.
$$

Call the right-hand side $d_c(x,y)$. It is the exact pullback of spherical chordal distance. The corresponding geodesic distance is

$$
d_g(x,y)=2\arcsin\!\left(\frac{d_c(x,y)}{2}\right).
$$

These formulas expose the essential geometry. The numerator records ordinary planar separation. The denominator records where both endpoints sit relative to the origin. Equal planar gaps can represent different spherical gaps because stereographic magnification changes with position.

## Why the radial shortcut fails

A proposed alternative was to transform only the Euclidean separation $d=\lVert x-y\rVert$ by

$$
r(d)=\frac{2d}{1+d^2/4}.
$$

This expression looks plausible: it is bounded, smooth, and behaves like $2d$ for small $d$. But it ignores $\lVert x\rVert$ and $\lVert y\rVert$ separately. That omission is fatal.

Consider the one-dimensional stereographic chart and the points $x=0$ and $y=2$. Their Euclidean separation is $2$, so

$$
r(2)=\frac{4}{1+1}=2.
$$

The true chordal distance is instead

$$
d_c(0,2)
=
\frac{2\cdot2}{\sqrt{(1+0^2)(1+2^2)}}
=
\frac{4}{\sqrt5}
<2.
$$

So the radial formula does not reproduce even chordal spherical distance. It also cannot reproduce geodesic distance, whose correct value is $2\arcsin(2/\sqrt5)$. This is not a minor numerical discrepancy; it shows that no location-blind use of this formula can give exact spherical persistence.

The deeper obstruction is translation. Compare two planar pairs having the same separation but lying at different distances from the origin. The numerator of $d_c$ stays fixed while its denominator changes. Therefore there is no single function of $\lVert x-y\rVert$ alone that equals inverse-stereographic chordal distance for every pair.

## From distances to evolving topological shapes

Persistent homology studies how topological features appear and disappear as a scale parameter grows. Two standard constructions are the Vietoris--Rips and Čech filtrations.

Given a finite labelled cloud $X=\{x_i\}$ and a distance $d$, a finite set of labels $\sigma$ is a **Vietoris--Rips face at scale $\varepsilon$** when every pair of its vertices lies within the threshold:

$$
d(x_i,x_j)\le\varepsilon
\quad\text{for all }i,j\in\sigma.
$$

A finite set $\sigma$ is a **Čech face at radius $\varepsilon$** when the closed balls of radius $\varepsilon$ around all its vertices share a common center. Equivalently, there is a point $z$ such that

$$
d(z,x_i)\le\varepsilon
\quad\text{for every }i\in\sigma.
$$

As $\varepsilon$ increases, faces are added but never removed. The resulting nested complexes form a filtration. Homology tracks connected components, loops, voids, and higher-dimensional holes through this evolution; a persistence diagram summarizes their lifetimes.

## Exact transport of the filtrations

The key preservation theorem is almost transparent once the correct metric is used.

**Exact Vietoris--Rips Transport Theorem.** Let $X$ be a finite point cloud contained in a stereographic chart. For every scale $\varepsilon$ and every finite vertex set $\sigma$, $\sigma$ is a Vietoris--Rips face of the inverse images on the sphere under chordal distance if and only if it is a Vietoris--Rips face of the chart points under

$$
d_c(x,y)=\frac{2\lVert x-y\rVert}{\sqrt{(1+\lVert x\rVert^2)(1+\lVert y\rVert^2)}}.
$$

Indeed, every pairwise spherical chord length is exactly equal to the weighted chart distance. Hence every threshold comparison is unchanged.

**Exact Chart-Centered Čech Transport Theorem.** Under the same assumptions, and requiring the common center to lie in the stereographic chart, $\sigma$ is a spherical chordal Čech face at radius $\varepsilon$ if and only if it is a weighted Čech face in $\mathbb R^n$ at the same radius.

Here too the reason is equality of distances, now applied between a candidate center and each vertex. The qualification about centers matters: the omitted pole has no finite chart coordinate. A spherical family of balls whose only useful common center is that pole requires separate treatment.

Because the faces agree at every scale, the filtered simplicial complexes agree, not merely their numerical summaries. Consequently their homology groups, persistence modules, barcodes, and persistence diagrams agree exactly.

For geodesic Vietoris--Rips persistence, one may either use $d_g$ directly or reparameterize chordal scale. A geodesic threshold $\varepsilon\in[0,\pi]$ corresponds to the chordal threshold

$$
2\sin(\varepsilon/2).
$$

This monotone change of scale preserves the order in which faces enter while relabelling their birth times.

## A practical algorithm

The corrected computational pipeline is straightforward.

First, represent each spherical point away from the omitted pole by its stereographic coordinate $x_i\in\mathbb R^n$. Next precompute $s_i=\sqrt{1+\lVert x_i\rVert^2}$. For every required pair, calculate

$$
d_c(x_i,x_j)=\frac{2\lVert x_i-x_j\rVert}{s_i s_j}.
$$

Use this matrix in a standard Vietoris--Rips persistence routine. For geodesic scales, transform each entry by $2\arcsin(d_c/2)$, with harmless numerical clipping of $d_c/2$ into $[0,1]$.

This method is exact at the mathematical level, but exactness does not magically remove the cost of dense output. A full $N\times N$ distance matrix contains on the order of $N^2$ entries, so explicitly producing it requires quadratic work and storage. Claims of $O(N\log N)$ exact performance need additional structure: sparsity, bounded dimension, neighborhood truncation, an implicit distance oracle, or output-sensitive computation.

That distinction is practically important. The geometry provides correctness; the data structure and output model determine complexity.

## Where the correction matters

Directional data arise throughout science. Cosmic microwave background measurements are indexed by directions on the celestial sphere. Atmospheric and geophysical observations cover a curved planet. Protein geometry includes orientations and angular conformations. In each setting, flattening can create false notions of proximity: points close to the omitted pole may fly far apart in the chart, while distant chart locations can represent moderate spherical separations.

The endpoint-dependent denominator repairs that distortion exactly. It lets planar software operate on chart coordinates without pretending that the chart is metrically flat.

The lesson reaches beyond stereographic projection. A coordinate transformation is not merely a change in how points are written; it changes how metric questions must be asked. Conformality preserves infinitesimal angles, but persistent homology is built from finite distances. The correct bridge is therefore not an appeal to conformal invariance. It is an explicit equality of the relevant distances.

The result is both a warning and a constructive recipe. The warning is that a beautiful radial formula can still erase essential positional information. The recipe is to pull the spherical metric back to the chart, preserve every filtration inequality exactly, and then apply the full machinery of persistent topology with confidence.
## What a persistence diagram sees

Imagine increasing $\varepsilon$ as if turning a focus knob. At tiny scales, every sample is isolated. As the threshold grows, nearby samples connect, components merge, loops form, and eventually those loops fill. A persistence interval records the scale at which a feature is born and the scale at which it dies. Long intervals often signal structure that survives changes of resolution; short ones may reflect sampling variation.

This picture also explains why an incorrect metric is consequential. If even one family of pairwise thresholds is shifted, edges can enter in a different order. Different triangles then appear, and a loop may be created too early or filled too late. A visually modest distance error can therefore alter a barcode qualitatively. Exact equality of all transported distances is much stronger than approximate visual agreement between two point plots.

The weighted formula protects the entire chain of consequences. It preserves each edge threshold, hence each Vietoris--Rips simplex threshold, because a simplex enters when its longest edge does. For a chart-centered Čech complex it preserves every test for a common ball center. The agreement reaches all homological dimensions at once; it is not restricted to connected components or loops.

## A small thought experiment

Take two pairs of points on a line in the chart: $(0,1)$ and $(1,2)$. Both pairs are one unit apart in ordinary Euclidean distance. Yet their weighted chordal distances are

$$
d_c(0,1)=\sqrt2
$$

and

$$
d_c(1,2)=\frac{2}{\sqrt{10}}.
$$

The second pair lies farther from the chart origin, where the same planar step corresponds to a shorter chord on the sphere. Any correction that sees only the number $1$ must assign both pairs the same answer and therefore cannot be exact. This experiment makes the role of the two endpoint norms tangible without requiring a picture of the projection.

A useful implementation test follows immediately. Generate points on a sphere, project them, and construct two distance matrices: one directly from spherical coordinates, the other from the weighted chart formula. Their entries should agree up to floating-point roundoff. At every chosen threshold, the sets of Vietoris--Rips edges should then coincide exactly. Testing clouds of $50$, $100$, and $200$ points exercises the identity over thousands of geometrically varied pairs.

## The broader principle

Coordinates are chosen for convenience; geometry determines meaning. Stereographic coordinates are exceptionally useful because they are smooth, global except for one point, and angle-preserving. None of those virtues makes ordinary planar distance the right metric. Pulling back the desired spherical metric does.

That principle is portable. Whenever data are transformed before topology is computed, one should ask which metric on the transformed coordinates makes the transformation an isometry. If such a metric is available, filtration equivalence can often be proved face by face. If only inequalities are available, one may instead seek stability bounds. Here the fortunate outcome is exact equality, provided the weight depends on both endpoints and the omitted pole is treated honestly.
