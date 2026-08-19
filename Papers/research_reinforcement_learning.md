# The Arithmetic of Alignment: Gibbs Variational Structure of KL-Regularized Reward Optimization and Its Number-Theoretic Instantiations

**Author:** Aristotle

**Date:** 2026-08-19

---

## Abstract

We develop, over a finite response space, a complete and exact theory of the Kullback–Leibler-regularized reward-optimization objective
$$
J(q) \;=\; \mathbb{E}_{y \sim q}[r(y)] \;-\; \beta\,\mathrm{KL}(q \Vert p) \;+\; \gamma\, \mathbb{E}_{x \sim d}[\log q(x)],
$$
the standard objective governing preference-based fine-tuning of generative models, and we exhibit a systematic dictionary between this theory and classical analytic number theory.

On the structural side we prove: an exact Gibbs variational identity $J(q) = \beta \log Z(\beta) - \beta\,\mathrm{KL}(q \Vert \pi_\beta)$ identifying the unique optimum $\pi_\beta \propto p\, e^{r/\beta}$ and the optimal value $V(\beta) = \beta \log Z(\beta)$; a strict *alignment tax* showing the pretraining-mixin-augmented value is bounded by $\beta \log Z - \gamma H(d)$ with equality unattainable off a degenerate case; exact identifiability of reward models modulo additive constants together with the implicit-reward inverse; and a *schedule collapse* theorem showing that an arbitrary finite schedule of alignment steps at arbitrary temperatures is reproduced by a single step with a rescaled reward sum.

On the analytic side we prove that the curvature of the value curve in the inverse temperature $t = 1/\beta$ equals the reward variance under the tilted policy, $\frac{d^2}{dt^2}\log Z(t) = \mathrm{Var}_{\pi_t}(r)$; deduce strict convexity, an annealing inequality, a variance-flow identity $\int_{t_1}^{t_2}\mathrm{Var}_{\pi_t}(r)\,dt = \mathbb{E}_{\pi_{t_2}}[r] - \mathbb{E}_{\pi_{t_1}}[r]$, and a temperature-uniform speed limit with the sharp Popoviciu constant $1/4$, whose equality case we characterize exactly. We further prove *spectral rigidity*: the value curve on $\beta > 0$ determines the reward spectrum (the reference mass at each reward value) and nothing finer. We make rigidity finite: with $n$ known candidate levels, **any** $n$ distinct temperatures suffice, via a Chebyshev-system (Descartes–Rolle) argument; with unknown levels, three temperatures provably do not suffice for two atoms, by an explicit moment coincidence.

On the arithmetic side we instantiate the theory with two reward models. The *Dirichlet reward* $r(n) = -\beta s \log n$ on smooth-number response spaces has aligned policy the truncated zeta distribution $\pi(n) \propto n^{-s}$; the Euler product becomes statistical independence of prime exponents, the value is additive over primes with a Mertens-type strict ceiling, divisibility statistics converge to the classical densities $1 - p^{-s}$, and the curvature decomposes additively over primes. The *von Mangoldt reward* $r(n) = \Lambda(n)$ on $\{1,\dots,N\}$ has value squeezed between $\psi(N)/N$ and $\log N$ with strict lower inequality, zero-temperature limit $\log P$ for $P$ the largest prime $\le N$, and satisfies a **prime discovery theorem**: if $\beta \log N \le \log 2$, the aligned policy emits a prime power with probability at least $1/2$, and the prime-power mass is monotone in the leash.

**Keywords:** Gibbs variational principle, KL regularization, free energy, reward spectrum, Chebyshev system, Euler product, von Mangoldt function, truncated zeta distribution.

---

## 1. Introduction

The dominant paradigm for shaping the behavior of large generative models is reward-based fine-tuning under a divergence constraint. One begins with a reference model $p$ obtained by supervised training, scores candidate outputs with a reward model $r$, and seeks a new model $q$ that scores well without departing too far from $p$. A third term mixes in the original pretraining objective to guard against regression on general capability. The resulting objective, over a fixed prompt and a response space $\Omega$, is

$$
J(q) \;=\; \mathbb{E}_{y \sim q}[r(y)] \;-\; \beta\,\mathrm{KL}(q \Vert p) \;+\; \gamma\, \mathbb{E}_{x \sim d}[\log q(x)], \qquad \beta > 0,\ \gamma \ge 0 .
$$

Practitioners treat this as an optimization target to be approached numerically. Our starting observation is that over a finite response space it is not merely approachable — it is *solvable*, and the solution has enough structure to support a genuine theory: a thermodynamics of alignment, with temperature, free energy, curvature, phase behavior, and rigidity.

The second, more surprising observation is that this thermodynamics is the same thermodynamics that analytic number theory has been practising, under a different name, since Euler and Riemann. The Riemann zeta function is a partition function; Dirichlet series are exponential moment generating functions; Euler products are independence statements; the von Mangoldt function is the natural arithmetic energy. Once the dictionary is set up, alignment theorems and arithmetic theorems become the same theorems.

This paper develops both sides. Sections 2–4 are the general theory. Sections 5–7 are the arithmetic instantiations. Section 8 discusses algorithms, Section 9 applications and interpretation, Section 10 open directions.

### 1.1 Notation and standing assumptions

Throughout, $\Omega$ is a nonempty finite set of responses. A *distribution* on $\Omega$ is a function $q : \Omega \to \mathbb{R}$ with $q \ge 0$ and $\sum_y q(y) = 1$; it is *positive* if $q(y) > 0$ for all $y$. The reference (supervised) policy $p$ is assumed positive throughout — a harmless assumption, since responses of zero reference probability are never produced by any policy of finite divergence. The reward is an arbitrary function $r : \Omega \to \mathbb{R}$. We write
$$
\mathrm{KL}(q \Vert g) = \sum_{y} q(y) \log \frac{q(y)}{g(y)}, \qquad H(d) = -\sum_y d(y) \log d(y).
$$

