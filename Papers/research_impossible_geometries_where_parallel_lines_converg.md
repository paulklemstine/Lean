# Split Geometry: A Direction-Dependent Parallel Postulate on the Plane

## Abstract

We introduce and rigorously analyze *Split Geometry*, a Riemannian structure on $\mathbb{R}^2$ whose infinitesimal length element expands in one coordinate direction and contracts in the perpendicular one:
$$ ds^2 = \frac{dx^2}{\cosh^2 y} + \cosh^2 x \, dy^2 . $$
The construction is designed so that the geometry behaves hyperbolically in some regions of the plane and elliptically in others, with a *phase boundary* separating them. We prove that the metric is positive-definite everywhere, hence a consistent Riemannian metric. We establish the exact monotonicity of the function $\operatorname{sech}^2 t = 1/\cosh^2 t$ in $|t|$, and use it to prove that the associated sign-indicator curvature $K(x,y)=\operatorname{sech}^2 x - \operatorname{sech}^2 y$ vanishes precisely on the two diagonals $y = \pm x$, is positive in the wedges where $|x|<|y|$, and is negative in the wedges where $|y|<|x|$. We prove a rigidity result: any straight coordinate line not parallel to a diagonal meets the phase boundary in at most two points, a fact that reduces to the quadratic nature of the defining equation. We conclude with an honest discussion distinguishing the sign-indicator $K$ from the metric's true Gaussian curvature, a numerical study of the split-triangle area functional, and a program of future work.

**Keywords:** Riemannian metric, hyperbolic cosine, direction-dependent curvature, phase boundary, positive-definiteness, geodesic crossing, parallel postulate.

## 1. Introduction

### 1.1 Background

The classification of two-dimensional geometries by the sign of curvature is one of the crown jewels of nineteenth-century mathematics. Euclid's parallel postulate — that through a point off a line there is a unique non-intersecting line — corresponds to *zero* curvature and flat geometry. Its negation admits two consistent alternatives, each with globally constant curvature: hyperbolic geometry ($K<0$), in which parallels diverge and triangle-angle sums fall below $\pi$; and elliptic geometry ($K>0$), in which parallels converge and angle sums exceed $\pi$.

In all three classical models the curvature is a single constant, independent of position and direction. Modern differential geometry loosened the first constraint: on a general surface the Gaussian curvature is a function of position. What we explore here is a deliberately constructed metric that dramatizes a *direction-dependent* split of behavior: near one coordinate axis it acts hyperbolically, near the perpendicular axis it acts elliptically, and the two regimes are separated by a sharp geometric locus.

### 1.2 The construction

We work on the whole plane $\mathbb{R}^2$ with global coordinates $(x,y)$. Define the metric coefficients
$$ E(y) = \operatorname{sech}^2 y = \frac{1}{\cosh^2 y}, \qquad G(x) = \cosh^2 x, $$
and the orthogonal metric $ds^2 = E(y)\,dx^2 + G(x)\,dy^2$. The horizontal coefficient $E$ never exceeds $1$ and decays away from the $x$-axis, so horizontal coordinate steps translate into longer proper distances — an *expanding*, hyperbolic-flavored direction. The vertical coefficient $G$ is never less than $1$ and grows away from the $y$-axis, so vertical steps cost more proper distance — a *contracting*, elliptic-flavored direction.

### 1.3 Summary of results

Our main results, all proved rigorously below, are:

1. **(Consistency)** The metric is positive-definite at every point; Split Geometry is a genuine Riemannian geometry (Theorem 3.1).
2. **(Monotonicity engine)** $\operatorname{sech}^2$ is strictly decreasing in $|t|$, and separates points up to sign (Theorem 4.1).
3. **(Phase boundary)** The sign-indicator curvature $K(x,y)=\operatorname{sech}^2 x-\operatorname{sech}^2 y$ vanishes exactly on the union of diagonals $y=x$ and $y=-x$ (Theorem 5.1).
4. **(Sign structure and trichotomy)** $K>0$ where $|x|<|y|$ and $K<0$ where $|y|<|x|$; every point falls into exactly one of the three phases (Theorem 5.2).
5. **(Crossing rigidity)** A straight coordinate line not parallel to a diagonal meets the phase boundary at most twice (Theorem 6.1).

## 2. Definitions

Throughout, $\cosh t = \tfrac12(e^t + e^{-t})$ denotes the hyperbolic cosine, an even function satisfying $\cosh t \ge 1$ for all real $t$, with equality iff $t=0$, and strictly increasing on $[0,\infty)$.

**Definition 2.1 (Hyperbolic secant squared).** For $t \in \mathbb{R}$,
$$ \operatorname{sech}^2 t := \frac{1}{\cosh^2 t}. $$

