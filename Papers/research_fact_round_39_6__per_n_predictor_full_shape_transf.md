# Shape Transfers, Level Tracks the Population: Exact Arithmetic and Regression Laws for a Per-$N$ Quadratic-Sieve Yield Dial

**Aristotle**

*October 2026*

---

## Abstract

The quadratic sieve factors an integer $N$ by sieving the values of $Q(x) = x^2 - N$ over a factor base of small primes, and its running time is dominated by the *yield*: the fraction of sieved candidates that turn out to be smooth. Integers of identical size can have markedly different yields. A cross-scale experimental study adopted the per-$N$ predictor
$$\mathrm{rate}(N) \approx -0.0035 + 0.01156\cdot \mathrm{QR}(N),$$
where $\mathrm{QR}(N)$ counts the odd primes $p \le 100$ that pass Euler's test for $N$, and summarised its behaviour across three scales by the slogan *"the shape transfers perfectly, the level tracks each population."* In this paper we show that each half of the slogan has an exact mathematical counterpart. (i) **Shape.** For each odd prime $p$, the number of roots of $x^2 \equiv N \pmod p$ is exactly $1 + (N/p)$; Euler's test is exactly the condition $(N/p) = 1$; consequently the total sieve root mass over any set $S$ of odd primes equals $2\,\mathrm{QR}_S(N) + \#\{p \in S: p \mid N\}$, an exact affine function of the feature with slope $2$, independent of the size of $N$. (ii) **Level.** In every complete residue system modulo $p$ exactly $(p-1)/2$ classes pass the test, so the population mean of $\mathrm{QR}_S$ over a common period is exactly $\sum_{p\in S}\frac{(p-1)/2}{p} \in [\,|S|/3, |S|/2)$; for the 24 odd primes up to $100$ this pins the mean feature in $[8,12)$ and the mean adopted rate in $[0.08898, 0.13522)$. (iii) **Transfer.** For any finite sample, the in-sample $R^2$ of a transferred slope $b$ with refitted level is exactly $\rho^2 - (b-\hat\beta)^2 S_{xx}/S_{yy}$; hence level refitting is always optimal, transfer never exceeds the squared correlation, and equality holds iff the slopes coincide. (iv) **Floor.** For any predictor depending only on the feature, the residual sum of squares decomposes as pure error plus lack of fit, so the pure-error sum is a floor attained exactly by the group-mean predictor. We also record two critical consequences: the reported pair (transfer $R^2 = 0.2719$, $\rho^2 = 0.2717$) cannot consist of two in-sample statistics of a single sample, and the adopted dial is negative on the semiprime $163520117 = 2027\cdot 80671$, which passes none of the 24 Euler tests, so the dial must be clipped.

---

## 1. Introduction

### 1.1 The quadratic sieve and per-$N$ yield

Let $N$ be an odd composite integer with no small prime factors. The quadratic sieve (QS) searches for integers $x$ near $\sqrt N$ such that $Q(x) = x^2 - N$ factors completely over a *factor base* of small primes. Relations $x^2 \equiv Q(x) \pmod N$ with smooth $Q(x)$ are combined by linear algebra over $\mathbb{F}_2$ into a congruence of squares $a^2 \equiv b^2 \pmod N$, and $\gcd(a-b, N)$ yields a factor with probability at least $1/2$ per independent congruence.

The dominant cost is sieving. For each factor-base prime $p$ one locates the residues $r \bmod p$ with $p \mid Q(r)$ and adds $\log p$ to every array position $x \equiv r \pmod p$; positions whose accumulated logarithm is close to $\log |Q(x)|$ are smooth candidates. Only primes $p$ for which $N$ is a quadratic residue contribute roots, and the classical *Knuth–Schroeppel* heuristic exploits this by choosing a multiplier $k$ so that $kN$ has many small residue primes. The same principle applies to a *fixed* $N$: two moduli of equal bit length can differ substantially in how many of the small primes are "friendly," and hence in yield.

### 1.2 The experimental dial

