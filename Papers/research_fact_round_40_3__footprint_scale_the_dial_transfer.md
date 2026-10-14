# Footprint-Scale Transfer of a Sieve-Yield Dial: Exact Algebra of Calibration Slopes, Reliability Ceilings and the Tropical Limit

**Aristotle**

*October 2026*

---

## Abstract

A footprint-weighted yield dial is a predictor of the smooth-relation yield of a sieve. It is built from the active prime support of a modulus $N$. We fit it at bit length $44$ and transfer it unchanged to bit lengths $48$ and $52$. The observed calibration slopes are $0.896$ and $0.834$ at $80$ sieve values per modulus, and $0.912$ and $0.834$ at $240$ values per modulus. All four lie inside the acceptance band. A direct divisibility feature $d(N)$ stays significant after the dial is partialled out in $12/12$ cells, with minimum $|t| = 3.92$. The in-cell $R^2$ rises from $0.41$ to $0.60$ in the cell $u = 2.5$, bit length $48$. This paper develops the exact finite-sample algebra that turns these numbers into conclusions.

We prove the following results.

1. An errors-in-variables *attenuation law*: the calibration slope equals $cV/(V+E)$.
2. A *stable-slope theorem*: equal slopes at two relation counts force the relation-count noise to vanish. Hence the bit-length-$52$ deficit is scale drift.
3. The *Frisch–Waugh–Lovell identity* for the pair (dial, $d(N)$), together with a criterion for independent signal.
4. A *$t$/partial-$R^2$ dictionary*. It shows that $|t|\ge 3.92$ forces a partial $R^2$ above $0.166$ at $77$ degrees of freedom but only above $0.06$ at $237$, and that the bound $1/6$ fails.
5. A *relation-count reliability curve* $R^2(m)=V/(V+F+\sigma/m)$. Its reciprocal is affine in $1/m$, it is bounded above by the Spearman–Brown prophecy, and its ceiling is identified from two points. For the reported cell this forces a structural floor $F>0$, pins the ceiling at exactly $82/105$, and shows that exactly $626$ values per modulus are needed for $R^2\ge 0.70$.
6. A *slope–$R^2$ factorisation*, $R^2=\text{slope}\cdot V/(V+H)$.
7. A *tropical limit theorem*: as the dial exponent $\alpha\to\infty$, the $R^2$ of the normalised log-dial converges to the $R^2$ of the min-plus statistic $-\log\min\operatorname{supp}N$.

---

## 1. Introduction

### 1.1 Setting

Sieve-based factoring algorithms collect *relations*: sieved values that factor completely over a fixed set of small primes. The yield of a sieve, meaning the number of relations per unit of sieving work, depends on the modulus $N$ through the arithmetic of the small primes. A prime $\ell$ is *active* for $N$ when it can divide the sieved values, for example when the relevant polynomial has roots modulo $\ell$. Write $\operatorname{supp}(N)$ for the finite set of active primes, each at least $2$. The **footprint-weighted dial** with exponent $\alpha>0$ is

$$S_\alpha(N)\;=\;\sum_{\ell\in\operatorname{supp}(N)}\ell^{-\alpha}.$$

Its *normalised log-dial* is $x_\alpha(N)=\alpha^{-1}\log S_\alpha(N)$. The dial is a one-parameter family. For moderate $\alpha$ it averages over the entire footprint of active primes. As $\alpha\to\infty$ it concentrates on the smallest active prime. In that limit it becomes a tropical (min-plus) statistic.

### 1.2 The transfer experiment

We fitted the dial at bit length $44$ and applied it unchanged to fresh moduli at bit lengths $48$ and $52$. We used two relation counts, $m=80$ and $m=240$ values per modulus, and several smoothness parameters $u$. In each cell (one bit length, one $u$, one $m$) we regressed the observed yield on the transferred prediction. The fitted slope is the **calibration slope**. We also ran a two-regressor fit on the dial and a direct divisibility feature $d(N)$. The pseudo-random seed was fixed in advance at $20260830$. The headline results:

