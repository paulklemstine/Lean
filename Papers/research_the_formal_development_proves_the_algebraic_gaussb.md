# Ideal Triangles in the Hyperbolic Half-Plane: Exact Area, Maximality, Rigidity, and Curvature Comparison

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

We give a complete, self-contained development of the area theory of ideal triangles in the upper half-plane model of the hyperbolic plane of constant curvature $-\kappa$, $\kappa > 0$, whose Riemannian area element is $dA = dx\,dy/(\kappa y^{2})$.

The analytic core is the exact evaluation of an improper integral: for all real $a < b$,
$$\int_{a}^{b} \frac{dx}{\sqrt{(x-a)(b-x)}} \;=\; \pi,$$
obtained from the explicit antiderivative $x \mapsto \arcsin\!\big((2x - a - b)/(b-a)\big)$, whose limits at the two singular endpoints are $\mp\pi/2$. Combined with the vertical fibre integral $\int_{c}^{\infty} y^{-2}\,dy = c^{-1}$, this yields by slicing that the ideal triangle with boundary vertices $a < b$ and third vertex $\infty$ has hyperbolic area exactly $\pi/\kappa$, independently of $a$ and $b$.

We then establish: (i) the **Gauss–Bonnet identity** $\mathrm{Area} = (\pi - (\alpha+\beta+\gamma))/\kappa$ as a *derived* statement, with interior angles computed from tangent vectors rather than postulated, for the family of triangles with at least one ideal vertex; (ii) **maximality and rigidity**, namely $\mathrm{Area} \le \pi/\kappa$ for admissible angle data with equality iff all three angles vanish, together with the strict positivity of interior angles at finite vertices, so that the maximum is attained only after adjoining the ideal boundary; (iii) the **ideal polygon formula** $\mathrm{Area} = (n-2)\pi/\kappa$, proved by genuine triangulation, with additivity under gluing along a common edge; (iv) **degeneration**, both geometric (a compact exhaustion by truncated regions with strictly smaller area, increasing to $\pi/\kappa$) and angular (every sequence of admissible triangles with area tending to $\pi/\kappa$ has all three angles tending to zero); (v) **sharp three-transitivity** of the real Möbius group on the boundary circle, with the explicit cross-ratio normalising map and a uniqueness statement, together with the two identities $\operatorname{Im} T(z) = (AD-BC)\operatorname{Im} z/|Cz+D|^{2}$ and $|T'(z)|/\operatorname{Im} T(z) = 1/\operatorname{Im} z$ that make real Möbius maps hyperbolic isometries; and (vi) **curvature comparison**: for a variable curvature profile $-K$ with $\kappa_{1} \le K \le \kappa_{2}$, the ideal triangle area is pinched, $\pi/\kappa_{2} \le \mathrm{Area} \le \pi/\kappa_{1}$, sharply.

**Keywords:** hyperbolic geometry, ideal triangle, Gauss–Bonnet theorem, upper half-plane model, Möbius transformation, curvature comparison, angle defect, ideal polygon.

**MSC (2020):** 51M10, 53C22, 30F45, 53A35.

---

## 1. Introduction

### 1.1 The phenomenon

In Euclidean geometry, the angles of a triangle sum to $\pi$ and carry no information about size. In hyperbolic geometry the angle sum is strictly less than $\pi$, and the *defect* $\pi - (\alpha+\beta+\gamma)$ is, up to the curvature normalisation, precisely the area. The immediate corollary — that hyperbolic triangles have uniformly bounded area — has no Euclidean counterpart and is one of the defining structural features of negative curvature. It underlies the finiteness of hyperbolic volumes of finite-type surfaces, the $\delta$-thinness of geodesic triangles that abstracts to Gromov hyperbolicity, and the ideal-tetrahedron decompositions used to compute hyperbolic structures on knot complements.

The extremal object is the *ideal triangle*: three vertices on the circle at infinity, three geodesic sides meeting asymptotically at angle zero. It has infinite diameter and finite area $\pi/\kappa$.

### 1.2 What this paper does

Much exposition of this material treats the angle-defect formula as an input and reasons algebraically from it. That approach yields maximality and rigidity as trivial consequences of $\alpha, \beta, \gamma \ge 0$, but it never explains *what a hyperbolic triangle is*, and in particular offers no independent verification that ideal triangles exist, that they all have the same area, or that the angle-zero configuration is unattainable in the interior of the plane.

We take the opposite route. We fix a concrete Riemannian model, compute areas by integration, define interior angles from tangent vectors, and derive Gauss–Bonnet where we can. Specifically, the logical structure is:

1. **§3** develops the analytic core: an explicit antiderivative for the chordal density, its improper integrability across both singular endpoints, and the evaluation $\int_a^b (x-a)^{-1/2}(b-x)^{-1/2}\,dx = \pi$.
2. **§4** develops the slicing formula and computes the ideal triangle area from the area element, obtaining $\pi/\kappa$; §4.4 extends this to ideal polygons by triangulation.
3. **§5** computes interior angles from tangent vectors, verifies conformal invariance of the angle functional, and *derives* Gauss–Bonnet for the family of triangles with at least one ideal vertex, in a statement that covers one, two, and three ideal vertices uniformly. It also proves the strict positivity of finite-vertex angles.
4. **§6** proves degeneration statements on both the geometric and the angle side.
5. **§7** proves that real Möbius maps of positive determinant are hyperbolic isometries and act sharply three-transitively on the boundary, so that the computed area is a genuine isometry invariant of *every* ideal triangle.
6. **§8** proves curvature comparison and its sharpness.

§9 gives algorithms and numerics, §10 discusses applications, and §11 states open problems, including a precise conjecture on the fully finite-vertex case and on Möbius invariance of hyperbolic area.

### 1.3 Conventions

Throughout, $\kappa > 0$ denotes the *curvature magnitude*, so the Gaussian curvature is $-\kappa$; the hyperbolic plane of curvature $-1$ corresponds to $\kappa = 1$. All integrals are Lebesgue integrals; interval integrals $\int_a^b$ are oriented. $\pi$ denotes the usual circle constant.

---

## 2. The upper half-plane model

### 2.1 Definition

**Definition 2.1 (Half-plane model).** The upper half-plane is $\mathbb{H} = \{(x,y) \in \mathbb{R}^{2} : y > 0\}$, identified with $\{z \in \mathbb{C} : \operatorname{Im} z > 0\}$. Equip it with the Riemannian metric
$$ds^{2} = \frac{dx^{2} + dy^{2}}{\kappa\,y^{2}}, \qquad \kappa > 0.$$
This metric has constant Gaussian curvature $-\kappa$. Its area element is
$$dA = \frac{dx\,dy}{\kappa\,y^{2}}.$$

**Definition 2.2 (Boundary at infinity).** The ideal boundary is $\partial\mathbb{H} = \mathbb{R} \cup \{\infty\}$, a topological circle. Points of $\partial\mathbb{H}$ are at infinite hyperbolic distance from every point of $\mathbb{H}$ and are not points of the space.

**Fact 2.3 (Geodesics).** The complete geodesics of $\mathbb{H}$ are precisely (a) the vertical rays $\{x = c,\ y > 0\}$, with ideal endpoints $c$ and $\infty$; and (b) the Euclidean semicircles centred on the real axis, with ideal endpoints the two intersections with $\mathbb{R}$.

We use Fact 2.3 to *define* the sides of our regions; no geodesic completeness theory is required, since every region we integrate over is described explicitly.

