# Monotone Decline Versus Interior Modes: A Shape/Leakage Decomposition for Positional Rate Profiles

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

We give a complete mathematical decomposition of the inference problem that arises when a positional rate profile is tested for shape against a flexible alternative. Three phenomena are separated and settled as theorems.

First, *nonlinearity does not imply a mode*: the scale-free family $T(x) = C(1+x)^{-a}$ with $C,a>0$ has a strictly convex log-rate — so no affine model can fit it and a likelihood-ratio test against a linear-in-$x$ model must reject — while being strictly decreasing and therefore provably free of interior maxima on every window. A decisive rejection of linearity is thus exactly what a mode-free steep decline predicts, and carries no information about location.

Second, *an endpoint-calibrated residual against a curvature-mismatched baseline manufactures a mid-window peak*. For a baseline $B(x) = C'(1+x)^{-a'}e^{-bx}$ the log-residual reduces to $d\log(1+x)+bx$ with mismatch $d = a'-a$; if $d>0$ and the tilt $b$ is calibrated so that the residual agrees at the two window edges, the residual acquires a genuine strict interior maximum located at $x^\star = L(1+l,1+u) - 1$, where $L$ is the logarithmic mean. We prove that this artefact is trapped strictly between the geometric mean of the window edges and the window midpoint, so it always lies in the left half of the window; that its amplitude is exactly proportional to $d$ while its location is independent of $d$; that the sign of $d$ decides bump versus no-bump; and that the phenomenon persists for an arbitrary strictly convex log-baseline excess. Conversely, a strict interior mode is impossible whenever the log-baseline differs from the log-signal by an affine function, so any observed strict interior mode is a certificate of baseline misspecification rather than evidence for a positional mode.

Third, *binning is innocent*: equal-width block averages of a continuous strictly decreasing shape are strictly decreasing for every bin width, so no interior peak can be created by coarse-graining.

We apply the decomposition to a binning-free re-analysis of a positional hit-rate experiment ($128$ strata, $9\,594$ hits against $512\,000$ controls) in which a free spline model defeated the linear model with a likelihood-ratio statistic of $100.574$ on $3$ degrees of freedom ($p_{\text{asym}} = 1.17\times10^{-21}$; $0/400$ permutation exceedances) while the profile's interior maximum was pinned to the extreme left edge in all $150$ bootstrap replicates. The correct reading is a steep monotone decline with peak-to-end ratio $2.54$ ($95\%$ CI $[2.243,2.798]$), not a positional mode; a previously reported peaked mid-window residual is retracted as baseline-curvature leakage, and the power-law description $T(x)\approx 0.0295\,(1+x)^{-1.104}$ is re-confirmed binning-free.

**Keywords:** power-law rate profile, interior mode, logarithmic mean, baseline misspecification, curvature leakage, likelihood-ratio test, binning invariance, Dickman-type decline.

---

## 1. Introduction

### 1.1 The inferential situation

A recurring pattern in empirical work is the *positional shape test*. Events occur at positions $x$ inside a window $[l,u]$; one asks whether the event rate $T(x)$ has a preferred interior location — a **mode** — or whether it merely declines. The distinction is scientifically decisive: a monotone decline is generic and is produced by many uninteresting mechanisms, whereas an interior maximum localises a mechanism at a specific position.

In practice the question is almost never asked directly. Instead one fits a flexible model (a spline, a polynomial, a nonparametric smoother) and tests it against a restrictive null, most often the model that is *linear in $x$* on the log-rate scale. A large likelihood-ratio statistic is then reported as evidence of "real structure". The step from "real structure" to "there is a peak" is the fallacy this paper closes.

A second and subtler failure mode arises because absolute rates are rarely observable. What is reported is a **residual**: signal over baseline, on the log scale, tilted so as to match at the window edges. We show that this construction has an intrinsic tendency to produce interior bumps whenever the baseline's curvature differs from the signal's, and we characterise the resulting artefact exactly.

### 1.2 Contributions

1. **Shape calculus** (§3). Elementary but sharp statements about interior modes: uniqueness of a strict interior mode; the impossibility of interior modes for strictly antitone shapes, for strictly convex shapes, and for affine residuals.
2. **Nonlinearity without mode** (§4). The power-law family is simultaneously non-affine on the log scale and mode-free; with an explicit identification of the exponent from a peak-to-end ratio and a steepness criterion separating $a<1$ from $a>1$.
3. **Curvature leakage** (§5). Existence, exact location, exact amplitude, sign dichotomy, and a model-free generalisation of the manufactured mid-window mode; plus the converse erratum principle.
4. **Location and amplitude bounds** (§6). GM $<$ LM $<$ AM in a self-contained hyperbolic normal form, yielding the left-half trap and the right-half falsifier, and the exact linear amplitude law.
5. **Binning invariance** (§7). Block averages of a strictly declining continuous shape are strictly declining.
6. **Application** (§8). The decomposition applied to the experimental record, producing an erratum and a strengthened power-law conclusion.

---

## 2. Notation and standing conventions

Throughout, $l < u$ are real numbers with $-1 < l$, and $[l,u]$ is the **window**. Position is measured in a shifted coordinate: all curvature statements are natural in $1+x$, and we write
$$A := 1+l, \qquad B := 1+u, \qquad 0 < A < B.$$
The **window ratio** is $\rho := B/A$. All logarithms are natural. $\operatorname{Icc}(l,u) = [l,u]$ denotes the closed window and $\operatorname{Ioo}(l,u) = (l,u)$ its interior.

**Definition 2.1 (Interior mode).** A point $x$ is an *interior mode* of $f$ on $[l,u]$ if $x \in (l,u)$ and $f(y) \le f(x)$ for all $y \in [l,u]$.