A three-scale study measured per-$N$ smoothness yields at smoothness parameters $u = 2.5$ and $u = 3.5$ (where $u = \log X / \log B$ for values of size $X$ and smoothness bound $B$) and regressed them on the count
$$\mathrm{QR}(N) = \#\{p \text{ odd prime},\ p \le 100 : p \nmid N,\ N^{(p-1)/2} \equiv 1 \pmod p\}.$$
Its reported findings, which this paper takes as the empirical backdrop, were:

* a base effect at all three scales, with correlation $r$ between $0.497$ and $0.521$ at $u = 2.5$;
* confirmation of the primary hypothesis on a test split ($R^2 = 0.3041$, slope ratio $1.128$ at $u = 2.5$);
* near-perfect cross-scale transfer: transferring the source slope and refitting only the level gave target $R^2 = 0.2719$ against a target squared correlation of $0.2717$; transferred slopes were within the tolerance band in $4$ of $4$ cells;
* a null result for a $1/p$-weighted variant of the feature (gain $+0.009$ in $R^2$);
* a *floor attribution*: the residual of the dial was $1.31$ times the pure-error floor at $u = 2.5$ and $1.05$ times at $u = 3.5$.

The adopted form was $\mathrm{rate}(N) \approx -0.0035 + 0.01156\cdot\mathrm{QR}(N)$.

### 1.3 Contributions

We give exact statements explaining these findings, and two corrections:

1. **Root-Count Law and Shape Theorem** (Section 3): the feature is an exact affine function of the sieve root mass.
2. **Half-Pass Law and Population Mean Theorem** (Section 4): the population mean of the feature is determined by the population alone, with explicit bounds.
3. **Dial range and negative witness** (Section 5).
4. **Transfer Law** (Section 6): an exact finite-sample identity governing slope transfer with level refit, with optimality, ceiling, equality and slope-band corollaries, and an impossibility result for the reported pair.
5. **Floor Decomposition** (Section 7): the pure-error sum is a sharp lower bound for every feature-only predictor.

Section 8 interprets the experiment through these results, Section 9 gives algorithms, and Sections 10–12 discuss applications, limitations and future work.

---

## 2. Setting and Definitions

Throughout, $p$ denotes an odd prime and $N$ a nonnegative integer.

**Definition 2.1 (Legendre symbol).** $\left(\frac{N}{p}\right) = 0$ if $p \mid N$, $+1$ if $N$ is a nonzero square modulo $p$, and $-1$ otherwise.

**Definition 2.2 (Root count).** The *root count* of $N$ at $p$ is
$$\mathrm{roots}_p(N) = \#\{\, r \in \{0,1,\dots,p-1\} : p \mid r^2 - N \,\}.$$

**Definition 2.3 (Euler test).** $N$ *passes the Euler test at $p$*, written $\mathrm{pass}_p(N)$, if $p \nmid N$ and $N^{(p-1)/2} \equiv 1 \pmod p$.

**Definition 2.4 (QR feature).** For a finite set $S$ of odd primes,
$$\mathrm{QR}_S(N) = \#\{p \in S : \mathrm{pass}_p(N)\}.$$
We write $P_{100} = \{3,5,7,\dots,97\}$ for the set of odd primes at most $100$; $|P_{100}| = 24$, and $\mathrm{QR}(N) = \mathrm{QR}_{P_{100}}(N)$.

**Definition 2.5 (Adopted dial).** In exact rationals, $\mathrm{dial}(q) = -\dfrac{7}{2000} + \dfrac{289}{25000}\,q$, i.e. $-0.0035 + 0.01156\,q$.

**Definition 2.6 (Sample statistics).** For a finite nonempty index set $s$ of size $n$ and real data $(x_i, y_i)_{i\in s}$, let $\bar x, \bar y$ be the sample means and
$$S_{xx} = \sum_i (x_i-\bar x)^2,\quad S_{yy} = \sum_i (y_i - \bar y)^2,\quad S_{xy} = \sum_i (x_i-\bar x)(y_i-\bar y).$$
For an affine predictor $a + bx$,
$$\mathrm{SSE}(a,b) = \sum_i (y_i - a - b x_i)^2,\qquad R^2(a,b) = 1 - \frac{\mathrm{SSE}(a,b)}{S_{yy}}.$$
The OLS slope is $\hat\beta = S_{xy}/S_{xx}$ and the squared correlation is $\rho^2 = S_{xy}^2/(S_{xx}S_{yy})$. The **transfer $R^2$** of a slope $b$ is $R^2_{\mathrm{tr}}(b) = R^2(\bar y - b\bar x,\ b)$: the slope is imported, and the level is refitted so that the line passes through $(\bar x, \bar y)$.