| bit length | slope at $m=80$ | slope at $m=240$ |
|---|---|---|
| 48 | 0.896 | 0.912 |
| 52 | 0.834 | 0.834 |

- All four calibration cells lie in the acceptance band.
- $d(N)$ is significant beyond the dial in $12/12$ cells, with minimum $|t|=3.92$.
- At $u=2.5$ and bit length $48$, the in-cell $R^2$ rises from $0.41$ ($m=80$) to $0.60$ ($m=240$).

On data hygiene: an early tabulation contained duplicated $u$-blocks and one out-of-band cell. These were corrected before analysis. A "ceiling" column computed under a convention inconsistent with the definition used here (Definition 6.2) was not adopted.

### 1.3 Contributions

All our results are exact identities or inequalities. They hold either for an arbitrary finite sample or for an explicit parametric model. We separate three kinds of claim:

- **Calibration (§3–§4).** Why slopes below one are expected. What a slope that does not move with $m$ implies. Why $R^2$ is comparable across scales while the slope is not.
- **Independent signal (§5).** What it means for $d(N)$ to survive partialling out the dial, and how much effect size a given $|t|$ guarantees.
- **Reliability (§6–§7).** How $R^2$ grows with the relation count, what ceiling it approaches, and how many relations are needed to reach a target.

Section 8 gives the tropical limit. Section 9 discusses scope, and Section 10 lists open problems.

---

## 2. Sample covariance algebra

Throughout, $\iota$ is a finite nonempty index set. In practice it is the set of moduli in one cell. A *column* is a function $x:\iota\to\mathbb R$.

**Definition 2.1 (mean, covariance, slope, $R^2$).** Let $n=|\iota|$.

$$\bar x=\frac1n\sum_i x_i,\qquad \operatorname{cov}(x,y)=\sum_i (x_i-\bar x)(y_i-\bar y),$$

$$\operatorname{slope}(x,y)=\frac{\operatorname{cov}(x,y)}{\operatorname{cov}(x,x)},\qquad R^2(x,y)=\frac{\operatorname{cov}(x,y)^2}{\operatorname{cov}(x,x)\operatorname{cov}(y,y)}.$$

We do not normalise the covariance by $n$ or $n-1$. Every quantity below is a ratio, so normalisation cancels. When a denominator vanishes, we use the convention that division by zero gives $0$. Every result is stated with the hypotheses needed to avoid that case.

**Lemma 2.2 (bilinearity).** The covariance is symmetric and bilinear: $\operatorname{cov}(x+z,y)=\operatorname{cov}(x,y)+\operatorname{cov}(z,y)$ and $\operatorname{cov}(cx,y)=c\operatorname{cov}(x,y)$, and similarly in the second argument. It vanishes when one argument is constant. It is unchanged when a constant is added to either argument. Finally, $\operatorname{cov}(x,x)\ge0$.

*Proof.* The mean is linear and maps a constant column to that constant. Expand the summand. $\square$

**Theorem 2.3 (Cauchy–Schwarz).** $0\le R^2(x,y)\le 1$.

*Proof.* Apply Cauchy–Schwarz to the centred vectors $(x_i-\bar x)$ and $(y_i-\bar y)$. This gives $\operatorname{cov}(x,y)^2\le\operatorname{cov}(x,x)\operatorname{cov}(y,y)$. If the right side is $0$, then $R^2=0$ by convention. Otherwise divide. $\square$

**Theorem 2.4 (affine reparametrisation).** Let $a,b\in\mathbb R$ with $b\ne0$, and let $\tilde x_i=a+bx_i$. Then

$$\operatorname{slope}(\tilde x,y)=\frac{\operatorname{slope}(x,y)}{b},\qquad R^2(\tilde x,y)=R^2(x,y).$$

*Proof.* By Lemma 2.2, $\operatorname{cov}(\tilde x,y)=b\operatorname{cov}(x,y)$ and $\operatorname{cov}(\tilde x,\tilde x)=b^2\operatorname{cov}(x,x)$. In the slope the factor $b/b^2=1/b$ remains. In $R^2$ the factor $b^2/b^2$ cancels. The degenerate cases are checked directly. $\square$

