# Reward Hacking Is a Covariance: First-Order Laws and a Sharp Hacking Threshold for KL-Regularized Policies

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

Let $p$ be a strictly positive probability distribution on a finite set $\Omega$ (a base or reference policy), let $r : \Omega \to \mathbb{R}$ be a bounded reward with $|r| \le R$, and let
$$\pi_\beta(y) = \frac{p(y)e^{r(y)/\beta}}{Z_\beta}, \qquad Z_\beta = \sum_{y \in \Omega} p(y)e^{r(y)/\beta},$$
be the exact maximizer of the KL-regularized objective $\mathbb{E}_\pi[r] - \beta\,\mathrm{KL}(\pi\|p)$. For an arbitrary *audit statistic* $f : \Omega \to \mathbb{R}$ define the **audit gap** $G(\beta) = \mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f]$.

We prove that the audit gap is, exactly at every regularization strength, the covariance of $f$ with the likelihood ratio $\pi_\beta/p$; that this covariance linearizes with an explicit constant,
$$\Big|G(\beta) - \frac{\mathrm{Cov}_p(r,f)}{\beta}\Big| \;\le\; 24\Big(\frac{R}{\beta}\Big)^2 \sigma_p(f) \qquad (0 < R \le \beta);$$
and that the leading coefficient is attained, $\beta G(\beta) \to \mathrm{Cov}_p(r,f)$. Consequently a statistic uncorrelated with the reward drifts only at order $\beta^{-2}$.

The two-sided envelope this produces yields a **sharp hacking threshold**. Defining the critical regularization strength at auditor tolerance $\varepsilon$ as $\beta_c(\varepsilon) = \sup\{\beta \ge R : |G(\beta)| \ge \varepsilon\}$, we prove an explicit two-sided window $(1-\delta)|\mathrm{Cov}_p(r,f)|/\varepsilon \le \beta_c(\varepsilon) \le (1+\delta)|\mathrm{Cov}_p(r,f)|/\varepsilon$ for all sufficiently small $\varepsilon$, hence
$$\varepsilon\,\beta_c(\varepsilon) \longrightarrow \big|\mathrm{Cov}_p(r,f)\big| \qquad (\varepsilon \downarrow 0).$$
Reward hacking of a statistic at tolerance $\varepsilon$ switches on exactly at $\beta_c(\varepsilon) = (1+o(1))|\mathrm{Cov}_p(r,f)|/\varepsilon$.

We extend the expansion to second order, where the coefficient is the **skew covariance** $\mathrm{SkewCov}_p(r,f) = \mathbb{E}_p[(r-\mathbb{E}_p r)^2 (f - \mathbb{E}_p f)]$, with remainder $40(R/\beta)^3\sigma_p(f)$ and exact limit $\beta^2(G(\beta) - \mathrm{Cov}_p(r,f)/\beta) \to \mathrm{SkewCov}_p(r,f)/2$. Finally we show both orders are attained: on the symmetric two-point model the gap is exactly $\tanh(R/\beta)$, and on the biased two-point model $\mathrm{SkewCov} = 8R^2q(1-q)(1-2q) \ne 0$, so the exponent $2$ in the first-order law cannot be improved to any $o(\beta^{-2})$.

**Keywords:** reward hacking, KL-regularized policy optimization, Gibbs measure, linear response, covariance, phase transition, alignment auditing.

---

## 1. Introduction

### 1.1 The problem

Fine-tuning a generative model against a learned reward reliably produces two effects: the reward goes up, and other, unmonitored quantities move. The second effect is variously called *reward hacking*, *specification gaming*, or *proxy drift*, and it is usually discussed qualitatively — as though the drift depended on the optimizer's search dynamics, or on the discovery of "loopholes" in the reward.

This paper argues, and proves, that under the standard KL-regularized objective the drift is not dynamical at all. It is a fixed, computable functional of the base model: the covariance of the drifting statistic with the reward. Nothing about the optimizer, the training trajectory, or the number of gradient steps enters the leading term.

### 1.2 Setting and conventions

Throughout, $\Omega$ is a finite nonempty set of responses. A **distribution** is $p : \Omega \to \mathbb{R}$ with $p \ge 0$ and $\sum_y p(y) = 1$; it is a **positive distribution** if $p(y) > 0$ for all $y$. We write
$$\mathbb{E}_p[f] = \sum_y p(y)f(y), \qquad \mathrm{Var}_p(f) = \mathbb{E}_p[(f - \mathbb{E}_p f)^2], \qquad \sigma_p(f) = \sqrt{\mathrm{Var}_p(f)},$$
$$\mathrm{Cov}_p(f,g) = \mathbb{E}_p\big[(f-\mathbb{E}_p f)(g - \mathbb{E}_p g)\big].$$

The reward $r : \Omega \to \mathbb{R}$ satisfies $|r(y)| \le R$ for all $y$; the parameter $\beta > 0$ is the KL penalty coefficient, so that *large* $\beta$ corresponds to a *weak, conservative* update. All results are stated in the perturbative regime $R \le \beta$; the constants are explicit and not optimized.

### 1.3 Contributions

1. **An exact identity** (Theorem 3.3): $G(\beta) = \mathrm{Cov}_p(\pi_\beta/p,\, f)$ at every $\beta$, with no error term.
2. **The first-order law** (Theorem 4.3): $|G(\beta) - \mathrm{Cov}_p(r,f)/\beta| \le 24(R/\beta)^2\sigma_p(f)$, with the alignment corollary that uncorrelated statistics move only at order $\beta^{-2}$ (Corollary 4.4).
3. **Exactness of the coefficient** (Theorem 5.2): $\beta G(\beta) \to \mathrm{Cov}_p(r,f)$, so the covariance is the drift rate and not merely a bound.
4. **A sharp hacking threshold** (Theorems 6.5, 6.6, 6.7): a two-sided window for the critical regularization strength $\beta_c(\varepsilon)$ and the limit $\varepsilon\beta_c(\varepsilon) \to |\mathrm{Cov}_p(r,f)|$.
5. **The second-order coefficient** (Theorems 7.3, 7.4): the skew covariance, with cubic remainder and second-order safety for statistics orthogonal to both $r$ and $(r-\mathbb{E}_p r)^2$.
6. **Optimality** (Section 8): closed forms on two-point models showing both the $\beta^{-1}$ constant and the $\beta^{-2}$ exponent are attained.

