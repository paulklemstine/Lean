# The Geometry of the KL Leash: Sharp Drift, Variance, and Covariance Laws for Preference-Optimized Policies

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

We give a complete quantitative theory of the displacement induced by the
Kullback–Leibler-regularized preference-optimization objective
$J(q) = \mathbb{E}_q[r] - \beta\,\mathrm{KL}(q\|p) + \gamma\,\mathbb{E}_d[\log q]$
on a finite response space, where $p$ is the reference (supervised fine-tuned) policy, $r$
a reward model, $d$ a pretraining distribution, and $\beta, \gamma > 0$ regularization
coefficients. The optimizer of the $\gamma = 0$ objective is the exponential tilt
$\pi_\beta \propto p\,e^{r/\beta}$, and we quantify precisely how far $\pi_\beta$ can be
from $p$, in what currency, and which functionals of the policy are able to move.

Our results are: (i) a Pinsker inequality $\|q-p\|_1^2 \le 2\,\mathrm{KL}(q\|p)$ derived from
a Padé-type lower bound for the logarithm, together with a proof that the constant $2$ is
optimal; (ii) the self-limiting divergence bound $\mathrm{KL}(\pi_\beta\|p) \le \mathrm{range}(r)/\beta$
and its $\beta^{-1/2}$ consequence; (iii) a strict improvement to the *quadratic* law
$\mathrm{KL}(\pi_\beta\|p) \le \frac{\mathrm{range}(r)^2}{2\beta^2}e^{\mathrm{range}(r)/\beta}$, hence
$\|\pi_\beta - p\|_1 = O(\beta^{-1})$, with a matching lower bound $1/(3\beta)$ showing the rate
$\Theta(\beta^{-1})$ is exact; (iv) a replacement of the reward range by the reference
*standard deviation*, $\|\pi_\beta - p\|_1 \le \beta^{-1}\sqrt{2 e^{\mathrm{range}(r)/\beta}\mathrm{Var}_p(r)}$,
which is never weaker (Popoviciu) and unboundedly stronger on rare-spike rewards, together
with a closed-form two-point computation $\|\pi_\beta - p\|_1 = \tanh(a/2\beta)$ proving the
law is $\Theta(\sigma_p(r)/\beta)$; (v) a first-order expansion of the *audit gap* of an
arbitrary statistic $f$,
$\big|\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f] - \mathrm{Cov}_p(r,f)/\beta\big| \le 24(R/\beta)^2\sigma_p(f)$
for $|r| \le R \le \beta$, whence statistics uncorrelated with the reward under the reference
move only at order $\beta^{-2}$; (vi) two-sided gain–drift inequalities and a single
budget inequality $\beta\,\mathrm{KL}(q\|p) + \gamma\,\mathrm{KL}(d\|q) \le \mathrm{range}(r) + \gamma\,\mathrm{KL}(d\|p)$
covering the pretraining mix-in; and (vii) a zero-temperature (Laplace/large-deviation)
analysis showing total policy collapse as $\beta \downarrow 0$.

Together these convert the informal claim "the KL penalty prevents reward hacking" into a
family of sharp inequalities whose constants are attained, and give an operational
criterion — pre-alignment correlation with the reward — for which behaviours of a model are
at first-order risk.

---

## 1. Introduction

### 1.1 The objective

Preference optimization of a generative model is standardly posed as the maximization of

$$J(q) \;=\; \underbrace{\mathbb{E}_{y\sim q}[r(y)]}_{\text{reward}} \;-\; \underbrace{\beta\,\mathrm{KL}(q\|p)}_{\text{anchor}} \;+\; \underbrace{\gamma\,\mathbb{E}_{y\sim d}[\log q(y)]}_{\text{pretraining mix-in}}
\tag{1}$$

over policies $q$, where $p$ is a reference model, $r$ is a learned or rule-based reward,
$d$ is the pretraining distribution, and $\beta,\gamma>0$. The three terms encode three
competing desiderata: score highly, do not move, do not forget. In practice $r$ may be a
neural preference model, a symbolic verifier, a mixture, or any bounded scoring function;
nothing in what follows depends on how $r$ is produced.

The *qualitative* solution of (1) with $\gamma = 0$ is classical: the maximizer is the Gibbs
tilt of the reference. The *quantitative* content — how far the optimizer travels, and
which observables it disturbs — is the subject of this paper.

### 1.2 What is folklore and what is proved

The alignment literature routinely asserts that the anchor term "prevents policy collapse
and reward hacking". Formalizing that assertion requires answering three separate
questions.

1. **How far does the policy move?** In which metric, at what rate in $\beta$, and with
   which functional of $r$ as the constant?
2. **Which functionals of the policy move?** A bound on the distance between $\pi_\beta$
   and $p$ bounds all bounded observables uniformly, but the interesting statement is
   *selective*: some observables are provably safe.
3. **What does the anchor cost?** How much reward improvement does a given amount of drift
   buy, and what does the pretraining mix-in add?

We answer all three, with matching examples establishing sharpness where possible.

### 1.3 Setting and notation

Throughout, $\Omega$ is a finite nonempty set of responses. A *distribution* is
$p : \Omega \to \mathbb{R}$ with $p \ge 0$ and $\sum_y p(y) = 1$; it is *positive* if $p(y) > 0$
for all $y$. We write

$$\mathbb{E}_p[f] = \sum_y p(y) f(y), \qquad
\mathrm{Var}_p(f) = \mathbb{E}_p\big[(f-\mathbb{E}_p f)^2\big], \qquad
\sigma_p(f) = \sqrt{\mathrm{Var}_p(f)},$$

