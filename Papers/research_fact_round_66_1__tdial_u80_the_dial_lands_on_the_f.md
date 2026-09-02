# The Rapidity Geometry of Confidence Intervals for Correlations, and the Resolution Floor of a Fading Dial

**Author:** Aristotle
**Date:** 2026-09-01

---

## Abstract

A rank-correlation measurement is reported at the largest setting of a monotone experimental ladder: three seeds return Spearman correlations $0.562$, $0.551$, $0.582$, pooling to $0.565$ with a reported $95\%$ interval $[0.542, 0.587]$, against a pre-registered validation floor of $0.55$. All readings clear the floor; one clears it by $+0.001$; every interval reaches below the floor at its lower end.

We develop the exact geometry of the interval, rather than the point estimate, and use it to score the record. Writing $\zeta(r) = \operatorname{artanh} r$ for the rapidity of a correlation and $d(x,y) = (x-y)/(1-xy)$ for the relativistic difference, we prove: (i) $\zeta(x)-\zeta(y) = \zeta(d(x,y))$, so rapidity gaps of correlations are themselves correlations; (ii) a rapidity-symmetric interval of half-width parameter $\tau$ about a reading $r$ is exactly $[d(r,\tau),\,d(r,-\tau)]$, with **width law** $2\tau(1-r^2)/(1-r^2\tau^2)$ and **asymmetry law** — the lower arm exceeds the upper by exactly $2r\tau^2(1-r^2)/(1-r^2\tau^2)$, strictly positive at any positive reading; (iii) a **certification criterion** in closed form, $\tau \le d(r,f)$; and (iv) the **resolution law**: with Fisher half-width $z/\sqrt{n-3}$, a floor $f$ is certified if and only if $n \ge 3 + \big(z/(\zeta(r)-\zeta(f))\big)^2$.

We further prove that rapidity is *canonical*: it is the unique coordinate, up to affine change, in which the interval half-width does not depend on the reading, being the unique solution family of the variance-stabilisation equation $g'(x)(1-x^2)=c$.

Applying the machinery: the reported interval is reproduced to better than $6\times10^{-4}$ by a single rapidity half-width parameter $\tau=0.033$ and by no correlation-symmetric interval; the experiment therefore carries between $3400$ and $3650$ effective paired draws; certifying the pooled reading over the floor requires at least $7900$ draws, so the measurement is undersampled by more than a factor of two; the $+0.001$ clearance requires at least $1.8\times 10^{6}$ draws and is statistically empty; and no individual seed certifies the floor, the best one included. A rapidity-linear extrapolation through the two most recent rungs places the floor crossing strictly between settings $82$ and $83$ and the next reading in $(0.543, 0.545)$, and certifying that drop would cost at least $74{,}000$ draws — more than twenty times the present budget. All numerical claims reduce, through $\zeta(x)=\tfrac12\log\frac{1+x}{1-x}$, to exact inequalities between rational powers.

**Keywords:** rank correlation, Fisher transformation, rapidity, variance stabilisation, confidence-interval asymmetry, sample-size resolution, hyperbolic geometry, pre-registration.

---

## 1. Introduction

### 1.1 The measurement

Consider an experiment parameterised by a discrete knob $b$ (here: the bit-length of uniformly drawn integers). At each setting one measures the Spearman rank correlation $\rho_T(b)$ between a statistic $T$ of the drawn integer — the number of trailing zeros in its binary expansion — and a downstream *rate*. A validation band $[0.55, 0.85]$ was pre-registered: the dial is said to **hold** at setting $b$ when $\rho_T(b)$ lies in the band.

At the highest uniform setting, $b = 80$, three independent seeds return

| seed | $\rho_T$ |
|---|---|
| A | $0.562$ |
| B | $0.551$ |
| C | $0.582$ |
| pooled | $0.565$, CI $[0.542, 0.587]$ |

Three further facts are recorded: all readings lie inside the band; seed B clears the floor $0.55$ by only $+0.001$; and every reported interval reaches below $0.55$ at its lower end. A secondary comparison — the advantage of $T$ over a plain population-count baseline — persists, with pooled advantage $+0.053$ (interval $[0.030,0.083]$), placing the baseline at $0.512$. The next setting, $b=84$, is announced as a *crossing test*.

### 1.2 The gap this paper fills

Every previous analysis of this ladder has treated the reading as a *point*: attenuation under ties, ceilings induced by parity structure, effects of pooling. But the record's three most consequential statements are all statements about *intervals*: a $+0.001$ margin, a lower end below the floor, and a band decision. No point-estimate analysis can adjudicate any of them.

The missing layer is the geometry of the interval itself — specifically, the exact shape of a *rapidity-symmetric* interval once it is mapped back to correlation coordinates, together with the sample-size cost of resolving a stated margin. This paper builds that layer from first principles, proves it canonical, and applies it.

### 1.3 Summary of contributions

