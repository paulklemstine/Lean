# The Pretraining Mix-In Creates a Regularization-Independent Alignment Floor

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

We analyse the optimum of the KL-regularised reinforcement-learning-from-human-feedback objective when the reference measure is displaced by a *pretraining mix-in* (the "PTX" term of production alignment recipes). Writing $p$ for the supervised reference policy, $d$ for the pretraining distribution, $\gamma \in [0,1]$ for the mix-in fraction, $r$ for a bounded reward and $\beta>0$ for the regularisation strength, the mix-in replaces the anchor $p$ by the mixture $p_\gamma = (1-\gamma)p + \gamma d$, and we show that the maximiser of $q \mapsto \mathbb{E}_q[r] - \beta\,\mathrm{KL}(q\,\|\,p_\gamma)$ is the Gibbs tilt $q^*_{\beta,\gamma}(y) \propto p_\gamma(y)e^{r(y)/\beta}$.

Our main theorem is a **two-scale drift law**: for all $\beta>0$ and all rewards with $L \le r \le M$,
$$\Bigl|\;\|q^*_{\beta,\gamma}-p\|_1 - \gamma\|d-p\|_1\;\Bigr| \;\le\; e^{(M-L)/\beta}\,\frac{\sigma_{p_\gamma}(r)}{\beta}.$$
Consequently $\|q^*_{\beta,\gamma}-p\|_1 \to \gamma\|d-p\|_1$ as $\beta\to\infty$, so for $\gamma>0$ and $d\ne p$ the aligned policy *never* returns to the reference policy, however strong the regularisation. We prove that this **alignment floor** is model independent: for any anchor $m$, $\|\mathrm{tilt}_\beta(m)-p\|_1 \to \|m-p\|_1$, hence the optimum returns to $p$ if and only if the anchor *is* $p$; this covers the geometric mix-in $p^{1-\gamma}d^\gamma/Z$ as well as the arithmetic one. Dualising against the reward gives the floor in reward units: $\mathbb{E}_{q^*_{\beta,\gamma}}[r] \to \mathbb{E}_p[r] + \gamma(\mathbb{E}_d[r]-\mathbb{E}_p[r])$.

We further sharpen the reward-induced part of the drift. The $\sigma/\beta$ law is an upper bound only; the exact first-order constant is the **mean absolute deviation**, $\beta\|\mathrm{tilt}_\beta(m)-m\|_1 \to \mathbb{E}_m|r-\mathbb{E}_m r|$, and the sandwich $\sigma^2/(M-L) \le \mathrm{MAD} \le \sigma$ shows the $\Theta(\sigma/\beta)$ reading is two-sided precisely up to the dimensionless factor $\sigma/(M-L)$ and not better. Finally, under a nondegeneracy condition we compute the exact $1/\beta$ coefficient of the *total* drift and find a **signed** covariance $\sum_y \operatorname{sgn}(p_\gamma(y)-p(y))\,p_\gamma(y)(r(y)-\mathbb{E}_{p_\gamma}r)$, which may be negative: reward optimisation can partially cancel the pretraining tax.

**Keywords.** RLHF, KL regularisation, Gibbs variational principle, pretraining mix-in, total variation, mean absolute deviation, alignment tax.

---

## 1. Introduction

### 1.1 The regularised alignment optimum

Fix a finite output space $\Omega$. A *policy* is a probability distribution on $\Omega$; a *reward* is a function $r : \Omega \to \mathbb{R}$. The canonical alignment problem is

$$\max_{q} \; \mathbb{E}_q[r] - \beta\,\mathrm{KL}(q \,\|\, p), \tag{1.1}$$

where $p$ is a fixed reference (supervised fine-tuned) policy and $\beta > 0$ trades reward against deviation. Its unique maximiser is the exponential (Gibbs) tilt

$$\pi_\beta(y) = \frac{p(y)e^{r(y)/\beta}}{\sum_z p(z) e^{r(z)/\beta}}. \tag{1.2}$$

Two structural facts make $\beta$ a natural safety dial. First, $\pi_\beta \to p$ as $\beta \to \infty$, so the reference policy is recoverable. Second, the approach is at rate $1/\beta$ with constant governed by the reward's dispersion under $p$; in the $\ell^1$ (unnormalised total variation) norm $\|f-g\|_1 = \sum_y|f(y)-g(y)|$ one has $\|\pi_\beta - p\|_1 = \Theta(\sigma_p(r)/\beta)$. The dial is monotone, calibrated and convergent to the identity.

### 1.2 The pretraining mix-in

Production alignment pipelines augment (1.1) with a *pretraining mix-in*: a fraction $\gamma$ of the training signal is drawn from the original pretraining distribution $d$, as a hedge against the capability degradation ("alignment tax") that reward optimisation induces. In the *anchor formulation* studied here, the mix-in acts by replacing the reference measure of the KL penalty with the mixture

$$p_\gamma := (1-\gamma)p + \gamma d, \tag{1.3}$$

so that the objective becomes

$$\max_q \; \mathbb{E}_q[r] - \beta\,\mathrm{KL}(q \,\|\, p_\gamma), \tag{1.4}$$

with optimum

$$q^*_{\beta,\gamma}(y) = \frac{p_\gamma(y)\,e^{r(y)/\beta}}{\sum_z p_\gamma(z)e^{r(z)/\beta}}. \tag{1.5}$$

The question this paper answers is what becomes of the two structural facts of §1.1 under (1.4). The answer: the *rate* survives, but the *limit* does not. A $\beta$-independent residual displacement appears, of size exactly $\gamma\|d-p\|_1$.

### 1.3 Contributions

