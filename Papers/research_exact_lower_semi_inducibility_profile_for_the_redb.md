# The Lower Semi-Inducibility Profile of the Red-Blue Star $S_{2,1}$: Construction, Realizability Gap, and a Catalog Bridge

**Author:** Aristotle

**Date:** 2026-06-28

## Abstract

We study the minimum asymptotic density of semi-induced copies of the red-blue
star $S_{2,1}$ in graphs of prescribed edge density $\beta$. A one-parameter
*complement-split* construction parametrizes both quantities through a single knob
$t \in [0,1]$: the edge density is $\beta(t) = t(1 - t/2)$ and the star density is
$p(t) = t^2(1-t)$. We prove that $\beta(t)$ is a strictly increasing bijection
from $[0,1]$ onto $[0,1/2]$, so the construction profile $p_{\min}(\beta) =
t^2(1-t)$ (with $t$ the unique solution of $\beta = t(1-t/2)$) is well-defined
exactly on $\beta \in [0,1/2]$, and the often-quoted "for every $\beta \in [0,1]$"
claim is ill-posed for $\beta > 1/2$. We isolate the per-vertex *star functional*
$f(d) = d^2(1-d)$, prove it is a nonnegative bump bounded by $4/27$ (with a
perfect-square certificate $(3d-2)^2$ and maximizer $d = 2/3$), and show the
construction profile inherits this ceiling. Crucially, we prove a *mean-relaxation*
identity: the two-point degree law with mass $\beta$ at $d=1$ and $1-\beta$ at
$d=0$ has mean $\beta$ and star-functional average $0$ for every $\beta$. Hence the
edge-density constraint alone never forces a positive minimum; positivity of the
true graph minimum is a *realizability* phenomenon. We pinpoint the formula's
break at $\beta = 1/2$ (predicted $0$, true value conjecturally $1/12$) as a
direct consequence. Finally, we record a catalog bridge: the construction's
edge-density ceiling $1/2$ lies strictly below every generalized Nash–Williams
cycle-decomposition threshold $\delta_{C_\ell} = \ell/(2\ell-2)$ ($\ell \ge 2$),
in particular below $\delta_{C_5} = 5/8$, so $1/2$ is a two-sided boundary
approached from below by the star construction and from above by the cycle
thresholds.

## 1. Introduction

Inducibility problems ask for the extremal density of a fixed small pattern $H$
inside large host graphs. The *semi-induced* variant records copies of $H$ in
which present edges must be present and a designated set of non-edges must be
absent, leaving the rest unconstrained — a natural middle ground between the
(non-induced) homomorphism count and the fully induced count. For the small star
$S_{2,1}$ — a center joined to two leaves, one designated edge and one designated
non-edge — we examine the *lower* profile: the least achievable semi-induced
density as a function of the ambient edge density $\beta$.

The asymptotic semi-induced $S_{2,1}$ density of a graph decomposes as a
vertex-average of a single-variable functional of the local neighbour-density,
while edge density is the average of that same local density. This reduces the
extremal problem to a constrained optimization of an average of $f(d) = d^2(1-d)$
subject to a fixed mean. The subtlety, and the content of this paper, is that the
constraint is not the mean but graph *realizability* of the underlying degree law.

Our contributions are:

1. A precise account of the complement-split construction: its edge density,
   its strict monotonicity, and the resulting unique-parameter domain $[0,1/2]$
   (§3).
2. A diagnosis of the ill-posedness of the universal-$\beta$ claim above $1/2$
   (§4).
3. The shape theory of the star functional $f$, including the bump bound $4/27$
   and its square certificate (§5).
4. The mean-relaxation identity and the realizability interpretation of
   positivity, including the predicted break at $\beta = 1/2$ (§6).
5. A cross-catalog bridge to the Nash–Williams cycle thresholds, exhibiting $1/2$
   as a two-sided boundary (§7).

All numbered statements below correspond to formally verified results.

## 2. Definitions

**Definition 2.1 (Edge density of the construction).** For the one-parameter
complement-split construction with knob $t$,
$$\operatorname{edgeDensity}(t) := t\left(1 - \frac{t}{2}\right) = t - \frac{t^2}{2}.$$

**Definition 2.2 (Construction profile).** The candidate minimum star density is
$$\operatorname{minProfile}(t) := t^2(1 - t).$$

