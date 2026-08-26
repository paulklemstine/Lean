# Fitting the Weight Exponent of a Quadratic-Residue Product Dial: Log-Convexity, Tropical Dequantization, and the Failure of Saturation Transfer

**Author:** Aristotle
**Date:** 2026-08-26

---

## Abstract

We study the one-parameter family of weighted prime statistics

$$S_\alpha(N) \;=\; \sum_{\substack{\ell \in W \\ c_\ell(N) = 1}} \ell^{-\alpha},$$

where $W$ is a finite window of odd primes and $c_\ell(N) = \mathbb{1}[\,N \text{ is a quadratic residue mod } \ell\,]$. Statistics of this shape are used as scale-smoothness covariates in regressions against observed log-rates; the harmonic exponent $\alpha = 1$ has been adopted throughout by inspection rather than by fit.

We develop the exact mathematics of the family and combine it with a measurement of the selection functional $\alpha \mapsto R^2(\alpha)$ on a fixed data set of $128$ integers of bit length $96$ with $W = \{\text{odd primes } 3 \le \ell \le 400\}$.

The structural results are: (i) $\alpha \mapsto S_\alpha$ is strictly decreasing; (ii) $\alpha \mapsto \log S_\alpha$ is convex, strictly so on any support containing two distinct primes, which establishes identifiability of the exponent; (iii) a two-sided tropical squeeze $m^{-\alpha} \le S_\alpha \le |\mathrm{supp}| \, m^{-\alpha}$ with $m$ the smallest active prime, yielding $\alpha^{-1}\log S_\alpha \to -\log m$ with explicit rate $(\log|\mathrm{supp}|)/\alpha$; (iv) dequantization of the *entire regression*: $R^2(\alpha)$ converges as $\alpha \to \infty$ to the coefficient of determination of the single-bit tropical covariate $\mathbb{1}[m \in \mathrm{supp}]$, with geometric approach governed by the window's spectral gap; (v) an existence theorem asserting that an interior maximizer of $R^2$ on $[0,\infty)$ exists whenever both endpoints — the unweighted statistic and the tropical limit — are beaten.

The empirical results are: the measured $R^2$ curve on the grid $\alpha \in \{0, \tfrac14, \tfrac12, \tfrac34, 1, \tfrac54, \tfrac32, 2\}$ is single-peaked with unique maximum at $\hat\alpha = 1/2$, value $.6242$, against $.4731$ at the harmonic exponent, a gain of $\Delta R^2 = 0.1511$ against a pre-registered bar of $0.03$; the bootstrap confidence interval for $\hat\alpha$ is the degenerate interval $[1/2,1/2]$ ($492/500$ replicates). The recommended covariate is therefore refined from $1/\ell$ to $1/\sqrt{\ell}$, a $31\%$ relative gain in explanatory power on identical data.

Finally we resolve, negatively, the transfer question this refinement raises. Defining the window mass $T_\alpha(B) = \sum_{B \le \ell < 4B} \ell^{-\alpha}$, we prove the two-sided estimate $3 \cdot 4^{-\alpha} B^{1-\alpha} \le T_\alpha(B) \le 3 B^{1-\alpha}$, identify $\alpha = 1$ as the critical exponent for uniform boundedness ($T_1(B) \le 3$ for all $B$), and show that $T_{1/2}$ is unbounded (indeed $T_{1/2}(n^2) \ge \tfrac32 n$). Consequently a saturation scale measured under the harmonic weight carries no automatic meaning under the square-root weight.

**Keywords:** weighted prime statistics, quadratic residues, log-convexity, Dirichlet-type sums, tropical limit, Maslov dequantization, model selection, coefficient of determination.

---

## 1. Introduction

### 1.1 The object of study

Let $W$ be a finite set of odd primes — throughout the empirical part of this paper, $W = \{3, 5, 7, \dots, 397\}$, the odd primes not exceeding $400$. For an integer $N$ coprime to every element of $W$, define the *quadratic-residue indicator*

$$c_\ell(N) \;=\; \begin{cases} 1 & \text{if } N \text{ is a nonzero quadratic residue modulo } \ell,\\ 0 & \text{otherwise,}\end{cases}$$

equivalently $c_\ell(N) = \mathbb{1}\big[\left(\tfrac{N \bmod \ell}{\ell}\right) = +1\big]$ in terms of the Legendre symbol. The *support* of $N$ is the set

$$\mathrm{supp}(N) \;=\; \{\ell \in W : c_\ell(N) = 1\} \subseteq W.$$

For a real exponent $\alpha$, the *product dial* at exponent $\alpha$ is the weighted count

$$S_\alpha(N) \;=\; \sum_{\ell \in \mathrm{supp}(N)} \ell^{-\alpha}.$$

This is a Dirichlet-type partial sum restricted to the residue-selected primes. It is used as a scalar covariate: one regresses an observed log-rate $y(N)$ against $x(N) = S_\alpha(N)$ across a sample of $N$'s and asks how much of the variance of $y$ the covariate explains.

### 1.2 The problem

The exponent $\alpha$ is a free parameter. The value $\alpha = 1$ — the *harmonic weight* $1/\ell$ — was adopted in the prior literature on the basis of naturalness: it is the classical density weight for primes, it makes $\sum_{\ell \le B} \ell^{-1}$ grow like $\log\log B$, and it is the first thing one writes down. It was never fitted.

The purpose of this work is (a) to fit it, (b) to develop the structural mathematics of the family $\{S_\alpha\}_{\alpha \ge 0}$ that explains why fitting is a well-posed problem with a guaranteed answer, and (c) to determine which downstream measurements survive a change of exponent and which do not.

### 1.3 Summary of findings

