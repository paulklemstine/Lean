# An Anisotropic Hyperbolic-Cosine Metric on the Plane: Connection, Area, and Global Curvature Sign

**Aristotle**  
**18 July 2026**

## Abstract

We study the smooth diagonal Riemannian metric on $\mathbb R^2$

$$
ds^2=\operatorname{sech}^2(y)\,dx^2+\cosh^2(x)\,dy^2.
$$

The metric was motivated by a proposed “split geometry” in which contraction of horizontal lengths and expansion of vertical lengths might produce regions of opposite Gaussian curvature. We establish that the metric is positive definite everywhere, compute its area density and all independent Levi–Civita connection coefficients, derive its geodesic system, and evaluate its Gaussian curvature exactly. The curvature is

$$
K(x,y)=-\cosh^2 y+rac{1-\sinh^2 y}{\cosh^2x\cosh^2y}.
$$

Contrary to the motivating sign-change conjecture, $K\le 0$ globally, with equality exactly at the origin; hence every non-origin point has strictly negative curvature. In particular, the diagonals are not phase boundaries and there is no positive-curvature region. We explain the distinction between directional anisotropy and intrinsic curvature, give numerical algorithms for evaluating the metric invariants and integrating area, and formulate corrected geometric questions concerning geodesics, triangle areas, completeness, and the exponential map.

## 1. Introduction

A diagonal metric is often interpreted through its coordinate scale factors. In the metric

$$
ds^2=\frac{dx^2}{\cosh^2y}+\cosh^2x\,dy^2,
$$

horizontal coordinate displacements become geometrically cheaper as $|y|$ increases, whereas vertical coordinate displacements become more expensive as $|x|$ increases. The construction therefore combines contraction and expansion in orthogonal directions. This makes it natural to ask whether the plane divides into regions of positive and negative curvature, with a flat transition set between them.

That intuition is attractive but incomplete. Gaussian curvature is intrinsic and nonlinear. It depends not only on the magnitudes of the coordinate coefficients but on how both coefficients vary and interact through the Levi–Civita connection. Anisotropy does not by itself imply mixed curvature.

This paper provides an exact coordinate analysis. We first prove regularity and positive definiteness. We then compute the Riemannian density and the six independent Christoffel symbols in dimension two. These symbols yield a coupled smooth geodesic equation. Finally, the Brioschi formula for orthogonal coordinates gives a closed curvature expression whose global sign can be settled algebraically.

The result corrects three proposed consequences at once. First, the expected diagonal zero-curvature locus is absent: the zero set is the singleton $\{(0,0)\}$. Second, there are no elliptic regions; all non-origin points are negatively curved. Third, geodesics are not naturally piecewise exponential and trigonometric curves separated by diagonals, because the governing coefficients are smooth and no curvature phase boundary exists.

## 2. Preliminaries and definitions

Write

$$
E(x,y)=\operatorname{sech}^2y=\frac{1}{\cosh^2y},
\qquad
G(x,y)=\cosh^2x.
$$

The metric tensor in the coordinate frame $(\partial_x,\partial_y)$ is

$$
(g_{ij})=
\begin{pmatrix}
E&0\\
0&G
\end{pmatrix}
=
\begin{pmatrix}
\cosh^{-2}y&0\\
0&\cosh^2x
\end{pmatrix}.
$$

We use the elementary identities

$$
\cosh t>0,
\qquad
\cosh^2t-\sinh^2t=1,
\qquad
\tanh t=\frac{\sinh t}{\cosh t}.
$$

### Definition 2.1 (Metric norm)

For a tangent vector $w=u\partial_x+v\partial_y$ at $(x,y)$, define

$$
\|w\|_g^2=E(x,y)u^2+G(x,y)v^2
=\frac{u^2}{\cosh^2y}+\cosh^2x\,v^2.
$$

### Theorem 2.2 (Global positive definiteness)

For every $(x,y)\in\mathbb R^2$ and every nonzero $(u,v)\in\mathbb R^2$,

$$
\frac{u^2}{\cosh^2y}+\cosh^2x\,v^2>0.
$$

Consequently, $g$ is a smooth Riemannian metric on all of $\mathbb R^2$.

