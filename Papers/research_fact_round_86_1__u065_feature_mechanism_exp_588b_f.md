# The Divisibility-Mixture Baseline for Quadratic Sieve Values

### Exact over-dispersion of $j^2 - N$, a convexity mechanism for smoothness excess, and an amplitude-to-spread calibration for Dickman humps

**Author:** Aristotle
**Date:** 2026-08-26

---

## Abstract

In Fermat- and quadratic-sieve-style factoring one tests the values $v = j^2 - N$ for $B$-smoothness while $j$ ranges over a window and the modulus $N$ is fixed. The standard baseline models $v$ as a random integer of its size, so that a small prime $p$ divides $v$ with density $1/p$ and the smoothness probability is the Dickman value $\rho(\log v / \log B)$. A large computational experiment (9,594 smooth hits, 512,000 controls, 128 moduli of 96 bits) fitted an *exact* Dickman baseline and found a residual hump of log-amplitude $A = 0.1163 \pm 0.0360$ ($z = 3.23$) over the rescaled range $t \in [0.45, 0.85]$, against a null paired-random control of $0.0269 \pm 0.0109$. Attempts to attribute the hump to any single binary covariate — parity, divisibility by $3$, $5$, or $7$, small-prime-factor-count terciles — removed $0\%$ of the amplitude in every case.

This paper supplies the arithmetic explanation and shows that both findings are forced. We prove: (i) **mean preservation at every modulus**, $\sum_{N \bmod m} \#\{ j : m \mid j^2 - N \} = m$, so the naive rate $1/m$ is exactly the average of the true per-$N$ rate; (ii) an **exact over-dispersion identity** for odd primes, $\sum_N (X_p(N) - 1)^2 = p - 1$, together with the exact functional identity $\sum_N g(X_p(N)) = g(1) + \tfrac{p-1}{2}(g(2) + g(0))$, whose specialisation $\sum_N c^{X_p(N)} = pc + \tfrac{(p-1)(c-1)^2}{2}$ exhibits the excess as *quadratic* in $c - 1$, i.e. a pure variance effect; (iii) a **convexity mechanism** — for every convex functional $G$ and every modulus $m$, $m\,G(1) \le \sum_N G(X_m(N))$, strictly for $m \ge 3$ and strictly convex $G$, with primality nowhere used; (iv) a **no-single-carrier theorem** — each prime's share of the total log-amplitude is at most $3/(2k)$ in a $k$-prime mixture, so with $k \ge 3$ no single covariate can reach the registered $60\%$ removal bar, and with $k \ge 5$ none reaches $30\%$; (v) an **amplitude–spread dictionary** — a symmetric two-point mixture of the Dickman argument with spread $\delta$ produces a hump of exactly $\tfrac12\log\!\big(1 + \delta^2/(4u(u-\delta))\big)$, an expression strictly increasing in $\delta$ and invertible in closed form, so that a measured amplitude identifies the mixture spread scale-freely; and (vi) an **amplitude tomography** bracket $A/X \le k \le \tfrac32 A/\log(1+X)$ on the number of participating primes. The conclusion is a replacement baseline: a divisibility mixture over residue classes of $N$ modulo the small primes, rather than a pointwise Dickman value corrected by per-hit binary covariates.

---

## 1. Introduction

### 1.1 The sieve setting

Let $N$ be a large odd composite to be factored and let $B$ be a smoothness bound. In the Fermat/quadratic sieve family one scans $j$ over a window near $\sqrt{N}$ and records the sieve values

$$v(j) = j^2 - N,$$

retaining those $v$ all of whose prime factors are at most $B$ (the *$B$-smooth* values). Enough smooth values yield, by linear algebra over $\mathbb{F}_2$ on their exponent vectors, a congruence $x^2 \equiv y^2 \pmod N$ and hence, generically, a nontrivial factor. The asymptotic complexity of the whole family is governed by the *yield rate*: the proportion of scanned $j$ for which $v(j)$ is smooth.

### 1.2 The naive baseline and the Dickman function

The classical heuristic treats $v(j)$ as a random integer of size $|v|$. For random integers the smoothness density is governed by the Dickman function.

> **Definition 1 (Dickman function).** $\rho : [0,\infty) \to (0,1]$ is the unique continuous function with $\rho(u) = 1$ on $[0,1]$ satisfying the delay differential equation
> $$u\,\rho'(u) = -\rho(u-1), \qquad u > 1.$$
> The proportion of integers up to $x$ that are $x^{1/u}$-smooth tends to $\rho(u)$.

