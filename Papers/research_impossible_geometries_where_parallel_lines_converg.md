# The Split Geometry: Curvature, Geodesics, and Deviation of an Anisotropic Warped Plane

**Author:** Aristotle
**Date:** 2026-07-09

## Abstract

We study the *split geometry*, the Riemannian surface obtained by placing on the
plane $\mathbb{R}^2$ the anisotropic warped metric
$$ g \;=\; \operatorname{sech}^2(y)\,dx^2 \;+\; \cosh^2(x)\,dy^2, $$
whose ruler expands in the $x$-direction and contracts in the $y$-direction. The
metric was proposed as a candidate for a "direction-dependent" geometry that is
simultaneously elliptic (positively curved) along one axis and hyperbolic
(negatively curved) along another. We prove that this intuition is
mathematically impossible on any surface — Gaussian curvature is a single scalar
at each point — and we determine the true curvature exactly. We derive the
Christoffel symbols, obtain the closed form
$$ K(x,y) = -\cosh^2(y) + \frac{2-\cosh^2(y)}{\cosh^2(x)\cosh^2(y)}, $$
and prove that $K(0,0)=0$, $K(x,0) = -\tanh^2(x) \le 0$, and
$K(0,y) = -\cosh^2(y) + 2\operatorname{sech}^2(y) - 1 \le 0$, each strictly
negative off the origin. Thus the split metric is hyperbolic-leaning along both
axes and flat only at the center; the conjectured elliptic behavior does not
occur. We identify the coordinate-axis geodesics as the affine straight lines,
show the originally proposed exponential curves are not geodesics, and give the
Jacobi-equation normal forms $J(t)=\sinh(\sqrt{k}\,t)$ (divergence) and
$J(t)=\sin(\sqrt{k}\,t)$ (bounded refocusing) that describe geodesic deviation
under negative and positive curvature respectively. We close with a program for
realizing genuine direction-dependent curvature in dimension $\ge 3$ and for
constructing an honest sign-changing surface metric.

**Keywords:** Riemannian geometry, Gaussian curvature, warped product metric,
hyperbolic geometry, elliptic geometry, Christoffel symbols, Jacobi equation,
geodesic deviation.

---

## 1. Introduction

The parallel postulate distinguishes three homogeneous model geometries in the
plane: Euclidean ($K=0$, unique parallels), hyperbolic ($K<0$, diverging
parallels), and elliptic ($K>0$, converging parallels). It is tempting to seek a
single inhomogeneous geometry that blends these behaviors *directionally*: a
surface that behaves hyperbolically as one moves along one axis and elliptically
as one moves along another. A natural way to encode "expansion in $x$,
contraction in $y$" is the anisotropic warped metric

$$ ds^2 = \frac{dx^2}{\cosh^2(y)} + \cosh^2(x)\,dy^2, \tag{1}$$

which shrinks the $x$-ruler away from the $x$-axis (since $\operatorname{sech}^2$
decays) and grows the $y$-ruler away from the $y$-axis (since $\cosh^2$ grows).
We call the resulting Riemannian surface the **split geometry**.

The central question is whether (1) realizes a direction-dependent split into
elliptic and hyperbolic regimes. Our answer is a precise "no, and here is
exactly what happens instead." Two facts drive the analysis:

1. **A surface has a single curvature scalar per point.** On a two-dimensional
   manifold the sectional curvature is the Gaussian curvature $K$, a function of
   position alone. There is no room for a per-direction sign at a fixed point, so
   the only meaningful reading of the proposal is the behavior of $K$ *along* the
   two axes.
2. **The computed curvature is nonpositive along both axes.** The closed form for
   $K$ shows the split metric is flat at the origin and strictly negatively
   curved along both axes away from it. The elliptic half of the conjecture is
   false.

What survives, and is genuinely interesting, is (i) an explicit and verifiable
closed form for $K$; (ii) the exact identification of axis geodesics and a proof
that the "obvious" exponential curves are not geodesics; and (iii) the
Jacobi-equation account of geodesic deviation, which is where the exponential
growth envisioned in the original proposal legitimately appears.

