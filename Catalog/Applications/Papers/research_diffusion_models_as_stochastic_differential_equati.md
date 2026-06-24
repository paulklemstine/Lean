# Diffusion Models as Stochastic Differential Equations: The Deterministic Moment Backbone of the Variance-Preserving Ornstein–Uhlenbeck Process

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Physics (Stochastic Processes / Generative Modeling)

---

## Abstract

Score-based generative diffusion models are governed, in their continuous-time
formulation, by a pair of coupled stochastic differential equations (SDEs): a *forward*
process that progressively corrupts data into noise, and a *reverse-time* process that
regenerates data from noise using the gradient of the log-density (the **score**). When
the forward process is a variance-preserving (VP) Ornstein–Uhlenbeck (OU) diffusion, the
marginal law of the state remains Gaussian for all time, and the entire forward dynamics
is encoded in two scalar functions: the marginal mean and the marginal variance. This
paper isolates and rigorously establishes the **deterministic analytic backbone** of this
model — the closed-form mean and variance, the first-order moment ordinary differential
equations (ODEs) they satisfy, their long-time convergence to the stationary Gaussian,
their positivity on the physical (forward) time line, and the exact Gaussian score
identity that drives reverse-time generation. We treat the closed-form marginals as
real-analytic functions of diffusion time and prove the calculus facts they obey, without
invoking stochastic calculus or measure theory. The results provide a fully verified
foundation on which the measure-theoretic and PDE layers of diffusion theory (transition
kernels, the Fokker–Planck equation, the probability-flow ODE) can be safely built. We
present the formal statements with proof sketches, accompanying algorithms, numerical
demonstrations, and a roadmap of future directions.

---

## 1. Introduction

### 1.1 Diffusion models and the SDE viewpoint

A modern generative diffusion model defines two processes on a data space. The **forward
process** takes a data sample $x_0 \sim p_{\text{data}}$ and evolves it under an SDE

$$ dX_t = f(X_t, t)\,dt + g(t)\,dW_t, \qquad t \in [0, T], $$

so that the marginal density $p_t$ deforms smoothly from $p_{\text{data}}$ at $t=0$ toward
a simple, tractable prior (typically a standard Gaussian) as $t \to T$. Here $W_t$ is
standard Brownian motion, $f$ is the *drift*, and $g$ is the *diffusion coefficient*.

The **reverse process** runs time backward and reconstructs the data distribution. A
classical result of Anderson states that the time reversal of the forward SDE is itself
an SDE,

$$ dX_t = \big[f(X_t,t) - g(t)^2 \, \nabla_x \log p_t(X_t)\big]\,dt + g(t)\, d\bar{W}_t, $$

where $\bar W_t$ is a reverse-time Brownian motion and $\nabla_x \log p_t$ is the
**score** of the marginal density. A diffusion model trains a neural network to
approximate this score; sampling then integrates the reverse SDE (or the associated
deterministic *probability-flow ODE*) from noise back to data.

### 1.2 The variance-preserving Ornstein–Uhlenbeck forward process

The most widely used forward process is the **variance-preserving (VP) SDE**, an
Ornstein–Uhlenbeck process. In the convention with unit noise intensity and decay rate
$1/2$ it reads

$$ dX_t = -\tfrac{1}{2}\, X_t\, dt + dW_t. \tag{VP-OU} $$

This choice is special because it is *linear* and *Gaussian-preserving*: if the initial
law is Gaussian, $X_0 \sim \mathcal N(m_0, v_0)$, then $X_t \sim \mathcal N(m(t), v(t))$
remains Gaussian for all $t$, with mean and variance given in closed form. Consequently
the full forward dynamics collapses to two scalar functions of time. Everything that the
reverse process needs to know about the marginals — including the score — is a function of
these two numbers.

### 1.3 Contribution

This paper formalizes and rigorously proves the **deterministic moment backbone** of the
VP-OU diffusion model:

1. The closed-form marginal mean $m(t) = m_0 e^{-t/2}$ and variance
   $v(t) = 1 + (v_0 - 1)e^{-t}$.