$$\mathrm{Cov}_p(f,g) = \mathbb{E}_p\big[(f-\mathbb{E}_p f)(g-\mathbb{E}_p g)\big], \qquad
\mathrm{KL}(q\|p) = \sum_y q(y)\log\frac{q(y)}{p(y)}, \qquad
\|q-p\|_1 = \sum_y |q(y)-p(y)|.$$

The *reward range* is $\mathrm{range}(r) = \max_y r(y) - \min_y r(y)$.

**Definition 1 (Aligned policy).** For $\beta > 0$, a reward $r$ and a positive reference
$p$, the *partition function*, *free energy*, *tilt* and *aligned (Gibbs) policy* are

$$Z_\beta = \sum_y p(y)e^{r(y)/\beta}, \qquad F_\beta = \beta \log Z_\beta, \qquad
T_\beta(y) = \frac{e^{r(y)/\beta}}{Z_\beta}, \qquad
\pi_\beta(y) = p(y)\,T_\beta(y).$$

Thus $\pi_\beta$ is a positive distribution, $\pi_\beta = p \cdot T_\beta$ pointwise, and
$\mathbb{E}_p[T_\beta] = 1$. That $\pi_\beta$ maximizes (1) with $\gamma = 0$, with optimal value
$F_\beta$, is the Gibbs variational principle; we use it only through two consequences,
recorded as Lemma 2 and Lemma 12.

**Lemma 2 (Divergence of the tilt).**
$\displaystyle \mathrm{KL}(\pi_\beta\|p) = \mathbb{E}_{\pi_\beta}\!\left[\frac{r}{\beta}\right] - \log Z_\beta.$

*Proof sketch.* Pointwise, $\pi_\beta(y)/p(y) = e^{r(y)/\beta}/Z_\beta$, so
$\log(\pi_\beta(y)/p(y)) = r(y)/\beta - \log Z_\beta$; summing against $\pi_\beta$ and using
$\sum_y \pi_\beta(y) = 1$ gives the claim. $\square$

**Lemma 3 (Shift invariance).** $\pi_\beta$ is unchanged if $r$ is replaced by $r + c$ for a
constant $c$. Consequently every bound below may be proved for the *centered* reward
$r - \tfrac{1}{2}(\max r + \min r)$, which satisfies $\|r\|_\infty \le \mathrm{range}(r)/2$.

This trivial observation is used repeatedly: it is what allows range-based hypotheses to be
converted into $L^\infty$ hypotheses without loss.

---

## 2. Pinsker's inequality and its sharpness

The bridge from divergence bounds to metric bounds is Pinsker's inequality. We prove it
from an explicit rational lower bound for the logarithm, which keeps the whole development
elementary and self-contained.

**Lemma 4 (Padé-type logarithm bound).** For all $t > 0$,
$$\log t \;\ge\; \frac{5t^2 - 4t - 1}{2t^2 + 4t}.$$

*Proof sketch.* Let $\Phi(t) = \log t - \frac{5t^2-4t-1}{2t^2+4t}$. A direct computation gives
$$\Phi'(t) = \frac{(t-1)^3}{t^2(t+2)^2},$$
which is negative on $(0,1)$ and positive on $(1,\infty)$; hence $\Phi$ is decreasing then
increasing with a global minimum at $t = 1$, where $\Phi(1) = \log 1 - 0 = 0$. Therefore
$\Phi \ge 0$ everywhere on $(0,\infty)$. The right-hand side is a $(2,2)$ Padé-type
approximant of $\log$ at $t=1$: the defect vanishes to third order there, which is exactly
what makes the resulting Pinsker constant sharp. $\square$

**Lemma 5 (Pointwise divergence slack).** For $a \ge 0$ and $b > 0$,
$$a \log\frac{a}{b} - a + b \;\ge\; \frac{3(a-b)^2}{2(a+2b)}.$$

*Proof sketch.* Apply Lemma 4 with $t = a/b$ and clear denominators; the case $a=0$ is the
elementary inequality $b \ge 3b/2 \cdot \frac{b}{2b}$, i.e. equality. $\square$

**Theorem 6 (Pinsker).** For a distribution $q$ and a positive distribution $p$ on $\Omega$,
$$\|q-p\|_1^2 \;\le\; 2\,\mathrm{KL}(q\|p).$$

*Proof sketch.* Since $\sum_y q(y) = \sum_y p(y) = 1$, we may write
$\mathrm{KL}(q\|p) = \sum_y \big(q(y)\log\frac{q(y)}{p(y)} - q(y) + p(y)\big)$, a sum of nonnegative
terms. Bounding each by Lemma 5 and applying Cauchy–Schwarz in Engel (Titu) form,
$$\sum_y \frac{(q(y)-p(y))^2}{q(y)+2p(y)} \;\ge\; \frac{\big(\sum_y|q(y)-p(y)|\big)^2}{\sum_y (q(y)+2p(y))} = \frac{\|q-p\|_1^2}{3},$$
gives $\mathrm{KL}(q\|p) \ge \tfrac{3}{2}\cdot\tfrac{1}{3}\|q-p\|_1^2 = \tfrac12\|q-p\|_1^2$. $\square$

Equivalently $\|q-p\|_1 \le \sqrt{2\,\mathrm{KL}(q\|p)}$.

**Theorem 7 (Optimality of the constant $2$).** Let $q_\varepsilon$ be the two-point
distribution $(\tfrac12+\varepsilon, \tfrac12-\varepsilon)$ and $q_0$ the uniform
distribution on a two-element space. Then
$$\frac{2\,\mathrm{KL}(q_\varepsilon\|q_0)}{\|q_\varepsilon - q_0\|_1^2} \xrightarrow[\varepsilon\downarrow 0]{} 1,$$
and consequently for every $c < 2$ the inequality $\|q-p\|_1^2 \le c\,\mathrm{KL}(q\|p)$ fails for
all sufficiently small $\varepsilon > 0$.

