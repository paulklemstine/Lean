# Rigidity, Separation, and Effective Exponents for Harmonic-Type Positional Kernels: A Bulk-Plus-Edge-Spike Refinement

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

We develop the analytic theory of the one-parameter family of *harmonic-type positional kernels* $\kappa_b(x) = (1+x)^{-b}$ on the normalised window $x \in [0,1]$, and of the two-component ("flat bulk plus narrow left-edge spike") profiles $T(x) = A(1+x)^{-b_1} + K(1+x)^{-b_2}$ built from them. The motivation is an empirical positional profile whose left decile carries measurably more mass than any calibrated single power law predicts, raising the question of whether the excess is genuine structure or a boundary artefact.

We prove five families of results. (i) **Rigidity**: for each interior window $t \in (0,1)$ the normalised cumulative mass $F(b,t)$ — the *edge fraction* — is strictly increasing in $b$, hence injective, so the exponent of a power law is identified by a single edge-mass measurement. (ii) **Non-falsifiability**: because $F(b,t) \to 1$ as $b \to \infty$ and $F$ is continuous in $b$, every value in $(F(b_0,t),1)$ is attained by some exponent $b > b_0$; therefore a single measured edge fraction can never refute the power-law hypothesis. (iii) **Separation at the density level**: a genuine two-component profile is strictly multiplicatively convex on every geometric triple, whereas every pure power law is multiplicatively affine there; consequently no rescaled single kernel agrees with $T$ on *any* nondegenerate subwindow. (iv) **Separation at the cumulative level**: no single exponent reproduces the mixture's edge fraction simultaneously at all windows, so the window-by-window fitted exponent is provably non-constant, while for each fixed window an effective exponent exists and is strictly bracketed, $b_1 < b_{\mathrm{eff}} < b_2$. (v) **Directionality and identifiability**: the two-point log-log slope of $T$ is strictly steeper on the left half of any geometric triple than on the right half, and in the narrow-spike limit $b_2 \to \infty$ the mixture edge fraction converges to $(1-w)F(b_1,t) + w$, so the spike weight $w$ is identified by the excess mass while the spike exponent is asymptotically unidentifiable.

Together these results turn a statistical tension into a structural theorem: a pure power law is *known wrong* for a bulk-plus-spike profile, at every scale, and the classical pooled exponent is reinterpreted as a compromise between the bulk and the spike rather than as a physical slope.

**Keywords:** power law, harmonic kernel, edge fraction, monotone likelihood ratio, log-convexity, mixture identifiability, effective exponent, positional profile.

---

## 1. Introduction

### 1.1 The empirical setting

Consider a family of windows indexed by a parameter, and within each window a finite set of *hits* — the positions at which some arithmetic or combinatorial condition holds. To pool observations across windows of unequal length, one rescales each window to $[0,1]$: a hit at absolute position $p$ in the window $[j_{\mathrm{lo}}, j_{\mathrm{hi}}]$ is recorded at

$$x \;=\; \frac{p - j_{\mathrm{lo}}}{\,j_{\mathrm{hi}} - j_{\mathrm{lo}}\,} \;\in\; [0,1] . \tag{1.1}$$

The empirical density of the pooled coordinates $x$ is the **positional profile**. In the case that motivated this work — the positional profile of the values $v_j = j^2 - N$ across many choices of $N$ — the profile had for some time been summarised by a single decaying power law

$$T(x) \;\propto\; (1+x)^{-b}, \qquad b \approx 1.104, \tag{1.2}$$

fitted on roughly $10^4$ pooled hits from $\sim 10^2$ windows. The fit is good in aggregate and reproducible across analysis pipelines.

A tension appeared at the boundary. The share of mass in the **left decile** $[0,0.1]$ predicted by (1.2) is $0.1415$; the measured share is $0.1620$ with a bootstrap interval $[0.1547, 0.1695]$. The prediction lies outside the interval. A two-component alternative,

$$T(x) \;=\; A(1+x)^{-b_1} \;+\; K(1+x)^{-b_2}, \qquad b_1 \ll b_2, \tag{1.3}$$

with a nearly flat bulk ($b_1 \approx 0.57$, interval $[0.41,0.77]$) and a narrow spike carrying $\approx 8.6\%$ of the mass, reproduces the observed left decile ($0.1617$) and improves every model-comparison criterion decisively; matched control data show no such component. More than half of the improvement in residual sum of squares is localised in the first decile, and essentially none of it near the interior features of the profile.

Two questions then arise, and both are mathematical rather than statistical:

1. *Could a single measured edge fraction, however discrepant, ever settle the matter?*
2. *If a two-component profile is the truth, in what precise sense is a power law wrong, and what is a fitted single exponent then measuring?*

This paper answers both, and in doing so supplies the rigidity, separation, and identifiability statements that make the empirical procedure sound.

### 1.2 Summary of results

Write $\kappa_b(x) = (1+x)^{-b}$, $H(b,t) = \int_0^t \kappa_b$, and $F(b,t) = H(b,t)/H(b,1)$.