1. **Rapidity algebra** (§3): the identity $\zeta(x)-\zeta(y)=\zeta(d(x,y))$, and the domination $x \le \zeta(x)$.
2. **Interval geometry** (§4): endpoint formulae, width law, asymmetry law, and closed-form certification criterion.
3. **Resolution law** (§5): an exact iff-characterisation of the sample size needed to certify a floor, plus the quadratic cost-scaling law.
4. **Canonicity** (§6): rapidity is the unique variance-stabilising coordinate up to affine change.
5. **Scoring the record** (§7): effective sample size, undersampling factor, the emptiness of the $+0.001$ clearance, and the failure of every seed to certify.
6. **Parity in the natural coordinate** (§8) and **the crossing prediction** (§9), together with the pricing of the announced crossing test.
7. **The identifiability barrier** (§10): the last-decidable-rung phenomenon.

---

## 2. Definitions

Throughout, correlations live in the open interval $(-1,1)$.

**Definition 2.1 (Rapidity).** For $x\in(-1,1)$, the *rapidity* of $x$ is
$$\zeta(x) \;=\; \operatorname{artanh} x \;=\; \tfrac12\log\frac{1+x}{1-x},$$
with inverse $x = \tanh\zeta$. Equivalently $2\zeta(x) = \log\frac{1+x}{1-x}$; this doubled form is the computational workhorse, because it turns a rapidity into the logarithm of a rational number whenever $x$ is rational.

**Definition 2.2 (Relativistic difference).** For $x,y\in(-1,1)$,
$$d(x,y) \;=\; \frac{x-y}{1-xy}.$$

This is the velocity-subtraction law of special relativity with $c=1$.

**Definition 2.3 (Rapidity-symmetric interval).** Let $r\in(-1,1)$ be a reading and $h>0$ a rapidity half-width; put $\tau=\tanh h\in(0,1)$. The associated interval is
$$I(r,\tau) \;=\; \big[\,L(r,\tau),\ U(r,\tau)\,\big],\qquad L(r,\tau)=\frac{r-\tau}{1-r\tau},\quad U(r,\tau)=\frac{r+\tau}{1+r\tau}.$$

**Definition 2.4 (Fisher half-width and required samples).** At confidence multiplier $z>0$ and effective sample size $n>3$,
$$h(z,n) = \frac{z}{\sqrt{n-3}},\qquad\text{and for a margin } M>0,\qquad N(z,M) = 3 + \left(\frac{z}{M}\right)^{2}.$$

**Definition 2.5 (Certification).** A measurement with reading $r$ and half-width parameter $\tau$ *certifies* the floor $f$ when $f\le L(r,\tau)$; it *certifies a drop below* the ceiling $f$ when $U(r,\tau)\le f$.

**Definition 2.6 (Rapidity-linear model).** Given two rungs $(b_1,r_1)$, $(b_2,r_2)$, the model reading at $b$ is
$$\widehat{r}(b) = \tanh\!\Big(\zeta(r_1) + \tfrac{b-b_1}{b_2-b_1}\big(\zeta(r_2)-\zeta(r_1)\big)\Big),$$
and the *crossing setting* for a floor $f$ is
$$b^{*} = b_1 + \frac{(\zeta(r_1)-\zeta(f))(b_2-b_1)}{\zeta(r_1)-\zeta(r_2)}.$$

---

## 3. Rapidity algebra

**Lemma 3.1 (Logarithmic form).** For $-1<x<1$, $\ \zeta(x)=\tfrac12\big(\log(1+x)-\log(1-x)\big)$, and $2\zeta(x)=\log\frac{1+x}{1-x}$.

*Proof sketch.* Immediate from $\operatorname{artanh} x = \log\sqrt{(1+x)/(1-x)}$ and the logarithm laws, both denominators being positive. $\square$

**Lemma 3.2 (Range of the relativistic difference).** If $x,y\in(-1,1)$ then $1-xy>0$ and $d(x,y)\in(-1,1)$; moreover $d(x,y)>0$ iff $y<x$.

*Proof sketch.* Positivity of $1-xy$ follows since $|xy|<1$. For the range, $d(x,y)<1$ is equivalent to $x-y<1-xy$, i.e. $(1+y)(1-x)>0$; similarly $d(x,y)>-1$ is $(1-y)(1+x)>0$. $\square$

**Theorem 3.3 (Rapidity differences are correlations).** For all $x,y\in(-1,1)$,
$$\zeta(x)-\zeta(y)=\zeta\big(d(x,y)\big).$$

*Proof sketch.* Compute $1+d(x,y)=\dfrac{(1+x)(1-y)}{1-xy}$ and $1-d(x,y)=\dfrac{(1-x)(1+y)}{1-xy}$. Substituting into the logarithmic form of Lemma 3.1 and splitting the logarithms of products and quotients (every factor being positive) yields the identity after cancellation of $\log(1-xy)$. $\square$

This is the structural heart of the paper: **the rapidity coordinate converts relativistic subtraction of correlations into ordinary subtraction.** Consequently, every statement about differences of rapidities is equivalently a statement about a single correlation, $d(x,y)$ — which is what makes closed-form criteria possible.

**Lemma 3.4 (Elementary two-sided bounds).** For $0\le x<1$,
$$\frac{x(2+x)}{2(1+x)} \;\le\; \zeta(x) \;\le\; \frac{x(2-x)}{2(1-x)}.$$