On the first nontrivial branch the equation solves in closed form.

> **Definition 2 (first Dickman branch).** For $u > 0$ put $\rho_1(u) = 1 - \log u$. On $[1,2]$, $\rho_1 = \rho$.

**Proposition 1 (branch verification).** $\rho_1$ is differentiable on $(0,\infty)$ with $\rho_1'(u) = -1/u$; consequently $u\,\rho_1'(u) = -1 = -\rho(u-1)$ for $1 \le u \le 2$, since $\rho \equiv 1$ on $[0,1]$. Thus $\rho_1$ satisfies the delay equation on the first branch.

*Proof.* Differentiate $1 - \log u$. Multiplying by $u$ gives $-1$; and $u - 1 \in [0,1]$ for $u \in [1,2]$, where $\rho \equiv 1$. $\square$

**Proposition 2 (convexity).** $\rho_1$ is convex on $(0,\infty)$.

*Proof.* $\log$ is strictly concave on $(0,\infty)$, hence $-\log$ is convex, and adding the constant $1$ preserves convexity. $\square$

Proposition 2 is the analytic engine of everything below: it is what makes an *average of Dickman values* exceed the *Dickman value at the average argument*.

### 1.3 The measurement

Fitting the exact Dickman curve $\rho(\log v/\log B)$ (with $\log B = \log 10^6$) to the observed smoothness rate of $j^2 - N$, with the normalisation flank-fitted rather than grid-fitted, leaves a residual hump of log-amplitude

$$A = 0.1163 \pm 0.0360 \quad (z = 3.23)$$

over $t \in [0.45, 0.85]$. A paired-random control — the same estimator applied to random integers of matched size, with no $j^2 - N$ structure — returns $0.0269 \pm 0.0109$, consistent with zero. The population comprised $9{,}594$ smooth hits and $512{,}000$ controls across $128$ moduli $N$ of bit-length $96$.

The pre-registered mechanism probe then attempted to attribute the hump to a single per-hit binary covariate, with a win condition of "removes $\ge 60\%$ of the amplitude and leaves all strata at $|z| < 2$". Table 1 records the outcome.

**Table 1. Single-covariate removal.**

| Candidate covariate | Stratum $z$-scores | Amplitude removed |
|---|---|---|
| $2 \mid v$ (parity) | 3.51 / 4.16 | 0% |
| $3 \mid v$ | 4.36 / 2.38 | 0% |
| $5 \mid v$ | 4.56 / 1.84 | 0% |
| $7 \mid v$ | 3.91 / 2.44 | 0% |
| small-prime-count terciles | 4.14 / 2.49 / 4.19 | 0% |
| $\gcd(j,N) > 1$ | — (stratum structurally empty at 96 bits) | not testable |

Divisibility conditioning nevertheless absorbed $45$–$60\%$ of the yes-stratum point amplitude, while parity and the factor-count statistic absorbed none. The reading: the excess is *arithmetic-internal and divisibility-distributed*.

### 1.4 Contribution

We show that the naive baseline is mis-specified in a precise and correctable way, that the correction is a **divisibility mixture**, and that the mixture's structure *forces* both the sign of the hump and the failure of every single-covariate removal. We then invert the amplitude into a mixture spread in closed form.

---

## 2. The root-count random variable

> **Definition 3 (root count).** For a modulus $m \ge 1$ and a target $a \in \mathbb{Z}/m$, set
> $$X_m(a) \;=\; \#\{\, x \in \mathbb{Z}/m \;:\; x^2 = a \,\} \;=\; \#\{\, j \bmod m \;:\; m \mid j^2 - a \,\}.$$

$X_m(N)/m$ is the exact density with which $m$ divides the sieve values $v(j) = j^2 - N$ as $j$ runs over a full residue window. The naive baseline uses the constant $1/m$ in its place.

### 2.1 Mean preservation at every modulus

**Theorem 1 (mean preservation).** For every modulus $m \ge 1$,
$$\sum_{a \in \mathbb{Z}/m} X_m(a) \;=\; m.$$
Equivalently, the average of the true per-$N$ divisibility rate $X_m(N)/m$ over $N$ is exactly the naive rate $1/m$.

*Proof.* Count the fibres of the squaring map $x \mapsto x^2$ on $\mathbb{Z}/m$. The domain has $m$ elements; each element lies in exactly one fibre; and $X_m(a)$ is the cardinality of the fibre over $a$. Summing fibre cardinalities recovers the domain. $\square$