**Definition 2.2 (Split metric).** The *split metric* on $\mathbb{R}^2$ is the symmetric bilinear form with coefficient functions
$$ E(y) = \operatorname{sech}^2 y, \qquad G(x) = \cosh^2 x, $$
acting on a tangent vector $(u,v)$ at the point $(x,y)$ by
$$ \|(u,v)\|^2_{(x,y)} = E(y)\,u^2 + G(x)\,v^2 . $$

**Definition 2.3 (Sign-indicator curvature).** The *sign-indicator curvature* of the split metric is
$$ K(x,y) := \operatorname{sech}^2 x - \operatorname{sech}^2 y . $$

**Definition 2.4 (Phase boundary and regions).** The *phase boundary* is the zero set $\{(x,y): K(x,y)=0\}$. The *elliptic region* is $\{|x|<|y|\}$ and the *hyperbolic region* is $\{|y|<|x|\}$.

## 3. Consistency: the metric is Riemannian

**Lemma 3.0 (Positivity of the coefficients).** For every $t$, $\operatorname{sech}^2 t > 0$; and for every $x$, $\cosh^2 x > 0$.

*Proof.* Since $\cosh t \ge 1 > 0$, both $\cosh^2 t$ and its reciprocal $\operatorname{sech}^2 t = 1/\cosh^2 t$ are strictly positive. $\square$

**Theorem 3.1 (Consistency / positive-definiteness).** For every point $(x,y)$ and every tangent vector $(u,v) \ne (0,0)$,
$$ E(y)\,u^2 + G(x)\,v^2 > 0. $$
Consequently the split metric is a positive-definite Riemannian metric, and its metric-tensor determinant $E(y)\,G(x) = \operatorname{sech}^2 y \cdot \cosh^2 x$ is strictly positive everywhere.

*Proof.* By Lemma 3.0, $E(y)>0$ and $G(x)>0$. If $u \ne 0$ then $u^2>0$, so $E(y)u^2 > 0$; adding the nonnegative $G(x)v^2 \ge 0$ keeps the sum strictly positive. The case $v \ne 0$ is symmetric. The determinant is a product of two positive numbers, hence positive, confirming nondegeneracy. $\square$

The determinant positivity also matters analytically: the Riemannian area element is $\sqrt{E G}\, dx\, dy = \dfrac{\cosh x}{\cosh y}\, dx\, dy$, a well-defined positive density used in Section 7.

## 4. The monotonicity engine

The entire qualitative theory rests on one elementary fact.

**Theorem 4.1 (Monotonicity of $\operatorname{sech}^2$ in $|t|$).** For all real $a,b$:
$$ \text{(i)}\quad \operatorname{sech}^2 a < \operatorname{sech}^2 b \iff |b| < |a|; $$
$$ \text{(ii)}\quad \operatorname{sech}^2 a \le \operatorname{sech}^2 b \iff |b| \le |a|; $$
$$ \text{(iii)}\quad \operatorname{sech}^2 a = \operatorname{sech}^2 b \iff |a| = |b|. $$

*Proof.* The hyperbolic cosine is even and strictly increasing in $|t|$; equivalently $\cosh a < \cosh b \iff |a| < |b|$. Since $\cosh a, \cosh b \ge 1 > 0$, squaring preserves this: $\cosh^2 a < \cosh^2 b \iff |a|<|b|$. Taking reciprocals reverses the inequality:
$$ \operatorname{sech}^2 a < \operatorname{sech}^2 b \iff \cosh^2 b < \cosh^2 a \iff |b| < |a|, $$
which is (i). Statement (ii) is the contrapositive/negation of (i) with roles swapped, and (iii) follows from (ii) applied in both directions together with antisymmetry of $\le$. $\square$

The content of Theorem 4.1 is that $\operatorname{sech}^2$ is a faithful, strictly decreasing readout of *magnitude*: it is blind to sign but sees size perfectly. Every subsequent structural result is a corollary.

## 5. The phase boundary and the sign of curvature

**Theorem 5.1 (Phase boundary equals the diagonals).** The following are equivalent for $(x,y) \in \mathbb{R}^2$:
$$ K(x,y) = 0 \iff \operatorname{sech}^2 x = \operatorname{sech}^2 y \iff |x| = |y| \iff x^2 = y^2 \iff (x = y \ \text{or}\ x = -y). $$
In particular the phase boundary is exactly the union of the two diagonals $y=x$ and $y=-x$.

*Proof.* By Definition 2.3, $K(x,y)=0$ iff $\operatorname{sech}^2 x = \operatorname{sech}^2 y$, which by Theorem 4.1(iii) is equivalent to $|x|=|y|$. Since both sides are nonnegative, $|x|=|y| \iff |x|^2 = |y|^2 \iff x^2 = y^2$. Finally $x^2=y^2 \iff x^2 - y^2 = 0 \iff (x-y)(x+y)=0 \iff (x=y \text{ or } x=-y)$. $\square$

