# Sharp First-Order Drift Laws for Kullback–Leibler-Regularised Alignment

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

Let $p$ be a strictly positive probability vector on a finite set $\Omega$, let $r : \Omega \to
\mathbb{R}$ be a reward, and let
$$\pi_\beta(y) \;=\; \frac{p(y)e^{r(y)/\beta}}{\sum_z p(z)e^{r(z)/\beta}}$$
be the Gibbs (Kullback–Leibler-regularised) policy at temperature $\beta > 0$, i.e. the unique
maximiser of $\mathbb{E}_q[r] - \beta\,\mathrm{KL}(q\|p)$. We determine the exact first-order
behaviour of three drift functionals along the path $\beta \mapsto \pi_\beta$ in the weak-alignment
regime $\beta \to \infty$.

We prove that the total-variation ($\ell^1$) drift satisfies
$\beta\|\pi_\beta - p\|_1 \to \operatorname{MAD}_p(r) := \mathbb{E}_p|r - \mathbb{E}_p r|$, with
explicit two-sided error $O(\operatorname{Var}_p(r)\beta^{-2})$ valid for all $\beta \ge
\operatorname{range}(r)$; that the relative-entropy drift satisfies $\beta^2\,\mathrm{KL}(\pi_\beta\|p)
\to \tfrac12\operatorname{Var}_p(r)$, with explicit error $O(\beta^{-3})$; and that for every
statistic $f$ the audit drift satisfies $\beta(\mathbb{E}_{\pi_\beta}f - \mathbb{E}_p f) \to
\operatorname{Cov}_p(r,f)$, with explicit error $O(\beta^{-2})$.

These identify the exact absolute constants of a family of bounds previously known only up to
constants and up to an exponential prefactor $e^{\operatorname{range}(r)/\beta}$, and they correct the
functional in the total-variation case: the governing quantity is the mean absolute deviation, an
$L^1$ moment, not the standard deviation. We prove the *deviation defect identity*
$\operatorname{Var}_p(r) - \operatorname{MAD}_p(r)^2 = \mathbb{E}_p(|r - \mathbb{E}_p r| -
\operatorname{MAD}_p(r))^2$, giving $\operatorname{MAD} \le \sigma$ with equality iff $|r -
\mathbb{E}_p r|$ is constant; on a rare-spike family the ratio $\operatorname{MAD}/\sigma =
2\sqrt{\varepsilon(1-\varepsilon)}$ tends to $0$, so the standard-deviation law is unboundedly lossy.
Combining the total-variation and relative-entropy laws yields an exact evaluation of the Pinsker
defect along the alignment path, $\|\pi_\beta - p\|_1 / \sqrt{2\mathrm{KL}(\pi_\beta\|p)} \to
\operatorname{MAD}_p(r)/\sigma_p(r)$, tight exactly for balanced two-valued rewards. Finally, the
covariance law implies that an audit statistic uncorrelated with the reward has drift $o(\beta^{-1})$:
first-order reward hacking is precisely the reward-correlated component of the statistic, and the
familiar bound $\sigma_p(r)\sigma_p(f)/\beta$ is its Cauchy–Schwarz relaxation.

**Keywords:** Gibbs policy, exponential tilting, mean absolute deviation, Kullback–Leibler
divergence, Pinsker inequality, cumulant expansion, alignment drift, reward hacking.

---

## 1. Introduction

### 1.1 The setting

Reinforcement learning from human feedback, and more generally any procedure that adjusts a
generative model to score better on a learned reward, is standardly formulated as the
Kullback–Leibler-regularised control problem

$$\pi_\beta \;=\; \arg\max_{q \in \Delta(\Omega)} \Big\{ \mathbb{E}_q[r] - \beta\,\mathrm{KL}(q\|p)
\Big\}, \qquad \beta > 0. \tag{1.1}$$

Here $p$ is the base (reference) policy, $r$ the reward, and $\beta$ a regularisation temperature.
The solution of (1.1) is classical and explicit: the exponential tilt

$$\pi_\beta(y) \;=\; \frac{p(y)e^{r(y)/\beta}}{Z_\beta}, \qquad Z_\beta = \sum_z p(z)e^{r(z)/\beta}.
\tag{1.2}$$

The regime of practical interest is $\beta$ large: the constraint is respected, the model moves only
slightly, and one wants a quantitative guarantee on *how* slightly. The literature supplies bounds of
the shape

$$\mathrm{KL}(\pi_\beta\|p) \;\le\; \frac{e^{R/\beta}\operatorname{Var}_p(r)}{\beta^2}, \qquad
\|\pi_\beta - p\|_1 \;\le\; \frac{\sqrt{2e^{R/\beta}\operatorname{Var}_p(r)}}{\beta}, \tag{1.3}$$

where $R = \operatorname{range}(r) = \max r - \min r$, together with two-point families showing the
drift is $\Theta(\sigma_p(r)/\beta)$. These leave three questions open: (i) what is the absolute
constant? (ii) is the exponential prefactor $e^{R/\beta}$ necessary? (iii) is $\sigma_p(r)$ the
correct functional at all?

### 1.2 Contributions

We answer all three. The prefactor is unnecessary; the constants are $1$, $\tfrac12$ and $1$
respectively for the three drift functionals below; and $\sigma_p(r)$ is *not* the correct functional
for total variation.

