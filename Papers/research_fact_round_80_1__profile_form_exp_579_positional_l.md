# Profile Form: A Rigidity Law for the Positional Hit Profile and the Structure of its Beyond-Background Residual

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

We study the *positional hit profile* of a factor-search experiment on semiprimes: the density $T(x)$ of recorded hits as a function of a rescaled offset $x$ in a window. Empirically, over $9594$ hits collected from $128$ semiprimes of bit-length $96$, the profile is described by the power law $T(x)\approx 0.0295\,(1+x)^{-1.104}$, with a resampling interval $[0.991,1.218]$ for the exponent and an Akaike weight of $0.987$ against exponential, logistic and linear rivals.

This paper isolates the mathematics behind that empirical verdict, and establishes six groups of results, all independent of the data.

1. **Rigidity.** Equip the shifted half-line with the composition $x\star y=(1+x)(1+y)-1$. Every positive continuous profile satisfying the normalised multiplicativity $T(0)T(x\star y)=T(x)T(y)$ is a power law $T(x)=T(0)(1+x)^{-b}$, and the exponent is identifiable. The empirical "profile form" is therefore a one-parameter law, not a curve-fitting convenience.
2. **Structural model selection.** The *log-midpoint defect* $D_f(t,h)=f(t-h)f(t+h)-f(t)^2$ is strictly positive for every power law with $b>0$ and non-positive for the exponential, logistic and affine families. A single invariant separates the winner from all three rivals simultaneously. Separately, the Akaike weight functional $w(d_1,d_2,d_3)=\bigl(1+\sum_i e^{-d_i/2}\bigr)^{-1}$ is shown to be a probability, monotone in each gap, capped at $1/2$ by any tied rival, saturating at $1$, and $>0.98$ at the measured gaps.
3. **A critical exponent for total mass.** The window mass $\int_0^X (1+x)^{-b}dx$ equals $\bigl((1+X)^{1-b}-1\bigr)/(1-b)$ for $b\neq 1$ and $\log(1+X)$ for $b=1$; it converges to $1/(b-1)$ iff $b>1$ and diverges for $b\le 1$. The measured interval $[0.991,1.218]$ straddles the threshold, so the experiment does not decide finiteness of total mass.
4. **Absorption.** With the uniform scale-mixture background $M(x)=\int_0^1 e^{-xs}ds=(1-e^{-x})/x$, which satisfies $1/(2x)\le M(x)\le 1/x$ for $x\ge 1$, the residual $R=T/M$ obeys the exact squeeze $Ax(1+x)^{-b}\le R(x)\le 2Ax(1+x)^{-b}$ and declines across the window by at most two thirds of the raw decline, uniformly in amplitude and exponent.
5. **A robust interior hump.** The endpoint-pinned concave fits $R_c(x)=\tfrac45+(\tfrac1{10}-c)x+cx^2$ have apex $x_c=(\tfrac1{10}-c)/(-2c)$, which lies in $(1/2,1)$ exactly when $c<-1/10$; for $-1/10\le c<0$ the fit is monotone on the window. The measured curvature interval $[-0.62,-0.14]$ lies entirely on the peaked side, with margin $0.04$. A peaked residual is not of profile form, and certifies that the background is not a power-law rescaling of the profile.
6. **Limits of that certification, and a location law.** A two-atom positive mixture $M_2(x)=\tfrac12 e^{-x/20}+\tfrac12 e^{-8x}$ produces a peaked residual, so a hump is *not* evidence against mixture backgrounds. Moreover the uniform background itself produces a hump for $b=1.1$, near $x=10$: peakedness is window-relative. The location is governed exactly: for $b>1$ the elementary factor $x(1+x)^{-b}$ has the unique maximiser $x^\star=1/(b-1)$, and for $b\le 1$ none. Finally, for every $b\ge 3/2$ the true residual $T/M$ is strictly decreasing on $(0,\infty)$, so a critical exponent for the existence of the hump lies in $(1.1,1.5)$ — a second qualitative threshold straddled by the measured interval.

**Keywords.** positional hit profile, power law, Cauchy functional equation, log-midpoint convexity, Akaike weight, Dickman-type mixture, completely monotone background, critical exponent.

---

## 1. Introduction

### 1.1 The empirical setting

A factor-search procedure applied to a semiprime $N=pq$ sweeps candidate offsets and occasionally records a *hit*. Collecting hits across a corpus of semiprimes and rescaling offsets to a common window produces a *positional hit profile*: a decreasing density $T(x)$, $x\in[0,2]$, with $x=0$ the near end (small offsets; the "small-$j$ wall") and $x=2$ the far end.

The dataset re-analysed here consists of $9594$ hits from $128$ semiprimes of bit-length $96$. Its profile is well fitted by

$$T(x) \;\approx\; 0.0295\,(1+x)^{-1.104}, \tag{1.1}$$

with a cluster-resampling interval $b\in[0.991,\ 1.218]$ for the exponent and an Akaike weight $0.987$ against three one-parameter rivals: an exponential ($\Delta\mathrm{AICc}=+9.2$), a logistic ($+11.5$, in a degenerate configuration) and a line ($+16.9$). The raw decline across the window is a factor $3.25$.

Two questions follow immediately, and this paper answers both in a data-independent way.

* **Why this shape?** Is (1.1) a fit, or is it forced?
* **What is left after the expected background is removed?** Number-theoretic heuristics of Dickman type predict a decline of their own; the measured background falls by $3.64$ where the profile falls by $3.25$. What structure survives the division?

### 1.2 Summary of the answers

