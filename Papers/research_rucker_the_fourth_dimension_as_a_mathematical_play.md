# Complex Coordinates and the Geometry of Four Dimensions

## Hopf circles, the Clifford torus, fixed-point-free rotation, four-ball volume, and tesseract diameter

**Aristotle**  
**July 21, 2026**

## Abstract

Four-dimensional Euclidean geometry admits a particularly coherent description after the identification $\mathbb R^4\cong\mathbb C^2$. This paper develops five consequences of that model in a self-contained way. First, the quadratic map

$$
H(z,w)=\bigl(2\operatorname{Re}(z\overline w),\,2\operatorname{Im}(z\overline w),\,|z|^2-|w|^2\bigr)
$$

maps the unit three-sphere to the unit two-sphere. Its fibers are characterized exactly: two unit vectors have the same image if and only if they differ by simultaneous multiplication by a unit complex scalar. This gives the circle fibers of the Hopf fibration through an explicit equality case of the Hermitian Cauchy–Schwarz inequality. Second, the Clifford torus is identified as the inverse image of the equator of the two-sphere. Third, simultaneous multiplication by $i$ is shown to be a norm-preserving quarter-turn with no fixed point away from the origin. Fourth, the volume of a four-dimensional open ball of positive radius $r$ is derived as $\frac{\pi^2}{2}r^4$. Finally, the standard tesseract is treated as a sign code: its squared vertex distance is four times Hamming distance, so its diameter is $4$. Together these results exhibit a common architecture linking complex phase, quotient geometry, continuous symmetry, measure, and discrete coding.

## 1. Introduction

Four-dimensional objects resist direct visualization, but they do not resist exact calculation. The most productive response to the absence of a faithful picture is to select coordinates adapted to symmetry. Pairing four real coordinates into two complex coordinates transforms the geometry of $\mathbb R^4$ into the geometry of $\mathbb C^2$. Rotations in two mutually orthogonal real planes become complex multiplication, the unit three-sphere becomes a simple quadratic level set, and a common phase action becomes visible.

The central object is the map $H:\mathbb C^2\to\mathbb R^3$ defined by three real quadratic expressions. Restricted to the unit three-sphere, it is the classical Hopf map. We prove its basic norm identity, its invariance under a common unit phase, and the converse statement that equal Hopf coordinates determine precisely one common-phase orbit. The converse is essential: invariance alone only proves that circles lie inside fibers, whereas phase reconstruction proves that every fiber is exactly one circle.

The same phase action organizes two further phenomena. The Clifford torus, defined by equality of the two coordinate moduli, is the inverse image of the equator in the base two-sphere. Meanwhile, the unit phase $i$ produces a simultaneous quarter-turn in two orthogonal planes. Unlike a nontrivial rotation in three-dimensional space, this four-dimensional double rotation fixes no nonzero point.

Two complementary calculations complete the picture. The exact volume of a four-ball establishes the natural metric normalization and illustrates dimensional scaling. The tesseract calculation replaces continuous coordinates by signs and reveals that Euclidean distance among its vertices is exactly a rescaled Hamming distance.

All definitions and arguments needed for these conclusions are given below. The emphasis is not merely on isolated formulas, but on the way a single complex model unifies them.

## 2. Four-space as complex two-space

Write a point of $\mathbb R^4$ as

$$
(x_1,x_2,x_3,x_4)\longleftrightarrow (z,w)
=(x_1+ix_2,\,x_3+ix_4)\in\mathbb C^2.
$$

This correspondence preserves squared Euclidean norm:

$$
x_1^2+x_2^2+x_3^2+x_4^2=|z|^2+|w|^2.
$$

### Definition 2.1 (Three-sphere and two-sphere)

The unit three-sphere in complex two-space is

$$
S^3=\{(z,w)\in\mathbb C^2:|z|^2+|w|^2=1\}.
$$

The unit two-sphere in real three-space is

$$
S^2=\{(X,Y,Z)\in\mathbb R^3:X^2+Y^2+Z^2=1\}.
$$

The subscript records intrinsic dimension: $S^3$ is the three-dimensional boundary of a four-dimensional ball.

### Definition 2.2 (Diagonal phase action)

The unit circle is

$$
S^1=\{u\in\mathbb C:|u|=1\}.
$$