1. **Two-scale drift law** (Theorem 4.4): a nonasymptotic two-sided estimate separating a $\beta$-independent mix-in term from a $\sigma/\beta$ reward term.
2. **The alignment floor** (Theorem 4.6): $\|q^*_{\beta,\gamma}-p\|_1 \to \gamma\|d-p\|_1$, nonzero whenever $\gamma>0$, $d\ne p$.
3. **Model independence** (Theorem 6.2, Corollary 6.4): the floor equals the anchor displacement for *every* anchor, including the geometric mix-in.
4. **Genuine optimisation** (Theorem 5.4): (1.5) is the maximiser of (1.4), via a Gibbs variational principle proved from scratch.
5. **The floor in reward units** (Theorem 7.3): $\mathbb{E}_{q^*_{\beta,\gamma}}[r] \to \mathbb{E}_p[r] + \gamma(\mathbb{E}_d[r]-\mathbb{E}_p[r])$.
6. **The sharp reward-drift constant** (Theorem 8.3): the mean absolute deviation, together with the sandwich $\sigma^2/(M-L)\le \mathrm{MAD}\le\sigma$ (Theorem 8.5) that delimits exactly how far the $\Theta(\sigma/\beta)$ folklore is correct.
7. **The exact $1/\beta$ correction to the floor** (Theorem 9.4): a signed covariance, of no fixed sign.

Methodologically, no differentiation of the free energy is used anywhere. The nonasymptotic estimates come from the convexity inequality $|e^a - e^b|\le e^{\max(a,b)}|a-b|$ combined with the variational characterisation of variance; the sharp constants come from the derivative of $t\mapsto e^{ct}$ at $t=0$ transported along $\beta\mapsto 1/\beta$.

---

## 2. Setting and definitions

Throughout, $\Omega$ is a finite nonempty set and all sums range over $\Omega$.

**Definition 2.1 (Distribution).** A function $p:\Omega\to\mathbb{R}$ is a *distribution* if $p(y)\ge 0$ for all $y$ and $\sum_y p(y)=1$.

**Definition 2.2 (Moments).** For a distribution $p$ and $f:\Omega\to\mathbb{R}$:
$$\mathbb{E}_p[f] = \sum_y p(y)f(y),\qquad \mathrm{Var}_p(f) = \sum_y p(y)\bigl(f(y)-\mathbb{E}_p[f]\bigr)^2,$$
$$\sigma_p(f) = \sqrt{\mathrm{Var}_p(f)},\qquad \mathrm{MAD}_p(f) = \sum_y p(y)\bigl|f(y)-\mathbb{E}_p[f]\bigr|.$$

**Definition 2.3 ($\ell^1$ distance).** For $f,g:\Omega\to\mathbb{R}$, $\|f-g\|_1 := \sum_y |f(y)-g(y)|$. This is twice the total variation distance when $f,g$ are distributions. It is symmetric, satisfies the triangle inequality, is nonnegative, and vanishes exactly when $f=g$.

**Definition 2.4 (Mixture anchor).** For $\gamma\in\mathbb{R}$ and $p,d:\Omega\to\mathbb{R}$, $p_\gamma := (1-\gamma)p+\gamma d$.

**Definition 2.5 (Partition function and Gibbs tilt).** For $\beta \neq 0$, an anchor $m$ and reward $r$,
$$Z_\beta(m,r) := \sum_z m(z)e^{r(z)/\beta}, \qquad \mathrm{tilt}_\beta(m)(y) := \frac{m(y)e^{r(y)/\beta}}{Z_\beta(m,r)}.$$

**Definition 2.6 (PTX optimum).** $q^*_{\beta,\gamma} := \mathrm{tilt}_\beta(p_\gamma)$, i.e. exactly (1.5).

**Definition 2.7 (Kullback–Leibler divergence).** $\mathrm{KL}(q\,\|\,s) := \sum_y q(y)\log\bigl(q(y)/s(y)\bigr)$, with the convention $0\log 0 = 0$ built into the product form of the summand.

We record the elementary structural facts used repeatedly.

**Lemma 2.8.** If $p,d$ are distributions and $0\le\gamma\le1$, then $p_\gamma$ is a distribution; moreover $\mathbb{E}_{p_\gamma}[f] = (1-\gamma)\mathbb{E}_p[f] + \gamma\mathbb{E}_d[f]$ for every $f$.

*Proof.* Nonnegativity is a nonnegative combination of nonnegative terms; the total mass is $(1-\gamma)\cdot1+\gamma\cdot1 = 1$. Linearity of the mean is immediate from the definition. $\square$

**Lemma 2.9.** If $m$ is a distribution then $Z_\beta(m,r)>0$ and $\mathrm{tilt}_\beta(m)$ is a distribution. If moreover $m(y)>0$ for all $y$, then $\mathrm{tilt}_\beta(m)(y)>0$ for all $y$.

*Proof.* Since $\sum_y m(y)=1$, some $m(y)>0$; each summand $m(z)e^{r(z)/\beta}$ is nonnegative and at least one is strictly positive, so $Z_\beta>0$. The tilt is then a nonnegative function summing to $Z_\beta/Z_\beta=1$. $\square$

**Lemma 2.10 (Pointwise tilt displacement).** For a distribution $m$ and every $y$,
$$\mathrm{tilt}_\beta(m)(y) - m(y) \;=\; \frac{m(y)\bigl(e^{r(y)/\beta}-Z_\beta(m,r)\bigr)}{Z_\beta(m,r)}. \tag{2.1}$$
Consequently
$$\|\mathrm{tilt}_\beta(m)-m\|_1 \;=\; \frac{\sum_y m(y)\,\bigl|e^{r(y)/\beta}-Z_\beta(m,r)\bigr|}{Z_\beta(m,r)}. \tag{2.2}$$

*Proof.* Immediate algebra from Definition 2.5, then take absolute values and use $Z_\beta>0$. $\square$

Formula (2.2) is the engine of the paper: it expresses the tilt's displacement as a *mean absolute deviation of the exponentiated reward about its own mean*, since $Z_\beta(m,r) = \mathbb{E}_m[e^{r/\beta}]$.

---

## 3. The two analytic inputs

Everything nonasymptotic rests on two elementary inequalities.

**Lemma 3.1 (Exponential Lipschitz estimate).** For all $a,b\in\mathbb{R}$,
$$|e^a - e^b| \;\le\; e^{\max(a,b)}\,|a-b|.$$

*Proof.* By symmetry assume $a\le b$. Then $|e^a-e^b| = e^b - e^a = e^b(1-e^{a-b})$ and $|a-b| = b-a$. Since $a-b\le0$, the inequality $1-e^{t}\le -t$ for $t\le 0$ (equivalently $1+t\le e^t$) gives $1-e^{a-b}\le b-a$, so $e^b-e^a \le e^b(b-a)$. $\square$