*Proof sketch.* Two cubic bounds, each proved by the same mean-value technique as Lemma 4
(the defect functions have derivatives $x^3/(1\pm x)$):
$$\log(1+x) \le x - \tfrac{x^2}{2} + \tfrac{x^3}{3}\ (x\ge 0), \qquad
\log(1-x) \le -x - \tfrac{x^2}{2} - \tfrac{x^3}{3}\ (0 \le x < 1).$$
Applying them to $2\,\mathrm{KL}(q_\varepsilon\|q_0)$ with $x = 2\varepsilon$ gives
$2\,\mathrm{KL}(q_\varepsilon\|q_0) \le \|q_\varepsilon-q_0\|_1^2\,(1 + \tfrac83\varepsilon^2)$, while
Theorem 6 gives the reverse with factor $1$; the ratio is squeezed to $1$. $\square$

The moral is methodological and is used immediately: because the Pinsker *step* is optimal,
any improvement to a drift law obtained by composing "KL bound $\to$ Pinsker" must come from
improving the KL bound.

---

## 3. First drift law: the anchor is self-limiting

**Theorem 8 (Self-limiting divergence).** For every $\beta > 0$, reward $r$ and positive
reference $p$,
$$\mathrm{KL}(\pi_\beta \| p) \;\le\; \frac{\mathrm{range}(r)}{\beta}.$$

*Proof sketch.* By Lemma 2, $\beta\,\mathrm{KL}(\pi_\beta\|p) = \mathbb{E}_{\pi_\beta}[r] - F_\beta$.
Jensen's inequality applied to $\log$ gives $F_\beta = \beta \log \mathbb{E}_p[e^{r/\beta}] \ge \mathbb{E}_p[r]$,
so $\beta\,\mathrm{KL}(\pi_\beta\|p) \le \mathbb{E}_{\pi_\beta}[r] - \mathbb{E}_p[r] \le \max r - \min r$,
because any expectation of $r$ lies in $[\min r, \max r]$. $\square$

**Corollary 9 (Square-root no-collapse law).**
$\|\pi_\beta - p\|_1 \le \sqrt{2\,\mathrm{range}(r)/\beta} \to 0$ as $\beta \to \infty$.

**Corollary 10 (Uniform audit bound).** If $|f| \le M$ pointwise, then
$$\big|\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f]\big| \;\le\; M\,\|\pi_\beta-p\|_1 \;\le\; M\sqrt{\frac{2\,\mathrm{range}(r)}{\beta}}.$$

Corollary 10 is already a nontrivial anti-reward-hacking guarantee: it applies to *every*
bounded statistic, including a second, unseen reward model or a safety probe. It has two
defects, which the remaining sections remove: the rate is not optimal, and it is blind to
which statistics are actually at risk.

---

## 4. The exact rate is $\beta^{-1}$

Theorem 8 uses only the *value* of the objective. The exponential-family structure of
$\pi_\beta$ contains more information: the divergence between a tilt and its base point is
second order in the tilt parameter.

**Lemma 11 (Elementary exponential estimates).** For all real $x$:
$1 + x \le e^{x}$ and $|e^{x} - 1| \le |x|e^{|x|}$; moreover for $|x| \le 1$,
$|e^x - 1 - x| \le x^2$.

**Theorem 12 (Quadratic divergence bound).** For $\beta > 0$,
$$\mathrm{KL}(\pi_\beta \| p) \;\le\; \frac{\mathrm{range}(r)^2}{2\beta^2}\, e^{\mathrm{range}(r)/\beta}.$$

*Proof sketch.* By Lemma 3 assume $|r| \le m := \mathrm{range}(r)/2$. Write, using Lemma 2,
$$\mathrm{KL}(\pi_\beta\|p) = \mathbb{E}_{\pi_\beta}\!\left[\frac{r}{\beta}\right] - \log \mathbb{E}_p\!\left[e^{r/\beta}\right]
\le \mathbb{E}_{\pi_\beta}\!\left[\frac{r}{\beta}\right] - \mathbb{E}_p\!\left[\frac{r}{\beta}\right],$$
the last step by Jensen. Now $\mathbb{E}_{\pi_\beta}[g] - \mathbb{E}_p[g] = \mathrm{Cov}_p(T_\beta, g)$
for any $g$ (Lemma 14 below), and the tilt satisfies the Lipschitz-type estimate
$|T_\beta(x) - T_\beta(y)| \le \frac{|r(x)-r(y)|}{\beta}e^{\mathrm{range}(r)/\beta}$ obtained from
$|e^a - e^b| \le |a-b|\max(e^a,e^b)$ together with the lower bound $Z_\beta \ge e^{\min r/\beta}$.
Feeding this into the covariance yields the factor $\mathrm{range}(r)^2/(2\beta^2)$ after the
centering afforded by Lemma 3. $\square$

**Corollary 13 (Linear no-collapse law).**
$$\|\pi_\beta - p\|_1 \le \frac{\mathrm{range}(r)}{\beta}\,e^{\mathrm{range}(r)/(2\beta)},
\qquad\text{and}\qquad
\|\pi_\beta - p\|_1 \le \frac{2\,\mathrm{range}(r)}{\beta} \text{ whenever } \beta \ge \mathrm{range}(r).$$

**Theorem 14 (The rate is attained).** Let $\Omega = \{\texttt{t},\texttt{f}\}$, $p$ uniform, and
$r = \mathbf{1}_{\{\texttt{t}\}}$, so $\mathrm{range}(r) = 1$. Then for every $\beta \ge 2$,
$$\|\pi_\beta - p\|_1 \;\ge\; \frac{1}{3\beta}.$$

*Proof sketch.* In this model $Z_\beta = (e^{1/\beta}+1)/2$ and one computes exactly
$\|\pi_\beta - p\|_1 = \frac{e^{1/\beta}-1}{e^{1/\beta}+1}$. Using $e^{x} \ge 1+x$ in the
numerator and $e^{1/\beta} \le e^{1/2} \le 2$ in the denominator gives the bound. $\square$