**Interpretation.** $R^2$ is the scale-free part of a transfer, and the slope carries the scale. Any change of units of the dial between bit lengths leaves $R^2$ untouched. The slope is the statistic that detects mis-scaling.

---

## 3. The attenuation law for calibration slopes

**Model 3.1.** The transferred prediction is $x=s+e$, the sum of a true signal $s$ and prediction noise $e$. The observed yield is $y=c\,s+\eta$, a scaled copy of the signal plus yield noise $\eta$. Here $c\in\mathbb R$ is the *scale factor*: $c=1$ means the dial's units transfer perfectly. We assume the sample orthogonality conditions

$$\operatorname{cov}(s,e)=\operatorname{cov}(s,\eta)=\operatorname{cov}(e,\eta)=0.$$

Write $V=\operatorname{cov}(s,s)$, $E=\operatorname{cov}(e,e)$ and $H=\operatorname{cov}(\eta,\eta)$.

**Theorem 3.2 (Attenuation Law).** Under Model 3.1,

$$\operatorname{slope}(s+e,\;c\,s+\eta)\;=\;\frac{c\,V}{V+E}.$$

*Proof.* By bilinearity, $\operatorname{cov}(s+e,cs+\eta)=cV+c\operatorname{cov}(e,s)+\operatorname{cov}(s,\eta)+\operatorname{cov}(e,\eta)=cV$. Likewise $\operatorname{cov}(s+e,s+e)=V+2\operatorname{cov}(s,e)+E=V+E$. $\square$

This is an exact finite-sample identity, not an asymptotic statement. The probabilistic version, in which the orthogonality holds only in expectation, is the classical regression-dilution bias.

**Corollary 3.3 (honest slopes lie in $(0,1]$).** Suppose $c=1$ and $V>0$. Then $0<\operatorname{slope}(s+e,s+\eta)\le1$. Moreover, $\operatorname{slope}=1$ if and only if $E=0$.

*Proof.* The slope is $V/(V+E)$ with $E\ge 0$. It equals $1$ exactly when $V=V+E$. $\square$

So in the absence of scale drift, every predictor with nonzero noise has slope strictly below $1$. The values $0.896$ and $0.912$ are what a correctly scaled but noisy dial produces.

### 3.1 Dependence on the relation count

The prediction noise has two parts. A fixed part with variance $E_0\ge0$ comes from structure the dial misses. A sampling part with variance $\sigma/m$ ($\sigma\ge0$) comes from estimating each modulus's yield from $m$ sieve values.

**Definition 3.4 (attenuated slope curve).** $\displaystyle \operatorname{att}(m)=\frac{cV}{V+E_0+\sigma/m}$ for $m>0$.

**Proposition 3.5 (more relations never hurt).** Suppose $c,V>0$ and $E_0,\sigma\ge0$. If $0<m_1\le m_2$, then $\operatorname{att}(m_1)\le\operatorname{att}(m_2)$.

*Proof.* $\sigma/m$ is nonincreasing in $m$. The numerator $cV$ is positive and the denominators are positive. $\square$

**Theorem 3.6 (Stable Slope ⇒ No Relation-Count Noise).** Suppose $c>0$, $V>0$, $E_0\ge0$, $\sigma\ge0$ and $0<m_1<m_2$. If $\operatorname{att}(m_1)=\operatorname{att}(m_2)$, then $\sigma=0$.

*Proof.* Both denominators are positive, so cross-multiplying gives $cV(V+E_0+\sigma/m_2)=cV(V+E_0+\sigma/m_1)$. Cancelling $cV>0$ gives $\sigma/m_1=\sigma/m_2$, that is, $\sigma(m_2-m_1)=0$. Since $m_2>m_1$, $\sigma=0$. $\square$

**Reading at bit length 52.** The slope is $0.834$ at both $m=80$ and $m=240$. Within the model, Theorem 3.6 forces $\sigma=0$ at this bit length. The deficit $1-0.834$ therefore splits into scale drift ($c<1$) and fixed prediction noise ($E_0>0$). Neither part can be removed by more sieving. At bit length $48$ the slope moves ($0.896\to0.912$), which is consistent with $\sigma>0$. Bit length $52$ is the first cell in which the two causes of miscalibration separate empirically. (Equality is of course up to reporting precision. The theorem is about the model, and its empirical reading assumes the two reported slopes are equal.)