1. **Total variation** (Theorem 4.3, Corollary 4.4). For $\beta \ge R$,
   $$\frac{\operatorname{MAD}_p(r)}{\beta} - \frac{3\operatorname{Var}_p(r)}{\beta^2}
   \;\le\; \|\pi_\beta - p\|_1 \;\le\;
   \frac{\operatorname{MAD}_p(r)}{\beta} + \frac{2\operatorname{Var}_p(r)}{\beta^2},$$
   and $\beta\|\pi_\beta - p\|_1 \to \operatorname{MAD}_p(r)$.

2. **The deviation defect** (Theorem 3.1 and Corollaries). $\operatorname{Var}_p(f) -
   \operatorname{MAD}_p(f)^2 = \mathbb{E}_p(|f - \mathbb{E}_p f| - \operatorname{MAD}_p(f))^2$, hence
   $\operatorname{MAD} \le \sigma$ with equality iff $|f - \mathbb{E}_p f|$ is constant on the
   support. On the rare-spike family the ratio degenerates: $\operatorname{MAD}/\sigma \to 0$.

3. **Relative entropy** (Theorem 5.3, Corollary 5.4). For $\beta \ge R$,
   $$\Big|\mathrm{KL}(\pi_\beta\|p) - \frac{\operatorname{Var}_p(r)}{2\beta^2}\Big| \;\le\;
   \frac{2R\operatorname{Var}_p(r)}{\beta^3} + \frac{3\operatorname{Var}_p(r)^2}{\beta^4},$$
   and $\beta^2\mathrm{KL}(\pi_\beta\|p) \to \tfrac12\operatorname{Var}_p(r)$.

4. **Audit drift** (Theorem 6.3, Corollaries 6.4–6.5). For every $f$ and $\beta \ge R$,
   $$\Big|\mathbb{E}_{\pi_\beta}f - \mathbb{E}_p f - \frac{\operatorname{Cov}_p(r,f)}{\beta}\Big|
   \;\le\; \frac{3R(f)\operatorname{Var}_p(r)}{\beta^2},$$
   hence $\beta(\mathbb{E}_{\pi_\beta}f - \mathbb{E}_p f) \to \operatorname{Cov}_p(r,f)$; if
   $\operatorname{Cov}_p(r,f)=0$ the drift is $o(\beta^{-1})$.

5. **Exact Pinsker defect** (Theorem 7.2, Theorem 7.3). $\|\pi_\beta - p\|_1/\sqrt{2\mathrm{KL}
   (\pi_\beta\|p)} \to \operatorname{MAD}_p(r)/\sigma_p(r) \le 1$, with limit $1$ iff $|r -
   \mathbb{E}_p r|$ is constant.

### 1.3 The organising principle

The path $\beta \mapsto \pi_\beta$ is a reparametrised one-parameter exponential family with natural
parameter $1/\beta$ and sufficient statistic $r$. Every functional of the path therefore admits a
cumulant/moment expansion in $1/\beta$, and the leading behaviour of a given drift functional is
governed by *the first cumulant or moment it does not annihilate*. Total variation is an $L^1$ norm
and sees the first absolute moment $\mathbb{E}_p|r - \mu|$; relative entropy is a quadratic form whose
Hessian is the Fisher information and sees the second cumulant $\operatorname{Var}_p(r)$; a linear
functional $f$ sees the mixed second moment $\operatorname{Cov}_p(r,f)$. The three constants
appearing in the literature ($R$, $\sigma$, $\operatorname{MAD}$) are the centred $L^q(p)$ norms of
the reward at $q = \infty, 2, 1$.

---

## 2. Definitions and notation

Throughout, $\Omega$ is a finite non-empty set.

**Definition 2.1 (Distributions).** A vector $p : \Omega \to \mathbb{R}$ is a *distribution* if
$p(y) \ge 0$ for all $y$ and $\sum_y p(y) = 1$; it is a *positive distribution* (full support) if
moreover $p(y) > 0$ for all $y$.

**Definition 2.2 (Moment functionals).** For a distribution $p$ and $f, g : \Omega \to \mathbb{R}$,
$$\mathbb{E}_p[f] = \sum_y p(y)f(y), \qquad
\operatorname{Var}_p(f) = \sum_y p(y)\big(f(y) - \mathbb{E}_p f\big)^2,$$
$$\operatorname{MAD}_p(f) = \sum_y p(y)\big|f(y) - \mathbb{E}_p f\big|, \qquad
\operatorname{Cov}_p(f,g) = \sum_y p(y)\big(f(y)-\mathbb{E}_p f\big)\big(g(y)-\mathbb{E}_p g\big).$$
We write $\sigma_p(f) = \sqrt{\operatorname{Var}_p(f)}$ and $R(f) = \max_y f(y) - \min_y f(y)$ for the
*range*. We abbreviate $R = R(r)$ and $\mu = \mathbb{E}_p r$.

**Definition 2.3 (Gibbs policy).** For $\beta > 0$, $Z_\beta = \sum_y p(y)e^{r(y)/\beta}$ and
$\pi_\beta(y) = p(y)e^{r(y)/\beta}/Z_\beta$. If $p$ is positive then $Z_\beta > 0$ and $\pi_\beta$ is
a positive distribution.

**Definition 2.4 (Divergences).** $\mathrm{KL}(q\|p) = \sum_y q(y)\log\frac{q(y)}{p(y)}$ and
$\|q - p\|_1 = \sum_y |q(y) - p(y)|$. (The total-variation distance is $\tfrac12\|q-p\|_1$; we work
with the $\ell^1$ norm throughout.)

