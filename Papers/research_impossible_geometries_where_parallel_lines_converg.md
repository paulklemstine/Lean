# Curvature Without a Phase Transition in an Anisotropic Hyperbolic Metric

**Aristotle**  
**29 July 2026**

## Abstract

We study the Riemannian metric on $\mathbb R^2$

$$
ds^2=\frac{dx^2}{\cosh^2 y}+\cosh^2 x\,dy^2,
$$

which contracts horizontal lengths as $|y|$ increases and expands vertical lengths as $|x|$ increases. This opposing directional behavior suggests a possible split between elliptic and hyperbolic regions. We derive the Gaussian curvature

$$
K(x,y)=-\cosh^2 y-\operatorname{sech}^2x
+2\operatorname{sech}^2x\operatorname{sech}^2y
$$

and establish its complete sign portrait. The curvature is nonpositive everywhere, vanishes exactly at the origin, and is strictly negative at every other point. In particular, neither diagonal is a flat phase boundary. We compare the intrinsic curvature with the schematic field $P(x,y)=\operatorname{sech}^2x-\operatorname{sech}^2y$, whose diagonal zero set motivated the phase-transition picture, and prove that the two fields vanish simultaneously only at the origin. We also give the Christoffel symbols, affine geodesic equations, area density, numerical algorithms, and asymptotic consequences. The example demonstrates that opposing coordinate scale factors do not imply opposing curvature signs and provides a rigorous starting point for designing genuinely sign-changing diagonal metrics.

## 1. Introduction

A two-dimensional Riemannian metric assigns a smoothly varying inner product to each tangent plane. Its Gaussian curvature is the intrinsic scalar that distinguishes locally spherical, Euclidean, and saddle-like behavior. Positive curvature encourages geodesic convergence, zero curvature describes local Euclidean behavior, and negative curvature encourages geodesic divergence. For a nonuniform anisotropic metric, however, the signs of the coordinate scale factors’ growth do not directly determine the sign of curvature. Curvature incorporates derivatives and interactions among all metric coefficients.

Consider the metric

$$
g=\operatorname{sech}^2 y\,dx^2+\cosh^2x\,dy^2.
$$

Its horizontal scale factor is $\operatorname{sech}y$, which decreases away from $y=0$, while its vertical scale factor is $\cosh x$, which increases away from $x=0$. This contrast motivates the idea of a “split geometry,” with one family of directions contracting and another expanding.

A natural schematic field associated with that contrast is

$$
P(x,y)=\operatorname{sech}^2x-\operatorname{sech}^2y.
$$

Because $\operatorname{sech}^2t$ is even and strictly decreases as $|t|$ increases, $P$ vanishes on $y=x$ and $y=-x$ and changes sign across those diagonals. It is tempting to interpret these diagonals as flat interfaces between regions of positive and negative curvature. The principal result of this paper is that this interpretation is false for the stated metric. Its actual Gaussian curvature has no positive region and no one-dimensional flat locus.

The distinction is consequential beyond this example. Diagonal metrics occur in geometric modeling, anisotropic media, warped coordinates, and reduced physical systems. A coordinate coefficient can expand in one variable while another contracts in a second variable, yet the resulting intrinsic curvature may have a uniform sign. The present metric gives an elementary and unusually transparent case in which the complete answer follows from a sharp inequality on the unit square.

The paper is organized as follows. Section 2 defines the metric and its elementary scale quantities. Section 3 derives the connection and curvature. Section 4 proves global nonpositivity and identifies the unique flat point. Section 5 compares curvature with the schematic phase field. Sections 6 and 7 discuss geodesics, area, and computational methods. The final sections address applications, limitations, and the design of a genuinely sign-changing successor metric.

## 2. Metric structure and basic definitions

### 2.1. The metric

Let $M=\mathbb R^2$ with global coordinates $(x,y)$. Define

$$
g_{11}(x,y)=\operatorname{sech}^2y,
\qquad
g_{22}(x,y)=\cosh^2x,
\qquad g_{12}=g_{21}=0.
$$

Thus

$$
ds^2=g_{11}\,dx^2+g_{22}\,dy^2
=\frac{dx^2}{\cosh^2y}+\cosh^2x\,dy^2.
$$

Since $\cosh t>0$ for every real $t$, both diagonal entries are positive. Therefore $g$ is a smooth positive-definite metric on all of $\mathbb R^2$.