---

## 4. Slope versus $R^2$

**Theorem 4.1 (Slope–$R^2$ Factorisation).** Under Model 3.1 with $c=1$ and $V>0$,

$$R^2(s+e,\;s+\eta)\;=\;\operatorname{slope}(s+e,\;s+\eta)\cdot\frac{V}{V+H}.$$

*Proof.* By bilinearity and orthogonality, $\operatorname{cov}(x,y)=V$, $\operatorname{cov}(x,x)=V+E$ and $\operatorname{cov}(y,y)=V+H$. So

$$R^2=\frac{V^2}{(V+E)(V+H)}=\frac{V}{V+E}\cdot\frac V{V+H}.\qquad\square$$

**Corollary 4.2.** Under the same hypotheses, $R^2\le\operatorname{slope}$. If the yield is noiseless ($\eta=0$, i.e. $y=s$), then $\operatorname{slope}(s+e,s)=R^2(s+e,s)=V/(V+E)$.

**Interpretation.** In the transfer experiment the slopes are about $0.83$–$0.91$, while the in-cell $R^2$ values are about $0.41$–$0.60$. Theorem 4.1 attributes the gap to the *yield reliability* $V/(V+H)$, not to miscalibration of the dial. With a noiseless yield, the slope column and the $R^2$ column would be one and the same reliability.

---

## 5. Independent signal of the divisibility feature

Let $x_1$ be the dial, $x_2=d(N)$ the divisibility feature, and $y$ the yield. Abbreviate $a=\operatorname{cov}(x_1,x_1)$, $b=\operatorname{cov}(x_1,x_2)$ and $d=\operatorname{cov}(x_2,x_2)$, and put $D=ad-b^2$.

**Definition 5.1 (partial coefficients and residual).**

$$\beta_1=\frac{d\operatorname{cov}(x_1,y)-b\operatorname{cov}(x_2,y)}{D},\qquad \beta_2=\frac{a\operatorname{cov}(x_2,y)-b\operatorname{cov}(x_1,y)}{D},$$

$$r=x_2-\operatorname{slope}(x_1,x_2)\,x_1\quad(\text{the residual of }d(N)\text{ after the dial}).$$

**Theorem 5.2 (normal equations).** If $D\ne0$, then

$$a\beta_1+b\beta_2=\operatorname{cov}(x_1,y),\qquad b\beta_1+d\beta_2=\operatorname{cov}(x_2,y).$$

So $(\beta_1,\beta_2)$ are the ordinary least-squares coefficients of the two-regressor fit with intercept.

*Proof.* Substitute and clear the common denominator $D$. $\square$

**Lemma 5.3 (orthogonality of the residual).** If $a\ne0$, then $\operatorname{cov}(x_1,r)=0$.

*Proof.* $\operatorname{cov}(x_1,r)=b-(b/a)\,a=0$. $\square$

**Theorem 5.4 (Frisch–Waugh–Lovell).** If $a\ne0$, then

$$\beta_2=\operatorname{slope}(r,y).$$

*Proof.* By bilinearity, $\operatorname{cov}(r,y)=\operatorname{cov}(x_2,y)-(b/a)\operatorname{cov}(x_1,y)=(a\operatorname{cov}(x_2,y)-b\operatorname{cov}(x_1,y))/a$. Also $\operatorname{cov}(r,r)=d-2b^2/a+b^2/a=D/a$. Their quotient is $\beta_2$, since the factor $1/a$ cancels. $\square$

**Corollary 5.5 (criterion for independent signal).** If $a\ne0$ and $D\ne0$, then

$$\beta_2\ne0\iff\operatorname{cov}(r,y)\ne0\iff a\operatorname{cov}(x_2,y)\ne b\operatorname{cov}(x_1,y).$$

In words, $d(N)$ contributes beyond the dial exactly when the part of $d(N)$ orthogonal to the dial is correlated with the yield.