**Definition 2.5 (Centred tilt).** Write $s(y) = (r(y)-\mu)/\beta$ and define the *centred partition
function*
$$W_\beta \;=\; \mathbb{E}_p\big[e^{s}\big] \;=\; \sum_y p(y)\,e^{(r(y)-\mu)/\beta}.$$

Two elementary facts recur. First, $Z_\beta = e^{\mu/\beta}W_\beta$, so
$$\pi_\beta(y) = \frac{p(y)e^{s(y)}}{W_\beta}, \tag{2.1}$$
which is the form we use exclusively: the mean of the reward is a gauge freedom and drops out.
Second, $\mathbb{E}_p[s] = 0$.

**Lemma 2.6 (Basic bounds).** Let $p$ be a distribution and $\beta>0$.
(i) $|r(y) - \mu| \le R$ for every $y$; hence $\operatorname{MAD}_p(r) \le R$.
(ii) *(Popoviciu)* $\operatorname{Var}_p(r) \le R^2/4$.
(iii) *(Jensen)* $W_\beta \ge 1$.
(iv) If $\beta \ge R$ then $W_\beta \le 1 + \operatorname{Var}_p(r)/\beta^2$.

*Proof sketch.* (i) The mean lies between $\min r$ and $\max r$. (ii) The variance is bounded by the
mean square deviation from any centre; take the midpoint $c = \tfrac12(\max r + \min r)$, for which
$(r(y)-c)^2 \le R^2/4$ pointwise. (iii) $W_\beta = \mathbb{E}_p e^{s} \ge e^{\mathbb{E}_p s} = 1$.
(iv) For $|u| \le 1$ one has $e^u \le 1 + u + u^2$; by (i) and $\beta \ge R$ we have $|s(y)| \le 1$,
so $W_\beta \le 1 + \mathbb{E}_p s + \mathbb{E}_p s^2 = 1 + \operatorname{Var}_p(r)/\beta^2$. $\square$

We use repeatedly the second-order Taylor bound $|e^u - 1 - u| \le u^2$ valid for $|u| \le 1$.

---

## 3. The deviation defect: $\operatorname{MAD}$ versus $\sigma$

Before the drift laws, we record the exact relationship between the two candidate constants. This is
what reconciles the sharp law of Section 4 with the standard-deviation folklore.

**Theorem 3.1 (Deviation defect identity).** For any distribution $p$ and any $f : \Omega \to
\mathbb{R}$,
$$\operatorname{Var}_p(f) - \operatorname{MAD}_p(f)^2 \;=\; \sum_y p(y)\Big(\big|f(y) - \mathbb{E}_p
f\big| - \operatorname{MAD}_p(f)\Big)^2 .$$

*Proof.* Put $a(y) = |f(y) - \mathbb{E}_p f|$ and $m = \operatorname{MAD}_p(f) = \mathbb{E}_p[a]$.
Expanding the square, $\mathbb{E}_p[(a-m)^2] = \mathbb{E}_p[a^2] - 2m\mathbb{E}_p[a] + m^2 =
\mathbb{E}_p[a^2] - m^2$, and $a(y)^2 = (f(y)-\mathbb{E}_p f)^2$, so $\mathbb{E}_p[a^2] =
\operatorname{Var}_p(f)$. $\square$

The right-hand side is the variance of the absolute deviation; we call it the *deviation defect*.

**Corollary 3.2.** $\operatorname{MAD}_p(f)^2 \le \operatorname{Var}_p(f)$, i.e.
$\operatorname{MAD}_p(f) \le \sigma_p(f)$.

**Theorem 3.3 (Equality case).** Let $p$ be a positive distribution. Then $\operatorname{MAD}_p(f) =
\sigma_p(f)$ if and only if $|f(y) - \mathbb{E}_p f| = \operatorname{MAD}_p(f)$ for every $y$.

*Proof.* Equality in Corollary 3.2 forces the sum in Theorem 3.1 to vanish; since $p(y)>0$ every
summand vanishes, giving $|f(y)-\mathbb{E}_p f| = \operatorname{MAD}_p(f)$ pointwise. Conversely if
the absolute deviation is constant the defect is zero, whence $\operatorname{MAD}^2 =
\operatorname{Var}$, and both quantities are non-negative. $\square$

Thus equality holds precisely for *balanced two-valued* statistics: $f$ takes two values placed
symmetrically about its mean (or is constant, with both sides zero).

**Example 3.4 (Rare spike).** Let $\Omega = \{0,1\}$, $p(1) = \varepsilon \in (0,1)$, and let $r =
\mathbf{1}_{\{1\}}$. Then $\mathbb{E}_p r = \varepsilon$,
$$\operatorname{MAD}_p(r) = 2\varepsilon(1-\varepsilon), \qquad
\operatorname{Var}_p(r) = \varepsilon(1-\varepsilon), \qquad
\operatorname{MAD}_p(r)^2 = 4\varepsilon(1-\varepsilon)\operatorname{Var}_p(r),$$
so $\operatorname{MAD}_p(r)/\sigma_p(r) = 2\sqrt{\varepsilon(1-\varepsilon)} \to 0$ as $\varepsilon
\to 0$. At $\varepsilon = \tfrac12$ the ratio equals $1$, recovering the balanced case of Theorem 3.3.