No primality, no reciprocity: pure counting. This is the reason the naive baseline is *unbiased on average* and yet wrong for every individual $N$.

**Theorem 2 (non-degeneracy).** For $m \ge 3$ there exists $a \in \mathbb{Z}/m$ with $X_m(a) = 0$, and there exists $a$ with $X_m(a) \ge 2$.

*Proof sketch.* The squaring map identifies $x$ with $-x$, and for $m \ge 3$ there is some $x$ with $x \ne -x$, so the image of the squaring map is a proper subset of $\mathbb{Z}/m$; any target outside the image has $X_m = 0$. Since the total is $m$ by Theorem 1 and some value is $0$, some value must be $\ge 2$. $\square$

Together, Theorems 1 and 2 say the root-count distribution has mean exactly $1$ and is never a point mass once $m \ge 3$.

### 2.2 The prime case: exact two-point mixture

Let $p$ be an odd prime and $\chi_p$ the quadratic character (Legendre symbol) on $\mathbb{Z}/p$.

**Theorem 3 (character formula).** For every $a \in \mathbb{Z}/p$, $X_p(a) = \chi_p(a) + 1$. Hence
$$X_p(a) = \begin{cases} 2, & a \text{ a nonzero square,} \\ 0, & a \text{ a non-residue,} \\ 1, & a = 0. \end{cases}$$

*Proof.* Standard: the fibre of $x \mapsto x^2$ over a nonzero square has two elements $\pm x_0$ (distinct as $p$ is odd), over a non-residue none, and over $0$ exactly one. $\square$

**Corollary 1 (mean).** $\sum_{a} X_p(a) = p$, since $\sum_a \chi_p(a) = 0$.

**Theorem 4 (exact over-dispersion).** For every odd prime $p$,
$$\sum_{a \in \mathbb{Z}/p} \big(X_p(a) - 1\big)^2 \;=\; p - 1.$$

*Proof.* By Theorem 3 the summand is $\chi_p(a)^2$, which equals $1$ for $a \ne 0$ and $0$ for $a = 0$. There are $p-1$ nonzero targets. $\square$

Interpretation: for a mean-one count supported in $\{0,1,2\}$, the value $p-1$ out of a maximum of $p$ is the extreme of over-dispersion — all but one target sit at the endpoints $0$ or $2$.

**Theorem 5 (exact functional identity).** For every function $g : \mathbb{N} \to \mathbb{R}$ and every odd prime $p$,
$$\sum_{a \in \mathbb{Z}/p} g\big(X_p(a)\big) \;=\; g(1) \;+\; \frac{p-1}{2}\Big(g(2) + g(0)\Big).$$

*Proof.* Split off $a = 0$, which contributes $g(1)$. On the punctured set write $g(X_p(a)) = \tfrac{g(2)+g(0)}{2} + \chi_p(a)\cdot\tfrac{g(2)-g(0)}{2}$, which is correct at both values of $\chi_p$; sum, and use $\sum_{a \ne 0}\chi_p(a) = 0$ and $\#\{a \ne 0\} = p-1$. $\square$

Theorem 5 is a complete description: *every* statistic of the root-count distribution is determined by the three numbers $g(0), g(1), g(2)$ and the residue split.

---

## 3. The convexity mechanism

### 3.1 Jensen at every modulus

Smoothness is multiplicative in the prime divisibility structure, so its natural proxies are convex functionals of the divisibility counts.

**Theorem 6 (mixture excess, arbitrary modulus, arbitrary convex functional).** For every modulus $m \ge 1$ and every convex $G : \mathbb{R} \to \mathbb{R}$,
$$m\,G(1) \;\le\; \sum_{a \in \mathbb{Z}/m} G\big(X_m(a)\big).$$

*Proof.* Apply Jensen's inequality to the uniform measure on $\mathbb{Z}/m$: $G\big(\tfrac1m\sum_a X_m(a)\big) \le \tfrac1m\sum_a G(X_m(a))$. By Theorem 1 the argument on the left equals $1$. Multiply by $m$. $\square$

The left-hand side is *exactly* the naive baseline — the functional evaluated as if every $N$ had the mean rate. Thus the truth always sits above the baseline, at every modulus, for every convex smoothness proxy.

**Theorem 7 (strictness).** For every $m \ge 3$ and every strictly convex $G$,
$$m\,G(1) \;<\; \sum_{a \in \mathbb{Z}/m} G\big(X_m(a)\big).$$