**Definition 2.2 (Strict interior mode).** A point $x$ is a *strict interior mode* of $f$ on $[l,u]$ if $x \in (l,u)$ and $f(y) < f(x)$ for every $y \in [l,u]$ with $y \ne x$.

A strict interior mode is in particular an interior mode. Both notions depend only on the restriction of $f$ to $[l,u]$; consequently two functions agreeing on the window have exactly the same modes, a fact we use silently when replacing a residual by a normalised representative.

**Definition 2.3 (Power-law rate).** For $C, a \in \mathbb{R}$ and $x > -1$,
$$T_{C,a}(x) := C\,(1+x)^{-a},$$
using the real power $t \mapsto t^{-a}$ on $t>0$. For $C>0$ we have $T_{C,a}(x)>0$ throughout.

**Definition 2.4 (Mixture-proxy baseline).** For $C', a', b \in \mathbb{R}$,
$$B_{C',a',b}(x) := C'\,(1+x)^{-a'}\,e^{-bx}.$$
This exponential-times-power form is the analytically tractable proxy for a mixture-Dickman baseline: it is closed under the log-residual operation and its two curvature parameters $(a', b)$ isolate, respectively, the scale-free curvature and the linear tilt.

**Definition 2.5 (Log-residual).** For $d, b \in \mathbb{R}$ and $x>-1$,
$$r_{d,b}(x) := d\log(1+x) + bx.$$
Here $d$ is the **curvature mismatch** and $b$ the **tilt**.

**Definition 2.6 (Logarithmic mean).** For $0 < A < B$,
$$L(A,B) := \frac{B-A}{\log B - \log A}.$$

---

## 3. A calculus of interior modes

We record the shape facts that everything else rests on. All are proved for a general real-valued $f$ on a window.

**Lemma 3.1 (Uniqueness).** If $x$ and $x'$ are both strict interior modes of $f$ on $[l,u]$ then $x = x'$.

*Proof.* If $x \ne x'$ then strictness at $x$ gives $f(x') < f(x)$ and strictness at $x'$ gives $f(x) < f(x')$, a contradiction. $\square$

**Lemma 3.2 (Monotone decline has no interior mode).** If $l<u$ and $f$ is strictly antitone on $[l,u]$ (i.e. $y_1<y_2$ in $[l,u]$ implies $f(y_2)<f(y_1)$), then no $x$ is an interior mode of $f$ on $[l,u]$.

*Proof.* Let $x \in (l,u)$. Then $l \in [l,u]$ and $l < x$, so $f(x) < f(l)$, violating the requirement $f(l) \le f(x)$. $\square$

**Lemma 3.3 (Convexity forbids interior modes).** Let $l<u$ and let $f$ be strictly convex on $[l,u]$. Then no $x$ is an interior mode. If $f$ is merely convex, no $x$ is a *strict* interior mode.

*Proof sketch.* An interior $x$ is a nontrivial convex combination $x = (1-t)l + tu$ with $t \in (0,1)$. Strict convexity gives $f(x) < (1-t)f(l) + tf(u) \le \max\{f(l),f(u)\}$, so $x$ fails to dominate one of the endpoints. In the merely convex case the same computation gives $f(x) \le \max\{f(l),f(u)\}$, which contradicts strict domination of that endpoint. $\square$

**Lemma 3.4 (Affine residuals are mode-free).** For any $p,q \in \mathbb{R}$ and $l<u$, the function $y \mapsto p + qy$ has no strict interior mode on $[l,u]$.

*Proof.* Affine functions are simultaneously convex and concave; apply the second half of Lemma 3.3. $\square$

**Theorem 3.5 (Log-curvature certificate).** Let $l<u$ and suppose the log-ratio $g = \log(T/B)$ of a positive signal to a positive baseline is convex on $[l,u]$. Then the residual $T/B$ has no strict interior mode on $[l,u]$.

*Proof.* By Lemma 3.3 the convex function $g$ has no strict interior mode; since $\exp$ is strictly increasing, $T/B = e^{g}$ has a strict interior mode exactly where $g$ does. $\square$

Theorem 3.5 is the practical form of the "innocence certificate": a fitted residual whose log is convex over the window cannot be exhibiting a peak, whatever the smoother says.

---

## 4. Nonlinearity without a mode

### 4.1 The power law is mode-free

**Proposition 4.1.** Let $C>0$, $a>0$. Then $T_{C,a}$ is strictly antitone on $(-1,\infty)$, hence on every window $[l,u] \subseteq (-1,\infty)$; consequently $T_{C,a}$ has no interior mode on any such window, and its left edge is the greatest value:
$$T_{C,a}(l) = \max_{y \in [l,u]} T_{C,a}(y),$$
attained only at $y=l$.

*Proof.* For $-1 < y_1 < y_2$ we have $0 < 1+y_1 < 1+y_2$, and $t \mapsto t^{-a}$ is strictly decreasing on $(0,\infty)$ for $a>0$; multiply by $C>0$. Lemma 3.2 gives mode-freeness. $\square$

### 4.2 Yet the log-rate is strictly convex

**Proposition 4.2.** For $a>0$, the function $\ell(x) := -a\log(1+x)$ is strictly convex on $(-1,\infty)$.

*Proof sketch.* $\log$ is strictly concave, so $-a\log$ is strictly convex for $a>0$; composition with the affine map $x\mapsto 1+x$ preserves strict convexity. Equivalently, $\ell''(x) = a/(1+x)^2 > 0$. A midpoint form of the same statement, $\log\!\big(\tfrac{A+B}{2}\big) > \tfrac12(\log A + \log B)$ for $A\neq B$ positive, suffices for the applications below. $\square$