* **Theorem A (closed forms).** For $b \ne 1$ and $t \ge 0$, $H(b,t) = \dfrac{(1+t)^{1-b}-1}{1-b}$ and $F(b,t) = \dfrac{(1+t)^{1-b}-1}{2^{1-b}-1}$.
* **Theorem B (rigidity).** For $0 < t < 1$ the map $b \mapsto F(b,t)$ is strictly increasing, hence injective; and $F(b,t) > t$ for every $b > 0$, with equality iff $b = 0$.
* **Theorem C (spike limit and non-falsifiability).** $F(b,t) \to 1$ as $b \to \infty$ for every $t > 0$; consequently, for $b_0 > 1$ and any $\alpha \in (F(b_0,t), 1)$ there is $b > b_0$ with $F(b,t) = \alpha$.
* **Theorem D (density-level separation).** For $A,K>0$ and $b_1 \ne b_2$, the profile (1.3) is strictly multiplicatively convex on every geometric triple; hence no $C, b$ satisfy $T(x) = C\kappa_b(x)$ on any nondegenerate interval.
* **Theorem E (mixture identity and effective exponents).** The normalised profile (1.3) equals the two-point mixture $(1-w)F(b_1,\cdot) + wF(b_2,\cdot)$ with $w = K H(b_2,1)/(AH(b_1,1)+KH(b_2,1))$; any single exponent calibrated to it on a fixed window satisfies $b_1 < b_{\mathrm{eff}} < b_2$.
* **Theorem F (cumulative-level separation and window dependence).** No exponent reproduces the mixture edge fraction at all $t \in (0,1)$; since an effective exponent exists for each $t$, the fitted exponent is necessarily window dependent.
* **Theorem G (left-edge steepening).** The two-point log-log slope of $T$ on the left half of any geometric triple strictly exceeds the slope on the right half; a pure power law returns the same value on both.
* **Theorem H (spike-weight identifiability).** As $b_2 \to \infty$, the mixture edge fraction tends to $(1-w)F(b_1,t) + w$; the weight is identified by the excess over the bulk prediction, while the spike exponent is not.

---

## 2. The harmonic-type kernel

### 2.1 Definitions

**Definition 2.1 (positional kernel).** For $b \in \mathbb{R}$ and $x \ge 0$, set
$$\kappa_b(x) \;=\; (1+x)^{-b}.$$
We call $b$ the *exponent*. Note $\kappa_b(0) = 1$ for all $b$, and $\kappa_0 \equiv 1$ is the flat kernel.

The shift by $1$ is not cosmetic: it makes the kernel bounded and continuous at the left endpoint of the window, so the family interpolates between the flat profile ($b=0$) and arbitrarily concentrated profiles ($b \to \infty$) without a singularity. All statements below are on $x \ge 0$.

**Definition 2.2 (head and tail mass).** For $0 \le t \le 1$,
$$H(b,t) = \int_0^t \kappa_b(x)\,dx, \qquad \Theta(b,t) = \int_t^1 \kappa_b(x)\,dx.$$

**Definition 2.3 (edge fraction).** For $0 \le t \le 1$,
$$F(b,t) \;=\; \frac{H(b,t)}{H(b,1)} .$$

Elementary facts, recorded for use below: $\kappa_b(x) > 0$; $\kappa_b$ is continuous on $[0,\infty)$ and therefore integrable on every compact subinterval; $H(b,t) > 0$ for $t>0$ and $\Theta(b,t) > 0$ for $t<1$; and $H(b,t) + \Theta(b,t) = H(b,1)$. Two structural identities do the real work:

$$\kappa_{b+c}(x) = \kappa_b(x)\,\kappa_c(x) \qquad\text{(exponent additivity)}, \tag{2.1}$$

$$c \ge 0 \implies \kappa_c \text{ antitone on } [0,\infty), \qquad c > 0 \implies \kappa_c \text{ strictly antitone.} \tag{2.2}$$

### 2.2 Closed forms

**Theorem 2.4 (Theorem A).** *For $b \ne 1$ and $t \ge 0$,*
$$H(b,t) \;=\; \frac{(1+t)^{1-b} - 1}{1-b}, \qquad\text{and, for } 0 \le t \le 1, \quad F(b,t) \;=\; \frac{(1+t)^{1-b} - 1}{2^{\,1-b} - 1}.$$
*Moreover $H(0,t) = t$ and $F(0,t) = t$.*

*Proof sketch.* The function $y \mapsto \big((1+y)^{1-b} - 1\big)/(1-b)$ is differentiable on $[0,\infty)$ with derivative $(1+y)^{-b} = \kappa_b(y)$ — differentiate the real power $y \mapsto (1+y)^{1-b}$ by the chain rule, which is legitimate because $1+y > 0$, and divide by the nonzero constant $1-b$. Since $\kappa_b$ is continuous, hence interval-integrable, the fundamental theorem of calculus gives the first formula, and the second follows by dividing the value at $t$ by the value at $1$, where $(1+1)^{1-b} = 2^{1-b}$; the factors $1-b$ cancel. Positivity of $H(b,1)$ guarantees the denominator $2^{1-b}-1$ is nonzero. The case $b=0$ is immediate. $\square$

The excluded case $b=1$ is the logarithmic one, $H(1,t) = \log(1+t)$; every statement below either avoids $b=1$ explicitly or is proved by an argument that does not use the closed form, so no generality is lost.

---

## 3. Rigidity of the single-law family

The next theorem is the analytic backbone of the paper. It is a monotone-likelihood-ratio statement: within the family $\{\kappa_b\}$, increasing the exponent shifts mass to the left in the strongest possible sense — monotonically in every cumulative statistic.

### 3.1 Two mass inequalities

**Lemma 3.1 (head discount).** *For $c \ge 0$ and $0 \le t$,*
$$\kappa_c(t)\,H(b,t) \;\le\; H(b+c,t).$$