It acts diagonally on $\mathbb C^2$ by

$$
u\cdot(z,w)=(uz,uw).
$$

Because $|u|=1$, the action preserves $|z|^2+|w|^2$ and hence restricts to an action on every sphere centered at the origin.

### Definition 2.3 (Hopf map)

Define $H:\mathbb C^2\to\mathbb R^3$ by

$$
H(z,w)=\bigl(X(z,w),Y(z,w),Z(z,w)\bigr),
$$

where

$$
X(z,w)=2\operatorname{Re}(z\overline w),\qquad
Y(z,w)=2\operatorname{Im}(z\overline w),\qquad
Z(z,w)=|z|^2-|w|^2.
$$

The map is homogeneous of degree two: $H(tz,tw)=t^2H(z,w)$ for real $t$. More importantly, it has an exact norm identity.

## 3. The Hopf norm identity

### Theorem 3.1 (Quadratic norm identity)

For all $z,w\in\mathbb C$,

$$
\|H(z,w)\|_{\mathbb R^3}^2=(|z|^2+|w|^2)^2.
$$

Equivalently,

$$
4\operatorname{Re}(z\overline w)^2
+4\operatorname{Im}(z\overline w)^2
+(|z|^2-|w|^2)^2
=(|z|^2+|w|^2)^2.
$$

**Proof sketch.** For any complex number $a$, one has $\operatorname{Re}(a)^2+\operatorname{Im}(a)^2=|a|^2$. Taking $a=z\overline w$ gives

$$
X^2+Y^2=4|z\overline w|^2=4|z|^2|w|^2.
$$

Adding

$$
Z^2=(|z|^2-|w|^2)^2
$$

and using the identity $4ab+(a-b)^2=(a+b)^2$ with $a=|z|^2$ and $b=|w|^2$ proves the claim. $\square$

### Corollary 3.2 (Sphere-to-sphere property)

If $(z,w)\in S^3$, then $H(z,w)\in S^2$.

**Proof sketch.** On $S^3$, the right-hand side of Theorem 3.1 is $(|z|^2+|w|^2)^2=1$. $\square$

The restricted map $H:S^3\to S^2$ is surjective. An explicit preimage can be supplied locally: for a point $(X,Y,Z)\in S^2$ with $Z\ne-1$, take

$$
z=\sqrt{\frac{1+Z}{2}},\qquad
w=\frac{X-iY}{\sqrt{2(1+Z)}}.
$$

A direct calculation gives $|z|^2+|w|^2=1$ and $H(z,w)=(X,Y,Z)$. The south pole $(0,0,-1)$ is the image of $(0,1)$. This explicit surjectivity complements the fiber characterization below.

## 4. Circle invariance and exact fiber reconstruction

### Proposition 4.1 (Phase invariance)

For every $u\in S^1$ and every $(z,w)\in\mathbb C^2$,

$$
H(uz,uw)=H(z,w).
$$

**Proof sketch.** Since $u\overline u=|u|^2=1$,

$$
(uz)\overline{(uw)}=u\overline u\,z\overline w=z\overline w.
$$

Thus the first two coordinates are unchanged. Also $|uz|=|z|$ and $|uw|=|w|$, so the third coordinate is unchanged. $\square$

It follows that every phase orbit is contained in a Hopf fiber. To show that no fiber is larger, we use Hermitian geometry.

### Definition 4.2 (Hermitian inner product)

For $a=(z,w)$ and $b=(z',w')$ in $\mathbb C^2$, define

$$
\langle a,b\rangle=\overline z z'+\overline w w'.
$$

The Cauchy–Schwarz inequality says

$$
|\langle a,b\rangle|\le \|a\|\,\|b\|,
$$

with equality for nonzero vectors if and only if they are complex-linearly dependent.

### Lemma 4.3 (Hopf equality forces Hermitian equality)

Let $a=(z,w)$ and $b=(z',w')$ belong to $S^3$. If $H(z,w)=H(z',w')$, then

$$
|\langle a,b\rangle|=1.
$$

**Proof sketch.** The components of $H$ determine the rank-one Hermitian matrix

$$
P_a=
\begin{pmatrix}
|z|^2 & z\overline w\\
\overline z w & |w|^2
\end{pmatrix}.
$$

