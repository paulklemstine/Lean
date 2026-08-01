# Exact Inverse-Stereographic Transport of Spherical Persistence

## Endpoint-dependent metrics, filtration equivalence, and a counterexample to radial weighting

**Author:** Aristotle  
**Date:** 2026-08-01

## Abstract

Persistent homology on spherical data should respect spherical rather than planar distance. Stereographic coordinates offer access to Euclidean computational infrastructure, but stereographic projection is conformal, not isometric: finite distances cannot be corrected by a function of planar separation alone. This paper derives the exact endpoint-dependent pullback of chordal distance under inverse stereographic projection,

$$
d_c(x,y)=\frac{2\lVert x-y\rVert}{\sqrt{(1+\lVert x\rVert^2)(1+\lVert y\rVert^2)}},
$$

and the corresponding geodesic distance

$$
d_g(x,y)=2\arcsin\!\left(\frac{d_c(x,y)}2\right).
$$

We prove that $d_c$ transports every Vietoris--Rips face and every chart-centered Čech face at exactly the same filtration parameter. Hence the associated filtered complexes and persistence invariants coincide. We also disprove the proposed endpoint-independent radial transform $r(d)=2d/(1+d^2/4)$ by the explicit pair $x=0$, $y=2$, for which $r(2)=2$ while the true chordal distance is $4/\sqrt5<2$. We give algorithms for exact weighted distance construction, filtration generation, and numerical validation, and clarify that an explicit dense pairwise filtration still has quadratic output cost. The results provide a precise and implementable foundation for topological data analysis of spherical point clouds represented in stereographic coordinates.

## 1. Introduction

Many data sets are intrinsically directional. Astronomical observations are indexed by celestial direction, geophysical measurements by location on a planet, and molecular data often include orientations or angular configurations. Such observations naturally lie on a sphere $S^n$, or on a space containing spherical factors. Applying a Euclidean metric after choosing planar coordinates can alter neighborhood relations and therefore alter the topology inferred from the data.

Persistent homology extracts multiscale topology from a metric point cloud. Its input is not merely a set of coordinates but a family of distance inequalities. If coordinates are changed, those inequalities must be transported correctly. Stereographic projection is especially attractive because it maps the sphere minus one pole bijectively and smoothly to Euclidean space and preserves angles. However, conformality is an infinitesimal statement. Vietoris--Rips and Čech filtrations depend on finite pairwise and center-to-vertex distances. Their preservation requires an exact pullback metric, not merely an angle-preserving coordinate map.

This paper makes four contributions. First, it states the exact chordal and geodesic metrics in stereographic coordinates. Second, it proves equality of chordal Vietoris--Rips filtrations and chart-centered chordal Čech filtrations under these coordinates. Third, it gives a certified elementary counterexample to a proposed correction depending only on Euclidean separation. Fourth, it presents computational procedures and distinguishes geometric correctness from complexity claims.

The conclusions are exact at the level of filtered complexes. Equality of persistence diagrams follows because each simplex enters at the same scale. For geodesic distance, exact transport follows either by applying the chord-to-arc transform to each pair or by monotonically reparameterizing a chordal Vietoris--Rips filtration.

## 2. Stereographic geometry

### 2.1. The sphere and its chart

Let

$$
S^n=\{p\in\mathbb R^{n+1}:\lVert p\rVert=1\}
$$

be the unit sphere, and let $N=(0,\ldots,0,1)$ be the north pole. Inverse stereographic projection from $\mathbb R^n$ to $S^n\setminus\{N\}$ is the map $P$ defined by

$$
P(x)=\left(\frac{2x}{1+\lVert x\rVert^2},
\frac{\lVert x\rVert^2-1}{1+\lVert x\rVert^2}\right).
$$

The first component is an $n$-vector and the last component is scalar. A direct expansion verifies $\lVert P(x)\rVert=1$. As $\lVert x\rVert\to\infty$, the image approaches $N$.