### 5.1 From $t$ to effect size

For a coefficient with partial $R^2$ equal to $\rho\in[0,1)$ and $\mathrm{df}$ residual degrees of freedom, the squared $t$-statistic is

$$t^2=\frac{\mathrm{df}\cdot\rho}{1-\rho}.$$

**Theorem 5.6 ($t$/partial-$R^2$ dictionary).** Let $\mathrm{df}>0$ and $\rho<1$.

1. $\rho=t^2/(t^2+\mathrm{df})$.
2. For every threshold $\tau$: $\tau^2\le t^2\iff \tau^2/(\tau^2+\mathrm{df})\le\rho$.

*Proof.* (1) $t^2+\mathrm{df}=\mathrm{df}/(1-\rho)$, so $t^2/(t^2+\mathrm{df})=\rho$. (2) Multiply through by the positive quantities $1-\rho$ and $\tau^2+\mathrm{df}$. Both directions reduce to the same linear inequality $\tau^2(1-\rho)\le\mathrm{df}\,\rho$. $\square$

**Theorem 5.7 (monotone threshold).** If $\tau\neq0$ and $0<\mathrm{df}_1<\mathrm{df}_2$, then

$$\frac{\tau^2}{\tau^2+\mathrm{df}_2}<\frac{\tau^2}{\tau^2+\mathrm{df}_1}.$$

**Corollary 5.8 (reading $\min|t|=3.92$).** The model has three fitted parameters (intercept, dial and $d(N)$).

- At $m=80$ ($\mathrm{df}=77$): $|t|\ge3.92$ implies $\rho>0.166$. The exact threshold is $3.92^2/(3.92^2+77)=1372/8247\approx0.166364$.
- At $m=240$ ($\mathrm{df}=237$): $|t|\ge3.92$ implies $\rho>0.06$. The exact threshold is $\approx0.060889$.

**Remark (a false rounding).** The statement "partial $R^2>1/6$ at $\mathrm{df}=77$" is *false* as a consequence of $|t|\ge3.92$, because $1372/8247<1/6$. By Theorem 5.7, significance at the larger relation count is a *weaker* effect-size statement. A $12/12$ significance count is not, by itself, evidence that $d(N)$ grows in importance with $m$.

---

## 6. The relation-count reliability curve

**Model 6.1.** In a fixed cell, the yield estimated from $m$ relations is the true signal (variance $V>0$), plus a fixed structural residual (variance $F\ge0$, independent of $m$), plus sampling noise averaged over the relations (variance $\sigma/m$, $\sigma\ge0$). The in-cell $R^2$ is then

$$R^2(m)=\frac{V}{V+F+\sigma/m}.$$

**Definition 6.2 (ceiling).** $\operatorname{ceil}=V/(V+F)$.

**Definition 6.3 (Spearman–Brown prophecy).** $\operatorname{SB}(k,R)=\dfrac{kR}{1+(k-1)R}$.

**Theorem 6.4 (affine reciprocal).** For $V>0$ and $m\ne0$,

$$\frac1{R^2(m)}=1+\frac FV+\frac\sigma V\cdot\frac1m.$$

*Proof.* Invert and divide numerator and denominator by $V$. $\square$

**Theorem 6.5 (monotonicity and ceiling).** Suppose $V>0$ and $F\ge0$.

1. If $\sigma>0$ and $0<m_1<m_2$, then $R^2(m_1)<R^2(m_2)$.
2. $R^2(m)\to\operatorname{ceil}$ as $m\to\infty$.
3. If $\sigma>0$, then $R^2(m)<\operatorname{ceil}$ for every $m>0$: the ceiling is never attained.

*Proof.* The term $\sigma/m$ is positive and strictly decreasing to $0$. $\square$

**Theorem 6.6 (Spearman–Brown).** If $F=0$, $V>0$, $\sigma\ge0$, $m>0$ and $k>0$, then $R^2(km)=\operatorname{SB}(k,R^2(m))$.

**Lemma 6.7 (closed form of the prophecy).** For $V>0$, $F,\sigma\ge0$, $m>0$ and $k>0$,