Indeed, the trace is $1$ on $S^3$, the difference of diagonal entries is the third Hopf coordinate, and the real and imaginary parts of the upper-right entry are the first two Hopf coordinates divided by $2$. Thus equal Hopf images imply $P_a=P_b$.

Alternatively, direct expansion yields

$$
|\langle a,b\rangle|^2
=\frac{1+H(a)\cdot H(b)}{2}
$$

for unit vectors $a$ and $b$. If $H(a)=H(b)$ and this common vector lies on $S^2$, then the dot product is $1$, so the right-hand side is $1$. $\square$

### Lemma 4.4 (Phase reconstruction)

Let $a,b\in S^3$. If $|\langle a,b\rangle|=1$, then there exists $u\in S^1$ such that $b=ua$.

**Proof sketch.** Cauchy–Schwarz gives $|\langle a,b\rangle|\le\|a\|\|b\|=1$. Equality implies complex linear dependence, so $b=ua$ for some $u\in\mathbb C$. Taking norms gives $1=\|b\|=|u|\|a\|=|u|$, hence $u\in S^1$. $\square$

### Theorem 4.5 (Exact Hopf fiber theorem)

For any $(z,w),(z',w')\in S^3$,

$$
H(z,w)=H(z',w')
$$

if and only if there exists $u\in S^1$ such that

$$
(z',w')=(uz,uw).
$$

Consequently, every fiber of $H:S^3\to S^2$ is exactly one circle orbit.

**Proof sketch.** If the Hopf images agree, Lemma 4.3 gives equality in the Hermitian Cauchy–Schwarz bound, and Lemma 4.4 reconstructs the unit phase. Conversely, Proposition 4.1 shows that a common unit phase does not alter the Hopf image. Since $(z,w)\ne(0,0)$ on $S^3$, the action is free: $u(z,w)=(z,w)$ forces $u=1$. Hence each orbit is a copy of $S^1$. $\square$

The theorem realizes $S^2$ as the orbit space $S^3/S^1$. Locally the map resembles a product with a circle, but globally it is nontrivial. This global twisting is visible in the linking of distinct fibers and prevents $S^3$ from being globally identified with $S^2\times S^1$.

## 5. The Clifford torus as an equatorial preimage

### Definition 5.1 (Clifford torus)

The Clifford torus in $S^3$ is

$$
T_{\mathrm C}=\{(z,w)\in S^3:|z|=|w|\}.
$$

Since $|z|^2+|w|^2=1$, the defining equality is equivalent to

$$
|z|=|w|=\frac1{\sqrt2}.
$$

It therefore has the parametrization

$$
(\alpha,\beta)\longmapsto
\left(\frac{e^{i\alpha}}{\sqrt2},
\frac{e^{i\beta}}{\sqrt2}\right),
$$

which exhibits it as $S^1\times S^1$.

### Theorem 5.2 (Equatorial level-set theorem)

For every $(z,w)\in\mathbb C^2$,

$$
|z|=|w|\quad\Longleftrightarrow\quad Z(z,w)=0.
$$

In particular,

$$
T_{\mathrm C}=H^{-1}(E),
$$

where

$$
E=\{(X,Y,Z)\in S^2:Z=0\}
$$

is the equator of $S^2$.

**Proof sketch.** By definition, $Z(z,w)=|z|^2-|w|^2$. Nonnegative real numbers have equal squares exactly when they are equal, so $Z=0$ is equivalent to $|z|=|w|$. Restricting to $S^3$ identifies the level set with the inverse image of the equator. $\square$

The theorem separates the two angular directions on the torus. Under the diagonal phase action, $(\alpha,\beta)$ changes to $(\alpha+\theta,\beta+\theta)$; this is motion along a Hopf fiber. The phase difference $\alpha-\beta$ determines position around the equator. Thus the torus is foliated by Hopf circles while projecting onto a circle.

This dimensional reduction has algorithmic value. Any quantity invariant under diagonal phase can be evaluated on a representative chosen by fixing one phase. Problems on a symmetric torus can thereby become one-dimensional problems on the equator.

## 6. A fixed-point-free four-dimensional quarter-turn

### Definition 6.1 (Simultaneous quarter-turn)

Define $Q:\mathbb C^2\to\mathbb C^2$ by

$$
Q(z,w)=(iz,iw).
$$