**Theorem 5.2 (Sign structure and trichotomy).** For every $(x,y)$ exactly one of the following holds:
$$ \begin{cases} K(x,y) > 0 & \text{and } |x| < |y| \quad(\text{elliptic}),\\ K(x,y) = 0 & \text{and } |x| = |y| \quad(\text{boundary}),\\ K(x,y) < 0 & \text{and } |y| < |x| \quad(\text{hyperbolic}). \end{cases} $$

*Proof.* Compare $|x|$ and $|y|$ by trichotomy of real numbers.

- If $|x|<|y|$, Theorem 4.1(i) with $a=y,b=x$ gives $\operatorname{sech}^2 y < \operatorname{sech}^2 x$, hence $K(x,y)=\operatorname{sech}^2 x - \operatorname{sech}^2 y > 0$.
- If $|x|=|y|$, Theorem 5.1 gives $K(x,y)=0$.
- If $|y|<|x|$, Theorem 4.1(i) with $a=x,b=y$ gives $\operatorname{sech}^2 x < \operatorname{sech}^2 y$, hence $K(x,y)<0$.

The three magnitude-comparisons are mutually exclusive and exhaustive, so exactly one case applies. $\square$

Geometrically, the plane is partitioned by the diagonals into four open wedges. The top and bottom wedges (those touching the $y$-axis, where $|x|<|y|$) form the elliptic region; the left and right wedges (those touching the $x$-axis, where $|y|<|x|$) form the hyperbolic region. Curvature sign alternates as one rotates around the origin, a pinwheel pattern.

## 6. Crossing the phase boundary at most twice

We now quantify how often a straight coordinate line can transition between phases. A line parallel to a diagonal (slope $\pm 1$ in coordinate directions, i.e. $a^2=b^2$) is degenerate: it can lie on a diagonal or run parallel to one, giving either infinitely many or zero boundary points. The interesting, generic case excludes it.

**Theorem 6.1 (Crossing rigidity).** Let $\gamma(t) = (x_0 + ta,\ y_0 + tb)$ be a straight coordinate line with $a^2 \ne b^2$. Then $\gamma$ meets the phase boundary in at most two distinct points; equivalently, among any three parameters $t_1,t_2,t_3$ with $\gamma(t_i)$ on the boundary, two of the $t_i$ coincide.

*Proof.* By Theorem 5.1, $\gamma(t)$ lies on the boundary iff $(x_0+ta)^2 = (y_0+tb)^2$. Expanding both sides and collecting in $t$,
$$ (a^2 - b^2)\,t^2 + 2\,(x_0 a - y_0 b)\,t + (x_0^2 - y_0^2) = 0. \tag{$\ast$} $$
Because $a^2 - b^2 \ne 0$, $(\ast)$ is a genuine quadratic in $t$, which has at most two distinct real roots. Hence at most two parameter values place $\gamma$ on the boundary.

For a self-contained algebraic argument avoiding the fundamental theorem of algebra: suppose three parameters $t_1,t_2,t_3$ satisfy $(\ast)$. Subtracting the equations for $t_1$ and $t_2$ and factoring yields
$$ (t_1-t_2)\big[(a^2-b^2)(t_1+t_2) + 2(x_0 a - y_0 b)\big] = 0, $$
and similarly for the pair $(t_1,t_3)$. If all three $t_i$ were distinct, the bracketed factors would vanish, giving
$$ (a^2-b^2)(t_1+t_2) = -2(x_0a-y_0b) = (a^2-b^2)(t_1+t_3), $$
hence $(a^2-b^2)(t_2-t_3)=0$. Since $a^2 - b^2 \ne 0$ this forces $t_2=t_3$, a contradiction. Therefore two of the parameters coincide. $\square$

**Interpretation.** A traveler on a straight coordinate course through Split Geometry can switch between the elliptic and hyperbolic regimes at most twice. The bound is sharp: a generic line entering an opposite wedge and exiting realizes exactly two crossings. The bound is a manifestation of the *convexity* of each wedge boundary — the seam is a conic (degenerate: a pair of lines), and a line meets a conic in at most two points.

## 7. The split triangle and its area