### 1.4 Relation to classical linear response

Readers from statistical physics will recognize the shape of Theorem 4.3. A Gibbs measure tilted by a field responds, to first order in the field strength, through the covariance of the observable with the field — the fluctuation–dissipation relation. The contribution here is not the heuristic but the quantitative apparatus: two-sided bounds with explicit constants in the exact regime that governs practical fine-tuning, and, on top of them, a genuine sharp-threshold theorem for the critical regularization strength, which is not a classical linear-response statement.

---

## 2. Moments of the reference policy

We record the elementary identities used throughout. Let $p$ be a distribution on the finite set $\Omega$.

**Lemma 2.1 (Raw-moment form of the covariance).** $\mathrm{Cov}_p(f,g) = \mathbb{E}_p[fg] - \mathbb{E}_p[f]\,\mathbb{E}_p[g]$.

*Proof sketch.* Expand the product $(f - \mathbb{E}_p f)(g - \mathbb{E}_p g)$ pointwise and use $\sum_y p(y) = 1$ three times. $\square$

**Lemma 2.2 (Bilinearity).** $\mathrm{Cov}_p$ is symmetric, additive in each argument, and $\mathrm{Cov}_p(g/c, f) = \mathrm{Cov}_p(g,f)/c$ for $c \ne 0$. Moreover $\mathrm{Cov}_p(f,f) = \mathrm{Var}_p(f) \ge 0$, and $\mathrm{Cov}_p(g,f)$ is unchanged if a constant is added to $g$.

**Lemma 2.3 (Pair representation of the variance).**
$$\mathrm{Var}_p(f) \;=\; \frac{1}{2}\sum_{x \in \Omega}\sum_{y \in \Omega} p(x)p(y)\big(f(x)-f(y)\big)^2 .$$

*Proof sketch.* Expand $(f(x)-f(y))^2 = f(x)^2 - 2f(x)f(y) + f(y)^2$, sum in $y$ then in $x$ using $\sum p = 1$, and compare with $\mathrm{Var}_p(f) = \mathbb{E}_p[f^2] - (\mathbb{E}_p f)^2$. $\square$

This representation is what converts a *uniform oscillation* estimate into a variance estimate, which is the engine of every remainder bound below.

**Lemma 2.4 (Oscillation controls the standard deviation).** If $|g(x) - g(y)| \le c$ for all $x,y \in \Omega$, with $c \ge 0$, then $\sigma_p(g) \le c$.

*Proof sketch.* By Lemma 2.3, each summand obeys $p(x)p(y)(g(x)-g(y))^2 \le p(x)p(y)c^2$, and $\sum_{x,y}p(x)p(y)c^2 = c^2$; hence $\mathrm{Var}_p(g) \le c^2/2 \le c^2$. Take square roots. $\square$

**Lemma 2.5 (Cauchy–Schwarz).** $|\mathrm{Cov}_p(f,g)| \le \sigma_p(f)\,\sigma_p(g)$.

*Proof sketch.* Apply the discrete Cauchy–Schwarz inequality to the vectors $y \mapsto \sqrt{p(y)}(f(y)-\mathbb{E}_p f)$ and $y \mapsto \sqrt{p(y)}(g(y)-\mathbb{E}_p g)$, whose inner product is $\mathrm{Cov}_p(f,g)$ and whose squared norms are $\mathrm{Var}_p(f)$ and $\mathrm{Var}_p(g)$. $\square$

Lemmas 2.4 and 2.5 combine into the workhorse of the paper: *if a reweighting function $g$ oscillates by at most $c$, then it can move the mean of any statistic $f$ by at most $c\,\sigma_p(f)$.*

---

## 3. The aligned policy and the exact covariance identity

**Definition 3.1 (Partition function, Gibbs policy, likelihood ratio).** For $\beta \ne 0$ set
$$Z_\beta \;=\; \sum_{y}p(y)e^{r(y)/\beta}, \qquad \pi_\beta(y) \;=\; \frac{p(y)e^{r(y)/\beta}}{Z_\beta}, \qquad L_\beta(y) \;=\; \frac{e^{r(y)/\beta}}{Z_\beta}.$$
Then $\pi_\beta(y) = p(y)L_\beta(y)$, and $\pi_\beta$ is a probability distribution.

$\pi_\beta$ is the unique maximizer of $\mathbb{E}_\pi[r] - \beta\,\mathrm{KL}(\pi\|p)$ over distributions absolutely continuous with respect to $p$; this is the standard closed form for the KL-regularized policy optimization objective and is the reason the family is the right object of study.

**Lemma 3.2 (Normalization).** If $p$ is a positive distribution then $Z_\beta > 0$ and $\mathbb{E}_p[L_\beta] = 1$.

*Proof sketch.* Positivity is a sum of positive terms; $\mathbb{E}_p[L_\beta] = \sum_y p(y)e^{r(y)/\beta}/Z_\beta = Z_\beta/Z_\beta = 1$. $\square$

**Theorem 3.3 (The audit gap is exactly a covariance).** For every positive distribution $p$, every $\beta \ne 0$, and every statistic $f$,
$$G(\beta) \;=\; \mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f] \;=\; \mathrm{Cov}_p\big(L_\beta,\, f\big).$$