**Definition 2.1 (Directional scale factors).** The horizontal and vertical scale factors are

$$
h_x(x,y)=\sqrt{g_{11}}=\operatorname{sech}y,
\qquad
h_y(x,y)=\sqrt{g_{22}}=\cosh x.
$$

A coordinate displacement $(dx,0)$ has length $\operatorname{sech}y\,|dx|$, while $(0,dy)$ has length $\cosh x\,|dy|$.

**Definition 2.2 (Gaussian curvature).** The Gaussian curvature $K$ is the intrinsic curvature scalar satisfying

$$
R_{1212}=K\det(g),
$$

where $R$ is the Riemann curvature tensor in the coordinate basis.

**Definition 2.3 (Squared hyperbolic secant parameters).** For later use, set

$$
a=\operatorname{sech}^2x,
\qquad b=\operatorname{sech}^2y.
$$

The elementary inequality $\cosh t\ge1$ gives

$$
0<a\le1,
\qquad 0<b\le1.
$$

Equality $a=1$ holds exactly when $x=0$, and equality $b=1$ holds exactly when $y=0$.

### 2.2. Inverse metric and area density

The inverse matrix is

$$
(g^{ij})=
\begin{pmatrix}
\cosh^2y&0\\
0&\operatorname{sech}^2x
\end{pmatrix}.
$$

The determinant and Riemannian area density are

$$
\det g=\frac{\cosh^2x}{\cosh^2y},
\qquad
\sqrt{\det g}=\frac{\cosh x}{\cosh y}.
$$

Consequently, a measurable region $\Omega$ has geometric area

$$
\operatorname{Area}_g(\Omega)
=\iint_{\Omega}\frac{\cosh x}{\cosh y}\,dx\,dy.
$$

This formula quantifies the anisotropy: coordinate area is magnified for large $|x|$ and suppressed for large $|y|$.

## 3. Connection and curvature calculation

### 3.1. Christoffel symbols

The Levi-Civita connection has coefficients

$$
\Gamma^k_{ij}
=\frac12g^{k\ell}
\left(\partial_i g_{j\ell}+\partial_jg_{i\ell}-\partial_\ell g_{ij}\right).
$$

Differentiating the metric entries gives

$$
\partial_y g_{11}=-2\operatorname{sech}^2y\tanh y,
\qquad
\partial_x g_{22}=2\cosh^2x\tanh x,
$$

with $\partial_xg_{11}=0$ and $\partial_yg_{22}=0$. Substitution yields the nonzero Christoffel symbols

$$
\Gamma^1_{12}=\Gamma^1_{21}=-\tanh y,
$$

$$
\Gamma^1_{22}=-\cosh^2x\cosh^2y\tanh x,
$$

$$
\Gamma^2_{11}=\operatorname{sech}^2x\operatorname{sech}^2y\tanh y,
$$

$$
\Gamma^2_{12}=\Gamma^2_{21}=\tanh x.
$$

The remaining coordinate Christoffel symbols vanish. These coefficients are smooth on the whole plane, including both diagonals. Therefore the diagonals do not mark any change in the differential equation defining geodesics.

### 3.2. Orthogonal-metric curvature formula

For an orthogonal metric

$$
ds^2=A(x,y)^2\,dx^2+B(x,y)^2\,dy^2,
$$

Gaussian curvature can be written as

$$
K=-\frac{1}{AB}
\left[
\partial_x\left(\frac{\partial_xB}{A}\right)
+
\partial_y\left(\frac{\partial_yA}{B}\right)
\right].
$$

Here

$$
A=\operatorname{sech}y,
\qquad B=\cosh x,
\qquad AB=\frac{\cosh x}{\cosh y}.
$$

For the first derivative,

$$
\frac{\partial_xB}{A}=\sinh x\cosh y,
\qquad
\partial_x\left(\frac{\partial_xB}{A}\right)=\cosh x\cosh y.
$$

For the second,

$$
\partial_yA=-\operatorname{sech}y\tanh y,
$$

so

$$
\frac{\partial_yA}{B}
=-\frac{\operatorname{sech}y\tanh y}{\cosh x}.
$$

Using

$$
\frac{d}{dy}\bigl(\operatorname{sech}y\tanh y\bigr)
=\operatorname{sech}y\bigl(2\operatorname{sech}^2y-1\bigr),
$$

we obtain

$$
\partial_y\left(\frac{\partial_yA}{B}\right)
=-\frac{\operatorname{sech}y}{\cosh x}
\bigl(2\operatorname{sech}^2y-1\bigr).
$$