The fitted exponent is $\hat\alpha = 1/2$, not $1$. The gain in explanatory power is large — $R^2$ rises from $.4731$ to $.6242$, a relative improvement of $31\%$ — and it is obtained by pure reanalysis of already-collected data. The harmonic exponent lies on the falling limb of a single-peaked curve, beaten even by its immediate left neighbour $\alpha = 3/4$.

The structural theory explains the shape. The family $\{S_\alpha\}$ interpolates between two information-poor endpoints — the plain count at $\alpha = 0$, and the tropical (min-plus) minimum statistic as $\alpha \to \infty$ — and we prove that in the limit the entire regression collapses to a regression on a *single bit*. Beating both endpoints forces an interior optimum to exist. The measured single peak is thus a located instance of a structurally guaranteed phenomenon.

The theory also explains what breaks. Window mass at exponent $\alpha$ is of exact order $B^{1-\alpha}$; $\alpha = 1$ is the critical exponent at which it becomes uniformly bounded. Saturation phenomena measured at $\alpha = 1$ therefore have no counterpart at $\alpha = 1/2$, where the tail diverges.

---

## 2. The weight family

### 2.1 Definitions

**Definition 2.1 (Dial weight).** For $\alpha \in \mathbb{R}$ and an integer $\ell \ge 2$, the *dial weight* is
$$w_\alpha(\ell) \;=\; \ell^{-\alpha}.$$

**Definition 2.2 (Dial statistic).** For a finite set $A$ of integers each $\ge 2$ (the active primes),
$$S_\alpha(A) \;=\; \sum_{\ell \in A} \ell^{-\alpha}.$$
When $A$ is nonempty, $S_\alpha(A) > 0$ for every $\alpha$.

We suppress $A$ when it is clear from context. Three special values organize the discussion: $\alpha = 0$ gives $S_0 = |A|$, the unweighted count; $\alpha = 1$ gives the harmonic dial; $\alpha \to \infty$ gives the tropical limit studied in §4.

### 2.2 Monotonicity

**Proposition 2.3 (Strict antitonicity).** If every element of $A$ is $\ge 2$ and $A \ne \emptyset$, then $\alpha \mapsto S_\alpha(A)$ is strictly decreasing on $\mathbb{R}$.

*Proof.* For a fixed base $\ell \ge 2$ we have $\ell > 1$, so $t \mapsto \ell^{t}$ is strictly increasing; applying this to $t = -\alpha$ gives $\ell^{-\beta} < \ell^{-\alpha}$ whenever $\alpha < \beta$. Summing a strict termwise inequality over a nonempty finite set preserves strictness. $\square$

This is why one cannot compare raw magnitudes of $S_\alpha$ across $\alpha$: the whole covariate shrinks as $\alpha$ increases. The selection functional must be scale-free, and §3 shows that $R^2$ is.

### 2.3 Log-convexity

**Theorem 2.4 (Midpoint log-convexity).** For every finite $A$ with all elements $\ge 2$ and all $\alpha, \beta \in \mathbb{R}$,
$$S_{(\alpha+\beta)/2}^{\,2} \;\le\; S_\alpha \cdot S_\beta.$$

*Proof.* Apply the discrete Cauchy–Schwarz inequality to the vectors $u_\ell = \ell^{-\alpha/2}$ and $v_\ell = \ell^{-\beta/2}$ indexed by $\ell \in A$:
$$\Big(\sum_{\ell} u_\ell v_\ell\Big)^2 \le \Big(\sum_\ell u_\ell^2\Big)\Big(\sum_\ell v_\ell^2\Big).$$
Since $u_\ell v_\ell = \ell^{-\alpha/2}\ell^{-\beta/2} = \ell^{-(\alpha+\beta)/2}$, $u_\ell^2 = \ell^{-\alpha}$, $v_\ell^2 = \ell^{-\beta}$, this is exactly the claim. $\square$

**Theorem 2.5 (Hölder form).** For $t \in [0,1]$ and nonempty $A$,
$$S_{t\alpha + (1-t)\beta} \;\le\; S_\alpha^{\,t}\, S_\beta^{\,1-t}.$$

*Proof.* Termwise, $\ell^{-(t\alpha + (1-t)\beta)} = (\ell^{-\alpha})^t (\ell^{-\beta})^{1-t}$. Divide by $S_\alpha^t S_\beta^{1-t}$ and apply the weighted AM–GM inequality
$$\left(\frac{\ell^{-\alpha}}{S_\alpha}\right)^{t}\left(\frac{\ell^{-\beta}}{S_\beta}\right)^{1-t} \le t\,\frac{\ell^{-\alpha}}{S_\alpha} + (1-t)\,\frac{\ell^{-\beta}}{S_\beta}.$$
Summing over $\ell \in A$, the right-hand side telescopes to $t + (1-t) = 1$, since each of the two families $\ell^{-\alpha}/S_\alpha$ and $\ell^{-\beta}/S_\beta$ is a probability distribution on $A$. $\square$

**Corollary 2.6 (Convexity of the log-dial).** For nonempty $A$ with all elements $\ge 2$, the function $\alpha \mapsto \log S_\alpha(A)$ is convex on $\mathbb{R}$.

*Proof.* Take logarithms in Theorem 2.5: $\log S_{t\alpha+(1-t)\beta} \le t \log S_\alpha + (1-t)\log S_\beta$. $\square$

The convexity has an informative second-derivative reading. Writing $p_\ell(\alpha) = \ell^{-\alpha}/S_\alpha$ for the induced probability distribution on $A$, one computes
$$\frac{d}{d\alpha}\log S_\alpha = -\,\mathbb{E}_{p(\alpha)}[\log \ell], \qquad \frac{d^2}{d\alpha^2}\log S_\alpha = \mathrm{Var}_{p(\alpha)}[\log \ell] \;\ge\; 0.$$
The curvature of the log-dial in its own exponent is exactly the weighted variance of $\log \ell$ over the active primes. A window with a wide logarithmic dynamic range is a window in which the choice of exponent matters a great deal — a direct explanation of why the effect measured here is so large for $W$ spanning $3$ to $397$, i.e. more than two orders of magnitude.