Combining Corollary 13 and Theorem 14: alignment drift is $\Theta(\beta^{-1})$. In
particular the $\beta^{-1/2}$ law of Corollary 9 is not tight, even though the Pinsker step
inside its proof is (Theorem 7).

---

## 5. The correct constant is the reward standard deviation

The range is an $L^\infty$ summary of the reward and is therefore dominated by rare
responses. The next theorem replaces it, at leading order, by an $L^2$ summary computed
under the reference policy.

The technical engine is the *pair representation* of the variance, which converts pointwise
oscillation estimates into variance comparisons without any differentiation.

**Lemma 15 (Pair representation).** For a distribution $p$ and any $f$,
$$\mathrm{Var}_p(f) = \tfrac12 \sum_{x}\sum_{y} p(x)p(y)\,(f(x)-f(y))^2.$$
Consequently, if $|f(x)-f(y)| \le c$ for all $x,y$ with $c \ge 0$, then $\sigma_p(f) \le c$;
and if $|f(x)-f(y)| \le c\,|g(x)-g(y)|$ for all $x,y$, then $\mathrm{Var}_p(f) \le c^2 \mathrm{Var}_p(g)$.

**Lemma 16 (Reweighting identity).** For every statistic $f$,
$$\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f] = \mathrm{Cov}_p(T_\beta, f).$$

*Proof sketch.* $\mathbb{E}_{\pi_\beta}[f] = \sum_y p(y)T_\beta(y)f(y) = \mathbb{E}_p[T_\beta f]$, and
$\mathbb{E}_p[T_\beta] = 1$, so $\mathbb{E}_p[T_\beta f] - \mathbb{E}_p[f] = \mathbb{E}_p[T_\beta f] - \mathbb{E}_p[T_\beta]\mathbb{E}_p[f] = \mathrm{Cov}_p(T_\beta,f)$. $\square$

This identity is the conceptual centre of the paper: *every* change produced by alignment is
a reference covariance with the likelihood ratio $T_\beta$.

**Theorem 17 (Variance of the tilt).**
$$\mathrm{Var}_p(T_\beta) \;\le\; \left(\frac{e^{\mathrm{range}(r)/\beta}}{\beta}\right)^{\!2}\mathrm{Var}_p(r).$$

*Proof sketch.* From $|e^{a}-e^{b}| \le |a-b|\max(e^a,e^b)$ and $Z_\beta \ge e^{\min r /\beta}$,
$$|T_\beta(x)-T_\beta(y)| \le \frac{e^{\mathrm{range}(r)/\beta}}{\beta}\,|r(x)-r(y)|
\qquad\text{for all } x,y,$$
and Lemma 15 upgrades this pointwise comparison to the stated variance comparison. $\square$

**Theorem 18 (Variance drift law).** For $\beta > 0$,
$$\mathrm{KL}(\pi_\beta\|p) \le e^{\mathrm{range}(r)/\beta}\,\frac{\mathrm{Var}_p(r)}{\beta^2},
\qquad
\|\pi_\beta - p\|_1 \le \frac{\sqrt{2\,e^{\mathrm{range}(r)/\beta}\,\mathrm{Var}_p(r)}}{\beta}.$$

*Proof sketch.* By Lemma 2 and Jensen as in Theorem 12,
$\mathrm{KL}(\pi_\beta\|p) \le \frac1\beta(\mathbb{E}_{\pi_\beta}[r]-\mathbb{E}_p[r]) = \frac1\beta\mathrm{Cov}_p(T_\beta,r)$
by Lemma 16. Cauchy–Schwarz gives $|\mathrm{Cov}_p(T_\beta,r)| \le \sigma_p(T_\beta)\sigma_p(r)$, and
Theorem 17 bounds $\sigma_p(T_\beta)$ by $\beta^{-1}e^{\mathrm{range}(r)/\beta}\sigma_p(r)$. The metric
form follows from Theorem 6. $\square$

**Remark 19 (Never weaker, sometimes much stronger).** Popoviciu's inequality
$\mathrm{Var}_p(r) \le \mathrm{range}(r)^2/4$ shows Theorem 18 always improves on Theorem 12 by at least a
factor $2$. The improvement is unbounded: take $p$ to give mass $1-\delta$ to a set on which
$r \equiv 0$ and mass $\delta$ to a single response with $r = R$. Then $\mathrm{range}(r) = R$ but
$\mathrm{Var}_p(r) = \delta(1-\delta)R^2 \to 0$ as $\delta \to 0$. This is precisely the profile of a
reward model with a rare exploitable hole, and the theorem says that such a hole *cannot* be
found by tilting alone at high $\beta$: the aligned policy is anchored by mass, not by
extremes.

**Corollary 20 (Zero contrast, zero drift).** If $\mathrm{Var}_p(r) = 0$ — the reward is constant
on the support of $p$ — then $\pi_\beta = p$ exactly, for every $\beta > 0$.

**Theorem 21 (Sharpness of the standard-deviation law).** Let $\Omega=\{\texttt{t},\texttt{f}\}$,
$p$ uniform, and $r_a = a\,\mathbf{1}_{\{\texttt{t}\}}$ for $a > 0$. Then, exactly,
$$\|\pi_\beta - p\|_1 = \frac{e^{a/\beta}-1}{e^{a/\beta}+1} = \tanh\!\Big(\frac{a}{2\beta}\Big),
\qquad \mathrm{Var}_p(r_a) = \frac{a^2}{4},\quad \sigma := \sigma_p(r_a) = \frac{a}{2},$$
and for $0 < a \le \beta$,
$$\frac{\sigma}{2\beta} \;\le\; \|\pi_\beta - p\|_1 \;\le\; \frac{3\sigma}{\beta}.$$