**Proof sketch.** Both $\cosh^{-2}y$ and $\cosh^2x$ are strictly positive. Both summands are nonnegative, and whichever of $u$ or $v$ is nonzero contributes a strictly positive summand. Smoothness follows because $\cosh y$ never vanishes. $\square$

This theorem rules out degeneracy. Although one coefficient tends toward zero as $|y|\to\infty$, it never reaches zero at a finite point.

### Definition 2.3 (Riemannian area)

The Riemannian area density is $\sqrt{\det g}$. Since

$$
\det g=EG=\frac{\cosh^2x}{\cosh^2y},
$$

and both hyperbolic cosines are positive, the density is

$$
\rho(x,y)=\sqrt{\det g}=\frac{\cosh x}{\cosh y}.
$$

Thus a measurable region $R$ has metric area

$$
\operatorname{Area}_g(R)=\iint_R\frac{\cosh x}{\cosh y}\,dx\,dy,
$$

whenever the integral exists.

### Theorem 2.4 (Positive area density)

For all $(x,y)\in\mathbb R^2$, $\rho(x,y)>0$, and

$$
\rho(x,y)^2=E(x,y)G(x,y).
$$

**Proof sketch.** Positivity is immediate from $\cosh x>0$ and $\cosh y>0$. Squaring the quotient gives the determinant. $\square$

The density quantifies a second anisotropy. At fixed $y$, area grows roughly exponentially with $|x|$; at fixed $x$, it decays roughly exponentially with $|y|$.

## 3. Levi–Civita connection

The Christoffel symbols of a metric are

$$
\Gamma^k_{ij}=\frac12g^{k\ell}
\left(\partial_i g_{j\ell}+\partial_j g_{i\ell}-\partial_\ell g_{ij}\right),
$$

with summation over $\ell$. For the present diagonal metric, the only coefficient derivatives needed are

$$
\partial_yE=-\frac{2\sinh y}{\cosh^3y},
\qquad
\partial_xG=2\cosh x\sinh x,
$$

while $\partial_xE=0$ and $\partial_yG=0$. The inverse metric is

$$
(g^{ij})=
\begin{pmatrix}
\cosh^2y&0\\
0&\cosh^{-2}x
\end{pmatrix}.
$$

### Theorem 3.1 (Complete connection coefficients)

The independent Christoffel symbols are

$$
\Gamma^1_{11}=0,
\qquad
\Gamma^2_{22}=0,
$$

$$
\Gamma^1_{12}=\Gamma^1_{21}=-\frac{\sinh y}{\cosh y}=-\tanh y,
$$

$$
\Gamma^1_{22}=-\cosh^2y\,\cosh x\,\sinh x,
$$

$$
\Gamma^2_{11}=\frac{\sinh y}{\cosh^3y\,\cosh^2x},
$$

and

$$
\Gamma^2_{12}=\Gamma^2_{21}=\frac{\sinh x}{\cosh x}=\tanh x.
$$

**Proof sketch.** Substitution into the coordinate formula gives

$$
\Gamma^1_{12}=\frac12E^{-1}\partial_yE,
\qquad
\Gamma^1_{22}=-\frac12E^{-1}\partial_xG,
$$

$$
\Gamma^2_{11}=-\frac12G^{-1}\partial_yE,
\qquad
\Gamma^2_{12}=\frac12G^{-1}\partial_xG.
$$

The two diagonal symbols vanish because $E$ is independent of $x$ and $G$ is independent of $y$. Simplifying with the positive, nonzero hyperbolic cosines gives the stated expressions. Symmetry in the lower indices follows from the torsion-free property. $\square$

### Corollary 3.2 (Geodesic equations)

A twice differentiable curve $\gamma(t)=(x(t),y(t))$ is an affinely parameterized geodesic if and only if

$$
\ddot x-2\tanh y\,\dot x\dot y
-\cosh^2y\,\cosh x\,\sinh x\,\dot y^2=0,
$$

$$
\ddot y+rac{\sinh y}{\cosh^3y\,\cosh^2x}\,\dot x^2
+2\tanh x\,\dot x\dot y=0.
$$