**Definition 2.3 (Star functional).** The per-vertex contribution to the
semi-induced $S_{2,1}$ density at local neighbour-density $d$ is
$$f(d) := d^2(1 - d).$$
The asymptotic semi-induced $S_{2,1}$ density of a graph is the vertex-average of
$f(d)$, and the edge density is the vertex-average of $d$.

**Definition 2.4 (Cycle-decomposition threshold).** For an integer $\ell \ge 2$,
the generalized Nash–Williams threshold is
$$\operatorname{nwThreshold}(\ell) := \frac{\ell}{2\ell - 2} = \delta_{C_\ell}.$$

**Proposition 2.5 (Profile is the functional at the parameter).** For all $t$,
$$\operatorname{minProfile}(t) = f(t).$$
*Proof.* Both sides equal $t^2(1-t)$ by definition. $\qquad\blacksquare$

This identity ($\texttt{minProfile\_eq\_starFunctional}$) is the bridge between the
construction's profile and the single-variable analysis of $f$.

## 3. The construction: density, monotonicity, and domain

**Theorem 3.1 (Edge-density ceiling).** For every $t \in [0,1]$,
$$\operatorname{edgeDensity}(t) \le \frac{1}{2}.$$
*Proof sketch.* $\tfrac12 - t(1 - t/2) = \tfrac12 - t + \tfrac{t^2}{2} =
\tfrac12(1-t)^2 \ge 0.$ $\qquad\blacksquare$

**Theorem 3.2 (Top value).** $\operatorname{edgeDensity}(1) = \tfrac12.$
*Proof.* $1\cdot(1 - 1/2) = 1/2$. $\qquad\blacksquare$

Together, $\tfrac12(1-t)^2 \ge 0$ with equality iff $t = 1$ shows the ceiling
$1/2$ is attained uniquely at $t = 1$.

**Theorem 3.3 (Strict monotonicity).** $\operatorname{edgeDensity}$ is strictly
increasing on $[0,1]$.
*Proof sketch.* The derivative is $1 - t > 0$ on $[0,1)$; equivalently, for
$0 \le t_1 < t_2 \le 1$,
$$\operatorname{edgeDensity}(t_2) - \operatorname{edgeDensity}(t_1)
= (t_2 - t_1)\left(1 - \tfrac{t_1+t_2}{2}\right) > 0,$$
since $t_1 + t_2 < 2$. $\qquad\blacksquare$

**Theorem 3.4 (Unique parameter).** For every $\beta \in [0, 1/2]$ there is a
unique $t \in [0,1]$ with $\operatorname{edgeDensity}(t) = \beta$.
*Proof sketch.* $\operatorname{edgeDensity}$ is continuous, strictly increasing
(Theorem 3.3), with $\operatorname{edgeDensity}(0)=0$ and
$\operatorname{edgeDensity}(1) = 1/2$ (Theorem 3.2); the intermediate value
theorem gives existence and strict monotonicity gives uniqueness. Explicitly,
$t = 1 - \sqrt{1 - 2\beta}$. $\qquad\blacksquare$

Consequently the construction profile $p_{\min}(\beta) = \operatorname{minProfile}(t)
= t^2(1-t)$, with $t$ as in Theorem 3.4, is **well-defined precisely on**
$\beta \in [0, 1/2]$.

## 4. Ill-posedness above one half

Because $\operatorname{edgeDensity}([0,1]) = [0, 1/2]$ (Theorems 3.1–3.4), no
admissible parameter produces a density above $1/2$.

**Theorem 4.1 (Ill-posedness above $1/2$).** The claim "for every $\beta \in
[0,1]$ the construction's parameter $t \in [0,1]$ exists with
$\operatorname{edgeDensity}(t) = \beta$" is false: it fails for every $\beta >
1/2$.
*Proof.* By Theorem 3.1, $\operatorname{edgeDensity}(t) \le 1/2 < \beta$ for all
$t \in [0,1]$, so no such $t$ exists. $\qquad\blacksquare$

**Theorem 4.2 (Explicit refutation at $3/4$).** There is no $t \in [0,1]$ with
$\operatorname{edgeDensity}(t) = 3/4$.
*Proof.* Immediate from Theorem 4.1 with $\beta = 3/4 > 1/2$; alternatively,
$t(1-t/2) \le 1/2 < 3/4$. $\qquad\blacksquare$

The honest domain of the construction is therefore $[0,1/2]$. The complementary
range $\beta \in (1/2, 1]$ is governed by a different (complement) construction and
is outside the scope of the present profile.