---

## 3. Shape: the Feature Is Exact Root Mass

### 3.1 The Root-Count Law

**Theorem 3.1 (Root-Count Law).** For every odd prime $p$ and every $N$,
$$\mathrm{roots}_p(N) = 1 + \left(\frac{N}{p}\right).$$

*Proof sketch.* Reduction modulo $p$ is a bijection between $\{0,\dots,p-1\}$ and $\mathbb{F}_p$, and $p \mid r^2 - N$ iff $\bar r^2 = \bar N$ in $\mathbb{F}_p$. So $\mathrm{roots}_p(N)$ is the number of square roots of $\bar N$ in the field $\mathbb{F}_p$. If $\bar N = 0$ the only root is $0$. If $\bar N = c^2 \neq 0$ the roots are $\pm c$, which are distinct because $p$ is odd. If $\bar N$ is a non-square there are none. These are the cases $1+0$, $1+1$, $1-1$. $\square$

### 3.2 Euler's test is the Legendre condition

**Theorem 3.2.** For every odd prime $p$, $\mathrm{pass}_p(N) \iff \left(\frac{N}{p}\right) = 1$.

*Proof sketch.* By Euler's criterion, $N^{(p-1)/2} \equiv \left(\frac{N}{p}\right) \pmod p$. If $p\nmid N$ the symbol is $\pm1$, and since $p > 2$ we have $-1 \not\equiv 1 \pmod p$, so the residue $1$ occurs exactly when the symbol is $+1$. If $p \mid N$ the test fails by definition and the symbol is $0$. $\square$

Thus the cheap computation in the dial loses no information relative to the symbol.

**Corollary 3.3 (Per-prime split).** For every odd prime $p$,
$$\mathrm{roots}_p(N) = 2\cdot[\mathrm{pass}_p(N)] + [\,p \mid N\,],$$
where $[\cdot]$ is the indicator of a condition.

*Proof.* Combine Theorems 3.1 and 3.2 with the fact that the symbol vanishes exactly when $p \mid N$. $\square$

### 3.3 The Shape Theorem

**Theorem 3.4 (Shape Theorem).** For every finite set $S$ of odd primes and every $N$,
$$\sum_{p \in S} \mathrm{roots}_p(N) = 2\,\mathrm{QR}_S(N) + \#\{p \in S : p \mid N\}.$$
In particular, if no prime of $S$ divides $N$, the total root mass is exactly $2\,\mathrm{QR}_S(N)$.

*Proof.* Sum Corollary 3.3 over $p \in S$. $\square$

The total root mass is therefore an *exact affine function* of the feature, with slope $2$ and with no further dependence on $N$, in particular none on its size. For RSA-type moduli (no prime factor at most $100$) the correction term vanishes.

### 3.4 From roots to sieve hits

Root counts become sieve hits by periodicity.

**Lemma 3.5 (Periodicity).** For all $p, N, x$: $p \mid (x+p)^2 - N \iff p \mid x^2 - N$.

*Proof.* $(x+p)^2 - N = (x^2 - N) + p(2x+p)$. $\square$

**Lemma 3.6 (Counting a periodic predicate).** If a predicate $P$ on $\mathbb{N}$ satisfies $P(x+p) \iff P(x)$ for all $x$, then for every $L$, the number of $x \in [0, Lp)$ satisfying $P$ is $L$ times the number of $x\in[0,p)$ satisfying $P$.

*Proof.* Induction on $L$: the block $[Lp, (L+1)p)$ is a translate of $[0,p)$ by $Lp$, and $P$ is invariant under translation by multiples of $p$. $\square$