*Proof sketch.* Both follow from $\log t \le t-1$ ($t>0$) alone. For the upper bound, apply it at $t=1+x$ to get $\log(1+x)\le x$, and at $t=1/(1-x)$ to get $-\log(1-x)\le x/(1-x)$; halve the sum. For the lower bound, apply it at $t=1/(1+x)$ to get $x/(1+x)\le\log(1+x)$, and at $t=1-x$ to get $\log(1-x)\le -x$; halve the sum. $\square$

These bounds are the numerical engine: they turn every rapidity claim about a rational reading into a rational inequality, which can then be decided exactly.

**Proposition 3.5 (Rapidity dominates correlation).** For $0\le x<1$, $\ x\le \zeta(x)$.

*Proof sketch.* The crude bounds of Lemma 3.4 are provably too weak here: the gap $\zeta(x)-x = x^3/3 + O(x^5)$ is cubic, while $\log t\le t-1$ is only first-order accurate. Instead consider $g(t)=\log(1+t)-\log(1-t)-2t$ on $(-1,1)$. Then
$$g'(t) = \frac{1}{1+t}+\frac{1}{1-t}-2 = \frac{2t^2}{1-t^2}\ \ge\ 0,$$
so $g$ is monotone on $[0,x]$; with $g(0)=0$ this gives $g(x)\ge 0$, i.e. $2\zeta(x)\ge 2x$. $\square$

*Remark.* This is not a technicality but a structural fact: variance stabilisation is a genuinely analytic phenomenon, not an algebraic one. No first-order comparison of logarithms can deliver the sharp inequality.

**Corollary 3.6 (Rapidity never deflates an advantage).** For $0\le b\le a<1$,
$$a-b \;\le\; \zeta(a)-\zeta(b).$$

*Proof sketch.* By Theorem 3.3 the right side is $\zeta(d(a,b))$, and by Proposition 3.5 that is at least $d(a,b)$. Finally $d(a,b) = (a-b)/(1-ab)\ge a-b$ since $0<1-ab\le 1$. $\square$

---

## 4. The geometry of a rapidity-symmetric interval

**Proposition 4.1 (Endpoints are back-transforms).** For $r,\tau\in(-1,1)$,
$$L(r,\tau) = \tanh\big(\zeta(r)-\zeta(\tau)\big),\qquad U(r,\tau) = \tanh\big(\zeta(r)+\zeta(\tau)\big).$$

*Proof sketch.* $L(r,\tau)=d(r,\tau)$ by definition; apply Theorem 3.3 and $\tanh\circ\zeta=\mathrm{id}$. For $U$, note $U(r,\tau)=d(r,-\tau)$ and $\zeta(-\tau)=-\zeta(\tau)$ (oddness, immediate from the logarithmic form). $\square$

So $I(r,\tau)$ really is "step $\pm\,\zeta(\tau)$ in rapidity, then map back". Everything else is algebra on the two rational expressions.

**Theorem 4.2 (Width law).** For $r,\tau\in(-1,1)$,
$$U(r,\tau)-L(r,\tau) \;=\; \frac{2\tau\,(1-r^{2})}{1-r^{2}\tau^{2}}.$$

*Proof sketch.* Put both endpoints over the common denominator $(1+r\tau)(1-r\tau)=1-r^2\tau^2$, which is positive; the numerator simplifies to $2\tau(1-r^2)$. $\square$

The factor $1-r^2$ is the familiar compression of correlation intervals near the endpoints $\pm1$; the correction $1/(1-r^2\tau^2)$ is the exact second-order term, usually discarded in textbook approximations.

**Theorem 4.3 (Asymmetry law).** For $r,\tau\in(-1,1)$, the lower arm minus the upper arm is exactly
$$\big(r - L(r,\tau)\big) - \big(U(r,\tau) - r\big) \;=\; \frac{2r\,\tau^{2}\,(1-r^{2})}{1-r^{2}\tau^{2}}.$$

*Proof sketch.* Same common denominator; the numerator collects to $2r\tau^2(1-r^2)$. $\square$

**Corollary 4.4 (A positive reading always dips further down than up).** If $0<r<1$ and $0<\tau<1$, then $U(r,\tau)-r < r-L(r,\tau)$.

*Proof sketch.* In Theorem 4.3 the numerator $2r\tau^2(1-r^2)$ is strictly positive and the denominator $1-r^2\tau^2$ is positive. $\square$

**Interpretation.** The record's observation that "every interval dips below the floor at its lower end" is *forced geometry*. Given a positive reading and the standard interval construction, the lower arm is always the longer one; whether it crosses a particular floor is then determined entirely by the point estimate and the half-width. The observation contains no information about the dial beyond what the point estimate already carries.

**Theorem 4.5 (Certification criterion).** Let $r\in(-1,1)$, $\tau\in(-1,1)$, and $f\in[0,1)$. Then
$$f \le L(r,\tau) \iff \tau \le d(r,f).$$

*Proof sketch.* Both $1-r\tau$ and $1-rf$ are positive (Lemma 3.2), so both inequalities may be cleared of denominators; each reduces to $\tau(1-rf)\le (r-f)(1-r\tau)$ after expansion, i.e. to $\tau - \tau r f \le r - f - r^2\tau + r f\tau$, and the two clearings produce the same polynomial inequality. $\square$