*Proof.* By Lemma 2.1, $\mathrm{Cov}_p(L_\beta,f) = \mathbb{E}_p[L_\beta f] - \mathbb{E}_p[L_\beta]\mathbb{E}_p[f]$. By Lemma 3.2 the second term is $\mathbb{E}_p[f]$, and $\mathbb{E}_p[L_\beta f] = \sum_y p(y)L_\beta(y)f(y) = \sum_y \pi_\beta(y) f(y) = \mathbb{E}_{\pi_\beta}[f]$. $\square$

Theorem 3.3 is exact — no perturbative hypothesis, no error term. It already contains the qualitative message: *what fine-tuning moves is what covaries, under the base model, with the reweighting fine-tuning applies.* Everything that follows is the quantitative analysis of the reweighting $L_\beta$.

---

## 4. The first-order law

The linearization $L_\beta \approx 1 + r/\beta$ is made precise by an oscillation estimate. Two preliminary bounds are needed.

**Lemma 4.1 (The partition function is close to one).** If $p$ is a positive distribution, $|r| \le R$ and $0 < R \le \beta$, then
$$\tfrac13 \le Z_\beta \le 3 \qquad\text{and}\qquad |Z_\beta - 1| \le 3\frac{R}{\beta}.$$

*Proof sketch.* For the lower bound, $r(y)/\beta \ge -1$ pointwise, so $Z_\beta \ge e^{-1} \ge 1/3$ (using $e \le 3$). For the two-sided bound, write $Z_\beta - 1 = \sum_y p(y)(e^{r(y)/\beta}-1)$ and apply the elementary inequality $|e^u - 1| \le 2|u|$ valid for $|u| \le 1$, with $|r(y)/\beta| \le R/\beta \le 1$. $\square$

**Lemma 4.2 (The likelihood ratio is its own linearization).** Under the hypotheses of Lemma 4.1, for all $x,y \in \Omega$,
$$\Big|\Big(L_\beta(x) - \frac{r(x)}{\beta}\Big) - \Big(L_\beta(y) - \frac{r(y)}{\beta}\Big)\Big| \;\le\; 24\Big(\frac{R}{\beta}\Big)^2 .$$

*Proof.* Write $u_z = r(z)/\beta$, so $|u_z| \le R/\beta \le 1$. Algebraically,
$$\Big(L_\beta(x) - u_x\Big) - \Big(L_\beta(y)-u_y\Big) \;=\; \frac{\big[(e^{u_x}-1-u_x) - (e^{u_y}-1-u_y)\big] \;+\; (1 - Z_\beta)(u_x - u_y)}{Z_\beta}.$$
For the numerator: the Taylor bound $|e^u - 1 - u| \le u^2$ for $|u|\le 1$ gives $|(e^{u_x}-1-u_x) - (e^{u_y}-1-u_y)| \le 2(R/\beta)^2$; and by Lemma 4.1 together with $|u_x - u_y| \le 2R/\beta$ we get $|(1-Z_\beta)(u_x-u_y)| \le 3(R/\beta)\cdot 2(R/\beta) = 6(R/\beta)^2$. The numerator is therefore at most $8(R/\beta)^2$ in absolute value. Dividing by $Z_\beta \ge 1/3$ gives the bound $24(R/\beta)^2$. $\square$

**Theorem 4.3 (First-order reward-hacking law).** Let $p$ be a positive distribution on a finite set, $|r| \le R$, and $0 < R \le \beta$. Then for every statistic $f$,
$$\left| \; \mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f] - \frac{\mathrm{Cov}_p(r,f)}{\beta} \; \right| \;\le\; 24\left(\frac{R}{\beta}\right)^{2}\sigma_p(f).$$

*Proof.* By Theorem 3.3, $G(\beta) = \mathrm{Cov}_p(L_\beta, f)$. Split $L_\beta = (r/\beta) + (L_\beta - r/\beta)$ and use bilinearity (Lemma 2.2):
$$G(\beta) = \frac{\mathrm{Cov}_p(r,f)}{\beta} + \mathrm{Cov}_p\Big(L_\beta - \frac{r}{\beta},\, f\Big).$$
The residual covariance is bounded by Cauchy–Schwarz (Lemma 2.5) by $\sigma_p(L_\beta - r/\beta)\,\sigma_p(f)$, and by Lemmas 2.4 and 4.2 the first factor is at most $24(R/\beta)^2$. $\square$

**Corollary 4.4 (Uncorrelated statistics are second-order safe).** If additionally $\mathrm{Cov}_p(r,f) = 0$, then
$$\big|\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f]\big| \;\le\; 24\left(\frac{R}{\beta}\right)^{2}\sigma_p(f).$$

The interpretation is the central alignment reading of the theory. Reward hacking, at leading order, is not a generic perturbation of all measurable behaviour: it is a perturbation *along the reward direction* in $L^2(p)$. Statistics orthogonal to the reward are quadratically protected.

**Remark 4.5 (Scale invariance).** Both sides of Theorem 4.3 are homogeneous of degree $1$ in $f$ and, replacing $(r,\beta)$ by $(\lambda r, \lambda \beta)$, invariant. Only the dimensionless ratio $R/\beta$ — the *effective tilt* — controls the accuracy of the expansion.

---

## 5. The covariance is exactly the hacking rate

An upper bound alone would leave open the possibility that the true drift is much smaller than $\mathrm{Cov}_p(r,f)/\beta$. It is not.

**Definition 5.1.** Write $K = 24R^2\sigma_p(f) \ge 0$ for the remainder constant, so that Theorem 4.3 reads $|G(\beta) - \mathrm{Cov}_p(r,f)/\beta| \le K/\beta^2$.