**Theorem 3.7 (Sieve hits on an interval).** The number of $x \in [0, Lp)$ with $p \mid x^2 - N$ equals $L\cdot \mathrm{roots}_p(N)$.

**Theorem 3.8 (Weighted sieve yield).** Let $M$ be a common multiple of the primes in $S$. Then
$$\sum_{p\in S} \#\{x\in[0,M) : p \mid x^2 - N\} = \sum_{p \in S} \frac{M}{p}\Bigl(2[\mathrm{pass}_p(N)] + [\,p\mid N\,]\Bigr).$$

*Proof.* Apply Theorem 3.7 with $L = M/p$ and Corollary 3.3. $\square$

Theorem 3.8 shows that the natural "weighted" feature, with weight $1/p$ per prime, is again a linear function of the same pass indicators. This frames the experimental null result for the weighted feature (Section 8.3).

---

## 4. Level: the Population Decides the Mean

### 4.1 The Half-Pass Law

**Lemma 4.1 (Total roots over a period).** For every $p \ge 1$, $\sum_{a=0}^{p-1} \mathrm{roots}_p(a) = p$.

*Proof.* Exchange the order of summation: $\sum_a \mathrm{roots}_p(a) = \sum_{r=0}^{p-1}\#\{a\in[0,p): p \mid r^2 - a\}$, and for each $r$ exactly one $a \in [0,p)$ is congruent to $r^2$. $\square$

**Theorem 4.2 (Half-Pass Law).** For every odd prime $p$, exactly $(p-1)/2$ residues $a \in [0,p)$ pass the Euler test.

*Proof.* Sum Corollary 3.3 over $a \in [0,p)$. The left side is $p$ by Lemma 4.1; the right side is $2\cdot\#\{\text{passing } a\} + 1$, since only $a = 0$ is divisible by $p$. Hence the number of passing residues is $(p-1)/2$. $\square$

**Lemma 4.3.** $\mathrm{pass}_p(N+p) \iff \mathrm{pass}_p(N)$.

*Proof.* Both conditions depend only on $N \bmod p$. $\square$

### 4.2 Population mean of the feature

**Theorem 4.4 (Population Sum).** Let $S$ be a finite set of odd primes and $M$ a common multiple of its elements. Then
$$\sum_{N=0}^{M-1} \mathrm{QR}_S(N) = \sum_{p\in S} \frac{M}{p}\cdot\frac{p-1}{2}.$$

*Proof.* Exchange the sums to get $\sum_{p\in S}\#\{N\in[0,M) : \mathrm{pass}_p(N)\}$; by Lemma 4.3 and Lemma 3.6 with $L = M/p$, each term equals $(M/p)$ times the one-period count, which is $(p-1)/2$ by Theorem 4.2. $\square$

**Theorem 4.5 (Population Mean).** Under the same hypotheses with $M > 0$, the mean of $\mathrm{QR}_S(N)$ over $0 \le N < M$ is exactly
$$\mu_S = \sum_{p\in S}\frac{(p-1)/2}{p}.$$

**Lemma 4.6.** For every odd prime $p$, $\dfrac13 \le \dfrac{(p-1)/2}{p} < \dfrac12$.

*Proof.* Write $p = 2k+1$ with $k \ge 1$. The ratio is $k/(2k+1)$; then $3k \ge 2k+1$ iff $k \ge 1$, and $2k < 2k+1$. $\square$

**Theorem 4.7 (Mean bounds).** If $S$ is nonempty, then $|S|/3 \le \mu_S < |S|/2$.

*Proof.* Sum Lemma 4.6 over $S$; strictness survives because $S$ is nonempty. $\square$

### 4.3 Level of the adopted dial

**Lemma 4.8 (Mean of an affine dial).** Because the dial is affine, its population mean equals the dial applied to the mean feature:
$$\frac1M\sum_{N<M}\mathrm{dial}(\mathrm{QR}_S(N)) = -\frac{7}{2000} + \frac{289}{25000}\,\mu_S.$$

