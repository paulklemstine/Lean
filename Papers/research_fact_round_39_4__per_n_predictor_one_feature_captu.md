# Per-Modulus Predictors at the Sampling Ceiling: A Single Quadratic-Residue Count Captures Two-Thirds of the Achievable Signal in Sieve Smoothness Rates

**Author:** Aristotle

**Date:** 2026-10-11

---

## Abstract

We study how well the smoothness rate of quadratic-sieve values $j^2 - N$ can be predicted from the modulus $N$ alone, when only a fixed number $n$ of binary outcomes (smooth / not smooth) is observed per modulus. We prove a set of exact finite-sample identities that separate what *any* per-modulus predictor can achieve from what is irreducible sampling noise. (i) For every per-modulus predictor $f$, the residual sum of squares equals the within-modulus sum of squares plus $n\sum_N(\bar y_N - f(N))^2$. Hence the in-sample $R^2$ of any such predictor is bounded by a *sampling ceiling* $1 - \mathrm{SSW}/\mathrm{SST}$, and only the per-modulus means reach it. (ii) For binary data the within-modulus sum of squares is exactly $n\sum_N \bar y_N(1-\bar y_N)$. In population, a binomial rate obeys $\mathbb E[(k/n - c)^2] = (\theta - c)^2 + \theta(1-\theta)/n$, so the observed per-modulus variance is systematic variance plus a binomial floor. (iii) The population ceiling $V/(V+E/n)$ is strictly increasing in $n$ and tends to $1$. (iv) The ordinary-least-squares predictor on a single feature has $R^2 = \text{ceiling}\cdot\rho^2$, with $\rho$ the correlation between the feature and the per-modulus means. (v) A residual equal to $\kappa$ times the floor attains the fraction $1 - (\kappa-1)F/(T-F)$ of the ceiling. On the number-theoretic side we analyse the feature $\mathrm{QR}(N)$, the number of odd primes $p \le 100$ at which $N$ passes Euler's criterion. We give its exact mean and variance over a period of the Chinese Remainder Theorem, and we prove a *factor-blindness* theorem: conditioned on any nonzero residue of $N$ modulo $p$, the factorizations of that residue are split exactly evenly by the quadratic character of the hidden factor. Empirically, the one-feature predictor $\beta_0 + \beta_1 \mathrm{QR}(N)$ attains held-out $R^2 = 0.2998$ at $u = 2.5$ and $0.2246$ at $u = 3.5$. Against ceilings of about $0.45$ and $0.31$ at $60$ values per modulus, these are $66\%$ and $73\%$ of the ceiling, with a residual only $1.12$–$1.24$ times the binomial floor. An audit using the identities above shows that the $u = 3.5$ figures are mutually consistent, while the $u = 2.5$ triple is in mild tension.

---

## 1. Introduction

The quadratic sieve factors an odd composite $N$ by collecting values $v_j = j^2 - N$, with $j$ slightly larger than $\sqrt N$, that are $B$-smooth (all prime factors at most $B$), and then combining them into a congruence of squares. Its cost is dominated by the *smoothness rate*: the probability that a sieve value is $B$-smooth. Heuristically, this rate depends on the size of the values through the Dickman parameter $u = \log v / \log B$. It also depends on the modulus $N$ itself. An odd prime $p \nmid N$ divides $j^2 - N$ for exactly two residue classes of $j$ when $N$ is a quadratic residue mod $p$, and for none when it is not. Moduli that are residues modulo many small primes therefore produce more small factors, and their sieve values are smooth more often.

This raises a calibration question: *how much of the per-modulus variation in smoothness rate can a simple arithmetic feature of $N$ explain?* The experiment reported here (a panel of moduli, $n = 60$ sieve values per modulus, held-out evaluation, fixed random seed) answers it with the minimal predictor

$$\widehat{\mathrm{rate}}(N) = \beta_0 + \beta_1\,\mathrm{QR}(N), \qquad \mathrm{QR}(N) = \#\{p \le 100 \text{ odd prime} : N^{(p-1)/2} \equiv 1 \pmod p\},$$

which takes $24$ modular exponentiations to compute.

A raw $R^2$ near $0.3$ looks modest. The central point of this paper is that it should be judged against the right benchmark. With only $n$ binary trials per modulus, a large share of the observed variance in per-modulus rates is binomial sampling noise that no function of $N$ can predict. We develop the exact algebra of this ceiling, connect the one-feature $R^2$ to a squared correlation, and derive the arithmetic linking the residual-to-floor ratio to the fraction of the ceiling attained. We also prove the number-theoretic facts that make the QR count a well-behaved feature, and that show it carries no information about the factors of $N$.