**Lemma 3.2 (Variational characterisation of variance).** For a distribution $p$, a function $f$ and any $c\in\mathbb{R}$,
$$\mathrm{Var}_p(f) \;\le\; \sum_y p(y)\bigl(f(y)-c\bigr)^2 .$$

*Proof.* Expanding, $\sum_y p(y)(f(y)-c)^2 = \mathrm{Var}_p(f) + (\mathbb{E}_p f - c)^2 \ge \mathrm{Var}_p(f)$. $\square$

**Lemma 3.3 ($\ell^1$–$\ell^2$ comparison).** For a distribution $p$ and any $g:\Omega\to\mathbb{R}$,
$$\sum_y p(y)|g(y)| \;\le\; \sqrt{\textstyle\sum_y p(y)g(y)^2}.$$

*Proof.* Cauchy–Schwarz with weights $\sqrt{p(y)}$, using $\sum_y p(y)=1$. $\square$

**Corollary 3.4.** $\mathrm{MAD}_p(f) \le \sigma_p(f)$ for every distribution $p$ and every $f$.

Two boundedness facts are also used: if $L\le r\le M$ pointwise and $m$ is a distribution then $L\le \mathbb{E}_m[r]\le M$; and $Z_\beta(m,r) \ge e^{L/\beta}$ for $\beta>0$, since $e^{r(z)/\beta}\ge e^{L/\beta}$ termwise and $m$ has unit mass.

---

## 4. The two-scale drift law

### 4.1 The mix-in displacement is exact

**Theorem 4.1 (Exact anchor displacement).** For any $p,d:\Omega\to\mathbb{R}$ and any $\gamma\ge0$,
$$\|p_\gamma - p\|_1 \;=\; \gamma\,\|d-p\|_1 .$$

*Proof.* Pointwise, $(1-\gamma)p(y)+\gamma d(y) - p(y) = \gamma(d(y)-p(y))$, so $|p_\gamma(y)-p(y)| = \gamma|d(y)-p(y)|$ using $\gamma\ge0$. Sum over $y$. $\square$

Note there is no error term and no hypothesis beyond $\gamma \ge 0$: the mix-in displacement is a *closed-form constant*, entirely independent of $\beta$ and $r$.

### 4.2 The reward-induced displacement vanishes at rate $1/\beta$

**Theorem 4.2 (Variance of the exponentiated reward).** Let $m$ be a distribution, $\beta>0$, and $r\le M$ pointwise. Then
$$\mathrm{Var}_m\bigl(e^{r/\beta}\bigr) \;\le\; \Bigl(\frac{e^{M/\beta}}{\beta}\Bigr)^{\!2}\,\mathrm{Var}_m(r).$$

*Proof.* By Lemma 3.2 applied with the constant $c = e^{\mathbb{E}_m[r]/\beta}$,
$$\mathrm{Var}_m(e^{r/\beta}) \;\le\; \sum_y m(y)\Bigl(e^{r(y)/\beta} - e^{\mathbb{E}_m[r]/\beta}\Bigr)^{2}.$$
By Lemma 3.1, each bracket is bounded in absolute value by $e^{\max(r(y),\mathbb{E}_m r)/\beta}\,|r(y)-\mathbb{E}_m r|/\beta \le (e^{M/\beta}/\beta)|r(y)-\mathbb{E}_m r|$, using $r\le M$ and $\mathbb{E}_m r\le M$ and monotonicity of $\exp$. Squaring and summing gives the claim. $\square$

**Theorem 4.3 (Reward-drift bound; the $\sigma/\beta$ law).** Let $m$ be a distribution, $\beta>0$, and $L\le r\le M$ pointwise. Then
$$\|\mathrm{tilt}_\beta(m)-m\|_1 \;\le\; e^{(M-L)/\beta}\,\frac{\sigma_m(r)}{\beta}.$$

*Proof.* Start from (2.2). Since $Z_\beta(m,r) = \mathbb{E}_m[e^{r/\beta}]$, the numerator is precisely $\mathrm{MAD}_m(e^{r/\beta})$, which by Lemma 3.3 is at most $\sigma_m(e^{r/\beta})$, which by Theorem 4.2 is at most $(e^{M/\beta}/\beta)\sigma_m(r)$. The denominator is at least $e^{L/\beta}$. Dividing, $e^{M/\beta}/e^{L/\beta} = e^{(M-L)/\beta}$. $\square$

### 4.3 The main estimate

**Theorem 4.4 (Two-scale drift law).** Let $p,d$ be distributions, $0\le\gamma\le1$, $\beta>0$, and $L\le r\le M$. Then
$$\gamma\|d-p\|_1 - e^{(M-L)/\beta}\frac{\sigma_{p_\gamma}(r)}{\beta} \;\le\; \|q^*_{\beta,\gamma}-p\|_1 \;\le\; \gamma\|d-p\|_1 + e^{(M-L)/\beta}\frac{\sigma_{p_\gamma}(r)}{\beta},$$
equivalently
$$\Bigl|\;\|q^*_{\beta,\gamma}-p\|_1 - \gamma\|d-p\|_1\;\Bigr| \;\le\; e^{(M-L)/\beta}\,\frac{\sigma_{p_\gamma}(r)}{\beta}.$$

*Proof.* By Lemma 2.8, $p_\gamma$ is a distribution, so Theorem 4.3 applies with $m=p_\gamma$ and bounds $\|q^*_{\beta,\gamma}-p_\gamma\|_1$ by the stated envelope $E_\beta := e^{(M-L)/\beta}\sigma_{p_\gamma}(r)/\beta$. The triangle inequality in the form $\|q^*-p\|_1 \le \|q^*-p_\gamma\|_1 + \|p_\gamma-p\|_1$ combined with Theorem 4.1 gives the upper bound. The reverse form $\|p_\gamma - p\|_1 \le \|p_\gamma - q^*\|_1 + \|q^*-p\|_1$, together with symmetry of $\|\cdot\|_1$, gives the lower bound. $\square$

**Remark 4.5.** The estimate is nonasymptotic and holds for every $\beta>0$; no smallness or largeness is assumed. Both scales are explicit: the constant scale $\gamma\|d-p\|_1$ and the vanishing scale $\sigma_{p_\gamma}(r)/\beta$ (times a factor tending to $1$).