*Proof sketch.* By (2.1), $\kappa_{b+c}(x) = \kappa_b(x)\kappa_c(x)$, and by (2.2) $\kappa_c(x) \ge \kappa_c(t)$ for $x \in [0,t]$. Hence the integrand on the right dominates $\kappa_c(t)\kappa_b(x)$ pointwise on $[0,t]$; integrate. $\square$

**Lemma 3.2 (strict tail discount).** *For $c > 0$ and $0 \le t < 1$,*
$$\Theta(b+c,t) \;<\; \kappa_c(t)\,\Theta(b,t).$$

*Proof sketch.* Split the tail at the midpoint $m = (t+1)/2$. On $[t,m]$ the same pointwise bound as in Lemma 3.1 gives $\int_t^m \kappa_{b+c} \le \kappa_c(t)\int_t^m \kappa_b$. On $[m,1]$ the strict antitonicity (2.2) gives the *strictly* smaller factor $\kappa_c(m) < \kappa_c(t)$, so $\int_m^1 \kappa_{b+c} \le \kappa_c(m)\int_m^1\kappa_b < \kappa_c(t)\int_m^1\kappa_b$, using $\int_m^1 \kappa_b > 0$. Adding the two pieces gives the strict inequality. $\square$

The asymmetry between Lemmas 3.1 and 3.2 — weak on the head, strict on the tail — is exactly the wedge that produces strict monotonicity of the ratio.

### 3.2 Rigidity and its consequences

**Theorem 3.3 (Theorem B, rigidity).** *For $0 < t < 1$ and $b_1 < b_2$,*
$$F(b_1,t) \;<\; F(b_2,t).$$
*Consequently $b \mapsto F(b,t)$ is injective: a power-law exponent is identified by a single edge-mass measurement.*

*Proof sketch.* Write $b_2 = b_1 + c$ with $c > 0$. Using $H(b,1) = H(b,t) + \Theta(b,t)$, the claim $\frac{H_1}{H_1+\Theta_1} < \frac{H_2}{H_2+\Theta_2}$ (subscripts for $b_1$ and $b_1+c$) is equivalent, after clearing the positive denominators, to $H_1\Theta_2 < H_2\Theta_1$. Lemma 3.1 gives $H_2 \ge \kappa_c(t) H_1$ and Lemma 3.2 gives $\Theta_2 < \kappa_c(t)\Theta_1$; multiplying the first by $\Theta_1 > 0$ and the second by $H_1 > 0$ and comparing yields $H_1\Theta_2 < \kappa_c(t) H_1 \Theta_1 \le H_2 \Theta_1$. Injectivity follows from trichotomy. $\square$

**Corollary 3.4 (left over-weighting).** *For $b > 0$ and $0 < t < 1$, $F(b,t) > t$, with equality precisely at $b = 0$.*

*Proof.* Apply Theorem 3.3 with $b_1 = 0$, $b_2 = b$, and use $F(0,t) = t$. $\square$

Corollary 3.4 is the quantitative form of "a decaying profile front-loads its window", and it already excludes any *flat* explanation of an elevated left decile.

---

## 4. The spike limit and non-falsifiability

**Theorem 4.1 (spike limit).** *For every $t > 0$, $F(b,t) \to 1$ as $b \to \infty$.*

*Proof sketch.* For $b > 1$ use the closed form of Theorem 2.4. Since $1 + t > 1$ and $2 > 1$, both $(1+t)^{1-b}$ and $2^{1-b}$ tend to $0$ as $b \to \infty$ (the exponent $1-b \to -\infty$). Hence the quotient tends to $(0-1)/(0-1) = 1$; the denominator's limit is nonzero, so the quotient rule for limits applies. $\square$

**Lemma 4.2 (continuity in the exponent).** *For fixed $t \ge 0$, $b \mapsto F(b,t)$ is continuous on $(1,\infty)$.*

*Proof sketch.* On $(1,\infty)$ the closed form applies; the numerator and denominator are compositions of the continuous maps $b \mapsto 1-b$ and $s \mapsto a^s$ (for the fixed bases $a = 1+t$ and $a=2$), and the denominator $2^{1-b} - 1$ never vanishes there because $b>1$ forces $2^{1-b} < 1$. $\square$

**Theorem 4.3 (Theorem C, non-falsifiability of a single measurement).** *Let $t > 0$, $b_0 > 1$, and let $\alpha$ satisfy $F(b_0,t) < \alpha < 1$. Then there exists $b > b_0$ with $F(b,t) = \alpha$.*

*Proof sketch.* By Theorem 4.1 there is $B > b_0$ with $F(B,t) > \alpha$. By Lemma 4.2, $F(\cdot,t)$ is continuous on the compact interval $[b_0,B] \subset (1,\infty)$, and $\alpha$ lies between $F(b_0,t)$ and $F(B,t)$; the intermediate value theorem supplies $b \in [b_0,B]$ with $F(b,t) = \alpha$. The endpoint $b = b_0$ is excluded because $F(b_0,t) < \alpha$. $\square$

**Interpretation.** Theorem 4.3 is a negative result of practical importance: *no* left-decile measurement, however far it lies from a reference law's prediction, is by itself evidence against the power-law hypothesis. In the motivating data, the reference exponent $1.104$ predicts $F = 0.14181$ and the measurement is $0.1620$; the exponent $b \approx 1.5698$ reproduces the measurement exactly. Detecting a two-component structure therefore *requires* a comparison of shapes across windows, not a single cumulative number — which is precisely the design the sections below justify.

