# The Ghost in the Baseline

### A guided tour of monotone decline, interior modes, and the logarithmic mean

---

## 0. The question, in one picture

Events happen at positions $x$ inside a window $[l,u]$. You have measured how often. Now you must
decide between two stories:

- **The cliff.** The rate simply falls as you move right. Boring, generic, and produced by dozens of
  uninteresting mechanisms.
- **The hill.** There is a preferred interior location — a *mode* — where events pile up. Exciting,
  specific, and evidence of a mechanism that acts *there*.

Everything in this page is about how to tell those apart, and about the two ways people get it
wrong. By the end you will be able to look at a bump in the middle of a window and say, before
running a single extra experiment, *exactly* where it would have to sit and *exactly* how tall it
would have to be if it were an artefact.

---

## 1. The first trap: a tiny $p$-value that means nothing about peaks

Almost nobody tests "is there a mode?" directly. What actually gets run is a comparison of a
flexible curve against a *straight line* on the log-rate scale, and the resulting likelihood-ratio
statistic gets reported as evidence of "real structure".

Here is the problem. Consider the family that actually fits declining rate data,

$$T(x) = C\,(1+x)^{-a}, \qquad C>0,\ a>0,\ x>-1.$$

Its log-rate is $\log C - a\log(1+x)$, whose second derivative is $a/(1+x)^2 > 0$: **strictly
convex**. A strictly convex function can never agree with a straight line on an interval, so a
linearity test against this truth is *guaranteed* to reject, with a significance that grows without
bound as data accumulate. And yet $T$ is strictly decreasing, so its maximum on any window is the
left edge and nothing else.

> **Nonlinearity Without Mode.** For every $C,a>0$ and every window $[l,u]\subset(-1,\infty)$, the
> power law $T(x)=C(1+x)^{-a}$ simultaneously (i) admits no affine fit to its log-rate, (ii) is
> strictly decreasing, and (iii) has no interior maximum.

Play with it. Push the exponent up and watch the misfit of the best straight line balloon while the
maximum sits stubbornly at the left edge.

{{interactive_demo:1}}

<details>
<summary><b>Click to reveal: why convexity alone forbids interior peaks</b></summary>

Let $f$ be strictly convex on $[l,u]$ and let $x\in(l,u)$ be interior. Then $x=(1-t)l+tu$ for some
$t\in(0,1)$, and strict convexity gives

$$f(x) < (1-t)f(l) + t f(u) \le \max\{f(l), f(u)\}.$$

So $x$ fails to dominate at least one endpoint, and is therefore not a maximum over the window.
Nothing about the specific shape was used — only its curvature. Consequently the *entire* class of
rates with convex log-rate is structurally incapable of the phenomenon a mode-hunt is looking for,
no matter how significant the departure from linearity.

The same computation with merely convex $f$ shows $f(x)\le\max\{f(l),f(u)\}$, which rules out a
*strict* interior mode. In particular an affine residual — the case $f(x)=p+qx$ — can never display
a strict interior peak, a fact we will need in §4.
</details>

<details>
<summary><b>Click to reveal: reading the exponent straight off a ratio</b></summary>

Because the amplitude cancels, the ratio of the rate at the two ends of a window is

$$\frac{T(l)}{T(u)} = \left(\frac{1+u}{1+l}\right)^{a} = \rho^{a},$$

where $\rho$ is the **window ratio** in the shifted coordinate. So one division identifies the
exponent:

$$a = \frac{\log R}{\log\rho}, \qquad R := \frac{T(l)}{T(u)}.$$

Two measurements pin the whole curve — a power law is determined by its values at any two distinct
points, amplitude and exponent both. And there is a memorable threshold hiding in the formula: if
the observed ratio exceeds the window ratio, $R>\rho$, then $a>1$, i.e. the decline is steeper than
reciprocal. That boundary separates a rate whose tail integral diverges logarithmically from one
that converges — see the [Dickman function](https://en.wikipedia.org/wiki/Dickman_function) for the
classical family living near it.
</details>

---

## 2. The second trap: nobody measures an absolute rate

What actually gets reported is a **residual**: the signal divided by a *baseline*, the expected
profile derived from a model of the process that would be running even if nothing interesting were
happening.

Take the baseline in the analytically convenient mixture form $B(x)=C'(1+x)^{-a'}e^{-bx}$, take
logs, and watch almost everything cancel:

$$\log\frac{T(x)}{B(x)} = \log\frac{C}{C'} + \underbrace{d\log(1+x) + bx}_{=:r(x)}, \qquad d := a'-a.$$

Only two numbers survive: the **curvature mismatch** $d$ and the **tilt** $b$. If $d=0$ the residual
is a straight line plus a constant and nothing can happen. If $d\ne0$, it is curved — and curvature
plus one innocuous calibration step is all it takes to invent a peak.

The calibration step is the one every practitioner performs: tilt the residual so that it agrees at
the two ends of the window, absorbing monotone drift and reporting only how the middle deviates from
the ends. That fixes

$$b^\star = -\,d\,\frac{\log(1+u)-\log(1+l)}{u-l}.$$

> **Baseline Leakage Manufactures a Mid-Window Mode.** If $d>0$ — the baseline is more curved than
> the signal — the edge-matched residual $r(x)=d\log(1+x)+b^\star x$ has a genuine strict interior
> maximum on $[l,u]$, even though the signal itself is strictly decreasing and mode-free.

The reason is one line: $r''(x) = -d/(1+x)^2 < 0$, so $r$ is strictly concave; a strictly concave
function with equal values at its two endpoints must bulge upward in between.

---

## 3. The ghost has a precise address

Where exactly does it bulge? Set $r'(x) = d/(1+x) + b^\star = 0$ and substitute the matching tilt:

$$1 + x^\star = \frac{-d}{b^\star} = \frac{u-l}{\log(1+u)-\log(1+l)}.$$

**The mismatch $d$ cancels.** What remains is the
[logarithmic mean](https://en.wikipedia.org/wiki/Logarithmic_mean) of the two window edges in the
shifted coordinate — a constant of the window alone, blind to how badly the baseline was
misspecified. And the logarithmic mean has a classical place in the hierarchy of means:

$$\sqrt{AB} \;<\; \frac{B-A}{\log B-\log A} \;<\; \frac{A+B}{2}, \qquad A = 1+l,\ B = 1+u.$$

> **The Ghost Is Trapped in the Left Half.** $\quad\sqrt{(1+l)(1+u)}-1 \;<\; x^\star \;<\; \dfrac{l+u}{2}.$
>
> A peak observed in the **right half** of a window cannot be produced by this mechanism.

Now go hunting. Move every slider; try to force the peak past the midpoint. It cannot be done.

{{interactive_demo:0}}

<details>
<summary><b>Click to reveal: the hyperbolic proof of GM &lt; LM &lt; AM</b></summary>

Write the window in normal form: $B = A e^{2s}$ with $s>0$, so $\log B - \log A = 2s$. Then

$$\sqrt{AB} = Ae^{s}, \qquad L(A,B) = \frac{B-A}{2s} = Ae^{s}\frac{\sinh s}{s}, \qquad \frac{A+B}{2} = Ae^{s}\cosh s,$$

using $B-A = A(e^{2s}-1) = 2Ae^{s}\sinh s$. All three means are $Ae^{s}$ times, respectively, $1$,
$\sinh(s)/s$ and $\cosh s$, so the whole chain reduces to two elementary inequalities:

- $s < \sinh s$ — immediate from $\sinh s = s + s^3/6 + \cdots$;
- $\tanh s < s$, i.e. $\sinh s < s\cosh s$ — let $\varphi(t) = t\cosh t - \sinh t$; then
  $\varphi'(t) = t\sinh t > 0$ for $t>0$ and $\varphi(0)=0$, so $\varphi(s)>0$.

That is the entire proof of the left-half trap. Everything else in this section is bookkeeping.
</details>

<details>
<summary><b>Click to reveal: the exact tangent-line argument for the peak</b></summary>

Let $d>0$ and $b<0$, put $m := -d/b > 0$ so that $1+x^\star = m$ and $b = -d/m$. For any $y>-1$ set
$t := (1+y)/m > 0$. The strict tangent-line inequality $\log t < t-1$ (valid for all $t>0$, $t\ne1$)
gives

$$d\big(\log(1+y) - \log m\big) < d\left(\frac{1+y}{m}-1\right) = -b\,(y - x^\star).$$

Rearranging, $d\log(1+y) + by < d\log m + b x^\star$, i.e. $r(y) < r(x^\star)$ — and the excluded
case $t=1$ is exactly $y = x^\star$. So the maximum is global on $(-1,\infty)$, unique, and located
at $-d/b - 1$. Feeding in the edge-matching tilt turns $-d/b$ into the logarithmic mean.
</details>

Here is the same story rendered as a static figure, including the exact quantitative version of the
amplitude law we are about to meet:

{{visualization:0}}

---

## 4. The tell: height scales, position does not

A short computation with $L = L(A,B)$ gives the bump's height above the common edge value in closed
form:

$$\mathcal{A}(d) = d\left[\log\frac{L}{A} - 1 + \frac{A}{L}\right] > 0 \quad (d>0),$$

positive because $\log t > 1 - 1/t$ for $t>1$. Two things about this formula matter more than the
formula itself:

1. **It is exactly linear in $d$.** Double the baseline's curvature error and the bump doubles.
2. **The location does not appear.** Doubling $d$ does not move the peak by so much as a
   floating-point ulp.

> **Experimental protocol.** Deliberately perturb the baseline curvature. If the bump scales
> linearly and stays put, it is leakage. If it moves, or fails to scale, it is not.

There is also a sign rule, and it is absolute: if the baseline is *less* curved than the signal
($d<0$), then $r'' = -d/(1+x)^2 > 0$ and the residual is convex, so **no tilt whatsoever** —
calibrated, fitted, or adversarially chosen — can produce an interior maximum. Bump or no bump is
decided by the sign of the mismatch; its magnitude only sets the scale.

{{algorithm:1}}

<details>
<summary><b>Click to reveal: the mechanism is not an artefact of the power-law baseline</b></summary>

Let $g$ be *any* continuous, strictly convex excess in the log-baseline over the window, and tilt by
the secant slope $c = (g(u)-g(l))/(u-l)$. The tilted residual $y \mapsto cy - g(y)$ is concave minus
strictly convex, hence strictly concave, and its endpoint values agree by construction:
$cl - g(l) = cu - g(u)$. A continuous strictly concave function with matching endpoint values
attains its maximum at a unique interior point.

So *existence* of the ghost follows from curvature alone. What the power-law calculation adds is the
*location* — and it is the location, being independent of everything but the window, that makes the
mechanism falsifiable.
</details>

<details>
<summary><b>Click to reveal: the erratum principle, stated precisely</b></summary>

An affine function has no strict interior maximum on an interval. Therefore:

> If $\log T - \log B$ is affine on the window, no strict interior mode can be reported.

Contrapositively, an observed strict interior mode in a log-residual proves that the log-baseline
differs from the log-signal by a **non-affine** function. Within the power-law family the signal
itself cannot supply a mode, so what has been detected is *baseline misspecification*, full stop.
That is why a retraction of a "peaked residual" finding is not a hedge or an appeal to noise: it is
a deduction, and it comes with the two tests above attached.
</details>

---

## 5. But couldn't the bins have done it?

Binning is the traditional scapegoat whenever a shape claim is disputed, so it deserves to be
cleared explicitly. Suppose you average a continuous strictly decreasing shape over equal-width
blocks $[l+kh,\, l+(k+1)h]$. Sliding a fixed-width window to the right strictly lowers its integral,
because at every offset the shifted curve lies strictly below the original. Hence:

> **Block Averages Preserve Decline.** Equal-width block averages of a continuous strictly
> decreasing shape are strictly decreasing, for any bin width. The first bin dominates every later
> bin, and no interior bin can be a maximum.

Binning can blur a peak or flatten it. It cannot conjure one.

{{visualization:1}}

---

## 6. Putting it together: the verdict procedure

Two channels, kept scrupulously separate:

- **Curvature channel.** Likelihood ratio of a free smooth log-rate against a linear-in-$x$ null,
  calibrated by permutations. Verdict: *nonlinear* or *not*. Nothing more.
- **Location channel.** Bootstrap the argmax of the fitted profile. Verdict: *interior* or
  *edge-pinned*.

A positional mode is declared only when the location channel says "interior", stably, inside the
pre-registered band. An edge-pinned bootstrap closes the mode channel regardless of how extreme the
likelihood ratio is.

{{algorithm:2}}

Applied to the record that motivated this work, the two channels say opposite-looking but perfectly
consistent things: a likelihood-ratio statistic of $100.574$ on $3$ degrees of freedom, zero
exceedances in $400$ permutations — and an interior maximum pinned at the extreme left edge in
**every one** of $150$ bootstrap replicates, with strictly declining deciles and a peak-to-end ratio
of $2.54$. That is a cliff described by an enormously significant nonlinearity test. Both are true;
only one of them is about location.

And if you want the exact prediction for where a leakage artefact *would* have to live in your own
window, it costs a handful of logarithms and no data at all:

{{algorithm:0}}

---

## 7. Run the numbers yourself

Every claim on this page is checked numerically below: strict decline and irreducible affine misfit;
exponent recovery from ratios; the residual argmax landing on the logarithmic mean to eight digits;
the trap holding across windows of widely different ratios; amplitude exactly linear and location
exactly immobile; convexity blocking any bump for negative mismatch; block averages declining at
five bin widths; and a verdict pipeline classifying five synthetic profiles.

{{demo:0}}

---

## 8. What to take away

1. **A significance test against a linear alternative measures curvature, not location.** Rejecting
   linearity licenses "not a straight line", and nothing else.
2. **Endpoint-calibrated residuals of curvature-mismatched models bulge in the middle, always.** The
   bulge is a theorem about concavity, not a finding about nature.
3. **The bulge is trapped between the geometric mean and the midpoint of the window**, so it lives
   in the left half; its height is exactly linear in the mismatch and its position is exactly
   independent of it.
4. **Coarse-graining a monotone decline leaves it monotone.**

Any field that fits ratios against models — counts against a luminosity function, coverage against a
composition baseline, a spectrum against a smooth background, incidence against a demographic
expectation — runs this same machinery and is exposed to the same ghost. The remedy is not more
data. It is knowing where the ghost has to stand, and how tall it has to be.

Further reading: [logarithmic mean](https://en.wikipedia.org/wiki/Logarithmic_mean),
[convex function](https://en.wikipedia.org/wiki/Convex_function),
[likelihood-ratio test](https://en.wikipedia.org/wiki/Likelihood-ratio_test),
[Dickman function](https://en.wikipedia.org/wiki/Dickman_function).