### 2.2. Chordal and geodesic distance

**Definition 2.1 (Chordal distance).** For $p,q\in S^n$, their chordal distance is

$$
d_{\mathrm{ch}}(p,q)=\lVert p-q\rVert.
$$

**Definition 2.2 (Geodesic distance).** For $p,q\in S^n$, their geodesic distance is

$$
d_{\mathrm{geo}}(p,q)=\arccos(p\cdot q)\in[0,\pi].
$$

If $\theta=d_{\mathrm{geo}}(p,q)$ and $c=d_{\mathrm{ch}}(p,q)$, the isosceles triangle formed by $0,p,q$ yields

$$
c^2=2-2\cos\theta=4\sin^2(\theta/2).
$$

Since $\theta/2\in[0,\pi/2]$,

$$
c=2\sin(\theta/2),
\qquad
\theta=2\arcsin(c/2).
$$

### 2.3. The exact pullback metrics

**Definition 2.3 (Weighted chordal distance).** For $x,y\in\mathbb R^n$, define

$$
d_c(x,y)=
\frac{2\lVert x-y\rVert}
{\sqrt{(1+\lVert x\rVert^2)(1+\lVert y\rVert^2)}}.
$$

**Lemma 2.4 (Inverse-stereographic chord identity).** For every $x,y\in\mathbb R^n$,

$$
d_{\mathrm{ch}}(P(x),P(y))=d_c(x,y).
$$

**Proof sketch.** Substitute the formula for $P(x)$ and $P(y)$ into $\lVert P(x)-P(y)\rVert^2$. Put the terms over the common denominator $(1+\lVert x\rVert^2)^2(1+\lVert y\rVert^2)^2$. Expanding the numerator and collecting inner-product terms reduces it to

$$
4\lVert x-y\rVert^2(1+\lVert x\rVert^2)(1+\lVert y\rVert^2).
$$

After cancellation,

$$
\lVert P(x)-P(y)\rVert^2=
\frac{4\lVert x-y\rVert^2}
{(1+\lVert x\rVert^2)(1+\lVert y\rVert^2)}.
$$

Both sides are nonnegative, so taking square roots proves the identity. $\square$

**Definition 2.5 (Weighted geodesic distance).** Define

$$
d_g(x,y)=2\arcsin\!\left(\frac{d_c(x,y)}2\right).
$$

The value $d_c(x,y)$ lies in $[0,2]$ because it is a chord length on the unit sphere, so the definition is well posed.

**Theorem 2.6 (Exact geodesic transport).** For every $x,y\in\mathbb R^n$,

$$
d_g(x,y)=d_{\mathrm{geo}}(P(x),P(y)).
$$

**Proof sketch.** Lemma 2.4 identifies $d_c(x,y)$ with the spherical chord length. Apply the chord-to-arc identity $\theta=2\arcsin(c/2)$. $\square$

The denominator in $d_c$ is endpoint-dependent. It is not a function of $\lVert x-y\rVert$ alone. This feature is required by the nonuniform scale distortion of stereographic projection.

## 3. Filtered complexes

Let $I$ be a finite label set and let $X:I\to\mathbb R^n$ be a point cloud in stereographic coordinates. Let $d$ be a nonnegative symmetric distance function on the chart.

**Definition 3.1 (Vietoris--Rips face).** A finite subset $\sigma\subseteq I$ is a Vietoris--Rips face at scale $\varepsilon$ if

$$
d(X(i),X(j))\le\varepsilon
\quad\text{for all }i,j\in\sigma.
$$

The collection of all such faces is the Vietoris--Rips complex $\operatorname{VR}_\varepsilon(X,d)$.

**Definition 3.2 (Čech face).** A finite subset $\sigma\subseteq I$ is a Čech face at radius $\varepsilon$ if there exists a center $z\in\mathbb R^n$ such that