**Theorem 4.9 (Population level of the adopted dial).** Let $M > 0$ be a common multiple of the primes in $P_{100}$. Then the population mean of $\mathrm{QR}(N)$ over $0 \le N < M$ lies in $[8, 12)$, and the population mean of $\mathrm{dial}(\mathrm{QR}(N))$ lies in
$$\left[\frac{4449}{50000}, \frac{6761}{50000}\right) = [\,0.08898,\ 0.13522\,).$$

*Proof.* $|P_{100}| = 24$, so Theorem 4.7 gives $[8,12)$; apply Lemma 4.8, using $-0.0035 + 0.01156\cdot 8 = 0.08898$ and $-0.0035 + 0.01156\cdot 12 = 0.13522$. $\square$

Numerically, $\mu_{P_{100}} = 12 - \tfrac12\sum_{p\in P_{100}} 1/p \approx 11.3486$, giving a population-mean dial of approximately $0.1277$.

**Interpretation.** The population mean of the feature is a function of the primes used and of the population's residue distribution, not of any individual $N$. A sample of $N$ drawn under a different procedure (a different bit length, a different smoothness parameter, semiprimes rather than uniform residues) has a different average level and a different average yield; the intercept must be refitted. The *deviation* $\mathrm{QR}(N) - \mu$ is the per-$N$ signal.

---

## 5. Range of the Adopted Dial and a Negative Witness

**Proposition 5.1.** For every integer $q \ge 0$, $\mathrm{dial}(q) > 0 \iff q \ge 1$.

*Proof.* $\mathrm{dial}(0) = -7/2000 < 0$ and $\mathrm{dial}(1) = 289/25000 - 7/2000 = 403/50000 > 0$; the dial is increasing. $\square$

**Proposition 5.2.** For every $N$, $\mathrm{dial}(\mathrm{QR}(N)) \le \dfrac{13697}{50000} = 0.27394$.

*Proof.* $\mathrm{QR}(N) \le |P_{100}| = 24$ and $\mathrm{dial}(24) = 13697/50000$. $\square$

**Theorem 5.3 (Negative witness).** Let $N_0 = 163520117$. Then $N_0 = 2027 \cdot 80671$ with both factors prime; $\mathrm{QR}(N_0) = 0$; $\sum_{p\in P_{100}}\mathrm{roots}_p(N_0) = 0$; and $\mathrm{dial}(\mathrm{QR}(N_0)) = -0.0035 < 0$.

*Proof sketch.* A finite computation: $N_0$ is a quadratic non-residue modulo each of the 24 odd primes up to $100$ and divisible by none of them. The root-mass statement then follows from the Shape Theorem. $\square$

So the linear dial must be clipped at $0$ at the bottom of its range. Semiprimes with $\mathrm{QR} = 0$ are rare (under a fair-coin model for the Legendre bits, about $2^{-24}$ of moduli), but they exist, and for them the sieve primes up to $100$ contribute *no* hits at all.

---

## 6. The Transfer Law

Fix a finite nonempty sample $s$ with $S_{xx} > 0$ and $S_{yy} > 0$.

### 6.1 Decomposing the residual

**Theorem 6.1 (Level/shape decomposition).** For all $a, b$,
$$\mathrm{SSE}(a,b) = n\,(\bar y - a - b\bar x)^2 + \bigl(S_{yy} - 2b\,S_{xy} + b^2 S_{xx}\bigr).$$

*Proof sketch.* Write $y_i - a - bx_i = (\bar y - a - b\bar x) + \bigl((y_i-\bar y) - b(x_i - \bar x)\bigr)$, expand the square, and use $\sum_i (x_i-\bar x) = \sum_i (y_i - \bar y) = 0$ to eliminate the cross term. $\square$

The first term depends on the level and the second only on the slope.

**Corollary 6.2 (Level refit is optimal).** For every slope $b$ and every intercept $a$,
$$\mathrm{SSE}(\bar y - b\bar x,\ b) \le \mathrm{SSE}(a, b).$$

**Lemma 6.3 (Completing the square).**
$$\mathrm{SSE}(\bar y - b\bar x,\ b) = S_{xx}\,(b - \hat\beta)^2 + \Bigl(S_{yy} - \frac{S_{xy}^2}{S_{xx}}\Bigr).$$