**Theorem 5.2 (Exact first-order rate).** If $p$ is a positive distribution and $|r| \le R$, then
$$\lim_{\beta \to \infty} \beta\,G(\beta) \;=\; \mathrm{Cov}_p(r,f).$$

*Proof.* For $\beta \ge \max(R,1)$, Theorem 4.3 gives $|\beta G(\beta) - \mathrm{Cov}_p(r,f)| = \beta|G(\beta) - \mathrm{Cov}_p(r,f)/\beta| \le K/\beta$, which tends to $0$. $\square$

**Corollary 5.3 (Two-sided envelope).** For $0 < R \le \beta$,
$$\frac{|\mathrm{Cov}_p(r,f)|}{\beta} - \frac{K}{\beta^2} \;\le\; |G(\beta)| \;\le\; \frac{|\mathrm{Cov}_p(r,f)|}{\beta} + \frac{K}{\beta^2}.$$

*Proof.* Both inequalities are the reverse triangle inequality $\big||a|-|b|\big| \le |a-b|$ applied to $a = G(\beta)$, $b = \mathrm{Cov}_p(r,f)/\beta$, together with $|\mathrm{Cov}_p(r,f)/\beta| = |\mathrm{Cov}_p(r,f)|/\beta$ for $\beta > 0$. $\square$

The *lower* envelope is the new ingredient. It converts a safety statement into an inevitability statement: any statistic with nonzero reward covariance is guaranteed to move, by a computable amount, as soon as $\beta$ is small enough that $K/\beta^2$ no longer dominates $|\mathrm{Cov}_p(r,f)|/\beta$ — i.e. as soon as $\beta \gg K/|\mathrm{Cov}_p(r,f)|$.

---

## 6. The sharp hacking threshold

### 6.1 Formulation

Fix an auditor's tolerance $\varepsilon > 0$: the smallest shift in $f$ the auditor will act on.

**Definition 6.1 (Hacked set and critical strength).**
$$H(\varepsilon) \;=\; \{\beta \in \mathbb{R} : R \le \beta \text{ and } |G(\beta)| \ge \varepsilon\}, \qquad \beta_c(\varepsilon) \;=\; \sup H(\varepsilon).$$

We restrict to $\beta \ge R$ because that is the regime in which the perturbative envelope is valid; the definition of $\beta_c$ as a *supremum* rather than a crossing point is essential and is discussed in Remark 6.8.

Two elementary one-sided statements do all the work.

**Proposition 6.2 (Hacked below the threshold).** Let $0 < \delta$, $|\mathrm{Cov}_p(r,f)| > 0$, $0 < R \le \beta$, and suppose
$$2K \le \delta\,|\mathrm{Cov}_p(r,f)|\,\beta \qquad\text{and}\qquad \varepsilon\beta \le (1-\delta)|\mathrm{Cov}_p(r,f)|.$$
Then $|G(\beta)| > \varepsilon$.

*Proof sketch.* By Corollary 5.3 it suffices to show $\varepsilon < |\mathrm{Cov}|/\beta - K/\beta^2$, i.e. $\varepsilon\beta^2 < |\mathrm{Cov}|\beta - K$. The first hypothesis gives $K \le \tfrac{\delta}{2}|\mathrm{Cov}|\beta$, and the second gives $\varepsilon\beta^2 \le (1-\delta)|\mathrm{Cov}|\beta$; combining, $|\mathrm{Cov}|\beta - K - \varepsilon\beta^2 \ge \tfrac{\delta}{2}|\mathrm{Cov}|\beta > 0$. $\square$

**Proposition 6.3 (Safe above the threshold).** Under $0 < R \le \beta$, $2K \le \delta|\mathrm{Cov}_p(r,f)|\beta$ and $(1+\delta)|\mathrm{Cov}_p(r,f)| \le \varepsilon\beta$, one has $|G(\beta)| \le \varepsilon$; with the last inequality strict, $|G(\beta)| < \varepsilon$.

*Proof sketch.* By Corollary 5.3 it suffices that $|\mathrm{Cov}|\beta + K \le \varepsilon\beta^2$, which follows by the same two substitutions. $\square$

The multiplicative formulation ($\varepsilon\beta \le (1-\delta)|\mathrm{Cov}|$) rather than the divided one ($\beta \le (1-\delta)|\mathrm{Cov}|/\varepsilon$) is what keeps the estimates uniform and free of case analysis on the sign of denominators.

### 6.2 The window

**Theorem 6.4 (The hacked set is bounded).** Assume $p$ positive, $|r| \le R$, $R>0$, $\varepsilon>0$, $\delta \in (0,1)$, $C := |\mathrm{Cov}_p(r,f)| > 0$, and the smallness condition
$$(\star)\qquad 2K\varepsilon \;\le\; \delta(1-\delta)\,C^2 .$$
Then $H(\varepsilon) \subseteq (-\infty,\ (1+\delta)C/\varepsilon]$.

*Proof sketch.* Suppose $\beta \in H(\varepsilon)$ with $\beta > (1+\delta)C/\varepsilon$, so $(1+\delta)C < \varepsilon\beta$ and in particular $(1-\delta)C < \varepsilon\beta$. Multiplying the latter by $\delta C > 0$ and combining with $(\star)$ gives $2K\varepsilon \le \delta(1-\delta)C^2 \le \delta C\,(\varepsilon\beta) = (\delta C\beta)\varepsilon$; dividing by $\varepsilon > 0$ yields $2K \le \delta C\beta$. Proposition 6.3 (strict form) then gives $|G(\beta)| < \varepsilon$, contradicting $\beta \in H(\varepsilon)$. $\square$

**Theorem 6.5 (The window is nonempty).** Under the hypotheses of Theorem 6.4 together with
$$(\star\star)\qquad \varepsilon R \;\le\; (1-\delta)C ,$$
the point $\beta^- := (1-\delta)C/\varepsilon$ belongs to $H(\varepsilon)$.