2. The first-order linear moment ODEs $m'(t) = -\tfrac12 m(t)$ and $v'(t) = 1 - v(t)$,
   derived by taking expectations of the drift and applying Itô's formula to the second
   moment.
3. Stationarity of the variance fixed point $v_0 = 1$.
4. Long-time convergence $m(t) \to 0$ and $v(t) \to 1$ to the standard Gaussian.
5. Positivity/nonnegativity of the variance on the physical forward-time regime
   $t \ge 0$, together with a precise note on why positivity can fail for $t<0$.
6. The exact Gaussian score identity $\nabla_x \log p(x) = -(x-m)/\sigma^2$, including the
   fact that the omitted normalization constant has zero $x$-derivative.

We emphasize that these are statements about *deterministic real-analytic functions*. No
stochastic calculus, measure theory, or PDE machinery is used in the proofs; the SDE
serves only to motivate the definitions. This separation is deliberate: it produces a
trusted analytic core onto which the heavier probabilistic theory can be layered without
circularity.

---

## 2. Definitions

Throughout, $t \in \mathbb{R}$ denotes diffusion time and $x \in \mathbb{R}$ a state
coordinate. We work in one spatial dimension; the multivariate isotropic case factorizes
coordinatewise.

**Definition 2.1 (VP/OU marginal mean).**
For initial mean $m_0 \in \mathbb{R}$,
$$ \mathrm{vpMean}(m_0, t) := m_0 \, e^{-t/2}. $$
This is the solution of the initial value problem $m'(t) = -\tfrac12 m(t)$, $m(0) = m_0$,
obtained by taking the expectation of (VP-OU).

**Definition 2.2 (VP/OU marginal variance).**
For initial variance $v_0 \in \mathbb{R}$,
$$ \mathrm{vpVar}(v_0, t) := 1 + (v_0 - 1)\, e^{-t}. $$
This is the solution of $v'(t) = 1 - v(t)$, $v(0) = v_0$, obtained from Itô's formula for
the second moment.

**Definition 2.3 (Gaussian log-density, up to additive constant).**
For mean $m$, scale $\sigma$, and state $x$,
$$ \mathrm{gaussianLogDensity}(m, \sigma, x) := -\frac{(x-m)^2}{2\sigma^2}. $$
The full Gaussian log-density is
$\log p(x) = -\frac{(x-m)^2}{2\sigma^2} - \log\sigma - \tfrac12\log(2\pi)$; the omitted
term $-\log\sigma - \tfrac12\log(2\pi)$ is constant in $x$ and therefore irrelevant to the
score.

**Definition 2.4 (Gaussian score).**
$$ \mathrm{gaussianScore}(m, \sigma, x) := -\frac{x-m}{\sigma^2}. $$
This is the claimed value of $\partial_x \log p(x)$.

---

## 3. The moment ODEs

The defining feature of the VP-OU process is that its first two moments evolve
autonomously, each by a first-order linear ODE. These ODEs are the deterministic shadow
of the SDE: the mean equation is the expectation of the drift, and the variance equation
follows from Itô's formula applied to $X_t^2$.

### 3.1 The mean equation

**Theorem 3.1 (`vpMean_hasDerivAt`).**
For all $m_0, t \in \mathbb{R}$, the mean satisfies
$$ \frac{d}{dt}\,\mathrm{vpMean}(m_0, t) = -\tfrac{1}{2}\,\mathrm{vpMean}(m_0, t). $$

*Proof sketch.* Write $m(t) = m_0\, e^{-t/2}$. The inner map $t \mapsto -t/2$ has constant
derivative $-1/2$. The chain rule for the exponential gives
$m'(t) = m_0 \, e^{-t/2}\cdot(-1/2) = -\tfrac12\, m(t)$. Formally this is the composition of
the standard derivative of $\exp$ with a constant-multiple-and-negate inner function,
followed by multiplication by the constant $m_0$; a final ring normalization matches the
two sides. $\square$

*Interpretation.* The mean undergoes pure exponential relaxation toward $0$ with rate
$1/2$. This is the expectation of the deterministic drift $-\tfrac12 X_t$ in (VP-OU); the
random term $dW_t$ has zero mean and contributes nothing.