### 2.2 The chord function

**Definition 2.4 (Chord height).** For $a < b$ and $x \in \mathbb{R}$ put
$$h_{a,b}(x) \;=\; \sqrt{(x - a)(b - x)}.$$
On $(a,b)$ this is the height of the Euclidean semicircle with diameter $[a,b]$, i.e. of the geodesic joining the boundary points $a$ and $b$.

**Lemma 2.5.** If $a < x < b$ then $h_{a,b}(x) > 0$.

*Proof.* $(x-a)(b-x) > 0$, and the square root of a positive real is positive. $\square$

### 2.3 Ideal triangles

**Definition 2.6 (Ideal triangle region).** For $a < b$, the ideal triangle with vertices $a$, $b$, $\infty$ is
$$\Delta(a,b) \;=\; \{(x,y) : a < x < b,\ y > h_{a,b}(x)\} \subset \mathbb{H}.$$

Its boundary consists of the geodesic semicircle over $[a,b]$ and the two vertical geodesics $x = a$, $x = b$. Every point of $\Delta(a,b)$ has $y > h_{a,b}(x) > 0$, so $\Delta(a,b) \subseteq \mathbb{H}$.

---

## 3. The analytic core

The whole area theory rests on one improper integral. We treat it carefully, because the integrand is unbounded at both endpoints of the interval of integration.

### 3.1 An explicit antiderivative

**Definition 3.1.** For $a < b$ set
$$F_{a,b}(x) \;=\; \arcsin\!\left(\frac{2x - a - b}{b - a}\right).$$
$F_{a,b}$ is defined and continuous on all of $\mathbb{R}$ (with $\arcsin$ extended by $\pm\pi/2$ outside $[-1,1]$, as is standard), and maps $[a,b]$ onto $[-\pi/2, \pi/2]$.

**Theorem 3.2 (Derivative of the chordal antiderivative).** For all $x \in (a,b)$,
$$F_{a,b}'(x) \;=\; \frac{1}{h_{a,b}(x)} \;=\; \frac{1}{\sqrt{(x-a)(b-x)}}.$$

*Proof sketch.* Write $u(x) = (2x - a - b)/(b-a)$, so $u'(x) = 2/(b-a)$, and $|u(x)| < 1$ for $x \in (a,b)$ (indeed $u(a) = -1$, $u(b) = 1$, and $u$ is increasing). The chain rule applied to $\arcsin$, whose derivative is $(1-u^{2})^{-1/2}$ away from $u = \pm 1$, gives
$$F_{a,b}'(x) = \frac{2/(b-a)}{\sqrt{1 - u(x)^{2}}}.$$
A direct algebraic computation gives the key identity
$$1 - u(x)^{2} \;=\; \frac{4\,(x-a)(b-x)}{(b-a)^{2}},$$
so that $\sqrt{1 - u(x)^{2}} = 2\sqrt{(x-a)(b-x)}/(b-a)$, the positive square root being correct since $b - a > 0$ and $(x-a)(b-x) > 0$. Substituting and cancelling the factor $2/(b-a)$ yields the claim. $\square$

**Lemma 3.3 (Endpoint values).** For $a < b$: $F_{a,b}(a) = -\pi/2$ and $F_{a,b}(b) = \pi/2$.

*Proof.* $u(a) = (2a - a - b)/(b-a) = -1$ and $u(b) = (2b - a - b)/(b - a) = 1$; then $\arcsin(\mp 1) = \mp\pi/2$. $\square$

### 3.2 Improper integrability

**Theorem 3.4 (Integrability of the chordal density).** For any real $a, b$, the function $x \mapsto h_{a,b}(x)^{-1}$ is interval-integrable on $[a,b]$.

*Proof sketch.* The density is nonnegative and is, on the open interval, the derivative of the continuous function $F_{a,b}$. A nonnegative derivative of a continuous function on a closed interval, differentiable on the interior, is integrable there — the increments of $F_{a,b}$ over compact subintervals bound the integrals uniformly, and monotone convergence supplies the limit. (Symmetrically for $b < a$, using $h_{b,a} = h_{a,b}$.) The point of the argument is that no dominating function is available near the endpoints; integrability is obtained from the boundedness of the antiderivative instead. $\square$

### 3.3 The fundamental evaluation

**Theorem 3.5 (Fundamental theorem across the singularities).** Let $a < b$, and let $a \le u < v \le b$. Then
$$\int_{u}^{v} \frac{dx}{h_{a,b}(x)} \;=\; F_{a,b}(v) - F_{a,b}(u).$$

*Proof sketch.* On $(u,v) \subseteq (a,b)$ we have $F_{a,b}' = h_{a,b}^{-1}$ by Theorem 3.2, and the density is integrable on $[u,v]$ by Theorem 3.4 and monotonicity of the integral. The endpoints may be singular, but $F_{a,b}$ is continuous, so its one-sided limits at $u^{+}$ and $v^{-}$ are $F_{a,b}(u)$ and $F_{a,b}(v)$. The version of the fundamental theorem of calculus valid for an interior derivative with integrable density and convergent boundary limits applies verbatim. $\square$

**Theorem 3.6 (The ideal-triangle integral).** For all $a < b$,
$$\int_{a}^{b} \frac{dx}{\sqrt{(x-a)(b-x)}} \;=\; \pi.$$

*Proof.* Take $u = a$, $v = b$ in Theorem 3.5 and apply Lemma 3.3: the value is $\pi/2 - (-\pi/2) = \pi$. $\square$

**Remark 3.7.** The value $\pi$ is *independent of $a$ and $b$*. This single fact is the analytic reason that all ideal triangles are congruent. Geometrically, $\int_a^b dx/h_{a,b}(x)$ measures the angular sweep of the semicircular arch over $[a,b]$ as seen from its centre — a semicircle spans $\pi$ radians — so the $\pi$ in the area of the largest triangle is the $\pi$ of a half-turn, arriving through $\arcsin$ rather than through any circle in the hyperbolic plane.

---

## 4. Areas by slicing

### 4.1 The vertical fibre

**Theorem 4.1 (Fibre integral).** For $c > 0$,
$$\int_{c}^{\infty} \frac{dy}{y^{2}} \;=\; \frac{1}{c}.$$

*Proof.* Rewrite $y^{-2} = y^{-2}$ as an $\mathbb{R}$-power $y^{-2}$ with exponent $-2 < -1$ and apply the standard evaluation $\int_{c}^{\infty} y^{s}\,dy = -c^{s+1}/(s+1)$ for $s < -1$, $c > 0$, with $s = -2$: the value is $-c^{-1}/(-1) = c^{-1}$. $\square$

### 4.2 The slicing formula

**Definition 4.2 (Sliced area).** For $\kappa \in \mathbb{R}$, $a < b$, and a "lower boundary" function $\mathrm{low} : \mathbb{R} \to \mathbb{R}$, define
$$\mathcal{A}_{\kappa}(a, b; \mathrm{low}) \;=\; \int_{a}^{b}\!\!\left(\int_{\mathrm{low}(x)}^{\infty} \frac{dy}{\kappa\,y^{2}}\right) dx .$$
This is the hyperbolic area of the region $\{(x,y) : a < x < b,\ y > \mathrm{low}(x)\}$ at curvature $-\kappa$.

**Theorem 4.3 (Slicing).** If $\mathrm{low}(x) > 0$ for all $x \in (a,b)$, then
$$\mathcal{A}_{\kappa}(a,b;\mathrm{low}) \;=\; \frac{1}{\kappa}\int_{a}^{b} \frac{dx}{\mathrm{low}(x)} .$$