*Proof sketch.* Let $L$ be a supporting line of $G$ at the point $1$: $G(x) \ge L(x)$ for all $x$, with equality only at $x = 1$ by strict convexity. Summing $L$ over $a$ reproduces $m\,G(1)$ exactly, because $L$ is affine and $\sum_a X_m(a) = m$ (Theorem 1). By Theorem 2 some target has $X_m \ne 1$, at which the inequality $G > L$ is strict; hence the summed inequality is strict. $\square$

Primality is nowhere used. **Mean preservation plus non-constancy is the entire mechanism**; quadratic reciprocity only fixes the *size* of the effect.

### 3.2 The multiplicative proxy: exact size of the excess

Fix a per-hit weight $c > 0$ and take the proxy $g(x) = c^x$ — the natural multiplicative model in which each divisibility hit multiplies the smoothness odds by $c$.

**Theorem 8 (generating identity).** For every odd prime $p$ and every real $c$,
$$\sum_{a \in \mathbb{Z}/p} c^{\,X_p(a)} \;=\; \underbrace{p\,c}_{\text{naive baseline}} \;+\; \underbrace{\frac{(p-1)(c-1)^2}{2}}_{\text{mixture excess}}.$$

*Proof.* Theorem 5 with $g(x) = c^x$ gives $c + \tfrac{p-1}{2}(c^2 + 1)$; rearrange using $c^2 + 1 = (c-1)^2 + 2c$. $\square$

The excess is *quadratic in $c-1$*: a second-order, variance-type effect, exactly as mean preservation demands. There is no first-order shift.

> **Definition 4 (excess ratio).** For an odd prime $q$ and $c > 0$,
> $$E_q(c) \;=\; \frac{\sum_{a} c^{\,X_q(a)}}{q\,c}.$$

**Theorem 9 (closed form and strictness).** For an odd prime $q$ and $c > 0$,
$$E_q(c) \;=\; 1 + \Big(1 - \tfrac1q\Big)\,X, \qquad X \;=\; \frac{(c-1)^2}{2c},$$
and $E_q(c) > 1$ whenever $c \ne 1$.

*Proof.* Divide Theorem 8 by $qc$ and simplify. Positivity of $X$ for $c \ne 1$ gives strictness. $\square$

**Theorem 10 (independence / product law).** For distinct odd primes $q_1, \dots, q_k$ and weights $c_1, \dots, c_k > 0$, summing the product proxy over the product of residue systems — isomorphic to $\mathbb{Z}/(q_1\cdots q_k)$ by the Chinese remainder theorem — factorises:
$$\sum_{N} \prod_{i} c_i^{\,X_{q_i}(N_i)} \;=\; \prod_i \sum_{a} c_i^{\,X_{q_i}(a)}.$$
Consequently, if every $c_i \ne 1$, $\prod_i (q_i c_i) < \sum_N \prod_i c_i^{X_{q_i}(N_i)}$: the multi-prime mixture strictly exceeds the multi-prime naive baseline.

*Proof.* Expansion of a product of sums; then apply Theorem 9 factor by factor. $\square$

---

## 4. No single carrier

> **Definition 5 (hump log-amplitude).** For a mixture model over odd primes $q_1,\dots,q_k$ with common weight $c$,
> $$A \;=\; \sum_{i=1}^k \ell_i, \qquad \ell_i \;=\; \log E_{q_i}(c) \;=\; \log\!\Big(1 + \big(1 - \tfrac{1}{q_i}\big) X\Big), \quad X = \frac{(c-1)^2}{2c}.$$

The essential observation is that the *shape factor* $X$ is common to all primes; the only prime-dependence is the bounded factor $1 - 1/q \in [2/3, 1)$.

**Lemma 1 (concavity squeeze).** For $Y \ge 0$ and $\theta \in [0,1]$, $\;\theta\log(1+Y) \le \log(1 + \theta Y)$.

*Proof.* $\log$ is concave; apply the definition of concavity to the points $1$ and $1+Y$ with weights $1-\theta$ and $\theta$, noting $\log 1 = 0$ and $(1-\theta)\cdot 1 + \theta(1+Y) = 1 + \theta Y$. $\square$

**Theorem 11 (two-sided per-prime squeeze).** For every odd prime $q$ and $c > 0$, with $L = \log(1+X)$,
$$\tfrac{2}{3} L \;\le\; \ell_q \;\le\; L.$$