**Theorem 4.3 (No affine log-fit).** Let $C,a>0$, $-1<l<u$. There exist no $p,q \in \mathbb{R}$ with
$$\log T_{C,a}(x) = p + qx \quad \text{for all } x \in [l,u].$$

*Proof.* Suppose such $p,q$ existed. Since $\log T_{C,a}(x) = \log C + \ell(x)$ with $\ell$ strictly convex (Proposition 4.2), the function $\ell$ would agree with an affine function on $[l,u]$. Take the midpoint $m = (l+u)/2$: strict convexity gives $\ell(m) < \tfrac12(\ell(l)+\ell(u))$, whereas the affine representation gives equality. Contradiction. $\square$

**Theorem 4.4 (Nonlinearity without mode — headline decomposition).** Let $C>0$, $a>0$, $-1<l<u$. Then, simultaneously:

1. there is no affine $p+qx$ agreeing with $\log T_{C,a}$ on $[l,u]$;
2. $T_{C,a}$ is strictly antitone on $[l,u]$;
3. no point of $(l,u)$ is an interior mode of $T_{C,a}$ on $[l,u]$.

*Proof.* Theorem 4.3, Proposition 4.1, Lemma 3.2. $\square$

**Interpretation.** A likelihood-ratio test of "free smooth log-rate" against "log-rate affine in $x$" is *guaranteed* to reject, asymptotically with probability one, when the truth is any power law with $a \neq 0$. The magnitude of the rejection is a statement about curvature. Item (3) says the truth may nevertheless have no interior maximum at all. Hence: **significance against linearity is not evidence for a mode.** More generally, by Lemma 3.3, *any* shape whose log-rate is convex is structurally incapable of an interior maximum, so the whole convex-log class is exempt from mode-hunting no matter how significant the nonlinearity.

### 4.3 Reading the exponent off a ratio

**Proposition 4.5 (Ratio law).** For $C \ne 0$ and $-1<l$, $-1<u$,
$$\frac{T_{C,a}(l)}{T_{C,a}(u)} = \left(\frac{1+u}{1+l}\right)^{a} = \rho^{a}.$$

*Proof.* Both amplitudes cancel; $(1+l)^{-a}/(1+u)^{-a} = ((1+u)/(1+l))^{a}$ by the power rules on positive bases. $\square$

**Theorem 4.6 (Exponent identification).** If $l<u$, $-1<l$, $-1<u$, and the observed peak-to-end ratio is $R = T_{C,a}(l)/T_{C,a}(u)$, then
$$a = \frac{\log R}{\log \rho}, \qquad \rho = \frac{1+u}{1+l} > 1.$$

*Proof.* Take logs in Proposition 4.5 and divide by $\log\rho>0$. $\square$

**Corollary 4.7 (Steepness test).** With the hypotheses of Theorem 4.6, if $R > \rho$ then $a > 1$.

*Proof.* $\log$ is strictly increasing, so $\log R > \log \rho > 0$; divide. $\square$

**Proposition 4.8 (Two-point identifiability).** If $T_{C,a}$ and $T_{C',a'}$ agree at two distinct points $x_1 \ne x_2$ of $(-1,\infty)$ with $C,C'>0$, then $C=C'$ and $a=a'$.