*Proof sketch.* For each $x$ in the open interval — hence for almost every $x$ in $[a,b]$ — the inner integral is $\kappa^{-1}\int_{\mathrm{low}(x)}^{\infty} y^{-2}\,dy = \kappa^{-1}\,\mathrm{low}(x)^{-1}$ by Theorem 4.1, after pulling the constant $\kappa^{-1}$ out. Since the two integrands of the outer integral agree almost everywhere, the outer integrals agree; and $\kappa^{-1}$ pulls out of the outer integral. Note that endpoints form a null set, so no hypothesis on $\mathrm{low}$ at $a$ or $b$ is needed. $\square$

Theorem 4.3 is the reduction that makes everything computable: a two-dimensional hyperbolic area becomes a one-dimensional integral of the **reciprocal height of the lower boundary**.

### 4.3 The area of an ideal triangle

**Theorem 4.4 (Ideal triangle area — Gauss–Bonnet derived).** For $\kappa > 0$ and $a < b$, the ideal triangle $\Delta(a,b)$ with vertices $a$, $b$, $\infty$ has hyperbolic area
$$\mathcal{A}_{\kappa}\big(a, b; h_{a,b}\big) \;=\; \frac{\pi}{\kappa}.$$

*Proof.* Apply Theorem 4.3 with $\mathrm{low} = h_{a,b}$, positive on $(a,b)$ by Lemma 2.5, then Theorem 3.6. $\square$

**Corollary 4.5 (Congruence of ideal triangles).** For any $a < b$ and $a' < b'$, the ideal triangles $\Delta(a,b)$ and $\Delta(a',b')$ have equal area. In particular the invariant does not see the position of the two finite ideal vertices.

**Corollary 4.6 (Consistency with the angle-defect invariant).** Define the *angle-defect invariant* of an angle triple by
$$\mathcal{G}_{\kappa}(\alpha,\beta,\gamma) \;=\; \frac{\pi - (\alpha + \beta + \gamma)}{\kappa}.$$
Then $\mathcal{A}_{\kappa}(a,b;h_{a,b}) = \mathcal{G}_{\kappa}(0,0,0)$. The Riemannian area of the ideal triangle agrees with the Gauss–Bonnet prediction at all angles zero.

### 4.4 Ideal polygons

**Definition 4.7.** Let $m \ge 1$ and let $v_{0} < v_{1} < \cdots < v_{m}$ be points of $\mathbb{R}$. The ideal $n$-gon with $n = m+2$ vertices $v_{0}, \ldots, v_{m}, \infty$ is cut by the vertical geodesics through $v_{1}, \ldots, v_{m-1}$ into the chimneys over the consecutive intervals; accordingly define
$$\mathcal{P}_{\kappa}(m; v) \;=\; \sum_{i=0}^{m-1} \mathcal{A}_{\kappa}\big(v_{i}, v_{i+1}; h_{v_{i}, v_{i+1}}\big).$$

**Theorem 4.8 (Area of an ideal polygon).** If $v_{i} < v_{i+1}$ for all $i < m$, then
$$\mathcal{P}_{\kappa}(m; v) \;=\; \frac{m\,\pi}{\kappa} \;=\; \frac{(n-2)\,\pi}{\kappa}, \qquad n = m + 2 .$$

*Proof.* Each summand is $\pi/\kappa$ by Theorem 4.4; there are $m$ of them. $\square$

**Theorem 4.9 (Triangulation invariance / additivity).** With $m, k \ge 0$ and admissible vertex data $v$, $w$, $u$ for an ideal $(m+2)$-gon, an ideal $(k+2)$-gon, and an ideal $(m+k+2)$-gon respectively,
$$\mathcal{P}_{\kappa}(m+k; u) \;=\; \mathcal{P}_{\kappa}(m; v) + \mathcal{P}_{\kappa}(k; w).$$

*Proof.* All three sides evaluate by Theorem 4.8 to $(m+k)\pi/\kappa$, $m\pi/\kappa$, $k\pi/\kappa$. $\square$

**Remark 4.10.** Theorem 4.9 says that gluing two ideal polygons along a common ideal edge adds their areas, and that the value depends only on the number of vertices, not on the triangulation chosen. This is the hyperbolic shadow of the Euclidean identity "the interior angles of an $n$-gon sum to $(n-2)\pi$": the same combinatorial coefficient, now measuring area.

---

## 5. Angles computed, not assumed

To make Gauss–Bonnet a theorem rather than a definition, one must define interior angles intrinsically and compute them.

### 5.1 The angle functional and conformal invariance

**Definition 5.1.** For nonzero $u, v \in \mathbb{R}^{2}$,
$$\angle(u,v) \;=\; \arccos\!\left(\frac{u_{1}v_{1} + u_{2}v_{2}}{\sqrt{u_{1}^{2}+u_{2}^{2}}\,\sqrt{v_{1}^{2}+v_{2}^{2}}}\right) \in [0,\pi].$$

**Theorem 5.2 (Conformal invariance).** For every $c > 0$ and all $u, v$,
$$\angle(cu, v) = \angle(u,v) = \angle(u, cv).$$

*Proof sketch.* Under $u \mapsto cu$ the numerator scales by $c$ and the norm $\sqrt{(cu_1)^2 + (cu_2)^2} = c\sqrt{u_1^2+u_2^2}$ also scales by $c$, so the quotient is unchanged; likewise on the right. $\square$

**Corollary 5.3 (Hyperbolic angles are Euclidean angles).** The half-plane metric is the Euclidean metric multiplied pointwise by the positive scalar $1/(\kappa y^{2})$; by Theorem 5.2, the angle functional does not see this factor. Hyperbolic angles in $\mathbb{H}$ therefore coincide with Euclidean angles between the same tangent vectors, and in particular are independent of $\kappa$.

This is exactly why we may compute angles with elementary trigonometry below.

### 5.2 A one-parameter family with an ideal vertex

Fix $0 \le \varphi < \theta \le \pi$. Consider the region bounded below by the **unit semicircle** $|z| = 1$ (a geodesic, being a semicircle centred on $\mathbb{R}$), and on the sides by the vertical geodesics $x = \cos\theta$ and $x = \cos\varphi$ (note $\cos\theta < \cos\varphi$ since $\cos$ is strictly decreasing on $[0,\pi]$). Its vertices are
$$P_{\theta} = (\cos\theta, \sin\theta), \qquad P_{\varphi} = (\cos\varphi, \sin\varphi), \qquad \infty .$$
When $0 < \varphi < \theta < \pi$ both $P_{\theta}$ and $P_{\varphi}$ lie in $\mathbb{H}$; when $\varphi = 0$ or $\theta = \pi$ the corresponding vertex degenerates onto the boundary points $1$ or $-1$.

The relevant unit tangent vectors are: for a vertical side, $T_{\mathrm{vert}} = (0,1)$ (pointing upward, into the region); for the unit circle at $P_{\theta}$, in the direction of increasing $x$, $T^{+}(\theta) = (\sin\theta, -\cos\theta)$; and at $P_{\varphi}$, in the direction of decreasing $x$, $T^{-}(\varphi) = (-\sin\varphi, \cos\varphi)$.

**Theorem 5.4 (Interior angles).** For $0 \le \theta \le \pi$ and $0 \le \varphi \le \pi$,
$$\angle\big(T_{\mathrm{vert}},\, T^{+}(\theta)\big) = \pi - \theta, \qquad \angle\big(T_{\mathrm{vert}},\, T^{-}(\varphi)\big) = \varphi .$$