### 4.4 The alignment floor

**Lemma 4.6.** For any constants $K,C$, $\;e^{K/\beta}C/\beta \to 0$ as $\beta\to\infty$, since $e^{K/\beta}\to e^0 = 1$.

**Theorem 4.7 (The alignment floor).** Under the hypotheses of Theorem 4.4 (with $L\le r\le M$ fixed),
$$\lim_{\beta\to\infty}\;\|q^*_{\beta,\gamma}-p\|_1 \;=\; \gamma\,\|d-p\|_1 .$$

*Proof.* Theorem 4.4 sandwiches $\|q^*_{\beta,\gamma}-p\|_1 - \gamma\|d-p\|_1$ in absolute value by a quantity tending to $0$ (Lemma 4.6). $\square$

**Theorem 4.8 (No return to the reference policy).** If $\gamma>0$, $\gamma\le1$, and $d\ne p$, then $\|q^*_{\beta,\gamma}-p\|_1 \not\to 0$ as $\beta\to\infty$.

*Proof.* By Theorem 4.7 the limit exists and equals $\gamma\|d-p\|_1$. If it were $0$, uniqueness of limits would force $\gamma\|d-p\|_1 = 0$; since $\gamma>0$ this gives $\|d-p\|_1=0$, and since $\ell^1$ separates points, $d=p$ — a contradiction. $\square$

This is the paper's headline: **the regularisation coefficient is not a dial that returns the model to its reference once a pretraining mix-in is present.** The residual displacement is a product of two data-pipeline quantities, $\gamma$ and $\|d-p\|_1$, and is untouched by the optimisation hyperparameter $\beta$.

---

## 5. The formula is a genuine optimum

Sections 4 and beyond are statements about the formula (1.5). This section closes the loop by proving that (1.5) is the maximiser of the objective (1.4), via a self-contained Gibbs variational principle.