*Proof sketch.* $(\star\star)$ gives $R \le \beta^-$, so $\beta^-$ is in the admissible range; $\varepsilon\beta^- = (1-\delta)C$ exactly; and $(\star)$ gives $2K \le \delta C \beta^-$. Proposition 6.2 applies and yields $|G(\beta^-)| > \varepsilon$. $\square$

**Theorem 6.6 (Critical-strength window).** Under $(\star)$ and $(\star\star)$,
$$(1-\delta)\frac{|\mathrm{Cov}_p(r,f)|}{\varepsilon} \;\le\; \beta_c(\varepsilon) \;\le\; (1+\delta)\frac{|\mathrm{Cov}_p(r,f)|}{\varepsilon}.$$

*Proof.* Theorem 6.4 shows $H(\varepsilon)$ is bounded above by $(1+\delta)C/\varepsilon$, so the supremum exists and obeys the upper bound. Theorem 6.5 exhibits an element $\beta^- = (1-\delta)C/\varepsilon$ of $H(\varepsilon)$, so the supremum is at least $\beta^-$. $\square$

**Theorem 6.7 (Sharp threshold).** If $p$ is a positive distribution, $|r| \le R$ with $R > 0$, and $\mathrm{Cov}_p(r,f) \ne 0$, then
$$\lim_{\varepsilon \downarrow 0} \varepsilon\,\beta_c(\varepsilon) \;=\; \big|\mathrm{Cov}_p(r,f)\big|, \qquad\text{equivalently}\qquad \beta_c(\varepsilon) = (1+o(1))\frac{|\mathrm{Cov}_p(r,f)|}{\varepsilon}.$$

*Proof.* Given $\eta > 0$, put $C = |\mathrm{Cov}_p(r,f)|$ and choose $\delta = \min\{1/2,\ \eta/(2C)\}$, so $\delta \in (0,1)$ and $\delta C \le \eta/2$. Both $(\star)$ and $(\star\star)$ hold for all
$$0 < \varepsilon < \min\left\{\frac{(1-\delta)C}{R},\ \frac{\delta(1-\delta)C^2}{2K+1}\right\},$$
and Theorem 6.6 then yields $|\varepsilon\beta_c(\varepsilon) - C| \le \delta C \le \eta/2 < \eta$. $\square$

The rewriting of Theorem 6.6 into the quantitative form $|\varepsilon\beta_c(\varepsilon) - C| \le \delta C$ is immediate from the window and is the statement one actually uses in applications: the relative error in the threshold is at most $\delta$.

**Remark 6.8 (Why a supremum, and not a crossing point).** It is tempting to define the critical strength as the unique $\beta$ at which $|G(\beta)|$ crosses $\varepsilon$. This is not available: $|G|$ need not be monotone in $\beta$ for general $r$ and $f$. The envelope of Corollary 5.3 constrains $|G|$ only to the band $|\mathrm{Cov}|/\beta \pm K/\beta^2$, inside which the gap may oscillate, and there exist rewards and statistics for which the sign of $G$ itself changes with $\beta$ (e.g. when $\mathrm{Cov}_p(r,f)$ and $\mathrm{SkewCov}_p(r,f)$ have opposite signs and $\beta$ is near the crossover, before the perturbative regime settles). The order-theoretic definition $\beta_c = \sup H(\varepsilon)$ sidesteps this entirely: it needs no regularity of $G$, only the two one-sided propositions, and it delivers the same asymptotics one would want from a crossing point. This is a transferable lesson: when the natural crossing point may fail to be unique, define the threshold as the supremum of the "hacked" region and prove a two-sided sandwich.

**Remark 6.9 (Operational reading).** Theorem 6.7 says that to keep a monitored statistic $f$ within tolerance $\varepsilon$ one must take
$$\beta \;\gtrsim\; \frac{|\mathrm{Cov}_p(r,f)|}{\varepsilon},$$
and that this requirement is *tight*: any smaller penalty leaves strengths at which the statistic is hacked. Halving the tolerance doubles the required regularization. Since $\mathrm{Cov}_p(r,f)$ is a base-model quantity, the entire calibration can be done before any fine-tuning takes place.

---

## 7. Second order: the skew covariance

### 7.1 Definition and algebra

**Definition 7.1 (Skew covariance).**
$$\mathrm{SkewCov}_p(r,f) \;=\; \mathbb{E}_p\big[(r - \mathbb{E}_p r)^2\,(f - \mathbb{E}_p f)\big].$$

**Lemma 7.2.** $\mathrm{SkewCov}_p(r,f) = \mathrm{Cov}_p(r^2, f) - 2\,\mathbb{E}_p[r]\,\mathrm{Cov}_p(r,f)$.

*Proof sketch.* Expand $(r-\mathbb{E}_p r)^2 = r^2 - 2\mathbb{E}_p[r]\,r + (\mathbb{E}_p r)^2$, pair each term against the centred statistic $f - \mathbb{E}_p f$, and use that pairing a *constant* against a centred function gives $0$ (a covariance only needs one argument centred). $\square$

Thus $\mathrm{SkewCov}$ is the covariance of $f$ with the *squared fluctuation* of the reward — a genuine third-moment object, mixed of degree $2$ in $r$ and degree $1$ in $f$.

### 7.2 The quadratic model

Define the second-order model of the likelihood ratio
$$Q_\beta(y) \;=\; \frac{r(y)}{\beta} + \frac{1}{2}\left(\frac{r(y)}{\beta}\right)^{2} - \frac{\mathbb{E}_p[r]}{\beta}\cdot\frac{r(y)}{\beta},$$
normalized to have no constant term (constants are invisible inside a covariance). The three terms are exactly the second-order Taylor expansion of $e^{r/\beta}$ divided by the second-order expansion $Z_\beta \approx 1 + \mathbb{E}_p[r]/\beta$ of the partition function.