*Proof.* Upper bound: $1 - 1/q < 1$ and $\log$ is increasing. Lower bound: $1 - 1/q \ge 2/3$ for $q \ge 3$, so $\ell_q \ge \log(1 + \tfrac23 X) \ge \tfrac23\log(1+X)$ by Lemma 1. $\square$

A finer, non-asymptotic sandwich is also available: with $Y_q = (1 - 1/q)X$,
$$\frac{Y_q}{1 + Y_q} \;\le\; \ell_q \;\le\; Y_q,$$
pinning each prime's contribution to its variance term up to a factor $1 + Y_q$.

**Theorem 12 (no single carrier).** In a mixture over $k$ odd primes, each prime's share of the total amplitude obeys
$$\frac{\ell_j}{A} \;\le\; \frac{3}{2k}.$$
Consequently: if $k \ge 3$, no single prime accounts for more than $50\%$ of the amplitude — strictly below the registered $60\%$ removal bar; if $k \ge 5$, no single prime accounts for more than $30\%$.

*Proof.* By Theorem 11, $A = \sum_i \ell_i \ge k \cdot \tfrac23 L$ and $\ell_j \le L$. Hence $\ell_j \le L \le \tfrac{3}{2k}\,A$. Substituting $k = 3$ and $k = 5$ gives $1/2$ and $3/10$. $\square$

**Corollary 2 (residual hump).** Let $R_j = A - \ell_j$ be the amplitude surviving the removal of the single covariate "$q_j \mid v$". For $k \ge 3$,
$$R_j \;\ge\; \tfrac12 A \;>\; 0.$$
The residual is still a genuine hump: strictly positive, and (by Section 5) realised by a strictly positive admissible Dickman spread.

This is the formal content of the experimental `removal = 0%` table. The result is *structural*, not statistical: no amount of data can make a single per-hit binary covariate carry more than $3/(2k)$ of a divisibility-mixture hump. The per-hit binary covariate family is therefore removed from the search space, and the correct modelling target is the mixture itself.

### 4.1 Amplitude tomography

Reading Theorem 11 in the other direction turns the amplitude into a counting instrument.

**Theorem 13 (carrier-count bracket).** For a $k$-prime mixture with weight $c \ne 1$, with $X = (c-1)^2/(2c)$,
$$\frac{A}{X} \;\le\; k \;\le\; \frac{3}{2}\cdot\frac{A}{\log(1+X)}.$$

*Proof.* Upper bound on $A$: $\ell_i \le \log(1 + X) \le X$, so $A \le kX$, giving the left inequality. Lower bound on $A$: $\ell_i \ge \tfrac23\log(1+X)$, so $A \ge \tfrac{2k}{3}\log(1+X)$, giving the right inequality. $\square$

The bracket is tight up to the factor $\tfrac32 X/\log(1+X)$, which tends to $\tfrac32$ as $X \to 0$: a measured amplitude determines the number of participating primes to within a factor of about $3/2$ in the small-$X$ regime.

---

## 5. From amplitude to spread: the Dickman dictionary

The mixture picture says that the effective Dickman argument $u = \log v/\log B$ is not a single number per hit but a small distribution: values of $v$ that inherit extra small prime factors behave as though their argument were slightly reduced. Fitting an exact Dickman baseline to such a population — i.e. evaluating $\rho$ at the *mean* argument — necessarily under-predicts, by Proposition 2. We now compute that gap exactly for the simplest nontrivial mixture.

> **Definition 6 (two-point hump amplitude).** For $u > 0$ and spread $\delta$ with $u - \delta > 0$,
> $$H(u,\delta) \;=\; \frac{\rho_1(u) + \rho_1(u-\delta)}{2} \;-\; \rho_1\!\Big(u - \frac{\delta}{2}\Big),$$
> the excess of the symmetric two-point mixture average over the baseline at the mean argument.

**Theorem 14 (closed form).** For $u > 0$ and $0 < u - \delta$,
$$H(u,\delta) \;=\; \frac{1}{2}\,\log\!\left(1 + \frac{\delta^2}{4\,u\,(u-\delta)}\right).$$

*Proof.* With $\rho_1(x) = 1 - \log x$ the three constant terms cancel and
$$H(u,\delta) = \log\Big(u - \tfrac{\delta}{2}\Big) - \tfrac12\log u - \tfrac12\log(u-\delta) = \tfrac12\log\frac{(u-\delta/2)^2}{u(u-\delta)}.$$
The algebraic identity $(u - \delta/2)^2 = u(u-\delta) + \delta^2/4$ turns the ratio into $1 + \delta^2/(4u(u-\delta))$. $\square$