$$\operatorname{SB}(k,R^2(m))=\frac{V}{V+F/k+\sigma/(km)}.$$

*Proof.* $1+(k-1)R^2(m)=(kV+F+\sigma/m)/(V+F+\sigma/m)$. Simplify. $\square$

So the prophecy formula behaves as if the structural residual were also averaged down by the factor $k$. The truth is that $F$ stays fixed. Theorem 6.6 is the special case $F=0$ of Lemma 6.7.

**Theorem 6.8 (Spearman–Brown is an upper bound).** Suppose $V>0$, $F,\sigma\ge0$ and $m>0$.

1. If $k\ge1$, then $R^2(km)\le\operatorname{SB}(k,R^2(m))$.
2. If $k>1$, then $R^2(km)<\operatorname{SB}(k,R^2(m))\iff F>0$.

*Proof.* Compare $V/(V+F+\sigma/(km))$ with Lemma 6.7. The only difference is $F$ against $F/k$, and $F/k\le F$, strictly so when $F>0$ and $k>1$. $\square$

**Theorem 6.9 (two-point identification of the ceiling).** If $V>0$ and $0<m_1<m_2$, then

$$\frac1{\operatorname{ceil}}=\frac{m_2/R^2(m_2)-m_1/R^2(m_1)}{m_2-m_1}.$$

*Proof.* By Theorem 6.4, $m/R^2(m)=m(1+F/V)+\sigma/V$. This is affine in $m$ with slope $1+F/V=1/\operatorname{ceil}$. The difference quotient of an affine function is its slope. $\square$

---

## 7. The reported cell: $u=2.5$, bit length $48$

Take $R^2(80)=0.41$ and $R^2(240)=0.60$, and assume Model 6.1 with $V>0$ and $F,\sigma\ge0$.

**Theorem 7.1 (a structural floor is forced).** Under these data, $F>0$.

*Proof.* Apply Theorem 6.8(2) with $m=80$ and $k=3$. Compute $\operatorname{SB}(3,0.41)=1.23/1.82\approx0.6758$, which is strictly greater than $0.60=R^2(240)$. Hence $F>0$. $\square$

So pure relation noise cannot explain the rise $0.41\to0.60$. Pure noise would have produced about $0.676$.

**Theorem 7.2 (exact ceiling and noise ratio).** Under these data,

$$\operatorname{ceil}=\frac{82}{105}\approx0.7810,\qquad\frac\sigma V=\frac{3800}{41}\approx92.68.$$

*Proof.* Theorem 6.9 gives $1/\operatorname{ceil}=(240/0.6-80/0.41)/160=(400-8000/41)/160=105/82$. Then Theorem 6.4 at $m=240$ gives $5/3=105/82+(\sigma/V)/240$, so $\sigma/V=240\,(5/3-105/82)=240\cdot 95/246=3800/41$. $\square$

**Theorem 7.3 (threshold for $R^2\ge0.70$).** For $m>0$,

$$R^2(m)\ge0.70\iff m\ge\frac{53200}{85}\approx625.88.$$

Consequently, for integer relation counts $n\ge1$: $R^2(n)\ge0.70\iff n\ge626$.

*Proof.* By Theorems 6.4 and 7.2, $1/R^2(m)=105/82+(3800/41)/m$. The condition $1/R^2\le10/7$ is equivalent to $(3800/41)/m\le10/7-105/82=85/574$, that is, $m\ge(3800/41)(574/85)=53200/85$. Since $625<53200/85<626$, the integer threshold is $626$. $\square$

**Corollary 7.4 (an unreachable target).** For every $m>0$, $R^2(m)<0.79$.

*Proof.* $R^2(m)\le\operatorname{ceil}=82/105\approx 0.781<0.79$. $\square$

| $m$ | 80 | 240 | 600 | 625 | 626 | 1000 | $\infty$ |
|---|---|---|---|---|---|---|---|
| $R^2(m)$ | 0.4100 | 0.6000 | 0.6969 | 0.6999 | 0.7000 | 0.7282 | 0.7810 |