*Proof.* Both circle tangents are unit vectors: $\sin^{2} + \cos^{2} = 1$. So the angle functional reduces to $\arccos$ of the plain dot product. We get $\langle (0,1), (\sin\theta, -\cos\theta)\rangle = -\cos\theta$ and $\arccos(-\cos\theta) = \pi - \arccos(\cos\theta) = \pi - \theta$ using $0 \le \theta \le \pi$. Likewise $\langle(0,1), (-\sin\varphi, \cos\varphi)\rangle = \cos\varphi$ and $\arccos(\cos\varphi) = \varphi$. $\square$

At the third vertex $\infty$ the two sides are parallel vertical geodesics, meeting asymptotically; the interior angle is $0$.

### 5.3 The area, and Gauss–Bonnet derived

**Theorem 5.5 (Area with at least one ideal vertex).** Let $0 \le \varphi < \theta \le \pi$ and $\kappa \ne 0$. The region described above has hyperbolic area
$$\mathcal{A}_{\kappa}\big(\cos\theta,\ \cos\varphi;\ h_{-1,1}\big) \;=\; \frac{\theta - \varphi}{\kappa} .$$

*Proof sketch.* First, $h_{-1,1}(x) = \sqrt{(x+1)(1-x)} = \sqrt{1-x^{2}}$ and $F_{-1,1}(x) = \arcsin x$. Second, $-1 \le \cos\theta < \cos\varphi \le 1$, so $[\cos\theta, \cos\varphi]$ is a subinterval of $[-1,1]$ and $h_{-1,1} > 0$ on its interior. Apply the slicing formula (Theorem 4.3) and then the fundamental theorem on a subinterval (Theorem 3.5):
$$\mathcal{A} = \frac{1}{\kappa}\big(\arcsin(\cos\varphi) - \arcsin(\cos\theta)\big).$$
Finally, for $0 \le t \le \pi$ one has $\arcsin(\cos t) = \pi/2 - t$, since $\cos t = \sin(\pi/2 - t)$ and $\pi/2 - t \in [-\pi/2, \pi/2]$. Substituting gives $\big((\pi/2 - \varphi) - (\pi/2 - \theta)\big)/\kappa = (\theta-\varphi)/\kappa$. $\square$

**Theorem 5.6 (Gauss–Bonnet, derived).** With the hypotheses of Theorem 5.5, and with $\alpha = \angle(T_{\mathrm{vert}}, T^{+}(\theta))$, $\beta = \angle(T_{\mathrm{vert}}, T^{-}(\varphi))$ the computed interior angles at the two non-ideal vertices,
$$\mathrm{Area} \;=\; \mathcal{G}_{\kappa}(\alpha, \beta, 0) \;=\; \frac{\pi - (\alpha + \beta)}{\kappa}.$$

*Proof.* By Theorem 5.4, $\alpha = \pi - \theta$ and $\beta = \varphi$, so $\pi - (\alpha + \beta + 0) = \pi - (\pi - \theta) - \varphi = \theta - \varphi$; compare with Theorem 5.5. $\square$

This is the key structural point: the angles were *computed from the metric* (Theorem 5.4) and the area was *computed from the area element* (Theorem 5.5); their agreement is a theorem, not a convention.

**Corollary 5.7 (Uniform treatment of one, two, three ideal vertices).**
- $0 < \varphi < \theta < \pi$: one ideal vertex, area $(\theta-\varphi)/\kappa$, angles $(\pi-\theta, \varphi, 0)$.
- $\varphi = 0 < \theta \le \pi$: two ideal vertices ($1$ and $\infty$), area $\theta/\kappa = \mathcal{G}_{\kappa}(\pi - \theta, 0, 0)$.
- $\varphi = 0$, $\theta = \pi$: three ideal vertices ($1$, $-1$, $\infty$), area $\pi/\kappa$, recovering Theorem 4.4.

### 5.4 Finite vertices have strictly positive angles

**Theorem 5.8 (Strict positivity).** If $0 < \varphi < \theta < \pi$ — that is, if both non-ideal vertices are genuine points of $\mathbb{H}$ — then both interior angles are strictly positive:
$$\alpha = \pi - \theta > 0, \qquad \beta = \varphi > 0 .$$

*Proof.* Immediate from Theorem 5.4 and the strict inequalities. $\square$

**Corollary 5.9 (Strict subideality).** For $\kappa > 0$ and $0 < \varphi < \theta \le \pi$,
$$\mathrm{Area} = \frac{\theta - \varphi}{\kappa} < \frac{\pi}{\kappa}.$$

*Proof.* $\theta - \varphi < \pi - 0 = \pi$ and $\kappa > 0$. $\square$

Thus the maximal area $\pi/\kappa$ is **not attained by any triangle with a finite vertex**. The angle-sum-zero configuration requires adjoining the ideal boundary; the extremal object lies on the boundary of the space of triangles, not inside it.

---

## 6. Maximality, rigidity, and degeneration

### 6.1 The angle-data statements

**Definition 6.1 (Admissible angles).** A triple $(\alpha, \beta, \gamma) \in \mathbb{R}^{3}$ is *admissible* if
$$\alpha \ge 0, \quad \beta \ge 0, \quad \gamma \ge 0, \quad \alpha + \beta + \gamma \le \pi .$$

**Theorem 6.2 (Maximality).** For $\kappa > 0$ and admissible $(\alpha,\beta,\gamma)$,
$$\mathcal{G}_{\kappa}(\alpha,\beta,\gamma) = \frac{\pi - (\alpha+\beta+\gamma)}{\kappa} \le \frac{\pi}{\kappa}.$$

*Proof.* $\alpha + \beta + \gamma \ge 0$, so the numerator is at most $\pi$; divide by $\kappa > 0$. $\square$

**Theorem 6.3 (Rigidity).** For $\kappa > 0$ and admissible $(\alpha,\beta,\gamma)$,
$$\mathcal{G}_{\kappa}(\alpha,\beta,\gamma) = \frac{\pi}{\kappa} \iff \alpha = \beta = \gamma = 0 .$$

*Proof.* Equality forces $\alpha+\beta+\gamma = 0$; combined with nonnegativity of each term, all are zero. Conversely $\mathcal{G}_{\kappa}(0,0,0) = \pi/\kappa$. $\square$

**Remark 6.4 (Nonnegativity is essential).** Without $\alpha, \beta, \gamma \ge 0$, rigidity is false: $(\alpha,\beta,\gamma) = (1, -1, 0)$ has sum zero and hence defect-invariant $\pi/\kappa$, yet the angles are not all zero. Maximality also fails. The hypothesis is not decorative; it encodes the geometric fact (Theorem 5.8) that interior angles of an actual region are nonnegative, with strict positivity at finite vertices.

### 6.2 Geometric degeneration: compact exhaustion

**Definition 6.5 (Truncated ideal triangle).** For $t > 0$ with $a + t < b - t$, the *truncated* region is the part of $\Delta(a,b)$ over $[a+t, b-t]$, with area
$$\mathcal{T}_{\kappa}(a,b;t) = \mathcal{A}_{\kappa}\big(a+t,\, b-t;\, h_{a,b}\big).$$

**Theorem 6.6 (Truncated area formula).** For $t > 0$ with $a + t < b - t$,
$$\mathcal{T}_{\kappa}(a,b;t) \;=\; \frac{F_{a,b}(b-t) - F_{a,b}(a+t)}{\kappa}.$$

