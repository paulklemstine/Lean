# Test Curvature Only After Identifiability

## The Levi-Civita Connection and Gauss Curvature of Concrete Finite-Support Statistical Models

**Author:** Aristotle
**Date:** 2026-08-30

---

## Abstract

We carry out, completely explicitly, the Riemannian geometry of four concrete
two-parameter statistical models and use the results to separate two properties that
are routinely conflated: *exponential statistical sensitivity* and *negative
curvature*.

For the open trinomial simplex $p(x,y) = (x, y, 1-x-y)$ we derive the score
functions as logarithmic derivatives, prove that they are centred, obtain the Fisher
information metric as the score covariance, construct the Levi-Civita connection
through a Koszul-type uniqueness theorem valid over an arbitrary index set, and
compute the Gauss curvature exactly. The answer is the constant $K \equiv +1/4$: the
model is an open piece of the round sphere of radius $2$, not a hyperbolic plane. For
Amari's whole one-parameter family of $\alpha$-connections the curvature scalar is
the quadratic $K_\alpha = (1-\alpha^2)/4$, which is non-negative on the entire
statistically meaningful range $|\alpha| \le 1$ and vanishes exactly at the dually
flat endpoints $\alpha = \pm 1$.

At the same time we prove that the model has maximal statistical sensitivity: the
Hellinger affinity of the $n$-fold product model is exactly $\rho^n$ with
$0 < \rho < 1$ for distinct parameters, so hypotheses separate geometrically fast;
and the Fisher metric coefficients are unbounded on the open parameter domain.
Combining these yields the counterexample: *exponential sensitivity does not imply
negative curvature.* The structural explanation is the Bhattacharyya embedding
$p \mapsto 2\sqrt{p}$, which is an isometry onto the sphere of radius $2$ and
identifies the exponential rate $\rho$ with the cosine of a spherical angle.

To show that finite support does not force any particular sign, we compute two
further models with the same machinery. The $2\times 2$ independence model
$p = (uv, u(1-v), (1-u)v, (1-u)(1-v))$ is identically flat, its Fisher metric being a
product of one-dimensional metrics. The tied two-group model
$p = ((1-s)t, (1-s)(1-t), st^2, s(1-t^2))$, in which the product structure is broken
by a quadratic tie, has curvature $-239/3844 < 0$ at $(s,t) = (1/10, 1/2)$ and
$+6209/42436 > 0$ at $(1/10, 1/10)$. Hence the Fisher–Rao curvature of a
four-outcome, two-parameter model can be positive, zero, negative, or of both signs
on a single model. A negatively curved control — the Poincaré half-plane, run through
the identical pipeline and returning $K \equiv -1$ — calibrates the sign conventions.

**Keywords:** Fisher information metric, Levi-Civita connection, Gauss curvature,
Amari $\alpha$-connections, Hellinger affinity, identifiability, information geometry,
finite-support models.

---

## 1. Introduction

### 1.1 The inference we refute

A widespread heuristic in statistics, machine learning and mathematical physics runs:
a model whose likelihood is exponentially sensitive to its parameters lives on a
negatively curved parameter space; and if the sensitivity rate is uniform, the
curvature is a negative constant. The heuristic has genuine ancestors — hyperbolic
space separates points exponentially, and exponentially separating geodesic flows are
the hallmark of negative curvature — but it is not a theorem, and it is not true.

The purpose of this paper is to settle the matter in the sharpest possible form: by
computing, for the smallest genuinely two-dimensional finite-support model, both the
sensitivity rate and the curvature, exactly, and observing that they point in
opposite directions.

### 1.2 The methodological discipline

The heuristic survives partly because curvature claims are often made in the abstract,
without a derivation. We therefore adopt a staged discipline in which nothing is
postulated:

1. **Identifiability and regularity first.** The score functions are *proved* to be
   the logarithmic derivatives of the model, and *proved* to be centred. Only after
   this is a Fisher metric meaningful.
2. **The metric is derived.** It is defined as the score covariance
   $g_{ij} = \mathbb{E}[s_i s_j]$ and *proved* equal to a closed form.
3. **The derivatives are derived.** Every claimed partial derivative of the metric
   and of the connection is *proved* to be that derivative.
4. **The connection is unique.** A Koszul-type uniqueness theorem shows that the
   torsion-free, metric-compatible connection is the only candidate, so "the
   curvature of the model" is well posed.
5. **The sign convention is calibrated.** A known negatively curved surface is run
   through the identical pipeline.
6. **Only then** is curvature computed and interpreted.

This is the content of the paper's title: *test curvature only after
identifiability*.

### 1.3 Summary of results

| Model | Outcomes | Gauss curvature |
|---|---|---|
| Trinomial simplex $(x, y, 1-x-y)$ | 3 | $K \equiv +1/4$; $\alpha$-family $K_\alpha \equiv (1-\alpha^2)/4$ |
| Poincaré half-plane (control) | — | $K \equiv -1$ |
| $2\times2$ independence model | 4 | $K \equiv 0$ |
| Tied two-group model | 4 | $K(\tfrac1{10},\tfrac12) = -\tfrac{239}{3844} < 0$, $K(\tfrac1{10},\tfrac1{10}) = \tfrac{6209}{42436} > 0$ |

together with: exact tensorisation of the Hellinger affinity, unboundedness of the
Fisher metric, the isometric sphere embedding, and the resulting separation theorem.

---

## 2. Preliminaries: the Fisher metric and the Levi-Civita connection

### 2.1 Statistical models with finite support