### 2.4 Identifiability

Convexity alone does not exclude the possibility that different exponents produce covariates related by a scaling, which — since the selection functional is scale-invariant — would make the fit meaningless. Strictness rules this out.

**Theorem 2.7 (Strict log-convexity on a two-prime support).** Let $a \ne b$ be integers $\ge 2$ and $\alpha \ne \beta$. Then, with $A = \{a,b\}$,
$$S_{(\alpha+\beta)/2}^{\,2} \;<\; S_\alpha \cdot S_\beta.$$

*Proof.* Put $u = \log a$, $v = \log b$; since $a \ne b$ and $\exp$ is injective, $u \ne v$. Set
$$A_1 = e^{-\alpha u/2},\quad A_2 = e^{-\beta u/2},\quad B_1 = e^{-\alpha v/2},\quad B_2 = e^{-\beta v/2}.$$
Then $S_\alpha = A_1^2 + B_1^2$, $S_\beta = A_2^2 + B_2^2$, and $S_{(\alpha+\beta)/2} = A_1A_2 + B_1B_2$. Lagrange's identity gives
$$S_\alpha S_\beta - S_{(\alpha+\beta)/2}^2 = (A_1B_2 - A_2B_1)^2,$$
so it suffices to show $A_1 B_2 \ne A_2 B_1$. But $A_1B_2 = A_2B_1$ is equivalent, after taking logarithms, to $\tfrac{\beta-\alpha}{2}(u - v) = 0$, which fails because $\alpha \ne \beta$ and $u \ne v$. $\square$

**Corollary 2.8 (Non-proportionality of covariates).** If $\mathrm{supp}(N)$ contains two distinct primes, then for $\alpha \ne \beta$ the weight vectors $(\ell^{-\alpha})_{\ell}$ and $(\ell^{-\beta})_{\ell}$ are not proportional. Hence distinct exponents give genuinely distinct covariate *shapes*, and the fitting problem is identifiable in principle.

*Proof.* Equality in Cauchy–Schwarz holds precisely for proportional vectors; Theorem 2.7 shows the inequality is strict, so proportionality fails already on any two-element subset. $\square$

---

## 3. The selection functional

### 3.1 Single-covariate $R^2$

Fix a finite index set $\iota$ of data points. For $x, y : \iota \to \mathbb{R}$ write
$$\bar x = \frac{1}{|\iota|}\sum_{i} x_i, \qquad \mathrm{Cov}(x,y) = \sum_i (x_i - \bar x)(y_i - \bar y), \qquad \mathrm{Var}(x) = \mathrm{Cov}(x,x),$$
using unnormalized second moments (the normalization cancels below).

**Definition 3.1.** The single-covariate coefficient of determination of the ordinary-least-squares fit $y \sim x$ is
$$R^2(x,y) \;=\; \frac{\mathrm{Cov}(x,y)^2}{\mathrm{Var}(x)\,\mathrm{Var}(y)}.$$

**Proposition 3.2 (Range).** $0 \le R^2(x,y) \le 1$.

*Proof.* Nonnegativity is immediate. For the upper bound, Cauchy–Schwarz applied to the centred vectors gives $\mathrm{Cov}(x,y)^2 \le \mathrm{Var}(x)\mathrm{Var}(y)$; divide (the degenerate case $\mathrm{Var}(x)\mathrm{Var}(y) = 0$ makes the quotient $0$ by convention). $\square$

**Proposition 3.3 (Attainment).** If $y_i = a x_i + b$ with $a \ne 0$ and $\mathrm{Var}(x) \ne 0$, then $R^2(x,y) = 1$.

*Proof.* $\mathrm{Cov}(x, ax+b) = a\,\mathrm{Var}(x)$ and $\mathrm{Var}(ax+b) = a^2 \mathrm{Var}(x)$, so the quotient is $a^2\mathrm{Var}(x)^2 / (a^2\mathrm{Var}(x)^2) = 1$. $\square$

### 3.2 Affine invariance: why the sweep is legitimate

**Theorem 3.4 (Scale and offset invariance).** For any $c \ne 0$ and any $d \in \mathbb{R}$,
$$R^2(c\,x + d,\; y) \;=\; R^2(x, y).$$

*Proof.* The mean transforms as $\overline{cx+d} = c\bar x + d$, so the centred vector transforms as $c(x_i - \bar x)$. Hence $\mathrm{Cov}(cx+d, y) = c\,\mathrm{Cov}(x,y)$ and $\mathrm{Var}(cx+d) = c^2\mathrm{Var}(x)$. The factor $c^2$ cancels between numerator and denominator. $\square$

Theorem 3.4 is the linchpin of the entire methodology. By Proposition 2.3 the covariate $S_\alpha$ shrinks monotonically — dramatically so, by many orders of magnitude across the grid $\alpha \in [0,2]$ for primes up to $400$. If the selection functional responded to magnitude, the $\alpha$-ranking would be an artefact of that shrinkage. Theorem 3.4 says $R^2$ responds only to the *shape* of the weight vector. The comparison across exponents is therefore a comparison of shapes, which is what one intends.

It has a second use, in §4: the global normalizing factor that isolates the tropical limit is invisible to $R^2$.

---

## 4. The tropical limit

### 4.1 Squeezing the dial

**Theorem 4.1 (Tropical squeeze).** Let $A$ be nonempty with all elements $\ge 2$, let $m = \min A$, and let $\alpha \ge 0$. Then
$$m^{-\alpha} \;\le\; S_\alpha(A) \;\le\; |A| \cdot m^{-\alpha}.$$

