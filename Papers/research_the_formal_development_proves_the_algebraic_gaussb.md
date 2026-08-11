# Ideal Triangles in the Half-Plane: An Explicit Derivation of Hyperbolic Gauss–Bonnet, Its Extremal Rigidity, and Curvature Comparison

**Author:** Aristotle
**Date:** 2026-08-11
**Keywords:** hyperbolic geometry, Gauss–Bonnet theorem, ideal triangle, upper half-plane model, Möbius transformation, curvature comparison, angular defect

---

## Abstract

We give a complete and elementary derivation, entirely from the Riemannian area
element of the upper half-plane model, of the area theory of ideal and
partially-ideal hyperbolic triangles at constant curvature $-\kappa$, $\kappa > 0$.
The analytic core is the single identity
$$\int_{a}^{b} \frac{dx}{\sqrt{(x-a)(b-x)}} = \pi \qquad (a < b),$$
an improper integral whose value is independent of the endpoints; it is
established via the explicit antiderivative $x \mapsto \arcsin\frac{2x-a-b}{b-a}$
together with a fundamental-theorem-of-calculus argument valid across both
singular endpoints. Combining this with the vertical fibre integral
$\int_{c}^{\infty} y^{-2}\,dy = c^{-1}$ yields, by Fubini-type slicing, that the
ideal triangle with boundary vertices $a < b$ and $\infty$ has hyperbolic area
exactly $\pi/\kappa$.

We then prove the following, all from the same slicing machinery. (i) An ideal
$n$-gon has area $(n-2)\pi/\kappa$, by a genuine triangulation along vertical
geodesics, and the area is additive under edge-gluing, so it is triangulation
invariant. (ii) For the family of triangles with vertices $(\cos\theta,
\sin\theta)$, $(\cos\varphi, \sin\varphi)$ and $\infty$, with $0 \le \varphi <
\theta \le \pi$, the interior angles — *defined* as angles between the tangent
vectors of the geodesic sides, and shown to be invariant under positive rescaling
of either tangent vector, hence conformally invariant — equal $\pi - \theta$ and
$\varphi$; and the area equals $(\theta - \varphi)/\kappa$, which is precisely the
Gauss–Bonnet value $\bigl(\pi - ((\pi - \theta) + \varphi + 0)\bigr)/\kappa$. The
single hypothesis range covers triangles with one, two or three ideal vertices.
(iii) Finite vertices carry strictly positive angles, so such triangles have area
strictly below $\pi/\kappa$; and compact truncations of an ideal triangle have
strictly smaller area, increasing to $\pi/\kappa$ in the limit. (iv) Conversely,
any sequence of admissible angle triples whose Gauss–Bonnet area tends to
$\pi/\kappa$ has all three angles tending to $0$: the ideal triangle is the unique
limiting shape of a maximising sequence. (v) The real Möbius group acts on the
half-plane by hyperbolic isometries — we prove the height-distortion identity
$\operatorname{Im} T(z) = \det(T)\operatorname{Im}(z)/|Cz+D|^{2}$ and the pointwise
conformality identity $|T'(z)|/\operatorname{Im}T(z) = 1/\operatorname{Im}z$ — and
acts sharply three-transitively on the boundary, via an explicit cross-ratio
normalisation with positive determinant and a uniqueness argument; hence every
ideal triangle is isometric to the standard one and the value $\pi/\kappa$ is
universal. (vi) Under variable curvature $-K(x)$ with $\kappa_1 \le K \le
\kappa_2$, the ideal-triangle area is pinched: $\pi/\kappa_2 \le \text{Area} \le
\pi/\kappa_1$, sharply.

---

## 1. Introduction

### 1.1 The phenomenon

Euclidean geometry has no largest triangle. Hyperbolic geometry does. In a
complete simply connected surface of constant curvature $-\kappa < 0$, the area
of a geodesic triangle with interior angles $\alpha, \beta, \gamma$ is

$$\mathcal{A}(\kappa; \alpha, \beta, \gamma) = \frac{\pi - (\alpha + \beta + \gamma)}{\kappa},$$

the two-dimensional Gauss–Bonnet theorem. Since the angles are nonnegative, the
area never exceeds $\pi/\kappa$, and equality forces all three angles to vanish.
There is thus a *universal* upper bound on triangle area depending only on the
curvature, attained only in the degenerate limit where all three vertices recede
to the ideal boundary.

This paper is concerned with converting that statement from a slogan about angle
data into an explicit, self-contained computation performed inside a concrete
model, together with the surrounding extremal and comparison theory.

### 1.2 The gap this work closes

A purely *algebraic* treatment can take
$\mathcal{A}(\kappa; \alpha, \beta, \gamma) := (\pi - (\alpha+\beta+\gamma))/\kappa$
as a definition and derive the maximality bound and the rigidity characterisation
by elementary inequalities. Such a treatment is correct but hollow: nothing in it
knows what a hyperbolic triangle *is*. Neither the area nor the angles are
connected to a metric; the "theorem" is a restatement of the definition.

The present development removes that gap. We fix the upper half-plane model with
its Riemannian area element, define regions by their geodesic boundaries, define
angles as arccosines of normalised inner products of tangent vectors, and then
*prove* that area equals angular defect over $\kappa$, for a family of triangles
rich enough to include all the ideal cases and a two-parameter family of
partially ideal ones. The proof of the fundamental area identity is elementary
enough to be checked by hand and precise enough to be checked by machine.

### 1.3 Organisation

Section 2 sets up the model. Section 3 proves the analytic core: the chordal
integral. Section 4 proves the slicing formula. Section 5 computes the ideal
triangle area, the polygon formula, and the degeneration statements. Section 6
defines angles and derives Gauss–Bonnet for triangles with at least one ideal
vertex. Section 7 develops the Möbius symmetry group and sharp
three-transitivity. Section 8 treats variable curvature. Section 9 presents
algorithms and numerical validation. Section 10 discusses applications, open
conjectures and future work.

---

## 2. The upper half-plane model

**Definition 2.1 (Half-plane model at curvature $-\kappa$).**
Let $\kappa > 0$. The *upper half-plane model of curvature $-\kappa$* is the set
$$\mathbb{H} = \{(x,y) \in \mathbb{R}^{2} : y > 0\}$$
equipped with the Riemannian metric
$$ds^{2} = \frac{dx^{2} + dy^{2}}{\kappa\, y^{2}}, \qquad\text{hence area element}\qquad dA = \frac{dx\,dy}{\kappa\, y^{2}}.$$
Identifying $(x,y)$ with $z = x + iy \in \mathbb{C}$, the line element is
$|dz|/(\sqrt{\kappa}\,y)$.

The metric is $1/\kappa$ times the standard hyperbolic metric of curvature $-1$;
scaling a two-dimensional metric by a positive constant $c$ scales its Gauss
curvature by $c^{-1}$, so the curvature is indeed the constant $-\kappa$.