**Summary of contributions.**

1. *Ceiling theorem* (Theorems 3.1–3.4): an exact decomposition of the residual of any per-modulus predictor, an upper bound on its $R^2$, and the exact headroom left for richer features.
2. *Binomial floor* (Theorems 3.5, 4.2, 4.3): the within-modulus sum of squares of binary data, and the bias–variance law of an observed binomial rate.
3. *Ceiling growth* (Theorem 5.1): the population ceiling increases strictly with the number of values per modulus and tends to $1$.
4. *One-feature law* (Theorem 6.4): $R^2 = \text{ceiling}\cdot\rho^2$.
5. *Fraction-of-ceiling law and consistency audit* (Section 7).
6. *The QR-count feature* (Section 8): Euler's test equals the Legendre symbol test; exact moments; orthogonality under the Chinese Remainder Theorem.
7. *Factor blindness* (Section 9).

---

## 2. Setting and definitions

Let $\mathcal I$ be a finite, nonempty panel of moduli, and let $n \ge 1$. For every $N \in \mathcal I$ we observe outcomes $y_{N,1},\dots,y_{N,n} \in \mathbb R$. In the application $y_{N,i}\in\{0,1\}$ records whether the $i$-th sieve value for $N$ is smooth.

**Definition 2.1 (per-modulus mean, sums of squares).**

* Per-modulus mean: $\bar y_N = \frac1n\sum_{i=1}^n y_{N,i}$.
* Within-modulus sum of squares: $\mathrm{SSW} = \sum_N\sum_i (y_{N,i} - \bar y_N)^2$.
* A *per-modulus predictor* is any function $f:\mathcal I\to\mathbb R$. Its residual sum of squares is $\mathrm{RSS}(f) = \sum_N\sum_i (y_{N,i} - f(N))^2$.
* Panel mean of a per-modulus quantity $v$: $\langle v\rangle = \frac{1}{|\mathcal I|}\sum_N v(N)$. Grand mean: $\bar y = \langle \bar y_\cdot\rangle$.
* Total sum of squares: $\mathrm{SST} = \mathrm{RSS}(\text{constant } \bar y)$.
* Coefficient of determination relative to a total $T>0$: $R^2_T(f) = 1 - \mathrm{RSS}(f)/T$.

**Definition 2.2 (centred cross-products).** For per-modulus quantities $u, v$, put $S_{uv} = \sum_N (u(N) - \langle u\rangle)(v(N)-\langle v\rangle)$. When $S_{xx}, S_{mm} > 0$, the squared correlation is $\rho^2(x,m) = S_{xm}^2/(S_{xx}S_{mm})$.

**Definition 2.3 (binomial weights).** For $n\in\mathbb N$, $\theta\in\mathbb R$ and $0\le k\le n$, put $b_{n,k}(\theta) = \binom nk \theta^k(1-\theta)^{n-k}$. These are the Bernstein basis polynomials evaluated at $\theta$. For $\theta\in[0,1]$ they form the law of a $\mathrm{Binomial}(n,\theta)$ count.

**Definition 2.4 (population ceiling).** For systematic variance $V$, mean per-draw variance $E$ and $n$ draws per modulus, put $\mathrm{ceil}(V,E,n) = V/(V + E/n)$.

**Definition 2.5 (Euler test and QR count).** For an odd prime $p$ and an integer $N$, $N$ *passes the Euler test at $p$* if $N^{(p-1)/2} \equiv 1 \pmod p$. For a finite set $S$ of odd primes, $\mathrm{QR}_S(N)$ is the number of $p\in S$ at which $N$ passes. We write $\mathrm{QR}(N)$ when $S$ is the set of the $24$ odd primes $3,5,\dots,97$.

---

## 3. The ceiling theorem for per-modulus predictors

**Lemma 3.0.** For each $N$, $\sum_i (y_{N,i} - \bar y_N) = 0$.

*Proof.* Expand: $\sum_i y_{N,i} - n\bar y_N = 0$. $\square$

**Theorem 3.1 (residual decomposition).** For every per-modulus predictor $f$,
$$\mathrm{RSS}(f) = \mathrm{SSW} + n\sum_{N}\bigl(\bar y_N - f(N)\bigr)^2 .$$