Consequently the $\sigma/\beta$ law is never violated by the sharp $\operatorname{MAD}/\beta$ law, is
attained exactly on the balanced two-valued family — precisely the family previously used to show the
$\sigma$-law could not be improved by more than a constant — and is unboundedly lossy on rare-spike
rewards.

---

## 4. The total-variation drift law

**Lemma 4.1 (Centred $\ell^1$ identity).** For a positive distribution $p$ and $\beta > 0$,
$$\|\pi_\beta - p\|_1 \;=\; \frac{S_\beta}{W_\beta}, \qquad S_\beta := \sum_y p(y)\,\big|e^{s(y)} -
W_\beta\big| .$$

*Proof.* By (2.1), $\pi_\beta(y) - p(y) = p(y)(e^{s(y)} - W_\beta)/W_\beta$. Take absolute values and
sum, using $p(y) > 0$ and $W_\beta > 0$. $\square$

**Lemma 4.2 (Numerator expansion).** If $\beta > 0$, $p$ is a distribution and $\beta \ge R$, then
$$\Big|S_\beta - \frac{\operatorname{MAD}_p(r)}{\beta}\Big| \;\le\;
\frac{2\operatorname{Var}_p(r)}{\beta^2}.$$

*Proof sketch.* Pointwise, $\big||e^{s} - W_\beta| - |s|\big| \le |e^{s} - W_\beta - s| \le |e^{s} - 1
- s| + |W_\beta - 1|$. The first term is $\le s^2$ by the Taylor bound (valid since $|s| \le
R/\beta \le 1$); the second is $\le \operatorname{Var}_p(r)/\beta^2$ by Lemma 2.6(iii)–(iv), uniformly
in $y$. Taking $\mathbb{E}_p$ and using $\mathbb{E}_p|s| = \operatorname{MAD}_p(r)/\beta$ and
$\mathbb{E}_p[s^2] = \operatorname{Var}_p(r)/\beta^2$ gives the bound with constant $1 + 1 = 2$.
$\square$

**Theorem 4.3 (Sharp two-sided drift law).** Let $p$ be a positive distribution and let $\beta > 0$
satisfy $\beta \ge R$. Then
$$\frac{\operatorname{MAD}_p(r)}{\beta} - \frac{3\operatorname{Var}_p(r)}{\beta^2}
\;\le\; \|\pi_\beta - p\|_1 \;\le\;
\frac{\operatorname{MAD}_p(r)}{\beta} + \frac{2\operatorname{Var}_p(r)}{\beta^2}.$$

*Proof sketch.* Upper bound: by Lemma 4.1 and $W_\beta \ge 1$ we have $\|\pi_\beta - p\|_1 \le
S_\beta$, and Lemma 4.2 bounds $S_\beta$.

Lower bound: write $X = \operatorname{MAD}_p(r)/\beta - 2\operatorname{Var}_p(r)/\beta^2$, so that
$S_\beta \ge X$ by Lemma 4.2. If $X \le 0$ the claim is trivial because $\|\pi_\beta - p\|_1 \ge 0$
and $\operatorname{Var}_p(r)/\beta^2 \ge 0$. If $X > 0$ then, using $W_\beta \ge 1$ and the elementary
inequality $X/W \ge X - X(W-1)$ for $W \ge 1$, $X>0$,
$$\|\pi_\beta - p\|_1 = \frac{S_\beta}{W_\beta} \ge \frac{X}{W_\beta} \ge X - X\,(W_\beta - 1).$$
By Lemma 2.6(i) and $\beta \ge R$ we have $X \le \operatorname{MAD}_p(r)/\beta \le R/\beta \le 1$, and
by Lemma 2.6(iv) $W_\beta - 1 \le \operatorname{Var}_p(r)/\beta^2$; hence $X(W_\beta - 1) \le
\operatorname{Var}_p(r)/\beta^2$ and the lower bound follows with total error constant $2 + 1 = 3$.
$\square$

**Corollary 4.4 (Exact drift constant).** For every positive distribution $p$ and reward $r$,
$$\lim_{\beta \to \infty} \beta\,\|\pi_\beta - p\|_1 \;=\; \operatorname{MAD}_p(r).$$

*Proof.* Multiply the bounds of Theorem 4.3 by $\beta$; both envelopes are $\operatorname{MAD}_p(r) +
O(\beta^{-1})$, and the hypothesis $\beta \ge R$ holds eventually. Squeeze. $\square$

Note what is absent: no exponential prefactor $e^{R/\beta}$, and the leading constant is exactly $1$.
Combined with Corollary 3.2 this shows the classical $\sigma$-law is a genuine upper bound, and
Example 3.4 shows the loss can be arbitrarily large.

---

## 5. The relative-entropy drift law

Define the *tilted first moment*
$$A_\beta \;=\; \mathbb{E}_p\big[e^{s}\,s\big] \;=\; \sum_y p(y)\,e^{(r(y)-\mu)/\beta}\,
\frac{r(y)-\mu}{\beta}.$$

**Lemma 5.1 (Positivity).** $A_\beta \ge 0$ for every distribution $p$ and every $\beta$.

*Proof sketch.* Termwise this is an FKG/Chebyshev-type statement; concretely, since
$\mathbb{E}_p[s] = 0$, one has $A_\beta = \mathbb{E}_p[(e^{s}-1)s]$, and $(e^u - 1)u \ge 0$ for all
real $u$ because $e^u - 1$ has the sign of $u$. $\square$