*Proof sketch.* $Z_\beta = (e^{a/\beta}+1)/2$, so $\pi_\beta(\texttt{t}) = e^{a/\beta}/(e^{a/\beta}+1)$
and $\pi_\beta(\texttt{f}) = 1/(e^{a/\beta}+1)$; subtracting $1/2$ from each and summing absolute
values gives the closed form. The sandwich follows from $1 + x \le e^x \le 1 + 3x$ for
$0 \le x \le 1$ applied with $x = a/\beta$. $\square$

Hence the drift law is exactly $\Theta(\sigma_p(r)/\beta)$: both the functional $\sigma_p(r)$
and the rate $\beta^{-1}$ are correct. Only the absolute constant remains open; the cumulant
heuristic ($\beta\log Z_\beta$ is the cumulant generating function of $r$ evaluated at
$1/\beta$, whose curvature at $0$ is $\mathrm{Var}_p(r)$) predicts $\mathrm{KL}(\pi_\beta\|p) = \mathrm{Var}_p(r)/(2\beta^2) + O(\beta^{-3})$.

---

## 6. Which statistics move: the audit gap is a covariance

Let $f : \Omega \to \mathbb{R}$ be an *audit statistic*: an unseen reward model, a safety
classifier, a refusal-rate indicator, a stylistic measurement. The *audit gap* is
$\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f]$.

Lemma 16 and Cauchy–Schwarz already give a first selective bound.

**Theorem 22 (Fluctuation, not magnitude).**
$$\big|\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f]\big| \;\le\; \frac{e^{\mathrm{range}(r)/\beta}}{\beta}\,\sigma_p(r)\,\sigma_p(f).$$

*Proof sketch.* $|\mathrm{Cov}_p(T_\beta,f)| \le \sigma_p(T_\beta)\sigma_p(f)$ combined with Theorem 17. $\square$

This is strictly better than Corollary 10 in two ways: the rate is $\beta^{-1}$, and the
size of $f$ is measured by its reference standard deviation rather than its supremum. A
statistic that is nearly deterministic under $p$ cannot be moved at any temperature.

Still, Theorem 22 is *uniform in the direction* of $f$. The main result of this section
identifies the actual leading term.

**Lemma 23 (Bilinearity).** For a distribution $p$, functions $g,h,f$ and a scalar $c \ne 0$,
$$\mathrm{Cov}_p(g-h, f) = \mathrm{Cov}_p(g,f) - \mathrm{Cov}_p(h,f), \qquad \mathrm{Cov}_p(g/c, f) = \mathrm{Cov}_p(g,f)/c.$$

**Lemma 24 (Partition function near $1$).** Suppose $|r| \le R \le \beta$. Then
$$\tfrac13 \le Z_\beta \le 1 + 3\tfrac{R}{\beta}, \qquad |Z_\beta - 1| \le 3\frac{R}{\beta}.$$

*Proof sketch.* Lower bound: $Z_\beta \ge e^{\min r/\beta} \ge e^{-R/\beta} \ge e^{-1} \ge 1/3$,
using $R \le \beta$ and $e \le 3$. Upper bound: $Z_\beta - 1 = \mathbb{E}_p[e^{r/\beta}-1]$ and
$|e^{x}-1| \le |x|e^{|x|} \le (R/\beta)\cdot 3$ pointwise for $|x| \le R/\beta \le 1$. $\square$

**Lemma 25 (The tilt is its own linearization).** If $|r| \le R \le \beta$ then the function
$T_\beta - r/\beta$ has oscillation at most $24(R/\beta)^2$:
$$\Big| \big(T_\beta(x) - \tfrac{r(x)}{\beta}\big) - \big(T_\beta(y) - \tfrac{r(y)}{\beta}\big) \Big| \;\le\; 24\Big(\frac{R}{\beta}\Big)^{2}
\qquad \text{for all } x,y \in \Omega.$$

*Proof sketch.* Write $u(y) = r(y)/\beta$, so $|u| \le R/\beta \le 1$, and decompose
$$T_\beta(y) - u(y) = \frac{e^{u(y)}}{Z_\beta} - u(y)
= \underbrace{\frac{e^{u(y)} - 1 - u(y)}{Z_\beta}}_{\text{(a)}}
+ \underbrace{\frac{1}{Z_\beta}}_{\text{(b), constant in } y}
+ \underbrace{u(y)\Big(\frac{1}{Z_\beta}-1\Big)}_{\text{(c)}}.$$
Term (b) is constant and contributes nothing to an oscillation. For (a), $|e^{u}-1-u| \le u^2 \le (R/\beta)^2$
and $1/Z_\beta \le 3$, so (a) has magnitude at most $3(R/\beta)^2$ and oscillation at most
$6(R/\beta)^2$. For (c), $|1/Z_\beta - 1| = |Z_\beta - 1|/Z_\beta \le 9R/\beta$ by Lemma 24, and
$|u| \le R/\beta$, so (c) has magnitude at most $9(R/\beta)^2$ and oscillation at most
$18(R/\beta)^2$. Summing, $6 + 18 = 24$. $\square$

**Theorem 26 (First-order expansion of the audit gap).** Let $|r| \le R \le \beta$. Then for
every statistic $f$,
$$\left| \; \mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f] \;-\; \frac{\mathrm{Cov}_p(r,f)}{\beta} \; \right|
\;\le\; 24\left(\frac{R}{\beta}\right)^{2}\sigma_p(f).$$