**Corollary 6.4 (Cauchy–Schwarz).** $S_{xy}^2 \le S_{xx}S_{yy}$, hence $\rho^2 \le 1$.

*Proof.* Evaluate Lemma 6.3 at $b = \hat\beta$ and use $\mathrm{SSE} \ge 0$. $\square$

### 6.2 The law and its corollaries

**Theorem 6.5 (Transfer Law).** For every slope $b$,
$$R^2_{\mathrm{tr}}(b) = \rho^2 - (b - \hat\beta)^2\,\frac{S_{xx}}{S_{yy}}.$$

*Proof.* Divide Lemma 6.3 by $S_{yy}$ and subtract from $1$; note $1 - (S_{yy} - S_{xy}^2/S_{xx})/S_{yy} = \rho^2$. $\square$

**Corollary 6.6.**
1. $R^2_{\mathrm{tr}}(\hat\beta) = \rho^2$ (the OLS fit attains the squared correlation).
2. $R^2_{\mathrm{tr}}(b) \le \rho^2$ for every $b$.
3. $R^2_{\mathrm{tr}}(b) = \rho^2 \iff b = \hat\beta$.
4. **(Ceiling.)** $R^2(a,b) \le \rho^2$ for *every* affine predictor $a + bx$.
5. **(Slope band.)** For every $\varepsilon$: $\rho^2 - R^2_{\mathrm{tr}}(b) \le \varepsilon \iff (b-\hat\beta)^2 \le \varepsilon\,S_{yy}/S_{xx}$.

*Proof.* Items 1–3 and 5 are immediate from Theorem 6.5, using $S_{xx}, S_{yy} > 0$. Item 4 combines item 2 with Corollary 6.2: $R^2(a,b) \le R^2_{\mathrm{tr}}(b) \le \rho^2$. $\square$

Item 5 converts any tolerance on the $R^2$ gap into an *exact* interval of admissible slopes, so "slopes in band" becomes a certificate rather than a heuristic.

### 6.3 An impossibility result for the reported pair

**Theorem 6.7.** There is no finite sample (with $S_{xx}, S_{yy} > 0$) and no affine predictor $a + bx$ such that simultaneously
$$|R^2(a,b) - 0.2719| \le 0.00005 \quad\text{and}\quad |\rho^2 - 0.2717| \le 0.00005.$$

*Proof.* The conditions force $R^2(a,b) \ge 0.27185 > 0.27175 \ge \rho^2$, contradicting Corollary 6.6(4). $\square$

Hence the reported transfer value $0.2719$ and target squared correlation $0.2717$ cannot both be in-sample statistics on one and the same target sample; they must have been computed on different samples (e.g. held-out versus full target), and their difference is sampling variation. The correct reading of "transfer shape perfect" is that the transfer gap is statistically indistinguishable from $0$, which by Corollary 6.6(5) means that the transferred slope lies in a narrow band around the target slope.

---

## 7. The Pure-Error Floor

Because $\mathrm{QR}$ is integer-valued in $\{0,\dots,24\}$, a sample splits into at most $25$ groups by feature value. Let $s$ be a finite sample with feature values $x_i$ and responses $y_i$.

**Definition 7.1.** The *group mean* at $i$ is $m(i) = $ the mean of $y_j$ over $\{j \in s: x_j = x_i\}$. The *pure error* is
$$\mathrm{PE} = \sum_{i\in s} (y_i - m(i))^2.$$

**Lemma 7.2 (One-group identity).** For a nonempty group and any constant $c$, $\sum_i (y_i - c)^2 = \sum_i (y_i - \bar y)^2 + n(\bar y - c)^2$.

**Theorem 7.3 (Floor Decomposition).** For every function $g:\mathbb{R}\to\mathbb{R}$,
$$\sum_{i\in s}(y_i - g(x_i))^2 = \mathrm{PE} + \sum_{i\in s}(m(i) - g(x_i))^2.$$