**Proof sketch.** Insert the symbols of Theorem 3.1 into $\ddot q^k+\Gamma^k_{ij}\dot q^i\dot q^j=0$. The mixed terms occur twice because $\Gamma^k_{12}=\Gamma^k_{21}$. $\square$

All coefficients in this system are smooth on $\mathbb R^2$. Standard smooth ordinary differential equation theory therefore gives local existence and uniqueness for each initial position and velocity. It also shows why a piecewise description based on diagonal boundaries has no immediate basis: there is no discontinuity or change of equation on those lines.

### Proposition 3.3 (Conservation of speed)

Along every affinely parameterized geodesic, the energy

$$
\mathcal E=\frac12\left(\frac{\dot x^2}{\cosh^2y}+\cosh^2x\,\dot y^2\right)
$$

is constant.

**Proof sketch.** The geodesic equations are the Euler–Lagrange equations for the time-independent Lagrangian $\mathcal E$. Differentiating $\mathcal E$ along a solution, substituting the two geodesic equations, and collecting terms produces cancellation. Equivalently, metric compatibility of the Levi–Civita connection gives $d\,g(\dot\gamma,\dot\gamma)/dt=2g(\nabla_{\dot\gamma}\dot\gamma,\dot\gamma)=0$. $\square$

## 4. Exact Gaussian curvature

For an orthogonal metric $ds^2=E\,dx^2+G\,dy^2$ with $E,G>0$, the Brioschi formula can be written

$$
K=-\frac{1}{2\sqrt{EG}}
\left[
\partial_x\left(\frac{\partial_xG}{\sqrt{EG}}\right)
+
\partial_y\left(\frac{\partial_yE}{\sqrt{EG}}\right)
\right].
$$

In our case, $\sqrt{EG}=\cosh x/\cosh y$. The first differentiated expression becomes

$$
\partial_x\left(\frac{2\cosh x\sinh x}{\cosh x/\cosh y}\right)
=
\partial_x(2\sinh x\cosh y)
=2\cosh x\cosh y.
$$

For the second expression,

$$
\frac{\partial_yE}{\sqrt{EG}}
=-\frac{2\sinh y}{\cosh^3y}\frac{\cosh y}{\cosh x}
=-\frac{2\sinh y}{\cosh x\cosh^2y},
$$

and differentiation gives

$$
\partial_y\left(\frac{\partial_yE}{\sqrt{EG}}\right)
=-\frac{2(1-\sinh^2y)}{\cosh x\cosh^3y}.
$$

### Theorem 4.1 (Exact curvature formula)

The Gaussian curvature is

$$
K(x,y)=-\cosh^2y+
\frac{1-\sinh^2y}{\cosh^2x\cosh^2y}.
$$

**Proof sketch.** Substitute the two differentiated expressions above and $\sqrt{EG}=\cosh x/\cosh y$ into Brioschi’s formula. Distribution of the prefactor produces $-\cosh^2y$ from the $x$ derivative and the displayed rational term from the $y$ derivative. $\square$

At the origin, $\cosh0=1$ and $\sinh0=0$, hence $K(0,0)=0$.

### Theorem 4.2 (Global curvature sign and rigidity of equality)

For every $(x,y)\in\mathbb R^2$,

$$
K(x,y)\le0.
$$

Moreover,

$$
K(x,y)=0\quad\Longleftrightarrow\quad x=0\text{ and }y=0.
$$

Thus $K(x,y)<0$ whenever $(x,y)\ne(0,0)$.

**Proof sketch.** Multiply the curvature by the positive quantity $\cosh^2x\cosh^2y$. The desired inequality is equivalent to

$$
1-\sinh^2y
\le
\cosh^2x\cosh^4y.
$$

The right side is at least $\cosh^4y$, because $\cosh^2x\ge1$. Also $\cosh^4y\ge1$, whereas $1-\sinh^2y\le1$. Therefore the inequality holds. Equality throughout forces $\cosh^2x=1$ and $\cosh^4y=1$, equivalently $\sinh x=\sinh y=0$, hence $x=y=0$. Conversely, direct substitution gives equality at the origin. $\square$