*Proof.* Write $y_{N,i} - f(N) = (y_{N,i} - \bar y_N) + (\bar y_N - f(N))$ and square. The cross term is $2(\bar y_N - f(N))\sum_i (y_{N,i}-\bar y_N)$, which vanishes by Lemma 3.0. The last term contributes $n(\bar y_N - f(N))^2$. Sum over $N$. $\square$

**Corollary 3.2 (no predictor beats the floor; equality case).** For every $f$, $\mathrm{SSW}\le \mathrm{RSS}(f)$, and $\mathrm{RSS}(f) = \mathrm{SSW}$ if and only if $f(N) = \bar y_N$ for all $N$.

*Proof.* The extra term in Theorem 3.1 is $n$ times a sum of squares. It vanishes if and only if every summand vanishes. $\square$

**Theorem 3.3 (ceiling).** For any $T > 0$ and any per-modulus predictor $f$,
$$R^2_T(f) \le 1 - \frac{\mathrm{SSW}}{T}.$$
Taking $T = \mathrm{SST}$, we call $1 - \mathrm{SSW}/\mathrm{SST}$ the *sampling ceiling*.

*Proof.* Divide Corollary 3.2 by $T$. $\square$

**Theorem 3.4 (headroom).** For any $T \neq 0$,
$$\Bigl(1 - \frac{\mathrm{SSW}}{T}\Bigr) - R^2_T(f) = \frac{n\sum_N(\bar y_N - f(N))^2}{T}.$$
So the only $R^2$ a richer per-modulus feature set can add on top of $f$ is the scaled distance from $f$ to the per-modulus means.

*Proof.* Substitute Theorem 3.1 into $R^2_T(f)$. $\square$

Taking $f$ constant equal to $c$ in Theorem 3.1 gives the classical **one-way ANOVA identity** $\mathrm{RSS}(c) = \mathrm{SSW} + n\sum_N(\bar y_N - c)^2$. With $c = \bar y$ this reads $\mathrm{SST} = \mathrm{SSW} + \mathrm{SSB}$, where $\mathrm{SSB} = n\,S_{\bar y\bar y}$. The ceiling is therefore $\mathrm{SSB}/\mathrm{SST}$.

**Theorem 3.5 (empirical binomial floor).** If every $y_{N,i}\in\{0,1\}$, then
$$\mathrm{SSW} = n\sum_N \bar y_N(1 - \bar y_N).$$

*Proof.* Since $y^2 = y$ for $y\in\{0,1\}$, we have $(y_{N,i} - \bar y_N)^2 = y_{N,i} - 2\bar y_N y_{N,i} + \bar y_N^2$. Summing over $i$ and using $\sum_i y_{N,i} = n\bar y_N$ gives $n\bar y_N - 2n\bar y_N^2 + n\bar y_N^2 = n\bar y_N(1-\bar y_N)$. $\square$

---

## 4. The binomial sampling floor

**Lemma 4.1 (Bernstein moments).** For every $n\in\mathbb N$ and $\theta\in\mathbb R$:
$$\sum_{k=0}^n b_{n,k}(\theta) = 1,\qquad \sum_{k=0}^n k\,b_{n,k}(\theta) = n\theta,\qquad \sum_{k=0}^n (n\theta - k)^2 b_{n,k}(\theta) = n\theta(1-\theta).$$

*Proof sketch.* The first is the binomial theorem applied to $(\theta + (1-\theta))^n$. The second follows from $k\binom nk = n\binom{n-1}{k-1}$. The third is the classical variance identity of the Bernstein basis, obtained by applying the second identity twice (once with $k(k-1)\binom nk = n(n-1)\binom{n-2}{k-2}$). These hold as polynomial identities, hence for every real $\theta$. $\square$

**Theorem 4.2 (bias–variance law for an observed rate).** For $n\ge1$ and all real $\theta, c$,
$$\sum_{k=0}^n\Bigl(\frac kn - c\Bigr)^2 b_{n,k}(\theta) = (\theta - c)^2 + \frac{\theta(1-\theta)}{n}.$$
Also $\sum_k \frac kn\, b_{n,k}(\theta) = \theta$, so the observed rate is unbiased.

*Proof.* Write $\frac kn - c = -\frac{n\theta - k}{n} + (\theta - c)$. Squaring gives $\frac{(n\theta-k)^2}{n^2} - \frac{2(\theta-c)(n\theta - k)}{n} + (\theta-c)^2$. Lemma 4.1 evaluates the three resulting sums as $\theta(1-\theta)/n$, $0$ and $(\theta-c)^2$. $\square$