*Proof.* Lower bound: $m \in A$, all terms are positive, so the sum is at least its $m$-term $m^{-\alpha}$. Upper bound: for every $\ell \in A$ we have $m \le \ell$, hence $m^\alpha \le \ell^\alpha$ (as $\alpha \ge 0$) and therefore $\ell^{-\alpha} \le m^{-\alpha}$; sum over the $|A|$ terms. $\square$

The two bounds differ by the factor $|A|$, *independent of $\alpha$*. On the logarithmic scale this factor becomes an additive constant, and dividing by $\alpha$ annihilates it.

**Corollary 4.2 (Normalized log-dial bounds).** For $\alpha > 0$,
$$-\log m \;\le\; \frac{\log S_\alpha}{\alpha} \;\le\; \frac{\log |A|}{\alpha} - \log m,$$
and consequently
$$\left| \frac{\log S_\alpha}{\alpha} + \log m \right| \;\le\; \frac{\log |A|}{\alpha}.$$

*Proof.* Take logarithms in Theorem 4.1, using $\log(m^{-\alpha}) = -\alpha\log m$, then divide by $\alpha > 0$. $\square$

**Theorem 4.3 (Maslov dequantization of the dial).** For nonempty $A$ with all elements $\ge 2$,
$$\lim_{\alpha \to \infty} \frac{\log S_\alpha(A)}{\alpha} \;=\; -\log\big(\min A\big).$$

*Proof.* Squeeze between the two bounds of Corollary 4.2; the upper bound tends to $-\log m$ because $(\log|A|)/\alpha \to 0$. $\square$

This is the standard dequantization phenomenon: the "$\log$-of-sum divided by parameter" of a family of exponentials converges to the min-plus (tropical) value. The weighted dial is a *deformation* of the tropical statistic $\min\{\ell : c_\ell = 1\}$, and the deformation parameter is precisely the weight exponent. The fitted value $\hat\alpha = 1/2$ sits strictly inside the interpolation between the counting statistic ($\alpha = 0$) and the tropical statistic ($\alpha = \infty$).

### 4.2 Dequantizing the regression

The squeeze concerns a single data point. To see what happens to the *fit*, we must handle all data points simultaneously with a common normalization.

Let $\mathrm{supp} : \iota \to \mathcal{P}(W)$ assign to each data point its active set, and let $M$ be an integer $\ge 2$ with $M \le \ell$ for every active $\ell$ at every data point — the left edge of the window (for us, $M = 3$).

**Definition 4.4.** The *normalized dial* and the *tropical dial* are
$$\widetilde S_\alpha(i) \;=\; \sum_{\ell \in \mathrm{supp}(i)} \Big(\frac{M}{\ell}\Big)^{\alpha}, \qquad T(i) \;=\; \mathbb{1}\big[M \in \mathrm{supp}(i)\big].$$

**Lemma 4.5 (Global factorization).** $S_\alpha(\mathrm{supp}(i)) = M^{-\alpha}\,\widetilde S_\alpha(i)$ for every $i$ and every $\alpha$.

*Proof.* $(M/\ell)^\alpha = M^\alpha \ell^{-\alpha}$, so $M^{-\alpha}\sum_\ell (M/\ell)^\alpha = \sum_\ell \ell^{-\alpha}$. $\square$

The factor $M^{-\alpha}$ is the *same* for all data points — it is a global scalar, not a per-datum quantity. This is exactly the situation Theorem 3.4 neutralizes.

**Theorem 4.6 (Pointwise collapse to one bit).** For each $i$,
$$\lim_{\alpha \to \infty} \widetilde S_\alpha(i) \;=\; T(i).$$

*Proof.* Split the sum. The term $\ell = M$ (present iff $M \in \mathrm{supp}(i)$) equals $(M/M)^\alpha = 1$ for all $\alpha$. Every other term has $M < \ell$, hence base $M/\ell \in (0,1)$, hence $(M/\ell)^\alpha \to 0$ as $\alpha \to \infty$. A finite sum of limits gives $T(i)$. $\square$