**On the definition of the ceiling.** The ceiling in Definition 6.2 is the asymptotic $R^2$, $\lim_{m\to\infty}R^2(m)$. It is identified from any two cells by Theorem 6.9. Any column labelled "ceiling" but computed under another convention can be compared neither with this quantity nor across cells. That is why such a column was not adopted.

---

## 8. The tropical limit of the dial

Let $\operatorname{supp}(N)$ be a nonempty finite set of integers $\ge2$ for each $N\in\iota$. Put $x_\alpha(N)=\alpha^{-1}\log S_\alpha(N)$ and $t(N)=-\log\min\operatorname{supp}(N)$.

**Lemma 8.1 (pointwise tropical limit).** For each $N$, $x_\alpha(N)\to t(N)$ as $\alpha\to\infty$.

*Proof sketch.* Let $\ell_0=\min\operatorname{supp}(N)$ and $k=|\operatorname{supp}(N)|$. Then $\ell_0^{-\alpha}\le S_\alpha(N)\le k\,\ell_0^{-\alpha}$. Taking $\alpha^{-1}\log$ gives $-\log\ell_0\le x_\alpha(N)\le-\log\ell_0+\alpha^{-1}\log k$. This is the log-sum-exp-to-minimum degeneration: in the min-plus semiring, $\lim_{\alpha\to\infty}\alpha^{-1}\log\sum_j e^{-\alpha a_j}=-\min_j a_j$. $\square$