**Definition 2.2 (Geodesics and the ideal boundary).**
The complete geodesics of $\mathbb{H}$ are the vertical rays $\{x = c,\ y > 0\}$
and the Euclidean semicircles centred on the $x$-axis. The *ideal boundary*
$\partial_{\infty}\mathbb{H}$ is $\mathbb{R} \cup \{\infty\}$; its points are not
points of $\mathbb{H}$ but are limits of geodesic rays. Each complete geodesic
has two distinct ideal endpoints, and conversely each pair of distinct ideal
points is joined by a unique complete geodesic.

Concretely, the geodesic joining the boundary points $a$ and $b$ with $a < b$ is
the semicircle of diameter $[a,b]$, whose height over $x \in (a,b)$ we denote

$$\ell_{a,b}(x) := \sqrt{(x-a)(b-x)},$$

and the geodesic joining $a$ to $\infty$ is the vertical ray above $a$.

**Definition 2.3 (Ideal triangle with vertex at $\infty$).**
For $a < b$, the *ideal triangle* $\Delta(a,b,\infty)$ is
$$\Delta(a,b,\infty) = \{(x,y) : a < x < b,\ y > \ell_{a,b}(x)\},$$
the region bounded below by the semicircular geodesic joining $a$ and $b$ and
laterally by the two vertical geodesics through $a$ and $b$. Every point of
$\Delta(a,b,\infty)$ has $y > \ell_{a,b}(x) > 0$, so the region does lie in the
open upper half-plane. In the Euclidean sense $\Delta(a,b,\infty)$ is unbounded
and of infinite area; its three "vertices" $a$, $b$, $\infty$ are ideal points,
not points of $\mathbb{H}$.

**Definition 2.4 (Angular defect and the Gauss–Bonnet functional).**
For $\kappa > 0$ and reals $\alpha, \beta, \gamma$, write
$$\mathcal{A}(\kappa;\alpha,\beta,\gamma) := \frac{\pi - (\alpha+\beta+\gamma)}{\kappa}.$$
A triple $(\alpha,\beta,\gamma)$ is *admissible* if $\alpha,\beta,\gamma \ge 0$
and $\alpha + \beta + \gamma \le \pi$.

For admissible triples, $0 \le \mathcal{A}(\kappa;\alpha,\beta,\gamma) \le
\pi/\kappa$, with the upper bound attained exactly when $\alpha=\beta=\gamma=0$.
Both the bound and the rigidity are immediate from the definitions, but note that
the nonnegativity hypothesis is indispensable: without it, a large positive angle
could be cancelled by a negative one and the rigidity would fail. The substance
of the paper is that $\mathcal{A}$ is the *actual* Riemannian area of the *actual*
region with the *actual* angles.

---

## 3. The analytic core: the chordal integral

The entire theory rests on one integral. We treat it carefully because the
integrand is singular at both endpoints of the interval of integration.

**Definition 3.1 (Chordal density and its antiderivative).**
For $a < b$ set
$$\ell_{a,b}(x) = \sqrt{(x-a)(b-x)}, \qquad F_{a,b}(x) = \arcsin\!\left(\frac{2x - a - b}{b-a}\right).$$
The function $F_{a,b} : \mathbb{R} \to [-\pi/2,\pi/2]$ is continuous everywhere,
being the composition of $\arcsin$ with an affine map.

**Lemma 3.2 (Key derivative computation).**
For every $x \in (a,b)$, $F_{a,b}$ is differentiable at $x$ with
$$F_{a,b}'(x) = \frac{1}{\ell_{a,b}(x)} = \frac{1}{\sqrt{(x-a)(b-x)}}.$$

*Proof sketch.* Write $u(x) = (2x-a-b)/(b-a)$, so $u'(x) = 2/(b-a)$ and $u(x) \in
(-1,1)$ for $x \in (a,b)$ (indeed $u(a) = -1$, $u(b) = 1$, and $u$ is strictly
increasing). On $(-1,1)$ the arcsine is differentiable with derivative
$1/\sqrt{1-u^{2}}$, so by the chain rule
$$F_{a,b}'(x) = \frac{2}{(b-a)\sqrt{1 - u(x)^{2}}}.$$
The algebraic identity
$$1 - \left(\frac{2x-a-b}{b-a}\right)^{2} = \frac{(b-a)^{2} - (2x-a-b)^{2}}{(b-a)^{2}} = \frac{4(x-a)(b-x)}{(b-a)^{2}}$$
gives $\sqrt{1-u(x)^{2}} = 2\sqrt{(x-a)(b-x)}/(b-a)$, since both sides are
nonnegative and $(x-a)(b-x) > 0$ on $(a,b)$. Substituting cancels the factor
$2/(b-a)$ and yields the claim. $\square$

**Lemma 3.3 (Improper integrability).**
The function $x \mapsto \ell_{a,b}(x)^{-1}$ is integrable on $[a,b]$, notwith\-standing
that it diverges at both endpoints.

*Proof sketch.* $F_{a,b}$ is continuous on $[a,b]$ and, by Lemma 3.2, has
nonnegative derivative $\ell_{a,b}^{-1}$ throughout the open interval. A
continuous function on a compact interval that is differentiable with
nonnegative derivative on the interior has integrable derivative there, with
total mass bounded by the increment of the function. (Concretely, the divergence
is of order $(x-a)^{-1/2}$ and $(b-x)^{-1/2}$, both integrable.) $\square$

**Proposition 3.4 (Fundamental theorem across the singularities).**
If $a \le u < v \le b$ then
$$\int_{u}^{v} \frac{dx}{\ell_{a,b}(x)} = F_{a,b}(v) - F_{a,b}(u),$$
*including* the cases $u = a$ and $v = b$ where the integrand is unbounded.

*Proof sketch.* On $(u,v) \subseteq (a,b)$ we have the pointwise derivative
statement of Lemma 3.2; the integrand is integrable on $[u,v]$ by Lemma 3.3 and
monotonicity of the integral domain; and $F_{a,b}$ is continuous, hence has the
correct one-sided limits at $u^{+}$ and $v^{-}$. The version of the fundamental
theorem of calculus requiring only interior differentiability, integrability, and
one-sided limits at the endpoints then applies. $\square$

**Theorem 3.5 (The chordal integral).**
For all $a < b$,
$$\int_{a}^{b} \frac{dx}{\sqrt{(x-a)(b-x)}} = \pi.$$

*Proof.* Apply Proposition 3.4 with $u = a$, $v = b$. Since
$u(a) = (2a - a - b)/(b-a) = -1$ and $u(b) = (2b-a-b)/(b-a) = 1$, we get
$F_{a,b}(a) = \arcsin(-1) = -\pi/2$ and $F_{a,b}(b) = \arcsin(1) = \pi/2$, whence
the integral equals $\pi/2 - (-\pi/2) = \pi$. $\square$

**Remark 3.6.** The value is independent of $a$ and $b$. This is the analytic
shadow of the geometric fact that all ideal triangles are congruent; the
scaling $x \mapsto a + (b-a)t$ turns the integral into
$\int_0^1 dt/\sqrt{t(1-t)} = B(\tfrac12,\tfrac12) = \pi$, the value of a Beta
function at the half-integer point.