**Lemma 7.3 (The quadratic model reproduces both orders).** For $\beta \ne 0$,
$$\mathrm{Cov}_p(Q_\beta, f) \;=\; \frac{\mathrm{Cov}_p(r,f)}{\beta} + \frac{\mathrm{SkewCov}_p(r,f)}{2\beta^2}.$$

*Proof sketch.* Write each covariance as $\sum_y p(y)\,g(y)\,(f(y)-\mathbb{E}_p f)$ (only one argument need be centred). Then linearity in $g$ gives
$$\mathrm{Cov}_p(Q_\beta,f) = \frac{1}{\beta}\mathrm{Cov}_p(r,f) + \frac{1}{2\beta^2}\mathrm{Cov}_p(r^2,f) - \frac{\mathbb{E}_p[r]}{\beta^2}\mathrm{Cov}_p(r,f),$$
which equals the claimed expression by Lemma 7.2. $\square$

The cubic oscillation estimate parallels Lemma 4.2, using the third-order Taylor bound $|e^u - 1 - u - u^2/2| \le |u|^3$ for $|u| \le 1$ together with the refined partition estimate $|Z_\beta - 1 - \mathbb{E}_p[r]/\beta| \le (R/\beta)^2$; the outcome is that $L_\beta - Q_\beta$ has oscillation at most $40(R/\beta)^3$.

**Theorem 7.4 (Second-order law).** For $p$ positive, $|r| \le R$ and $0 < R \le \beta$,
$$\left| \; \mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f] - \frac{\mathrm{Cov}_p(r,f)}{\beta} - \frac{\mathrm{SkewCov}_p(r,f)}{2\beta^2} \; \right| \;\le\; 40\left(\frac{R}{\beta}\right)^{3}\sigma_p(f).$$

*Proof.* As in Theorem 4.3: $G(\beta) = \mathrm{Cov}_p(L_\beta,f) = \mathrm{Cov}_p(Q_\beta,f) + \mathrm{Cov}_p(L_\beta - Q_\beta, f)$; substitute Lemma 7.3 for the first term and bound the second by $\sigma_p(L_\beta - Q_\beta)\sigma_p(f) \le 40(R/\beta)^3\sigma_p(f)$ using Lemmas 2.4, 2.5 and the cubic oscillation estimate. $\square$

**Theorem 7.5 (Exact second-order rate).** $\displaystyle \lim_{\beta\to\infty}\beta^2\Big(G(\beta) - \frac{\mathrm{Cov}_p(r,f)}{\beta}\Big) = \frac{\mathrm{SkewCov}_p(r,f)}{2}.$

*Proof.* Multiply Theorem 7.4 by $\beta^2$: the error becomes $40R^3\sigma_p(f)/\beta \to 0$. $\square$

**Corollary 7.6 (Second-order safety).** If $\mathrm{Cov}_p(r,f) = 0$ and $\mathrm{SkewCov}_p(r,f) = 0$, then $|G(\beta)| \le 40(R/\beta)^3\sigma_p(f)$.

Thus there is a *hierarchy of audit invariants*: a statistic is first-order safe iff it is $L^2(p)$-orthogonal to $r$, and second-order safe iff it is in addition orthogonal to $(r - \mathbb{E}_p r)^2$.

---

## 8. Both orders are attained

### 8.1 The symmetric two-point model

Take $\Omega = \{+,-\}$, $p(+) = p(-) = 1/2$, $r(\pm) = \pm R$, $f(\pm) = \pm 1$.

**Proposition 8.1.** $\mathbb{E}_p[r] = \mathbb{E}_p[f] = 0$, $\sigma_p(f) = 1$, $\mathrm{Cov}_p(r,f) = R$, $Z_\beta = \cosh(R/\beta)$, and
$$G(\beta) \;=\; \tanh\!\left(\frac{R}{\beta}\right).$$

*Proof sketch.* $Z_\beta = \tfrac12(e^{R/\beta}+e^{-R/\beta}) = \cosh(R/\beta)$ and $\mathbb{E}_{\pi_\beta}[f] = \tfrac{\frac12 e^{R/\beta} - \frac12 e^{-R/\beta}}{\cosh(R/\beta)} = \tanh(R/\beta)$, while $\mathbb{E}_p[f] = 0$. $\square$

**Corollary 8.2 (The first-order constant is attained).** $\beta\,G(\beta) = \beta\tanh(R/\beta) \to R = \mathrm{Cov}_p(r,f)$ as $\beta\to\infty$, and $G(\beta) > 0$ for all $\beta,R>0$: the aligned policy always moves the aligned statistic in the reward's direction.

**Corollary 8.3 (Closed-form threshold).** Since $\beta \mapsto \tanh(R/\beta)$ is strictly decreasing and positive, for $0 < \varepsilon < \tanh(1)$ the hacked set is exactly $[R,\ R/\operatorname{artanh}\varepsilon]$ and
$$\beta_c(\varepsilon) = \frac{R}{\operatorname{artanh}\varepsilon} = \frac{R}{\varepsilon}\Big(1 - \frac{\varepsilon^2}{3} + O(\varepsilon^4)\Big),$$
so $\varepsilon\beta_c(\varepsilon) \to R = |\mathrm{Cov}_p(r,f)|$, in agreement with Theorem 6.7 and with the sharper information that the relative error is $O(\varepsilon^2)$ in this model.

The symmetric model has $\mathrm{SkewCov} = 0$ by symmetry (the centred reward squared is constant), consistent with $\tanh$ being odd: the expansion is $R/\beta - R^3/(3\beta^3) + \dots$, with no $\beta^{-2}$ term.