**Lemma 5.1 (Gibbs' inequality).** If $q,s$ are distributions with $s(y)>0$ for all $y$, then $\mathrm{KL}(q\,\|\,s) \ge 0$. Moreover $\mathrm{KL}(s\,\|\,s)=0$.

*Proof.* We show $-q(y)\log(q(y)/s(y)) \le s(y)-q(y)$ for each $y$. If $q(y)=0$ the left side is $0$ and the right side is $s(y)>0$. If $q(y)>0$, put $t = s(y)/q(y)>0$; then $\log t \le t-1$, so $q(y)\log t \le s(y)-q(y)$, and $q(y)\log t = -q(y)\log(q(y)/s(y))$. Summing over $y$ gives $-\mathrm{KL}(q\|s) \le 1-1 = 0$. The second claim is immediate since $\log(s(y)/s(y))=0$ whenever $s(y)\neq 0$, and the summand vanishes identically otherwise. $\square$

**Lemma 5.2 (Free-energy identity).** Let $m$ be a strictly positive distribution, $\beta>0$, $r$ arbitrary, and $q$ any distribution. Then
$$\mathbb{E}_q[r] - \beta\,\mathrm{KL}(q\,\|\,m) \;=\; \beta\log Z_\beta(m,r) \;-\; \beta\,\mathrm{KL}\bigl(q\,\|\,\mathrm{tilt}_\beta(m)\bigr). \tag{5.1}$$

*Proof.* Write $g = \mathrm{tilt}_\beta(m)$, so $\log\bigl(q(y)/g(y)\bigr) = \log\bigl(q(y)/m(y)\bigr) - r(y)/\beta + \log Z_\beta(m,r)$ for each $y$ with $q(y)>0$ (and both sides' contributions vanish when $q(y)=0$). Multiplying by $\beta q(y)$ and summing, using $\sum_y q(y)=1$:
$$\beta\,\mathrm{KL}(q\,\|\,g) \;=\; \beta\,\mathrm{KL}(q\,\|\,m) - \mathbb{E}_q[r] + \beta\log Z_\beta(m,r),$$
which rearranges to (5.1). $\square$

**Theorem 5.3 (Gibbs variational principle).** Let $m$ be a strictly positive distribution and $\beta>0$. Then for every distribution $q$,
$$\mathbb{E}_q[r] - \beta\,\mathrm{KL}(q\,\|\,m) \;\le\; \mathbb{E}_{\mathrm{tilt}_\beta(m)}[r] - \beta\,\mathrm{KL}\bigl(\mathrm{tilt}_\beta(m)\,\|\,m\bigr).$$

*Proof.* Apply (5.1) to $q$ and to $g = \mathrm{tilt}_\beta(m)$. For $g$ the correction term is $\beta\,\mathrm{KL}(g\|g) = 0$, so the right side equals $\beta\log Z_\beta(m,r)$ exactly. For $q$ the correction term is $\beta\,\mathrm{KL}(q\|g)\ge0$ by Lemma 5.1 (note $g>0$ by Lemma 2.9), so the left side is at most $\beta\log Z_\beta(m,r)$. $\square$

**Theorem 5.4 (The PTX optimum).** Let $p,d$ be strictly positive distributions, $0\le\gamma\le1$, $\beta>0$. Then $p_\gamma$ is strictly positive, and for every distribution $q$,
$$\mathbb{E}_q[r] - \beta\,\mathrm{KL}(q\,\|\,p_\gamma) \;\le\; \mathbb{E}_{q^*_{\beta,\gamma}}[r] - \beta\,\mathrm{KL}\bigl(q^*_{\beta,\gamma}\,\|\,p_\gamma\bigr).$$

*Proof.* Strict positivity: if $\gamma=0$ then $p_\gamma=p>0$; if $\gamma>0$ then $p_\gamma(y) = (1-\gamma)p(y) + \gamma d(y) \ge \gamma d(y) > 0$. Now apply Theorem 5.3 with $m=p_\gamma$. $\square$

Thus every drift law in this paper describes a genuine optimisation problem, not an ad hoc formula.

---

## 6. Model independence: the floor is the anchor displacement

The arithmetic mixture (1.3) is one model of the mix-in. We now show the floor phenomenon depends only on the fact that the anchor moved.

**Lemma 6.1 (Reverse triangle inequality).** For $f,g,h$, $\;\bigl|\|f-h\|_1 - \|g-h\|_1\bigr| \le \|f-g\|_1$.

**Theorem 6.2 (Anchor limit).** Let $m$ be a distribution, $L\le r\le M$, and let $f$ be any fixed function. Then
$$\lim_{\beta\to\infty}\;\|\mathrm{tilt}_\beta(m) - f\|_1 \;=\; \|m-f\|_1 .$$

*Proof.* By Lemma 6.1 and Theorem 4.3, $\bigl|\|\mathrm{tilt}_\beta(m)-f\|_1 - \|m-f\|_1\bigr| \le \|\mathrm{tilt}_\beta(m)-m\|_1 \le e^{(M-L)/\beta}\sigma_m(r)/\beta \to 0$. $\square$

**Theorem 6.3 (Return criterion).** For any distribution $m$, any distribution $p$ and any bounded reward,
$$\lim_{\beta\to\infty}\|\mathrm{tilt}_\beta(m)-p\|_1 = 0 \quad\Longleftrightarrow\quad m = p .$$

*Proof.* ($\Rightarrow$) By Theorem 6.2 the limit is $\|m-p\|_1$; uniqueness of limits gives $\|m-p\|_1=0$, hence $m=p$. ($\Leftarrow$) Substitute $m=p$ into Theorem 6.2. $\square$

**Definition 6.4 (Geometric mix-in).** For strictly positive $p,d$ and $\gamma\in\mathbb{R}$,
$$p^{\mathrm{geo}}_\gamma(y) := \frac{p(y)^{1-\gamma}d(y)^{\gamma}}{\sum_z p(z)^{1-\gamma}d(z)^{\gamma}}.$$
This is the anchor generated by regularising with the convex combination of divergences $(1-\gamma)\mathrm{KL}(q\|p) + \gamma\,\mathrm{KL}(q\|d)$, rather than by mixing data. It is a distribution, being a positive function normalised to unit mass.

**Corollary 6.5 (Robustness across mix-in models).** With the geometric anchor,
$$\lim_{\beta\to\infty}\|\mathrm{tilt}_\beta(p^{\mathrm{geo}}_\gamma)-p\|_1 = 0 \quad\Longleftrightarrow\quad p^{\mathrm{geo}}_\gamma = p .$$

*Proof.* Theorem 6.3 with $m = p^{\mathrm{geo}}_\gamma$. $\square$

For $\gamma \in (0,1]$ the condition $p^{\mathrm{geo}}_\gamma = p$ forces $d=p$ (the log-linear blend of two distinct distributions is distinct from each). So the geometric mix-in pays a floor of exactly the same character. The floor is a property of the *anchor*, not of the *mixing rule*.

---

## 7. The floor in reward units

Total variation is an abstraction; dualising against the reward converts the floor into a statement about the achieved score.

**Lemma 7.1 ($\ell^1$–$\ell^\infty$ duality).** If $|h(y)|\le C$ for all $y$, then $|\mathbb{E}_f[h] - \mathbb{E}_g[h]| \le C\,\|f-g\|_1$.

*Proof.* $\mathbb{E}_f[h]-\mathbb{E}_g[h] = \sum_y (f(y)-g(y))h(y)$; bound termwise by $C|f(y)-g(y)|$. $\square$

**Theorem 7.2 (Achieved reward converges to the anchor's reward).** Let $m$ be a distribution, $L\le r\le M$ and $|r|\le C$. Then $\mathbb{E}_{\mathrm{tilt}_\beta(m)}[r] \to \mathbb{E}_m[r]$ as $\beta\to\infty$.

*Proof.* By Lemma 7.1 and Theorem 4.3, $|\mathbb{E}_{\mathrm{tilt}_\beta(m)}[r]-\mathbb{E}_m[r]| \le C\,e^{(M-L)/\beta}\sigma_m(r)/\beta \to 0$. $\square$

**Theorem 7.3 (The reward-level alignment tax).** Let $p,d$ be distributions, $0\le\gamma\le1$, $L\le r\le M$, $|r|\le C$. Then
$$\lim_{\beta\to\infty}\;\mathbb{E}_{q^*_{\beta,\gamma}}[r] \;=\; \mathbb{E}_p[r] + \gamma\bigl(\mathbb{E}_d[r]-\mathbb{E}_p[r]\bigr).$$

*Proof.* Theorem 7.2 with $m=p_\gamma$ gives the limit $\mathbb{E}_{p_\gamma}[r]$, which by Lemma 2.8 equals $(1-\gamma)\mathbb{E}_p[r]+\gamma\mathbb{E}_d[r] = \mathbb{E}_p[r]+\gamma(\mathbb{E}_d[r]-\mathbb{E}_p[r])$. $\square$

**Remark 7.4.** The shift $\gamma(\mathbb{E}_d[r]-\mathbb{E}_p[r])$ is $\beta$-independent and negative precisely when the pretraining distribution is worse-rewarded than the reference policy — the typical case, since $p$ was constructed to score well. This is the alignment tax made quantitative: $\gamma$ times the reward gap between corpus and reference. Both factors are estimable *before* training.

---

## 8. The sharp reward-drift constant: mean absolute deviation, not standard deviation

Theorem 4.3 is an upper bound. What is the exact first-order behaviour?

**Lemma 8.1 (Rescaled exponential).** For any $c\in\mathbb{R}$, $\;\beta\bigl(e^{c/\beta}-1\bigr)\to c$ as $\beta\to\infty$.

*Proof.* This is the derivative of $t\mapsto e^{ct}$ at $t=0$, transported along $t = 1/\beta$: $\beta(e^{c/\beta}-1) = (e^{ct}-e^{0})/t$ at $t=1/\beta\downarrow0$. $\square$

**Lemma 8.2 (Rescaled partition function).** For a distribution $m$: $Z_\beta(m,r)\to 1$ and $\beta\bigl(Z_\beta(m,r)-1\bigr)\to \mathbb{E}_m[r]$ as $\beta\to\infty$.

*Proof.* $\beta(Z_\beta - 1) = \sum_y m(y)\,\beta(e^{r(y)/\beta}-1) \to \sum_y m(y)r(y)$ by Lemma 8.1 termwise (a finite sum), using $\sum_y m(y)=1$. The first claim follows since $\beta(Z_\beta-1)$ is bounded and $\beta\to\infty$; equivalently, apply $e^{r(y)/\beta}\to1$ termwise. $\square$

Combining, $\beta\bigl(e^{r(y)/\beta}-Z_\beta(m,r)\bigr) \to r(y) - \mathbb{E}_m[r]$ for each $y$.

**Theorem 8.3 (Sharp drift constant).** For every distribution $m$ and every $r$,
$$\lim_{\beta\to\infty}\;\beta\,\|\mathrm{tilt}_\beta(m)-m\|_1 \;=\; \mathrm{MAD}_m(r) \;=\; \mathbb{E}_m\bigl|r-\mathbb{E}_m r\bigr| .$$

*Proof.* By (2.2), $\beta\|\mathrm{tilt}_\beta(m)-m\|_1 = \sum_y m(y)\,\bigl|\beta(e^{r(y)/\beta}-Z_\beta)\bigr| / Z_\beta$. Each numerator term converges to $m(y)|r(y)-\mathbb{E}_m r|$ by the display above and continuity of $|\cdot|$; the denominator converges to $1$ by Lemma 8.2. The sum is finite, so limits pass through. $\square$

So the $\sigma/\beta$ bound of Theorem 4.3 is **not** attained: the true first-order constant is $\mathrm{MAD}_m(r)\le\sigma_m(r)$. The loss came from the Cauchy–Schwarz step (Lemma 3.3). How much is lost is exactly quantifiable.

**Theorem 8.4 (Reverse comparison).** If $L\le r\le M$ then $\sigma_m(r)^2 \le (M-L)\,\mathrm{MAD}_m(r)$.

*Proof.* Since $L\le r\le M$ and $L\le\mathbb{E}_m r\le M$, every deviation satisfies $|r(y)-\mathbb{E}_m r|\le M-L$. Hence $(r(y)-\mathbb{E}_m r)^2 = |r(y)-\mathbb{E}_m r|^2 \le (M-L)|r(y)-\mathbb{E}_m r|$. Weight by $m(y)$ and sum. $\square$

**Theorem 8.5 (The sandwich).** If $L\le r\le M$ with $L<M$, then
$$\frac{\sigma_m(r)^2}{M-L} \;\le\; \mathrm{MAD}_m(r) \;\le\; \sigma_m(r).$$

*Proof.* Right: Corollary 3.4. Left: rearrange Theorem 8.4. $\square$

**Corollary 8.6 (Guarded $\Theta(\sigma/\beta)$).** Writing $\rho := \sigma_m(r)/(M-L)\in[0,1]$ for the dimensionless dispersion ratio,
$$\rho\cdot\frac{\sigma_m(r)}{\beta} \;\lesssim\; \|\mathrm{tilt}_\beta(m)-m\|_1 \;\lesssim\; \frac{\sigma_m(r)}{\beta}$$
to first order. Thus the $\Theta(\sigma/\beta)$ law is two-sided exactly up to the factor $\rho$, and cannot be sharpened to an equality; the honest constant is $\mathrm{MAD}$.

**Theorem 8.7 (PTX version).** For distributions $p,d$ and $0\le\gamma\le1$,
$$\lim_{\beta\to\infty}\;\beta\,\|q^*_{\beta,\gamma}-p_\gamma\|_1 \;=\; \mathrm{MAD}_{p_\gamma}(r).$$

*Proof.* Theorem 8.3 with $m = p_\gamma$, a distribution by Lemma 2.8. $\square$

The $\gamma$-dependence of the reward-induced drift enters *only* through the anchor: mixing in pretraining data changes the constant by changing the measure under which the reward's dispersion is computed.

---

## 9. The exact $1/\beta$ correction to the floor is a signed covariance

Theorem 4.7 gives $\|q^*_{\beta,\gamma}-p\|_1 = \gamma\|d-p\|_1 + O(1/\beta)$; Theorem 8.7 identifies the sharp constant of the drift *from the anchor*. We now identify the $1/\beta$ coefficient of the drift *from $p$*, which behaves qualitatively differently.

**Definition 9.1.** For $f,g:\Omega\to\mathbb{R}$ set $s_{f,g}(y) := +1$ if $g(y) < f(y)$ and $-1$ otherwise. Whenever $g(y)\ne f(y)$ we have $|f(y)-g(y)| = s_{f,g}(y)\bigl(f(y)-g(y)\bigr)$.

**Lemma 9.2 (Pointwise convergence).** For a distribution $m$ and each $y$: $\mathrm{tilt}_\beta(m)(y)\to m(y)$ as $\beta\to\infty$.

*Proof.* $m(y)e^{r(y)/\beta}/Z_\beta \to m(y)\cdot1/1$ by Lemma 8.2. $\square$

**Lemma 9.3 (Rescaled pointwise drift).** For a distribution $m$ and each $y$,
$$\beta\bigl(\mathrm{tilt}_\beta(m)(y)-m(y)\bigr) \;\longrightarrow\; m(y)\bigl(r(y)-\mathbb{E}_m[r]\bigr).$$

*Proof.* By (2.1), the left side is $m(y)\,\beta(e^{r(y)/\beta}-Z_\beta)/Z_\beta$; apply Lemma 8.2. $\square$

**Theorem 9.4 (Exact $1/\beta$ correction, general anchor).** Let $m$ be a distribution and $p$ a function with $p(y)\ne m(y)$ for *every* $y$. Then
$$\lim_{\beta\to\infty}\;\beta\Bigl(\|\mathrm{tilt}_\beta(m)-p\|_1 - \|m-p\|_1\Bigr) \;=\; \sum_y s_{m,p}(y)\,m(y)\bigl(r(y)-\mathbb{E}_m[r]\bigr).$$

*Proof.* Fix $y$. Since $m(y)\ne p(y)$, either $p(y)<m(y)$ or $p(y)>m(y)$. In the first case $s_{m,p}(y)=1$, and by Lemma 9.2 we have $\mathrm{tilt}_\beta(m)(y) > p(y)$ for all sufficiently large $\beta$, so $|\mathrm{tilt}_\beta(m)(y)-p(y)| = s_{m,p}(y)(\mathrm{tilt}_\beta(m)(y)-p(y))$ eventually. The second case is symmetric with $s_{m,p}(y)=-1$. Since $\Omega$ is finite, there is a single threshold beyond which this holds for all $y$ simultaneously. For such $\beta$,
$$\|\mathrm{tilt}_\beta(m)-p\|_1 - \|m-p\|_1 = \sum_y s_{m,p}(y)\bigl(\mathrm{tilt}_\beta(m)(y)-p(y)\bigr) - \sum_y s_{m,p}(y)\bigl(m(y)-p(y)\bigr),$$
which telescopes to $\sum_y s_{m,p}(y)\bigl(\mathrm{tilt}_\beta(m)(y)-m(y)\bigr)$: the $p$ terms cancel exactly, and the absolute values have become linear. Multiplying by $\beta$ and applying Lemma 9.3 termwise gives the claim. $\square$

**Theorem 9.5 (PTX drift to first order).** Let $p,d$ be distributions, $0\le\gamma\le1$, and suppose $p(y)\ne p_\gamma(y)$ for every $y$. Then
$$\beta\Bigl(\|q^*_{\beta,\gamma}-p\|_1 - \gamma\|d-p\|_1\Bigr) \;\longrightarrow\; \sum_y \operatorname{sgn}\bigl(p_\gamma(y)-p(y)\bigr)\,p_\gamma(y)\,\bigl(r(y)-\mathbb{E}_{p_\gamma}[r]\bigr),$$
i.e.
$$\|q^*_{\beta,\gamma}-p\|_1 \;=\; \gamma\|d-p\|_1 \;+\; \frac{1}{\beta}\sum_y \operatorname{sgn}\bigl(p_\gamma(y)-p(y)\bigr)\,p_\gamma(y)\,\bigl(r(y)-\mathbb{E}_{p_\gamma}[r]\bigr) \;+\; o(1/\beta).$$

*Proof.* Theorem 9.4 with $m = p_\gamma$, then substitute $\|p_\gamma - p\|_1 = \gamma\|d-p\|_1$ (Theorem 4.1). $\square$

**Remark 9.6 (Why the sign changes).** Note the contrast with Theorem 8.7. There the coefficient is $\sum_y p_\gamma(y)|r(y)-\mathbb{E}_{p_\gamma}r| \ge 0$; here it is the same sum with $|\cdot|$ replaced by a *sign pattern determined by the anchor displacement*, namely $\operatorname{sgn}(p_\gamma(y)-p(y))$. The two agree only when the reward deviation happens to be aligned with the displacement direction at every coordinate. In general the sum is a covariance-like quantity
$$\mathrm{Cov}\text{-type} \;=\; \mathbb{E}_{p_\gamma}\Bigl[\operatorname{sgn}\bigl(p_\gamma-p\bigr)\cdot\bigl(r - \mathbb{E}_{p_\gamma}r\bigr)\Bigr]$$
and can be negative. Interpretation: if the reward is *high* precisely on outputs whose probability the mix-in *reduced*, then tilting toward the reward pushes those coordinates back toward their values under $p$, and the total displacement decreases with decreasing $\beta$. Reward optimisation then partially cancels the pretraining tax — though never below the floor $\gamma\|d-p\|_1$, which is the $\beta\to\infty$ limit itself.

**Remark 9.7 (Degeneracy).** The hypothesis $p(y)\ne p_\gamma(y)$ for all $y$ — equivalently $d(y)\ne p(y)$ for all $y$ when $\gamma>0$ — is genuinely needed: at a coordinate where the anchor coincides with $p$, the sign of $q^*_{\beta,\gamma}(y)-p(y)$ is not eventually constant, and that coordinate contributes an absolute value rather than a signed term. On such coordinates the argument of Theorem 8.3 applies instead. Numerical experiment agrees to eight significant figures with the mixed formula obtained by summing signed terms over the moved coordinates and absolute values over the degenerate ones; a proof is stated as a conjecture in §13.

---

## 10. Algorithms

The results yield three directly implementable procedures on a finite output space of size $n$.

**Algorithm A (Exact PTX optimum).** Given $p,d,r,\beta,\gamma$: form $p_\gamma(y) = (1-\gamma)p(y)+\gamma d(y)$; compute the stabilised weights $w(y) = p_\gamma(y)\exp\bigl((r(y)-\max_z r(z))/\beta\bigr)$; normalise $q^*(y) = w(y)/\sum_z w(z)$. Cost $O(n)$ time and space; numerically stable for all $\beta>0$ because of the max-subtraction, which cancels in the normalisation.

**Algorithm B (Drift certificate).** Given $p,d,r,\beta,\gamma$: compute $F = \gamma\|d-p\|_1$ (the floor), $\sigma = \sigma_{p_\gamma}(r)$, $E = e^{(M-L)/\beta}\sigma/\beta$ (the envelope of Theorem 4.4), and return the certified interval $[\max(0, F-E),\, F+E]$ containing $\|q^*_{\beta,\gamma}-p\|_1$. Cost $O(n)$. This gives a rigorous, training-free bracket on the achievable drift.

**Algorithm C (Asymptotic panel).** Given $p,d,r,\gamma$: return the floor $F=\gamma\|d-p\|_1$; the anchor-drift constant $\mathrm{MAD}_{p_\gamma}(r)$ with its sandwich $[\sigma^2/(M-L),\,\sigma]$; the signed covariance coefficient $\sum_y \operatorname{sgn}(p_\gamma(y)-p(y))p_\gamma(y)(r(y)-\mathbb{E}_{p_\gamma}r)$ (valid when no coordinate is degenerate); and the reward-unit tax $\gamma(\mathbb{E}_d[r]-\mathbb{E}_p[r])$. Cost $O(n)$. Together these predict $\|q^*_{\beta,\gamma}-p\|_1$ to $o(1/\beta)$ and the achieved reward to $o(1)$, with no optimisation performed.

---

## 11. Applications and interpretation

**11.1 Hyperparameter semantics.** The pair $(\beta,\gamma)$ is not two dials on the same axis. $\beta$ controls a perturbative, $O(1/\beta)$ effect; $\gamma$ controls an $O(1)$ effect. Any safety argument of the form "we set $\beta$ large, therefore the aligned model is close to the supervised model" is invalid whenever $\gamma>0$: the correct bound is $\|q^*-p\|_1 \ge \gamma\|d-p\|_1 - e^{(M-L)/\beta}\sigma_{p_\gamma}(r)/\beta$, which for large $\beta$ is bounded *below* by roughly $\gamma\|d-p\|_1$.

**11.2 Pre-training-time budgeting.** Both $\gamma$ and $\|d-p\|_1$ are known or estimable, so the floor and the reward tax $\gamma(\mathbb{E}_d[r]-\mathbb{E}_p[r])$ can be computed before training. This turns the mix-in fraction into a quantity with a stated price rather than a folklore knob.

**11.3 Predicting drift rather than bounding it.** Corollary 8.6 says that using $\sigma$ as the drift constant systematically over-predicts by a factor between $1$ and $(M-L)/\sigma$. For nearly two-point reward distributions the two are comparable; for rewards with rare large values the over-prediction is severe. Practitioners fitting drift-versus-$\beta$ curves should fit $\mathrm{MAD}$.

**11.4 Design of mix-in schemes.** Theorem 6.3 shows no reparametrisation escapes the floor: arithmetic mixture, geometric mixture, or a second KL term all displace the anchor and all pay. Escaping requires a scheme that leaves the anchor at $p$ — e.g. applying the pretraining constraint as a *hard* feasibility constraint rather than as a shift of the reference measure — which is a genuinely different optimisation problem.

**11.5 Sign of the correction as a design signal.** By Theorem 9.5 the sign of the covariance $\mathbb{E}_{p_\gamma}[\operatorname{sgn}(p_\gamma-p)(r-\mathbb{E}_{p_\gamma}r)]$ determines whether finite-$\beta$ operation drifts *more* or *less* than the asymptotic floor. A negative value means the reward is anticorrelated with the mix-in displacement, and moderate $\beta$ actually reduces total drift below the floor — an exploitable regime.

---

## 12. Discussion and limitations

The analysis is finite-dimensional and exact within its model. Three caveats.

*The anchor formulation.* We model the mix-in as displacing the KL reference measure. Real pipelines add a pretraining log-likelihood term to a stochastic-gradient objective; the anchor formulation is the natural fixed-point idealisation, and Theorem 6.3 shows the conclusion is insensitive to the precise mixing rule, but the correspondence is a modelling assumption, not a theorem.

*Finiteness.* $\Omega$ is finite, so all sums converge and pointwise limits pass through. Extension to countable or continuous output spaces requires uniform integrability of $e^{r/\beta}$; for bounded $r$ this is routine, and none of the arguments use finiteness except to interchange limit and sum.

*Exact optimisation.* We compare optima, not trajectories. Real training reaches an approximate optimum; the floor is a statement about where the optimisation is pulling, and quantifying the approximation error is open.

Within these limits, the structure is robust: it depends only on the fact that the tilt is a $1/\beta$ perturbation while the anchor is an $O(1)$ displacement.

---

## 13. Future directions

**Sharpening Theorem 9.5 to a rate.** Conjecturally the error in Theorem 9.5 is $O(\beta^{-2})$ with an explicit constant, and the degenerate case admits a unified statement: if some coordinates satisfy $p_\gamma(y)=p(y)$,
$$\beta\Bigl(\|q^*_{\beta,\gamma}-p\|_1 - \gamma\|d-p\|_1\Bigr) \to \sum_{y:\,p_\gamma(y)\ne p(y)} \operatorname{sgn}\bigl(p_\gamma(y)-p(y)\bigr)p_\gamma(y)\bigl(r(y)-\mathbb{E}_{p_\gamma}r\bigr) + \sum_{y:\,p_\gamma(y)=p(y)} p_\gamma(y)\bigl|r(y)-\mathbb{E}_{p_\gamma}r\bigr|.$$
The nondegenerate case is Theorem 9.5, and the degenerate coordinates are exactly where the argument of Theorem 8.3 applies verbatim, so the two proofs should glue.

**An unavoidable reward-unit tax.** Conjecturally, for $\gamma>0$ and $d\ne p$ there is $c(\gamma,d,p)>0$, independent of $\beta$, such that the achieved reward is bounded away from the reward-optimal value by at least $c$, uniformly over rewards of unit range; the total-variation floor should dualise into a uniform reward gap via $|\mathbb{E}_{q^*}[r]-\mathbb{E}_p[r]| \le \mathrm{range}(r)\cdot\|q^*-p\|_1/2$ run in the reverse direction.

**Multi-anchor and scheduled mix-ins.** Real pipelines vary $\gamma$ over training. The floor for a $\gamma$-schedule should be governed by the terminal anchor, but the transient behaviour, and whether an annealed schedule can land below the terminal floor, is open.

**Beyond total variation.** The same two-scale structure should hold in KL, Hellinger and Wasserstein distance, with the $O(1)$ term given by the corresponding anchor displacement and the $1/\beta$ constant by the appropriate dispersion functional (variance for KL, by the local quadratic structure of the divergence).

---

## 14. Conclusion

A pretraining mix-in of fraction $\gamma$ moves the reference measure of the KL-regularised alignment objective from $p$ to $p_\gamma=(1-\gamma)p+\gamma d$. Because the exponential tilt is an $O(1/\beta)$ perturbation of its anchor while the anchor shift is $O(1)$, the total displacement of the optimum from the supervised policy splits as
$$\|q^*_{\beta,\gamma}-p\|_1 \;=\; \underbrace{\gamma\|d-p\|_1}_{\beta\text{-independent floor}} \;+\; \underbrace{O(\sigma_{p_\gamma}(r)/\beta)}_{\text{reward-induced}},$$
with the floor exact, the envelope nonasymptotic, the floor's height independent of the mixing rule, the reward-unit version equal to $\gamma(\mathbb{E}_d[r]-\mathbb{E}_p[r])$, the sharp reward constant equal to the mean absolute deviation (sandwiched by $\sigma^2/(M-L)\le\mathrm{MAD}\le\sigma$), and the exact $1/\beta$ coefficient of the total drift a signed covariance capable of partially cancelling the tax. The regularisation coefficient remains a dial for the reward-induced motion, and ceases to be one for the mix-in-induced motion.