$$
d(z,X(i))\le\varepsilon
\quad\text{for every }i\in\sigma.
$$

The collection of these faces is the chart-centered Čech complex $\operatorname{Cech}_\varepsilon(X,d)$. Equivalently, the closed $d$-balls of radius $\varepsilon$ around the vertices have nonempty intersection in the chart.

Both constructions are monotone in $\varepsilon$: if $\varepsilon\le\varepsilon'$, every face at scale $\varepsilon$ is also a face at scale $\varepsilon'$. Thus each construction gives a filtered simplicial complex.

Let $P\circ X:I\to S^n\setminus\{N\}$ denote the corresponding spherical cloud.

## 4. Exact filtration transport

**Theorem 4.1 (Vietoris--Rips face transport).** For every finite $\sigma\subseteq I$ and every real threshold $\varepsilon$,

$$
\sigma\in\operatorname{VR}_\varepsilon(P\circ X,d_{\mathrm{ch}})
\quad\Longleftrightarrow\quad
\sigma\in\operatorname{VR}_\varepsilon(X,d_c).
$$

**Proof sketch.** By Definition 3.1, the left side is the family of inequalities

$$
d_{\mathrm{ch}}(P(X(i)),P(X(j)))\le\varepsilon
$$

for all $i,j\in\sigma$. Lemma 2.4 replaces each left-hand side exactly by $d_c(X(i),X(j))$. The resulting inequalities are precisely the right side. $\square$

**Corollary 4.2 (Equality of chordal Vietoris--Rips filtrations).** The spherical chordal Vietoris--Rips filtration of $P\circ X$ and the weighted chart filtration of $X$ have exactly the same labelled simplices at every parameter.

**Proof sketch.** Theorem 4.1 applies independently to every finite label set and every threshold. $\square$

For Čech complexes, the omitted pole requires explicit attention.

**Theorem 4.3 (Chart-centered Čech face transport).** For every finite $\sigma\subseteq I$ and every real radius $\varepsilon$, the following are equivalent:

1. there exists $z\in\mathbb R^n$ such that $d_c(z,X(i))\le\varepsilon$ for every $i\in\sigma$;
2. there exists a spherical center $P(z)\in S^n\setminus\{N\}$ such that $d_{\mathrm{ch}}(P(z),P(X(i)))\le\varepsilon$ for every $i\in\sigma$.

Consequently,

$$
\sigma\in\operatorname{Cech}_\varepsilon(X,d_c)
\quad\Longleftrightarrow\quad
\sigma\in\operatorname{Cech}^{\,S^n\setminus\{N\}}_\varepsilon(P\circ X,d_{\mathrm{ch}}),
$$

where the superscript indicates that common centers are restricted to the stereographic chart.

**Proof sketch.** If $z$ is a chart center, Lemma 2.4 gives

$$
d_c(z,X(i))=d_{\mathrm{ch}}(P(z),P(X(i)))
$$

for every vertex. Hence all ball inequalities are preserved. Conversely, every permitted spherical center has a unique finite stereographic coordinate $z$, and the same identity transports the inequalities back. $\square$

**Remark 4.4 (The omitted pole).** Theorem 4.3 does not claim equivalence with a spherical Čech complex whose centers may include $N$. A family of spherical balls may admit $N$ as a common center even when the relevant intersection behavior cannot be represented by a finite chart center. Full spherical Čech transport therefore needs either a second chart, an explicit point at infinity, or a condition guaranteeing a common center different from $N$.

**Corollary 4.5 (Persistence equivalence).** Over any fixed coefficient field, the chordal Vietoris--Rips persistence modules of $P\circ X$ and $(X,d_c)$ are naturally identical. The same holds for chart-centered chordal Čech persistence. In particular, whenever persistence diagrams are defined for these finite filtrations, the corresponding diagrams are equal.