**Theorem 4.3 (signal plus floor across a panel).** Suppose each modulus $N$ has true rate $\theta_N$, and its observed rate is $k_N/n$ with $k_N \sim \mathrm{Binomial}(n,\theta_N)$. Then for every common centre $c$,
$$\sum_N \mathbb E\Bigl[\Bigl(\frac{k_N}{n} - c\Bigr)^2\Bigr] = \sum_N(\theta_N - c)^2 + \frac1n\sum_N \theta_N(1-\theta_N).$$

*Proof.* Sum Theorem 4.2 over $N$. $\square$

The first term is the **systematic** part, which a perfect predictor of $N$ would remove. The second is the **sampling floor**, which no predictor of $N$ can remove. Since $\theta(1-\theta) = \tfrac14 - (\theta - \tfrac12)^2$, the floor per draw never exceeds $1/4$.

Writing $V$ for the systematic variance per modulus and $E$ for the mean of $\theta_N(1-\theta_N)$, Theorem 4.3 shows that the best attainable expected $R^2$ of per-modulus rates is $V/(V + E/n) = \mathrm{ceil}(V,E,n)$.

**Remark 4.4 (two levels of description).** Theorems 3.1–3.5 are exact, sample-by-sample statements about the full $|\mathcal I|\times n$ table. Theorem 4.3 is an exact statement in expectation about the per-modulus rates. The two agree in spirit: in both, the observed variance is the systematic variance plus a binomial floor of size $\theta(1-\theta)/n$ per modulus. In the experiment, $R^2$ and the ceiling are reported for per-modulus rates. The residual-to-floor ratio $\kappa$ compares the residual variance of those rates with the estimated binomial floor $\sum_N \bar y_N(1-\bar y_N)/n$.

---

## 5. The ceiling grows with the number of values per modulus

**Theorem 5.1.** Let $V>0$ and $E > 0$. Then:

1. $n\mapsto \mathrm{ceil}(V,E,n)$ is strictly increasing on $n\ge1$;
2. $\mathrm{ceil}(V,E,n) < 1$ for every $n \ge 1$;
3. $\mathrm{ceil}(V,E,n)\to1$ as $n\to\infty$.

*Proof.* $E/n$ is strictly decreasing and positive, so $V/(V+E/n)$ is strictly increasing and less than $1$. Since $E/n\to0$, continuity of division gives the limit $V/V = 1$. $\square$

*Consequence.* If $\mathrm{ceil}(V,E,60) = c_{60}$, then $V/E = c_{60}/(60(1-c_{60}))$, and the ceiling at any $n$ follows. For $c_{60} = 0.45$ the predicted ceilings are $0.62$ at $n = 120$, $0.77$ at $n = 240$ and $0.93$ at $n = 960$. For $c_{60} = 0.31$ they are $0.47$, $0.64$ and $0.88$. The headroom for richer features lies in larger $n$.

---

## 6. One feature: fraction of ceiling equals squared correlation

Fix a per-modulus feature $x$ and write $m = \bar y_\cdot$ for the vector of per-modulus means.

**Lemma 6.1 (least-squares decomposition).** For all $a, b\in\mathbb R$,
$$\sum_N\bigl(m(N) - a - b\,x(N)\bigr)^2 = S_{mm} - 2bS_{xm} + b^2S_{xx} + |\mathcal I|\bigl(\langle m\rangle - a - b\langle x\rangle\bigr)^2 .$$

*Proof.* Centre both $m$ and $x$ at their panel means. The cross terms involving the constant vanish because centred quantities sum to zero. $\square$

**Lemma 6.2 (completing the square).** If $S_{xx}>0$, then for all $a,b$,
$$\sum_N\bigl(m(N) - a - bx(N)\bigr)^2 \ge S_{mm} - \frac{S_{xm}^2}{S_{xx}},$$
with equality for the ordinary-least-squares coefficients $\hat b = S_{xm}/S_{xx}$ and $\hat a = \langle m\rangle - \hat b\langle x\rangle$.

*Proof.* $S_{mm} - 2bS_{xm} + b^2 S_{xx} = S_{mm} - S_{xm}^2/S_{xx} + (bS_{xx} - S_{xm})^2/S_{xx}$, and the last term together with the intercept term of Lemma 6.1 is nonnegative. Both vanish at $(\hat a,\hat b)$. $\square$

**Corollary 6.3 (Cauchy–Schwarz from least squares).** If $S_{xx} > 0$, then $S_{xm}^2 \le S_{xx}S_{mm}$. Hence $\rho^2(x,m)\le1$ whenever $S_{mm}>0$.