*Proof sketch.* By Lemma 16 the gap equals $\mathrm{Cov}_p(T_\beta, f)$. Split
$T_\beta = \frac{r}{\beta} + \big(T_\beta - \frac{r}{\beta}\big)$ and use bilinearity (Lemma 23):
$$\mathrm{Cov}_p(T_\beta,f) = \frac{\mathrm{Cov}_p(r,f)}{\beta} + \mathrm{Cov}_p\Big(T_\beta - \frac{r}{\beta},\, f\Big).$$
For the remainder, Cauchy–Schwarz gives
$|\mathrm{Cov}_p(T_\beta - r/\beta, f)| \le \sigma_p(T_\beta - r/\beta)\,\sigma_p(f)$, and by the
oscillation half of Lemma 15 together with Lemma 25,
$\sigma_p(T_\beta - r/\beta) \le 24(R/\beta)^2$. $\square$

**Corollary 27 (Uncorrelated statistics are second-order safe).** If $\mathrm{Cov}_p(r,f) = 0$ and
$|r| \le R \le \beta$, then
$$\big|\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f]\big| \;\le\; 24\left(\frac{R}{\beta}\right)^{2}\sigma_p(f).$$

Two comments. First, the hypothesis is checkable *before* alignment: $\mathrm{Cov}_p(r,f)$ is an
expectation under the reference policy, estimable by sampling from the model one already
has. Second, the conclusion is an order-of-magnitude improvement, not merely a constant: the
generic guarantee (Theorem 22) is $O(\beta^{-1})$, while uncorrelated statistics enjoy
$O(\beta^{-2})$. This is the precise sense in which *first-order reward hacking requires
correlation with the reward model*.

---

## 7. The price of alignment

### 7.1 Two-sided gain–drift inequalities

Let $G_\beta = \mathbb{E}_{\pi_\beta}[r] - \mathbb{E}_p[r]$ denote the *reward gain*.

**Theorem 28 (Gain costs drift).**
$$G_\beta \;\ge\; \beta\,\mathrm{KL}(\pi_\beta\|p) \;\ge\; \frac{\beta}{2}\,\|\pi_\beta - p\|_1^2 .$$

*Proof sketch.* Optimality of $\pi_\beta$ gives $J(\pi_\beta) = F_\beta$, i.e.
$\mathbb{E}_{\pi_\beta}[r] - \beta\,\mathrm{KL}(\pi_\beta\|p) = F_\beta$, while Jensen gives
$F_\beta \ge \mathbb{E}_p[r]$; subtract. The second inequality is Theorem 6. $\square$

**Theorem 29 (Drift caps gain).**
$$G_\beta \;\le\; \frac{\mathrm{range}(r)}{2}\,\|\pi_\beta - p\|_1,
\qquad\text{and if } \beta \ge \mathrm{range}(r), \quad G_\beta \le \frac{\mathrm{range}(r)^2}{\beta}.$$

*Proof sketch.* Centering $r$ at $c = \tfrac12(\max r + \min r)$ makes $|r - c| \le \mathrm{range}(r)/2$
and leaves $G_\beta$ unchanged; then $G_\beta = \sum_y (\pi_\beta(y)-p(y))(r(y)-c) \le \frac{\mathrm{range}(r)}{2}\|\pi_\beta-p\|_1$.
The second statement substitutes Corollary 13. $\square$

Together: a policy that has not moved cannot have improved, and a policy that has improved
must have moved — with the quantitative exchange rate fixed by $\beta$ and $\mathrm{range}(r)$.
Once the anchor exceeds the reward scale, the *total* extractable reward is itself
$O(\beta^{-1})$: turning up $\beta$ does not merely restrain the model, it caps the
achievable objective.

### 7.2 The pretraining mix-in

Now restore $\gamma > 0$ in (1), writing $J_\gamma$ for the full objective. Remarkably, no
optimality is needed: any policy that merely *beats the reference* obeys a budget.

**Theorem 30 (PTX budget).** Let $p, q$ be positive distributions and $d$ a distribution,
and suppose $J_\gamma(p) \le J_\gamma(q)$. Then
$$\beta\,\mathrm{KL}(q\|p) \;+\; \gamma\,\mathrm{KL}(d\|q) \;\le\; \mathrm{range}(r) \;+\; \gamma\,\mathrm{KL}(d\|p).$$

*Proof sketch.* Expand both sides of $J_\gamma(p) \le J_\gamma(q)$. Using $\mathrm{KL}(p\|p) = 0$,
$$\mathbb{E}_p[r] + \gamma\,\mathbb{E}_d[\log p] \;\le\; \mathbb{E}_q[r] - \beta\,\mathrm{KL}(q\|p) + \gamma\,\mathbb{E}_d[\log q].$$
Rewrite each cross-entropy as $\mathbb{E}_d[\log u] = -H(d) - \mathrm{KL}(d\|u)$; the entropies cancel,
leaving $\beta\,\mathrm{KL}(q\|p) + \gamma\,\mathrm{KL}(d\|q) \le (\mathbb{E}_q[r] - \mathbb{E}_p[r]) + \gamma\,\mathrm{KL}(d\|p)$,
and $\mathbb{E}_q[r] - \mathbb{E}_p[r] \le \max r - \min r$. $\square$

**Corollary 31 (Two independent budgets).** Under the hypotheses of Theorem 30, with
$\beta,\gamma > 0$:
$$\mathrm{KL}(q\|p) \;\le\; \frac{\mathrm{range}(r) + \gamma\,\mathrm{KL}(d\|p)}{\beta},
\qquad
\|q-p\|_1 \;\le\; \sqrt{\frac{2\big(\mathrm{range}(r) + \gamma\,\mathrm{KL}(d\|p)\big)}{\beta}},$$
$$\mathrm{KL}(d\|q) \;\le\; \mathrm{KL}(d\|p) \;+\; \frac{\mathrm{range}(r)}{\gamma}.$$