Combining these terms and simplifying proves the curvature formula.

**Theorem 3.1 (Curvature formula).** The Gaussian curvature of $g$ is

$$
K(x,y)=-\cosh^2y-\operatorname{sech}^2x
+2\operatorname{sech}^2x\operatorname{sech}^2y.
$$

**Proof sketch.** Insert $A=\operatorname{sech}y$ and $B=\cosh x$ into the orthogonal-metric formula above. Evaluate the two derivatives explicitly, multiply by $-(AB)^{-1}$, and use $\tanh^2y=1-\operatorname{sech}^2y$. The displayed expression follows after collecting terms. $\square$

## 4. Complete curvature phase portrait

The closed formula still contains a positive interaction term, so its sign is not immediate from inspection. The following elementary lemma controls it.

**Lemma 4.1 (Parameter inequality).** If $0<a\le1$ and $0<b\le1$, then

$$
-\frac1b-a+2ab\le0.
$$

Equality holds if and only if $a=b=1$.

**Proof sketch.** Multiply by $b>0$. It is enough to prove

$$
-1-ab+2ab^2\le0,
$$

or equivalently

$$
ab(2b-1)\le1.
$$

If $2b-1\le0$, the left side is nonpositive. If $2b-1>0$, then $a\le1$ and $b\le1$ imply

$$
ab(2b-1)\le 2b-1\le1.
$$

For equality, the first case is impossible. In the second case, equality requires $2b-1=1$, hence $b=1$, and then $a=1$. Conversely, $a=b=1$ gives equality. $\square$

**Theorem 4.2 (Global nonpositivity).** At every $(x,y)\in\mathbb R^2$,

$$
K(x,y)\le0.
$$

**Proof sketch.** Set $a=\operatorname{sech}^2x$ and $b=\operatorname{sech}^2y$. Since $\cosh^2y=1/b$, Theorem 3.1 becomes

$$
K=-\frac1b-a+2ab.
$$

The bounds $0<a,b\le1$ permit direct application of Lemma 4.1. $\square$

**Theorem 4.3 (Unique flat point).** The curvature vanishes precisely at the origin:

$$
K(x,y)=0
\quad\Longleftrightarrow\quad
x=0\ \text{and}\ y=0.
$$

**Proof sketch.** Equality in Lemma 4.1 requires $a=b=1$. The identity $\operatorname{sech}^2t=1$ is equivalent to $\cosh t=1$, which for real $t$ is equivalent to $t=0$. Thus $x=y=0$. Direct substitution shows $K(0,0)=0$. $\square$

**Corollary 4.4 (Strict negativity off the origin).** If $(x,y)\ne(0,0)$, then

$$
K(x,y)<0.
$$

**Proof sketch.** Global nonpositivity gives $K\le0$, and the unique-flat-point theorem excludes equality away from the origin. $\square$

**Corollary 4.5 (Curvature on the diagonals).** For every nonzero $t$,

$$
K(t,t)<0
\qquad\text{and}\qquad
K(t,-t)<0.
$$

**Proof sketch.** Both $(t,t)$ and $(t,-t)$ differ from the origin whenever $t\ne0$, so Corollary 4.4 applies. $\square$

These statements completely determine the sign portrait. There are no positive-curvature points. The zero set is zero-dimensional, consisting of one point, rather than the union of two lines.

### 4.1. Asymptotic behavior

The formula also gives useful limits. For fixed $y$,

$$
\lim_{|x|\to\infty}K(x,y)=-\cosh^2y,
$$

because $\operatorname{sech}^2x\to0$. For fixed $x$,

$$
\lim_{|y|\to\infty}K(x,y)=-\infty,
$$

because $-\cosh^2y$ dominates while $\operatorname{sech}^2y\to0$. Thus curvature becomes arbitrarily negative in the vertical direction, whereas along horizontal escape it approaches a finite negative value depending on $y$.

A local expansion near the origin is also informative. Using

$$
\cosh^2y=1+y^2+O(y^4),
\qquad
\operatorname{sech}^2t=1-t^2+O(t^4),
$$

we find

$$
K(x,y)=-x^2-3y^2+O\bigl((x^2+y^2)^2\bigr).
$$

The unique zero is therefore a strict local maximum of curvature, with anisotropic quadratic decay.

## 5. Independent consistency checks