**Theorem 4.6 (Mirror criterion for a ceiling).** Let $r\in(-1,1)$, $0\le \tau<1$, $f\in(-1,1)$. Then
$$U(r,\tau) \le f \iff \tau \le d(f,r).$$

*Proof sketch.* Identical algebra with the roles of the arguments reversed. $\square$

Thus **certifying a drop below a level costs precisely the same rapidity margin as certifying a clearance above it** — the cost calculus is direction-symmetric, which is exactly what one needs to price a crossing test.

---

## 5. The resolution law

**Lemma 5.1 (Half-width versus sample size).** For $z>0$, $n>3$, $M>0$,
$$h(z,n)\le M \iff N(z,M)\le n.$$

*Proof sketch.* $z/\sqrt{n-3}\le M \iff z/M \le \sqrt{n-3} \iff (z/M)^2 \le n-3$, using positivity throughout and squaring a nonnegative inequality. $\square$

**Theorem 5.2 (Resolution law).** Let $z>0$, $n>3$, and $0\le f< r<1$. With $\tau=\tanh h(z,n)$,
$$f \le L(r,\tau) \iff n \;\ge\; 3+\left(\frac{z}{\zeta(r)-\zeta(f)}\right)^{2}.$$

*Proof sketch.* By Theorem 4.5, the left side is $\tau\le d(r,f)$. Since $\tanh$ and $\zeta$ are inverse strictly increasing bijections between $\mathbb{R}$ and $(-1,1)$, this is equivalent to $h(z,n)\le \zeta(d(r,f))$, which by Theorem 3.3 equals $\zeta(r)-\zeta(f)$. Apply Lemma 5.1 with $M=\zeta(r)-\zeta(f)>0$. $\square$

**Corollary 5.3 (Quadratic cost law).** For $M\ne 0$ and any $k$, $\ N(z,M/k)-3 = k^{2}\,(N(z,M)-3)$; and $N(z,\cdot)$ is strictly decreasing on $(0,\infty)$.

*Proof sketch.* Direct algebra for the first; monotonicity of $M\mapsto (z/M)^2$ for the second. $\square$

The resolution law is a dictionary. On the left is an experimental verdict — "the interval clears the floor". On the right is a single number, the *rapidity margin*, squared and inverted. Everything about the difficulty of a certification is contained in that margin; nothing else about the data matters.

---

## 6. Canonicity: rapidity is the only stabilising coordinate

A reader may object that all quantitative conclusions are drawn in the coordinate $\zeta$, and that a different coordinate would tell a different story. It would not, and here is the reason.

A sample correlation from $n$ paired draws has asymptotic variance $(1-\rho^2)^2/n$. Under a smooth reparameterisation $g$, the delta method gives asymptotic variance $g'(\rho)^2(1-\rho^2)^2/n$. Demanding that this be free of $\rho$ — which is precisely the condition making an interval half-width reading-independent — is the ordinary differential equation
$$g'(x)\,(1-x^{2}) = c, \qquad x\in(-1,1).$$

**Lemma 6.1 (Derivative of rapidity).** For $x\in(-1,1)$, $\ \zeta'(x)=\dfrac{1}{1-x^{2}}$.

*Proof sketch.* Differentiate $\tfrac12(\log(1+x)-\log(1-x))$, valid on a neighbourhood of $x$ inside $(-1,1)$, obtaining $\tfrac12\big(\tfrac{1}{1+x}+\tfrac{1}{1-x}\big) = \tfrac{1}{1-x^2}$. $\square$

**Theorem 6.2 (Canonicity of rapidity).** Suppose $g$ is differentiable on $(-1,1)$ with $g'(x)=c/(1-x^{2})$ there. Then $g(x)=c\,\zeta(x)+g(0)$ for all $x\in(-1,1)$.

*Proof sketch.* Set $h(t)=g(t)-c\,\zeta(t)$. By Lemma 6.1, $h'\equiv 0$ on the convex open set $(-1,1)$, hence $h$ is constant there; evaluating at $0$ (where $\zeta(0)=0$) gives $h\equiv g(0)$. $\square$

**Corollary 6.3 (Two-way form).** $g$ satisfies $g'(x)=c/(1-x^2)$ on $(-1,1)$ if and only if there is $b\in\mathbb{R}$ with $g(x)=c\,\zeta(x)+b$ on $(-1,1)$.

**Consequence.** Rapidity is not one convenient chart among many: it is the *unique* chart, up to affine change, in which the width of an interval is not a function of the thing being measured. Any competing coordinate reintroduces exactly the pathology that motivated the transformation. The verdicts of §7 are therefore coordinate-free in the only sense that matters.

---

## 7. Scoring the record

We now instantiate. Set $z=1.96$ (the $95\%$ normal multiplier used by the reporting procedure), $f=0.55$ (floor), $r_{\text{pool}}=0.565$, and seed readings $r_A=0.562$, $r_B=0.551$, $r_C=0.582$.

**Proposition 7.1 (Band membership; pooling consistency).** All three seed readings and the pooled reading lie strictly inside $[0.55, 0.85]$, and the pooled reading equals the arithmetic mean of the three seeds to within $10^{-4}$.

*Proof sketch.* Direct rational arithmetic; $(0.562+0.551+0.582)/3 = 0.565$ exactly. $\square$