*Proof.* The left side of Lemma 6.2 is nonnegative, so $S_{mm} - S_{xm}^2/S_{xx} \ge 0$ at the minimum. $\square$

Combining Lemma 6.2 with Theorem 3.1: among all predictors $a + bx(N)$, the residual sum of squares is at least $\mathrm{SSW} + n(S_{mm} - S_{xm}^2/S_{xx})$, and OLS on the per-modulus means attains this bound.

**Theorem 6.4 (one-feature law).** Assume $S_{xx}>0$ and $S_{mm}>0$, and let $\hat f(N) = \hat a + \hat b\,x(N)$ be the OLS line. Then
$$R^2_{\mathrm{SST}}(\hat f) = \Bigl(1 - \frac{\mathrm{SSW}}{\mathrm{SST}}\Bigr)\cdot \rho^2(x,m).$$

*Proof.* By the ANOVA identity, $\mathrm{SST} = \mathrm{SSW} + nS_{mm} > 0$. By Theorem 3.1 and Lemma 6.2, $\mathrm{RSS}(\hat f) = \mathrm{SSW} + n(S_{mm} - S_{xm}^2/S_{xx})$. Therefore $1 - \mathrm{RSS}(\hat f)/\mathrm{SST} = nS_{xm}^2/(S_{xx}\,\mathrm{SST})$. The ceiling is $nS_{mm}/\mathrm{SST}$, and the quotient of the two is $S_{xm}^2/(S_{xx}S_{mm}) = \rho^2$. $\square$

*Interpretation.* "The one-feature predictor reaches $66\%$ of the ceiling" says exactly that the squared correlation between the feature and the per-modulus means is $0.66$. By Corollary 6.3 a single linear feature never exceeds the ceiling, consistent with Theorem 3.3. Finding the best single feature becomes a projection problem: choose $x$ to maximize its correlation with $m$.

---

## 7. Residual-to-floor ratio, fraction of ceiling, and a consistency audit

Let $T$ be a total variation, $F<T$ the sampling floor, and $R$ the residual of a predictor. Then $R^2 = 1 - R/T$ and the ceiling is $1 - F/T$.

**Theorem 7.1 (fraction-of-ceiling law).** If $T>0$, $F<T$ and $R = \kappa F$, then
$$\frac{1 - \kappa F/T}{1 - F/T} = 1 - \frac{(\kappa - 1)F}{T - F}.$$

*Proof.* Multiply the numerator and denominator by $T$ and simplify. $\square$

**Theorem 7.2 (captured share).** If $F<T$ and $R\le\kappa F$, the predictor captures at least the share $1 - (\kappa-1)F/(T-F)$ of the systematic variation $T - F$; that is, $(T - R)/(T - F) \ge 1 - (\kappa-1)F/(T-F)$.

*Proof.* The right side equals $(T - \kappa F)/(T-F)$, and $T - R\ge T - \kappa F$. $\square$

**Theorem 7.3 (residual-ratio identity).** On a common total $T$, with floor $W \ne 0$ and residual $R$,
$$1 - R^2 = \frac{R}{W}\,\bigl(1 - \mathrm{ceiling}\bigr).$$
In words: one minus $R^2$ equals $\kappa$ times one minus the ceiling.

*Proof.* Both sides equal $R/T$. $\square$

**Audit of the reported numbers.**

* $u = 3.5$: if $1 - 0.2246 = \kappa(1 - 0.31)$, then $\kappa = 0.7754/0.69 \in (1.12, 1.13)$, inside the reported band $1.12$–$1.24$. The triple is **consistent**.
* $u = 2.5$: if $1 - 0.2998 = \kappa(1 - c)$ with $0 \le \kappa \le 1.24$, then $1 - c \ge 0.7002/1.24 > 0.564$, so $c < 0.436$. A ceiling of $0.45$ is therefore **inconsistent** with the identity under a common sum of squares. Either the ceiling and the held-out $R^2$ refer to different sums of squares (for instance in-sample versus held-out), or $\kappa$ at $u = 2.5$ is nearer $(1-0.2998)/(1-0.45) \approx 1.27$.
* Fractions of the ceiling: $0.66 < 0.2998/0.45 < 0.67$ and $0.72 < 0.2246/0.31 < 0.73$.

---

## 8. The QR-count feature