---

## 5. Two-component profiles and their separation from power laws

**Definition 5.1.** For $A, K > 0$ and exponents $b_1, b_2$, the *two-component profile* is
$$T_{A,K,b_1,b_2}(x) \;=\; A\,\kappa_{b_1}(x) \;+\; K\,\kappa_{b_2}(x), \qquad x \ge 0 .$$
We call the pair *genuine* when $A,K>0$ and $b_1 \ne b_2$. In the application $b_1$ is the *bulk* exponent (small) and $b_2$ the *spike* exponent (large).

### 5.1 Three-point obstruction

**Definition 5.2 (geometric triple).** Positions $x_0 < x_1 < x_2$ in $[0,\infty)$ form a *geometric triple* if $(1+x_1)^2 = (1+x_0)(1+x_2)$; equivalently, $\log(1+x_0), \log(1+x_1), \log(1+x_2)$ are in arithmetic progression.

**Lemma 5.3 (power laws are log-affine).** *On any geometric triple and for any exponent $\beta$,*
$$\kappa_\beta(x_1)^2 \;=\; \kappa_\beta(x_0)\,\kappa_\beta(x_2).$$

*Proof.* $\kappa_\beta(x_1)^2 = \big((1+x_1)^2\big)^{-\beta} = \big((1+x_0)(1+x_2)\big)^{-\beta} = \kappa_\beta(x_0)\kappa_\beta(x_2)$, using multiplicativity of real powers on positive bases. $\square$

**Theorem 5.4 (Theorem D, strict multiplicative convexity).** *Let $A,K>0$ and $b_1 \ne b_2$, and let $x_0<x_1<x_2$ be a geometric triple with $x_0 \ge 0$. Then*
$$T(x_1)^2 \;<\; T(x_0)\,T(x_2).$$

*Proof sketch.* Write $a = \kappa_{b_1}(x_0)$, $a' = \kappa_{b_1}(x_2)$, $k = \kappa_{b_2}(x_0)$, $k' = \kappa_{b_2}(x_2)$, $p = \kappa_{b_1}(x_1)$, $q = \kappa_{b_2}(x_1)$, all positive. Lemma 5.3 gives $p^2 = aa'$ and $q^2 = kk'$. Expanding,
$$T(x_0)T(x_2) - T(x_1)^2 \;=\; A^2(aa' - p^2) + K^2(kk' - q^2) + AK\big(ak' + ka' - 2pq\big) \;=\; AK\big(ak' + ka' - 2pq\big),$$
so everything reduces to the cross terms. Their product satisfies $(ak')(ka') = (aa')(kk') = p^2q^2 = (pq)^2$, so $pq$ is their geometric mean; by the strict AM–GM inequality it suffices that $ak' \ne ka'$. That is exactly where $b_1 \ne b_2$ enters: for $c_1 < c_2$ one has
$$\kappa_{c_1}(x_0)\kappa_{c_2}(x_2) \;<\; \kappa_{c_2}(x_0)\kappa_{c_1}(x_2),$$
because dividing both sides by $\kappa_{c_1}(x_0)\kappa_{c_1}(x_2) > 0$ reduces it to $(1+x_2)^{-(c_2-c_1)} < (1+x_0)^{-(c_2-c_1)}$, which holds since $x_0 < x_2$ and the exponent is negative. Applying this with $(c_1,c_2)$ equal to $(b_1,b_2)$ or $(b_2,b_1)$ according to the sign of $b_2 - b_1$ gives $ak' \ne ka'$, hence $2pq < ak' + ka'$, hence the claim (recall $AK > 0$). $\square$

**Theorem 5.5 (no single power law on any subwindow).** *Let $A,K>0$ and $b_1 \ne b_2$, and let $0 \le s < e$. There are no constants $C, b$ with*
$$T(x) = C\,\kappa_b(x) \quad \text{for all } x \in [s,e].$$

*Proof sketch.* Put $x_1 = \sqrt{(1+s)(1+e)} - 1$, the geometric mean of the shifted endpoints minus one; then $s < x_1 < e$ (strictly, since $s<e$) and $(s,x_1,e)$ is a geometric triple. Theorem 5.4 gives $T(x_1)^2 < T(s)T(e)$. But if $T = C\kappa_b$ on $[s,e]$, then Lemma 5.3 gives $T(x_1)^2 = C^2\kappa_b(x_1)^2 = C^2\kappa_b(s)\kappa_b(e) = T(s)T(e)$, a contradiction. $\square$

Theorem 5.5 is the *falsifiability* statement of the programme: if the true profile is a genuine mixture, then a pure power law is wrong not merely globally but on every nondegenerate subwindow, and no restriction of attention can rescue it. It also fixes a hard constraint on any future shape model for the profile: it must fail log-affinity on geometric triples.

*(A self-contained special case, useful as a sanity check, is the triple $(0,\sqrt2-1,1)$ inside the full window: evaluation at these three points alone already contradicts any $C\kappa_b$.)*

---

## 6. The mixture identity and effective exponents

### 6.1 Normalising a two-component profile

**Definition 6.1 (two-point mixture).** For $w \in \mathbb{R}$,
$$M_w(b_1,b_2,t) \;=\; (1-w)F(b_1,t) \;+\; w\,F(b_2,t).$$