**Theorem 7.2 (The reported interval is rapidity-symmetric).** With $\tau = 0.033$,
$$\Big|L(0.565,\ 0.033) - 0.542\Big| < 6\times10^{-4}, \qquad \Big|U(0.565,\ 0.033) - 0.587\Big| < 6\times10^{-4}.$$

*Proof sketch.* $L = (0.565-0.033)/(1-0.565\cdot0.033) = 0.542107\ldots$ and $U=(0.565+0.033)/(1+0.565\cdot 0.033) = 0.587054\ldots$; both are exact rational evaluations. $\square$

That is: to the three decimals reported, the interval is exactly the back-transform of a symmetric rapidity interval of half-width parameter $0.033$.

**Proposition 7.3 (No correlation-symmetric interval matches).** $U(0.565,0.033)-0.565 < 0.565-L(0.565,0.033)$, and $L(0.565,0.033)<0.55$.

*Proof sketch.* Corollary 4.4 with $r=0.565>0$, $\tau=0.033>0$; the arm gap is $2(0.565)(0.033)^2(1-0.565^2)/(1-0.565^2 0.033^2) \approx 8.4\times10^{-4}$. The dip below the floor is direct arithmetic. $\square$

**Theorem 7.4 (Effective sample size).** The effective number of paired draws carried by the reported interval, $N(1.96,\ \zeta(0.033))$, satisfies
$$3400 \;\le\; n_{\text{eff}} \;\le\; 3650.$$

*Proof sketch.* Apply the two-sided bounds of Lemma 3.4 at $x=0.033$: $\zeta(0.033)\in[0.0329\ldots, 0.0330\ldots]$, and monotonicity of $N(z,\cdot)$ transfers these to bounds on $3+(1.96/\zeta(0.033))^2$. The true value is $\approx 3528$. $\square$

Note that no external record of the sample size is needed: the interval itself reveals it.

**Theorem 7.5 (The pooled reading is undersampled).** Certifying $f=0.55$ from $r=0.565$ requires
$$n \;\ge\; N\big(1.96,\ \zeta(0.565)-\zeta(0.55)\big) \;\ge\; 7900,$$
hence $2\,n_{\text{eff}} < 7900 \le n_{\text{required}}$: the measurement is short by more than a factor of two.

*Proof sketch.* By Theorem 3.3 the margin equals $\zeta(d(0.565,0.55))$ with $d(0.565,0.55)=0.015/(1-0.31075)=0.021756\ldots$; the upper bound of Lemma 3.4 gives $\zeta(d)\le 0.022$ (approximately), whence $N \ge 3+(1.96/0.022)^2 > 7900$. The exact value is $\approx 8112$. Combine with Theorem 7.4. $\square$

**Theorem 7.6 (The $+0.001$ clearance is statistically empty).** Certifying $f=0.55$ from $r_B=0.551$ requires
$$n \;\ge\; 1.8\times 10^{6}.$$

*Proof sketch.* $d(0.551,0.55) = 0.001/(1-0.30305) = 0.0014349\ldots$; the upper bound of Lemma 3.4 keeps $\zeta(d)$ below $0.001435$, so $N \ge 3+(1.96/0.001435)^2 > 1.8\times10^{6}$. The exact value is $\approx 1.866\times 10^{6}$. $\square$

Against a per-seed budget of about $1200$ draws, this is three orders of magnitude of shortfall. The clearance is not disconfirmed; it is invisible.

**Theorem 7.7 (No seed certifies the floor).** With each seed carrying at most $n_{\text{eff}}/3 \le 1217$ draws,
$$\frac{n_{\text{eff}}}{3} \;<\; N\big(1.96,\ \zeta(r_s)-\zeta(0.55)\big)\qquad\text{for } s\in\{A,B,C\}.$$

*Proof sketch.* The three required sizes admit rigorous lower bounds $12{,}500$, $1.8\times10^6$, and $1650$ respectively (exact values $\approx 12{,}735$, $1.866\times10^6$, $1735$), each exceeding $1217$. $\square$

The best seed, $0.582$, fails by a factor of about $1.4$; the others by factors of $10$ and $1500$.

**Discussion.** The record's claim, "the dial holds at bitlen 80", is a claim about a point estimate lying in a band. In the vocabulary developed here the substantive version reads: *the certification set of the measurement contains the floor*. At the U80 budget it does not — for any seed, and not for the pool.

---

## 8. Count parity in the natural coordinate

The record also states a secondary result: the statistic $T$ beats a population-count baseline by a pooled $+0.053$ (interval $[0.030, 0.083]$), placing the baseline at $0.512$.

**Theorem 8.1 (Rapidity inflates the advantage).**
$$\zeta(0.565)-\zeta(0.512) \;\ge\; 0.0745.$$

*Proof sketch.* By Theorem 3.3 the left side is $\zeta(d)$ with $d = 0.053/(1-0.28928) = 0.074574\ldots$, and by Proposition 3.5 $\zeta(d)\ge d > 0.0745$. The exact value is $0.07471$. $\square$

So the raw advantage of $+0.053$ becomes at least $+0.0745$ in the canonical coordinate: an inflation of about $40\%$. The parity effect is *stronger*, not weaker, once measured properly.