**Lemma 5.2 (Exact centred KL identity).** For a positive distribution $p$ and $\beta > 0$,
$$\mathrm{KL}(\pi_\beta\|p) \;=\; \frac{A_\beta}{W_\beta} \;-\; \log W_\beta .$$

*Proof.* By (2.1), $\pi_\beta(y)/p(y) = e^{s(y)}/W_\beta$, so $\log(\pi_\beta(y)/p(y)) = s(y) - \log
W_\beta$. Hence
$$\mathrm{KL}(\pi_\beta\|p) = \sum_y \frac{p(y)e^{s(y)}}{W_\beta}\big(s(y) - \log W_\beta\big)
= \frac{A_\beta}{W_\beta} - \log W_\beta \cdot \frac{W_\beta}{W_\beta}. \qquad \square$$

**Theorem 5.3 (Second-order KL law).** Let $p$ be a positive distribution and $\beta \ge R$,
$\beta>0$. Then
$$\Big|\mathrm{KL}(\pi_\beta\|p) - \frac{\operatorname{Var}_p(r)}{2\beta^2}\Big| \;\le\;
\frac{2R\operatorname{Var}_p(r)}{\beta^3} + \frac{3\operatorname{Var}_p(r)^2}{\beta^4}.$$

*Proof sketch.* Three expansions feed Lemma 5.2. Write $V = \operatorname{Var}_p(r)$.

1. *First moment.* $|A_\beta - V/\beta^2| \le \mathbb{E}_p|e^{s} - 1 - s|\,|s| \le \mathbb{E}_p|s|^3
   \le (R/\beta)\,V/\beta^2$, using $|e^u - 1 - u|\le u^2$ for $|u|\le1$ and $|s| \le R/\beta$.
2. *Partition function.* $|W_\beta - 1 - V/(2\beta^2)| \le \mathbb{E}_p|e^{s} - 1 - s - s^2/2| \le
   \mathbb{E}_p|s|^3 \le (R/\beta)V/\beta^2$, by the third-order Taylor bound, again using
   $\mathbb{E}_p s = 0$.
3. *Logarithm.* For $W \ge 1$, $W - 1 - (W-1)^2 \le \log W \le W - 1$; and $0 \le W_\beta - 1 \le
   V/\beta^2$ by Lemma 2.6, so $(W_\beta-1)^2 \le V^2/\beta^4$.

Also $A_\beta/W_\beta$ differs from $A_\beta$ by at most $A_\beta(W_\beta-1) \le 2(V/\beta^2)^2$,
using $A_\beta \le 2V/\beta^2$ from step 1 with $R \le \beta$. Substituting into Lemma 5.2,
$$\mathrm{KL} = A_\beta - \log W_\beta + O(V^2\beta^{-4}) = \frac{V}{\beta^2} - \frac{V}{2\beta^2}
+ O(RV\beta^{-3}) + O(V^2\beta^{-4}) = \frac{V}{2\beta^2} + O(RV\beta^{-3}) + O(V^2\beta^{-4}),$$
and collecting the explicit constants yields $2RV/\beta^3 + 3V^2/\beta^4$. $\square$

**Corollary 5.4.** $\displaystyle \lim_{\beta \to \infty}\beta^2\,\mathrm{KL}(\pi_\beta\|p) =
\frac{\operatorname{Var}_p(r)}{2}$, and consequently
$\lim_{\beta\to\infty} \beta\sqrt{2\,\mathrm{KL}(\pi_\beta\|p)} = \sigma_p(r)$.

The half is exactly the cancellation between the first-moment term $V/\beta^2$ and the log-partition
term $V/(2\beta^2)$; equivalently, it is the statement that the Fisher information of the exponential
family $\{\pi_\beta\}$ with respect to the natural parameter $\theta = 1/\beta$ equals
$\operatorname{Var}_p(r)$ at $\theta = 0$, and that relative entropy is one half the Fisher quadratic
form to leading order.

---

## 6. The audit-drift law: the constant is the covariance

Let $f : \Omega \to \mathbb{R}$ be an arbitrary *audit statistic* — a bounded measurement one might
monitor (a classifier score, a length, an indicator of a forbidden behaviour).

**Lemma 6.1 (Exact audit identity).** For a positive distribution $p$ and $\beta > 0$,
$$\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f] \;=\;
\frac{1}{W_\beta}\,\sum_y p(y)\,\big(e^{s(y)} - 1\big)\big(f(y) - \mathbb{E}_p f\big).$$

*Proof.* By (2.1), $\mathbb{E}_{\pi_\beta}[f] = \mathbb{E}_p[e^{s}f]/W_\beta$. Expanding the
right-hand numerator,
$$\mathbb{E}_p\big[(e^{s}-1)(f - \mathbb{E}_p f)\big] = \mathbb{E}_p[e^{s}f] - \mathbb{E}_p f\cdot
W_\beta - \mathbb{E}_p[f] + \mathbb{E}_p f = \mathbb{E}_p[e^{s}f] - \mathbb{E}_p f \cdot W_\beta,$$
and dividing by $W_\beta$ gives $\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f]$. $\square$

**Lemma 6.2 (Numerator expansion).** If $p$ is a distribution, $\beta > 0$ and $\beta \ge R$, then
$$\Big|\sum_y p(y)\big(e^{s(y)}-1\big)\big(f(y)-\mathbb{E}_p f\big) -
\frac{\operatorname{Cov}_p(r,f)}{\beta}\Big| \;\le\; \frac{R(f)\operatorname{Var}_p(r)}{\beta^2}.$$