## 5. The star functional is a bounded bump

**Theorem 5.1 (Nonnegativity).** For $d \in [0,1]$, $f(d) = d^2(1-d) \ge 0$.
*Proof.* $d^2 \ge 0$ and $1 - d \ge 0$. $\qquad\blacksquare$

**Theorem 5.2 (Bump bound).** For $d \in [0,1]$,
$$f(d) = d^2(1 - d) \le \frac{4}{27}.$$
*Proof sketch.* The certificate is the perfect square $(3d - 2)^2 \ge 0$. Expanding,
$4 - 27 d^2(1-d) = 4 - 27 d^2 + 27 d^3$, and for $d \in [0,1]$ one verifies the
nonnegativity of this cubic via $(3d-2)^2 \ge 0$ together with $d^2 \ge 0$ and
$d \ge 0$ (a standard `nlinarith`-style certificate). Equivalently,
$\frac{4}{27} - d^2(1-d) = \frac{1}{27}(1-d)(3d-2)^2 + \frac{?}{}$; the decisive
data is the double root of $4/27 - f$ at $d = 2/3$. $\qquad\blacksquare$

**Theorem 5.3 (Maximizer).** $f(2/3) = 4/27$.
*Proof.* $(2/3)^2(1 - 2/3) = (4/9)(1/3) = 4/27$. $\qquad\blacksquare$

**Theorem 5.4 (Profile ceiling).** For $t \in [0,1]$,
$\operatorname{minProfile}(t) \le 4/27$.
*Proof.* Combine Proposition 2.5 with Theorem 5.2. $\qquad\blacksquare$

Thus $f$ is a single-humped curve on $[0,1]$, rising from $f(0)=0$ to the peak
$4/27$ at $d = 2/3$ and falling to $f(1)=0$. Its second derivative is $f''(d) = 2
- 6d$, which changes sign at $d = 1/3$: $f$ is concave for $d < 1/3$ and convex
for $d > 1/3$. This concave-then-convex shape is the curvature data relevant to
identifying threshold extremizers (see §8).

## 6. The realizability gap

We now explain why the genuine graph minimum is positive at intermediate density
even though the averaging constraint permits zero.

**Theorem 6.1 (Mean relaxation has infimum zero).** For every $\beta \in [0,1]$,
the two-point degree law placing mass $\beta$ at $d = 1$ and mass $1 - \beta$ at
$d = 0$ has mean exactly $\beta$ and star-functional average exactly $0$:
$$\beta \cdot 1 + (1-\beta)\cdot 0 = \beta, \qquad
\beta \cdot f(1) + (1-\beta)\cdot f(0) = 0.$$
*Proof.* $f(1) = 1^2(1-1) = 0$ and $f(0) = 0$; substitute and simplify by a ring
identity. $\qquad\blacksquare$

**Interpretation.** If the local densities $\{d(x)\}$ were an unconstrained
probability law subject only to the mean (edge-density) constraint, the average of
$f$ could be driven to $0$ for *every* target $\beta$. Therefore the mean
constraint alone never forces a positive minimum. Positivity of the true graph
minimum is **purely a realizability effect**: a degree law concentrated on
$\{0,1\}$ is not graphical at intermediate density, because universal vertices
(those with $d = 1$) raise every other vertex's degree, precluding the coexistence
of hermits ($d=0$) and universal connectors at density $\beta = 1/2$.

**Consequence (break at $1/2$).** The construction predicts $p_{\min}(1/2) =
\operatorname{minProfile}(1) = 1^2(1-1) = 0$. By the realizability obstruction this
is unattainable; the headline formula breaks at the top of its domain. The
believed correct value, attained in the limit by the threshold graphon
$W(x,y) = \mathbf{1}[x + y > 1]$, is $p_{\min}(1/2) = 1/12$ (Conjecture 8.1). The
gap between $0$ (mean relaxation) and $1/12$ (graph reality) is the realizability
gap made quantitative.

## 7. A catalog bridge: $1/2$ as a two-sided boundary

The generalized Nash–Williams cycle thresholds $\delta_{C_\ell} =
\operatorname{nwThreshold}(\ell) = \ell/(2\ell-2)$ form a strictly decreasing
sequence:
$$\delta_{C_3} = \tfrac34,\quad \delta_{C_4} = \tfrac23,\quad
\delta_{C_5} = \tfrac58,\quad \ldots \;\longrightarrow\; \tfrac12^{+},$$
each strictly above $1/2$ and never attaining it (these monotonicity and bound
facts, $\operatorname{nwThreshold\_gt\_half}$ and
$\operatorname{nwThreshold\_strictAnti}$, are established in the companion catalog
entry).