Throughout, $p$ is an odd prime and $\chi_p$ is the quadratic character of $\mathbb Z/p\mathbb Z$ (the Legendre symbol), with $\chi_p(0) = 0$.

**Theorem 8.1 (Euler's test computes the Legendre symbol).** For every integer $N$, $N^{(p-1)/2}\equiv 1 \pmod p$ if and only if $\left(\frac Np\right) = 1$. Consequently $\mathrm{QR}_S(N)$ equals the number of $p\in S$ at which $N$ is a nonzero quadratic residue.

*Proof.* If $p\mid N$, the power is $0\ne1$ and the symbol is $0$. Otherwise this is Euler's criterion: $N^{(p-1)/2}\equiv\left(\frac Np\right)\pmod p$, and $1\not\equiv -1$ because $p$ is odd. $\square$

**Theorem 8.2 (multiplicativity).** $\left(\frac{PQ}{p}\right) = \left(\frac Pp\right)\left(\frac Qp\right)$ for all integers $P, Q$.

Write $\iota_p(a) = \mathbf 1[a^{(p-1)/2} = 1]$ for $a\in\mathbb Z/p\mathbb Z$. Then $\iota_p = (\chi_p + \chi_p^2)/2$.

**Theorem 8.3 (per-prime moments).** Put $\mu_p = (p-1)/(2p)$. Then
$$\sum_{a\in\mathbb Z/p}\iota_p(a) = \frac{p-1}{2},\qquad \frac1p\sum_a\iota_p(a) = \mu_p,\qquad \sum_a(\iota_p(a) - \mu_p) = 0,\qquad \sum_a(\iota_p(a) - \mu_p)^2 = \frac{p^2-1}{4p}.$$

*Proof.* $\sum_a\chi_p(a) = 0$ and $\sum_a\chi_p(a)^2 = p-1$. This gives the first identity, and the second and third follow. For the fourth, $\iota_p^2 = \iota_p$, so the sum equals $\frac{p-1}{2} - 2\mu_p\frac{p-1}{2} + p\mu_p^2 = \frac{p-1}{2}\cdot\frac{p+1}{2p}$. $\square$

In particular the per-prime test is **not** a fair coin: it passes with probability $\mu_p<\tfrac12$, because $0$ always fails.

**Theorem 8.4 (orthogonality under the Chinese Remainder Theorem).** Let $Z_1,\dots,Z_r$ be finite sets and $g_i : Z_i\to\mathbb R$ with $\sum_{a\in Z_i}g_i(a) = 0$ for every $i$. Then, summing over the full product $Z_1\times\dots\times Z_r$,
$$\sum_{z}\Bigl(\sum_i g_i(z_i)\Bigr)^2 = \sum_i \Bigl(\sum_{a\in Z_i} g_i(a)^2\Bigr)\prod_{k\ne i}|Z_k| .$$

*Proof.* Expand the square. A diagonal term $g_i(z_i)^2$ summed over the product gives $\sum_a g_i(a)^2$ times $\prod_{k\ne i}|Z_k|$, since a single coordinate of a uniformly enumerated product is uniform. A cross term $g_i(z_i)g_j(z_j)$ with $i\ne j$ factors as $\bigl(\sum_a g_i(a)\bigr)\bigl(\sum_b g_j(b)\bigr)\cdot\prod_{k\ne i,j}|Z_k| = 0$. $\square$

By the Chinese Remainder Theorem, as $N$ runs over a complete residue system modulo $M = \prod_i q_i$ (distinct odd primes $q_i$), the vector of residues $(N \bmod q_i)_i$ runs exactly once over $\prod_i\mathbb Z/q_i$.

**Corollary 8.5 (moments of the QR count).** Over a complete residue system modulo $M = \prod_{i} q_i$,
$$\frac1M\sum_N\mathrm{QR}(N) = \sum_i\frac{q_i-1}{2q_i},\qquad \frac1M\sum_N\Bigl(\mathrm{QR}(N) - \sum_i\mu_{q_i}\Bigr)^2 = \sum_i\frac{q_i^2-1}{4q_i^2}.$$
The variance is strictly less than $r/4$, the value for $r$ fair coins.

*Proof.* The mean follows from Theorem 8.3 by marginal uniformity. The variance follows from Theorem 8.4 applied to $g_i = \iota_{q_i} - \mu_{q_i}$, together with Theorem 8.3, after dividing by $M$. $\square$

For the $24$ odd primes up to $100$, the mean is $\approx 11.35$ and the standard deviation is $\approx 2.439$ (against $\sqrt6\approx2.449$ for fair coins). Orthogonality makes the count a natural one-dimensional summary of the 24 bits: under the uniform model the bits are pairwise uncorrelated, so their sum has no redundancy from correlation between primes.

---

## 9. Factor blindness of the residue dial

**Theorem 9.1 (exact balance).** Let $p$ be an odd prime and $n\in\mathbb Z/p\mathbb Z$ with $n\ne0$. Among the ordered factorizations $n = x\cdot y$ in $\mathbb Z/p\mathbb Z$, exactly $(p-1)/2$ have $x$ a square and exactly $(p-1)/2$ have $x$ a non-square.

*Proof.* Since $n\ne0$, every factorization has $x\ne0$, and $y = x^{-1}n$ is then determined. So factorizations correspond bijectively to nonzero $x$, with any predicate on $x$ carried along. Among the $p-1$ nonzero $x$, exactly $(p-1)/2$ are squares: by Euler's criterion they are the elements passing the Euler test, and Theorem 8.3 counts them. The remaining $(p-1)/2$ are non-squares. $\square$

*Interpretation (barrier).* The QR count is a function of the residues $N\bmod p$. Conditioned on any such residue, the residue character of a hidden factor is perfectly balanced. Combined with Theorem 8.2, the feature sees only the product $\chi_p(P)\chi_p(Q)$ for $N = PQ$. It therefore predicts the *input statistics of the sieve method* (how often values are smooth) while carrying zero information about the residue characters of the factors themselves. A strong smoothness predictor of this kind is not a step towards factoring.

---

## 10. Empirical results

**Design.** Panel of semiprime moduli; $n = 60$ sieve values per modulus; outcome is smoothness of $j^2 - N$; two difficulty levels $u\in\{2.5, 3.5\}$; fit and test on disjoint moduli; transfer test to 44-bit moduli without refitting; fixed random seed $20260827$.

| Setting | held-out $R^2$ | calibration slope | approx. ceiling ($n=60$) | fraction of ceiling | residual / floor |
|---|---|---|---|---|---|
| $u = 2.5$ | $0.2998$ | $1.003$ | $0.45$ | $66\%$ | $1.12$–$1.24$ |
| $u = 3.5$ | $0.2246$ | $0.896$ | $0.31$ | $73\%$ | $1.12$–$1.24$ |
| transfer, 44 bits, $u = 2.5$ | $0.23$ | $0.84$ | — | — | — |
| transfer, 44 bits, $u = 3.5$ | $0.17$ | $0.79$ | — | — | — |

**Pre-stated hypotheses.** H1 and H2 (bands on held-out $R^2$ and calibration) were formally **not met**: at $u = 3.5$ the results missed the stated bands by $0.025$ and $0.012$. We record this as stated. H3 (residual variance within a small factor of the pure 60-draw binomial floor) **held decisively**, with ratios $1.12$–$1.24$. By Theorems 3.4 and 7.2, essentially all systematic per-modulus structure that $60$ values can resolve is captured by the single feature.

**Ceiling analysis.** The maximal achievable $R^2$ at $60$ values per modulus is about $0.45$ at $u = 2.5$ and $0.31$ at $u = 3.5$. The one-feature predictor reaches $66\%$ and $73\%$ of these. By Theorem 6.4, these fractions are squared correlations between the QR count and the per-modulus rates. By Theorem 5.1, the remaining headroom calls for more values per modulus before more features.

---

## 11. Algorithms

**Algorithm A (QR-count feature).** Input $N$ and a list $S$ of odd primes. For each $p\in S$, compute $r = N^{(p-1)/2}\bmod p$ by fast exponentiation and increment a counter if $r = 1$. Cost: $O(|S|\log p)$ modular multiplications. For $S$ = the odd primes up to $100$, this is $24$ exponentiations with exponents below $49$.

**Algorithm B (ceiling audit for a per-modulus predictor).** Input a $0/1$ table $y_{N,i}$ and predictions $f(N)$.
1. Compute $\bar y_N$, the grand mean, $\mathrm{SST}$, and $\mathrm{SSW} = n\sum\bar y_N(1-\bar y_N)$.
2. Ceiling: $1 - \mathrm{SSW}/\mathrm{SST}$. Predictor $R^2$: $1 - \mathrm{RSS}(f)/\mathrm{SST}$, where $\mathrm{RSS}(f) = \mathrm{SSW} + n\sum(\bar y_N - f(N))^2$.
3. Report the fraction of the ceiling, $\kappa = \mathrm{RSS}/\mathrm{SSW}$, and the headroom $n\sum(\bar y_N - f(N))^2/\mathrm{SST}$.
4. Consistency check: $1 - R^2 = \kappa(1 - \text{ceiling})$.

Cost: $O(|\mathcal I|\,n)$.

**Algorithm C (one-feature fit).** Compute $S_{xx}$, $S_{xm}$ and $S_{mm}$ on the per-modulus means. Set $\hat b = S_{xm}/S_{xx}$ and $\hat a = \langle m\rangle - \hat b\langle x\rangle$. Then $R^2 = \text{ceiling}\cdot S_{xm}^2/(S_{xx}S_{mm})$. Cost: $O(|\mathcal I|)$ after the means are computed.

**Algorithm D (ceiling extrapolation).** From an estimated ceiling $c_{n_0}$ at $n_0$ values per modulus, set $V/E = c_{n_0}/(n_0(1-c_{n_0}))$ and predict $\mathrm{ceil}(n) = (V/E)/((V/E) + 1/n)$.

---

## 12. Discussion and applications

The framework applies wherever a per-unit rate is estimated from a few binary trials per unit: per-page conversion rates, per-batch defect rates, per-site response rates, and in computational number theory, per-modulus or per-polynomial yields of sieving methods. Three practical rules follow from the theorems.

1. **Judge against the ceiling.** A per-unit predictor cannot exceed $\mathrm{SSB}/\mathrm{SST}$ (Theorem 3.3). A raw $R^2$ of $0.3$ can be two-thirds of what is possible.
2. **Use the residual-to-floor ratio as a completeness test.** A ratio near $1$ means little systematic structure remains (Theorems 3.4 and 7.2).
3. **Scale trials before features.** The ceiling rises with $n$ (Theorem 5.1). A richer feature set cannot raise it.

In the quadratic-sieve setting, the QR count acts as a cheap *calibration dial*: it forecasts a modulus's smoothness yield from $24$ modular exponentiations. Theorem 9.1 limits its meaning, since such forecasts reveal nothing about the residue characters of the factors.

**Limitations.** The ceiling estimates ($0.45$, $0.31$) are empirical, and the audit in Section 7 indicates that at $u = 2.5$ the ceiling and the held-out $R^2$ were probably computed on different sums of squares. The moment computations of Section 8 refer to the uniform distribution over a period of the Chinese Remainder Theorem. Actual panels of semiprimes of a fixed size are only approximately uniform modulo small primes.

---

## 13. Future work

1. **Weighted QR count.** Replace the unit weights by $w_p\propto \log p/(p-1)$, the smoothness gain of a doubled root count. Conjecture: at $u = 2.5$ the fraction of the ceiling rises from about $0.66$ to at least $0.85$, still with one feature. Theorem 6.4 makes the fraction an exact squared correlation, and Theorem 8.4 makes the optimal projection onto the per-prime characters coordinate-wise.
2. **Ceiling growth law.** With $V$ and $E$ fitted at $n = 60$, test whether the measured ceiling at $n = 240$ matches $V/(V + E/240)$ (predicted $\approx0.77$ at $u = 2.5$) to within $0.02$.
3. **Factor-blind sufficiency.** For semiprimes $N = PQ$ of fixed size, conjecture that the per-modulus smoothness rate is, up to $O(n^{-1/2})$ noise, a function of the residue vector $(\chi_p(N))_{p\le B}$ alone. Then adding any factor statistic, such as $\chi_p(P)$, as a feature should add zero $R^2$, in line with Theorem 9.1.

---

## Appendix: notation

| Symbol | Meaning |
|---|---|
| $\mathcal I$, $n$ | panel of moduli; values per modulus |
| $y_{N,i}$, $\bar y_N$ | outcomes; per-modulus mean |
| $\mathrm{SSW}$, $\mathrm{SSB}$, $\mathrm{SST}$ | within, between and total sums of squares |
| $\mathrm{RSS}(f)$ | residual sum of squares of a predictor |
| $S_{uv}$, $\rho^2$ | centred cross-product; squared correlation |
| $V$, $E$ | systematic variance; mean per-draw binomial variance |
| $\kappa$ | residual-to-floor ratio |
| $\chi_p$, $\iota_p$, $\mu_p$ | quadratic character; Euler-test indicator; its mean $(p-1)/(2p)$ |
| $\mathrm{QR}(N)$ | number of odd primes $p\le100$ at which $N$ passes Euler's test |