**Definition 2.1 (finite-support model).** Let $\mathcal{A}$ be a finite set and
$\Theta \subseteq \mathbb{R}^d$ open. A *finite-support statistical model* is a smooth
map $\theta \mapsto p(\theta) = (p_a(\theta))_{a \in \mathcal{A}}$ with
$p_a(\theta) > 0$ for all $a$ and $\sum_a p_a(\theta) = 1$.

**Definition 2.2 (score functions).** The *scores* of the model are
$$s_i(a; \theta) = \frac{\partial}{\partial\theta_i}\log p_a(\theta), \qquad i = 1,\dots,d.$$

**Lemma 2.3 (centring / regularity).** For a finite-support model,
$\mathbb{E}_\theta[s_i] = \sum_a p_a(\theta) s_i(a;\theta) = 0$ for every $i$.

*Proof sketch.* $\sum_a p_a s_i = \sum_a \partial_i p_a = \partial_i \sum_a p_a =
\partial_i 1 = 0$; the interchange of sum and derivative is legitimate because the sum
is finite. $\square$

Lemma 2.3 is the identifiability/regularity check that must precede any geometric
claim: it is exactly what makes the Fisher metric a *covariance* rather than a mere
second moment.

**Definition 2.4 (Fisher information metric).**
$$g_{ij}(\theta) = \mathbb{E}_\theta[s_i s_j] = \sum_a p_a(\theta)\, s_i(a;\theta)\, s_j(a;\theta).$$
It is symmetric and positive semidefinite; on all models below it is positive
definite, hence a Riemannian metric on $\Theta$.

**Definition 2.5 (Amari–Chentsov skewness tensor).**
$$C_{ijk}(\theta) = \mathbb{E}_\theta[s_i s_j s_k] = \sum_a p_a(\theta)\, s_i(a)s_j(a)s_k(a),$$
a totally symmetric cubic tensor.

### 2.2 Uniqueness of the Levi-Civita connection

Rather than assert the Koszul formula, we prove the algebraic rigidity that underlies
it, in a form independent of dimension or index type.

**Theorem 2.6 (Koszul rigidity).** Let $\iota$ be any index set and let
$D : \iota^3 \to \mathbb{R}$ play the role of $D_{kij} = \partial_k g_{ij}$. Suppose
$G : \iota^3 \to \mathbb{R}$ satisfies
* **torsion-freeness** $G_{ijl} = G_{jil}$ for all $i,j,l$, and
* **metric compatibility** $D_{kij} = G_{kij} + G_{kji}$ for all $k,i,j$.

Then $G$ is uniquely determined:
$$G_{ijl} = \tfrac12\big(D_{ijl} + D_{jil} - D_{lij}\big).$$

*Proof sketch.* Write out the three compatibility relations
$D_{ijl} = G_{ijl} + G_{ilj}$, $D_{jil} = G_{jil} + G_{jli}$,
$D_{lij} = G_{lij} + G_{lji}$. Form the combination
$D_{ijl} + D_{jil} - D_{lij}$ and use symmetry $G_{ilj} = G_{lij}$,
$G_{jli} = G_{lji}$, $G_{jil} = G_{ijl}$ to cancel four of the six terms, leaving
$2G_{ijl}$. The argument is pure linear algebra: no smoothness, dimension, or
finiteness is used. $\square$

Consequently we may *define*, with no loss of canonicity,

**Definition 2.7 (Christoffel symbols).** The symbols of the first and second kind
are
$$\Gamma_{ij,l} = \tfrac12\big(\partial_i g_{jl} + \partial_j g_{il} - \partial_l g_{ij}\big),
\qquad \Gamma^k_{\ ij} = \sum_l g^{kl}\,\Gamma_{ij,l},$$
where $(g^{kl})$ is the inverse metric.

**Definition 2.8 (Riemann tensor and Gauss curvature).** In a two-dimensional chart,
$$R^l_{\ kij} = \partial_i \Gamma^l_{\ jk} - \partial_j \Gamma^l_{\ ik}
 + \sum_m \big(\Gamma^l_{\ im}\Gamma^m_{\ jk} - \Gamma^l_{\ jm}\Gamma^m_{\ ik}\big),$$
$$K = \frac{\sum_l R^l_{\ 1 0 1}\, g_{l 0}}{g_{00}g_{11} - g_{01}g_{10}}.$$
The denominator is $\det g$, so $K$ is the sectional curvature of the (unique)
two-plane, i.e. the Gauss curvature.