The single inequality of Theorem 30 therefore contains both halves of the alignment tax.
The RL term can purchase at most $\mathrm{range}(r)/\beta$ of divergence from the fine-tuned
reference — enlarged by exactly $\gamma\,\mathrm{KL}(d\|p)/\beta$, the reference's own pretraining
mismatch, which is the precise cost of letting the mix-in pull the policy back toward $d$.
Symmetrically, the reward can push the policy at most $\mathrm{range}(r)/\gamma$ (in divergence)
away from the pretraining distribution beyond where the reference already sat: this is a
formal *no-catastrophic-forgetting* guarantee, with $\gamma$ the explicit dial.

---

## 8. The low-temperature phase: collapse

For completeness we describe $\beta \downarrow 0$, where the anchor is switched off. Let
$r^\star = \max_y r(y)$ and $p_{\min} = \min_y p(y) > 0$.

**Theorem 32 (Two-sided Laplace estimate).** For all $\beta > 0$,
$$r^\star + \beta \log p_{\min} \;\le\; \beta\log Z_\beta \;\le\; r^\star,
\qquad\text{hence}\qquad \beta \log Z_\beta \xrightarrow[\beta\downarrow 0]{} r^\star.$$

*Proof sketch.* Upper: $Z_\beta \le \sum_y p(y) e^{r^\star/\beta} = e^{r^\star/\beta}$. Lower:
keep only a maximizing term, $Z_\beta \ge p(y^\star)e^{r^\star/\beta} \ge p_{\min}e^{r^\star/\beta}$.
Take logarithms and multiply by $\beta$. This is a non-asymptotic, finite-space form of
Varadhan's lemma. $\square$

**Theorem 33 (Exponential suppression of suboptimal responses).** For all $y$ and $\beta > 0$,
$$\pi_\beta(y) \;\le\; \frac{1}{p_{\min}}\,e^{-(r^\star - r(y))/\beta}.$$
Consequently $\pi_\beta(y) \to 0$ as $\beta \downarrow 0$ for every $y$ with $r(y) < r^\star$.

*Proof sketch.* $\pi_\beta(y) = p(y)e^{r(y)/\beta}/Z_\beta \le e^{r(y)/\beta}/(p_{\min}e^{r^\star/\beta})$
using $p(y) \le 1$ and the lower bound on $Z_\beta$. $\square$

**Theorem 34 (Total collapse).** In the two-point model of Theorem 14,
$\|\pi_\beta - p\|_1 \to 1$ as $\beta \downarrow 0$ — the maximal value for that model, i.e.
the aligned policy converges to a point mass on the reward maximizer.

*Proof sketch.* $\|\pi_\beta - p\|_1 = \frac{e^{1/\beta}-1}{e^{1/\beta}+1} \to 1$. $\square$

The complete phase picture of the anchor is therefore: total collapse at $\beta = 0^+$;
drift $\Theta(\sigma_p(r)/\beta)$ at large $\beta$; exact recovery of the reference at
$\beta = \infty$. In particular, low temperature is *not* a continuous deformation of the
reference — the collapse is total, and no perturbative statement survives there.

---

## 9. Algorithms and estimation

All quantities in Sections 5–7 are expectations under the reference policy or under the
aligned policy, hence estimable by sampling. We record the three procedures that matter.

**Algorithm A (Exact tilt and drift diagnostics on a finite space).** Given $p$, $r$,
$\beta$: compute $u_y = r(y)/\beta$, subtract $\max_y u_y$ for numerical stability, form
$w_y = p(y)e^{u_y - \max u}$, normalize to obtain $\pi_\beta$, then return
$\mathrm{KL}(\pi_\beta\|p) = \sum_y \pi_\beta(y)(u_y - \log Z_\beta)$ and $\|\pi_\beta - p\|_1$. Cost
$O(|\Omega|)$ time and memory. This is the reference implementation against which all
bounds are checked.

**Algorithm B (Pre-alignment audit ranking).** Given samples $y_1,\dots,y_N \sim p$, reward
values $r(y_i)$ and a family of audit statistics $f^{(1)},\dots,f^{(K)}$, compute the empirical
covariances $\widehat{\mathrm{Cov}}(r, f^{(k)})$ and standard deviations $\hat\sigma(f^{(k)})$ and
report, for each $k$, the predicted first-order gap $\widehat{\mathrm{Cov}}(r,f^{(k)})/\beta$ with
error bar $24(R/\beta)^2\hat\sigma(f^{(k)})$. Rank statistics by predicted gap. Cost
$O(NK)$; note that *no* alignment run is needed. By Theorem 26 the ranking is correct up to
the stated $O(\beta^{-2})$ error, and by Corollary 27 statistics with vanishing empirical
covariance are certified second-order safe.

**Algorithm C (Temperature selection from a drift specification).** Given a drift tolerance
$\varepsilon$ and estimates of $\sigma_p(r)$ and $\mathrm{range}(r)$, return the smallest $\beta$
(binary search on the monotone bound of Theorem 18) with
$\beta^{-1}\sqrt{2e^{\mathrm{range}(r)/\beta}\mathrm{Var}_p(r)} \le \varepsilon$; the accompanying
reward-gain ceiling $\mathrm{range}(r)^2/\beta$ of Theorem 29 tells the practitioner what has been
given up. Cost $O(\log(1/\text{tol}))$ evaluations.

---

## 10. Discussion

### 10.1 What the results say about reward hacking

"Reward hacking" is usually described as the phenomenon that optimizing a proxy $r$ degrades
an unmeasured target $f$. The results above decompose that phenomenon into two independent
factors:

- a **budget** factor, $\Theta(\sigma_p(r)/\beta)$, which bounds how much *total* probability
  mass alignment can relocate; and
- a **direction** factor, $\mathrm{Cov}_p(r,f)$, which determines how much of that relocation is
  visible in the coordinate $f$.