**Proof sketch.** The filtered complexes contain the same labelled simplices at every scale and have the same inclusion maps. Applying simplicial homology degree by degree therefore gives identical persistence modules, from which equality of barcodes and diagrams follows. $\square$

This conclusion uses exact metric transport, not a general claim that persistence diagrams are invariant under conformal transformations. Arbitrary conformal maps need not preserve finite distances or filtration thresholds.

## 5. Geodesic filtrations

**Theorem 5.1 (Geodesic Vietoris--Rips transport).** For every finite $\sigma\subseteq I$ and $\varepsilon\in[0,\pi]$,

$$
\sigma\in\operatorname{VR}_\varepsilon(P\circ X,d_{\mathrm{geo}})
\quad\Longleftrightarrow\quad
\sigma\in\operatorname{VR}_\varepsilon(X,d_g).
$$

**Proof sketch.** Replace every spherical geodesic distance by the equal weighted geodesic distance from Theorem 2.6. $\square$

**Proposition 5.2 (Chordal reparameterization).** For $\varepsilon\in[0,\pi]$,

$$
\operatorname{VR}_\varepsilon(P\circ X,d_{\mathrm{geo}})
=
\operatorname{VR}_{2\sin(\varepsilon/2)}(X,d_c).
$$

**Proof sketch.** For a pair with geodesic distance $\theta\in[0,\pi]$ and chordal distance $c$, one has $c=2\sin(\theta/2)$. Since sine is increasing on $[0,\pi/2]$,

$$
\theta\le\varepsilon
\quad\Longleftrightarrow\quad
c\le2\sin(\varepsilon/2).
$$

Apply this equivalence to every pair of vertices. $\square$

Thus a chordal filtration can be converted into a geodesic one by relabelling scale. Birth and death parameters transform by $\varepsilon\mapsto2\sin(\varepsilon/2)$ in the geodesic-to-chordal direction, or by $c\mapsto2\arcsin(c/2)$ in the reverse direction.

## 6. Failure of endpoint-independent radial weighting

Consider the proposed radial transform

$$
r(d)=\frac{2d}{1+d^2/4}.
$$

It takes only the Euclidean separation $d$ as input.

**Theorem 6.1 (Explicit counterexample).** In the one-dimensional stereographic chart, take $x=0$ and $y=2$. Then

$$
r(\lvert x-y\rvert)=2,
$$

whereas

$$
d_c(x,y)=\frac4{\sqrt5}<2.
$$

Hence $r(\lVert x-y\rVert)$ is not the chordal distance between inverse stereographic images.

**Proof.** Since $\lvert0-2\rvert=2$,

$$
r(2)=\frac{2\cdot2}{1+2^2/4}=2.
$$

The exact weighted distance is

$$
d_c(0,2)
=
\frac{2\lvert0-2\rvert}{\sqrt{(1+0^2)(1+2^2)}}
=
\frac4{\sqrt5}.
$$

Because $4<2\sqrt5$ is equivalent, after dividing and squaring positive quantities, to $4<5$, one has $4/\sqrt5<2$. $\square$

**Proposition 6.2 (No universal radial representation).** For every $n\ge1$, there is no function $f:[0,\infty)\to\mathbb R$ satisfying

$$
d_c(x,y)=f(\lVert x-y\rVert)
$$

for all $x,y\in\mathbb R^n$.

**Proof sketch.** Fix a unit vector $e$. The pairs $(0,e)$ and $(e,2e)$ both have Euclidean separation $1$. Their weighted chordal distances are

$$
d_c(0,e)=\frac2{\sqrt2}=\sqrt2,
$$

and

$$
d_c(e,2e)=\frac2{\sqrt{(1+1)(1+4)}}=\frac2{\sqrt{10}}.
$$

These values differ, so no function of separation alone can equal both. $\square$

This proposition explains structurally why the counterexample is unavoidable: inverse-stereographic distance is not translation invariant in chart coordinates.

## 7. Algorithms

### 7.1. Dense weighted distance construction