*Proof sketch.* Taking logs, $\log C - a\log(1+x_i) = \log C' - a'\log(1+x_i)$ for $i=1,2$. Subtracting, $(a'-a)(\log(1+x_1)-\log(1+x_2)) = 0$; the second factor is nonzero because $\log$ is injective on $(0,\infty)$ and $x_1\neq x_2$. Hence $a=a'$, and then $\log C = \log C'$. $\square$

**Proposition 4.9 (Monotone ratio in the exponent).** For a fixed window with $\rho>1$, the map $a \mapsto \rho^{a}$ is strictly increasing. Steeper exponents produce larger peak-to-end ratios, so the ratio is a monotone summary statistic for steepness.

---

## 5. Curvature leakage: how a baseline manufactures a peak

### 5.1 Reduction of the residual

**Theorem 5.1 (Residual normal form).** Let $C, C' > 0$ and $x > -1$. Then
$$\log \frac{T_{C,a}(x)}{B_{C',a',b}(x)} \;=\; \log\frac{C}{C'} \;+\; r_{d,b}(x), \qquad d = a'-a,$$
with $r_{d,b}(x) = d\log(1+x) + bx$ as in Definition 2.5.

*Proof.* Expand both logs: $\log T = \log C - a\log(1+x)$ and $\log B = \log C' - a'\log(1+x) - bx$; subtract. $\square$

Thus the entire two-model comparison collapses to a two-parameter object $(d,b)$: a curvature mismatch and a tilt. The additive constant $\log(C/C')$ is mode-irrelevant.

### 5.2 The endpoint-matching tilt

**Definition 5.2 (Matching tilt).**
$$b^\star(d,l,u) := -\,d\,\frac{\log(1+u) - \log(1+l)}{u - l}.$$

**Lemma 5.3.** If $d>0$, $-1<l<u$, then $b^\star(d,l,u) < 0$; and for all $d$, $r_{d,b^\star}(l) = r_{d,b^\star}(u)$.

*Proof.* Negativity: $\log(1+u)>\log(1+l)$ and $u-l>0$, so the quotient is positive and the leading $-d$ makes it negative. Endpoint equality is a direct algebraic verification:
$$r_{d,b^\star}(u) - r_{d,b^\star}(l) = d\big(\log(1+u)-\log(1+l)\big) + b^\star (u-l) = 0. \qquad\square$$

This is exactly the calibration performed in practice: a linear drift is absorbed into the fit so that the residual is anchored at both ends of the window and only mid-window deviation is reported.

### 5.3 Existence and exact location of the ghost

**Theorem 5.4 (Tangent-line maximality).** Let $d>0$ and $b<0$. Then $r_{d,b}$ has a unique global maximum on $(-1,\infty)$, at
$$x^\star = \frac{-d}{b} - 1,$$
i.e. $r_{d,b}(y) < r_{d,b}(x^\star)$ for every $y>-1$ with $y \ne x^\star$.

*Proof.* Put $m := -d/b > 0$, so $1+x^\star = m$ and $b = -d/m$. For $y>-1$ set $t := (1+y)/m > 0$. The strict tangent-line inequality $\log t < t-1$ for $t>0$, $t\ne 1$, gives
$$d\big(\log(1+y) - \log m\big) < d\left(\frac{1+y}{m} - 1\right) = -b\,(y - x^\star),$$
using $d/m = -b$. Rearranging, $d\log(1+y) + by < d\log m + b x^\star = r_{d,b}(x^\star)$, which is the claim; $t=1$ corresponds precisely to $y = x^\star$. $\square$

**Theorem 5.5 (The peak is the logarithmic mean).** For $d>0$, $-1<l<u$, with $b^\star$ as in Definition 5.2,
$$\frac{-d}{b^\star} - 1 \;=\; L(1+l,\,1+u) - 1 \;=\; \frac{(1+u)-(1+l)}{\log(1+u)-\log(1+l)} - 1 .$$
In particular **the location does not depend on the mismatch $d$**: $d$ cancels between numerator and denominator of the stationarity equation $d/(1+x)+b^\star = 0$.

*Proof.* Substitute Definition 5.2 and simplify: $-d/b^\star = (u-l)/(\log(1+u)-\log(1+l)) = (B-A)/(\log B - \log A) = L(A,B)$. $\square$

**Lemma 5.6 (Logarithmic mean is interior).** For $0<A<B$, $L(A,B) \in (A,B)$.

*Proof sketch.* Strict concavity of $\log$ gives, for the secant through $(A,\log A)$ and $(B,\log B)$, $\log B - \log A < (B-A)/A$ and $\log B - \log A > (B-A)/B$; dividing $B-A$ by these bounds yields $A < L < B$. $\square$

**Theorem 5.7 (Baseline leakage manufactures a mid-window mode).** Let $d>0$ and $-1<l<u$. Then
$$x^\star = L(1+l,1+u) - 1$$
is a **strict interior mode** of the endpoint-matched residual $r_{d,b^\star}$ on $[l,u]$: $x^\star \in (l,u)$ and $r_{d,b^\star}(y) < r_{d,b^\star}(x^\star)$ for every $y \in [l,u]$, $y \ne x^\star$.

*Proof.* Interiority is Lemma 5.6 translated by $-1$. Lemma 5.3 gives $b^\star<0$, so Theorem 5.4 applies and gives strict global maximality at $-d/b^\star - 1$, which equals $x^\star$ by Theorem 5.5. Restrict to $[l,u]$. $\square$

**Corollary 5.8 (The signal has no such mode).** Under the hypotheses of Theorem 5.7, with $C,a>0$, the signal $T_{C,a}$ has no interior mode on $[l,u]$ while its endpoint-matched residual against a more-curved baseline does. The peak is entirely an artefact of the comparison.

*Proof.* Proposition 4.1 and Theorem 5.7. $\square$

### 5.4 The converse: an erratum principle

**Theorem 5.9 (Strict interior modes force non-affine log-residuals).** Let $l<u$ and let $f$ be any function on $[l,u]$ possessing a strict interior mode. Then $f$ is not affine on $[l,u]$; equivalently, if $\log T - \log B$ is affine on the window, no strict interior mode can be reported.

*Proof.* Lemma 3.4. $\square$

**Interpretation (the erratum principle).** Within the power-law family, a positional "mode" cannot exist (Proposition 4.1). Therefore an observed strict interior mode in a log-residual proves one of exactly two things: (i) the signal leaves the power-law family, or (ii) the log-baseline differs from the log-signal by a **non-affine** function — baseline misspecification. Since the *shape* channel tests precisely hypothesis (i) and finds monotone decline pinned to the left edge, the surviving explanation is (ii). Any revival of the peaked claim must therefore be stated as a baseline-misspecification claim, never as a positional mode.

### 5.5 The mechanism is not an artefact of the parametrisation

**Lemma 5.10 (Matched-endpoint concave shapes have a mode).** Let $l<u$ and let $f$ be continuous on $[l,u]$, strictly concave there, with $f(l) = f(u)$. Then $f$ has a strict interior mode on $[l,u]$.

*Proof sketch.* Continuity on a compact set gives a maximiser $x$. It cannot be an endpoint: for interior $y$, strict concavity gives $f(y) > \min\{f(l),f(u)\} = f(l) = f(u)$, so the endpoints are not maximal. Strictness of the domination follows because a strictly concave function attains its maximum at a unique point: if $f(x_1)=f(x_2)=\max$ with $x_1\ne x_2$, the midpoint would exceed the maximum. $\square$

**Theorem 5.11 (General curvature leakage).** Let $g$ be continuous and strictly convex on $[l,u]$, $l<u$ — an arbitrary strictly convex excess in the log-baseline over the log-signal. Let $c := (g(u)-g(l))/(u-l)$ be the secant slope. Then the secant-tilted residual
$$y \longmapsto c\,y - g(y)$$
has a strict interior mode on $[l,u]$.

*Proof.* The affine map $y\mapsto cy$ is concave, and subtracting a strictly convex function from a concave function yields a strictly concave function. Its endpoint values agree: $cl - g(l) = cu - g(u)$ by the definition of $c$. Continuity holds. Apply Lemma 5.10. $\square$

Theorem 5.11 shows that leakage is a consequence of curvature *per se*, not of the exponential-times-power parametrisation. The power-law calculation of §5.3 adds the location.

### 5.6 The sign of the mismatch decides bump versus no bump

**Proposition 5.12 (Concavity/convexity dichotomy).** For $d>0$ and any $b$, $r_{d,b}$ is strictly concave on $(-1,\infty)$. For $d \le 0$ and any $b$, $r_{d,b}$ is convex on $(-1,\infty)$.

*Proof.* $r_{d,b}''(x) = -d/(1+x)^2$, negative for $d>0$ and nonnegative for $d\le0$; the linear term contributes nothing to curvature. $\square$

**Theorem 5.13 (Under-curved baselines never leak a peak).** If $d \le 0$ then for **every** tilt $b$ — matched, fitted, or adversarially chosen — the residual $r_{d,b}$ has no strict interior mode on $[l,u]$. If moreover $d<0$, then $r_{d,b^\star}$ has no interior mode at all.

*Proof.* Convexity (Proposition 5.12) with Lemma 3.3 forbids strict interior modes. For $d<0$ the endpoint-matched residual is the negative of the $|d|$-case, hence strictly convex, and Lemma 3.3's first half forbids interior modes outright: the maximum sits at an endpoint. $\square$

So the *sign* of the curvature mismatch, not its size, determines whether the endpoint-matched residual bumps upward or dips downward. Over-curved baselines leak peaks; under-curved baselines leak troughs; matched baselines leak nothing.

---

## 6. Trapping the ghost: location bounds and amplitude law

### 6.1 GM $<$ LM $<$ AM, from scratch

**Lemma 6.1 (Hyperbolic normal form).** For $0<A<B$ there exists $s>0$ with
$$B = A\,e^{2s}, \qquad \log B - \log A = 2s .$$
Moreover
$$\sqrt{AB} = A e^{s}, \qquad L(A,B) = A e^{s}\,\frac{\sinh s}{s}, \qquad \frac{A+B}{2} = A e^{s}\cosh s .$$

*Proof.* Take $s = (\log B - \log A)/2 > 0$. Then $\sqrt{AB} = \sqrt{A^2 e^{2s}} = Ae^{s}$; $B - A = A(e^{2s}-1) = 2Ae^{s}\sinh s$, so $L = 2Ae^s\sinh s/(2s)$; and $(A+B)/2 = A(1+e^{2s})/2 = Ae^{s}\cosh s$. $\square$

**Lemma 6.2 ($\tanh s < s$).** For $s>0$, $\sinh s < s\cosh s$.

*Proof.* Let $\varphi(t) = t\cosh t - \sinh t$. Then $\varphi'(t) = \cosh t + t\sinh t - \cosh t = t\sinh t > 0$ for $t>0$, so $\varphi$ is strictly increasing on $[0,\infty)$; since $\varphi(0)=0$, $\varphi(s)>0$ for $s>0$. $\square$

**Lemma 6.3 ($s < \sinh s$).** For $s>0$, $s < \sinh s$. (Immediate from $\sinh s = s + s^3/6 + \cdots$, or from $\sinh' = \cosh \ge 1$ with strictness.)

**Theorem 6.4 (Mean inequalities).** For $0 < A < B$,
$$\sqrt{AB} \;<\; L(A,B) \;<\; \frac{A+B}{2}.$$

*Proof.* By Lemma 6.1 all three equal $Ae^{s}$ times, respectively, $1$, $\sinh(s)/s$, $\cosh s$. The left inequality is $1 < \sinh(s)/s$, i.e. Lemma 6.3; the right is $\sinh(s)/s < \cosh s$, i.e. Lemma 6.2. $\square$

### 6.2 The left-half trap and the falsifier

**Theorem 6.5 (Ghost trapped between geometric mean and midpoint).** Let $d>0$, $-1<l<u$. The strict interior mode $x^\star = L(1+l,1+u)-1$ of the endpoint-matched residual satisfies
$$\sqrt{(1+l)(1+u)} - 1 \;<\; x^\star \;<\; \frac{l+u}{2}.$$

*Proof.* Apply Theorem 6.4 with $A=1+l$, $B=1+u$ and subtract $1$; note $\big((1+l)+(1+u)\big)/2 - 1 = (l+u)/2$. $\square$

**Theorem 6.6 (Right-half falsifier).** Let $d>0$, $-1<l<u$, and let $x \ge (l+u)/2$. Then $x$ is **not** a strict interior mode of the endpoint-matched residual $r_{d,b^\star}$ on $[l,u]$.

*Proof.* By Theorem 5.7 the residual has a strict interior mode at $x^\star$, and by Lemma 3.1 a strict interior mode is unique; so if $x$ were one, $x = x^\star < (l+u)/2$ by Theorem 6.5, contradicting $x \ge (l+u)/2$. $\square$

This is the operationally important statement. **A peak observed in the right half of a window cannot be explained by endpoint-matched curvature leakage of this kind.** The bound is uniform in the mismatch $d$ and in the amplitude of the effect; it depends only on the window.

Quantitatively, the ghost's position as a fraction of the window is
$$\frac{x^\star - l}{u-l} = \frac{L(A,B)-A}{B-A} = \frac{1}{2}\left(\frac{1}{s} - \frac{e^{-s}}{\sinh s}\right) \in \left(0,\tfrac12\right), \qquad s = \tfrac12\log\rho,$$
tending to $1/2$ as $\rho = B/A \to 1$ (narrow windows: the ghost approaches the midpoint) and to $0$ as $\rho \to \infty$ (wide windows: the ghost crowds the left edge). On the unit window $[0,1]$ one gets $x^\star = 1/\log 2 - 1 = 0.442695\ldots$, trapped between $\sqrt 2 - 1 = 0.414214$ and $0.5$.

### 6.3 Amplitude: exactly linear in the mismatch

**Definition 6.7 (Ghost amplitude).** The height of the manufactured bump above the (common) edge value is
$$\mathcal{A}(d,l,u) := r_{d,b^\star}\big(L(A,B)-1\big) - r_{d,b^\star}(l).$$

**Theorem 6.8 (Amplitude law).** For all $d,l,u$,
$$\mathcal{A}(d,l,u) = d \cdot \mathcal{A}(1,l,u),$$
and for $d>0$, $-1<l<u$ we have $\mathcal{A}(d,l,u) > 0$ with the closed form
$$\mathcal{A}(d,l,u) = d\left[\log\frac{L}{A} - 1 + \frac{A}{L}\right], \qquad A = 1+l,\ L = L(A,B).$$

*Proof.* Homogeneity: $b^\star(d,l,u) = d\,b^\star(1,l,u)$ and $r_{d,\,d b}(x) = d\,r_{1,b}(x)$, both immediate from the definitions; the location $L-1$ does not involve $d$ (Theorem 5.5), so both terms in Definition 6.7 scale by $d$. Positivity: by Theorem 5.7 the mode strictly dominates the endpoint $l \ne x^\star$. Closed form: with $b^\star(1,l,u) = -1/L$ (Definition 5.2 rewritten via Definition 2.6), $r_{1,-1/L}(x) = \log(1+x) - x/L$; evaluating at $x = L-1$ and at $x=l$ and subtracting gives $\log(L/A) - (L-A)/L$. Positivity is also visible directly from $\log t > 1 - 1/t$ for $t = L/A > 1$. $\square$

**Corollary 6.9 (Experimental signature).** Doubling the curvature mismatch of a baseline exactly doubles the height of the leakage bump and leaves its location unchanged. A candidate peak that scales linearly with a deliberately injected baseline curvature error, without moving, is leakage; one that moves, or that fails to scale, is not.

Because $\mathcal{A}$ is linear in $d$ and vanishes at $d=0$, the amplitude also provides a *calibration*: measuring the bump height and the window determines the mismatch,
$$d = \mathcal{A}\Big/\left[\log\frac{L}{A} - 1 + \frac{A}{L}\right],$$
which can then be checked against an independent estimate of the baseline exponent.

---

## 7. Binning invariance: coarse-graining cannot create a peak

Histogram binning is the traditional suspect whenever a shape claim is disputed. We clear it in the direction that matters.

**Theorem 7.1 (Sliding a window right lowers the integral).** Let $h>0$ and $s<t$, and let $f$ be continuous on $[s,t+h]$ and strictly antitone there. Then
$$\int_{t}^{t+h} f(x)\,dx \;<\; \int_{s}^{s+h} f(x)\,dx .$$

*Proof.* Change variables to a common offset: both sides equal $\int_0^h f(t+\xi)\,d\xi$ and $\int_0^h f(s+\xi)\,d\xi$. For each $\xi \in [0,h]$ we have $s+\xi < t+\xi$, both in $[s,t+h]$, so $f(t+\xi) \le f(s+\xi)$, with strict inequality at (for instance) $\xi = 0$. Continuity plus a pointwise inequality that is strict at a point gives a strict inequality between the integrals. $\square$

**Definition 7.2 (Block mean).** For a shape $f$, left edge $l$, bin width $h>0$ and index $k \in \mathbb{N}$,
$$\overline{f}_k := \frac1h \int_{l+kh}^{l+kh+h} f(x)\,dx .$$

**Theorem 7.3 (Block averages of a declining power law decline).** Let $C,a>0$, $-1<l$, $h>0$. Then $k \mapsto \overline{(T_{C,a})}_k$ is strictly decreasing on $\mathbb{N}$.

*Proof.* For $j<k$, put $s = l+jh$, $t = l+kh$, so $s<t$ and $s>-1$. On $[s, t+h] \subseteq (-1,\infty)$ the power law is continuous and strictly antitone (Proposition 4.1). Theorem 7.1 gives $\int_t^{t+h}T < \int_s^{s+h}T$; multiply by $1/h>0$. $\square$

**Corollary 7.4 (First bin dominates).** For every $n$, $\overline{(T_{C,a})}_0 = \max_{0\le k \le n} \overline{(T_{C,a})}_k$, attained only at $k=0$.

**Corollary 7.5 (No interior binned peak).** For every $n$ and every $k$ with $0 < k \le n$, it is false that $\overline{(T_{C,a})}_j \le \overline{(T_{C,a})}_k$ for all $j \le n$: no bin other than the first can be a maximum. This is the discrete analogue of Proposition 4.1.

The same argument works verbatim for any continuous strictly antitone shape, not just the power law: **binning can blur or attenuate a peak, but it cannot manufacture one.** Consequently a strictly declining decile profile is not an artefact of the deciles, and — had a peak been observed — it could not have been blamed on the bins either.

---

## 8. Application: the absolute-shape channel

### 8.1 Design

The re-analysis that motivated this development used no binning at all. The data comprise $128$ strata with $9\,594$ hits against $512\,000$ controls, over windows $[j_{\text{lo}}, j_{\text{hi}}]$ of fixed ratio $j_{\text{hi}}/j_{\text{lo}} = 3$. A stratum-conditional case–control logistic model was fitted to raw hit indicators with $128$ profiled intercepts, comparing:

- **H0 (linear):** log-odds affine in position $x$;
- **H1 (free):** log-odds a natural cubic spline with $5$ degrees of freedom, knots at the $0.25/0.5/0.75$ quantiles.

Calibration used within-stratum label permutations ($B=400$, on a design capped at $200$ controls per stratum) and a bootstrap with $150$ replicates. Observed statistics were computed on the full design (design rows: $521\,594$ observations, $1\,024\,000$ control rows); permutation and bootstrap legs ran on the capped design.

### 8.2 Results and their correct reading

| Quantity | Value | Reading under the decomposition |
|---|---|---|
| Free-vs-linear likelihood ratio | $100.574$ on $3$ df | Real curvature |
| Asymptotic $p$ | $1.17\times 10^{-21}$ | — |
| Permutation exceedances | $0/400$, so $p \le 0.0025$ | Curvature is not a calibration artefact |
| Interior maximum $x^\star$ | $0.020$, CI $[0.020,0.020]$ | Pinned to the **left edge** in $150/150$ replicates |
| Peak/end rate ratio | $2.54$, CI $[2.243,2.798]$ | Steep decline |
| Deciles | strictly declining, $1554 \to 694$ | Monotone; cf. Theorem 7.3 |
| Control arm | permutation $p = 0.856$ | Null, as required |
| Mid-window ripple | $+1.6\%$ near the middle | Baseline-relative, not a mode |

By Theorem 4.4, the first two rows and the fourth row are perfectly consistent: the power law is nonlinear *and* mode-free, so a $10^{-21}$ rejection of linearity coexists with a maximum at the extreme left edge. There is no tension to resolve — only a fallacy to avoid.

The registered location criterion (an interior maximum in $[0.4,0.8]$ of the window) **fails**, and fails not marginally but with zero-width confidence interval across all bootstrap replicates. The shape is a cliff.

By Theorem 4.6, the ratio $R = 2.54$ identifies the exponent through $a = \log R/\log\rho$ in the shifted coordinate. The recorded description $T(x) \approx 0.0295\,(1+x)^{-1.104}$ corresponds to an effective window ratio $\rho = R^{1/a} = 2.54^{1/1.104} \approx 2.327$; the confidence interval $[2.243, 2.798]$ on $R$ transfers to $a \in [\log 2.243/\log\rho,\ \log 2.798/\log\rho] \approx [0.957,\ 1.219]$ at $\rho = 2.327$, comfortably bracketing the Dickman-type regime near $a \approx 1$. Corollary 4.7 supplies the crisp test for the boundary case: $R>\rho$ if and only if the decline is steeper than reciprocal.

### 8.3 The erratum

A previously recorded finding reported a *peaked mid-window residual*. Under the present decomposition that finding is retracted and reclassified as **baseline-curvature leakage**:

- The residual was formed against a mixture-Dickman baseline and calibrated at the window edges — exactly the configuration of Lemma 5.3.
- By Theorem 5.7, if the baseline's effective log-curvature exponent exceeds the signal's ($d = a'-a>0$), that configuration *must* display a strict interior maximum, regardless of the positional shape.
- By Corollary 5.8, the underlying signal has no interior mode at all; and by Theorem 5.9, an observed strict interior mode is a certificate of baseline misspecification rather than of positional structure.
- By Theorem 7.3, the alternative scapegoat — binning — is unavailable.

The power-law headline therefore **stands and is strengthened**: it is now re-found binning-free, with a strictly monotone decile profile and a null control arm. The absolute-shape channel closes. Any revival of the peaked claim must be framed as a baseline-misspecification claim, and must then pass two independent tests supplied by §6:

1. **Location.** The candidate peak must lie in the left half of the window, between the geometric mean of the edges and the midpoint (Theorem 6.5). A right-half peak is not explicable by endpoint-matched leakage (Theorem 6.6) — and is therefore evidence either for a different, non-endpoint-matched misspecification or for genuine structure.
2. **Amplitude.** Deliberately perturbing the baseline curvature must scale the peak height exactly linearly, without moving it (Theorem 6.8, Corollary 6.9).

### 8.4 Disclosures

The comparison as executed used two legs: free spline versus linear, with permutation calibration. A monotone $I$-spline / isotonic leg and an exact Dickman-offset leg were not run, so the "beats monotone" clause of the alternative remains untested; this does not affect the conclusion, because the *location* clause of the registered criterion fails independently of it. The permutation floor at $B=400$ is $p \le 0.0025$, above a registered $p<0.001$ threshold that is unattainable at that $B$; the direction of the evidence is nevertheless unambiguous. Permutation and bootstrap legs used capped designs while observed statistics came from the full design. Total wall time $273.4$ s.

---

## 9. Algorithms

Three procedures make the theory operational.

**A. Shape-channel verdict.** Given a fitted profile on a window, decide between "monotone decline" and "interior mode". *Inputs:* profile values or a fitted smooth log-rate, window $[l,u]$, bootstrap replicates. *Steps:* (i) locate the argmax of the profile on the window; (ii) bootstrap the argmax and record its distribution; (iii) if the argmax mass concentrates at or adjacent to an edge, report **no interior mode** — regardless of the linearity test's $p$-value; (iv) independently report the linearity likelihood-ratio statistic as a *curvature* statement only. Complexity: $O(RN)$ for $R$ replicates and $N$ observations.

**B. Ghost locator.** Given only the window, predict where an endpoint-matched leakage artefact must appear: compute $A = 1+l$, $B=1+u$, $L = (B-A)/(\log B - \log A)$, return $x^\star = L-1$ together with the trap $[\sqrt{AB}-1,\ (l+u)/2]$. Complexity $O(1)$. This is a *prediction made before looking at the residual*, which is what makes it a falsifier.

**C. Amplitude-scaling test.** Inject a controlled curvature perturbation $\delta$ into the baseline exponent, recompute the endpoint-matched residual, and regress the observed bump height on $\delta$. Under leakage the regression is exactly linear through the origin with slope $\log(L/A) - 1 + A/L$, and the fitted peak location is constant in $\delta$. Deviations from either prediction falsify the leakage explanation. Complexity: $O(K)$ evaluations for $K$ perturbation levels.

---

## 10. Discussion

### 10.1 What kind of result this is

The three theorems are not deep; they are *load-bearing*. Each closes a specific inferential gap that had been bridged by intuition:

- "The $p$-value is astronomically small, so there must be a peak" — closed by Theorem 4.4.
- "The residual has a clear bump in the middle, so something happens in the middle" — closed by Theorems 5.7, 6.5 and 5.9.
- "Maybe the bins did it" — closed by Theorem 7.3.

The payoff is a *clean closure*: one that prevents both a wrong positional-mode hunt and a wrong retraction of the true power law. Negative results of this shape are cheap to state and expensive to obtain, because they require ruling out the alternative explanations rather than merely failing to find the effect.

### 10.2 The logarithmic mean as a diagnostic constant

It is striking that the artefact's location is a classical mean. The logarithmic mean $L(A,B)$ arises in heat exchanger design (the log-mean temperature difference), in the theory of divided differences ($L(A,B) = 1/\!\int_0^1 (tA+(1-t)B)^{-1}dt$ is the harmonic-integral form), and in the theory of means as the member of the Stolarsky family interpolating geometric and arithmetic. Its appearance here is not a coincidence: the stationarity condition of $d\log(1+x)+bx$ is $1+x = -d/b$, and the endpoint-matching condition makes $-d/b$ literally the divided difference of $\exp$ against $\log$ over the window. The universality of the location — its independence from $d$ — is exactly the statement that the divided difference does not know the size of the mismatch.

### 10.3 Scope and limitations

- The location and amplitude results are proved for the exponential-times-power baseline proxy. Theorem 5.11 shows that *existence* of a ghost is fully general for strictly convex log-excess, but the *pinning* of the location at the logarithmic mean uses the specific $\log(1+x)$ curvature. Extending the location pinning to arbitrary smooth curvature excess is the sharpest open problem here.
- "Endpoint-matched" is essential: a residual tilted by an ordinary least-squares fit rather than by edge matching will move the artefact somewhat. The left-half conclusion should be re-derived for each calibration convention actually used.
- The results are deterministic shape statements. They constrain what a *point estimate* can be, not the sampling distribution around it; the empirical work supplies the latter through permutation and bootstrap.
- Binning invariance is proved for equal-width blocks of a strictly antitone continuous shape. Unequal bins can distort a profile's apparent shape and are not covered.

---

## 11. Future directions

The three developments settle, as theorems, the three inferential steps that the shape closure rested on: (1) nonlinearity does not imply a mode; (2) a mid-window peak is a baseline artefact; (3) binning is innocent. Two sharp, falsifiable quantitative predictions accompany them: the leakage ghost is trapped strictly between the geometric mean of the window edges and the window midpoint, and its amplitude is exactly proportional to the curvature mismatch while its location is independent of it.

Open items not closed here: a rate-layer covariate for the stratum size $N$; a monotone $I$-spline / isotonic leg; and an exact Dickman-offset baseline (we used the analytically tractable exponential-times-power mixture $C'(1+x)^{-a'}e^{-bx}$ as the mixture proxy).

**Direction 1 — Log-mean pinning of curvature-leakage artefacts.** The key insight is that the endpoint-matched tilt cancels the mismatch size $d$ from the stationarity equation $d/(1+x)+b=0$, leaving $1+x^\star = (u-l)/(\log(1+u)-\log(1+l))$, the logarithmic mean — a *universal* location depending only on the window. The two-sided trap $\mathrm{GM} < \mathrm{LM} < \mathrm{AM}$ is now proved, as is the *existence* half for an arbitrary strictly convex curvature excess; what remains is to show that the same *location* pinning survives when the baseline mismatch is an arbitrary smooth curvature excess rather than a pure exponent shift. That would turn "peak in the right half" into a decisive, model-free falsifier for any leakage explanation.

**Direction 2 — Curvature-signed dichotomy for residual shapes.** The key insight is that the sign of the second-derivative mismatch, not its size, decides whether an endpoint-matched residual bumps or dips. A full dichotomy theorem — over-curved baselines yield exactly one interior maximum, under-curved baselines exactly one interior minimum, matched baselines yield a flat residual — would give a complete classification of first-order residual pathologies and, with it, a sign test on the residual's curvature as a one-line diagnostic for baseline misspecification.

**Direction 3 — Rate-layer covariates.** The sole remaining open item on the empirical thread is the rate layer's dependence on stratum size. Since the shape layer is now closed, a covariate model at the rate layer can be estimated without contaminating the shape conclusion — the two layers have been formally separated by the decomposition above.

**Direction 4 — Calibration-convention robustness.** Repeat the location analysis for least-squares-tilted, mean-matched, and quantile-matched residuals. Each convention should produce its own universal location constant; the family of such constants would form a small "atlas of ghosts" usable as a lookup table in applied work.

---

## 12. Conclusion

A likelihood-ratio statistic of $100.574$ on $3$ degrees of freedom, with zero permutation exceedances in $400$ relabelings, establishes that a positional rate profile is not linear. It establishes nothing whatever about a mode, because the fitted alternative — a power law $T(x) = C(1+x)^{-a}$ — is nonlinear and mode-free at once. The observed profile's maximum sits at the left edge of the window in every bootstrap replicate, its deciles decline strictly, and its peak-to-end ratio of $2.54$ measures a steep Dickman-type decline.

The mid-window bump that had been reported is a ghost with a precise address: an endpoint-matched residual against a more-curved baseline must peak at the logarithmic mean of the window edges, strictly between their geometric mean and their midpoint, with a height exactly proportional to the curvature mismatch and a position entirely independent of it. That is not a hedge; it is a prediction, and it can be tested.

The power law stands. The peak does not. And the next mid-window bump anyone reports now has two numbers to answer to.