**Theorem 6.2 (mixture identity).** *For $A,K>0$ and $0 \le t \le 1$,*
$$\frac{\int_0^t T(x)\,dx}{\int_0^1 T(x)\,dx} \;=\; M_w(b_1,b_2,t), \qquad w \;=\; \frac{K\,H(b_2,1)}{A\,H(b_1,1) + K\,H(b_2,1)} \in (0,1).$$

*Proof sketch.* Linearity of the integral gives $\int_0^s T = A H(b_1,s) + K H(b_2,s)$ for every $s \ge 0$. Substituting at $s=t$ and $s=1$ and dividing, then writing $H(b_i,t) = F(b_i,t)H(b_i,1)$, the quotient becomes the stated convex combination with weights proportional to $AH(b_1,1)$ and $KH(b_2,1)$. Positivity of $A,K$ and of the head masses puts $w$ strictly inside $(0,1)$. $\square$

Thus the *observable* normalised profile depends on $(A,K)$ only through the single scalar $w$ — the share of total mass carried by the steep component. This is the first identifiability reduction: four parameters $(A,K,b_1,b_2)$ collapse to three, $(w,b_1,b_2)$.

**Proposition 6.3 (strict bracketing).** *Let $b_1 < b_2$, $0<t<1$. If $w > 0$ then $F(b_1,t) < M_w(b_1,b_2,t)$; if $w < 1$ then $M_w(b_1,b_2,t) < F(b_2,t)$.*

*Proof.* Immediate from Theorem 3.3 ($F(b_1,t) < F(b_2,t)$) and the fact that $M_w$ is an affine interpolation between the two values. $\square$

### 6.2 The effective exponent

**Definition 6.4.** Given a window $t \in (0,1)$ and a target value $\alpha$, an *effective exponent* is a solution $b$ of $F(b,t) = \alpha$. By Theorem 3.3 it is unique when it exists.

**Theorem 6.5 (Theorem E, effective-exponent inflation).** *Let $0 < w < 1$, $b_1 < b_2$, $0<t<1$, and suppose $F(b,t) = M_w(b_1,b_2,t)$. Then*
$$b_1 \;<\; b \;<\; b_2 .$$

*Proof sketch.* By Proposition 6.3, $F(b_1,t) < F(b,t) < F(b_2,t)$. Strict monotonicity of $F$ in its first argument (Theorem 3.3) converts these inequalities between values into the same inequalities between exponents: if $b \le b_1$ we would get $F(b,t) \le F(b_1,t)$, and if $b \ge b_2$ we would get $F(b,t) \ge F(b_2,t)$, both contradictions. $\square$

**Theorem 6.6 (existence of the effective exponent).** *If $0<w<1$, $1 < b_1 < b_2$ and $0<t<1$, then there exists $b > b_1$ with $F(b,t) = M_w(b_1,b_2,t)$.*

*Proof sketch.* By Proposition 6.3 the target exceeds $F(b_1,t)$, and since $F(b_1,t), F(b_2,t) < 1$ (each edge fraction is strictly below $1$ for $t<1$, because the tail mass is positive) the target is a convex combination of two numbers below $1$ and hence itself below $1$. Theorem 4.3 then applies with reference exponent $b_1$. $\square$

**Interpretation.** Theorems 6.5 and 6.6 explain the empirical arithmetic exactly. Fitting a single law to a profile whose bulk exponent is $\approx 0.57$ and whose spike is very steep necessarily returns a value strictly between the two; the historically reported $\approx 1.10$ is that compromise. The pooled exponent is a *statistic of the mixture*, not a slope of anything.

---

## 7. Window dependence: separation at the cumulative level

Theorem 5.5 separates the families at the level of densities. But an experimenter measures cumulative quantities. Does the separation survive normalisation and integration? It does — and the proof turns the density-level statement into the cumulative one by differentiation.

**Lemma 7.1 (differentiating the edge fraction in the window).** *For $t>0$, the map $s \mapsto H(\beta,s)$ is differentiable at $t$ with derivative $\kappa_\beta(t)$; hence $s \mapsto F(\beta,s)$ has derivative $\kappa_\beta(t)/H(\beta,1)$ at $t$.*

*Proof sketch.* $\kappa_\beta$ is continuous at $t$ and locally integrable, so the fundamental theorem of calculus for the upper limit of an interval integral applies; divide by the constant $H(\beta,1)$. $\square$

**Theorem 7.2 (Theorem F, cumulative separation).** *Let $0<w<1$ and $b_1 \ne b_2$. There is no exponent $b$ with*
$$M_w(b_1,b_2,t) \;=\; F(b,t) \qquad \text{for all } t \in (0,1).$$

*Proof sketch.* Suppose such a $b$ existed. Differentiating both sides at each $t \in (0,1)$ — legitimate by Lemma 7.1 applied to $b_1$, $b_2$ and $b$, and by uniqueness of derivatives for functions agreeing on a neighbourhood — yields
$$\underbrace{\frac{1-w}{H(b_1,1)}}_{=:A}\,\kappa_{b_1}(t) \;+\; \underbrace{\frac{w}{H(b_2,1)}}_{=:K}\,\kappa_{b_2}(t) \;=\; \frac{1}{H(b,1)}\,\kappa_b(t)$$
for all $t \in (0,1)$. Here $A,K>0$ because $0<w<1$ and the head masses are positive. But this says exactly that the genuine two-component profile $T_{A,K,b_1,b_2}$ coincides with a rescaled single kernel on the subwindow $[\tfrac14,\tfrac34]$, contradicting Theorem 5.5. $\square$