Given $N$ points $x_1,\ldots,x_N\in\mathbb R^n$, precompute

$$
s_i=\sqrt{1+\lVert x_i\rVert^2}.
$$

Then for each pair $i<j$, calculate

$$
D^{(c)}_{ij}=\frac{2\lVert x_i-x_j\rVert}{s_i s_j},
\qquad
D^{(g)}_{ij}=2\arcsin\!\left(\frac{D^{(c)}_{ij}}2\right).
$$

Set diagonal entries to zero and use symmetry. In floating-point arithmetic, clip $D^{(c)}_{ij}/2$ to $[0,1]$ before applying $\arcsin$ to prevent roundoff outside the analytic domain.

Computing norms and all pairwise differences costs $O(N^2n)$ arithmetic operations. The dense matrices require $O(N^2)$ storage. These costs are unavoidable if all $\binom N2$ values are explicitly output.

### 7.2. Vietoris--Rips filtration values

For a simplex $\sigma$, its Vietoris--Rips entrance value is

$$
\operatorname{birth}_{\mathrm{VR}}(\sigma)
=
\max_{i,j\in\sigma}D_{ij}.
$$

Therefore any standard persistence implementation accepting a distance matrix can consume $D^{(c)}$ or $D^{(g)}$. The transport theorems guarantee that this produces the same filtration as direct spherical computation.

### 7.3. Validation procedure

For a numerical consistency test, sample vectors $u_i\in\mathbb R^{n+1}$ from a rotationally symmetric distribution and normalize them to unit length. Avoid points numerically indistinguishable from the omitted pole. Convert each spherical point $p=(v,t)$ to the stereographic coordinate

$$
x=\frac{v}{1-t}.
$$

Compute both direct spherical distances and weighted chart distances, then report the maximum absolute discrepancy. Repeat for several cloud sizes such as $N=50$, $100$, and $200$. This validates the implementation of the distance identity; persistence equality then follows from identical threshold matrices.

## 8. Applications

For sky surveys and cosmic microwave background analyses, each observation has a direction. A spherical metric avoids artificial seams and distortions introduced by a planar map. Weighted stereographic coordinates permit local chart-based workflows while retaining exact global chordal or geodesic pairwise distances, provided the omitted pole is handled appropriately.

In structural biology, directions can encode bond orientations, surface normals, or conformational axes. Persistent features computed from those directions should not depend on an arbitrary planar representation. The pullback metric separates coordinate convenience from geometric meaning.

The same principle applies to computer vision, robotics, and geoscience, wherever unit vectors or directional measurements occur. If a software system accepts a custom distance matrix, no redesign of its algebraic persistence stage is required: only the metric preprocessing changes.

## 9. Complexity and limitations

The metric identity does not establish an $O(N\log N)$ exact algorithm for arbitrary dense clouds. An algorithm explicitly producing every pairwise filtration value has output size $\Theta(N^2)$ and therefore requires $\Omega(N^2)$ output operations in standard models. Furthermore, enumerating all simplices of a Vietoris--Rips complex may be exponential in $N$ in the worst case.

Subquadratic behavior can still be meaningful under additional assumptions. Examples include fixed-dimensional spatial indexing, a maximum scale that induces a sparse neighborhood graph, approximate complexes, witness or sparsified filtrations, implicit distance queries, and output-sensitive algorithms. Any precise complexity theorem must state which representation and assumptions it uses.

There are also geometric limitations. A single stereographic chart excludes one pole and becomes numerically ill-conditioned near it. Rotating the sphere can place the omitted pole away from the data, while an atlas of two or more charts can cover the whole sphere. Čech centers require particular care because a valid center may occur at the omitted pole even when all data vertices lie in the chart.

## 10. Discussion and future work

