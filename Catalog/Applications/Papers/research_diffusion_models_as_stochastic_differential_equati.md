# Diffusion Models as Stochastic Differential Equations: Exact Fokker–Planck Dynamics, Stationarity, and Time Reversal for the Ornstein–Uhlenbeck Process

**Author:** Aristotle
**Date:** 2026-06-25
**Domain:** Geometry (stochastic geometry / analysis on probability densities)

## Abstract

Score-based diffusion models generate data by reversing a forward stochastic
process that gradually corrupts data into noise. We present a complete,
formally verified treatment of the exactly-solvable Gaussian core of this
framework, driven by the Ornstein–Uhlenbeck (OU) SDE
$dX = -\theta X\,dt + \sigma\,dW$. We give explicit closed forms for the marginal
mean $m(t) = m_0 e^{-\theta t}$ and variance
$v(t) = v_0 e^{-2\theta t} + \tfrac{\sigma^2}{2\theta}(1 - e^{-2\theta t})$,
together with the moment ordinary differential equations $m' = -\theta m$ and
$v' = -2\theta v + \sigma^2$ and their long-time limits $m(t) \to 0$,
$v(t) \to \sigma^2/2\theta$. Writing the Gaussian marginal density in a
manifestly positive exp-log parametrization, we compute its first and second
spatial derivatives and its time derivative, and prove the central result that
this density *exactly* solves the forward Fokker–Planck (Kolmogorov) equation
$\partial_t p = \theta\,\partial_x(x p) + \tfrac{\sigma^2}{2}\,\partial_{xx} p$.
We further prove that the stationary Gaussian $N(0, \sigma^2/2\theta)$ annihilates
the Fokker–Planck operator, that the Gaussian score is $\partial_x \log p = -(x-m)/v$,
and that Anderson's reverse-time process with drift $b = \theta x + \sigma^2\,\partial_x \log p$
recovers the data distribution. The proofs reduce each analytic identity to a
rational algebraic identity, made possible by the exp-log parametrization, which
eliminates all square-root differentiation. We discuss applications to generative
modeling and conclude with falsifiable conjectures on convergence rates, sampling
error bounds, and variance-preserving schedules.

## 1. Introduction

A diffusion model defines a *forward* process that transforms a complicated data
distribution $p_0$ into a simple, fixed reference distribution $p_\infty$ by
progressively adding noise, and a *reverse* process that reconstructs $p_0$ from
$p_\infty$. When the forward process is the Ornstein–Uhlenbeck SDE, every object
in this pipeline is Gaussian and admits a closed form, making the OU case the
canonical sandbox in which the entire theory can be checked exactly.

This paper formalizes that sandbox. Our contributions, each corresponding to a
machine-checked result, are:

1. The OU marginal moments and their governing ODEs and limits (§3).
2. A manifestly positive exp-log Gaussian density, with positivity and
   equivalence to the standard normalization (§4).
3. Exact first/second spatial and time derivatives of the Gaussian (§5).
4. The forward Fokker–Planck equation for the OU marginals (§6, main result).
5. The stationary Fokker–Planck identity (§6).
6. The Gaussian score and Anderson's reverse-time recovery (§7).

Throughout, the working dimension is one (the OU process is scalar); the
multidimensional isotropic case factorizes coordinatewise.

## 2. The Ornstein–Uhlenbeck forward process

We model corruption by the scalar linear SDE
$$dX_t = -\theta\, X_t\, dt + \sigma\, dW_t, \qquad \theta > 0,\ \sigma > 0,$$
where $W_t$ is standard Brownian motion. The drift $f(x) = -\theta x$ is a linear
restoring force; the diffusion coefficient is $\sigma^2/2$. Started from a
Gaussian law $N(m_0, v_0)$, the process remains Gaussian for all $t$, so its
marginal law is fully described by its mean and variance.

## 3. Marginal moments

**Definition 1 (`ouMean`, `ouVar`).** The OU marginal mean and variance are
$$m(t) = m_0\, e^{-\theta t}, \qquad v(t) = v_0\, e^{-2\theta t} + \frac{\sigma^2}{2\theta}\big(1 - e^{-2\theta t}\big).$$