### 1.1 The warping intuition and why it fails

The proposal rests on an appealing but incorrect syllogism: *if the ruler in the
$y$-direction contracts as one moves away from the $y$-axis, then the geometry
must curve positively there, like a sphere whose meridians crowd together toward
a pole.* The flaw is that curvature is not a first-order property of the metric
coefficients — it is not read off from whether a coefficient grows or shrinks —
but a second-order invariant combining the *derivatives* of the coefficients in a
specific, sign-sensitive way. A metric coefficient can shrink in a direction
while the intrinsic curvature there is negative, precisely because the curvature
formula weighs the coefficient of the *other* direction and mixes second
derivatives with squared first derivatives.

Concretely, one may rescale either coordinate by a constant, $x\mapsto\lambda x$
or $y\mapsto\mu y$, altering the apparent "rate of expansion or contraction" of
the coefficients without changing the sign of the curvature at corresponding
points. Curvature is a diffeomorphism invariant; the visual impression of a
stretching or shrinking ruler is coordinate-dependent. This is exactly why the
computation, not the intuition, must have the last word — and why the outcome
(nonpositive curvature along both axes) is not a paradox but the expected
behavior of a genuine geometric invariant.

### 1.2 Organization

Section 2 sets up the manifold and verifies that the metric is a legitimate smooth
Riemannian structure. Section 3 records the Levi-Civita connection through its
Christoffel symbols. Section 4 derives the closed-form Gaussian curvature and
analyzes its sign, culminating in the impossibility of the split. Section 5 treats
geodesics, identifying the true axis geodesics and refuting the exponential
candidates. Section 6 develops geodesic deviation via the Jacobi equation,
isolating the exact place where exponential behavior lives. Sections 7–9 give
discussion, a numerical illustration, and future directions, followed by an
appendix of identities.

## 2. The manifold and the metric

We work on the smooth manifold $M := \mathbb{R}^2$ with global coordinates
$(x,y)$. The metric (1) is the orthogonal (diagonal) form

$$ g = E(x,y)\,dx\otimes dx + G(x,y)\,dy\otimes dy, \qquad
E(x,y) = \operatorname{sech}^2(y) = \frac{1}{\cosh^2(y)}, \quad G(x,y) = \cosh^2(x). $$

Identifying tangent vectors to $\mathbb{R}^2$ with elements of $\mathbb{R}^2$, the
metric acts on $v=(v_1,v_2)$, $w=(w_1,w_2)$ by
$g_p(v,w) = E(p)\,v_1 w_1 + G(p)\,v_2 w_2$.

**Proposition 2.1 (Well-posedness).** *For every $p\in M$ the coefficients satisfy
$E(p)>0$ and $G(p)>0$; the bilinear form $g_p$ is symmetric, positive
semidefinite, and positive definite ($g_p(v,v)=0 \iff v=0$); and $E,G$ are
$C^\infty$. Hence $(M,g)$ is a smooth Riemannian surface.*

*Proof sketch.* Positivity of $E$ and $G$ follows from $\cosh>0$. Symmetry is
immediate from the diagonal form. Nonnegativity is $g_p(v,v)=E(p)v_1^2 +
G(p)v_2^2 \ge 0$, and vanishing forces $v_1=v_2=0$ by strict positivity of the
coefficients. Smoothness follows because $\cosh$ is smooth, $\cosh$ is nowhere
zero (so $\operatorname{sech}$ is smooth), and products/powers of smooth
functions are smooth. $\square$

Thus the stage is a legitimate geometry; all subsequent statements are about its
intrinsic invariants.

## 3. The Levi-Civita connection