Both factors are computed under the *reference* policy. This is the practically important
point: the leading-order damage to any audit statistic is predicted by a quantity you can
measure before alignment begins, at the cost of one sampling pass over the reference model.

The results also delimit what the anchor cannot do. It cannot protect a statistic that is
strongly correlated with the reward — for such $f$ the first-order gap $\mathrm{Cov}_p(r,f)/\beta$ is
genuinely present, not an artifact of a loose bound; Theorem 21 exhibits a family where the
bound is attained up to a factor $6$. And it cannot protect anything at all at small $\beta$,
where Theorem 34 shows collapse is total.

### 10.2 Range versus variance, and rare exploits

The distinction of Remark 19 deserves emphasis. A widespread intuition holds that a reward
model with a large exploitable maximum is dangerous in proportion to that maximum. Theorem 18
says otherwise at fixed high $\beta$: what governs drift is the reward's fluctuation
*weighted by the reference policy*. A hole that the reference model essentially never falls
into contributes $\delta(1-\delta)R^2$ to the variance, not $R^2$. The danger from such holes
is therefore not a first-order tilting effect but a consequence of running $\beta$ low enough
(or optimizing long enough off-distribution) to leave the perturbative regime — exactly the
regime Section 8 shows to be discontinuous.

### 10.3 Methodological remark: which step is loose

The progression Theorem 8 $\to$ Theorem 12 $\to$ Theorem 18 is a case study in locating
slack. The first law, $\|\pi_\beta - p\|_1 = O(\beta^{-1/2})$, was obtained by composing a
divergence bound with Pinsker. Theorem 7 proves the Pinsker step optimal, so all the slack
lay in the divergence bound — and indeed two successive improvements of that step (using
exponential-family structure, then second-moment rather than $L^\infty$ control) produced the
correct law. The general lesson: verify the sharpness of each step of a composite bound
separately before attempting to improve the composition.

### 10.4 Scope and limitations

The development is for a finite response space and a positive reference policy; the finiteness
is used only to guarantee existence of $\max$, $\min$, and finite sums, and every statement
extends verbatim to a reference measure with bounded reward under standard integrability
assumptions. More substantively, all statements concern the *exact* optimizer $\pi_\beta$ of
the idealized objective (or, in Theorem 30, any policy that beats the reference). They do not
account for optimization error, for the fact that practical training uses stochastic policy
gradients with clipped surrogate objectives, or for the reward model's own estimation error.
They should be read as the ideal-case geometry against which those additional error sources
must be measured — a target, not a description of a particular training run.

---

## 11. Future directions

Several precise questions remain.

**The absolute constant in the drift law.** We have $\|\pi_\beta - p\|_1 = \Theta(\sigma_p(r)/\beta)$
with proven bracket $[\sigma/(2\beta), 3\sigma/\beta]$ on an explicit family and the general upper
bound $\sqrt{2e^{\mathrm{range}(r)/\beta}}\,\sigma_p(r)/\beta$. The cumulant heuristic predicts
$\mathrm{KL}(\pi_\beta\|p) = \mathrm{Var}_p(r)/(2\beta^2) + O(\beta^{-3})$ and hence a leading constant of $1$;
establishing $\|\pi_\beta - p\|_1 \le (1+o(1))\sigma_p(r)/\beta$ with no exponential prefactor
requires replacing the crude $e^{\mathrm{range}(r)/\beta}$ factor, which enters only through the
Lipschitz estimate on the tilt, by a second-moment argument.

**A sharp threshold for audit statistics.** Theorem 26 gives a first-order law; it does not
establish a *phase transition*. Is there a critical temperature $\beta_c$, expressible in terms
of $\sigma_p(r)$, $\mathrm{Cov}_p(r,f)$ and higher cumulants, below which the audit gap of a given
statistic ceases to be predicted by its covariance? Section 8 shows the behaviour at $\beta = 0^+$
is qualitatively different, so such a threshold must exist; locating it is open.

**Higher-order expansion.** The natural continuation of Theorem 26 is a full Edgeworth-type
series: the second-order term should involve the third joint cumulant of $(r, f)$ under $p$, with
remainder $O(\beta^{-3})$. This would sharpen Algorithm B from a ranking to a calibrated
prediction.

**Multi-objective and iterated alignment.** Real pipelines apply several reward models in
sequence. Since the composition of two tilts is a tilt by the sum of rewards, the results above
apply verbatim to a single round with $r = \sum_i \lambda_i r_i$; but the *iterated* setting, where
each round re-estimates the reward on the previous round's policy, is not a single tilt and its
drift accumulation is unstudied.

**Beyond the exact optimizer.** Quantifying how the bounds degrade for an $\epsilon$-suboptimal
policy is straightforward for Theorem 30 (which already assumes only that $q$ beats $p$) but open
for the covariance expansion, which uses the exact exponential form of $\pi_\beta$.

---

## 12. Conclusion

The Kullback–Leibler anchor in preference optimization admits a complete and sharp quantitative
theory on finite response spaces. The aligned policy is the exponential tilt of the reference;
its displacement is $\Theta(\sigma_p(r)/\beta)$, governed by the reward's fluctuation under the
reference rather than by its range; every observable's shift is, to first order, its reference
covariance with the reward divided by $\beta$, with an explicit $O(\beta^{-2})$ remainder; the
reward gain is squeezed between $\beta\,\mathrm{KL}$ from below and $\tfrac12\mathrm{range}(r)\|\pi_\beta-p\|_1$
from above; the pretraining mix-in contributes an additive, symmetric budget; and all of this
degenerates into total collapse at zero temperature. The folklore that "the divergence penalty
prevents reward hacking" is true, but the useful form of the statement is finer: it prevents
first-order movement of exactly those behaviours that are uncorrelated with the reward model, and
the correlation can be measured before any alignment is performed.