**Definition 2.9 (Amari's $\alpha$-connections).** For $\alpha \in \mathbb{R}$,
$$\Gamma^{(\alpha)}_{ij,l} = \Gamma_{ij,l} - \frac{\alpha}{2}\,C_{ijl}.$$
The cases $\alpha = -1, 0, +1$ are the mixture, Levi-Civita and exponential
connections respectively. Curvature of the $\alpha$-connection is defined by
Definition 2.8 applied to $\Gamma^{(\alpha)}$.

---

## 3. The trinomial simplex

### 3.1 The model

**Definition 3.1.** The *open trinomial simplex model* has sample space
$\mathcal{A} = \{1,2,3\}$, parameter domain
$$\Delta^\circ = \{(x,y) \in \mathbb{R}^2 : x > 0,\ y > 0,\ z := 1-x-y > 0\},$$
and probabilities $p(x,y) = (x, y, z)$.

**Proposition 3.2 (scores).** On $\Delta^\circ$ the score functions are
$$s_1 = \Big(\frac1x,\ 0,\ \frac{-1}{z}\Big), \qquad s_2 = \Big(0,\ \frac1y,\ \frac{-1}{z}\Big),$$
and they are centred, $\mathbb{E}[s_1] = \mathbb{E}[s_2] = 0$.

*Proof sketch.* Differentiate $\log$ of each coordinate. For the third coordinate the
chain rule applies to $t \mapsto \log(1-t-y)$, whose derivative is $-1/z$; the first
two coordinates are $\log x$ and $\log y$, constant in the other variable. Centring:
$x\cdot\frac1x + y\cdot 0 + z\cdot\frac{-1}{z} = 0$, and symmetrically. $\square$

**Theorem 3.3 (Fisher metric).** For $(x,y) \in \Delta^\circ$,
$$g = \begin{pmatrix} \frac1x + \frac1z & \frac1z \\[1ex] \frac1z & \frac1y + \frac1z\end{pmatrix},
\qquad \det g = \frac{1}{xyz},
\qquad g^{-1} = \begin{pmatrix} x(1-x) & -xy \\ -xy & y(1-y)\end{pmatrix}.$$

*Proof sketch.* $g_{11} = x\cdot\frac1{x^2} + z\cdot\frac1{z^2} = \frac1x + \frac1z$;
$g_{12} = z\cdot\frac1{z^2} = \frac1z$; symmetrically for $g_{22}$. The determinant is
$(\frac1x+\frac1z)(\frac1y+\frac1z) - \frac1{z^2}
= \frac{1}{xy} + \frac{1}{xz} + \frac{1}{yz} = \frac{x+y+z}{xyz} = \frac{1}{xyz}$.
The stated $g^{-1}$ is verified to be a two-sided inverse directly; note that it is
precisely the multinomial covariance $\delta_{ij}p_i - p_ip_j$. $\square$

**Proposition 3.4 (metric derivatives).** With $z = 1-x-y$,
$$\partial_1 g_{11} = -\frac1{x^2} + \frac1{z^2}, \qquad
\partial_2 g_{22} = -\frac1{y^2} + \frac1{z^2},$$
and every remaining first derivative $\partial_k g_{ij}$ equals $\frac1{z^2}$.

**Theorem 3.5 (mixture-coordinate identity).** On $\Delta^\circ$,
$$\partial_k g_{ij} = -\,C_{ijk}.$$

*Proof sketch.* Both sides are computed in closed form from Proposition 3.4 and
Definition 2.5; e.g. $C_{111} = x\frac1{x^3} + z\frac{-1}{z^3} = \frac1{x^2} -
\frac1{z^2} = -\partial_1 g_{11}$, and $C_{112} = z\cdot\frac{-1}{z^3} = -\frac1{z^2}$,
matching $-\partial_2 g_{11}$. All eight index combinations agree. $\square$

The sign is coordinate-dependent: in the *natural* coordinates of an exponential
family one obtains $+C$ instead. The flip is precisely the $\alpha \mapsto -\alpha$
duality, and $(x,y)$ are mixture coordinates here.

### 3.2 The connection

**Corollary 3.6.** On $\Delta^\circ$ the Levi-Civita symbols of the first kind are
$$\Gamma_{ij,l} = -\tfrac12\, C_{ijl},$$
and they are the unique torsion-free, metric-compatible choice.

*Proof sketch.* By Definition 2.7 and Theorem 3.5,
$\Gamma_{ij,l} = \tfrac12(-C_{jli} - C_{ilj} + C_{ijl})$; total symmetry of $C$
reduces this to $-\tfrac12 C_{ijl}$. Uniqueness is Theorem 2.6 applied with
$D_{kij} = \partial_k g_{ij}$, whose hypotheses hold by symmetry of $\partial_k g_{ij}$
in $(i,j)$ and by the identity $\partial_k g_{ij} = \Gamma_{ki,j} + \Gamma_{kj,i}$
(direct verification). $\square$

**Corollary 3.7 ($\alpha$-collapse).** On $\Delta^\circ$,
$$\Gamma^{(\alpha)}_{ij,l} = \Gamma_{ij,l} - \frac{\alpha}{2}C_{ijl} = (1+\alpha)\,\Gamma_{ij,l}.$$

*Proof.* Substitute $C_{ijl} = -2\Gamma_{ij,l}$ from Corollary 3.6. $\square$

This is a strong structural fact: on the simplex the entire $\alpha$-family is a
*scalar multiple* of a single connection. Because the Riemann tensor is quadratic in
the connection (a linear term in $\partial\Gamma$ plus a quadratic term
$\Gamma\Gamma$), rescaling $\Gamma \mapsto \lambda\Gamma$ makes the curvature a
quadratic polynomial in $\lambda$; Theorem 3.9 identifies which one.

**Proposition 3.8 (second-kind symbols).** Raising with $g^{-1}$ of Theorem 3.3 gives
the closed forms
$$\Gamma^1_{\ 11} = \tfrac12\Big(\frac{x}{z} - \frac1x + 1\Big), \quad
\Gamma^2_{\ 11} = \tfrac12\Big(\frac{y}{z} + \frac{y}{x}\Big), \quad
\Gamma^1_{\ 12} = \Gamma^1_{\ 21} = \frac{x}{2z}, \quad
\Gamma^2_{\ 12} = \Gamma^2_{\ 21} = \frac{y}{2z},$$
$$\Gamma^1_{\ 22} = \tfrac12\Big(\frac{x}{z} + \frac{x}{y}\Big), \quad
\Gamma^2_{\ 22} = \tfrac12\Big(\frac{y}{z} - \frac1y + 1\Big).$$

### 3.3 Curvature

**Theorem 3.9 (curvature of the $\alpha$-family).** For every
$(x,y) \in \Delta^\circ$ and every $\alpha \in \mathbb{R}$,
$$K_\alpha(x,y) = \frac{1 - \alpha^2}{4}.$$

*Proof sketch.* By Corollary 3.7 the $\alpha$-connection of the second kind is
$(1+\alpha)\Gamma^k_{\ ij}$, with derivatives $(1+\alpha)\partial_d\Gamma^k_{\ ij}$.
Substituting into Definition 2.8, the contracted Riemann numerator becomes
$$\sum_l R^{(\alpha)\,l}_{\qquad 1 0 1}\, g_{l0}
= \Big[(1+\alpha) - (1+\alpha)^2\Big]\cdot\!\Big(\text{a fixed rational function}\Big)
= \frac{1-\alpha^2}{4}\cdot\frac{1}{xyz},$$
where the linear-in-$\Gamma$ part scales as $(1+\alpha)$ and the quadratic part as
$(1+\alpha)^2$. Explicit substitution of Proposition 3.8 and its derivatives, followed
by clearing denominators over $x$, $y$, $z$, yields the numerator
$\frac{1-\alpha^2}{4}\cdot\frac{1}{xyz}$ exactly. Dividing by $\det g = 1/(xyz)$
(Theorem 3.3) leaves the constant $(1-\alpha^2)/4$. $\square$

**Theorem 3.10 (main computation).** The Gauss curvature of the Fisher–Rao metric on
the open trinomial simplex is the constant
$$K(x,y) = \frac14 \qquad \text{for all } (x,y) \in \Delta^\circ.$$

*Proof.* Set $\alpha = 0$ in Theorem 3.9. $\square$

**Corollary 3.11 (dual flatness).** $K_{+1} = K_{-1} = 0$: the exponential and
mixture connections are flat. This recovers Amari's dual flatness of the simplex as a
special case of a single quadratic identity.

**Corollary 3.12 (sign of $K_\alpha$).** $K_\alpha \ge 0$ if and only if
$|\alpha| \le 1$, and $K_\alpha < 0$ if and only if $|\alpha| > 1$. Within the
statistically meaningful range of $\alpha$, no negative curvature occurs anywhere.

**Corollary 3.13 (no negative curvature).** There is no point of $\Delta^\circ$ at
which $K < 0$, and for no constant $c < 0$ is $K \equiv c$ on $\Delta^\circ$.

*Proof.* $K \equiv 1/4 > 0$; evaluate at $(1/3, 1/3)$ for the second claim. $\square$

### 3.4 Calibration: the negatively curved control

A reader may reasonably suspect an index or sign convention error, given that a
"blow-up at the boundary" intuitively suggests hyperbolicity.

**Theorem 3.14 (calibration).** Applying Definitions 2.7 and 2.8 verbatim to the
Poincaré upper half-plane metric $g = y^{-2}(dx^2 + dy^2)$ yields
$$\Gamma^1_{\ 12} = \Gamma^1_{\ 21} = -\tfrac1y, \quad
\Gamma^2_{\ 11} = \tfrac1y, \quad
\Gamma^2_{\ 22} = -\tfrac1y, \quad \text{others } 0,$$
and $K \equiv -1$.

*Proof sketch.* Only $\partial_2 g_{11} = \partial_2 g_{22} = -2/y^3$ is nonzero, so
the first-kind symbols are $\Gamma_{11,2} = 1/y^3$, $\Gamma_{12,1} = \Gamma_{21,1} =
-1/y^3$, $\Gamma_{22,2} = -1/y^3$. Raising with $g^{-1} = y^2 I$ gives the stated
symbols. Then $R^1_{\ 101} = \partial_0\Gamma^1_{\ 11} - \partial_1\Gamma^1_{\ 01} +
\dots = -1/y^2$ after cancellation, and dividing the contraction by
$\det g = y^{-4}$ returns $-1$. $\square$

Hence the sign convention is calibrated: the $+1/4$ of Theorem 3.10 is genuine
positive curvature. In particular no point of the half-plane has the same curvature as
any point of the simplex, so the two surfaces are nowhere locally isometric.

### 3.5 The structural explanation: the sphere of radius 2

**Definition 3.15 (Bhattacharyya embedding).**
$\Phi(x,y) = 2\big(\sqrt{x}, \sqrt{y}, \sqrt{z}\big) \in \mathbb{R}^3$.

**Theorem 3.16.** For all $(x,y) \in \Delta^\circ$:
1. $\|\Phi(x,y)\|^2 = 4$, so $\Phi$ maps into the Euclidean sphere of radius $2$;
2. the Euclidean pullback of $\Phi$ is exactly the Fisher metric:
   $\sum_a \partial_i\Phi_a\,\partial_j\Phi_a = g_{ij}$.

*Proof sketch.* (1) $\sum_a 4 p_a = 4$. (2) The partial derivatives are
$\partial_1\Phi = (1/\sqrt x, 0, -1/\sqrt z)$ and
$\partial_2\Phi = (0, 1/\sqrt y, -1/\sqrt z)$, whence
$\langle \partial_1\Phi, \partial_1\Phi\rangle = \frac1x + \frac1z$,
$\langle \partial_1\Phi, \partial_2\Phi\rangle = \frac1z$,
$\langle \partial_2\Phi, \partial_2\Phi\rangle = \frac1y + \frac1z$,
matching Theorem 3.3. $\square$

Since a round sphere of radius $r$ has $K = 1/r^2$, Theorem 3.16 explains Theorem 3.10
conceptually: $K = 1/2^2 = 1/4$. It also dissolves the intuition behind the
hyperbolic rumour. The blow-up of $g_{11} = 1/x + 1/z$ as $x \to 0$ is a
*chart* degeneracy — the analogue of latitude–longitude near a pole — not a geometric
singularity. The surface is uniformly round.

---

## 4. Identifiability: exponential sensitivity with positive curvature

### 4.1 Unbounded sensitivity

**Theorem 4.1 (unboundedness).** For every $M \in \mathbb{R}$ there exists
$(x,y) \in \Delta^\circ$ with $g_{11}(x,y) > M$.

*Proof sketch.* Put $c = \max(M, 0)$ and take $x = 1/(c+4)$, $y = 1/4$; then
$0 < x \le 1/4$, so $z = 1 - x - 1/4 > 0$, and
$g_{11} = (c+4) + 1/z > c \ge M$. $\square$

So the model *is* arbitrarily sensitive on its open domain — and by Theorem 3.10 this
carries no consequence at all for the sign of the curvature.

### 4.2 Exact tensorisation of the Hellinger affinity

**Definition 4.2.** For parameters $\theta = (x,y)$ and $\theta' = (x', y')$ in
$\Delta^\circ$, the *Hellinger affinity* is
$\rho(\theta, \theta') = \sum_{a} \sqrt{p_a(\theta) p_a(\theta')}$. For $n \in
\mathbb{N}$ the $n$-fold i.i.d. product model on $\{1,2,3\}^n$ is
$p^{(n)}_\omega(\theta) = \prod_{i=1}^n p_{\omega_i}(\theta)$.