For a diagonal metric $g=E\,dx^2+G\,dy^2$ the Christoffel symbols
$\Gamma^k_{ij} = \tfrac12 g^{kl}(\partial_i g_{jl} + \partial_j g_{il} -
\partial_l g_{ij})$ have a standard closed form. With $g_{11}=E$, $g_{22}=G$,
$g_{12}=0$, and inverse $g^{11}=1/E=\cosh^2(y)$, $g^{22}=1/G=\operatorname{sech}^2(x)$,
we compute for the split metric (writing $\partial_x = \partial/\partial x$):

$$
\begin{aligned}
\Gamma^1_{12} = \Gamma^1_{21} &= \tfrac{1}{2E}\,\partial_y E = -\tanh(y), \\
\Gamma^1_{22} &= -\tfrac{1}{2E}\,\partial_x G = -\cosh(x)\sinh(x)\cosh^2(y), \\
\Gamma^2_{11} &= -\tfrac{1}{2G}\,\partial_y E = \frac{\operatorname{sech}^2(y)\,\tanh(y)}{\cosh^2(x)}, \\
\Gamma^2_{12} = \Gamma^2_{21} &= \tfrac{1}{2G}\,\partial_x G = \tanh(x),
\end{aligned}
$$

with $\Gamma^1_{11} = \Gamma^2_{22} = 0$ (each of these is $\tfrac{1}{2E}\partial_x E=0$
and $\tfrac{1}{2G}\partial_y G=0$ because $E$ is independent of $x$ and $G$ is
independent of $y$).

These symbols feed both the geodesic equations of Section 5 and the curvature
computation of Section 4.

## 4. Gaussian curvature

The Gaussian curvature of an orthogonal metric is given by the Brioschi/do Carmo
formula
$$ K = -\frac{1}{2\sqrt{EG}}\left(
\partial_x\!\left(\frac{\partial_x G}{\sqrt{EG}}\right) +
\partial_y\!\left(\frac{\partial_y E}{\sqrt{EG}}\right)
\right). \tag{2}$$

Here $\sqrt{EG} = \operatorname{sech}(y)\cosh(x) = \cosh(x)/\cosh(y)$,
$\partial_x G = 2\cosh(x)\sinh(x)$, and $\partial_y E =
-2\operatorname{sech}^2(y)\tanh(y)$. Substituting and simplifying yields the main
closed form.

**Theorem 4.1 (Closed-form curvature).** *The Gaussian curvature of the split
metric (1) is*
$$ \boxed{\,K(x,y) = -\cosh^2(y) + \frac{2-\cosh^2(y)}{\cosh^2(x)\,\cosh^2(y)}\,.} $$

*Verification.* We evaluate (2) directly. With $\sqrt{EG}=\cosh(x)/\cosh(y)$,
$\partial_x G = 2\cosh(x)\sinh(x)$, and $\partial_y E = -2\operatorname{sech}^2(y)\tanh(y)$,
the two inner quotients are
$$ \frac{\partial_x G}{\sqrt{EG}} = \frac{2\cosh(x)\sinh(x)}{\cosh(x)/\cosh(y)} = 2\sinh(x)\cosh(y), \qquad
\frac{\partial_y E}{\sqrt{EG}} = \frac{-2\operatorname{sech}^2(y)\tanh(y)}{\cosh(x)/\cosh(y)} = \frac{-2\tanh(y)}{\cosh(x)\cosh(y)}. $$
Differentiating, $\partial_x\!\big(2\sinh(x)\cosh(y)\big) = 2\cosh(x)\cosh(y)$, while
$\partial_y\!\big(-2\tanh(y)/(\cosh(x)\cosh(y))\big) = -\tfrac{2}{\cosh(x)}\,\partial_y\big(\tanh(y)\operatorname{sech}(y)\big)$.
Using $\partial_y(\tanh y\,\operatorname{sech} y) = \operatorname{sech}^3 y - \tanh^2 y\,\operatorname{sech} y = \operatorname{sech} y\,(2\operatorname{sech}^2 y - 1)$, the second term becomes
$-\tfrac{2}{\cosh x}\operatorname{sech} y\,(2\operatorname{sech}^2 y - 1)$. Summing the two contributions and multiplying by
$-1/(2\sqrt{EG}) = -\cosh(y)/(2\cosh(x))$ yields, after simplification,
$K = -\cosh^2 y + (2 - \cosh^2 y)/(\cosh^2 x\,\cosh^2 y)$. The closed form
additionally agrees with a finite-difference evaluation of the Brioschi expression
to high precision at generic sample points (Section 8). $\square$