*Proof.* $\operatorname{Cov}_p(r,f)/\beta = \mathbb{E}_p[s\,(f - \mathbb{E}_p f)]$. Subtracting
termwise and using $|e^{s}-1-s| \le s^2$ (valid as $|s|\le1$) and $|f(y)-\mathbb{E}_p f| \le R(f)$,
the difference is at most $R(f)\,\mathbb{E}_p[s^2] = R(f)\operatorname{Var}_p(r)/\beta^2$. $\square$

**Theorem 6.3 (The audit-drift constant is the covariance).** Let $p$ be a positive distribution and
$\beta \ge R$, $\beta > 0$. Then for every $f$,
$$\Big|\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f] - \frac{\operatorname{Cov}_p(r,f)}{\beta}\Big|
\;\le\; \frac{3\,R(f)\operatorname{Var}_p(r)}{\beta^2}.$$

*Proof sketch.* Let $D$ denote the numerator of Lemma 6.1. Then
$$\mathbb{E}_{\pi_\beta}f - \mathbb{E}_p f - \frac{\operatorname{Cov}_p(r,f)}{\beta}
= \Big(D - \frac{\operatorname{Cov}_p(r,f)}{\beta}\Big) - D\,\frac{W_\beta-1}{W_\beta}.$$
The first bracket is $\le R(f)V/\beta^2$ by Lemma 6.2. For the second: $|\operatorname{Cov}_p(r,f)|
\le R\,R(f)$ by the pointwise bounds $|r-\mu|\le R$, $|f - \mathbb{E}_p f| \le R(f)$, so
$|\operatorname{Cov}_p(r,f)/\beta| \le R(f)$ when $\beta \ge R$; combined with Lemma 6.2 and
$V/\beta^2 \le 1$ (which follows from Popoviciu, $V \le R^2/4 \le \beta^2$) this gives $|D| \le
2R(f)$. Since $1 \le W_\beta \le 1 + V/\beta^2$ we get $|D|(W_\beta-1)/W_\beta \le 2R(f)V/\beta^2$.
Adding the two contributions gives the constant $3$. $\square$

**Corollary 6.4 (Audit limit law).** $\displaystyle \lim_{\beta\to\infty}
\beta\big(\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f]\big) = \operatorname{Cov}_p(r,f)$.

**Corollary 6.5 (Uncorrelated statistics are first-order unhackable).** If
$\operatorname{Cov}_p(r,f) = 0$ then $\beta(\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f]) \to 0$, i.e.
the drift of $f$ is $o(\beta^{-1})$.

**Remark 6.6 (Relation to the Cauchy–Schwarz bound).** The standard anti-reward-hacking guarantee
takes the form $|\mathbb{E}_{\pi_\beta}f - \mathbb{E}_p f| \le
\sigma_p(r)\sigma_p(f)e^{R/\beta}/\beta$. Theorem 6.3 identifies its content exactly: the true
first-order coefficient is $\operatorname{Cov}_p(r,f)$, and $|\operatorname{Cov}_p(r,f)| \le
\sigma_p(r)\sigma_p(f)$ is Cauchy–Schwarz. The bound is therefore tight exactly when $f$ is an affine
function of $r$, and arbitrarily loose otherwise — in particular, infinitely loose for uncorrelated
$f$, where the true constant vanishes but the bound does not.

---

## 7. The exact Pinsker defect along the alignment path

Pinsker's inequality states $\|q-p\|_1 \le \sqrt{2\,\mathrm{KL}(q\|p)}$ for all distributions. Along
the Gibbs path both sides are now known to first order, so the inequality can be audited exactly.

**Lemma 7.1.** $\beta\sqrt{2\,\mathrm{KL}(\pi_\beta\|p)} \to \sigma_p(r)$ as $\beta \to \infty$.

*Proof.* Immediate from Corollary 5.4 and continuity of the square root:
$\beta\sqrt{2\mathrm{KL}} = \sqrt{2\beta^2\mathrm{KL}} \to \sqrt{2 \cdot V/2} = \sigma_p(r)$.
$\square$

**Theorem 7.2 (Exact Pinsker defect).** Let $p$ be a positive distribution with
$\operatorname{Var}_p(r) > 0$. Then
$$\lim_{\beta\to\infty}\; \frac{\|\pi_\beta - p\|_1}{\sqrt{2\,\mathrm{KL}(\pi_\beta\|p)}}
\;=\; \frac{\operatorname{MAD}_p(r)}{\sigma_p(r)} \;\le\; 1 .$$

*Proof.* Multiply numerator and denominator by $\beta$ and apply Corollary 4.4 and Lemma 7.1; the
denominator limit $\sigma_p(r)$ is non-zero by hypothesis. The inequality is Corollary 3.2. $\square$

**Theorem 7.3 (Asymptotic tightness of Pinsker).** Under the hypotheses of Theorem 7.2, the limiting
Pinsker ratio equals $1$ if and only if $|r(y) - \mathbb{E}_p r| = \operatorname{MAD}_p(r)$ for every
$y$ — i.e. exactly for balanced two-valued rewards.

*Proof.* By Theorem 7.2 the ratio is $\operatorname{MAD}_p(r)/\sigma_p(r)$, which equals $1$ iff
$\operatorname{MAD}_p(r) = \sigma_p(r)$; apply Theorem 3.3. $\square$