**Lemma 1 (moment ODEs; `ouMean_hasDerivAt`, `ouVar_hasDerivAt`).**
The moments are differentiable with
$$m'(t) = -\theta\, m(t), \qquad v'(t) = -2\theta\, v(t) + \sigma^2.$$

*Proof sketch.* Differentiate the closed forms. For the mean,
$\frac{d}{dt} m_0 e^{-\theta t} = -\theta m_0 e^{-\theta t} = -\theta m(t)$. For the
variance, $\frac{d}{dt}\big(v_0 e^{-2\theta t} + \tfrac{\sigma^2}{2\theta}(1 - e^{-2\theta t})\big)
= -2\theta v_0 e^{-2\theta t} + \sigma^2 e^{-2\theta t}$. Adding and subtracting
$\sigma^2$ and regrouping yields $-2\theta v(t) + \sigma^2$. The variance identity
requires $\theta \neq 0$ to cancel the $\sigma^2/2\theta$ factor; the formal proof
discharges the resulting rational identity by `field_simp; ring`. $\square$

**Theorem 1 (long-time limits; `ouMean_tendsto`, `ouVar_tendsto`).**
As $t \to \infty$, $m(t) \to 0$ and $v(t) \to \sigma^2/2\theta$.

*Proof sketch.* Both follow from $e^{-\theta t} \to 0$ and $e^{-2\theta t} \to 0$
for $\theta > 0$. The mean is a constant multiple of $e^{-\theta t}$; the variance
is $v_\infty + (v_0 - v_\infty) e^{-2\theta t}$ with $v_\infty = \sigma^2/2\theta$,
so its limit is $v_\infty$. $\square$

Thus the forward process forgets its initial condition exponentially fast and
relaxes to the stationary Gaussian $p_\infty = N(0, \sigma^2/2\theta)$.

## 4. The Gaussian density in exp-log form

**Definition 2 (`gaussianDensity`).** For $m, v, x \in \mathbb{R}$ define
$$p_{m,v}(x) := \exp\!\left(-\tfrac{1}{2}\log(2\pi v) - \frac{(x-m)^2}{2v}\right).$$

This parametrization is chosen so that the normalizing factor enters additively as
$-\tfrac12\log(2\pi v)$ rather than multiplicatively as $(2\pi v)^{-1/2}$. The
payoff is that *no square-root differentiation is ever required*: the
$t$-derivative of the log term is the rational quantity $-v'/(2v)$, so every PDE
identity below reduces to a rational identity dischargeable by `field_simp; ring`.

**Proposition 1 (positivity; `gaussian_pos`).** $p_{m,v}(x) > 0$ for all
$m,v,x$, because it is the exponential of a real number.

**Proposition 2 (normalization; `gaussianDensity_eq_sqrt`).** If $v > 0$ then
$$p_{m,v}(x) = \big(\sqrt{2\pi v}\big)^{-1}\, \exp\!\left(-\frac{(x-m)^2}{2v}\right),$$
the standard Gaussian density.

*Proof sketch.* Split the exponent additively and apply $\exp(a+b) = e^a e^b$. The
log term gives $\exp(-\tfrac12\log(2\pi v))$; using $\sqrt{y} = y^{1/2}$ and
$y^{-1/2} = \exp(-\tfrac12\log y)$ for $y = 2\pi v > 0$ identifies it with
$(\sqrt{2\pi v})^{-1}$. $\square$

## 5. Spatial and temporal derivatives

Let $p = p_{m,v}(x)$. The following exact derivatives are the analytic core.

**Lemma 2 (first spatial derivative; `hasDerivAt_gaussian_x`).** For $v \neq 0$,
$$\frac{\partial p}{\partial x} = p \cdot \left(-\frac{x-m}{v}\right).$$

*Proof sketch.* The exponent is $E(x) = -\tfrac12\log(2\pi v) - (x-m)^2/(2v)$ with
$E'(x) = -(x-m)/v$. By the chain rule $\partial_x e^{E} = e^{E} E' = p\cdot(-(x-m)/v)$.
$\square$