In real coordinates this is

$$
Q(x_1,x_2,x_3,x_4)=(-x_2,x_1,-x_4,x_3).
$$

It rotates each of the two orthogonal coordinate planes through $90^\circ$.

### Proposition 6.2 (Norm preservation)

For every $(z,w)\in\mathbb C^2$,

$$
\|Q(z,w)\|^2=|z|^2+|w|^2.
$$

**Proof sketch.** Since $|i|=1$, one has $|iz|=|z|$ and $|iw|=|w|$. $\square$

Thus $Q$ is an orthogonal transformation and preserves every sphere centered at the origin.

### Theorem 6.3 (Fixed-point theorem for the quarter-turn)

The origin is the only fixed point of $Q$ in $\mathbb R^4$. Consequently, the restriction of $Q$ to every sphere of positive radius, and in particular to $S^3$, has no fixed point.

**Proof sketch.** If $Q(z,w)=(z,w)$, then $iz=z$ and $iw=w$. Hence $(i-1)z=(i-1)w=0$. Since $i-1\ne0$, it follows that $z=w=0$. Conversely, the origin is plainly fixed. $\square$

A rotation in $\mathbb R^3$ necessarily has a fixed axis, but the four-dimensional transformation above rotates two orthogonal planes simultaneously. There is no unused direction in which a nonzero fixed vector can lie. On $S^3$, $Q$ is the diagonal phase action with $u=i$; by Proposition 4.1 it preserves each Hopf fiber and advances every point by one quarter of that circle.

More generally, the map $Q_\theta(z,w)=(e^{i\theta}z,e^{i\theta}w)$ is fixed-point-free on every positive-radius sphere whenever $\theta$ is not a multiple of $2\pi$. It is the time-$\theta$ motion of the circle action whose orbits are the Hopf fibers.

## 7. Exact volume of a four-dimensional ball

### Definition 7.1 (Open four-ball)

For $c\in\mathbb R^4$ and $r>0$, define

$$
B_4(c,r)=\{x\in\mathbb R^4:\|x-c\|<r\}.
$$

### Theorem 7.2 (Four-ball volume)

The four-dimensional Lebesgue volume of $B_4(c,r)$ is

$$
\operatorname{Vol}_4(B_4(c,r))=\frac{\pi^2}{2}r^4.
$$

The value is independent of the center $c$.

**Proof sketch.** Translation invariance reduces the calculation to $c=0$. Polar integration in $n$ dimensions gives

$$
\operatorname{Vol}_n(B_n(0,r))
=\frac{\pi^{n/2}}{\Gamma(n/2+1)}r^n.
$$

For completeness, the coefficient can be obtained from the Gaussian integral. On one hand,

$$
\int_{\mathbb R^n}e^{-\|x\|^2}\,dx=\pi^{n/2}
$$

by separating the integral into $n$ one-dimensional Gaussian factors. On the other hand, radial integration writes the same integral as

$$
A_{n-1}\int_0^\infty e^{-\rho^2}\rho^{n-1}\,d\rho
=\frac{A_{n-1}}2\Gamma(n/2),
$$

where $A_{n-1}$ is the area of the unit $(n-1)$-sphere. Hence $A_{n-1}=2\pi^{n/2}/\Gamma(n/2)$, and integrating shell area from $0$ to $r$ yields the ball formula. Setting $n=4$ and using $\Gamma(3)=2$ gives $\frac{\pi^2}{2}r^4$. $\square$

If radius is allowed to be any real number under the convention that an open metric ball of nonpositive radius is empty, the formula becomes

$$
\operatorname{Vol}_4(B_4(c,r))
=\frac{\pi^2}{2}(\max\{r,0\})^4.
$$

### Corollary 7.3 (Boundary three-volume)

Differentiating with respect to $r>0$ gives the three-dimensional hypersurface measure of the radius-$r$ three-sphere:

$$
A_3(r)=\frac{d}{dr}V_4(r)=2\pi^2r^3.
$$

This relation makes explicit the scaling distinction between a four-dimensional region and its three-dimensional boundary.

## 8. Tesseract geometry and Hamming distance

### Definition 8.1 (Standard tesseract vertices)

The vertex set of the standard tesseract is

$$
\mathcal V=\{-1,1\}^4.
$$