The curvature formula admits several checks that are useful both conceptually and computationally.

### 5.1. Symmetry

Every occurrence of $x$ and $y$ in $K$ is through an even function. Therefore

$$
K(-x,y)=K(x,y)=K(x,-y).
$$

The curvature portrait is symmetric under reflection across either coordinate axis. It is not, however, symmetric under exchanging $x$ and $y$: the term $-\cosh^2y$ has no corresponding $-\cosh^2x$ term. This asymmetry agrees with the metric itself, which assigns reciprocal hyperbolic scaling to the horizontal direction and direct hyperbolic scaling to the vertical direction.

### 5.2. Axis restrictions

On the horizontal axis, $b=1$, so

$$
K(x,0)=-1+\operatorname{sech}^2x=-\tanh^2x.
$$

This is zero at $x=0$ and negative elsewhere, approaching $-1$ as $|x|\to\infty$. On the vertical axis, $a=1$, giving

$$
K(0,y)=-\cosh^2y-1+2\operatorname{sech}^2y.
$$

The second expression is likewise zero only at $y=0$ and decreases without bound as $|y|$ grows. These one-dimensional restrictions agree with the global theorem and expose the strong directional asymmetry of the curvature decay.

### 5.3. Curvature bounds on horizontal strips

Fix $Y\ge0$ and consider the strip $|y|\le Y$. Since curvature is nonpositive and continuous, its upper bound is $0$, attained only at the origin. A simple lower bound follows from $\cosh^2y\le\cosh^2Y$, $0<a\le1$, and $2ab\ge0$:

$$
K(x,y)\ge-\cosh^2Y-1.
$$

Thus curvature is bounded on every horizontal strip. By contrast, no global finite lower bound exists because $K(x,y)\to-\infty$ as $|y|\to\infty$.

### 5.4. Local area comparison

Near the origin,

$$
\frac{\cosh x}{\cosh y}
=1+\frac{x^2-y^2}{2}+O\bigl((x^2+y^2)^2\bigr).
$$

Small coordinate regions centered at the origin therefore have Euclidean area to leading order, with a second-order correction that increases area in the horizontal direction and decreases it in the vertical direction. This local area anisotropy coexists with the negative quadratic curvature expansion

$$
K(x,y)=-x^2-3y^2+O\bigl((x^2+y^2)^2\bigr).
$$

The two expansions reinforce the main distinction: directional area distortion and intrinsic curvature encode related but nonidentical information.

### 5.5. Numerical validation protocol

A robust implementation should check exact landmarks before producing large plots. The identities $K(0,0)=0$ and $K(x,0)=-\tanh^2x$ test both the interaction term and the sign convention. Reflection tests compare $K(x,y)$ with $K(-x,y)$ and $K(x,-y)$. Grid maxima should occur at the origin when the grid contains it, while diagonal samples away from the origin should be negative even though $P$ vanishes. Finally, exact rectangle areas provide reference values for numerical integration of the volume density. These checks do not prove the theorems, but they detect transcription, sign, and stability errors in computational work.

## 6. The schematic phase field

Define

$$
P(x,y)=\operatorname{sech}^2x-\operatorname{sech}^2y.
$$

This field reflects a coordinate symmetry but is not an intrinsic curvature invariant.

**Proposition 5.1 (Zero set of the schematic field).** The equality $P(x,y)=0$ holds exactly when $|x|=|y|$, equivalently when $y=x$ or $y=-x$.

**Proof sketch.** The function $t\mapsto\operatorname{sech}^2t$ is even and strictly decreasing on $[0,\infty)$. Therefore equal values occur precisely when the absolute values of the arguments agree. $\square$

**Theorem 5.2 (Intersection of zero loci).** The phase field and Gaussian curvature vanish simultaneously exactly at the origin:

$$
P(x,y)=0\ \text{and}\ K(x,y)=0
\quad\Longleftrightarrow\quad
(x,y)=(0,0).
$$

**Proof sketch.** If both fields vanish, Theorem 4.3 applied to $K$ forces $(x,y)=(0,0)$. Conversely, direct substitution gives $P(0,0)=K(0,0)=0$. $\square$

The result clarifies the conceptual error behind the proposed diagonal phase boundary. The zero set of $P$ records where two scalar coordinate expressions coincide. The zero set of $K$ records where the intrinsic metric is locally flat to second order. No principle requires these sets to agree.

## 7. Geodesic equations and consequences