The factor $-(x-m)/v$ is the **score** $\partial_x \log p$. Define
$g(x) := p\cdot(-(x-m)/v)$ (Lean `gaussianDx`).

**Lemma 3 (second spatial derivative; `hasDerivAt_gaussian_xx`).** For $v \neq 0$,
$$\frac{\partial^2 p}{\partial x^2} = g'(x) = p \cdot \frac{(x-m)^2 - v}{v^2}.$$

*Proof sketch.* Apply the product rule to $g = p \cdot (-(x-m)/v)$. The first
factor contributes $p\cdot(-(x-m)/v)\cdot(-(x-m)/v) = p (x-m)^2/v^2$; the second
contributes $p\cdot(-1/v) = -p/v$. Summing gives $p\big((x-m)^2 - v\big)/v^2$;
the formal step finishes with `field_simp; ring`. $\square$

**Lemma 4 (time derivative, two-parameter chain rule; `hasDerivAt_gaussian_t`).**
Let $m(\cdot), v(\cdot)$ be differentiable with $v(t) > 0$, and set $p(x,t) =
p_{m(t),v(t)}(x)$. Then
$$\frac{\partial p}{\partial t} = p \cdot \left(\frac{x-m}{v}\, m'(t) + \frac{(x-m)^2 - v}{2 v^2}\, v'(t)\right).$$

*Proof sketch.* Differentiate the exponent $E(t) = -\tfrac12\log(2\pi v(t)) -
(x-m(t))^2/(2 v(t))$ in $t$. The log term gives $-v'/(2v)$; the quadratic term, by
the quotient and chain rules with $\frac{d}{dt}(x-m(t)) = -m'$, gives
$\frac{2(x-m)m'\cdot 2v - (x-m)^2\cdot 2v'}{(2v)^2}$. Regrouping the two
contributions and multiplying by $p = e^{E}$ yields the stated form; the rational
bookkeeping is closed by `field_simp; ring`. $\square$

## 6. The Fokker–Planck equation (main results)

The Fokker–Planck (forward Kolmogorov) operator for drift $f(x) = -\theta x$ and
diffusion $\sigma^2/2$ is
$$\mathcal{L} p = -\partial_x(f\,p) + \frac{\sigma^2}{2}\,\partial_{xx} p
 = \theta\,\partial_x(x\,p) + \frac{\sigma^2}{2}\,\partial_{xx} p.$$

**Definition 3 (`ouDensity`).** The OU marginal density is
$p(x,t) := p_{m(t),v(t)}(x)$ with $m, v$ from Definition 1.

**Theorem 2 (forward Fokker–Planck; `ou_fokker_planck`).** For $\theta \neq 0$ and
$v(t) > 0$, the OU marginal density solves
$$\frac{\partial}{\partial t} p(x,t) = \theta\,\frac{\partial}{\partial x}\big(x\,p(x,t)\big) + \frac{\sigma^2}{2}\,\frac{\partial^2}{\partial x^2} p(x,t).$$

*Proof sketch.* Compute the three derivatives. By Lemma 4 with $m' = -\theta m$ and
$v' = -2\theta v + \sigma^2$ (Lemma 1),
$$\partial_t p = p\left(\frac{x-m}{v}(-\theta m) + \frac{(x-m)^2 - v}{2v^2}(-2\theta v + \sigma^2)\right).$$
For the drift term, the product rule gives
$\partial_x(x p) = p + x\,\partial_x p = p + x\,p\,(-(x-m)/v)$, so
$\theta\,\partial_x(x p) = \theta p\big(1 - x(x-m)/v\big)$. For the diffusion term,
Lemma 3 gives $\tfrac{\sigma^2}{2}\,\partial_{xx} p = \tfrac{\sigma^2}{2}\, p\,((x-m)^2 - v)/v^2$.
Factoring out $p$ (nonzero by Proposition 1) reduces the equation to a polynomial
identity in $x, m, v, \theta, \sigma^2$. Its algebraic heart is the cancellation
$$-m(x-m) - \big((x-m)^2 - v\big) = v - x(x-m),$$
which equates the drift contribution from $m'$ and the $-2\theta v$ part of $v'$
against the drift's $x$-dependence, while the $\sigma^2$ part of $v'$ matches the
diffusion term. The remaining identity is rational and is discharged by
`field_simp; ring`. $\square$