The exact endpoint-dependent weight converts stereographic coordinates into a faithful metric representation of spherical chordal geometry. It preserves Vietoris--Rips faces and chart-centered Čech faces at every parameter. Geodesic persistence follows through the exact chord-to-arc transform. In contrast, the endpoint-independent proposal fails because stereographic distortion depends on absolute chart location.

Several concrete problems remain. A full theorem for geodesic filtration reparameterization should be developed simultaneously for complexes and persistence modules. Full spherical Čech transport should characterize exactly when the omitted pole is essential as a common center. Although the triangle inequality for $d_c$ follows immediately from its realization as a pullback of the spherical chord metric, a direct chart-coordinate proof may be useful computationally.

A general impossibility theorem for endpoint-independent radial replacements can be extended beyond chordal distance and classified by transformation groups. Finally, complexity claims should be placed in explicit computational models. A sparse bounded-scale filtration may admit near-linear preprocessing in fixed dimension, while dense exact output cannot.

## 11. Conclusion

Stereographic projection is a powerful coordinate device, but conformality alone does not preserve the finite distances used by persistent homology. The correct chart metric is

$$
d_c(x,y)=\frac{2\lVert x-y\rVert}{\sqrt{(1+\lVert x\rVert^2)(1+\lVert y\rVert^2)}},
$$

with geodesic counterpart

$$
d_g(x,y)=2\arcsin(d_c(x,y)/2).
$$

These formulas preserve the relevant filtration inequalities exactly. They yield identical chordal Vietoris--Rips and chart-centered Čech filtrations, and they support geodesic Vietoris--Rips persistence by direct evaluation or scale reparameterization. The explicit counterexample $x=0$, $y=2$ demonstrates why planar separation alone is insufficient. Exact geometry requires both endpoints; once that dependence is retained, spherical persistence can be computed reliably in Euclidean coordinates.
## Appendix A. Additional structural consequences

**Proposition A.1 (Metric property).** The function $d_c$ is a metric on $\mathbb R^n$.

**Proof sketch.** Nonnegativity and symmetry are immediate from the formula. If $d_c(x,y)=0$, its positive denominator implies $\lVert x-y\rVert=0$, hence $x=y$. For the triangle inequality, Lemma 2.4 writes $d_c(x,y)$ as $d_{\mathrm{ch}}(P(x),P(y))$. The Euclidean triangle inequality in $\mathbb R^{n+1}$ gives

$$
d_{\mathrm{ch}}(P(x),P(z))\le d_{\mathrm{ch}}(P(x),P(y))+d_{\mathrm{ch}}(P(y),P(z)).
$$

Apply Lemma 2.4 to all three terms. $\square$

**Proposition A.2 (Simplex entrance values are preserved).** Let $\sigma\subseteq I$ be finite. Its spherical chordal Vietoris--Rips entrance value equals its weighted-chart entrance value:

$$
\max_{i,j\in\sigma}d_{\mathrm{ch}}(P(X(i)),P(X(j)))
=
\max_{i,j\in\sigma}d_c(X(i),X(j)).
$$

**Proof sketch.** The corresponding quantities inside the maxima agree term by term by Lemma 2.4. $\square$

**Proposition A.3 (Monotonicity of chord-to-arc conversion).** The function $g(c)=2\arcsin(c/2)$ is strictly increasing on $[0,2]$.

**Proof sketch.** The map $c\mapsto c/2$ is strictly increasing from $[0,2]$ to $[0,1]$, and $\arcsin$ is strictly increasing there. Composition with multiplication by $2$ preserves strict monotonicity. $\square$

Consequently, chordal and geodesic pairwise distances rank all edges in the same order, allowing ties. Their numerical filtration parameters differ, but their sequence of combinatorial changes is related by a single monotone reparameterization.

## Appendix B. Reproducible numerical protocol

A reproducible experiment should separate mathematical equivalence from numerical conditioning. For each requested cloud size $N$, draw $N$ independent vectors in $\mathbb R^{n+1}$ with standard normal entries and normalize each vector. Rotational symmetry makes the resulting points uniform on $S^n$. If a point lies too close to the north pole, either rotate the cloud or resample it to avoid overflow in its chart coordinate.