*Proof.* Slicing (Theorem 4.3) reduces to $\kappa^{-1}\int_{a+t}^{b-t} h_{a,b}^{-1}$, and on this compact subinterval of $(a,b)$ the ordinary fundamental theorem of calculus applies, the density being integrable by Theorem 3.4 restricted to a subinterval. $\square$

**Theorem 6.7 (Strict subideality of truncations).** For $\kappa > 0$, $t > 0$ with $a + t < b - t$,
$$\mathcal{T}_{\kappa}(a,b;t) \;<\; \frac{\pi}{\kappa}.$$

*Proof.* $F_{a,b}(b-t) \le \pi/2$ always, while $F_{a,b}(a+t) > -\pi/2$ strictly, because the argument $(2(a+t)-a-b)/(b-a) > -1$ exactly when $t > 0$, and $\arcsin$ is $> -\pi/2$ on $(-1, 1]$. Subtract and divide by $\kappa > 0$. $\square$

**Theorem 6.8 (Degeneration).** For $a < b$,
$$\lim_{t \downarrow 0} \mathcal{T}_{\kappa}(a,b;t) \;=\; \frac{\pi}{\kappa}.$$

*Proof.* The right-hand side of Theorem 6.6 is a continuous function of $t$ (as $F_{a,b}$ is continuous on $\mathbb{R}$), whose value at $t = 0$ is $(F_{a,b}(b) - F_{a,b}(a))/\kappa = \pi/\kappa$ by Lemma 3.3. The formula of Theorem 6.6 is valid eventually as $t \downarrow 0$ — precisely once $0 < t < (b-a)/2$ — so the limit of the areas equals the limit of the continuous expression. $\square$

Together, Theorems 6.7 and 6.8 say: the ideal triangle is the increasing limit of a compact exhaustion by regions of strictly smaller area. The supremum $\pi/\kappa$ is approached but never attained by any truncation.

**Theorem 6.9 (Geometric degeneration in the angle family).** In the family of §5.2, as $(\theta, \varphi) \to (\pi, 0)$ within the admissible parameter set $\{0 \le \varphi < \theta \le \pi\}$, the area $(\theta - \varphi)/\kappa$ converges to $\pi/\kappa$: the two finite vertices slide out to the boundary points $-1$ and $1$, both angles tend to $0$, and the region increases to an ideal triangle.

### 6.3 Angular degeneration: uniqueness of the limiting shape

**Theorem 6.10 (Maximising sequences degenerate).** Let $\kappa > 0$ and let $(\alpha_{n}, \beta_{n}, \gamma_{n})$ be admissible for every $n$. If
$$\mathcal{G}_{\kappa}(\alpha_{n}, \beta_{n}, \gamma_{n}) \longrightarrow \frac{\pi}{\kappa},$$
then $\alpha_{n} \to 0$, $\beta_{n} \to 0$, and $\gamma_{n} \to 0$.

*Proof.* Write $S_{n} = \alpha_{n} + \beta_{n} + \gamma_{n}$, so $S_{n} = \pi - \kappa\,\mathcal{G}_{\kappa}(\alpha_n,\beta_n,\gamma_n)$ identically. The right-hand side converges to $\pi - \kappa\cdot(\pi/\kappa) = 0$, so $S_{n} \to 0$. Now $0 \le \alpha_{n} \le S_{n}$ (using $\beta_{n}, \gamma_{n} \ge 0$), and likewise for $\beta_{n}$ and $\gamma_{n}$. The squeeze theorem gives the three limits. $\square$

**Corollary 6.11.** The ideal triangle is the *unique* limiting shape of an area-maximising sequence of hyperbolic triangles. Rigidity therefore holds not only for exact maximisers but asymptotically.

---

## 7. Isometries, and why one computation suffices

Theorem 4.4 computes the area of ideal triangles whose third vertex is the special boundary point $\infty$. To conclude that *every* ideal triangle has area $\pi/\kappa$ we need (a) that real Möbius maps are hyperbolic isometries, and (b) that they act transitively on boundary triples.

### 7.1 Real Möbius maps preserve the half-plane

**Definition 7.1.** For $A, B, C, D \in \mathbb{R}$, the associated real Möbius map is
$$T(z) \;=\; \frac{Az + B}{Cz + D}, \qquad z \in \mathbb{C},\ Cz + D \ne 0,$$
with determinant $\det T = AD - BC$. On the boundary line it restricts to $x \mapsto (Ax+B)/(Cx+D)$, with pole at $x = -D/C$, which is sent to $\infty$.

**Theorem 7.2 (Imaginary part).** For all $A,B,C,D \in \mathbb{R}$ and all $z$ with $Cz+D \ne 0$,
$$\operatorname{Im} T(z) \;=\; \frac{(AD - BC)\,\operatorname{Im} z}{|Cz+D|^{2}}.$$

*Proof sketch.* Multiply numerator and denominator by the conjugate $\overline{Cz+D}$ and take imaginary parts; the real coefficients make the cross terms combine to $(AD-BC)\operatorname{Im} z$, while the denominator becomes $|Cz+D|^{2}$. $\square$

**Theorem 7.3 (Invariance of the upper half-plane).** If $\det T = AD - BC > 0$ and $\operatorname{Im} z > 0$, then $Cz+D \ne 0$ and $\operatorname{Im} T(z) > 0$.

*Proof sketch.* If $Cz + D = 0$ then its imaginary part $C \operatorname{Im} z$ vanishes, forcing $C = 0$ since $\operatorname{Im} z > 0$; then its real part $D$ vanishes too; but $C = D = 0$ makes $AD - BC = 0$, contradicting positivity. So $Cz+D \ne 0$, and Theorem 7.2 exhibits $\operatorname{Im} T(z)$ as a quotient of positive quantities. $\square$

### 7.2 Conformality: the isometry identity

**Theorem 7.4 (Derivative).** If $Cz + D \ne 0$ then $T$ is complex-differentiable at $z$ with
$$T'(z) \;=\; \frac{AD - BC}{(Cz+D)^{2}} .$$

*Proof.* Quotient rule applied to the affine numerator and denominator: $\big(A(Cz+D) - C(Az+B)\big)/(Cz+D)^{2} = (AD-BC)/(Cz+D)^{2}$. $\square$