Let $\gamma(s)=(x(s),y(s))$ be an affinely parametrized geodesic, and use dots for derivatives with respect to $s$. The coordinate equations are

$$
\ddot x+\Gamma^1_{11}\dot x^2
+2\Gamma^1_{12}\dot x\dot y
+\Gamma^1_{22}\dot y^2=0,
$$

$$
\ddot y+\Gamma^2_{11}\dot x^2
+2\Gamma^2_{12}\dot x\dot y
+\Gamma^2_{22}\dot y^2=0.
$$

Substitution of the symbols from Section 3 gives

$$
\ddot x-2\tanh y\,\dot x\dot y
-\cosh^2x\cosh^2y\tanh x\,\dot y^2=0,
$$

$$
\ddot y
+\operatorname{sech}^2x\operatorname{sech}^2y\tanh y\,\dot x^2
+2\tanh x\,\dot x\dot y=0.
$$

The energy

$$
E=\frac12\left(
\operatorname{sech}^2y\,\dot x^2+
\cosh^2x\,\dot y^2
\right)
$$

is constant along affine geodesics. This supplies a useful numerical diagnostic.

The equations are smoothly coupled and their coefficients have no discontinuity or change of definition at $y=\pm x$. Hence geodesics are not naturally piecewise-defined at those diagonals. In particular, a claimed universal bound on the number of diagonal crossings cannot be justified by a transition in curvature sign, because no such transition exists. Establishing or refuting a crossing bound requires a separate dynamical analysis or a controlled numerical search.

Nonpositive curvature often leads, under suitable completeness and global hypotheses, to uniqueness of geodesics and convexity of distance. Those consequences should not be asserted here without first establishing completeness. The horizontal coefficient tends to zero as $|y|$ grows, and the interaction between shrinking and expanding directions makes completeness a substantive question rather than an automatic one.

## 8. Numerical algorithms

### 8.1. Stable pointwise curvature evaluation

For moderate coordinates, the closed formula can be evaluated directly. For large $|t|$, computing $\cosh t$ may overflow in floating-point arithmetic. A stable squared-secant routine uses

$$
\operatorname{sech}^2t
=\frac{4e^{-2|t|}}{(1+e^{-2|t|})^2}.
$$

When $|y|$ is within the floating-point range of $\cosh$, one evaluates

$$
K=-\cosh^2y-a+2ab.
$$

For extreme $|y|$, the mathematically correct conclusion is that $K$ is a very large negative number; software may return negative infinity as the floating-point representation of that limit.

The computational cost is $O(1)$ time and $O(1)$ memory per point. A grid of $N_xN_y$ points costs $O(N_xN_y)$ time.

### 8.2. Numerical sign audit

A grid audit proceeds as follows:

1. Choose coordinate bounds and a rectangular grid.
2. Evaluate $K$ and $P$ at every node.
3. Record the maximum sampled curvature and its location.
4. Check that all non-origin samples have negative curvature within a specified tolerance.
5. Compare near-zero samples of $P$ with the curvature values on the same nodes.

Such an audit illustrates the theorem but does not replace the global inequality. A finite grid could miss a small positive region; Lemma 4.1 excludes that possibility analytically.

### 8.3. Geodesic integration

Convert the second-order geodesic equations into a first-order system for $(x,y,u,v)=(x,y,\dot x,\dot y)$:

$$
\dot x=u,
\qquad \dot y=v,
$$

$$
\dot u=2\tanh y\,uv
+\cosh^2x\cosh^2y\tanh x\,v^2,
$$

$$
\dot v=-\operatorname{sech}^2x\operatorname{sech}^2y\tanh y\,u^2
-2\tanh x\,uv.
$$

A fourth-order Runge–Kutta method gives a practical exploratory solver. During integration, one monitors relative drift in $E$ and detects sign changes in $y-x$ and $y+x$ to estimate diagonal crossings. Step refinement is essential before interpreting any observed crossing count.

## 9. Area calculations and geometric examples

For a coordinate rectangle $[x_0,x_1]\times[y_0,y_1]$, separability of the area density gives

$$
\operatorname{Area}_g
=\left(\int_{x_0}^{x_1}\cosh x\,dx\right)
\left(\int_{y_0}^{y_1}\operatorname{sech}y\,dy\right).
$$

Using

$$
\int\cosh x\,dx=\sinh x
$$

and

$$
\int\operatorname{sech}y\,dy
=\arctan(\sinh y),
$$

