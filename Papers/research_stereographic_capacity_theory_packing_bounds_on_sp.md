# Spherical Cap Packing on the Two-Sphere: Area Bounds, Distortion Diagnostics, and a Tetrahedral Obstruction

**Aristotle**  
**August 2, 2026**

## Abstract

We study equal-radius geodesic cap packings on the unit two-sphere. The intrinsic cap-area formula yields the universal bound $N(2,r)\le 2/(1-\cos r)$ for $0<r<\pi$, where $N(2,r)$ is the maximum cardinality of a family of pairwise non-overlapping caps of radius $r$. On $0<r<\pi/2$, this bound implies the proposed stereographic inequality obtained by multiplying the area ratio by $(2/\cos r)^2$, but the implication is strictly elementary: the multiplier is at least one, so no stereographic argument is needed. Moreover, $(2/\cos r)^2$ equals $4$ at $r=0$ and therefore cannot be a correction of the form $1+O(r^2)$. We then give an inner-product obstruction proving that four unit vectors cannot have all pairwise inner products at most $-1/2$. Hence four caps of radius $\pi/3$ cannot be packed, and the tetrahedral calibration at that radius is false. A regular tetrahedron instead supports caps only up to radius $\frac12\arccos(-1/3)$. Combining the obstruction with an equatorial construction gives $N(2,\pi/3)=3$ for open caps, while the area bound and the octahedral construction give $N(2,\pi/4)=6$ under the corresponding tangency convention. We discuss computational audits, the limits of one-chart stereographic distortion, and directions toward sharp small-cap asymptotics.

## 1. Introduction

Packing equal regions on a sphere is a basic problem in discrete geometry with applications to directional coding, communications, sampling, molecular configurations, and constellation design. A center on the sphere may represent a normalized signal or spatial direction. If two centers must remain distinguishable under angular noise of size $r$, their radius-$r$ neighborhoods should not overlap. This turns code design into spherical cap packing.

A natural proposal is to use stereographic projection, convert caps into planar disks, and compensate for conformal distortion. That approach is attractive because stereographic projection preserves angles and sends circles to circles or lines. It is also delicate: the projection does not preserve area, and its local scale diverges near the omitted pole. Any asserted global correction therefore requires careful normalization and domain control.

This paper separates three logically different ingredients. First, finite additivity of area gives an intrinsic upper bound requiring no projection. Second, a proposed stereographic multiplier can be compared directly with that bound and tested at zero radius. Third, candidate equality cases can be audited through inner products of center vectors. The resulting picture is both simpler and more restrictive than the projection heuristic suggests.

The principal conclusions are:

1. Every packing of $m$ equal caps of geodesic radius $r$ on the unit two-sphere satisfies

$$
m\le \frac{2}{1-\cos r}.
$$

2. For $0<r<\pi/2$, the inequality

$$
m\le \left(\frac{2}{\cos r}\right)^2\frac{4\pi}{2\pi(1-\cos r)}
$$

is a weaker consequence of the first bound.

3. The multiplier $(2/\cos r)^2$ is not $1+O(r^2)$, since its value at zero is $4$.

4. Four caps of radius $\pi/3$ cannot be packed. For open caps, three can, so $N(2,\pi/3)=3$.

5. The regular tetrahedron supports equal caps only up to radius $\frac12\arccos(-1/3)$, not $\pi/3$.

We state all measure-theoretic and geometric assumptions explicitly, because boundary conventions matter. Open caps may be tangent without intersecting, whereas closed caps at the same radius share boundary points. When discussing exact constructions at equality, “non-overlapping” will mean disjoint interiors, equivalently open caps; closed-cap statements require replacing equality of center separation by a strict inequality.

## 2. Definitions and geometric preliminaries

### 2.1 The unit sphere and geodesic distance

Let

$$
S^2=\{x\in\mathbb R^3:\lVert x\rVert=1\}.
$$

For $x,y\in S^2$, their geodesic distance is

$$
d_{S^2}(x,y)=\arccos(x\cdot y)\in[0,\pi].
$$

Thus angular separation and inner product are related by

$$
x\cdot y=\cos d_{S^2}(x,y).
$$

Because cosine decreases on $[0,\pi]$, the separation condition $d_{S^2}(x,y)\ge\theta$ is equivalent to $x\cdot y\le\cos\theta$.

### 2.2 Geodesic caps

For a center $p\in S^2$ and radius $r\in(0,\pi)$, define the open geodesic cap