**Theorem 8.2 (tropical limit of the dial's $R^2$).** Let $y$ be any yield column with $\operatorname{cov}(t,t)\operatorname{cov}(y,y)\ne0$. Then

$$\lim_{\alpha\to\infty}R^2(x_\alpha,y)=R^2(t,y).$$

*Proof.* By Lemma 8.1, $x_\alpha\to t$ in $\mathbb R^\iota$. The maps $x\mapsto\operatorname{cov}(x,y)$ and $x\mapsto\operatorname{cov}(x,x)$ are polynomial, hence continuous. So the numerator $\operatorname{cov}(x_\alpha,y)^2$ and the denominator $\operatorname{cov}(x_\alpha,x_\alpha)\operatorname{cov}(y,y)$ converge. The limit of the denominator is nonzero, so the quotient converges. $\square$

**Interpretation.** The exponent $\alpha$ is a continuous dial. At one end is a smooth footprint summary of all active primes. At the other is the min-plus statistic "logarithm of the smallest active prime". The dial's explanatory power varies continuously all the way to the tropical endpoint, so the endpoint is a legitimate member of the family. Together with Theorem 2.4, this means $R^2$ curves can be compared across $\alpha$ and across bit lengths without any recalibration.

---

## 9. Algorithms

**Algorithm A (two-point reliability fit).** *Input:* $(m_1,R_1)$ and $(m_2,R_2)$ with $0<m_1<m_2$, and a target $R^\ast$.
1. Compute $\gamma=(m_2/R_2-m_1/R_1)/(m_2-m_1)$, so that $\operatorname{ceil}=1/\gamma$.
2. Compute $\nu=m_1(1/R_1-\gamma)$; this is $\sigma/V$.
3. If $\gamma<1$ or $\nu<0$, reject the model (it would need $F<0$ or $\sigma<0$). Otherwise $F/V=\gamma-1\ge0$.
4. If $R^\ast\ge\operatorname{ceil}$, report "unreachable". Otherwise report $m^\ast=\lceil\nu/(1/R^\ast-\gamma)\rceil$.
5. Floor test: if $m_2=km_1$, then $F>0$ if and only if $R_2<\operatorname{SB}(k,R_1)$.

The cost is $O(1)$ arithmetic, and exact rational arithmetic is possible. On $(80,0.41)$ and $(240,0.60)$ with $R^\ast=0.7$, it returns $\operatorname{ceil}=82/105$, $\nu=3800/41$ and $m^\ast=626$.

**Algorithm B (miscalibration diagnosis).** *Input:* slopes $b(m_1)$ and $b(m_2)$ at one bit length. If they are equal (to reporting precision), the attenuation model forces $\sigma=0$, and the deficit $1-b$ is attributed to drift and fixed noise. Otherwise $\sigma>0$. Fitting $1/b(m)=(V+E_0)/(cV)+(\sigma/(cV))/m$, which is again affine in $1/m$, separates the asymptotic slope $cV/(V+E_0)$ from the sampling part.

**Algorithm C (partialled feature test).** Compute $a,b,d$ and the two covariances with $y$ in $O(n)$. Form the residual $r$ of $d(N)$ on the dial. Report $\beta_2=\operatorname{slope}(r,y)$ and the effect-size lower bound $\tau^2/(\tau^2+\mathrm{df})$ for the observed $|t|=\tau$.

**Algorithm D (dial evaluation along $\alpha$).** For each modulus, compute $x_\alpha(N)$ stably as $\alpha^{-1}\bigl(\max_\ell(-\alpha\log\ell)+\log\sum_\ell e^{-\alpha\log\ell-\max}\bigr)$. Compute $R^2(x_\alpha,y)$ on a grid of $\alpha$ values and compare it with the endpoint $R^2(t,y)$. The cost is $O(n\,\bar k)$ per grid point, where $\bar k$ is the mean support size.

---

## 10. Discussion

**What is exact and what is modelled.** Theorems 2.3–2.4, 3.2, 4.1 and 5.2–5.4 are identities about an arbitrary finite sample, subject only to the stated orthogonality conditions. Theorems 3.6 and 6.4–7.3 are exact consequences of explicit one-line models of how noise depends on the relation count. Their empirical force is only as good as those models. The models are falsifiable, and Section 11 proposes tests.

**What failed.** Two plausible claims are false. (i) "Pure relation noise explains $0.41\to0.60$" is refuted by Theorem 7.1, since Spearman–Brown predicts $0.676$. (ii) "$|t|\ge3.92$ at $\mathrm{df}=77$ gives partial $R^2>1/6$" is refuted by the exact threshold $0.16636$.

**Why both the slope and $R^2$ are needed.** By Theorem 2.4 the slope carries scale and $R^2$ does not. By Theorem 4.1, $R^2$ is the slope times the yield reliability. A transfer report that gives only $R^2$ cannot detect drift. A report that gives only the slope cannot separate prediction noise from yield noise. The four in-band slopes together with the $R^2$ growth curve make a complete diagnosis.

---

## 11. Future directions

1. **The 626-relation threshold test.** In the cell $u=2.5$, bit length $48$, rerun at $626$ values per modulus and at $600$. The prediction is $R^2\ge0.70$ at $626$ and $R^2<0.70$ at $600$, up to sampling error. A third value of $m$ tests the affine-reciprocal form of Theorem 6.4.
2. **Scale-drift law.** Conjecture: for every bit length $b\ge52$ the calibration slope does not depend on the relation count, and $\log c(b)$ is linear in $b-44$.
3. **Universal footprint ceiling.** Conjecture: the two-point ceiling $V/(V+F)$ is independent of bit length within $\pm0.03$ for $b\in\{44,48,52,56\}$. That would make the structural floor a property of the dial, not of the scale.
4. **Tropical endpoint dominance.** Conjecture: $\alpha\mapsto R^2(x_\alpha,y)$ is unimodal, and its tropical limit (Theorem 8.2) lies strictly below the interior optimum at every bit length. Simulated examples show this pattern. The question is open for real sieve data.

---

## Appendix: notation

| symbol | meaning |
|---|---|
| $\operatorname{supp}(N)$ | active prime support of $N$ |
| $S_\alpha(N)$ | footprint dial $\sum\ell^{-\alpha}$ |
| $x_\alpha$ | normalised log-dial $\alpha^{-1}\log S_\alpha$ |
| $m$ | relation count (sieve values per modulus) |
| $c$ | scale factor (drift) |
| $V,E,H$ | signal, prediction-noise and yield-noise variances |
| $E_0,\sigma$ | fixed and per-relation prediction noise |
| $F$ | structural residual variance |
| $\operatorname{ceil}$ | $V/(V+F)=\lim_{m\to\infty}R^2(m)$ |
| $d(N)$ | direct divisibility feature |