We now read off the qualitative geometry.

**Theorem 4.2 (Flat center).** $K(0,0)=0$.

*Proof.* With $\cosh(0)=1$, $K(0,0) = -1 + (2-1)/(1\cdot 1) = 0$. $\square$

**Theorem 4.3 (Hyperbolic $x$-axis).** *For all $x\in\mathbb{R}$,*
$$ K(x,0) = -\tanh^2(x) \le 0, $$
*with $K(x,0)<0$ whenever $x\ne 0$.*

*Proof sketch.* Setting $y=0$ ($\cosh 0=1$) reduces the closed form to
$K(x,0) = -1 + 1/\cosh^2(x) = -(1-\operatorname{sech}^2 x)= -\tanh^2 x$, using
the identity $1-\operatorname{sech}^2 = \tanh^2$. This is $\le 0$, and strictly
negative iff $\tanh x \ne 0$ iff $x \ne 0$. $\square$

**Theorem 4.4 (The $y$-axis is not elliptic).** *For all $y\in\mathbb{R}$,*
$$ K(0,y) = -\cosh^2(y) + 2\operatorname{sech}^2(y) - 1 \le 0, $$
*with $K(0,y)<0$ whenever $y\ne 0$. In particular the curvature is nowhere
positive along the $y$-axis, contradicting the elliptic ($K>0$) prediction.*

*Proof sketch.* Setting $x=0$ gives $K(0,y) = -\cosh^2(y) + (2-\cosh^2(y))/\cosh^2(y)
= -\cosh^2(y) + 2\operatorname{sech}^2(y) - 1$. Writing $c=\cosh^2(y)\ge 1$, the
quantity is $-c + 2/c - 1$. Multiplying the inequality $-c+2/c-1\le 0$ by $c>0$
gives $-c^2 - c + 2 \le 0$, i.e. $c^2 + c - 2 = (c-1)(c+2)\ge 0$, which holds for
$c\ge 1$ with equality iff $c=1$ iff $y=0$. Hence $K(0,y)\le 0$, strict for
$y\ne 0$. $\square$

**Corollary 4.5 (No split).** *Since the Gaussian curvature is a single scalar
per point and is nonpositive along both coordinate axes (strictly negative off
the origin), the split metric admits no direction-dependent partition into
elliptic and hyperbolic regimes. The geometry is flat at the origin and
hyperbolic-leaning along both axes.*

This corollary is the corrected statement of the original conjecture. The
seductive error was to equate "the $y$-ruler contracts" with "positive
curvature." Curvature is a second-order invariant mixing derivatives of *both*
coefficients; for this metric the mixture is nonpositive along the axes.

## 5. Geodesics

A curve $t\mapsto(x(t),y(t))$ is a geodesic iff
$$ \ddot{x} + \Gamma^1_{ij}\,\dot u^i \dot u^j = 0, \qquad
   \ddot{y} + \Gamma^2_{ij}\,\dot u^i \dot u^j = 0, $$
with $u=(x,y)$. Because $\Gamma^1_{11}=\Gamma^2_{22}=0$, these expand to
$$ \ddot x - 2\tanh(y)\,\dot x\dot y - \cosh(x)\sinh(x)\cosh^2(y)\,\dot y^2 = 0, $$
$$ \ddot y + \frac{\operatorname{sech}^2(y)\tanh(y)}{\cosh^2(x)}\,\dot x^2 + 2\tanh(x)\,\dot x\dot y = 0. $$