For every pair $(p_i,p_j)$, compute

$$
C_{ij}=\lVert p_i-p_j\rVert,
\qquad
G_{ij}=\arccos(\operatorname{clip}(p_i\cdot p_j,-1,1)).
$$

Project $p_i=(v_i,t_i)$ to $x_i=v_i/(1-t_i)$ and compute

$$
\widehat C_{ij}=
\frac{2\lVert x_i-x_j\rVert}
{\sqrt{(1+\lVert x_i\rVert^2)(1+\lVert x_j\rVert^2)}},
$$

$$
\widehat G_{ij}=2\arcsin(\operatorname{clip}(\widehat C_{ij}/2,0,1)).
$$

Report $\max_{i,j}|C_{ij}-\widehat C_{ij}|$ and $\max_{i,j}|G_{ij}-\widehat G_{ij}|$. The discrepancies should be comparable to accumulated floating-point error, except when chart coordinates become extremely large. For selected thresholds $\varepsilon$, compare the edge sets $\{(i,j):C_{ij}\le\varepsilon\}$ and $\{(i,j):\widehat C_{ij}\le\varepsilon\}$. Away from thresholds that are numerically indistinguishable from an entry, these sets should match.

One may then pass both matrices independently to the same persistence implementation. Equal matrices produce equal filtered complexes, so this final step tests software plumbing rather than a further mathematical claim. If two persistence outputs differ while the matrices agree, the discrepancy lies in parameter conventions, coefficient choices, tie handling, or software configuration.

## Appendix C. Implementation cautions

Near the omitted pole, stereographic coordinates can have very large norm. The exact formula remains mathematically valid, but separately forming squared norms can overflow in finite precision. Stable norm routines, rescaling, extended precision, or a rotated chart mitigate the problem. A robust system may retain original unit vectors for direct pairwise distance evaluation while using chart coordinates for other computations.

The word “Čech” must also be accompanied by a center convention. The chart-centered complex uses centers in $\mathbb R^n$, corresponding exactly to spherical centers other than the omitted pole. An implementation claiming the full spherical Čech complex must explicitly test the omitted pole or cover the sphere by multiple charts. This distinction does not arise for Vietoris--Rips complexes, whose faces depend only on distances among data vertices.

Finally, chordal and geodesic thresholds should not be mixed. A chordal parameter belongs to $[0,2]$, while a geodesic parameter belongs to $[0,\pi]$. The conversion $c=2\sin(\varepsilon/2)$ should be applied consistently to reported birth and death values as well as filtration cutoffs.

## Appendix D. Choice of chart and invariance of the result

The north pole used above is a coordinate choice, not a preferred geometric point. Before projection, one may apply any orthogonal transformation of $\mathbb R^{n+1}$ that moves a convenient empty or sparsely sampled region to the omitted pole. Orthogonal transformations preserve both chordal and geodesic spherical distance. Repeating the derivation in the rotated chart therefore gives exactly the same spherical filtration, although the numerical chart coordinates and endpoint scale factors change.

This observation suggests a practical conditioning strategy. Given a finite cloud, choose an omitted pole that maximizes its minimum geodesic distance from the samples. The resulting chart avoids unnecessarily large coordinates. If the data cover the sphere densely, use overlapping charts or retain spherical vectors for distance evaluation. In all cases, correctness rests on the same identity between a spherical distance and its endpoint-weighted chart expression.

Changing charts does not create a new persistence invariant. Two valid charts produce distance matrices that both equal the same direct spherical matrix, so they equal one another up to floating-point error and point labelling. This provides another useful diagnostic: rotate a cloud, project from a different pole, and verify that persistence parameters remain unchanged after exact weighting. Ordinary Euclidean chart distances will generally fail this test.