### 8.2 The biased two-point model: optimality of the exponent

Now take $p(+) = q$, $p(-) = 1-q$ with $q \in (0,1)$, keeping $r(\pm) = \pm R$ and $f(\pm)=\pm1$.

**Proposition 8.4.** $\mathbb{E}_p[f] = 2q-1$, $\mathbb{E}_p[r] = R(2q-1)$, and
$$\mathrm{Cov}_p(r,f) = 4Rq(1-q), \qquad \mathrm{SkewCov}_p(r,f) = 8R^2q(1-q)(1-2q).$$

*Proof sketch.* $\mathbb{E}_p[rf] = qR + (1-q)R = R$, so $\mathrm{Cov} = R - R(2q-1)^2 = 4Rq(1-q)$. For the skew covariance use Lemma 7.2 with $r^2 \equiv R^2$ constant, so $\mathrm{Cov}_p(r^2,f) = 0$ and $\mathrm{SkewCov} = -2R(2q-1)\cdot 4Rq(1-q) = 8R^2q(1-q)(1-2q)$. $\square$

**Corollary 8.5 (The $\beta^{-2}$ remainder is genuinely present).** For $q\in(0,1)$,
$$\beta^2\left(G(\beta) - \frac{\mathrm{Cov}_p(r,f)}{\beta}\right) \;\longrightarrow\; 4R^2q(1-q)(1-2q),$$
which is nonzero whenever $R > 0$ and $q \ne 1/2$. Hence the remainder in Theorem 4.3 is **not** $o(\beta^{-2})$, and the exponent $2$ there is optimal.

*Proof.* Theorem 7.5 with Proposition 8.4. If the rescaled remainder tended to $0$, uniqueness of limits would force $\mathrm{SkewCov}_p(r,f)=0$, contradicting $8R^2q(1-q)(1-2q)\ne0$. $\square$

Interpretively: it is *skewness of the base model* that opens the second-order hacking channel. A symmetric base model is protected at order $\beta^{-2}$; a biased one is not.

---

## 9. Algorithms

Three computations follow directly from the theory, all performed on the base model.

**A. Audit-gap oracle.** Given $p$, $r$, $f$, $\beta$: compute $w_y = p_y e^{r_y/\beta}$, normalize, return $\sum_y \pi_\beta(y)f(y) - \sum_y p(y) f(y)$. Cost $O(|\Omega|)$. In practice $\Omega$ is enormous and the sums are Monte-Carlo estimates over base-model samples with self-normalized importance weights $e^{r/\beta}$ — the same estimator, unbiased in the normalized limit.

**B. Covariance audit ranking.** Given a battery of candidate statistics $f_1,\dots,f_m$, compute $c_i = \mathrm{Cov}_p(r,f_i)$ and $s_i = \mathrm{SkewCov}_p(r,f_i)$ from a single sample of the base model scored by $r$; rank by $|c_i|$, breaking ties on $|s_i|$. By Theorem 4.3 and Theorem 7.4 this ranks the statistics by predicted drift, with error $O(\beta^{-2})$ and $O(\beta^{-3})$ respectively. Cost $O(m\,n)$ for $n$ samples.

**C. Critical-strength solver.** Given a tolerance $\varepsilon$, compute $\beta_c(\varepsilon)$ by bisection on the envelope-certified bracket $[(1-\delta)C/\varepsilon,\ (1+\delta)C/\varepsilon]$ supplied by Theorem 6.6, testing membership in $H(\varepsilon)$ with algorithm A. The theorem guarantees the bracket is valid whenever $(\star)$ and $(\star\star)$ hold, so no unbounded search is needed; the asymptotic estimate $C/\varepsilon$ is itself a first guess accurate to relative error $O(\varepsilon)$ in general and $O(\varepsilon^2)$ on the symmetric two-point model.

---

## 10. Applications

**Pre-training-time audit prediction.** The pair $(\mathrm{Cov}_p(r,f), \mathrm{SkewCov}_p(r,f))$ is a complete two-term predictor of drift. Because both are base-model expectations, an alignment team can, before spending a single fine-tuning step, rank all monitored behavioural metrics by how far they will move, and at what penalty strength they will cross an alarm threshold.

**Principled KL-penalty selection.** Given a set $\mathcal{F}$ of monitored statistics and a per-statistic tolerance $\varepsilon$, Theorem 6.7 turns the choice of $\beta$ from a hyperparameter search into an inequality: $\beta \ge (1+\delta)\max_{f\in\mathcal{F}}|\mathrm{Cov}_p(r,f)|/\varepsilon$ suffices, and by Theorem 6.6 nothing substantially smaller does.

**Hardened metrics.** Since drift is, to first order, the linear functional $f \mapsto \mathrm{Cov}_p(r,f)/\beta$, the first-order-safe statistics form the hyperplane $r^\perp \subset L^2(p)$. Any statistic can be hardened by projection,
$$\tilde f \;=\; f - \frac{\mathrm{Cov}_p(r,f)}{\mathrm{Var}_p(r)}\,r,$$
after which $\mathrm{Cov}_p(r,\tilde f) = 0$ and Corollary 4.4 applies. Orthogonalizing further against $(r-\mathbb{E}_p r)^2$ (Gram–Schmidt against the first two reward powers) buys safety through order $\beta^{-2}$ by Corollary 7.6.

**A dual, adversarial reading.** The same subspace decomposition tells an adversary where to hide: behaviour supported in the orthogonal complement of $\mathrm{span}\{r,(r-\mathbb{E}_p r)^2\}$ moves the hardened metrics only at order $\beta^{-3}$. Auditing schemes should therefore treat the reward-orthogonal directions as *unmonitored by construction*, not as *safe*.