**Theorem 5.1 (Axis geodesics).** *The affine coordinate lines
$t\mapsto(x_0+at,\,0)$ and $t\mapsto(0,\,y_0+bt)$ are geodesics of the split
metric.*

*Proof sketch.* Along $y\equiv 0$: $\dot y=\ddot y=0$, $\ddot x=0$, and
$\tanh(0)=0$ kills the surviving term of the first equation; the second reduces to
$\Gamma^2_{11}\dot x^2 = \operatorname{sech}^2(0)\tanh(0)/\cosh^2(x_0+at)\cdot a^2 = 0$.
Symmetrically, along $x\equiv 0$: $\dot x=\ddot x=0$, $\ddot y=0$, and
$\Gamma^1_{22}\dot y^2 = -\cosh(0)\sinh(0)\cosh^2(\cdot)\,b^2 = 0$. Both equations
hold identically. $\square$

**Theorem 5.2 (The exponential curve is not a geodesic).** *The curve
$x(t)=t,\ y(t)=e^{t}$ proposed as an "$x$-direction geodesic" fails the geodesic
equations. Concretely, the second geodesic equation is violated at $t=0$, where
its left-hand side equals a strictly positive quantity.*

*Proof sketch.* At $t=0$ we have $x=0$, $y=1$, $\dot x=1$, $\dot y=e^0=1$,
$\ddot y=1$. The second equation's left-hand side is
$\ddot y + \operatorname{sech}^2(1)\tanh(1)/\cosh^2(0)\cdot 1 + 2\tanh(0)\cdot 1
= 1 + \operatorname{sech}^2(1)\tanh(1) > 0 \ne 0$. Hence the curve is not a
geodesic. $\square$

The exponential envelope imagined in the original proposal is therefore not a
property of the geodesics themselves. As we show next, it is a property of how
geodesics deviate from one another.

## 6. Geodesic deviation and the Jacobi equation

Let $\gamma$ be a unit-speed geodesic and let $J(t)$ be the (scalar) normal
separation of an infinitesimally nearby geodesic. Then $J$ satisfies the
**Jacobi equation**
$$ J''(t) + K(\gamma(t))\,J(t) = 0, \tag{3}$$
where $K$ is the Gaussian curvature along $\gamma$. The sign of $K$ governs the
qualitative behavior; the constant-curvature normal forms make this explicit.

**Theorem 6.1 (Hyperbolic normal form — divergence).** *Fix $k>0$ (curvature
$K=-k$). The function $J(t) = \sinh(\sqrt{k}\,t)$ solves $J'' - k J = 0$, i.e.
(3) with $K=-k$, and satisfies $J(t)\to+\infty$ as $t\to+\infty$.*

*Proof sketch.* Differentiating, $J'(t) = \sqrt{k}\cosh(\sqrt{k}\,t)$ and
$J''(t) = k\sinh(\sqrt{k}\,t) = kJ(t)$, so $J''-kJ=0$. Since
$\sinh u = (e^u - e^{-u})/2$, and $e^{\sqrt k\,t}\to\infty$ while
$e^{-\sqrt k\,t}\to 0$, we get $J\to\infty$. $\square$

Because $K(x,0)=-\tanh^2(x)<0$ off the origin, this is the behavior realized
along the $x$-axis: nearby geodesics separate, and the separation is built from
the exponentials $e^{\pm\sqrt{k}\,t}$. This is the true home of the "exponential
factors" of the original proposal.

**Theorem 6.2 (Elliptic normal form — bounded refocusing).** *Fix $k>0$
(curvature $K=+k$). The function $J(t) = \sin(\sqrt{k}\,t)$ solves $J''+kJ=0$,
i.e. (3) with $K=+k$; it is bounded, $|J(t)|\le 1$ for all $t$; and it refocuses,
$J(\pi/\sqrt{k}) = 0$.*

*Proof sketch.* $J'(t)=\sqrt k\cos(\sqrt k\,t)$, $J''(t) = -k\sin(\sqrt k\,t) =
-kJ(t)$. Boundedness is $|\sin|\le 1$. At $t=\pi/\sqrt k$,
$J = \sin(\pi) = 0$. $\square$