*Proof sketch.* Partition $s$ into fibres of the feature. On a fibre, $g(x_i)$ is a constant $c$ and $m(i)$ is the fibre mean, so Lemma 7.2 applies; summing the fibre identities gives the claim. $\square$

**Corollary 7.4.**
1. $\mathrm{PE} \le \sum_i (y_i - g(x_i))^2$ for every feature-only predictor $g$; every residual-to-floor ratio is at least $1$.
2. Equality holds iff $g(x_i) = m(i)$ for all $i \in s$.
3. In particular $\mathrm{PE} \le \mathrm{SSE}(a,b)$ for every affine dial, including the adopted one and its least-squares refit.
4. $\mathrm{PE} \le S_{yy}$ (take $g$ constant at $\bar y$).

The excess of an affine dial over the floor is precisely $\sum_i (m(i) - a - b x_i)^2$, the **lack of fit** of a straight line to the group means.

---

## 8. Interpreting the Experiment

### 8.1 Why the shape transfers

By the Shape Theorem, the feature is (for moduli free of small factors) exactly half the root mass of the 24 smallest odd sieve primes, and by Theorem 3.7 root mass is the per-period count of sieve hits. This identity has no dependence on the size of $N$. The relationship between feature and *yield* is not an identity — smoothness depends on $\log p$ weights, on primes beyond $100$, and on the size of the sieved values — so correlations of about $0.5$ rather than $1$ are expected. But the mechanism linking one extra friendly prime to extra yield is scale-free, which makes slope transfer plausible a priori and explains the observed in-band slopes in all four transfer cells.

### 8.2 Why the level must be refitted

By Theorem 4.5 the mean feature is a population constant, and the mean yield depends on the population through the smoothness parameter and the size of the values. The intercept absorbs both, so it must move between populations. Corollary 6.2 guarantees that refitting the level on the target never hurts.

### 8.3 The weighted-feature null

By Theorem 3.8 the $1/p$-weighted root mass and the unweighted count are both linear in the same vector of pass indicators. Over $p \le 100$ the weights vary only by a factor of about $33$, so the two features are highly collinear on populations whose Legendre bits behave like independent fair coins. A gain of $+0.009$ in $R^2$ is consistent with this near-collinearity.

### 8.4 Floor attribution

By Corollary 7.4 the ratios $1.31$ ($u=2.5$) and $1.05$ ($u=3.5$) are both necessarily at least $1$. At $u = 3.5$ the dial is within $5\%$ of the best any function of $\mathrm{QR}$ can achieve: the feature is essentially exhausted and the remaining residual is noise relative to it. At $u = 2.5$ the excess of $31\%$ is lack of fit of the straight line to the group means — real structure, such as curvature in the group-mean profile, that a richer function of the same feature (or an additional feature) could capture.

### 8.5 Corrections

Theorem 6.7 requires that the two published $R^2$ numbers be recomputed on a single sample. Theorem 5.3 requires that the dial be used in the clipped form $\max(0, \mathrm{dial}(\mathrm{QR}(N)))$.

---

## 9. Algorithms

**Algorithm A (Per-$N$ yield dial).**
Input: $N$. Output: predicted relative yield.
1. $q \leftarrow 0$.
2. For each $p \in P_{100}$: if $N \bmod p \ne 0$ and $N^{(p-1)/2} \bmod p = 1$, set $q \leftarrow q+1$.
3. Return $\max\bigl(0,\ -0.0035 + 0.01156\,q\bigr)$.

Cost: $24$ modular exponentiations with exponent below $50$, i.e. $O(24\log 100)$ multiplications modulo primes below $100$, after one reduction of $N$ modulo each prime ($O(\log N)$ word operations each). By Theorem 3.2 the test equals the Legendre condition; by Theorem 3.4, $2q$ is the exact root mass when $N$ has no small factors.