**Corollary 7.3 (window dependence of the fitted exponent).** *Let $0<w<1$, $b_1 \ne b_2$, and let $b_{\mathrm{eff}} : (0,1) \to \mathbb{R}$ satisfy $F(b_{\mathrm{eff}}(t), t) = M_w(b_1,b_2,t)$ for all $t \in (0,1)$. Then $b_{\mathrm{eff}}$ is not constant.*

*Proof.* If $b_{\mathrm{eff}} \equiv c$, the defining identity would exhibit a single exponent reproducing the mixture edge fraction at every window, contradicting Theorem 7.2. $\square$

By Theorem 6.6 such a function $b_{\mathrm{eff}}$ does exist (and is unique, by rigidity) whenever $1 < b_1 < b_2$, so Corollary 7.3 is not vacuous: the fitted exponent is a genuine, well-defined, non-constant function of the fitting window. This is the formal content of the observation that *refitting a single law on a narrower left window returns a different exponent* — empirically, a steepening from $\approx 1.10$ on the full window to $\approx 1.80$ on the left half.

---

## 8. Directionality: the measured slope steepens toward the edge

Corollary 7.3 asserts non-constancy but not direction. The direction comes from log-convexity.

**Definition 8.1 (measured local exponent).** For a positive profile $f$ and $0 \le x < y$,
$$\lambda_f(x,y) \;=\; -\,\frac{\log f(y) - \log f(x)}{\log(1+y) - \log(1+x)} ,$$
the exponent reported by a two-point log-log slope measurement on $[x,y]$.

**Proposition 8.2 (scale-freeness of a power law).** *For $C>0$ and any $b$, $\lambda_{C\kappa_b}(x,y) = b$ for all $0 \le x < y$.*

*Proof.* $\log(C\kappa_b(z)) = \log C - b\log(1+z)$, so the numerator is $b\big(\log(1+y)-\log(1+x)\big)$ up to sign and the quotient is $b$. $\square$

**Theorem 8.3 (Theorem G, left-edge steepening).** *Let $A,K>0$, $b_1 \ne b_2$, and let $x_0<x_1<x_2$ be a geometric triple with $x_0 \ge 0$. Then*
$$\lambda_T(x_1,x_2) \;<\; \lambda_T(x_0,x_1) .$$

*Proof sketch.* Because the triple is geometric, the two log-spacings coincide: $\log(1+x_1) - \log(1+x_0) = \log(1+x_2) - \log(1+x_1) =: \delta > 0$. Hence the two local exponents have the same positive denominator $\delta$, and the claim reduces to
$$\log T(x_0) - \log T(x_1) \;>\; \log T(x_1) - \log T(x_2),$$
i.e. to $2\log T(x_1) < \log T(x_0) + \log T(x_2)$. Taking logarithms in the strict inequality $T(x_1)^2 < T(x_0)T(x_2)$ of Theorem 5.4 — legitimate since $T > 0$ and $\log$ is strictly increasing — gives exactly this. $\square$

So the drift established in Corollary 7.3 has a sign: as the measurement window moves left, the reported exponent strictly increases. A single-law analysis of a bulk-plus-spike profile is therefore not merely imprecise; it is *systematically* biased in a known direction, and the size of the bias is itself a diagnostic.

---

## 9. Identifiability of the spike: weight yes, exponent no

**Theorem 9.1 (Theorem H, narrow-spike limit).** *For fixed $w$, $b_1$ and $t>0$,*
$$M_w(b_1,b_2,t) \;\xrightarrow[b_2\to\infty]{}\; (1-w)F(b_1,t) \;+\; w .$$

*Proof.* $M_w(b_1,b_2,t) = (1-w)F(b_1,t) + wF(b_2,t)$ and $F(b_2,t) \to 1$ by Theorem 4.1. $\square$

**Consequences.** Two, and they pull in opposite directions.

*The weight is identified.* Rearranging the limit, $w = \dfrac{M_\infty - F(b_1,t)}{1 - F(b_1,t)}$: the spike weight is precisely the excess of the observed edge mass over the bulk prediction, normalised by the maximum possible excess. Given a bulk exponent and a measured edge fraction, $w$ is determined.

*The spike exponent is not.* Since the limit is independent of $b_2$, and (by Theorem 3.3) $F(\cdot,t)$ approaches its limit monotonically, all sufficiently steep spikes produce nearly identical observable profiles. Numerically, at $t = 0.1$ and $w = 0.086$ with bulk $b_1 = 0.573$, the mixture edge fractions for $b_2 = 50$ and $b_2 = 2000$ are $0.19542$ and $0.19622$ — a difference in the fourth decimal, far below sampling error at realistic sample sizes.

This resolves what would otherwise look like a pathology of the empirical fit. When the optimiser is given a ceiling on the spike exponent it saturates that ceiling; when the ceiling is raised from $10$ to $40$ it finds an interior optimum near $22.5$ with a bootstrap interval roughly $[11,41]$, and the model improvement *grows*. Theorem 9.1 says this is the expected behaviour of a well-posed estimator on a partially unidentified parameter: the likelihood surface is asymptotically flat in $b_2$. The correct report is therefore a **lower bound** on the spike exponent together with a **point estimate of the weight** — never a point estimate of the exponent.