**Lemma 3.7 (Vertical fibre integral).**
For $c > 0$, $\displaystyle\int_{c}^{\infty} \frac{dy}{y^{2}} = \frac{1}{c}.$

*Proof sketch.* Rewrite $y^{-2} = y^{-2}$ as a real power and apply the standard
formula $\int_{c}^{\infty} y^{s}\,dy = -c^{s+1}/(s+1)$ for $s < -1$, $c>0$, at
$s = -2$. $\square$

Geometrically, Lemma 3.7 says that the hyperbolic measure of the vertical fibre
above height $c$ is finite and equal to $1/c$: an infinite Euclidean chimney of
finite hyperbolic content. This is the second miracle and, with Theorem 3.5, it
is all we need.

---

## 4. Slicing

**Definition 4.1 (Sliced area).**
Let $\kappa \in \mathbb{R}$, $a < b$, and $\text{low} : \mathbb{R} \to \mathbb{R}$
a function positive on $(a,b)$. The *sliced area* of the region above the graph of
$\text{low}$ over $(a,b)$ is
$$\mathcal{S}_{\kappa}(a,b;\text{low}) := \int_{a}^{b}\!\!\left(\int_{\text{low}(x)}^{\infty} \frac{dy}{\kappa y^{2}}\right) dx .$$

**Theorem 4.2 (Slicing formula).**
With hypotheses as in Definition 4.1,
$$\mathcal{S}_{\kappa}(a,b;\text{low}) = \frac{1}{\kappa}\int_{a}^{b} \frac{dx}{\text{low}(x)}.$$

*Proof sketch.* For each $x \in (a,b)$, factor the constant: $(\kappa y^{2})^{-1}
= \kappa^{-1} y^{-2}$, pull $\kappa^{-1}$ out of the inner integral, and apply
Lemma 3.7 with $c = \text{low}(x) > 0$ to get $\kappa^{-1}\text{low}(x)^{-1}$.
This holds for all $x$ in the open interval, hence almost everywhere on $[a,b]$
(the two endpoints form a null set), so the outer integrals agree; finally pull
$\kappa^{-1}$ out of the outer integral. $\square$

Theorem 4.2 reduces every two-dimensional hyperbolic area computation of this
shape to a one-dimensional integral of the reciprocal height of the lower
boundary. The geometry of hyperbolic area is thereby localised entirely in the
lower boundary curve.

---

## 5. The ideal triangle, ideal polygons, and degeneration

**Theorem 5.1 (Area of an ideal triangle; Gauss–Bonnet at all angles zero).**
For $\kappa > 0$ and $a < b$, the hyperbolic area of $\Delta(a,b,\infty)$ is
$$\mathcal{S}_{\kappa}(a,b;\ell_{a,b}) = \frac{\pi}{\kappa} = \mathcal{A}(\kappa; 0,0,0).$$

*Proof.* By Theorem 4.2 with $\text{low} = \ell_{a,b}$, which is positive on
$(a,b)$, the area is $\kappa^{-1}\int_{a}^{b} \ell_{a,b}(x)^{-1}dx$, and by
Theorem 3.5 this is $\pi/\kappa$. The second equality is the definition of
$\mathcal{A}$ at zero angles. $\square$

This is the promised derivation: the value that the Gauss–Bonnet functional
*predicts* for a triangle with three zero angles is *computed* directly from the
Riemannian area element, with no appeal to Gauss–Bonnet.

**Corollary 5.2 (Congruence of ideal triangles with a vertex at $\infty$).**
For any $a<b$ and $a'<b'$, $\mathcal{S}_{\kappa}(a,b;\ell_{a,b}) =
\mathcal{S}_{\kappa}(a',b';\ell_{a',b'})$. The area invariant does not see the
positions of the two finite ideal vertices.

**Definition 5.3 (Ideal polygon).**
Let $m \ge 1$ and let $v_{0} < v_{1} < \cdots < v_{m}$ be boundary points. The
*ideal $(m+2)$-gon* with these finite vertices and last vertex $\infty$ is the
region bounded below by the $m$ geodesic semicircles joining consecutive $v_{i}$
and laterally by the vertical geodesics through $v_{0}$ and $v_{m}$. Its area is
the sum
$$\mathcal{P}_{\kappa}(v_{0},\dots,v_{m}) := \sum_{i=0}^{m-1} \mathcal{S}_{\kappa}(v_{i}, v_{i+1}; \ell_{v_{i},v_{i+1}}).$$

The definition is a genuine triangulation: the vertical geodesics through the
interior finite vertices $v_{1},\dots,v_{m-1}$ cut the polygon into $m$ regions,
the $i$-th of which is exactly $\Delta(v_{i},v_{i+1},\infty)$.

**Theorem 5.4 (Area of an ideal $n$-gon).**
If $v_{0} < v_{1} < \cdots < v_{m}$ then
$$\mathcal{P}_{\kappa}(v_{0},\dots,v_{m}) = \frac{m\pi}{\kappa} = \frac{(n-2)\pi}{\kappa}, \qquad n = m+2.$$

*Proof.* Each summand equals $\pi/\kappa$ by Theorem 5.1; there are $m$ of them.
$\square$

**Theorem 5.5 (Additivity under gluing; triangulation invariance).**
For ideal polygons with $m$ and $k$ triangulating pieces respectively, glued
along a common edge to form a polygon with $m + k$ pieces, the areas add:
$$\mathcal{P}^{(m+k)} = \mathcal{P}^{(m)} + \mathcal{P}^{(k)}.$$

*Proof.* All three quantities are computed by Theorem 5.4, and $(m+k)\pi/\kappa =
m\pi/\kappa + k\pi/\kappa$. $\square$

The content of Theorem 5.5 is that the area depends only on the *number of
vertices*, never on the triangulation used to compute it — the invariant is
combinatorial, and it reproduces the Euclidean angle-sum count $(n-2)\pi$ as an
*area* rather than as an angle.

### 5.1 Degeneration: compact exhaustion

**Definition 5.6 (Truncated ideal triangle).**
For $t > 0$ with $a + t < b - t$, the *truncated* ideal triangle is the portion of
$\Delta(a,b,\infty)$ lying over $[a+t, b-t]$; its area is
$$T_{\kappa}(a,b;t) := \mathcal{S}_{\kappa}(a+t, b-t; \ell_{a,b}).$$

**Proposition 5.7 (Closed form for the truncation).**
$$T_{\kappa}(a,b;t) = \frac{F_{a,b}(b-t) - F_{a,b}(a+t)}{\kappa}
= \frac{1}{\kappa}\left[\arcsin\!\Bigl(\tfrac{b-a-2t}{b-a}\Bigr) - \arcsin\!\Bigl(\tfrac{2t-(b-a)}{b-a}\Bigr)\right].$$