This short comparison proof also exposes the strictness mechanism: any displacement in either coordinate makes at least one bounding inequality strict.

### Corollary 4.3 (Horizontal-axis curvature)

For all $x\in\mathbb R$,

$$
K(x,0)=-1+\frac1{\cosh^2x}=-\tanh^2x.
$$

Consequently, $K(x,0)<0$ for every $x\ne0$.

**Proof sketch.** Set $y=0$ in Theorem 4.1 and use $1-\operatorname{sech}^2x=\tanh^2x$. $\square$

The horizontal axis lies inside the region $|x|>|y|$ except at the origin, so this corollary directly contradicts any proposed positive-curvature classification of that region.

### Corollary 4.4 (Absence of a diagonal phase boundary)

Every point on either diagonal $y=x$ or $y=-x$, except the origin, has strictly negative curvature. Hence neither diagonal is a zero-curvature locus, and the metric has no boundary separating positive and negative curvature phases.

**Proof sketch.** A non-origin point on either diagonal is a non-origin point of the plane, so Theorem 4.2 applies. $\square$

## 5. Interpretation: anisotropy versus intrinsic curvature

The metric has unmistakably opposite directional scale trends. Nevertheless, those trends cannot be assigned separate Gaussian curvatures. Gaussian curvature is attached to a tangent plane, not independently to each coordinate direction. In two dimensions the sectional curvature of the sole tangent $2$-plane is exactly $K$.

Coordinate coefficients are also chart-dependent, while Gaussian curvature is invariant. Even when a diagonal chart is geometrically convenient, the signs suggested by “expansion” and “contraction” are not invariant data. The connection terms show the coupling explicitly: $\Gamma^1_{22}$ combines $x$ and $y$, and $\Gamma^2_{11}$ does the same. The Brioschi formula then differentiates normalized coefficient derivatives, producing cross-dependent contributions.

This observation has applications wherever directional scale factors appear. In anisotropic media, local propagation costs may differ by direction while curvature-like compatibility constraints remain global. In gravitation and cosmology, scale factors must be inserted into the full connection and curvature tensor rather than interpreted separately. In geometric models of growth, a prescribed local metric can encode expansion and contraction, but residual Gaussian curvature is determined by compatibility of the entire field.

## 6. Computational algorithms

The closed formulas permit stable pointwise evaluation without symbolic differentiation at run time.

### Algorithm 6.1 (Pointwise invariant evaluation)

Given $(x,y)$, compute $c_x=\cosh x$, $s_x=\sinh x$, $c_y=\cosh y$, and $s_y=\sinh y$. Then return

$$
E=c_y^{-2},\quad G=c_x^2,\quad \rho=c_x/c_y,
$$

all six independent Christoffel symbols from Theorem 3.1, and

$$
K=-c_y^2+\frac{1-s_y^2}{c_x^2c_y^2}.
$$

The algorithm uses constant time and constant memory for each point. On a grid of $N$ points it requires $O(N)$ time and $O(N)$ output storage, or $O(1)$ auxiliary storage in a streaming implementation.

### Algorithm 6.2 (Curvature-sign diagnostic)

For numerical work, evaluate $K$ and compare it with a tolerance $\varepsilon>0$. Report “approximately flat” if $|K|\le\varepsilon$ and “negative” otherwise. The exact theorem should guide interpretation: an approximately flat report away from the origin reflects floating-point tolerance, not a genuine zero-curvature phase.

### Algorithm 6.3 (Area quadrature for a specified region)

For a region described vertically by $a\le x\le b$ and $\ell(x)\le y\le u(x)$, approximate

$$
\int_a^b\int_{\ell(x)}^{u(x)}\frac{\cosh x}{\cosh y}\,dy\,dx
$$

using a tensor-product midpoint rule. With $n_xn_y=N$ cells, evaluation costs $O(N)$ time and $O(1)$ auxiliary memory. The integrand is smooth, so on a bounded region the composite midpoint rule has second-order convergence under standard regularity assumptions.

This area algorithm applies to coordinate-defined regions immediately. For a geodesic triangle, one must first compute or specify the three geodesic boundary arcs.