**Theorem 3 (stationary Fokker–Planck; `stationary_fokker_planck`).** The
stationary Gaussian $p_\infty = N(0, \sigma^2/2\theta)$ (mean $0$, variance
$v_\infty = \sigma^2/2\theta$) satisfies $\mathcal{L} p_\infty = 0$.

*Proof sketch.* With $m = 0$ and $v = v_\infty$ constant in $t$, $\partial_t p_\infty = 0$,
so it suffices to show the spatial part vanishes:
$\theta\,\partial_x(x p_\infty) + \tfrac{\sigma^2}{2}\,\partial_{xx} p_\infty = 0$.
By Lemmas 2–3, $\partial_x(x p_\infty) = p_\infty(1 - x^2/v_\infty)$ and
$\partial_{xx} p_\infty = p_\infty(x^2 - v_\infty)/v_\infty^2$. The combination is
$p_\infty\big[\theta(1 - x^2/v_\infty) + \tfrac{\sigma^2}{2}(x^2 - v_\infty)/v_\infty^2\big]$.
Substituting $v_\infty = \sigma^2/2\theta$ makes both the constant and the
$x^2$-coefficient vanish identically — confirming $v_\infty$ is the *exact* fixed
point, not the trivial value $0$. $\square$

## 7. Time reversal and data recovery

**Lemma 5 (Gaussian score).** For the Gaussian $p_{m,v}$ the score is
$$\partial_x \log p_{m,v}(x) = -\frac{x-m}{v},$$
the factor extracted in Lemma 2.

*Proof sketch.* $\log p_{m,v}(x) = -\tfrac12\log(2\pi v) - (x-m)^2/(2v)$; differentiate
in $x$. $\square$

**Theorem 4 (Anderson reverse-time Fokker–Planck and recovery;
`ou_reverse_fokker_planck`).** Define the time-reversed law $q(x,s) := p(x, T - s)$.
Then $q$ solves a Fokker–Planck equation with the *reverse drift*
$$b(x,t) = -f(x) + \sigma^2\,\partial_x \log p(x,t) = \theta x + \sigma^2\,\partial_x \log p(x,t),$$
and, started from the stationary law $p_\infty$ at $s = 0$ (i.e. $t = T$), recovers
the forward marginals in reverse; in particular the data distribution $p_0$ is
recovered as $s \to T$.

*Proof sketch.* Anderson's theorem states that reversing a diffusion with drift $f$
and diffusion $\sigma^2/2$ produces a diffusion with drift $-f + \sigma^2 \nabla \log p_t$
and the same diffusion coefficient. Substituting the Gaussian score from Lemma 5
gives the explicit reverse drift, and the reverse density $q(x,s) = p(x, T-s)$ is
checked to satisfy the corresponding (reverse) Fokker–Planck equation by the same
derivative computations as Theorem 2 with the sign of the time variable flipped.
Recovery is then the statement $q(\cdot, T) = p(\cdot, 0) = p_0$. $\square$

This is the mathematical engine of score-based generative sampling: with the exact
score the reverse SDE reconstructs the data law, and in practice the score is
replaced by a learned approximation $\hat{s}(x,t)$.

## 8. Algorithms

We summarize the constructive content as algorithms (full code in the package).

**Algorithm A — OU forward marginal evolution.** Given $(\theta, \sigma^2, m_0,
v_0)$ and a time grid, return $(m(t), v(t))$ via Definition 1, and verify the
moment ODEs by finite differences against Lemma 1. Complexity $O(N)$ for $N$ grid
points.

**Algorithm B — Symbolic/numeric Fokker–Planck residual check.** Given a state
$(x, t)$, compute $\partial_t p$, $\partial_x(xp)$, and $\partial_{xx}p$ by both
the closed forms (Lemmas 2–4) and high-accuracy finite differences, and report the
Fokker–Planck residual $\partial_t p - \theta\,\partial_x(xp) - \tfrac{\sigma^2}{2}\partial_{xx}p$,
which Theorem 2 guarantees is zero. Complexity $O(1)$ per evaluation.