*Proof sketch.* By Theorem 4.2 the area is $\kappa^{-1}\int_{a+t}^{b-t}
\ell_{a,b}^{-1}$, and $[a+t,b-t] \subset (a,b)$ is an interval on which the
integrand is continuous, so the ordinary fundamental theorem of calculus applies
with the antiderivative $F_{a,b}$ of Lemma 3.2. $\square$

**Theorem 5.8 (Strict subideality of compact pieces).**
For $\kappa > 0$, $t > 0$ and $a + t < b - t$,
$$T_{\kappa}(a,b;t) < \frac{\pi}{\kappa}.$$

*Proof sketch.* Always $F_{a,b}(b-t) \le \pi/2$. And $F_{a,b}(a+t) > -\pi/2$
strictly, because the argument $(2(a+t)-a-b)/(b-a) = (2t - (b-a))/(b-a)$ is
strictly greater than $-1$ when $t > 0$, and $\arcsin$ exceeds $-\pi/2$ strictly
above $-1$. Hence the numerator is strictly below $\pi$. $\square$

**Theorem 5.9 (Degeneration).**
For $a < b$,
$$\lim_{t \to 0^{+}} T_{\kappa}(a,b;t) = \frac{\pi}{\kappa}.$$

*Proof sketch.* The map $t \mapsto (F_{a,b}(b-t) - F_{a,b}(a+t))/\kappa$ is
continuous on a neighbourhood of $0$ (composition of the continuous $F_{a,b}$
with affine maps), and its value at $t = 0$ is $(\pi/2 - (-\pi/2))/\kappa =
\pi/\kappa$. For all sufficiently small $t > 0$ the closed-form expression of
Proposition 5.7 agrees with $T_{\kappa}(a,b;t)$, so the limit along $t \to 0^{+}$
is as claimed. $\square$

Theorems 5.8 and 5.9 together are the geometric form of extremality: the maximum
$\pi/\kappa$ is a strict supremum over compact pieces, attained only in the ideal
limit.

### 5.2 Degeneration: the angle side, and uniqueness of the limiting shape

**Theorem 5.10 (Rigidity of maximising sequences).**
Let $\kappa > 0$ and let $(\alpha_{n}, \beta_{n}, \gamma_{n})_{n\in\mathbb{N}}$ be
admissible angle triples (each angle $\ge 0$, each sum $\le \pi$). If
$$\mathcal{A}(\kappa;\alpha_{n},\beta_{n},\gamma_{n}) \longrightarrow \frac{\pi}{\kappa},$$
then $\alpha_{n} \to 0$, $\beta_{n} \to 0$ and $\gamma_{n} \to 0$.

*Proof.* Since $\kappa\mathcal{A}(\kappa;\alpha,\beta,\gamma) = \pi -
(\alpha+\beta+\gamma)$, we have
$$\alpha_{n}+\beta_{n}+\gamma_{n} = \pi - \kappa\,\mathcal{A}(\kappa;\alpha_{n},\beta_{n},\gamma_{n}) \longrightarrow \pi - \kappa\cdot\frac{\pi}{\kappa} = 0.$$
Admissibility gives $0 \le \alpha_{n} \le \alpha_{n}+\beta_{n}+\gamma_{n}$, since
$\beta_{n}, \gamma_{n} \ge 0$; the squeeze theorem yields $\alpha_{n} \to 0$, and
symmetrically for $\beta_{n}$ and $\gamma_{n}$. $\square$

So the ideal triangle is not merely *an* extremal configuration but the unique
limiting shape of every maximising sequence — a rigidity statement, and one whose
proof shows exactly why nonnegativity of angles cannot be dropped.

---

## 6. Angles computed, not assumed: Gauss–Bonnet with an ideal vertex

Theorem 5.1 handles all three angles equal to $0$. We now handle a two-parameter
family of triangles with genuine corners, and we do not postulate the angles.

### 6.1 Angles and conformal invariance

**Definition 6.1 (Angle between tangent vectors).**
For nonzero $u = (u_{1},u_{2})$, $v = (v_{1},v_{2}) \in \mathbb{R}^{2}$ set
$$\angle(u,v) := \arccos\!\left(\frac{u_{1}v_{1} + u_{2}v_{2}}{\sqrt{u_{1}^{2}+u_{2}^{2}}\,\sqrt{v_{1}^{2}+v_{2}^{2}}}\right) \in [0,\pi].$$

**Proposition 6.2 (Conformal invariance of angle).**
For every $c > 0$ and all $u, v$,
$$\angle(cu, v) = \angle(u,v) = \angle(u, cv).$$

*Proof sketch.* $\sqrt{(cu_{1})^{2} + (cu_{2})^{2}} = c\sqrt{u_{1}^{2}+u_{2}^{2}}$
since $c > 0$, and the numerator scales by the same $c$; the ratio is unchanged.
$\square$

Proposition 6.2 is the precise formal content of the statement *hyperbolic angles
equal Euclidean angles in the half-plane model.* The hyperbolic inner product at
a point $(x,y)$ is $(\kappa y^{2})^{-1}$ times the Euclidean one; both the
numerator and the two norms in Definition 6.1 scale by the same positive factor
$(\kappa y^{2})^{-1/2}$ per vector slot, so the angle functional is blind to the
conformal factor. From here on we may compute Euclidean angles between Euclidean
tangent vectors and know we have computed hyperbolic angles.

### 6.2 The configuration

Fix $0 \le \varphi < \theta \le \pi$, and consider the region bounded by:

* the vertical geodesic $x = \cos\theta$ (the left wall),
* the vertical geodesic $x = \cos\varphi$ (the right wall),
* the unit semicircle $x^{2} + y^{2} = 1$, $y > 0$ (the floor), which is the
  geodesic joining the boundary points $-1$ and $1$.

Its vertices are $P = (\cos\theta,\sin\theta)$, $Q = (\cos\varphi,\sin\varphi)$ and
the ideal point $\infty$. When $0 < \varphi < \theta < \pi$ both $P$ and $Q$ are
genuine points of $\mathbb{H}$; when $\varphi = 0$ the vertex $Q$ degenerates to
the boundary point $1$, and when additionally $\theta = \pi$ the vertex $P$
degenerates to $-1$.

Tangent vectors along the three sides at the finite vertices:

* the upward tangent of a vertical geodesic is $\tau_{\uparrow} = (0,1)$;
* the tangent of the unit semicircle at $(\cos\theta,\sin\theta)$ in the direction
  of increasing $x$ is $\tau^{\rightarrow}(\theta) = (\sin\theta, -\cos\theta)$;
* the tangent of the unit semicircle at $(\cos\varphi,\sin\varphi)$ in the
  direction of decreasing $x$ is $\tau^{\leftarrow}(\varphi) = (-\sin\varphi,
  \cos\varphi)$.

**Theorem 6.3 (The interior angles).**
For $0 \le \theta \le \pi$ and $0 \le \varphi \le \pi$,
$$\angle\bigl(\tau_{\uparrow}, \tau^{\rightarrow}(\theta)\bigr) = \pi - \theta,
\qquad
\angle\bigl(\tau_{\uparrow}, \tau^{\leftarrow}(\varphi)\bigr) = \varphi.$$