Thus a vertex is a sign vector $x=(x_1,x_2,x_3,x_4)$ with each $x_j\in\{-1,1\}$.

### Definition 8.2 (Hamming distance)

For $x,y\in\mathcal V$, let $d_H(x,y)$ be the number of coordinates in which $x$ and $y$ differ.

### Lemma 8.3 (Distance correspondence)

For all vertices $x,y\in\mathcal V$,

$$
\|x-y\|^2=4d_H(x,y).
$$

**Proof sketch.** In a coordinate where $x_j=y_j$, the squared contribution is $0$. In a coordinate where the signs differ, $x_j-y_j=\pm2$, and the squared contribution is $4$. Summing over the differing coordinates proves the identity. $\square$

### Theorem 8.4 (Tesseract diameter)

For all $x,y\in\mathcal V$,

$$
\|x-y\|^2\le16.
$$

Equality holds exactly when $y=-x$. Therefore the Euclidean diameter of the standard tesseract is $4$.

**Proof sketch.** There are four coordinates, so $d_H(x,y)\le4$. Lemma 8.3 gives $\|x-y\|^2\le16$. Equality requires disagreement in all four coordinates, which is equivalent to $y=-x$. $\square$

The identity in Lemma 8.3 turns the tesseract into a geometric model of four-bit strings. More generally, the vertices of the $n$-cube $\{-1,1\}^n$ satisfy $\|x-y\|^2=4d_H(x,y)$. This is the elementary bridge between hypercube geometry and binary coding: maximizing Euclidean separation among selected vertices is equivalent to maximizing minimum Hamming distance.

## 9. Computational procedures

The results support several direct algorithms.

### 9.1 Hopf projection

Given $(z,w)\in\mathbb C^2$, compute $z\overline w$, extract its real and imaginary parts, and append the difference $|z|^2-|w|^2$. The procedure uses a constant number of arithmetic operations. If the input is intended to lie on $S^3$, one may first normalize it by dividing by $\sqrt{|z|^2+|w|^2}$, provided it is nonzero.

The norm identity supplies an internal consistency check: the squared norm of the output must equal the square of the input’s squared norm. This is valuable in numerical experiments because the residual

$$
\left|\|H(z,w)\|^2-(|z|^2+|w|^2)^2\right|
$$

should be near floating-point roundoff.

### 9.2 Phase reconstruction

When two unit inputs share a Hopf image, the phase can be recovered from their Hermitian inner product. Under the convention

$$
\langle a,b\rangle=\overline z z'+\overline w w',
$$

and the relation $b=ua$, one gets $\langle a,b\rangle=u$. Thus calculate

$$
u=\overline z z'+\overline w w'.
$$

Exact equality gives $|u|=1$ and zero reconstruction error. For noisy data, replacing $u$ by $u/|u|$ when $u\ne0$ gives the nearest unit phase suggested by the correlation, and the residual $\|b-ua\|$ measures departure from a common orbit.

### 9.3 Tesseract distance enumeration

Enumerate the sixteen sign vectors and calculate pairwise distances. Since there are $\binom{16}{2}=120$ unordered pairs and each comparison examines four coordinates, exhaustive verification is trivial. In dimension $n$, exhaustive enumeration costs $O(n4^n)$ for all unordered pairs, whereas a single pairwise distance costs $O(n)$. The exact formula $4d_H$ avoids floating-point square roots and exposes the combinatorial structure.

## 10. Applications and interpretation

### 10.1 Qubits and the Bloch sphere

A normalized pure state of a two-level quantum system is a unit vector $(z,w)\in\mathbb C^2$. Multiplication by a global phase $u\in S^1$ does not change physical predictions. The exact Hopf fiber theorem says that quotienting normalized vectors by global phase produces precisely $S^2$, the Bloch sphere. The Hopf coordinates are expectation-value coordinates for three basic observables. Thus the passage $S^3\to S^2$ is not only topological; it is the geometry of state-space redundancy.

### 10.2 Symmetry reduction

The Clifford torus result illustrates a general strategy. When a problem on $S^3$ is invariant under diagonal phase, the Hopf map removes that symmetry and produces a problem on $S^2$. A phase-invariant torus composed of whole fibers corresponds to a curve in the base. Surface optimization may therefore reduce to a weighted curve problem. The equator’s inverse image is the most symmetric instance.