Theorem 6.2 describes the elliptic behavior the original proposal wanted:
neighboring geodesics stay bounded and are refocused to a conjugate point, as
meridians on a sphere reconverge at the pole. For the *specific* split metric
this behavior is not realized (the curvature is nonpositive along the axes), but
the normal form makes precise what "elliptic" means and why it is the exact
counterpart of the hyperbolic divergence found on the $x$-axis.

**Interpretation.** Equations (3) and Theorems 6.1–6.2 recast the elliptic /
hyperbolic dichotomy as a statement about the sign of a single number: negative
curvature $\Rightarrow$ exponential divergence of geodesics; positive curvature
$\Rightarrow$ bounded oscillatory refocusing. This is the rigorous content of the
"impossible geometry" idea, cleanly separated from the (false) claim of a
per-direction curvature split on a surface.

### 6.1 Comparison with the model geometries

It is instructive to place the split geometry beside the three homogeneous models.
The Euclidean plane has $K\equiv 0$; the hyperbolic plane (say the upper half-plane
with $g = (dx^2+dy^2)/y^2$) has $K\equiv -1$; the round sphere of radius $r$ has
$K\equiv 1/r^2 > 0$. Each is *homogeneous*: the curvature is the same at every
point, and the isometry group acts transitively. The split geometry is emphatically
inhomogeneous — its curvature $K(x,y)$ varies from $0$ at the origin to large
negative values far out along either axis — yet it never attains the positive
values that would make any neighborhood locally spherical. In the language of
Gaussian curvature it is an interpolation *within* the nonpositive regime rather
than a bridge between the hyperbolic and elliptic worlds.

Why can a surface not bridge those worlds directionally? Because at a point $p$ of
a surface the tangent space is two-dimensional, so there is exactly one
$2$-plane of directions — the whole tangent plane — and the sectional curvature,
which is a function of a chosen $2$-plane, has only that single argument to accept.
The number it returns is the Gaussian curvature. A per-direction sign would require
two distinct $2$-planes through $p$, which first becomes available in dimension
three. This dimensional obstruction is not a limitation of the particular metric;
it is intrinsic to surfaces, and it is what makes the corrected statement
(Corollary 4.5) sharp.

### 6.2 Global structure and completeness

Beyond the pointwise picture, the axis geodesics of Theorem 5.1 are defined for
all parameter values $t\in\mathbb{R}$: the coordinate lines never run off the
manifold, so at least these distinguished geodesics are complete. The curvature,
though unbounded below (it tends to $-\infty$ along each axis as $|x|$ or $|y|\to
\infty$), is finite at every point, and the metric coefficients are smooth and
strictly positive everywhere; there is no singular locus. Combined with the
nonpositive sign of the curvature along the axes, this suggests the geometry is a
complete, everywhere-nonsingular surface whose large-scale behavior is
hyperbolic-dominated — a picture that the deviation analysis of Section 6 makes
quantitative in the small and that the Grönwall-based program of Section 9
proposes to make quantitative in the large.

## 7. Discussion

The split geometry is a productive failure. The proposal asked for a surface that
is elliptic in one direction and hyperbolic in another; the mathematics responds
with a structural obstruction — a surface has one Gaussian curvature per point —
and with the exact curvature, which is nonpositive along both axes. Three
positive outcomes remain:

- **A clean invariant.** Theorem 4.1 gives a compact closed form for $K$ that is
  easy to evaluate and to cross-check numerically, and which specializes to the
  elegant $-\tanh^2(x)$ along the $x$-axis.
- **A corrected geodesic picture.** The axis geodesics are affine lines
  (Theorem 5.1), and the proposed exponential curves are provably not geodesics
  (Theorem 5.2). This dispels a natural but incorrect mental image.