### 3.2 The variance equation

**Theorem 3.2 (`vpVar_hasDerivAt`).**
For all $v_0, t \in \mathbb{R}$, the variance satisfies
$$ \frac{d}{dt}\,\mathrm{vpVar}(v_0, t) = 1 - \mathrm{vpVar}(v_0, t). $$

*Proof sketch.* Write $v(t) = 1 + (v_0 - 1)\, e^{-t}$. The inner map $t \mapsto -t$ has
derivative $-1$, so the chain rule yields $\frac{d}{dt}\, e^{-t} = -e^{-t}$ and hence
$v'(t) = -(v_0-1)e^{-t}$. Since $1 - v(t) = -(v_0-1)e^{-t}$, the two coincide; the constant
$+1$ added to the exponential term has zero derivative. A ring normalization closes the
identity. $\square$

*Interpretation.* The variance ODE $v' = 1 - v$ is a relaxation equation whose
right-hand side is the *signed gap* to the stationary value $1$. The deterministic drift
contributes the $-v$ part (geometric contraction of spread), while the constant unit
*production* term $+1$ is precisely the contribution of the noise intensity $g^2 = 1$ via
Itô's formula. The competition between contraction and noise injection is what fixes the
equilibrium variance at $1$ — hence "variance-preserving."

---

## 4. Stationarity and long-time convergence

### 4.1 The variance fixed point

**Theorem 4.1 (`vpVar_stationary`).**
For all $t \in \mathbb{R}$, $\ \mathrm{vpVar}(1, t) = 1.$

*Proof sketch.* Substituting $v_0 = 1$ kills the exponential term:
$1 + (1-1)e^{-t} = 1$. $\square$

*Interpretation.* $v_0 = 1$ is the fixed point of $v' = 1 - v$ (the unique zero of the
right-hand side). A process started at the equilibrium variance remains there for all
time — the statistical signature of having reached the stationary distribution
$\mathcal N(0,1)$.

### 4.2 Convergence to the standard Gaussian

We use the elementary limit that underlies all of diffusion's "forgetting":

**Lemma 4.2 (`exp_neg_tendsto_zero`).**
$\displaystyle \lim_{t\to\infty} e^{-t} = 0.$

**Theorem 4.3 (`vpMean_tendsto_zero`).**
For all $m_0$, $\ \displaystyle \lim_{t\to\infty}\mathrm{vpMean}(m_0,t) = 0.$

*Proof sketch.* As $t\to\infty$, $t/2 \to \infty$, so $e^{-t/2} \to 0$ by composing the
limit $t/2\to\infty$ with $\lim_{s\to\infty} e^{-s}=0$. Multiplying the convergent factor
by the constant $m_0$ preserves the limit. $\square$

**Theorem 4.4 (`vpVar_tendsto_one`).**
For all $v_0$, $\ \displaystyle \lim_{t\to\infty}\mathrm{vpVar}(v_0,t) = 1.$

*Proof sketch.* $\mathrm{vpVar}(v_0,t) = 1 + (v_0-1)e^{-t}$. Since $e^{-t}\to 0$, the second
term vanishes, leaving the limit $1$. Formally, scale the limit of $e^{-t}$ by the
constant $(v_0-1)$ and add the constant $1$. $\square$

*Interpretation.* Together, Theorems 4.3 and 4.4 prove that the marginal law
$\mathcal N(m(t), v(t))$ converges to the standard normal $\mathcal N(0,1)$ as
$t \to \infty$, **regardless of the initial mean and variance**. This is the precise
sense in which the forward process erases all information about the data distribution and
maps every input to the same universal prior — the property a diffusion model relies on
when it initializes reverse sampling from pure Gaussian noise.

---

## 5. Positivity of the variance on the physical time line