This closes the circle. The standard-deviation constant of the classical drift law is *exactly* the
Pinsker relaxation of the true total-variation constant, and the amount lost is exactly the deviation
defect $\sigma_p(r) - \operatorname{MAD}_p(r)$ of the reward under the base policy.

---

## 8. Algorithms

The results are directly computable on finite $\Omega$. Three routines suffice.

**Algorithm A (Gibbs tilt in centred form).** Given $p$, $r$, $\beta$: compute $\mu = \sum_y p(y)r(y)$;
form $w(y) = \exp((r(y)-\mu)/\beta)$; set $W = \sum_y p(y)w(y)$; output $\pi(y) = p(y)w(y)/W$.
Centring is not cosmetic: it keeps $\exp$ arguments in $[-R/\beta, R/\beta] \subseteq [-1,1]$ for
$\beta \ge R$, so the computation is numerically stable at every temperature in the regime of
interest. Cost $O(|\Omega|)$.

**Algorithm B (Drift profile).** Given $p$, $r$ and a grid of temperatures, evaluate for each $\beta$
the three drift functionals $\|\pi_\beta-p\|_1$, $\mathrm{KL}(\pi_\beta\|p)$ and
$\mathbb{E}_{\pi_\beta}f - \mathbb{E}_p f$, together with the rescalings $\beta\|\cdot\|_1$,
$\beta^2\mathrm{KL}$ and $\beta \times$ audit gap, and compare against the predicted limits
$\operatorname{MAD}_p(r)$, $\tfrac12\operatorname{Var}_p(r)$, $\operatorname{Cov}_p(r,f)$. The
residuals should decay like $\beta^{-1}$ in the first and third case and $\beta^{-1}$ (relative to the
leading term) in the second. Cost $O(|\Omega|)$ per temperature.

**Algorithm C (Temperature budgeting).** Given a total-variation tolerance $\delta > 0$, return
$$\beta^\star = \max\Big\{R(r),\; \frac{\operatorname{MAD}_p(r)}{\delta} +
\frac{2\operatorname{Var}_p(r)}{\delta \cdot \max(R(r), \operatorname{MAD}_p(r)/\delta)}\Big\},$$
a temperature at which Theorem 4.3 certifies $\|\pi_{\beta^\star}-p\|_1 \le \delta$; in practice one
solves the quadratic $\operatorname{MAD}/\beta + 2\operatorname{Var}/\beta^2 = \delta$ exactly, giving
$$\beta^\star = \frac{\operatorname{MAD}_p(r) +
\sqrt{\operatorname{MAD}_p(r)^2 + 8\delta\operatorname{Var}_p(r)}}{2\delta},$$
clipped below at $R(r)$. This is a certificate, not a heuristic, and it requires no tuning: both
moments are computable from $p$ and $r$ in $O(|\Omega|)$ time.

**Algorithm D (Audit-metric screening).** Given a family of candidate audit statistics $f_1, \dots,
f_k$, compute $c_i = \operatorname{Cov}_p(r,f_i)$ and rank by $|c_i|$. By Theorem 6.3 the drift of
$f_i$ at temperature $\beta$ is $c_i/\beta \pm 3R(f_i)\operatorname{Var}_p(r)/\beta^2$; statistics
with $c_i = 0$ are first-order invariant. Cost $O(k|\Omega|)$.

---

## 9. Applications and interpretation

**Certified drift budgets.** To guarantee a total-variation change of at most $\delta$, take $\beta
\approx \operatorname{MAD}_p(r)/\delta$ (Algorithm C). Bounds of the form (1.3) instead demand
$\beta \approx \sqrt{2}\,\sigma_p(r)e^{R/2\beta}/\delta$, over-provisioning by the factor
$\sqrt{2}\,\sigma/\operatorname{MAD}$ — which Example 3.4 shows is unbounded. On a reward that fires
with probability $10^{-6}$, the over-provisioning factor exceeds $700$.

**Reward-shape diagnostics.** The single number $\operatorname{MAD}_p(r)/\sigma_p(r) \in (0,1]$
classifies rewards: values near $1$ indicate a balanced, essentially binary signal; values near $0$
indicate a rare spike, where the reward concentrates its variance on a low-probability set. By
Theorem 7.2 this same number is exactly the asymptotic slack in Pinsker's inequality along the
alignment path, so it simultaneously measures how much any KL-to-total-variation conversion is losing
on this reward.

**Audit design.** Corollary 6.5 turns metric selection into linear algebra: project the candidate
statistic onto the reward in $L^2(p)$. The component orthogonal to $r$ is first-order invariant under
alignment; the parallel component drifts at rate $\operatorname{Cov}_p(r,f)/\beta$. A safety metric
should be chosen (or orthogonalised) so that its correlation with the reward reflects only the
intended coupling. Conversely, an unexpectedly large $|\operatorname{Cov}_p(r,f)|$ for an undesirable
$f$ is a *pre-training* red flag: it predicts, quantitatively, that optimizing $r$ will move $f$, and
by how much, before any optimization is run.

**Interpretation of reward hacking.** In the weak-alignment regime, "reward hacking" has no residual
mystery: the drift of any statistic is exactly its covariance with the reward, over $\beta$. What
makes hacking surprising in practice is not the mechanism but the estimation problem — the covariance
is taken under the base policy, and rare high-reward regions contribute to it in ways that finite
samples underestimate.

---

## 10. Discussion and limitations

The results are exact but asymptotic in $\beta$, with fully explicit error terms valid on the
non-asymptotic range $\beta \ge R(r)$. Three limitations should be stated plainly.