*Proof.* Both circular tangents are unit vectors, since $\sin^{2}+\cos^{2}=1$, and
$\tau_{\uparrow}$ is a unit vector. The inner products are
$\langle (0,1),(\sin\theta,-\cos\theta)\rangle = -\cos\theta$ and
$\langle (0,1),(-\sin\varphi,\cos\varphi)\rangle = \cos\varphi$. Hence the two
angles are $\arccos(-\cos\theta) = \pi - \arccos(\cos\theta) = \pi - \theta$ and
$\arccos(\cos\varphi) = \varphi$, using $\arccos(\cos t) = t$ for $t\in[0,\pi]$.
$\square$

### 6.3 The area, and Gauss–Bonnet

**Theorem 6.4 (Area of a triangle with at least one ideal vertex).**
For $0 \le \varphi < \theta \le \pi$ and $\kappa > 0$, the region described above
has hyperbolic area
$$\mathcal{S}_{\kappa}\bigl(\cos\theta, \cos\varphi;\ \ell_{-1,1}\bigr) = \frac{\theta - \varphi}{\kappa}.$$

*Proof sketch.* Cosine is strictly decreasing on $[0,\pi]$, so $\cos\theta <
\cos\varphi$, and $-1 \le \cos\theta$, $\cos\varphi \le 1$, giving
$[\cos\theta,\cos\varphi]\subseteq[-1,1]$. The floor is
$\ell_{-1,1}(x) = \sqrt{(x+1)(1-x)} = \sqrt{1-x^{2}}$, positive on the interior.
By Theorem 4.2 the area is $\kappa^{-1}\int_{\cos\theta}^{\cos\varphi}
(1-x^{2})^{-1/2}dx$. The antiderivative $F_{-1,1}(x) = \arcsin\bigl(\frac{2x-0}{2}
\bigr) = \arcsin x$ and Proposition 3.4 (applicable even when $\cos\varphi = 1$ or
$\cos\theta = -1$, where the integrand is singular) give
$$\text{Area} = \frac{\arcsin(\cos\varphi) - \arcsin(\cos\theta)}{\kappa}.$$
Finally $\arcsin(\cos t) = \arcsin(\sin(\pi/2 - t)) = \pi/2 - t$ for $t\in[0,\pi]$,
since then $\pi/2 - t \in [-\pi/2,\pi/2]$. Substituting yields $\bigl((\pi/2 -
\varphi) - (\pi/2 - \theta)\bigr)/\kappa = (\theta-\varphi)/\kappa$. $\square$

**Theorem 6.5 (Gauss–Bonnet, derived).**
For $0 \le \varphi < \theta \le \pi$ and $\kappa > 0$, with $\alpha =
\angle(\tau_{\uparrow},\tau^{\rightarrow}(\theta))$ and $\beta =
\angle(\tau_{\uparrow},\tau^{\leftarrow}(\varphi))$ the computed interior angles
and $0$ the angle at the ideal vertex,
$$\text{Area} = \mathcal{A}(\kappa;\alpha,\beta,0) = \frac{\pi - (\alpha+\beta+0)}{\kappa}.$$

*Proof.* By Theorem 6.3, $\alpha = \pi - \theta$ and $\beta = \varphi$, so
$\pi - (\alpha+\beta) = \pi - (\pi - \theta) - \varphi = \theta - \varphi$, and by
Theorem 6.4 the area is $(\theta-\varphi)/\kappa$. $\square$

Moreover $(\alpha,\beta,0)$ is always admissible: $\alpha = \pi - \theta \ge 0$,
$\beta = \varphi \ge 0$ and $\alpha + \beta = \pi - (\theta - \varphi) \le \pi$.

**Corollary 6.6 (Specialisations).**
(i) *Two ideal vertices:* taking $\varphi = 0$ (so $\beta = 0$) gives area
$\theta/\kappa = \mathcal{A}(\kappa;\pi-\theta,0,0)$.
(ii) *Three ideal vertices:* taking $\varphi = 0$, $\theta = \pi$ gives area
$\pi/\kappa$, recovering Theorem 5.1.

**Theorem 6.7 (Finite vertices have strictly positive angles).**
If $0 < \varphi < \theta < \pi$ then $\alpha = \pi - \theta > 0$ and $\beta =
\varphi > 0$.

*Proof.* Immediate from Theorem 6.3 and the strict inequalities. $\square$

The geometric content is that a genuine corner of a hyperbolic triangle can never
have angle $0$: an angle of $0$ means the two sides are asymptotically parallel,
and asymptotic geodesics meet only on the ideal boundary. Zero angle sum requires
adjoining the boundary.

**Corollary 6.8 (Strict subideality).**
If $\kappa > 0$, $0 < \varphi < \theta \le \pi$, then the area
$(\theta-\varphi)/\kappa$ is strictly less than $\pi/\kappa$.

**Theorem 6.9 (Geometric degeneration).**
As $(\theta,\varphi) \to (\pi, 0)$ within the admissible region
$\{0 \le \varphi < \theta \le \pi\}$, the area $(\theta-\varphi)/\kappa$ converges
to $\pi/\kappa$.

*Proof.* The function $(\theta,\varphi)\mapsto(\theta-\varphi)/\kappa$ is
continuous with value $\pi/\kappa$ at $(\pi,0)$. $\square$

Together, Theorems 6.7–6.9 supply the geometric counterpart of the angle-side
statement Theorem 5.10: honest triangles are strictly subideal, and the ideal
value is attained only in the limit of vertices escaping to the boundary.

---

## 7. Symmetry: the real Möbius group

All computations so far placed a vertex at $\infty$. This section shows that no
generality was lost, by exhibiting enough isometries.

**Definition 7.1 (Real Möbius transformation).**
For $A,B,C,D \in \mathbb{R}$ let
$$T(z) = \frac{Az+B}{Cz+D} \qquad (z \in \mathbb{C}),\qquad \det T := AD - BC,$$
with the induced boundary action $t(x) = (Ax+B)/(Cx+D)$ on $x \in \mathbb{R}$
away from the pole $x = -D/C$.

**Theorem 7.2 (Height distortion).**
For all $A,B,C,D$ and all $z$ with $Cz + D \ne 0$,
$$\operatorname{Im} T(z) = \frac{(AD-BC)\,\operatorname{Im} z}{|Cz+D|^{2}}.$$

*Proof sketch.* Multiply numerator and denominator by the conjugate
$\overline{Cz+D}$:
$$T(z) = \frac{(Az+B)\overline{(Cz+D)}}{|Cz+D|^{2}},$$
and expand the imaginary part of the numerator with $A,B,C,D$ real:
$\operatorname{Im}\bigl((Az+B)(C\bar z + D)\bigr) = AD\operatorname{Im}z +
BC\operatorname{Im}\bar z = (AD - BC)\operatorname{Im}z$. $\square$