$$
B(p,r)=\{x\in S^2:d_{S^2}(x,p)<r\}.
$$

Its closed analogue replaces $<$ by $\le$. Two open caps of radius $r$ are disjoint whenever their centers have distance at least $2r$. Conversely, if the center distance is less than $2r$, the midpoint of a minimizing geodesic lies in both caps. For closed caps, distance exactly $2r$ creates tangency and a shared boundary point.

Define the open-cap packing number $N(2,r)$ as the greatest cardinality of a finite set $C\subseteq S^2$ such that

$$
d_{S^2}(x,y)\ge 2r
$$

for all distinct $x,y\in C$. This center-separation formulation automatically permits tangency of open caps.

### 2.3 Surface area of a cap

The unit sphere has area

$$
A_{S^2}=4\pi.
$$

A cap of geodesic radius $r$ has Euclidean height $h=1-\cos r$. The area of a spherical zone on the unit sphere is $2\pi$ times its height, hence

$$
A_{
m cap}(r)=2\pi(1-\cos r).
$$

The formula applies equally to open and closed caps because their boundary circles have surface measure zero.

For small $r$, the Taylor expansion $1-\cos r=r^2/2-r^4/24+O(r^6)$ gives

$$
A_{
m cap}(r)=\pi r^2-\frac{\pi}{12}r^4+O(r^6),
$$

consistent with local Euclidean geometry.

## 3. The finite-measure packing principle

The area argument is an instance of a general statement.

### Theorem 1 (Finite-measure packing principle)

Let $(X,\mu)$ be a measure space, let $A\subseteq X$ be measurable, and let $E_1,\ldots,E_m$ be pairwise disjoint measurable subsets of $A$. If $\mu(E_i)\ge v$ for every $i$, then

$$
mv\le\mu(A).
$$

#### Proof sketch

Finite additivity on pairwise disjoint measurable sets gives

$$
\mu\left(\bigcup_{i=1}^m E_i\right)=\sum_{i=1}^m\mu(E_i)\ge mv.
$$

Monotonicity and $\bigcup_iE_i\subseteq A$ give

$$
\mu\left(\bigcup_iE_i\right)\le\mu(A).
$$

Combining the inequalities proves the claim. The same proof works for extended nonnegative measures, including infinite values, though the finite spherical application has ordinary real area.

### Theorem 2 (Direct area bound on $S^2$)

For $0<r<\pi$, any family of $m$ pairwise non-overlapping geodesic caps of radius $r$ on the unit sphere satisfies

$$
m\le \frac{2}{1-\cos r}.
$$

Consequently,

$$
N(2,r)\le\left\lfloor\frac{2}{1-\cos r}\right\rfloor.
$$

#### Proof sketch

Apply Theorem 1 with ambient area $4\pi$ and cap area $2\pi(1-\cos r)$. Since $0<r<\pi$, one has $\cos r<1$, so the cap area is positive. Therefore

$$
m\,2\pi(1-\cos r)\le4\pi.
$$

Division by the positive factor $2\pi(1-\cos r)$ yields the stated inequality.

### Remark 1 (Necessity versus sharpness)

Theorem 2 is a volume obstruction. It does not account for interstitial gaps, so it need not be attainable. The discrepancy is analogous to planar disk packing: the total area of disks cannot exceed the container area, but an area budget alone ignores geometric packing density and boundary effects.

### Small-radius behavior

Using the expansion of the cosine,

$$
\frac{2}{1-\cos r}
=\frac{4}{r^2}+\frac13+O(r^2).
$$

Thus the area argument predicts the correct order $r^{-2}$ for small caps. It should not be interpreted as a sharp asymptotic constant. Locally, sufficiently small caps resemble Euclidean disks, and planar packing density is expected to influence the leading behavior of efficient global packings. Establishing a sharp asymptotic requires geometric input beyond finite additivity.

## 4. Audit of the proposed stereographic multiplier

Consider the proposed factor

$$
C(r)=\left(\frac{2}{\cos r}\right)^2.
$$

It is finite and positive for $0<r<\pi/2$.

### Theorem 3 (The proposed inequality is weaker than the area bound)

Let $0<r<\pi/2$. If a real number $m$ satisfies

$$
m\le\frac{2}{1-\cos r},
$$

then

$$
m\le C(r)\frac{A_{S^2}}{A_{
m cap}(r)}.
$$

In particular, every equal-cap packing satisfies the latter inequality.

#### Proof sketch

On this range, $0<\cos r\le1$. Hence $2/\cos r\ge2$, and therefore $C(r)\ge4\ge1$. Also,