We use $\beta > 0$ for the KL coefficient ("temperature", "leash") and $t = 1/\beta$ for the inverse temperature. All sums are finite; no measure-theoretic subtlety arises.

---

## 2. The exact variational structure

### 2.1 Partition function and aligned policy

**Definition 2.1 (Partition function).** For $\beta \ne 0$ set
$$
Z(\beta) \;=\; \sum_{y \in \Omega} p(y)\, e^{r(y)/\beta}.
$$
For $p$ positive, $Z(\beta) > 0$.

**Definition 2.2 (Aligned policy).** The *aligned* (Gibbs, softmax-tilted) policy is
$$
\pi_\beta(y) \;=\; \frac{p(y)\,e^{r(y)/\beta}}{Z(\beta)} .
$$
It is a positive distribution.

**Definition 2.3 (Free energy / value curve).** $V(\beta) = \beta \log Z(\beta)$.

We first record the two ingredients we need about divergence.

**Lemma 2.4 (Gibbs' inequality with equality case).** For a distribution $q$ and a positive distribution $g$ on $\Omega$, $\mathrm{KL}(q \Vert g) \ge 0$, with equality if and only if $q = g$.

*Proof sketch.* Pointwise, for $u \ge 0$ and $v > 0$ one has $u \log(u/v) \ge u - v$, with strict inequality unless $u = v$ (the case $u = 0$ being $0 \ge -v$, strict). Summing over $\Omega$ and using $\sum q = \sum g = 1$ gives $\mathrm{KL}(q \Vert g) \ge 0$. Strictness at any single point where $q$ and $g$ differ propagates to the sum. $\square$

### 2.2 The variational identity

**Theorem 2.5 (Exact Gibbs variational identity).** Let $\beta > 0$, let $p$ be positive and $q$ a distribution. Then
$$
J_0(q) \;:=\; \mathbb{E}_q[r] - \beta\,\mathrm{KL}(q \Vert p) \;=\; \beta \log Z(\beta) \;-\; \beta\,\mathrm{KL}(q \Vert \pi_\beta).
$$

*Proof sketch.* Expand $\mathrm{KL}(q \Vert \pi_\beta) = \sum_y q(y)\log\frac{q(y)}{p(y)} - \sum_y q(y) \frac{r(y)}{\beta} + \log Z(\beta)$, using the explicit form of $\pi_\beta$ and $\sum_y q(y) = 1$. Multiply by $\beta$ and rearrange. $\square$

**Corollary 2.6 (Variational principle).** $J_0(q) \le V(\beta)$ for every distribution $q$, with equality if and only if $q = \pi_\beta$; the inequality is strict for $q \ne \pi_\beta$.

**Corollary 2.7 (Alignment never hurts).** Taking $q = p$ gives $\mathbb{E}_p[r] \le V(\beta)$.

### 2.3 The pretraining mix-in and the alignment tax

**Theorem 2.8 (PTX bound).** Let $\gamma \ge 0$, let $d$ be a distribution on $\Omega$, and set
$$
J(q) \;=\; \mathbb{E}_q[r] - \beta\,\mathrm{KL}(q\Vert p) + \gamma\,\mathbb{E}_{d}[\log q].
$$
Then for every positive distribution $q$,
$$
J(q) \;\le\; \beta \log Z(\beta) \;-\; \gamma\,H(d).
$$

*Proof sketch.* The cross-entropy inequality $-\sum_y d(y)\log q(y) \ge H(d)$ (equivalently $\mathrm{KL}(d \Vert q) \ge 0$) bounds the third term by $-\gamma H(d)$; the first two terms are bounded by $\beta \log Z$ via Corollary 2.6. $\square$

**Theorem 2.9 (Alignment tax).** For $\gamma > 0$ the bound of Theorem 2.8 is attained only if $q = \pi_\beta$ and $q = d$ simultaneously. Consequently, unless $\pi_\beta = d$, one has the strict inequality $J(q) < \beta \log Z(\beta) - \gamma H(d)$ for every positive $q$: the pretraining mix-in and the reward cannot both be optimally served.

This is the precise sense in which the pretraining mix-in is a *tax* rather than a free correction: the two constituents of the objective have distinct and generically incompatible maximizers, and the deficit is exactly $\beta\,\mathrm{KL}(q\Vert\pi_\beta) + \gamma\,\mathrm{KL}(d \Vert q)$, which is bounded below by a positive constant depending on $\mathrm{KL}(d\Vert \pi_\beta)$.

---

## 3. Thermodynamics of the value curve

### 3.1 Monotonicity, bounds, and endpoints

**Theorem 3.1 (Antitonicity).** If $0 < \beta_1 \le \beta_2$ then $V(\beta_2) \le V(\beta_1)$.

*Proof sketch.* Write $V(\beta_2) = \mathbb{E}_{\pi_{\beta_2}}[r] - \beta_2 \mathrm{KL}(\pi_{\beta_2}\Vert p)$ by Corollary 2.6. Since $\mathrm{KL} \ge 0$ and $\beta_1 \le \beta_2$, replacing $\beta_2$ by $\beta_1$ can only increase the expression; and the increased expression is $J_0^{(\beta_1)}(\pi_{\beta_2}) \le V(\beta_1)$ by the variational principle at $\beta_1$. $\square$

**Theorem 3.2 (Two-sided bracket).** $\mathbb{E}_p[r] \le V(\beta) \le \max_y r(y)$ for all $\beta > 0$. Moreover $V(\beta) \ge r(y) + \beta \log p(y)$ for every single response $y$.

**Theorem 3.3 (No policy collapse — the KL budget).** If $m \le r \le M$ pointwise then
$$
\beta \cdot \mathrm{KL}(\pi_\beta \Vert p) \;\le\; M - m .
$$

*Proof sketch.* $V(\beta) = \mathbb{E}_{\pi_\beta}[r] - \beta\mathrm{KL}(\pi_\beta \Vert p) \le M - \beta\mathrm{KL}(\pi_\beta\Vert p)$, while $V(\beta) \ge \mathbb{E}_p[r] \ge m$. $\square$

**Theorem 3.4 (Zero-temperature limit).** $\displaystyle \lim_{\beta \to 0^+} V(\beta) = \max_y r(y)$.

*Proof sketch.* Upper bound from Theorem 3.2. For the lower bound, apply the pointwise bound of Theorem 3.2 at a maximizer $y^\star$: $V(\beta) \ge \max r + \beta \log p(y^\star) \to \max r$. $\square$

**Theorem 3.5 (Infinite-temperature limit, with rate).** If $m \le r \le M$ then
$$
V(\beta) \;\le\; m + e^{(M-m)/\beta}\big(\mathbb{E}_p[r] - m\big),
$$
and consequently $\displaystyle \lim_{\beta \to \infty} V(\beta) = \mathbb{E}_p[r]$.

Thus the value curve is a decreasing bijection-like interpolation between the reference mean (no alignment) and the reward ceiling (greedy maximization).

### 3.2 Curvature is variance

Change variables to $t = 1/\beta$. Define the *exponential moments*
$$
M_k(t) \;=\; \sum_y p(y)\, r(y)^k\, e^{r(y)t}, \qquad k \ge 0,
$$
so that $Z = M_0$ in the $t$ variable, and the *tilted policy* $\pi_t(y) \propto p(y)e^{r(y)t}$, with
$$
\mathrm{tiltMean}(t) = \mathbb{E}_{\pi_t}[r] = \frac{M_1(t)}{M_0(t)}, \qquad \mathrm{tiltVar}(t) = \mathrm{Var}_{\pi_t}(r) = \frac{M_2(t)}{M_0(t)} - \Big(\frac{M_1(t)}{M_0(t)}\Big)^2.
$$

**Lemma 3.6 (Moment ladder).** $M_k' = M_{k+1}$ for every $k$.

*Proof sketch.* A finite sum of differentiable terms; each term $p(y)r(y)^k e^{r(y)t}$ differentiates to $p(y)r(y)^{k+1}e^{r(y)t}$. $\square$

**Theorem 3.7 (First derivative).** $\dfrac{d}{dt}\log M_0(t) = \mathbb{E}_{\pi_t}[r]$.

**Theorem 3.8 (Curvature identity).** $\dfrac{d^2}{dt^2}\log M_0(t) = \mathrm{Var}_{\pi_t}(r)$, and the right side equals the honest sum of squares
$$
\mathrm{Var}_{\pi_t}(r) \;=\; \sum_y \pi_t(y)\,\big(r(y) - \mathbb{E}_{\pi_t}[r]\big)^2 .
$$

*Proof sketch.* Differentiate $M_1/M_0$ by the quotient rule and use Lemma 3.6: the derivative is $M_2/M_0 - (M_1/M_0)^2$. The sum-of-squares form follows by expanding the square and using $\sum_y \pi_t(y) = 1$. $\square$

**Corollary 3.9 (Convexity, strict off constants).** $t \mapsto \log M_0(t)$ is convex on $\mathbb{R}$, and strictly convex as soon as there exist $y_0, z_0$ with $r(y_0) \ne r(z_0)$.

**Corollary 3.10 (Annealing inequality).** For $\theta \in [0,1]$ and inverse temperatures $t_1, t_2$,
$$
\log Z\big(\theta t_1 + (1-\theta)t_2\big) \;\le\; \theta \log Z(t_1) + (1-\theta)\log Z(t_2).
$$
In the temperature variable the relevant midpoint is the *harmonic* mean of $\beta_1$ and $\beta_2$: no interpolation of leash settings beats the corresponding average of the endpoint values. (A direct Cauchy–Schwarz proof of the midpoint case, applied to the vectors $\sqrt{p}\,e^{rt_i/2}$, is available and gives strictness for $t_1 \ne t_2$ and non-constant reward.)

### 3.3 A speed limit for alignment

**Theorem 3.11 (Monotone alignment).** $t \mapsto \mathbb{E}_{\pi_t}[r]$ is monotone nondecreasing.

*Proof sketch.* Its derivative is $\mathrm{Var}_{\pi_t}(r) \ge 0$ by Theorem 3.8. $\square$

**Theorem 3.12 (Popoviciu ceiling).** If $m \le r \le M$ then $\mathrm{Var}_{\pi_t}(r) \le (M-m)^2/4$ for all $t$, uniformly in $|\Omega|$.

**Theorem 3.13 (Drift bound / speed limit).** For $t_1 \le t_2$,
$$
\mathbb{E}_{\pi_{t_2}}[r] - \mathbb{E}_{\pi_{t_1}}[r] \;\le\; \frac{(M-m)^2}{4}\,(t_2 - t_1).
$$

**Theorem 3.14 (Variance-flow identity).** $\displaystyle \int_{t_1}^{t_2} \mathrm{Var}_{\pi_t}(r)\,dt \;=\; \mathbb{E}_{\pi_{t_2}}[r] - \mathbb{E}_{\pi_{t_1}}[r]$.

*Proof sketch.* $\mathrm{tiltVar}$ is continuous (a rational expression in continuous positive functions) and is the derivative of $\mathrm{tiltMean}$; apply the fundamental theorem of calculus. $\square$

Total alignment gain is accumulated reward variance: variance is not noise here, it is *progress*.

**Theorem 3.15 (Sharpness of the constant $1/4$).** Let $\Omega = \{0,1\}$, $r$ the indicator reward ($r(1) = 1$, $r(0) = 0$), and $p$ the balanced reference. Then
$$
\mathrm{Var}_{\pi_t}(r) \;=\; \frac{e^t}{(1+e^t)^2}, \qquad \mathrm{Var}_{\pi_0}(r) = \tfrac14, \qquad \frac{d}{dt}\Big|_{t=0}\mathbb{E}_{\pi_t}[r] = \tfrac14 .
$$
Consequently no constant $C < 1/4$ can replace $1/4$ in Theorem 3.12 or Theorem 3.13.

**Theorem 3.16 (Equality analysis).** With $m \le r \le M$, the Popoviciu ceiling is attained at a temperature $t$ if and only if (i) $r$ takes only the two extreme values $m$ and $M$, and (ii) the tilted policy splits its mass evenly, $\mathbb{E}_{\pi_t}[r] = (m+M)/2$.

---

## 4. Identifiability, composition, and rigidity

### 4.1 What the aligned policy remembers about the reward

**Theorem 4.1 (Shift invariance).** For any constant $c$, the reward $r + c$ induces the same aligned policy as $r$; indeed $Z_{r+c}(\beta) = e^{c/\beta}Z_r(\beta)$.

**Theorem 4.2 (Exact identifiability).** For $\beta > 0$ and positive $p$, two rewards $r_1, r_2$ satisfy $\pi_\beta(r_1, p) = \pi_\beta(r_2, p)$ if and only if there exists $c \in \mathbb{R}$ with $r_1 = r_2 + c$ pointwise.

*Proof sketch.* Sufficiency is Theorem 4.1. For necessity, equating the two policies at each $y$ and taking logarithms gives $r_1(y)/\beta - \log Z_1 = r_2(y)/\beta - \log Z_2$, so $c = \beta \log(Z_1/Z_2)$ works. $\square$

**Theorem 4.3 (Implicit reward / reparametrization).** Every positive distribution $q$ is the aligned policy of the reward $\beta \log(q/p)$. Hence $r \mapsto \pi_\beta(r,p)$ is a bijection from rewards modulo additive constants onto positive distributions.

This is exactly the reparametrization exploited by direct preference-optimization methods: fitting a policy *is* fitting a reward, and no information is lost or gained by the change of variable.

**Theorem 4.4 (Composition adds rewards).** $\pi_\beta\big(r_2,\ \pi_\beta(r_1, p)\big) = \pi_\beta(r_1 + r_2,\ p)$.

Thus the alignment steps at a fixed temperature carry an action of the additive group of reward models.

### 4.2 Schedule collapse

**Theorem 4.5 (Temperature–reward rescaling).** For nonzero $\beta, \beta'$, $\ \pi_\beta\big((\beta/\beta')\,r,\ p\big) = \pi_{\beta'}(r, p)$.

Only the ratio $r/\beta$ is observable.

**Theorem 4.6 (Schedule collapse).** Let $L = \big((\beta_1, r_1), \dots, (\beta_k, r_k)\big)$ be a finite training schedule, executed by folding the alignment map left over $L$ starting from $p$. Then for *any* fixed $\beta \ne 0$ the resulting policy equals
$$
\pi_\beta\Big(\textstyle\sum_{i=1}^k \frac{\beta}{\beta_i}\, r_i,\ \ p\Big).
$$

*Proof sketch.* Induction on $k$, using Theorem 4.5 to bring each step to the common temperature $\beta$ and Theorem 4.4 to merge it into the accumulated reward. $\square$

**Corollary 4.7 (No expressive gain from iteration).** The set of policies reachable by an arbitrary finite schedule equals the set reachable by a single alignment step. Multi-stage pipelines change optimization dynamics, not the attainable set.

### 4.3 Spectral rigidity: what the value curve reveals

**Definition 4.8 (Reward spectrum).** $\displaystyle m(v) = \sum_{y : r(y) = v} p(y)$, the reference mass carried by reward value $v$.

**Lemma 4.9 (Partition function as spectral transform).** $\displaystyle Z(t) = \sum_{v} m(v)\, e^{v t}$, the sum over the finite set of attained reward values.

**Lemma 4.10 (Independence of real exponentials on a half-line).** Let $v_1 < \dots < v_n$ be distinct reals and $c_1,\dots,c_n$ reals with $\sum_j c_j e^{v_j t} = 0$ for all $t > 0$. Then all $c_j = 0$.

*Proof sketch.* On all of $\mathbb{R}$ this is Dedekind's theorem on the linear independence of distinct characters, applied to the multiplicative monoid of the reals under addition. The half-line hypothesis is not seen by that argument, so we argue instead by peeling: divide by $e^{v_n t}$ and let $t \to \infty$; every other term vanishes in the limit, forcing $c_n = 0$; induct. $\square$

**Theorem 4.11 (Spectral rigidity).** Let two alignment problems $(\Omega_1, r_1, p_1)$ and $(\Omega_2, r_2, p_2)$ — over possibly different finite response spaces — satisfy $Z_1(\beta) = Z_2(\beta)$ for all $\beta > 0$. Then $m_1(v) = m_2(v)$ for every $v \in \mathbb{R}$. The same conclusion holds under equality of the free-energy curves $V_1 = V_2$ on $\beta > 0$.

*Proof sketch.* By Lemma 4.9 the hypothesis says two finitely supported exponential sums agree on a half-line; subtract and apply Lemma 4.10 to the union of the two level sets. $\square$

**Corollary 4.12.** Equal value curves force equal reward ceilings, $\max r_1 = \max r_2$, and equal support: a value $v$ is attained by $r_i$ if and only if $m_i(v) \ne 0$ (for positive references).

The spectrum is *exactly* what the curve knows: permutations of responses carrying the same value are invisible, and nothing else is.

### 4.4 Finite-sample rigidity: how many temperatures?

**Theorem 4.13 (Known levels, arithmetic grid).** Let $v_1, \dots, v_n$ be known distinct levels and $t_0, t_0 + \tau, \dots, t_0 + (n-1)\tau$ an arithmetic grid with $\tau \ne 0$. Then the mass vector on those levels is uniquely determined by the values of $\sum_j a_j e^{v_j t_i}$ at the $n$ grid points.

*Proof sketch.* On an arithmetic grid the system becomes a Vandermonde system in the variables $x_j = e^{v_j \tau}$, which are pairwise distinct since $\exp$ is injective; a Vandermonde matrix with distinct nodes is invertible. $\square$

The grid hypothesis is an artifact. It can be removed entirely:

**Theorem 4.14 (Exponential sums are a Chebyshev system).** Let $v_1 < \dots < v_n$ and let $t_1 < \dots < t_n$. If $\sum_{j=1}^n c_j e^{v_j t_i} = 0$ for $i = 1, \dots, n$, then all $c_j = 0$. Equivalently, a nonzero exponential polynomial with $n$ distinct exponents has at most $n-1$ real zeros.

*Proof sketch.* Induction on $n$. Multiply by $e^{-v_1 t}$, which does not change the zero set, obtaining $g(t) = \sum_j c_j e^{(v_j - v_1)t}$ with $n$ zeros. Rolle's theorem on each of the $n-1$ consecutive intervals produces $n-1$ distinct zeros of $g'$, which is an exponential polynomial with the $n-1$ *positive*, strictly increasing exponents $v_2 - v_1 < \dots < v_n - v_1$ and coefficients $c_j(v_j - v_1)$. By induction each $c_j(v_j - v_1) = 0$, and positivity of the exponents forces $c_2 = \dots = c_n = 0$. Feeding this back into the equation at $t_1$ gives $c_1 e^{v_1 t_1} = 0$, hence $c_1 = 0$. $\square$

**Corollary 4.15 (Audit with known levels).** If the candidate reward levels are known and number $n$, then the reward spectrum of an alignment problem is determined by the partition function at *any* $n$ distinct inverse temperatures. There is no bad choice of probe temperatures.

The picture changes completely when the levels themselves are unknown.

**Theorem 4.16 (Three temperatures do not suffice for two atoms).** There exist two alignment problems on $\Omega = \{0,1\}$, with positive references and with all four reward levels pairwise distinct, whose partition functions agree at the three inverse temperatures $t = 0, 1, 2$, but whose reward spectra differ.

*Proof sketch (explicit construction).* The two-point distributions supported on $\{1, 3\}$ with masses $(\tfrac12, \tfrac12)$ and on $\{\tfrac32, 4\}$ with masses $(\tfrac45, \tfrac15)$ have the same mean, $2$, and the same second moment, $5$. Take the reward levels to be the logarithms of the supports, $\{\log 3, 0\}$ and $\{\log 4, \log \tfrac32\}$, and the reference masses to be the given masses. Then $Z(t) = \sum a_j e^{v_j t} = \sum a_j x_j^t$ with $x_j$ the original support points, so agreement at $t = 1$ and $t = 2$ is exactly the equality of first and second moments, and agreement at $t = 0$ is normalization. The spectra differ, e.g. at $v = \log 3$. $\square$

Thus the natural guess "$2n - 1$ probes suffice for $n$ unknown atoms" already fails at $n = 2$. Rigidity is real but it is *conditional on structural prior knowledge*: with $n$ known levels, $n$ arbitrary probes determine everything; with unknown levels, $2n-1$ probes determine nothing decisive.

---

## 5. Arithmetic instantiation I: Dirichlet rewards and Euler products

We now specialize. Fix distinct primes $P_1, \dots, P_k$ and exponent caps $A_1, \dots, A_k$, and take the response space of smooth numbers
$$
\Omega \;=\; \prod_{i=1}^k \{0, 1, \dots, A_i\}, \qquad n(a) \;=\; \prod_{i=1}^k P_i^{\,a_i},
$$
with the uniform reference. (Unique factorization guarantees that distinct exponent tuples name distinct integers, so $\Omega$ genuinely is a set of integers.)

**Definition 5.1 (Dirichlet reward).** For a sharpness parameter $s$, set $r(a) = -\beta s \log n(a)$. Write $w_s(n) = n^{-s}$.

**Theorem 5.2 (Aligned policy is the truncated zeta law).** The aligned policy is
$$
\pi(a) \;=\; \frac{n(a)^{-s}}{\sum_{a'} n(a')^{-s}} .
$$

*Proof sketch.* $e^{r(a)/\beta} = e^{-s\log n(a)} = n(a)^{-s}$; the uniform reference contributes a constant that cancels. $\square$

**Theorem 5.3 (Euler product).** With $\zeta_{\mathrm{loc}}(s; P, A) = \sum_{j=0}^{A} P^{-js}$,
$$
\sum_{a \in \Omega} n(a)^{-s} \;=\; \prod_{i=1}^k \zeta_{\mathrm{loc}}(s; P_i, A_i).
$$

*Proof sketch.* Complete multiplicativity of $n \mapsto n^{-s}$ over finite products, plus the distributive expansion of a product of sums over the product index set. $\square$

**Theorem 5.4 (Independence of prime exponents).** Under the aligned policy the coordinates $a_1, \dots, a_k$ are mutually independent:
$$
\pi(a) \;=\; \prod_{i=1}^k \frac{P_i^{-a_i s}}{\zeta_{\mathrm{loc}}(s; P_i, A_i)} .
$$

This is the exact content of Euler's product formula, restated as a fact about a fine-tuned model: *alignment under the Dirichlet reward factorizes the model into independent per-prime components*. Each marginal is a truncated geometric law in the exponent.

**Theorem 5.5 (Additivity of the value).** $\displaystyle V \;=\; \beta\Big(\sum_{i=1}^k \log \zeta_{\mathrm{loc}}(s; P_i, A_i) \;-\; \log |\Omega|\Big)$.

**Theorem 5.6 (Mertens-type strict ceiling).** If $P_i \ge 2$ for all $i$, $k \ge 1$, and $s > 0$, then
$$
\sum_{i=1}^k \log \zeta_{\mathrm{loc}}(s; P_i, A_i) \;<\; -\sum_{i=1}^k \log\big(1 - P_i^{-s}\big).
$$

*Proof sketch.* Termwise: the truncated geometric sum $\sum_{j \le A} P^{-js}$ is strictly less than the full geometric sum $(1 - P^{-s})^{-1}$ because $P^{-s} < 1$ and a positive tail is discarded; take logarithms and sum. $\square$

**Theorem 5.7 (Euler factor in the limit).** For $P \ge 2$, $s > 0$: $\ \zeta_{\mathrm{loc}}(s; P, A) \to (1 - P^{-s})^{-1}$ as $A \to \infty$.

### 5.1 Divisibility statistics of the aligned model

**Theorem 5.8 (Indivisibility marginal).** The probability that a sample from the aligned policy is not divisible by $P$ is exactly $1/\zeta_{\mathrm{loc}}(s;P,A)$.

**Theorem 5.9 (Strict density bound and its limit).** Consequently the probability that $P$ divides the sample is strictly less than $P^{-s}$, and as $A \to \infty$ the indivisibility probability converges to $1 - P^{-s}$, the classical Dirichlet density of $P$-indivisible integers.

Alignment under a logarithmic reward therefore *reproduces classical arithmetic densities as sampling statistics*.

### 5.2 Curvature over the primes

**Theorem 5.10 (Local factors are log-convex).** For each $P \ge 2$ and $A \ge 1$, $s \mapsto \log \zeta_{\mathrm{loc}}(s;P,A)$ is strictly convex on $\mathbb{R}$, with
$$
\frac{d^2}{ds^2}\log \zeta_{\mathrm{loc}}(s;P,A) \;=\; \mathrm{Var}\big(j \log P\big)
$$
under the truncated geometric law on exponents $j \in \{0,\dots,A\}$.

*Proof sketch.* The local factor is the partition function of the reward $j \mapsto -j\log P$ on the exponent space with uniform reference; apply Theorem 3.8. $\square$

**Theorem 5.11 (Additive curvature decomposition).** The curvature of the truncated Euler product is the sum of the per-prime curvatures. Alignment "difficulty", measured as value-curve curvature, decomposes as a sum of independent local arithmetic contributions.

**Theorem 5.12 (Truncated zeta is strictly log-convex).** For $N \ge 2$ the truncated zeta function $s \mapsto \sum_{n \le N} n^{-s}$ is strictly log-convex on all of $\mathbb{R}$, with curvature equal to the variance of $\log n$ under the truncated zeta distribution.

*Proof sketch.* This is Theorem 3.8 applied to the response space $\{1,\dots,N\}$ with uniform reference and reward $r(n) = -\log n$, which is non-constant for $N \ge 2$. $\square$

### 5.3 The alignment semigroup acts by Dirichlet convolution

**Theorem 5.13 (Composition of Dirichlet steps).** Composing two alignment steps with Dirichlet rewards of sharpness $s_1$ and $s_2$, at arbitrary temperatures, yields exactly the truncated zeta policy of sharpness $s_1 + s_2$, independently of the schedule.

*Proof sketch.* Combine Theorem 4.6 (schedule collapse) with the additivity $r_{s_1} + r_{s_2} = r_{s_1 + s_2}$ of Dirichlet rewards after rescaling. $\square$

Since $n^{-s_1} \cdot n^{-s_2} = n^{-(s_1+s_2)}$, the alignment semigroup acts on Dirichlet exponents by addition — that is, by multiplication of the associated Dirichlet series weights.

---

## 6. Arithmetic instantiation II: the von Mangoldt reward

Now take $\Omega = \{1, 2, \dots, N\}$, the uniform reference, and the reward
$$
\Lambda(n) \;=\; \begin{cases} \log P, & n = P^k,\ P \text{ prime},\ k \ge 1,\\ 0, & \text{otherwise.}\end{cases}
$$
Recall the Chebyshev function $\psi(N) = \sum_{n \le N}\Lambda(n)$.

**Theorem 6.1 (Explicit aligned policy).** The unnormalized weight of $n$ is $e^{\Lambda(n)/\beta}$, i.e. $P^{1/\beta}$ if $n = P^k$ is a prime power and $1$ otherwise; the aligned policy is this weight normalized.

**Theorem 6.2 (Value squeeze).** For $\beta > 0$ and $N \ge 1$,
$$
\frac{\psi(N)}{N} \;\le\; V(\beta) \;\le\; \log N,
$$
and for $N \ge 2$ the left inequality is strict.

*Proof sketch.* The lower bound is Corollary 2.7 with the uniform reference, whose expected reward is exactly $\psi(N)/N$. The upper bound is Theorem 3.2 with $\max_n \Lambda(n) \le \log N$. Strictness for $N \ge 2$ follows from the strict-improvement criterion: the aligned policy differs from the reference exactly when the reward is non-constant, and $\Lambda$ is non-constant on $\{1,\dots,N\}$ for $N \ge 2$. $\square$

The alignment gain over the untuned model is therefore powered *precisely by the irregularity of the primes*: a reward constant across responses yields no gain, and the size of the gain is governed by how unevenly $\Lambda$ is distributed.

**Theorem 6.3 (Endpoints are prime-counting data).** For $N \ge 2$,
$$
\lim_{\beta \to 0^+} V(\beta) \;=\; \log P_{\max}(N), \qquad \lim_{\beta \to \infty} V(\beta) \;=\; \frac{\psi(N)}{N},
$$
where $P_{\max}(N)$ is the largest prime not exceeding $N$.

*Proof sketch.* Theorems 3.4 and 3.5, together with the identification $\max_{n \le N}\Lambda(n) = \log P_{\max}(N)$ (the maximum of $\log P$ over prime powers $P^k \le N$ is attained at the largest prime itself). $\square$

**Theorem 6.4 (Prime Discovery).** Let $N \ge 2$ and $\beta > 0$ satisfy $\beta \log N \le \log 2$. Then the aligned policy for the von Mangoldt reward assigns probability at least $\tfrac12$ to the set of prime powers:
$$
\sum_{n \le N,\ n \text{ a prime power}} \pi_\beta(n) \;\ge\; \frac12 .
$$

*Proof sketch.* Split the total weight $T$ into the prime-power part $S$ and the rest $R$. Every non-prime-power has $\Lambda = 0$ and hence weight exactly $1$, so $R \le N$. Meanwhile the single response $n = 2$ contributes weight $e^{\log 2/\beta} = 2^{1/\beta}$, and the hypothesis $\beta \log N \le \log 2$ is precisely $\log N \le \log 2/\beta$, i.e. $2^{1/\beta} \ge N$. Hence $S \ge N \ge R$, so $T = S + R \le 2S$ and $S/T \ge 1/2$. $\square$

The threshold is explicit and remarkably mild: for $N = 10^6$ it reads $\beta \le \log 2/\log 10^6 \approx 0.0502$.

**Theorem 6.5 (Monotone prime mass).** For any threshold $c$, the aligned probability of the upper level set $\{y : r(y) \ge c\}$ is antitone in $\beta$. In particular the prime-power mass under the von Mangoldt reward is nondecreasing as the leash is tightened.

*Proof sketch.* A rearrangement (Chebyshev/FKG-type) inequality on unnormalized weights: for $y$ in the level set, $z$ outside, and $\beta_1 \le \beta_2$, we have $(r(y) - r(z))(1/\beta_2 - 1/\beta_1) \le 0$, hence $w_{\beta_2}(y)w_{\beta_1}(z) \le w_{\beta_1}(y)w_{\beta_2}(z)$. Summing over all pairs in $A \times A^c$ gives $S(\beta_2)R(\beta_1) \le S(\beta_1)R(\beta_2)$, which is exactly the monotonicity of $S/(S+R)$. $\square$

**Corollary 6.6 (Downward-closed prime regime).** The set of leash values at which the model is at least half supported on prime powers is downward closed and contains the whole interval $\big(0, \log 2/\log N\big]$.

**Theorem 6.7 (Arithmetic rigidity of the value curve).** Any reward model on $\{1,\dots,N\}$ with uniform reference whose value curve coincides with that of $\Lambda$ has, for every value $v$, exactly as many responses of value $v$ as $\Lambda$ does. The alignment curve therefore encodes the entire multiset $\{\Lambda(1),\dots,\Lambda(N)\}$ — equivalently, the counts $\#\{k \ge 1 : P^k \le N\}$ for every prime $P$.

*Proof sketch.* Theorem 4.11 with the uniform reference, for which the spectrum is $\tfrac1N$ times the multiplicity count. $\square$

---

## 7. Synthesis: the dictionary

| Alignment concept | Arithmetic counterpart |
| --- | --- |
| Partition function $Z(t)$ | Dirichlet series / truncated zeta |
| Inverse temperature $t = 1/\beta$ | Dirichlet exponent $s$ |
| Aligned (Gibbs) policy | Truncated zeta distribution $\pi(n) \propto n^{-s}$ |
| Factorization of the policy | Euler product |
| Independence of coordinates | Multiplicativity |
| Value additivity over components | $\log$ of the Euler product |
| Curvature of the value curve | Variance of $\log n$ under the zeta law |
| Reward spectrum | Multiset of reward values with reference weights |
| Reward maximum | $\log$ of the largest prime $\le N$ |
| Reference mean reward | Chebyshev average $\psi(N)/N$ |
| Composition of alignment steps | Multiplication of Dirichlet weights, $s_1 + s_2$ |

Each row is a theorem, not an analogy. The unifying reason is structural: both sides study the same object, an exponentially tilted measure on a finite set, from opposite ends. Statistical mechanics calls it a Gibbs measure, machine learning calls it a softmax policy, and number theory calls it a Dirichlet series.

---

## 8. Algorithms

Three computational primitives fall directly out of the theory.

**(A) Value-curve evaluation and aligned sampling.** Given $(r, p, \beta)$ on a finite $\Omega$, compute $Z(\beta)$ in $O(|\Omega|)$ arithmetic operations (with the standard max-shift for numerical stability: factor out $e^{\max r/\beta}$), then $V(\beta) = \beta\log Z(\beta)$ and $\pi_\beta$ by normalization. Sampling is $O(\log|\Omega|)$ after an $O(|\Omega|)$ prefix-sum build.

**(B) Spectrum recovery from probes (known levels).** Given known levels $v_1 < \dots < v_n$ and measurements $Z(t_1), \dots, Z(t_n)$ at any $n$ distinct temperatures, solve the $n \times n$ linear system $\big(e^{v_j t_i}\big)_{ij}\, a = Z$ for the mass vector $a$. By Theorem 4.14 the matrix is invertible for *every* choice of distinct probes; conditioning, however, degrades rapidly as probes cluster or as levels approach each other, so a practical implementation should choose well-spread probes and monitor the condition number. Cost: $O(n^3)$ by Gaussian elimination, or $O(n^2)$ by exploiting the Vandermonde structure when the probes form an arithmetic grid.

**(C) Prime-regime certification.** Given $N$, compute the threshold $\beta^\star = \log 2/\log N$. Theorem 6.4 certifies prime-power mass $\ge \tfrac12$ for every $\beta \le \beta^\star$, and Theorem 6.5 certifies that the mass is monotone, so a single evaluation at $\beta^\star$ bounds the entire regime below it. Cost $O(N)$ to build $\Lambda$ by sieve, $O(N)$ per evaluation.

The schedule-collapse theorem yields a fourth, more practical primitive: **schedule compilation**. Given a schedule $\big((\beta_i, r_i)\big)_{i \le k}$, emit the single equivalent pair $\big(\beta, \sum_i (\beta/\beta_i) r_i\big)$. This is $O(k|\Omega|)$ and exactly reproduces the schedule's endpoint.

---

## 9. Applications and interpretation

**Auditing.** Theorem 4.11 says an auditor who can measure the achievable value at each leash setting learns the reward spectrum exactly and learns nothing else. This is a two-sided guarantee: it is a *capability* result for the auditor (the spectrum is recoverable) and a *privacy* result for the model owner (which response carries which reward is not). Theorems 4.14–4.16 quantify the cost: with known candidate levels the audit is finite and robust to probe placement; with unknown levels, small probe budgets are provably inconclusive.

**Hyperparameter theory.** Theorem 3.13 is a design constraint: whatever the reward and however large the vocabulary, alignment progress per unit of inverse temperature is capped by $(M-m)^2/4$. Rewards with a large dynamic range move faster; the bound is attained exactly by two-valued rewards at balance (Theorem 3.16), which suggests that binary preference rewards, precisely because they are extreme-valued, are the fastest-moving.

**Pipeline design.** Corollary 4.7 is a negative result for multi-stage alignment as a *representational* device: nothing new becomes reachable. Any advantage of multi-stage pipelines must be explained by optimization landscape, sample efficiency, or reward-model staleness — not by the geometry of attainable policies.

**Reward hacking, reconsidered.** Theorem 6.4 is a "reward hacking works" theorem. The model given the von Mangoldt reward and a short leash does not approximate primality; it concentrates on prime powers with certified probability. The lesson is not that reward hacking is benign but that it is *predictable*: the structure of $\pi_\beta$ is completely determined by the reward, and if one can characterize the reward's level sets one can characterize the hacked behavior in advance.

**Number theory.** Theorems 5.4, 5.10–5.12 give probabilistic readings of Euler products, and the strict log-convexity of the truncated zeta function on all of $\mathbb{R}$ with variance-identified curvature is a clean statement of independent interest, obtained here for free from the curvature identity.

---

## 10. Limitations and future work

The theory is exact but finite: $\Omega$ is a finite response space, so no statement is made about the infinite-sequence spaces of real language models, nor about the optimization difficulty of *reaching* $\pi_\beta$ with a parametric family. The prompt variable is suppressed; the results should be read conditionally on a fixed prompt, and expectations over prompts distribute trivially through the linear parts of the objective but not through $\log Z$.

Directions we consider most promising:

1. **Prompt-averaged rigidity.** Does the value curve averaged over a prompt distribution still determine the per-prompt spectra, or only their mixture?
2. **Sharp Prony counts for unknown levels.** Theorem 4.16 rules out three probes for two atoms. What is the exact minimal probe count for $n$ unknown atoms, and is it finite at all without a bound on the levels?
3. **Beyond prime powers.** The prime-discovery threshold rests only on the existence of one heavily-rewarded response. What arithmetic rewards drive alignment onto sparser sets — twin primes, smooth numbers of bounded type, or the support of a given multiplicative function — and with what thresholds?
4. **Rates and phase transitions.** Theorem 6.5 gives monotonicity of the prime-power mass but not a rate. Is the transition sharp in $N$, i.e. does the mass jump from $o(1)$ to $1 - o(1)$ across a window of width $o(\log 2/\log N)$?
5. **Curvature as a training diagnostic.** The variance-flow identity converts observed reward drift into an integrated variance. Can measured drift be used to certify, from training logs alone, that a reward is close to two-valued (hence at the Popoviciu extreme)?

---

## 11. Conclusion

The KL-regularized alignment objective is an exactly solvable model. Its optimum is a Gibbs measure, its optimal value is a free energy, its curvature is a variance, and its temperature curve determines the reward spectrum precisely and nothing more. Once one grants that, the arithmetic follows without effort: Dirichlet rewards produce zeta policies, Euler products become independence, and a von Mangoldt reward drives an aligned model onto the primes below an explicit and computable threshold.

The deeper point is methodological. Alignment theory has been developing its own vocabulary for objects — tilted measures, partition functions, log-convexity, moment recovery — that statistical mechanics and analytic number theory have understood for a century and a half. Setting up the dictionary once makes each field's theorems available to the other. This paper is an attempt to write down a first chapter of that dictionary, precisely enough that both sides can use it.