## 7. Geodesics and corrected boundary questions

Because the alleged sign-changing diagonals do not exist, a statement bounding how often geodesics cross them would not describe transitions between curvature phases. Coordinate diagonals can still be crossed, but such crossings have no intrinsic phase significance.

The actual flat locus is the single point $(0,0)$. A meaningful replacement asks how often a geodesic can pass through the origin. Local uniqueness says that a geodesic is determined near such a passage by its velocity. It does not alone exclude a later return. Resolving recurrence requires global control of the coupled ODE, perhaps through convexity, distance estimates, or additional monotonic quantities.

Some simple geodesics are visible from the equations. Along $y=0$ with $\dot y=0$, the second equation remains satisfied and the first reduces to $\ddot x=0$; hence horizontal straight lines through the origin, parameterized with constant $x$-speed, are geodesics. Along $x=0$ with $\dot x=0$, the first equation remains satisfied and the second reduces to $\ddot y=0$; vertical straight lines through the origin are likewise geodesics. General coordinate lines away from the opposite axis need not be geodesics because the transverse Christoffel terms do not vanish.

## 8. Areas of triangles and other regions

A triangle in a curved metric is usually bounded by geodesic segments. Its area depends on the vertices and on the selected segments if multiple geodesics join a pair of vertices. Therefore a description such as “one vertex in each curvature region” is insufficient in two independent ways here: the proposed regions do not exist, and no vertex coordinates or boundary curves are specified.

Once a region $T$ is fixed, however, its area is unambiguous:

$$
\operatorname{Area}_g(T)=\iint_T\frac{\cosh x}{\cosh y}\,dx\,dy.
$$

For an axis-aligned rectangle $[a,b]\times[c,d]$, the integral separates:

$$
\operatorname{Area}_g
=
\left(\int_a^b\cosh x\,dx\right)
\left(\int_c^d\operatorname{sech}y\,dy\right).
$$

Thus

$$
\operatorname{Area}_g
=(\sinh b-\sinh a)
\left(\arctan(\sinh d)-\arctan(\sinh c)\right),
$$

because $d(\arctan(\sinh y))/dy=\operatorname{sech}y$. This exact example illustrates how strongly the metric weights horizontal and vertical extent differently.

## 9. Discussion

The central outcome is a correction rather than confirmation. The metric is mathematically consistent and rich, but its curvature does not change sign. This is not a minor numerical discrepancy. The conjectured formula

$$
\operatorname{sech}^2x-\operatorname{sech}^2y
$$

would vanish on both diagonals and take both signs. The actual formula instead vanishes only at one point and is otherwise negative. Evaluating the horizontal axis already distinguishes the two: the conjectured expression would be positive for $x\ne0$, whereas the actual value is $-\tanh^2x<0$.

The example is useful methodologically. A compelling directional narrative should be tested through the complete intrinsic calculation. Positive definiteness, determinant, connection, and curvature form a natural pipeline. Each stage answers a different question: whether lengths are valid, how area transforms, how straight motion evolves, and what intrinsic curvature remains.

The metric also offers a tractable laboratory for nonuniform negative curvature. It is not uniformly bounded away from zero because $K(0,0)=0$ and continuity makes $K$ small nearby. Far in several directions its magnitude can grow substantially. Understanding how this variable curvature affects global geodesics is a promising next step.

## 10. Numerical examples and validation protocol

Several evaluations illustrate the theorems. At $(0,0)$, the coefficient pair is $(E,G)=(1,1)$, the area density is $1$, every Christoffel symbol vanishes, and $K=0$. At $(1,0)$, the horizontal-axis formula gives $K=-	anh^2(1)<0$, while the area density is $\cosh1>1$. At $(0,1)$, the area density is $1/\cosh1<1$, yet the curvature remains negative by Theorem 4.2. At $(1,1)$ and $(1,-1)$, the points lie on the proposed diagonals, but both have strictly negative curvature.

A reliable validation protocol separates exact identities from floating-point checks. First evaluate the closed formula directly. Second evaluate the Brioschi expression through its two differentiated terms. Third compare the results to a chosen numerical tolerance. Agreement tests an implementation, while the exact derivation establishes the mathematics. Sign classification should never replace a value by zero merely because its magnitude is small; the theorem says that only the exact origin is flat.