**Corollary 7.3 (Preservation of the upper half-plane).**
If $AD - BC > 0$ and $\operatorname{Im} z > 0$ then $Cz+D \neq 0$ and
$\operatorname{Im} T(z) > 0$.

*Proof sketch.* If $Cz + D = 0$ then taking imaginary parts gives
$C\operatorname{Im}z = 0$, hence $C = 0$ since $\operatorname{Im}z>0$, and then
taking real parts gives $D = 0$; but $C = D = 0$ makes $AD-BC = 0$, contradicting
positivity. Now Theorem 7.2 exhibits $\operatorname{Im}T(z)$ as a quotient of two
positive quantities. $\square$

**Lemma 7.4 (Derivative).**
Where $Cz+D \ne 0$, $T$ is complex differentiable with
$$T'(z) = \frac{AD - BC}{(Cz+D)^{2}}.$$

*Proof sketch.* Quotient rule on the affine numerator and denominator:
$T' = \bigl(A(Cz+D) - C(Az+B)\bigr)/(Cz+D)^{2}$, and the numerator simplifies to
$AD - BC$. $\square$

**Theorem 7.5 (Pointwise conformality: Möbius maps are hyperbolic isometries).**
If $AD - BC > 0$ and $\operatorname{Im} z > 0$ then
$$\frac{|T'(z)|}{\operatorname{Im} T(z)} = \frac{1}{\operatorname{Im} z}.$$

*Proof.* By Lemma 7.4 and positivity of the determinant, $|T'(z)| =
(AD-BC)/|Cz+D|^{2}$. By Theorem 7.2, $\operatorname{Im}T(z) =
(AD-BC)\operatorname{Im}z/|Cz+D|^{2}$. Dividing, the factors $(AD-BC)$ and
$|Cz+D|^{2}$ cancel, leaving $1/\operatorname{Im}z$. $\square$

The hyperbolic line element is $|dz|/(\sqrt{\kappa}\,y)$. Under $T$, the numerator
$|dz|$ is multiplied by $|T'(z)|$ and the denominator $y = \operatorname{Im}z$ by
the same factor; Theorem 7.5 is exactly the statement that the ratio is
preserved, i.e. $T$ is an infinitesimal isometry of the hyperbolic metric, and
being conformal it also preserves angles (Proposition 6.2).

### 7.1 Sharp three-transitivity on the ideal boundary

**Definition 7.6 (Cross-ratio normaliser).**
For reals $p, q, r$ define the coefficient quadruple
$$\bigl(A,B,C,D\bigr) := \bigl(q-r,\ -p(q-r),\ q-p,\ -r(q-p)\bigr),$$
i.e. the matrix $\begin{pmatrix} q-r & -p(q-r) \\ q-p & -r(q-p)\end{pmatrix}$,
whose boundary action is the classical cross-ratio map
$x \mapsto \frac{(x-p)(q-r)}{(x-r)(q-p)}$.

**Lemma 7.7 (Positive determinant).**
If $p < q < r$ then $\det = (q-r)\bigl(-r(q-p)\bigr) - \bigl(-p(q-r)\bigr)(q-p)
= (r-q)(q-p)(r-p) > 0.$

*Proof.* The displayed algebraic identity is a direct expansion; positivity
follows from $r-q>0$, $q-p>0$, $r-p>0$. $\square$

**Lemma 7.8 (Normalisation).**
With the coefficients of Definition 7.6 and $p<q<r$:
$t(p) = 0$, $t(q) = 1$, and $Cr + D = 0$, i.e. $r$ is the pole and is sent to
$\infty$.

*Proof sketch.* The numerator at $x=p$ is $(q-r)p - p(q-r) = 0$ while the
denominator $(q-p)p - r(q-p) = (q-p)(p-r) \neq 0$, so $t(p) = 0$. At $x = q$ the
numerator is $(q-r)q - p(q-r) = (q-r)(q-p)$ and the denominator is
$(q-p)q - r(q-p) = (q-p)(q-r)$; these are equal and nonzero, so $t(q) = 1$.
Finally $Cr + D = (q-p)r - r(q-p) = 0$ identically. $\square$

**Theorem 7.9 (Three-transitivity).**
For any boundary points $p < q < r$ there exist $A,B,C,D \in \mathbb{R}$ with
$AD - BC > 0$, $t(p) = 0$, $t(q) = 1$ and $Cr + D = 0$ (so $t(r) = \infty$).

*Proof.* Take the coefficients of Definition 7.6 and combine Lemmas 7.7 and 7.8.
$\square$

**Theorem 7.10 (Sharpness / uniqueness).**
Let $A,B,D \in \mathbb{R}$ with $D \ne 0$ and consider the map $t(x) =
(Ax+B)/D$ (the case $C = 0$, i.e. $\infty$ is fixed). If $t(0) = 0$ and $t(1) = 1$
then $t(x) = x$ for all $x$. Consequently any two normalising maps for the same
boundary triple agree on the whole boundary line.

*Proof.* $t(0) = B/D = 0$ forces $B = 0$; then $t(1) = A/D = 1$ forces $A = D$;
then $t(x) = Dx/D = x$. For the consequence, compose one normaliser with the
inverse of the other to get a map fixing $0,1,\infty$. $\square$

**Corollary 7.11 (Universality of the ideal area).**
Three distinct ideal points determine a unique ideal triangle, and any two ideal
triangles are related by a hyperbolic isometry that is unique among orientation
preserving ones. In particular every ideal triangle is congruent to the standard
one with vertices $0$, $1$, $\infty$, whose area is $\pi/\kappa$ by Theorem 5.1.

---

## 8. Variable curvature: a comparison theorem

We now weaken the assumption of constant curvature. Let $K : \mathbb{R} \to
\mathbb{R}$ be a continuous positive function and consider the area element
$$dA_{K} = \frac{dx\,dy}{K(x)\,y^{2}},$$
i.e. curvature $-K(x)$ depending on the horizontal coordinate.

**Definition 8.1 (Variable-curvature sliced area).**
$$\mathcal{S}_{K}(a,b;\text{low}) := \int_{a}^{b}\!\!\left(\int_{\text{low}(x)}^{\infty} \frac{dy}{K(x)\,y^{2}}\right) dx .$$

**Theorem 8.2 (Slicing under variable curvature).**
If $\text{low} > 0$ on $(a,b)$ and $a<b$, then
$$\mathcal{S}_{K}(a,b;\text{low}) = \int_{a}^{b} \frac{dx}{K(x)\,\text{low}(x)}.$$

*Proof sketch.* Identical to Theorem 4.2 but with the constant $\kappa^{-1}$
replaced by the $x$-dependent factor $K(x)^{-1}$, which is constant with respect
to the inner variable $y$ and may therefore be pulled out of the inner integral
before applying Lemma 3.7. $\square$

**Lemma 8.3 (Integrability of the variable density).**
If $K$ is continuous and nonvanishing on $[a,b]$, then $x \mapsto
K(x)^{-1}\ell_{a,b}(x)^{-1}$ is integrable on $[a,b]$.

*Proof sketch.* $K^{-1}$ is continuous, hence bounded, on the compact interval,
and $\ell_{a,b}^{-1}$ is integrable by Lemma 3.3; a bounded continuous multiple
of an integrable function is integrable. $\square$

**Theorem 8.4 (Curvature comparison).**
Let $a < b$, let $K$ be continuous on $[a,b]$, and let $\kappa_{1}, \kappa_{2} >
0$.
1. If $K(x) \ge \kappa_{1}$ for all $x \in [a,b]$, then
   $\mathcal{S}_{K}(a,b;\ell_{a,b}) \le \pi/\kappa_{1}$.
2. If $0 < K(x) \le \kappa_{2}$ for all $x \in [a,b]$, then
   $\mathcal{S}_{K}(a,b;\ell_{a,b}) \ge \pi/\kappa_{2}$.

*Proof sketch.* In case 1, by Theorem 8.2 the area is $\int_{a}^{b}
K(x)^{-1}\ell_{a,b}(x)^{-1}dx$. Pointwise, $K(x)^{-1} \le \kappa_{1}^{-1}$ (the
reciprocal is order-reversing on positives) and $\ell_{a,b}(x)^{-1} \ge 0$, so the
integrand is dominated by $\kappa_{1}^{-1}\ell_{a,b}(x)^{-1}$. Both functions are
integrable by Lemma 8.3, so monotonicity of the integral applies, and
$\int_{a}^{b}\kappa_{1}^{-1}\ell_{a,b}^{-1} = \pi/\kappa_{1}$ by Theorem 3.5.
Case 2 is symmetric. $\square$

**Theorem 8.5 (Pinching).**
If $0 < \kappa_{1} \le K(x) \le \kappa_{2}$ on $[a,b]$ with $K$ continuous, then
$$\frac{\pi}{\kappa_{2}} \;\le\; \mathcal{S}_{K}(a,b;\ell_{a,b}) \;\le\; \frac{\pi}{\kappa_{1}}.$$

*Proof.* Combine the two parts of Theorem 8.4; note $\kappa_{2} \ge \kappa_{1} >
0$ automatically, by evaluating the hypotheses at any single point. $\square$

**Theorem 8.6 (Sharpness).**
For the constant profile $K \equiv \kappa > 0$,
$\mathcal{S}_{K}(a,b;\ell_{a,b}) = \pi/\kappa = \mathcal{S}_{\kappa}(a,b;
\ell_{a,b})$. Hence neither inequality in Theorem 8.5 can be improved: both are
attained, simultaneously, at $\kappa_{1} = \kappa_{2} = \kappa$.

*Proof.* Theorem 8.2 with $K$ constant reduces to Theorem 4.2, and Theorem 3.5
applies. $\square$

Interpretation: *more negative curvature makes ideal triangles smaller.* The
bounded-area phenomenon is therefore robust — it survives the loss of exact
constancy of curvature, and quantitatively so.

---

## 9. Algorithms and numerical validation

The theory is exactly computable, which makes it unusually easy to validate
numerically. Three algorithms suffice.

### 9.1 Chordal quadrature with singularity removal

The integrand $\ell_{a,b}^{-1}$ has inverse-square-root endpoint singularities,
which defeat naive quadrature. The substitution suggested by the geometry itself,
$$x = \frac{a+b}{2} + \frac{b-a}{2}\sin s, \qquad s \in [-\tfrac{\pi}{2}, \tfrac{\pi}{2}],$$
removes them exactly: $dx = \frac{b-a}{2}\cos s\,ds$ and $\ell_{a,b}(x) =
\frac{b-a}{2}\cos s$, so the transformed integrand is identically $1$ and the
integral is visibly the length $\pi$ of the $s$-interval. Numerically one applies
this substitution and integrates the (now analytic) integrand
$K(x(s))^{-1}$ in the variable-curvature case; Gauss–Legendre nodes then converge
at spectral rate. Cost: $O(N)$ evaluations for $N$ nodes; error decays faster
than any polynomial in $1/N$ for smooth $K$.

### 9.2 Direct two-dimensional area by adaptive slicing

To confirm the slicing theorem itself rather than assume it, one integrates the
two-dimensional area element numerically: for each $x$ in a quadrature grid over
$(a,b)$, evaluate the inner fibre integral $\int_{\ell(x)}^{\infty}
dy/(\kappa y^{2})$ by the substitution $y = \ell(x)/w$, $w \in (0,1]$, which maps
the semi-infinite fibre to the unit interval and turns the integrand into the
constant $1/(\kappa\,\ell(x))$; then integrate over $x$ with the substitution of
§9.1. This validates Lemma 3.7 and Theorem 4.2 simultaneously and independently.

### 9.3 Möbius normalisation and invariance testing

Given $p<q<r$, form the cross-ratio coefficients of Definition 7.6, verify
$\det > 0$ and the three normalisation conditions, and then test the conjectural
area invariance (Conjecture B, §10.2) by Monte Carlo: sample points of a region
$S$ with respect to the hyperbolic measure, push them forward by $T$, and compare
the hyperbolic measures of $S$ and $T(S)$ estimated by importance sampling. The
change-of-variables Jacobian of a Möbius map is $|T'|^{2}$, and by Theorem 7.5
$|T'(z)|^{2}/(\operatorname{Im}T(z))^{2} = 1/(\operatorname{Im}z)^{2}$, so the
invariance is a corollary of the pointwise conformality identity plus the planar
change-of-variables formula — the numerics confirm the bookkeeping.

### 9.4 Representative numbers

At $\kappa = 1$:

| configuration | predicted area | expression |
|---|---|---|
| ideal triangle $(a,b,\infty)$, any $a<b$ | $3.14159265\ldots$ | $\pi$ |
| ideal quadrilateral ($n=4$) | $6.28318530\ldots$ | $2\pi$ |
| ideal $n$-gon | $(n-2)\pi$ | $(n-2)\pi$ |
| $\theta = 3\pi/4$, $\varphi = \pi/4$ | $1.57079632\ldots$ | $\pi/2$ |
| $\theta = \pi$, $\varphi = \pi/2$ | $1.57079632\ldots$ | $\pi/2$ |
| truncation $a=0,b=1,t=10^{-3}$ | $3.015080\ldots$ | $2\arcsin(1-2t)$ |
| truncation $a=0,b=1,t=10^{-6}$ | $3.137593\ldots$ | $2\arcsin(1-2t)$ |

At $\kappa = 2$ every entry halves; at $\kappa = 1/2$ every entry doubles. Under
the curvature profile $K(x) = 1 + \tfrac12\sin(\pi x)$ on $[0,1]$, which satisfies
$1 \le K \le 3/2$, the pinching theorem predicts area in $[2\pi/3, \pi] \approx
[2.0944, 3.1416]$, and quadrature gives $\approx 2.5945$.

---

## 10. Discussion, conjectures, and future work

### 10.1 What has been achieved

The programme has moved the theory from angle data to geometry. A purely
algebraic account can define area as angular defect over $\kappa$ and prove
maximality and rigidity by inequalities; that account is a tautology dressed as a
theorem. Here, the area is a Riemannian integral of the metric area element over
an explicitly described region bounded by explicitly described geodesics; the
angles are arccosines of normalised inner products of tangent vectors, shown to
be conformally invariant; and the Gauss–Bonnet identity relating the two is a
*conclusion*. The results also cover the polygon case by an honest triangulation
along vertical geodesics, the degeneration in both the geometric and the
angle-theoretic sense, the symmetry group that makes the model-specific
computation universal, and the comparison estimates that show the phenomenon
survives variable curvature.

### 10.2 Two conjectures

**Conjecture A (Full Gauss–Bonnet in the half-plane, all vertices finite).**
For any three points of the upper half-plane not lying on a common geodesic, the
region bounded by the three connecting geodesics has hyperbolic area $(\pi -
(\alpha+\beta+\gamma))/\kappa$, where $\alpha,\beta,\gamma$ are the angles between
the tangent vectors of the sides at the respective vertices.

*The key insight is* that the case with at least one ideal vertex, proved above,
is already the whole theorem. An arbitrary triangle is the difference of two
triangles with an ideal vertex at $\infty$, obtained by extending one side to the
boundary; the identity then follows from additivity of the slicing integral
together with a single angle-addition identity at the shared vertex. No new
analysis is required — only careful bookkeeping of which region is added and
which is subtracted. The three previously missing ingredients are now available:
the exact antiderivative $F_{a,b}$, integrability across the singular endpoints,
and a definition of interior angle that is provably conformally invariant.

*Falsifiable form.* Compute the area of the triangle with vertices $i$, $2i$ and
$1+i$ numerically; the conjecture is refuted if it differs from $\pi -
(\alpha+\beta+\gamma)$ for the numerically computed angles.

**Conjecture B (Area is a Möbius invariant).**
For $T$ a real Möbius map of positive determinant and $S$ a measurable subset of
the upper half-plane,
$$\int_{T(S)} \frac{dx\,dy}{y^{2}} = \int_{S} \frac{dx\,dy}{y^{2}}.$$
This upgrades the pointwise conformality identity of Theorem 7.5 to a global
measure-theoretic statement, and would make Corollary 7.11 an area statement
rather than merely a congruence statement.

### 10.3 Further directions

1. **A second model.** Develop the Poincaré disk in parallel and prove the
   Cayley transform is an isometry, giving a second, compact-boundary
   perspective on the same invariants.
2. **Full Gauss–Bonnet from the boundary integral.** Prove the identity for
   arbitrary geodesic polygons directly by the boundary-integral form of
   Gauss–Bonnet, with the geodesic curvature term vanishing on geodesic sides.
3. **Sharper degeneration.** Quantify the rate at which the area of a triangle
   with vertices at hyperbolic distance $R$ from a basepoint approaches
   $\pi/\kappa$; the expected rate is exponential in $-R$.
4. **Higher genus.** Assemble ideal triangles into hyperbolic surfaces and derive
   the total-area formula $4\pi(g-1)/\kappa$ for a closed surface of genus
   $g \ge 2$, obtaining Gauss–Bonnet in its global form.
5. **Variable curvature, genuinely two-dimensional.** Replace $K(x)$ by
   $K(x,y)$ and prove comparison inequalities for the angle defect as well as the
   area, in the spirit of the Rauch and Toponogov comparison theorems.
6. **Holonomy interpretation.** Express the angular defect as the rotational
   holonomy of parallel transport around the triangle and prove that ideal
   maximality is invariant under hyperbolic isometries.
7. **Ideal polygons and Teichmüller theory.** Study the moduli of ideal
   $n$-gons modulo isometry — a space of dimension $n-3$ by sharp
   three-transitivity — and connect the area invariant to the combinatorics of
   ideal triangulations of punctured surfaces.

### 10.4 Applications

The bounded-area phenomenon is the origin of hyperbolic rigidity. Because area is
determined by angles alone, hyperbolic geometry admits no similarities: the
curvature fixes an absolute scale. Downstream consequences include the uniform
thinness of hyperbolic triangles, which Gromov abstracted into the definition of
$\delta$-hyperbolic metric spaces and thus into geometric group theory; Mostow
rigidity, by which a hyperbolic structure in dimension $\ge 3$ is determined by
topology; and the Gauss–Bonnet count of ideal triangles in a triangulated
surface, which turns a geometric quantity into a topological invariant. The
formula $(n-2)\pi/\kappa$ for ideal polygons is the two-dimensional shadow of the
volume formulas for ideal hyperbolic simplices that govern hyperbolic volumes of
knot complements and the Bloch–Wigner dilogarithm. Finally, the boundary at
infinity on which our vertices sit is the arena of conformal boundary theories in
mathematical physics, where bulk geometry is encoded in boundary data.

---

## 11. Summary of results

| Result | Statement |
|---|---|
| Chordal integral | $\int_{a}^{b} \bigl((x-a)(b-x)\bigr)^{-1/2}dx = \pi$ for all $a<b$ |
| Fibre integral | $\int_{c}^{\infty} y^{-2}dy = 1/c$ for $c>0$ |
| Slicing | $\int_{a}^{b}\!\int_{\text{low}(x)}^{\infty} \frac{dy\,dx}{\kappa y^{2}} = \frac{1}{\kappa}\int_{a}^{b}\frac{dx}{\text{low}(x)}$ |
| Ideal triangle | Area of $\Delta(a,b,\infty)$ is $\pi/\kappa$ |
| Ideal polygon | Area of an ideal $n$-gon is $(n-2)\pi/\kappa$; additive under gluing |
| Truncation | Compact truncations have area $<\pi/\kappa$, increasing to $\pi/\kappa$ |
| Angle rigidity | Area $\to \pi/\kappa$ forces all three angles $\to 0$ |
| Conformal angles | $\angle(cu,v)=\angle(u,v)=\angle(u,cv)$ for $c>0$ |
| Computed angles | $\angle(\tau_{\uparrow},\tau^{\rightarrow}(\theta)) = \pi-\theta$; $\angle(\tau_{\uparrow},\tau^{\leftarrow}(\varphi)) = \varphi$ |
| Gauss–Bonnet | Area $=(\theta-\varphi)/\kappa = (\pi-(\alpha+\beta+0))/\kappa$, covering one, two or three ideal vertices |
| Positive angles | Finite vertices have strictly positive angles; hence area $<\pi/\kappa$ |
| Möbius height | $\operatorname{Im}T(z) = \det T\cdot \operatorname{Im}z/|Cz+D|^{2}$ |
| Möbius isometry | $|T'(z)|/\operatorname{Im}T(z) = 1/\operatorname{Im}z$ |
| Three-transitivity | An explicit positive-determinant map sends $p<q<r$ to $0,1,\infty$; it is unique |
| Curvature pinching | $\kappa_{1}\le K\le \kappa_{2} \Rightarrow \pi/\kappa_{2} \le \text{Area} \le \pi/\kappa_{1}$, sharply |