**Theorem 8.2 (But the advantage still fades).** At the much lower setting $b=44$, the corresponding pair of readings was $0.78$ against a $0.71$ baseline, and
$$1.8\cdot\big(\zeta(0.565)-\zeta(0.512)\big) \;<\; \zeta(0.78)-\zeta(0.71).$$

*Proof sketch.* Upper-bound the left factor by $\zeta(d(0.565,0.512)) \le 0.0776$ via Lemma 3.4; lower-bound the right side by $\zeta(d(0.78,0.71)) \ge 0.1462$, again by Lemma 3.4 applied to $d(0.78,0.71) = 0.07/(1-0.5538)=0.15688\ldots$. Then $1.8\times0.0776 = 0.1397 < 0.1462$. Exact values: $0.0747$ and $0.1582$. $\square$

The fade of the parity advantage across the ladder is therefore a genuine phenomenon and not an artefact of reading correlations on a compressive scale — a distinction that only a coordinate-free treatment can draw.

---

## 9. The crossing prediction, and what the crossing test costs

The two most recent uniform rungs are $(b_1,r_1)=(72,\ 0.605)$ and $(b_2,r_2)=(80,\ 0.565)$.

**Lemma 9.1 (Rational reduction).** Using $2\zeta(x)=\log\frac{1+x}{1-x}$:
$$2\big(\zeta(0.605)-\zeta(0.565)\big) = \log\tfrac{27927}{24727},\quad 2\big(\zeta(0.565)-\zeta(0.55)\big) = \log\tfrac{939}{899},\quad 2\big(\zeta(0.605)-\zeta(0.55)\big) = \log\tfrac{2889}{2449}.$$

*Proof sketch.* $\frac{1+0.605}{1-0.605} = \frac{321}{79}$, $\frac{1+0.565}{1-0.565} = \frac{313}{87}$, $\frac{1+0.55}{1-0.55}=\frac{31}{9}$; take quotients and use $\log(a/b)=\log a-\log b$. $\square$

Because $\log$ is strictly increasing, *any* linear inequality with integer coefficients between these rapidity gaps is exactly equivalent to an inequality between products of rational powers. This is what makes an extrapolation of a rank correlation an arithmetic statement.

**Theorem 9.2 (The floor is crossed between settings 82 and 83).**
$$82 \;<\; b^{*} \;<\; 83,$$
where $b^{*} = 72 + \dfrac{8\,(\zeta(0.605)-\zeta(0.55))}{\zeta(0.605)-\zeta(0.565)}$.

*Proof sketch.* The two bounds are, after clearing the (positive) denominator, the linear inequalities
$$10\,(\zeta(0.605)-\zeta(0.565)) < 8\,(\zeta(0.605)-\zeta(0.55)) < 11\,(\zeta(0.605)-\zeta(0.565)),$$
which by Lemma 9.1 are exactly
$$\left(\tfrac{27927}{24727}\right)^{5} < \left(\tfrac{2889}{2449}\right)^{4} \quad\text{and}\quad \left(\tfrac{2889}{2449}\right)^{8} < \left(\tfrac{27927}{24727}\right)^{11}.$$
Both are decided by exact rational arithmetic. Numerically $b^{*}\approx 82.86$. $\square$

**Theorem 9.3 (The predicted reading at setting 84).**
$$0.543 \;<\; \widehat{r}(84) \;<\; 0.545,$$
in particular $\widehat{r}(84) < 0.55$.

*Proof sketch.* $\widehat{r}(84)=\tanh\big(\zeta(0.605)+\tfrac{12}{8}(\zeta(0.565)-\zeta(0.605))\big)$. Since $\tanh$ is strictly increasing, it suffices to compare the rapidity argument with $\zeta(0.543)$ and $\zeta(0.545)$. Doubling and using $\frac{1+0.543}{1-0.543}=\frac{1543}{457}$, $\frac{1+0.545}{1-0.545}=\frac{309}{91}$, the two comparisons become the rational inequalities
$$\left(\tfrac{1543}{457}\right)^{2}\cdot\tfrac{321}{79} < \left(\tfrac{313}{87}\right)^{3} \quad\text{and}\quad \left(\tfrac{313}{87}\right)^{3} < \left(\tfrac{309}{91}\right)^{2}\cdot\tfrac{321}{79}.$$
Numerically $\widehat r(84)\approx 0.54393$. $\square$

**Theorem 9.4 (Discrete crossing, no continuity assumed).** Let $(w_k)$ be a rapidity ladder with $w_{k+1}\le w_k - \delta$ for a fixed $\delta>0$. Then $w_k \le w_0 - k\delta$ for all $k$, and hence $w_k\le L$ whenever $k \ge (w_0-L)/\delta$. Applying this with $w_0 = \zeta(0.565)$ and $\delta = \zeta(0.605)-\zeta(0.565)$ (the observed one-rung fade),
$$w_1 \;<\; \zeta(0.55).$$

*Proof sketch.* The linear-decay bound is induction on $k$. For the application, $w_1 \le 2\zeta(0.565)-\zeta(0.605)$, and the required strict inequality $2\zeta(0.565)-\zeta(0.605)<\zeta(0.55)$ is, after doubling and exponentiating, precisely
$$\left(\tfrac{313}{87}\right)^{2} < \tfrac{31}{9}\cdot\tfrac{321}{79}.$$
$\square$