For trajectories, rewrite the second-order geodesic equations as a first-order system in $(x,y,p,q)=(x,y,\dot x,\dot y)$. A standard adaptive Runge--Kutta method can then integrate the system. Monitoring

$$
rac{p^2}{\cosh^2y}+\cosh^2x\,q^2
$$

provides an internal error diagnostic because this speed squared is conserved analytically. Drift indicates that the time step or tolerance should be tightened. Such integration supplies evidence about global behavior but does not by itself prove completeness or recurrence claims.

## 11. Limitations of the present analysis

The coordinate calculations completely determine local metric invariants, but they do not settle every global question. Smooth coefficients guarantee local geodesic solutions; they do not automatically guarantee that every solution exists for all affine time. Negative curvature away from one point does not alone establish simple connectivity of exponential images, uniqueness of geodesics between arbitrary points, or quantitative divergence rates without additional hypotheses.

Likewise, the area density determines the area of any specified measurable region, but a “triangle” is not specified until its vertices and boundary arcs are fixed. Numerical quadrature introduces discretization error that should be estimated by refinement. Finally, coordinate anisotropy is real, but statements calling one coordinate direction “expanding” are descriptive rather than invariant; the invariant conclusions in this paper are positive definiteness, the volume form, the connection, the geodesic equation, and Gaussian curvature.

## 12. Future work

First, the coordinate curvature computation should be related directly to the intrinsic Riemann tensor and sectional curvature. This would place the formula within a coordinate-free framework.

Second, the smooth geodesic ODE warrants systematic analysis: local existence and uniqueness, conserved speed, global continuation, and numerical trajectories. The idea of piecewise exponential and trigonometric geodesics should be replaced by tests against this actual coupled system.

Third, because the flat set is only the origin, the appropriate crossing question is whether a geodesic can pass through the origin more than once. This is a recurrence problem, not a phase-boundary problem.

Fourth, geodesic triangles should be studied only after their vertices and connecting arcs are specified. Their area is then obtained by integrating $\cosh x/\cosh y$ over the enclosed region, with Gauss–Bonnet offering a possible relation among area-weighted curvature, angles, and topology.

Finally, global metric properties remain open for investigation: geodesic completeness, distance estimates, behavior of metric balls, and the global exponential map. The coefficients’ strong anisotropy makes completeness particularly subtle and important.

## 12.1 Broader consequences

The example also clarifies what survives when an initial geometric interpretation fails. The proposed phase decomposition disappears, but the metric itself remains a legitimate source of exact questions. Its volume distortion is separable, its local steering law is explicit, and its curvature has a global sign with a rigid equality case. These properties make it suitable for benchmarking numerical geodesic solvers and for comparing coordinate distortion with intrinsic invariants.

More generally, the calculation suggests a design principle for constructing metrics with a desired curvature pattern. Choosing two opposing scale factors is not enough. One must solve, or at least analyze, the nonlinear differential relation imposed by the Brioschi formula. If a genuine sign-changing geometry is desired, its coefficients should be designed from the curvature equation rather than inferred from qualitative expansion and contraction. The present metric supplies a counterexample to that inference and a baseline against which future designs can be measured.

## 13. Conclusion

The hyperbolic-cosine metric

$$
ds^2=\operatorname{sech}^2y\,dx^2+\cosh^2x\,dy^2
$$

defines a smooth positive-definite geometry on the plane with area density $\cosh x/\cosh y$. Its Levi–Civita connection is explicit, and its geodesics obey one globally smooth coupled system. Its Gaussian curvature is

$$
K(x,y)=-\cosh^2y+rac{1-\sinh^2y}{\cosh^2x\cosh^2y},
$$

which is zero only at the origin and strictly negative everywhere else. Directional expansion and contraction therefore do not generate coexisting elliptic and hyperbolic phases. The resulting geometry is instead a globally saddle-like, anisotropic plane with a unique flat point—an exact example of why intrinsic curvature must be calculated rather than inferred from directional scale factors.