A variance must be nonnegative to be meaningful. The closed form
$v(t) = 1 + (v_0-1)e^{-t}$ does **not** guarantee this for arbitrary real $t$: as
$t\to-\infty$, $e^{-t}\to+\infty$, so for $0 < v_0 < 1$ the term $(v_0-1)e^{-t}$ diverges to
$-\infty$ and $v(t)$ eventually goes negative. The resolution is that diffusion time is
intrinsically forward: the physically relevant regime is $t \ge 0$, where $0 < e^{-t}\le 1$.

**Theorem 5.1 (`vpVar_pos_of_pos`).**
If $v_0 > 0$ and $t \ge 0$, then $\mathrm{vpVar}(v_0, t) > 0.$

*Proof sketch.* For $t\ge 0$ we have $0 < e^{-t} \le 1$. Rewrite
$$ v(t) = 1 + (v_0-1)e^{-t} = (1 - e^{-t}) + v_0\, e^{-t}. $$
The first summand $1 - e^{-t}$ is nonnegative (since $e^{-t}\le 1$), and the second
$v_0\,e^{-t}$ is strictly positive (product of positives). Hence $v(t) > 0$. $\square$

**Theorem 5.2 (`vpVar_nonneg_of_nonneg`).**
If $v_0 \ge 0$ and $t \ge 0$, then $\mathrm{vpVar}(v_0, t) \ge 0.$

*Proof sketch.* Identical decomposition; both summands are now $\ge 0$. $\square$

**Theorem 5.3 (`vpVar_pos_of_pos_of_nonneg_time`).**
A restatement of Theorem 5.1 under an explicit "nonnegative diffusion time" name,
recording that strict positivity holds throughout the forward process for any strictly
positive initial variance.

*Interpretation.* On the forward time line the variance interpolates monotonically and
strictly positively between its initial value $v_0$ and the equilibrium value $1$,
confirming that $\mathcal N(m(t), v(t))$ is a bona fide Gaussian at every physical time.

---

## 6. The Gaussian score identity

Reverse-time generation is driven by the score $\nabla_x \log p_t(x)$. When the marginal
is Gaussian, the score has a closed affine form, and the normalization constant of the
density plays no role.

**Theorem 6.1 (Gaussian score formula, `gaussianScore_eq_deriv_logDensity`).**
For $\sigma \ne 0$ and all $x$,
$$ \frac{d}{dx}\,\mathrm{gaussianLogDensity}(m,\sigma,x) = \mathrm{gaussianScore}(m,\sigma,x)
= -\frac{x-m}{\sigma^2}. $$
Moreover, adding the constant normalization term $-\log\sigma - \tfrac12\log(2\pi)$ to the
log-density does not change this derivative, since that term is independent of $x$.

*Proof sketch.* Differentiate $-\frac{(x-m)^2}{2\sigma^2}$ in $x$. The chain rule on the
quadratic $(x-m)^2$ gives $2(x-m)$, so
$$ \frac{d}{dx}\Big[-\frac{(x-m)^2}{2\sigma^2}\Big]
   = -\frac{2(x-m)}{2\sigma^2} = -\frac{x-m}{\sigma^2}, $$
which is exactly $\mathrm{gaussianScore}(m,\sigma,x)$. Any term constant in $x$
differentiates to $0$, so the dropped normalization is irrelevant. The hypothesis
$\sigma \ne 0$ ensures $\sigma^2 \ne 0$ so the expression is well-defined. $\square$

*Interpretation.* The Gaussian score is a linear restoring field pointing toward the mean
$m$, with magnitude $|x-m|/\sigma^2$ increasing with displacement and decreasing with
spread. This is precisely the term injected into Anderson's reverse SDE: it is the
"compass" that steers noise back toward the data manifold. Because the score depends only
on $m = \mathrm{vpMean}(m_0,t)$ and $\sigma^2 = \mathrm{vpVar}(v_0,t)$, it is fully
determined by the verified moment backbone of Sections 3–5.

---

## 7. From the backbone to the full theory

The deterministic backbone connects to the standard probabilistic objects of diffusion
theory as follows.

### 7.1 The Fokker–Planck equation