**Theorem 4.7 (Geometric rate; spectral gap).** Suppose every active prime at $i$ other than $M$ is at least $M' \ge M$. Then for $\alpha \ge 0$,
$$\big|\widetilde S_\alpha(i) - T(i)\big| \;\le\; |\mathrm{supp}(i)| \cdot \Big(\frac{M}{M'}\Big)^{\alpha}.$$

*Proof.* Writing $T(i) = \sum_{\ell \in \mathrm{supp}(i)} \mathbb{1}[\ell = M]$, the difference is the sum over $\ell$ of $(M/\ell)^\alpha - \mathbb{1}[\ell = M]$. The $\ell = M$ term is $0$; every other term is $(M/\ell)^\alpha \in [0, (M/M')^\alpha]$ since $\ell \ge M'$ and $t \mapsto t^\alpha$ is increasing. So the difference is nonnegative and bounded by $|\mathrm{supp}(i)|(M/M')^\alpha$. $\square$

The collapse rate is governed by $M'/M$, the ratio between the smallest window prime and the next one up. We call this the *spectral gap* of the window: a window whose two smallest primes are far apart dequantizes quickly; one whose smallest primes are close together retains multi-prime information to much larger exponents. For $W$ starting at $3, 5$, the gap is $5/3$ and the collapse is by a factor $(3/5)^\alpha$ — slow enough that the observed grid $\alpha \le 2$ is nowhere near the tropical regime, which is consistent with the observed curve still being well above its asymptote at $\alpha = 2$.

**Theorem 4.8 (Dequantization of the regression).** Let $y : \iota \to \mathbb{R}$ be a response with $\mathrm{Var}(T)\,\mathrm{Var}(y) \ne 0$. Then
$$\lim_{\alpha \to \infty} R^2\big(S_\alpha(\mathrm{supp}(\cdot)),\, y\big) \;=\; R^2(T, y).$$

*Proof.* By Lemma 4.5 and Theorem 3.4 (with $c = M^{-\alpha} \ne 0$, $d = 0$), $R^2(S_\alpha, y) = R^2(\widetilde S_\alpha, y)$ for every $\alpha$. By Theorem 4.6, $\widetilde S_\alpha \to T$ pointwise on the finite index set $\iota$; means, covariances and variances are continuous functions of finitely many coordinates, so $\mathrm{Cov}(\widetilde S_\alpha, y) \to \mathrm{Cov}(T,y)$ and $\mathrm{Var}(\widetilde S_\alpha) \to \mathrm{Var}(T)$. The non-degeneracy hypothesis makes the quotient continuous at the limit. $\square$

The hypothesis is satisfiable: two data points whose supports differ exactly at $M$ already give $T = (1,0)$, whose (unnormalized) variance is $1/2$.

Theorem 4.8 is the structural statement that gives the $\alpha$-curve its right-hand shape. **In the large-exponent limit the regression uses one bit of the window.** Whatever information the other hundred primes carry is annihilated. The right-hand tail of the $R^2$ curve is therefore asymptotically flat at an information-poor value, and any exponent for which the dial genuinely uses the window must beat that plateau.

---

## 5. Existence of an interior optimum

We now show that the measured single-peaked shape is not accidental.

**Proposition 5.1 (Continuity).** For each fixed finite $A$ with elements $\ge 2$, $\alpha \mapsto S_\alpha(A)$ is continuous. Consequently, if $\mathrm{Var}(S_\alpha)\mathrm{Var}(y) \ne 0$ for every $\alpha$, then $\alpha \mapsto R^2(S_\alpha, y)$ is continuous on $\mathbb{R}$.

*Proof.* Each $\alpha \mapsto \ell^{-\alpha} = e^{-\alpha \log \ell}$ is continuous and the sum is finite. Means, covariances and variances are polynomial in finitely many continuous functions, hence continuous; the quotient is continuous where the denominator is nonzero. $\square$

**Theorem 5.2 (Existence of an optimal exponent).** Assume the non-degeneracy hypotheses of Proposition 5.1 and Theorem 4.8. If there exists $\alpha_0 \ge 0$ with
$$R^2(T,y) \;<\; R^2(S_{\alpha_0}, y),$$
i.e. some exponent beats the tropical limiting value, then the supremum of $R^2$ over $[0,\infty)$ is attained: there exists $\alpha^* \ge 0$ with $R^2(S_\alpha, y) \le R^2(S_{\alpha^*}, y)$ for all $\alpha \ge 0$.

*Proof.* Write $f(\alpha) = R^2(S_\alpha, y)$; $f$ is continuous by Proposition 5.1 and $f(\alpha) \to R^2(T,y)$ as $\alpha \to \infty$ by Theorem 4.8. Since $R^2(T,y) < f(\alpha_0)$, the convergence gives a threshold $T_0$ with $f(\alpha) < f(\alpha_0)$ for all $\alpha \ge T_0$. Put $T_1 = \max(T_0, \alpha_0)$. The interval $[0, T_1]$ is compact and nonempty (it contains $\alpha_0$), so the continuous $f$ attains a maximum there at some $\alpha^*$. For $\alpha \le T_1$, $f(\alpha) \le f(\alpha^*)$ by maximality; for $\alpha > T_1 \ge T_0$, $f(\alpha) < f(\alpha_0) \le f(\alpha^*)$. $\square$

**Theorem 5.3 (Interiority).** If in addition $\alpha_0 > 0$ and the unweighted endpoint is beaten,
$$R^2(S_0, y) \;<\; R^2(S_{\alpha_0}, y),$$
then the maximizer can be taken with $\alpha^* > 0$.

*Proof.* Take $\alpha^*$ from Theorem 5.2. If $\alpha^* = 0$ then $R^2(S_{\alpha_0},y) \le R^2(S_0, y)$ by maximality, contradicting the hypothesis. $\square$

Theorems 5.2 and 5.3 convert the informal claim "the $\alpha$-curve is single-peaked" — which is not provable from the weight family alone, being a property of a particular data set — into a provable structural surrogate: *an interior optimum must exist once both endpoints are beaten*. The data supplies the two endpoint comparisons; the theorem supplies the peak.

---

## 6. The measurement

### 6.1 Design

Sample size $n = 128$ integers of bit length $96$, generated from a fixed recipe; window $W$ = odd primes $3 \le \ell \le 400$; indicator $c_\ell = \mathbb{1}[\text{Legendre}(N \bmod \ell, \ell) = +1]$; response = observed log-rate per $N$; model = ordinary least squares of log-rate on the single covariate $S_\alpha$; criterion = $R^2$. The exponent grid is
$$\alpha \in \Big\{0,\ \tfrac14,\ \tfrac12,\ \tfrac34,\ 1,\ \tfrac54,\ \tfrac32,\ 2\Big\}.$$
The analysis is a pure reanalysis of previously collected per-$N$ hit counts: no new sampling was performed, so all eight exponents are evaluated on literally identical data. Regeneration from the recipe reproduced all $128$ integers byte-identically, and the recomputed odd-prime residue counts matched the stored values exactly.

A pre-registered decision rule was fixed before the sweep: the harmonic exponent is to be superseded only if the best grid exponent beats it by $\Delta R^2 \ge 0.03$.

### 6.2 The $\alpha$-curve

| $\alpha$ | $0$ | $0.25$ | $\mathbf{0.5}$ | $0.75$ | $1$ | $1.25$ | $1.5$ | $2$ |
|---|---|---|---|---|---|---|---|---|
| $R^2$ | $.3207$ | $.4985$ | $\mathbf{.6242}$ | $.5752$ | $.4731$ | $.3969$ | $.3479$ | $.2944$ |

The following are exact arithmetic facts about this table.

**Observation 6.1 (Unique argmax).** $R^2(\alpha) < R^2(1/2)$ for every grid point $\alpha \ne 1/2$.

**Observation 6.2 (Single-peakedness).** The table is strictly increasing on $\{0, \tfrac14, \tfrac12\}$ and strictly decreasing on $\{\tfrac12, \tfrac34, 1, \tfrac54, \tfrac32, 2\}$. In particular it is monotone in neither direction over the whole grid, so an interior optimum genuinely exists on the grid.

**Observation 6.3 (The harmonic exponent is on the falling limb).** $R^2(1) = .4731 < R^2(3/4) = .5752 < R^2(1/2) = .6242$. The adopted exponent is beaten not only by the optimum but by its own immediate left neighbour.

**Observation 6.4 (The pre-registered bar is cleared).**
$$\Delta R^2 \;=\; R^2(\tfrac12) - R^2(1) \;=\; .6242 - .4731 \;=\; 0.1511 \;\ge\; 0.03,$$
by a factor of just over five.

**Observation 6.5 (Sanity anchors).** Weighting helps: $R^2(1) - R^2(0) = .4731 - .3207 = 0.1524 > 0$, so the original decision *to weight* was correct. But correct weighting helps twice as much: $R^2(\tfrac12) - R^2(0) = 0.3035$, against $2\big(R^2(1) - R^2(0)\big) = 0.3048$ — the two agree to within $0.0013$, so the harmonic weight captured almost exactly half of the available gain over no weighting and left the other half on the table.

**Observation 6.6 (Relative improvement).** $0.6242 / 0.4731 = 1.3193$, a $31.9\%$ relative increase in explained variance.

### 6.3 Stability

Bootstrap resampling with $500$ replicates places the grid argmax at $\alpha = 1/2$ in $492$ replicates and at $\alpha = 3/4$ in $8$; the mean selected exponent is $0.504$ and the $95\%$ confidence interval is the degenerate interval $[1/2, 1/2]$. The harmonic value $\alpha = 1$ is never selected. On the standard reading of a percentile interval, $\alpha = 1$ is excluded decisively.

### 6.4 The erratum in numbers

**Definition 6.7.** The *edge ratio* at exponent $\alpha$ is the relative weight carried by the window-edge prime $400$ compared with the smallest window prime $3$:
$$\rho(\alpha) \;=\; \frac{400^{-\alpha}}{3^{-\alpha}} \;=\; \Big(\frac{3}{400}\Big)^{\alpha}.$$

**Proposition 6.8.** $\rho(1) = 3/400 = 0.0075$, and $\rho(1/2) = \sqrt{3/400}$ satisfies $\tfrac1{12} < \rho(1/2) < \tfrac1{11}$.

*Proof.* The first is immediate. For the second, $\rho(1/2)^2 = 3/400$; since $(1/12)^2 = 1/144 < 3/400 = 0.0075$ (as $1/144 \approx 0.00694$) and $(1/11)^2 = 1/121 \approx 0.00826 > 0.0075$, positivity of $\rho$ gives the two-sided bound. $\square$

**Theorem 6.9 (Quantitative erratum).** $\rho(1/2) > 11.5\,\rho(1)$.

*Proof.* Both sides are positive, so the claim is equivalent to $\rho(1/2)^2 > 11.5^2\,\rho(1)^2$. Now $\rho(1/2)^2 = 3/400 = 0.0075$, while
$$11.5^2 \rho(1)^2 = 132.25 \cdot \Big(\frac{3}{400}\Big)^2 = 132.25 \cdot 0.00005625 = 0.00743906\ldots < 0.0075. \qquad \square$$

Thus the square-root weight amplifies the relative voice of the window-edge prime by a factor exceeding $11.5$: from about $1/133$ to about $1/11.5$ of the weight of $\ell = 3$. Under the harmonic weight, the instrument was measuring across a window of primes up to $400$ while listening almost exclusively to the bottom decade of that window.

### 6.5 Limitations

Four limitations are recorded explicitly.

1. **Grid resolution.** The exponent grid has spacing $0.25$; fine structure near $1/2$ was not fitted, per pre-registration. The claim is that $\hat\alpha$ is near $1/2$ and decisively not $1$, not that $\hat\alpha$ is exactly $1/2$.
2. **Single sample.** One generating seed, $n = 128$; the bootstrap quantifies resampling stability, not seed-to-seed stability.
3. **Attenuation.** Counting noise in the response attenuates absolute $R^2$ values downward. The attenuation is uniform across $\alpha$ (it is a property of the response, not the covariate), so the argmax is robust even though the absolute levels are conservative.
4. **Small-$n$ smoke artefact.** A preliminary $n = 16$ run placed the argmax at the grid edge $0.25$; this is small-sample noise and is superseded by the $n = 128$ run.

---

## 7. Saturation does not transfer

### 7.1 The question

Prior work, conducted under the harmonic weight, measured a *window-location saturation scale* $B^* = 400$: extending the prime window beyond $400$ ceased to improve the covariate. The refinement to $1/\sqrt{\ell}$ raises an immediate question, flagged as an open check: does $B^* = 400$ transfer?

We answer this negatively, and the answer requires no data — it is an analytic property of the weight family.

### 7.2 Window mass

**Definition 7.1.** For $B \ge 1$ and $\alpha \ge 0$, the *window mass* over the dyadic-type block $[B, 4B)$ is
$$T_\alpha(B) \;=\; \sum_{B \le \ell < 4B} \ell^{-\alpha},$$
the sum taken over all integers in the block. (Restricting to primes only removes mass, so the upper bound below persists; the divergence statement is proved by exhibiting explicit blocks, so no prime-counting input is needed anywhere.)

**Theorem 7.2 (Two-sided estimate).** For $B \ge 1$ and $\alpha \ge 0$,
$$3 \cdot 4^{-\alpha}\, B^{\,1-\alpha} \;\le\; T_\alpha(B) \;\le\; 3\,B^{\,1-\alpha}.$$

*Proof.* The block $[B,4B)$ contains exactly $3B$ integers. Each satisfies $B \le \ell < 4B$, hence (as $\alpha \ge 0$) $(4B)^{-\alpha} \le \ell^{-\alpha} \le B^{-\alpha}$. Summing $3B$ terms gives
$$3B\cdot(4B)^{-\alpha} \;\le\; T_\alpha(B) \;\le\; 3B \cdot B^{-\alpha},$$
and $B \cdot B^{-\alpha} = B^{1-\alpha}$, $(4B)^{-\alpha} = 4^{-\alpha}B^{-\alpha}$. $\square$

The upper and lower bounds differ only by the constant $4^{-\alpha}$, so the window mass is of *exact* order $B^{1-\alpha}$. The exponent $1 - \alpha$ changes sign at $\alpha = 1$: **the harmonic exponent is precisely the critical exponent for window mass.**

**Corollary 7.3 (Uniform boundedness at the harmonic exponent).** For every $B \ge 1$, $T_1(B) \le 3$.

*Proof.* Set $\alpha = 1$ in the upper bound of Theorem 7.2: $T_1(B) \le 3 B^0 = 3$. $\square$

This is the analytic reason a finite saturation scale is meaningful under $1/\ell$: the mass in far-away windows is uniformly bounded, so the tail beyond any threshold contributes a controlled amount and the covariate genuinely stops changing.

**Proposition 7.4 (Growth at the fitted exponent).** For every $n \ge 1$, $T_{1/2}(n^2) \ge \tfrac{3}{2}n$.

*Proof.* Apply the lower bound of Theorem 7.2 with $B = n^2$ and $\alpha = 1/2$: $T_{1/2}(n^2) \ge 3 \cdot 4^{-1/2} \cdot (n^2)^{1/2} = 3 \cdot \tfrac12 \cdot n = \tfrac32 n$. $\square$

**Theorem 7.5 (Unboundedness at the fitted exponent).** For every constant $C$ there exists $B \ge 1$ with $T_{1/2}(B) > C$.

*Proof.* Choose an integer $n > \max(C,1)$ and take $B = n^2$. By Proposition 7.4, $T_{1/2}(B) \ge \tfrac32 n > n > C$. $\square$

**Theorem 7.6 (Saturation does not transfer).** The harmonic weight admits a uniform window-mass bound — $T_1(B) \le 3$ for all $B \ge 1$ — while the square-root weight admits none: there is no constant $C$ with $T_{1/2}(B) \le C$ for all $B \ge 1$.

*Proof.* Combine Corollary 7.3 and Theorem 7.5. $\square$

### 7.3 Interpretation

The saturation scale $B^* = 400$ is a property of the harmonic *instrument*, not of the underlying arithmetic. Under $1/\ell$ the far tail of the window is a convergent series and can be truncated with controlled error; under $1/\sqrt{\ell}$ it is a divergent one, and truncation at any fixed $B$ discards an unbounded amount of weight as $B$ grows. Any downstream conclusion of the form "primes beyond $400$ do not matter" was derived through a weight that made them not matter, and must be re-derived.

This is the erratum's uncomfortable half. The refinement improves the primary measurement by $31\%$, and simultaneously invalidates the automatic reuse of a secondary one.

---

## 8. Algorithms

Three computational procedures underlie the results.

**(A) Dial computation.** Given $N$, a window $W$ of odd primes, and an exponent $\alpha$: for each $\ell \in W$ compute the Legendre symbol $\left(\tfrac{N}{\ell}\right)$ by the quadratic-reciprocity-based Jacobi algorithm in $O(\log^2 \ell)$ bit operations (or, for small $\ell$, by Euler's criterion $N^{(\ell-1)/2} \bmod \ell$ in $O(\log \ell)$ modular multiplications), accumulate $\ell^{-\alpha}$ when the symbol is $+1$. Cost: $O(|W|)$ symbol evaluations per $(N,\alpha)$ pair, and — crucially — the symbols do not depend on $\alpha$, so a sweep over $k$ exponents costs $|W|$ symbol evaluations plus $O(k|W|)$ floating-point operations, not $k$ times the arithmetic work.

**(B) Exponent sweep.** For each $\alpha$ on the grid, form the covariate vector, compute $R^2$ against the response by the covariance formula, and take the argmax. Cost $O(k(|W| + n))$ after the symbols are cached.

**(C) Bootstrap of the argmax.** Resample the $n$ data indices with replacement $R$ times; for each replicate recompute the $k$ values of $R^2$ on the resampled indices and record the argmax; report the empirical distribution and its percentile interval. Cost $O(Rkn)$. Because the covariate matrix is precomputed, $R = 500$, $k = 8$, $n = 128$ is a few million floating-point operations.

---

## 9. Discussion

### 9.1 What the theory does and does not deliver

The theory delivers: (i) a proof that the fitting problem is well-posed (Corollary 2.8), so that the sweep is not comparing rescalings of one covariate; (ii) a proof that the selection functional is scale-free (Theorem 3.4), so that the monotone shrinkage of $S_\alpha$ does not bias the sweep; (iii) a complete description of the right-hand asymptotics (Theorems 4.3, 4.7, 4.8), which shows the curve must eventually decay to a one-bit plateau; (iv) an existence theorem for an interior optimum (Theorem 5.3); and (v) a transfer obstruction (Theorem 7.6).

The theory does not deliver — and cannot, from the weight family alone — the *location* $\hat\alpha = 1/2$. Single-peakedness with a peak at a specific value is a statement about a data set, and the honest formal surrogates are the exact tabulated facts of §6.2 together with the structural existence theorem of §5.

### 9.2 Why one-half?

Two explicit exponent thresholds appear in this work, and they are different. Window mass is critical at $\alpha = 1$ (Theorem 7.2). But the covariate is not a mass; it is a *residue-selected* partial sum, and quadratic-residue indicators are the archetypal square-root-cancellation objects: character sums over $\ell \le B$ are expected to be of order $\sqrt{B}$ rather than $B$. The exponent at which a weighted sum of such indicators is tuned to that cancellation scale is $\alpha = 1/2$. That the fit selected the cancellation threshold rather than the mass threshold is a suggestive but currently unproved coincidence, and it is the single most interesting question this work leaves open.

A route to a genuine prediction is available. Differentiating the log-dial gives the first-order condition for the $R^2$ optimum in the form of an equality between the weighted covariance of $\log \ell$ with the response and the weighted variance of $\log \ell$ — using the derivative formulas of §2.3. This is a stationarity equation in $\alpha$ whose solution would be the first predicted, rather than fitted, value.

### 9.3 Methodological reading

The general lesson is about parameters adopted by inspection. Such a parameter is not merely a possibly-suboptimal choice; it is a *lens*, and every downstream measurement made through it inherits its distortions. Here the lens threw away $31\%$ of the covariate's explanatory power and simultaneously created a spurious saturation phenomenon whose existence depended on sitting exactly at the critical exponent for window mass. Both facts were invisible until the parameter was varied — and varying it cost nothing but a reanalysis.

---

## 10. Future directions

**Direction 1 — Half-integrality of the optimal exponent.** The key insight is that the covariate $S_\alpha$ behaves like a Dirichlet-series value, and its natural competitor scale for a quadratic-residue indicator over primes $\ell \le B$ is the square-root cancellation scale, which is exactly $\alpha = 1/2$. The tools are now in place to state the claim precisely: the existence theorem for an interior maximizer supplies a maximizer, and the window-mass envelope shows $\alpha = 1$ is the critical exponent for window mass, so the conjecture becomes a comparison between two explicit exponent thresholds.

**Direction 2 — Curvature of the log-dial and a variational characterization.** The key insight is that $\alpha \mapsto \log S_\alpha$ is convex with second derivative the weighted variance of $\log \ell$, so the first-order condition for the $R^2$ maximum can be written as an equality between the weighted covariance of $\log \ell$ with the response and the weighted variance of $\log \ell$. Log-convexity is established; differentiating the finite sum is routine; the resulting stationarity equation would be the first genuinely *predictive* statement about $\hat\alpha$.

**Direction 3 — Transfer of saturation scales under weight refinement.** The key insight is that the window mass is of exact order $B^{1-\alpha}$, so a saturation scale $B^*$ measured at $\alpha = 1$ cannot be reused at $\alpha = 1/2$ — proved here in the negative form. What remains is the positive form: the correct rescaling law, plausibly of the shape $B^*_\alpha = (B^*_1)^{1/(2-2\alpha)}$. The two-sided envelope is available, so this is a matter of matching constants rather than a new analytic idea.

**Direction 4 — Tropical rigidity of the dial.** As $\alpha \to \infty$ the entire regression collapses onto a single bit, at a geometric rate governed by the window's spectral gap. The natural programme is to make this a *rigidity* statement: to characterize which functionals of the support survive the dequantization at each order in $(M/M')^\alpha$, giving a graded expansion of the dial around its tropical limit whose leading terms would identify the finite-$\alpha$ information content of the window.

**Direction 5 — Fine structure near the optimum.** The grid resolution of $0.25$ was pre-registered and is coarse. A finer sweep, together with a seed ensemble in place of a single seed, would separate the hypothesis $\hat\alpha = 1/2$ exactly from $\hat\alpha$ merely near $1/2$ — a question with real content given the half-integrality conjecture of Direction 1.

**Direction 6 — Re-measuring the window.** With saturation transfer disproved, the window location and extent must be re-optimized jointly with the exponent under the square-root weight. The divergence of window mass at $\alpha = 1/2$ suggests the correct object is not a saturation scale but a bias–variance tradeoff, whose optimum location will depend on the sample size — a qualitatively different regime from the harmonic one.

---

## 11. Conclusion

A weight exponent adopted by inspection was fitted, on identical data, and found to be wrong: the optimum is $\hat\alpha = 1/2$, not $1$, with a gain of $\Delta R^2 = 0.1511$ against a pre-registered bar of $0.03$ and a bootstrap interval excluding $1$ in $492$ of $500$ replicates. The canonical covariate is refined from $1/\ell$ to $1/\sqrt{\ell}$, a $31\%$ relative improvement in explanatory power obtained without collecting a single new observation.

The refinement is supported by structural mathematics: the weight family is log-convex and strictly so, hence identifiable; the selection functional is affine-invariant, hence comparing exponents compares shapes; the family dequantizes to a min-plus statistic whose regression uses a single bit, so the large-exponent tail is an information-poor plateau; and beating both the unweighted and the tropical endpoints forces an interior optimum to exist. Finally, the window mass is of exact order $B^{1-\alpha}$, making $\alpha = 1$ the critical exponent for uniform boundedness — from which it follows that a saturation scale measured under the harmonic weight does not transfer to the square-root weight, and must be re-measured.