The shape is forced, by a scale-composition law (Theorem 2.4). The model-selection verdict is underwritten by a single convexity invariant (Theorems 3.2–3.6), independently of any information criterion, whose own behaviour is characterised in §4. The background absorbs the decline in a strong, quantitative sense (Theorem 5.4). What survives is not a slope but an interior hump, robust across the reported curvature uncertainty (Theorem 6.7), and genuinely outside the profile-form family (Theorem 6.9). Finally §7 records two corrections that sharpen the interpretation, and §8 derives an exact hump-location law together with a critical exponent for the hump's existence.

### 1.3 Notation

Throughout, $b$ denotes an exponent and $A>0$ an amplitude. We write

$$T_{A,b}(x)=A(1+x)^{-b}$$

for the **profile-form** family, defined for $x>-1$. All logarithms are natural. The window on which the residual analysis takes place is normalised to $[0,1]$; the profile itself is fitted on $[0,2]$.

---

## 2. Rigidity: the profile form is a law

### 2.1 The shift-scale group law

**Definition 2.1 (scale composition).** For $x,y>-1$ set
$$x\star y \;=\; (1+x)(1+y)-1 .$$

Then $\star$ is the transport of ordinary multiplication on $(0,\infty)$ through the bijection $x\mapsto 1+x$. It is associative and commutative, has identity $0$, and every $x>-1$ has the inverse $\frac{1}{1+x}-1$. It is the natural composition on positions measured *relatively*: composing offsets multiplies their shifted coordinates.

**Definition 2.2 (scale multiplicativity).** A profile $T:(-1,\infty)\to\mathbb{R}$ is *scale-multiplicative* if
$$T(0)\,T(x\star y) \;=\; T(x)\,T(y) \qquad\text{for all } x,y>-1. \tag{2.1}$$

**Proposition 2.3.** Every profile-form function $T_{A,b}$ is scale-multiplicative.

*Proof.* $1+(x\star y)=(1+x)(1+y)$, and $\bigl((1+x)(1+y)\bigr)^{-b}=(1+x)^{-b}(1+y)^{-b}$ for positive bases. Multiplying by $A^2$ and using $T_{A,b}(0)=A$ gives (2.1). $\square$

### 2.2 The rigidity theorem

**Theorem 2.4 (Rigidity of the profile form).** Let $T:(-1,\infty)\to\mathbb{R}$ be positive, continuous on $(-1,\infty)$, and scale-multiplicative. Then there exists $b\in\mathbb{R}$ such that
$$T(x) \;=\; T(0)\,(1+x)^{-b} \qquad \text{for all } x>-1 .$$

*Proof sketch.* Put $A=T(0)>0$ and reparameterise by $x=e^u-1$, $u\in\mathbb{R}$, which is a bijection onto $(-1,\infty)$ and turns $\star$ into addition:
$$\bigl(1+(e^u-1)\bigr)\bigl(1+(e^v-1)\bigr)-1 = e^{u+v}-1 .$$
Define $g(u)=\log\bigl(T(e^u-1)/A\bigr)$, which is well defined by positivity. Applying (2.1) at $x=e^u-1$, $y=e^v-1$ gives
$$\frac{T(e^{u+v}-1)}{A} \;=\; \frac{T(e^u-1)}{A}\cdot\frac{T(e^v-1)}{A},$$
and taking logarithms yields Cauchy's functional equation $g(u+v)=g(u)+g(v)$. The map $g$ is continuous, being a composition of continuous maps with a logarithm of a positive continuous function. A continuous additive map on $\mathbb{R}$ is $\mathbb{R}$-linear, so $g(u)=u\,g(1)$.

Now let $x>-1$ and set $u=\log(1+x)$, so that $e^u-1=x$. Then $\log(T(x)/A)=\log(1+x)\,g(1)$, i.e.
$$T(x) = A\exp\bigl(g(1)\log(1+x)\bigr) = A(1+x)^{g(1)} = A(1+x)^{-b}, \qquad b:=-g(1). \qquad\square$$

**Remark 2.5.** The three hypotheses are all needed and all physically natural: *positivity* (a hit density), *continuity* (a smoothly varying density; without it Hamel-basis pathologies reappear), and *scale multiplicativity* (relative offsets compose). Note that no differentiability, and no growth condition, is assumed.