**Theorem 4.3 (tensorisation).** For all $n$,
$$\sum_{\omega \in \{1,2,3\}^n} \sqrt{p^{(n)}_\omega(\theta)\, p^{(n)}_\omega(\theta')}
= \rho(\theta,\theta')^n.$$

*Proof sketch.* By positivity, $\sqrt{\prod_i p_{\omega_i}(\theta)\prod_i
p_{\omega_i}(\theta')} = \prod_i \sqrt{p_{\omega_i}(\theta)}\sqrt{p_{\omega_i}(\theta')}$.
Summing a product over all $\omega$ factorises the sum coordinatewise (the
multinomial-expansion identity $\sum_{\omega}\prod_i f(\omega_i) = (\sum_a f(a))^n$),
giving $\rho^n$. $\square$

**Lemma 4.4 (Hellinger identity).**
$\rho(\theta,\theta') = 1 - \tfrac12\sum_a\big(\sqrt{p_a(\theta)} -
\sqrt{p_a(\theta')}\big)^2$.

*Proof.* Expand the square and use $\sum_a p_a(\theta) = \sum_a p_a(\theta') = 1$.
$\square$

**Theorem 4.5 (strict contraction).** If $\theta \ne \theta'$ (say $x \ne x'$) then
$0 < \rho(\theta,\theta') < 1$.

*Proof sketch.* Positivity: every summand $\sqrt{p_a p'_a} > 0$. Strict upper bound:
$x \ne x'$ with both positive gives $\sqrt{x} \ne \sqrt{x'}$, so the first term of the
sum in Lemma 4.4 is strictly positive while the others are non-negative. $\square$

**Corollary 4.6 (exponential distinguishability).** For distinct parameters the
affinity of the $n$-fold product model equals $r^n$ with $r = \rho \in (0,1)$ and
therefore tends to $0$ geometrically as $n \to \infty$.

### 4.3 The affinity is a spherical cosine

**Theorem 4.7.** $\displaystyle \rho(\theta,\theta') =
\frac{\langle \Phi(\theta), \Phi(\theta')\rangle}{4}$, the cosine of the angle
subtended at the centre by the two points on the sphere of radius $2$. Consequently the
Fisher–Rao geodesic distance between them is $2\arccos\rho$.

*Proof.* $\langle \Phi(\theta), \Phi(\theta')\rangle = \sum_a 4\sqrt{p_a p'_a} = 4\rho$;
the great-circle distance on a sphere of radius $r$ subtending angle $\vartheta$ is
$r\vartheta$, here $2\arccos\rho$. $\square$

This is the conceptual heart of the refutation. The exponential rate $\rho$ that
governs statistical distinguishability is *literally a cosine on a positively curved
surface*. The geometric decay $\rho^n$ arises from the product construction — from
multiplying $n$ copies of a number below $1$ — and not from any hyperbolicity of the
parameter space. It would occur identically for a flat or a spherical model.

### 4.4 The separation theorem

**Theorem 4.8 (separation).** Let $\theta \ne \theta'$ be two points of
$\Delta^\circ$. Then:
1. there is $r \in (0,1)$ with $\displaystyle \sum_\omega
   \sqrt{p^{(n)}_\omega(\theta)p^{(n)}_\omega(\theta')} = r^n$ for every $n$ —
   exponential statistical sensitivity; and
2. $K(\theta) = K(\theta') = \tfrac14 > 0$ — constant *positive* curvature.

*Proof.* Combine Theorems 4.3, 4.5 and 3.10. $\square$

**Corollary 4.9.** The implication "exponential sensitivity $\Rightarrow$ negative
(let alone constant negative) Fisher–Rao curvature" is false. It fails on the smallest
non-trivial finite-support model.

---

## 5. Finite support does not determine the sign

Theorem 3.10 might be read as suggesting that finite support forces *positive*
curvature. It does not. We compute two more models with the same pipeline.

### 5.1 A flat model: $2\times 2$ independence

**Definition 5.1.** The *$2\times 2$ independence model* has four outcomes and
$$p(u,v) = \big(uv,\ u(1-v),\ (1-u)v,\ (1-u)(1-v)\big), \qquad (u,v) \in (0,1)^2,$$
two independent Bernoulli coordinates.

**Proposition 5.2.** Its scores are
$s_1 = \big(\tfrac1u, \tfrac1u, \tfrac{-1}{1-u}, \tfrac{-1}{1-u}\big)$,
$s_2 = \big(\tfrac1v, \tfrac{-1}{1-v}, \tfrac1v, \tfrac{-1}{1-v}\big)$, and the Fisher
metric is the diagonal product metric
$$g = \operatorname{diag}\!\left(\frac{1}{u - u^2},\ \frac{1}{v - v^2}\right).$$

*Proof sketch.* $g_{11} = u\cdot\frac1{u^2} + (1-u)\cdot\frac1{(1-u)^2} =
\frac{1}{u(1-u)}$ after summing the four terms in pairs; $g_{22}$ symmetrically; and
$g_{12} = \sum_a p_a s_1 s_2$ factorises as $\big(\sum \text{Bernoulli score}\big)
\cdot\big(\sum \text{Bernoulli score}\big) = 0$ by centring. $\square$

**Theorem 5.3 (flatness).** $K(u,v) = 0$ for all $(u,v) \in (0,1)^2$.

*Proof sketch.* Because $g_{11}$ depends only on $u$ and $g_{22}$ only on $v$, the
only nonvanishing metric derivatives are $\partial_1 g_{11}$ and $\partial_2 g_{22}$.
Hence the only nonzero second-kind symbols are $\Gamma^1_{\ 11}$ and $\Gamma^2_{\ 22}$,
each a function of its own variable alone. In the Riemann tensor
$R^l_{\ 101}$ every surviving term contains either a derivative of a symbol with
respect to the *other* variable, or a product $\Gamma^l_{\ im}\Gamma^m_{\ jk}$ with
mixed indices; all of them vanish. $\square$

The conceptual reason is factorisation: the metric is a Riemannian product of two
one-dimensional metrics, and one-dimensional metrics are flat. Explicitly, the
substitution $u = \sin^2(\phi/2)$, $v = \sin^2(\psi/2)$ turns $g$ into
$d\phi^2 + d\psi^2$, a Euclidean rectangle.

### 5.2 A sign-changing model: the tied two-group Bernoulli family

**Definition 5.4.** In the *tied two-group model* an individual belongs to group $A$
with probability $1-s$ and then succeeds with probability $t$, or to group $B$ with
probability $s$ and then succeeds with probability $t^2$ — the *same* parameter,
squared. The four outcome probabilities are
$$p(s,t) = \big((1-s)t,\ (1-s)(1-t),\ s t^2,\ s(1-t^2)\big), \qquad (s,t) \in (0,1)^2.$$

**Proposition 5.5 (metric).** The scores are
$$s_1 = \Big(\tfrac{-1}{1-s}, \tfrac{-1}{1-s}, \tfrac1s, \tfrac1s\Big), \qquad
s_2 = \Big(\tfrac1t, \tfrac{-1}{1-t}, \tfrac2t, \tfrac{-2t}{1-t^2}\Big),$$
and the Fisher metric is diagonal,
$$g = \operatorname{diag}\!\left(\frac{1}{s - s^2},\ \frac{N}{t - t^3}\right),
\qquad N = N(s,t) = (1-s) + (1+3s)t.$$

*Proof sketch.* $g_{11}$ is the Bernoulli information of the group indicator.
$g_{12} = 0$ because, conditionally on the group, the second score is centred within
each group and the first score is constant on each group. For $g_{22}$, summing
$(1-s)t\cdot\frac1{t^2} + (1-s)(1-t)\cdot\frac1{(1-t)^2} + st^2\cdot\frac4{t^2} +
s(1-t^2)\cdot\frac{4t^2}{(1-t^2)^2}$ and clearing denominators over
$t(1-t)(1+t) = t - t^3$ produces the numerator $N$. $\square$

The tie is exactly what breaks the product structure of §5.1: $g_{22}$ now depends on
$s$ as well as $t$.

**Theorem 5.6 (connection).** The nonvanishing second-kind symbols are
$$\Gamma^1_{\ 11} = \frac{2s-1}{2(s-s^2)}, \qquad
\Gamma^1_{\ 22} = \frac{(s^2-s)(3t-1)}{2(t-t^3)}, \qquad
\Gamma^2_{\ 12} = \Gamma^2_{\ 21} = \frac{3t-1}{2N},$$
$$\Gamma^2_{\ 22} = \frac{2(1+3s)t^3 + 3(1-s)t^2 - (1-s)}{2N\,(t-t^3)}.$$
They are torsion-free and metric-compatible, hence by Theorem 2.6 they are *the*
Levi-Civita connection.

**Theorem 5.7 (sign change).** The Gauss curvature of the tied two-group model
satisfies
$$K\!\left(\tfrac1{10}, \tfrac12\right) = -\frac{239}{3844} \approx -0.062175 < 0,
\qquad
K\!\left(\tfrac1{10}, \tfrac1{10}\right) = \frac{6209}{42436} \approx +0.146314 > 0.$$
Consequently there is no constant $c$ with $K \equiv c$ on $(0,1)^2$.

*Proof sketch.* Substitute Theorem 5.6 and its partial derivatives into Definition
2.8; at each of the two rational parameter points every quantity is an exact rational
number, and the contraction divided by $\det g$ evaluates to the stated fractions.
Non-constancy follows because the two values differ. $\square$

Numerical evaluation of $K$ over the whole square indicates a striking picture of its
zero set: it consists of the horizontal line $t = 1/3$ — exactly where the factor
$3t - 1$ appearing in $\Gamma^1_{\ 22}$ and $\Gamma^2_{\ 12}$ vanishes — together with
a single monotone curve $s = \sigma(t)$ descending from $\sigma(0.05) \approx 0.696$
to $\sigma(0.95) \approx 0.417$. The two cross near $(s, t) \approx (0.497, 1/3)$, and
the curvature alternates in sign across the four resulting regions: positive for
$(s,t) = (0.1, 0.1)$ and $(0.9, 0.9)$, negative for $(0.1, 0.5)$ and $(0.9, 0.05)$. In
particular negative Fisher–Rao curvature *does* occur for finite-support models — it is
simply not implied by anything about the support or the sensitivity.

### 5.3 The trichotomy

**Theorem 5.8 (curvature trichotomy).** Among two-parameter statistical models with
at most four outcomes, the Fisher–Rao Gauss curvature attains strictly positive,
exactly zero, and strictly negative values:
* the trinomial simplex has $K \equiv +1/4 > 0$;
* the $2\times2$ independence model has $K \equiv 0$;
* the tied two-group model has $K(1/10, 1/2) = -239/3844 < 0$.

Moreover one single model — the tied one — already realises both signs. Hence neither
the number of outcomes nor the number of parameters determines the sign of the
curvature, and "the curvature of a finite-support model" is not a well-defined
quantity.

---

## 6. Algorithms

The computations above follow one reusable pipeline. We record it as an algorithm
because it is exactly what any curvature claim about a concrete model should be
required to run.

### 6.1 The staged curvature pipeline

**Input.** A finite-support model $\theta \mapsto p(\theta)$ on $|\mathcal{A}|$
outcomes with a two-dimensional open parameter domain.

**Stage 0 (identifiability).** Verify $p_a > 0$ for all $a$ on the domain; compute the
scores $s_i = \partial_i \log p_a$; verify $\sum_a p_a = 1$ and $\sum_a p_a s_i = 0$.
*Abort if either fails* — no Fisher metric, hence no curvature, is defined.

**Stage 1 (metric).** Form $g_{ij} = \sum_a p_a s_i s_j$; verify $\det g \ne 0$ on the
domain; invert.

**Stage 2 (derivatives).** Differentiate $g$; verify the derivative formulas
symbolically or by an independent finite-difference check.

**Stage 3 (connection).** Form $\Gamma_{ij,l} = \tfrac12(\partial_i g_{jl} + \partial_j
g_{il} - \partial_l g_{ij})$ and raise: $\Gamma^k_{\ ij} = g^{kl}\Gamma_{ij,l}$. Verify
torsion-freeness $\Gamma^k_{\ ij} = \Gamma^k_{\ ji}$ and metric compatibility
$\partial_k g_{ij} = \Gamma_{ki,j} + \Gamma_{kj,i}$; by Theorem 2.6 these two checks
*certify* that the connection is the Levi-Civita one.

**Stage 4 (curvature).** Differentiate $\Gamma$, assemble $R^l_{\ kij}$, contract, and
divide by $\det g$.

**Stage 5 (calibration).** Run Stages 1–4 on a reference surface of known curvature —
the Poincaré half-plane, returning $-1$ — before interpreting any sign.

**Cost.** With $d = 2$ parameters and $m$ outcomes, Stage 1 costs $O(m d^2)$ arithmetic
operations, Stage 3 $O(d^4)$, Stage 4 $O(d^4)$; symbolically the cost is dominated by
rational-function simplification, which for these models is a handful of common
denominators over $x$, $y$, $z$ (resp. $s$, $t$). Numerically, with central
differences, the whole pipeline is $O(m d^2)$ per evaluation point with a
second-order accurate result.

### 6.2 The $\alpha$-curvature shortcut

When a model satisfies the mixture identity $\partial_k g_{ij} = -C_{ijk}$ — as the
simplex does — Stages 3 and 4 need only be run once. Corollary 3.7 gives
$\Gamma^{(\alpha)} = (1+\alpha)\Gamma$, so with $A$ the linear (derivative) part and
$B$ the quadratic part of the contracted Riemann numerator at $\alpha = 0$, the
$\alpha$-curvature is $\big[(1+\alpha)A + (1+\alpha)^2 B\big]/\det g$, a quadratic in
$\alpha$ determined by its values at any three points. For the simplex the resulting
quadratic is $(1-\alpha^2)/4$, which one may check by evaluating only at
$\alpha = -1, 0, 1$.

---

## 7. Discussion

### 7.1 What went wrong with the heuristic

Three distinct phenomena were being conflated.

*Coordinate blow-up.* The Fisher metric of the simplex diverges at the boundary of
the parameter triangle. This is real (Theorem 4.1) but is a chart artefact: the sphere
embedding (Theorem 3.16) shows the surface is uniformly round. Divergence of metric
*coefficients* says nothing about curvature.

*Exponential separation of hypotheses.* This is real, exact and uniform (Theorem 4.3).
But it comes from independence — the tensorisation of the affinity — and its rate is a
*cosine* of a spherical angle (Theorem 4.7). It is a positively curved quantity.

*Negative curvature.* This is a statement about the second derivatives of the metric
tensor, and it can be checked only by computing them. Doing so gives $+1/4$.

The analogy with Anosov dynamics, where exponential separation genuinely does come
with negative curvature, does not transfer: there the exponential rate is a property of
*geodesics in the manifold*, whereas here it is a property of *products of
distributions*, an entirely different construction that happens to also produce
exponentials.

### 7.2 Flatness as factorisation

A pattern emerges across the models. The independence model is flat precisely because
its Fisher metric factorises into one-dimensional pieces (§5.1). The tied model is
curved precisely because the tie $t \mapsto t^2$ destroys that factorisation, making
$g_{22}$ depend on $s$ (§5.2). The simplex is curved for a different reason: it is not
a product at all, and its curvature is the extrinsic curvature of the ambient sphere
transferred by an isometry.

This suggests a general slogan: for Fisher–Rao geometry, *curvature measures the
failure of parameters to be statistically decoupled*, with the extrinsic sphere
curvature $1/4$ as the baseline.

### 7.3 The role of the $\alpha$-family

The identity $K_\alpha = (1-\alpha^2)/4$ is unusually clean. Its content is:
* the simplex is dually flat at $\alpha = \pm 1$ (Amari's theorem);
* between the endpoints the curvature is a *concave parabola* peaking at the
  Levi-Civita value $1/4$;
* the family never enters the negatively curved regime for statistically meaningful
  $\alpha$.

The proof of the last point is entirely structural: the collapse
$\Gamma^{(\alpha)} = (1+\alpha)\Gamma$ (Corollary 3.7) makes the degree-$2$ polynomial
dependence inevitable, and the two known flat endpoints then pin the quadratic down to
$(1-\alpha^2)/4$ up to the leading coefficient, which the $\alpha = 0$ value fixes.
That is, the curvature of the entire $\alpha$-family is determined by three numbers.

### 7.4 Practical consequences

For anyone modelling a parameter space geometrically — natural-gradient optimisation,
hyperbolic embeddings of hierarchies, geometry-aware MCMC, information-geometric
statistical mechanics — the message is operational:

1. **Establish identifiability first.** Positivity, honest scores, centring, and
   $\det g \ne 0$. Without them the Fisher "metric" is not a metric.
2. **Do not infer curvature from sensitivity.** Sensitivity is a first-order property
   of the metric; curvature is a second-order property of its derivatives.
3. **Compute the curvature and calibrate the sign** on a reference space.
4. **Expect the answer to be model-specific.** By Theorem 5.8 it varies not only across
   models with identical support size but within a single model.

If your architecture assumes a hyperbolic parameter space, the assumption needs a
computation, not an analogy. And if the underlying model is a categorical distribution
— as it is in a great many machine-learning settings — the honest answer is that the
geometry is *spherical*, and a hyperbolic embedding is fighting the metric rather than
following it.

---

## 8. Future work

**Nonexistence of constant negative curvature for finite-support models.** We
conjecture that no two-parameter finite-support model with everywhere-positive
probabilities has Fisher–Rao Gauss curvature equal to a constant $c < 0$ on an open
parameter set. The mechanism is Theorem 3.16: every finite-support model with $m$
outcomes is an immersed surface in the sphere of radius $2$ in $\mathbb{R}^m$ (via
$p \mapsto 2\sqrt p$), so by the Gauss equation its intrinsic curvature is
$1/4 + \det(\mathrm{II})$. Realising a *constant* negative value forces the second
fundamental form to have constant determinant $c - 1/4$, a strong Codazzi obstruction
for immersions that are algebraic (polynomial) in $p$. The tied model shows negative
values occur; the conjecture is that constant negative values do not.

**Classification of flat finite-support models.** §5.1 and §5.2 suggest that
Fisher-flatness of a two-parameter finite-support model is equivalent to a
factorisation of the metric after a change of coordinates. Making "factorisation"
precise in terms of the model rather than the metric — presumably as a conditional
independence statement — would give a checkable criterion.

**The curvature sign as a statistical statistic.** For the tied model the zero locus of
$K$ is a curve in parameter space separating a spherical from a hyperbolic region.
Interpreting the sign statistically — does it correspond to a phase transition in the
behaviour of estimators, or in the geometry of confidence regions? — is open.

**Higher-dimensional simplices.** The $(m-1)$-dimensional open simplex is a piece of
the sphere of radius $2$ in $\mathbb{R}^m$ and so has constant sectional curvature
$1/4$ in every two-plane; the corresponding $\alpha$-family should again yield
$(1-\alpha^2)/4$. The collapse $\Gamma^{(\alpha)} = (1+\alpha)\Gamma$ is what needs
generalising, and it depends only on the mixture identity
$\partial_k g_{ij} = -C_{ijk}$, which holds in every dimension.

**Curved exponential families.** The tied model is a curved subfamily of a full
multinomial family. The general question — how the curvature of a submodel relates to
the ambient $+1/4$ and to the second fundamental form of the embedding — is the
Efron-curvature story in Riemannian dress, and the Gauss-equation decomposition
$K = 1/4 + \det(\mathrm{II})$ makes it fully explicit for two-parameter submodels.

---

## 9. Conclusion

The Fisher–Rao geometry of the open trinomial simplex has constant Gauss curvature
$+1/4$; it is an open piece of the round sphere of radius $2$. Its Amari
$\alpha$-connections have curvature $(1-\alpha^2)/4$, non-negative throughout
$|\alpha| \le 1$ and zero at the dually flat endpoints. The very same model separates
$n$-sample hypotheses at the exact geometric rate $\rho^n$, $0 < \rho < 1$, and has
unbounded Fisher information on its open domain. Exponential statistical sensitivity
therefore neither implies nor even suggests negative curvature; the two are logically
independent, and the exponential rate is, in this model, precisely the cosine of a
spherical angle.

Finite support does not settle the question either way: the $2\times 2$ independence
model is identically flat, and the tied two-group model is negatively curved at
$(1/10, 1/2)$ and positively curved at $(1/10, 1/10)$. The sign of the Fisher–Rao
curvature is a property of the individual family, computable only by carrying out the
derivation — scores, centring, metric, connection, Riemann tensor, contraction — with
the sign conventions calibrated against a known example.

Test identifiability first. Then, and only then, test curvature. And test it by
computing it.