For a one-dimensional SDE $dX_t = f(X_t,t)\,dt + g(t)\,dW_t$, the marginal density
$p(t,x)$ obeys the **Fokker–Planck (forward Kolmogorov) equation**
$$ \partial_t p = -\partial_x\!\big(f(x,t)\,p\big) + \tfrac12 g(t)^2\,\partial_{xx} p. $$
For (VP-OU), $f(x,t) = -\tfrac12 x$ and $g \equiv 1$:
$$ \partial_t p = \tfrac12\,\partial_x(x\,p) + \tfrac12\,\partial_{xx} p. $$
Taking the first two moments of this PDE reproduces *exactly* the moment ODEs of
Theorems 3.1 and 3.2: multiplying by $x$ and integrating yields $m' = -\tfrac12 m$, and
multiplying by $(x-m)^2$ and integrating yields $v' = 1 - v$. Thus the verified ODEs are
the moment projection of the Fokker–Planck dynamics, and the convergence theorems of
Section 4 are the statement that the Fokker–Planck flow drives every initial Gaussian to
its stationary solution $\mathcal N(0,1)$, the unique density annihilated by the
right-hand side.

### 7.2 The reverse-time SDE and data recovery

Anderson's reverse SDE for (VP-OU) is
$$ dX_t = \big[-\tfrac12 X_t - \nabla_x \log p_t(X_t)\big]\,dt + d\bar W_t. $$
When $p_t = \mathcal N(m(t), v(t))$, the score is the affine field of Theorem 6.1, and the
reverse drift is an explicit linear function of the state. Running this process from
$\mathcal N(0,1)$ (the $t\to\infty$ limit established in Section 4) recovers the marginal
family in reverse and hence the data distribution at $t = 0$ — the mathematical guarantee
that the reverse process "paints" the data back from noise.

### 7.3 The probability-flow ODE

The deterministic probability-flow ODE
$$ \frac{dx}{dt} = f(x,t) - \tfrac12 g(t)^2\, \nabla_x \log p_t(x) $$
shares the marginals of the SDE. For a Gaussian marginal it becomes the closed-form affine
velocity field obtained by substituting the score of Theorem 6.1, built entirely from
$\mathrm{vpMean}$, $\mathrm{vpVar}$, and $\mathrm{gaussianScore}$.

---

## 8. Algorithms

We summarize the three computational primitives implied by the backbone. (Full
type-hinted implementations appear in the accompanying package.)

### 8.1 Forward marginal evaluation

Given $(m_0, v_0)$ and a time grid, evaluate $m(t) = m_0 e^{-t/2}$ and
$v(t) = 1 + (v_0-1)e^{-t}$. Cost: $O(N)$ exponentials for $N$ grid points. This is the
exact forward-noising schedule; no simulation of trajectories is required because the
marginals are known in closed form.

### 8.2 Stationarity / convergence certificate

Given a tolerance $\varepsilon$, return the time $t^\star$ after which
$|m(t)| < \varepsilon$ and $|v(t) - 1| < \varepsilon$. Solving the exponential bounds gives
$t^\star = \max\!\big(2\log(|m_0|/\varepsilon),\ \log(|v_0-1|/\varepsilon)\big)$, a direct
consequence of Theorems 4.3–4.4. Cost: $O(1)$.

### 8.3 Gaussian score / reverse-drift evaluation

Given $(m,\sigma)$ and a point $x$, return the score $-(x-m)/\sigma^2$ (Theorem 6.1) and,
for VP-OU, the reverse drift $-\tfrac12 x - \text{score}$. Cost: $O(1)$ per evaluation.
This is the kernel of any sampler that integrates the reverse SDE or the
probability-flow ODE on Gaussian marginals.

---

## 9. Applications

- **Generative modeling.** The backbone is the analytic foundation of VP-SDE / DDPM-style
  diffusion models: the forward schedule, the noise prior, and the score target are all
  instances of the functions proved here.
- **Exact training targets.** Because the marginals are Gaussian, the denoising score
  matching target is the closed-form affine score of Theorem 6.1, enabling exact loss
  computation and analysis of estimator bias.