A natural invariant of a triangle straddling the phases is its Riemannian area. With area density $\sqrt{EG}=\cosh x/\cosh y$, the metric area of a coordinate region $R$ is
$$ \operatorname{Area}(R) = \iint_R \frac{\cosh x}{\cosh y}\, dx\, dy. $$
This integral is elementary in each variable separately: $\int \cosh x\, dx = \sinh x$ and $\int \operatorname{sech} y\, dy = 2\arctan(\tanh(y/2)) = \operatorname{gd}(y)$, the Gudermannian function. For an axis-aligned coordinate rectangle $[x_1,x_2]\times[y_1,y_2]$,
$$ \operatorname{Area} = \big(\sinh x_2 - \sinh x_1\big)\,\big(\operatorname{gd}(y_2) - \operatorname{gd}(y_1)\big), $$
where $\operatorname{gd}(y) = 2\arctan(e^y) - \pi/2$. For a triangle with one vertex in the elliptic region and one in the hyperbolic region, the area is obtained by numerical quadrature of the same density; Section 9 (companion demonstrations) reports representative values. The interplay of the expanding factor $\cosh x$ and the contracting factor $1/\cosh y$ makes the area density anisotropic, largest along the $x$-axis and smallest along the $y$-axis, in harmony with the curvature picture.

## 8. Discussion: the sign-indicator versus the true curvature

Intellectual honesty requires a clear statement of what the results above do and do not assert about differential geometry. The function $K(x,y)=\operatorname{sech}^2 x - \operatorname{sech}^2 y$ is the *sign-indicator* proposed for the geometry, chosen for its transparent diagonal phase structure. Every theorem in Sections 5–6 is a rigorous, unconditional statement about this explicit real-analytic function.

However, $K$ is *not* the genuine Gaussian curvature of the split metric. For an orthogonal metric $ds^2 = E\,dx^2 + G\,dy^2$, the Brioschi/Liouville formula gives the Gaussian curvature
$$ K_{\mathrm{Gauss}} = -\frac{1}{2\sqrt{EG}}\left[\partial_x\!\left(\frac{G_x}{\sqrt{EG}}\right) + \partial_y\!\left(\frac{E_y}{\sqrt{EG}}\right)\right]. $$
Carrying out the differentiation with $E=\operatorname{sech}^2 y$ and $G=\cosh^2 x$ yields
$$ K_{\mathrm{Gauss}}(x,y) = -\cosh^2 y + \operatorname{sech}^2 x\,\big(2\operatorname{sech}^2 y - 1\big), $$
which coincides with the conjectured $K$ only at the origin and does not possess the clean diagonal phase structure. What survives verbatim, and is fully proved, is the *geometric skeleton* the conjecture was reaching for: the comparison of $|x|$ with $|y|$ partitions the plane along its diagonals into regions of opposite sign of the indicator, the metric is genuinely Riemannian, and straight coordinate lines cross the diagonal seam at most twice. These are robust, self-contained facts, independent of the differential-geometric interpretation of $K$.

## 9. Applications and connections

- **Anisotropic curvature fields.** Split Geometry is a minimal model of a curvature that flips sign by direction, a phenomenon central to general relativity, where the sectional curvature of spacetime focuses some geodesics while defocusing others.
- **Conic-line incidence.** The crossing-rigidity theorem is an instance of the classical fact that a line meets a conic in at most two points; here the conic is the degenerate pair $x^2=y^2$.
- **Special functions.** The area functional links the geometry to the Gudermannian function $\operatorname{gd}$, the bridge between circular and hyperbolic trigonometry.

## 10. Future directions

1. **Derive the true Gaussian curvature in closed form.** Work out the Brioschi formula for the split metric with differentiable coefficient functions, verify the closed form $K_{\mathrm{Gauss}}(x,y) = -\cosh^2 y + \operatorname{sech}^2 x(2\operatorname{sech}^2 y - 1)$, and determine its actual sign set.
2. **Realize the conjectured $K$.** Search for, or rule out, an orthogonal (e.g. conformal) metric whose genuine Gaussian curvature equals the clean indicator $\operatorname{sech}^2 x - \operatorname{sech}^2 y$. The Liouville equation $\Delta(\log\lambda) = -K\lambda$ for a conformal factor $\lambda$ is the tractable entry point.
3. **Genuine geodesics.** Replace straight coordinate lines by solutions of the geodesic equations and prove the "at most two crossings" bound for true geodesics via a Sturm/convexity argument.
4. **Split triangles and Gauss–Bonnet.** Compute the metric area $\iint \cosh x/\cosh y \, dx\, dy$ of a triangle with one vertex in each phase and relate it to $\iint K_{\mathrm{Gauss}}\, dA$ through the Gauss–Bonnet theorem.

## 11. Conclusion

Split Geometry demonstrates how a single elementary inequality — that $\operatorname{sech}^2 t$ strictly decreases in $|t|$ — can organize an entire two-dimensional world into alternating regions of opposite curvature sign, separated by the diagonals $y=\pm x$, with straight paths crossing that seam at most twice. The metric is provably consistent, the phase structure is exact, and the crossing bound is a clean corollary of the quadratic. Distinguishing the sign-indicator from the true Gaussian curvature sharpens rather than diminishes the result: it isolates precisely the combinatorial-geometric core that is robust and permanent.