**Theorem 2.6 (Identifiability of the exponent).** Let $A>0$. If $T_{A,b}(x)=T_{A,b'}(x)$ for all $x>-1$, then $b=b'$.

*Proof.* Evaluate at $x=1$: $A\,2^{-b}=A\,2^{-b'}$. Cancel $A>0$, take logarithms, and divide by $\log 2\neq 0$. $\square$

Together, Theorems 2.4 and 2.6 say: the positional layer has exactly one degree of freedom beyond amplitude, and the experiment's task is to measure it.

### 2.3 The window decline factor

The scalar most directly comparable with the raw data is the decline of the profile across the fitted window $[0,2]$.

**Definition 2.7.** $\mathrm{DF}(b) = T_{A,b}(0)/T_{A,b}(2) = 3^{\,b}$ (independent of $A>0$).

**Proposition 2.8.** $\mathrm{DF}$ is strictly increasing, and for every $b\in[0.991,1.218]$,
$$2.8 \;<\; \mathrm{DF}(b) \;<\; 4.1 .$$

*Proof sketch.* Strict monotonicity is monotonicity of $b\mapsto 3^b$. For the bracket, use the rigorous enclosure $1.05<\log 3<1.14$, obtained from $e^{1.05}<3<e^{1.14}$ via $e<2.7182818286$, the elementary bound $e^y\le(1-y)^{-1}$ for $y<1$, and $1+y\le e^y$. Then $\mathrm{DF}(b)=e^{b\log 3}$ lies between $e^{0.991\cdot 1.05}=e^{1.0406}>2.8$ and $e^{1.218\cdot1.14}\le e^{1.3886}<4.1$; the last inequality follows from $e^{0.3886}=(e^{0.048575})^8\le(1-0.048575)^{-8}<1.49$. $\square$

The measured raw decline $3.25$ lies inside this bracket, so the fitted exponent interval and the measured decline are mutually consistent — a consistency check the law makes available with no extra fitting.

---

## 3. One invariant separates the winner from all three rivals

Model comparison by information criterion is a statement about a specific dataset. The following is a statement about the *families*.

**Definition 3.1 (log-midpoint defect).** For $f>0$ and $t,h$ with $t\pm h$ in the domain, put
$$D_f(t,h) \;=\; f(t-h)\,f(t+h) - f(t)^2 .$$

$D_f\ge 0$ is midpoint log-convexity; $D_f\le 0$ is midpoint log-concavity.

**Theorem 3.2 (Strict log-convexity of the power law).** Let $A>0$, $b>0$, $h>0$ and $t-h>-1$. Then
$$T_{A,b}(t)^2 \;<\; T_{A,b}(t-h)\,T_{A,b}(t+h),$$
i.e. $D_{T_{A,b}}(t,h)>0$ strictly.

*Proof sketch.* $\bigl(1+(t-h)\bigr)\bigl(1+(t+h)\bigr)=(1+t)^2-h^2<(1+t)^2$, and both sides are positive. Since $-b<0$, the map $s\mapsto s^{-b}$ is strictly decreasing on $(0,\infty)$, whence
$$\bigl((1+t)^2\bigr)^{-b} < \Bigl(\bigl(1+(t-h)\bigr)\bigl(1+(t+h)\bigr)\Bigr)^{-b}.$$
Splitting each side by multiplicativity of $s\mapsto s^{-b}$ and multiplying by $A^2>0$ gives the claim. $\square$

The three rivals go the other way.

**Theorem 3.3 (Exponential family).** For $E_{C,k}(x)=Ce^{-kx}$ one has $D_{E_{C,k}}(t,h)=0$ identically.

*Proof.* $e^{-k(t-h)}e^{-k(t+h)}=e^{-2kt}=\bigl(e^{-kt}\bigr)^2$. $\square$

**Theorem 3.4 (Logistic family).** For $L_{C,k,x_0}(x)=C/\bigl(1+e^{k(x-x_0)}\bigr)$ with $C>0$, $D_{L}(t,h)\le 0$.

*Proof sketch.* Write $u=k(t-x_0)$. The claim reduces to
$$\bigl(1+e^{u}\bigr)^2 \le \bigl(1+e^{u-kh}\bigr)\bigl(1+e^{u+kh}\bigr).$$
Expanding, the cross terms satisfy $e^{u-kh}e^{u+kh}=e^{2u}$ exactly, while $e^{u-kh}+e^{u+kh}=e^u\bigl(e^{-kh}+e^{kh}\bigr)\ge 2e^u$ by AM–GM (equivalently $(e^{kh/2}-e^{-kh/2})^2\ge0$). $\square$

**Theorem 3.5 (Affine family).** For $P_{p,q}(x)=p+qx$ one has the exact identity $D_{P_{p,q}}(t,h)=-q^2h^2\le 0$, with no positivity hypothesis.

*Proof.* $(p+q(t-h))(p+q(t+h))-(p+qt)^2=-q^2h^2$. $\square$

**Theorem 3.6 (Separation).** Let $A>0$ and $b>0$. Then $T_{A,b}$ coincides on $(-1,\infty)$ with no member of the exponential family, no member of the logistic family with $C>0$, and no affine function.

*Proof.* Evaluate at $t=1$, $h=1$: by Theorem 3.2, $T_{A,b}(0)T_{A,b}(2)>T_{A,b}(1)^2$. Each rival satisfies the reverse (non-strict, or equality) inequality at the same triple by Theorems 3.3–3.5. Equality of the functions would give a contradiction. $\square$

**Remark 3.7.** Theorem 3.6 requires no data, no noise model, and no criterion: the winner is *structurally* outside the three rival families. The empirical model comparison and this structural fact are independent lines of evidence pointing the same way — which is exactly the situation in which a model-selection verdict deserves confidence.

---

## 4. What an Akaike weight can and cannot say

Fix a four-model comparison whose best model is at $\Delta\mathrm{AICc}=0$ and whose rivals are at gaps $d_1,d_2,d_3\ge0$.

**Definition 4.1.** $\displaystyle w(d_1,d_2,d_3) = \frac{1}{1+e^{-d_1/2}+e^{-d_2/2}+e^{-d_3/2}}$.

**Theorem 4.2.** For all real $d_1,d_2,d_3$: (i) $w\in(0,1)$; (ii) $w$ is non-decreasing in each argument; (iii) $w(0,d_2,d_3)<1/2$; (iv) $w(d,d,d)\to1$ as $d\to\infty$; (v) if $d\le d_i$ for $i=1,2,3$, then $w\ge \bigl(1+3e^{-d/2}\bigr)^{-1}$.

*Proof sketch.* The denominator exceeds $1$ and each exponential is positive, giving (i). For (ii), increasing $d_i$ decreases $e^{-d_i/2}$, hence increases $w$. For (iii), a tied rival contributes $e^0=1$, so the denominator exceeds $2$. For (iv), each exponential tends to $0$, so the denominator tends to $1$ and $w$ to $1$ by continuity of inversion. (v) is (ii) applied coordinatewise. $\square$

Item (iii) is the point of substance: because a tied rival caps the weight at $1/2$, a weight close to $1$ cannot be manufactured by the normalisation and is genuine evidence that *every* rival was beaten.

**Theorem 4.3 (The measured verdict).** $w(9.2,\ 11.5,\ 16.9) > 0.98$.

*Proof sketch.* Rigorous exponential bounds suffice. From $e>2.7182818283$ one gets $e^4\ge 54.59$. Hence $e^{4.6}=e^4e^{0.6}\ge 54.59\cdot1.6\ge 87$, so $e^{-4.6}\le 1/87\le 0.0115$; $e^{5.75}=e^4e^{1.75}\ge54.59\cdot2.75\ge150$, so $e^{-5.75}\le 0.0067$; and $e^{8}=(e^4)^2\ge 2980$, so $e^{-8.45}\le e^{-8}\le 0.00034$. The denominator is therefore at most $1.01824$, and $w\ge 1/1.01824>0.98$. $\square$

This reproduces the reported weight $0.987$ to the accuracy that elementary rigorous bounds allow.

---

## 5. The exponent-one threshold, and the absorption of the decline

### 5.1 Total window mass

**Definition 5.1.** The (unit-amplitude) *window mass* is $\displaystyle W(b,X)=\int_0^X (1+x)^{-b}\,dx$, for $X\ge0$.

**Theorem 5.2 (Closed form and the critical exponent).** For $X\ge0$:

1. if $b\neq 1$, then $\displaystyle W(b,X)=\frac{(1+X)^{1-b}-1}{1-b}$;
2. $W(1,X)=\log(1+X)$;
3. if $b>1$, then $W(b,X)\to \dfrac{1}{b-1}$ as $X\to\infty$;
4. if $b\le 1$, then $W(b,X)\to\infty$ as $X\to\infty$.

*Proof sketch.* (1) The function $x\mapsto (1+x)^{1-b}/(1-b)$ has derivative $(1+x)^{-b}$ on $[0,X]$, and the integrand is continuous there, so the fundamental theorem of calculus applies. (2) Likewise, $x\mapsto\log(1+x)$ has derivative $(1+x)^{-1}$. (3) For $b>1$, $(1+X)^{1-b}\to0$, so the closed form tends to $(0-1)/(1-b)=1/(b-1)$. (4) For $b=1$ use $\log(1+X)\to\infty$; for $b<1$, $(1+X)^{1-b}\to\infty$ and the denominator $1-b>0$ is a positive constant. $\square$

**Corollary 5.3 (The measurement straddles the threshold).** Within the reported interval $[0.991,\,1.218]$ there exist exponents (e.g. $b=1$) for which $W(b,X)\to\infty$, and exponents (e.g. the point estimate $b=1.104$) for which $W(b,X)$ converges to a finite limit.

Thus the experiment determines the *shape* of the profile sharply while leaving a first-order qualitative question — whether the profile carries finite total mass — completely undecided. A follow-up experiment must therefore be powered to separate $b$ from $1$, not merely to estimate $b$.

The divergence at the critical exponent is not a continuum artefact. Writing the critical profile in counted form gives harmonic weights, and the classical comparison

$$\log(n+1) \;\le\; \sum_{j=0}^{n-1}\frac{1}{j+1}$$

(proved by induction, using $\log\frac{n+2}{n+1}\le\frac{n+2}{n+1}-1=\frac1{n+1}$, itself a case of $\log s \le s-1$) shows that unbounded accumulation is visible already at the level of counted hits.

### 5.2 The uniform scale-mixture background

**Definition 5.4.** The *mixture background* is
$$M(x) \;=\; \int_0^1 e^{-xs}\,ds \;=\; \frac{1-e^{-x}}{x}\qquad (x\neq0),$$
the uniform scale mixture of exponential regimes with rates in $[0,1]$. It is positive for $x>0$.

The integral evaluation follows from $\frac{d}{ds}\bigl(-e^{-xs}/x\bigr)=e^{-xs}$.

**Lemma 5.5 (Exponent-one squeeze).** For $x\ge1$,
$$\frac{1}{2x} \;\le\; M(x) \;\le\; \frac1x .$$

*Proof.* $0<e^{-x}\le e^{-1}\le 1/2$ for $x\ge1$, hence $1/2\le 1-e^{-x}<1$. Divide by $x>0$. $\square$

So $M$ is itself an exponent-one decline, up to a factor $2$ — the same order as the profile's fitted exponent $1.104$. This is why the background can absorb almost all of the raw decline, and the next results make that quantitative.

**Definition 5.6.** The *residual* is $R_{A,b}(x)=T_{A,b}(x)/M(x)$.

**Theorem 5.7 (Absorption bounds).** For $A>0$ and $x\ge1$,
$$A\,x\,(1+x)^{-b} \;\le\; R_{A,b}(x) \;\le\; 2A\,x\,(1+x)^{-b} .$$

*Proof.* Immediate from Lemma 5.5, since $R_{A,b}(x)=A(1+x)^{-b}/M(x)$ and $M>0$. $\square$

**Theorem 5.8 (The background eats the harmonic gradient).** For every $A>0$ and every $b\in\mathbb{R}$,
$$\frac{R_{A,b}(1)}{R_{A,b}(3)} \;\le\; \frac{2}{3}\cdot\frac{T_{A,b}(1)}{T_{A,b}(3)} .$$

*Proof sketch.* By Theorem 5.7, $R_{A,b}(1)\le 2A\cdot 1\cdot 2^{-b}$ and $R_{A,b}(3)\ge A\cdot3\cdot4^{-b}>0$. Dividing,
$$\frac{R_{A,b}(1)}{R_{A,b}(3)} \le \frac{2A\,2^{-b}}{3A\,4^{-b}} = \frac23\cdot\frac{A2^{-b}}{A4^{-b}} = \frac23\cdot\frac{T_{A,b}(1)}{T_{A,b}(3)}. \qquad\square$$

The interpretation is that dividing by the mixture converts an exponent-$b$ decline into an almost flat object: at least one third of the decline is removed, whatever the amplitude and exponent. Empirically the background falls by $3.64$ where the profile falls by $3.25$, so the mixture absorbs the entire raw decline and slightly over-absorbs it — which is precisely why the residual's remaining structure is a *shape*, not a slope.

---

## 6. The beyond-background residual is peaked

### 6.1 A criterion for peakedness

**Definition 6.1.** A function $f$ on $[0,1]$ is *peaked* if it attains a maximum at an interior point and is neither monotone nor antitone on $[0,1]$.

**Lemma 6.2 (Interior maximum from endpoint dominance).** Let $f$ be continuous on $[0,1]$ and let $c\in(0,1)$ satisfy $f(0)<f(c)$ and $f(1)<f(c)$. Then $f$ attains its maximum over $[0,1]$ at some $m\in(0,1)$, and $f$ is neither monotone nor antitone on $[0,1]$.

*Proof.* Compactness gives a maximiser $m\in[0,1]$ with $f(c)\le f(m)$; if $m=0$ or $m=1$ this contradicts the strict inequalities, so $m\in(0,1)$. If $f$ were monotone, $f(c)\le f(1)$, contradiction; if antitone, $f(c)\le f(0)$, contradiction. $\square$

The hypothesis is a *value* condition, not a derivative condition — which is what the data actually supply (end values and an interior value), and it delivers the same conclusions.

### 6.2 The fitted residual

The measured residual is pinned at the end values $R(0)=0.80$ (the small-offset wall) and $R(1)=0.90$, with reported vertex $0.59$. The concave quadratic with those data is

$$\widehat R(x) \;=\; \frac45 + \frac{59}{90}x - \frac59 x^2 . \tag{6.1}$$

**Proposition 6.3 (Exact concavity identity).** For all $x$,
$$\widehat R(0.59) - \widehat R(x) \;=\; \frac59\bigl(x-0.59\bigr)^2 .$$
Hence $x=0.59$ is the strict global maximiser, with $\widehat R(0.59)=\tfrac{17881}{18000}\approx 0.99339$.

**Corollary 6.4 (Hump ratios and end deficits).**
$$\widehat R(0.59) \;\ge\; \tfrac65\,\widehat R(0), \qquad \widehat R(0.59)\;\ge\;\tfrac{11}{10}\,\widehat R(1), \qquad \widehat R(0)<1,\quad \widehat R(1)<1 .$$

So the apex clears the wall end by at least $20\%$ and the far end by at least $10\%$, while both ends are *deficits*: the background over-predicts at both ends of the window and under-predicts in the middle. The residual is therefore peaked in the sense of Definition 6.1 (Lemma 6.2 with $c=0.59$).

### 6.3 Robustness: the whole endpoint-pinned family

A single parabola is a weak object to hang a verdict on. Replace it by the entire family compatible with the two measured end values.

**Definition 6.5.** For $c\in\mathbb{R}$ let
$$R_c(x) \;=\; \frac45+\Bigl(\frac1{10}-c\Bigr)x + c\,x^2, \qquad\text{so } R_c(0)=\tfrac45,\ R_c(1)=\tfrac9{10}.$$
Its apex is at $x_c=\dfrac{1/10-c}{-2c}$ for $c\neq0$. The reported fit (6.1) is $R_{-5/9}$.

**Theorem 6.6 (Sharp curvature threshold).** Let $c<0$.

1. If $c<-1/10$, then $x_c\in(1/2,1)$ and $R_c$ is peaked on $[0,1]$.
2. If $-1/10\le c<0$, then $R_c$ is monotone (non-decreasing) on $[0,1]$: no peak at all.
3. At the threshold, $x_{-1/10}=1$ exactly: the apex slides onto the right endpoint.
4. For every $c<0$, the apex height satisfies $R_c(x_c)\ge \tfrac{28}{25}R_c(0)$, i.e. it exceeds the wall end value by at least $12\%$; and if in addition $c\neq -1/10$ then $R_c(x_c)>9/10=R_c(1)$.

*Proof sketch.* The exact identity $R_c(x_c)-R_c(x)=-c\,(x-x_c)^2$ gives the strict global maximum at $x_c$ for $c<0$. Part (1): $x_c>1/2 \iff 1/10-c>-c$, always true; $x_c<1 \iff 1/10-c<-2c \iff c<-1/10$. Peakedness then follows from Lemma 6.2 with $c$ replaced by $x_c$. Part (2): factor $R_c(y)-R_c(x)=(y-x)\bigl[(1/10-c)+c(x+y)\bigr]$; for $x,y\in[0,1]$ and $-1/10\le c<0$ the bracket is at least $1/10-c+2c=1/10+c\ge0$. Part (3) is direct computation. Part (4): $R_c(x_c)=\tfrac45-\tfrac{(1/10-c)^2}{4c}$, and elementary algebra shows $\tfrac{(1/10-c)^2}{4c}\le -0.096$ for all $c<0$ (with the tightest case near $c=-0.092$), giving $R_c(x_c)\ge 0.896=\tfrac{28}{25}\cdot\tfrac45$; and $\tfrac{(1/10-c)^2}{4c}<-\tfrac1{10}$ whenever $c\neq-1/10$, since this is equivalent to $(c+1/10)^2>0$. $\square$

**Theorem 6.7 (Invariance of the verdict over the reported uncertainty).** Every $c\in[-0.62,\,-0.14]$ satisfies $c<-1/10$; hence $R_c$ is peaked for every curvature in the reported interval, with margin $0.04$ to the threshold.

This is the precise content of the empirical claim that the "PEAKED" verdict is invariant across the reported brackets: it is not a robustness heuristic but a containment of an interval in a half-line whose endpoint is explicit.

### 6.4 The residual is not of profile form

**Lemma 6.8.** For $A>0$, the profile $T_{A,b}$ is antitone on $[0,1]$ when $b\ge0$ and monotone when $b\le0$. In particular it is never peaked.

**Theorem 6.9 (Layer separation).** For no $A>0$ and $b\in\mathbb R$ does $\widehat R$ coincide with $T_{A,b}$ on $[0,1]$.

*Proof.* $\widehat R$ is neither monotone nor antitone on $[0,1]$ (Corollary 6.4 plus Lemma 6.2), while $T_{A,b}$ is one or the other by Lemma 6.8. $\square$

**Theorem 6.10 (What the hump certifies).** Let $A>0$, $c\in(0,1)$ and let $M^\sharp$ be any function with $M^\sharp(0)<M^\sharp(c)$ and $M^\sharp(1)<M^\sharp(c)$. Then $M^\sharp$ does not coincide with $T_{A,b}$ on $[0,1]$ for any $b$.

Applied with $M^\sharp=T/M$: an interior peak in the residual proves that the background is **not** a power-law rescaling of the profile. The positional layer has a law; the beyond-background layer is a genuinely different object. This is the exact certification the data support — no more, as the next section shows.

---

## 7. Two corrections that sharpen the interpretation

### 7.1 A peak does not rule out a mixture background

It is tempting to strengthen Theorem 6.10 to: *an interior peak in $T/M$ rules out any positive scale mixture of exponentials as background.* Mixtures of exponentials (completely monotone functions) are the natural class here, and the uniform mixture $M$ of §5 belongs to it. The strengthening is **false**.

**Theorem 7.1 (Two-atom counterexample).** Let
$$M_2(x) \;=\; \tfrac12 e^{-x/20} + \tfrac12 e^{-8x},$$
a positive two-atom scale mixture with rates $1/20$ and $8$, and let $b=11/10$. Then the residual $\rho=T_{1,b}/M_2$ satisfies
$$\rho(0)=1,\qquad \rho(0.3)>\tfrac54,\qquad \rho(1)<\tfrac54,$$
hence $\rho$ is peaked on $[0,1]$.

*Proof sketch.* At $x=0$ both numerator and denominator equal $1$. At $x=0.3$: from $\log(1.3)\le 0.27$ (via $(1+27/800)^8\ge 1.3$ and $1+y\le e^y$) one gets $T_{1,b}(0.3)=e^{-1.1\log 1.3}\ge e^{-0.297}\ge 0.703$, using $e^{y}\le(1-y)^{-1}$; while $M_2(0.3)\le\tfrac12(1+0.1)=0.55$ because $e^{-2.4}\le 1/10$ (from $e^{2.4}=e^2e^{0.4}\ge 7.38\cdot1.4\ge10$). Hence $\rho(0.3)\ge 0.703/0.55>1.25$. At $x=1$: $T_{1,b}(1)=2^{-1.1}<1/2$ and $M_2(1)\ge\tfrac12 e^{-1/20}\ge 19/40$, so $\rho(1)\le (1/2)/(19/40)=20/19<5/4$. Lemma 6.2 finishes. $\square$

Consequently, peakedness of the residual is evidence about *which* mixture, not evidence against mixtures as such.

### 7.2 Peakedness is window-relative

Sharper still: the *actual* uniform background produces a hump too, outside the analysed window.

**Theorem 7.2 (The uniform-mixture residual peaks near $x=10$).** For $b=11/10$ let $\rho_U(x)=T_{1,b}(x)/M(x)$. Then
$$\rho_U(3)\le 0.69,\qquad \rho_U(10)\ge 0.70,\qquad \rho_U(100)\le 0.69,$$
so $\rho_U$ attains an interior maximum on $[3,100]$ and is neither monotone nor antitone there.

*Proof sketch.* Write $\rho_U(x)=(1+x)^{-11/10}x/(1-e^{-x})$. Rational exponents are handled by converting $a^{11/10}\le c$ into $a^{11}\le c^{10}$ (and dually), both exact integer comparisons: $11^{11}\le (100/7)^{10}$ gives $11^{-11/10}\ge 0.07$; $ (229/50)^{10}\le 4^{11}$ gives $4^{-11/10}\le 50/229$; $146^{10}\le 101^{11}$ gives $101^{-11/10}\le 1/146$. The exponential factors are controlled by $e^3\ge 20$ and $e^7\ge 1000$. Lemma 6.2 (on the window $[3,100]$) finishes. $\square$

**Corollary 7.3.** An interior hump locates a feature *of the analysed window*; it cannot by itself be read as evidence that the background is wrong. The defensible reading of the experiment is Theorem 6.10 together with the localisation of the measured hump at $x\approx0.59$ inside $[0,1]$.

---

## 8. The hump-location law and a critical exponent

### 8.1 Exact factorisation and the location law

For $x>0$,
$$\frac{T_{1,b}(x)}{M(x)} \;=\; \frac{x\,(1+x)^{-b}}{1-e^{-x}} \;=\; \frac{\tau_b(x)}{1-e^{-x}},\qquad \tau_b(x):=x(1+x)^{-b}. \tag{8.1}$$

Since $1-e^{-x}\to1$, the *shape* of the residual far from the origin is governed by the elementary factor $\tau_b$.

**Theorem 8.1 (Hump-location law).** For every $b>1$, $\tau_b$ has a unique maximiser on $[0,\infty)$, located at
$$x^\star \;=\; \frac{1}{b-1},$$
with $\tau_b$ strictly increasing on $[0,x^\star]$ and strictly decreasing on $[x^\star,\infty)$. For $b\le1$, $\tau_b$ is strictly increasing on all of $[0,\infty)$ and has no maximiser.

*Proof sketch.* Differentiating, for $x>-1$,
$$\tau_b'(x) \;=\; (1+x)^{-b-1}\bigl(1-(b-1)x\bigr),$$
whose first factor is positive. For $b>1$ the second factor is positive exactly for $x<1/(b-1)$ and negative for $x>1/(b-1)$; strict monotonicity on the two pieces follows from the sign of the derivative, and uniqueness of the maximiser from combining them. For $b\le1$, $(b-1)x\le0$ for $x\ge0$, so $\tau_b'>0$ throughout. $\square$

**Corollary 8.2.** At the measured exponent $b=11/10$, $x^\star=10$ — precisely where the hump of Theorem 7.2 was located.

**Remark 8.3 (Dichotomy at exponent one, again).** Theorem 8.1 is a dichotomy governed by exactly the threshold of Theorem 5.2: below it, no hump exists in the tail factor; above it, the hump exists and sits at $1/(b-1)$, receding to infinity as $b\downarrow1$. The reported interval $[0.991,1.218]$ straddles this too.

The transfer from $\tau_b$ to the true residual is quantitative.

**Theorem 8.4 (Confinement).** Let $b>1$ and $0<x_0\le x$. If
$$\tau_b(x) \;<\; \bigl(1-e^{-x_0}\bigr)\,\tau_b(x^\star),$$
then $\dfrac{T_{1,b}(x)}{M(x)} < \dfrac{T_{1,b}(x^\star)}{M(x^\star)}$. Moreover, for every $b>1$ and $x_0>0$ this hypothesis holds for all sufficiently large $x$, since $\tau_b(x)\to0$.

*Proof sketch.* From (8.1) and $1-e^{-x_0}\le 1-e^{-x}<1$ we get the sandwich
$$\tau_b(x)\;\le\;\frac{T_{1,b}(x)}{M(x)}\;\le\;\frac{\tau_b(x)}{1-e^{-x_0}}\quad (x\ge x_0>0).$$
Chaining the upper bound at $x$, the hypothesis, and the lower bound at $x^\star$ gives the claim. Decay of $\tau_b$ follows from $\tau_b(x)\le(1+x)^{1-b}\to0$ for $b>1$. $\square$

Since $1-e^{-x_0}\to1$, the localisation of the true hump near $1/(b-1)$ is asymptotically sharp.

### 8.2 A critical exponent for the existence of the hump

The exact logarithmic derivative of the true residual is, for $x>0$,

$$\frac{d}{dx}\log\frac{T_{1,b}(x)}{M(x)} \;=\; \frac1x - \frac{b}{1+x} - \frac{1}{e^{x}-1}. \tag{8.2}$$

The first two terms are the algebraic part of Theorem 8.1, positive up to $x^\star=1/(b-1)$; the third is an exponential correction that is large near the origin. As $b$ grows, $x^\star$ shrinks into the region where the correction dominates and the hump is destroyed. We prove the destruction side.

**Lemma 8.5 (Padé bound).** For $0<x<2$, $\displaystyle e^x<\frac{2+x}{2-x}$.

*Proof sketch.* Let $h(t)=(2+t)e^{-t}-(2-t)$. Then $h(0)=0$ and $h'(t)=1-(1+t)e^{-t}>0$ for $t>0$, since $1+t<e^t$. Hence $h(x)>0$ for $x>0$, i.e. $(2+x)e^{-x}>2-x$; multiplying by $e^x>0$ and dividing by $2-x>0$ gives the bound. $\square$

**Lemma 8.6.** For every $x>0$, $\displaystyle \frac1x-\frac12 \;<\; \frac{1}{e^x-1}$.

*Proof.* For $x\ge2$ the left side is $\le0<$ right side. For $0<x<2$, Lemma 8.5 gives $e^x-1<\frac{2+x}{2-x}-1=\frac{2x}{2-x}$; inverting the (positive) quantities, $\frac{1}{e^x-1}>\frac{2-x}{2x}=\frac1x-\frac12$. $\square$

**Theorem 8.7 (No hump for large exponents).** For every $b\ge 3/2$, the residual $x\mapsto T_{1,b}(x)/M(x)$ is strictly decreasing on all of $(0,\infty)$.

*Proof sketch.* It suffices that the derivative (8.2) of the log-residual be negative for all $x>0$. Two regimes:

* $0<x\le2$: by Lemma 8.6 it suffices that $\frac{b}{1+x}\ge\frac12$, i.e. $2b\ge 1+x$, which holds since $x\le 2\le 2b-1$ for $b\ge3/2$.
* $x>2$: the algebraic part is already non-positive, since $\frac1x\le\frac{b}{1+x}\iff 1+x\le bx$, which holds for $x>2\ge \frac{1}{b-1}$ when $b\ge3/2$; and the correction $-1/(e^x-1)$ is strictly negative.

Strict antitonicity of the log-residual transfers to the residual since $\log$ is strictly increasing and the residual is positive. $\square$

**Theorem 8.8 (Bracketing the humping regime).** The uniform-mixture residual humps at $b=11/10$ (Theorem 7.2) and is strictly monotone for every $b\ge3/2$ (Theorem 8.7). Hence the qualitative shape changes at a critical exponent $b_c\in(11/10,\,3/2)$; numerically $b_c\approx1.1605$.

**Corollary 8.9.** The hump is not a structural property of the profile/background pair: the same pair is humped at one exponent and monotone at another. Since the reported interval $[0.991,1.218]$ contains exponents on both sides of $b_c$, the experiment as it stands does not settle whether the pair humps at all outside the measured window.

**Remark 8.10.** The constant $3/2$ is exactly what the two elementary bounds deliver: the argument requires $1/(b-1)\le2\le 2b-1$, i.e. $2b^2-3b\ge0$. Closing the gap to the true $b_c\approx1.1605$ requires a sharper lower bound on $1/(e^x-1)$ near $x\approx1$ than the Padé bound provides.

---

## 9. Algorithms

Three computational procedures underpin the empirical side of the analysis; all are elementary, and their cost is dominated by resampling.

**(A) Endpoint-pinned curvature fit.** Given residual samples $\{(x_i,r_i)\}_{i=1}^n$ with the two end values pinned at $r(0)=0.8$, $r(1)=0.9$, the family $R_c$ has a single free parameter, so least squares reduces to a scalar problem:
$$\hat c \;=\; \frac{\sum_i (r_i - \tfrac45 - \tfrac{x_i}{10})(x_i^2-x_i)}{\sum_i (x_i^2-x_i)^2},$$
obtained by writing $R_c(x)=\tfrac45+\tfrac{x}{10}+c(x^2-x)$ and minimising over $c$. Cost $O(n)$. The apex is then $x_{\hat c}=(1/10-\hat c)/(-2\hat c)$ and the peak verdict is the single comparison $\hat c<-1/10$.

**(B) Cluster bootstrap over source objects.** Hits are clustered by source semiprime, so resampling must be at the cluster level. For $B$ replicates, draw $128$ semiprimes with replacement, pool their hits, refit the exponent by log–log regression (or by maximum likelihood), and report the empirical $2.5\%$/$97.5\%$ quantiles. Cost $O(B\,n)$; with $B=2000$ this is a few seconds at $n\approx 10^4$. The reported interval $[0.991,1.218]$ came from such a procedure.

**(C) Model comparison by corrected Akaike weight.** For each candidate family, fit by least squares on the log scale, compute $\mathrm{AICc}=n\log(\mathrm{RSS}/n)+2k+\frac{2k(k+1)}{n-k-1}$, form gaps $d_i$ against the best model, and evaluate $w=\bigl(1+\sum_i e^{-d_i/2}\bigr)^{-1}$. Theorem 4.2(iii) provides the interpretive guard-rail: a tied rival caps $w$ at $1/2$.

---

## 10. Discussion

### 10.1 What is actually established

Three things are established with no reference to the data:

* **A law, not a fit.** Scale multiplicativity plus positivity plus continuity forces the power form (Theorem 2.4), with an identifiable exponent (Theorem 2.6). The empirical profile form is therefore a one-parameter law.
* **A structural model-selection verdict.** The log-midpoint defect separates the power law from the exponential, logistic and affine families simultaneously (Theorem 3.6), independently of any criterion.
* **A quantitative absorption statement.** The mixture background removes at least a third of the raw decline for every amplitude and exponent (Theorem 5.8), which is why the beyond-background layer shows a shape rather than a slope.

### 10.2 What is established with the data, and how robustly

The interior hump is not the property of one fitted parabola: it holds for every endpoint-pinned curvature below the sharp threshold $-1/10$, and the reported curvature interval $[-0.62,-0.14]$ lies entirely below it (Theorems 6.6, 6.7). Its consequence is exactly Theorem 6.10 — the background is not a power-law rescaling of the profile — and no more.

### 10.3 What is *not* established, and why that matters

Two tempting over-readings were refuted in the course of this work.

* An interior peak does **not** rule out mixture backgrounds; the two-atom mixture of Theorem 7.1 produces one.
* An interior peak is **not** an intrinsic property of a profile/background pair: peakedness is window-relative, and the very background used here humps near $x=10$ for the measured exponent (Theorem 7.2). Whether a hump exists at all is governed by a critical exponent in $(1.1,1.5)$ (Theorem 8.8).

Additionally, an earlier attempt to state "the residual peaks" as a derivative condition at the endpoints was replaced by the value condition of Lemma 6.2 — which is what the data supply and which yields the same conclusions. An earlier claim that $T/M$ can *never* have an interior maximum is false and was withdrawn; Theorem 8.1 and Theorem 8.7 give the correct picture, in which the location of the maximum, and its existence, are both explicit functions of the exponent.

### 10.4 The two straddled thresholds

The measured exponent interval $[0.991,\,1.218]$ straddles two distinct qualitative thresholds:

* $b=1$, the boundary between divergent and finite total window mass (Theorem 5.2), which is also the boundary for existence of a maximiser of $\tau_b$ (Theorem 8.1);
* $b=b_c\approx1.1605$, the boundary between the humped and monotone regimes of the true residual (Theorem 8.8).

Both are pinned by the mathematics and unresolved by the current data. This is the operationally useful output of the analysis: it converts "estimate $b$" into "separate $b$ from $1$ and from $\approx1.16$", which is a specific and checkable power requirement for a follow-up experiment.

---

## 11. Future work

1. **Close the critical-exponent gap.** Determine $b_c$ exactly, or at least bracket it inside $(1.15,1.17)$, by replacing the Padé bound of Lemma 8.5 with a two-sided rational approximation to $1/(e^x-1)$ valid near $x\approx1$. The defining equation is $\frac1{x}-\frac{b}{1+x}=\frac{1}{e^x-1}$ having a double root.
2. **General mixtures.** Characterise which positive scale mixtures $M(x)=\int e^{-sx}\,d\mu(s)$ admit a humped residual against a fixed power law. Theorem 7.1 shows the class is non-empty; the uniform mixture shows the hump can be pushed far out; a full characterisation in terms of $\mu$ (say, via the spread of $\log s$ under $\mu$) is open.
3. **Sharpen absorption.** The factor $2$ in Theorem 5.7 comes from the crude squeeze $1/(2x)\le M\le 1/x$. A refined expansion $M(x)=1/x-e^{-x}/x$ should convert Theorem 5.8's constant $2/3$ into an $x$-dependent bound that is asymptotically $1$.
4. **Discrete-to-continuum.** All the statements about window mass are continuum statements. Quantify the error between $\sum_{j<n} (1+x_j)^{-b}$ and $\int_0^{X}(1+x)^{-b}dx$ for the actual sampling grid, so the critical-exponent dichotomy can be tested directly on counts.
5. **Higher-dimensional profile forms.** Scale multiplicativity has an obvious analogue for profiles depending on two rescaled coordinates; the corresponding rigidity theorem should produce products of power laws, and would test whether the observed layer separation persists.