**Theorem 15 (faithfulness and positivity).** $H(u,0) = 0$; and $H(u,\delta) > 0$ whenever $\delta \ne 0$ and $0 < u - \delta$.

*Proof.* Immediate from Theorem 14: the logarithm's argument is $1$ when $\delta = 0$ and exceeds $1$ otherwise, since $\delta^2 > 0$ and $4u(u-\delta) > 0$. $\square$

**Theorem 16 (strict monotonicity in the spread).** For fixed $u > 0$, the map $\delta \mapsto H(u,\delta)$ is strictly increasing on $[0, u)$.

*Proof.* By Theorem 14 it suffices that $\delta \mapsto \delta^2/(4u(u-\delta))$ is strictly increasing on $[0,u)$. For $0 \le a < b < u$, cross-multiplying gives the difference
$$b^2\,4u(u-a) - a^2\,4u(u-b) = 4u\,(b-a)\big(u(a+b) - ab\big),$$
and $u(a+b) - ab > 0$ because $u > a \ge 0$ and $b > 0$ give $ub > ab$, while $ua \ge 0$. Hence the difference is positive. $\square$

Monotonicity makes the amplitude an unambiguous readout of the spread. It is, moreover, invertible in closed form.

> **Definition 7 (calibrated spread).** For $u > 0$ and $A > 0$, put $s = e^{2A} - 1$ and
> $$\delta(u, A) \;=\; 2u\left(\sqrt{s^2 + s} \; - \; s\right).$$

**Theorem 17 (admissibility).** For every $u > 0$ and $A > 0$, $\;0 < \delta(u,A) < u$.

*Proof.* Since $A > 0$, $s > 0$; then $s^2 + s > s^2$ gives $\sqrt{s^2+s} > s$, so $\delta > 0$. For the upper bound, $\sqrt{s^2+s} < s + \tfrac12$ because $(s+\tfrac12)^2 = s^2 + s + \tfrac14 > s^2 + s$; hence $\delta < 2u \cdot \tfrac12 = u$. $\square$

**Theorem 18 (exact calibration).** For every $u > 0$ and $A > 0$,
$$H\big(u,\;\delta(u,A)\big) \;=\; A.$$

*Proof.* Write $t = \sqrt{s^2+s} - s$, so $\delta = 2ut$ and $t$ satisfies the quadratic identity $t^2 + 2st - s = 0$, i.e. $t^2 = s(1 - 2t)$. By Theorem 17, $1 - 2t > 0$. Then
$$\frac{\delta^2}{4u(u-\delta)} = \frac{4u^2t^2}{4u\cdot u(1-2t)} = \frac{t^2}{1-2t} = s = e^{2A} - 1,$$
so the argument of the logarithm in Theorem 14 is $e^{2A}$, and $H = \tfrac12 \cdot 2A = A$. $\square$

**Theorem 19 (scale freedom).** $\delta(u,A) = u\cdot\delta(1,A)$: the relative spread $\delta/u$ depends only on the measured amplitude, not on the size regime.

*Proof.* Immediate from Definition 7, in which $u$ appears only as an overall factor. $\square$

### 5.1 Synthesis: the mixture *is* the hump

**Theorem 20 (mixture–hump identification).** Let $A = \sum_i \log E_{q_i}(c) > 0$ be the log-amplitude generated by a nonempty quadratic-residue divisibility mixture over odd primes with weight $c \ne 1$, and let $u > 0$. Then $\delta(u,A) \in (0,u)$ and $H(u,\delta(u,A)) = A$.

*Proof.* $A > 0$ by Theorem 9 (each factor exceeds $1$). Apply Theorems 17 and 18. $\square$

So "a hump over an exact Dickman baseline" and "a divisibility-mixture baseline" are two descriptions of one object, related by an explicit, invertible dictionary.

**Theorem 21 (monotone comparability).** For $u > 0$ and $0 < A < B$, $\;\delta(u,A) < \delta(u,B)$.

*Proof.* Both spreads lie in $[0,u)$ by Theorem 17; if $\delta(u,A) \ge \delta(u,B)$ then Theorem 16 (or equality) would give $A \ge B$ via Theorem 18, a contradiction. $\square$

**Theorem 22 (residual hump is a hump).** With $k \ge 3$ primes, for any $j$ the residual amplitude $R_j = A - \ell_j$ satisfies $R_j \ge \tfrac12 A > 0$, its calibrated spread $\delta(u, R_j)$ is admissible, and $H(u,\delta(u,R_j)) = R_j$. Moreover $\delta(u, \tfrac12 A) \le \delta(u, R_j)$.