**Algorithm B (Cross-scale transfer with level refit).**
Input: source sample, target sample. Output: transferred predictor and diagnostics.
1. Fit the OLS slope $b$ on the source sample.
2. On the target, compute $\bar x, \bar y, S_{xx}, S_{yy}, S_{xy}$, $\hat\beta$ and $\rho^2$.
3. Set $a \leftarrow \bar y - b\bar x$ (level refit).
4. Report $R^2_{\mathrm{tr}} = \rho^2 - (b-\hat\beta)^2 S_{xx}/S_{yy}$ and the gap; declare the slope in band for tolerance $\varepsilon$ iff $(b-\hat\beta)^2 \le \varepsilon S_{yy}/S_{xx}$.
5. Compute both $R^2_{\mathrm{tr}}$ and $\rho^2$ on the *same* sample.

Cost: $O(n)$.

**Algorithm C (Floor attribution).**
1. Group the sample by feature value; compute group means $m$.
2. $\mathrm{PE} \leftarrow \sum_i (y_i - m(i))^2$.
3. For a candidate dial $(a,b)$, report $\mathrm{SSE}(a,b)/\mathrm{PE} \ge 1$ and the lack of fit $\mathrm{SSE}(a,b) - \mathrm{PE} = \sum_i (m(i) - a - bx_i)^2$.

Cost: $O(n)$ with a hash map, or $O(n + 25)$ with an array indexed by feature value.

---

## 10. Applications

* **QS parameter calibration.** The clipped dial gives a cheap pre-sieve estimate of relative yield for a specific $N$, which can drive the choice of sieve interval length, factor-base size, or time budget. Its population level should be refitted for each operating regime (bit length, $u$), while the slope may be carried over.
* **Multiplier selection.** The Shape Theorem quantifies why a Knuth–Schroeppel-type multiplier helps: replacing $N$ by $kN$ changes the pass vector and hence the root mass by exactly twice the change in $\mathrm{QR}$.
* **Experimental hygiene.** The Transfer Law and the impossibility theorem give exact consistency checks for any regression-transfer study: in-sample transfer $R^2$ can never exceed $\rho^2$, and the gap is an explicit quadratic in the slope error.
* **Diagnostics for any discrete feature.** The Floor Decomposition applies to every integer-valued predictor and separates noise from lack of fit.

---

## 11. Discussion and Limitations

The results proved here are exact, but they concern the *mechanism* (root mass), the *population mean of the feature*, and the *algebra* of regression transfer. They do not by themselves prove that the measured yield correlates with the feature, nor do they determine the numerical slope $0.01156$; those are empirical. The population-mean theorem is stated for a uniform population over a complete common period; real samples (semiprimes of fixed size) are only approximately equidistributed in residue classes, so the bounds $[8,12)$ and $[0.08898, 0.13522)$ describe the idealised population. The dial's linear form is adequate where the floor ratio is close to $1$ ($u = 3.5$) but leaves lack of fit at $u = 2.5$.

These results also bear on the security of factoring-based cryptography only in a calibration sense. The dial predicts constant-factor variations in sieve yield and does not change the asymptotic complexity of the quadratic sieve or of the number field sieve.

---

## 12. Future Work

1. **Log-weighted root-mass equivalence.** Under an independent fair-coin model for Legendre bits, compute in closed form the correlation between the $1/p$-weighted root mass and the unweighted count over $p \le 100$; the conjecture is that it is at least $0.95$, which would explain the weighted-feature null.
2. **Slope-band certificate.** Recompute transfer $R^2$ and $\rho^2$ on one held-out sample per cell and verify that the gap equals $(b_{\mathrm{src}} - \hat\beta_{\mathrm{tgt}})^2 S_{xx}/S_{yy}$ to rounding, with every in-band cell satisfying $(b-\hat\beta)^2 \le 10^{-3} S_{yy}/S_{xx}$.
3. **Clipped and nonlinear dials.** Replace the affine dial by its clipped version, or by the group-mean profile, and quantify how much of the $31\%$ excess at $u = 2.5$ is recovered.
4. **Beyond $p \le 100$.** Extend the feature to larger factor-base primes with $\log p$ weights, where Theorem 3.8 still gives exact yields over a common period.

---

## Acknowledgement of scope

All theorems in Sections 3–7 are stated with complete hypotheses and proved (in sketch) above; the experimental figures quoted in Sections 1.2 and 8 are reported measurements from the underlying study and are used here only for interpretation.