### 10.3 Rotation and dynamics

The maps $Q_\theta$ define a periodic flow on $S^3$. Every trajectory is a Hopf circle, and all trajectories have the same period. The quarter-turn is one time slice. Since there are no fixed points for nontrivial phases, the dynamics has no stationary state on the sphere. This supplies an explicit model of a free circle action and contrasts with axial rotation in three dimensions.

### 10.4 Coding and high-dimensional data

The tesseract calculation is the four-dimensional instance of an important encoding. Mapping a bit to a sign embeds binary strings into Euclidean space so that Hamming distance becomes squared Euclidean distance divided by four. This correspondence underlies binary phase-shift signaling, nearest-neighbor decoding, and hypercube-based combinatorial optimization.

### 10.5 High-dimensional measure

The four-ball formula enters probability and statistics whenever a rotationally symmetric distribution is integrated over a radius threshold. It also gives the normalization needed for uniform sampling from a four-ball: choose a random direction on $S^3$ and an independent radius $R=rU^{1/4}$ for $U$ uniform on $[0,1]$. The fourth root appears because enclosed volume scales as $R^4$.

## 11. Scope and limitations

The exact algebraic fiber theorem establishes that the point-preimages of the restricted Hopf map are phase circles. A full treatment of fiber bundles would additionally introduce local trivializations and transition functions; these are standard consequences but are not needed for the conclusions developed here.

Similarly, the fixed-point-free quarter-turn is an explicit orthogonal map, not a statement that every element of the rotation group $SO(4)$ is fixed-point-free. A general four-dimensional rotation may rotate by separate angles in two orthogonal planes; it has nonzero fixed vectors precisely when one of the corresponding planar angles is zero modulo $2\pi$.

Finally, no unrestricted embedding assertion for closed three-manifolds in $\mathbb R^4$ should be inferred. Not every closed three-manifold embeds smoothly in four-space. An embedding into the four-sphere separates the ambient manifold into complementary regions, and their homology, linking forms, and intersection pairings impose coupled restrictions. The meaningful classification problem is to characterize exactly which three-manifolds satisfy these embedding conditions.

## 12. Future directions

Several focused problems emerge from this framework.

First, exact phase reconstruction suggests a quantitative stability theorem. If two unit vectors have Hopf images within $\varepsilon$, one expects a unit phase aligning the vectors within a bound of order $\sqrt\varepsilon$. The square-root scale is natural because the Hopf map is quadratic and equality in Cauchy–Schwarz has a second-order defect.

Second, the Clifford torus may be studied variationally among tori invariant under diagonal phase. Such tori descend to curves on $S^2$, so area becomes a weighted length functional. This reduction offers a route to proving uniqueness or stability of the equatorial configuration under appropriate separation hypotheses.

Third, the geometry of $SO(4)$ invites a classification of fixed-point sets in terms of two planar rotation angles. The diagonal phase action treats equal angles; unequal angles produce more general torus dynamics on $S^3$, including periodic and dense trajectories depending on their ratio.

Fourth, the elementary tesseract–Hamming correspondence scales directly to high-dimensional code design. One can investigate selected vertex sets with maximal minimum distance, spectral properties of cube graphs, and convergence questions comparing discrete hypercube structures with spherical geometry.

Fifth, the embedding problem for closed three-manifolds should be formulated through complementary four-manifolds rather than as an unrestricted existence claim. Lens spaces, Seifert manifolds, and homology spheres provide concrete test families for coupled linking-form and intersection-form obstructions.

## 13. Conclusion

The identification $\mathbb R^4\cong\mathbb C^2$ makes a substantial portion of four-dimensional geometry accessible through elementary algebra. The Hopf norm identity sends $S^3$ to $S^2$. Phase invariance and Hermitian equality reconstruct its fibers exactly as circles. The Clifford torus is the preimage of the equator, and the fixed-point-free quarter-turn is motion by the distinguished phase $i$ along every fiber. The formula $\frac{\pi^2}{2}r^4$ measures the ambient four-ball, while the tesseract’s diameter $4$ records the maximal Hamming separation of four signs.

These are not disconnected curiosities. They are continuous, metric, and discrete expressions of one principle: in four dimensions, a well-chosen algebraic model can reveal the structure that ordinary visualization hides.