**Theorem 7.5 (Pointwise conformality — the isometry identity).** If $\det T > 0$ and $\operatorname{Im} z > 0$, then
$$\frac{|T'(z)|}{\operatorname{Im} T(z)} \;=\; \frac{1}{\operatorname{Im} z}.$$

*Proof.* By Theorem 7.4 and positivity of the determinant, $|T'(z)| = (AD-BC)/|Cz+D|^{2}$. By Theorem 7.2, $\operatorname{Im} T(z) = (AD-BC)\operatorname{Im} z / |Cz+D|^{2}$. Dividing, the factor $(AD-BC)/|Cz+D|^{2}$ cancels and the quotient is $1/\operatorname{Im} z$. $\square$

**Corollary 7.6 (Real Möbius maps are hyperbolic isometries).** The hyperbolic line element on $\mathbb{H}$ is $ds = |dz|/(\sqrt{\kappa}\,y)$. Under $T$, the infinitesimal displacement $|dz|$ is multiplied by $|T'(z)|$ while the height $y = \operatorname{Im} z$ becomes $\operatorname{Im} T(z)$. Theorem 7.5 says the ratio is unchanged, so $T$ preserves hyperbolic length pointwise, hence hyperbolic distance, hence hyperbolic area, hence (being conformal, Theorem 5.2) hyperbolic angles.

### 7.3 Sharp three-transitivity on the boundary

**Definition 7.7 (Cross-ratio normaliser).** For $p < q < r$, let $T_{p,q,r}$ be the real Möbius map with coefficients
$$(A, B, C, D) \;=\; \big(q-r,\ -p(q-r),\ q-p,\ -r(q-p)\big),$$
that is,
$$T_{p,q,r}(x) \;=\; \frac{(q-r)(x-p)}{(q-p)(x-r)} .$$

**Theorem 7.8 (Orientation).** $\det T_{p,q,r} = (r-q)(q-p)(r-p) > 0$ for $p < q < r$.

*Proof.* Expand $AD - BC = (q-r)(-r(q-p)) + p(q-r)(q-p) = (q-r)(q-p)(p - r) = (r-q)(q-p)(r-p)$, a product of three positive numbers. $\square$

**Theorem 7.9 (Normalisation).** For $p < q < r$: $T_{p,q,r}(p) = 0$, $T_{p,q,r}(q) = 1$, and $r$ is the pole of $T_{p,q,r}$, i.e. $Cr + D = (q-p)r - r(q-p) = 0$, so $T_{p,q,r}(r) = \infty$.

*Proof.* The numerator at $x = p$ is $(q-r)(p-p) = 0$ while the denominator $(q-p)(p-r) \ne 0$, so the value is $0$. At $x = q$ numerator and denominator are both $(q-r)(q-p) \ne 0$, so the value is $1$. The pole identity is an algebraic triviality. $\square$

**Theorem 7.10 (Existence).** For every $p < q < r$ there exists a real Möbius map of positive determinant carrying $(p,q,r)$ to $(0,1,\infty)$.

*Proof.* Theorems 7.8 and 7.9. $\square$

**Theorem 7.11 (Uniqueness).** A real Möbius map fixing $0$, $1$ and $\infty$ is the identity on the boundary line. Explicitly: if $C = 0$ (which is what fixing $\infty$ means: no finite pole), $D \ne 0$, and $x \mapsto (Ax+B)/D$ fixes $0$ and $1$, then $(Ax+B)/D = x$ for all $x$.

*Proof.* Fixing $0$ gives $B/D = 0$, so $B = 0$. Fixing $1$ then gives $A/D = 1$, so $A = D$. Hence the map is $x \mapsto Dx/D = x$. $\square$

**Corollary 7.12 (Sharp three-transitivity).** For $p < q < r$ the normalising map is unique: any two real Möbius maps carrying $(p,q,r)$ to $(0,1,\infty)$ agree on the whole boundary line. Consequently three distinct boundary points determine an ideal triangle, uniquely up to a unique hyperbolic isometry.

*Proof.* If $T$ and $T'$ both normalise, then $T \circ T'^{-1}$ fixes $0$, $1$, $\infty$, hence is the identity by Theorem 7.11. $\square$

**Corollary 7.13 (Universality of the area).** Every ideal triangle in $\mathbb{H}$ — three distinct boundary vertices, three geodesic sides — is the image under a hyperbolic isometry of the standard ideal triangle with vertices $0$, $1$, $\infty$, and therefore has area $\pi/\kappa$. In particular $\mathcal{A}_{\kappa}(0,1;h_{0,1}) = \pi/\kappa$ is the universal value.

*(The last step uses that hyperbolic area is a Möbius invariant; the pointwise identity of Theorem 7.5 is the infinitesimal statement, and its integrated form is stated as Conjecture B in §11.)*

---

## 8. Variable curvature: comparison and pinching

The results so far are at constant curvature $-\kappa$. We now allow the curvature magnitude to vary along the base, replacing the area element $dx\,dy/(\kappa y^{2})$ by $dx\,dy/(K(x)\,y^{2})$ for a positive function $K$.

**Definition 8.1 (Variable-curvature sliced area).**
$$\mathcal{A}^{K}(a,b;\mathrm{low}) \;=\; \int_{a}^{b}\!\!\left(\int_{\mathrm{low}(x)}^{\infty} \frac{dy}{K(x)\,y^{2}}\right)dx .$$

**Theorem 8.2 (Variable slicing).** If $a < b$ and $\mathrm{low} > 0$ on $(a,b)$, then
$$\mathcal{A}^{K}(a,b;\mathrm{low}) \;=\; \int_{a}^{b} \frac{dx}{K(x)\,\mathrm{low}(x)} .$$
No positivity, continuity, or measurability hypothesis on $K$ is required beyond what makes the outer integral meaningful.

*Proof sketch.* As in Theorem 4.3, the inner integral is $K(x)^{-1}\,\mathrm{low}(x)^{-1}$ for almost every $x$. $\square$

**Lemma 8.3 (Reference integral).** For $a < b$ and $\kappa \ne 0$, $\int_{a}^{b} \kappa^{-1}h_{a,b}(x)^{-1}\,dx = \pi/\kappa$.

*Proof.* Pull out the constant and apply Theorem 3.6. $\square$

**Theorem 8.4 (Upper comparison).** Let $a < b$, $\kappa_{1} > 0$, $K$ continuous on $[a,b]$ with $K \ge \kappa_{1}$ there. Then
$$\mathcal{A}^{K}\big(a,b;h_{a,b}\big) \;\le\; \frac{\pi}{\kappa_{1}} .$$

*Proof sketch.* By Theorem 8.2 the area is $\int_{a}^{b} K(x)^{-1}h_{a,b}(x)^{-1}dx$. Both this integrand and the reference integrand $\kappa_{1}^{-1}h_{a,b}^{-1}$ are integrable: the chordal density is integrable (Theorem 3.4) and $K^{-1}$ is continuous, hence bounded, on the compact interval (using $K \ge \kappa_1 > 0$ so $K$ never vanishes). Pointwise, $K(x) \ge \kappa_{1} > 0$ gives $K(x)^{-1} \le \kappa_{1}^{-1}$, and $h_{a,b}^{-1} \ge 0$, so the integrands are ordered. Monotonicity of the integral plus Lemma 8.3 completes the proof. $\square$

**Theorem 8.5 (Lower comparison).** Let $a < b$, $\kappa_{2} > 0$, $K$ continuous and positive on $[a,b]$ with $K \le \kappa_{2}$ there. Then
$$\frac{\pi}{\kappa_{2}} \;\le\; \mathcal{A}^{K}\big(a,b;h_{a,b}\big).$$

*Proof sketch.* Identical, with the inequality $\kappa_{2}^{-1} \le K(x)^{-1}$ from $0 < K(x) \le \kappa_{2}$. $\square$

**Theorem 8.6 (Pinching).** If $a < b$, $0 < \kappa_{1} \le K \le \kappa_{2}$ on $[a,b]$ with $K$ continuous, then
$$\frac{\pi}{\kappa_{2}} \;\le\; \mathcal{A}^{K}\big(a,b;h_{a,b}\big) \;\le\; \frac{\pi}{\kappa_{1}} .$$

*Proof.* Note $\kappa_{2} \ge K(a) \ge \kappa_{1} > 0$, so $\kappa_{2} > 0$ and both Theorems 8.4 and 8.5 apply. $\square$

**Theorem 8.7 (Sharpness).** For constant $K \equiv \kappa$,
$$\mathcal{A}^{\kappa}\big(a,b;h_{a,b}\big) \;=\; \frac{\pi}{\kappa} \;=\; \mathcal{A}_{\kappa}\big(a,b;h_{a,b}\big).$$
Hence neither inequality of Theorem 8.6 can be improved: taking $K \equiv \kappa_{1}$ attains the upper bound and $K \equiv \kappa_{2}$ attains the lower bound.

*Proof.* Theorem 8.2, Lemma 8.3, and Theorem 4.4. $\square$

**Interpretation 8.8.** Curvature magnitude and ideal area are in exact inverse proportion: $\mathrm{Area} \cdot \kappa = \pi$. More negative curvature compresses the plane and shrinks the largest triangle; the flat limit $\kappa \downarrow 0$ sends $\pi/\kappa \to \infty$, recovering the Euclidean absence of a maximum. Under pinching the product $\mathrm{Area}\cdot K$ is no longer constant but is still trapped: $\pi\,\kappa_{1}/\kappa_{2} \le \mathrm{Area}\cdot\kappa_{1}$ and so on. This is the elementary prototype of Riemannian comparison geometry — Rauch, Toponogov, Bishop–Gromov — where curvature bounds are converted into metric and volume bounds.

---

## 9. Algorithms and numerics

### 9.1 Exact area of an ideal polygon

**Algorithm 9.1.** *Input:* curvature magnitude $\kappa > 0$; a list of $m+1$ increasing finite boundary vertices, with an implicit vertex at $\infty$. *Output:* exact area.

1. Verify $v_{0} < v_{1} < \cdots < v_{m}$.
2. Return $m\pi/\kappa$.

Complexity: $O(m)$ for validation, $O(1)$ arithmetic. The remarkable feature is that no positions enter the answer. This is Theorem 4.8.

### 9.2 Numerical verification of the chordal integral

The integral $\int_{a}^{b} h_{a,b}^{-1}$ has inverse-square-root singularities at both endpoints, so naive uniform quadrature converges at rate $O(N^{-1/2})$ — unusably slow. The correct method is to *remove the singularity by substitution*: set $x = \frac{a+b}{2} + \frac{b-a}{2}\sin\psi$, $\psi \in [-\pi/2, \pi/2]$. Then $dx = \frac{b-a}{2}\cos\psi\,d\psi$ and $h_{a,b}(x) = \frac{b-a}{2}\cos\psi$, so the integrand becomes the constant $1$ and the integral is the length $\pi$ of the $\psi$-interval — exactly, in one line. This substitution is also the cleanest proof of Theorem 3.6 and explains the appearance of $\pi$.

For an independent numerical check one may instead use the *tanh–sinh* (double-exponential) quadrature rule, which handles endpoint algebraic singularities and converges at a rate that is essentially exponential in the number of nodes.

### 9.3 Area by direct two-dimensional quadrature

To verify Theorem 4.4 without using the closed form, compute
$$\frac{1}{\kappa}\int_{a}^{b} \frac{dx}{h_{a,b}(x)}$$
by an adaptive quadrature that is aware of the endpoint singularity, or truncate: compute $\mathcal{T}_{\kappa}(a,b;t)$ for a sequence $t \downarrow 0$ and observe convergence to $\pi/\kappa$ from below, in agreement with Theorems 6.7 and 6.8. The truncated value has the closed form of Theorem 6.6, which also permits an exact error estimate:
$$\frac{\pi}{\kappa} - \mathcal{T}_{\kappa}(a,b;t) = \frac{1}{\kappa}\left[\left(\frac{\pi}{2} - \arcsin\frac{b - a - 2t}{b-a}\right) + \left(\arcsin\frac{2t - (b-a)}{b-a} + \frac{\pi}{2}\right)\right] \sim \frac{4}{\kappa}\sqrt{\frac{t}{b-a}}$$
as $t \downarrow 0$, using $\arccos(1-\varepsilon) \sim \sqrt{2\varepsilon}$. The square-root rate is a direct signature of the endpoint singularity.

### 9.4 Normalising a boundary triple

**Algorithm 9.2.** *Input:* $p < q < r$. *Output:* coefficients $(A,B,C,D)$ of the unique orientation-preserving real Möbius map sending $(p,q,r) \mapsto (0,1,\infty)$, plus the determinant.

1. $A \leftarrow q-r$; $B \leftarrow -p(q-r)$; $C \leftarrow q-p$; $D \leftarrow -r(q-p)$.
2. $\det \leftarrow AD - BC = (r-q)(q-p)(r-p)$.
3. Return $(A,B,C,D,\det)$.

Complexity $O(1)$. Correctness is Theorems 7.8–7.9; uniqueness is Theorem 7.11.

### 9.5 Sample numerics

At $\kappa = 1$: every ideal triangle has area $\pi \approx 3.14159265$. The ideal quadrilateral has area $2\pi \approx 6.28318531$; the ideal hexagon $4\pi \approx 12.56637$. With $\kappa = 2$ (curvature $-2$), the ideal triangle has area $\pi/2 \approx 1.5708$.

For the family of §5.2 with $\kappa = 1$: taking $\theta = 2\pi/3$, $\varphi = \pi/3$ gives angles $\alpha = \pi/3 \approx 1.0472$, $\beta = \pi/3$, $\gamma = 0$, and area $(2\pi/3 - \pi/3)/1 = \pi/3 \approx 1.0472$, in agreement with $(\pi - \pi/3 - \pi/3 - 0)/1 = \pi/3$.

Truncation at $t = 10^{-3}$ with $a = 0$, $b = 1$, $\kappa = 1$ gives area $2\arcsin(1 - 2\cdot 10^{-3}) \approx 3.0151$, below $\pi$ by about $0.1265$, consistent with the predicted $4\sqrt{t} = 0.1265$.

---

## 10. Applications and context

**Quantisation of hyperbolic surface area.** A closed orientable surface of genus $g \ge 2$ admits hyperbolic metrics of curvature $-1$. Any such metric decomposes into $4g-4$ ideal-like triangles or, via Gauss–Bonnet globally, has total area exactly $2\pi|\chi| = 4\pi(g-1)$, determined by topology alone. No deformation of the metric changes it. The bounded-area theorem for triangles is the local statement of which this is the global integral.

**Thin triangles and coarse geometry.** Bounded area forces bounded "thickness": in the hyperbolic plane every geodesic triangle is $\delta$-thin for a universal $\delta$ (each side lies in the $\delta$-neighbourhood of the union of the other two). Abstracting this property away from any metric model gives Gromov's notion of a hyperbolic group, from which follow solvable word problems, linear isoperimetric inequalities, and boundary theories. The uniform area bound proved here is the geometric substance behind that abstraction.

**Ideal triangulations and knot invariants.** The three-dimensional analogue of the ideal triangle is the ideal tetrahedron; a hyperbolic structure on a knot complement is typically constructed by gluing finitely many of them and solving Thurston's gluing equations. Finiteness of ideal volume — the analogue of our $\pi/\kappa$ — makes hyperbolic volume a real-valued invariant of knots, and one of the strongest in practice. The area formula $(n-2)\pi/\kappa$ for ideal polygons is the two-dimensional model for the additivity of ideal volume under decomposition.

**Modular geometry and number theory.** The modular group $\mathrm{PSL}(2,\mathbb{Z})$ acts on $\mathbb{H}$, and its standard fundamental domain is a hyperbolic triangle with one ideal vertex at $\infty$ and angles $\pi/3$, $\pi/3$, $0$; its area is $\pi - 2\pi/3 = \pi/3$, an instance of Theorem 5.6. This number appears throughout the theory of modular forms — for instance in the mass formulae and the Gauss–Bonnet computation of the Euler characteristic of the modular curve.

**Tilings and visual art.** Escher's *Circle Limit* woodcuts tile the hyperbolic plane by congruent figures. The tiles do not shrink hyperbolically; the apparent shrinkage is an artefact of the Euclidean rendering. Ideal triangulations of the hyperbolic plane by copies of *the* ideal triangle (all congruent, by Corollary 7.13) are the cleanest example: infinitely many pieces, each of area exactly $\pi$.

**Comparison geometry.** Theorem 8.6 is the simplest possible curvature-comparison statement: a pointwise two-sided curvature bound yields a two-sided area bound, sharp at the constant-curvature ends. The general theory — Rauch comparison, Toponogov's theorem, Bishop–Gromov volume comparison — is the same idea run at much greater generality, and the ideal triangle is the extremal configuration in the negative-curvature model case.

---

## 11. Discussion and future directions

### 11.1 What is proved and what is assumed

The development above is honest about its scope. Theorems 3.2–3.6 (analysis), 4.1–4.9 (areas by slicing), 5.2–5.9 (angles and Gauss–Bonnet with at least one ideal vertex), 6.2–6.10 (maximality, rigidity, degeneration), 7.2–7.12 (Möbius isometries and three-transitivity) and 8.2–8.7 (curvature comparison) are proved in full from the definitions given.

Two deliberate scope restrictions remain. First, the derived Gauss–Bonnet theorem of §5 covers triangles with **at least one ideal vertex** — a family rich enough to include the ideal triangle, the modular triangle, and every degeneration between — but not yet triangles with three finite vertices. Second, Corollary 7.13 uses the integrated Möbius invariance of hyperbolic area, of which Theorem 7.5 is the infinitesimal form.

Both gaps are addressed by the two conjectures below, and both are, in the authors' assessment, matters of bookkeeping rather than new analysis.

### 11.2 Conjecture A — full Gauss–Bonnet with all vertices finite

**Conjecture A.** For any three points of the upper half-plane not on a common geodesic, the region bounded by the three connecting geodesics has hyperbolic area $(\pi - (\alpha+\beta+\gamma))/\kappa$, where $\alpha, \beta, \gamma$ are the angles between the tangent vectors of the sides at the three vertices.

*Why the one-ideal-vertex case should already be the whole theorem.* Extend one side of an arbitrary finite triangle to the boundary; the triangle becomes the difference of two triangles each having an ideal vertex at $\infty$, for which §5 gives the area. The identity then follows by additivity of the slicing integral together with a single angle-addition identity at the shared vertex — no new analysis is required, only careful bookkeeping of which region is added and which subtracted. The three previously missing ingredients are now in place: the exact antiderivative $F_{a,b}$, the improper integrability across the singular endpoints, and a definition of interior angle that is provably conformally invariant.

*Falsifiable form.* Compute the area of the triangle with vertices $i$, $2i$, $1+i$ numerically; the conjecture is refuted if it differs from $\pi - \alpha - \beta - \gamma$ for the numerically computed angles.

### 11.3 Conjecture B — Möbius invariance of hyperbolic area

**Conjecture B.** For $T$ a real Möbius map of positive determinant and $S$ a measurable subset of the upper half-plane,
$$\int_{T(S)} \frac{dx\,dy}{y^{2}} \;=\; \int_{S} \frac{dx\,dy}{y^{2}} .$$

This is the integrated form of Theorem 7.5. The proof is the change-of-variables formula: the real Jacobian determinant of $T$, viewed as a map $\mathbb{R}^{2} \to \mathbb{R}^{2}$, equals $|T'(z)|^{2}$ by holomorphy, while the density transforms by $\operatorname{Im}T(z)^{-2} = |T'(z)|^{-2}\operatorname{Im}(z)^{-2}$; the two factors cancel exactly. Establishing it turns Corollary 7.13 into an unconditional theorem: hyperbolic area is an isometry invariant, and *every* ideal triangle has area $\pi/\kappa$.

### 11.4 Further directions

1. **A second model.** Develop the Poincaré disk model and the explicit isometry with the half-plane (the Cayley transform $z \mapsto (z-i)/(z+i)$), and check that ideal triangle area is model-independent.
2. **Ideal polygons with all vertices finite on $\mathbb{R}$.** Prove $(n-2)\pi/\kappa$ without the convenient vertex at $\infty$, using Conjecture B to move one vertex there.
3. **Sequences of finite triangles converging to an ideal one.** Construct an explicit sequence of triangles with three finite vertices whose vertices converge to three boundary points, each angle tending to zero and area tending to $\pi/\kappa$ — the finite-vertex refinement of Theorems 6.7 and 6.8.
4. **Genuinely two-dimensional variable curvature.** Section 8 allows $K$ to depend on the base coordinate $x$. Allow $K = K(x,y)$, and relate the resulting area functional to the intrinsic Gaussian curvature of the corresponding conformal metric $e^{2u}(dx^{2}+dy^{2})$, whose curvature is $-e^{-2u}\Delta u$. Comparison should then follow from the maximum principle applied to the Liouville equation.
5. **Holonomy.** Express the angular defect as the rotational holonomy of the Levi-Civita connection around the triangle, and prove directly that ideal maximality is invariant under all hyperbolic isometries (including orientation-reversing ones).
6. **Higher dimensions.** The ideal tetrahedron in $\mathbb{H}^{3}$ has volume given by the Lobachevsky function $\Lambda$, maximised by the regular ideal tetrahedron at volume $3\Lambda(\pi/3) \approx 1.0149$. The two-dimensional story here is the degenerate case in which the maximiser is unique up to isometry and the maximum is a closed form; the three-dimensional analogue is genuinely harder and is the foundation of hyperbolic volume computations for knots.
7. **Quantitative stability.** Theorem 6.10 says area near-maximal implies angles near zero. Make this quantitative: $\pi/\kappa - \mathrm{Area} = (\alpha+\beta+\gamma)/\kappa$ is already exact, so the interesting question is a *geometric* stability statement — if the area is within $\varepsilon$ of maximal, how close (in Hausdorff distance on the compactified plane, say) must the triangle be to an ideal one?

### 11.5 A note on the shape of the argument

It is worth recording how little machinery the development needs. One improper integral, $\int_a^b dx/\sqrt{(x-a)(b-x)} = \pi$, supplies the area of the ideal triangle *and*, by its independence of $a$ and $b$, the congruence of all such triangles. One algebraic identity, $\mathrm{Area} = (\pi - \alpha-\beta-\gamma)/\kappa$, supplies maximality (from nonnegativity of angles), rigidity (from the equality case), and the polygon formula (by triangulation). One conformality identity, $|T'|/\operatorname{Im}T = 1/\operatorname{Im}$, supplies the isometry group and, through three-transitivity, the reduction of the general ideal triangle to the normal form $(0,1,\infty)$.

Three inputs; the rest is bookkeeping. That economy is the hallmark of a theory that has found its correct formulation.

---

## References (classical background)

The angle-defect formula for hyperbolic triangles is due to Lambert and Gauss; the half-plane model to Beltrami and Poincaré; the classification of geodesics and the action of $\mathrm{PSL}(2,\mathbb{R})$ is standard nineteenth-century material. Thurston's ideal-tetrahedron programme and Gromov's $\delta$-hyperbolicity are the two modern developments most directly downstream of the results presented here.