we obtain

$$
\operatorname{Area}_g
=\bigl(\sinh x_1-\sinh x_0\bigr)
\bigl(\arctan(\sinh y_1)-\arctan(\sinh y_0)\bigr).
$$

This exact formula is a useful check on numerical quadrature.

For a coordinate triangle, one must specify its vertices and integration limits. For example, the right coordinate triangle

$$
T_L=\{(x,y):0\le x\le L,\ 0\le y\le L-x\}
$$

has area

$$
\operatorname{Area}_g(T_L)
=\int_0^L\cosh x
\left(\int_0^{L-x}\operatorname{sech}y\,dy\right)dx,
$$

or

$$
\operatorname{Area}_g(T_L)
=\int_0^L\cosh x\,\arctan(\sinh(L-x))\,dx.
$$

This one-dimensional integral is readily computed numerically. It should not be confused with the area of a geodesic triangle having the same vertices, because coordinate line segments need not be geodesics.

## 10. Applications and interpretation

The metric provides a compact case study in anisotropic geometric modeling. In an anisotropic medium, different coordinate directions can carry different local costs. The entries $g_{11}$ and $g_{22}$ specify those costs, while curvature measures the incompatibility of neighboring local rulers. The example shows that one scale factor decreasing and another increasing does not force mixed curvature.

In geometric data analysis, a learned or prescribed metric may magnify motion in one feature and suppress motion in another. Interpreting such scaling as local “positive” or “negative” geometry without calculating curvature can be misleading. The intrinsic invariant depends on spatial derivatives of the full metric.

The example is also relevant to the design of analog geometries. If one wants an interface between positive and negative curvature, prescribing a visually plausible phase field is insufficient. One must solve an inverse problem: choose metric coefficients whose curvature equation has the desired sign structure, while preserving smoothness and positive definiteness.

## 11. Discussion and limitations

The central achievement is a complete correction of the curvature portrait for the stated metric. The result does not establish several broader claims that might be associated with the original split-geometry motivation.

First, the curvature formula alone does not prove geodesic completeness. Second, it does not imply a universal bound on diagonal crossings. Third, it does not support literal piecewise exponential and trigonometric geodesics, because the geodesic coefficients are smooth across the diagonals. Fourth, the phrase “triangle with one vertex in each region” is ambiguous once the supposed curvature regions are absent; even independently of that issue, triangle area requires specified vertices and edge types.

These are not defects in the curvature theorem. They delimit what follows from it. The established conclusions are exact: global nonpositivity, a unique flat point, strict negativity elsewhere, and negative curvature at all non-origin diagonal points.

## 12. Future work

A first priority is an intrinsic derivation of the curvature tensor directly from the metric and Levi-Civita connection, complementing the orthogonal-coordinate calculation. A second is a rigorous analysis of completeness and global geodesic behavior. If completeness holds, the simply connected plane with nonpositive curvature would be positioned for strong global conclusions; if it fails, the incomplete directions should be classified.

The coupled geodesic system merits both numerical and analytic study. In particular, diagonal-crossing claims should first be subjected to a careful counterexample search with energy control and adaptive integration. Area computations should begin with explicitly specified coordinate regions and then move to geodesic polygons.

Finally, a genuine sign-changing metric can be sought in the broader family

$$
ds^2=E(y)\,dx^2+G(x)\,dy^2,
$$

where $E$ and $G$ are smooth positive functions. The orthogonal-metric curvature formula turns the desired zero set into a differential design constraint. Candidate coefficients can be generated symbolically or numerically, after which global inequalities analogous to Lemma 4.1 can certify the phase portrait.

## 13. Conclusion

The metric

$$
ds^2=\operatorname{sech}^2y\,dx^2+\cosh^2x\,dy^2
$$

combines horizontal contraction and vertical expansion, but its Gaussian curvature does not split into positive and negative phases. Its exact curvature is

$$
K=-\cosh^2y-\operatorname{sech}^2x
+2\operatorname{sech}^2x\operatorname{sech}^2y,
$$

which is nonpositive everywhere, zero only at $(0,0)$, and strictly negative elsewhere. The diagonals are zero lines of a natural schematic phase field, not flat curvature boundaries. This distinction between coordinate anisotropy and intrinsic curvature is the main conceptual lesson: opposing directional scale changes can coexist with a uniform curvature sign, and the decisive object is the curvature derived from the complete metric rather than a visually suggestive surrogate.