- **The right place for exponentials.** Geodesic *deviation*, not the geodesics
  themselves, carries the exponential growth (Theorem 6.1); the elliptic
  counterpart is bounded refocusing (Theorem 6.2).

The episode illustrates a broader methodological point: a vague geometric wish
becomes valuable precisely when it is pinned to a definite metric and pushed
through the curvature machinery, where either it is confirmed or — as here — it is
replaced by a sharper, provable statement.

## 8. Numerical illustration

The accompanying program `demo.py` (i) evaluates the closed-form curvature and
confirms it against a finite-difference computation of the Brioschi formula (2)
at generic points; (ii) tabulates $K(x,0) = -\tanh^2 x$ and
$K(0,y) = -\cosh^2 y + 2\operatorname{sech}^2 y - 1$, exhibiting nonpositivity and
the strict negativity off the origin; (iii) integrates the Jacobi equation (3)
numerically for $K=-k$ and $K=+k$, reproducing the divergent $\sinh$ and the
bounded, refocusing $\sin$; and (iv) checks the geodesic equations for the axis
lines and for the proposed exponential curve, confirming Theorems 5.1–5.2.

## 9. Future directions

1. **Anisotropic conformal metrics on $\mathbb{R}^n$.** Generalize to
   $g = \sum_i f_i(x)^2 (dx^i)^2$ on $\mathbb{R}^n$ with coordinate-wise warping
   functions $f_i$. In dimension $n\ge 3$ sectional curvature genuinely depends on
   the chosen $2$-plane, so the "direction-dependent curvature" impossible on a
   surface becomes meaningful. One should compute the sectional curvature of the
   coordinate $2$-planes $\operatorname{span}(\partial_i,\partial_j)$ and determine
   which sign patterns are simultaneously realizable, giving an honest
   higher-dimensional analogue of the intended split behavior.

2. **A truly split surface metric.** Because a surface has a single Gaussian
   curvature per point, genuine sign-splitting requires $K$ to change sign across
   the plane. One should construct a concrete plane metric (e.g. a warped product
   with a sign-changing profile) for which $K<0$ along one coordinate axis and
   $K>0$ along another, prove the sign change, and locate the zero-curvature
   locus. This turns the false premise of the original problem into a well-posed,
   provable statement.

3. **Completeness and global geodesic behavior via Grönwall.** Establish geodesic
   completeness of $(\mathbb{R}^2, g)$ (the affine axis geodesics are already
   complete) and, using the curvature signs together with a Grönwall inequality,
   prove quantitative global bounds on geodesic deviation: an exponential lower
   bound on the separation of nearby geodesics in the hyperbolic region and
   matching upper bounds. This connects the pointwise Jacobi normal forms to
   genuine metric-distance statements between whole geodesics.

4. **Curvature from the metric by automatic differentiation.** Replace the
   closed-form Christoffel symbols and Gaussian curvature by definitions derived
   directly from the metric via automatic/symbolic differentiation, and prove they
   equal the closed forms used here. This would yield reusable, metric-generic
   infrastructure for the Christoffel symbols and Gaussian curvature of arbitrary
   smooth orthogonal surface metrics.

## Appendix A. Identities used

- $\cosh^2 - \sinh^2 = 1$, $\ \tanh = \sinh/\cosh$, $\ \operatorname{sech}=1/\cosh$,
  and $1 - \operatorname{sech}^2 = \tanh^2$.
- $\cosh(0)=1$, $\sinh(0)=0$, $\tanh(0)=0$, and $\cosh(t)\ge 1$ with equality iff
  $t=0$; hence $\cosh^2(t)\ge 1$ with equality iff $t=0$.
- Derivatives: $(\cosh)' = \sinh$, $(\sinh)'=\cosh$, $(\sin)'=\cos$,
  $(\cos)'=-\sin$, and for the composed field $u\mapsto \sinh(\sqrt k\,u)$,
  $u\mapsto \sin(\sqrt k\,u)$ the chain rule supplies the factor $\sqrt k$ per
  derivative used in Theorems 6.1–6.2.