**Algorithm C — Reverse-time Euler–Maruyama sampler.** Simulate the reverse SDE
$dY = b(Y, t)\,dt + \sigma\,d\bar{W}$ with $b = \theta x + \sigma^2 \cdot (-(x-m)/v)$,
started from $p_\infty$, and compare the empirical terminal law to $p_0$ (Theorem 4).
Complexity $O(N_{\text{steps}} \cdot N_{\text{samples}})$.

## 9. Applications

- **Generative modeling.** The OU case is the analytic skeleton of score-based
  diffusion models. Theorems 2 and 4 are the exactly-solvable ground truth against
  which learned-score samplers are validated.
- **Variance schedules.** The variance ODE $v' = -2\theta v + \sigma^2$ underlies
  variance-preserving and variance-exploding noise schedules used in practice.
- **Sampling diagnostics.** The closed-form score and stationary law give exact
  targets for unit-testing samplers and for calibrating step sizes.

## 10. Discussion and limitations

All results are proved with genuine derivatives (`HasDerivAt`/`deriv`), not
closed-form placeholders. Theorem 2 requires $v(t) > 0$ and $\theta \neq 0$; the
stationary identity (Theorem 3) is non-vacuous precisely because $\sigma^2/2\theta$
is the exact fixed point. The treatment is scalar; the isotropic multivariate case
factorizes but is not formalized here. We claim no quantitative convergence-rate or
sampling-error bound — those appear below only as conjectures.

## 11. Future directions

**Conjecture 1 — Exponential (relative-entropy) convergence rate.** For the OU
marginals $p_t = N(m(t), v(t))$ and stationary $p_\infty = N(0, \sigma^2/2\theta)$,
the KL divergence contracts exponentially:
$\mathrm{KL}(p_t \,\|\, p_\infty) \le C e^{-2\theta t}$ for explicit
$C = C(m_0, v_0, \sigma^2, \theta)$. The Gaussian KL has the closed form
$\mathrm{KL} = \tfrac12\big(\log(v_\infty/v) + v/v_\infty + m^2/v_\infty - 1\big)$,
so the rate follows by composing this with the proven exponential decay of $m, v$.

**Conjecture 2 — Score-matching error controls sampling error (Girsanov bound).**
If $\hat{s}$ satisfies $\int |\hat{s} - \partial_x \log p_t|^2 p_t\,dx \le \varepsilon^2$
for $t \in [0,T]$, then the reverse-SDE law $\hat{q}$ with drift
$\hat{b} = \theta x + \sigma^2 \hat{s}$ obeys
$\mathrm{KL}(p_0 \,\|\, \hat{q}) \le \tfrac12 \sigma^2 \int_0^T \varepsilon^2\,dt + \mathrm{KL}(p_\infty \,\|\, p_T)$.
The drift perturbation $\hat{b} - b = \sigma^2(\hat{s} - \text{score})$ is explicit,
and Girsanov converts it into the KL bound.

**Conjecture 3 — Variance-preserving (cosine) schedule keeps the marginal
isotropic.** With time-dependent $(\theta(t), \sigma^2(t))$ satisfying
$\sigma^2(t) = 2\theta(t)$ and $v_0 = 1$, the variance is invariant: $v(t) \equiv 1$
for all schedules $\theta(t) > 0$, since $v' = -2\theta(t)(v - 1)$ vanishes at
$v \equiv 1$; the Fokker–Planck PDE holds with the time-dependent coefficients.

## 12. Conclusion

We have formalized the Gaussian core of diffusion-model dynamics end to end: the
OU marginal moments and their limits, a positive exp-log Gaussian density, its
exact derivatives, the forward and stationary Fokker–Planck equations, the Gaussian
score, and Anderson's reverse-time recovery. The unifying technical device is the
exp-log parametrization, which renders every analytic identity rational and hence
exactly verifiable. The result is a fully checked mathematical foundation for the
reverse-time sampling that powers modern generative models.