Thus **one further 8-bit rung at the observed fade rate already puts the dial below the floor**, and this conclusion requires no assumption that the reading varies continuously in the setting.

**Theorem 9.5 (Pricing the crossing test).** Certifying that the reading has dropped below $0.55$ requires
$$n \ge 38{,}000 \ \text{ at the optimistic end } 0.543, \qquad n \ge 74{,}000 \ \text{ at the conservative end } 0.545 .$$
Consequently $20\,n_{\text{eff}} < n_{\text{required}}$.

*Proof sketch.* By Theorem 4.6 the cost is $N(1.96, \zeta(0.55)-\zeta(\hat r))$, with $\hat r\in\{0.543,0.545\}$; bound the rapidity margins above using Lemma 3.4 applied to $d(0.55, \hat r)$ and invoke monotonicity of $N$. Exact values: $\approx 38{,}600$ and $\approx 75{,}300$. Combine with $n_{\text{eff}}\le 3650$. $\square$

**Conclusion.** Run at the present budget, the announced crossing test cannot be decisive whatever it returns. A reading of $0.544$ with $3500$ draws is compatible both with a dial that has crossed and with a dial that has not.

---

## 10. The identifiability barrier

The preceding sections combine into a general principle.

Suppose a dial fades approximately linearly in rapidity in the setting $b$: $\zeta(\rho(b)) \approx \zeta_0 - \lambda (b-b_0)$ with $\lambda>0$. Then relative to a fixed floor $f$ the *margin*
$$M(b) = \zeta(\rho(b)) - \zeta(f)$$
shrinks linearly in $b$, while by Corollary 5.3 the cost of resolving it grows as $M(b)^{-2}$. Setting the cost equal to a budget $N$ and solving,

$$M \ge \frac{z}{\sqrt{N-3}} \iff b \le b_{\max}(N) := b_0 + \frac{1}{\lambda}\Big(\zeta_0-\zeta(f) - \frac{z}{\sqrt{N-3}}\Big).$$

Two readings of this formula.

1. **There is a last decidable rung.** For each budget $N$ there is a largest setting at which any classification of the dial relative to the floor is possible. Beyond it, an experiment of size $N$ returns readings whose certification sets simply do not contain the floor, regardless of which side of it the truth lies on.
2. **Buying data barely helps.** $b_{\max}$ grows only like $\log N$ if one insists on a fixed number of *further* decidable rungs — more precisely, extending the decidable range by one rung of size $\Delta$ requires multiplying $N$ by a factor that itself grows without bound as the margin approaches zero, since the cost scales as the inverse square of a linearly-shrinking quantity. Concretely: on this ladder the pooled margin fell from $\approx 0.0616$ in rapidity at setting $72$ to $\approx 0.0208$ at setting $80$, a factor of $3$, which by the quadratic cost law multiplied the certification cost by $9$.

The U80 cell is the first on this ladder where the barrier is the dominant effect rather than a distant worry: one measured margin ($+0.001$ raw, $\approx 0.00143$ in rapidity) is smaller than the experiment's own resolution ($\approx 0.033$) by more than a factor of $20$, and smaller than what the budget could resolve by three orders of magnitude in sample size.

---

## 11. Algorithms

We record the three computational primitives, all of which run in $O(1)$ arithmetic operations per call.

**Algorithm A — Interval reconstruction.** *Input:* reported endpoints $(\ell, u)$. *Output:* the reading $r$ and half-width parameter $\tau$ of the unique rapidity-symmetric interval with those endpoints, plus the implied effective sample size.
Set $\zeta_\ell = \operatorname{artanh}\ell$, $\zeta_u = \operatorname{artanh} u$, $r = \tanh\frac{\zeta_\ell+\zeta_u}{2}$, $\tau = \tanh\frac{\zeta_u-\zeta_\ell}{2}$, $n = 3 + \big(2z/(\zeta_u-\zeta_\ell)\big)^2$. Correctness is Proposition 4.1: the rapidity midpoint and half-gap invert the construction exactly.

**Algorithm B — Certification test.** *Input:* $r$, $\tau$, floor $f$. *Output:* certified or not, with the shortfall. Compute $g = d(r,f)$; certified iff $\tau \le g$ (Theorem 4.5); the shortfall factor is $\big(\operatorname{artanh}\tau / \operatorname{artanh} g\big)^2$, the multiple by which $n$ must grow (Corollary 5.3).

**Algorithm C — Ladder extrapolation and crossing.** *Input:* two rungs $(b_1,r_1)$, $(b_2,r_2)$, floor $f$, target $b$. *Output:* $\widehat r(b)$ and $b^*$ by Definition 2.6. Exactness: for rational readings, all comparisons reduce via Lemma 9.1 to comparisons of products of rational powers with integer exponents, which can be settled in exact arithmetic.

---

## 12. Applications beyond this ladder

The results are not specific to trailing-zero statistics.