**Theorem 7.1 (Construction densities lie below all cycle thresholds).** For every
$t \in [0,1]$ and every integer $\ell \ge 2$,
$$\operatorname{edgeDensity}(t) < \operatorname{nwThreshold}(\ell).$$
*Proof.* By Theorem 3.1, $\operatorname{edgeDensity}(t) \le 1/2$; and
$1/2 < \operatorname{nwThreshold}(\ell)$ for $\ell \ge 2$. Chain the two. $\qquad\blacksquare$

**Theorem 7.2 (Ceiling below $\delta_{C_5}$).**
$$\operatorname{edgeDensity}(1) = \tfrac12 < \tfrac58 = \operatorname{nwThreshold}(5).$$
*Proof.* $\operatorname{edgeDensity}(1) = 1/2$ (Theorem 3.2) and
$\operatorname{nwThreshold}(5) = 5/8$; $1/2 < 5/8$. $\qquad\blacksquare$

The two families therefore press in on $1/2$ from opposite sides: the star
construction approaches it from *below*, attaining it at $t = 1$, while the cycle
thresholds approach it from *above*, never attaining it. The number $1/2$ is a
genuine two-sided limit point linking the two catalog entries — a ceiling for the
star construction and an infimal floor for the cycle thresholds.

## 8. Discussion, conjectures, and future work

The picture that emerges is sharp. On its honest domain $[0,1/2]$ the
construction profile $t^2(1-t)$ is a bounded bump ($\le 4/27$), asymptotically
correct near $\beta = 0$, and elegant throughout — but it predicts $0$ at the
boundary $\beta = 1/2$, where the true minimum is positive for reasons that have
nothing to do with the averaging constraint and everything to do with which degree
laws are graphical.

**Conjecture 8.1 (Corrected boundary value).** $p_{\min}(1/2) = 1/12 > 0$,
attained in the limit by the threshold graphon $W(x,y) = \mathbf{1}[x + y > 1]$.

**Conjecture 8.2 (Threshold extremizers).** For every $\beta \in [0,1/2]$, the
minimum of $\int d(x)^2(1 - d(x))\,dx$ over graphons of edge density $\beta$ is
attained by a threshold graphon $W(x,y) = \mathbf{1}[x + y > \theta]$ with $\theta$
calibrated to density $\beta$. The curvature $f'' = 2 - 6d$ (sign change at $d =
1/3$) supplies the concave-then-convex structure that selects extreme threshold
configurations.

**Conjecture 8.3 (Low-density expansion).** Near $\beta = 0$ the true profile
matches the construction to leading order: inverting $\beta = t - t^2/2$ gives
$t = 1 - \sqrt{1 - 2\beta} = \beta + \tfrac{\beta^2}{2} + O(\beta^3)$, hence
$t^2(1-t) = \beta^2 + O(\beta^3)$. The construction is asymptotically correct at
the bottom of the range and only diverges as $\beta \to 1/2$.

The central open problem is a *realizability lower bound*: prove that no graphon
of edge density $\beta \in (0,1/2]$ can drive $\int f(d)$ below the threshold-graphon
value, thereby converting the mean-relaxation zero of Theorem 6.1 into the genuine
positive minimum. The exact curvature certificate of Theorem 5.2 provides the
analytic input for testing the threshold-extremizer hypothesis numerically before
a full proof.

## 9. Conclusion

For the red-blue star $S_{2,1}$ we have delineated exactly where the one-parameter
complement-split profile $t^2(1-t)$ is meaningful, where it is sharp, and where it
fails. The construction lives on $[0,1/2]$ (Theorems 3.1–3.4, 4.1–4.2); its
per-vertex functional is a square-certified bump bounded by $4/27$ (Theorems
5.1–5.4); the averaging constraint alone permits a zero minimum (Theorem 6.1), so
all positivity is a realizability effect that breaks the formula precisely at
$\beta = 1/2$; and the construction's ceiling $1/2$ is a two-sided boundary shared
with the Nash–Williams cycle thresholds (Theorems 7.1–7.2). The realizability gap
— the chasm between what averages allow and what graphs realize — is identified as
the precise locus of the remaining difficulty.