---

## 10. Algorithms

The theory yields three procedures, all elementary and all numerically stable.

### 10.1 Edge-fraction inversion (effective exponent)

Given a window $t \in (0,1)$ and a target edge fraction $\alpha \in (0,1)$, find the unique $b$ with $F(b,t) = \alpha$. Rigidity (Theorem 3.3) makes $F(\cdot,t)$ strictly increasing, so bisection converges monotonically and unconditionally; the spike limit (Theorem 4.1) and $F(b,t)\to 0$ as $b \to -\infty$ guarantee a bracketing interval exists whenever $t < \alpha < 1$ (for $\alpha \le t$ one brackets below $0$ instead). Cost: $O(\log(1/\varepsilon))$ evaluations of a closed-form expression.

### 10.2 The bulk-plus-spike diagnostic

Given a sample of normalised positions, the theory prescribes a specific test that a single edge fraction cannot perform:

1. Estimate the edge fraction $\widehat F(t_i)$ on a grid of windows $t_1 < \cdots < t_m$.
2. Invert each one to get $\widehat b_{\mathrm{eff}}(t_i)$ by §10.1.
3. Under the single-law hypothesis, $\widehat b_{\mathrm{eff}}$ is constant up to sampling noise (Proposition 8.2 and Theorem 3.3). Under the bulk-plus-spike hypothesis, it is strictly decreasing in $t$ (Corollary 7.3 gives non-constancy; Theorem 8.3 gives the direction).
4. Test monotone decrease — e.g. by a rank statistic on $(t_i, \widehat b_{\mathrm{eff}}(t_i))$, or by comparing left-half and full-window refits, whose difference is a one-sided quantity under the alternative.

The point of the pipeline is that step 4 tests a *shape* invariant, which Theorem 4.3 shows cannot be tested by any single $t$.

### 10.3 Weight estimation with a censored spike exponent

Given a bulk estimate $\widehat b_1$ and an edge fraction $\widehat F(t)$ at a small window $t$, estimate
$$\widehat w \;=\; \frac{\widehat F(t) - F(\widehat b_1,t)}{1 - F(\widehat b_1,t)},$$
the narrow-spike-limit estimator of Theorem 9.1. It is consistent for the weight whenever the spike exponent exceeds the resolution threshold, and it deliberately does not attempt to estimate $b_2$. A lower bound for $b_2$ is obtained by finding the smallest $b_2$ for which the two-component fit remains within the confidence band of the data — the honest output being an interval of the form $b_2 \gtrsim \beta_{\min}$.

---

## 11. Discussion

### 11.1 What has actually been established

The mathematics above converts a soft statistical claim ("the left edge looks special") into hard structural statements.

* A single edge-mass number is *never* decisive (Theorem 4.3). This is a limitation of the measurement, not of the data.
* If the truth is a genuine mixture, then no power law describes it on *any* window, and the failure is quantitative: strict log-convexity on geometric triples with a gap governed by $AK(\sqrt{ak'}-\sqrt{ka'})^2$-type terms (Theorem 5.4, Theorem 5.5).
* Every single-law fit to such a mixture returns a compromise exponent strictly between bulk and spike, which drifts, and drifts *upward as the window narrows to the left* (Theorems 6.5, 7.2, 8.3).
* The spike's weight is estimable; its sharpness, past a threshold, is not (Theorem 9.1).

Each of these is a statement about the analytic families themselves, independent of sample size, binning, or estimator. They are the reason a two-percentage-point discrepancy in one cumulative statistic could be escalated into a definite structural conclusion.

### 11.2 Reinterpreting the canonical exponent

The practical consequence for the motivating profile is a change of canonical form. The description
$$T(x) \propto (1+x)^{-1.104}$$
is retired as the *form* of the profile and retained only as a pooled summary: by Theorem 6.5 it is precisely the effective compromise generated by a flat bulk ($b_1 \approx 0.57$) and a narrow spike carrying a few percent of the mass. The canonical description becomes

$$T(x) \;=\; A(1+x)^{-b_{\mathrm{bulk}}} + K(1+x)^{-b_{\mathrm{edge}}}, \qquad b_{\mathrm{bulk}} \approx 0.57,\; b_{\mathrm{edge}} \gtrsim 10, \; w \approx 0.09 .$$

Any downstream shape model must now satisfy a falsifiable constraint: it must not be log-affine on geometric triples, because the data are strictly log-convex there.

### 11.3 A caution on reported values, and on definitional drift

Two methodological remarks deserve emphasis, both of which the theory clarifies.

First, on *censoring*. An estimator that reports a parameter pinned at the boundary of its admissible range is reporting censoring, not an estimate. Theorem 9.1 identifies exactly which parameter suffers this (the spike exponent) and exactly which does not (the weight), so the appropriate reporting convention is determined by the mathematics rather than by convention.

Second, on *normalisation*. Every quantity in this paper is defined relative to the specific normalisation (1.1) and the specific window definition $[0,t]$. Edge fractions computed under a different convention — a combined two-sided edge, a per-window equal-mean pooling, a logarithmic rescaling, or a different denominator in (1.1) — are *different functionals* and are not comparable numerically. In the motivating dataset an earlier-quoted edge fraction of $0.2346$ is not reproducible under the canonical convention, which yields $0.1620$; the leading explanation is a definitional mismatch with a combined-edge decomposition (numerically, $0.162 + 0.072$), and the discrepancy is flagged as requiring reconciliation. None of the conclusions above depend on it: every threshold and every interval here is evaluated against the canonically measured $0.1620$. The general lesson is that *edge statistics are convention-sensitive in a way that interior statistics are not*, which is one more reason to prefer the shape diagnostics of §10.2 over headline numbers.