1. **Finite outcome space.** All statements are for finite $\Omega$. The proofs use only Taylor
   bounds, Jensen's inequality and dominated finite sums, so they extend verbatim to any base measure
   under which $r$ is bounded; unbounded rewards with sub-Gaussian tails should admit the same laws
   with $R$ replaced by a tail parameter, but that is not proved here.

2. **The regime $\beta \ge R$.** Below the reward range the tilt is no longer a perturbation and the
   expansions fail; there the drift saturates (as $\beta \to 0$, $\pi_\beta$ concentrates on the
   argmax of $r$ and $\|\pi_\beta - p\|_1 \to 2(1 - p(\arg\max r))$). The transition between the
   linear-response regime and the concentration regime is not analysed here.

3. **Population, not sample.** The moments $\operatorname{MAD}_p(r)$, $\operatorname{Var}_p(r)$ and
   $\operatorname{Cov}_p(r,f)$ are taken under the exact base policy. In practice they are estimated
   from samples, and the $L^1$ functional $\operatorname{MAD}$ has different estimation behaviour from
   the variance — notably, it is not an unbiased plug-in under mean estimation. Sharp laws for
   estimated moments are open.

A conceptual remark. The corrected functional is not an accident of total variation being "unusual".
It is the expected outcome of a general principle: *the leading drift constant of a divergence is the
first cumulant or moment of the reward that the divergence does not annihilate*. Total variation is
homogeneous of degree $1$ in the perturbation, so it reads an $L^1$ moment; relative entropy is
degree $2$, so it reads a second cumulant; linear functionals read the mixed second moment. Any
proposed law that assigns the same constant to all three is, on this reading, conflating the
divergence with the statistic.

---

## 11. Future directions

### D1. Rényi-order interpolation of the drift functional

For $\alpha \in (0,\infty)$, we conjecture $D_\alpha(\pi_\beta\|p) = \alpha\operatorname{Var}_p(r)/
(2\beta^2) + O(\beta^{-3})$, and for the $L^q$ drift
$$\Big\|\frac{\pi_\beta - p}{p}\Big\|_{L^q(p)} = \frac{\|r - \mathbb{E}_p r\|_{L^q(p)}}{\beta} +
O(\beta^{-2}), \qquad q \in [1,\infty].$$
If so, the family of drift constants is exactly the family of centred $L^q$ norms of the reward:
$q=1$ gives $\operatorname{MAD}$ (total variation), $q=2$ gives $\sigma$ (the $\chi^2$/Pinsker
constant), $q=\infty$ gives the range. The three constants appearing in the literature are then not
competitors but the endpoints and midpoint of one interpolation family indexed by the divergence
order.

### D2. Higher-order expansions

The next term in each law should be a third cumulant: skewness for KL, and for total variation a
term involving $\mathbb{E}_p[(r-\mu)^2\operatorname{sgn}(r-\mu)]$. Establishing these would turn the
two-sided bounds into genuine asymptotic series and sharpen the budgeting rule of Algorithm C from a
certificate into a calibration.

### D3. Beyond bounded rewards and beyond finiteness

Extend the laws to sub-Gaussian rewards on general measurable spaces, with $R$ replaced by a tail
parameter. The centred-tilt identities of Lemmas 4.1, 5.2 and 6.1 are measure-theoretic and survive;
only the Taylor control needs a new argument.

### D4. Sequential and multi-step alignment

Real alignment is applied to autoregressive policies, where the reward is a function of a whole
trajectory. Does the drift of a per-token statistic decompose into a sum of per-step covariances? A
chain-rule version of Corollary 6.4 would give a token-level attribution of alignment drift.

### D5. Estimation theory for the sharp constants

Given $n$ samples from $p$ and noisy reward evaluations, what is the minimax rate for estimating
$\operatorname{MAD}_p(r)$ and $\operatorname{Cov}_p(r,f)$, and how does estimation error propagate
into the certified temperature $\beta^\star$? This is the gap between the exact laws proved here and
their deployment.

---

## 12. Summary of results

| Functional | Exact first-order law | Explicit error (valid for $\beta \ge R$) |
| --- | --- | --- |
| $\|\pi_\beta - p\|_1$ | $\operatorname{MAD}_p(r)/\beta$ | $-3V/\beta^2 \le \cdot \le +2V/\beta^2$ |
| $\mathrm{KL}(\pi_\beta\|p)$ | $\operatorname{Var}_p(r)/(2\beta^2)$ | $2RV/\beta^3 + 3V^2/\beta^4$ |
| $\mathbb{E}_{\pi_\beta}f - \mathbb{E}_p f$ | $\operatorname{Cov}_p(r,f)/\beta$ | $3R(f)V/\beta^2$ |
| $\|\pi_\beta-p\|_1/\sqrt{2\mathrm{KL}}$ | $\operatorname{MAD}_p(r)/\sigma_p(r)$ | $\to$, tight iff $|r-\mu|$ constant |

with $V = \operatorname{Var}_p(r)$, $R = R(r)$. Structural relations:
$\operatorname{MAD}_p(r) \le \sigma_p(r) \le R(r)/2$, the first with equality iff $|r-\mu|$ is
constant (Theorem 3.3), the second by Popoviciu (Lemma 2.6(ii)); and
$\operatorname{Var}_p(r) - \operatorname{MAD}_p(r)^2$ is the variance of the absolute deviation
(Theorem 3.1).