**Beyond alignment.** Nothing in the proofs uses the interpretation of $r$ as a reward. The same statements govern importance-weighted estimators, exponential tilting in rare-event simulation, and any setting where a base measure is reweighted by a bounded exponential factor: the induced bias in any bounded observable is its covariance with the tilt, to explicit second order.

---

## 11. Discussion and limitations

**Constants.** The constants $24$ and $40$ arise from crude but robust estimates ($|e^u-1-u| \le u^2$, $Z_\beta \ge 1/3$, $|Z_\beta - 1| \le 3R/\beta$). They are not optimal; the symmetric two-point model shows the true second-order remainder can be zero. What is optimal is the *shape*: $\beta^{-2}\sigma_p(f)$ at first order (Corollary 8.5), and $\beta^{-3}\sigma_p(f)$ at second.

**Regime.** All bounds assume $R \le \beta$, i.e. effective tilt at most $1$. Outside this regime the exponential is genuinely nonlinear and no covariance expansion can be expected; indeed as $\beta \downarrow 0$ the Gibbs policy concentrates on the argmax of $r$ and the audit gap saturates at $\max f - \mathbb{E}_p f$ rather than growing like $1/\beta$. The threshold theorem is asymptotic in $\varepsilon \downarrow 0$ precisely because small $\varepsilon$ pushes $\beta_c$ deep into the perturbative regime.

**Exactness of the Gibbs form.** We analyze the *exact* optimum of the KL-regularized objective. Real pipelines approximate it, and the approximation error is not modelled here. However, the analysis is uniform over the whole family $\{\pi_\beta\}$, so any policy that is $\pi_\beta$ for some effective $\beta$ inherits the bounds; empirically, measuring the realized $\beta$ from the achieved KL divergence and substituting it is a reasonable calibration.

**Finiteness.** $\Omega$ is finite. Extension to general measurable $\Omega$ with $|r| \le R$ and $f \in L^2(p)$ is expected to be routine: every step (the exact covariance identity, the oscillation bound, Cauchy–Schwarz, the pair representation of the variance) has a direct measure-theoretic analogue.

**Non-monotonicity.** As stressed in Remark 6.8, $|G|$ need not be monotone, so $\beta_c(\varepsilon)$ is a supremum, and the hacked set need not be an interval outside the perturbative window. Whether $H(\varepsilon)$ is an interval under natural hypotheses (e.g. $\mathrm{SkewCov}$ of the same sign as $\mathrm{Cov}$) is open.

---

## 12. Future directions

**Cumulant hierarchy of audit invariants.** $\mathrm{Cov}_p(r,f)$ and $\mathrm{SkewCov}_p(r,f)$ look like the first two members of a single family: the $k$-th order hacking coefficient should be a mixed cumulant of $r^{\otimes k}$ with $f$, so that the full expansion reads
$$G(\beta) \;\sim\; \sum_{k\ge1}\frac{\kappa_k(r;f)}{k!\,\beta^k}, \qquad \kappa_1 = \mathrm{Cov}_p(r,f),\quad \kappa_2 = \mathrm{SkewCov}_p(r,f).$$
Proving a $k$-th order law with remainder $C_k(R/\beta)^{k+1}\sigma_p(f)$, and identifying $\kappa_k$ as the joint cumulant, would give a complete "audit spectrum" of a statistic. The corresponding safety statement — orthogonality to the first $k$ reward powers implies drift $O(\beta^{-(k+1)})$ — would follow.

**Radius of convergence.** The generating function $\beta \mapsto G(\beta)$ is analytic in $1/\beta$ on the whole line; its Taylor coefficients are the cumulants above. What is the growth rate of $C_k$, and does the series converge for $R/\beta < \rho$ with an explicit $\rho$? This would replace the asymptotic hierarchy by an exact formula in the whole perturbative regime.

**Structure of the hacked set.** Give checkable hypotheses under which $H(\varepsilon)$ is an interval, so that $\beta_c(\varepsilon)$ is a true crossing point and the transition is a genuine bifurcation rather than a supremum.

**Vector-valued and worst-case audits.** For a family $\mathcal{F}$ of statistics with $\sigma_p(f)\le1$, the worst-case first-order drift is $\sup_{f\in\mathcal F}|\mathrm{Cov}_p(r,f)|/\beta$; for $\mathcal F$ the whole unit ball this equals $\sigma_p(r)/\beta$. A quantitative uniform threshold theorem over classes $\mathcal F$ (with metric-entropy-dependent remainders) would extend the sharp threshold from a single audit to a whole battery.

**Estimation theory.** All quantities are base-model expectations, hence Monte-Carlo estimable. What sample complexity is needed to certify $\beta \ge (1+\delta)\hat C/\varepsilon$ with confidence $1-\alpha$, given a plug-in estimate $\hat C$ of $|\mathrm{Cov}_p(r,f)|$? Concentration for the covariance under a bounded reward should give a clean answer.

**Continuous and sequential settings.** Extend to measurable response spaces and, more ambitiously, to token-level sequential policies where the KL penalty is applied per step, so that the effective tilt compounds along the trajectory.

---

## 13. Conclusion

The audit gap of a KL-regularized policy is a covariance — exactly at every regularization strength against the likelihood ratio, and to leading order against the reward itself, with an explicit second-order remainder and a matching lower bound. From that identity a genuine phase transition follows: at auditor tolerance $\varepsilon$, hacking of a statistic switches on at critical regularization strength
$$\beta_c(\varepsilon) \;=\; \big(1+o(1)\big)\,\frac{|\mathrm{Cov}_p(r,f)|}{\varepsilon}.$$
The second-order coefficient is the skew covariance, and the biased two-point model shows the expansion cannot be improved. The practical upshot is that reward hacking is predictable *before* training, from correlations measurable on the base model alone — and that the standard knob of alignment practice, the KL penalty, has a formula.