- **Reporting practice.** Any report of a correlation with an asymmetric interval implicitly declares a rapidity half-width; Algorithm A extracts it, and with it the effective sample size, even when the latter is not stated. Interval asymmetry should never be reported as a finding: by Corollary 4.4 it is forced.
- **Pre-registration design.** Before running an experiment against a floor $f$, the resolution law converts the smallest scientifically interesting reading $r$ into the required $n$. Designs that cannot meet $3+(z/(\zeta(r)-\zeta(f)))^2$ should not be run against that floor.
- **Meta-analysis.** Because rapidity gaps are themselves correlations (Theorem 3.3), differences between studies can be reported on the same scale as the studies themselves, and Corollary 3.6 guarantees such reporting never understates an effect relative to raw differences.
- **Monotone-ladder experiments generally.** Any experiment sweeping a parameter toward a decision threshold inherits the last-decidable-rung phenomenon of §10; the budget required grows quadratically in the inverse of a margin that is itself shrinking.

---

## 13. Discussion

Three points deserve emphasis.

**A point estimate cannot support a band decision.** The dominant convention — reading a point estimate against a pre-registered band — is not merely imprecise; at small margins it is empty. The certification-set formulation (Definition 2.5) is the minimum repair, and it is fully computable in closed form.

**Interval asymmetry is not evidence.** Corollary 4.4 makes "the interval dips below the floor" a theorem about positive readings, not an observation about a dial. Reporting it as a caution is harmless; reporting it as information is a category error.

**Coordinates matter, and there is only one right one.** The canonicity theorem (Theorem 6.2) removes the last discretionary element from the analysis. One does not choose to work in rapidity; it is the unique coordinate meeting the requirement that makes intervals interpretable at all.

**A limitation.** The analysis takes the reported interval and multiplier at face value and treats $n_{\text{eff}}$ as the quantity implied by them; genuine effective sample sizes for rank correlations under ties differ from the nominal count, and the constant in the asymptotic variance for Spearman's coefficient differs from the Pearson case by a factor that depends on the underlying copula. These refinements change the constants but not the structure: cost remains the inverse square of a rapidity margin.

---

## 14. Future directions

Two cycles of work were carried out on this record. The first built the geometry of a rapidity-symmetric confidence interval — the exact width law, the asymmetry law, the closed-form certification criterion, and the resolution law $n \ge 3 + (z/(\zeta(r)-\zeta(f)))^2$ — and used it to score the record. The second removed the obvious objection to the first by proving that rapidity is the *only* coordinate in which an interval half-width is reading-independent, then priced the announced crossing test and re-derived the crossing conclusion discretely.

**What survived.** Everything about interval *shape*. The asymmetry law explains a reported qualitative feature ("every interval dips below the floor") with no reference to the dial at all, and the resolution law converts each reported margin into a hard number of draws.

**What failed, instructively.** The elementary route to $\zeta(x)\ge x$ cannot work: the gap is cubic while $\log t \le t-1$ is only first-order accurate. This is the reason variance stabilisation is a genuinely analytic, not algebraic, phenomenon.

**What needs a different definition.** "The dial holds at setting 80" cannot be stated as a property of the point estimate. In the vocabulary built here it becomes: *the certification set of the measurement contains the floor* — and at this budget it does not, for any of the three seeds.

Two conjectures follow.

**Conjecture 1 (The identifiability barrier is quadratic in the fade).** As a monotone dial approaches a pre-registered floor, its rapidity margin shrinks linearly in the setting while the sample size needed to resolve it grows like the inverse square of that margin. There is therefore a *last decidable rung*: a setting $b_{\max}(N)$ beyond which no experiment of size $N$ can classify the dial relative to the floor, with $b_{\max}$ growing only like $\log N$. The present cell is the first in the thread where the measured margin is smaller than the experiment's resolution by three orders of magnitude, so the barrier has become the dominant effect and can be tested against the existing ladder.

**Conjecture 2 (Rapidity-metric geodesy of the ladder).** Once rapidity is known to be the canonical coordinate, the ladder becomes a curve in a one-dimensional hyperbolic metric space, and "the dial fades linearly" is the statement that the ladder is a geodesic parametrised by arclength. Deviations from linearity — the rebound at one higher setting, the deceleration at another — are then *curvature*, a coordinate-free quantity. Every rung of the thread is already recorded, so the curvature of the recorded ladder can be computed and compared against the seed-spread noise.

---

## 15. Conclusion

A correlation is a velocity; rapidity is its proper coordinate, and provably the only one. In that coordinate a confidence interval is a symmetric segment, and mapping it back to correlation space produces two exact laws — a width law and an asymmetry law — that between them account for the qualitative features of the record without reference to the experiment at all. Certification of a floor is then a single inequality between a half-width and a relativistic gap, and its sample-size form is the resolution law: cost is a rapidity margin, squared and inverted.

Applied to the measurement in question, the machinery returns an unambiguous verdict. The experiment carries at most about $3650$ effective draws. It needs at least $7900$ to certify its pooled reading over the floor, at least $12{,}500$ for its strongest seed at the seed-level budget, and at least $1.8$ million for the seed whose $+0.001$ clearance was recorded as a success. Not one of the three seeds certifies the floor. The extrapolation puts the crossing between settings $82$ and $83$ and the next reading in $(0.543, 0.545)$; certifying that drop would cost more than twenty times the present budget.

The dial did not hold at setting 80, and it did not fail. At this budget, it was not measured.