$$
\frac{A_{S^2}}{A_{
m cap}(r)}
=\frac{4\pi}{2\pi(1-\cos r)}
=\frac{2}{1-\cos r}.
$$

Multiplying this positive area ratio by $C(r)\ge1$ can only increase it. The direct area bound therefore implies the proposed inequality.

The conclusion is not that stereographic methods are invalid. Rather, this particular inequality does not demonstrate their strength: its right-hand side is at least four times the direct area ratio near zero.

### Proposition 4 (Failure of unit normalization)

The factor $C(r)$ does not have the form $1+O(r^2)$ as $r\to0$. Indeed,

$$
C(0)=4.
$$

#### Proof sketch

Since $\cos0=1$,

$$
C(0)=\left(\frac21\right)^2=4.
$$

Any function of the form $1+O(r^2)$ tends to $1$ as $r\to0$, so $C$ cannot have that normalization. More precisely, using $\sec^2r=1+r^2+\frac23r^4+O(r^6)$,

$$
C(r)=4+4r^2+\frac83r^4+O(r^6).
$$

The normalized candidate $\widetilde C(r)=1/\cos^2r$ does satisfy

$$
\widetilde C(r)=1+r^2+\frac23r^4+O(r^6).
$$

This observation identifies a normalization error; it does not by itself prove that $\widetilde C$ controls a global packing distortion.

### 4.1 Why one stereographic chart is insufficient globally

Under a standard stereographic coordinate $x\in\mathbb R^2$, the spherical metric is conformal to the Euclidean metric, with an area density proportional to

$$
\frac{4}{(1+\lVert x\rVert^2)^2}
$$

for projection from the omitted pole to the plane. The reciprocal factor grows without bound as $\lVert x\rVert\to\infty$. Consequently, no finite global maximum of the reciprocal distortion exists in a single chart covering the sphere minus its projection point. Caps approaching the omitted pole are represented in increasingly distorted planar regions.

A rigorous global projection argument must therefore do at least one of the following: restrict all caps to a compact subregion of one chart; use a finite atlas with bounded distortion on each chart; or incorporate the exact spherical area density into a weighted planar packing problem. For the basic upper bound on $S^2$, direct intrinsic area avoids these complications entirely.

## 5. The four-vector obstruction

Area alone gives $m\le4$ when $r=\pi/3$. We now show that equality is geometrically impossible.

### Lemma 5 (Four-vector inner-product obstruction)

Let $a,b,c,d$ be unit vectors in any real inner-product space. It is impossible that every pair satisfy

$$
a\cdot b,\ a\cdot c,\ a\cdot d,\ b\cdot c,\ b\cdot d,\ c\cdot d\le-\frac12.
$$

#### Proof sketch

Expand the nonnegative squared norm

$$
\begin{aligned}
\lVert a+b+c+d\rVert^2
&=\lVert a\rVert^2+\lVert b\rVert^2+\lVert c\rVert^2+\lVert d\rVert^2\\
&\quad+2(a\cdot b+a\cdot c+a\cdot d+b\cdot c+b\cdot d+c\cdot d).
\end{aligned}
$$

The four diagonal terms sum to $4$. The six off-diagonal terms sum to at most $6(-1/2)=-3$, and the factor $2$ makes their total contribution at most $-6$. Thus

$$
\lVert a+b+c+d\rVert^2\le4-6=-2,
$$

contradicting nonnegativity.

This is a Gram-matrix argument in elementary form. The Gram matrix of the vectors must be positive semidefinite; testing it against the all-ones vector produces exactly the squared norm above.

### Theorem 6 (No four caps of radius $\pi/3$)

Four pairwise non-overlapping open geodesic caps of radius $\pi/3$ cannot be placed on $S^2$.

#### Proof sketch

Non-overlap requires every pair of centers to be separated by at least $2\pi/3$. Represent the centers by unit vectors. Since

$$
\cos\left(\frac{2\pi}{3}\right)=-\frac12,
$$

monotonicity of cosine implies that every pairwise inner product is at most $-1/2$. Lemma 5 rules out four such vectors.

### Theorem 7 (Exact open-cap packing at radius $\pi/3$)

Under the open-cap convention,

$$
N(2,\pi/3)=3.
$$

#### Proof sketch