- **Statistical physics.** The same OU process models a Brownian particle in a harmonic
  potential; the moment ODEs and equilibrium variance describe its relaxation to thermal
  equilibrium, with the unit variance playing the role of the fluctuation–dissipation
  balance.
- **Numerical validation.** The closed forms give ground truth against which SDE/ODE
  integrators (Euler–Maruyama, probability-flow ODE solvers) can be benchmarked.

---

## 10. Discussion

The methodological point of this work is the clean separation between a *deterministic
analytic core* and the *probabilistic superstructure* of diffusion theory. By treating the
marginal mean and variance as ordinary real-analytic functions and proving their calculus
properties directly — derivatives, limits, sign — we obtain a trusted, self-contained
foundation. Crucially, none of the proofs invoke stochastic calculus, measure theory, or
PDE theory; the SDE only motivates the definitions. This makes the core both robust and
reusable: the transition kernel, the Fokker–Planck equation, and the probability-flow ODE
can each be layered on top without re-deriving the underlying calculus and without risk of
circular reasoning.

A subtle but important point established here is the *time-domain restriction* on variance
positivity. The naive expectation that $v(t) > 0$ "always" is false: it fails for
$t < 0$ when $0 < v_0 < 1$. The honest, verified statements (Theorems 5.1–5.3) hold on the
physical forward-time regime $t \ge 0$, exactly where diffusion models operate. This kind
of precise scoping is the dividend of full rigor.

---

## 11. Future Directions

**1. Formalize the Brownian heat kernel and its PDE.** Build the one-dimensional heat
kernel $p(t,x,y) = (4\pi t)^{-1/2}\exp(-(x-y)^2/4t)$ and prove that, as a function of
$(t,x)$, it satisfies the heat equation $\partial_t p = \partial_{xx} p$ with the correct
distributional initial condition. The heat kernel is a Gaussian with fixed mean and
linearly growing variance, so its space derivatives are governed by exactly the
Gaussian-log-density differentiation already proved (the score identity), and its time
derivative is a moment-ODE computation analogous to the variance derivative. The hardest
elementary obstacle — differentiating a Gaussian quadratic form cleanly and reconciling
coercions — is already solved, so the heat-equation proof reduces to assembling verified
derivative lemmas.

**2. Construct the OU transition kernel and verify its moments.** Define the OU transition
kernel as the Gaussian with mean $x_0 e^{-t/2}$ and variance $1 - e^{-t}$ (the
deterministic-initial-condition specialization of the variance with $v_0 = 0$) and prove
that its mean and variance match the backbone functions and that it converges to the
standard normal as $t \to \infty$. The kernel is *defined by* the same two closed-form
moment functions already characterized, so its correctness theorems are corollaries of
the moment derivatives and their long-time limits; the remaining work is measure-theoretic
packaging (a measure/pdf wrapper) layered on a trusted analytic core.

**3. Derive the Gaussian probability-flow ODE.** Formalize the probability-flow ODE
associated with VP diffusion, whose deterministic trajectories share the SDE's marginals,
and prove that for a Gaussian marginal $\mathcal N(m(t), v(t))$ the flow's velocity field
is the explicit affine map obtained by substituting the Gaussian score into the
flow-drift formula $f(x,t) - \tfrac12 g(t)^2 \nabla \log p_t(x)$. Once the marginal is
Gaussian, the probability-flow velocity is a closed-form affine function of $x$ built
entirely from the mean, variance, and score identities already proved.

---

## 12. Conclusion

We have rigorously established the deterministic moment backbone of the variance-preserving
Ornstein–Uhlenbeck diffusion model: closed-form marginal mean and variance, their
first-order moment ODEs $m' = -\tfrac12 m$ and $v' = 1 - v$, the variance fixed point at
$1$, convergence of the marginals to $\mathcal N(0,1)$, positivity of the variance on the
forward-time line, and the exact Gaussian score $-(x-m)/\sigma^2$ that drives reverse-time
generation. These results form the verified analytic foundation on which the
measure-theoretic and PDE layers of diffusion theory — transition kernels, the
Fokker–Planck equation, and the probability-flow ODE — can be safely constructed.