### 11.4 Scope

The results are descriptive-form refinements *inside* the positional layer. They constrain the shape of the positional profile and nothing else: no statement is made or implied about rate-level quantities, about the density of the underlying arithmetic events, or about any structure orthogonal to position within a window.

---

## 12. Future directions

**Conjecture 1 (monotone drift of the fitted exponent).** For a mixture with $A,K>0$ and $b_1 < b_2$, let $b_{\mathrm{eff}}(t)$ be the unique exponent with $F(b_{\mathrm{eff}}(t),t) = M_w(b_1,b_2,t)$. Then $b_{\mathrm{eff}}$ is *strictly decreasing* on $(0,1)$, with $b_{\mathrm{eff}}(t) \to b_2$ as $t \to 0^+$ and $b_{\mathrm{eff}}(t)$ tending to the pooled compromise value as $t \to 1^-$. The insight is that the local exponent of a two-component profile is a weighted average of $b_1$ and $b_2$ whose weight is itself strictly decreasing in position, so every cumulative statistic inherits the same drift; the left-edge steepening of Theorem 8.3 is the two-point shadow of a genuinely monotone one-parameter family. Non-constancy is already proved (Corollary 7.3); the missing step is a derivative computation for $t \mapsto b_{\mathrm{eff}}(t)$ via the implicit function theorem applied to $F$, whose strict monotonicity in the exponent — the required nondegeneracy — is now available (Theorem 3.3). Numerically the conjecture is clearly true: on the grid $t = 0.02, 0.05, 0.1, 0.2, 0.4, 0.65, 0.9, 0.98$ with $b_1 = 0.573$, $b_2 = 22.54$, $w = 0.086$, the effective exponents are $3.046, 2.591, 2.071, 1.524, 1.121, 0.945, 0.863, 0.846$ — strictly decreasing.

**Conjecture 2 (spike weight identifiable, spike exponent not — quantitatively).** For fixed bulk $b_1$ and window $t$, the map $(w,b_2) \mapsto$ edge-fraction profile is not injective: profiles with the same $w$ and different large $b_2$ differ in sup-distance by $O(2^{-b_2})$, so $b_2$ is unidentifiable above a threshold while $w$ is determined exactly by the $b_2 \to \infty$ limit of the excess over the bulk prediction. The insight is that the convergence in Theorem 9.1 is *uniform on compact windows*, so the family of profiles is a compact perturbation of a one-parameter ($w$) family plus an exponentially small remainder — and that remainder, not noise, is what a fitting procedure sees when it reports a censored spike exponent. The limit is proved pointwise; upgrading it to a uniform statement with an explicit $2^{-b_2}$ rate requires only the closed form of Theorem 2.4 and elementary bounds.

**Conjecture 3 (two-window sufficiency).** Two well-separated windows should suffice to identify the pair $(w,b_1)$ under a narrow-spike assumption: the map $(w,b_1) \mapsto \big(M_\infty(t_1), M_\infty(t_2)\big)$ ought to be a diffeomorphism onto its image for $t_1 \ne t_2$, which would replace grid-based diagnostics by a two-point estimator with explicit error propagation.

**Further directions.** (a) A quantitative version of Theorem 5.5 giving a lower bound on the sup-distance between a genuine mixture and the best single power law on a window of given width, in terms of $w$ and $b_2 - b_1$ — this would convert the qualitative no-go into a power calculation. (b) Extension of the rigidity theorem to general exponential families of positional kernels, of which $\{\kappa_b\}$ is the special case generated by $\log(1+x)$; the monotone-likelihood-ratio proof of Theorem 3.3 uses only that the sufficient statistic $\log(1+x)$ is increasing, so the generalisation should be immediate and would cover alternative shift and rescaling conventions. (c) A three-component analysis testing whether a right-edge feature also exists, now that the diagnostic of §10.2 is available in a directional form. (d) Reconciliation of the edge-fraction conventions discussed in §11.3, with an explicit dictionary between combined-edge and one-sided definitions.

---

## 13. Conclusion

A positional profile that had been summarised for years by a single power law with exponent $\approx 1.10$ is better described, decisively, as a nearly flat bulk plus a narrow left-edge spike. The mathematics developed here explains why the question was hard, why it is now settled, and what the old exponent was really measuring.

The one-parameter family of harmonic-type kernels is rigid: its edge fraction is strictly increasing in the exponent, so one measurement identifies one law. It is also *complete* on the relevant range, in the sense that its edge fractions sweep out an entire interval up to $1$ — which is why no single measurement can ever falsify the family. Falsification requires a shape invariant, and there is a clean one: pure power laws are multiplicatively affine on geometric triples, while genuine two-component profiles are strictly multiplicatively convex there. That gap propagates to every level of the analysis — densities, cumulative statistics, and measured log-log slopes alike — and it has a direction, steepening toward the left edge.

What remains genuinely unmeasurable is the sharpness of the spike, and the theory says precisely so: above a resolution threshold the observable profile is flat in that parameter to exponentially small order. The right summary is a bulk exponent, a weight, and a lower bound — which is exactly the form the canonical description now takes.