*Proof.* Combine Corollary 2 with Theorems 17, 18 and 21. $\square$

---

## 6. Numerical illustration

Take the multiplicative weight $c = 3/2$, meaning each divisibility hit multiplies the smoothness odds by $1.5$, so $X = (c-1)^2/(2c) = 1/12 \approx 0.08333$.

* For $p = 7$: $\sum_{a} c^{X_7(a)} = 7c + 3(c-1)^2 = 10.5 + 0.75 = 11.25$, matching brute-force enumeration of the root counts $(1,2,2,0,2,0,0)$: $c + 3c^2 + 3 = 1.5 + 6.75 + 3 = 11.25$. The excess ratio is $E_7(3/2) = 11.25/10.5 = 15/14 \approx 1.0714$, and $\log E_7 \approx 0.06899$.
* For $p = 13$: $\sum_a c^{X_{13}(a)} = 13c + 6(c-1)^2 = 19.5 + 1.5 = 21$ exactly.
* Over-dispersion: $\sum_a (X_{11}(a)-1)^2 = 10 = 11 - 1$, confirmed by enumeration.

Taking the mixture over the odd primes $3,5,7,11,13$ at $c = 3/2$ gives
$$A = \sum_{q} \log\!\Big(1 + (1-\tfrac1q)\tfrac{1}{12}\Big) \approx 0.0540 + 0.0645 + 0.0690 + 0.0730 + 0.0740 \approx 0.3345,$$
and each prime's share ranges only from $16.1\%$ to $22.1\%$ — comfortably inside the guaranteed ceiling $3/(2\cdot 5) = 30\%$, and far below the $60\%$ bar. The tomography bracket at these values reads $A/X \approx 4.01 \le k = 5 \le \tfrac32 A / \log(1+X) \approx 6.27$, correctly bracketing the true prime count.

Finally, calibrate the *measured* amplitude $A = 0.1163$ at $u = 2$: $s = e^{0.2326} - 1 \approx 0.26187$, $\sqrt{s^2+s} \approx 0.57485$, and
$$\delta \approx 2\cdot 2\cdot(0.57485 - 0.26187) \approx 1.2519, \qquad \delta/u \approx 0.626.$$
Substituting back reproduces $H(2, 1.2519) = 0.1163$ to machine precision, and the relative spread $0.626$ is the same at every $u$ by Theorem 19.

---

## 7. Algorithms

Three computational procedures are implicit in the results.

**(A) Exact mixture baseline.** Rather than predicting the yield of a sieve by $\rho(\log v/\log B)$, compute, for the actual modulus $N$, the true small-prime densities $X_q(N)/q$ for all $q \le Q$, and use the resulting mixture as the baseline. Complexity: one Legendre-symbol evaluation per small prime, $O(\pi(Q)\log N)$ overall — negligible next to any sieve.

**(B) Amplitude calibration.** Given a fitted amplitude $A$ and a reference argument $u$, return $\delta(u,A)$ from Definition 7. Constant time, exact by Theorem 18, scale-free by Theorem 19.

**(C) Carrier-count tomography.** Given $A$ and the weight $c$, return the bracket of Theorem 13. Constant time; the returned interval provably contains the number of participating primes under the mixture model.

---

## 8. Discussion

### 8.1 What was mis-specified

The naive baseline is not wrong about the *average* behaviour — Theorem 1 shows it is exactly right there. It is wrong about the *conditional* behaviour: for a fixed $N$, every small prime has already made a binary decision (residue vs. non-residue) that fixes its divisibility density at $2/q$ or $0$, never $1/q$. Averaging over $N$ hides this; sieving a single $N$ exposes it. Since the smoothness functional is convex in the densities, the concealed structure always pushes the yield *up*. The direction of the observed hump is therefore not merely consistent with the arithmetic; it is compelled by it.

### 8.2 Why the negative result is the strong one

A common failure mode in large computational experiments is to keep testing binary features until one appears to explain an anomaly. Theorem 12 forecloses that search analytically: no per-hit binary covariate can remove more than $3/(2k)$ of a $k$-prime mixture hump, so with even a handful of small primes the registered $60\%$ bar is unreachable *by construction*. The experiment's uniform $0\%$ removal table is thus a confirmation of the mechanism rather than a null finding — and the correct next model is a mixture over $v \bmod q$ for small $q$, not a covariate-augmented pointwise baseline.