Theorem 6 gives the upper bound $N(2,\pi/3)\le3$. For the lower bound, choose three points equally spaced on the equator, with longitudes $0$, $2\pi/3$, and $4\pi/3$. Every pair has geodesic distance $2\pi/3$. The corresponding open caps of radius $\pi/3$ have disjoint interiors and tangent boundaries. Hence three caps exist and the upper bound is attained.

## 6. Correcting the tetrahedral calibration

For a regular tetrahedron centered at the origin and inscribed in $S^2$, any two distinct vertex vectors have inner product $-1/3$. Their common angular separation is therefore

$$
\theta_{\rm tet}=\arccos\left(-\frac13\right).
$$

### Proposition 8 (Tetrahedral cap radius)

The largest equal open-cap radius supported by tetrahedral centers is

$$
r_{\rm tet}=\frac12\arccos\left(-\frac13\right)
\approx0.9553166\text{ radians}
\approx54.7356^\circ.
$$

In particular, $r_{\rm tet}<\pi/3$.

#### Proof sketch

Equal caps centered at points with minimum separation $\theta$ are disjoint in their interiors exactly up to radius $\theta/2$. For tetrahedral vertices, $\theta=\arccos(-1/3)$. To compare with $\pi/3$, note that caps of radius $\pi/3$ require pairwise inner products at most

$$
\cos(2\pi/3)=-\frac12.
$$

But $-1/3>-1/2$, so tetrahedral vertices are too close. Equivalently, $\arccos(-1/3)<2\pi/3$.

The correction preserves the tetrahedron’s role as a symmetric four-center configuration while assigning it the geometrically correct radius.

## 7. Numerical landmarks and polyhedral labels

### 7.1 Radius $r=\pi/6$

At $30$ degrees,

$$
\frac{2}{1-\cos(\pi/6)}
=\frac{2}{1-\sqrt3/2}
=8+4\sqrt3
\approx14.9282.
$$

Thus the integer area bound is $N(2,\pi/6)\le14$. A twelve-center icosahedral configuration is numerically compatible with this upper bound. Compatibility is not an optimality proof, and the radius must still be checked against the icosahedron’s actual minimum angular separation.

### 7.2 Radius $r=\pi/4$

At $45$ degrees,

$$
\frac{2}{1-\cos(\pi/4)}
=\frac{2}{1-\sqrt2/2}
=4+2\sqrt2
\approx6.8284.
$$

Hence $N(2,\pi/4)\le6$. The six vertices $\pm e_1,\pm e_2,\pm e_3$ of a regular octahedron have minimum angular separation $\pi/2$. They therefore support six open caps of radius $\pi/4$, proving

$$
N(2,\pi/4)=6
$$

for open caps. This six-center configuration is octahedral. A cuboctahedron has twelve vertices and should not be used as its label.

### 7.3 Radius $r=\pi/3$

Here the area ratio is exactly

$$
\frac{2}{1-\cos(\pi/3)}=4.
$$

The area bound permits four in principle, but Theorem 6 excludes four. The equatorial three-center construction then gives the exact value $3$ for open caps. This example demonstrates why equality in a volume bound cannot be inferred from arithmetic alone.

### 7.4 The proposed multiplier in the examples

For $r<\pi/2$, the proposed right-hand side equals the area ratio multiplied by $4/\cos^2r$. At $r=\pi/6$, this multiplier is $16/3$; at $r=\pi/4$, it is $8$. It therefore produces upper bounds far larger than the intrinsic area estimate. At $r=\pi/3$, the multiplier is $16$, yielding $64$ instead of the direct bound $4$. These values underscore that the inequality is valid but very loose.

## 8. Algorithms and computational audits

The essential quantities can be audited with a short deterministic procedure.

### Algorithm 1 (Radius audit)

Given $r\in(0,\pi)$ and an optional candidate cardinality $m$:

1. Compute $A=2\pi(1-\cos r)$.
2. Compute the real area bound $B=4\pi/A=2/(1-\cos r)$.
3. Set the integer upper bound to $\lfloor B\rfloor$.
4. If $r<\pi/2$, compute $C=4/\cos^2r$ and the proposed bound $CB$.
5. If candidate unit center vectors are supplied, normalize them, compute every pairwise inner product, and convert the largest pairwise inner product to the minimum angle by $\arccos$.
6. Accept open-cap non-overlap only if the minimum angle is at least $2r$, allowing a numerical tolerance.

For a fixed radius, the scalar calculations take constant time. For $m$ supplied centers in dimension $d$, pairwise checking takes $O(m^2d)$ time and $O(1)$ auxiliary space if pairs are streamed. Computing a full Gram matrix uses $O(m^2)$ memory.