The empirical observation that divisibility conditioning absorbed $45$–$60\%$ of the yes-stratum point amplitude, while parity and factor-count statistics absorbed none, fits this picture precisely: conditioning on $q \mid v$ partially freezes one factor of the product in Theorem 10, removing that factor's share $\ell_q$ — bounded by Theorem 12 — while parity and coarse factor counts do not align with any single factor at all.

### 8.3 Scope and caveats

The identification in Theorem 20 is a *model* identification: it assumes the effective Dickman argument is well approximated by a two-point mixture, and it prices the hump on the first Dickman branch, where $\rho(u) = 1 - \log u$. Extending the closed form past $u = 2$ requires the higher branches, which are no longer elementary; the qualitative statements (positivity, monotonicity in the spread) persist by convexity of $\rho$ throughout, but the exact inversion of Definition 7 is branch-specific. Similarly, the shared-factor covariate could not be tested in the reported experiment because at $96$ bits the prime factors of $N$ vastly exceed the sieve window, making that stratum structurally empty rather than merely quiet; and a factor-count statistic capped at $100$ ignores prime factors above $100$ by definition.

### 8.4 Robustness of the mechanism

Only two properties of $j^2 - N$ were used: the root count has mean $1$ over the targets, and it is not constant. Both are stable under substantial generalisation. Replacing $j^2$ by an arbitrary sieve polynomial $f(j)$ leaves the fibre-counting proof of Theorem 1 untouched — the sum of fibre sizes of $f$ over $\mathbb{Z}/m$ is $m$ regardless of $f$ — so the convexity excess of Theorems 6 and 7 persists verbatim; only the *size* of the excess, controlled by the splitting behaviour of $f$ modulo $q$, changes. Likewise, prime-power and composite moduli are already covered by Theorems 1, 6 and 7; only the exact quantitative Theorems 3–5, 8, 9 use the residue dichotomy.

---

## 9. Future work

1. **Prime-power and composite carriers.** Mean preservation holds at every modulus, so only the *shape* of the root-count distribution distinguishes moduli. For $m = p^k$ that shape is governed by Hensel lifting and stratification by the $p$-adic valuation of the target. The general inequality is settled; what remains is the exact size of the effect, a finite and tractable computation.

2. **Higher-degree sieve polynomials.** For a general sieve polynomial $f(j) - N$, the mean-preservation argument transfers verbatim; the shape of the excess should then be governed by the splitting behaviour of $f$ modulo $q$ — a Galois-theoretic invariant rather than quadratic reciprocity. The variance identity and the stratum sizes need the degree-$d$ analogue.

3. **Weighted mixtures and per-prime weights.** The present model gives every prime the same weight $c$. A realistic smoothness proxy weights $q$ by something like $\log q / \log B$; the per-prime squeeze of Theorem 11 must then be replaced by a weighted version, and the $3/(2k)$ ceiling by a weighted share bound.

4. **Beyond the first Dickman branch.** Extend the closed-form hump and its inversion to $u > 2$, where $\rho$ has no elementary expression; convexity guarantees the qualitative statements survive, but a usable calibration needs quantitative control of $\rho''$.

5. **Sharpening the tomography.** The bracket $A/X \le k \le \tfrac32 A/\log(1+X)$ loses a factor near $3/2$ from the crude bound $1 - 1/q \ge 2/3$. Using the actual primes present, rather than the worst case $q = 3$, should shrink the interval to near-determinacy.

---

## 10. Conclusion

A three-sigma hump over an exact Dickman baseline in the smoothness rate of $j^2 - N$ has an exact arithmetic explanation and admits no single-covariate carrier — and both facts are theorems, not observations. Mean preservation holds at every modulus, so the naive rate is unbiased on average; the per-$N$ rate is nevertheless a genuine two-point mixture with maximal over-dispersion $\sum_N (X_p(N)-1)^2 = p-1$; convexity of the smoothness functional therefore forces a strictly positive excess, quadratic in the deviation $c - 1$; each prime's share of the resulting log-amplitude is capped at $3/(2k)$, which for $k \ge 3$ already defeats a $60\%$ removal bar; and the amplitude itself, through the closed form $\tfrac12\log(1 + \delta^2/(4u(u-\delta)))$ and its exact scale-free inversion, measures the spread of the underlying mixture. The practical upshot is a replacement baseline for sieve yield prediction: a divisibility mixture over residue classes of $N$ modulo the small primes.