### Numerical stability

Near $r=0$, direct evaluation of $1-\cos r$ can lose precision through cancellation. A stable identity is

$$
1-\cos r=2\sin^2(r/2),
$$

so the area bound may be evaluated as

$$
\frac{1}{\sin^2(r/2)}.
$$

When recovering angles from dot products, numerical values should be clamped to $[-1,1]$ before applying $\arccos$.

## 9. Applications

### Spherical codes

A finite set $C\subset S^2$ with minimum angular distance $2r$ is a spherical code. Nearest-neighbor decoding can tolerate angular perturbations smaller than $r$ without ambiguity. The cap packing number therefore limits the size of a directional codebook at a prescribed noise margin.

### Signal processing and directional sensing

Microphone arrays, radar systems, and orientation sensors sample directional data. Separation constraints prevent nearly redundant sensing directions and improve robustness. The area bound supplies an immediate feasibility screen, while Gram-matrix tests verify a concrete design.

### Molecular and polyhedral geometry

Repelling sites on a spherical shell often organize into symmetric configurations. Polyhedral names are useful only when paired with their correct vertex counts and angular separations. The tetrahedral correction shows that visual symmetry does not override quantitative separation requirements.

### Constellation design

If satellites or beams are idealized by directions from a central observer, exclusion zones become spherical caps. Real systems add altitude, visibility, and time dependence, but the static spherical packing bound remains a baseline constraint.

## 10. Discussion

The direct area method has three advantages: it is intrinsic, global, and exact at the level of measure. Its weakness is equally clear: it ignores packing inefficiency. The vector-sum method complements it by encoding angular compatibility. At $r=\pi/3$, the two methods separate sharply: area gives $4$, while positive semidefiniteness reduces the bound to $3$.

Stereographic projection remains valuable for local analysis and for translating spherical geometry into weighted planar geometry. The crucial word is “weighted.” Ordinary Euclidean area in the image plane does not represent spherical area uniformly. A finite stereographic atlas could provide bounded local distortion, but chart overlap and caps crossing chart boundaries would need systematic treatment.

The small-radius asymptotic is another place where the crude area ratio should not be mistaken for a sharp answer. Since cap area is approximately $\pi r^2$, the area budget behaves like $4/r^2$. Yet locally dense equal-disk packings occupy only a fraction of the plane. Curvature and global topology create lower-order corrections, while local planar density is expected to affect the principal efficiency. Turning this expectation into a theorem requires localization, boundary control, and constructions that distribute defects across the sphere.

Boundary conventions also deserve emphasis. Open caps at exact center separation $2r$ are disjoint; closed caps touch. Surface area is insensitive to the boundary, but set-theoretic disjointness is not. Exact packing numbers must state the convention.

## 11. Future work

A complete intrinsic theory should define the packing number through center sets on $S^2$, prove compactness sufficient for attainment, and connect center separation precisely to open and closed cap disjointness. Exact constructions should be developed at corrected radii: the octahedron at $\pi/4$, the tetrahedron at $\frac12\arccos(-1/3)$, and the icosahedron at half its minimum angular separation.

For projection-based work, a finite atlas or exact weighted planar measure should replace any appeal to a global maximum distortion in one noncompact chart. In higher dimensions, cap volume involves an integral of $\sin^{n-1}t$, and finite measure still gives a universal volume-ratio bound. Gram-matrix positivity likewise generalizes and can provide cardinality obstructions from pairwise inner-product thresholds.

The most substantial open direction is sharp asymptotics. One should determine how local Euclidean packing density, curvature, and unavoidable global defects combine as $r\to0$. This would turn a coarse capacity estimate into a quantitative bridge between planar packing and spherical codes.

## 12. Conclusion

Equal-cap packing on $S^2$ begins with a simple area ledger:

$$
N(2,r)\le\frac{2}{1-\cos r}.
$$

The proposed multiplier $(2/\cos r)^2$ only weakens this bound on $0<r<\pi/2$ and fails unit normalization at zero. More importantly, area alone does not decide attainability. Positive semidefiniteness of Gram matrices rules out four centers separated by $120$ degrees, correcting the tetrahedral claim and yielding the exact open-cap value $N(2,\pi/3)=3$. At $r=\pi/4$, the area bound and octahedral construction match at $6$.

These results illustrate a reliable hierarchy for spherical packing: begin with intrinsic measure, audit limiting normalizations, and then test candidate configurations through angular algebra. Projection can enrich the analysis, but it cannot replace those checks.